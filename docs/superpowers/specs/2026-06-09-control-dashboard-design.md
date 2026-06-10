# CWDB Mission Control Dashboard — Design Spec

**Date:** 2026-06-09
**Status:** Approved by Jim (architecture, layout, write semantics, error handling, testing)
**Owner experience:** Jim approves/rejects/steers the autonomous control loop from a local dark-glass dashboard instead of raw SQL or the read-only daily digest.

## 1. Problem

The CWDB autonomous control loop (Inc 1, live as of 2026-06-09) surfaces proposals in `approval_queue` and writes a read-only daily digest. Jim's only decision channels are (a) telling the CEO session in chat or (b) raw SQL. There is no interactive surface to decide proposals, give the orchestrator feedback, pause/resume, steer priorities, or adjust budget/rollout dials.

## 2. Requirements (as decided)

- **Access:** laptop-only. Local server bound to `127.0.0.1`; credentials stay in the existing `.env.local`. No hosting, no public surface, no phone access.
- **Actions (all four):**
  1. Approve / reject / request-changes on `approval_queue` rows, with a free-text note.
  2. Pause / resume the loop (mirrors `control-power.ps1` semantics exactly).
  3. Steer: standing directives + direct task injection into the queue.
  4. Budget + rollout dial: edit `control-config.json` (day soft/hard dollars, project cap, `dry_run`, `auto_execute_max_tier`, `council_enabled`, `tier2_execution_enabled`).
- **Liveness:** refresh on load only + a manual refresh button. No polling, no realtime.
- **Read content:** mirrors the daily digest and more — mode/gate, validation-gate progress, queue counts, spend vs caps, pending + decided approvals, recent events, active directives, funnel/CAC glance.
- **Design language:** dark background, glassmorphism (translucent panels, backdrop blur, subtle borders/glows), modern/gamified. Brand accents: Crafted Orange `#e54c00`, Wisconsin Sky Blue `#83b2cf`; success green, warning gold.
- **Layout:** **Command Deck** (chosen over Side Rail and Quest HUD): single dense screen, no navigation. Top status strip (mode pill, gate state, pause/tick buttons) → KPI card row (gate progress, spend, queue) → two-column main split (approvals feed left ~60%, activity feed right) → directive composer docked at the bottom. Gamified accents (XP-style progress bar on the validation gate, streak/badge touches) folded into the Command Deck rather than a separate HUD layout.

## 3. Architecture (Approach A — PowerShell-served local app)

Chosen over (B) static HTML calling Supabase directly from the browser and (C) Streamlit. Rationale: safety-critical writes share code with the loop's own tooling instead of duplicating it (no logic drift on pause/resume reconciliation); credentials never reach the browser; the server can shell out to existing PS scripts ("Run tick now", "Refresh warehouse").

```
operations/control-plane/dashboard/
  dashboard-server.ps1    # HttpListener on http://127.0.0.1:7717 (loopback only)
  public/
    index.html            # the glass UI (single page)
    app.js                # fetch + render + action calls
    style.css             # dark glassmorphic design system
  start-dashboard.ps1     # launcher: starts server, opens default browser
```

`dashboard-server.ps1` dot-sources `operations/control-plane/scripts/control-db.ps1` (same Supabase REST helpers + `.env.local` credential loading the watchdog uses).

### Endpoints (localhost JSON API)

| Endpoint | Method | Behavior |
|---|---|---|
| `/` , `/app.js`, `/style.css` | GET | static UI |
| `/api/state` | GET | one bundle: `v_control_status`, pending approvals + last 20 decided, task list, last 50 `event_log` rows, `v_budget_rollup`, `v_validation_gate`, latest `v_lead_funnel` + `v_cac_by_channel`, active directives, current `control-config.json` |
| `/api/approval/{id}/decide` | POST | body `{decision: approve\|reject\|request_changes, note}` — see write semantics |
| `/api/power` | POST | body `{action: pause\|resume, reason?, until?}` — shared logic with `control-power.ps1` |
| `/api/directive` | POST | body `{kind: directive\|task, ...}` — insert directive or queued task |
| `/api/directive/{id}` | POST | body `{status: done\|dismissed}` |
| `/api/config` | GET/POST | read / edit `control-config.json` (timestamped backup + JSON round-trip validation) |
| `/api/run/{script}` | POST | allowlist only: `control-tick`, `warehouse-daily`. Shells to the existing PS scripts, streams exit code + tail of output |

