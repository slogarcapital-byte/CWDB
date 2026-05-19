# CWDB Tracking Plan

**Purpose:** Single source of truth for every event the site fires, its parameters, and which platforms receive it. Every GTM tag, GA4 event, Meta Pixel custom event, Nextdoor event, and Google Ads conversion references this document.

**Scope:** Central Wisconsin Deck Builders — cwdeckbuilders.com (21-page Webflow site).

**Owner:** Analytics agent.

---

## Naming Conventions

- **Event names:** `snake_case`, verb-style (`form_submit_quote`, not `QuoteSubmitted`). Same name across every platform — no per-platform renaming.
- **Parameters:** `snake_case`, scoped (`form_location` not just `location`).
- **Values:** lowercase strings for enums (`homepage`, `city_page`, `blog`). Booleans as `true`/`false`. Currency as numbers, no `$`.

---

## Core Events

The site fires **6 standard events**. Every tag in GTM maps to exactly one row in this table.

| # | Event name | When it fires | Primary purpose | Conversion? |
|---|---|---|---|---|
| 1 | `form_submit_quote` | Quote form successfully submits on `/get-a-quote` (thank-you redirect confirms) | **Primary conversion.** Homeowner requested a quote. | **Yes** — Google Ads, Meta, Nextdoor |
| 2 | `calculator_complete` | Cost calculator renders an estimate on `/cost-calculator` | High-intent micro-conversion. Shows the user engaged deeply. | Meta, Nextdoor (as custom events) |
| 3 | `phone_click` | User taps/clicks any `tel:` link | Captures mobile call intent (phone often replaces form). | **Yes** — Google Ads (secondary) |
| 4 | `cta_click` | User clicks any element with class `cta-primary` or `cta-secondary` | Funnel diagnostic — which CTAs drive vs. dead-end. | No (GA4 only) |
| 5 | `scroll_depth` | User reaches 50% or 90% of page height (GTM built-in trigger) | Engagement signal for bounce-rate quality check. | No (GA4 only) |
| 6 | `blog_read_complete` | User reaches 90% of a blog article body | Content ROI signal for blog pieces. | No (GA4 only) |

---

## Event Schemas

### 1. `form_submit_quote`

**Trigger:** Successful Webflow native form submission on `/get-a-quote`. Preferred detection: the thank-you page redirect (`/thank-you`), which guarantees the submission was accepted by Webflow. Backup: Webflow form success event in GTM.

**Parameters:**

| Name | Type | Example | Notes |
|---|---|---|---|
| `project_type` | string | `new_deck`, `deck_replacement`, `repair` | From form field |
| `city` | string | `wausau` | From form field (address parse or dropdown) |
| `budget_range` | string | `5k_10k`, `10k_25k`, `25k_plus` | From form dropdown |
| `timeline` | string | `asap`, `1_3_months`, `3_6_months`, `exploring` | From form dropdown |
| `form_location` | string | `get_a_quote_page`, `homepage_inline`, `city_page_inline` | Which page the form was submitted from (we have multiple inline instances) |
| `value` | number | `1000` | Static value = $1,000 (target revenue per accepted bid) — used for Google Ads bidding |
| `currency` | string | `USD` | Static |

**Platform mapping:**

| Platform | Event name there | Notes |
|---|---|---|
| GA4 | `form_submit_quote` (mark as **Key Event**) | Also send as `generate_lead` (GA4 recommended event) for enhanced reports |
| Meta Pixel | `Lead` (standard event) | Send `value: 1000`, `currency: USD` for value-based lookalikes |
| Nextdoor Pixel | `Lead` (standard event) | Same value/currency |
| Google Ads | Conversion "Quote Request" | Value = 1000, currency USD, count = one per click |

---

### 2. `calculator_complete`

**Trigger:** `dataLayer.push({event: 'calculator_complete', ...})` from `/website/pages/cost-calculator/calculator.js` after the estimate is rendered. Add the push right after the estimate appears on screen.

**Parameters:**

| Name | Type | Example | Notes |
|---|---|---|---|
| `estimate_low` | number | `12500` | Low end of estimate range |
| `estimate_high` | number | `18000` | High end |
| `deck_sqft` | number | `240` | |
| `material` | string | `composite`, `cedar`, `pressure_treated` | |
| `features` | string | `railing,steps,lighting` | Comma-joined list |

