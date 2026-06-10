# CWDB Autonomous Control Plane

A durable, self-correcting control loop that pursues one goal - **maximize qualified leads, then accepted bids** - with minimal human touch. It wakes itself on a schedule, advances the goal one bounded step at a time, gates every output through an independent critic, holds irreversible actions for your approval, and halts itself on budget or breaker conditions. You clear an approval queue and read a daily digest. That's it.

## The one idea

This runtime has **no persistent daemon**. So the loop is not a running process - it is reconstructed from durable state every tick. Each tick reads control state from Supabase, advances it one step, writes it back, and exits. **State is the source of truth; the context window is disposable.** Two schedulers drive it:

| Layer | What | Cadence | Cost |
|---|---|---|---|
| **Control tick** (`control-tick.ps1`) | Deterministic watchdog: budget roll-up, circuit breakers, lease reaper (crash recovery), the gate, daily digest. Decides *whether* the loop may reason. | every 30 min, 06:00-22:00 CT | ~free (no LLM) |
| **Orchestrator tick** (`cwdb-orchestrator-tick` agent via `/schedule`) | The reasoning step: read state -> decompose -> route ONE task to ONE worker -> critic -> write back. Decides *what* to do. | every 2 h, 07:00-21:00 CT | model spend (budgeted) |

PowerShell decides whether to think; Claude decides what to think. You never want an LLM deciding whether the LLM may spend more money.

## Safety posture (read this)

- **Boots paused.** `control_state.run_mode` defaults to `paused`. Deploy everything; nothing reasons or spends until you run `control-power.ps1 on`.
- **Nothing irreversible without approval.** Tier-2 actions (deliver a real lead, change ad budget, send to a new party, publish) land in `approval_queue`. Tier-3 (raise the spend ceiling, pricing/brand/legal, disburse funds) are hard-blocked - advisory only.
- **Everything is bounded.** Per-task token caps, daily/project dollar ceilings, and circuit breakers (consecutive critic fails, error-rate spike, dead-man's switch on no *funnel* progress). A trip flips `run_mode='halted'` and alerts.
- **Independent critic.** No worker grades its own output. A separate fast gate (Tier A) checks every output; the LLM Council (Tier B) convenes only on high-stakes/uncertain/repeated-fail/strategic calls.

## File map

```
operations/control-plane/
  scripts/
    control-db.ps1            # shared DB helper (PATCH/INSERT + typed wrappers over the 006 tables)
    control-tick.ps1          # the deterministic watchdog tick
    control-power.ps1         # the on/off switch  (off | on | status)
    install-control-tick.ps1  # registers the \CWDB\CWDB-Control-Tick scheduled task
  workflows/
    council.mjs               # Tier-B LLM Council (5 lenses -> peer review -> chairman). Wired in Inc 2.
  config/
    control-config.json       # budgets, breakers, cadence, tier boundary, rollout flags
  sql/
    001_seed.sql              # objective + agent_registry seed
  dashboard/                  # Mission Control web UI (local-only) - see start-dashboard.ps1
operations/data-warehouse/
  schema/006_operational_tables.sql   # the 8 control tables (state, objective, task, event_log, ...)
  views/002_control_views.sql         # v_validation_gate, v_control_status, v_budget_rollup
.claude/agents/cwdb-orchestrator-tick.md   # the orchestrator runbook (the /schedule agent)
_vault/control/digest-<date>.md            # daily digest (written by the control tick)
```

## Deploy (one time)

The system boots paused, so these steps are safe; the loop will not act until you turn it on.

1. **Apply the SQL** (Supabase MCP `apply_migration`, or paste into the Supabase SQL Editor) in order:
   1. `operations/data-warehouse/schema/006_operational_tables.sql`
   2. `operations/data-warehouse/views/002_control_views.sql`
   3. `operations/control-plane/sql/001_seed.sql`
   Verify: `SELECT run_mode, gate_open FROM control_state;` -> `('paused', false)`. `SELECT * FROM v_validation_gate;` -> one row.
2. **Register the watchdog:** `pwsh operations/control-plane/scripts/install-control-tick.ps1` (registers `\CWDB\CWDB-Control-Tick`, every 30 min). Deterministic, no spend.
3. **Register the orchestrator** as a `/schedule` remote agent running `cwdb-orchestrator-tick` every 2 h, 07:00-21:00 CT. **Prerequisite:** the remote agent env must mirror local (same MCP servers - Supabase/HubSpot/Make/Webflow/Gmail - and the `.claude/agents/` roster), or it cannot spawn workers / write state.

## Operate (daily)

```
pwsh operations/control-plane/scripts/control-power.ps1 status              # one-screen health
pwsh operations/control-plane/scripts/control-power.ps1 on                  # turn the loop ON
pwsh operations/control-plane/scripts/control-power.ps1 off -Until 2026-06-15 -Reason "out of town"
pwsh operations/control-plane/dashboard/start-dashboard.ps1   # Mission Control dashboard (approvals, steer, dials)
```

- **Off** is quiet: no reasoning, no spend, in-flight work frozen, no alerts. **On** resumes exactly where it left off (re-anchors breaker windows, extends pending approval expiries, re-baselines the funnel). `-Until` auto-resumes.
- **`halted`** (a breaker tripped) is loud - `on` clears it.
- Read the digest each morning (`_vault/control/digest-<date>.md`, also delivered as a Gmail draft by the reasoning layer). Clear `approval_queue` items you approve.

## Rollout increments (`config/control-config.json` -> `rollout`)

Loosen ONE step only after the skeleton runs clean across multiple ticks.

| Inc | `dry_run` | `auto_execute_max_tier` | `council_enabled` | `tier2_execution_enabled` | Effect |
|---|---|---|---|---|---|
| **1** (now) | true | 0 | false | false | Workers propose only; everything -> approval queue. Prove the loop. |
| **2** | false | 1 | true | false | Auto-execute Tier 0/1; council convenes on triggers. |
| **3** | false | 1 | true | true | Approved `approval_queue` rows execute (first real lead delivery -> first `fact_bids` row). |
| **4** | false | 1 | true | true | Activate more workers (`is_active=true` in `agent_registry`). |

## Why each guardrail exists

- **Gate token freshness** (orchestrator refuses if `gate_token_at` > 35 min old): proves the watchdog is alive before spending.
- **Lease + reaper**: a crashed mid-tick worker leaves an `active` row; the reaper requeues it. Crash recovery for free.
- **Dead-man's switch on funnel progress** (not task busyness): a loop that's "busy producing confident nonsense" still halts.
- **Default paused + Tier boundary**: the two most important safety decisions, both set conservatively and adjustable in config.
