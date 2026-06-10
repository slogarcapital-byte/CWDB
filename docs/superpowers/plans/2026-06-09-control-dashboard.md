# CWDB Mission Control Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A laptop-only, dark-glassmorphic "Command Deck" dashboard where Jim reads loop state and writes decisions (approve/reject/request-changes, pause/resume, directives/task injection, budget+rollout dial) against the CWDB autonomous control plane.

**Architecture:** A single PowerShell `HttpListener` server bound to `127.0.0.1:7717` serves a static single-page UI and a small JSON API. The server dot-sources the existing `operations/control-plane/scripts/control-db.ps1` so every write reuses the loop's own tested helpers (no logic duplication). Pause/resume logic is extracted from `control-power.ps1` into shared functions both callers use. A small migration adds a `directive` table and `approval_queue.decision_note`.

**Tech Stack:** PowerShell 7 (`System.Net.HttpListener`), Supabase PostgREST (service-role key from `.env.local`), vanilla HTML/CSS/JS front-end (no build step, no frameworks).

**Spec:** `docs/superpowers/specs/2026-06-09-control-dashboard-design.md`

---

## File structure

```
operations/data-warehouse/schema/007_dashboard.sql        # NEW  migration: directive table + decision_note
operations/control-plane/scripts/control-db.ps1           # MOD  add Invoke-LoopPause/Invoke-LoopResume,
                                                          #      ConvertTo-UtcIsoFromCentral, Invoke-SupabasePatchReturning
operations/control-plane/scripts/control-power.ps1        # MOD  off/on branches call the shared functions
operations/control-plane/dashboard/dashboard-server.ps1   # NEW  HttpListener server + routing + -SelfTest
operations/control-plane/dashboard/start-dashboard.ps1    # NEW  launcher (starts server, opens browser)
operations/control-plane/dashboard/public/index.html      # NEW  Command Deck markup
operations/control-plane/dashboard/public/style.css       # NEW  dark glass design system
operations/control-plane/dashboard/public/app.js          # NEW  fetch/render/actions
operations/control-plane/dashboard/tests/test-writes.ps1  # NEW  synthetic-row write-path test
.claude/agents/cwdb-orchestrator-tick.md                  # MOD  step 2 reads active directives
```

Conventions to follow (from the existing scripts): `Set-StrictMode -Version Latest` in libraries, `$ErrorActionPreference='Stop'` in entrypoints, comment style matches `control-tick.ps1`, all times UTC ISO via `Get-UtcIso`, every human-visible state change writes an `event_log` row. There is no test framework in this repo — tests are plain PS scripts that `throw` on failure and print `PASS` lines (same spirit as `-SelfTest`).

**Execution notes for the engineer:**
- Run everything from the repo root: `C:\Users\jslog\OneDrive\Desktop\Slogars\CPA\Slogar-Capital\Claude\Projects\CWDB`.
- The Supabase project id is `iabiwsbmnbxmkjvkgfhg`. DDL (Task 1) must go through the Supabase MCP `apply_migration` tool (PostgREST cannot run DDL). All other DB access goes through the PS helpers.
- The control loop is LIVE. Tasks 2 and 13 touch live state (a brief pause/resume cycle and a real approval decision). Both are designed to be safe; do them exactly as written and do not improvise extra writes.
- Commit after every task with the exact message given.

---

### Task 1: Migration 007 — `directive` table + `approval_queue.decision_note`

**Files:**
- Create: `operations/data-warehouse/schema/007_dashboard.sql`

- [ ] **Step 1: Write the migration file**

```sql
-- =============================================================
-- 007_dashboard.sql - dashboard write surfaces.
--   directive: standing human guidance the orchestrator reads each tick (step 2).
--   approval_queue.decision_note: Jim's free-text note on approve/reject/request-changes.
-- Idempotent: IF NOT EXISTS guards throughout.
-- =============================================================

CREATE TABLE IF NOT EXISTS directive (
    directive_id  bigserial PRIMARY KEY,
    body          text NOT NULL,
    status        text NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active','done','dismissed')),
    created_by    text NOT NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_directive_active ON directive (created_at) WHERE status = 'active';

ALTER TABLE approval_queue ADD COLUMN IF NOT EXISTS decision_note text;
```

- [ ] **Step 2: Apply it**

Use the Supabase MCP tool `apply_migration` with `project_id` `iabiwsbmnbxmkjvkgfhg`, `name` `007_dashboard`, and the file's SQL as `query`.

- [ ] **Step 3: Verify**

Run via Supabase MCP `execute_sql` (project `iabiwsbmnbxmkjvkgfhg`):

```sql
SELECT column_name FROM information_schema.columns WHERE table_name='directive' ORDER BY ordinal_position;
SELECT column_name FROM information_schema.columns WHERE table_name='approval_queue' AND column_name='decision_note';
```

Expected: directive columns `directive_id, body, status, created_by, created_at, updated_at`; one row `decision_note`.

- [ ] **Step 4: Commit**

```bash
git add operations/data-warehouse/schema/007_dashboard.sql
git commit -m "Add migration 007: directive table + approval_queue.decision_note"
```

---

### Task 2: Extract shared pause/resume into `control-db.ps1`

**Files:**
- Modify: `operations/control-plane/scripts/control-db.ps1` (append before the `# ---- daily digest` section, around line 175)
- Modify: `operations/control-plane/scripts/control-power.ps1` (replace the bodies of the `'off'` and `'on'` switch branches and delete its local `ConvertTo-UtcIsoFromCentral`)

- [ ] **Step 1: Add the shared functions to `control-db.ps1`**

Insert this block immediately before the `# ---- daily digest ---` comment line:

```powershell
# ---- central-time parsing ---------------------------------------------------
function ConvertTo-UtcIsoFromCentral {
    <# .SYNOPSIS  "2026-06-15" (-> 06:00 CT) or any datetime text, Central -> UTC ISO. #>
    [CmdletBinding()] param([Parameter(Mandatory)][string] $Text)
    $tz = [System.TimeZoneInfo]::FindSystemTimeZoneById("Central Standard Time")
    $parsed = [DateTime]::Parse($Text, [System.Globalization.CultureInfo]::InvariantCulture)
    if ($parsed.TimeOfDay.TotalSeconds -eq 0 -and $Text -notmatch '[:T]') {
        $parsed = $parsed.Date.AddHours(6)
    }
    $utc = [System.TimeZoneInfo]::ConvertTimeToUtc([DateTime]::SpecifyKind($parsed, 'Unspecified'), $tz)
    return $utc.ToString("o")
}

# ---- pause / resume (single implementation: control-power.ps1 + dashboard) --
function Invoke-LoopPause {
    <# .SYNOPSIS  Pause the loop: mode+reason+optional until, close gate, event row. #>
    [CmdletBinding()]
    param([string] $Reason, [string] $UntilUtcIso, [Parameter(Mandatory)][string] $By)
    $set = @{
        run_mode      = 'paused'
        paused_at     = (Get-UtcIso)
        paused_by     = $By
        paused_reason = $(if ($Reason) { $Reason } else { $null })
        gate_open     = $false
        gate_reason   = 'paused_by_human'
    }
    if ($UntilUtcIso) { $set["resume_at"] = $UntilUtcIso }
    Set-ControlState -Set $set
    Write-ControlEvent -Actor 'human' -EventType 'paused' -Severity 'info' -Detail @{
        paused_by = $By; reason = $Reason; resume_at = $set["resume_at"]
    }
}

function Invoke-LoopResume {
    <# .SYNOPSIS  Resume: clear pause/halt, re-anchor breakers, extend pending approval
                  expiries by the pause duration. Returns @{pause_seconds; approvals_extended}. #>
    [CmdletBinding()] param([Parameter(Mandatory)][string] $By)
    $state = Get-ControlState
    $pauseSeconds = 0
    if ($state.paused_at) {
        $pausedAt = [DateTime]::Parse($state.paused_at, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
        $pauseSeconds = [int]([DateTime]::UtcNow - $pausedAt.ToUniversalTime()).TotalSeconds
    }
    Set-ControlState -Set @{
        run_mode                 = 'running'
        paused_at                = $null
        paused_by                = $null
        paused_reason            = $null
        resume_at                = $null
        halted_reason            = $null
        gate_reason              = 'resumed_awaiting_next_control_tick'
        consecutive_critic_fails = 0
        ticks_since_progress     = 0
        last_progress_at         = (Get-UtcIso)
    }
    $pushed = 0
    if ($pauseSeconds -gt 0) {
        $pending = Invoke-SupabaseSelect -Table "approval_queue" -Select "approval_id,expires_at" -Filter "status=eq.pending"
        foreach ($a in @($pending)) {
            if ($a.expires_at) {
                $exp = [DateTime]::Parse($a.expires_at, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
                $newExp = $exp.ToUniversalTime().AddSeconds($pauseSeconds).ToString("o")
                Invoke-SupabasePatch -Table "approval_queue" -Filter "approval_id=eq.$($a.approval_id)" -Set @{ expires_at = $newExp; updated_at = (Get-UtcIso) }
                $pushed++
            }
        }
    }
    Write-ControlEvent -Actor 'human' -EventType 'resumed' -Severity 'info' -Detail @{
        resumed_by = $By; pause_seconds = $pauseSeconds; approvals_extended = $pushed
        note = 'breaker windows re-anchored; first orchestrator tick will re-baseline the funnel'
    }
    return @{ pause_seconds = $pauseSeconds; approvals_extended = $pushed }
}
```

