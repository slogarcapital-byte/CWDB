# JobTread Accelerated-Hybrid Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up JobTread as CWDB's job platform with a Supabase Edge Function intake/attribution backbone, per `operations/analysis/jobtread-setup-design.md`, with HubSpot untouched as a parallel safety net.

**Architecture:** A single Edge Function (`jobtread-gateway`) receives Webflow form POSTs (`/intake`: stamp attribution + consent, dual-write JobTread via Pave + HubSpot Forms API, land bronze `raw_intake_events`) and JobTread stage-change webhooks (`/webhook`: log to `raw_jobtread_events`; on Signed/Booked write `conversions_outbox` + fire GA4 MP). A local PowerShell worker uploads Google offline conversions from the outbox using the laptop's existing Google Ads credentials (design refinement: outbox pattern keeps ad-platform secrets out of the cloud). An additive daily pull mirrors JobTread into bronze.

**Tech Stack:** JobTread Pave API (JSON query language, `grantKey` auth) + AI Connector MCP · Supabase Edge Functions (Deno/TypeScript) + Postgres migrations · PowerShell 7 pull/push scripts · Webflow site script (vanilla JS relay).

## Global Constraints

- No em dashes in any authored content (standing rule).
- HubSpot relay path stays functional until the test lead round-trips (spec §1); dual-write keeps HubSpot fed after cutover.
- `budget_range` dropdown options must be the EXACT HubSpot option strings (warehouse normalizer dependency).
- TCPA consent is data, never inferred; `tcpa_consent_given` + `tcpa_consent_source` are day-one Customer fields.
- No existing warehouse columns or views change; everything is additive (spec §5).
- Test leads use `@cwdb-internal.test` emails so `v_clean_leads` excludes them.
- AI Connector writes are immediate, no undo: draft-then-confirm for anything customer-visible.
- No real customer signs in JobTread until legal-compliance-counsel signs off on the proposal template (spec §4).
- Pave mutation/field names in Tasks 3, 5, 6 are best-known from JobTread docs; Task 3's prototype validates the live schema FIRST and later tasks adjust names to match reality before deploying.
- Supabase project: `iabiwsbmnbxmkjvkgfhg`. Migration numbering: next is `015`.

**Manual-step protocol:** Tasks tagged `[JIM]` need Jim's hands (UI logins, phone test). Execution pauses and pings Jim with exactly what to do, then verifies his work programmatically before proceeding.

---

### Task 1: JobTread org inventory + configuration worksheet `[JIM]`

**Files:**
- Create: `operations/jobtread/org-config-worksheet.csv`
- Create: `operations/jobtread/org-setup-notes.md`

**Interfaces:**
- Produces: a configured JobTread org (custom fields, 10 job stages, 5 cost codes) whose field names Task 3 verifies via Pave and Tasks 5/9 depend on verbatim.

- [ ] **Step 1: Write the configuration worksheet CSV** (per standing rule: CSV for any 10+ value UI paste task). Columns: Step, Section, Action, Value.

```csv
Step,Section,Action,Value
1,Settings > Custom Fields > Customer,Create field (Checkbox),tcpa_consent_given
2,Settings > Custom Fields > Customer,Create field (Dropdown),tcpa_consent_source
3,Settings > Custom Fields > Customer,Add dropdown options,form|verbal|assumed
4,Settings > Custom Fields > Customer,Create field (Dropdown),lead_channel
5,Settings > Custom Fields > Customer,Add dropdown options,webform|phone|manual|other
6,Settings > Custom Fields > Customer,Create field (Text),utm_source
7,Settings > Custom Fields > Customer,Create field (Text),utm_medium
8,Settings > Custom Fields > Customer,Create field (Text),utm_campaign
9,Settings > Custom Fields > Customer,Create field (Text),gclid
10,Settings > Custom Fields > Customer,Create field (Text),lead_source_page
11,Settings > Custom Fields > Job,Create field (Dropdown),project_type
12,Settings > Custom Fields > Job,Add dropdown options,New Deck Build|Deck Repair|Deck Replacement|Staining & Sealing|Other
13,Settings > Custom Fields > Job,Create field (Dropdown),budget_range
14,Settings > Custom Fields > Job,Add dropdown options,Under $5k|$5k-$10k|$10k-$20k|$20k-$40k|Over $40k|Not sure
15,Settings > Custom Fields > Job,Create field (Dropdown),project_timeline
16,Settings > Custom Fields > Job,Add dropdown options,ASAP|1-3 months|3-6 months|6+ months|Just researching
17,Settings > Custom Fields > Job,Create field (Dropdown),owns_property
18,Settings > Custom Fields > Job,Add dropdown options,Yes|No
19,Settings > Custom Fields > Job,Create field (Dropdown),source_city
20,Settings > Custom Fields > Job,Add dropdown options,Wausau|Schofield|Weston|Mosinee|Merrill|Other
21,Settings > Custom Fields > Job,Create field (Number),lead_score
22,Settings > Custom Fields > Job,Create field (Text),disqualification_reason
23,Settings > Job Stages,Create stage 1,New Lead
24,Settings > Job Stages,Create stage 2,Qualified
25,Settings > Job Stages,Create stage 3,Walk-through Scheduled
26,Settings > Job Stages,Create stage 4,Estimating
27,Settings > Job Stages,Create stage 5,Estimate Delivered
28,Settings > Job Stages,Create stage 6,Signed / Booked
29,Settings > Job Stages,Create stage 7,In Production
30,Settings > Job Stages,Create stage 8,Complete - Paid
31,Settings > Job Stages,Create stage 9,Stale - No Response
32,Settings > Job Stages,Create stage 10,Lost
33,Settings > Cost Codes,Create,Materials
34,Settings > Cost Codes,Create,Labor
35,Settings > Cost Codes,Create,Permits
36,Settings > Cost Codes,Create,Equipment
37,Settings > Cost Codes,Create,Other
```

**IMPORTANT for the implementer:** before finalizing the CSV, read `operations/automation/hubspot-lead-pipeline.json` and copy the EXACT `project_type`, `budget_range`, `project_timeline`, `owns_property`, `source_city` option strings from it into rows 12, 14, 16, 18, 20 (the values above are placeholders to be replaced with the verbatim HubSpot strings; `budget_range` strings are load-bearing for the warehouse normalizer).

