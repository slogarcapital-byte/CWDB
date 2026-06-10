<#
.SYNOPSIS
    The on/off switch for the CWDB autonomous control loop.

.DESCRIPTION
    A single source of truth (control_state.run_mode) decides whether the loop reasons:
      running  = go.
      paused   = Jim turned it off. Quiet. No model spend, no alerts, in-flight work frozen.
      halted   = a circuit breaker stopped it. Loud (alerts). `on` clears it.

    Because the whole loop is reconstituted from Supabase every tick, turning it off and
    resuming exactly where it left off is nearly free. The only real work is making sure a
    multi-day gap can't be misread as failure - `on` re-anchors the time-windowed breakers
    and pushes pending approval expiries forward by the pause duration.

.PARAMETER Command
    off | on | status

.PARAMETER Until
    (off only) Auto-resume target. Date "2026-06-15" (resumes 06:00 Central) or a full
    datetime. The control tick flips paused -> running itself once this passes.

.PARAMETER Reason
    (off only) Free-text note stored on the pause.

.EXAMPLE
    pwsh control-power.ps1 off -Until 2026-06-15 -Reason "out of town"
    pwsh control-power.ps1 on
    pwsh control-power.ps1 status
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)][ValidateSet('off','on','status')][string] $Command = 'status',
    [string] $Until,
    [string] $Reason
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot "control-db.ps1")
Initialize-ControlDb

$who = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

function Show-Status {
    $rows = Invoke-SupabaseSelect -Table "v_control_status" -Select "*"
    if (-not $rows -or @($rows).Count -eq 0) { Write-Host "v_control_status returned no rows."; return }
    $s = @($rows)[0]
    $mode = $s.run_mode.ToUpper()
    $marker = switch ($s.run_mode) { 'running' { 'ON ' } 'paused' { 'OFF' } 'halted' { '!! ' } default { '?  ' } }

    Write-Host ""
    Write-Host ("  [{0}] CWDB control loop: {1}" -f $marker, $mode)
    if ($s.run_mode -eq 'paused') {
        Write-Host ("        paused since {0}{1}" -f $s.paused_at, $(if ($s.resume_at) { "  (auto-resume $($s.resume_at))" } else { "" }))
        if ($s.paused_reason) { Write-Host ("        reason: {0}" -f $s.paused_reason) }
    } elseif ($s.run_mode -eq 'halted') {
        Write-Host ("        HALTED by breaker: {0}" -f $s.halted_reason)
    } else {
        Write-Host ("        gate_open={0}  {1}" -f $s.gate_open, $s.gate_reason)
    }
    Write-Host ""
    Write-Host ("  goal     qualified(since gate) {0}/{1}   accepted(lifetime) {2}/{3}   gate_met={4}   days_to_deadline={5}" -f `
        $s.qualified_since_gate, $s.qualified_target, $s.accepted_lifetime, $s.accepted_target, $s.gate_met, $s.days_to_deadline)
    Write-Host ("  queue    queued={0}  active={1}  needs_approval={2}  blocked={3}  failed={4}  done_24h={5}" -f `
        $s.tasks_queued, $s.tasks_active, $s.tasks_needs_approval, $s.tasks_blocked, $s.tasks_failed, $s.tasks_done_24h)
    Write-Host ("  spend    today `${0} (soft `${1} / hard `${2})   project `${3}/`${4}" -f `
        $s.day_dollars_spent, $s.day_soft_dollars, $s.day_hard_dollars, $s.total_dollars_spent, $s.project_cap_dollars)
    Write-Host ("  breaker  critic_fails={0}  ticks_since_progress={1}  approvals_pending={2}" -f `
        $s.consecutive_critic_fails, $s.ticks_since_progress, $s.approvals_pending)
    Write-Host ("  ticks    control={0}  orchestrator={1}" -f $s.last_control_tick_at, $s.last_orchestrator_tick_at)
    Write-Host ""
}

switch ($Command) {

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

    'status' { Show-Status }
}
