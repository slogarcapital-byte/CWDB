---
type: component-spec
component-name: multi-step-form
status: spec
created: 2026-04-19
---

# multi-step-form

## Purpose

The 3-step wizard that replaces the single-page form on `/get-a-quote`. Splits the 9-field ask into three smaller commitments, accepts pre-filled `zip` and `phone` from the URL when the user arrives from the homepage hero micro-form (two-touch commitment), and fires the existing Make webhook on final submit.

The tradeoff being managed: long single-page forms have higher drop-off, but multi-step forms without progress indication have higher drop-off. This spec requires both the dashes-indicator and the Back affordance to keep drop-off down.

## Layout

```
Step [●][ ][ ]     Step [●][●][ ]     Step [●][●][●]

┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ STEP 1 OF 3     │ │ STEP 2 OF 3     │ │ STEP 3 OF 3     │
│                 │ │                 │ │                 │
│ Where is the    │ │ Tell us about   │ │ When + how much?│
│ deck going?     │ │ the project.    │ │                 │
│                 │ │                 │ │ Budget  [____]  │
│ Zip    [____]   │ │ Project [____]  │ │ Timeline [____] │
│ Phone  [____]   │ │ Address [____]  │ │ Details [____]  │
│                 │ │ Own/Rent[____]  │ │                 │
│ [ NEXT → ]      │ │ [← BACK] [NEXT] │ │ [← BACK] [SUBMIT]│
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

All three steps are rendered in the DOM. JS toggles `display: none / block` based on the current step. Single Webflow native form element wraps all three — the form submits only when the user reaches the end.

## Spec

**Container:**
- Background: `var(--white)`
- Max-width: 560px (inside the left column of the 2-col `.quote-layout`)
- Padding: 32px 24px (form wrapper has tight padding; the full page gives surrounding breathing room)

**Progress indicator:**
- Display: flex, gap: 8px
- 3 equal-width bars, each:
  - Height: 3px
  - Width: `flex: 1`
  - Background (active): `var(--orange)`
  - Background (inactive): `var(--sky)` at 50% opacity (`rgba(131,178,207,0.5)`) — sky replaces grey so progress feels alive, not dormant
  - Border-radius: 0 (hard-edged, no pill rounding)
- Margin-bottom: 32px

**Step label:**
- Font: Public Sans 600, 12px, uppercase, letter-spacing 2px
- Color: `var(--orange)`
- Text: "STEP 1 OF 3" / "STEP 2 OF 3" / "STEP 3 OF 3"
- Margin-bottom: 12px

**Step heading:**
- Font: Staatliches 400, 32px desktop / 26px mobile
- Color: `var(--slate)`
- Line-height: 1.1
- Margin-bottom: 32px
- Copy:
  - Step 1: "Where is the deck going?"
  - Step 2: "Tell us about the project."
  - Step 3: "When and how much?"

**Fields:**
All fields inherit from the design-system Quote Form spec: 48px height inputs/selects, Public Sans 400 16px, 1px `#ddd` border, 4px border-radius, focus `--sky`.

**Step 1 fields:**
- Zip code (text, numeric pattern `\d{5}`, required, name=`zip`)
- Phone number (tel, required, name=`phone`)
- Gap between fields: 16px

**Step 2 fields:**
- Project type (select, required, name=`project_type`, options listed in `/website/pages/get-a-quote/content.md`)
- Property address (text, required, name=`address`)
- Property ownership (select: Yes/No, required, name=`owns_property`)

**Step 3 fields:**
- Budget range (select, required, name=`budget`)
- Timeline (select, required, name=`timeline`)
- Project details (textarea, optional, name=`notes`)

**Navigation row (bottom of each step):**
- Display: flex, justify-content: space-between
- Step 1: `[ NEXT → ]` only, right-aligned
- Step 2: `[ ← BACK ]` left, `[ NEXT → ]` right
- Step 3: `[ ← BACK ]` left, `[ SUBMIT ]` right

**Back link:**
- Font: Public Sans 500, 14px, uppercase, letter-spacing 1px
- Color: `var(--sky)` — text link convention: sky on light bg, orange reserved for CTA buttons
- No background, no border — text-only link
- Hover: underline fades in, color stays `var(--sky)`