### Backend changes that ride along

1. **Migration `007_dashboard.sql`:**
   - `directive` table: `directive_id bigserial PK, body text NOT NULL, status text CHECK (status IN ('active','done','dismissed')) DEFAULT 'active', created_by text NOT NULL, created_at timestamptz DEFAULT now(), updated_at timestamptz DEFAULT now()`.
   - `ALTER TABLE approval_queue ADD COLUMN decision_note text;`
2. **Orchestrator runbook update** (`.claude/agents/cwdb-orchestrator-tick.md` step 2): also `SELECT * FROM directive WHERE status='active' ORDER BY created_at` and treat directives as standing guidance when decomposing and prioritizing.

## 4. Write-action semantics

Every button maps to a concept the loop already understands; the orchestrator needs no new mechanisms beyond reading `directive`.

- **Approve:** `approval_queue.status='approved'`, `decided_by='jim-dashboard'`, `decided_at=now()`, `decision_note`. `event_log` row (`actor='human'`, `event_type='approval_decided'`). Nothing auto-executes in Inc 1; the watchdog's work-available check already counts approved rows.
- **Reject:** `status='rejected'` + note + event row. Linked task → `status='failed'`.
- **Request changes:** `status='rejected'` + note, **and** linked task requeued (`status='queued'`) with the note appended to `payload.feedback` — the identical mechanism the critic uses on a fail verdict. Next tick re-routes the task; the worker sees the feedback verbatim.
- **Pause/Resume:** identical semantics to `control-power.ps1` via shared dot-sourced functions (pause: mode+reason+optional until, close gate, event row; resume: clear pause fields, re-anchor breakers, extend pending approval expiries by pause duration, event row). The shared logic is extracted from `control-power.ps1` into `control-db.ps1` as `Invoke-LoopPause` / `Invoke-LoopResume`; `control-power.ps1` and the dashboard both call those, so there is exactly one implementation.
- **Directive:** insert `directive` row. Dashboard can mark `done`/`dismissed`.
- **Inject task:** insert `task` row (`status='queued'`, type, title, priority, `assigned_agent` constrained to a dropdown of `agent_registry WHERE is_active`, DoD lines → `payload.dod`, `trace_id='dashboard'`). Competes on priority like any queued task.
- **Config dial:** edit `control-config.json` on disk. Timestamped backup first (`control-config.json.bak-<stamp>`), JSON round-trip validation, `event_log` row with old→new diff. Budget caps and rollout flags get an explicit "this is a safety rail" confirm dialog in the UI.

## 5. Error handling & safety

- Server binds `127.0.0.1` only; never reachable off-machine.
- Approve/reject writes are guarded with PostgREST conditional filters (`status=eq.pending`); a lost race returns conflict → UI toast "already decided/expired", no silent double-write.
- Failed Supabase calls → visible toast with raw error. No silent retry.
- Config write failure → automatic restore from the backup just taken.
- `/api/run/*` is a fixed two-script allowlist; no arbitrary command execution.
- The dashboard **never executes proposals** — it only flips approval status. Execution remains the loop's job at its rollout increment. This boundary is the safety model.

## 6. Testing

- **Self-test mode:** `dashboard-server.ps1 -SelfTest` starts the server, hits every GET endpoint, asserts JSON shape, exits non-zero on failure.
- **Write-path test:** insert a synthetic approval row (`action_kind='dashboard-selftest'`), decide it via the API, assert status + event row, delete it. Same pattern for a synthetic directive. No real rows touched.
- **Manual acceptance:** Jim opens the dashboard and decides the real `approval_id 1` from the UI as its first production use.

## 7. Out of scope (explicit)

- Phone/remote access, auth, hosting.
- Realtime push or polling.
- Executing approved proposals from the dashboard.
- Editing `objective` or `agent_registry` from the UI (SQL remains the path for those rare edits).

## 8. Open follow-ups recorded elsewhere

- Approval_id 1 decision + manual `lead-routing` build (Jim chose manual execution path; loop stays Inc 1).
- `v_clean_leads` hardening migration.
- Gate-opener cloud migration for laptop-off autonomy (the remote routine currently depends on the local watchdog's gate token).
