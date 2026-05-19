---
type: memory
agent-id: analytics
department: finance
tags:
  - type/memory
  - agent/analytics
created: 2026-04-16
updated: 2026-04-27
status: active
---

# Analytics Agent Memory — CWDB

Auto-loaded each session. Keep under 150 lines. Details in linked files.

## User Profile
- [[Jim Slogar]] — sole member. Needs clear dashboards and funnel reports.

## Tracking Status
- [Tracking Status](tracking-status.md) — Phase F pixels live; Phase A server-event spec authored 2026-04-27

## Active Specs
- **CANONICAL (2026-04-28):** `operations/analytics/hubspot-webflow-native-plan.md` — Webflow → HubSpot → {Google Ads, Meta, GA4} via native integrations + workflow webhooks. Phase 0 verification gate (4 capability checks) before build.
- A1 Enhanced Conversions parallel quick-win track lives in §3 Phase 4 of the canonical plan — GTM-only update, ships independent of HubSpot pipeline.

## Deprecated Specs
- `operations/analytics/server-event-spec.md` — DEPRECATED 2026-04-28 (Cloudflare Worker plan). Hashing/normalization rules (§2) still useful as reference if a hashing-only Worker is ever added.
- `operations/analytics/path-a-vs-path-b-server-events.md` — DEPRECATED 2026-04-28 (Path A/B comparison). Decision audit trail preserved.

## Key Funnel
Ad Impression → Click → Page Visit → Form Submit → Qualified Lead → Contractor Delivery

## Tracking Tools (all pending)
| Tool | Purpose | Status |
|------|---------|--------|
| GTM | Tag management | Not configured |
| GA4 | Web analytics | Not configured |
| Meta Pixel | Facebook/Instagram conversion | Not configured |
| Nextdoor Pixel | Nextdoor conversion | Not configured |
| Google Ads Conversion | Search ad ROI | Not configured |
| MS Clarity | Heatmaps, session recordings | Not configured |

## Website
- Platform: [[Webflow]]
- Site: cwdeckbuilders.com (staging: central-wisconsin-deck-builders.webflow.io)
- Pages: 21 (Phases A–E complete)

## Open Issues
- All tracking setup is blocked on Phase F
- No data exists yet (pre-launch)

## Related Files
- Reports output: `/finance/reports/performance/`
- PII audit: `/finance/reports/performance/pii-data-flow-audit-2026-04-04.md`
