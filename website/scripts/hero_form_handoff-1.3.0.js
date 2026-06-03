/*!
 * hero_form_handoff v1.3.0
 * Intercepts hero-split form submission on the homepage and hands off
 * zip + phone to /get-a-quote via URL params.
 *
 * Fixed in 1.3.0 (2026-06-03):
 *   - Forward ALL source-URL query params (utm_*, gclid, fbclid, etc.) into
 *     the /get-a-quote redirect. Previously only zip + phone were carried,
 *     which dropped attribution params on every ad-click -> homepage -> hero
 *     submit flow. Root cause of the UTM black hole observed in fact_leads
 *     (all 6 rows had NULL utm_source / utm_campaign / gclid as of 2026-06-02).
 *     Source-URL params are preserved; form values for zip/phone override any
 *     matching source-URL values.
 *
 * Fixed in 1.2.0 (2026-05-05):
 *   - Removed `novalidate` set on the form. The previous behavior suppressed
 *     all browser validation UI, so empty-field or bad-format submits silently
 *     did nothing.
 *   - Defer validation to the browser's native pattern/required validators.
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
      if (typeof form.checkValidity === 'function' && !form.checkValidity()) {
        return;
      }

      ev.preventDefault();
      ev.stopPropagation();

      var zipEl = form.querySelector('input[name="zip" i]');
      var phoneEl = form.querySelector('input[name="phone" i]');
      var zip = zipEl ? (zipEl.value || '').trim() : '';
      var phone = phoneEl ? (phoneEl.value || '').trim() : '';

      if (phoneEl && phone.replace(/\D/g, '').length < 10) {
        if (phoneEl.setCustomValidity) phoneEl.setCustomValidity('Please enter a 10-digit phone number.');
        if (phoneEl.reportValidity) phoneEl.reportValidity();
        if (phoneEl.setCustomValidity) {
          var clear = function () { phoneEl.setCustomValidity(''); phoneEl.removeEventListener('input', clear); };
          phoneEl.addEventListener('input', clear);
        }
        return false;
      }

      // Carry all source-URL params (utm_*, gclid, fbclid, etc.) into the
      // redirect. Form values for zip/phone override source-URL values.
      var params;
      try {
        params = new URLSearchParams(window.location.search);
      } catch (e) {
        params = new URLSearchParams();
      }
      if (zip) params.set('zip', zip);
      if (phone) params.set('phone', phone);
      var qs = params.toString();
      window.location.href = '/get-a-quote' + (qs ? '?' + qs : '');
      return false;
    }, true);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
