---
name: Cost Calculator Legal Audit — Open Action Item
description: Jim requested legal audit of /cost-calculator page for risky claims (price ranges, implied guarantees); initial code review completed 2026-04-04
type: project
tags:
  - type/memory
  - agent/legal-compliance-counsel
created: 2026-04-04
updated: 2026-04-16
status: active
---

## Status: INITIAL CODE REVIEW COMPLETE — WRITTEN AUDIT PENDING

Jim specifically requested this audit (2026-04-04) because the cost calculator is the page most likely to contain legally risky claims.

## Preliminary Findings from calculator.js Code Review

### Issues Identified

**1. Disclaimer language — ADEQUATE but could be stronger**
Current disclaimer: "This is a rough estimate based on average Central Wisconsin pricing. Actual costs vary based on site conditions, design complexity, and contractor availability."
- This is reasonable but should add: "This estimate is for informational purposes only and does not constitute a quote, bid, or guarantee of pricing."
- Risk: MEDIUM — without stronger language, a homeowner could argue reliance on the estimate

**2. CTA button text — MINOR CONCERN**
CTA reads: "Get My Exact Quote -- Free"
- The word "Exact" after showing an estimate range could imply CWDB guarantees precision
- Recommendation: Change to "Get Your Free Quote" (removes "Exact" which over-promises)
- Risk: LOW

**3. Price data accuracy**
- Material costs are hardcoded (e.g., pressure-treated $15-25/sq ft, composite $30-60/sq ft)
- If these become stale, the calculator produces misleading estimates
- Recommendation: Add a "Prices last updated [date]" note; review pricing data quarterly
- Risk: LOW (currently reasonable ranges)

**4. No "not a guarantee" language in result display**
- The result shows "$X,XXX -- $XX,XXX" prominently with disclaimer below in small text
- Recommendation: Add inline qualifier like "Estimated Range:" above the dollar figures
- Risk: LOW (disclaimer exists, but prominence matters)

### No Issues Found
- Calculator does not promise specific contractor pricing
- Calculator does not guarantee availability
- Calculator does not collect PII (just selection inputs, no personal data)
- GTM tracking only logs calculator usage metrics, not personal data

## Next Step
Deliver full written audit to Jim with specific redline recommendations for disclaimer language and CTA text.

**Why:** Cost calculators are a common FTC enforcement target when they create false expectations about pricing. The current implementation is mostly sound but needs tightening.

**How to apply:** Deliver audit in Jim's preferred format (full document + plain-English summary + section walkthrough). Flag CTA text change and disclaimer strengthening as pre-launch items.
