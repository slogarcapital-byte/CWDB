---
type: doc
dept: website
created: 2026-07-22
status: ready-for-web-dev
tasks:
  - audit-2026-07-05#13 (compliance sweep)
  - audit-2026-07-05#21 (repositioning to construction company)
---

# Website Revamp: July 2026 (Tasks 13 + 21)

Copy-only deliverable. A web-dev pass applies these REPLACE blocks to the live Webflow site afterward. Nothing here touches Webflow.

## Why this exists

CWDB pivoted 2026-07-05 from a lead broker (sell homeowner leads to contractors) to a **deck construction company that self-performs, fed by its own lead engine**. Jim is the operator. Every page still reads like a quote-matching directory ("we connect you with vetted builders," "we match you"). Two jobs:

- **Task 13 (compliance sweep):** strip claims that are not true yet.
- **Task 21 (repositioning):** make the site read as "we build, repair, and refinish decks," and turn /thank-you into a walk-through booking page.

## Ground truth used for every rewrite (2026-07-22)

- **License:** DSPS Dwelling Contractor license is IN PROGRESS, NOT issued. Do not claim "licensed." Do not claim "bonded."
- **Insurance:** TRUE. $1M/$2M general liability, bound ~2026-06-25. "Insured" / "fully insured" is allowed and encouraged.
- **Real completed work:** the Overbeck job (a completed deck staining/refinishing project in the Wausau area, paid in full) is real and can be referenced generically as "a completed Wausau-area project." Do not invent a quote for it.
- **The crew:** Ben Barton (Barton Builders LLC) and John Garcia (John Garcia Construction LLC) are real, signed builders who do the structural building. First-person "we build" is honest when the building is done by our crew and builders.
- **Response promise:** Jim owns all follow-up and walk-throughs. Honest commitment is "we answer fast, usually within one business day." No 24- or 48-hour guarantee.

## How to read a REPLACE block

Each block is mechanical. Find OLD on the live page/CMS field, swap in NEW.

```
### REPLACE: <where>
OLD:
<exact current text>
NEW:
<exact new text>
```

Blocks marked **REMOVE** delete an element entirely (no replacement). Blocks marked **NEW PAGE** or **NEW SECTION** are additive.

**About the em dashes you will see in OLD/REMOVE blocks:** the current live site uses em dashes in many headlines and body strings. Those are reproduced verbatim inside OLD and REMOVE blocks so the find matches exactly. Every NEW string and all of the instructional text in this package follow the project's no-em-dash rule (colon, comma, or parentheses instead). Do not "fix" the em dashes inside OLD blocks or the match will break.

## File map

| File | Page / target | Live source of truth |
|---|---|---|
| `home.md` | Homepage `/` | `website/pages/homepage/content.md` + Webflow |
| `about.md` | `/about` | `website/pages/about/content.md` |
| `services.md` | `/services` (**NEW PAGE**, proposed) | none yet |
| `faq.md` | `/faq` | `website/pages/faq/content.md` |
| `get-a-quote.md` | `/get-a-quote` | `website/pages/get-a-quote/content.md` |
| `our-builders.md` | `/our-builders` | `website/pages/our-builders/content.md` |
| `thank-you.md` | `/thank-you` (**becomes booking page**) | `website/pages/thank-you/content.md` + `index.html` |
| `gallery.md` | `/gallery` | `website/pages/gallery/content.md` |
| `city-wausau.md` | `/wausau` | `website/pages/cities/wausau/content.md` + `index.html` |
| `city-schofield.md` | `/schofield` | `website/pages/cities/schofield/content.md` |
| `city-weston.md` | `/weston` | `website/pages/cities/weston/content.md` |
| `city-mosinee.md` | `/mosinee` | `website/pages/cities/mosinee/content.md` |
| `city-merrill.md` | `/merrill` | `website/pages/cities/merrill/content.md` |
| `shared-components.md` | `base.html` template + hero/cta/process components + design-system badges | `website/templates/base.html`, `website/components/*`, `website/design-system.md` |
| `meta-descriptions.md` | every meta title + description that changes | all frontmatter + `index.html` `<meta>` |
| `json-ld-fixes.md` | every JSON-LD block | city `content.md` + `index.html` |

## Flagged for a different owner (NOT rewritten here)

These need legal-compliance-counsel, not marketing copy. See the "Beyond the ask" section at the bottom of `home.md` for the full list. The big one: **`website/pages/terms/content.md` still states "CWDB is a referral and matching service. We are not a general contractor, construction company, or builder. We do not perform any construction work."** That is now both off-positioning and factually contradicted by the Overbeck job. Route to legal before touching.
