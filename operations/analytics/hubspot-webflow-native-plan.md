# WS-1 Phase A — HubSpot ↔ Webflow Native Integration Plan (Canonical)

**Status:** Authoritative architecture as of 2026-04-28. Replaces `path-a-vs-path-b-server-events.md` (Cloudflare Worker vs Make scheduled) and supersedes `server-event-spec.md` (Cloudflare Worker spec — now deprecated).
**Decided by:** Jim, 2026-04-28: *"completely rework plan. i'm going to use the hubspot connection with webflow to update the crm."*
**Author:** cwdb-ceo-operator (2026-04-28)

---

## TL;DR

**New architecture:** Webflow form → HubSpot Contact → HubSpot lifecycle/deal stage transitions fan out to Google Ads (Offline Conversions), Meta (CAPI), and GA4 (Measurement Protocol). All routing happens inside platforms Jim already pays for or pays nothing for; no custom serverless code, no Make reactivation, no Cloudflare Worker.

**The trade we made:** We lose the **Cloudflare Worker's real-time fan-out and edge-side hashing** (Path A) AND we lose the **Make scheduler's UI visibility** (Path B). What we gain is a stack that lives inside Webflow + HubSpot — both of which Jim can edit himself, both of which the agent system already has MCP access to, and neither of which violates the 2026-04-19 Make pivot.

**What this plan now critically depends on:** **HubSpot pipeline must actually exist in HubSpot.** The pipeline JSON spec at `operations/automation/hubspot-lead-pipeline.json` defines stages on paper. Until those stages are live in the HubSpot UI with workflow automations attached, **none of the closed-loop fan-out routes work**. This was the "Phase B Gate 1" prereq in the old plan; under the new plan, **it is the entire game.** Flagging in queue.

**Honest read on what we lost vs the old plan:** The old Path A had a "Phase A1" piece — **browser-side Google Ads Enhanced Conversions** — that was completely independent of any serverless infrastructure. It was a no-regret 2-hour GTM tag update that improves Google Ads match rate ~70% within 48 hours. **That piece survives the rework intact.** Recommendation: treat A1 as a parallel quick-win track that ships independently of the HubSpot reroute. Surfaced in queue.

**Honest read on Lever 4 (proof) since this rework hit Jim's inbox:** Both contractor calls returned zero testimonials. Proof sprint via existing contractors is structurally dead. The new plan's reliance on HubSpot pipeline live + first homeowner deal close means **the first proof asset doesn't materialize until first revenue does.** This is a runway problem the rework doesn't solve. Surfaced in §6 below and in state-file §8.

---

## §1 Architecture overview

```
┌─────────────────────────────────────────────────────────────────────┐
│  Webflow form submit on /get-a-quote                                │
│  (existing form: name, email, phone, address, project_type, etc.)   │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               │ Webflow native HubSpot integration
                               │ (Webflow Apps marketplace) maps form
                               │ fields → HubSpot Contact properties
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  HubSpot Contact created                                            │
│  - lifecycle_stage = lead (initial)                                 │
│  - hs_lead_status = new                                             │
│  - GCLID + fbclid stored as custom properties (from URL params)     │
│  - email, phone, name, address (raw — HubSpot stores plaintext)     │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               │ HubSpot Workflow (lifecycle change trigger)
                               │ creates Deal in pipeline; advances stage
                               │ as homeowner→quoted→accepted→won
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  HubSpot Deal in pipeline `cwdb-leads`                              │
│  Stages: new → contacted → quoted → accepted → won (or lost)        │
└──┬───────────────────┬───────────────────┬──────────────────────────┘
   │                   │                   │
   │ Native            │ Native            │ Workflow → Webhook →
   │ HubSpot           │ HubSpot           │ GA4 Measurement
   │ ⇄ Google Ads      │ ⇄ Meta            │ Protocol (DIY)
   │ integration       │ integration       │
   ▼                   ▼                   ▼
Google Ads OCI    Meta Ads CAPI       GA4 generate_lead +
(Offline Conv     (Conversions API    (qualified_lead +
 Import on        on lifecycle        accepted_bid as
 stage change)    stage change)       lifecycle progresses)
```

**Two browser-side things that stay independent and ship in parallel:**
1. **Google Ads Enhanced Conversions for Leads** (A1 from old plan) — GTM-only tag update, ships in <2 hrs, no HubSpot dependency, ~70% match-rate boost in 48h.
2. **Existing Pixel + GA4 web stream** — already firing on form submit. Source of truth for browser-side conversion counts. The HubSpot fan-out is **augmentation**, not replacement.

---

## §2 Verify each claim before building (research-first)

