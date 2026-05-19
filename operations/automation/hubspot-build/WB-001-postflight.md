---
type: post-flight-checklist
dept: operations/automation
created: 2026-05-07
companion_to: WB-001-jim-clicks.md
status: ready-to-run
estimated_time: 5 min after workflow activation
---

# WB-001 — Post-Flight Verification (5 min after workflow goes live)

> Use this checklist immediately after toggling the workflow ON in Section 6 of `WB-001-jim-clicks.md`. Each step has a pass/fail criterion. If any step fails, the rollback at the bottom restores Day-N+1 state.

## Why this exists

The walkthrough's Section 7 verification step is a single "submit a test form, see if it lands." That's correct but coarse. This file decomposes it into 6 atomic checks against the **5 already-existing real contacts** in HubSpot, plus 1 fresh smoke submit. Catching an issue here costs 5 minutes; catching it after the next real lead arrives costs trust.

## Pre-conditions

- [ ] Workflow `Homeowner Lead Routing — v1` toggled **ON** (top-right of workflow canvas, must be green).
- [ ] "Run actions for existing contacts who meet the trigger" set to **OFF** (this is critical — see warning at bottom).
- [ ] You have HubSpot open in one tab, this checklist in another.

## Smoke test (3 min)

### Step 1 — Submit a fresh test form

In a private/incognito window:

1. Open https://www.cwdeckbuilders.com/get-a-quote
2. Fill: First name `WB001Test`, Last name `Verify-2026-05-07`, Email `wb001-verify-{timestamp}@example.com` (replace timestamp with current 4-digit clock e.g. `0830`), Phone `(715) 555-0107`, ZIP `54401`, Project type `new-deck`, Budget `20k-35k`, Timeline `1-3-months`, Owns `Yes`
3. Submit. Expect redirect to /thank-you.

### Step 2 — Within 60 seconds, verify Contact created

Path: HubSpot → Contacts → search `wb001-verify-` → click the new Contact.

| Property | Expected | Pass? |
|---|---|---|
| Contact exists | yes | [ ] |
| First name | `WB001Test` | [ ] |
| Last name | `Verify-2026-05-07` | [ ] |
| Phone | `(715) 555-0107` | [ ] |
| ZIP | `54401` | [ ] |
| `source_city` | `Wausau` (auto-populated from ZIP) | [ ] |
| `project_type` | `new-deck` | [ ] |
| `budget_range` | `20k-35k` | [ ] |
| `project_timeline` | `1-3-months` | [ ] |
| `owns_property` | `Yes` | [ ] |
| `tcpa_consent_given` | `true` (implicit on submit) | [ ] |

If any FAIL: the relay or form is broken, not the workflow. Workflow is fine — escalate to relay debug.

### Step 3 — Within 60 seconds, verify Deal created

Path: HubSpot → Deals → Pipeline `Homeowner Leads` → New Lead column.

| Field | Expected | Pass? |
|---|---|---|
| Deal exists in `New Lead` (stage `3610478270`) | yes | [ ] |
| Deal name contains `WB001Test Verify-2026-05-07` and `new-deck` and `Wausau` | yes | [ ] |
| Pipeline | `Homeowner Leads` (id `2247158458`) | [ ] |
| Amount | `1000` | [ ] |
| Close date | ~60 days from today | [ ] |
| Deal owner | Jim Slogar | [ ] |

If any FAIL: workflow Step 3 (Create Deal action) is misconfigured. Re-open workflow, double-click Create Deal action, check property tokens.

### Step 4 — Verify Deal ↔ Contact association

Path: open the Contact from Step 2 → right rail → **Deals** card.

| Check | Expected | Pass? |
|---|---|---|
| Deal from Step 3 appears in Contact's Deals card | yes | [ ] |
| Contact appears in Deal's Contacts card (open Deal, check right rail) | yes | [ ] |

If FAIL: Section 4 of walkthrough — "Associate this deal with the enrolled record" — was not set to Yes. Re-edit workflow.

### Step 5 — Verify notification email at slogarjw@gmail.com

Within 60 seconds of submit:

| Check | Expected | Pass? |
|---|---|---|
| Email arrives at slogarjw@gmail.com | yes | [ ] |
| Subject: `🔔 New CWDB Lead: WB001Test — Wausau` | yes | [ ] |
| Body shows all 11 contact properties (no `{{tokens}}` left unrendered) | yes | [ ] |
| HubSpot deal-link in body works | yes | [ ] |

If FAIL: workflow Step 5 (notification email action) is misconfigured. Most likely: token names typed wrong (must match Internal Names in `02-contact-properties.csv`), or recipient email field misspelled.

## 5 existing contacts NOT re-enrolled (1 min)

Per "Run actions for existing contacts who meet the trigger" = **OFF**, the 5 real contacts from 2026-05-05 (Hanus, Gundersen, Waldman, Keuler, Nayak) should NOT have new auto-built Deals after activation.

Path: HubSpot → Deals → Homeowner Leads pipeline → confirm only the **6** deals exist (5 hand-built + 1 fresh smoke test), NOT 11 (which would mean re-enrollment fired).

| Check | Expected | Pass? |
|---|---|---|
| Total deals in `Homeowner Leads` pipeline = 6 (5 prior + 1 smoke) | yes | [ ] |

If 11 deals appear: workflow re-enrolled the existing 5. **Roll back immediately** (see below) and clean up the 5 duplicate deals.

## Rollback path (if anything fails)

If any FAIL above leaves the workflow in a broken state:

1. **Toggle workflow OFF** (top-right of workflow canvas, must turn grey).
2. Form submissions still create Contacts (the relay → HubSpot Form path is independent of the workflow).
3. **Manual lead handling resumes:** Jim watches slogarjw@gmail.com for the form's native HubSpot notification email, calls homeowner, hand-builds Deal (same pattern as the 5 existing deals).
4. Open a comment in `_vault/board/in-flight.md` under `[WB-001]` describing what failed (Step #N + symptom), and the CEO operator picks it up next session.

## After full pass

1. Add `[x]` to the `[WB-001]` line in tomorrow's brief Top-3 with `%done — smoke test green at HH:MM, all 6 checks pass%`.
2. Move `[WB-001]` from `_vault/board/in-flight.md` → `_vault/board/shipped.md`.
3. **Delete the smoke-test Contact + Deal** to keep HubSpot clean (Contacts → search `wb001-verify-` → delete; same for Deal).
4. Memorize: relay is verified working as of `<datetime>`. Future drought hypotheses can rule out fork (b) of `_vault/experiments/2026-05-07-volume-drought/b-smoke-test.md` for ~7 days.

## Standing warning

> The "Run actions for existing contacts who meet the trigger" toggle is in Section 6 of the walkthrough. If you flip it ON by accident, the workflow will create 5 NEW deals associated to the 5 existing real contacts, on top of the 5 deals already manually built. Result: 10 deals for 5 leads. To recover: workflow OFF, then manually delete the 5 auto-built dupes (compare createdate timestamps; the dupes will all share the workflow-fire timestamp).
