---
name: Heavy copy-paste workflows ship as spreadsheets, not prose walkthroughs
description: When a manual UI task involves many discrete paste-values (ad copy fields, form fills, config setup across many fields), deliver it as a CSV/spreadsheet with isolated paste columns — not as a numbered-steps prose document with fenced code blocks
type: feedback
originSessionId: fa9cfbd6-9de3-4868-9fc9-f7a70658d170
---
**For any task that is primarily heavy copy-paste into a UI, default to delivering a CSV/spreadsheet — not a prose walkthrough.** Jim's preferred format for this class of work going forward.

**Why:** Jim confirmed 2026-04-23 after I served a 41-step manual Meta Ads walkthrough in prose form. Prose walkthroughs require him to scroll back and forth in chat, hunt for the fenced block that has the next value to paste, and re-locate his place after switching to the target UI. Spreadsheet format means:
- One row per paste-value, cell-copyable directly (Ctrl+C on the cell vs Ctrl+C on markdown inside a fenced block)
- No scrolling to find the next value — it's just the next row
- Jim can tick off completed rows visually as he works
- The "action" column stays short and scannable; the "value" column stays clean
- Works equally well in Excel and Google Sheets

**How to apply:**
- When a task has ≥10 discrete paste-values to put into a UI, deliver a CSV
- Suggested column schema: `Step` · `Section` · `Action / Field` · `Value to Paste` · `Notes`
- For lists (e.g., 10 interests to add one at a time), give each list item its own row — don't batch them into one cell
- Save the CSV into the work folder (e.g., `marketing/launch-2026-04/bulk-upload/`) so it's discoverable
- Still provide a short chat preamble explaining structure + the file path, but the detailed walkthrough lives in the CSV
- Prose walkthrough is fine for decisions, explanations, or tasks with <10 paste-values; the rule is for heavy-paste UI work specifically

**Canonical examples of tasks this applies to:**
- Ad platform UI config (Meta, Google Ads extensions, LinkedIn, Nextdoor)
- HubSpot pipeline/property setup via UI
- Webflow Designer actions Jim has to hand-do
- Form-filling across many fields (legal, banking, insurance applications)
- DocuSign template field configuration
- CRM import or onboarding wizards

**Tasks where prose is still correct:**
- Single-decision / high-context questions
- Explaining architecture or tradeoffs
- Debugging and root-cause narratives
- Bulk-upload CSV creation (the CSV IS the artifact — no walkthrough needed)
