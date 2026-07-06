"""
CWDB Work Order / Home Improvement Contract: Send via DocuSign
Central Wisconsin Deck Builders, LLC

Sends an already-generated work-order or contract PDF (from
generate_work_order_pdf.py / generate_sow_pdf.py) for e-signature.
Signing order: homeowner(s) first, then Jim (CWDB).

Unlike the contractor-agreement sender (fixed page/x/y tabs), this uses
DocuSign ANCHOR tabs, because the contract's page count varies by job:
  - CWDB signer anchors on "By: James Slogar, Member"
  - Homeowner anchors on "Printed name: <client name>"
  - Co-owner (optional) anchors on "all titleholders must sign"
The signature widget is offset ~0.35in above the anchor (onto the blank
line); the date-signed tab sits in the Date column ~4.2in right.

Required environment variables (same as sales/contractor-agreements/):
    DOCUSIGN_ACCOUNT_ID    e.g. 07a2f8c5-1951-4d6d-baab-0c45359ab80e
    DOCUSIGN_ACCESS_TOKEN  OAuth token from DocuSign Admin > Apps & Keys
                           (expires ~8h; refresh before sending)

Usage:
    # real send (homeowner then Jim)
    python generate_and_send_sow.py 2026-06-03-overbeck-stain-work-order.pdf \
        --signer-name "Debbie Overbeck" --signer-email doverbeck1@gmail.com \
        --job-number CWDB-2026-001

    # test envelope to Jim only (verify tab placement, then void it)
    python generate_and_send_sow.py <pdf> --signer-name "Debbie Overbeck" \
        --signer-email slogarjw@gmail.com --job-number CWDB-2026-001 --test

    # no API call at all
    ... --dry-run

REMINDER: the e-signed envelope does not replace the paper duties; the
homeowner must still receive TWO copies of the Notice of Cancellation (they
are pages of the PDF; DocuSign delivers the full signed PDF), and the deposit
is held until the 3-business-day window passes.
"""

import argparse
import base64
import json
import os
import sys
import urllib.request
import urllib.error
from datetime import date
from pathlib import Path

HERE = Path(__file__).parent
LOG_FILE = HERE / 'sow-send-log.md'

DOCUSIGN_BASE = 'https://na4.docusign.net/restapi/v2.1'

CWDB_SIGNER_NAME_DEFAULT = 'James Slogar'
CWDB_SIGNER_EMAIL_DEFAULT = 'slogarjw@gmail.com'

# Anchor geometry (inches). Signature line sits one table row above the
# printed-name anchor text; Date column starts ~4.2in right of the labels.
SIG_Y_OFFSET = '-0.35'
DATE_X_OFFSET = '4.2'


def _anchor_tabs(anchor):
    return {
        'signHereTabs': [{
            'anchorString': anchor,
            'anchorUnits': 'inches',
            'anchorXOffset': '0',
            'anchorYOffset': SIG_Y_OFFSET,
        }],
        'dateSignedTabs': [{
            'anchorString': anchor,
            'anchorUnits': 'inches',
            'anchorXOffset': DATE_X_OFFSET,
            'anchorYOffset': SIG_Y_OFFSET,
        }],
    }


def build_envelope(pdf_path, doc_name, subject, blurb, signers):
    with open(pdf_path, 'rb') as f:
        pdf_b64 = base64.b64encode(f.read()).decode('utf-8')
    return {
        'emailSubject': subject,
        'emailBlurb': blurb,
        'documents': [{
            'documentBase64': pdf_b64,
            'name': doc_name,
            'fileExtension': 'pdf',
            'documentId': '1',
        }],
        'recipients': {'signers': signers},
        'status': 'sent',
    }


def send_envelope(payload):
    account_id = os.environ.get('DOCUSIGN_ACCOUNT_ID', '').strip()
    access_token = os.environ.get('DOCUSIGN_ACCESS_TOKEN', '').strip()
    if not account_id or not access_token:
        raise EnvironmentError(
            'Missing DOCUSIGN_ACCOUNT_ID and/or DOCUSIGN_ACCESS_TOKEN.\n'
            "  $env:DOCUSIGN_ACCOUNT_ID = '07a2f8c5-1951-4d6d-baab-0c45359ab80e'\n"
            "  $env:DOCUSIGN_ACCESS_TOKEN = '<token from DocuSign Admin > Apps & Keys>'")
    url = f'{DOCUSIGN_BASE}/accounts/{account_id}/envelopes'
    req = urllib.request.Request(
        url, data=json.dumps(payload).encode('utf-8'),
        headers={'Authorization': f'Bearer {access_token}',
                 'Content-Type': 'application/json',
                 'Accept': 'application/json'},
        method='POST')
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode('utf-8'))['envelopeId']
    except urllib.error.HTTPError as e:
        raise RuntimeError(
            f'DocuSign API error {e.code}: {e.read().decode("utf-8")}') from e


