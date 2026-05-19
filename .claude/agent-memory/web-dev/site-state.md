---
name: Site State & Page IDs
description: Current Webflow build status, all page IDs, CMS IDs, and phase completion tracking
type: project
tags:
  - type/memory
  - agent/web-dev
created: 2026-04-02
updated: 2026-04-16
status: active
---

# Site State — CWDB Webflow

Last updated: 2026-04-07

## Build Phases

| Phase | Scope | Status |
|---|---|---|
| A — Foundation | Design system, global styles, header, footer, core components | ✅ Complete |
| B — Core conversion | Homepage, /get-a-quote, /thank-you | ✅ Complete |
| C — City pages | Service Areas CMS (28 fields), city template, Wausau/Schofield/Weston/Mosinee/Merrill | ✅ Complete |
| D — Supporting pages | /about, /faq, /gallery, /our-builders + 3 CMS collections | ✅ Complete |
| E — Blog | /cost-calculator, /blog index, blog article template, 4 articles | ✅ Complete |
| F — Legal pages | /privacy, /terms | ❌ Not built — /privacy is go-live blocker |
| G — SEO & analytics | Meta tags, JSON-LD schema, GTM, GA4, Meta Pixel, Nextdoor Pixel, Google Ads conversion, MS Clarity | ❌ Not started |

## Page IDs

| Page | ID | Slug |
|---|---|---|
| Home | `69c846dd9eee02fddb1e2376` | / |
| Get a Quote | `69ce4163e79002c5d4762a57` | /get-a-quote |
| Thank You | `69ce7e7446c34cb2d17b7ffb` | /thank-you |
| Service Areas template | `69cf0c27f69f8fdddb60ccc0` | /service-areas/{slug} |
| About | `69cff11ab796bc97b788f894` | /about |
| FAQ | `69cff2909d6b4ef6581d1c83` | /faq |
| Our Builders | `69cff29d53036270250204d6` | /our-builders |
| Gallery | `69cff2a36004fc5dff348ad5` | /gallery |
| Cost Calculator | `69d04360b87483b9bbc76b04` | /cost-calculator |
| Blog Index | `69d04373a1cf39d4f6680755` | /blog |
| Blog Article template | `69d043662f0a55d546c1f61a` | /blog/{slug} |

**For all other page IDs** (city pages, /privacy, /terms): query `mcp__claude_ai_Webflow__data_pages_tool`

## CMS Collections

| Collection | ID | Items | Notes |
|---|---|---|---|
| Service Areas | `69cf0c26f69f8fdddb60ccba` | 5 | 28 fields; [[Wausau]], [[Schofield]], [[Weston]], [[Mosinee]], [[Merrill]] |
| Gallery Photos | `69cff077a56c28009f3df538` | 7 | Placeholder stock photos — needs real Wisconsin deck photos |
| Our Builders | `69cff079df8b05e8d3935fdf` | 2 | [[Ben Barton]] + [[John Garcia]] (updated 2026-04-07); headshots/bios pending |
| FAQs | `69cff07bd29f3d1624e2ffb9` | 12 | Fully populated |
| Blog Posts | `69d043662f0a55d546c1f597` | 4 | deck-cost-wisconsin, composite-vs-wood, deck-permits-wausau, best-time-build-deck |

## City Template Section Order
global-nav · city-intro-section · faq-section · testimonials · cedar-strip · coverage-area-cards · mobile-sticky-bar · quote-form-inline · global-footer

## Local Reference Files
- Page content: `/website/pages/*/content.md`
- Base template: `/website/templates/base.html`
- Design system: `/website/design-system.md`
- Site architecture: `/website/site-architecture.md`
- Cost calculator JS: `/website/pages/cost-calculator/calculator.js`
