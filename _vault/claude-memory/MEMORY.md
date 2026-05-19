---
title: MEMORY
type: memory
memory_type: index
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/MEMORY.md
tags:
  - type/memory
  - memory/index
---
# CWDB Project Memory
Auto-loaded each session. Keep under 150 lines. Details → project-state.md.

## Daily Read
- **State of CWDB** — `_vault/state-of-cwdb.md` in the CWDB repo. Open first each session. Single source of truth for current state, Inbox/Outbox comms with Jim, decisions needed, KPIs. Updated by `/session-end` (auto) and `/state` (manual).

## User
- [[user_name|User goes by Jim]] — call him Jim; James appears on legal docs only

## Business Contact (Canonical NAP)
- [[business-contact|CWDB NAP — name, address, phone, email, hours]] — 906 N 16th Ave, Wausau WI 54401 · (715) 544-7941 · info@cwdeckbuilders.com

## LLC — Central Wisconsin Deck Builders, LLC
- **Formed:** 2026-04-06 · Wisconsin single-member LLC · James Slogar, Sole Member
- **EIN:** 41-5355234 · **Wisconsin Entity ID:** C138564
- **Registered office:** 906 N 16th Ave., Wausau, WI 54401
- **Annual report due:** June 30, 2027 ($25, DFI online) · S-Corp election window closes ~2026-06-20
- **Docs:** `/docs/legal/` — articles, EIN proof, contractor agreement v1 (.md, .docx, .pdf)
- **Contractor agreement v1:** Sent via DocuSign to Ben Barton + John Garcia (2026-04-07, effective April 6, 2026) · PDFs in `/sales/contractor-agreements/` · Generator: `/docs/legal/generate_agreement_pdf.py` (parameterized) · Send script: `/sales/contractor-agreements/generate_and_send.py` · Log: `/sales/contractor-agreements/log.md`
- Full details → [[llc-formation|llc-formation.md]]

## What This Project Is
Trades lead generation business. Generate homeowner deck project leads in Central Wisconsin and sell them to contractors.
Niche: Deck Builders. Market: Wausau, Schofield, Weston, Mosinee, Merrill.

