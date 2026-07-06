---
name: Webflow MCP — Designer page context is shared state across parallel agents
description: When two web-dev agents run in parallel and both modify Webflow pages, one agent switching the active Designer page can cause the other's structural-edit calls (e.g. transform_element_to_component) to fail; each agent should re-select its target page before structural edits
type: feedback
originSessionId: e2b6a733-2fef-472f-a385-0b6e4f5fe424
---

When two (or more) web-dev subagents run in parallel and both perform Webflow MCP edits, the **active Designer page is a shared piece of session state**, not per-agent. If Agent A switches the active page to work on `/service-area/template`, Agent B's next call that assumes the home page is active (e.g. `transform_element_to_component` on a homepage element) can fail with "element not found on current page" or similar.

**Why:** Observed 2026-04-20 during parallel dispatch of Step 7 (`gallery-featured` on homepage) and Phase 2.5 Part A (`hero-interior` on city template). Step 7 agent's first `transform_element_to_component` call errored because the Phase 2.5 agent had switched the Designer to the Service Areas Template just before. Step 7 agent's recovery was to re-select home and retry — succeeded on second attempt.

**How to apply:**

1. **When dispatching parallel web-dev agents**, give each agent an explicit directive: "before any structural edit, re-select your target page via `data_pages_tool` or equivalent." This is defensive — it costs nothing and prevents race failures.

2. **When only one agent will perform structural edits**, let it run solo. Parallel is still safe for read-only operations (CMS queries, snapshot fetches, verification scans) across any number of agents.

3. **Avoid parallel dispatch when both agents will hit the same page or same shared component.** That's a logical conflict, not just a context one — resolve with sequential ordering instead.

4. **If you see "element not found" mid-run**, first check whether a parallel agent may have switched page context, then re-select and retry before escalating.

This applies to Webflow MCP's stateful model specifically. Stateless REST-style calls (via `data_cms_tool`, `data_pages_tool` in read mode) are not affected.

---

**UPDATE 2026-04-20 Phase 4 Wave 1γ:** Re-reproduced and more severe than originally scoped. Three web-dev agents ran concurrently (About, FAQ, Blog index). Blog agent's `element_tool.query_elements` returned matches **scoped to the About page's component ID** — meaning the Designer page context swap didn't just fail the call, it silently returned *wrong-page* results. If the Blog agent had trusted those results and written DOM edits, it would have corrupted the About page mid-flight. The Blog agent halted correctly rather than writing.

**Hardened rule going forward:** Structural DOM edits across multiple pages **must be serial**, not parallel. Read-only diagnostic work (`get_page_content`, `get_component_content`, `list_collection_items`, WebFetch verification) remains safe in parallel. When dispatching Phase 4-scale waves:

- Parallel = OK for: audit passes, WebFetch verification, CMS read queries, snapshot comparisons, script registration (which is page-scoped by ID, not by active-page state).
- Serial required for: `element_tool` inserts/removes, `whtml_builder` page mutations, `de_component_tool.transform_element_to_component`, `style_tool` on DOM-dependent selectors, `de_page_tool.switch_page`.

Operational pattern: dispatch structural work one page at a time, let each complete + publish, then next. Accept the ~2x wall-clock cost — it's cheaper than recovering from cross-page corruption.
