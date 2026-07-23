---
type: memory
agent-id: ad-campaign
department: marketing
tags:
  - type/memory
  - agent/ad-campaign
created: 2026-04-16
updated: 2026-04-16
status: active
---

# Ad Campaign Agent Memory — CWDB

Auto-loaded each session. Keep under 150 lines. Details in linked files.

## User Profile
- [[Jim Slogar]] — sole member, manages all ad accounts. No marketing agency on retainer.

## Platform Status
- [Platform Status](platform-status.md) — All 4 platforms: ad copy written, none launched
- [Budget Allocation](budget-allocation.md) — Planned $700–$1,100 first month

## Creative Production
- [Creatives Shipped](creatives-shipped.md) — Running log of every rendered variant + CPL when known
- [Anti-Patterns Seen](anti-patterns-seen.md) — AI-slop patterns caught in /critique; never recur

## Creative Pipeline References (read before any creative work)
- `/.impeccable.md` — Design Context (users, brand personality, aesthetic direction, principles)
- `/marketing/creatives/README.md` — folder structure, naming, workflow
- `/marketing/creatives/platform-specs.md` — exact dimensions, safe zones, file limits
- `/marketing/creatives/creative-system.md` — reusable atoms and tokens (grows via /impeccable extract)
- `C:\Users\jslog\.claude\skills\impeccable\SKILL.md` — methodology source of truth

## Platforms
| Platform | Ad Copy | Audiences | Account | Status |
|----------|---------|-----------|---------|--------|
| [[Google Ads]] | `/marketing/google-ads/ad-copy.md` | Keywords in CSV | TBD | Not launched |
| [[Meta Ads]] | `/marketing/facebook-ads/ad-copy.md` | `/marketing/facebook-ads/audiences.md` | TBD | Not launched |
| [[Nextdoor]] | `/marketing/nextdoor/ad-copy.md` | `/marketing/nextdoor/audiences.md` | TBD | Not launched |
| [[TikTok]] | `/marketing/tiktok/ad-copy.md` | `/marketing/tiktok/audiences.md` | TBD | Not launched |

## Target Metrics
- Cost per lead: <$60
- Target CPL by platform: Google $40-60, Facebook $30-50, Nextdoor $20-40
- Landing page: cwdeckbuilders.com (via [[Webflow]])

## Prerequisites Before Launch
- [ ] Website Phase F complete (SEO, analytics, pixels)
- [ ] GTM + GA4 configured
- [ ] Meta Pixel installed
- [ ] Nextdoor Pixel installed
- [ ] Google Ads conversion tracking configured
- [ ] At least one signed contractor agreement

## Key Rules
- All ads drive to cwdeckbuilders.com — never to third-party forms
- Geographic targeting: 5 primary cities ([[Wausau]], [[Schofield]], [[Weston]], [[Mosinee]], [[Merrill]])
- Persona: Homeowners aged 30-65 with property in Central Wisconsin

## Platform Quirks (hard-won lessons)
- [Google Ads Smart Bidding cold-start starvation](google-ads-smart-bidding-cold-start.md) — STANDING PATTERN. New campaigns with <30 conv/mo self-starve under Maximize Conversions / Target CPA. Bridge with Maximize Clicks + max CPC cap until ≥30 conversions banked, then graduate. CWDB campaign hit ~12% budget utilization for 26 days before this was diagnosed.
- [Google Ads callout bulk Row type is "Callout" not "Callout extension"](google-ads-callout-row-type.md) — Google's own template sample rows are wrong; parser rejects the legacy value.
- [Meta Ads bulk import gated ~2 weeks of account maturity](meta-ads-bulk-import-gate.md) — Fresh accounts can't use bulk; plan manual-UI launches for any new Meta account. CWDB unlocked ~2026-05-07.
- [Google Ads conversion graveyard](google-ads-conversion-graveyard.md) — 2026-07-22 cleanup. Google-hosted (GBP) conversion actions NOT API-mutable (MUTATE_NOT_ALLOWED); native tag AW-18113251301 vs stale AW-10862517194; GTM-T3PB96G2; two GA4 ids; silent primary since 6/10 = on-site /thank-you signal break, not config; enabled Search campaign 23783717705 on MAXIMIZE_CONVERSIONS.
