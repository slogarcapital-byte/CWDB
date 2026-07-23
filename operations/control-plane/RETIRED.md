# RETIRED (formal record, 2026-07-22)

The autonomous control plane is **retired**, effective 2026-07-05 (audit decision), formally recorded 2026-07-22 (audit fix #19, dashboard task 19).

## What retired

- `\CWDB\CWDB-Control-Tick` scheduled task: **Disabled** (verified 2026-07-22)
- `\CWDB\CWDB-Dashboard` (Mission Control) scheduled task: **Disabled** (verified 2026-07-22)
- The `cwdb-orchestrator-tick` remote routine: no longer scheduled
- `approval_queue` is closed for new work; final open item #61 rejected 2026-07-22 (Make scenario repoint, obsolete after gateway relay v2)
- Make scenarios 5361099 (deactivated 2026-07-22) and 4792854 (parked since 2026-04-19)

## What stays

- The Supabase warehouse, all views, and `\CWDB\CWDB-Warehouse-Daily` (enabled, 06:55 daily, plus the logon catch-up guardrail added 2026-07-22)
- The control tables (control_state, event_log, approval_queue, etc.): kept as historical record, no writers
- The CWDB HQ dashboard (`operations/dashboard/`, port 8511): this REPLACED Mission Control and the daily ritual

## Why

Phase 1 closed 2026-07-05 with the construction pivot. The control plane optimized for lead-fee validation (route leads, chase accepted bids). The validated business is self-perform construction with a weekly 15-minute review on the HQ dashboard; a 2-hourly autonomous loop has nothing to drive. Full rationale: `_vault/briefs/2026-07-05-audit.md`.

## Rollback

`operations/control-plane/` is preserved intact. To revive: re-enable the two scheduled tasks, re-register the remote routine per README.md, and run `control-power.ps1 on`. Do not revive without a new written objective; the 006-table objective row is stale.
