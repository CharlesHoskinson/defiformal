#!/usr/bin/env python3
"""Shared EVM run/classify/dump for token0 and vault.

P16 r6: duplicate empty output is blocked BEFORE known-EVM-error classification.
Dump JSON is not genesis; convert accounts to alloc. Dump steals stdout.
"""
from __future__ import annotations

import json
import re
from copy import deepcopy
from pathlib import Path
from typing import Any

from abi import decode_revert_payload
from common import (
    EVM,
    EVM_SHA256,
    blocked,
    pin_tool,
    record_cmd,
    sha256_text,
    write_json,
)
from prestate import (
    ISTANBUL_GENESIS_TEMPLATE,
    SHANGHAI_GENESIS_TEMPLATE,
    dump_to_alloc,
)

ABI_WORD = re.compile(r"^0x[0-9a-fA-F]{64}$")
EMPTY_HEX = re.compile(r"^0x$", re.IGNORECASE)
ERROR_REVERT = "error: execution reverted"
ERROR_INVALID = "error: invalid opcode: invalid"
GAS_LIMIT = 10_000_000_000


def _blocked(klass: str, reason: str, extra: dict | None = None) -> dict:
    return {"class": klass, "status": "blocked", "reason": reason, **(extra or {})}


def classify_evm_stdout(
    stdout: str,
    process_exit: int | None,
    timeout: bool,
    *,
    receipt: dict | None = None,
    purpose: str = "call",
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
            {"process_exit": process_exit, "wrapper_exit": wrapper_exit},
        )
    if process_exit != 0:
        return _blocked(
            "process_failure",
            "evm process failed before a classified semantic observation",
            {"process_exit": process_exit, "wrapper_exit": wrapper_exit},
        )

    nonempty = [ln.strip() for ln in stdout.splitlines() if ln.strip()]
    abi_words = []
    revert_hex = []
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
        elif lower.startswith("0x") and len(lower) > 2 and len(lower) % 2 == 0 and all(c in "0123456789abcdef" for c in lower[2:]):
            revert_hex.append(lower)
        else:
            extra.append(stripped)
    if extra:
        return _blocked(
            "unknown_output",
            "extra unmatched EVM protocol output is not a recognized result",
            {"stdout": stdout, "extra": extra, "process_exit": process_exit},
        )
    if len(empty_hex) > 1:
        return _blocked(
            "unknown_output",
            "duplicate empty EVM payload records are ambiguous protocol output",
            {"empty_payloads": empty_hex, "process_exit": process_exit},
        )
    if len(abi_words) > 1:
        return _blocked(
            "unknown_output",
            "duplicate EVM returndata lines are ambiguous protocol output",
            {"returndata": abi_words, "process_exit": process_exit},
        )
    if len(revert_hex) > 1:
        return _blocked(
            "unknown_output",
            "duplicate EVM returndata lines are ambiguous protocol output",
            {"returndata": revert_hex, "process_exit": process_exit},
        )
    if (abi_words or revert_hex) and empty_hex:
        return _blocked(
            "unknown_output",
            "ABI word and empty 0x together are extra protocol output",
            {"returndata": abi_words or revert_hex, "process_exit": process_exit},
        )
    if abi_words and revert_hex:
        return _blocked(
            "unknown_output",
            "duplicate EVM returndata lines are ambiguous protocol output",
            {"returndata": abi_words + revert_hex, "process_exit": process_exit},
        )
    if len(error_lines) > 1:
        return _blocked(
            "unknown_output",
            "duplicate EVM error lines are ambiguous protocol output",
            {"errors": error_lines, "process_exit": process_exit},
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
        payload = abi_words[0] if abi_words else (revert_hex[0] if revert_hex else "0x")
        if err_l == ERROR_INVALID:
            if abi_words or revert_hex:
                return _blocked(
                    "unknown_output",
                    "extra unmatched EVM protocol output is not a recognized result",
                    {"extra": abi_words + revert_hex, "stdout": stdout, "process_exit": process_exit},
                )
            return {
                "class": "evm_exception",
                "status": "exception",
                "returndata": "0x",
                "error": err_line,
                "reason": "semantic EVM exceptional halt (not a host process crash)",
                "process_exit": process_exit,
            }
        if payload == "0x":
            return {
                "class": "evm_revert",
                "status": "revert",
                "returndata": "0x",
                "error": err_line,
                "decoded_error": None,
                "selector": None,
                "reason": "semantic EVM revert; process may still exit 0",
                "process_exit": process_exit,
            }
        decoded = decode_revert_payload(payload)
        if decoded is not None:
            return {
                "class": "evm_revert",
                "status": "revert",
                "returndata": payload,
                "error": err_line,
                "decoded_error": decoded["decoded_error"],
                "selector": decoded["selector"],
                "reason": "semantic EVM revert with decoded error",
                "process_exit": process_exit,
            }
        if len(payload) == 66:
            return {
                "class": "evm_revert",
                "status": "revert",
                "returndata": payload,
                "error": err_line,
                "decoded_error": None,
                "selector": None,
                "reason": "semantic EVM revert; process may still exit 0",
                "process_exit": process_exit,
            }
        return _blocked(
            "unknown_output",
            "unrecognized or malformed EVM revert payload",
            {"payload": payload, "stdout": stdout, "process_exit": process_exit},
        )

    if revert_hex:
        return _blocked(
            "unknown_output",
            "non-32-byte returndata without revert error line is not a recognized ABI result",
            {"returndata": revert_hex, "stdout": stdout, "process_exit": process_exit},
        )

    emptyish = not nonempty or nonempty == ["0x"]
    if emptyish:
        if purpose in ("genesis_stop", "create"):
            return {
                "class": "stop_or_create",
                "status": "ok",
                "returndata": "0x",
                "reason": "empty returndata with process exit 0",
                "process_exit": process_exit,
            }
        return _blocked(
            "unknown_output",
            "empty or STOP-like returndata is not a recognized ABI result",
            {"stdout": stdout, "process_exit": process_exit},
        )
    if len(abi_words) == 1:
        return {
            "class": "success",
            "status": "ok",
            "returndata": abi_words[0],
            "reason": "ABI-encoded returndata, no EVM error line",
            "process_exit": process_exit,
        }
    return _blocked(
        "unknown_output",
        "unrecognized EVM stdout is not a success, revert, exception, or empty create",
        {"stdout": stdout, "process_exit": process_exit},
    )


def write_genesis(path: Path, *, fork: str, alloc: dict, timestamp: int = 0) -> dict:
    if fork == "shanghai":
        genesis = deepcopy(SHANGHAI_GENESIS_TEMPLATE)
    elif fork == "istanbul":
        genesis = deepcopy(ISTANBUL_GENESIS_TEMPLATE)
    else:
        raise ValueError(f"unknown fork {fork}")
    genesis["alloc"] = alloc
    genesis["timestamp"] = hex(timestamp)
    text = json.dumps(genesis, indent=2) + "\n"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    binding = {
        "fork": fork,
        "path": str(path),
        "sha256": sha256_text(text),
        "bytes": len(text.encode("utf-8")),
        "timestamp": timestamp,
        "alloc_accounts": sorted(alloc),
    }
    write_json(path.with_name("genesis-binding.json"), binding)
    return binding


def parse_dump(stdout: str) -> dict | None:
    text = stdout.strip()
    if not text:
        return None
    try:
        obj = json.loads(text)
    except json.JSONDecodeError:
        start = text.find("{")
        end = text.rfind("}")
        if start < 0 or end <= start:
            return None
        try:
            obj = json.loads(text[start : end + 1])
        except json.JSONDecodeError:
            return None
    if not isinstance(obj, dict) or "accounts" not in obj:
        return None
    return obj


def run_tx(
    name: str,
    *,
    out_dir: Path,
    genesis_path: Path,
    sender: str,
    receiver: str | None,
    code_hex: str | None,
    input_hex: str,
    create: bool,
    dump: bool,
    timeout: float = 30.0,
    purpose: str = "call",
    timestamp: int | None = None,
    trace: bool = False,
) -> dict:
    out_dir = Path(out_dir).resolve()
    genesis_path = Path(genesis_path).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    try:
        pin_tool(EVM, EVM_SHA256, "evm")
    except Exception as exc:
        report = blocked(str(exc))
        write_json(out_dir / "observation.json", report)
        return report
    argv = [str(EVM), "run", "--prestate", str(genesis_path), "--gas", str(GAS_LIMIT), "--sender", sender]
    if trace:
        argv.extend(["--trace", "--nomemory=false"])
    if create:
        argv.append("--create")
    if receiver:
        argv.extend(["--receiver", receiver])
    if code_hex is not None:
        code_path = out_dir / "code.hex"
        code_path.write_text(code_hex + "\n")
        argv.extend(["--codefile", str(code_path)])
    input_path = out_dir / "input.hex"
    input_path.write_text(input_hex + "\n")
    argv.extend(["--inputfile", str(input_path)])
    if dump:
        argv.append("--dump")
    if timestamp is not None:
        # geth uses genesis timestamp; extra flag ignored if absent
        pass
    rec = record_cmd(name, argv, cwd=out_dir, out_dir=out_dir / "record", timeout=timeout)
    stdout_path = Path((rec.get("_wrapper") or {}).get("stdout_path") or "")
    stdout = stdout_path.read_text(errors="replace") if stdout_path.is_file() else ""
    dump_obj = parse_dump(stdout) if dump else None
    if dump:
        if dump_obj is None:
            obs = blocked("missing or unusable evm dump JSON", {"class": "blocked_missing_evm"})
            write_json(out_dir / "observation.json", obs)
            return {**obs, "receipt": rec, "stdout": stdout[:2000]}
        alloc = dump_to_alloc(dump_obj)
        write_json(out_dir / "dump.json", {"root": dump_obj.get("root"), "n_accounts": len(alloc)})
        write_json(out_dir / "alloc.json", alloc)
        return {
            "status": "ok",
            "class": "dump",
            "alloc": alloc,
            "root": dump_obj.get("root"),
            "receipt": rec,
        }
    trace_stderr = ""
    if trace:
        stderr_path = Path((rec.get("_wrapper") or {}).get("stderr_path") or "")
        trace_stderr = stderr_path.read_text(errors="replace") if stderr_path.is_file() else ""
        if not stdout.strip():
            for line in reversed(trace_stderr.splitlines()):
                line = line.strip()
                if line.startswith("{") and "output" in line:
                    try:
                        out_info = json.loads(line)
                        if "output" in out_info:
                            out_hex = "0x" + out_info["output"]
                            if out_info.get("error"):
                                stdout = f"error: {out_info['error']}\n{out_hex}\n"
                            else:
                                stdout = f"{out_hex}\n"
                            break
                    except Exception:
                        pass
    obs = classify_evm_stdout(
        stdout,
        rec.get("exit"),
        bool(rec.get("timeout")),
        receipt=rec,
        purpose=purpose,
    )
    if trace:
        obs["trace_stderr"] = trace_stderr
    write_json(out_dir / "observation.json", obs)
    return {**obs, "receipt": rec}
