<#
.SYNOPSIS
    Prototype Pave API query: verify the grant works, discover the org id,
    and confirm the CWDB custom fields + 10-stage Status funnel are queryable.

.DESCRIPTION
    Read-only except for appending JOBTREAD_ORG_ID to .env.local on first run.
    Pave endpoint: POST https://api.jobtread.com/pave
    Body: single JSON "query" object; grantKey rides inside "$" args.

    Live schema facts (validated 2026-07-14) live in
    operations/jobtread/org-setup-notes.md under "Pave schema facts".
    Key ones encoded here: org discovery goes through
    currentGrant.user.memberships; customers are "accounts"; job stages are
    options on the job "Status" custom field.
#>
[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\load-supabase.ps1"
Load-DotEnvIfNeeded -RepoRoot $RepoRoot

$grantKey = $env:JOBTREAD_GRANT_KEY
if (-not $grantKey) { throw "JOBTREAD_GRANT_KEY missing from .env.local" }

function Invoke-Pave {
    param([Parameter(Mandatory)] [hashtable] $Query)
    $body = @{ query = $Query } | ConvertTo-Json -Depth 24
    try {
        return Invoke-RestMethod -Uri "https://api.jobtread.com/pave" -Method Post `
            -ContentType "application/json" -Body $body
    } catch {
        $detail = if ($_.ErrorDetails) { $_.ErrorDetails.Message } else { $_.Exception.Message }
        Write-Host "--- PAVE ERROR (schema hints live here) ---"
        Write-Host $detail
        Write-Host "--- request was ---"
        Write-Host $body
        throw
    }
}

Write-Host "=== 1. currentGrant -> user -> memberships -> organization ==="
$who = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    currentGrant = @{
        id = @{}
        user = @{
            name = @{}
            memberships = @{ nodes = @{ organization = @{ id = @{}; name = @{} } } }
        }
    }
}
$org   = @($who.currentGrant.user.memberships.nodes)[0].organization
$orgId = $org.id
Write-Host ("org: {0} ({1})" -f $org.name, $orgId)

Write-Host "=== 2. accounts (customers; first 5, with custom field values) ==="
$accounts = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    organization = @{
        '$' = @{ id = $orgId }
        accounts = @{
            '$' = @{ size = 5 }
            nodes = @{
                id = @{}; name = @{}; type = @{}
                customFieldValues = @{ nodes = @{ value = @{}; customField = @{ name = @{} } } }
            }
        }
    }
}
$accounts | ConvertTo-Json -Depth 24 | Write-Host

Write-Host "=== 3. jobs (first 5, with custom field values incl. Status) ==="
$jobs = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    organization = @{
        '$' = @{ id = $orgId }
        jobs = @{
            '$' = @{ size = 5 }
            nodes = @{
                id = @{}; name = @{}
                customFieldValues = @{ nodes = @{ value = @{}; customField = @{ name = @{} } } }
            }
        }
    }
}
$jobs | ConvertTo-Json -Depth 24 | Write-Host

Write-Host "=== 4. custom field definitions ==="
$fields = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    organization = @{
        '$' = @{ id = $orgId }
        customFields = @{
            '$' = @{ size = 100 }
            nodes = @{ id = @{}; name = @{}; type = @{}; targetType = @{}; options = @{} }
        }
    }
}
@($fields.organization.customFields.nodes) | ForEach-Object {
    $opts = if ($_.PSObject.Properties.Name -contains 'options' -and $_.options) { $_.options -join ' | ' } else { '' }
    Write-Host ("{0}`t{1}`t{2}`t{3}" -f $_.targetType, $_.type, $_.name, $opts)
}

Write-Host "=== 5. persist org id ==="
$envFile = Join-Path $RepoRoot ".env.local"
$raw = Get-Content $envFile -Raw
if ($raw -notmatch '(?m)^JOBTREAD_ORG_ID=') {
    # Guard the no-trailing-newline trap: ensure the file ends with a newline first.
    if ($raw -notmatch '[\r\n]$') { Add-Content $envFile "" }
    Add-Content $envFile "JOBTREAD_ORG_ID=$orgId"
    Write-Host "JOBTREAD_ORG_ID appended to .env.local"
} else {
    Write-Host "JOBTREAD_ORG_ID already present"
}

Write-Host "PAVE PROTOTYPE OK"
