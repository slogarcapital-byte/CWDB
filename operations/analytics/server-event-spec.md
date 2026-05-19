---
type: spec
agent-id: analytics
name: server-event-spec
description: DEPRECATED 2026-04-28. Cloudflare Worker spec superseded by HubSpot↔Webflow native plan. See operations/analytics/hubspot-webflow-native-plan.md.
tags:
  - type/spec
  - agent/analytics
  - phase/a
  - status/deprecated
created: 2026-04-27
updated: 2026-04-28
status: DEPRECATED
deprecated_by: operations/analytics/hubspot-webflow-native-plan.md
deprecated_reason: "Jim chose HubSpot↔Webflow native integration over Cloudflare Worker on 2026-04-28. Worker plan parked indefinitely; no implementation work to be done from this spec."
owner: analytics-agent
implementer: NONE — do not implement
---

> **DEPRECATED 2026-04-28.** Jim chose to use the HubSpot↔Webflow native integration in place of a Cloudflare Worker. Canonical plan now lives at `operations/analytics/hubspot-webflow-native-plan.md`. This document is preserved as a decision audit trail and as a recipe for hashing/normalization rules (§2) that may apply if we ever build a hashing-only Worker. **Do not start implementation from this document.**
>
> **What survived the rework into the new plan:**
> - The `event_id` schema (§1.1) — informs the HubSpot workflow webhook's payload-templating recipe for Meta CAPI dedup.
> - Hashing normalization rules (§2) — applies anywhere we hash PII, including HubSpot workflow webhook payloads if HubSpot's templating gains SHA-256 support, OR if we ever add a hashing-only Worker.
> - Per-platform payload field maps (§3.1, §3.2, §3.3) — directly reusable as the JSON body for HubSpot Workflow Webhook actions to Google Ads, Meta CAPI, and GA4 MP respectively.
>
> **What was dropped:**
> - The Cloudflare Worker scaffold (§4).
> - The `relay.cwdeckbuilders.com` subdomain plan.
> - The wrangler/secrets/CORS architecture.
> - Active spec status — implementer no longer assigned.
>
> ---

# Server-Event Integration Spec — Phase A (DEPRECATED — kept as reference only)

**Plan reference:** `C:\Users\jslog\.claude\plans\cwdb-ceo-operator-agent-i-made-tranquil-sketch.md`
**Workstream:** WS-1 Phase A (browser-augmented + serverless, no Make/HubSpot dependency)
**Status:** Spec authoring complete. Implementation pending in a follow-up web-dev session.
**Out of scope:** Phase B closed-loop on accepted-bid lifecycle (gated, see Section 7).

---

## 0. Mission and Why-Now

CWDB has Google Search ads live for 2 days at $30/day. All conversion signals currently flow only through the browser via GTM (Google Ads conversion tag, Meta Pixel `Lead`, Nextdoor Pixel `LEAD`, GA4 `form_submit_quote`). Browser-only tracking suffers three structural losses:

1. **iOS Safari ITP / Chrome third-party cookie deprecation** drops 20–40% of attribution windows on Meta Pixel and shrinks lookalike-audience match quality.
2. **Ad-blockers** (~25% of US desktop users on `uBlock Origin` / `Ghostery`) silently kill the Pixel and `gtag` `conversion` payload entirely.
3. **Google Ads Enhanced Conversions for Leads** is required to recover hashed-PII match between our form-submit event and Google's logged-in-user graph — without it, Smart Bidding optimizes against a thinner signal.

Phase A closes those gaps by **adding** (not replacing) a serverless ping that fires in parallel with the browser tags. Browser remains source-of-truth; server is augmentation. Dedup is enforced via a single shared `event_id` per submission.

Jim's verbatim ask (queue note): *"need to create direct data feed to google and meta ads as well as GA4."*

---

## 1. `event_id` Schema and Dedup Contract

### 1.1 Format

```
event_id = "cwdb_" + Date.now() + "_" + crypto.randomUUID().slice(0, 8)
```

Example: `cwdb_1745812345678_a3f9c1d2`

**Why this format over UUID v4:**
- Sortable by submission time when scanning logs (timestamp prefix).
- Namespace prefix `cwdb_` makes the ID grep-able in Cloudflare logs, Meta Events Manager test events, GA4 DebugView, and Google Ads diagnostics simultaneously.
- 8-char random suffix from `crypto.randomUUID()` (122 bits of entropy in the source, truncated to 32 bits) gives 1-in-4-billion collision odds within any single millisecond. Form submits are ~1 per IP per day in practice; collision risk is effectively zero.
- All three platforms accept arbitrary strings up to 64 chars. Our format is 28 chars.

### 1.2 Generation Point — single source

`event_id` is generated **once**, in the browser, on the form's `submit` event, **before** any analytics fires. The same string is then:

1. Stored on the form element as `data-event-id` (and as a hidden `<input name="event_id">` for Webflow form-data delivery).
2. Pushed into `dataLayer` so the GTM Meta Pixel `Lead` tag and Google Ads conversion tag can read it.
3. Posted in the `fetch()` body to the serverless relay endpoint.

