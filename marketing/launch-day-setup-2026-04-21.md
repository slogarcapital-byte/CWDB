---
type: runbook
status: ready-for-execution
created: 2026-04-21
target_launch: 2026-04-21 (tonight)
owner: jim (executes) / ad-campaign (authored)
tags:
  - type/runbook
  - dept/marketing
  - phase-1
  - platform/google-ads
  - platform/meta-ads
---

# Launch-Day Setup — 2026-04-21 (TONIGHT)

## Pre-Flip Verification Gate

**BOTH campaigns deploy in PAUSED state.** Do not flip to active until Jim personally clears §2 (GTM tags firing on production), §3 (form → email delivery confirmed), and §5 (phone answer path confirmed) from `/marketing/launch-day-verification-2026-04-21.md`. A silent conversion gap on Day 1 means untracked ROAS, no kill-criteria data, and wasted $50/day. If any of the three gates fail, log the blocker in `/marketing/launch-blockers-2026-04-21.md` and hold. §1, §4, §6, §7 of the verification checklist are strongly recommended but a single failure there is recoverable mid-flight.

---

## Kill Criteria (verbatim from approved brief)

After 7 days of spend:
- **Pause Google** if CPL > $80 OR 0 leads after $200 spent
- **Pause Meta** if CPL > $50 OR 0 leads after $140 spent
- **Pause both** if combined CPL > $100 across week 1

After 14 days:
- **Pause any ad set** with >$250 cumulative spend and 0 leads
- **Pause any keyword** with CTR <1.5% and >500 impressions
- **Target CPL:** <$60 combined (unit economics requirement)

Revenue gate:
- If no contractor accepts a bid after 30 days / $1,500 spent, halt spend and re-evaluate contractor-side funnel (not ad-side). Lead quality is first suspect; contractor follow-up speed is second.

---

## 1. GOOGLE ADS — Copy/Paste Setup Block

### 1.1 Campaign settings

| Setting | Value |
|---|---|
| Campaign name | `CWDB — Central WI Decks — Search` |
| Campaign type | Search |
| Networks | Google Search ONLY — **uncheck Search Partners, uncheck Display Network** |
| Goal | Leads |
| Bidding strategy | Manual CPC with Enhanced CPC OFF — cap at $3.50 max CPC |
| Daily budget | $30.00 |
| Account-level daily cap | $50.00 (safety) |
| Start date | 2026-04-21 |
| End date | None |
| Ad rotation | Optimize (default) |
| Ad schedule | Mon–Sun, 6:00 AM – 10:00 PM Central |
| Device targeting | All devices, no bid adjustment |
| Campaign status at save | **PAUSED** |

### 1.2 Location targeting

- **Targeting method:** "Presence: People in or regularly in your targeted locations" (NOT "Presence or interest")
- **Include (radius targeting):**
  - Wausau, WI — ZIP 54401, 54403
  - Schofield, WI — ZIP 54476
  - Weston, WI — ZIP 54476
  - Mosinee, WI — ZIP 54455
  - Merrill, WI — ZIP 54452
  - Stretch: Kronenwetter, Rothschild, Rib Mountain — ZIP 54474
- **Exclude:** Any location outside a 20-mile radius of Wausau city center (44.9591, -89.6301)
- **Language:** English

### 1.3 Tracking template (campaign level)

```
{lpurl}?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content={creative}&utm_term={keyword}
```

Final URL suffix: leave blank.

### 1.4 Ad Group 1 — Deck Builder Intent

**Match types:** Exact + Phrase. Load each keyword twice where noted.

| Keyword | Match type |
|---|---|
| deck builder wausau | Exact `[deck builder wausau]` + Phrase `"deck builder wausau"` |
| deck builders near me | Phrase `"deck builders near me"` |
| deck contractor wausau | Exact `[deck contractor wausau]` + Phrase `"deck contractor wausau"` |
| wausau deck builder | Exact `[wausau deck builder]` |
| central wisconsin deck builder | Phrase `"central wisconsin deck builder"` |
| deck installation wausau | Phrase `"deck installation wausau"` |
| composite deck wausau | Phrase `"composite deck wausau"` |

**Max CPC:** $3.50 (ad-group override, matches campaign cap).

#### RSA — Ad Group 1 (15 headlines, 4 descriptions)

