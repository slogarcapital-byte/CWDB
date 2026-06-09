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

function ConvertTo-UtcIsoFromCentral {
    param([string] $Text)
    $tz = [System.TimeZoneInfo]::FindSystemTimeZoneById("Central Standard Time")
    # Date-only -> default to 06:00 (start of the active window).
    $parsed = [DateTime]::Parse($Text, [System.Globalization.CultureInfo]::InvariantCulture)
    if ($parsed.TimeOfDay.TotalSeconds -eq 0 -and $Text -notmatch '[:T]') {
        $parsed = $parsed.Date.AddHours(6)
    }
    $utc = [System.TimeZoneInfo]::ConvertTimeToUtc([DateTime]::SpecifyKind($parsed, 'Unspecified'), $tz)
    return $utc.ToString("o")
}

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

        $set = @{
            run_mode      = 'paused'
            paused_at     = (Get-UtcIso)
            paused_by     = $who
            paused_reason = $(if ($Reason) { $Reason } else { $null })
            gate_open     = $false
            gate_reason   = 'paused_by_human'
        }
        if ($Until) { $set["resume_at"] = (ConvertTo-UtcIsoFromCentral $Until) }
        Set-ControlState -Set $set
        Write-ControlEvent -Actor 'human' -EventType 'paused' -Severity 'info' -Detail @{
            paused_by = $who; reason = $Reason; resume_at = $set["resume_at"]
        }
        Write-Host ""
        Write-Host "  Control loop PAUSED. No reasoning ticks, no model spend until you turn it back on."
        if ($Until) { Write-Host "  Auto-resume scheduled for $Until (Central)." }
        Write-Host "  Resume any time with:  pwsh `"$PSCommandPath`" on"
        Write-Host ""
    }

    'on' {
        $state = Get-ControlState
        if ($state.run_mode -eq 'running') { Write-Host "Already running."; Show-Status; break }

        # Pause duration (for expiry push + logging).
        $pauseSeconds = 0
        if ($state.paused_at) {
            $pausedAt = [DateTime]::Parse($state.paused_at, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
            $pauseSeconds = [int]([DateTime]::UtcNow - $pausedAt.ToUniversalTime()).TotalSeconds
        }

        # Resume reconciliation: re-anchor time-windowed breakers, clear pause/halt fields.
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

        # Push pending approval expiries forward by the gap so nothing silently expired.
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
            resumed_by = $who; pause_seconds = $pauseSeconds; approvals_extended = $pushed
            note = 'breaker windows re-anchored; first orchestrator tick will re-baseline the funnel'
        }
        Write-Host ""
        Write-Host ("  Control loop RESUMED (was off ~{0:n1}h). Picks up the next queued task." -f ($pauseSeconds / 3600.0))
        if ($pushed -gt 0) { Write-Host ("  Extended {0} pending approval expiry(ies) by the pause duration." -f $pushed) }
        Write-Host "  The next control tick (<=30 min) opens the gate. Run it now with:"
        Write-Host ("    pwsh `"{0}`"" -f (Join-Path $PSScriptRoot 'control-tick.ps1'))
        Write-Host ""
    }

    'status' { Show-Status }
}
