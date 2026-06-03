<#
.SYNOPSIS
    Register the CWDB-Warehouse-Daily scheduled task. Idempotent. Re-running
    rotates the task config cleanly.

.DESCRIPTION
    Creates a Windows Task Scheduler entry that runs run-daily.ps1 every day
    at 06:55 local time (America/Chicago, Central). Options:
      - StartWhenAvailable: true (catches up after machine-off windows)
      - ExecutionTimeLimit: 30 minutes (kill if anything hangs)
      - Runs as current user, only when logged on (avoids password storage)

.NOTES
    Run once. Verify with:
      Get-ScheduledTask -TaskPath \CWDB\ | Format-List TaskName, State, Triggers
      Get-ScheduledTaskInfo -TaskName CWDB-Warehouse-Daily -TaskPath \CWDB\
    Manually fire with:
      Start-ScheduledTask -TaskName CWDB-Warehouse-Daily -TaskPath \CWDB\

    To uninstall:
      Unregister-ScheduledTask -TaskName CWDB-Warehouse-Daily -TaskPath \CWDB\ -Confirm:$false
#>

[CmdletBinding()]
param(
    [string] $TaskName = 'CWDB-Warehouse-Daily',
    [string] $TaskPath = '\CWDB\',
    [string] $TriggerTime = '06:55'
)

$ErrorActionPreference = 'Stop'

$ScriptRoot = $PSScriptRoot
$RepoRoot   = (Resolve-Path (Join-Path $ScriptRoot "..\..\..")).Path
$RunDaily   = Join-Path $ScriptRoot 'run-daily.ps1'

if (-not (Test-Path $RunDaily)) {
    throw "run-daily.ps1 not found at expected path: $RunDaily"
}

Write-Host "RepoRoot: $RepoRoot"
Write-Host "RunDaily: $RunDaily"

# If the task already exists, remove it so we start clean.
$existing = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "Existing task found at $TaskPath$TaskName. Unregistering before rotation."
    Unregister-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -Confirm:$false
}

$argString = '-NoProfile -ExecutionPolicy Bypass -File "' + $RunDaily + '"'
$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument $argString `
    -WorkingDirectory $RepoRoot

$trigger = New-ScheduledTaskTrigger -Daily -At $TriggerTime

$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30) `
    -MultipleInstances IgnoreNew `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries

$principal = New-ScheduledTaskPrincipal `
    -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) `
    -LogonType Interactive `
    -RunLevel Limited

$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal `
    -Description "Daily CWDB warehouse refresh: pulls HubSpot, Google Ads, Meta Ads, GA4 and UPSERTs into Supabase. Source: operations/data-warehouse/scripts/run-daily.ps1"

Register-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -InputObject $task | Out-Null

Write-Host ""
Write-Host "Registered $TaskPath$TaskName"
Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath | Format-List TaskName, TaskPath, State, Description
Write-Host ""
Write-Host "Trigger: daily at $TriggerTime local time."
Write-Host "Manual fire: Start-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath"
