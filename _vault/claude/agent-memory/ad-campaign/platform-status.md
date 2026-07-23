---
type: memory
agent-id: ad-campaign
name: platform-status
description: Status of each advertising platform — accounts, creatives, launch readiness
tags:
  - type/memory
  - agent/ad-campaign
created: 2026-04-16
updated: 2026-07-05
status: active
---

# Platform Status

**Why:** Quick reference for which platforms are ready to launch and what's blocking them.

**How to apply:** Check this before any campaign work. Update as accounts are created and campaigns go live.

## Google Ads
- Account: LIVE since 2026-04-23. Customer 712-991-0870 (7129910870), MCC login 7762492754. Native conv tracking id 18113251301.
- Enabled Search campaign `CWDB Search Launch 2026-04` id 23783717705, bid = MAXIMIZE_CONVERSIONS. Paused PMax clutter `Campaign #1` id 23783582120.
- Ad copy: Written at `/marketing/google-ads/ad-copy.md`
- Keywords: `/marketing/google-ads/keywords.csv` (needs validation/pruning)
- Conversion tracking: fires via GTM-T3PB96G2. Primary = from_submit_quotes (7587819071) but SILENT since 2026-06-10 (on-site /thank-you signal break). 4 GBP local actions wrongly Primary (not API-mutable). Cleanup memo: `marketing/google-ads/2026-07-22-conversion-cleanup.md` + clicksheet. See [google-ads-conversion-graveyard](google-ads-conversion-graveyard.md).
- Budget: $30/day (peak-season, budget-limited, ~20% impression share)

## Meta (Facebook/Instagram)
- Account: LIVE. Ad account `act_1301499298740692`. Campaign "CWDB-Leads-Launch 2026-04" id `120241408537330461`, objective OUTCOME_LEADS.
- **STATUS 2026-07-05: campaign PAUSED at campaign level** (Jim-approved during business audit). Set via Meta Marketing API (`META_*` creds in `.env.local`), verified status=PAUSED / effective_status=PAUSED.
  - **Why paused:** Meta Pixel has never fired a Lead event, so OUTCOME_LEADS optimizes blind. Stays paused until the Pixel Lead event is fixed, then re-evaluate with clean data. Do not un-pause or refresh creatives until the Lead event is confirmed firing.
- Ad copy: Written at `/marketing/facebook-ads/ad-copy.md`
- Audiences: Defined at `/marketing/facebook-ads/audiences.md`
- Pixel: Installed but Lead event NOT firing (root cause of the pause).
- Budget: $20/day (per project decision 2026-04-18; $30 Google + $20 Meta)

## Nextdoor
- Account: Not created
- Ad copy: Written at `/marketing/nextdoor/ad-copy.md`
- Audiences: Defined at `/marketing/nextdoor/audiences.md`
- Pixel: Not installed
- Budget: $100–$200/mo planned
- Also: organic community engagement (monitoring neighborhood posts)

## TikTok
- Account: Not created
- Ad copy: Written at `/marketing/tiktok/ad-copy.md`
- Audiences: Defined at `/marketing/tiktok/audiences.md`
- Budget: Lowest priority, TBD
