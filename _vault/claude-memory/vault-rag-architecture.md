---
name: Vault RAG architecture
description: How the CWDB Obsidian vault mirrors project content — junction + transclusions + memory copy — so future sessions don't re-diagnose "missing folders"
type: reference
originSessionId: 11c51573-e6a8-4e9f-a093-cf492020737f
---
# CWDB Obsidian Vault — RAG Architecture

The CWDB project directory IS the Obsidian vault (`.obsidian/` sits at the CWDB root). Inside it, `_vault/` holds the curated knowledge graph. The vault is wired to mirror project content as follows:

## Structure

```
CWDB/                        ← vault root
├── .obsidian/               ← vault config
├── .claude/                 ← real agent prompts, commands, skills, agent-memory (hidden by Obsidian)
├── _vault/
│   ├── agents/              ← 12 agent stubs with ![[claude/agents/X]] + ![[claude/agent-memory/X/MEMORY]] transclusions
│   ├── claude/              ← JUNCTION → ../.claude/  (makes .claude visible to Obsidian under a non-dot path)
│   ├── claude-memory/       ← COPIES of ~/.claude/projects/.../memory/*.md (refreshed by /vault-sync)
│   ├── departments/         ← 8 hub notes for website/sales/marketing/ops/finance/business-context/branding/docs
│   ├── sessions/            ← auto-created by SessionStart hook, closed by Stop hook
│   ├── decisions/, entities/, phases/, people/, markets/, platforms/, products/, canvases/
├── website/, sales/, marketing/, operations/, finance/, business-context/, branding/, docs/  ← dept source folders
```

## Key Mechanics

- **Directory junction** at `_vault/claude/` points to `../.claude/`. Created via `New-Item -ItemType Junction` in PowerShell. Makes agent prompts, agent-memory, commands, and skills indexable and browsable inside Obsidian without renaming or showing dot-folders.
- **Transclusions** in agent stubs embed the real prompt + memory content live via `![[claude/agents/<id>]]` and `![[claude/agent-memory/<id>/MEMORY]]`. Single source of truth stays in `.claude/`.
- **Memory mirror** at `_vault/claude-memory/` is a *copy* of the global Claude memory dir (which lives OUTSIDE the vault under `~/.claude/projects/.../memory/`). Not a junction because that dir is outside OneDrive and mixing junctions across OneDrive boundaries can cause sync weirdness.
- **`/vault-sync` slash command** refreshes memory copies, detects new agents without vault stubs, and verifies the junction.

## When to use what

- To read an agent prompt → open the `_vault/agents/<Name> Agent.md` stub in Obsidian; transclusion renders the full prompt inline.
- To search across all agent prompts, commands, and skills → Obsidian global search works because the junction exposes them under `_vault/claude/`.
- To read current global memory inside Obsidian → `_vault/claude-memory/*.md` (but remember: source of truth is the global dir; run `/vault-sync` before assuming the mirror is fresh).
- To add a new agent → create the real prompt in `.claude/agents/<id>.md`, then create a matching `_vault/agents/<Name> Agent.md` stub with frontmatter + transclusion blocks.

## Built / Changed
- 2026-04-18: Junction + transclusions + memory mirror + 8 dept hubs + `/vault-sync` command all created. Plan: `~/.claude/plans/delightful-purring-puffin.md`.
