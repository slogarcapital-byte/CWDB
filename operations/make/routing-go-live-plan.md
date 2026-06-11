# Routing Scenario Go-Live Plan (Make TEST scenario to LIVE)

- **Status:** PLAN ONLY. Nothing in this document has been executed. The go-live action is Tier 2 and requires its own approval in `approval_queue` before any step below is performed.
- **Authored by:** control-loop task #56 (trace e05340dec806), artifact-only task, 2026-06-11
- **Basis:** approved-but-not-yet-executed TEST build plan in Supabase `approval_queue` approval_id 1 (task_id 2, status `approved`, expires 2026-06-17), plus `operations/make/webhooks.json`, `operations/leads/routing-rules.json`, and warehouse schema 001/005.

---

## 1. Purpose

Take the TEST routing scenario (a stripped clone of parked Make scenario 4792854) live for real homeowner leads, so that every qualified webform lead produces:

1. A `fact_leads` row in the Supabase warehouse (upsert, idempotent).
2. A `pending` `fact_bids` row (the canonical homeowner deal record).
3. An immediate notification so follow-up starts within the 5-minute delivery SLA (`operations/leads/routing-rules.json`, `delivery_sla_minutes: 5`).

No real lead has ever been routed (zero `fact_bids` rows for any real lead as of 2026-06-11). This go-live closes the "Deliver first lead via routing" Phase 1 step.

## 2. Preconditions (must ALL be true before go-live is approved)

| # | Precondition | How to verify |
|---|---|---|
| P1 | TEST scenario exists and passed its self-test | Approval_id 1 steps executed: test webhook fired with `utm_source=test`, email `routing-selftest@cwdb-internal.test`; pending `fact_bids` row appeared; `v_clean_leads` count for the test email = 0; `v_validation_gate.gate_met` unchanged; test rows deleted afterward. As of this writing the TEST build is approved but NOT yet executed (`tier2_execution_enabled=false` in Inc 1; needs Inc 3 or a manual lead-routing run). |
| P2 | New scenario id + module chain documented | `operations/make/webhooks.json` updated with the TEST scenario id (per the final step of approval_id 1). Parked scenario 4792854 left unchanged. |
| P3 | Supabase service-role key stored as a Make connection/keychain item, not inline in module config | Make scenario inspection. |
| P4 | `v_clean_leads` exclusions verified current | View excludes `utm_source IN ('test','routing-selftest')` and `slogarjw@gmail.com` (migrations views/003 and the routing-selftest fix). |
| P5 | Notification recipient decision made (see Section 8, D1) | Tier-2 approval payload states the recipient(s). |
| P6 | Separate Tier-2 approval row exists and is approved | `approval_queue` row for the go-live action, status `approved`, not expired. |

## 3. Exact module chain (LIVE scenario)

The live scenario is the TEST scenario plus the re-attached notify branch and per-contractor bid rows, per the `go_live` clause of approval_id 1: "re-attach notify branch, one pending fact_bids per active contractor, repoint Webflow webhook, activate."