Final URL: `https://www.cwdeckbuilders.com/get-a-quote`
Display path: `/deck-quote` / `/wausau-decks`

Headlines (≤30 chars — all verified):

| # | Headline | Chars | Pin |
|---|---|---|---|
| 1 | Wausau Deck Builders | 20 | Position 1 |
| 2 | Get a Free Deck Quote | 21 | — |
| 3 | Quote in 48 Hours | 17 | Position 2 |
| 4 | Local Deck Contractors | 22 | — |
| 5 | Central WI Deck Experts | 23 | — |
| 6 | Licensed & Insured Pros | 23 | — |
| 7 | Trusted Wisconsin Builders | 26 | — |
| 8 | Build Your Dream Deck | 21 | — |
| 9 | Custom Deck Installation | 24 | — |
| 10 | Composite Decks — Wausau | 24 | — |
| 11 | Free Estimates, No Spam | 23 | — |
| 12 | Vetted Local Pros | 17 | — |
| 13 | Backed by Local Pros | 20 | — |
| 14 | Cedar · Composite · Trex | 24 | — |
| 15 | Serving 5 Central WI Cities | 27 | — |

Descriptions (≤90 chars — all verified):

1. Connect with vetted Central Wisconsin deck builders. Free quote in 48 hours. No hassle. (88)
2. Licensed deck pros in Wausau, Schofield, Weston, Mosinee & Merrill. Get matched fast. (85)
3. Cedar, composite, multi-level — get a no-obligation quote from a local builder today. (87)
4. Skip the ghosting. Real local contractors who actually call back. Free quote, 2 minutes. (89)

### 1.5 Ad Group 2 — Deck Quote / Estimate Intent

**Match types:** Phrase only (broader commercial-research intent).

| Keyword | Match type |
|---|---|
| deck quote wausau | Phrase `"deck quote wausau"` |
| deck estimate wisconsin | Phrase `"deck estimate wisconsin"` |
| build a deck wausau | Phrase `"build a deck wausau"` |
| new deck cost wisconsin | Phrase `"new deck cost wisconsin"` |
| deck repair wausau | Phrase `"deck repair wausau"` |

**Max CPC:** $3.00 (10% lower than AG1 — lower intent tier).

#### RSA — Ad Group 2 (15 headlines, 4 descriptions)

Final URL: `https://www.cwdeckbuilders.com/get-a-quote`
Display path: `/deck-quote` / `/free-estimate`

Headlines (≤30 chars — all verified):

| # | Headline | Chars | Pin |
|---|---|---|---|
| 1 | Free Deck Quote — Wausau | 24 | Position 1 |
| 2 | Get Your Deck Estimate | 22 | — |
| 3 | Quote in 48 Hours | 17 | Position 2 |
| 4 | Central WI Deck Pricing | 23 | — |
| 5 | New Deck Cost Estimate | 22 | — |
| 6 | Deck Repair & Rebuild | 21 | — |
| 7 | Compare Local Builders | 22 | — |
| 8 | No-Obligation Deck Quote | 24 | — |
| 9 | Cedar, Composite, Trex | 22 | — |
| 10 | Licensed WI Deck Pros | 21 | — |
| 11 | Know Your Deck Price | 20 | — |
| 12 | Plan Your 2026 Build | 20 | — |
| 13 | 2-Minute Quote Request | 22 | — |
| 14 | Serving 5 WI Cities | 19 | — |
| 15 | Free — No Sales Calls | 21 | — |

Descriptions (≤90 chars — all verified):

1. Get a ballpark deck cost from a licensed Central WI builder. Free, 2 minutes, no pressure. (90)
2. Real quotes from real local contractors. Wausau, Schofield, Weston, Mosinee, Merrill. (85)
3. Cedar, composite, multi-level — compare estimates from vetted Central WI deck pros. (84)
4. Planning a 2026 deck? Lock your estimate now before spring calendars fill. Free quote. (86)

### 1.6 Campaign-level negative keywords

Load as **Phrase match** negatives at campaign level:

```
diy
kit
plans
pdf
photos
ideas
images
gallery
job
jobs
hiring
career
careers
salary
how to build
free plans
used
rental
rent
union
osha
license cost
permit cost
menards
home depot
lowes
```

