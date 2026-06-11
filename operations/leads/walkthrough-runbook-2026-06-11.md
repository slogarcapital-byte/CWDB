# Walk-Through Readiness Runbook — 2026-06-11

**For:** Jim. **Window:** 7 days to the validation gate (2026-06-18). **Goal:** bid sent + homeowner acceptance.
**Produced by:** lead-qualification agent, control-loop task #57 (trace b7a0af806648). Data pulled live from Supabase + HubSpot 2026-06-11.

---

## 60-Second Action List (do these in order)

| # | Who | Action TODAY (6/11) | Phone |
|---|-----|--------------------|-------|
| 0 | **Joe Sjoberg** | FOLLOW UP on the $13,443 resurface bid already sent. One acceptance = gate passed outright. Highest leverage call of the week. | (715) 297-4513 |
| 1 | **Thomas Quinn** | Call, book walk-through for Fri 6/12 or Sat 6/13. Storm-damaged porch = urgent, well-defined, small job. | (715) 346-2705 |
| 2 | **Mike Kampstra** | Call, book walk-through for Sat 6/13 or Sun 6/14. Highest-intent notes of the three. | (715) 218-3792 |
| 3 | **David A Johnson** | Call, book walk-through early next week (Mon 6/15). "Just researching" = lower urgency; don't burn weekend slots. | (715) 302-4749 |
| 4 | **Darlene** | Discovery callback (5 min): get address, project, budget, timeline, ownership. Record is name + phone only. | (715) 409-1008 |

All calls are Jim's own outbound follow-up on inbound leads with TCPA consent on file (form for 1-3, verbal/assumed for 0 and 4). No automated sends were made by this runbook.

---

## Per-Lead Detail + Pre-Filled Estimate Context

Estimator: https://cwdb-estimator.streamlit.app/ · Estimate PDFs: `sales/estimates/generate_estimate_pdf.py`

