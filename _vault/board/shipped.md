# Shipped — Done, live, or running

> Append-only history of completed work. Tag every item with one of three ship types:
> `build` · `artifact-prod` · `scheduled-recurring-automation`

---

## 2026-05-11

- **Shipped Without Asking — WB-002 GMB → parked** — `artifact-prod`
  - Authority: 24h default-ship rule + WB-015 directive (logged 2026-05-10).
  - Day-of-carry at default: 11 (proposed-park 2026-05-09; zero `%...%` reply across Days 9-11).
  - Decision: PARK (not kill) — preserves GMB account assets; walkthrough archived; reversibility cost asymmetric.
  - Files touched: `_vault/decisions/wb-002-gmb-park.md` (status → PARKED + Default-Ship Log appended); WB-002 moved from `_vault/board/in-flight.md` to `_vault/board/killed.md` "Parked (not killed)" subsection.
  - Un-park triggers: (1) first accepted bid closes, (2) Debbie resolves `%real%` + closes within 30d, (3) $5K MRR, (4) Jim books a 30-min GMB block.
  - Rollback: edit decision file status header back to `STATUS: ACTIVE` and move WB-002 entry from killed.md back to in-flight.md.

- **Day 7 quiet — three primary unsent artifacts intact** — `artifact-prod` (verification)
  - Verified at 2026-05-11: `sales/outreach/jim-self-outreach-2026-05-09.md` (WB-014 single-question outreach) · `_vault/contingencies/debbie-overlook-soft-outreach.md` (Day 1 soft outreach) · `_vault/experiments/2026-05-07-volume-drought/c-manual-paste.md` (manual-paste fork). All present, frontmatter current. No drift.

## 2026-05-09

- **WB-014 single-question outreach drafted** — `artifact-prod`
  - `/sales/outreach/jim-self-outreach-2026-05-09.md` — 94-char question + HubSpot link to contact `483345261285`; ready-to-paste copy for Jim-to-Jim text/email
  - Reply path defined: `%real%` / `%test%` / `%unsure%` on brief §6
- **Debbie Overlook real-lead contingency pre-staged** — `artifact-prod`
  - `_vault/contingencies/debbie-overlook-real-lead-playbook.md` — 5-step routing path (deal create, Ben primary / John secondary, homeowner SMS template, testimonial gate, logging); activates only on `%real%`
- **WB-002 GMB park-not-kill decision proposed** — `artifact-prod`
  - `_vault/decisions/wb-002-gmb-park.md` — rejects today's brief `%kill%` rec on reversibility grounds; proposes park with 4 named un-park triggers (first close, Debbie close, $5K MRR, Jim time-block)

## 2026-05-08

- **WB-011 cascade re-verified** — `artifact-prod` (re-verification, not new ship)
  - `templates/scripts/.env.example` (11 env-var names) matches `pull-google-ads-mtd.ps1` + `pull-meta-ads-mtd.ps1` + `pull-ga4-7d.ps1` exactly
  - `operations/automation/api-credentials/README.md` walkthrough current; customer ID `7129910870` pre-filled
  - WB-001 walkthrough + post-flight harness both readable at `operations/automation/hubspot-build/WB-001-jim-clicks.md` + `WB-001-postflight.md`
  - Net: cascade still hot. Jim's 5-min dev-token submit triggers downstream credential paste with zero rework.

- **Shipped Without Asking — auto-brief time confirmed at 7:00 AM Central** — `scheduled-recurring-automation`
  - Authority: 24h default-ship rule (CWDB CLAUDE.md operator clause). Decision carried 3+ days with CEO recommendation `%confirmed%` and no `%...%` resolution.
  - Confirmed via `CronList`: `f832a6f0` runs daily at 7:03 AM Central (`/brief` skill); `4d213bd3` runs at 6:55 AM Central (ad-platform pull pre-stage). Both `[session-only]`, recurring.
  - Note on time: actual brief generation runs 7:03 AM (3-min offset to let the 6:55 data pull complete). Not 7:00 AM as worded in §5 — close enough; flagging for transparency.
  - Rollback: edit the cron schedule via `CronCreate`/`CronDelete`.

