<#
.SYNOPSIS
    Register the CWDB-Warehouse-Catchup scheduled task. Idempotent. Re-running
    rotates the task config cleanly.

.DESCRIPTION
    Guardrail companion to install-cron.ps1 (audit-2026-07-05#25). The daily
    06:55 task only fires if the laptop is on; this task fires run-catchup.ps1
    at user LOGON with a 3-minute delay. run-catchup.ps1 itself is the guard:
    it only invokes run-daily.ps1 when the last successful RUN_END in
    _vault/data/cron-runs.log is older than 24 hours, so repeated logons are
    harmless no-ops.

    -IncludeUnlockTrigger additionally fires on workstation UNLOCK (+3 min).
    Registering a session-state-change trigger requires an ELEVATED prompt
    (verified 2026-07-22: non-elevated registration returns Access denied,
    while the logon trigger registers fine). Default: logon only.

.NOTES
    Run once. Verify with:
      Get-ScheduledTask -TaskName CWDB-Warehouse-Catchup -TaskPath \CWDB\ | Format-List *
    Manually fire with:
      Start-ScheduledTask -TaskName CWDB-Warehouse-Catchup -TaskPath \CWDB\
    To uninstall:
      Unregister-ScheduledTask -TaskName CWDB-Warehouse-Catchup -TaskPath \CWDB\ -Confirm:$false
#>

[CmdletBinding()]
param(
    [string] $TaskName = 'CWDB-Warehouse-Catchup',
    [string] $TaskPath = '\CWDB\',
    [string] $Delay    = 'PT3M',
    [switch] $IncludeUnlockTrigger   # requires an elevated PowerShell
)

$ErrorActionPreference = 'Stop'

$ScriptRoot = $PSScriptRoot
$RepoRoot   = (Resolve-Path (Join-Path $ScriptRoot "..\..\..")).Path
$RunCatchup = Join-Path $ScriptRoot 'run-catchup.ps1'

if (-not (Test-Path $RunCatchup)) {
    throw "run-catchup.ps1 not found at expected path: $RunCatchup"
}

Write-Host "RepoRoot:   $RepoRoot"
Write-Host "RunCatchup: $RunCatchup"

# If the task already exists, remove it so we start clean.
$existing = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Existing task found at $TaskPath$TaskName. Unregistering before rotation."
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
}

$argString = '-NoProfile -ExecutionPolicy Bypass -File "' + $RunCatchup + '"'
$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument $argString `
    -WorkingDirectory $RepoRoot

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# Trigger 1: at logon of the current user, delayed.
$logonTrigger = New-ScheduledTaskTrigger -AtLogOn -User $currentUser
$logonTrigger.Delay = $Delay

$triggers = @($logonTrigger)

# Trigger 2 (opt-in, elevated only): workstation unlock (SessionStateChange 8).
# New-ScheduledTaskTrigger has no unlock switch; build the CIM instance directly.
if ($IncludeUnlockTrigger) {
    $stateChangeClass = Get-CimClass `
        -Namespace Root/Microsoft/Windows/TaskScheduler `
        -ClassName MSFT_TaskSessionStateChangeTrigger
    $unlockTrigger = New-CimInstance -CimClass $stateChangeClass -ClientOnly -Property @{
        StateChange = 8          # TASK_SESSION_UNLOCK
        Delay       = $Delay
        Enabled     = $true
    }
    $triggers += $unlockTrigger
}

$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 35) `
    -MultipleInstances IgnoreNew `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries

$principal = New-ScheduledTaskPrincipal `
    -UserId $currentUser `
    -LogonType Interactive `
    -RunLevel Limited

$task = New-ScheduledTask -Action $action -Trigger $triggers -Settings $settings -Principal $principal `
    -Description "Catch-up guardrail for the laptop-coupled warehouse cron: at logon (+3 min) runs run-catchup.ps1, which invokes run-daily.ps1 only if the last successful refresh is older than 24h. Source: operations/data-warehouse/scripts/run-catchup.ps1"

Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -InputObject $task | Out-Null

Write-Host ""
Write-Host "Registered $TaskPath$TaskName"
Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Format-List TaskName, TaskPath, State, Description
Write-Host ""
$trigDesc = "at logon of $currentUser (+$Delay)"
if ($IncludeUnlockTrigger) { $trigDesc += " and on workstation unlock (+$Delay)" }
Write-Host "Triggers: $trigDesc."
Write-Host "Manual fire: Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath"
