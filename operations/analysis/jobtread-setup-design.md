# JobTread Setup Design: Accelerated Hybrid

**Date:** 2026-07-13
**Status:** Approved design (Jim, 2026-07-13). Supersedes the sequencing in `jobtread-phase1-plan.md` Part A (trial gates) because the switch decision is made; Part B content is absorbed and extended here.
**Parents:** `jobtread-migration-analysis.md` (Option B analysis), `jobtread-phase1-plan.md` (Phase 1 plan)
**Goal:** Configure JobTread as CWDB's job platform with maximum automation, efficiency, and flexibility, while the HubSpot funnel stays live as a safety net until the new intake path is proven.

---

## 1. Decisions Locked (2026-07-13)

| Decision | Call | Consequence |
|---|---|---|
| Status | Signed up, lightly explored | Clean build plus an inventory pass of anything already configured |
| Posture | **Accelerated hybrid** | Phase 1 org work AND form middleware AND webhook attribution built in one push; HubSpot untouched as parallel safety net until a test lead round-trips |
| SBG | **Lean now** | Solo self-perform data model only; cost codes stay minimal and additive so SBG structure can bolt on later without rebuild |
| Automation backbone | **Supabase Edge Function** | One owned function (`jobtread-gateway`) is the single seam for intake, attribution capture, and conversion fan-out; no new vendor (Make/Zapier rejected as backbone) |

Standing constraints carried forward unchanged:

- Never cut the Webflow form relay before a test lead round-trips through the new path.
- Notice of Cancellation (two embedded copies) must be in JobTread proposal templates with legal-compliance-counsel sign-off before any real customer signs in JobTread.
- TCPA consent is data, never inferred: `tcpa_consent_given` + `tcpa_consent_source` are day-one Customer custom fields.
- AI Connector writes are immediate with no undo: draft-then-confirm for anything customer-visible.

## 2. Target Architecture

```
Webflow form ── POST ──▶ Supabase Edge Function "jobtread-gateway"
                            │  /intake
                            │   1. stamp UTM / gclid / consent / lead_channel
                            │   2. dual-write: JobTread (Pave createCustomer/createJob)
                            │                  + HubSpot (Forms API, safety net)
                            │   3. land lead warehouse-first (fact_leads seam)
                            │
JobTread job-stage ──────▶  │  /webhook
change (webhook)            │   log-only from day one (payload capture)
                            │   fan-out when enabled (step 6):
                            │     Signed/Booked ──▶ Google Ads offline conversion (gclid)
                            │                   ──▶ Meta CAPI (when Meta un-pauses)
                            │                   ──▶ GA4 Measurement Protocol
                            ▼
                      Supabase warehouse ◀── pull-jobtread-snapshot.ps1 (daily source #5)
                            ▼
                      CWDB HQ dashboard (jobtread platform label, existing KPI views)

Claude ◀──▶ JobTread AI Connector (MCP on claude.ai + Claude Code)
Jim    ◀──▶ JobTread UI (estimating, proposals + e-sign, scheduling, native QBO sync)
```

Why the Edge Function is mandatory, not optional: JobTread has no unauthenticated public forms endpoint. Pave requires a secret `grantKey` that can never ship in browser JS, so any intake path needs a server hop. That hop becomes the single chokepoint where attribution and consent get stamped, which is exactly what fixes the UTM black hole.

Why dual-write beats dual-relay: the browser POSTs once to the Edge Function; the function writes server-side to both JobTread and HubSpot. One payload, one place to log and retry, and HubSpot cutover later is deleting one code block.

### Webhook dependency order (explicit)

A webhook needs a URL to point at, so registration cannot precede function deployment:

1. Step 2 creates the Pave grant (auth).
2. Step 3 deploys `jobtread-gateway` and registers the job-stage-change webhook via Pave, pointed at `/webhook` in **log-only mode** (payloads recorded to the warehouse, no side effects). This accumulates real stage-change history and validates payload shape early.
3. Step 6 flips the fan-out on.

## 3. JobTread Org Model (lean solo)

### 3.1 Custom fields

Customer fields:

| Field | Type | Source |
|---|---|---|
| `tcpa_consent_given` | checkbox | form / intake middleware |
| `tcpa_consent_source` | dropdown: form, verbal, assumed | intake middleware or manual |
| `lead_channel` | dropdown: webform, phone, manual, other | intake middleware or manual |
| `utm_source`, `utm_medium`, `utm_campaign`, `gclid`, `lead_source_page` | single-line | intake middleware |

Job fields:

| Field | Type | Notes |
|---|---|---|
| `project_type` | dropdown (same 5 options as HubSpot) | jobs are first-class in JobTread |
| `budget_range` | dropdown, **exact HubSpot option strings** | warehouse normalizer expects these strings |
| `project_timeline` | dropdown | |
| `owns_property` | dropdown | qualification input |
| `source_city` | dropdown (+ native Location city) | preserves city FK logic |
| `lead_score` | number | lead-qualification agent logic unchanged |
| `disqualification_reason` | single-line | |

NOT created (parked with the lead-resale model): `matched_contractor`, `routing_sent_at`, `first_response_window_hours`, `referral_fee_invoiced_at`, `referral_fee_paid_at`, contractor Vendor fields. Create only if the overflow lane reactivates.

Phone-only leads: a Customer with phone and no email must succeed (verify during org setup; phone leads arrive at webform volume).

### 3.2 Job stages (mapped to warehouse `bid_status`)

| # | JobTread stage | `bid_status` | Notes |
|---|---|---|---|
| 1 | New Lead | (pre-bid) | |
| 2 | Qualified | (pre-bid) | lead_score >= 60 |
| 3 | Walk-through Scheduled | (pre-bid) | |
| 4 | Estimating | creating_bid | starts `v_kpi_cycle_time` |
| 5 | Estimate Delivered | delivered_bid | |
| 6 | Signed / Booked | accepted_bid | revenue event; drives attribution conversion + `v_kpi_booked_revenue`, `v_kpi_close_rate` |
| 7 | In Production | accepted_bid | enables `v_kpi_backlog` |
| 8 | Complete - Paid | won | |
| 9 | Stale - No Response | expired | warm-revisit holding stage |
| 10 | Lost | lost | |

### 3.3 Cost codes (minimal, additive)

Solo set only: Materials, Labor, Permits, Equipment, Other. No SBG structure, no extra seats. SBG (shared-labor billing, Ben/John internal seats, $145/hr derived rate) bolts on later if the attorney/CPA gate clears.

### 3.4 Setup mechanics

Field and stage creation is UI paste-work at more than 10 values, so per standing rule it ships as a CSV worksheet (Step / Section / Action / Value) generated during implementation.

## 4. Legal Gates (non-negotiable)

1. Notice of Cancellation: both required copies embedded verbatim in the JobTread proposal template. Route to legal-compliance-counsel for sign-off BEFORE any real customer signs in JobTread. Until sign-off, real signatures stay on the QBO Contracts combined estimate + work order flow.
2. Builder-lane disclosure: a named-builder template variant exists for any pre-license job CWDB does not self-perform.
3. TCPA: consent fields created day one; `consent_missing` flag logic ports into the new pull script; consent blocks SMS, never hides leads.
4. PII: JobTread becomes a PII processor; both PII audit docs updated in step 8.

## 5. Data Layer (additive, zero-risk)

- New migration: `raw_jobtread_snapshot` bronze table (mirrors `raw_hubspot_snapshot` pattern) + nullable `jobtread_customer_id` / `jobtread_job_id` on `fact_leads` / `fact_bids` + `crm_source` column defaulting `'hubspot'`. **No existing columns or views change.**
- New script `templates/scripts/pull-jobtread-snapshot.ps1`: Pave paginated query (customers + contacts + jobs + custom fields). Ports from the HubSpot script: test-lead exclusion, consent-as-data, channel derivation, budget normalization.
- Registered in `run-daily.ps1` as source #5 after ga4 (isolated subprocess, same failure-logging pattern). HubSpot stays source #1.
- Webhook payloads land in a small `raw_jobtread_events` table (log-only mode target; also the audit trail once fan-out is live).
- Form intake lands in `raw_intake_events` (bronze, written by the Edge Function `/intake` route; see §6). Becomes the `fact_leads` source at cutover; until then `fact_leads` stays HubSpot-pull-fed to avoid duplicates.
- Dashboard: `jobtread` added to `platform_health` + label maps (`lib/health.py`, `tabs/diagnostics.py`).
- Reconciliation rule: a JobTread Job whose Customer email/phone matches a `fact_leads` row links via the new ID columns; manual backfill acceptable at current volume.

## 6. Edge Function: `jobtread-gateway`

Single Supabase Edge Function, two routes:

### `/intake` (POST, called by the Webflow relay)

1. Validate + normalize payload (name, phone required; email optional).
2. Stamp attribution (utm_*, gclid, lead_source_page from the relay) and consent (`tcpa_consent_given`, `tcpa_consent_source='form'`), `lead_channel='webform'`.
3. Write warehouse-first: insert into a new bronze table `raw_intake_events` so a durable record exists even if downstream writes fail. NOT directly into `fact_leads`: during the hybrid, `fact_leads` stays populated by the HubSpot pull, so a direct write would duplicate every lead. `raw_intake_events` is the audit trail and the future `fact_leads` source at cutover.
4. Dual-write: Pave `createCustomer` + `createJob` (stage: New Lead) with custom fields; HubSpot Forms API POST (existing portal + form GUID) as the safety-net write.
5. Failure isolation: JobTread write failure must not block the HubSpot write, and vice versa; failures logged per-call.
6. Secrets (`JOBTREAD_GRANT_KEY`, HubSpot IDs) live in Supabase function env, never in the browser.