- [ ] **Step 2: Write `org-setup-notes.md`** capturing: org name, anything Jim already configured during his poking-around (inventory: ask Jim to list or screenshot), the note that phone-only Customers (no email) must be verified to save, and that resale-model fields are deliberately NOT created.

- [ ] **Step 3: PING JIM** with the worksheet: work through the CSV top-to-bottom in the JobTread UI; while in Settings, also verify a Customer can be created with phone but NO email (create + delete a scratch record); report anything JobTread's UI would not allow verbatim (especially dropdown option strings).

- [ ] **Step 4: Record deviations** Jim reports into `org-setup-notes.md`. Do not proceed to Task 3 verification until Jim confirms the worksheet is done.

- [ ] **Step 5: Commit**

```bash
git add operations/jobtread/
git commit -m "JobTread org config worksheet + setup notes (Task 1)"
```

---

### Task 2: Pave grant + AI Connector MCP `[JIM]`

**Files:**
- Modify: `.env.local` (not committed; gitignored)
- Create: `.env.example` (repo root) if absent, else modify

**Interfaces:**
- Produces: `JOBTREAD_GRANT_KEY` + `JOBTREAD_ORG_ID` in `.env.local`; AI Connector reachable from Claude Code. Tasks 3, 5, 6, 9 consume the grant key.

- [ ] **Step 1: PING JIM** with these exact instructions:
  1. In JobTread: app.jobtread.com/grants, create a grant named `cwdb-warehouse`, copy the grant key.
  2. Add to `.env.local` at repo root: `JOBTREAD_GRANT_KEY=<key>`.
  3. In Claude Code, add the AI Connector as an HTTP MCP server: `claude mcp add --transport http jobtread https://api.jobtread.com/mcp` and complete the OAuth prompt.
  4. Optionally add the same connector on claude.ai (Settings > Connectors > custom connector, same URL).

- [ ] **Step 2: Add placeholders to `.env.example`**

```
# JobTread Pave API (created at app.jobtread.com/grants)
JOBTREAD_GRANT_KEY=
JOBTREAD_ORG_ID=
```

- [ ] **Step 3: Verify** the grant key exists locally (do NOT echo the value):

Run: `pwsh -c "if ((Get-Content .env.local) -match '^JOBTREAD_GRANT_KEY=.+') { 'grant key present' } else { 'MISSING' }"`
Expected: `grant key present`

- [ ] **Step 4: Commit** (only `.env.example`)

```bash
git add .env.example
git commit -m "Add JobTread grant-key env placeholders (Task 2)"
```

---

### Task 3: Pave prototype query + live schema validation

**Files:**
- Create: `templates/scripts/test-pave-query.ps1`

**Interfaces:**
- Consumes: `JOBTREAD_GRANT_KEY` from Task 2; org config from Task 1.
- Produces: `JOBTREAD_ORG_ID` written to `.env.local`; a validated record (in `operations/jobtread/org-setup-notes.md`) of the ACTUAL Pave node/field names for customers, jobs, stages, custom fields, and webhook + create mutations. Tasks 5, 6, 9 must be adjusted to these names before running.

- [ ] **Step 1: Write the prototype script**

```powershell
<#
.SYNOPSIS
    Prototype Pave API query: verify grant works, discover org id,
    and confirm Task 1 custom fields + stages are queryable.
.NOTES
    Pave endpoint: POST https://api.jobtread.com/pave
    Body: a single JSON "query" object; grantKey rides inside $ args.
    Docs: https://www.jobtread.com/integrations/open-api
#>
[CmdletBinding()]
param([string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\load-supabase.ps1"   # provides Load-DotEnv used repo-wide
Load-DotEnv (Join-Path $RepoRoot ".env.local")

$grantKey = $env:JOBTREAD_GRANT_KEY
if (-not $grantKey) { throw "JOBTREAD_GRANT_KEY missing from .env.local" }

function Invoke-Pave {
    param([hashtable] $Query)
    $body = @{ query = $Query } | ConvertTo-Json -Depth 20
    Invoke-RestMethod -Uri "https://api.jobtread.com/pave" -Method Post `
        -ContentType "application/json" -Body $body
}

# 1. Whoami: discover the organization behind this grant
$who = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    currentGrant = @{
        id = @{}
        organization = @{ id = @{}; name = @{} }
    }
}
$orgId = $who.currentGrant.organization.id
Write-Host ("org: {0} ({1})" -f $who.currentGrant.organization.name, $orgId)

# 2. Customers page (with custom field values)
$customers = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    organization = @{
        '$' = @{ id = $orgId }
        customers = @{
            '$' = @{ size = 5 }
            nodes = @{
                id = @{}; name = @{}
                customFieldValues = @{ nodes = @{ value = @{}; customField = @{ name = @{} } } }
            }
        }
    }
}
$customers | ConvertTo-Json -Depth 20 | Write-Host

# 3. Jobs page with stage
$jobs = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    organization = @{
        '$' = @{ id = $orgId }
        jobs = @{
            '$' = @{ size = 5 }
            nodes = @{ id = @{}; name = @{}; stage = @{ id = @{}; name = @{} } }
        }
    }
}
$jobs | ConvertTo-Json -Depth 20 | Write-Host

# 4. Persist org id for later scripts
$envFile = Join-Path $RepoRoot ".env.local"
if (-not ((Get-Content $envFile -Raw) -match 'JOBTREAD_ORG_ID=')) {
    Add-Content $envFile "JOBTREAD_ORG_ID=$orgId"
    Write-Host "JOBTREAD_ORG_ID appended to .env.local"
}
Write-Host "PAVE PROTOTYPE OK"
```

- [ ] **Step 2: Run it**

Run: `pwsh templates/scripts/test-pave-query.ps1`
Expected: org name + id printed, customers/jobs JSON (may be near-empty), `PAVE PROTOTYPE OK`.

- [ ] **Step 3: Schema-validate and correct.** Pave error responses name valid fields. If any node/arg name in Step 1's query differs from the live schema (e.g. `customers` vs `accounts`, `stage` vs `jobStage`, custom field value shapes), fix the script until it runs green, then record every corrected name in `operations/jobtread/org-setup-notes.md` under a `## Pave schema facts` heading. Also query for the mutation names needed later (`createCustomer` / `createJob` / `createWebhook` or live equivalents) by attempting a no-op introspection and record their true names + required args. Tasks 5 and 6 MUST be updated to these names.

