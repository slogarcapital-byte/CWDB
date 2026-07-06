---
name: session-end
description: Summarize the current Claude Code session and create/update an Obsidian session note in _vault/sessions/. Chains to previous session for persistent memory.
---

# Session End — Obsidian Session Summary

Create a session summary note that chains to previous sessions for persistent memory across conversations.

## Steps

### 1. Determine Session ID
- Format: `YYYY-MM-DD-NNN` where NNN is a zero-padded sequence number
- Check `_vault/sessions/` for existing files with today's date
- Increment the sequence number (001, 002, etc.)

### 2. Find Previous Session
- Glob `_vault/sessions/*.md` sorted by modification time
- Read the most recent session note
- This becomes the `previous-session` link

### 3. Create/Update Session Note
Write to `_vault/sessions/<session-id>.md` with this structure:

```yaml
---
type: session
session-id: "<session-id>"
agents-used: [<list agents invoked this session>]
topics: [<2-4 word topic summaries>]
decisions-made: [<links to any decision notes created>]
files-changed: [<key files created or modified>]
previous-session: "[[<previous-session-id>]]"
next-session: ""
duration-minutes: <estimated>
tags:
  - type/session
  - session/<YYYY-MM>
created: <today>
updated: <today>
status: complete
---
```

### 4. Write Summary Content
Fill in these sections based on the conversation:

- **Context** — What was the goal of this session?
- **Work Done** — Bullet list of accomplishments
- **Decisions Made** — Key decisions with links
- **Open Items** — What's unfinished
- **Agent Activity** — Which agents ran and what they did
- **Memory Updates** — What was saved to agent memory or project memory
- **Next Session** — Suggested next actions

### 5. Update Previous Session
Edit the previous session note to set its `next-session` field to the current session ID.

### 6. Update Agent Memory
If any agent memory files need updating based on session work, update them now.

### 7. Seal today's daily brief

Today's brief lives at `_vault/briefs/<today>.md` (composed earlier by `/brief`). At session end, **seal it** so it becomes immutable history and tomorrow's brief can be forward-chained from it.

If `_vault/briefs/<today>.md` exists:

1. Open it and flip the frontmatter `status: active` → `status: sealed`. Touch nothing else (preserve all `[x]` marks, `%...%` comments, and section bodies exactly as written).
2. If today's brief has no `next` value populated yet, leave it empty — tomorrow's `/brief` will set it when the next-day brief is composed.

If today's brief does not exist (no `/brief` was run today):
- Skip sealing. Note in the report that no brief was sealed because none was composed today.
- Do NOT auto-create a placeholder brief at session-end. The morning ritual owns brief creation.

The `_vault/state-of-cwdb.md` singleton has been deleted (2026-06-05). Business-state source of truth is the Supabase warehouse. Write the dated session snapshot to `_vault/state-archive/state-<sessionId>.md` as a historical record only.

### 8. Trigger CEO end-of-session memory ritual

Dispatch the `cwdb-ceo-operator` agent (or run inline if the CEO has been the active agent this session) with this directive:

> Run your **end-of-session memory ritual**. Write 0–3 NEW memory entries to `.claude/agent-memory/cwdb-ceo-operator/` based on what you learned this session. Each entry must answer: "What did I learn today that future-CEO must remember?"
>
> - Categories: feedback, project, reference, user (per the agent's memory protocol).
> - For each new entry, write a memory file with proper frontmatter and add a one-line pointer to `.claude/agent-memory/cwdb-ceo-operator/MEMORY.md`.
> - If you write 0 entries, justify why in today's brief's "CEO Memory Updates" section (e.g., "no durable learning this session — all work was routine execution of known patterns").
>
> Report back the list of memory files written (paths) or the justification for writing none.

### 9. Report
Tell the user:
1. Session note created at `_vault/sessions/<session-id>.md` with <N> agents used, <M> decisions logged
2. Brief sealed at `_vault/briefs/<today>.md` (status flipped to `sealed`) — or noted as skipped if no brief was composed today
3. CEO memory ritual: <N> new memory entries written to `.claude/agent-memory/cwdb-ceo-operator/` (list paths) or justification for zero
4. Linked to previous session [[<previous-session-id>]]

Do NOT `git add` or commit — Jim handles staging himself.
