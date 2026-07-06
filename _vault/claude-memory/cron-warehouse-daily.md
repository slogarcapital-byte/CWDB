---
name: cron-warehouse-daily
description: CWDB-Warehouse-Daily Task Scheduler entry runs all 4 warehouse pulls at 06:55 Central each day. Where to look when freshness regresses.
metadata: 
  node_type: memory
  type: project
  originSessionId: e1825064-98f6-4cf0-8cd2-b3f72618d47b
---

Daily warehouse refresh runs as Windows scheduled task `\CWDB\CWDB-Warehouse-Daily` at 06:55 America/Chicago. Set up 2026-06-03.

**Why:** Previously no cron existed (Get-ScheduledTask returned zero matches before setup), so `raw_hubspot_snapshot` had been stale since 2026-05-21 and `fact_ad_spend_daily` since 2026-05-28. The brief skill's "Live Data Tables" were rendering against frozen data without flagging it.

**How to apply:**
- Source of truth: `operations/data-warehouse/scripts/run-daily.ps1` (orchestrator) + `operations/data-warehouse/scripts/install-cron.ps1` (idempotent registrar).
- Status check: `Get-ScheduledTaskInfo -TaskName CWDB-Warehouse-Daily -TaskPath \CWDB\` — LastTaskResult=0 means clean, 1 means at least one source failed.
- Per-source results: tail `_vault/data/cron-runs.log` (tab-separated: source, exit, elapsed_s, optional error).
- Re-installing: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File "operations\data-warehouse\scripts\install-cron.ps1"` — wipes + re-creates cleanly.
- Manual fire for testing: `Start-ScheduledTask -TaskName CWDB-Warehouse-Daily -TaskPath \CWDB\`.

**Steady state (as of 2026-06-04):** All 4 sources succeed. Previous "persistent Google Ads 400" was misattributed to WB-011 dev-token; actual root cause was OAuth refresh token expiry under Testing-mode 7-day rule. See [[google-oauth-testing-mode-7day-trap]] for the trap, symptom signature, and recovery procedure. The script `pull-google-ads-warehouse.ps1` now extracts response body in its catch block, so future refresh failures log the actual `invalid_grant` body instead of a bare "(400) Bad Request."

Related: [[feedback-powershell-script-portability]] for the gotchas hit during setup, [[google-oauth-testing-mode-7day-trap]] for the OAuth refresh-token expiry trap.
