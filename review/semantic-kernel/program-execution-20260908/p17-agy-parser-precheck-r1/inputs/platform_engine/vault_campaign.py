#!/usr/bin/env python3
"""Vault compile campaign using the shared platform engine.

Mocks and storage seeds are identified separately from captured SUsds.sol.
Does not claim source execution until fixtures are observed on-chain.
"""
from __future__ import annotations

import sys
from pathlib import Path

ENGINE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(ENGINE_DIR))

from common import (  # noqa: E402
    CLOSURE,
    CAPTURE_SRC,
    EVIDENCE,
    SOLC_VAULT,
    SOLC_VAULT_SHA256,
    SUSDS_SHA256,
    blocked,
    sha256_file,
    write_json,
)
from compile import compile_sources, compiler_settings  # noqa: E402


MOCK_FILES = {
    "test/mocks/UsdsMock.sol": CAPTURE_SRC / "test/mocks/UsdsMock.sol",
    "test/mocks/UsdsJoinMock.sol": CAPTURE_SRC / "test/mocks/UsdsJoinMock.sol",
    "test/mocks/VatMock.sol": CAPTURE_SRC / "test/mocks/VatMock.sol",
}


def load_sources() -> tuple[dict[str, str], dict[str, str]]:
    sources: dict[str, str] = {}
    roles: dict[str, str] = {}
    if not CLOSURE.is_dir():
        raise FileNotFoundError(f"missing compile-source-closure: {CLOSURE}")
    for path in sorted(CLOSURE.rglob("*.sol")):
        rel = str(path.relative_to(CLOSURE))
        sources[rel] = path.read_text()
        if rel == "src/SUsds.sol":
            roles[rel] = "captured_source"
        else:
            roles[rel] = "captured_oz_closure"
    for rel, path in MOCK_FILES.items():
        sources[rel] = path.read_text()
        roles[rel] = "generated_mock_not_captured_source"
    return sources, roles


def main() -> int:
    out = EVIDENCE / "evm" / "compile"
    out.mkdir(parents=True, exist_ok=True)
    try:
        sources, roles = load_sources()
    except FileNotFoundError as exc:
        report = blocked(str(exc))
        write_json(out / "compile.json", report)
        print(report["reason"])
        return 3
    susds = CLOSURE / "src/SUsds.sol"
    got = sha256_file(susds)
    if got != SUSDS_SHA256:
        report = blocked(
            "captured SUsds.sol hash drifted",
            {"got": got, "expected": SUSDS_SHA256},
        )
        write_json(out / "compile.json", report)
        print(report["reason"])
        return 3
    settings = compiler_settings(
        evm_version="shanghai",
        optimizer_runs=200,
        bytecode_hash="none",
    )
    report = compile_sources(
        name="vault-solc-0.8.21-shanghai",
        sources=sources,
        source_roles=roles,
        solc=SOLC_VAULT,
        expected_solc_sha=SOLC_VAULT_SHA256,
        settings=settings,
        out_dir=out,
        timeout=60.0,
        required=[
            "src/SUsds.sol:SUsds",
            "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy",
            "test/mocks/UsdsMock.sol:UsdsMock",
            "test/mocks/UsdsJoinMock.sol:UsdsJoinMock",
            "test/mocks/VatMock.sol:VatMock",
        ],
    )
    write_json(out / "result.json", {k: report[k] for k in report if k != "artifacts"})
    print(report.get("status"), report.get("exit"), "contracts", len(report.get("contracts") or []))
    if report.get("status") != "ok" or report.get("exit") != 0:
        return 3 if report.get("exit") in (None, 0) else int(report["exit"])
    from vault_exec import deploy, run_fixtures
    from pathlib import Path as P
    from common import EVIDENCE as EV
    exe = EV / "evm" / "execute"
    exe.mkdir(parents=True, exist_ok=True)
    try:
        deployed = deploy(exe / "deploy")
        scored = run_fixtures(exe / "fixtures", deployed["addresses"], P(deployed["genesis"]))
    except Exception as exc:
        write_json(exe / "score.json", blocked(str(exc)))
        print("execute_blocked", exc)
        return 3
    print("fixture_score", scored.get("status"), scored.get("exit"), scored.get("reason"))
    return int(scored.get("exit", 3))


if __name__ == "__main__":
    raise SystemExit(main())
