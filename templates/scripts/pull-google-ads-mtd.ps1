<#
.SYNOPSIS
    Pull Google Ads MTD performance data for CWDB and write to JSON snapshot.

.DESCRIPTION
    Authenticates to Google Ads API via OAuth2 refresh token, runs a GAQL query for
    month-to-date performance on customer 712-991-0870, and writes a normalized JSON
    file at _vault/data/google-ads-latest.json. Idempotent - safe to re-run mid-day.

    On any error, writes to _vault/data/google-ads-error.log and exits non-zero.

.NOTES
    Required env vars (read from .env.local at repo root or process env):
      GOOGLE_ADS_DEVELOPER_TOKEN      - Approved dev token (Standard access)
      GOOGLE_ADS_CLIENT_ID            - OAuth2 client ID (from Google Cloud Console)
      GOOGLE_ADS_CLIENT_SECRET        - OAuth2 client secret
      GOOGLE_ADS_REFRESH_TOKEN        - Long-lived refresh token (read-only scope)
      GOOGLE_ADS_LOGIN_CUSTOMER_ID    - Manager (MCC) customer ID, digits only, OPTIONAL
      GOOGLE_ADS_CUSTOMER_ID          - Target customer ID, digits only (default: 7129910870)

    Output schema:
      { "pulled_at": ISO8601, "source": "google-ads", "data": {...}, "error": null }
#>

[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$DataDir   = Join-Path $RepoRoot "_vault\data"
$OutFile   = Join-Path $DataDir "google-ads-latest.json"
$ErrorLog  = Join-Path $DataDir "google-ads-error.log"
$EnvFile   = Join-Path $RepoRoot ".env.local"

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

try {
    Load-DotEnv -Path $EnvFile

    $devToken     = $env:GOOGLE_ADS_DEVELOPER_TOKEN
    $clientId     = $env:GOOGLE_ADS_CLIENT_ID
    $clientSecret = $env:GOOGLE_ADS_CLIENT_SECRET
    $refreshToken = $env:GOOGLE_ADS_REFRESH_TOKEN
    $loginCust    = $env:GOOGLE_ADS_LOGIN_CUSTOMER_ID
    $customerId   = $env:GOOGLE_ADS_CUSTOMER_ID
    if (-not $customerId) { $customerId = "7129910870" }

    $missing = @()
    foreach ($pair in @(
        @{ Name = "GOOGLE_ADS_DEVELOPER_TOKEN"; Val = $devToken },
        @{ Name = "GOOGLE_ADS_CLIENT_ID";       Val = $clientId },
        @{ Name = "GOOGLE_ADS_CLIENT_SECRET";   Val = $clientSecret },
        @{ Name = "GOOGLE_ADS_REFRESH_TOKEN";   Val = $refreshToken }
    )) {
        if (-not $pair.Val) { $missing += $pair.Name }
    }
    if ($missing.Count -gt 0) {
        throw "Missing required env vars: $($missing -join ', '). See operations/automation/api-credentials/README.md"
    }

    # 1) Exchange refresh token for short-lived access token
    $tokenBody = @{
        client_id     = $clientId
        client_secret = $clientSecret
        refresh_token = $refreshToken
        grant_type    = "refresh_token"
    }
    $tokenResp = Invoke-RestMethod -Method Post `
        -Uri "https://oauth2.googleapis.com/token" `
        -Body $tokenBody `
        -ContentType "application/x-www-form-urlencoded" `
        -ErrorAction Stop
    $accessToken = $tokenResp.access_token
    if (-not $accessToken) { throw "OAuth token exchange returned no access_token" }

    # 2) Build MTD GAQL query at the customer level
    $gaql = @"
SELECT
    customer.id,
    customer.descriptive_name,
    metrics.cost_micros,
    metrics.impressions,
    metrics.clicks,
    metrics.ctr,
    metrics.conversions,
    metrics.conversions_value,
    metrics.cost_per_conversion
FROM customer
WHERE segments.date DURING THIS_MONTH
"@

    $headers = @{
        "Authorization"    = "Bearer $accessToken"
        "developer-token"  = $devToken
        "Content-Type"     = "application/json"
    }
    if ($loginCust) { $headers["login-customer-id"] = $loginCust }

    $body = @{ query = $gaql } | ConvertTo-Json -Depth 5
    $apiVersion = "v18"
    $url = "https://googleads.googleapis.com/$apiVersion/customers/$customerId/googleAds:search"

    $resp = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body -ErrorAction Stop

    # 3) Aggregate (single row at customer level, but loop defensively)
    $costMicros = 0; $impressions = 0; $clicks = 0; $conversions = 0.0; $convValue = 0.0
    if ($resp.results) {
        foreach ($r in $resp.results) {
            $costMicros  += [int64]   ($r.metrics.costMicros       | ForEach-Object { $_ })
            $impressions += [int64]   ($r.metrics.impressions      | ForEach-Object { $_ })
            $clicks      += [int64]   ($r.metrics.clicks           | ForEach-Object { $_ })
            $conversions += [double]  ($r.metrics.conversions      | ForEach-Object { $_ })
            $convValue   += [double]  ($r.metrics.conversionsValue | ForEach-Object { $_ })
        }
    }

    $spend = [math]::Round($costMicros / 1000000.0, 2)
    $ctr   = if ($impressions -gt 0) { [math]::Round(($clicks / [double]$impressions) * 100, 2) } else { 0 }
    $cpa   = if ($conversions -gt 0) { [math]::Round($spend / $conversions, 2) } else { 0 }

    $out = [ordered]@{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "google-ads"
        data      = [ordered]@{
            customer_id        = $customerId
            date_range         = "THIS_MONTH"
            spend              = $spend
            impressions        = $impressions
            clicks             = $clicks
            ctr_percent        = $ctr
            conversions        = $conversions
            conversions_value  = [math]::Round($convValue, 2)
            cost_per_conversion = $cpa
        }
        error     = $null
    }

    $out | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutFile -Encoding utf8 -Force
    Write-Output "google-ads pull OK: spend=`$$spend impressions=$impressions clicks=$clicks conv=$conversions"
    exit 0
}
catch {
    $msg = "google-ads pull FAILED: $($_.Exception.Message)"
    Write-ErrorLog -Message $msg
    # Also write a stub JSON marking the failure so brief skill can detect staleness vs. error
    $stub = [ordered]@{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "google-ads"
        data      = $null
        error     = $_.Exception.Message
    } | ConvertTo-Json -Depth 5
    try { $stub | Out-File -FilePath $OutFile -Encoding utf8 -Force } catch {}
    Write-Error $msg
    exit 1
}