- [ ] **Step 2: Refactor `control-power.ps1` to call them**

Delete the local `function ConvertTo-UtcIsoFromCentral { ... }` block (lines ~45-55). Replace the `'off'` branch body with:

```powershell
    'off' {
        $state = Get-ControlState
        if ($state.run_mode -eq 'paused') { Write-Host "Already paused (since $($state.paused_at))."; Show-Status; break }

        $untilIso = $(if ($Until) { ConvertTo-UtcIsoFromCentral $Until } else { $null })
        Invoke-LoopPause -Reason $Reason -UntilUtcIso $untilIso -By $who
        Write-Host ""
        Write-Host "  Control loop PAUSED. No reasoning ticks, no model spend until you turn it back on."
        if ($Until) { Write-Host "  Auto-resume scheduled for $Until (Central)." }
        Write-Host "  Resume any time with:  pwsh `"$PSCommandPath`" on"
        Write-Host ""
    }
```

Replace the `'on'` branch body with:

```powershell
    'on' {
        $state = Get-ControlState
        if ($state.run_mode -eq 'running') { Write-Host "Already running."; Show-Status; break }

        $r = Invoke-LoopResume -By $who
        Write-Host ""
        Write-Host ("  Control loop RESUMED (was off ~{0:n1}h). Picks up the next queued task." -f ($r.pause_seconds / 3600.0))
        if ($r.approvals_extended -gt 0) { Write-Host ("  Extended {0} pending approval expiry(ies) by the pause duration." -f $r.approvals_extended) }
        Write-Host "  The next control tick (<=30 min) opens the gate. Run it now with:"
        Write-Host ("    pwsh `"{0}`"" -f (Join-Path $PSScriptRoot 'control-tick.ps1'))
        Write-Host ""
    }
```

- [ ] **Step 3: Verify with a live pause/resume cycle**

The loop is live; this cycle is safe (resume restores everything, and the approval-expiry extension is the *correct* behavior, not a side effect). Run:

```powershell
pwsh operations/control-plane/scripts/control-power.ps1 status     # expect RUNNING
pwsh operations/control-plane/scripts/control-power.ps1 off -Reason "task-2 refactor verification"
pwsh operations/control-plane/scripts/control-power.ps1 status     # expect PAUSED with that reason
pwsh operations/control-plane/scripts/control-power.ps1 on
pwsh operations/control-plane/scripts/control-power.ps1 status     # expect RUNNING, gate_reason=resumed_awaiting_next_control_tick
pwsh operations/control-plane/scripts/control-tick.ps1             # reopen the gate now rather than waiting 30 min
```

Expected final line: `control-tick: gate_open=True reason=open ...` (if it says `stale_warehouse_data`, run `pwsh operations/data-warehouse/scripts/run-daily.ps1` first).

- [ ] **Step 4: Commit**

```bash
git add operations/control-plane/scripts/control-db.ps1 operations/control-plane/scripts/control-power.ps1
git commit -m "Extract shared Invoke-LoopPause/Invoke-LoopResume into control-db.ps1"
```

---

### Task 3: Conditional-write helper `Invoke-SupabasePatchReturning`

This is the optimistic-lock primitive: PATCH with `Prefer: return=representation` returns the rows actually updated, so `approval_id=eq.N&status=eq.pending` updating 0 rows = lost race = HTTP 409 to the UI.

**Files:**
- Modify: `operations/control-plane/scripts/control-db.ps1` (append after `Invoke-SupabaseInsert`)
- Create: `operations/control-plane/dashboard/tests/test-writes.ps1`

- [ ] **Step 1: Write the failing test**

Create `operations/control-plane/dashboard/tests/test-writes.ps1`:

```powershell
<# Write-path tests against SYNTHETIC rows only. Throws on failure; prints PASS lines. #>
[CmdletBinding()] param()
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot "..\..\scripts\control-db.ps1")
Initialize-ControlDb

function Assert([bool]$Cond, [string]$Msg) {
    if (-not $Cond) { throw "FAIL: $Msg" }
    Write-Host "PASS: $Msg"
}

# --- Invoke-SupabasePatchReturning: updates matching row, returns it; 0 rows on no match ---
$uid = New-Uid
Invoke-SupabaseInsert -Table "approval_queue" -Records @(@{
    action_kind = 'dashboard-selftest'; summary = "patch-returning test $uid"
    proposed_action = @{ test = $true }; status = 'pending'
})
$row = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "approval_id,status" -Filter "summary=eq.patch-returning test $uid")[0]
Assert ($null -ne $row) "synthetic approval row inserted"

$updated = @(Invoke-SupabasePatchReturning -Table "approval_queue" `
    -Filter "approval_id=eq.$($row.approval_id)&status=eq.pending" `
    -Set @{ status = 'approved'; decided_by = 'test'; decision_note = 'note' })
Assert ($updated.Count -eq 1) "conditional patch updated exactly 1 row"
Assert ($updated[0].status -eq 'approved') "returned representation has new status"
Assert ($updated[0].decision_note -eq 'note') "decision_note column writable"

$second = @(Invoke-SupabasePatchReturning -Table "approval_queue" `
    -Filter "approval_id=eq.$($row.approval_id)&status=eq.pending" `
    -Set @{ status = 'rejected' })
Assert ($second.Count -eq 0) "lost race returns 0 rows (status no longer pending)"

# cleanup
Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/approval_queue?approval_id=eq.$($row.approval_id)" `
    -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
Write-Host "PASS: cleanup"
Write-Host "`nALL WRITE-PATH TESTS PASSED"
```

- [ ] **Step 2: Run it to verify it fails**

Run: `pwsh operations/control-plane/dashboard/tests/test-writes.ps1`
Expected: error containing `Invoke-SupabasePatchReturning` is not recognized.

- [ ] **Step 3: Implement the helper in `control-db.ps1`**

Append after the closing brace of `Invoke-SupabaseInsert`:

```powershell
function Invoke-SupabasePatchReturning {
    <#
    .SYNOPSIS  PATCH with Prefer: return=representation. Returns the array of rows actually
               updated - the optimistic-lock primitive (0 rows = the WHERE no longer matched).
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Table,
        [Parameter(Mandatory)][string] $Filter,
        [Parameter(Mandatory)][hashtable] $Set
    )
    $url  = "$($Script:SupabaseUrl)/rest/v1/$Table" + "?$Filter"
    $body = $Set | ConvertTo-Json -Depth 32 -Compress
    $headers = @{
        "apikey"        = $Script:SupabaseKey
        "Authorization" = "Bearer $($Script:SupabaseKey)"
        "Content-Type"  = "application/json"
        "Prefer"        = "return=representation"
    }
    try {
        $resp = Invoke-RestMethod -Method Patch -Uri $url -Headers $headers -Body $body -ErrorAction Stop
        if ($null -eq $resp) { return @() }
        return @($resp)
    } catch {
        $errBody = ""
        try {
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $errBody = $reader.ReadToEnd()
            }
        } catch { }
        throw "PATCH(returning) $Table ($Filter) failed: $($_.Exception.Message)`n$errBody"
    }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `pwsh operations/control-plane/dashboard/tests/test-writes.ps1`
Expected: 6 `PASS:` lines then `ALL WRITE-PATH TESTS PASSED`.

- [ ] **Step 5: Commit**

```bash
git add operations/control-plane/scripts/control-db.ps1 operations/control-plane/dashboard/tests/test-writes.ps1
git commit -m "Add Invoke-SupabasePatchReturning (optimistic-lock primitive) + write-path test"
```

---

### Task 4: Server skeleton — static files, `/api/state`, `-SelfTest`

**Files:**
- Create: `operations/control-plane/dashboard/dashboard-server.ps1`
- Create: `operations/control-plane/dashboard/public/index.html` (placeholder shell; real UI in Task 10)

- [ ] **Step 1: Create a minimal `public/index.html` so static serving is testable**

```html
<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><title>CWDB Mission Control</title>
<link rel="stylesheet" href="/style.css"></head>
<body><div id="app">loading…</div><script src="/app.js"></script></body></html>
```

- [ ] **Step 2: Write `dashboard-server.ps1`**

```powershell
<#
.SYNOPSIS
    CWDB Mission Control dashboard server. Local-only (binds 127.0.0.1).

.DESCRIPTION
    Serves the static Command Deck UI from ./public and a JSON API that reuses the
    control-plane helpers (control-db.ps1). The dashboard NEVER executes proposals -
    it only flips approval status and writes the same control rows the PS scripts do.

      GET  /api/state                 one bundle: status, approvals, tasks, events, budget,
                                      gate, funnel, cac, directives, config, freshness
      POST /api/approval/{id}/decide  {decision: approve|reject|request_changes, note}
      POST /api/power                 {action: pause|resume, reason?, until?}   (until = Central time text)
      POST /api/directive             {kind: directive, body} | {kind: task, type, title, priority, assigned_agent, dod[]}
      POST /api/directive/{id}        {status: done|dismissed}
      GET  /api/config                current control-config.json
      POST /api/config                partial: {budget:{...}, rollout:{...}} - allowlisted keys only
      POST /api/run/{script}          script in {control-tick, warehouse-daily}

.NOTES
    pwsh dashboard-server.ps1            # serve until Ctrl+C
    pwsh dashboard-server.ps1 -SelfTest  # spawn child server, probe GET endpoints, exit non-zero on failure
#>
[CmdletBinding()]
param([int] $Port = 7717, [switch] $SelfTest)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot "..\scripts\control-db.ps1")

# ---------- self-test: spawn a child server, probe, kill ----------
if ($SelfTest) {
    $child = Start-Process pwsh -ArgumentList @('-NoProfile','-File', $PSCommandPath, '-Port', "$Port") -PassThru -WindowStyle Hidden
    try {
        $ok = $false
        foreach ($i in 1..20) {
            Start-Sleep -Milliseconds 500
            try { Invoke-RestMethod "http://127.0.0.1:$Port/api/state" -TimeoutSec 5 | Out-Null; $ok = $true; break } catch { }
        }
        if (-not $ok) { throw "server did not come up on port $Port" }

        $state = Invoke-RestMethod "http://127.0.0.1:$Port/api/state"
        foreach ($key in 'status','approvals_pending','approvals_decided','tasks','events','validation_gate','funnel','cac','directives','config','warehouse_fresh') {
            if ($null -eq $state.PSObject.Properties[$key]) { throw "/api/state missing key: $key" }
            Write-Host "PASS: /api/state has $key"
        }
        $cfg = Invoke-RestMethod "http://127.0.0.1:$Port/api/config"
        if ($null -eq $cfg.budget.day_soft_dollars) { throw "/api/config missing budget.day_soft_dollars" }
        Write-Host "PASS: /api/config returns budget"
        $html = Invoke-WebRequest "http://127.0.0.1:$Port/" -UseBasicParsing
        if ($html.Content -notmatch 'CWDB Mission Control') { throw "static index.html not served" }
        Write-Host "PASS: static index served"
        Write-Host "`nSELF-TEST PASSED"
        exit 0
    } finally {
        Stop-Process -Id $child.Id -Force -ErrorAction SilentlyContinue
    }
}

