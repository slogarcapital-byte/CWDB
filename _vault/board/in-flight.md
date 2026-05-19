# In Flight — Work has owner + acceptance criteria

> Items here are actively being built. Each must have: owner, acceptance criteria, ship type.
> If something stalls 7+ days without progress, CEO surfaces it in the daily brief Mentor Check.

---

## Active

- [WB-001] Build HubSpot lead-routing Workflow
  - Owner: Jim (25-min UI build) — Path A (programmatic) ruled out 2026-05-05; HubSpot Workflows API requires Marketing Hub Pro+ ($800+/mo) and is not exposed by the HubSpot MCP toolkit on Starter tier.
  - Walkthrough: `operations/automation/hubspot-build/WB-001-jim-clicks.md` (5 sections, 25 min, click-by-click w/ acceptance checks per section)
  - **NEW 2026-05-07 — Post-flight harness:** `operations/automation/hubspot-build/WB-001-postflight.md` (6 atomic pass/fail checks, fresh smoke submit, rollback path)
  - Underlying spec: `operations/automation/hubspot-build/04-lead-routing-workflow-spec.md`
  - Status: in-flight (Day 3 of carry as of 2026-05-07) — walkthrough + post-flight harness both ready, awaiting Jim's HubSpot UI session
  - Acceptance: workflow active in HubSpot; fires on form submit; creates Deal in pipeline `2247158458` at "New Lead" stage `3610478270`; associates Deal to Contact; fires notification email to Jim; **post-flight harness all 6 checks PASS**
  - Ship type: scheduled-recurring-automation
  - Priority: **CRITICAL-PATH** — sole remaining gap before fully automated end-to-end leads
  - Notes: %% 5 real homeowner contacts already in HubSpot from 2026-05-05; all currently sitting without auto-created deals (Jim hand-built 5 deals manually). Once this ships, future form submits auto-route. v2 routing branch (city → contractor) deferred until volume justifies. Day 3 of carry — 25 min Jim UI session is the ONLY remaining gate. %%

- [WB-003] Pull Google Ads MTD numbers (or replace with API integration)
  - Owner: analytics agent + Jim (UI session) OR analytics agent alone (after WB-011 ships)
  - Status: in-flight (since 2026-04-25) — **6+ sessions overdue**
  - Acceptance (interim): Jim pastes MTD numbers (cost, impressions, clicks, CTR, conversions, cost/conv) for date range 2026-04-23 → today into the daily brief once
  - Acceptance (long-term): superseded by WB-011 (API integration)
  - Ship type: artifact-prod (data) → eventually scheduled-recurring-automation
  - Notes: %% Week-1 review was Mon 2026-05-04 = OVERDUE. Either Jim pulls or kills the ask. CEO ships WB-011 in parallel. %%

- [WB-004] Confirm payment rails for first $1,000 invoice
  - Owner: accounting agent + Jim
  - Status: in-flight (since 2026-04-19)
  - Acceptance: Jim confirms which payment method (QBO Payments / Venmo / Zelle / check) handles the first $1,000 contractor referral invoice; documented in `/finance/invoices/payment-rails.md`
  - Ship type: artifact-prod
  - Notes: %% Decision made 2026-05-04: QBO Payments primary, Venmo backup. Ship blocker: QBO must be live (see WB-010). %%

- [WB-008] Paste HubSpot Pipeline ID + Stage IDs into config
  - Owner: Jim
  - Status: in-flight (since 2026-05-05) — quick task
  - Acceptance: `operations/automation/hubspot-lead-pipeline.json` populated with pipeline_id `2247158458` and all 9 stage IDs from `_vault/reality-2026-05-05.md`. Note: stage IDs already known via reality memo — analytics agent can populate from that source without Jim's UI session.
  - Ship type: artifact-prod
  - Notes: %% Pipeline ID 2247158458. Stage IDs: 3610478270 New Lead · 3610478271 Qualified · 3610478272 Scheduled/Delivered · 3610415826 Creating Bid · 3610415827 Delivered Bid · 3610478273 Accepted Bid · 3610478275 Expired Bid · 3610478274 Won · 3610478276 Lost. Already documented in reality memo — task downgraded to analytics-agent autopopulation. %%

