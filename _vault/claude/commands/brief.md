---
description: Morning briefing ritual. Reads yesterday's brief, merges Jim's checkboxes and %...% comments, pulls live HubSpot + ad-platform data, surfaces top 3 actions, and kicks off the CEO operator.
---

Run the morning briefing ritual. This is the lowest-friction way for Jim to open the day: one command, and the CEO agent reads yesterday's brief, honors Jim's marks/comments, pulls live data tables, surfaces what matters today, and starts driving.

Every run writes a **new dated daily brief** to `_vault/briefs/<today>.md`, generated forward from `_vault/briefs/<yesterday>.md`. **Jim's `[x]` marks and `%...%` comments from yesterday are authoritative** — merge against them, do not regenerate from memory. Yesterday's brief is then sealed (`status: sealed`) and the brief INDEX is updated.

Source of truth is the Supabase warehouse (project `iabiwsbmnbxmkjvkgfhg`). The brief is a daily working surface that layers Jim's marks and decisions on top of warehouse data. The legacy `_vault/state-of-cwdb.md` singleton has been deleted (2026-06-05); do not recreate it.

## What to do (in order)

### 1. Read yesterday's brief

Compute yesterday's date (YYYY-MM-DD, America/Chicago). Read `_vault/briefs/<yesterday>.md`. Parse frontmatter (`date`, `prev`, `next`, `status`) and all 8 sections. Pay particular attention to:

- **Today's Top 3** and **Decisions Needed** — every `[x]` and every non-empty `%...%` comment is a signal for the merge step that runs later.
- **Notes from Jim** — freeform notes Jim left that must be resolved (answered, escalated, or filed) in today's brief.
- **Mentor Check** — any Hormozi-diagnostic bottleneck carried forward.

If yesterday's file is missing, walk back day-by-day until you find the most recent brief (it is the new authoritative source). If no brief exists at all, bootstrap by reading the agent's MEMORY.md and dispatching the CEO operator to compose the first brief from scratch.

### 2. Pull live HubSpot data

Use `mcp__claude_ai_HubSpot__search_crm_objects` to pull live pipeline data for the brief's Live Data Tables section:

- Recent contacts (last 7 days, sorted by `createdate` desc)
- Open deals by pipeline stage (count + total amount)
- Lifecycle stage breakdown (lead / mql / sql / customer counts)

Capture both the raw counts and any deltas vs. yesterday's snapshot.

### 3. Read ad-platform data files

If present, read the latest auto-pulled JSON snapshots:

- `_vault/data/google-ads-latest.json`
- `_vault/data/meta-ads-latest.json`
- `_vault/data/ga4-latest.json`

These are auto-pulled at 6:55 AM Central. Check the `pulled_at` timestamp; if older than 24 hours, **flag stale data visibly** in the brief's Live Data Tables section (`⚠️ STALE: <file> last pulled <timestamp>`). If a file is missing entirely, note it as `(no data this morning)` rather than fabricating values.

### 4. KPI threshold check (alerts lead the brief)

From the live HubSpot + ad-platform data, check thresholds. If any of these are true, the brief **must lead with the alert**:

- CPL > $60 (cost per lead above target)
- ROI < 2x (advertising return below target)
- Any accepted-bid count that decreased (regression)
- Stale data files older than 24 hours

If any alert fires, frame the first line of the brief as: `⚠️ ALERT: [metric] is [value], [target context]. Recommend: [action].`

### 5. Dispatch CEO to compose today's brief

Launch the `cwdb-ceo-operator` agent with this directive:

> Compose today's daily brief at `_vault/briefs/<today>.md` per your **Daily Brief Protocol**. Forward-chain from yesterday's brief (`_vault/briefs/<yesterday>.md`).
>
> 1. Apply the three merge rules to all carried items:
>    - `[x]` on a `[Do]` item + verifiable evidence → drop, log to Recent Wins / shipped board.
>    - `[x]` on a `[Do]` item + no evidence → carry forward checked; raise in Decisions Needed.
>    - Non-empty `%...%` on a `[Do]` item → read as verification context.
>    - Non-empty `%...%` on a `[Decide]` item → classify as decision (drop + act + log), deferral (keep with note + reminder), or question back (keep + answer in Decisions Needed).
>    - Every new `[Do]` / `[Decide]` item must include `  - Jim's note: %%` sub-bullet.
> 2. Resolve all of yesterday's Notes from Jim — answer, act, or escalate into Decisions Needed.
> 3. Compose the 8 sections:
>    1. Live Data Tables (HubSpot pipeline + recent contacts + ad performance from JSON snapshots)
>    2. Yesterday's Deltas (what changed since yesterday's brief)
>    3. Today's Top 3 (each Tier-classified per Default Delegation Hierarchy)
>    4. Board Snapshot (counts only — Directives N · In Flight N · Shipped this week N)
>    5. Decisions Needed
>    6. Notes from Jim (extracted from yesterday's brief that need follow-through)
>    7. Mentor Check (Hormozi 12-step, 1 line per dimension)
>    8. CEO Memory Updates (0–3 entries from end-of-session ritual; otherwise justify)
> 4. Set frontmatter: `type: brief`, `date: <today>`, `prev: <yesterday>`, `next: ""`, `status: active`, `generated_by: cwdb-ceo-operator`, `generated_at: <ISO 8601, -05:00>`.
> 5. Write the file. Never overwrite an existing brief — if `_vault/briefs/<today>.md` already exists, error and surface the conflict.
> 6. Seal yesterday's brief: open `_vault/briefs/<yesterday>.md` and flip `status: active` → `status: sealed`. Set its `next` field to `<today>`.
> 7. Update `_vault/briefs/INDEX.md` — prepend a row for today's brief (date, status, top-3 summary).
>
> Then execute today's Top 3 autonomously. Delegate to specialist agents in parallel where possible. Follow your MANDATORY EXECUTION PROTOCOL — actually invoke the Agent tool for every Tier 1 / Tier 2 delegation.

The CEO agent takes it from there.

## Output format

Keep the brief output terse, operator-voice. No filler. Lead with any alerts, then the top 3, then "Dispatching CEO to drive..."

Do NOT repeat the entire brief back to Jim — he can open it himself. The summary is the **delta**: what needs attention today, not what's already known.
