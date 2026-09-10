#!/usr/bin/env python3
"""Intact vs missing-tool controls for blocked_missing_compiler / blocked_missing_evm (task 2.5)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ENGINE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(ENGINE_DIR))

from common import (  # noqa: E402
    EVM,
    EVM_SHA256,
    EVIDENCE,
    SOLC_VAULT,
    SOLC_VAULT_SHA256,
    SetupBlocked,
    blocked,
    choose_run_dir,
    pin_tool,
    refuse_nonempty_dir,
    write_json,
)
from compile import compile_sources, compiler_settings  # noqa: E402
from evm import run_tx, write_genesis  # noqa: E402


def _as_blocked(exc: SetupBlocked) -> dict:
    return blocked(exc.reason, exc.extra)


def main() -> int:
    out = refuse_nonempty_dir(choose_run_dir(EVIDENCE) / "setup-controls")
    results = []

    try:
        pin = pin_tool(SOLC_VAULT, SOLC_VAULT_SHA256, "solc")
        results.append({"id": "intact-solc", "expected_class": None, "got": pin, "matched": True, "exit": 0})
    except SetupBlocked as exc:
        report = _as_blocked(exc)
        results.append({"id": "intact-solc", "expected_exit": 0, "got": report, "matched": False})

    try:
        pin_tool(Path("/nonexistent/solc-missing"), SOLC_VAULT_SHA256, "solc")
        results.append({"id": "missing-solc", "expected_class": "blocked_missing_compiler", "matched": False})
    except SetupBlocked as exc:
        report = _as_blocked(exc)
        matched = report.get("class") == "blocked_missing_compiler" and report.get("exit") == 3
        results.append({
            "id": "missing-solc",
            "expected_class": "blocked_missing_compiler",
            "expected_exit": 3,
            "got": report,
            "matched": matched,
        })

    try:
        pin = pin_tool(EVM, EVM_SHA256, "evm")
        results.append({"id": "intact-evm", "got": pin, "matched": True, "exit": 0})
    except SetupBlocked as exc:
        results.append({"id": "intact-evm", "got": _as_blocked(exc), "matched": False})

    try:
        pin_tool(Path("/nonexistent/evm-missing"), EVM_SHA256, "evm")
        results.append({"id": "missing-evm", "expected_class": "blocked_missing_evm", "matched": False})
    except SetupBlocked as exc:
        report = _as_blocked(exc)
        matched = report.get("class") == "blocked_missing_evm" and report.get("exit") == 3
        results.append({
            "id": "missing-evm",
            "expected_class": "blocked_missing_evm",
            "expected_exit": 3,
            "got": report,
            "matched": matched,
        })

    # Public compile consumer with missing compiler path.
    missing_compile = compile_sources(
        name="missing-compiler-consumer",
        sources={"A.sol": "pragma solidity ^0.8.21; contract A {}"},
        source_roles={"A.sol": "control"},
        solc=Path("/nonexistent/solc-missing"),
        expected_solc_sha=SOLC_VAULT_SHA256,
        settings=compiler_settings(evm_version="shanghai", optimizer_runs=200, bytecode_hash="none"),
        out_dir=out / "missing-compiler-consumer",
        timeout=10.0,
    )
    results.append({
        "id": "missing-compiler-consumer",
        "expected_class": "blocked_missing_compiler",
        "expected_exit": 3,
        "got": {k: missing_compile.get(k) for k in ("status", "exit", "class", "missing_identity", "reason")},
        "matched": missing_compile.get("class") == "blocked_missing_compiler" and missing_compile.get("exit") == 3,
    })

    matched = sum(1 for r in results if r.get("matched"))
    report = {
        "checks": len(results),
        "matched": matched,
        "results": results,
        "exit": 0 if matched == len(results) else 1,
    }
    write_json(out / "result.json", report)
    print(json.dumps({"checks": report["checks"], "matched": report["matched"], "exit": report["exit"]}))
    return int(report["exit"])


if __name__ == "__main__":
    raise SystemExit(main())
