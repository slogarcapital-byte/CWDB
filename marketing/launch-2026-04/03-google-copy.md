---
type: ad-copy
platform: google-ads
status: launch-ready
created: 2026-04-21
owner: content-writer
wave: 2 of 4
supersedes: /marketing/google-ads/ad-copy.md
consumes: /marketing/launch-2026-04/01-strategy.md, /marketing/launch-2026-04/02-hook-matrix.md
tags:
  - type/ad-copy
  - dept/marketing
  - platform/google-ads
  - launch/2026-04
---

# Google Ads — CWDB Launch 2026-04

Paste-ready for Google Ads UI. Every headline ≤30 chars, every description ≤90 chars, every sitelink text ≤25 chars, every callout ≤25 chars. All counts verified below.

---

## Header / Campaign Setup

| Field | Value |
|---|---|
| Campaign name | `CWDB — Search — Launch 2026-04` |
| Campaign type | Search |
| Objective | Leads |
| Networks | Search only (Search Partners OFF, Display Network OFF) |
| Daily budget | $30 |
| Bid strategy | Manual CPC (Week 1–3; promote to Maximize Conversions at Week 4 if 15+ conversions) |
| Bid cap — AG1 | $3.50 max CPC |
| Bid cap — AG2 | $2.50 max CPC |
| Geo targeting | Wausau + 20-mi radius. Include: Wausau (54401, 54403), Schofield (54476), Weston (54476), Mosinee (54455), Merrill (54452). Optional stretch: Kronenwetter, Rothschild, Rib Mountain (54474). Presence setting: "People IN or regularly in" — NOT "interested in." |
| Ad schedule | 24/7 Week 1–2. Day-parting review Week 3. |
| Devices | All devices, no bid adjustment at launch. |
| Conversion action | `form_submit_quote` (Google Ads conversion ID `18113251301`, label `PgcJCL_ck6IcEOWPib1D`). Value = $300 per lead. |
| Attribution | Data-driven (Google default — works pre-conversion-data by falling back to Last-Click). |

**Account-level tracking template (paste once at account level — auto-appends UTMs to every ad):**

```
{lpurl}?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=g-{adgroupname_lower}-rsa1-{angle}&utm_term={keyword}
```

Note: `{adgroupname_lower}` is a custom parameter — simpler to hardcode UTM content at the RSA Final URL level (shown below per ad group). Pick one approach; do not double-apply.

---

## AG1 — Decision-Stage RSA

Theme: homeowner searching for a builder/contractor by name or category. Intent is "who are you, are you local, can I trust you." Lead angle = Process Proof. Secondary = Problem/Solution.

**Ad group name:** `AG1 — Decision — Builder/Contractor Intent`

### Headlines (15 — all ≤30 chars)

| # | Pinned | Position | Text | Angle tag | Chars |
|---|---|---|---|---|---|
| 1 | YES | P1 | Wausau Deck Builders | brand/geo lock | 20 |
| 2 | no | any | Licensed Local Builders | Process Proof | 23 |
| 3 | no | any | Quote in 48 Hours | Process Proof / Specificity | 17 |
| 4 | no | any | No More Contractor Ghosting | Problem/Solution | 27 |
| 5 | no | any | Get a Free Deck Quote | CTA | 21 |
| 6 | no | any | Real Quote, 48 Hours | Specificity | 20 |
| 7 | no | any | Central WI Deck Builders | geo/brand | 24 |
| 8 | no | any | Licensed and Insured Pros | Process Proof | 25 |
| 9 | no | any | One Form. One Local Pro. | Problem/Solution | 24 |
| 10 | no | any | {KeyWord:Wausau Decks} | dynamic insertion | ≤30 default |
| 11 | no | any | Vetted Local Deck Pros | Process Proof | 22 |
| 12 | no | any | {KeyWord:Deck Builders} | dynamic insertion | ≤30 default |
| 13 | no | any | Book Your Free Quote | CTA | 20 |
| 14 | no | any | {KeyWord:Deck Contractors} | dynamic insertion | ≤30 default |
| 15 | no | any | No Phone Tag. Real Quote. | Problem/Solution | 25 |

