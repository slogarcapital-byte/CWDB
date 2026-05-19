# Pre-Launch P0 — Designer-Required Actions
**Date**: 2026-04-22 (ad launch day)
**Source of truth for blocker list**. All items below are blocked by the well-documented Webflow MCP single-locale limitation ("locale must be a secondary locale" error on all component/page static-content writes). They must be executed by hand in the Webflow Designer.

---

## Open Designer URL

https://central-wisconsin-deck-builders.design.webflow.com/

After each batch below: Publish site to both `cwdeckbuilders.com` and `www.cwdeckbuilders.com`.

---

## BLOCK 1 — Footer component (fixes P0-1 + P1-7 + P1-8-partial)

**Component**: `footer` (component ID `16ed2b41-9560-24aa-44d6-089f1ffb26d7`)

### 1a. Service Areas column — 5 hrefs (P0-1)

Open the `footer` component in Designer. Under the "SERVICE AREAS" column, click each link and change the URL field:

| Link text | Change from            | Change to               |
|-----------|------------------------|-------------------------|
| Wausau    | `/deck-builders-wausau`    | `/service-area/wausau`    |
| Schofield | `/deck-builders-schofield` | `/service-area/schofield` |
| Weston    | `/deck-builders-weston`    | `/service-area/weston`    |
| Mosinee   | `/deck-builders-mosinee`   | `/service-area/mosinee`   |
| Merrill   | `/deck-builders-merrill`   | `/service-area/merrill`   |

### 1b. Footer phone href (small fix alongside)

In the footer logo-row column there is an `<a>` at the top with text `(715) 544-7941` and `href="#"`. Change href to `tel:+17155447941`.

Also in the CONTACT column, the phone-number link `(715) 544-7941` uses `href="#"`. Change to `tel:+17155447941`.

### 1c. Footer NAP (P1-7)

The CONTACT column currently shows just "Central Wisconsin" as address. Replace with full canonical NAP. Click the existing `<p class="footer-link">Central Wisconsin</p>` and replace its content. Then above it, add:

```
906 N 16th Ave
Wausau, WI 54401
```

Below the phone line, add a new footer-link pointing to `mailto:info@cwdeckbuilders.com` with text `info@cwdeckbuilders.com`.

Final CONTACT column should read (top to bottom):
```
CONTACT
906 N 16th Ave
Wausau, WI 54401
(715) 544-7941        (tel:+17155447941)
info@cwdeckbuilders.com (mailto:info@cwdeckbuilders.com)
Get a Free Quote      (/get-a-quote)
Mon–Fri 8am–6pm CT
```

---

## BLOCK 2 — Header component — Resources dropdown hrefs (P1-8)

**Component**: `header` (component ID `17135213-0f65-1d96-c6af-955d586e2f00`)

Open the header → Resources dropdown. Four links have `href="#"`. Update:

| Link text          | Change to                    |
|--------------------|------------------------------|
| Cost Calculator    | `/cost-calculator`           |
| Deck Permits Guide | `/blog/deck-permits-wausau`  |
| Blog               | `/blog`                      |
| FAQ                | `/faq`                       |

---

## BLOCK 3 — /get-a-quote wizard form fields (P0-3 + P1-10)

**Page**: /get-a-quote (page ID `69ce4163e79002c5d4762a57`).

For each of the following fields, set the placeholder text, fix the `<label for="">` to match the input id, and add these custom attributes. All five inputs currently have `placeholder="Example text"` (Webflow default that was never replaced).

Also **remove the `placeholder` attribute entirely** from `input[name="page_source"]` (that one is hidden — no need for a placeholder).

| Input id           | name      | type    | placeholder                                                      | label for target | custom attrs                                            |
|--------------------|-----------|---------|------------------------------------------------------------------|------------------|---------------------------------------------------------|
| `wizard-name`      | name      | text    | `Jane Smith`                                                     | `wizard-name`    | `aria-label="Full name"`                                |
| `wizard-email`     | email     | email   | `you@email.com`                                                  | `wizard-email`   | `aria-label="Email address"`                            |
| `wizard-zip`       | zip       | text    | `54401`                                                          | `wizard-zip`     | `aria-label="ZIP code"` + verify `inputmode="numeric"` already present |
| `wizard-phone`     | phone     | tel     | `(715) 555-0100`                                                 | `wizard-phone`   | `aria-label="Phone number"` + `inputmode="tel"`         |
| `wizard-address`   | address   | text    | `123 Main St, Wausau`                                            | `wizard-address` | `aria-label="Property address"`                         |
| `wizard-notes`     | notes     | textarea| `e.g. 12x16 composite with railing, off the back of the house`   | `wizard-notes`   | `aria-label="Project notes"`                            |

