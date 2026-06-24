<#
.SYNOPSIS
    Pull HubSpot contacts, deals, and companies, write JSON snapshot, push to Supabase.

.DESCRIPTION
    1. Calls the HubSpot CRM v3 Search API for contacts, deals, and companies (paginated).
    2. Writes a normalized JSON file at _vault/data/hubspot-latest.json.
    3. UPSERTs each object into Supabase:
       - raw_hubspot_snapshot (bronze layer — full payload as jsonb)
       - dim_contractor (typed projection of contacts with lifecyclestage=customer)

    Typed projections of fact_leads + fact_bids are deferred to a SQL view layer that
    reads from raw_hubspot_snapshot. This keeps the script simple and lets us refine
    the projection logic without re-pulling data.

.NOTES
    Required env vars (read from .env.local at repo root):
      HUBSPOT_PRIVATE_APP_TOKEN  - Private app token with scopes: crm.objects.contacts.read,
                                   crm.objects.deals.read, crm.objects.companies.read,
                                   crm.schemas.contacts.read, crm.schemas.deals.read
      SUPABASE_URL               - https://<project>.supabase.co
      SUPABASE_SERVICE_ROLE_KEY  - service_role JWT (server-side only)

    Private app setup: https://developers.hubspot.com/docs/api/private-apps
      HubSpot -> Settings -> Integrations -> Private Apps -> Create. Copy token immediately.

    Output schema (JSON file):
      { "pulled_at": ISO8601, "source": "hubspot", "data": {...}, "error": null }
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

$DataDir  = Join-Path $RepoRoot "_vault\data"
$OutFile  = Join-Path $DataDir "hubspot-latest.json"
$ErrorLog = Join-Path $DataDir "hubspot-error.log"
$EnvFile  = Join-Path $RepoRoot ".env.local"

if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir -Force | Out-Null
}

function Write-ErrorLog {
    param([string] $Message)
    $stamp = (Get-Date).ToString("o")
    Add-Content -Path $ErrorLog -Value "[$stamp] $Message" -Encoding utf8
}

function Get-PropOrNull {
    <#
    .SYNOPSIS
        Strict-mode-safe property access. Returns $null if the property is absent.
    #>
    param(
        [Parameter(Mandatory)] $InputObject,
        [Parameter(Mandatory)] [string] $Name
    )
    if ($null -eq $InputObject) { return $null }
    if (-not ($InputObject.PSObject.Properties.Name -contains $Name)) { return $null }
    return $InputObject.$Name
}

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

# Custom properties from operations/automation/hubspot-lead-pipeline.json
# Plus the standard HubSpot ones we care about.
$ContactProperties = @(
    "firstname","lastname","email","phone","address","city","state","zip",
    "lifecyclestage","createdate","lastmodifieddate","hs_object_id",
    # CWDB-custom homeowner lead fields
    "project_type","budget_range","project_timeline","lead_notes","owns_property",
    "source_city","utm_source","utm_medium","utm_campaign","utm_term","utm_content",
    "gclid","tcpa_consent_given","lead_source_page","lead_channel","tcpa_consent_source",
    # CWDB-custom contractor fields
    "business_name","service_area_zips","onboarded_at"
)

$DealProperties = @(
    "dealname","dealstage","pipeline","amount","closedate","createdate","hs_object_id",
    "hs_lastmodifieddate","hubspot_owner_id",
    # CWDB-custom homeowner lead pipeline fields
    "lead_score","disqualification_reason","matched_contractor","routing_sent_at",
    "first_response_window_hours","bid_amount","referral_fee_invoiced_at","referral_fee_paid_at"
)

$CompanyProperties = @(
    "name","domain","createdate","hs_object_id","hs_lastmodifieddate","city","state","zip","phone"
)

