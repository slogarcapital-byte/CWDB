---
name: Google Ads callout bulk upload — Row type must be "Callout" not "Callout extension"
description: The callout_asset_template.csv from Google's own support page shows Row type = "Callout extension" in sample rows, but the Google Ads bulk-upload parser rejects that value. The correct value is "Callout".
originSessionId: fa9cfbd6-9de3-4868-9fc9-f7a70658d170
title: Google Ads callout bulk upload — Row type must be "Callout" not "Callout extension"
type: memory
memory_type: reference
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/google-ads-callout-row-type.md
tags:
  - type/memory
  - memory/reference
---
When building Google Ads campaign-level callout CSVs for bulk upload via **Tools → Bulk actions → Uploads**, the `Row type` column must contain **"Callout"** — NOT "Callout extension" as shown in Google's own `callout_asset_template.csv` sample data.

**Why this matters:** Google's official template (downloaded from https://support.google.com/google-ads/answer/10702525 on 2026-04-22) literally has `Callout extension` in the example rows. If you match the template verbatim (as recommended), the parser silently rejects those rows with a generic "invalid row type" error. Jim hit this 2026-04-22/23 during the launch upload and had to hand-fix all 8 rows to `Callout` before the upload succeeded.

**How to apply:**
- For future CWDB Google Ads callout bulk CSVs, use `Callout` (asset-format) not `Callout extension` (legacy extension-format) as the `Row type` value.
- The header column stays `Row type` (lowercase `t`) — that part of Google's template is correct.
- Same issue likely applies if Google ever migrates the structured snippet template to ask for a Row Type; check that file too when next editing.
- Ad group column can remain blank for campaign-level callouts. That part worked as expected.

**Canonical fixed row example:**
```
Row type,Action,Campaign,Ad group,Callout text
Callout,add,CWDB — Search — Launch 2026-04,,48-Hour Quote
```

**File reference:** `marketing/launch-2026-04/bulk-upload/07-callouts.csv` — currently uses the corrected `Callout` value after Jim's hand-fix.
