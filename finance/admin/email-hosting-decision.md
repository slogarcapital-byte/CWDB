---
type: decision-log
date: 2026-05-08
ship_type: artifact-prod
shipped_by: cwdb-ceo-operator
authority: 24h-default-ship-rule (CLAUDE.md operator clause)
related: WB-009 (directives.md)
re_evaluate_on: first homeowner-deal close OR $5K MRR (whichever first)
---

# Email Hosting Decision — cwdeckbuilders.com

## Decision

**Path (a): Skip the alias. Use `slogarjw@gmail.com` with a Gmail "reply-to" set to `info@cwdeckbuilders.com` for outbound homeowner replies.**

No MX records configured. No paid mailbox. No Workspace, no GoDaddy M365.

## Rationale

- **Cheapest reversible:** zero ongoing cost, zero DNS surface, zero account migration debt later.
- **Send-As + reply-to is sufficient** for the current volume (5 contacts in pipeline, 0 closes). Homeowners see `info@cwdeckbuilders.com` on outbound; replies route to slogarjw@gmail.com transparently.
- **Inbound forwarding is not blocking** — every form submission lands in HubSpot regardless of MX. The only inbound need is direct emails from homeowners replying to outbound, which Send-As handles natively.
- **Volume floor unverified.** Spending $6/mo on Workspace before knowing whether the funnel produces deals at all is a Principle 2 violation (build before validate).

## Reversibility

- **To upgrade to Google Workspace:** ~30 min — register Workspace, set MX records at GoDaddy, add domain alias, migrate Send-As.
- **To upgrade to GoDaddy M365:** ~20 min — already in GoDaddy ecosystem; one-click add.
- **No data migration needed** — there's no inbox content yet to move.

## Re-evaluate trigger

This decision is binding until **either**:
1. **First homeowner deal closes** (validates the funnel; brand polish becomes worth $6/mo), OR
2. **$5K MRR** (volume justifies professional hosting independent of brand argument).

Whichever fires first reopens WB-009 with a new recommendation.

## Why default-ship today

Per CLAUDE.md 24h default-ship rule: this decision was carried 14+ days with no `%...%` resolution. CEO recommendation in §5 of the daily brief was `%a%` for ~5 consecutive briefs. At 14 days of carry on a fully-reversible decision, default-ship is the operator's job.

## Rollback

Delete this file and reopen WB-009 in directives.md. No infrastructure was changed.
