# JobTread Phase 1 — Trial Evaluation Checklist + Execution Plan

**Date:** 2026-07-12
**Parent:** `operations/analysis/jobtread-migration-analysis.md` (Option B, phased hybrid)
**Scope:** Everything up to the Phase 1 → Phase 2 gate. HubSpot stays live and untouched as top-of-funnel throughout.

---

## Part A — Trial Evaluation Checklist (before paying)

JobTread has no free tier, but demos/trials are standard. Work this list during the trial; every item is pass/fail. **Any hard-gate failure → fall back to Option C (stay on HubSpot) and revisit in a quarter.**

### A1. Legal / compliance (HARD GATES)

- [ ] **Notice of Cancellation:** confirm JobTread proposal/contract templates can embed the two required Notice of Cancellation copies verbatim (the ones in the combined estimate + work order). Route the template to **legal-compliance-counsel** for sign-off before any real customer signs in JobTread.
- [ ] **Named-builder disclosure:** confirm templates can carry the Phase 0 `builder`-lane disclosure for any job CWDB doesn't self-perform pre-license.
- [ ] **TCPA consent as data:** create `tcpa_consent_given` (checkbox) + `tcpa_consent_source` (dropdown: form | verbal | assumed) as custom fields on Customer, and confirm they're queryable via Pave. Consent must never be inferred.
- [ ] **Data terms:** review JobTread's DPA/privacy terms; JobTread becomes a PII processor (update both PII audit docs if adopted).

### A2. Data model (HARD GATES)

- [ ] **Custom fields:** create the full field set (§B1 mapping below) on Customer/Contact/Job; confirm dropdowns support the exact option strings (e.g. budget ranges) so warehouse normalization logic ports unchanged.
- [ ] **Phone-only leads:** create a Customer with phone but **no email** — must succeed (phone leads arrive at webform volume).
- [ ] **Job stages:** model the Phase 2 stage set (§B2) and confirm stage-change history is retrievable via Pave (needed for `bid_status` and cycle-time KPIs).
- [ ] **Export:** verify full data export (CSV or Pave bulk query) — no lock-in.

### A3. Integration surface (HARD GATES)

- [ ] **AI Connector:** connect `https://api.jobtread.com/mcp` to claude.ai and Claude Code; verify Claude can read customers, jobs, stages, and custom fields. Test one write (create a test task) and confirm scope/behavior.
- [ ] **Pave API:** create a grant at app.jobtread.com/grants; run a paginated customers+jobs query with custom fields from a PowerShell prototype (this de-risks the warehouse pull before any real work).
- [ ] **Webhooks:** subscribe to a job-stage-change webhook, point it at a test endpoint, and confirm the payload carries enough to drive the future attribution fan-out (job id, old/new stage, timestamps).
- [ ] **QBO sync:** connect the QBO Essentials account (or QBO sandbox first); verify sync direction and that estimates/invoices land where the accounting agent expects. Confirm it coexists with existing QBO Contracts usage.

### A4. Workflow fit (SOFT GATES — judgment calls)

- [ ] **Rebuild one real estimate** (a stain/resurface job like Overbeck) in JobTread estimating; compare output quality and time-to-produce against the Streamlit estimator + PDF pipeline.
- [ ] **E-sign flow:** send a test proposal to yourself; time the estimate → signature loop against the QBO Contracts flow.
- [ ] **SBG lens:** if SBG proceeds, confirm per-job cost codes can represent shared-labor billing at the derived $145/hr rate; Ben/John would be internal seats (+$18–20/user each), subs/vendors free external users.
- [ ] **Pricing confirmed:** 1 internal seat at $159/mo annual ($199 monthly); note contract/cancellation terms.

**Trial exit:** decision checkpoint at the weekly review. All A1–A3 hard gates green → commit to Part B. Log the decision as a dashboard event.

---

## Part B — Phase 1 Execution Plan (~20–30 h)

Ordering principle: nothing in Phase 1 touches the form relay, the HubSpot pipeline, or the existing warehouse pull. Everything is **additive**; rollback at any point = cancel JobTread, delete the additive migration, revert doc commits.

### B1. Workstream 1 — Org setup + custom fields (4–6 h)

Field mapping (HubSpot → JobTread). Contact properties (all form-fillable today):

| HubSpot property | JobTread object.field | Notes |
|---|---|---|
| `project_type` | Job custom field (dropdown, same 5 options) | Lives on Job, not Customer — jobs are first-class in JobTread |
| `budget_range` | Job custom field (dropdown, exact option strings) | Warehouse normalizer expects these strings |
| `project_timeline` | Job custom field (dropdown) | |
| `lead_notes` | Job description / custom multi-line | |
| `owns_property` | Job custom field (dropdown) | Qualification input |
| `source_city` | Location city + custom dropdown | JobTread has native Locations; keep the dropdown for the city FK logic |
| `utm_source`, `utm_campaign`, `gclid`, `lead_source_page` | Customer custom fields (single-line) | Attribution set — stamped by intake middleware in Phase 2; during hybrid these stay HubSpot-side |
| `tcpa_consent_given`, `tcpa_consent_source` | Customer custom fields | Compliance — day-one requirement |
| `lead_channel` (webform/phone/manual/other) | Customer custom field (dropdown) | Feeds `fact_leads.lead_channel` |

Deal properties — **do not blindly replicate**; 6 of 8 are shaped around the parked lead-resale model:

| HubSpot deal property | Disposition |
|---|---|
| `lead_score` | Keep — Job custom field (number); lead-qualification agent logic unchanged |
| `disqualification_reason` | Keep — Job custom field |
| `bid_amount` | Superseded — JobTread estimate/budget totals are native and become the *better* source for `fact_bids.bid_amount` |
| `matched_contractor`, `routing_sent_at`, `first_response_window_hours` | Park — resale-model fields; only create if/when the overflow lane reactivates |
| `referral_fee_invoiced_at`, `referral_fee_paid_at` | Park — same; QBO invoice records cover the rare overflow case |

Contractor-side fields (`business_name`, `service_area_zips`, `onboarded_at`) → JobTread **Vendor** custom fields, only when the overflow lane needs them.

### B2. Workstream 2 — Job stages for the Phase 2 funnel (2–3 h)

The HubSpot 9-stage pipeline narrates the resale model ("Delivered to Contractor", "$1000 referral fee owed"). Model JobTread stages around the **self-perform** funnel, with an explicit map to the warehouse `bid_status` enum so `fact_bids` and the KPI views keep working:

| # | JobTread job stage | Maps to `bid_status` | Notes |
|---|---|---|---|
| 1 | New Lead | (pre-bid) | |
| 2 | Qualified | (pre-bid) | lead_score ≥ 60 |
| 3 | Walk-through Scheduled | (pre-bid) | replaces "Delivered to Contractor" |
| 4 | Estimating | creating_bid | drives `v_kpi_cycle_time` start |
| 5 | Estimate Delivered | delivered_bid | |
| 6 | Signed / Booked | accepted_bid | revenue event → `v_kpi_booked_revenue`, `v_kpi_close_rate` |
| 7 | In Production | accepted_bid | new — enables `v_kpi_backlog` |
| 8 | Complete — Paid | won | closed-won |
| 9 | Stale — No Response | expired | warm-revisit holding stage (kept from HubSpot design) |
| 10 | Lost | lost | closed-lost |

Overflow/resale jobs (builder lane) can use the same stages; the parked routing fields in B1 cover their specifics.

### B3. Workstream 3 — Claude connectivity (2–4 h)

1. Connect the AI Connector on claude.ai (custom connector) and in Claude Code (HTTP MCP server).
2. Update `.claude/commands/brief.md` and `state.md`: **add** JobTread job-pipeline reads alongside the existing HubSpot reads (hybrid = both are live; HubSpot rows drop out at Phase 3).
3. Update agent prose minimally: `cwdb-ceo-operator` (verification gate accepts "visible change in JobTread" for job-lane work), `analytics` (note the new source). Leave `lead-routing`/`lead-qualification` HubSpot-facing until Phase 2.
4. Add a JobTread platform note to agent memory; standing rule: **AI Connector writes are immediate and have no undo — draft-then-confirm for anything customer-visible.**

### B4. Workstream 4 — Estimating/production lane cutover (4–6 h)

- New estimates start in JobTread (templates carry the legal-approved Notice of Cancellation + disclosures from A1).
- Streamlit estimator stays up as fallback for one month; retire after two clean JobTread jobs (its `hubspot_client.py` pre-fill never needs porting under this plan).
- `attach-file-to-deal.ps1` is not used for JobTread jobs — documents live on the Job natively.
- QBO native sync on (validated in A3); the unbuilt `hubspot-qbo-flow.md` design is marked superseded.

### B5. Workstream 5 — Additive warehouse pull (8–12 h)

- New script `templates/scripts/pull-jobtread-snapshot.ps1` (Pave: customers + contacts + jobs + custom fields, paginated; port test-lead exclusion, consent-as-data, channel derivation, budget normalization from the HubSpot script).
- New migration: `raw_jobtread_snapshot` table (bronze, mirrors `raw_hubspot_snapshot` pattern) + nullable `jobtread_customer_id` / `jobtread_job_id` on `fact_leads` / `fact_bids`, and a `crm_source` column defaulting `'hubspot'`. **No changes to existing columns or views.**
- Register in `run-daily.ps1` as source #5, after ga4 (isolated subprocess, same failure-logging pattern) — HubSpot remains source #1.
- Add `jobtread` to `platform_health` + dashboard label maps (`lib/health.py`, `tabs/diagnostics.py`).
- Dual-running both pulls is the hybrid's data seam: leads keep flowing through HubSpot into `fact_leads`; jobs/bids increasingly originate in JobTread. Reconciliation rule: a Job whose Customer email/phone matches a `fact_leads` row links via the new ID columns (manual backfill acceptable at ~10 leads/month).

### B6. Workstream 6 — Docs (1–2 h)

CLAUDE.md tech-stack line, `_vault/platforms/JobTread.md` profile, PII audits (+JobTread as processor), session note. `.env.example` gains `JOBTREAD_GRANT_KEY`.

### Phase 1 exit gate (→ Phase 2: form relay middleware + webhook attribution + historical import)

- ≥ 2 real jobs run estimate → signature → production entirely in JobTread
- Daily JobTread pull green in `cron-runs.log` for 7 consecutive days
- Weekly review runs with JobTread-sourced numbers visible on the dashboard
- Legal sign-off on file for the signing templates

### Rollback (any point in Phase 1)

Cancel JobTread → revert `run-daily.ps1` registration → drop the additive migration (bronze table + nullable columns; nothing references them) → revert doc/skill commits → resume Streamlit estimator. HubSpot was never touched, so the funnel never notices.
