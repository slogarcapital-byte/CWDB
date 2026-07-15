"""Diagnostics health checks (Tab 3 top panel).

Local mode COMPUTES the checks (cron log, Task Scheduler, warehouse freshness)
and persists them to platform_health so the cloud twin can render the same
panel without laptop access. Cloud mode only reads the table.

All checks are cheap and local/warehouse-derived: no ad-platform API calls
here (those live in the pull scripts, which stamp their own health rows).
"""

from __future__ import annotations

import subprocess
from datetime import datetime, timedelta, timezone
from typing import Any

from . import config, db


def _row(platform: str, check: str, status: str, detail: str) -> dict[str, Any]:
    return {"platform": platform, "check_name": check, "status": status,
            "detail": detail, "checked_at": datetime.now(timezone.utc).isoformat()}


def _check_cron_log() -> list[dict[str, Any]]:
    if not config.CRON_LOG.exists():
        return [_row("warehouse", "cron_last_run", "fail", "cron-runs.log not found")]
    lines = config.CRON_LOG.read_text(encoding="utf-8", errors="replace").strip().splitlines()
    run_ends = [ln for ln in lines if "RUN_END" in ln]
    if not run_ends:
        return [_row("warehouse", "cron_last_run", "unknown", "no RUN_END lines")]
    last = run_ends[-1]
    cols = last.split("\t")
    stamp = cols[0] if cols else ""
    ok = "exit=0" in last or "success" in last.lower()
    try:
        age_days = (datetime.now(timezone.utc)
                    - datetime.fromisoformat(stamp.replace("Z", "+00:00"))).days
    except ValueError:
        age_days = None
    status = "ok" if ok else "fail"
    if age_days is not None and age_days >= 2:
        status = "warn"
    detail = f"last run {stamp}" + ("" if ok else " (non-zero exit)")
    if age_days is not None and age_days >= 2:
        detail += f" - {age_days} days ago (laptop-coupled cron, see task #25)"
    return [_row("warehouse", "cron_last_run", status, detail)]


def _check_freshness() -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    checks = [
        ("hubspot", "fact_leads", "updated_at"),
        ("google_ads", "fact_ad_spend_daily", "updated_at"),
        ("ga4", "fact_traffic_daily", "updated_at"),
        ("jobtread", "raw_jobtread_snapshot", "pulled_at"),
    ]
    for platform, table, col in checks:
        try:
            data = db.select(table, f"select={col}&order={col}.desc&limit=1")
            if not data:
                rows.append(_row(platform, f"{table}_freshness", "unknown", "table empty"))
                continue
            stamp = data[0][col]
            age = datetime.now(timezone.utc) - datetime.fromisoformat(str(stamp).replace("Z", "+00:00"))
            status = "ok" if age < timedelta(days=2) else ("warn" if age < timedelta(days=5) else "fail")
            rows.append(_row(platform, f"{table}_freshness", status,
                             f"newest row updated {age.days}d ago"))
        except Exception as exc:  # noqa: BLE001 - health panel must never crash the app
            rows.append(_row(platform, f"{table}_freshness", "unknown", str(exc)[:200]))
    return rows


def _check_last_lead() -> list[dict[str, Any]]:
    try:
        data = db.select("v_clean_leads", "select=submitted_at&order=submitted_at.desc&limit=1")
        if not data:
            return [_row("hubspot", "days_since_last_lead", "unknown", "no leads")]
        last = datetime.fromisoformat(str(data[0]["submitted_at"]).replace("Z", "+00:00"))
        days = (datetime.now(timezone.utc) - last).days
        status = "ok" if days <= 7 else ("warn" if days <= 14 else "fail")
        return [_row("hubspot", "days_since_last_lead", status,
                     f"{days} days (last: {last.date()})")]
    except Exception as exc:  # noqa: BLE001
        return [_row("hubspot", "days_since_last_lead", "unknown", str(exc)[:200])]


def _check_consent_missing() -> list[dict[str, Any]]:
    try:
        data = db.select("v_clean_leads", "select=lead_id&consent_missing=eq.true")
        n = len(data)
        status = "ok" if n == 0 else "warn"
        return [_row("hubspot", "consent_missing_leads", status,
                     f"{n} lead(s) need consent re-capture before SMS" if n else "none")]
    except Exception as exc:  # noqa: BLE001
        return [_row("hubspot", "consent_missing_leads", "unknown", str(exc)[:200])]


def _check_ad_spend_yesterday() -> list[dict[str, Any]]:
    rows = []
    try:
        data = db.select(
            "fact_ad_spend_daily",
            "select=platform,spend_date,cost_cents&order=spend_date.desc&limit=60",
        )
        for platform in ("google_ads", "meta"):
            plat_rows = [r for r in data if r["platform"] == platform]
            if not plat_rows:
                rows.append(_row(platform, "spend_recent", "unknown", "no spend rows"))
                continue
            latest_date = plat_rows[0]["spend_date"]
            total = sum(r["cost_cents"] for r in plat_rows if r["spend_date"] == latest_date) / 100
            note = f"latest spend day {latest_date}: ${total:,.2f}"
            if platform == "meta":
                note += " (campaign PAUSED 7/5 until Pixel Lead event fixed)"
            rows.append(_row(platform, "spend_recent", "ok", note))
    except Exception as exc:  # noqa: BLE001
        rows.append(_row("google_ads", "spend_recent", "unknown", str(exc)[:200]))
    return rows


def _check_scheduled_tasks() -> list[dict[str, Any]]:
    rows = []
    for task, expect_enabled in (("CWDB-Warehouse-Daily", True),
                                 ("CWDB-Control-Tick", False),
                                 ("CWDB-Dashboard", False)):
        try:
            out = subprocess.run(
                ["schtasks", "/Query", "/TN", f"\\CWDB\\{task}", "/FO", "LIST"],
                capture_output=True, text=True, timeout=15,
            )
            if out.returncode != 0:
                rows.append(_row("scheduler", task, "warn" if expect_enabled else "ok",
                                 "task not found"))
                continue
            disabled = "Disabled" in out.stdout
            if expect_enabled:
                rows.append(_row("scheduler", task, "fail" if disabled else "ok",
                                 "DISABLED" if disabled else "enabled"))
            else:
                # Control plane retired: disabled is the desired state.
                rows.append(_row("scheduler", task, "ok" if disabled else "warn",
                                 "disabled (retired, as intended)" if disabled
                                 else "still enabled - control plane is retired"))
        except Exception as exc:  # noqa: BLE001
            rows.append(_row("scheduler", task, "unknown", str(exc)[:120]))
    return rows


def compute_and_store() -> list[dict[str, Any]]:
    """Run all checks (local mode), upsert to platform_health, return rows."""
    rows = (_check_cron_log() + _check_freshness() + _check_last_lead()
            + _check_consent_missing() + _check_ad_spend_yesterday()
            + _check_scheduled_tasks())
    if not config.is_read_only():
        db.insert("platform_health", rows, on_conflict="platform,check_name", merge=True)
    return rows


def read_stored() -> list[dict[str, Any]]:
    return db.select("platform_health", "select=*&order=platform.asc,check_name.asc")
