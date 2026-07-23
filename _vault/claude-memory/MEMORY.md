# CWDB Project Memory
Auto-loaded each session. Keep under 100 lines. Detail files in this directory; per-agent platform quirks in `~/.claude/agent-memory/<agent>/`.

## Source of Truth
**Supabase warehouse, not vault files.** Project `iabiwsbmnbxmkjvkgfhg`. Query `v_lead_funnel`, `v_cac_by_channel`, `v_meta_attribution_gap`, `v_contractor_scorecard`, `v_pl_monthly` before claiming any business-state fact. Control-loop health + the gate are machine-readable via `v_control_status` and `v_validation_gate`. See CWDB/CLAUDE.md "Source of Truth" section for the daily-read order.

## Validation Gate (CLOSED 2026-07-05)
- **Verdict (adopted by Jim 2026-07-05):** Phase 1 closed with a pivot. Pay-per-accepted-bid unproven (0 contractor acceptances, $0 fees ever invoiced); parked as a secondary overflow product. Validated model: self-perform construction fed by CWDB's owned lead engine. Phase 2 = construction profitability (licensed, insured, 2-4 booked jobs/month, measured funnel). Full audit + 28-item fix list: `_vault/briefs/2026-07-05-audit.md`.
- **Deadline (was):** 2026-06-18
- **Pass:** `v_validation_gate.gate_met` (qualified_since_gate >= 3 OR accepted_lifetime >= 1). NOTE: the real columns are `leads_qualified`/`leads_bid_accepted`, NOT `qualified_count`/`accepted_count` (that drift is fixed in views/002).
- **As of 2026-06-12: gate met on BOTH criteria** (3/3 qualified: Johnson 6/7, Kampstra 6/8, Quinn 6/10; AND accepted_lifetime=1: Overbeck CWDB-2026-043 [re-based 2026-06-26 from -001] signed + deposit paid 6/11). Caveat: Overbeck is cwdb-lane SELF-PERFORM (direct construction revenue); the $1,000 contractor-fee leg (Ben/John paying for an accepted bid) is still untested. Next proof: a builder-lane acceptance.
- **Miss:** call pay-per-accepted-bid model unproven. Pivot or sunset. No third extension.

## User
- [Jim](user_name.md) — call him Jim; James is legal docs only
- [No em dashes ever](feedback-no-em-dashes.md) — STANDING RULE. Replace with period/colon/comma/parens/and

## Business Contact (Canonical NAP)
- [CWDB NAP](business-contact.md) — 906 N 16th Ave, Wausau WI 54401 · (715) 544-7941 · info@cwdeckbuilders.com
- [Social URLs](social-urls.md) — IG `cwdeckbuilders`, FB `profile.php?id=61564720918864`, Nextdoor `central-wisconsin-deck-builders-wausau-wi`

## LLC
[Central Wisconsin Deck Builders, LLC](llc-formation.md) — Formed 2026-04-06, Wisconsin single-member, James Slogar Sole Member. EIN 41-5355234, WI Entity C138564. Annual report due 2027-06-30. S-Corp election DECLINED for 2026 (decision 2026-06-09; revisit triggers in `agent-memory/accounting/s-corp-decision.md`).

## Brand
Name: Central Wisconsin Deck Builders. Domain: cwdeckbuilders.com. Colors: `#e54c00` Orange · `#323434` Slate · `#646760` Grey · `#83b2cf` Sky Blue. Logos in `/branding/logos/`.

## Contractors signed
- Ben Barton (Barton Builders LLC), HubSpot contact `462464338657`, agreement signed 2026-04-17
- John Garcia (John Garcia Construction LLC), HubSpot contact `465926077160`, agreement signed 2026-04-17
- Both deals closedwon 2026-04-19. Zero accepted bids to date.

## Fulfillment Model (pivot 2026-06-10)
[Jim owns follow-up/walk-throughs/estimates](fulfillment-model-pivot-2026-06-10.md) — Ben/John too busy for the 48h quote promise. Hand-off at the estimate: `fulfillment.lane` in estimate JSON = `cwdb` (stain/resurface self-perform, work order + deposit) or `builder` (named-builder disclosure prints; builder signs/deposits/permits; $1,000 fee on acceptance). CWDB NEVER signs as prime or takes a build deposit pre-license (DSPS cert + GL pending). Option B (CWDB primes, subs to Ben/John) unlocks post-license. Legal punch list: board WB-018.