This plan is being authored without the time to spike each integration in the actual HubSpot + Webflow UIs today. The four verification gates below are **mandatory before committing to build**. Each is small (15-30 min) and is delegated to the analytics agent in the next session.

### §2.1 Webflow → HubSpot integration capability

**Claim under test:** Webflow has a native HubSpot integration (via Webflow Apps marketplace OR via direct HubSpot account connection in Webflow form settings) that pushes Webflow native form submissions directly into HubSpot as Contacts.

**What to verify:**
- Does the integration work for **Webflow native forms** (i.e. a `<form>` element built in the Designer with submit-to-Webflow), or does it only work for forms inside **Webflow Logic** flows (a separate paid product)?
- What does the field mapping UI look like? Are arbitrary form fields mappable to arbitrary HubSpot Contact properties, or are only standard fields (email, name) supported?
- What is the lag between form submit and Contact creation in HubSpot? (Real-time webhook, batched sync, or other?)
- Is there a Workspace-tier requirement on Webflow side? (Webflow Free vs CMS vs Business vs Enterprise.) Webflow's marketplace apps historically require a paid Workspace.
- Is there a tier requirement on HubSpot side? (HubSpot Free CRM vs Starter vs Professional.)
- What happens to URL parameters at submit time (GCLID, fbclid) — does the integration capture them as custom properties automatically, or does form HTML need to inject them as hidden fields?

**Where to look:**
- Webflow Apps marketplace: https://webflow.com/apps (search "HubSpot")
- Webflow form integration docs: https://help.webflow.com/hc/en-us/sections/360008636073 (form integrations index)
- Webflow direct form integration page in Site Settings → Forms tab → "Integrations" — confirm whether HubSpot is listed alongside Mailchimp / Zapier / etc.
- HubSpot Webflow integration listing: https://ecosystem.hubspot.com/marketplace/integrations (search "Webflow")

**Plan B if claim fails:**
- HubSpot's **Forms API** (`POST /submissions/v3/integration/submit/{portalId}/{formGuid}`) allows submitting form data to a HubSpot-defined form from any source. We add a `fetch()` in the Webflow form's submit handler that POSTs to HubSpot's Forms API with the form data. This requires no Cloudflare Worker (the POST goes browser → HubSpot directly), but does require:
  - A HubSpot form to exist (created in HubSpot Marketing → Forms — note: Forms are gated on certain HubSpot tiers; Free CRM may not include them; Forms-only or Marketing Hub Free does).
  - Or fall back to HubSpot's contact-creation endpoint via a private app token (`POST /crm/v3/objects/contacts`), which requires hashing the token onto the page — **rejected**, leaks secret to the browser.
- If neither works at our HubSpot tier, the rework's premise breaks and we revisit.

### §2.2 HubSpot → Google Ads native integration capability

**Claim under test:** HubSpot has a native Google Ads integration that supports Offline Conversions Import on lifecycle stage / deal stage transitions. We can fire conversion events to Google Ads when a HubSpot Deal moves through the pipeline.

**What to verify:**
- Where in HubSpot is the Google Ads connector configured? (Marketing → Ads → Connect Account; or Settings → Integrations → Google Ads.)
- What is the conversion event creation flow? Can we define a custom conversion (e.g. `accepted_bid`) tied to a HubSpot Deal stage = `accepted` transition, and have HubSpot push that as an Offline Conversion to the linked Google Ads account?
- Does it require GCLID to be stored on the Contact at creation time? (Almost certainly yes — Offline Conversions Import requires GCLID for attribution back to the click.)
- What HubSpot tier is required? Historically the "Marketing Events / Ads tracking" feature has been gated on Marketing Hub Starter or higher. **CWDB is on HubSpot Free CRM. This is a likely blocker.**
- Latency: stage-change → Google Ads conversion fire — minutes? hours?

**Where to look:**
- HubSpot Knowledge: search "Google Ads integration" at https://knowledge.hubspot.com/
- HubSpot Ads tool: https://app.hubspot.com/ads (will return a tier-gated "upgrade" page if not licensed — itself a useful signal)
- Google Ads → Tools → Conversions → New conversion → Import → CRM/HubSpot — Google's side of the wire.

**Plan B if claim fails (HubSpot tier blocks it):**
- HubSpot Workflow → Webhook action → POST to Google Ads Conversion API directly. This is technically possible from HubSpot's Workflow Webhook module (which IS in HubSpot Free CRM as far as we know — re-verify). Payload would mirror the OCI spec: `gclid`, `conversion_action_name`, `conversion_date_time`, `conversion_value`. Adds complexity but stays inside HubSpot.
- Worst case: defer Google Ads OCI until first revenue justifies a HubSpot tier upgrade.

