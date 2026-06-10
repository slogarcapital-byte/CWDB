/* CWDB Mission Control — fetch/render/actions. Refresh-on-load only (+ manual button). */
let S = null;            // last /api/state bundle
let decideId = null;     // approval being decided in the dialog

const $ = (id) => document.getElementById(id);
const dlg = (id) => $(id);
const esc = (s) => String(s ?? '').replace(/[&<>"']/g, (c) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));

function toast(msg, isErr = false) {
  const el = document.createElement('div');
  el.className = 'toast-item' + (isErr ? ' err' : '');
  el.textContent = msg;
  $('toast').appendChild(el);
  setTimeout(() => el.remove(), isErr ? 9000 : 4000);
}

async function api(path, body) {
  const opts = body ? { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(body) } : {};
  const r = await fetch(path, opts);
  const j = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(j.error || `${r.status} on ${path}`);
  return j;
}

async function load() {
  try {
    S = await api('/api/state');
    render();
  } catch (e) { toast('load failed: ' + e.message, true); }
}

function render() {
  const st = S.status;

  // status strip
  const pill = $('mode-pill');
  pill.textContent = (st.run_mode === 'running' ? '● ' : st.run_mode === 'paused' ? '⏸ ' : '‼ ') + st.run_mode.toUpperCase();
  pill.className = 'pill ' + st.run_mode;
  $('gate-text').textContent = `gate ${st.gate_open ? 'OPEN' : 'closed'} · ${st.gate_reason || ''}`;
  $('btn-power').textContent = st.run_mode === 'running' ? '⏸ pause' : '▶ resume';

  // KPIs
  $('kpi-days').textContent = st.days_to_deadline;
  $('kpi-gate').textContent = `${st.qualified_since_gate}/${st.qualified_target} qualified · ${st.accepted_lifetime}/${st.accepted_target} accepted`;
  $('bar-qualified').style.width = Math.min(100, 100 * st.qualified_since_gate / st.qualified_target) + '%';
  $('bar-accepted').style.width  = Math.min(100, 100 * st.accepted_lifetime / st.accepted_target) + '%';
  $('kpi-streak').textContent = `🏆 first accepted bid wins · breaker: ${st.consecutive_critic_fails} critic fails, ${st.ticks_since_progress} ticks since progress`;
  $('kpi-spend').textContent = `$${st.day_dollars_spent} / $${st.day_soft_dollars} today`;
  $('bar-spend').style.width = Math.min(100, 100 * st.day_dollars_spent / st.day_hard_dollars) + '%';
  $('kpi-project').textContent = `project $${st.total_dollars_spent} of $${st.project_cap_dollars} cap`;
  $('kpi-queue').textContent = `${st.tasks_queued} queued · ${st.tasks_needs_approval} await you`;
  $('kpi-freshness').textContent = (S.warehouse_fresh ? '⛁ warehouse fresh' : '⚠ warehouse STALE — gate will close') + ` · as of ${new Date(S.served_at).toLocaleTimeString()}`;

  // approvals
  $('badge-pending').textContent = S.approvals_pending.length;
  $('approvals').innerHTML = S.approvals_pending.length === 0
    ? '<p class="dim small">nothing waiting on you 🎉</p>'
    : S.approvals_pending.map(a => `
      <div class="card">
        <span class="tier">TIER 2 · ${esc(a.action_kind)}</span>
        <b>${esc(a.summary)}</b>
        <div class="meta">${a.recommended ? '💡 ' + esc(a.recommended) + '<br>' : ''}${a.rollback_plan ? '↩ ' + esc(a.rollback_plan) : ''}
          <br>expires ${a.expires_at ? new Date(a.expires_at).toLocaleDateString() : '—'}</div>
        <div class="row">
          <button class="btn ok" onclick="openDecide(${a.approval_id})">✓ / ✎ / ✕ decide…</button>
        </div>
      </div>`).join('');
  $('decided').innerHTML = S.approvals_decided.map(a =>
    `<div class="task-line">[${esc(a.status)}] <b>${esc(a.action_kind)}</b> ${a.decision_note ? '— ' + esc(a.decision_note) : ''}</div>`).join('') || '<p class="small">none yet</p>';

  // events + tasks
  $('events').innerHTML = S.events.map(e => `
    <div class="event"><span class="dot sev-${esc(e.severity)}"></span>
      <span class="dim">${new Date(e.created_at).toLocaleTimeString()}</span>
      <span><b>${esc(e.actor)}</b> ${esc(e.event_type)}</span></div>`).join('');
  $('tasks').innerHTML = S.tasks.map(t =>
    `<div class="task-line">#${t.task_id} <b>${esc(t.title)}</b> · ${esc(t.status)} · ${esc(t.assigned_agent || '—')} · attempt ${t.attempts}/${t.max_attempts}</div>`).join('');

  // directives chips + inject-agent dropdown
  $('directives').innerHTML = S.directives.map(d => `
    <span class="chip">🎯 ${esc(d.body)}
      <button title="done" onclick="setDirective(${d.directive_id},'done')">✓</button>
      <button title="dismiss" onclick="setDirective(${d.directive_id},'dismissed')">✕</button></span>`).join('');
  $('inj-agent').innerHTML = S.agents.map(a => `<option value="${esc(a.agent_name)}">${esc(a.agent_name)}</option>`).join('');
}

/* ---------- actions ---------- */
function openDecide(id) {
  decideId = id;
  const a = S.approvals_pending.find(x => x.approval_id === id);
  if (!a) { toast(`approval #${id} no longer pending — refresh`, true); return; }
  $('dlg-decide-title').textContent = `Decide #${id} — ${a.action_kind}`;
  $('dlg-decide-summary').textContent = a.summary;
  $('decide-note').value = '';
  dlg('dlg-decide').showModal();
}
async function decide(decision) {
  if (decision === 'request_changes' && !$('decide-note').value.trim()) {
    toast('a note is required for request changes', true); return;
  }
  try {
    await api(`/api/approval/${decideId}/decide`, { decision, note: $('decide-note').value });
    dlg('dlg-decide').close();
    toast(`#${decideId}: ${decision.replace('_', ' ')} ✓`);
    await load();
  } catch (e) { toast(e.message, true); }
}

$('btn-power').onclick = () => {
  if (S.status.run_mode === 'running') dlg('dlg-power').showModal();
  else power('resume');
};
async function power(action) {
  try {
    const body = { action };
    if (action === 'pause') { body.reason = $('pause-reason').value; if ($('pause-until').value) body.until = $('pause-until').value; }
    const r = await api('/api/power', body);
    dlg('dlg-power').close();
    toast(`loop ${r.run_mode}` + (r.approvals_extended ? ` · ${r.approvals_extended} approval expiries extended` : ''));
    await load();
  } catch (e) { toast(e.message, true); }
}

$('btn-directive').onclick = async () => {
  const body = $('directive-input').value.trim();
  if (!body) return;
  try {
    await api('/api/directive', { kind: 'directive', body });
    $('directive-input').value = '';
    toast('directive sent — orchestrator reads it next tick');
    await load();
  } catch (e) { toast(e.message, true); }
};
async function setDirective(id, status) {
  try { await api(`/api/directive/${id}`, { status }); await load(); } catch (e) { toast(e.message, true); }
}

$('btn-inject').onclick = () => dlg('dlg-inject').showModal();
async function injectTask() {
  try {
    const dod = $('inj-dod').value.split('\n').map(s => s.trim()).filter(Boolean);
    const r = await api('/api/directive', {
      kind: 'task', type: $('inj-type').value, title: $('inj-title').value,
      priority: parseInt($('inj-priority').value, 10) || 50,
      assigned_agent: $('inj-agent').value, dod
    });
    dlg('dlg-inject').close();
    toast(`task #${r.task_id} queued`);
    await load();
  } catch (e) { toast(e.message, true); }
}

$('btn-config').onclick = () => {
  const c = S.config;
  $('config-fields').innerHTML = `
    <div><label>day soft $</label><input class="input" id="cf-soft" type="number" step="0.5" value="${c.budget.day_soft_dollars}"></div>
    <div><label>day hard $</label><input class="input" id="cf-hard" type="number" step="0.5" value="${c.budget.day_hard_dollars}"></div>
    <div><label>project cap $</label><input class="input" id="cf-cap" type="number" value="${c.budget.project_cap_dollars}"></div>
    <div><label>auto-execute max tier</label><input class="input" id="cf-tier" type="number" min="0" max="3" value="${c.rollout.auto_execute_max_tier}"></div>
    <div><label>dry_run</label><select class="input" id="cf-dry"><option ${c.rollout.dry_run ? 'selected' : ''}>true</option><option ${!c.rollout.dry_run ? 'selected' : ''}>false</option></select></div>
    <div><label>tier2_execution_enabled</label><select class="input" id="cf-t2"><option ${c.rollout.tier2_execution_enabled ? 'selected' : ''}>true</option><option ${!c.rollout.tier2_execution_enabled ? 'selected' : ''}>false</option></select></div>`;
  dlg('dlg-config').showModal();
};
async function saveConfig() {
  if (!confirm('These are the safety rails. Apply changes to control-config.json?')) return;
  try {
    const r = await api('/api/config', {
      budget: {
        day_soft_dollars: parseFloat($('cf-soft').value),
        day_hard_dollars: parseFloat($('cf-hard').value),
        project_cap_dollars: parseFloat($('cf-cap').value)
      },
      rollout: {
        dry_run: $('cf-dry').value === 'true',
        auto_execute_max_tier: parseInt($('cf-tier').value, 10),
        tier2_execution_enabled: $('cf-t2').value === 'true'
      }
    });
    dlg('dlg-config').close();
    toast('config applied · backup: ' + r.backup);
    await load();
  } catch (e) { toast(e.message, true); }
}

$('btn-refresh').onclick = load;
$('btn-tick').onclick = async () => {
  toast('running control tick…');
  try { const r = await api('/api/run/control-tick', {}); toast(r.tail.split('\n').pop()); await load(); }
  catch (e) { toast(e.message, true); }
};
$('btn-warehouse').onclick = async () => {
  toast('warehouse pull started (1–2 min, the deck will freeze — that is normal)…');
  try { const r = await api('/api/run/warehouse-daily', {}); toast(r.ok ? 'warehouse refreshed ✓' : 'warehouse FAILED: ' + r.tail, !r.ok); await load(); }
  catch (e) { toast(e.message, true); }
};

load();
