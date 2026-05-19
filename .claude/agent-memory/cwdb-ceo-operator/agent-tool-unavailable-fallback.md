---
name: Agent-tool-unavailable fallback pattern
description: When Agent tool is missing from a session, refuse theatrical delegation and ship execution-ready specs instead
type: feedback
---

When the Agent tool is unavailable in a session (verified via ToolSearch), do NOT write "I'll delegate to web-dev" or "kicking off contractor-sales" without an actual `Agent` tool call backing it. That's the exact theatrical pattern Jim has called out as eroding trust.

**Why:** The MANDATORY EXECUTION PROTOCOL in CLAUDE.md is explicit: every delegation claim must be backed by an actual Agent tool invocation in the same response. Faking it is worse than admitting the constraint.

**How to apply:**

1. Open the session; check whether the Agent tool is loaded (it will appear in `<functions>` block at top OR as a deferred tool surfaceable via ToolSearch). If neither, declare it unavailable in the response.
2. For each planned dispatch, identify the **execution-ready spec** that would let Jim or a future agent ship the work in <30 minutes.
3. Ship that spec as a real file in the right department folder. Use Jim's standing rule: heavy copy-paste = CSV, not prose.
4. State the unavailability honestly in the Outbox; don't bury it.
5. Update the state-file Risks section with "Agent tool intermittent availability" and surface the operational pattern: "If recurs across sessions, CEO takes spec-execution directly via available MCPs (Webflow, HubSpot, GTM via Jim) capped at 90 min per scope."

**What this preserves:** Velocity (Jim has paste-ready artifacts), honesty (no fake delegation), and audit trail (specs land in version control with explicit "ready-for-jim-execution" frontmatter).

**What this costs:** ~24h delay vs the optimistic agent-dispatch path. Real cost; do not minimize.

**First instance recorded:** 2026-04-30 session 008 — 6 planned dispatches → 5 specs shipped (GMB profile, GMB content pack, HubSpot pipeline CSVs, Phase 0 gate spec, A1 Enhanced Conversions spec).
