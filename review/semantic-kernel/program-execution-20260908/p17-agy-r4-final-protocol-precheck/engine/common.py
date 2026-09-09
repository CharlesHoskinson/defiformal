#!/usr/bin/env python3
"""Shared engine paths, recorder invocation, and fail-closed scoring.

Extracted from scripts/token0_p16 compile/prestate/score plus frozen record_cmd.py.
Does not edit Token0Probe.sol or record_cmd.py. Empty selections are blocked 3.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

ENGINE_DIR = Path(__file__).resolve().parent
ROOT = ENGINE_DIR.parents[1]
PYTHON = sys.executable
RECORDER = ROOT / "scripts/token0_p16/record_cmd.py"
FROZEN_RECORDER_SHA256 = "31057e00d0ec5e4f5edcfcfe7594d29a86a985ff8c863d5fb9c3bd5d52baaed1"
FROZEN_PROBE = ROOT / "scripts/token0_p16/Token0Probe.sol"
FROZEN_PROBE_SHA256 = "cc12001912e34069e54042ed62be5ecd0c1e57bca7e1c3685fce404e21cb069c"

SOLC_VAULT = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/"
    "p17-source-readiness/solc-linux-amd64-v0.8.21+commit.d9974bed"
)
SOLC_VAULT_SHA256 = "f2857a898be15c69e8de5598dcd3f3e169e94964a0ce9a0bbb1b111f145a81df"
SOLC_TOKEN0 = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/"
    "p16-tools/solc-linux-amd64-v0.7.6+commit.7338295f"
)
SOLC_TOKEN0_SHA256 = "bd69ea85427bf2f4da74cb426ad951dd78db9dfdd01d791208eccc2d4958a6bb"
EVM = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p16-tools/evm")
EVM_SHA256 = "d298ce2c811de089d650ed4f9535c0c58efc72e7adee9b61a40b6c10cc26fb5c"

CAPTURE = (
    ROOT
    / "review/semantic-kernel/program-execution-20260908/p17-source-acquisition"
)
CLOSURE = CAPTURE / "compile-source-closure"
CAPTURE_SRC = CAPTURE / "capture"
SUSDS_SHA256 = "9fe0c713751142e75a1da60ad6c0127d5ad01cb6d24289183ac48b202f3c5d69"
TOKEN0_CAPTURE = (
    ROOT
    / "review/semantic-kernel/program-loop-20260908"
    / "concentrated-liquidity-source-readiness-gpt6-evidence/upstream"
)

_DEFAULT_EVIDENCE = ROOT / "review/semantic-kernel/vault-platform-reuse/p17/implementation/agy-r4"
EVIDENCE = Path(os.environ.get("DEFIFORMAL_EVIDENCE_DIR", str(_DEFAULT_EVIDENCE)))


def validate_model_receipt(receipt: dict, name: str) -> None:
    """Validate a command execution receipt from record_cmd for model bindings."""
    if not isinstance(receipt, dict):
        raise RuntimeError(f"{name} receipt is not a dict: {type(receipt)}")
    if receipt.get("exit") != 0:
        raise RuntimeError(f"{name} failed with exit {receipt.get('exit')}: {receipt.get('reason')}")
    if receipt.get("classification") != "ok":
        raise RuntimeError(f"{name} classification is {receipt.get('classification')!r}, expected 'ok'")
    if receipt.get("valid") is False:
        raise RuntimeError(f"{name} receipt marked valid=False")
    if receipt.get("timeout"):
        raise RuntimeError(f"{name} command timed out")
    if receipt.get("cancelled"):
        raise RuntimeError(f"{name} command cancelled")
    wrapper = receipt.get("_wrapper")
    if isinstance(wrapper, dict):
        if wrapper.get("wrapper_exit") not in (0, None):
            raise RuntimeError(f"{name} wrapper exit {wrapper.get('wrapper_exit')}")
        stdout_p = wrapper.get("stdout_path")
        if stdout_p and not Path(stdout_p).is_file():
            raise RuntimeError(f"{name} wrapper stdout file missing: {stdout_p}")



def choose_run_dir(base_ev: Path) -> Path:
    """Select a unique run/attempt directory, respecting env or auto-incrementing."""
    env_run = os.environ.get("DEFIFORMAL_RUN_DIR")
    if env_run:
        return base_ev / env_run
    if base_ev.name.startswith("attempt-") or base_ev.name.startswith("run-"):
        return base_ev
    idx = 1
    while (base_ev / f"attempt-{idx}").exists():
        idx += 1
    return base_ev / f"attempt-{idx}"


def refuse_nonempty_dir(dir_path: Path) -> Path:
    """Refuse reuse of non-empty evidence directories before writing."""
    p = Path(dir_path).resolve()
    if p.exists() and any(p.iterdir()):
        raise RuntimeError(f"target evidence directory already exists and is non-empty: {p}")
    p.mkdir(parents=True, exist_ok=True)
    return p


SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
ISO_SKEW = timedelta(seconds=1)
RECEIPT_CLASSIFICATIONS = {
    "ok",
    "failure",
    "blocked",
    "timeout_blocked",
    "cancelled",
    "crash",
    "nonzero",
}

VAULT_FIXTURE_IDS = [
    "P17-DEP-D0",
    "P17-MINT-D0",
    "P17-RED-D0",
    "P17-WD-D0",
    "P17-DEP-D1",
    "P17-MINT-D1",
    "P17-RED-D1",
    "P17-WD-D1",
    "P17-DEP-ZERO",
    "P17-DEP-BAD-RECV",
    "P17-DEP-SELF",
    "P17-DEP-TF-BAL",
    "P17-DEP-TF-ALLOW",
    "P17-RED-BAL",
    "P17-RED-ALLOW",
    "P17-DEP-MUL-OVF",
    "P17-RED-DELEGATED",
]

OBSERVED_CELLS = [
    "initialized",
    "chi",
    "ssr",
    "rho",
    "timestamp",
    "susds.totalSupply",
    "susds.balance.S",
    "susds.balance.R",
    "susds.balance.O",
    "susds.balance.P",
    "susds.allowance.O.P",
    "usds.totalSupply",
    "usds.balance.S",
    "usds.balance.R",
    "usds.balance.O",
    "usds.balance.P",
    "usds.balance.vault",
    "usds.allowance.S.vault",
    "usds.allowance.O.vault",
]


class SetupBlocked(Exception):
    def __init__(self, reason: str, extra: dict | None = None) -> None:
        super().__init__(reason)
        self.reason = reason
        self.extra = extra or {}


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


def sha256_text(text: str) -> str:
    return sha256_bytes(text.encode("utf-8"))


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def write_json(path: Path, obj: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2) + "\n")


def load_json(path: Path) -> Any:
    return json.loads(path.read_text())


def python_env() -> dict[str, str]:
    env = os.environ.copy()
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    return env


def blocked(reason: str, extra: dict | None = None) -> dict:
    report = {"status": "blocked", "exit": 3, "reason": reason, "denominator": 0}
    if extra:
        report["extra"] = extra
    return report


def score_rows(rows: list[dict], required_ids: list[str] | None = None) -> dict:
    """P16 r6 fail-closed grammar: 0 nonempty unique ok, 1 semantic false, 3 blocked."""
    if not rows:
        return {
            "status": "blocked",
            "exit": 3,
            "denominator": 0,
            "reason": "empty selection; zero source credit",
        }
    ids = [r.get("id") for r in rows]
    if any(i is None or i == "" for i in ids):
        return {"status": "blocked", "exit": 3, "denominator": len(ids), "reason": "missing fixture id"}
    if len(ids) != len(set(ids)):
        return {"status": "blocked", "exit": 3, "denominator": len(ids), "reason": "duplicated fixture ids"}
    if required_ids is not None and ids != required_ids:
        return {
            "status": "blocked",
            "exit": 3,
            "denominator": len(ids),
            "reason": "row ids are not the exact required set",
            "got": ids,
            "expected": required_ids,
        }
    gates = []
    for row in rows:
        cmp_ = row.get("comparison")
        if not isinstance(cmp_, dict) or "gate" not in cmp_:
            return {
                "status": "blocked",
                "exit": 3,
                "denominator": len(rows),
                "reason": "row missing comparison.gate",
            }
        gate = cmp_["gate"]
        if gate not in ("ok", "fail", "blocked"):
            return {
                "status": "blocked",
                "exit": 3,
                "denominator": len(rows),
                "reason": f"unrecognized gate {gate!r}",
            }
        gates.append(gate)
    blocked_n = sum(1 for g in gates if g == "blocked")
    fail_n = sum(1 for g in gates if g == "fail")
    ok_n = sum(1 for g in gates if g == "ok")
    if blocked_n:
        return {
            "status": "blocked",
            "exit": 3,
            "denominator": len(rows),
            "ok": ok_n,
            "fail": fail_n,
            "blocked": blocked_n,
            "reason": "one or more observations blocked by tool/setup",
        }
    if fail_n:
        return {
            "status": "fail",
            "exit": 1,
            "denominator": len(rows),
            "ok": ok_n,
            "fail": fail_n,
            "blocked": 0,
            "reason": "bound observation disagrees with independent expected",
        }
    return {
        "status": "ok",
        "exit": 0,
        "denominator": len(rows),
        "ok": ok_n,
        "fail": 0,
        "blocked": 0,
        "reason": "nonempty unique fixtures; all independent comparisons hold",
    }


def pin_tool(path: Path, expected_sha: str, label: str) -> dict:
    if not path.is_file():
        raise SetupBlocked(f"missing {label}", {"path": str(path)})
    got = sha256_file(path)
    if got != expected_sha:
        raise SetupBlocked(
            f"{label} hash mismatch",
            {"path": str(path), "got": got, "expected": expected_sha},
        )
    return {"path": str(path), "sha256": got, "label": label}


def record_cmd(
    name: str,
    cmd: list[str],
    cwd: Path,
    out_dir: Path,
    timeout: float | None = None,
    env_pairs: list[str] | None = None,
) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    receipt_path = out_dir / "receipt.json"
    stdout_path = out_dir / "stdout.bin"
    stderr_path = out_dir / "stderr.bin"
    if not RECORDER.is_file():
        report = blocked("frozen record_cmd.py missing", {"path": str(RECORDER)})
        write_json(out_dir / "validation.json", report)
        return report
    rec_sha = sha256_file(RECORDER)
    if rec_sha != FROZEN_RECORDER_SHA256:
        report = blocked(
            "record_cmd.py is not the frozen recorder",
            {"got": rec_sha, "expected": FROZEN_RECORDER_SHA256},
        )
        write_json(out_dir / "validation.json", report)
        return report
    argv = [
        PYTHON,
        "-B",
        str(RECORDER),
        "--name",
        name,
        "--cwd",
        str(cwd),
        "--out",
        str(receipt_path),
        "--stdout-path",
        str(stdout_path),
        "--stderr-path",
        str(stderr_path),
        "--env",
        "PYTHONDONTWRITEBYTECODE=1",
    ]
    if timeout is not None:
        argv.extend(["--timeout", str(timeout)])
    for pair in env_pairs or []:
        argv.extend(["--env", pair])
    argv.append("--")
    argv.extend(cmd)
    proc = subprocess.run(argv, cwd=str(ROOT), env=python_env(), check=False)
    if not receipt_path.is_file():
        report = blocked(
            "missing receipt for the current invocation",
            {"wrapper_exit": proc.returncode, "argv": cmd},
        )
        write_json(out_dir / "validation.json", report)
        return report
    try:
        loaded = load_json(receipt_path)
    except json.JSONDecodeError as exc:
        report = blocked("malformed receipt JSON", {"error": str(exc)})
        write_json(out_dir / "validation.json", report)
        return report
    loaded["_wrapper"] = {
        "wrapper_exit": proc.returncode,
        "receipt_path": str(receipt_path),
        "stdout_path": str(stdout_path),
        "stderr_path": str(stderr_path),
        "recorder_sha256": rec_sha,
        "frozen_recorder_sha256": FROZEN_RECORDER_SHA256,
    }
    if loaded.get("classification") == "timeout_blocked" or loaded.get("timeout"):
        loaded["valid"] = False
        loaded["reason"] = "timeout is blocked, never success"
        return loaded
    if loaded.get("exit") == 124:
        loaded["valid"] = False
        loaded["reason"] = "shell timeout 124 is blocked, never success"
        loaded["classification"] = "timeout_blocked"
        return loaded
    loaded["valid"] = True
    return loaded
