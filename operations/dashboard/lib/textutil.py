"""Text helpers for Streamlit rendering."""

from __future__ import annotations


def md_safe(text: str | None) -> str:
    """Escape $ so st.markdown does not treat '$...$' pairs as LaTeX math.

    Business text is full of dollar amounts; two of them on one line otherwise
    turn the span between them into garbled math output.
    """
    return (text or "").replace("$", "\\$")
