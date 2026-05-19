---
type: bulk-upload-instructions
status: ready
created: 2026-04-22
owner: cwdb-ceo-operator
for: Jim — Google Ads bulk upload (replaces manual click-through in DEPLOY.md §2)
tags:
  - type/bulk-upload
  - dept/marketing
  - launch/2026-04
---

# Google Ads Bulk Upload — CWDB Launch 2026-04

**This replaces ~25 of the 30 manual steps in `DEPLOY.md §2`.** Five CSVs build the full Search campaign in one upload pass. Extensions (sitelinks, callouts, structured snippets, call) still need to be added manually after — see §C below.

---

## Estimated time

- **Bulk-upload path (this folder):** ~15 min total upload + 2 min for Call schedule + 5 min verification = **~22 min**
- **Old manual path (DEPLOY.md §2 1–30):** 60–90 min
- **Net savings:** ~50 min, plus zero copy-paste error risk

---

## §A — Files in this folder

Upload IN THIS ORDER (each later file references campaign/ad-group names from earlier files):

| # | File | What it creates | Rows |
|---|---|---|---|
| 1 | `01-campaign.csv` | The Search campaign (Paused, $30/day, Manual CPC, Wausau +20mi) | 1 |
| 2 | `02-ad-groups.csv` | AG1 (Decision, $3.50 CPC) + AG2 (Comparison, $2.50 CPC) | 2 |
| 3 | `03-keywords.csv` | 15 AG1 (7 phrase + 8 exact) + 16 AG2 (phrase) = 31 keywords | 31 |
| 4 | `04-negative-keywords.csv` | 59 campaign-level negatives | 59 |
| 5 | `05-responsive-search-ads.csv` | 2 RSAs (1 per ad group, Headline 1 pinned to Position 1) | 2 |
| 6 | `06-sitelinks.csv` | 4 sitelink assets (campaign-level) | 4 |
| 7 | `07-callouts.csv` | 8 callout extensions (campaign-level) | 8 |
| 8 | `08-structured-snippets.csv` | 1 Services structured snippet (5 values) | 1 |
| 9 | `09-call-asset.csv` | Call asset with phone (715) 544-7941 | 1 |
| 10 | `10-meta-bulk-import.csv` | Meta: 1 campaign + 2 ad sets + 4 ads (replaces DEPLOY.md §3) | 4 |

All files use UTF-8, comma-separated, header row included. Em-dashes (`—`) in campaign/ad-group names are preserved across upload.

**Note on schemas:** Files 1–6 + 9 use Google Ads Editor's modern format (Row Type / Asset action / Level columns). Files 7 + 8 use the older extension format (lowercase `add` action) — that's how Google's official templates ship them today (callout + structured snippet templates haven't been migrated to Asset format). Both formats are accepted by Google Ads UI's bulk-upload endpoint.

---

## §B — How to upload

### Option 1: Google Ads UI (web — easiest, recommended for this launch)

1. Go to https://ads.google.com → click your account.
2. **Tools** (wrench icon, top right) → **Bulk actions** → **Uploads**.
3. Click **+ NEW UPLOAD**.
4. Upload `01-campaign.csv` → click **Preview**. Review the diff. Click **Apply**.
5. Wait for "Upload complete" status (~30 sec).
6. Repeat steps 3–5 for `02`, `03`, `04`, `05` IN ORDER.
7. Verify: navigate to Campaigns → confirm `CWDB — Search — Launch 2026-04` appears with status **Paused**, both ad groups present, RSA built in each.

### Option 2: Google Ads Editor (desktop app — better diff review)

1. Open Google Ads Editor (download free from Google if not installed).
2. **File → Import → From file** → select each CSV in order.
3. Editor shows a preview before posting. Review.
4. **Post Changes** button → applies to your live account.

UI option is cleaner if you've never used Editor. Editor option is better if you want to inspect every change before it goes live.

---

## §C — What's NOT in this bulk upload (manual after)

The 9 CSVs cover everything except 2 small Call-asset settings that the official call_asset_template.csv doesn't expose as columns:

### Call asset — 2-click manual finish

After uploading `09-call-asset.csv`, go to **Ads & assets → Assets → Call asset (the one we just created) → Edit**:
- ☑ **Call reporting:** ON
- **Schedule:** click "Add schedule" → Mon–Fri, 9:00 AM – 5:00 PM, (GMT-06:00) Central Time

That's it for assets. ~2 minutes total.

---

## §D — Manual UI steps still required after bulk upload

Two settings that the bulk-upload CSVs don't expose (or expose poorly), **do these in the UI before un-pausing**:

1. **Networks — confirm Search Partners + Display Network are OFF.**
   - Campaign settings → Networks. The CSV sets `Networks: Google search` which should default both off, but visually confirm. If either checkbox is on, uncheck and save.

2. **Location options — Presence vs Interest.**
   - Campaign settings → Locations → expand "Location options".
   - Target = `Presence: People in or regularly in your targeted locations`
   - Exclude = `Presence or interest`
   - The CSV sets the geographic radius but Google's default presence/interest setting is "Presence or interest" — which is wrong for local lead gen. Switch to "Presence" only.

3. **Conversion action — confirm `form_submit_quote` is in the campaign.**
   - Goals → Conversions. Confirm it's listed under this campaign with value $200. If it's only set as account-default but not explicitly attached, attach it.

4. **Ad schedule** — confirm the ad-group rotation is set to "All day, every day" (24/7). The CSV doesn't override schedule, so it inherits Google's default which is correct, but spot-check.

---

## §E — Verification

Once all 9 uploads are done + Call asset schedule/reporting set + manual UI settings confirmed:

1. **Campaign list** → `CWDB — Search — Launch 2026-04` shows status **Paused** (gray dot).
2. **Ad groups** → 2 ad groups present, both Paused.
3. **Keywords tab** → 31 active keywords across the 2 ad groups.
4. **Negative keywords tab** (campaign level) → 59 negatives.
5. **Ads tab** → 2 RSAs, both Paused, Headline 1 shows "Pinned to Position 1" badge.
6. **Assets tab** → 4 sitelinks + 8 callouts + 1 structured snippet + 1 call asset, all attached to the campaign.

If all 6 check, run §4 Verification Lap from `DEPLOY.md` (1 test lead through the form), then un-pause the campaign per §5 Go-Live.

---

## §F — If something fails

- **Upload error "Campaign not found"** on file 02/03/04/05 → file 01 didn't actually post. Re-upload `01-campaign.csv`, then retry from where you stopped.
- **Headline rejected for length** → unlikely (every headline pre-verified ≤30 chars), but if it happens, edit in the UI and resave.
- **`{KeyWord:...}` headlines show as literal text in preview** → that's expected in CSV preview; they activate at ad-serve time when a triggering keyword fits.
- **Negative keyword "what is" or "how to" over-blocking real queries** → expected risk; review search-terms report at Day 7 and remove if needed (these are phrase-match not broad, so impact is bounded).
- **Headline 1 not pinned to Position 1** → CSV column "Headline 1 position" set to `1` should pin. If it didn't apply, manually pin in UI (RSA → click Headline 1 → pin icon → Position 1).

---

## §G — Meta Ads bulk import (replaces DEPLOY.md §3)

**File:** `10-meta-bulk-import.csv` — 4 ad rows × 114 columns matching Meta's `AdsManagerTemplate_v2.3.xltx` schema. Builds 1 campaign + 2 ad sets + 4 ads in one upload (subject to the un-grey workaround in step 1).

### Step 1 — Un-grey the "Import ads in bulk" button

Meta greys this menu item out when the ad account has zero existing campaigns. Two ways past it (pick one):

**Option A (recommended, faster):** Create the CWDB campaign object manually first.
1. Ads Manager → **Create** (green button, top left of Campaigns tab)
2. Objective: **Leads**
3. Campaign name: `CWDB — Leads — Launch 2026-04`
4. Special ad categories: NONE
5. Buying type: AUCTION
6. Continue → reach the ad set step → **don't fill anything else** → click **Save as draft** or close out
7. Confirm campaign exists in Campaigns view (will show as Paused / Draft)
8. Now go to More → **Import ads in bulk** — should be clickable

