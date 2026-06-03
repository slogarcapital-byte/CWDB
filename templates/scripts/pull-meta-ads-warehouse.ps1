<#
.SYNOPSIS
    Pull Meta (Facebook/Instagram) Ads campaign hierarchy + daily ad spend into the warehouse.

.DESCRIPTION
    Distinct from pull-meta-ads-mtd.ps1 (MTD aggregate for daily brief). This script
    does granular warehouse loading via the Marketing API Insights endpoint:

      dim_campaign           <- Meta campaigns
      dim_ad_group           <- Meta ad sets (their term for ad groups)
      dim_ad                 <- Meta ads
      fact_ad_spend_daily    <- one row per (ad, day) from Insights API

    Idempotent.

.NOTES
    Required env vars:
      META_ACCESS_TOKEN   - long-lived System User token (scope: ads_read)
      META_AD_ACCOUNT_ID  - ad account ID, digits only (no act_ prefix)
      META_API_VERSION    - default v21.0
      SUPABASE_URL
      SUPABASE_SERVICE_ROLE_KEY

    Default date range: last 90 days. Override with -DaysBack <N>.
#>

[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [int]    $DaysBack = 90,
    [switch] $SkipSupabase,
    [switch] $DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\load-supabase.ps1"

$DataDir  = Join-Path $RepoRoot "_vault\data"
$OutFile  = Join-Path $DataDir "meta-ads-warehouse-latest.json"
$ErrorLog = Join-Path $DataDir "meta-ads-warehouse-error.log"
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

function Get-PropOrNull {
    param($InputObject, [Parameter(Mandatory)] [string] $Name)
    if ($null -eq $InputObject) { return $null }
    if (-not ($InputObject.PSObject.Properties.Name -contains $Name)) { return $null }
    return $InputObject.$Name
}

function Get-MetaPaged {
    <#
    .SYNOPSIS
        GET a Meta Graph API endpoint with cursor-based pagination, return all data rows.
    #>
    param(
        [Parameter(Mandatory)] [string] $Url,
        [Parameter(Mandatory)] [string] $AccessToken
    )
    $all = New-Object System.Collections.Generic.List[object]
    $next = $Url
    do {
        # Append access_token if not already in URL
        $sep = if ($next.Contains('?')) { '&' } else { '?' }
        $reqUrl = if ($next -match 'access_token=') { $next } else { "$next$($sep)access_token=$AccessToken" }
        $resp = Invoke-RestMethod -Method Get -Uri $reqUrl -ErrorAction Stop
        $rows = @(Get-PropOrNull $resp "data")
        foreach ($r in $rows) { $all.Add($r) }
        $paging = Get-PropOrNull $resp "paging"
        $next = if ($paging) { Get-PropOrNull $paging "next" } else { $null }
    } while ($next)
    return ,$all.ToArray()
}

try {
    Load-DotEnv -Path $EnvFile
    Load-DotEnvIfNeeded -RepoRoot $RepoRoot

    $token   = $env:META_ACCESS_TOKEN
    $acctId  = $env:META_AD_ACCOUNT_ID
    $version = $env:META_API_VERSION
    if (-not $version) { $version = "v21.0" }

    if (-not $token)  { throw "Missing META_ACCESS_TOKEN. See operations/automation/api-credentials/README.md" }
    if (-not $acctId) { throw "Missing META_AD_ACCOUNT_ID. Digits only, no act_ prefix." }

    $actId = "act_$acctId"
    $base  = "https://graph.facebook.com/$version"

    # Date range for insights
    $since = (Get-Date).AddDays(-$DaysBack).ToString("yyyy-MM-dd")
    $until = (Get-Date).ToString("yyyy-MM-dd")
    $timeRange = "%7B%22since%22%3A%22$since%22%2C%22until%22%3A%22$until%22%7D"

    Write-Output "Pulling Meta campaigns..."
    $campaignsRaw = Get-MetaPaged -AccessToken $token -Url "$base/$actId/campaigns?fields=id,name,status,objective,daily_budget,start_time,stop_time&limit=200"
    Write-Output "  -> $($campaignsRaw.Count) campaigns"

    Write-Output "Pulling Meta ad sets..."
    $adSetsRaw = Get-MetaPaged -AccessToken $token -Url "$base/$actId/adsets?fields=id,name,status,campaign_id,daily_budget&limit=200"
    Write-Output "  -> $($adSetsRaw.Count) ad sets"

    Write-Output "Pulling Meta ads..."
    $adsRaw = Get-MetaPaged -AccessToken $token -Url "$base/$actId/ads?fields=id,name,status,adset_id,creative{title,body}&limit=200"
    Write-Output "  -> $($adsRaw.Count) ads"

    Write-Output "Pulling Meta daily insights (last $DaysBack days)..."
    $insightsRaw = Get-MetaPaged -AccessToken $token -Url "$base/$actId/insights?level=ad&fields=date_start,date_stop,campaign_id,adset_id,ad_id,impressions,clicks,spend,actions,action_values&time_range=$timeRange&time_increment=1&limit=200"
    Write-Output "  -> $($insightsRaw.Count) (ad, day) rows"

    # Snapshot for inspection
    @{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "meta-ads-warehouse"
        data      = @{
            ad_account_id = $acctId
            campaigns     = $campaignsRaw
            ad_sets       = $adSetsRaw
            ads           = $adsRaw
            insights_rows = $insightsRaw.Count
        }
        error = $null
    } | ConvertTo-Json -Depth 32 | Out-File -FilePath $OutFile -Encoding utf8 -Force

    if ($SkipSupabase) { Write-Output "SkipSupabase: snapshot only. Done."; exit 0 }

    Initialize-SupabaseClient
    $capturedAt = (Get-Date).ToUniversalTime().ToString("o")

    # === dim_campaign ===
    $campaignRecords = New-Object System.Collections.Generic.List[hashtable]
    foreach ($c in $campaignsRaw) {
        $dailyBudget = Get-PropOrNull $c "daily_budget"
        $budgetCents = $null
        if ($dailyBudget) { try { $budgetCents = [int64] $dailyBudget } catch { } }   # Meta returns cents
        $campaignRecords.Add(@{
            platform              = "meta"
            platform_campaign_id  = "$($c.id)"
            campaign_name         = $c.name
            objective             = (Get-PropOrNull $c "objective")
            status                = (Get-PropOrNull $c "status")
            daily_budget_cents    = $budgetCents
            start_date            = if (Get-PropOrNull $c "start_time") { ([datetime] $c.start_time).ToString("yyyy-MM-dd") } else { $null }
            end_date              = if (Get-PropOrNull $c "stop_time")  { ([datetime] $c.stop_time).ToString("yyyy-MM-dd")  } else { $null }
            updated_at            = $capturedAt
        })
    }
    if ($DryRun) { Write-Output "DryRun: would upsert $($campaignRecords.Count) dim_campaign rows" }
    elseif ($campaignRecords.Count -gt 0) {
        $n = Invoke-SupabaseUpsert -Table "dim_campaign" -Records $campaignRecords.ToArray() -ConflictColumns "platform,platform_campaign_id"
        Write-Output "Upserted $n rows into dim_campaign"
    }

    # FK lookups
    $campRows = Invoke-SupabaseSelect -Table "dim_campaign" -Select "campaign_id,platform_campaign_id" -Filter "platform=eq.meta"
    $campIdByPlatformId = @{}; foreach ($r in $campRows) { $campIdByPlatformId[[string] $r.platform_campaign_id] = [int64] $r.campaign_id }

    # === dim_ad_group (Meta ad sets) ===
    $adGroupRecords = New-Object System.Collections.Generic.List[hashtable]
    foreach ($a in $adSetsRaw) {
        $pCampId = Get-PropOrNull $a "campaign_id"
        if (-not $campIdByPlatformId.ContainsKey([string] $pCampId)) { continue }
        $cpcCents = $null
        $dailyBudget = Get-PropOrNull $a "daily_budget"
        if ($dailyBudget) { try { $cpcCents = [int64] $dailyBudget } catch { } }
        $adGroupRecords.Add(@{
            campaign_id          = $campIdByPlatformId[[string] $pCampId]
            platform             = "meta"
            platform_ad_group_id = "$($a.id)"
            ad_group_name        = $a.name
            status               = (Get-PropOrNull $a "status")
            max_cpc_cents        = $cpcCents
            updated_at           = $capturedAt
        })
    }
    if ($DryRun) { Write-Output "DryRun: would upsert $($adGroupRecords.Count) dim_ad_group rows" }
    elseif ($adGroupRecords.Count -gt 0) {
        $n = Invoke-SupabaseUpsert -Table "dim_ad_group" -Records $adGroupRecords.ToArray() -ConflictColumns "platform,platform_ad_group_id"
        Write-Output "Upserted $n rows into dim_ad_group"
    }

    $agRows = Invoke-SupabaseSelect -Table "dim_ad_group" -Select "ad_group_id,platform_ad_group_id" -Filter "platform=eq.meta"
    $agIdByPlatformId = @{}; foreach ($r in $agRows) { $agIdByPlatformId[[string] $r.platform_ad_group_id] = [int64] $r.ad_group_id }

    # === dim_ad ===
    $adRecords = New-Object System.Collections.Generic.List[hashtable]
    foreach ($a in $adsRaw) {
        $pAdSetId = Get-PropOrNull $a "adset_id"
        if (-not $agIdByPlatformId.ContainsKey([string] $pAdSetId)) { continue }
        $creative = Get-PropOrNull $a "creative"
        $title = if ($creative) { Get-PropOrNull $creative "title" } else { $null }
        $body  = if ($creative) { Get-PropOrNull $creative "body" }  else { $null }
        $adRecords.Add(@{
            ad_group_id      = $agIdByPlatformId[[string] $pAdSetId]
            platform         = "meta"
            platform_ad_id   = "$($a.id)"
            ad_name          = $a.name
            headline_1       = $title
            description_1    = $body
            status           = (Get-PropOrNull $a "status")
            updated_at       = $capturedAt
        })
    }
    if ($DryRun) { Write-Output "DryRun: would upsert $($adRecords.Count) dim_ad rows" }
    elseif ($adRecords.Count -gt 0) {
        $n = Invoke-SupabaseUpsert -Table "dim_ad" -Records $adRecords.ToArray() -ConflictColumns "platform,platform_ad_id"
        Write-Output "Upserted $n rows into dim_ad"
    }

    $adRows = Invoke-SupabaseSelect -Table "dim_ad" -Select "ad_id,platform_ad_id" -Filter "platform=eq.meta"
    $adIdByPlatformId = @{}; foreach ($r in $adRows) { $adIdByPlatformId[[string] $r.platform_ad_id] = [int64] $r.ad_id }

    # === fact_ad_spend_daily ===
    $spendRecords = New-Object System.Collections.Generic.List[hashtable]
    $spendSkipped = 0
    foreach ($i in $insightsRaw) {
        $pCampId = Get-PropOrNull $i "campaign_id"
        $pAgId   = Get-PropOrNull $i "adset_id"
        $pAdId   = Get-PropOrNull $i "ad_id"
        $campFk  = if ($campIdByPlatformId.ContainsKey([string] $pCampId)) { $campIdByPlatformId[[string] $pCampId] } else { $null }
        $agFk    = if ($agIdByPlatformId.ContainsKey([string] $pAgId))     { $agIdByPlatformId[[string] $pAgId] }     else { $null }
        $adFk    = if ($adIdByPlatformId.ContainsKey([string] $pAdId))     { $adIdByPlatformId[[string] $pAdId] }     else { $null }
        if (-not $campFk -or -not $adFk) { $spendSkipped++; continue }

        $spendDollars = Get-PropOrNull $i "spend"
        $costCents = 0
        if ($spendDollars) { try { $costCents = [int64] ([math]::Round([decimal] $spendDollars * 100)) } catch { } }

        # Conversions: Meta returns an actions array; sum any "lead" or "purchase" actions
        $convs = 0.0; $convValueCents = 0
        $actions = @(Get-PropOrNull $i "actions")
        foreach ($act in $actions) {
            $type = Get-PropOrNull $act "action_type"
            if ($type -in @("lead","offsite_conversion.fb_pixel_lead","purchase")) {
                $val = Get-PropOrNull $act "value"
                if ($val) { try { $convs += [double] $val } catch { } }
            }
        }
        $actionVals = @(Get-PropOrNull $i "action_values")
        foreach ($av in $actionVals) {
            $type = Get-PropOrNull $av "action_type"
            if ($type -in @("lead","offsite_conversion.fb_pixel_lead","purchase")) {
                $val = Get-PropOrNull $av "value"
                if ($val) { try { $convValueCents += [int64] ([math]::Round([decimal] $val * 100)) } catch { } }
            }
        }

        $spendRecords.Add(@{
            spend_date              = $i.date_start
            platform                = "meta"
            campaign_id             = $campFk
            ad_group_id             = $agFk
            ad_id                   = $adFk
            impressions             = [int64] (Get-PropOrNull $i "impressions")
            clicks                  = [int64] (Get-PropOrNull $i "clicks")
            cost_cents              = $costCents
            conversions             = [decimal] $convs
            conversion_value_cents  = $convValueCents
            updated_at              = $capturedAt
        })
    }
    if ($DryRun) {
        Write-Output "DryRun: would upsert $($spendRecords.Count) fact_ad_spend_daily rows (skipped $spendSkipped)"
    } else {
        $n = Invoke-SupabaseUpsert -Table "fact_ad_spend_daily" -Records $spendRecords.ToArray() -ConflictColumns "spend_date,platform,ad_id"
        Write-Output "Upserted $n rows into fact_ad_spend_daily (skipped $spendSkipped for missing FKs)"
    }

    Write-Output "meta-ads warehouse pull OK"
    exit 0
}
catch {
    $msg = "meta-ads warehouse pull FAILED: $($_.Exception.Message)"
    Write-ErrorLog -Message $msg
    @{ pulled_at = (Get-Date).ToUniversalTime().ToString("o"); source = "meta-ads-warehouse"; data = $null; error = $_.Exception.Message } |
        ConvertTo-Json -Depth 5 | Out-File -FilePath $OutFile -Encoding utf8 -Force
    Write-Error $msg
    exit 1
}
