---
description: Refresh the Obsidian vault's RAG mirror — sync Claude memory copies, detect new agents, verify the claude/ junction
---

Run a full sync pass on the CWDB Obsidian vault so it stays an accurate RAG mirror of the project.

## What to do

### 1. Refresh `_vault/claude-memory/` with frontmatter + wikilink rewriting

Run the sync script:

```
powershell -File templates/scripts/vault-sync.ps1
```

What it does for each `.md` in the source memory dir:
- Injects Obsidian frontmatter (`type: memory`, `memory_type: <user|feedback|project|reference|workflow|index>`, `tags: [type/memory, memory/<type>]`, `source: <canonical path>`, `title`, `created`, `updated`)
- Preserves any existing source fields (`name`, `description`, `originSessionId`, etc.)
- Rewrites `[text](file.md)` → `[[basename|text]]` so Obsidian graph view picks up links
- Idempotent — skips write when content matches modulo the `updated:` line
- Reports counts (written / unchanged) and orphans (files in dest not in source)
- Writes `.last-sync` timestamp marker

Source: `C:\Users\jslog\.claude\projects\C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB\memory\`
Destination: `_vault/claude-memory/` (inside the CWDB project)

Do NOT delete orphan files in the destination automatically — report them so the user can decide.

After the script runs, update `_vault/claude-memory/_README.md`'s `updated:` frontmatter field to today's date.

### 2. Detect new agents without vault stubs
List every `.md` file in `.claude/agents/`. For each agent ID, check whether a matching `_vault/agents/*.md` stub exists. Mapping rule: strip the `.md` from the agent filename and look for a stub whose `agent-id:` frontmatter value matches.

For any agent without a stub, propose creating one (template: see existing stubs in `_vault/agents/`). Do not auto-create — ask the user first since agent vault notes include hand-written descriptions and responsibilities.

### 3. Detect agents without agent-memory stubs on their vault notes
For each `_vault/agents/*.md`, confirm it contains two transclusion blocks at the end:
- `![[claude/agents/<agent-id>]]`
- `![[claude/agent-memory/<agent-id>/MEMORY]]`

If missing, append them.

### 4. Verify the `_vault/claude` junction still points at `.claude`
Run `Get-Item _vault/claude | Select-Object Target` (PowerShell) or check with `dir` that the junction resolves. If broken, re-create:
```
New-Item -ItemType Junction -Path '<CWDB>\_vault\claude' -Target '<CWDB>\.claude'
```

### 5. Report
Output a concise summary:
- How many memory files were refreshed (and any orphans in the destination)
- Any agents missing vault stubs
- Any vault stubs missing transclusion blocks
- Junction health (OK / broken and re-created / failed)

Do not touch `_vault/sessions/` — session notes are managed by SessionStart/Stop hooks.