- **Shipped Without Asking — email hosting decision (path a)** — `artifact-prod`
  - Authority: 24h default-ship rule. WB-009 carried 14+ days with CEO recommendation `%a%` and no `%...%` resolution.
  - Decision: skip alias; use `slogarjw@gmail.com` with reply-to set to `info@cwdeckbuilders.com`. No MX, no paid mailbox.
  - Logged at `finance/admin/email-hosting-decision.md` with rationale, reversibility, and re-evaluate trigger (first close OR $5K MRR).
  - Rollback: delete the file; reopen WB-009.

## 2026-05-07

- **WB-001 post-flight verification harness** — `artifact-prod`
  - `operations/automation/hubspot-build/WB-001-postflight.md` — 6-step pass/fail checklist Jim runs immediately after toggling workflow ON; fresh smoke submit + 5 atomic CRM checks + rollback path + standing warning about the "re-enroll existing" toggle
  - Companion to `WB-001-jim-clicks.md`. Reduces post-activation risk from coarse "did it work" to atomic per-property verification

- **Volume-drought experiment one-pagers (3 forks)** — `artifact-prod`
  - `_vault/experiments/2026-05-07-volume-drought/README.md` — index + recommended sequence
  - `a-budget-bump.md` — $30→$60/day, 7-day Lever 1 volume-floor test ($210 incremental, 7-day evidence)
  - `b-smoke-test.md` — fresh mobile + desktop submit, ~$0, 15-min evidence (run first)
  - `c-manual-paste.md` — 5-min Google Ads UI status + 6-metric paste, $0 (run second)
  - Reduces Jim's decision cost from "design the experiment" to "pick a folder"

- **WB-011 scaffolding verified end-to-end** — `artifact-prod` (verification, not new ship)
  - `.env.example` confirms 11 env-vars match `pull-google-ads-mtd.ps1` exactly
  - `operations/automation/api-credentials/README.md` is current (50-70 min runbook)
  - `templates/scripts/pull-google-ads-mtd.ps1` reads `GOOGLE_ADS_DEVELOPER_TOKEN`, `_CLIENT_ID`, `_CLIENT_SECRET`, `_REFRESH_TOKEN` exactly as named in `.env.example`
  - Customer ID `7129910870` pre-filled
  - **Net:** zero new minutes of Jim work added. Jim's 5-min dev-token submit + ~25 min credential pasting cascades into a working pull immediately.

## 2026-05-05

- **HubSpot Forms API direct-fetch relay** — `build`
  - `website/scripts/hubspot_form_relay-1.0.0.js` (4761 bytes) + `.min.js` (2038 bytes)
  - Capture-phase submit listener on `form#wf-form-Quote-Request` → POST to HubSpot Forms API (HUB_ID 245712220, FORM_GUID `bb473d64-06b1-4311-8e02-7c70d605b79b`) with `keepalive: true`
  - Webflow App disconnected (was source of "could not get/set child form element ID" error)
  - **Verified live in production:** captured 5 real homeowner contacts in an 8-minute window 07:40 → 07:48 UTC
  - Deployed to production with Jim's `%%confirmed%%` mark

- **HubSpot Homeowner Leads pipeline (9 stages) + 19 custom properties** — `build`
  - Pipeline ID `2247158458` — 9 stages live (Jim added 3 to original 6-stage spec: Creating Bid, Delivered Bid, Expired Bid)
  - 11 Contact Properties (form-fillable lead details) + 8 Deal Properties (workflow-managed lifecycle)
  - Architecture correction logged: forms populate Contact only, workflow creates Deal + associates to Contact
  - All 3 dropdowns (project_type, project_timeline, budget_range) aligned to Webflow form's slug values

