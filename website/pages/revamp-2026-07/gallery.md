---
type: page-revamp
page: Gallery
url: /gallery
source: website/pages/gallery/content.md
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
---

# Gallery Revamp: `/gallery`

Light touch. No "licensed" claim and no testimonials here. Two changes: reposition "our builders" language to first person, and flag the stock-photo launch note as a compliance risk under the new construction positioning.

Live source: `website/pages/gallery/content.md`.

---

## Hero subtext

### REPLACE
OLD:
See what our builders have done for homeowners like you. From simple platform decks to custom multi-level outdoor spaces — browse real projects for inspiration.
NEW:
See what we've built for homeowners like you. From simple platform decks to custom multi-level outdoor spaces, these are real Central Wisconsin projects.

---

## Bottom CTA

### REPLACE: subtext + button
OLD:
Get a free quote from a vetted local contractor. No cost, no obligation — just a straightforward estimate for your project.
NEW:
Book a free walk-through with our local crew. No cost, no obligation: just a straightforward estimate for your project.

OLD (button):
Get Your Free Quote
NEW (button):
Book a Free Walk-Through

(Headline "Ready to Build Your Dream Deck?" stays.)

---

## FLAG: stock-photo launch note (not a copy fix, a compliance heads-up)

`gallery/content.md` lines 60-72 instruct: "At launch, use high-quality stock photos of deck projects... Tag them with realistic project types and cities" (e.g. "Composite Deck Build: Wausau, WI").

Under the old directory model this was borderline. Under the **new "we build these decks" positioning it is materially riskier**: a stock photo captioned "Composite Deck Build: Wausau, WI" on a page that says "see what we've built" implies CWDB built that specific deck. That is a deceptive-implication problem (same family as the fabricated testimonials).

Recommendation for web-dev + Jim:
- Use only real photos of real CWDB work in the gallery (the project-photos folder already holds real Wausau/Weston/Merrill/Mosinee/Rothschild shots).
- If a stock or generic photo is used to fill the grid, caption it neutrally ("Composite decking detail") with no city and no "built by us" implication, or add a small "inspiration" label.
- Do not caption any photo with a specific city + "build" unless CWDB actually built that deck.

This is a note, not a REPLACE block. The gallery images are outside copy scope, but the caption convention is a copy decision, so it is flagged here.