- [ ] **Step 4: Confirm Task 1 fields visible.** Ask the AI Connector (MCP) or extend the query to list custom-field definitions; verify all Task 1 fields and the 10 stages exist with exact names. Any mismatch: PING JIM to fix in the UI.

- [ ] **Step 5: Commit**

```bash
git add templates/scripts/test-pave-query.ps1 operations/jobtread/org-setup-notes.md
git commit -m "Pave prototype query + live schema facts (Task 3)"
```

---

### Task 4: Warehouse migration 015 (additive bronze + link columns)

**Files:**
- Create: `operations/data-warehouse/schema/015_jobtread_hybrid.sql`

**Interfaces:**
- Produces: tables `raw_jobtread_snapshot`, `raw_intake_events`, `raw_jobtread_events`, `conversions_outbox`; nullable `jobtread_customer_id`/`jobtread_job_id` + `crm_source` on `fact_leads`/`fact_bids`. Tasks 5, 9, 10 write to these.

- [ ] **Step 1: Write the migration**

```sql
-- 015_jobtread_hybrid.sql
-- Additive JobTread hybrid layer per operations/analysis/jobtread-setup-design.md §5.
-- No existing columns or views change.

create table if not exists raw_jobtread_snapshot (
    id          bigint generated always as identity primary key,
    pulled_at   timestamptz not null default now(),
    object_type text not null check (object_type in ('customer','contact','job')),
    object_id   text not null,
    payload     jsonb not null,
    unique (object_type, object_id)
);

create table if not exists raw_intake_events (
    id                   bigint generated always as identity primary key,
    received_at          timestamptz not null default now(),
    source               text not null default 'webform',
    payload              jsonb not null,
    jobtread_customer_id text,
    jobtread_job_id      text,
    hubspot_status       int,
    jobtread_status      int,
    error                text
);

create table if not exists raw_jobtread_events (
    id           bigint generated always as identity primary key,
    received_at  timestamptz not null default now(),
    event_id     text,
    event_type   text,
    payload      jsonb not null,
    processed_at timestamptz
);
create unique index if not exists raw_jobtread_events_event_id_uq
    on raw_jobtread_events (event_id) where event_id is not null;

create table if not exists conversions_outbox (
    id                     bigint generated always as identity primary key,
    created_at             timestamptz not null default now(),
    platform               text not null default 'google_ads',
    gclid                  text,
    conversion_time        timestamptz not null default now(),
    conversion_value_cents bigint,
    currency               text not null default 'USD',
    jobtread_job_id        text,
    status                 text not null default 'pending'
                           check (status in ('pending','uploaded','failed','skipped')),
    uploaded_at            timestamptz,
    error                  text
);

alter table fact_leads add column if not exists jobtread_customer_id text;
alter table fact_leads add column if not exists jobtread_job_id      text;
alter table fact_leads add column if not exists crm_source           text not null default 'hubspot';
alter table fact_bids  add column if not exists jobtread_job_id      text;
alter table fact_bids  add column if not exists crm_source           text not null default 'hubspot';

-- RLS: deny-all like the rest of the warehouse (002); service role bypasses.
alter table raw_jobtread_snapshot enable row level security;
alter table raw_intake_events     enable row level security;
alter table raw_jobtread_events   enable row level security;
alter table conversions_outbox    enable row level security;
```

- [ ] **Step 2: Apply via Supabase MCP** `apply_migration` (project `iabiwsbmnbxmkjvkgfhg`, name `jobtread_hybrid`) with the file content.

- [ ] **Step 3: Verify**

Run (Supabase MCP `execute_sql`): `select table_name from information_schema.tables where table_name in ('raw_jobtread_snapshot','raw_intake_events','raw_jobtread_events','conversions_outbox');`
Expected: 4 rows. Then: `select crm_source from fact_leads limit 1;` returns `hubspot`.

- [ ] **Step 4: Commit**

```bash
git add operations/data-warehouse/schema/015_jobtread_hybrid.sql
git commit -m "Migration 015: JobTread hybrid bronze tables + link columns (Task 4)"
```

---

### Task 5: Edge Function `jobtread-gateway` (/intake dual-write + /webhook log-only)

**Files:**
- Create: `operations/data-warehouse/functions/jobtread-gateway/index.ts`

**Interfaces:**
- Consumes: Pave mutation names validated in Task 3 (ADJUST the `createCustomer`/`createJob` blocks to the recorded live names); `JOBTREAD_GRANT_KEY` + `JOBTREAD_ORG_ID` as function secrets; Task 4 tables.
- Produces: HTTPS endpoints `POST .../functions/v1/jobtread-gateway/intake` (consumed by Task 8 relay) and `POST .../functions/v1/jobtread-gateway/webhook` (consumed by Task 6 registration, extended by Task 10).

- [ ] **Step 1: Write the function**

