"""Event log helper: every dashboard mutation appends a dashboard_events row.

processed_at stays NULL until a Claude session ingests the event via
/dashboard-sync (the SessionStart hook surfaces the unprocessed count).
This is the dashboard->Claude half of the two-way loop.
"""

from __future__ import annotations

from typing import Any

from . import db


def emit(event_type: str, payload: dict[str, Any] | None = None,
         task_id: int | None = None, actor: str = "dashboard") -> None:
    row: dict[str, Any] = {
        "event_type": event_type,
        "payload": payload or {},
        "actor": actor,
    }
    if task_id is not None:
        row["task_id"] = task_id
    db.insert("dashboard_events", [row])
