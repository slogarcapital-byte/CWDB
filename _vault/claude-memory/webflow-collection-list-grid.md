---
name: Webflow Collection List — use display:contents to make grid/flex work on CMS items
description: Webflow's DynamoWrapper + DynamoList wrappers break grid/flex layouts applied to the parent container; use display:contents on them so items bubble up as direct children
originSessionId: ea094e47-91f4-4f70-a34c-89fcf9e48fd2
title: Webflow Collection List — use display:contents to make grid/flex work on CMS items
type: memory
memory_type: reference
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/webflow-collection-list-grid.md
tags:
  - type/memory
  - memory/reference
---
When a Webflow Collection List is placed inside a container that has `display: grid` or `display: flex`, the intended layout silently fails because Webflow inserts two generated wrappers between the parent container and the Collection Items:

```
.parent-grid  (display: grid)
  └─ .w-dyn-list    ← DynamoWrapper — intercepts layout
       └─ .w-dyn-items  ← DynamoList — intercepts layout
            ├─ Collection Item
            ├─ Collection Item
            └─ Collection Item
```

The grid container sees only `.w-dyn-list` as its child — one element, one cell. Grid layout never reaches the Collection Items.

**Fix:** Apply `display: contents` to BOTH `.w-dyn-list` and `.w-dyn-items`. They disappear from the layout tree, and the Collection Items become direct children of the grid/flex container.

In Webflow specifically, give both wrappers a custom class name (e.g., `[component]__list-wrapper` on `.w-dyn-list`, `[component]__list` on `.w-dyn-items`) and set `display: contents` on each via `style_tool`. Found + used on 2026-04-20 for `gallery-featured` (classes `gallery-featured__list-wrapper` + `gallery-featured__list`).

**When to apply:**
- Any Webflow CMS Collection List that needs grid or flex layout on the items, rather than the default vertical block flow.
- Confirm first that the grid/flex styles are already on the parent container and simply not cascading — otherwise fix the parent before touching wrappers.