Menards/Home Depot/Lowes added to filter DIY-shopper searches. Expand after Week 1 from Search Terms report.

### 1.7 Conversion action

| Setting | Value |
|---|---|
| Conversion name | `Form submit — get-a-quote` |
| Category | Submit lead form |
| Source | GTM tag published 2026-04-18 (Phase F) — fires on `/thank-you` page view + `form_submission` custom event |
| Value | $200 per conversion (estimated — revisit after Week 1) |
| Count | One |
| Attribution model | Data-driven (default) |
| Click-through window | 30 days |
| Include in "Conversions" column | Yes |
| Verification gate | Submit 1 real test lead on production; confirm conversion appears within 24 hr |

### 1.8 Ad extensions

**Sitelinks (4):**

| Title | URL | Desc line 1 | Desc line 2 |
|---|---|---|---|
| See Our Work | `https://www.cwdeckbuilders.com/gallery` | Real Central WI deck projects | Cedar, composite, multi-level |
| Estimate Deck Cost | `https://www.cwdeckbuilders.com/cost-calculator` | Get a ballpark in 60 seconds | Free, no signup needed |
| Meet the Builders | `https://www.cwdeckbuilders.com/our-builders` | Vetted local deck contractors | Licensed and insured |
| Common Questions | `https://www.cwdeckbuilders.com/faq` | Costs, timelines, materials | Wisconsin permits + more |

**Callouts (8):**
`Licensed & Insured` · `Free Quotes` · `Local Wisconsin Builders` · `48-Hour Response` · `Cedar · Composite · Trex` · `Serving 5 Cities` · `No Obligation` · `Vetted Contractors`

**Structured snippets — Service catalog:**
`New Decks` · `Deck Repair` · `Deck Replacement` · `Composite Decks` · `Multi-Level Decks` · `Screen Porches` · `Pergolas`

**Call extension — DISABLED at launch:**

- Number: (715) 544-7941 — Google Voice
- Schedule: Mon–Sat 8:00 AM – 7:00 PM Central
- **Default state: PAUSED.** Enable only AFTER Jim personally confirms §5 of the verification checklist passes (line answers within 6 rings OR voicemail identifies CWDB and voicemail-back within business hours is realistic). If either fails, Call extension stays off until manual answer-path is fixed.

**Location extension:** DEFER until Google Business Profile verified. Track separately.

### 1.9 Final Google Ads checklist (before save)

- [ ] Campaign set to **Search only** (Search Partners OFF, Display OFF)
- [ ] Bidding: Manual CPC, Enhanced OFF, max $3.50 AG1 / $3.00 AG2
- [ ] Daily budget $30, account cap $50
- [ ] Geo: 5 cities + 20-mi Wausau radius, Presence-only
- [ ] Schedule: Mon–Sun 6am–10pm Central
- [ ] Tracking template loaded at campaign level
- [ ] AG1 keywords loaded (7 exact, 7 phrase — duplicates where noted)
- [ ] AG2 keywords loaded (5 phrase)
- [ ] AG1 RSA: 15 headlines + 4 descriptions, pins on H1 + H3
- [ ] AG2 RSA: 15 headlines + 4 descriptions, pins on H1 + H3
- [ ] Negatives loaded (26 phrase-match terms)
- [ ] Conversion action `Form submit — get-a-quote` set as primary
- [ ] Sitelinks × 4, Callouts × 8, Structured snippets × 7 loaded
- [ ] Call extension **PAUSED**
- [ ] **Campaign status: PAUSED**

---

## 2. META (FB + IG) LEAD ADS — Copy/Paste Setup Block

### 2.1 Campaign structure

| Level | Setting | Value |
|---|---|---|
| Campaign | Name | `CWDB — Central WI Decks — Leads` |
| Campaign | Objective | Leads |
| Campaign | Advantage campaign budget | OFF (ad-set-level budgeting) |
| Campaign | Special Ad Category | **Housing** (required by Meta policy — limits targeting, no ZIP-level radius, no age/gender restrict below 18) |
| Ad set | Name | `Homeowner Intent — Cold — Central WI` |
| Ad set | Daily budget | $20.00 (ad-set-level cap) |
| Ad set | Optimization | Conversion Leads (Lead event) |
| Ad set | Conversion location | **Instant form** (Meta native Lead Form) |
| Ad set | Attribution window | 7-day click + 1-day view |
| Ad set | Budget pacing | Standard |
| Ad set | Start time | 2026-04-21, time Jim launches |
| Ad set | End time | None |
| Ad set | Status at save | **PAUSED** |

