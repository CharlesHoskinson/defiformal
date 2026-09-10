#!/usr/bin/env python3
"""P18 release validator.

Schema validity is not proof. Required packet inventory is independent of the
loaded glob. Missing/empty required evidence is blocked (exit 3). Contradictory
or changed claims are fail (exit 1). Intact matching evidence is 0.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[5]
SCHEMA = ROOT / "openspec/changes/reusable-verification-platform-program/contracts/evidence-packet.schema.json"
DEFAULT_PACKETS = ROOT / "review/semantic-kernel/platform-increment/p18/packets"
DEFAULT_INVENTORY = Path(__file__).resolve().parent / "required-inventory.json"
DEFAULT_INDEX = Path(__file__).resolve().parent / "evidence-binding-index.json"
FIXTURES = Path(__file__).resolve().parent / "fixtures"
OLD_EXAMPLES = ROOT / "openspec/changes/reusable-verification-platform-program/contracts/examples"
USAGE = ROOT / "openspec/changes/reusable-verification-platform-program/contracts/evidence-packet-usage.md"

RELEASE_REQUIRED_PACKETS = ["p18.token0.next-price.packet.json"]
RELEASE_REQUIRED_PACKET_ID = "p18.token0.next-price.accepted-p16-increment"
EMPTY_SHA256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
OLD_PACKET_HASHES = {
    "empty-denominator-blocked.packet.json": "04826ff3fb466211366ccb643eec1be4646b954a4922c6d5b6f7788fbf1783c1",
    "illustrative-not-credited.packet.json": "cf610eb2527d1fd2822cecb72d28bb8fda3896b097a149720e930886fbff5192",
    "token0-unexecuted-incomplete.packet.json": "9c3ea55a13792c089da218ccecf32f6b80dfa81d3c0c6649240cc9640ec065a4",
}


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_json(path: Path):
    return json.loads(path.read_text())


def nonempty_log(sha: str | None, size: int | None) -> bool:
    if not sha or sha == EMPTY_SHA256:
        return False
    if size is not None and size <= 0:
        return False
    return True


def classify_exit(blocked: list[str], failures: list[str]) -> int:
    if blocked:
        return 3
    if failures:
        return 1
    return 0


def resolve_run(index: dict, run_id: str, claimed_sha: str | None, root: Path, blocked: list[str], failures: list[str], kind: str) -> dict | None:
    by_id = {r["id"]: r for r in index.get("runtime_bindings", [])}
    rec = by_id.get(run_id)
    if rec is None:
        failures.append(f"{kind} {run_id}: no release-side binding for this run id")
        return None
    path = root / rec["log_path"]
    if not path.is_file():
        blocked.append(f"{kind} {run_id}: bound log missing {rec['log_path']}")
        return rec
    actual = sha256_file(path)
    size = path.stat().st_size
    if rec.get("log_sha256") and rec["log_sha256"] != actual:
        failures.append(f"{kind} {run_id}: binding index hash {rec['log_sha256']} != file {actual}")
    if claimed_sha and claimed_sha != actual:
        failures.append(f"{kind} {run_id}: claimed log_sha256 {claimed_sha} != bound file {actual}")
    if rec.get("class") in {"source_runtime", "model_runtime"} and not nonempty_log(actual, size):
        failures.append(f"{kind} {run_id}: empty log presented as {rec.get('class')}")
    return rec


def evaluate_main_packet(packet: dict, index: dict, root: Path, blocked: list[str], failures: list[str]) -> dict:
    if packet.get("packet_id") != RELEASE_REQUIRED_PACKET_ID:
        failures.append(f"required packet id {packet.get('packet_id')} != {RELEASE_REQUIRED_PACKET_ID}")

    parts = packet["executions"]["partitions"]
    derived_declared = len(parts)
    derived_nonempty = sum(1 for p in parts if p.get("nonempty"))
    derived_empty = sum(1 for p in parts if not p.get("nonempty"))
    case_ids: list[str] = []
    for p in parts:
        cases = p.get("cases") or []
        if p.get("count") != len(cases):
            failures.append(f"partition {p.get('id')} count {p.get('count')} != len(cases) {len(cases)}")
        if p.get("nonempty") and (p.get("count") or 0) < 1:
            blocked.append(f"nonempty partition {p.get('id')} has empty count")
        if (not p.get("nonempty")) and p.get("count") != 0:
            failures.append(f"empty partition {p.get('id')} has count {p.get('count')}")
        case_ids.extend(cases)
    claimed_parts = packet["denominators"]["partitions"]
    if claimed_parts["declared"] != derived_declared or claimed_parts["nonempty"] != derived_nonempty or claimed_parts["empty"] != derived_empty:
        failures.append(f"partitions denominator {claimed_parts} != derived declared={derived_declared} nonempty={derived_nonempty} empty={derived_empty}")
    if derived_nonempty == 0 or claimed_parts["nonempty"] == 0:
        blocked.append("required nonempty partitions are empty")

    expected_rows = index.get("source_observation_ids") or []
    if expected_rows and case_ids != expected_rows and sorted(case_ids) != sorted(expected_rows):
        if set(case_ids) != set(expected_rows) or len(case_ids) != len(expected_rows):
            failures.append(f"partition cases {case_ids} != bound source observation ids {expected_rows}")

    source_runs = packet["executions"]["source_runs"]
    model_runs = packet["executions"]["model_runs"]
    derived_source_runtime = 0
    derived_model_runtime = 0
    for run in source_runs:
        if run.get("status") != "executed":
            continue
        rec = resolve_run(index, run["id"], run.get("log_sha256"), root, blocked, failures, "source_run")
        if rec is None:
            continue
        if rec.get("class") != "source_runtime":
            failures.append(f"source_run {run['id']} bound class is {rec.get('class')}, not source_runtime")
            continue
        path = root / rec["log_path"]
        if path.is_file() and nonempty_log(sha256_file(path), path.stat().st_size):
            derived_source_runtime += 1
    compilation_ids = {r["id"] for r in index.get("compilation_bindings", [])}
    for run in model_runs:
        if run.get("status") != "executed":
            continue
        if run["id"] in compilation_ids:
            failures.append(
                f"model_run {run['id']} is a compilation receipt, not a nonempty model runtime witness"
            )
            continue
        rec = resolve_run(index, run["id"], run.get("log_sha256"), root, blocked, failures, "model_run")
        if rec is None:
            continue
        if rec.get("class") == "compilation":
            failures.append(f"model_run {run['id']} is compilation, not a nonempty model runtime witness")
            continue
        if rec.get("class") != "model_runtime":
            failures.append(f"model_run {run['id']} bound class is {rec.get('class')}, not model_runtime")
            continue
        path = root / rec["log_path"]
        if path.is_file() and nonempty_log(sha256_file(path), path.stat().st_size):
            derived_model_runtime += 1

    derived_runtime = derived_source_runtime + derived_model_runtime
    claimed_exec = packet["denominators"]["executions"]
    if derived_source_runtime == 0 or derived_model_runtime == 0 or claimed_exec["actually_run"] == 0:
        blocked.append(
            f"required runtime evidence empty: derived_source_runtime={derived_source_runtime} "
            f"derived_model_runtime={derived_model_runtime} claimed_actually_run={claimed_exec['actually_run']}"
        )
    elif claimed_exec["actually_run"] != derived_runtime:
        failures.append(
            f"executions.actually_run claimed {claimed_exec['actually_run']} != derived {derived_runtime} "
            f"(units: executed nonempty source_runtime+model_runtime invocations; "
            f"source={derived_source_runtime} model={derived_model_runtime})"
        )
    planned_derived = len(source_runs) + len(model_runs)
    if claimed_exec["planned"] != planned_derived:
        failures.append(f"executions.planned claimed {claimed_exec['planned']} != derived {planned_derived}")
    unexecuted_derived = sum(1 for r in source_runs + model_runs if r.get("status") != "executed")
    if claimed_exec["unexecuted"] != unexecuted_derived:
        failures.append(f"executions.unexecuted claimed {claimed_exec['unexecuted']} != derived {unexecuted_derived}")

    prod = [m for m in packet["mutations"]["production"] if m.get("status") == "compiled_production"]
    controls = [m for m in packet["mutations"]["unaffected_controls"] if m.get("status") == "compiled_production"]
    python_only = packet["mutations"]["python_only"]
    claimed_mut = packet["denominators"]["mutations"]
    mut_index = {m["id"]: m for m in index.get("mutation_bindings", [])}
    ctrl_index = {m["id"]: m for m in index.get("control_bindings", [])}
    derived_prod = 0
    for m in prod:
        rec = mut_index.get(m["id"])
        if rec is None:
            failures.append(f"production mutant {m['id']} has no binding")
            continue
        summary = root / rec["summary_path"]
        if not summary.is_file():
            blocked.append(f"production mutant {m['id']}: summary missing {rec['summary_path']}")
            continue
        data = load_json(summary)
        if data.get("status") != "ok" or data.get("compile_status") != "compiled":
            failures.append(f"production mutant {m['id']} summary not compiled/ok")
            continue
        if not data.get("designated", {}).get("changed") or not data.get("unaffected_control", {}).get("unchanged"):
            failures.append(f"production mutant {m['id']} designated/control gate failed in bound summary")
            continue
        if m.get("designated_observation") != data["designated"]["id"]:
            failures.append(f"production mutant {m['id']} designated_observation mismatch")
        if m.get("unaffected_sibling") != data["unaffected_control"]["id"]:
            failures.append(f"production mutant {m['id']} unaffected_sibling mismatch")
        derived_prod += 1
    derived_ctrl = 0
    for m in controls:
        rec = ctrl_index.get(m["id"])
        if rec is None:
            failures.append(f"unaffected control {m['id']} has no binding")
            continue
        summary = root / rec["summary_path"]
        if not summary.is_file():
            blocked.append(f"unaffected control {m['id']}: summary missing {rec['summary_path']}")
            continue
        data = load_json(summary)
        if not data.get("unaffected_control", {}).get("unchanged"):
            failures.append(f"unaffected control {m['id']} not unchanged in bound summary")
            continue
        derived_ctrl += 1
    if derived_prod == 0 or claimed_mut["compiled_production"] == 0:
        blocked.append(f"required compiled production mutants empty: derived={derived_prod} claimed={claimed_mut['compiled_production']}")
    elif claimed_mut["compiled_production"] != derived_prod:
        failures.append(f"mutations.compiled_production claimed {claimed_mut['compiled_production']} != derived {derived_prod}")
    if derived_ctrl == 0 or claimed_mut["unaffected_controls"] == 0:
        blocked.append(f"required unaffected controls empty: derived={derived_ctrl} claimed={claimed_mut['unaffected_controls']}")
    elif claimed_mut["unaffected_controls"] != derived_ctrl:
        failures.append(f"mutations.unaffected_controls claimed {claimed_mut['unaffected_controls']} != derived {derived_ctrl}")
    if claimed_mut["python_only"] != len(python_only):
        failures.append(f"mutations.python_only claimed {claimed_mut['python_only']} != derived {len(python_only)}")

    theorems = packet["theorem_evidence"]["theorems"]
    derived_named = sum(1 for t in theorems if t.get("status") == "named")
    derived_unproved = sum(1 for t in theorems if t.get("status") == "not_yet_proved")
    claimed_th = packet["denominators"]["theorems"]
    if derived_named == 0:
        blocked.append("required named theorems empty")
    elif claimed_th["named"] != derived_named:
        failures.append(f"theorems.named claimed {claimed_th['named']} != derived {derived_named}")
    if claimed_th["not_yet_proved"] != derived_unproved:
        failures.append(f"theorems.not_yet_proved claimed {claimed_th['not_yet_proved']} != derived {derived_unproved}")
    for th in theorems:
        tpath = root / th["path"]
        if not tpath.is_file():
            blocked.append(f"theorem path missing {th['path']}")
        elif sha256_file(tpath) != th.get("sha256"):
            failures.append(f"theorem hash mismatch {th['name']}")

    src = packet["identities"]["source"]
    model = packet["identities"]["model"]
    for label, ident in (("source", src), ("model", model)):
        if not ident.get("path"):
            blocked.append(f"main packet {label} path missing")
            continue
        p = root / ident["path"]
        if not p.is_file():
            blocked.append(f"main packet {label} missing {ident['path']}")
        elif ident.get("sha256") and sha256_file(p) != ident["sha256"]:
            failures.append(f"main packet {label} hash mismatch")

    for rec in index.get("archive_bindings", []):
        p = root / rec["path"]
        if not p.is_file():
            blocked.append(f"bound archive missing {rec['path']}")
        elif sha256_file(p) != rec["sha256"]:
            failures.append(f"bound archive hash mismatch {rec['path']}")

    if packet.get("credit_eligible") is True:
        failures.append("author set credit_eligible true before Opus review")
    verdict = packet.get("independent_verdict") or {}
    if verdict.get("verdict") != "pending":
        failures.append("P18 independent verdict is not pending")
    if verdict.get("requested_model") != "opus":
        failures.append("requested_model is not opus")
    if verdict.get("reported_model") is not None:
        failures.append("reported_model must remain null until Opus returns")
    for cls in packet.get("obligation_classes") or []:
        if cls.get("class") == "source_refinement" and cls.get("status") != "open":
            failures.append("source_refinement is not open")
        if cls.get("class") == "representation_correspondence" and cls.get("status") != "open":
            failures.append("representation_correspondence is not open")

    reviews = packet["denominators"]["independent_reviews"]
    if reviews.get("completed") != 0:
        failures.append("independent_reviews.completed must be 0 until Opus")
    if reviews.get("required", 0) < 1:
        blocked.append("independent_reviews.required is 0")

    return {
        "derived_source_runtime": derived_source_runtime,
        "derived_model_runtime": derived_model_runtime,
        "derived_runtime": derived_runtime,
        "derived_production": derived_prod,
        "derived_controls": derived_ctrl,
        "derived_named_theorems": derived_named,
        "derived_partitions_nonempty": derived_nonempty,
        "units": index.get("units"),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--packets-dir", default=None)
    parser.add_argument("--inventory", default=None)
    parser.add_argument("--binding-index", default=None)
    args = parser.parse_args()

    packets_dir = Path(args.packets_dir).resolve() if args.packets_dir else DEFAULT_PACKETS
    inventory_path = Path(args.inventory).resolve() if args.inventory else DEFAULT_INVENTORY
    index_path = Path(args.binding_index).resolve() if args.binding_index else DEFAULT_INDEX

    blocked: list[str] = []
    failures: list[str] = []
    checks: list[dict] = []

    if not inventory_path.is_file():
        blocked.append(f"required inventory missing {inventory_path}")
        result = {
            "validator": "review/semantic-kernel/platform-increment/p18/validation/validate_p18.py",
            "schema_validity_is_not_proof": True,
            "semantic_credit": False,
            "blocked": blocked,
            "failures": failures,
            "ok": False,
            "exit_meaning": "0 intact; 1 contradictory/changed claim; 3 blocked missing/empty required evidence",
        }
        print(json.dumps(result, indent=2))
        return 3
    inventory = load_json(inventory_path)
    required = inventory.get("required_packets") or []
    if required != RELEASE_REQUIRED_PACKETS:
        failures.append(f"inventory required_packets {required} != release contract {RELEASE_REQUIRED_PACKETS}")
    if inventory.get("required_main_packet_id") != RELEASE_REQUIRED_PACKET_ID:
        failures.append("inventory required_main_packet_id does not match release contract")

    missing_required = [name for name in RELEASE_REQUIRED_PACKETS if not (packets_dir / name).is_file()]
    if missing_required:
        blocked.append(f"required release packet missing: {missing_required}; control fixtures cannot satisfy the release")

    if not index_path.is_file():
        blocked.append(f"evidence binding index missing {index_path}")
    else:
        index = load_json(index_path)

    schema = load_json(SCHEMA)
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator(schema)

    loaded = sorted(packets_dir.glob("*.packet.json")) if packets_dir.is_dir() else []
    p17 = [p for p in loaded if "p17" in p.name.lower()]
    if p17:
        failures.append(f"P17 packets present while P17 is open: {[p.name for p in p17]}")

    summaries = []
    derived = None
    if index_path.is_file() and not missing_required:
        index = load_json(index_path)
        main_path = packets_dir / RELEASE_REQUIRED_PACKETS[0]
        main = load_json(main_path)
        errs = sorted(validator.iter_errors(main), key=lambda e: list(e.path))
        if errs:
            for e in errs:
                failures.append(f"{main_path.name} schema: {e.message} at {list(e.path)}")
            checks.append({"name": f"packet:{main_path.name}", "status": "schema_fail"})
        else:
            checks.append({"name": f"packet:{main_path.name}", "status": "schema_ok"})
            derived = evaluate_main_packet(main, index, ROOT, blocked, failures)
            summaries.append(
                {
                    "path": main_path.name,
                    "derived_runtime": derived["derived_runtime"],
                    "derived_production": derived["derived_production"],
                    "derived_controls": derived["derived_controls"],
                    "credit_eligible": main.get("credit_eligible"),
                }
            )
            if main.get("credit_eligible") is True:
                failures.append("validator must not treat the pending packet as credited")

    for path in loaded:
        if path.name in RELEASE_REQUIRED_PACKETS:
            continue
        packet = load_json(path)
        errs = sorted(validator.iter_errors(packet), key=lambda e: list(e.path))
        if errs:
            for e in errs:
                failures.append(f"{path.name} schema: {e.message} at {list(e.path)}")
            checks.append({"name": f"packet:{path.name}", "status": "schema_fail"})
            continue
        checks.append({"name": f"packet:{path.name}", "status": "schema_ok_optional_control"})
        if packet.get("credit_eligible") is True:
            failures.append(f"{path.name}: control/optional packet set credit_eligible true")

    invalid = load_json(FIXTURES / "credit-self-assert.invalid.json")
    invalid_errs = list(validator.iter_errors(invalid))
    if not invalid_errs:
        failures.append("credit-self-assert.invalid.json was accepted by schema")
    else:
        checks.append({"name": "negative_credit_self_assert", "count": len(invalid_errs), "status": "rejected_as_required"})

    for name, expected in OLD_PACKET_HASHES.items():
        path = OLD_EXAMPLES / name
        if not path.is_file():
            blocked.append(f"old illustrative packet missing {name}")
            continue
        actual = sha256_file(path)
        if actual != expected:
            failures.append(f"old packet rewritten {name}: {actual}")
        else:
            checks.append({"name": f"preserved:{name}", "status": "unchanged"})

    if not USAGE.is_file() or USAGE.stat().st_size == 0:
        blocked.append("usage contract missing")

    example = ROOT / "examples/platform-increment/lean/Token0ReleaseExample.lean"
    if not example.is_file() or example.stat().st_size == 0:
        blocked.append("example Lean missing")
    readme = ROOT / "examples/platform-increment/README.md"
    if readme.is_file() and "lake env lean" not in readme.read_text():
        failures.append("README missing lake env lean invocation")
    env_example_path = ROOT / "examples/platform-increment/environment.example.json"
    if env_example_path.is_file():
        text = env_example_path.read_text()
        if "/home/charl/.cache" in text or "/home/charl/defiformal-wt-" in text:
            failures.append("API files bake a private path")
        env_example = load_json(env_example_path)
        for key in ("lake", "lean", "solc", "evm", "repository_root"):
            if env_example.get(key) not in (None,):
                failures.append(f"environment.example.json {key} is not null")

    expected_obs = ROOT / "examples/platform-increment/expected/token0-observations.json"
    if not expected_obs.is_file():
        blocked.append("expected observations missing")
    else:
        obs = load_json(expected_obs)
        if obs.get("count") != 12 or not obs.get("rows"):
            blocked.append("expected observations empty")
        elif obs["count"] != len(obs["rows"]):
            failures.append("expected count mismatch")

    code = classify_exit(blocked, failures)
    result = {
        "validator": "review/semantic-kernel/platform-increment/p18/validation/validate_p18.py",
        "schema_validity_is_not_proof": True,
        "semantic_credit": False,
        "packets_dir": str(packets_dir),
        "required_inventory": str(inventory_path),
        "required_packets": RELEASE_REQUIRED_PACKETS,
        "loaded_packet_count": len(loaded),
        "checks": checks,
        "check_count": len(checks),
        "summaries": summaries,
        "derived": derived,
        "blocked": blocked,
        "blocked_count": len(blocked),
        "failures": failures,
        "failure_count": len(failures),
        "ok": code == 0,
        "exit_meaning": "0 intact matching evidence with credit false; 1 contradictory/changed claim; 3 blocked missing/empty required evidence",
    }
    print(json.dumps(result, indent=2))
    return code


if __name__ == "__main__":
    raise SystemExit(main())