## Current Phase
Phase 1 — Validation (IN PROGRESS)
Contractor commitment secured ✅ — first contractor agreed to $1,000 per accepted bid (2026-03-12)
Full 21-page website plan created ✅ — see `/business-context/website-plan.md` (2026-03-29)
Website content files, design system, site architecture, and cost calculator all created (2026-03-29)
**Webflow Phase A complete ✅ (2026-04-02)** — design system, global styles, header, footer, all core components
**Webflow Phase B complete ✅ (2026-04-02)** — homepage, Get a Quote page, Thank-You page all done
**Webflow Phase C complete ✅ (2026-04-03)** — Service Areas CMS collection (28 fields), template page built + styled, all 5 city items published (Wausau, Schofield, Weston, Mosinee, Merrill)
**Webflow Phase D complete ✅ (2026-04-03)** — About, FAQ, Gallery, Our Builders pages live on staging. 3 new CMS collections created.
**Webflow Phase E complete ✅ (2026-04-03)** — cost calculator page, Blog Posts CMS collection (4 articles), /blog index, blog article template all live on staging.
**Contractor agreements sent ✅ (2026-04-07)** — DocuSign sent to Ben Barton (Barton Builders LLC) + John Garcia (John Garcia Construction, LLC). Both HubSpot lifecycle stages → customer.
**Webflow Phase F complete ✅ (2026-04-18)** — GTM snippet in Webflow site head; GTM container configured with 8 tags (GA4, Meta Pixel, Nextdoor Pixel, Clarity, Conversion Linker, Google Ads Conversion, Meta Lead event, Nextdoor Lead event); all tags verified firing in GTM Preview mode on staging. GTM container published 2026-04-18.
**DNS cutover live ✅ (2026-04-18)** — cwdeckbuilders.com → 301 → www.cwdeckbuilders.com (200).
**Make scenario v1 built (2026-04-18) — PARKED 2026-04-19** — `CWDB Lead Routing — v1` (scenario 4792854, hook 2183206) remains inactive. Not to be reactivated until triggers fire — see pivot memo.
**HubSpot OAuth authorized in Make (2026-04-18)** — left as-is; no further connections pursued.
**PIVOT 2026-04-19:** Make scenario parked; Google Voice → Twilio port-in cancelled. Manual contractor notification via Jim's SMS is the interim path. Rationale: Principle 2 — no lead flow yet, automation is premature. Reactivation triggers: ≥10 leads/week, 3rd contractor signs, first accepted bid, or Jim availability constraint. See `/agents/agent-memory/cwdb-ceo-operator/pivot-2026-04-19.md`.
**Barton + Garcia deals → closedwon (2026-04-19)** — HubSpot deal IDs 318227725018 and 319472967405 updated via MCP.
**Ad launch brief staged (2026-04-19)** — `/marketing/launch-brief-2026-04-20.md`. ~~Target launch 2026-04-20~~ **DELAYED** — see next line.
**Site revamp COMPLETE ✅ (2026-04-21)** — Full 21-page revamp shipped. Phase 1 foundation (Staatliches + Public Sans, header/footer, social SVGs, content fixes); Phase 2 homepage spine complete (hero-split → process-steps-v2 → gallery-featured → builders-strip [CMS-bound] → coverage-map [static SVG, 5 sky-blue pins] → cta-final [unique variant]); Phase 3 complete (/get-a-quote 3-step wizard = Webflow native form + JS embed with URL-param pre-fill); Phase 4 complete (all 11 page rebuilds on new typography: 5 cities + About/FAQ/Gallery/Our Builders/Calculator/Blog). Phase 2.5 still deferred (hero-interior + CMS rewire + embedded-hero nuke). Plan reference `/plans/web-dev-agent-let-s-work-stateless-scroll.md` does NOT exist on disk — canonical source is `_vault/state-of-cwdb.md` §8.
**Ad launch TODAY 2026-04-21** — Launch window pulled forward from 2026-04-30. Homepage section order AUDITED 2026-04-21 — correct (slot 1 header, 2 hero-split, 3 process-steps-v2, 4 gallery-featured, 5 builders-strip, 6 coverage-map, 7 faq-section-home, 8 cta-final, 9 footer, 10 mobile-sticky-bar). **Hero-form handoff bug FIXED ✅ 2026-04-21** — root cause: default Webflow form with no intercept reloaded `/` with query params. Fix: inline site script `hero_form_handoff` v1.0.0 registered + applied to homepage footer; capture-phase submit listener validates zip/phone, navigates to `/get-a-quote?zip=...&phone=...`. Verified end-to-end on staging + production (script CDN: `cdn.prod.website-files.com/.../hero_form_handoff-1.0.0.js`). Published to both `cwdeckbuilders.com` + `www.cwdeckbuilders.com`. Non-blocker tech debt: testimonials section absent from homepage (intentional?); legacy `hero-section-subpage` + `hero-subpage` still in component library (Phase 2.5 cleanup); phone formatting passed verbatim (aesthetic nicety).

