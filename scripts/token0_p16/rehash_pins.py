#!/usr/bin/env python3
"""Re-hash captured token0 closure, planning archive, defective oracle, compiler identity."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

ROOT = Path("/home/charl/defiformal-wt-p16-token0-grok-gpt6-20260908")
PRIMARY = Path("/home/charl/defiformal")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    source_pin = json.loads((ROOT / "openspec/changes/uniswap-token0-p16/source-pin.json").read_text())
    compiler_plan = json.loads(
        (ROOT / "openspec/changes/uniswap-token0-p16/compiler-harness-plan.json").read_text()
    )
    current = json.loads(
        (ROOT / "review/semantic-kernel/strategy-audit-20260908/CURRENT.json").read_text()
    )
    liquidity_sha = None
    for lane in current["lanes"]:
        if lane.get("id") == "liquidity":
            liquidity_sha = lane["candidate"]["sha256"]
    capture_root = ROOT / source_pin["capture_root"]
    closure = []
    mismatches = []
    for entry in source_pin["token0_closure"]:
        path = capture_root / entry["rel"]
        actual = sha256_file(path)
        size = path.stat().st_size
        row = {
            "rel": entry["rel"],
            "path": str(path),
            "expected_sha256": entry["sha256"],
            "actual_sha256": actual,
            "expected_bytes": entry["bytes"],
            "actual_bytes": size,
            "match": actual == entry["sha256"] and size == entry["bytes"],
        }
        closure.append(row)
        if not row["match"]:
            mismatches.append(row)
    archive = PRIMARY / (
        "review/semantic-kernel/program-execution-20260908/p16-planning-candidate-r3.tar.gz"
    )
    liquidity_archive = ROOT / source_pin["liquidity_archive"]["retained_path"]
    defective = ROOT / (
        "review/semantic-kernel/uniswap-token0/p16/planning/grok-r1/witnesses/cl_oracle_defective.py"
    )
    compiler_identity = ROOT / (
        "review/semantic-kernel/uniswap-token0/p16/planning/grok-r1/"
        "compiler-identity/solc-0.7.6-linux-amd64.json"
    )
    compiler_list = ROOT / (
        "review/semantic-kernel/uniswap-token0/p16/planning/grok-r1/"
        "compiler-identity/solc-linux-amd64-list.json"
    )
    solc = Path(
        "/home/charl/.cache/defiformal-program/program-execution-20260908/"
        "p16-tools/solc-linux-amd64-v0.7.6+commit.7338295f"
    )
    word = ROOT / "lean/DefiKernel/Arithmetic/Word.lean"
    rounding = ROOT / "lean/DefiKernel/Arithmetic/Rounding.lean"
    operations = ROOT / "lean/DefiKernel/Arithmetic/Operations.lean"
    toolchain = ROOT / "lean/lean-toolchain"
    manifest = ROOT / "lean/lake-manifest.json"
    report = {
        "closure": closure,
        "closure_all_match": not mismatches,
        "mismatches": mismatches,
        "liquidity_archive": {
            "path": str(liquidity_archive),
            "sha256": sha256_file(liquidity_archive),
            "source_pin": source_pin["liquidity_archive"]["sha256"],
            "CURRENT_value": liquidity_sha,
            "match_pin": sha256_file(liquidity_archive) == source_pin["liquidity_archive"]["sha256"],
            "match_CURRENT": sha256_file(liquidity_archive) == liquidity_sha,
        },
        "planning_archive": {
            "path": str(archive),
            "sha256": sha256_file(archive),
            "expected": "382975c628b5881e0352bd011fdf8242b6d4c088d1b4271c4e7bef30c3722a4f",
        },
        "defective_oracle": {
            "path": str(defective),
            "sha256": sha256_file(defective),
            "expected": "4ecd60394ab4deff50387f578a9ac85f981946d17b9ff36d0724ccbd3921e0cd",
        },
        "compiler_identity": {
            "path": str(compiler_identity),
            "sha256": sha256_file(compiler_identity),
        },
        "compiler_list": {
            "path": str(compiler_list),
            "sha256": sha256_file(compiler_list),
            "expected": compiler_plan["solc"]["list_sha256"],
        },
        "solc_binary": {
            "path": str(solc),
            "sha256": sha256_file(solc) if solc.is_file() else None,
            "expected": compiler_plan["solc"]["binary_sha256"],
        },
        "source_pin_sha256": sha256_file(ROOT / "openspec/changes/uniswap-token0-p16/source-pin.json"),
        "compiler_harness_plan_sha256": sha256_file(
            ROOT / "openspec/changes/uniswap-token0-p16/compiler-harness-plan.json"
        ),
        "arithmetic_pins": {
            "Word.lean": sha256_file(word),
            "Word.lean_expected": "5c0f467384bc3fe320ab363b7124f1c94b9ea688293c61cac7c5e08af8cb879b",
            "Rounding.lean": sha256_file(rounding),
            "Rounding.lean_expected": "0bd0c65af77bc809f4ff3b8cb5d98ab7eca5be0e0e7216e9e88263e4e02649f0",
            "Operations.lean": sha256_file(operations),
            "Operations.lean_expected": "081c4d29809a33b6377ab1746ae93f2f2a429f5fa307983331c4cb5fbc460485",
        },
        "lean_toolchain": {
            "path": str(toolchain),
            "text": toolchain.read_text().strip(),
            "sha256": sha256_file(toolchain),
            "expected": "leanprover/lean4:v4.33.0-rc2",
        },
        "mathlib": {
            "rev": json.loads(manifest.read_text())["packages"][0]["rev"],
            "expected": "51e6992efd06126df61a496bebf8f49482a4e129",
        },
    }
    report["planning_archive"]["match"] = (
        report["planning_archive"]["sha256"] == report["planning_archive"]["expected"]
    )
    report["defective_oracle"]["match"] = (
        report["defective_oracle"]["sha256"] == report["defective_oracle"]["expected"]
    )
    report["compiler_list"]["match"] = (
        report["compiler_list"]["sha256"] == report["compiler_list"]["expected"]
    )
    report["solc_binary"]["match"] = (
        report["solc_binary"]["sha256"] == report["solc_binary"]["expected"]
    )
    report["arithmetic_pins"]["all_match"] = (
        report["arithmetic_pins"]["Word.lean"] == report["arithmetic_pins"]["Word.lean_expected"]
        and report["arithmetic_pins"]["Rounding.lean"]
        == report["arithmetic_pins"]["Rounding.lean_expected"]
        and report["arithmetic_pins"]["Operations.lean"]
        == report["arithmetic_pins"]["Operations.lean_expected"]
    )
    report["lean_toolchain"]["match"] = (
        report["lean_toolchain"]["text"] == report["lean_toolchain"]["expected"]
    )
    report["mathlib"]["match"] = report["mathlib"]["rev"] == report["mathlib"]["expected"]
    out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/dev/stdout")
    if str(out) != "/dev/stdout":
        out.write_text(json.dumps(report, indent=2) + "\n")
    else:
        print(json.dumps(report, indent=2))
    ok = (
        report["closure_all_match"]
        and report["liquidity_archive"]["match_pin"]
        and report["liquidity_archive"]["match_CURRENT"]
        and report["planning_archive"]["match"]
        and report["defective_oracle"]["match"]
        and report["compiler_list"]["match"]
        and report["solc_binary"]["match"]
        and report["arithmetic_pins"]["all_match"]
        and report["lean_toolchain"]["match"]
        and report["mathlib"]["match"]
    )
    report_status = {"ok": ok}
    print(json.dumps(report_status))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
