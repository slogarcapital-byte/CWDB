---
title: project state
type: memory
memory_type: project
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/project-state.md
tags:
  - type/memory
  - memory/project
---
# CWDB Project State — Detailed Reference
Linked from MEMORY.md. Update this file as tools are configured and files change.

---

## File Tree (current)

```
CWDB/
├── CLAUDE.md                              CEO document — strategic overview
├── agents/
│   ├── market-research/prompt.txt         BUILT
│   ├── web-dev/prompt.txt                 BUILT
│   ├── ad-campaign/prompt.txt             BUILT
│   ├── lead-qualification/prompt.txt      BUILT
│   ├── lead-routing/prompt.txt            BUILT
│   ├── contractor-sales/prompt.txt        BUILT
│   ├── revenue-optimization/prompt.txt    BUILT
│   ├── accounting/prompt.txt              BUILT
│   └── analytics/prompt.txt              BUILT
���── marketing/
│   ���── google-ads/
│   │   ├��─ ad-copy.txt                    BUILT — needs real campaign data
│   │   └── keywords.csv                   BUILT — needs validation/pruning
│   ├── facebook-ads/
│   │   ├── ad-copy.txt                    BUILT — needs real campaign data
│   │   └── audiences.txt                  BUILT
│   └── tiktok/
│       ├── ad-copy.txt                    BUILT — needs real campaign data
│       └── audiences.txt                  BUILT
├── website/
│   ├── design-system.md                   BUILT ✅ (2026-03-29) — colors, fonts, components
│   ├── site-architecture.md               BUILT ✅ (2026-03-29) — sitemap, nav, SEO, analytics
│   ├── templates/base.html                UPDATED ✅ (2026-03-29) — full multi-page Webflow reference
│   ├── pages/homepage/content.md          BUILT �� (2026-03-29)
│   ├── pages/get-a-quote/content.md       BUILT ✅ (2026-03-29)
│   ├── pages/thank-you/content.md         BUILT ✅ (2026-03-29)
│   ├── pages/our-builders/content.md      BUILT ✅ (2026-03-29)
│   ├── pages/gallery/content.md           BUILT ✅ (2026-03-29)
│   ├── pages/about/content.md             BUILT ✅ (2026-03-29)
│   ├── pages/faq/content.md               BUILT ✅ (2026-03-29)
│   ├── pages/cost-calculator/content.md   BUILT ✅ (2026-03-29)
│   ├── pages/cost-calculator/calculator.js BUILT ✅ (2026-03-29) — client-side JS
│   ├── pages/cost-calculator/index.html   BUILT ✅ (2026-04-03) — Webflow sync file
│   ├── pages/cities/wausau/content.md     BUILT ✅ (2026-03-29)
│   ├── pages/cities/schofield/content.md  BUILT ✅ (2026-03-29)
│   ├── pages/cities/weston/content.md     BUILT ✅ (2026-03-29)
│   ├── pages/cities/mosinee/content.md    BUILT ✅ (2026-03-29)
│   ├── pages/cities/merrill/content.md    BUILT ✅ (2026-03-29)
│   ├── pages/blog/content.md              BUILT ✅ (2026-03-29) — blog index
│   ├── pages/blog/index.html              BUILT ✅ (2026-04-03) — Webflow sync file
│   ├── pages/blog/article-template/index.html BUILT ✅ (2026-04-03) — Webflow CMS template sync
│   ├── pages/blog/deck-cost-wisconsin.md  BUILT ✅ (2026-03-29)
│   ├── pages/blog/composite-vs-wood.md    BUILT ✅ (2026-03-29)
│   ├── pages/blog/deck-permits-wausau.md  BUILT ✅ (2026-03-29)
│   ├── pages/blog/best-time-build-deck.md BUILT ✅ (2026-03-29)
│   ├── pages/privacy/content.md           BUILT ✅ (2026-03-29)
│   ├── pages/terms/content.md             BUILT ✅ (2026-03-29)
│   └── pages/wausau-deck/index.html       SUPERSEDED — old single-page template
├── sales/
│   ├── outreach/email-template.txt        BUILT
│   ├── outreach/call-script.txt           BUILT
│   ├── onboarding/contractor-profile.json BUILT
│   └── crm/pipeline-stages.json          BUILT
├── operations/
│   ├── leads/quote-form-fields.json       UPDATED ✅ (2026-03-29) — now references Webflow native forms
│   ├── leads/scoring-rules.json           BUILT
│   ├─��� leads/routing-rules.json           BUILT — contractor slots VACANT
│   └── make/webhooks.json                 BUILT — scenario NOT built in Make
├── business-context/
│   ├── phase-1-plan.md                    UPDATED ✅ (2026-03-29) — 3B section expanded for full website
│   └── website-plan.md                    BUILT ✅ (2026-03-29) — complete 21-page website spec
├── finance/
│   ���── pl/                                EMPTY — drop P&L files here
│   └��─ reports/
│       ├── market-research/               EMPTY
│       └── performance/                   EMPTY
└── templates/
    ├── email/                             EMPTY
    ├── forms/                             EMPTY
    └── scripts/                           EMPTY
```