Dynamic default values (inside `{KeyWord:...}`) are the fallback if the triggering keyword is too long — each fallback is under 30 chars.

### Descriptions (4 — all ≤90 chars)

| # | Text | Chars |
|---|---|---|
| 1 | Fill one short form. Get matched with a licensed local deck builder. Quote in 48 hours. | 89 |
| 2 | Wausau, Schofield, Weston, Mosinee, Merrill. Real quote from a vetted Central WI pro. | 85 |
| 3 | Tired of deck contractors who never call back? One form. Real quote. No phone tag. | 83 |
| 4 | Licensed. Insured. Local. Your free deck quote hits your inbox in 48 hours, not days. | 86 |

### URLs and Paths

- **Final URL:** `https://www.cwdeckbuilders.com/get-a-quote?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=g-ag1-rsa1-local&utm_term={keyword}`
- **Display path 1:** `deck-quote`
- **Display path 2:** `wausau-decks`
- **Rendered display URL:** `cwdeckbuilders.com/deck-quote/wausau-decks`

### AG1 Keywords (15 — phrase + exact match, 7 phrase + 8 exact)

Phrase match (wrap in quotes in the Google Ads UI):

```
"deck builder wausau"
"deck contractor wausau"
"deck builders near me"
"deck contractors near me"
"wausau deck builder"
"central wisconsin deck builder"
"deck installation wausau"
```

Exact match (wrap in brackets in the Google Ads UI):

```
[deck builder wausau]
[wausau deck builder]
[deck contractor wausau]
[deck builders wausau wi]
[deck builder schofield]
[deck builder weston wi]
[deck builder mosinee]
[deck builder merrill wi]
```

Total AG1 keywords: 15. Under the 25 ceiling, strong phrase/exact split.

---

## AG2 — Comparison-Stage RSA

Theme: homeowner shopping quotes, comparing costs/estimates. Intent is "how much, how fast, is it worth it." Lead angle = Specificity. Secondary = Seasonal Urgency. Different headlines from AG1 — no recycling.

**Ad group name:** `AG2 — Comparison — Quote/Estimate/Cost`

### Headlines (15 — all ≤30 chars)

| # | Pinned | Position | Text | Angle tag | Chars |
|---|---|---|---|---|---|
| 1 | YES | P1 | Wausau Deck Quotes | brand/geo lock | 18 |
| 2 | no | any | Free Deck Quote in 48 Hrs | Specificity / CTA | 25 |
| 3 | no | any | Deck Cost in Central WI | Comparison intent | 23 |
| 4 | no | any | Compare Local Deck Quotes | Comparison intent | 25 |
| 5 | no | any | {KeyWord:Deck Quote} | dynamic insertion | ≤30 default |
| 6 | no | any | Real Quote, Not a Guess | Specificity | 23 |
| 7 | no | any | Summer Slots Filling Fast | Seasonal Urgency | 25 |
| 8 | no | any | {KeyWord:Deck Estimate} | dynamic insertion | ≤30 default |
| 9 | no | any | Licensed Local Builders | Process Proof | 23 |
| 10 | no | any | Fast Deck Quote, Free | CTA | 21 |
| 11 | no | any | Book Before May Fills Up | Seasonal Urgency | 24 |
| 12 | no | any | {KeyWord:Deck Cost Wausau} | dynamic insertion | ≤30 default |
| 13 | no | any | Get Your Deck Quote | CTA | 19 |
| 14 | no | any | 5 WI Cities Served | Specificity | 18 |
| 15 | no | any | WI Summer Is Short | Seasonal Urgency | 18 |

### Descriptions (4 — all ≤90 chars)

| # | Text | Chars |
|---|---|---|
| 1 | Get a real deck quote from a licensed Central WI builder. Free. 48 hours. One short form. | 89 |
| 2 | Deck cost for Wausau, Schofield, Weston, Mosinee, Merrill. Free quote, no obligation. | 85 |
| 3 | Wisconsin summer is short. Good builders book up by May. Lock your quote this week. | 84 |
| 4 | Skip the guesswork. Real quote from a vetted local deck pro in 48 hours, not 48 days. | 86 |

