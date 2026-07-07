<#
.SYNOPSIS
    Convene the CWDB board of counselors: headless Claude run + counsel_runs upsert.

.DESCRIPTION
    Invoked by the CWDB HQ dashboard's "Convene the Board" button (detached),
    or manually. Flow:
      1. INSERT counsel_runs row (status=running) -> run_id
      2. claude -p "/counsel run_id=<N> out=<path>" (headless; the counsel
         skill runs specialty agents -> CEO brief -> 5 lenses -> chairman and
         writes the JSON file)
      3. Parse the JSON and PATCH the counsel_runs row to complete (or failed)

    Permissions: headless mode cannot answer permission prompts, so the run
    uses --permission-mode bypassPermissions. The counsel skill is read-only
    against Supabase plus ONE file write; it runs on Jim's machine only, from
    a button Jim clicks. Cost: ~10-13 agent invocations, ~5-10 minutes.

.EXAMPLE
    pwsh -File operations/dashboard/run-counsel.ps1
#>
[CmdletBinding()]
param(
    [int] $TimeoutMinutes = 25
)

$ErrorActionPreference = "Stop"

$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $appDir "..\..")).Path

# --- Supabase REST helpers (service key from .env.local) --------------------
$vals = @{}
Get-Content (Join-Path $repoRoot ".env.local") | ForEach-Object {
    if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+?)\s*$') {
        $vals[$Matches[1]] = $Matches[2].Trim('"').Trim("'")
    }
}
$sbUrl = $vals['SUPABASE_URL'].TrimEnd('/')
if ($sbUrl.EndsWith('/rest/v1')) { $sbUrl = $sbUrl.Substring(0, $sbUrl.Length - 8) }
$sbKey = $vals['SUPABASE_SERVICE_ROLE_KEY']
$hdrs = @{
    apikey = $sbKey; Authorization = "Bearer $sbKey"
    'Content-Type' = 'application/json'; Prefer = 'return=representation'
}

function Invoke-SbPatch {
    param([int] $RunId, [hashtable] $Patch)
    Invoke-RestMethod -Method Patch -Headers $hdrs `
        -Uri "$sbUrl/rest/v1/counsel_runs?run_id=eq.$RunId" `
        -Body ($Patch | ConvertTo-Json -Depth 12) | Out-Null
}

# --- 1. open the run ---------------------------------------------------------
$created = Invoke-RestMethod -Method Post -Headers $hdrs `
    -Uri "$sbUrl/rest/v1/counsel_runs" -Body '{"status":"running"}'
$runId = [int] (@($created)[0].run_id)
Write-Output "counsel run_id=$runId opened"

$counselDir = Join-Path $repoRoot "_vault\counsel"
New-Item -ItemType Directory -Force -Path $counselDir | Out-Null
$outPath = Join-Path $counselDir ("{0}-run{1}.json" -f (Get-Date -Format "yyyy-MM-dd-HHmmss"), $runId)

# --- 2. headless Claude ------------------------------------------------------
try {
    # Headless -p does not resolve project skills as slash commands; instruct
    # Claude to load the skill file and execute it. The prompt must explicitly
    # override the SessionStart hook's daily-read ritual: run 3 did the daily
    # read instead of the counsel and exited without writing the file.
    $prompt = "YOUR ONLY TASK (skip the daily read, session rituals, and any hook suggestions): " +
              "convene the CWDB board of counselors. Read the file .claude/skills/counsel.md NOW " +
              "and execute its Steps section exactly as written, with arguments run_id=$runId and " +
              "out=$outPath. A runner invoked you, so do NOT upsert counsel_runs yourself; your " +
              "session is successful ONLY if the JSON file exists at that exact path when you stop. " +
              "Launch the specialty agents, the CEO, the five lenses, and the chairman per the skill, " +
              "then write the JSON file as the final action."
    # npm installs claude as a .ps1/.cmd shim; Start-Process needs the .cmd.
    $claudeCmd = (Get-Command claude -ErrorAction Stop).Source
    if ($claudeCmd -match '\.ps1$') {
        $cmdShim = $claudeCmd -replace '\.ps1$', '.cmd'
        if (Test-Path $cmdShim) { $claudeCmd = $cmdShim }
        else { throw "claude CLI shim not runnable: $claudeCmd (no .cmd sibling)" }
    }
    # Pass the prompt via STDIN: Start-Process argv quoting through the npm
    # .cmd shim truncates multi-word args (runs 3-4 received one-word prompts).
    $promptFile = Join-Path $counselDir "run$runId-prompt.txt"
    Set-Content -Path $promptFile -Value $prompt -Encoding UTF8 -NoNewline
    Write-Output "launching: claude -p (prompt via stdin, $($prompt.Length) chars)"
    $proc = Start-Process -FilePath $claudeCmd -WorkingDirectory $repoRoot -PassThru -NoNewWindow `
        -ArgumentList @("-p", "--permission-mode", "bypassPermissions") `
        -RedirectStandardInput  $promptFile `
        -RedirectStandardOutput (Join-Path $counselDir "run$runId-stdout.log") `
        -RedirectStandardError  (Join-Path $counselDir "run$runId-stderr.log")
    if (-not $proc.WaitForExit($TimeoutMinutes * 60 * 1000)) {
        $proc.Kill()
        throw "claude -p timed out after $TimeoutMinutes minutes"
    }
    if (-not (Test-Path $outPath)) {
        throw "claude exited (code $($proc.ExitCode)) without writing $outPath - see run$runId-*.log"
    }

    # --- 3. upsert the result ------------------------------------------------
    $json = Get-Content $outPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $patch = @{
        status            = if ($json.PSObject.Properties.Name -contains 'error' -and $json.error) { 'failed' } else { 'complete' }
        exec_summary      = [string] $json.exec_summary
        ceo_brief         = [string] $json.ceo_brief
        lens_outputs      = $json.lens_outputs
        chairman_verdict  = [string] $json.chairman_verdict
        recommended_moves = $json.recommended_moves
        kpi_snapshot      = $json.kpi_snapshot
    }
    if ($json.PSObject.Properties.Name -contains 'error' -and $json.error) {
        $patch.error = [string] $json.error
    }
    Invoke-SbPatch -RunId $runId -Patch $patch
    Write-Output "counsel run $runId $($patch.status): $outPath"
} catch {
    $msg = $_.Exception.Message
    try { Invoke-SbPatch -RunId $runId -Patch @{ status = 'failed'; error = $msg } } catch { }
    Write-Error "counsel run $runId failed: $msg"
    exit 1
}
