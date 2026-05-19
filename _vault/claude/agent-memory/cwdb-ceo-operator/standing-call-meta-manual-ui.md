---
name: Standing call — Meta launch is manual UI process
description: CWDB Meta Ads launch is manual via UI per Jim's standing call (2026-04-27); bulk-import path is NOT in play
type: feedback
---

Meta launch is manual UI process per Jim's standing call (2026-04-27).

**Why:** Jim wrote "remove. decided on manual process. you should know that from the files you created." in response to a queue item asking him to retry the bulk-upload CSV edit at `marketing/launch-2026-04/bulk-upload/meta-manual-ui-walkthrough.csv`. The reference doc itself signals the decision — manual UI walkthrough was the chosen path. The bulk-import retry was queued from an outdated state where bulk was still on the table.

**How to apply:**
- Reference doc: `marketing/launch-2026-04/04-meta-copy.md` (manual UI walkthrough is the canonical path).
- Do NOT surface the Meta bulk-import option in the queue, Outbox, or recommendations. It's not the chosen path.
- The CSV at `marketing/launch-2026-04/bulk-upload/meta-manual-ui-walkthrough.csv` is reference material, not an action item — do not queue retries on its content edits.
- When Meta launch resumes (post Google clean-data confirmation per WS-1 sequencing), surface the manual UI walkthrough doc, not the bulk-import path.
