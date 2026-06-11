# Walk-Through Scheduling: HubSpot to Google Calendar

**Created:** 2026-06-10 (fulfillment pivot: Jim owns walk-throughs)
**Status:** Setup steps for Jim. Native sync first; build automation only if this proves insufficient.

## Goal

Book a walk-through while on the phone with a homeowner, have it land on Google Calendar automatically, and keep the appointment attached to the contact and deal in HubSpot.

## Recommended path: HubSpot native two-way calendar sync (free, no code)

HubSpot Starter includes two-way Google Calendar sync through the Meetings tool. One-time setup (about 3 minutes):

1. HubSpot > Settings (gear icon) > General > **Calendar** tab.
2. **Connect your calendar** > Google / Gmail > sign in with slogarjw@gmail.com > grant access.
3. Turn ON both toggles: "Sync meetings from HubSpot to your calendar" and (if offered) the inverse sync so events you create in Google with a known contact email get logged in HubSpot.
4. Optional but useful: Settings > General > Calendar > **Set up meetings scheduling page**. This gives a booking link (cwdeckbuilders branding, your availability) that can later go in estimate follow-up emails so homeowners self-book.

## Daily workflow (per phone lead)

1. Open the contact in HubSpot (create it first if this is a new phone lead: set Lead Channel = Phone Call and TCPA Consent Source = Verbal once those properties exist, see board WB-016).
2. On the contact record: **Schedule** (calendar icon in the left activity bar) > pick date/time > title it "Walk-through: [address]" > **associate the meeting with the deal** (right panel checkbox).
3. Save. The event appears on Google Calendar within a minute or two, with the homeowner's name, phone, and any description.
4. Reschedules made in either place stay in sync.

## Deal-level reporting (pending WB-016)

A `walkthrough_datetime` deal property will be created once the schema-write scope is added. Set it when booking so the warehouse can measure speed-to-walk-through against the 48-hour quote promise. Until then, the meeting engagement itself is the record.

## Fallback / automation path (only if native sync disappoints)

- Claude can create Google Calendar events directly (Google Calendar connector) on request: "book the Quinn walk-through Thursday 4pm" works in a session.
- A small script in the style of `templates/scripts/pull-*.ps1` could read deals with upcoming `walkthrough_datetime` and upsert calendar events via the Google Calendar API. Do not build this until native sync has actually failed at something.