# ---------- real server ----------
Initialize-ControlDb
$publicDir = Join-Path $PSScriptRoot "public"
$repo      = Get-ControlRepoRoot

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()
Write-Host "CWDB Mission Control: http://127.0.0.1:$Port/   (Ctrl+C to stop)"

function Send-Json {
    param($Ctx, $Obj, [int] $Code = 200)
    $json = $Obj | ConvertTo-Json -Depth 24
    $buf  = [System.Text.Encoding]::UTF8.GetBytes($json)
    $Ctx.Response.StatusCode      = $Code
    $Ctx.Response.ContentType     = 'application/json; charset=utf-8'
    $Ctx.Response.ContentLength64 = $buf.Length
    $Ctx.Response.OutputStream.Write($buf, 0, $buf.Length)
    $Ctx.Response.Close()
}

function Read-Body {
    param($Ctx)
    $reader = New-Object System.IO.StreamReader($Ctx.Request.InputStream, [System.Text.Encoding]::UTF8)
    $text = $reader.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    return $text | ConvertFrom-Json
}

function Send-Static {
    param($Ctx, [string] $RelPath)
    $file = Join-Path $publicDir $RelPath
    if (-not (Test-Path $file)) { Send-Json $Ctx @{ error = "not found" } 404; return }
    $ext  = [System.IO.Path]::GetExtension($file)
    $mime = switch ($ext) { '.html' {'text/html'} '.css' {'text/css'} '.js' {'application/javascript'} default {'application/octet-stream'} }
    $buf  = [System.IO.File]::ReadAllBytes($file)
    $Ctx.Response.ContentType     = "$mime; charset=utf-8"
    $Ctx.Response.ContentLength64 = $buf.Length
    $Ctx.Response.OutputStream.Write($buf, 0, $buf.Length)
    $Ctx.Response.Close()
}

