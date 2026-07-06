---
name: feedback-powershell-script-portability
description: "PowerShell 5.1 gotchas to avoid when writing .ps1 files Jim will run on Windows. Em-dashes, PSScriptRoot in param defaults, escape sequences."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e1825064-98f6-4cf0-8cd2-b3f72618d47b
---

When writing .ps1 files for this Windows environment, the default executor is Windows PowerShell 5.1 (powershell.exe), not PowerShell 7. Three traps to avoid:

**1. No non-ASCII characters in .ps1 source.**
- Why: PS5.1 reads BOM-less UTF-8 files as Windows-1252 by default. UTF-8 byte sequences for em-dash (—, `E2 80 94`), curly quotes, ellipsis, etc. get split into 3 individual CP1252 bytes, one of which is often a closing curly quote (`"` = 0x94). That prematurely terminates the next string literal and the parser dies several lines later with a confusing "string missing terminator" error.
- How to apply: stick to ASCII in all .ps1 files. Replace `—` with `.` or `:`. Replace curly quotes with straight. Replace `→` with `->`. This is also reinforced by [[feedback-no-em-dashes]] (Jim's standing rule against em-dashes everywhere).

**2. `$PSScriptRoot` is empty during param-block default evaluation.**
- Why: Quirk of PS5.1. When a script is invoked via `powershell.exe -File`, $PSScriptRoot is set for the script body but NOT for `param()` default-value expressions, which evaluate before the body's context fully attaches. So `param([string] $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path)` throws "Cannot bind argument to parameter 'Path' because it is an empty string."
- How to apply: move the resolution out of the param default into the script body. If you also want the param to be settable from the caller, use `param([string] $RepoRoot)` and then `if (-not $RepoRoot) { $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }; $RepoRoot = (Resolve-Path (Join-Path $scriptDir "..\..\..")).Path }`. Or have the caller pass `-RepoRoot $known` so the child never touches `$PSScriptRoot` at all.

**3. The escape sequence `` `"" `` (backtick-quote, quote) trips the PS5.1 parser in some contexts.**
- Why: The lexer can interpret it as "literal quote + closing quote + extra junk" rather than "literal quote + closing quote" depending on surrounding tokens (especially with line-continuation backticks nearby).
- How to apply: when building a string that needs embedded double quotes (e.g. arguments to `New-ScheduledTaskAction -Argument`), prefer string concatenation: `$arg = '-File "' + $path + '"'`. Avoid `"-File `"$path`""` patterns. Single-quoted strings + concatenation are bulletproof.

All three were hit on 2026-06-03 while setting up [[cron-warehouse-daily]]. They are reproducible on Jim's Windows 11 box with default PowerShell 5.1.
