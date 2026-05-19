# CWDB CEO Operator — Memory Index
Auto-loaded each session. Keep under 150 lines. Details in linked files.

## Load on every session
- [5 leads + 4 deals on 2026-05-05](5-leads-and-4-deals-on-2026-05-05.md) — Forms API relay shipped 5 real homeowner contacts; 5 deals in Homeowner Leads pipeline (ID 2247158458). Verify live HubSpot state before claiming "no leads." Snapshot: `_vault/reality-2026-05-05.md`

## User
- [Jim Slogar — founder profile](user_james.md) — goes by Jim (James on legal docs only); CPA, Sole Member, passive income goal; 5–15 hrs/wk

## Feedback (how to work with James)
- [Ruthless mentor mandate](feedback_mentor_mandate.md) — call out weak ideas, find optimal path, keep him honest; never default to yes-man mode
- [Operator-voice communication](feedback_communication_style.md) — lead with answer, batch asks, structured briefings, no filler
- [Autonomy defaults](feedback_autonomy.md) — act on reversible work; only interrupt for money/legal/brand/irreversible; batch asks
- [Agent-tool-unavailable fallback](agent-tool-unavailable-fallback.md) — when Agent tool missing, refuse theatrical delegation and ship execution-ready specs (CSV/Markdown) instead

## Project (current state)
- [Phase 1 status](project_phase1_status.md) — what's shipped, what's left; target: ads running this week
- [Unit economics](project_unit_economics.md) — $1K/bid · CPL <$60 · cost/bid <$400 · margin ~$700; defend these
- [Contractor roster](project_contractors.md) — Ben Barton + John Garcia signed but unreturned; only 2 of 10–20 target
- [Ads-live blockers](project_blockers.md) — live punch list to get ads running (Phase F, /privacy, phone, publish, Make, HubSpot)
- [Automation backlog](project_automation_backlog.md) — what's automated vs manual; priority order for next automations
- [Pivot 2026-04-19](pivot-2026-04-19.md) — Make/Twilio parked, manual contractor SMS until ≥10 leads/week or 3rd contractor signs
- [Launch package shipped 2026-04-21](session-2026-04-21-launch-package.md) — 4-agent orchestration produced `/marketing/launch-2026-04/`; Jim executes DEPLOY.md next
- [Standing call — Meta launch is manual UI](standing-call-meta-manual-ui.md) — bulk-import path is NOT in play; reference `marketing/launch-2026-04/04-meta-copy.md`
- [Meta pixel deletion walkthrough](meta-pixel-deletion-walkthrough.md) — manual UI steps to remove pixel `4411592295757520`; unassign-from-ad-accounts is the gate before delete works
- [HubSpot↔Webflow native plan (canonical)](../../../operations/analytics/hubspot-webflow-native-plan.md) — Replaces Path A/B memo + server-event-spec 2026-04-28; HubSpot pipeline build is critical-path
- [Server-events rework 2026-04-28](server-events-rework-2026-04-28.md) — standing pattern: Jim prefers in-platform tooling over custom serverless; propose Make/HubSpot/Webflow before Workers/Lambda
- [Lever 4 structurally blocked](lever-4-structurally-blocked.md) — Ben + John have no testimonials; proof sprint via existing contractors is dead; next testimonial requires first homeowner deal close
- [Payment processor decision 2026-05-04](payment-processor-decision-2026-05-04.md) — QBO Payments primary (ACH $10 cap, B2B+B2C, native CPA stack); Venmo Business fallback; Stripe rejection-fallback
- [HubSpot forms can only populate Contact / Company / Ticket](hubspot-form-architecture-contact-not-deal.md) — never Deal; lead detail on Contact (the *person*), workflow creates Deal and associates
- [HubSpot Forms API direct-fetch relay pattern](hubspot-forms-api-relay-pattern.md) — Plan B beats Plan A; deterministic field map > auto-detection; capture-phase listener, keepalive POST, no preventDefault
- [Hookify rule — session-end-required on Stop](../../../.claude/hookify.session-end-required.local.md) — defense-in-depth backup to `templates/scripts/session-end.ps1`; both fire on Stop, neither fires if Stop never triggers (Esc/force-quit)

## Reference (where to look things up)
- [State files to read each session](reference_state_files.md) — MEMORY.md, CLAUDE.md, phase-1-plan, agent memories
- [9 specialist agents — direct reports](reference_specialist_agents.md) — who owns what, how to delegate
- [Key business docs](reference_docs.md) — strategy, website, legal, ops, marketing, financial, system IDs
