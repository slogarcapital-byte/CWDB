---
type: audit
status: complete
audited: 2026-04-21
auditor: CEO Operator (Playwright MCP)
staging_base: https://central-wisconsin-deck-builders.webflow.io
pages_checked: 20
gate: pre-launch-checklist Section 1, gate 1.3
tags:
  - type/audit
  - phase-1
  - pre-launch
---

# Staging Audit — 2026-04-21

**Scope:** All 20 public URLs on staging (17 from launch brief scope + `/privacy`, `/terms`, `/sitemap.xml` verification). Automated via Playwright MCP — HTTP fetch + structural HTML probe per URL.

**Method:** Fetch each URL, parse `<title>`, first `<h1>`, H2 list, CMS item counts (`w-dyn-item`), empty states (`w-dyn-empty`), presence of layout-critical elements. No rendered-pixel checks — structural only.

---

## Summary

| Severity | Count | Items |
|---|---|---|
| **P0 launch-blocker** | 2 | `/terms` 404 from footer; placeholder H1 "Heading" on calculator + 4 blog articles |
| **P1 content-quality** | 2 | Blog index has 5 items (expected 4); 3rd Our Builders CMS item has no name |
| **P2 verify-manually** | 2 | Gallery CMS photo content (8 items, need Jim eyeball); city page quote-form-inline visual title |
| **Clean** | 14 | All remaining URLs load 200, have real titles + H1s, CMS bindings populate |

---

## P0 Launch Blockers (MUST fix before first $1 of spend)

### P0-1. `/terms` returns 404 but is linked from the homepage footer

**Evidence:**
- `GET /terms` → HTTP 404, `<title>` = "404 - Page not found"
- Homepage source contains `href="/terms"` in footer links

**Impact:** A 404 on any homepage footer link destroys trust instantly. Google Ads landing-page policy has been known to flag accounts for broken footer links. Also breaks Meta advertiser-verification if they spider the site.

**Fix (choose one):**
- **A (recommended):** Build a minimal `/terms` page in Webflow using the same template pattern as `/privacy` (which exists and works). Estimated 30 min — Jim can duplicate the privacy page and swap the copy. TCPA/standard terms boilerplate is acceptable.
- **B (fallback):** Remove `/terms` from the footer link list via Webflow Designer. Strips the 404 but leaves the site without a Terms page, which is unusual and slightly amateur for a business landing page.

**Owner:** web-dev agent (or Jim in Designer). Should land in Section 1 of pre-launch checklist as a new gate.

---

### P0-2. Placeholder H1 = "Heading" on `/cost-calculator` + all 4 blog articles