**Option B (workaround):** Create a throwaway $1/day stub campaign (any objective, paused), un-grey the menu, bulk-import, then delete the stub.

Option A is cleaner because the bulk import will then ADD ad sets and ads UNDER the existing campaign rather than create a duplicate.

### Step 2 — Upload the 6 PNG creatives

In the Bulk Import dialog (after step 1), there's an **Images** drag-drop section. Drop in all 6 PNG files from `marketing/launch-2026-04/creatives/meta/`:

```
problem-solution-1080x1080.png
problem-solution-1080x1350.png
process-proof-1080x1080.png
process-proof-1080x1350.png
seasonal-urgency-1080x1080.png
seasonal-urgency-1080x1350.png
```

Meta auto-hashes them and matches against the `Image File Name` column in the CSV. The CSV currently references the 1080×1080 variants only — Meta will request the 1080×1350 portrait variants automatically when the ad serves on Reels/Stories.

### Step 3 — Upload the CSV

In the same dialog, **drag-drop or click "Upload"** for `10-meta-bulk-import.csv` (or paste contents into the text area).

Meta validates and shows a preview. Resolve any errors (most likely warnings: "Geo targeting empty" — that's expected, see step 4). Click **Publish to drafts** (NOT direct-publish — keep paused).

### Step 4 — Manual UI configuration after import (~10 min)

The CSV intentionally omits ~6 settings that are either too finicky to encode reliably or require account-specific values. For each ad set, in the UI:

**For both AS1 and AS2:**
1. **Geo:** Locations → Wausau, Wisconsin → +20 mi radius. Add explicit ZIPs: 54401, 54403, 54474, 54476, 54455, 54452.
2. **Pixel + Conversion event:** Conversion location = Website. Pixel = `1276568654662913` (`cwdeckbuilders.com`). Event = **Lead**. Attribution = 7-day click + 1-day view (default).
3. **Placements:** Advantage+ Placements (default — should be already on).

**For AS1 only (manual core targeting):**
4. **Detailed targeting (INCLUDE, OR):** Home improvement, Home & garden, Patio, Backyard, Outdoor living, Landscaping, HGTV, The Home Depot, Lowe's, DIY
5. **Narrow audience (AND):** Engaged Shoppers OR Likely Movers
6. **Demographics:** Homeowners + Household income top 50% in area
7. **Exclude:** Renters

**For AS2 only (Advantage+):**
4. Detailed targeting suggestions: OFF (Meta auto-optimizes)
5. Exclude: Renters

### Step 5 — Verify all 4 ads built

In Ads Manager → Ads tab, confirm:
- 4 ads, all PAUSED
- AS1 → Problem Solution + Process Proof
- AS2 → Problem Solution (control) + Seasonal Urgency
- Each ad shows the correct creative thumbnail (from your image upload)
- URL Tags resolve correctly when previewed

### Realistic time savings for Meta

- **Manual UI path:** ~25–30 min for fresh-account first launch
- **Bulk path:** ~5 min (campaign stub) + 2 min (image upload) + 3 min (CSV upload) + 10 min (geo + targeting per ad set in UI) = **~20 min total**
- **Net savings:** ~5–10 min on first launch. Bigger wins on subsequent campaign launches/refreshes (most settings carry over via duplicate, and the CSV becomes your reusable template).

### Why Meta bulk savings are smaller than Google

Meta's bulk-import schema can't reliably express:
- The per-ad-set geo radius + ZIP combo (formats vary)
- Custom interest stacks with AND/OR/NARROW logic
- Pixel + custom-conversion-event attachment

So those settings stay manual. The bulk path still wins on the 30+ paste-heavy fields per ad (Title, Body, Link Description, URL Tags, etc.) — that's where the time goes.