function Get-HubSpotObjects {
    <#
    .SYNOPSIS
        Page through the HubSpot CRM v3 List API for a given object type.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]   $ObjectType,   # contacts | deals | companies
        [Parameter(Mandatory)] [string]   $Token,
        [Parameter(Mandatory)] [string[]] $Properties,
        [string[]] $Associations = @(),
        [int] $PageSize = 100
    )

    $base = "https://api.hubapi.com/crm/v3/objects/$ObjectType"
    $headers = @{ "Authorization" = "Bearer $Token"; "Content-Type" = "application/json" }
    $propsParam = ($Properties -join ",")

    $all = New-Object System.Collections.Generic.List[object]
    $after = $null
    $page = 0
    do {
        $page++
        $qs  = "limit=$PageSize&properties=$propsParam&archived=false"
        if ($Associations.Count -gt 0) { $qs += "&associations=" + ($Associations -join ",") }
        if ($after) { $qs += "&after=$after" }
        $url = "$base" + "?" + $qs

        $resp = Invoke-RestMethod -Method Get -Uri $url -Headers $headers -ErrorAction Stop

        $hasResults = $resp.PSObject.Properties.Name -contains "results"
        if ($hasResults -and $resp.results) {
            foreach ($r in $resp.results) { $all.Add($r) }
        }

        $after = $null
        $hasPaging = $resp.PSObject.Properties.Name -contains "paging"
        if ($hasPaging -and $resp.paging) {
            $hasNext = $resp.paging.PSObject.Properties.Name -contains "next"
            if ($hasNext -and $resp.paging.next) {
                $hasAfter = $resp.paging.next.PSObject.Properties.Name -contains "after"
                if ($hasAfter) { $after = $resp.paging.next.after }
            }
        }
        Write-Verbose "HubSpot $ObjectType page $page : pulled $($all.Count) so far"
    } while ($after)

    return ,$all.ToArray()
}

