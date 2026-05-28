"""
Gmail SMTP wrapper for the CWDB Estimator app.

Sends one email with PDF + .xlsx attached to a configured recipient. Uses
Gmail SMTP over SSL (port 465) with a 16-character app password. Credentials
come from Streamlit secrets so they never live in the codebase.
"""

from __future__ import annotations

import smtplib
import ssl
from email.message import EmailMessage
from pathlib import Path


GMAIL_SMTP_HOST = "smtp.gmail.com"
GMAIL_SMTP_PORT = 465


def send_estimate_email(
    *,
    gmail_address: str,
    gmail_app_password: str,
    recipient: str,
    subject: str,
    body: str,
    attachments: list[Path],
) -> None:
    """Send one email with the given attachments. Raises on failure."""
    msg = EmailMessage()
    msg["From"] = gmail_address
    msg["To"] = recipient
    msg["Subject"] = subject
    msg.set_content(body)

    for path in attachments:
        path = Path(path)
        data = path.read_bytes()
        if path.suffix.lower() == ".pdf":
            maintype, subtype = "application", "pdf"
        elif path.suffix.lower() == ".xlsx":
            maintype, subtype = (
                "application",
                "vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            )
        else:
            maintype, subtype = "application", "octet-stream"
        msg.add_attachment(
            data, maintype=maintype, subtype=subtype, filename=path.name
        )

    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(GMAIL_SMTP_HOST, GMAIL_SMTP_PORT, context=context) as smtp:
        smtp.login(gmail_address, gmail_app_password)
        smtp.send_message(msg)
