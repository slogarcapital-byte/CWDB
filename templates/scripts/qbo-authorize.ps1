<#
.SYNOPSIS
    One-time QBO OAuth2 authorization. Catches the redirect on
    http://localhost:8000/callback, exchanges the code for tokens, and writes
    QBO_REFRESH_TOKEN + QBO_REALM_ID into .env.local.

.DESCRIPTION
    1. Prints the Intuit authorize URL (or accepts -State so the caller can
       print it). Jim opens it, signs in, picks the company, clicks Connect.
    2. A raw TcpListener on 127.0.0.1:8000 catches the callback (no admin
       urlacl needed, unlike HttpListener).
    3. Exchanges the auth code, persists refresh token + realm, and verifies
       with a CompanyInfo read.
#>

[CmdletBinding()]
param(
    [string] $State = [guid]::NewGuid().ToString("N"),
    [int] $TimeoutMinutes = 15
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\qbo-common.ps1"
Import-QboEnv

foreach ($v in 'QBO_CLIENT_ID','QBO_CLIENT_SECRET') {
    if (-not [Environment]::GetEnvironmentVariable($v, 'Process')) {
        throw "Missing $v in .env.local"
    }
}

$redirect = "http://localhost:8000/callback"
$authUrl = "https://appcenter.intuit.com/connect/oauth2" +
    "?client_id=$($env:QBO_CLIENT_ID)" +
    "&response_type=code" +
    "&scope=com.intuit.quickbooks.accounting" +
    "&redirect_uri=" + [uri]::EscapeDataString($redirect) +
    "&state=$State"

Write-Output "AUTHORIZE URL:"
Write-Output $authUrl
Write-Output ""
Write-Output "Waiting up to $TimeoutMinutes minutes on $redirect ..."

$listener = [System.Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 8000)
$listener.Start()
$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
$code = $null; $realm = $null
try {
    while ((Get-Date) -lt $deadline) {
        if (-not $listener.Pending()) { Start-Sleep -Milliseconds 250; continue }
        $client = $listener.AcceptTcpClient()
        try {
            $stream = $client.GetStream()
            $reader = [IO.StreamReader]::new($stream)
            $requestLine = $reader.ReadLine()
            while (($null -ne ($l = $reader.ReadLine())) -and $l -ne "") { }  # drain headers

            $isCallback = $requestLine -match "^GET\s+/callback\?(\S+)\s"
            if ($isCallback) {
                $qs = @{}
                foreach ($pair in $Matches[1].Split("&")) {
                    $kv = $pair.Split("=", 2)
                    if ($kv.Count -eq 2) { $qs[$kv[0]] = [uri]::UnescapeDataString($kv[1]) }
                }
                if ($qs["state"] -ne $State) {
                    $html = "<h2>State mismatch. Try again.</h2>"
                } elseif ($qs["code"]) {
                    $code  = $qs["code"]
                    $realm = $qs["realmId"]
                    $html = "<h2>Connected. You can close this window and return to Claude.</h2>"
                } else {
                    $html = "<h2>No code in callback: $($qs['error'])</h2>"
                }
            } else {
                $html = "<h2>Waiting for the Intuit callback...</h2>"
            }
            $bodyBytes = [Text.Encoding]::UTF8.GetBytes(
                "<html><body style='font-family:sans-serif'>$html</body></html>")
            $resp = "HTTP/1.1 200 OK`r`nContent-Type: text/html`r`n" +
                    "Content-Length: $($bodyBytes.Length)`r`nConnection: close`r`n`r`n"
            $respBytes = [Text.Encoding]::ASCII.GetBytes($resp)
            $stream.Write($respBytes, 0, $respBytes.Length)
            $stream.Write($bodyBytes, 0, $bodyBytes.Length)
            $stream.Flush()
        } finally { $client.Close() }
        if ($code) { break }
    }
} finally { $listener.Stop() }

if (-not $code) { throw "Timed out waiting for the OAuth callback." }

Write-Output "Auth code received (realm $realm). Exchanging for tokens..."
$basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(
    "$($env:QBO_CLIENT_ID):$($env:QBO_CLIENT_SECRET)"))
$tokens = Invoke-RestMethod -Method Post `
    -Uri "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer" `
    -Headers @{ Authorization = "Basic $basic"; Accept = "application/json" } `
    -ContentType "application/x-www-form-urlencoded" `
    -Body @{ grant_type = "authorization_code"; code = $code; redirect_uri = $redirect }

Set-QboEnvVar -Name "QBO_REFRESH_TOKEN" -Value $tokens.refresh_token
if ($realm) { Set-QboEnvVar -Name "QBO_REALM_ID" -Value $realm }
Write-Output "Tokens stored. Verifying with CompanyInfo..."

$info = Invoke-QboApi -Path "companyinfo/$realm"
Write-Output ("CONNECTED: " + $info.CompanyInfo.CompanyName +
    " (realm $realm, env $($env:QBO_ENVIRONMENT))")
