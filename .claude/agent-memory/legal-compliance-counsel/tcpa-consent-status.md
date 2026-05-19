---
name: TCPA Consent Language Status
description: TCPA consent checkbox finalized 2026-04-07 with compliant language; no longer a go-live blocker
type: project
tags:
  - type/memory
  - agent/legal-compliance-counsel
created: 2026-04-04
updated: 2026-04-16
status: active
---

TCPA consent checkbox language has been finalized and deployed to the quote form spec (field id 10) as of 2026-04-07. This is no longer a go-live blocker.

Finalized consent text:

> "I agree to receive calls, text messages, and emails from [[Central Wisconsin Deck Builders LLC|Central Wisconsin Deck Builders, LLC]] and its contractor partners about my project request. Consent is not a condition of receiving a quote. Msg & data rates may apply. Reply STOP to opt out."

**Why:** TCPA (47 U.S.C. 227) requires prior express written consent before sending marketing texts or making autodialed calls. FCC regulations require the consent disclosure to be "clear and conspicuous" and cannot be a condition of purchase. Wisconsin also has its own telemarketing regulations under Wis. Stat. 100.52. Without proper consent language, any SMS or phone follow-up to leads could trigger TCPA liability ($500-$1,500 per violation).

**How to apply:** This language must appear on all [[Webflow]] quote forms (/get-a-quote and all inline city page forms) as a required checkbox, placed below fields and above the submit button. The same text should be used verbatim wherever TCPA consent is collected. Any future changes to contact methods (e.g., adding autodialed calls) may require updating this language.

**Compliance checklist (all addressed in finalized text):**
1. Consent to be contacted by phone/SMS/email -- YES
2. Consent is not a condition of service -- YES ("Consent is not a condition of receiving a quote")
3. Identifies who will contact them -- YES ("Central Wisconsin Deck Builders, LLC and its contractor partners")
4. Message/data rates may apply -- YES
5. Opt-out instructions -- YES ("Reply STOP to opt out")