function Get-StateBundle {
    $status   = @(Invoke-SupabaseSelect -Table "v_control_status" -Select "*")[0]
    $pending  = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "*" -Filter "status=eq.pending&order=created_at.asc")
    $decided  = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "*" -Filter "status=neq.pending&order=updated_at.desc&limit=20")
    $tasks    = @(Invoke-SupabaseSelect -Table "task" -Select "task_id,type,title,status,priority,assigned_agent,permission_tier,attempts,max_attempts,updated_at" -Filter "order=priority.asc,created_at.asc&limit=50")
    $events   = @(Invoke-SupabaseSelect -Table "event_log" -Select "event_id,actor,event_type,severity,detail,created_at" -Filter "order=created_at.desc&limit=50")
    $gate     = @(Invoke-SupabaseSelect -Table "v_validation_gate" -Select "*")[0]
    $funnel   = @(Invoke-SupabaseSelect -Table "v_lead_funnel" -Select "*" -Filter "order=month.desc&limit=3")
    $cac      = @(Invoke-SupabaseSelect -Table "v_cac_by_channel" -Select "*")
    $dirs     = @(Invoke-SupabaseSelect -Table "directive" -Select "*" -Filter "status=eq.active&order=created_at.asc")
    $agents   = @(Invoke-SupabaseSelect -Table "agent_registry" -Select "agent_name,task_types,is_active" -Filter "is_active=eq.true")
    return @{
        status            = $status
        approvals_pending = $pending
        approvals_decided = $decided
        tasks             = $tasks
        events            = $events
        validation_gate   = $gate
        funnel            = $funnel
        cac               = $cac
        directives        = $dirs
        agents            = $agents
        config            = (Get-ControlConfig)
        warehouse_fresh   = (Test-WarehouseFresh)
        served_at         = (Get-UtcIso)
    }
}

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
        $path   = $ctx.Request.Url.AbsolutePath
        $method = $ctx.Request.HttpMethod

        if ($method -eq 'GET' -and $path -eq '/')            { Send-Static $ctx 'index.html'; continue }
        if ($method -eq 'GET' -and $path -in '/style.css','/app.js','/index.html') { Send-Static $ctx $path.TrimStart('/'); continue }
        if ($method -eq 'GET' -and $path -eq '/api/state')   { Send-Json $ctx (Get-StateBundle); continue }
        if ($method -eq 'GET' -and $path -eq '/api/config')  { Send-Json $ctx (Get-ControlConfig); continue }

        # POST routes are added in Tasks 5-9 between this comment and the 404.

        Send-Json $ctx @{ error = "no route: $method $path" } 404
    } catch {
        try { Send-Json $ctx @{ error = "$($_.Exception.Message)" } 500 } catch { }
    }
}
```

- [ ] **Step 3: Run the self-test to verify it fails on the missing UI files, then passes on API**

Run: `pwsh operations/control-plane/dashboard/dashboard-server.ps1 -SelfTest`
Expected: `PASS: /api/state has ...` for each key, `PASS: /api/config returns budget`, `PASS: static index served`, `SELF-TEST PASSED`, exit code 0. (`/style.css` and `/app.js` will 404 in the browser until Task 10 — the self-test doesn't probe them yet.)

- [ ] **Step 4: Commit**

```bash
git add operations/control-plane/dashboard/dashboard-server.ps1 operations/control-plane/dashboard/public/index.html
git commit -m "Add dashboard server skeleton: static serving + /api/state + -SelfTest"
```

---

### Task 5: `POST /api/approval/{id}/decide`

**Files:**
- Modify: `operations/control-plane/dashboard/dashboard-server.ps1` (add route + handler)
- Modify: `operations/control-plane/dashboard/tests/test-writes.ps1` (add endpoint test)

- [ ] **Step 1: Extend the write-path test (failing first)**

Append to `tests/test-writes.ps1` before the final `Write-Host`:

```powershell
# --- /api/approval/{id}/decide end-to-end (needs server running on 7717) ---
# Insert synthetic pending approval + a synthetic queued task it points at.
$tuid = New-Uid
Invoke-SupabaseInsert -Table "task" -Records @(@{
    type = 'dashboard.selftest'; title = "decide-test task $tuid"; status = 'needs_approval'
    priority = 999; trace_id = 'dashboard-selftest'; payload = @{ dod = @('selftest') }
})
$task = @(Invoke-SupabaseSelect -Table "task" -Select "task_id,status,payload" -Filter "title=eq.decide-test task $tuid")[0]
Invoke-SupabaseInsert -Table "approval_queue" -Records @(@{
    action_kind = 'dashboard-selftest'; summary = "decide test $tuid"; task_id = $task.task_id
    proposed_action = @{ test = $true }; status = 'pending'
})
$appr = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "approval_id" -Filter "summary=eq.decide test $tuid")[0]

# request_changes -> approval rejected + task requeued with feedback
$resp = Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/approval/$($appr.approval_id)/decide" `
    -ContentType 'application/json' -Body (@{ decision = 'request_changes'; note = 'tighten the DoD' } | ConvertTo-Json)
Assert ($resp.ok -eq $true) "decide endpoint returned ok"
$apprAfter = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "status,decision_note,decided_by" -Filter "approval_id=eq.$($appr.approval_id)")[0]
Assert ($apprAfter.status -eq 'rejected') "request_changes sets approval status=rejected"
Assert ($apprAfter.decision_note -eq 'tighten the DoD') "note persisted"
Assert ($apprAfter.decided_by -eq 'jim-dashboard') "decided_by stamped"
$taskAfter = @(Invoke-SupabaseSelect -Table "task" -Select "status,payload" -Filter "task_id=eq.$($task.task_id)")[0]
Assert ($taskAfter.status -eq 'queued') "request_changes requeues the task"
Assert ("$($taskAfter.payload.feedback)" -match 'tighten the DoD') "note appended to payload.feedback"

# deciding again -> 409 (already decided)
$conflict = $false
try {
    Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/approval/$($appr.approval_id)/decide" `
        -ContentType 'application/json' -Body (@{ decision = 'approve' } | ConvertTo-Json)
} catch { if ($_.Exception.Response.StatusCode.value__ -eq 409) { $conflict = $true } }
Assert $conflict "second decision returns 409"

# cleanup (task cascade-deletes the approval row via FK)
Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/task?task_id=eq.$($task.task_id)" `
    -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
Write-Host "PASS: decide cleanup"
```

- [ ] **Step 2: Run to verify the new section fails**

Start the server in one terminal: `pwsh operations/control-plane/dashboard/dashboard-server.ps1`
Run in another: `pwsh operations/control-plane/dashboard/tests/test-writes.ps1`
Expected: earlier PASSes, then a 404 error from the decide call (`no route`).

- [ ] **Step 3: Implement the route**

In `dashboard-server.ps1`, replace the `# POST routes are added in Tasks 5-9...` comment with:

```powershell
        if ($method -eq 'POST' -and $path -match '^/api/approval/(\d+)/decide$') {
            $id   = [long]$Matches[1]
            $body = Read-Body $ctx
            $decision = "$($body.decision)"
            $note     = "$($body.note)"
            if ($decision -notin 'approve','reject','request_changes') { Send-Json $ctx @{ error = "bad decision: $decision" } 400; continue }

            $newStatus = $(if ($decision -eq 'approve') { 'approved' } else { 'rejected' })
            $set = @{ status = $newStatus; decided_by = 'jim-dashboard'; decided_at = (Get-UtcIso); updated_at = (Get-UtcIso) }
            if ($note) { $set["decision_note"] = $note }

            # optimistic lock: only flips if still pending
            $rows = Invoke-SupabasePatchReturning -Table "approval_queue" -Filter "approval_id=eq.$id&status=eq.pending" -Set $set
            if ($rows.Count -eq 0) { Send-Json $ctx @{ error = "already decided or expired" } 409; continue }
            $appr = $rows[0]

            # linked-task consequence (same mechanics the critic uses)
            if ($appr.task_id) {
                if ($decision -eq 'reject') {
                    Invoke-SupabasePatch -Table "task" -Filter "task_id=eq.$($appr.task_id)" -Set @{ status = 'failed'; updated_at = (Get-UtcIso) }
                } elseif ($decision -eq 'request_changes') {
                    $t = @(Invoke-SupabaseSelect -Table "task" -Select "payload" -Filter "task_id=eq.$($appr.task_id)")[0]
                    $payload = $t.payload
                    $fb = @()
                    if ($payload.PSObject.Properties['feedback']) { $fb = @($payload.feedback) }
                    $fb += "[jim-dashboard $(Get-UtcIso)] $note"
                    $payload | Add-Member -NotePropertyName feedback -NotePropertyValue $fb -Force
                    Invoke-SupabasePatch -Table "task" -Filter "task_id=eq.$($appr.task_id)" -Set @{ status = 'queued'; payload = $payload; updated_at = (Get-UtcIso) }
                }
            }
            Write-ControlEvent -Actor 'human' -EventType 'approval_decided' -Severity 'info' -TaskId $appr.task_id -Detail @{
                approval_id = $id; decision = $decision; note = $note; via = 'dashboard'
            }
            Send-Json $ctx @{ ok = $true; approval_id = $id; status = $newStatus }
            continue
        }
```

- [ ] **Step 4: Restart the server, run the test to verify it passes**

Restart server, run: `pwsh operations/control-plane/dashboard/tests/test-writes.ps1`
Expected: all PASS lines including `request_changes requeues the task` and `second decision returns 409`, then `ALL WRITE-PATH TESTS PASSED`.

- [ ] **Step 5: Commit**

```bash
git add operations/control-plane/dashboard/dashboard-server.ps1 operations/control-plane/dashboard/tests/test-writes.ps1
git commit -m "Add POST /api/approval/{id}/decide with optimistic lock + feedback requeue"
```

---

### Task 6: `POST /api/power`

**Files:**
- Modify: `operations/control-plane/dashboard/dashboard-server.ps1`

- [ ] **Step 1: Add the route** (directly below the decide route)