---

## Tool Configs (fill in as tools are set up)

| Tool | Config | Status |
|------|--------|--------|
| Tally Form | Form ID: 81GbEO | SUPERSEDED — replaced by Webflow native forms (2026-03-29) |
| Webflow Form | 9-field quote form, native | Spec complete, not yet built in Webflow |
| Webflow Form | Redirect: /thank-you | Spec complete |
| Make Scenario | `CWDB Lead Routing — v1` · ID 4792854 · hook 2183206 · webhook URL `https://hook.us2.make.com/p4cbbf1lq3bl6lpew6c3odahnrhoc1m4` | Built 2026-04-18, INACTIVE pending connections + activation |
| Make Account | Paid tier upgrade pending (Core $9/mo or Pro $16/mo, TBD) | In progress (2026-04-18/19) |
| Make Connection — HubSpot | OAuth authorized ✅ | CONFIRMED ✅ (2026-04-18) |
| Make Connection — Gmail | OAuth pending | Awaiting Jim |
| Make Connection — Twilio | Pending Twilio port + SID/Auth Token | Blocked on Google Voice → Twilio port (started 2026-04-19, 3–7 bd) |
| HubSpot | Pipeline ID: [TBD] | Not configured — scenario currently uses `pipeline=default`, `dealstage=appointmentscheduled` |
| HubSpot | Portal ID: [TBD] | Not configured |
| Webflow | Site ID: 69c846db9eee02fddb1e2367 | CONFIRMED ✅ (2026-04-02) |
| Webflow | Workspace ID: 69c8468c7b22dbee46e2fe14 | CONFIRMED ✅ (2026-04-02) |
| Webflow | Staging URL: central-wisconsin-deck-builders.webflow.io | CONFIRMED ✅ (2026-04-02) |
| Webflow | Page ID — Home: 69c846dd9eee02fddb1e2376 | CONFIRMED ✅ (2026-04-02) |
| Webflow | Page ID — Get a Quote: 69ce4163e79002c5d4762a57 | CONFIRMED ✅ (2026-04-02) |
| Webflow | Page ID — Thank You: 69ce7e7446c34cb2d17b7ffb | CONFIRMED ✅ (2026-04-02) |
| Webflow | MCP protocol active — skill: .claude/skills/webflow-connect.md | CONFIRMED ✅ (2026-04-02) |
| Webflow | Page ID — /cost-calculator: 69d04360b87483b9bbc76b04 | CONFIRMED ✅ (2026-04-03) |
| Webflow | Page ID — /blog: 69d04373a1cf39d4f6680755 | CONFIRMED ✅ (2026-04-03) |
| Webflow | Page ID — Blog Posts template: 69d043662f0a55d546c1f61a | CONFIRMED ✅ (2026-04-03) |
| Webflow | CMS — Blog Posts collection: 69d043662f0a55d546c1f597 (4 articles) | CONFIRMED ✅ (2026-04-03) |
| GTM | Container ID: [TBD] | Not configured |
| GA4 | Property ID: [TBD] | Not configured |
| Meta Pixel | Pixel ID: [TBD] | Not configured |
| Nextdoor Pixel | Pixel ID: [TBD] | Not configured |
| Google Ads | Account ID: [TBD] | Not active |
| Facebook Ads | Ad Account ID: [TBD] | Not active |
| TikTok Ads | Ad Account ID: [TBD] | Not active |
| MS Clarity | Project ID: [TBD] | Not configured |

