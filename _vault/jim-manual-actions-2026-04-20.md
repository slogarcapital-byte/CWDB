---
type: manual-actions-queue
session-id: "2026-04-20-001"
created: 2026-04-20
tags:
  - manual-actions
  - phase-2
  - revamp
---

# Jim's Manual Actions — 2026-04-20 End of Session

> **How to use:** work top-to-bottom. Items grouped by urgency. Each has exact click path + why it matters. This is the full backlog accumulated during autonomous Phase 2 / 2.5 / Step 11 execution.

---

## P0 — DO BEFORE NEXT AD SPEND

### 1. Form → email delivery verification (carried, unchanged)

- **Where:** `https://www.cwdeckbuilders.com/get-a-quote`
- **Action:** Submit one test entry with real info (can use your own name + zip)
- **Confirm:** notification email lands in the expected inbox
- **Why:** Without this verified, every ad dollar risks leaking leads into a black hole. This is the #1 pre-launch gate.
- **Time:** 5 min

---

## P1 — WEBFLOW DESIGNER MANUAL ACTIONS (known MCP gaps)

*MCP can't do these. You handle in Webflow Designer after the agents finish.*

### 2. `cta-final` — Add Component Properties

- **Where:** Webflow Designer → Components panel → open `cta-final` component
- **Action:**
  - Right-click the headline text element → "Add property" → name `headline` → type Plain Text
  - Right-click the CTA button label → "Add property" → name `cta_label` → type Plain Text
  - Right-click the CTA button → "Add property" on its link → name `cta_href` → type URL/Link
- **Why:** Without these, city pages / blog / About can't override the CTA headline per page — everyone would see the homepage default copy.
- **Time:** 2 min

### 3. `hero-interior` — Add Component Properties + Bind to Service Areas CMS

This is the P0 blocker for Phase 2.5 Part B (the embedded-hero-in-`header` nuke). Until this is done, all 5 city pages show the placeholder text "DECK BUILDERS IN YOUR CITY" instead of their correct city-specific title.

- **Where:** Webflow Designer → Components panel → open `hero-interior` component (ID `ec0fc950-6cea-2755-d848-50ade4f2af3c`, group "Heroes")
- **Action 1 — Create 4 Component Properties:**
  - Right-click `.hero-interior__eyebrow` text → "Add property" → name `eyebrow` → Plain Text
  - Right-click `.hero-interior__title` text → "Add property" → name `title` → Plain Text
  - Right-click `.hero-interior__subtitle` text → "Add property" → name `subtitle` → Plain Text
  - Right-click `.hero-interior__bg` background image → "Add property" → name `bg_image` → Image #jim background image is set in the styling "Backgrounds" panel of the container-inner div. need plan to pull that out if we need to add a property to the image.
- **Action 2 — Bind city template instance to CMS fields** (Service Areas collection `69cf0c26f69f8fdddb60ccba`):
  - Open the Service Areas Template page → click the `hero-interior` component instance at top of page
  - Bind `title` → Service Areas CMS field `Hero Headline` (slug: `hero-headline`)
  - Bind `subtitle` → CMS field `Hero Subheadline` (slug: `hero-subheadline`)
  - Bind `bg_image` → CMS field `Hero Background Image` (slug: `hero-background-image`) #jim no image component under hero-interior_bg. nothing to bind to. i created bg_image property
  - Leave `eyebrow` hardcoded as literal text "SERVICE AREA" — no binding
- **Action 3 (optional) — About page:** The About hero-interior is currently an inline section (not a component instance). Right-click the section → "Create Component from Selection" → name it (or merge into the existing `hero-interior`) to keep it linked to future master edits.
- **Why:** All 5 city pages currently show placeholder text. Ads driving to any city page will show wrong content until bindings are done. This is the highest-value manual action on the list.
- **Time:** 10-15 min

### 4. Privacy + Terms — Decide hero approach

Context: Phase 2.5 Part B will nuke the embedded hero from the `header` component entirely (necessary to stop double-heroing site-wide). Without a fix, Privacy + Terms will lose their only hero.

