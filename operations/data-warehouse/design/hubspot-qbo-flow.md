# HubSpot to QuickBooks Online Integration Design

**Status:** DESIGN ONLY (2026-06-10). No API connection exists yet. Author: accounting agent.
**Prereqs:** Intuit developer app + OAuth credentials (checklist in `~/.claude/agent-memory/accounting/qbo-integration.md`); HubSpot `crm.schemas.deals.write` scope for `cwdb_job_number` (board WB-016, Jim adding).

## 1. System-of-Record Boundaries

| System | Owns | Never holds |
|---|---|---|
| **QBO** (realm 9341457249522270, Essentials) | Financial record: customers-as-payers, invoices, payments, deposits, sales tax, bank feeds, P&L for tax | Lead/pipeline state, marketing data |
| **HubSpot** (pipeline 2247158458, 9 stages) | CRM: contacts, deals, stage progression, accepted-bid confirmation events | Invoice amounts/status as authority (mirror fields only) |
| **Supabase** | Analytics: `fact_leads`, `fact_bids` (pending/sent/accepted/paid), `dim_jobs` + `allocate_job_number()`, `v_pl_monthly` | Books of record; never the invoice authority |

Sync directions:
- HubSpot -> QBO: deal-stage events trigger Customer + Invoice creation (one way).
- QBO -> Supabase: invoice/payment facts flow to warehouse for `v_pl_monthly` (Phase 3; until then warehouse derives from HubSpot + manual entries).
- QBO -> HubSpot: at most a read-only mirror property (invoice number + status) for Jim's pipeline view. Optional, late.
- Never sync: QBO chart of accounts, bank transactions, tax config (QBO-only); HubSpot marketing/contact noise into QBO (QBO customer list stays payers-only).

## 2. Customer Creation (QBO Customer entity)

Two payer types, two triggers:

**A. Contractor (lead-fee channel).** Created once, manually, at agreement signing. Ben Barton (Barton Builders LLC) and John Garcia (John Garcia Construction LLC) are the only two; create them during initial QBO setup, not per deal. DisplayName = legal LLC name; map email/phone from HubSpot contact (462464338657 / 465926077160). Terms: Net 15.

**B. Homeowner (direct construction channel).** Created when a deal reaches the work-order/contract-signed stage (the same event that allocates a job number via `allocate_job_number()`). Earlier stages never create QBO customers: no payer, no customer.

Field mapping (HubSpot deal + contact -> QBO Customer):

| QBO field | Source |
|---|---|
| DisplayName | Contact first + last (homeowner) or LLC legal name (contractor) |
| PrimaryEmailAddr | Contact email |
| PrimaryPhone | Contact phone |
| BillAddr | Contact/deal address (job site for homeowners) |
| CustomerMemo convention | Job number `CWDB-YYYY-NNN` from `dim_jobs` (also on every invoice memo/custom field) |

Essentials has no class tracking, so channel separation interim = **sub-customer/parent structure or job-number memo discipline**; revisit on Plus upgrade (see section 3 note).

## 3. Invoice Creation Triggers

One invoice number series for everything: **INV-YYYY-NNN** (next: INV-2026-002). QBO DocNumber is set explicitly to match; custom transaction numbers ON.

| # | Trigger event | Channel | QBO Customer | Line item (Service) | Amount | Terms |
|---|---|---|---|---|---|---|
| a | Work order / Home Improvement Contract signed (HubSpot stage -> contracted; `dim_jobs` row created) | Direct Construction | Homeowner | `Construction:Deposit` -> 4200 Construction Revenue (or a deposit liability account if accrual treatment is later adopted; cash basis books it as received) | Per contract (e.g. 30%) | Due on receipt |
| b | Completion walkthrough done (HubSpot stage -> completed) | Direct Construction | Homeowner | `Construction:Final` -> 4200, less deposit applied | Contract balance | Due on receipt |
| c | Accepted-bid confirmation (fact_bids -> accepted; contractor reports per agreement) | Lead Generation | Contractor | `Lead Fee: Accepted Bid` -> 4000 Lead Fees | $1,000 | Net 15, invoice within 10 business days, 1.5%/mo late interest |

