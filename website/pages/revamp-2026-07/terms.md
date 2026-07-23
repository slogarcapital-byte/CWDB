---
type: page-revamp
page: Terms of Service
url: /terms
source: website/pages/terms/content.md
tasks: [audit-2026-07-05#13, audit-2026-07-05#21]
status: draft-for-yde-review
---

# Terms of Service Revamp: `/terms`

> **DRAFT FOR LAUREN YDE (YDE LAW) REVIEW.** These REPLACE blocks rewrite the live Terms of Service to match reality after the 2026-07-05 construction pivot. Do NOT publish to Webflow until Yde reviews. The limitation-of-liability rework (Section 8) and the ATCP 110 / Wisconsin Consumer Act savings language are the items most worth her eyes.

The live ToS still describes CWDB as a pure "referral and matching service" that "does not perform any construction work." That is false: CWDB self-performs deck construction, repair, and refinishing (the cwdb lane, for example the completed Overbeck job), and for some projects a named independent builder performs the work (the builder lane). This package rewrites the ToS to the true dual model, keeps the liability structure coherent (the $100 cap now applies to website use only, not to construction CWDB performs), adds an SMS section consistent with the new privacy policy, and preserves Wisconsin law and ATCP 110 alignment.

Live copy source: `website/pages/terms/content.md`.

## How to read a REPLACE block

Same convention as the rest of this revamp package (see `README.md`). Find OLD on the live page, swap in NEW. Blocks marked **NEW SECTION** are additive. NEW text follows the project no-em-dash rule.

**Two notes for the web-dev applying this:**
1. The vault source for Section 2 renders "Central Wisconsin Deck Builders" from a wikilink; on the live page it is plain text. The OLD blocks below use the plain rendered text so the find matches the live page.
2. Where a whole section body is rewritten, the OLD block is the entire body under that heading. Replace the body, keep the heading unless a heading REPLACE is given.

---

## Header

### REPLACE: Last Updated date
OLD:
**Last Updated:** March 29, 2026
NEW:
**Last Updated:** July 22, 2026

---

## Section 2: Service Description

### REPLACE: Section 2 body (everything under the "## 2. Service Description" heading, through the bold "referral and matching service" paragraph)
OLD:
Central Wisconsin Deck Builders ("CWDB," "we," "us," or "our") operates an online platform that connects homeowners with vetted, licensed deck building contractors in Central Wisconsin.

Our service includes:
- Accepting project details from homeowners via online quote request forms
- Reviewing and qualifying project requests
- Matching homeowners with contractors in our network based on location, availability, and project type
- Facilitating the initial connection between homeowner and contractor

**CWDB is a referral and matching service.** We are not a general contractor, construction company, or builder. We do not perform any construction work, and we are not a party to any agreement between you and a contractor.
NEW:
Central Wisconsin Deck Builders, LLC ("CWDB," "we," "us," or "our") is a deck company serving Central Wisconsin. We design, build, replace, repair, and refinish (stain and reseal) residential decks, and we generate and respond to homeowner project requests through this website.

Depending on your project, your work is handled in one of two ways:

- **Work we perform (self-perform).** For many projects, including deck staining, refinishing, repair, and construction, CWDB is your contractor and performs the work under a written home improvement contract you sign with CWDB. CWDB carries commercial general liability insurance.
- **Work performed by a named independent builder (builder referral).** For some projects, CWDB prepares your estimate and arranges for an independent deck builder to perform the work. When that happens, we tell you that builder's name in writing before you commit, the builder signs its own contract directly with you, and that builder (not CWDB) is responsible for performing the construction. In that case CWDB is not a party to your contract with the builder.

We will tell you, before you sign any construction contract, whether CWDB or a named independent builder will perform your project. Submitting a form on this website does not by itself create a contract for construction work.

---

## Section 3: Estimates and Who Performs Your Work

### REPLACE: Section 3 heading
OLD:
## 3. No Guarantees on Contractor Work
NEW:
## 3. Estimates and Who Performs Your Work

### REPLACE: Section 3 body (everything under the heading)
OLD:
While we vet every contractor in our network for licensing, insurance, and track record, **we do not guarantee the quality, timeliness, cost, or outcome of any work performed by a contractor.**

Specifically, CWDB does not guarantee:
- That a contractor's quote will match the final project cost
- That work will be completed by a specific date
- That the finished project will meet your expectations
- That no disputes will arise between you and the contractor
- That a contractor will remain available after being matched to your project

Any agreement you enter into with a contractor — including scope, pricing, timeline, warranties, and payment terms — is solely between you and the contractor. CWDB is not a party to that agreement and bears no responsibility for its fulfillment.
NEW:
An estimate or quote is a good-faith projection, not a final bill. The final scope, price, schedule, warranties, and payment terms for any project are set by the written contract you sign with the party that performs the work. Changes to scope or price are handled by written change order.

**For projects CWDB performs,** CWDB stands behind its work as stated in the written home improvement contract you sign with CWDB, including any workmanship warranty in that contract. Our work is insured.

**For projects performed by a named independent builder,** that builder is responsible for the quality, timeliness, cost, and completion of the work under the contract you sign directly with that builder. CWDB is not a party to that contract and is not responsible for that builder's performance.

In either case, an estimate is not a promise that the final cost will match the estimate, that work will finish by a specific date, or that no disputes will arise.

---

## Section 4: User Responsibilities

### REPLACE: Section 4 bullet, "communicate directly with the matched contractor"
OLD:
- You will communicate directly with the matched contractor regarding project details, pricing, and scheduling.
NEW:
- You will communicate with CWDB, or, for a project performed by a named independent builder, with that builder, regarding project details, pricing, and scheduling.

### REPLACE: Section 4 bullet, "conducting your own due diligence before hiring any contractor"
OLD:
- You are responsible for conducting your own due diligence before hiring any contractor, including verifying credentials, reviewing contracts, and checking references.
NEW:
- You are responsible for reviewing your contract before you sign it, whether it is with CWDB or with a named independent builder, and for asking any questions about scope, price, and warranty before work begins.

---

## Section 5: Free Estimates; Paid Construction Work

### REPLACE: Section 5 heading
OLD:
## 5. No Fee to Homeowners
NEW:
## 5. Free Estimates; Paid Construction Work

### REPLACE: Section 5 body (everything under the heading)
OLD:
Our service is free for homeowners. There is no charge to submit a quote request, receive a contractor match, or obtain a quote. You are never obligated to hire a contractor through our service.
NEW:
Requesting a quote, receiving a walk-through, and getting an estimate are free, and you are never obligated to move forward. If you hire CWDB to perform your project, the construction work is a paid service governed by the written home improvement contract you sign with CWDB, including its price, deposit, and payment schedule. If your project is performed by a named independent builder, your price and payment terms are set by your contract with that builder.

---

## Section 8: Limitation of Liability

### REPLACE: Section 8 body (everything under the "## 8. Limitation of Liability" heading; keep the heading)
OLD:
**To the fullest extent permitted by law, Central Wisconsin Deck Builders, its owners, operators, employees, and affiliates shall not be liable for any:**

- Direct, indirect, incidental, consequential, or punitive damages arising from your use of our website or service
- Damages resulting from any contractor's work, conduct, or failure to perform
- Loss of data, revenue, or business opportunity related to the use of our service
- Errors, inaccuracies, or omissions in website content

**Our total liability to you for any claim arising from or related to our service shall not exceed $100.**

You acknowledge that CWDB is a free referral service for homeowners and that this limitation of liability is reasonable given the nature of the service provided.
NEW:
This Section applies to your use of this website and its content. It does NOT limit CWDB's obligations for construction work CWDB performs, which are governed by your signed home improvement contract and by Wisconsin law.

**To the fullest extent permitted by law, and with respect to your use of this website and its content, Central Wisconsin Deck Builders, LLC, its owners, members, employees, and affiliates shall not be liable for any:**

- Direct, indirect, incidental, consequential, or punitive damages arising from your use of this website
- Loss of data, revenue, or business opportunity related to your use of this website
- Errors, inaccuracies, or omissions in website content
- The acts, work, or conduct of a named independent builder who contracts with you directly

**For claims arising from your use of this website, our total liability to you shall not exceed one hundred dollars ($100).**

This cap does not apply to, and nothing in these Terms limits: (a) CWDB's obligations under a written home improvement contract you sign with CWDB for work CWDB performs; (b) any liability that cannot be limited or disclaimed under Wisconsin law; or (c) your rights under the Wisconsin home improvement practices rules (Wis. Admin. Code ch. ATCP 110) or the Wisconsin Consumer Act (Wis. Stat. chs. 421 to 427).

---

## Section 9: Indemnification

### REPLACE: Section 9 bullet, "Any dispute between you and a contractor"
OLD:
- Any dispute between you and a contractor
NEW:
- Any dispute between you and a named independent builder who contracts with you directly

---

## Section 11: Dispute Resolution

### REPLACE: Section 11 intro line (immediately under the heading, before the numbered list)
OLD:
Any dispute arising from or related to these Terms or your use of our service shall be resolved as follows:
NEW:
Any dispute arising from or related to these Terms or your use of this website shall be resolved as follows. Disputes about construction work CWDB performs are governed instead by the dispute resolution terms of the home improvement contract you sign with CWDB.

---

## Section 15: Entire Agreement

### REPLACE: Section 15 body (everything under the heading)
OLD:
These Terms, together with our [Privacy Policy](/privacy), constitute the entire agreement between you and Central Wisconsin Deck Builders regarding your use of our website and service.
NEW:
These Terms, together with our [Privacy Policy](/privacy), constitute the entire agreement between you and Central Wisconsin Deck Builders, LLC regarding your use of this website. If you hire CWDB to perform a project, the written home improvement contract you sign with CWDB governs that work and controls over these Terms to the extent of any conflict about the construction.

---

## NEW SECTION: Communications and Text Messages (SMS)

Insert this as a new numbered section AFTER the current Section 15 (Entire Agreement) and BEFORE the "Contact Us" block. Number it 16. Its terms match the SMS section of the Privacy Policy and the site's consent checkbox language.

```
## 16. Communications and Text Messages (SMS)

By providing your phone number and agreeing to be contacted (by checking the consent box on our form, or by replying YES to a confirmation text), you consent to receive calls, text messages, and emails from Central Wisconsin Deck Builders, LLC and, where applicable, the named independent builder handling your project, about your project request.

- Consent to receive text messages is not a condition of requesting or receiving a quote.
- Message frequency varies based on your project and our follow-up.
- Message and data rates may apply.
- To stop text messages at any time, reply STOP. For help, reply HELP, or contact us at (715) 544-7941 or info@cwdeckbuilders.com.

We handle your information, including your mobile number and your consent, as described in our Privacy Policy. We do not sell your personal information, and we do not share your mobile number with third parties for their own marketing.
```

---

## Notes for Yde (not part of the page)

1. **Limitation of liability scope (Section 8).** The old $100 cap covered "any claim arising from or related to our service" and was justified by CWDB being a "free referral service." That rationale is gone now that CWDB performs paid construction. The rewrite scopes the $100 cap to website use only and carves out CWDB's construction obligations, non-waivable liability, and consumer rights under ATCP 110 and the Wisconsin Consumer Act. Please confirm this scoping holds and that the savings clause is worded the way you want.
2. **Consumer-rights savings clause.** A home improvement contract cannot waive the buyer's ATCP 110 or Wisconsin Consumer Act rights. The savings clause in Section 8(c) is meant to make that explicit in the ToS. Confirm placement and scope.
3. **SMS section.** Mirrors the Privacy Policy drafted the same day and the finalized on-form TCPA consent text. Confirm it is consistent with how CWDB actually sends texts (reply-YES confirmation plus consent checkbox; STOP/HELP handling).
4. **Named-builder disclosure.** Section 2 and Section 3 describe the builder lane at a high level. The operative disclosure and the builder's own contract live in the estimate and contract documents, not here. Confirm the ToS description is consistent with those.
5. **No "licensed" claim.** Per current ground truth, the DSPS Dwelling Contractor license is in progress, not issued, so no "licensed" or "bonded" claim appears anywhere in the rewrite. "Insured" is used because the $1M/$2M general liability policy is bound. Confirm this stays accurate at publish time; if the license issues before publish, we can add it.

> **DISCLAIMER:** This revamp copy was prepared by AI legal counsel for informational purposes. Review by a licensed Wisconsin attorney (Lauren Yde, Yde Law) is recommended before publication.
