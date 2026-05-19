---
type: contingency
date: 2026-05-09
trigger: jim-marks-debbie-real
contact_id: 483345261285
status: pre-staged
---

# Debbie Overlook → Real Lead Playbook

**Activation trigger:** Jim replies `%real%` to WB-014 outreach. Until then this file is dormant.

**Total CEO + Jim time if activated:** ~25 minutes (HubSpot deal + contractor route + outreach text). 5 min CEO orchestration, 20 min Jim.

---

## Lead snapshot

| Field | Value |
|---|---|
| Name | Debbie Overlook |
| Contact ID | `483345261285` |
| Phone | (715) 393-7145 |
| Email | need@getemail.com |
| Zip | 54474 (Wausau-area, ~9 mi south) |
| Project | deck-repair |
| Budget | under-10k |
| Timeline | asap |
| Lifecycle | lead (un-progressed) |
| Created | 2026-05-08 19:13:15 UTC |

## Step 1 — Manual deal create (HubSpot, ~3 min)

CEO executes via MCP (`mcp__claude_ai_HubSpot__manage_crm_objects`):

- Object: `deal`
- Pipeline: `2247158458` (Homeowner Leads)
- Stage: `3610478270` (New Lead)
- dealname: `Deck Repair - Debbie Overlook`
- amount: blank (under-10k bucket; set when bid lands)
- Associations: contact `483345261285`

If MCP fails, Jim hand-creates via UI: Sales → Deals → Create deal → assign to Homeowner Leads pipeline → New Lead stage → associate Debbie contact.

## Step 2 — Contractor route (manual SMS, ~2 min Jim)

Per pivot 2026-04-19 (Make scenario parked), Jim manually routes via personal SMS.

**Primary:** Ben Barton (Barton Builders LLC) — 54401, ~9 mi north of zip 54474, closest available contractor.
**Secondary:** John Garcia (John Garcia Construction, LLC) — 54426 Marathon, fallback if Ben passes.

Text Ben first. Wait 4 hours. If no response, ping John.

**SMS template (paste-ready):**

```
Ben — new homeowner lead in Wausau-area zip 54474. Debbie Overlook,
deck repair, under $10k, asap timeline. Phone (715) 393-7145.
HubSpot link: https://app.hubspot.com/contacts/245712220/record/0-1/483345261285
You want it? First yes wins.
```

Move deal to stage `3610478272` (Scheduled / Delivered to Contractor) once Ben or John accepts.

## Step 3 — Homeowner outreach within 24 hours (Jim or contractor, ~10 min)

The first contractor to accept makes the call/text. If both pass, Jim makes the courtesy outreach to keep the lead warm.

**Homeowner SMS template (Jim or contractor sends):**

```
Hi Debbie — this is [name] with Central Wisconsin Deck Builders.
Saw your quote request for a deck repair. Available to swing by
this week and take a look? Free estimate, 48-hour turnaround.
Best times to reach you?
```

If she responds and wants a site visit → contractor schedules → deal moves to stage `3610415826` (Creating Bid).

## Step 4 — Testimonial gate (post-close, NOT today)

WB-007 testimonial collection is gated until first close. Note here only: if Debbie closes a job through Ben or John, this is the unlock event for Lever 4 (proof). Do not request testimonial pre-close.

## Step 5 — Logging

CEO logs to `_vault/board/shipped.md` under 2026-05-09:

```
- [WB-014] Debbie Overlook real-lead routing — deal `<id>` created, routed to <Ben|John>, homeowner outreach sent — `artifact-prod`
```

Do NOT log this playbook itself as shipped. The playbook is pre-stage; the routing IS the ship.

## Reversibility

Every step is reversible: deal can be deleted, SMS can be retracted in HubSpot CRM tracking note, lifecycle stage can revert. Default-ship safe.