Order of operations (must be exact):

```js
form.addEventListener('submit', (e) => {
  // 1. Generate ONCE
  const eventId = 'cwdb_' + Date.now() + '_' + crypto.randomUUID().slice(0, 8);

  // 2. Stamp it on the form (for Webflow form-data + GTM dataLayer reads)
  form.dataset.eventId = eventId;
  let hidden = form.querySelector('input[name="event_id"]');
  if (!hidden) {
    hidden = document.createElement('input');
    hidden.type = 'hidden';
    hidden.name = 'event_id';
    form.appendChild(hidden);
  }
  hidden.value = eventId;

  // 3. Push to dataLayer for GTM tags
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push({
    event: 'form_submit_quote',
    event_id: eventId,
    project_type: form.querySelector('[name=project_type]').value,
    form_location: 'get_a_quote_page',
    value: 1000,
    currency: 'USD'
  });

  // 4. Fire serverless relay (fire-and-forget; do NOT await — let Webflow do its native submit)
  fetch('https://relay.cwdeckbuilders.com/lead-event', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
      event_id: eventId,
      event_name: 'Lead',
      event_time: Math.floor(Date.now() / 1000),
      page_url: window.location.href,
      user_agent: navigator.userAgent,
      fbc: getCookie('_fbc'),
      fbp: getCookie('_fbp'),
      ga_client_id: getGaClientId(),
      form_data: {
        email: form.querySelector('[name=email]').value,
        phone: form.querySelector('[name=phone]').value,
        name: form.querySelector('[name=name]').value,
        address: form.querySelector('[name=address]').value
      },
      custom_data: {
        project_type: form.querySelector('[name=project_type]').value,
        budget: form.querySelector('[name=budget]').value,
        timeline: form.querySelector('[name=timeline]').value,
        value: 1000,
        currency: 'USD'
      }
    }),
    keepalive: true  // survives page navigation to /thank-you
  }).catch(() => { /* swallow — server is augmentation, browser is source of truth */ });

  // Webflow native form continues its normal submit — DO NOT preventDefault
});
```

The `keepalive: true` flag is critical: Webflow's native form will navigate the browser to `/thank-you` immediately after submit, and without `keepalive` the in-flight `fetch()` would be cancelled.

**Critical:** Raw PII (`email`, `phone`, `name`, `address`) is sent to OUR Cloudflare Worker over HTTPS only. The Worker hashes before forwarding to Meta/Google/GA4. The browser never hashes — that work happens server-side where we control consistency. Per `tracking-plan.md` line 173 ("never send PII in events as parameters"), no PII enters `dataLayer` or any browser-fired event.

### 1.3 Dedup Per Platform

| Platform | Mechanism | Field name on browser | Field name on server | Window |
|---|---|---|---|---|
| Meta | Explicit dedup by `event_id` match | `fbq('track', 'Lead', {...}, {eventID: '<event_id>'})` | `data[].event_id` in CAPI POST | 48 hours; first received wins |
| Google Ads Enhanced Conversions | NOT a dedup mechanism — Enhanced Conversions augments the existing browser conversion with hashed PII; it does not double-fire. `event_id` is for our own observability only. | n/a (enhanced data attaches to the existing GCLID-keyed conversion) | n/a | n/a |
| GA4 | Custom event parameter `event_id`. GA4 does not auto-dedup — we send from web stream OR server stream, never both for the same event. **Decision:** server stream sends `generate_lead` (canonical for ads-platform-quality reporting); web stream continues sending `form_submit_quote` (engagement reporting). Different event names = no collision. | `event_id` parameter on `form_submit_quote` (web) | `event_id` parameter on `generate_lead` (server) | n/a |

**Meta dedup mechanic explained:** Meta's CAPI documentation states that when both Pixel and CAPI events arrive with matching `event_name` + `event_id`, Meta keeps the first arrival (usually the Pixel, since it fires sub-second; CAPI arrives in 200ms–2s) and discards the second. This is the entire point of dedup — both signals reach Meta, but only one is counted. The CAPI signal still contributes its hashed PII to the EMQ (Event Match Quality) score, which improves attribution and lookalike modeling even when the count itself comes from the Pixel.

Reference: https://developers.facebook.com/docs/marketing-api/conversions-api/deduplicate-pixel-and-server-events

---

## 2. Hashed-PII Normalization Rules

This is the #1 source of silent failures. Mismatched normalization between browser and server (or between our server and Meta's hash-comparator) drops match rates from 90%+ down to single digits with no error message — every event gets accepted, but none of them match Meta's user graph.

**All hashing happens in the Cloudflare Worker, NOT in the browser.** The browser sends raw PII over HTTPS to our Worker; the Worker normalizes and hashes before forwarding to Meta/Google/GA4.

### 2.1 Email

```js
function normalizeEmail(raw) {
  return raw.trim().toLowerCase();
}
function sha256Hex(str) {
  return crypto.createHash('sha256').update(str, 'utf8').digest('hex');
}
const em = sha256Hex(normalizeEmail(form_data.email));
```

