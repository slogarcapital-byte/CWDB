# JobTread Migration Analysis — HubSpot → JobTread + Claude Connectivity

**Date:** 2026-07-12
**Status:** Decision-grade analysis (no systems changed)
**Question:** What is the lift — technical and business — to switch CWDB from HubSpot to JobTread, and to connect JobTread to Claude?

---

## 1. Executive Summary

**Connecting JobTread to Claude is easy. Replacing HubSpot is not — but most of what's hard is optional, and the timing argument for JobTread is strong.**

- JobTread ships an **official MCP server** (the "AI Connector," `https://api.jobtread.com/mcp`) that connects to Claude / Claude Code the same way the HubSpot connector does today, plus a full programmatic API ("Pave") and webhooks for the warehouse scripts. Claude connectivity is a few hours of work, not a project.
- HubSpot is deeply coupled in exactly **three places**: the warehouse ingestion script (677 lines shaped around HubSpot objects), the Supabase schema (tables keyed on HubSpot IDs), and the **ads-attribution architecture** (closed-loop conversions keyed off HubSpot deal-stage changes). Everything else — dashboard, skills, agents, routing config — is labels and prose.
- Business-wise this is a **strategic-fit decision, not a tooling decision**. HubSpot Starter ($15/mo) fits the parked lead-resale model. JobTread ($159–199/mo, 1 seat) fits the adopted Phase 2 self-perform model — and would consolidate the Streamlit estimator, work orders, QBO Contracts e-sign, and the job-costing data the Phase 2 KPIs need but don't have today.
- **Recommendation: Option B — phased hybrid.** Adopt JobTread now for jobs/estimating/production (where CWDB has no real system), keep the HubSpot form relay and pipeline running as top-of-funnel until the JobTread webhook-based attribution replacement is proven, then cut over. Full cutover in one shot is ~55–95 hours and risks the funnel; the hybrid first phase is ~20–30 hours and risks nothing.

**Total cost of change:** ~$1,750–2,200/yr in new subscription cost (net of what it can retire), plus 20–30 hours near-term / 55–95 hours to full cutover.

---

## 2. What JobTread Is — and Isn't

JobTread is **construction management software**: estimating, budgets/job costing, proposals with e-signature, scheduling, customer portal, documents, purchase orders, and native QuickBooks Online sync. It has a sales pipeline for jobs, but it is **not a marketing CRM**:

| Capability | HubSpot Starter (today) | JobTread |
|---|---|---|
| Web form capture endpoint | Native Forms API (`api.hsforms.com`, unauthenticated client POST) | **None public** — intake goes through Zapier or the authenticated Pave API |
| Marketing attribution (`hs_analytics_source`, UTM-on-contact) | Native | **None** — must be modeled as custom fields |
| Ad-platform integrations (Google offline conversions, Meta CAPI) | Native/plannable | **None** — must be built on webhooks |
| Deal pipeline | 9-stage Homeowner Leads + 8-stage Contractor Sales | Job stages + custom fields (comparable) |
| Estimating / cost catalogs | None (Streamlit app built in-house) | **Core product** |
| Proposals + e-sign | None (QBO Contracts workaround) | **Core product** |
| Job costing / budgets vs actuals | None | **Core product** |
| Work orders / subcontractor management | In-house PDFs | **Core product** (free unlimited external vendor/sub/customer users) |
| QuickBooks integration | Designed, never built (`hubspot-qbo-flow.md`) | **Native sync** |
| Claude / MCP | HubSpot connector (in use by `brief`/`state`) | **Official AI Connector MCP server** |

The overlap map is the crux: JobTread is weak exactly where HubSpot is strong (top-of-funnel capture + attribution) and strong exactly where CWDB currently has hand-rolled or missing systems (estimate → contract → build → invoice).

## 3. Connecting JobTread to Claude (the easy part)

Three integration surfaces, all first-party:

1. **AI Connector (MCP server)** — `https://api.jobtread.com/mcp`, OAuth against the JobTread org. Add as a custom connector on claude.ai and as an HTTP MCP server in Claude Code. Replaces every current HubSpot MCP use: the `brief`/`state` skills' live pipeline pulls, `lead-routing`'s CRM writes, CEO-operator verification gates. Caveats per JobTread's docs: it acts with your full account permissions and **writes are immediate with no undo** — skills that write should keep a draft-then-confirm pattern.
2. **Pave API** — `POST https://api.jobtread.com/pave`, GraphQL-style query object, `grantKey` auth (created at app.jobtread.com/grants). Covers customers, contacts, jobs, locations, tasks, documents, custom fields, pagination/filtering (`where`, `sortBy`), and **webhook subscriptions**. This is what the warehouse pull script and form-intake middleware would use. One new secret (`JOBTREAD_GRANT_KEY`) replaces `HUBSPOT_PRIVATE_APP_TOKEN`.
3. **Zapier (first-party) / Make (third-party app by Maxmel Tech)** — relevant because CWDB already has a Make account (scenario 4792854, parked).

