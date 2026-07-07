"""Tab 2 - To-Do: canonical task list, grouped by owner, with action buttons.

Buttons: Complete / Defer / Decline / Send to Claude (Do it now = new terminal;
Queue it = surfaced by the next Claude session's SessionStart hook).
Every mutation appends a dashboard_events row and regenerates the board mirrors.
"""

from __future__ import annotations

import html
from datetime import date, datetime, timezone
from typing import Any

import streamlit as st

from lib import board_mirror, db, events, prompts, runners
from lib.textutil import md_safe

_GROUPS = [
    ("jim", "Jim (real life)"),
    ("project", "Project work (Claude + agents)"),
    ("others", "Other people (Ben, John, legal, CPA)"),
]
_PRIORITY_CLASS = {"P0": "p0", "P1": "p1", "P2": "p2"}


@st.cache_data(ttl=120, show_spinner=False)
def _load_tasks() -> list[dict[str, Any]]:
    return db.select("dashboard_tasks", "select=*&order=priority.asc,task_id.asc")


def _mutate(task: dict[str, Any], patch: dict[str, Any], event_payload: dict[str, Any]) -> None:
    patch["updated_at"] = datetime.now(timezone.utc).isoformat()
    db.update("dashboard_tasks", f"task_id=eq.{task['task_id']}", patch)
    events.emit("task_status_change",
                {"title": task["title"], "source_ref": task.get("source_ref"), **event_payload},
                task_id=task["task_id"])
    board_mirror.regenerate()
    st.cache_data.clear()
    st.rerun()


def _task_card(t: dict[str, Any], read_only: bool) -> None:
    tid = t["task_id"]
    with st.container(border=True, key=f"glass_task_{tid}"):
        prio = str(t.get("priority") or "")
        chip_cls = _PRIORITY_CLASS.get(prio)
        chip = (f'<span class="cwdb-chip {chip_cls}">{html.escape(prio)}</span>'
                if chip_cls else html.escape(prio))
        effort = (f'<span class="cwdb-task-effort">{html.escape(str(t["effort"]))}</span>'
                  if t.get("effort") else "")
        st.markdown(
            f'<div class="cwdb-task-head">{chip}'
            f'<span class="cwdb-task-title">{html.escape(str(t["title"]))}</span>'
            f'{effort}</div>',
            unsafe_allow_html=True,
        )
        if t.get("detail"):
            st.caption(md_safe(t["detail"]))
        meta = f"`{t.get('source_ref') or 'manual'}` · owner: {t.get('owner_detail') or t['owner_group']}"
        if t["status"] == "deferred" and t.get("deferred_until"):
            meta += f" · deferred until {t['deferred_until']}"
        if t.get("notes"):
            meta += f"\n\nNote: {t['notes']}"
        st.markdown(md_safe(meta))

        if read_only:
            return

        _sp, c1, c2, c3, c4, c5 = st.columns(
            [1.7, 1.05, 0.75, 0.85, 1.35, 1.3], gap="small")
        if c1.button("Complete", key=f"done_{tid}", width="stretch"):
            _mutate(t, {"status": "done",
                        "completed_at": datetime.now(timezone.utc).isoformat()},
                    {"new_status": "done"})
        if c2.button("Defer", key=f"defer_btn_{tid}", type="tertiary",
                     width="stretch"):
            st.session_state[f"defer_open_{tid}"] = True
        if c3.button("Decline", key=f"decline_btn_{tid}", type="tertiary",
                     width="stretch"):
            st.session_state[f"decline_open_{tid}"] = True
        if c4.button("Claude: do it now", key=f"send_{tid}", width="stretch",
                     help="Opens a new terminal running Claude Code with this task"):
            prompt = prompts.build_task_prompt(t)
            pf = runners.open_claude_terminal(t["title"], prompt)
            events.emit("sent_to_terminal", {"title": t["title"], "prompt_file": str(pf)},
                        task_id=tid)
            st.toast("Terminal opened - Claude is on it.")
        if c5.button("Claude: queue it", key=f"queue_{tid}", width="stretch",
                     help="Queued for pickup at the start of the next Claude session"):
            events.emit("queued_for_claude",
                        {"title": t["title"], "prompt": prompts.build_task_prompt(t)},
                        task_id=tid)
            st.toast("Queued for the next Claude session.")

        if st.session_state.get(f"defer_open_{tid}"):
            with st.form(key=f"defer_form_{tid}"):
                until = st.date_input("Defer until", value=date.today(), key=f"defer_date_{tid}")
                if st.form_submit_button("Confirm defer"):
                    st.session_state.pop(f"defer_open_{tid}", None)
                    _mutate(t, {"status": "deferred", "deferred_until": until.isoformat()},
                            {"new_status": "deferred", "until": until.isoformat()})
        if st.session_state.get(f"decline_open_{tid}"):
            with st.form(key=f"decline_form_{tid}"):
                reason = st.text_input("Why decline?", key=f"decline_reason_{tid}")
                if st.form_submit_button("Confirm decline"):
                    st.session_state.pop(f"decline_open_{tid}", None)
                    notes = (t.get("notes") or "")
                    notes = (notes + "\n" if notes else "") + f"Declined: {reason}"
                    _mutate(t, {"status": "declined", "notes": notes},
                            {"new_status": "declined", "reason": reason})


