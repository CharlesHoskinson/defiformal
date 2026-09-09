#!/usr/bin/env python3
"""Execute vault production mutants V-TF-SKIP and V-DEP-CEIL.

Each mutant is a single, exact Solidity edit to captured SUsds.sol.
Mutants are compiled with Solc 0.8.21 shanghai through the platform engine,
deployed, and scored against designated false and positive/refusal controls.
"""
from __future__ import annotations

import difflib
import json
import os
import sys
from pathlib import Path

ENGINE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(ENGINE_DIR))

import common
from common import (
    SOLC_VAULT,
    SOLC_VAULT_SHA256,
    SUSDS_SHA256,
    blocked,
    refuse_nonempty_dir,
    sha256_text,
    utc_now,
    write_json,
)
from compile import compile_sources, compiler_settings
from vault_campaign import load_sources
from vault_exec import deploy, run_fixtures

MUTANTS = [
    {
        "id": "V-TF-SKIP",
        "class": "asset_credit",
        "file": "src/SUsds.sol",
        "target": "        usds.transferFrom(msg.sender, address(this), assets);\n",
        "replacement": "",
        "designated_false": "P17-DEP-D0",
        "controls": ["P17-RED-D0", "P17-DEP-BAD-RECV", "P17-RED-ALLOW"],
    },
    {
        "id": "V-DEP-CEIL",
        "class": "rounding",
        "file": "src/SUsds.sol",
        "target": "        shares = assets * RAY / drip();",
        "replacement": "        shares = _divup(assets * RAY, drip());",
        "designated_false": "P17-DEP-D1",
        "controls": ["P17-DEP-D0", "P17-RED-D1"],
    },
]


def run_single_mutant(mdef: dict, out_base: Path) -> dict:
    mid = mdef["id"]
    mout = out_base / mid
    mout.mkdir(parents=True, exist_ok=True)
    sources, roles = load_sources()
    orig_code = sources[mdef["file"]]
    target = mdef["target"]
    if target not in orig_code:
        report = blocked(f"mutation target string not found in {mdef['file']}")
        write_json(mout / "result.json", report)
        return report
    mutated_code = orig_code.replace(target, mdef["replacement"], 1)
    sources[mdef["file"]] = mutated_code
    diff = "".join(
        difflib.unified_diff(
            orig_code.splitlines(keepends=True),
            mutated_code.splitlines(keepends=True),
            fromfile=f"a/{mdef['file']}",
            tofile=f"b/{mdef['file']}",
        )
    )
    (mout / "patch.diff").write_text(diff)

    # Compile mutant
    compile_out = mout / "compile"
    settings = compiler_settings(
        evm_version="shanghai",
        optimizer_runs=200,
        bytecode_hash="none",
    )
    comp_report = compile_sources(
        name=f"vault-mutant-{mid}",
        sources=sources,
        source_roles=roles,
        solc=SOLC_VAULT,
        expected_solc_sha=SOLC_VAULT_SHA256,
        settings=settings,
        out_dir=compile_out,
        timeout=60.0,
        required=["src/SUsds.sol:SUsds"],
    )
    write_json(compile_out / "result.json", {k: comp_report[k] for k in comp_report if k != "artifacts"})
    if comp_report.get("status") != "ok" or comp_report.get("exit") != 0:
        res = blocked("mutant failed compilation", {"compile_report": comp_report})
        write_json(mout / "result.json", res)
        return res

    # Deploy mutant
    deploy_out = mout / "deploy"
    try:
        deployed = deploy(deploy_out, compile_path=compile_out / "compile.json")
    except Exception as exc:
        res = blocked(f"mutant deploy failed: {exc}")
        write_json(mout / "result.json", res)
        return res

    # Run designated false and controls
    test_ids = [mdef["designated_false"]] + mdef["controls"]
    fixtures_out = mout / "fixtures"
    score = run_fixtures(fixtures_out, deployed["addresses"], Path(deployed["genesis"]), fixture_ids=test_ids)

    # Analyze detection and control preservation
    rows_file = fixtures_out / "rows.json"
    rows = json.loads(rows_file.read_text()) if rows_file.is_file() else []
    rows_by_id = {r["id"]: r for r in rows}

    desig_row = rows_by_id.get(mdef["designated_false"])
    desig_gate = (desig_row.get("comparison") or {}).get("gate") if desig_row else None
    detected = (desig_gate == "fail")

    controls_ok = True
    control_results = {}
    for cid in mdef["controls"]:
        crow = rows_by_id.get(cid)
        cgate = (crow.get("comparison") or {}).get("gate") if crow else None
        control_results[cid] = cgate
        if cgate != "ok":
            controls_ok = False

    result = {
        "mutant_id": mid,
        "class": mdef["class"],
        "status": "ok" if (detected and controls_ok) else "fail",
        "detected": detected,
        "designated_false": {
            "id": mdef["designated_false"],
            "gate": desig_gate,
            "detected": detected,
        },
        "controls_ok": controls_ok,
        "control_results": control_results,
        "diff_sha256": sha256_text(diff),
    }
    write_json(mout / "result.json", result)
    return result


def main(evidence_dir: Path | None = None) -> int:
    ev = common.choose_run_dir(evidence_dir or common.EVIDENCE)
    out = refuse_nonempty_dir(ev / "mutants")
    summary = {
        "status": "ok",
        "mutants": {},
        "timestamp_utc": utc_now(),
    }
    all_ok = True
    for mdef in MUTANTS:
        res = run_single_mutant(mdef, out)
        summary["mutants"][mdef["id"]] = res
        print(f"Mutant {mdef['id']}: status={res.get('status')} detected={res.get('detected')} controls_ok={res.get('controls_ok')}")
        if res.get("status") != "ok":
            all_ok = False
            summary["status"] = "fail"

    write_json(out / "summary.json", summary)
    return 0 if all_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
