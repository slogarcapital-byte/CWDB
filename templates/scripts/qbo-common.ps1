# qbo-common.ps1 - shared QBO API helpers (dot-source from qbo-* scripts)
#
# Env vars (in .env.local at repo root):
#   QBO_CLIENT_ID, QBO_CLIENT_SECRET  - Intuit developer app keys
#   QBO_REALM_ID                      - company id (set by qbo-authorize.ps1)
#   QBO_ENVIRONMENT                   - sandbox | production
#   QBO_REFRESH_TOKEN                 - rotated by Intuit on every refresh;
#                                       Get-QboAccessToken writes the new one
#                                       back to .env.local automatically.

function Get-QboRepoRoot {
    (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

function Import-QboEnv {
    param([string] $RepoRoot = (Get-QboRepoRoot))
    $envFile = Join-Path $RepoRoot ".env.local"
    if (-not (Test-Path $envFile)) { throw ".env.local not found at $envFile" }
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $idx  = $line.IndexOf("=")
            $name = $line.Substring(0, $idx).Trim()
            $val  = $line.Substring($idx + 1).Trim().Trim("'`"")
            [Environment]::SetEnvironmentVariable($name, $val, "Process")
        }
    }
}

function Set-QboEnvVar {
    # Persist NAME=value into .env.local (replace line or append).
    param(
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] [string] $Value,
        [string] $RepoRoot = (Get-QboRepoRoot)
    )
    $envFile = Join-Path $RepoRoot ".env.local"
    $lines = @(Get-Content $envFile)
    $found = $false
    $lines = $lines | ForEach-Object {
        if ($_ -match "^\s*$Name\s*=") { $found = $true; "$Name=$Value" } else { $_ }
    }
    if (-not $found) { $lines += "$Name=$Value" }
    Set-Content -Path $envFile -Value $lines -Encoding utf8
    [Environment]::SetEnvironmentVariable($Name, $Value, "Process")
}

function Get-QboApiBase {
    if ($env:QBO_ENVIRONMENT -eq "production") {
        "https://quickbooks.api.intuit.com"
    } else {
        "https://sandbox-quickbooks.api.intuit.com"
    }
}

function Get-QboAccessToken {
    # Exchange the stored refresh token for an access token. Intuit ROTATES
    # the refresh token: always persist the new one or the chain dies in 24h.
    Import-QboEnv
    foreach ($v in 'QBO_CLIENT_ID','QBO_CLIENT_SECRET','QBO_REFRESH_TOKEN') {
        if (-not [Environment]::GetEnvironmentVariable($v, 'Process')) {
            throw "Missing $v in .env.local (run qbo-authorize.ps1 first)"
        }
    }
    $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(
        "$($env:QBO_CLIENT_ID):$($env:QBO_CLIENT_SECRET)"))
    $resp = Invoke-RestMethod -Method Post `
        -Uri "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer" `
        -Headers @{ Authorization = "Basic $basic"; Accept = "application/json" } `
        -ContentType "application/x-www-form-urlencoded" `
        -Body @{ grant_type = "refresh_token"; refresh_token = $env:QBO_REFRESH_TOKEN }
    if ($resp.refresh_token -and $resp.refresh_token -ne $env:QBO_REFRESH_TOKEN) {
        Set-QboEnvVar -Name "QBO_REFRESH_TOKEN" -Value $resp.refresh_token
    }
    return $resp.access_token
}

function Invoke-QboApi {
    # Minimal wrapper: Invoke-QboApi -Method Get -Path "companyinfo/<realm>"
    # or -Path "query?query=..." or -Method Post -Path "invoice" -Body $obj
    param(
        [string] $Method = "Get",
        [Parameter(Mandatory)] [string] $Path,
        $Body = $null
    )
    $token = Get-QboAccessToken
    $base  = Get-QboApiBase
    $uri   = "$base/v3/company/$($env:QBO_REALM_ID)/$Path"
    $headers = @{ Authorization = "Bearer $token"; Accept = "application/json" }
    if ($null -ne $Body) {
        Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers `
            -ContentType "application/json" -Body ($Body | ConvertTo-Json -Depth 10)
    } else {
        Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
    }
}
