---
type: experiment
fork: c
created: 2026-05-07
owner: ad-campaign
hypothesis: ad-account-issue
status: awaiting-jim-decision
---

# Fork C — Ad-Account-Issue Hypothesis: 5-minute manual paste from ads.google.com

## Hypothesis

Something is wrong inside the Google Ads UI that we cannot see from outside it. Possibilities (in rough probability order):
1. **Campaign is paused** — accidentally, or auto-paused by a Google policy flag we missed.
2. **Ads disapproved** — a creative element (image, claim, landing page) tripped policy review and ads stopped serving without notification email landing.
3. **Daily budget capped to $0** — possible if billing failed (card declined, account suspended).
4. **Conversion-tracking broken on the platform side** — Google de-prioritizing serving because Smart Bidding sees zero conversions.
5. **Audience exhaustion / frequency cap** — small Wausau geo + 14 days of running = audience saturation. Some impressions, near-zero clicks.

Without WB-011 credentials we cannot pull the data via API. Without a manual paste we cannot see it at all. **3 days of flying blind.**

## What to do

1. Open https://ads.google.com (Customer 712-991-0870; verify account selector top-right reads "Central Wisconsin Deck Builders" per memory `feedback-account-identity-verification.md`).
2. Top of dashboard: confirm campaign `CWDB — Search — Launch 2026-04` status:
   - **Status:** Enabled / Paused / Removed / Limited?
   - **Policy:** any red badges on ads or keywords?
   - **Budget:** is the daily $30/day actually being spent? (look for "Limited by budget" indicator)
3. Reports → Performance → date range last 7 days. Capture for brief paste:
   - Cost (spend)
   - Impressions
   - Clicks
   - CTR
   - Conversions (form submits)
   - Cost / conversion
4. Paste the 6 numbers into a comment in tomorrow's brief Inbox. Format: `%week-1: cost=$X, imp=Y, clk=Z, ctr=A%, conv=B, cpa=$C, status=enabled%`

## What evidence resolves it

**Confirms hypothesis (account issue exists):** Status ≠ Enabled, OR ads have policy red flags, OR daily spend ≪ $30/day, OR impressions trending toward zero. → kill all other forks until the account-level issue is resolved.

**Falsifies hypothesis (account is healthy):** Status Enabled, no red flags, ~$30/day spend, normal impressions, and ≥10 clicks/day. → account is fine; problem is downstream (creative resonance, landing page, or genuine demand floor). Fork (a) becomes the rational next move.

## Cost

- **Ad spend:** $0
- **Jim time:** **~5 minutes** (this is the fastest, highest-information-density action available today)
- **Risk:** zero

## Why this is fork C (run after B)

(b) tests "is the pipe broken?" (c) tests "is the source dry?" Both are diagnostic before any treatment (a). Run order: (b) 15 min → (c) 5 min → if both clean, fund (a) tomorrow.

This fork is also a **superset of §5's** "Keep or kill Google Ads manual paste ask." Picking fork (c) = saying yes to that decision. The recommendation in the brief was already (a) yes for one final paste — fork (c) operationalizes it.

## What this looks like if Jim picks it

- Today: 5-minute UI session. Numbers pasted into brief Inbox or directly here.
- Tomorrow's brief auto-merges the paste into §1 Live Data Tables under Google Ads MTD (replacing the API-blocked error block until WB-011 lands).
- Decision quality on fork (a) becomes 10x sharper because we know the baseline.

## Linked decisions

- §5 decision: "Keep or kill Google Ads manual paste ask" — fork (c) IS the manual paste; picking it = `%yes one final paste%`.
- WB-003 (in-flight, 6+ sessions overdue) — fork (c) closes WB-003.
- WB-011 (Day 3 carry) — fork (c) is the **interim** while waiting on the dev-token approval clock.