**Options — pick one and tell me:**
- **(A)** Add a `hero-interior` instance to Privacy + Terms with hardcoded titles (small slate band with just a title, no photo) — consistent site-wide, ~5 min per page for an agent to execute after your call #jim gave them hero-interior_about that was created above.
- **(B)** Legal pages don't need full heroes — I'll add a simple H1 + subtitle block at the top of the body on each — faster, less chrome, works for legal pages

Once you pick, I can dispatch Phase 2.5 Part B.

---

## P2 — RICH-TEXT BODY CLEANUP (from prior agent verification)

*5-minute Designer cleanup. Low priority but prevents SEO issues.*

### 4. Terms of Service page (`/terms-of-service`)

- **Click path:** Designer → Pages → Terms of Service → open page
- **Action 1:** Find the empty H1 inside the rich-text body (`.blog-body.w-richtext`). It contains only a zero-width joiner character (`\u200D`). Delete the entire H1 element.
- **Action 2:** Open Page Settings → SEO tab → Page Title currently reads "Privacy Policy | Central Wisconsin Deck Builders" → change to `Terms of Service | Central Wisconsin Deck Builders`
- **Why:** The duplicate H1 confuses screen readers and SEO; the wrong SEO title means Google indexes Terms as if it's the Privacy Policy page.

### 5. About page (`/about`)

- **Click path:** Designer → Pages → About → open page
- **Action:** Find the H1 inside the rich-text body (`.blog-body.w-richtext`) containing the literal placeholder text "Heading 1". Delete that H1 element.
- **Why:** Same as Terms — extra H1 pollutes the page's heading structure.

---

## P3 — CONTENT GAPS (whenever convenient) #jim will do later

### 6. Social URLs for footer

- **Need:** Real Facebook, Instagram, and Nextdoor business page URLs for CWDB
- **Where they go:** Footer component — 3 social icon links currently have placeholder hrefs
- **How to send:** paste into the Jim → CEO Inbox in `_vault/state-of-cwdb.md` or reply in next session
- **Why:** Launch-readiness polish; not a blocker but Google crawlers and users notice

### 7. Nextdoor business account verification

- **Carried from 2026-04-18** — you said "doing now"
- **Confirm status:** is the business account verified?
- **Why:** Nextdoor organic posts need a verified business account for full reach

---

## P1 — CONTENT QUALITY (critical before ads)

### 8. Replace 3 CMS Gallery Photos (ACTUAL BLOCKER FOR ADS) #jim use C:\Users\jslog\OneDrive\Desktop\Slogars\CPA\Slogar-Capital\Claude\Projects\CWDB\website\pages\gallery\project-photos for all gallery photos

- **Finding from Step 7 agent:** The 3 Gallery Photos CMS items I picked for the homepage `gallery-featured` component have correct metadata (project type, dimensions, city, builder name) but their underlying image assets **are not decks**. They are:
  - Asset `69cff0a50dcd496698b5a921` — currently an interior living room
  - Asset `69cff0a50dcd496698b5a932` — currently a hotel bedroom
  - Asset `69cff0a50dcd496698b5a919` — currently a tool close-up
- **Action:** Upload 3 real Wisconsin deck photos to the Webflow Asset Manager, then in the Gallery Photos CMS collection (`69cff077a56c28009f3df538`), replace the image references on the 3 items:
  - `69cff0a60dcd496698b5a991` (Cedar Deck with Pergola — Merrill)
  - `69cff0a60dcd496698b5a98b` (Composite Deck — Wausau)
  - `69cff0a60dcd496698b5a98d` (Multi-Level Deck — Weston)
- **Why:** The homepage `gallery-featured` component is now pulling these images. They're the first "proof" scroll-zone for any ad-clicked visitor. A living-room photo under a "Cedar Deck" caption is worse than no photo — it destroys trust instantly.
- **Time:** 15-30 min if photos are already on your phone / Dropbox
- **Alternative:** If real deck photos aren't ready, we can temporarily hide `gallery-featured` via a single Designer visibility toggle until photos land. Flag me and I'll queue it.

---

## Updates log (appended by agents as they finish)

