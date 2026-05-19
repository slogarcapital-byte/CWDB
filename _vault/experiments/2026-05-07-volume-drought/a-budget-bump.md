---
type: experiment
fork: a
created: 2026-05-07
owner: revenue-optimization
hypothesis: backlog-flush
status: awaiting-jim-decision
---

# Fork A — Backlog-Flush Hypothesis: Bump Google Ads to $50-75/day for one week

## Hypothesis

The 5-lead burst on 2026-05-05 07:40-07:48 UTC was an accumulated-backlog dump on relay-deploy day. The form relay had been silently failing prior to 2026-05-05 (HubSpot Forms API direct-fetch relay shipped that morning per memory `hubspot-forms-api-relay-pattern.md`). Once it went live, the 14 days of trapped form-submitters who had returned to the site or finished the form flushed in 8 minutes. **The real organic rate on $30/day Google with our current creative + landing page is 0-1 leads/day.**

If true: this is a **Lever 1 volume-floor problem.** Below Hormozi's "Rule of 100" floor for any single channel. Cost-per-lead is fine in theory; absolute volume is the bottleneck.

## What to do

1. Bump Google Ads daily budget on `CWDB — Search — Launch 2026-04` from $30/day → **$60/day** for **7 days** (2026-05-07 evening through 2026-05-14 evening).
2. **Do not** change creative, keywords, audiences, or landing page during the test window — controlled variable is budget alone.
3. At end of 7 days: compare leads/day, CPL, conversion rate vs. the prior 14 days at $30/day.

## What evidence resolves it

**Confirms hypothesis:** 60/day budget produces ≥4 leads in the 7-day window (vs. 0 in the prior 48h). That tells us volume scales linearly with spend → keep the bump or push higher.

**Falsifies hypothesis:** 60/day budget produces 0-1 leads in the 7-day window. That tells us the problem is upstream of ad spend (creative, landing page, ad-account misconfig, or seasonality) → kill the bump, redirect to forks (b)/(c), and run a creative diagnostic.

## Cost

- **Incremental ad spend:** $30/day × 7 days = **$210 incremental** (total spend during test: $420 vs. $210 baseline)
- **Jim time:** 5 minutes to change budget in Google Ads UI
- **Risk:** $210 with no return if hypothesis is wrong. Acceptable diagnostic cost for a Lever 1 question that's been carrying for 14+ days.

## Why this is fork A and not the default

Fork (b) and fork (c) are both **cheaper-to-evidence**. If tracking is broken (b) or the ad account is throttled (c), bumping budget on a broken pipe just burns more money faster. **Run (b) and (c) first.** Only fund (a) if both return clean.

## What this looks like if Jim picks it

- Today: Jim changes daily budget to $60 in Google Ads UI.
- Daily: Manual paste of yesterday's leads count + CPL into the brief (or wait for WB-011 to land mid-week).
- 2026-05-14 morning: Compare 7-day leads, CPL, total spend; ship verdict to revenue-optimization for write-up.

## Linked decisions

- §5 decision item: "Volume regression interpretation + budget bump" — this is the formal experiment design for that ask.
- Carries from yesterday's brief.
