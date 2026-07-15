# Central Wisconsin Deck Builders (CWDB) Operating System

## Source of Truth

**Live business state lives in the Supabase data warehouse, not vault files.** Query Supabase first; treat briefs / state-archive / MEMORY.md as derived, not authoritative.

- **Supabase project:** `iabiwsbmnbxmkjvkgfhg` (`https://iabiwsbmnbxmkjvkgfhg.supabase.co`)
- **Schema:** `operations/data-warehouse/schema/` (12 tables, 6 analytical views)
- **Daily refresh:** Task Scheduler `\CWDB\CWDB-Warehouse-Daily` at 06:55 Central runs `operations/data-warehouse/scripts/run-daily.ps1`; pulls HubSpot + Google Ads + Meta Ads + GA4
- **Last-run log:** `_vault/data/cron-runs.log` (TSV; non-zero exit = failure)

### Daily Read (in order)

1. **Lead funnel:** query `v_lead_funnel` for submitted → qualified → delivered → bid-sent → accepted → paid counts
2. **CAC by channel:** query `v_cac_by_channel` for spend, leads, cost per lead by platform
3. **Attribution gap:** query `v_meta_attribution_gap` (UTM black hole diagnostic; flags Meta-vs-GA4 disagreement)
4. **Contractor scorecard:** query `v_contractor_scorecard` (win-rate, response time, fees earned)
5. **P&L:** query `v_pl_monthly` (ad spend vs. accepted-bid revenue)

The Supabase MCP tool is authorized; pull live numbers before claiming any business-state fact.

## Phase 2: Construction Profitability (Phase 1 CLOSED 2026-07-05 with pivot verdict)

- **Verdict (adopted by Jim 2026-07-05):** the pay-per-accepted-bid contractor model is unproven (0 acceptances, $0 fees ever invoiced) and is parked as a secondary overflow product. The validated model is **self-perform construction fed by CWDB's owned lead engine** (Overbeck closed + collected $2,800, Garcia sub-labor $800, break-even YTD).
- **Phase 2 targets:** licensed (DSPS) + insured (GL scope confirmed), 2-4 booked jobs/month, measured funnel.
- **KPIs:** `v_kpi_booked_revenue`, `v_kpi_job_profitability`, `v_kpi_close_rate`, `v_kpi_cost_per_booked_job`, `v_kpi_cycle_time`, `v_kpi_backlog` (audit section 2 set; CPL ceiling repriced to $300-500 under job-margin economics).
- Full audit + fix list: `_vault/briefs/2026-07-05-audit.md`. Fix-list execution is tracked in the CWDB HQ dashboard (below).

## Operating Rhythm

- **CWDB HQ dashboard (primary operating surface, 2026-07-06):** `pwsh operations/dashboard/launch-dashboard.ps1` (port 8511). Tabs: KPIs + exec summary + board of counselors, canonical to-do list (Complete/Defer/Decline/Send-to-Claude), platform diagnostics, QBO financials. Read-only phone twin on Streamlit Cloud. Docs: `operations/dashboard/README.md`.
- **Weekly 15-minute review** replaces the daily brief/session ritual (audit decision 2026-07-05): open the dashboard, work the to-do tab, convene the board when strategy needs a fresh read.
- **Two-way loop:** dashboard actions append `dashboard_events`; the SessionStart hook surfaces unprocessed events; `/dashboard-sync` ingests them. `/session-end` emits a `session_summary` event back to the dashboard.
- **Session start:** SessionStart hook creates `_vault/sessions/<today>-NNN.md`, scans cron log, surfaces env-var gaps, continuity context, and pending dashboard events. Read those before doing anything else.
- **Session end:** `/session-end` writes Work Done + Decisions + Memory Updates into today's session note. Hookify enforces non-empty Work Done.
- **Project board:** `_vault/board/*.md` are GENERATED mirrors of `dashboard_tasks` - edit via the dashboard, never by hand. `/brief` + `/state` remain optional troubleshooting surfaces.

