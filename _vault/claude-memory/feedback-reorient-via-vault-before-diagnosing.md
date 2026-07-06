---
name: feedback-reorient-via-vault-before-diagnosing
description: "Before diagnosing any CWDB issue, read prior briefs + state-archive + agent-memory + raw platform data first — do not rely on recon-agent summaries or stale MEMORY.md"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d7ccfc8a-fa04-45b2-9345-9c80e9d4d28b
---

When opening a session in CWDB after a multi-day gap, fully reorient via primary sources before forming any diagnostic hypothesis or asking the user questions. Specifically:

1. List + read the last 5-10 daily briefs in `_vault/briefs/` (date-stamped filenames).
2. Read the most recent `_vault/state-archive/state-<session-id>.md`.
3. Read `agents/agent-memory/cwdb-ceo-operator/` for any pivot memos or context-shifts.
4. Pull raw data from the operational systems (HubSpot via MCP, Webflow Forms log, ad platform UIs) — don't trust subagent summaries.
5. Read `MEMORY.md` knowing it's potentially stale.

**Why:** 2026-05-19 session — Jim caught me running a diagnostic for "lead-flow cliff" based on a recon-agent summary that mischaracterized the 2026-05-05 "5-lead burst." The reality (per Jim): those 5 entries were a combination of real form submits AND ad-driven phone calls that Jim manually logged because Webflow→HubSpot relay wasn't wired yet at that point. The recon agent labeled them "manual entries" based on HubSpot source labels alone, missing the operational context. Worse, Jim said "form submissions were definitely occurring from ads in the past — at least 3" — meaning real lead history was being overlooked.

Operating on summary alone caused me to nearly diagnose the wrong problem. The primary-source rule prevents this.

**How to apply:**
- When session opens with a multi-day gap, treat reorientation as Phase 1 of any diagnostic. Spend the first 5-10 minutes reading vault primary sources before asking the user a single substantive question.
- If a subagent recon hands you a snapshot, verify the load-bearing claims against the vault before acting on them. Recon is a starting hypothesis, not a conclusion.
- Memory in `MEMORY.md` is index-only; it points to detail files and to vault docs. When `MEMORY.md` says X happened on Y date, check the corresponding brief or state-archive entry for nuance.
- For lead-flow / funnel diagnostics specifically: pull Webflow Forms log + HubSpot raw + GA4 before forming a hypothesis. The story is in the data, not in summaries about the data.

Related: [[feedback-state-file-merge-protocol]] — Jim's `[x]` checkboxes and `%...%` comments in state files are authoritative.