```typescript
// jobtread-gateway: CWDB intake + JobTread webhook receiver.
// /intake : Webflow relay POST -> stamp attribution -> bronze row ->
//           dual-write JobTread (Pave) + HubSpot Forms API (safety net).
// /webhook: JobTread event -> log to raw_jobtread_events (fan-out added in Task 10).
import { createClient } from "npm:@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);
const GRANT_KEY = Deno.env.get("JOBTREAD_GRANT_KEY")!;
const ORG_ID = Deno.env.get("JOBTREAD_ORG_ID")!;
const HS_ENDPOINT =
  "https://api.hsforms.com/submissions/v3/integration/submit/245712220/bb473d64-06b1-4311-8e02-7c70d605b79b";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
};

async function pave(query: unknown): Promise<any> {
  const res = await fetch("https://api.jobtread.com/pave", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query }),
  });
  const body = await res.json();
  if (!res.ok) throw new Error(`pave ${res.status}: ${JSON.stringify(body)}`);
  return body;
}

// ---- /intake -------------------------------------------------------------
async function handleIntake(req: Request): Promise<Response> {
  const p = await req.json(); // flat payload from the relay (see Task 8 FIELD_MAP)
  const bronze = {
    source: "webform",
    payload: p,
    hubspot_status: null as number | null,
    jobtread_status: null as number | null,
    jobtread_customer_id: null as string | null,
    jobtread_job_id: null as string | null,
    error: null as string | null,
  };

  // 1. JobTread write (failure must not block HubSpot write, and vice versa)
  try {
    // NOTE: mutation names/args below follow JobTread docs conventions.
    // Adjust to the live names recorded in org-setup-notes.md (Task 3 step 3).
    const created = await pave({
      $: { grantKey: GRANT_KEY },
      createCustomer: {
        $: {
          organizationId: ORG_ID,
          name: p.name ?? "Unknown",
          // phone-only leads are valid; email may be absent
          ...(p.email ? { email: p.email } : {}),
          ...(p.phone ? { phone: p.phone } : {}),
          customFieldValues: {
            tcpa_consent_given: p.tcpa_consent === "true",
            tcpa_consent_source: "form",
            lead_channel: "webform",
            utm_source: p.utm_source ?? "",
            utm_medium: p.utm_medium ?? "",
            utm_campaign: p.utm_campaign ?? "",
            gclid: p.gclid ?? "",
            lead_source_page: p.page_uri ?? "",
          },
        },
        createdCustomer: { id: {} },
      },
    });
    const customerId = created.createCustomer.createdCustomer.id;
    bronze.jobtread_customer_id = customerId;

    const job = await pave({
      $: { grantKey: GRANT_KEY },
      createJob: {
        $: {
          organizationId: ORG_ID,
          customerId,
          name: `${p.name ?? "Lead"} - ${p.project_type ?? "Deck project"}`,
          customFieldValues: {
            project_type: p.project_type ?? "",
            budget_range: p.budget ?? "",
            project_timeline: p.timeline ?? "",
            owns_property: p.owns_property ?? "",
            source_city: p.city ?? "",
          },
        },
        createdJob: { id: {} },
      },
    });
    bronze.jobtread_job_id = job.createJob.createdJob.id;
    bronze.jobtread_status = 200;
  } catch (e) {
    bronze.jobtread_status = 500;
    bronze.error = `jobtread: ${String(e).slice(0, 300)}`;
  }

  // 2. HubSpot safety-net write (same payload shape the old relay sent)
  try {
    const fields = Object.entries({
      firstname: p.name, email: p.email, phone: p.phone, address: p.address,
      zip: p.zip, project_type: p.project_type, budget_range: p.budget,
      project_timeline: p.timeline, lead_notes: p.notes,
      tcpa_consent_given: p.tcpa_consent, owns_property: p.owns_property,
      lead_source_page: p.page_uri, utm_source: p.utm_source,
      utm_campaign: p.utm_campaign, gclid: p.gclid,
    }).filter(([, v]) => v != null && v !== "")
      .map(([name, value]) => ({ name, value: String(value) }));
    const hs = await fetch(HS_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        fields,
        context: { pageUri: p.page_uri ?? "", pageName: p.page_name ?? "Get a Quote" },
      }),
    });
    bronze.hubspot_status = hs.status;
  } catch (e) {
    bronze.hubspot_status = 500;
    bronze.error = `${bronze.error ?? ""} hubspot: ${String(e).slice(0, 300)}`;
  }

  // 3. Bronze row ALWAYS lands (even if both writes failed)
  const { error } = await supabase.from("raw_intake_events").insert(bronze);
  if (error) console.error("bronze insert failed", error);

  return new Response(JSON.stringify({
    ok: bronze.jobtread_status === 200 || bronze.hubspot_status === 200,
  }), { status: 200, headers: { ...CORS, "Content-Type": "application/json" } });
}

// ---- /webhook (log-only until Task 10) ------------------------------------
async function handleWebhook(req: Request): Promise<Response> {
  const payload = await req.json();
  const { error } = await supabase.from("raw_jobtread_events").insert({
    event_id: payload?.id ?? payload?.eventId ?? null,
    event_type: payload?.type ?? payload?.event ?? null,
    payload,
  });
  if (error && !String(error.message).includes("duplicate")) {
    console.error("event insert failed", error);
  }
  return new Response("ok", { status: 200 });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  const path = new URL(req.url).pathname;
  try {
    if (path.endsWith("/intake") && req.method === "POST") return await handleIntake(req);
    if (path.endsWith("/webhook") && req.method === "POST") return await handleWebhook(req);
    return new Response("not found", { status: 404, headers: CORS });
  } catch (e) {
    console.error("gateway error", e);
    return new Response("error", { status: 500, headers: CORS });
  }
});
```

- [ ] **Step 2: Adjust Pave blocks** to the live mutation names from `org-setup-notes.md` (Task 3 step 3). This is mandatory, not optional.

- [ ] **Step 3: Deploy** via Supabase MCP `deploy_edge_function` (name `jobtread-gateway`). Then set secrets. If no MCP secrets surface exists, PING JIM: Supabase dashboard > Edge Functions > jobtread-gateway > Secrets, add `JOBTREAD_GRANT_KEY` and `JOBTREAD_ORG_ID` (values from `.env.local`). Note: the function must be callable with the anon key in the `Authorization: Bearer` header (default `verify_jwt` behavior); the relay sends it.

- [ ] **Step 4: Smoke-test /intake with a test lead**

```powershell
# Uses SUPABASE_URL + SUPABASE_ANON_KEY from .env.local (anon key is public by design)
$body = @{ name="Gateway Test"; email="gateway-test@cwdb-internal.test"; phone="7155550100";
           project_type="Staining & Sealing"; budget="Under $5k"; timeline="ASAP";
           tcpa_consent="true"; owns_property="Yes"; city="Wausau";
           utm_source="test"; page_uri="https://cwdeckbuilders.com/get-a-quote" } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri "$env:SUPABASE_URL/functions/v1/jobtread-gateway/intake" `
  -Headers @{ Authorization = "Bearer $env:SUPABASE_ANON_KEY"; apikey = $env:SUPABASE_ANON_KEY } `
  -ContentType "application/json" -Body $body
```

