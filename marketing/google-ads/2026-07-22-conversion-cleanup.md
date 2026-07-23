# Google Ads Conversion Cleanup (audit-2026-07-05 #10)

Date: 2026-07-22
Owner: ad-campaign agent
Account: Central Wisconsin Deck Builders, customer 712-991-0870 (7129910870), MCC login 7762492754
Method: diagnosed and attempted changes via the Google Ads API (v21, OAuth app cwdb-ads-pull); everything not API-executable is in the sibling clicksheet.

---

## TL;DR

- The "silent primary" is NOT a Google Ads conversion-action problem. Two independent web conversions (the tag-based `from_submit_quotes` and the GA4-import `thank_you`) both stopped on the **same day, 2026-06-10**, which means the shared upstream **on-site /thank-you dataLayer signal broke**. Re-pointing "primary" fixes nothing; the site/GTM signal must be restored (handoff to web-dev/analytics).
- The task hypothesis that the 2026-07-14 relay v2 cutover caused the silence is ruled out: the silence began 2026-06-10, a month earlier, on the two-tier-contract / form rebuild day.
- Nothing in this task was API-mutable. The API instead **confirmed** the primary and dedupe are already correct, and **proved** the GBP demotion must be done in the UI.
- The stale `AW-10862517194` tag is **already absent** from the live site and the published GTM container. It is a verify-and-remove-if-present item in 3 back-end places, not an on-site edit.

---

## Root cause of the silent primary (task item 1)

Warehouse (`fact_ad_spend_daily`, google_ads): last day with any recorded conversion is **2026-06-10**. After that, six straight weeks of zero conversions while delivery ramped hard (clicks 36/wk to 157/wk, spend holding $180-230/wk). Machine-confirmed.

Google Ads API, per-conversion-action firing (2026-05-15 to 2026-07-22):

| Conversion action | id | total all_conv | first | last |
|---|---|---|---|---|
| from_submit_quotes (WEBPAGE, primary) | 7587819071 | 3 | 2026-06-07 | **2026-06-10** |
| cwdeckbuilders.com (web) thank_you (GA4 import, secondary) | 7587860386 | 3 | 2026-06-07 | **2026-06-10** |
| Local actions - Website visits (GBP) | 7601332445 | 18 | 2026-05-21 | 2026-07-16 |
| Local actions - Other engagements (GBP) | 7629142557 | 9 | 2026-05-27 | 2026-07-15 |
| Local actions - Directions (GBP) | 7666706074 | 4 | 2026-06-29 | 2026-07-16 |
| Clicks to call (GBP) | 7663734897 | 1 | 2026-06-24 | 2026-06-24 |

Both web conversions died on the identical day while the two GBP local actions kept firing. Because `from_submit_quotes` (Google's own tag path) and the GA4 import (a separate measurement path) share only one thing (the website's post-submit /thank-you event), the break is on the site, not in Google Ads. Corroborating: the live `/get-a-quote` still redirects to `/thank-you`, and GTM container `GTM-T3PB96G2` still contains `/thank-you`, `form_submit`, and `generate_lead` references, so the tag/trigger config is intact but the dataLayer signal it listens for stopped on 6/10. This is BREAK C in the 2026-07-05 audit, and its fix belongs with the attribution-keeper / relay work (web-dev, analytics), not this task.

## Which action should be THE primary (task item 1, decision)

- **Keep `from_submit_quotes` (7587819071) as the single primary lead conversion.** It is the purpose-built web quote-submit event, correct category (Submit lead form), already Primary, already Count = One. It is the only Primary among controllable (website-origin) actions.
- **Do NOT switch primary to the GA4-import `thank_you` action.** It died on the same day from the same broken source, so it is not a working alternative.
- **Do NOT make the offline JobTread booked-job conversion the primary.** Reasons: (1) it does not exist yet (`GOOGLE_ADS_JT_CONVERSION_ACTION` is unset, so `push-google-offline-conversions.ps1` is a no-op); (2) booked-job volume is ~1-2/month, far below the ~30/mo Smart Bidding needs, so it would starve as a sole biddable signal; (3) offline uploads match on gclid, and until the attribution-keeper ships (BREAK A/B) almost no lead carries a gclid, so matches would be near zero. Correct sequencing: restore the web-submit primary now, add the offline booked-job action as a **Secondary** later (value signal), then consider a blended value strategy once matches accumulate. Steps captured in clicksheet row 15.

## Demote the 4 GBP "Local actions" to secondary (task item 2)

