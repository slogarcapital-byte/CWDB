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
  const text = await res.text();
  if (!res.ok) throw new Error(`pave ${res.status}: ${text.slice(0, 500)}`);
  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`pave non-json response: ${text.slice(0, 200)}`);
  }
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

// JobTread caps entity names at 30 characters ("Name cannot be more than 30
// characters" 400). Truncate every composed name.
const MAX_NAME = 30;
function trunc(s: string): string {
  return s.length > MAX_NAME ? s.slice(0, MAX_NAME) : s;
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

    // Account names are UNIQUE in JobTread ("already exists" 400). Two
    // homeowners can share a name, so retry with disambiguating suffixes.
    const last4 = (p.phone ?? "").replace(/\D/g, "").slice(-4);
    const base = name.slice(0, 22); // leave room for a " (xxxx)" suffix
    const candidates = [
      trunc(name),
      last4 ? `${base} (${last4})` : trunc(`${base} (${Date.now() % 100000})`),
      trunc(`${base} (${Date.now() % 100000})`),
    ];
    let acct: any = null;
    let lastErr: unknown = null;
    for (const candidate of candidates) {
      try {
        acct = await pave({
          $: { grantKey: GRANT_KEY },
          createAccount: {
            $: {
              organizationId: ORG_ID,
              name: candidate,
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
        break;
      } catch (e) {
        lastErr = e;
        if (!String(e).includes("already exists")) throw e;
      }
    }
    if (!acct) throw lastErr;
    const accountId = acct.createAccount.createdAccount.id;
    bronze.jobtread_customer_id = accountId;

    await pave({
      $: { grantKey: GRANT_KEY },
      createContact: {
        $: {
          accountId,
          name: trunc(name),
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
          name: trunc(`${name} - ${p.project_type ?? "Deck project"}`),
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

// ---- /webhook ----------------------------------------------------------------
// Observed JobTread payload shape (real event, 2026-07-15):
//   { _type: "root", createdEvent: { id, type: "jobUpdated",
//     job: {id}, account: {id}, location: {id},
//     data: { next: {custom: {Status: "..."}}, previous: {custom: {Status: "..."}} },
//     createdAt, ... } }
// Fan-out (design §6): on transition INTO "Signed / Booked", queue a Google
// offline conversion in conversions_outbox (uploaded by the local worker
// push-google-offline-conversions.ps1) and fire a GA4 MP event directly.
// Dedupe: unique index on raw_jobtread_events.event_id; a replayed event hits
// the duplicate error and skips fan-out entirely.
const SIGNED_STAGE = "Signed / Booked";

async function handleWebhook(req: Request, url: URL): Promise<Response> {
  if (url.searchParams.get("token") !== WEBHOOK_TOKEN) {
    return new Response("unauthorized", { status: 401 });
  }
  const payload = await req.json();
  const ev = payload?.createdEvent ?? {};
  const { error } = await supabase.from("raw_jobtread_events").insert({
    event_id: ev.id ?? null,
    event_type: ev.type ?? null,
    payload,
  });
  if (error) {
    if (!String(error.message).includes("duplicate")) {
      console.error("event insert failed", error);
    }
    return new Response("ok", { status: 200 }); // replay or unloggable: no fan-out
  }

  const nextStatus = ev?.data?.next?.custom?.Status;
  const prevStatus = ev?.data?.previous?.custom?.Status;
  const jobId = ev?.job?.id ?? null;
  if (ev.type === "jobUpdated" && jobId && nextStatus === SIGNED_STAGE && prevStatus !== SIGNED_STAGE) {
    try {
      // Recover the click id from the intake record that created this job.
      const { data: intake } = await supabase
        .from("raw_intake_events")
        .select("payload")
        .eq("jobtread_job_id", jobId)
        .order("id", { ascending: true })
        .limit(1)
        .maybeSingle();
      const gclid = intake?.payload?.gclid ?? null;
      await supabase.from("conversions_outbox").insert({
        platform: "google_ads",
        gclid,
        jobtread_job_id: jobId,
        status: gclid ? "pending" : "skipped",
        error: gclid ? null : "no gclid on intake record",
      });

      // GA4 Measurement Protocol: real-time signed-job event. Skips silently
      // until GA4_MEASUREMENT_ID + GA4_API_SECRET secrets are set.
      const mid = Deno.env.get("GA4_MEASUREMENT_ID");
      const sec = Deno.env.get("GA4_API_SECRET");
      if (mid && sec) {
        await fetch(
          `https://www.google-analytics.com/mp/collect?measurement_id=${mid}&api_secret=${sec}`,
          {
            method: "POST",
            body: JSON.stringify({
              client_id: `jobtread.${jobId}`,
              events: [{ name: "job_signed", params: { job_id: jobId } }],
            }),
          },
        ).catch((e) => console.error("ga4 mp failed", e));
      }
    } catch (e) {
      console.error("fan-out failed (event logged, conversion may be missing)", e);
    }
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
