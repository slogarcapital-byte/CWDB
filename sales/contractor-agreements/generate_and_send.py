"""
Contractor Agreement — Generate PDF and Send via DocuSign
Central Wisconsin Deck Builders, LLC

Usage:
    python generate_and_send.py --contractor-json '<json>' --effective-date "April 10, 2026"
    python generate_and_send.py --contractor-json '<json>' --effective-date "April 10, 2026" --dry-run

Required environment variables:
    DOCUSIGN_ACCOUNT_ID    — your DocuSign account ID (e.g. 74214705)
    DOCUSIGN_ACCESS_TOKEN  — OAuth access token from DocuSign Admin > Apps & Keys

The --contractor-json argument is a JSON string with these keys:
    name           legal entity name (e.g. "Barton Builders LLC")
    entity_type    "LLC" / "Sole Proprietorship" / "Corporation"
    street         street address
    city           city
    state          state abbreviation (default "WI")
    zip            zip code
    contact_name   signer's full name
    contact_title  signer's title (e.g. "Owner")
    contact_email  signer's email address

This script is called by Claude after pulling contractor data from HubSpot via MCP.
It does NOT make any HubSpot API calls itself.
"""

import argparse
import base64
import json
import os
import re
import sys
import urllib.request
import urllib.error
from datetime import date
from pathlib import Path

HERE = Path(__file__).parent
DOCS_LEGAL = HERE.parent.parent / "docs" / "legal"
LOG_FILE = HERE / "log.md"

# ── Signature tab positions (page 4, signature block) ────────────────────────
# These coordinates place the DocuSign signature widget on the contractor's
# signature line. Adjust if the PDF layout changes.
SIGN_HERE_PAGE   = "4"
SIGN_HERE_X      = "390"   # right column of signature block
SIGN_HERE_Y      = "415"
DATE_SIGNED_X    = "390"
DATE_SIGNED_Y    = "480"


def slugify(name: str) -> str:
    return re.sub(r'[^a-z0-9]+', '-', name.lower()).strip('-')


def generate_pdf_for_contractor(contractor: dict, effective_date: str) -> Path:
    sys.path.insert(0, str(DOCS_LEGAL))
    from generate_agreement_pdf import generate_pdf

    contractor["effective_date"] = effective_date
    contractor.setdefault("state", "WI")

    slug = slugify(contractor["name"])
    filename = f"{slug}-agreement-{date.today().isoformat()}.pdf"
    output_path = HERE / filename

    generate_pdf(contractor, str(output_path))
    return output_path