## Lead history (as of 2026-07-22: 19 clean leads in v_clean_leads after views/010; lead_scores tiers 10A/5B/1C/1D/3DQ)
- 11 clean rows in `fact_leads` = 7 webform + 2 phone (Sjoberg, Darlene) + 2 manual (Nayak, Keuler). 3 qualified leads followed up by Jim 6/11: Johnson, Kampstra, Quinn. See **[All channels count](phone-leads-count.md)** (phone leads = webform for funnel + gate; `lead_channel`/`tcpa_consent_source`, schema/009-010, views/004).
- `v_clean_leads` excludes test noise: utm_source='test', slogarjw@gmail.com (views/003), and @cwdb-internal.test (views/006). lead_id 48 was Jim's self-test that false-counted as qualified.
- **First accepted bid 2026-06-11** (Overbeck, bid_id 4, $2,800, cwdb lane). No real lead has ever been routed to a CONTRACTOR yet (builder-lane routing still unproven). Sjoberg $13,443 + Nayak $4,900 + Keuler deals in fact_bids.

## Standing Rules (durable, all agents)
- [Reorient via vault primary sources before diagnosing](feedback-reorient-via-vault-before-diagnosing.md) — after multi-day gap, read state-archive + agent-memory + raw Supabase before forming hypotheses
- [Elegant path default](feedback-elegant-path-default.md) — propose bulk/scripted/API alternatives before manual workflows
- [Spreadsheets for heavy copy-paste](feedback-spreadsheet-for-copy-paste-workflows.md) — CSV columns Step/Section/Action/Value for any ≥10-value UI-paste task
- [Verify platform-account identity before configuring](feedback-account-identity-verification.md) — confirm account selector at top of UI before pasting IDs (Phase F 2026-04-18 incident)
- [Real-device mobile testing is the only acceptance](feedback-real-device-mobile-testing.md) — Playwright Chromium ≠ iOS Safari; require Jim's iPhone 11 Safari + Chrome confirmation
- [Webflow native elements over custom HTML](feedback-webflow-native-elements.md) — pause and ask Jim if a custom embed seems needed
- [Webflow component-first sections](feedback-webflow-components.md) — edit props → copy+rename → net new (last resort); headers always `hero-`, footer always `footer`
- [Ad creatives always 1:1 + 9:16 + 16:9](feedback-ad-creative-three-ratios.md) — every batch, every platform, 1080×1080 + 1080×1920 + 1920×1080 master ratios
- **Combined estimate + work order** (`combined: true`) for ALL new cwdb-lane jobs (standalone work-order generator retired; Overbeck grandfathered). Builder lane stays estimate-only. /bid skill encodes lane derivation + no-cash payment string + QBO Contracts send path.
- **[[jobtread-hybrid]] is the jobs platform (2026-07-13):** HubSpot stays top-of-funnel until cutover; `fact_leads` stays HubSpot-fed (gateway writes `raw_intake_events`, NOT fact_leads); AI Connector writes have NO undo; stage 6 = `Signed / Booked` exactly; no real JobTread signature until legal sign-off.
- **[[cwdb-hq-dashboard]] is the operating surface (2026-07-06):** `dashboard_tasks` (Supabase) = CANONICAL task list; `_vault/board/*.md` are GENERATED mirrors, never hand-edit. Unprocessed `dashboard_events` at session start → run `/dashboard-sync`. Consent is data not a gate (`consent_missing` flag blocks SMS, never hides leads). fact_bids accepted_at = earliest-wins (HubSpot closedate re-stamps). Test-exclusion predicate lives in BOTH v_clean_leads and v_clean_leads_safe.

