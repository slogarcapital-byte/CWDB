"""Tab 1 - Command: KPI scorecard, exec summary, board-of-counselors strategy."""

from __future__ import annotations

import json
from typing import Any

import streamlit as st

from lib import config, db, events, runners
from lib.textutil import md_safe


# ---------------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------------

@st.cache_data(ttl=300, show_spinner=False)
def _load_kpis() -> dict[str, Any]:
    out: dict[str, Any] = {}
    for key, view, query in [
        ("booked", "v_kpi_booked_revenue", "select=*&order=month.desc&limit=6"),
        ("jobs", "v_kpi_job_profitability", "select=*"),
        ("close", "v_kpi_close_rate", "select=*&order=month.desc&limit=6"),
        ("cpbj", "v_kpi_cost_per_booked_job", "select=*&order=month.desc&limit=6"),
        ("cycle", "v_kpi_cycle_time", "select=*&order=submitted_at.desc&limit=30"),
        ("backlog", "v_kpi_backlog", "select=*"),
        ("funnel", "v_lead_funnel", "select=*&order=month.desc&limit=6"),
    ]:
        try:
            out[key] = db.select(view, query)
        except Exception as exc:  # noqa: BLE001
            out[key] = []
            out[f"{key}_error"] = str(exc)[:200]
    return out


@st.cache_data(ttl=300, show_spinner=False)
def _load_counsel() -> dict[str, Any] | None:
    rows = db.select("counsel_runs", "select=*&order=run_id.desc&limit=1")
    return rows[0] if rows else None


@st.cache_data(ttl=3600, show_spinner=False)
def _load_exec_finding() -> dict[str, Any] | None:
    rows = db.select("audit_findings",
                     "select=*&section=eq.exec_summary&order=audit_date.desc&limit=1")
    return rows[0] if rows else None


# ---------------------------------------------------------------------------
# Render
# ---------------------------------------------------------------------------

def _money(x: Any) -> str:
    try:
        return f"${float(x):,.0f}"
    except (TypeError, ValueError):
        return "-"


def _kpi_cards(kpis: dict[str, Any]) -> None:
    booked = kpis.get("booked") or []
    jobs = kpis.get("jobs") or []
    close = kpis.get("close") or []
    cpbj = kpis.get("cpbj") or []
    cycle = kpis.get("cycle") or []
    backlog = (kpis.get("backlog") or [{}])[0]

    total_booked = sum(float(r.get("booked_revenue") or 0) for r in booked)
    jobs_booked = sum(int(r.get("jobs_booked") or 0) for r in booked)

    real_jobs = [r for r in jobs if float(r.get("revenue") or 0) > 100]  # skip $5 test
    gp_total = sum(float(r.get("gross_profit") or 0) for r in real_jobs)
    gp_pcts = [float(r["gp_pct"]) for r in real_jobs if r.get("gp_pct") is not None]
    avg_gp_pct = sum(gp_pcts) / len(gp_pcts) if gp_pcts else None

    delivered = sum(int(r.get("estimates_delivered") or 0) for r in close)
    accepted = sum(int(r.get("estimates_accepted") or 0) for r in close)
    open_value = sum(float(r.get("open_estimate_value") or 0) for r in close)
    close_rate = (100 * accepted / delivered) if delivered else 0

    spend_months = [r for r in cpbj if float(r.get("ad_spend") or 0) > 0]
    total_spend = sum(float(r.get("ad_spend") or 0) for r in spend_months)
    cost_per_job = (total_spend / jobs_booked) if jobs_booked else None

    days = [float(r["days_lead_to_estimate"]) for r in cycle
            if r.get("days_lead_to_estimate") is not None]
    avg_cycle = sum(days) / len(days) if days else None

    cards = [
        ("Booked contract revenue (all time)", _money(total_booked),
         f"{jobs_booked} job(s) signed"),
        ("Gross profit per job",
         _money(gp_total / len(real_jobs)) if real_jobs else "-",
         f"avg GP {avg_gp_pct:.0f}% (costs under-tagged)" if avg_gp_pct else "no QBO job costs yet"),
        ("Estimate close rate", f"{close_rate:.0f}%",
         f"{accepted}/{delivered} · {_money(open_value)} open pipeline"),
        ("Cost per booked job",
         _money(cost_per_job) if cost_per_job else "-",
         f"{_money(total_spend)} lifetime ad spend, target 300-500"),
        ("Lead → estimate cycle",
         f"{avg_cycle:.1f} d" if avg_cycle is not None else "-",
         "target same-day first touch"),
        ("Backlog", f"{int(backlog.get('jobs_in_backlog') or 0)} job(s)",
         f"{_money(backlog.get('backlog_value') or 0)} signed, not complete"),
    ]
    for row_start in (0, 3):
        cols = st.columns(3)
        for i, (label, value, delta) in enumerate(cards[row_start:row_start + 3]):
            with cols[i], st.container(border=True, key=f"glass_kpi_{row_start + i}"):
                st.metric(label, value, delta)

    funnel = kpis.get("funnel") or []
    consent_missing = sum(int(r.get("leads_consent_missing") or 0) for r in funnel)
    if consent_missing:
        st.warning(f"{consent_missing} lead(s) are ingested with consent_missing - "
                   "re-capture TCPA consent before texting (task #5).", icon="⚠️")


