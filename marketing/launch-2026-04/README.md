---
type: launch-package-index
status: ready-for-deployment
created: 2026-04-21
owner: cwdb-ceo-operator
launch_window: 2026-04-21 onward
platforms: Google Search, Meta (Facebook + Instagram)
daily_budget: $50 ($30 Google + $20 Meta)
---

# CWDB Ad Launch — 2026-04

**Status:** READY FOR DEPLOYMENT
**One file to open first:** [`DEPLOY.md`](./DEPLOY.md) — follow steps in order, est. 60–90 min.

---

## What This Package Is

A complete, paste-ready ad campaign bundle produced through a 4-agent orchestration (revenue-optimization → content-writer → ad-campaign → CEO). Every file in this folder is final and internally consistent. No improvisation should be needed during deployment — if something feels missing, stop and check.

**Supersedes:** `/marketing/google-ads/*` and `/marketing/facebook-ads/*` (v1 baselines). Those files remain in git as a fallback.

---

## File Tree

```
marketing/launch-2026-04/
├── README.md                        ← you are here
├── DEPLOY.md                        ← master deployment checklist (Jim's entry point)
├── 01-strategy.md                   ← campaign architecture, bid strategy, unit economics
├── 02-hook-matrix.md                ← 10+ angles scored, 3 winners locked
├── 03-google-copy.md                ← Google Ads paste-ready (headlines, keywords, extensions)
├── 04-meta-copy.md                  ← Meta paste-ready (4 ads, primary/headline/desc/CTA)
├── 05-hook-audit.md                 ← creative audit (11/11 PASS)
└── creatives/
    ├── meta/                        ← 6 PNGs + HTML + notes (GO LIVE on Day 1)
    │   ├── problem-solution-1080x1080.{html,png,-notes.md}
    │   ├── problem-solution-1080x1350.{html,png,-notes.md}
    │   ├── process-proof-1080x1080.{html,png,-notes.md}
    │   ├── process-proof-1080x1350.{html,png,-notes.md}
    │   ├── seasonal-urgency-1080x1080.{html,png,-notes.md}
    │   └── seasonal-urgency-1080x1350.{html,png,-notes.md}
    └── google-display/              ← 3 banner PNGs + 2 logo PNGs (STANDBY — Week 4+)
        ├── landscape-1200x628.{html,png,-notes.md}
        ├── square-1200x1200.{html,png,-notes.md}
        ├── portrait-960x1200.{html,png,-notes.md}
        ├── logo-square-1200x1200.{html,png}
        ├── logo-horizontal-1200x300.{html,png}
        └── README.md
```

---

## Campaign at a Glance

| Dimension | Setting |
|---|---|
| Budget | $50/day ($30 Google + $20 Meta) → ~$1,500/month |
| Geo | Wausau WI + 20-mi radius (ZIPs 54401, 54403, 54474, 54476, 54455, 54452) |
| Target avatar | Stressed Delegator homeowner, 35–65 |
| Speed promise | Quote in 48 hours |
| Primary LP | `https://www.cwdeckbuilders.com/get-a-quote` |
| Conversion event | `form_submit_quote` on `/thank-you` |
| Target CPL | <$60 combined (Google $40–60, Meta $30–50) |
| Kill floor CPL | $100 combined (auto-pause) |

### Google Search

- 1 campaign · 2 ad groups (Decision-stage, Comparison-stage)
- Manual CPC Week 1–3; promote to Max Conversions at Week 4 if 15+ conversions
- 15 headlines + 4 descriptions per ad group · 31 keywords total · 34+ negatives
- Call extension: `(715) 544-7941` Mon–Fri 9am–5pm Central

### Meta (Facebook + Instagram)

- 1 campaign · 2 ad sets (Manual Core audience vs Advantage+ Audience)
- **Website Conversion objective** (NOT Instant Form — preserves GTM attribution stack)
- 4 ads total (AS1 × 2, AS2 × 2) — scientific control: Problem/Solution copy shared across both ad sets
- 3 unique creatives (Problem/Solution, Process Proof, Seasonal Urgency) × 2 aspect ratios each = 6 PNG assets

---

## Three Angles (why these, why not more)

1. **Problem/Solution** — "Tired of deck contractors who never call back?" — names the Stressed Delegator's exact pain.
2. **Process Proof** — "Licensed. Insured. Local. 48 hours, not 48 days." — trust via specificity, not puffery.
3. **Seasonal Urgency** — "Wisconsin summer is short. Book before May fills up." — honest scarcity, not manufactured.

**Social Proof is deferred**, not forgotten. We have 0 reviews/testimonials/case studies at launch; running that angle would be structurally dishonest. Social Proof re-enters the rotation once 5+ customer reviews are banked (target: ~Week 6).

Full reasoning: `02-hook-matrix.md`.

---

## Unit Economics (quick math)

- $1,500/month spend ÷ $50 CPL = 30 leads/month
- 30 leads × 20% contractor close rate = 6 accepted bids/month
- 6 × $1,000 revenue per bid = $6,000/month
- Margin = $6,000 − $1,500 = **$4,500/month** (LTGP:CAC = 4:1)

Clears Hormozi's 3:1 payback threshold with room. Phase 2 revenue target ($3K–$10K/mo) lands at the floor — scaling to $100/day once unit economics prove will hit the target cleanly.

Breakeven CPL = $200. Pause line = $100. Target = $50.

Full sensitivity table: `01-strategy.md` §8.

---

## Pre-Launch Gates (all GREEN to proceed)

- [x] Production site live (`www.cwdeckbuilders.com` verified 2026-04-21)
- [x] Form → email delivery verified
- [x] GTM/GA4/Meta Pixel/Google Ads conversion tags live (Phase F, 2026-04-18)
- [x] 3 locked angles confirmed by Jim (Social Proof deferred)
- [x] Call extension enabled for Mon–Fri 9am–5pm only
- [x] Hook audit passed 11/11 creatives
- [ ] Test lead through verification lap (§4 in DEPLOY.md) — Jim runs this just before un-pausing

---

## What Happens After Deployment

- **Days 1–7:** Data collection, no decisions. Daily 5-min ops check (rejections, pacing, leads).
- **Day 7:** First individual-ad kill decisions (any ad at >$140 spend, 0 conversions).
- **Day 14:** Full kill criteria — pause channels that breach CPL ceilings.
- **Week 3:** First variant refresh (Google RSA asset rotation, Meta angle swap if needed).
- **Week 4:** Scale decision (to $100/day if CPL <$60 and first accepted bid banked) + retargeting activation.

---

## Questions the Package Assumes You Already Have Answers To

These were answered during the orchestration; listed here so the assumptions are visible:

- Q: Should we run Instant Form for higher volume? **A:** Not at launch. Website Conversion preserves full GTM stack attribution. Revisit Week 2 only if Meta CPL >$60.
- Q: Should we target beyond 20-mi radius? **A:** No. Lead quality degrades fast outside the contractor service area.
- Q: Should we run Social Proof copy? **A:** No. We don't have the proof yet. Process Proof replaces it.
- Q: Should we call extend enable 24/7? **A:** No. Google Voice answer-window is Mon–Fri 9am–5pm. Unanswered calls are conversion leaks.

---

## What To Do Next

1. Open [`DEPLOY.md`](./DEPLOY.md).
2. Work through §0 Pre-Flight.
3. Proceed through §2 Google Ads setup → §3 Meta Ads setup → §4 Verification Lap → §5 Go-Live.

If you get stuck, every paste-block in DEPLOY.md cites the file and section where the full content + rationale lives.
