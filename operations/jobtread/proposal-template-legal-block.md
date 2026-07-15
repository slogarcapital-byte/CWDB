# JobTread Proposal Template: Legal Block

**Date:** 2026-07-14
**Purpose:** the text below must be embedded in the JobTread proposal template(s)
before any real customer signs in JobTread (design §4; gate on Task 10).
**Source of truth:** extracted verbatim from `sales/estimates/generate_estimate_pdf.py`
(the QBO Contracts combined estimate + work order flow, legal-approved).
**Status:** SIGNED OFF by legal-compliance-counsel 2026-07-14. Two confirm-on-build
gates remain before any real customer signs (R7 render conspicuousness + R4 E-SIGN
consent verification) plus the scope-firewall carry-forward; see Review section.

## Placement rules (revised 2026-07-14 per counsel R1-R5)

1. **Two complete copies** of the Notice of Cancellation appear in every
   cwdb-lane (self-perform) proposal, after the signature block. Never strip
   them (16 CFR 429 + Wis. Stat. 423.203 require duplicate copies).
2. **Explicit dates are MANDATORY before signing (R3).** Both the Date of
   Transaction line and the deadline line must carry an ENTERED calendar
   date; the parenthetical definition alone is NOT a completed notice. The
   deadline must be computed from the SAME date that populates
   `{date_signed}`: midnight of the third business day after it (Saturdays
   count as business days; Sundays and federal holidays do not; helper:
   `_cancellation_deadline()` in `generate_estimate_pdf.py`). If JobTread
   cannot do holiday-aware business-day math natively, use ONE of these
   self-consistent designs and no other:
   (a) fix the transaction date, pre-compute the explicit deadline with the
   helper, and require same-day e-sign; or
   (b) print a deadline that is never EARLIER than 3 business days after the
   actual signature date (later is always safe; earlier is never).
3. **Near-signature cancellation statement (R1).** The "Your Right to
   Cancel" block below must sit in immediate proximity to the buyer's
   e-signature field, boldface, 10pt or larger. It is required IN ADDITION
   to the two Notice copies (16 CFR 429.1(a)).
4. **Notice to Owner (R2).** The Wis. Stat. 779.02(2) block below is
   mandatory in every cwdb-lane contract over $1,000 (all of them, in
   practice). Bold, verbatim.
5. **E-SIGN consent gate (R4).** Before presenting the contract for
   e-signature, the flow must: (i) capture the buyer's affirmative consent
   to receive these records electronically and sign electronically;
   (ii) provide the hardware/software statement and the right to request a
   paper copy or withdraw consent; (iii) deliver the fully executed document
   (with BOTH notice copies) as a downloadable, retainable file
   (15 USC 7001(c); Wis. Stat. 137.15(2)). If JobTread's standard e-sign
   flow does not present such consent language, add it to the template
   ahead of the signature block.
