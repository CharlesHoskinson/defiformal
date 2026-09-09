#!/usr/bin/env python3
"""Apply the six named single Solidity edits from planned-mutations.json.

Each edit is a unique exact-string replacement on a copied SqrtPriceMath.sol.
Captured libraries stay immutable. Compiler failure is blocked, not detection.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from p16_common import MUTANT_IDS, load_mutations, sha256_file, sha256_text, write_json

# Unique exact fragments from captured SqrtPriceMath.sol (Uniswap v3-core v1.0.0).
EDITS: dict[str, dict[str, str]] = {
    "T0-ID-SKIP": {
        "find": "        if (amount == 0) return sqrtPX96;\n",
        "replace": "",
        "note": "Delete the identity statement only. Product-fit test remains and is reached at amount 0.",
    },
    "T0-WRAP-SKIP": {
        "find": "                if (denominator >= numerator1)\n",
        "replace": "                if (true)\n",
        "note": "Keep native wrapped product and denominator sum. Replace wrap-fit test with true.",
    },
    "T0-PROD-SKIP": {
        "find": "            if ((product = amount * sqrtPX96) / amount == sqrtPX96) {\n                uint256 denominator = numerator1 + product;\n",
        "replace": "            product = amount * sqrtPX96;\n            if (true) {\n                uint256 denominator = numerator1 + product;\n",
        "note": "Retain product assignment (native wrap). Replace product-fit condition with true. Do not delete the assignment.",
    },
    "T0-REQ-SKIP": {
        "find": "            require((product = amount * sqrtPX96) / amount == sqrtPX96 && numerator1 > product);\n",
        "replace": "            require((product = amount * sqrtPX96) / amount == sqrtPX96);\n",
        "note": "Keep product-fit conjunct. Delete only numerator1 > product.",
    },
    "T0-FLOOR": {
        "find": "                    return uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator));\n",
        "replace": "                    return uint160(FullMath.mulDiv(numerator1, sqrtPX96, denominator));\n",
        "note": "Replace add-path primary FullMath.mulDivRoundingUp with FullMath.mulDiv.",
    },
    "T0-CHECKED-ADD": {
        "find": "                uint256 denominator = numerator1 + product;\n",
        "replace": "                uint256 denominator = numerator1.add(product);\n",
        "note": "Replace wrapping uint256 sum with LowGasSafeMath.add already in scope.",
    },
}


def apply_edit(source: str, mutant_id: str) -> tuple[str, dict]:
    spec = EDITS[mutant_id]
    find = spec["find"]
    replace = spec["replace"]
    count = source.count(find)
    if count != 1:
        return source, {
            "status": "blocked_edit_not_unique_or_missing",
            "id": mutant_id,
            "occurrences": count,
            "find_sha256": sha256_text(find),
        }
    after = source.replace(find, replace, 1)
    if after == source:
        return source, {
            "status": "blocked_edit_no_change",
            "id": mutant_id,
        }
    return after, {
        "status": "applied",
        "id": mutant_id,
        "find_sha256": sha256_text(find),
        "replace_sha256": sha256_text(replace),
        "find": find,
        "replace": replace,
        "note": spec["note"],
        "occurrences": 1,
    }


def apply_mutant(overlay: Path, mutant_id: str, out_json: Path | None = None) -> dict:
    if mutant_id not in MUTANT_IDS:
        report = {"status": "blocked_unknown_mutant", "id": mutant_id}
        if out_json:
            write_json(out_json, report)
        return report
    path = overlay / "SqrtPriceMath.sol"
    before = path.read_text()
    after, meta = apply_edit(before, mutant_id)
    plan = next(row for row in load_mutations() if row["id"] == mutant_id)
    report = {
        **meta,
        "file": "SqrtPriceMath.sol",
        "before_sha256": sha256_text(before),
        "after_sha256": sha256_text(after) if meta.get("status") == "applied" else None,
        "planned_designated_false": plan.get("designated_false"),
        "planned_unaffected_positive": plan.get("unaffected_positive"),
        "planned_equality_baseline_control": plan.get("equality_baseline_control"),
        "planned_original_public": plan.get("original_public") or plan.get("original_public_strict"),
        "planned_mutant_public": plan.get("mutant_public") or plan.get("mutant_public_strict"),
        "planned_ordinary_control": plan.get("ordinary_control"),
        "actual_source_change": plan.get("actual_source_change"),
    }
    if meta.get("status") == "applied":
        path.write_text(after)
        report["after_file_sha256"] = sha256_file(path)
    if out_json:
        write_json(out_json, report)
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--overlay", required=True)
    parser.add_argument("--id", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    report = apply_mutant(Path(args.overlay), args.id, Path(args.out))
    print(json.dumps({"id": args.id, "status": report.get("status")}))
    return 0 if report.get("status") == "applied" else 3


if __name__ == "__main__":
    raise SystemExit(main())
