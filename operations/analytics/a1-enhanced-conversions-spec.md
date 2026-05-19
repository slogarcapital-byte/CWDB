---
type: spec
dept: operations/analytics
created: 2026-04-30
updated: 2026-04-30
status: ready-for-execution
owner: cwdb-ceo-operator
parallel_track: yes
no_hubspot_dependency: yes
estimated_match_rate_lift: 60-80% within 48h
---

# A1 — Google Ads Enhanced Conversions for Leads (GTM-Only)

> **Quick-win track.** Independent of HubSpot pipeline. Ships in parallel with everything else.
> **Lift:** Google's documented 60-80% match-rate increase within 48 hours of activation. At our spend ($30/day), this means more conversions get attributed back to the click, which means Smart Bidding gets cleaner signal, which means CPL drops without changing a thing about the ads themselves.
> **Why now:** The form rebuild already collects email + phone first-class on Step 1. The only missing piece is hashing them and pushing to Google's conversion tag.

---

## §1 What we're shipping

Two changes to the existing `quote_page_polish` site-applied script (or a new sibling script `enhanced_conversions_v1.0.0`):

1. **On form submit (before redirect):** hash email + phone (SHA-256, lowercase, trimmed) per Google's spec, push them onto `dataLayer` alongside a `form_submit` event.
2. **In GTM:** modify the existing Google Ads Conversion tag to read the hashed values from dataLayer and send them as User Provided Data alongside the existing `gtag` conversion fire.

Net code added: ~30 lines JS in the site-script, one new dataLayer variable in GTM, one tag config change in GTM.

---

## §2 Site-script change (Webflow `data_scripts_tool` apply)

Either (a) extend the existing `quote_page_polish` script with the new hashing block, or (b) ship a sibling `enhanced_conversions-1.0.0.js` script applied to the homepage + /get-a-quote pages. Recommend (b) for clean rollback.

### 2.1 New script body

```js
// enhanced_conversions-1.0.0.js
// Hashes email + phone on form submit and pushes to dataLayer for Google Ads Enhanced Conversions for Leads.
// Spec: https://support.google.com/google-ads/answer/13262500

(function () {
  'use strict';

  if (window.__cwdb_enhanced_conv_loaded) return;
  window.__cwdb_enhanced_conv_loaded = true;

  // SHA-256 helper using SubtleCrypto (browser-native, no library)
  async function sha256Hex(input) {
    if (!input) return '';
    const cleaned = String(input).trim().toLowerCase();
    const buf = new TextEncoder().encode(cleaned);
    const hash = await crypto.subtle.digest('SHA-256', buf);
    return Array.from(new Uint8Array(hash))
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('');
  }

  // Normalize phone: strip non-digits, prepend +1 for US numbers
  function normalizePhone(raw) {
    if (!raw) return '';
    const digits = String(raw).replace(/\D/g, '');
    if (digits.length === 10) return '+1' + digits;
    if (digits.length === 11 && digits.startsWith('1')) return '+' + digits;
    return digits ? '+' + digits : '';
  }

  // Find the form on the page
  function getForm() {
    return (
      document.querySelector('form[action*="get-a-quote"]') ||
      document.querySelector('form[name*="quote"]') ||
      document.querySelector('form[id*="Quote"]') ||
      document.querySelector('form[data-name*="quote" i]')
    );
  }

  function attachHandler() {
    const form = getForm();
    if (!form) return false;

    form.addEventListener(
      'submit',
      async function (e) {
        try {
          const emailEl = form.querySelector('input[type="email"], input[name*="email" i]');
          const phoneEl = form.querySelector('input[type="tel"], input[name*="phone" i]');
          const nameEl = form.querySelector('input[name*="name" i]:not([type="hidden"])');

          const email = emailEl ? emailEl.value : '';
          const phoneNorm = normalizePhone(phoneEl ? phoneEl.value : '');
          const name = nameEl ? nameEl.value.trim() : '';
          const nameParts = name.split(/\s+/);
          const first = nameParts[0] || '';
          const last = nameParts.slice(1).join(' ') || '';

          const [emailHash, phoneHash, firstHash, lastHash] = await Promise.all([
            sha256Hex(email),
            sha256Hex(phoneNorm),
            sha256Hex(first),
            sha256Hex(last),
          ]);

          window.dataLayer = window.dataLayer || [];
          window.dataLayer.push({
            event: 'form_submit_with_user_data',
            user_data: {
              sha256_email_address: emailHash,
              sha256_phone_number: phoneHash,
              address: {
                sha256_first_name: firstHash,
                sha256_last_name: lastHash,
              },
            },
          });
        } catch (err) {
          // Never block submit on hashing failure
          console && console.warn && console.warn('[CWDB EC] hash error', err);
        }
      },
      true // capture phase — fires BEFORE the existing handlers' redirect
    );
    return true;
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', attachHandler);
  } else {
    attachHandler();
  }
})();
```