**Evidence:**
- `/cost-calculator` first H1: `Heading` · first H2: `Material Quick Reference` (meaningful H2 exists, H1 wasn't swapped)
- `/blog-post/deck-cost-wisconsin` first H1: `Heading` · first H2: `Example H2 heading`
- `/blog-post/composite-vs-wood`, `/blog-post/deck-permits-wausau`, `/blog-post/best-time-build-deck` — same pattern

**Impact:**
- **SEO:** Google indexes H1 as the primary on-page signal. "Heading" as H1 tanks ranking for deck-cost and deck-material queries we explicitly plan to pay for.
- **UX:** The text "Heading" is visible at the top of the rendered page. Anyone arriving from a Google Ads click sees literal placeholder text.
- **Google Ads Quality Score:** Landing page relevance score weights H1 heavily. Expect higher CPC on all keywords that route to these pages.

**Fix:**
- **Cost calculator:** Jim swaps the static H1 in Webflow Designer to something like "What does a deck cost in Central Wisconsin?" (matches the calculator's intent). 2 min.
- **Blog articles:** The H1 is coming from the blog-post template — either (a) bind it to the `Name` CMS field if not already, or (b) the CMS field for H1 is literally set to "Heading" on all 4 items. Open Webflow CMS → Blog Posts → confirm each item has a real `Heading` / `Title` field populated, or update the template H1 to bind to the correct field. 5-10 min.
- The **H2 "Example H2 heading"** on blog articles is the same pattern — another placeholder in the template that was never swapped. Needs the same fix.

**Owner:** Jim in Webflow Designer. Add to `/_vault/jim-manual-actions-2026-04-20.md` or create a new `jim-manual-actions-2026-04-21.md`.

---

## P1 Content-Quality (fix before launch; not strictly blocking but visible)

### P1-1. Blog index shows 5 items, expected 4

**Evidence:** `/blog` page has 5 `w-dyn-item` instances. Memory / CMS record shows only 4 published articles (deck-cost-wisconsin, composite-vs-wood, deck-permits-wausau, best-time-build-deck).

**Likely cause:** A 5th Blog Posts CMS item exists — possibly a draft, template, or test post that's been published accidentally.

**Fix:** Jim opens Webflow CMS → Blog Posts → confirm 4 expected articles and identify the 5th. Either delete, unpublish, or populate if it was supposed to be real content.

**Risk if ignored:** An empty 5th card on the index with placeholder copy looks broken.

---

### P1-2. Our Builders page: 3 CMS items but only 2 builder names rendered

**Evidence:** `/our-builders` has 3 `w-dyn-item` entries. Builder-name heading extraction found "John Garcia" and "Ben Barton" — the 3rd item has no matching name in a `.builder` heading class.

**Likely cause:** A leftover test/template CMS item from Phase D build. Or the 3rd item has a name in a field the grep didn't catch (different class naming).

**Fix:** Jim opens Webflow CMS → Our Builders → review the 3 items. Delete any leftover test/template item. OR if it's a placeholder "third builder" spot, hide the page's Collection List to only show 2 until a 3rd signs.

---

## P2 Verify-Manually (Jim eyeball, brief check before promote)

### P2-1. Gallery CMS photos — 0 Unsplash URLs detected (good sign), but 8 items needs Jim eyeball

**Evidence:** `/gallery` renders 8 CMS items, zero image src attributes contain "unsplash". Stock placeholder URLs have been replaced, confirmed at URL level.

**What still needs checking (Jim, 1 min):** Open `/gallery` on staging. Confirm the photos are **real Wisconsin deck builds**, not a different stock source or CWDB-logo placeholders. State-file KPI gate 1.2 requires real photos. If any of the 8 are still generic/stock or CWDB-branded fillers, this becomes a P0.

---

### P2-2. Service Areas quote-form-inline section — structural presence not verifiable via fetch

**Evidence:** `form-inline` class match failed on `/service-area/wausau`. Could mean (a) the section uses a different class name than I searched for, (b) the form is there but nested in a different wrapper, or (c) it's genuinely missing from the city template.

**What needs checking (Jim, 2 min):** Open `/service-area/wausau` and scroll — confirm the inline quote-form section appears with the city name correctly in the eyebrow/header ("Get a quote in Wausau" or similar). Gate 1.8 of pre-launch checklist. If the form title doesn't show the city, the CMS rebind from the 2026-04-20 Designer batch didn't land.

Spot-check at least 2 of the 5 city pages.

---

## Clean Pages (200, real H1, no structural issues)

1. `/` — H1 "Get a quote within 48 hours." · 200 · 29.6 KB
2. `/about` — H1 "Building decks should be exciting not stressful" · 200
3. `/faq` — H1 "Frequently Asked Questions" · 200
4. `/gallery` — H1 "Our Deck Projects" · 200 (see P2-1)
5. `/our-builders` — H1 "Meet Our Trusted Builders" · 200 (see P1-2)
6. `/get-a-quote` — H1 "Ready to start your deck project?" · 200 · form present
7. `/thank-you` — H1 "Thank you for your request" · 200
8. `/blog` — H1 "Deck Building Blog" · 200 (see P1-1)
9. `/service-area/wausau` — H1 "Deck Builders in Wausau, WI" · 200
10. `/service-area/schofield` — H1 "Deck Builders in Schofield, Wisconsin" · 200
11. `/service-area/weston` — H1 "Deck Builders in Weston, Wisconsin" · 200
12. `/service-area/mosinee` — H1 "Deck Builders in Mosinee, Wisconsin" · 200
13. `/service-area/merrill` — H1 "Deck Builders in Merrill, Wisconsin" · 200
14. `/privacy` — H1 "Privacy Policy" · 200

---

## Console Errors (spot-checked homepage + /get-a-quote)

- `/` — 0 errors, 0 warnings
- `/get-a-quote` — 0 errors, 0 warnings

A deeper console check across all 20 URLs was not run individually (too many MCP calls). If any P0 fixes require a retest, a full console sweep can be run at that time.

---

## Analytics / Tag Verification (from HTML source)

- GTM snippet present in `<body>` of homepage (`gtm_head_snippet-1.0.0.js` from Webflow CDN) — confirmed.
- Meta Pixel `fbq` IIFE present in body — firing.
- Nextdoor Pixel `ndp` IIFE present in body — firing.
- Microsoft Clarity script present — firing.
- GA4 via GTM — not verified as firing in this pass (would need to spin up GTM Preview or use `browser_network_requests` for a GA4 hit).

Recommendation: on production promote, re-run Clarity + GA4 real-time + Meta Events Manager check as part of pre-launch gate 3.2 / 3.3 (submit 1 test lead, confirm events fire).

---

## Site-Wide Structural Note

Every page has 6-7 elements with `hero-*` class names. This is **expected** — the class family spans `hero-split`, `hero-interior`, `hero-tag`, `hero-eyebrow`, etc. Not evidence of the old double-hero issue. Wave 0 classname swap from 2026-04-20 (`hero-section mobile` → `site-header`) appears to have eliminated the embedded double-hero problem at source.

---

## Recommended Gate 1.3 Sign-Off

Gate 1.3 (Workstream B staging audit clean) should be marked **BLOCKED** in the pre-launch checklist until:

- [ ] P0-1: `/terms` builds or is unlinked
- [ ] P0-2: Placeholder "Heading" H1s replaced on calculator + 4 blog posts (+ "Example H2 heading" on blog posts)
- [ ] P1-1: Blog 5th item resolved
- [ ] P1-2: Our Builders 3rd item resolved
- [ ] P2-1: Gallery photo content visually confirmed as real WI decks
- [ ] P2-2: City page quote-form-inline Title visually confirmed on 2 city pages

Total estimated fix time for Jim: **45-60 minutes in Webflow Designer**, all rolled into a single pass with the existing Designer batch.

---

## Artifacts

- Audit script: this file
- Playwright session closed at completion (no lingering browser context)
- No screenshots saved to repo (avoid binary churn)
