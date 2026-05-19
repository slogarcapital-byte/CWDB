---
type: playbook
channel: meta
status: ready-to-execute-on-approval
created: 2026-04-21
owner: CEO Operator (executes with Jim at the keyboard for login-gated steps)
companion: /marketing/launch-brief-2026-04-20.md
tags:
  - type/playbook
  - dept/marketing
  - phase-1
  - ad-launch
---

# Meta Ads (Facebook + Instagram) — Account Setup Playbook

**Purpose:** Step-by-step script to build the CWDB launch campaign in Meta Ads Manager. Target execution time: **30 minutes** once Section 1 of `/marketing/pre-launch-checklist.md` is fully green and Jim has written "Launch approved" in the state file Inbox.

**DO NOT execute any step in this playbook until:**
1. Pre-launch checklist Section 1 is 11/11 green (including **gate 1.2 — real Wisconsin deck photos** — Meta creative cannot ship with stock photos).
2. Jim has explicitly approved launch with a date in the Inbox.

---

## Prerequisites (verify before you start)

- [ ] Jim logged into `https://business.facebook.com` with the Business Manager tied to cwdeckbuilders.com
- [ ] Meta Pixel (ID from Phase F memory) already installed and firing via GTM (verified 2026-04-18)
- [ ] Facebook Business Page exists for Central Wisconsin Deck Builders
- [ ] Instagram Business account connected (or connect during Step 0)
- [ ] Ad copy reference open: `/marketing/facebook-ads/ad-copy.md`
- [ ] 3 real deck photos saved locally, 1200x1200 square + 1080x1920 story-safe crops for each (9 total images)
- [ ] TCPA consent language copy-pasted ready for lead-form config

---

## Step 0 — Business Manager + Page Setup (skip if done)

1. `business.facebook.com` → Business settings → Accounts → **Pages** → confirm CWDB Facebook page is connected.
2. Accounts → **Instagram accounts** → connect the CWDB IG business account (if not connected).
3. Data sources → **Pixels** → confirm the CWDB pixel (from Phase F) shows **Active** and has received the `Lead` event in the last 7 days (test firings from GTM Preview should have landed).
4. Payments → confirm billing card matches Jim's designated ad-spend card.

---

## Step 1 — Create Campaign

