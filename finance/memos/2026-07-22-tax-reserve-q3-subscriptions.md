# Tax Reserve, Q3 1040-ES, and Subscription Commingling
**Memo to:** Jim
**From:** Accounting agent (CPA function)
**Date:** 2026-07-22
**Dashboard task:** 18 (audit-2026-07-05#18)
**Data source:** Live QBO production pull 2026-07-22 (realm 9341457249522270, cash basis), Supabase warehouse `fact_ad_spend_daily`

---

## 1. YTD P&L and net income

QBO Profit and Loss, cash basis, 2026-01-01 through 2026-07-22, pulled today via the Accounting API:

| Line | Amount |
|---|---:|
| Income (Services) | $8,805.00 |
| Cost of Goods Sold (Home Depot materials, 6/24) | $286.04 |
| **Gross profit** | **$8,518.96** |
| Advertising and marketing (Website ads $1,314.26 + Sponsorship $308.69) | $1,622.95 |
| Bank fees and service charges (credit card late fee 6/10) | $41.00 |
| Meals | $33.89 |
| Software and apps (QBO subscription, reclassed today) | $37.50 |
| QuickBooks Payments fees | $85.27 |
| **Total expenses** | **$1,820.61** |
| **Net income YTD (cash)** | **$6,698.35** |

Income detail: Overbeck $2,800 (INV-2026-043 deposit $840 + INV-2026-045 final $1,960, both collected), Garcia sub-labor $6,000 (INV-2026-044 $800 + INV-2026-046 $2,560 + INV-2026-049 $2,640, all collected), plus a $5.00 "Sample Customer" test invoice that is real cash but not real revenue (parked on the cleanup list, see the books-cleanup memo).

Known headwinds not yet in the books (both reduce taxable income when booked):
- July credit card activity is uncategorized: no card transactions in QBO after 6/25, while the warehouse shows $673.18 of platform-accrued July ad spend (Google $630.42 + Meta $42.76). Cash-basis timing follows the card charge dates, but the feed needs categorizing.
- Personally paid subscriptions (section 3 below), roughly $300 to $600 YTD, amounts pending your statement review.

Working tax-basis estimate after those adjustments: roughly **$5,900 to $6,400**. I use the booked $6,698.35 for reserve math below (conservative, reserves slightly high).

## 2. Tax reserve and Q3 1040-ES

### Reserve rate: 35% confirmed as the right number

Math on YTD net income of $6,698.35 (entity is a disregarded SMLLC, all of this lands on your 1040 Schedule C):

| Component | Calculation | Amount |
|---|---|---:|
| Net earnings from self-employment | $6,698.35 x 92.35% | $6,185.92 |
| SE tax at 15.3% | $6,185.92 x 15.3% | $946.45 |
| Deduction for half of SE tax | $946.45 / 2 | ($473.22) |
| Income subject to income tax | $6,698.35 - $473.22 | $6,225.13 |
| Federal income tax, 12% marginal scenario | $6,225.13 x 12% | $747.02 |
| Federal income tax, 22% marginal scenario | $6,225.13 x 22% | $1,369.53 |
| Wisconsin, 4.4% marginal scenario | $6,225.13 x 4.4% | $273.91 |
| Wisconsin, 5.3% marginal scenario | $6,225.13 x 5.3% | $329.93 |
| **Total, low scenario** | SE + 12% + 4.4% | **$1,967.38 (29.4%)** |
| **Total, high scenario** | SE + 22% + 5.3% | **$2,645.91 (39.5%)** |
| **Reserve at 35%** | $6,698.35 x 35% | **$2,344.42** |

35% sits between the scenarios and the QBI deduction (20% of qualified business income, IRC 199A) gives additional cushion on the federal leg, so **35% stands. Reserve today: $2,344, round to $2,350.**

Sources:
- SE tax rate 15.3% (12.4% Social Security + 2.9% Medicare): VERIFIED 2026-07-22, irs.gov/businesses/small-businesses-self-employed/self-employment-tax-social-security-and-medicare-taxes. The 92.35% factor is the standard Schedule SE line 4a computation; exact 2026 Social Security wage base NEEDS VERIFICATION but is irrelevant at this income level.
- WI brackets (3.50% / 4.4% / 5.3% / 7.65%, 2025 tables): VERIFIED 2026-07-22, revenue.wi.gov/Pages/FAQS/pcs-taxrates.aspx. 2026 bracket indexing NEEDS VERIFICATION when DOR publishes.
- Your actual federal marginal bracket depends on household income I do not have. Tell me your expected 2026 filing status and other income and I will pin the scenario.

### Q3 1040-ES: pay $2,350 by Monday 2026-09-15

- Q3 covers June 1 through Aug 31 and is due **September 15** (VERIFIED 2026-07-22, irs.gov/faqs/estimated-tax).
- No Q1/Q2 estimates were made and none were needed: CWDB was cumulatively at a loss through 5/31 (Apr -$20.84, May -$398.40). All profit landed in June ($1,969.59) and July ($5,148.00 so far), inside the Q3 window.
- **Recommended payment: $2,350** (the full 35% reserve on YTD profit). Pay at irs.gov/payments (Direct Pay, select 1040-ES, tax year 2026).
- **Recompute on 8/31 before paying:** if the Koy ($2,325) and Peksa ($900) deposit invoices collect before then, add 35% of collections (+$1,129 if both) for a payment near $3,480.
- Wisconsin estimate: WI has its own estimated tax (Form 1-ES). Recommended WI piece of the reserve is the ~$300 WI slice above; pay via tap.revenue.wi.gov. WI underpayment thresholds NEEDS VERIFICATION (Form 1-ES instructions) before I call a required amount; paying the slice voluntarily is safe either way.
- Safe harbor check (VERIFIED 2026-07-22, irs.gov/faqs/estimated-tax): no federal penalty if 2026 withholding + estimates reach the smaller of 90% of 2026 tax or 100% of 2025 tax (110% if 2025 AGI over $150k). **If your W-2 withholding already covers 100% (or 110%) of your 2025 total tax, the 9/15 payment is optional penalty-wise**, but I still recommend paying so April 2027 is not a cliff. Send me your 2025 total tax and current withholding and I will confirm which side you are on.

## 3. Subscription commingling

The business credit card in QBO (Business Credit Card 1474) shows only ad platforms, one Intuit charge, and job materials. None of the stack subscriptions appear anywhere in the business accounts, which confirms they are riding personal payment methods.

| Vendor | Est. monthly | Basis for estimate | Action |
|---|---:|---|---|
| HubSpot Starter | $15.00 | Known plan price (register, confirmed) | Switch card: HubSpot > Settings > Account and Billing > Payment method |
| Webflow (site plan, cwdeckbuilders.com) | TBD (~$23 to $29) | Typical CMS plan; pull from Webflow > Site settings > Plans | Switch card on billing page; grab invoice history PDF |
| GoDaddy (domain + DNS) | TBD (~$2/mo equivalent, billed annually) | Typical .com renewal; pull from GoDaddy > Account > Renewals and billing | Switch card; note renewal date |
| Supabase (warehouse project) | TBD (~$25 if Pro) | Warehouse live since 6/3; check org billing page | Switch card |
| Anthropic API | Variable | Budget ledger caps $8/day soft, $150 project cap | Switch card at console.anthropic.com billing |
| Streamlit Cloud | Likely $0 | Estimator on Community Cloud | Confirm free tier, no action if $0 |
| DocuSign | TBD | May have lapsed since JobTread e-sign | Confirm status; cancel or switch |
| JobTread | TBD | Platform live since 7/13 cutover | Confirm who pays and amount; switch to business card |
| Make | $0 expected | Parked since 4/19 | Confirm no charges |

Estimated total riding personal cards: **roughly $65 to $100/mo** plus variable Anthropic. Exact figures need your personal card statements (I cannot see them).

### The fix, two parts

**Part 1, stop the bleed (do once, ~20 minutes):** switch the payment method on each vendor above to the business credit card. New charges then flow through the QBO bank feed and get categorized normally. I will build bank rules once the first charges land.

**Part 2, months already paid personally:** for a disregarded single-member LLC the clean treatment is **expense plus Owner Contribution**, not a formal accountable plan (accountable plans are the corporate-employer mechanism; keep that concept for a future S-corp year). Two equivalent mechanics, pick one:
- (a) **Journal entry (preferred, no cash moves):** one JE per month or one compound JE: debit the expense accounts, credit Shareholders' equity: Contributions (QBO account 134). On the cash basis these are deductible when you paid them personally, because the LLC is disregarded and your payment is the business's payment for Schedule C purposes.
- (b) **Reimbursement:** the LLC pays you back from the business account with the vendor receipts attached; the payment gets categorized to the expense accounts.

**What I need from you:** the personal card statement lines for these vendors from 2026-03-12 to today (vendor, date, amount). I will draft the exact JEs the same day, they go on the pre-4/28 backfill JE list in the books-cleanup memo.

### Substantiation

Download the invoice/receipt history from each vendor's billing page while you are in there (HubSpot, Webflow, GoDaddy, Supabase, Anthropic all offer PDF invoice history). Drop them in the receipts intake point, which is still an open item for you to pick (open action item 3, my recommendation remains QBO receipt capture).

---

*Positions in this memo are labeled VERIFIED (with date and source) or NEEDS VERIFICATION per standing research protocol. Nothing here changes the standing owner decisions of 2026-06-10 (no WI sales tax on CWDB revenue, no S-corp election for 2026).*