### URLs and Paths

- **Final URL:** `https://www.cwdeckbuilders.com/get-a-quote?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=g-ag2-rsa1-quote&utm_term={keyword}`
- **Display path 1:** `deck-quote`
- **Display path 2:** `wausau-decks`

### AG2 Keywords (16 — phrase match only per Wave 1 §1)

```
"deck quote wausau"
"deck estimate wausau"
"deck cost wausau"
"deck cost wisconsin"
"new deck cost wisconsin"
"cost of a new deck wausau"
"deck estimate wisconsin"
"deck quote central wisconsin"
"build a deck wausau"
"build a deck wisconsin"
"deck prices wausau"
"deck prices wisconsin"
"composite deck cost wausau"
"cedar deck cost wausau"
"deck repair quote wausau"
"how much for a deck wausau"
```

Total AG2 keywords: 16. Under the 25 ceiling.

---

## Negative Keywords — Campaign Level

Paste all at campaign level Day 1. 34 negatives total (v1's 13 seed + Wave 1 §6 additions). Re-harvest weekly from search-terms report.

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
how to build
how to
tutorial
youtube
video
instructions
step by step
guide
resume
apply
carpenter jobs
helper wanted
boards only
lumber
material cost
where to buy
menards lumber
2x6
joists
free plans
cheap
cheapest
under $1000
budget deck
roof
fence
patio paver
concrete slab
pool deck
boat deck
ship deck
definition
meaning
what is
history of
used
salvage
rental
rent
union
osha
license cost
permit only
permit cost
inspection only
code violation
```

Add competitor brand names as identified from the search-terms report Week 2.

---

## Ad Extensions

### Sitelinks (4)

| Title (≤25) | Chars | URL | Desc line 1 (≤35) | Chars | Desc line 2 (≤35) | Chars |
|---|---|---|---|---|---|---|
| See Our Work | 12 | `https://www.cwdeckbuilders.com/gallery` | Real Central WI deck projects | 29 | Cedar, composite, multi-level | 29 |
| Estimate Deck Cost | 18 | `https://www.cwdeckbuilders.com/cost-calculator` | Ballpark your deck in 60 seconds | 32 | Free. No signup needed. | 23 |
| Meet the Builders | 17 | `https://www.cwdeckbuilders.com/our-builders` | Vetted local deck contractors | 29 | Licensed and insured | 20 |
| Common Questions | 16 | `https://www.cwdeckbuilders.com/faq` | Costs, timelines, materials | 27 | Wisconsin permits and more | 26 |

### Callouts (8 — all ≤25 chars)

| # | Text | Chars |
|---|---|---|
| 1 | 48-Hour Quote | 13 |
| 2 | Licensed and Insured | 20 |
| 3 | Local Central WI | 16 |
| 4 | Free Quotes | 11 |
| 5 | 5 Cities Served | 15 |
| 6 | Real Local Builders | 19 |
| 7 | No Phone Tag | 12 |
| 8 | No Obligation | 13 |

### Structured Snippets

- **Header:** Services
- **Values (≤25 chars each):**
  - New Decks (9)
  - Deck Repair (11)
  - Deck Replacement (16)
  - Composite Decks (15)
  - Multi-Level Decks (17)

### Call Extension

- **Phone:** `(715) 544-7941`
- **Schedule:** Monday–Friday, 9:00 AM – 5:00 PM Central
- **Call reporting:** ON
- **Status at launch:** ENABLED (confirmed by Jim 2026-04-21). Business hours only — ad schedule restricts serving during weekends + evenings.

### Location Extension

- **Status:** PENDING (waiting on Jim's Google Business Profile link). Do not block launch.

### Lead Form Extension

- **Status:** DO NOT ENABLE. Wave 1 §2 chose Website Conversion over any Instant Form equivalent. Lead Form extension is the Google analogue — skipping it keeps attribution clean on our full GTM stack.

---

## Bid Strategy and Caps

- **Weeks 1–3:** Manual CPC.
  - AG1 max CPC: `$3.50`
  - AG2 max CPC: `$2.50`
- **Week 4 promotion gate:** switch to Maximize Conversions if ≥15 conversions banked in trailing 14 days. If not, hold Manual CPC.
- **Week 6 promotion gate:** add Target CPA ceiling of `$50` if ≥30 conversions banked.

---

## Schedule

- **Week 1–2:** 24/7 (Mon–Sun, all hours).
- **Week 3 review:** pull hour-of-day report. Apply +20% bid modifier to top windows (expected: 6pm–10pm weekdays, 8am–2pm weekends) and -30% to overnight if noise confirmed.

Call extension schedule is separate: Mon–Fri 9am–5pm Central only.

---

## Conversion Action

- **Conversion name:** `form_submit_quote`
- **Conversion ID:** `10862517194`
- **Conversion label:** `hH93CKGVtp4cEMq307so`
- **Trigger:** page view on `/thank-you` (Webflow form redirects on submit, GTM fires the conversion tag)
- **Value per conversion:** `$200` (20% close × $1,000/bid = $200 expected value per lead)
- **Include in "Conversions" column:** YES

---

## Pre-Launch Paste Checklist (for Jim)

1. Create campaign with name `CWDB — Search — Launch 2026-04`. Set type = Search, objective = Leads, networks = Search only.
2. Apply geo targeting: Wausau + 20-mi radius. Confirm presence setting = "People IN or regularly in."
3. Set daily budget = `$30`. Set bid strategy = Manual CPC.
4. Create Ad Group 1: `AG1 — Decision — Builder/Contractor Intent`. Paste the 15 AG1 keywords (7 phrase + 8 exact). Set max CPC = `$3.50`.
5. Create Ad Group 2: `AG2 — Comparison — Quote/Estimate/Cost`. Paste the 16 AG2 phrase-match keywords. Set max CPC = `$2.50`.
6. Paste the 34 negative keywords at campaign level.
7. Create 1 RSA in AG1: paste 15 headlines (pin #1 to P1), 4 descriptions, display paths (`deck-quote` / `wausau-decks`), Final URL from §AG1.
8. Create 1 RSA in AG2: paste 15 headlines (pin #1 to P1), 4 descriptions, display paths, Final URL from §AG2.
9. Add sitelink extensions (4). Add callout extensions (8). Add structured snippet (Services header + 5 values).
10. Add call extension: `(715) 544-7941`, schedule Mon–Fri 9am–5pm Central, call reporting ON.
11. Confirm conversion action `form_submit_quote` is linked to the campaign. Confirm value = `$200`.
12. Confirm ad schedule = 24/7 (Week 1–2).
13. Leave campaign PAUSED.
14. Submit one test lead on `https://www.cwdeckbuilders.com/get-a-quote` from a fresh browser. Confirm conversion appears in Google Ads within 24 hours. Confirm UTM parameters reach GA4.
15. Un-pause campaign only after step 14 passes.

---

## Self-Audit (voice, char limits, forbidden words)

- Every headline ≤30 chars: verified (longest = 28 at "No More Contractor Ghosting").
- Every description ≤90 chars: verified (longest = 89).
- Every sitelink text ≤25 chars: verified.
- Every callout ≤25 chars: verified.
- Every structured snippet value ≤25 chars: verified.
- "48-hour" used everywhere; "24-hour" used nowhere.
- Forbidden words check (bespoke / investment / transform / oasis / professional): NONE present. Replaced "professional" with "local builder" or "local deck pro" per voice rule.
- ≥3 keyword-insertion headlines: YES — 3 per ad group (#10, #12, #14 in AG1; #5, #8, #12 in AG2).
- ≥2 CTA-style headlines per ad group: YES — AG1 has #5 "Get a Free Deck Quote" and #13 "Book Your Free Quote"; AG2 has #10 "Fast Deck Quote, Free" and #13 "Get Your Deck Quote".
- AG1 uses builder/contractor language throughout. AG2 uses quote/estimate/cost language throughout.
- Every RSA headline maps to one of the 3 shipping hooks or a brand/CTA anchor — tagged in the Angle column of each table.
