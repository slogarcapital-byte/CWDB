<#
.SYNOPSIS
    Pull GA4 daily-by-page-by-source rows into fact_traffic_daily.

.DESCRIPTION
    Distinct from pull-ga4-7d.ps1 (brief snapshot for daily report). This script
    does warehouse loading at the (date, page, source, medium, campaign) grain.

    Auth: same service-account JWT-bearer pattern as pull-ga4-7d.ps1.

    Default range: last 90 days. Override with -DaysBack <N>.

    form_submits is left at 0 in v1. A future pass can layer in event-level
    counts via a second runReport filtered on eventName='form_submit' or
    'generate_lead', and proportionally distribute across same-day same-page
    source rows.

.NOTES
    Required env vars (read from .env.local at repo root or process env):
      GA4_SERVICE_ACCOUNT_JSON  - Absolute path to service account key file
      GA4_PROPERTY_ID           - Optional override (default 533582902)
      SUPABASE_URL
      SUPABASE_SERVICE_ROLE_KEY

    The service account email must have Viewer access on the GA4 property.
#>

[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [int]    $DaysBack = 90,
    [switch] $SkipSupabase,
    [switch] $DryRun
)

# Self-relaunch under PowerShell 7+ if invoked from 5.1.
if ($PSVersionTable.PSVersion.Major -lt 6) {
    $pwshPath = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
    if (-not $pwshPath) {
        $stub = Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps\pwsh.exe"
        if (Test-Path $stub) { $pwshPath = $stub }
    }
    if (-not $pwshPath) {
        throw "Requires PowerShell 7+. Install: winget install --id Microsoft.PowerShell --source winget --force"
    }
    $relaunchArgs = @()
    foreach ($k in $PSBoundParameters.Keys) {
        $v = $PSBoundParameters[$k]
        if ($v -is [switch]) {
            if ($v.IsPresent) { $relaunchArgs += "-$k" }
        } else {
            $relaunchArgs += "-$k"
            $relaunchArgs += [string] $v
        }
    }
    & $pwshPath -NoProfile -File $PSCommandPath @relaunchArgs
    exit $LASTEXITCODE
}

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\load-supabase.ps1"

$DataDir  = Join-Path $RepoRoot "_vault\data"
$OutFile  = Join-Path $DataDir "ga4-warehouse-latest.json"
$ErrorLog = Join-Path $DataDir "ga4-warehouse-error.log"
$EnvFile  = Join-Path $RepoRoot ".env.local"

if (-not (Test-Path $DataDir)) { New-Item -ItemType Directory -Path $DataDir -Force | Out-Null }

function Write-ErrorLog {
    param([string] $Message)
    Add-Content -Path $ErrorLog -Value "[$((Get-Date).ToString('o'))] $Message" -Encoding utf8
}

function Load-DotEnv {
    param([string] $Path)
    if (-not (Test-Path $Path)) { return }
    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $idx  = $line.IndexOf("=")
            $name = $line.Substring(0, $idx).Trim()
            $val  = $line.Substring($idx + 1).Trim().Trim("'`"")
            if ($name -and -not [Environment]::GetEnvironmentVariable($name, "Process")) {
                [Environment]::SetEnvironmentVariable($name, $val, "Process")
            }
        }
    }
}

function Get-ServiceAccountAccessToken {
    param(
        [Parameter(Mandatory)] [string] $KeyFilePath,
        [Parameter(Mandatory)] [string] $Scope
    )
    if (-not (Test-Path $KeyFilePath)) { throw "Service account key file not found: $KeyFilePath" }
    $key = Get-Content $KeyFilePath -Raw | ConvertFrom-Json

    if (-not $key.client_email) { throw "Service account JSON missing client_email" }
    if (-not $key.private_key)  { throw "Service account JSON missing private_key" }
    if (-not $key.token_uri)    { $key | Add-Member -NotePropertyName token_uri -NotePropertyValue "https://oauth2.googleapis.com/token" -Force }

    function ConvertTo-Base64Url([byte[]] $bytes) {
        return [Convert]::ToBase64String($bytes).TrimEnd('=').Replace('+','-').Replace('/','_')
    }

    $now    = [int][double]::Parse((Get-Date -UFormat %s))
    $header = @{ alg = "RS256"; typ = "JWT" } | ConvertTo-Json -Compress
    $claim  = @{
        iss   = $key.client_email
        scope = $Scope
        aud   = $key.token_uri
        exp   = $now + 3600
        iat   = $now
    } | ConvertTo-Json -Compress

    $headerB64 = ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes($header))
    $claimB64  = ConvertTo-Base64Url ([Text.Encoding]::UTF8.GetBytes($claim))
    $signingInput = "$headerB64.$claimB64"

    $rsa = [System.Security.Cryptography.RSA]::Create()
    $rsa.ImportFromPem($key.private_key.ToCharArray())

    $sigBytes = $rsa.SignData(
        [Text.Encoding]::UTF8.GetBytes($signingInput),
        [System.Security.Cryptography.HashAlgorithmName]::SHA256,
        [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
    )
    $sigB64 = ConvertTo-Base64Url $sigBytes
    $jwt = "$signingInput.$sigB64"

    $body = @{
        grant_type = "urn:ietf:params:oauth:grant-type:jwt-bearer"
        assertion  = $jwt
    }
    $resp = Invoke-RestMethod -Method Post -Uri $key.token_uri -Body $body -ContentType "application/x-www-form-urlencoded"
    if (-not $resp.access_token) { throw "Service account token exchange returned no access_token" }
    return $resp.access_token
}