Expected: `{"ok":true}`. Then verify all three landings: `raw_intake_events` row has `jobtread_status=200` AND `hubspot_status` in 200-299 AND non-null `jobtread_customer_id` (Supabase MCP `execute_sql`); the Customer + Job visible in JobTread (AI Connector read); the contact in HubSpot (MCP search, then note it is test noise).

- [ ] **Step 5: Commit**

```bash
git add operations/data-warehouse/functions/jobtread-gateway/index.ts
git commit -m "jobtread-gateway Edge Function: intake dual-write + webhook log-only (Task 5)"
```

---

### Task 6: Register the JobTread webhook (log-only)

**Files:**
- Create: `templates/scripts/register-jobtread-webhook.ps1`

**Interfaces:**
- Consumes: live `createWebhook` mutation name/args from Task 3; deployed `/webhook` URL from Task 5.
- Produces: an active JobTread webhook subscription; stage-change payloads accumulating in `raw_jobtread_events` (consumed by Task 10).

- [ ] **Step 1: Write the registration script**

```powershell
<# Register (idempotently) the CWDB job-stage webhook pointing at jobtread-gateway. #>
[CmdletBinding()]
param([string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path)
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\load-supabase.ps1"
Load-DotEnv (Join-Path $RepoRoot ".env.local")

$grantKey = $env:JOBTREAD_GRANT_KEY; $orgId = $env:JOBTREAD_ORG_ID
$hookUrl  = "$env:SUPABASE_URL/functions/v1/jobtread-gateway/webhook"

function Invoke-Pave { param([hashtable] $Query)
    Invoke-RestMethod -Uri "https://api.jobtread.com/pave" -Method Post `
        -ContentType "application/json" -Body (@{ query = $Query } | ConvertTo-Json -Depth 20) }

# ADJUST node/mutation names to org-setup-notes.md "Pave schema facts" (Task 3).
$existing = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    organization = @{ '$' = @{ id = $orgId }
        webhooks = @{ nodes = @{ id = @{}; url = @{} } } }
}
$hooks = @($existing.organization.webhooks.nodes)   # PS7 non-enumeration guard
if ($hooks | Where-Object { $_.url -eq $hookUrl }) {
    Write-Host "webhook already registered"; exit 0
}
$created = Invoke-Pave @{
    '$' = @{ grantKey = $grantKey }
    createWebhook = @{
        '$' = @{ organizationId = $orgId; url = $hookUrl }
        createdWebhook = @{ id = @{} }
    }
}
Write-Host ("webhook registered: {0} -> {1}" -f $created.createWebhook.createdWebhook.id, $hookUrl)
```

- [ ] **Step 2: Run it.** Expected: `webhook registered: <id> -> <url>` (or `already registered` on re-run; idempotency is the test).

- [ ] **Step 3: Fire a real event:** move the Task 5 test Job to stage `Qualified` via the AI Connector (draft-then-confirm), then verify a row in `raw_jobtread_events` whose payload mentions the job id.

- [ ] **Step 4: Commit**

```bash
git add templates/scripts/register-jobtread-webhook.ps1
git commit -m "Idempotent JobTread webhook registration (Task 6)"
```

---

### Task 7: Relay v2 + Webflow flip `[JIM]`

**Files:**
- Create: `website/scripts/cwdb_intake_relay-2.0.0.js`
- Create: `website/scripts/cwdb_intake_relay-2.0.0.min.js`

**Interfaces:**
- Consumes: `/intake` endpoint from Task 5.
- Produces: production form traffic flowing through the gateway (dual-write); the old HubSpot-direct relay retired from Webflow (file kept in repo for rollback).

- [ ] **Step 1: Write relay v2** (structure mirrors `hubspot_form_relay-1.0.0.js`; same form selector, same capture-phase fire-and-forget pattern; sends ONE flat JSON payload):

```javascript
/**
 * cwdb_intake_relay v2.0.0
 * Relays /get-a-quote submissions to the CWDB jobtread-gateway Edge Function,
 * which dual-writes JobTread (Pave) + HubSpot (safety net) server-side.
 * Replaces hubspot_form_relay-1.0.0.js (kept in repo for rollback).
 * Fire-and-forget: never blocks Webflow's native email + redirect flow.
 * Apply via Webflow Site Scripts, page-scoped to /get-a-quote.
 */
