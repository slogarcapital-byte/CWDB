---
name: State file is merged, not regenerated — Jim's marks are authoritative
description: When updating _vault/state-of-cwdb.md, the prior archived snapshot is input. Jim's [x] and %...% comments must be honored and verified — never wiped.
originSessionId: f4e90ffd-e4df-4d8a-b487-b45ec9ca0acd
title: State file is merged, not regenerated — Jim's marks are authoritative
type: memory
memory_type: feedback
created: 2026-04-30
updated: 2026-04-30
source: C:/Users/jslog/.claude/projects/C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB/memory/feedback-state-file-merge-protocol.md
tags:
  - type/memory
  - memory/feedback
---
When running `/state`, `/brief`, or the state-file update step of `/session-end`, the state file must be **merged** against the previous snapshot — never regenerated from scratch.

**Why:** Prior workflow treated `_vault/state-of-cwdb.md` as fully derived output. Each regeneration re-surfaced items Jim had already marked `[x]` and lost the rationale on `[Decide]` items. Jim called this out 2026-04-21: "there doesn't seem to be any lookback at previous approvals/completions… I just want to see the stuff that hasn't been completed yet." The archive folder + merge protocol is the fix.

**How to apply:**

1. Before writing any new state file, read the latest snapshot in `_vault/state-archive/` (files sort chronologically by filename).
2. Walk every item in §3 Jim's Queue:
   - `[x]` on a `[Do]` item → verify completion against repo / memory / MCP / session notes. If verified, **drop** the item and append a one-liner to §9 Recent Wins. If unverified, keep the item and raise a note in the Outbox asking Jim for evidence.
   - Non-empty `%...%` on a `[Do]` item → read as verification context (blocker, evidence pointer, status).
   - Non-empty `%...%` on a `[Decide]` item → classify as **decision** (act, drop, log to §9), **deferral** (keep in-queue with Jim's note preserved, Outbox reminder on the date), or **question** (keep, resolve in Outbox).
3. Write the new snapshot to `_vault/state-archive/state-<current-session-id>.md`.
4. Mirror the snapshot over `_vault/state-of-cwdb.md` so downstream tools (MEMORY.md pointer, MOC, vault-sync) keep working.
5. Every new `[Do]` or `[Decide]` item CEO writes must include a `  - Jim's note: %%` sub-bullet so Jim has a place to annotate on his next pass.

**Guardrails:**
- Never drop a `[Do]` item without positive evidence. "It's probably done" ≠ verified.
- Deferral comments on `[Decide]` items keep the item visible every session — nothing slips through. Jim's Queue is the visibility contract.
- Never re-surface an item Jim has already resolved. Check the prior snapshot first.
- Historical snapshots in `_vault/state-archive/` are read-only. Never edit or delete.