The four Google-hosted local actions are all currently Primary and pollute the "Conversions" column (and drive the tracking-error nag): Website visits (7601332445), Other engagements (7629142557), Clicks to call (7663734897), Directions (7666706074).

**Attempted via API and BLOCKED.** `conversionActions:mutate` (validateOnly) returned `MUTATE_NOT_ALLOWED` on all four at `operations[].update.type`: Google-hosted conversion actions cannot be modified through the API. This is a hard platform limit, not a permission or scope issue (the token holds the full `https://www.googleapis.com/auth/adwords` scope, which permits mutates; the account's own website actions are mutable, these are not).

Result: manual UI demotion. Clicksheet rows 4-7.

Note on live impact: this is not only cosmetic. The enabled Search campaign `CWDB Search Launch 2026-04` (23783717705) is on **MAXIMIZE_CONVERSIONS** (the audit assumed Target Spend; the live API says otherwise). Its only biddable web goals (Submit lead form / Request quote, website) have had zero conversions since 6/10, so the bidder is effectively blind in peak season while junk local actions clutter the Conversions column. Recommend switching that campaign to Maximize Clicks until the site signal is restored and >=30 conversions bank, consistent with the standing cold-start pattern. Needs Jim/CEO sign-off (clicksheet row 13).

## Remove the stale AW-10862517194 site tag (task item 3)

Findings from the live site and published GTM container (2026-07-22):

- The account's OWN conversion tracking id is **18113251301** (`customer.conversion_tracking_setting.conversion_tracking_id`). So `AW-18113251301` is the correct native tag.
- Live site `www.cwdeckbuilders.com` fires everything through **GTM container `GTM-T3PB96G2`**. No AW tag is hardcoded in Webflow custom code (checked home, /get-a-quote, /thank-you).
- The published `GTM-T3PB96G2` container contains **only `AW-18113251301`**. `AW-10862517194` appears **0 times** in the container and 0 times in the site HTML.

So the stale tag is **not currently firing from the live site**. Exact location to check/remove (it is a back-end linkage or an unpublished workspace, not on-page): (a) GTM `GTM-T3PB96G2` unpublished workspace / paused tags; (b) the Google tag `AW-18113251301` linked/connected destinations in Google Ads Data manager; (c) GA4 (properties `G-M9SFJ2RSQJ` and `G-ZQ19JEF9KC`) Google Ads product links. Clicksheet rows 10-12. It is possible it was already removed since the 7/5 audit.

Adjacent finding (not this task, for analytics): the container fires **two GA4 properties** (`G-M9SFJ2RSQJ`, `G-ZQ19JEF9KC`), i.e., the audit's double-tracking. Recommend consolidating to one.

## Once-per-session dedupe on the primary (task item 4)

`from_submit_quotes` already has Count = One (`ONE_PER_CLICK`). The dedupe requirement is already satisfied. No change (verified via API; clicksheet row 3 is a no-touch confirmation). The Google-hosted lead form action "do not use" (7585643038) is already Secondary + One, so no action there either.

---

## What changed via API vs clicksheet

- **Changed via API: nothing.** No mutate was applied. The one API-executable candidate (GBP demotion) is blocked by `MUTATE_NOT_ALLOWED`, and the primary + dedupe were already correct so needed no mutate. All API calls this session were read-only diagnostics plus one `validateOnly` dry-run (no side effects).
- **Clicksheet (`2026-07-22-conversion-cleanup-clicksheet.csv`):** demote the 4 GBP local actions (rows 4-7); verify primary + dedupe unchanged (rows 2-3); verify/remove the stale AW-10862517194 in 3 back-end places (rows 10-12); bid-strategy protective switch (row 13, needs decision); optional PMax cleanup (row 14); offline JobTread follow-up (row 15); website-signal handoff (row 16).

## Full conversion-action inventory (13 actions, as of 2026-07-22)

Enabled: 7585643038 "do not use" (leadform, Secondary, One); **7587819071 from_submit_quotes (WEBPAGE, PRIMARY, One)**; 7587860386 GA4 thank_you (Secondary, Many); 7601332445 / 7629142557 / 7663734897 / 7666706074 GBP local actions (all PRIMARY, Many, Google-hosted, API-immutable).
Removed (already deleted, the ~25-30-conv GA4 imports the audit noted): 7585332161, 7587866788, 7587892314.
Hidden: 7585330016 (converted lead), 7585330019 (qualified lead), 7585640374 (GA4 purchase).