Supporting items: `Late Fee / Penalty` -> 4100 (1.5%/mo interest, $250 unreported-bid penalty).

**Class structure (target) vs Essentials reality.** Target COA design uses QBO classes `Lead Generation` and `Direct Construction` on every transaction. Class tracking is Plus/Advanced only (VERIFIED 2026-06-10, Intuit article L1QzEOUxM). Interim on Essentials: channel is inferable from the item (4000-series items = Lead Gen, 4200-series = Construction) plus job-number memos; P&L by channel comes from item-level reporting. **Upgrade-to-Plus trigger stands: launch of Option B (CWDB-primed full builds).** On upgrade, add the two classes and backfill via item mapping.

**Option B (future, post-license).** CWDB primes; Ben/John become vendors (subcontractors), paid via Bill/BillPayment, mapped to a new COGS account (Subcontractor Labor, under 5100 block). 1099-NEC applies to this channel only; QBO contractor/1099 tracking turns on then. Do not create vendor records for Ben/John until Option B is live (they are customers today; QBO allows both but keep it clean until needed).

## 4. Sales Tax Hooks (RESOLVED 2026-06-10 by owner decision)

Jim decided 2026-06-10: no WI sales tax on any CWDB revenue (lead fees and all construction/staining/resurfacing). DOR inquiry closed. See `agent-memory/accounting/wi-sales-use-tax.md`. Operative config: QBO sales tax stays off, all items non-taxable, no seller's permit registration, invoice push always tax-silent. The table below is retained only as the config map if DOR ever contacts us:

| Outcome | QBO config change |
|---|---|
| Staining EXEMPT (real property improvement) | No registration. All invoices non-taxable. Set company sales tax OFF or leave items non-taxable. Materials: pay sales tax at purchase (contractor-as-consumer), book to 5100. |
| Staining TAXABLE (repair/maintenance service) | Register for WI seller's permit BEFORE the final invoice. Enable QBO Automated Sales Tax, agency WI DOR, Marathon County situs (5.5% combined, NEEDS VERIFICATION). Mark `Construction:Final` staining item taxable. Overbeck: tax absorbed inside the fixed $2,800 (tax-included math per INV-2026-001-tax-position-note.md), never added on top without a change order. |
| Lead fees (either way) | Expected exempt; lead-fee item stays non-taxable. If DOR surprises us, item flips taxable and contractors get 60-day notice per agreement before any pricing change. |

Invoice push script reads a per-item taxable flag from its JSON input so the flip requires no code change.

## 5. Implementation Mechanics

**Auth.** Intuit developer app, OAuth 2.0 authorization code grant, scope `com.intuit.quickbooks.accounting`. Access token 1 hour; refresh token rolling 100 days, rotates, old token dies 24h after rotation, so the script writes the new refresh token back to `.env.local` on every refresh (the Intuit analog of our Google OAuth trap). Env vars in `.env.local` at repo root, loaded by the same Load-DotEnv pattern as the warehouse pulls: `QBO_CLIENT_ID`, `QBO_CLIENT_SECRET`, `QBO_REFRESH_TOKEN`, `QBO_REALM_ID`, `QBO_ENVIRONMENT`.

**Base URL.** `https://quickbooks.api.intuit.com/v3/company/<realmId>/<entity>?minorversion=75` (sandbox: `sandbox-quickbooks.api.intuit.com`). Retry on 429 with same requestId.

**Minimal endpoint set.**
- `Customer` (create/query by DisplayName before create; never duplicate)
- `Item` (one-time setup of the service items in section 3)
- `Invoice` (create with explicit DocNumber, email send optional)
- `Payment` (record receipt, apply to invoice)
- Maybe later: `Estimate` (mirror of our PDF estimates; low priority, PDFs work) and `CreditMemo` (cancellation-window refunds, Section 4.1).

