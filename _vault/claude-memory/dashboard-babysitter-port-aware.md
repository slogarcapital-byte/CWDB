---
name: dashboard-babysitter-port-aware
description: "Mission Control dashboard keep-alive is a port-aware short-lived babysitter, not a direct always-running server task; ghost-Running wedge incident 2026-06-24"
metadata: 
  node_type: memory
  type: project
  originSessionId: 3c365f77-3049-4609-a723-6cd4b81c4136
---

The Mission Control dashboard (`http://127.0.0.1:7717`) keep-alive was redesigned 2026-06-24 after an outage. **Do not "simplify" it back into a single always-running server task.**

**What broke:** The `\CWDB\CWDB-Dashboard` task used to run `dashboard-server.ps1` directly and try to stay running one instance forever. The server process died (silently: launched `-WindowStyle Hidden` with no log), and Task Scheduler wedged in a ghost **State=Running / 0x41301** with no process behind it. Because the 5-min babysitter trigger used `MultipleInstances=IgnoreNew`, it treated the ghost as "already up" and **suppressed every relaunch** — the safety net jammed by the exact failure it was built to catch. Port stayed closed → `ERR_CONNECTION_REFUSED`. Found via: task State=Running but `Get-NetTCPConnection -LocalPort 7717` empty and no `powershell.exe` running `dashboard-server.ps1`.

**The fix (verified end-to-end, incl. kill-test):**
- New `operations/control-plane/dashboard/dashboard-babysitter.ps1` is now the task action. It is **short-lived**: probes the real **port** each tick; if up → log + exit; if down → kill any stale server, archive the prior server log to `.prev`, relaunch `dashboard-server.ps1` detached with stdout/stderr → `_logs/`, confirm, exit. The task returns to **Ready** every tick, so it can never wedge. Liveness is judged by the port, not Scheduler bookkeeping. (Same short-lived shape as why `CWDB-Control-Tick` never wedges.)
- `dashboard-server.ps1` hardened: top-level `trap { Write-Error; exit 1 }` (crash now lands in `_logs/dashboard-server.err.log`) + guarded `GetContext()` accept loop that restarts the listener in place on a sleep/resume `HttpListenerException` instead of dying silently.
- Logs: `operations/control-plane/dashboard/_logs/` (gitignored): `dashboard-babysitter.log`, `dashboard-server.log`, `dashboard-server.err.log`, `*.prev`.
- Recover a wedge manually: `Stop-ScheduledTask -TaskName CWDB-Dashboard -TaskPath \CWDB\; Start-ScheduledTask ...`. Or just re-run `install-dashboard-task.ps1` (idempotent; rotates + deploys + starts).

Changes shipped on `test-branch` (4 files); **not yet committed/pushed** as of 2026-06-24. See [[ps7-invoke-restmethod-non-enumeration]] for the related control-plane normalizer.
