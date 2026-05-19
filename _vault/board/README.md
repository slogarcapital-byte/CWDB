# Board — How It Works

This is CWDB's project management spine. Every piece of work lives here from "Jim mentioned it" through "live in production."

## The 4 lifecycle files

| File | What lives here |
|---|---|
| `directives.md` | New asks not yet started. Jim drops things here from mobile or chat; CEO routes them. |
| `in-flight.md` | Work has an owner and acceptance criteria. Currently being built. |
| `shipped.md` | Done. Tagged with one of three ship types. |
| `killed.md` | Failed, deferred-indefinitely, or superseded. Each gets a one-line postmortem. |

## Item format (all files use the same shape)

```
- [WB-014] Build HubSpot lead-routing Workflow
  - Owner: lead-routing agent
  - Spec: operations/automation/hubspot-build/04-lead-routing-workflow-spec.md
  - Status: in-flight (since 2026-05-05)
  - Acceptance: workflow active in HubSpot; fires on form submit; creates Deal at New Lead; associates to Contact; sends notify email; smoke test passes
  - Ship type: scheduled-recurring-automation
  - Notes: %% Jim's comments go here %%
```

## Item IDs

Format: `[WB-NNN]` (WorkBoard, sequential, never reused). Once an ID is issued, it persists forever — through stage moves, ships, kills.

Source of truth for the next ID: `INDEX.md`.

## Ship-type taxonomy

When an item moves to `shipped.md`, it MUST be tagged with one of these:

- `build` — code, page, or component live in production (e.g., Webflow page, JS embed, HubSpot workflow)
- `artifact-prod` — non-code asset live (e.g., GMB profile published, ad campaign launched, contractor agreement signed)
- `scheduled-recurring-automation` — automated process running on a cron, hook, or webhook (e.g., daily HubSpot pull, brief generation)

If it doesn't fit, push back. "Done meeting" is not a ship.

## Movement rules

```
directives.md ──► in-flight.md ──► shipped.md
                  │                  
                  └─► killed.md (with postmortem)
```

1. New asks land in `directives.md` (top of file is "newest")
2. CEO assigns owner + acceptance + ship-type → moves item block to `in-flight.md`
3. Owner reports done with evidence → CEO verifies → moves to `shipped.md`, adds shipped-date
4. Failed/killed/superseded → moves to `killed.md` with one-line postmortem

The item's full history (its block of bullet points) moves with it. Don't summarize, don't fork.

## Jim's input markers

Same as the daily brief:

- Add `[x]` to mark something done — CEO verifies on next brief
- Drop a `%...%` comment under any item to give CEO context, decisions, or pushback

## Brief integration

Each daily brief at `_vault/briefs/YYYY-MM-DD.md` shows:

- Counts (Directives N · In Flight N · Shipped this week N)
- Today's Top 3 are always pulled from `in-flight.md`
- New `[Decide]` items in directives appear in the brief's Decisions Needed section

Don't duplicate items between brief and board. The board is the system of record.
