# Books Cleanup: Findings, Journal Entries, Applied vs Parked
**Memo to:** Jim
**From:** Accounting agent (CPA function)
**Date:** 2026-07-22
**Dashboard task:** 24 (audit-2026-07-05#24)
**Data source:** Live QBO production pull 2026-07-22 (realm 9341457249522270): full Purchase, Invoice, Payment, Deposit, JournalEntry, Account list, plus cash-basis P&L. Warehouse cross-check: `fact_ad_spend_daily`.

---

## 1. What was APPLIED to QBO today (2 reclasses, both verified after posting)

Both are expense-to-expense reclasses, net income unchanged at $6,698.35. Full audit trail in `finance/invoices/_logs/qbo.log` (intuit_tid captured per call).

| # | Txn | Was | Now | Why it was safe |
|---|---|---|---|---|
| 1 | Purchase Id 25, 2026-06-11, $37.50, memo "Intuit *qbooks Online" | Advertising and marketing: Website ads | Office expenses: Software and apps | This is the QuickBooks Online Essentials subscription itself. Unambiguously not ad spend. |
| 2 | Purchase Id 32, 2026-06-02, $104.38, memo "Google AdsXXXXXX0870" | Advertising and marketing (parent account) | Advertising and marketing: Website ads | Every other Google Ads charge (10 of them) sits in the Website ads subaccount. Pure consistency fix within the same P&L section. |

Post-fix P&L check: Website ads $1,314.26, Software and apps $37.50, totals tie.

## 2. PARKED: verification list for Jim (nothing applied)

### 2.1 The $308.69 sponsorship (LOCATED, needs substantiation)

It is two transactions from the checking account (CWDB Chk), not one:

| QBO Id | Date | Amount | Bank memo |
|---|---|---:|---|
| Purchase 13 | 2026-06-22 | $200.00 | ATM withdrawal, Kwik Trip 3221, 1440 W Campus Dr, Wausau |
| Purchase 10 | 2026-06-24 | $108.69 | Debit card, Greenwood Hills Country Club, Wausau |

Both are coded to Advertising and marketing: Sponsorship. What I need from you before this survives a tax return:
1. **Receipt or invoice** from the sponsored organization for the $200 cash (an ATM withdrawal is not substantiation, only proof cash left the account). And the Greenwood Hills receipt for the $108.69.
2. **What it was:** event name, date, what CWDB received (hole sign, banner, program listing, team entry?).
3. **Why it matters, the tax character turns on the answer:**
   - Name/logo displayed or promotional benefit received: **advertising expense, fully deductible** on Schedule C. This is the good answer, keep the coding.
   - Donation with no return benefit: for a disregarded SMLLC that is a **personal charitable contribution** (Schedule A itemized), NOT a business expense; I would reclass to Owner Draws.
   - Green fees / playing in the outing: entertainment, **nondeductible** under IRC 274(a) (NEEDS VERIFICATION on the specific facts; the entertainment disallowance is settled law but application depends on what the $108.69 bought).

### 2.2 Purchase 22: $61.00 credit card payment booked as an expense (balance sheet is wrong)

2026-06-18, on the credit card, memo "Internet Payment Thank You", line category **CWDB Chk** (the checking account). That memo is the card statement's acknowledgment of a PAYMENT you made to the card. As booked, it increases both checking and the card liability by $61 each, which is backwards. No P&L impact, but both balance sheet accounts are off and the bank rec will not tie.

**Fix (you, in the UI, 2 minutes):** delete Purchase 22 (Expenses > filter date 6/18), then check Transactions > Bank transactions for the matching $61 outflow on the checking side. If the checking feed has it, categorize it as a credit card payment (QBO offers "Record as credit card payment" / pair as Transfer to Business Credit Card 1474). I did not touch it because I cannot see whether the checking-side twin was already categorized somewhere, and deleting blind risks doubling the error.

### 2.3 Sample Customer test invoice: $5.00 sitting in real income

Invoice 1001 (2026-06-09, "Sample Customer", item Hours) was paid through QuickBooks Payments ($5.00 deposit 6/14, $0.15 fee). It was your payments-enablement test, but it is booked as Services income. Immaterial, yet it is fake revenue with your own $5 behind it.

**Recommended fix:** leave the cash (it is real), reclass the income: void is messy once a payment and deposit are linked. Cleanest: JE, debit Services $5.00, credit Shareholders' equity: Contributions $5.00, memo "reclass payments-test invoice 1001". Say go and I will post it (parked only because it touches income and you may prefer to just leave $5 of income and move on; either is defensible at this size).

### 2.4 July credit card feed is uncategorized

Last card transaction in QBO is 2026-06-25. The warehouse shows **$673.18 of platform-accrued July ad spend** (Google $630.42, Meta $42.76 through 7/22), and the card's QBO balance ($1,651.69) implies charges are landing unbooked. Action: Transactions > Bank transactions, categorize the backlog. While you are in there, accept my standing recommendation to add **bank rules**: "Google Ads" and "Facebk" to Advertising and marketing: Website ads, "Intuit" to Software and apps. Rules are not exposed in the v3 API, so this is a UI task.

### 2.5 Credit card late fee, $41 (6/10)

Coded to Bank fees and service charges, which is fine and deductible. Flag is operational: put the business card on autopay so this is the last one.

### 2.6 Meals $33.89 (Krist Food Mart, 6/25)

Confirm the business purpose (crew food on the Overbeck staining job?). Deduction is limited to 50% ($16.95) on the return (VERIFIED 2026-07-22, IRS Pub 334: "Deductions for meal expenses generally remain limited to 50%"). Books keep the full $33.89 in the Meals account; the 50% haircut happens on Schedule C. Keep the receipt.

### 2.7 Open build-job deposit invoices vs licensing gate (flag, not accounting)

INV-2026-047 (Virginia Koy, $2,325, "16x8 ft. Deck", exactly 30% of a $7,751 contract; this appears to be the staged job the board tracks as Quinn, confirm) and INV-2026-048 (Jim Peksa, $900, deck stair repair) are open deposit invoices on **build/structural work**. Standing rule: CWDB does not sign as prime or take a build deposit pre-license (DSPS cert + GL). GL bound ~6/25 per the audit; **confirm the DSPS Dwelling Contractor cert is in hand before these deposits collect.** If the cert is still pending, these invoices should not be payable yet. Flagging per the fulfillment-model standing rule; legal-compliance-counsel owns the call.

## 3. Pre-4/28 backfill (draft JE list, amounts pending your statements)

QBO's ledger starts 2026-04-28 (first card feed transaction, Google Ads $10.00). The LLC formed 2026-04-06 and the project started 2026-03-12.

Good news, verified today: **there is no missing ad spend.** The warehouse shows $0.00 platform-accrued ad cost before 2026-04-28 (Google went live 4/23 but accrued nothing until after; first real charges hit the card 4/28+ and are all in QBO). The pre-4/28 gap is entirely the personally paid items.

Draft entries, all of form **debit expense / credit Shareholders' equity: Contributions (account 134)**, dated on the actual personal payment dates, posted once you supply amounts:

| # | Item | Est. date | Amount | Debit account |
|---|---|---|---:|---|
| JE-1 | WI Articles of Organization filing fee (WDFI) | ~2026-04-06 | $130.00 expected, confirm from receipt (standard WDFI online fee, NEEDS VERIFICATION against your actual charge) | Legal and accounting services |
| JE-2 | GoDaddy domain registration (cwdeckbuilders.com, brand confirmed 3/28) | ~2026-03-28 | TBD | Office expenses: Software and apps |
| JE-3 | Webflow subscription, March/April months paid personally | Mar-Apr | TBD | Office expenses: Software and apps |
| JE-4 | HubSpot Starter, months before business-card cutover | Mar-Apr | $15.00/mo | Office expenses: Software and apps |
| JE-5 | Anthropic API usage, March/April | Mar-Apr | TBD | Office expenses: Software and apps |
| JE-6 | Catch-all: any other business charges on personal cards 3/12 to 4/27 (statement sweep) | various | TBD | per item |

Notes:
- These continue past 4/28 for any subscription still on a personal card; same JE form, see the companion tax-reserve memo section 3.
- **Section 195 startup-cost tag:** items dated before the business actively commenced are startup expenditures (deductible up to $5,000 in year one, remainder amortized over 180 months; limits NEEDS VERIFICATION against current IRS guidance). Lead-gen operations arguably commenced ~3/12, before formation, which would make most of this ordinary expense rather than 195. Either way the totals are far under $5,000, so the deduction lands in 2026 regardless. I keep the tag for return prep.
- The 4/14 $25.00 owner contribution deposit ("TRANSFER JIM") is already booked correctly. Contributions account currently shows only that $25; the JEs above will build it up properly.

## 4. Subscription miscoding summary

Searched every Purchase line in the company (77 transactions). Findings: the two reclasses in section 1 (applied), and the absence of every stack subscription from the business ledger (the commingling issue, handled in the companion memo). No other miscoded subscriptions exist in QBO today.

## 5. Scorecard

| Category | Applied | Parked for Jim |
|---|---|---|
| Reclasses | 2 (QBO sub $37.50, Google parent-account $104.38) | Purchase 22 card-payment fix, $5 test-invoice reclass |
| Substantiation | | Sponsorship $308.69 (receipts + business purpose), Meals $33.89 (purpose + receipt) |
| Feed hygiene | | July card backlog + bank rules, autopay on the card |
| Backfill JEs | | JE-1 through JE-6 pending amounts from personal statements |
| Compliance flag | | DSPS cert confirmation before Koy/Peksa build deposits collect |
