---
name: 5 leads + 4 deals on 2026-05-05 (reality reconciliation)
description: First batch of real homeowner leads captured by Forms API relay; 4 deals in Homeowner Leads pipeline as of reality snapshot date
type: project
priority: load-on-every-session
created: 2026-05-05
---

On 2026-05-05, the HubSpot Forms API relay captured 5 real homeowner contacts in production within an 8-minute window. Jim hand-built 4 deals in the Homeowner Leads pipeline (ID 2247158458) for pipeline validation. The lead-routing workflow is the SOLE remaining critical-path item before fully automated end-to-end leads.

**Why:** Until 2026-05-05 the state file had been claiming zero leads; this entry prevents that drift from recurring.

**How to apply:** Every morning brief must reflect actual HubSpot state. Verify pipeline counts match the live MCP query before claiming "no leads."

Full snapshot: `_vault/reality-2026-05-05.md`

**Forensic correction (read the full memo):** Reality is **5 contacts + 5 deals** (not 4). The Hanus deal was built at 07:43 UTC, 1 minute after the first form fired; the remaining 4 deals were built 19:42–19:59 UTC. A 6th contact `481779765982` exists (Jim self-test) with no associated deal — exclude from brief KPIs.

**Pipeline value as of snapshot:** $5,900 reported (3 of 5 deals have no `amount`; true value higher).

**Top stage distribution:** 3 in "Scheduled / Delivered to Contractor" · 1 in "Creating Bid" · 1 in "Delivered Bid".
