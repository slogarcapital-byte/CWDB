"""HubSpot read helper for the CWDB estimator.

Fetches recent CRM contacts so the estimator can pre-fill the client fields
instead of forcing a copy-paste from the HubSpot record. Read-only: uses the
existing private-app token (scope crm.objects.contacts.read), supplied via
Streamlit secrets as `hubspot_private_app_token` (same value as the
HUBSPOT_PRIVATE_APP_TOKEN env var the warehouse scripts use). Secrets live in
the Streamlit Cloud dashboard, not in the repo.

HubSpot stores the address as four separate properties (address, city, state,
zip); the estimate wants one `address_line`, and the name is firstname +
lastname. Both are composed here so callers get estimate-ready values.
"""
from __future__ import annotations

import requests
import streamlit as st

_SEARCH_URL = "https://api.hubapi.com/crm/v3/objects/contacts/search"
_PROPERTIES = [
    "firstname", "lastname", "email", "phone",
    "address", "city", "state", "zip",
]
_EXCLUDE_EMAILS = {"slogarjw@gmail.com"}  # Jim's self-test contact


def _token() -> str:
    try:
        return st.secrets.get("hubspot_private_app_token", "")
    except Exception:
        return ""


def compose_name(props: dict) -> str:
    """firstname + lastname, trimmed."""
    first = (props.get("firstname") or "").strip()
    last = (props.get("lastname") or "").strip()
    return f"{first} {last}".strip()


def compose_address_line(props: dict) -> str:
    """Join HubSpot's 4 address fields into one line, e.g.
    '3701 Crystal Dr., Wausau, WI 54401'. Blanks are skipped."""
    street = (props.get("address") or "").strip()
    city = (props.get("city") or "").strip()
    state = (props.get("state") or "").strip()
    zip_ = (props.get("zip") or "").strip()
    locality = " ".join(p for p in (state, zip_) if p)  # "WI 54401"
    return ", ".join(p for p in (street, city, locality) if p)


@st.cache_data(ttl=300, show_spinner=False)
def list_recent_contacts() -> tuple[list[dict], str]:
    """Return (contacts, status).

    status is one of:
      "ok"             - contacts loaded (list may still be empty)
      "not_configured" - no token in secrets; caller should prompt setup
      "error"          - API call failed (a warning is already surfaced)

    Each contact is {id, name, email, phone, address_line, label}, most
    recently modified first. `label` is what the picker dropdown shows.
    Cached for 5 minutes; call .clear() to force a refresh.
    """
    token = _token()
    if not token:
        return [], "not_configured"

    payload = {
        "sorts": [{"propertyName": "lastmodifieddate", "direction": "DESCENDING"}],
        "properties": _PROPERTIES,
        "limit": 100,
    }
    try:
        resp = requests.post(
            _SEARCH_URL,
            json=payload,
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
            },
            timeout=10,
        )
        resp.raise_for_status()
    except requests.RequestException as exc:
        st.warning(f"Could not load HubSpot contacts: {exc}", icon="⚠️")
        return [], "error"

    out: list[dict] = []
    for row in resp.json().get("results", []):
        props = row.get("properties", {}) or {}
        email = (props.get("email") or "").strip()
        if email.lower() in _EXCLUDE_EMAILS:
            continue
        name = compose_name(props)
        phone = (props.get("phone") or "").strip()
        if not (name or email or phone):
            continue  # nothing usable to pre-fill or label
        ident = email or phone or "no contact info"
        out.append({
            "id": row.get("id"),
            "name": name,
            "email": email,
            "phone": phone,
            "address_line": compose_address_line(props),
            "label": f"{name or '(no name)'} · {ident}",
        })
    return out, "ok"