## Memory Map

- **CLAUDE.md (this file):** how to navigate. Stable; rewrite quarterly or on architectural change.
- **`~/.claude/projects/.../memory/MEMORY.md`:** auto-loaded standing rules + key decisions (~80 lines). Detail files in same dir keyed by `[[name]]`.
- **`~/.claude/agent-memory/<agent>/MEMORY.md`:** per-agent learned constraints (platform quirks, gotchas). Read by that agent only.
- **`_vault/sessions/<date>-NNN.md`:** per-session log of work, decisions, open items. Chained via `previous-session` frontmatter.
- **`_vault/state-archive/state-<sessionId>.md`:** point-in-time snapshots written by `/session-end`. Historical record, not live state.
- **Supabase warehouse:** all live business state (leads, deals, ad spend, traffic). Query, don't cache.

## Default Delegation Hierarchy (CEO behavior)

Top-3 daily items classified by tier:
1. **Tier 1 (Recipe, default):** Specialty agent owns execution. CEO orchestrates.
2. **Tier 2 (Hybrid):** Mostly automated, minimal Jim touch.
3. **Tier 3 (User-driven):** Jim does this manually. Requires written justification.

When Agent tool is unavailable, CEO diagnoses + attempts fix first; if still blocked, BLOCK + FLAG. No silent fallback to direct execution.

**24h default-ship rule:** CEO ships autonomously at deadline, then writes a "Shipped Without Asking" entry in the brief listing what + where + how to roll back.

---

## Mission

Scalable lead-gen engine. Generate homeowner deck project leads in Central Wisconsin; sell them to contractors. Initial: deck builders, Wausau / Schofield / Weston / Mosinee / Merrill. Expansion (only after Phase 1 passes): Eau Claire, Appleton, Green Bay, Stevens Point, Madison, Minneapolis suburbs.

## Business Model

Revenue: **pay per accepted bid at $1,000** (contractor pays when homeowner accepts their bid sourced from a CWDB lead) **plus direct construction-services revenue** on jobs CWDB self-performs. Secondary models (territory licensing, multi-contractor marketplace) deferred to Phase 4+. Target margin: ~$700 per accepted bid.

### Fulfillment Model (pivot 2026-06-10)

Ben/John are busy building and cannot meet the 48-hour quote promise, so **Jim owns all lead follow-up, walk-through booking, walk-throughs, and estimates** (Streamlit estimator + `sales/estimates/generate_estimate_pdf.py`). Phased hybrid per legal-compliance-counsel opinion:

- **Phase 0 (now, pre-license).** Hand-off at the estimate. Two lanes, set via `fulfillment.lane` in the estimate JSON:
  - `cwdb`: cosmetic stain/resurface (no permit) — CWDB self-performs and takes the deposit. **Document: the combined estimate + work order (`combined: true` in the estimate JSON; standing rule 2026-06-11)** — one PDF, homeowner's signature converts it to the binding work order, e-signed via QBO Contracts (works on Essentials). The standalone staining work order is retired for new jobs. The two embedded Notice of Cancellation copies are legally required; never strip them.
  - `builder`: any build/repair/structural job — CWDB issues the estimate WITH the named-builder disclosure; the contractor signs the homeowner, takes the deposit, pulls the permit; CWDB collects $1,000 on acceptance. CWDB must NOT sign as prime or take a build deposit pre-license.
- **Phase 1 (after DSPS Dwelling Contractor cert + GL insurance).** Option B unlocks per-job: CWDB primes the Home Improvement Contract and subs to Ben/John under the subcontractor agreement. A and B run side by side; choose per job.
- Legal punch list and gating items: board directive WB-018.

### SBG Construction Group (under evaluation, 2026-06-18)

