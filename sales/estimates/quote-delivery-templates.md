# Quote / Estimate Delivery Templates

Short, concise templates for sending a deck estimate to a homeowner.
Merge fields map to the estimate JSON in `sales/estimates/_data/`.

**Merge fields**
- `{{first_name}}` — `client.name` first name
- `{{project}}` — short project label (e.g. "deck stain & refinish")
- `{{total}}` — quote total (e.g. "$2,800")
- `{{valid_days}}` — `valid_days` (default 14)
- `{{deposit_pct}}` — `payment.deposit_pct` (default 30)
- `{{sign_link}}` — QBO Contracts e-sign link
- `{{my_name}}` — sender (Jim)
- `{{my_phone}}` — callback number

---

## Email

**Subject:** Your deck quote from Central Wisconsin Deck Builders — {{total}}

Hi {{first_name}},

Thanks for the chance to quote your {{project}}. Your estimate is attached (PDF).

- **Total:** {{total}}
- **Deposit to book:** {{deposit_pct}}%
- **Good for:** {{valid_days}} days

To move forward, just review and sign here: {{sign_link}}. That locks in your spot on the schedule. Happy to walk through any line item or adjust the scope — reply or call/text me at {{my_phone}}.

Thanks,
{{my_name}}
Central Wisconsin Deck Builders
*Fast Quotes. Trusted Builders.*

---

## SMS

Hi {{first_name}}, it's {{my_name}} with Central WI Deck Builders. Your deck quote is ready — {{total}}, {{deposit_pct}}% to book, good {{valid_days}} days. Review & sign: {{sign_link}}. Questions? Just reply or call {{my_phone}}.

---

### Notes
- **TCPA:** only SMS leads with a logged consent source (`tcpa_consent_source` = form/verbal). Don't text "assumed"-consent leads.
- **Builder lane:** if `fulfillment.lane = builder`, the contractor signs/collects the deposit — change "Deposit to book" line to "A builder from our network will follow up to sign and schedule" and drop the deposit/sign-link.
- Keep SMS under ~320 chars (2 segments). Drop the sign link to a shortlink if needed.
