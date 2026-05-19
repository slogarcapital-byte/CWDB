---
type: session-log
date: 2026-04-21
session: 013
outcome: launch-package-shipped
tags:
  - type/session-log
  - launch/2026-04
  - wave-orchestration
---

# Session 2026-04-21-013 — Launch Package 4-Agent Orchestration

**Directive from Jim:** "we're finally ready to launch! time to create our campaigns. we'll be redoing existing ad campaign files to create highly targeted, highest converting ads possible for Google and Meta. work with revenue-optimization to develop the overall structure, ad spend, overall variants, testing plan, etc. then work with content-writer to craft hooks, offers, etc. finally work with ad-campaign to create high-quality creative. package it all up for simple deployment by me."

## What Shipped

`/marketing/launch-2026-04/` — complete v2 deployment package superseding v1 baselines in `/marketing/google-ads/` + `/marketing/facebook-ads/` (v1 preserved in git as rollback).

### Files

- `README.md` — package index + file tree
- `DEPLOY.md` — Jim's master checklist (60–90 min to Go-Live)
- `01-strategy.md` — 8-question architecture (revenue-optimization)
- `02-hook-matrix.md` — 10+ angles scored → 3 winners locked (content-writer)
- `03-google-copy.md` — paste-ready Google RSA × 2 ad groups + extensions (content-writer)
- `04-meta-copy.md` — paste-ready Meta 4 ads × full field set (content-writer)
- `05-hook-audit.md` — 11/11 PASS (ad-campaign)
- `creatives/meta/` — 6 PNGs (3 angles × 2 aspect ratios)
- `creatives/google-display/` — 3 banner PNGs + 2 logo PNGs (STANDBY for Week 4+)

## Key Strategic Decisions (logged here for future-self)

1. **Meta objective: Website Conversion, NOT Instant Form.** Rationale: Instant Form leads bypass the entire GTM/GA4/Clarity/Google Ads Conv stack → no cross-attribution, no lookalikes, no LP drop-off visibility. 40–60% higher CPL is the cost of keeping measurement coherent. Reopen Instant Form ONLY if Meta CPL >$60 in Week 1 (pre-approved escape hatch).
2. **Meta ads cut from v1's 9 → v2's 4.** Reason: $20/day across 9 ads = $1.10/ad/day = no ad ever hits learning floor. At 4 ads × $5/day, each gets enough data to evaluate in 3–4 weeks.
3. **Social Proof angle deferred.** We have 0 reviews/testimonials/case studies at launch — "hundreds of Wausau homeowners trust us" would be structurally dishonest. Process Proof (licensed/insured/local/48hr) replaces it. Social Proof re-enters rotation once 5+ customer reviews banked.
4. **3 locked angles:** Problem/Solution + Process Proof + Seasonal Urgency. Specificity treated as flavor within the other two, not standalone.
5. **Scientific control on Meta:** AS1 Ad 1 and AS2 Ad 1 share IDENTICAL copy + IDENTICAL image. Only variable changing is the audience (Manual Core vs Advantage+). Lets us attribute differences to audience, not copy.
6. **Google bid strategy:** Manual CPC weeks 1–3, NOT Maximize Conversions. Rationale: smart bidding needs ~15–30 conversion events to converge; we have zero. Promote at Week 4 if 15+ conversions banked.
7. **Call extension:** Enabled Mon–Fri 9am–5pm Central only (matches Jim's answer-window commitment). Unanswered calls = conversion leak; schedule eliminates exposure outside business hours.
8. **Google Display banners: built, but STANDBY.** Strategy §1 disables Display at launch (budget leak for Search campaigns). Assets ready for Week 4+ expansion.

## What the Agents Each Surfaced

- **revenue-optimization** pushed back correctly on v1's 9-ad Meta structure. Math was unambiguous. Also did honest unit-economics sensitivity: breakeven CPL at $200, 3:1 safety floor at $66, pause line at $100.
- **content-writer** flagged one subtle thing: Specificity as a standalone archetype "felt weaker than as a flavor inside Process Proof and Seasonal Urgency." Called the merge openly. Good judgment.
- **ad-campaign** caught a real issue during rendering: `hero-wausau.webp` is a pergola, not a deck. Swapped to `composite-deck-wittenburg.jpg`, re-rendered, passed audit. Also flagged `hero-wausau.webp` as an anti-pattern (filename implies deck, content is pergola) — future copy/brief authors should not trust filename.

## Jim's Decisions This Session

Three AskUserQuestion decisions before launching Wave 2:
1. Social Proof → **Defer** (recommended)
2. Call extension → **Enabled, business hours only** (9am–5pm Mon–Fri)
3. Form delivery → **Already verified, go**

## Orchestration Pattern That Worked

Sequential 4-wave waterfall with CEO (me) reviewing each output before dispatching the next. NOT parallel — each wave's output became the next wave's input. Attempts to parallelize would have produced misaligned copy + creatives.

TaskCreate + TaskUpdate per wave kept status visible to Jim without requiring per-wave approvals.

Each agent got:
- Full constraints manifest (non-negotiable, same for all)
- Specific reference reading (in order)
- Precise deliverable spec (file paths + required sections)
- Hard rules (voice, forbidden words, char limits, brand colors)
- Report-back format with length cap

No agent had to relitigate locked decisions. This is the pattern for future multi-agent orchestration.

## What's Not in the Package (intentionally deferred)

- TikTok ads, Nextdoor paid ads (organic only at launch)
- Instant Form / Meta Lead Form (preserved attribution by choosing Website Conversion)
- Lookalike audiences (deferred until 50+ conversions banked, ~Day 50)
- Retargeting/Remarketing (setup Week 4)
- Performance Max campaigns

## Next Steps for Jim

1. Open `/marketing/launch-2026-04/DEPLOY.md`
2. Work §0 Pre-Flight → §5 Go-Live (60–90 min)
3. Run the Verification Lap (§4) — 1 test lead, 5 signals checked across GA4 DebugView + Meta Test Events + Google Ads conversion diagnostic + Clarity + email
4. Un-pause only after verification passes
5. Report back Day 3 checkpoint, Day 7 decision gate

## Governance Note for Future Sessions

Post-launch monitoring rhythm (per strategy §5):
- Day 1–3: spend/delivery sanity checks only, no performance decisions
- Day 7: first individual-ad kill decisions (>$140 0-conv Meta, >$200 0-conv Google)
- Day 14: full kill criteria from launch brief
- Week 3: first variant refresh
- Week 4: scale decision + retargeting activation + bid-strategy promotion

If Jim asks for a review at any of these checkpoints, the reference is `01-strategy.md §5` + `launch-brief-2026-04-20.md §Kill Criteria`.
