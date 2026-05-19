<#
.SYNOPSIS
    Pull Meta (Facebook/Instagram) Marketing API MTD insights for CWDB and write JSON snapshot.

.DESCRIPTION
    Authenticates with a long-lived System User access token, queries the /insights
    endpoint of the CWDB Meta ad account at MTD level, and writes a normalized JSON
    file at _vault/data/meta-ads-latest.json. Idempotent.

    Pre-launch case: Meta is at $0 spend. Script returns successfully with zeros.

    On any error, writes to _vault/data/meta-ads-error.log and exits non-zero.

.NOTES
    Required env vars (read from .env.local at repo root or process env):
      META_ACCESS_TOKEN     - System User access token (read-only ads_read scope)
      META_AD_ACCOUNT_ID    - Ad account ID, digits only (the act_<id> prefix is added)
      META_API_VERSION      - Optional, defaults to v21.0

    Output schema:
      { "pulled_at": ISO8601, "source": "meta-ads", "data": {...}, "error": null }
#>

[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$DataDir  = Join-Path $RepoRoot "_vault\data"
$OutFile  = Join-Path $DataDir "meta-ads-latest.json"
$ErrorLog = Join-Path $DataDir "meta-ads-error.log"
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

try {
    Load-DotEnv -Path $EnvFile

    $token     = $env:META_ACCESS_TOKEN
    $acctId    = $env:META_AD_ACCOUNT_ID
    $apiVer    = $env:META_API_VERSION
    if (-not $apiVer) { $apiVer = "v21.0" }

    $missing = @()
    if (-not $token)  { $missing += "META_ACCESS_TOKEN" }
    if (-not $acctId) { $missing += "META_AD_ACCOUNT_ID" }
    if ($missing.Count -gt 0) {
        throw "Missing required env vars: $($missing -join ', '). See operations/automation/api-credentials/README.md"
    }

    # MTD date range
    $today = Get-Date
    $monthStart = (Get-Date -Year $today.Year -Month $today.Month -Day 1).ToString("yyyy-MM-dd")
    $todayStr   = $today.ToString("yyyy-MM-dd")
    $timeRange = @{ since = $monthStart; until = $todayStr } | ConvertTo-Json -Compress

    $fields = "spend,impressions,clicks,ctr,actions,cost_per_action_type"
    $url = "https://graph.facebook.com/$apiVer/act_$acctId/insights" +
           "?level=account" +
           "&fields=$fields" +
           "&time_range=$([uri]::EscapeDataString($timeRange))" +
           "&access_token=$([uri]::EscapeDataString($token))"

    $resp = Invoke-RestMethod -Method Get -Uri $url -ErrorAction Stop

    # Pre-launch: data array may be empty. Return zeros.
    $spend = 0.0; $impressions = 0; $clicks = 0; $ctr = 0.0
    $leads = 0; $costPerLead = 0.0
    if ($resp.data -and $resp.data.Count -gt 0) {
        $row = $resp.data[0]
        $spend       = [double] ($row.spend       | ForEach-Object { $_ })
        $impressions = [int64]  ($row.impressions | ForEach-Object { $_ })
        $clicks      = [int64]  ($row.clicks      | ForEach-Object { $_ })
        $ctr         = [double] ($row.ctr         | ForEach-Object { $_ })

        if ($row.PSObject.Properties.Name -contains "actions" -and $row.actions) {
            $leadAction = $row.actions | Where-Object { $_.action_type -eq "lead" } | Select-Object -First 1
            if ($leadAction) { $leads = [int]$leadAction.value }
        }
        if ($row.PSObject.Properties.Name -contains "cost_per_action_type" -and $row.cost_per_action_type) {
            $cpl = $row.cost_per_action_type | Where-Object { $_.action_type -eq "lead" } | Select-Object -First 1
            if ($cpl) { $costPerLead = [double]$cpl.value }
        }
    }

    $out = [ordered]@{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "meta-ads"
        data      = [ordered]@{
            ad_account_id  = $acctId
            date_range     = "MTD ($monthStart -> $todayStr)"
            spend          = [math]::Round($spend, 2)
            impressions    = $impressions
            clicks         = $clicks
            ctr_percent    = [math]::Round($ctr, 2)
            leads          = $leads
            cost_per_lead  = [math]::Round($costPerLead, 2)
        }
        error     = $null
    }

    $out | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutFile -Encoding utf8 -Force
    Write-Output "meta-ads pull OK: spend=`$$spend impressions=$impressions clicks=$clicks leads=$leads"
    exit 0
}
catch {
    $msg = "meta-ads pull FAILED: $($_.Exception.Message)"
    Write-ErrorLog -Message $msg
    $stub = [ordered]@{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "meta-ads"
        data      = $null
        error     = $_.Exception.Message
    } | ConvertTo-Json -Depth 5
    try { $stub | Out-File -FilePath $OutFile -Encoding utf8 -Force } catch {}
    Write-Error $msg
    exit 1
}