**Customer Hub evaluation note (2026-06-11).** Evaluated QBO Customer Hub (Estimates/Proposals/Contracts/e-sign) vs our document stack: see `finance/invoices/qbo-customer-hub-evaluation.md`. Endpoint impact: NONE. Contracts/Proposals are not exposed in the v3 Accounting API (no contract-signed webhook), so the minimal set above stands and no Estimates API is needed. If Jim adopts the recommended hybrid (our combined PDF e-signed via QBO contract builder), invoice creation at signing remains this design's `push-qbo-invoice.ps1` path, manually triggered at signature until Phase 3. Side effect on Section 7 item 1: contract builder requires Plus, which may pull the Plus upgrade forward ahead of Option B (and gives us class tracking early).

**Scripts** live in `templates/scripts/`, named to match the existing `pull-*.ps1` family:
- `push-qbo-invoice.ps1` (JSON in, Customer find-or-create + Invoice create out; same JSON the PDF generator consumes from `finance/invoices/_data/`)
- `pull-qbo-status.ps1` (Phase 3: invoice/payment status -> Supabase for `v_pl_monthly`)
- Shared token helper inside each script or a dot-sourced `load-qbo.ps1` (mirrors `load-supabase.ps1`).

**Phased rollout.**
1. **Phase 1 (now, pre-connection):** PDF invoices remain authoritative artifacts; Jim or I key them into QBO manually once bank feeds are connected. Sandbox testing of the developer app happens here.
2. **Phase 2 (credentials live):** `push-qbo-invoice.ps1` pushes each invoice JSON to QBO at generation time; PDF and QBO record are created in the same session. Manual trigger.
3. **Phase 3 (automation):** HubSpot stage-change (or `fact_bids` status flip detected by the daily warehouse run) queues the invoice push; `pull-qbo-status.ps1` joins the daily cron alongside the other pulls. Human review of every invoice before send stays until volume forces otherwise.

## 6. Back-fill Plan (pre-connection invoices)

- **INV-2026-001** (Overbeck deposit, $840, 2026-06-10): enter into QBO as the first invoice once connected; DocNumber INV-2026-001, customer Debbie Overbeck, deposit item, memo CWDB-2026-001, tax-silent per the tax-position note. Record Payment when the check clears (watch `dim_jobs.deposit_received_at`; funds held to midnight 2026-06-13 per the cancellation window).
- Any other PDF invoice issued before connection joins the same backlog; the JSON files in `finance/invoices/_data/` are the entry source, so back-fill is just running `push-qbo-invoice.ps1` over the existing JSONs in number order.
- Expense back-fill is separate and already planned: bank feeds first (90-day pull covers to ~2026-03-12; verify earliest date), CSV upload for any gap, bank rules for recurring vendors.

## 7. Open Decisions for Jim

1. **QBO tier:** stay Essentials now; upgrade to Plus at Option B launch (classes + better job costing). Confirm this trigger or upgrade earlier if item-level channel reporting feels thin.
2. **QBO Payments:** DECIDED 2026-06-10: enable for card/ACH. Policy: card/digital first, check second, no cash, on all invoices. Setup steps: `finance/invoices/qbo-setup-for-jim.md`.
3. **DOR inquiry:** CLOSED 2026-06-10 by owner decision (section 4): no sales tax on any CWDB revenue, no registration.
4. **Cash basis confirmation** (existing action item 4): affects whether deposits post as income on receipt or as a liability.
5. **Invoice sending channel:** QBO-emailed invoices (QBO branding) vs our branded PDFs with QBO as ledger only. Recommend: our PDFs to the customer, QBO for the books, until QBO Payments makes the QBO email link worth it.
6. **HubSpot mirror property:** want invoice number/status visible on the deal record? Needs the same scope work as `cwdb_job_number` (WB-016).
