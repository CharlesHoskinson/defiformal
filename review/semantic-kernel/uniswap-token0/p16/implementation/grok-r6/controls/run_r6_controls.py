#!/usr/bin/env python3
"""Focused r6 real-consumer controls. Diagnostic only; not a production recorder."""
from __future__ import annotations

import json
import os
import shutil
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908")
sys.path.insert(0, str(ROOT / "scripts/token0_p16"))
import p16_common as c  # noqa: E402
import source_campaign as s  # noqa: E402

CTRL = Path(__file__).resolve().parent
RECEIPT_RELAY = CTRL / "receipt_fault_relay.py"
RUNTIME_RELAY = CTRL / "runtime_extra_relay.py"


def write_result(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n")


def _score(dest: Path) -> dict | None:
    path = dest / "campaign-score.json"
    if path.is_file():
        return json.loads(path.read_text())
    return None


def run_intact_like(dest: Path, mutate) -> dict:
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    started = time.monotonic()
    start_utc = datetime.now(timezone.utc).isoformat()
    try:
        exit_code = mutate()
    except Exception as exc:
        exit_code = 1
        (dest / "uncaught.txt").write_text(f"{type(exc).__name__}: {exc}\n")
    seconds = time.monotonic() - started
    score = _score(dest)
    wrapper = {
        "actual_exit": exit_code,
        "seconds": seconds,
        "start_utc": start_utc,
        "end_utc": datetime.now(timezone.utc).isoformat(),
        "score_status": None if score is None else score.get("status"),
        "score_exit": None if score is None else score.get("exit"),
        "mutants": None if score is None else score.get("mutants"),
        "lean_bindings": None if score is None else score.get("lean_bindings"),
        "lean_runtime": None if score is None else score.get("lean_runtime"),
        "score": score,
    }
    write_result(dest / "wrapper-receipt.json", wrapper)
    return wrapper


def run_lean_emit(mode: str) -> dict:
    dest = CTRL / mode
    original = s.write_source_bindings_lean

    def corrupt(path, fixtures=None):
        original(path, fixtures)
        if mode == "compiler-nonzero":
            path.write_text(path.read_text() + "\n#check P16ReviewNonexistentDeclaration\n")
        elif mode == "malformed-extra":
            path.write_text(path.read_text() + '\n#eval IO.println "P16-ADD malformed extra protocol row"\n')

    s.write_source_bindings_lean = corrupt
    try:
        row = run_intact_like(dest, lambda: s.mode_intact(dest))
    finally:
        s.write_source_bindings_lean = original
    row["mode"] = mode
    row["expected_exit"] = 3
    row["ok"] = row["actual_exit"] == 3
    return row


def run_lean_false() -> dict:
    dest = CTRL / "lean-false"
    original = s.write_source_bindings_lean

    def bad(path, fixtures=None):
        original(path, fixtures)
        text = path.read_text()
        old = "expectedOk := some 39614081257132168796771975168"
        if text.count(old) != 1:
            raise AssertionError(f"expected one P16-ADD literal, found {text.count(old)}")
        path.write_text(text.replace(old, "expectedOk := some 0"))

    s.write_source_bindings_lean = bad
    try:
        row = run_intact_like(dest, lambda: s.mode_intact(dest))
    finally:
        s.write_source_bindings_lean = original
    row["mode"] = "lean-false"
    row["expected_exit"] = 1
    row["ok"] = row["actual_exit"] == 1
    return row


def run_receipt(mode: str) -> dict:
    dest = CTRL / mode
    saved = c.RECORDER
    os.environ["P16_R6_RECEIPT_FAULT"] = mode
    c.RECORDER = RECEIPT_RELAY
    try:
        row = run_intact_like(dest, lambda: s.mode_intact(dest))
    finally:
        c.RECORDER = saved
        os.environ.pop("P16_R6_RECEIPT_FAULT", None)
    row["mode"] = mode
    row["expected_exit"] = 3
    row["ok"] = row["actual_exit"] == 3
    return row


def run_runtime_extra() -> dict:
    dest = CTRL / "runtime-extra"
    saved = c.RECORDER
    c.RECORDER = RUNTIME_RELAY
    try:
        row = run_intact_like(dest, lambda: s.mode_intact(dest))
    finally:
        c.RECORDER = saved
    row["mode"] = "runtime-extra"
    row["expected_exit"] = 3
    row["ok"] = row["actual_exit"] == 3
    return row


def main() -> int:
    rows = []
    for mode in ("compiler-nonzero", "malformed-extra"):
        row = run_lean_emit(mode)
        rows.append(row)
        print(json.dumps({"mode": row["mode"], "actual_exit": row["actual_exit"], "ok": row["ok"]}))
    row = run_runtime_extra()
    rows.append(row)
    print(json.dumps({"mode": row["mode"], "actual_exit": row["actual_exit"], "ok": row["ok"]}))
    for mode in ("wrong-status", "unknown-error-output"):
        row = run_receipt(mode)
        rows.append(row)
        print(json.dumps({"mode": row["mode"], "actual_exit": row["actual_exit"], "ok": row["ok"]}))
    row = run_lean_false()
    rows.append(row)
    print(json.dumps({"mode": row["mode"], "actual_exit": row["actual_exit"], "ok": row["ok"]}))
    summary = {
        "rows": [
            {
                "mode": r["mode"],
                "actual_exit": r["actual_exit"],
                "expected_exit": r["expected_exit"],
                "ok": r["ok"],
                "seconds": r["seconds"],
                "score_exit": r.get("score_exit"),
                "score_status": r.get("score_status"),
            }
            for r in rows
        ],
        "all_ok": all(r["ok"] for r in rows),
        "note": "compiler-nonzero/malformed-extra/runtime-extra/wrong-status/unknown-error block 3; lean-false remains fail 1 with compiler 0",
    }
    write_result(CTRL / "fault-campaign-summary.json", summary)
    return 0 if summary["all_ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
