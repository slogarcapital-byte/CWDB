# CWDB HQ — business dashboard

Four tabs: **Command** (construction-era KPIs, exec summary, board of
counselors), **To-Do** (canonical task list: Complete / Defer / Decline /
Send-to-Claude), **Diagnostics** (instrument health + audit findings),
**Financials** (QBO P&L, position, tax reserve, job profitability).

Built 2026-07-06 from the 2026-07-05 full business audit. Design/plan:
`~/.claude/plans/brainstorm-a-dashboard-for-velvet-dragonfly.md`.

## Run locally (full function)

```powershell
pwsh operations/dashboard/launch-dashboard.ps1     # port 8511, opens browser
```

Local mode reads `.env.local` (service-role key) and can write: task buttons,
board mirrors (`_vault/board/*.md`), event log, terminal launches, data pulls,
counsel runs. Pin a shortcut to the launcher for one-click access.

## The two-way loop

- **Dashboard → Claude:** every action appends a `dashboard_events` row.
  The SessionStart hook surfaces unprocessed events; `/dashboard-sync`
  ingests them (memory with judgment, queued work executed).
  "Claude: do it now" opens a Windows Terminal running Claude with the task
  prompt; "Claude: queue it" defers to the next session.
- **Claude → dashboard:** task prompts instruct Claude to update the task's
  Supabase row + append an event when done; `/session-end` emits a
  `session_summary` event.

## Board of counselors (Tab 1)

"Convene the Board" runs `run-counsel.ps1`: headless Claude executes
`.claude/skills/counsel.md` — specialty agents pull live numbers → CEO
strategy brief → 5 lenses (Contrarian, First Principles, Expansionist,
Outsider, Executor; ported from the control plane's council) → independent
chairman verdict + recommended moves (each adoptable as a task).
~10-13 agent invocations, ~5-10 minutes per convening.

## Cloud twin (phone, read-only)

Same codebase on Streamlit Cloud, deployed from **test-branch** (same as the
estimator):

1. share.streamlit.io → New app → repo/test-branch →
   main file `operations/dashboard/app.py`.
2. Secrets (App settings → Secrets):

   ```toml
   supabase_url = "https://iabiwsbmnbxmkjvkgfhg.supabase.co"
   supabase_anon_key = "<anon key - Supabase dashboard -> Settings -> API>"
   app_passcode = "<pick one>"
   ```

3. No service-role key EVER goes to the cloud. The anon key passes only the
   RLS SELECT policies from `views/008` + the definer aggregate views from
   `views/009`; PII (fact_leads, v_clean_leads) and dashboard_events are
   blocked, writes are RLS-filtered no-ops.
4. Mode auto-detects (`CWDB_HQ_MODE` defaults to cloud when no `.env.local`
   exists); all buttons are hidden read-only.
5. Acceptance: Jim's iPhone Safari (standing rule - Playwright is not
   acceptance for mobile).

## Data layer

- Tables: `operations/data-warehouse/schema/013_dashboard_hq.sql`
  (+ seed `014_seed_audit_2026_07_05.sql`)
- KPI views: `operations/data-warehouse/views/007_construction_kpis.sql`
- Twin read path: `views/008_cloud_twin_read_path.sql` +
  `views/009_clean_leads_safe.sql`
  (NOTE: the test-exclusion predicate lives in BOTH `v_clean_leads` and
  `v_clean_leads_safe` - change both together.)
- QBO pull: `templates/scripts/pull-qbo-financials.ps1` (fin_* tables)
