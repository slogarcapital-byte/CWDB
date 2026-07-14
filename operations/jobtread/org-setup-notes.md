# JobTread Org Setup Notes

**Started:** 2026-07-13
**Design:** `operations/analysis/jobtread-setup-design.md`
**Worksheet:** `org-config-worksheet.csv` (37 config rows + 1 verification row)

## Inventory (what existed before the worksheet)

- Jim signed up and explored the UI before 2026-07-13; nothing systematic configured.
- TO FILL after Jim's pass: anything he had already created that the worksheet duplicated or that JobTread pre-seeds (default job stages, default cost codes). If JobTread ships default stages, RENAME or REORDER them to match worksheet rows 23-32 rather than creating duplicates.

## Deliberate omissions (do not "fix")

- Resale-model fields NOT created: matched_contractor, routing_sent_at, first_response_window_hours, referral_fee_invoiced_at, referral_fee_paid_at, contractor Vendor fields. Parked with the lead-resale model; create only if the overflow lane reactivates.
- SBG structure NOT modeled (lean-now decision 2026-07-13): no partner seats, no shared-labor cost codes. Additive later if the attorney/CPA gate clears.

## Load-bearing values

- `budget_range` option strings must match HubSpot byte-for-byte (warehouse normalizer dependency), including the en dashes and commas: `Under $5,000` / `$5,000 – $10,000` / `$10,000 – $20,000` / `$20,000 – $40,000` / `$40,000+`.
- Stage names row 23-32 are consumed verbatim by the webhook fan-out (`Signed / Booked` exactly, with spaces around the slash).

## Deviations reported by Jim

- TO FILL: anything JobTread's UI would not accept verbatim (character limits, forbidden characters in dropdown options, stage-name constraints).

## Phone-only Customer verification

- TO FILL: pass/fail of worksheet row 38.

## Pave schema facts (Task 3)

- TO FILL by `templates/scripts/test-pave-query.ps1`: live node names, custom-field value shapes, create/webhook mutation names + required args, org id (goes to `.env.local` as JOBTREAD_ORG_ID, never committed).
