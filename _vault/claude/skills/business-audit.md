---
name: business-audit
description: Use when Jim asks for a full or partial audit of the CWDB business ("audit the business", "where do we sit", "are we hitting KPIs", "review all platforms", "health check"), or quarterly, or before any major strategic decision (pivot, SBG milestone, big spend change). Produces a verified state-of-business report with a prioritized fix list.
---

# CWDB Business Audit

Reproduce the structured audit first run 2026-07-05 (`_vault/briefs/2026-07-05-audit.md`). Core principle: **the mirror is guilty until proven innocent.** Do not audit the business from the warehouse views; audit the views against each platform of record first. Every claim in the deliverable must trace to a live query or API pull made during THIS audit, never to memory, vault narrative, or a derived view that has not been reconciled.

## Non-negotiable constraints

1. **Read-only throughout.** No platform changes, no file edits (except the deliverable itself), no git, no cron/scheduler changes. Every problem becomes a PROPOSED fix on the fix list. Jim approves line by line.
2. Any technically unavoidable write (e.g., persisting a rotated OAuth token to keep an API connection alive) is allowed but must be DISCLOSED in the report.
3. Subagents inherit the read-only mandate verbatim; put it in the first line of every interview prompt.
4. No em dashes anywhere (standing rule).

## Phase 0: Baseline recon (before asking Jim anything)

Ground yourself so questions are informed, not generic:
- Live warehouse queries: `v_lead_funnel`, `v_cac_by_channel`, `v_pl_monthly`, `v_contractor_scorecard`, `v_validation_gate` (or current gate view), `v_control_status`, raw `fact_leads` + `fact_bids` ledgers.
- One Explore agent: board files (`_vault/board/`), 3 newest session notes, `_vault/data/cron-runs.log` tail, git status summary.
- `Get-ScheduledTask -TaskPath "\CWDB\"` state + last/next run.

## Phase 1: Scope check-in with Jim (AskUserQuestion)

Ask, seeded with Phase 0 anomalies: (a) strategic frame the recommendations should optimize for, (b) how to treat any live anomaly found (e.g., spend running against broken tracking), (c) agent write permissions (default: read-only + fix list), (d) deliverable form (default: vault report + chat summary). In plan mode, write the plan file and get approval before executing.

## Phase 2: Instrument verification (platform of record vs mirror)

Reconcile every mirror against its source. Known drift patterns from 2026-07-05, re-check all of them:
- **HubSpot contacts vs `fact_leads`**: count and name-match; the pull's consent gate (`templates/scripts/pull-hubspot-snapshot.ps1`) has silently dropped leads before. Check `hs_analytics_source` on recent contacts; the warehouse only reads custom utm/gclid props.
- **QBO vs `v_pl_monthly`**: pull the live invoice register + P&L (accounting agent). The view has previously counted phantom referral fees and missed construction revenue entirely.
- **Google Ads / Meta / GA4 APIs vs warehouse spend + conversions**: three systems reporting three different conversion counts = broken measurement, not dead ads. Check conversion-action status, Pixel Lead events, GA4 key events.
- **Live site trace** (Playwright, test params, do NOT submit the form): attribution capture, tracking-tag inventory, compliance claims.
- **Cron log vs Task Scheduler vs today's date**: silent gaps make everything downstream stale.

## Phase 3: Agent interviews (parallel background batches of ~4)

Interview the roster relevant to scope; default: cwdb-ceo-operator, accounting, contractor-sales, web-dev, ad-campaign, legal-compliance-counsel, lead-routing, lead-qualification. Each prompt contains: (a) READ-ONLY mandate first, (b) the strategic frame, (c) verified Phase 0/2 findings for its domain (never unverified memory), (d) the standard questionnaire: domain state, KPI read, top 3 risks, top 3 highest-leverage changes under the strategic frame, kill list, fix list as `issue | severity P0-P3 | proposed fix | effort | owner`. Inject discoveries from completed interviews into later batches.

## Phase 4: Synthesis

1. **KPI scorecard**: target vs measured vs CORRECTED-reality columns; flag unmeasurable KPIs rather than reporting corrupted numbers.
2. **Corrections to the record**: every fact where memory/board/CLAUDE.md disagrees with verified reality.
3. **Consolidated fix list**: dedupe across all sources, P0 (this week, revenue or legal critical) / P1 (2 weeks, measurement + compliance) / P2 (this month, structure + hygiene), each with effort + owner.
4. **Strategy assessment** under Jim's frame, with a proposed verdict/decision wording where one is due.

## Phase 5: Deliver and decide

1. Write the report to `_vault/briefs/<YYYY-MM-DD>-audit.md` where the date is TODAY'S date (never reuse the date of a prior audit such as 2026-07-05; that file is the historical first run). Contents: exec summary, KPI scorecard, instrument diagnosis, platform findings, interview digests, strategy assessment, fix list, corrections, time-sensitive calendar items.
2. Executive summary in chat, leading with the single most consequential finding.
3. AskUserQuestion round on the major strategy calls surfaced (verdict wording, spend decisions, kill/retire decisions, next structural step).
4. Record Jim's decisions in the report (Decisions section) and MEMORY.md. Execute ONLY the actions Jim explicitly approved in that round; everything else stays on the fix list.
5. Run `/session-end`.

## Common mistakes

| Mistake | Fix |
|---|---|
| Quoting `v_lead_funnel`/`v_pl_monthly` as business truth | Reconcile against HubSpot/QBO first; report the corrected number |
| Concluding "ads don't work" from warehouse CPL | Trace the attribution chain end to end before judging spend |
| Interviewing agents with stale memory as context | Feed them THIS audit's verified findings |
| Executing fixes mid-audit because they're "obvious" | Fix list only; approval #per-item; the audit trail is the product |
| Report says "done" for items still pending Jim | Mark owner=Jim items explicitly; list time-sensitive dates |
