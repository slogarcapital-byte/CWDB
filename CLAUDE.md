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

## Validation Gate (active)

- **Deadline:** 2026-06-18
- **Pass criteria:** `v_lead_funnel.qualified_count >= 3` since 2026-06-04 OR `v_lead_funnel.accepted_count >= 1` lifetime
- **Miss verdict:** call the pay-per-accepted-bid model unproven. Decide between pivot (pay-per-lead, marketplace) or sunset. Do not extend the gate a third time.
- **Why this matters:** 0 accepted bids since project start (2026-03-12). 0 new qualified leads in the 28 days from Debbie Overlook (2026-05-08) through today. OAuth refresh-token fix shipped 2026-06-04 was the last suspected funnel blocker; the gate measures whether the funnel actually works once unblocked.

## Operating Rhythm

- **Session start:** SessionStart hook creates `_vault/sessions/<today>-NNN.md`, scans `_vault/data/cron-runs.log` for last-24h failures, surfaces env-var gaps and continuity context. Read those before doing anything else.
- **Brief (optional, troubleshooting):** `/brief` skill generates `_vault/briefs/<today>.md` from Supabase + checkboxes. Useful when planning the day. Not the source of truth.
- **State (optional, troubleshooting):** `/state` skill patches live data tables into today's brief without rebuild.
- **Session end:** `/session-end` writes Work Done + Decisions + Memory Updates into today's session note. Hookify enforces non-empty Work Done.
- **Project board:** `_vault/board/{directives,in-flight,shipped,killed}.md` for Kanban; ship-type tags `build` / `artifact-prod` / `scheduled-recurring-automation`.

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
  - `cwdb`: cosmetic stain/resurface (no permit) — CWDB self-performs under the interim staining work order and takes the deposit.
  - `builder`: any build/repair/structural job — CWDB issues the estimate WITH the named-builder disclosure; the contractor signs the homeowner, takes the deposit, pulls the permit; CWDB collects $1,000 on acceptance. CWDB must NOT sign as prime or take a build deposit pre-license.
- **Phase 1 (after DSPS Dwelling Contractor cert + GL insurance).** Option B unlocks per-job: CWDB primes the Home Improvement Contract and subs to Ben/John under the subcontractor agreement. A and B run side by side; choose per job.
- Legal punch list and gating items: board directive WB-018.

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
- **Forms:** Webflow native → HubSpot Forms API relay JS
- **CRM:** HubSpot Starter ($15/mo); 9-stage pipeline; 19 custom properties
- **Ads:** Google Ads (live since 2026-04-23); Meta Ads (live since 2026-04-26)
- **Community:** Nextdoor (organic only)
- **Analytics:** GA4 + GTM + Meta Pixel + Nextdoor Pixel + Google Ads Conversion + MS Clarity
- **Warehouse:** Supabase Postgres (12 tables, 6 views, daily ingestion)
- **Estimator:** Streamlit app at https://cwdb-estimator.streamlit.app/ (built 2026-05-28; live 2026-05-31)
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

Active gate: see Validation Gate section at top.

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