```powershell
        if ($method -eq 'POST' -and $path -eq '/api/power') {
            $body = Read-Body $ctx
            switch ("$($body.action)") {
                'pause' {
                    $untilIso = $(if ($body.until) { ConvertTo-UtcIsoFromCentral "$($body.until)" } else { $null })
                    Invoke-LoopPause -Reason "$($body.reason)" -UntilUtcIso $untilIso -By 'jim-dashboard'
                    Send-Json $ctx @{ ok = $true; run_mode = 'paused' }
                }
                'resume' {
                    $r = Invoke-LoopResume -By 'jim-dashboard'
                    Send-Json $ctx @{ ok = $true; run_mode = 'running'; pause_seconds = $r.pause_seconds; approvals_extended = $r.approvals_extended }
                }
                default { Send-Json $ctx @{ error = "bad action: $($body.action)" } 400 }
            }
            continue
        }
```

- [ ] **Step 2: Verify with curl against the live loop (pause then resume)**

```powershell
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:7717/api/power -ContentType 'application/json' -Body '{"action":"pause","reason":"task-6 endpoint test"}'
pwsh operations/control-plane/scripts/control-power.ps1 status    # expect PAUSED, reason "task-6 endpoint test"
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:7717/api/power -ContentType 'application/json' -Body '{"action":"resume"}'
pwsh operations/control-plane/scripts/control-power.ps1 status    # expect RUNNING
pwsh operations/control-plane/scripts/control-tick.ps1            # reopen gate
```

Expected: status flips paused -> running; final tick prints `gate_open=True`.

- [ ] **Step 3: Commit**

```bash
git add operations/control-plane/dashboard/dashboard-server.ps1
git commit -m "Add POST /api/power (pause/resume via shared loop functions)"
```

---

### Task 7: `POST /api/directive` (+ status update)

**Files:**
- Modify: `operations/control-plane/dashboard/dashboard-server.ps1`
- Modify: `operations/control-plane/dashboard/tests/test-writes.ps1`

- [ ] **Step 1: Extend the test (failing first)** — append before the final `Write-Host`:

```powershell
# --- /api/directive: directive insert, task injection, status update ---
$d = Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive" -ContentType 'application/json' `
    -Body (@{ kind = 'directive'; body = "selftest directive $tuid" } | ConvertTo-Json)
Assert ($d.ok -eq $true -and $d.directive_id -gt 0) "directive inserted"
$drow = @(Invoke-SupabaseSelect -Table "directive" -Select "*" -Filter "directive_id=eq.$($d.directive_id)")[0]
Assert ($drow.status -eq 'active' -and $drow.created_by -eq 'jim-dashboard') "directive row correct"

$inj = Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive" -ContentType 'application/json' `
    -Body (@{ kind = 'task'; type = 'dashboard.selftest'; title = "injected task $tuid"; priority = 999; assigned_agent = 'lead-routing'; dod = @('a','b') } | ConvertTo-Json)
Assert ($inj.ok -eq $true -and $inj.task_id -gt 0) "task injected"
$trow = @(Invoke-SupabaseSelect -Table "task" -Select "status,priority,assigned_agent,payload,trace_id" -Filter "task_id=eq.$($inj.task_id)")[0]
Assert ($trow.status -eq 'queued' -and $trow.trace_id -eq 'dashboard') "injected task queued with trace_id=dashboard"
Assert (@($trow.payload.dod).Count -eq 2) "DoD lines in payload"

$upd = Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive/$($d.directive_id)" -ContentType 'application/json' `
    -Body (@{ status = 'dismissed' } | ConvertTo-Json)
Assert ($upd.ok -eq $true) "directive status update ok"
$drow2 = @(Invoke-SupabaseSelect -Table "directive" -Select "status" -Filter "directive_id=eq.$($d.directive_id)")[0]
Assert ($drow2.status -eq 'dismissed') "directive dismissed"

# cleanup
Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/directive?directive_id=eq.$($d.directive_id)" `
    -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/task?task_id=eq.$($inj.task_id)" `
    -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
Write-Host "PASS: directive cleanup"
```

- [ ] **Step 2: Run to verify the new section 404s**, then **implement the routes**:

```powershell
        if ($method -eq 'POST' -and $path -eq '/api/directive') {
            $body = Read-Body $ctx
            switch ("$($body.kind)") {
                'directive' {
                    if ([string]::IsNullOrWhiteSpace("$($body.body)")) { Send-Json $ctx @{ error = "empty directive body" } 400; continue }
                    Invoke-SupabaseInsert -Table "directive" -Records @(@{ body = "$($body.body)"; created_by = 'jim-dashboard' })
                    $row = @(Invoke-SupabaseSelect -Table "directive" -Select "directive_id" -Filter "body=eq.$([uri]::EscapeDataString("$($body.body)"))&order=directive_id.desc&limit=1")[0]
                    Write-ControlEvent -Actor 'human' -EventType 'directive_added' -Severity 'info' -Detail @{ directive_id = $row.directive_id; body = "$($body.body)"; via = 'dashboard' }
                    Send-Json $ctx @{ ok = $true; directive_id = $row.directive_id }
                }
                'task' {
                    $obj = @(Invoke-SupabaseSelect -Table "objective" -Select "objective_id" -Filter "status=eq.open&order=priority.asc&limit=1")
                    $rec = @{
                        type           = "$($body.type)"
                        title          = "$($body.title)"
                        status         = 'queued'
                        priority       = [int]$body.priority
                        assigned_agent = "$($body.assigned_agent)"
                        permission_tier = $(if ($body.permission_tier) { [int]$body.permission_tier } else { 2 })
                        payload        = @{ dod = @($body.dod); inputs = @{} }
                        trace_id       = 'dashboard'
                    }
                    if ($obj.Count -gt 0) { $rec["objective_id"] = $obj[0].objective_id }
                    Invoke-SupabaseInsert -Table "task" -Records @($rec)
                    $row = @(Invoke-SupabaseSelect -Table "task" -Select "task_id" -Filter "title=eq.$([uri]::EscapeDataString("$($body.title)"))&order=task_id.desc&limit=1")[0]
                    Write-ControlEvent -Actor 'human' -EventType 'task_injected' -Severity 'info' -TaskId $row.task_id -Detail @{ title = "$($body.title)"; agent = "$($body.assigned_agent)"; via = 'dashboard' }
                    Send-Json $ctx @{ ok = $true; task_id = $row.task_id }
                }
                default { Send-Json $ctx @{ error = "bad kind: $($body.kind)" } 400 }
            }
            continue
        }
        if ($method -eq 'POST' -and $path -match '^/api/directive/(\d+)$') {
            $id = [long]$Matches[1]
            $body = Read-Body $ctx
            if ("$($body.status)" -notin 'done','dismissed') { Send-Json $ctx @{ error = "bad status" } 400; continue }
            Invoke-SupabasePatch -Table "directive" -Filter "directive_id=eq.$id" -Set @{ status = "$($body.status)"; updated_at = (Get-UtcIso) }
            Send-Json $ctx @{ ok = $true }
            continue
        }
