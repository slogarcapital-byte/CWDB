# QBO Customer Hub Evaluation: Estimates, Contracts, E-Sign vs Our Document Stack

**Date:** 2026-06-11 · **Author:** accounting agent · **For:** Jim
**Question:** Can QBO's native Customer Hub (Estimates, Proposals, Contracts, e-sign) replace parts of our custom PDF generators + planned DocuSign flow?
**Short answer:** Partially. The compliance content generation stays ours. The e-signing and invoicing layers can move to QBO, but only after a Plus upgrade and legal sign-off.

---

## 1. What Customer Hub actually is, and tier gating

Customer Hub is Intuit's CRM layer rolled into QBO plans (modules: Overview, Customers & leads, Opportunities, Estimates, Proposals, Contracts, Appointments, Reviews). Feature access is tiered:

| Feature | Tier required | Status |
|---|---|---|
| Reviews (reputation mgmt), Appointments | Essentials and up | VERIFIED 2026-06-11 (quickbooks.intuit.com/customers/) |
| Contracts + e-signatures, Customer Agent (beta) | **Plus or Advanced only** | VERIFIED 2026-06-11 (same page) |
| Proposals with e-sign + deposit payment | Plus/Advanced (e-sign in beta) | VERIFIED 2026-06-11 (same page) |
| Estimates: customer online review/approve from email; convert to invoice | All paid tiers (core QBO) | VERIFIED 2026-06-11 (Intuit help L0kOXRjoP, L2dAsWOiq) |

**We are on Essentials** (realm 9341457249522270). So the two modules that matter most for this question, Contracts and Proposals e-sign, are NOT in our current plan. That is why Jim sees the modules: the Hub shell shows on Essentials, but Contracts/e-sign are Plus-gated.

## 2. Capability check against our combined estimate + work order requirements

Our spec (docs/legal/templates/combined-estimate-work-order-spec.md) requires one signed document carrying: full ATCP 110.05(2) contract content, a CONSPICUOUS (bold, >= body size) Right to Cancel block citing Wis. Stat. 423.201-203 + 16 CFR 429, the full Wis. Stat. 779.02(2) Notice to Owner verbatim, conversion acceptance language, and TWO embedded Notice of Cancellation copies.

- **QBO Estimates: CANNOT hold this.** Estimates are line-item transaction documents with message/footer text fields. No long-form verbatim statutory text, no conspicuous bold-block formatting control, no embedded NoC forms. The online "approve" click is an acceptance status change, not a signature applied to a document containing the notices. Candidate A fails compliance for the cwdb lane.
- **QBO Contract builder: CAN take our PDF.** Contract builder accepts an uploaded PDF (valid PDF, max 25 MB), lets you place signature, date, and text fields for both parties, supports initialing (per-page initialing confirmed; exact placement of initial fields on specific blocks NEEDS VERIFICATION in-product), sends for e-sign, supports reminders/expiration, and produces an **electronic signature certificate with full audit history**; signed contracts download with the audit trail. VERIFIED 2026-06-11 (Intuit help article L0LenCa69 "Get started with contract builder", via search; page JS-rendered, direct fetch timed out).
- So the formatting problem disappears: our generator renders the fully compliant combined PDF exactly as specced, and QBO only carries and signs it. Template limits never touch the compliance content.

## 3. Flow comparison (fewest customer touches wins)

| | Candidate A: all-QBO estimate | Candidate B: our PDF + QBO Contracts | Candidate C: our PDF + DocuSign (status quo plan) |
|---|---|---|---|
| Compliance content | FAILS (sec. 2) | Ours, intact | Ours, intact |
| E-sign vehicle | Estimate approve click (not a signature) | QBO contract builder | DocuSign |
| Audit trail | None adequate | Signature certificate + audit history | Completion certificate (already counsel-assessed) |
| Invoice creation | Native convert | Manual/API at signing (same as C) | Manual/API at signing |
| Customer touches | 2 (but non-compliant) | **2** (sign email, invoice/pay email) | 2, across two vendor experiences |
| Extra cost | none | Plus upgrade (sec. 5) | DocuSign subscription |
| Vendors in flow | 1 | **1 (QBO only)** | 2 |

Candidate B wins on touches-per-vendor and consolidation. Candidate A is rejected for the cwdb lane (builder-lane estimates stay estimate-only per spec sec. 6 and are unaffected).

## 4. Audit trail and the two-NoC-copies delivery proof