### §2.3 HubSpot → Meta native integration capability

**Claim under test:** HubSpot has a native Meta Ads integration that supports CAPI from lifecycle/deal stage events.

**What to verify:**
- Same flow as Google: Marketing → Ads → Connect Meta account.
- Does it push CAPI events (`Lead`, `Purchase`, custom events) on stage transitions, or is it strictly for ad-account read (impressions, spend reporting back to HubSpot)?
- Tier-gated: same likely concern as Google — Marketing Hub Starter+.
- Does it handle EMQ-boosting hashed PII automatically? (HubSpot already stores raw email/phone/name; should be straightforward.)

**Where to look:**
- HubSpot Knowledge: search "Facebook Ads integration" at https://knowledge.hubspot.com/
- HubSpot Ads tool: https://app.hubspot.com/ads/{portalId}/manage
- Meta Events Manager → Pixel `1276568654662913` → Settings → Conversions API → "Set up via partner integration" → check if HubSpot is listed.

**Plan B if claim fails (HubSpot tier blocks it):**
- HubSpot Workflow → Webhook → POST to Meta CAPI endpoint directly. We have the spec from the deprecated `server-event-spec.md` §3.2 — the payload shape is fully documented. Workflow webhook calls Meta's `/v19.0/{pixel_id}/events` with `META_CAPI_TOKEN` in the URL (token stored as a HubSpot secret if available, or in workflow URL — webhook URLs in HubSpot are not hidden from any portal user, which is a real concern for storing the access token in plain text).
- Same fallback pattern as Google: workflow + webhook is the universal escape hatch, but introduces hand-built JSON shaping.

### §2.4 HubSpot → GA4 path

**Claim under test:** No clean native integration exists; we need a workflow webhook to GA4 Measurement Protocol.

**Verification (faster — confirming absence):**
- Search HubSpot Marketplace for "GA4" / "Google Analytics 4" — confirm only third-party paid connectors exist (e.g. Tray.io, Workato, MakeForms — all gated on HubSpot Operations Hub tiers).
- Confirm HubSpot Workflow Webhook action can hit `https://www.google-analytics.com/mp/collect` with arbitrary JSON payload.

**Plan:**
- HubSpot Workflow on stage change → Webhook action → POST to GA4 MP `https://www.google-analytics.com/mp/collect?measurement_id=G-ZQ19JEF9KC&api_secret=<GA4_API_SECRET>` with payload from deprecated §3.3.
- Three workflows total (one per lifecycle stage we want to attribute): `generate_lead` on Contact creation, `qualified_lead` on Deal stage = `quoted`, `accepted_bid` on Deal stage = `accepted`.
- API secret stored in HubSpot as a... **problem.** HubSpot Workflow webhook URLs are visible to any portal user with workflow-edit permission. Storing the GA4 API secret in the URL is a low-blast-radius leak (the secret allows event forwarding only, not data read), but it's worth flagging. **Acceptable given Jim is the only portal user.**

---

## §3 Build sequence (assuming all §2 verifications pass)

### Phase 0 — Verification gate (~2 hours, analytics agent)

Run all four §2 verifications. Document results in `operations/analytics/hubspot-webflow-verification-2026-04-29.md`. **Do not start Phase 1 until verification report exists and is reviewed.**

### Phase 1 — HubSpot pipeline live (~3-4 hours, contractor-sales agent)

This is the **critical-path prereq** that gates everything else.

1. **Build the deal pipeline in HubSpot UI.** Reference `operations/automation/hubspot-lead-pipeline.json` for stage names + properties. Stages: `new` → `contacted` → `quoted` → `accepted` → `won` (and `lost` as a closed-lost branch).
2. **Create the workflow that generates a Deal on Contact creation.** Lifecycle stage = `lead` triggers Deal creation in pipeline `cwdb-leads`, stage `new`, owner = Jim.
3. **Add custom Contact properties** for `gclid`, `fbclid`, `utm_source`, `utm_medium`, `utm_campaign` if not already present. These are required for downstream attribution.
4. **Verify with a test Contact creation** via HubSpot UI manual entry that the workflow fires and a Deal is created in the right stage.

### Phase 2 — Webflow → HubSpot wiring (~1-2 hours, web-dev agent)

Conditional on §2.1 result.

**Path A (native integration works):** Configure the Webflow Apps HubSpot integration on the `/get-a-quote` form. Map fields. Add hidden inputs for GCLID/fbclid capture from URL params. Submit a test lead end-to-end; confirm Contact appears in HubSpot, Deal auto-creates per Phase 1 workflow.

