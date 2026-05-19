---
type: walkthrough
dept: operations/automation
created: 2026-05-05
status: ready-to-execute
audience: Jim (or anyone w/ HubSpot Super Admin)
estimated_time: 25 min
prereqs: All shipped 2026-05-05 (pipeline live, properties live, form relay live, 5 contacts already captured)
companion_spec: 04-lead-routing-workflow-spec.md
---

# WB-001 — Jim's HubSpot Workflow Clicks

> **TL;DR.** 5 sections, ~25 minutes. You will build one Contact-based workflow that turns every form submission into a routed Deal + notification email. After this is live, future leads automate end-to-end. The 5 existing hand-built deals are NOT touched.

## Before you start (1 min)

- Open https://app.hubspot.com in Chrome (not Safari — Workflow editor lags on Safari).
- Confirm top-left account selector reads **CWDB / 245712220**.
- Have this doc open in a second window. Each step ends with an **Acceptance check** so you can confirm you're on track before clicking Next.

---

## Section 1 — Open the Workflow editor (2 min)

1. Left nav → **Automations** → **Workflows**.
2. Top-right → **Create workflow** → **From scratch**.
3. Modal "What type of workflow?" → choose **Contact-based** → click **Next**.
4. Top-left, click the workflow name (currently "Untitled workflow") → rename to:

   ```
   Homeowner Lead Routing — v1
   ```

5. Top-right gear icon → **Settings** → set Description:

   ```
   Form submit → Create Deal in Homeowner Leads at New Lead → Notify Jim
   ```

   → click **Save**.

**Acceptance check:** Workflow canvas is open, named "Homeowner Lead Routing — v1", with one empty enrollment-trigger box at top.

---

## Section 2 — Enrollment trigger (3 min)

> We want this to fire on form submission, NOT on a property change. Form submission gives us the full payload + lets returning homeowners re-enroll for a new deal.

1. Click the empty **Set enrollment triggers** box.
2. Right panel → filter type list → click **Form submission**.
3. Form dropdown → search "Quote" → select **Quote Request** (the form with GUID `bb473d64-06b1-4311-8e02-7c70d605b79b` — should be the only Quote Request form in the account).
4. Page dropdown → **Any page** (relay can fire from any page on cwdeckbuilders.com).
5. Click **Apply filter**.
6. Bottom of right panel → toggle **Re-enrollment** → **ON** → check the box "Form submission" under "Re-enroll contacts when they meet…" → click **Save**.

**Acceptance check:** Trigger box now reads "Filled out form: Quote Request on any page". Re-enrollment toggle is green/on.

---

## Section 3 — Action 1: Create the Deal (5 min)

1. Click the **+** below the trigger box.
2. Right panel → search "Create record" → click **Create record**.
3. Object to create → **Deal** → click **Next**.
4. Fill the property panel exactly as below. Most properties accept **personalization tokens** — click the curly-brace icon `{ }` next to the field to insert tokens.

| Property | Value | How |
|---|---|---|
| **Deal name** | `[firstname] [lastname] — [project_type] — [source_city]` | Click `{ }` → search "First name" → insert. Type a space, then ` — `, then `{ }` → "Last name" → insert. Continue for each segment. |
| **Pipeline** | `Homeowner Leads` | Dropdown |
| **Deal stage** | `New Lead` | Dropdown (only New Lead, Qualified, etc. should appear once Homeowner Leads is selected) |
| **Amount** | `1000` | Type literal number — fixed referral fee per contractor agreement |
| **Close date** | `60 days from now` | Click `{ }` → "Date math" → "Today" → "+ 60 days" → insert |
| **Deal owner** | `Jim Slogar` | Dropdown |

5. **CRITICAL — Association toggle:** Scroll to bottom of the create-record panel. You'll see "**Associate this deal with the enrolled record?**" → set to **YES**. This is what auto-links the new Deal to the submitting Contact.
6. Click **Save**.

**Acceptance check:** Action box now reads "Create deal" with a sub-line showing pipeline = Homeowner Leads, stage = New Lead. The association toggle is on.

> If the dash character — disappears or becomes a hyphen, that's fine — HubSpot's token concat sometimes strips Unicode. Acceptable for v1.

---

## Section 4 — Action 2: Send notification email to Jim (10 min)