1. Ads Manager → **+ Create**.
2. Objective → **Leads**.
3. Campaign name → `CWDB — Central WI Decks — Launch 2026-04`.
4. Special ad category → **None** (this is not housing/employment/credit).
5. A/B test → **Off** at launch (we'll A/B creative in week 2 once we have a baseline).
6. Advantage campaign budget (CBO) → **Off** — we want ad-set-level control at $20/day.
7. Click **Next**.

---

## Step 2 — Ad Set Configuration

### Ad set name
`CWDB — Cold — Central WI Homeowners 35-65`

### Conversion location
**Website** (NOT Instant Forms for launch — we want the site to handle submission so Google Ads + GA4 + HubSpot manual pull all see the same conversion. Revisit Instant Forms in week 3 as a CPL test.)

**Alternative if Jim prefers lower-CPL / higher-volume-lower-quality:** switch to **Instant Forms** and use the Lead Form fields from launch brief §Meta → Lead form. This playbook assumes Website.

### Performance goal
**Maximize number of conversions**

### Conversion event
`Lead` (confirm it's the one firing from GTM via the Phase F tag).

### Dataset
CWDB Pixel (from Phase F).

### Budget
**$20/day** — ad set level. Do NOT set campaign budget (CBO off — see Step 1).

### Schedule
- Start: **12:00 PM Central, 2026-04-24** (or Jim's approved date).
- End: leave open-ended at launch. We control via kill criteria.

### Audience (cold)

**Locations:**
- Wausau, WI +20 mi
- Schofield, WI +10 mi
- Weston, WI +10 mi
- Mosinee, WI +10 mi
- Merrill, WI +15 mi
- Location type → **People living in this location** (not recently in).

**Age:** 35 – 65+
**Gender:** All
**Languages:** English (US)

**Detailed targeting (narrow — use "Narrow audience" AND logic between groups):**

Group A (demographic): one of
- Homeowners

AND Group B (interests): one of
- Home improvement
- Home & Garden
- DIY (Do It Yourself)
- Backyard
- Patio
- Landscaping
- Decks

AND Group C (behaviors): one of
- Engaged Shoppers

**Exclude:** Renters (if the option is available in detailed demographics).

**Advantage detailed targeting:** **Off** at launch (we want tight control — turn on in week 2 if CPL is too high).

**Audience size target:** 40k–120k reach. If the estimator shows <30k, widen interests before widening geo. If >200k, tighten to Homeowners + Deck/Patio-specific.

### Placements
**Advantage+ placements: ON** (let Meta optimize across FB feed, IG feed, Stories, Reels). If Jim prefers manual:
- Facebook Feed
- Facebook Marketplace
- Instagram Feed
- Instagram Stories
- Instagram Reels
- Exclude: Audience Network (low quality), Right Column (FB desktop — cheap but poor CTR).

### Optimization & delivery
- Attribution setting: **7-day click / 1-day view** (default).
- Cost per result goal: leave blank at launch. Revisit week 2 after baseline.

Click **Next**.

---

## Step 3 — Ads (build 9 total: 3 angles × 3 creatives)

**Creative file source:** `/marketing/facebook-ads/ad-copy.md`

For each of 9 ads, click **+ Create ad** and fill:

### Ad template (repeat 9 times)

| Field | Value |
|---|---|
| Ad name | Format: `CWDB-LA-[angle]-[img#]` e.g. `CWDB-LA-SocialProof-1` |
| Identity | Facebook Page: Central Wisconsin Deck Builders · IG: connected IG business |
| Ad format | **Single image** |
| Media | 1 real Wisconsin deck photo (1200x1200 square — Meta auto-crops for Stories) |
| Primary text | [angle-specific copy from ad-copy.md] |
| Headline | [rotating, see below] |
| Description | "Free quote in 48 hours. Licensed local builders." |
| CTA button | **Get Quote** |
| Website URL | `https://www.cwdeckbuilders.com/get-a-quote?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=[angle]-img[#]` |
| Tracking | Pixel already attached at dataset level |

### 9-ad matrix

| # | Angle | Primary text source (ad-copy.md) | Image | Headline |
|---|---|---|---|---|
| 1 | Social Proof | "Hundreds of Central Wisconsin homeowners..." | Deck photo 1 (cedar/PT) | Local Deck Builders You Can Trust |
| 2 | Social Proof | same | Deck photo 2 (composite) | Wausau's Most-Booked Deck Pros |
| 3 | Social Proof | same | Deck photo 3 (multi-level) | Decks Built by Your Neighbors |
| 4 | Problem / Solution | "Tired of calling deck contractors who never call back..." | Deck photo 1 | Get a Real Quote in 48 Hours |
| 5 | Problem / Solution | same | Deck photo 2 | Done With Flaky Contractors? |
| 6 | Problem / Solution | same | Deck photo 3 | Stop Calling — Get Called Back |
| 7 | Seasonal Urgency | "Summer books up fast in Wisconsin..." | Deck photo 1 | Book Your Summer Deck Now |
| 8 | Seasonal Urgency | same | Deck photo 2 | WI Summer Is Short — Don't Wait |
| 9 | Seasonal Urgency | same | Deck photo 3 | Beat the Summer Rush |

**UTM per ad:** `utm_content=socialproof-img1` through `utm_content=seasonal-img3`.

---

## Step 4 — Compliance / Trust

### Facebook lead ad compliance (even though we're using Website, not Instant Form)
- Primary text must NOT make guarantees ("we'll save you money", "cheapest prices" → reject).
- Must NOT use "you" targeting attributes ("are you a homeowner?" is risky).
- Avoid before/after implying transformation (Meta flags personal attributes).

Review each of the 9 primary-text blocks against the above before publishing. The drafts in `/marketing/facebook-ads/ad-copy.md` have been written to comply, but re-check after any last-minute edits.

### Ad account verification
- Confirm **Identity verification** is complete on the ad account (Business Settings → Security Center). Unverified accounts get ads rejected for "Low Quality or Disruptive Content" frequently.

---

## Step 5 — Pre-Launch Checks (before hitting Publish)

- [ ] Campaign objective = **Leads**, conversion location = **Website**.
- [ ] Ad set budget = **$20/day**.
- [ ] Audience estimator shows 40k–120k reach.
- [ ] 9 ads created, each with a real deck photo (NOT stock).
- [ ] All 9 URLs include UTM params and resolve to `/get-a-quote`.
- [ ] Pixel `Lead` event is the selected conversion event.
- [ ] Placements set (either Advantage+ or manual per Step 2).
- [ ] Start date/time = 12:00 PM Central, 2026-04-24 (or approved date).
- [ ] **No open disapprovals** in the Ad account review panel.

---

## Step 6 — Launch

1. **Publish** all 3 ad levels (Campaign → Ad Set → 9 Ads) in a single action.
2. Immediately go to **Ads Manager → Account Overview** and confirm status = **Active** (not "In Review" for more than 60 min — if stuck, submit a re-review or message support).

---

## Step 7 — Day-1 Monitoring (first 4 hours live)

- Check Impressions > 0.
- Check for any ad showing **"Rejected"** → read the reason in the disapproval panel and revise (usually language tweaks).
- Check **Events Manager → Pixel → Lead event** — if the first Meta-sourced lead lands within the window, confirm it fires.
- Check **CPM** — if >$30, audience is too narrow. If <$8, audience is too broad. Target $10–$25.
- Check **CTR (link)** — target >1.5%. <1% at day 1 means weak hook; pause + rework creative.

---

## Week 1 Review Triggers

Per launch brief kill criteria:
- CPL > $50 after 7 days → pause entire ad set, review.
- 0 leads after $140 spent → pause, diagnose.
- Any ad with >$40 spend and 0 conversions at day 7 → pause that specific ad.
- Frequency > 3.5 on cold audience at day 7 → audience is saturating fast; expand.

Log week 1 review in `/finance/reports/performance/2026-05-01-week1.md`.

---

## CSV Export Ritual (manual lead pull until Make reactivates)

If switching to Instant Forms in week 3, you'll need:
- Daily: **Leads Center → Download CSV** → manually create HubSpot contact + deal.
- Until then (Website conversion route), all leads come through the site form → Webflow notification → Jim's inbox → manual HubSpot create + SMS to contractor. This matches the 2026-04-19 pivot memo.

---

## Rollback Plan

If creative gets mass-disapproved or CPL spikes >$100 in the first 24 hours:
1. Pause the ad set (not the campaign — preserves data).
2. Flag in state-of-cwdb.md Outbox for Jim.
3. Diagnose — 80% of day-1 disasters are audience too narrow or creative too generic.

Never delete — always pause.
