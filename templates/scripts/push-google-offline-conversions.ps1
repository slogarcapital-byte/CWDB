<#
.SYNOPSIS
    Upload pending Google Ads offline conversions from conversions_outbox.

.DESCRIPTION
    Outbox pattern (design refinement, 2026-07-13): the jobtread-gateway Edge
    Function queues a conversions_outbox row when a job transitions into
    "Signed / Booked"; this worker runs on the laptop (daily cron source #6)
    and uploads ClickConversions using the SAME Google Ads credentials as
    pull-google-ads-warehouse.ps1. Google accepts click conversions up to 90
    days old, so daily batching loses nothing.

    Rows transition pending -> uploaded | failed. partialFailure=true so one
    bad gclid never sinks the batch. Exits 0 (no-op) while
    GOOGLE_ADS_JT_CONVERSION_ACTION is unset so run-daily stays green until
    the conversion action is created in the Google Ads UI.

.NOTES
    Required env vars (.env.local):
      GOOGLE_ADS_DEVELOPER_TOKEN, GOOGLE_ADS_CLIENT_ID, GOOGLE_ADS_CLIENT_SECRET,
      GOOGLE_ADS_REFRESH_TOKEN, GOOGLE_ADS_CUSTOMER_ID,
      GOOGLE_ADS_LOGIN_CUSTOMER_ID (optional),
      GOOGLE_ADS_JT_CONVERSION_ACTION (customers/<cid>/conversionActions/<id>),
      SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
#>
[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [switch] $DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\load-supabase.ps1"
Load-DotEnvIfNeeded -RepoRoot $RepoRoot

$ApiVersion = "v21"   # keep in lockstep with pull-google-ads-warehouse.ps1

$convAction = [Environment]::GetEnvironmentVariable("GOOGLE_ADS_JT_CONVERSION_ACTION", "Process")
if (-not $convAction) {
    Write-Host "GOOGLE_ADS_JT_CONVERSION_ACTION not set; skipping upload (no-op). Create the conversion action in Google Ads UI first."
    exit 0
}

Initialize-SupabaseClient
$base    = ($env:SUPABASE_URL -replace '/rest/v1/?$', '')
$sbHead  = @{ apikey = $env:SUPABASE_SERVICE_ROLE_KEY; Authorization = "Bearer $($env:SUPABASE_SERVICE_ROLE_KEY)"; "Content-Type" = "application/json" }

# 1) pending rows
$pending = @(Invoke-RestMethod -Uri "$base/rest/v1/conversions_outbox?status=eq.pending&platform=eq.google_ads&select=id,gclid,conversion_time,conversion_value_cents,currency&order=id.asc&limit=200" -Headers $sbHead)
if ($pending.Count -eq 0) {
    Write-Host "no pending conversions; done"
    exit 0
}
Write-Host ("pending conversions: {0}" -f $pending.Count)

if ($DryRun) {
    $pending | ForEach-Object { Write-Host ("WOULD UPLOAD outbox id {0} gclid {1}" -f $_.id, $_.gclid) }
    exit 0
}

# 2) OAuth refresh (same pattern as pull-google-ads-warehouse.ps1)
$tokenResp = Invoke-RestMethod -Method Post `
    -Uri "https://oauth2.googleapis.com/token" `
    -Body @{
        client_id     = $env:GOOGLE_ADS_CLIENT_ID
        client_secret = $env:GOOGLE_ADS_CLIENT_SECRET
        refresh_token = $env:GOOGLE_ADS_REFRESH_TOKEN
        grant_type    = "refresh_token"
    }
$accessToken = $tokenResp.access_token
if (-not $accessToken) { throw "OAuth token exchange returned no access_token" }

$customerId = $env:GOOGLE_ADS_CUSTOMER_ID
if (-not $customerId) { $customerId = "7129910870" }
$gHead = @{
    "Authorization"   = "Bearer $accessToken"
    "developer-token" = $env:GOOGLE_ADS_DEVELOPER_TOKEN
    "Content-Type"    = "application/json"
}
$loginCust = [Environment]::GetEnvironmentVariable("GOOGLE_ADS_LOGIN_CUSTOMER_ID", "Process")
if ($loginCust) { $gHead["login-customer-id"] = $loginCust }

# 3) build ClickConversions. conversionDateTime format: "yyyy-MM-dd HH:mm:ssK"
#    with an explicit offset (K gives +00:00 for UTC).
$conversions = @()
foreach ($row in $pending) {
    $dt = ([DateTimeOffset]::Parse($row.conversion_time)).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:sszzz")
    $conv = @{
        gclid              = $row.gclid
        conversionAction   = $convAction
        conversionDateTime = $dt
        conversionValue    = $(if ($row.conversion_value_cents) { [math]::Round($row.conversion_value_cents / 100.0, 2) } else { 0 })
        currencyCode       = $(if ($row.currency) { $row.currency } else { "USD" })
    }
    $conversions += ,$conv
}

$uploadBody = @{ conversions = $conversions; partialFailure = $true } | ConvertTo-Json -Depth 8
$url = "https://googleads.googleapis.com/$ApiVersion/customers/${customerId}:uploadClickConversions"

$stamp = (Get-Date).ToUniversalTime().ToString("o")
try {
    $resp = Invoke-RestMethod -Method Post -Uri $url -Headers $gHead -Body $uploadBody
} catch {
    $msg = if ($_.ErrorDetails) { $_.ErrorDetails.Message } else { $_.Exception.Message }
    # whole-batch failure: mark all attempted rows failed with the error
    foreach ($row in $pending) {
        $patch = @{ status = "failed"; error = $msg.Substring(0, [Math]::Min(300, $msg.Length)) } | ConvertTo-Json
        Invoke-RestMethod -Method Patch -Uri "$base/rest/v1/conversions_outbox?id=eq.$($row.id)" -Headers $sbHead -Body $patch | Out-Null
    }
    throw "uploadClickConversions failed: $msg"
}

# 4) partial-failure handling: error details index into the conversions array
$failedIdx = @{}
$pfe = $null
if ($resp.PSObject.Properties.Name -contains 'partialFailureError' -and $resp.partialFailureError) {
    $pfe = $resp.partialFailureError
    Write-Host "partial failures reported: $($pfe.message)"
    if ($pfe.PSObject.Properties.Name -contains 'details') {
        foreach ($detail in @($pfe.details)) {
            if ($detail.PSObject.Properties.Name -contains 'errors') {
                foreach ($e in @($detail.errors)) {
                    $idx = $null
                    if ($e.PSObject.Properties.Name -contains 'location' -and $e.location -and ($e.location.PSObject.Properties.Name -contains 'fieldPathElements')) {
                        $fe = @($e.location.fieldPathElements) | Where-Object { $_.fieldName -eq 'conversions' } | Select-Object -First 1
                        if ($fe -and ($fe.PSObject.Properties.Name -contains 'index')) { $idx = [int]$fe.index }
                    }
                    if ($null -ne $idx) { $failedIdx[$idx] = $e.message }
                }
            }
        }
    }
}

$ok = 0; $bad = 0
for ($i = 0; $i -lt $pending.Count; $i++) {
    $row = $pending[$i]
    if ($failedIdx.ContainsKey($i)) {
        $emsg = "$($failedIdx[$i])"
        $patch = @{ status = "failed"; error = $emsg.Substring(0, [Math]::Min(300, $emsg.Length)) } | ConvertTo-Json
        $bad++
    } else {
        $patch = @{ status = "uploaded"; uploaded_at = $stamp; error = $null } | ConvertTo-Json
        $ok++
    }
    Invoke-RestMethod -Method Patch -Uri "$base/rest/v1/conversions_outbox?id=eq.$($row.id)" -Headers $sbHead -Body $patch | Out-Null
}

Write-Host ("uploaded={0} failed={1}" -f $ok, $bad)
exit 0
