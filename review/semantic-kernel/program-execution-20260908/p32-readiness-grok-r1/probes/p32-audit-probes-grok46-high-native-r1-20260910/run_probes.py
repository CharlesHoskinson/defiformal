#!/usr/bin/env python3
"""Independent P32 readiness audit probes. Does not run capture.py. Does not compile."""
from __future__ import annotations

import datetime
import hashlib
import json
import os
import shutil
import stat
import subprocess
import sys
from pathlib import Path

UTC = datetime.timezone.utc
now = lambda: datetime.datetime.now(UTC).isoformat()
sha256 = lambda b: hashlib.sha256(b).hexdigest()
file_sha = lambda p: sha256(Path(p).read_bytes())

PROBE = Path(__file__).resolve().parent
EVIDENCE = PROBE.parents[1]
SANDBOX = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p32-readiness-grok-r1-sandbox")
INPUTS = EVIDENCE / "inputs.json"
PREP = SANDBOX / "review/semantic-kernel/program-execution-20260908/p32-readiness-preparation"
P16 = SANDBOX / "review/semantic-kernel/uniswap-token0/p16/implementation/grok-r6"
UPSTREAM = SANDBOX / "review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream"
OVERLAY = P16 / "compiler/baseline/overlay"
TOOLS = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p16-tools")
SOLC = TOOLS / "solc-linux-amd64-v0.7.6+commit.7338295f"
EVM = TOOLS / "evm"
GROUPS = {
    "evm": ["forge", "cast", "anvil", "solc", "evm"],
    "solana": ["solana", "cargo-build-sbf", "anchor", "agave-validator", "solana-test-validator"],
    "cosmos": ["gaiad", "osmosisd", "wasmd", "hermes"],
    "move-sui": ["sui", "aptos", "move"],
    "sovereign-cross-chain": ["polkadot", "substrate", "cardano-node", "cardano-cli"],
    "payment-channel": ["bitcoind", "bitcoin-cli", "lnd", "lncli", "lightningd", "lightning-cli"],
}
ROOTS = [
    Path("/home/charl/.local/bin"),
    Path("/home/charl/.cargo/bin"),
    Path("/usr/local/bin"),
    TOOLS,
]
GENERIC = ["rustc", "cargo", "go", "python3"]

commands = []


