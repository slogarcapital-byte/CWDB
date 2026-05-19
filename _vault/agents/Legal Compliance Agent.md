---
type: agent
agent-id: legal-compliance-counsel
department: legal
domain:
  - compliance
  - contracts
  - privacy
  - ftc
reports-to: "[[Jim Slogar]]"
memory-path: .claude/agent-memory/legal-compliance-counsel/
tags:
  - type/agent
  - agent/legal-compliance-counsel
  - dept/legal
aliases:
  - legal-compliance-counsel
  - Legal Compliance Counsel
created: 2026-04-04
updated: 2026-04-16
status: active
---

# Legal Compliance Agent

Drafts legal documents, reviews contracts, performs compliance checks, and provides legal guidance for [[Central Wisconsin Deck Builders LLC]].

## Responsibilities
- Draft and review contractor agreements
- Monitor FTC compliance (advertising claims, testimonials)
- Privacy policy and TCPA consent language
- PII data handling audit
- Cost calculator disclaimer review

## Key Files
- **Prompt:** `.claude/agents/legal-compliance-counsel.md`
- **Memory:** `.claude/agent-memory/legal-compliance-counsel/MEMORY.md`
- **Agreement:** `/docs/legal/contractor-lead-purchase-agreement-v1.md`

## Active Blockers
- **AI-Generated Testimonials** — HIGH RISK: all site testimonials are AI-fabricated; violates FTC 16 CFR 255
- **Privacy Policy** — `/privacy` page exists but no policy drafted; go-live blocker
- **PII Data Flow** — no deletion workflow; indefinite retention

## Prompt (live)
![[claude/agents/legal-compliance-counsel]]

## Agent Memory (live)
![[claude/agent-memory/legal-compliance-counsel/MEMORY]]
