---
type: reference
status: launch-ready
created: 2026-03-11
updated: 2026-04-21
launch_target: 2026-04-24
tags:
  - type/reference
  - dept/marketing
  - platform/meta-ads
---

# FACEBOOK ADS — AUDIENCE TARGETING (LAUNCH)

**Market:** Central Wisconsin Deck Builders LLC
**Daily budget:** $20 / ad set
**Target reach pool:** 40k–120k

---

## PRIMARY AUDIENCE: HOMEOWNER INTENT — COLD

### Location

Use one ad set with combined geo (recommended for $20/day). Create city-by-city ad sets only if breaking the budget down for granular city-level CPL data after week 2.

| City | Zip | Radius |
|---|---|---|
| Wausau | 54401, 54403 | + 20 mi (centered) |
| Schofield | 54476 | included by Wausau radius |
| Weston | 54474 | included by Wausau radius |
| Mosinee | 54455 | included by Wausau radius |
| Merrill | 54452 | included by Wausau radius |

**Setting:** "People living in this location" (NOT "People who were recently in this location" — too broad for homeowner targeting).

**Exclude:**
- Outside 20-mi radius of Wausau city center
- Cities >25 miles from Wausau (eliminates accidental Eau Claire / Stevens Point / Green Bay overspill)

### Demographics

- Age: 35-65 (homeowners with budget; 30-34 underperforms historically for high-ticket home services)
- Gender: All
- Languages: English

### Detailed Targeting (NARROW — must match ALL)

**Layer 1 (interests OR behaviors):**
- Home improvement
- Home & garden
- DIY (Do It Yourself)
- Patio
- Backyard
- Outdoor living
- Landscaping
- Lowe's (interest)
- The Home Depot (interest)
- HGTV (interest)

**Layer 2 (NARROW with — must also match):**
- Behaviors → Engaged Shoppers
- Behaviors → Likely Movers (recently moved homeowners — high deck-replacement intent)

### Exclusions (Detailed Targeting)

- Renters (Demographics → Home Type → Renters) — best-effort, Meta data is noisy
- People under 25
- After Week 1: exclude existing form submitters (custom audience from Pixel/CRM)

---

## AUDIENCE SIZE — Target Reach Pool

40,000-120,000. Adjust:
- **Too narrow (<40k):** drop one Layer 2 behavior, or widen interests by adding "Home renovation" / "Real estate"
- **Too broad (>120k):** narrow Layer 2 by adding behaviors AND interests (use compound NARROW)

---

## LOOKALIKE AUDIENCE (Phase 2 — defer until 50+ conversions)

- Source: Form submitters from Webflow (uploaded as Custom Audience via Pixel events or CSV upload from HubSpot)
- Lookalike: 1-2% similarity (1% for highest match quality)
- Location: Central Wisconsin (5 cities + 20-mi radius)
- Trigger: Build after 50 form submissions banked

---

## RETARGETING AUDIENCE (Phase 2 — defer until Week 3)

- Source: Pixel-tracked website visitors who did NOT submit form
- Engagement: people who clicked ad but did not convert
- Window: 30 days
- Frequency cap: 3/week to avoid fatigue
- Daily budget: $5 carved from cold $20 (revisit Week 4)

---

## AD-SET LEVEL PLACEMENTS

- Automatic placements at launch (FB feed, IG feed, Stories, Reels, Marketplace)
- After Week 2: review placement breakdown; if any single placement >40% spend with bad CPL, exclude

---

## OPTIMIZATION & DELIVERY

- **Conversion event:** Lead (Meta Pixel)
- **Optimization goal:** Conversion Leads
- **Attribution window:** 7-day click + 1-day view (default)
- **Budget pacing:** standard (not accelerated)

---

## CHANGE LOG

- 2026-04-21 — Reset to LAUNCH spec; aligned with brief geo (5 cities + 20-mi radius), tightened age (35-65), added Engaged Shoppers + Likely Movers behaviors, added renter exclusion
- 2026-04-16 — Initial draft
