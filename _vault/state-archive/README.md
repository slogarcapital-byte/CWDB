---
type: readme
title: State Archive
created: 2026-04-21
updated: 2026-04-21
tags:
  - type/readme
  - state-archive
---

# State Archive

This folder holds a dated snapshot of `_vault/state-of-cwdb.md` for every `/state`, `/brief`, and `/session-end` run. Snapshots are **read-only history**. The root `_vault/state-of-cwdb.md` is always a byte-for-byte copy of the latest file in this folder.

## Naming

```
state-<session-id>.md
```

Session IDs follow the existing `_vault/sessions/` convention: `YYYY-MM-DD-NNN`, where `NNN` is the zero-padded run counter for the day. Filenames are chronologically sortable — the newest file is always the last one by alphabetical order.

Example:
- `state-2026-04-21-011.md` — state at the end of run 011 on 2026-04-21
- `state-2026-04-21-012.md` — state at the end of run 012 on 2026-04-21
- `state-2026-04-22-001.md` — first run of 2026-04-22

## Merge protocol (why this folder exists)

Before the archive pattern, each `/state` or `/brief` run regenerated the state file from memory + session notes, wiping Jim's checkboxes and approvals. The archive exists so the **previous snapshot is authoritative input** to the next regeneration.

Every run, the CEO operator:

1. **Reads** the latest file in this folder (= prior snapshot).
2. **Merges** Jim's marks against evidence:
   - `[x]` on a `[Do]` item + verifiable evidence → **drop** from Jim's Queue; log to §9 Recent Wins.
   - `[x]` on a `[Do]` item + no evidence → **keep** item checked; add Outbox line asking Jim for evidence.
   - Non-empty `%...%` comment on a `[Do]` item → read as verification context (e.g., "blocked on X" or "done, tested at 14:22").
   - Non-empty `%...%` comment on a `[Decide]` item — classify:
     - **Decision made** → drop item, act on it, log to §9 Recent Wins.
     - **Deferral** (e.g., `%hold until 04-30%`) → **keep in queue with Jim's note preserved**, add dated Outbox reminder.
     - **Question back** → keep item, treat as Inbox, resolve in Outbox.
3. **Writes** the new snapshot to `state-<current-session-id>.md`.
4. **Mirrors** the new snapshot over `_vault/state-of-cwdb.md` so tools reading the singleton keep working.

## Conventions for Jim's Queue items

Every `[Do]` and `[Decide]` item in §3 carries a comment sub-bullet:

```markdown
- [ ] `[Do]` Verify Webflow form → email notification delivery
  - Jim's note: %%
- [ ] `[Decide]` Approve ad-launch brief
  - Jim's note: %%
```

- Empty `%%` = no input from Jim yet → carry forward unchanged.
- Non-empty `%text%` = Jim's input → CEO reads and honors.

## What to never do

- **Never edit a historical snapshot.** They are the audit trail.
- **Never delete a snapshot.** Space is cheap; history is load-bearing.
- **Never bypass the mirror.** If you edit the singleton, also write the same content to a new dated snapshot (or the mirror will drift from history).
