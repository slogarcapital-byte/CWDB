---
type: hook-audit
status: pass
created: 2026-04-21
owner: ad-campaign
wave: 3 of 4
consumes:
  - /marketing/launch-2026-04/02-hook-matrix.md
  - /marketing/launch-2026-04/creatives/meta/*
  - /marketing/launch-2026-04/creatives/google-display/*
produces_for:
  - ceo-operator (Wave 4)
tags:
  - type/hook-audit
  - dept/marketing
  - launch/2026-04
---

# Hook Audit — CWDB Launch 2026-04 Creatives

Mandatory gate before Wave 3 handoff. One row per rendered creative. Any row with "Ship: NO" triggers a rebuild before the batch is declared complete.

Avatar fit rubric (1–5):
- 5 = reads exactly like the Stressed Delegator's internal monologue
- 4 = reads close; a homeowner would nod
- 3 = generic but not wrong
- 2 = reads as marketer
- 1 = off-avatar

## Audit Table

| File | Angle | Hook text (on-image) | ≤5th-grade? | Avatar fit | WI specificity | Brand voice pass | Ship? |
|---|---|---|---|---|---|---|---|
| `meta/problem-solution-1080x1080.png` | Problem/Solution | TIRED OF CONTRACTORS WHO NEVER CALL BACK? | YES | 5 | YES ("Central WI" in sub; real WI deck photo) | PASS | YES |
| `meta/problem-solution-1080x1350.png` | Problem/Solution | TIRED OF CONTRACTORS WHO NEVER CALL BACK? | YES | 5 | YES | PASS | YES |
| `meta/process-proof-1080x1080.png` | Process Proof | 48 HOURS. NOT 48 DAYS. | YES | 4 | YES ("Central Wisconsin" in sub; real WI deck photo) | PASS | YES |
| `meta/process-proof-1080x1350.png` | Process Proof | 48 HOURS. NOT 48 DAYS. | YES | 4 | YES | PASS | YES |
| `meta/seasonal-urgency-1080x1080.png` | Seasonal Urgency | BOOK BEFORE MAY FILLS UP. | YES | 5 | YES ("Wisconsin Summer 2026" eyebrow, "Central WI" in sub, real WI deck photo) | PASS | YES |
| `meta/seasonal-urgency-1080x1350.png` | Seasonal Urgency | BOOK BEFORE MAY FILLS UP. | YES | 5 | YES | PASS | YES |
| `google-display/landscape-1200x628.png` | Process Proof (banner default) | 48 HOURS. NOT 48 DAYS. | YES | 4 | YES | PASS | YES |
| `google-display/square-1200x1200.png` | Process Proof (banner default) | 48 HOURS. NOT 48 DAYS. | YES | 4 | YES | PASS | YES |
| `google-display/portrait-960x1200.png` | Process Proof (banner default) | 48 HOURS. NOT 48 DAYS. | YES | 4 | YES | PASS | YES |
| `google-display/logo-square-1200x1200.png` | Logo (no headline) | — | n/a | n/a | Logo shows "Central Wisconsin Deck Builders" | PASS | YES |
| `google-display/logo-horizontal-1200x300.png` | Logo (no headline) | — | n/a | n/a | Same | PASS | YES |

## Reading grade check (all hooks)

- "TIRED OF CONTRACTORS WHO NEVER CALL BACK?" — Flesch-Kincaid ≈ 3.5. PASS.
- "48 HOURS. NOT 48 DAYS." — grade 1. PASS.
- "BOOK BEFORE MAY FILLS UP." — grade 2. PASS.
- "WISCONSIN SUMMER 2026" (eyebrow) — grade 1. PASS.
- All sub-copy uses ≤6 word clauses separated by periods. Hemingway-check passes across all 9 content creatives.

## Forbidden-word check (all creatives)

Scanned every creative for:
- bespoke — 0 occurrences
- investment — 0 occurrences
- transform — 0 occurrences
- oasis — 0 occurrences
- professional — 0 occurrences (substituted with "vetted local builder" / "local deck pro" throughout)
- 24-hour / 24 hours — 0 occurrences ("48 hours" is the locked promise)

## Brand-rule check

- Orange `#e54c00` lies once per creative (always on CTA): VERIFIED on all 9 content creatives.
- Staatliches + Public Sans only (both Google Fonts-loaded): VERIFIED.
- No side-stripe borders, no gradient text, no reflex fonts, no cyan/purple, no pure black or pure white text, no stock photography: VERIFIED.
- Real Wisconsin deck photo on every content creative: VERIFIED.
  - problem-solution — `composite-deck-wittenburg.jpg`
  - process-proof — `wausau-deck.webp`
  - seasonal-urgency — `hero-merrill.webp`
  - Google banners — `wausau-deck.webp` (landscape, square) + `hero-merrill.webp` (portrait)
- Logo present on every content creative, not larger than 12% of longest dimension: VERIFIED.

## 7-point anti-AI-slop test (applied to each content creative)

For every Meta + Google Display content creative:

- [x] Would a Wausau homeowner thumb-stop on this in their feed? (Headline + photo combo is designed for 0.8s thumb-stop window.)
- [x] Does it look like CWDB, not generic home-services lead-gen? (Staatliches headline + real WI deck photo + orange CTA = recognizable as ours.)
- [x] Would someone who saw the site yesterday recognize this as ours without reading the logo? (Type lockup + single-hit-of-orange + deck-photo-hero pattern mirrors homepage.)
- [x] Is the CTA unmistakable in under 1 second? (Orange pill, white uppercase, bottom-left/center.)
- [x] Zero side-stripes, zero gradient text, zero reflex fonts, zero AI cyan/purple? (Verified above.)
- [x] Real Wisconsin deck photo? (Verified.)
- [x] Copy sounds like a neighbor, not a marketer? ("never call back," "no phone tag," "book up by May," "not 48 days" — all avatar-voice.)

## Summary

- **Total creatives rendered:** 11 (6 Meta + 3 Google Display banners + 2 Google Display logos)
- **Total passing:** 11
- **Re-dos required:** 1 (problem-solution-1080x1080.png was initially rendered with `hero-wausau.webp` which is a pergola, not a deck. Swapped to `composite-deck-wittenburg.jpg` — verified real Central WI deck, re-rendered, now passes.)
- **All creatives PASS.** Wave 3 is ready for Wave 4 handoff.
