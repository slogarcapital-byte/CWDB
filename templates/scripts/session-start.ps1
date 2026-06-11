# session-start.ps1
# Creates a session note in _vault/sessions/ if one doesn't exist for today.
# Links to the previous session, scans warehouse cron health and env-var presence,
# and surfaces failures + Validation Gate state in the SessionStart hook output.

$ErrorActionPreference = 'Stop'
$vaultRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$sessionsDir = Join-Path (Join-Path $vaultRoot "_vault") "sessions"
$briefsDir   = Join-Path (Join-Path $vaultRoot "_vault") "briefs"
$dataDir     = Join-Path (Join-Path $vaultRoot "_vault") "data"
$today = Get-Date -Format "yyyy-MM-dd"
$month = Get-Date -Format "yyyy-MM"
$todayBriefFile = Join-Path $briefsDir "$today.md"
$todayBriefExists = Test-Path $todayBriefFile

# Ensure sessions directory exists
if (-not (Test-Path $sessionsDir)) {
    New-Item -ItemType Directory -Path $sessionsDir -Force | Out-Null
}

# Find existing sessions for today
$todaySessions = Get-ChildItem -Path $sessionsDir -Filter "$today-*.md" -ErrorAction SilentlyContinue | Sort-Object Name
$sequenceNumber = 1

if ($todaySessions) {
    $lastSession = $todaySessions[-1].BaseName
    if ($lastSession -match "\d{4}-\d{2}-\d{2}-(\d{3})") {
        $sequenceNumber = [int]$Matches[1] + 1
    }
}

$sessionId = "$today-$($sequenceNumber.ToString('D3'))"
$sessionFile = Join-Path $sessionsDir "$sessionId.md"

if (Test-Path $sessionFile) {
    Write-Host "Session note already exists: $sessionId"
    exit 0
}

# Find the most recent previous session (any date)
$allSessions = Get-ChildItem -Path $sessionsDir -Filter "????-??-??-???.md" -ErrorAction SilentlyContinue | Sort-Object Name
$previousSession = ""
if ($allSessions) {
    $previousSession = $allSessions[-1].BaseName
}

# --------------------------------------------------------------------------
# Warehouse cron health check
# Reads _vault/data/cron-runs.log; flags any RUN_END line in the last 24h
# with overall_exit != 0, plus any per-source failures.
# --------------------------------------------------------------------------
$cronLogPath = Join-Path $dataDir 'cron-runs.log'
$cronFailures = @()
$cronLastRun = $null
$cronLastRunStatus = 'unknown'

if (Test-Path $cronLogPath) {
    try {
        $cronLines = Get-Content -Path $cronLogPath -Tail 100 -ErrorAction Stop
        $cutoff = (Get-Date).ToUniversalTime().AddHours(-24)
        foreach ($line in $cronLines) {
            if ($line -match '^\[([0-9TZ:\.\-]+)\]\s+(\S+)\s+(.*)$') {
                # 4-arg overload: WinPS 5.1's binder cannot bind TryParse(String, [ref]DateTime)
                $ts = [DateTime]::MinValue
                if ([DateTime]::TryParse($Matches[1],
                        [System.Globalization.CultureInfo]::InvariantCulture,
                        [System.Globalization.DateTimeStyles]::RoundtripKind, [ref]$ts)) {
                    $tsUtc = $ts.ToUniversalTime()
                    $kind = $Matches[2]
                    $rest = $Matches[3]
                    if ($kind -eq 'RUN_END') {
                        $cronLastRun = $tsUtc
                        if ($rest -match 'overall_exit=(\d+)') {
                            $exitCode = [int]$Matches[1]
                            $cronLastRunStatus = if ($exitCode -eq 0) { 'success' } else { 'failure' }
                            if ($exitCode -ne 0 -and $tsUtc -gt $cutoff) {
                                $cronFailures += "RUN_END $($tsUtc.ToString('yyyy-MM-ddTHH:mm')) overall_exit=$exitCode"
                            }
                        }
                    }
                    if ($tsUtc -gt $cutoff -and $rest -match 'exit=([1-9]\d*)') {
                        $cronFailures += "$kind $($tsUtc.ToString('yyyy-MM-ddTHH:mm')) exit=$($Matches[1])"
                    }
                }
            }
        }
    } catch {
        $cronLastRunStatus = "log-read-error: $($_.Exception.Message)"
    }
} else {
    $cronLastRunStatus = 'log-missing'
}

