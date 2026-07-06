---
name: Webflow MCP — cannot insert siblings adjacent to component instances at body level
description: insert_component_instance / component_builder with position "before"/"after" fails when the anchor is a body-level component instance; workaround is remove + re-append in correct order
type: feedback
originSessionId: e2b6a733-2fef-472f-a385-0b6e4f5fe424
---

When using Webflow MCP to reorder or insert a component instance adjacent to another component instance at the body level, `insert_component_instance` and `component_builder` with `position: "before"` or `position: "after"` fail with the error "Cannot insert elements directly into a component instance." This is a known restriction on component-instance sibling insertion at the top level of a page body.

**Why:** Confirmed 2026-04-20 during Phase 2 Step 11 homepage assembly. The agent needed to reorder `coverage-map` and `cta-final` around each other and to position new sections between existing component-instance siblings. All `before`/`after` adjacent-to-component-instance insertion attempts failed with the same error.

**How to apply — two workarounds, pick based on how many instances are in play:**

1. **Single insertion:** Append the new component to the body at the end, then re-order via a second MCP call that moves other existing sections to their correct positions. Still fails if the move operation uses before/after against a component instance.

2. **Reliable workaround — remove + re-append in order:** Remove the trailing N sections (from the insertion point to the end of body) in one batch, then sequentially append them (including the new one) in the correct final order. As long as the removed component instances have no property overrides, re-appending preserves all their content/bindings. This is what shipped Step 11 homepage assembly cleanly.

**Prerequisite check before workaround #2:**
- Confirm the component instances being removed have NO per-instance overrides (Webflow MCP can't recreate those on re-append since per-instance overrides aren't exposed on single-locale sites anyway). If any do, stop and escalate — removing + re-appending would drop the override.

**Read-only operations are unaffected.** This restriction is specific to DOM-structural write operations adjacent to component instances.
