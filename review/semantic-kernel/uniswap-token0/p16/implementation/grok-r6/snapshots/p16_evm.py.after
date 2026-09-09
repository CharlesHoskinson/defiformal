#!/usr/bin/env python3
"""Run compiled Token0Probe runtime bytecode under an explicit Istanbul genesis.

Process failure is distinct from a semantic EVM revert or exception. go-ethereum
evm run prints returndata and an error line but still exits 0 on revert.
Invalid invocation evidence is never classified as a semantic result.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from p16_common import (
    EVM,
    EXPECTED_EVM_SHA256,
    GAS_LIMIT,
    RECEIVER,
    SENDER,
    decode_uint160,
    encode_probe_calldata,
    invocation_is_complete,
    invocation_is_successful,
    record_cmd,
    sha256_file,
    sha256_text,
    write_json,
)

ISTANBUL_GENESIS = {
    "config": {
        "chainId": 1,
        "homesteadBlock": 0,
        "eip150Block": 0,
        "eip155Block": 0,
        "eip158Block": 0,
        "byzantiumBlock": 0,
        "constantinopleBlock": 0,
        "petersburgBlock": 0,
        "istanbulBlock": 0,
    },
    "nonce": "0x0",
    "timestamp": "0x0",
    "extraData": "0x",
    "gasLimit": hex(GAS_LIMIT),
    "difficulty": "0x1",
    "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "coinbase": "0x0000000000000000000000000000000000000000",
    "alloc": {},
    "number": "0x0",
    "gasUsed": "0x0",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
}

FORK_BINDING = {
    "selected_fork": "istanbul",
    "compiler_evmVersion": "istanbul",
    "compiler_evmVersion_establishes_execution_fork": False,
    "genesis_config_fields_set": [
        "chainId",
        "homesteadBlock",
        "eip150Block",
        "eip155Block",
        "eip158Block",
        "byzantiumBlock",
        "constantinopleBlock",
        "petersburgBlock",
        "istanbulBlock",
    ],
    "later_forks_omitted_nil": [
        "muirGlacierBlock",
        "berlinBlock",
        "londonBlock",
        "arrowGlacierBlock",
        "grayGlacierBlock",
        "mergeNetsplitBlock",
        "shanghaiTime",
        "cancunTime",
        "pragueTime",
        "osakaTime",
        "verkleTime",
    ],
    "absent_prestate_would_use": "params.AllDevChainProtocolChanges",
    "prestate_supplied": True,
    "time": 0,
    "number": 0,
    "gasLimit": GAS_LIMIT,
    "sender": SENDER,
    "receiver": RECEIVER,
    "note": "istanbulBlock=0 with later forks omitted is the bound execution fork. Compiler evmVersion is a separate compile setting.",
}

ABI_WORD = re.compile(r"^0x[0-9a-fA-F]{64}$")
EMPTY_HEX = re.compile(r"^0x$", re.IGNORECASE)
ERROR_REVERT = "error: execution reverted"
ERROR_INVALID = "error: invalid opcode: invalid"


def _blocked(klass: str, reason: str, extra: dict | None = None) -> dict:
    return {"class": klass, "status": "blocked", "reason": reason, **(extra or {})}


def classify_evm_stdout(
    stdout: str,
    process_exit: int | None,
    timeout: bool,
    *,
    receipt: dict | None = None,
    purpose: str = "token0_probe",
) -> dict:
    rec = receipt or {}
    wrapper_exit = (rec.get("_wrapper") or {}).get("wrapper_exit")
    cancelled = bool(rec.get("cancelled"))
    classification = rec.get("classification")
    if rec and rec.get("valid") is False:
        return _blocked(
            "invalid_invocation",
            rec.get("reason") or "current invocation receipt is not valid",
            {"wrapper_exit": wrapper_exit, "recorder_classification": classification},
        )
    if timeout or classification == "timeout_blocked":
        return _blocked(
            "process_timeout",
            "evm process timeout is setup/blocked, not a semantic mutant detection",
            {"process_exit": process_exit, "wrapper_exit": wrapper_exit},
        )
    if cancelled or classification == "cancelled":
        return _blocked(
            "process_cancelled",
            "evm process cancellation is setup/blocked, not a semantic observation",
            {"process_exit": process_exit, "wrapper_exit": wrapper_exit},
        )
    if classification == "crash" or (isinstance(process_exit, int) and process_exit < 0) or process_exit is None:
        return _blocked(
            "process_crash",
            "crash or unknown child exit is setup/blocked; partial stdout is not a semantic revert",
            {
                "process_exit": process_exit,
                "wrapper_exit": wrapper_exit,
                "stdout_bytes": len(stdout.encode("utf-8", "replace")),
            },
        )
    if rec and not invocation_is_complete(rec):
        return _blocked(
            "invalid_invocation",
            rec.get("reason") or "invocation is not a completed pinned EVM run",
            {"process_exit": process_exit, "wrapper_exit": wrapper_exit},
        )
    if process_exit != 0:
        return _blocked(
            "process_failure",
            "evm process failed before a classified semantic observation",
            {"process_exit": process_exit, "wrapper_exit": wrapper_exit, "stdout": stdout},
        )
    if wrapper_exit not in (0, None) and wrapper_exit != 0:
        return _blocked(
            "invalid_invocation",
            "wrapper exit is not success for a semantic EVM observation",
            {"wrapper_exit": wrapper_exit, "process_exit": process_exit},
        )
    if rec and not invocation_is_successful(rec):
        return _blocked(
            "invalid_invocation",
            rec.get("reason")
            or "child/wrapper/classification are not a successful source execution",
            {
                "process_exit": process_exit,
                "wrapper_exit": wrapper_exit,
                "recorder_classification": classification,
            },
        )

    nonempty = [ln.strip() for ln in stdout.splitlines() if ln.strip()]
    abi_words = []
    empty_hex = []
    error_lines = []
    extra = []
    for stripped in nonempty:
        lower = stripped.lower()
        if ABI_WORD.match(stripped):
            abi_words.append(lower)
        elif EMPTY_HEX.match(stripped):
            empty_hex.append("0x")
        elif lower.startswith("error:"):
            error_lines.append(stripped)
        else:
            extra.append(stripped)
    if extra:
        return _blocked(
            "unknown_output",
            "extra unmatched EVM protocol output is not a recognized token0 result",
            {"stdout": stdout, "extra": extra, "process_exit": process_exit},
        )
    if len(abi_words) > 1:
        return _blocked(
            "unknown_output",
            "duplicate EVM returndata lines are ambiguous protocol output",
            {"returndata": abi_words, "process_exit": process_exit},
        )
    if len(error_lines) > 1:
        return _blocked(
            "unknown_output",
            "duplicate EVM error lines are ambiguous protocol output",
            {"errors": error_lines, "process_exit": process_exit},
        )
    if len(empty_hex) > 1:
        return _blocked(
            "unknown_output",
            "duplicate empty EVM payload records are ambiguous protocol output",
            {"empty_payloads": empty_hex, "process_exit": process_exit},
        )
    if abi_words and empty_hex:
        return _blocked(
            "unknown_output",
            "ABI word and empty 0x together are extra protocol output",
            {"returndata": abi_words, "process_exit": process_exit},
        )

    if error_lines:
        err_line = error_lines[0]
        err_l = err_line.lower()
        if err_l not in {ERROR_REVERT, ERROR_INVALID}:
            return _blocked(
                "unknown_output",
                "unrecognized EVM error text is not a documented revert or INVALID opcode",
                {"error": err_line, "stdout": stdout, "process_exit": process_exit},
            )
        if purpose == "genesis_stop":
            return _blocked(
                "unknown_output",
                "genesis STOP smoke is not a revert or exceptional halt",
                {"error": err_line},
            )
        payload = abi_words[0] if abi_words else "0x"
        if err_l == ERROR_REVERT:
            return {
                "class": "evm_revert",
                "status": "revert",
                "returndata": payload,
                "error": err_line,
                "reason": "semantic EVM revert; process may still exit 0",
                "process_exit": process_exit,
            }
        return {
            "class": "evm_exception",
            "status": "exception",
            "returndata": payload,
            "error": err_line,
            "reason": "semantic EVM exceptional halt (not a host process crash)",
            "process_exit": process_exit,
        }

    emptyish = not nonempty or nonempty == ["0x"]
    if emptyish:
        if purpose == "genesis_stop":
            return {
                "class": "stop_smoke",
                "status": "ok",
                "returndata": "0x",
                "reason": "STOP smoke: empty returndata, no error, process exit 0",
                "process_exit": process_exit,
            }
        return _blocked(
            "unknown_output",
            "empty or STOP-like returndata is not a recognized token0 ABI uint160 result",
            {"stdout": stdout, "process_exit": process_exit},
        )
    if len(abi_words) == 1:
        hex_line = abi_words[0]
        if purpose == "genesis_stop":
            return _blocked(
                "unknown_output",
                "genesis STOP smoke produced a 32-byte word, not empty STOP output",
                {"returndata": hex_line},
            )
        value = decode_uint160(hex_line)
        if value is None:
            return _blocked(
                "malformed_output",
                "returndata is 32 bytes but is not a valid ABI uint160 word",
                {"returndata": hex_line, "process_exit": process_exit},
            )
        return {
            "class": "success",
            "status": "ok",
            "returndata": hex_line,
            "uint160": value,
            "reason": "ABI-encoded uint160 returndata, no EVM error line",
            "process_exit": process_exit,
        }
    return _blocked(
        "unknown_output",
        "unrecognized EVM stdout is not a token0 success, revert, exception, or STOP smoke",
        {"stdout": stdout, "process_exit": process_exit},
    )


def write_genesis(path: Path) -> dict:
    text = json.dumps(ISTANBUL_GENESIS, indent=2) + "\n"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    binding = {
        **FORK_BINDING,
        "path": str(path),
        "sha256": sha256_text(text),
        "bytes": len(text.encode("utf-8")),
        "genesis": ISTANBUL_GENESIS,
    }
    write_json(path.with_name("genesis-binding.json"), binding)
    return binding


def run_probe(
    name: str,
    runtime_hex_path: Path,
    calldata_hex: str,
    genesis_path: Path,
    out_dir: Path,
    evm: Path = EVM,
    timeout: float = 30.0,
    purpose: str = "token0_probe",
) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    if not evm.is_file():
        report = {"status": "blocked_missing_evm", "evm": str(evm), "observation": _blocked("invalid_invocation", "missing evm")}
        write_json(out_dir / "observation.json", report)
        return report
    evm_sha = sha256_file(evm)
    if evm_sha != EXPECTED_EVM_SHA256:
        report = {
            "status": "blocked_evm_hash_mismatch",
            "sha256": evm_sha,
            "expected": EXPECTED_EVM_SHA256,
            "observation": _blocked("invalid_invocation", "evm hash mismatch"),
        }
        write_json(out_dir / "observation.json", report)
        return report
    calldata_path = out_dir / "calldata.hex"
    calldata_path.write_text(calldata_hex + "\n")
    argv = [
        str(evm),
        "run",
        "--prestate",
        str(genesis_path),
        "--codefile",
        str(runtime_hex_path),
        "--inputfile",
        str(calldata_path),
        "--gas",
        str(GAS_LIMIT),
        "--sender",
        SENDER,
        "--receiver",
        RECEIVER,
    ]
    receipt = record_cmd(name, argv, cwd=out_dir, out_dir=out_dir / "record", timeout=timeout)
    stdout_path = Path((receipt.get("_wrapper") or {}).get("stdout_path") or "")
    stdout = stdout_path.read_text(errors="replace") if stdout_path.is_file() else ""
    classification = classify_evm_stdout(
        stdout,
        receipt.get("exit"),
        bool(receipt.get("timeout")),
        receipt=receipt,
        purpose=purpose,
    )
    status = "blocked" if classification.get("status") == "blocked" else "observed"
    report = {
        "name": name,
        "argv": argv,
        "evm": str(evm),
        "evm_sha256": evm_sha,
        "runtime_hex_path": str(runtime_hex_path),
        "runtime_hex_sha256": sha256_file(runtime_hex_path),
        "genesis_path": str(genesis_path),
        "genesis_sha256": sha256_file(genesis_path),
        "calldata_hex": calldata_hex,
        "calldata_sha256": sha256_text(calldata_hex + "\n"),
        "selected_fork": "istanbul",
        "gas": GAS_LIMIT,
        "sender": SENDER,
        "receiver": RECEIVER,
        "process_exit": receipt.get("exit"),
        "wrapper_exit": (receipt.get("_wrapper") or {}).get("wrapper_exit"),
        "timeout": receipt.get("timeout"),
        "cancelled": receipt.get("cancelled"),
        "receipt_valid": bool(receipt.get("valid")),
        "receipt_reason": receipt.get("reason"),
        "recorder_classification": receipt.get("classification"),
        "status": status,
        "observation": classification,
        "stdout_sha256": receipt.get("stdout_sha256") if receipt.get("valid") else (sha256_text(stdout) if stdout_path.is_file() else None),
        "stderr_sha256": receipt.get("stderr_sha256") if receipt.get("valid") else None,
        "start_utc": receipt.get("start_utc"),
        "end_utc": receipt.get("end_utc"),
        "model_failure_names_are_not_source_payloads": True,
        "purpose": purpose,
    }
    write_json(out_dir / "observation.json", report)
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--name", required=True)
    parser.add_argument("--runtime", required=True)
    parser.add_argument("--selector", required=True)
    parser.add_argument("--sqrt", required=True)
    parser.add_argument("--liquidity", required=True)
    parser.add_argument("--amount", required=True)
    parser.add_argument("--add", required=True, choices=["true", "false"])
    parser.add_argument("--genesis", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args()
    calldata = encode_probe_calldata(
        args.selector,
        int(args.sqrt),
        int(args.liquidity),
        int(args.amount),
        args.add == "true",
    )
    report = run_probe(
        args.name,
        Path(args.runtime),
        calldata.hex(),
        Path(args.genesis),
        Path(args.out),
    )
    print(json.dumps({"name": args.name, "observation": report.get("observation")}))
    if report.get("status", "").startswith("blocked") or report.get("observation", {}).get("status") == "blocked":
        return 3
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