```

- [ ] **Step 3: Restart server, run test — expect all PASS.** Then **commit**:

```bash
git add operations/control-plane/dashboard/dashboard-server.ps1 operations/control-plane/dashboard/tests/test-writes.ps1
git commit -m "Add POST /api/directive (directives + task injection + status update)"
```

---

### Task 8: `POST /api/config` (budget + rollout dial)

**Files:**
- Modify: `operations/control-plane/dashboard/dashboard-server.ps1`

- [ ] **Step 1: Add the route** (below the directive routes). Allowlisted keys only; timestamped backup; round-trip validation; event row with the diff:

```powershell
        if ($method -eq 'POST' -and $path -eq '/api/config') {
            $body = Read-Body $ctx
            $cfgPath = Join-Path $repo "operations\control-plane\config\control-config.json"
            $raw  = Get-Content $cfgPath -Raw
            $cfg  = $raw | ConvertFrom-Json
            $allowedBudget  = 'day_soft_dollars','day_hard_dollars','project_cap_dollars','day_soft_tokens','day_hard_tokens'
            $allowedRollout = 'dry_run','auto_execute_max_tier','council_enabled','tier2_execution_enabled'
            $diff = @{}
            if ($body.PSObject.Properties['budget']) {
                foreach ($p in $body.budget.PSObject.Properties) {
                    if ($p.Name -notin $allowedBudget) { Send-Json $ctx @{ error = "key not allowed: budget.$($p.Name)" } 400; continue }
                    $diff["budget.$($p.Name)"] = @{ from = $cfg.budget.($p.Name); to = $p.Value }
                    $cfg.budget.($p.Name) = $p.Value
                }
            }
            if ($body.PSObject.Properties['rollout']) {
                foreach ($p in $body.rollout.PSObject.Properties) {
                    if ($p.Name -notin $allowedRollout) { Send-Json $ctx @{ error = "key not allowed: rollout.$($p.Name)" } 400; continue }
                    $diff["rollout.$($p.Name)"] = @{ from = $cfg.rollout.($p.Name); to = $p.Value }
                    $cfg.rollout.($p.Name) = $p.Value
                }
            }
            if ($diff.Count -eq 0) { Send-Json $ctx @{ error = "nothing to change" } 400; continue }

            $stamp  = (Get-Date).ToString("yyyyMMdd-HHmmss")
            $backup = "$cfgPath.bak-$stamp"
            Copy-Item $cfgPath $backup
            try {
                $newJson = $cfg | ConvertTo-Json -Depth 16
                $null = $newJson | ConvertFrom-Json   # round-trip validation
                Set-Content -Path $cfgPath -Value $newJson -Encoding utf8
            } catch {
                Copy-Item $backup $cfgPath -Force
                Send-Json $ctx @{ error = "config write failed, backup restored: $($_.Exception.Message)" } 500
                continue
            }
            Write-ControlEvent -Actor 'human' -EventType 'config_changed' -Severity 'warn' -Detail @{ diff = $diff; backup = $backup; via = 'dashboard' }
            Send-Json $ctx @{ ok = $true; diff = $diff; backup = $backup }
            continue
        }
```

- [ ] **Step 2: Verify round-trip by hand (change a soft cap, confirm, change it back)**

```powershell
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:7717/api/config -ContentType 'application/json' -Body '{"budget":{"day_soft_dollars":9}}'
(Get-Content operations/control-plane/config/control-config.json -Raw | ConvertFrom-Json).budget.day_soft_dollars   # expect 9
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:7717/api/config -ContentType 'application/json' -Body '{"budget":{"day_soft_dollars":8}}'
(Get-Content operations/control-plane/config/control-config.json -Raw | ConvertFrom-Json).budget.day_soft_dollars   # expect 8
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:7717/api/config -ContentType 'application/json' -Body '{"rollout":{"nonsense":true}}'  # expect 400 key not allowed
ls operations/control-plane/config/control-config.json.bak-*   # expect 2 backups; delete them after verifying
```

- [ ] **Step 3: Commit**

```bash
git add operations/control-plane/dashboard/dashboard-server.ps1
git commit -m "Add POST /api/config (allowlisted budget+rollout dial, backup + validation)"
```

---

### Task 9: `POST /api/run/{script}`

**Files:**
- Modify: `operations/control-plane/dashboard/dashboard-server.ps1`

- [ ] **Step 1: Add the route** (fixed two-script allowlist; synchronous; returns exit code + output tail):

```powershell
        if ($method -eq 'POST' -and $path -match '^/api/run/([a-z-]+)$') {
            $allow = @{
                'control-tick'    = (Join-Path $repo "operations\control-plane\scripts\control-tick.ps1")
                'warehouse-daily' = (Join-Path $repo "operations\data-warehouse\scripts\run-daily.ps1")
            }
            $name = $Matches[1]
            if (-not $allow.ContainsKey($name)) { Send-Json $ctx @{ error = "script not allowed: $name" } 400; continue }
            $out = & pwsh -NoProfile -File $allow[$name] 2>&1 | Out-String
            $code = $LASTEXITCODE
            $tail = ($out -split "`r?`n" | Select-Object -Last 15) -join "`n"
            Write-ControlEvent -Actor 'human' -EventType 'script_run' -Severity $(if ($code -eq 0) {'info'} else {'error'}) -Detail @{ script = $name; exit = $code; via = 'dashboard' }
            Send-Json $ctx @{ ok = ($code -eq 0); exit = $code; tail = $tail }
            continue
        }
```

- [ ] **Step 2: Verify**

```powershell
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:7717/api/run/control-tick      # expect ok=True, tail ends with gate_open=...
Invoke-RestMethod -Method Post -Uri http://127.0.0.1:7717/api/run/not-a-script      # expect 400
```

- [ ] **Step 3: Commit**

```bash
git add operations/control-plane/dashboard/dashboard-server.ps1
git commit -m "Add POST /api/run (control-tick + warehouse-daily allowlist)"
```

---

### Task 10: The Command Deck UI

**Files:**
- Modify: `operations/control-plane/dashboard/public/index.html` (replace placeholder)
- Create: `operations/control-plane/dashboard/public/style.css`
- Create: `operations/control-plane/dashboard/public/app.js`

The visual language was validated in brainstorming: dark background with radial brand-color glows, glass panels (`backdrop-filter: blur`, translucent fills, 1px light borders), Crafted Orange `#e54c00` for primary actions/progress, Sky Blue `#83b2cf` accents, success green `#3ddc84`, warning gold `#ffc24b`, danger `#ff5d5d`. Gamified accents: XP-style gradient progress bar on the validation gate with a glow, streak line under it, badge-count pill on the approvals header.

- [ ] **Step 1: Replace `index.html`**

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CWDB Mission Control</title>
<link rel="stylesheet" href="/style.css">
</head>
<body>
  <div id="toast"></div>

  <!-- status strip -->
  <header class="glass strip">
    <span id="mode-pill" class="pill">…</span>
    <span id="gate-text" class="dim">…</span>
    <span class="grow"></span>
    <button id="btn-refresh" class="btn ghost">⟳ refresh</button>
    <button id="btn-tick" class="btn ghost">⚙ run tick</button>
    <button id="btn-warehouse" class="btn ghost">⛁ warehouse</button>
    <button id="btn-power" class="btn ghost">⏸ pause</button>
  </header>

  <!-- KPI row -->
  <section class="kpis">
    <div class="glass kpi">
      <div class="label">VALIDATION GATE · <span id="kpi-days">…</span> DAYS LEFT</div>
      <div class="big" id="kpi-gate">…</div>
      <div class="bar"><i id="bar-qualified"></i></div>
      <div class="bar thin"><i id="bar-accepted"></i></div>
      <div class="dim small" id="kpi-streak">…</div>
    </div>
    <div class="glass kpi">
      <div class="label">MODEL SPEND</div>
      <div class="big" id="kpi-spend">…</div>
      <div class="bar"><i id="bar-spend"></i></div>
      <div class="dim small" id="kpi-project">…</div>
    </div>
    <div class="glass kpi">
      <div class="label">QUEUE</div>
      <div class="big" id="kpi-queue">…</div>
      <div class="dim small" id="kpi-freshness">…</div>
    </div>
  </section>

  <!-- main split -->
  <main class="split">
    <section class="glass col" id="col-approvals">
      <h2>⚡ Approvals <span id="badge-pending" class="badge">0</span></h2>
      <div id="approvals"></div>
      <h3 class="dim">decided</h3>
      <div id="decided" class="dim"></div>
    </section>
    <section class="glass col">
      <h2>◉ Activity</h2>
      <div id="events"></div>
      <h3 class="dim">tasks</h3>
      <div id="tasks"></div>
    </section>
  </main>

  <!-- steer dock -->
  <footer class="glass dock">
    <div class="row">
      <input id="directive-input" class="input grow" placeholder="🎯 standing directive for the orchestrator… (e.g. 'prioritize routing the 2 real leads')">
      <button id="btn-directive" class="btn primary">send</button>
      <button id="btn-inject" class="btn ghost">+ task</button>
      <button id="btn-config" class="btn ghost">⚙ dials</button>
    </div>
    <div id="directives" class="row wrap"></div>
  </footer>

  <!-- modals -->
  <dialog id="dlg-decide" class="glass-dialog">
    <h3 id="dlg-decide-title">Decide</h3>
    <p id="dlg-decide-summary" class="dim"></p>
    <textarea id="decide-note" class="input" rows="3" placeholder="optional note — on 'request changes' this is fed back to the worker verbatim"></textarea>
    <div class="row">
      <button class="btn ok"     onclick="decide('approve')">✓ approve</button>
      <button class="btn accent" onclick="decide('request_changes')">✎ request changes</button>
      <button class="btn danger" onclick="decide('reject')">✕ reject</button>
      <button class="btn ghost"  onclick="dlg('dlg-decide').close()">cancel</button>
    </div>
  </dialog>

  <dialog id="dlg-power" class="glass-dialog">
    <h3>Pause the loop</h3>
    <input id="pause-reason" class="input" placeholder="reason">
    <input id="pause-until"  class="input" placeholder="auto-resume (optional) — e.g. 2026-06-15 or 2026-06-15 14:00 (Central)">
    <div class="row">
      <button class="btn danger" onclick="power('pause')">⏸ pause</button>
      <button class="btn ghost"  onclick="dlg('dlg-power').close()">cancel</button>
    </div>
  </dialog>

  <dialog id="dlg-inject" class="glass-dialog">
    <h3>Inject a task</h3>
    <input id="inj-title" class="input" placeholder="title">
    <input id="inj-type"  class="input" placeholder="type — e.g. routing.build_scenario">
    <div class="row">
      <select id="inj-agent" class="input grow"></select>
      <input id="inj-priority" class="input" type="number" value="50" style="width:90px" title="priority (lower = sooner)">
    </div>
    <textarea id="inj-dod" class="input" rows="3" placeholder="definition of done — one item per line"></textarea>
    <div class="row">
      <button class="btn primary" onclick="injectTask()">queue it</button>
      <button class="btn ghost"   onclick="dlg('dlg-inject').close()">cancel</button>
    </div>
  </dialog>

  <dialog id="dlg-config" class="glass-dialog">
    <h3>Safety dials <span class="badge danger">these are the rails</span></h3>
    <div class="grid2" id="config-fields"></div>
    <div class="row">
      <button class="btn danger" onclick="saveConfig()">apply (writes control-config.json)</button>
      <button class="btn ghost"  onclick="dlg('dlg-config').close()">cancel</button>
    </div>
  </dialog>

  <script src="/app.js"></script>
