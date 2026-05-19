---
name: Where to read current CWDB state every session
description: File paths for state files — read these at the start of every session before briefing
type: reference
---

# Canonical State Files — Read at Session Start

Every session the CEO reads these files to rebuild context. If any of them contradict recalled memory, trust the files, not the memory. Update memory if stale.

## Root-level state
- `C:\Users\jslog\.claude\projects\C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB\memory\MEMORY.md` — user-scoped auto-memory for CWDB (loaded into every session automatically). Full project snapshot.
- `C:\Users\jslog\OneDrive\Desktop\Slogars\CPA\Slogar-Capital\Claude\Projects\CWDB\CLAUDE.md` — project instructions, versioned.
- `C:\Users\jslog\OneDrive\Desktop\Slogars\CPA\Slogar-Capital\Claude\Projects\CWDB\business-context\phase-1-plan.md` — the canonical Phase 1 playbook.
- `C:\Users\jslog\OneDrive\Desktop\Slogars\CPA\Slogar-Capital\Claude\Projects\CWDB\business-context\website-plan.md` — 21-page site spec.

## Agent memories (read the one you're delegating to)
- `.claude/agent-memory/web-dev/MEMORY.md` — Webflow site state, CMS, component inventory, open items
- `.claude/agent-memory/ad-campaign/MEMORY.md` — ad channel state
- `.claude/agent-memory/analytics/MEMORY.md` — funnel + pixel state
- `.claude/agent-memory/contractor-sales/MEMORY.md` — contractor roster, outreach status
- `.claude/agent-memory/lead-qualification/MEMORY.md` — scoring rules, spam filter state
- `.claude/agent-memory/lead-routing/MEMORY.md` — Make scenarios, delivery config
- `.claude/agent-memory/accounting/MEMORY.md` — billing, expense tracking
- `.claude/agent-memory/revenue-optimization/MEMORY.md` — ROI, CPL history, pricing tests
- `.claude/agent-memory/market-research/MEMORY.md` — city/trade demand research

## Operational references
- `/operations/leads/quote-form-fields.json` — current form schema
- `/operations/leads/routing-rules.json` — territory routing logic
- `/operations/leads/scoring-rules.json` — qualification scoring
- `/operations/make/webhooks.json` — Make automation spec
- `/sales/crm/pipeline-stages.json` — HubSpot deal pipeline

## Session-update rule
When state changes (contractor signs, ad launches, page publishes, blocker clears) update:
1. The relevant agent memory file
2. Root-level MEMORY.md / project-state.md
3. This CEO's own memory if it changed the operating picture
