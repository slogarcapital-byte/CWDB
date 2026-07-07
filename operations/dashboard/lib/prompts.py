"""Build the Send-to-Claude prompt for a task (both Do-it-now and Queue paths).

The prompt carries the return leg of the two-way loop: it instructs Claude to
update the task's Supabase row and append a completion event when done, so
work finished in a terminal is visible on the dashboard without any sync step.
"""

from __future__ import annotations

from typing import Any


def build_task_prompt(t: dict[str, Any]) -> str:
    parts = [
        f"Work on this CWDB HQ dashboard task (dashboard_tasks.task_id={t['task_id']}, "
        f"source {t.get('source_ref') or 'manual'}):",
        "",
        f"TITLE: {t['title']}",
    ]
    if t.get("detail"):
        parts += ["", f"DETAIL: {t['detail']}"]
    meta = f"Priority {t['priority']} · owner {t.get('owner_detail') or t['owner_group']}"
    if t.get("effort"):
        meta += f" · est. effort {t['effort']}"
    parts += ["", meta]
    if t.get("suggested_agent"):
        parts += ["", f"SUGGESTED AGENT: use the {t['suggested_agent']} agent (Agent tool) "
                      "for the domain work if it fits."]
    if t.get("files"):
        parts += ["", "RELEVANT FILES:", t["files"]]
    if t.get("notes"):
        parts += ["", f"NOTES: {t['notes']}"]
    parts += [
        "",
        "CONTEXT: this task comes from the 2026-07-05 full business audit "
        "(_vault/briefs/2026-07-05-audit.md) via the CWDB HQ dashboard.",
        "",
        "WHEN DONE (or blocked), close the loop in Supabase (project iabiwsbmnbxmkjvkgfhg):",
        f"1. Update the task row: PATCH dashboard_tasks (task_id={t['task_id']}) -> "
        "status='done' + completed_at=now + a one-line notes summary "
        "(or leave status and write a blocked note).",
        "2. Append a dashboard_events row: event_type='task_status_change', "
        f"task_id={t['task_id']}, actor='claude', payload = what changed, "
        "processed_at = now() (you ARE the processor for your own event).",
        "Use the Supabase MCP tool or PostgREST with the service key from .env.local.",
    ]
    return "\n".join(parts)
