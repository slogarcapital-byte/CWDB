---
tags:
  - type/memory
  - agent/web-dev
created: 2026-04-02
updated: 2026-04-16
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
- Fonts: Barlow Condensed (headlines, uppercase) · Inter (body, labels)
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
