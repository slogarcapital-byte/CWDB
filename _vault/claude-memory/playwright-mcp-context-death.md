---
title: playwright mcp context death
type: memory
memory_type: reference
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/playwright-mcp-context-death.md
tags:
  - type/memory
  - memory/reference
---
# Playwright MCP — Browser Context Dies on Idle

**Symptom:** First `browser_navigate` or `browser_snapshot` call after any idle period (including a fresh agent session) fails silently with:

> Target page, context or browser has been closed.

The error is NOT recoverable by retrying the same call. The browser/page handle is dead and must be reinitialized.

## Working pattern — always run at start of any Playwright-MCP session

```
1. mcp__plugin_playwright_playwright__browser_close            # safe even if no browser is running
2. mcp__plugin_playwright_playwright__browser_navigate("about:blank")
3. mcp__plugin_playwright_playwright__browser_resize(1280, 800)
4. Then navigate to real URLs
```

## Mid-run recovery

If the same error reappears mid-audit (long gap between calls, network hiccup, MCP server restart), repeat the close → about:blank → resize cycle before the next real navigation. Do NOT silently skip the affected step — the snapshot is the audit deliverable.

## Escalation

If the close+reopen cycle fails 3+ times in a row, stop the run and flag. Something is wrong beyond idle-death — possibly the MCP server itself, a proxy issue, or a stale host binary.

## Confirmed

- 2026-04-21 — Phase 4 staging audit run; pattern documented and verified working for 17-URL sweep on staging.