- [WB-010] QBO Payments live before Nayak invoice (deadline 2026-05-12)
  - Owner: accounting agent + Jim (Quickbooks setup)
  - Status: in-flight (since 2026-05-04)
  - Acceptance: QBO Payments processor live + tested; first invoice for Nayak ($4,900 deposit) sendable
  - Ship type: build (QBO config)
  - Deadline: 2026-05-12 (7 days)
  - Notes: %% Hard deadline — Nayak job requires deposit collection. %%

- [WB-011] Google Ads + Meta + GA4 API integration (auto-pull scripts)
  - Owner: analytics agent (scripts) + Jim (credentials creation)
  - Spec: see plan file Phase 2b at `C:\Users\jslog\.claude\plans\cwdb-ceo-operator-agent-once-again-hazy-shamir.md`
  - Status: in-flight (since 2026-05-05) — **scaffolding SHIPPED 2026-05-05, blocked on Jim credentials**
  - Acceptance: Three PowerShell pull scripts at `templates/scripts/pull-{google-ads,meta-ads,ga4}-*.ps1`; daily cron at 6:55 AM Central writes JSON to `_vault/data/{google-ads,meta-ads,ga4}-latest.json`; brief skill reads and renders auto-tables; manual paste retired
  - Ship type: scheduled-recurring-automation
  - Scaffolded (DONE by analytics agent 2026-05-05):
    - `templates/scripts/pull-google-ads-mtd.ps1` (REST + OAuth2 refresh-token pattern, GAQL MTD at customer level)
    - `templates/scripts/pull-meta-ads-mtd.ps1` (System User token, /insights at account level, MTD)
    - `templates/scripts/pull-ga4-7d.ps1` (Service Account JWT, runReport on property 533582902, last 7d)
    - `templates/scripts/.env.example` (full env-var schema, repo-root `.env.local` already gitignored)
    - `operations/automation/api-credentials/README.md` (50-70min runbook: dev token apply, OAuth client, refresh token script, System User, Service Account, GA4 grant, troubleshooting)
    - Cron registered: `55 6 * * *` America/Chicago, durable, runs all three scripts (cron job ID logged in CEO operator session memory)
    - Brief skill `_vault/.claude/commands/brief.md` step 3 already reads the three JSON files (Phase 1.6 pre-wire confirmed) — no changes needed
    - Architecture memory: `.claude/agent-memory/cwdb-ceo-operator/api-pull-architecture.md`
  - **Blocked on Jim** (specific credentials he must create per README sections):
    - §1a Apply for Google Ads developer token (24-72h wait), paste `GOOGLE_ADS_DEVELOPER_TOKEN`
    - §1b-c Create OAuth2 Desktop client + run refresh-token snippet, paste `GOOGLE_ADS_CLIENT_ID`, `GOOGLE_ADS_CLIENT_SECRET`, `GOOGLE_ADS_REFRESH_TOKEN`
    - §2 Generate Meta System User long-lived token, paste `META_ACCESS_TOKEN` and `META_AD_ACCOUNT_ID`
    - §3 Create GCP Service Account + JSON key, grant Viewer on GA4 property 533582902, paste `GA4_SERVICE_ACCOUNT_JSON` (absolute path)
  - Notes: %% Tier 2 — agents did scaffolding, Jim creates API credentials. ~50-70 min hands-on + 24-72h Google dev-token wait. Once Jim pastes envs, all three scripts run green and the brief auto-renders Live Data Tables every morning. %%

- [WB-012] Daily brief auto-generation cron (7am Central)
  - Owner: CEO operator (this session)
  - Status: in-flight (since 2026-05-05)
  - Acceptance: CronCreate task scheduled at `0 7 * * *` America/Chicago; fires brief skill autonomously; today's brief lands at `_vault/briefs/<today>.md` without Jim invoking
  - Ship type: scheduled-recurring-automation
  - Notes: %% Phase 2 of CEO-lag-fix plan. %%
