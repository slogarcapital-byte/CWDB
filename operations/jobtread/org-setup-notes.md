# JobTread Org Setup Notes

**Started:** 2026-07-13 · **Org configured:** 2026-07-14 (programmatically)
**Design:** `operations/analysis/jobtread-setup-design.md`
**Org:** Central Wisconsin Deck Builders, id `22PakakWzKDv`

## How the org was configured

Jim created the grant + the three consent fields in the UI; everything else shipped via
`templates/scripts/setup-jobtread-org.ps1` (idempotent; re-run any time; safe).
The CSV worksheet (`org-config-worksheet.csv`) is superseded by that script and kept
only as the field-spec record. Verification: `templates/scripts/test-pave-query.ps1`
prints the full live field/option dump.

## Inventory (what existed before configuration)

- JobTread pre-seeds: customer `Lead Source` dropdown, job `Status` dropdown (13 default
  options, REPLACED by our 10-stage funnel), vendor `Type`/`Trade`/`W-9`/`COI Expires`,
  Email/Phone fields on all contact types, and sample records ("Example Customer",
  "Example Vendor", "Job 1"). Sample records are harmless; delete whenever.
- Jim had created: `tcpa_consent_given`, `tcpa_consent_source`, `lead_channel`.

## Deviations from the worksheet (accepted 2026-07-14)

1. **Consent + channel fields live on `customerContact`, not `customer`** (Jim created
   them there; consent belongs to a person). Gateway + pull script target customerContact.
2. **Job stages are NOT a first-class object.** They are options on the pre-seeded job
   `Status` custom field. The 13 default options were replaced with the 10-stage funnel.
3. **Contact phone/email are custom field values** (`customerContact.Phone` type
   phoneNumber, `customerContact.Email` type emailAddress), not top-level args.
4. **Phone-only leads verified via API** (worksheet row 38): createContact with only the
   Phone custom field succeeds.

## Load-bearing values

- **Option vocabulary (corrected 2026-07-15):** the Webflow form submits SLUGS
  (`deck-replacement`, `35k-50k`, `asap`); HubSpot's real property options and the
  warehouse both speak slug. The original worksheet copied labels from the STALE
  design doc (`hubspot-lead-pipeline.json`), which broke the first real-device lead
  (createJob 400 -> no job). Fix: the three job option fields (`project_type`,
  `budget_range`, `project_timeline`) now hold the live form's human-readable
  LABELS, and the gateway maps slug -> label (the ONLY translation seam; maps at
  the top of `jobtread-gateway/index.ts`). Bronze payloads + the HubSpot write keep
  raw slugs, so warehouse vocabulary is untouched. If the form's options change,
  update the JobTread option lists AND the gateway maps together.
- Status option 6 is exactly `Signed / Booked` (spaces around slash); the attribution
  webhook keys on it.
- The live form's name field is `firstname` (relay v2.0.1 maps it to `name`; the
  gateway also accepts `firstname` directly as a fallback).

## Pave schema facts (validated live 2026-07-14)

- **Endpoint:** `POST https://api.jobtread.com/pave`, body `{ "query": {...} }`,
  `grantKey` inside the top-level `"$"` args. Errors are terse but name the failing path;
  a wrong field name sometimes gets "did you mean" hints.
- **Org discovery:** `currentGrant.user.memberships.nodes[].organization` (NOT
  `currentGrant.organization`, which returns null).
- **Object model:** Account (`type`: `customer` | `vendor`) → Contacts + Locations;
  Jobs hang off **Locations** (`createJob` requires `locationId`, not accountId).
- **Organization child nodes:** `accounts`, `contacts`, `jobs`, `customFields`,
  `webhooks`, `locations`, `costCodes` (no `customers`, `jobStages`, `stages`,
  `pipelines` nodes).
- **customFieldValues:** on reads, a connection (`nodes[].{value, customField{name}}`);
  on creates, a MAP KEYED BY FIELD ID: `customFieldValues: { "<fieldId>": <value> }`.
  Build a name→id map at runtime; do not hardcode ids in code (they are in git history
  if ever needed).
- **Field targetTypes:** `customer`, `customerContact`, `job`, `vendor`, `vendorContact`.
- **Field types seen:** `text`, `number`, `boolean`, `option`, `phoneNumber`,
  `emailAddress`, `date`.
- **Mutations validated:**
  - `createCustomField($: organizationId, targetType, type, name, minValuesRequired
    [, options])` → `createdCustomField{id}` (`minValuesRequired` is REQUIRED)
  - `updateCustomField($: id, options)` (replaces the option list)
  - `createCostCode($: organizationId, name)` → `createdCostCode{id}`
  - `createAccount($: organizationId, name, type)` → `createdAccount{id}`
  - `createContact($: accountId, name, customFieldValues)` → `createdContact{id}`
    (phone/email go through customFieldValues; phone-only OK)
  - `createLocation($: accountId, name, address)` → `createdLocation{id}`
  - `createJob($: locationId, name, customFieldValues)` → `createdJob{id}`
  - `deleteJob`, `deleteLocation`, `deleteAccount` ($: id) — child-first;
    deleteAccount refuses while a job references the account.
- **Pagination:** connection args take `size`; `nextPage` cursor field on the
  connection (pull script consumes `nextPage` + `page` arg; re-verify shape on first
  large pull).

## Deliberate omissions (do not "fix")

- Resale-model fields NOT created: matched_contractor, routing_sent_at,
  first_response_window_hours, referral_fee_invoiced_at, referral_fee_paid_at.
- SBG structure NOT modeled (lean-now decision 2026-07-13); cost codes are the solo
  five: Materials, Labor, Permits, Equipment, Other.
