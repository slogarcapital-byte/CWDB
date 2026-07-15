// jobtread-gateway: CWDB intake + JobTread webhook receiver.
//
// /intake : Webflow relay POST -> stamp attribution -> dual-write
//           JobTread (Pave: account -> contact -> location -> job) +
//           HubSpot Forms API (safety net) -> bronze raw_intake_events row.
//           Public endpoint by design (replaces the unauthenticated
//           api.hsforms.com relay target); deployed with verify_jwt=false.
// /webhook: JobTread event -> log to raw_jobtread_events. Custom auth:
//           requires ?token=<JT_WEBHOOK_TOKEN> (JobTread cannot send JWTs).
//           Attribution fan-out is added in Task 10 (design §6).
//
// Pave schema facts (validated 2026-07-14, see
// operations/jobtread/org-setup-notes.md): customers are "accounts"; jobs
// hang off locations; contact phone/email and all CWDB fields are custom
// fields; create-mutation customFieldValues is a map keyed by FIELD ID, so
// the field name->id map is fetched at cold start and cached per isolate.
import { createClient } from "npm:@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);
const GRANT_KEY = Deno.env.get("JOBTREAD_GRANT_KEY")!;
const ORG_ID = Deno.env.get("JOBTREAD_ORG_ID")!;
const WEBHOOK_TOKEN = Deno.env.get("JT_WEBHOOK_TOKEN")!;
const HS_ENDPOINT =
  "https://api.hsforms.com/submissions/v3/integration/submit/245712220/bb473d64-06b1-4311-8e02-7c70d605b79b";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "content-type",
};

async function pave(query: unknown): Promise<any> {
  const res = await fetch("https://api.jobtread.com/pave", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query }),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(`pave ${res.status}: ${JSON.stringify(body)}`);
  return body;
}

// Field name -> id map, cached per isolate. Key: `${targetType}.${name}`.
let fieldMap: Record<string, string> | null = null;
async function getFieldMap(): Promise<Record<string, string>> {
  if (fieldMap) return fieldMap;
  const res = await pave({
    $: { grantKey: GRANT_KEY },
    organization: {
      $: { id: ORG_ID },
      customFields: {
        $: { size: 100 },
        nodes: { id: {}, name: {}, targetType: {} },
      },
    },
  });
  const map: Record<string, string> = {};
  for (const f of res.organization.customFields.nodes) {
    map[`${f.targetType}.${f.name}`] = f.id;
  }
  fieldMap = map;
  return map;
}

// Drop empty values so Pave never sees blank option-field writes.
function compact(obj: Record<string, unknown>): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(obj).filter(([, v]) => v !== undefined && v !== null && v !== ""),
  );
}

