<#
.SYNOPSIS
    Register the CWDB-Control-Tick scheduled task. Idempotent (re-running rotates it cleanly).

.DESCRIPTION
    Runs control-tick.ps1 every 30 minutes from 06:00 to 22:00 Central. This is the cheap,
    deterministic watchdog: budget roll-up, breakers, lease reaper, the gate, and the daily
    digest. It never calls an LLM, so it can run frequently at ~zero cost.

    Mirrors operations/data-warehouse/scripts/install-cron.ps1 (same principal / battery /
    StartWhenAvailable posture) but uses a repeating intraday trigger instead of once-daily.

.NOTES
    Verify:   Get-ScheduledTask -TaskPath \CWDB\ | Format-List TaskName, State
    Fire now: Start-ScheduledTask -TaskName CWDB-Control-Tick -TaskPath \CWDB\
    Remove:   Unregister-ScheduledTask -TaskName CWDB-Control-Tick -TaskPath \CWDB\ -Confirm:$false
#>

[CmdletBinding()]
param(
    [string] $TaskName  = 'CWDB-Control-Tick',
    [string] $TaskPath  = '\CWDB\',
    [string] $StartTime = '06:00',
    [int]    $IntervalMinutes = 30,
    [int]    $ActiveHours = 16        # 06:00 -> 22:00
)

$ErrorActionPreference = 'Stop'

$ScriptRoot   = $PSScriptRoot
$RepoRoot     = (Resolve-Path (Join-Path $ScriptRoot "..\..\..")).Path
$ControlTick  = Join-Path $ScriptRoot 'control-tick.ps1'
if (-not (Test-Path $ControlTick)) { throw "control-tick.ps1 not found at: $ControlTick" }

Write-Host "RepoRoot:    $RepoRoot"
Write-Host "ControlTick: $ControlTick"

$existing = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Existing task at $TaskPath$TaskName - unregistering before rotation."
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
}

# Use the stable Windows PowerShell path. Task Scheduler cannot reliably resolve bare 'pwsh.exe'
# (PS7 on this box is an MSIX/WindowsApps build: ACL-restricted and version-stamped path that
# breaks on every update). The control scripts are verified 5.1-compatible and reach Supabase
# over TLS fine, matching how the warehouse cron (install-cron.ps1) runs.
$exe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

$argString = '-NoProfile -ExecutionPolicy Bypass -File "' + $ControlTick + '"'
$action = New-ScheduledTaskAction -Execute $exe -Argument $argString -WorkingDirectory $RepoRoot

# Daily trigger + intraday repetition (the documented way to repeat every N minutes within a window).
$trigger = New-ScheduledTaskTrigger -Daily -At $StartTime
$repetition = (New-ScheduledTaskTrigger -Once -At $StartTime `
    -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) `
    -RepetitionDuration (New-TimeSpan -Hours $ActiveHours)).Repetition
$trigger.Repetition = $repetition

$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 10) `
    -MultipleInstances IgnoreNew `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries

$principal = New-ScheduledTaskPrincipal `
    -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) `
    -LogonType Interactive `
    -RunLevel Limited

$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal `
    -Description "CWDB autonomous control tick: budget roll-up, circuit breakers, lease reaper, watchdog gate, daily digest. Runs every $IntervalMinutes min, $StartTime for $ActiveHours h. Source: operations/control-plane/scripts/control-tick.ps1"

Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -InputObject $task | Out-Null

Write-Host ""
Write-Host "Registered $TaskPath$TaskName"
Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Format-List TaskName, TaskPath, State, Description
Write-Host ""
Write-Host "Trigger: every $IntervalMinutes min from $StartTime for $ActiveHours h (Central)."
Write-Host "Manual fire: Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath"
