-- 010_lead_email_nullable.sql
-- Phone leads often arrive with a phone number and no email address
-- (e.g. inbound calls logged as HubSpot contacts). Webform leads always
-- carry both (the form requires them), so this only affects phone/manual
-- channel rows. phone stays NOT NULL: a lead with no phone and no email
-- is not contactable and should not be in fact_leads.

ALTER TABLE fact_leads ALTER COLUMN email DROP NOT NULL;

COMMENT ON COLUMN fact_leads.email IS
    'NULL allowed for phone/manual channel leads. Webform leads always have one.';