## Key Decisions Log (compressed; full detail in linked files / CLAUDE.md / agent-memory)
- **2026-03-12** — Pay per accepted bid at $1,000 confirmed
- **2026-03-29** — Webflow native forms (replaced Tally); 21-page site
- **2026-04-18** — Ad budget $50/day ($30 Google + $20 Meta); Nextdoor organic-only
- **2026-04-19** — Lead-routing pivot: Make scenario parked, manual SMS interim; reactivation triggers ≥10 leads/wk OR 3rd contractor OR 1st accepted bid. See [[pivot-2026-04-19]]
- **2026-04-21** — Full site revamp (Staatliches + Public Sans, photo-driven, zero-decoration)
- **2026-05-19** — Google Ads: switch to Maximize Clicks until ≥30 conv banked (Smart Bidding cold-start starved)
- **2026-06-03** — Supabase warehouse + Task Scheduler cron + 4 ingestion scripts shipped
- **2026-06-04** — Google OAuth refresh-token expiry fixed (cwdb-ads-pull app published; was misdiagnosed as dev-token blocker)
- **2026-06-05** — `_vault/claude-memory` junction rebuilt (OneDrive corruption); CWDB pinned local; source-of-truth → Supabase; gate 2026-06-18 set
- **2026-06-09** — Autonomous control plane built (migration 006 + views/002; `control-tick.ps1` watchdog + `cwdb-orchestrator-tick`). On/off: `control-power.ps1 on|off|status`. Remote routine `CWDB-Orchestrator-Tick` registered (cron every 2h 7a-9p Central; connectors Supabase+Make+HubSpot). Coupling caveat: gate token refreshed by LOCAL watchdog → laptop-off = remote tick skips. See [[schedule-supabase-not-routine-eligible]], [[v-clean-leads-test-exclusion-gap]]. Accounting agent = CPA+QBO; S-Corp DECLINED 2026 (revisit triggers in agent-memory/accounting).
- **2026-06-10** — Two-tier homeowner contract system [[sow-job-number-system]] (signed contract REQUIRED at deposit per ATCP 110.05). Mission Control dashboard shipped [[dashboard-babysitter-port-aware]]. Gate hit 3/3 qualified. Fulfillment pivot [[fulfillment-model-pivot-2026-06-10]]. Invoice series INV-YYYY-NNN. [[phone-leads-count]]. [[ps7-invoke-restmethod-non-enumeration]].
- **2026-06-10 owner decisions (durable, do not re-raise):** (1) NO WI sales tax on ANY CWDB revenue (lead fees + construction/staining). (2) Payments card/digital (QBO) first, then check, NO cash; invoices sent from QBO. (3) Combined estimate+work order = one PDF, cwdb-lane (signature converts to binding work order); builder lane estimate-only. (4) Overbeck staining proceeds UNINSURED (risk accepted). (5) HubSpot portal **245712220 on NA2** (app-na2.hubspot.com).
- **2026-06-11** — WB-016 HubSpot wiring DONE. **QBO PRODUCTION LIVE** (prod realm 9341457249522270, sandbox 9341457257078287 for testing, `QBO_ENVIRONMENT` selects; runbook `finance/invoices/qbo-production-cutover.md`). Control plane Inc 2→5 live [[control-plane-inc2-5-rollout]] (since RETIRED 7/5). Owner: NO QBO Plus (Essentials gives e-sign); Notice of Cancellation copies STAY embedded (16 CFR 429 + Wis. Stat. 423.203); GV→HubSpot call-logging gap (`operations/leads/google-voice-hubspot-memo.md`).
- **2026-06-12** — **FIRST ACCEPTED BID + REVENUE.** Overbeck signed via QBO Contracts, $840 deposit; gate met on BOTH criteria (cwdb-lane self-perform; contractor-fee leg untested). fact_bids bid_id 4, job CWDB-2026-043, INV-2026-043; final $1,960 paid 6/28 (total $2,800 collected).
- **2026-06-17** — **Estimator v2 LIVE** (Streamlit Cloud): TimberTech decking/railing, per-line color, New Build + Fence, auto AI mock-ups. **Deploys from `test-branch` NOT main.** EXIF orientation via `exif_transpose`; PDF mock-up = side-by-side one-page + 8pt consolidated disclosure (commit 2e6faf7). Renderer needs PAID Gemini key in Streamlit Cloud secrets [[streamlit-secrets-location]]; iOS-Safari input fix [[ios-safari-streamlit-dark-inputs]]. OPEN: John to confirm TimberTech/fence pricing (`CONFIRM WITH JOHN`).
- **2026-06-18** — **SBG Construction Group under evaluation** [[sbg-construction-group]]: shared-services/captive-labor group (NOT a merger); 3 LLCs stay independent (Phase A), shared SBG-Labor (S-corp) + SBG-Equipment + SBG-RealEstate owned 1/3 each. Partners $80/hr W-2 → ~$145/hr billable. Lead engine stays Jim's, DOWNPLAYED in partner docs. Package `business-context/construction-group/` (PRIVATE: financial-model §4 + jim-private-brief). Gated on WI attorney + CPA. Open: WI sales tax on equipment leases (SEPARATE from the no-CWDB-sales-tax call).
- **2026-06-24** — Mission Control dashboard ghost-Running outage fixed: keep-alive is now a **port-aware short-lived babysitter** (not a direct always-running task) + crash logging to `_logs/` + resilient accept loop. Self-heal kill-tested. See [[dashboard-babysitter-port-aware]].
- **2026-06-26** — **Quinn HIC staged ($7,751, start Aug 2026; SEND HELD pending DSPS cert/GL)** + job numbers re-based to the QBO invoice series (migration 012, [[sow-job-number-system]]): Overbeck CWDB-2026-043, Quinn CWDB-2026-044, next = 045. QBO Contracts upload is manual (no API; Playwright blocked at Intuit login).