**Path B (Forms API fallback):** Add a `fetch()` to the Webflow form submit handler that POSTs to HubSpot Forms API. Implement as a Webflow site script following the `hero_form_handoff` and `quote_page_polish` patterns. Same verification.

### Phase 3 — Google Ads + Meta + GA4 fan-out (~2-4 hours, analytics agent)

Conditional on §2.2 / §2.3 verification.

For each of Google Ads / Meta / GA4:
- **Native integration available:** configure in HubSpot Ads UI, define conversion event mapped to lifecycle/deal stage, verify in respective platform's events manager.
- **Workflow webhook fallback:** build a HubSpot Workflow that fires on the chosen stage transition, with a Webhook action POSTing the platform-specific payload. Test with a manual stage advance on the test Deal from Phase 1.

### Phase 4 — A1 quick win parallel track (~2 hours, analytics agent)

**Independent of all above.** Update GTM Google Ads Conversion tag to enable User Provided Data (Enhanced Conversions for Leads).

- In the existing Google Ads Conversion tag, scroll to "User Provided Data" section.
- Source from Data Layer Variables: `enh_conv_user_data.email`, `enh_conv_user_data.phone`, `enh_conv_user_data.first_name`, `enh_conv_user_data.last_name`, `enh_conv_user_data.address.postal_code`, `enh_conv_user_data.address.country` (= `'US'`).
- Push raw form values into `dataLayer` on form submit (already partially done by `quote_page_polish` script — extend it).
- "Hash data in GTM" stays checked (default) — GTM applies Google's normalization and SHA-256.
- Publish container.
- Verify in 48h: Google Ads → Tools → Conversions → `from_submit_quotes` → Diagnostics → User-provided data status → "Recording: Good" with >70% match rate.

**This track ships independent of HubSpot pipeline build and delivers a real measurable improvement to Smart Bidding signal in 48 hours.**

---

## §4 What Jim does in this plan

| Action | When | Time |
|---|---|---|
| Approve Phase 0 verification dispatch | Now (Outbox) | <1 min |
| Confirm A1 Enhanced Conversions parallel track | Now (Outbox) | <1 min |
| Provision GA4 Measurement Protocol API secret | Phase 3 | 5 min |
| Generate Meta CAPI access token (if §2.3 falls back to webhook) | Phase 3 | 5 min |
| Decide whether to upgrade HubSpot tier if §2.2/§2.3 native integrations are tier-gated | After Phase 0 | TBD pending verification |

---

## §5 What Jim does NOT do in this plan

- Edit Cloudflare Worker code (no Worker exists).
- Edit Make scenarios (Make stays parked per 2026-04-19 pivot).
- Manage TypeScript / wrangler / npm tooling.
- Maintain `wrangler.toml` secrets.