**Selects** — replace `placeholder="Example text"` if present; Webflow select placeholder is the first-option text. Ensure the first `<option>` in each is a disabled/placeholder:
- Project Type select → first option text `Select project type` (already present in screenshot — confirm)
- Budget select → first option `Select budget range`
- Timeline select → first option `Select timeline`
- Own property select → first option `Select one` (already present in screenshot — confirm)

**Labels** — every `<label>` currently has `for=""` (empty). Click each label element and set the For Attribute in Designer's element settings panel to match the corresponding input id above.

### Also while on /get-a-quote:
**Hero sub paragraph** — currently reads "Fill out the form below and hear from licensed Central Wisconsin deck builders within 24 hours. Free. No obligation." Change `24 hours` → `48 hours`.

---

## BLOCK 4 — 5 service-area inline quote forms (P0-3 continued)

Each city page (`/service-area/<city>`) uses the `quote-form-inline` component which contains a static paragraph ending in **"...reach out within 24 hours."**

Open the `quote-form-inline` component (component ID in inventory: `e71ba2ae-93c5-a86e-264a-976a176c91b0`) and change `24 hours` → `48 hours`. Single component edit replicates to all 5 city pages.

While in the `quote-form-inline` component, same label/placeholder sweep as BLOCK 3 for any fields that still have `placeholder="Example text"` — apply the same placeholder/aria-label/label-for pattern.

---

## BLOCK 5 — Homepage FAQ component + Homepage Custom Code (P0-2 remainder + P0-4)

### 5a. `faq-section-home` component

**Component**: `faq-section-home` (component ID `89e82a46-a8d3-cf05-801c-8ab696580bcb`)

The third FAQ answer reads "Most homeowners hear from a contractor within 24 hours..." — change `24 hours` → `48 hours`. (FAQ CMS already updated, but this component hard-codes the answer text, so the component must be updated separately.)

### 5b. Homepage Custom Code — delete dev-note leak, paste JSON-LD (P0-4)

Open Page Settings for **Home** → Custom Code.

**"Before `</body>` tag" section** currently contains literal markdown-style text:
```
/operations/analytics/json-ld-snippets/homepage-localbusiness.html (includes <script type="application/ld+json"> wrapper)
```
followed by two `<script src="...gtm_head_snippet...">` lines.

**Action**: DELETE THE FIRST LINE only (the devnote path). Keep the GTM script lines. OR clear the entire Before-Body-Tag box if those GTM scripts are being duplicated (they are already registered site-wide via the scripts API).

**"Inside `<head>` tag" section** — paste the full LocalBusiness JSON-LD. Source file (copy entire contents verbatim):

```
C:\Users\jslog\OneDrive\Desktop\Slogars\CPA\Slogar-Capital\Claude\Projects\CWDB\operations\analytics\json-ld-snippets\homepage-localbusiness.html
```

That file is the correct `<script type="application/ld+json">...</script>` block. After pasting, validate with https://search.google.com/test/rich-results after publish.

---

## BLOCK 6 — /cost-calculator hero subtitle (P0-2 remainder)

**Page**: /cost-calculator

The `hero-interior__subtitle` on this page reads "Expert deck builders serving your city in Central Wisconsin. Free quotes within 24 hours." Change `24 hours` → `48 hours`.

This is likely a per-instance property override on the `hero-interior` component. Edit in place on the page.

---

## BLOCK 7 — /faq page static body + head (P0-2 remainder)

The /faq page appears to hard-code its FAQ answers in page body (not CMS-bound) AND includes a static FAQPage JSON-LD in Custom Code head with the same 24-hour text.

Two edits on /faq:
1. Body — find the answer for "How quickly will I hear back?" and change `24 hours` → `48 hours`.
2. Custom Code head — find the FAQPage JSON-LD script and edit the same answer's `text` value from `24 hours` → `48 hours`.

