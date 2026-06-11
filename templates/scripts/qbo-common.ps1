# qbo-common.ps1 - shared QBO API helpers (dot-source from qbo-* scripts)
#
# Credentials are PER ENVIRONMENT so the sandbox and production connections
# coexist in .env.local at the repo root:
#   QBO_ENVIRONMENT                  - sandbox | production (selects the active set)
#   QBO_SANDBOX_CLIENT_ID            - Intuit app "Development" keys
#   QBO_SANDBOX_CLIENT_SECRET
#   QBO_SANDBOX_REALM_ID             - written by qbo-authorize.ps1
#   QBO_SANDBOX_REFRESH_TOKEN        - written by qbo-authorize.ps1; ROTATES
#   QBO_PRODUCTION_CLIENT_ID         - Intuit app "Production" keys
#   QBO_PRODUCTION_CLIENT_SECRET
#   QBO_PRODUCTION_REALM_ID
#   QBO_PRODUCTION_REFRESH_TOKEN
#
# Intuit rotates the refresh token on every refresh and the old one dies 24h
# later; Get-QboAccessToken writes the new token back to .env.local under the
# active environment's key automatically.

$script:QboEnvironmentOverride = $null

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

function Set-QboEnvironmentOverride {
    # Point subsequent qbo-common calls at a specific environment regardless
    # of QBO_ENVIRONMENT (used by qbo-authorize.ps1 -Environment).
    param(
        [Parameter(Mandatory)]
        [ValidateSet("sandbox", "production")]
        [string] $Environment
    )
    $script:QboEnvironmentOverride = $Environment
}

function Get-QboEnvironment {
    if ($script:QboEnvironmentOverride) { return $script:QboEnvironmentOverride }
    if ($env:QBO_ENVIRONMENT -eq "production") { "production" } else { "sandbox" }
}

function Get-QboSettingName {
    param([Parameter(Mandatory)] [string] $Name)
    "QBO_$((Get-QboEnvironment).ToUpperInvariant())_$Name"
}

function Get-QboSetting {
    param(
        [Parameter(Mandatory)] [string] $Name,
        [switch] $Required
    )
    $key = Get-QboSettingName $Name
    $val = [Environment]::GetEnvironmentVariable($key, "Process")
    if (-not $val -and $Required) {
        throw "Missing $key in .env.local (paste the app keys, or run qbo-authorize.ps1 -Environment $(Get-QboEnvironment) for tokens)"
    }
    $val
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
    if ((Get-QboEnvironment) -eq "production") {
        "https://quickbooks.api.intuit.com"
    } else {
        "https://sandbox-quickbooks.api.intuit.com"
    }
}

function Get-QboLogPath {
    # Append-only operational log, one line per QBO API call, so the intuit_tid
    # for any request can be handed to Intuit support and failures are durably
    # recorded. Gitignored; may contain Intuit fault detail.
    $dir = Join-Path (Get-QboRepoRoot) "finance\invoices\_logs"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Join-Path $dir "qbo.log"
}

function Write-QboLog {
    param(
        [Parameter(Mandatory)] [ValidateSet("INFO", "ERROR")] [string] $Level,
        [Parameter(Mandatory)] [string] $Message,
        [string] $Tid
    )
    $ts      = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")
    $tidPart = if ($Tid) { "intuit_tid=$Tid" } else { "intuit_tid=-" }
    $line    = "$ts`t$Level`t$(Get-QboEnvironment)`t$tidPart`t$Message"
    try { Add-Content -Path (Get-QboLogPath) -Value $line -Encoding utf8 } catch { }
}

function Get-QboTidFromHeaders {
    # intuit_tid arrives as a response header on every Intuit call. The hashtable
    # from -ResponseHeadersVariable stores values as string arrays.
    param($Headers)
    if (-not $Headers) { return $null }
    foreach ($key in @("intuit_tid", "Intuit_Tid", "INTUIT_TID")) {
        if ($Headers.ContainsKey($key)) {
            $v = $Headers[$key]
            if ($v -is [System.Array]) { return ($v -join ",") }
            return [string] $v
        }
    }
    return $null
}

function Get-QboTidFromError {
    # On a thrown Invoke-RestMethod call the headers live on the HttpResponse,
    # not in -ResponseHeadersVariable (which never got populated).
    param($ErrorRecord)
    $resp = $ErrorRecord.Exception.Response
    if (-not $resp) { return $null }
    $vals = $null
    try {
        if ($resp.Headers.TryGetValues("intuit_tid", [ref] $vals)) { return ($vals -join ",") }
    } catch { }
    return $null
}

function Get-QboErrorDetail {
    param($ErrorRecord)
    $detail = if ($ErrorRecord.ErrorDetails -and $ErrorRecord.ErrorDetails.Message) {
        $ErrorRecord.ErrorDetails.Message   # Intuit's fault JSON body
    } else {
        $ErrorRecord.Exception.Message
    }
    $detail = ($detail -replace "\s+", " ").Trim()
    if ($detail.Length -gt 1500) { $detail = $detail.Substring(0, 1500) }
    $detail
}

function Get-QboAccessToken {
    # Exchange the stored refresh token for an access token. Intuit ROTATES
    # the refresh token: always persist the new one or the chain dies in 24h.
    Import-QboEnv
    $clientId = Get-QboSetting CLIENT_ID -Required
    $secret   = Get-QboSetting CLIENT_SECRET -Required
    $refresh  = Get-QboSetting REFRESH_TOKEN -Required
    $basic = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(
        "${clientId}:${secret}"))
    $respHeaders = $null
    try {
        $resp = Invoke-RestMethod -Method Post `
            -Uri "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer" `
            -Headers @{ Authorization = "Basic $basic"; Accept = "application/json" } `
            -ContentType "application/x-www-form-urlencoded" `
            -Body @{ grant_type = "refresh_token"; refresh_token = $refresh } `
            -ResponseHeadersVariable respHeaders
    } catch {
        Write-QboLog -Level ERROR -Message "token refresh FAILED: $(Get-QboErrorDetail $_)" `
            -Tid (Get-QboTidFromError $_)
        throw
    }
    $rotated = $false
    if ($resp.refresh_token -and $resp.refresh_token -ne $refresh) {
        Set-QboEnvVar -Name (Get-QboSettingName REFRESH_TOKEN) -Value $resp.refresh_token
        $rotated = $true
    }
    Write-QboLog -Level INFO -Message "token refresh ok (rotated=$rotated)" `
        -Tid (Get-QboTidFromHeaders $respHeaders)
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
    $realm = Get-QboSetting REALM_ID -Required
    $uri   = "$base/v3/company/$realm/$Path"
    $headers = @{ Authorization = "Bearer $token"; Accept = "application/json" }
    $respHeaders = $null
    try {
        if ($null -ne $Body) {
            $result = Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers `
                -ContentType "application/json" -Body ($Body | ConvertTo-Json -Depth 10) `
                -ResponseHeadersVariable respHeaders
        } else {
            $result = Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers `
                -ResponseHeadersVariable respHeaders
        }
    } catch {
        Write-QboLog -Level ERROR -Message "$($Method.ToUpper()) $Path FAILED: $(Get-QboErrorDetail $_)" `
            -Tid (Get-QboTidFromError $_)
        throw
    }
    Write-QboLog -Level INFO -Message "$($Method.ToUpper()) $Path" -Tid (Get-QboTidFromHeaders $respHeaders)
    return $result
}
