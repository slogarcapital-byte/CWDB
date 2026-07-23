---
type: page-revamp
page: Our Builders
url: /our-builders
source: website/pages/our-builders/content.md + website/pages/our-builders/index.html
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# Our Builders Revamp: `/our-builders`

Reframes from "our network of vetted contractors" (directory) to "meet the crew that builds your deck." Removes "licensed" verification claims and the "License #: Verified" / "License: Licensed" fields. Keeps Ben Barton and John Garcia as the real builders. Softens (does not delete) the builder-recruitment CTA, since the builder-lane partnership is still a secondary product.

Live sources: `website/pages/our-builders/content.md` and `website/pages/our-builders/index.html`.

---

## Hero Section

### REPLACE: headline
OLD:
Meet Our Trusted Builders
NEW:
Meet the Crew

### REPLACE: subtext
OLD:
Every contractor in our network has been vetted for licensing, insurance, experience, and reputation. We don't work with just anyone — and that's the point.
NEW:
These are the local builders who show up, measure, and build your deck. Insured, experienced, and from right here in Central Wisconsin. When you hire us, these are the people on your job.

---

## Vetting Process Section: reframe to "How We Work"

### REPLACE: section heading
OLD:
How We Choose Our Contractors
NEW:
How We Work

### REPLACE: body (drop the license-verification checklist; state what's true)
OLD:
Not every contractor makes the cut. Before a builder joins the CWDB network, we verify:

- **Active state license** — Confirmed with the Wisconsin Department of Safety and Professional Services
- **General liability insurance** — Minimum coverage to protect your property and investment
- **Workers' compensation** — Coverage for every crew member on your job site
- **Track record** — Proven history of completed residential deck projects in Central Wisconsin
- **Customer references** — Verified feedback from past homeowners

We check these credentials before a builder joins — and we continue to monitor them over time. If a contractor doesn't meet our standards, they don't stay in the network.
NEW:
We keep it simple. One insured local crew handles your deck from start to finish:

- **Fully insured**: We carry $1M/$2M general liability insurance, so your property and investment are covered.
- **Real experience**: Our builders have years of completed residential deck work across Central Wisconsin.
- **Built to code**: We build for Wisconsin frost depth, snow load, and freeze-thaw, and we pull the permits.
- **One point of contact**: The person who walks your project is the person who builds it.

---

## Contractor Profile Cards: reframe

### REPLACE: the "Launch Profile: Placeholder Contractor" block
This placeholder card ("Name: Coming Soon," "License #: Verified," "Licensed, insured, and committed...") should be replaced with the two real builders. Use real profile cards for Ben Barton and John Garcia. Remove the License # line entirely; use Insured + Experience + Service Area.

REMOVE (our-builders/content.md lines 73-89, the placeholder profile) and REPLACE with two cards:

**Card 1**
- **Name:** Ben Barton
- **Company:** Barton Builders LLC
- **Service Area:** Wausau, Schofield, Weston, Mosinee, Merrill
- **Focus:** New builds, composite and pressure-treated decks, multi-level designs
- **Bio:** [Bio pending — replace with Ben-provided copy. Do not fabricate.] Ben builds decks across the Wausau area with Central Wisconsin Deck Builders. Insured and local.

**Card 2**
- **Name:** John Garcia
- **Company:** John Garcia Construction LLC
- **Service Area:** Merrill, Wausau, and Lincoln County
- **Focus:** New builds, repairs and replacements, refinishing
- **Bio:** [Bio pending — replace with John-provided copy. Do not fabricate.] John builds and repairs decks across Central Wisconsin with Central Wisconsin Deck Builders. Insured and local.

### REPLACE: index.html John Garcia license row (our-builders/index.html line 141)
REMOVE the entire license row:
```
<div style="display:flex; gap:8px;"><span ...>License:</span><span ...>Licensed</span></div>
```
Do not replace with a license claim. If a labeled row is wanted in its place, use "Insured: Yes" or "Local: Central Wisconsin."

### REPLACE: index.html John Garcia bio (our-builders/index.html line 144)
OLD:
John Garcia is the owner of John Garcia Construction, LLC, a licensed contractor serving Central Wisconsin. [Bio pending — to be updated with contractor-provided copy.]
NEW:
John Garcia is the owner of John Garcia Construction, LLC, an insured local builder serving Central Wisconsin. [Bio pending: to be updated with builder-provided copy.]

### REPLACE: index.html subhead (our-builders/index.html line 113)
OLD:
Vetted, licensed deck contractors ready to serve your project.
NEW:
Insured local builders ready to build your project.

### REPLACE: content.md placeholder bio "licensed" line (line 87), if the placeholder card is kept temporarily
OLD:
Our first contractor partner brings over a decade of deck building experience in the Wausau area. They specialize in both composite and pressure-treated builds, from simple backyard decks to custom multi-level designs. Licensed, insured, and committed to getting the job done right.
NEW:
Our lead builder brings over a decade of deck building experience in the Wausau area, specializing in composite and pressure-treated builds from simple backyard decks to custom multi-level designs. Insured, local, and committed to getting the job done right.

---

## Bottom CTA: For Builders (soften, keep)

This section recruits builders (the secondary builder-lane product). Keep it, but drop "licensed" from the requirement and reframe around the partnership.

### REPLACE: body (content.md line 101 + index.html line 156)
OLD:
We're building a network of trusted builders and connecting them with homeowners who are ready to start their deck projects. If you're licensed, insured, and looking for quality leads — we should talk.
NEW:
We team up with a few skilled local builders to keep up with demand across Central Wisconsin. If you run an insured crew and want steady deck work without chasing leads: let's talk.

(Headline "Are You a Deck Contractor in Central Wisconsin?" and the mailto CTA stay.)

---

## Meta

Meta title/description updated in `meta-descriptions.md` (current description says "vetted, licensed deck contractors in our network").