---

## BLOCK 8 — Homepage hero form labels + inputmode (P1-10)

**Component**: `hero-split` (component ID `0f19c38f-c81b-c27b-46e6-e5e3fa6807f1`)

Zip and phone inputs currently have correct placeholders (54401, (715) 555-0123) but the labels are not wired:
- Add `for="hero-zip"` on the Zip label; add `id="hero-zip"` and `aria-label="ZIP code"`, `inputmode="numeric"` on the input.
- Add `for="hero-phone"` on the Phone label; add `id="hero-phone"` and `aria-label="Phone number"`, `inputmode="tel"` on the input.

---

## Publish checklist after all 8 blocks

1. Publish to `cwdeckbuilders.com`
2. Publish to `www.cwdeckbuilders.com`
3. Publish to Webflow subdomain for staging sanity check
4. Re-run verification crawl — expected state:
   - `/deck-builders-` count across all pages = 0
   - `"24 hours"` count site-wide = 0
   - `placeholder="Example text"` count = 0
   - Hero form handoff still lands at `/get-a-quote?zip=...&phone=...`
   - Homepage top-of-body has no stray text; one `<script type="application/ld+json">` LocalBusiness is present and parses at https://search.google.com/test/rich-results

---

## Why this couldn't be fixed via MCP

Per project memory: **"Per-instance Component Property overrides are Designer-only on single-locale sites"**. The CWDB site has no secondary locales, which means:
- `update_component_content` / `update_static_content` endpoints reject all write attempts with `locale must be a secondary locale`.
- Data API: CMS updates + page-level SEO settings + scripts registration all work.
- Designer API write tools need an open Webflow Designer session (not available in autonomous runs).

Already fixed via Data API and published:
- 5 Service Areas CMS items: `meta-description`, `hero-subheadline`, `city-intro`, `faq-5-answer` all `24h → 48h`.
- FAQs CMS item "How quickly will I hear back?" → `48 hours`.
- /get-a-quote page-level SEO description → `48 hours`.

Everything else above is Designer-required.

---

## Round 2 — 2026-04-23

**Context**: Jim's post-launch mobile audit surfaced 6 additional issues. The single-locale Webflow API still blocks every static text/property override, but Data API **script registration works and applies site-wide automatically**. Round 2 was shipped via a new inline site script `cwdb_round_2_fixes` (v1.1.0, 2000-char budget, footer location, auto-applied to all 16 pages).

**Published**: both `cwdeckbuilders.com` and `www.cwdeckbuilders.com` @ 2026-04-23.

### Fixed via MCP (script injection — no Designer action required)

| ID | Fix | Mechanism |
|----|-----|-----------|
| R2-1 | Mobile hamburger now opens a populated drawer (Home, About, Builders, Gallery, Cost Calculator, FAQ, Blog, Get a Quote). Logo was already `<a href="/">`-wrapped, no change needed. | Script rewrites `.w-nav-menu` innerHTML if it contains only the placeholder "Link" node. |
| R2-2 | "First Name*" field injected above Zip on `/get-a-quote` wizard. `name="firstname"` maps to HubSpot's standard contact property; `required`, `aria-label="First name"`, `placeholder="Jane"`, `autocomplete="given-name"`. | Script inserts label+input before `#wizard-zip`. |
| R2-3 | NEXT button now `display:inline-flex`, `align-items:center`, `justify-content:center`, `font-size:18px`, `line-height:1`, Crafted Orange halo `0 0 24px 4px rgba(229,76,0,.5), 0 4px 14px rgba(229,76,0,.3)` plus brighter hover. | CSS override on `a.btn-submit` + `.btn-submit.w-button`. |
| R2-4 | `hero-interior` mobile padding-top raised 64px → 104px (96px + 8px safety). H1 now sits 76px below sticky header on mobile (was 36px). Desktop bumped to 120px. | CSS override. Verified on `/faq` and `/about`. |
| R2-5 | "Join Our Builder Network" already points to `mailto:info@cwdeckbuilders.com?subject=Interested%20in%20joining%20CWDB%20builder%20network` on `/our-builders`. Site-wide scan of 14 pages confirms it's the only instance. No fix was required. | Verification only. |
| R2-6 | Mobile sticky bottom banner `display:none`. New `.cwdb-top-bar` slides in from the top (56px, Crafted Orange, Staatliches, links to `/get-a-quote`) when `scrollY > 600px` on mobile / `> 800px` on desktop. Includes × dismiss button that sets `sessionStorage['cwdbBar']='1'` to suppress for the session. | New DOM node inserted into `<body>`, scroll listener. |

