---
name: Meta Pixel Deletion Walkthrough — pixel 4411592295757520
description: Step-by-step manual UI walkthrough Jim uses to delete the wrong-account Meta pixel after Phase F account-identity audit. Includes unassign-from-ad-accounts step which is the gate Meta enforces before allowing deletion.
type: project
---

**Goal:** Permanently remove Meta pixel `4411592295757520` (named `CWDB`, set up in wrong account during Phase F 2026-04-18). Keep `1276568654662913` (named `cwdeckbuilders.com`) as the canonical pixel — it's the one referenced in GTM Tag 1 and `marketing/launch-2026-04/04-meta-copy.md`.

**Why:** Removes future paste-the-wrong-ID risk before WS-1 Phase A ships the CAPI endpoint. Once a serverless endpoint is firing server-side events to a Meta pixel ID, having a stale duplicate around will cause a real misfire some day.

**Why this can't be done via MCP:** Destructive in production. Same reason ad-account deletions, page deletions, and DocuSign template removals are all gated to manual UI — one wrong click and the wrong asset is gone. Jim executes; the CEO writes the click path.

---

## Pre-flight (CEO does this BEFORE Jim opens the UI)

The Meta UI will not let you click "Remove" on a pixel that has any active assignments to ad accounts. If you click delete and nothing happens, **that's the cause** — the Remove button greys out (or the action no-ops silently). You unassign first, then delete.

The CEO has not yet pre-checked this via MCP because the available Meta MCP surface (Webflow, HubSpot, Make, Google Drive, Gmail, Calendar) does NOT include a Meta Marketing API client. The check is part of Step 1 below — if the pixel has zero ad accounts assigned, Step 1 is a no-op and you skip straight to Step 2.

---

## Step-by-step (do this on desktop — easier than mobile for the asset selector chrome)

### Step 1 — Confirm pixel ID and check for ad-account assignments

1. Go to `business.facebook.com`
2. Confirm you're in the correct Business Manager — **`Central Wisconsin Deck Builders`** (NOT your CPA work account, which is where the wrong-account pixel originally got created during Phase F).
   - Top-left of the page: Business name dropdown. If it says anything other than CWDB, click and switch.
3. Click the gear icon (Settings, lower-left) → **Business settings**.
4. In the left sidebar: **Data Sources** → **Datasets** (Meta renamed "Pixels" → "Datasets" mid-2024; the pixel asset is now technically a "dataset"). If you don't see "Datasets", look for **Pixels** — older accounts still show the legacy label.
5. You should see two assets in the list:
   - `CWDB` — ID `4411592295757520` ← **THIS IS THE ONE TO DELETE**
   - `cwdeckbuilders.com` — ID `1276568654662913` ← KEEP THIS ONE
6. Click on `CWDB` (`4411592295757520`) to open its detail panel.
7. Look at the right side of the panel — there should be tabs/sections for **People**, **Connected assets**, **Ad accounts**, **Apps**.
   - Click **Ad accounts** (or **Connected assets** if that's the only tab).
   - **If the list is empty** → skip to Step 2.
   - **If any ad accounts are listed** → continue Step 1.
8. For each ad account in the list:
   - Click the three-dot menu (`⋯`) at the right of that ad account row
   - Click **Remove ad account** (or **Disconnect**)
   - Confirm in the popup
9. Repeat until the Ad accounts list is empty.

### Step 2 — Delete the pixel

1. Make sure `CWDB` (`4411592295757520`) is still selected in the Datasets list (left side of Business settings).
2. Look at the **top-right** of the detail panel for one of these:
   - A three-dot menu (`⋯`) — click it; the dropdown should now show **Remove** or **Delete**.
   - A **Remove** button directly visible (no menu) — click it.
   - **If neither appears**, the pixel still has an assignment somewhere — Meta sometimes hides the Delete option when even one app, person, or ad account is connected. Re-check the **People** and **Apps** tabs (Step 1.7) and unassign anything found there.
3. A confirmation modal will appear: "Are you sure you want to remove this dataset?" — click **Remove** / **Delete** / **Confirm**.
4. The pixel disappears from the Datasets list.
5. Refresh the page to confirm — only `cwdeckbuilders.com` (`1276568654662913`) should remain.

### Step 3 — Verify

1. Back in the Datasets list, confirm only `cwdeckbuilders.com` remains.
2. (Optional belt-and-suspenders) Open Events Manager (top-left waffle menu → **All tools** → **Events Manager**). Confirm only one pixel is listed there too. Sometimes Events Manager is the more reliable list view than Business Settings.

### Step 4 — Tell the CEO it's done

Drop `%done — only cwdeckbuilders.com (1276568654662913) remains%` (or similar) on the queue item. CEO will drop the item to wins on the next `/state` run.

---

## If you get stuck

- **"Remove" button is greyed out / nothing happens on click:** Step 1 wasn't fully completed — there's still an assignment. Re-check ad accounts, people, and apps tabs.
- **Can't find the pixel:** You're in the wrong Business Manager. Confirm the top-left dropdown says `Central Wisconsin Deck Builders`. If both pixels were created in your CPA work BM, switch there.
- **Pixel name doesn't match:** Verify by ID, not name. ID `4411592295757520` is the one to delete. Names are user-editable; IDs are immutable.
- **Bail criteria:** If anything looks off (wrong number of pixels, ID doesn't match, deletion popup says "this will affect [X] active campaigns"), STOP and ping the CEO. Better one extra session than deleting the wrong asset.

---

## Architectural note

Once this pixel is deleted, `1276568654662913` becomes the single source of truth for both browser-side (GTM Tag 1) and server-side (WS-1 Phase A CAPI endpoint, when it ships). No ambiguity, no risk of writing CAPI code that targets the wrong asset.

This walkthrough is also referenced in `_vault/state-of-cwdb.md` Outbox echo for the session that surfaces the pixel-delete carry.
