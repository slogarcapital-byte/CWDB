---
name: Meta Ads bulk import is gated behind 2 weeks of account-age / spend maturity
description: New Meta ad accounts cannot access the "Import ads in bulk" feature until they've run ads for ~2 weeks. The greyed-out menu item is not fixable via workaround — it's a hard account-maturity gate.
originSessionId: fa9cfbd6-9de3-4868-9fc9-f7a70658d170
title: Meta Ads bulk import is gated behind 2 weeks of account-age / spend maturity
type: memory
memory_type: reference
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/meta-ads-bulk-import-gate.md
tags:
  - type/memory
  - memory/reference
---
**Meta Ads Manager's "Import ads in bulk" feature is locked behind account maturity.** Brand-new ad accounts cannot use it — even if you create a stub campaign first. The menu item stays greyed-out until the account has ~2 weeks of ad-serving history.

Meta surfaces this as one of the "advanced features" unlocked alongside: higher daily spend limits, live video ads, maximize value of conversions (ROAS), ad account creation increase, share Meta Pixel, share custom audiences, bulk import ads, overlay banner ads. See the "Get higher daily spend limits and advanced features" panel inside Ads Manager for the full list.

**Implication for CWDB:**
- First Meta campaign (2026-04-23 launch) had to be configured manually in the UI — no bulk-upload path available.
- Meta bulk CSV (`marketing/launch-2026-04/bulk-upload/10-meta-bulk-import.csv`) is valid and correctly structured; it's preserved for **Week 3+ use** once the CWDB ad account matures past the gate. At that point, the same CSV template can be used for variant refreshes, new ad-set splits, retargeting campaigns, etc.
- For the first ~14 days, all Meta campaign management stays manual UI.

**Contrast with Google Ads:** Google's bulk-upload via Tools → Bulk actions → Uploads works from day 1 on fresh accounts. No account-maturity gate. This is why the elegant-path savings for Google (~40 min) far exceeded Meta's (~5–10 min theoretical, 0 min actual for new accounts).

**How to apply:**
- For any NEW Meta ad account Jim sets up going forward, plan on ~2 weeks of manual UI before the bulk path opens up.
- When building campaign-launch brief: assume manual UI on Meta for any account < 14 days old.
- Don't promise bulk-Meta time savings for a first-launch unless the account is already mature.
- Check `marketing/launch-2026-04/bulk-upload/10-meta-bulk-import.csv` for expected unlock around 2026-05-07 (~2 weeks from 2026-04-23 launch).