1. Click the **+** below the Create-deal action.
2. Right panel → search "Send internal" → click **Send internal email notification**.
3. **From:** leave default (HubSpot system).
4. **To:** type `slogarjw@gmail.com` → press Enter to confirm chip.
5. **Subject:**
   ```
   New CWDB Lead: {{contact.firstname}} — {{contact.source_city}}
   ```
   (Use `{ }` token picker — do not type `{{...}}` literally; HubSpot's UI inserts the right format.)
6. **Body:** Click into the body editor → paste the block below → use `{ }` icon to swap each `[TOKEN: ...]` placeholder for the matching contact token. If the editor is in rich-text mode, switch to plain text first (toolbar → ⋯ → "Source code" or similar).

   ```
   New homeowner lead just submitted the quote form.

   NAME: [TOKEN: First name] [TOKEN: Last name]
   EMAIL: [TOKEN: Email]
   PHONE: [TOKEN: Phone Number]
   ADDRESS: [TOKEN: Street Address]
   ZIP: [TOKEN: Postal Code]
   CITY: [TOKEN: Source City]

   PROJECT TYPE: [TOKEN: Project Type]
   BUDGET: [TOKEN: Budget Range]
   TIMELINE: [TOKEN: Project Timeline]
   OWNS PROPERTY: [TOKEN: Owns Property]
   TCPA CONSENT: [TOKEN: TCPA Consent Given]

   NOTES: [TOKEN: Lead Notes]

   ATTRIBUTION:
     utm_source: [TOKEN: UTM Source]
     utm_campaign: [TOKEN: UTM Campaign]
     gclid: [TOKEN: GCLID]
     page: [TOKEN: Lead Source Page]

   Open contact in HubSpot:
   https://app.hubspot.com/contacts/245712220/contact/[TOKEN: Record ID]

   Action needed:
     1. Call homeowner within 5 minutes (speed-to-lead).
     2. Forward to matched contractor:
          Wausau / Schofield / Weston → Ben Barton
          Mosinee / Merrill          → John Garcia
          Other / overlap            → both
     3. Update Deal stage in HubSpot when contractor confirms acceptance.
   ```

7. Click **Save**.

**Acceptance check:** Action box reads "Send internal email notification — to slogarjw@gmail.com". If you click into it, all the tokens render as colored chips, not as `[TOKEN: ...]` literals.

> If a token chip won't insert because the property isn't found: that property's internal name is wrong. All 11 contact properties + 8 deal properties were verified live earlier today (search HubSpot for the property label exactly as listed in the table above). If a token still 404s, ping back — likely a property internal-name typo in the spec.

---

## Section 5 — Activate + smoke test (5 min)

### 5a. Review + activate (2 min)

1. Top right → **Review and publish**.
2. Modal asks "Run actions for existing contacts who currently meet the trigger?" → **NO** (we don't want the 5 existing hand-built contacts re-running).
3. Click **Turn on**.

**Acceptance check:** Top-right status pill reads **ON / Active** in green.

### 5b. Smoke test (3 min)

1. Open **incognito/private** window → https://cwdeckbuilders.com/get-a-quote
2. Submit the form with these test values:

   | Field | Value |
   |---|---|
   | First name | `WorkflowTest` |
   | Last name | `Smoke` |
   | Email | `workflow-test-{paste current Unix timestamp}@cwdb-internal.test` (any unique string works — we'll delete after) |
   | Phone | `715-555-0199` |
   | Address | `123 Test St` |
   | Zip | `54401` |
   | Project type | `New Deck` |
   | Budget | `$10K-$20K` |
   | Timeline | `1-3 months` |

3. Within **30 seconds**, check:
   - HubSpot → Contacts → search "WorkflowTest" → contact exists with all 11 lead fields populated.
   - HubSpot → Deals → Homeowner Leads pipeline → new Deal at "New Lead" with name "WorkflowTest Smoke — new-deck — Wausau" (or similar).
   - On the new Contact → **Deals tab** → the new Deal is associated.
   - slogarjw@gmail.com inbox → notification email arrived with all tokens populated (not blank, not literal `{{contact.x}}`).

### 5c. Clean up smoke-test data (1 min)

After verifying all 4 above:
1. Open the WorkflowTest contact → top right ⋯ menu → **Delete contact** → confirm. (HubSpot will offer to also delete the associated deal — accept.)
2. Confirm WorkflowTest is gone from both Contacts and Deals views.

---

## If something fails

**Trigger doesn't fire on smoke test.** Check Automations → Workflows → Homeowner Lead Routing — v1 → **History** tab → does WorkflowTest appear as enrolled? If not, the form-submission filter didn't match. Re-open Section 2 and confirm Form = "Quote Request" exactly.

**Deal created but not associated to Contact.** Section 3 step 5 (association toggle) was missed. Edit the Create-deal action, flip toggle to YES, save. Re-run smoke test.

**Email arrived but tokens are literal `{{contact.x}}`.** Body was edited as plain text and tokens were typed instead of inserted via `{ }` picker. Edit action, click into body, replace each literal with a real chip via the picker.

**Email never arrived.** Check spam first. Then verify in workflow History → click the smoke-test enrollment → expand "Send internal email" step → check for "Skipped" or "Errored" status. Most common cause: HubSpot has the email property unconfirmed. Check `slogarjw@gmail.com` is verified in Settings → Account Defaults.

## Rollback

If anything misbehaves on a real lead post-launch:
1. Top-right toggle → **OFF**. Workflow stops; form submissions still create Contacts (form relay is independent).
2. Manual handling resumes: watch Gmail for HubSpot's native form-submit notification, manually create Deal.

## What this unblocks

Once verified live with one real form submission:
- Native HubSpot ↔ Google Ads offline conversion sync (Settings → Integrations → Google Ads → "Send conversions when Deal stage = Accepted Bid")
- Native HubSpot ↔ Meta sync (same pattern, Meta integration)
- WB-011 becomes more valuable (closed-loop revenue per channel)
- Meta launch unblocks (was waiting on attribution pipeline)

## v2 backlog (do not build today)

- Routing branch on `source_city` → set `matched_contractor` automatically
- TCPA gate (skip notification if `tcpa_consent_given = false`)
- Lead score calc + populate `lead_score` on Deal
- Stage automation: at Accepted Bid → set `referral_fee_invoiced_at` + trigger invoice
- SMS to contractor (HubSpot SMS add-on or Twilio bridge)

---

## Done?

When all acceptance checks in Section 5 pass, ping back. CEO operator will:
1. Move WB-001 from `_vault/board/in-flight.md` → `_vault/board/shipped.md`
2. Update `_vault/board/INDEX.md` stage column → `shipped`
3. Tag with ship type `scheduled-recurring-automation`