function Invoke-GA4RunReport {
    <#
    .SYNOPSIS
        Page through a GA4 runReport response and return all rows.
    #>
    param(
        [Parameter(Mandatory)] [string] $AccessToken,
        [Parameter(Mandatory)] [string] $PropertyId,
        [Parameter(Mandatory)] [hashtable] $RequestBody,
        [int] $PageSize = 10000
    )
    $url = "https://analyticsdata.googleapis.com/v1beta/properties/$PropertyId" + ":runReport"
    $headers = @{ "Authorization" = "Bearer $AccessToken"; "Content-Type" = "application/json" }
    $all = New-Object System.Collections.Generic.List[object]
    $offset = 0
    do {
        $RequestBody['limit']  = $PageSize
        $RequestBody['offset'] = $offset
        $bodyJson = $RequestBody | ConvertTo-Json -Depth 8
        $resp = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $bodyJson -ErrorAction Stop
        $rows = @($resp.rows)
        foreach ($r in $rows) { $all.Add($r) }
        $rowCount = if ($null -ne $resp.rowCount) { [int] $resp.rowCount } else { $all.Count }
        $offset = $offset + $rows.Count
        $more = ($rows.Count -eq $PageSize) -and ($offset -lt $rowCount)
    } while ($more)
    return ,$all.ToArray()
}

try {
    Load-DotEnv -Path $EnvFile
    Load-DotEnvIfNeeded -RepoRoot $RepoRoot

    $keyPath    = $env:GA4_SERVICE_ACCOUNT_JSON
    $propertyId = $env:GA4_PROPERTY_ID
    if (-not $propertyId) { $propertyId = "533582902" }

    if (-not $keyPath) {
        throw "Missing GA4_SERVICE_ACCOUNT_JSON. See operations/automation/api-credentials/README.md"
    }

    $since = (Get-Date).AddDays(-$DaysBack).ToString("yyyy-MM-dd")
    $until = (Get-Date).ToString("yyyy-MM-dd")

    Write-Output "GA4 access token..."
    $accessToken = Get-ServiceAccountAccessToken `
        -KeyFilePath $keyPath `
        -Scope "https://www.googleapis.com/auth/analytics.readonly"

    Write-Output "Pulling GA4 daily traffic ($since -> $until)..."
    $reqBody = @{
        dateRanges = @(@{ startDate = $since; endDate = $until })
        dimensions = @(
            @{ name = "date" },
            @{ name = "pagePath" },
            @{ name = "sessionSource" },
            @{ name = "sessionMedium" },
            @{ name = "sessionCampaignName" }
        )
        metrics    = @(
            @{ name = "sessions" },
            @{ name = "totalUsers" },
            @{ name = "engagedSessions" },
            @{ name = "conversions" }
        )
        orderBys   = @(@{ dimension = @{ dimensionName = "date" }; desc = $false })
    }

    $rows = Invoke-GA4RunReport -AccessToken $accessToken -PropertyId $propertyId -RequestBody $reqBody
    Write-Output "  -> $($rows.Count) (date, page, source, medium, campaign) rows"

    @{
        pulled_at   = (Get-Date).ToUniversalTime().ToString("o")
        source      = "ga4-warehouse"
        data        = @{
            property_id = $propertyId
            since       = $since
            until       = $until
            row_count   = $rows.Count
        }
        error       = $null
    } | ConvertTo-Json -Depth 32 | Out-File -FilePath $OutFile -Encoding utf8 -Force

    if ($SkipSupabase) { Write-Output "SkipSupabase: snapshot only. Done."; exit 0 }

    Initialize-SupabaseClient
    $capturedAt = (Get-Date).ToUniversalTime().ToString("o")

    $records = New-Object System.Collections.Generic.List[hashtable]
    foreach ($r in $rows) {
        $dv = $r.dimensionValues
        $mv = $r.metricValues
        # date arrives as yyyymmdd
        $dateStr = $dv[0].value
        if ($dateStr.Length -ne 8) { continue }
        $sessionDate = "$($dateStr.Substring(0,4))-$($dateStr.Substring(4,2))-$($dateStr.Substring(6,2))"

        $pagePath = $dv[1].value
        $source   = $dv[2].value;  if (-not $source)   { $source   = "(none)" }
        $medium   = $dv[3].value;  if (-not $medium)   { $medium   = "(none)" }
        $campaign = $dv[4].value;  if (-not $campaign) { $campaign = "(none)" }

        $records.Add(@{
            session_date      = $sessionDate
            page_path         = $pagePath
            source            = $source
            medium            = $medium
            campaign          = $campaign
            sessions          = [int64] $mv[0].value
            users             = [int64] $mv[1].value
            engaged_sessions  = [int64] $mv[2].value
            form_submits      = 0
            conversions       = [int64] [math]::Round([double] $mv[3].value)
            updated_at        = $capturedAt
        })
    }

    if ($DryRun) {
        Write-Output "DryRun: would upsert $($records.Count) fact_traffic_daily rows"
    } elseif ($records.Count -gt 0) {
        $n = Invoke-SupabaseUpsert -Table "fact_traffic_daily" -Records $records.ToArray() -ConflictColumns "session_date,page_path,source,medium,campaign"
        Write-Output "Upserted $n rows into fact_traffic_daily"
    } else {
        Write-Output "No rows to upsert."
    }

    Write-Output "ga4 warehouse pull OK"
    exit 0
}
catch {
    $msg = "ga4 warehouse pull FAILED: $($_.Exception.Message)"
    Write-ErrorLog -Message $msg
    @{ pulled_at = (Get-Date).ToUniversalTime().ToString("o"); source = "ga4-warehouse"; data = $null; error = $_.Exception.Message } |
        ConvertTo-Json -Depth 5 | Out-File -FilePath $OutFile -Encoding utf8 -Force
    Write-Error $msg
    exit 1
}
