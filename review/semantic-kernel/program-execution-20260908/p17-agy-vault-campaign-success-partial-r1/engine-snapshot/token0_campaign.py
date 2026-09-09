#!/usr/bin/env python3
"""Token0 compile through the same parameterized engine as vault.

Does not edit frozen Token0Probe.sol. Istanbul/0.7.6 settings are parameters,
not a second compiler implementation.
"""
from __future__ import annotations

import sys
from pathlib import Path

ENGINE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(ENGINE_DIR))

from common import (  # noqa: E402
    EVIDENCE,
    FROZEN_PROBE,
    FROZEN_PROBE_SHA256,
    SOLC_TOKEN0,
    SOLC_TOKEN0_SHA256,
    TOKEN0_CAPTURE,
    blocked,
    sha256_file,
    write_json,
)
from compile import compile_sources, compiler_settings  # noqa: E402

LIB_NAMES = [
    "FullMath.sol",
    "UnsafeMath.sol",
    "LowGasSafeMath.sol",
    "SafeCast.sol",
    "FixedPoint96.sol",
    "SqrtPriceMath.sol",
]


def load_sources() -> tuple[dict[str, str], dict[str, str]]:
    sources: dict[str, str] = {}
    roles: dict[str, str] = {}
    if not FROZEN_PROBE.is_file():
        raise FileNotFoundError(f"missing Token0Probe.sol: {FROZEN_PROBE}")
    sources["Token0Probe.sol"] = FROZEN_PROBE.read_text()
    roles["Token0Probe.sol"] = "frozen_probe"
    lib_root = TOKEN0_CAPTURE / "contracts/libraries"
    for name in LIB_NAMES:
        path = lib_root / name
        sources[name] = path.read_text()
        roles[name] = "captured_token0_library"
    return sources, roles


def main() -> int:
    out = EVIDENCE / "evm" / "token0-compile"
    out.mkdir(parents=True, exist_ok=True)
    got = sha256_file(FROZEN_PROBE)
    if got != FROZEN_PROBE_SHA256:
        report = blocked(
            "Token0Probe.sol hash drifted",
            {"got": got, "expected": FROZEN_PROBE_SHA256},
        )
        write_json(out / "compile.json", report)
        print(report["reason"])
        return 3
    try:
        sources, roles = load_sources()
    except FileNotFoundError as exc:
        report = blocked(str(exc))
        write_json(out / "compile.json", report)
        print(report["reason"])
        return 3
    settings = compiler_settings(
        evm_version="istanbul",
        optimizer_runs=800,
        bytecode_hash="none",
    )
    report = compile_sources(
        name="token0-solc-0.7.6-istanbul",
        sources=sources,
        source_roles=roles,
        solc=SOLC_TOKEN0,
        expected_solc_sha=SOLC_TOKEN0_SHA256,
        settings=settings,
        out_dir=out,
        timeout=60.0,
        required=["Token0Probe.sol:Token0Probe"],
    )
    write_json(out / "result.json", {k: report[k] for k in report if k != "artifacts"})
    print(report.get("status"), report.get("exit"), "contracts", len(report.get("contracts") or []))
    if report.get("status") == "ok" and report.get("exit") == 0:
        return 0
    return 3 if report.get("exit") in (None, 0) else int(report["exit"])


if __name__ == "__main__":
    raise SystemExit(main())
