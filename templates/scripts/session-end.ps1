# session-end.ps1
# Two-stage Stop hook.
#
# Stage 1 (content not yet populated): Emit a block decision asking Claude
#   to invoke the session-end skill. Claude populates Work Done, Decisions
#   Made, Memory Updates, etc. in the day's session note, then tries to stop.
#
# Stage 2 (content populated OR no note): Flip frontmatter status to
#   complete and bump updated date. Let the stop proceed.
#
# Infinite-loop guard: once the skill runs, it writes Work Done content and
# flips status to complete. Either of those makes Stage 2 the winning branch
# on the next invocation, so the hook blocks at most once per session.

$ErrorActionPreference = 'Stop'
$vaultRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$sessionsDir = Join-Path (Join-Path $vaultRoot "_vault") "sessions"
$today = Get-Date -Format "yyyy-MM-dd"

# Read stdin payload (Stop hook passes JSON with transcript_path, session_id, cwd).
$stdinPayload = $null
try {
    if (-not [Console]::IsInputRedirected) {
        $stdinPayload = $null
    } else {
        $raw = [Console]::In.ReadToEnd()
        if ($raw) { $stdinPayload = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue }
    }
} catch { $stdinPayload = $null }

function Write-AllowStop {
    # Default behavior: silently allow stop. PowerShell exit 0 + no stdout.
    exit 0
}

function Write-BlockStop {
    param([string]$Reason)
    $payload = @{
        decision = "block"
        reason   = $Reason
    } | ConvertTo-Json -Compress
    Write-Output $payload
    exit 0
}

function Get-TranscriptFacts {
    param([string]$TranscriptPath)
    $facts = [ordered]@{
        turns = 0
        toolCalls = 0
        filesModified = New-Object 'System.Collections.Generic.HashSet[string]'
        firstUserPrompt = ''
    }
    if (-not $TranscriptPath) { return $facts }
    if (-not (Test-Path -LiteralPath $TranscriptPath)) { return $facts }
    try {
        Get-Content -LiteralPath $TranscriptPath -Encoding UTF8 | ForEach-Object {
            $line = $_.Trim()
            if (-not $line) { return }
            try { $obj = $line | ConvertFrom-Json -ErrorAction Stop } catch { return }
            $facts.turns++
            $msgType = $obj.type
            if (-not $msgType) { $msgType = $obj.role }
            $msg = $obj.message
            if (-not $msg) { $msg = $obj }

            if ($msgType -eq 'user') {
                $text = ''
                if ($msg.content -is [string]) { $text = $msg.content }
                elseif ($msg.content) {
                    foreach ($c in $msg.content) {
                        if ($c.type -eq 'text' -and $c.text) { $text += $c.text }
                        elseif ($c -is [string]) { $text += $c }
                    }
                }
                if ($text -and -not $facts.firstUserPrompt -and $text.Length -gt 5 -and -not $text.StartsWith('<')) {
                    $trimmed = ($text -replace '\s+',' ').Trim()
                    if ($trimmed.Length -gt 200) { $trimmed = $trimmed.Substring(0,200) + '...' }
                    $facts.firstUserPrompt = $trimmed
                }
            }

            if ($msgType -eq 'assistant' -and $msg.content) {
                foreach ($c in $msg.content) {
                    if ($c.type -eq 'tool_use') {
                        $facts.toolCalls++
                        $name = $c.name
                        if ($name -in 'Edit','Write','NotebookEdit' -and $c.input -and $c.input.file_path) {
                            [void]$facts.filesModified.Add([string]$c.input.file_path)
                        }
                    }
                }
            }
        }
    } catch {
        # Best-effort - swallow parse errors.
    }
    return $facts
}

function Format-AutoCaptured {
    param($Facts)
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('## Auto-Captured')
    [void]$sb.AppendLine('')
    [void]$sb.AppendLine("- **Turns:** $($Facts.turns)")
    [void]$sb.AppendLine("- **Tool calls:** $($Facts.toolCalls)")
    [void]$sb.AppendLine("- **Files changed:** $($Facts.filesModified.Count)")
    if ($Facts.firstUserPrompt) {
        [void]$sb.AppendLine("- **Topic:** $($Facts.firstUserPrompt)")
    }
    if ($Facts.filesModified.Count -gt 0) {
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('### Files touched')
        $sorted = @($Facts.filesModified) | Sort-Object -Unique
        $max = [Math]::Min(50, $sorted.Count)
        for ($i = 0; $i -lt $max; $i++) {
            [void]$sb.AppendLine('- `' + $sorted[$i] + '`')
        }
        if ($sorted.Count -gt 50) {
            $rem = $sorted.Count - 50
            [void]$sb.AppendLine("- ...and $rem more")
        }
    }
    return $sb.ToString()
}

if (-not (Test-Path $sessionsDir)) { Write-AllowStop }

$filter = "$today-*.md"
$todaySessions = Get-ChildItem -Path $sessionsDir -Filter $filter -ErrorAction SilentlyContinue | Sort-Object Name
if (-not $todaySessions) { Write-AllowStop }

$sessionFile = $todaySessions[-1].FullName
$sessionId = $todaySessions[-1].BaseName
$content = Get-Content -Path $sessionFile -Raw -Encoding UTF8

# Detect populated state: status already complete, OR Work Done has content.
$isComplete = $content -match '(?m)^status:\s*complete\s*$'
$workDoneHasContent = $false
if ($content -match '(?s)##\s*Work Done\s*\r?\n(.*?)##') {
    $body = $Matches[1].Trim()
    if ($body.Length -gt 0) { $workDoneHasContent = $true }
}

if ($isComplete -and $workDoneHasContent) {
    # Already closed and populated. Nothing to do.
    Write-AllowStop
}

if (-not $workDoneHasContent) {
    # Stage 1: ask Claude to populate before allowing stop.
    $reason = "Session note $sessionId is open with empty Work Done section. " +
              "Before stopping, invoke the session-end skill (via the Skill tool: skill=session-end) " +
              "to populate Work Done, Decisions Made, Memory Updates, Open Items, Agent Activity, " +
              "and Next Session based on this conversation's actual work. Target file: " +
              "_vault/sessions/$sessionId.md. Do not create a new session note. Update the existing one. " +
              "Keep existing frontmatter; only fill body sections and update topics/agents-used/files-changed " +
              "arrays in frontmatter if empty."
    Write-BlockStop -Reason $reason
}

# Stage 2: content is populated but status still in-progress. Flip it and
# append auto-captured facts from the transcript.
$content = $content -replace '(?m)^updated: \d{4}-\d{2}-\d{2}\s*$', "updated: $today"
$content = $content -replace '(?m)^status: in-progress\s*$', 'status: complete'

# Append Auto-Captured section if not already present and we have a transcript.
if ($content -notmatch '(?m)^##\s+Auto-Captured\s*$' -and $stdinPayload -and $stdinPayload.transcript_path) {
    try {
        $facts = Get-TranscriptFacts -TranscriptPath $stdinPayload.transcript_path
        if ($facts.turns -gt 0) {
            $autoSection = Format-AutoCaptured -Facts $facts
            $content = $content.TrimEnd() + "`n`n" + $autoSection
        }
    } catch {
        # Never fail the hook on parse errors.
    }
}

Set-Content -Path $sessionFile -Value $content -Encoding UTF8
Write-Host "Session note closed: $sessionId"
exit 0
