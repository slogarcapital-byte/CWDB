/* cwdb_conversion_signal v1.0.0 (2026-07-22)
 * Restores the post-submit conversion signal that broke 2026-06-10.
 * Root cause: the HubSpot Webflow forms integration (WB-016 wiring) intercepts
 * form#wf-form-Quote-Request submits, shows the inline success state, and never
 * executes Webflow's configured redirect="/thank-you". GTM (GTM-T3PB96G2)
 * triggers on /thank-you pageview + generate_lead, so both went silent.
 * Fix: on quote-form success, push generate_lead to the dataLayer, then enforce
 * the form's own data-redirect target (declared in Webflow form settings).
 * Coordinates with cwdb_intake_relay v2.1.0: relay fires on submit (capture)
 * via sendBeacon, which survives navigation. This script acts only on success.
 * Registered inline site script, footer. Rollback: remove_site_script
 * cwdb_conversion_signal.
 */
(function () {
  'use strict';
  if (window.__cwdbConvSignal) return;
  window.__cwdbConvSignal = true;
  function init() {
    var form = document.querySelector('form#wf-form-Quote-Request');
    if (!form) return;
    var wrap = form.closest('.w-form') || form.parentNode;
    var done = wrap ? wrap.querySelector('.w-form-done') : null;
    var fired = false;
    function fire() {
      if (fired) return;
      fired = true;
      try {
        window.dataLayer = window.dataLayer || [];
        window.dataLayer.push({ event: 'generate_lead', form_id: 'wf-form-Quote-Request' });
      } catch (e) {}
      var target = form.getAttribute('data-redirect') || '/thank-you';
      setTimeout(function () {
        try { window.location.assign(target); } catch (e) {}
      }, 150);
    }
    if (done) {
      var mo = new MutationObserver(function () {
        if (getComputedStyle(done).display !== 'none') fire();
      });
      mo.observe(done, { attributes: true, attributeFilter: ['style', 'class'] });
    }
    var mo2 = new MutationObserver(function () {
      if (form && getComputedStyle(form).display === 'none') fire();
    });
    mo2.observe(wrap || document.body, { attributes: true, subtree: true, attributeFilter: ['style', 'class'] });
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
