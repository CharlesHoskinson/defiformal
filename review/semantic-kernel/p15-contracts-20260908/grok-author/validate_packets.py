#!/usr/bin/env python3
"""Replayable P15 freeze validation. Not a platform checker or certificate scorer."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

from jsonschema import Draft202012Validator

WT = Path(__file__).resolve().parents[4]
CONTRACTS = WT / "openspec/changes/reusable-verification-platform-program/contracts"
SCHEMA = CONTRACTS / "evidence-packet.schema.json"
EXAMPLES = CONTRACTS / "examples"
BINDINGS = CONTRACTS / "source-bindings.json"
AUTHOR = Path(__file__).resolve().parent
FIXTURES = AUTHOR / "fixtures"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_json(path: Path):
    return json.loads(path.read_text())


def fail(msg: str, failures: list[str]) -> None:
    failures.append(msg)


def check_packet_semantics(path: Path, packet: dict, failures: list[str]) -> None:
    parts = packet["executions"]["partitions"]
    nonempty = sum(1 for p in parts if p["nonempty"])
    empty = sum(1 for p in parts if not p["nonempty"])
    declared = len(parts)
    d = packet["denominators"]["partitions"]
    if d["declared"] != declared or d["nonempty"] != nonempty or d["empty"] != empty:
        fail(
            f"{path.name}: denominators.partitions {d} != computed declared={declared} nonempty={nonempty} empty={empty}",
            failures,
        )
    for p in parts:
        if p["nonempty"] and p["count"] < 1:
            fail(f"{path.name}: nonempty partition {p['id']} has count {p['count']}", failures)
        if (not p["nonempty"]) and p["count"] != 0:
            fail(f"{path.name}: empty partition {p['id']} has count {p['count']}", failures)
        if p["count"] != len(p.get("cases") or []):
            fail(
                f"{path.name}: partition {p['id']} count {p['count']} != len(cases) {len(p.get('cases') or [])}",
                failures,
            )
    if packet["credit_eligible"] is True:
        fail(f"{path.name}: P15 freeze examples/packets must not set credit_eligible true", failures)
    if packet["packet_status"] in {"illustrative", "blocked", "incomplete"} and packet["credit_eligible"]:
        fail(f"{path.name}: non-reviewed status with credit_eligible true", failures)
    runs = packet["denominators"]["executions"]
    if (
        packet["packet_status"] != "blocked"
        and runs["actually_run"] == 0
        and any(
            c["class"] == "bounded_source_execution" and c["status"] == "independently_reviewed"
            for c in packet["obligation_classes"]
        )
    ):
        fail(f"{path.name}: unexecuted bounded_source_execution marked independently_reviewed", failures)


def check_bindings(failures: list[str], checks: list[dict]) -> None:
    bindings = load_json(BINDINGS)
    if bindings["worktree_head"] != "01490b539b3d30bb992e0d6cfc603022d7be99a9":
        fail(f"source-bindings worktree_head {bindings['worktree_head']}", failures)
    if bindings["certificates_are_p16_prerequisite"] is not False:
        fail("certificates_are_p16_prerequisite must be false", failures)
    if bindings["p16_implementation_opened"] is not False:
        fail("p16_implementation_opened must be false", failures)
    if bindings["tasks_ticked"] is not False:
        fail("tasks_ticked must be false", failures)

    pairs = []
    ki = bindings["kernel_identity"]
    pairs.append((WT / "lean/lean-toolchain", ki["lean_toolchain_sha256"]))
    pairs.append((WT / "lean/lake-manifest.json", ki["lake_manifest_sha256"]))
    pairs.append((WT / "lean/lakefile.toml", ki["lakefile_toml_sha256"]))
    pairs.append((WT / "lean/DefiKernel.lean", ki["defikernel_root_sha256"]))
    op = bindings["kernel_operator"]
    pairs.append((WT / op["execute"]["path"], op["execute"]["sha256"]))
    pairs.append((WT / op["identities_file"]["path"], op["identities_file"]["sha256"]))
    pairs.append((WT / op["authority_file"]["path"], op["authority_file"]["sha256"]))
    pairs.append((WT / op["expr_file"]["path"], op["expr_file"]["sha256"]))
    pairs.append((WT / op["composition"]["interfaces"]["path"], op["composition"]["interfaces"]["sha256"]))
    pairs.append((WT / op["composition"]["execution"]["path"], op["composition"]["execution"]["sha256"]))
    pairs.append((WT / op["composition"]["sequence"]["path"], op["composition"]["sequence"]["sha256"]))
    pairs.append((WT / op["composition"]["world"]["path"], op["composition"]["world"]["sha256"]))
    for mod in bindings["library_arithmetic"]["modules"]:
        pairs.append((WT / mod["path"], mod["sha256"]))
    for item in bindings["read_only_planning_inputs"]["files"]:
        pairs.append((WT / item["path"], item["sha256"]))

    hashed = 0
    for path, expected in pairs:
        if not path.is_file():
            fail(f"missing bound file {path}", failures)
            continue
        actual = sha256(path)
        hashed += 1
        if actual != expected:
            fail(f"hash mismatch {path}: expected {expected} got {actual}", failures)
    checks.append({"name": "binding_hash_pairs", "count": hashed, "status": "compared"})

    token0 = Path(bindings["token0_source"]["files"][0]["rel"])
    # files listed as rel under capture_root
    capture = Path(bindings["token0_source"]["capture_root"])
    for rec in bindings["token0_source"]["files"]:
        p = capture / rec["rel"]
        if not p.is_file():
            fail(f"missing captured source {p}", failures)
            continue
        actual = sha256(p)
        hashed += 1
        if actual != rec["sha256"]:
            fail(f"hash mismatch {p}: expected {rec['sha256']} got {actual}", failures)
        if p.stat().st_size != rec["bytes"]:
            fail(f"byte mismatch {p}", failures)
    checks.append({"name": "token0_capture_files", "count": len(bindings["token0_source"]["files"]), "status": "compared"})

    oracle = Path(bindings["token0_source"]["python_oracle"]["path"])
    if oracle.is_file():
        actual = sha256(oracle)
        if actual != bindings["token0_source"]["python_oracle"]["sha256"]:
            fail(f"oracle hash mismatch {actual}", failures)
        checks.append({"name": "python_oracle", "count": 1, "status": "compared"})
    else:
        fail(f"python oracle missing {oracle}", failures)


def main() -> int:
    failures: list[str] = []
    checks: list[dict] = []
    schema = load_json(SCHEMA)
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator(schema)
    checks.append({"name": "schema_meta", "count": 1, "status": "ok"})

    packets = sorted(EXAMPLES.glob("*.packet.json"))
    if len(packets) == 0:
        fail("no example packets", failures)
    for path in packets:
        packet = load_json(path)
        errs = sorted(validator.iter_errors(packet), key=lambda e: list(e.path))
        if errs:
            for e in errs:
                fail(f"{path.name} schema: {e.message} at {list(e.path)}", failures)
        else:
            check_packet_semantics(path, packet, failures)
        checks.append({"name": f"packet:{path.name}", "count": 1, "status": "validated" if not errs else "schema_fail"})

    # Negative control: self-asserted credit must fail schema.
    invalid = load_json(FIXTURES / "credit-self-assert.invalid.json")
    invalid_errs = list(validator.iter_errors(invalid))
    if not invalid_errs:
        fail("credit-self-assert.invalid.json was accepted by schema", failures)
    else:
        checks.append(
            {
                "name": "negative_credit_self_assert",
                "count": len(invalid_errs),
                "status": "rejected_as_required",
            }
        )

    bindings = load_json(BINDINGS)
    if bindings["package_id"] != "reusable-verification-platform.p15.minimum-contracts":
        fail("unexpected package_id", failures)
    check_bindings(failures, checks)

    # Cross-file references
    for name in [
        "kernel-operator-contract.md",
        "library-arithmetic-contract.md",
        "adapter-observation-contract.md",
        "evidence-packet-usage.md",
        "README.md",
        "evidence-packet.schema.json",
        "source-bindings.json",
    ]:
        p = CONTRACTS / name
        if not p.is_file() or p.stat().st_size == 0:
            fail(f"missing or empty {name}", failures)
    checks.append({"name": "contract_files_present", "count": 7, "status": "ok"})

    result = {
        "validator": "review/semantic-kernel/p15-contracts-20260908/grok-author/validate_packets.py",
        "schema": str(SCHEMA.relative_to(WT)),
        "packet_count": len(packets),
        "checks": checks,
        "check_count": len(checks),
        "failure_count": len(failures),
        "failures": failures,
        "ok": len(failures) == 0,
    }
    print(json.dumps(result, indent=2))
    return 0 if result["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())
