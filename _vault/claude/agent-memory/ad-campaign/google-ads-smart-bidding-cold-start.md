---
name: google-ads-smart-bidding-cold-start
description: CWDB 2026-05-19 — Smart Bidding starved campaign to ~10% budget utilization; fix is Maximize Clicks bridge until 30+ conversions banked
metadata: 
  node_type: memory
  type: project
  originSessionId: d7ccfc8a-fa04-45b2-9345-9c80e9d4d28b
---

Smart Bidding (Maximize Conversions / Target CPA / Max Conversion Value) requires ~30 conversions per month of feedback to optimize. Below that threshold, Google's algorithm refuses to bid aggressively and the campaign self-starves.

**The CWDB diagnosis (2026-05-19):** 14 days of $30/day budget = $420 committed. Actual spend $50 (~12% utilization), 96 impressions, 7 clicks (7.3% CTR), 1-2 conversions. Status Enabled with no warnings. This is the cold-start death spiral — algorithm has insufficient conversion data, bids low, fewer clicks land, even less data accumulates, repeat.

**Why:** Validated by the 5/5 state file's own warning ("Conversion tracking broken → Smart Bidding starved → delivery collapses"). The 26 days between ad launch (2026-04-23) and this diagnosis produced exactly one organic form lead (Debbie 2026-05-08). Everything else logged as a "lead" was Jim's manual catch-up of pre-relay email/call leads. CTR was actually fine — bid strategy never let the ads enter the auction enough to test conversion rate.

**How to apply:**
1. **For any new Google Ads campaign in CWDB's category**: start with **Maximize Clicks** + max CPC cap (~$5 for home-services WI). Force the budget to be spent. Generate the click volume needed to bank conversions.
2. **Run for 3-4 weeks** until ≥30 conversions accumulated in the past 30 days.
3. **Then switch back** to Maximize Conversions or Target CPA. Smart Bidding now has signal to work with.
4. **Same rule for Meta**: don't put a new pixel on Maximize Conversions until 50+ events accumulated. Start with Maximize Reach or Manual bidding.
5. **Don't change multiple variables at once.** When fixing bid strategy, hold keywords + budget + creative steady for 7-10 days to isolate the effect.
6. **Watch the spend column**, not the impressions count, for the first signal. If daily spend climbs toward budget within 48h, the fix is working.

**Signal that the fix isn't enough:** if Maximize Clicks still doesn't spend ≥80% of budget within 5-7 days, the constraint is elsewhere — audience too narrow, keywords too restrictive, Quality Score issues, or geographic targeting drift. Then layer in keyword broadening or geo-loosening.

Related: [[hormozi-framework]] — Lever 1 (Volume) below Rule of 100 was the named bottleneck. [[feedback-reorient-via-vault-before-diagnosing]] — the vault primary sources (state file, briefs) already named this risk; recon-agent summary glossed it.
