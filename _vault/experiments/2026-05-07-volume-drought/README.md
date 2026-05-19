---
type: experiment-set
created: 2026-05-07
owner: cwdb-ceo-operator
status: awaiting-jim-decision
---

# Volume Drought 2026-05-07 — Three Diagnostic Forks

> **The signal.** 5 homeowner contacts arrived in an 8-minute burst at 2026-05-05 07:40-07:48 UTC (plus 1 test submit at 20:33). Then **48+ hours of zero new contacts**. This is Day 3 of the drought.
>
> **The decision.** Pick one of the three folders below. Each is a credible explanation for the drought with a defined experiment, evidence threshold, and cost. Jim's choice is which fork to test first; everything inside the chosen one-pager is pre-decided.

## The forks (folder pick = decision)

| Fork | Hypothesis (in 1 line) | Test cost | Time-to-evidence |
|---|---|---|---|
| [a-budget-bump.md](./a-budget-bump.md) | Real organic rate on $30/day Google is 0-1/day; the burst was backlog flush | $140-315 incremental | 5-7 days |
| [b-smoke-test.md](./b-smoke-test.md) | Tracking is broken; leads are arriving but not landing in HubSpot | ~$0 | 5-30 minutes |
| [c-manual-paste.md](./c-manual-paste.md) | Ad account has a problem (paused, disapproved, capped) that we can't see | ~$0 | 5 minutes |

## Recommended sequence

The forks aren't mutually exclusive — they answer different questions. Run them in order of cost-to-evidence ascending: **(b) → (c) → (a)**. If (b) and (c) both come back clean, then (a) becomes the only remaining explanation and is worth funding.

But **even running (b) and (c) requires Jim's ~10 min today**. If Jim won't run either, we are committing to a 4th day of ignorance, and the brief should escalate that explicitly tomorrow.

## Mentor note

The cost of NOT picking is the cost of staying in the dark for another 24 hours. With $30/day burning, that's $30 of ad spend potentially flying into a void we cannot see. Across three days of inaction, that's $90 of unverified spend. Cheap relative to the business — but the **operational pattern is more expensive than the dollars**: it is the third consecutive day of carry on a 5-minute task.

The right move is the cheapest: spend 5 minutes today on (b), then 5 minutes on (c). If both clean, schedule (a) for tomorrow's brief.

---

> **Day 2 of carry as of 2026-05-08.** Recommend Jim run `b-smoke-test.md` first ($0, 15 min) before any other fork — falsifies tracking-blackout hypothesis cheapest.