def _add_task_form() -> None:
    with st.expander("Add task"):
        with st.form("add_task", clear_on_submit=True):
            title = st.text_input("Title")
            detail = st.text_area("Detail", height=80)
            c1, c2, c3 = st.columns(3)
            owner = c1.selectbox("Owner", [g for g, _ in _GROUPS],
                                 format_func=dict(_GROUPS).get)
            priority = c2.selectbox("Priority", ["P0", "P1", "P2"], index=1)
            agent = c3.text_input("Suggested agent (optional)")
            if st.form_submit_button("Create") and title.strip():
                created = db.insert("dashboard_tasks", [{
                    "title": title.strip(), "detail": detail.strip() or None,
                    "owner_group": owner, "priority": priority,
                    "suggested_agent": agent.strip() or None,
                }])
                events.emit("task_created", {"title": title.strip(), "manual": True},
                            task_id=created[0]["task_id"] if created else None)
                board_mirror.regenerate()
                st.cache_data.clear()
                st.rerun()


def render(read_only: bool) -> None:
    st.header("To-Do")
    tasks = _load_tasks()

    open_tasks = [t for t in tasks if t["status"] == "open"]
    deferred = [t for t in tasks if t["status"] == "deferred"]
    done = [t for t in tasks if t["status"] == "done"]
    declined = [t for t in tasks if t["status"] == "declined"]

    # Auto-wake: deferred tasks whose date has passed show with the open ones.
    today = date.today().isoformat()
    woken = [t for t in deferred if (t.get("deferred_until") or "9999") <= today]
    sleeping = [t for t in deferred if t not in woken]

    st.caption(f"{len(open_tasks) + len(woken)} open · {len(sleeping)} deferred · "
               f"{len(done)} done · {len(declined)} declined")

    if not read_only:
        _add_task_form()

    for group, label in _GROUPS:
        rows = [t for t in open_tasks + woken if t["owner_group"] == group]
        if not rows:
            continue
        st.subheader(label)
        for t in rows:
            _task_card(t, read_only)

    if sleeping:
        with st.expander(f"Deferred ({len(sleeping)})"):
            for t in sleeping:
                _task_card(t, read_only)
    if done:
        with st.expander(f"Done ({len(done)})"):
            for t in sorted(done, key=lambda x: str(x.get("completed_at") or ""), reverse=True):
                st.markdown(f"- ✓ ~~{t['title']}~~ `{t.get('source_ref') or 'manual'}` "
                            f"({str(t.get('completed_at') or '')[:10]})")
                if t.get("notes"):
                    st.caption(md_safe(t["notes"]))
    if declined:
        with st.expander(f"Declined ({len(declined)})"):
            for t in declined:
                st.markdown(f"- ✕ ~~{t['title']}~~")
                if t.get("notes"):
                    st.caption(md_safe(t["notes"]))