Scripts registered:
- `cwdb_round_2_fixes` v1.0.0 (5:30 UTC) + v1.1.0 (5:34 UTC, drawer-stack polish). Both apply; 1.1.0 takes precedence for styles.
- Hosted: `cdn.prod.website-files.com/.../cwdb_round_2_fixes-1.1.0.js`.

### Appended to DESIGNER-HANDOFF.md — open items for Jim

**Block 9 — Mobile nav drawer vertical stack (P2, polish)**

Current state: clicking the hamburger opens the Webflow `.w-nav-overlay`, which now contains all 8 links, but the existing `.w-nav-menu` base styles flex them in a horizontal wrap row. The CSS override in the script (`.w-nav-overlay .w-nav-menu { display:flex !important; flex-direction:column }`) is being beaten by a higher-specificity Webflow base rule.

In Designer, open the `header` component → find the `navbar mobile > w-nav-menu` element → at the Medium breakpoint (≤991px) set:
- `display: flex`
- `flex-direction: column`
- `background: #323434`
- `padding: 8px 0`

And on the `.nav-link` children at the same breakpoint:
- `padding: 16px 24px`
- `color: #fff`
- `border-bottom: 1px solid rgba(255,255,255,0.08)`
- `font-family: Staatliches`
- `font-size: 18px`
- `letter-spacing: 0.06em`

And (optional) add a `.nav-link.cta` combo class on the "Get a Quote" link with `background: #e54c00`, `margin: 12px 16px`, `border-radius: 6px`, `text-align: center`, `border-bottom: 0` — the script already adds the `nav-link-cta` class; align to whatever naming Jim prefers.

**Block 10 — Persist nav links as real component nodes (P2, hygiene)**

The R2 script rewrites `.w-nav-menu.innerHTML` on every page load as a soft-inject. Long-term, the eight nav links should be authored as real Webflow elements inside the `header` component so they appear in:
- View source HTML (SEO crawlability — currently Googlebot sees the placeholder "Link" in rendered HTML; dynamic inject arrives post-paint)
- The `header` component content returned by the Webflow API (currently only contains the placeholder)
- Webflow's Designer component preview (empty drawer hurts anyone else editing the header)

In Designer, open the `header` component → remove the placeholder `<a>Link</a>` → add 8 new Link elements inside `.w-nav-menu` with the same slugs as the hardcoded list in R2-6. The R2 script's guard (`length <= 1`) means it will silently no-op once real links are in place, so no coordination needed.

**Block 11 — `scroll-banner-cta` component (P3, migrate script → native component)**

Same pattern: the R2 script injects the top banner via JS for speed. Long-term, convert it to a proper Webflow component named `scroll-banner-cta` so it's:
- Editable in Designer
- Included in the component inventory
- Not dependent on a script file

Spec to build:
- Fixed 56px band at top of body, `z-index: 9999`
- Crafted Orange `#e54c00` background, white Staatliches text
- Contains a single `<a href="/get-a-quote">GET YOUR FREE QUOTE →</a>` + dismiss `×` button
- Hidden by default (`transform: translateY(-100%)`), `.show` modifier slides in
- A tiny (under 500 char) inline Webflow interaction can replace the scroll listener

Once the native component is placed in the global body wrapper on every page, delete the banner chunk from `cwdb_round_2_fixes` and bump the version.

### Why these three couldn't ship in Round 2

All three are standard Designer-authorable work; none hit the locale wall. They were scoped as Round-3 polish items because the Round 2 script budget (2000 chars) was spent on the six P0/P1 functional fixes, and Jim's ad launch today needed functional-first.

---

## Round 3 — 2026-04-23

