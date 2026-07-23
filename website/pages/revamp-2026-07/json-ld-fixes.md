---
type: page-revamp
page: JSON-LD structured data (all pages)
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# JSON-LD Structured Data: exact old vs new

Structured data is published to Google. It carries the same claims as the visible copy, so it must be swept too. Two problem classes:

1. **Fake `aggregateRating`** on all five city pages (a star rating with `reviewCount: 0`). REMOVE entirely. This is fabricated structured data: FTC exposure plus Google rich-result manual-action risk.
2. **"Connect with vetted contractors" descriptions** and **FAQ answer strings** that mirror the old matching-service copy. Reposition to construction.

Apply these in the JSON-LD block inside each city `content.md`, the Wausau `index.html` commented block, and the FAQ `content.md` JSON-LD block, plus the live Webflow Page Settings > Custom Code where these blocks are published.

---

## Optional across all five city pages: schema @type

Each city block uses `"@type": "LocalBusiness"`. A more accurate type for a deck-building company is `"HomeAndConstructionBusiness"` (a schema.org subtype of LocalBusiness). This is a category, not a license claim, and it reinforces the construction positioning. Recommended but optional. If applied, change `"@type": "LocalBusiness"` to `"@type": "HomeAndConstructionBusiness"` in all five city blocks and the Wausau index.html block.

Also optional (em-dash consistency): the schema `"name"` fields use ": " (em dash), e.g. `"Central Wisconsin Deck Builders: Wausau"`. Per the no-em-dash rule, change each to `"Central Wisconsin Deck Builders (Wausau)"` etc.

---

## Wausau `/wausau` (content.md JSON-LD + index.html commented block)

### REPLACE: description (content.md line 160; index.html line 152)
OLD:
"description": "Connect with vetted local deck contractors in Wausau, Wisconsin. Free quotes for deck replacements, new builds, and composite upgrades.",
NEW:
"description": "A local insured crew that builds, replaces, and refinishes decks in Wausau, Wisconsin. Free on-site walk-through and estimate.",

### REMOVE: aggregateRating (content.md lines 221-226)
REMOVE this entire block (and the trailing comma on the `hasOfferCatalog` block that precedes it):
```
"aggregateRating": {
  "@type": "AggregateRating",
  "ratingValue": "4.8",
  "reviewCount": "0",
  "bestRating": "5"
}
```
(The index.html commented JSON-LD has no aggregateRating, so nothing to remove there.)

---

## Schofield `/schofield` (content.md JSON-LD)

### REPLACE: description (line 156)
OLD:
"description": "Find vetted local deck builders in Schofield, Wisconsin. Free quotes for new deck construction, repairs, and composite upgrades.",
NEW:
"description": "A local insured crew building, repairing, and refinishing decks in Schofield, Wisconsin. Free on-site walk-through and estimate.",

### REMOVE: aggregateRating (lines 217-222)
REMOVE the full `aggregateRating` block (ratingValue "4.8", reviewCount "0").

---

## Weston `/weston` (content.md JSON-LD)

### REPLACE: description (line 160)
OLD:
"description": "Custom deck construction and outdoor living spaces in Weston, Wisconsin. Free quotes from vetted local contractors. Composite upgrades and multi-level designs.",
NEW:
"description": "Custom deck construction and outdoor living spaces in Weston, Wisconsin, built by a local insured crew. Composite upgrades and multi-level designs.",

### REMOVE: aggregateRating (lines 221-226)
REMOVE the full `aggregateRating` block (ratingValue "4.9", reviewCount "0").

---

## Mosinee `/mosinee` (content.md JSON-LD)

### REPLACE: description (line 156)
OLD:
"description": "Trusted deck contractors in Mosinee, Wisconsin. Free quotes for new deck builds, replacements, and repairs. Built for river-town living.",
NEW:
"description": "A local insured crew that builds, replaces, and repairs decks in Mosinee, Wisconsin. Built for river-town living. Free on-site walk-through.",

### REMOVE: aggregateRating (lines 217-222)
REMOVE the full `aggregateRating` block (ratingValue "4.7", reviewCount "0").

---

## Merrill `/merrill` (content.md JSON-LD)

### REPLACE: description (line 160)
OLD:
"description": "Affordable deck construction and replacement in Merrill, Wisconsin. Free quotes from vetted local contractors serving Lincoln County.",
NEW:
"description": "Affordable deck construction, replacement, and repair in Merrill, Wisconsin, from a local insured crew serving Lincoln County.",

### REMOVE: aggregateRating (lines 231-236)
REMOVE the full `aggregateRating` block (ratingValue "4.8", reviewCount "0").

