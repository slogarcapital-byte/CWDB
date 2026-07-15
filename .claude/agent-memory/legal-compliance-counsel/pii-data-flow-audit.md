---
name: PII Data Flow Audit Findings
description: Analytics agent audit (2026-04-04) — data retention gaps, no deletion workflow, contractor data handling uncontrolled; feeds privacy policy and contractor agreement drafting
type: project
tags:
  - type/memory
  - agent/legal-compliance-counsel
created: 2026-04-04
updated: 2026-04-16
status: active
---

Analytics agent completed a PII data flow audit on 2026-04-04. Full report at `/finance/reports/performance/pii-data-flow-audit-2026-04-04.md`.

## Current Data Flow (as of 2026-04-04)

```
Webflow Form → Make → HubSpot CRM → Contractor (email + SMS)
   LIVE         NOT BUILT   NOT CONFIGURED    NOT ACTIVE
```

Only Webflow form is live. Data accumulates in Webflow dashboard only.

## Platform Retention Periods

| Platform | Retention | Auto-delete? |
|---|---|---|
| [[Webflow]] Forms | Indefinite | No — manual only |
| [[Make]] execution logs | 30 days (free plan) | Yes |
| [[HubSpot]] CRM (free tier) | Indefinite | No — requires Operations Hub (paid) |
| Contractor inbox | Unknown — contractor-controlled | No |

## Three Critical Gaps

1. **No TCPA consent language on form** — already flagged as go-live blocker (see tcpa-consent-status.md)
2. **Contractor data handling is uncontrolled** — once lead is delivered, CWDB has no visibility into what contractor does with homeowner PII. MUST include a data handling clause in Contractor Lead Purchase Agreement.
3. **No deletion workflow** — no process to honor subject access or deletion requests. Neither Webflow nor HubSpot free tier supports automated deletion.

**Why:** Wisconsin does not yet have a comprehensive data privacy statute, but FTC Act Section 5 (unfair/deceptive practices) and the privacy policy CWDB will publish create binding obligations. If the privacy policy promises deletion rights, CWDB must be able to fulfill them. The contractor data handling gap also creates potential vicarious liability if a contractor misuses homeowner PII.

**How to apply:**
- Privacy policy draft must accurately describe retention and not promise deletion capabilities that don't exist yet
- Contractor Lead Purchase Agreement MUST include: (a) permitted uses of lead data, (b) prohibition on resale/sharing, (c) data retention/deletion obligations, (d) notification requirements for data breaches, (e) indemnification for contractor misuse of PII
- Consider building a manual deletion checklist (Webflow dashboard + HubSpot) before promising deletion rights in privacy policy

## Addendum 2026-07-14: JobTread is now a processor

Flow adds a parallel branch: Webflow Form → `jobtread-gateway` Edge Function → JobTread (accounts/contacts/jobs; consent flags on customerContact) AND → HubSpot (unchanged) AND → Supabase bronze (`raw_intake_events`). JobTread retention: indefinite, manual deletion only (child-first: job → location → account). Add JobTread to: privacy policy third-party list, deletion checklist, DPA review queue. Signing surface migration is separately gated by `operations/jobtread/proposal-template-legal-block.md` (signed off 2026-07-14, three confirm-on-build gates).