def append_log(job_number, signer_name, signer_email, pdf_path, envelope_id,
               status):
    if not LOG_FILE.exists():
        LOG_FILE.write_text(
            '# Work Order / Contract Send Log\n\n'
            '| Date | Job No. | Signer | Email | PDF File | Envelope ID | Status |\n'
            '|------|---------|--------|-------|----------|-------------|--------|\n',
            encoding='utf-8')
    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(f'| {date.today().isoformat()} | {job_number} | {signer_name} '
                f'| {signer_email} | {pdf_path.name} | {envelope_id} '
                f'| {status} |\n')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('pdf_path', help='generated work-order or contract PDF')
    p.add_argument('--signer-name', required=True,
                   help='homeowner name exactly as printed on the signature '
                        'block (used as the DocuSign anchor)')
    p.add_argument('--signer-email', required=True)
    p.add_argument('--co-signer-name', default=None)
    p.add_argument('--co-signer-email', default=None)
    p.add_argument('--job-number', required=True)
    p.add_argument('--cwdb-signer-name', default=CWDB_SIGNER_NAME_DEFAULT)
    p.add_argument('--cwdb-signer-email', default=CWDB_SIGNER_EMAIL_DEFAULT)
    p.add_argument('--doc-name', default=None)
    p.add_argument('--test', action='store_true',
                   help='mark subject [TEST]; send to whatever --signer-email '
                        'you gave (use your own), verify tabs, then void')
    p.add_argument('--dry-run', action='store_true')
    args = p.parse_args()

    pdf_path = Path(args.pdf_path).resolve()
    if not pdf_path.exists():
        sys.exit(f'PDF not found: {pdf_path}')
    doc_name = args.doc_name or pdf_path.stem.replace('-', ' ').title()
    subject = (f'Please sign: CWDB {doc_name} (Job No. {args.job_number})')
    if args.test:
        subject = f'[TEST: VOID AFTER REVIEW] {subject}'
    blurb = (
        f'Hi {args.signer_name.split()[0]},\n\n'
        f'Please review and sign the attached agreement with Central '
        f'Wisconsin Deck Builders, LLC (Job No. {args.job_number}).\n\n'
        'The document includes your Notice of Cancellation (two copies): you '
        'may cancel without penalty until midnight of the third business day '
        'after signing, and your deposit is held untouched until that period '
        'passes.\n\n'
        'Questions? Reply to this email or call (715) 544-7941.')

    signers = [{
        'email': args.signer_email,
        'name': args.signer_name,
        'recipientId': '1',
        'routingOrder': '1',
        'tabs': _anchor_tabs(f'Printed name: {args.signer_name}'),
    }]
    rid = 2
    if args.co_signer_name and args.co_signer_email:
        signers.append({
            'email': args.co_signer_email,
            'name': args.co_signer_name,
            'recipientId': str(rid),
            'routingOrder': '1',
            'tabs': _anchor_tabs('all titleholders must sign'),
        })
        rid += 1
    signers.append({
        'email': args.cwdb_signer_email,
        'name': args.cwdb_signer_name,
        'recipientId': str(rid),
        'routingOrder': '2',
        'tabs': _anchor_tabs('By: James Slogar, Member'),
    })

    if args.dry_run:
        print('[DRY RUN] Envelope NOT sent. Recipients:')
        for s in signers:
            print(f"  routing {s['routingOrder']}: {s['name']} <{s['email']}>")
        print(f'[DRY RUN] Document: {pdf_path}')
        append_log(args.job_number, args.signer_name, args.signer_email,
                   pdf_path, 'dry-run', 'DRY RUN')
        return

    payload = build_envelope(pdf_path, doc_name, subject, blurb, signers)
    envelope_id = send_envelope(payload)
    status = 'TEST SENT' if args.test else 'SENT'
    append_log(args.job_number, args.signer_name, args.signer_email,
               pdf_path, envelope_id, status)
    print(f'DocuSign envelope sent. Envelope ID: {envelope_id}')
    print(f'Logged to: {LOG_FILE}')
    if args.test:
        print('TEST envelope: verify signature/date tab placement on every '
              'signer, then VOID the envelope in DocuSign.')


if __name__ == '__main__':
    main()
