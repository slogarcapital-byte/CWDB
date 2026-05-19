---
variant_id: m-as1-v1-problem-16x9
platform: youtube | google-display-landscape | fb-in-stream
dimensions: 1920x1080 (16:9)
angle: Problem/Solution
campaign: launch-2026-04
created: 2026-04-26
---

# Problem/Solution · 1920x1080 (16:9)

## Angle
Problem/Solution — same angle as 1:1, 4:5, 9:16 masters. Side-anchored composition for landscape orientation.

## Copy as shipped
- Headline (on-image): "TIRED OF CONTRACTORS WHO NEVER CALL BACK?"
- Sub: "One form. One vetted local builder. Real quote in 48 hours."
- CTA: GET QUOTE
- Trust row: LICENSED · LOCAL · 48-HR QUOTE

## Photo asset
`/website/pages/gallery/project-photos/composite-deck-wittenburg.jpg`. Photo crop biased to right (`background-position: 65% 45%`) so deck stairs + garden + fence form a rich right-side composition while content lives left-50%.

## 16:9 layout decisions (NEW PATTERN — extract candidate)
- **Side-anchored composition**: photo fills full bleed, content block hugs LEFT 54% of frame (1040px content width within 1920px frame).
- **Vertical scrim** (90deg gradient) replaces the bottom horizontal scrim used on 1:1 / 4:5 / 9:16. `linear-gradient(90deg, rgba(50,52,52,0.92) 0% → 0.78 38% → 0.20 62% → 0 80%)`. This hides the type-side and lets the photo breathe on the right.
- Logo top-left (top:64px, left:80px), 64px height — 1.2× the 1:1 logo for landscape weight balance.
- Headline 124px Staatliches max-width 16ch — wraps to 3 lines ("TIRED OF / CONTRACTORS WHO / NEVER CALL BACK?"). Strong cadence for landscape.
- CTA + trust row inline as flex-row, both bottom-anchored at bottom:80px.

## Self-critique scores (out of 5)
- Hierarchy: 5
- Legibility: 5 — vertical scrim solves logo contrast cleanly
- Brand fit: 5
- Composition: 5 — photo's deck/garden detail breathes on right

## Pattern extraction (for /impeccable extract at batch end)
Side-anchored composition with vertical scrim is the new master template for 16:9 ratio. Atom name candidate: `.cwdb-scrim-left` and corresponding content positioning rules. Should be added to `/marketing/creatives/creative-system.md`.

## Anti-AI-slop check
- Real Wisconsin deck photo ✅
- Staatliches + Public Sans only ✅
- Orange lies once ✅
- No forbidden tokens ✅
- Sounds like a neighbor ✅
