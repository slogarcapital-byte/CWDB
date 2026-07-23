# Customer Deposit Timing Policy
**Owner:** Accounting agent (CPA function)
**Effective:** 2026-07-22
**Applies to:** all homeowner deposits on cwdb-lane self-perform jobs (staining, resurfacing, and, once licensed, builds). Builder-lane jobs take no CWDB deposit by standing rule.

---

## 1. How a deposit is recorded in QBO (current mechanics are correct, keep them)

The company already runs the right pattern, verified against the live ledger today:

1. **Deposit invoice at signing:** invoice the homeowner for the deposit using the **"Customer Deposit" service item**, which posts to **Customer Deposits (Other Current Liability, QBO account 1150040000, detail type Deferred Revenue)**, not to income. Example: INV-2026-043 (Overbeck, $840), INV-2026-047 (Koy, $2,325), INV-2026-048 (Peksa, $900).
2. **Payment received:** QuickBooks Payments deposits the cash to CWDB Chk; the liability stands on the books. The homeowner's money is a debt owed back until the work is done.
3. **Final invoice at completion:** bill the **full contract price to the Services income item** and add a **negative Customer Deposit line** for the deposit already paid. Example: INV-2026-045 (Overbeck): +$2,800 Services, -$840 Customer Deposit, balance due $1,960. This relieves the liability and books the full job revenue at completion in one document the homeowner can read.

Do not record deposits as straight income at receipt and do not use the generic "Customer prepayments" account; the Customer Deposit item flow above is the house standard.

## 2. Liability vs income: the three timelines

| View | Deposit treatment |
|---|---|
| **Books / GAAP (management view)** | Contract liability (deferred revenue) until the performance obligation is satisfied, then revenue. This matches ASC 606 revenue recognition and is exactly what the QBO mechanics in section 1 produce on the accrual ledger. |
| **Tax (cash basis, what hits Schedule C)** | **Income when received, full stop.** Under the cash method, income is recognized when actually or constructively received, and advance payments are included in the year received, not deferred to when the work happens. VERIFIED 2026-07-22, IRS Publication 334 (irs.gov/publications/p334). |
| **Operational (spendability)** | Deposit cash is held unspent until the 3-business-day cancellation window closes (section 3). It is legally refundable money until then. |

**The year-end trap this policy exists to catch:** a deposit received in December for January work is **taxable in December's year** even though QBO shows it as a liability. At return prep, Schedule C gross receipts = QBO cash-basis income **plus any Customer Deposits balance received during the year that is still unearned at 12/31**. I will run this reconciliation every January before the return. (QBO's cash-basis P&L largely handles this automatically because paid deposit invoices convert to income on the cash report, but the reconciliation is checked, not assumed.)

## 3. Consumer-protection constraints (per legal-compliance-counsel standing findings)

These are counsel's calls, restated here because they gate accounting timing:

- **Signed contract before or at deposit.** No deposit is invoiced or accepted without the signed work order / Home Improvement Contract (ATCP 110.05 requirement per counsel memo 2026-06-10; the two-tier contract system encodes it).
- **Notice of Cancellation stays embedded.** Two copies in every contract (16 CFR 429 and Wis. Stat. 423.203 per counsel). The 3-business-day right to cancel runs from the actual e-sign date; compute it from the signature certificate, never from the draft date.
- **Hold period:** deposit funds are treated as unspendable until midnight of the third business day after signing (Overbeck precedent, 2026-06-12). If the homeowner cancels in the window, refund promptly and in full (FTC cooling-off rule requires refund within 10 business days; exact WI timing NEEDS VERIFICATION, defer to counsel).
- **Pre-license gate:** CWDB takes no deposit on build/structural work until the DSPS Dwelling Contractor certification and GL insurance are both confirmed in hand. Cosmetic no-permit work (staining, resurfacing) is not gated.

## 4. Deposit sizing

- **House standard: 30% of contract price at signing**, rounding to whole dollars. Precedent: Overbeck $840 of $2,800 (30.0%), Koy $2,325 of $7,751 (30.0%), and the staged $7,751 contract follows the same term.
- Counsel has identified no Wisconsin statutory cap on home-improvement deposit size for our contract type; 30% is the business term, chosen to cover materials without holding excessive refundable cash. Any change to the percentage is an owner decision and a contract-template change, not an accounting call.
- Remaining balance: due on the final invoice after completion and walkthrough, payment card/digital first, then check, no cash (owner decision 2026-06-10).

## 5. Worked example (upcoming: staged contract $7,751)

1. Contract e-signed, day 0. Deposit invoice $2,325 (Customer Deposit item) sent same day.
2. Homeowner pays day 1. Books: cash +$2,325, Customer Deposits liability +$2,325. Tax: $2,325 is 2026 gross receipts as of day 1. Reserve action: move 35% ($814) to the tax reserve per the standing reserve policy.
3. Days 1 to 3: funds held, not spent. If cancelled: refund $2,325, reverse the liability, no income.
4. Job completes: final invoice $7,751 Services minus $2,325 deposit credit, balance $5,426. Liability zeroes, full revenue on the books.

## 6. Reserve hook

Every deposit receipt triggers the 35% tax reserve transfer on receipt (not at completion), because tax recognizes the deposit at receipt (section 2). This is the one place the liability treatment on the books must NOT drive cash behavior.