The trade for getting all of those off Jim's plate: HubSpot pipeline build is on Jim's plate (or the contractor-sales agent's plate, with Jim verifying in HubSpot UI).

---

## §6 Honest tradeoffs and risks

### What we lose vs the deprecated Cloudflare Worker plan (Path A)

1. **Real-time fan-out.** Worker would have hit Meta CAPI in ~500ms; HubSpot workflow webhooks fire on a polling cadence (typically 1-5 min). Smart Bidding doesn't care; this is fine.
2. **Deterministic `event_id` for Meta dedup.** With workflow webhooks, the server-fired Meta event won't share an `event_id` with the browser-fired Pixel event. Meta will count both — likely as ~1.3-1.5 events per lead instead of 1.0. Workaround: in the workflow webhook, build the `event_id` as `cwdb_${contact_id}_${created_timestamp}` and update the GTM Pixel tag to compute the same string from `dataLayer` on browser submit. Achievable but adds a fragile coupling.
3. **Edge-side hashing.** Worker would have done all SHA-256 in Cloudflare. Now hashing happens in HubSpot's webhook payload templating (HubSpot supports Handlebars-like template functions; SHA-256 is NOT in their built-in helpers as of last public docs). **This may force us to use HubSpot's "send raw, let Meta hash" path** — which Meta does support but it's not ideal because raw PII traverses HTTPS to Meta. Not worse than what 99% of HubSpot customers do; just worth noting.
4. **The architectural elegance of "one canonical event delivery layer."** Now we have: browser Pixel + GTM (web stream), HubSpot → Google Ads (offline), HubSpot → Meta (CAPI), HubSpot → GA4 (MP). Three platforms, three different mechanisms. The Worker would have unified them. **This is the real architectural cost; it's ongoing rather than one-time.**

### What we lose vs the deprecated Make scheduled plan (Path B)

1. Make's polished UI. Replaced by HubSpot's workflow UI, which is also polished but less developer-friendly for inspecting webhook payloads.
2. Native Make modules for Meta CAPI / GA4 MP. Replaced by HubSpot Workflow Webhook actions, which are more DIY (you write the JSON body in a textarea).

### What we gain vs both deprecated plans

1. **No infra to maintain.** No Cloudflare account, no wrangler, no Make subscription, no Make connection rotation.
2. **Aligns with Jim's stated preference for in-platform tooling.** This is a standing pattern — see the new `server-events-rework-2026-04-28.md` memory.
3. **HubSpot pipeline gets built either way.** The pipeline was already on the queue as `[ ] Set up HubSpot pipeline (reference /sales/crm/pipeline-stages.json)`. Under the deprecated plans it was deferred behind Phase A; under the new plan it IS Phase A. We're not adding a new TODO; we're promoting an existing one to critical-path.
4. **Aligns with Hormozi's "money model" frame.** The HubSpot pipeline IS the closed-loop attribution mechanism. Building it serves both the ops-tracking goal and the analytics-attribution goal. One artifact, two outcomes.

### The Lever 4 (proof) interaction

**This is the risk that compounds over the build time of the rework.**

Jim called Ben + John on 2026-04-28. Both confirmed zero homeowner testimonials available to share. **The proof sprint via existing contractors is structurally exhausted.** Under the new plan, the next testimonial we collect will come from a homeowner whose project we deliver — which requires the full funnel to fire end-to-end at least once: lead → quoted → accepted → job completed → testimonial captured. Optimistically that's 4-8 weeks from now. Under the deprecated Path A plan, the timeline was the same — except Path A was 6-8 hours of build time vs the new plan's ~12-15 hours. **The new plan extends the no-proof window by ~1 week.**

**Decision implication for Jim's Outbox:** ad spend continues during the rework build. CPL data accrues against a no-proof landing page. Two valid paths:

- **(α) Pause Google Ads until first deal closes** (conservative; preserves ad budget but starves the funnel of the leads needed to generate that first deal).
- **(β) Keep $30/day Google live** (aggressive; burns ad budget against unfavorable proof odds but is the only mechanism to manufacture the first deal that breaks the proof gridlock).

CEO recommends β. Reasoning: $30/day for 4 weeks = $840 spend. If even one lead converts to an accepted bid, recovers 1.2x that spend. Pausing now means waiting for proof we cannot create without leads we cannot generate without ads. Bootstrap problem — the only escape is forward. Surface as queue item.

---

## §7 Status of the deprecated artifacts

- `operations/analytics/path-a-vs-path-b-server-events.md` — **deprecated 2026-04-28.** Header note added pointing here. Decision audit trail preserved (the rationale on why Path A and Path B were each viable matters for future architectural decisions).
- `operations/analytics/server-event-spec.md` — **deprecated 2026-04-28.** Header note added pointing here. Useful content preserved: §2 hashing normalization rules apply if we ever fall back to a workflow-webhook with hashing (HubSpot doesn't have native SHA-256, but if we add a tiny CF Worker for hashing-only at some point, the spec is the recipe).
- `agents/agent-memory/cwdb-ceo-operator/MEMORY.md` — pointer to Path A/B memo dropped, pointer to this new doc added.
- `agents/agent-memory/analytics/MEMORY.md` — server-event-spec marked deprecated, this doc added as canonical.

---

## §8 Open questions for Jim

1. **Approve dispatch of analytics agent for Phase 0 verification (the four §2 checks).** ETA: <2 hours. Default if no answer: dispatch on next session.
2. **Approve A1 Enhanced Conversions parallel track.** ETA: <2 hours. No HubSpot dependency. Default: ship on next session.
3. **(α) vs (β) on ad spend during the rework window.** CEO recommends β. Default if no answer: stay live at $30/day.
4. **HubSpot tier upgrade contingency.** If §2.2 or §2.3 verification reveals that native Google Ads / Meta integrations require Marketing Hub Starter ($20-50/mo), are you willing to upgrade, or default to workflow webhook fallbacks at no additional cost? Recommend defaulting to workflow webhooks until we have first revenue justifying the upgrade. Default if no answer: workflow webhooks.

---

## §9 Changelog

- 2026-04-28 — Initial authoring after Jim's "completely rework plan" decision. Replaces Path A/Path B memo and Cloudflare Worker spec. Surfaces HubSpot pipeline as critical-path prereq, A1 quick-win as parallel track, Lever 4 runway risk as the structural problem the architecture cannot solve.
