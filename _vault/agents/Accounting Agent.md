---
type: agent
agent-id: accounting
department: finance
domain:
  - billing
  - invoicing
  - pl-statements
reports-to: "[[Jim Slogar]]"
memory-path: .claude/agent-memory/accounting/
tags:
  - type/agent
  - agent/accounting
  - dept/finance
aliases:
  - accounting
  - Agent 8
created: 2026-03-11
updated: 2026-04-16
status: active
---

# Accounting Agent

Tracks contractor payments, reconciles ad spend vs. revenue, and produces monthly P&L statements.

## Responsibilities
- Track contractor payments and billing cycles
- Generate and send invoices
- Reconcile ad spend vs. revenue
- Produce monthly P&L statements

## Key Files
- **Prompt:** `.claude/agents/accounting.md`
- **Memory:** `.claude/agent-memory/accounting/MEMORY.md`
- **P&L Output:** `/finance/pl/`
- **Reports:** `/finance/reports/performance/`

## Current State
No invoices sent. No revenue yet. Pre-launch phase.

## Prompt (live)
![[claude/agents/accounting]]

## Agent Memory (live)
![[claude/agent-memory/accounting/MEMORY]]
