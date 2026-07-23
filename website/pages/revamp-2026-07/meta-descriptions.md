---
type: page-revamp
page: Meta titles + descriptions (all pages)
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# Meta Titles & Descriptions: exact old vs new

Every page's SEO title, meta description, and OG title/description that changes. Apply in the page's frontmatter (`content.md`) AND in the live Webflow page SEO settings / `index.html` `<meta>` tags where noted. Titles kept at or under 60 characters, descriptions at or under 155.

Two cross-cutting fixes baked in here:
- **"Licensed" removed** everywhere (Merrill's OG description was the last one still saying "from licensed local builders").
- **Em dashes removed** from every title and description per the project's no-em-dash standing rule. Several existing OG titles and city descriptions used em dashes; all new strings use a colon, comma, or pipe instead.

---

## Homepage `/`

### REPLACE: seo_title
OLD:
Deck Builders in Central Wisconsin | Free Quotes — CWDB
NEW:
Deck Builders in Central Wisconsin | Build, Repair, Refinish

### REPLACE: meta_description
OLD:
Get a deck quote within 48 hours. Vetted builders in Wausau, Schofield, Weston, Mosinee, and Merrill. Enter your zip to get matched.
NEW:
We build, replace, and refinish decks across Wausau, Schofield, Weston, Mosinee, and Merrill. Insured local crew. Free on-site walk-through.

---

## About `/about`

(seo_title "About Us | Central Wisconsin Deck Builders" stays.)

### REPLACE: meta_description (content.md + about/index.html lines 53 and 58)
OLD:
CWDB connects Central Wisconsin homeowners with vetted, licensed deck contractors. Learn how we make finding a trusted builder fast and easy.
NEW:
Central Wisconsin Deck Builders is a local, insured crew that builds, replaces, and refinishes decks in the Wausau area. Meet the team.

---

## FAQ `/faq`

### REPLACE: meta_description
OLD:
Get answers about deck quotes, costs, permits, materials, and how Central Wisconsin Deck Builders connects you with vetted local contractors.
NEW:
Answers on deck costs, permits, materials, timelines, and how we build, replace, and refinish decks across Central Wisconsin.

---

## Get a Quote `/get-a-quote`

### REPLACE: seo_title (optional but recommended)
OLD:
Get a Free Deck Quote | Central Wisconsin Deck Builders
NEW:
Get a Free Deck Estimate | Central Wisconsin Deck Builders

### REPLACE: meta_description (content.md frontmatter)
OLD:
Get a deck quote within 48 hours. 3-step form, vetted local builders, no cost. Serving Wausau, Schofield, Weston, Mosinee, Merrill.
NEW:
Tell us about your deck in 3 quick steps. We book a free on-site walk-through, usually within one business day. Serving the Wausau area.

### REPLACE: meta_description (get-a-quote/index.html line 7)
OLD:
Request a free, no-obligation deck quote from vetted contractors in Central Wisconsin. Tell us about your project and hear back within 24 hours.
NEW:
Request a free, no-obligation deck estimate from a local insured crew in Central Wisconsin. Tell us about your project and we'll book a walk-through.

---

## Our Builders `/our-builders`

### REPLACE: meta_description (content.md + our-builders/index.html lines 52 and 57)
OLD:
Meet the vetted, licensed deck contractors in our Central Wisconsin network. Every builder is insured, experienced, and committed to quality.
NEW:
Meet the insured local crew that builds your deck. Experienced Central Wisconsin builders committed to quality, from walk-through to final board.

---

## Thank You `/thank-you` (noindex, refresh anyway)

### REPLACE: meta_description
OLD:
Your deck quote request has been received. Here's what happens next.
NEW:
Thanks for reaching out. Book your free on-site deck walk-through, or call us at (715) 544-7941.

---

## Gallery `/gallery`

### REPLACE: meta_description
OLD:
Browse completed deck projects in Central Wisconsin. See composite decks, multi-level builds, and more from our vetted local contractors.
NEW:
Browse decks we've built and refinished across Central Wisconsin. Composite, multi-level, and more. Real projects from a local insured crew.

---

## Wausau `/wausau`

### REPLACE: title (content.md `title` + Webflow seo-title; old is 65 chars, over limit)
OLD:
Deck Builders in Wausau, WI | Free Quotes from Trusted Contractors
NEW:
Deck Builders in Wausau, WI | Build, Repair & Refinish

### REPLACE: description (content.md `description` + index.html line 11 + CMS meta-description lines 113-115)
OLD:
Get free deck quotes from vetted deck builders in Wausau, WI. Licensed, insured contractors respond within 24 hours. Serving Wausau and surrounding Marathon County.
NEW:
We build, replace, and refinish decks in Wausau, WI. Insured local crew, free on-site walk-through. New builds, replacements, composite upgrades.

### REPLACE: og_title (content.md line 22)
OLD:
Deck Builders in Wausau, WI — Get Your Free Quote Today
NEW:
Deck Builders in Wausau, WI | Free On-Site Estimate

### REPLACE: og_description (content.md line 23 + index.html line 17)
OLD (content.md):
Connect with pre-vetted Wausau deck contractors. Free quotes, no obligation. New builds, replacements, and composite upgrades.
OLD (index.html line 17):
Get free deck quotes from vetted deck builders in Wausau, WI. Licensed, insured contractors. Fast quotes within 24 hours.
NEW (use for both):
A local insured crew building, replacing, and refinishing decks in Wausau. Free walk-through, no obligation.

---

## Schofield `/schofield`

### REPLACE: description
OLD:
Find trusted deck builders in Schofield, Wisconsin. New construction decks, repairs, and upgrades. Get a free quote from a vetted local contractor.
NEW:
A local insured crew building, repairing, and upgrading decks in Schofield, WI. New construction to refinishing. Free on-site walk-through.

### REPLACE: og_title
OLD:
Deck Builders in Schofield, WI — Free Quote, No Obligation
NEW:
Deck Builders in Schofield, WI | Free Estimate

### REPLACE: og_description
OLD:
Schofield homeowners — get a free deck quote from a vetted local contractor. New builds, repairs, and composite upgrades.
NEW:
Schofield homeowners: we build, repair, and refinish decks. Insured local crew, free on-site walk-through, no obligation.

---

## Weston `/weston`

### REPLACE: description
OLD:
Get a free deck quote in Weston, Wisconsin. Composite upgrades, multi-level designs, and outdoor living spaces from vetted local contractors.
NEW:
We build custom decks and outdoor living spaces in Weston, WI. Composite upgrades and multi-level designs. Insured local crew, free walk-through.

### REPLACE: og_title
OLD:
Deck Builders in Weston, WI — Custom Designs, Free Quotes
NEW:
Deck Builders in Weston, WI | Custom Designs

### REPLACE: og_description
OLD:
Weston homeowners — connect with vetted deck contractors for composite upgrades, multi-level builds, and outdoor living spaces. Free quotes.
NEW:
Weston homeowners: we build composite upgrades, multi-level decks, and outdoor living spaces. Insured local crew, free walk-through.

---

## Mosinee `/mosinee`

### REPLACE: description
OLD:
Mosinee homeowners — get a free deck quote from a trusted local contractor. New builds, repairs, and seasonal deck projects on the Wisconsin River.
NEW:
Mosinee homeowners: we build, replace, and repair decks for river-town living. Insured local crew, free on-site walk-through, no obligation.

### REPLACE: og_title
OLD:
Deck Builders in Mosinee, WI — Get a Free Quote Today
NEW:
Deck Builders in Mosinee, WI | Free Estimate

### REPLACE: og_description
OLD:
Mosinee deck contractors ready to build. New decks, repairs, and upgrades for river-town living. Free quotes, no obligation.
NEW:
A local insured crew building, replacing, and repairing decks in Mosinee. Free walk-through, no obligation.

---

## Merrill `/merrill`

### REPLACE: description
OLD:
Merrill homeowners — get a free deck quote from vetted local contractors. Affordable new builds, repairs, and replacements in the City of Parks.
NEW:
Merrill homeowners: we build, replace, and repair decks across Lincoln County. Affordable, insured local crew. Free on-site walk-through.

### REPLACE: og_title
OLD:
Deck Builders in Merrill, WI — Free Quotes, Trusted Contractors
NEW:
Deck Builders in Merrill, WI | Free Estimate

### REPLACE: og_description (this one still says "licensed")
OLD:
Merrill deck contractors ready to build. Affordable new decks, replacements, and repairs from licensed local builders. Free quotes.
NEW:
Affordable deck building, replacement, and repair in Merrill and Lincoln County. Insured local crew, free walk-through, no obligation.

---

## Note on the Terms and Privacy meta

`terms` and `privacy` are noindex and their meta is generic. Do not edit their copy here. They are flagged for legal-compliance-counsel (see README and json-ld-fixes.md) because the body text, not the meta, carries the "referral and matching service / we do not perform construction work" problem.
