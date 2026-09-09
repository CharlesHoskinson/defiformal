#!/usr/bin/env python3
"""Compile Token0Probe with pinned solc 0.7.6 standard-JSON.

Copies frozen probe + captured six-library closure into an overlay. Does not
edit captured library bytes. Empty/malformed compile is blocked 3.
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
import signal
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from p16_common import (
    CAPTURE_ROOT,
    COMPILER_TIMEOUT_SEC,
    EXPECTED_SOLC_SHA256,
    FROZEN_PROBE,
    FROZEN_PROBE_SHA256,
    LIB_NAMES,
    SOLC,
    encode_probe_calldata,
    python_env,
    sha256_bytes,
    sha256_file,
    sha256_text,
    utc_now,
    write_json,
)

COMPILER_SETTINGS = {
    "optimizer": {"enabled": True, "runs": 800},
    "metadata": {"bytecodeHash": "none"},
    "evmVersion": "istanbul",
}


def copy_overlay(dest: Path) -> dict:
    dest.mkdir(parents=True, exist_ok=True)
    copied = []
    probe_dest = dest / "Token0Probe.sol"
    shutil.copy2(FROZEN_PROBE, probe_dest)
    probe_sha = sha256_file(probe_dest)
    if probe_sha != FROZEN_PROBE_SHA256:
        raise SystemExit("blocked: Token0Probe.sol overlay hash drifted")
    copied.append({"name": "Token0Probe.sol", "sha256": probe_sha, "bytes": probe_dest.stat().st_size})
    for name in LIB_NAMES:
        src = CAPTURE_ROOT / "contracts/libraries" / name
        dst = dest / name
        shutil.copy2(src, dst)
        copied.append({"name": name, "sha256": sha256_file(dst), "bytes": dst.stat().st_size, "src": str(src)})
    return {"overlay": str(dest), "files": copied}


def standard_json_input(overlay: Path) -> dict:
    sources = {}
    for name in ["Token0Probe.sol", *LIB_NAMES]:
        path = overlay / name
        sources[name] = {"content": path.read_text()}
    return {
        "language": "Solidity",
        "sources": sources,
        "settings": {
            **COMPILER_SETTINGS,
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


def _kill_group(proc: subprocess.Popen) -> None:
    try:
        pgid = os.getpgid(proc.pid)
    except ProcessLookupError:
        pgid = proc.pid
    if pgid and pgid > 1:
        for sig in (signal.SIGTERM, signal.SIGKILL):
            try:
                os.killpg(pgid, sig)
            except (ProcessLookupError, PermissionError):
                break
    else:
        try:
            proc.kill()
        except OSError:
            pass


def compile_overlay(
    overlay: Path,
    out_dir: Path,
    solc: Path = SOLC,
    timeout: float = COMPILER_TIMEOUT_SEC,
) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    if not solc.is_file():
        report = {
            "status": "blocked_missing_compiler",
            "solc": str(solc),
            "exists": False,
        }
        write_json(out_dir / "compile.json", report)
        return report
    solc_sha = sha256_file(solc)
    if solc_sha != EXPECTED_SOLC_SHA256:
        report = {
            "status": "blocked_compiler_hash_mismatch",
            "solc": str(solc),
            "sha256": solc_sha,
            "expected": EXPECTED_SOLC_SHA256,
        }
        write_json(out_dir / "compile.json", report)
        return report
    inp = standard_json_input(overlay)
    input_bytes = (json.dumps(inp, indent=2) + "\n").encode("utf-8")
    (out_dir / "standard-json-input.json").write_bytes(input_bytes)
    source_hashes = {
        name: sha256_text(body["content"]) for name, body in inp["sources"].items()
    }
    write_json(out_dir / "source-hashes.json", source_hashes)
    argv = [str(solc), "--standard-json"]
    start = utc_now()
    proc = subprocess.Popen(
        argv,
        cwd=str(overlay),
        env=python_env(),
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        start_new_session=True,
    )
    timed_out = False
    try:
        stdout, stderr = proc.communicate(input=input_bytes, timeout=timeout)
    except subprocess.TimeoutExpired:
        timed_out = True
        _kill_group(proc)
        try:
            stdout, stderr = proc.communicate(timeout=1)
        except Exception:
            stdout, stderr = b"", b""
            try:
                proc.kill()
            except OSError:
                pass
    end = utc_now()
    stdout = stdout or b""
    stderr = stderr or b""
    (out_dir / "solc.stdout.bin").write_bytes(stdout)
    (out_dir / "solc.stderr.bin").write_bytes(stderr)
    receipt = {
        "name": "solc-standard-json",
        "argv": argv,
        "cwd": str(overlay),
        "start_utc": start,
        "end_utc": end,
        "timeout": timed_out,
        "exit": None if timed_out else proc.returncode,
        "stdout_path": str(out_dir / "solc.stdout.bin"),
        "stderr_path": str(out_dir / "solc.stderr.bin"),
        "stdout_sha256": sha256_bytes(stdout),
        "stderr_sha256": sha256_bytes(stderr),
        "stdout_bytes": len(stdout),
        "stderr_bytes": len(stderr),
        "solc_sha256": solc_sha,
        "timeout_sec": timeout,
    }
    write_json(out_dir / "solc-receipt.json", receipt)
    if timed_out:
        report = {
            "status": "blocked_compile_timeout",
            "exit": None,
            "timeout": True,
            "stdout_bytes": len(stdout),
            "stderr_bytes": len(stderr),
            "stdout_sha256": sha256_bytes(stdout),
            "stderr_sha256": sha256_bytes(stderr),
            "solc_sha256": solc_sha,
            "argv": argv,
            "start_utc": start,
            "end_utc": end,
            "receipt": str(out_dir / "solc-receipt.json"),
        }
        write_json(out_dir / "compile.json", report)
        return report
    if proc.returncode != 0 or not stdout.strip():
        report = {
            "status": "blocked_compile_empty_or_nonzero",
            "exit": proc.returncode,
            "timeout": False,
            "stdout_bytes": len(stdout),
            "stderr_bytes": len(stderr),
            "stdout_sha256": sha256_bytes(stdout),
            "stderr_sha256": sha256_bytes(stderr),
            "solc_sha256": solc_sha,
            "argv": argv,
            "start_utc": start,
            "end_utc": end,
        }
        write_json(out_dir / "compile.json", report)
        return report
    try:
        output = json.loads(stdout.decode("utf-8"))
    except json.JSONDecodeError as exc:
        report = {
            "status": "blocked_compile_malformed_json",
            "error": str(exc),
            "stdout_sha256": sha256_bytes(stdout),
            "solc_sha256": solc_sha,
        }
        write_json(out_dir / "compile.json", report)
        return report
    (out_dir / "standard-json-output.json").write_bytes(stdout)
    errors = output.get("errors") or []
    severe = [e for e in errors if e.get("severity") in ("error", "Error")]
    contracts = (output.get("contracts") or {}).get("Token0Probe.sol") or {}
    probe = contracts.get("Token0Probe") or {}
    evm = probe.get("evm") or {}
    creation = ((evm.get("bytecode") or {}).get("object")) or ""
    runtime = ((evm.get("deployedBytecode") or {}).get("object")) or ""
    methods = evm.get("methodIdentifiers") or {}
    abi = probe.get("abi") or []
    if severe or not runtime:
        report = {
            "status": "blocked_compile_error_or_empty_bytecode",
            "errors": severe,
            "all_errors": errors,
            "runtime_empty": not bool(runtime),
            "creation_empty": not bool(creation),
            "solc_sha256": solc_sha,
            "argv": argv,
            "start_utc": start,
            "end_utc": end,
        }
        write_json(out_dir / "compile.json", report)
        return report
    creation_hex = creation.lower().removeprefix("0x")
    runtime_hex = runtime.lower().removeprefix("0x")
    (out_dir / "creation.hex").write_text(creation_hex + "\n")
    (out_dir / "runtime.hex").write_text(runtime_hex + "\n")
    selector = methods.get("probe(uint160,uint128,uint256,bool)")
    write_json(out_dir / "abi.json", abi)
    write_json(out_dir / "methodIdentifiers.json", methods)
    report = {
        "status": "compiled",
        "argv": argv,
        "cwd": str(overlay),
        "start_utc": start,
        "end_utc": end,
        "exit": proc.returncode,
        "solc": str(solc),
        "solc_sha256": solc_sha,
        "settings": COMPILER_SETTINGS,
        "source_hashes": source_hashes,
        "creation_bytecode_sha256": sha256_bytes(bytes.fromhex(creation_hex)),
        "runtime_bytecode_sha256": sha256_bytes(bytes.fromhex(runtime_hex)),
        "creation_hex_sha256": sha256_text(creation_hex + "\n"),
        "runtime_hex_sha256": sha256_text(runtime_hex + "\n"),
        "creation_bytes": len(creation_hex) // 2,
        "runtime_bytes": len(runtime_hex) // 2,
        "methodIdentifiers": methods,
        "probe_selector": selector,
        "selector_source": "compiler_methodIdentifiers",
        "abi": abi,
        "errors_nonfatal": [e for e in errors if e not in severe],
        "standard_json_input_sha256": sha256_bytes(input_bytes),
        "standard_json_output_sha256": sha256_bytes(stdout),
        "stderr_sha256": sha256_bytes(stderr),
        "timeout": False,
        "receipt": str(out_dir / "solc-receipt.json"),
        "note": "creation bytecode and deployed runtime bytecode are distinct hashes",
    }
    write_json(out_dir / "compile.json", report)
    write_json(
        out_dir / "bytecode-hashes.json",
        {
            "creation_bytecode_sha256": report["creation_bytecode_sha256"],
            "runtime_bytecode_sha256": report["runtime_bytecode_sha256"],
            "creation_bytes": report["creation_bytes"],
            "runtime_bytes": report["runtime_bytes"],
        },
    )
    if selector:
        sample = encode_probe_calldata(selector, 1, 1, 1, True)
        write_json(
            out_dir / "calldata-encoding.json",
            {
                "signature": "probe(uint160,uint128,uint256,bool)",
                "selector": selector,
                "selector_source": "compiler_methodIdentifiers_not_sha3",
                "encoding": "ABI 4-byte selector plus four 32-byte words",
                "sample_add_1_1_1_true_hex": sample.hex(),
            },
        )
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--overlay", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--solc", default=str(SOLC))
    parser.add_argument("--prepare-overlay", action="store_true")
    args = parser.parse_args()
    overlay = Path(args.overlay)
    out = Path(args.out)
    if args.prepare_overlay:
        copy_overlay(overlay)
    report = compile_overlay(overlay, out, Path(args.solc))
    print(json.dumps({"status": report.get("status"), "runtime": report.get("runtime_bytecode_sha256")}))
    if report.get("status") != "compiled":
        return 3
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