**Lift: ~2–4 hours** (connector setup + swapping MCP tool references in `.claude/commands/{brief,state}.md` and agent prose).

## 4. Technical Migration Lift — System by System

Inventory from a full repo sweep (~200 files mention HubSpot; the load-bearing code is below).

### 4.1 Deep couplings (the real work)

| # | System | Today | Migration work | Effort |
|---|---|---|---|---|
| 1 | **Warehouse ingestion** — `templates/scripts/pull-hubspot-snapshot.ps1` (677 lines) | Pulls contacts (26 props), deals (18 props), companies from HubSpot CRM v3; hardcodes pipeline `2247158458` + all 9 stage IDs → `bid_status` map; writes `raw_hubspot_snapshot`, `dim_contractor`, `fact_leads`, `fact_bids` | Full rewrite as `pull-jobtread-snapshot.ps1` against Pave (customers/contacts/jobs + custom fields). Business logic (test-lead exclusion, TCPA consent-as-data, channel derivation, budget normalization) ports over; the object mapping does not | **12–20 h** |
| 2 | **Warehouse schema** — `schema/001_initial.sql` + migrations `003`, `005`, `013`; keys `hubspot_contact_id` / `hubspot_deal_id`; `hs_analytics_source` column | Tables are keyed on HubSpot object IDs | New migration: add `crm_source` + generalized `crm_object_id` (or parallel `jobtread_customer_id`/`jobtread_job_id`) so historical HubSpot rows and new JobTread rows coexist. The 6 KPI views read `fact_leads`/`fact_bids` columns, not HubSpot IDs — they survive mostly untouched | **4–8 h** |
| 3 | **Data model remap** — 9-stage Homeowner pipeline + 19 custom properties (`operations/automation/hubspot-lead-pipeline.json`, `hubspot-build/*.csv`) | HubSpot Contact (11 custom props) + Deal (8 custom props), workflow creates the Deal | JobTread: Customer + Contact + **Job** (custom fields supported on all three). 9 deal stages → job stages. Key props to preserve: `lead_channel`, `tcpa_consent_source`, `tcpa_consent_given`, `budget_range`, UTM set, `lead_score`. Also remodel the separate 8-stage Contractor Sales pipeline (`sales/crm/pipeline-stages.json`) — or park it with the lead-resale model | **4–6 h** (JobTread org setup) |
| 4 | **Website form relay** — `website/scripts/hubspot_form_relay-1.0.0.js` | Client-side fire-and-forget POST to `api.hsforms.com` with hardcoded portal `245712220` + form GUID; FIELD_MAP → HubSpot props; injects UTM/gclid | JobTread has **no unauthenticated forms endpoint** and the `grantKey` can't ship in browser JS. Insert a middleware hop: **Supabase Edge Function** (recommended — infra already exists; also gives a warehouse-first landing point for leads) or a Zapier webhook. Rewrite relay to POST there; function calls Pave `createCustomer`/`createJob` and stamps UTM/gclid/consent custom fields | **8–12 h** |
| 5 | **Ads attribution / closed-loop conversions** — `operations/analytics/hubspot-webflow-native-plan.md` (canonical) | Architecture keys Google Ads offline conversions, Meta CAPI, and GA4 MP events off HubSpot lifecycle/deal-stage transitions | **Biggest risk.** Rebuild the fan-out on JobTread **webhooks** (job-stage-change events → Supabase Edge Function → ad platforms). Nothing in JobTread does this natively | **16–30 h** — or **$0 now** under the hybrid (see §5) |

### 4.2 Medium couplings

| System | Work | Effort |
|---|---|---|
| Estimator pre-fill — `sales/estimating/streamlit_app/hubspot_client.py` (109 lines, read-only contact search) | Repoint to Pave customer search — **or retire the estimator entirely** in favor of JobTread estimating/proposals (separate decision; JobTread e-sign also supersedes the QBO Contracts combined estimate + work order flow, though the two embedded Notice of Cancellation copies must be reproduced in JobTread proposal templates — legal review required before switching signing surfaces) | 2–4 h to repoint |
| PDF paper trail — `templates/scripts/attach-file-to-deal.ps1` (HubSpot Files + deal note) | JobTread documents-on-jobs replaces this natively | 1–2 h |
| QBO integration — `operations/data-warehouse/design/hubspot-qbo-flow.md` (design-only, never built) | **Deleted from the backlog** — JobTread↔QBO sync is native. This is negative lift | −(future build) |
| Contractor directory — `operations/leads/routing-rules.json` (runtime lookup of `lifecyclestage=customer` in HubSpot) | Repoint to JobTread vendors, or park with the resale model | 1–2 h |