- No exceptions. No removing dots from Gmail addresses (Meta and Google explicitly say *do not* normalize gmail dots).
- No removing plus-aliases. `jim+test@example.com` stays `jim+test@example.com` then lowercased.

### 2.2 Phone

```js
function normalizePhone(raw) {
  const digits = raw.replace(/\D/g, '');         // strip everything non-digit
  if (digits.length === 10) return '+1' + digits; // US 10-digit → E.164
  if (digits.length === 11 && digits.startsWith('1')) return '+' + digits;
  return '+' + digits; // assume already in international form; let Meta/Google reject if invalid
}
const ph = sha256Hex(normalizePhone(form_data.phone));
```

- Meta + Google + GA4 all want E.164 with leading `+`. The `+` IS hashed.
- Wisconsin form input `(715) 555-1234` → `7155551234` → `+17155551234` → SHA-256.

### 2.3 First Name / Last Name

The CWDB form has a single `name` field (per `quote-form-fields.json` field id 1). Split on first whitespace:

```js
function splitName(raw) {
  const trimmed = raw.trim();
  const idx = trimmed.indexOf(' ');
  if (idx === -1) return { first: trimmed.toLowerCase(), last: null };
  return {
    first: trimmed.slice(0, idx).toLowerCase(),
    last: trimmed.slice(idx + 1).toLowerCase()  // entire remainder, not just second token
  };
}
const { first, last } = splitName(form_data.name);
const fn = sha256Hex(first);
const ln = last ? sha256Hex(last) : null;
```

- "Mary Jane Watson" → first=`mary`, last=`jane watson`. Multi-token last names stay intact.
- Single-token names (just "Cher") → first=`cher`, last omitted from payload entirely (do NOT send empty string or null inside the array — omit the `ln` key).

### 2.4 ZIP

The `address` field is freeform. Parse with this regex (5-digit ZIP at end of US-format address):

```js
function extractZip(raw) {
  const m = raw.match(/\b(\d{5})(?:-\d{4})?\s*$/);
  return m ? m[1] : null;
}
const zipRaw = extractZip(form_data.address);
const zp = zipRaw ? sha256Hex(zipRaw.trim()) : null;
```

- Take first 5 digits only. Discard ZIP+4 suffix.
- If parse fails, omit `zp` from payload — do not send empty/null.

### 2.5 Address (optional, for Meta CAPI EMQ boost)

If parse-out succeeds for street/city/state, hash each separately (Meta uses `ct`, `st`, `country`):

```js
// Best-effort parse; many forms will only give partial data.
function parseAddressLoose(raw) {
  // Expected user input: "123 Main St, Wausau, WI 54401"
  const parts = raw.split(',').map(s => s.trim());
  if (parts.length < 3) return null;
  return {
    street: parts[0].toLowerCase(),
    city: parts[1].toLowerCase(),
    state: (parts[2].match(/\b([A-Z]{2})\b/i)?.[1] || '').toLowerCase()
  };
}
```

- Hash each: `ct = sha256Hex(parsed.city)`, `st = sha256Hex(parsed.state)`.
- Send `country: sha256Hex('us')` always when sending any address piece.
- Street goes in Meta's `db` (date of birth) slot? **No.** Street is `address` in Google Enhanced Conversions and is NOT a Meta CAPI standard field — Meta accepts `ct`/`st`/`zp`/`country` only. Don't hash street for Meta.

### 2.6 Canonical Implementation Reference

| Environment | Function | Output format |
|---|---|---|
| Browser (NOT used here — server hashes) | `crypto.subtle.digest('SHA-256', new TextEncoder().encode(str))` then convert to hex | hex, lowercase |
| Cloudflare Worker (Node compat) | `import { createHash } from 'node:crypto'; createHash('sha256').update(str, 'utf8').digest('hex')` | hex, lowercase |
| Worker (Web Crypto only, no Node compat) | `crypto.subtle.digest('SHA-256', new TextEncoder().encode(str))` then `Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, '0')).join('')` | hex, lowercase |

**Always lowercase hex.** Meta's hash-comparator is case-sensitive on the hash itself; uppercase hex hashes will never match.

---

## 3. Per-Platform Payload Field Maps

### 3.1 A1 — Google Ads Enhanced Conversions for Leads

**No new tag.** Augment the existing GTM Google Ads Conversion tag (the one currently using conversion ID `18113251301` / label `PgcJCL_ck6IcEOWPib1D` per `gtm-snippets.txt` lines 96–101).

Conversion is keyed by GCLID (already captured by the Conversion Linker tag). Enhanced Conversions adds hashed user-provided data so Google can match the conversion to a logged-in user when GCLID is missing or expired.

**GTM tag config — User Provided Data section:**

| Tag config field | Source | Format |
|---|---|---|
| `email_address` | Cloudflare Worker pre-hashes and POSTs back hashed values? **NO — Google Ads Enhanced Conversions runs entirely in the browser via GTM.** Source the raw values from form fields via Data Layer Variables, then check **"Hash data in GTM"** in the User Provided Data settings. | raw (GTM hashes); OR pre-hashed lowercase hex SHA-256 if "Hash data in GTM" is unchecked |
| `phone_number` | Data Layer Variable from form | raw E.164 (GTM hashes); see normalization rules |
| `first_name` | Data Layer Variable from form | raw (GTM hashes) |
| `last_name` | Data Layer Variable from form (optional) | raw (GTM hashes) |
| `home_address.postal_code` | Data Layer Variable from form (parsed ZIP) | raw 5-digit (GTM hashes) |
| `home_address.country_code` | Hardcoded constant `US` | raw |

