---
name: /get-a-quote form rebuild complete (surgical fix landed 2026-04-28)
description: iOS submit bug killed, name+email are real Webflow fields, project_type moved to Step 3, scripts consolidated 15→8 applied + 1 page-scoped. Verified by Jim on iPhone 11 Safari + Chrome.
originSessionId: 7a0b1919-ea22-4cce-8eed-19785562bedd
title: /get-a-quote form rebuild complete (surgical fix landed 2026-04-28)
type: memory
memory_type: project
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/project-form-rebuild-2026-04-27.md
tags:
  - type/memory
  - memory/project
---
The /get-a-quote form rebuild from session 2026-04-27 landed in production at 2026-04-28 03:31 UTC.

**Final architecture:**
- Form id `wf-form-Quote-Request` (unchanged)
- Step 1: zip, phone (matches homepage hero handoff)
- Step 2: name, email, address, owns_property
- Step 3: project_type (FIRST), budget, timeline, notes, tcpa_consent
- Submit button: `<input type="submit">`, `display: block` (iOS-safe, no flex)
- Next anchors: `<a class="btn-submit w-button">`, `display: inline-flex` (anchor-safe)
- All fields are first-class Webflow form fields (no JS injection)

**Site-applied scripts (8/15):**
- gtm_head_snippet 1.1.0
- coverageMapHoverCss 1.1.0
- galleryFeaturedHover 1.1.0
- faqHomeToggle 1.1.0
- cwdbCalcCss 1.1.0
- multistepwizard 1.1.0 (handles wizard step visibility — keep)
- hero_form_handoff 1.1.0 (homepage hero → /get-a-quote URL-param navigation)
- cwdb_site_polish 2.0.1 (consolidated replacement for 5x launch_polish + 3x round_2_fixes; CDN-hosted; 4368 chars; cannot be modified via MCP without manual paste)

**Page-scoped script on /get-a-quote only:**
- quote_page_polish 1.0.0 — does two things: (a) `a.btn-submit { display: inline-flex; align-items: center; justify-content: center }` for Next button text centering, (b) URL-param prefill that reads `?zip=...&phone=...` on page load and populates Step 1.

**Why:** The pre-rebuild form had a confirmed iOS submit bug from `display: inline-flex !important` on the submit input, runtime field injection of firstname+email by `cwdb_round_2_fixes`, and 15/15 stacked legacy scripts saturating site capacity. All resolved.

**How to apply:**
- Don't restack legacy `cwdb_launch_polish` or `cwdb_round_2_fixes` versions — they're deleted from the registry.
- Don't re-add `display: inline-flex` to `.btn-submit.w-button` (the input). Anchor-only flex is fine.
- New site-wide CSS/JS goes into `cwdb_site_polish` next minor version (manual paste required if >2000 chars).
- New /get-a-quote-only logic goes into `quote_page_polish` page-scoped script.
- Designer panel still shows "Field 2" labels for owns_property, budget, timeline, project_type — Jim to manually rename in Designer when convenient (HTML name attributes are correct; cosmetic only).

Plan file (preserved for reference): `C:\Users\jslog\.claude\plans\web-dev-agent-emergency-my-velvety-spark.md`.