- 2026-04-20 initial draft — Jim's existing backlog + `cta-final` property gap captured
- 2026-04-20 Step 7 complete — added Gallery Photos content replacement (critical for ads, P1 manual #8)
- 2026-04-20 Phase 2.5 Part A complete — hero-interior built + placed on 5 cities + About, but CMS binding is Jim-manual (P0 unblock for Part B, see manual #3)
- 2026-04-20 Step 11 complete — 13 deprecated sections removed from main-sections, wrapper deleted, homepage spine reordered; discovered FAQ was missing from homepage entirely
- 2026-04-20 Step 11.5 complete — `faq-section-home` built from CMS (6 FAQs hardcoded, first-by-sort-order) + placed between coverage-map and cta-final; final spine verified matching target
- **MCP parallel-agent note:** Designer page context is shared state between concurrent MCP sessions. Re-select target page before any structural edit.
- **MCP sibling-insert note:** `before`/`after` can fail adjacent to body-level component instances ("Cannot insert elements directly into a component instance"); workaround is remove + re-append trailing sections in correct order. Note: was not reproducible in Step 11.5 (body-level insert worked fine) — may be state-dependent.
- **MCP whtml_builder strip list (expanded):** pseudo-elements (`::before`/`::after`), `:hover`, `@keyframes`, compound pseudo-stacks, AND attribute selectors (`[open]`, `[aria-expanded]`). Inline `<script>` tags get their quotes HTML-encoded, breaking execution — use `data_scripts_tool.add_inline_site_script` + `upsert_page_script` instead.

---

## Phase 2 + 2.5 Progress Summary (2026-04-20 session)

**Done autonomously today:**
- ✅ Step 6 — `process-steps-v2`
- ✅ Step 7 — `gallery-featured` (Jim-manual follow-up: replace 3 stock photos with real deck shots)
- ✅ Step 8 — `builders-strip`
- ✅ Step 9 — `coverage-map` (dot-and-line constellation fallback)
- ✅ Step 10 — `cta-final` (Jim-manual follow-up: create Component Properties in Designer)
- ✅ Step 11 — homepage assembly (deprecated sections removed, wrapper deleted, spine reordered)
- ✅ Step 11.5 — `faq-section-home` built + placed
- ✅ Phase 2.5 Part A — `hero-interior` component built + placed on 5 cities + About (Jim-manual follow-up: Component Properties + CMS bindings)

**Final homepage spine — verified live on staging:**
`header → hero-split → process-steps-v2 → gallery-featured → builders-strip → coverage-map → faq-section-home → cta-final → footer → mobile-sticky-bar`

**Blocked — awaiting Jim:**
- Phase 2.5 Part B (nuke embedded hero from `header` component + fix Privacy/Terms) — blocked on manual actions #3 and #4 in this doc

**Staging URL:** `https://central-wisconsin-deck-builders.webflow.io`

**Production:** untouched throughout the session.

---

## Phase 3 — Multi-Step Wizard Follow-ups (appended 2026-04-20 PM)

### Make webhook payload schema (Make scenario reactivation prerequisite — NOT a launch blocker)

- **Where:** Make scenario `CWDB Lead Routing — v1` (ID 4792854, hook 2183206). Currently PARKED per 2026-04-19 pivot.
- **Action when reactivation triggers fire:** Update the webhook's expected payload schema and all downstream module mappings to match the Option A wizard field names below.
- **Locked payload keys (Option A — spec wins):**
  - `zip` (string, 5-digit)
  - `phone` (string, tel)
  - `project_type` (string — one of: new-deck, deck-replacement, deck-repair, deck-expansion, screen-porch, pergola, other)
  - `address` (string)
  - `owns_property` (string: "Yes" | "No")
  - `budget` (string — one of: under-10k, 10k-20k, 20k-35k, 35k-50k, 50k-plus, not-sure)
  - `timeline` (string — one of: asap, 1-3-months, 3-6-months, 6-12-months, just-researching)
  - `notes` (string, optional)
  - `tcpa_consent` (string — browser sends "yes" when checked; absent if unchecked, but field is required so absence = no submission)
  - `page_source` (string — always "get-a-quote-multistep" for submissions from this wizard)
- **What is NOT collected:** `name`, `first_name`, `last_name`, `email`. Do NOT re-introduce these into the Make scenario mappings or contractor SMS templates.
- **Contractor SMS copy:** When reconstructing manual SMS templates (Jim → contractor), note that the lead will have address + phone + project type + budget + timeline — no homeowner name until the contractor reaches them by phone.
- **Reactivation triggers (restated):** ≥10 leads/week, 3rd contractor signs, first accepted bid, or Jim availability constraint.

### TCPA consent text review (optional — copy was shipped under the "working + flagged" rule)

- **Where:** Webflow Designer → Get a Quote page → `multi-step-form` component → step 3 → `tcpa-consent-wrap` span
- **Shipped copy:** "By submitting, I agree to receive calls and text messages about my project from Central Wisconsin Deck Builders and matched contractors. Message and data rates may apply. Reply STOP to opt out. Consent is not a condition of purchase."
- **Action:** rubber-stamp OR edit in-place if legal prefers tighter phrasing. Copy is deliberately shorter than the prior email-inclusive disclosure since email is no longer collected.


---

## Phase 4 Staging Audit Results — 2026-04-21

> Full accessibility-tree audit of all 17 live staging URLs. Run by web-dev agent via Playwright MCP (`browser_snapshot` at 1280x800 + 375x667 for P0 pages).

### Summary counts
- **GREEN (no issues):** 9 pages
- **YELLOW (Designer handoff pending — not a dev problem):** 2 pages (`/our-builders` headshots, `/gallery` orphan placeholder CMS item)
- **RED (actual blocker):** 6 pages (`/get-a-quote`, `/cost-calculator`, and all 4 `/blog-post/*`)

### Audit table (17 rows)

| URL | Desktop | Mobile | Hero OK? | Content OK? | Issues Flagged |
|---|---|---|---|---|---|
| `/` | OK | OK | OK | OK | Footer service-area links use legacy `/deck-builders-*` URLs instead of `/service-area/*`; inline `(function(){...})` custom-code rendering as text node in DOM (likely benign but noisy in a11y tree) |
| `/get-a-quote` | RED | RED | OK (real H1 + eyebrow) | RED | 3-step wizard is STUB-only — Step 1 shows "Example text" placeholders, Next button points to `#`, no step-2/step-3 DOM. Header Resources dropdown links all `#`. Copy says "within 24 hours" — homepage says "48 hours" (inconsistency). |
| `/service-area/wausau` | OK | OK | OK | OK | Body copy says "within 24 hours" — drifts from homepage "48 hours" (CMS rich-text edit, not structural) |
| `/service-area/schofield` | OK | OK | OK | OK | Same 24h/48h drift across all 5 city pages |
| `/service-area/weston` | OK | OK | OK | OK | Same 24h/48h drift |
| `/service-area/mosinee` | OK | OK | OK | OK | Same 24h/48h drift |
| `/service-area/merrill` | OK | OK | OK | OK | Same 24h/48h drift |
| `/about` | OK | n/a | OK | OK | Clean |
| `/our-builders` | YELLOW | n/a | OK | Partial | Both contractor profiles render (Garcia + Barton) BUT no `<img>` for headshots — bind or upload pending. Cards link to `#` (builder detail pages not wired). |
| `/faq` | OK | n/a | OK | OK | All 12 FAQ items render from CMS |
| `/gallery` | YELLOW | n/a | OK | Partial | 7 real photo cards render, plus 1 orphan placeholder "Project Title" / "Deck project" card — clean this item from CMS |
| `/cost-calculator` | RED | n/a | RED | RED | (1) Hero default leak — eyebrow "Service Area", H1 "Heading", subheading "Expert deck builders serving your city…"; (2) calculator.js is pasted but rendering as raw text at bottom of DOM, NOT executing — missing `<script>` wrapper or `#cwdb-calculator` container missing from page. Material table is present (static). JS font references `Public Sans`/`Staatliches` — correct, so updated JS was used, just installed wrong. |
| `/blog` | OK | n/a | OK | OK | All 4 article cards render |
| `/blog-post/deck-cost-wisconsin` | RED | n/a | RED | RED | H1 literal "Heading"; body literal "Example H2 heading" / "Example H3 subheading". Page `<title>` is CMS-correct but DOM H1 + rich-text body are NOT bound. |
| `/blog-post/composite-vs-wood` | RED | n/a | RED | RED | Same pattern as above — template CMS binds missing |
| `/blog-post/deck-permits-wausau` | RED | n/a | RED | RED | Same pattern |
| `/blog-post/best-time-build-deck` | RED | n/a | RED | RED | Same pattern |

### Blockers for production promote (RED — must fix before any ad launch)

1. **`/cost-calculator` — calculator not running.** The JS is pasted into Custom Code but missing `<script>` wrapper, OR the `#cwdb-calculator` container div isn't in the page. Result: JS body text appears in DOM, no interactive calculator renders. The Material Table section does render — so the page isn't useless, but the advertised "calculator" is broken. Also: hero-interior showing defaults ("Heading", "Service Area", "Expert deck builders serving your city…") — override needed OR bind hero to proper page-specific content.
2. **`/cost-calculator` hero defaults** — same hero-interior leak pattern Jim has been overriding elsewhere. This page was not on the original 9-page manual toggle list because it was pending calculator.js paste; needs a Designer Title/Eyebrow/Subtitle override pass.
3. **4× `/blog-post/*` articles — CMS binds not wired.** Page-level `<title>` is correctly slug-bound, but the H1 inside hero-interior and the rich-text body inside article-body are showing template defaults (`"Heading"`, `"Example H2 heading"`, `"Example H3 subheading"`). Article template needs its H1 element bound to Blog Posts:Title and the rich-text element bound to Blog Posts:Body. One fix replicates across all 4 articles via the template.
4. **`/get-a-quote` form is non-functional.** Step 1 shows placeholder "Example text" inputs; Next button links to `#`; steps 2 and 3 absent from DOM. This is Phase 3 work per MEMORY — but if any ad traffic arrives at this page before Phase 3 lands, every click is lost. Either finish Phase 3 before launch OR revert to a single-page native Webflow form as a stopgap.

### Pending Designer handoff (YELLOW — confirmed in Jim's existing queue)

5. **`/our-builders` headshots** — contractor cards text-only, no headshot `<img>` elements. Maps to Jim's existing "upload contractor headshots + bind" queue item.
6. **`/our-builders` card links** — both cards link to `#`. Either wire builder detail pages, or make cards non-linked (static profile tiles). Flag only — not blocker if plan is static tiles.
7. **`/gallery` orphan placeholder** — 8th CMS item with generic "Project Title" / "Deck project" content. Delete that CMS record or publish real content.

### Observations / polish (minor — not blockers)

8. **Footer service-area link URLs are stale across all 17 pages.** Footer component uses `/deck-builders-wausau`, `/deck-builders-schofield`, etc. — but the actual slugs are `/service-area/wausau` etc. Any user clicking a footer service-area link today hits a 404. Single edit in the `footer` component fixes all 21 pages.
9. **Copy drift: "24 hours" vs "48 hours" response time.** Homepage + footer CTA bars say "48-hour response", but the city-page body copy and `/get-a-quote` subhead say "within 24 hours". Pick one number and make it consistent. Phase 4 chose 48h per MEMORY (2026-04-19), so city-page + quote-page copy should move to 48h.
10. **Header Resources dropdown (on `/get-a-quote`) links to `#`.** The dropdown is exposed in the expanded state on that page — 4 dead links. Fix in the `header` component.
11. **Inline custom-code string rendering as text node on every page.** The `(function(){var s=document.createElement('style')...})` block and `(function(){var h=document.querySelector('.header-wrap')...})` block are appearing as visible text in the accessibility tree — suggests one Custom Code block was pasted without `<script>` tags. Invisible on render (text node but likely styled `display:none` or zero-size) so not P0, but clean it up to avoid confusing future audits and potential a11y noise.

### Memory update confirmation

- **Wrote** `playwright-mcp-context-death.md` at `C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/` — documents the `close → about:blank → resize` reinit pattern and the 3-strike escalation rule.
- **Linked** it in `MEMORY.md` under the Webflow MCP learnings block.