---

# FAQ Page JSON-LD (`faq/content.md` lines 173-277)

These answer strings mirror the visible FAQ answers changed in `faq.md`. Keep them in sync or Google sees a mismatch between the page and its structured data.

### REPLACE: Q1 answer (line 184)
OLD:
"text": "You fill out a quick form telling us about your deck project. We review your request and match you with a vetted, licensed contractor in your area. The contractor reaches out to discuss your project and provide a detailed quote. The whole process is free for homeowners, and there's never any obligation to move forward."
NEW:
"text": "You fill out a quick form about your deck project. We reach out to set up a free on-site walk-through, usually within one business day. Our insured local crew measures, talks through options, and gives you a clear, itemized estimate. Free, with no obligation to move forward."

### REPLACE: Q3 answer (line 200)
OLD:
"text": "Most homeowners hear from a contractor within 48 hours."
NEW:
"text": "Most homeowners hear from us within one business day. We reach out to book your free walk-through as soon as we see your request."

### REPLACE: Q4 question + answer (lines 205-208)
OLD (name):
"name": "How do you choose which contractors are in your network?",
OLD (text):
"text": "Every contractor goes through a vetting process. We verify active Wisconsin contractor license, general liability insurance, workers' compensation coverage, track record of residential deck projects, and customer references."
NEW (name):
"name": "Who actually builds my deck?",
NEW (text):
"text": "Your deck is built by our own crew: experienced local builders working under the Central Wisconsin Deck Builders name. We are fully insured, we build to Wisconsin code, and we handle your project from walk-through to final board."

### REPLACE: Q6 answer (line 224)
OLD:
"text": "Our contractors handle new deck construction, multi-level and wraparound decks, composite and PVC decking, pressure-treated wood decks, cedar and hardwood decks, deck repairs, resurfacing, screened porches, pergolas, and railing and stair upgrades."
NEW:
"text": "We handle new deck construction, multi-level and wraparound decks, composite and PVC decking, pressure-treated wood decks, cedar and hardwood decks, deck repairs, resurfacing, screened porches, pergolas, and railing and stair upgrades."

### REPLACE: Q8 answer (line 240)
OLD:
"text": "In most cases, yes. Wisconsin municipalities generally require a building permit for new deck construction and significant structural modifications. Your contractor typically handles the permit application as part of the project."
NEW:
"text": "In most cases, yes. Wisconsin municipalities generally require a building permit for new deck construction and significant structural modifications. We handle the permit application as part of the project."

### REPLACE: Q9 answer (line 248)
OLD:
"text": "Common materials include pressure-treated lumber, composite decking (Trex, TimberTech), PVC decking, cedar, and hardwoods like ipe. Your contractor can recommend the best material for your budget and preferences."
NEW:
"text": "Common materials include pressure-treated lumber, composite decking (Trex, TimberTech), PVC decking, cedar, and hardwoods like ipe. At your walk-through we'll recommend the best material for your budget and preferences."

### REPLACE: Q11 question + answer (lines 261-264)
OLD (name):
"name": "Can I choose which contractor I work with?",
OLD (text):
"text": "We match you with the best-fit contractor based on location, availability, and specialization. As our network grows, you may receive quotes from multiple builders and choose your preferred one."
NEW (name):
"name": "Do you do the work yourselves, or subcontract it out?",
NEW (text):
"text": "We do the work with our own local crew. The people who walk your project and write your estimate are the people who build your deck."

### REPLACE: Q12 answer (line 272)
OLD:
"text": "Your contact and project details are shared only with the vetted contractor(s) matched to your project. We do not sell your information to marketing lists or unrelated third parties."
NEW:
"text": "Your contact and project details are used by our team to plan and build your deck. We do not sell your information to marketing lists or unrelated third parties."

---

## FLAG: Terms of Service is NOT structured data but is the deepest positioning conflict

`website/pages/terms/content.md` §2 declares CWDB "operates an online platform that connects homeowners with vetted, licensed deck building contractors" and "We are not a general contractor, construction company, or builder. We do not perform any construction work." That directly contradicts the repositioning and the completed, paid Overbeck self-perform job. It also anchors the site's liability structure (the $100 liability cap, the indemnification, the "we are not a party to any agreement" language all depend on the referral framing).

Do not marketing-rewrite this. Route `terms` (and `privacy`, which describes sharing data with "matched contractors") to legal-compliance-counsel to redraft for the two-lane self-perform + builder model. This is called out in the README and in `home.md` "Beyond the ask" as well.
