"""
Contractor Lead Purchase Agreement — PDF Generator
Central Wisconsin Deck Builders, LLC

Usage (library):
    from generate_agreement_pdf import generate_pdf
    path = generate_pdf(contractor, "output/path.pdf")

Usage (standalone):
    python generate_agreement_pdf.py
    (generates a blank-placeholder copy to docs/legal/)
"""

from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table,
                                 TableStyle, HRFlowable, PageBreak)
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY

ORANGE   = colors.HexColor('#e54c00')
SLATE    = colors.HexColor('#323434')
GREY     = colors.HexColor('#646760')
WHITE    = colors.white
LIGHT_BG = colors.HexColor('#f7f4f1')

styles = getSampleStyleSheet()

def S(name, **kw):
    return ParagraphStyle(name, parent=styles['Normal'], **kw)

normal    = S('n',   fontName='Times-Roman',        fontSize=10.5, leading=15.5, textColor=SLATE, spaceAfter=6,  alignment=TA_JUSTIFY)
bold_body = S('bb',  fontName='Times-Bold',          fontSize=10.5, leading=15.5, textColor=SLATE, spaceAfter=6,  alignment=TA_JUSTIFY)
h1        = S('h1',  fontName='Helvetica-Bold',      fontSize=17,   leading=21,   textColor=ORANGE, spaceAfter=4, alignment=TA_CENTER)
h2        = S('h2',  fontName='Helvetica-Bold',      fontSize=12.5, leading=16,   textColor=SLATE,  spaceAfter=4, spaceBefore=14)
recital   = S('r',   fontName='Times-Italic',        fontSize=10.5, leading=15.5, textColor=SLATE,  spaceAfter=6, leftIndent=18, alignment=TA_JUSTIFY)
subbullet = S('sb',  fontName='Times-Roman',         fontSize=10.5, leading=15,   textColor=SLATE,  spaceAfter=4, leftIndent=36, bulletIndent=24)
caps_sec  = S('cs',  fontName='Times-Bold',          fontSize=10.5, leading=15.5, textColor=SLATE,  spaceAfter=6, alignment=TA_JUSTIFY)
sub       = S('sub', fontName='Helvetica',            fontSize=9,    leading=12,   textColor=GREY,   spaceAfter=2, alignment=TA_CENTER)
exec_head = S('eh',  fontName='Helvetica-Bold',      fontSize=11,   leading=14,   textColor=WHITE,  spaceAfter=0)
exec_body = S('eb',  fontName='Helvetica',            fontSize=9.8,  leading=14,   textColor=SLATE,  spaceAfter=5, alignment=TA_JUSTIFY)
exec_sub  = S('es',  fontName='Helvetica-Bold',      fontSize=10,   leading=13,   textColor=ORANGE, spaceAfter=2, spaceBefore=6)


