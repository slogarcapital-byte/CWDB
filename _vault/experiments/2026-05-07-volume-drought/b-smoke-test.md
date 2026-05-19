---
type: experiment
fork: b
created: 2026-05-07
owner: lead-routing
hypothesis: tracking-blackout
status: awaiting-jim-decision
---

# Fork B — Tracking-Blackout Hypothesis: Fresh smoke submit + relay log check

## Hypothesis

Real homeowner leads ARE arriving on cwdeckbuilders.com/get-a-quote, but **something between the form and HubSpot is silently failing.** The Forms API relay (`hubspot_form_relay-1.0.0.js`) could be:
- Throwing JS errors on certain browsers (mobile Safari? old Android?)
- Hitting CORS or rate-limit issues at api.hsforms.com
- Reporting success in the UI but failing silently server-side
- A regression introduced by a Webflow site republish since 2026-05-05

The original smoke test was Jim's `dcebighitta12@aim.com` test on 2026-05-05 20:33 UTC — that landed cleanly. We have no signal that the relay still works **today**.

## What to do

1. Open cwdeckbuilders.com/get-a-quote in **mobile Safari** (real iPhone, not desktop browser dev mode — the 2026-04-27 iOS flex submit bug per memory `feedback-ios-flex-submit-bug.md` proves mobile-specific failures happen).
2. Submit the form with `test-2026-05-07-AM@example.com`, real-looking name, real ZIP (54401), pick any project type, ANY budget, ANY timeline.
3. Open browser dev tools (Safari → Develop → iPhone) BEFORE submit if possible; capture the network request to `api.hsforms.com/submissions/v3/integration/submit/...`. Note status code.
4. Within 60 seconds of submit, check three places:
   - **HubSpot Contacts:** does `test-2026-05-07-AM@example.com` show up?
   - **HubSpot Deals → Homeowner Leads:** does a new Deal show up? (if WB-001 isn't shipped yet, expect no Deal — that's separate.)
   - **Email at slogarjw@gmail.com:** does the HubSpot form's native notification email arrive?
5. Repeat once on **desktop Chrome** for the control case.

## What evidence resolves it

**Confirms hypothesis (tracking IS broken):** mobile submit fails to land in HubSpot OR returns a non-2xx status from api.hsforms.com OR notification email never arrives. → escalate immediately to lead-routing for relay debug; do NOT bump budget.

**Falsifies hypothesis (tracking is fine):** both mobile and desktop submits land cleanly in HubSpot Contacts within 60s. → tracking is healthy; demand is genuinely the problem. Move to fork (c) or (a).

## Cost

- **Ad spend:** $0
- **Jim time:** ~10-15 minutes (two test submits + verify)
- **Risk:** essentially zero. Worst case wastes 15 minutes.

## Why this is fork B (cheapest, run first)

If the relay is broken, running fork (a) literally just burns more ad money for leads that vanish into a JS error. Cost-to-evidence here is 15 minutes vs. $210 — strict dominance.

## What this looks like if Jim picks it

- This morning: Jim runs the two submits (15 min).
- Result lands in §6 of tomorrow's brief as `%done — mobile + desktop both green%` or `%done — mobile failed at /submissions/v3, see screenshot%`.
- If green: triage to fork (c) tomorrow. If broken: lead-routing agent debugs the relay (likely a JS regression or browser-specific issue).

## Linked decisions

- §5 decision item: "Volume regression interpretation + budget bump" — fork (b) is the *first thing to rule out* before any spend decision.
- §5 decision item: "Keep or kill Google Ads manual paste ask" — fork (c) is the better version of that ask; (b) precedes both.
