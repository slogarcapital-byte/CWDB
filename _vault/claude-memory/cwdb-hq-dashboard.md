---
name: cwdb-hq-dashboard
description: "CWDB HQ dashboard (2026-07-06) - canonical task list, KPIs, counsel, financials; two-way loop between dashboard and Claude; board files are generated mirrors"
metadata: 
  node_type: memory
  type: project
  originSessionId: ca908955-e2c5-43b1-bf9b-ab849f1a920c
---

# CWDB HQ dashboard (shipped 2026-07-06)

Streamlit app at `operations/dashboard/` (launch: `pwsh operations/dashboard/launch-dashboard.ps1`, port 8511). Four tabs: Command (6 construction-era KPIs + exec summary + board of counselors), To-Do, Diagnostics (health + audit findings), Financials (QBO P&L / position / tax reserve / job profit). Cloud twin: same code on Streamlit Cloud (test-branch, like the estimator), read-only, passcode + ANON key only (RLS SELECT policies in views/008-009; service-role key never leaves the laptop).

## Standing rules this created

- **`dashboard_tasks` (Supabase) is the CANONICAL task list.** `_vault/board/*.md` are GENERATED mirrors, rewritten by the dashboard on every mutation - never hand-edit them. Old board content is in git history (pre-2026-07-06, commit 99dfd76).
- **Two-way loop:** every dashboard action appends to `dashboard_events` (processed_at NULL = pending). SessionStart hook surfaces unprocessed events; run [[dashboard-sync]] skill (`.claude/skills/dashboard-sync.md`) to ingest. `/session-end` emits a `session_summary` event back. Task prompts sent to terminals instruct Claude to update the task row when done.
- **Counsel pipeline:** "Convene the Board" button → `run-counsel.ps1` → headless `claude -p` executes `.claude/skills/counsel.md`: specialty agents → CEO brief → 5 lenses (from control-plane council.mjs, First Principles re-aimed at booked construction revenue + GP/job) → independent chairman → JSON → `counsel_runs` table. Headless gotcha: the prompt must explicitly override the SessionStart daily-read ritual or the session does the daily read instead (run 3 failure, 2026-07-06).
- **Consent is data, not a gate** (fix #6): fact_leads ingests all real leads; `consent_missing=true` blocks SMS until re-capture. The old `CHECK (tcpa_consent_given = true)` constraint was the root cause of the 3 dropped leads.
- **fact_bids.accepted_at: earliest wins.** HubSpot closedate re-stamps on later deal touches (bid 4 read 7/6 after Jim moved Overbeck to Won); the pull now preserves the earliest recorded acceptance. Bid 4 = 2026-06-11 (true date).
- **Test-exclusion predicate lives in TWO views**: `v_clean_leads` (invoker, full columns) and `v_clean_leads_safe` (definer, non-PII, feeds the twin-readable aggregates). Change both together.
- **QBO financials pull**: `templates/scripts/pull-qbo-financials.ps1` → `fin_pl_monthly` / `fin_position` / `fin_job_profit`. v_pl_monthly rebuilt: fee revenue only when invoiced + lead_purchase lane (phantom $1,000 gone), construction leg from QBO. Job costs only count when QBO expense lines are customer-tagged (mostly untagged today, GP% reads high).

## Design system (impeccable pass 2026-07-06)

`.impeccable.md` gained a "Design Context (Internal Tools / CWDB HQ dashboard)" section: dark Timber Slate, glassmorphism IN scope for internal tools by Jim's decision (ad ban does not apply), Staatliches + Public Sans, orange scarce (act-here only), Wisconsin Sky as secondary accent. Theme lives in `operations/dashboard/.streamlit/config.toml` (NOT repo root - a root config would retheme the estimator's Streamlit Cloud app); the launcher sets CWD to the app dir so it loads.

Streamlit platform gotchas learned:
- pandas 3.x breaks Streamlit's Styler path (falls back to raw values); the grid also paints null cells as literal faded "None". Use `st.column_config.NumberColumn` + `fillna(0)` for P&L-style tables (matches QBO's 0.00 rendering).
- `Start-Process` child processes die when the launching shell's console closes; run the server via a detached hidden pwsh (`Start-Process pwsh -WindowStyle Hidden`).
- npm `claude.ps1` shim: not executable by Start-Process (use the `.cmd` sibling); argv through the .cmd shim TRUNCATES multi-word args - pass headless prompts via stdin (`-RedirectStandardInput`); `claude -p "/skill"` does not resolve project skills (instruct it to read the skill file); the headless session obeys the SessionStart daily-read ritual unless the prompt explicitly overrides it, and each headless run creates a stub session note.

Deploy/docs: `operations/dashboard/README.md`. Data layer: schema/013-014, views/007-009.