def generate_pdf(contractor: dict, output_path: str) -> str:
    """
    Generate a filled Contractor Lead Purchase Agreement PDF.

    Args:
        contractor: dict with keys:
            name          — legal entity name (e.g. "Barton Builders LLC")
            entity_type   — "LLC" / "Sole Proprietorship" / "Corporation"
            street        — street address
            city          — city
            state         — state abbreviation (default "WI")
            zip           — zip code
            contact_name  — signer's full name
            contact_title — signer's title (e.g. "Owner")
            contact_email — signer's email address
            effective_date — string like "April 10, 2026"
        output_path: absolute or relative path for the output PDF

    Returns:
        output_path (string)
    """
    c = contractor
    state = c.get("state", "WI")

    doc = SimpleDocTemplate(
        output_path, pagesize=letter,
        leftMargin=1.1*inch, rightMargin=1.1*inch,
        topMargin=1*inch, bottomMargin=1*inch,
        title='Contractor Lead Purchase Agreement',
        author='Central Wisconsin Deck Builders, LLC'
    )

    story = []

    def p(txt, style=normal): return Paragraph(txt, style)
    def sp(n=0.1):             return Spacer(1, n*inch)
    def hr():                  return HRFlowable(width='100%', thickness=0.5, color=GREY, spaceAfter=8, spaceBefore=8)

    # ── HEADER ──────────────────────────────────────────────────────────────────
    story.append(sp(0.05))
    story.append(p('CONTRACTOR LEAD PURCHASE AGREEMENT', h1))
    story.append(p('Central Wisconsin Deck Builders, LLC  ·  cwdeckbuilders.com', sub))
    story.append(sp(0.05))
    story.append(HRFlowable(width='100%', thickness=2, color=ORANGE, spaceAfter=5))
    story.append(p('Document Version 1.0  ·  Entity ID: C138564  ·  EIN: 41-5355234', sub))
    story.append(sp(0.18))

    # ── EXECUTIVE SUMMARY (contractor audience) ─────────────────────────────────
    def exec_row(content_rows):
        inner = Table([[r] for r in content_rows], colWidths=[6.1*inch])
        inner.setStyle(TableStyle([
            ('BACKGROUND',    (0,0),(-1,-1), LIGHT_BG),
            ('TOPPADDING',    (0,0),(-1,-1), 7),
            ('BOTTOMPADDING', (0,0),(-1,-1), 2),
            ('LEFTPADDING',   (0,0),(-1,-1), 12),
            ('RIGHTPADDING',  (0,0),(-1,-1), 12),
            ('BOX',           (0,0),(-1,-1), 0.5, GREY),
        ]))
        return inner

    title_bar = Table([[p('PLAIN-ENGLISH SUMMARY — WHAT THIS AGREEMENT MEANS FOR YOU', exec_head)]],
                      colWidths=[6.3*inch])
    title_bar.setStyle(TableStyle([
        ('BACKGROUND',    (0,0),(-1,-1), SLATE),
        ('TOPPADDING',    (0,0),(-1,-1), 8),
        ('BOTTOMPADDING', (0,0),(-1,-1), 8),
        ('LEFTPADDING',   (0,0),(-1,-1), 12),
        ('RIGHTPADDING',  (0,0),(-1,-1), 12),
    ]))
    story.append(title_bar)

    summary_page1 = [
        p('The Big Picture', exec_sub),
        p('Central Wisconsin Deck Builders, LLC ("CWDB") runs a digital lead generation system that connects homeowners in Central Wisconsin with qualified deck builders. <b>You receive homeowner project leads at no upfront cost.</b> You pay CWDB only when you win the job — specifically, when a homeowner signs your written proposal or pays you a deposit. There are no monthly fees, no subscription costs, and no charge for leads that don\'t convert.', exec_body),

        p('What CWDB Is Responsible For', exec_sub),
        p('<b>✔ Generating and delivering leads</b> — homeowner name, phone, address, and project description sent to you via email, SMS, or CRM.', exec_body),
        p('<b>✔ Funding all advertising</b> — Google Ads, Facebook, and other channels. That cost is CWDB\'s alone.', exec_body),
        p('<b>✔ Invoicing you accurately</b> — within 10 business days of confirming an accepted bid.', exec_body),
        p('<b>✔ Keeping your business information confidential</b> — your identity in the CWDB network and our shared pricing are protected.', exec_body),
        p('<b>✔ Following up with homeowners independently</b> — CWDB may contact homeowners directly to verify lead status. This is how the system stays honest for everyone.', exec_body),
        p('<b>✗ Not guaranteeing lead volume or quality</b> — lead flow varies by season and market conditions. CWDB makes no promise of a minimum number of leads.', exec_body),
        sp(0.05),
    ]

    summary_page2 = [
        p('What You (the Contractor) Are Responsible For', exec_sub),
        p('<b>✔ Report every accepted bid within 5 business days.</b> This is your single most important obligation. When a homeowner from a CWDB lead signs your proposal or pays a deposit, notify CWDB in writing within 5 business days with: the homeowner\'s name, property address, the accepted bid amount, and estimated start date.', exec_body),
        p('<b>✔ Pay the Lead Fee of $1,000 per accepted bid</b> within 15 days of CWDB\'s invoice. The fee is owed even if the project is later cancelled by the homeowner. Late payments accrue 1.5%/month interest.', exec_body),
        p('<b>✔ Maintain a valid Wisconsin contractor license</b> throughout the agreement. If your license lapses, CWDB may pause your leads immediately.', exec_body),
        p('<b>✔ Maintain general liability insurance ($1M minimum)</b> and provide a Certificate of Insurance when you sign. Notify CWDB within 5 days of any coverage change.', exec_body),
        p('<b>✔ Protect homeowner data</b> — use homeowner contact information only for the specific CWDB-referred project. Do not sell, share, or market to homeowners for unrelated services.', exec_body),
        p('<b>✔ Allow quarterly audits</b> — CWDB may audit your project records related to CWDB-sourced leads once per quarter with 10 business days\' notice.', exec_body),
        p('<b>✔ Keep CWDB\'s pricing and systems confidential</b> — this obligation continues for 2 years after termination.', exec_body),

        p('Key Numbers', exec_sub),
        p('<b>$1,000</b> per accepted bid  ·  <b>5 business days</b> to report a win  ·  <b>15 days</b> to pay the invoice  ·  <b>1.5%/month</b> late interest  ·  <b>30 days written notice</b> to terminate without cause  ·  <b>12-month tail period</b> — the fee applies to any CWDB lead that converts within 12 months of delivery, even after termination.', exec_body),

        p('If You Don\'t Report an Accepted Bid', exec_sub),
        p('Failure to report is a material breach. CWDB may: (1) immediately suspend your lead delivery; (2) charge the $1,000 Lead Fee plus a $250 late-reporting penalty per unreported bid; and (3) terminate the agreement if two or more bids go unreported in any 12-month period. CWDB monitors outcomes through direct homeowner follow-up and quarterly audits.', exec_body),

        p('Exiting the Agreement', exec_sub),
        p('Either party may walk away with 30 days written notice — no penalty. CWDB may terminate immediately for non-payment, fraud, license lapse, or repeated reporting failures. All fees owed at termination remain due, and the 12-month tail period applies to leads already delivered.', exec_body),
        sp(0.05),
    ]

    story.append(exec_row(summary_page1))
    story.append(PageBreak())
    story.append(title_bar)
    story.append(exec_row(summary_page2))
    story.append(sp(0.2))

    # ── AGREEMENT BODY ───────────────────────────────────────────────────────────
    story.append(PageBreak())
    story.append(p('CONTRACTOR LEAD PURCHASE AGREEMENT', h1))
    story.append(HRFlowable(width='100%', thickness=1.5, color=ORANGE, spaceAfter=14))

    story.append(p(f'<b>THIS CONTRACTOR LEAD PURCHASE AGREEMENT</b> (this "Agreement") is entered into as of {c["effective_date"]} (the "Effective Date"), by and between:'))
    story.append(sp(0.08))
    story.append(p('<b>Central Wisconsin Deck Builders, LLC</b>, a Wisconsin limited liability company organized under Chapter 183 of the Wisconsin Statutes, with Wisconsin Entity ID No. C138564, EIN 41-5355234, and its principal place of business at 906 N 16th Ave., Wausau, WI 54401 (the "Company");'))
    story.append(sp(0.08))
    story.append(p('and'))
    story.append(sp(0.08))
    story.append(p(f'<b>{c["name"]}</b> ("Contractor"), a {c["entity_type"]}, with a principal place of business at {c["street"]}, {c["city"]}, {state} {c["zip"]}.'))
    story.append(sp(0.08))
    story.append(p('Company and Contractor are each referred to herein as a "Party" and collectively as the "Parties."'))
    story.append(hr())

    # RECITALS
    story.append(p('RECITALS', h2))
    story.append(p('<b>WHEREAS</b>, the Company operates a lead generation business that connects homeowners seeking deck construction, repair, and improvement services with qualified contractors in Central Wisconsin; and', recital))
    story.append(p('<b>WHEREAS</b>, the Contractor is engaged in the business of residential deck construction, repair, and improvement services and desires to receive homeowner project leads from the Company; and', recital))
    story.append(p('<b>WHEREAS</b>, the Parties desire to establish the terms and conditions under which the Company will deliver leads to the Contractor and the Contractor will pay the Company for leads that result in accepted bids;', recital))
    story.append(p('<b>NOW, THEREFORE</b>, in consideration of the mutual covenants and agreements set forth herein, and for other good and valuable consideration, the receipt and sufficiency of which are hereby acknowledged, the Parties agree as follows:', recital))
    story.append(hr())

    # § 1
    story.append(p('SECTION 1. DEFINITIONS', h2))
    story.append(p('<b>1.1 "Accepted Bid"</b> means an event in which a Homeowner executes, signs, or otherwise formally accepts a written proposal, estimate, bid, or contract submitted by the Contractor for a Project that originated from a Lead delivered under this Agreement. An Accepted Bid occurs when the Homeowner manifests assent to the Contractor\'s proposed scope of work and pricing, whether by physical signature, electronic signature, verbal acceptance confirmed in writing, or payment of a deposit. A Homeowner\'s mere expression of interest, request for additional information, or verbal indication of intent without a signed document or deposit does not constitute an Accepted Bid.'))
    story.append(p('<b>1.2 "Confidential Information"</b> means any non-public information disclosed by one Party to the other in connection with this Agreement, including but not limited to business methods, pricing, lead sources, technology systems, customer lists, marketing strategies, and financial information.'))
    story.append(p('<b>1.3 "Homeowner"</b> means a residential property owner or authorized occupant who submits a request for a deck project quote through the Company\'s website, advertising, or other lead generation channels.'))
    story.append(p('<b>1.4 "Lead"</b> means the contact information and project details of a Homeowner, as collected by the Company and delivered to the Contractor, including at minimum the Homeowner\'s name, phone number, property address, and project description.'))
    story.append(p('<b>1.5 "Lead Fee"</b> means the fee of One Thousand Dollars ($1,000.00) per Accepted Bid, as set forth in Section 4.'))
    story.append(p('<b>1.6 "Project"</b> means any residential deck construction, repair, replacement, resurfacing, expansion, or improvement project for which a Lead is generated.'))
    story.append(p('<b>1.7 "Service Area"</b> means the geographic territory in which the Company currently operates its lead generation services, consisting of Wausau, Schofield, Weston, Mosinee, and Merrill, Wisconsin, and surrounding areas within Marathon County. The Service Area may be modified by the Company from time to time upon written notice to the Contractor.'))
    story.append(p('<b>1.8 "PII" or "Personal Identifiable Information"</b> means any information that identifies or could reasonably be used to identify a specific Homeowner, including but not limited to name, address, phone number, and email address.'))
    story.append(hr())

    # § 2
    story.append(p('SECTION 2. LEAD DELIVERY', h2))
    story.append(p('<b>2.1 Delivery Method.</b> The Company shall deliver Leads to the Contractor via email, SMS, CRM notification, or such other electronic method as the Company may designate from time to time with reasonable prior notice.'))
    story.append(p('<b>2.2 Lead Contents.</b> Each Lead shall include, at minimum, the Homeowner\'s name, phone number, property address, and a description of the requested Project. The Company may include additional information when available but is not obligated to do so.'))
    story.append(p('<b>2.3 No Guarantee of Volume or Quality.</b> The Company makes no representation or warranty regarding the number of Leads to be delivered, the frequency of delivery, or the likelihood that any Lead will result in an Accepted Bid. Lead volume may vary based on market conditions, advertising spend, seasonality, and other factors within and outside the Company\'s control.'))
    story.append(p('<b>2.4 No Guarantee of Accuracy.</b> While the Company will use commercially reasonable efforts to collect accurate information from Homeowners, the Company does not warrant the accuracy, completeness, or validity of information provided by Homeowners.'))
    story.append(p('<b>2.5 Lead Delivery Discretion.</b> The Company reserves the right, in its sole discretion, to pause, limit, redirect, or discontinue Lead delivery to the Contractor at any time, including but not limited to suspected underreporting of Accepted Bids, failure to maintain required credentials, or non-payment of Lead Fees.'))
    story.append(hr())

    # § 3
    story.append(p('SECTION 3. LEAD EXCLUSIVITY', h2))
    story.append(p('<b>3.1 Non-Exclusive Leads.</b> Unless otherwise agreed in a separate written agreement signed by both Parties, all Leads delivered under this Agreement are non-exclusive. The Company may deliver the same Lead to one or more other contractors simultaneously or sequentially.'))
    story.append(p('<b>3.2 Exclusive Territory Agreements.</b> The Parties may enter into a separate Territory Licensing Agreement granting the Contractor exclusive rights to Leads within a defined geographic area. Any such agreement must be in writing, signed by both Parties, and will supplement (not replace) this Agreement.'))
    story.append(p('<b>3.3 No Restriction on Contractor.</b> Nothing in this Agreement restricts the Contractor from generating its own leads through its own marketing efforts or from receiving leads from other lead generation services.'))
    story.append(hr())

    # § 4
    story.append(p('SECTION 4. LEAD FEE AND PAYMENT', h2))
    story.append(p('<b>4.1 Lead Fee.</b> The Contractor shall pay the Company a Lead Fee of One Thousand Dollars ($1,000.00) for each Accepted Bid that results from a Lead delivered under this Agreement.'))
    story.append(p('<b>4.2 Payment Trigger.</b> The Lead Fee becomes due and payable upon the occurrence of an Accepted Bid, regardless of whether the Project is subsequently completed, modified, or cancelled by either the Homeowner or the Contractor.'))
    story.append(p('<b>4.3 Invoicing.</b> The Company shall issue an invoice to the Contractor within ten (10) business days of the Company\'s confirmation of an Accepted Bid. Confirmation may occur through the Contractor\'s report under Section 5, the Company\'s independent verification under Section 6, or both.'))
    story.append(p('<b>4.4 Payment Terms.</b> The Contractor shall pay each invoice within fifteen (15) calendar days of the invoice date via check, ACH transfer, credit card, or such other method as the Company may reasonably designate.'))
    story.append(p('<b>4.5 Late Payment.</b> Any amount not paid when due shall bear interest at the rate of one and one-half percent (1.5%) per month (18% per annum), or the maximum rate permitted by Wisconsin law, whichever is less, from the due date until paid in full. The Contractor shall also be responsible for all reasonable costs of collection, including attorneys\' fees and court costs, incurred by the Company in collecting past-due amounts.'))
    story.append(p('<b>4.6 Disputed Invoices.</b> If the Contractor disputes any invoice, the Contractor must provide written notice to the Company within ten (10) business days of the invoice date specifying the basis for the dispute. The undisputed portion remains due on the original due date. The Parties shall work in good faith to resolve any dispute within thirty (30) calendar days.'))
    story.append(p('<b>4.7 Fee Adjustment.</b> The Company may adjust the Lead Fee upon sixty (60) days\' prior written notice. The adjusted fee shall apply only to Accepted Bids occurring after the effective date of the adjustment. If the Contractor does not agree to the adjusted fee, the Contractor may terminate this Agreement pursuant to Section 15.'))
    story.append(hr())

    # § 5
    story.append(p('SECTION 5. CONTRACTOR REPORTING OBLIGATION', h2))
    story.append(p('<b>5.1 Reporting Requirement.</b> The Contractor shall notify the Company in writing within five (5) business days of any Accepted Bid resulting from a Lead delivered under this Agreement. Such notice shall include:'))
    story.append(Paragraph('(a) The Homeowner\'s full name;', subbullet))
    story.append(Paragraph('(b) The Project property address;', subbullet))
    story.append(Paragraph('(c) The accepted bid amount;', subbullet))
    story.append(Paragraph('(d) The estimated Project start date; and', subbullet))
    story.append(Paragraph('(e) A copy of the signed proposal, contract, or other documentation evidencing the Accepted Bid, if requested by the Company.', subbullet))
    story.append(p('<b>5.2 Method of Reporting.</b> Reports under this Section may be submitted via email to slogarjw@gmail.com, through the Company\'s CRM portal, or by such other method as the Company may designate.'))
    story.append(p('<b>5.3 Ongoing Obligation.</b> The reporting obligation under this Section continues for a period of twelve (12) months following the delivery of each Lead. If a Homeowner accepts a bid from the Contractor on a Project related to a Lead delivered under this Agreement at any time within twelve (12) months of Lead delivery, that event constitutes an Accepted Bid subject to the Lead Fee, regardless of whether the Homeowner initially declined or failed to respond.'))
    story.append(p('<b>5.4 Failure to Report.</b> Failure to report an Accepted Bid within the time required by Section 5.1 constitutes a material breach of this Agreement and subjects the Contractor to the consequences set forth in Section 6.4.'))
    story.append(hr())

    # § 6
    story.append(p('SECTION 6. VERIFICATION AND AUDIT RIGHTS', h2))
    story.append(p('<b>6.1 Homeowner Follow-Up.</b> The Contractor acknowledges and agrees that the Company may contact Homeowners directly, through automated or manual follow-up communications (including email and SMS), to independently verify the status of Leads, including whether the Homeowner has received bids, selected a contractor, or commenced a Project. The Contractor shall not interfere with, discourage, or obstruct such communications.'))
    story.append(p('<b>6.2 Audit Rights.</b> The Company shall have the right, no more than once per calendar quarter and upon not less than ten (10) business days\' prior written notice, to audit the Contractor\'s books, records, invoices, contracts, and correspondence related to Leads delivered under this Agreement. The Contractor shall cooperate fully and provide reasonable access to relevant records during normal business hours.'))
    story.append(p('<b>6.3 Scope of Audit.</b> The scope of any audit under Section 6.2 shall be limited to records pertaining to Projects originated from Leads delivered by the Company. The Company shall not have access to records unrelated to Company-sourced Leads.'))
    story.append(p('<b>6.4 Consequences of Underreporting.</b> If the Company determines, through audit, Homeowner follow-up, or other means, that the Contractor has failed to report one or more Accepted Bids as required by Section 5:'))
    story.append(Paragraph('(a) <b>Unreported Accepted Bid:</b> The Contractor shall immediately pay the applicable Lead Fee of $1,000.00 for each unreported Accepted Bid, plus a late reporting penalty of Two Hundred Fifty Dollars ($250.00) per unreported Accepted Bid.', subbullet))
    story.append(Paragraph('(b) <b>Suspension of Leads:</b> Upon discovery of any unreported Accepted Bid, the Company may immediately suspend Lead delivery to the Contractor pending resolution.', subbullet))
    story.append(Paragraph('(c) <b>Automatic Termination:</b> If the Contractor fails to report two (2) or more Accepted Bids within any twelve (12) month period, the Company may terminate this Agreement immediately for cause, and all outstanding Lead Fees and late reporting penalties shall become immediately due and payable.', subbullet))
    story.append(p('<b>6.5 Lead Withholding.</b> Without limiting any other rights under this Agreement, the Company may, in its sole and absolute discretion, pause, limit, redirect, or discontinue Lead delivery to the Contractor at any time. The exercise of this right shall not constitute a breach of this Agreement.'))
    story.append(hr())

    # § 7
    story.append(p('SECTION 7. CONTRACTOR CREDENTIALS', h2))
    story.append(p('<b>7.1 License.</b> The Contractor represents and warrants that it holds, and shall maintain throughout the term of this Agreement, all licenses required by the State of Wisconsin to perform residential deck construction and improvement services, including any applicable registration or credential issued by the Wisconsin Department of Safety and Professional Services (DSPS) under Wisconsin Administrative Code SPS 305.'))
    story.append(p('<b>7.2 Insurance.</b> The Contractor represents and warrants that it maintains, and shall use commercially reasonable efforts to maintain throughout the term of this Agreement, commercial general liability insurance with a minimum coverage of One Million Dollars ($1,000,000.00) per occurrence from an insurer licensed to do business in Wisconsin. The Contractor shall provide proof of such insurance to the Company upon onboarding and shall provide prompt written notice of any material change in coverage.'))
    story.append(p('<b>7.3 Notice of Lapse.</b> The Contractor shall provide the Company with written notice within five (5) business days of any lapse, suspension, revocation, or material change in the Contractor\'s license or insurance coverage.'))
    story.append(p('<b>7.4 Consequences of License Lapse.</b> If the Contractor\'s required Wisconsin contractor license lapses, is suspended, or is revoked: (a) the Company may immediately pause Lead delivery without prior notice; (b) the Company may remove the Contractor from all Company advertising and Homeowner-facing communications; and (c) if the license is not restored within thirty (30) days of lapse, the Company may terminate this Agreement for cause.'))
    story.append(p('<b>7.5 Company\'s Right to Verify.</b> The Company may independently verify the Contractor\'s license status at any time through DSPS records or other public databases.'))
    story.append(hr())

    # § 8
    story.append(p('SECTION 8. DATA HANDLING AND HOMEOWNER PRIVACY', h2))
    story.append(p('<b>8.1 Permitted Use.</b> The Contractor may use Homeowner PII received from the Company solely for the purpose of contacting the Homeowner, providing a bid, and performing work related to the specific Project for which the Lead was generated. The Contractor shall not use Homeowner PII for any other purpose.'))
    story.append(p('<b>8.2 Prohibited Uses.</b> Without limiting Section 8.1, the Contractor shall not: (a) sell, rent, lease, or otherwise transfer Homeowner PII to any third party; (b) use Homeowner PII for marketing purposes unrelated to the specific CWDB-referred Project, including adding Homeowners to mailing lists or email marketing campaigns; (c) share Homeowner PII with subcontractors or other parties except as reasonably necessary to perform work on the specific referred Project; or (d) use Homeowner PII to directly solicit the Homeowner for future projects that bypass the Company\'s lead generation system.'))
    story.append(p('<b>8.3 Data Security.</b> The Contractor shall implement and maintain reasonable administrative, technical, and physical safeguards to protect Homeowner PII from unauthorized access, disclosure, alteration, or destruction, consistent with industry standards for businesses of similar size and scope.'))
    story.append(p('<b>8.4 Data Retention and Deletion.</b> Upon termination or expiration of this Agreement, the Contractor shall, within thirty (30) days, delete or destroy all Homeowner PII received from the Company that is not required for an active, ongoing Project or by applicable law, and shall provide written certification to the Company confirming such deletion or destruction.'))
    story.append(p('<b>8.5 Breach Notification.</b> The Contractor shall notify the Company in writing within seventy-two (72) hours of discovering any actual or suspected unauthorized access to or disclosure of Homeowner PII, including the nature of the breach, the data affected, and the Contractor\'s remediation plan.'))
    story.append(hr())

    # § 9
    story.append(p('SECTION 9. CONFIDENTIALITY', h2))
    story.append(p('<b>9.1 Confidentiality Obligation.</b> Each Party agrees to hold the other Party\'s Confidential Information in strict confidence and not to disclose it to any third party without the prior written consent of the disclosing Party, except as required by law or as reasonably necessary to perform obligations under this Agreement.'))
    story.append(p('<b>9.2 Company Confidential Information.</b> Without limiting Section 9.1, the Contractor specifically agrees that the following constitute Confidential Information of the Company: Lead Fee amounts and pricing structure; lead sources and advertising methods; technology systems and automation workflows; the number and identity of other contractors in the Company\'s network; and the Company\'s business plans and expansion strategies.'))
    story.append(p('<b>9.3 Exceptions.</b> Confidential Information does not include information that: (a) is or becomes publicly available through no fault of the receiving Party; (b) was already known to the receiving Party prior to disclosure; (c) is independently developed by the receiving Party without use of the disclosing Party\'s Confidential Information; or (d) is disclosed pursuant to a valid court order or legal requirement, provided the receiving Party gives prompt prior notice to the disclosing Party.'))
    story.append(p('<b>9.4 Survival.</b> The obligations under this Section shall survive termination or expiration of this Agreement for a period of two (2) years.'))
    story.append(hr())

    # § 10
    story.append(p('SECTION 10. INDEPENDENT CONTRACTOR STATUS', h2))
    story.append(p('<b>10.1 Independent Contractor.</b> The Contractor is an independent contractor and not an employee, partner, joint venturer, or agent of the Company. Nothing in this Agreement creates or is intended to create an employment relationship, partnership, joint venture, or agency relationship between the Parties.'))
    story.append(p('<b>10.2 No Authority to Bind.</b> The Contractor has no authority to bind the Company, make representations on behalf of the Company, or incur obligations on behalf of the Company.'))
    story.append(p('<b>10.3 Taxes and Benefits.</b> The Contractor is solely responsible for all federal, state, and local taxes arising from payments received under this Agreement, including self-employment taxes. The Company will not withhold taxes from Lead Fee payments and will not provide the Contractor with employee benefits of any kind. The Company will issue a Form 1099-NEC to the Contractor for payments of $600 or more in a calendar year, as required by the Internal Revenue Code.'))
    story.append(p('<b>10.4 Contractor\'s Employees and Subcontractors.</b> The Contractor is solely responsible for its own employees, subcontractors, and agents, including their compensation, taxes, insurance, and compliance with all applicable labor and employment laws.'))
    story.append(hr())

    # § 11
    story.append(p('SECTION 11. NON-DISPARAGEMENT', h2))
    story.append(p('<b>11.1 Mutual Non-Disparagement.</b> During the term of this Agreement and for a period of one (1) year following termination, neither Party shall make any public statement, whether oral, written, or electronic, that disparages, defames, or reflects negatively on the other Party, its owners, officers, employees, or services. This provision does not restrict either Party from making truthful statements required by law, in legal proceedings, or in response to a government inquiry.'))
    story.append(hr())

    # § 12
    story.append(p('SECTION 12. INDEMNIFICATION', h2))
    story.append(p('<b>12.1 Contractor Indemnification.</b> The Contractor shall indemnify, defend, and hold harmless the Company and its owners, officers, managers, employees, and agents (the "Company Indemnified Parties") from and against any and all claims, actions, suits, liabilities, damages, losses, costs, and expenses (including reasonable attorneys\' fees) arising out of or relating to: (a) the Contractor\'s performance or failure to perform any Project; (b) the Contractor\'s breach of this Agreement; (c) the Contractor\'s use or misuse of Homeowner PII; (d) any claim by a Homeowner or third party related to the Contractor\'s work, workmanship, materials, or conduct; (e) the Contractor\'s violation of any applicable law, regulation, or building code; or (f) any claim arising from the Contractor\'s failure to maintain required licenses or insurance.'))
    story.append(p('<b>12.2 Company Indemnification.</b> The Company shall indemnify, defend, and hold harmless the Contractor from and against any and all claims, liabilities, damages, losses, costs, and expenses (including reasonable attorneys\' fees) arising out of or relating to the Company\'s material breach of this Agreement or the Company\'s gross negligence or willful misconduct.'))
    story.append(hr())

    # § 13
    story.append(p('SECTION 13. LIMITATION OF LIABILITY', h2))
    story.append(p('<b>13.1 Cap on Company Liability.</b> IN NO EVENT SHALL THE COMPANY\'S TOTAL AGGREGATE LIABILITY TO THE CONTRACTOR UNDER OR IN CONNECTION WITH THIS AGREEMENT EXCEED THE TOTAL LEAD FEES ACTUALLY PAID BY THE CONTRACTOR TO THE COMPANY DURING THE THREE (3) MONTH PERIOD IMMEDIATELY PRECEDING THE EVENT GIVING RISE TO THE CLAIM.', caps_sec))
    story.append(p('<b>13.2 Exclusion of Consequential Damages.</b> IN NO EVENT SHALL THE COMPANY BE LIABLE TO THE CONTRACTOR FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, PUNITIVE, OR EXEMPLARY DAMAGES, INCLUDING BUT NOT LIMITED TO DAMAGES FOR LOST PROFITS, LOST REVENUE, OR LOSS OF GOODWILL, REGARDLESS OF WHETHER SUCH DAMAGES WERE FORESEEABLE OR WHETHER THE COMPANY WAS ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.', caps_sec))
    story.append(p('<b>13.3 Exceptions.</b> The limitations in this Section 13 shall not apply to: (a) the Company\'s indemnification obligations under Section 12.2; or (b) damages arising from the Company\'s gross negligence or willful misconduct.'))
    story.append(hr())

    # § 14
    story.append(p('SECTION 14. DISPUTE RESOLUTION', h2))
    story.append(p('<b>14.1 Informal Resolution.</b> Before initiating any formal dispute resolution proceeding, the aggrieved Party shall provide written notice of the dispute to the other Party, and the Parties shall attempt in good faith to resolve the dispute through informal negotiation for a period of thirty (30) calendar days from the date of such notice.'))
    story.append(p('<b>14.2 Binding Arbitration.</b> If the dispute is not resolved within the thirty (30) day informal negotiation period, either Party may submit the dispute to binding arbitration conducted in Marathon County, Wisconsin, by a single arbitrator, in accordance with the rules of the American Arbitration Association (AAA) then in effect. The arbitrator\'s decision shall be final and binding on both Parties, and judgment on the award may be entered in any court of competent jurisdiction.'))
    story.append(p('<b>14.3 Costs of Arbitration.</b> Each Party shall bear its own attorneys\' fees and costs in connection with any arbitration, except that the prevailing Party shall be entitled to recover its reasonable attorneys\' fees and arbitration costs from the non-prevailing Party.'))
    story.append(p('<b>14.4 Equitable Relief.</b> Notwithstanding the foregoing, either Party may seek injunctive or other equitable relief in any court of competent jurisdiction to prevent irreparable harm, including but not limited to breaches of Sections 8 (Data Handling) and 9 (Confidentiality), without first complying with the informal negotiation or arbitration requirements of this Section.'))
    story.append(p('<b>14.5 Small Claims.</b> Disputes involving amounts of $10,000 or less may be brought in the small claims court of Marathon County, Wisconsin, at the election of either Party, as an alternative to arbitration.'))
    story.append(hr())

    # § 15
    story.append(p('SECTION 15. TERM AND TERMINATION', h2))
    story.append(p('<b>15.1 Term.</b> This Agreement shall commence on the Effective Date and shall continue in effect until terminated by either Party in accordance with this Section.'))
    story.append(p('<b>15.2 Termination Without Cause.</b> Either Party may terminate this Agreement at any time, for any reason or no reason, upon thirty (30) days\' prior written notice to the other Party.'))
    story.append(p('<b>15.3 Termination for Cause by Company.</b> The Company may terminate this Agreement immediately upon written notice to the Contractor if: (a) the Contractor fails to pay any Lead Fee within thirty (30) days of the invoice due date; (b) the Contractor breaches any material term of this Agreement and fails to cure such breach within fifteen (15) days of written notice (except for breaches incapable of cure, which result in immediate termination); (c) the Contractor\'s required license lapses and is not restored within thirty (30) days; (d) the Contractor fails to report two (2) or more Accepted Bids within any twelve (12) month period; (e) the Contractor engages in fraud, dishonesty, or willful misconduct; or (f) the Contractor becomes insolvent, files for bankruptcy, or has a receiver appointed for its business.'))
    story.append(p('<b>15.4 Termination for Cause by Contractor.</b> The Contractor may terminate this Agreement immediately upon written notice to the Company if the Company materially breaches this Agreement and fails to cure such breach within thirty (30) days of written notice from the Contractor.'))
    story.append(p('<b>15.5 Effect of Termination.</b> Upon termination of this Agreement: (a) the Company shall cease delivering Leads to the Contractor; (b) all Lead Fees for Accepted Bids that occurred prior to or on the date of termination shall remain due and payable; (c) the Contractor shall comply with the data deletion requirements of Section 8.4; and (d) Sections 6.4, 9, 11, 12, 13, and 14 shall survive termination.'))
    story.append(p('<b>15.6 Tail Period.</b> The Contractor\'s obligation to report and pay Lead Fees for Accepted Bids on Leads delivered prior to termination shall continue for twelve (12) months following the effective date of termination (the "Tail Period"). If a Homeowner from a pre-termination Lead accepts the Contractor\'s bid during the Tail Period, the Contractor owes the Lead Fee as if this Agreement were still in effect.'))
    story.append(hr())

    # § 16
    story.append(p('SECTION 16. GENERAL PROVISIONS', h2))
    story.append(p('<b>16.1 Governing Law.</b> This Agreement shall be governed by and construed in accordance with the laws of the State of Wisconsin, without regard to its conflict of laws principles.'))
    story.append(p('<b>16.2 Jurisdiction and Venue.</b> The Parties consent to the exclusive jurisdiction and venue of the state and federal courts located in Marathon County, Wisconsin, for any legal proceedings not subject to arbitration under Section 14.'))
    story.append(p('<b>16.3 Entire Agreement.</b> This Agreement constitutes the entire agreement between the Parties with respect to the subject matter hereof and supersedes all prior and contemporaneous agreements, representations, warranties, and understandings, whether oral or written, including any prior verbal commitments, text messages, or informal communications regarding lead delivery or pricing.'))
    story.append(p('<b>16.4 Amendments.</b> This Agreement may not be amended, modified, or supplemented except by a written instrument signed by both Parties.'))
    story.append(p('<b>16.5 Severability.</b> If any provision of this Agreement is held to be invalid, illegal, or unenforceable, such provision shall be modified to the minimum extent necessary to make it valid and enforceable, and the remaining provisions shall continue in full force and effect.'))
    story.append(p('<b>16.6 No Waiver.</b> The failure of either Party to enforce any provision of this Agreement shall not constitute a waiver of that Party\'s right to enforce that provision or any other provision in the future. No waiver shall be effective unless made in writing and signed by the waiving Party.'))
    story.append(p('<b>16.7 Assignment.</b> The Contractor may not assign or transfer this Agreement or any rights or obligations hereunder without the prior written consent of the Company. The Company may assign this Agreement to any successor entity without the Contractor\'s consent.'))
    story.append(p('<b>16.8 Notices.</b> All notices required or permitted under this Agreement shall be in writing and shall be deemed delivered when: (a) personally delivered; (b) sent by email with confirmation of receipt; or (c) sent by certified mail, return receipt requested, to the addresses below.'))
    story.append(sp(0.1))

    notice_data = [
        [Paragraph('<b>COMPANY:</b>', bold_body), Paragraph('<b>CONTRACTOR:</b>', bold_body)],
        [Paragraph('Central Wisconsin Deck Builders, LLC\nAttn: James Slogar\n906 N 16th Ave., Wausau, WI 54401\nEmail: slogarjw@gmail.com', normal),
         Paragraph(f'{c["name"]}\nAttn: {c["contact_name"]}\n{c["street"]}, {c["city"]}, {state} {c["zip"]}\nEmail: {c["contact_email"]}', normal)],
    ]
    nt = Table(notice_data, colWidths=[3.05*inch, 3.05*inch])
    nt.setStyle(TableStyle([
        ('VALIGN',        (0,0),(-1,-1), 'TOP'),
        ('TOPPADDING',    (0,0),(-1,-1), 5),
        ('BOTTOMPADDING', (0,0),(-1,-1), 5),
        ('LINEBELOW',     (0,0),(-1,0), 0.5, GREY),
    ]))
    story.append(nt)
    story.append(sp(0.1))

    story.append(p('<b>16.9 Counterparts.</b> This Agreement may be executed in counterparts, each of which shall be deemed an original, and all of which together shall constitute one and the same instrument. Electronic signatures shall be deemed valid and binding to the same extent as original signatures.'))
    story.append(p('<b>16.10 Force Majeure.</b> Neither Party shall be liable for any failure or delay in performance due to causes beyond its reasonable control, including but not limited to acts of God, natural disasters, pandemics, or government actions, provided the affected Party gives prompt notice and uses commercially reasonable efforts to resume performance.'))
    story.append(p('<b>16.11 Headings.</b> Section headings are for convenience only and shall not affect the interpretation of this Agreement.'))
    story.append(hr())

    # ── SIGNATURES ───────────────────────────────────────────────────────────────
    story.append(PageBreak())
    story.append(p('SIGNATURES', h2))
    story.append(p('<b>IN WITNESS WHEREOF</b>, the Parties have executed this Agreement as of the Effective Date first written above.'))
    story.append(sp(0.25))

    sig_data = [
        [
            Table([
                [p('<b>COMPANY:</b>')],
                [p('Central Wisconsin Deck Builders, LLC<br/>A Wisconsin Limited Liability Company<br/>Entity ID No. C138564')],
                [sp(0.25)],
                [p('Signature: ____________________________')],
                [sp(0.04)],
                [p('Printed Name: James Slogar')],
                [sp(0.04)],
                [p('Title: Manager / Sole Member')],
                [sp(0.04)],
                [p('Date: ________________________________')],
            ], colWidths=[2.9*inch]),
            Table([
                [p('<b>CONTRACTOR:</b>')],
                [p(f'{c["name"]}')],
                [sp(0.25)],
                [p('Signature: ____________________________')],
                [sp(0.04)],
                [p(f'Printed Name: {c["contact_name"]}')],
                [sp(0.04)],
                [p(f'Title: {c["contact_title"]}')],
                [sp(0.04)],
                [p('Date: ________________________________')],
            ], colWidths=[2.9*inch]),
        ]
    ]
    st = Table(sig_data, colWidths=[3.15*inch, 3.15*inch])
    st.setStyle(TableStyle([('VALIGN', (0,0),(-1,-1), 'TOP')]))
    story.append(st)
    story.append(sp(0.35))
    story.append(HRFlowable(width='100%', thickness=1, color=ORANGE, spaceAfter=0))

    doc.build(story)
    return output_path


if __name__ == '__main__':
    import os
    # Standalone run: generates a blank-placeholder copy for review
    placeholder = {
        "name": "_____________________________________________",
        "entity_type": "_______________________ [e.g., Wisconsin limited liability company]",
        "street": "_________________________________________________",
        "city": "_________________",
        "state": "WI",
        "zip": "_________",
        "contact_name": "________________________",
        "contact_title": "________________________________",
        "contact_email": "__________________________",
        "effective_date": "_____________________, 2026",
    }
    here = os.path.dirname(os.path.abspath(__file__))
    out = os.path.join(here, 'contractor-lead-purchase-agreement-v1.pdf')
    path = generate_pdf(placeholder, out)
    print(f"SUCCESS: {path}")
