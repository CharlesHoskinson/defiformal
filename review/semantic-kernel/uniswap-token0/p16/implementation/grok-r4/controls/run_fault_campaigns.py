#!/usr/bin/env python3
"""Run reviewer-style full-campaign faults through the repaired consumer."""
from __future__ import annotations

import json
import os
import shutil
import sys
import time
from pathlib import Path

ROOT = Path("/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908")
sys.path.insert(0, str(ROOT / "scripts/token0_p16"))
import p16_common as c
import source_campaign as s

CTRL = Path(__file__).resolve().parent
EVIDENCE = ROOT / "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r4"
SHIM = CTRL / "fault_recorder.py"
R1_MODES = [
    "missing-receipt",
    "unknown-stdout",
    "stale-receipt",
    "crash-partial",
    "malformed-receipt",
    "timeout",
]


def write_result(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n")


def run_r1(mode: str) -> dict:
    dest = CTRL / mode
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    os.environ["P16_R4_FAULT"] = mode
    c.RECORDER = SHIM
    started = time.monotonic()
    try:
        exit_code = s.mode_intact(dest)
    except Exception as exc:
        exit_code = 1
        (dest / "uncaught.txt").write_text(f"{type(exc).__name__}: {exc}\n")
    seconds = time.monotonic() - started
    score = None
    score_path = dest / "campaign-score.json"
    if score_path.is_file():
        score = json.loads(score_path.read_text())
    c.RECORDER = ROOT / "scripts/token0_p16/record_cmd.py"
    os.environ.pop("P16_R4_FAULT", None)
    return {
        "mode": mode,
        "actual_exit": exit_code,
        "seconds": seconds,
        "score_status": None if score is None else score.get("status"),
        "score_exit": None if score is None else score.get("exit"),
        "mutants": None if score is None else score.get("mutants"),
        "expected_exit": 3,
        "ok": exit_code == 3,
    }


def run_missing_fixture() -> dict:
    dest = CTRL / "missing-fixture"
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    local = dest / "plan-input"
    shutil.copytree(c.PLAN_DIR, local)
    data = json.loads((local / "fixtures.json").read_text())
    data["fixtures"] = [r for r in data["fixtures"] if r["id"] != "P16-I-REM"]
    (local / "fixtures.json").write_text(json.dumps(data, indent=2) + "\n")
    saved = c.PLAN_DIR
    c.PLAN_DIR = local
    started = time.monotonic()
    try:
        exit_code = s.mode_intact(dest)
    except Exception as exc:
        exit_code = 1
        (dest / "uncaught.txt").write_text(f"{type(exc).__name__}: {exc}\n")
    seconds = time.monotonic() - started
    c.PLAN_DIR = saved
    score = None
    if (dest / "campaign-score.json").is_file():
        score = json.loads((dest / "campaign-score.json").read_text())
    return {
        "mode": "missing-fixture",
        "actual_exit": exit_code,
        "seconds": seconds,
        "score_status": None if score is None else score.get("status"),
        "expected_exit": 3,
        "ok": exit_code == 3,
    }


def run_lean_false() -> dict:
    dest = CTRL / "lean-false"
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    original = s.write_source_bindings_lean

    def bad(path, fixtures=None):
        original(path, fixtures)
        text = path.read_text()
        old = "expectedOk := some 39614081257132168796771975168"
        if text.count(old) != 1:
            raise AssertionError(f"expected one P16-ADD literal, found {text.count(old)}")
        path.write_text(text.replace(old, "expectedOk := some 0"))

    s.write_source_bindings_lean = bad
    started = time.monotonic()
    try:
        exit_code = s.mode_intact(dest)
    except Exception as exc:
        exit_code = 1
        (dest / "uncaught.txt").write_text(f"{type(exc).__name__}: {exc}\n")
    seconds = time.monotonic() - started
    s.write_source_bindings_lean = original
    score = None
    if (dest / "campaign-score.json").is_file():
        score = json.loads((dest / "campaign-score.json").read_text())
    return {
        "mode": "lean-false",
        "actual_exit": exit_code,
        "seconds": seconds,
        "score_status": None if score is None else score.get("status"),
        "lean_bindings": None if score is None else score.get("lean_bindings"),
        "expected_exit": 1,
        "ok": exit_code == 1,
    }


def main() -> int:
    rows = []
    for mode in R1_MODES:
        row = run_r1(mode)
        rows.append(row)
        print(json.dumps(row))
    rows.append(run_missing_fixture())
    print(json.dumps(rows[-1]))
    rows.append(run_lean_false())
    print(json.dumps(rows[-1]))
    summary = {
        "rows": rows,
        "all_ok": all(r["ok"] for r in rows),
        "note": "R1 faults must block 3; well-formed false Lean comparison must fail 1",
    }
    write_result(CTRL / "fault-campaign-summary.json", summary)
    write_result(EVIDENCE / "logs" / "fault-campaign-summary.json", summary)
    return 0 if summary["all_ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
