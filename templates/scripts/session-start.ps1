# session-start.ps1
# Creates a session note in _vault/sessions/ if one doesn't exist for today.
# Links to the previous session for memory chaining.
# Called by Claude Code SessionStart hook.

$ErrorActionPreference = 'Stop'
$vaultRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$sessionsDir = Join-Path (Join-Path $vaultRoot "_vault") "sessions"
$briefsDir  = Join-Path (Join-Path $vaultRoot "_vault") "briefs"
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
    # Get the highest sequence number for today
    $lastSession = $todaySessions[-1].BaseName
    if ($lastSession -match "\d{4}-\d{2}-\d{2}-(\d{3})") {
        $sequenceNumber = [int]$Matches[1] + 1
    }
}

$sessionId = "$today-$($sequenceNumber.ToString('D3'))"
$sessionFile = Join-Path $sessionsDir "$sessionId.md"

# Don't create if already exists
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

# Create session note
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

# Build additionalContext from previous session note so Claude sees continuity
# automatically on every new session.
$additionalContext = $null
if ($prevBody) {
    $maxChars = 4000
    $truncated = $prevBody
    if ($truncated.Length -gt $maxChars) {
        $truncated = $truncated.Substring(0, $maxChars) + "`n`n[truncated to $maxChars chars]"
    }
    $briefStatusBlock = if ($todayBriefExists) {
        "Today's brief is at ``_vault/briefs/$today.md`` (active)."
    } else {
        "**Today's brief is MISSING** at ``_vault/briefs/$today.md``. Run ``/brief`` to generate it before starting work — the CEO operator reads yesterday's brief, pulls live data, and writes today's."
    }

    $additionalContext = @"
## Continuity from previous session

The most recent prior session is ``$previousSession``. You can wikilink it as [[$previousSession]].
Below is its content (truncated to $maxChars chars). Pick up any open threads listed there.

This session's note is ``$sessionId`` (_vault/sessions/$sessionId.md) - populate it via /session-end before Stop.

---

$truncated

---

## Today's Brief

$briefStatusBlock

Operational surfaces:
- Daily brief: ``_vault/briefs/$today.md`` (singleton ``_vault/state-of-cwdb.md`` is DEPRECATED — use briefs)
- Kanban board: ``_vault/board/{directives,in-flight,shipped,killed}.md``
- Session index: ``_vault/sessions/INDEX.md``
- Nav hub: ``_vault/MOC - Home.md``
"@
}

Write-Host "Session note created: $sessionId (linked to previous: $previousSession)"

# Emit SessionStart hook output so Claude gets the prior session context.
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
