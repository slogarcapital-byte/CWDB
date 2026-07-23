---
tags:
  - type/memory
  - agent/web-dev
created: 2026-04-02
updated: 2026-07-22
status: active
---

# Web Dev Agent Memory — CWDB

Auto-loaded each session. Keep under 150 lines. Details in linked files.

## Site Identity
- **Webflow Site ID:** `69c846db9eee02fddb1e2367` · **Workspace:** `69c8468c7b22dbee46e2fe14`
- **Staging:** https://central-wisconsin-deck-builders.webflow.io · **Live:** cwdeckbuilders.com ([[Webflow]])
- **21-page authority site** — lead gen + local SEO. Full plan: `/business-context/website-plan.md`

## Build Progress
- [Site State & Page IDs](site-state.md) — Phases A–E complete; Phase F (SEO/analytics) and legal pages next
- [Open Items & Blockers](open-items.md) — Phone number missing, /privacy not built (go-live blocker), TCPA done

## Design System
- Colors: `#e54c00` Orange · `#323434` Timber Slate · `#646760` Builders Grey · `#83b2cf` Sky Blue
- Fonts: Staatliches (headlines) · Public Sans (body, labels) — changed from Barlow/Inter in 2026-04-21 site revamp
- Full spec: `/website/design-system.md`

## Components & CMS
- [Component Inventory](component-inventory.md) — 21 confirmed components; naming rules, 3-tier methodology
- [CMS Collections](cms-collections.md) — 5 collections: Service Areas, Gallery Photos, Our Builders, FAQs, Blog Posts

## Key Rules (always apply)
- Webflow MCP first, then sync local HTML — never edit only local files
- Every section must be a named component — no raw sections, no orphaned divs
- 3-tier hierarchy: edit properties → copy+rename → build net new (last resort)
- CMS for any repeating/structured content
- Webflow native forms only — Tally is dead, do not use

## Audit Findings (2026-04-07)
- [Gaps & Missing Info](gaps-identified.md) — Phone number, /privacy page, TCPA (resolved), Our Builders (resolved)

## Platform Quirks (hard-won lessons; read before reaching for the obvious solution)

### Webflow MCP
- [Pseudo-elements stripped by whtml_builder](webflow-mcp-pseudo-elements.md) — `::before`/`::after` silently dropped on import; use `style_tool` with pseudo param OR fall back to aria-hidden div
- [Designer page context shared across parallel agents](webflow-mcp-parallel-agents.md) — concurrent agents fight over active-page state; re-select target page before structural edits
- [Cannot insert siblings adjacent to component instances](webflow-mcp-sibling-insert.md) — `before`/`after` fails with "Cannot insert elements directly into a component instance"; workaround is remove + re-append trailing sections
- [Cannot bind DOM elements to CMS fields](webflow-mcp-cms-binds.md) — Image src/alt + Text content binds + Collection List filter settings are Designer-only; build DOM then hand off to Jim
- [Use display:contents for grid/flex inside Collection List](webflow-collection-list-grid.md) — DynamoWrapper + DynamoList intercept layout; set display:contents on both so items become direct grid/flex children
- [Per-instance Component Property overrides Designer-only on single-locale sites](webflow-mcp-component-bool-props.md) — all override types fail via Data API; Designer MCP has no write path; hand off to Jim in Designer
- [Script slots cap at 15, inline cap at 2000 chars](webflow-mcp-script-constraints.md) — `data_scripts_tool` only exposes `add_inline_site_script`; page-scoped scripts via `upsert_page_script` for >2000 chars; `publish_site` requires domain IDs not hostnames
- [No native Multi-Step Form element](webflow-no-native-multistep.md) — every multi-step is custom JS hiding wizard-step divs. Don't propose "use Webflow native multi-step."
- **Script topology 2026-07-22:** intake relay v2.1.0 lives in the SITE freeform footer (site-wide; covers /service-area/* quote forms too), attribution keeper `cwdb_attribution_keeper` 1.0.0 is a registered inline site script (header). `cwdb_conversion_signal` 1.0.0 is a registered inline site script (slot 11/15, footer): on quote-form success it pushes generate_lead to dataLayer then enforces the form's data-redirect to /thank-you (HubSpot forms integration ignores Webflow's redirect setting). The /get-a-quote page freeform footer is now only a pointer comment. Sources + rollback notes: `website/scripts/`. Registered hosted scripts render as CDN `<script src>` tags, NOT inline — grep for the script name in the src, not its code, when verifying a publish.
- **OAuth scope gap 2026-07-22:** the MCP connection lacks `page_client:write`. ALL of data_element_tool, data_component_tool, data_element_builder, data_whtml_builder fail with OAuthForbidden. Designer tools need Jim's Designer open with the MCP companion app. Working surfaces: sites, pages (settings/SEO/jsonLdSchema), CMS, scripts, forms(read), freeform code. DOM/component edits are blocked until the Webflow app connection is re-authorized with that scope.
- **Page freeform code WAF 2026-07-22:** `set_page_freeform_code` returns HTTP 406 whenever content contains a `<script>` tag (comments/empty writes succeed). Put JSON-LD in page settings via `bulk_update_pages_schema_markup` instead (renders one ld+json block in head). FAQ + Home JSON-LD now live there, freeform head blocks cleared.
- **HubSpot forms integration hijacks quote form (root cause of 6/10 conversion silence):** the HubSpot Webflow app (WB-016 wiring, 2026-06-10/11) adds data-wfhsfieldname attrs + js.hs-scripts.com loader and takes over form#wf-form-Quote-Request submits; it shows the inline success state and never executes the form's configured redirect="/thank-you" (still present in markup and in responseSettings.redirectUrl). Fixed via cwdb_conversion_signal script; if the HubSpot app is ever removed, the native redirect resumes and the script becomes a harmless no-op (it only acts on success).
- **City page JSON-LD was never live in Webflow:** /service-area/* pages render ZERO ld+json blocks; the aggregateRating blocks existed only in local `website/pages/cities/*/content.md` reference files.

### Browser / Device
- [Playwright MCP context dies on idle](playwright-mcp-context-death.md) — first call after idle fails; always run `browser_close` → `browser_navigate("about:blank")` → `browser_resize(1280, 800)` at session start, repeat if error recurs mid-run
- [iOS Safari + flex on `<input type="submit">` swallows tap submits](feedback-ios-flex-submit-bug.md) — WebKit bug killed CWDB form 2026-04-27. Submit inputs stay `inline-block`; flex centering only on `a.btn-submit` anchors

### Site-specific incidents (don't re-introduce)
- [Hero form handoff silent-fail (fixed 2026-05-05 v1.2.0)](hero-form-handoff-silent-fail.md) — `novalidate` + `reportValidity()` is a no-op; drop novalidate and use browser native popups
- [/get-a-quote form rebuild (2026-04-28)](project-form-rebuild-2026-04-27.md) — iOS bug killed, name+email first-class fields, project_type on Step 3, scripts consolidated to 8 site + 1 page-scoped
