# Directives — New asks not yet started

> Newest at top. CEO routes from here into `in-flight.md` with owner + acceptance + ship-type.
> Jim: drop new directives at the top with a quick description. CEO assigns the WB-ID and routes on next brief.

---

## Active directives

- [WB-018] Legal/compliance punch list from fulfillment-pivot opinion (2026-06-10)
  - Created: 2026-06-10. Updated 2026-06-10 late: items 1 and 3 CLOSED by owner decision; item 2 risk-accepted for the staining job.
  - Source: legal-compliance-counsel memo on Option A (CWDB estimates, builder contracts) vs Option B (CWDB primes, subs out)
  - Owner decisions 2026-06-10 (Jim): NO Wisconsin sales tax charged on any CWDB revenue (lead fees or construction/staining); Overbeck staining job proceeds WITHOUT GL insurance bound (risk accepted). Both recorded; do not re-raise.
  - Remaining items:
    1. ~~WI DOR staining-tax determination~~ CLOSED: owner decision, no sales tax
    2. Bind GL insurance (still required before DSPS cert filing; staining-job gap risk-accepted by Jim 2026-06-10)
    3. ~~WI DOR lead-fee exemption confirmation~~ CLOSED: owner decision, no sales tax
    4. DSPS filings: Qualifier 12-hour course + entity Dwelling Contractor Certification (insurance binds first)
    5. City of Wausau / Marathon County: cosmetic-vs-structural permit line + any local bond/registration
    6. One-time WI attorney review: estimate disclosure language, combined estimate/work-order doc, home improvement contract, subcontractor agreement, amendment, side letter
  - Suggested owner: Jim (external calls) + legal-compliance-counsel (document prep done)
  - Acceptance: each item checked off with date + outcome noted here
  - Ship type: artifact-prod (compliance)

- [WB-017] Scrub "licensed and insured" claims sitewide (pre-license ATCP 110.02 exposure)
  - Created: 2026-06-10
  - Source: legal-compliance-counsel memo, Option A disclosure requirements
  - Issue: until CWDB holds the DSPS cert + GL insurance, no site/ad/estimate copy may imply CWDB itself is a licensed builder. CWDB self-describes as a deck project and estimating service on Option-A jobs; the named builder carries the licensed/insured claim.
  - Suggested owner: web-dev agent (site copy) + content-writer (ad copy review)
  - Acceptance: site-wide grep of Webflow copy for licensed/insured claims; each instance either removed, attributed to the named builder, or made true (post-licensing)
  - Ship type: build

- [WB-016] HubSpot private app scopes: schema write + files + objects write — **RESOLVED 2026-06-11**
  - Resolution: Jim added the scopes; properties created (lead_channel, tcpa_consent_source, cwdb_job_number, walkthrough_datetime); Sjoberg/Darlene (phone) + Nayak/Keuler (manual) tagged and ingested; Overbeck estimate + INV-2026-001 attached to deal 324817992387; Overbeck deal stamped CWDB-2026-001. Note: files API access must be PRIVATE (HIDDEN_* needs files.ui_hidden.write).
  - Created: 2026-06-10
  - Source: phone-lead channel tracking, cwdb_job_number property, estimate-PDF deal attachments (all blocked on scopes)
  - Issue: Jim: direct link https://app-na2.hubspot.com/private-apps/245712220 (portal 245712220, NA2; the app exists, the token works for reads). If the link 404s, confirm the portal ID shown in the HubSpot URL bar matches 245712220 (wrong-account login is the usual cause). Open the app > Scopes tab, add these four, save (2 minutes):
    1. `crm.schemas.contacts.write` (create lead_channel + tcpa_consent_source properties)
    2. `crm.schemas.deals.write` (create cwdb_job_number + walkthrough_datetime properties)
    3. `files` (upload estimate/invoice PDFs; `templates/scripts/attach-file-to-deal.ps1` is built and tested to this wall)
    4. `crm.objects.deals.write` (stamp estimate amount/date on deals)
  - Then Claude: creates the 4 properties, tags the skipped contacts (Sjoberg + Darlene = real phone leads; Sjoberg already has a $13,443 deal invisible to the warehouse), re-runs the pull, and attaches the Overbeck estimate + INV-2026-001 to deal 324817992387.
  - Suggested owner: Jim (2 minutes) then cwdb-ceo-operator
  - Acceptance: properties exist; Sjoberg + Darlene in fact_leads on next pull; Overbeck PDFs visible on her deal timeline
  - Ship type: build

