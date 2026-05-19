# Agent-Driven Ads Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build agent-driven ad management on top of Make as execution layer. Agents read metrics, draft proposals, Jim approves via inline edits in `_vault/state-of-cwdb.md`, agents execute via Make scenarios. `social-media-manager` handles Nextdoor via Playwright.

**Architecture:** Three-loop system (READ / APPROVE / EXECUTE) per spec at `C:/Users/jslog/.claude/plans/start-planning-ads-while-vivid-teacup.md`. Make handles OAuth + API calls for Google Ads + Meta. Playwright MCP handles Nextdoor. `analytics` reads, `ad-campaign` proposes + executes paid, `social-media-manager` handles Nextdoor, `cwdb-ceo-operator` orchestrates.

**Tech Stack:** Make (claude_ai_Make MCP) · Webflow (already live) · HubSpot (free tier) · Playwright MCP · Markdown + JSON file contracts · Python helper scripts for proposal parsing

---

## Phase T Prerequisite (outside this plan's scope)

Phase T (manual ad launch tonight via playbooks) is executed in the next Jim-in-session turn using pre-produced files:
- `marketing/google-ads/account-setup-playbook.md` (produced 2026-04-21)
- `marketing/facebook-ads/account-setup-playbook.md` (produced 2026-04-21)
- `marketing/nextdoor/organic-posting-playbook.md` (produced 2026-04-21)
- `_vault/jim-today-2026-04-21.md`

**Do not start Day 1 of this plan until:**
- At least one of (Google OR Meta) campaign is live and spending
- First test lead has fired successfully (form submit → email + Meta Pixel + Google Ads Conv)
- Launch timestamp posted to `_vault/state-of-cwdb.md`

Day 1 starts after launch lands. D1-D5 tasks below assume ads are live.

---

## Day 1 — Foundation (agent files + directory scaffolding + state-of-cwdb lane)

No Make scenarios yet. Goal: every agent + every directory is ready for Day 2 read scenarios to drop data.

### Task 1.1: Create ad-ops directory scaffolding

**Files:**
- Create: `operations/ad-metrics/google/.gitkeep`
- Create: `operations/ad-metrics/meta/.gitkeep`
- Create: `operations/ad-alerts/.gitkeep`
- Create: `operations/ad-executions/.gitkeep`
- Create: `finance/reports/performance/.gitkeep`
- Create: `marketing/google-ads/campaign-templates/.gitkeep`
- Create: `marketing/google-ads/ad-group-templates/.gitkeep`
- Create: `marketing/facebook-ads/campaign-templates/.gitkeep`
- Create: `marketing/facebook-ads/ad-set-templates/.gitkeep`
- Create: `marketing/facebook-ads/ad-templates/.gitkeep`

- [ ] **Step 1: Create all directories + empty .gitkeep files**

```bash
mkdir -p operations/ad-metrics/google operations/ad-metrics/meta operations/ad-alerts operations/ad-executions finance/reports/performance marketing/google-ads/campaign-templates marketing/google-ads/ad-group-templates marketing/facebook-ads/campaign-templates marketing/facebook-ads/ad-set-templates marketing/facebook-ads/ad-templates
touch operations/ad-metrics/google/.gitkeep operations/ad-metrics/meta/.gitkeep operations/ad-alerts/.gitkeep operations/ad-executions/.gitkeep finance/reports/performance/.gitkeep marketing/google-ads/campaign-templates/.gitkeep marketing/google-ads/ad-group-templates/.gitkeep marketing/facebook-ads/campaign-templates/.gitkeep marketing/facebook-ads/ad-set-templates/.gitkeep marketing/facebook-ads/ad-templates/.gitkeep
```

- [ ] **Step 2: Verify structure**

```bash
find operations marketing -type d -newer CLAUDE.md | sort
```

Expected output includes all 10 new directories.

- [ ] **Step 3: Add `.claude/playwright-state/` to .gitignore**

```bash
grep -qxF '.claude/playwright-state/' .gitignore || echo '.claude/playwright-state/' >> .gitignore
```

- [ ] **Step 4: Commit**

```bash
git add -A operations/ finance/ marketing/ .gitignore
git commit -m "scaffold: ad-ops directory structure for agent-driven ads"
```

---

### Task 1.2: Add Pending Approvals + Executed lanes to state-of-cwdb.md

**Files:**
- Modify: `_vault/state-of-cwdb.md` (append 2 new sections)

- [ ] **Step 1: Read current state-of-cwdb.md structure**

```bash
grep -n '^## ' _vault/state-of-cwdb.md
```

Note the line numbers of existing sections — we insert the two new lanes AFTER `## ✋ Manual Actions Queue` and BEFORE `## ⏳ Waiting On` (or whatever order exists; check line numbers from grep).

- [ ] **Step 2: Insert Pending Approvals section**

Add this block in the state file at the appropriate location (after Manual Actions Queue):

```markdown
## ⏳ Pending Approvals

*Ad-management proposals awaiting Jim's APPROVE/REJECT. Agents append here; Jim inline-edits Status line.*

**Grammar:**
- `APPROVE` → execute as-is
- `REJECT: <reason>` → kill proposal; archive with reason
- `APPROVE with edits: <free text>` → agent re-drafts + re-proposes
- Blank / `hold` / `later` → stays pending until TTL expires

**TTL defaults:** Tier 1 = 72 hr · Tier 2 = 5 days · Tier 3 = 7 days. Expired proposals auto-move to Executed with `expired unapproved`.

(no pending proposals)

---

## ✅ Recently Executed

*Last 10 ad-ops actions. Older entries archived to `operations/ad-executions/{YYYY-MM-DD}.md`.*

(no executions yet)
```

- [ ] **Step 3: Commit**

```bash
git add _vault/state-of-cwdb.md
git commit -m "feat(state): add Pending Approvals + Executed lanes for agent-driven ads"
```

---

### Task 1.3: Extend `analytics` agent for Loop 1 READ ownership

**Files:**
- Modify: `.claude/agents/analytics.md`

- [ ] **Step 1: Append new section to analytics.md**

Append to end of file:

```markdown

---

# AD OPS — LOOP 1 READ RESPONSIBILITIES (added 2026-04-21)

## Daily metrics pull workflow

At 06:00 CT (scheduled via external cron or triggered by cwdb-ceo-operator morning run):

1. Call `mcp__claude_ai_Make__scenarios_run` for scenario `CWDB Ads — Google — Daily Metrics Pull` (R1). Scenario returns prior-day metrics JSON.
2. Write JSON to `operations/ad-metrics/google/{YYYY-MM-DD}.json` (YYYY-MM-DD = prior day, not today).
3. Call R2 for Meta. Write to `operations/ad-metrics/meta/{YYYY-MM-DD}.json`.
4. Read both JSONs. Run threshold checks:
   - CPL > $60 on any ad group / ad set
   - CTR < 1.5% on any keyword / ad with >500 impressions
   - Zero conversions on keyword / ad with >$50 cumulative spend
   - Ad set > $250 cumulative spend with 0 leads
   - Spend vs daily budget variance > 10%
   - Any conversion rate drop > 40% day-over-day with normal traffic pattern
5. Write violations to `operations/ad-alerts/{YYYY-MM-DD}.md` using this format per alert:

```markdown
### ALERT: {platform} — {metric} threshold breach
- **Entity:** {campaign / ad group / keyword / ad ID + name}
- **Metric:** {CPL / CTR / conversions / spend}
- **Value:** {actual} vs threshold {threshold}
- **Suggested action:** {pause kw / pause ad set / reduce budget / etc.}
- **Linked scenario:** {Wn suggestion}
```

6. Write daily digest to `finance/reports/performance/{YYYY-MM-DD}-ads-daily.md`:

```markdown
# Ads Daily Report — {YYYY-MM-DD}

## Spend & Leads
| Platform | Spend | Leads | CPL | vs kill threshold |
|---|---|---|---|---|
| Google | ${spend} | {n} | ${cpl} | {status} |
| Meta | ${spend} | {n} | ${cpl} | {status} |
| **Total** | ${sum} | {n} | ${cpl} | — |

## Highlights
- {top converter, top waster, any anomalies}

## Alerts (count: {n})
{bulleted summary — full detail in operations/ad-alerts/{YYYY-MM-DD}.md}
```

## Failure handling

- If R1 or R2 returns non-2xx: log to `operations/ad-alerts/{YYYY-MM-DD}.md` with `ERROR` prefix. Do NOT retry silently; flag to Jim in Pending Approvals ("Re-auth Make connection for {platform}").
- If 2 consecutive days fail: escalate as Tier 2 proposal "Re-authenticate Make + verify API token".
```

- [ ] **Step 2: Verify file valid**

```bash
wc -l .claude/agents/analytics.md
head -5 .claude/agents/analytics.md
```

Expected: more lines than before (~60+), frontmatter intact.

- [ ] **Step 3: Commit**

```bash
git add .claude/agents/analytics.md
git commit -m "feat(agent): extend analytics with Loop 1 READ ad-ops responsibilities"
```

---

### Task 1.4: Extend `ad-campaign` agent for Propose + Execute modes

**Files:**
- Modify: `.claude/agents/ad-campaign.md`

- [ ] **Step 1: Append new section to ad-campaign.md**

Append to end of file:

```markdown

---

# AD OPS — PROPOSE + EXECUTE MODES (added 2026-04-21)

## Scope narrowing

This agent now covers **paid Google Ads + Meta only**. Nextdoor moved to `social-media-manager` agent. TikTok remains deferred (Phase 2).

## Propose mode

Triggered by: analytics alerts · cwdb-ceo-operator on-demand · scheduled daily 09:30 CT

1. Read today's alerts from `operations/ad-alerts/{YYYY-MM-DD}.md`.
2. Read last 7 days of `operations/ad-metrics/{platform}/*.json` for context.
3. For each alert, draft 0-N proposals (tier based on action severity; see tier rubric below).
4. Append each proposal to `_vault/state-of-cwdb.md` under `## ⏳ Pending Approvals` using the format below.

### Proposal block format

```markdown
### {TIER_ICON} TIER {N} — {Short action title}
- **ID:** P-YYYY-MM-DD-NNN
- **Proposed:** YYYY-MM-DD HH:MM CT · **Expires:** YYYY-MM-DD HH:MM CT
- **Scenario:** {Wn — Scenario name}
- **Payload:** {key1: val1, key2: val2}
- **Rationale:** {why, with metric reference}
- **Expected impact:** {quantified}
- (TIER 2+) **Reversibility:** {window / method}
- (TIER 3) **Naming collision check:** {scan result}
- (TIER 3) **Spend cap commitment:** {hard limit}
- (TIER 3) **Rollback plan:** {exact reverse scenario}
- (TIER 3) **Alternatives considered:** {2 of 3 rejected with reasons}
- **Status:** APPROVE
```

Tier icons: TIER 1 = no icon · TIER 2 = ⚙️ · TIER 3 = ⚠️.

### Tier rubric
- **Tier 1 (instant reversible):** W1 Pause Keyword, W2 Pause Ad Group, W4 Add Negative Kw, W6 Pause Ad, W7 Pause Ad Set, W10 Pause Underperforming.
- **Tier 2 (reversible with $ at stake):** W3 Adjust Campaign Budget, W5 Create RSA, W8 Adjust Ad Set Budget, W9 Duplicate Ad, W11 Create Ad Group, W13 Create Ad, W14 Create Ad Set.
- **Tier 3 (material new commitment):** W12 Create Campaign, W15 Create Campaign.

### Proposal ID rule
Monotonic per-day: `P-YYYY-MM-DD-NNN` where NNN starts at 001 each day. Check last ID for today in state-of-cwdb before assigning next.

## Execute mode

Triggered by: cwdb-ceo-operator dispatching approved proposals.

1. Receive payload: `{proposal_id, scenario: "Wn", payload: {...}}`.
2. Call `mcp__claude_ai_Make__scenarios_run` with the corresponding Make scenario + payload.
3. On 2xx response: append entry to `operations/ad-executions/{YYYY-MM-DD}.md`:

```markdown
## {HH:MM CT} · {proposal_id} · {Wn scenario name}
- **Payload:** {inline JSON}
- **Result:** ✅ Success — {short description of platform state after}
- **Make run ID:** {if returned}
```

4. On non-2xx: append with `❌ error:` prefix + full error body. Draft follow-up proposal with diagnostic (e.g., "Scenario W1 failed with 401 — Make Google Ads connection needs re-auth").
5. Move proposal from `## ⏳ Pending Approvals` to `## ✅ Recently Executed` in state-of-cwdb.md. Summary line format:

```
- YYYY-MM-DD HH:MM CT · P-YYYY-MM-DD-NNN · Wn {short action} · {✅ Success / ❌ error} · by ad-campaign
```

6. Keep last 10 in Executed. Older entries roll out (remain in `operations/ad-executions/` archive).

## Scenario → tool call mapping

For v1, all write scenarios are called via `mcp__claude_ai_Make__scenarios_run` with `scenarioId` from this mapping (to be populated after Day 2 build — each Make scenario returns an ID after creation; populate this table in the same Day it's built):

| Wn | Scenario name | Scenario ID |
|---|---|---|
| W1 | CWDB Ads — Google — Pause Keyword | TBD Day 3 |
| W2 | CWDB Ads — Google — Pause Ad Group | TBD Day 3 |
| W3 | CWDB Ads — Google — Adjust Campaign Budget | TBD Day 4 |
| W4 | CWDB Ads — Google — Add Negative Keyword | TBD Day 3 |
| W5 | CWDB Ads — Google — Create Responsive Search Ad | TBD Day 4 |
| W6 | CWDB Ads — Meta — Pause Ad | TBD Day 3 |
| W7 | CWDB Ads — Meta — Pause Ad Set | TBD Day 3 |
| W8 | CWDB Ads — Meta — Adjust Ad Set Budget | TBD Day 4 |
| W9 | CWDB Ads — Meta — Duplicate Ad with Tweaks | TBD Day 4 |
| W10 | CWDB Ads — Meta — Pause Underperforming Ad Set | TBD Day 3 |
| W11 | CWDB Ads — Google — Create Ad Group from Template | TBD Day 4 |
| W12 | CWDB Ads — Google — Create Campaign from Template | TBD Day 5 |
| W13 | CWDB Ads — Meta — Create Ad from Template | TBD Day 4 |
| W14 | CWDB Ads — Meta — Create Ad Set from Template | TBD Day 4 |
| W15 | CWDB Ads — Meta — Create Campaign from Template | TBD Day 5 |
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/ad-campaign.md
git commit -m "feat(agent): extend ad-campaign with Propose + Execute modes (Make-orchestrated)"
```

---

### Task 1.5: Extend `cwdb-ceo-operator` with Execute-dispatch routine

**Files:**
- Modify: `.claude/agents/cwdb-ceo-operator.md`

- [ ] **Step 1: Append routine section to ceo-operator.md**

Append:

```markdown

---

# AD OPS — EXECUTE DISPATCH ROUTINE (added 2026-04-21)

## Daily approval-sweep routine

Each session start (after reading state-of-cwdb.md):

1. Parse `## ⏳ Pending Approvals` section in `_vault/state-of-cwdb.md`.
2. For each proposal block, extract the `Status:` line value.
3. Filter for lines matching exactly `APPROVE` (case-sensitive; ignore `APPROVE with edits:` — agent re-drafts those itself).
4. For each APPROVE: dispatch `ad-campaign` agent in Execute mode with payload `{proposal_id, scenario, payload}`.
5. Wait for Execute mode to complete; verify the proposal was moved from Pending Approvals to Executed section.
6. Include executed actions in morning briefing summary: "Yesterday we executed N proposals. Results: {W-scenario-name count}"

## Reject + edit handling

- For `REJECT: <reason>` lines: move proposal to Executed section with `❌ rejected: {reason}` · by Jim · NO agent dispatch.
- For `APPROVE with edits: <text>` lines: re-dispatch `ad-campaign` in Propose mode with `{proposal_id, original_payload, edit_text}`. Agent re-drafts and appends a NEW proposal (same ID with `-v2` suffix), archives old one.

## TTL expiration handling

At start of each session, also scan Pending Approvals for expired proposals (compare `Expires:` timestamp to now). For each expired: move to Executed as `expired unapproved — no action taken` · no agent dispatch.

## Escalation triggers

If Pending Approvals count exceeds 10, or oldest unhandled proposal exceeds 48 hours: surface in morning briefing as a priority item ("X proposals awaiting review").
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/cwdb-ceo-operator.md
git commit -m "feat(agent): extend ceo-operator with ad-ops Execute-dispatch routine"
```

---

### Task 1.6: Create `social-media-manager` agent

**Files:**
- Create: `.claude/agents/social-media-manager.md`

- [ ] **Step 1: Write social-media-manager.md**

```markdown
---
name: social-media-manager
description: Monitor Nextdoor neighborhood feeds for contractor-request intent, draft replies using templates, propose via Pending Approvals, post approved replies via Playwright
---

AGENT: Social Media Manager
DEPARTMENT: Marketing / Operations
ROLE: Drive organic community-channel engagement (Nextdoor primary; Reddit + FB Groups future)

TECH STACK:
- Playwright MCP (browser automation — no public Nextdoor ads API)
- Session state persisted to `.claude/playwright-state/nextdoor.json` (gitignored)

SCOPE:
- Nextdoor organic monitoring + reply drafting + posting
- Does NOT manage paid Nextdoor ads (none running at launch per 2026-04-18 budget decision)
- Does NOT overlap with `ad-campaign` (paid Google + Meta only)

## Scheduled scan workflow

Runs at 08:00 CT and 17:00 CT daily (triggered by cwdb-ceo-operator or external cron).

1. Launch Playwright via `mcp__plugin_playwright_playwright__browser_navigate` to `https://nextdoor.com/business`
2. Load session state from `.claude/playwright-state/nextdoor.json`. If session died (login redirect detected), flag to Jim in Pending Approvals: "Nextdoor re-auth needed"; halt scan.
3. For each of 5 neighborhoods (Wausau, Schofield, Weston, Mosinee, Merrill), navigate to neighborhood feed and scroll to capture last 20 posts.
4. Intent detection pass — keyword + context match:
   - Keywords: "deck", "builder", "contractor", "quote", "estimate"
   - Context: "looking for", "anyone recommend", "need a", "hiring", "replace my", "build a new"
   - Exclude: self-posts (posted by CWDB Business page), already-replied threads
5. For each hit: generate reply from templates A/B/C (rotate by thread hash to avoid repetition).
6. Append to `_vault/state-of-cwdb.md` `## ⏳ Pending Approvals` with action `nextdoor-reply`:

```markdown
### TIER 1 — Nextdoor reply: {neighborhood} — {short thread summary}
- **ID:** P-YYYY-MM-DD-NNN
- **Proposed:** YYYY-MM-DD HH:MM CT · **Expires:** +72 hrs
- **Scenario:** nextdoor-reply (Playwright)
- **Payload:** thread_url={url}, reply_text="{draft}", template={A|B|C}
- **Rationale:** {post hook + why we match}
- **Expected impact:** 1 organic reply, no ad spend, Nextdoor trust signal
- **Status:** APPROVE
```

7. Rate limit: max 3 organic replies posted per day across all neighborhoods. If 3 already executed today, queue further hits in Pending Approvals but mark them `(rate-limited — will queue for tomorrow)` in Rationale.

## Reply post workflow (execute mode)

Triggered by cwdb-ceo-operator after Jim's APPROVE.

1. Re-open Playwright, load session state.
2. Navigate to `thread_url` from payload.
3. Post `reply_text` via reply UI.
4. Capture screenshot post-post to confirm visibility.
5. Append to `operations/ad-executions/{YYYY-MM-DD}.md`:

```markdown
## {HH:MM CT} · {proposal_id} · nextdoor-reply
- **Thread:** {thread_url}
- **Template:** {A|B|C}
- **Result:** ✅ Posted — screenshot saved to operations/ad-executions/screenshots/{proposal_id}.png
```

6. Move proposal to Executed.

## Templates (A/B/C)

Source: `marketing/nextdoor/organic-posting-playbook.md` (produced 2026-04-21). Templates rotate by thread hash so no thread sees the same template variant from CWDB.

## Failure modes

- Session death → flag to Jim (`Nextdoor re-auth needed`), halt scan
- Thread already replied (CWDB post detected) → skip, log
- Post UI change → capture screenshot, flag to Jim ("Nextdoor reply UI changed — selectors need update")
- Rate limit triggered → queue, surface in next morning briefing
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/social-media-manager.md
git commit -m "feat(agent): add social-media-manager for Nextdoor organic engagement"
```

---

### Task 1.7: Write proposal-parsing helper script

**Files:**
- Create: `operations/ad-ops/parse_approvals.py`
- Create: `operations/ad-ops/test_parse_approvals.py`

Why a script: `cwdb-ceo-operator` dispatches need to parse state-of-cwdb.md reliably. Hand-rolling markdown parsing each session is error-prone. This single Python helper becomes the canonical parser.

- [ ] **Step 1: Write failing test first**

Create `operations/ad-ops/test_parse_approvals.py`:

```python
"""Tests for parse_approvals helper."""
import sys
import os
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from parse_approvals import parse_pending_approvals, ProposalStatus


SAMPLE_STATE = """# State of CWDB

## ⏳ Pending Approvals

### TIER 1 — Pause Keyword "deck kit"
- **ID:** P-2026-04-23-014
- **Proposed:** 2026-04-23 18:22 CT · **Expires:** 2026-04-26 18:22 CT
- **Scenario:** W1 — CWDB Ads — Google — Pause Keyword
- **Payload:** keyword_id=1234567890
- **Rationale:** 234 impressions, 0 conv, $4.80 spent. DIY intent.
- **Expected impact:** save ~$5/week
- **Status:** APPROVE

### ⚙️ TIER 2 — Increase Meta Ad Set Budget
- **ID:** P-2026-04-23-015
- **Proposed:** 2026-04-23 18:25 CT · **Expires:** 2026-04-28 18:25 CT
- **Scenario:** W8 — CWDB Ads — Meta — Adjust Ad Set Budget
- **Payload:** ad_set_id=999888, new_daily_budget_cents=3000
- **Rationale:** CPL $38 at $90 spend, below target.
- **Expected impact:** +30% leads/day
- **Reversibility:** W8 reversal in <5 sec
- **Status:** REJECT: not ready to scale yet

### ⚠️ TIER 3 — Create Google Campaign
- **ID:** P-2026-04-23-016
- **Proposed:** 2026-04-23 18:30 CT · **Expires:** 2026-04-30 18:30 CT
- **Scenario:** W12 — CWDB Ads — Google — Create Campaign from Template
- **Payload:** template=search-deck-cost, daily_budget_cents=1500
- **Rationale:** Cost-keyword traffic untapped.
- **Status:** hold

## ✅ Recently Executed
(previous entries)
"""


def test_parses_approve():
    result = parse_pending_approvals(SAMPLE_STATE)
    approved = [p for p in result if p.status == ProposalStatus.APPROVE]
    assert len(approved) == 1
    assert approved[0].proposal_id == "P-2026-04-23-014"
    assert approved[0].scenario == "W1 — CWDB Ads — Google — Pause Keyword"


def test_parses_reject_with_reason():
    result = parse_pending_approvals(SAMPLE_STATE)
    rejected = [p for p in result if p.status == ProposalStatus.REJECT]
    assert len(rejected) == 1
    assert rejected[0].proposal_id == "P-2026-04-23-015"
    assert rejected[0].reject_reason == "not ready to scale yet"


def test_parses_hold_as_pending():
    result = parse_pending_approvals(SAMPLE_STATE)
    pending = [p for p in result if p.status == ProposalStatus.PENDING]
    assert len(pending) == 1
    assert pending[0].proposal_id == "P-2026-04-23-016"


def test_empty_approvals_returns_empty_list():
    empty_state = """# State of CWDB

## ⏳ Pending Approvals

(no pending proposals)

## ✅ Recently Executed
"""
    result = parse_pending_approvals(empty_state)
    assert result == []


def test_proposal_payload_parsed():
    result = parse_pending_approvals(SAMPLE_STATE)
    approved = [p for p in result if p.status == ProposalStatus.APPROVE][0]
    assert approved.payload == {"keyword_id": "1234567890"}


if __name__ == "__main__":
    test_parses_approve()
    test_parses_reject_with_reason()
    test_parses_hold_as_pending()
    test_empty_approvals_returns_empty_list()
    test_proposal_payload_parsed()
    print("All tests passed.")
```

- [ ] **Step 2: Run test — expect failure (import error)**

```bash
python operations/ad-ops/test_parse_approvals.py
```

Expected: `ModuleNotFoundError: No module named 'parse_approvals'`.

- [ ] **Step 3: Write minimal implementation**

Create `operations/ad-ops/parse_approvals.py`:

```python
"""Parse Pending Approvals section of _vault/state-of-cwdb.md.

Contract: returns list of Proposal objects. Status enum:
  APPROVE  → ready to execute
  REJECT   → archive with reason
  PENDING  → blank / hold / later / unrecognized — stays pending
  EDIT     → APPROVE with edits: <text> — re-draft

Used by cwdb-ceo-operator to dispatch ad-campaign in Execute mode.
"""
from __future__ import annotations

import re
from dataclasses import dataclass, field
from enum import Enum


class ProposalStatus(Enum):
    APPROVE = "APPROVE"
    REJECT = "REJECT"
    EDIT = "EDIT"
    PENDING = "PENDING"


@dataclass
class Proposal:
    proposal_id: str
    tier: int
    title: str
    scenario: str
    payload: dict
    status: ProposalStatus
    reject_reason: str | None = None
    edit_text: str | None = None


_APPROVALS_SECTION_RE = re.compile(
    r"## ⏳ Pending Approvals(.*?)(?=\n## )", re.DOTALL
)
_PROPOSAL_BLOCK_RE = re.compile(
    r"### (?:[⚙️⚠️]\s*)?TIER (\d+) — (.+?)\n(.*?)(?=\n### |\Z)", re.DOTALL
)
_FIELD_RE = re.compile(r"^- \*\*([A-Za-z][A-Za-z ]*):\*\* (.+?)$", re.MULTILINE)


def parse_pending_approvals(state_content: str) -> list[Proposal]:
    section_match = _APPROVALS_SECTION_RE.search(state_content)
    if not section_match:
        return []

    section = section_match.group(1)
    if "(no pending proposals)" in section:
        return []

    proposals = []
    for block_match in _PROPOSAL_BLOCK_RE.finditer(section):
        tier = int(block_match.group(1))
        title = block_match.group(2).strip()
        body = block_match.group(3)

        fields = {m.group(1).strip(): m.group(2).strip() for m in _FIELD_RE.finditer(body)}

        proposal_id = fields.get("ID", "")
        scenario = fields.get("Scenario", "")
        payload = _parse_payload(fields.get("Payload", ""))
        status_raw = fields.get("Status", "").strip()

        status, reject_reason, edit_text = _classify_status(status_raw)

        proposals.append(
            Proposal(
                proposal_id=proposal_id,
                tier=tier,
                title=title,
                scenario=scenario,
                payload=payload,
                status=status,
                reject_reason=reject_reason,
                edit_text=edit_text,
            )
        )

    return proposals


def _parse_payload(raw: str) -> dict:
    """Parse `key=value, key2=value2` style payload into dict."""
    if not raw:
        return {}
    result = {}
    for pair in raw.split(","):
        pair = pair.strip()
        if "=" in pair:
            key, value = pair.split("=", 1)
            result[key.strip()] = value.strip()
    return result


def _classify_status(raw: str) -> tuple[ProposalStatus, str | None, str | None]:
    if raw == "APPROVE":
        return ProposalStatus.APPROVE, None, None
    if raw.startswith("REJECT:"):
        return ProposalStatus.REJECT, raw[len("REJECT:"):].strip(), None
    if raw.startswith("APPROVE with edits:"):
        return ProposalStatus.EDIT, None, raw[len("APPROVE with edits:"):].strip()
    return ProposalStatus.PENDING, None, None
```

- [ ] **Step 4: Run test — expect pass**

```bash
python operations/ad-ops/test_parse_approvals.py
```

Expected: `All tests passed.`

- [ ] **Step 5: Commit**

```bash
git add operations/ad-ops/
git commit -m "feat(ops): add proposal-parsing helper for ceo-operator approval sweep"
```

---

## Day 1 checkpoint

Stop + verify:

```bash
git log --oneline | head -8
```

Expected: 7 commits from Day 1 tasks (1.1 through 1.7). Agent files modified or created; state-of-cwdb has new lanes; proposal parser passing tests. No Make scenarios built yet — those are Day 2.

---

## Day 2 — Make read scenarios (R1 + R2)

Goal: daily metrics pull working. First data lands in `operations/ad-metrics/`. `analytics` agent can be dispatched tomorrow and produce real alerts.

### Task 2.1: Confirm Make connections for Google Ads + Meta Ads

**Files:** no new files; verification-only step.

- [ ] **Step 1: List existing Make connections via MCP**

Call `mcp__claude_ai_Make__connections_list` with no filters.

Expected: an existing Google Ads connection (authorized during Phase T launch if Jim used Make for any step, OR new connection we build now) and a Meta/Facebook Ads connection.

- [ ] **Step 2: If missing, create connections**

If Google Ads connection absent: Jim goes to `https://www.make.com/en/integrations/google-ads` → click "Connect" → authorize Google Ads account. (This is Jim-manual, ~5 min.)

If Meta connection absent: same flow at `https://www.make.com/en/integrations/facebook-ads`.

- [ ] **Step 3: Record connection IDs in agent memory**

After confirming, record the 2 connection IDs for use in scenario builds. No file edit needed yet — next task uses them.

---

### Task 2.2: Build Make scenario R1 — Google Daily Metrics Pull

**Files:**
- No file writes; scenario exists in Make account, ID captured in Day 1 agent files afterwards.

- [ ] **Step 1: Create scenario via Make MCP**

Call `mcp__claude_ai_Make__scenarios_create`:

```
{
  "name": "CWDB Ads — Google — Daily Metrics Pull",
  "folderId": (create or reuse "CWDB Ads" folder)
}
```

Record the returned `scenarioId`.

- [ ] **Step 2: Configure scenario modules**

Use `mcp__claude_ai_Make__scenarios_set-interface` or `scenarios_update` to define modules:

1. **Scheduler module** — daily trigger, 06:00 CT (12:00 UTC for America/Chicago summer; adjust for DST)
2. **Google Ads "List Campaigns" module** — use the Google Ads connection from Task 2.1. Date range: yesterday. Fields to pull: campaign ID, name, status, spend, clicks, impressions, conversions, cost_per_conversion, ctr, conversion_rate.
3. **Google Ads "List Ad Groups" module** — similar, scoped to yesterday, for each campaign in step 2 output.
4. **Google Ads "List Keywords" module** — similar, scoped to yesterday.
5. **Tools module — Aggregator** — merge campaign + ad group + keyword arrays into single JSON with shape:

```json
{
  "pulled_at": "2026-04-22T06:00:00-05:00",
  "metrics_date": "2026-04-21",
  "campaigns": [...],
  "ad_groups": [...],
  "keywords": [...]
}
```

6. **HTTP module — Make a Request** — POST to a webhook that the `analytics` agent can consume (either a Make data-store write, or a direct write to a Gmail draft with JSON body; easiest: **Data Store module** writing to a "CWDB Ad Metrics" data store so the agent retrieves on demand).

Alternative architecture (simpler for v1): instead of Data Store, have R1 return the JSON as scenario output. `analytics` agent calls `mcp__claude_ai_Make__scenarios_run` synchronously and writes the response directly to `operations/ad-metrics/google/{YYYY-MM-DD}.json`. Skip the Data Store.

- [ ] **Step 3: Test scenario manually**

Call `mcp__claude_ai_Make__scenarios_run` with the R1 scenarioId and empty input.

Expected: scenario runs, returns JSON matching shape above. If empty (account has no activity yesterday because it just launched), empty arrays are acceptable.

- [ ] **Step 4: Update the ad-campaign.md scenario mapping**

Edit the table in `.claude/agents/ad-campaign.md` — replace `R1 TBD Day 2` row's Scenario ID column with the actual ID.

```bash
# Hand-edit or via sed — replace "TBD Day 2" for R1 row with actual ID
```

Also update the analytics.md scenario reference in the "Daily metrics pull workflow" section.

- [ ] **Step 5: Commit**

```bash
git add .claude/agents/
git commit -m "feat(make): R1 Google metrics pull scenario + wire scenario ID into agent files"
```

---

### Task 2.3: Build Make scenario R2 — Meta Daily Metrics Pull

**Files:** no new files; Make scenario + agent file updates.

- [ ] **Step 1: Create R2 via Make MCP** — same pattern as Task 2.2, substituting Facebook/Meta Ads modules for Google.

Modules: Scheduler (same schedule) → Facebook Ads "List Campaigns" → "List Ad Sets" → "List Ads" → Aggregator → return JSON.

JSON shape parallel to R1:

```json
{
  "pulled_at": "2026-04-22T06:00:00-05:00",
  "metrics_date": "2026-04-21",
  "campaigns": [...],
  "ad_sets": [...],
  "ads": [...]
}
```

- [ ] **Step 2: Test R2 manually via `scenarios_run`**

Expected: parallel to R1 — campaigns/ad_sets/ads arrays populated if Meta campaign is live.

- [ ] **Step 3: Update ad-campaign.md + analytics.md mapping**

Same pattern as Task 2.2 Step 4.

- [ ] **Step 4: Commit**

```bash
git add .claude/agents/
git commit -m "feat(make): R2 Meta metrics pull scenario + wire scenario ID into agent files"
```

---

### Task 2.4: First analytics dispatch — generate alerts + daily digest

**Files:**
- Creates (via analytics agent): `operations/ad-metrics/google/{today-1}.json`, `operations/ad-metrics/meta/{today-1}.json`, `operations/ad-alerts/{today-1}.md`, `finance/reports/performance/{today-1}-ads-daily.md`

- [ ] **Step 1: Dispatch analytics agent via Agent tool**

Prompt summary: "Run your Loop 1 READ routine. Call R1 and R2 scenarios, write metrics JSONs, detect violations, write alerts + digest. If either scenario returns empty (campaigns just launched), write empty-alert files with 'no data yet — campaigns in first 24 hr' noted in digest."

- [ ] **Step 2: Verify files created**

```bash
ls -la operations/ad-metrics/google/ operations/ad-metrics/meta/ operations/ad-alerts/ finance/reports/performance/
```

Expected: at minimum one `{YYYY-MM-DD}.json` per platform, one `{YYYY-MM-DD}.md` alert file, one `{YYYY-MM-DD}-ads-daily.md` digest.

- [ ] **Step 3: Inspect digest**

```bash
cat finance/reports/performance/*-ads-daily.md | head -40
```

Expected: table with Google + Meta rows, spend/leads/CPL columns, "Highlights" + "Alerts" sections.

- [ ] **Step 4: Commit**

```bash
git add operations/ finance/
git commit -m "feat(ad-ops): first daily metrics pull + digest generated"
```

---

## Day 2 checkpoint

Stop + verify:

- [ ] R1 + R2 Make scenarios exist and run successfully
- [ ] Scenario IDs recorded in agent files
- [ ] First digest file shows yesterday's data (or explicitly says "no data yet")
- [ ] `git log` shows 3-4 new commits from Day 2

---

## Day 3 — Tier 1 write scenarios (pause ops) + first end-to-end loop

Goal: at end of Day 3, Jim can approve a Tier 1 proposal and the agent executes it via Make.

### Task 3.1: Build W1 — Google Pause Keyword

**Files:** no file writes; Make scenario + agent mapping update.

- [ ] **Step 1: Create W1 scenario via Make MCP**

```
{
  "name": "CWDB Ads — Google — Pause Keyword",
  "folderId": (same CWDB Ads folder from R1/R2)
}
```

Webhook trigger (not scheduled). Module: Google Ads "Update Keyword" with `status=paused` where `keyword_id = {{webhook.keyword_id}}`. Return module: scenario output = `{success: true, keyword_id: <id>, new_status: "paused"}`.

- [ ] **Step 2: Test W1 manually**

Call `scenarios_run` with payload `{"keyword_id": "<pick a real low-spend keyword ID from R1 output>"}`.

Verify in Google Ads UI that the keyword status changes to paused.

- [ ] **Step 3: Revert manually in Google Ads UI** (we were testing — don't leave production state changed).

- [ ] **Step 4: Update agent mapping**

Replace `W1 TBD Day 3` row in `.claude/agents/ad-campaign.md` scenario table with actual ID.

- [ ] **Step 5: Commit**

```bash
git add .claude/agents/ad-campaign.md
git commit -m "feat(make): W1 Google Pause Keyword scenario + wire ID"
```

---

### Task 3.2: Build W2, W4, W6, W7, W10 — remaining Tier 1 scenarios

Same pattern as W1. Each is one Make scenario + one agent mapping update.

- [ ] **W2 — Google Pause Ad Group** — Google Ads "Update Ad Group" with `status=paused`. Test + revert + map.
- [ ] **W4 — Google Add Negative Keyword** — Google Ads "Add Negative Keyword" at campaign or ad-group level. Test with a dummy non-matching term, verify it appears, remove. Map.
- [ ] **W6 — Meta Pause Ad** — Facebook Ads "Update Ad" with `status=PAUSED`. Test + revert + map.
- [ ] **W7 — Meta Pause Ad Set** — Facebook Ads "Update Ad Set" with `status=PAUSED`. Test + revert + map.
- [ ] **W10 — Meta Pause Underperforming Ad Set** — same as W7 but with structured rationale field in webhook (used to distinguish from manual pause). Test + revert + map.

After each scenario built: test via `scenarios_run`, revert via platform UI, update agent table, commit with message `feat(make): Wn {scenario name} + wire ID`.

---

### Task 3.3: End-to-end loop test — synthetic Tier 1 proposal

**Files:**
- Creates test proposal in `_vault/state-of-cwdb.md` (manually)
- Executes via CEO dispatch → ad-campaign → Make
- Verifies in `operations/ad-executions/{YYYY-MM-DD}.md`

- [ ] **Step 1: Pick a real low-spend keyword to pause as test target**

From `operations/ad-metrics/google/{latest}.json`, find a keyword with <10 impressions + 0 conversions.

- [ ] **Step 2: Manually append a test proposal to Pending Approvals in state-of-cwdb.md**

```markdown
### TIER 1 — [SYNTHETIC TEST] Pause Keyword "{kw_text}"
- **ID:** P-TEST-001
- **Proposed:** {now} CT · **Expires:** +72 hrs
- **Scenario:** W1 — CWDB Ads — Google — Pause Keyword
- **Payload:** keyword_id={kw_id}
- **Rationale:** E2E test of agent-driven ops loop. Will revert after execution.
- **Expected impact:** synthetic — test only
- **Status:** APPROVE
```

- [ ] **Step 3: Dispatch cwdb-ceo-operator**

Prompt summary: "Run your ad-ops approval-sweep routine. Parse state-of-cwdb Pending Approvals, find APPROVE lines, dispatch ad-campaign in Execute mode. Report what you executed."

- [ ] **Step 4: Verify execution**

Check:
- Google Ads UI — keyword status is paused
- `operations/ad-executions/{today}.md` — new entry appended with `✅ Success`
- state-of-cwdb.md — proposal moved from Pending Approvals to Recently Executed
- Recently Executed summary line: `{YYYY-MM-DD HH:MM} CT · P-TEST-001 · W1 Pause kw "{kw_text}" · ✅ Success · by ad-campaign`

- [ ] **Step 5: Manually revert keyword in Google Ads** (this was a test — restore state).

- [ ] **Step 6: Delete the test entry from Recently Executed** (since it was synthetic, don't pollute audit log).

- [ ] **Step 7: Commit state-of-cwdb changes (minus the deleted test entry) + audit log**

```bash
git add _vault/state-of-cwdb.md operations/ad-executions/
git commit -m "test(ad-ops): end-to-end Tier 1 loop verified — propose → approve → execute"
```

---

## Day 3 checkpoint

- [ ] All 6 Tier 1 scenarios (W1, W2, W4, W6, W7, W10) built and tested
- [ ] End-to-end loop verified
- [ ] Scenario mapping table in `.claude/agents/ad-campaign.md` has actual IDs for W1-W10 except the Tier 2/3 rows

---

## Day 4 — Tier 2 write scenarios + seed first templates

Goal: agent can propose budget changes, new ad creation, duplications; has 1 campaign template + 1 ad set template + 3 ad templates seeded from live campaigns.

### Task 4.1: Build W3 — Google Adjust Campaign Budget

- [ ] Build Make scenario via MCP — webhook trigger, Google Ads "Update Campaign" module with `daily_budget_micros = {{webhook.new_daily_budget_cents * 10000}}` (Google API uses micros; $30 = 30000000 micros).
- [ ] Test with a +$1 budget change on the live campaign. Revert to original budget.
- [ ] Update agent scenario table.
- [ ] Commit.

### Task 4.2: Build W5 — Google Create Responsive Search Ad

- [ ] Build Make scenario — Google Ads "Create Responsive Search Ad" under an ad group. Accept payload: `ad_group_id`, `headlines` (array of 15), `descriptions` (array of 4), `final_url`.
- [ ] Test by creating a test ad in the live ad group; verify in Google Ads UI; delete test ad.
- [ ] Update agent scenario table.
- [ ] Commit.

### Task 4.3: Build W8 — Meta Adjust Ad Set Budget

- [ ] Build Make scenario — Facebook Ads "Update Ad Set" with `daily_budget` (in cents). Test + revert + map + commit.

### Task 4.4: Build W9 — Meta Duplicate Ad with Tweaks

- [ ] Build Make scenario — "Duplicate Ad" module with `source_ad_id`, override `primary_text` + `headline` fields. Test + verify duplicate exists in Ads Manager with new copy + archive duplicate after test + map + commit.

### Task 4.5: Seed 1 Google campaign template from live campaign

**Files:**
- Create: `marketing/google-ads/campaign-templates/search-deck-builders.json`

- [ ] Call R1 manually; from output, pick the primary live campaign (`CWDB — Central WI Decks — Search`). Extract its config: name, budget, bidding strategy, locations, languages, ad schedule, network settings, etc.
- [ ] Write template JSON:

```json
{
  "template_id": "search-deck-builders",
  "description": "Standard Google Search campaign for deck-builder intent in Wausau cluster. Proven Phase-1 config.",
  "defaults": {
    "campaign_type": "SEARCH",
    "bidding_strategy": "MAXIMIZE_CONVERSIONS",
    "network_settings": { "target_google_search": true, "target_search_network": false, "target_content_network": false, "target_partner_search_network": false },
    "locations": [{ "type": "proximity", "latitude": 44.9591, "longitude": -89.6301, "radius_miles": 20 }],
    "languages": ["en"],
    "ad_schedule": "ALL_HOURS",
    "start_date": "TODAY",
    "final_url_template": "https://www.cwdeckbuilders.com/get-a-quote",
    "conversion_action": "AW-10862517194/hH93CKGVtp4cEMq307so"
  },
  "overrides_contract": [
    { "field": "name", "type": "string", "required": true },
    { "field": "daily_budget_cents", "type": "integer", "required": true, "min": 1000, "max": 20000 },
    { "field": "geo_radius_miles", "type": "integer", "default": 20, "min": 10, "max": 50 },
    { "field": "geo_center_zip", "type": "string", "default": "54403" }
  ]
}
```

- [ ] Commit:

```bash
git add marketing/google-ads/campaign-templates/search-deck-builders.json
git commit -m "feat(templates): seed Google search-deck-builders campaign template"
```

### Task 4.6: Seed 1 Meta campaign template + 1 ad set template + 3 ad templates

Parallel pattern — extract from live Meta campaign.

- [ ] `marketing/facebook-ads/campaign-templates/meta-lead-standard.json` — campaign-level config (objective LEADS, special_ad_category=NONE for decks, daily_budget placeholder, status=PAUSED default).
- [ ] `marketing/facebook-ads/ad-set-templates/central-wi-cold-homeowners.json` — ad set config: targeting (age 35-65, 5 cities + 30mi, interests, behaviors, exclusions), placements (automatic), optimization_goal (OFFSITE_CONVERSIONS), billing_event (IMPRESSIONS), lead_form_id placeholder.
- [ ] `marketing/facebook-ads/ad-templates/social-proof-angle.json`, `problem-solution-angle.json`, `seasonal-urgency-angle.json` — each with primary_text, headline, description, CTA, creative placeholder.

Each as JSON with `defaults` + `overrides_contract` same pattern as Google template.

- [ ] Commit all 5 templates in one commit:

```bash
git add marketing/facebook-ads/
git commit -m "feat(templates): seed Meta campaign + ad set + 3 ad-angle templates"
```

### Task 4.7: Build W11, W13, W14 — CREATE-from-template scenarios (ad-group, ad, ad-set level)

- [ ] **W11 — Google Create Ad Group from Template** — Make scenario that reads template file (via HTTP Get to GitHub raw URL or via Make Data Store), merges with payload overrides, calls Google Ads "Create Ad Group". Test + map + commit.
- [ ] **W13 — Meta Create Ad from Template** — similar, Facebook Ads "Create Ad". Test + map + commit.
- [ ] **W14 — Meta Create Ad Set from Template** — Facebook Ads "Create Ad Set". Test + map + commit.

Note: the template-read step inside Make can use an HTTP module to fetch the JSON from GitHub (public repo) or store templates in Make Data Store. Decision for v1: **HTTP module fetching from GitHub raw URL** — keeps templates in git, version-controlled, human-editable. Cost: every CREATE scenario run is 1 extra HTTP module call (~1 op, negligible).

---

## Day 4 checkpoint

- [ ] All Tier 2 scenarios (W3, W5, W8, W9, W11, W13, W14) built
- [ ] 6 templates committed (1 Google campaign, 1 Google ad group can be done here or deferred, 1 Meta campaign, 1 Meta ad set, 3 Meta ads)
- [ ] Agent scenario table has actual IDs for all Tier 2 scenarios

---

## Day 5 — Tier 3 CREATE + social-media-manager + first Nextdoor scan

### Task 5.1: Build W12 — Google Create Campaign from Template

- [ ] Build Make scenario. Payload: `template_id`, `overrides` (name, daily_budget_cents, geo_radius_miles, geo_center_zip). Scenario: HTTP Get template JSON from GitHub → Aggregator merges defaults + overrides → Google Ads "Create Campaign" module.
- [ ] Test with dummy name `"CWDB TEST CAMPAIGN"` + budget $1/day + immediately pause after creation. Archive test campaign via platform UI.
- [ ] Update agent mapping table + commit.

### Task 5.2: Build W15 — Meta Create Campaign from Template

- [ ] Parallel pattern. Facebook Ads "Create Campaign" module. Test + archive test + commit.

### Task 5.3: Initialize Playwright Nextdoor session state

**Files:**
- Create: `.claude/playwright-state/nextdoor.json` (gitignored via Task 1.1 .gitignore update)

- [ ] **Step 1: Login to Nextdoor via Playwright MCP**

Call `mcp__plugin_playwright_playwright__browser_navigate` to `https://nextdoor.com/login`. Jim enters credentials in the browser (interactive).

- [ ] **Step 2: Verify logged in**

After Jim submits: `mcp__plugin_playwright_playwright__browser_snapshot` — expect feed view, business-profile link in nav.

- [ ] **Step 3: Persist session state**

Call `mcp__plugin_playwright_playwright__browser_run_code` with:

```javascript
const storage = await context.storageState();
await fs.writeFile('.claude/playwright-state/nextdoor.json', JSON.stringify(storage, null, 2));
```

(Actual MCP tool name / method may differ; verify via `mcp__plugin_playwright_playwright__browser_evaluate` and adjust.)

- [ ] **Step 4: Close browser** (but keep session state on disk for next load)

```bash
# Verify state file exists
ls -la .claude/playwright-state/nextdoor.json
```

### Task 5.4: First supervised Nextdoor scan via social-media-manager

**Files:**
- Potentially appends proposals to state-of-cwdb.md Pending Approvals

- [ ] **Step 1: Dispatch social-media-manager**

Prompt summary: "Run your scheduled scan workflow. Load session state. Navigate to 5 neighborhoods. Scan last 20 posts each. Intent-detect. Draft replies for any hits. Append to Pending Approvals. Report what you found."

- [ ] **Step 2: Verify output**

Check `_vault/state-of-cwdb.md` — if any hits, Pending Approvals has new entries with action `nextdoor-reply`.

If no hits in this first pass (common — requires waiting for an actual intent post), still verify agent completed the scan without errors (screenshot capture, navigation, no session death).

- [ ] **Step 3: If hit, review 1 proposal manually**

Read the draft reply. Is template A/B/C appropriate for the post? Does reply tone match CWDB brand voice? If yes, `APPROVE` in state-of-cwdb. If no, `REJECT: {reason}`.

- [ ] **Step 4: If approved, verify posting**

Dispatch cwdb-ceo-operator to run approval sweep. Social-media-manager executes → Playwright posts → confirms screenshot.

Verify: reply appears on Nextdoor (manually check).

- [ ] **Step 5: Commit audit trail**

```bash
git add _vault/state-of-cwdb.md operations/ad-executions/
git commit -m "test(social): first supervised Nextdoor scan + reply posted (or empty-scan confirmed)"
```

---

## Day 5 checkpoint

- [ ] Both Tier 3 CREATE scenarios (W12, W15) built
- [ ] Nextdoor Playwright session live
- [ ] social-media-manager agent verified operational
- [ ] At least one scan completed (whether or not it found intent posts)

---

## End-to-end verification (run after Day 5)

### Task V.1: Full-system smoke test

- [ ] **Step 1: Run analytics** → produces fresh alerts file
- [ ] **Step 2: Run ad-campaign in Propose mode** → produces 1+ proposals in Pending Approvals
- [ ] **Step 3: Jim inline-edits `APPROVE` on 1 Tier 1 proposal, `REJECT: {reason}` on another**
- [ ] **Step 4: Run cwdb-ceo-operator approval sweep**
- [ ] **Step 5: Verify**: APPROVE executed (platform UI confirms + Recently Executed row added); REJECT moved to Recently Executed with reason; expired proposals (if any TTL past) also swept

- [ ] **Step 6: Run social-media-manager scan → 0+ proposals**
- [ ] **Step 7: Approve or reject any proposal; verify post flow end-to-end**

If all 7 steps pass, the system is in steady state. v1 is done.

```bash
git log --oneline | head -20
```

Expected: ~20-25 commits across Days 1-5 + verification.

---

## Self-Review Checklist (performed before handoff)

- [x] **Spec coverage:** every section of the design spec has a corresponding task. 3-loop architecture = Tasks 1.2, 1.3, 1.4, 1.5. 4 agents = Tasks 1.3-1.6. 14 write scenarios = Tasks 3.1, 3.2, 4.1-4.4, 4.7, 5.1, 5.2. Templates = Tasks 4.5, 4.6. Pending Approvals format = Task 1.2. TTL handling = Task 1.5. social-media-manager = Task 1.6, 5.3, 5.4. Daily rhythm = implied by scheduler modules in Tasks 2.2, 2.3.
- [x] **No placeholders:** all `TBD` references are intentional (scenario ID slots that get filled on their build day). No "implement later" stubs.
- [x] **Type consistency:** `Proposal` dataclass used in parser test matches implementation. `ProposalStatus` enum values (APPROVE, REJECT, EDIT, PENDING) match the approval grammar in Task 1.2 and Task 1.5.

## Open (acceptable deferrals)

- Detailed Make module configuration for each scenario (covered at "sufficient detail for engineer" level; exact screen-by-screen Make UI steps live in the MCP tool's knowledge, not the plan)
- Error-payload specifics for Make API failures (log-and-propose-diagnostic pattern covers the general case)
- Playwright selector specifics for Nextdoor (will surface during Day 5; templates updated in `social-media-manager.md` as selectors are discovered)

---

## Files created/modified (summary)

**Created:**
- `operations/ad-ops/parse_approvals.py`
- `operations/ad-ops/test_parse_approvals.py`
- `.claude/agents/social-media-manager.md`
- `marketing/google-ads/campaign-templates/search-deck-builders.json`
- `marketing/facebook-ads/campaign-templates/meta-lead-standard.json`
- `marketing/facebook-ads/ad-set-templates/central-wi-cold-homeowners.json`
- `marketing/facebook-ads/ad-templates/social-proof-angle.json`
- `marketing/facebook-ads/ad-templates/problem-solution-angle.json`
- `marketing/facebook-ads/ad-templates/seasonal-urgency-angle.json`
- `.claude/playwright-state/nextdoor.json` (gitignored)
- Empty `operations/ad-metrics/google/.gitkeep` et al (10 scaffolding files)

**Modified:**
- `_vault/state-of-cwdb.md` (added Pending Approvals + Executed lanes)
- `.claude/agents/analytics.md` (Loop 1 READ section appended)
- `.claude/agents/ad-campaign.md` (Propose + Execute modes + scenario mapping table)
- `.claude/agents/cwdb-ceo-operator.md` (Execute-dispatch routine)
- `.gitignore` (`.claude/playwright-state/`)

**Generated by agents at runtime:**
- `operations/ad-metrics/google/{YYYY-MM-DD}.json` (daily by R1)
- `operations/ad-metrics/meta/{YYYY-MM-DD}.json` (daily by R2)
- `operations/ad-alerts/{YYYY-MM-DD}.md` (daily by analytics)
- `operations/ad-executions/{YYYY-MM-DD}.md` (append on each execute)
- `finance/reports/performance/{YYYY-MM-DD}-ads-daily.md` (daily digest)

**External state:**
- 16 Make scenarios (2 read + 14 write) created in Make account
- 2 Make connections (Google Ads, Meta Ads) authorized