# --------------------------------------------------------------------------
# Env-var sanity check
# Reads .env.local at repo root, reports any required keys that are missing
# or empty. Required keys derived from warehouse ingestion scripts.
# --------------------------------------------------------------------------
$envFile = Join-Path $vaultRoot '.env.local'
$requiredKeys = @(
    'HUBSPOT_PRIVATE_APP_TOKEN',
    'GOOGLE_ADS_DEVELOPER_TOKEN',
    'GOOGLE_ADS_CLIENT_ID',
    'GOOGLE_ADS_CLIENT_SECRET',
    'GOOGLE_ADS_REFRESH_TOKEN',
    'GOOGLE_ADS_CUSTOMER_ID',
    'META_ACCESS_TOKEN',
    'META_AD_ACCOUNT_ID',
    'GA4_SERVICE_ACCOUNT_JSON',
    'SUPABASE_URL',
    'SUPABASE_SERVICE_ROLE_KEY'
)
$envMissing = @()
$envPresent = @{}

if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+?)\s*$') {
            $k = $Matches[1]
            $v = $Matches[2].Trim('"').Trim("'")
            if ($v) { $envPresent[$k] = $true }
        }
    }
    foreach ($k in $requiredKeys) {
        if (-not $envPresent.ContainsKey($k)) { $envMissing += $k }
    }
} else {
    $envMissing = @('.env.local FILE MISSING at ' + $envFile)
}

# --------------------------------------------------------------------------
# Compose session note content
# --------------------------------------------------------------------------
$content = @"
---
type: session
session-id: "$sessionId"
agents-used: []
topics: []
decisions-made: []
files-changed: []
previous-session: "$( if ($previousSession) { "[[" + $previousSession + "]]" } else { "" } )"
next-session: ""
duration-minutes: 0
tags:
  - type/session
  - session/$month
created: $today
updated: $today
status: in-progress
warehouse-last-run: "$( if ($cronLastRun) { $cronLastRun.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { 'never' } )"
warehouse-last-status: "$cronLastRunStatus"
env-vars-missing: $( if ($envMissing.Count -eq 0) { '0' } else { $envMissing.Count } )
---

# Session $sessionId

## Context
<!-- Session goal will be filled by /session-end -->

## Work Done

## Decisions Made

## Open Items

## Agent Activity

## Memory Updates

## Next Session
"@

Set-Content -Path $sessionFile -Value $content -Encoding UTF8

# Update previous session's next-session field
$prevBody = $null
if ($previousSession) {
    $prevFile = Join-Path $sessionsDir "$previousSession.md"
    if (Test-Path $prevFile) {
        $prevContent = Get-Content -Path $prevFile -Raw -Encoding UTF8
        $prevBody = $prevContent
        $prevContent = $prevContent -replace 'next-session: ""', "next-session: `"[[$sessionId]]`""
        Set-Content -Path $prevFile -Value $prevContent -Encoding UTF8
    }
}

# Prepend this session to _vault/sessions/INDEX.md under "## Recent Sessions".
$indexPath = Join-Path $sessionsDir 'INDEX.md'
if (Test-Path $indexPath) {
    try {
        $indexText = Get-Content -Path $indexPath -Raw -Encoding UTF8
        $entry = "- [[$sessionId]] - $today"
        if ($indexText -notmatch [regex]::Escape($entry)) {
            if ($indexText -match '(?s)(## Recent Sessions\s*\r?\n)') {
                $indexText = $indexText -replace '(?s)(## Recent Sessions\s*\r?\n)', ('$1' + $entry + "`n")
            } else {
                $indexText = $indexText.TrimEnd() + "`n`n## Recent Sessions`n" + $entry + "`n"
            }
            $indexText = $indexText -replace '(?m)^updated: \d{4}-\d{2}-\d{2}\s*$', "updated: $today"
            Set-Content -Path $indexPath -Value $indexText -Encoding UTF8
        }
    } catch {
        # Never break the hook on INDEX update failure.
    }
}

