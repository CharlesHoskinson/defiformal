#!/usr/bin/env python3
"""Record one command with argv/cwd/start/end/exit and raw stdout/stderr hashes.

Reviewer-local recorder. Does not invoke author R24 recorder.
"""
from __future__ import annotations

import hashlib
import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

OUT = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-module-tree-grok-r1"
)
INDEX = OUT / "logs" / "command-index.jsonl"


def sha256_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def sha256_file(p: Path) -> str:
    return sha256_bytes(p.read_bytes())


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def run_cmd(
    cmd_id: str,
    argv: list[str],
    cwd: str | Path,
    *,
    env: dict[str, str] | None = None,
    timeout: int | None = None,
    source: str = "reviewer",
    tool: str = "unknown",
    probe: str | None = None,
    note: str | None = None,
) -> dict:
    cwd = str(cwd)
    log_dir = OUT / "logs" / cmd_id
    log_dir.mkdir(parents=True, exist_ok=True)
    stdout_path = log_dir / "stdout"
    stderr_path = log_dir / "stderr"
    meta_path = log_dir / "meta.json"
    started = utc_now()
    run_env = os.environ.copy()
    if env:
        run_env.update(env)
    try:
        proc = subprocess.run(
            argv,
            cwd=cwd,
            env=run_env,
            capture_output=True,
            timeout=timeout,
        )
        timed_out = False
        exit_code = proc.returncode
        stdout = proc.stdout
        stderr = proc.stderr
    except subprocess.TimeoutExpired as e:
        timed_out = True
        exit_code = 124
        stdout = e.stdout or b""
        stderr = e.stderr or b""
    finished = utc_now()
    stdout_path.write_bytes(stdout)
    stderr_path.write_bytes(stderr)
    credit = bool(exit_code == 0 and not timed_out)
    rec = {
        "id": cmd_id,
        "argv": argv,
        "cwd": cwd,
        "start": started,
        "end": finished,
        "exit": exit_code,
        "timed_out": timed_out,
        "source": source,
        "tool": tool,
        "probe": probe,
        "rawstdout_sha256": sha256_bytes(stdout),
        "rawstderr_sha256": sha256_bytes(stderr),
        "stdout_path": str(stdout_path.relative_to(OUT)),
        "stderr_path": str(stderr_path.relative_to(OUT)),
        "stdout_bytes": len(stdout),
        "stderr_bytes": len(stderr),
        "credit": credit,
        "note": note,
        "model_identity": "unknown",
        "returned_model": "unknown",
    }
    meta_path.write_text(json.dumps(rec, indent=2) + "\n")
    INDEX.parent.mkdir(parents=True, exist_ok=True)
    with INDEX.open("a") as f:
        f.write(json.dumps(rec) + "\n")
    return rec
