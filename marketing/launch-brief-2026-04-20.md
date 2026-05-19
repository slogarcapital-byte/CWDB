---
type: brief
status: approved
created: 2026-04-19
updated: 2026-04-21
approved_by: jim
approved_date: 2026-04-21
target_launch: 2026-04-21
target_launch_window: "2026-04-21 (tonight)"
owner: ad-campaign
tags:
  - type/brief
  - dept/marketing
  - phase-1
---

# Ad Launch Brief — $50/day · Target: 2026-04-21 (TONIGHT)

**Purpose:** 15-minute review target. Jim approves, then ad-campaign executes setup in Google Ads + Meta Ads Manager. Kill criteria below are enforced no matter what.

**Launch prerequisites (live status):**
- [x] Phase 4 Designer handoff complete ✅ (2026-04-21 — full 21-page revamp shipped)
- [x] Gallery CMS: all 7 photos real Wisconsin deck photos ✅ (2026-04-21)
- [x] Builders CMS: Ben Barton + John Garcia headshots uploaded; builders-strip CMS-bound ✅ (2026-04-21)
- [x] Hero-form handoff bug fixed ✅ (2026-04-21 — script `hero_form_handoff` v1.0.0 deployed to prod)
- [x] Production site live on cwdeckbuilders.com + www.cwdeckbuilders.com ✅ (2026-04-21)
- [x] Jim sign-off on this brief ✅ (2026-04-21)
- [ ] Form → email delivery verified (Jim manual test — see `/marketing/launch-day-verification-2026-04-21.md` §3)
- [ ] GTM Preview tag firing re-verified post-revamp (see `/marketing/launch-day-verification-2026-04-21.md` §2)
- [ ] Phone (715) 544-7941 answered during business hours (determines Call extension on/off — §5)

## Budget Split

| Channel                 | Daily   | Monthly (30d) | Notes                                               |
| ----------------------- | ------- | ------------- | --------------------------------------------------- |
| Google Search Ads       | $30     | $900          | Intent-driven; highest-quality channel at launch    |
| Meta (FB + IG) Lead Ads | $20     | $600          | Cold-audience top-funnel; cheaper CPL, lower intent |
| Nextdoor paid           | $0      | $0            | Organic-only; Jim posts in neighborhood groups      |
| TikTok                  | $0      | $0            | Not at launch                                       |
| **Total**               | **$50** | **$1,500**    |                                                     |

---

## Geographic Targeting (both channels)

Radius targeting. Include + exclude by ZIP.

- Wausau, WI (54401, 54403)
- Schofield, WI (54476)
- Weston, WI (54476)
- Mosinee, WI (54455)
- Merrill, WI (54452)
- Optional stretch: Kronenwetter, Rothschild, Rib Mountain (54474)

Exclude: outside 20-mile radius of Wausau city center.

---

## Google Search Ads

### Campaign structure
- **Campaign:** CWDB — Central WI Decks — Search
- **Ad group 1 (tight match):** Deck Builder Intent
- **Ad group 2 (broader):** Deck Quote / Estimate Intent

### Keywords (Ad Group 1 — phrase/exact match)
- "deck builder wausau"
- "deck builders near me"
- "deck contractor wausau"
- "wausau deck builder"
- "central wisconsin deck builder"
- "deck installation wausau"
- "composite deck wausau"

### Keywords (Ad Group 2 — phrase match)
- "deck quote wausau"
- "deck estimate wisconsin"
- "build a deck wausau"
- "new deck cost wisconsin"
- "deck repair wausau"

### Negative keywords (seed list)
- diy, kit, rental, job, jobs, hiring, career, used, photos, ideas, plans, pdf, blueprint

### Headlines (30-char max — RSA min 3, max 15. Final list in `/marketing/google-ads/ad-copy.md` after polish pass.)
Match the on-site promise: 48-hour quote response, Central WI focus, licensed local builders. Avoid 24-hour claims — homepage hero was deliberately downgraded to 48hr for realism (2026-04-19 revamp).

1. Get a Free Deck Quote
2. Wausau Deck Builders
3. Local Deck Contractors
4. Quote in 48 Hours
5. Central WI Deck Experts
6. Trusted Wisconsin Builders
7. Custom Deck Installation
8. Free Estimates — Book Now
9. Licensed & Insured Builders
10. Build Your Dream Deck
11. Composite Decks — Wausau

### Descriptions (90-char)
1. Connect with top-rated local deck builders. Free quote in minutes. No hassle.
2. Licensed deck contractors in Wausau, Schofield, Weston & surrounding areas. Call today.
3. Compare quotes from Central Wisconsin's best deck builders. Fast, easy, and free.

### Landing page
`https://www.cwdeckbuilders.com/get-a-quote`

### Extensions
- Sitelinks (verify all resolve post-Phase-4 deploy):
  - `https://www.cwdeckbuilders.com/gallery`
  - `https://www.cwdeckbuilders.com/cost-calculator`
  - `https://www.cwdeckbuilders.com/our-builders`
  - `https://www.cwdeckbuilders.com/faq`
- Callout: "Licensed & Insured", "Free Quotes", "Local Builders", "48-Hour Response"
- Call extension: (715) 544-7941 — **enabled at launch** if Jim confirms the Google Voice line is answered promptly during business hours. Otherwise keep paused until manual answer-path is sorted.
- Structured snippets: Service type → New Decks, Deck Repair, Composite Decks, Multi-Level