---

## Contractor Pipeline

| Contractor | City | Status | Pricing Model | Per Accepted Bid |
|------------|------|--------|---------------|------------------|
| [NAME TBD] | TBD | **COMMITTED ✅ (2026-03-12)** | Pay per accepted bid | $1,000 |
| [VACANT] | Wausau Metro | Prospecting | — | — |
| [VACANT] | Mosinee/Merrill | Prospecting | — | — |

---

## Campaign Status

| Platform | Campaign | Status | Spend/mo | CPL |
|----------|----------|--------|----------|-----|
| Google Ads | Wausau Deck Builders | NOT LIVE | — | — |
| Facebook Ads | Wausau Homeowners | NOT LIVE | — | — |
| TikTok | Awareness | NOT LIVE | — | — |
| Nextdoor | Community + Paid | NOT LIVE | — | — |

---

## Agent Status

| Agent | Prompt Built | Deployed | Notes |
|-------|-------------|----------|-------|
| market-research | Yes | No | — |
| web-dev | Yes | No | — |
| ad-campaign | Yes | No | — |
| lead-qualification | Yes | No | — |
| lead-routing | Yes | No | — |
| contractor-sales | Yes | No | — |
| revenue-optimization | Yes | No | — |
| accounting | Yes | No | — |
| analytics | Yes | No | — |

---

## Session Log

### 2026-03-11
- Built full department file structure from scratch
- Created 9 agent prompt.txt files
- Created seed files for all departments
- Updated CLAUDE.md: stack, agents 8+9, department map, Make/Tally references
- Created memory system (this file + MEMORY.md)
- Status: Phase 1 not yet started — no contractors contacted

### 2026-03-12
- **MILESTONE: First contractor commitment secured** ✅
- Pricing model confirmed: Pay per accepted bid at $1,000 (contractor pays when they win the job)
- Updated all pricing references across 13 files
- Next step: Build Tally form + Webflow page + Make automation, then launch ads

### 2026-03-28
- **MILESTONE: Tally form built** ✅ — Form ID: 81GbEO | https://tally.so/r/81GbEO
- Form created manually in Tally UI (API script had block-structure incompatibility)
- Post-submit confirmation message requires Tally Pro — decision: redirect to cwdeckbuilders.com/thank-you
- Sub-Phase 3A complete

### 2026-03-29
- **MILESTONE: Full website plan created + all content files built** ✅
- **KEY DECISION: Tally replaced by Webflow native forms** — simpler stack, better design control
- **KEY DECISION: Single landing page expanded to 21-page authority site** — invest in SEO + authority + conversion
- Created: website-plan.md (full spec), design-system.md, site-architecture.md
- Updated: base.html (complete rewrite for multi-page Webflow), quote-form-fields.json (Webflow forms)
- Created: 21 page content files (homepage, get-a-quote, thank-you, 5 cities, our-builders, gallery, about, FAQ, cost-calculator, blog index + 4 articles, privacy, terms)
- Created: calculator.js (client-side deck cost calculator)
- Updated: phase-1-plan.md (3B section expanded), CLAUDE.md (tech stack + phase checklist)
- Updated: MEMORY.md + this file
- Next: Build website in Webflow using reference files, then Make automation, then ads

### 2026-04-02
- **MILESTONE: Webflow Phase A complete** ✅ — design system, global styles, header, footer, all core components built
- **MILESTONE: Webflow Phase B homepage complete** ✅ — all homepage sections built in Webflow
- All homepage sections converted to reusable Webflow components (available for city pages, supporting pages, future development)
- Updated: website-plan.md (Phase A marked complete, Phase B homepage marked complete)
- Updated: MEMORY.md (current phase + open items checklist)
- Next: Phase B remaining — Get a Quote page, Thank-You page, end-to-end form flow test