### 2.2 Apply via Webflow MCP

```
data_scripts_tool register
  - hostedLocation: registers via inlineScript=script body, version="1.0.0", displayName="Enhanced Conversions for Leads"
data_scripts_tool apply
  - target: homepage (because hero form lives there) + /get-a-quote
  - location: footer
```

---

## §3 GTM changes

### 3.1 New Variable: `DLV - user_data`

- GTM → Variables → New → Data Layer Variable
- Variable name: `dlv.user_data`
- Data Layer Variable Name: `user_data`
- Data Layer Version: 2
- Save.

### 3.2 New Trigger: `Form Submit With User Data`

- GTM → Triggers → New → Custom Event
- Trigger name: `Custom — form_submit_with_user_data`
- Event name: `form_submit_with_user_data`
- Fires on: All Custom Events
- Save.

### 3.3 Modify the existing Google Ads Conversion tag

- GTM → Tags → Open the existing `Google Ads Conversion — Quote Form Submit` tag
- Confirm: Conversion ID = `AW-18113251301`, Conversion Label = `PgcJCL_ck6IcEOWPib1D` (per canonical tracking-ID memory)
- Scroll to **"Include user-provided data from your website"** section → toggle ON
- User Data Source → New User-Provided Data Variable:
  - Type: User-Provided Data
  - Variable name: `User Data — Quote Form`
  - Data Source: Manual Configuration
  - Email: `{{dlv.user_data}}.sha256_email_address`
  - Phone Number: `{{dlv.user_data}}.sha256_phone_number`
  - First Name: `{{dlv.user_data}}.address.sha256_first_name`
  - Last Name: `{{dlv.user_data}}.address.sha256_last_name`
  - **Important:** check the "Already hashed" toggle for each field (we hash client-side; don't double-hash).
- Trigger: keep existing trigger (the form_submit event); ADD the new `Custom — form_submit_with_user_data` trigger so the tag fires on either signal.

### 3.4 Test in GTM Preview

- Preview mode → load `/get-a-quote` → submit with test data
- In Tag Assistant: confirm Google Ads Conversion tag fires with User Provided Data block populated and hashes visible
- In Network tab: confirm the conversion-fire request to `googleads.g.doubleclick.net` includes the `enhanced_conversion_data` payload

### 3.5 Publish

- Save → Submit → Publish container version → Note version number

---

## §4 Verification window

- **t+0:** Publish.
- **t+24-48h:** Google Ads → Tools → Conversions → `from_submit_quotes` → Diagnostics tab. Look for "Enhanced conversions for leads — Status: Recording data" with a non-zero matched-conversions count.
- **t+72h:** Match rate visible in same Diagnostics tab. Target: ≥30% in week 1, ≥50% by week 4.
- **t+7d:** CPL trend in the existing weekly review. Expectation: 5-15% CPL improvement on the same hook (Smart Bidding now has cleaner signal).

---

## §5 Rollback

If anything breaks:

- Remove the `enhanced_conversions-1.0.0.js` script from applied pages via `data_scripts_tool apply` with empty target list, OR pause the GTM Tag.
- The existing conversion tag still fires the bare conversion (without user data) — no regression.

---

## §6 Owner

- **Builder:** analytics agent OR Jim (since changes are GTM-side; site-script change requires Webflow MCP and can be done by web-dev or CEO).
- **Time-box:** 2 hours total (script write 30m + Webflow apply 15m + GTM config 45m + Preview test 30m).
- **Decision authority:** None needed — additive change, fully reversible.
