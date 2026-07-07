"""Thin PostgREST client for CWDB HQ (requests-based, mirrors load-supabase.ps1).

All reads/writes go through here so the read-only cloud mode has one choke
point: `insert`/`update` raise in cloud mode before any HTTP happens.
"""

from __future__ import annotations

import json
from typing import Any

import requests

from . import config

_TIMEOUT = 30


def _headers(write: bool = False) -> dict[str, str]:
    url, key = config.get_supabase_credentials()
    h = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
    }
    if write:
        h["Prefer"] = "return=representation"
    return h


def _base() -> str:
    url, _ = config.get_supabase_credentials()
    return f"{url}/rest/v1"


def select(table: str, query: str = "select=*") -> list[dict[str, Any]]:
    """GET rows. `query` is a raw PostgREST query string (no leading ?)."""
    r = requests.get(f"{_base()}/{table}?{query}", headers=_headers(), timeout=_TIMEOUT)
    r.raise_for_status()
    return r.json()


def _guard_write() -> None:
    if config.is_read_only():
        raise PermissionError("CWDB HQ is in cloud read-only mode; writes are disabled.")


def insert(table: str, rows: list[dict[str, Any]], on_conflict: str | None = None,
           merge: bool = False) -> list[dict[str, Any]]:
    _guard_write()
    url = f"{_base()}/{table}"
    headers = _headers(write=True)
    if on_conflict:
        url += f"?on_conflict={on_conflict}"
    if merge:
        headers["Prefer"] = "resolution=merge-duplicates,return=representation"
    r = requests.post(url, headers=headers, data=json.dumps(rows), timeout=_TIMEOUT)
    r.raise_for_status()
    return r.json() if r.text else []


def update(table: str, filter_query: str, patch: dict[str, Any]) -> list[dict[str, Any]]:
    """PATCH rows matching `filter_query` (e.g. 'task_id=eq.7')."""
    _guard_write()
    r = requests.patch(f"{_base()}/{table}?{filter_query}", headers=_headers(write=True),
                       data=json.dumps(patch), timeout=_TIMEOUT)
    r.raise_for_status()
    return r.json() if r.text else []
