---
name: Payment processor decision (2026-05-04)
description: CWDB chose QuickBooks Payments as primary card processor. Rationale, fees, alternatives, setup steps.
type: project
---

**Decision:** QuickBooks Payments is the primary card processor for CWDB, LLC. Venmo Business is the consumer-facing fallback for clients who refuse to enter a card number.

**Why:**
1. CWDB needs ONE processor that serves two flows: B2C deposits + balances on $4.9K homeowner jobs (Nayak), and B2B $1,000 invoices to contractors (Barton, Garcia). QBO Payments does both natively and the bookkeeping reconciles itself.
2. Jim is a CPA. QuickBooks Online is already in his stack mentally. Setup is hours, not days. No third-party reconciliation.
3. ACH on QBO Payments is 1% capped at $10. On a $4,900 job that is $10 vs $147 on Venmo Business at 3.0% or ~$148 on Stripe at 2.9% + $0.30. ACH for the deposit alone saves real money on every job and is the right default when Jim controls the invoice.
4. Venmo Business is locked to 3.0% with no ACH option for invoices, has weak invoicing UX vs QBO, and the QuickBooks integration is third-party only. Fine as a backup; wrong as primary.

**How to apply:** When Jim asks about payments, billing, invoicing, or merchant services, default to the QBO Payments path. Use Venmo Business only when (a) the client explicitly resists giving info to a QBO invoice, or (b) the amount is small (<$200) and friction matters more than fee.

**Fees on the Nayak $4,900 job:**
- ACH path (recommended): $10 deposit + $10 balance = **$20 total fees**
- Card path (if client insists): 2.99% × $4,900 = **~$146.51 total fees**
- Mixed (ACH deposit, card balance): ~$112.66

**Setup steps (live before 2026-05-12):**
1. Confirm/create QuickBooks Online subscription under EIN 41-5355234 (likely already exists if Jim's CPA practice uses QBO; create new company file for CWDB if not)
2. Apply for QuickBooks Payments inside QBO (Settings → Payments → Sign Up). Approval is usually same-day for an LLC with EIN + WI business address + bank account
3. Connect CWDB business checking to QBO Payments for deposits
4. Build invoice template: CWDB letterhead, "Pay now" button enabled, ACH + card both on
5. Send Nayak a $1,470 invoice (deposit) the moment she signs the estimate
6. Repeat for $3,430 balance after walkthrough

**Risks:**
- QBO Payments holds new merchants' first deposit 5–7 business days. Apply NOW, not after Nayak signs.
- 1099-K from QuickBooks comes to the LLC EIN; clean. (Venmo personal account would 1099-K to Jim's SSN, which is the wrong tax entity. Never use personal Venmo for CWDB revenue.)
- Chargebacks: card path exposes CWDB to disputes. Mitigation: ACH the deposit, get signed estimate + signed completion walkthrough before card balance, keep photos of finished work.
- If QBO Payments app rejects (rare for LLCs in good standing), Stripe is the fallback. Stripe approval is also same-day, fees 2.9% + $0.30 card / 0.8% capped $5 ACH. Slightly worse than QBO on B2B invoicing UX but no QBO required.

**Alternatives evaluated and rejected:**
- Venmo Business: 3.0% flat, no ACH, weak invoice UX, third-party QBO sync. Backup only.
- Stripe: comparable fees, more developer-flavored, no native QBO. Fallback if QBO rejects.
- Square: similar fees, retail/POS-flavored, weaker for emailed invoices.
- PayPal Business: 3.49% + $0.49 on cards. Worse fees, hated UX.

**Coordination:**
- Accounting agent owns QBO setup + invoice template + reconciliation
- Legal-compliance review NOT needed for QBO standard merchant terms (no negotiation surface)
- CEO operator owns the decision and the Nayak invoice timing
