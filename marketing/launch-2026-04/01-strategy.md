---
type: strategy
status: draft
created: 2026-04-21
owner: revenue-optimization
wave: 1 of 4
supersedes_v1: /marketing/google-ads/* and /marketing/facebook-ads/*
downstream_consumers:
  - content-writer (Wave 2)
  - ad-campaign (Wave 3)
  - ceo-operator (Wave 4)
tags:
  - type/strategy
  - dept/marketing
  - phase-1
  - launch/2026-04
---

# CWDB Ad Launch v2 — Master Strategy

Budget: $50/day ($30 Google Search + $20 Meta) · Launch: 2026-04-21 · Geo: Wausau + 20-mi radius.

This document answers the 8 architectural questions for the v2 raise-the-bar rebuild. No ad copy, no creative specs, no click-paths — those are Waves 2/3/4. Every number below has a rationale; if a downstream agent wants to deviate, they need to contradict the rationale, not ignore it.

---

## 0. Framing — What "v2" Is Solving That v1 Wasn't

The v1 files (`/marketing/google-ads/`, `/marketing/facebook-ads/`) are competent but optimized for a market with prior conversion data and a mature offer/proof stack. We have neither. Three cold-start realities drive v2:

1. **Zero conversion history** — Google's Maximize Conversions and Meta's Conversion Leads optimization both need ~15–30 conversion events before the algorithm converges. At our expected volume (~1 lead/day), that's 2–4 weeks of data collection before smart bidding is stable. v1 assumed we could flip to Max Conversions in Week 3; that's optimistic.
2. **Lever 1 volume floor breach** — Hormozi's Rule of 100 says $100/day is the minimum to absorb statistical noise across two channels. We're at $50/day. We MUST design for slow, boring, patience-driven optimization and resist the urge to make Week 1 decisions.
3. **Lever 3 proof gap** — We have 0 testimonials, 0 reviews, 0 case studies, 0 completed CWDB jobs. v1's "Social Proof" angle ("Hundreds of Wausau homeowners got their dream deck this year...") is a structural lie at launch — we have no customers yet. v2 swaps the emphasis toward *process proof* (licensed, insured, local, 48-hour response) and defers outcome-proof angles until we bank reviews.

The rest of this doc assumes these three facts.

---

## 1. Google Ads Campaign Structure

### Recommendation
**1 campaign, 2 ad groups, phrase match dominant, Manual CPC bidding for Weeks 1–3.**

### Campaign count: 1

At $30/day, campaign-level budget split only fragments the learning signal. Google Ads campaign-level learning (auction dynamics, quality score history, negative keyword harvesting) compounds. Two campaigns = half the data per campaign = slower convergence. 1 campaign is correct until we hit $100+/day.

### Ad group count: 2

Two intent tiers — matches v1 and aligns with how search demand actually splits:

| Ad group | Theme | Budget signal |
|---|---|---|
| AG1 — Decision-stage | "[deck builder] / [deck contractor] [city]" — someone searching for a provider | Higher intent, higher CPC, higher CVR |
| AG2 — Comparison-stage | "deck quote / estimate / cost [geo]" — someone shopping quotes | Lower intent, lower CPC, lower CVR but more volume |

We do NOT split a 3rd ad group for "deck repair" or "composite deck" material-type intent. At $30/day, a third bucket fragments impressions below statistical floor. Roll those terms into AG1.

### Match type per ad group

**AG1 (Decision-stage):** Phrase + Exact, no Broad. Reason: the long-tail variance on "deck builder wausau" is small, and broad match will spend our entire $30/day on tangential searches ("deck ideas wausau") before Google learns our conversion signal. With 0 conversions banked, Broad + Smart Bidding is actively harmful.

**AG2 (Comparison-stage):** Phrase only. "Exact" excludes too many valuable variants ("cost of a new deck in wausau" vs "deck cost wausau"). Phrase catches them all.

**Broad match: NO, not at launch.** Add Broad in Week 4+ if Phrase is starving for volume AND we have 10+ conversions for Google to optimize against.

### Bid strategy: Manual CPC, Week 1–3

This is the single most important cold-start decision. Options:

| Strategy | Needs conversion data? | Cold-start safe? |
|---|---|---|
| Manual CPC | No | Yes (default pick) |
| Maximize Clicks | No | Yes, but spends faster, lower quality |
| Maximize Conversions | Yes (~15–30 events) | **No** — will burn budget on bad auctions |
| Target CPA | Yes (30+ events) | No |

**Pick Manual CPC with a max bid of $3.50.** Defended math:
- Industry CPC for "deck builder [city]" in tier-2 US markets: $2.50–$5.00.
- At $3.50 cap and ~15% CTR on phrase match, $30/day = ~15 clicks/day = ~450 clicks/month.
- At a 3–5% LP conversion rate (reasonable for a 3-step form with pre-fill), that's 14–22 leads/month — enough volume to start seeing a signal by Week 2.

**Promotion path:**
- Week 3 checkpoint: if we have 15+ conversions, switch to **Maximize Conversions** (no tCPA yet — gives Google room to spend on learning).
- Week 6 checkpoint: if 30+ conversions, add **Target CPA = $50** as a ceiling.

### Day-parting / ad schedule

- **Week 1–2:** All-hours (Mon–Sun, 24/7). Reason: we don't know when Central WI homeowners search. Let the data decide.
- **Week 3 checkpoint:** pull the hour-of-day report. Most likely pattern for home-services B2C: 6pm–10pm weekdays + Sat/Sun 8am–2pm. Apply +20% bid modifiers to top windows, -30% to overnight (12am–6am) if they show noise with no conversions.

### Network settings

- **Search Partners: OFF.** Historically degrades lead quality for local services; worth adding back in Week 6+ if core Search is saturated.
- **Display Network expansion: OFF.** Display in a Search campaign is a classic budget leak. If we want display, it gets its own campaign later.

---

## 2. Meta (Facebook + Instagram) Campaign Structure

### Recommendation
**1 campaign · 2 ad sets · Website Conversion objective (NOT Instant Form) · Advantage+ Placements · Ad-Set-level budget.**

### Objective: Website Conversion, drive to `/get-a-quote`

This is the highest-leverage call in this section. Trade-off:

| Objective | CPL (expected) | Lead quality | Attribution quality |
|---|---|---|---|
| Instant Form (Lead Ad) | Lower ($25–$40) | Lower — pre-fills hide intent | Limited — lives inside Meta |
| Website Conversion | Higher ($40–$60) | Higher — user self-selects by clicking through + filling our form | High — hits full GTM stack, GA4, Google Ads conversion, Clarity |

**Pick Website Conversion because:**
1. The v1 brief specifies Instant Form, citing "~2x better conversion." That's true in aggregate but misleading for us. Our entire measurement stack (GTM → GA4 + Google Ads Conversion + Clarity) fires on `/thank-you`. An Instant Form lead never hits that stack — which means we can't cross-attribute to Google, we can't see LP drop-off in Clarity, and we can't build lookalikes off of high-intent site behavior.
2. Our Lever 4 offer ("Free quote in 48 hours from licensed local builder") is strong enough that the click-through filter is a *feature*, not a *cost*. We want the homeowner who cares enough to fill a real form.
3. The site wizard IS our qualification step. Pulling leads out of it undermines lead-qualification-agent's schema.
4. Instant Form leads require daily manual CSV export + HubSpot entry until Make is reactivated. Website conversions hit HubSpot via the Webflow form submission directly (pending verification).

**Risk:** Website Conversion CPL will be 40–60% higher than Instant Form CPL. If we blow past the $50 Meta CPL ceiling in Week 1, this is the first thing to revisit in Week 2. Reopen Instant Form as a second ad set if cold-start CPL sits >$60.

### Ad set count: 2

| Ad set | Audience | Purpose |
|---|---|---|
| AS1 — Manual Core | Layered interest + behavior stack (v1 spec) | Baseline — known-audience control |
| AS2 — Advantage+ Audience | Meta-optimized, minimal manual constraint beyond geo + age | Test — does Meta's algo beat human targeting? |

Rationale for running both from Day 1 despite $20/day being tight: Advantage+ Audience is Meta's recommended default for low-budget accounts precisely BECAUSE it converges faster than manual targeting when conversion data is sparse. But we don't trust it blindly on a new pixel — running Manual alongside gives us a benchmark. Kill one in Week 2 based on CPL.

### Audience structure

**AS1 (Manual Core):** Carry over v1 targeting.
- Geo: Wausau + 20-mi radius (5 ZIPs)
- Age: 35–65
- Layer 1 (OR): Home improvement, Home & garden, Patio, Backyard, Outdoor living, HGTV, Home Depot, Lowe's
- Layer 2 (AND via NARROW): Engaged Shoppers OR Likely Movers
- Exclusions: Renters, under 25

**AS2 (Advantage+ Audience):**
- Geo: same 5 ZIPs + 20-mi radius (hard constraint)
- Age: 35–65 (hard constraint)
- Detailed targeting suggestions: OFF (full Advantage+)
- Exclusions: Renters only

### Placements: Advantage+ Placements (automatic)

At $20/day across 2 ad sets (= $10/day each), manual placement selection starves individual placements of impressions and slows learning. Advantage+ lets Meta pool across Feed, Reels, Stories, Marketplace. Week 2 review: if one placement is eating >40% of spend with bad CPL, exclude it. Not before.

### Budget: Ad-Set-level ($10/day each), NOT CBO

Why ad-set budget over Campaign Budget Optimization at this spend level:
- CBO needs conversion signal to optimize the split. We have none.
- CBO at $20/day will frequently shift 80%+ of budget to whichever ad set catches an early lucky conversion — which is statistical noise, not signal.
- Ad-set budget locks $10/day per ad set, guaranteeing both audiences get comparable learning impressions. After Week 2, if one ad set is clearly winning on CPL with statistical confidence (40+ impressions minimum, not 4), consolidate to CBO.

### Optimization event: Lead (Pixel)

Standard. Pixel Lead event is confirmed firing (Phase F). Attribution window: 7-day click + 1-day view (default; do not change).

---

## 3. Variant Math (Exact Counts)

### Statistical reality check

At ~$50 CPL combined, $50/day = **~1 lead/day total, split ~0.6 Google + 0.4 Meta**. Over a 14-day test window, that's:
- Google: ~8–10 leads total
- Meta: ~5–7 leads total

**Leads per variant needed for statistical confidence:** ~10 conversions minimum to distinguish signal from noise at 95% confidence. That means:
- Google RSA: 1 ad group can statistically evaluate 1 ad (2 max) in 14 days.
- Meta: 1 ad set can statistically evaluate 1–2 ads in 14 days.

**The implication:** we are NOT A/B testing in Week 1–2. We're collecting baseline. Over-variation is actively harmful — it guarantees no single variant hits its learning floor.

### Google RSA: 1 RSA per ad group, loaded with 15 headlines + 4 descriptions

RSA format requires 3–15 headlines and 2–4 descriptions. Google's own algorithm rotates them for us — this is asset-level testing, not ad-level testing. Load the max:

| Asset | Count | Pinned? |
|---|---|---|
| Headlines | 15 | Headline 1 pinned to Position 1 (brand: "Wausau Deck Builders" or "Central WI Deck Builders") |
| Descriptions | 4 | None pinned |
| Final URL | 1 | `/get-a-quote` |
| Display paths | 2 | `/deck-quote`, `/wausau-decks` |

Wave 2 (content-writer) produces the 15 headlines + 4 descriptions per ad group. **AG1 and AG2 get different RSAs — the copy angles differ by intent stage (decision vs comparison).**

### Meta: 2 ads per ad set (not 3, not 4, not 9)

v1 spec calls for 9 ads (3 angles × 3 variants). That's wrong for our budget. At $10/day/ad set across 9 ads = $1.10/day/ad = no ad hits its learning floor in 2 weeks.

**v2 spec: 2 ads per ad set × 2 ad sets = 4 ads total.**

| Ad set | Ad 1 angle | Ad 2 angle |
|---|---|---|
| AS1 (Manual Core) | Problem/Solution (safest given proof gap) | Process Proof (licensed/insured/local/48hr) |
| AS2 (Advantage+) | Same Problem/Solution copy (control variable) | Seasonal Urgency (WI building season) |

Note: v1's "Social Proof" angle is demoted/deferred — we don't have the social proof to make it honest. Wave 2 will rewrite if they disagree, but flag the proof gap.

### Creative aspect ratios

**2 per ad:** 1080×1080 (square, primary — Feed) + 1080×1350 (portrait — Reels/Stories). Skip 1080×1920 pure Story format — it's now a subset of the 1350 tall treatment in Advantage+ Placements.

### Hook archetypes to test (pointer for Wave 2)

Per Hormozi Lever 5, 6 archetypes exist. We'll only test 3 at launch given volume:
1. **Problem-Solution** (ghosted-by-contractors angle — proven empathetic pain point)
2. **Specificity** (48-hour · 5 cities · licensed — concrete, trust-building)
3. **Seasonal Urgency** (WI short season — real, not manufactured scarcity)

Deferred to Week 3+: Social-Proof, Curiosity, Outcome (need reviews/photos/case studies first).

---

## 4. Spend Allocation Within Each Platform

| Channel | Daily | Split | Rationale |
|---|---|---|---|
| Google — AG1 (Decision) | $30 shared | Shared budget, Google auction allocates | Phrase/Exact means bid cap is the real lever, not budget split. Google will naturally spend more on AG1 because intent keywords have higher Quality Score and auction frequency. |
| Google — AG2 (Comparison) | (shared) | — | — |
| Meta — AS1 (Manual) | $10/day | 50% | Even split |
| Meta — AS2 (Advantage+) | $10/day | 50% | Even split |

**Google shared budget, not per-ad-group budget:** Google Ads doesn't support true ad-group-level budgeting anyway (budget is campaign-level). So this is inherent, but worth stating explicitly. Control per-ad-group spend via **bid caps**: AG1 max CPC $3.50, AG2 max CPC $2.50 (lower-intent gets lower bid).

**Meta even split, not CBO:** Already defended in §2. Locked at ad-set level, revisit Week 2.

---

## 5. Testing Plan (Day-By-Day)

### Launch-week discipline

Principle 1: **No decisions before Day 7.** Week 1 is data collection. The Rule of 100 is in full effect — a 2-lead swing in either direction is pure noise at $50/day.

Principle 2: **Kill criteria from the launch brief are hard floors, not goals.** Do not tighten them mid-week. Do not loosen them either.

### Day-by-day gate structure

| Window | What to watch | Decision gate |
|---|---|---|
| Day 1–3 | Impressions firing, clicks flowing, conversion pixel firing on test lead, no rejected ads | If Day 3 has $0 spent → ad disapproval or bid too low. Fix immediately. No performance decisions. |
| Day 4–7 | CPL directional only, CTR per ad, search terms report (Google), placement breakdown (Meta) | **Day 7 gate:** any ad at >$140 spend with 0 conversions = pause that ad (per brief). Do NOT pause entire ad sets/groups yet. |
| Day 8–14 | CPL converging, lead volume stabilizing, first full 7-day conversion cohort visible | **Day 14 gate:** apply full launch-brief kill criteria (Google CPL >$80, Meta CPL >$50, combined >$100 = pause channel). |
| Day 15–21 | Winning variants emerging | **Promote-a-winner:** any ad with CPL < target AND 10+ conversions. Scale to 60% of ad-set budget. |
| Day 22–30 | Scaling decision | If combined CPL <$60 AND 1+ accepted contractor bid banked → scale to $100/day. If no accepted bid yet, hold $50/day and investigate contractor-side funnel per brief revenue gate. |

### Promote-a-winner criteria (explicit thresholds)

An ad earns "scale" status when ALL are true:
- CPL ≤ $50 (Meta) or ≤ $60 (Google)
- CTR ≥ 1.5% (Google) or ≥ 1.0% (Meta)
- 10+ conversions in trailing 14 days
- Quality Score ≥ 6 (Google) or Quality Ranking "Above Average" (Meta)

### Kill-a-loser criteria (respecting launch brief)

Pause individual ad when:
- >$140 spend with 0 conversions (Meta), >$200 (Google)
- OR CTR <0.5% after 500 impressions (Meta) or <1.5% after 500 impressions (Google)
- OR Quality Score ≤ 3 (Google) after 1,000 impressions

Pause entire ad group / ad set when:
- Cumulative >$250 with 0 conversions
- OR combined CPL breaches brief thresholds

Pause entire channel when:
- Brief Day-7 or Day-14 thresholds breached AND 14-day trailing window confirms it's not single-day noise.

### Week-by-week testing focus

| Week | Test focus |
|---|---|
| 1 | Baseline — nothing tested. Data collection. |
| 2 | Verify learning — conversion pixel stable, CPL trending. No new variants. |
| 3 | First variant refresh — swap Meta losers (if any) for new angle from Wave 2's backup copy. First Google RSA asset rotation (swap weakest 3 headlines). |
| 4 | Scale winners if Week 3 gates cleared. Begin retargeting setup (site visitors, 30-day window). Begin custom audience upload (existing CRM contacts from HubSpot for exclusion + future lookalike). |

---

## 6. Audience Layers

### Meta: Core Four mapping

Meta's "Core Four" (Meta's own framework, distinct from Hormozi's) = Interests, Behaviors, Demographics, Life Events. Our stack:

**Interests (Layer 1, OR logic):**
1. Home improvement (broad — highest priority)
2. Home & garden
3. Patio
4. Backyard
5. Outdoor living
6. Landscaping
7. HGTV
8. The Home Depot
9. Lowe's
10. DIY (include despite the word "DIY" — homeowners shopping for pros also follow DIY content)

**Behaviors (Layer 2, AND via NARROW):**
1. Engaged Shoppers (primary — directional buying intent)
2. Likely Movers (secondary — recent home purchase = high deck-upgrade probability)

Exclude: **Small business owners** (not homeowner-mindset even if they own a house), **Business decision-makers** (corporate-procurement bias).

**Demographics:**
- Age: 35–65 (as constrained)
- Home ownership: Homeowners (Demographics → Home Type → Homeowners)
- Household income: Top 50% in area (tier-2 market; avoids bottom-income waste without narrowing too much)

**Life Events (Layer 3 — OPTIONAL, add only if audience too large):**
- Recently moved
- Newly engaged (1-year window — often drives "ready the backyard" renovations)
- New job (income bump triggers)

**Exclusions:**
- Renters
- Under 25
- Employees of 3 biggest WI deck competitors (if identifiable by company name on Meta — best effort, data is sparse)
- Existing CRM contacts (upload from HubSpot as Custom Audience — exclude from cold targeting) — deferred until Week 2 when we have list size >50.

**Lookalikes:** DEFERRED until 50+ conversions banked (per brief). At $50/day, 50 conversions ≈ Day 50. Don't touch until then.

### Google: Negative keyword expansion

v1 seed list (13 negatives): diy, kit, rental, job, jobs, hiring, career, used, photos, ideas, plans, pdf, blueprint. Good foundation.

**v2 additions (20+ more, add campaign-level on Day 1):**

| Category | Negatives |
|---|---|
| DIY/guide intent | how to, tutorial, youtube, video, instructions, step by step, guide |
| Career/job | resume, apply, position, contractor jobs, carpenter jobs, helper wanted |
| Material-only shoppers | boards only, lumber, material cost, where to buy, menards lumber, 2x6, joists |
| Free/budget (waste) | free estimate pdf, cheap, cheapest, under $1000, budget |
| Wrong service | roof, fence, patio paver, concrete slab, pool deck (pool — different trade), boat deck, ship deck |
| Informational/educational | definition, meaning, what is, history of, architecture |
| Salvage/used | used wood, salvage, reclaimed (ambiguous — re-evaluate after Week 2; high-end clients also search "reclaimed") |
| Regulatory/permit | permit only, permit cost only, inspection only, code violation |
| Competitor brand names | (add as we identify them in search terms report — Week 2) |

**Plus ongoing:** harvest from search terms report weekly. Add any term with 0 conversions + $10 spend as negative.

### Location exclusions (Google)

- Hard exclude: anything outside 20-mi radius of Wausau center.
- Presence setting: "People IN or regularly in" — NOT "interested in." This is critical for local services. "Interested in" catches people Googling "Wausau decks" from Chicago planning a vacation home — total waste.

### Audience exclusions (Google)

- **Customer match list:** upload HubSpot contact list as Customer Match audience. Apply as EXCLUSION to all campaigns. Prevents re-acquiring existing contractor leads via paid search. (Deferred to Week 2 — list too small Day 1.)
- **Retargeting setup note:** create Remarketing audience (site visitors, 30-day) for Week 4 activation. Set up the list now so the cookie window starts collecting; activate targeting later.

---

## 7. UTM Taxonomy

### Pattern (both channels)

```
?utm_source={google|meta}
&utm_medium=cpc
&utm_campaign=launch-2026-04
&utm_content={variant_id}
&utm_term={keyword}   // Google only; Meta uses {variant_id} in utm_content
```

### Variant ID schema

**Google:** `g-{adgroup}-{ad_format}{n}-{angle}`
- `adgroup`: `ag1` (decision) or `ag2` (comparison)
- `ad_format`: `rsa` (responsive search ad)
- `n`: sequential number within ad group
- `angle`: short slug for primary hook (e.g., `speed`, `local`, `licensed`)

Examples:
- `g-ag1-rsa1-local` → AG1, RSA #1, local-builders angle
- `g-ag2-rsa1-quote` → AG2, RSA #1, quote-comparison angle

**Meta:** `m-{adset}-v{n}-{angle}`
- `adset`: `as1` (manual core) or `as2` (advantage-plus)
- `n`: sequential variant number
- `angle`: short slug (`problem`, `process`, `urgency`, `speed`)

Examples:
- `m-as1-v1-problem` → AS1, variant 1, problem-solution angle
- `m-as2-v2-urgency` → AS2, variant 2, seasonal urgency angle

### Ad-group / ad-set naming (UI-level, not UTM)

| Platform | Object | Name |
|---|---|---|
| Google | Campaign | `CWDB — Search — Launch 2026-04` |
| Google | Ad Group 1 | `AG1 — Decision — Builder/Contractor Intent` |
| Google | Ad Group 2 | `AG2 — Comparison — Quote/Estimate/Cost` |
| Meta | Campaign | `CWDB — Leads — Launch 2026-04` |
| Meta | Ad Set 1 | `AS1 — Manual Core — Homeowner 35-65` |
| Meta | Ad Set 2 | `AS2 — Advantage+ — Homeowner 35-65` |
| Meta | Ad 1 in AS1 | `AS1 — Problem Solution — v1 — problem` |
| Meta | Ad 2 in AS1 | `AS1 — Process Proof — v1 — process` |

Wave 3 (ad-campaign agent) builds with these exact names.

### Full resolved URL examples

Google (AG1, decision-stage, kw = "deck builder wausau"):
```
https://www.cwdeckbuilders.com/get-a-quote?utm_source=google&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=g-ag1-rsa1-local&utm_term=deck+builder+wausau
```

Meta (AS2, urgency variant):
```
https://www.cwdeckbuilders.com/get-a-quote?utm_source=meta&utm_medium=cpc&utm_campaign=launch-2026-04&utm_content=m-as2-v2-urgency
```

GA4 already captures all UTM params (verified Phase F). No setup change needed.

---

## 8. Unit-Economics Projection

### Baseline projection at $50 CPL blended

| Metric | Value |
|---|---|
| Monthly spend | $1,500 |
| Blended CPL (target) | $50 |
| Leads/month | 30 |
| Close rate (brief assumption) | 20% |
| Accepted bids/month | 6 |
| Revenue per bid | $1,000 |
| Revenue/month | $6,000 |
| Gross margin ($1,500 ad spend vs $6,000 revenue) | $4,500 |
| 30-day revenue gate cleared? | YES (gate: >0 accepted bid at $1,500 spent) |
| LTGP:CAC ratio | 4:1 (at 20% close rate, CAC per accepted bid = $250; LTGP = $1,000) |

**This clears Hormozi's 3:1 payback threshold (actually 4:1) with room to spare — IF CPL holds at $50.**

### Sensitivity table

| Blended CPL | Leads/mo | Accepted bids/mo (20% close) | Revenue/mo | CAC per bid | LTGP:CAC | Verdict |
|---|---|---|---|---|---|---|
| $30 | 50 | 10 | $10,000 | $150 | 6.7:1 | Scale aggressively |
| $50 | 30 | 6 | $6,000 | $250 | 4:1 | **Target — healthy** |
| $66 | 23 | 4.5 | $4,500 | $333 | 3:1 | Margin-of-safety floor |
| $80 | 19 | 3.8 | $3,750 | $400 | 2.5:1 | Below brief kill line — pause channel |
| $100 | 15 | 3 | $3,000 | $500 | 2:1 | Pause spend, diagnose funnel |
| $200 | 7.5 | 1.5 | $1,500 | $1,000 | 1:1 | Breakeven — HALT |

### Key thresholds

- **Breakeven CPL (given 20% close rate, $1,000 per bid):** CPA = CPL × 5. Breakeven at CPA = $1,000 → CPL = $200.
- **3:1 payback floor CPL:** CPA = $333 → CPL = **$66**.
- **Brief target CPL:** <$60 (inside 3:1 margin of safety with buffer).
- **Halt CPL:** >$100 combined after 14 days of spend.

### Close-rate sensitivity

All above assumes 20% contractor close rate (homeowner accepts contractor's bid). If actual close rate diverges:

| Actual close rate | CPL for 3:1 payback |
|---|---|
| 10% | $33 |
| 15% | $50 |
| 20% (assumption) | $66 |
| 25% | $83 |
| 30% | $100 |

**We do not have close-rate data yet.** The 20% assumption is from the launch brief and CLAUDE.md. First accepted-bid data point will revise this number. Until then, $66 is the ceiling CPL.

### Volume risk

At $50/day, the 4:1 ratio produces $4,500/month margin. That's a healthy unit-economic story but **does not pass the Phase 2 revenue target** of $3K–$10K/month fully confidently — it's near the floor. Scaling to $100–$150/day once unit economics are proven is necessary to hit Phase 2 goals.

---

## Open Questions / Risks (Need Jim's Call)

1. **Proof-gap risk (Lever 3):** v1's Social Proof angle is structurally dishonest at launch (no customers yet). v2 defers it. Does Jim want Wave 2 to write it anyway as a third Meta angle, or honor the deferral?

2. **Phone answer-path gate (from brief):** Call extension enable depends on Jim confirming (715) 544-7941 is answered promptly during business hours. What's the interim answer? If no one answers, the Call extension becomes a conversion leak. Recommend DISABLED at launch, re-enable Week 2 once GV setup is verified.

3. **Instant Form escape hatch:** If Meta Website Conversion CPL sits >$60 in Week 1, the v2 recommendation is to add an Instant Form ad set in Week 2 for volume while Website Conversion continues for quality. OK with Jim?

4. **Close-rate assumption uncertainty:** Entire unit-economics model hinges on 20% contractor close rate. Zero data validates this yet. If actual close rate is 10%, breakeven CPL drops to $33 — well below realistic Google CPCs for our market. Need first accepted-bid data point in first 30 days to validate.

5. **Conversion value assignment ($200):** v1 ad-copy file has conversion value set to $200 per lead. At 20% close × $1,000 revenue, expected value is $200 — correct. But Google's smart bidding will eventually use this. Should we consider weighting conversions by completion quality (partial vs full form)? Defer to Week 4 when Google has data to act on.

6. **Wave-2/Wave-3 sequencing:** Wave 2 (content-writer) needs the Meta angle list locked before writing. v2 locked it to Problem/Solution + Process Proof + Seasonal Urgency (3 archetypes). If Wave 2 wants to push back, flag here not silently swap.

7. **Webflow form delivery verification:** Launch brief still has this as an unchecked gate. Strategy assumes it works. If it doesn't, every number in §8 is wrong (leads are generated but don't reach inbox). Blocker.

---

## Summary: What This Strategy Changes vs v1

| Area | v1 | v2 |
|---|---|---|
| Google bid strategy | Manual CPC Week 1-2, Max Conversions Week 3 | Manual CPC Week 1-3, Max Conversions Week 4 (pending conversion data floor) |
| Meta objective | Instant Form (Lead Ad) | Website Conversion → `/get-a-quote` |
| Meta ads per ad set | 9 (3 angles × 3 variants) | 2 (one proven angle + one test angle) |
| Meta ad sets | 1 | 2 (Manual Core + Advantage+ Audience) |
| Meta budget structure | single ad set $20/day | 2 ad sets × $10/day ad-set budget (no CBO) |
| Social Proof angle | Yes, featured | Deferred (proof gap honesty) |
| Negative keywords | 13 seed | 13 seed + 20 v2 additions + weekly harvest |
| UTM variant ID | `{angle}-{variant}` | `{platform}-{adgroup|adset}-{format}{n}-{angle}` |
| Day-parting | "All hours, review after data" | Same; formalized Week 3 checkpoint |
| Audience exclusions | Renters only | Renters + Customer Match list (Week 2) + Business owners |