**Next / Submit buttons:**
- Use `.btn--primary` (inherits)
- Labels: "Next →" and "Submit"

## JS behavior (custom, in Webflow Page Settings → Before `</body>`)

```javascript
// Pseudocode — finalize in implementation
(function() {
  var steps = [
    document.querySelector('[data-step="1"]'),
    document.querySelector('[data-step="2"]'),
    document.querySelector('[data-step="3"]')
  ];
  var progressBars = document.querySelectorAll('[data-progress]');
  var current = 0;

  function show(idx) {
    steps.forEach(function(s, i) { s.style.display = (i === idx) ? 'block' : 'none'; });
    progressBars.forEach(function(bar, i) {
      bar.classList.toggle('active', i <= idx);
    });
    current = idx;
    // Scroll to top of form on step change
    document.querySelector('[data-form-container]').scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  // URL param pre-fill
  var params = new URLSearchParams(window.location.search);
  var zip = params.get('zip');
  var phone = params.get('phone');
  if (zip) document.querySelector('[name="zip"]').value = zip;
  if (phone) document.querySelector('[name="phone"]').value = phone;

  // If both pre-filled and valid, skip directly to step 2
  if (zip && /^\d{5}$/.test(zip) && phone && phone.replace(/\D/g, '').length === 10) {
    show(1);
  } else {
    show(0);
  }

  // Next / Back handlers
  document.querySelectorAll('[data-next]').forEach(function(btn) {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      // Validate current step's required fields before advancing
      var fields = steps[current].querySelectorAll('[required]');
      var valid = Array.from(fields).every(function(f) { return f.reportValidity(); });
      if (valid && current < steps.length - 1) show(current + 1);
    });
  });

  document.querySelectorAll('[data-back]').forEach(function(btn) {
    btn.addEventListener('click', function(e) {
      e.preventDefault();
      if (current > 0) show(current - 1);
    });
  });

  // Only the Submit button on step 3 triggers the actual form POST — no hijack needed.
  // The form's action attribute + native Webflow submission handles the Make webhook fire.
})();
```

## States

**Default (cold arrival, no URL params):** show step 1, progress bar fills only bar 1.

**Arrival with URL params:** pre-fill zip + phone. If both valid, start on step 2; otherwise start on step 1 with fields populated.

**Advance attempt with invalid fields:** browser-native `reportValidity()` surfaces the inline validation message; step does not advance.

**Submit pending:** final submit button text → "Submitting…", button disabled. Webflow's native form handling covers this.

**Submit success:** redirect to `/thank-you` (existing behavior).

**Submit failure:** Webflow's native error message displays below the form ("Oops! Something went wrong while submitting the form."). Component does not need custom error-handling JS beyond that.

## Webflow implementation notes

- Build as a net new component `multi-step-form` on the `/get-a-quote` page specifically (do not try to make this reusable across pages — the logic is page-scoped).
- Single Webflow native form element wraps all three step divs. Each step div gets `data-step="1"` / `"2"` / `"3"` attributes.
- Each Next button: `data-next` attribute, `type="button"` (not submit).
- Each Back link: `data-back` attribute.
- Progress bar: 3 child divs with `data-progress="1"` / `"2"` / `"3"`, combo class `.active` applied via JS.
- URL-param pre-fill JS goes in Page Settings → Custom Code → Before `</body>`. This is an exception to the "no custom HTML embed" rule — the logic genuinely needs JS and Webflow has no native multi-step form feature.
- Form action URL: keep the existing Make webhook (same one firing today). Field names must match the webhook's expected payload keys.
- Hidden field: add `page_source = get-a-quote-multistep` so the Make scenario can distinguish multistep submissions from any legacy single-page submissions during the transition.
- Test end-to-end with one real submission before Jim's sign-off on this step (Phase 3 step 14 in the plan's build sequence).

## Related files

- `/website/design-system.md` — form styling, typography
- `/website/pages/get-a-quote/content.md` — full field spec, copy source
- `/website/components/hero-split.md` — the source of the pre-filled URL params
- `/operations/leads/quote-form-fields.json` — canonical field spec
- Make scenario: `CWDB Lead Routing — v1` (4792854, parked — manual SMS interim per 2026-04-19 pivot)
