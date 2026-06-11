---
type: spec
status: active
created: 2026-06-10
updated: 2026-06-10
tags:
  - type/spec
  - dept/legal
---

# Combined Estimate + Work Order — Single-Document Spec (CWDB self-perform lane)

**Scope.** ONE PDF, presented as an estimate, that becomes the binding interim staining
work order the moment the homeowner signs the acceptance block. Applies ONLY to the
`fulfillment.lane == "cwdb"` stain/resurface/refinish lane (no permit, no structural work).
Implemented as new sections appended in `generate_estimate_pdf.py` when a `combined=true`
flag is set. Source content lives in `staining-work-order-interim.md`; this spec maps that
content into the existing estimate section order. Do not modify the generator from this spec
alone; this is the implementer's brief.

**Why this is now compliant.** The prior "becomes a binding work order" line was ATCP 110
exposure because the estimate lacked the required contract content. The cure is to put ALL
ATCP 110.05(2) required content into the same signed PDF, so signature-as-contract is lawful.

---

## 1. Existing estimate sections that stay AS-IS (same order, same code)

Keep, unchanged, in this order: Header (logo + NAP), Estimate meta bar, Client block,
Project Overview, Scope of Work (+ scope_note), Itemized Pricing (TOTAL FIXED PRICE),
What's Included, What's Not Included, Schedule, Payment Terms (deposit/balance table).
These already satisfy: work-and-materials description, total price, payment schedule.

## 2. Content ADDED from the interim work order (required for ATCP 110.05(2))

Append these AFTER Payment Terms and BEFORE the Acceptance block. Pull verbatim wording
from `staining-work-order-interim.md` sections cited:

- **Start / completion dates** (work-order Sec. 5): start "on or about {schedule.start},
  after the three-business-day cancellation period expires, weather permitting"; completion
  "within approximately {schedule.duration} of start, subject to weather and finish cure."
  Schedule section already prints dates; ADD the "after cancellation period expires" clause.
- **Materials description standard** (Sec. 1): "CWDB supplies all premium finish product plus
  application supplies; finish product and color are as stated in the Itemized Pricing above."
- **Change-order clause** (Sec. 8): written, both-signature changes only; no verbal changes
  bind either party.
- **Scope firewall / structural stop-work** (Sec. 1, surface-finish-only para): cosmetic
  surface finishing of a structurally sound deck only; on discovering rot or structural
  defect, CWDB stops affected work, notifies Owner, and any repair needs a separate signed
  agreement. Print as a bold callout (reuse the scope_note styling).
- **Warranty** (Sec. 9): one-year workmanship warranty + the exclusions list.
- **Deposit hold / deposit-use restriction** (Sec. 4.1, 6): deposit held, not spent and no
  job-specific materials ordered, until the cancellation window closes; no security interest
  or lien taken on the Property as part of this agreement; fully refundable if cancelled in
  window. The Payment Terms table stays; ADD this hold language as a note beneath it.

## 3. Required consumer notices (verbatim / near-verbatim)

Append AFTER the added contract content, framed as the things the signature acknowledges.

- **3-business-day right to cancel — CONSPICUOUS (bold, type >= body).** Use work-order
  Sec. 7 wording verbatim, including the operative line "YOU, THE BUYER, MAY CANCEL THIS
  TRANSACTION AT ANY TIME PRIOR TO MIDNIGHT OF THE THIRD BUSINESS DAY AFTER THE DATE OF THIS
  TRANSACTION." Cite **Wis. Stat. 423.201 to 423.203** (Wisconsin Consumer Act) AND the FTC
  Cooling-Off Rule **16 CFR Part 429**. Do NOT cite ATCP 110.025 for the cancel right
  (110.025 is lien waivers). State that CWDB has given the buyer **two (2) completed copies
  of the Notice of Cancellation** and informed them of the right; refund within 10 days.
  Deadline = midnight of the third business day, counting Saturdays but not Sundays or federal
  holidays (16 CFR 429); the generator computes {cancellation_deadline}.
- **Two cancellation-notice copies.** Append the **Notice of Cancellation** form TWICE inside
  the same PDF (two complete, separately-signable copies), exactly as in the work-order
  ATTACHMENT block. In a PDF/DocuSign flow the "two copies" requirement is satisfied by
  delivering the fully executed PDF (which contains both notice copies) to the buyer by email
  and letting them retain/print it; record delivery (DocuSign completion certificate + the
  emailed signed PDF) as proof.