(function () {
  'use strict';
  if (window.__cwdbIntakeRelayLoaded) return;
  window.__cwdbIntakeRelayLoaded = true;

  var ENDPOINT = 'https://iabiwsbmnbxmkjvkgfhg.supabase.co/functions/v1/jobtread-gateway/intake';
  var ANON_KEY = '%%SUPABASE_ANON_KEY%%'; // publishable key; substituted before minifying
  var FORM_SELECTOR = 'form#wf-form-Quote-Request';
  var LOG = '[cwdb_intake_relay]';

  // Webflow form name attr -> gateway payload key (server maps onward)
  var FIELD_MAP = {
    'name': 'name', 'email': 'email', 'phone': 'phone', 'address': 'address',
    'zip': 'zip', 'project_type': 'project_type', 'project-type': 'project_type',
    'budget': 'budget', 'timeline': 'timeline', 'notes': 'notes',
    'tcpa_consent': 'tcpa_consent', 'owns_property': 'owns_property',
    'ownership': 'owns_property', 'page_source': 'page_uri', 'city': 'city'
  };

  function getUrlParam(n) {
    try { return new URLSearchParams(window.location.search).get(n) || ''; }
    catch (e) { return ''; }
  }

  function buildPayload(form) {
    var data = new FormData(form); var out = {};
    data.forEach(function (v, k) {
      if (v === '' || v == null) return;
      var key = FIELD_MAP[k];
      if (!key || out[key]) return;
      out[key] = (k === 'tcpa_consent') ? 'true' : String(v);
    });
    ['utm_source', 'utm_medium', 'utm_campaign', 'gclid'].forEach(function (k) {
      if (!out[k]) { var v = getUrlParam(k); if (v) out[k] = v; }
    });
    out.page_uri = out.page_uri || window.location.href;
    out.page_name = document.title || 'Get a Quote';
    return out;
  }

  function relay(form) {
    var payload;
    try { payload = buildPayload(form); }
    catch (err) { console.warn(LOG, 'payload build failed (non-blocking):', err); return; }
    console.log(LOG, 'relaying to gateway');
    fetch(ENDPOINT, {
      method: 'POST', mode: 'cors', keepalive: true,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + ANON_KEY, 'apikey': ANON_KEY
      },
      body: JSON.stringify(payload)
    }).then(function (res) {
      console.log(LOG, res.ok ? 'gateway accepted (HTTP ' + res.status + ')'
                              : 'gateway rejected (HTTP ' + res.status + ')');
    }).catch(function (err) { console.warn(LOG, 'relay failed (non-blocking):', err); });
  }

  function attach() {
    var form = document.querySelector(FORM_SELECTOR);
    if (!form) { console.warn(LOG, 'form not found:', FORM_SELECTOR); return; }
    if (form.__cwdbRelayAttached) return;
    form.__cwdbRelayAttached = true;
    form.addEventListener('submit', function () { relay(form); }, true);
    console.log(LOG, 'attached to', FORM_SELECTOR);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', attach);
  } else { attach(); }
})();
```

- [ ] **Step 2: Substitute the real anon key** (from Supabase MCP `get_publishable_keys`; it is a publishable key, safe in browser JS) and produce the `.min.js` (simple whitespace/comment strip is fine, matching how v1's min file was made).

- [ ] **Step 3: Apply to Webflow:** replace the page-scoped `/get-a-quote` script (old relay) with relay v2 via the Webflow MCP scripts tool (web-dev agent owns Webflow quirks) or, if the MCP path fights back, PING JIM with the exact Designer steps (Site Settings > Custom Code path used for v1). Publish.

- [ ] **Step 4: Verify with a REAL submission + PING JIM (standing rule: real-device acceptance):** Jim submits the form once from his iPhone Safari using a `@cwdb-internal.test` email. Verify the row lands in `raw_intake_events` with both statuses 200-range, the Customer/Job in JobTread, the contact in HubSpot.

- [ ] **Step 5: Commit**

```bash
git add website/scripts/cwdb_intake_relay-2.0.0.js website/scripts/cwdb_intake_relay-2.0.0.min.js
git commit -m "Relay v2: form intake via jobtread-gateway dual-write (Task 7)"
```

---

### Task 8: Daily JobTread pull (source #5) + dashboard label

**Files:**
- Create: `templates/scripts/pull-jobtread-snapshot.ps1`
- Modify: `operations/data-warehouse/scripts/run-daily.ps1:51-56` (sources array)
- Modify: `operations/dashboard/lib/health.py:53` (freshness checks tuple list)
- Modify: `operations/dashboard/tabs/diagnostics.py:16` (label map)

**Interfaces:**
- Consumes: Pave node names from Task 3; Task 4 `raw_jobtread_snapshot`.
- Produces: daily bronze mirror of JobTread customers/contacts/jobs; `jobtread` platform health rows.

- [ ] **Step 1: Write the pull script.** Bronze-only, mirroring `pull-hubspot-snapshot.ps1` conventions (`Load-DotEnv`, `-DryRun`/`-SkipSupabase` switches, error log at `_vault/data/jobtread-error.log`, JSON snapshot at `_vault/data/jobtread-latest.json`, Supabase UPSERT on `object_type,object_id`). Core shape (ADJUST Pave names per Task 3; page with `size`/`page` args per live schema):

```powershell
<#
.SYNOPSIS
    Pull JobTread customers, contacts, jobs (with custom fields + stage) via Pave,
    write JSON snapshot, UPSERT bronze rows into raw_jobtread_snapshot.
.NOTES
    Required env vars (.env.local): JOBTREAD_GRANT_KEY, JOBTREAD_ORG_ID,
    SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY.
    Typed projections into fact_leads/fact_bids stay deferred (hybrid: HubSpot
    pull remains the fact_leads source; see design §5 reconciliation rule).
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
Load-DotEnv (Join-Path $RepoRoot ".env.local")

$DataDir = Join-Path $RepoRoot "_vault\data"
$OutFile = Join-Path $DataDir "jobtread-latest.json"
$grantKey = $env:JOBTREAD_GRANT_KEY; $orgId = $env:JOBTREAD_ORG_ID
if (-not $grantKey -or -not $orgId) { throw "JOBTREAD_GRANT_KEY / JOBTREAD_ORG_ID missing" }

