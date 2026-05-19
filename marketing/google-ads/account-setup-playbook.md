---
type: playbook
channel: google-ads
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

# Google Ads — Account Setup Playbook

**Purpose:** Step-by-step script to build the CWDB launch campaign from scratch in Google Ads. Target execution time: **30 minutes** once Section 1 of `/marketing/pre-launch-checklist.md` is fully green and Jim has written "Launch approved" in the state file Inbox.

**DO NOT execute any step in this playbook until:**
1. Pre-launch checklist Section 1 is 11/11 green.
2. Jim has explicitly approved launch with a date in the Inbox.

**Budget check before starting:** confirm Google Ads billing is on Jim's preferred card. If billing isn't set up, Step 0 handles it.

---

## Prerequisites (verify before you start)

- [ ] Jim logged into `https://ads.google.com` with the Google account tied to cwdeckbuilders.com
- [ ] Google Ads Conversion ID from GTM on hand (in Phase F IDs memory — `AW-XXXXXXXXX` and conversion label)
- [ ] `https://www.cwdeckbuilders.com/get-a-quote` live on production and form submission redirects to `/thank-you`
- [ ] Phone number (715) 544-7941 answer-test passed (gate 1.11 in pre-launch checklist)
- [ ] Ad copy reference open: `/marketing/google-ads/ad-copy.md`
- [ ] Keywords reference open: `/marketing/google-ads/keywords.csv`

---

## Step 0 — Billing (skip if already configured)

1. Tools & settings (wrench icon, top right) → **Billing** → **Summary**.
2. Confirm payment method on file. If none, add the card Jim designated for ad spend.
3. Set **account-level spend cap** to **$1,500/month** under Billing → Promotions & accounts (hard cap protects against runaway spend).

---

## Step 1 — Create the Campaign

1. Campaigns → **+ New campaign**.
2. Objective → **Leads**.
3. Conversion goal → ensure **Google Ads Conversion** (the one wired in Phase F) is the primary goal. Add it explicitly if not listed.
4. Campaign type → **Search**.
5. Results you want → **Website visits** (URL: `https://www.cwdeckbuilders.com/get-a-quote`).
6. Campaign name → `CWDB — Central WI Decks — Search`.
7. Click **Continue**.

---

## Step 2 — Bidding

1. Bid strategy → **Maximize conversions**.
2. **Do NOT set a target CPA at launch.** Collect 7 days of data first — then switch to Target CPA around $60 once we have a baseline.
3. Click **Next**.

---

## Step 3 — Campaign Settings

### Networks
- [ ] Uncheck **Search partners** (low quality, inflates impressions).
- [ ] Uncheck **Display Network** (we are Search-only at launch).

### Locations
- Select **Enter another location**.
- Add each with radius:
  - Wausau, WI — 20 mile radius
  - Schofield, WI — 10 mile radius
  - Weston, WI — 10 mile radius
  - Mosinee, WI — 10 mile radius
  - Merrill, WI — 15 mile radius
- Location options → **Presence: People in or regularly in your included locations** (tighter, avoids travelers).
- Exclude: none at launch. Tighten week 2 if traffic leaks from Minneapolis/Twin Cities searches.

### Languages
- English only.

### Audience segments
- Leave empty at launch. Layer **Observation** audiences (not Targeting) week 2 once we see who converts.

### Ad schedule
- Mon–Fri: 7:00 AM – 8:00 PM Central
- Sat: 8:00 AM – 6:00 PM Central
- Sun: 9:00 AM – 5:00 PM Central
- Rationale: answer-path gate 1.11 — don't pay for clicks when no one will pick up the phone.

### Budget
- Daily budget: **$30**.
- Google may spend up to 2x on high-traffic days but monthly will balance. Acceptable.

Click **Next**.

---

## Step 4 — Ad Group 1: "Deck Builder Intent" (tight match)

1. Ad group name → `Deck Builder Intent`.
2. Default bid → leave blank (Maximize conversions handles it).
3. Paste keywords **one per line** with match types:

```
"deck builder wausau"
"deck builders near me"
"deck contractor wausau"
"wausau deck builder"
"central wisconsin deck builder"
"deck installation wausau"
"composite deck wausau"
[deck builder wausau]
[wausau deck contractor]
```

Phrase match uses `"..."`. Exact match uses `[...]`. Broad match: none at launch.

### Ads — Responsive Search Ad 1

**Final URL:** `https://www.cwdeckbuilders.com/get-a-quote?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=rsa1&utm_term={keyword}`

**Display path:** `cwdeckbuilders.com/Get-Quote`

**Headlines (15 — paste from `/marketing/google-ads/ad-copy.md`):**
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
12. Deck Installation Wausau
13. Professional Deck Builders
14. Get 3 Deck Quotes Fast
15. Wisconsin Deck Pros

**Descriptions (4):**
1. Connect with top-rated local deck builders. Free quote in 48 hours. No hassle.
2. Licensed deck contractors in Wausau, Schofield, Weston, Mosinee & Merrill. Start today.
3. Compare quotes from Central Wisconsin's best deck builders. Fast, easy, and free.
4. Ready for a new deck? We match you with trusted local builders. Quote in 48 hours.

**Pin headlines (recommended):**
- Position 1: Headline #1 OR #14 (CTA-led)
- Position 2: Headline #2 OR #12 (geo anchor)

Unpin the rest — let Google rotate.

Click **Save and continue**.

---

## Step 5 — Ad Group 2: "Deck Quote / Estimate Intent" (broader)

