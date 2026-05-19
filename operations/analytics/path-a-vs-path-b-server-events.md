# WS-1 Phase A — Path A (Cloudflare Worker) vs. Path B (Make scheduled read-only) — Decision Memo

> **DEPRECATED 2026-04-28.** Jim chose **Path C-prime** — HubSpot↔Webflow native integration — superseding both Path A and Path B. Canonical plan now lives at `operations/analytics/hubspot-webflow-native-plan.md`. Both paths analyzed below remain useful as decision audit trail (the rationale on each path's tradeoffs informs future architectural decisions). **Neither path will be implemented as designed.**
>
> Jim's verbatim decision: *"completely rework plan. i'm going to use the hubspot connection with webflow to update the crm."* — 2026-04-28.

---

# WS-1 Phase A — Path A (Cloudflare Worker) vs. Path B (Make scheduled read-only) — Decision Memo (DEPRECATED — kept as reference)

**Status:** Decision queued for Jim. CEO recommendation at the bottom.
**Author:** cwdb-ceo-operator (2026-04-28)
**Context:** Jim wrote on the prior state file: `%revisit plan to setup proper connections in make for scheduled read only runs for meta and google if more elegant.%` This memo answers that ask honestly.

---

## What we're choosing between

Both paths solve the same problem: get conversion events from CWDB's lead funnel into Google Ads (Enhanced Conversions / Offline Conversions Import), Meta Ads (CAPI), and GA4 (Measurement Protocol) with **server-augmented** signal — not just browser-fired pixel hits — so that Smart Bidding has cleaner attribution and our LTGP/CAC ratio improves.

The trigger event is the same in both paths: a Webflow form submission lands at `/get-a-quote` Step 3, fires the existing `from_submit_quotes` GA4 event, and the lead lands in Jim's inbox + (eventually) HubSpot.

The question is **how the data gets from there to the three ad platforms**.

---

## Path A — Cloudflare Worker serverless endpoint (current plan, in spec)

**Architecture:**
```
Webflow form submit
  → form JS POSTs to relay.cwdeckbuilders.com/lead-event
    → Cloudflare Worker
      → fan-out (parallel):
        ├── Meta CAPI (POST to graph.facebook.com)
        ├── GA4 Measurement Protocol (POST to www.google-analytics.com/mp)
        └── Google Ads Enhanced Conversions (browser-side via gtag — actually stays browser-side; Worker doesn't handle Google Ads)
```

**Spec lives at:** `operations/analytics/server-event-spec.md` (in flight per session 2026-04-27, owned by analytics agent).

**Pros:**
- **Real-time.** Event hits all three platforms within ~500ms of form submit.
- **Deterministic event_id.** Generated on form submit, used to dedup browser-fired pixel hit against CAPI server hit. Industry-standard CAPI dedup contract.
- **Hashed PII done at the edge.** Form fields → SHA-256 → POST. Never touches a third-party automation tool with raw PII.
- **No HubSpot dependency.** Works whether or not HubSpot pipeline is configured (relevant — HubSpot pipeline is still on the queue as unbuilt).
- **Cleanly extends to qualified-lead and accepted-bid signals later** — same Worker, just gated on lifecycle stage transitions when those flows exist.

**Cons:**
- **Custom code to maintain.** TypeScript Worker, deploy pipeline (wrangler), CI/secret management for FB_ACCESS_TOKEN + GA4 API_SECRET + (eventually) Google Ads OAuth tokens for Offline Conversions.
- **Jim cannot edit it himself in a UI.** When (not if) FB rotates an access token or GA4 deprecates an MP field, web-dev agent has to be dispatched.
- **Debugging requires reading Worker logs in Cloudflare dashboard** — not zero-effort but not bad either.
- **Bus-factor risk:** if the agent system is unavailable, Jim is stuck waiting for a maintenance window.

**Effort:** ~6-8 hours of web-dev work to ship A1 (form JS extension) + A2 (Worker with Meta CAPI) + A3 (Worker with GA4 MP). Google Ads Enhanced Conversions stays browser-side via existing gtag — no Worker work needed for that one.

**Ongoing cost:** Cloudflare Workers free tier covers up to 100K requests/day. CWDB will use ~10-50/day. **$0/month.**

---

## Path B — Make scheduled read-only runs

**Architecture:**
```
[Source of truth: HubSpot deal stage transitions OR Webflow form submission log]
  ↓ (every 15 min)
Make scenario polls source
  ↓ (for each new event since last run)
  ├── Meta CAPI module (Make has a native Meta Conversions API connector)
  ├── GA4 Measurement Protocol module (Make has a native GA4 connector)
  └── Google Ads Offline Conversions Import (Make has a native Google Ads Customer Match / Offline Conversions module)
```

**Pros:**
- **No custom code.** All visible inside Make's UI, which Jim already uses.
- **Jim can edit it himself.** When FB rotates a token or GA4 changes a field, Jim opens Make, fixes the module, done.
- **Native modules for all three platforms.** Make has built-in connectors for Meta CAPI, GA4 MP, and Google Ads Offline Conversions Import. No DIY HTTP calls.
- **Built-in error handling, retries, execution logs.** Better operational visibility than reading Cloudflare logs.
- **Reactivates an asset Jim is already paying-for-zero on** (Make scenario `4792854` is parked but the connection is live).

**Cons:**
- **Reactivates the parked Make scenario, which is a deliberate violation of the 2026-04-19 pivot's deferral rule.** That pivot's reactivation triggers were: ≥10 leads/week, 3rd contractor signs, first accepted bid, or Jim availability constraint. **None have fired.** Reactivating Make for analytics-feed work is technically a different use case than the original "lead routing" reactivation gate, but it's adjacent — needs an explicit decision to amend the pivot.
- **15-minute lag.** Smart Bidding is fine with this (Google's own Offline Conversions Import recommends ≤24h latency; 15 min is way inside that). Meta CAPI prefers <60 min for event-time matching; 15 min is fine. GA4 doesn't really care.
- **Requires HubSpot pipeline to exist OR Webflow form submission history to be queryable.** HubSpot pipeline is still on the queue as unbuilt. Webflow form submissions are visible in Webflow's dashboard via API but the Make → Webflow form-submissions module may or may not exist (would need to check — Webflow's CMS API is solid but form-submissions is a different surface). This is a real architectural dependency that needs verification before committing.
- **Make free tier limits:** 1,000 ops/month. At 15-min poll × 24h × 30d = 2,880 polls/month just for the scheduler trigger. Adding fan-out (3 platforms × N events) puts us over. **Would need to upgrade Make to paid tier ($10.59/mo minimum) — which the 2026-04-19 pivot specifically cancelled.**
- **No "real-time" path for Google Ads Enhanced Conversions** — that's a browser-side mechanism by design (gtag passes hashed user data on conversion fire). Path B can do Google Ads Offline Conversions Import (which is server-side and 24h-latency-tolerant), but **Enhanced Conversions specifically requires browser-side gtag**. So Path B is actually **Enhanced Conversions browser-side + Offline Conversions Import server-side via Make** — two different mechanisms for Google Ads, not one.
- **Doesn't solve the architectural goal as cleanly.** The point of Phase A was a single canonical event delivery layer. Path B fragments it across two Google Ads mechanisms (browser EC + server OCI) and a Make scheduler.

**Effort:** ~3-4 hours of CEO + Jim work to build the Make scenario, configure connectors, set up HubSpot triggers. Plus prerequisite work to either build HubSpot pipeline OR verify Make can read Webflow form submissions.

**Ongoing cost:** $10.59/mo Make paid tier (free tier doesn't cover the volume).

---

## Honest comparison

| Dimension | Path A (Worker) | Path B (Make) |
|---|---|---|
| Time to first signal | Real-time (~500ms) | 15-min batched |
| Custom code Jim can't touch | Yes (TS Worker) | No (Make UI) |
| Ongoing cost | $0 | $10.59/mo |
| Fits the 2026-04-19 pivot | Yes (no Make reactivation) | **No — reactivates Make + cancels free-tier decision** |
| Prereq work | Form JS extension only | HubSpot pipeline OR Webflow Form-submissions Make module verified |
| Single canonical event delivery layer | Yes | No (split EC + OCI for Google) |
| Operational visibility | Cloudflare Worker logs | Make execution logs (better) |
| Bus-factor when agent system down | Worse (Jim stuck) | Better (Jim can edit) |
| Scales to qualified-lead / accepted-bid signals later | Yes (same Worker) | Yes (same Make scenario) |
| Maintenance over 12 months | Higher (token rotation, code drift) | Lower (Make handles updates) |

---

## CEO recommendation: **Path A — Cloudflare Worker — for now, but with an honest caveat.**

**Reasoning:**

1. **Path B reactivates Make in violation of the 2026-04-19 pivot.** That pivot was an explicit decision: no Make spend until lead flow proves out. We are pre-revenue and pre-first-lead. Reactivating Make for analytics-feed work — even if it's a different use case than lead routing — is the kind of drift the pivot was designed to prevent. **This is the deciding factor.** If we want to override the pivot, that's fine, but it should be an explicit decision, not a side-effect of choosing Path B.

2. **Path A's "custom code Jim can't touch" downside is mitigated by the fact that the agent system IS the maintenance layer.** Jim hired the CEO to handle code-level maintenance. The bus-factor argument cuts both ways — if Jim is the only one who can edit the Make scenario, and Jim is the SPOF the whole system is trying to remove, then Path B's "Jim can edit it" advantage is actually a re-introduction of the SPOF Jim is trying to engineer away.

3. **Real-time matters more than I initially weighted it.** 15-min lag is fine for batch Smart Bidding optimization, but real-time CAPI matching (with deterministic `event_id`) gives **measurably better attribution match rates** at small volumes — and CWDB is at small volumes. At <50 events/day, the law-of-small-numbers means every 1% improvement in match rate is non-trivial signal.

4. **Path B's prereq dependency is real.** HubSpot pipeline is still on the queue as unbuilt. Webflow → Make form-submissions integration needs to be verified. Both add discovery work that Path A doesn't have. Path A's only prereq is the form JS extension, which web-dev can do in <2 hours.

5. **Path A's $0/mo vs Path B's $10.59/mo is small money but it's an explicit reversal of a recent decision** (the Make-paid-cancellation 2026-04-19). That same drift logic from #1 applies.

**Honest caveat to the recommendation:** Path A is the right call **today**, but if at 6-month checkpoint the WS-1 Phase A Worker has needed >2 hours of maintenance per quarter, or if Jim ever needs to be unblocked by code change he can't make himself, **revisit Path B**. The trade is "code I maintain forever" vs "tool I rent forever" and the right answer depends on how often the code changes and how often Jim needs to ship without an agent in the loop.

**One concession to Path B's logic:** The argument *for* visibility is strong. As Path A ships, instrument the Cloudflare Worker with structured logging (Logpush to a Cloudflare R2 bucket OR push to a Make data store as a one-way audit trail) so Jim has a non-code-readable view of what events fired. This gives Path A the operational-visibility benefit of Path B without the architectural drift.

---

## Decision needed from Jim

One of:

- **(A) Approve Path A as-is** — proceed with WS-1 Phase A spec already in flight from the analytics agent. Web-dev follows with A1+A2+A3. Default if no answer.
- **(B) Override the 2026-04-19 pivot and choose Path B** — explicit decision to reactivate Make, upgrade to paid tier, build HubSpot pipeline first. Path B work supplants Phase A spec.
- **(C) Hybrid** — Path A for Meta CAPI + GA4 MP (real-time matters most for Meta), Path B for Google Ads Offline Conversions Import (since that mechanism is batch-by-design). Splits complexity but gets best of both. CEO can scope this if Jim wants it.

**Drop the choice on the next state file's queue item; CEO executes.**