- **2026-07-05** - **FULL BUSINESS AUDIT + PIVOT VERDICT ADOPTED** (full detail: `_vault/briefs/2026-07-05-audit.md`). Phase 1 CLOSED construction-first (Validation Gate above); Google stays $30/day, Meta PAUSED (campaign 120241408537330461; re-enable = one flip after Pixel Lead fix); control plane RETIRED (weekly 15-min review replaces daily ritual); SBG unlock triggers adopted (Yde Law scoping). Corrections: GL insurance bound ~6/25 ($1M/$2M CGL); Overbeck collected in full $2,800; INV-2026-044 Garcia sub-labor $800 paid; QBO YTD +$1,550; 15 real lifetime leads (paid ads >=4); Petersen/Hanson/Neely dropped by TCPA gate (backfilled 7/6). `/business-audit` skill created + wired into cwdb-ceo-operator (quarterly).

- **2026-07-09/11** — **Estimator v2 SIMPLE-LABOR pricing model LIVE (cutover 2026-07-11, commit 2591b04 on test-branch + main)** [[estimator-v2-explicit-labor]]: `price = materials(true Wausau cost)/(1-30%) x market_load + labor at face + allowances at face`. Labor = SIMPLE CREW-DAYS (days table in the JSON, +1 contingency day every job, 0.5-day rounding) printed literally as "N days x 3 crew x 8 hrs @ $125/hr"; **margin on MATERIALS ONLY**; **all client figures round to nearest $50**. Diamond Piers $150; **never assume Menards 11% rebate**; Excel attachment replaced by Materials & Hardware List PDF (piece-level takeoff). Reference deck: $31,950 ($12,000 labor). Gate: `pricing-db-v2.json` status draft->active (one-line rollback); v1 frozen as audit. Calibration flags: stain +150% / fence +59% vs v1 - review before flipping. Tests: `sales/estimating/test_engine_v2.py` (16); harness: `verify_engine.py` (v1-vs-v2 table + confidence audit replaces CONFIRM WITH JOHN).

- **2026-07-06** — **CWDB HQ dashboard SHIPPED** [[cwdb-hq-dashboard]]: 4-tab Streamlit app (`operations/dashboard/`, launcher port 8511) + read-only Streamlit Cloud twin (anon key + RLS, views/008-009; service key never leaves laptop). Audit fixes #6 (consent gate → `consent_missing` flag; Petersen/Hanson/Neely backfilled, Petersen = PAID_SOCIAL via new `hs_analytics_source` column) and #15 (v_pl_monthly rebuilt: phantom fee dead, QBO construction leg; June = $3,605 rev vs $1,179 spend) shipped as phase 1. 6 construction-era KPI views (`v_kpi_*`). QBO pull `pull-qbo-financials.ps1` → fin_* tables. 28 audit fixes seeded into `dashboard_tasks` (4 pre-done). Two-way loop: dashboard_events + SessionStart hook + `/dashboard-sync` + `/counsel` skills. Board-of-counselors pipeline (agents → CEO → 5 lenses → chairman) via `run-counsel.ps1` headless. Also: pull no longer wipes lead_score; v_clean_leads PII hole closed (was definer-rights).