1. **+ New ad group** after saving Ad Group 1.
2. Ad group name → `Deck Quote & Estimate`.
3. Keywords (phrase match):

```
"deck quote wausau"
"deck estimate wisconsin"
"build a deck wausau"
"new deck cost wisconsin"
"deck repair wausau"
"deck cost calculator wisconsin"
"deck price wausau"
```

### Ads — Responsive Search Ad 2

**Final URL:** `https://www.cwdeckbuilders.com/get-a-quote?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=rsa2&utm_term={keyword}`

**Display path:** `cwdeckbuilders.com/Free-Quote`

Same 15 headlines and 4 descriptions as Ad Group 1 (rotate pins differently — pin #8 "Free Estimates" in position 1, #5 "Central WI Deck Experts" in position 2).

Save.

---

## Step 6 — Negative Keywords (campaign level)

Campaign → Keywords → Negative keywords → **+** → paste (one per line, broad match):

```
diy
kit
rental
job
jobs
hiring
career
used
photos
ideas
plans
pdf
blueprint
design
drawings
software
license
home depot
lowes
menards
permit
cost of
how to build
how to
```

Click **Save**.

---

## Step 7 — Ad Extensions (Assets)

### Sitelinks (4)
Campaign → Assets → **+** → Sitelinks:

| Sitelink text | URL |
|---|---|
| See Our Work | `https://www.cwdeckbuilders.com/gallery?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=sl-gallery` |
| Deck Cost Calculator | `https://www.cwdeckbuilders.com/cost-calculator?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=sl-calc` |
| Meet the Builders | `https://www.cwdeckbuilders.com/our-builders?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=sl-builders` |
| FAQ | `https://www.cwdeckbuilders.com/faq?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=sl-faq` |

For each: add 2 description lines (25 chars each). Examples:
- Gallery: "Real Central WI decks" / "Cedar, composite, multi-level"
- Calculator: "Estimate your deck cost" / "Free — takes 60 seconds"
- Builders: "Local, licensed, insured" / "Meet our vetted pros"
- FAQ: "Permits, costs, timelines" / "Quick answers"

### Callouts (minimum 4, add 6+):
- Licensed & Insured
- Free Quotes in 48 Hours
- Local Central WI Builders
- Cedar · Composite · Multi-Level
- Wausau, Schofield, Weston, Mosinee, Merrill
- Fully Vetted Contractors

### Structured Snippets:
- Header: **Service catalog**
- Values: New Decks, Deck Repair, Composite Decks, Cedar Decks, Multi-Level Decks

### Call extension
- Number: **(715) 544-7941**
- Schedule: match the campaign ad schedule (Step 3).
- **Gate:** only enable if gate 1.11 (phone answer-test) has passed. Otherwise leave paused.

### Location extension
- Link the Google Business Profile if Jim has one. If not, skip at launch — add in week 2.

---

## Step 8 — Conversion Tracking Verification

1. Tools → **Conversions**.
2. Confirm the conversion action tied to `AW-XXXXXXXXX/[label]` from GTM shows **Status: Recording conversions** (or "No recent conversions" if nothing has fired yet — that's fine pre-launch).
3. Set the conversion **value** to **$200** per conversion (rough lead value — revise week 4 with real accepted-bid data).
4. Conversion window: **30 days**.
5. Count: **One** (not every — we want unique leads, not reloads of thank-you).

---

## Step 9 — Final Pre-Launch Checks (before hitting Publish)

- [ ] Daily budget shows **$30**.
- [ ] Both ad groups have 1 enabled RSA each.
- [ ] At least 4 sitelinks, 4 callouts, 4 snippets attached.
- [ ] Call extension enabled OR paused per gate 1.11.
- [ ] Location targeting = 5 cities + radii.
- [ ] Display Network + Search Partners both OFF.
- [ ] Ad schedule set.
- [ ] Negative keyword list applied at campaign level.
- [ ] Final URL includes UTM params.

---

## Step 10 — Launch

1. Campaign status → **Enabled**.
2. Launch time — schedule for **12:00 PM Central on 2026-04-24** (or Jim's approved date). Use Campaign → Settings → Start date.

**Do not launch mid-afternoon Friday unless explicitly planned.** Monday morning launches give 5 clean days of data before week 1 kill-criteria review.

---

## Step 11 — Day-1 Monitoring (first 4 hours live)

Within the first 4 hours of launch:
- Check Impressions > 0 (if 0, targeting is too narrow or bids not competitive — review Bid strategy diagnostics).
- Check for **Disapproved ads** (Google policy flags). Fix immediately.
- Check Quality Score on top keywords (aim 7+ — if 3 or below, rework headlines/landing page match).
- Confirm first click → site resolves → conversion fires via GA4 real-time + Google Ads real-time panel.

---

## Week 1 Review Triggers

Per launch brief kill criteria:
- CPL > $80 after 7 days → pause entire campaign, review.
- 0 leads after $200 spent → pause, diagnose.
- CTR < 1.5% with >500 impressions on any keyword → pause that keyword.

Log Week 1 review in `/finance/reports/performance/2026-05-01-week1.md` (create when time comes).

---

## Rollback Plan

If something goes visibly wrong (disapproved ads, wrong landing page, spend runaway):
1. Campaign → **Pause** (top left status toggle). Spend stops immediately.
2. Flag in state-of-cwdb.md Outbox for Jim.
3. Diagnose before re-enabling.

Never delete a campaign — always pause. Data is useful for the next attempt.
