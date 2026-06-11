<#
.SYNOPSIS
    One-time QBO OAuth2 authorization for ONE environment (sandbox or
    production). Writes the environment's QBO_<ENV>_REFRESH_TOKEN +
    QBO_<ENV>_REALM_ID into .env.local.

.DESCRIPTION
    Sandbox/development uses an http://localhost loopback redirect: a raw
    TcpListener on 127.0.0.1 auto-catches the callback (no admin urlacl needed).

    PRODUCTION redirect URIs must be PUBLIC HTTPS - Intuit rejects http://,
    localhost, and bare IPs on the Production tab - so there is nothing on this
    machine to catch the callback. The production redirect therefore points at a
    page on our own domain (default https://cwdeckbuilders.com/qbo-callback,
    which may 404; the OAuth code is still in the browser's address bar). Flow:
      1. Run with -Environment production to PRINT the consent URL.
      2. Consent in the browser, picking the REAL company (realm
         9341457249522270), then copy `code` and `realmId` out of the URL the
         browser lands on.
      3. Re-run with -Code/-RealmId to exchange them for tokens.

.EXAMPLE
    pwsh templates/scripts/qbo-authorize.ps1                            # sandbox, auto-capture
.EXAMPLE
    pwsh templates/scripts/qbo-authorize.ps1 -Environment production    # step 1: print consent URL
    pwsh templates/scripts/qbo-authorize.ps1 -Environment production -Code <code> -RealmId <realm>
#>

[CmdletBinding()]
param(
    [ValidateSet("sandbox", "production")]
    [string] $Environment,
    [string] $RedirectUri,
    [string] $Code,
    [string] $RealmId,
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

# Production must use a public HTTPS redirect; sandbox/dev uses the loopback.
if (-not $RedirectUri) {
    $RedirectUri = if ($Environment -eq "production") {
        "https://cwdeckbuilders.com/qbo-callback"
    } else {
        "http://localhost:8000/callback"
    }
}
$redirect = $RedirectUri
$basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(
    "${clientId}:${clientSecret}"))

function Complete-QboAuthorization {
    # Exchange an auth code for tokens, persist them, and verify. The
    # redirect_uri here MUST match the one used to obtain the code.
    param([Parameter(Mandatory)] [string] $AuthCode, [string] $Realm)
    Write-Output "Exchanging auth code for tokens ($Environment)..."
    $tokens = Invoke-RestMethod -Method Post `
        -Uri "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer" `
        -Headers @{ Authorization = "Basic $basic"; Accept = "application/json" } `
        -ContentType "application/x-www-form-urlencoded" `
        -Body @{ grant_type = "authorization_code"; code = $AuthCode; redirect_uri = $redirect }
    Set-QboEnvVar -Name (Get-QboSettingName REFRESH_TOKEN) -Value $tokens.refresh_token
    if ($Realm) { Set-QboEnvVar -Name (Get-QboSettingName REALM_ID) -Value $Realm }
    Write-Output "Tokens stored. Verifying with CompanyInfo..."
    $verifyRealm = if ($Realm) { $Realm } else { Get-QboSetting REALM_ID -Required }
    $info = Invoke-QboApi -Path "companyinfo/$verifyRealm"
    Write-Output ("CONNECTED: " + $info.CompanyInfo.CompanyName +
        " (realm $verifyRealm, env $Environment)")
}

# --- manual exchange mode: caller already has the code (production) ----------
if ($Code) {
    if (-not $RealmId) {
        throw "Provide -RealmId together with -Code (both are in the redirected URL)."
    }
    Complete-QboAuthorization -AuthCode $Code -Realm $RealmId
    return
}

$authUrl = "https://appcenter.intuit.com/connect/oauth2" +
    "?client_id=$clientId" +
    "&response_type=code" +
    "&scope=com.intuit.quickbooks.accounting" +
    "&redirect_uri=" + [uri]::EscapeDataString($redirect) +
    "&state=$State"

Write-Output "Authorizing the $Environment environment."
Write-Output "Redirect URI: $redirect"
Write-Output "AUTHORIZE URL:"
Write-Output $authUrl
Write-Output ""

$isLoopback = $redirect -match "^https?://(localhost|127\.0\.0\.1)(:\d+)?(/|$)"

if (-not $isLoopback) {
    Write-Output "Production redirect is public HTTPS, so there is no local listener."
    Write-Output "1. Open the URL above, sign in, and pick the REAL company"
    Write-Output "   (Central Wisconsin Deck Builders, realm 9341457249522270)."
    Write-Output "2. The browser lands on:"
    Write-Output "   $($redirect)?code=...&realmId=...&state=..."
    Write-Output "   The page may 404 - the values are in the address bar."
    Write-Output "3. Re-run with the copied values:"
    Write-Output "   pwsh templates/scripts/qbo-authorize.ps1 -Environment $Environment -Code <code> -RealmId <realmId>"
    return
}

# --- loopback auto-capture mode (sandbox/dev) --------------------------------
Write-Output "Waiting up to $TimeoutMinutes minutes on $redirect ..."

$port = ([uri]$redirect).Port
$listener = [System.Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $port)
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

Write-Output "Auth code received (realm $realm)."
Complete-QboAuthorization -AuthCode $code -Realm $realm
