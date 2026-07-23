<#
.SYNOPSIS
    Logon-triggered catch-up guardrail for the laptop-coupled warehouse cron.
    If the last SUCCESSFUL daily refresh (RUN_END overall_exit=0 in
    _vault/data/cron-runs.log) is older than the staleness threshold (24h),
    invoke run-daily.ps1. Otherwise no-op.

.DESCRIPTION
    Companion to run-daily.ps1. Registered as Task Scheduler task
    \CWDB\CWDB-Warehouse-Catchup (see install-catchup.ps1), fired at user
    logon and workstation unlock with a 3-minute delay.

    Idempotent by design:
      - Only fires a refresh when the warehouse is actually stale (>24h since
        last clean RUN_END), so repeated logons/unlocks in one day no-op.
      - Skips if the \CWDB\CWDB-Warehouse-Daily task is currently Running.
      - The scheduled task itself is registered MultipleInstances IgnoreNew.

    Logs its decision to the SAME _vault/data/cron-runs.log, one tab-separated
    line per invocation:
      [ISO8601]\tCATCHUP\tdecision=<noop|run|skip_daily_running>\tlast_success=<iso|none>\tage_h=<float|na>
    When decision=run, run-daily.ps1 then writes its normal RUN_START /
    per-source / RUN_END lines.

.NOTES
    Manual test: pwsh -File run-catchup.ps1   (no-ops if last success < 24h old)
    Force path:  pwsh -File run-catchup.ps1 -ThresholdHours 0
#>

[CmdletBinding()]
param(
    [string] $RepoRoot,
    [double] $ThresholdHours = 24
)

$ErrorActionPreference = "Continue"

if (-not $RepoRoot) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
    $RepoRoot  = (Resolve-Path (Join-Path $scriptDir "..\..\..")).Path
}

$DataDir  = Join-Path $RepoRoot "_vault\data"
$LogFile  = Join-Path $DataDir "cron-runs.log"
$RunDaily = Join-Path $RepoRoot "operations\data-warehouse\scripts\run-daily.ps1"

if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
}

function Write-RunLog {
    param([string] $Line)
    $stamp = (Get-Date).ToUniversalTime().ToString("o")
    Add-Content -Path $LogFile -Value "[$stamp]`t$Line" -Encoding utf8
}

# --- 1. Find the last successful RUN_END in the log -------------------------
$lastSuccess = $null
if (Test-Path $LogFile) {
    # Tail is plenty: RUN_END lines are ~1 per run, 500 lines covers weeks.
    $tail = Get-Content -Path $LogFile -Tail 500
    foreach ($line in $tail) {
        if ($line -match '^\[(?<ts>[^\]]+)\]\tRUN_END\t.*\boverall_exit=0\b') {
            $parsed = [datetime]::MinValue
            if ([datetime]::TryParse(
                    $Matches.ts,
                    [System.Globalization.CultureInfo]::InvariantCulture,
                    [System.Globalization.DateTimeStyles]::RoundtripKind,
                    [ref]$parsed)) {
                # Later lines win; log is append-only chronological.
                $lastSuccess = $parsed.ToUniversalTime()
            }
        }
    }
}

$nowUtc = (Get-Date).ToUniversalTime()
$ageH   = if ($lastSuccess) { [math]::Round(($nowUtc - $lastSuccess).TotalHours, 2) } else { $null }
$lastStr = if ($lastSuccess) { $lastSuccess.ToString("o") } else { "none" }
$ageStr  = if ($null -ne $ageH) { $ageH } else { "na" }

# --- 2. Fresh enough? No-op. ------------------------------------------------
if ($lastSuccess -and $ageH -lt $ThresholdHours) {
    Write-RunLog ("CATCHUP`tdecision=noop`tlast_success={0}`tage_h={1}" -f $lastStr, $ageStr)
    Write-Host ("Catch-up no-op: last successful run {0} is {1}h old (< {2}h threshold)." -f $lastStr, $ageStr, $ThresholdHours)
    exit 0
}

# --- 3. Don't stack on top of a live daily run. -----------------------------
try {
    $daily = Get-ScheduledTask -TaskName 'CWDB-Warehouse-Daily' -TaskPath '\CWDB\' -ErrorAction Stop
    if ($daily.State -eq 'Running') {
        Write-RunLog ("CATCHUP`tdecision=skip_daily_running`tlast_success={0}`tage_h={1}" -f $lastStr, $ageStr)
        Write-Host "Catch-up skipped: CWDB-Warehouse-Daily is currently running."
        exit 0
    }
} catch {
    # Task not found or query failed: proceed, staleness check already passed.
}

# --- 4. Stale: run the daily refresh. ---------------------------------------
Write-RunLog ("CATCHUP`tdecision=run`tlast_success={0}`tage_h={1}" -f $lastStr, $ageStr)
Write-Host ("Warehouse stale (last success: {0}, age: {1}h). Invoking run-daily.ps1." -f $lastStr, $ageStr)

if (-not (Test-Path $RunDaily)) {
    Write-RunLog "CATCHUP`terror=run_daily_not_found"
    Write-Host "ERROR: run-daily.ps1 not found at $RunDaily"
    exit 127
}

$global:LASTEXITCODE = 0
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $RunDaily -RepoRoot $RepoRoot
exit $LASTEXITCODE