try {
    Load-DotEnv -Path $EnvFile
    Load-DotEnvIfNeeded -RepoRoot $RepoRoot

    $token = $env:HUBSPOT_PRIVATE_APP_TOKEN
    if (-not $token) {
        throw "Missing required env var: HUBSPOT_PRIVATE_APP_TOKEN. Create a private app at HubSpot -> Settings -> Integrations -> Private Apps. See operations/data-warehouse/README.md."
    }

    Write-Output "Pulling HubSpot contacts..."
    $contacts = Get-HubSpotObjects -ObjectType "contacts" -Token $token -Properties $ContactProperties
    Write-Output "  -> $($contacts.Count) contacts"

    Write-Output "Pulling HubSpot deals (with contact + company associations)..."
    $deals = Get-HubSpotObjects -ObjectType "deals" -Token $token -Properties $DealProperties -Associations @("contacts","companies")
    Write-Output "  -> $($deals.Count) deals"

    Write-Output "Pulling HubSpot companies..."
    $companies = Get-HubSpotObjects -ObjectType "companies" -Token $token -Properties $CompanyProperties
    Write-Output "  -> $($companies.Count) companies"

    # ===== Write JSON snapshot =====
    $snapshot = [ordered]@{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "hubspot"
        data      = [ordered]@{
            contact_count  = $contacts.Count
            deal_count     = $deals.Count
            company_count  = $companies.Count
            contacts       = $contacts
            deals          = $deals
            companies      = $companies
        }
        error     = $null
    }
    $snapshot | ConvertTo-Json -Depth 32 | Out-File -FilePath $OutFile -Encoding utf8 -Force
    Write-Output "Wrote $OutFile"

    if ($SkipSupabase) {
        Write-Output "SkipSupabase: JSON written but not loaded to DB. Done."
        exit 0
    }

    # ===== Push to Supabase =====
    Initialize-SupabaseClient

    $capturedAt = (Get-Date).ToUniversalTime().ToString("o")

    # Bronze layer: raw_hubspot_snapshot
    $rawRecords = New-Object System.Collections.Generic.List[hashtable]
    foreach ($c in $contacts) {
        $rawRecords.Add(@{
            captured_at = $capturedAt
            object_type = "contact"
            object_id   = "$($c.id)"
            payload     = $c
        })
    }
    foreach ($d in $deals) {
        $rawRecords.Add(@{
            captured_at = $capturedAt
            object_type = "deal"
            object_id   = "$($d.id)"
            payload     = $d
        })
    }
    foreach ($co in $companies) {
        $rawRecords.Add(@{
            captured_at = $capturedAt
            object_type = "company"
            object_id   = "$($co.id)"
            payload     = $co
        })
    }

    if ($DryRun) {
        Write-Output "DryRun: would upsert $($rawRecords.Count) raw_hubspot_snapshot rows."
    } else {
        $n = Invoke-SupabaseUpsert -Table "raw_hubspot_snapshot" -Records $rawRecords.ToArray() -ConflictColumns "captured_at,object_type,object_id"
        Write-Output "Upserted $n rows into raw_hubspot_snapshot"
    }

    # Typed layer: dim_contractor (subset of contacts where lifecyclestage = 'customer')
    $contractorRecords = New-Object System.Collections.Generic.List[hashtable]
    foreach ($c in $contacts) {
        $props = Get-PropOrNull $c "properties"
        if ($null -eq $props) { continue }

        $stage = Get-PropOrNull $props "lifecyclestage"
        if ($stage -ne "customer") { continue }

        $firstname = Get-PropOrNull $props "firstname"
        $lastname  = Get-PropOrNull $props "lastname"
        $bizName   = Get-PropOrNull $props "business_name"
        $email     = Get-PropOrNull $props "email"
        $phone     = Get-PropOrNull $props "phone"
        $zipsRaw   = Get-PropOrNull $props "service_area_zips"
        $onboarded = Get-PropOrNull $props "onboarded_at"

        $contactName = ((@($firstname, $lastname) | Where-Object { $_ }) -join " ").Trim()

        if (-not $bizName -and $contactName) { $bizName = $contactName }
        if (-not $bizName) { $bizName = "Unknown contractor (HubSpot id $($c.id))" }

        $zips = @()
        if ($zipsRaw) {
            $zips = $zipsRaw -split "[,;\s]+" | Where-Object { $_ }
        }

        $contractorRecords.Add(@{
            hubspot_contact_id = "$($c.id)"
            business_name      = $bizName
            contact_name       = $contactName
            email              = $email
            phone              = $phone
            service_area_zips  = $zips
            lifecycle_stage    = "customer"
            onboarded_at       = $onboarded
            is_active          = $true
            updated_at         = $capturedAt
        })
    }

    if ($DryRun) {
        Write-Output "DryRun: would upsert $($contractorRecords.Count) dim_contractor rows."
    } elseif ($contractorRecords.Count -gt 0) {
        $n = Invoke-SupabaseUpsert -Table "dim_contractor" -Records $contractorRecords.ToArray() -ConflictColumns "hubspot_contact_id"
        Write-Output "Upserted $n rows into dim_contractor"
    } else {
        Write-Output "No contacts with lifecyclestage=customer; dim_contractor unchanged"
    }

    # ===========================================================================
    # Typed layer: fact_leads (homeowner-lead contacts with TCPA consent)
    # ---------------------------------------------------------------------------
    # Filter: lifecyclestage != 'customer' (those are contractors) AND tcpa_consent_given truthy.
    # We resolve city_id via dim_city by source_city/city name OR matching zip.
    # Campaign attribution FKs (attributed_campaign_id_via_*) are left NULL here;
    # Phase C populates dim_campaign and a later view can resolve the attribution.
    # ===========================================================================

    Write-Verbose "Fetching dim_city for FK resolution"
    $cities = Invoke-SupabaseSelect -Table "dim_city" -Select "city_id,city_name,zip_codes"
    $cityIdByName = @{}
    $cityIdByZip  = @{}
    foreach ($city in $cities) {
        $cityIdByName[$city.city_name.ToLowerInvariant()] = [int] $city.city_id
        if ($city.zip_codes) {
            foreach ($z in $city.zip_codes) { $cityIdByZip[$z] = [int] $city.city_id }
        }
    }

    function Resolve-CityId {
        param([string] $CityName, [string] $Zip)
        if ($CityName) {
            $k = $CityName.Trim().ToLowerInvariant()
            if ($cityIdByName.ContainsKey($k)) { return $cityIdByName[$k] }
        }
        if ($Zip) {
            $z = $Zip.Trim()
            if ($z.Length -ge 5) { $z = $z.Substring(0, 5) }   # strip ZIP+4 suffix
            if ($cityIdByZip.ContainsKey($z)) { return $cityIdByZip[$z] }
        }
        return $null
    }

    function ConvertTo-BoolOrNull {
        param($Value)
        if ($null -eq $Value) { return $null }
        $s = ([string] $Value).Trim().ToLowerInvariant()
        if ($s -in @("true","yes","y","1","on"))  { return $true }
        if ($s -in @("false","no","n","0","off")) { return $false }
        return $null
    }

    function ConvertTo-IsoOrNull {
        param($Value)
        if (-not $Value) { return $null }
        try { return ([datetime]::Parse($Value)).ToUniversalTime().ToString("o") } catch { return $null }
    }

    function ConvertTo-DateKeyOrNull {
        param($Value)
        if (-not $Value) { return $null }
        try { return ([datetime]::Parse($Value)).ToUniversalTime().ToString("yyyy-MM-dd") } catch { return $null }
    }

    $leadRecords = New-Object System.Collections.Generic.List[hashtable]
    $skipped = [ordered]@{ no_consent = 0; no_phone = 0; no_email = 0; is_customer = 0; no_submitted_at = 0; test_lead = 0 }

    foreach ($c in $contacts) {
        $props = Get-PropOrNull $c "properties"
        if ($null -eq $props) { continue }

        $stage = Get-PropOrNull $props "lifecyclestage"
        if ($stage -eq "customer") { $skipped.is_customer++; continue }

        # Test-lead exclusion: never INGEST a test contact into fact_leads. The
        # v_clean_leads view already filters these from the funnel, but a view filter is
        # NOT enough - an un-skipped test contact can 409 the fact_leads UPSERT (the table
        # has UNIQUE(email) while this loader upserts on hubspot_contact_id, so a second
        # contact sharing an email collides) and fail the entire HubSpot pull, which closes
        # the watchdog gate as stale_warehouse_data. (Incident 2026-06-24: test@test.com.)
        # Predicate mirrors views/003-006 exactly: test emails, the synthetic internal
        # domain, full_name starting "test", and utm_source='test'.
        $emailRaw = Get-PropOrNull $props "email"
        $emailLc  = if ($emailRaw) { ([string]$emailRaw).Trim().ToLowerInvariant() } else { "" }
        $nameLc   = ((@((Get-PropOrNull $props "firstname"), (Get-PropOrNull $props "lastname")) |
                      Where-Object { $_ }) -join " ").Trim().ToLowerInvariant()
        $utmLc    = ([string](Get-PropOrNull $props "utm_source")).Trim().ToLowerInvariant()
        $isTestLead =
            ($emailLc -in @('test@test.com','dcebighitta12@aim.com','slogarjw@gmail.com')) -or
            ($emailLc -like '*@cwdb-internal.test') -or
            ($nameLc.StartsWith('test')) -or
            ($utmLc -eq 'test')
        if ($isTestLead) { $skipped.test_lead++; continue }

        # Consent gate (2026-06-10 pivot: all channels count).
        # A lead passes when the form relay set tcpa_consent_given=true, OR it is
        # a phone/manual entry where Jim recorded a consent source (verbal/assumed).
        $tcpaRaw    = Get-PropOrNull $props "tcpa_consent_given"
        $tcpa       = ConvertTo-BoolOrNull $tcpaRaw
        $channelRaw = Get-PropOrNull $props "lead_channel"
        $consentSrc = Get-PropOrNull $props "tcpa_consent_source"
        $consentOk  = ($tcpa -eq $true) -or
                      ($consentSrc -and $channelRaw -in @("phone", "manual", "other"))
        if (-not $consentOk) { $skipped.no_consent++; continue }

        # Channel: explicit property wins; otherwise a form-set TCPA means webform
        # (the relay was the only path that ever set it before lead_channel existed).
        $leadChannel = if ($channelRaw) { $channelRaw } else { "webform" }
        if (-not $consentSrc) { $consentSrc = "form" }

        $phone = Get-PropOrNull $props "phone"
        $email = Get-PropOrNull $props "email"
        if (-not $phone) { $skipped.no_phone++; continue }
        if (-not $email) {
            # Phone/manual leads may arrive with no email (schema/010 allows
            # NULL); webform leads always have one, so a missing email there
            # is a data problem worth skipping.
            if ($leadChannel -eq "webform") { $skipped.no_email++; continue }
            $email = $null
        }

        $createdate = Get-PropOrNull $props "createdate"
        $submittedAt = ConvertTo-IsoOrNull $createdate
        $dateKey     = ConvertTo-DateKeyOrNull $createdate
        if (-not $submittedAt -or -not $dateKey) { $skipped.no_submitted_at++; continue }

        $firstname  = Get-PropOrNull $props "firstname"
        $lastname   = Get-PropOrNull $props "lastname"
        $fullName   = ((@($firstname, $lastname) | Where-Object { $_ }) -join " ").Trim()
        if (-not $fullName) { $fullName = $null }

        $sourceCity = Get-PropOrNull $props "source_city"
        $stdCity    = Get-PropOrNull $props "city"
        $zipRaw     = Get-PropOrNull $props "zip"
        $cityForFk  = if ($sourceCity) { $sourceCity } else { $stdCity }
        $cityId     = Resolve-CityId -CityName $cityForFk -Zip $zipRaw

        $budget = Get-PropOrNull $props "budget_range"
        if ($budget) {
            # Normalize en-dash variants to ASCII hyphen so CHECK constraint matches
            $budget = $budget -replace '[–—]', '-'
        }

        $leadRecords.Add(@{
            webflow_submission_id              = $null
            hubspot_contact_id                 = "$($c.id)"
            hubspot_deal_id                    = $null
            submitted_at                       = $submittedAt
            date_key                           = $dateKey
            full_name                          = $fullName
            phone                              = $phone
            email                              = $email
            property_address                   = (Get-PropOrNull $props "address")
            city_id                            = $cityId
            owns_property                      = ConvertTo-BoolOrNull (Get-PropOrNull $props "owns_property")
            project_type                       = (Get-PropOrNull $props "project_type")
            budget_range                       = $budget
            project_timeline                   = (Get-PropOrNull $props "project_timeline")
            lead_notes                         = (Get-PropOrNull $props "lead_notes")
            tcpa_consent_given                 = $true
            lead_channel                       = $leadChannel
            tcpa_consent_source                = $consentSrc
            utm_source                         = (Get-PropOrNull $props "utm_source")
            utm_medium                         = (Get-PropOrNull $props "utm_medium")
            utm_campaign                       = (Get-PropOrNull $props "utm_campaign")
            utm_term                           = (Get-PropOrNull $props "utm_term")
            utm_content                        = (Get-PropOrNull $props "utm_content")
            gclid                              = (Get-PropOrNull $props "gclid")
            lead_source_page                   = (Get-PropOrNull $props "lead_source_page")
            attributed_campaign_id_via_utm     = $null
            attributed_campaign_id_via_gclid   = $null
            lead_score                         = 0
            disqualification_reason            = $null
            updated_at                         = $capturedAt
        })
    }

    if ($DryRun) {
        Write-Output "DryRun: would upsert $($leadRecords.Count) fact_leads rows."
        Write-Output "DryRun: skipped $($skipped.is_customer) contractors, $($skipped.test_lead) test leads, $($skipped.no_consent) without consent (no form TCPA and no recorded consent source), $($skipped.no_phone) without phone, $($skipped.no_email) without email, $($skipped.no_submitted_at) without createdate"
    } elseif ($leadRecords.Count -gt 0) {
        $n = Invoke-SupabaseUpsert -Table "fact_leads" -Records $leadRecords.ToArray() -ConflictColumns "hubspot_contact_id"
        Write-Output "Upserted $n rows into fact_leads"
        Write-Output "Skipped: contractors=$($skipped.is_customer), test_leads=$($skipped.test_lead), no_consent=$($skipped.no_consent), no_phone=$($skipped.no_phone), no_email=$($skipped.no_email), no_createdate=$($skipped.no_submitted_at)"
    } else {
        Write-Output "No homeowner leads with TCPA + phone + email; fact_leads unchanged"
        Write-Output "Skipped: contractors=$($skipped.is_customer), test_leads=$($skipped.test_lead), no_consent=$($skipped.no_consent), no_phone=$($skipped.no_phone), no_email=$($skipped.no_email), no_createdate=$($skipped.no_submitted_at)"
    }

    # ===========================================================================
    # Typed layer: fact_bids (homeowner-lead pipeline deals)
    # ---------------------------------------------------------------------------
    # Pipeline 2247158458 is the Homeowner Leads pipeline. We project every deal
    # in this pipeline to fact_bids, mapping the 9 stages to our bid_status enum:
    #
    #   New Lead / Qualified / Scheduled / Creating Bid → 'pending'
    #   Delivered Bid                                    → 'sent'
    #   Accepted Bid                                     → 'accepted'
    #   Won - Contractor Payment Received                → 'paid'
    #   Expired Bid - No Response                        → 'expired'
    #   Lost                                             → 'declined'
    #
    # Contractor resolution: matched_contractor in HubSpot is free-text (e.g.,
    # "John Garcia", "Ben Barton", or "CWDB"/"Jim" for self-handled jobs). We do
    # a case-insensitive substring match against dim_contractor.contact_name.
    # No match → contractor_id NULL (allowed by migration 005).
    #
    # Lead resolution: first associated contact_id → fact_leads.lead_id lookup.
    # Deals with no associated contact in fact_leads are skipped (cannot satisfy
    # the lead_id FK to fact_leads).
    # ===========================================================================

    $HomeownerPipelineId = "2247158458"
    $StageMap = @{
        "3610478270" = @{ Label = "New Lead";                              BidStatus = "pending"  }
        "3610478271" = @{ Label = "Qualified";                             BidStatus = "pending"  }
        "3610478272" = @{ Label = "Scheduled / Delivered to Contractor";   BidStatus = "pending"  }
        "3610415826" = @{ Label = "Creating Bid";                          BidStatus = "pending"  }
        "3610415827" = @{ Label = "Delivered Bid";                         BidStatus = "sent"     }
        "3610478273" = @{ Label = "Accepted Bid";                          BidStatus = "accepted" }
        "3610478275" = @{ Label = "Expired Bid - No Response";             BidStatus = "expired"  }
        "3610478274" = @{ Label = "Won - Contractor Payment Received";     BidStatus = "paid"     }
        "3610478276" = @{ Label = "Lost";                                  BidStatus = "declined" }
    }

    # Lookup: hubspot_contact_id -> lead_id (we just upserted fact_leads, so refetch)
    Write-Verbose "Fetching fact_leads for lead_id resolution"
    $leadRows = Invoke-SupabaseSelect -Table "fact_leads" -Select "lead_id,hubspot_contact_id"
    $leadIdByContactId = @{}
    foreach ($lr in $leadRows) {
        if ($lr.hubspot_contact_id) { $leadIdByContactId[[string] $lr.hubspot_contact_id] = [int64] $lr.lead_id }
    }

    # Lookup: dim_contractor by case-insensitive substring of contact_name
    Write-Verbose "Fetching dim_contractor for contractor_id resolution"
    $contractorRows = Invoke-SupabaseSelect -Table "dim_contractor" -Select "contractor_id,contact_name,business_name"
    function Resolve-ContractorId {
        param([string] $MatchedName)
        if (-not $MatchedName) { return $null }
        $needle = $MatchedName.Trim().ToLowerInvariant()
        if (-not $needle) { return $null }
        foreach ($cr in $contractorRows) {
            $cn = if ($cr.contact_name)  { $cr.contact_name.ToLowerInvariant() }  else { "" }
            $bn = if ($cr.business_name) { $cr.business_name.ToLowerInvariant() } else { "" }
            # Substring either direction (deal text may have last-name only)
            if ($cn -and ($cn -like "*$needle*" -or $needle -like "*$cn*")) { return [int64] $cr.contractor_id }
            if ($bn -and ($bn -like "*$needle*" -or $needle -like "*$bn*")) { return [int64] $cr.contractor_id }
            # Last-token comparison ("john garcia" -> "garcia")
            $lastTok = ($needle -split '\s+')[-1]
            if ($cn -and $lastTok -and $cn.EndsWith($lastTok)) { return [int64] $cr.contractor_id }
        }
        return $null
    }

    $bidRecords = New-Object System.Collections.Generic.List[hashtable]
    $bidSkipped = [ordered]@{ wrong_pipeline = 0; unknown_stage = 0; no_associated_contact = 0; no_matching_lead = 0; no_createdate = 0 }

    foreach ($d in $deals) {
        $props = Get-PropOrNull $d "properties"
        if ($null -eq $props) { continue }

        $pipelineId = Get-PropOrNull $props "pipeline"
        if ($pipelineId -ne $HomeownerPipelineId) { $bidSkipped.wrong_pipeline++; continue }

        $stageId = Get-PropOrNull $props "dealstage"
        if (-not $StageMap.ContainsKey($stageId)) { $bidSkipped.unknown_stage++; continue }
        $stageInfo = $StageMap[$stageId]

        # Find the first associated contact id
        $associatedContactId = $null
        $assocs = Get-PropOrNull $d "associations"
        if ($assocs) {
            $contactsAssoc = Get-PropOrNull $assocs "contacts"
            if ($contactsAssoc) {
                $results = @(Get-PropOrNull $contactsAssoc "results")
                if ($results.Count -gt 0) {
                    $associatedContactId = [string] $results[0].id
                }
            }
        }
        if (-not $associatedContactId) { $bidSkipped.no_associated_contact++; continue }

        if (-not $leadIdByContactId.ContainsKey($associatedContactId)) {
            $bidSkipped.no_matching_lead++; continue
        }
        $leadId = $leadIdByContactId[$associatedContactId]

        $createdate = Get-PropOrNull $props "createdate"
        $closedate  = Get-PropOrNull $props "closedate"
        $createdAt  = ConvertTo-IsoOrNull $createdate
        if (-not $createdAt) { $bidSkipped.no_createdate++; continue }

        $bidSentAt = if ($stageInfo.BidStatus -in @("sent","accepted","paid","declined","expired")) { $createdAt } else { $null }
        $acceptedAt = if ($stageInfo.BidStatus -in @("accepted","paid")) { ConvertTo-IsoOrNull $closedate } else { $null }
        $declinedAt = if ($stageInfo.BidStatus -eq "declined") { ConvertTo-IsoOrNull $closedate } else { $null }

        # bid_amount: prefer custom bid_amount property, fall back to standard amount
        $bidAmountRaw = Get-PropOrNull $props "bid_amount"
        if (-not $bidAmountRaw) { $bidAmountRaw = Get-PropOrNull $props "amount" }
        $bidAmountCents = $null
        if ($bidAmountRaw) {
            try {
                $dollars = [decimal] $bidAmountRaw
                if ($dollars -gt 0) { $bidAmountCents = [int64] ([math]::Round($dollars * 100)) }
            } catch { }
        }

        $matchedContractor = Get-PropOrNull $props "matched_contractor"
        $contractorId = Resolve-ContractorId -MatchedName $matchedContractor

        $refInvoicedAt = ConvertTo-IsoOrNull (Get-PropOrNull $props "referral_fee_invoiced_at")
        $refPaidAt     = ConvertTo-IsoOrNull (Get-PropOrNull $props "referral_fee_paid_at")

        $bidRecords.Add(@{
            hubspot_deal_id            = "$($d.id)"
            lead_id                    = $leadId
            contractor_id              = $contractorId
            bid_amount_cents           = $bidAmountCents
            bid_sent_at                = $bidSentAt
            bid_status                 = $stageInfo.BidStatus
            accepted_at                = $acceptedAt
            declined_at                = $declinedAt
            declined_reason            = $null
            referral_fee_invoiced_at   = $refInvoicedAt
            referral_fee_paid_at       = $refPaidAt
            referral_fee_cents         = 100000   # $1,000 standard
            hubspot_deal_stage_id      = $stageId
            hubspot_deal_stage_label   = $stageInfo.Label
            updated_at                 = $capturedAt
        })
    }

    if ($DryRun) {
        Write-Output "DryRun: would upsert $($bidRecords.Count) fact_bids rows."
        Write-Output "DryRun: bid-skipped wrong_pipeline=$($bidSkipped.wrong_pipeline), unknown_stage=$($bidSkipped.unknown_stage), no_associated_contact=$($bidSkipped.no_associated_contact), no_matching_lead=$($bidSkipped.no_matching_lead), no_createdate=$($bidSkipped.no_createdate)"
    } elseif ($bidRecords.Count -gt 0) {
        $n = Invoke-SupabaseUpsert -Table "fact_bids" -Records $bidRecords.ToArray() -ConflictColumns "hubspot_deal_id"
        Write-Output "Upserted $n rows into fact_bids"
        Write-Output "Bid-skipped: wrong_pipeline=$($bidSkipped.wrong_pipeline), unknown_stage=$($bidSkipped.unknown_stage), no_associated_contact=$($bidSkipped.no_associated_contact), no_matching_lead=$($bidSkipped.no_matching_lead), no_createdate=$($bidSkipped.no_createdate)"
    } else {
        Write-Output "No deals in the homeowner-lead pipeline; fact_bids unchanged"
    }

    Write-Output "hubspot pull OK: contacts=$($contacts.Count) deals=$($deals.Count) companies=$($companies.Count)"
    exit 0
}
catch {
    $msg = "hubspot pull FAILED: $($_.Exception.Message)"
    Write-ErrorLog -Message $msg
    $stub = [ordered]@{
        pulled_at = (Get-Date).ToUniversalTime().ToString("o")
        source    = "hubspot"
        data      = $null
        error     = $_.Exception.Message
    } | ConvertTo-Json -Depth 5
    try { $stub | Out-File -FilePath $OutFile -Encoding utf8 -Force } catch {}
    Write-Error $msg
    exit 1
}
