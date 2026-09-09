#!/usr/bin/env python3
"""Structural controls for the P17 planning slice. Not source execution, not mutation credit."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

RAY = 10**27
WAD = 10**18
CHI_D1 = RAY + 1


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for candidate in [here.parents[6], Path.cwd()]:
        if (candidate / "openspec/changes/vault-platform-reuse-p17/proposal.md").is_file():
            return candidate
    raise SystemExit("blocked: cannot locate vault-platform-reuse-p17 from diagnose.py")


def divup(x: int, y: int) -> int:
    if y == 0:
        raise SystemExit("blocked: divup denominator 0 in diagnostic formulae")
    return 0 if x == 0 else (x - 1) // y + 1


def load_json(path: Path) -> object:
    return json.loads(path.read_text())


def spec_counts(change: Path) -> tuple[int, int, list[str]]:
    reqs = 0
    scenarios = 0
    names: list[str] = []
    for spec in sorted((change / "specs").rglob("spec.md")):
        text = spec.read_text()
        reqs += len(re.findall(r"^### Requirement:", text, re.M))
        for m in re.finditer(r"^#### Scenario: (.+)$", text, re.M):
            names.append(m.group(1).strip())
            scenarios += 1
    return reqs, scenarios, names


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--empty-corpus", action="store_true")
    parser.add_argument("--out", type=Path, default=None)
    args = parser.parse_args()
    root = repo_root()
    change = root / "openspec/changes/vault-platform-reuse-p17"
    capture = root / "review/semantic-kernel/program-execution-20260908/p17-source-acquisition"
    failures: list[str] = []
    checks: list[dict] = []

    def check(name: str, ok: bool, detail: object) -> None:
        checks.append({"name": name, "ok": ok, "detail": detail})
        if not ok:
            failures.append(name)

    source_pin = load_json(change / "source-pin.json")
    fixtures_doc = load_json(change / "fixtures.json")
    mutations_doc = load_json(change / "planned-mutations.json")
    remaining = load_json(change / "remaining-gates.json")
    reuse = load_json(change / "reuse-design.json")
    compiler = load_json(change / "compiler-harness-plan.json")
    scenario_map = load_json(change / "scenario-map.json")

    if args.empty_corpus:
        fixtures_doc = {"fixtures": [], "partitions": []}
        mutations_doc = {"vault_production_mutants": []}

    fixtures = list(fixtures_doc.get("fixtures") or [])
    mutants = list(mutations_doc.get("vault_production_mutants") or [])
    partitions = list(fixtures_doc.get("partitions") or [])

    check("nonempty_fixtures", len(fixtures) > 0, {"count": len(fixtures)})
    check("nonempty_partitions", len(partitions) > 0, {"count": len(partitions)})
    check("nonempty_mutants", len(mutants) > 0, {"count": len(mutants)})

    ids = [f.get("id") for f in fixtures]
    check("unique_fixture_ids", len(ids) == len(set(ids)) and all(isinstance(i, str) and i for i in ids), ids)

    expected_d1_deposit = str(WAD * RAY // CHI_D1)
    expected_d1_mint = str(divup(WAD * CHI_D1, RAY))
    expected_d1_redeem = str(WAD * CHI_D1 // RAY)
    expected_d1_withdraw = str(divup(WAD * RAY, CHI_D1))
    by_id = {f.get("id"): f for f in fixtures if isinstance(f, dict)}
    if not args.empty_corpus:
        check(
            "independent_P17-DEP-D0",
            by_id.get("P17-DEP-D0", {}).get("expected", {}).get("ok_shares") == str(WAD),
            by_id.get("P17-DEP-D0", {}).get("expected"),
        )
        check(
            "independent_P17-DEP-D1",
            by_id.get("P17-DEP-D1", {}).get("expected", {}).get("ok_shares") == expected_d1_deposit,
            {"expected": expected_d1_deposit, "got": by_id.get("P17-DEP-D1", {}).get("expected")},
        )
        check(
            "independent_P17-MINT-D1",
            by_id.get("P17-MINT-D1", {}).get("expected", {}).get("ok_assets") == expected_d1_mint,
            {"expected": expected_d1_mint, "got": by_id.get("P17-MINT-D1", {}).get("expected")},
        )
        check(
            "independent_P17-RED-D1",
            by_id.get("P17-RED-D1", {}).get("expected", {}).get("ok_assets") == expected_d1_redeem,
            {"expected": expected_d1_redeem, "got": by_id.get("P17-RED-D1", {}).get("expected")},
        )
        check(
            "independent_P17-WD-D1",
            by_id.get("P17-WD-D1", {}).get("expected", {}).get("ok_shares") == expected_d1_withdraw,
            {"expected": expected_d1_withdraw, "got": by_id.get("P17-WD-D1", {}).get("expected")},
        )
        ovf = 2**256 // RAY + 1
        check(
            "independent_P17-DEP-MUL-OVF",
            by_id.get("P17-DEP-MUL-OVF", {}).get("inputs", {}).get("assets") == str(ovf),
            {"expected": str(ovf), "got": by_id.get("P17-DEP-MUL-OVF", {}).get("inputs")},
        )
        check("negative_present", "P17-NEG-MINT-NO-CREDIT" in by_id, list(by_id))

    fixture_ids = set(by_id)
    for mutant in mutants:
        mid = mutant.get("id")
        designated = mutant.get("designated_false")
        unaffected = mutant.get("unaffected_positive")
        check(
            f"mutant_{mid}_designated_in_fixtures",
            isinstance(designated, str) and designated in fixture_ids,
            {"designated": designated},
        )
        check(
            f"mutant_{mid}_unaffected_in_fixtures",
            isinstance(unaffected, str) and unaffected in fixture_ids and unaffected != designated,
            {"unaffected": unaffected, "designated": designated},
        )
        change_text = str(mutant.get("actual_source_change"))
        check(
            f"mutant_{mid}_one_solidity_edit",
            mutant.get("language") == "Solidity"
            and ("Delete" in change_text or "Replace" in change_text),
            mutant.get("actual_source_change"),
        )

    check("gate_accepted_false", remaining.get("gate_accepted") is False, remaining.get("gate_accepted"))
    check("platform_reuse_false", remaining.get("p17_platform_reuse") is False, remaining.get("p17_platform_reuse"))
    check("independent_not_run", remaining.get("independent_gpt6") == "required_not_run", remaining.get("independent_gpt6"))
    check("p16_gate_not_assumed", remaining.get("p16_source_gate_assumed_closed") is False, None)
    check("composition_unclaimed", reuse.get("composition_integration_claimed") is False, None)
    check("wrapper_rejected", reuse.get("common_harness_engine", {}).get("wrapper_around_separate_engines") is False, None)
    check("smoke_not_campaign", compiler.get("administrative_smoke", {}).get("is_campaign_bytecode") is False, None)
    check("python_not_source", fixtures_doc.get("python_not_source_execution") is True or args.empty_corpus, None)
    check("solc_not_run", fixtures_doc.get("solc_executed") is False or args.empty_corpus, None)
    check("planning_not_mutation_credit", mutations_doc.get("planning_validation_is_not_production_mutation_credit") is True or args.empty_corpus, None)

    main_rel = capture / "capture/src/SUsds.sol"
    l2_rel = capture / "capture/src/l2/SUsds.sol"
    if not args.empty_corpus:
        if not main_rel.is_file() or not l2_rel.is_file():
            check("source_files_present", False, {"main": str(main_rel), "l2": str(l2_rel)})
        else:
            main_sha = sha256_file(main_rel)
            l2_sha = sha256_file(l2_rel)
            check("main_sha", main_sha == source_pin["pin"]["sha256"] and main_rel.stat().st_size == source_pin["pin"]["bytes"], {"actual": main_sha, "size": main_rel.stat().st_size})
            check("l2_sha", l2_sha == source_pin["rejected_l2"]["sha256"] and l2_rel.stat().st_size == source_pin["rejected_l2"]["bytes"], {"actual": l2_sha, "size": l2_rel.stat().st_size})
            check("main_vs_l2", main_sha != l2_sha, {"main": main_sha, "l2": l2_sha})
            closure_ok = True
            closure_rows = []
            for entry in source_pin["compiler_source_keys"]:
                key = entry["key"]
                if key.startswith("src/"):
                    path = capture / "compile-source-closure" / key
                    if not path.is_file():
                        path = capture / "capture" / key
                else:
                    path = capture / "compile-source-closure" / key
                if not path.is_file():
                    closure_ok = False
                    closure_rows.append({"key": key, "missing": str(path)})
                    continue
                actual = sha256_file(path)
                size = path.stat().st_size
                match = actual == entry["sha256"] and size == entry["bytes"]
                closure_ok = closure_ok and match
                closure_rows.append({"key": key, "match": match, "actual": actual, "size": size})
            check("closure_hashes", closure_ok and len(source_pin["compiler_source_keys"]) == 10, {"count": len(source_pin["compiler_source_keys"]), "rows": closure_rows})
            foundry = capture / "capture/foundry.toml"
            check("foundry_toml", foundry.is_file() and sha256_file(foundry) == source_pin["foundry_toml"]["sha256"], sha256_file(foundry) if foundry.is_file() else None)

    reqs, scenarios, names = spec_counts(change)
    check("requirements_nonempty", reqs > 0, reqs)
    check("scenarios_nonempty", scenarios > 0, scenarios)
    check("scenario_names_unique", len(names) == len(set(names)), names)
    mapped = [row["scenario"] for row in scenario_map.get("scenarios", [])]
    check("scenario_map_covers_specs", set(names) <= set(mapped) and set(mapped) <= set(names), {"spec": names, "map": mapped})

    tasks_text = (change / "tasks.md").read_text()
    checked = len(re.findall(r"^- \[x\]", tasks_text, re.M))
    unchecked = len(re.findall(r"^- \[ \]", tasks_text, re.M))
    check("tasks_unchecked", checked == 0 and unchecked > 0, {"checked": checked, "unchecked": unchecked})

    result = {
        "schema": "p17-vault-planning-diagnose/v1",
        "empty_corpus": args.empty_corpus,
        "repo_root": str(root),
        "checks": checks,
        "failures": failures,
        "counts": {
            "checks": len(checks),
            "failed": len(failures),
            "fixtures": len(fixtures),
            "mutants": len(mutants),
            "requirements": reqs,
            "scenarios": scenarios,
            "tasks_unchecked": unchecked,
            "tasks_checked": checked,
        },
        "production_mutation_credit": 0,
        "solc_executed": False,
        "evm_executed": False,
        "lean_executed": False,
        "python_is_source_execution": False,
    }
    text = json.dumps(result, indent=2) + "\n"
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(text)
    else:
        sys.stdout.write(text)

    if args.empty_corpus:
        if len(fixtures) == 0 or len(mutants) == 0:
            return 3
        return 1
    if failures:
        return 1
    if len(checks) == 0:
        return 3
    return 0


if __name__ == "__main__":
    sys.exit(main())
