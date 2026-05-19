---
name: CMS Collections
description: All Webflow CMS collections with IDs, field counts, item counts, and binding notes
type: project
tags:
  - type/memory
  - agent/web-dev
created: 2026-04-02
updated: 2026-04-16
status: active
---

# CMS Collections — CWDB Webflow

Last updated: 2026-04-07

## Service Areas
- **Collection ID:** `69cf0c26f69f8fdddb60ccba`
- **Fields:** 28
- **Items:** 5 — [[Wausau]], [[Schofield]], [[Weston]], [[Mosinee]], [[Merrill]]
- **Bound to:** City page template (`69cf0c27f69f8fdddb60ccc0`)
- **Notes:** Most complex collection; includes city-specific copy, FAQs, contractor names, service radius, schema fields

## Gallery Photos
- **Collection ID:** `69cff077a56c28009f3df538`
- **Fields:** ~7
- **Items:** 7
- **Bound to:** `/gallery` page (`gallery-grid-lightbox` component)
- **Notes:** All items are placeholder stock photos. Replace with real Wisconsin deck project photos before go-live.

## Our Builders
- **Collection ID:** `69cff079df8b05e8d3935fdf`
- **Fields:** 9 — name, slug, business-name, bio (RichText), service-area, specialties, headshot (Image), years-in-business (Number), license-number
- **Items:** 2 (updated 2026-04-07)
  - [[Ben Barton]] — `69cff0a989e454afdd3f5788` — Barton Builders LLC — Wausau, WI
  - [[John Garcia]] — `69d4b9e6b553503a6618ddbf` — John Garcia Construction, LLC — Edgar, WI
- **Bound to:** `/our-builders` page (`builders-grid` component)
- **Notes:** Bios, headshots, specialties, license numbers, and years in business are all pending. No Phone or Email fields exist in the schema (not added — those aren't displayed on the public page).

## FAQs
- **Collection ID:** `69cff07bd29f3d1624e2ffb9`
- **Fields:** ~4 (question, answer, category, order)
- **Items:** 12
- **Bound to:** `/faq` page (`faq-section-full` component)
- **Notes:** Fully populated. FAQPage JSON-LD needs to be added manually to FAQ page `<head>`.

## Blog Posts
- **Collection ID:** `69d043662f0a55d546c1f597`
- **Fields:** ~10 (title, slug, body, excerpt, category, read-time, published-date, featured-image, author, tags)
- **Items:** 4
  - `deck-cost-wisconsin`
  - `composite-vs-wood`
  - `deck-permits-wausau`
  - `best-time-build-deck`
- **Bound to:** `/blog` index (`blog-index-grid`) + blog article template (`article-hero-section`, `article-body-section`)
- **Notes:** Article JSON-LD schema needs to be added manually to blog article template `<head>`.

## CMS Usage Rules
- Always design component with placeholder content first, then bind to CMS
- Use CMS when: multiple pages share same content structure, OR single page has repeating content following a pattern
- Never hard-code repeating content when CMS is the right fit
- CMS-bound components get cleaner API access and consistent data structure
