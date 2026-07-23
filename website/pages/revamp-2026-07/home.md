---
type: page-revamp
page: Homepage
url: /
source: website/pages/homepage/content.md
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# Homepage Revamp: `/`

Repositions the homepage from "we match you with builders" to "we build, repair, and refinish decks." Removes the "Licensed" trust claim. Reworks the process so step 2/3 point at a walk-through and estimate, not a matched contractor callback.

Live copy source: `website/pages/homepage/content.md`. Meta title/description handled in `meta-descriptions.md`.

---

## 1. Hero: `hero-split`

### REPLACE: hero headline
OLD:
Get a quote within 48 hours.
NEW:
Decks built right, by a local crew.

### REPLACE: hero subtext
OLD:
Vetted builders in Wausau, Schofield, Weston, Mosinee, and Merrill. Enter your zip and we'll match you in hours.
NEW:
Central Wisconsin Deck Builders designs, builds, replaces, and refinishes decks in Wausau, Schofield, Weston, Mosinee, and Merrill. Tell us about your deck and we'll set up a free on-site walk-through, usually within one business day.

### REPLACE: hero trust row (also lives in `hero-split.md` and `design-system.md`, see shared-components.md)
OLD:
✓ Licensed · ✓ Insured · ✓ Free
NEW:
✓ Insured · ✓ Local crew · ✓ Free walk-through

### CTA note (optional, web-dev + Jim call)
The micro-form and button can keep the label "Start My Quote →". If you want the button to match the new funnel, use **"Get My Free Estimate →"**. Copy does not depend on which you pick.

---

## 2. Builders strip: `builders-strip`

No compliance issue. One positioning tweak so the strip reads as "the people who build your deck," not "vendors in a network."

### REPLACE: builders-strip label
OLD:
YOUR LOCAL BUILDERS:
NEW:
THE CREW THAT BUILDS IT:

(Ben Barton and John Garcia rows stay exactly as-is. "Meet the team →" link stays.)

---

## 3. Process: `process-steps-v2`

### REPLACE: section heading
OLD:
Three steps. One quote.
NEW:
Three steps. One local crew.

### REPLACE: Step 02 title
OLD:
Step 02 — Get matched with a local builder
NEW:
Step 02: We come out for a free walk-through

### REPLACE: Step 02 body
OLD:
We hand-match based on city and project type.
NEW:
We visit your place, measure, and talk through what you want. Usually within one business day of your request.

### REPLACE: Step 03 body
OLD:
Builder reaches out within 48 hours to schedule a site visit.
NEW:
You get a clear, itemized estimate and we lock in a build date that works for you.

---

## 4. Gallery: `gallery-featured`

### REPLACE: section heading (already close; tighten to construction framing)
OLD:
Recent Central Wisconsin builds
NEW:
Decks we've built and refinished around Central Wisconsin

No other change. Real photos only. When Jim adds a caption for the completed Overbeck-area refinishing job, it can read "Deck refinishing · Wausau area" with no invented homeowner quote.

---

## 5. Coverage: `coverage-map`

No change. "We serve Central Wisconsin" is accurate and already construction-voiced.

---

## 6. FAQ: `faq-section-home`

No change on the homepage module itself (it is CMS-bound to the FAQ collection). The FAQ answers change in `faq.md`.

---

## 7. Final CTA: `cta-final`

### REPLACE: headline (this default string also lives in `cta-final.md` and several city/blog page headers, see shared-components.md)
OLD:
Start your deck quote. 48-hour response from a local builder.
NEW:
Ready to build? Get a free estimate from a local crew, usually within one business day.

---

## 8. Footer

No change. Tagline "Fast Quotes. Trusted Builders." stays.

---

## Copy Rules block: update the source note

`homepage/content.md` has a "Copy Rules (enforce site-wide)" block that still hard-codes the old promise. Update it so future copy stays on-model.

### REPLACE: copy rule line
OLD:
- "48-hour response" is the concrete promise — not "fast" or "quick"
NEW:
- "Usually within one business day" is the honest response commitment. Never promise a fixed 24- or 48-hour window.

### REPLACE: copy rule line
OLD:
- Subtext never uses "no cost, no pressure, no obligation" filler
NEW:
- Lead with the work (build, replace, refinish) and the crew. "Free walk-through" and "insured" are the trust anchors. Never claim "licensed" or "bonded" until the DSPS license issues.

---

## Beyond the ask: claims I found that were not on the brief

These are real exposures uncovered during the sweep. Listed here once; each is also flagged in its own file.

1. **Fabricated named testimonials are live on the Wausau page.** `website/pages/cities/wausau/index.html` lines 122-133 carry three invented quotes attributed to real-sounding people ("Sarah M.: Wausau, WI," "Mike T.: Wausau, WI," "Jennifer K.: Schofield, WI"). This is the sharpest FTC 16 CFR 255/465 exposure on the site because the quotes are attributed to named individuals. Removed in `city-wausau.md` and `json-ld-fixes.md`.

2. **Fake `aggregateRating` in all five city JSON-LD blocks.** Each city page publishes `"aggregateRating": { "ratingValue": "4.7"–"4.9", "reviewCount": "0" }`. A star rating with zero reviews is fabricated structured data (FTC exposure + Google rich-result manual action risk). Removed in `json-ld-fixes.md`.

3. **Terms of Service contradicts reality and the pivot.** `website/pages/terms/content.md` §2 says CWDB "operates an online platform that connects homeowners with vetted, licensed deck building contractors" and "We are not a general contractor, construction company, or builder. We do not perform any construction work." CWDB self-performed and was paid for the Overbeck job, so this is false, and it undercuts the whole repositioning. **Do not marketing-rewrite this. Route `terms` and `privacy` to legal-compliance-counsel** to redraft the service description and liability structure for the two-lane (self-perform + builder) model.

4. **License-verification claims about the crew.** The FAQ and Our Builders pages state that CWDB verifies each contractor's "Active Wisconsin contractor license," and Our Builders lists "License #: Verified" / "License: Licensed." These assert a licensing fact we cannot substantiate here. Softened to insurance + experience + local + references in `faq.md` and `our-builders.md`.

5. **`base.html` template still carries the old model end-to-end** (Licensed & insured badges, "matched with a local builder," 48-hour promise, three "Placeholder: real testimonial coming soon" cards). It is a reference template, not the live page, but it will re-seed the old claims if reused. Fixed in `shared-components.md`.

6. **The `/our-builders` page and the "Join Our Builder Network" CTA** read as a contractor directory. Under the new model the builder-recruitment path is a secondary product. Repositioned (not deleted) in `our-builders.md`.
