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

# FACEBOOK / INSTAGRAM ADS — CWDB Launch Campaign

**Platform:** Meta (Facebook + Instagram)
**Objective:** Leads (Conversion Leads optimization, Pixel Lead event)
**Daily budget:** $20 (per launch brief)
**Landing page:** `https://www.cwdeckbuilders.com/get-a-quote`
**Native lead-form alternative:** see launch brief for field schema (Option A — no name/email collected)

---

## 9 Ads — 3 Angles × 3 Variants

Specs:
- Primary text: 125-char visible cap (Meta truncates after ~125 chars on most placements)
- Headline: 40-char cap
- Description: 30-char cap (shows on Audience Network only — keep tight)
- CTA button: "Get Quote" across all 9
- Image: 1 real Wisconsin deck photo per angle (post-Phase-4 Gallery CMS, see launch checklist gate)

---

### Angle 1: SOCIAL PROOF

**Variant 1A — Neighbor recommendation**
- Primary (123): Hundreds of Wausau-area homeowners got their dream deck this year. We connect you with vetted local builders. Free quote in 48 hrs.
- Headline (38): Your neighbors trust local deck pros
- Description (30): Free quote · Licensed builders

**Variant 1B — Builder roster**
- Primary (124): Real Central Wisconsin deck contractors. Real reviews. Real quotes. Tell us your project — we'll match you with the right builder.
- Headline (35): Vetted Wausau deck contractors
- Description (29): No spam · No obligation

**Variant 1C — 5-city footprint**
- Primary (122): Serving Wausau, Schofield, Weston, Mosinee & Merrill. Get a free deck quote from a licensed Central WI builder in 48 hours.
- Headline (37): Central Wisconsin deck specialists
- Description (28): Cedar · Composite · Trex

---

### Angle 2: PROBLEM/SOLUTION

**Variant 2A — Ghosted by contractors**
- Primary (124): Tired of calling deck contractors who never call back? We do the legwork. One form. One vetted local builder. Free quote in 48 hrs.
- Headline (33): No more ghosting. Real quotes.
- Description (29): Local builders who answer

**Variant 2B — Quote-shopping fatigue**
- Primary (122): Stop chasing 3 contractors for 3 quotes. Tell us about your deck once — we route it to a Central WI pro who actually shows up.
- Headline (32): One form. One vetted builder.
- Description (30): Save hours of phone tag

**Variant 2C — Quality risk**
- Primary (123): Hiring the wrong deck contractor costs more than the deck. Skip the gamble — get matched with a licensed local pro. Free quote.
- Headline (37): Skip the contractor gamble
- Description (28): Licensed · Insured · Local

---

### Angle 3: SEASONAL URGENCY

**Variant 3A — Wisconsin season is short**
- Primary (123): Wisconsin building season is short. The good deck builders book up by May. Get your free quote now and lock your spot for 2026.
- Headline (35): Lock your 2026 deck build now
- Description (30): Builders fill up by May

**Variant 3B — Backyard-ready by July**
- Primary (124): Want your new deck ready for July weekends? Now's the window — 48-hr free quote from a Central WI builder. No obligation to book.
- Headline (33): Backyard-ready by Summer 2026
- Description (29): Free quote in 48 hours

**Variant 3C — Calendar pressure**
- Primary (121): Spring quotes are filling up across Central WI. Get matched with a local deck builder this week — free, 2 minutes, no pressure.
- Headline (37): Spring deck calendars filling up
- Description (29): 2 minutes to get a quote

---

## Headline Library (40-char cap — for rotation if testing additional variants)

- Get Your Free Deck Quote (24)
- Local Deck Builders — Wausau Area (32)
- Build Your Dream Deck This Summer (33)
- Compare Local Deck Contractors (30)
- Free Quote · Licensed Local Builders (36)
- Cedar, Composite, Trex Decks (28)
- 48-Hour Free Quote · Central WI (31)

---

## Call to Action

- **Primary across all 9 ads:** Get Quote
- **Awareness/retargeting (Phase 2):** Learn More

---

## Link Description (under-headline preview text — 30-char visible)

- Free quote in 48 hours
- No spam · No obligation
- Vetted local Wisconsin pros

---

## Creative Assets — Image Spec

- 1080×1080 square (primary) + 1080×1350 vertical (Stories/Reels)
- Real Wisconsin deck photo, no overlay text on initial test (Meta penalizes >20% text)
- One image per angle = 3 images total (3 ads per angle reuse the same image with copy variations)
- **Asset gate:** the 4 stock Gallery photos flagged 2026-04-20 must be replaced with real deck photos before these ads ship. Use `/website/pages/gallery/project-photos/` or Jim's phone library.

---

## UTM Tracking — Append to Landing Page URL

Pattern: `?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content={angle}-{variant}`

Examples:
- Variant 1A: `?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=social-proof-1a`
- Variant 2C: `?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=problem-2c`
- Variant 3A: `?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=urgency-3a`

---

## Day-1 Test Read (Week 1)

- Aim: 9 ads x ~$2.20/day shared spend = test all 9 in week 1
- After 7 days, kill bottom 6 ads (lowest CPL retained)
- Scale top 3 to $20/day combined; expand winning angle for week 3 with 3 fresh variants

---

## Pre-Launch Checklist (Meta)

- [ ] All 9 ads built (3 angles × 3 variants)
- [ ] Real deck photos replace 3 stock images
- [ ] Pixel Lead event firing confirmed in Events Manager (1 test lead from `/thank-you`)
- [ ] Custom audience exclusion: existing form submitters (uploaded after first 50 leads)
- [ ] Geo + age + interests configured (see `/marketing/facebook-ads/audiences.md`)
- [ ] Daily budget cap: $20 ad-set level
- [ ] Optimization: Conversion Leads → Lead event
- [ ] Schedule: launch 12:00 PM Central, 2026-04-24 (target — flex ±1 day)
