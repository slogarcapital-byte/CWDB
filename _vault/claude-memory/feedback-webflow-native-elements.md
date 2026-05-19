---
name: Webflow — prefer native elements over custom HTML
description: When building Webflow pages for CWDB, always use native Webflow elements (forms, CMS, interactions) instead of custom HTML embeds. It's acceptable to pause and ask the user to do steps manually if it results in a CMS-manageable site.
title: Webflow — prefer native elements over custom HTML
type: memory
memory_type: feedback
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/feedback-webflow-native-elements.md
tags:
  - type/memory
  - memory/feedback
---
Always use native Webflow elements instead of custom HTML embeds when both can accomplish the goal.

**Why:** Custom HTML elements (especially forms) caused a broken, unmanageable result that required manual cleanup. The user needs a site they can maintain through the Webflow CMS without code — custom HTML breaks that workflow.

**How to apply:** For any Webflow task — forms, sliders, tabs, galleries, nav, CMS collections — default to native Webflow elements. If a requirement would force a custom HTML embed, stop and ask the user to handle that step manually in the Webflow designer rather than generating HTML that bypasses the CMS. Never embed raw HTML when a Webflow-native component exists, even if the native approach requires more setup steps.
