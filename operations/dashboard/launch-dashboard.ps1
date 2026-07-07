<#
.SYNOPSIS
    Launch CWDB HQ locally (full-function mode) and open the browser.

.DESCRIPTION
    On-demand launcher (no resident process, no babysitter): starts Streamlit
    on port 8511 and lets it open the default browser. Ctrl+C in the window
    (or closing it) stops the app. Pin a shortcut to this script for one-click
    access:
        pwsh -File "<repo>\operations\dashboard\launch-dashboard.ps1"
#>
[CmdletBinding()]
param(
    [int] $Port = 8511
)

$ErrorActionPreference = "Stop"
$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$env:CWDB_HQ_MODE = "local"

# If the port is already serving, just open the browser instead of double-starting.
$existing = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if ($existing) {
    Write-Output "CWDB HQ already running on port $Port - opening browser."
    Start-Process "http://localhost:$Port"
    return
}

Write-Output "Starting CWDB HQ on http://localhost:$Port ..."
# CWD must be the app dir so Streamlit picks up .streamlit/config.toml (theme).
# App code never depends on CWD (all paths derive from __file__ in lib/config.py).
Set-Location $appDir
streamlit run (Join-Path $appDir "app.py") --server.port $Port
