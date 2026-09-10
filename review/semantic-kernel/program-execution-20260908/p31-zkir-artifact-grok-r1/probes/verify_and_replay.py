#!/usr/bin/env python3
"""Independent P31 ZKIR artifact-preparation probes. Writes only under the review tree."""
from __future__ import annotations

import collections
import hashlib
import json
import os
import shutil
import subprocess
import datetime
from pathlib import Path

REVIEW = Path("/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p31-zkir-artifact-grok-r1")
SANDBOX = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p31-zkir-artifact-grok-r1-sandbox")
PREP = SANDBOX / "p31-zkir-artifact-preparation"
TOOL = Path("/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl/zkir")
NODE = Path("/home/charl/.foreman/tools/fnm/node-versions/v24.18.1/installation/bin/node")
COMPILER_BIN = Path("/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl/compactc.bin")
FROZEN_TOOL_SHA = "5443f87db07b7f19cc273380c224b77b4b7ca124deac6d54f7a165628fc5e1fc"
FROZEN_TOOL_VERSION = "midnight-zkir 2.1.0"
SOURCE_PIN = "7307349d0275af6fcb4144e1661d8b59d6b2663a"

NINE = [
    "loan/bound-program.json",
    "loan/harness.compact",
    "loan/kernel.compact",
    "loan/metadata.json",
    "materialization.json",
    "swap/bound-program.json",
    "swap/harness.compact",
    "swap/kernel.compact",
    "swap/metadata.json",
]

MOCK_CASES = [
    ("valid-record0", PREP / "mock-format-validation/valid-record0/input.zkir"),
    ("valid-record1", PREP / "mock-format-validation/valid-record1/input.zkir"),
    ("invalid-version999", PREP / "mock-format-validation/invalid-version/input.zkir"),
    ("unsupported-inrange-version255", PREP / "mock-format-validation/unsupported-inrange-version/input.zkir"),
    ("invalid-opcode", PREP / "mock-format-validation/invalid-opcode/input.zkir"),
]


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_path(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def git_blob(data: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(data)).encode("ascii") + b"\0" + data).hexdigest()


def now() -> str:
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def write_json(path: Path, obj) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2) + "\n")


def observe_zkir(path: Path) -> dict:
    data = json.loads(path.read_text())
    ops = collections.Counter(ins["op"] for ins in data["instructions"])
    fields: dict[str, set[str]] = {}
    for ins in data["instructions"]:
        fields.setdefault(ins["op"], set()).update(ins.keys())
    return {
        "path": str(path),
        "sha256": sha256_path(path),
        "bytes": path.stat().st_size,
        "top_level_keys": list(data.keys()),
        "version": data["version"],
        "do_communications_commitment": data.get("do_communications_commitment"),
        "num_inputs": data["num_inputs"],
        "instruction_count": len(data["instructions"]),
        "op_counts": dict(sorted(ops.items())),
        "distinct_ops": sorted(ops),
        "distinct_op_count": len(ops),
        "observed_op_fields": {k: sorted(v) for k, v in sorted(fields.items())},
    }


def run_cmd(argv, cwd: Path, timeout: int, stdout_path: Path, stderr_path: Path) -> dict:
    start = now()
    timed_out = False
    code = None
    stdout = b""
    stderr = b""
    try:
        proc = subprocess.run(
            argv,
            cwd=str(cwd),
            capture_output=True,
            timeout=timeout,
        )
        code = proc.returncode
        stdout = proc.stdout or b""
        stderr = proc.stderr or b""
    except subprocess.TimeoutExpired as exc:
        timed_out = True
        stdout = exc.stdout or b""
        stderr = exc.stderr or b""
        code = None
    finished = now()
    stdout_path.write_bytes(stdout)
    stderr_path.write_bytes(stderr)
    return {
        "argv": list(argv),
        "cwd": str(cwd),
        "started_utc": start,
        "finished_utc": finished,
        "exit": code,
        "timeout": timed_out,
        "stdout_bytes": len(stdout),
        "stderr_bytes": len(stderr),
        "stdout_sha256": sha256_bytes(stdout),
        "stderr_sha256": sha256_bytes(stderr),
        "success": (not timed_out) and code == 0,
    }


