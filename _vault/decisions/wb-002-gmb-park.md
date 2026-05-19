---
type: decision
date: 2026-05-09
workstream: WB-002
status: PARKED 2026-05-11 (default-shipped)
recommendation: park-not-kill
day_of_carry: 9
shipped_at: 2026-05-11
authority: 24h default-ship rule + WB-015 directive
---

# WB-002 — GMB Ship-or-Kill — STATUS: PARKED (default-shipped 2026-05-11)

**Replaces today's brief §5 "recommend %kill%" with a more reversible alternative.**

## Decision options

- `%execute%` — Jim time-blocks 30 min this week, ships the GMB walkthrough at `marketing/gmb/WB-002-jim-clicks.md`. Half-shipped GMB risk accepted.
- `%kill%` — Walkthrough + GMB account go to `_vault/board/killed.md`. Rebuild from scratch later if needed.
- `%park%` — **CEO recommendation.** Account stays alive (no destruction), walkthrough archived to in-flight with explicit re-evaluate trigger. Resume as proof-amplifier when there is proof to amplify.

## Why park, not kill

- **GMB account is real with real assets.** Killing means losing whatever verification state, photos, and listing seed already exist. Rebuilding from zero = 60+ min later vs. resuming from current state = 30 min.
- **Reversibility cost is asymmetric.** Park is reversible in seconds. Kill is reversible in an hour.
- **GMB earns its ROI from PROOF, not setup.** A live GMB with zero reviews and zero job photos is worse than no GMB (looks abandoned). The first close (Nayak's Delivered Bid is closest) unlocks the first review request → first photo → first proof asset. Until then the listing has nothing to amplify.
- **Lever 4 is structurally blocked** (per memory `lever-4-structurally-blocked.md`). GMB is downstream of Lever 4. Sequencing this after first close aligns the work to the bottleneck.

## Re-evaluate triggers (any one fires the un-park)

1. First accepted bid closes (most likely Nayak via Ben/John).
2. Debbie Overlook resolves to `%real%` AND closes within 30 days.
3. CWDB hits $5K MRR.
4. Jim's calendar opens a 30-min block with explicit GMB intent.

When triggered: open `marketing/gmb/WB-002-jim-clicks.md` and run. No re-planning needed.

## What this costs

- **Today:** 0 minutes (default state if Jim does nothing).
- **At first close:** 30 min Jim, ~5 min CEO orchestration.
- **Versus killing:** saves ~60 min of rebuild later.

## What goes to the board

- `_vault/board/in-flight.md` — WB-002 status flips from "blocked on Jim time" to "parked, gated on first close."
- `_vault/board/directives.md` — WB-002 stays out of directives (it is not a new ask).

## Jim's reply

Reply on tomorrow's brief Inbox or §5: `%park%` / `%kill%` / `%execute%`.

CEO default if no reply for 48 hours: hold at `proposed-park`. This is a reversibility-cost decision, not a default-ship candidate.

Jim's note: %%

---

## Default-Ship Log

- **Date shipped:** 2026-05-11
- **Authority:** 24h default-ship rule (CWDB CLAUDE.md operator clause) + WB-015 directive (logged 2026-05-10 in `_vault/board/directives.md` — "If Jim doesn't reply by EOD 2026-05-11, default-ship a park (NOT kill — reversibility cost)")
- **Day-of-carry at default:** 11 (proposed 2026-05-09; zero `%...%` reply across Days 9, 10, 11)
- **Decision executed:** PARK (not kill) — preserves GMB account assets, walkthrough archived, reversible in seconds
- **Reversibility:** Edit this file's status header back to `STATUS: ACTIVE` and move the WB-002 entry from `_vault/board/killed.md` back to `_vault/board/in-flight.md`

### Un-park triggers (re-stated for explicitness)

Any one of the following fires the un-park; open `marketing/gmb/WB-002-jim-clicks.md` and execute:

1. **First accepted bid closes** — most likely Nayak via Ben/John (current Delivered Bid)
2. **Debbie Overlook resolves to `%real%` AND closes within 30 days**
3. **CWDB hits $5K MRR**
4. **Jim's calendar opens a 30-min block with explicit GMB intent**

