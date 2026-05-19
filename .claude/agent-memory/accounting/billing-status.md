---
type: memory
agent-id: accounting
name: billing-status
description: Current billing status — revenue model, invoicing state, contractor payment tracking
tags:
  - type/memory
  - agent/accounting
created: 2026-04-16
updated: 2026-04-16
status: active
---

# Billing Status

Pay-per-accepted-bid model at $1,000 per accepted bid. Contractor pays when homeowner accepts their bid on a lead sourced by CWDB.

**Why:** This is the core revenue mechanism. Every financial report depends on tracking accepted bids.

**How to apply:** When generating invoices or P&L statements, revenue = count of accepted bids × $1,000.

## Key Facts
- Price per accepted bid: $1,000
- Contractors: [[Ben Barton]] (Barton Builders LLC), [[John Garcia]] (John Garcia Construction, LLC)
- Agreements: Sent via [[DocuSign]] 2026-04-07, awaiting signatures
- Invoices sent: 0
- Revenue collected: $0
- Leads delivered: 0 (pre-launch)

## Verification System
5-layer bid verification defined in contractor agreement:
1. Homeowner follow-up survey
2. Contractor self-reporting
3. Audit rights (CWDB can verify with homeowner)
4. Contractual penalties for non-reporting
5. Lead withholding for non-compliance

## Related
- [[Central Wisconsin Deck Builders LLC]]
- Agreement: `/docs/legal/contractor-lead-purchase-agreement-v1.md`