- **HubSpot Phase 0 gate test** — `artifact-prod` (verification)
  - PASS confirmed 2026-05-05 02:16 EDT via Plan A (Non-HubSpot Forms tracking)
  - Superseded with Plan B (Forms API direct fetch) for deterministic field mapping

- **Reality reconciliation memo** — `artifact-prod`
  - `_vault/reality-2026-05-05.md` — full forensic capture of 5 contacts + 5 deals in HubSpot
  - Memory entry `5-leads-and-4-deals-on-2026-05-05.md` with `priority: load-on-every-session`

## 2026-04-30

- **HubSpot Free → Starter Customer Platform** — `artifact-prod` ($15/mo, 25% promo)
- **Make scenario `4792854` permanently DEAD** — `artifact-prod` (cleanup; superseded by HubSpot Starter native connectors)
- **Google My Business account live + instant verification** — `artifact-prod`
- **5 paste-ready specs shipped** — `artifact-prod`
  - `marketing/gmb/profile-spec.md`
  - `marketing/gmb/initial-content-pack.md`
  - `operations/automation/hubspot-build/01-pipeline-stages.csv`
  - `operations/automation/hubspot-build/02-deal-properties.csv` (later replaced with `02-contact-properties.csv` + `03-deal-properties.csv`)
  - `operations/analytics/phase-0-gate-spec.md`
  - `operations/analytics/a1-enhanced-conversions-spec.md`

## 2026-04-25 → 2026-04-28

- **Tracking ID audit + reconciliation** — `artifact-prod` (2026-04-25)
- **Primary conversion swap** (`from_submit_quotes` → Primary) — `build` (2026-04-25)
- **Google Ads campaign un-paused on corrected attribution** — `scheduled-recurring-automation` (2026-04-25; ~12 days running at $30/day as of 2026-05-05)
- **Phone Ben + John for proof completed** — `artifact-prod` (2026-04-28; both confirmed zero testimonials → Lever 4 structurally blocked)
- **WS-3 hookify rule (session-end-required) shipped** — `scheduled-recurring-automation` (2026-04-28)
- **Meta pixel `4411592295757520` decoupled from all ad accounts** — `artifact-prod` (2026-04-28)

## 2026-04-23

- **Google Ads LIVE — first ad spend in CWDB history** — `scheduled-recurring-automation`
  - Campaign `CWDB — Search — Launch 2026-04`
  - Customer `712-991-0870` · Conversion ID `AW-18113251301/PgcJCL_ck6IcEOWPib1D`

## 2026-04-21

- **Hero-form handoff bug FIXED** — `build` (`hero_form_handoff` v1.0.0 capture-phase JS)
- **Site revamp Phase 2 + 3 + 4 complete** — `build` (homepage spine + form wizard + 11 page rebuilds)
- **Launch package shipped** — `artifact-prod` (`/marketing/launch-2026-04/`, hook audit 11/11 PASS)

## 2026-04-18 → 2026-04-19

- **GTM container published; cwdeckbuilders.com live** — `build` (2026-04-18)
- **DNS cutover** (cwdeckbuilders.com → 301 → www.) — `build` (2026-04-18)
- **Make + Twilio parked** — `artifact-prod` (2026-04-19, decision)
- **Barton + Garcia HubSpot deals → closedwon** — `artifact-prod` (2026-04-19, MCP)

## 2026-04-17

- **Contractor agreements signed** — `artifact-prod` (Ben Barton + John Garcia, DocuSign PDFs in `/sales/contractor-agreements/`)

## 2026-04-02 → 2026-04-03

- **Webflow design system + homepage** — `build` (2026-04-02)
- **All 5 city pages + About/FAQ/Gallery/Our Builders/Blog/Calculator** — `build` (2026-04-03)

## 2026-03-28

- **Brand finalized** — `artifact-prod` (CWDB name, cwdeckbuilders.com domain, logos, color palette)

## 2026-03-12

- **First contractor committed to $1,000/accepted bid** — `artifact-prod` (Ben Barton)