### 4.3 Shallow couplings (labels and prose)

- **Dashboard** (`operations/dashboard/`): reads only Supabase; "hubspot" is a platform label in `lib/health.py`, `tabs/diagnostics.py`, `app.py`, and the `platform_health` table. Rename to `jobtread`. ~1 h.
- **Skills/agents**: `.claude/commands/{brief,state}.md` MCP tool swap; prose updates in `lead-routing`, `lead-qualification`, `cwdb-ceo-operator`, `analytics` agents; rewrite 3 HubSpot-specific agent-memory files. ~2–4 h.
- **Docs/vault**: CLAUDE.md tech stack, `_vault/platforms/`, canvases, PII audits (HubSpot is a documented PII processor — add JobTread, note data-migration handling). ~1–2 h.
- **Credentials**: retire `HUBSPOT_PRIVATE_APP_TOKEN` + `hubspot_private_app_token` (Streamlit secret); add `JOBTREAD_GRANT_KEY` + MCP OAuth.

### 4.4 One-time data migration

Export HubSpot contacts/deals (the full history is also already mirrored in `raw_hubspot_snapshot` — bronze layer preserves everything even after HubSpot is gone), import customers/jobs into JobTread via Pave or CSV. At current volume (tens of contacts, ~20 deals) this is small: **4–8 h** including verification.

### 4.5 Effort totals

| Path | Scope | Estimate |
|---|---|---|
| Claude connectivity only (no CRM switch) | AI Connector + skill swap | **2–4 h** |
| Hybrid Phase 1 | JobTread org setup + estimator lane + QBO sync + MCP + warehouse *additive* pull | **20–30 h** |
| Full cutover | Everything incl. form relay middleware, schema migration, attribution rebuild, data migration, doc sweep | **55–95 h** |

## 5. The Attribution Problem (critical path)

The migration's one genuinely hard problem — with an important mitigating fact from live data:

**Attribution is already broken.** June 2026 (live `v_cac_by_channel`): $912 Google spend but only **1 lead attributed to google_ads**, while **8 landed in organic_direct** — the UTM black hole that `v_meta_attribution_gap` was built to diagnose. The `hubspot-webflow-native-plan.md` closed-loop architecture was designed to fix this and is **not yet delivering**. So the migration doesn't destroy a working attribution system; it changes which platform the fix gets built on.

That cuts both ways: there's less to lose, but the fix must not be built twice. Two options:

