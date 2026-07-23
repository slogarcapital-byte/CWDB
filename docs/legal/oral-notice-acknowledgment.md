---
type: reference
status: draft
created: 2026-07-22
tags:
  - type/reference
  - dept/legal
  - cancellation-rights
---

> **ATTORNEY REVIEW BANNER — DRAFT FOR LAUREN YDE, YDE LAW.** AI-drafted. Confirm the exact wording before it is added to the signing document.

# Oral Notice of Cancellation Rights: Acknowledgment Sentence

## The sentence to add

Add this one-line acknowledgment to the combined estimate and work order document, inside the acceptance block, immediately below or beside the conspicuous "Your Right to Cancel" statement:

> **I acknowledge that, before I signed, a representative of Central Wisconsin Deck Builders, LLC orally informed me of my right to cancel this transaction at any time before midnight of the third business day after the date of this transaction.**

**Fuller variant** (use if counsel prefers a single acknowledgment that also covers the written copies):

> **I acknowledge that, before I signed, a representative of Central Wisconsin Deck Builders, LLC orally informed me of my three-business-day right to cancel this transaction, and that I have received two completed copies of the Notice of Cancellation and a completed copy of this Agreement.**

Use the short version if the acceptance block already recites that the buyer received the two Notice of Cancellation copies and a completed copy of the Agreement (it currently does, per the combined document spec). The short version then adds only the missing piece: proof of ORAL disclosure.

## Where it goes

- **Document:** the combined estimate and work order (`combined: true`, cwdb self-perform lane only), rendered by `sales/estimates/generate_estimate_pdf.py`. See `docs/legal/templates/combined-estimate-work-order-spec.md` Section 5 (Acceptance block) and Section 3 (Required consumer notices).
- **Exact spot:** in the acceptance block, directly after the conspicuous "Your Right to Cancel" bold statement and before the homeowner signature line. It is part of what the homeowner's signature affirms.
- **Signing flow:** give it its own **buyer initial tab** in the DocuSign/QBO Contracts flow (alongside the existing initial tabs on the Right to Cancel block and the Notice to Owner). An initial next to the oral-notice acknowledgment is the cleanest evidence that oral disclosure occurred.
- **Do NOT add it to the builder lane.** The builder-lane path stays estimate-only, and the independent builder (not CWDB) gives the homeowner the cancellation notices and any oral disclosure on the builder's own contract.
- **Operational reminder for Jim:** the acknowledgment is only truthful if the oral disclosure actually happens. At the walk-through or signing, Jim (or whoever presents the document) must actually say, out loud, that the homeowner can cancel until midnight of the third business day. The document records that it happened; it does not replace doing it.

## Why this is needed

The FTC Cooling-Off Rule requires the seller, in a door-to-door or off-premises consumer sale, to do three things at the time of sale: furnish the buyer a completed copy of the contract, furnish two copies of a Notice of Cancellation, and **orally inform the buyer of the right to cancel.** See 16 CFR 429.1(a) and (e). The written notices are already in the combined document. The oral-disclosure requirement is separate, and the only practical way to evidence it after the fact is a signed acknowledgment that it occurred.

The parallel Wisconsin right lives in the Wisconsin Consumer Act, Wis. Stat. 423.201 to 423.203, which gives the customer a three-business-day right to cancel and requires the notice of that right. Home improvement sales at the residence fall within these rules.

CWDB's self-perform staining and refinishing jobs are sold at the homeowner's residence after an on-site walk-through, so they are the kind of off-premises consumer sale these rules target. Adding the oral-notice acknowledgment closes the last open gap in the cancellation-rights compliance stack:

1. Two Notice of Cancellation copies (16 CFR 429.1(b), Wis. Stat. 423.203) — already in the document.
2. Conspicuous near-signature "Your Right to Cancel" statement (16 CFR 429.1(a)) — already in the document.
3. **Oral disclosure of the right to cancel (16 CFR 429.1(a)) — this acknowledgment.**
4. Notice to Owner (Wis. Stat. 779.02(2)) — already in the document.

Do not cite ATCP 110.025 for the cancellation right; that section governs lien waivers. The cancellation right comes from Wis. Stat. 423.201 to 423.203 and 16 CFR Part 429.

## Retention

Keep the signed document (which now carries the oral-notice acknowledgment and initial) and the signing-platform completion certificate for at least six years (Wis. Stat. 893.43), filed by CWDB Job Number, consistent with the rest of the cancellation-rights record.

---

> **DISCLAIMER:** This document was prepared by AI legal counsel for informational purposes. Review by a licensed Wisconsin attorney (Lauren Yde, Yde Law) is recommended before the sentence is added to the signing document.
