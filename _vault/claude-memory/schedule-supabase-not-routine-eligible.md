---
name: schedule-supabase-not-routine-eligible
description: RESOLVED 2026-06-09 — Supabase became /schedule routine-eligible; CWDB-Orchestrator-Tick remote routine registered (disabled) and proven end-to-end against main
metadata:
  node_type: memory
  type: project
  originSessionId: a7c883f9-25c5-4d44-a1fb-295356b1e6df
---

**RESOLVED 2026-06-09 (session -003).** Supabase is now `/schedule` routine-eligible. The two-surface split (below) closed: Supabase is now a first-class claude.ai connector (`mcp__claude_ai_Supabase__*`, connector_uuid `f10ca040-d328-4fe3-810b-390e977b21c5`, url `https://mcp.supabase.com/mcp`), not plugin-only, so it appears in the routine connector picker and is attachable.

**Routine registered:** `CWDB-Orchestrator-Tick`, trigger_id `trig_018CtCscGjfLC9TEJ6t6Laha`, **enabled=false** (boots disabled to honor "nothing spends until `control-power on`"). Cron `0 0,2,12,14,16,18,20,22 * * *` UTC = every 2h, 7am-9pm Central. Model `claude-sonnet-4-6`. Repo default branch `main`. Connectors attached: Supabase + Make + HubSpot. Env `env_014skvczgPXvHS9TF5Thfggi` (Jim). Self-contained prompt points at `.claude/agents/cwdb-orchestrator-tick.md` + `operations/control-plane/config/control-config.json`. Manage at https://claude.ai/code/routines (cannot delete via API).

**Proven end-to-end (2 manual test runs, loop paused):**
1. Tick 1 skipped `err-spec-missing` -> surfaced that the control plane lived only on `test-branch`, but the routine checks out the **default branch `main`** (was 14 commits stale). Fixed: `git push origin test-branch:main` (clean 0-divergence fast-forward; whole control plane now on main).
2. Tick 2 (event_log #18, trace `orch-0609-a1b2`): read spec + config (reported `dry_run:true, config_version:1`), ran the gate check, saw `run_mode=paused`, skipped with `reason=gate_check_failed`. Correct paused-loop behavior.

**Two caveats from the memory's original warning, now answered:**
- The "set Supabase `execute_sql` to Always-allow" worry is **MOOT for routines**: `mcp_connections.permitted_tools:[]` resolves to all-permitted, and the unattended cloud WRITE to `event_log` succeeded with no permission hang.
- **Gate-token coupling:** the routine's gate check requires `token_age <= 35 min`, and the gate token is refreshed by the LOCAL watchdog `\CWDB\CWDB-Control-Tick`. So with the laptop OFF the token goes stale and the remote tick will skip. True laptop-off autonomy needs the gate-opener moved to the cloud (future increment).

**To go live:** `RemoteTrigger` update `{enabled:true}` on the trigger as part of `control-power on`. Related: [[v-clean-leads-test-exclusion-gap]].

---
**HISTORICAL (pre-resolution, 2026-06-09 sessions -001/-002):** The `/schedule` connector list originally surfaced only a subset of claude.ai connectors. Supabase was fully connected interactively (live `List projects` call worked) but did NOT appear as routine-eligible across multiple refreshes 95 min apart -> ruled out cache lag; it was structural. Root cause: a two-surface split. An INTERACTIVE claude.ai/code session COULD use Supabase, but a ROUTINE is built only from the `mcp_connections` allowlist, and Supabase was then present locally only as a PLUGIN MCP (`mcp__plugin_supabase_supabase__*`), never `mcp__claude_ai_*`, so it was not routine-attachable. ("GitHub Integration" is the git-checkout source, not an MCP connector, which is why it also did not appear.) Routine-eligible connectors at the time: HubSpot, Make, Webflow, Gmail, Google Drive, Google Calendar. Remote registration was deferred to embedded-REST fallback vs keep-local-watchdog; the upgrade to a first-class claude.ai connector resolved it without needing the fallback.
