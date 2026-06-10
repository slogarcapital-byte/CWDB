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
    $status   = @(Get-SupabaseRows -Table "v_control_status" -Select "*")[0]
    $pending  = @(Get-SupabaseRows -Table "approval_queue" -Select "approval_id,task_id,action_kind,summary,recommended,rollback_plan,status,decided_by,decided_at,decision_note,expires_at,created_at,updated_at" -Filter "status=eq.pending&order=created_at.asc")
    $decided  = @(Get-SupabaseRows -Table "approval_queue" -Select "approval_id,task_id,action_kind,summary,recommended,rollback_plan,status,decided_by,decided_at,decision_note,expires_at,created_at,updated_at" -Filter "status=neq.pending&order=updated_at.desc&limit=20")
    $tasks    = @(Get-SupabaseRows -Table "task" -Select "task_id,type,title,status,priority,assigned_agent,permission_tier,attempts,max_attempts,updated_at" -Filter "order=priority.asc,created_at.asc&limit=50")
    $events   = @(Get-SupabaseRows -Table "event_log" -Select "event_id,actor,event_type,severity,detail,created_at" -Filter "order=created_at.desc&limit=50")
    $gate     = @(Get-SupabaseRows -Table "v_validation_gate" -Select "*")[0]
    $funnel   = @(Get-SupabaseRows -Table "v_lead_funnel" -Select "*" -Filter "order=month.desc&limit=3")
    $cac      = @(Get-SupabaseRows -Table "v_cac_by_channel" -Select "*")
    $dirs     = @(Get-SupabaseRows -Table "directive" -Select "*" -Filter "status=eq.active&order=created_at.asc")
    $agents   = @(Get-SupabaseRows -Table "agent_registry" -Select "agent_name,task_types,is_active" -Filter "is_active=eq.true")
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
                    $t = @(Get-SupabaseRows -Table "task" -Select "task_id,status,payload" -Filter "task_id=eq.$($appr.task_id)")[0]
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
                    $reason   = $(if ($body -and $body.PSObject.Properties['reason']) { "$($body.reason)" } else { "" })
                    $untilIso = $null
                    if ($body -and $body.PSObject.Properties['until'] -and $body.until) {
                        try { $untilIso = ConvertTo-UtcIsoFromCentral "$($body.until)" }
                        catch { Send-Json $ctx @{ error = "bad until value: $($_.Exception.Message)" } 400; continue }
                    }
                    $current = Get-ControlState
                    if ($current.run_mode -eq 'paused') {
                        Send-Json $ctx @{ ok = $true; run_mode = 'paused'; note = 'already paused' }
                    } else {
                        Invoke-LoopPause -By 'jim-dashboard' -Reason $reason -UntilUtcIso $untilIso
                        Send-Json $ctx @{ ok = $true; run_mode = 'paused' }
                    }
                }
                'resume' {
                    $current = Get-ControlState
                    if ($current.run_mode -eq 'running') {
                        Send-Json $ctx @{ ok = $true; run_mode = 'running'; note = 'already running' }
                    } else {
                        $r = Invoke-LoopResume -By 'jim-dashboard'
                        Send-Json $ctx @{ ok = $true; run_mode = 'running'; pause_seconds = $r.pause_seconds; approvals_extended = $r.approvals_extended }
                    }
                }
                default { Send-Json $ctx @{ error = "bad action: $action" } 400 }
            }
            continue
        }

        if ($method -eq 'POST' -and $path -eq '/api/directive') {
            $body = Read-Body $ctx
            $kind = $(if ($body -and $body.PSObject.Properties['kind']) { "$($body.kind)" } else { "" })
            switch ($kind) {
                'directive' {
                    $dbody = $(if ($body.PSObject.Properties['body']) { "$($body.body)" } else { "" })
                    if ([string]::IsNullOrWhiteSpace($dbody)) { Send-Json $ctx @{ error = "empty directive body" } 400; continue }
                    $row = @(Invoke-SupabaseInsertReturning -Table "directive" -Records @(@{ body = $dbody; created_by = 'jim-dashboard' }))[0]
                    Write-ControlEvent -Actor 'human' -EventType 'directive_added' -Severity 'info' -Detail @{ directive_id = $row.directive_id; body = $dbody; via = 'dashboard' }
                    Send-Json $ctx @{ ok = $true; directive_id = $row.directive_id }
                }
                'task' {
                    $missing = @()
                    foreach ($req in 'type','title','assigned_agent') {
                        if (-not ($body.PSObject.Properties[$req] -and "$($body.$req)".Trim())) { $missing += $req }
                    }
                    if ($missing.Count -gt 0) { Send-Json $ctx @{ error = "missing field: $($missing[0])" } 400; continue }
                    $agentOk = @(Get-SupabaseRows -Table "agent_registry" -Select "agent_name" -Filter "agent_name=eq.$($body.assigned_agent)&is_active=eq.true")
                    if ($agentOk.Count -eq 0) { Send-Json $ctx @{ error = "unknown or inactive agent: $($body.assigned_agent)" } 400; continue }
                    $obj = @(Get-SupabaseRows -Table "objective" -Select "objective_id" -Filter "status=eq.open&order=priority.asc&limit=1")
                    # Dashboard-injected tasks never get tier 0 (auto-execute); Jim can set tier 0 via SQL if ever truly needed.
                    $tier = $(if ($body.PSObject.Properties['permission_tier']) { [Math]::Max(1, [Math]::Min(3, [int]$body.permission_tier)) } else { 2 })
                    $rec = @{
                        type            = "$($body.type)"
                        title           = "$($body.title)"
                        status          = 'queued'
                        priority        = $(if ($body.PSObject.Properties['priority']) { [int]$body.priority } else { 50 })
                        assigned_agent  = "$($body.assigned_agent)"
                        permission_tier = $tier
                        payload         = @{ dod = @($(if ($body.PSObject.Properties['dod']) { $body.dod } else { @() })); inputs = @{} }
                        trace_id        = 'dashboard'
                    }
                    if ($obj.Count -gt 0) { $rec["objective_id"] = $obj[0].objective_id }
                    $row = @(Invoke-SupabaseInsertReturning -Table "task" -Records @($rec))[0]
                    Write-ControlEvent -Actor 'human' -EventType 'task_injected' -Severity 'info' -TaskId $row.task_id -Detail @{ title = "$($body.title)"; agent = "$($body.assigned_agent)"; via = 'dashboard' }
                    Send-Json $ctx @{ ok = $true; task_id = $row.task_id }
                }
                default { Send-Json $ctx @{ error = "bad kind: $kind" } 400 }
            }
            continue
        }
        if ($method -eq 'POST' -and $path -match '^/api/directive/(\d+)$') {
            $id = [long]$Matches[1]
            $body = Read-Body $ctx
            $newStatus = $(if ($body -and $body.PSObject.Properties['status']) { "$($body.status)" } else { "" })
            if ($newStatus -notin 'done','dismissed') { Send-Json $ctx @{ error = "bad status: $newStatus" } 400; continue }
            $rows = @(Invoke-SupabasePatchReturning -Table "directive" -Filter "directive_id=eq.$id" -Set @{ status = $newStatus; updated_at = (Get-UtcIso) })
            if ($rows.Count -eq 0) { Send-Json $ctx @{ error = "directive $id not found" } 404; continue }
            Send-Json $ctx @{ ok = $true }
            continue
        }

        if ($method -eq 'POST' -and $path -eq '/api/config') {
            $body = Read-Body $ctx
            $cfgPath = Join-Path $repo "operations\control-plane\config\control-config.json"
            $raw  = Get-Content $cfgPath -Raw
            $cfg  = $raw | ConvertFrom-Json
            $allowedBudget  = 'day_soft_dollars','day_hard_dollars','project_cap_dollars','day_soft_tokens','day_hard_tokens'
            $allowedRollout = 'dry_run','auto_execute_max_tier','council_enabled','tier2_execution_enabled'
            $diff = @{}
            $badKey = $null
            if ($body -and $body.PSObject.Properties['budget']) {
                foreach ($p in $body.budget.PSObject.Properties) {
                    if ($p.Name -notin $allowedBudget) { $badKey = "budget.$($p.Name)"; break }
                    if ("$($cfg.budget.($p.Name))" -ne "$($p.Value)") {
                        $diff["budget.$($p.Name)"] = @{ from = $cfg.budget.($p.Name); to = $p.Value }
                        $cfg.budget.($p.Name) = $p.Value
                    }
                }
            }
            if (-not $badKey -and $body -and $body.PSObject.Properties['rollout']) {
                foreach ($p in $body.rollout.PSObject.Properties) {
                    if ($p.Name -notin $allowedRollout) { $badKey = "rollout.$($p.Name)"; break }
                    if ("$($cfg.rollout.($p.Name))" -ne "$($p.Value)") {
                        $diff["rollout.$($p.Name)"] = @{ from = $cfg.rollout.($p.Name); to = $p.Value }
                        $cfg.rollout.($p.Name) = $p.Value
                    }
                }
            }
            if ($badKey) { Send-Json $ctx @{ error = "key not allowed: $badKey" } 400; continue }
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
            Write-ControlEvent -Actor 'human' -EventType 'config_changed' -Severity 'warn' -Detail @{ diff = $diff; backup = (Split-Path $backup -Leaf); via = 'dashboard' }
            Send-Json $ctx @{ ok = $true; diff = $diff; backup = (Split-Path $backup -Leaf) }
            continue
        }

        # POST route for Task 9 is added between this comment and the 404.

        Send-Json $ctx @{ error = "no route: $method $path" } 404
    } catch {
        try { Send-Json $ctx @{ error = "$($_.Exception.Message)" } 500 } catch { }
    }
}
