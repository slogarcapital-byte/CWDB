---
description: Populate the day's Obsidian session note with Work Done, Decisions Made, and Memory Updates from the current conversation
---

Invoke the `session-end` skill (via the Skill tool, `skill=session-end`) and follow it to populate today's `_vault/sessions/YYYY-MM-DD-NNN.md` note based on the current conversation.

Rules:
- Do NOT create a new session note. The SessionStart hook already created today's file. Find the highest-numbered `YYYY-MM-DD-*.md` in `_vault/sessions/` and update it in place.
- Preserve existing frontmatter; only fill empty arrays (`agents-used`, `topics`, `decisions-made`, `files-changed`).
- Populate the six body sections: Context, Work Done, Decisions Made, Open Items, Agent Activity, Memory Updates, Next Session.
- Draw from this conversation's actual work — what tools were called, what files were edited, what decisions were reached, what agents were dispatched. Do not invent content.
- Leave `status: in-progress` as-is. The Stop hook flips it to `complete` after you finish.
- Also update the previous day's session note's `next-session` frontmatter field to point at today's session ID if it's currently empty.
