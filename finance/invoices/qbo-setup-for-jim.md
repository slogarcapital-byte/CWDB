# QBO Setup for Jim (2026-06-10)

Two parts. Part A sends INV-2026-001 from QBO tonight. Part B creates the
Intuit developer app so I can build the API push next session.
Company: Central Wisconsin Deck Builders, Essentials, realm ID 9341457249522270.
Note: QBO menu labels shift occasionally; if a label differs, look for the nearest match.

## Part A: Send INV-2026-001 from the QBO UI tonight

1. Sign in at qbo.intuit.com and confirm the company name top left is Central Wisconsin Deck Builders.
2. Gear icon (top right) > Account and settings > Sales > Sales form content: turn ON "Custom transaction numbers". Save, then Done. This lets us use our INV-2026-001 number instead of QBO's auto number.
3. Gear icon > Account and settings > Payments: if QuickBooks Payments is not yet active, click the signup/learn more button and complete the application (business info, EIN 41-5355234, owner SSN, business bank account for deposits). This enables the card/ACH pay button on emailed invoices. Approval is usually fast but can take up to a day.
4. Left menu Sales > Customers > New customer. Enter: Name Debbie Overbeck; Email doverbeck1@gmail.com; Phone (715) 393-7145; Billing address 9409 Lambert St., Rothschild, WI 54474. Save.
5. Gear icon > Products and services > New > Service. Name: Customer Deposit. Income account: an income account such as Sales or Services (if the list is the QBO default, pick Sales of Product Income or Services; I will review the chart of accounts later). Do NOT mark it taxable. Save and close.
6. Click + New (top left) > Invoice.
7. Fill the invoice:
   - Customer: Debbie Overbeck
   - Invoice no.: INV-2026-001
   - Invoice date: 06/10/2026; Terms: Due on receipt
   - Line 1: Product/Service = Customer Deposit; Description = "Deposit due at signing: 30% of the $2,800.00 Total Price under the Deck Staining Work Order, Job No. CWDB-2026-001. Remaining balance of $1,960.00 due on the final invoice after completion of the Work and your walkthrough."; Amount = 840.00
   - No sales tax anywhere on the form (owner decision 2026-06-10). If a tax field shows, leave it blank or set Not taxable.
8. Message on invoice (the note the customer sees): "Your deposit will be held, not deposited or spent, until your three-business-day right to cancel expires at midnight on Saturday, June 13, 2026. If you cancel within that period, your deposit is fully refundable. Thank you. Central Wisconsin Deck Builders, LLC, (715) 544-7941."
9. On the invoice, find the online payments toggles (usually "Manage" panel or checkboxes near the top: Cards and Bank transfer/ACH). Turn both ON. These only appear once step 3 (Payments) is active. If Payments approval is still pending, you can send now and the pay button starts working once approved, or wait for approval to send.
10. Click Review and send. Send to doverbeck1@gmail.com. Cc info@cwdeckbuilders.com so we have a copy. Confirm the email preview shows the pay button (if Payments is active).
11. Tell me once it is sent. I will log the status. Do not record a payment in QBO until her money actually arrives, and remember the funds hold until midnight 2026-06-13.

## Part B: Intuit developer app (for the API automation, next session)

1. Go to developer.intuit.com and sign in with the SAME Intuit account that owns the live QBO company. This matters for authorizing the app later.
2. Open the dashboard and click Create an app. Choose QuickBooks Online and Payments as the platform. Name it something like "CWDB Books Integration".
3. Scopes: select com.intuit.quickbooks.accounting (Accounting). Skip the Payments API scope; QBO Payments from Part A does not need it.
4. In the app, open Keys & credentials. There are two key sets: Development (sandbox) and Production. Copy the Client ID and Client Secret for Development now. Production keys may require completing Intuit's production questionnaire; do that when prompted, it can be finished later.
5. Still in the app settings, add a Redirect URI: http://localhost:8000/callback
6. Put the keys in the file `.env.local` at the CWDB repo root (create the lines if missing, never commit this file):
   - QBO_CLIENT_ID=your Client ID
   - QBO_CLIENT_SECRET=your Client Secret
   - QBO_REALM_ID=9341457249522270
   - QBO_ENVIRONMENT=sandbox  (I flip this to production when we go live)
   - QBO_REFRESH_TOKEN=  (leave blank; the one-time authorization run fills it, and my scripts keep it rotated)
7. Stop there. Next session I run the one-time OAuth authorization with you (a localhost listener catches the auth code), test against the sandbox company, then connect the live company and build push-qbo-invoice.ps1 per operations/data-warehouse/design/hubspot-qbo-flow.md.
