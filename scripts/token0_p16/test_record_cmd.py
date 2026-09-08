#!/usr/bin/env python3
"""Deterministic recorder controls: child 0/1/3, empty/blocked, timeout group reaping."""
from __future__ import annotations

import json
import os
import signal
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RECORDER = Path(__file__).resolve().parent / "record_cmd.py"
DESCENDANT = Path(__file__).resolve().parent / "timeout_descendant.py"
EVIDENCE = (
    ROOT
    / "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r2/logs/recorder-controls"
)
PYTHON = sys.executable


def alive(pid: int) -> bool:
    if pid <= 0:
        return False
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    return True


def run_recorder(name: str, cmd: list[str], timeout: float | None = None) -> tuple[int, dict]:
    out_dir = EVIDENCE / name
    out_dir.mkdir(parents=True, exist_ok=True)
    receipt = out_dir / "receipt.json"
    stdout_path = out_dir / "stdout.bin"
    stderr_path = out_dir / "stderr.bin"
    argv = [
        PYTHON,
        "-B",
        str(RECORDER),
        "--name",
        name,
        "--cwd",
        str(ROOT),
        "--out",
        str(receipt),
        "--stdout-path",
        str(stdout_path),
        "--stderr-path",
        str(stderr_path),
    ]
    if timeout is not None:
        argv.extend(["--timeout", str(timeout)])
    argv.append("--")
    argv.extend(cmd)
    proc = subprocess.run(argv, cwd=str(ROOT), check=False, capture_output=True)
    if not receipt.is_file():
        raise AssertionError(f"{name}: missing receipt; wrapper_exit={proc.returncode}")
    data = json.loads(receipt.read_text())
    data["_wrapper_exit"] = proc.returncode
    data["_wrapper_stdout"] = proc.stdout.decode("utf-8", "replace")
    data["_wrapper_stderr"] = proc.stderr.decode("utf-8", "replace")
    (out_dir / "wrapper.json").write_text(json.dumps({
        "wrapper_exit": proc.returncode,
        "receipt_exit": data.get("exit"),
        "timeout": data.get("timeout"),
        "classification": data.get("classification"),
        "argv": data.get("argv"),
        "cwd": data.get("cwd"),
        "start_utc": data.get("start_utc"),
        "end_utc": data.get("end_utc"),
        "stdout_sha256": data.get("stdout_sha256"),
        "stderr_sha256": data.get("stderr_sha256"),
        "pgid": data.get("pgid"),
    }, indent=2) + "\n")
    return proc.returncode, data


def expect_child(name: str, child_exit: int) -> None:
    wrapper, data = run_recorder(name, [PYTHON, "-c", f"import sys; sys.exit({child_exit})"])
    if data.get("timeout") is not False:
        raise AssertionError(f"{name}: timeout must be false, got {data.get('timeout')}")
    if data.get("exit") != child_exit:
        raise AssertionError(f"{name}: receipt exit {data.get('exit')} != {child_exit}")
    if wrapper != child_exit:
        raise AssertionError(f"{name}: wrapper exit {wrapper} != child {child_exit}")
    classification = data.get("classification")
    if classification in (None, ""):
        raise AssertionError(f"{name}: classification must be non-null")
    if not data.get("argv"):
        raise AssertionError(f"{name}: argv missing")
    if not data.get("cwd"):
        raise AssertionError(f"{name}: cwd missing")
    if not data.get("start_utc") or not data.get("end_utc"):
        raise AssertionError(f"{name}: UTC timestamps missing")
    if data.get("stdout_sha256") is None or data.get("stderr_sha256") is None:
        raise AssertionError(f"{name}: hashes missing")


def expect_empty_blocked() -> None:
    name = "empty-cmd"
    out_dir = EVIDENCE / name
    out_dir.mkdir(parents=True, exist_ok=True)
    receipt = out_dir / "receipt.json"
    argv = [
        PYTHON, "-B", str(RECORDER),
        "--name", name,
        "--cwd", str(ROOT),
        "--out", str(receipt),
        "--stdout-path", str(out_dir / "stdout.bin"),
        "--stderr-path", str(out_dir / "stderr.bin"),
        "--",
    ]
    proc = subprocess.run(argv, cwd=str(ROOT), check=False, capture_output=True)
    if proc.returncode != 3:
        raise AssertionError(f"empty-cmd: wrapper {proc.returncode} != 3")
    (out_dir / "wrapper.json").write_text(json.dumps({
        "wrapper_exit": proc.returncode,
        "stdout": proc.stdout.decode("utf-8", "replace"),
        "stderr": proc.stderr.decode("utf-8", "replace"),
        "receipt_exists": receipt.is_file(),
    }, indent=2) + "\n")


def expect_timeout_kills_owned_descendant() -> None:
    name = "timeout-descendant"
    out_dir = EVIDENCE / name
    out_dir.mkdir(parents=True, exist_ok=True)
    pid_path = out_dir / "grandchild.pid"
    if pid_path.exists():
        pid_path.unlink()
    outsider = subprocess.Popen([PYTHON, "-c", "import time; time.sleep(20)"])
    try:
        wrapper, data = run_recorder(
            name,
            [PYTHON, "-B", str(DESCENDANT), str(pid_path)],
            timeout=0.3,
        )
        if wrapper != 3:
            raise AssertionError(f"timeout-descendant: wrapper {wrapper} != 3")
        if data.get("timeout") is not True:
            raise AssertionError(f"timeout-descendant: timeout {data.get('timeout')} != true")
        if data.get("classification") in (None, ""):
            raise AssertionError("timeout-descendant: classification must be non-null")
        if data.get("exit") is not None:
            raise AssertionError(
                f"timeout-descendant: child exit must be null if unknown, got {data.get('exit')}"
            )
        deadline = time.monotonic() + 2.0
        grandchild = None
        while time.monotonic() < deadline:
            if pid_path.is_file() and pid_path.read_text().strip():
                grandchild = int(pid_path.read_text().strip())
                break
            time.sleep(0.05)
        if grandchild is None:
            raise AssertionError("timeout-descendant: grandchild pid was not recorded")
        time.sleep(0.2)
        if alive(grandchild):
            raise AssertionError(
                f"timeout-descendant: owned grandchild {grandchild} still alive after timeout"
            )
        if not alive(outsider.pid):
            raise AssertionError(
                "timeout-descendant: recorder killed a process outside its owned group"
            )
    finally:
        if outsider.poll() is None:
            outsider.send_signal(signal.SIGKILL)
            outsider.wait(timeout=2)


def main() -> int:
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    failures: list[str] = []
    for name, code in (("child-0", 0), ("child-1", 1), ("child-3", 3)):
        try:
            expect_child(name, code)
        except Exception as exc:
            failures.append(f"{name}: {exc}")
    try:
        expect_empty_blocked()
    except Exception as exc:
        failures.append(f"empty-cmd: {exc}")
    try:
        expect_timeout_kills_owned_descendant()
    except Exception as exc:
        failures.append(f"timeout-descendant: {exc}")
    summary = {
        "denominator": 5,
        "failures": failures,
        "passed": 5 - len(failures),
    }
    (EVIDENCE / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps(summary, indent=2))
    if failures:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