### 2026-04-03 — Phase E
- **MILESTONE: Webflow Phase E complete** ✅ — cost calculator page, Blog Posts CMS, /blog index, blog article template
- Blog Posts CMS collection ID: 69d043662f0a55d546c1f597 — 4 articles seeded and published
- Blog Posts template page ID: 69d043662f0a55d546c1f61a — article-hero-section, article-body-section, dark CTA sections built
- /blog index page ID: 69d04373a1cf39d4f6680755 — hero + 2×2 CMS-bound card grid + dark CTA
- /cost-calculator page ID: 69d04360b87483b9bbc76b04 — hero + calculator div + material table + dark CTA
- Built local sync files: cost-calculator/index.html, blog/index.html, blog/article-template/index.html
- Updated agent config: .claude/agents/web-dev.md — 5 new components added to COMPONENT INVENTORY
- MANUAL STEP OUTSTANDING: Calculator JS must be pasted into /cost-calculator Page Settings > Custom Code > Before </body> — data_scripts_tool is limited to 2,000 chars and cannot accommodate the 241-line script
- MANUAL STEP OUTSTANDING: Blog article template page in Webflow Designer needs sections built (Designer was disconnected during this session; see article-template/index.html for full section spec)
- Next: Phase F — SEO meta tags, JSON-LD schema (Article, FAQPage), GTM + GA4 + Meta Pixel + Nextdoor Pixel + Google Ads conversion + MS Clarity

### 2026-04-06 — LLC formed
- **MILESTONE: Central Wisconsin Deck Builders, LLC formed** ✅ — WI single-member LLC · James Slogar, Sole Member · EIN 41-5355234 · WI Entity ID C138564 · registered office 906 N 16th Ave, Wausau WI 54401

### 2026-04-07 — Contractor agreements sent
- **MILESTONE: Contractor agreement v1 sent via DocuSign** ✅ — Ben Barton (Barton Builders LLC, envelope 462464338657) + John Garcia (John Garcia Construction, LLC, envelope 465926077160)

### 2026-04-17 — Manual asset + schema round + contractor signatures
- **MILESTONE: Contractor agreements signed** ✅ — both Barton + Garcia signed PDFs in /sales/contractor-agreements/
- Manual steps completed: FAQPage JSON-LD, Article JSON-LD, gallery photos replaced with real Wisconsin deck photos, calculator.js pasted into /cost-calculator Custom Code

### 2026-04-18 — Phase F + DNS + Make scenario v1
- **MILESTONE: Webflow Phase F complete** ✅ — GTM container published; GA4 + Meta Pixel + Nextdoor Pixel + Google Ads Conversion + MS Clarity + 3 event tags all firing live on cwdeckbuilders.com
- **MILESTONE: DNS cutover live** ✅ — cwdeckbuilders.com → 301 → www.cwdeckbuilders.com (200); site live on custom domain with GTM snippet active
- **MILESTONE: Make scenario v1 built** ✅ — `CWDB Lead Routing — v1` · scenario 4792854 · hook 2183206 · webhook `https://hook.us2.make.com/p4cbbf1lq3bl6lpew6c3odahnrhoc1m4`. End-to-end: webhook trigger → router → HubSpot upsert + deal creation → contractor search + iterator → Gmail + Twilio sends → admin summary + DQ paths. INACTIVE pending Jim's review, connection auth, activation.
- **Make HubSpot OAuth authorized** ✅
- **DECISION: Ad budget confirmed** — $50/day ($30 Google + $20 Meta; $0 Nextdoor paid — organic-only)
- **DECISION: Lead-routing = Make** (not RemoteTrigger) — reverses 2026-04-15 webhooks.json pivot
- **DECISION: Make paid tier upgrade** — exact tier TBD (Core $9 or Pro $16)
- **Created:** _vault/state-of-cwdb.md as single source of truth

### 2026-04-19 — Twilio port-in + state refresh
- **DECISION: Phone strategy** — port Google Voice (+17155447941, canonical NAP) → Twilio rather than buy new number. 3–7 business day window. Brief unreachable period expected at cutover. GV SMS history will not transfer. Scenario Twilio connection blocked until port completes + SID/Auth Token captured.
- **Gmail connection** — still pending Jim's OAuth
- **State refresh** — _vault/state-of-cwdb.md TL;DR, Outbox, Next Session Agenda rewritten; Manual Queue, Waiting On, Risks, Wins, Budget patched with Twilio port + Make paid tier + connection state; Recent Sessions prepended with 2026-04-19-001
- Next: wait on Twilio port; drive Gmail OAuth + Nextdoor verification + Barton/Garcia deal-stage approval + HubSpot pipeline build to ready state so scenario activation is one-step when Twilio creds land
