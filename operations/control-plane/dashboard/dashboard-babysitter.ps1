<#
.SYNOPSIS
    CWDB Mission Control babysitter. Port-aware keep-alive for dashboard-server.ps1.

.DESCRIPTION
    Run by the \CWDB\CWDB-Dashboard scheduled task on every tick (logon + every 5 min).
    Short-lived by design: probes http://127.0.0.1:<Port>/ and

      - if the server answers -> logs one line and exits 0 (the cheap common case), or
      - if it does not answer -> (re)launches dashboard-server.ps1 detached, with stdout and
        stderr redirected into _logs/, then exits 0.

    WHY THIS EXISTS (incident 2026-06-24): the task used to run dashboard-server.ps1 directly
    and tried to stay "running" one instance forever. When the server process died (e.g. the
    HttpListener accept loop threw on sleep/resume), Task Scheduler did not notice and left the
    task wedged in a ghost "Running" state. MultipleInstances=IgnoreNew then treated that ghost
    as "already up" and SUPPRESSED every 5-minute relaunch - the safety net jammed by the exact
    failure it was built to catch. Judging liveness by the actual PORT (not Scheduler
    bookkeeping), and making the task short-lived (returns to Ready every tick, so it can never
    wedge), removes that blind spot. Mirrors why CWDB-Control-Tick never wedges: it runs, exits,
    and returns to Ready.

.NOTES
    Verified Windows PowerShell 5.1-compatible (no pwsh-only syntax).
    Manual fire: Start-ScheduledTask -TaskName CWDB-Dashboard -TaskPath \CWDB\
    Logs:        operations/control-plane/dashboard/_logs/ (gitignored)
#>
[CmdletBinding()]
param([int] $Port = 7717)

$ErrorActionPreference = 'Stop'

$ScriptRoot = $PSScriptRoot
$Server     = Join-Path $ScriptRoot 'dashboard-server.ps1'
$LogDir     = Join-Path $ScriptRoot '_logs'
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

$sitterLog = Join-Path $LogDir 'dashboard-babysitter.log'
$serverOut = Join-Path $LogDir 'dashboard-server.log'
$serverErr = Join-Path $LogDir 'dashboard-server.err.log'

function Write-SitterLog {
    param([string] $Message)
    $line = '{0}  {1}' -f (Get-Date).ToString('o'), $Message
    try { Add-Content -Path $sitterLog -Value $line -Encoding UTF8 } catch { }
}

# Keep the appending sitter log from growing without bound: at >5 MB, roll to .1 (one backup).
function Limit-LogSize {
    param([string] $Path, [long] $MaxBytes = 5MB)
    try {
        if ((Test-Path $Path) -and ((Get-Item $Path).Length -gt $MaxBytes)) {
            $bak = "$Path.1"
            if (Test-Path $bak) { Remove-Item $bak -Force -ErrorAction SilentlyContinue }
            Move-Item $Path $bak -Force
        }
    } catch { }
}

function Test-DashboardUp {
    param([int] $Port)
    try {
        $r = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/" -UseBasicParsing -TimeoutSec 3
        return ($r.StatusCode -eq 200)
    } catch {
        return $false
    }
}

Limit-LogSize $sitterLog

if (Test-DashboardUp -Port $Port) {
    Write-SitterLog "alive: server answering on $Port"
    exit 0
}

Write-SitterLog "DOWN: no answer on $Port - relaunching dashboard-server.ps1"

# Defensive: a server process can linger without serving (hung, or holding the HTTP.sys binding).
# Kill any so the relaunch can bind cleanly. Matches the server script by command line, never
# this babysitter (different file name).
try {
    $stale = @(Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -and $_.CommandLine -match 'dashboard-server\.ps1' })
    foreach ($s in $stale) {
        Write-SitterLog "killing stale server PID $($s.ProcessId)"
        Stop-Process -Id $s.ProcessId -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-SitterLog "stale-scan error: $($_.Exception.Message)"
}

# Preserve the crashed run's output before Start-Process truncates these files on relaunch:
# move each non-empty log to .prev (one generation kept) so the failure stays diagnosable.
foreach ($f in @($serverErr, $serverOut)) {
    try {
        if ((Test-Path $f) -and ((Get-Item $f).Length -gt 0)) {
            Move-Item $f "$f.prev" -Force -ErrorAction SilentlyContinue
        }
    } catch { }
}

$exe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
try {
    $p = Start-Process -FilePath $exe `
        -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-File', $Server, '-Port', "$Port") `
        -WindowStyle Hidden `
        -RedirectStandardOutput $serverOut `
        -RedirectStandardError  $serverErr `
        -PassThru
    Write-SitterLog "launched server PID $($p.Id)"
} catch {
    Write-SitterLog "LAUNCH FAILED: $($_.Exception.Message)"
    exit 1
}

# Confirm it actually came up (~4s budget). Either way exit 0: a transient miss recovers on the
# next tick, and a persistent startup failure is captured in dashboard-server.err.log.
$up = $false
foreach ($i in 1..6) {
    Start-Sleep -Milliseconds 700
    if (Test-DashboardUp -Port $Port) { $up = $true; break }
}
if ($up) {
    Write-SitterLog "relaunch confirmed: server answering on $Port"
} else {
    Write-SitterLog "WARN: server relaunched but not yet answering on $Port - see dashboard-server.err.log"
}
exit 0