### Conversion tracking
- Google Ads Conversion tag live via GTM (Phase F, 2026-04-18) — published to production
- Trigger: page view on `/thank-you` (form action redirects on submit)
- Tag also sends `form_submission` custom event for GA4 attribution
- Assign value: $200 per conversion (estimated lead value — adjust after week 1)
- **Pre-launch verification:** submit a real test lead on production after Phase 4 promote and confirm the conversion appears in Google Ads Manager within 24 hr (see `/marketing/pre-launch-checklist.md` Section 3).

---

## Meta (Facebook + Instagram) Lead Ads

### Campaign structure
- **Objective:** Leads
- **Optimization:** Conversion Leads (with Meta Pixel Lead event already firing — confirmed Phase F)
- **Placement:** Automatic (FB feed, IG feed, Stories, Reels)

### Audience (cold)
- Age: 35–65
- Gender: All
- Geo: same 5 cities + 20-mi radius
- Detailed targeting (narrow):
  - Homeowners (demographic)
  - Interests: Home improvement, Home & garden, DIY, Patio, Backyard, Landscaping
  - Behaviors: Engaged Shoppers
- Exclude: renters, under 25

### Audience size target
- Aim for 40k–120k reach pool. Widen interests before widening geo if it's too narrow.

### Ad variants — 3 angles × 3 creatives each (9 ads total)
Copy variants already drafted in `/marketing/facebook-ads/ad-copy.md`:

1. **Social Proof** — "Hundreds of Central Wisconsin homeowners got their dream decks..."
2. **Problem/Solution** — "Tired of calling deck contractors who never call back?..."
3. **Seasonal Urgency** — "Summer books up fast in Wisconsin..."

Headlines rotated (4 variants already in file). CTA: **Get Quote**.

### Creative
- Image: One real deck photo per angle (use Gallery CMS photos — Webflow Gallery Photos collection `69cff077a56c28009f3df538`). **Gate: SATISFIED 2026-04-21** — all 7 Gallery CMS photos are real Wisconsin deck photos.
- Video: None at launch (add after 2 weeks of data)

### Landing page (if using Website Conversions objective instead of Lead Form)
`https://www.cwdeckbuilders.com/get-a-quote`

### Lead form (recommended — Meta native Lead Form, not redirect)
- Why: Meta's own form converts ~2x better than redirect to site, cheaper CPL
- **Field alignment with site wizard (Option A schema, locked 2026-04-20):**
  - `zip` (5-digit), `phone`, `project_type`, `address`, `owns_property` (Y/N), `budget`, `timeline`, `notes` (optional)
  - **Do NOT collect:** name, email — site wizard does not collect these and the manual SMS-to-contractor template is built around the smaller schema
  - `tcpa_consent` checkbox — required
- CRM: Export daily to CSV, manually create in HubSpot until Make automation reactivation triggers fire (see pivot memo 2026-04-19)

---

## UTM Plan

Consistent across all ads.

```
utm_source={channel}
utm_medium=cpc
utm_campaign=launch-2026-04
utm_content={ad_variant_id}
utm_term={keyword}   // Google only
```

Examples:
- Google: `?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=hg1&utm_term=deck+builder+wausau`
- Meta: `?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=social-proof-img1`

GA4 already configured to capture all UTM params — verified during Phase F.

---

## Kill Criteria — Enforced Without Jim Sign-off

After 7 days of spend:
- **Pause Google** if CPL > $80 OR 0 leads after $200 spent
- **Pause Meta** if CPL > $50 OR 0 leads after $140 spent
- **Pause both** if combined CPL > $100 across week 1

After 14 days:
- **Pause any ad set** with >$250 cumulative spend and 0 leads
- **Pause any keyword** with CTR <1.5% and >500 impressions
- **Target CPL:** <$60 combined (unit economics requirement)

Revenue gate:
- If no contractor accepts a bid after 30 days / $1,500 spent, halt spend and re-evaluate contractor-side funnel (not ad-side). Lead quality is the first suspect; contractor follow-up speed is the second.

---

## Launch Checklist (pre-go-live)

- [x] Jim approves this brief ✅ (2026-04-21)
- [ ] Confirm phone (715) 544-7941 reachable (GV kept — no Twilio port; confirm answer path before enabling Call extension)
- [ ] Verify Get a Quote form email notification delivers to correct inbox (CRITICAL — no Make automation backup; see verification checklist §3)
- [ ] Confirm Meta Pixel Lead event firing in GTM Preview on test submission (§2)
- [ ] Confirm Google Ads Conversion tag firing in GTM Preview on test submission (§2)
- [ ] Upload 3 deck photos from Gallery collection for Meta creative (if using Website Conversions objective; skip if using Meta native Lead Form)
- [ ] Set both campaigns to launch **2026-04-21 (tonight)**
- [ ] Enable spend caps: $50/day account cap on Google, $20/day ad set cap on Meta
- [ ] **Campaigns deploy in PAUSED state first** — flip to active only after §2/§3/§5 of `/marketing/launch-day-verification-2026-04-21.md` all pass

---

## What's NOT in this brief

- No ad-testing plan (separate doc, build before scaling beyond $50/day)
- No Nextdoor organic content calendar (separate — ad-campaign to draft after launch)
- No retargeting (not enough site traffic yet to justify; revisit week 3)
- No lookalike audiences (need >50 conversions first)
