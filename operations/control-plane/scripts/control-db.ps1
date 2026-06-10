<#
.SYNOPSIS
    Control-plane data-access helper. Dot-source from control-tick.ps1 / control-power.ps1.

.DESCRIPTION
    Builds on the warehouse helper templates/scripts/load-supabase.ps1 (UPSERT + SELECT) and
    adds what the control loop needs: PATCH-by-filter (the warehouse upsert can't partial-update
    NOT-NULL rows), idempotent INSERT, and typed convenience wrappers over the 006 tables.

    The warehouse helper is reused as-is and never modified.

.NOTES
    Requires SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY (loaded from .env.local). The
    service_role key bypasses RLS - server-side only, never the browser.
#>

Set-StrictMode -Version Latest

# Repo root = three levels up from operations/control-plane/scripts.
$Script:ControlRepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
. (Join-Path $Script:ControlRepoRoot "templates\scripts\load-supabase.ps1")

function Initialize-ControlDb {
    [CmdletBinding()] param()
    Load-DotEnvIfNeeded -RepoRoot $Script:ControlRepoRoot
    Initialize-SupabaseClient
}

# ---- time helpers ----------------------------------------------------------
function Get-UtcIso { (Get-Date).ToUniversalTime().ToString("o") }

function Get-CentralNow {
    $utc = [DateTime]::UtcNow
    $tz  = [System.TimeZoneInfo]::FindSystemTimeZoneById("Central Standard Time")
    [System.TimeZoneInfo]::ConvertTimeFromUtc($utc, $tz)
}
function Get-CentralDate { (Get-CentralNow).ToString("yyyy-MM-dd") }

function New-Uid { [guid]::NewGuid().ToString("N") }

# ---- generic REST verbs the warehouse helper doesn't provide ---------------
function Invoke-SupabasePatch {
    <#
    .SYNOPSIS  PATCH (partial update) rows matching a PostgREST filter.
    .PARAMETER Table   public-schema table name.
    .PARAMETER Filter  PostgREST filter, e.g. "id=eq.1" or "status=eq.active".
    .PARAMETER Set     Hashtable of column => value to write.
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
        "Prefer"        = "return=minimal"
    }
    try {
        Invoke-RestMethod -Method Patch -Uri $url -Headers $headers -Body $body -ErrorAction Stop | Out-Null
    } catch {
        $errBody = ""
        try {
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $errBody = $reader.ReadToEnd()
            }
        } catch { }
        throw "PATCH $Table ($Filter) failed: $($_.Exception.Message)`n$errBody"
    }
}

function Invoke-SupabaseInsert {
    <#
    .SYNOPSIS  Plain INSERT (no on_conflict). Records carry their own unique *_uid so retries
               that already landed will 409 - callers treat a duplicate as success.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Table,
        [Parameter(Mandatory)][object[]] $Records
    )
    $url  = "$($Script:SupabaseUrl)/rest/v1/$Table"
    if ($Records.Count -eq 1) {
        $body = "[" + ($Records[0] | ConvertTo-Json -Depth 32 -Compress) + "]"
    } else {
        $body = $Records | ConvertTo-Json -Depth 32 -Compress
    }
    $headers = @{
        "apikey"        = $Script:SupabaseKey
        "Authorization" = "Bearer $($Script:SupabaseKey)"
        "Content-Type"  = "application/json"
        "Prefer"        = "return=minimal"
    }
    try {
        Invoke-RestMethod -Method Post -Uri $url -Headers $headers -Body $body -ErrorAction Stop | Out-Null
    } catch {
        # 409 = unique violation = this row already landed on a prior try. Idempotent: ok.
        if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 409) { return }
        $errBody = ""
        try {
            if ($_.Exception.Response) {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $errBody = $reader.ReadToEnd()
            }
        } catch { }
        throw "INSERT $Table failed: $($_.Exception.Message)`n$errBody"
    }
}

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
        # PostgREST returns [] for 0 matches -> @() ; a single match -> single object -> @(obj) = 1-element array.
        # $null happens only on a genuine empty body; guard kept for safety.
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

# ---- typed wrappers over the 006 tables ------------------------------------
function Get-ControlState {
    $rows = Invoke-SupabaseSelect -Table "control_state" -Filter "id=eq.1"
    if (-not $rows -or @($rows).Count -eq 0) { throw "control_state row id=1 missing. Apply schema/006 + INSERT default." }
    return @($rows)[0]
}

