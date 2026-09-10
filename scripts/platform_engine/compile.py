#!/usr/bin/env python3
"""Parameterized solc standard-JSON compile for token0 and vault.

Compiler identity is the pinned binary hash plus settings, not a host path.
Empty or malformed compiler output is blocked 3, never semantic 0/1.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from common import (
    SetupBlocked,
    blocked,
    pin_tool,
    record_cmd,
    sha256_text,
    write_json,
)


def compiler_settings(
    *,
    evm_version: str,
    optimizer_runs: int,
    bytecode_hash: str,
    optimizer: bool = True,
) -> dict:
    return {
        "optimizer": {"enabled": optimizer, "runs": optimizer_runs},
        "metadata": {"bytecodeHash": bytecode_hash},
        "evmVersion": evm_version,
    }


def standard_json_input(sources: dict[str, str], settings: dict) -> dict:
    if not sources:
        raise SetupBlocked("empty compile sources")
    return {
        "language": "Solidity",
        "sources": {name: {"content": body} for name, body in sources.items()},
        "settings": {
            **settings,
            "outputSelection": {
                "*": {
                    "*": [
                        "abi",
                        "evm.bytecode.object",
                        "evm.deployedBytecode.object",
                        "evm.methodIdentifiers",
                        "metadata",
                    ]
                }
            },
        },
    }


def compile_sources(
    *,
    name: str,
    sources: dict[str, str],
    source_roles: dict[str, str],
    solc: Path,
    expected_solc_sha: str,
    settings: dict,
    out_dir: Path,
    timeout: float = 60.0,
    required: list[str] | None = None,
) -> dict:
    out_dir = Path(out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    try:
        pin = pin_tool(solc, expected_solc_sha, "solc")
    except SetupBlocked as exc:
        report = blocked(exc.reason, exc.extra)
        write_json(out_dir / "compile.json", report)
        return report
    try:
        inp = standard_json_input(sources, settings)
    except SetupBlocked as exc:
        report = blocked(exc.reason, exc.extra)
        write_json(out_dir / "compile.json", report)
        return report
    input_bytes = (json.dumps(inp, indent=2) + "\n").encode("utf-8")
    (out_dir / "standard-json-input.json").write_bytes(input_bytes)
    source_hashes = {name_: sha256_text(body) for name_, body in sources.items()}
    write_json(out_dir / "source-hashes.json", source_hashes)
    write_json(out_dir / "source-roles.json", source_roles)
    stdin_path = out_dir / "standard-json-input.json"
    rec = record_cmd(
        name,
        ["sh", "-c", f'exec "{solc}" --standard-json < "{stdin_path}"'],
        cwd=out_dir,
        out_dir=out_dir / "record",
        timeout=timeout,
    )
    if rec.get("valid") is False or rec.get("classification") in (
        "timeout_blocked",
        "cancelled",
        "crash",
        "blocked",
    ):
        report = blocked(
            rec.get("reason") or "compiler invocation blocked",
            {"receipt": rec.get("classification"), "exit": rec.get("exit")},
        )
        write_json(out_dir / "compile.json", report)
        return report
    stdout_path = Path(rec["_wrapper"]["stdout_path"])
    raw = stdout_path.read_bytes() if stdout_path.is_file() else b""
    if not raw:
        report = blocked("empty compiler stdout", {"exit": rec.get("exit")})
        write_json(out_dir / "compile.json", report)
        return report
    try:
        parsed = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        report = blocked("malformed compiler JSON", {"error": str(exc)})
        write_json(out_dir / "compile.json", report)
        return report
    errors = [e for e in parsed.get("errors", []) if e.get("severity") == "error"]
    contracts = parsed.get("contracts") or {}
    if errors or rec.get("exit") not in (0, None):
        report = blocked(
            "compiler reported errors; not a semantic source result",
            {"errors": [e.get("formattedMessage") or e.get("message") for e in errors], "exit": rec.get("exit")},
        )
        write_json(out_dir / "compile.json", report)
        return report
    if not contracts:
        report = blocked("compiler produced no contracts", {"exit": rec.get("exit")})
        write_json(out_dir / "compile.json", report)
        return report
    artifacts = {}
    for file_name, cmap in contracts.items():
        for cname, body in cmap.items():
            evm = body.get("evm") or {}
            creation = ((evm.get("bytecode") or {}).get("object")) or ""
            runtime = ((evm.get("deployedBytecode") or {}).get("object")) or ""
            if not creation or not runtime:
                continue
            artifacts[f"{file_name}:{cname}"] = {
                "abi": body.get("abi") or [],
                "creation": creation,
                "runtime": runtime,
                "methodIdentifiers": evm.get("methodIdentifiers") or {},
            }
    if required:
        missing = [key for key in required if key not in artifacts]
        if missing:
            report = blocked(
                "required contracts missing bytecode",
                {"missing": missing, "have": sorted(artifacts)},
            )
            write_json(out_dir / "compile.json", report)
            return report
    bytecode_sha256 = {
        key: {
            "creation": sha256_text(body["creation"]),
            "runtime": sha256_text(body["runtime"]),
        }
        for key, body in artifacts.items()
    }
    report = {
        "status": "ok",
        "exit": 0,
        "solc": pin,
        "settings": settings,
        "source_hashes": source_hashes,
        "source_roles": source_roles,
        "contracts": sorted(artifacts),
        "bytecode_sha256": bytecode_sha256,
        "artifacts": artifacts,
    }
    write_json(out_dir / "compile.json", report)
    return report
