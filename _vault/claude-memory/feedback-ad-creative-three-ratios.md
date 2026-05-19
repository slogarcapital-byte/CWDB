---
name: Ad creatives — always produce 1:1, 9:16, and 16:9
description: Every ad-campaign batch on every platform (Meta, Google, Nextdoor, TikTok, YouTube) must ship all three master ratios. Standing rule.
originSessionId: 37853590-4161-4f21-a7ce-ef5a8870c928
title: Ad creatives — always produce 1:1, 9:16, and 16:9
type: memory
memory_type: feedback
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/feedback-ad-creative-three-ratios.md
tags:
  - type/memory
  - memory/feedback
---
# Ad creatives — always produce 1:1, 9:16, and 16:9

For every angle / variant / refresh, the ad-campaign agent must produce the creative in **all three master aspect ratios**:

| Ratio | Pixel master | Primary use                                          |
| ----- | ------------ | ---------------------------------------------------- |
| 1:1   | 1080 × 1080  | Meta feed, IG feed, Nextdoor feed, Google Display square |
| 9:16  | 1080 × 1920  | IG/FB Stories, IG/FB Reels, TikTok, YouTube Shorts   |
| 16:9  | 1920 × 1080  | YouTube, Google Display landscape, FB in-stream      |

**Why:** Jim's standing rule (2026-04-26). Locks a consistent master set across platforms so every future placement is a crop, not a redesign. Avoids the past pattern of producing only 1:1 + 4:5 (Meta-optimized vertical) and getting stuck without Stories/Reels/TikTok-native vertical.

**How to apply:**
- When generating a batch of creatives for any new angle, produce all 3 ratios per angle, not 2.
- File naming pattern: `<angle>-<ratio>.html` / `.png` / `-notes.md` (e.g. `problem-solution-1080x1080.html`, `problem-solution-1080x1920.html`, `problem-solution-1920x1080.html`).
- Drop into the campaign's `creatives/<platform>/` folder. If a creative is platform-agnostic (same art, different crop), keep it under one platform folder and reference it from others rather than duplicating files.
- 4:5 (1080×1350) and 1.91:1 (1200×628) are NOT replacements for these — they're optional secondary crops if a specific placement requires them. The 3 masters above are mandatory.
- If the user explicitly says "1:1 only" or "skip vertical," override this rule for that batch — but default is always all three.
- Apply the /impeccable craft → critique → polish → extract loop to all three ratios, not just the first one. Visual hierarchy must hold at each aspect.
