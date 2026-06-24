<#
.SYNOPSIS
    Register the CWDB-Dashboard scheduled task. Idempotent (re-running rotates it cleanly).

.DESCRIPTION
    Runs dashboard-babysitter.ps1 as the task action on every tick (logon + every 5 minutes,
    all day). The babysitter is SHORT-LIVED: it probes http://127.0.0.1:7717/ and relaunches
    dashboard-server.ps1 (detached, output -> _logs/) only if the port is not answering, then
    exits. Liveness is judged by the actual PORT, not Task Scheduler's bookkeeping, and the task
    returns to Ready every tick. After installing, the Mission Control deck is simply always at
    http://127.0.0.1:7717 - no terminal window, no Claude session required.

    WHY (incident 2026-06-24): the task used to run dashboard-server.ps1 directly and stay
    "running" one instance forever. When the server died, Task Scheduler wedged in a ghost
    "Running" state, and MultipleInstances=IgnoreNew then treated that ghost as "already up" and
    suppressed every relaunch - the safety net jammed by the failure it was built to catch. A
    short-lived, port-aware babysitter cannot wedge. (Task Scheduler's native RestartCount also
    proved unreliable for killed processes - verified 2026-06-10.)

    Mirrors install-control-tick.ps1 (same 5.1 principal / battery / StartWhenAvailable posture,
    and the same short-lived-action shape that keeps that task from ever wedging). Both
    dashboard-babysitter.ps1 and dashboard-server.ps1 are verified Windows PowerShell
    5.1-compatible.

.NOTES
    Verify:   Get-ScheduledTask -TaskPath \CWDB\ | Format-List TaskName, State
    Start:    Start-ScheduledTask -TaskName CWDB-Dashboard -TaskPath \CWDB\
    Stop:     Stop-ScheduledTask  -TaskName CWDB-Dashboard -TaskPath \CWDB\
    Remove:   Unregister-ScheduledTask -TaskName CWDB-Dashboard -TaskPath \CWDB\ -Confirm:$false
#>

[CmdletBinding()]
param(
    [string] $TaskName = 'CWDB-Dashboard',
    [string] $TaskPath = '\CWDB\',
    [int]    $Port     = 7717
)

$ErrorActionPreference = 'Stop'

$ScriptRoot  = $PSScriptRoot
$RepoRoot    = (Resolve-Path (Join-Path $ScriptRoot "..\..\..")).Path
$Babysitter  = Join-Path $ScriptRoot 'dashboard-babysitter.ps1'
$Server      = Join-Path $ScriptRoot 'dashboard-server.ps1'
if (-not (Test-Path $Babysitter)) { throw "dashboard-babysitter.ps1 not found at: $Babysitter" }
if (-not (Test-Path $Server))     { throw "dashboard-server.ps1 not found at: $Server" }

Write-Host "RepoRoot:    $RepoRoot"
Write-Host "Babysitter:  $Babysitter"
Write-Host "Server:      $Server"

$existing = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Existing task at $TaskPath$TaskName - stopping + unregistering before rotation."
    Stop-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
}

# Stable Windows PowerShell 5.1 path - same rationale as install-control-tick.ps1
# (pwsh on this box is an MSIX build with an ACL-restricted, version-stamped path).
$exe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

$argString = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $Babysitter + '" -Port ' + $Port
$action = New-ScheduledTaskAction -Execute $exe -Argument $argString -WorkingDirectory $RepoRoot

# Trigger 1: instant start at logon. Trigger 2: babysitter - daily at 00:00 repeating
# every 5 min for 24h. Each tick runs the short-lived babysitter, which probes the port
# and relaunches the server only if it is down.
$logonTrigger = New-ScheduledTaskTrigger -AtLogOn -User ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
$sitterTrigger = New-ScheduledTaskTrigger -Daily -At '00:00'
$sitterTrigger.Repetition = (New-ScheduledTaskTrigger -Once -At '00:00' `
    -RepetitionInterval (New-TimeSpan -Minutes 5) `
    -RepetitionDuration (New-TimeSpan -Hours 24)).Repetition

$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -MultipleInstances IgnoreNew `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries

$principal = New-ScheduledTaskPrincipal `
    -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) `
    -LogonType Interactive `
    -RunLevel Limited

$task = New-ScheduledTask -Action $action -Trigger @($logonTrigger, $sitterTrigger) -Settings $settings -Principal $principal `
    -Description "CWDB Mission Control dashboard (local-only, http://127.0.0.1:$Port). Task runs the short-lived dashboard-babysitter.ps1 at logon + every 5 min: it probes the port and relaunches dashboard-server.ps1 (detached, logs -> _logs/) only if down. Port-aware + short-lived so the task cannot wedge in a ghost Running state. Source: operations/control-plane/dashboard/dashboard-babysitter.ps1"

Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -InputObject $task | Out-Null

Write-Host ""
Write-Host "Registered $TaskPath$TaskName - starting it now."
Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath
Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Format-List TaskName, TaskPath, State, Description
Write-Host ""
Write-Host "Dashboard: http://127.0.0.1:$Port/  (always on; port-aware babysitter relaunches the server within <=5 min if it dies)"
Write-Host "Logs:      operations/control-plane/dashboard/_logs/ (dashboard-babysitter.log + dashboard-server.log/.err.log)"
