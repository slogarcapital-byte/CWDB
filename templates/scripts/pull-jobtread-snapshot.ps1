<#
.SYNOPSIS
    Pull JobTread accounts, contacts, jobs, locations (with custom field values)
    via Pave, write a JSON snapshot, UPSERT bronze rows into raw_jobtread_snapshot.

.DESCRIPTION
    Bronze-only by design (mirrors pull-hubspot-snapshot.ps1 philosophy): typed
    projections stay deferred; during the hybrid, fact_leads remains fed by the
    HubSpot pull, so this script never writes fact_leads/fact_bids (design §5,
    reconciliation via the nullable jobtread_* link columns is manual at current
    volume).

    Registered as source #5 in operations/data-warehouse/scripts/run-daily.ps1.

.NOTES
    Required env vars (.env.local at repo root):
      JOBTREAD_GRANT_KEY        - Pave grant (app.jobtread.com/grants)
      JOBTREAD_ORG_ID           - organization id (22PakakWzKDv)
      SUPABASE_URL              - REST url ok; Initialize-SupabaseClient normalizes
      SUPABASE_SERVICE_ROLE_KEY - service_role JWT (server-side only)

    Pave schema facts: operations/jobtread/org-setup-notes.md
    (accounts not customers; jobs hang off locations; customFieldValues is a
    connection on reads).
#>
[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [switch] $SkipSupabase,
    [switch] $DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\load-supabase.ps1"
Load-DotEnvIfNeeded -RepoRoot $RepoRoot

$DataDir  = Join-Path $RepoRoot "_vault\data"
$OutFile  = Join-Path $DataDir "jobtread-latest.json"
$ErrorLog = Join-Path $DataDir "jobtread-error.log"

if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
}

function Write-ErrorLog {
    param([string] $Message)
    $stamp = (Get-Date).ToString("o")
    Add-Content -Path $ErrorLog -Value "[$stamp] $Message" -Encoding utf8
}

$grantKey = $env:JOBTREAD_GRANT_KEY
$orgId    = $env:JOBTREAD_ORG_ID
if (-not $grantKey) { Write-ErrorLog "JOBTREAD_GRANT_KEY missing"; throw "JOBTREAD_GRANT_KEY missing from .env.local" }
if (-not $orgId)    { Write-ErrorLog "JOBTREAD_ORG_ID missing";    throw "JOBTREAD_ORG_ID missing from .env.local" }

function Invoke-Pave {
    param([Parameter(Mandatory)] [hashtable] $Query)
    $body = @{ query = $Query } | ConvertTo-Json -Depth 24
    try {
        return Invoke-RestMethod -Uri "https://api.jobtread.com/pave" -Method Post `
            -ContentType "application/json" -Body $body
    } catch {
        $msg = if ($_.ErrorDetails) { $_.ErrorDetails.Message } else { $_.Exception.Message }
        throw "Pave error: $msg"
    }
}

function Get-PavePage {
    <#
    .SYNOPSIS
        Page through an organization-level Pave connection. Uses nextPage
        cursors when the schema exposes them; falls back to one large page.
    #>
    param(
        [Parameter(Mandatory)] [string] $Node,
        [Parameter(Mandatory)] [hashtable] $Shape,
        # Pave 413s ("Request Entity Too Large") on big pages with nested
        # custom-field connections; 25 stays comfortably under the limit.
        [int] $Size = 25
    )
    $all = @()
    $page = $null
    $usePaging = $true
    while ($true) {
        $connArgs = @{ size = $Size }
        if ($page) { $connArgs.page = $page }
        $conn = @{ '$' = $connArgs; nodes = $Shape }
        if ($usePaging) { $conn.nextPage = @{} }
        try {
            $res = Invoke-Pave @{
                '$' = @{ grantKey = $grantKey }
                organization = @{ '$' = @{ id = $orgId }; $Node = $conn }
            }
        } catch {
            if ($usePaging) {
                # nextPage not supported on this connection: retry unpaged once
                $usePaging = $false
                continue
            }
            throw
        }
        $connection = $res.organization.$Node
        $all += @($connection.nodes)   # PS7 non-enumeration guard
        $next = if ($usePaging -and ($connection.PSObject.Properties.Name -contains 'nextPage')) { $connection.nextPage } else { $null }
        if (-not $next) { break }
        $page = $next
    }
    return ,$all
}

$cfShape = @{ nodes = @{ value = @{}; customField = @{ name = @{}; targetType = @{} } } }

Write-Host "Pulling JobTread org $orgId ..."
$accounts = Get-PavePage -Node 'accounts' -Shape @{
    id = @{}; name = @{}; type = @{}; createdAt = @{}
    customFieldValues = $cfShape
}
$contacts = Get-PavePage -Node 'contacts' -Shape @{
    id = @{}; name = @{}; createdAt = @{}
    account = @{ id = @{} }
    customFieldValues = $cfShape
}
$locations = Get-PavePage -Node 'locations' -Shape @{
    id = @{}; name = @{}; address = @{}
    account = @{ id = @{} }
}
$jobs = Get-PavePage -Node 'jobs' -Shape @{
    id = @{}; name = @{}; createdAt = @{}; number = @{}
    location = @{ id = @{}; account = @{ id = @{} } }
    customFieldValues = $cfShape
}

Write-Host ("pulled: {0} accounts, {1} contacts, {2} locations, {3} jobs" -f `
    @($accounts).Count, @($contacts).Count, @($locations).Count, @($jobs).Count)

$snapshot = [ordered]@{
    pulled_at = (Get-Date).ToUniversalTime().ToString("o")
    source    = "jobtread"
    data      = [ordered]@{
        accounts  = $accounts
        contacts  = $contacts
        locations = $locations
        jobs      = $jobs
    }
    error     = $null
}
$snapshot | ConvertTo-Json -Depth 24 | Set-Content -Path $OutFile -Encoding utf8
Write-Host "snapshot written: $OutFile"

if ($DryRun -or $SkipSupabase) {
    Write-Host "dry-run/skip-supabase: no warehouse write"
    exit 0
}

Initialize-SupabaseClient

$records = [System.Collections.Generic.List[hashtable]]::new()
$pulledAt = $snapshot.pulled_at
foreach ($a in $accounts)  { $records.Add(@{ pulled_at = $pulledAt; object_type = 'account';  object_id = "$($a.id)"; payload = $a }) }
foreach ($c in $contacts)  { $records.Add(@{ pulled_at = $pulledAt; object_type = 'contact';  object_id = "$($c.id)"; payload = $c }) }
foreach ($l in $locations) { $records.Add(@{ pulled_at = $pulledAt; object_type = 'location'; object_id = "$($l.id)"; payload = $l }) }
foreach ($j in $jobs)      { $records.Add(@{ pulled_at = $pulledAt; object_type = 'job';      object_id = "$($j.id)"; payload = $j }) }

if ($records.Count -gt 0) {
    try {
        $n = Invoke-SupabaseUpsert -Table "raw_jobtread_snapshot" -Records $records.ToArray() -ConflictColumns "object_type,object_id"
        Write-Host "raw_jobtread_snapshot upserted: $n rows"
    } catch {
        Write-ErrorLog "raw_jobtread_snapshot upsert failed: $($_.Exception.Message)"
        throw
    }
} else {
    Write-Host "no records to upsert"
}

Write-Host "PULL OK"
exit 0
