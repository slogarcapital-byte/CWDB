<#
.SYNOPSIS
    Register (idempotently) the CWDB job webhook pointing at the
    jobtread-gateway Edge Function /webhook route.

.DESCRIPTION
    The webhook URL embeds JT_WEBHOOK_TOKEN as a query param because JobTread
    cannot send JWTs; the gateway rejects calls without the token (401).
    Re-run safe: skips registration if a webhook with the same URL exists.

.NOTES
    Required env vars (.env.local): JOBTREAD_GRANT_KEY, JOBTREAD_ORG_ID,
    JT_WEBHOOK_TOKEN, SUPABASE_URL.
    Pave schema facts: operations/jobtread/org-setup-notes.md.
#>
[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\load-supabase.ps1"
Load-DotEnvIfNeeded -RepoRoot $RepoRoot

foreach ($v in 'JOBTREAD_GRANT_KEY','JOBTREAD_ORG_ID','JT_WEBHOOK_TOKEN','SUPABASE_URL','SUPABASE_PUBLISHABLE_KEY') {
    if (-not [Environment]::GetEnvironmentVariable($v, 'Process')) { throw "$v missing from .env.local" }
}
$grantKey = $env:JOBTREAD_GRANT_KEY
$orgId    = $env:JOBTREAD_ORG_ID
# apikey param: Supabase gateway requires an apikey on every function call
# even with verify_jwt off; JobTread cannot send headers, so it rides the URL.
# NOTE: repo convention is SUPABASE_URL = the REST url (.../rest/v1/); strip it.
$fnBase   = ($env:SUPABASE_URL -replace '/rest/v1/?$', '') + '/functions/v1'
$hookUrl  = "$fnBase/jobtread-gateway/webhook?token=$($env:JT_WEBHOOK_TOKEN)&apikey=$($env:SUPABASE_PUBLISHABLE_KEY)"

function Invoke-Pave {
    param([Parameter(Mandatory)] [hashtable] $Query)
    $body = @{ query = $Query } | ConvertTo-Json -Depth 24
    try {
        return Invoke-RestMethod -Uri "https://api.jobtread.com/pave" -Method Post `
            -ContentType "application/json" -Body $body
    } catch {
        $msg = if ($_.ErrorDetails) { $_.ErrorDetails.Message } else { $_.Exception.Message }
        throw "Pave error: $msg`nRequest: $body"
    }
}

$existing = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    organization = @{
        '$' = @{ id = $orgId }
        webhooks = @{ '$' = @{ size = 25 }; nodes = @{ id = @{}; url = @{} } }
    }
}
$hooks = @($existing.organization.webhooks.nodes)   # PS7 non-enumeration guard
$mine  = $hooks | Where-Object { $_.url -eq $hookUrl }
if ($mine) {
    Write-Host ("webhook already registered: {0}" -f @($mine)[0].id)
    exit 0
}

$created = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    createWebhook = @{
        '$' = @{ organizationId = $orgId; url = $hookUrl }
        createdWebhook = @{ id = @{} }
    }
}
Write-Host ("webhook registered: {0}" -f $created.createWebhook.createdWebhook.id)
Write-Host ("url: {0}" -f ($hookUrl -replace 'token=.*', 'token=<redacted>'))
exit 0