function Invoke-Pave { param([hashtable] $Query)
    Invoke-RestMethod -Uri "https://api.jobtread.com/pave" -Method Post `
        -ContentType "application/json" -Body (@{ query = $Query } | ConvertTo-Json -Depth 24) }

function Get-PavePage {
    param([string] $Node, [hashtable] $Shape, [int] $Size = 100)
    $all = @(); $page = $null
    while ($true) {
        $args = @{ size = $Size }; if ($page) { $args.page = $page }
        $q = @{ '$' = @{ grantKey = $grantKey }
                organization = @{ '$' = @{ id = $orgId }
                    $Node = @{ '$' = $args
                        nextPage = @{}
                        nodes = $Shape } } }
        $res  = Invoke-Pave $q
        $conn = $res.organization.$Node
        $all += @($conn.nodes)                       # PS7 non-enumeration guard
        if (-not $conn.nextPage) { break }
        $page = $conn.nextPage
    }
    return $all
}

$cfShape  = @{ nodes = @{ value = @{}; customField = @{ name = @{} } } }
$customers = Get-PavePage -Node 'customers' -Shape @{
    id = @{}; name = @{}; createdAt = @{}
    customFieldValues = $cfShape }
$jobs = Get-PavePage -Node 'jobs' -Shape @{
    id = @{}; name = @{}; createdAt = @{}
    stage = @{ id = @{}; name = @{} }
    customer = @{ id = @{} }
    customFieldValues = $cfShape }

$snapshot = @{ pulled_at = (Get-Date).ToUniversalTime().ToString("o")
               source = "jobtread"
               data = @{ customers = $customers; jobs = $jobs }; error = $null }
$snapshot | ConvertTo-Json -Depth 24 | Set-Content -Path $OutFile -Encoding utf8
Write-Host ("snapshot: {0} customers, {1} jobs" -f @($customers).Count, @($jobs).Count)

if ($DryRun -or $SkipSupabase) { Write-Host "dry-run/skip: no Supabase write"; exit 0 }

$rows = @()
foreach ($c in $customers) { $rows += @{ object_type = 'customer'; object_id = "$($c.id)"; payload = $c } }
foreach ($j in $jobs)      { $rows += @{ object_type = 'job';      object_id = "$($j.id)"; payload = $j } }
if ($rows.Count) {
    Invoke-SupabaseUpsert -Table 'raw_jobtread_snapshot' -Rows $rows -OnConflict 'object_type,object_id'
}
Write-Host "raw_jobtread_snapshot upserted: $($rows.Count) rows"
exit 0
```

(If `load-supabase.ps1` exposes a different upsert helper name, use that; check the top of `pull-hubspot-snapshot.ps1` for the exact call it makes and mirror it.)

- [ ] **Step 2: Run once manually.** `pwsh templates/scripts/pull-jobtread-snapshot.ps1` then verify row counts: `select object_type, count(*) from raw_jobtread_snapshot group by 1;` matches the printed counts.

- [ ] **Step 3: Register as source #5** in `run-daily.ps1` after the `ga4` line:

```powershell
    @{ Name = 'jobtread';   Path = Join-Path $RepoRoot 'templates\scripts\pull-jobtread-snapshot.ps1' }
```

- [ ] **Step 4: Dashboard labels.** In `lib/health.py`, add to the freshness `checks` list: `("jobtread", "raw_jobtread_snapshot", "pulled_at"),`. In `tabs/diagnostics.py` line 16 label map, add `"jobtread": "JobTread",`.

- [ ] **Step 5: Verify end-to-end:** run `pwsh operations/data-warehouse/scripts/run-daily.ps1` and confirm the summary table shows `jobtread exit=0`; open the dashboard diagnostics tab and see the JobTread freshness row.

- [ ] **Step 6: Commit**

```bash
git add templates/scripts/pull-jobtread-snapshot.ps1 operations/data-warehouse/scripts/run-daily.ps1 operations/dashboard/lib/health.py operations/dashboard/tabs/diagnostics.py
git commit -m "Daily JobTread bronze pull as source #5 + dashboard health label (Task 8)"
```

---

### Task 9: Attribution fan-out (outbox + GA4 MP + Google upload worker) `[JIM]`

**Files:**
- Modify: `operations/data-warehouse/functions/jobtread-gateway/index.ts` (webhook handler)
- Create: `templates/scripts/push-google-offline-conversions.ps1`
- Modify: `operations/data-warehouse/scripts/run-daily.ps1` (add source #6)

**Interfaces:**
- Consumes: `raw_jobtread_events` payload shape OBSERVED in Task 6 step 3 (write the stage-detection against real payloads, not guesses); `conversions_outbox` from Task 4; existing Google Ads env vars (see `pull-google-ads-warehouse.ps1` header for exact names).
- Produces: Google offline conversions uploaded daily; GA4 `job_signed` events real-time.

- [ ] **Step 1: PING JIM (two manual platform steps):**
  1. Google Ads UI > Goals > Conversions > New conversion action > Import > "Other data sources" / manual upload; name it `JobTread Signed Job`. Copy its resource name / conversion action ID into `.env.local` as `GOOGLE_ADS_JT_CONVERSION_ACTION=customers/<cid>/conversionActions/<id>`.
  2. GA4 Admin > Data Streams > web stream > Measurement Protocol API secrets > Create; add `GA4_MEASUREMENT_ID` + `GA4_API_SECRET` as Edge Function secrets (Supabase dashboard, same place as Task 5 step 3).

- [ ] **Step 2: Extend `handleWebhook`** after the insert (only when the insert succeeded, so webhook replays dedupe on `event_id`): detect a transition into stage name `Signed / Booked` using the REAL payload field paths observed in `raw_jobtread_events`; look up the originating `raw_intake_events` row by `jobtread_job_id` to recover `gclid`; then:

```typescript
// inside handleWebhook, after successful insert (error == null):
const stageName = payload?.job?.stage?.name ?? payload?.stage?.name; // ADJUST to observed shape
const jobId = payload?.job?.id ?? payload?.jobId;                    // ADJUST to observed shape
if (stageName === "Signed / Booked" && jobId) {
  const { data: intake } = await supabase
    .from("raw_intake_events")
    .select("payload")
    .eq("jobtread_job_id", jobId)
    .maybeSingle();
  const gclid = intake?.payload?.gclid ?? null;
  await supabase.from("conversions_outbox").insert({
    platform: "google_ads",
    gclid,
    jobtread_job_id: jobId,
    status: gclid ? "pending" : "skipped",
    error: gclid ? null : "no gclid on intake record",
  });
  const mid = Deno.env.get("GA4_MEASUREMENT_ID"), sec = Deno.env.get("GA4_API_SECRET");
  if (mid && sec) {
    await fetch(
      `https://www.google-analytics.com/mp/collect?measurement_id=${mid}&api_secret=${sec}`,
      { method: "POST", body: JSON.stringify({
          client_id: `jobtread.${jobId}`,
          events: [{ name: "job_signed", params: { job_id: jobId } }],
        }) },
    ).catch((e) => console.error("ga4 mp failed", e));
  }
}
```

Redeploy the function (same MCP call as Task 5 step 3).

- [ ] **Step 3: Write the upload worker** `push-google-offline-conversions.ps1`: load env (same `Load-DotEnv`), read `conversions_outbox` rows `status=eq.pending&platform=eq.google_ads` via Supabase REST, POST a `ClickConversion` batch to `https://googleads.googleapis.com/v20/customers/<cid>:uploadClickConversions` using the SAME auth pattern as `pull-google-ads-warehouse.ps1` (read that script first and reuse its token-refresh function verbatim; developer token + login-customer-id headers identical). Each conversion: `gclid`, `conversionAction=$env:GOOGLE_ADS_JT_CONVERSION_ACTION`, `conversionDateTime` from `conversion_time` formatted `yyyy-MM-dd HH:mm:ssK`, `conversionValue` from `conversion_value_cents/100` (default 0), `currencyCode`. Mark rows `uploaded` (+`uploaded_at`) or `failed` (+`error`). `partialFailure=true` so one bad gclid never sinks the batch.