function Set-ControlState {
    [CmdletBinding()] param([Parameter(Mandatory)][hashtable] $Set)
    $Set["updated_at"] = Get-UtcIso
    Invoke-SupabasePatch -Table "control_state" -Filter "id=eq.1" -Set $Set
}

function Write-ControlEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $Actor,
        [Parameter(Mandatory)][string] $EventType,
        [ValidateSet('debug','info','warn','error','critical')][string] $Severity = 'info',
        [hashtable] $Detail = @{},
        [Nullable[long]] $TaskId = $null,
        [string] $TraceId = $null
    )
    $row = @{
        event_uid  = New-Uid
        actor      = $Actor
        event_type = $EventType
        severity   = $Severity
        detail     = $Detail
    }
    if ($TaskId)  { $row["task_id"]  = $TaskId }
    if ($TraceId) { $row["trace_id"] = $TraceId }
    Invoke-SupabaseInsert -Table "event_log" -Records @($row)
}

function Get-ControlConfig {
    $path = Join-Path $Script:ControlRepoRoot "operations\control-plane\config\control-config.json"
    if (-not (Test-Path $path)) { throw "control-config.json not found at $path" }
    return Get-Content $path -Raw | ConvertFrom-Json
}

function Get-ControlRepoRoot { $Script:ControlRepoRoot }

# ---- warehouse freshness ---------------------------------------------------
function Test-WarehouseFresh {
    <#
    .SYNOPSIS  True if the daily warehouse cron's last RUN_END succeeded within MaxAgeHours.
               Never reason on stale funnel data. Set $env:CWDB_SKIP_FRESHNESS=1 to bypass (testing).
    #>
    [CmdletBinding()] param([double] $MaxAgeHours = 26)
    if ($env:CWDB_SKIP_FRESHNESS -eq '1') { return $true }
    $log = Join-Path $Script:ControlRepoRoot "_vault\data\cron-runs.log"
    if (-not (Test-Path $log)) { return $false }   # can't verify => conservative
    $end = Get-Content $log | Where-Object { $_ -match 'RUN_END' } | Select-Object -Last 1
    if (-not $end) { return $false }
    if ($end -notmatch '^\[(?<ts>[^\]]+)\].*overall_exit=(?<exit>\d+)') { return $false }
    if ([int]$Matches['exit'] -ne 0) { return $false }
    $ts = [DateTime]::Parse($Matches['ts'], $null, [System.Globalization.DateTimeStyles]::RoundtripKind)
    return (([DateTime]::UtcNow - $ts.ToUniversalTime()).TotalHours -le $MaxAgeHours)
}

# ---- central-time parsing --------------------------------------------------
function ConvertTo-UtcIsoFromCentral {
    <# .SYNOPSIS  "2026-06-15" (-> 06:00 CT) or any datetime text, Central -> UTC ISO. #>
    [CmdletBinding()] param([Parameter(Mandatory)][string] $Text)
    $tz = [System.TimeZoneInfo]::FindSystemTimeZoneById("Central Standard Time")
    $parsed = [DateTime]::Parse($Text, [System.Globalization.CultureInfo]::InvariantCulture)
    # Date-only -> default to 06:00 (start of the active window).
    if ($parsed.TimeOfDay.TotalSeconds -eq 0 -and $Text -notmatch '[:T]') {
        $parsed = $parsed.Date.AddHours(6)
    }
    $utc = [System.TimeZoneInfo]::ConvertTimeToUtc([DateTime]::SpecifyKind($parsed, 'Unspecified'), $tz)
    return $utc.ToString("o")
}

# ---- pause / resume (single implementation: control-power.ps1 + dashboard) -
function Invoke-LoopPause {
    <# .SYNOPSIS  Pause the loop: mode+reason+optional until, close gate, event row. #>
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $By, [string] $Reason, [string] $UntilUtcIso)
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
    # NOTE: gate_open stays false on purpose - the next control tick opens the gate.
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