Contract builder's signature certificate (full signer audit history, downloadable signed contract with audit trail) is functionally the analog of the DocuSign completion certificate our spec sec. 5b relies on. Retention plan unchanged: download signed PDF + certificate, file by Job No., keep 6 years (Wis. Stat. 893.43).
**NOT yet established, needs legal-compliance-counsel sign-off before first QBO-signed contract:**
1. Whether QBO automatically delivers the fully executed PDF (with both embedded NoC copies) to the buyer by email, the way DocuSign does. The spec's delivery-proof logic was assessed against DocuSign specifically.
2. Whether initial fields can be placed exactly on the Right to Cancel and Notice to Owner blocks (spec 5b tabs), vs only page-level initialing.
3. Typed-name-converted signature adequacy under E-SIGN/UETA for a WI home-improvement consumer transaction.
4. Effective Date = signature-certificate completion date drives {cancellation_deadline}; counsel confirms that mapping.

## 5. Estimate-accept-to-invoice automation

Yes, natively, two ways: manual Convert to Invoice once status = Accepted, and an **auto-convert toggle that creates the invoice when a requested deposit is paid** (requires QBO Payments, which we enabled). VERIFIED 2026-06-11 (Intuit help L2dAsWOiq, L81Kln0bN, L9jVVT2GY via search). Caveats: this lives on the Estimate object only; contract signing does NOT auto-create an invoice, and the auto path fits homeowner deposits, not contractor lead fees. So our planned API invoice push survives; see sec. 7.

## 6. Cost

- Current: Essentials. Contracts/e-sign require **Plus**. Exact 2026 list prices NEEDS VERIFICATION (pricing page JS-rendered; Jim: check quickbooks.intuit.com/pricing). Ballpark delta historically ~$35-45/mo.
- No per-envelope e-sign fee appears on Intuit's official pages; contracts/e-sign present as subscription-included with Plus/Advanced. Volume limits NEEDS VERIFICATION in-product after upgrade.
- Offsets: (a) Plus upgrade was already planned at Option B launch for class tracking; pulling it forward also fixes our Essentials class-tracking gap (Lead Gen vs Construction separation) now. (b) DocuSign cost for homeowner docs goes away; note contractor onboarding templates still live in DocuSign, so it stays until/unless those migrate too.

## 7. Recommendation

**Adopt Candidate B, gated on two things: the Plus upgrade and legal sign-off on sec. 4 items.** Concretely:
1. **Keep ours:** `generate_estimate_pdf.py` with the `combined=true` path generates the entire compliant document (all ATCP 110.05(2) content, conspicuous blocks, verbatim 779.02(2) notice, two NoC copies). This never moves to QBO templates.
2. **Move to QBO:** e-signing (contract builder replaces DocuSign for homeowner combined docs), payment collection (QBO Payments link, already decided), audit-trail artifact (signature certificate replaces DocuSign completion certificate, pending counsel).
3. **Stay as planned:** invoice creation at signing via `push-qbo-invoice.ps1` (Phase 2 of the design doc). Optional later experiment: QBO Estimate + deposit-request auto-convert for the homeowner deposit invoice, but only as a payment-collection convenience, never as the contract.
4. **Until the gate clears:** Candidate C stands. Do not upgrade tiers or send any QBO-signed contract before counsel signs off.
5. **Sequence:** Jim verifies Plus pricing > upgrade decision > I sandbox-test contract builder with a dummy combined PDF > legal-compliance-counsel review (sec. 4 list) > first live use.

## 8. API impact (Part B unchanged)

Part B (developer app keys at developer.intuit.com) remains Jim's interactive step, unchanged. Customer Hub does NOT change our endpoint set: Contracts/Proposals are not exposed in the v3 Accounting API (no contract-signed webhook; NEEDS VERIFICATION if Intuit ships one), so the Customer + Item + Invoice + Payment set in operations/data-warehouse/design/hubspot-qbo-flow.md stands; no Estimates API needed. I added a dated note to that design doc reflecting this evaluation.

**Sources:** [Customer Hub](https://quickbooks.intuit.com/customers/) · [Contract builder help (L0LenCa69)](https://quickbooks.intuit.com/learn-support/en-us/help-article/personal-profile/get-started-contract-builder-quickbooks-online/L0LenCa69_US_en_US) · [Estimates (L0kOXRjoP)](https://quickbooks.intuit.com/learn-support/en-us/help-article/job-estimates/create-send-estimates-quickbooks-online/L0kOXRjoP_US_en_US) · [Convert estimate to invoice (L2dAsWOiq)](https://quickbooks.intuit.com/learn-support/en-us/help-article/invoicing/convert-estimate-invoice-quickbooks-online/L2dAsWOiq_US_en_US) · [Deposit on estimate (L81Kln0bN)](https://quickbooks.intuit.com/learn-support/en-us/help-article/bank-deposits/request-customer-deposit-estimate-quickbooks/L81Kln0bN_US_en_US) · [QBO pricing](https://quickbooks.intuit.com/pricing/)

> DISCLAIMER: Tax and compliance items flagged above require the noted verifications; nothing here is a final legal position. Counsel review required before first QBO-signed contract.