- [ ] **Step 4: Register as source #6** in `run-daily.ps1` after `jobtread`:

```powershell
    @{ Name = 'google_conv'; Path = Join-Path $RepoRoot 'templates\scripts\push-google-offline-conversions.ps1' }
```

- [ ] **Step 5: End-to-end test:** walk the Task 5 test Job to `Signed / Booked` via AI Connector (draft-then-confirm). Verify: `raw_jobtread_events` row (stage change), `conversions_outbox` row (pending, with the test gclid if the test lead carried one; otherwise `skipped` proves the guard), GA4 DebugView/Realtime shows `job_signed`. Run the worker; verify the outbox row flips `uploaded` and the conversion appears in Google Ads (import can lag hours; check next day if absent). Replay the same webhook payload with curl; verify NO duplicate outbox row (dedupe on `event_id`).

- [ ] **Step 6: Commit**

```bash
git add operations/data-warehouse/functions/jobtread-gateway/index.ts templates/scripts/push-google-offline-conversions.ps1 operations/data-warehouse/scripts/run-daily.ps1
git commit -m "Attribution fan-out: outbox + GA4 MP + Google offline conversion worker (Task 9)"
```

---

### Task 10: Estimating lane + legal template `[JIM]`

**Files:**
- Create: `operations/jobtread/proposal-template-legal-block.md`

**Interfaces:**
- Consumes: the Notice of Cancellation text embedded in the combined estimate + work order generator (`sales/estimates/generate_estimate_pdf.py`; extract the two copies verbatim).
- Produces: a legal-approved JobTread proposal template; the gate that lets real customers sign in JobTread.

- [ ] **Step 1: Extract the legal block:** copy the two Notice of Cancellation copies + the named-builder disclosure text verbatim from the estimate generator into `proposal-template-legal-block.md`, with instructions for where each sits in a JobTread proposal template (both cancellation copies must appear; never strip them; builder-lane variant includes the disclosure).

- [ ] **Step 2: Dispatch legal-compliance-counsel agent** to review the file against ATCP 110 / 16 CFR 429 / Wis. Stat. 423.203 in the JobTread-proposal context and write its sign-off (or required changes) into the same file.

- [ ] **Step 3: PING JIM:** build the JobTread proposal template using the approved block (JobTread UI: proposal template editor), one `cwdb` self-perform template + one `builder` variant with the disclosure. Send himself a test proposal and e-sign it to time the loop.

- [ ] **Step 4: Record the lane rule** in `org-setup-notes.md`: new estimates start in JobTread from today; Streamlit estimator stays as fallback for 1 month or 2 clean JobTread jobs, whichever first; QBO Contracts remains the signing surface ONLY until this template is approved.

- [ ] **Step 4b: PING JIM: connect QBO native sync** (design §2/§9). In JobTread Settings > Integrations > QuickBooks Online, connect the SANDBOX realm first (9341457257078287, per design §9), verify an estimate/invoice syncs where the accounting agent expects, then reconnect to production realm 9341457249522270. Confirm coexistence with QBO Contracts usage. Record sync direction settings in `org-setup-notes.md`.

- [ ] **Step 5: Commit**

```bash
git add operations/jobtread/proposal-template-legal-block.md operations/jobtread/org-setup-notes.md
git commit -m "JobTread proposal legal block + counsel sign-off + lane rule (Task 10)"
```

---

### Task 11: Docs, skills, and memory sweep

**Files:**
- Modify: `CLAUDE.md` (CWDB project file: Tech Stack + Operating Rhythm sections)
- Modify: `.claude/commands/brief.md`, `.claude/commands/state.md`
- Create: `_vault/platforms/JobTread.md`
- Modify: the two PII audit docs (locate via `grep -ril "PII audit" _vault/ docs/ operations/`)
- Modify: `~/.claude/projects/.../memory/MEMORY.md` + create detail file `jobtread-hybrid.md`

**Interfaces:**
- Consumes: everything shipped in Tasks 1-10.
- Produces: navigable, truthful docs; agents that know JobTread exists.

- [ ] **Step 1: CLAUDE.md tech stack line** (add under Tech Stack): `- **Jobs platform:** JobTread (estimating, proposals + e-sign, scheduling, QBO native sync; AI Connector MCP + Pave API; hybrid: HubSpot stays top-of-funnel)` and note the gateway in the architecture prose.

- [ ] **Step 2: brief.md + state.md:** ADD a JobTread job-pipeline read (via AI Connector MCP or Pave) alongside the existing HubSpot read; both live during hybrid.

- [ ] **Step 3: `_vault/platforms/JobTread.md`:** org id, grant name, gateway URL + routes, webhook id, pull script path, outbox worker, secrets inventory (names only), rollback recipe from design §9.

- [ ] **Step 4: PII audits:** add JobTread as a PII processor (customer PII: name/phone/email/address; processor since 2026-07; DPA/terms noted).

- [ ] **Step 5: Memory:** add MEMORY.md one-liner under Standing Rules pointing to a new `[[jobtread-hybrid]]` detail file (gateway architecture, no-undo AI Connector rule, outbox pattern, hybrid seam: fact_leads stays HubSpot-fed until cutover).

- [ ] **Step 6: Agent prose:** `cwdb-ceo-operator.md` verification gate accepts "visible change in JobTread" for job-lane work; `analytics.md` notes the new source + `raw_jobtread_snapshot`. Leave `lead-routing`/`lead-qualification` HubSpot-facing.

- [ ] **Step 7: Commit**

```bash
git add CLAUDE.md .claude/commands/brief.md .claude/commands/state.md _vault/platforms/JobTread.md .claude/agents/cwdb-ceo-operator.md .claude/agents/analytics.md
git commit -m "Docs/skills/memory sweep: JobTread hybrid live (Task 11)"
```

(Memory files under `~/.claude/` are outside the repo; write them but do not git-add.)

---

## Exit criteria (from design §8, tracked after execution)

- Test lead round-trips (Task 5) ✓ gates the relay flip (Task 7)
- Real lead verified in both systems gates ongoing operation
- Daily cron green 7 consecutive days (watch `_vault/data/cron-runs.log`)
- Test conversion visible in Google Ads (Task 9)
- Legal sign-off on file before any real signature in JobTread (Task 10)