### 0. Joe Sjoberg — CHASE ACCEPTANCE (bid already out)
- **Lead:** lead_id 103 · phone channel, **no email** · HubSpot contact [496138717933](https://app.hubspot.com/contacts/245712220/record/0-1/496138717933) · deal 328044234471 (stage: Delivered Bid)
- **Address:** 133 Ross Ave., Wausau WI 54403 (in territory)
- **Project:** deck-repair / resurfacing existing pressure-treated structure · budget 10k-20k · timeline 1-3 months
- **Bid:** bid_id 71, $13,443.00, status `sent`
- **Lane:** `cwdb` (cosmetic resurface, no permit) — combined estimate + work order applies if he accepts
- **Next action:** phone follow-up; if verbal yes, generate the combined estimate/work order for signature and collect deposit (card-first via QBO).
- **Score:** 100/100 (written to warehouse this run)

### 1. Thomas Quinn — walk-through #1
- **Lead:** lead_id 75 · webform 6/10 · HubSpot contact [499866886891](https://app.hubspot.com/contacts/245712220/record/0-1/499866886891)
- **Address:** 10186 County Road Mm, zip 54407 (Amherst Junction, Portage County — ~45 min SE of Wausau, OUTSIDE the scoring-rules zip list; see Findings)
- **Project:** deck-replacement · "8x16 treated lumber porch that needs to be replaced. It was lost in the April ice storm." · budget under-10k · timeline 1-3 months · owns property
- **Lane guess:** `builder` — full structural replacement, permit territory. Possible insurance claim angle (storm loss): ask if an adjuster has been out; insurance money removes the budget ceiling.
- **Estimator prefill:** 8x16 (128 sqft), pressure-treated, tear-off + rebuild, attached porch. Small scope = fast estimate same evening.
- **Why first:** freshest lead (yesterday), real loss event, smallest and clearest scope = fastest bid out the door.
- **Score:** 80/100

### 2. Mike Kampstra — walk-through #2
- **Lead:** lead_id 50 · webform 6/7 · HubSpot contact [498552078025](https://app.hubspot.com/contacts/245712220/record/0-1/498552078025)
- **Address:** 212727 Hayes Rd, zip 54484 (Stratford — ~30 min SW of Wausau, OUTSIDE the scoring-rules zip list; see Findings)
- **Project:** deck-replacement or repair · "Joists need to be sistered or replaced as there is some rot. Structurally, the ledger and first 4 ft of the joists are very sound." · budget not-sure · timeline 1-3 months · owns property
- **Lane guess:** `builder` — joist sistering/replacement is structural repair. He's already diagnosed his own framing: technically literate buyer, bring a moisture meter and quote both repair-and-redeck vs full replace.
- **Estimator prefill:** existing attached deck, partial frame repair (sister joists beyond 4 ft from ledger) + full redeck; capture dimensions on site (not provided).
- **Why second:** most detailed homeowner notes of the batch = highest intent; budget open-ended.
- **Score:** 80/100

### 3. David A Johnson — walk-through #3
- **Lead:** lead_id 49 · webform 6/7 · HubSpot contact [498530723573](https://app.hubspot.com/contacts/245712220/record/0-1/498530723573)
- **Address:** 5706 Alex Street, zip 54476 (Weston — in territory)
- **Project:** deck-replacement · "2009 build with wearing, needs an upgrade" · budget under-10k · timeline **just-researching** · owns property
- **Lane guess:** fork at walk-through — if the 2009 frame is sound, pitch a resurface/redeck (`cwdb` lane, no permit, fits under-10k budget, CWDB self-performs and keeps the whole ticket). If frame is shot, `builder` lane replacement.
- **Estimator prefill:** 2009 PT deck, capture dimensions on site; prep both a resurface option and a replacement option.
- **Why third:** "just researching" + oldest of the three. Still book him this week: a same-week in-person visit is exactly what converts researchers.
- **Score:** 80/100

### 4. Darlene — discovery callback (not yet walk-through ready)
- **Lead:** lead_id 104 · phone channel 6/3 · **no email, no address, no project data** · HubSpot contact [496138719988](https://app.hubspot.com/contacts/245712220/record/0-1/496138719988)
- **Next action:** 5-minute callback to capture address, ownership, project type, budget, timeline. Log to HubSpot; daily warehouse pull picks it up. Do NOT count toward gate planning until scoped.
- **Score:** 10/100 (incomplete record, not disqualified)

---

## Calendar Feasibility: 3 walk-throughs by 6/18?

**Verdict: comfortably feasible.** 7 calendar days, 3 visits, all within ~45 min of Wausau.

| Day | Plan |
|-----|------|
| Wed 6/11 (today) | All 5 calls (Sjoberg follow-up first). Book the 3 walk-throughs. |
| Fri 6/12 – Sat 6/13 | Quinn walk-through (Amherst Jct). Estimate out same evening via Streamlit. |
| Sat 6/13 – Sun 6/14 | Kampstra walk-through (Stratford). Estimate out within 24h. |
| Mon 6/15 | Johnson walk-through (Weston). Estimate out 6/15-6/16. |
| Tue 6/16 – Wed 6/17 | All 3 estimates delivered; follow-up calls on each. |
| Thu 6/18 | Gate day. |

Risks: (1) homeowner scheduling, mitigate by offering evening/weekend slots on the first call; (2) acceptance (not the walk-through) is the real gate metric, and the realistic acceptance-by-6/18 path is **Sjoberg**, whose bid is already out, or **Quinn** (small, urgent, possibly insured). (3) Quinn and Kampstra are outside the documented territory zips; drive time is fine, but see Finding F2 before promising service-area marketing claims.

---

## ARTIFACT: Schema Validation — Real Leads vs Scenario 5361099 (sc-002) Webhook Contract

**Contract source:** `operations/make/webhooks.json` sc-002 (hook 2442209, scenario 5361099, INACTIVE).
Webhook interface: `webflow_submission_id, submitted_at, date_key, name, phone, email, tcpa_consent_given, utm_source`. Module 2 upserts `fact_leads` via PostgREST `?on_conflict=webflow_submission_id` (Prefer: resolution=merge-duplicates) and hardcodes `lead_channel='webform'`, `tcpa_consent_source='form'`. Module 3 inserts a `fact_bids` row `{lead_id, contractor_id: null, bid_status: 'pending'}`.

**Rows checked (full fact_leads rows pulled 2026-06-11):** Johnson (49, webform), Kampstra (50, webform), Quinn (75, webform), Sjoberg (103, phone/no-email), Darlene (104, phone/no-email), plus manual leads Nayak (97) and Keuler (98) observed in the same pull.

### Findings (by severity)

**F1 — CRITICAL: `webflow_submission_id` is NULL on ALL real rows, including the 3 webform leads.**
The current ingestion path (HubSpot daily pull) never populates it. Postgres unique index `fact_leads_webflow_submission_id_key` is NOT declared `NULLS NOT DISTINCT`, so `ON CONFLICT (webflow_submission_id)` **never fires when the key is NULL — and never matches existing NULL rows even when the webhook supplies a value**. Consequences for go-live (task 58):
- A webhook post for a lead that already exists from the HubSpot pull inserts a **duplicate fact_leads row** (e.g. re-submitting Quinn would create lead_id N+1 alongside 75).
- Duplicates flow into `v_clean_leads` → inflate `v_lead_funnel.leads_qualified` → **corrupt the validation gate** (same failure class as the routing-selftest bug caught 2026-06-09).
- Fix options: (a) make the webhook the FIRST writer and have the daily HubSpot pull upsert on `hubspot_contact_id` (unique index exists) with email/phone matching to merge rather than insert; (b) add a dedupe key the two paths share (normalized phone + date); (c) declare the index `NULLS NOT DISTINCT` is NOT a fix (would collapse all NULL rows into one conflict target — worse).

**F2 — HIGH: phone/manual leads structurally cannot use the sc-002 contract.**
Sjoberg (103) and Darlene (104) have no `webflow_submission_id` and no email. Email is nullable in `fact_leads` and `v_clean_leads` handles NULL email explicitly (`email IS NULL OR ...`), so the rows themselves are healthy — but if anyone ever replays a phone lead through the webhook: NULL upsert key → guaranteed duplicate insert on every retry (no idempotency), plus hardcoded `lead_channel='webform'` / `tcpa_consent_source='form'` would **falsify the channel and TCPA consent provenance** (Sjoberg's consent is `assumed`, not `form`). sc-002 must remain webform-only; phone leads stay on the HubSpot-manual-entry path.

**F3 — HIGH: the webhook contract drops every qualification field.**
The 8-field interface omits `property_address, owns_property, project_type, budget_range, project_timeline, lead_notes`, and zip/city. A lead landing via sc-002 alone cannot be scored (homeowner/territory/budget/timeline are 90 of 100 points) and cannot feed this runbook. The production contract (task 58) needs the full 10-field sc-001 payload (name, phone, email, address, owner, project_type, budget, timeline, notes, tcpa_consent) mapped to warehouse columns.

**F4 — MEDIUM: module 3 auto-insert of a pending `fact_bids` row inflates the funnel.**
`v_lead_funnel.leads_delivered_to_contractor` counts ANY `fact_bids` row for the lead. A webhook that always inserts `bid_status='pending', contractor_id=null` marks every submission "delivered to contractor" the instant it arrives, before any contractor sees it. Either gate the insert on actual routing or change the funnel view to require `contractor_id IS NOT NULL`.

**F5 — MEDIUM: scoring-rules territory list is stale vs business reality.**
`operations/leads/scoring-rules.json` lists zips 54401/54403/54476/54474/54452 with `disqualify_if_fail: true`. Kampstra is 54484 (Stratford) and Quinn is 54407 (Amherst Jct) — both would be HARD-DISQUALIFIED by the rules as written, yet both are verified-real, Jim-qualified leads being pursued. Recommend Jim confirm the true drive-time radius and update `service_territory.zip_codes` before any automated scoring goes live, or automation will reject leads Jim wants.

**F6 — LOW: phone formats are not normalized.**
Observed in the same column: `17153024749`, `+1 (715) 218-3792`, `7153462705`, `+17152974513`. The 30-day duplicate-by-phone rule in scoring-rules.json is unenforceable without E.164 normalization at ingest (webhook AND HubSpot pull).

**F7 — LOW: `city_id` NULL on Kampstra/Quinn rows; `dim_cities` does not exist (table is `dim_city`).**
Webhook contract has no city/zip field, so city attribution (`v_cac_by_channel` by city, `idx_fact_leads_city_date`) silently degrades for webhook-landed leads. Derive `city_id` from zip at ingest.

**NOT-NULL contract check (submitted_at, date_key, phone, tcpa_consent_given):** all 7 real rows satisfy all four. A minimal phone lead (Darlene: name + phone + assumed consent only) still satisfies the table constraints; the binding constraint is the missing upsert key (F1/F2), not NOT-NULLs.

### Warehouse writes made by this run (tier 1, internal only)
`UPDATE fact_leads SET lead_score = ... WHERE lead_id IN (49,50,75,103,104) AND lead_score = 0` → 49=80, 50=80, 75=80, 103=100, 104=10. `disqualification_reason` untouched (all NULL; F5 territory misses deliberately NOT written as disqualifications). Verified post-write: `v_validation_gate` unchanged (qualified_since_gate=3, accepted_lifetime=0, gate_met=true). `v_lead_funnel` does not reference `lead_score`, so scoring writes cannot move the gate.
