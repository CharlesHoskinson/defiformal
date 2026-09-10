#!/usr/bin/env python3
"""Bounded independent verification of two P31 supplemental records.
Read-only on frozen sandbox and allowed runtime tool tree. Writes only under review/replay.
"""
from __future__ import annotations

import hashlib
import json
import os
import shutil
import stat
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REVIEW = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p31-runtime-preparation-grok-r1")
SANDBOX = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p31-runtime-preparation-grok-r1-sandbox")
NODE = Path("/home/charl/.foreman/tools/fnm/node-versions/v24.18.1/installation/bin/node")
RUNTIME_NM = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p31-compact-runtime-tool/node_modules")
COMPACTC = Path("/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl/compactc.bin")
LAUNCHER = Path("/home/charl/.local/bin/compact")
SCANNER_TS = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p31-import-scanner-tool/node_modules/typescript/lib/typescript.js")

REPLAY = REVIEW / "replay"
SIM_OUT = REPLAY / "source-closure"
COMPACT_OUT = REPLAY / "compact-add"
RESULT = REPLAY / "verification.json"


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def git_blob(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()


def run_cmd(argv: list[str], cwd: Path, stdout_path: Path | None = None, stderr_path: Path | None = None) -> dict:
    started = datetime.now(timezone.utc).isoformat()
    proc = subprocess.run(argv, cwd=str(cwd), capture_output=True)
    finished = datetime.now(timezone.utc).isoformat()
    if stdout_path is not None:
        stdout_path.write_bytes(proc.stdout)
    if stderr_path is not None:
        stderr_path.write_bytes(proc.stderr)
    rec = {
        "argv": argv,
        "cwd": str(cwd),
        "started_utc": started,
        "finished_utc": finished,
        "exit": proc.returncode,
        "stdout_sha256": sha256_bytes(proc.stdout),
        "stderr_sha256": sha256_bytes(proc.stderr),
        "stdout_bytes": len(proc.stdout),
        "stderr_bytes": len(proc.stderr),
    }
    if stdout_path is not None:
        rec["stdout_path"] = str(stdout_path)
    if stderr_path is not None:
        rec["stderr_path"] = str(stderr_path)
    return rec


def collect_files(root: Path) -> list[str]:
    out = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames.sort()
        for name in sorted(filenames):
            p = Path(dirpath) / name
            rel = p.relative_to(root).as_posix()
            out.append(rel)
    return out


def main() -> int:
    SIM_OUT.mkdir(parents=True, exist_ok=True)
    COMPACT_OUT.mkdir(parents=True, exist_ok=True)

    inputs = json.loads((REVIEW / "inputs.json").read_text())
    identity_rows = []
    identity_ok = True
    extra_sandbox = []
    missing_sandbox = []

    declared = inputs["files"]
    for rel, expected in declared.items():
        path = SANDBOX / rel
        if not path.is_file():
            missing_sandbox.append(rel)
            identity_ok = False
            identity_rows.append({"path": rel, "present": False, "expected": expected})
            continue
        actual = sha256_file(path)
        match = actual == expected
        if not match:
            identity_ok = False
        identity_rows.append(
            {
                "path": rel,
                "present": True,
                "bytes": path.stat().st_size,
                "sha256": actual,
                "expected": expected,
                "sha256_match": match,
            }
        )

    declared_set = set(declared)
    for rel in collect_files(SANDBOX):
        if rel not in declared_set:
            extra_sandbox.append(rel)

    closure_manifest = json.loads((SANDBOX / "p31-source-closure/manifest.json").read_text())
    blob_rows = []
    blob_ok = True
    for row in closure_manifest["files"]:
        path = SANDBOX / "p31-source-closure/source" / row["path"]
        data = path.read_bytes()
        actual_sha = sha256_bytes(data)
        actual_blob = git_blob(data)
        rec = {
            "path": row["path"],
            "bytes": len(data),
            "bytes_match": len(data) == row["bytes"],
            "sha256": actual_sha,
            "sha256_match": actual_sha == row["sha256"],
            "git_blob": actual_blob,
            "git_blob_match": actual_blob == row["git_blob"],
        }
        if not (rec["bytes_match"] and rec["sha256_match"] and rec["git_blob_match"]):
            blob_ok = False
        blob_rows.append(rec)

    example_manifest = json.loads((SANDBOX / "p31-source-closure/example-inputs.json").read_text())
    example_rows = []
    example_ok = True
    for row in example_manifest["files"]:
        path = SANDBOX / "p31-source-closure/source" / row["path"]
        data = path.read_bytes()
        rec = {
            "path": row["path"],
            "bytes": len(data),
            "bytes_match": len(data) == row["bytes"],
            "sha256": sha256_bytes(data),
            "sha256_match": sha256_bytes(data) == row["sha256"],
            "git_blob": git_blob(data),
            "git_blob_match": git_blob(data) == row["git_blob"],
        }
        if not (rec["bytes_match"] and rec["sha256_match"] and rec["git_blob_match"]):
            example_ok = False
        example_rows.append(rec)

    original13 = [
        "LICENSE",
        "experiments/moriarty-language/src/types.ts",
        "experiments/moriarty-language/src/runtime-types.ts",
        "experiments/moriarty-language/src/evaluate.ts",
        "experiments/moriarty-language/src/codec.ts",
        "experiments/moriarty-language/src/lower-compact.ts",
        "experiments/moriarty-language/src/successor/core.ts",
        "experiments/moriarty-language/src/successor/repayment.ts",
        "experiments/moriarty-language/compact/MAPPING.md",
        "experiments/moriarty-language/compact/arithmetic.compact",
        "experiments/moriarty-language/compact/verify-mapping.py",
        "experiments/moriarty-language/formal/k/moriarty.k",
        "experiments/moriarty-language/spec/numeric-profile.json",
    ]
    added7 = [
        "experiments/moriarty-language/src/frontend.ts",
        "experiments/moriarty-language/src/registered-bounds.ts",
        "experiments/moriarty-language/src/parser.ts",
        "experiments/moriarty-language/src/checker.ts",
        "experiments/moriarty-language/src/validate.ts",
        "experiments/moriarty-language/src/diagnostics.ts",
        "experiments/moriarty-language/spec/bounds.json",
    ]
    manifest_paths = [f["path"] for f in closure_manifest["files"]]
    roots_match = closure_manifest["roots"] == original13
    files20 = set(manifest_paths) == set(original13 + added7)
    edges40 = len(closure_manifest["edges"]) == 40
    unresolved_empty = closure_manifest["unresolved"] == []

    classifications = {}
    for e in closure_manifest["edges"]:
        classifications[e["classification"]] = classifications.get(e["classification"], 0) + 1
        if e["classification"] == "pinned_relative":
            target = SANDBOX / "p31-source-closure/source" / e["target"]
            if not target.is_file():
                unresolved_empty = False

    sim_captured = json.loads((SANDBOX / "p31-source-closure/simulation.stdout.json").read_text())
    captured_checks = []
    loan_settle_outstanding = False
    for rec in sim_captured["records"]:
        for step in rec["steps"]:
            body = step["result"]["candidate"]["body"]
            after = body["after"]["body"]
            adverse = step["adverseResult"]["diagnostics"][0]["code"]
            missing = step["acceptanceWithoutProof"]["diagnostics"][0]["code"]
            row = {
                "example": rec["name"],
                "program_hash": rec["programHash"],
                "action": step["action"],
                "result_kind": step["result"]["kind"],
                "writes": len(body["writes"]),
                "effects": len(body["effects"]),
                "episode": after["episodeStatus"],
                "agreement": after["agreementStatus"],
                "adverse_code": adverse,
                "without_backend_code": missing,
            }
            captured_checks.append(row)
            if rec["name"] == "loan" and step["action"] == "settle":
                loan_settle_outstanding = after["agreementStatus"] == "Outstanding" and after["episodeStatus"] == "Closed"

    obs = json.loads((SANDBOX / "p31-source-closure/root-observations.json").read_text())
    obs_match = True
    if len(obs["checks"]) != len(captured_checks):
        obs_match = False
    else:
        for a, b in zip(obs["checks"], captured_checks):
            for key in ("example", "program_hash", "action", "adverse_code", "without_backend_code", "episode", "agreement"):
                if a[key] != b[key]:
                    obs_match = False
            if a["simulated"] is not True or b["result_kind"] != "Simulation":
                obs_match = False
            if a["writes"] != b["writes"] or a["effects"] != b["effects"]:
                obs_match = False

    node_rec = {
        "path": str(NODE),
        "present": NODE.is_file(),
        "sha256": sha256_file(NODE) if NODE.is_file() else None,
        "expected": "f3432a45b03b2da0d270095fdd8813dc34cbea73f5fc8b18c7a384b7cf9b333a",
    }
    node_rec["sha256_match"] = node_rec["sha256"] == node_rec["expected"]
    node_ver = run_cmd([str(NODE), "--version"], cwd=SIM_OUT)

    sim_script = SANDBOX / "p31-source-closure/source/experiments/moriarty-language/examples/simulate.mjs"
    sim_run = run_cmd(
        [str(NODE), str(sim_script), "--json"],
        cwd=SIM_OUT,
        stdout_path=SIM_OUT / "simulation.stdout.json",
        stderr_path=SIM_OUT / "simulation.stderr.log",
    )
    captured_stdout_sha = "6cc901fb87248a40d1331ae7b9307a18bbe530b381726563789daff183aa887d"
    captured_stderr_sha = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    sim_bytes_match = sim_run["stdout_sha256"] == captured_stdout_sha and sim_run["stderr_sha256"] == captured_stderr_sha

    replay_checks = []
    replay_loan_settle_outstanding = False
    semantic_match = False
    if sim_run["exit"] == 0:
        replayed = json.loads((SIM_OUT / "simulation.stdout.json").read_text())
        for rec in replayed["records"]:
            for step in rec["steps"]:
                body = step["result"]["candidate"]["body"]
                after = body["after"]["body"]
                row = {
                    "example": rec["name"],
                    "program_hash": rec["programHash"],
                    "action": step["action"],
                    "result_kind": step["result"]["kind"],
                    "writes": len(body["writes"]),
                    "effects": len(body["effects"]),
                    "episode": after["episodeStatus"],
                    "agreement": after["agreementStatus"],
                    "adverse_code": step["adverseResult"]["diagnostics"][0]["code"],
                    "without_backend_code": step["acceptanceWithoutProof"]["diagnostics"][0]["code"],
                }
                replay_checks.append(row)
                if rec["name"] == "loan" and step["action"] == "settle":
                    replay_loan_settle_outstanding = after["agreementStatus"] == "Outstanding" and after["episodeStatus"] == "Closed"
        semantic_match = replay_checks == captured_checks

    compiled_src = SANDBOX / "p31-compact-add-diagnostic/compiled"
    probe_src = SANDBOX / "p31-compact-add-diagnostic/probe.mjs"
    copy_rows = []
    for rel in [
        "compiled/compiler/contract-info.json",
        "compiled/contract/index.js",
        "compiled/contract/index.d.ts",
        "compiled/contract/index.js.map",
    ]:
        src = SANDBOX / "p31-compact-add-diagnostic" / rel
        dst = COMPACT_OUT / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        src_sha = sha256_file(src)
        dst_sha = sha256_file(dst)
        copy_rows.append(
            {
                "rel": rel,
                "src_sha256": src_sha,
                "dst_sha256": dst_sha,
                "byte_match": src_sha == dst_sha,
                "mode": oct(dst.stat().st_mode),
            }
        )
    probe_dst = COMPACT_OUT / "probe.mjs"
    shutil.copy2(probe_src, probe_dst)
    copy_rows.append(
        {
            "rel": "probe.mjs",
            "src_sha256": sha256_file(probe_src),
            "dst_sha256": sha256_file(probe_dst),
            "byte_match": sha256_file(probe_src) == sha256_file(probe_dst),
            "mode": oct(probe_dst.stat().st_mode),
        }
    )

    nm_link = COMPACT_OUT / "node_modules"
    if nm_link.exists() or nm_link.is_symlink():
        if nm_link.is_symlink() or nm_link.is_file():
            nm_link.unlink()
        else:
            shutil.rmtree(nm_link)
    os.symlink(RUNTIME_NM, nm_link, target_is_directory=True)
    link_ok = nm_link.is_symlink() and os.readlink(nm_link) == str(RUNTIME_NM)

    runtime_nm_ro = True
    try:
        runtime_nm_ro = not os.access(RUNTIME_NM, os.W_OK)
    except OSError:
        runtime_nm_ro = True

    compiled_files = collect_files(compiled_src)
    zkir_hits = [
        rel
        for rel in compiled_files
        if any(tok in rel.lower() for tok in (".prover", ".verifier", "zkir", ".zkey", "proof", "key"))
        and not rel.endswith("contract-info.json")
    ]
    # contract-info may mention proof:false; search filenames only for artifacts
    zkir_filename_hits = [
        rel
        for rel in compiled_files
        if any(rel.lower().endswith(ext) or tok in Path(rel).name.lower() for ext in (".prover", ".verifier", ".zkey", ".zkir") for tok in ("prover", "verifier", "zkey"))
    ]

    info = json.loads((compiled_src / "compiler/contract-info.json").read_text())
    circuits = info.get("circuits", [])
    all_pure_no_proof = all(c.get("pure") is True and c.get("proof") is False for c in circuits)

    compactc_rec = {
        "path": str(COMPACTC),
        "present": COMPACTC.is_file(),
        "sha256": sha256_file(COMPACTC) if COMPACTC.is_file() else None,
        "expected": "3054ffa89d7a4dfe24afd31c27ef37e87a95757de0fc24485f335635e26dce57",
    }
    compactc_rec["sha256_match"] = compactc_rec["present"] and compactc_rec["sha256"] == compactc_rec["expected"]
    launcher_rec = {
        "path": str(LAUNCHER),
        "present": LAUNCHER.is_file(),
        "sha256": sha256_file(LAUNCHER) if LAUNCHER.is_file() else None,
        "expected": "d3acfa66b6048ce29acb5bd25880a72ce7bf42694087ffbcb5ba7922861aaa59",
    }
    launcher_rec["sha256_match"] = launcher_rec["present"] and launcher_rec["sha256"] == launcher_rec["expected"]

    scanner_ts_rec = {
        "path": str(SCANNER_TS),
        "present": SCANNER_TS.is_file(),
        "sha256": sha256_file(SCANNER_TS) if SCANNER_TS.is_file() else None,
        "expected": closure_manifest["scanner"]["typescript_sha256"],
        "inspected": SCANNER_TS.is_file(),
    }
    scanner_ts_rec["sha256_match"] = scanner_ts_rec["present"] and scanner_ts_rec["sha256"] == scanner_ts_rec["expected"]

    probe_run = run_cmd(
        [str(NODE), str(probe_dst)],
        cwd=COMPACT_OUT,
        stdout_path=COMPACT_OUT / "runtime.stdout.json",
        stderr_path=COMPACT_OUT / "runtime.stderr.log",
    )
    captured_probe_stdout = "2ef2229921535d031ea72a77d934ddaae6fc1284f85dd94de885b4f66867ae9c"
    probe_bytes_match = probe_run["stdout_sha256"] == captured_probe_stdout and probe_run["stderr_sha256"] == captured_stderr_sha
    probe_semantic = None
    if probe_run["exit"] == 0:
        probe_out = json.loads((COMPACT_OUT / "runtime.stdout.json").read_text())
        captured_probe = json.loads((SANDBOX / "p31-compact-add-diagnostic/runtime.stdout.json").read_text())
        probe_semantic = probe_out == captured_probe

    # sample runtime package hashes from tool-inputs
    tool_inputs = json.loads((SANDBOX / "p31-compact-add-diagnostic/tool-inputs.json").read_text())
    runtime_sample = []
    runtime_sample_ok = True
    for rel in [
        "@midnight-ntwrk/compact-runtime/package.json",
        "@midnight-ntwrk/compact-runtime/dist/index.js",
        "@midnight-ntwrk/compact-runtime/dist/error.js",
        "@midnight-ntwrk/onchain-runtime-v3/package.json",
    ]:
        p = RUNTIME_NM / rel
        expected = tool_inputs["runtime_files"].get(rel)
        actual = sha256_file(p) if p.is_file() else None
        match = actual == expected
        if not match:
            runtime_sample_ok = False
        runtime_sample.append({"path": rel, "present": p.is_file(), "sha256": actual, "expected": expected, "match": match})

    js = (compiled_src / "contract/index.js").read_text()
    overflow_guard_present = (
        "if (t1 > 340282366920938463463374607431768211455n)" in js
        and "cast from Field or Uint value to smaller Uint value failed" in js
        and "_checkedAdd_0(a_0, b_0)" in js
    )

    attempt1_partial = collect_files(SANDBOX / "p31-source-closure/attempt1/source")
    capture_py = (SANDBOX / "p31-source-closure/capture.py").read_text()
    capture_requires_fresh = "source.mkdir(exist_ok=False)" in capture_py

    result = {
        "utc": datetime.now(timezone.utc).isoformat(),
        "identity": {
            "declared_files": len(declared),
            "rows_ok": identity_ok,
            "missing": missing_sandbox,
            "extra_sandbox_files": extra_sandbox,
            "rows": identity_rows,
        },
        "source_closure": {
            "file_count_declared": closure_manifest["file_count"],
            "file_count_actual": len(closure_manifest["files"]),
            "roots_are_original13": roots_match,
            "files_are_original13_plus_7": files20,
            "edge_count": len(closure_manifest["edges"]),
            "edges_are_40": edges40,
            "unresolved_empty": unresolved_empty,
            "classifications": classifications,
            "blob_ok": blob_ok,
            "blob_rows": blob_rows,
            "example_ok": example_ok,
            "example_rows": example_rows,
            "acceptance": closure_manifest.get("acceptance"),
            "capture_requires_fresh_output": capture_requires_fresh,
            "attempt1_partial_source": attempt1_partial,
            "scanner_typescript_version_declared": closure_manifest["scanner"]["typescript_version"],
        },
        "simulation": {
            "captured_checks": captured_checks,
            "replay_checks": replay_checks,
            "observations_match_captured_stdout": obs_match,
            "loan_settle_agreement_outstanding_captured": loan_settle_outstanding,
            "loan_settle_agreement_outstanding_replay": replay_loan_settle_outstanding,
            "semantic_match": semantic_match,
            "stdout_bytes_match": sim_bytes_match,
            "run": sim_run,
            "node": node_rec,
            "node_version": node_ver,
        },
        "compact": {
            "copy_rows": copy_rows,
            "copies_byte_match": all(r["byte_match"] for r in copy_rows),
            "node_modules_symlink": str(nm_link),
            "node_modules_target": os.readlink(nm_link) if nm_link.is_symlink() else None,
            "symlink_ok": link_ok,
            "runtime_nm_not_writable_by_this_process": runtime_nm_ro,
            "compiled_files": compiled_files,
            "zkir_filename_hits": zkir_filename_hits,
            "compiler_version": info.get("compiler-version"),
            "language_version": info.get("language-version"),
            "runtime_version": info.get("runtime-version"),
            "all_circuits_pure_proof_false": all_pure_no_proof,
            "circuit_count": len(circuits),
            "overflow_guard_present": overflow_guard_present,
            "compactc": compactc_rec,
            "launcher": launcher_rec,
            "runtime_sample": runtime_sample,
            "runtime_sample_ok": runtime_sample_ok,
            "probe_run": probe_run,
            "probe_stdout_bytes_match": probe_bytes_match,
            "probe_semantic_match": probe_semantic,
        },
        "scanner_ts": scanner_ts_rec,
        "not_run": [
            "capture.py",
            "compact compile",
            "live Moriarty git show",
            "lake/lean/k",
        ],
    }
    RESULT.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({
        "identity_ok": identity_ok,
        "extra_sandbox": extra_sandbox,
        "blob_ok": blob_ok,
        "example_ok": example_ok,
        "files20": files20,
        "edges40": edges40,
        "unresolved_empty": unresolved_empty,
        "obs_match": obs_match,
        "loan_settle_outstanding": loan_settle_outstanding,
        "sim_exit": sim_run["exit"],
        "sim_bytes_match": sim_bytes_match,
        "semantic_match": semantic_match,
        "copies_ok": all(r["byte_match"] for r in copy_rows),
        "symlink_ok": link_ok,
        "probe_exit": probe_run["exit"],
        "probe_bytes_match": probe_bytes_match,
        "probe_semantic": probe_semantic,
        "overflow_guard": overflow_guard_present,
        "zkir_filename_hits": zkir_filename_hits,
        "node_sha_match": node_rec["sha256_match"],
        "compactc_match": compactc_rec["sha256_match"],
        "launcher_match": launcher_rec["sha256_match"],
        "scanner_ts_match": scanner_ts_rec["sha256_match"],
        "runtime_sample_ok": runtime_sample_ok,
        "all_pure_no_proof": all_pure_no_proof,
        "result": str(RESULT),
    }, indent=2))
    return 0 if sim_run["exit"] == 0 and probe_run["exit"] == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
