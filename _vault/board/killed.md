# Killed — Failed, deferred-indefinitely, or superseded

> Each item gets one line of postmortem: what was tried, why it died, what replaced it.

---

## Parked (not killed)

> Reversible-in-seconds. GMB account / asset preserved. Un-park triggers documented in linked decision file.

### 2026-05-11

- **WB-002 — GMB profile + content pack** — Parked 2026-05-11 by default-ship (WB-015 + 24h rule); un-park triggers: (1) first accepted bid closes, (2) Debbie resolves `%real%` + closes within 30 days, (3) CWDB hits $5K MRR, (4) Jim's calendar opens a 30-min block with explicit GMB intent. Decision file: `_vault/decisions/wb-002-gmb-park.md`. When triggered: open `marketing/gmb/WB-002-jim-clicks.md` and execute (Path B walkthrough already paste-ready: 4 sections, ≤30 min Jim, 12 services + 732-char description + 12 Q&A + 3 GMB Posts). Owner on un-park: content-writer agent (already-shipped walkthrough) → Jim (UI execution). Ship type: artifact-prod. Postmortem: Lever 4 structurally blocked — GMB earns ROI from PROOF, not setup; live profile with zero reviews is worse than no profile. Park aligns work to bottleneck instead of producing an abandoned-looking listing.

---

## 2026-04-30

- **Make scenario `4792854` (lead routing v1)** — superseded
  - Was: parked since 2026-04-19 pivot
  - Replaced by: HubSpot Starter native connectors (form intake + contact/deal creation + contractor notification + offline conversion sync)
  - Postmortem: principle-2 violation; built before lead flow existed

- **Phase 0 verification scope (4 gates)** — collapsed to 1
  - HubSpot Starter SKU answered 3 of 4 questions instantly
  - Replaced by: single Phase 0 gate at `operations/analytics/phase-0-gate-spec.md`

## 2026-04-28

- **Server-events architecture: Path A (Cloudflare Worker) and Path B (Make scheduled)** — both dropped
  - Replaced by: HubSpot ↔ Webflow native (canonical plan: `operations/analytics/hubspot-webflow-native-plan.md`)
  - Postmortem: Jim chose simpler native integration over custom infrastructure

## 2026-04-19

- **Google Voice → Twilio port-in** — cancelled
  - Postmortem: pivot 2026-04-19 — manual SMS via Jim's existing GV is sufficient until lead volume justifies automation

- **Original 6-stage HubSpot pipeline spec** — superseded mid-build
  - Replaced by: 9-stage version (Jim added Creating Bid, Delivered Bid, Expired Bid to match contractor reality)
  - Postmortem: spec was correct for generic CRM but missed the "Expired Bid - No Response" warm-revisit slot needed for Wisconsin contractors' actual workflow

- **Original Deal-properties spec (`02-deal-properties.csv` first version)** — wrong-architecture
  - Replaced by: `02-contact-properties.csv` (form-fillable) + `03-deal-properties.csv` (workflow-managed)
  - Postmortem: HubSpot forms can only populate Contact/Company/Ticket — never Deal. Correction caught by Jim mid-build.

## 2026-03-29

- **Tally form** — superseded
  - Replaced by: Webflow native forms
  - Postmortem: simpler stack, better design control

- **WordPress + Zapier + Typeform stack** — never adopted
  - Replaced by: Webflow + Make + (later) HubSpot Starter
  - Postmortem: cost + integration tradeoffs favored consolidated stack
