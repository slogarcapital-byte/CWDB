---
type: agent
agent-id: web-dev
department: website
domain:
  - webflow
  - landing-pages
  - conversion
reports-to: "[[Jim Slogar]]"
memory-path: .claude/agent-memory/web-dev/
tags:
  - type/agent
  - agent/web-dev
  - dept/website
aliases:
  - web-dev
  - Agent 2
  - Landing Page Builder
created: 2026-03-11
updated: 2026-04-16
status: active
---

# Web Dev Agent

Builds and maintains the [[Webflow]] website for [[Central Wisconsin Deck Builders LLC]].

## Responsibilities
- Build landing page structure in [[Webflow]]
- Optimize conversion flow and CTA messaging
- Manage 21-page authority site
- Component-first section building

## Key Files
- **Prompt:** `.claude/agents/web-dev.md`
- **Memory:** `.claude/agent-memory/web-dev/MEMORY.md`
- **Design System:** `/website/design-system.md`
- **Site Architecture:** `/website/site-architecture.md`

## Build Progress
Phases A–E complete. Phase F (SEO & analytics) pending.

## Key Rules
- [[Webflow]] MCP first, then sync local HTML
- Every section must be a named component
- 3-tier hierarchy: edit properties → copy+rename → build net new
- CMS for repeating content
- Native forms only (no Tally)

## Prompt (live)
![[claude/agents/web-dev]]

## Agent Memory (live)
![[claude/agent-memory/web-dev/MEMORY]]
