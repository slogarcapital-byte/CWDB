---
name: Webflow MCP — per-instance Component Property overrides are Designer-only on single-locale sites
description: ALL per-instance Component Property overrides (Text, Image, Boolean) fail via Data API on single-locale sites with "locale must be a secondary locale"; Designer MCP has no write path either
originSessionId: ea094e47-91f4-4f70-a34c-89fcf9e48fd2
title: Webflow MCP — per-instance Component Property overrides are Designer-only on single-locale sites
type: memory
memory_type: reference
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/webflow-mcp-component-bool-props.md
tags:
  - type/memory
  - memory/reference
---
**Verified 2026-04-20 across three sequential Phase 2.5 Part B agents.** The finding evolved twice before settling on this broader truth.

## The rule

On single-locale Webflow sites (like CWDB), **per-instance Component Property overrides of ALL types are Designer-only**. This affects:

- **Plain Text properties** (e.g., `Main Title`, `heading`, `subheading`)
- **Boolean properties** (e.g., `Header Visibility`)
- **Image properties** (untested but same API gate — assume same)
- **Link properties** (untested — assume same)

## Why

Two independent MCP paths both blocked:

1. **Data API writes** (`update_component_properties`, `update_static_content`) — all return:
   ```
   400 Bad Request: The provided locale must be a secondary locale.
   ```
   The API is localization-scoped by design; primary-locale overrides aren't writable.

2. **Designer MCP tools** (`element_tool`, `de_component_tool`, `component_builder`, `de_page_tool`) — the loaded schemas expose `query_elements` that *reads* `hasOverride` + `value`, but no corresponding *write* action for per-instance property overrides.

## What this means for agent tasks

- Per-instance override tasks → **hand off to Jim in Designer with exact click path**. 2 pages × 2 fields = ~2 min of clicks. Agents should NEVER attempt to script this and fabricate success.
- Component *master* edits (structural DOM, master-level property defaults, master styles) ARE MCP-doable via `whtml_builder`, `element_builder`, `style_tool`, `update_component_properties` (without instance scoping).
- CMS field binds on DOM elements inside Collection Items → also Designer-only (different surface, same "stop and hand off" pattern — see `webflow-mcp-cms-binds.md`).

## False leads tried this session

- Setting propertyOverrides via `data_pages_tool.update_static_content` with the primary locale ID → locale error.
- Calling `update_component_properties` with a payload that tried to target a specific instance → locale error.
- Hunting for a Designer-side write action → none exists in any loaded tool schema.

## Workarounds (in priority order)

1. **Manual Designer clicks by Jim** — fastest, safest, exactly matches what the Designer UI is for.
2. **Enable a secondary locale temporarily** — unlocks the Data API write surface, but introduces side effects across CMS + published pages. Not recommended for CWDB.
3. **Refactor the component so the override isn't needed** — e.g., swap to a CMS-bound hero that draws per-page content from a CMS collection. Higher up-front effort but eliminates future per-instance overrides.

## Related memories

- `webflow-mcp-cms-binds.md` — CMS field binds are Designer-only (different surface, consistent "hand off" pattern)
- `pivot-2026-04-19.md` — the original correct conclusion; this memory confirms + expands it
- `webflow-collection-list-grid.md` — `display: contents` pattern for Webflow CMS grids (unrelated to overrides, but relevant to Webflow MCP workarounds generally)
