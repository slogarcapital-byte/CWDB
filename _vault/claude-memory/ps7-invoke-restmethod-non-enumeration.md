---
name: ps7-invoke-restmethod-non-enumeration
description: "PS7 Invoke-RestMethod returns JSON arrays un-enumerated; @(direct-call) nests, .Count lies, [0] returns the inner array. Use Get-SupabaseRows in control-plane code."
metadata: 
  node_type: memory
  type: project
  originSessionId: f0a6a325-85dd-4a33-beca-b703ac2d6909
---

On Jim's machine (PowerShell 7.x), `Invoke-RestMethod` returns a PostgREST JSON array as a SINGLE un-enumerated `Object[]` item. Verified empirically 2026-06-10 via the dashboard's `/api/state` serializing `[[]]` for an empty table.

**The trap (asymmetric):**
- Direct-call wrap `@(Invoke-SupabaseSelect ...)` NESTS: outer Count is always 1 (even for empty results), `[0]` yields the inner row-array, JSON serialization produces `[[...]]`/`[{...}]`.
- Plain assignment `$x = Invoke-SupabaseSelect ...` captures FLAT (accidentally correct): empty → len-0 Object[], N rows → len-N.
- PowerShell member enumeration MASKS the nesting for single-row property access (`@(f)[0].col` works), so PS-side tests pass while JSON consumers (browser JS) break and `.Count` checks lie.

**Real bug it caused:** `control-tick.ps1`'s workAvail probes (`@(select...limit=1).Count -gt 0`) were ALWAYS true → the `no_work_available` gate branch was dead code until fixed 2026-06-10 (commit `e6c36a1`).

**How to apply:** in control-plane code, never call `Invoke-SupabaseSelect` directly; use `Get-SupabaseRows` (control-db.ps1) which emits one pipeline object per row, then wrap call sites with `@(...)`. Functions returning arrays should let the pipeline enumerate (`return @($resp)` enumerates on output; callers re-collect with `@(...)`); remember `return @()` emits NOTHING (assignment gives $null) — callers must `@()`-wrap. The warehouse helper `templates/scripts/load-supabase.ps1` stays unmodified by policy; its ingest callers use plain assignment (the accidentally-safe form).
