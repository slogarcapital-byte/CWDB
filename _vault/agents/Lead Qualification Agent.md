---
type: agent
agent-id: lead-qualification
department: operations
domain:
  - lead-scoring
  - spam-filtering
  - data-validation
reports-to: "[[Jim Slogar]]"
memory-path: .claude/agent-memory/lead-qualification/
tags:
  - type/agent
  - agent/lead-qualification
  - dept/operations
aliases:
  - lead-qualification
  - Agent 4
created: 2026-03-11
updated: 2026-04-16
status: active
---

# Lead Qualification Agent

Validates lead quality, filters spam, and ensures contractors receive high-quality homeowner leads.

## Responsibilities
- Validate lead data (name, address, phone, project type, budget, timeline)
- Filter spam submissions
- Confirm homeowner intent
- Score leads using rules at `/operations/leads/scoring-rules.json`

## Key Files
- **Prompt:** `.claude/agents/lead-qualification.md`
- **Memory:** `.claude/agent-memory/lead-qualification/MEMORY.md`
- **Scoring Rules:** `/operations/leads/scoring-rules.json`
- **Form Fields:** `/operations/leads/quote-form-fields.json`

## Persona Target
[[Homeowner]] — validates they are a real homeowner with a genuine deck project

## Prompt (live)
![[claude/agents/lead-qualification]]

## Agent Memory (live)
![[claude/agent-memory/lead-qualification/MEMORY]]
