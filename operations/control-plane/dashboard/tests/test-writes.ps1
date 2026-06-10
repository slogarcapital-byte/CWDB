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
# Insert synthetic pending approval + a synthetic queued task it points at.
$tuid = New-Uid
Invoke-SupabaseInsert -Table "task" -Records @(@{
    type = 'dashboard.selftest'; title = "decide-test task $tuid"; status = 'needs_approval'
    priority = 999; trace_id = 'dashboard-selftest'; payload = @{ dod = @('selftest') }
})
$task = @(Invoke-SupabaseSelect -Table "task" -Select "task_id,status,payload" -Filter "title=eq.decide-test task $tuid")[0]
try {
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
} finally {
    try {
        # task cascade-deletes the approval row via FK
        Invoke-RestMethod -Method Delete -Uri "$($Script:SupabaseUrl)/rest/v1/task?task_id=eq.$($task.task_id)" `
            -Headers @{ apikey = $Script:SupabaseKey; Authorization = "Bearer $($Script:SupabaseKey)" } | Out-Null
        Write-Host "PASS: decide cleanup"
    } catch { Write-Warning "decide cleanup failed (synthetic rows may remain): $_" }
}
Write-Host "`nALL WRITE-PATH TESTS PASSED"
