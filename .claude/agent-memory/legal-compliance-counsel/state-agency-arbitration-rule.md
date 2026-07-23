---
name: state-agency-arbitration-rule
description: WI state agencies (incl. UW System / UWSP) cannot agree to binding arbitration; strike it from any public-buyer contract. First state-agency job = UWSP CWDB-2026-044.
metadata:
  type: project
---

# WI State-Agency Counterparty: No Binding Arbitration

CWDB's first government/institutional customer is the **University of Wisconsin-Stevens Point** (an agency of the State of Wisconsin / UW System). Job No. **CWDB-2026-044**, new deck build, $7,751, 10186 County Road MM, Amherst Junction. Signer: **Jesse Crain, Director of Procurement**. Institutional variant (no consumer 3-day rescission; PO language).

**Rule:** A Wisconsin state agency cannot bind itself to binding arbitration. Crain flagged this and is correct. Standard CWDB construction contract's Binding Arbitration clause must be STRUCK for any state/public buyer.

**Why:** Sovereign immunity, Wis. Const. art. IV, sec. 27 (state may be sued only as the legislature directs). Claims against the state run through the Claims Board (Wis. Stat. sec. 16.007) then sec. 775.01; state procurement standard terms (Wis. Stat. ch. 16) prohibit binding arbitration. Even a "to the extent permitted" hedge is not acceptable to procurement.

**How to apply (the edit pattern, 2026-07-08):**
- Strike ONLY the Binding Arbitration subsection (13.2 in the UWSP renumber, 15.2 in `docs/legal/templates/home-improvement-contract-template.md` / `sales/estimates/generate_sow_pdf.py`). KEEP informal-resolution (13.1) and equitable-relief (13.3).
- REPLACE (do not delete) with a neutral Litigation clause routed to the venue section; carry forward the "nothing limits statutory rights" savings language; add an affirmative "no dispute is subject to binding arbitration" line (reassures the buyer). Keep the number as 13.2 so 13.3 does not shift.
- Venue clause (14.1 / template 16.2): delete the trailing "for any proceeding not subject to arbitration."
- Also fix any TOC/section-summary row that describes the section as "binding arbitration" (template line ~69).
- Arbitration appears in the CWDB template in ONLY those two spots. No prevailing-party/attorneys'-fee, survival, or limitation-of-liability clause references it.

**Venue reality vs. the state (know, but do not force into the edit unless raised):** proper venue against a state agency is Dane County (Wis. Stat. sec. 801.50(3)); Eleventh Amendment largely bars suit against the state in federal court. So "state and federal courts in Wisconsin" is aspirational as to UWSP. A CWDB claim against UWSP realistically goes through the state claims process + Dane County circuit court.

**Watch:** state procurement offices often require their OWN standard terms (DOA / UW System T&Cs) to control and may attach a superseding rider (indemnification caps, no cap on state liability, prompt-pay per Wis. Stat. sec. 16.528). Crain raised only arbitration; make that one edit and send, but a second round of state-terms asks would not be a surprise.

Related: [[sow-two-tier-contract-system]].
