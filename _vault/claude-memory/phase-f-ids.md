---
name: Phase F Analytics IDs
description: GTM, GA4, Meta, Nextdoor, Google Ads, MS Clarity account IDs for CWDB site install
originSessionId: c88b8450-e859-4bc8-ac91-1ebbe449e767
title: Phase F Analytics IDs
type: memory
memory_type: project
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/phase-f-ids.md
tags:
  - type/memory
  - memory/project
---
# Phase F — Analytics & Pixel IDs

Collected 2026-04-17. Jim gathering in batch; paste into GTM once complete.

## Received
- **GTM Container ID:** `GTM-T3PB96G2` (2026-04-17)
- **GA4 Measurement ID:** `G-ZQ19JEF9KC` (2026-04-17)
- **Meta Pixel ID:** `1276568654662913` (2026-04-25 — pixel `cwdeckbuilders.com` in CWDB Meta Business; superseded original 1207759804531749 which was in work Meta Business)
- **Nextdoor Pixel ID:** `090fab28-0395-4c7d-8044-6eb1139b5e65` (2026-04-18)
- **Google Ads Customer ID:** `712-991-0870` (2026-04-25 — CWDB-dedicated account; replaces original work account where Phase F conversion was mistakenly created)
- **Google Ads Conversion ID:** `AW-18113251301` (2026-04-25 — superseded original AW-10862517194)
- **Google Ads Conversion Label:** `PgcJCL_ck6IcEOWPib1D`
- **Combined send_to value (for GTM):** `AW-18113251301/PgcJCL_ck6IcEOWPib1D`
- **MS Clarity Project ID:** `wdo8r9av0g` (2026-04-18)

## Pending
(none — batch complete 2026-04-18)

## Install Status (2026-04-18)
- ✅ GTM head snippet registered + applied to Webflow site (id: `gtm_head_snippet`, location: header)
- ✅ Site published to staging subdomain `central-wisconsin-deck-builders.webflow.io`
- ⏳ GTM container configuration (inside tagmanager.google.com) — pending Jim
  - Add GA4 Configuration tag (measurement ID `G-ZQ19JEF9KC`, trigger: All Pages)
  - Add Meta Pixel base code tag (pixel ID `1276568654662913`, trigger: All Pages) — corrected 2026-04-25 after account-mismatch discovery
  - Add Nextdoor Pixel base code tag (pixel ID `090fab28-0395-4c7d-8044-6eb1139b5e65`, trigger: All Pages)
  - Add MS Clarity tag (project ID `wdo8r9av0g`, trigger: All Pages)
  - Add Google Ads Conversion Linker tag (trigger: All Pages)
  - Add Google Ads Conversion Tracking tag (send_to: `AW-18113251301/PgcJCL_ck6IcEOWPib1D`, trigger: /thank-you pageview) — corrected 2026-04-25 after account-mismatch discovery
  - Add Meta Pixel Lead event (trigger: /thank-you pageview)
  - Add Nextdoor Lead event (trigger: /thank-you pageview)
  - Publish GTM container (top-right "Submit" button in GTM)

**Why:** Needed to fire Phase F install — web-dev will drop GTM snippet into all 21 Webflow pages, then every pixel loads through the container (one source of truth).

**How to apply:** All 6 IDs now in. Ready for web-dev + analytics to run the install in one pass — drop GTM snippet into Webflow head, configure all 5 pixels/conversions inside GTM, publish, smoke-test with GTM Preview + Tag Assistant.
