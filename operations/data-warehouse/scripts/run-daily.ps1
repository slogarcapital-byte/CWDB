<#
.SYNOPSIS
    Daily warehouse refresh orchestrator. Calls each pull-* script sequentially,
    captures per-source exit code + elapsed time, appends a structured log line
    per source to _vault/data/cron-runs.log.

.DESCRIPTION
    Designed as the single entry point for the CWDB-Warehouse-Daily scheduled
    task. Continues through individual source failures so one bad pull never
    starves the rest. Final exit code is 0 only if every source succeeded.

    Each pull script handles its own .env.local loading (via Load-DotEnv) and
    Supabase UPSERTs. The GA4 pull self-relaunches under PowerShell 7 when
    invoked from PS 5.1, so this orchestrator runs cleanly under either.

.NOTES
    Log format (one line per source, tab-separated):
      [ISO8601]\tRUN_START\trun_id=<guid>\tsources=<count>
      [ISO8601]\t<source>\texit=<code>\telapsed_s=<float>\terror=<short>
      [ISO8601]\tRUN_END\trun_id=<guid>\toverall_exit=<code>\telapsed_s=<float>

    Failing sources do NOT abort the orchestrator. Their exit codes are
    captured and rolled up into the final overall_exit.
#>

[CmdletBinding()]
param(
    [string] $RepoRoot
)

$ErrorActionPreference = "Continue"

if (-not $RepoRoot) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
    $RepoRoot  = (Resolve-Path (Join-Path $scriptDir "..\..\..")).Path
}

$DataDir = Join-Path $RepoRoot "_vault\data"
$LogFile = Join-Path $DataDir "cron-runs.log"

if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
}

function Write-RunLog {
    param([string] $Line)
    $stamp = (Get-Date).ToUniversalTime().ToString("o")
    Add-Content -Path $LogFile -Value "[$stamp]`t$Line" -Encoding utf8
}

$sources = @(
    @{ Name = 'hubspot';    Path = Join-Path $RepoRoot 'templates\scripts\pull-hubspot-snapshot.ps1' }
    @{ Name = 'google_ads'; Path = Join-Path $RepoRoot 'templates\scripts\pull-google-ads-warehouse.ps1' }
    @{ Name = 'meta_ads';   Path = Join-Path $RepoRoot 'templates\scripts\pull-meta-ads-warehouse.ps1' }
    @{ Name = 'ga4';        Path = Join-Path $RepoRoot 'templates\scripts\pull-ga4-warehouse.ps1' }
    @{ Name = 'jobtread';   Path = Join-Path $RepoRoot 'templates\scripts\pull-jobtread-snapshot.ps1' }
    @{ Name = 'google_conv'; Path = Join-Path $RepoRoot 'templates\scripts\push-google-offline-conversions.ps1' }
)

$runId    = [guid]::NewGuid().ToString("N").Substring(0, 12)
$runStart = Get-Date
Write-RunLog ("RUN_START`trun_id={0}`tsources={1}" -f $runId, $sources.Count)

$results = @()
foreach ($src in $sources) {
    $name = $src.Name
    $path = $src.Path
    $start = Get-Date
    $exit = 0
    $errMsg = ''

    if (-not (Test-Path $path)) {
        $exit = 127
        $errMsg = "script_not_found"
    } else {
        try {
            $global:LASTEXITCODE = 0
            & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path -RepoRoot $RepoRoot 2>&1 | ForEach-Object { Write-Output $_ }
            if ($LASTEXITCODE) { $exit = $LASTEXITCODE }
        } catch {
            $exit = 1
            $errMsg = ($_.Exception.Message -replace "[`r`n`t]", " ")
            if ($errMsg.Length -gt 200) { $errMsg = $errMsg.Substring(0, 200) }
        }
    }

    $elapsed = [math]::Round(((Get-Date) - $start).TotalSeconds, 2)
    $logLine = "{0}`texit={1}`telapsed_s={2}" -f $name, $exit, $elapsed
    if ($errMsg) { $logLine += "`terror=$errMsg" }
    Write-RunLog $logLine

    $results += [pscustomobject]@{
        Name      = $name
        Exit      = $exit
        ElapsedSec = $elapsed
        Error     = $errMsg
    }
}

$failed = @($results | Where-Object { $_.Exit -ne 0 })
$overallExit = if ($failed.Count -gt 0) { 1 } else { 0 }
$overallElapsed = [math]::Round(((Get-Date) - $runStart).TotalSeconds, 2)
Write-RunLog ("RUN_END`trun_id={0}`toverall_exit={1}`telapsed_s={2}" -f $runId, $overallExit, $overallElapsed)

Write-Host ""
Write-Host ("=== run-daily.ps1 summary (run_id={0}) ===" -f $runId)
$results | Format-Table Name, Exit, ElapsedSec, Error -AutoSize | Out-String | Write-Host
Write-Host ("Overall exit: {0}  Elapsed: {1}s" -f $overallExit, $overallElapsed)

exit $overallExit
