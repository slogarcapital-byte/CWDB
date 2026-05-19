---
name: creatives-shipped
description: Running log of every ad creative the ad-campaign agent has rendered and shipped, with platform, path, and performance-when-known. One row per variant.
type: project
---

# Creatives Shipped — CWDB Ad Campaign

Running log of shipped variants. Append one row per creative at render-time. Update the CPL column when analytics comes back with per-creative performance.

Status values: `rendered` (HTML + PNG exist, not yet uploaded) · `live` (running on spend) · `paused` (kill-criteria hit) · `retired` (ended without fault) · `killed` (banned or brand-safety issue).

| Date | Campaign | Angle | Variant | Platform | Path (HTML) | Status | Spend | CPL | Notes |
|------|----------|-------|---------|----------|-------------|--------|-------|-----|-------|
| 2026-04-21 | launch-2026-04 | problem-solution | 1080x1080 | meta-square | /marketing/launch-2026-04/creatives/meta/problem-solution-1080x1080.html | rendered | — | — | shared by `m-as1-v1-problem` + `m-as2-v1-problem` control; composite-deck-wittenburg photo |
| 2026-04-21 | launch-2026-04 | problem-solution | 1080x1350 | meta-portrait | /marketing/launch-2026-04/creatives/meta/problem-solution-1080x1350.html | rendered | — | — | same control pair; Reels/Stories placement |
| 2026-04-21 | launch-2026-04 | process-proof | 1080x1080 | meta-square | /marketing/launch-2026-04/creatives/meta/process-proof-1080x1080.html | rendered | — | — | `m-as1-v2-process`; wausau-deck photo |
| 2026-04-21 | launch-2026-04 | process-proof | 1080x1350 | meta-portrait | /marketing/launch-2026-04/creatives/meta/process-proof-1080x1350.html | rendered | — | — | `m-as1-v2-process`; Reels/Stories |
| 2026-04-21 | launch-2026-04 | seasonal-urgency | 1080x1080 | meta-square | /marketing/launch-2026-04/creatives/meta/seasonal-urgency-1080x1080.html | rendered | — | — | `m-as2-v2-urgency`; hero-merrill photo; new eyebrow-tick atom |
| 2026-04-21 | launch-2026-04 | seasonal-urgency | 1080x1350 | meta-portrait | /marketing/launch-2026-04/creatives/meta/seasonal-urgency-1080x1350.html | rendered | — | — | `m-as2-v2-urgency`; Reels/Stories |
| 2026-04-21 | launch-2026-04 | process-proof | 1200x628 | google-display | /marketing/launch-2026-04/creatives/google-display/landscape-1200x628.html | rendered | — | — | RDA landscape; on standby (not running in launch) |
| 2026-04-21 | launch-2026-04 | process-proof | 1200x1200 | google-display | /marketing/launch-2026-04/creatives/google-display/square-1200x1200.html | rendered | — | — | RDA square; on standby |
| 2026-04-21 | launch-2026-04 | process-proof | 960x1200 | google-display | /marketing/launch-2026-04/creatives/google-display/portrait-960x1200.html | rendered | — | — | RDA portrait; on standby |
| 2026-04-21 | launch-2026-04 | logo | 1200x1200 | google-display | /marketing/launch-2026-04/creatives/google-display/logo-square-1200x1200.html | rendered | — | — | RDA logo square |
| 2026-04-21 | launch-2026-04 | logo | 1200x300 | google-display | /marketing/launch-2026-04/creatives/google-display/logo-horizontal-1200x300.html | rendered | — | — | RDA logo horizontal |


---

## How to append

When you ship a creative (after `/polish` pass and PNG rendered), add a row in this exact format:

```
| 2026-04-30 | launch-2026-04 | fast-quotes | v1 | meta-square | /marketing/creatives/meta/launch-2026-04/fast-quotes-v1.html | rendered | — | — | hero-wausau, dusk light |
```

When analytics comes back:
- Update `Status` to `live` / `paused` / `retired` / `killed`
- Fill in `Spend` (cumulative USD)
- Fill in `CPL` (USD per lead for this specific variant)
- Add one-line `Notes` on what performed or broke

---

## Monthly rollup

At the end of each month, add a one-paragraph summary below:

### April 2026
First batch shipped 2026-04-21 for the launch-2026-04 campaign. 6 Meta + 5 Google Display = 11 PNG assets. All 11 passed hook audit (`/marketing/launch-2026-04/05-hook-audit.md`). One re-do during production: Problem/Solution 1080×1080 was initially rendered against `hero-wausau.webp` (which is a pergola walkway, not a deck) and was swapped to `composite-deck-wittenburg.jpg`. No rollup performance data yet — Day-7 read expected 2026-04-28.