- [WB-015] WB-002 GMB park default-ship trigger 2026-05-11
  - Created: 2026-05-10
  - Source: 24h default-ship rule; Day 10 carry on WB-002
  - Issue: WB-002 GMB ship/park/kill carrying since 2026-04-30 (Day 10 today). CEO park recommendation at `_vault/decisions/wb-002-gmb-park.md` since 2026-05-09. If Jim doesn't reply by EOD 2026-05-11, default-ship a park (NOT kill — reversibility cost).
  - Suggested owner: cwdb-ceo-operator (next morning brief or session-end)
  - Acceptance: 2026-05-11 brief either reads "WB-002 resolved by Jim mark" or "WB-002 default-shipped to park; rollback path: edit `_vault/decisions/wb-002-gmb-park.md` to flip to execute or kill."
  - Ship type: artifact-prod (escalation protocol)
  - Notes: %% Day 11 = forced park. Park ≠ kill — assets preserved, 4 named un-park triggers documented. %%

- [WB-014] Day-5 default-ship preparation if Jim engagement remains zero
  - Created: 2026-05-08
  - Source: Day 4 carry pattern
  - Issue: 4 consecutive briefs with zero Jim marks. CEO has shipped what can be agent-shipped; remaining items are Jim-required UI sessions and decisions. If Day 5 (2026-05-09) opens with another zero-mark brief, CEO should compose a "minimum viable engagement" ask — a single 30-second response to one specific question that unblocks the most carry — and surface it as a single-question email/text-ready paste to Jim, NOT another brief.
  - Suggested owner: cwdb-ceo-operator (next morning brief composition)
  - Acceptance: If 2026-05-09 brief has zero %...% from Jim, CEO drafts a single-question outreach (under 100 chars) requesting one decision that unblocks the most other items. The question goes in §6 of the 2026-05-09 brief AND a copy ready-to-send sits at `/sales/outreach/jim-self-outreach-2026-05-09.md`.
  - Ship type: artifact-prod (escalation protocol)
  - Notes: %% This is a calibration play. The operator-bottleneck has been honestly named in §7 for 4 days running. If Day 5 still has zero engagement, the bottleneck-naming itself isn't enough — needs a single-question reduction. %%

- [WB-013] Brief Top-3 framing correction — flag for tomorrow's brief
  - Created: 2026-05-07
  - Source: 2026-05-07 brief execution session
  - Issue: Today's brief framed WB-001 as "Tier 1 (Recipe) — dispatch lead-routing agent." That's wrong. `_vault/board/in-flight.md` already documents the truth: HubSpot Workflows API is Marketing Hub Pro+ ($800+/mo) and not exposed by HubSpot MCP toolkit on Starter tier. WB-001 is Tier 3 (Jim UI execution) and has been since 2026-05-05.
  - Suggested owner: cwdb-ceo-operator (next brief generation pass should pull from in-flight.md status, not the 04-spec which still reads "ready-for-jim-execution" ambiguously)
  - Acceptance: tomorrow's brief Top-3 #1 reads "Tier 3 — Jim UI build, 25 min" with link to walkthrough + new postflight harness
  - Ship type: artifact-prod (brief generation correction)
  - Notes: %% This is a self-correction. The brief should not have said "dispatch lead-routing agent via Agent tool" — there is no Agent tool in the CEO operator session and no Workflows API in the HubSpot MCP. The pattern of restating the spec's surface framing (which still says ready-for-jim-execution) instead of the in-flight board's truth (Path A ruled out) caused the framing drift. %%

- [WB-005] Real Facebook/Instagram/Nextdoor business URLs (footer fix)
  - Created: 2026-04-19
  - Source: state-of-cwdb.md §3 Jim's Queue
  - Suggested owner: web-dev agent + Jim (Jim provides URLs)
  - Acceptance: Webflow footer shows real URLs (not placeholders) on production
  - Ship type: build
  - Notes: %% Whenever — non-blocking %%

- [WB-006] Post-launch ad-testing plan
  - Created: 2026-04-21
  - Source: state-of-cwdb.md §3 Jim's Queue
  - Suggested owner: revenue-optimization agent
  - Acceptance: Written hypothesis, creative variants, CPL thresholds, kill criteria — ready before scaling beyond $50/day
  - Ship type: artifact-prod (planning doc)
  - Notes: %% Deferred until Week-1 data lands clean — Google Ads numbers needed first %%

- [WB-007] Testimonial-collection consent + script for first homeowner close
  - Created: 2026-04-28
  - Source: state-of-cwdb.md §3 Jim's Queue
  - Suggested owner: contractor-sales agent
  - Acceptance: Standing template ready (text + photo + optional video request) — can fire within 24h of any close
  - Ship type: artifact-prod (template)
  - Notes: %% Hard-gated on first deal close. Surfaces here so it doesn't get lost in the moment. %%

- [WB-009] Resolve email hosting (cwdeckbuilders.com MX records)
  - Created: 2026-05-04
  - Source: 2026-05-04 session note
  - Suggested owner: analytics agent (research) + Jim (decision)
  - Acceptance: Send-As alias for `info@cwdeckbuilders.com` works; Jim can reply professionally to homeowners
  - Ship type: artifact-prod
  - Notes: %% Three paths: (a) skip alias, use slogarjw@gmail.com with reply-to, (b) Google Workspace $6/mo, (c) GoDaddy M365. Pick one. %%
