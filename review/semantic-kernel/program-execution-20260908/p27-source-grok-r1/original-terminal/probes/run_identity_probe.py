#!/usr/bin/env python3
"""Recorded wrapper for identity_probe.py. Does not execute solc, yarn, or capture scripts."""
from __future__ import annotations

import datetime
import hashlib
import json
import subprocess
import sys
from pathlib import Path

OUT = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p27-source-grok-r1")
PROBE = OUT / "probes/identity_probe.py"
STDOUT = OUT / "raw/identity_probe.stdout"
STDERR = OUT / "raw/identity_probe.stderr"
RECORD = OUT / "raw/identity_probe.command.json"
CWD = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p27-source-grok-r1-sandbox")
PYTHON = Path(sys.executable).resolve()


def sha256_path(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    STDOUT.parent.mkdir(parents=True, exist_ok=True)
    argv = [str(PYTHON), str(PROBE)]
    started = datetime.datetime.now(datetime.timezone.utc)
    proc = subprocess.run(argv, cwd=str(CWD), capture_output=True)
    finished = datetime.datetime.now(datetime.timezone.utc)
    STDOUT.write_bytes(proc.stdout)
    STDERR.write_bytes(proc.stderr)
    record = {
        "argv": argv,
        "cwd": str(CWD),
        "started_utc": started.isoformat(),
        "finished_utc": finished.isoformat(),
        "exit": proc.returncode,
        "python_executable": str(PYTHON),
        "python_sha256": sha256_path(PYTHON),
        "script_path": str(PROBE),
        "script_sha256": sha256_path(PROBE),
        "stdout_path": str(STDOUT),
        "stdout_sha256": sha256_path(STDOUT),
        "stderr_path": str(STDERR),
        "stderr_sha256": sha256_path(STDERR),
        "stdout_bytes": STDOUT.stat().st_size,
        "stderr_bytes": STDERR.stat().st_size,
        "tool": "run_terminal_command",
        "source_execution": False,
        "solc_executed": False,
        "yarn_or_npm_executed": False,
        "hardhat_executed": False,
        "tests_executed": False,
        "capture_scripts_executed": False,
        "network": False,
    }
    RECORD.write_text(json.dumps(record, indent=2) + "\n")
    sys.stdout.buffer.write(proc.stdout)
    sys.stderr.buffer.write(proc.stderr)
    return proc.returncode


if __name__ == "__main__":
    raise SystemExit(main())