**Context**: Jim's second-pass mobile audit (6 findings A–F). Phase-0 verification on production found most of his complaints were already fixed by Round-2 but two real problems remained: (B) the wizard Step 1 was missing an Email field, and (D) the `/get-a-quote` hero H1 was clipped by the sticky 72px header (the R2 hero padding only targeted `.hero-interior`; `/get-a-quote` uses `.hero-h1`). Round 3 also hardens against duplicate top-bar injection caused by v1.0.0 + v1.1.0 + v1.2.0 all being applied simultaneously.

**Published**: both `cwdeckbuilders.com` and `www.cwdeckbuilders.com` @ 2026-04-23.

### Fixed via MCP (script injection — no Designer action required)

| ID | Fix | Mechanism |
|----|-----|-----------|
| R3-1 | `/get-a-quote` H1 no longer clipped. `.hero-h1` now gets `padding-top: 96px` at ≤767px (`.hero-section-quote` and `.hero-split` covered by the same rule). | CSS override in `cwdb_round_2_fixes-1.2.0.js`. |
| R3-2 | Wizard Step 1 now injects **Email** field after First Name on `/get-a-quote` (`name="email"`, `type="email"`, `autocomplete="email"`, `inputmode="email"`, `required`). First Name (R2-2) still injects as well. | Idempotent DOM insert in the same script. |
| R3-3 | Duplicate `.cwdb-top-bar` elements removed. The v1.0.0, v1.1.0, and v1.2.0 scripts all load in sequence; a `window.__cwdbR2Loaded` guard + a post-paint `.cwdb-top-bar` dedupe sweep ensures only one banner exists in the DOM. | Script-level idempotency flag. |
| R3-4 | Stronger bottom-banner hide: `.mobile-sticky-bar, [class*="mobile-sticky-bar"] { display:none !important }`. Confirmed on homepage production DOM; element collapses to 0×0. | CSS override. |

Scripts registered:
- `cwdb_round_2_fixes` v1.2.0 (2026-04-23 UTC). Hosted: `cdn.prod.website-files.com/.../cwdb_round_2_fixes-1.2.0.js`.

### Phase-0 findings that were already fixed in Round 2 (no R3 action needed)