# ---- daily digest ----------------------------------------------------------
function Write-DigestIfDue {
    <#
    .SYNOPSIS  Once per day, during the configured digest hour (Central), write the digest
               markdown + a JSON handoff the Claude layer turns into a Gmail draft (PowerShell
               has no Gmail credentials; the reasoning layer owns the external send).
    #>
    [CmdletBinding()] param()
    $cfg     = Get-ControlConfig
    $central = Get-CentralNow
    if ($central.Hour -ne [int]$cfg.cadence.digest_hour_local) { return }

    $date = $central.ToString("yyyy-MM-dd")
    $dir  = Join-Path $Script:ControlRepoRoot "_vault\control"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $md = Join-Path $dir "digest-$date.md"
    if (Test-Path $md) { return }   # already written today

    $s = @(Invoke-SupabaseSelect -Table "v_control_status" -Select "*")[0]
    $since   = [DateTime]::UtcNow.AddHours(-24).ToString("o")
    $events  = @(Invoke-SupabaseSelect -Table "event_log" -Select "created_at,actor,event_type,severity,detail" -Filter "severity=in.(warn,error,critical)&created_at=gt.$since&order=created_at.desc&limit=25")
    $pending = @(Invoke-SupabaseSelect -Table "approval_queue" -Select "approval_id,action_kind,summary,recommended,rollback_plan,created_at" -Filter "status=eq.pending&order=created_at.asc")

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("# CWDB Control Loop - Digest $date")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("**Mode:** $($s.run_mode.ToUpper())  ·  gate_open=$($s.gate_open)  ·  $($s.gate_reason)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Goal")
    [void]$sb.AppendLine("- Qualified since gate: **$($s.qualified_since_gate)/$($s.qualified_target)**  ·  Accepted lifetime: **$($s.accepted_lifetime)/$($s.accepted_target)**  ·  gate_met=$($s.gate_met)")
    [void]$sb.AppendLine("- Days to deadline: $($s.days_to_deadline)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Queue")
    [void]$sb.AppendLine("- queued=$($s.tasks_queued) active=$($s.tasks_active) needs_approval=$($s.tasks_needs_approval) blocked=$($s.tasks_blocked) failed=$($s.tasks_failed) done(24h)=$($s.tasks_done_24h)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Spend (model, not ad)")
    [void]$sb.AppendLine("- Today: `$$($s.day_dollars_spent) (soft `$$($s.day_soft_dollars) / hard `$$($s.day_hard_dollars))  ·  Project: `$$($s.total_dollars_spent)/`$$($s.project_cap_dollars)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Pending approvals ($($pending.Count))")
    if ($pending.Count -eq 0) { [void]$sb.AppendLine("- none") }
    foreach ($a in $pending) {
        [void]$sb.AppendLine("- **[$($a.action_kind)]** $($a.summary)")
        if ($a.recommended)   { [void]$sb.AppendLine("  - Recommended: $($a.recommended)") }
        if ($a.rollback_plan) { [void]$sb.AppendLine("  - Rollback: $($a.rollback_plan)") }
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Notable events (24h, warn+)")
    if ($events.Count -eq 0) { [void]$sb.AppendLine("- none") }
    foreach ($e in $events) { [void]$sb.AppendLine("- [$($e.severity)] $($e.created_at) $($e.actor)/$($e.event_type)") }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Switch")
    [void]$sb.AppendLine("- Pause:  ``pwsh operations/control-plane/scripts/control-power.ps1 off -Until <date>``")
    [void]$sb.AppendLine("- Resume: ``pwsh operations/control-plane/scripts/control-power.ps1 on``")

    Set-Content -Path $md -Value $sb.ToString() -Encoding utf8

    # Handoff for the Claude layer to deliver as a Gmail draft (it has the Gmail MCP; PS doesn't).
    $json = @{
        date = $date
        delivered = $false
        subject = "CWDB digest $date - $($s.run_mode), $($s.qualified_since_gate)/$($s.qualified_target) qualified, $($s.approvals_pending) approvals pending"
        to = $cfg.escalation.to
        markdown_path = $md
        approvals_pending = [int]$s.approvals_pending
    } | ConvertTo-Json -Depth 8
    Set-Content -Path (Join-Path $dir "digest-latest.json") -Value $json -Encoding utf8

    Write-ControlEvent -Actor 'control_tick' -EventType 'digest_written' -Severity 'info' -Detail @{ date = $date; approvals_pending = [int]$s.approvals_pending }
}