6. The **builder-lane variant** adds the "Who Performs Your Work" disclosure
   box near the top (before pricing) and is estimate-only. Affirmative
   exclusions (R5): the builder variant must NOT contain the Notice of
   Cancellation copies, the Your Right to Cancel block, the Notice to Owner,
   or any homeowner-to-CWDB deposit/payment authorization (those belong in
   the named builder's own contract). If JobTread forces an acceptance
   action on every proposal, scope it in-template as "acknowledgment of
   estimate only, not a contract with CWDB."
7. **Conspicuousness on render (R7, confirm-on-build).** Verify the JobTread
   renderer preserves bold + >=10pt for the NOTICE OF CANCELLATION caption,
   the YOU MAY CANCEL statement, and the near-signature statement, and that
   both copies survive into the final retained PDF.

## Your Right to Cancel (cwdb lane, immediately adjacent to the signature field; R1)

> **Your Right to Cancel**
>
> **YOU, THE BUYER, MAY CANCEL THIS TRANSACTION AT ANY TIME PRIOR TO
> MIDNIGHT OF THE THIRD BUSINESS DAY AFTER THE DATE OF THIS TRANSACTION.**
> This right is provided under the Wisconsin Consumer Act, Wis. Stat.
> 423.202 and 423.203, and the federal Cooling-Off Rule, 16 CFR Part 429.
>
> CWDB has given you two (2) completed copies of the Notice of Cancellation
> (attached to this document) and has informed you of your right to cancel.
> To cancel, sign and date one copy of the attached Notice of Cancellation
> and mail or deliver it, or send any other written notice of cancellation,
> to Central Wisconsin Deck Builders, LLC, 906 N 16th Ave, Wausau, WI 54401,
> not later than midnight of **{cancellation_deadline}**. If you cancel
> within the cancellation period, CWDB will return your deposit and any
> other payments in full within ten (10) days after receiving your
> cancellation notice.

## Notice to Owner (cwdb lane, mandatory over $1,000; Wis. Stat. 779.02(2); R2)

> **Notice to Owner (Wis. Stat. 779.02(2))**
>
> **"PLEASE READ THIS NOTICE. As a result of receiving labor or materials
> for the improvement of your property, those who provide labor or
> materials for the work may have a right under Wisconsin law to claim a
> construction lien against your property if they are not paid. Central
> Wisconsin Deck Builders, LLC, and any subcontractors and material
> suppliers, may have lien rights on your land and buildings if not paid.
> Those entitled to lien rights, in addition to Central Wisconsin Deck
> Builders, LLC, are those who contract directly with you or those who give
> you notice within 60 days after they first furnish labor or materials for
> the work. Accordingly, you may receive notices from those who furnish
> labor or materials for the work, and you should give a copy of each
> notice you receive to your mortgage lender, if any. Central Wisconsin
> Deck Builders, LLC, agrees to cooperate with you and your lender, if any,
> to see that all potential lien claimants are duly paid. IF YOU DO NOT
> UNDERSTAND THESE REQUIREMENTS OR THE STEPS TO PROTECT YOURSELF FROM
> CONSTRUCTION LIENS, PLEASE CONSULT YOUR ATTORNEY."** You acknowledge
> receiving this Notice to Owner as part of this Agreement.

## Notice of Cancellation (embed TWICE, verbatim; Copy 1 of 2 / Copy 2 of 2)

> **NOTICE OF CANCELLATION (Copy N of 2)**
>
> **Date of Transaction: {date_signed}**
>
> **YOU MAY CANCEL THIS TRANSACTION, WITHOUT ANY PENALTY OR OBLIGATION,
> WITHIN THREE BUSINESS DAYS FROM THE ABOVE DATE.**
>
> If you cancel, any payments made by you under this Agreement, and any
> negotiable instrument executed by you, will be returned within TEN (10)
> DAYS following CWDB's receipt of your cancellation notice, and any
> security interest arising out of the transaction will be cancelled.
>
> If CWDB has delivered any goods or materials to you under this Agreement,
> you must make them available to CWDB at your residence in substantially as
> good condition as when received; or you may comply with CWDB's
> instructions regarding return at CWDB's expense and risk. If CWDB does not
> pick them up within twenty (20) days of the date of your Notice of
> Cancellation, you may keep or dispose of them without further obligation.
>
> TO CANCEL THIS TRANSACTION, mail or deliver a signed and dated copy of
> this Notice of Cancellation, or any other written notice, to **Central
> Wisconsin Deck Builders, LLC, 906 N 16th Ave, Wausau, WI 54401**, NOT
> LATER THAN MIDNIGHT OF **{cancellation_deadline}** (the third business day
> after the date of the transaction, not counting Sundays and federal
> holidays).
>
> I HEREBY CANCEL THIS TRANSACTION.
>
> Buyer Signature: ____________________
> Printed Name: ____________________
> Date of this Cancellation: ____________________

## Builder-lane disclosure (builder variant only, near top)

> **Who Performs Your Work**
>
> Central Wisconsin Deck Builders, LLC sources your project and prepares
> this estimate. The construction described here will be performed and
> contracted by **{builder_name}**, an independent licensed Wisconsin
> dwelling contractor. You will sign your construction contract directly
> with that builder. Central Wisconsin Deck Builders, LLC is not the builder
> and does not perform deck construction.

## Review (legal-compliance-counsel)

- [x] Notice text matches the approved combined estimate + work order verbatim
      (checked word-for-word against `generate_estimate_pdf.py` `_notice_of_cancellation()`,
      lines 169-206; the two-copy Notice body is identical. Verbatim text left UNTOUCHED.)
- [x] Two-copy requirement satisfied in the JobTread template layout
      (the Copy 1 of 2 / Copy 2 of 2 structure satisfies 16 CFR 429.1(b); CAVEAT R7 below:
      JobTread rendering must preserve boldface + >=10pt and land BOTH copies in the
      retained/downloadable executed document.)
- [x] Date-of-transaction merge behavior acceptable under ATCP 110 / 16 CFR 429
      (RESOLVED on re-review 2026-07-14: placement rule 2 mandates explicit entered dates in BOTH
      lines and derives the deadline from the same date as `{date_signed}`, with the two
      self-consistent designs; ambiguous fallback removed. `{date_signed}` preferred over source
      `{date_issued}`.)
- [x] Builder-lane variant carries the disclosure and takes no prime signature
      (disclosure text is verbatim-correct; estimate-only posture preserves WB-018 Phase 0; R5
      hardening now IN-DOC at placement rule 6 - excludes all consumer-contract blocks + CWDB deposit.)
- [x] Sign-off recorded here with date
      (SIGN-OFF recorded 2026-07-14; verdict below. Two confirm-on-build gates + scope-firewall
      carry-forward remain for Jim's template build.)

### Verdict: APPROVED / SIGN-OFF — legal-compliance-counsel, 2026-07-14

Re-review 2026-07-14: all four blocking items (R1-R4) are resolved in this doc and verified
against the approved source `generate_estimate_pdf.py`. R5 hardening is now in-doc. The document
is a complete and faithful port of the approved cwdb-lane legal blocks.

- **R1 RESOLVED** — "Your Right to Cancel" near-signature block added VERBATIM (source lines
  733-753); placement rule 3 requires immediate proximity to the e-signature field, bold, >=10pt.
- **R2 RESOLVED** — Notice to Owner (Wis. Stat. 779.02(2)) added VERBATIM (source lines 754-778);
  placement rule 4 makes it mandatory on every cwdb-lane contract over $1,000.
- **R3 RESOLVED** — placement rule 2 mandates explicit entered dates in BOTH lines, derives the
  deadline from the SAME date as `{date_signed}`, and specifies exactly the two self-consistent
  designs; the ambiguous fallback is gone.
- **R4 RESOLVED (spec)** — placement rule 5 adds the E-SIGN consent gate (affirmative consent +
  hardware/software statement + paper-copy/withdraw right + retainable executed document), citing
  15 USC 7001(c) and Wis. Stat. 137.15(2). Runtime verification stays a confirm-on-build gate.
- **R5 RESOLVED** — placement rule 6 affirmatively excludes the cancellation copies, Your Right to
  Cancel, Notice to Owner, and any homeowner-to-CWDB deposit from the builder variant, and scopes
  any forced acceptance as "acknowledgment of estimate only, not a contract with CWDB." WB-018
  Phase 0 posture preserved.
- **R6** — the `{date_signed}` / `{cancellation_deadline}` rename is used consistently throughout;
  acceptable, and `{date_signed}` is the better name.

The verbatim Notice of Cancellation text and the builder disclosure are unchanged and match source.

**SIGNED OFF for the JobTread proposal-template build. THREE gates remain and must be satisfied by
Jim before any real customer signs in JobTread — they can only be verified against the built
template, not this spec:**

1. **R7 — conspicuousness on render:** the built template must render the NOTICE OF CANCELLATION
   caption, the YOU MAY CANCEL statement, and the near-signature statement in bold at >=10pt, and
   BOTH notice copies must survive into the final retained PDF.
2. **R4 — E-SIGN consent at runtime:** confirm JobTread's e-sign flow actually presents the
   affirmative consent + hardware/software statement + paper-copy right AHEAD of the signature, and
   that the executed document is downloadable/retainable. If the stock flow omits any of it, add it
   to the template before the first real send.
3. **Scope-firewall carry-forward (pre-license posture):** the cwdb-lane template BODY must also
   carry the "Surface-Finish Only: No Structural Work" clause (source lines 703-715). It is not one
   of the four notice blocks reviewed here, but it is compliance-critical: without it a cwdb-lane
   staining contract could be read to cover structural work CWDB is not yet DSPS-licensed to perform.
   Do not ship a cwdb-lane template without it.

--- First-round review (2026-07-14, SUPERSEDED by the sign-off above — retained for audit) ---

**R1 (BLOCKING) — Missing 16 CFR 429.1(a) near-signature cancellation statement.**
The FTC Cooling-Off Rule requires BOTH (a) a conspicuous cancellation statement in immediate
proximity to the buyer's signature, in boldface >=10pt, AND (b) the two completed Notice of
Cancellation copies. This doc captured only (b). The approved flow's (a) statement lives at
`generate_estimate_pdf.py` lines 733-753 ("Your Right to Cancel" — "YOU, THE BUYER, MAY CANCEL
THIS TRANSACTION AT ANY TIME PRIOR TO MIDNIGHT OF THE THIRD BUSINESS DAY AFTER THE DATE OF THIS
TRANSACTION," citing Wis. Stat. 423.202 and 423.203 and 16 CFR Part 429). Add it, verbatim, to
the cwdb-lane template spec, positioned immediately adjacent to the JobTread e-signature field,
bold, >=10pt. Omitting it is a straight 429.1(a) / ATCP 110 defect.

**R2 (BLOCKING) — Missing Wis. Stat. 779.02(2) Notice to Owner (construction-lien notice).**
Wisconsin lien law requires the prime contractor on a home-improvement contract over $1,000 to
furnish the owner this specific written Notice to Owner. Cwdb-lane staining jobs exceed $1,000
(Overbeck was $2,800), so it is mandatory. The approved flow includes it verbatim at
`generate_estimate_pdf.py` lines 754-778. Omitting it from the JobTread template both violates
779.02(2) and can impair CWDB's OWN lien rights. Add the full bold Notice to Owner block to the
cwdb-lane template spec.

**R3 (BLOCKING) — Date-of-transaction / deadline consistency; explicit date is mandatory.**
`{date_signed}` for Date of Transaction is conceptually CORRECT and an improvement over the
source's `{date_issued}` (transaction date = signature date is more precise). BUT: (i) an
explicit calendar date is MANDATORY in BOTH the Date-of-Transaction line and the deadline line
before signing — under 16 CFR 429.1(b) and Wis. Stat. 423.203 a "completed" notice requires the
seller to ENTER the dates; the parenthetical alone is not a completed notice. Never send with the
deadline showing only "(the third business day after...)". (ii) `{cancellation_deadline}` MUST be
computed as the 3rd business day (Saturdays count; Sundays + federal holidays excluded) after the
SAME date that populates `{date_signed}`. If JobTread merges a dynamic signature date into Date of
Transaction but the deadline is pre-computed from a different/earlier date, the printed deadline
can UNDERSTATE the window — a violation (giving LESS than 3 business days). If JobTread cannot do
holiday-aware business-day math natively, pick ONE self-consistent design: (a) fix the transaction
date, pre-compute the explicit deadline with CWDB's `_cancellation_deadline()` helper, and require
same-day e-sign; or (b) print a deadline that is never earlier than 3 business days after ACTUAL
signature (later is always safe; earlier is never). Rewrite the doc's ambiguous item-2 fallback to
state exactly this.

**R4 (BLOCKING) — E-SIGN / Wisconsin UETA consumer consent for e-delivery.**
The Notice of Cancellation is a record required BY LAW to be furnished to the buyer, so delivering
it electronically triggers 15 USC 7001(c). Before presenting the contract + notice for e-signature,
the JobTread flow must (i) capture the buyer's affirmative consent to transact and receive these
records electronically and to sign electronically, (ii) provide the hardware/software statement and
the buyer's right to request a paper copy / withdraw consent, and (iii) ensure the fully executed
document (with BOTH notice copies) is downloadable and retainable by the buyer. Wis. UETA (Wis.
Stat. 137.15(2)) also requires each party to have agreed to conduct the transaction electronically.
Add an E-SIGN consent gate to the flow spec; without it, e-delivery of the statutory cancellation
notice is exposed.

**R5 (confirm-on-build) — Builder-lane hardening (WB-018 Phase 0).**
Estimate-only posture is correct. Make two guardrails explicit in the doc: (a) the builder-lane
JobTread template must NOT enable an e-sign acceptance that would form a construction contract with
CWDB — if JobTread forces an acceptance action, scope it in-template as "acknowledgment of estimate
only, not a contract with CWDB"; and (b) the builder-lane variant must NOT contain the two CWDB
Notice of Cancellation copies (R1/R2 elements either) NOR any homeowner-to-CWDB deposit/payment
authorization — those belong in the named builder's own contract. Placement rule 1 already scopes
the copies to cwdb-lane; state the builder-variant exclusion affirmatively so no one adds them.

**R6 (note) — Merge-field rename is acceptable.**
Source uses `{date_issued}`/`{deadline}`; this doc uses `{date_signed}`/`{cancellation_deadline}`.
Not a verbatim-text defect (the notice body is identical) and `date_signed` is the better name.
Implementer must map them and preserve the Sunday+federal-holiday business-day computation (subject
to R3).

**R7 (confirm-on-build) — Conspicuousness in JobTread render.**
16 CFR 429.1 requires the caption and key statements in >=10pt boldface. Verify the JobTread
proposal renderer preserves bold + >=10pt for the "NOTICE OF CANCELLATION" caption, the "YOU MAY
CANCEL..." statement, and the R1 near-signature statement, and that both copies survive to the
final PDF the buyer retains.

Re-review trigger: update this doc to resolve R1-R4, then route back for sign-off. The verbatim
Notice text and builder disclosure need no change; the fix is additive (put the two missing
statutory blocks + the E-SIGN gate + the date safeguard into the template spec).