</body>
</html>
```

- [ ] **Step 2: Create `style.css`**

```css
:root{
  --bg0:#07090f; --bg1:#0c1018; --ink:#e8ecf4; --dim:#8b94a7;
  --glass:rgba(255,255,255,.05); --bd:rgba(255,255,255,.10);
  --orange:#e54c00; --sky:#83b2cf; --green:#3ddc84; --gold:#ffc24b; --red:#ff5d5d;
}
*{box-sizing:border-box;margin:0;padding:0}
body{
  font-family:'Segoe UI',system-ui,sans-serif;color:var(--ink);min-height:100vh;
  padding:18px 22px 30px;display:flex;flex-direction:column;gap:16px;
  background:
    radial-gradient(1100px 500px at 85% -10%, rgba(229,76,0,.16), transparent 60%),
    radial-gradient(900px 600px at -10% 30%, rgba(131,178,207,.12), transparent 55%),
    radial-gradient(700px 500px at 50% 110%, rgba(61,220,132,.07), transparent 60%),
    linear-gradient(180deg,var(--bg0),var(--bg1));
  background-attachment:fixed;
}
.glass{
  background:linear-gradient(160deg,rgba(255,255,255,.07),rgba(255,255,255,.02));
  border:1px solid var(--bd);border-radius:18px;
  backdrop-filter:blur(14px);-webkit-backdrop-filter:blur(14px);
}
.dim{color:var(--dim)} .small{font-size:12px} .grow{flex:1}
.row{display:flex;gap:10px;align-items:center} .wrap{flex-wrap:wrap}
h2{font-size:16px;letter-spacing:.2px;margin-bottom:10px}
h3{font-size:11px;text-transform:uppercase;letter-spacing:.12em;margin:14px 0 6px}

/* status strip */
.strip{display:flex;align-items:center;gap:14px;padding:12px 18px}
.pill{border-radius:999px;padding:4px 14px;font-weight:800;font-size:13px;letter-spacing:.06em}
.pill.running{background:rgba(61,220,132,.14);color:var(--green);border:1px solid rgba(61,220,132,.45);box-shadow:0 0 14px rgba(61,220,132,.25)}
.pill.paused{background:rgba(255,194,75,.12);color:var(--gold);border:1px solid rgba(255,194,75,.4)}
.pill.halted{background:rgba(255,93,93,.14);color:var(--red);border:1px solid rgba(255,93,93,.5);box-shadow:0 0 14px rgba(255,93,93,.3)}

/* buttons */
.btn{cursor:pointer;border-radius:10px;padding:8px 14px;font-size:13px;font-weight:700;border:1px solid var(--bd);background:var(--glass);color:var(--ink);transition:all .15s}
.btn:hover{transform:translateY(-1px);border-color:rgba(131,178,207,.5)}
.btn.primary{background:rgba(229,76,0,.85);border-color:var(--orange)}
.btn.primary:hover{box-shadow:0 4px 18px rgba(229,76,0,.4)}
.btn.ok{background:rgba(61,220,132,.16);color:var(--green);border-color:rgba(61,220,132,.45)}
.btn.accent{background:rgba(131,178,207,.15);color:var(--sky);border-color:rgba(131,178,207,.45)}
.btn.danger{background:rgba(255,93,93,.13);color:var(--red);border-color:rgba(255,93,93,.4)}
.btn.ghost{background:transparent}

/* KPI cards */
.kpis{display:grid;grid-template-columns:1.4fr 1fr 1fr;gap:16px}
.kpi{padding:14px 18px}
.label{font-size:10px;font-weight:800;letter-spacing:.14em;color:var(--dim)}
.big{font-size:22px;font-weight:800;margin:6px 0}
.bar{height:10px;border-radius:999px;background:rgba(255,255,255,.07);overflow:hidden;margin:6px 0}
.bar.thin{height:6px}
.bar i{display:block;height:100%;border-radius:999px;background:linear-gradient(90deg,var(--orange),var(--gold));box-shadow:0 0 12px rgba(229,76,0,.6);transition:width .6s ease}
#bar-accepted{background:linear-gradient(90deg,var(--sky),var(--green))}
#bar-spend{background:var(--sky);box-shadow:none}

