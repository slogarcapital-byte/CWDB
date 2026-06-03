<#
.SYNOPSIS
    Grant a Google identity (typically a service account) Viewer access on a GA4
    property via the Analytics Admin API, bypassing the GA4 UI's email validator.

.DESCRIPTION
    Workaround for the GA4 UI's "doesn't match a Google Account" rejection of
    service-account emails. Uses the same OAuth client as Google Ads, requests a
    one-time access token with the analytics.manage.users scope, then calls:

      POST https://analyticsadmin.googleapis.com/v1alpha/properties/{id}/accessBindings

.NOTES
    Required env vars (read from .env.local at repo root):
      GOOGLE_ADS_CLIENT_ID
      GOOGLE_ADS_CLIENT_SECRET

    Run AS the Google identity that has GA4 Admin rights on the property
    (typically slogarjw@gmail.com). One-shot — no token persisted.
#>

[CmdletBinding()]
param(
    [string] $RepoRoot     = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [string] $PrincipalEmail = "cwdb-ga4-reader@cwdb-ads-pull.iam.gserviceaccount.com",
    [string] $PropertyId   = "533582902",
    [string] $Role         = "predefinedRoles/viewer"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Load-DotEnv {
    param([string] $Path)
    if (-not (Test-Path $Path)) { return }
    Get-Content $Path | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $idx  = $line.IndexOf("=")
            $name = $line.Substring(0, $idx).Trim()
            $val  = $line.Substring($idx + 1).Trim().Trim("'`"")
            if ($name -and -not [Environment]::GetEnvironmentVariable($name, "Process")) {
                [Environment]::SetEnvironmentVariable($name, $val, "Process")
            }
        }
    }
}

Load-DotEnv -Path (Join-Path $RepoRoot ".env.local")

$ClientId     = $env:GOOGLE_ADS_CLIENT_ID
$ClientSecret = $env:GOOGLE_ADS_CLIENT_SECRET
if (-not $ClientId)     { throw "Missing GOOGLE_ADS_CLIENT_ID in .env.local" }
if (-not $ClientSecret) { throw "Missing GOOGLE_ADS_CLIENT_SECRET in .env.local" }

$Scope    = "https://www.googleapis.com/auth/analytics.manage.users"
$Redirect = "http://localhost:8765/"

$AuthUrl = "https://accounts.google.com/o/oauth2/v2/auth" +
           "?client_id=$ClientId" +
           "&redirect_uri=$([uri]::EscapeDataString($Redirect))" +
           "&response_type=code" +
           "&scope=$([uri]::EscapeDataString($Scope))" +
           "&access_type=online" +
           "&prompt=consent"

Write-Host ""
Write-Host "Opening Google consent screen in your browser..." -ForegroundColor Cyan
Write-Host "Sign in as the Google identity that has GA4 Admin on property $PropertyId"
Write-Host "(typically slogarjw@gmail.com)."
Write-Host ""
Start-Process $AuthUrl

Write-Host "After clicking Allow, your browser redirects to http://localhost:8765/?code=..."
Write-Host "The page will fail to load. That's expected."
Write-Host "Copy the FULL value of the 'code' parameter from the URL bar."
Write-Host ""
$Code = Read-Host "Paste the code"
if (-not $Code) { throw "No code provided." }

Write-Host ""
Write-Host "Exchanging code for access token..." -ForegroundColor Cyan
$tokResp = Invoke-RestMethod -Method Post -Uri "https://oauth2.googleapis.com/token" `
    -Body @{
        code          = $Code
        client_id     = $ClientId
        client_secret = $ClientSecret
        redirect_uri  = $Redirect
        grant_type    = "authorization_code"
    } `
    -ContentType "application/x-www-form-urlencoded"

if (-not $tokResp.access_token) { throw "Token exchange failed (no access_token in response)." }
$accessToken = $tokResp.access_token
Write-Host "  -> access token acquired (scope: $($tokResp.scope))" -ForegroundColor Green

Write-Host ""
Write-Host "Granting $Role on property $PropertyId to $PrincipalEmail..." -ForegroundColor Cyan
$url = "https://analyticsadmin.googleapis.com/v1alpha/properties/$PropertyId/accessBindings"
$body = @{
    user  = $PrincipalEmail
    roles = @($Role)
} | ConvertTo-Json -Depth 4

# curl.exe surfaces the response body on 4xx, unlike Invoke-RestMethod.
# Body goes to a temp file so PowerShell 5.1 doesn't strip inner JSON quotes
# during native-command argument escaping.
$tmpHeaders = New-TemporaryFile
$tmpBody    = New-TemporaryFile
$tmpReqBody = New-TemporaryFile
try {
    [System.IO.File]::WriteAllText($tmpReqBody.FullName, $body, [System.Text.UTF8Encoding]::new($false))
    $curlArgs = @(
        "-s","-S",
        "-D", $tmpHeaders.FullName,
        "-o", $tmpBody.FullName,
        "-w", "%{http_code}",
        "-X","POST",
        "-H","Authorization: Bearer $accessToken",
        "-H","Content-Type: application/json",
        "--data-binary","@$($tmpReqBody.FullName)",
        $url
    )
    $httpCode = & curl.exe @curlArgs
    $respBody = Get-Content $tmpBody.FullName -Raw -ErrorAction SilentlyContinue
    if ($httpCode -match "^2") {
        $resp = $respBody | ConvertFrom-Json
        Write-Host ""
        Write-Host "SUCCESS (HTTP $httpCode)" -ForegroundColor Green
        Write-Host "  binding name : $($resp.name)"
        Write-Host "  user         : $($resp.user)"
        Write-Host "  roles        : $($resp.roles -join ', ')"
        exit 0
    } else {
        Write-Host ""
        Write-Host "FAILED (HTTP $httpCode)" -ForegroundColor Red
        Write-Host "  url  : $url"
        Write-Host "  body :"
        Write-Host $respBody
        exit 1
    }
}
finally {
    Remove-Item $tmpHeaders.FullName -Force -ErrorAction SilentlyContinue
    Remove-Item $tmpBody.FullName    -Force -ErrorAction SilentlyContinue
    Remove-Item $tmpReqBody.FullName -Force -ErrorAction SilentlyContinue
}