// ---- /intake ---------------------------------------------------------------
async function handleIntake(req: Request): Promise<Response> {
  const p = await req.json(); // flat payload from the relay (Task 7 FIELD_MAP)
  const bronze = {
    source: "webform",
    payload: p,
    hubspot_status: null as number | null,
    jobtread_status: null as number | null,
    jobtread_customer_id: null as string | null,
    jobtread_job_id: null as string | null,
    error: null as string | null,
  };

  // 1. JobTread write (failure must not block the HubSpot write, and vice versa)
  try {
    const fm = await getFieldMap();
    const name = p.name ?? "Unknown Lead";

    const acct = await pave({
      $: { grantKey: GRANT_KEY },
      createAccount: {
        $: {
          organizationId: ORG_ID,
          name,
          type: "customer",
          customFieldValues: compact({
            [fm["customer.utm_source"]]: p.utm_source,
            [fm["customer.utm_medium"]]: p.utm_medium,
            [fm["customer.utm_campaign"]]: p.utm_campaign,
            [fm["customer.gclid"]]: p.gclid,
            [fm["customer.lead_source_page"]]: p.page_uri,
          }),
        },
        createdAccount: { id: {} },
      },
    });
    const accountId = acct.createAccount.createdAccount.id;
    bronze.jobtread_customer_id = accountId;

    await pave({
      $: { grantKey: GRANT_KEY },
      createContact: {
        $: {
          accountId,
          name,
          customFieldValues: compact({
            [fm["customerContact.Phone"]]: p.phone,
            [fm["customerContact.Email"]]: p.email,
            [fm["customerContact.tcpa_consent_given"]]: p.tcpa_consent === "true",
            [fm["customerContact.tcpa_consent_source"]]: "form",
            [fm["customerContact.lead_channel"]]: "webform",
          }),
        },
        createdContact: { id: {} },
      },
    });

    const address = [p.address, p.zip].filter(Boolean).join(", ");
    const loc = await pave({
      $: { grantKey: GRANT_KEY },
      createLocation: {
        $: compact({ accountId, name: "Project site", address }),
        createdLocation: { id: {} },
      },
    });

    const job = await pave({
      $: { grantKey: GRANT_KEY },
      createJob: {
        $: {
          locationId: loc.createLocation.createdLocation.id,
          name: `${name} - ${p.project_type ?? "Deck project"}`,
          customFieldValues: compact({
            [fm["job.Status"]]: "New Lead",
            [fm["job.project_type"]]: p.project_type,
            [fm["job.budget_range"]]: p.budget,
            [fm["job.project_timeline"]]: p.timeline,
            [fm["job.owns_property"]]: p.owns_property,
            [fm["job.source_city"]]: p.city,
          }),
        },
        createdJob: { id: {} },
      },
    });
    bronze.jobtread_job_id = job.createJob.createdJob.id;
    bronze.jobtread_status = 200;
  } catch (e) {
    bronze.jobtread_status = 500;
    bronze.error = `jobtread: ${String(e).slice(0, 300)}`;
  }

  // 2. HubSpot safety-net write (same shape the old relay sent)
  try {
    const fields = Object.entries({
      firstname: p.name, email: p.email, phone: p.phone, address: p.address,
      zip: p.zip, project_type: p.project_type, budget_range: p.budget,
      project_timeline: p.timeline, lead_notes: p.notes,
      tcpa_consent_given: p.tcpa_consent, owns_property: p.owns_property,
      lead_source_page: p.page_uri, utm_source: p.utm_source,
      utm_campaign: p.utm_campaign, gclid: p.gclid,
    }).filter(([, v]) => v != null && v !== "")
      .map(([name, value]) => ({ name, value: String(value) }));
    const hs = await fetch(HS_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        fields,
        context: { pageUri: p.page_uri ?? "", pageName: p.page_name ?? "Get a Quote" },
      }),
    });
    bronze.hubspot_status = hs.status;
  } catch (e) {
    bronze.hubspot_status = 500;
    bronze.error = `${bronze.error ?? ""} hubspot: ${String(e).slice(0, 300)}`;
  }

  // 3. Bronze row ALWAYS lands (even if both writes failed)
  const { error } = await supabase.from("raw_intake_events").insert(bronze);
  if (error) console.error("bronze insert failed", error);

  return new Response(
    JSON.stringify({ ok: bronze.jobtread_status === 200 || bronze.hubspot_status === 200 }),
    { status: 200, headers: { ...CORS, "Content-Type": "application/json" } },
  );
}

// ---- /webhook (log-only until Task 10) --------------------------------------
async function handleWebhook(req: Request, url: URL): Promise<Response> {
  if (url.searchParams.get("token") !== WEBHOOK_TOKEN) {
    return new Response("unauthorized", { status: 401 });
  }
  const payload = await req.json();
  const { error } = await supabase.from("raw_jobtread_events").insert({
    event_id: payload?.id ?? payload?.eventId ?? null,
    event_type: payload?.type ?? payload?.event ?? null,
    payload,
  });
  if (error && !String(error.message).includes("duplicate")) {
    console.error("event insert failed", error);
  }
  return new Response("ok", { status: 200 });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  const url = new URL(req.url);
  try {
    if (url.pathname.endsWith("/intake") && req.method === "POST") {
      return await handleIntake(req);
    }
    if (url.pathname.endsWith("/webhook") && req.method === "POST") {
      return await handleWebhook(req, url);
    }
    return new Response("not found", { status: 404, headers: CORS });
  } catch (e) {
    console.error("gateway error", e);
    return new Response("error", { status: 500, headers: CORS });
  }
});
