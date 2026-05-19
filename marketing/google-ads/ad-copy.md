---
type: reference
status: launch-ready
created: 2026-03-11
updated: 2026-04-21
launch_target: 2026-04-24
tags:
  - type/reference
  - dept/marketing
  - platform/google-ads
---

# GOOGLE ADS — CWDB Launch Campaign

**Platform:** Google Search Ads
**Campaign:** CWDB — Central WI Decks — Search
**Market:** [[Central Wisconsin Deck Builders LLC|Central Wisconsin Deck Builders]]
**Daily budget:** $30 (per launch brief)
**Landing page:** `https://www.cwdeckbuilders.com/get-a-quote`

---

## Ad Group Structure

| Ad group | Match types | Theme |
|---|---|---|
| Deck Builder Intent | Phrase + Exact | "X near me" / "deck builder [city]" — high-intent commercial |
| Deck Quote Intent | Phrase | "deck quote", "estimate", "cost" — comparison-stage |

---

## Responsive Search Ad — Headlines (30-char max each)

RSA requires min 3, max 15 unique headlines. Pin Headline 1 to position 1 for brand consistency.

| # | Headline | Chars | Pin |
|---|---|---|---|
| 1 | Wausau Deck Builders | 20 | Position 1 |
| 2 | Get a Free Deck Quote | 21 | — |
| 3 | Quote in 48 Hours | 17 | — |
| 4 | Local Deck Contractors | 22 | — |
| 5 | Central WI Deck Experts | 23 | — |
| 6 | Licensed & Insured Pros | 23 | — |
| 7 | Trusted Wisconsin Builders | 26 | — |
| 8 | Build Your Dream Deck | 21 | — |
| 9 | Custom Deck Installation | 24 | — |
| 10 | Composite Decks — Wausau | 24 | — |
| 11 | Free Estimates — Book Now | 25 | — |
| 12 | New Decks · Repair · Replace | 28 | — |
| 13 | Backed by Local Pros | 20 | — |
| 14 | Cedar, Composite, Trex | 22 | — |
| 15 | Serving 5 Central WI Cities | 27 | — |

---

## Responsive Search Ad — Descriptions (90-char max each)

RSA requires min 2, max 4. All four below are <=90 chars (verified).

1. Connect with vetted Central Wisconsin deck builders. Free quote in 48 hours. No hassle. (88)
2. Licensed deck pros in Wausau, Schofield, Weston, Mosinee & Merrill. Get matched fast. (85)
3. Cedar, composite, multi-level — get a no-obligation quote from a local builder today. (87)
4. Skip the ghosting. Real local contractors who actually call back. Free quote, 2 minutes. (89)

---

## Display URL Paths (15-char max each)

- `/deck-quote`
- `/wausau-decks`

---

## Ad Extensions

### Sitelink extensions (4 — verify URLs resolve post-Phase-4 deploy)

| Sitelink Title | URL | Description Line 1 (35) | Description Line 2 (35) |
|---|---|---|---|
| See Our Work | `https://www.cwdeckbuilders.com/gallery` | Real Central WI deck projects | Cedar, composite, multi-level |
| Estimate Deck Cost | `https://www.cwdeckbuilders.com/cost-calculator` | Get a ballpark in 60 seconds | Free, no signup needed |
| Meet the Builders | `https://www.cwdeckbuilders.com/our-builders` | Vetted local deck contractors | Licensed and insured |
| Common Questions | `https://www.cwdeckbuilders.com/faq` | Costs, timelines, materials | Wisconsin permits + more |

### Callout extensions (~25 char each, 4-10 recommended)

- Licensed & Insured
- Free Quotes
- Local Wisconsin Builders
- 48-Hour Response
- Cedar · Composite · Trex
- Serving 5 Cities
- No Obligation
- Vetted Contractors

### Structured snippet extensions

- **Header: Service catalog**
  - New Decks
  - Deck Repair
  - Deck Replacement
  - Composite Decks
  - Multi-Level Decks
  - Screen Porches
  - Pergolas

### Call extension

- Number: (715) 544-7941
- Schedule: Mon-Sat 8am-7pm Central
- **Default state at launch:** ENABLED if Jim confirms phone is answered promptly during business hours. Otherwise PAUSED until manual answer-path is sorted (see launch checklist).

### Location extension

- Defer until Google Business Profile is verified. Track separately.

---

## Call-to-Action Options

For ad copy and sitelinks (rotational):
- Get My Free Quote
- Request a Quote
- See Pricing
- Book a Consultation

---

## UTM Tracking

Final tracking template (applied at the campaign level, auto-tagged to all ads):

```
{lpurl}?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content={adgroup}-{creative}&utm_term={keyword}
```

Example resolved URL:
```
https://www.cwdeckbuilders.com/get-a-quote?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=deckbuilder-rsa1&utm_term=deck+builder+wausau
```

---

## Negative Keywords (Seed — Campaign Level)

Add these as Phrase or Exact match negatives at the campaign level on day 1. Expand from search-terms report after week 1.

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
```

---

## Conversion Tracking

- Conversion action: `Form submit — get-a-quote`
- Live via GTM since Phase F (2026-04-18, container published to production)
- Trigger: page view on `/thank-you` (form action redirects on submit)
- Conversion value: $200 per lead (estimated; revisit after Week 1 with actual close-rate data)
- **Pre-launch verification gate:** submit 1 real test lead on production after Phase 4 promote, confirm conversion fires in Google Ads conversion column within 24 hours.

---

## Bidding Strategy

- **Week 1-2:** Manual CPC (cap at ~$3.50 per click). Goal: collect data, control spend.
- **Week 3+:** Switch to Maximize Conversions if 15+ conversions banked. If not, stay manual.
- **Week 6+:** Switch to Target CPA at $50 if 30+ conversions banked.

---

## Launch Day Checklist

- [ ] All 15 headlines + 4 descriptions loaded into RSA
- [ ] All 4 sitelinks loaded with descriptions
- [ ] Callouts (8) loaded
- [ ] Structured snippets loaded
- [ ] Call extension loaded with schedule (status TBD at launch)
- [ ] Final URLs include UTM tracking template
- [ ] $30/day campaign-level budget set, $50/day account-level cap
- [ ] Geo: Wausau, Schofield, Weston, Mosinee, Merrill + 20-mi radius (Presence: People in target locations)
- [ ] Negative keyword list loaded at campaign level
- [ ] Conversion tracking verified (1 real test lead)
- [ ] Ad scheduling: Mon-Sun 6am-10pm Central (homeowners search heavily during evenings)
- [ ] Device targeting: All devices, no bid adjustment at launch
