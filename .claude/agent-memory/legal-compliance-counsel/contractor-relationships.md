---
name: Contractor Relationships
description: 2 contractors with executed agreements sent via DocuSign 2026-04-07; Ben Barton (Barton Builders LLC) + John Garcia (John Garcia Construction, LLC); $1K/accepted bid
type: project
tags:
  - type/memory
  - agent/legal-compliance-counsel
created: 2026-04-04
updated: 2026-04-16
status: active
---

CWDB has two committed contractors. Both have Contractor Lead Purchase Agreement v1 sent via DocuSign on 2026-04-07 (effective April 6, 2026). Awaiting signed copies returned.

**Why:** These are the first two revenue partners. Formalizing via executed agreements protects CWDB from disputes over terms, payment, and data handling obligations.

**How to apply:** Track DocuSign status for both contractors. Once signed copies are returned, file in /sales/contractor-agreements/. Do not begin delivering leads until signed agreements are in hand.

## Contractor 1: [[Ben Barton]]
- **Company:** Barton Builders LLC
- **Location:** [[Wausau]], WI
- **Email:** bartonbuildersllc@yahoo.com
- **Phone:** 715-551-3191
- **HubSpot ID:** 462464338657
- **HubSpot lifecycle:** Customer
- **Terms:** $1,000 per accepted bid
- **Agreement status:** DocuSign sent 2026-04-07, effective 2026-04-06 — awaiting signed copy
- **First contractor secured:** 2026-03-12

## Contractor 2: [[John Garcia]]
- **Company:** John Garcia Construction, LLC
- **Location:** Edgar, WI
- **Email:** john@johngarciaconstruction.com
- **Phone:** 715-567-0269
- **HubSpot ID:** 465926077160
- **HubSpot lifecycle:** Customer
- **Terms:** $1,000 per accepted bid
- **Agreement status:** DocuSign sent 2026-04-07, effective 2026-04-06 — awaiting signed copy

## Infrastructure
- **Agreement generator:** /docs/legal/generate_agreement_pdf.py (parameterized)
- **Send script:** /sales/contractor-agreements/generate_and_send.py
- **Signed PDFs location:** /sales/contractor-agreements/
- **Log:** /sales/contractor-agreements/log.md

## Open Items
1. Track DocuSign returns — follow up if not signed within 7 days
2. Implement bid acceptance verification system (see verification-architecture.md)
3. Attorney review of agreement v1 still recommended (especially liquidated damages, limitation of liability, arbitration clauses)
4. Verify both contractors maintain required insurance and licensing per agreement terms
