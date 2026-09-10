#!/usr/bin/env python3
"""Intact, falsifying, non-distinguishing and malformed controls for the token0 detector.

Metadata diagnostics, not compiled production mutants. Uses the same
score_designated_detection function as token0_campaign.py.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ENGINE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(ENGINE_DIR))

from common import EVIDENCE, choose_run_dir, refuse_nonempty_dir, write_json  # noqa: E402
from token0_campaign import score_designated_detection  # noqa: E402

INTACT = {"status": "ok", "value": 39614081257132168796771975168}
DISTINCT_PLANNED = {"status": "ok", "value": 1}


def main() -> int:
    out = refuse_nonempty_dir(choose_run_dir(EVIDENCE) / "token0-detector-controls")
    cases = [
        {
            "id": "intact-agree",
            "des_status": "ok",
            "des_ret_uint": INTACT["value"],
            "des_class": "success",
            "intact_expected": INTACT,
            "planned": DISTINCT_PLANNED,
            "expected_detected": False,
            "expected_class": "fail",
        },
        {
            "id": "falsify-disagree",
            "des_status": "ok",
            "des_ret_uint": 12345,
            "des_class": "success",
            "intact_expected": INTACT,
            "planned": DISTINCT_PLANNED,
            "expected_detected": True,
            "expected_class": "ok",
        },
        {
            "id": "non-distinguishing-planned-equals-intact",
            "des_status": "ok",
            "des_ret_uint": 0,
            "des_class": "success",
            "intact_expected": INTACT,
            "planned": dict(INTACT),
            "expected_detected": False,
            "expected_class": "blocked",
        },
        {
            "id": "malformed-blocked-execution",
            "des_status": "blocked",
            "des_ret_uint": None,
            "des_class": "blocked",
            "intact_expected": INTACT,
            "planned": DISTINCT_PLANNED,
            "expected_detected": False,
            "expected_class": "blocked",
        },
    ]
    results = []
    for case in cases:
        got = score_designated_detection(
            case["des_status"],
            case["des_ret_uint"],
            case["des_class"],
            case["intact_expected"],
            case["planned"],
        )
        matched = (
            got["detected"] == case["expected_detected"]
            and got["detection_class"] == case["expected_class"]
        )
        results.append({
            "id": case["id"],
            "kind": "metadata_diagnostic_not_compiled_mutation",
            "expected_detected": case["expected_detected"],
            "expected_class": case["expected_class"],
            "got": got,
            "matched": matched,
        })
    matched = sum(1 for r in results if r["matched"])
    report = {
        "kind": "token0_detector_controls",
        "function": "token0_campaign.score_designated_detection",
        "checks": len(results),
        "matched": matched,
        "results": results,
        "exit": 0 if matched == len(results) else 1,
    }
    write_json(out / "result.json", report)
    print(json.dumps({
        "checks": report["checks"],
        "matched": report["matched"],
        "exit": report["exit"],
        "failed_ids": [r["id"] for r in results if not r["matched"]],
    }))
    return int(report["exit"])


if __name__ == "__main__":
    raise SystemExit(main())
