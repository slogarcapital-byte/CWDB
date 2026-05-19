# vault-sync.ps1
# Mirrors Claude Code auto-memory into _vault/claude-memory/ with Obsidian
# frontmatter injected and markdown links rewritten as wikilinks. Idempotent.
#
# Called by the /vault-sync command. Safe to run on-demand.

$ErrorActionPreference = 'Stop'

$vaultRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$source = Join-Path $env:USERPROFILE '.claude\projects\C--Users-jslog-OneDrive-Desktop-Slogars-CPA-Slogar-Capital-Claude-Projects-CWDB\memory'
$dest = Join-Path (Join-Path $vaultRoot '_vault') 'claude-memory'
$today = Get-Date -Format 'yyyy-MM-dd'

if (-not (Test-Path $source)) {
    Write-Error "Source memory dir not found: $source"
    exit 1
}
if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
}

function Get-MemoryType {
    param([string]$FileName, [string]$SourceType)
    $base = [IO.Path]::GetFileNameWithoutExtension($FileName)
    if ($base -eq 'MEMORY') { return 'index' }
    $lower = $base.ToLower()
    foreach ($prefix in 'feedback', 'project', 'reference', 'user', 'workflow') {
        if ($lower.StartsWith($prefix)) { return $prefix }
    }
    if ($SourceType) {
        $t = $SourceType.Trim().Trim('"','''')
        if ($t -in 'user','feedback','project','reference','workflow') { return $t }
    }
    return 'reference'
}

function Split-Frontmatter {
    param([string]$Text)
    $result = @{ hasFrontmatter = $false; fm = [ordered]@{}; body = $Text }
    if (-not ($Text.StartsWith("---`n") -or $Text.StartsWith("---`r`n"))) {
        return $result
    }
    $lines = $Text -split "`r?`n"
    $closeIdx = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -eq '---') { $closeIdx = $i; break }
    }
    if ($closeIdx -lt 0) { return $result }

    $fm = [ordered]@{}
    for ($i = 1; $i -lt $closeIdx; $i++) {
        $ln = $lines[$i]
        if ($ln -match '^([A-Za-z0-9_\-]+):\s*(.*)$') {
            $fm[$Matches[1]] = $Matches[2]
        }
    }
    $body = ($lines[($closeIdx + 1)..($lines.Count - 1)] -join "`n")
    return @{ hasFrontmatter = $true; fm = $fm; body = $body }
}

function Format-Frontmatter {
    param([System.Collections.Specialized.OrderedDictionary]$Fm, [string[]]$Tags)
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('---')
    foreach ($key in $Fm.Keys) {
        if ($key -eq 'tags') { continue }
        [void]$sb.AppendLine("${key}: $($Fm[$key])")
    }
    [void]$sb.AppendLine('tags:')
    foreach ($t in $Tags) {
        [void]$sb.AppendLine("  - $t")
    }
    [void]$sb.AppendLine('---')
    return $sb.ToString()
}

function Rewrite-Links {
    param([string]$Body)
    # [text](file.md) or [text](file.md#anchor) -> [[basename|text]] (or [[basename]] if text == basename)
    # Skip http/https/mailto targets.
    $pattern = '\[([^\]]+)\]\(([^)\s]+\.md(?:#[^)]+)?)\)'
    return [regex]::Replace($Body, $pattern, {
        param($m)
        $text = $m.Groups[1].Value
        $target = $m.Groups[2].Value
        if ($target -match '^(https?:|mailto:)') { return $m.Value }
        $anchor = ''
        if ($target.Contains('#')) {
            $parts = $target.Split('#', 2)
            $target = $parts[0]
            $anchor = '#' + $parts[1]
        }
        $base = [IO.Path]::GetFileNameWithoutExtension($target)
        $link = "$base$anchor"
        if ($text -eq $base) { return "[[$link]]" }
        return "[[$link|$text]]"
    })
}

function Sync-OneFile {
    param([System.IO.FileInfo]$Src)

    $raw = Get-Content -Path $Src.FullName -Raw -Encoding UTF8
    if (-not $raw) { $raw = '' }
    $split = Split-Frontmatter -Text $raw

    $srcFm = $split.fm
    $body = $split.body
    $memoryType = Get-MemoryType -FileName $Src.Name -SourceType ([string]$srcFm['type'])

    # Build destination frontmatter. Preserve source fields, override/add Obsidian ones.
    $destFm = [ordered]@{}
    foreach ($k in $srcFm.Keys) {
        if ($k -in 'tags','type','memory_type','source','updated','created','title') { continue }
        $destFm[$k] = $srcFm[$k]
    }
    $title = if ($srcFm.Contains('name') -and $srcFm['name']) { $srcFm['name'] } else { $Src.BaseName.Replace('_',' ').Replace('-',' ') }
    $destFm['title']       = $title
    $destFm['type']        = 'memory'
    $destFm['memory_type'] = $memoryType
    $created = if ($srcFm.Contains('created') -and $srcFm['created']) { $srcFm['created'] } else { $today }
    $destFm['created']     = $created
    $destFm['updated']     = $today
    $destFm['source']      = ($Src.FullName -replace '\\','/')

    $tags = @('type/memory', "memory/$memoryType")
    $fmText = Format-Frontmatter -Fm $destFm -Tags $tags

    $newBody = Rewrite-Links -Body $body
    $newBody = $newBody.TrimStart("`n","`r").TrimEnd()
    $newText = $fmText + $newBody + "`n"

    $destPath = Join-Path $dest $Src.Name

    # Idempotency: compare modulo `updated:` line
    if (Test-Path $destPath) {
        $old = Get-Content -Path $destPath -Raw -Encoding UTF8
        $oldNorm = $old -replace '(?m)^updated: .*$','updated:'
        $newNorm = $newText -replace '(?m)^updated: .*$','updated:'
        if ($oldNorm -eq $newNorm) { return 'skipped' }
    }

    Set-Content -Path $destPath -Value $newText -Encoding UTF8 -NoNewline
    return 'written'
}

$written = 0
$skipped = 0
$failed  = @()

Get-ChildItem -Path $source -Filter '*.md' -File | ForEach-Object {
    try {
        $result = Sync-OneFile -Src $_
        if ($result -eq 'written') { $written++ } else { $skipped++ }
    } catch {
        $failed += "$($_.Name): $($_.Exception.Message)"
    }
}

# Orphan detection: files in dest that no longer exist in source (exclude _README.md, .last-sync, our own files)
$sourceNames = Get-ChildItem -Path $source -Filter '*.md' -File | Select-Object -ExpandProperty Name
$orphans = @()
Get-ChildItem -Path $dest -Filter '*.md' -File | ForEach-Object {
    if ($_.Name -eq '_README.md') { return }
    if ($_.Name -notin $sourceNames) { $orphans += $_.Name }
}

# Write last-sync marker
Set-Content -Path (Join-Path $dest '.last-sync') -Value (Get-Date -Format 'o') -Encoding UTF8

Write-Host "vault-sync: $written written, $skipped unchanged"
if ($orphans.Count -gt 0) {
    Write-Host ("orphans (in dest, not in source): " + ($orphans -join ', '))
}
if ($failed.Count -gt 0) {
    Write-Host "failures:"
    $failed | ForEach-Object { Write-Host "  $_" }
}