**Architecture decision:** Google Ads Enhanced Conversions is the ONE platform that runs browser-side via GTM, NOT through our Cloudflare Worker. Reasons:
1. GCLID lives in `_gcl_aw` cookie which is browser-only — easier to keep the conversion + enhanced data co-located.
2. GTM has built-in client-side hashing that matches Google's expected normalization exactly. Re-implementing it server-side risks subtle mismatches.
3. The Google Ads CAPI (Offline Conversion Import) is for true offline events (CRM sales matched back). Form-submit Enhanced Conversions belongs in GTM.

**Required dataLayer push** (already covered in Section 1.2, but explicitly enumerated for the GTM tag's Data Layer Variables):

```js
dataLayer.push({
  event: 'form_submit_quote',
  event_id: '<event_id>',
  enh_conv_user_data: {
    email: rawEmail,         // GTM Data Layer Variable: enh_conv_user_data.email
    phone: rawPhoneE164,     // GTM Data Layer Variable: enh_conv_user_data.phone
    first_name: rawFirstName,
    last_name: rawLastName,
    address: {
      postal_code: rawZip5,
      country: 'US'
    }
  }
});
```

In the GTM Google Ads Conversion tag, point each User Provided Data field at the corresponding Data Layer Variable, and **leave "Hash data in GTM" CHECKED** (default). GTM applies Google's canonical normalization (lowercase, trim, E.164 phone) before hashing.

**Reference docs:**
- https://support.google.com/google-ads/answer/13262500 (Enhanced Conversions for Leads — setup overview)
- https://support.google.com/tagmanager/answer/13438771 (GTM tag config for User Provided Data)
- https://support.google.com/google-ads/answer/13257235 (Field-level normalization rules — confirm against Section 2 of this spec)

**Verification expectation:** Google Ads → Tools → Conversions → click `from_submit_quotes` row → Diagnostics tab. "User-provided data" status should reach **"Recording: Good"** with **>70% match rate** within 48 hours of first hashed lead. The match-rate panel updates on a 24-hour delay.

### 3.2 A2 — Meta Conversions API

**Endpoint:**
```
POST https://graph.facebook.com/v19.0/1276568654662913/events?access_token=<META_CAPI_TOKEN>
Content-Type: application/json
```

(Pixel ID `1276568654662913` per `gtm-snippets.txt` line 23.)

**Payload structure (single event per request; we never batch since form submits are sub-1/sec):**

```json
{
  "data": [
    {
      "event_name": "Lead",
      "event_time": 1745812345,
      "event_id": "cwdb_1745812345678_a3f9c1d2",
      "event_source_url": "https://www.cwdeckbuilders.com/get-a-quote",
      "action_source": "website",
      "user_data": {
        "em": ["<sha256_hex_email>"],
        "ph": ["<sha256_hex_phone_e164>"],
        "fn": ["<sha256_hex_first_name>"],
        "ln": ["<sha256_hex_last_name>"],
        "zp": ["<sha256_hex_zip5>"],
        "ct": ["<sha256_hex_city>"],
        "st": ["<sha256_hex_state>"],
        "country": ["<sha256_hex_us>"],
        "client_user_agent": "<from request headers — User-Agent passed by browser>",
        "client_ip_address": "<CF-Connecting-IP header in Cloudflare Workers>",
        "fbc": "<value of _fbc cookie if present, else omit>",
        "fbp": "<value of _fbp cookie if present, else omit>"
      },
      "custom_data": {
        "value": 1000,
        "currency": "USD",
        "lead_event_source": "cwdeckbuilders.com",
        "form_step": 3,
        "content_category": "<budget bucket from form, e.g. '5k_10k'>",
        "content_name": "<project_type from form, e.g. 'new_deck'>"
      }
    }
  ]
}
```

**Field-by-field notes:**

| Field | Required? | Source | Note |
|---|---|---|---|
| `event_name` | Yes | constant `"Lead"` | Match the Pixel event name exactly for dedup |
| `event_time` | Yes | `Math.floor(Date.now() / 1000)` at the moment the Worker receives the POST | Unix seconds, NOT milliseconds |
| `event_id` | Yes for dedup | from browser request body | Must be IDENTICAL to the `eventID` in `fbq('track', 'Lead', {...}, {eventID})` |
| `event_source_url` | Strongly recommended | from browser request body `page_url` | Improves EMQ |
| `action_source` | Yes | constant `"website"` | Must be `"website"` for browser-originated events |
| `user_data.em/ph/fn/ln/zp/ct/st/country` | At least 2 strongly recommended for EMQ ≥ 6 | hashed in Worker per Section 2 | Each value is an array of one element (Meta supports multiple, we always send one) |
| `user_data.client_user_agent` | Required when `action_source: "website"` | `request.headers.get('User-Agent')` | NOT hashed |
| `user_data.client_ip_address` | Required when `action_source: "website"` | `request.headers.get('CF-Connecting-IP')` (Cloudflare-specific) | NOT hashed |
| `user_data.fbc` | Optional but huge EMQ boost | from browser request body (read `_fbc` cookie client-side, send raw to Worker) | Format: `fb.1.<creation_time>.<fbclid>` |
| `user_data.fbp` | Optional but huge EMQ boost | from browser request body (read `_fbp` cookie client-side, send raw to Worker) | Format: `fb.1.<creation_time>.<random>` |
| `custom_data.value` | Yes for ROAS | constant `1000` | Matches GTM Meta Pixel Lead tag; reflects target revenue per accepted bid |
| `custom_data.currency` | Yes | constant `"USD"` | |

**HTTP response handling:**
- 200 with `{"events_received": 1, "messages": [], "fbtrace_id": "..."}` → success.
- 400 with `{"error": {"message": "..."}}` → log to Cloudflare Logs but still return 200 to browser. Common 400s: bad `event_time` (must be within last 7 days), malformed hash (uppercase hex), missing required field.

**Required secret:** `META_CAPI_TOKEN`
- Provisioning: Meta Events Manager → Data Sources → select Pixel `1276568654662913` → Settings tab → Conversions API section → "Generate access token". Token is non-rotating but can be revoked. Store in Cloudflare Worker env var ONLY; never commit to repo.
- Token has `ads_management` + `business_management` scopes scoped to the Pixel.

**Reference docs:**
- https://developers.facebook.com/docs/marketing-api/conversions-api/get-started (CAPI overview)
- https://developers.facebook.com/docs/marketing-api/conversions-api/parameters/customer-information-parameters (full user_data field list and normalization rules)
- https://developers.facebook.com/docs/marketing-api/conversions-api/deduplicate-pixel-and-server-events (dedup contract)

**Verification expectation:** Meta Events Manager → Pixel `1276568654662913` → Test Events tab. Submit a test form and look for:
- Two events for `Lead` (one labeled "Browser", one labeled "Server") that **collapse into a single deduplicated event** within ~30 seconds.
- Event Match Quality (EMQ) score on the server event ≥ 6/10 within 24h of accumulated traffic. Higher is better; we aim for 8+ once `fbc`/`fbp` are flowing reliably.

### 3.3 A3 — GA4 Measurement Protocol

**Endpoint:**
```
POST https://www.google-analytics.com/mp/collect?measurement_id=G-ZQ19JEF9KC&api_secret=<GA4_API_SECRET>
Content-Type: application/json
```

(Measurement ID `G-ZQ19JEF9KC` per `gtm-snippets.txt` line 87.)

**Payload structure:**

```json
{
  "client_id": "<from _ga cookie if present, else generated UUIDv4>",
  "user_id": null,
  "timestamp_micros": 1745812345678000,
  "non_personalized_ads": false,
  "events": [
    {
      "name": "generate_lead",
      "params": {
        "event_id": "cwdb_1745812345678_a3f9c1d2",
        "currency": "USD",
        "value": 1000,
        "lead_source": "form_submit_quote",
        "form_location": "get_a_quote_page",
        "project_type": "new_deck",
        "budget_range": "10k_25k",
        "timeline": "1_3_months",
        "engagement_time_msec": "1",
        "session_id": "<from _ga_<container> cookie if parseable, else omit>"
      }
    }
  ]
}
```

**Field-by-field notes:**

| Field | Required? | Source | Note |
|---|---|---|---|
| `client_id` | Yes | Browser sends value of `_ga` cookie (parsed: `_ga` = `GA1.1.<client_id>` — split on `.` and take last 2 segments joined with `.`). If absent, generate a UUID v4 in the browser and send. | This MUST match the `_ga` cookie value the web stream is using, or GA4 will treat the server event as a separate user. |
| `events[].name` | Yes | constant `"generate_lead"` | GA4 recommended event for lead-gen; deliberately **different from web stream's `form_submit_quote`** to avoid double-counting in standard reports |
| `events[].params.event_id` | Yes for our observability | from browser request body | Used to cross-reference with web stream events in BigQuery export (Phase B) |
| `events[].params.value` + `currency` | Required for `generate_lead` | constants `1000` + `"USD"` | Matches the value used in Meta Pixel + Google Ads conversion |
| `events[].params.engagement_time_msec` | Required (any positive value) | constant `"1"` | GA4 quirk: server events without this are treated as bot traffic and excluded from reports |
| `events[].params.session_id` | Optional but recommended | Parse from `_ga_<measurement_id_suffix>` cookie if present | Ties server event to the same session as the web `form_submit_quote` event |

**HTTP response handling:**
- 204 No Content → success (GA4 MP returns empty body on success — no JSON).
- 4xx with debug endpoint can be used to test: send to `https://www.google-analytics.com/debug/mp/collect?...` (NOTE: `/debug/mp/collect` not `/mp/collect`) which returns validation messages but does NOT record the event. Use this in Cloudflare Worker dev mode only.

**Required secret:** `GA4_API_SECRET`
- Provisioning: GA4 Admin → Data Streams → click web stream for cwdeckbuilders.com → "Measurement Protocol API secrets" → "Create" → name it `cwdb-server-relay`. Copy the secret value (only shown once on creation; can rotate by deleting and creating new).
- Stream ID `533582902` per CLAUDE.md context.

**Reference docs:**
- https://developers.google.com/analytics/devguides/collection/protocol/ga4/sending-events (overview + payload)
- https://developers.google.com/analytics/devguides/collection/protocol/ga4/reference (full param reference)
- https://developers.google.com/analytics/devguides/collection/protocol/ga4/validating-events (debug endpoint)

**Verification expectation:** GA4 → Reports → Realtime → Events table within 10 minutes of test submission shows `generate_lead` with `event_id` matching the test value. DebugView (Admin → DebugView) requires the browser to send `debug_mode: true` in `params` — to test server events specifically, send debug payloads to `/debug/mp/collect` and inspect the response body for validation messages.

---

## 4. Serverless Endpoint Architecture

### 4.1 Recommended Host: Cloudflare Worker

Rationale:
- **Latency:** Cloudflare's edge network puts the Worker within 10–50ms of any US visitor; the form-submit fetch returns before the user finishes navigating to `/thank-you`.
- **Free tier:** 100,000 requests/day on the free plan. CWDB will hit ~50–500/day at Phase 2 targets — orders of magnitude under the cap.
- **Native support for `CF-Connecting-IP` header** (real client IP, required by Meta CAPI) and built-in env-var secret storage.
- **Simple deploy:** `wrangler deploy` from a 200-line `worker.js` file. No Docker, no Lambda packaging.
- **Logs:** `wrangler tail` for live, plus optional Logpush to R2/S3.

Fallback: Vercel Function (also good; pick if Jim already has Vercel infra and not Cloudflare). The spec is identical except for env-var syntax and the IP header (`x-forwarded-for` first IP on Vercel).

### 4.2 Endpoint Path

```
https://relay.cwdeckbuilders.com/lead-event
```

Subdomain `relay.cwdeckbuilders.com` requires a Cloudflare DNS CNAME pointing to Cloudflare Workers (the `*.workers.dev` route can be aliased via Workers Custom Domains feature). See Section 6 open question — Jim must confirm DNS authority is on Cloudflare.

If DNS is on GoDaddy still and Cloudflare proxy isn't in front of it, fallback option:
```
https://cwdb-relay.<chosen>.workers.dev/lead-event
```
This is the default `*.workers.dev` URL Cloudflare provisions; it works but is uglier and pollutes server logs with the Worker subdomain.

### 4.3 CORS

Worker must respond to `OPTIONS` preflight with:

```
Access-Control-Allow-Origin: https://www.cwdeckbuilders.com
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
Access-Control-Max-Age: 86400
```

Two allowed origins: `https://www.cwdeckbuilders.com` AND `https://cwdeckbuilders.com` (the apex 301s to www, but during transition or direct testing the apex may submit). Reflect the request `Origin` header back if it matches one of the allowlist; reject all others with 403.

POST-only on `/lead-event`. Reject other paths with 404.

### 4.4 Secrets Storage

Stored as Cloudflare Worker environment variables (encrypted at rest by Cloudflare; settable via `wrangler secret put`):

| Secret name | Source | Rotation cadence |
|---|---|---|
| `META_CAPI_TOKEN` | Meta Events Manager → CAPI → Generate Access Token | On suspected compromise; otherwise indefinite |
| `META_PIXEL_ID` | Hardcoded `1276568654662913` (already in `gtm-snippets.txt`) — store as env var anyway for portability when we add a second Pixel | n/a |
| `GA4_MEASUREMENT_ID` | Hardcoded `G-ZQ19JEF9KC` — store as env var | n/a |
| `GA4_API_SECRET` | GA4 Admin → Data Streams → Measurement Protocol API secrets → Create | On suspected compromise |
| `ALLOWED_ORIGINS` | Comma-separated list, default `https://www.cwdeckbuilders.com,https://cwdeckbuilders.com` | When a new domain is added |

**Never commit to repo.** `wrangler.toml` should reference `[vars]` only for non-secret config. The `wrangler secret put META_CAPI_TOKEN` flow stores encrypted and never appears in source.

### 4.5 Failure Mode

The Worker MUST always return 200 to the browser within 50ms, regardless of downstream success. Pattern:

```js
export default {
  async fetch(request, env, ctx) {
    if (request.method === 'OPTIONS') return corsPreflight(request, env);
    if (request.method !== 'POST') return new Response('Not found', { status: 404 });
    // ... CORS check, parse body, hash PII ...

    // Fire both downstreams in parallel; do not await for response body
    ctx.waitUntil(Promise.allSettled([
      fetchMetaCapi(payload, env).catch(err => log('meta_capi_fail', err)),
      fetchGa4Mp(payload, env).catch(err => log('ga4_mp_fail', err))
    ]));

    return new Response(JSON.stringify({ ok: true, event_id: payload.event_id }), {
      status: 200,
      headers: corsHeaders(request, env)
    });
  }
};
```

`ctx.waitUntil()` allows the Worker to keep the downstream fetches alive after responding to the browser. If either downstream fails:
- Browser still got 200 → no user impact.
- Browser Pixel + GA4 web stream + Google Ads conversion all still fired → primary signal preserved.
- Cloudflare Logs records the failure → analytics agent reviews weekly.

The browser-side signals are the source of truth. The server signals are augmentation. Server-only failures degrade EMQ and Enhanced Conversion match rate but do not affect conversion counting.

### 4.6 Rate Limiting

30 requests/minute per IP, returned as 429 with `Retry-After: 60`. Implementation: Cloudflare Workers KV-backed counter keyed by `CF-Connecting-IP`, TTL 60s.

Real expected traffic: <1 request per IP per day. Limit exists to catch:
- Form-submit loops (broken JS resubmitting on every keystroke).
- Adversarial replay of stolen `event_id`s to skew conversion counts.
- Bots probing the endpoint.

### 4.7 Code Sketch (for web-dev session — NOT to be implemented this session)

Approximate Worker structure web-dev will build:

```
worker/
├── wrangler.toml                  // routes, custom domain, vars
├── src/
│   ├── index.ts                   // fetch handler, CORS, dispatch
│   ├── normalize.ts               // hashEmail, hashPhone, splitName, extractZip
│   ├── meta.ts                    // CAPI POST builder
│   ├── ga4.ts                     // Measurement Protocol POST builder
│   └── log.ts                     // structured log emit
└── test/
    ├── normalize.test.ts          // unit tests for hashing — every example in Section 2
    ├── meta.test.ts               // mock Meta endpoint, assert payload shape
    └── ga4.test.ts                // mock GA4 endpoint
```

Web-dev session deliverable list:
1. `wrangler init` + `wrangler.toml` with custom domain config.
2. Implement hashing module with unit tests covering every Section 2 example (Mary Jane Watson, Cher, gmail dots, +alias, ZIP+4, etc.).
3. Implement Meta + GA4 dispatchers with mocked endpoints in tests.
4. Wire CORS + rate limit + `ctx.waitUntil` pattern.
5. Browser-side: add the form-submit JS from Section 1.2 to Webflow site `<head>` custom code OR as a registered site script (preferred, follows the `hero_form_handoff` pattern from CLAUDE.md memory).
6. GTM: update existing Meta Pixel Lead tag to read `event_id` from dataLayer and pass via `eventID` parameter to `fbq`. Update Google Ads conversion tag to enable User Provided Data with the dataLayer variables.
7. Provision secrets via `wrangler secret put` (Jim runs these or pairs with web-dev).
8. Run Section 5 verification checklist end-to-end on a single test submission before announcing GA.

---

## 5. Verification Checklist (Analytics Agent Owns)

Run after web-dev ships and Jim has fired a single test submission via the production form on `/get-a-quote`.

### 5.1 Pre-Flight (before test submission)

- [ ] `relay.cwdeckbuilders.com/lead-event` returns 200 to a curl POST with a minimal valid body. (Direct Worker health check.)
- [ ] `relay.cwdeckbuilders.com/lead-event` returns 403 to a POST with `Origin: https://example.com`. (CORS allowlist enforced.)
- [ ] `relay.cwdeckbuilders.com/lead-event` returns 405 (or 404) to GET. (Method enforcement.)
- [ ] Cloudflare Worker env vars confirmed set: `META_CAPI_TOKEN`, `META_PIXEL_ID`, `GA4_MEASUREMENT_ID`, `GA4_API_SECRET`. (`wrangler secret list`.)
- [ ] Browser-side form-submit JS deployed to production (visible in `<head>` or as registered site script in Webflow).
- [ ] GTM Meta Pixel Lead tag updated to pass `eventID` from `{{DLV - event_id}}` Data Layer Variable.
- [ ] GTM Google Ads Conversion tag has User Provided Data section configured with the 5 fields from Section 3.1, "Hash data in GTM" checked.
- [ ] Both above GTM changes published to live container (not Preview only).

### 5.2 Test Submission

Submit the production form with Jim's real PII (use his actual contact info — Meta and Google will reject obviously-fake test data and skew EMQ).

### 5.3 Within 5 Minutes

- [ ] Cloudflare Worker logs show 1 hit on `/lead-event` with 200 response, `event_id` matches the submitted test.
- [ ] Cloudflare Worker logs show no `meta_capi_fail` or `ga4_mp_fail` entries for that `event_id`.
- [ ] Meta Events Manager → Test Events tab → both `Lead` events visible (Browser and Server), badge shows "Deduplicated" within ~30s.
- [ ] GA4 → Realtime → `generate_lead` event from server stream appears (visible as event with our `event_id` parameter when filtered).

### 5.4 Within 24 Hours

- [ ] Meta Events Manager → Overview → EMQ score for `Lead` event ≥ 6/10. (Single test won't move EMQ much; check after 5–10 submits.)
- [ ] GA4 → Reports → Engagement → Events shows `generate_lead` count incrementing without doubling `form_submit_quote` count (proves no double-attribution).

### 5.5 Within 48 Hours

- [ ] Google Ads → Tools → Conversions → `from_submit_quotes` → Diagnostics tab shows User-Provided Data status: **"Recording: Good"** with match rate **>70%**.
- [ ] No 4xx or 5xx errors in Cloudflare Worker logs over the period (browse `wrangler tail` or Logs dashboard).

### 5.6 Ongoing (analytics agent monthly review)

- [ ] Meta EMQ stays >7. If drops, audit `fbc`/`fbp` cookie capture and re-verify Section 2 normalization didn't drift.
- [ ] Google Ads Enhanced Conversions match rate stays >65%. If drops, suspect form field changes (e.g. address parsing failing on a new freeform pattern).
- [ ] Worker error rate stays <1% of total requests.

---

## 6. Open Questions for Jim (Escalate Via State-File Outbox)

1. **Cloudflare Worker vs Vercel Function.** Plan default is Cloudflare Worker. Confirm CWDB DNS is on Cloudflare (or willing to migrate). If GoDaddy DNS only and Jim doesn't want to move, fall back to Vercel Function (deploy on free tier from a fresh Vercel project). Spec is portable; only Section 4 changes.
2. **Subdomain `relay.cwdeckbuilders.com`.** OK to provision a CNAME for this? Alternative: use the default `*.workers.dev` URL Cloudflare hands out (uglier in network logs but functionally identical). No customer-facing exposure either way.
3. **Where to store secrets if not Cloudflare Worker env vars?** Default is encrypted Worker env vars (`wrangler secret put`). Alternatives: 1Password CLI integration, Doppler, AWS Secrets Manager. None are needed for Phase A scale; recommend stick with Worker env vars.
4. **Should the Worker also forward a copy of the lead to HubSpot via API?** Currently HubSpot intake is manual from the Webflow form-submission email Jim receives. If we add HubSpot API insert from the Worker, leads flow into the CRM with zero manual steps. **Recommendation: defer** — adds a third dependency to Phase A's surface area, and the manual flow works at <10 leads/week. Revisit when reactivation triggers from `pivot-2026-04-19.md` fire.

---

## 7. Out of Scope for Phase A

| Item | Why deferred | When to revisit |
|---|---|---|
| Lifecycle events (`Qualified Lead`, `Accepted Bid`, `Job Won`) | Requires HubSpot pipeline buildout (currently manual tracking); requires Make scenario reactivation (parked per pivot-2026-04-19). | Phase B — gated on ≥10 leads/week OR 3rd contractor signs OR first accepted bid logged. |
| Customer Match audience sync (Google Ads) | Needs ≥1,000 hashed customer records to seed an audience. We have 2 contractor customers. | After ~100 closed-won homeowners (likely Phase 3 expansion). |
| Server-side GTM container | Architecturally redundant — the Cloudflare Worker IS our server-side component. Adopting Server GTM doubles infra cost ($120/mo on App Engine minimum) for no incremental signal. | If/when we exceed 1M monthly events and need GTM's batching + Cloud Logging integration. |
| Nextdoor server-side | Per 2026-04-25 audit decision (memory: tracking-status). Nextdoor pixel stays browser-only; their CAPI maturity is poor and their volume share is small. | When Nextdoor paid spend exceeds 20% of total ad spend. |
| TikTok Events API | TikTok ad spend is $0 today and not in launch plan. | If/when TikTok is added to active platforms. |
| BigQuery export of GA4 + cross-stream `event_id` join | Useful for cohort analysis but Phase A doesn't need cross-stream reconciliation beyond manual spot-checks. | Phase B reporting. |

---

## 8. Implementation Sequence (Web-Dev Session)

A suggested order for the follow-up web-dev session:

1. **Worker scaffold + hashing module + unit tests** — verifiable in isolation; no live secrets needed.
2. **Worker dispatchers (Meta + GA4) + mocked endpoint tests** — verifiable without provisioning real secrets.
3. **Provision secrets** (Jim's part — ~15 min in Meta Events Manager + GA4 Admin UI; reference Section 4.4).
4. **Worker deploy to staging URL** (`*.workers.dev`); run direct curl tests against Section 5.1 checklist.
5. **DNS CNAME for `relay.cwdeckbuilders.com`** (after Section 6 question 2 resolves).
6. **Browser-side form-submit JS deploy** (Webflow site script registration; mirror the `hero_form_handoff` deployment pattern from CLAUDE.md memory).
7. **GTM tag updates** — Meta Pixel Lead `eventID` parameter; Google Ads Conversion User Provided Data section.
8. **Run Section 5.2 test submission + Section 5.3 verification.**
9. **Wait 24h, run Section 5.4 verification.** If EMQ <6 or anything red, debug per Section 2 normalization rules first (90% of issues live there).
10. **Wait 48h, run Section 5.5 verification.** Announce Phase A complete in `_vault/state-of-cwdb.md` Outbox.

---

## 9. Changelog

- 2026-04-27 — Initial spec authored by analytics agent (WS-1 Phase A). Ready for web-dev implementation in follow-up session.