Jim is evaluating going full-time into construction with Ben Barton and John Garcia as **SBG Construction Group** (Slogar, Barton, Garcia): a shared-services / captive-labor group (NOT a merger). In Phase A the three existing LLCs stay independent and keep their own job profit, while shared SBG entities (SBG-Labor as an S-corp employing the crews and partners, SBG-Equipment, and a dormant SBG-RealEstate, owned 1/3 each and funded by equal cash) own the crews and equipment and bill the LLCs at market rates. Phase B (1 to 2 years out) would transition to a true merger where job profit pools 1/3, on rules decided now. Partners draw an $80/hr W-2 wage (derived billable rate ~$145/hr). Jim's lead engine stays CWDB's and is deliberately downplayed in all partner-facing docs. Full package and analysis: `business-context/construction-group/`. Memory: [[sbg-construction-group]]. Status: proposal stage, gated on a Wisconsin attorney + CPA. If pursued, it shifts CWDB from the lead-gen experiment toward a construction operating business.

### Leads count from EVERY channel

Phone calls arrive at the same volume as webform submissions and count identically toward the funnel and validation gate. All leads live in HubSpot; `fact_leads.lead_channel` (webform | phone | manual | other) + `tcpa_consent_source` (form | verbal | assumed) track arrival and consent. Phone leads may lack an email. Never treat "lead" as synonymous with "webform submission."

## Operating Principles

1. **Own the lead asset.** Contractors are replaceable. The lead flow is the asset.
2. **Validate demand before building infrastructure.** Do not build complex systems until contractors confirm willingness to pay. *(Active reminder: see Validation Gate above.)*
3. **Focus on one niche first.** Deck builders only until Phase 1 passes.
4. **Replicate profitable systems.** Clone the funnel into a new city only after the current city is profitable.
5. **Automation first.** Every repeatable operational task should eventually be automated.

## Tech Stack (current)

- **Site:** Webflow (21-page authority site at cwdeckbuilders.com, GoDaddy DNS)
- **Forms:** Webflow native → `jobtread-gateway` Supabase Edge Function (dual-writes JobTread + HubSpot + bronze; relay v2, 2026-07-14)
- **Jobs platform:** JobTread (estimating, proposals + e-sign, scheduling, native QBO sync; AI Connector MCP + Pave API; profile `_vault/platforms/JobTread.md`)
- **CRM (hybrid top-of-funnel):** HubSpot Starter ($15/mo); 9-stage pipeline; 19 custom properties; retires at JobTread cutover per `operations/analysis/jobtread-setup-design.md`
- **Ads:** Google Ads (live since 2026-04-23); Meta Ads (PAUSED 2026-07-05 pending Pixel Lead fix)
- **Community:** Nextdoor (organic only)
- **Analytics:** GA4 + GTM + Meta Pixel + Nextdoor Pixel + Google Ads Conversion + MS Clarity; JobTread webhook → `conversions_outbox` → Google offline conversions
- **Warehouse:** Supabase Postgres (daily ingestion, 6 sources incl. JobTread bronze)
- **Estimator:** Streamlit app at https://cwdb-estimator.streamlit.app/ (fallback during JobTread estimating cutover; retire after 2 clean JobTread jobs or 1 month)
- **Contractor onboarding:** DocuSign-driven parameterized agreement templates
- **Automation (parked):** Make scenario 4792854 inactive since 2026-04-19 pivot

## Brand

- **Name:** Central Wisconsin Deck Builders (CWDB internally)
- **Domain:** cwdeckbuilders.com
- **Tagline:** "Fast Quotes. Trusted Builders."
- **Colors:** `#e54c00` Crafted Orange (CTAs) · `#323434` Timber Slate (text) · `#646760` Builders Grey (secondary) · `#83b2cf` Wisconsin Sky Blue (accent)
- **Logos:** `/branding/logos/1.1-primary-logo-high-res.png` (stacked) · `/branding/logos/1.2-horizontal-logo-high-res.png` (horizontal)
- **Full guidelines:** `/business-context/brand-discovery/`

