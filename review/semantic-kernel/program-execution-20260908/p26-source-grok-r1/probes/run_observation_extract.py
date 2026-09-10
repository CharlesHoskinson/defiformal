#!/usr/bin/env python3
from __future__ import annotations

import datetime
import hashlib
import json
import subprocess
import sys
from pathlib import Path

OUT = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p26-source-grok-r1")
PROBE = OUT / "probes/observation_extract.py"
STDOUT = OUT / "raw/observation_extract.stdout"
STDERR = OUT / "raw/observation_extract.stderr"
RECORD = OUT / "raw/observation_extract.command.json"
CWD = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p26-source-grok-r1-sandbox")
PYTHON = Path(sys.executable).resolve()


def sha256_path(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    argv = [str(PYTHON), str(PROBE)]
    started = datetime.datetime.now(datetime.timezone.utc)
    proc = subprocess.run(argv, cwd=str(CWD), capture_output=True)
    finished = datetime.datetime.now(datetime.timezone.utc)
    STDOUT.write_bytes(proc.stdout)
    STDERR.write_bytes(proc.stderr)
    RECORD.write_text(json.dumps({
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
        "Go_tests_executed": False,
        "Makefile_executed": False,
        "capture_scripts_executed": False,
        "network": False,
    }, indent=2) + "\n")
    sys.stdout.buffer.write(proc.stdout)
    sys.stderr.buffer.write(proc.stderr)
    return proc.returncode


if __name__ == "__main__":
    raise SystemExit(main())
