---
name: Webflow MCP — cannot bind DOM elements to CMS fields
description: MCP has no CMS field-binding API; Image src/alt + Text Block content binds are Designer-only
originSessionId: ea094e47-91f4-4f70-a34c-89fcf9e48fd2
title: Webflow MCP — cannot bind DOM elements to CMS fields
type: memory
memory_type: feedback
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/webflow-mcp-cms-binds.md
tags:
  - type/memory
  - memory/feedback
---
Webflow MCP tools (`whtml_builder`, `element_builder`, `element_tool`, `data_components_tool`) can build DOM trees inside Collection Item templates, but **cannot bind those elements to CMS fields**. CMS binds live in the DynamoElement internal data model, not HTML attributes or text content.

**Attempts that do not work:**
- `set_text` with handlebar syntax `{{wf {"path":"title",...}}}` → stored as literal string.
- `add_or_update_attribute` with `wf-bind-text` → accepted as plain HTML attribute, stripped by Webflow publish engine.
- `element_snapshot_tool` on elements inside DynamoItem → errors with status undefined.

**Also Designer-only:**
- Creating Collection Lists (any source)
- Reading/setting Collection List filter + limit + sort settings (DynamoWrapper returns no settings metadata)
- Per-instance Component Property overrides on single-locale sites (known from prior sessions)
- Component Property deletion on master components

**Why:** Field-binding + filter settings are Webflow Designer UI surfaces backed by proprietary internal APIs that the public MCP does not expose.

**How to apply:**
- When a task involves CMS binds on Image src/alt or Text content: agents can pre-build the DOM structure with correct class names, but must stop there and hand off the bind step to Jim in Designer with a click-path.
- Never publish a page with unbound CMS-intended elements — it ships placeholder/empty content. Always hold publish until Jim confirms binds are wired.
- In briefs, explicitly warn agents that MCP may not support CMS binding; tell them to stop cleanly rather than fabricate hardcoded values.
- For Collection List filters: agent inspection returns no filter data. Always ask Jim to verify the filter + limit in Designer before the element is considered wired.
