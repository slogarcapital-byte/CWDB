---
name: Webflow MCP — whtml_builder silently strips pseudo/hover/keyframe CSS
description: whtml_builder drops ::before/::after, :hover, @keyframes, and compound pseudo-stacks on import; use style_tool with pseudo param, real aria-hidden divs, or inline site scripts
type: feedback
originSessionId: e2b6a733-2fef-472f-a385-0b6e4f5fe424
---

Webflow MCP's `whtml_builder` silently drops several CSS constructs during import. No errors are thrown — the rules are just missing from the rendered Designer output. Confirmed stripped:

- `::before`, `::after` (pseudo-elements — base rules)
- `:hover` pseudo-class rules
- `@keyframes` animation definitions
- **Compound pseudo-stacks** like `:hover::after` — `style_tool`'s `pseudo` enum has single-pseudo options only (`before`, `after`, `hover`, `focus`, `focus-visible`, etc.) with no compound option
- **Attribute selectors** like `[open]`, `[aria-expanded="true"]` — e.g. `.faq-item[open] .chevron { transform: rotate(180deg); }` got stripped on publish (confirmed 2026-04-20, Step 11.5 FAQ accordion build)

Also: **inline `<script>` tags inside a whtml_builder element are preserved, but Webflow HTML-encodes their quotes** (`'` → `&#x27;`), making the script text non-executable. Don't inline scripts via whtml — use `data_scripts_tool.add_inline_site_script` + `upsert_page_script` instead.

**Why:** Confirmed across Phase 2 builds (2026-04-20) of `process-steps-v2` (`::before` connector stripped), `coverage-map` (`:hover::after` underline stripped — base `::after` survived via `style_tool` retry but the hover-animated variant couldn't be represented), and multiple other components.

**How to apply — three tiers, pick based on need:**

1. **Simple pseudo (single-pseudo, no state stacking):** Use `style_tool > update_style` with an explicit `pseudo: "before"` / `"after"` / `"hover"` / `"focus-visible"` parameter from the start. Works for base rules.

2. **Decorative or structural (pseudo with no state stacking, or where semantics don't matter):** Use a real element — `<div aria-hidden="true">` with absolute positioning. Reliably imports. Slightly less semantic but no fight with the MCP.

3. **Stateful / compound pseudo (`:hover::after`, animations, keyframes):** Use an inline site script that injects a `<style>` tag with `!important`. Apply via Webflow's site scripts at the header location. This is the only working path for things like hover underline animations or keyframe effects. Real-world example from `coverage-map`: `coverageMapHoverCss` site script injects `.coverage-city-link:hover::after{width:100%!important}`.

Do NOT waste time debugging why a compound or animated rule "didn't land" via whtml import — it never will. Choose the right tier at the start of the component build.
