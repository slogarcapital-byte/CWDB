<#
.SYNOPSIS
    Idempotent JobTread org configuration via Pave API.
    Creates the CWDB custom-field set, replaces the default job Status options
    with the 10-stage Phase 2 funnel, and creates the solo cost-code set.

.DESCRIPTION
    Safe to re-run: queries existing custom fields first and only creates what
    is missing. Encodes operations/jobtread/org-config-worksheet.csv rows 1-37
    (row 38, the phone-only Customer check, stays manual).

    Field placement deviation from the worksheet (accepted 2026-07-14):
    tcpa_consent_given / tcpa_consent_source / lead_channel live on
    customerContact (Jim created them there; consent belongs to a person).
    UTM attribution set lives on customer (the account) per the design.

.NOTES
    Required env vars (.env.local): JOBTREAD_GRANT_KEY, JOBTREAD_ORG_ID
#>
[CmdletBinding()]
param(
    [string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [switch] $DryRun
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

. "$PSScriptRoot\load-supabase.ps1"
Load-DotEnvIfNeeded -RepoRoot $RepoRoot

$grantKey = $env:JOBTREAD_GRANT_KEY
$orgId    = $env:JOBTREAD_ORG_ID
if (-not $grantKey) { throw "JOBTREAD_GRANT_KEY missing from .env.local" }
if (-not $orgId)    { throw "JOBTREAD_ORG_ID missing from .env.local" }

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

# ---------------------------------------------------------------- field spec
# Load-bearing strings: budget_range options must match HubSpot byte-for-byte
# (warehouse normalizer dependency), including en dashes and commas.
$FieldSpec = @(
    @{ targetType = 'customer';        type = 'text';   name = 'utm_source' }
    @{ targetType = 'customer';        type = 'text';   name = 'utm_medium' }
    @{ targetType = 'customer';        type = 'text';   name = 'utm_campaign' }
    @{ targetType = 'customer';        type = 'text';   name = 'gclid' }
    @{ targetType = 'customer';        type = 'text';   name = 'lead_source_page' }
    @{ targetType = 'customerContact'; type = 'boolean'; name = 'tcpa_consent_given' }
    @{ targetType = 'customerContact'; type = 'option'; name = 'tcpa_consent_source'
       options = @('form','verbal','assumed') }
    @{ targetType = 'customerContact'; type = 'option'; name = 'lead_channel'
       options = @('webform','phone','manual','other') }
    @{ targetType = 'job';             type = 'option'; name = 'project_type'
       options = @('New deck build','Deck replacement','Deck repair','Deck addition / expansion','Not sure yet') }
    @{ targetType = 'job';             type = 'option'; name = 'budget_range'
       options = @('Under $5,000','$5,000 – $10,000','$10,000 – $20,000','$20,000 – $40,000','$40,000+') }
    @{ targetType = 'job';             type = 'option'; name = 'project_timeline'
       options = @('As soon as possible','Within 1–3 months','3–6 months','Just planning ahead') }
    @{ targetType = 'job';             type = 'option'; name = 'owns_property'
       options = @('Yes','No','Not sure') }
    @{ targetType = 'job';             type = 'option'; name = 'source_city'
       options = @('Wausau','Schofield','Weston','Mosinee','Merrill','Other') }
    @{ targetType = 'job';             type = 'number'; name = 'lead_score' }
    @{ targetType = 'job';             type = 'text';   name = 'disqualification_reason' }
)

# 10-stage Phase 2 funnel (design §3.2). Stage 6 name is consumed verbatim by
# the attribution webhook: "Signed / Booked" with spaces around the slash.
$StageOptions = @(
    'New Lead','Qualified','Walk-through Scheduled','Estimating','Estimate Delivered',
    'Signed / Booked','In Production','Complete - Paid','Stale - No Response','Lost'
)

$CostCodes = @('Materials','Labor','Permits','Equipment','Other')

# ------------------------------------------------------------ existing state
$existing = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    organization = @{
        '$' = @{ id = $orgId }
        customFields = @{
            '$' = @{ size = 100 }
            nodes = @{ id = @{}; name = @{}; type = @{}; targetType = @{}; options = @{} }
        }
    }
}
$existingFields = @($existing.organization.customFields.nodes)
Write-Host ("existing custom fields: {0}" -f $existingFields.Count)

function Test-FieldExists {
    param([string] $TargetType, [string] $Name)
    return [bool]($existingFields | Where-Object { $_.targetType -eq $TargetType -and $_.name -eq $Name })
}

# -------------------------------------------------------------- create fields
$created = 0; $skipped = 0
foreach ($f in $FieldSpec) {
    if (Test-FieldExists -TargetType $f.targetType -Name $f.name) {
        Write-Host ("SKIP  {0}.{1} (exists)" -f $f.targetType, $f.name)
        $skipped++
        continue
    }
    if ($DryRun) { Write-Host ("WOULD CREATE {0}.{1}" -f $f.targetType, $f.name); continue }

    $args = @{
        organizationId    = $orgId
        targetType        = $f.targetType
        type              = $f.type
        name              = $f.name
        minValuesRequired = 0
    }
    if ($f.ContainsKey('options')) { $args.options = $f.options }

    $r = Invoke-Pave @{
        '$' = @{ grantKey = $grantKey }
        createCustomField = @{
            '$' = $args
            createdCustomField = @{ id = @{}; name = @{} }
        }
    }
    Write-Host ("CREATE {0}.{1} -> {2}" -f $f.targetType, $f.name, $r.createCustomField.createdCustomField.id)
    $created++
}

# ------------------------------------------- job Status options -> 10 stages
$statusField = $existingFields | Where-Object { $_.targetType -eq 'job' -and $_.name -eq 'Status' }
if (-not $statusField) { throw "job Status field not found; org defaults changed?" }

$currentOptions = @($statusField.options)
$diff = Compare-Object $currentOptions $StageOptions
if (-not $diff) {
    Write-Host "Status options already match the 10-stage funnel"
} elseif ($DryRun) {
    Write-Host "WOULD UPDATE Status options -> $($StageOptions -join ' | ')"
} else {
    $null = Invoke-Pave @{
        '$' = @{ grantKey = $grantKey }
        updateCustomField = @{
            '$' = @{ id = $statusField.id; options = $StageOptions }
        }
    }
    Write-Host "UPDATED job Status options -> 10-stage funnel"
}

# ------------------------------------------------------------------ cost codes
# Cost codes live under organization accounts in Pave probing; try costCodes node.
$ccExisting = $null
try {
    $cc = Invoke-Pave @{
        '$' = @{ grantKey = $grantKey }
        organization = @{
            '$' = @{ id = $orgId }
            costCodes = @{ '$' = @{ size = 50 }; nodes = @{ id = @{}; name = @{} } }
        }
    }
    $ccExisting = @($cc.organization.costCodes.nodes) | ForEach-Object { $_.name }
} catch {
    Write-Host "costCodes node not queryable ($($_.Exception.Message.Split("`n")[0])); create cost codes in the UI (worksheet rows 33-37)"
}
if ($null -ne $ccExisting) {
    foreach ($name in $CostCodes) {
        if ($ccExisting -contains $name) { Write-Host "SKIP  costCode $name (exists)"; continue }
        if ($DryRun) { Write-Host "WOULD CREATE costCode $name"; continue }
        $r = Invoke-Pave @{
            '$' = @{ grantKey = $grantKey }
            createCostCode = @{
                '$' = @{ organizationId = $orgId; name = $name }
                createdCostCode = @{ id = @{} }
            }
        }
        Write-Host ("CREATE costCode {0} -> {1}" -f $name, $r.createCostCode.createdCostCode.id)
    }
}

Write-Host ""
Write-Host ("DONE. created={0} skipped={1}" -f $created, $skipped)
exit 0
