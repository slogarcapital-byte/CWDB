<#
.SYNOPSIS
    Register the CWDB-Dashboard scheduled task. Idempotent (re-running rotates it cleanly).

.DESCRIPTION
    Runs dashboard-server.ps1 as an always-on local service: starts hidden at user logon,
    no execution time limit. Resilience comes from a BABYSITTER TRIGGER (every 5 minutes,
    all day, MultipleInstances IgnoreNew): if the server is alive the start is ignored;
    if it died, the next 5-minute tick relaunches it. (Task Scheduler's native
    RestartCount proved unreliable for killed processes - verified 2026-06-10.) After
    installing, the Mission Control deck is simply always at http://127.0.0.1:7717 -
    no terminal window, no Claude session required.

    Mirrors install-control-tick.ps1 (same 5.1 principal / battery / StartWhenAvailable
    posture). dashboard-server.ps1 is verified Windows PowerShell 5.1-compatible.

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

$ScriptRoot = $PSScriptRoot
$RepoRoot   = (Resolve-Path (Join-Path $ScriptRoot "..\..\..")).Path
$Server     = Join-Path $ScriptRoot 'dashboard-server.ps1'
if (-not (Test-Path $Server)) { throw "dashboard-server.ps1 not found at: $Server" }

Write-Host "RepoRoot: $RepoRoot"
Write-Host "Server:   $Server"

$existing = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Existing task at $TaskPath$TaskName - stopping + unregistering before rotation."
    Stop-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
}

# Stable Windows PowerShell 5.1 path - same rationale as install-control-tick.ps1
# (pwsh on this box is an MSIX build with an ACL-restricted, version-stamped path).
$exe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

$argString = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $Server + '" -Port ' + $Port
$action = New-ScheduledTaskAction -Execute $exe -Argument $argString -WorkingDirectory $RepoRoot

# Trigger 1: instant start at logon. Trigger 2: babysitter - daily at 00:00 repeating
# every 5 min for 24h; with IgnoreNew this is a no-op while the server lives and a
# relaunch within <=5 min when it doesn't.
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
    -Description "CWDB Mission Control dashboard server (local-only, http://127.0.0.1:$Port). Starts at logon; 5-min babysitter trigger relaunches it if it dies. Source: operations/control-plane/dashboard/dashboard-server.ps1"

Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -InputObject $task | Out-Null

Write-Host ""
Write-Host "Registered $TaskPath$TaskName - starting it now."
Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath
Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Format-List TaskName, TaskPath, State, Description
Write-Host ""
Write-Host "Dashboard: http://127.0.0.1:$Port/  (always on from now on; survives logoff/reboot via logon trigger)"
