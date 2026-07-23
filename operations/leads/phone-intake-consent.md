# Phone Intake: Consent Hygiene (audit fix #16, 2026-07-22)

## What changed today (done by Claude)

- The HubSpot contact property `tcpa_consent_source` no longer offers "Assumed": the option is hidden (historical values preserved). New phone and manual leads must be logged as `verbal` or `form`.
- Property descriptions updated to say Assumed is retired.
- Both `lead_channel` and `tcpa_consent_source` already exist as dropdowns (created 2026-06-11).

## The one scripted consent sentence (say this on every inbound call)

> "Before we hang up: is it okay if I text you at this number about your deck project, things like scheduling the walk-through and your estimate? You can reply STOP anytime."

If the caller says yes: set `tcpa_consent_source = Verbal (on call)` on the contact, same call, before anything else. If no or unclear: leave it blank and only call or email. Never text a lead whose consent source is blank (the warehouse flags these as `consent_missing` and the dashboard blocks SMS on that flag).

## Jim: 2-minute UI step (create-contact screen)

HubSpot cannot expose this via API. In HubSpot (app-na2.hubspot.com, portal 245712220):

1. Settings (gear) > Data Management > Objects > Contacts > "Customize the 'Create contact' form"
2. Add both properties: **Lead Channel** and **TCPA Consent Source**
3. Save

After this, every manually created phone lead prompts for both fields at creation time.

## Jim: notify-path steps (audit fix #7, ~8 minutes)

Leads flow Webflow form -> jobtread-gateway -> HubSpot **Forms API** (form ID `bb473d64-06b1-4311-8e02-7c70d605b79b`). Because they arrive as real form submissions, HubSpot's native form notification email works, no workflows needed. The private app token lacks the `forms` scope, so these are UI steps:

1. Marketing > Forms > open the "Get a Quote" form > Options tab > "Send submission email notifications to" > add `info@cwdeckbuilders.com` (and `slogarjw@gmail.com` if you want a second copy) > Update.
2. On your iPhone: install the **HubSpot mobile app**, sign in, Profile > Notifications > enable push for **Form submissions** (and New contact assigned if offered).

Result: sub-5-minute speed-to-lead alerting with zero new infrastructure. Petersen sat 5 days because nothing notified you; this closes that hole.
