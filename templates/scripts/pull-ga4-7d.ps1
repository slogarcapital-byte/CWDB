<#
.SYNOPSIS
    Pull GA4 Data API last-7-day snapshot for CWDB and write JSON.

.DESCRIPTION
    Authenticates with a Google Cloud Service Account JSON key, calls the GA4 Data API
    (analyticsdata.googleapis.com:runReport) on the CWDB property, and writes a
    normalized JSON file at _vault/data/ga4-latest.json. Idempotent.

    Property ID resolution order:
      1. $env:GA4_PROPERTY_ID
      2. Default: 533582902 (CWDB property, measurement G-ZQ19JEF9KC, confirmed 2026-04-25)

.NOTES
    Required env vars (read from .env.local at repo root or process env):
      GA4_SERVICE_ACCOUNT_JSON  - Absolute path to the downloaded service account key file
      GA4_PROPERTY_ID           - Optional override of the GA4 property ID (digits only)

    The service account email in the JSON key file MUST be granted Viewer access on
    the GA4 property (Admin -> Property Access Management). See README.md.

    Output schema:
      { "pulled_at": ISO8601, "source": "ga4", "data": {...}, "error": null }
#>

[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$DataDir  = Join-Path $RepoRoot "_vault\data"
$OutFile  = Join-Path $DataDir "ga4-latest.json"
$ErrorLog = Join-Path $DataDir "ga4-error.log"
$EnvFile  = Join-Path $RepoRoot ".env.local"

if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
}

function Write-ErrorLog {
    param([string] $Message)
    $stamp = (Get-Date).ToString("o")
    Add-Content -Path $ErrorLog -Value "[$stamp] $Message" -Encoding utf8
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

# Build a Google service account JWT and exchange for an access token.
# Avoids any Python / SDK dependency.
function Get-ServiceAccountAccessToken {
    param(
        [Parameter(Mandatory)] [string] $KeyFilePath,
        [Parameter(Mandatory)] [string] $Scope
    )
    if (-not (Test-Path $KeyFilePath)) { throw "Service account key file not found: $KeyFilePath" }
    $key = Get-Content $KeyFilePath -Raw | ConvertFrom-Json

    if (-not $key.client_email)  { throw "Service account JSON missing client_email" }
    if (-not $key.private_key)   { throw "Service account JSON missing private_key" }
    if (-not $key.token_uri)     { $key | Add-Member -NotePropertyName token_uri -NotePropertyValue "https://oauth2.googleapis.com/token" -Force }

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

    # Import PEM private key into RSA. .NET 4.7.2+ on Win10/11 supports ImportFromPem on RSA via RSACng.
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

try {
    Load-DotEnv -Path $EnvFile

    $keyPath    = $env:GA4_SERVICE_ACCOUNT_JSON
    $propertyId = $env:GA4_PROPERTY_ID
    if (-not $propertyId) { $propertyId = "533582902" }   # CWDB property, confirmed 2026-04-25

    if (-not $keyPath) {
        throw "Missing required env var: GA4_SERVICE_ACCOUNT_JSON. See operations/automation/api-credentials/README.md"
    }

    $accessToken = Get-ServiceAccountAccessToken `
        -KeyFilePath $keyPath `
        -Scope "https://www.googleapis.com/auth/analytics.readonly"

    # 1) Sessions / users / conversion rate
    $body1 = @{
        dateRanges = @(@{ startDate = "7daysAgo"; endDate = "today" })
        metrics    = @(
            @{ name = "sessions" },
            @{ name = "totalUsers" },
            @{ name = "userEngagementDuration" },
            @{ name = "conversions" }
        )
    } | ConvertTo-Json -Depth 8

    # 2) Top channel by sessions (sessionDefaultChannelGroup)
    $body2 = @{
        dateRanges = @(@{ startDate = "7daysAgo"; endDate = "today" })
        dimensions = @(@{ name = "sessionDefaultChannelGroup" })
        metrics    = @(@{ name = "sessions" })
        orderBys   = @(@{ metric = @{ metricName = "sessions" }; desc = $true })
        limit      = 1
    } | ConvertTo-Json -Depth 8

    $headers = @{ "Authorization" = "Bearer $accessToken"; "Content-Type" = "application/json" }
    $url     = "https://analyticsdata.googleapis.com/v1beta/properties/$propertyId" + ":runReport"

    $r1 = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body1 -ErrorAction Stop
    $r2 = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body2 -ErrorAction Stop

    $sessions = 0; $users = 0; $conversions = 0.0
    if ($r1.rows -and $r1.rows.Count -gt 0) {
        $row = $r1.rows[0]
        $sessions    = [int64]  $row.metricValues[0].value
        $users       = [int64]  $row.metricValues[1].value
        $conversions = [double] $row.metricValues[3].value
    }
    $convRate = if ($sessions -gt 0) { [math]::Round(($conversions / [double]$sessions) * 100, 2) } else { 0 }

    $topChannel = "(none)"; $topChannelSessions = 0
    if ($r2.rows -and $r2.rows.Count -gt 0) {
        $topChannel         = $r2.rows[0].dimensionValues[0].value
        $topChannelSessions = [int64] $r2.rows[0].metricValues[0].value
    }

    $out = [ordered]@{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "ga4"
        data      = [ordered]@{
            property_id            = $propertyId
            date_range             = "7daysAgo..today"
            sessions               = $sessions
            users                  = $users
            conversions            = $conversions
            conversion_rate_percent = $convRate
            top_channel            = $topChannel
            top_channel_sessions   = $topChannelSessions
        }
        error     = $null
    }

    $out | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutFile -Encoding utf8 -Force
    Write-Output "ga4 pull OK: sessions=$sessions users=$users conv=$conversions topChannel=$topChannel"
    exit 0
}
catch {
    $msg = "ga4 pull FAILED: $($_.Exception.Message)"
    Write-ErrorLog -Message $msg
    $stub = [ordered]@{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "ga4"
        data      = $null
        error     = $_.Exception.Message
    } | ConvertTo-Json -Depth 5
    try { $stub | Out-File -FilePath $OutFile -Encoding utf8 -Force } catch {}
    Write-Error $msg
    exit 1
}
