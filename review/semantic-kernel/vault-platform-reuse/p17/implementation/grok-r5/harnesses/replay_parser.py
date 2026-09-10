#!/usr/bin/env python3
"""Candidate-local retarget of the 30-row parser diagnostic.

Provenance: p17-implementation-opus-review-r1/work/checks/r4-protocol-retarget/replay_parser_opus.py
(reviewer-authored). Classifies current-engine classify_evm_stdout against
current campaign refusal stdout plus grammar controls.
Exits nonzero when expected classifications mismatch.
"""
from __future__ import annotations

import hashlib
import json
import os
import sys
from pathlib import Path


def find_root(start: Path) -> Path:
    for p in [start, *start.parents]:
        if (p / "scripts/platform_engine").is_dir() and (p / "lean").is_dir():
            return p
    raise RuntimeError(f"worktree root not found from {start}")


ROOT = find_root(Path(__file__).resolve())
ENGINE = ROOT / "scripts/platform_engine"
sys.dont_write_bytecode = True
sys.path.insert(0, str(ENGINE))
from evm import classify_evm_stdout  # noqa: E402

EV = Path(os.environ.get(
    "DEFIFORMAL_EVIDENCE_DIR",
    str(ROOT / "review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5"),
))
RUN = EV / os.environ.get("DEFIFORMAL_RUN_DIR", "attempt-1")
OUT = RUN / "harness-parser"
FIXTURES = ROOT / "openspec/changes/vault-platform-reuse-p17/fixtures.json"

REFUSAL_IDS = [
    "P17-DEP-BAD-RECV",
    "P17-DEP-MUL-OVF",
    "P17-DEP-SELF",
    "P17-DEP-TF-ALLOW",
    "P17-DEP-TF-BAL",
    "P17-RED-ALLOW",
    "P17-RED-BAL",
]


def check(rows, name, stdout, expected_status, expected_error=None):
    got = classify_evm_stdout(stdout, 0, False)
    ok = got["status"] == expected_status
    if expected_error is not None:
        ok = ok and got.get("decoded_error") == expected_error
    rows.append({
        "id": name,
        "stdout_sha256": hashlib.sha256(stdout.encode()).hexdigest(),
        "expected_status": expected_status,
        "expected_error": expected_error,
        "actual_status": got.get("status"),
        "actual_error": got.get("decoded_error"),
        "matches": ok,
    })


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    rows = []
    data = json.loads(FIXTURES.read_text())
    by_id = {fx["id"]: fx for fx in data["fixtures"]}
    missing = []
    for fid in REFUSAL_IDS:
        stdout_path = RUN / "evm/execute/fixtures" / fid / "op-returndata/record/stdout.bin"
        if not stdout_path.is_file():
            missing.append(str(stdout_path))
            continue
        want = by_id[fid]["expected"].get("error")
        check(rows, fid, stdout_path.read_text(errors="replace"), "revert", want)
    if missing:
        report = {
            "status": "blocked",
            "exit": 3,
            "reason": "missing current-campaign refusal stdout",
            "missing": missing,
        }
        (OUT / "result.json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report))
        return 3

    error = rows[0]["id"]  # placeholder; real error line taken from first refusal stdout
    first_stdout = (RUN / "evm/execute/fixtures" / REFUSAL_IDS[0] / "op-returndata/record/stdout.bin").read_text(errors="replace")
    error = first_stdout.splitlines()[0]
    panic_path = RUN / "evm/execute/fixtures/P17-DEP-MUL-OVF/op-returndata/record/stdout.bin"
    panic = panic_path.read_text(errors="replace").splitlines()[0]
    word = "0x" + "0" * 63 + "1"
    revert = "error: execution reverted"
    invalid = "error: invalid opcode: invalid"
    controls = [
        ("word-success", word, "ok"),
        ("empty-call", "0x", "blocked"),
        ("duplicate-empty-revert", "0x\n0x\n" + revert, "blocked"),
        ("duplicate-empty-invalid", "0x\n0x\n" + invalid, "blocked"),
        ("duplicate-word", word + "\n" + word, "blocked"),
        ("duplicate-structured", error + "\n" + error + "\n" + revert, "blocked"),
        ("mixed-word-structured", word + "\n" + error + "\n" + revert, "blocked"),
        ("mixed-empty-structured", "0x\n" + error + "\n" + revert, "blocked"),
        ("duplicate-errors", error + "\n" + revert + "\n" + revert, "blocked"),
        ("unknown-error", error + "\nerror: made up", "blocked"),
        ("structured-without-error", error, "blocked"),
        ("odd-hex", "0x123\n" + revert, "blocked"),
        ("nonhex", "0xgg\n" + revert, "blocked"),
        ("truncated-panic", panic[:-2] + "\n" + revert, "blocked"),
        ("trailing-panic", panic + "00\n" + revert, "blocked"),
        ("truncated-error", error[:-2] + "\n" + revert, "blocked"),
        ("nonzero-error-padding", error[:-2] + "01\n" + revert, "blocked"),
        ("unknown-short-revert", "0x1234\n" + revert, "blocked"),
        ("unknown-short-invalid", "0x1234\n" + invalid, "blocked"),
        ("malformed-panic-invalid", panic[:-2] + "\n" + invalid, "blocked"),
        ("empty-revert", "0x\n" + revert, "revert"),
        ("empty-invalid", "0x\n" + invalid, "exception"),
        ("word-revert-preserved", word + "\n" + revert, "revert"),
    ]
    for name, raw, expected in controls:
        check(rows, name, raw, expected)

    failures = [row["id"] for row in rows if not row["matches"]]
    result = {
        "engine": str(ENGINE),
        "vault_run": str(RUN),
        "provenance": "Opus reviewer parser retarget; grammar controls preserved",
        "review_authorship": "claude-opus-5 session a1e40b81-7427-45e5-8b00-b2492cd46156",
        "real_refusal_rows": len(REFUSAL_IDS),
        "grammar_controls": len(controls),
        "total": len(rows),
        "matched": len(rows) - len(failures),
        "failed_ids": failures,
        "exit": 1 if failures else 0,
        "rows": rows,
    }
    (OUT / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: v for k, v in result.items() if k != "rows"}))
    return int(result["exit"])


if __name__ == "__main__":
    raise SystemExit(main())