The Webflow relay (`hubspot_form_relay-1.0.0.js`) is rewritten to POST to this endpoint only, flipped in step 4 after the test round-trip passes.

### `/webhook` (POST, called by JobTread)

- Day one (step 3): log-only. Record payload to `raw_jobtread_events`. No side effects.
- Step 6: on stage transition to Signed / Booked, fire in order of spend priority:
  1. Google Ads offline conversion upload keyed on stored `gclid` (Google is the live $30/day spend and the proven black hole: June $912 spend, 1 attributed lead).
  2. GA4 Measurement Protocol event.
  3. Meta CAPI event (deferred until the Meta campaign un-pauses after its Pixel Lead fix).
- Idempotency: event id + stage transition deduped against `raw_jobtread_events` so replays cannot double-fire conversions.

## 7. Claude Connectivity

- AI Connector MCP (`https://api.jobtread.com/mcp`) added on claude.ai (custom connector) and Claude Code (HTTP MCP server).
- Pave grant created at app.jobtread.com/grants; `JOBTREAD_GRANT_KEY` added to `.env.example` and local env.
- `.claude/commands/brief.md` + `state.md`: ADD JobTread job-pipeline reads alongside HubSpot reads (hybrid = both live).
- Agent prose, minimal: `cwdb-ceo-operator` verification gate accepts "visible change in JobTread" for job-lane work; `analytics` notes the new source. `lead-routing` / `lead-qualification` stay HubSpot-facing until cutover.
- Agent memory: JobTread platform note + the no-undo draft-then-confirm standing rule.

## 8. Build Order (each step gated on the previous)

| # | Step | Gate to proceed |
|---|---|---|
| 1 | Inventory existing org config; create fields + stages + cost codes (CSV worksheet) | Fields queryable via Pave prototype query |
| 2 | AI Connector MCP + Pave grant + PowerShell prototype query | Claude reads customers / jobs / custom fields |
| 3 | Deploy `jobtread-gateway` (/intake dual-write + /webhook log-only); register webhook via Pave | **Test lead round-trips:** lands in JobTread + HubSpot + `raw_intake_events`; webhook payload observed in `raw_jobtread_events` |
| 4 | Flip Webflow relay to the new endpoint | Real lead verified in both systems |
| 5 | Warehouse pull + migration + dashboard label | Daily cron green 7 consecutive days |
| 6 | Enable /webhook fan-out (Google offline conversions first) | Test conversion visible in Google Ads |
| 7 | Estimating lane cutover: new estimates start in JobTread; Streamlit estimator stays as fallback 1 month or 2 clean jobs | Legal sign-off on proposal templates FIRST |
| 8 | Docs sweep: CLAUDE.md tech stack, `_vault/platforms/JobTread.md`, PII audits, `.env.example`, session note, memory updates | none (terminal) |

Steps 1+2 can run the same day; 3 is the largest single build; 5 and 6 can overlap once 4 is done.

## 9. Rollback

- Before step 4: the funnel has zero dependency on JobTread. Rollback = stop work.
- After step 4: HubSpot still receives every lead via dual-write. Rollback = repoint the relay to `api.hsforms.com` (one JS change), unregister the webhook, drop the additive migration (nothing references it), cancel JobTread, resume Streamlit estimator.
- QBO native sync validated against sandbox realm first (9341457257078287) before touching production.

## 10. Testing

- Step 3 gate is an end-to-end test lead using the `@cwdb-internal.test` convention so `v_clean_leads` excludes it.
- `pull-jobtread-snapshot.ps1` gets the same treatment as the HubSpot pull: dry-run mode + per-call logging.
- Conversion fan-out tested with a test job walked through stages; verify dedupe by replaying the same webhook payload.
- Real-device check not required (no UI surface changes except the relay swap, which is invisible; still verify one form submit from Jim's iPhone after step 4 per standing rule).

## 11. Out of Scope (explicitly)

- SBG cost-code structure, partner seats, shared-labor billing (gated on attorney/CPA).
- Contractor/overflow-lane fields and vendor setup (parked with the resale model).
- HubSpot cancellation and credential retirement (a later decision after sustained clean running; not part of this build).
- Historical HubSpot-to-JobTread data import (current volume does not justify it yet; bronze layer preserves history regardless).
