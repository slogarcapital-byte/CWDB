/**
 * cwdb_attribution_keeper v1.0.0
 *
 * Site-wide first-touch attribution keeper (audit-2026-07-05 #9).
 * On every page load, captures utm_source / utm_medium / utm_campaign /
 * utm_term / utm_content / gclid / fbclid from the URL into localStorage
 * under key `cwdb_first_touch` with a 90-day expiry.
 *
 * FIRST TOUCH WINS: an unexpired stored first touch is never overwritten.
 * Expired entries are dropped and the next attributed load re-captures.
 *
 * Exposes window.cwdbFirstTouch() so the intake relay (and anything else)
 * can read the stored first touch without duplicating expiry logic. The
 * relay also reads localStorage directly, so load order does not matter.
 *
 * Deployed as a registered inline site script (header, all pages).
 * Registered id: cwdb_attribution_keeper. Rollback: remove_site_script.
 */
(function () {
  'use strict';
  if (window.__cwdbAttribKeeperLoaded) return;
  window.__cwdbAttribKeeperLoaded = true;

  var KEY = 'cwdb_first_touch';
  var TTL_MS = 90 * 24 * 60 * 60 * 1000;
  var PARAMS = ['utm_source', 'utm_medium', 'utm_campaign', 'utm_term', 'utm_content', 'gclid', 'fbclid'];

  function readFirstTouch() {
    try {
      var raw = window.localStorage.getItem(KEY);
      if (!raw) return null;
      var obj = JSON.parse(raw);
      if (!obj || typeof obj.ts !== 'number') return null;
      if (Date.now() - obj.ts > TTL_MS) {
        window.localStorage.removeItem(KEY);
        return null;
      }
      return obj;
    } catch (e) {
      return null;
    }
  }

  function capture() {
    if (readFirstTouch()) return;
    var sp;
    try {
      sp = new URLSearchParams(window.location.search);
    } catch (e) {
      return;
    }
    var out = { ts: Date.now(), landing: window.location.pathname };
    var found = false;
    for (var i = 0; i < PARAMS.length; i++) {
      var v = sp.get(PARAMS[i]);
      if (v) {
        out[PARAMS[i]] = v;
        found = true;
      }
    }
    if (!found) return;
    try {
      window.localStorage.setItem(KEY, JSON.stringify(out));
    } catch (e) {}
  }

  window.cwdbFirstTouch = readFirstTouch;
  capture();
})();