def write_bytes(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


def record_cmd(label: str, argv, cwd, started, finished, exit_code, stdout: bytes, stderr: bytes, extra=None):
    stdout_path = PROBE / "cmd" / f"{label}.stdout"
    stderr_path = PROBE / "cmd" / f"{label}.stderr"
    write_bytes(stdout_path, stdout)
    write_bytes(stderr_path, stderr)
    tool_path = None
    tool_hash = None
    if argv:
        cand = Path(argv[0])
        if cand.is_file():
            tool_path = str(cand)
            tool_hash = file_sha(cand)
    rec = {
        "id": label,
        "label": label,
        "argv": list(argv) if argv is not None else None,
        "cwd": str(cwd) if cwd is not None else None,
        "started_utc": started,
        "finished_utc": finished,
        "exit": exit_code,
        "tool_path": tool_path,
        "tool_sha256": tool_hash,
        "source_sha256": None,
        "stdout_path": str(stdout_path),
        "stderr_path": str(stderr_path),
        "stdout_sha256": file_sha(stdout_path),
        "stderr_sha256": file_sha(stderr_path),
        "stdout_bytes": len(stdout),
        "stderr_bytes": len(stderr),
    }
    if extra:
        rec.update(extra)
    commands.append(rec)
    return rec


def run(label: str, argv, cwd):
    started = now()
    try:
        res = subprocess.run(argv, cwd=str(cwd), capture_output=True, timeout=30)
        finished = now()
        return record_cmd(label, argv, cwd, started, finished, res.returncode, res.stdout, res.stderr)
    except Exception as e:
        finished = now()
        err = f"{type(e).__name__}: {e}\n".encode()
        return record_cmd(
            label,
            argv,
            cwd,
            started,
            finished,
            None,
            b"",
            err,
            extra={"exception": type(e).__name__, "exception_text": str(e)},
        )


def main():
    python_path = Path(sys.executable)
    python_hash = file_sha(python_path) if python_path.is_file() else None
    identity = {
        "python_path": str(python_path),
        "python_sha256": python_hash,
        "python_version": sys.version,
        "probe_dir": str(PROBE),
        "sandbox": str(SANDBOX),
        "script": str(Path(__file__).resolve()),
        "script_sha256": file_sha(__file__),
        "started_utc": now(),
        "capture_py_not_run": True,
        "compile_not_run": True,
        "lean_not_run": True,
        "package_install_not_run": True,
        "held_payloads_not_selected": True,
    }

    inputs = json.loads(INPUTS.read_text())
    files = inputs["files"]
    before = {}
    mismatches_before = []
    missing_before = []
    started = now()
    for rel, expected in files.items():
        p = SANDBOX / rel
        if not p.is_file():
            missing_before.append(rel)
            before[rel] = None
            continue
        actual = file_sha(p)
        before[rel] = actual
        if actual != expected:
            mismatches_before.append({"path": rel, "expected": expected, "actual": actual})
    finished = now()
    before_json = json.dumps(
        {
            "utc_started": started,
            "utc_finished": finished,
            "declared": len(files),
            "present": sum(1 for v in before.values() if v is not None),
            "matches": sum(1 for rel, actual in before.items() if actual == files[rel]),
            "missing": missing_before,
            "mismatches": mismatches_before,
            "hashes": before,
        },
        indent=2,
        sort_keys=True,
    ) + "\n"
    write_bytes(PROBE / "hash-before.json", before_json.encode())
    record_cmd(
        "hash-before-inputs",
        [str(python_path), str(Path(__file__).resolve())],
        PROBE,
        started,
        finished,
        0 if not mismatches_before and not missing_before else 1,
        before_json.encode(),
        b"",
        extra={
            "method": "sha256 of each inputs.json path from sandbox bytes",
            "declared": len(files),
            "matches": sum(1 for rel, actual in before.items() if actual == files[rel]),
            "missing": missing_before,
            "mismatches": mismatches_before,
            "tool_path": str(python_path),
            "tool_sha256": python_hash,
            "source_sha256": file_sha(INPUTS),
        },
    )

    brief = EVIDENCE / "brief.txt"
    dispatch = json.loads((EVIDENCE / "dispatch.json").read_text())
    brief_hash = file_sha(brief)
    write_bytes(PROBE / "brief.sha256.txt", (brief_hash + "\n").encode())
    identity["brief_sha256"] = brief_hash
    identity["dispatch_brief_sha256"] = dispatch.get("brief_sha256")
    identity["brief_matches_dispatch"] = brief_hash == dispatch.get("brief_sha256")
    identity["requested_model"] = dispatch.get("requested_model")
    identity["effort"] = dispatch.get("effort")
    identity["fresh_session"] = dispatch.get("fresh_session")
    identity["dispatch_status"] = dispatch.get("status")

    # Two absolute-path version commands only.
    solc_rec = run("solc-version", [str(SOLC), "--version"], PROBE)
    evm_rec = run("evm-version", [str(EVM), "--version"], PROBE)

    frozen_solc = json.loads((PREP / "commands.json").read_text())[0]
    frozen_evm = json.loads((PREP / "commands.json").read_text())[1]
    p16_solc = json.loads((P16 / "logs/setup/solc-version/receipt.json").read_text())
    p16_evm = json.loads((P16 / "logs/setup/evm-version/receipt.json").read_text())
    version_compare = {
        "solc_exists": SOLC.is_file(),
        "evm_exists": EVM.is_file(),
        "solc_tool_sha256": solc_rec.get("tool_sha256"),
        "evm_tool_sha256": evm_rec.get("tool_sha256"),
        "solc_matches_p32_commands": solc_rec.get("tool_sha256") == frozen_solc.get("tool_sha256"),
        "evm_matches_p32_commands": evm_rec.get("tool_sha256") == frozen_evm.get("tool_sha256"),
        "solc_matches_p16_receipt": solc_rec.get("tool_sha256") == p16_solc["tool"]["sha256"],
        "evm_matches_p16_receipt": evm_rec.get("tool_sha256") == p16_evm["tool"]["sha256"],
        "solc_stdout_matches_p32": solc_rec.get("stdout_sha256") == frozen_solc.get("stdout_sha256"),
        "evm_stdout_matches_p32": evm_rec.get("stdout_sha256") == frozen_evm.get("stdout_sha256"),
        "solc_stdout_matches_p16": solc_rec.get("stdout_sha256") == p16_solc.get("stdout_sha256"),
        "evm_stdout_matches_p16": evm_rec.get("stdout_sha256") == p16_evm.get("stdout_sha256"),
        "solc_stderr_empty": solc_rec.get("stderr_sha256") == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "evm_stderr_empty": evm_rec.get("stderr_sha256") == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "solc_exit": solc_rec.get("exit"),
        "evm_exit": evm_rec.get("exit"),
        "frozen_solc_tool_sha256": frozen_solc.get("tool_sha256"),
        "frozen_evm_tool_sha256": frozen_evm.get("tool_sha256"),
        "p16_solc_tool_sha256": p16_solc["tool"]["sha256"],
        "p16_evm_tool_sha256": p16_evm["tool"]["sha256"],
    }
    write_bytes(PROBE / "version-compare.json", (json.dumps(version_compare, indent=2) + "\n").encode())

    # Bounded discovery: shutil.which on current PATH plus exact-name in four roots.
    names = {n for ns in GROUPS.values() for n in ns}
    started = now()
    current_path = os.environ.get("PATH")
    original_discovery = json.loads((PREP / "tool-discovery.json").read_text())
    original_path = original_discovery["path"]
    which_current = {k: {n: shutil.which(n) for n in ns} for k, ns in GROUPS.items()}
    which_generic_current = {n: shutil.which(n) for n in GENERIC}
    directory_checks = {}
    for root in ROOTS:
        if not root.is_dir():
            directory_checks[str(root)] = None
            continue
        directory_checks[str(root)] = sorted(x.name for x in root.iterdir() if x.name in names)
    p16_tools_listing = None
    p16_tools_entries = []
    if TOOLS.is_dir():
        for x in sorted(TOOLS.iterdir(), key=lambda p: p.name):
            st = x.stat()
            p16_tools_entries.append(
                {
                    "name": x.name,
                    "is_file": x.is_file(),
                    "mode": oct(st.st_mode),
                    "size": st.st_size,
                    "sha256": file_sha(x) if x.is_file() else None,
                }
            )
        p16_tools_listing = [e["name"] for e in p16_tools_entries]
    # Repeat which under the original recorded PATH only (still shutil.which, not extra roots).
    which_original_path = {k: {n: shutil.which(n, path=original_path) for n in ns} for k, ns in GROUPS.items()}
    which_generic_original_path = {n: shutil.which(n, path=original_path) for n in GENERIC}
    finished = now()
    discovery = {
        "utc_started": started,
        "utc_finished": finished,
        "method": "shutil.which on current process PATH plus exact-name directory entries in four known local tool roots; additional shutil.which using the original recorded PATH string only; generic rustc/cargo/go recorded as non-chain tools",
        "current_path": current_path,
        "original_recorded_path": original_path,
        "path_strings_equal": current_path == original_path,
        "which_current_path": which_current,
        "which_original_recorded_path": which_original_path,
        "which_generic_current_path": which_generic_current,
        "which_generic_original_recorded_path": which_generic_original_path,
        "directory_checks": directory_checks,
        "directory_checks_match_original": directory_checks == original_discovery["directory_checks"],
        "which_current_matches_original_which": which_current == original_discovery["which"],
        "which_original_path_matches_original_which": which_original_path == original_discovery["which"],
        "p16_tools_listing": p16_tools_listing,
        "p16_tools_entries": p16_tools_entries,
        "scope": "Bounded local discovery only. Absence from these lookups does not establish absence throughout the machine or availability on the public network. Generic Rust/Go compilers are not evidence that a chain-specific toolchain is ready.",
        "searched_roots": [str(p) for p in ROOTS],
        "named_tools": sorted(names),
    }
    disc_bytes = (json.dumps(discovery, indent=2) + "\n").encode()
    write_bytes(PROBE / "bounded-discovery.json", disc_bytes)
    record_cmd(
        "bounded-discovery",
        [str(python_path), str(Path(__file__).resolve()), "--bounded-discovery"],
        PROBE,
        started,
        finished,
        0,
        disc_bytes,
        b"",
        extra={
            "method": discovery["method"],
            "tool_path": str(python_path),
            "tool_sha256": python_hash,
            "source_sha256": file_sha(PREP / "tool-discovery.json"),
        },
    )

    # Source-closure, overlay, compiler, genesis cross-check (hash/read only).
    started = now()
    pin = json.loads((SANDBOX / "openspec/changes/uniswap-token0-p16/source-pin.json").read_text())
    evm_rec_json = json.loads((PREP / "evm.json").read_text())
    source_hashes = json.loads((P16 / "compiler/baseline/source-hashes.json").read_text())
    bytecode_hashes = json.loads((P16 / "compiler/baseline/bytecode-hashes.json").read_text())
    compile_json = json.loads((P16 / "compiler/baseline/compile.json").read_text())
    std_in = json.loads((P16 / "compiler/baseline/standard-json-input.json").read_text())
    genesis = json.loads((P16 / "genesis/istanbul-genesis.json").read_text())
    genesis_binding = json.loads((P16 / "genesis/genesis-binding.json").read_text())
    result = json.loads((P16 / "result.json").read_text())
    overlay_copy = json.loads((P16 / "compiler/baseline/overlay-copy.json").read_text())

    closure_rows = []
    for item in pin["token0_closure"]:
        rel = item["rel"]
        up = UPSTREAM / rel
        ov_name = Path(rel).name
        ov = OVERLAY / ov_name if (OVERLAY / ov_name).is_file() else None
        row = {
            "rel": rel,
            "pin_sha256": item["sha256"],
            "upstream_exists": up.is_file(),
            "upstream_sha256": file_sha(up) if up.is_file() else None,
            "overlay_path": str(ov) if ov else None,
            "overlay_sha256": file_sha(ov) if ov else None,
            "source_hashes_json": source_hashes.get(ov_name),
            "inputs_upstream": files.get(str(up.relative_to(SANDBOX))),
            "match_pin_upstream": (file_sha(up) == item["sha256"]) if up.is_file() else False,
            "match_overlay_upstream": (file_sha(ov) == file_sha(up)) if ov and up.is_file() else None,
        }
        closure_rows.append(row)

    runtime_hex = P16 / "compiler/baseline/runtime.hex"
    creation_hex = P16 / "compiler/baseline/creation.hex"
    runtime_hex_bytes = runtime_hex.read_bytes() if runtime_hex.is_file() else b""
    creation_hex_bytes = creation_hex.read_bytes() if creation_hex.is_file() else b""
    runtime_text = runtime_hex_bytes.decode() if runtime_hex_bytes else ""
    hex_body = runtime_text.strip().replace("0x", "") if runtime_text else ""
    try:
        runtime_raw = bytes.fromhex(hex_body) if hex_body else b""
        runtime_raw_sha = sha256(runtime_raw) if runtime_raw else None
    except ValueError as e:
        runtime_raw = b""
        runtime_raw_sha = None
        runtime_decode_error = str(e)
    else:
        runtime_decode_error = None

    helper_src = (UPSTREAM / "contracts/libraries/SqrtPriceMath.sol").read_text()
    helper_lines = helper_src.splitlines()
    span_text = "\n".join(helper_lines[27:56])  # 1-based 28-56

    cross = {
        "source_pin": pin["pin"],
        "evm_record_pin": evm_rec_json["source_pin"],
        "pins_equal": pin["pin"] == evm_rec_json["source_pin"],
        "helper_pin": pin["helper"],
        "helper_evm_record": evm_rec_json["implementation"],
        "helpers_equal": pin["helper"] == evm_rec_json["implementation"],
        "source_closure_count_pin": len(pin["token0_closure"]),
        "source_closure_hashes_verified_field": evm_rec_json["source_closure_hashes_verified"],
        "closure_rows": closure_rows,
        "all_seven_pin_upstream_match": all(r["match_pin_upstream"] for r in closure_rows),
        "overlay_library_matches": [r for r in closure_rows if r["overlay_sha256"]],
        "token0probe_overlay_sha256": file_sha(OVERLAY / "Token0Probe.sol") if (OVERLAY / "Token0Probe.sol").is_file() else None,
        "token0probe_source_hashes": source_hashes.get("Token0Probe.sol"),
        "hardhat_declares_evmVersion": "evmVersion" in (UPSTREAM / "hardhat.config.ts").read_text(),
        "standard_json_settings": std_in.get("settings"),
        "evm_compile_settings": evm_rec_json.get("compile_settings"),
        "compile_settings_equal_standard_json": evm_rec_json.get("compile_settings") == std_in.get("settings"),
        "compiler_evmVersion": std_in.get("settings", {}).get("evmVersion"),
        "genesis_selected_fork": genesis_binding.get("selected_fork"),
        "compiler_evmVersion_establishes_execution_fork": genesis_binding.get("compiler_evmVersion_establishes_execution_fork"),
        "genesis_file_sha256": file_sha(P16 / "genesis/istanbul-genesis.json"),
        "genesis_binding_sha256_field": genesis_binding.get("sha256"),
        "evm_genesis_sha256_field": evm_rec_json["execution_environment"]["genesis_sha256"],
        "genesis_hashes_agree": file_sha(P16 / "genesis/istanbul-genesis.json")
        == genesis_binding.get("sha256")
        == evm_rec_json["execution_environment"]["genesis_sha256"],
        "genesis_istanbulBlock": genesis.get("config", {}).get("istanbulBlock"),
        "later_forks_present_in_genesis_config": sorted(
            k for k in genesis.get("config", {}) if k not in {
                "chainId",
                "homesteadBlock",
                "eip150Block",
                "eip155Block",
                "eip158Block",
                "byzantiumBlock",
                "constantinopleBlock",
                "petersburgBlock",
                "istanbulBlock",
            }
        ),
        "prestate_supplied": genesis_binding.get("prestate_supplied"),
        "runtime_hex_file_sha256": file_sha(runtime_hex) if runtime_hex.is_file() else None,
        "creation_hex_file_sha256": file_sha(creation_hex) if creation_hex.is_file() else None,
        "runtime_bytecode_sha256_from_raw_hex": runtime_raw_sha,
        "runtime_decode_error": runtime_decode_error,
        "runtime_raw_bytes": len(runtime_raw),
        "bytecode_hashes_runtime": bytecode_hashes.get("runtime_bytecode_sha256"),
        "compile_json_runtime_bytecode": compile_json.get("runtime_bytecode_sha256"),
        "compile_json_runtime_hex": compile_json.get("runtime_hex_sha256"),
        "result_runtime_bytecode": result.get("compile", {}).get("runtime_bytecode_sha256"),
        "evm_record_runtime_bytecode": evm_rec_json["deployment"]["runtime_bytecode_sha256"],
        "runtime_bytecode_identities_agree": len({
            runtime_raw_sha,
            bytecode_hashes.get("runtime_bytecode_sha256"),
            compile_json.get("runtime_bytecode_sha256"),
            result.get("compile", {}).get("runtime_bytecode_sha256"),
            evm_rec_json["deployment"]["runtime_bytecode_sha256"],
        }) == 1,
        "runtime_hex_file_distinct_from_bytecode": file_sha(runtime_hex) != bytecode_hashes.get("runtime_bytecode_sha256") if runtime_hex.is_file() else None,
        "overlay_copy_path": overlay_copy.get("overlay"),
        "overlay_dir_exists": OVERLAY.is_dir(),
        "overlay_names": sorted(p.name for p in OVERLAY.iterdir()) if OVERLAY.is_dir() else [],
        "solc_receipt_solc_sha256": json.loads((P16 / "compiler/baseline/solc-receipt.json").read_text()).get("solc_sha256"),
        "helper_span_first_line": helper_lines[27] if len(helper_lines) >= 28 else None,
        "helper_span_last_line": helper_lines[55] if len(helper_lines) >= 56 else None,
        "helper_function_internal_pure": "internal pure" in span_text,
        "mainnet_address_verified": evm_rec_json["deployment"]["mainnet_address_verified"],
        "mainnet_deployment_identity": evm_rec_json["deployment"]["mainnet_deployment_identity"],
        "source_pin_compiler_binary_verified_historical": pin.get("compiler_binary_verified"),
        "source_pin_evm_harness_historical": pin.get("evm_harness"),
        "source_pin_status_historical": pin.get("status"),
    }
    finished = now()
    cross_bytes = (json.dumps(cross, indent=2) + "\n").encode()
    write_bytes(PROBE / "evm-crosscheck.json", cross_bytes)
    record_cmd(
        "evm-crosscheck-hashes",
        [str(python_path), str(Path(__file__).resolve()), "--evm-crosscheck"],
        PROBE,
        started,
        finished,
        0,
        cross_bytes,
        b"",
        extra={
            "method": "read-only sha256 of frozen overlay/upstream/genesis/compiler artifacts; no solc --standard-json; no evm run",
            "tool_path": str(python_path),
            "tool_sha256": python_hash,
        },
    )

    # Hash-after inputs.
    after = {}
    mismatches_after = []
    missing_after = []
    started = now()
    for rel, expected in files.items():
        p = SANDBOX / rel
        if not p.is_file():
            missing_after.append(rel)
            after[rel] = None
            continue
        actual = file_sha(p)
        after[rel] = actual
        if actual != expected:
            mismatches_after.append({"path": rel, "expected": expected, "actual": actual})
    finished = now()
    changed = [rel for rel in files if before.get(rel) != after.get(rel)]
    after_obj = {
        "utc_started": started,
        "utc_finished": finished,
        "declared": len(files),
        "present": sum(1 for v in after.values() if v is not None),
        "matches": sum(1 for rel, actual in after.items() if actual == files[rel]),
        "missing": missing_after,
        "mismatches": mismatches_after,
        "changed_since_before": changed,
        "before_after_identical": before == after,
        "hashes": after,
    }
    after_bytes = (json.dumps(after_obj, indent=2, sort_keys=True) + "\n").encode()
    write_bytes(PROBE / "hash-after.json", after_bytes)
    record_cmd(
        "hash-after-inputs",
        [str(python_path), str(Path(__file__).resolve())],
        PROBE,
        started,
        finished,
        0 if not mismatches_after and not missing_after and not changed else 1,
        after_bytes,
        b"",
        extra={
            "method": "sha256 of each inputs.json path from sandbox bytes after probes",
            "declared": len(files),
            "matches": after_obj["matches"],
            "missing": missing_after,
            "mismatches": mismatches_after,
            "changed_since_before": changed,
            "tool_path": str(python_path),
            "tool_sha256": python_hash,
            "source_sha256": file_sha(INPUTS),
        },
    )

    identity["finished_utc"] = now()
    write_bytes(PROBE / "probe-identity.json", (json.dumps(identity, indent=2) + "\n").encode())
    write_bytes(PROBE / "commands-raw.json", (json.dumps(commands, indent=2) + "\n").encode())
    summary = {
        "hash_before_matches": after_obj["matches"] if False else sum(1 for rel, actual in before.items() if actual == files[rel]),
        "hash_after_matches": after_obj["matches"],
        "hash_declared": len(files),
        "inputs_unchanged": before == after,
        "solc_exit": solc_rec.get("exit"),
        "evm_exit": evm_rec.get("exit"),
        "version_compare": version_compare,
        "discovery_which_current_any_hit": any(
            v is not None for env in which_current.values() for v in env.values()
        ),
        "directory_checks": directory_checks,
        "all_seven_pin_upstream_match": cross["all_seven_pin_upstream_match"],
        "pins_equal": cross["pins_equal"],
        "helpers_equal": cross["helpers_equal"],
        "compile_settings_equal_standard_json": cross["compile_settings_equal_standard_json"],
        "genesis_hashes_agree": cross["genesis_hashes_agree"],
        "runtime_bytecode_identities_agree": cross["runtime_bytecode_identities_agree"],
        "commands": len(commands),
    }
    write_bytes(PROBE / "summary.json", (json.dumps(summary, indent=2) + "\n").encode())
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