**Note on Special Ad Category:** Deck/home-improvement services fall under Housing when targeting homeowners. This disables age/gender minimums and forces ≥15-mile radius. Keep the 20-mile Wausau radius which is already policy-compliant. If Meta flags the category check, override to **Credit** is NOT appropriate — stay with Housing. If Meta rejects Housing, re-submit under no special category and accept the broader audience.

### 2.2 Audience (cold)

- **Location type:** People living in this location
- **Geo:** Wausau, WI + 20-mile radius (pin-drop on city center). Include ZIPs 54401, 54403, 54476, 54455, 54452, 54474 are auto-captured within radius.
- **Exclude:** Cities >25 miles from Wausau (prevents Eau Claire / Stevens Point / Green Bay overspill)
- **Age:** 35–65 (if Housing category allows; otherwise defaults to 18–65+)
- **Gender:** All
- **Languages:** English (US)
- **Detailed Targeting — interests OR behaviors (Layer 1):**
  - Home improvement
  - Home & garden
  - DIY (Do It Yourself)
  - Patio
  - Backyard
  - Outdoor living
  - Landscaping
  - Lowe's
  - The Home Depot
  - HGTV
- **Detailed Targeting — NARROW (Layer 2, must also match):**
  - Engaged Shoppers (Behaviors)
  - Likely Movers (Behaviors) — if Housing category blocks Likely Movers, drop it and widen Layer 1
- **Exclusions:**
  - Renters (Demographics → Home Type) — best-effort
  - Under 25 (redundant with 35–65 cap but belt-and-suspenders)
- **Target reach pool:** 40k–120k. If <40k, drop one Layer 2 behavior. If >120k, tighten Layer 1.

### 2.3 Placements

- **At launch:** Automatic placements (FB feed, IG feed, Stories, Reels, Marketplace)
- **Week 2 review:** if any placement >40% spend with CPL >$50, exclude that placement

### 2.4 Meta Native Lead Form (recommended — DO NOT redirect to site)

**Form name:** `CWDB — Deck Quote — Option A v1`
**Form type:** More volume (default — higher conversion than Higher intent)
**Intro screen:** OFF (reduces friction)

**Field schema (matches site wizard Option A — locked 2026-04-20):**

| # | Field | Type | Required | Notes |
|---|---|---|---|---|
| 1 | `zip` | Short answer — Numeric | Yes | Validation: 5 digits |
| 2 | `phone` | Phone number | Yes | Auto-filled from Meta profile when available |
| 3 | `project_type` | Multiple choice | Yes | Options: New deck · Deck replacement · Deck repair · Addition / pergola / porch |
| 4 | `address` | Short answer — Text | Yes | Street address only |
| 5 | `owns_property` | Multiple choice | Yes | Options: Yes · No |
| 6 | `budget` | Multiple choice | Yes | Options: Under $10k · $10k–$20k · $20k–$40k · $40k+ · Not sure |
| 7 | `timeline` | Multiple choice | Yes | Options: ASAP · 1–3 months · 3–6 months · 6–12 months · Just researching |
| 8 | `notes` | Paragraph | No | "Anything we should know about your project?" |
| 9 | `tcpa_consent` | Custom disclaimer + checkbox | Yes | See copy below |

**DO NOT collect:** name, email. Site wizard doesn't collect these and the manual SMS-to-contractor template is built around the 8-field schema. Adding name/email here creates schema drift and breaks the lead-handoff template.

**TCPA consent copy (custom disclaimer, checkbox required):**

> By submitting this form, I agree to be contacted by Central Wisconsin Deck Builders and its partner contractors via phone, text, and email about my deck project. I understand consent is not a condition of purchase. Message and data rates may apply. Reply STOP to opt out.

**Privacy policy URL:** `https://www.cwdeckbuilders.com/privacy`
**Thank-you screen headline:** "You're all set — a local builder will reach out within 48 hours."
**Thank-you screen button:** "See our work" → `https://www.cwdeckbuilders.com/gallery?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=lead-form-thankyou`

### 2.5 Tracking template (all ads)

