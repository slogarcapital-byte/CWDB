/**
 * hubspot_form_relay v1.0.0
 *
 * Relays /get-a-quote form submissions to HubSpot Forms API.
 * Fire-and-forget — does NOT block Webflow's native email + redirect flow.
 *
 * Architecture: Plan B from operations/analytics/phase-0-gate-spec.md
 * Replaces the broken HubSpot Webflow App + Non-HubSpot Forms tracking
 * auto-detection with explicit field-name translation.
 *
 * Constants verified 2026-05-05:
 *   HUB_ID:    245712220 (CWDB Starter Customer Platform)
 *   FORM_GUID: bb473d64-06b1-4311-8e02-7c70d605b79b (form schema, never embedded)
 *   REGION:    na2 (api.hsforms.com routes by portal ID)
 *
 * Apply via Webflow Site Scripts → Page-scoped to /get-a-quote.
 */
(function () {
  'use strict';

  if (window.__hsFormRelayLoaded) return;
  window.__hsFormRelayLoaded = true;

  var HUB_ID = '245712220';
  var FORM_GUID = 'bb473d64-06b1-4311-8e02-7c70d605b79b';
  var ENDPOINT = 'https://api.hsforms.com/submissions/v3/integration/submit/' + HUB_ID + '/' + FORM_GUID;
  var FORM_SELECTOR = 'form#wf-form-Quote-Request';
  var LOG = '[hubspot_form_relay]';

  // Webflow form `name` attr → HubSpot Contact property internal name.
  // Some keys appear twice to handle both source-HTML and Designer-derived variants.
  var FIELD_MAP = {
    'name':           'firstname',
    'email':          'email',
    'phone':          'phone',
    'address':        'address',
    'zip':            'zip',
    'project_type':   'project_type',
    'project-type':   'project_type',
    'budget':         'budget_range',
    'timeline':       'project_timeline',
    'notes':          'lead_notes',
    'tcpa_consent':   'tcpa_consent_given',
    'owns_property':  'owns_property',
    'ownership':      'owns_property',
    'page_source':    'lead_source_page'
  };

  function getUrlParam(name) {
    try {
      return new URLSearchParams(window.location.search).get(name) || '';
    } catch (e) {
      return '';
    }
  }

  function buildPayload(form) {
    var formData = new FormData(form);
    var fields = [];
    var seen = {};
    var unmapped = [];

    formData.forEach(function (rawValue, rawName) {
      if (rawValue === '' || rawValue == null) return;
      var hubspotName = FIELD_MAP[rawName];
      if (!hubspotName) {
        unmapped.push(rawName);
        return;
      }
      if (seen[hubspotName]) return;
      seen[hubspotName] = true;

      var value;
      if (rawName === 'tcpa_consent') {
        value = 'true';
      } else {
        value = String(rawValue);
      }
      fields.push({ name: hubspotName, value: value });
    });

    // URL-derived attribution fields (only if form didn't already include them)
    ['utm_source', 'utm_campaign', 'gclid'].forEach(function (key) {
      if (seen[key]) return;
      var v = getUrlParam(key);
      if (v) {
        fields.push({ name: key, value: v });
        seen[key] = true;
      }
    });

    if (unmapped.length) {
      console.warn(LOG, 'unmapped form fields (skipped):', unmapped);
    }

    return {
      fields: fields,
      context: {
        pageUri: window.location.href,
        pageName: document.title || 'Get a Quote'
      }
    };
  }

  function relay(form) {
    var payload;
    try {
      payload = buildPayload(form);
    } catch (err) {
      console.warn(LOG, 'payload build failed (non-blocking):', err);
      return;
    }

    if (!payload.fields.length) {
      console.warn(LOG, 'no mappable fields — skipping POST');
      return;
    }

    console.log(LOG, 'relaying', payload.fields.length, 'fields to HubSpot');

    fetch(ENDPOINT, {
      method: 'POST',
      mode: 'cors',
      keepalive: true,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    })
      .then(function (res) {
        if (res.ok) {
          console.log(LOG, 'HubSpot accepted submission (HTTP', res.status + ')');
          return;
        }
        return res.text().then(function (text) {
          console.warn(LOG, 'HubSpot rejected (HTTP', res.status + '):', text);
        });
      })
      .catch(function (err) {
        console.warn(LOG, 'relay failed (non-blocking):', err);
      });
  }

  function attach() {
    var form = document.querySelector(FORM_SELECTOR);
    if (!form) {
      console.warn(LOG, 'form not found:', FORM_SELECTOR);
      return;
    }
    if (form.__hsRelayAttached) return;
    form.__hsRelayAttached = true;
    // Capture-phase listener so we run before Webflow's native submit handler
    form.addEventListener('submit', function () { relay(form); }, true);
    console.log(LOG, 'attached to', FORM_SELECTOR);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', attach);
  } else {
    attach();
  }
})();