- **(a) Rebuild on JobTread now:** webhook on job-stage change → Supabase Edge Function → Google offline conversions / Meta CAPI / GA4 MP. UTM/gclid captured at the form middleware (§4.1 #4) and stored as JobTread custom fields. 16–30 h, done once, on the platform you'll keep.
- **(b) Hybrid bridge:** keep the HubSpot relay + pipeline as the attribution surface while JobTread runs jobs; leads dual-write (relay → HubSpot for attribution, middleware → JobTread for production). Defers the rebuild, costs double data entry or a small sync, keeps $15/mo HubSpot running.

Recommendation within the hybrid: go straight to (a) for *new* attribution work — do not invest another hour in HubSpot-keyed conversion plumbing.

## 6. Business Analysis

**Live state (Supabase, 2026-07-12):** 17 leads over May–July (7 / 9 / 1), one accepted + paid bid ever (May — the Overbeck job, $2,800 collected), 0 contractor fees ever invoiced. Monthly ad spend $300–$1,180. The business is running the Phase 2 verdict: self-perform construction fed by the owned lead engine.

**Cost.** HubSpot Starter $15/mo → JobTread $159/mo (annual; $199 monthly), +$18–20 per added user (relevant if SBG proceeds — Ben/John as internal users; subs/customers are free external users). Net new: ~$145–185/mo, **~$1,750–2,200/yr**. Against a break-even business that's real money — but it should be scored against what it retires or unblocks: Streamlit estimator hosting/maintenance, the QBO Contracts e-sign workaround, hand-built work-order PDFs, the never-built HubSpot→QBO integration, and — most importantly — **job costing**, which `v_kpi_job_profitability`, `v_kpi_cycle_time`, and `v_kpi_backlog` require and no current system provides. One incremental job won on faster estimate-to-signature pays for ~2 years of JobTread at Overbeck margins.

**Strategic fit.** The 2026-07-05 audit verdict makes this nearly a category question: HubSpot Starter is a marketing CRM bought for a lead-*resale* model that is now parked; JobTread is job software for the construction model that was adopted. It also fits the SBG evaluation directly (per-LLC job costing, shared-labor billing at the $145/hr derived rate, sub/vendor portals). Counterpoint: the lead engine is CWDB's moat, and JobTread does nothing for top-of-funnel — the Webflow site, ads, and attribution stack remain wholly CWDB-built regardless.

**Risks.**
1. **Attribution regression** (§5) — mitigated by hybrid sequencing and by the fact it's already broken.
2. **TCPA/compliance continuity** — `tcpa_consent_given`/`tcpa_consent_source` must become JobTread custom fields on day one; consent-as-data (`consent_missing`) logic ports into the new pull script. The PII audits must be updated (JobTread becomes a PII processor; verify their data terms).
3. **Notice of Cancellation** — the two embedded copies in the combined estimate/work order are legally required; JobTread proposal templates must reproduce them before any signing moves. Route through legal-compliance-counsel.
4. **No-undo AI writes** — the AI Connector executes with full permissions; keep write-skills on a draft-confirm pattern.
5. **Funnel continuity during cutover** — never cut the form relay before the middleware path is verified end-to-end with a test lead landing in both JobTread and `fact_leads`.
6. **Phone leads** — arrive at webform volume, may lack email; JobTread customers don't require email, but the intake middleware and pull script must preserve `lead_channel` semantics.

## 7. Options

**A. Full cutover (55–95 h).** Everything at once. Fastest to a single system; highest funnel risk; front-loads the attribution rebuild before JobTread has proven itself in daily use. Not recommended.

**B. Phased hybrid (recommended).** 
- *Phase 1 (~20–30 h):* JobTread org + custom fields + job stages; move estimating/proposals/jobs/QBO sync into JobTread; connect the AI Connector to Claude; add a JobTread pull to the warehouse (additive — HubSpot pull keeps running); dashboard gets a `jobtread` platform label. HubSpot untouched as top-of-funnel.
- *Phase 2 (~25–40 h):* form-relay middleware (Supabase Edge Function → Pave), webhook-driven attribution fan-out, schema generalization, historical import.
- *Phase 3 (~5–10 h):* retire the HubSpot pull, cancel Starter, doc/agent sweep, rotate credentials.
- *Gates:* don't start Phase 2 until JobTread has run ≥2 real jobs end-to-end; don't cut the relay until a test lead round-trips; don't cancel HubSpot until one full weekly review runs on JobTread-sourced dashboard data.

**C. Stay on HubSpot, add job costing elsewhere.** Cheapest in cash, but keeps three hand-rolled systems (estimator, work orders, QBO flow) as permanent maintenance, and buys marketing-CRM features the parked model no longer needs. Only right if Phase 2 self-perform stalls.

## 8. Recommendation

**Option B.** The Phase 2 verdict already made the strategic call; JobTread is the tool that matches it, and the official MCP server means Claude-side continuity is trivial. Sequence the migration so the lead engine — the one asset the audit said to protect — is never at risk: jobs move first, the funnel moves last, and the attribution fix gets built once, on JobTread webhooks, not twice.

Immediate next steps if adopted:
1. Start a JobTread trial/demo; validate proposal templates can embed the Notice of Cancellation (legal-compliance-counsel review).
2. Connect the AI Connector to Claude and confirm the `brief`/`state` skills can read job/pipeline state.
3. Model the custom-field set (19 properties → JobTread fields) in the trial org.
4. Decision checkpoint at the weekly review: commit to Phase 1 or fall back to Option C.

---

### Sources

- Repo inventory: full sweep of `operations/`, `website/`, `sales/`, `templates/scripts/`, `.claude/` (details in §4; key files cited inline).
- Live metrics: Supabase `v_lead_funnel`, `v_cac_by_channel` (queried 2026-07-12).
- [JobTread AI Connector — help](https://app.jobtread.com/help/ai-claude-integration) · [AI Connector blog](https://www.jobtread.com/blog/the-jobtread-ai-connector-what-it-is-and-how-it-works)
- [JobTread Open API](https://www.jobtread.com/integrations/open-api) · [API Developer Certification](https://www.jobtread.com/resources/training/certifications/api-developer)
- [JobTread pricing](https://www.jobtread.com/pricing) · [Zapier integration](https://www.jobtread.com/integrations/zapier) · [Make app (Maxmel Tech)](https://apps.make.com/job-tread-nwht6n)