# --------------------------------------------------------------------------
# Build additionalContext for SessionStart hook output
# --------------------------------------------------------------------------
$additionalContext = $null
if ($prevBody) {
    $maxChars = 4000
    $truncated = $prevBody
    if ($truncated.Length -gt $maxChars) {
        $truncated = $truncated.Substring(0, $maxChars) + "`n`n[truncated to $maxChars chars]"
    }

    $cronBlock = if ($cronFailures.Count -gt 0) {
        "WARNING: Warehouse cron had $($cronFailures.Count) failure(s) in the last 24h:`n" + ($cronFailures | ForEach-Object { "  - $_" } | Out-String).TrimEnd() + "`nTail _vault/data/cron-runs.log for detail."
    } elseif ($cronLastRunStatus -eq 'success') {
        "Warehouse cron: last run $( $cronLastRun.ToString('yyyy-MM-ddTHH:mm') )Z succeeded, all 4 sources exit=0."
    } elseif ($cronLastRunStatus -eq 'log-missing') {
        "WARNING: cron-runs.log not found at _vault/data/cron-runs.log. Has the Task Scheduler installer run?"
    } else {
        "Warehouse cron status: $cronLastRunStatus"
    }

    $envBlock = if ($envMissing.Count -eq 0) {
        "Env vars: all 11 required keys present in .env.local."
    } else {
        "WARNING: $($envMissing.Count) required env var(s) missing from .env.local:`n" + ($envMissing | ForEach-Object { "  - $_" } | Out-String).TrimEnd()
    }

    $briefStatusBlock = if ($todayBriefExists) {
        "Brief: ``_vault/briefs/$today.md`` exists (optional working surface)."
    } else {
        "Brief: not generated today. ``/brief`` is optional troubleshooting; live state is queryable from Supabase."
    }

    $additionalContext = @"
## Continuity from previous session

The most recent prior session is ``$previousSession``. Wikilink: [[$previousSession]].
Below is its content (truncated to $maxChars chars). Pick up any open threads.

This session's note is ``$sessionId`` (_vault/sessions/$sessionId.md) - populate via /session-end before Stop.

---

$truncated

---

## Source of Truth (read CWDB/CLAUDE.md for daily-read order)

Live business state is in the **Supabase warehouse** (project ``iabiwsbmnbxmkjvkgfhg``). Query views (``v_lead_funnel``, ``v_cac_by_channel``, ``v_meta_attribution_gap``, ``v_contractor_scorecard``, ``v_pl_monthly``) for canonical numbers before forming any business-state hypothesis.

## Validation Gate (active)

Deadline 2026-06-18. Pass: ``v_lead_funnel.qualified_count >= 3`` since 2026-06-04 OR ``v_lead_funnel.accepted_count >= 1`` lifetime. Miss: call pay-per-accepted-bid model unproven; pivot or sunset (no third extension).

## Warehouse cron health (last 24h)

$cronBlock

## Env-var presence

$envBlock

## Operational surfaces

- $briefStatusBlock
- Kanban: ``_vault/board/{directives,in-flight,shipped,killed}.md``
- Sessions: ``_vault/sessions/INDEX.md``
- Vault home: ``_vault/MOC - Home.md``
"@
}

Write-Host "Session note created: $sessionId (linked to previous: $previousSession)"
Write-Host "Warehouse last run: $($cronLastRunStatus); env vars missing: $($envMissing.Count)"

if ($additionalContext) {
    $hookOut = @{
        hookSpecificOutput = @{
            hookEventName = 'SessionStart'
            additionalContext = $additionalContext
        }
        suppressOutput = $true
    } | ConvertTo-Json -Depth 6 -Compress
    Write-Output $hookOut
}
