<#
.SYNOPSIS
    The deterministic control tick - the unattended watchdog/gatekeeper of the CWDB loop.

.DESCRIPTION
    Runs every ~30 min on Windows Task Scheduler. No LLM, ~free. Each tick:
      1. rolls up the budget ledger into control_state,
      2. honors auto-resume (paused -> running once resume_at passes),
      3. if paused/halted: keeps the gate closed and exits (no reaping, no breakers),
      4. if running: reaps expired task leases (= crash recovery),
      5. evaluates circuit breakers (trip -> run_mode='halted', gate closed, alert),
      6. checks warehouse freshness + budget,
      7. computes the WATCHDOG GATE: opens it (fresh token) only when it's safe to reason,
      8. updates heartbeats and, once/day, writes the digest.

    The orchestrator (the expensive Claude layer) refuses to run unless this tick has left
    gate_open=true with a recent gate_token. PowerShell decides WHETHER to think; Claude
    decides WHAT to think. You never want an LLM deciding whether the LLM may spend more money.

.NOTES
    Idempotent and safe to run by hand for testing:  pwsh control-tick.ps1
    Registered as \CWDB\CWDB-Control-Tick by install-control-tick.ps1.
#>

[CmdletBinding()]
param([string] $RepoRoot)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot "control-db.ps1")
Initialize-ControlDb

$cfg      = Get-ControlConfig
$repo     = Get-ControlRepoRoot
$nowUtc   = [DateTime]::UtcNow
$nowIso   = $nowUtc.ToString("o")
$central  = Get-CentralNow

# Accumulate state changes; flush in as few PATCHes as possible at the end.
$patch = @{ last_control_tick_at = $nowIso }

