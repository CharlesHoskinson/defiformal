#!/usr/bin/env python3
"""Record a command with argv, cwd, UTC, full stdout/stderr, exit, and tool hashes.

The child is started in an owned session/process group. Timeout and cancellation
terminate and reap that group only. Wrapper exit preserves genuine child 0/1/3.
Timeout is blocked 3 with a non-null classification and child exit null.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import signal
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str | None:
    if not path.is_file():
        return None
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def resolve_tool(argv0: str, cwd: Path) -> dict:
    path = Path(argv0)
    if not path.is_absolute():
        found = shutil.which(argv0)
        path = Path(found) if found else (cwd / argv0)
    resolved = path.resolve() if path.exists() else path
    return {
        "argv0": argv0,
        "resolved": str(resolved),
        "exists": resolved.is_file(),
        "sha256": sha256_file(resolved) if resolved.is_file() else None,
        "mode": oct(resolved.stat().st_mode) if resolved.exists() else None,
    }


def classify(timeout: bool, cancelled: bool, exit_code: int | None) -> str:
    if timeout:
        return "timeout_blocked"
    if cancelled:
        return "cancelled"
    if exit_code is None or exit_code < 0:
        return "crash"
    if exit_code == 0:
        return "ok"
    if exit_code == 1:
        return "failure"
    if exit_code == 3:
        return "blocked"
    return "nonzero"


def wrapper_exit(timeout: bool, cancelled: bool, exit_code: int | None) -> int:
    if timeout or cancelled:
        return 3
    if exit_code is None or exit_code < 0:
        return 3
    return exit_code


def kill_own_process_group(pgid: int) -> None:
    if pgid is None or pgid <= 1:
        return
    for sig in (signal.SIGTERM, signal.SIGKILL):
        try:
            os.killpg(pgid, sig)
        except ProcessLookupError:
            return
        except PermissionError:
            return
        if sig == signal.SIGTERM:
            deadline = time.monotonic() + 0.5
            while time.monotonic() < deadline:
                try:
                    os.killpg(pgid, 0)
                except ProcessLookupError:
                    return
                time.sleep(0.02)


def reap_own_process_group(pgid: int) -> None:
    if pgid is None or pgid <= 1:
        return
    deadline = time.monotonic() + 1.0
    while time.monotonic() < deadline:
        try:
            pid, _status = os.waitpid(-pgid, os.WNOHANG)
        except ChildProcessError:
            return
        except OSError:
            return
        if pid == 0:
            try:
                os.killpg(pgid, 0)
            except ProcessLookupError:
                return
            except PermissionError:
                return
            time.sleep(0.02)
            continue
    while True:
        try:
            pid, _status = os.waitpid(-pgid, os.WNOHANG)
        except (ChildProcessError, OSError):
            return
        if pid == 0:
            return


def run_owned(cmd: list[str], cwd: Path, env: dict, timeout: float | None) -> tuple[bool, bool, int | None, bytes, bytes, int | None]:
    proc = subprocess.Popen(
        cmd,
        cwd=str(cwd),
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        start_new_session=True,
    )
    try:
        pgid = os.getpgid(proc.pid)
    except ProcessLookupError:
        pgid = proc.pid
    if pgid <= 1:
        pgid = proc.pid
    timed_out = False
    cancelled = False
    stdout = b""
    stderr = b""
    exit_code: int | None = None

    def _on_signal(signum, _frame):
        nonlocal cancelled
        cancelled = True
        kill_own_process_group(pgid)
        raise KeyboardInterrupt

    prev_int = signal.getsignal(signal.SIGINT)
    prev_term = signal.getsignal(signal.SIGTERM)
    signal.signal(signal.SIGINT, _on_signal)
    signal.signal(signal.SIGTERM, _on_signal)
    try:
        try:
            stdout, stderr = proc.communicate(timeout=timeout)
            exit_code = proc.returncode
        except subprocess.TimeoutExpired:
            timed_out = True
            kill_own_process_group(pgid)
            try:
                stdout, stderr = proc.communicate(timeout=1)
            except subprocess.TimeoutExpired:
                try:
                    proc.kill()
                except OSError:
                    pass
                stdout, stderr = proc.communicate()
            exit_code = None
        except KeyboardInterrupt:
            cancelled = True
            kill_own_process_group(pgid)
            try:
                stdout, stderr = proc.communicate(timeout=1)
            except Exception:
                stdout = stdout or b""
                stderr = stderr or b""
            exit_code = None
    finally:
        signal.signal(signal.SIGINT, prev_int)
        signal.signal(signal.SIGTERM, prev_term)
        if proc.poll() is None:
            kill_own_process_group(pgid)
            try:
                proc.wait(timeout=1)
            except subprocess.TimeoutExpired:
                try:
                    proc.kill()
                except OSError:
                    pass
        reap_own_process_group(pgid)
    return timed_out, cancelled, exit_code, stdout or b"", stderr or b"", pgid


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True)
    parser.add_argument("--cwd", required=True)
    parser.add_argument("--out", required=True, help="JSON receipt path")
    parser.add_argument("--stdout-path", required=True)
    parser.add_argument("--stderr-path", required=True)
    parser.add_argument("--timeout", type=float, default=None)
    parser.add_argument("--env", action="append", default=[], help="KEY=VALUE extras")
    parser.add_argument("cmd", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    cmd = args.cmd
    if cmd and cmd[0] == "--":
        cmd = cmd[1:]
    if not cmd:
        print("missing command", file=sys.stderr)
        return 3
    cwd = Path(args.cwd).resolve()
    if not cwd.is_dir():
        print(f"cwd missing: {cwd}", file=sys.stderr)
        return 3
    env = os.environ.copy()
    for item in args.env:
        if "=" not in item:
            print(f"bad --env {item}", file=sys.stderr)
            return 3
        k, v = item.split("=", 1)
        env[k] = v
    start = utc_now()
    timed_out, cancelled, exit_code, stdout, stderr, pgid = run_owned(
        cmd, cwd, env, args.timeout
    )
    end = utc_now()
    classification = classify(timed_out, cancelled, exit_code)
    stdout_path = Path(args.stdout_path)
    stderr_path = Path(args.stderr_path)
    stdout_path.parent.mkdir(parents=True, exist_ok=True)
    stderr_path.parent.mkdir(parents=True, exist_ok=True)
    stdout_path.write_bytes(stdout)
    stderr_path.write_bytes(stderr)
    receipt = {
        "name": args.name,
        "argv": cmd,
        "cwd": str(cwd),
        "start_utc": start,
        "end_utc": end,
        "timeout": timed_out,
        "cancelled": cancelled,
        "classification": classification,
        "exit": exit_code,
        "pgid": pgid,
        "stdout_path": str(stdout_path),
        "stderr_path": str(stderr_path),
        "stdout_sha256": sha256_bytes(stdout),
        "stderr_sha256": sha256_bytes(stderr),
        "stdout_bytes": len(stdout),
        "stderr_bytes": len(stderr),
        "tool": resolve_tool(cmd[0], cwd),
        "python": sys.version,
        "record_cmd_sha256": sha256_file(Path(__file__).resolve()),
    }
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps({
        "name": args.name,
        "exit": exit_code,
        "timeout": timed_out,
        "classification": classification,
    }))
    return wrapper_exit(timed_out, cancelled, exit_code)


if __name__ == "__main__":
    raise SystemExit(main())
