# Legal Memorandum: Entity Structure, Liability, and Future Spinout

**To:** James "Jim" Slogar, Sole Member, Central Wisconsin Deck Builders, LLC
**From:** AI Legal Counsel (CWDB)
**Date:** 2026-06-08
**Re:** Running construction inside the existing lead-gen LLC: the liability tradeoff, the S-Corp interplay, and a future off-ramp

---

## Executive Summary (Plain English)

You have decided to run deck construction inside the existing Central Wisconsin Deck Builders, LLC rather than forming a second company. That is a reasonable starting choice for a solo owner-operator who wants to move fast and keep costs and paperwork low. It carries one significant cost you must manage on purpose: **everything is now in one bucket.**

When lead generation and construction share one LLC, a construction claim (someone falls off a deck you built, a ledger board pulls loose, a structure damages a home) can be asserted against all of the Company's assets, including the cash and goodwill your lead-gen line built. And if that claim is uninsured or underinsured, or if you have run the LLC sloppily, it can reach you personally. I rate the bundled-entity exposure **HIGH**.

The single-LLC choice is still defensible, but only if three substitutes for a separate entity are all real and maintained:

1. **Strong commercial insurance** (CGL now, workers' compensation when labor is added).
2. **An operating agreement that scopes both lines** and locks in the separation covenants (already drafted at `docs/legal/cwdb-operating-agreement.md`).
3. **Strictly separate bookkeeping** per line.

This memo explains that tradeoff, walks through the S-Corp election timing (window closes about 2026-06-20, and adding labor income changes the math, so this is a CPA decision), and gives you a concrete future off-ramp: when and how to spin construction into its own LLC later.

---

## Section-by-Section Walkthrough

| Section | What it covers | Risk rating |
|---|---|---|
| 1. The single-LLC choice | Why one entity, and what you give up | HIGH (bundled exposure) |
| 2. The three substitutes | Insurance, operating agreement, separate books | MEDIUM if all three are maintained |
| 3. S-Corp interplay | Election timing and how construction labor changes the analysis | MEDIUM (CPA decision, hard deadline) |
| 4. The future spinout off-ramp | Triggers and a checklist for forming a second LLC later | LOW now, rises with growth |
| 5. Action list | What to do, in order | n/a |

---

## 1. The Single-LLC Choice and Its Liability Tradeoff

**Rating: HIGH.**

A Wisconsin LLC normally gives its owner a liability shield. Under Wis. Stat. s. 183.0304, the debts and liabilities of the LLC are the LLC's alone, and the member is not personally liable just for being the member. That shield is the whole reason to use an LLC.

The problem with putting construction inside the same LLC as lead generation is not that the shield disappears. It is that the shield protects you (the person) from the Company, but it does nothing to wall off one Company business from another Company business. Inside the single LLC, there is no internal wall. So:

- A construction injury or property-damage claim can be collected against **all** Company assets, including the lead-gen revenue, the website, the brand, and any cash on hand. The plaintiff is not limited to "construction assets," because legally there is only one pool of assets.
- If the claim exceeds your insurance, or if you have no applicable coverage, the Company pays out of that single pool until it is exhausted.
- If you have run the LLC as an alter ego (commingled funds, ignored formalities, left it badly underinsured), a plaintiff can argue the court should disregard the LLC entirely and reach **you personally**. Wisconsin courts can pierce the veil where the LLC is operated as a mere instrumentality and respecting the separate entity would sanction a fraud or injustice. This is a fact-specific doctrine; the defense is to not give them the facts.

Construction is materially riskier than lead generation. Lead-gen liability is mostly contract and advertising risk. Construction adds bodily-injury and structural-failure risk, which is exactly the kind of large, sometimes catastrophic, sometimes uninsured liability that threatens personal assets. That is why bundling them is rated HIGH rather than MEDIUM.

## 2. The Three Substitutes That Must All Be Real

**Rating: MEDIUM, conditioned on all three being maintained.** If any one fails, the rating drifts back toward HIGH.

Because you are not buying a second entity's internal wall, you have to recreate equivalent protection three other ways. All three are required; they are not a menu.

**Substitute 1: Strong commercial insurance.**
Insurance is your first and most important line of defense, because it pays claims before they ever reach Company or personal assets. You need commercial general liability now and workers' compensation once you add labor (Wis. Stat. ch. 102 governs workers' compensation; verify your employee threshold with the Wisconsin Department of Workforce Development). Bind insurance BEFORE you start work, both because it is the real protection and because the Wisconsin Dwelling Contractor Certification requires proof of insurance to issue. See `docs/legal/construction-setup/insurance-spec-sheet.md`. Underinsurance is the single most common way a deck-builder's bad day becomes a personal-bankruptcy day. Rating of an underinsured construction operation on its own: **HIGH.**

**Substitute 2: An operating agreement that scopes both lines.**
The drafted operating agreement (`docs/legal/cwdb-operating-agreement.md`) expressly authorizes both the lead-gen line and the construction line, names you as sole member-manager, and writes in the no-commingling, insurance, and separate-books covenants. A clear operating agreement that documents adequate capitalization and formalities is part of how you defeat a future veil-piercing argument. Rating with a scoped agreement in place: **LOW** for the governance gap itself.

