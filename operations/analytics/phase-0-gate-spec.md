---
type: spec
dept: operations/analytics
created: 2026-04-30
updated: 2026-04-30
status: ready-for-execution
owner: cwdb-ceo-operator
gate_blocks: ["Webflow → HubSpot wiring", "Native ad-platform offline conversion sync"]
gate_passes_to: hubspot-webflow-native-plan.md §3 build sequence
---

# Phase 0 Gate — Webflow → HubSpot Tracking Script Intercept

> **The ONLY remaining verification gate.** Yesterday's HubSpot Starter purchase resolved 3 of 4 prior gates instantly (native Google Ads + Meta + GA4 paths confirmed available at this tier). This is the one that survives.
>
> **Question under test:** Will HubSpot's "Non-HubSpot Forms" tracking script intercept the existing Webflow native form on `/get-a-quote`, capturing the submission as a HubSpot Contact — without breaking the form's current behavior (iOS-Safari-friendly submit + URL-param prefill + `info@cwdeckbuilders.com` email delivery)?
>
> **Why it matters:** If yes, we keep the 2026-04-28 form rebuild intact and just add tracking. If no, we fall back to either (a) HubSpot Forms API direct fetch from the submit handler, or (b) embedding HubSpot's hosted form (which kills the rebuild). Significant work-volume difference downstream.

---

## §1 The 30-minute test (Jim or web-dev runs)

### 1.1 Install the tracking script

In HubSpot:

1. Settings (gear) → Tracking & Analytics → **Tracking Code**.
2. Copy the script. It looks like:

```html
<!-- Start of HubSpot Embed Code -->
<script type="text/javascript" id="hs-script-loader" async defer src="//js.hs-scripts.com/<HUBID>.js"></script>
<!-- End of HubSpot Embed Code -->
```

3. Replace `<HUBID>` is auto-baked in (it's Jim's portal ID = `245712220` per current HubSpot session).

In Webflow:

4. **Recommended path: GTM tag, not direct site head paste.** Reason: keeps the Tag Manager as single source of truth for all third-party scripts; allows enable/disable toggling without redeploys; allows firing rule control if needed later.
5. GTM → Tags → New → "Custom HTML" tag.
   - **Name:** `HubSpot — Tracking Code`
   - **HTML:** Paste the snippet from step 2.
   - **Trigger:** All Pages.
   - Save.