def main() -> None:
    replay = REVIEW / "replay"
    replay.mkdir(parents=True, exist_ok=True)

    tool_exists = TOOL.is_file()
    tool_sha = sha256_path(TOOL) if tool_exists else None
    version_rec = None
    if tool_exists:
        version_rec = run_cmd(
            [str(TOOL), "--version"],
            cwd=replay,
            timeout=30,
            stdout_path=replay / "tool-version.stdout",
            stderr_path=replay / "tool-version.stderr",
        )
    tool_version = None
    if version_rec is not None:
        tool_version = (replay / "tool-version.stdout").read_text(errors="replace").strip()
    tool_identity = {
        "path": str(TOOL),
        "exists": tool_exists,
        "sha256": tool_sha,
        "frozen_receipt_sha256": FROZEN_TOOL_SHA,
        "sha256_matches_frozen_receipt": tool_sha == FROZEN_TOOL_SHA,
        "version_command": version_rec,
        "version_stdout": tool_version,
        "frozen_receipt_version": FROZEN_TOOL_VERSION,
        "version_matches_frozen_receipt": tool_version == FROZEN_TOOL_VERSION,
    }
    write_json(replay / "tool-identity.json", tool_identity)

    compiler_sha = sha256_path(COMPILER_BIN) if COMPILER_BIN.is_file() else None
    node_sha = sha256_path(NODE) if NODE.is_file() else None
    binaries = {
        "compactc.bin": {
            "path": str(COMPILER_BIN),
            "exists": COMPILER_BIN.is_file(),
            "sha256": compiler_sha,
            "frozen_compile_receipt_sha256": "3054ffa89d7a4dfe24afd31c27ef37e87a95757de0fc24485f335635e26dce57",
            "match": compiler_sha == "3054ffa89d7a4dfe24afd31c27ef37e87a95757de0fc24485f335635e26dce57",
        },
        "node": {
            "path": str(NODE),
            "exists": NODE.is_file(),
            "sha256": node_sha,
            "frozen_inputs_sha256": "f3432a45b03b2da0d270095fdd8813dc34cbea73f5fc8b18c7a384b7cf9b333a",
            "match": node_sha == "f3432a45b03b2da0d270095fdd8813dc34cbea73f5fc8b18c7a384b7cf9b333a",
        },
    }
    write_json(replay / "binary-identity.json", binaries)

    review_inputs = json.loads((REVIEW / "inputs.json").read_text())
    review_hash_rows = []
    for rel, expected in review_inputs["files"].items():
        path = SANDBOX / rel
        actual = sha256_path(path) if path.is_file() else None
        review_hash_rows.append(
            {
                "path": rel,
                "expected": expected,
                "actual": actual,
                "match": actual == expected,
                "exists": path.is_file(),
            }
        )
    write_json(
        replay / "review-inputs-hash-check.json",
        {
            "declared": len(review_hash_rows),
            "matched": sum(1 for r in review_hash_rows if r["match"]),
            "mismatched": [r for r in review_hash_rows if not r["match"]],
        },
    )

    source_inputs = json.loads((PREP / "inputs.json").read_text())
    source_rows = []
    for entry in source_inputs["files"]:
        path = PREP / "source" / entry["path"]
        data = path.read_bytes() if path.is_file() else None
        actual_sha = sha256_bytes(data) if data is not None else None
        actual_blob = git_blob(data) if data is not None else None
        actual_bytes = len(data) if data is not None else None
        source_rows.append(
            {
                "path": entry["path"],
                "exists": path.is_file(),
                "expected_sha256": entry["sha256"],
                "actual_sha256": actual_sha,
                "sha256_match": actual_sha == entry["sha256"],
                "expected_bytes": entry["bytes"],
                "actual_bytes": actual_bytes,
                "bytes_match": actual_bytes == entry["bytes"],
                "expected_git_blob": entry["git_blob"],
                "actual_git_blob": actual_blob,
                "git_blob_match": actual_blob == entry["git_blob"],
                "capture": entry.get("capture"),
            }
        )
    write_json(
        replay / "source33-identity.json",
        {
            "source_pin": source_inputs["source_pin"],
            "declared_file_count": source_inputs["file_count"],
            "rows": len(source_rows),
            "sha256_matched": sum(1 for r in source_rows if r["sha256_match"]),
            "bytes_matched": sum(1 for r in source_rows if r["bytes_match"]),
            "git_blob_matched": sum(1 for r in source_rows if r["git_blob_match"]),
            "mismatched": [r for r in source_rows if not (r["sha256_match"] and r["bytes_match"] and r["git_blob_match"])],
            "files": source_rows,
        },
    )

    nine_rows = []
    for rel in NINE:
        gen = PREP / "generated" / rel
        pinned = PREP / "source/experiments/moriarty-language/compact/generated" / rel
        gen_sha = sha256_path(gen) if gen.is_file() else None
        pinned_sha = sha256_path(pinned) if pinned.is_file() else None
        nine_rows.append(
            {
                "path": rel,
                "generated_sha256": gen_sha,
                "pinned_source_generated_sha256": pinned_sha,
                "generated_equals_pinned_source": gen_sha == pinned_sha and gen_sha is not None,
            }
        )
    write_json(
        replay / "nine-file-pinned-compare.json",
        {
            "all_generated_equals_pinned_source": all(r["generated_equals_pinned_source"] for r in nine_rows),
            "files": nine_rows,
        },
    )

    zkir0 = observe_zkir(PREP / "compiled/loan-harness/zkir/record0.zkir")
    zkir1 = observe_zkir(PREP / "compiled/loan-harness/zkir/record1.zkir")
    union_ops = sorted(set(zkir0["distinct_ops"]) | set(zkir1["distinct_ops"]))
    write_json(
        replay / "zkir-observations.json",
        {
            "record0": zkir0,
            "record1": zkir1,
            "union_ops": union_ops,
            "union_op_count": len(union_ops),
            "each_has_11_distinct": zkir0["distinct_op_count"] == 11 and zkir1["distinct_op_count"] == 11,
            "union_may_differ": len(union_ops) != 11,
            "scope": "Observed generated subset only; not a complete ZKIR opcode schema or semantics.",
        },
    )

    compiled_dir = PREP / "compiled/loan-harness"
    compiled_files = sorted(
        str(p.relative_to(compiled_dir)) for p in compiled_dir.rglob("*") if p.is_file()
    )
    write_json(replay / "compiled-tree.json", {"files": compiled_files, "count": len(compiled_files)})

    mutated = {
        "invalid-version999": json.loads((PREP / "mock-format-validation/invalid-version/input.zkir").read_text())["version"],
        "unsupported-inrange-version255": json.loads((PREP / "mock-format-validation/unsupported-inrange-version/input.zkir").read_text())["version"],
        "invalid-opcode-first-op": json.loads((PREP / "mock-format-validation/invalid-opcode/input.zkir").read_text())["instructions"][0]["op"],
        "valid-record0-sha256": sha256_path(PREP / "mock-format-validation/valid-record0/input.zkir"),
        "compiled-record0-sha256": sha256_path(PREP / "compiled/loan-harness/zkir/record0.zkir"),
        "valid-record1-sha256": sha256_path(PREP / "mock-format-validation/valid-record1/input.zkir"),
        "compiled-record1-sha256": sha256_path(PREP / "compiled/loan-harness/zkir/record1.zkir"),
    }
    write_json(replay / "mutated-input-controls.json", mutated)

    materialize_dir = replay / "materialize"
    if materialize_dir.exists():
        raise SystemExit("materialize output already exists; not replacing")
    materialize_dir.mkdir()
    mapper = PREP / "source/experiments/moriarty-language/compact/materialize-mapping.mjs"
    materialize_cmd = run_cmd(
        [str(NODE), str(mapper), str(materialize_dir)],
        cwd=replay,
        timeout=60,
        stdout_path=replay / "materialize.stdout",
        stderr_path=replay / "materialize.stderr",
    )
    rematerialized = []
    for rel in NINE:
        outp = materialize_dir / rel
        frozen = PREP / "generated" / rel
        out_sha = sha256_path(outp) if outp.is_file() else None
        frozen_sha = sha256_path(frozen) if frozen.is_file() else None
        rematerialized.append(
            {
                "path": rel,
                "replay_sha256": out_sha,
                "frozen_generated_sha256": frozen_sha,
                "exact_match": out_sha == frozen_sha and out_sha is not None,
                "exists": outp.is_file(),
            }
        )
    write_json(
        replay / "materialize-replay.json",
        {
            "command": materialize_cmd,
            "mapper_sha256": sha256_path(mapper),
            "expected_mapper_sha256": "5dac9c40152378490b35c62c1815978eb4d89d4d261f02bb45761a9fe138b856",
            "mapper_unchanged": sha256_path(mapper) == "5dac9c40152378490b35c62c1815978eb4d89d4d261f02bb45761a9fe138b856",
            "all_exact": all(r["exact_match"] for r in rematerialized),
            "files": rematerialized,
        },
    )

    mock_root = replay / "mock-compile"
    mock_root.mkdir()
    frozen_bzkir = {
        "valid-record0": {
            "bytes": 955,
            "sha256": "d1217f2fe66662dce7e0df9eac73ede27406d43704bdfd0f455128ca8a3abb7d",
            "rows": 5297,
            "k": 13,
        },
        "valid-record1": {
            "bytes": 395,
            "sha256": "f02506aea4a31d7db9bd3526ca65c6173b9fa08d5bc26a5368c61ce36f73684d",
            "rows": 2941,
            "k": 12,
        },
    }
    mock_rows = []
    for label, src in MOCK_CASES:
        d = mock_root / label
        d.mkdir()
        dst = d / "input.zkir"
        shutil.copyfile(src, dst)
        copy_sha = sha256_path(dst)
        src_sha = sha256_path(src)
        copy_ok = copy_sha == src_sha
        (d / "copy-identity.json").write_text(
            json.dumps({"src": str(src), "src_sha256": src_sha, "dst_sha256": copy_sha, "byte_identical": copy_ok}, indent=2)
            + "\n"
        )
        rec = run_cmd(
            [str(TOOL), "mock-compile", str(dst)],
            cwd=d,
            timeout=60,
            stdout_path=d / "stdout.log",
            stderr_path=d / "stderr.log",
        )
        artifacts = []
        bzkir = d / "input.bzkir"
        if bzkir.is_file():
            artifacts.append(
                {
                    "path": "input.bzkir",
                    "bytes": bzkir.stat().st_size,
                    "sha256": sha256_path(bzkir),
                }
            )
        extra = [
            str(p.relative_to(d))
            for p in sorted(d.rglob("*"))
            if p.is_file() and p.name not in {"input.zkir", "stdout.log", "stderr.log", "copy-identity.json", "command.json"}
        ]
        stderr_text = (d / "stderr.log").read_text(errors="replace")
        stdout_text = (d / "stdout.log").read_text(errors="replace")
        expected = frozen_bzkir.get(label)
        bzkir_cmp = None
        if expected is not None and artifacts:
            art = artifacts[0]
            bzkir_cmp = {
                "bytes": art["bytes"],
                "expected_bytes": expected["bytes"],
                "bytes_match": art["bytes"] == expected["bytes"],
                "sha256": art["sha256"],
                "expected_sha256": expected["sha256"],
                "sha256_match": art["sha256"] == expected["sha256"],
                "nondeterminism": art["sha256"] != expected["sha256"],
            }
        row = {
            "label": label,
            "argv": rec["argv"],
            "cwd": rec["cwd"],
            "started_utc": rec["started_utc"],
            "finished_utc": rec["finished_utc"],
            "exit": rec["exit"],
            "timeout": rec["timeout"],
            "timeout_is_not_success": True,
            "input_sha256": copy_sha,
            "copy_byte_identical": copy_ok,
            "stdout_sha256": rec["stdout_sha256"],
            "stderr_sha256": rec["stderr_sha256"],
            "stdout_text": stdout_text,
            "stderr_text": stderr_text,
            "artifacts": artifacts,
            "extra_emitted_files": extra,
            "bzkir_compare": bzkir_cmp,
            "frozen_expected": expected,
        }
        write_json(d / "command.json", row)
        mock_rows.append(row)

    write_json(
        replay / "mock-compile-receipt.json",
        {
            "tool": str(TOOL),
            "tool_sha256": tool_sha,
            "tool_version": tool_version,
            "commands": mock_rows,
            "proofs_generated": False,
            "keys_generated": False,
            "scope": "Independent native mock-compile replay on frozen inputs in unique review directories. Timeout is not success. Mock compilation is not constraint soundness, witness validity, verification, or settlement.",
        },
    )

    summary = {
        "utc": now(),
        "source_pin": SOURCE_PIN,
        "review_inputs_declared": len(review_hash_rows),
        "review_inputs_matched": sum(1 for r in review_hash_rows if r["match"]),
        "source33_declared": source_inputs["file_count"],
        "source33_sha256_matched": sum(1 for r in source_rows if r["sha256_match"]),
        "source33_git_blob_matched": sum(1 for r in source_rows if r["git_blob_match"]),
        "nine_generated_equals_pinned_source": all(r["generated_equals_pinned_source"] for r in nine_rows),
        "materialize_all_exact": all(r["exact_match"] for r in rematerialized),
        "tool_sha_match": tool_sha == FROZEN_TOOL_SHA,
        "tool_version_match": tool_version == FROZEN_TOOL_VERSION,
        "record0_counts": [zkir0["num_inputs"], zkir0["instruction_count"], zkir0["distinct_op_count"]],
        "record1_counts": [zkir1["num_inputs"], zkir1["instruction_count"], zkir1["distinct_op_count"]],
        "union_op_count": len(union_ops),
        "compiled_file_count": len(compiled_files),
        "mock_exits": {r["label"]: r["exit"] for r in mock_rows},
        "mock_timeouts": {r["label"]: r["timeout"] for r in mock_rows},
        "mock_bzkir": {r["label"]: r["bzkir_compare"] for r in mock_rows if r["bzkir_compare"] is not None},
    }
    write_json(replay / "summary.json", summary)
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