def _counsel_section(read_only: bool) -> None:
    st.subheader("Board of Counselors")
    latest = _load_counsel()

    if not read_only:
        col_a, col_b = st.columns([1, 2])
        running = latest and latest.get("status") == "running"
        if running:
            col_a.button("Convening…", disabled=True)
            col_b.caption("A counsel run is in progress (~5-10 min). Refresh to check.")
        elif col_a.button("Convene the Board", type="primary",
                          help="Headless Claude run: specialty agents → CEO brief → "
                               "5-lens board → chairman verdict. ~10-13 agent "
                               "invocations, ~5-10 minutes."):
            log = runners.run_counsel()
            events.emit("counsel_convened", {"log": str(log)})
            st.cache_data.clear()
            st.info(f"Board convening started. Log: {log}")
            st.rerun()

    if not latest:
        st.caption("No counsel runs yet. The exec summary below is from the "
                   "2026-07-05 audit; convene the board for a fresh verdict.")
        return
    if latest.get("status") == "failed":
        st.error(f"Last counsel run failed: {latest.get('error') or 'unknown error'}")
        return
    if latest.get("status") == "running":
        st.info("Counsel run in progress…")
        return

    st.caption(f"Last convened: {str(latest['ran_at'])[:16].replace('T', ' ')} UTC "
               f"(run #{latest['run_id']})")
    if latest.get("chairman_verdict"):
        st.markdown("**Chairman's verdict**")
        st.markdown(md_safe(latest["chairman_verdict"]))
    if latest.get("ceo_brief"):
        with st.expander("CEO strategy brief"):
            st.markdown(md_safe(latest["ceo_brief"]))
    lenses = latest.get("lens_outputs") or []
    if isinstance(lenses, str):
        lenses = json.loads(lenses)
    if lenses:
        with st.expander("The five lenses"):
            for lens in lenses:
                st.markdown(f"**{lens.get('name', '?')}**")
                st.markdown(md_safe(lens.get("text", "")))
                st.divider()

    moves = latest.get("recommended_moves") or []
    if isinstance(moves, str):
        moves = json.loads(moves)
    if moves:
        st.markdown("**Recommended moves**")
        for i, mv in enumerate(moves):
            cols = st.columns([5, 1])
            cols[0].markdown(md_safe(f"- **{mv.get('title', '?')}** - {mv.get('detail', '')}"))
            if not read_only and cols[1].button("Adopt", key=f"adopt_{latest['run_id']}_{i}"):
                created = db.insert("dashboard_tasks", [{
                    "source_ref": f"counsel-run-{latest['run_id']}#{i + 1}",
                    "title": mv.get("title", "Counsel move"),
                    "detail": mv.get("detail"),
                    "owner_group": mv.get("owner_group", "jim"),
                    "priority": mv.get("priority", "P1"),
                    "suggested_agent": mv.get("suggested_agent"),
                }], on_conflict="source_ref", merge=True)
                if created:
                    events.emit("task_created",
                                {"from": f"counsel-run-{latest['run_id']}",
                                 "title": mv.get("title")},
                                task_id=created[0]["task_id"])
                from lib import board_mirror
                board_mirror.regenerate()
                st.cache_data.clear()
                st.success("Adopted as task.")
                st.rerun()


def render(read_only: bool) -> None:
    st.header("Command")

    kpis = _load_kpis()
    _kpi_cards(kpis)

    st.divider()
    st.subheader("Executive summary")
    latest = _load_counsel()
    if latest and latest.get("status") == "complete" and latest.get("exec_summary"):
        st.markdown(md_safe(latest["exec_summary"]))
        st.caption(f"From counsel run #{latest['run_id']}, "
                   f"{str(latest['ran_at'])[:10]}")
    else:
        finding = _load_exec_finding()
        if finding:
            st.markdown(f"**{finding['title']}** *(audit {finding['audit_date']})*")
            st.markdown(md_safe(finding["body"]))

    st.divider()
    _counsel_section(read_only)