**Substitute 3: Strictly separate bookkeeping per line.**
Track lead-gen and construction as two distinct profit centers. This matters for three reasons: (a) it supports the entity-integrity story if anyone ever attacks the LLC, (b) it is needed to handle sales/use tax correctly on construction work (Wis. Stat. ch. 77; Wis. Admin. Code ch. Tax 11), and (c) it gives your CPA a clean basis for the S-Corp reasonable-salary analysis in Section 3. Commingled, undifferentiated books undercut all three. Rating if books are commingled: **MEDIUM to HIGH.**

## 3. S-Corp Election Interplay

**Rating: MEDIUM. This is a CPA decision with a hard deadline.**

Your LLC is, by default, a disregarded entity for federal tax: all profit flows to you and is subject to self-employment tax. An S-Corporation election can reduce self-employment/payroll tax by splitting your take into (a) a reasonable W-2 salary subject to payroll tax and (b) distributions that are not subject to self-employment tax.

Two timing and analysis points:

- **The election window closes about 2026-06-20** (roughly 75 days from the April 6, 2026 formation, the general window for an election effective for the first tax year). If you want the election to apply to the current year, the IRS Form 2553 generally must be filed inside that window. Verify the exact deadline and effective-date rules with your CPA, because relief for late elections exists but should not be relied on as a plan.

- **Adding construction labor income changes the reasonable-salary analysis.** The S-Corp benefit depends on paying yourself a defensible "reasonable compensation" for the work you actually perform. Lead-gen is largely a marketing/automation business; construction is hands-on labor. When you personally swing a hammer, the IRS expects a higher reasonable salary for that labor, which shrinks the distribution portion that escapes self-employment tax. In other words, the more of your income that comes from your own physical construction work rather than from the lead-gen system, the smaller the S-Corp savings tend to be, and the more important it is to get the salary number right. This interacts directly with the separate-books covenant in Section 2: clean per-line books let your CPA build a defensible salary.

**This memo does not tell you whether to elect.** That is a CPA call that depends on your projected profit mix, payroll costs, and the labor-versus-system split. The considerations above are inputs, not a directive. Decide with your CPA before about 2026-06-20. See `docs/legal/construction-setup/tax-treatment-memo.md`.

## 4. The Future Spinout Off-Ramp

**Rating: LOW now; rises as the construction line grows.**

Starting in one LLC does not lock you in. The intended path is to spin construction into its own LLC later, once the construction line is big enough or risky enough that the bundled exposure outweighs the simplicity of one entity. Build this in as a planned move, not a panic move.

**Concrete trigger points (any one should prompt a serious spinout conversation):**

- **Hiring W-2 employees** for construction (adds payroll, workers' comp exposure, and employment-law risk to the shared bucket).
- **Revenue or job-volume thresholds:** for example construction revenue becoming a large share of total Company revenue, or a steady book of multiple simultaneous jobs. Set a specific number with your CPA and attorney.
- **Taking on larger or more structural builds** (elevated multi-level decks, complex structural attachments, work where a failure could cause serious injury), which raises the size of a worst-case claim.
- **Any significant claim or near-miss:** an actual injury, a structural failure, a substantial property-damage event, or even a close call. A near-miss is a free warning to separate the entities before the next one.

**Short checklist of what a spinout would involve (verify each with a licensed Wisconsin attorney and CPA):**

1. Form a new Wisconsin LLC for construction (Articles of Organization with the Wisconsin Department of Financial Institutions under Wis. Stat. ch. 183), with its own operating agreement.
2. Obtain a new EIN and, if the lead-gen entity keeps the Dwelling Contractor Certification, move or re-apply for the credential under the new entity at WI DSPS (Wis. Stat. ch. 101; Wis. Admin. Code ch. SPS 305). Credentials generally do not automatically transfer between entities.
3. Bind insurance under the new entity (the prior policy will not cover a different legal entity by default).
4. Re-paper the subcontractor agreements and any homeowner-facing contracts under the new entity, and update the lead-purchase relationship so the lead-gen entity sells leads to the construction entity at arm's length.
5. Set up separate bank accounts and books for the new entity from day one.
6. Update licensing, registrations, the website, advertising, NAP listings, and tax registrations to reflect the correct entity.
7. Confirm sales/use tax registration for the construction entity with the Wisconsin Department of Revenue.

The point of doing this later, on a trigger, is that you get the speed and low cost of one entity now, and you separate the riskier business into its own shield exactly when the risk justifies the added cost and complexity.

## 5. Action List

1. Adopt the operating agreement at `docs/legal/cwdb-operating-agreement.md` (substitute #2).
2. Bind CGL insurance before any work; arrange workers' comp before adding labor (substitute #1); see the insurance spec sheet.
3. Set up separate per-line bookkeeping immediately (substitute #3).
4. Meet your CPA before about 2026-06-20 to decide the S-Corp election with the construction-labor analysis in hand.
5. Write your spinout trigger numbers down now (revenue share, employee count) so the off-ramp is objective, not emotional.

---

This document was prepared by AI legal counsel for informational purposes. Review by a licensed Wisconsin attorney is recommended before execution.
