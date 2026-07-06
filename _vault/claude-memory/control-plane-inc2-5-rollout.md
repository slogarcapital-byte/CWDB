---
name: control-plane-inc2-5-rollout
description: "2026-06-11 one-day rollout of control-plane increments 2-5 — what shipped, how the executor works, open items (approval 60, token-cap revert)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 54a6e86e-af62-464b-994e-19819c76adeb
---

# Control Plane Inc 2→5 Rollout (2026-06-11)

All five build-sequence increments from the original plan (`~/.claude/plans/your-mission-you-zesty-aurora.md`) are now live. Commits 27d3d9d (Inc 2), c132bc2 (Inc 3), 9052d09 (Inc 4), 98f0c1e (Inc 5), pushed test-branch→main same day.

## Flag state (control-config.json rollout)
`dry_run=false · auto_execute_max_tier=1 · council_enabled=true · tier2_execution_enabled=true`

## How the executor works (runbook §3, the Inc 3 centerpiece)
- Orchestrator checks for an `approved` approval_queue row BEFORE decomposing/routing; executing one IS the tick's single bounded step.
- Atomic claim: conditional `UPDATE ... SET status='executing', execution_attempts+1 ... WHERE status='approved' ... RETURNING` (no double-claim across concurrent ticks).
- Worker spawned in EXECUTE-APPROVED mode: idempotency check FIRST (adopt crashed partial work), then steps, then embedded verify.
- Tier-A critic gates the execution evidence before commit (never-commit-unverified applies to executions).
- Fail attempt 1 → released back to `approved` + error in task feedback; attempt 2 → terminal `failed`.
- Reapers in control-tick 4b: expiry (pending/approved past expires_at → expired; warn if was approved) and stale claim (`executing` >45 min → back to approved).
- Migration 011 added statuses `executing`/`failed` + `claimed_at`/`executed_at`/`execution_attempts`/`execution_result`.

## proven_delivery_path hinge (control-tick 6b)
Flips Tier-2→Tier-1 for deliveries only when `v_delivery_proof.real_bid_count>=1` AND an `action_executed` event with a delivery-class `action_kind` exists. The AND is load-bearing: WB-016 backfill means 7 real fact_bids rows exist WITHOUT any routed delivery. Currently false (correct).

## What got executed/produced today
- Approval 1 EXECUTED → Make TEST scenario 5361099 (hook 2442209, INACTIVE, folder 231872), parked 4792854 untouched, documented as sc-002 in `operations/make/webhooks.json`. Make API cannot run-once an inactive scenario → ~25s activate/deactivate window is the accepted pattern for webhook self-tests.
- Council #1 (verdict changes) ordered the [[v-clean-leads-test-exclusion-gap]] hardening BEFORE the test webhook → views/006 excludes `@cwdb-internal.test` (RESOLVED, defense in depth done).
- Council #2 (decomposition review, verdict changes) reframed seeding: walk-through-readiness first. Task 57 artifact: `operations/leads/walkthrough-runbook-2026-06-11.md` (Jim call order: Sjoberg → Quinn → Kampstra → Johnson; calendar shows 3 walk-throughs by 6/18 feasible).
- CRITICAL schema finding F1: `webflow_submission_id` is NULL on ALL real fact_leads rows (HubSpot pull never sets it) → any upsert keyed on it never merges; duplicates would corrupt the gate. F2: phone leads can't use the sc-002 contract. F4: auto fact_bids insert inflates delivered counts.
- First fully autonomous remote tick (13:16 Central) routed task 58 and queued **approval 60 `routing.go_live`** with F1/F2/F4 fixes (email-keyed upsert, webform-only null-email gate, notify-Jim-only, no auto fact_bids).

## Open items
- **Approval 60 pending** = Jim's decision; once approved, the executor takes the routing path live (real leads → notify Jim).
- **Token caps temp-raised** to soft 700k / hard 900k (day_tokens hit 646k from rollout gauntlets; token_hard_daily tripped honestly at 13:30 and was resumed). **Revert to 400k/600k on 2026-06-12** via dashboard config dialog.
- Task 59 (ads.hook_audit, tier 1) queued; scheduled ticks will pick it up.
- contractor-sales activation waits for the hinge (first REAL routed delivery).
- Breaker thresholds still pre-staged; retune from ledger data after ~a week.
- council_verdict.task_id is NOT NULL → decomposition councils must insert AFTER seeding tasks (attach to the task the verdict shaped).
