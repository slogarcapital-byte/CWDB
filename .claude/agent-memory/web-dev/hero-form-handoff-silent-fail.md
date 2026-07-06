# Hero form handoff silent-fail bug — fixed 2026-05-05

## Symptom (Jim, 2026-05-05)
"Pressing the submit button on the homepage hero form does nothing."

## Root cause
`hero_form_handoff` v1.0.0 (shipped 2026-04-21) and v1.1.0 (re-registered identically during the 2026-04-28 rebuild) both set `form.setAttribute('novalidate', 'novalidate')` at init, then attempted to surface invalid-input errors via `input.reportValidity()`. With `novalidate=true`, `reportValidity()` is a no-op and renders no UI. Net effect: any submit with an empty zip, an empty phone, fewer than 10 phone digits, or a ZIP+4 entry was a silent fail. The handoff script's preventDefault path also blocked Webflow's native form submission, so the user saw zero feedback.

## Fix — v1.2.0 (2026-05-05)
- Removed the `novalidate` set entirely.
- Submit handler now defers to `form.checkValidity()`. If the form is invalid, the script returns WITHOUT calling preventDefault — letting the browser's own validation popup render against the offending input.
- Phone-digit-count check kept as a belt-and-suspenders post-checkValidity check (since `required` only enforces non-empty, not 10-digit). On failure, sets a custom validity message via `setCustomValidity()` and calls `reportValidity()` so the popup actually renders. Self-clears on next input.

## Verification
- Staging (https://central-wisconsin-deck-builders.webflow.io/): empty submit shows native "Please fill out this field." popup; valid submit navigates to `/get-a-quote?zip=54401&phone=7155551234` with Step 2 showing and hidden zip+phone fields prefilled.
- Production www (https://www.cwdeckbuilders.com/): same behavior verified end-to-end on 390x844 mobile viewport.
- Production apex (cwdeckbuilders.com): 301 → www, transitively verified.
- **iPhone real-device confirmed by Jim (2026-05-05)** — passes the standing real-device rule for mobile fixes.

## Lessons for future scripts
- Never set `novalidate` on a Webflow form unless you replace the entire validation UX yourself. `reportValidity()` returns true and shows nothing on novalidate forms — it does NOT bypass the attribute.
- Prefer `form.checkValidity()` + native `pattern`/`required`/`type=tel|email` validators over JS regexes inside the submit handler. The browser already paints the error UI for free; reproducing it in JS is wasted work and gets it wrong.
- Page-scoped scripts can still race with site-scoped duplicates. The `cwdbHandoff='1'` data-attribute guard prevents double-binding, but BOTH scripts will still load. When publishing a new version, bump both the page-scoped and site-scoped applications, or accept that the latest-registered version wins (registration order = load order in Webflow's CDN).
- Webflow CDN serves the LAST published state of page-scoped scripts. After `upsert_page_script`, you must `publish_site` to make the new applications hit production. The first publish call doesn't always pick up the script application change — re-publish if the CDN still serves the old version.

## Files
- Local source: `/website/scripts/hero_form_handoff-1.2.0.js` and `.min.js`
- Webflow registered ID: `hero_form_handoff` v1.2.0 (CDN: 69fa5026b896a043c4fa8fc1)
- Page-scoped on homepage `69c846dd9eee02fddb1e2376`: hero_form_handoff@1.2.0 + faqhometoggle@1.1.0
- Site-scoped (still pinned at v1.1.0 — bails harmlessly via cwdbHandoff guard, leave alone unless removing site-scoped duplicate becomes priority)