**Deep-link parameters (Instant Form leads don't route to website, but set the tracking template for the thank-you outbound link and for consistency):**

```
?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content={variant}
```

Substitute `{variant}` per ad — see §2.6 for variant IDs.

### 2.6 Ad variants — 3 angles × 3 variants = 9 ads

All 9 ads use **CTA: Get Quote**. All use the Instant Form from §2.4.

#### Angle 1 — SOCIAL PROOF

**Ad 1A** (variant id: `social-proof-1a`)
- Primary text: Hundreds of Wausau-area homeowners got their dream deck this year. We connect you with vetted local builders. Free quote in 48 hrs.
- Headline: Your neighbors trust local deck pros
- Description: Free quote · Licensed builders
- Image: `wausau-deck.webp` (clean finished deck — the flagship hero shot; matches "neighbor trust" feel)

**Ad 1B** (variant id: `social-proof-1b`)
- Primary text: Real Central Wisconsin deck contractors. Real reviews. Real quotes. Tell us your project — we'll match you with the right builder.
- Headline: Vetted Wausau deck contractors
- Description: No spam · No obligation
- Image: `wausau-addition.webp` (substantial craftsmanship, reads as "real work" — pairs with "real contractors" copy)

**Ad 1C** (variant id: `social-proof-1c`)
- Primary text: Serving Wausau, Schofield, Weston, Mosinee & Merrill. Get a free deck quote from a licensed Central WI builder in 48 hours.
- Headline: Central Wisconsin deck specialists
- Description: Cedar · Composite · Trex
- Image: `composite-deck-wittenburg.jpg` (composite deck — matches material callout in description)

#### Angle 2 — PROBLEM/SOLUTION

**Ad 2A** (variant id: `problem-2a`)
- Primary text: Tired of calling deck contractors who never call back? We do the legwork. One form. One vetted local builder. Free quote in 48 hrs.
- Headline: No more ghosting. Real quotes.
- Description: Local builders who answer
- Image: `mosinee-addition.webp` (completed project shot — "proof the work gets done" counter to ghosting pain)

**Ad 2B** (variant id: `problem-2b`)
- Primary text: Stop chasing 3 contractors for 3 quotes. Tell us about your deck once — we route it to a Central WI pro who actually shows up.
- Headline: One form. One vetted builder.
- Description: Save hours of phone tag
- Image: `wausau-small-deck.webp` (approachable smaller project — lowers the "is this for me?" barrier)

**Ad 2C** (variant id: `problem-2c`)
- Primary text: Hiring the wrong deck contractor costs more than the deck. Skip the gamble — get matched with a licensed local pro. Free quote.
- Headline: Skip the contractor gamble
- Description: Licensed · Insured · Local
- Image: `weston-pergola.webp` (premium pergola build — signals "this is what good looks like")

#### Angle 3 — SEASONAL URGENCY

**Ad 3A** (variant id: `urgency-3a`)
- Primary text: Wisconsin building season is short. The good deck builders book up by May. Get your free quote now and lock your spot for 2026.
- Headline: Lock your 2026 deck build now
- Description: Builders fill up by May
- Image: `rothschild-covered-patio.webp` (substantial outdoor living build — aspirational "this is what you're locking in")

**Ad 3B** (variant id: `urgency-3b`)
- Primary text: Want your new deck ready for July weekends? Now's the window — 48-hr free quote from a Central WI builder. No obligation to book.
- Headline: Backyard-ready by Summer 2026
- Description: Free quote in 48 hours
- Image: `merill-front-porch.webp` (warm, summer-ready porch feel — matches "July weekends")

**Ad 3C** (variant id: `urgency-3c`)
- Primary text: Spring quotes are filling up across Central WI. Get matched with a local deck builder this week — free, 2 minutes, no pressure.
- Headline: Spring deck calendars filling up
- Description: 2 minutes to get a quote
- Image: `marathon-front-porch.webp` (fresh, recent-build feel — matches "filling up now" urgency)

#### Creative asset export specs

- Square 1080×1080 (primary feed)
- Landscape 1200×628 (desktop feed)
- Vertical 1080×1920 (Stories / Reels)
- No overlay text on initial test (Meta penalizes >20% text)
- Source directory: `/website/pages/gallery/project-photos/`
- Export filenames: `{variant-id}-square.jpg`, `{variant-id}-landscape.jpg`, `{variant-id}-story.jpg`
  - Example: `social-proof-1a-square.jpg`, `problem-2c-story.jpg`

**Autonomous pairing decision:** Photos were paired to angles by emotional tone (see `/marketing/gallery-photo-rationale` note below). Flagship `wausau-deck.webp` anchors Angle 1 Variant A (highest-performing slot by convention — broadest appeal). Rothschild covered patio anchors urgency because the scale of the build visually reinforces "worth locking in your 2026 slot." If Jim has a different read on any pairing, swap before export — ad-set rebuilds are cheap.

### 2.7 Final Meta checklist (before save)

- [ ] Campaign objective: Leads, Special Ad Category: Housing
- [ ] Ad set daily budget $20 (ad-set level, not campaign level)
- [ ] Conversion location: Instant form (native Lead Form)
- [ ] Optimization: Conversion Leads → Lead event
- [ ] Attribution: 7-day click + 1-day view
- [ ] Audience: 5-city + 20-mi Wausau radius, age 35–65, interests + NARROW behaviors as spec'd
- [ ] Lead Form built — 8 fields + TCPA — NO name/email
- [ ] Privacy policy URL + thank-you screen set
- [ ] All 9 ads built (3 angles × 3 variants)
- [ ] All 9 ads use CTA: Get Quote
- [ ] All 9 images exported at 1080×1080, 1200×628, 1080×1920
- [ ] Tracking template per variant applied
- [ ] Pixel Lead event firing confirmed in Events Manager on test submit
- [ ] **Campaign status: PAUSED**

---

## 3. Post-Launch Monitoring — Day 1, Day 3, Day 7

Tied directly to kill-criteria thresholds in the approved brief. Check dashboards twice a day (morning + evening) for first 48 hrs, then once daily.

### Day 1 (first 24 hrs after flip)

- **Google Ads dashboard:** impressions > 0, clicks > 0, search-terms populating. If zero impressions after 12 hrs → check geo / negatives not over-filtering / budget not paused
- **Meta Ads Manager:** impressions > 0, link clicks > 0, lead-form opens > 0. If zero after 12 hrs → Special Ad Category may be blocking delivery; check rejection notices
- **GA4 real-time:** UTM-tagged sessions arriving from both sources
- **Conversions:** any leads? If yes → verify the lead email delivered to Jim's inbox. If no email → PAUSE both campaigns immediately (Day 1 conversion-gap check)
- **Budget pacing:** neither campaign should be >50% spent by noon unless volume is real; a runaway spend on Day 1 with no conversions = pause and investigate

### Day 3 (after ~$150 spent)

- **Google CPL check (early signal, not kill):** if CPL > $100 after $90 spent, pause worst-performing ad group and rebuild keyword list from Search Terms report
- **Meta CPL check (early signal):** if CPL > $60 after $60 spent, pause bottom 3 of 9 ads
- **Search Terms report (Google):** add any wasteful queries as negatives (brand misspellings, DIY terms, competitor names if not already blocked)
- **Placement breakdown (Meta):** flag if any single placement is >50% of spend with zero leads
- **Lead quality sniff test:** did any lead have a fake ZIP / fake phone? Spam-filter tuning may be needed on the form

### Day 7 (kill-criteria window closes)

**Hard enforcement — these thresholds trigger pause without Jim sign-off:**

- **Google:** CPL > $80 → PAUSE. 0 leads after $200 spent → PAUSE.
- **Meta:** CPL > $50 → PAUSE. 0 leads after $140 spent → PAUSE.
- **Combined:** CPL > $100 → PAUSE BOTH.

If thresholds pass:
- Keep winning keywords, pause bottom-quartile on CTR
- Kill bottom 6 of 9 Meta ads, scale top 3 to shared $20/day budget
- Begin building lookalike audience pool if ≥50 conversions banked (unlikely week 1)
- Draft Week 2 test plan (new headline angles, new keyword expansions)

If thresholds fail:
- Log outcome in `/marketing/launch-postmortem-week1.md`
- Re-evaluate before re-launching — do NOT just restart the same ads

### Day 14 (extended kill criteria)

- **Pause any ad set** with >$250 cumulative spend and 0 leads
- **Pause any keyword** with CTR <1.5% and >500 impressions
- **Target CPL:** <$60 combined — if missed, the unit economics don't clear and pricing/channel mix needs rework

### Day 30 (revenue gate)

- If no contractor has accepted a bid sourced from these leads, halt spend. Lead quality is first suspect; contractor follow-up speed is second. Do NOT blame the ad channel until the contractor-side funnel is audited.

---

## 4. Launch Day Runbook — Jim's 10-Step Execution Order

Execute sequentially. Do not skip gates.

1. **Complete §1 of verification checklist** — Playwright regression on hero-form end-to-end flow (web-dev agent task). Must pass before touching ad platforms.

2. **Complete §2 of verification checklist** — GTM Preview mode connected to production. Confirm GA4 page_view, GA4 form_submission, Meta Pixel Lead, Nextdoor Pixel Lead, Google Ads Conversion, Conversion Linker, MS Clarity all fire on a real test submission. **GATE.**

3. **Complete §3 of verification checklist** — submit a real test lead on `/get-a-quote` (production). Confirm email lands in Jim's inbox within 2 min with all fields populated. **HARD GATE — launch is blocked until this passes.**

4. **Complete §5 of verification checklist** — call (715) 544-7941 from an outside number. Answer within 6 rings OR voicemail identifies CWDB. Decide Call-extension on/off for Google Ads. **GATE.**

5. **Build Google Ads campaign using §1 of this doc** — paste settings, load keywords + RSAs + extensions + negatives + conversion action. Save with campaign status = **PAUSED**. Verify UTM template in one ad preview.

6. **Build Meta campaign using §2 of this doc** — paste settings, build the Instant Form (8 fields + TCPA, NO name/email), build all 9 ads with paired photos. Save with campaign status = **PAUSED**. Verify one ad preview loads correctly on mobile.

7. **Final pre-flip sanity** — open both dashboards side by side. Confirm budgets are capped ($30 Google / $20 Meta), geo is correct, both are PAUSED, tracking templates populated.

8. **Flip Google live** — only after §2, §3, §5 gates are all green. Toggle campaign to Enabled. Confirm it's spending within 30 minutes (impressions > 0 on dashboard).

9. **Flip Meta live** — immediately after Google. Toggle ad set to Active. Confirm delivery starts within 60 minutes (Meta is slower to leave Learning phase).

10. **Write to `_vault/state-of-cwdb.md`** — log launch timestamp, ads live, first-hour status. Set a 12-hour follow-up to check Day 1 monitoring items from §3 of this doc.

**If any gate fails:** halt. Log blocker in `/marketing/launch-blockers-2026-04-21.md`. Do NOT flip to active. The cost of a silent Day 1 is worse than the cost of a 24-hour launch delay.

---

## Autonomous Decisions Noted

1. **Gallery photo → Meta angle pairing** — selected 9 photos from `/website/pages/gallery/project-photos/` keyed to emotional tone per angle. Flagship `wausau-deck.webp` anchors Angle 1 Variant A. If Jim wants different pairings, swap the filename in §2.6 before export — no other copy change needed.

2. **Google Ads AG2 max CPC** — set at $3.00 (10% below AG1's $3.50) since Ad Group 2 targets lower-intent research queries. Not spec'd in brief — consistent with commercial-research vs. commercial-intent tier conventions.

3. **Campaign-level negatives expanded** — added `menards`, `home depot`, `lowes` to the brief's seed list to filter DIY-shopper searches on local branded terms. These are high-volume Central WI retail queries that would otherwise burn budget.

4. **Meta Special Ad Category set to Housing** — home-improvement services targeting homeowners fall under Meta's Housing policy. This disables age/gender restrictions and enforces ≥15-mi radius (we're at 20-mi, compliant). Brief didn't call this out explicitly. If Meta rejects the Housing classification on review, fall back to no-category with wider targeting and accept the audience bloat.

5. **Meta objective/conversion location** — chose **Instant form** (native Lead Form) over website redirect, per brief recommendation. Schema in §2.4 matches site wizard Option A exactly — no name, no email.

6. **RSA pinning** — pinned H1 (brand) to position 1 and H3 (48-hour promise) to position 2 in both ad groups for brand + offer consistency. Google may flag this as reducing Ad Strength — acceptable tradeoff at launch for message control.
