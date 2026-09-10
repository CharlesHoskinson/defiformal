#!/usr/bin/env python3
"""Apply real perturbations to the current substantive P18 packet.

Expected exits: intact 0; missing/empty required evidence 3; contradictory
claims 1. Control-only directories cannot satisfy the release. This driver
fails if any case does not match.
"""
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from copy import deepcopy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
VALIDATOR = Path(__file__).resolve().parent / "validate_p18.py"
PACKETS = ROOT / "review/semantic-kernel/platform-increment/p18/packets"
MAIN_NAME = "p18.token0.next-price.packet.json"
ZERO_SHA = "0" * 64

CASES = [
    {"id": "intact", "expected_exit": 0},
    {"id": "missing-required-main-packet", "expected_exit": 3},
    {"id": "zero-main-execution-denominator", "expected_exit": 3},
    {"id": "missing-main-source", "expected_exit": 3},
    {"id": "changed-actual-source-log-binding", "expected_exit": 1},
    {"id": "invented-execution-denominator", "expected_exit": 1},
    {"id": "missing-production-mutations-and-controls", "expected_exit": 3},
    {"id": "empty-stdout-presented-as-model-runtime", "expected_exit": 1},
]


def load(path: Path):
    return json.loads(path.read_text())


def dump(path: Path, data) -> None:
    path.write_text(json.dumps(data, indent=2) + "\n")


def copy_packets(dst: Path) -> None:
    if dst.exists():
        shutil.rmtree(dst)
    shutil.copytree(PACKETS, dst)


def perturb(case_id: str, packets_dir: Path) -> None:
    main_path = packets_dir / MAIN_NAME
    if case_id == "intact":
        return
    if case_id == "missing-required-main-packet":
        main_path.unlink()
        return
    packet = load(main_path)
    if case_id == "zero-main-execution-denominator":
        packet["executions"]["source_runs"] = []
        packet["executions"]["model_runs"] = []
        packet["denominators"]["executions"] = {"planned": 0, "actually_run": 0, "unexecuted": 0}
    elif case_id == "missing-main-source":
        packet["identities"]["source"]["path"] = "review/semantic-kernel/platform-increment/p18/validation/fixtures/does-not-exist.sol"
        packet["identities"]["source"]["sha256"] = None
    elif case_id == "changed-actual-source-log-binding":
        packet["executions"]["source_runs"][0]["log_sha256"] = ZERO_SHA
    elif case_id == "invented-execution-denominator":
        packet["denominators"]["executions"]["actually_run"] = 999
    elif case_id == "missing-production-mutations-and-controls":
        packet["mutations"]["production"] = []
        packet["mutations"]["unaffected_controls"] = []
        packet["denominators"]["mutations"]["compiled_production"] = 0
        packet["denominators"]["mutations"]["unaffected_controls"] = 0
    elif case_id == "empty-stdout-presented-as-model-runtime":
        packet["executions"]["model_runs"].append(
            {
                "id": "p18-tests-consumer",
                "status": "executed",
                "tool": "lake env lean",
                "exit_code": 0,
                "log_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                "notes": "Deliberate R5 perturbation: compile-only empty stdout presented as model runtime.",
            }
        )
        packet["denominators"]["executions"]["planned"] = len(packet["executions"]["source_runs"]) + len(packet["executions"]["model_runs"])
        packet["denominators"]["executions"]["actually_run"] = packet["denominators"]["executions"]["planned"]
    else:
        raise SystemExit(f"unknown case {case_id}")
    dump(main_path, packet)


def run_validator(packets_dir: Path) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(VALIDATOR), "--packets-dir", str(packets_dir)],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
        check=False,
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out-dir", required=True)
    args = parser.parse_args()
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    results = []
    matched = 0
    for case in CASES:
        case_dir = out_dir / case["id"]
        packets_dir = case_dir / "packets"
        copy_packets(packets_dir)
        perturb(case["id"], packets_dir)
        proc = run_validator(packets_dir)
        (case_dir / "stdout.bin").write_text(proc.stdout)
        (case_dir / "stderr.bin").write_text(proc.stderr)
        ok = proc.returncode == case["expected_exit"]
        if ok:
            matched += 1
        payload = None
        try:
            payload = json.loads(proc.stdout)
        except json.JSONDecodeError:
            payload = None
        rec = {
            "id": case["id"],
            "expected_exit": case["expected_exit"],
            "actual_consumer_exit": proc.returncode,
            "matched": ok,
            "validator_ok": None if payload is None else payload.get("ok"),
            "blocked": None if payload is None else payload.get("blocked"),
            "failures": None if payload is None else payload.get("failures"),
        }
        dump(case_dir / "result.json", rec)
        results.append(rec)
    summary = {
        "schema": "defiformal-p18-release-controls/v1",
        "validator": str(VALIDATOR.relative_to(ROOT)),
        "packets": str(PACKETS.relative_to(ROOT)),
        "checks": len(CASES),
        "matched": matched,
        "results": results,
        "ok": matched == len(CASES),
    }
    dump(out_dir / "results.json", summary)
    print(json.dumps(summary, indent=2))
    return 0 if summary["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