6. GTM Preview mode → load `https://www.cwdeckbuilders.com/get-a-quote`.
7. Verify the tag fires (visible in Tag Manager Preview's "Tags Fired" pane).
8. Verify in browser DevTools → Network: a request to `js.hs-scripts.com/245712220.js` is made and returns 200.

**Fallback if GTM has issues:** Paste the snippet directly into Webflow → Site Settings → Custom Code → Footer code. Less elegant; works.

### 1.2 Enable Non-HubSpot Forms collection in HubSpot

In HubSpot:

1. Settings → Tracking & Analytics → Forms (or under Marketing → Forms → "Non-HubSpot forms" tab depending on UI build at time of test).
2. Toggle **"Collect data from non-HubSpot forms"** to ON.
3. **Critical sub-setting:** Some HubSpot UIs require explicitly listing form CSS selectors or domains. Whitelist `www.cwdeckbuilders.com` and the form selector if prompted (form is likely at `form#wf-form-Get-A-Quote-Form` or similar — Jim/web-dev confirms the actual ID via DevTools).
4. Save.

### 1.3 Submit a test lead

1. Open `https://www.cwdeckbuilders.com/get-a-quote` in a fresh incognito window (no HubSpot tracking cookies to confuse the test).
2. Fill the form with test data:
   - Name: `Phase 0 Test`
   - Email: `phase0test+<timestamp>@slogarjw.com` (or any inbox you control)
   - Phone: `(715) 555-0100`
   - Address: `100 Test St, Wausau, WI 54401`
   - Project type: any
   - Notes: `Phase 0 Gate Test — Non-HubSpot Forms intercept verification 2026-04-30`
3. Submit.
4. **Expected:** form succeeds, redirect to thank-you page, email delivers to `info@cwdeckbuilders.com` (this verifies we didn't break the existing pipe).

### 1.4 Verify HubSpot capture

1. HubSpot → Contacts → Sort by Created descending.
2. **Pass:** the test contact appears within ~5 minutes with name + email + phone populated, plus a "Form submission" entry on the activity timeline pointing back to `/get-a-quote`.
3. **Fail:** no contact appears OR contact is missing key fields OR submission shows up disconnected from the form-source URL.

---

## §2 Pass / Fail decision tree

### PASS criteria (ALL must be true)

- [ ] HubSpot tracking script loads on `/get-a-quote` (Network tab confirms)
- [ ] Existing form submission still triggers email to `info@cwdeckbuilders.com` (no regression)
- [ ] Existing form prefill from URL params still works (`?zip=54401&phone=...` populates)
- [ ] Test contact appears in HubSpot Contacts within 5 minutes
- [ ] Contact has email, phone, name fields populated correctly
- [ ] Activity timeline shows form-source URL = `/get-a-quote`

If all 6 pass → proceed to next session's wiring step. **No code changes required to the existing form.** Net work to ship the integration: just the workflow + ad-platform sync wiring.

### FAIL → Plan B

If 1–3 of the criteria fail (especially "contact appears" or "fields populated"), the most likely cause is HubSpot's Non-HubSpot Forms feature not finding/parsing the Webflow form's HTML structure. This was a known issue with non-standard form markup pre-2025; status in 2026 is uncertain.

**Plan B (Forms API direct fetch):**

1. Create a HubSpot Form in Marketing → Forms → Create form. Name it `cwdeckbuilders Get a Quote — Mirror`. Configure fields to match the Webflow form 1:1 (same internal names).
2. Capture the Form GUID from the URL after save.
3. Add a `fetch()` POST inside the existing Webflow form submit handler (the same script that does `hero_form_handoff`). Endpoint:

```
POST https://api.hsforms.com/submissions/v3/integration/submit/245712220/<FORM_GUID>
Content-Type: application/json

{
  "fields": [
    { "name": "email", "value": "<form value>" },
    { "name": "firstname", "value": "<form value>" },
    { "name": "phone", "value": "<form value>" },
    ...
  ],
  "context": {
    "pageUri": "https://www.cwdeckbuilders.com/get-a-quote",
    "pageName": "Get a Quote"
  }
}
```

4. The fetch is fire-and-forget; it does NOT block the form's existing submit-to-Webflow → email pipe. If the HubSpot POST fails, the email still delivers. **Two channels, one source.**
5. Re-run §1.3 + §1.4 to verify capture.

**Plan B is more code than Plan A** (the tracking script approach), but it's still <1 hour of web-dev work and zero infrastructure beyond what's in the page already. It does NOT require Workers, Lambda, Make, or any third-party service.

### FAIL → Plan C (escalation)

Plan C kicks in only if Plan B's Forms API endpoint is gated behind a HubSpot tier higher than Starter. The HubSpot docs say Forms-only is included in all tiers; verify before despairing. If it really is gated:

- Embed a HubSpot hosted form on `/get-a-quote` and replace the Webflow form. Kills the 2026-04-28 rebuild. Last resort.
- Or wire Webflow form → Webflow Logic → HubSpot. Webflow Logic is its own paid product. Not ideal.

---

## §3 Time-box

- §1.1 + §1.2 (install + enable): 15 min
- §1.3 (submit test lead): 2 min
- §1.4 (verify): 3 min
- Decision + report: 10 min

**Total: 30 min, hard cap.** If the test takes longer than that, document where it broke and surface in Outbox — don't extend.

---

## §4 What this unblocks

- **PASS:** Webflow → HubSpot wiring done in ~0 hours (script-only). Native HubSpot ↔ Google Ads + Meta sync setup proceeds. Workflow build proceeds. End-to-end native lead routing live within ~3-4 hours of agent work.
- **FAIL → Plan B:** Add ~1 hour for Forms API integration. Same downstream dependencies.
- **FAIL → Plan C:** Add ~3-4 hours for form replacement. Significant downstream regression risk (re-test iOS Safari, prefill behavior, email delivery — the 2026-04-27 form-rebuild work re-litigated).

---

## §5 Owner

- **Test executor:** web-dev agent (when Agent tool available) OR Jim directly via the GTM + HubSpot UIs.
- **Decision authority:** Jim (final pass/fail call).
- **Reporter:** CEO updates state file §3 Queue + §6 Dashboard with result.
