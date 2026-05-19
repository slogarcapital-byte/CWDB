---
type: ad-copy
platform: meta-ads
status: launch-ready
created: 2026-04-21
owner: content-writer
wave: 2 of 4
supersedes: /marketing/facebook-ads/ad-copy.md
consumes: /marketing/launch-2026-04/01-strategy.md, /marketing/launch-2026-04/02-hook-matrix.md
tags:
  - type/ad-copy
  - dept/marketing
  - platform/meta-ads
  - launch/2026-04
---

# Meta Ads — CWDB Launch 2026-04

Paste-ready for Meta Ads Manager. 2 ad sets × 2 ads = 4 ads total. Website Conversion objective to `/get-a-quote`. Pixel Lead event (confirmed firing Phase F).

**Important:** we are NOT using Instant Form / Lead Ads. Wave 1 §2 chose Website Conversion for attribution quality + full GTM stack coverage. Never reference "lead form" or "instant form" in copy or setup.

---

## Header / Campaign Setup

| Field | Value |
|---|---|
| Campaign name | `CWDB — Leads — Launch 2026-04` |
| Objective | Leads → Website Conversion |
| Conversion event | Lead (Meta Pixel) |
| Attribution window | 7-day click + 1-day view (default — do not change) |
| Budget structure | Ad-Set level (NOT CBO) |
| Daily budget per ad set | `$10/day` × 2 ad sets = `$20/day` total |
| Placements | Advantage+ Placements (automatic) |
| Pixel ID | (live from Phase F — Jim has on file; not hardcoded here) |
| Ad-set optimization | Conversions |
| Bid strategy | Highest volume (default — no bid cap at launch) |
| Start date | 2026-04-21 |

---

## Audience Reference

Full stacks live in `/marketing/facebook-ads/audiences.md` and Wave 1 §6. Summaries below so Wave 3 + Jim can paste without opening another doc.

### AS1 — Manual Core — Homeowner 35-65

Geo: Wausau + 20-mi radius (ZIPs 54401, 54403, 54476, 54455, 54452, optional 54474). Age 35–65. Gender: All. Interests (OR): Home improvement, Home & garden, Patio, Backyard, Outdoor living, Landscaping, HGTV, The Home Depot, Lowe's, DIY. Behaviors (AND/NARROW): Engaged Shoppers OR Likely Movers. Demographics: Homeowners, household income top 50% in area. Exclusions: Renters, Under 25.

### AS2 — Advantage+ Audience — Homeowner 35-65

Geo: same 5 ZIPs + 20-mi radius (hard constraint). Age: 35–65 (hard constraint). Detailed targeting suggestions: OFF (full Advantage+ audience). Exclusions: Renters only.

---

## AS1 — Manual Core — Homeowner 35-65

Ad-set name: `AS1 — Manual Core — Homeowner 35-65`

---

### Ad 1 — Problem/Solution

