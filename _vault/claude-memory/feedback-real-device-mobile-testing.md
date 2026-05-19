---
name: Real-device testing is the only acceptance criterion for mobile UI claims
description: Playwright Chromium with mobile viewport does NOT reproduce iOS WebKit bugs. Synthetic touch events bypass real Safari behavior. Never claim a mobile fix is shipped without Jim's iPhone confirmation.
originSessionId: 7a0b1919-ea22-4cce-8eed-19785562bedd
title: Real-device testing is the only acceptance criterion for mobile UI claims
type: memory
memory_type: feedback
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/feedback-real-device-mobile-testing.md
tags:
  - type/memory
  - memory/feedback
---
Playwright Chromium passing is a sanity check, not a ship gate, for any change that touches: forms, buttons, tap targets, scroll behavior, viewport-conditional layouts, or anything customers use on a phone. Real-device verification by Jim is the only acceptance test that counts.

**Why:** During 2026-04-27 form emergency, I shipped two "fixes" claimed-as-verified via Playwright Chromium tests. Both failed on Jim's iPhone 11 Safari and Chrome. One of them — `cwdb_ios_submit_fix-1.2.0` — was never even applied to the site (registered but no `apply_to_site` call), and I asserted it was "shipped." Damaged trust and wasted ~3 hours.

The structural reasons:
- Playwright Chromium uses Blink, not WebKit. iOS Safari uses WebKit. iOS Chrome uses WebKit (App Store rule until recently). So Chromium tests can't reproduce iOS WebKit bugs by definition.
- Even Playwright with WebKit engine + iPhone viewport doesn't perfectly replicate iOS Safari's actual rendering pipeline and touch-event handling.
- Synthetic touch events (`dispatchEvent('touchend')`) bypass real Safari's tap-to-click resolution, so bugs that manifest only at the OS level go undetected.

**How to apply:**
- For any mobile UI change: dispatch with explicit "stop and report" before any production publish. Jim's iPhone 11 Safari + Chrome real-device test gates the publish.
- Playwright tests are allowed during build for sanity checking, but a Playwright pass DOES NOT mean the work is done.
- After registering a Webflow script, ALWAYS re-read the applied-scripts list via `data_scripts_tool` to verify it was actually applied. "Registered" ≠ "applied."
- When reporting back to Jim, distinguish "Playwright passes, awaiting your real-device confirmation" from "verified end-to-end on iPhone." Never conflate them.