## File Structure

```
CWDB/
├── .claude/              Agents, skills, hooks, settings
├── _vault/               Obsidian vault — briefs, sessions, state-archive, board, data logs
├── branding/             Logos and brand assets
├── business-context/     Phase plans, brand discovery, validation roadmap
├── docs/legal/           LLC docs, EIN proof, contractor agreement templates
├── finance/              P&L, reports
├── marketing/            Ad campaigns (Google, Meta, Nextdoor, TikTok)
├── operations/
│   ├── data-warehouse/   Supabase schema, views, ingestion orchestrator
│   ├── leads/            Form specs, routing rules
│   └── make/             Parked scenario configs
├── sales/                Contractor outreach, onboarding, agreements, estimates
├── templates/scripts/    Hook scripts, data-pull scripts, vault-sync
└── website/              Webflow page content, design system, design docs
```

## AI Agent Roster

Specialty agents live in `.claude/agents/`. Each is invoked via the Agent tool. Agent-specific platform constraints live in `~/.claude/agent-memory/<agent>/MEMORY.md`.

- **cwdb-ceo-operator** — daily briefing, prioritization, decision-making (orchestrator)
- **web-dev** — Webflow page builds and edits (MCP-driven)
- **ad-campaign** — Google/Meta/Nextdoor/TikTok creative + targeting + optimization
- **content-writer** — page copy, email, sales scripts, blog
- **contractor-sales** — contractor outreach, onboarding, agreement sends
- **lead-qualification** — validate inbound leads
- **lead-routing** — deliver leads to contractors via HubSpot workflow
- **revenue-optimization** — pricing, ad spend allocation
- **accounting** — billing, P&L, reconciliation
- **analytics** — funnel diagnostics, attribution debugging
- **market-research** — niche / city expansion (Phase 3+)
- **legal-compliance-counsel** — compliance review, document drafting

Agents marked Phase 3+ should not be invoked until Phase 1 gate passes.

## Phase 1: Validation (active)

Goal: prove contractors pay $1,000 per accepted bid for CWDB leads.

| Step | Status |
|---|---|
| Secure first contractor commitment | DONE (2026-03-12, $1,000/accepted bid) |
| Confirm brand + domain | DONE (2026-03-28) |
| Build website | DONE (2026-04-21 site revamp complete) |
| Sign contractor agreements | DONE (Ben Barton + John Garcia, 2026-04-17) |
| Run ad campaign | LIVE (Google 2026-04-23, Meta 2026-04-26) |
| Deliver first lead via routing | NOT DONE (no HubSpot workflow yet) |
| Get first accepted bid | NOT DONE (0 since project start) |

Phase 1 CLOSED 2026-07-05 with pivot verdict: see the Phase 2 section at top.

## Phase 2: Profitability (gated on Phase 1 pass)

20-50 leads/month at <$60 CPL, >$1,000 revenue/accepted bid, 2x+ ROI.

## Phase 3: Replication (gated on Phase 2)

Clone funnel into a second city only after the first is profitable.

## Phase 4: Marketplace Expansion (long-term)

Multi-trade, multi-contractor marketplace (roofing, bathroom, concrete, basement finishing, pole barns). Comparable: Angi, Thumbtack.

## Success Metrics (queried from warehouse, not narrated here)

- Cost per lead: `v_cac_by_channel` (target <$60)
- Revenue per accepted bid: `v_pl_monthly` (target $1,000)
- Cost per accepted bid: derived (target <$400)
- Lead-to-accepted-bid conversion: `v_lead_funnel` (no target yet — need first accepted bid to measure)
- Contractor LTV: `v_contractor_scorecard`

## Strategic Advantage

Digital marketing capability + automation + a fragmented contractor market where most operators lack online presence. Owning the lead flow beats owning any one contractor.

## End State

Regional contractor lead marketplace across multiple trades and states. $50K-$150K/month at scale. Validated by Phase 1 first.
