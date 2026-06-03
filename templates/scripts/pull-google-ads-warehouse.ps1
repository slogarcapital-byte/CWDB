<#
.SYNOPSIS
    Pull Google Ads campaign hierarchy + per-day ad spend into the CWDB warehouse.

.DESCRIPTION
    Distinct from pull-google-ads-mtd.ps1 which writes a single MTD aggregate for the
    daily brief. This script does granular warehouse loading:

      dim_campaign     <- one row per campaign in the Google Ads account
      dim_ad_group     <- one row per ad group (FK -> dim_campaign)
      dim_ad           <- one row per responsive search ad (FK -> dim_ad_group)
      fact_ad_spend_daily <- one row per (ad, day) with cost/impressions/clicks/conversions

    Idempotent. UPSERTs on natural keys (platform_*_id) so re-runs replace.

.NOTES
    Required env vars (same as pull-google-ads-mtd.ps1):
      GOOGLE_ADS_DEVELOPER_TOKEN   - approved dev token (Standard or Test access)
      GOOGLE_ADS_CLIENT_ID         - OAuth2 client ID
      GOOGLE_ADS_CLIENT_SECRET     - OAuth2 client secret
      GOOGLE_ADS_REFRESH_TOKEN     - long-lived refresh token (scope: adwords)
      GOOGLE_ADS_CUSTOMER_ID       - target customer ID (digits only, default 7129910870)
      GOOGLE_ADS_LOGIN_CUSTOMER_ID - optional MCC login customer
      SUPABASE_URL
      SUPABASE_SERVICE_ROLE_KEY

    Date range default: last 90 days. Override with -DaysBack <N>.

    Output: also writes _vault/data/google-ads-warehouse-latest.json for inspection.
#>

[CmdletBinding()]
param(
    [string] $RepoRoot   = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [int]    $DaysBack   = 90,
    [switch] $SkipSupabase,
    [switch] $DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\load-supabase.ps1"

$DataDir  = Join-Path $RepoRoot "_vault\data"
$OutFile  = Join-Path $DataDir "google-ads-warehouse-latest.json"
$ErrorLog = Join-Path $DataDir "google-ads-warehouse-error.log"
$EnvFile  = Join-Path $RepoRoot ".env.local"
$ApiVersion = "v21"

if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
}

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

function Get-PropOrNull {
    param([Parameter(Mandatory)] $InputObject, [Parameter(Mandatory)] [string] $Name)
    if ($null -eq $InputObject) { return $null }
    if (-not ($InputObject.PSObject.Properties.Name -contains $Name)) { return $null }
    return $InputObject.$Name
}

function Invoke-GAQL {
    param(
        [Parameter(Mandatory)] [string] $CustomerId,
        [Parameter(Mandatory)] [string] $AccessToken,
        [Parameter(Mandatory)] [string] $DevToken,
        [Parameter(Mandatory)] [string] $Query,
        [string] $LoginCustomerId = $null
    )
    $headers = @{
        "Authorization"   = "Bearer $AccessToken"
        "developer-token" = $DevToken
        "Content-Type"    = "application/json"
    }
    if ($LoginCustomerId) { $headers["login-customer-id"] = $LoginCustomerId }
    $body = @{ query = $Query } | ConvertTo-Json -Depth 5
    $url  = "https://googleads.googleapis.com/$ApiVersion/customers/$CustomerId/googleAds:searchStream"
    $resp = Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body -ErrorAction Stop

    # searchStream returns an array of pages; concatenate results.
    $all = New-Object System.Collections.Generic.List[object]
    if ($resp -is [array]) {
        foreach ($page in $resp) {
            $results = @(Get-PropOrNull $page "results")
            foreach ($r in $results) { $all.Add($r) }
        }
    } else {
        $results = @(Get-PropOrNull $resp "results")
        foreach ($r in $results) { $all.Add($r) }
    }
    return ,$all.ToArray()
}

