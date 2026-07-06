---
name: Always steer back to the most elegant approach
description: When work is heading down a manual / click-through / step-by-step path and a bulk-import / CSV / API / Editor / scripted path exists, propose the elegant path proactively — don't wait to be asked
type: feedback
originSessionId: fa9cfbd6-9de3-4868-9fc9-f7a70658d170
---
When Jim is about to execute work the manual way (clicking through a UI, copy-pasting one field at a time, repeating a step N times), and a bulk / templated / scripted alternative exists for that platform — **propose the elegant path before serving the manual one.** Even if Jim asked for "step by step copy-paste," check whether bulk import is available first. If yes, lead with it.

**Why:** Jim called this out 2026-04-22 after I served him a 30-step Google Ads click-through workflow when Google Ads supports CSV bulk-upload via Editor (and he had already downloaded the templates). His exact words: *"you should always steer the conversation back to the most elegant approach if you notice us headed down a sub-optimal path."* This is a standing instruction.

**How to apply:**
- Before serving any multi-step manual workflow, ask: "Is there a bulk-import / scripted / API path for this?" If yes, propose it.
- Specifically for ad platforms: Google Ads has Editor + CSV bulk upload; Meta Ads has Ads Manager bulk import + the marketing API; LinkedIn has Campaign Manager bulk; Nextdoor has limited bulk but does have CSV for audiences.
- Specifically for Webflow: prefer MCP component_builder + bulk CMS imports over per-element clicks.
- Specifically for HubSpot: prefer MCP `manage_crm_objects` batched calls over manual record creation.
- Specifically for DocuSign: prefer template + bulk-send over individual envelope creation.
- If Jim explicitly chooses the manual path *after* I've proposed the elegant one, fine — proceed manually. The standing rule is to *propose* the elegant path, not force it.
- If you've already started serving the manual path and realize an elegant path exists, stop and re-propose. Don't sunk-cost.
