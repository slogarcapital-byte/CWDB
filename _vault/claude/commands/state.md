---
description: Refresh the Live Data Tables in today's brief without rebuilding it. Pulls fresh HubSpot + ad-platform data and patches the section in-place. Preserves Jim's checkboxes and %...% comments.
---

Refresh the live data snapshot inside today's daily brief. This is the manual mid-day refresh — when Jim wants the brief's Live Data Tables to reflect *right now* without waiting for tomorrow's `/brief`.

This skill **does not rebuild the brief.** It only rewrites the Live Data Tables section. Everything else (Today's Top 3, Decisions Needed, Notes from Jim, Mentor Check, Memory Updates) — including any `[x]` marks and `%...%` comments Jim has left mid-day — is preserved exactly as written.

Live data source is the Supabase warehouse (project `iabiwsbmnbxmkjvkgfhg`); query views like `v_lead_funnel` and `v_cac_by_channel`. The legacy `_vault/state-of-cwdb.md` singleton has been deleted (2026-06-05); do not recreate it.

## What to do

### 1. Verify today's brief exists

Compute today's date (YYYY-MM-DD, America/Chicago). Check that `_vault/briefs/<today>.md` exists.

If it does NOT exist, **error and direct the user to run `/brief` first**:

> No brief found at `_vault/briefs/<today>.md`. Run `/brief` to compose today's brief — `/state` only refreshes the Live Data Tables section in an existing brief; it does not generate one.

Do not silently fall back to creating a new brief.

### 2. Pull fresh data

Pull live data from each source:

- **HubSpot** (via `mcp__claude_ai_HubSpot__search_crm_objects`):
  - Recent contacts (last 7 days, sorted by `createdate` desc)
  - Open deals by pipeline stage (count + total amount)
  - Lifecycle stage breakdown (lead / mql / sql / customer counts)

- **Ad-platform JSON snapshots** at `_vault/data/`:
  - `google-ads-latest.json`
  - `meta-ads-latest.json`
  - `ga4-latest.json`

  Check each `pulled_at` timestamp. Flag any older than 24 hours as `⚠️ STALE: <file> last pulled <timestamp>`. If a file is missing, note as `(no data)` rather than fabricating.

### 3. Patch the Live Data Tables section in-place

Open `_vault/briefs/<today>.md`. Locate the `## 1. Live Data Tables` heading (or whichever heading anchor is used for that section). Replace **only** the body of that section with the freshly composed table block.

**Touch nothing else.** Do not modify:
- Frontmatter (other than bumping a `last_data_refresh` field if it exists; do not touch `status`, `date`, `prev`, `next`, or `generated_at`).
- Any other section (Yesterday's Deltas, Today's Top 3, Board Snapshot, Decisions Needed, Notes from Jim, Mentor Check, CEO Memory Updates).
- Any `[x]` mark or `%...%` comment Jim has left in the brief mid-day.

Use the `Edit` tool with a precise old/new block scoped to the Live Data Tables section. Do NOT rewrite the whole file.

### 4. Run /vault-sync internally

After the brief is patched, invoke the `/vault-sync` slash command to refresh `_vault/claude-memory/` (copies of the global memory files) and verify the `_vault/claude` junction is still healthy.

### 5. Report

Output a concise summary:
- Brief patched: `_vault/briefs/<today>.md` — Live Data Tables refreshed
- HubSpot: <N> contacts, <N> open deals, <pipeline summary>
- Google Ads: <last refresh timestamp + headline metrics, or stale/missing flag>
- Meta Ads: <same>
- GA4: <same>
- Any stale-data warnings surfaced
- Confirmed: no other section was modified; Jim's marks and comments preserved

Do NOT `git add` or commit anything — Jim handles staging himself.
