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
try {
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
}
finally {
    try {
        Invoke-RestMethod -Method Delete `
            -Uri "$($Script:SupabaseUrl)/rest/v1/approval_queue?action_kind=eq.dashboard-selftest&summary=eq.patch-returning test $uid" `
            -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
        Write-Host "PASS: cleanup"
    } catch { Write-Warning "cleanup failed (synthetic row may remain): $_" }
}

# --- /api/approval/{id}/decide end-to-end (needs server running on 7717) ---

# F5: all setup inside try so cleanup always fires on setup failure
$tuid      = New-Uid
$tuidRC    = New-Uid   # request_changes (original path)
$tuidApp   = New-Uid   # approve path
$tuidRej   = New-Uid   # reject path
$tuidNoNote = New-Uid  # F6: request_changes without note

$task      = $null
$taskRC    = $null   # kept for clarity (original task, now used for rc path)
$taskApp   = $null
$taskRej   = $null
$taskNoNote = $null

try {
    # --- original task for request_changes path ---
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
    Assert ($resp.decision -eq 'request_changes') "response echoes decision token (request_changes)"
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

    # F4a: approve path ---
    # task stays in needs_approval; we only assert the approval row flipped + task UNCHANGED + response echoes 'approve'
    Invoke-SupabaseInsert -Table "task" -Records @(@{
        type = 'dashboard.selftest'; title = "approve-test task $tuidApp"; status = 'needs_approval'
        priority = 999; trace_id = 'dashboard-selftest'; payload = @{ dod = @('selftest-approve') }
    })
    $taskApp = @(Invoke-SupabaseSelect -Table "task" -Select "task_id,status" -Filter "title=eq.approve-test task $tuidApp")[0]
    Invoke-SupabaseInsert -Table "approval_queue" -Records @(@{
        action_kind = 'dashboard-selftest'; summary = "approve test $tuidApp"; task_id = $taskApp.task_id
        proposed_action = @{ test = $true }; status = 'pending'
    })
    $apprApp = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "approval_id" -Filter "summary=eq.approve test $tuidApp")[0]

    $respApp = Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/approval/$($apprApp.approval_id)/decide" `
        -ContentType 'application/json' -Body (@{ decision = 'approve' } | ConvertTo-Json)
    Assert ($respApp.ok -eq $true) "approve path: endpoint returned ok"
    Assert ($respApp.decision -eq 'approve') "approve path: response echoes decision token (approve)"
    $apprAppAfter = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "status" -Filter "approval_id=eq.$($apprApp.approval_id)")[0]
    Assert ($apprAppAfter.status -eq 'approved') "approve path: approval status=approved"
    $taskAppAfter = @(Invoke-SupabaseSelect -Table "task" -Select "status" -Filter "task_id=eq.$($taskApp.task_id)")[0]
    Assert ($taskAppAfter.status -eq 'needs_approval') "approve path: task status unchanged (still needs_approval)"

    # F4b: reject path ---
    Invoke-SupabaseInsert -Table "task" -Records @(@{
        type = 'dashboard.selftest'; title = "reject-test task $tuidRej"; status = 'needs_approval'
        priority = 999; trace_id = 'dashboard-selftest'; payload = @{ dod = @('selftest-reject') }
    })
    $taskRej = @(Invoke-SupabaseSelect -Table "task" -Select "task_id,status" -Filter "title=eq.reject-test task $tuidRej")[0]
    Invoke-SupabaseInsert -Table "approval_queue" -Records @(@{
        action_kind = 'dashboard-selftest'; summary = "reject test $tuidRej"; task_id = $taskRej.task_id
        proposed_action = @{ test = $true }; status = 'pending'
    })
    $apprRej = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "approval_id" -Filter "summary=eq.reject test $tuidRej")[0]

    $respRej = Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/approval/$($apprRej.approval_id)/decide" `
        -ContentType 'application/json' -Body (@{ decision = 'reject'; note = 'not ready' } | ConvertTo-Json)
    Assert ($respRej.ok -eq $true) "reject path: endpoint returned ok"
    Assert ($respRej.decision -eq 'reject') "reject path: response echoes decision token (reject)"
    $apprRejAfter = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "status" -Filter "approval_id=eq.$($apprRej.approval_id)")[0]
    Assert ($apprRejAfter.status -eq 'rejected') "reject path: approval status=rejected"
    $taskRejAfter = @(Invoke-SupabaseSelect -Table "task" -Select "status" -Filter "task_id=eq.$($taskRej.task_id)")[0]
    Assert ($taskRejAfter.status -eq 'failed') "reject path: task status=failed"

    # F6: request_changes with no note -> 400 ---
    Invoke-SupabaseInsert -Table "task" -Records @(@{
        type = 'dashboard.selftest'; title = "nonote-test task $tuidNoNote"; status = 'needs_approval'
        priority = 999; trace_id = 'dashboard-selftest'; payload = @{ dod = @('selftest-nonote') }
    })
    $taskNoNote = @(Invoke-SupabaseSelect -Table "task" -Select "task_id,status" -Filter "title=eq.nonote-test task $tuidNoNote")[0]
    Invoke-SupabaseInsert -Table "approval_queue" -Records @(@{
        action_kind = 'dashboard-selftest'; summary = "nonote test $tuidNoNote"; task_id = $taskNoNote.task_id
        proposed_action = @{ test = $true }; status = 'pending'
    })
    $apprNoNote = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "approval_id" -Filter "summary=eq.nonote test $tuidNoNote")[0]

    $got400 = $false
    try {
        Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/approval/$($apprNoNote.approval_id)/decide" `
            -ContentType 'application/json' -Body (@{ decision = 'request_changes' } | ConvertTo-Json)
    } catch {
        if ($_.Exception.Response.StatusCode.value__ -eq 400) { $got400 = $true }
    }
    Assert $got400 "request_changes with no note returns 400"
    # approval should still be pending (request not applied)
    $apprNoNoteAfter = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "status" -Filter "approval_id=eq.$($apprNoNote.approval_id)")[0]
    Assert ($apprNoNoteAfter.status -eq 'pending') "request_changes no-note: approval remains pending after 400"

} finally {
    # F5: guarded cleanup; fallback by trace_id for stragglers
    $cleanErrors = @()
    if ($task) {
        try {
            Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/task?task_id=eq.$($task.task_id)" `
                -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
            Write-Host "PASS: decide cleanup (request_changes task)"
        } catch { $cleanErrors += "request_changes task: $_" }
    }
    if ($taskApp) {
        try {
            Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/task?task_id=eq.$($taskApp.task_id)" `
                -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
            Write-Host "PASS: decide cleanup (approve task)"
        } catch { $cleanErrors += "approve task: $_" }
    }
    if ($taskRej) {
        try {
            Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/task?task_id=eq.$($taskRej.task_id)" `
                -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
            Write-Host "PASS: decide cleanup (reject task)"
        } catch { $cleanErrors += "reject task: $_" }
    }
    if ($taskNoNote) {
        try {
            Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/task?task_id=eq.$($taskNoNote.task_id)" `
                -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
            Write-Host "PASS: decide cleanup (no-note task)"
        } catch { $cleanErrors += "no-note task: $_" }
    }
    # fallback straggler sweep by trace_id
    try {
        Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/task?trace_id=eq.dashboard-selftest&type=eq.dashboard.selftest" `
            -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
    } catch { }
    if ($cleanErrors.Count -gt 0) {
        Write-Warning "Some cleanup steps failed (synthetic rows may remain): $($cleanErrors -join '; ')"
    }
}
# --- /api/directive: directive insert, task injection, status update ---
$duid = New-Uid
$d = $null; $inj = $null
try {
    $d = Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive" -ContentType 'application/json' `
        -Body (@{ kind = 'directive'; body = "selftest directive $duid" } | ConvertTo-Json)
    Assert ($d.ok -eq $true -and $d.directive_id -gt 0) "directive inserted"
    $drow = @(Invoke-SupabaseSelect -Table "directive" -Select "*" -Filter "directive_id=eq.$($d.directive_id)")[0]
    Assert ($drow.status -eq 'active' -and $drow.created_by -eq 'jim-dashboard') "directive row correct"

    $inj = Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive" -ContentType 'application/json' `
        -Body (@{ kind = 'task'; type = 'dashboard.selftest'; title = "injected task $duid"; priority = 999; assigned_agent = 'lead-routing'; dod = @('a','b') } | ConvertTo-Json)
    Assert ($inj.ok -eq $true -and $inj.task_id -gt 0) "task injected"
    $trow = @(Invoke-SupabaseSelect -Table "task" -Select "status,priority,assigned_agent,payload,trace_id" -Filter "task_id=eq.$($inj.task_id)")[0]
    Assert ($trow.status -eq 'queued' -and $trow.trace_id -eq 'dashboard') "injected task queued with trace_id=dashboard"
    Assert (@($trow.payload.dod).Count -eq 2) "DoD lines in payload"

    $upd = Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive/$($d.directive_id)" -ContentType 'application/json' `
        -Body (@{ status = 'dismissed' } | ConvertTo-Json)
    Assert ($upd.ok -eq $true) "directive status update ok"
    $drow2 = @(Invoke-SupabaseSelect -Table "directive" -Select "status" -Filter "directive_id=eq.$($d.directive_id)")[0]
    Assert ($drow2.status -eq 'dismissed') "directive dismissed"

    # validation: empty directive body -> 400
    $bad = $false
    try {
        Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive" -ContentType 'application/json' `
            -Body (@{ kind = 'directive'; body = '  ' } | ConvertTo-Json)
    } catch { if ($_.Exception.Response.StatusCode.value__ -eq 400) { $bad = $true } }
    Assert $bad "empty directive body returns 400"

    # F5: negative-path tests
    # kind='task' missing title -> 400
    $got400MissingTitle = $false
    try {
        Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive" -ContentType 'application/json' `
            -Body (@{ kind = 'task'; type = 'dashboard.selftest'; assigned_agent = 'lead-routing' } | ConvertTo-Json)
    } catch { if ($_.Exception.Response.StatusCode.value__ -eq 400) { $got400MissingTitle = $true } }
    Assert $got400MissingTitle "kind=task missing title returns 400"

    # kind='task' with unknown agent -> 400
    $got400BadAgent = $false
    try {
        Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive" -ContentType 'application/json' `
            -Body (@{ kind = 'task'; type = 'dashboard.selftest'; title = 'neg test'; assigned_agent = 'no-such-agent' } | ConvertTo-Json)
    } catch { if ($_.Exception.Response.StatusCode.value__ -eq 400) { $got400BadAgent = $true } }
    Assert $got400BadAgent "kind=task with unknown assigned_agent returns 400"

    # kind='bogus' -> 400
    $got400BadKind = $false
    try {
        Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive" -ContentType 'application/json' `
            -Body (@{ kind = 'bogus'; body = 'whatever' } | ConvertTo-Json)
    } catch { if ($_.Exception.Response.StatusCode.value__ -eq 400) { $got400BadKind = $true } }
    Assert $got400BadKind "kind=bogus returns 400"

    # POST /api/directive/{ghost-id} -> 404
    $got404Ghost = $false
    try {
        Invoke-RestMethod -Method Post -Uri "http://127.0.0.1:7717/api/directive/99999999" -ContentType 'application/json' `
            -Body (@{ status = 'done' } | ConvertTo-Json)
    } catch { if ($_.Exception.Response.StatusCode.value__ -eq 404) { $got404Ghost = $true } }
    Assert $got404Ghost "PATCH ghost directive_id returns 404"
} finally {
    try {
        if ($d -and $d.directive_id) {
            Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/directive?directive_id=eq.$($d.directive_id)" `
                -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
        }
        if ($inj -and $inj.task_id) {
            Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/task?task_id=eq.$($inj.task_id)" `
                -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
        }
        Write-Host "PASS: directive cleanup"
    } catch { Write-Warning "directive cleanup failed: $_" }
}

Write-Host "`nALL WRITE-PATH TESTS PASSED"
