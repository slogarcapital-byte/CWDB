<# .SYNOPSIS  Start the Mission Control server and open the browser. #>
[CmdletBinding()] param([int] $Port = 7717)
$server = Join-Path $PSScriptRoot "dashboard-server.ps1"
Start-Process "http://127.0.0.1:$Port/"
& pwsh -NoProfile -File $server -Port $Port
