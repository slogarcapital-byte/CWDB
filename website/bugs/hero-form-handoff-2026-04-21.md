---
type: bug-spec
bug-id: hero-form-handoff-2026-04-21
reported: 2026-04-21
reported-by: Jim Slogar
severity: P0 (blocks Phase 3 /get-a-quote wizard contract)
status: triage-queued
owning-agent: web-dev
authored-by: cwdb-ceo-operator (Agent-tool unavailable this session — Jim's briefing requested dispatch, dispatch not executed; spec drafted from CEO context so web-dev has a concrete starting point next run)
related-components: hero-split, multi-step-form, /get-a-quote
---

# Bug — Homepage hero form does not hand off zip/phone to `/get-a-quote` Step 2

## Observation (from Jim, 2026-04-21)

> "zip and phone fields not pre-filling and moving to step 2 of form. when you hit button, form gives you thank you message."

Repro: Fill zip + phone on the homepage hero form, click the CTA. Expected: land on `/get-a-quote` with Step 2 open and both fields pre-filled. Actual: a direct Webflow form success message (or redirect to `/thank-you`) fires — the lead never reaches Step 2.

## Why this matters

The `hero-split` component was specced (see `/website/components/hero-split.md` §Spec → CTA) as the entry point of a two-touch commitment funnel:

1. **Touch 1 (hero, 2 fields):** zip + phone — deliberately low-stakes to maximize micro-conversion on the LP.
2. **Touch 2 (/get-a-quote Step 2 of a 3-step wizard):** project details (type, timeline, budget, address) — user arrives already committed.

The contract between Touch 1 and Touch 2 is a URL-param handoff: the hero CTA navigates to `/get-a-quote?zip={{zip}}&phone={{phone}}` and the multi-step form on /get-a-quote pre-fills Step 1 (or skips directly to Step 2) from the query string.

Breaking that handoff means:
- Hero leads are collected as raw form submissions with **only zip + phone** — missing the qualification data the pipeline depends on (project type, budget, timeline).
- Users lose trust: they expect to complete a quote, not to receive a thank-you for a 2-field submit.
- The Phase 3 multi-step wizard (unbuilt as of 2026-04-21) cannot be tested or launched against a broken entry point.

## Root cause hypothesis (to be confirmed by web-dev)

The Webflow hero form is almost certainly still wired as a **native Webflow form with default success behavior** — i.e. it POSTs to Webflow's form submission endpoint and either shows the inline "Thank you" or redirects to `/thank-you` per the form's Success Redirect setting. The CTA is functioning as a form submit button, not as a navigation trigger.

The `hero-split` spec (line 80) clearly states:
> **CTA:** On submit: navigate to `/get-a-quote?zip={{zip}}&phone={{phone}}`

…but the Webflow form block likely either:
- (a) has Success Redirect pointing at `/thank-you` (or empty → inline success), OR
- (b) has no mechanism to append the input values as query params — Webflow's native Success Redirect is a static URL, not a templated one.

The spec (line 116) anticipated this exact gap:
> If Webflow's native form block cannot append URL params on submit, pause and ask the user before adding a small custom JS snippet to Page Settings → Before `</body>`.

That pause was not executed — the form shipped with whatever Webflow default Success Redirect was in place.

## Web-dev agent: triage steps for next session

1. **Audit the hero-split component in the Webflow Designer** (MCP or Designer):
   - Confirm the form block type (native Webflow form vs. custom HTML).
   - Read the Form Settings → Success Redirect value.
   - Read the CTA button's link or submit type.
   - Check whether any Page Settings → Custom Code (head or body) is already attempting a JS handoff.

2. **Propose one of these fix approaches** and document the tradeoff:

   **Option A — JS handoff (recommended):**
   - Leave the form block native (preserves Webflow's styling + validation).
   - Add a small Before `</body>` custom script that intercepts form submit on `.hero-split form`, prevents Webflow's default submit, grabs the zip + phone values, and does `window.location = '/get-a-quote?zip=' + encodeURIComponent(zip) + '&phone=' + encodeURIComponent(phone)`.
   - Pro: preserves form validation, handoff is clean, no lead polluted in Webflow Forms inbox.
   - Con: requires a small JS snippet; must be tested against Webflow's own form validation lifecycle.

   **Option B — Non-submitting button:**
   - Convert the form block from a `<form>` to a plain set of input fields.
   - Replace the submit button with a plain button that runs JS to read values and navigate.
   - Pro: no race with Webflow's native submit; cleaner mental model.
   - Con: loses Webflow's native validation UX; requires manual validation wiring.

   **Option C — Success Redirect with JS shim:**
   - Let the form submit natively but on the `/thank-you` page read the last-submitted values (from Webflow's form submission DOM state or a session cookie) and re-route. Brittle, not recommended.

3. **Recommended pick: Option A.** Document the exact JS snippet in this file once confirmed via MCP audit.

4. **Do NOT implement yet.** Phase 3 `/get-a-quote` 3-step wizard does not exist. The fix goes in once the Phase 3 wizard is scoped so the URL-param contract is finalized in one PR.

## Acceptance criteria (when fix ships)

- Zip + phone submitted on hero form land as URL params on `/get-a-quote`.
- `/get-a-quote` Step 1 (or wizard's first step with those fields) pre-fills them and, if valid, advances to Step 2 automatically.
- No Webflow Forms submission is created for the hero touch (the real lead is captured at /get-a-quote final submit).
- `/thank-you` is reached only after the multi-step form completes.

## Tracking

- Opened: 2026-04-21 (session `2026-04-21-012`)
- Owner: web-dev (dispatch deferred — see §§ Authored-by above)
- Priority: P0 — blocks Phase 3 wizard validation and will degrade LP conversion if ads launch against this state
- Status: triage-queued
- Next action: next session, web-dev agent audits current Webflow state and fills in the Option A snippet below

## Appendix — suggested JS for Option A (draft, untested)

```html
<!-- Page Settings → Before </body> on homepage -->
<script>
(function(){
  var form = document.querySelector('.hero-split form, [data-component="hero-split"] form');
  if (!form) return;
  form.addEventListener('submit', function(ev){
    ev.preventDefault();
    ev.stopPropagation();
    var zip   = (form.querySelector('input[name="zip"], input[name="Zip"]') || {}).value || '';
    var phone = (form.querySelector('input[name="phone"], input[name="Phone"]') || {}).value || '';
    var qs = [];
    if (zip)   qs.push('zip=' + encodeURIComponent(zip));
    if (phone) qs.push('phone=' + encodeURIComponent(phone));
    window.location.href = '/get-a-quote' + (qs.length ? '?' + qs.join('&') : '');
  }, true);
})();
</script>
```

Constraints: must match the actual field `name` attributes in the live Webflow form (verify during audit); must defeat Webflow's own submit handler — `useCapture = true` in the listener is there to front-run Webflow.
