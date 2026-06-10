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
    $pending  = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "approval_id,task_id,action_kind,summary,recommended,rollback_plan,status,decided_by,decided_at,decision_note,expires_at,created_at,updated_at" -Filter "status=eq.pending&order=created_at.asc")
    $decided  = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "approval_id,task_id,action_kind,summary,recommended,rollback_plan,status,decided_by,decided_at,decision_note,expires_at,created_at,updated_at" -Filter "status=neq.pending&order=updated_at.desc&limit=20")
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

        if ($method -eq 'POST' -and $path -match '^/api/approval/(\d+)/decide$') {
            $id       = [long]$Matches[1]
            $body     = Read-Body $ctx
            $decision = $(if ($body -and $body.PSObject.Properties['decision']) { "$($body.decision)" } else { "" })
            $note     = $(if ($body -and $body.PSObject.Properties['note'])     { "$($body.note)"     } else { "" })
            if ($decision -notin 'approve','reject','request_changes') { Send-Json $ctx @{ error = "bad decision: $decision" } 400; continue }
            # F3: note required for request_changes
            if ($decision -eq 'request_changes' -and -not $note) { Send-Json $ctx @{ error = "note required for request_changes" } 400; continue }

            $newStatus = $(if ($decision -eq 'approve') { 'approved' } else { 'rejected' })
            $set = @{ status = $newStatus; decided_by = 'jim-dashboard'; decided_at = (Get-UtcIso); updated_at = (Get-UtcIso) }
            if ($note) { $set["decision_note"] = $note }

            # optimistic lock: only flips if still pending
            $rows = @(Invoke-SupabasePatchReturning -Table "approval_queue" -Filter "approval_id=eq.$id&status=eq.pending" -Set $set)
            if ($rows.Count -eq 0) { Send-Json $ctx @{ error = "already decided or expired" } 409; continue }
            $appr = $rows[0]

            # linked-task consequence (same mechanics the critic uses)
            # F1: race guard — only apply if task is still in needs_approval
            if ($appr.task_id) {
                if ($decision -eq 'reject') {
                    $taskRows = @(Invoke-SupabasePatchReturning -Table "task" -Filter "task_id=eq.$($appr.task_id)&status=eq.needs_approval" -Set @{ status = 'failed'; updated_at = (Get-UtcIso) })
                    if ($taskRows.Count -eq 0) {
                        Write-ControlEvent -Actor 'human' -EventType 'approval_task_skipped' -Severity 'warn' -TaskId $appr.task_id -Detail @{
                            approval_id = $id; decision = $decision; reason = 'task no longer in needs_approval'
                        }
                    }
                } elseif ($decision -eq 'request_changes') {
                    $t = @(Invoke-SupabaseSelect -Table "task" -Select "task_id,status,payload" -Filter "task_id=eq.$($appr.task_id)")[0]
                    if ($t -and $t.status -eq 'needs_approval') {
                        $payload = $t.payload
                        $fb = @()
                        if ($payload.PSObject.Properties['feedback']) { $fb = @($payload.feedback) }
                        $fb += "[jim-dashboard $(Get-UtcIso)] $note"
                        $payload | Add-Member -NotePropertyName feedback -NotePropertyValue $fb -Force
                        $taskRows = @(Invoke-SupabasePatchReturning -Table "task" -Filter "task_id=eq.$($appr.task_id)&status=eq.needs_approval" -Set @{ status = 'queued'; payload = $payload; updated_at = (Get-UtcIso) })
                        if ($taskRows.Count -eq 0) {
                            Write-ControlEvent -Actor 'human' -EventType 'approval_task_skipped' -Severity 'warn' -TaskId $appr.task_id -Detail @{
                                approval_id = $id; decision = $decision; reason = 'task no longer in needs_approval'
                            }
                        }
                    } else {
                        Write-ControlEvent -Actor 'human' -EventType 'approval_task_skipped' -Severity 'warn' -TaskId $appr.task_id -Detail @{
                            approval_id = $id; decision = $decision; reason = 'task no longer in needs_approval'
                        }
                    }
                }
            }
            Write-ControlEvent -Actor 'human' -EventType 'approval_decided' -Severity 'info' -TaskId $appr.task_id -Detail @{
                approval_id = $id; decision = $decision; note = $note; via = 'dashboard'
            }
            # F2: echo decision token in response
            Send-Json $ctx @{ ok = $true; approval_id = $id; status = $newStatus; decision = $decision }
            continue
        }

        if ($method -eq 'POST' -and $path -eq '/api/power') {
            $body = Read-Body $ctx
            $action = $(if ($body -and $body.PSObject.Properties['action']) { "$($body.action)" } else { "" })
            switch ($action) {
                'pause' {
                    $reason = $(if ($body.PSObject.Properties['reason']) { "$($body.reason)" } else { "" })
                    $untilIso = $(if ($body.PSObject.Properties['until'] -and $body.until) { ConvertTo-UtcIsoFromCentral "$($body.until)" } else { $null })
                    Invoke-LoopPause -By 'jim-dashboard' -Reason $reason -UntilUtcIso $untilIso
                    Send-Json $ctx @{ ok = $true; run_mode = 'paused' }
                }
                'resume' {
                    $r = Invoke-LoopResume -By 'jim-dashboard'
                    Send-Json $ctx @{ ok = $true; run_mode = 'running'; pause_seconds = $r.pause_seconds; approvals_extended = $r.approvals_extended }
                }
                default { Send-Json $ctx @{ error = "bad action: $action" } 400 }
            }
            continue
        }

        # POST routes for Tasks 7-9 are added between this comment and the 404.

        Send-Json $ctx @{ error = "no route: $method $path" } 404
    } catch {
        try { Send-Json $ctx @{ error = "$($_.Exception.Message)" } 500 } catch { }
    }
}