**Platform mapping:**

| Platform | Event name |
|---|---|
| GA4 | `calculator_complete` |
| Meta | `CustomizeProduct` (standard) — value = estimate_high |
| Nextdoor | `ViewContent` (standard) |

---

### 3. `phone_click`

**Trigger:** GTM click trigger — `Click URL starts with tel:`.

**Parameters:**

| Name | Type | Example |
|---|---|---|
| `phone_number` | string | `+17155551234` |
| `page_location` | string | `/wausau` (auto from GTM) |
| `device_type` | string | `mobile`, `desktop` |

**Platform mapping:**

| Platform | Event name |
|---|---|
| GA4 | `phone_click` (mark as Key Event) |
| Google Ads | Secondary conversion "Phone Call" — count-once |
| Meta | `Contact` (standard) |

---

### 4. `cta_click`

**Trigger:** GTM click trigger — `Click Classes contains cta-primary` OR `cta-secondary`.

**Parameters:**

| Name | Type | Example |
|---|---|---|
| `cta_text` | string | `Get My Free Quote` |
| `cta_location` | string | `hero`, `mid_page`, `sticky_bar`, `footer` |
| `cta_variant` | string | `primary`, `secondary` |

**Platform mapping:** GA4 only.

---

### 5. `scroll_depth`

**Trigger:** GTM built-in Scroll Depth trigger. Thresholds: 50%, 90%.

**Parameters:** Auto-captured by GTM (`percent_scrolled`).

**Platform mapping:** GA4 only.

---

### 6. `blog_read_complete`

**Trigger:** Scroll Depth trigger scoped to pages matching `/blog/*` (not `/blog` index). Threshold: 90%.

**Parameters:**

| Name | Type | Example |
|---|---|---|
| `article_slug` | string | `deck-cost-wisconsin` |
| `article_category` | string | `cost`, `materials`, `permits`, `timing` |

**Platform mapping:** GA4 only.

---

## Automatic Page Views

The GA4 Configuration tag fires `page_view` on all pages automatically. No manual event needed. Meta/Nextdoor Pixels fire `PageView` via their base installs.

---

## User Properties (GA4)

Set once per session via GTM where detectable:

| Property | Values | Source |
|---|---|---|
| `entry_city_page` | `wausau`, `schofield`, `weston`, `mosinee`, `merrill`, `none` | First city page in session |
| `traffic_source_category` | `paid_search`, `paid_social`, `nextdoor`, `organic`, `direct`, `referral` | UTM / referrer parsing |

---

## What We Are NOT Tracking (by design)

- **Individual form field focus/blur events** — noise, no signal.
- **Time on page as an event** — GA4 captures engagement time automatically; a separate event is redundant.
- **Outbound clicks** — no outbound links worth tracking on this site yet.
- **Video plays** — no video content on the site currently.
- **PII in events** — never send email, phone, name, or address as event parameters. All PII stays in HubSpot.

---

## IDs to Collect (Phase F10–F11)

Fill in as each account is created; mirror into `.claude/agent-memory/analytics/tracking-status.md`.

| Tool | ID format | Captured |
|---|---|---|
| GTM container | `GTM-XXXXXXX` | TBD |
| GA4 measurement ID | `G-XXXXXXXXXX` | TBD |
| Meta Pixel ID | 15–16 digit numeric | TBD |
| Nextdoor Pixel ID | numeric | TBD |
| Google Ads customer ID | `XXX-XXX-XXXX` | TBD |
| Google Ads conversion ID | `AW-XXXXXXXXX/label` | TBD |
| MS Clarity project ID | alphanumeric string | TBD |

---

## Verification Checklist (used in F17)

For each event, confirm it reaches each destination:

- [ ] `form_submit_quote` → GA4 DebugView → Meta Pixel Helper → Nextdoor dashboard → Google Ads conversion status
- [ ] `calculator_complete` → GA4 DebugView → Meta → Nextdoor
- [ ] `phone_click` → GA4 DebugView → Google Ads → Meta
- [ ] `cta_click` → GA4 DebugView
- [ ] `scroll_depth` → GA4 DebugView (50% + 90%)
- [ ] `blog_read_complete` → GA4 DebugView on a `/blog/*` page

---

## Changelog

- 2026-04-16 — Initial draft (Phase F kickoff).