| # | Module | App / type | Config |
|---|---|---|---|
| 1 | Inbound trigger | `gateway:CustomWebHook` (the TEST scenario's own hook, NOT parked hook 2183206) | Receives Webflow `form_submission` payload: name, phone, email, address, owner, project_type, budget, timeline, notes, tcpa_consent. |
| 2 | Qualification filter | `util:SetVariables` + Router (Make built-in) | Hard disqualifiers per `operations/leads/scoring-rules.json`: renter, zip not in 54401/54403/54476/54474/54452, invalid US phone, no TCPA consent. Disqualified path: stop after logging the lead (module 3 still runs with a disqualified flag); no notification, no fact_bids row. |
| 3 | Warehouse lead upsert | HTTP module: POST PostgREST `/rest/v1/fact_leads` | Headers `Prefer: resolution=merge-duplicates,return=representation`, service-role auth. Payload includes `lead_channel='webform'`, `tcpa_consent_source='form'`. Returns `lead_id` for downstream modules. |
| 4 | Contractor lookup | HubSpot CRM: Search CRM Objects (contacts), filter `lifecyclestage=customer` | Returns active contractors (currently Ben Barton, HubSpot contact 462464338657, and John Garcia, 465926077160). Fallback rule from routing-rules.json: if zero results, send admin alert to slogarjw@gmail.com with subject `[ACTION REQUIRED] Qualified Lead - No Active Contractors Found` and do not drop the lead. |
| 5 | Iterator | `flow:Iterator` (Make built-in) | One iteration per active contractor from module 4. |
| 6 | Warehouse bid insert | HTTP module: POST PostgREST `/rest/v1/fact_bids` | One row per iteration: `{lead_id, contractor_id: <mapped from dim_contractor>, bid_status: 'pending'}`. Schema 005 allows `pending` status and nullable `contractor_id`; if the HubSpot contact cannot be mapped to a `dim_contractor` row, insert with `contractor_id: null` rather than failing. |
| 7 | Notify branch | Gmail (Send an Email) and/or Twilio (Create a Message) | Recipient per Decision D1 (Section 8). Body: name, city, project_type, budget, timeline, phone, HubSpot link. |
| 8 | Admin summary | Gmail: Send an Email to slogarjw@gmail.com | Subject `[CWDB] Lead routed - [name]`, body lists qualification result, fact_bids row count, notifications sent. |

Error handling: every HTTP module gets a Make error handler route that sends the admin alert email (module 8 template) and does NOT silently swallow the lead. Webhook queue setting: store failed executions for replay (Make incomplete-executions ON).

## 4. Webhook repointing steps

Current state: the Webflow form relays to HubSpot via the Forms API relay JS (client-side). No Webflow native `form_submission` webhook is active; the parked scenario's hook URL (`https://hook.us2.make.com/p4cbbf1lq3bl6lpew6c3odahnrhoc1m4`, hook 2183206) was never pasted into Webflow (see `webhooks.json` status field). The Make webhook is therefore ADDITIVE: the HubSpot relay JS stays untouched.

1. In the TEST scenario, copy the hook URL from its Custom Webhook module (this is a NEW hook, distinct from 2183206).
2. Webflow: Project Settings, Integrations, Webhooks, Add Webhook. Event: `form_submission`. URL: the TEST scenario hook URL. (Account-identity check first: confirm the cwdeckbuilders.com site is selected, per the standing platform-identity rule.)
3. Verify scenario scheduling is set to "immediately" (webhook-triggered scenarios run on receipt).
4. Activate the scenario in Make (`scenarios_activate` or UI toggle).
5. Submit ONE controlled test from the live form using `utm_source=test` and email `routing-selftest@cwdb-internal.test` (both excluded by `v_clean_leads`, so the validation gate cannot be corrupted). Verify modules 1 through 8 execute, then delete the test `fact_bids` and `fact_leads` rows.
6. Leave parked scenario 4792854 INACTIVE and unmodified. It is the reference blueprint only.

## 5. External systems touched (at go-live, not by this doc)

| System | Touch | Detail |
|---|---|---|
| Make | Modify + activate | TEST scenario gains notify branch + iterator + per-contractor bid insert; scenario activated. Team 2073972, org 7086579, folder 231872. Parked scenario 4792854: untouched. |
| Webflow | Modify | One native `form_submission` webhook added in Project Settings (site cwdeckbuilders.com). Existing HubSpot relay JS unchanged. |
| HubSpot | Read (and possibly write) | Read: contractor lookup `lifecyclestage=customer`. Write only if Decision D2 keeps HubSpot contact/deal creation in the chain (the current relay JS already creates the contact; avoid duplicates). Portal 245712220 on NA2. |
| Supabase | Write | PostgREST upsert `fact_leads`, insert `fact_bids` (project iabiwsbmnbxmkjvkgfhg). Reads of `v_clean_leads` and `v_validation_gate` for verification. |
| Gmail / Twilio | Send | Notification and admin summary sends. Twilio requires credentials (TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM_NUMBER) connected in Make; Gmail via Make connection (credential-request inbox: requestId 2cf06b68-55cd-447d-b329-9d459300d7ff). |

## 6. Verification: first REAL fact_bids row

Run after the first real (non-test) form submission post-activation. All queries are read-only against project `iabiwsbmnbxmkjvkgfhg`.

Primary verification query (the DoD query for the first real routed lead):

```sql
SELECT b.bid_id,
       b.lead_id,
       b.contractor_id,
       b.bid_status,
       b.created_at,
       l.email,
       l.utm_source,
       l.lead_channel
FROM   fact_bids  b
JOIN   fact_leads l USING (lead_id)
WHERE  l.lead_id IN (SELECT lead_id FROM v_clean_leads)   -- excludes test/self-test rows
AND    b.bid_status = 'pending'
ORDER  BY b.created_at DESC
LIMIT  5;
```

Pass criteria: at least one row returned whose `email` is NOT `routing-selftest@cwdb-internal.test` and NOT `slogarjw@gmail.com`, `utm_source` is not `test`/`routing-selftest`, and `created_at` is within minutes of the form submission timestamp.

Secondary checks:

```sql
-- Gate integrity: must NOT have flipped because of routing plumbing
SELECT * FROM v_validation_gate;

-- Funnel: delivered count should now be > 0
SELECT * FROM v_lead_funnel;
```

Also verify in Make: execution history for the scenario shows one successful run with all modules green, and the admin summary email arrived at slogarjw@gmail.com.

## 7. Rollback

Rollback target: zero real leads lost, warehouse clean, site form still feeding HubSpot via the relay JS (which never depended on Make).

1. **Deactivate the scenario** in Make (UI toggle or `scenarios_deactivate`). This alone stops all side-effects; the Webflow webhook will get non-consuming posts which Make queues or drops harmlessly while inactive.
2. **Remove the Webflow webhook** (Project Settings, Integrations, Webhooks, delete the `form_submission` entry). Leads continue to reach HubSpot through the relay JS, so no lead is lost during rollback.
3. **Replay or hand-enter any in-flight leads**: check Make incomplete executions queue; for any submission that fired during the broken window, confirm the HubSpot contact exists (relay JS path) and manually create the `fact_leads`/`fact_bids` rows if needed.
4. **Clean bad warehouse rows** (only if the failure wrote garbage): delete the offending `fact_bids` rows first (FK), then `fact_leads`, identified by `created_at` window and `utm_source`. This is a Tier-2 write; log it in `event_log`.
5. **Scenario config restore**: Make keeps scenario version history; restore the pre-go-live blueprint version if module edits caused the failure. Parked 4792854 remains the ultimate reference blueprint.
6. **Record the rollback** in the session note and board (`_vault/board/`), and requeue the go-live task with failure feedback.

## 8. Open decisions for the Tier-2 approval (do NOT default these)

- **D1. Notification recipient.** Approval_id 1's go-live clause predates the 2026-06-10 fulfillment pivot. Under the pivot, Jim owns ALL lead follow-up, walk-through booking, and estimates; Ben/John engage at the estimate hand-off, not at lead arrival. Recommendation: notify Jim (SMS + email) only; do NOT notify contractors at lead arrival. The Tier-2 approval must state the final recipient list.
- **D2. Per-contractor fact_bids rows vs one row.** The approved clause says "one pending fact_bids per active contractor" (marketplace-style). Under the pivot, contractor assignment happens at the estimate (`fulfillment.lane`), so ONE pending row with `contractor_id: null` may better reflect reality and avoids phantom per-contractor deals. The Tier-2 approval must pick one.
- **D3. HubSpot writes in-scenario.** The relay JS already creates the HubSpot contact. Duplicating contact/deal creation in Make risks duplicate records. Decide: Make reads HubSpot only (recommended), or Make becomes the writer and the relay JS is retired (bigger change, separate task).
- **D4. Reactivation triggers context.** The 2026-04-19 decision parked automation until ≥10 leads/week, a 3rd contractor, or the 1st accepted bid. The Tier-2 approval should explicitly acknowledge it is superseding that parking decision (gate at 3/3 qualified justifies it, but say so on the record).

## 9. References

- Approved TEST build plan: Supabase `approval_queue` approval_id 1 (`proposed_action` jsonb), project iabiwsbmnbxmkjvkgfhg
- Parked scenario config: `operations/make/webhooks.json` (scenario 4792854, hook 2183206)
- Routing rules: `operations/leads/routing-rules.json`
- Scoring rules: `operations/leads/scoring-rules.json`
- Warehouse schema: `operations/data-warehouse/schema/001_initial.sql`, `005_fact_bids_schema_adaptation.sql` (pending status, nullable contractor_id), views `001_views.sql`, `002_control_views.sql`, 003 (test exclusions), 004 (lead channels)
- Fulfillment pivot: project memory `fulfillment-model-pivot-2026-06-10`, board directive WB-018
- Control plane ops: `operations/control-plane/README.md`
