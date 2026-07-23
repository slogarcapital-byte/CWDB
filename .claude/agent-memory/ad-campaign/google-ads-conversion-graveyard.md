---
name: google-ads-conversion-graveyard
description: CWDB Google Ads conversion cleanup (2026-07-22) - live IDs, the 6/10 silent-primary root cause, and the GBP-local-actions-not-API-mutable gotcha
metadata:
  node_type: memory
  type: project
---

Findings from audit-2026-07-05 #10 conversion cleanup, verified live 2026-07-22. Full memo: `marketing/google-ads/2026-07-22-conversion-cleanup.md`.

## Durable platform quirks (reuse these)
- **Google-hosted conversion actions (GBP "Local actions", lead-form) are NOT mutable via the Google Ads API.** `conversionActions:mutate` returns `MUTATE_NOT_ALLOWED` at `operations[].update.type`. Setting them Primary/Secondary must happen in the Google Ads UI. The token scope (`https://www.googleapis.com/auth/adwords`) DOES allow mutates; the account's own website conversion actions are mutable, these are not. Do not waste a cycle scripting it.
- **Per-conversion-action metrics cannot be queried `FROM conversion_action`** (`PROHIBITED_METRIC_IN_SELECT_OR_WHERE_CLAUSE`). Use `FROM customer` (or campaign) with `segments.conversion_action_name` + `metrics.all_conversions` to get per-action firing by date.
- **PowerShell tool was broken this session** (exit 1 on any command incl. `Write-Host`). Fallback that worked: Python via the Bash tool for OAuth + GAQL (`urllib`). jq is NOT installed; use `python -c`.

## Live IDs (stable references)
- Ads customer 712-991-0870 (7129910870); MCC login 7762492754.
- Account native conversion tracking id = **18113251301** (so `AW-18113251301` is the correct on-site tag). Stale foreign tag to purge = `AW-10862517194`.
- Live GTM container = **GTM-T3PB96G2** (fires everything; no AW hardcoded in Webflow custom code). As of 2026-07-22 the published container holds only AW-18113251301; `AW-10862517194` is absent from site HTML and the published container (check unpublished GTM workspace / Google-tag linked destinations / GA4 Ads-links instead).
- Two GA4 measurement IDs double-track: **G-M9SFJ2RSQJ** and **G-ZQ19JEF9KC** (audit's double-tracking; consolidate).
- THE primary lead conversion = `from_submit_quotes` (id 7587819071, WEBPAGE, Count=One). GBP local actions to demote: 7601332445, 7629142557, 7663734897, 7666706074.
- Enabled Search campaign `CWDB Search Launch 2026-04` = **id 23783717705, bid = MAXIMIZE_CONVERSIONS** (corrects the older Maximize-Clicks note). Paused PMax clutter `Campaign #1` = 23783582120.

## Root cause of the silent primary (why re-designating primary won't fix it)
Both web conversions (`from_submit_quotes` tag AND the GA4-import `thank_you`) last fired **2026-06-10** and died the same day. Two independent measurement paths dying together = the shared upstream on-site /thank-you dataLayer signal broke on 6/10 (the two-tier-contract / form rebuild day), NOT the relay v2 cutover (7/14, a month later) and NOT any conversion-action config. GTM still has the /thank-you + form_submit + generate_lead trigger and /get-a-quote still redirects to /thank-you, so restore the on-page form-success dataLayer push (web-dev/analytics), then the primary self-heals.

## Decision: offline JobTread conversion stays SECONDARY, not primary
`GOOGLE_ADS_JT_CONVERSION_ACTION` is unset (the booked-job offline action does not exist yet; `push-google-offline-conversions.ps1` is a no-op). Do not make booked-job the primary: ~1-2/mo starves Smart Bidding, and gclid match rate is ~0 until the attribution-keeper ships. Sequence: fix web-submit primary, add offline booked-job as Secondary (value signal) after the keeper, then consider a blended value strategy.