- **2026-07-22** - **CLEAR-THE-BOARD SESSION** (21 open dashboard tasks worked in one session; Jim residuals in `_vault/briefs/2026-07-22-jim-checklist.md`). Durable changes: (1) control plane FORMALLY retired (operations/control-plane/RETIRED.md; Make 5361099+4792854 dead, approval #61 rejected; key rotation pending Jim). (2) Cron laptop-coupling ACCEPTED by Jim + `\CWDB\CWDB-Warehouse-Catchup` logon guardrail (runs only if last success >24h). (3) Lead scoring engine live: `lead_scores` side table (migr 016) + scoring-rules.json v2 drive-time rubric; pull-proof. (4) views/010: lead 5 excluded; **19 clean leads**. (5) TCPA: "Assumed" consent option RETIRED in HubSpot; Petersen consent BACKFILLED with Webflow-record evidence (she checked the box; transport lost it in FB in-app browser). (6) Relay 2.1.0 + attribution keeper live site-wide (beacon-first; hubspot_form_relay lineage retired), gateway v11 forwards hutk/fbclid. (7) Google Ads: conversion silent since 6/10 = on-page form-success signal broke (form rebuild day), NOT ads config; primary+dedupe already correct; GBP demotion is UI-only (not API-mutable). (8) Site repositioned as deck CONSTRUCTION company + licensed/bonded/fake-testimonial/fake-aggregateRating purge + /privacy published + ToS rewritten (liability cap scoped to website use, ATCP 110 carve-out); all drafts Yde-review-gated. (9) Terminations (kill 12-mo tail, Jim signs personally) + subcontractor master agreement drafted for Winchester Aug 17. (10) QBO net income YTD $6,698; reserve $2,350; Q3 1040-ES $2,350 due 9/15; HOLD Koy/Peksa deposit collection until DSPS cert. (11) Zombie WB board archived (_vault/board/archive/); dashboard_tasks sole canonical list. (12) Branch policy: test-branch canonical, merge to main for parity.

## Detail Files (this directory; link with `[[name]]`)
[CWDB HQ dashboard](cwdb-hq-dashboard.md) · [Pivot 2026-04-19](pivot-2026-04-19.md) · [Hormozi Framework](hormozi-framework.md) · [Cron warehouse daily](cron-warehouse-daily.md) · [Google OAuth 7-day trap](google-oauth-testing-mode-7day-trap.md) · [Phase F IDs](phase-f-ids.md) · [Vault RAG architecture](vault-rag-architecture.md) · [Deck estimator tool](deck-estimator-tool.md) · [Estimator app live](estimator-app-live.md) · [v_clean_leads test-exclusion gap](v-clean-leads-test-exclusion-gap.md) · [Schedule: Supabase routine-eligible — RESOLVED](schedule-supabase-not-routine-eligible.md) · [SOW + Job Number system](sow-job-number-system.md) · [PS7 Invoke-RestMethod non-enumeration trap](ps7-invoke-restmethod-non-enumeration.md) · [Fulfillment model pivot](fulfillment-model-pivot-2026-06-10.md) · [Phone leads count](phone-leads-count.md) · [Control plane Inc 2-5 rollout](control-plane-inc2-5-rollout.md) · [iOS Safari dark inputs](ios-safari-streamlit-dark-inputs.md) · [Streamlit secrets location](streamlit-secrets-location.md) · [SBG Construction Group](sbg-construction-group.md) · [Dashboard babysitter port-aware](dashboard-babysitter-port-aware.md) · [Lauren Yde (SBG attorney)](contact-lauren-yde.md) · [Estimator v2 explicit labor](estimator-v2-explicit-labor.md)

## Per-Agent Memory (platform quirks live here, not in this file)
- `~/.claude/agent-memory/web-dev/` — Webflow MCP quirks, iOS Safari bugs, Playwright MCP, script slot constraints
- `~/.claude/agent-memory/ad-campaign/` — Google Ads cold-start, callout Row type, Meta bulk-import gate, account-identity gotcha
- `~/.claude/agent-memory/cwdb-ceo-operator/` — PowerShell portability, OAuth 7-day trap, state-merge protocol
- `~/.claude/agent-memory/contractor-sales/` — DocuSign user/account IDs, contractor roster
- `~/.claude/agent-memory/accounting/` — CPA mandate, tax calendar, S-Corp decision, draft COA, billing terms, QBO API facts + setup checklist, WI sales-tax analysis (12 files, built 2026-06-09)

## Memory Update Discipline
- When the warehouse schema changes → update this file's Source of Truth section
- When a standing rule emerges → add to Standing Rules with `[[detail-file]]`; do not duplicate content
- When a deprecated path / file is created → grep for refs first, update them; do not leave dangling
- At end of major session → `/session-end` writes Work Done + Decisions to today's session note; THEN consider whether MEMORY.md needs a one-line addition
