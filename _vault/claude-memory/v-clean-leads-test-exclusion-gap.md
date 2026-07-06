---
name: v-clean-leads-test-exclusion-gap
description: "v_clean_leads excludes only utm_source='test' plus a few emails; any other internal/test marker leaks and false-counts toward the validation gate"
metadata: 
  node_type: memory
  type: project
  originSessionId: a7c883f9-25c5-4d44-a1fb-295356b1e6df
---

`v_clean_leads` (migration `003_tighten_test_exclusion.sql`) treats a lead as test-only when `utm_source='test'` OR the email is in a hardcoded list (`slogarjw@gmail.com`, `test@test.com`, `dcebighitta12@aim.com`). Any OTHER internal/test marker passes straight through and counts as a real lead: e.g. `utm_source='routing-selftest'`, or a `@cwdb-internal.test` email. Because the validation gate reads `qualified_since_gate` off `v_clean_leads` (currently 2/3), a single mistagged synthetic lead would false-flip `gate_met` to true and wrongly declare Phase 1 passed.

Surfaced 2026-06-09 by the Inc-1 dry-run critic, which failed a `lead-routing` proposal whose test lead used `utm_source='routing-selftest'`.

**Why:** the gate is the project's go/no-go decision. A false positive (declaring the model proven when it isn't) is far worse than a false negative.

**How to apply:** for ANY synthetic or test lead, tag `utm_source='test'` (the only currently safe marker). Open follow-up: tighten migration 003 / `v_clean_leads` to also exclude the `cwdb-internal.test` email domain (or add an explicit `is_test` flag) as defense-in-depth. Related: [[schedule-supabase-not-routine-eligible]].
