---
name: session-end-required
enabled: true
event: stop
pattern: .*
action: warn
---

**Stop event detected — Session note populator check.**

Before this conversation ends, ensure today's session note in `_vault/sessions/YYYY-MM-DD-NNN.md` has a populated `## Work Done` section. If it does not:

1. Invoke the session-end skill via the Skill tool (`skill: session-end`).
2. The skill will populate Work Done, Decisions Made, Memory Updates, Open Items, Agent Activity, and Next Session from this conversation's actual work.
3. The skill will also write the dated state-archive snapshot and mirror it to `_vault/state-of-cwdb.md`.

This rule is the deterministic backstop on top of `templates/scripts/session-end.ps1` (which also fires on Stop and issues a hard `decision: block` if Work Done is empty). The PowerShell hook is the primary enforcement; this hookify rule is the secondary reminder so the skill invocation is unmistakable.

**Note for Jim:** This rule fires only when Stop is triggered (a clean session end). If a session ends via force-quit, Esc, or crash before Stop fires, neither this rule nor the PowerShell hook can run — the next session's `/brief` will detect the empty note and the next `/session-end` can be invoked manually for that prior date if recovery is wanted.