## Webflow Site IDs (confirmed 2026-04-02)
- Site ID: `69c846db9eee02fddb1e2367`
- Workspace ID: `69c8468c7b22dbee46e2fe14`
- Staging URL: `https://central-wisconsin-deck-builders.webflow.io`
- Page IDs: Home `69c846dd9eee02fddb1e2376` · Get a Quote `69ce4163e79002c5d4762a57` · Thank You `69ce7e7446c34cb2d17b7ffb` · Service Areas template `69cf0c27f69f8fdddb60ccc0`
- Phase D page IDs: About `69cff11ab796bc97b788f894` · FAQ `69cff2909d6b4ef6581d1c83` · Our Builders `69cff29d53036270250204d6` · Gallery `69cff2a36004fc5dff348ad5`
- Phase E page IDs: /cost-calculator `69d04360b87483b9bbc76b04` · /blog `69d04373a1cf39d4f6680755` · Blog Posts template `69d043662f0a55d546c1f61a`
- CMS: Service Areas `69cf0c26f69f8fdddb60ccba` (28 fields) · Gallery Photos `69cff077a56c28009f3df538` (7 items — all real WI deck photos as of 2026-04-21) · Our Builders `69cff079df8b05e8d3935fdf` (2 real items — Ben Barton `69cff0a989e454afdd3f5788` + John Garcia `69d4b9e6b553503a6618ddbf` — all fields populated incl. headshots; homepage `builders-strip` CMS-bound as of 2026-04-21) · FAQs `69cff07bd29f3d1624e2ffb9` (12 items) · Blog Posts `69d043662f0a55d546c1f597` (4 articles: deck-cost-wisconsin, composite-vs-wood, deck-permits-wausau, best-time-build-deck)
- Revamp Phase 2 component IDs: `hero-split` `0f19c38f-c81b-c27b-46e6-e5e3fa6807f1` · `process-steps-v2` `08624456-cfb4-450f-f121-c4e6c4f174a9` · `gallery-featured` `182ba5d8-1b29-7e4d-30f1-99ff54130c65` · `builders-strip`, `coverage-map`, `cta-final` (IDs not yet logged)
- City template sections (in order): global-nav · city-intro-section · faq-section · testimonials · cedar-strip · coverage-area-cards · mobile-sticky-bar · quote-form-inline · global-footer
- MCP protocol: all website changes go through Webflow MCP first, then sync local HTML — see `.claude/skills/webflow-connect.md`

## Confirmed Tech Stack
- Landing Pages: Webflow (21-page authority site)
- Forms: Webflow native forms (replaced Tally 2026-03-29)
- Automation: Make (formerly Integromat)
- CRM: HubSpot (free tier)
- Ads: Google Ads + Facebook/Instagram + Nextdoor (primary community channel) + TikTok
- Analytics: GA4 + GTM + Meta Pixel + Nextdoor Pixel + Google Ads Conversion + MS Clarity

## Department Structure (agents = employees, folders = departments)
- agents/       9 AI agent prompt configs
- marketing/    Ad campaigns (Google, Facebook, Nextdoor, TikTok)
- website/      Webflow pages, templates, design system, page content
- sales/        Contractor outreach, onboarding, CRM
- operations/   Lead processing, qualification, routing, Make automation
- finance/      P&L and performance reports
- templates/    Shared reusable assets

## 9 Agents Defined
1. market-research
2. web-dev (builds Webflow pages)
3. ad-campaign (Google, Facebook, Nextdoor, TikTok)
4. lead-qualification
5. lead-routing
6. contractor-sales
7. revenue-optimization
8. accounting
9. analytics

## Brand Identity (CONFIRMED 2026-03-28)
- **Brand name:** Central Wisconsin Deck Builders (CWDB internally)
- **Domain:** cwdeckbuilders.com (registered on GoDaddy)
- **Colors:** #e54c00 Crafted Orange · #323434 Timber Slate · #646760 Builders Grey · #83b2cf Wisconsin Sky Blue
- **Logos:** 2 active files in /branding/logos/ — 1.1-primary-logo-high-res.png (stacked) and 1.2-horizontal-logo-high-res.png

## Website Reference Files (created 2026-03-29)
- Full plan: `/business-context/website-plan.md`
- Design system: `/website/design-system.md`
- Site architecture: `/website/site-architecture.md`
- Base HTML template: `/website/templates/base.html`
- Page content: `/website/pages/*/content.md`
- Cost calculator JS: `/website/pages/cost-calculator/calculator.js`
- Form spec: `/operations/leads/quote-form-fields.json` (updated for Webflow)

