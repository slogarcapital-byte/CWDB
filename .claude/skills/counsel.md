---
name: counsel
description: Convene the CWDB board of counselors - specialty agents pull live numbers, the CEO synthesizes a strategy brief, five conflicting lenses review it, and an independent chairman issues the verdict and recommended moves. Writes a counsel JSON for the CWDB HQ dashboard. Invoked by the dashboard's Convene-the-Board button (headless) or manually.
---

# Counsel — Board of Counselors strategy review

Pipeline (per Jim's 2026-07-06 design): **agents feed the CEO, the CEO feeds
the board, the board's chairman sets the strategic recommendations.** The five
lenses are ported from the retired control plane's council
(`operations/control-plane/workflows/council.mjs`), re-aimed at the
construction-era goal.

## Arguments

Invocation may pass `run_id=<N> out=<path>`. If absent: insert your own
`counsel_runs` row (status `running`) to get a run_id, and default the output
path to `_vault/counsel/<yyyy-MM-dd-HHmmss>.json`.

## Steps

### 1. Pull the live numbers (no narrative sources)

Query Supabase (project `iabiwsbmnbxmkjvkgfhg`; MCP tool, or PostgREST via
Bash with the service key from `.env.local` when MCP is unavailable in
headless mode):

- `v_kpi_booked_revenue`, `v_kpi_job_profitability`, `v_kpi_close_rate`,
  `v_kpi_cost_per_booked_job`, `v_kpi_backlog`, `v_lead_funnel` (last 3 months)
- `fin_position` (latest row), `fin_pl_monthly`
- `dashboard_tasks` open P0/P1 counts by owner_group
- latest `audit_findings` strategy row (baseline strategy of record)

Save this bundle - it becomes `kpi_snapshot` in the output.

### 2. Specialty agents report (parallel, read-only)

Launch in ONE message: `accounting`, `contractor-sales`, `ad-campaign`,
`lead-qualification` (add `legal-compliance-counsel` if legal state changed
since the last run). Each gets the KPI bundle and returns a <=200-word domain
read: what changed, what is working, the one move they would make now.

### 3. CEO synthesizes the strategy brief

Launch `cwdb-ceo-operator` with the KPI bundle + all domain reads. It returns
a strategy brief (<=500 words): current-state assessment, the 3 highest-leverage
moves with expected impact, and what it would STOP doing. This brief is what
the board reviews.

### 4. The board: five conflicting lenses (parallel, anonymized)

Launch 5 `general-purpose` agents in ONE message. Each receives the CEO brief
AND the KPI bundle, plus its lens. Tell each: "Lean fully into your angle; do
not soften or balance it - the council gets diversity from each advisor being
one-sided. Write 150-300 words."

1. **Contrarian** - Hunt for the FATAL FLAW. What is wrong, missing, or will
   fail in this brief? Assume it is broken and find where.
2. **First Principles** - Ignore the surface plan. Does this brief solve the
   ACTUAL problem? Reason from the underlying goal: maximize booked
   construction revenue and gross profit per job via the owned lead engine.
3. **Expansionist** - What upside is left on the table? Is this brief
   UNDERAMBITIOUS relative to the goal?
4. **Outsider** - Zero project context. React only to what is literally in
   front of you, as a Wausau homeowner or a small-town contractor would.
5. **Executor** - One question only: is this plan EXECUTABLE this week by one
   person, and if not, what is the single concrete next step?

### 5. Chairman verdict (independent - NOT the CEO)

Launch ONE more `general-purpose` agent as chairman. Input: the CEO brief +
the five lens outputs ANONYMIZED (label them Advisor A-E in rotated order;
strip lens names). The chairman returns:

- `chairman_verdict` (<=300 words): what stands, what falls, what changes
- `recommended_moves`: 3-5 moves as JSON objects
  `{title, detail, owner_group: jim|project|others, priority: P0|P1|P2, suggested_agent}`
- `exec_summary` (<=150 words): the state of the business + the verdict, in
  plain language - this replaces the dashboard's exec summary

### 6. Write the output JSON

Write to the output path:

```json
{
  "run_id": <N>,
  "exec_summary": "...",
  "ceo_brief": "...",
  "lens_outputs": [{"key": "contrarian", "name": "Contrarian", "text": "..."}, ...5],
  "chairman_verdict": "...",
  "recommended_moves": [{"title": "...", "detail": "...", "owner_group": "jim", "priority": "P0", "suggested_agent": null}],
  "kpi_snapshot": { ...the step-1 bundle, condensed... }
}
```

If invoked WITHOUT a runner (manual /counsel), also upsert the row yourself:
PATCH `counsel_runs` run_id row with all fields + `status=complete`, and
append a `counsel_convened` dashboard_events row (processed_at=now()).
If a runner invoked you (run_id passed), the runner does the upsert - just
write the file.

## Failure discipline

If any stage fails, still write the JSON with whatever completed and an
`"error"` field describing what is missing. A partial counsel beats a silent
one.