| Finding (Jim's R2 screenshots) | Production state confirmed |
|--------------------------------|---------------------------|
| A1 — Hamburger non-functional | FIXED — `.w-nav-menu` has all 8 links; drawer opens on tap. |
| A2 — Stray "Link" text under header | FIXED — no stray nodes in top 200px of any page. |
| A3 — Logo not linked to `/` | FIXED — logo `<img>` is wrapped in `<a href="/" class="header-logo-text">`. |
| C — NEXT button styling | FIXED — `display:inline-flex`, `align-items:center`, `font-size:18px`, Crafted Orange halo `box-shadow: 0 0 24px 4px rgba(229,76,0,.5), 0 4px 14px rgba(229,76,0,.3)`, brighter on hover. |
| E — "Join Our Builder Network" dead link | FIXED — `href="mailto:info@cwdeckbuilders.com?subject=Interested%20in%20joining%20CWDB%20builder%20network"`. |
| F — Bottom sticky banner vs. scroll-triggered top bar | FIXED — `.mobile-sticky-bar` hidden, `#cwdb-top-bar` slides in at `scrollY > 600` on mobile. |

---

## Designer-required items for Round 3 (append-only — do not modify blocks 1–11)

### BLOCK 12 — Persist First Name + Email as real Webflow form inputs on `/get-a-quote` wizard

**Why**: The Round-2/Round-3 scripts inject these fields into Step 1 at runtime via DOM manipulation. This works functionally today (users see the inputs, form submission captures them), **but**:
- If the script CDN ever 404s or loads late, Step 1 ships without the fields.
- Googlebot sees the pre-inject DOM — no name/email labels in crawled HTML.
- The Webflow native form schema has no knowledge of these fields, so HubSpot mapping and server-side validation are fragile.

**Designer action** — open `/get-a-quote` (page ID `69ce4163e79002c5d4762a57`) → find the Step 1 container (the `.wizard-step[data-step="1"]` element) → add two new Webflow Text Field inputs + labels **above** the existing Zip field:

| Input id        | name        | type   | placeholder       | required | label text   | custom attrs                                                                    |
|-----------------|-------------|--------|-------------------|----------|--------------|---------------------------------------------------------------------------------|
| `wizard-name`   | `firstname` | text   | `Jane`            | yes      | `First Name*`| `aria-label="First name"`, `autocomplete="given-name"`                          |
| `wizard-email`  | `email`     | email  | `you@email.com`   | yes      | `Email*`     | `aria-label="Email address"`, `autocomplete="email"`, `inputmode="email"`       |

Each label needs its `for=` attribute wired to the matching input id. Final Step 1 order: First Name → Email → Zip Code → Phone Number.

After adding: the R3 script's `if(!document.getElementById('wizard-name'))` and `if(!document.getElementById('wizard-email'))` guards will silently no-op, so no coordination needed.

---

### BLOCK 13 — Remove `.hero-h1` padding workaround once `/get-a-quote` migrates to `hero-interior`

**Why**: `/get-a-quote` currently uses a page-level element with class `.hero-h1` instead of the site's canonical `hero-interior` component. The R3 script patches this with `padding-top: 96px !important` at mobile, but the long-term fix is to swap the page to use `hero-interior` (same as FAQ, About, city pages).

**Designer action** — open `/get-a-quote`, select the current hero block, replace with a `hero-interior` component instance (the Title override pattern used site-wide). Once live, delete the `.hero-h1` rule from `cwdb_round_2_fixes` and bump to v1.3.0.

Not a launch blocker — R3 CSS is functional. This is Phase 2.5 hygiene.

---

### BLOCK 14 — Promote `cwdb_round_2_fixes` to a native Webflow component + delete legacy v1.0.0/v1.1.0 applications

**Why**: Three versions of `cwdb_round_2_fixes` are currently applied to the site simultaneously (v1.0.0, v1.1.0, v1.2.0). The v1.2.0 `window.__cwdbR2Loaded` guard makes the older scripts no-op, but every mobile visitor still downloads three JS files (~11 KB wasted on mobile). MCP has no "unapply site script" endpoint, so:

**Designer action** — in Webflow Dashboard → Site Settings → Custom Code → Registered Scripts → Applied Scripts panel, uncheck the v1.0.0 and v1.1.0 rows of `cwdb_round_2_fixes`. Leave v1.2.0 checked. Publish.

Alternative: Settings → Apps & Integrations → the CWDB Webflow App registration → remove the old versions. Either path results in a single applied script.

---

### BLOCK 15 — `/for-builders` recruitment page (post-launch, P3)

**Why**: The "Join Our Builder Network" CTA on `/our-builders` currently links to `mailto:info@cwdeckbuilders.com` as a stopgap (R2-5). Better conversion path is a dedicated recruitment page with: value prop, lead volume estimate, pay-per-accepted-bid pricing, Barton/Garcia testimonials, short intake form.

**Designer action** — build new page `/for-builders` using `hero-interior` + static sections. Wire the two existing "Join Our Builder Network" CTAs (one on `/our-builders`, likely also a dark CTA band at the bottom of homepage or footer) from `mailto:` → `/for-builders`.

Not a launch blocker. File as P3 post-launch work after first 10 leads ship.

---

### Summary grid — what shipped where in Round 3

| Item | Method | Status |
|------|--------|--------|
| `/get-a-quote` hero clipping | MCP (v1.2.0 CSS) | SHIPPED |
| Email field in wizard Step 1 | MCP (v1.2.0 DOM inject) | SHIPPED |
| Duplicate top-bar dedupe | MCP (v1.2.0 guard) | SHIPPED |
| Bottom banner stronger hide | MCP (v1.2.0 CSS) | SHIPPED |
| Native firstname + email form fields | Designer (Block 12) | HANDOFF |
| `/get-a-quote` use `hero-interior` | Designer (Block 13) | HANDOFF |
| Unapply v1.0.0 + v1.1.0 scripts | Designer (Block 14) | HANDOFF |
| `/for-builders` recruitment page | Designer (Block 15) | HANDOFF (P3) |

---

### BLOCK 16 — Native head/meta work: /faq JSON-LD revalidation + meta descriptions + crosslink to Block 9/12

Bundled Designer-only chore consolidating three items that cannot be cleanly patched from a footer-scoped runtime script.

**16a. `/faq` FAQPage JSON-LD — revalidate and re-author in Designer**

The existing `<script type="application/ld+json">` block on `/faq` (authored 2026-04-17, head-level custom code) contains literal newline characters inside string-typed JSON values (answer text). `JSON.parse()` on that source throws, which is why v1.0.1 quietly removed the tag via its `document.querySelectorAll('body>script[type="application/ld+json"]')` unparsable-JSON sweep — meaning Google's Rich Results Test will find no FAQPage schema on `/faq` today. The Round 3 runtime rebuild of FAQPage JSON-LD in v1.0.1 only fires on client navigation to `/faq` and is not in the static HTML Googlebot parses on first crawl.

**Designer action** — open `/faq` → Page Settings → Custom Code → `<head>` tag. Either:
- (recommended) Rewrite each answer's `text` property to escape real newlines as `\n` rather than using a raw multi-line string, and confirm it `JSON.parse`s before saving. Paste result between `<script type="application/ld+json">` tags.
- Or flatten each answer to a single line (strip linebreaks entirely) so the JSON is syntactically valid without escapes.

Validate at `https://search.google.com/test/rich-results` with the published `/faq` URL. Launch-blocker for SEO rich-result eligibility, but NOT a launch-blocker for paid traffic.

**16b. Meta descriptions — static HTML only, not runtime-patchable**

Crawlers (Google, Facebook OG, Nextdoor preview) read meta description from static HTML on first fetch. Runtime JS cannot influence that. Every page that ships without a meta description today will render a Google-generated snippet.

**Designer action** — open each of the 21 pages' Page Settings → SEO → Description, author 140–160 char description. Batch in Designer; publish. Priority order for paid-ad landing pages: `/`, `/get-a-quote`, `/service-area/wausau`, `/service-area/weston`, `/service-area/schofield`, `/service-area/mosinee`, `/service-area/merrill`.

**16c. Cross-reference to Block 9 + Block 12**

Block 16a-16b sit alongside already-documented native form work:
- **Block 9** — wizard form fields promoted to native Webflow form inputs (replace JS-injected inputs)
- **Block 12** — native `First Name` + `Email` field wiring with proper `for=` attributes

All four items share the root constraint: **static HTML / Webflow-native authoring is the correct surface. Runtime JS patches are stopgaps only.** Cluster as one Designer batch session.

| Sub-block | Surface | Priority | SEO vs conversion |
|-----------|---------|----------|-------------------|
| 16a FAQPage JSON-LD | `/faq` head | P1 (rich results) | SEO |
| 16b Meta descriptions (21 pages) | Page Settings SEO | P1 (paid landing) + P2 (rest) | Both |
| 16c Cross-ref: Block 9 + 12 (native form fields) | `/get-a-quote` form | P1 (form reliability) | Conversion |

---

## BLOCK 17 — TCPA consent label on /get-a-quote Step 3 (script-patched)

**Status**: SHIPPED as stopgap via `cwdb_launch_polish-1.2.0.js` (registered 2026-04-23, site-wide footer script). Runtime JS patch replaces the Webflow-default checkbox label (which rendered the literal field name `tcpa_consent`) with the full legal disclosure + Privacy/Terms links. Checkbox is also force-set to `required` + `aria-required="true"`, and the injected `<label for>` is wired to the checkbox id.

**Why this needs a Designer fix later**: The checkbox on the wizard's Step 3 lives inside a Webflow native form field that uses the field's `name` as the label fallback. The script fix is non-destructive and idempotent, but a durable native fix is preferable (fewer runtime scripts; crawler-visible label text for accessibility/compliance audits).

### 17a. Native fix path (do in Designer when convenient)

1. Open `/get-a-quote` in Designer (page ID `69ce4163e79002c5d4762a57`).
2. Navigate to Step 3 of the wizard (the `.wizard-step` that contains the Estimated Budget / Timeline / Notes fields).
3. Find the checkbox field (currently `name="tcpa_consent"`, `id="checkbox"`).
4. Click the label element (`.w-form-label` span sibling) and replace its text with the exact string below. Webflow's label editor supports inline links — use it to add the Privacy Policy + Terms anchors.

### Exact label string (paste-ready)

```
By submitting, I agree to receive calls, texts, and emails from Central Wisconsin Deck Builders and its partner contractors at the phone and email provided about my deck project. Consent is not a condition of service. Message and data rates may apply. Reply STOP to opt out. See our Privacy Policy and Terms.
```

Link wiring:
- "Privacy Policy" → `/privacy`
- "Terms" → `/terms`

### 17b. Optional styling (to match current script output)

```css
.w-checkbox:has(input[name="tcpa_consent"]) { display:flex; align-items:flex-start; gap:8px; }
.w-checkbox:has(input[name="tcpa_consent"]) .w-form-label { font-size:12px; line-height:1.4; color:#646760; }
.w-checkbox:has(input[name="tcpa_consent"]) .w-form-label a { color:#83b2cf; text-decoration:underline; }
```

### 17c. Once the native label ships

The script-patched version is idempotent — it detects any real label (`textContent.length > 30`) and short-circuits without modifying the DOM. Safe to leave in place indefinitely. Optional cleanup: remove `cwdb_launch_polish-1.2.0` from site-applied scripts after native fix verified.

**Service-area inline quote form** (`.quote-form-inline` on `/service-area/<city>`): already ships with the correct TCPA label natively — verified 2026-04-23 on `/service-area/wausau`. No action required.

---

## BLOCK 18 — Cost calculator is broken (P0, added 2026-04-23, Round 6)

**Page**: `/cost-calculator` (page ID `69d04360b87483b9bbc76b04`)
**Diagnosis**: Someone pasted the contents of `/website/pages/cost-calculator/calculator.js` into Page Settings → Custom Code → Before `</body>` **without** wrapping it in `<script>` tags. The browser is rendering the JavaScript source code as plain text at the bottom of the page body (visible in the viewport). The calculator never initializes because no `<script>` element exists. The mount div `<div id="cwdb-calculator">` is present and correctly placed inside `section#calculator-section > div.container-inner > div.calculator-section-inner` — leave it alone.

Fix requires two Designer actions on the `/cost-calculator` page:

### 18a. Open the page Custom Code panel

1. Open the Designer.
2. Navigate to the `Cost Calculator` page.
3. Press `P` for Pages panel, hover the "Cost Calculator" page, click the gear icon for page settings.
4. Scroll to **Custom Code → Before `</body>` tag**.
5. You will see the raw JavaScript (starts with `/** CWDB Deck Cost Calculator ... (function () { 'use strict'; ...`). **Delete all of it.**

### 18b. Paste the corrected version

Replace with the file below in its entirety (this is the same calculator.js wrapped with `<script>` tags):

```html
<script>
```
…paste the full contents of `/website/pages/cost-calculator/calculator.js` here…
```html
</script>
```

The exact paste-ready string is at `/website/pages/cost-calculator/calculator-paste.html` (created 2026-04-23).

Save → close page settings → **Publish to both `cwdeckbuilders.com` and `www.cwdeckbuilders.com`**.

### 18c. Verify

Hard-reload `/cost-calculator` on production. Expected:

- No plain-text JavaScript at the bottom of the body.
- A form renders inside the "Calculator" section: Deck Size select, Material select, Features checkboxes, City select, orange "Calculate My Estimate" button.
- Pick size `12×16 (192)`, material `Composite`, check Railing + Stairs. Click Calculate. Expected range: **$7,460 – $18,020** (verified via synthetic injection 2026-04-23).
- Result panel shows disclaimer + orange "Get My Exact Quote — Free" CTA linking to `/get-a-quote`.
- Open DevTools → Application → `window.dataLayer` → after clicking Calculate, the tail entry should be `{event: "calculator_use", calc_size: 192, calc_material: "composite", calc_low: 7460, calc_high: 18020, ...}`.

### 18d. Why this wasn't auto-fixed via MCP

The native page Custom Code field (where the broken paste lives) is not exposed by the Webflow Data Pages API — it only returns page metadata/SEO/slug. The Data Scripts API (inline site scripts) has a 2000-character cap per script and a 15-script-per-site registration block cap; the calculator is 10.7KB and the CWDB site is already at 14/15 script slots. A site-script-chain deploy would require freeing slots and coordinating 4 chained registrations plus a manual clear of the broken native paste anyway. The paste-replace flow above is strictly simpler and shorter.

There is one artifact to discard after 18a–b ships: a placeholder script `cwdbCalcCss` v1.0.0 was registered during diagnosis (it is not applied to any page). Leave it — it consumes one registration slot but does nothing. Clean up later when deregistration tooling is available.

