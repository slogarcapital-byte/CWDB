/*!
 * hero_form_handoff v1.2.0
 * Intercepts hero-split form submission on the homepage and hands off
 * zip + phone to /get-a-quote via URL params.
 *
 * Fixed in 1.2.0 (2026-05-05):
 *   - Removed `novalidate` set on the form. The previous behavior suppressed
 *     all browser validation UI, so empty-field or bad-format submits silently
 *     did nothing (no popup, no toast). User-reported bug: "pressing submit
 *     does nothing."
 *   - Defer validation to the browser's native pattern/required validators.
 *     The handoff script now only intercepts when checkValidity() passes.
 *     If checkValidity() is false, we DO NOT preventDefault — the browser
 *     shows its native validation popup over the offending input.
 *
 * Selectors confirmed against production DOM 2026-05-05:
 *   form[data-name="hero-split-form"]  <— Webflow form block name
 *   input[name="zip" i]                <— pattern="\d{5}" required
 *   input[name="phone" i]              <— type="tel" required
 *   input[type="submit"].hero-split__cta.w-button
 */
(function () {
  function init() {
    var form = document.querySelector('.hero-split form, form[data-name="hero-split-form"]');
    if (!form) return;
    if (form.dataset.cwdbHandoff === '1') return;
    form.dataset.cwdbHandoff = '1';

    form.addEventListener('submit', function (ev) {
      // If the form is invalid, let the browser's native validation UI fire.
      // checkValidity() returns false when required/pattern/type fail.
      if (typeof form.checkValidity === 'function' && !form.checkValidity()) {
        // Do NOT preventDefault. Browser will block the submit AND show its
        // native validation popup pointing at the offending input.
        return;
      }

      // All validators passed. Block Webflow's native submit and route to
      // /get-a-quote with the captured zip + phone.
      ev.preventDefault();
      ev.stopPropagation();

      var zipEl = form.querySelector('input[name="zip" i]');
      var phoneEl = form.querySelector('input[name="phone" i]');
      var zip = zipEl ? (zipEl.value || '').trim() : '';
      var phone = phoneEl ? (phoneEl.value || '').trim() : '';

      // Belt-and-suspenders: phone digit count check. Native `required` only
      // checks non-empty, not digit count. We accept any phone with >=10
      // digits after stripping non-digits.
      if (phoneEl && phone.replace(/\D/g, '').length < 10) {
        // Use the native validity message so the popup renders.
        if (phoneEl.setCustomValidity) phoneEl.setCustomValidity('Please enter a 10-digit phone number.');
        if (phoneEl.reportValidity) phoneEl.reportValidity();
        if (phoneEl.setCustomValidity) {
          // Clear the custom message on next input so the popup goes away.
          var clear = function () { phoneEl.setCustomValidity(''); phoneEl.removeEventListener('input', clear); };
          phoneEl.addEventListener('input', clear);
        }
        return false;
      }

      var qs = [];
      if (zip) qs.push('zip=' + encodeURIComponent(zip));
      if (phone) qs.push('phone=' + encodeURIComponent(phone));
      window.location.href = '/get-a-quote' + (qs.length ? '?' + qs.join('&') : '');
      return false;
    }, true);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