## Key Decisions Log
- WordPress dropped → Webflow only
- Zapier dropped → Make (cheaper, better free tier)
- Typeform dropped → Tally → **Tally dropped → Webflow native forms (2026-03-29)**
- HubSpot on free tier
- Landing-page-builder agent renamed to web-dev
- Folder structure modeled as company departments
- Nextdoor added as primary community traffic channel
- **Pricing model confirmed (2026-03-12): Pay per accepted bid at $1,000**
- **Brand finalized (2026-03-28):** Name, domain, logos, color palette confirmed
- **Website expanded (2026-03-29):** Single landing page → 21-page authority site with SEO, blog, cost calculator, city pages
- **Webflow native forms replace Tally (2026-03-29):** Simpler stack, better design control, Tally form 81GbEO superseded
- **Ad budget confirmed (2026-04-18):** $50/day — $30 Google + $20 Meta; Nextdoor organic-only; no TikTok spend at launch
- **Lead-routing pivot (2026-04-19):** Make scenario parked; manual SMS by Jim is interim path until reactivation triggers fire. Supersedes 2026-04-18 Make-as-router decision.
- **Make paid tier cancelled (2026-04-19):** Free tier stays. Automation parked pending lead flow.
- **Phone strategy reversed (2026-04-19):** Google Voice → Twilio port-in cancelled. Keep GV for (715) 544-7941.
- **Barton + Garcia deals closedwon (2026-04-19):** Both HubSpot deals updated via MCP.
- **Site revamp chosen over ad launch (2026-04-19 evening):** Full 21-page revamp before ads. Staatliches + Public Sans replace Barlow Condensed + Inter. Photo-driven, zero-decoration aesthetic (removes border-left stripes, tinted icon wrappers, cedar-strip divider, sky-tint section backgrounds). Proof-first homepage spine (hero-split → process → gallery → builders → map → FAQ → CTA). 3-step form wizard on /get-a-quote. Plan: `/plans/web-dev-agent-let-s-work-stateless-scroll.md`. 11-15 day timeline. Hero copy: "Get a quote within 48 hours." (was "24 hours — not 24 days" per Jim's realism feedback).
- **Sky-blue reintegration (2026-04-19):** Sky becomes signal-accent color for text links on light bg, trust-row checkmarks, 1px connectors, inactive progress dashes, coverage-map pins, focus rings. Orange reserved for CTA buttons + section-label eyebrows only. Documented as Color Rule #9 in design-system.md.
- **Hybrid double-hero fix (2026-04-19):** Full `hero-interior` component + CMS rewire + embedded-hero nuke deferred to Phase 2.5. Visibility toggles + Title overrides as interim. MCP limitation discovered: per-instance component property overrides not exposed on single-locale Webflow sites — manual Designer action required.

## Open Items (Phase 1 Checklist)
- [ ] Contact 10-20 deck contractors (use /sales/outreach/)
- [x] Secure first contractor commitment ✅ — $1,000/accepted bid (2026-03-12)
- [x] Contractor agreements signed ✅ — Ben Barton + John Garcia signed PDFs in /sales/contractor-agreements/ (2026-04-17)
- [x] Website plan + content files created ✅ (2026-03-29)
- [x] Webflow Phase A complete ✅ — design system, global styles, header, footer, components (2026-04-02)
- [x] Webflow Phase B homepage complete ✅ — all sections + reusable components (2026-04-02)
- [x] Webflow Phase B complete ✅ — Get a Quote, Thank-You pages done (2026-04-02)
- [x] Service Areas CMS collection created ✅ — 28 fields, Wausau item populated (2026-04-03)
- [x] Wausau city page template built ✅ — styled, CMS bindings done by user (2026-04-03)
- [x] Webflow Phase C complete ✅ — all 5 city pages live on staging (2026-04-03)
- [x] Webflow Phase D complete ✅ — About, FAQ, Gallery, Our Builders live; 3 CMS collections created (2026-04-03)
- [x] Webflow Phase E complete ✅ — calculator + blog live on staging (2026-04-03)
- [x] Manual: FAQPage JSON-LD added to FAQ page ✅ (2026-04-17)
- [x] Manual: Gallery placeholder photos replaced with real Wisconsin deck photos ✅ (2026-04-17)
- [x] Manual: calculator.js pasted into /cost-calculator Custom Code ✅ (2026-04-17)
- [x] Manual: Article JSON-LD schema added to blog template ✅ (2026-04-17)
- [x] Webflow Phase F complete ✅ — GTM + GA4 + Meta + Nextdoor + Google Ads + Clarity all wired and live; GTM container published 2026-04-18
- [~] Make scenario for lead routing — PARKED 2026-04-19 (pivot). Scenario 4792854 remains inactive pending reactivation triggers.
- [x] Barton + Garcia deals → closedwon ✅ (2026-04-19, via HubSpot MCP)
- [x] ~~P0 (2026-04-20 AM) — 9 manual Webflow Designer toggles~~ **OBSOLETED 2026-04-20 Phase 4 Wave 0** — classname swap on header component root (`hero-section mobile` → `site-header`) eliminated the double-hero at source site-wide. Privacy/Terms Title override piece may still apply — to be re-audited in Wave 1.
- [x] **P0 — Webflow form → email delivery verified ✅ (2026-04-28)** — confirmed during /get-a-quote form rebuild; submissions land at info@cwdeckbuilders.com
- [x] **/get-a-quote form rebuild complete ✅ (2026-04-28)** — iOS submit bug killed (was `display: inline-flex` on `<input type="submit">`), name+email now first-class Webflow fields, project_type moved to Step 3, scripts consolidated 15→8 applied + 1 page-scoped (`quote_page_polish-1.0.0`). Verified by Jim on iPhone 11 Safari + Chrome.
- [ ] Jim reviews + approves ad-launch brief `/marketing/launch-brief-2026-04-20.md` — **LAUNCH TODAY 2026-04-21** (window pulled forward from 2026-04-30)
- [x] **Phase 2 homepage spine complete ✅ (2026-04-21)** — hero-split, process-steps-v2, gallery-featured, builders-strip (CMS-bound), coverage-map (static SVG), cta-final (unique variant) all built + placed
- [x] **Phase 3 complete ✅ (2026-04-21)** — /get-a-quote 3-step wizard shipped as Webflow native form + JS embed with URL-param pre-fill
- [x] **Phase 4 complete ✅ (2026-04-21)** — all 11 page rebuilds done: 5 cities + About/FAQ/Gallery/Our Builders/Calculator/Blog on new typography
- [ ] **Phase 2.5 deferred** — build `hero-interior` component, rewire city CMS bindings, nuke embedded hero from `header`
- [ ] **Homepage polish (post-launch, non-blocking)** — decide on testimonials section inclusion; remove legacy `hero-section-subpage` + `hero-subpage` from component library
- [ ] Jim supplies real CWDB Facebook/Instagram/Nextdoor business URLs (currently placeholders in footer)
- [ ] Set up HubSpot pipeline (reference /sales/crm/pipeline-stages.json) — for manual lead tracking
- [ ] Set up Nextdoor business account + verification (Jim unconfirmed as of 2026-04-19)
- [x] DNS cutover live ✅ — cwdeckbuilders.com → 301 → www.cwdeckbuilders.com (200); site published to both custom domains with GTM snippet active (2026-04-18)
- [~] Run first small ad campaign ($50/day: $30 Google + $20 Meta; Nextdoor organic-only) — **GOOGLE LIVE ✅ 2026-04-23** (first ad spend in CWDB history — campaign `CWDB — Search — Launch 2026-04` un-paused after bulk-upload of 9 CSVs). **PAUSED 2026-04-25 mid-session for tracking audit; pending Primary swap + test lead before un-pause.** Meta still pending.

## Memory Update Instructions (for Claude)
When files are created or changed → update project-state.md
When stack/agent/strategy decisions are made → update this file + project-state.md
When user signals end of major session → remind user to run /claude-md-management:revise-claude-md

## Webflow Development Rules
- **Native elements only** — never use custom HTML embeds when a native Webflow element exists (forms, CMS, sliders, tabs, etc.)
- **Pause > hack** — if a requirement forces a custom HTML embed, stop and ask the user to do it manually in the designer
- **Component-first sections** — every section must be a named Webflow component; edit property values first, then copy+rename closest component for styling variations, build net new only as last resort; headers always use `hero-` component; footer always uses `footer` component
- **CMS for repeating content** — design components with placeholder content first; bind to CMS collection when content repeats or follows a pattern (FAQ items, gallery photos, contractor profiles, city pages)

## Detailed State
See: project-state.md

## DocuSign (for contractor agreement sends)
- User ID: `265ec01f-b037-4eae-b96d-0fdebec59723` · Account ID (GUID): `07a2f8c5-1951-4d6d-baab-0c45359ab80e`
- Skill: `.claude/skills/contractor-onboarding.md` — use for all future contractor agreement generation + sends
- Contractors: Ben Barton `462464338657` (Barton Builders LLC) · John Garcia `465926077160` (John Garcia Construction, LLC)

- [[phase-f-ids|Phase F Analytics IDs]] — All 6 IDs received (GTM, GA4, Meta, Nextdoor, Google Ads, Clarity) — ready for install

- [[vault-rag-architecture|Vault RAG architecture]] — CWDB Obsidian vault mirrors project content via junction + transclusions + memory copy; run /vault-sync to refresh

- [[feedback-webflow-native-elements|Webflow — prefer native elements over custom HTML]] — No custom HTML embeds when native Webflow elements exist; pause and ask user to do manually if needed
- [[feedback-webflow-components|Webflow — component-first section building]] — Every section must be a named component; 3-tier hierarchy: edit properties → copy+rename for styling variations → net new as last resort; naming: `[base]-[descriptor]`; headers always `hero-`; footer always `footer`
- [[webflow-mcp-pseudo-elements|Webflow MCP — pseudo-elements stripped by whtml_builder]] — `::before`/`::after` rules silently dropped on whtml import; use style_tool with pseudo param OR fall back to aria-hidden div
- [[webflow-mcp-parallel-agents|Webflow MCP — Designer page context is shared across parallel agents]] — concurrent web-dev agents share active-page state; re-select target page before structural edits to avoid race failures
- [[webflow-mcp-sibling-insert|Webflow MCP — cannot insert siblings adjacent to component instances at body level]] — `before`/`after` fails with "Cannot insert elements directly into a component instance"; workaround is remove + re-append trailing sections in correct order
- [[webflow-mcp-cms-binds|Webflow MCP — cannot bind DOM elements to CMS fields]] — Image src/alt + Text content binds + Collection List filter settings are Designer-only; agents should build DOM then hand off to Jim
- [[webflow-collection-list-grid|Webflow Collection List — use display:contents for grid/flex]] — DynamoWrapper + DynamoList intercept layout; set display:contents on both so Collection Items become direct grid/flex children
- [[webflow-mcp-component-bool-props|Webflow MCP — per-instance Component Property overrides are Designer-only on single-locale sites]] — ALL override types (Text, Boolean, Image) fail via Data API with "locale must be a secondary locale"; Designer MCP has no write path; hand off to Jim in Designer
- [[pivot-2026-04-19|Pivot 2026-04-19 — Make/Twilio parked]] — Manual contractor SMS until ≥10 leads/week or 3rd contractor; scenario 4792854 dormant
- [[playwright-mcp-context-death|Playwright MCP — browser context dies on idle]] — First call after idle fails with "Target page, context or browser has been closed"; always run `browser_close` → `browser_navigate("about:blank")` → `browser_resize(1280, 800)` at start of any Playwright session, and repeat the cycle if the error reappears mid-run
- [[hormozi-framework|Hormozi Operating Framework]] — `Skill hormozi-operator` + CEO agent 12-step diagnostic + state-file §4–§6; Lever 4 (proof) and Lever 1 (volume) are current bottlenecks
- [[feedback-state-file-merge-protocol|State file is merged, not regenerated]] — `/state`, `/brief`, and `/session-end` read latest `_vault/state-archive/state-<session-id>.md`; Jim's `[x]` and `%...%` comments are authoritative; snapshot is mirrored to singleton `_vault/state-of-cwdb.md`
- [[feedback-elegant-path-default|Always steer back to the most elegant approach]] — Before serving any multi-step manual workflow, propose the bulk/scripted/API alternative if one exists (Google Ads Editor CSV, Meta bulk import, Webflow MCP component_builder, HubSpot batched MCP, DocuSign templates). Standing instruction.
- [[google-ads-callout-row-type|Google Ads callout bulk Row type must be "Callout" not "Callout extension"]] — Google's own template sample rows are wrong; parser rejects the legacy value. Fix-forward for future CWDB callout CSVs.
- [[meta-ads-bulk-import-gate|Meta Ads bulk import gated behind ~2 weeks of account maturity]] — Fresh accounts can't use bulk; CWDB expected to unlock ~2026-05-07. Plan manual-UI for any first-launch on new Meta accounts.
- [[feedback-spreadsheet-for-copy-paste-workflows|Heavy copy-paste workflows ship as spreadsheets, not prose walkthroughs]] — Default to CSV with Step/Section/Action/Value columns for any UI-paste task with ≥10 discrete values. Standing instruction.
- [[feedback-account-identity-verification|Verify platform-account identity before configuring tags]] — Phase F (2026-04-18) was set up in Jim's CPA work account; Google Ads + Meta IDs landed in wrong businesses. Always confirm account selector at top of UI before pasting pixel/conversion IDs into launch docs.
- [[feedback-ad-creative-three-ratios|Ad creatives — always 1:1, 9:16, and 16:9]] — STANDING RULE (2026-04-26). Every ad-campaign batch on every platform ships all three master ratios (1080×1080, 1080×1920, 1920×1080). 4:5 and 1.91:1 are optional secondary crops, not replacements.
- [[feedback-ios-flex-submit-bug|iOS Safari + flex on `<input type="submit">` swallows tap submits]] — WebKit bug killed CWDB form 2026-04-27. Submit inputs stay `inline-block`; flex centering only on `a.btn-submit` anchors.
- [[feedback-real-device-mobile-testing|Real-device testing is the only acceptance criterion for mobile UI claims]] — Playwright Chromium ≠ iOS Safari. Never claim a mobile fix is shipped without Jim's iPhone 11 Safari + Chrome confirmation. Re-read `list_applied_scripts` after any apply call.
- [[webflow-no-native-multistep|Webflow has NO native Multi-Step Form element]] — every multi-step is custom JS hiding wizard-step divs. Don't propose "use Webflow native multi-step" as a rebuild path.
- [[webflow-mcp-script-constraints|Webflow MCP — script slots cap at 15, inline cap at 2000 chars]] — `data_scripts_tool` only exposes `add_inline_site_script`; hosted-script registration not exposed; page-scoped scripts via `upsert_page_script` are the workaround for >2000 chars; `publish_site` requires domain IDs not hostnames.
- [[project-form-rebuild-2026-04-27|/get-a-quote form rebuild complete (2026-04-28)]] — iOS bug killed; name+email are real fields; project_type on Step 3; 8 site scripts + 1 page-scoped (`quote_page_polish-1.0.0`); plan file at `~/.claude/plans/web-dev-agent-emergency-my-velvety-spark.md`.
