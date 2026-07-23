/**
 * cwdb_intake_relay v2.1.0
 *
 * Relays quote form submissions to the CWDB jobtread-gateway Edge Function,
 * which dual-writes JobTread (Pave) + HubSpot (safety net) server-side and
 * lands a bronze warehouse row.
 *
 * v2.1.0 changes (audit-2026-07-05 #9 attribution + #12 consent hardening):
 *  - Attribution param-or-storage fallback: live URL params win; otherwise
 *    the stored 90-day first touch from cwdb_attribution_keeper
 *    (localStorage key `cwdb_first_touch`) fills utm_source / utm_medium /
 *    utm_campaign / utm_term / utm_content / gclid / fbclid.
 *  - HubSpot hutk cookie (`hubspotutk`) included in the gateway payload so
 *    the server-side HubSpot Forms API write carries analytics context and
 *    merges cleanly with the collected-forms contact.
 *  - Hidden form fields (utm_source / hutk / pageUri / pageName) are
 *    populated before submit so the Webflow-native submission keeps
 *    attribution even if the gateway POST never lands (the Petersen 6/30
 *    failure mode: browser POST lost, collected-forms contact had nothing).
 *  - sendBeacon-first delivery (text/plain, no CORS preflight; the gateway
 *    parses the body as JSON regardless of content type). Beacons survive
 *    the redirect to /thank-you in webviews that cancel keepalive fetches
 *    (e.g. Facebook in-app browser). fetch(keepalive) is the fallback.
 *  - Applied SITE-WIDE (site freeform footer) instead of page-scoped, so
 *    the city-page quote forms (/service-area/*, same form id
 *    wf-form-Quote-Request) also reach the gateway. On pages without the
 *    form the script exits quietly.
 *
 * Replaces cwdb_intake_relay-2.0.1.js (kept in repo for rollback: paste
 * that file's <script> block back into the /get-a-quote page footer
 * freeform code and clear the site freeform footer relay block).
 *
 * Fire-and-forget: never blocks Webflow's native email + redirect flow.
 */
(function () {
  'use strict';

  if (window.__cwdbIntakeRelayLoaded) return;
  window.__cwdbIntakeRelayLoaded = true;

  // apikey URL param: Supabase gateway requires an apikey on every function
  // call even with verify_jwt off. This is the PUBLISHABLE key (browser-safe,
  // same class as the public HubSpot portal id in relay v1).
  var ENDPOINT = 'https://iabiwsbmnbxmkjvkgfhg.supabase.co/functions/v1/jobtread-gateway/intake' +
    '?apikey=sb_publishable_dykWddolrfHGA3ID7jjBiw_Y6w3bU4A';
  var FORM_SELECTOR = 'form#wf-form-Quote-Request';
  var LOG = '[cwdb_intake_relay]';
  var FT_KEY = 'cwdb_first_touch';
  var FT_TTL_MS = 90 * 24 * 60 * 60 * 1000;
  var ATTR_KEYS = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'gclid', 'fbclid'];

  // Webflow form name attr -> gateway payload key (the server maps onward).
  // Some keys appear twice to handle both source-HTML and Designer variants.
  // NOTE: the form's hidden `utm_source` input is deliberately NOT mapped;
  // attribution keys come from the URL or the stored first touch only.
  var FIELD_MAP = {
    'name':           'name',
    'firstname':      'name',
    'email':          'email',
    'phone':          'phone',
    'address':        'address',
    'zip':            'zip',
    'project_type':   'project_type',
    'project-type':   'project_type',
    'budget':         'budget',
    'timeline':       'timeline',
    'notes':          'notes',
    'tcpa_consent':   'tcpa_consent',
    'owns_property':  'owns_property',
    'ownership':      'owns_property',
    'page_source':    'page_uri',
    'city':           'city'
  };

  function getUrlParam(name) {
    try {
      return new URLSearchParams(window.location.search).get(name) || '';
    } catch (e) {
      return '';
    }
  }

  function firstTouch() {
    try {
      var raw = window.localStorage.getItem(FT_KEY);
      if (!raw) return {};
      var obj = JSON.parse(raw);
      if (!obj || typeof obj.ts !== 'number') return {};
      if (Date.now() - obj.ts > FT_TTL_MS) return {};
      return obj;
    } catch (e) {
      return {};
    }
  }

  function getCookie(name) {
    try {
      var m = document.cookie.match(new RegExp('(?:^|; )' + name + '=([^;]*)'));
      return m ? decodeURIComponent(m[1]) : '';
    } catch (e) {
      return '';
    }
  }

  // Live URL param wins; stored first touch is the fallback.
  function attribution() {
    var stored = firstTouch();
    var out = {};
    for (var i = 0; i < ATTR_KEYS.length; i++) {
      var k = ATTR_KEYS[i];
      var v = getUrlParam(k) || stored[k] || '';
      if (v) out[k] = v;
    }
    return out;
  }

  function setHiddenField(form, name, value) {
    if (!value) return;
    var el = form.querySelector('input[type="hidden"][name="' + name + '"]');
    if (el) el.value = value;
  }

  // Keep the Webflow-native submission (and HubSpot collected-forms capture)
  // attribution-complete even when the gateway POST never lands.
  function fillHiddenFields(form) {
    var attrs = attribution();
    setHiddenField(form, 'utm_source', attrs.utm_source);
    setHiddenField(form, 'hutk', getCookie('hubspotutk'));
    setHiddenField(form, 'pageUri', window.location.href);
    setHiddenField(form, 'pageName', document.title);
  }

  function buildPayload(form) {
    var formData = new FormData(form);
    var out = {};

    formData.forEach(function (rawValue, rawName) {
      if (rawValue === '' || rawValue == null) return;
      var key = FIELD_MAP[rawName];
      if (!key || out[key]) return;
      out[key] = (rawName === 'tcpa_consent') ? 'true' : String(rawValue);
    });

    var attrs = attribution();
    for (var k in attrs) {
      if (!out[k]) out[k] = attrs[k];
    }

    var hutk = getCookie('hubspotutk');
    if (hutk) out.hutk = hutk;

    out.page_uri = out.page_uri || window.location.href;
    out.page_name = document.title || 'Get a Quote';
    return out;
  }

  function send(body) {
    try {
      if (navigator.sendBeacon &&
          navigator.sendBeacon(ENDPOINT, new Blob([body], { type: 'text/plain' }))) {
        console.log(LOG, 'queued via sendBeacon');
        return;
      }
    } catch (e) { /* fall through to fetch */ }
    fetch(ENDPOINT, {
      method: 'POST',
      mode: 'cors',
      keepalive: true,
      headers: { 'Content-Type': 'application/json' },
      body: body
    })
      .then(function (res) {
        if (res.ok) {
          console.log(LOG, 'gateway accepted (HTTP', res.status + ')');
          return;
        }
        return res.text().then(function (text) {
          console.warn(LOG, 'gateway rejected (HTTP', res.status + '):', text);
        });
      })
      .catch(function (err) {
        console.warn(LOG, 'relay failed (non-blocking):', err);
      });
  }

  function relay(form) {
    var payload;
    try {
      fillHiddenFields(form);
      payload = buildPayload(form);
    } catch (err) {
      console.warn(LOG, 'payload build failed (non-blocking):', err);
      return;
    }
    console.log(LOG, 'relaying to gateway');
    send(JSON.stringify(payload));
  }

  function attach() {
    var form = document.querySelector(FORM_SELECTOR);
    if (!form) return; // site-wide script: most pages have no quote form
    if (form.__cwdbRelayAttached) return;
    form.__cwdbRelayAttached = true;
    fillHiddenFields(form);
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