def send_to_docusign(pdf_path: Path, contractor: dict, dry_run: bool = False) -> str:
    """
    Upload the PDF to DocuSign and send for e-signature.
    Returns the DocuSign envelope ID on success.
    """
    if dry_run:
        print(f"[DRY RUN] Would POST to DocuSign")
        print(f"[DRY RUN] Recipient: {contractor['contact_name']} <{contractor['contact_email']}>")
        print(f"[DRY RUN] PDF: {pdf_path}")
        return "dry-run-no-envelope-id"

    account_id = os.environ.get("DOCUSIGN_ACCOUNT_ID", "").strip()
    access_token = os.environ.get("DOCUSIGN_ACCESS_TOKEN", "").strip()

    if not account_id or not access_token:
        raise EnvironmentError(
            "Missing required environment variables: DOCUSIGN_ACCOUNT_ID and/or DOCUSIGN_ACCESS_TOKEN\n"
            "Set them before running:\n"
            "  $env:DOCUSIGN_ACCOUNT_ID = '07a2f8c5-1951-4d6d-baab-0c45359ab80e'\n"
            "  $env:DOCUSIGN_ACCESS_TOKEN = '<token>'"
        )

    with open(pdf_path, "rb") as f:
        pdf_b64 = base64.b64encode(f.read()).decode("utf-8")

    payload = {
        "emailSubject": "Please sign: Central Wisconsin Deck Builders Contractor Agreement",
        "emailBlurb": (
            f"Hi {contractor['contact_name']},\n\n"
            "Please review and sign the attached Contractor Lead Purchase Agreement with "
            "Central Wisconsin Deck Builders, LLC.\n\n"
            "Questions? Reply to this email or contact slogarjw@gmail.com."
        ),
        "documents": [
            {
                "documentBase64": pdf_b64,
                "name": "Contractor Lead Purchase Agreement",
                "fileExtension": "pdf",
                "documentId": "1",
            }
        ],
        "recipients": {
            "signers": [
                {
                    "email": contractor["contact_email"],
                    "name": contractor["contact_name"],
                    "recipientId": "1",
                    "tabs": {
                        "signHereTabs": [
                            {
                                "documentId": "1",
                                "pageNumber": SIGN_HERE_PAGE,
                                "xPosition": SIGN_HERE_X,
                                "yPosition": SIGN_HERE_Y,
                            }
                        ],
                        "dateSignedTabs": [
                            {
                                "documentId": "1",
                                "pageNumber": SIGN_HERE_PAGE,
                                "xPosition": DATE_SIGNED_X,
                                "yPosition": DATE_SIGNED_Y,
                            }
                        ],
                    },
                }
            ]
        },
        "status": "sent",
    }

    url = f"https://na4.docusign.net/restapi/v2.1/accounts/{account_id}/envelopes"
    # Account ID should be the GUID format: 07a2f8c5-1951-4d6d-baab-0c45359ab80e
    body = json.dumps(payload).encode("utf-8")
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

    req = urllib.request.Request(url, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req) as resp:
            result = json.loads(resp.read().decode("utf-8"))
            return result["envelopeId"]
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8")
        raise RuntimeError(f"DocuSign API error {e.code}: {error_body}") from e


def append_log(contractor: dict, pdf_path: Path, envelope_id: str, effective_date: str, dry_run: bool):
    today = date.today().isoformat()
    status = "DRY RUN" if dry_run else "SENT"
    line = (
        f"| {today} | {contractor['name']} | {contractor['contact_email']} "
        f"| {pdf_path.name} | {envelope_id} | {effective_date} | {status} |"
    )

    if not LOG_FILE.exists():
        LOG_FILE.write_text(
            "# Contractor Agreement Send Log\n\n"
            "| Date | Contractor | Email | PDF File | DocuSign Envelope ID | Effective Date | Status |\n"
            "|------|------------|-------|----------|----------------------|----------------|--------|\n"
        )

    with open(LOG_FILE, "a") as f:
        f.write(line + "\n")


def main():
    parser = argparse.ArgumentParser(description="Generate and send contractor agreement via DocuSign")
    parser.add_argument("--contractor-json", required=True, help="JSON string of contractor fields")
    parser.add_argument("--effective-date", required=True, help='Effective date, e.g. "April 10, 2026"')
    parser.add_argument("--dry-run", action="store_true", help="Generate PDF but skip DocuSign upload")
    args = parser.parse_args()

    contractor = json.loads(args.contractor_json)

    required = ["name", "entity_type", "street", "city", "zip", "contact_name", "contact_title", "contact_email"]
    missing = [k for k in required if not contractor.get(k)]
    if missing:
        print(f"ERROR: Missing contractor fields: {', '.join(missing)}", file=sys.stderr)
        sys.exit(1)

    print(f"Generating PDF for {contractor['name']}...")
    pdf_path = generate_pdf_for_contractor(contractor, args.effective_date)
    print(f"PDF saved: {pdf_path}")

    print("Sending to DocuSign..." if not args.dry_run else "Dry run — skipping DocuSign...")
    envelope_id = send_to_docusign(pdf_path, contractor, dry_run=args.dry_run)

    append_log(contractor, pdf_path, envelope_id, args.effective_date, args.dry_run)

    if args.dry_run:
        print(f"[DRY RUN] Complete. PDF at: {pdf_path}")
    else:
        print(f"DocuSign envelope sent. Envelope ID: {envelope_id}")
        print(f"Logged to: {LOG_FILE}")


if __name__ == "__main__":
    main()