# --- shared resume reconciliation (used by auto-resume + nothing else here) ---
function Invoke-ResumeReconciliation {
    param([object] $State)
    $pauseSeconds = 0
    if ($State.paused_at) {
        $pausedAt = [DateTime]::Parse($State.paused_at, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
        $pauseSeconds = [int]($nowUtc - $pausedAt.ToUniversalTime()).TotalSeconds
    }
    if ($pauseSeconds -gt 0) {
        $pending = @(Get-SupabaseRows -Table "approval_queue" -Select "approval_id,expires_at" -Filter "status=eq.pending")
        foreach ($a in $pending) {
            if ($a.expires_at) {
                $exp = [DateTime]::Parse($a.expires_at, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
                $newExp = $exp.ToUniversalTime().AddSeconds($pauseSeconds).ToString("o")
                Invoke-SupabasePatch -Table "approval_queue" -Filter "approval_id=eq.$($a.approval_id)" -Set @{ expires_at = $newExp; updated_at = $nowIso }
            }
        }
    }
    return $pauseSeconds
}

try {
    $state = Get-ControlState

    # ---- 1. budget roll-up (always) -----------------------------------------
    $roll = @(Get-SupabaseRows -Table "v_budget_rollup" -Select "*")[0]
    $patch["day_tokens_spent"]   = [long]$roll.day_tokens
    $patch["day_cents_spent"]    = [long]$roll.day_cents
    $patch["total_tokens_spent"] = [long]$roll.total_tokens
    $patch["total_cents_spent"]  = [long]$roll.total_cents
    $patch["day_key"]            = (Get-CentralDate)

    # ---- 2. auto-resume (paused + resume_at passed) -------------------------
    if ($state.run_mode -eq 'paused' -and $state.resume_at) {
        $resumeAt = [DateTime]::Parse($state.resume_at, $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
        if ($nowUtc -ge $resumeAt.ToUniversalTime()) {
            $gap = Invoke-ResumeReconciliation -State $state
            $patch["run_mode"]                 = 'running'
            $patch["paused_at"]                = $null
            $patch["paused_by"]                = $null
            $patch["paused_reason"]            = $null
            $patch["resume_at"]                = $null
            $patch["halted_reason"]            = $null
            $patch["consecutive_critic_fails"] = 0
            $patch["ticks_since_progress"]     = 0
            $patch["last_progress_at"]         = $nowIso
            $state.run_mode = 'running'
            Write-ControlEvent -Actor 'control_tick' -EventType 'auto_resumed' -Severity 'info' -Detail @{ pause_seconds = $gap }
        }
    }

    # ---- 3. paused / halted -> gate closed, exit early ----------------------
    if ($state.run_mode -ne 'running') {
        $patch["gate_open"]   = $false
        $patch["gate_reason"] = $state.run_mode    # 'paused' or 'halted'
        Set-ControlState -Set $patch
        Write-DigestIfDue
        Write-Host ("control-tick: run_mode={0} -> gate closed. (no reaping, no breakers)" -f $state.run_mode)
        return
    }

    # ---- 4. reaper: requeue tasks whose lease expired (crash recovery) -------
    $expired = @(Get-SupabaseRows -Table "task" -Select "task_id,attempts,type" -Filter "status=eq.active&lease_until=lt.$nowIso")
    foreach ($t in $expired) {
        Invoke-SupabasePatch -Table "task" -Filter "task_id=eq.$($t.task_id)" -Set @{
            status = 'queued'; attempts = ([int]$t.attempts + 1); lease_until = $null; updated_at = $nowIso
        }
        Write-ControlEvent -Actor 'control_tick' -EventType 'lease_expired' -Severity 'warn' -TaskId ([long]$t.task_id) -Detail @{ type = $t.type; new_attempts = ([int]$t.attempts + 1) }
    }

    # ---- 4b. approval reapers (Inc 3) ----------------------------------------
    # Expiry: pending/approved rows past expires_at can no longer be acted on.
    # An expired APPROVED row is loud (warn): Jim approved something that never ran.
    $staleApprovals = @(Get-SupabaseRows -Table "approval_queue" -Select "approval_id,status,expires_at" `
        -Filter "status=in.(pending,approved)&expires_at=lt.$nowIso")
    foreach ($a in $staleApprovals) {
        Invoke-SupabasePatch -Table "approval_queue" -Filter "approval_id=eq.$($a.approval_id)" -Set @{
            status = 'expired'; updated_at = $nowIso
        }
        $sev = if ($a.status -eq 'approved') { 'warn' } else { 'info' }
        Write-ControlEvent -Actor 'control_tick' -EventType 'approval_expired' -Severity $sev -Detail @{
            approval_id = [long]$a.approval_id; was_status = $a.status; expired_at = $a.expires_at
        }
    }
    # Stale claim: an executor that crashed mid-execution leaves status='executing'.
    # Release it back to 'approved' (the attempt was already counted at claim time);
    # safe only because the executor is idempotency-checked before mutating.
    $staleClaimCutoff = $nowUtc.AddMinutes(-45).ToString("o")
    $staleClaims = @(Get-SupabaseRows -Table "approval_queue" -Select "approval_id,claimed_at" `
        -Filter "status=eq.executing&claimed_at=lt.$staleClaimCutoff")
    foreach ($a in $staleClaims) {
        Invoke-SupabasePatch -Table "approval_queue" -Filter "approval_id=eq.$($a.approval_id)" -Set @{
            status = 'approved'; updated_at = $nowIso
        }
        Write-ControlEvent -Actor 'control_tick' -EventType 'approval_execution_stale' -Severity 'warn' -Detail @{
            approval_id = [long]$a.approval_id; claimed_at = $a.claimed_at
        }
    }

    # ---- 5. circuit breakers ------------------------------------------------
    $b = $cfg.breakers
    $dayHardCents     = [long]([double]$cfg.budget.day_hard_dollars * 100)
    $projectCapCents  = [long]([double]$cfg.budget.project_cap_dollars * 100)
    $tripped = $null

    if ([long]$patch["total_cents_spent"] -ge $projectCapCents) {
        $tripped = "project_cap_reached"
    } elseif ([long]$patch["day_cents_spent"] -ge $dayHardCents) {
        $tripped = "budget_hard_daily"
    } elseif ([long]$patch["day_tokens_spent"] -ge [long]$cfg.budget.day_hard_tokens) {
        $tripped = "token_hard_daily"
    } elseif ([int]$state.consecutive_critic_fails -ge [int]$b.consecutive_critic_fails) {
        $tripped = "consecutive_critic_fails"
    } elseif ([int]$state.ticks_since_progress -ge [int]$b.deadman_ticks_since_progress) {
        $tripped = "deadman_no_progress"
    } else {
        # error-rate spike: error/critical events within the rolling window.
        $cutoff = $nowUtc.AddHours(-1 * [double]$b.error_rate_window_hours).ToString("o")
        $errs = @(Get-SupabaseRows -Table "event_log" -Select "event_id" -Filter "severity=in.(error,critical)&created_at=gt.$cutoff")
        if ($errs.Count -ge [int]$b.error_rate_threshold) { $tripped = "error_rate_spike" }
    }

    # loop detection (Inc 5): the orchestrator re-creating the SAME work across tasks.
    # Fingerprint = type + SHA1(canonical dod). Trip when >= loop_detection_repeats live
    # tasks share a fingerprint with zero 'done' siblings in the 48h window.
    # 'needs_approval' is excluded: waiting on Jim is not looping.
    if (-not $tripped) {
        $cutoff48 = $nowUtc.AddHours(-48).ToString("o")
        $recent = @(Get-SupabaseRows -Table "task" -Select "task_id,type,status,payload,created_at" -Filter "created_at=gt.$cutoff48")
        if ($recent.Count -gt 0) {
            $sha = [System.Security.Cryptography.SHA1]::Create()
            $groups = $recent | Group-Object {
                $dod = ConvertTo-Json @($_.payload.dod) -Compress
                [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes("$($_.type)|$dod")))
            }
            foreach ($g in $groups) {
                $live = @($g.Group | Where-Object { $_.status -in 'queued','active','failed' })
                $done = @($g.Group | Where-Object { $_.status -eq 'done' })
                if ($live.Count -ge [int]$b.loop_detection_repeats -and $done.Count -eq 0) { $tripped = 'loop_detected'; break }
            }
            $sha.Dispose()
        }
    }

    # cost-per-progress (Inc 5): spend keeps accumulating while the funnel sits flat.
    # Trip when last_progress_at is older than cost_per_progress_flat_days AND the
    # ledger spend since that watermark >= cost_per_progress_spend_multiple x daily
    # soft budget. Resume re-anchors last_progress_at, so pauses cannot false-trip.
    if (-not $tripped -and $state.last_progress_at) {
        $lp = [DateTime]::Parse($state.last_progress_at, $null, [System.Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()
        if (($nowUtc - $lp).TotalDays -ge [double]$b.cost_per_progress_flat_days) {
            $led = @(Get-SupabaseRows -Table "budget_ledger" -Select "cents" -Filter "created_at=gt.$($lp.ToString('o'))")
            $spentSince = [long](($led | Measure-Object -Property cents -Sum).Sum)
            $threshold  = [long]([double]$b.cost_per_progress_spend_multiple * [double]$cfg.budget.day_soft_dollars * 100)
            if ($spentSince -ge $threshold) { $tripped = 'cost_per_progress' }
        }
    }

    if ($tripped) {
        $patch["run_mode"]      = 'halted'
        $patch["halted_reason"] = $tripped
        $patch["gate_open"]     = $false
        $patch["gate_reason"]   = "breaker:$tripped"
        Set-ControlState -Set $patch
        Write-ControlEvent -Actor 'control_tick' -EventType 'breaker_tripped' -Severity 'critical' -Detail @{
            breaker = $tripped
            day_cents = [long]$patch["day_cents_spent"]; total_cents = [long]$patch["total_cents_spent"]
            ticks_since_progress = [int]$state.ticks_since_progress; critic_fails = [int]$state.consecutive_critic_fails
        }
        Write-DigestIfDue
        Write-Host ("control-tick: BREAKER TRIPPED ({0}) -> halted, gate closed, alert logged." -f $tripped)
        return
    }

    # ---- 6. warehouse freshness ---------------------------------------------
    $fresh = Test-WarehouseFresh -MaxAgeHours ([double]$cfg.data_freshness.warehouse_max_age_hours)

    # ---- 6b. proven_delivery_path hinge (Inc 3) -------------------------------
    # One human-approved REAL delivery flips subsequent deliveries on the proven
    # path Tier 2 -> Tier 1. Two-condition AND: a real (non-test) fact_bids row
    # exists (v_delivery_proof) AND the loop actually executed a delivery-class
    # action (action_executed event). The second leg matters: WB-016 backfilled
    # real deals into fact_bids, so bid rows alone prove nothing about routing.
    if (-not [bool]$state.proven_delivery_path) {
        $proof = @(Get-SupabaseRows -Table "v_delivery_proof" -Select "real_bid_count")[0]
        if ($proof -and [int]$proof.real_bid_count -ge 1) {
            $deliveryKinds = @('routing.deliver_lead', 'deliver_lead')
            $execEvents = @(Get-SupabaseRows -Table "event_log" -Select "event_id,detail" -Filter "event_type=eq.action_executed")
            $delivered = @($execEvents | Where-Object { $_.detail -and ($deliveryKinds -contains [string]$_.detail.action_kind) })
            if ($delivered.Count -ge 1) {
                $patch["proven_delivery_path"] = $true
                Write-ControlEvent -Actor 'control_tick' -EventType 'proven_delivery_path_set' -Severity 'info' -Detail @{
                    real_bid_count = [int]$proof.real_bid_count; first_delivery_event_id = [long]$delivered[0].event_id
                }
            }
        }
    }

    # ---- 7. watchdog gate ---------------------------------------------------
    $softCents = [long]([double]$cfg.budget.day_soft_dollars * 100)
    $degraded  = ([long]$patch["day_cents_spent"] -ge $softCents) -or ([long]$patch["day_tokens_spent"] -ge [long]$cfg.budget.day_soft_tokens)

    # Is there anything worth waking the orchestrator for?
    $queued    = @(Get-SupabaseRows -Table "task" -Select "task_id" -Filter "status=eq.queued&limit=1")
    $openObj   = @(Get-SupabaseRows -Table "objective" -Select "objective_id" -Filter "status=eq.open&limit=1")
    $approved  = @(Get-SupabaseRows -Table "approval_queue" -Select "approval_id" -Filter "status=eq.approved&limit=1")
    $workAvail = ($queued.Count -gt 0) -or ($openObj.Count -gt 0) -or ($approved.Count -gt 0)

    if (-not $fresh) {
        $patch["gate_open"] = $false; $patch["gate_reason"] = "stale_warehouse_data"
    } elseif (-not $workAvail) {
        $patch["gate_open"] = $false; $patch["gate_reason"] = "no_work_available"
    } else {
        $patch["gate_open"]     = $true
        $patch["gate_token"]    = (New-Uid)
        $patch["gate_token_at"] = $nowIso
        $patch["gate_reason"]   = $(if ($degraded) { "open_degraded_soft_budget_tier0_1_only" } else { "open" })
    }

    # ---- 8. flush + transitions + digest ------------------------------------
    Set-ControlState -Set $patch
    if ([bool]$state.gate_open -ne [bool]$patch["gate_open"]) {
        Write-ControlEvent -Actor 'control_tick' -EventType 'gate_transition' -Severity 'info' -Detail @{
            from = [bool]$state.gate_open; to = [bool]$patch["gate_open"]; reason = $patch["gate_reason"]
        }
    }
    Write-DigestIfDue
    Write-Host ("control-tick: gate_open={0} reason={1} day=`${2} reaped={3}" -f `
        $patch["gate_open"], $patch["gate_reason"], ([long]$patch["day_cents_spent"] / 100.0), $expired.Count)
}
catch {
    # A failing control tick must never silently strand the loop. Log loudly; leave state as-is.
    try {
        Write-ControlEvent -Actor 'control_tick' -EventType 'control_tick_error' -Severity 'error' -Detail @{ error = ($_.Exception.Message) }
    } catch { }
    Write-Error $_
    exit 1
}
