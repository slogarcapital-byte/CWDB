"""Local-mode process launchers: Claude terminals, data pulls, counsel runs.

Everything here is local-only (guarded); the cloud twin never shows the
buttons that call these.

Terminal launch strategy: the prompt is written to a UTF-8 file under
_vault/dashboard/prompts/ and the new terminal runs
    claude "$(Get-Content -Raw <file>)"
because quoting a multi-line prompt through wt.exe -> pwsh -> claude argv
is otherwise unwinnable.
"""

from __future__ import annotations

import re
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

from . import config


def _guard() -> None:
    if config.is_read_only():
        raise PermissionError("Cloud mode cannot launch local processes.")


def _slug(text: str, max_len: int = 40) -> str:
    s = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return s[:max_len] or "task"


def write_prompt_file(title: str, prompt: str) -> Path:
    config.PROMPTS_DIR.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    path = config.PROMPTS_DIR / f"{stamp}-{_slug(title)}.txt"
    path.write_text(prompt, encoding="utf-8")
    return path


def open_claude_terminal(title: str, prompt: str) -> Path:
    """Open a new Windows Terminal in the repo running claude with the prompt."""
    _guard()
    prompt_file = write_prompt_file(title, prompt)
    ps_command = (
        f"claude \"$(Get-Content -Raw '{prompt_file}')\""
    )
    wt = shutil.which("wt.exe") or shutil.which("wt")
    if wt:
        cmd = [wt, "-d", str(config.REPO_ROOT), "pwsh", "-NoExit", "-Command", ps_command]
    else:
        # Fallback: plain pwsh window (Windows Terminal not installed)
        cmd = ["pwsh", "-NoExit", "-Command", ps_command]
        subprocess.Popen(cmd, cwd=str(config.REPO_ROOT),
                         creationflags=subprocess.CREATE_NEW_CONSOLE)
        return prompt_file
    subprocess.Popen(cmd, cwd=str(config.REPO_ROOT))
    return prompt_file


def run_detached(script_relpath: str, args: list[str] | None = None,
                 log_name: str | None = None) -> Path:
    """Run a repo PowerShell script detached; stdout/err -> _vault/dashboard/logs."""
    _guard()
    log_dir = config.VAULT_DIR / "dashboard" / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    log = log_dir / f"{stamp}-{log_name or _slug(script_relpath)}.log"
    script = config.REPO_ROOT / script_relpath
    with open(log, "w", encoding="utf-8") as fh:
        subprocess.Popen(
            ["pwsh", "-NoProfile", "-File", str(script), *(args or [])],
            cwd=str(config.REPO_ROOT), stdout=fh, stderr=subprocess.STDOUT,
            creationflags=subprocess.CREATE_NO_WINDOW,
        )
    return log


def run_qbo_pull() -> Path:
    return run_detached("templates/scripts/pull-qbo-financials.ps1", log_name="qbo-pull")


def run_warehouse_daily() -> Path:
    return run_detached("operations/data-warehouse/scripts/run-daily.ps1", log_name="warehouse-daily")


def run_counsel() -> Path:
    return run_detached("operations/dashboard/run-counsel.ps1", log_name="counsel")
