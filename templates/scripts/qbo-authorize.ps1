<#
.SYNOPSIS
    One-time QBO OAuth2 authorization for ONE environment (sandbox or
    production). Catches the redirect on http://localhost:8000/callback,
    exchanges the code for tokens, and writes the environment's
    QBO_<ENV>_REFRESH_TOKEN + QBO_<ENV>_REALM_ID into .env.local.

.DESCRIPTION
    1. Prints the Intuit authorize URL (or accepts -State so the caller can
       print it). Jim opens it, signs in, picks the company, clicks Connect.
       For -Environment production pick the REAL CWDB company on the consent
       screen (realm 9341457249522270), not the sandbox company.
    2. A raw TcpListener on 127.0.0.1:8000 catches the callback (no admin
       urlacl needed, unlike HttpListener).
    3. Exchanges the auth code, persists refresh token + realm under the
       environment-suffixed keys, and verifies with a CompanyInfo read.

.EXAMPLE
    pwsh templates/scripts/qbo-authorize.ps1                            # active env
    pwsh templates/scripts/qbo-authorize.ps1 -Environment production    # go-live
#>

[CmdletBinding()]
param(
    [ValidateSet("sandbox", "production")]
    [string] $Environment,
    [string] $State = [guid]::NewGuid().ToString("N"),
    [int] $TimeoutMinutes = 15
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\qbo-common.ps1"
Import-QboEnv
if (-not $Environment) { $Environment = Get-QboEnvironment }
Set-QboEnvironmentOverride $Environment

$clientId     = Get-QboSetting CLIENT_ID -Required
$clientSecret = Get-QboSetting CLIENT_SECRET -Required

$redirect = "http://localhost:8000/callback"
$authUrl = "https://appcenter.intuit.com/connect/oauth2" +
    "?client_id=$clientId" +
    "&response_type=code" +
    "&scope=com.intuit.quickbooks.accounting" +
    "&redirect_uri=" + [uri]::EscapeDataString($redirect) +
    "&state=$State"

Write-Output "Authorizing the $Environment environment."
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
    "${clientId}:${clientSecret}"))
$tokens = Invoke-RestMethod -Method Post `
    -Uri "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer" `
    -Headers @{ Authorization = "Basic $basic"; Accept = "application/json" } `
    -ContentType "application/x-www-form-urlencoded" `
    -Body @{ grant_type = "authorization_code"; code = $code; redirect_uri = $redirect }

Set-QboEnvVar -Name (Get-QboSettingName REFRESH_TOKEN) -Value $tokens.refresh_token
if ($realm) { Set-QboEnvVar -Name (Get-QboSettingName REALM_ID) -Value $realm }
Write-Output "Tokens stored. Verifying with CompanyInfo..."

$info = Invoke-QboApi -Path "companyinfo/$realm"
Write-Output ("CONNECTED: " + $info.CompanyInfo.CompanyName +
    " (realm $realm, env $Environment)")