- **Notice to Owner — CONSPICUOUS (Wis. Stat. 779.02(2)).** Print the lien Notice to Owner
  verbatim from work-order Sec. 11 (the full "PLEASE READ THIS NOTICE..." paragraph), not the
  shorter estimate-style lien blurb. This replaces the existing one-paragraph 779.02 lien
  notice at the end of the estimate when `combined=true`.

## 4. Payment methods (no cash, no tax)

Render accepted methods in this priority order: **card / digital payment via QBO first, then
check. NO cash.** Set the JSON `payment.methods` string to "credit or debit card or digital
payment (preferred), or check. Cash not accepted." NO sales-tax line, field, or language
appears anywhere in the document (owner decision 2026-06-10: no Wisconsin sales tax on any
CWDB revenue). The total price is the fixed total with no tax line added.

## 5. Acceptance block — the conversion language

Replace the cwdb-lane acceptance text (currently "subject to execution of CWDB's signed Home
Improvement Contract (or Staining Work Order)") with, when `combined=true`:

> "By signing below, you accept this estimate and **this document becomes the binding Deck
> Staining Work Order and Home Improvement Agreement between you and Central Wisconsin Deck
> Builders, LLC.** No separate work order is required. You acknowledge you have received two
> completed copies of the Notice of Cancellation and the Notice to Owner above, and that your
> three-business-day right to cancel runs from the date you sign. This Agreement is governed
> by the laws of the State of Wisconsin; venue is Marathon County, Wisconsin."

The existing two-party signature block (Homeowner + CWDB by James Slogar, Owner) stays. Add a
line for a co-owner / all-titleholders signature when `client.co_owner_name` is present.

## 5b. DocuSign signing flow notes

- **Tabs needed:** Homeowner signature + date on the acceptance block; CWDB signature + date;
  co-owner signature + date if applicable; one **Buyer initial** tab on the CONSPICUOUS Right
  to Cancel block and one on the Notice to Owner (initials evidence the buyer saw both
  conspicuous notices). The two embedded Notice of Cancellation copies stay UNSIGNED in the
  delivered contract (they are the buyer's to sign only if they choose to cancel).
- **Cancellation-notice delivery:** emailing the completed, signed PDF (which embeds both
  Notice of Cancellation copies) to the buyer through DocuSign, with the DocuSign completion
  certificate retained, satisfies the "two copies + informed of right" delivery requirement.
  Keep the signed PDF + completion certificate 6 years (Wis. Stat. 893.43), filed by Job No.
- Set the document Effective Date = DocuSign completion date; the generator derives
  {cancellation_deadline} from it.

## 6. Builder lane stays estimate-only (do NOT combine)

The `fulfillment.lane == "builder"` path must remain estimate-only and must NOT receive the
combined treatment: the binding home-improvement contract is the independent builder's own
paper that the homeowner signs directly with that builder, so CWDB combining its estimate
into a contract would wrongly make CWDB the contracting party on a job it does not perform.

## 7. Implementer changes in `generate_estimate_pdf.py` terms

- Add a `combined` flag read from `estimate.get("combined", False)`; only honor it when
  `lane == "cwdb"` (ignore + warn if a builder-lane JSON sets it).
- When `combined and lane == "cwdb"`, after the Payment Terms `KeepTogether`, append in order:
  deposit-hold note (Sec. 2 above), Materials standard, Change Orders, Scope Firewall callout,
  Warranty, Right-to-Cancel CONSPICUOUS block, Notice to Owner CONSPICUOUS (779.02(2) full
  text), then the two Notice of Cancellation copies.
- Swap the acceptance text to the Section 5 conversion language (gate on `combined`).
- When `combined`, suppress the existing short lien blurb at the end (Sec. 3 replaces it with
  the full Notice to Owner) to avoid a duplicate, weaker lien notice.
- Add styles for CONSPICUOUS text (bold, >= body size) reusing `body_b`; reuse `note`/scope
  styling for the firewall callout. Keep the AI-counsel disclaimer footer behavior.
- New JSON fields consumed: `combined` (bool), `warranty` (text/list, optional override),
  `payment.methods` (already exists; set per Sec. 4). All other fields unchanged.

---

> **DISCLAIMER:** This spec was prepared by AI legal counsel for informational purposes.
> The rendered combined document must be reviewed by a licensed Wisconsin attorney before the
> first signature.
