"""Tab 4 - Financials: real QBO P&L, cash/A-R position, tax reserve tracker,
per-job profitability. Data comes from the fin_* tables written by
templates/scripts/pull-qbo-financials.ps1 (Refresh button re-runs it)."""

from __future__ import annotations

from datetime import date, datetime, timezone
from typing import Any

import pandas as pd
import streamlit as st

from lib import db, events, runners

_TAX_RATE = 0.35
_Q3_DEADLINE = date(2026, 9, 15)


@st.cache_data(ttl=300, show_spinner=False)
def _load() -> dict[str, Any]:
    out: dict[str, Any] = {}
    out["position"] = db.select("fin_position", "select=*&order=position_id.desc&limit=1")
    out["pl"] = db.select("fin_pl_monthly", "select=*&order=period.asc")
    out["jobs"] = db.select("v_kpi_job_profitability", "select=*")
    out["settings"] = {s["key"]: s["value"]
                       for s in db.select("dashboard_settings", "select=*")}
    return out


def _money_cents(cents: Any) -> str:
    try:
        return f"${int(cents) / 100:,.2f}"
    except (TypeError, ValueError):
        return "-"


def _pl_table(pl_rows: list[dict[str, Any]]) -> None:
    if not pl_rows:
        st.caption("No P&L rows yet - run the QBO refresh.")
        return
    df = pd.DataFrame(pl_rows)
    # to_numeric: Python None from the API otherwise survives the pivot as a
    # literal "None" cell (the styler's na_rep only catches real NaN).
    df["amount"] = pd.to_numeric(df["amount_cents"], errors="coerce") / 100.0
    df["month"] = pd.to_datetime(df["period"]).dt.strftime("%b %Y")
    # Order account types the way a P&L reads.
    type_order = ["Income", "COGS", "GrossProfit", "Expense", "OtherIncome",
                  "OtherExpense", "NetOperatingIncome", "NetOtherIncome", "NetIncome"]
    df["type_rank"] = df["account_type"].map({t: i for i, t in enumerate(type_order)}).fillna(99)
    pivot = (df.pivot_table(index=["type_rank", "account_type", "account_name"],
                            columns="month", values="amount", aggfunc="sum")
             .sort_index())
    # Column order chronological
    months = (pd.to_datetime(df["period"]).dt.to_period("M").drop_duplicates()
              .sort_values().dt.strftime("%b %Y").tolist())
    months = [m for m in dict.fromkeys(months) if m in pivot.columns]
    pivot = pivot[months]
    pivot["YTD"] = pivot.sum(axis=1)
    pivot.index = [f"{t} · {n}" if n != t else t
                   for (_, t, n) in pivot.index]
    # column_config, not a pandas Styler: Streamlit's Styler path breaks under
    # pandas 3.x, and its grid paints null cells as a literal faded "None".
    # fillna(0) matches how QBO itself renders no-activity months (0.00);
    # accounting format = commas + parenthesized negatives.
    pivot = pivot.fillna(0.0)
    col_cfg = {c: st.column_config.NumberColumn(format="accounting")
               for c in pivot.columns}
    st.dataframe(pivot, width="stretch", column_config=col_cfg)


def _tax_reserve(position: dict[str, Any], settings: dict[str, Any],
                 read_only: bool) -> None:
    st.subheader("Tax reserve")
    ytd_net = int(position.get("ytd_net_income_cents") or 0)
    target = max(0, int(ytd_net * _TAX_RATE))
    set_aside = int(settings.get("tax_set_aside_cents", 0) or 0)
    days_left = (_Q3_DEADLINE - date.today()).days

    c1, c2, c3 = st.columns(3)
    c1.metric("Reserve target (35% of YTD net)", _money_cents(target))
    c2.metric("Set aside so far", _money_cents(set_aside),
              f"{_money_cents(set_aside - target)} vs target")
    c3.metric("Q3 1040-ES deadline", _Q3_DEADLINE.strftime("%b %d"),
              f"{days_left} days away")
    if not read_only:
        with st.expander("Update set-aside amount"):
            with st.form("tax_set_aside"):
                dollars = st.number_input("Amount set aside ($)",
                                          value=set_aside / 100.0, min_value=0.0, step=50.0)
                if st.form_submit_button("Save"):
                    db.insert("dashboard_settings", [{
                        "key": "tax_set_aside_cents",
                        "value": int(round(dollars * 100)),
                        "updated_at": datetime.now(timezone.utc).isoformat(),
                    }], on_conflict="key", merge=True)
                    events.emit("decision", {"setting": "tax_set_aside_cents",
                                             "value_dollars": dollars})
                    st.cache_data.clear()
                    st.rerun()


def _jobs_table(jobs: list[dict[str, Any]]) -> None:
    st.subheader("Job profitability")
    if not jobs:
        st.caption("No job rows yet - run the QBO refresh.")
        return
    df = pd.DataFrame(jobs)[["job", "client_name", "job_status", "revenue",
                             "direct_costs", "gross_profit", "gp_pct"]]
    st.dataframe(df, width="stretch", hide_index=True, column_config={
        "revenue": st.column_config.NumberColumn("Revenue", format="dollar"),
        "direct_costs": st.column_config.NumberColumn("Direct costs", format="dollar"),
        "gross_profit": st.column_config.NumberColumn("Gross profit", format="dollar"),
        "gp_pct": st.column_config.NumberColumn("GP %", format="%.0f%%"),
        "job": st.column_config.TextColumn("Job"),
        "client_name": st.column_config.TextColumn("Client"),
        "job_status": st.column_config.TextColumn("Status"),
    })
    st.caption("Honesty note: costs only count when the QBO expense line is tagged "
               "to a Customer. Most early expenses are untagged, so GP% reads high. "
               "Tag job expenses in QBO going forward (audit task #24).")


def render(read_only: bool) -> None:
    st.header("Financials")

    if not read_only:
        if st.button("Refresh from QBO",
                     help="Runs pull-qbo-financials.ps1 in the background (~30s), "
                          "then re-query"):
            log = runners.run_qbo_pull()
            events.emit("refresh_run", {"scope": "qbo", "log": str(log)})
            st.info(f"QBO pull started in the background. Log: {log}. "
                    "Re-open this tab in ~30 seconds.")

    data = _load()
    position = (data["position"] or [{}])[0]
    if position:
        as_of = str(position.get("as_of") or "")[:16].replace("T", " ")
        st.caption(f"Position as of {as_of} UTC")
        c1, c2, c3, c4 = st.columns(4)
        c1.metric("YTD net income", _money_cents(position.get("ytd_net_income_cents")))
        c2.metric("Cash (checking)", _money_cents(position.get("cash_cents")))
        c3.metric("Card liability", _money_cents(position.get("card_liability_cents")))
        c4.metric("Accounts receivable", _money_cents(position.get("ar_total_cents")))
        open_inv = position.get("open_invoices") or []
        if open_inv:
            with st.expander(f"Open invoices ({len(open_inv)})"):
                for inv in open_inv:
                    st.markdown(f"- **{inv.get('doc_number')}** {inv.get('customer')} · "
                                f"{_money_cents(inv.get('balance_cents'))} due {inv.get('due_date')}")

    st.divider()
    st.subheader("P&L by month (cash basis)")
    _pl_table(data["pl"])

    st.divider()
    _tax_reserve(position, data["settings"], read_only)

    st.divider()
    _jobs_table(data["jobs"])