try {
    Load-DotEnv -Path $EnvFile
    Load-DotEnvIfNeeded -RepoRoot $RepoRoot

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

    # 1) OAuth refresh
    $tokenResp = Invoke-RestMethod -Method Post `
        -Uri "https://oauth2.googleapis.com/token" `
        -Body @{ client_id = $clientId; client_secret = $clientSecret; refresh_token = $refreshToken; grant_type = "refresh_token" } `
        -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
    $accessToken = $tokenResp.access_token
    if (-not $accessToken) { throw "OAuth token exchange returned no access_token" }

    # 2) Campaign metadata
    Write-Output "Pulling Google Ads campaigns..."
    $campaignsRaw = Invoke-GAQL -CustomerId $customerId -AccessToken $accessToken -DevToken $devToken -LoginCustomerId $loginCust -Query @"
SELECT
    campaign.id, campaign.name, campaign.status, campaign.advertising_channel_type,
    campaign_budget.amount_micros, campaign.start_date, campaign.end_date
FROM campaign
"@
    Write-Output "  -> $($campaignsRaw.Count) campaigns"

    # 3) Ad group metadata
    Write-Output "Pulling Google Ads ad groups..."
    $adGroupsRaw = Invoke-GAQL -CustomerId $customerId -AccessToken $accessToken -DevToken $devToken -LoginCustomerId $loginCust -Query @"
SELECT ad_group.id, ad_group.name, ad_group.status, ad_group.campaign, ad_group.cpc_bid_micros
FROM ad_group
"@
    Write-Output "  -> $($adGroupsRaw.Count) ad groups"

    # 4) Ad metadata (responsive search ads only for now)
    Write-Output "Pulling Google Ads ad creatives..."
    $adsRaw = Invoke-GAQL -CustomerId $customerId -AccessToken $accessToken -DevToken $devToken -LoginCustomerId $loginCust -Query @"
SELECT
    ad_group_ad.ad.id,
    ad_group_ad.ad.name,
    ad_group_ad.ad.responsive_search_ad.headlines,
    ad_group_ad.ad.responsive_search_ad.descriptions,
    ad_group_ad.ad.final_urls,
    ad_group_ad.status,
    ad_group_ad.ad_group
FROM ad_group_ad
"@
    Write-Output "  -> $($adsRaw.Count) ads"

    # 5) Per-day spend — GAQL's named DURING ranges only go up to LAST_30_DAYS;
    # use an explicit BETWEEN to support arbitrary -DaysBack windows.
    $startDate = (Get-Date).AddDays(-$DaysBack).ToString("yyyy-MM-dd")
    $endDate   = (Get-Date).ToString("yyyy-MM-dd")
    Write-Output "Pulling Google Ads daily spend ($startDate .. $endDate)..."
    $spendRaw = Invoke-GAQL -CustomerId $customerId -AccessToken $accessToken -DevToken $devToken -LoginCustomerId $loginCust -Query @"
SELECT
    segments.date, campaign.id, ad_group.id, ad_group_ad.ad.id,
    metrics.impressions, metrics.clicks, metrics.cost_micros,
    metrics.conversions, metrics.conversions_value
FROM ad_group_ad
WHERE segments.date BETWEEN '$startDate' AND '$endDate'
"@
    Write-Output "  -> $($spendRaw.Count) (ad, day) rows"

    # Snapshot for inspection
    $snapshot = [ordered]@{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "google-ads-warehouse"
        data      = [ordered]@{
            customer_id   = $customerId
            campaigns     = $campaignsRaw
            ad_groups     = $adGroupsRaw
            ads           = $adsRaw
            spend_rows    = $spendRaw.Count
        }
        error = $null
    }
    $snapshot | ConvertTo-Json -Depth 32 | Out-File -FilePath $OutFile -Encoding utf8 -Force

    if ($SkipSupabase) { Write-Output "SkipSupabase: snapshot only. Done."; exit 0 }

    Initialize-SupabaseClient
    $capturedAt = (Get-Date).ToUniversalTime().ToString("o")

    # Helpers to extract IDs from resource paths like "customers/.../adGroups/123"
    function Get-LastSegment([string] $s) { if (-not $s) { return $null }; return ($s -split '/')[-1] }

    # === dim_campaign ===
    $campaignRecords = New-Object System.Collections.Generic.List[hashtable]
    foreach ($c in $campaignsRaw) {
        $campaign = Get-PropOrNull $c "campaign"
        $budget   = Get-PropOrNull $c "campaignBudget"
        if ($null -eq $campaign) { continue }
        $micros = Get-PropOrNull $budget "amountMicros"
        $budgetCents = $null
        if ($micros) { try { $budgetCents = [int64] ([decimal] $micros / 10000) } catch { } }
        $campaignRecords.Add(@{
            platform              = "google_ads"
            platform_campaign_id  = "$($campaign.id)"
            campaign_name         = $campaign.name
            objective             = (Get-PropOrNull $campaign "advertisingChannelType")
            status                = (Get-PropOrNull $campaign "status")
            daily_budget_cents    = $budgetCents
            start_date            = (Get-PropOrNull $campaign "startDate")
            end_date              = (Get-PropOrNull $campaign "endDate")
            updated_at            = $capturedAt
        })
    }
    if ($DryRun) {
        Write-Output "DryRun: would upsert $($campaignRecords.Count) dim_campaign rows"
    } else {
        $n = Invoke-SupabaseUpsert -Table "dim_campaign" -Records $campaignRecords.ToArray() -ConflictColumns "platform,platform_campaign_id"
        Write-Output "Upserted $n rows into dim_campaign"
    }

    # === Lookup dim_campaign for FK resolution ===
    $campRows = Invoke-SupabaseSelect -Table "dim_campaign" -Select "campaign_id,platform,platform_campaign_id" -Filter "platform=eq.google_ads"
    $campIdByPlatformId = @{}
    foreach ($r in $campRows) { $campIdByPlatformId[[string] $r.platform_campaign_id] = [int64] $r.campaign_id }

    # === dim_ad_group ===
    $adGroupRecords = New-Object System.Collections.Generic.List[hashtable]
    foreach ($g in $adGroupsRaw) {
        $ag = Get-PropOrNull $g "adGroup"
        if ($null -eq $ag) { continue }
        $campaignPath = Get-PropOrNull $ag "campaign"
        $platformCampaignId = Get-LastSegment $campaignPath
        if (-not $campIdByPlatformId.ContainsKey($platformCampaignId)) { continue }
        $cpcMicros = Get-PropOrNull $ag "cpcBidMicros"
        $cpcCents = $null
        if ($cpcMicros) { try { $cpcCents = [int64] ([decimal] $cpcMicros / 10000) } catch { } }
        $adGroupRecords.Add(@{
            campaign_id          = $campIdByPlatformId[$platformCampaignId]
            platform             = "google_ads"
            platform_ad_group_id = "$($ag.id)"
            ad_group_name        = $ag.name
            status               = (Get-PropOrNull $ag "status")
            max_cpc_cents        = $cpcCents
            updated_at           = $capturedAt
        })
    }
    if ($DryRun) {
        Write-Output "DryRun: would upsert $($adGroupRecords.Count) dim_ad_group rows"
    } else {
        $n = Invoke-SupabaseUpsert -Table "dim_ad_group" -Records $adGroupRecords.ToArray() -ConflictColumns "platform,platform_ad_group_id"
        Write-Output "Upserted $n rows into dim_ad_group"
    }

    # === Lookup dim_ad_group for FK resolution ===
    $agRows = Invoke-SupabaseSelect -Table "dim_ad_group" -Select "ad_group_id,platform,platform_ad_group_id" -Filter "platform=eq.google_ads"
    $agIdByPlatformId = @{}
    foreach ($r in $agRows) { $agIdByPlatformId[[string] $r.platform_ad_group_id] = [int64] $r.ad_group_id }

    # === dim_ad ===
    $adRecords = New-Object System.Collections.Generic.List[hashtable]
    foreach ($a in $adsRaw) {
        $ada = Get-PropOrNull $a "adGroupAd"
        if ($null -eq $ada) { continue }
        $ad = Get-PropOrNull $ada "ad"
        if ($null -eq $ad) { continue }
        $platformAdGroupId = Get-LastSegment (Get-PropOrNull $ada "adGroup")
        if (-not $agIdByPlatformId.ContainsKey($platformAdGroupId)) { continue }

        $rsa = Get-PropOrNull $ad "responsiveSearchAd"
        $headlines = @(); $descriptions = @()
        if ($rsa) {
            $hl = @(Get-PropOrNull $rsa "headlines")
            $headlines = $hl | ForEach-Object { Get-PropOrNull $_ "text" } | Where-Object { $_ }
            $ds = @(Get-PropOrNull $rsa "descriptions")
            $descriptions = $ds | ForEach-Object { Get-PropOrNull $_ "text" } | Where-Object { $_ }
        }
        $finalUrls = @(Get-PropOrNull $ad "finalUrls")
        $finalUrl  = if ($finalUrls.Count -gt 0) { $finalUrls[0] } else { $null }

        $adRecords.Add(@{
            ad_group_id      = $agIdByPlatformId[$platformAdGroupId]
            platform         = "google_ads"
            platform_ad_id   = "$($ad.id)"
            ad_name          = (Get-PropOrNull $ad "name")
            headline_1       = if ($headlines.Count -ge 1) { $headlines[0] } else { $null }
            headline_2       = if ($headlines.Count -ge 2) { $headlines[1] } else { $null }
            headline_3       = if ($headlines.Count -ge 3) { $headlines[2] } else { $null }
            description_1    = if ($descriptions.Count -ge 1) { $descriptions[0] } else { $null }
            description_2    = if ($descriptions.Count -ge 2) { $descriptions[1] } else { $null }
            final_url        = $finalUrl
            status           = (Get-PropOrNull $ada "status")
            updated_at       = $capturedAt
        })
    }
    if ($DryRun) {
        Write-Output "DryRun: would upsert $($adRecords.Count) dim_ad rows"
    } else {
        $n = Invoke-SupabaseUpsert -Table "dim_ad" -Records $adRecords.ToArray() -ConflictColumns "platform,platform_ad_id"
        Write-Output "Upserted $n rows into dim_ad"
    }

    # === Lookup dim_ad for FK resolution ===
    $adRows = Invoke-SupabaseSelect -Table "dim_ad" -Select "ad_id,platform,platform_ad_id" -Filter "platform=eq.google_ads"
    $adIdByPlatformId = @{}
    foreach ($r in $adRows) { $adIdByPlatformId[[string] $r.platform_ad_id] = [int64] $r.ad_id }

    # === fact_ad_spend_daily ===
    $spendRecords = New-Object System.Collections.Generic.List[hashtable]
    $spendSkipped = 0
    foreach ($s in $spendRaw) {
        $seg = Get-PropOrNull $s "segments"; if ($null -eq $seg) { $spendSkipped++; continue }
        $met = Get-PropOrNull $s "metrics";  if ($null -eq $met) { $spendSkipped++; continue }
        $cam = Get-PropOrNull $s "campaign"
        $ag  = Get-PropOrNull $s "adGroup"
        $ada = Get-PropOrNull $s "adGroupAd"
        $ad  = if ($ada) { Get-PropOrNull $ada "ad" } else { $null }

        $platformCampaignId = if ($cam) { "$($cam.id)" } else { $null }
        $platformAgId       = if ($ag)  { "$($ag.id)"  } else { $null }
        $platformAdId       = if ($ad)  { "$($ad.id)"  } else { $null }

        $campaignFk = if ($platformCampaignId -and $campIdByPlatformId.ContainsKey($platformCampaignId)) { $campIdByPlatformId[$platformCampaignId] } else { $null }
        $agFk       = if ($platformAgId       -and $agIdByPlatformId.ContainsKey($platformAgId))       { $agIdByPlatformId[$platformAgId] }       else { $null }
        $adFk       = if ($platformAdId       -and $adIdByPlatformId.ContainsKey($platformAdId))       { $adIdByPlatformId[$platformAdId] }       else { $null }

        if (-not $campaignFk -or -not $adFk) { $spendSkipped++; continue }

        $costMicros = Get-PropOrNull $met "costMicros"
        $costCents = 0
        if ($costMicros) { try { $costCents = [int64] ([decimal] $costMicros / 10000) } catch { } }

        $spendRecords.Add(@{
            spend_date              = $seg.date
            platform                = "google_ads"
            campaign_id             = $campaignFk
            ad_group_id             = $agFk
            ad_id                   = $adFk
            impressions             = [int64] (Get-PropOrNull $met "impressions")
            clicks                  = [int64] (Get-PropOrNull $met "clicks")
            cost_cents              = $costCents
            conversions             = [decimal] (Get-PropOrNull $met "conversions")
            conversion_value_cents  = [int64] ([math]::Round([double] (Get-PropOrNull $met "conversionsValue") * 100))
            updated_at              = $capturedAt
        })
    }
    if ($DryRun) {
        Write-Output "DryRun: would upsert $($spendRecords.Count) fact_ad_spend_daily rows (skipped $spendSkipped for missing FKs)"
    } else {
        $n = Invoke-SupabaseUpsert -Table "fact_ad_spend_daily" -Records $spendRecords.ToArray() -ConflictColumns "spend_date,platform,ad_id"
        Write-Output "Upserted $n rows into fact_ad_spend_daily (skipped $spendSkipped for missing FKs)"
    }

    Write-Output "google-ads warehouse pull OK"
    exit 0
}
catch {
    $msg = "google-ads warehouse pull FAILED: $($_.Exception.Message)"
    Write-ErrorLog -Message $msg
    $stub = [ordered]@{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "google-ads-warehouse"
        data      = $null
        error     = $_.Exception.Message
    } | ConvertTo-Json -Depth 5
    try { $stub | Out-File -FilePath $OutFile -Encoding utf8 -Force } catch {}
    Write-Error $msg
    exit 1
}