**Variant ID:** `m-as1-v1-problem`
**Ad name:** `AS1 — Problem Solution — v1 — problem`
**Angle:** Problem/Solution (hook #1 from `/marketing/launch-2026-04/02-hook-matrix.md`)

**Primary text (107 chars):**

> Tired of deck contractors who never call back? One form. One vetted local builder. Real quote in 48 hours.

**Headline (29 chars):**

> One form. Real local builder.

**Description (28 chars):**

> 48-hour quote. No phone tag.

**CTA button:** Get Quote
*Rationale:* matches Website Conversion intent + mirrors the wording on the landing-page hero. "Learn More" softens the click; we want form submissions, not window-shoppers.

**Destination URL:**

```
https://www.cwdeckbuilders.com/get-a-quote?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=m-as1-v1-problem
```

**Creative spec hand-off note to Wave 3:**
Evokes relief — problem named, solution shown. Imagery direction: a Central Wisconsin homeowner at a kitchen table, phone nearby showing a "missed call" screen or a stack of unanswered voicemails. Mid-40s, casual, realistic — NOT a stock "frustrated person" pose. Lighting: warm, kitchen-window natural. No text overlay on the image itself (Meta penalizes >20% text). Reserve contrast for headline placement above/below the image.

---

### Ad 2 — Process Proof

**Variant ID:** `m-as1-v2-process`
**Ad name:** `AS1 — Process Proof — v1 — process`
**Angle:** Process Proof (hook #2)

**Primary text (106 chars):**

> Licensed. Insured. Local to Central Wisconsin. Your deck quote hits your inbox in 48 hours — not 48 days.

**Headline (22 chars):**

> 48 hours, not 48 days.

**Description (23 chars):**

> Licensed local builders.

**CTA button:** Get Quote

**Destination URL:**

```
https://www.cwdeckbuilders.com/get-a-quote?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=m-as1-v2-process
```

**Creative spec hand-off note to Wave 3:**
Evokes trust + specificity. Imagery direction: a crisp, close-up shot of a finished Central Wisconsin cedar or composite deck — golden hour light, clean lines, visible craftsmanship (railing detail, board transitions). Use one of the real Wisconsin photos from the Gallery CMS (Webflow collection `69cff077a56c28009f3df538`). No people in frame — the work speaks. Square 1080×1080 + portrait 1080×1350. No overlay text on image.

---

## AS2 — Advantage+ Audience — Homeowner 35-65

Ad-set name: `AS2 — Advantage+ — Homeowner 35-65`

---

### Ad 1 — Problem/Solution (CONTROL — identical copy to AS1 Ad 1)

**Variant ID:** `m-as2-v1-problem`
**Ad name:** `AS2 — Problem Solution — v1 — problem`
**Angle:** Problem/Solution
**Purpose:** Scientific control. Identical copy + creative to `m-as1-v1-problem`. The only variable changing between AS1 Ad 1 and AS2 Ad 1 is the audience. This lets us attribute performance differences to Manual Core vs Advantage+, not to copy.

**Primary text (107 chars — IDENTICAL to AS1 Ad 1):**

> Tired of deck contractors who never call back? One form. One vetted local builder. Real quote in 48 hours.

**Headline (29 chars — IDENTICAL to AS1 Ad 1):**

> One form. Real local builder.

**Description (28 chars — IDENTICAL to AS1 Ad 1):**

> 48-hour quote. No phone tag.

**CTA button:** Get Quote

**Destination URL (UTM differs so we can attribute to AS2):**

```
https://www.cwdeckbuilders.com/get-a-quote?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=m-as2-v1-problem
```

**Creative spec hand-off note to Wave 3:**
USE THE EXACT SAME IMAGE as `m-as1-v1-problem`. This is a control — if visuals diverge, the test is compromised. Re-use the rendered asset; do not produce a second version.

---

### Ad 2 — Seasonal Urgency

**Variant ID:** `m-as2-v2-urgency`
**Ad name:** `AS2 — Seasonal Urgency — v1 — urgency`
**Angle:** Seasonal Urgency (hook #3)

**Primary text (111 chars):**

> Wisconsin summer is short. The good deck builders book up by May. Free quote from a local builder in 48 hours.

**Headline (24 chars):**

> Book before May fills up.

**Description (27 chars):**

> Lock your summer deck build.

**CTA button:** Get Quote

**Destination URL:**

```
https://www.cwdeckbuilders.com/get-a-quote?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=m-as2-v2-urgency
```

**Creative spec hand-off note to Wave 3:**
Evokes honest time-pressure without being salesy. Imagery direction: a finished Central WI deck with late-spring context — early green trees, patio furniture just out for the season, blue sky. Or a builder crew shot in action (tool belt, measuring, composite boards in progress) on a clear spring day. The feeling is "the build window is real and it's open right now." Avoid visual tropes of urgency (red countdown timers, "LIMITED TIME" stamps). Let the seasonal light do the work.

---

## Hook → Ad Mapping Summary

| Variant ID | Ad Set | Angle | Hook summary | Headline | CTA |
|---|---|---|---|---|---|
| `m-as1-v1-problem` | AS1 — Manual Core | Problem/Solution | Tired of deck contractors who never call back? | One form. Real local builder. | Get Quote |
| `m-as1-v2-process` | AS1 — Manual Core | Process Proof | Licensed. Insured. Local. 48 hours, not 48 days. | 48 hours, not 48 days. | Get Quote |
| `m-as2-v1-problem` | AS2 — Advantage+ | Problem/Solution (CONTROL) | Same copy as AS1 v1 | One form. Real local builder. | Get Quote |
| `m-as2-v2-urgency` | AS2 — Advantage+ | Seasonal Urgency | WI summer is short. Book by May. | Book before May fills up. | Get Quote |

---

## Creative Brief Hand-Off (Wave 3)

Consolidated notes per ad for the ad-campaign agent building the final visual assets. Aspect ratios: 1080×1080 square (primary — Feed) + 1080×1350 portrait (Reels/Stories). Skip pure 1080×1920 per Wave 1 §3.

**`m-as1-v1-problem` (and identical `m-as2-v1-problem`):** emotion = relief tinged with recognition. Imagery = homeowner in a natural kitchen/home environment, phone visible, missed-call or unanswered-text context. Realistic, mid-40s, not a stock photo. Warm natural light. No text overlay. Hands visible (implies action/agency when they click the ad).

**`m-as1-v2-process`:** emotion = trust, craftsmanship, certainty. Imagery = a finished Central WI deck, clean lines, golden hour, visible detail work (railing joint, board transition). Pull from Gallery CMS. No people. No text overlay.

**`m-as2-v2-urgency`:** emotion = honest seasonal timing. Imagery = spring-in-Wisconsin feeling. Either a finished deck with early-season context (just-green trees, patio furniture returning) OR a build-in-progress shot with a Wisconsin-sky backdrop. Avoid red/yellow urgency tropes. Let light + season do the work.

---

## Pre-Launch Paste Checklist (for Jim)

1. Create campaign `CWDB — Leads — Launch 2026-04`. Objective = Leads. Performance goal = Maximize number of conversions. Conversion location = Website.
2. Create Ad Set 1: `AS1 — Manual Core — Homeowner 35-65`. Paste audience (geo, age, interests, behaviors, exclusions) per §AS1 reference. Set ad-set budget = `$10/day`. Placements = Advantage+ Placements. Optimization event = Lead. Attribution = 7-day click + 1-day view.
3. Create Ad Set 2: `AS2 — Advantage+ — Homeowner 35-65`. Audience = Advantage+ with geo + age hard constraints, exclude Renters. Set ad-set budget = `$10/day`. Same placements + optimization + attribution.
4. In AS1, create Ad 1 (`m-as1-v1-problem`): paste Primary, Headline, Description, CTA button = Get Quote, Destination URL with UTM.
5. In AS1, create Ad 2 (`m-as1-v2-process`): paste Primary, Headline, Description, CTA = Get Quote, Destination URL.
6. In AS2, create Ad 1 (`m-as2-v1-problem`): paste IDENTICAL Primary/Headline/Description as AS1 Ad 1. Destination URL uses `m-as2-v1-problem` UTM content (only diff).
7. In AS2, create Ad 2 (`m-as2-v2-urgency`): paste Primary, Headline, Description, CTA = Get Quote, Destination URL.
8. Upload creative assets from Wave 3 output: same image for both Problem/Solution ads (v1-problem pair), unique image for Process Proof, unique image for Seasonal Urgency. 1080×1080 + 1080×1350.
9. Confirm Meta Pixel Lead event is selected as the optimization event (not a page view, not a custom event).
10. Leave campaign PAUSED.
11. Submit one test lead on `https://www.cwdeckbuilders.com/get-a-quote` with a new browser and a UTM-tagged URL. Confirm Pixel Lead event fires in Meta Events Manager and the UTMs flow into GA4.
12. Un-pause campaign only after step 11 passes.

---

## Self-Audit (voice, char limits, forbidden words)

- Primary text ≤125 chars visible cap: AS1 Ad 1 = 107, AS1 Ad 2 = 106, AS2 Ad 1 = 107 (control), AS2 Ad 2 = 111. All inside the 100–120 target band.
- Headline ≤40 chars: longest = 29 ("One form. Real local builder."). Verified.
- Description ≤30 chars: longest = 28 ("48-hour quote. No phone tag."). Verified.
- "48-hour" used; "24-hour" never used.
- Forbidden words check (bespoke / investment / transform / oasis / professional): NONE present. "Licensed local builder" and "vetted local builder" are the substitutes for "professional."
- "Instant Form" / "Lead Form" references: NONE — all ads route to `/get-a-quote` via Website Conversion.
- CTA = "Get Quote" on all 4 ads.
- Every URL carries exact Wave 1 §7 variant ID in `utm_content`.
- 5th-grade reading grade: all copy uses short words, short sentences (avg 6–8 words). Hemingway-check passes.
- Hammer voice confirmed: problem-led for angle 1, proof-led for angle 2, time-led for angle 3.
- Control variable preserved: AS1 Ad 1 and AS2 Ad 1 share identical Primary + Headline + Description + visual asset.
