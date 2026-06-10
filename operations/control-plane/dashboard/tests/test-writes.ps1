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