/* main split */
.split{display:grid;grid-template-columns:1.5fr 1fr;gap:16px;flex:1;min-height:0}
.col{padding:16px 18px;overflow-y:auto;max-height:58vh}
.badge{background:var(--orange);color:#fff;border-radius:999px;padding:1px 9px;font-size:11px;vertical-align:2px}
.badge.danger{background:rgba(255,93,93,.2);color:var(--red);font-size:10px;font-weight:700}

/* approval + feed cards */
.card{background:rgba(255,255,255,.04);border:1px solid var(--bd);border-radius:12px;padding:12px 14px;margin-bottom:10px}
.card .tier{display:inline-block;border-radius:999px;padding:2px 9px;font-size:10px;font-weight:800;background:rgba(255,194,75,.12);color:var(--gold);border:1px solid rgba(255,194,75,.35);margin-bottom:6px}
.card b{display:block;margin-bottom:4px}
.card .meta{font-size:12px;color:var(--dim);line-height:1.5;margin-bottom:8px}
.event{display:flex;gap:8px;align-items:baseline;font-size:12.5px;padding:4px 0;border-bottom:1px solid rgba(255,255,255,.04)}
.dot{width:7px;height:7px;border-radius:50%;flex-shrink:0;position:relative;top:1px}
.sev-info{background:var(--sky)} .sev-warn{background:var(--gold)} .sev-error,.sev-critical{background:var(--red)}
.task-line{font-size:12.5px;padding:4px 0;color:var(--dim)}
.task-line b{color:var(--ink)}

/* dock */
.dock{padding:14px 18px;display:flex;flex-direction:column;gap:10px}
.input{background:rgba(0,0,0,.3);border:1px solid var(--bd);border-radius:10px;color:var(--ink);padding:9px 12px;font-size:13px;font-family:inherit}
.input:focus{outline:none;border-color:var(--sky)}
.chip{border-radius:999px;border:1px solid rgba(131,178,207,.4);background:rgba(131,178,207,.1);color:var(--sky);padding:4px 12px;font-size:12px;display:flex;gap:8px;align-items:center}
.chip button{background:none;border:none;color:var(--dim);cursor:pointer;font-size:13px}

/* dialogs + toast */
.glass-dialog{background:linear-gradient(160deg,#141927,#0d1119);border:1px solid var(--bd);border-radius:18px;color:var(--ink);padding:22px;width:520px;max-width:92vw}
.glass-dialog::backdrop{background:rgba(0,0,0,.6);backdrop-filter:blur(4px)}
.glass-dialog h3{font-size:16px;text-transform:none;letter-spacing:0;margin-bottom:12px}
.glass-dialog .input{width:100%;margin-bottom:10px}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:12px}
.grid2 label{font-size:11px;color:var(--dim);display:block;margin-bottom:3px}
#toast{position:fixed;top:18px;right:18px;z-index:99;display:flex;flex-direction:column;gap:8px}
.toast-item{background:#141927;border:1px solid var(--bd);border-left:3px solid var(--sky);border-radius:10px;padding:10px 16px;font-size:13px;box-shadow:0 8px 30px rgba(0,0,0,.5);animation:slide .25s ease}
.toast-item.err{border-left-color:var(--red)}
@keyframes slide{from{transform:translateX(30px);opacity:0}to{transform:none;opacity:1}}
```

- [ ] **Step 3: Create `app.js`**

```javascript
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
  const st = S.status, gate = S.validation_gate;

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
          <button class="btn ok"     onclick="openDecide(${a.approval_id})">✓ / ✎ / ✕ decide…</button>
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
  $('dlg-decide-title').textContent = `Decide #${id} — ${a.action_kind}`;
  $('dlg-decide-summary').textContent = a.summary;
  $('decide-note').value = '';
  dlg('dlg-decide').showModal();
}
async function decide(decision) {
  try {
    await api(`/api/approval/${decideId}/decide`, { decision, note: $('decide-note').value });
    dlg('dlg-decide').close();
    toast(`#${decideId} ${decision.replace('_', ' ')}d`);
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
    toast('config applied · backup: ' + r.backup.split('\\').pop());
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
  toast('warehouse pull started (1–2 min)…');
  try { const r = await api('/api/run/warehouse-daily', {}); toast(r.ok ? 'warehouse refreshed ✓' : 'warehouse FAILED: ' + r.tail, !r.ok); await load(); }
  catch (e) { toast(e.message, true); }
};

load();
```

- [ ] **Step 4: Extend the self-test to cover the static assets**

In `dashboard-server.ps1`'s `-SelfTest` block, after the `static index served` check, add:

```powershell
        foreach ($asset in 'style.css','app.js') {
            $r = Invoke-WebRequest "http://127.0.0.1:$Port/$asset" -UseBasicParsing
            if ($r.StatusCode -ne 200) { throw "static $asset not served" }
            Write-Host "PASS: static $asset served"
        }
```

- [ ] **Step 5: Run self-test + eyeball it**

Run: `pwsh operations/control-plane/dashboard/dashboard-server.ps1 -SelfTest` — expect all PASS + `SELF-TEST PASSED`.
Then start the server and open `http://127.0.0.1:7717/` — expect the Command Deck: running pill, gate progress bars, the real approval_id 1 card, events feed, directive composer.

- [ ] **Step 6: Commit**

```bash
git add operations/control-plane/dashboard/public/
git add operations/control-plane/dashboard/dashboard-server.ps1
git commit -m "Add Command Deck UI (dark glass, gamified gate progress)"
```

---

### Task 11: Launcher

**Files:**
- Create: `operations/control-plane/dashboard/start-dashboard.ps1`

- [ ] **Step 1: Write it**

```powershell
<# .SYNOPSIS  Start the Mission Control server and open the browser. #>
[CmdletBinding()] param([int] $Port = 7717)
$server = Join-Path $PSScriptRoot "dashboard-server.ps1"
Start-Process "http://127.0.0.1:$Port/"
& pwsh -NoProfile -File $server -Port $Port
```

- [ ] **Step 2: Verify** — run `pwsh operations/control-plane/dashboard/start-dashboard.ps1`; browser opens to the deck; Ctrl+C stops the server.

- [ ] **Step 3: Commit**

```bash
git add operations/control-plane/dashboard/start-dashboard.ps1
git commit -m "Add dashboard launcher"
```

---

### Task 12: Orchestrator reads directives

**Files:**
- Modify: `.claude/agents/cwdb-orchestrator-tick.md` (step 2 "Read the world")

- [ ] **Step 1: Edit the runbook**

In `### 2. Read the world`, after the "active worker roster" bullet, add:

```markdown
- Standing human directives: `SELECT directive_id, body, created_at FROM directive WHERE status='active' ORDER BY created_at;`
  Treat these as Jim's standing guidance when decomposing and prioritizing — they bias WHAT you queue and route, but never override the gate, tiers, budgets, or any invariant. If a directive is satisfied or obsolete, mark it done: `UPDATE directive SET status='done', updated_at=now() WHERE directive_id=:id;` and log an `event_log` row (`event_type='directive_done'`).
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/cwdb-orchestrator-tick.md
git commit -m "Orchestrator step 2 reads active directives as standing guidance"
```

---

### Task 13: Full test pass + production acceptance

- [ ] **Step 1: Full self-test + write-path suite**

```powershell
pwsh operations/control-plane/dashboard/dashboard-server.ps1 -SelfTest          # expect SELF-TEST PASSED
# in terminal A:
pwsh operations/control-plane/dashboard/dashboard-server.ps1
# in terminal B:
pwsh operations/control-plane/dashboard/tests/test-writes.ps1                   # expect ALL WRITE-PATH TESTS PASSED
```

- [ ] **Step 2: Production acceptance — Jim decides approval_id 1 from the UI**

With the server running, Jim opens `http://127.0.0.1:7717/`, reviews the real `approval_id 1` card (build_make_routing_scenario), and clicks his decision. Verify afterward:

```sql
SELECT approval_id, status, decided_by, decided_at, decision_note FROM approval_queue WHERE approval_id = 1;
SELECT event_type, detail FROM event_log WHERE event_type = 'approval_decided' ORDER BY created_at DESC LIMIT 1;
```

Expected: status reflects Jim's choice, `decided_by='jim-dashboard'`, matching event row. **This step is Jim-driven — do not decide approval_id 1 programmatically.**

- [ ] **Step 3: Final commit (any straggler fixes) + update the project board**

```bash
git add -A operations/control-plane/dashboard/
git commit -m "Dashboard: final test pass"
```

Add a line to `_vault/board/shipped.md`: `- [build] Mission Control dashboard (local Command Deck for the control loop) — 2026-06-XX`.

---

## Self-review (done at plan-writing time)

- **Spec coverage:** laptop-only server ✓ (Task 4 binds 127.0.0.1), four action groups ✓ (Tasks 5/6/7/8), refresh-on-load ✓ (app.js `load()` once + manual button), digest-mirror reads ✓ (`Get-StateBundle`), glass/dark/gamified ✓ (Task 10), migration ✓ (Task 1), runbook directive read ✓ (Task 12), optimistic lock ✓ (Task 3+5), config backup/validation/allowlist ✓ (Task 8), run allowlist ✓ (Task 9), self-test ✓ (Tasks 4/10), synthetic write tests ✓ (Tasks 3/5/7), Jim-decides-approval-1 acceptance ✓ (Task 13).
- **Placeholder scan:** clean — every step has full code or an exact command with expected output.
- **Type consistency:** helper names match `control-db.ps1` exactly (`Invoke-SupabaseSelect -Table -Select -Filter`, `Invoke-SupabasePatch -Table -Filter -Set`, `Write-ControlEvent -Actor -EventType -Severity -Detail -TaskId`); `Invoke-LoopPause/Invoke-LoopResume` defined in Task 2 before use in Task 6; `Invoke-SupabasePatchReturning` defined in Task 3 before use in Task 5; API field names (`decision`, `note`, `action`, `until`, `kind`, `dod`) consistent between server routes and `app.js`.
