---
title: Brain — Home
aliases: [MOC, Home, Brain Home]
tags:
  - type/moc
type: moc
status: active
created: 2026-04-21
updated: 2026-04-21
---
# Brain — Home

Navigational hub for the CWDB Obsidian vault. For daily operational work start at `[[state-of-cwdb|State of CWDB]]`; use this page when you need to jump somewhere specific.

## Daily
- [[state-of-cwdb|State of CWDB — operational dashboard]] — Inbox/Outbox, Decisions Needed, Manual Actions Queue, KPI thresholds
- [[INDEX|Sessions Index]] — chronological session log

## Memory
- `_vault/claude-memory/MEMORY` — mirrored auto-memory index (synced by `/vault-sync`)
- `_vault/claude-memory/` — full memory mirror (synced from `~/.claude/projects/<hash>/memory/`)
- `_vault/claude/` — live Windows junction to the hidden `.claude/` folder

## Departments
- [[Website Department]]
- [[Sales Department]]
- [[Marketing Department]]
- [[Operations Department]]
- [[Finance Department]]
- [[Business Context]]
- [[Branding]]
- [[Docs]]

## Agents
- `_vault/agents/` — 13 agent stubs with live transclusions of prompt + memory

## Domains
- `_vault/decisions/` — decision log
- `_vault/people/` — contacts, contractors, team
- `_vault/markets/` — target cities, competitive landscape
- `_vault/platforms/` — Webflow, HubSpot, Make, Google Ads, Meta, Nextdoor
- `_vault/products/` — lead SKUs, pricing
- `_vault/phases/` — phase 1/2/3/4 plans
- `_vault/canvases/` — JSON Canvas visual maps

## Maintenance
- `/vault-sync` — refresh memory mirror, verify junction, detect new agents
- `/state` — force-refresh `state-of-cwdb.md`
- `/brief` — morning briefing (reads state file, processes Inbox)
- `/session-end` — populate current session note before Stop
