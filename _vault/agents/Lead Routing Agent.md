---
type: agent
agent-id: lead-routing
department: operations
domain:
  - lead-delivery
  - make-automation
  - notifications
reports-to: "[[Jim Slogar]]"
memory-path: .claude/agent-memory/lead-routing/
tags:
  - type/agent
  - agent/lead-routing
  - dept/operations
aliases:
  - lead-routing
  - Agent 5
created: 2026-03-11
updated: 2026-04-16
status: active
---

# Lead Routing Agent

Delivers qualified leads to contractors via [[Make]] automation with SMS/email notifications.

## Responsibilities
- Route leads based on territory
- Handle multi-contractor distribution
- Trigger SMS and email notifications
- Manage [[Make]] scenarios

## Key Files
- **Prompt:** `.claude/agents/lead-routing.md`
- **Memory:** `.claude/agent-memory/lead-routing/MEMORY.md`
- **Routing Rules:** `/operations/leads/routing-rules.json`
- **Webhooks:** `/operations/make/webhooks.json`
- **SMS Template:** `/operations/automation/twilio-sms-template.md`

## Current State
[[Make]] scenario not built yet. Routing rules defined but contractor slots vacant.

## Prompt (live)
![[claude/agents/lead-routing]]

## Agent Memory (live)
![[claude/agent-memory/lead-routing/MEMORY]]
