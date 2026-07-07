"""Tab 3 - Diagnostics: live instrument-health panel + audit findings per
platform, with each finding's linked fix tasks shown so findings visibly
retire as the tasks complete."""

from __future__ import annotations

from typing import Any

import streamlit as st

from lib import db, health
from lib.textutil import md_safe

_STATUS_ICON = {"ok": "🟢", "warn": "🟡", "fail": "🔴", "unknown": "⚪"}
_PLATFORM_LABEL = {
    "warehouse": "Supabase warehouse", "hubspot": "HubSpot", "qbo": "QuickBooks",
    "google_ads": "Google Ads", "meta": "Meta Ads", "ga4": "GA4",
    "site": "Webflow site", "scheduler": "Task Scheduler", "make": "Make.com",
    "control_plane": "Control plane (retired)",
}


@st.cache_data(ttl=300, show_spinner=False)
def _load_findings() -> list[dict[str, Any]]:
    return db.select("audit_findings",
                     "select=*&section=eq.platform&order=sort_order.asc")


@st.cache_data(ttl=120, show_spinner=False)
def _load_task_status() -> dict[str, dict[str, Any]]:
    rows = db.select("dashboard_tasks", "select=source_ref,title,status")
    return {r["source_ref"]: r for r in rows if r.get("source_ref")}


def _health_panel(read_only: bool) -> None:
    st.subheader("Instrument health")
    if not read_only:
        if st.button("Run health checks now"):
            with st.spinner("Checking cron log, warehouse freshness, scheduled tasks…"):
                health.compute_and_store()
            st.cache_data.clear()
            st.rerun()
    rows = health.read_stored()
    if not rows:
        st.caption("No health rows yet - run the checks (local mode) or the data pulls.")
        return
    by_platform: dict[str, list[dict[str, Any]]] = {}
    for r in rows:
        by_platform.setdefault(r["platform"], []).append(r)
    cols = st.columns(3)
    for i, (platform, checks) in enumerate(sorted(by_platform.items())):
        worst = max(checks, key=lambda c: {"ok": 0, "unknown": 1, "warn": 2, "fail": 3}[c["status"]])
        with cols[i % 3].container(border=True, key=f"glass_health_{platform}"):
            st.markdown(f"{_STATUS_ICON[worst['status']]} **{_PLATFORM_LABEL.get(platform, platform)}**")
            for c in checks:
                st.caption(f"{_STATUS_ICON[c['status']]} {c['check_name']}: {c['detail']}")
            st.caption(f"checked {str(checks[0]['checked_at'])[:16].replace('T', ' ')}Z")


def _findings_section() -> None:
    st.subheader("Audit findings by platform (2026-07-05)")
    findings = _load_findings()
    task_status = _load_task_status()
    for f in findings:
        refs = f.get("linked_task_refs") or []
        linked = [task_status.get(r) for r in refs]
        linked = [t for t in linked if t]
        n_open = sum(1 for t in linked if t["status"] in ("open", "deferred"))
        badge = "🟢 all fixes closed" if linked and n_open == 0 else (
            f"🟠 {n_open}/{len(linked)} fixes open" if linked else "")
        with st.expander(f"**{f['title']}** {badge}"):
            st.markdown(md_safe(f["body"]))
            if linked:
                st.markdown("**Linked fixes:**")
                for ref, t in zip(refs, (task_status.get(r) for r in refs)):
                    if not t:
                        continue
                    mark = {"done": "✓", "declined": "✕", "deferred": "…"}.get(t["status"], "○")
                    st.markdown(f"- {mark} `{ref}` {t['title']}")


def render(read_only: bool) -> None:
    st.header("Diagnostics")
    _health_panel(read_only)
    st.divider()
    _findings_section()
