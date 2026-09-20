#!/usr/bin/env python3
"""Reproduce and lock P19 fixture-runner truthful outcome behavior.

Exercises actual functions in run_certificate_fixtures.py.
Does not derive expected values from checker output.

The CLI nonzero-child probe explicitly simulates a Lean `--run` child: it prints
the checked-in F01 expected object from fixtures.json and exits 1. That is not a
real Lean failure. Other tests invoke the real lake/Lean path.
"""
import copy
import hashlib
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile


SCRIPTS = Path(__file__).resolve().parent
REPO = SCRIPTS.parent
if str(SCRIPTS) not in sys.path:
    sys.path.insert(0, str(SCRIPTS))

import run_certificate_fixtures as runner  # noqa: E402


FROZEN_FIXTURES = REPO / "openspec/changes/serialized-kernel-certificates/fixtures.json"
REVIEWED_COMPANIONS = REPO / "lean/DefiKernel/Certificates/f41-assumption-companions.json"
FROZEN_FIXTURES_SHA256 = "ad1857ecf7269920a2169ab7e644d28da3311cad91be60df09a737cf94fe7742"
REVIEWED_COMPANIONS_SHA256 = "9cb69f8bb937ad410c3554f3dde38e8e3a199339f5d54f9d256cb5fda46f8575"

VERIFIED_STATUSES = {
    "verified_by_fixture",
    "verified_by_fixture_and_theorem",
    "theorem_proved_codec_roundtrip",
    "bounded_fixture_verified",
}


def load_f41():
    data = json.loads(FROZEN_FIXTURES.read_text(encoding="utf-8"))
    return next(fix for fix in data["fixtures"] if fix["id"] == "F41")


def load_reviewed_companions():
    return json.loads(REVIEWED_COMPANIONS.read_text(encoding="utf-8"))


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def test_zero_controls_cannot_pass():
    code = runner.campaign_exit_code(
        passed_count=54, total=54, control_discriminated_count=0, audit_ok=True
    )
    assert code == 1, f"completed campaign with zero controls is mismatch 1, got exit {code}"
    print("PASS: zero controls cannot pass.")


def test_missing_controls_cannot_pass():
    code = runner.campaign_exit_code(
        passed_count=54, total=54, control_discriminated_count=53, audit_ok=True
    )
    assert code == 1, f"completed campaign with missing controls is mismatch 1, got exit {code}"
    print("PASS: missing controls cannot pass.")


def test_failed_control_cannot_pass():
    records = [
        {"id": "F01", "match": True, "control_discriminated": True, "exit_code": 0},
        {"id": "F02", "match": True, "control_discriminated": False, "exit_code": 0},
    ]
    accepted = sum(1 for rec in records if runner.fixture_record_accepted(rec))
    code = runner.campaign_exit_code(
        passed_count=2,
        total=2,
        control_discriminated_count=1,
        audit_ok=True,
        accepted_count=accepted,
    )
    assert code == 1, f"completed campaign with a failed control is mismatch 1, got exit {code}"
    assert not runner.fixture_record_accepted(records[1])
    print("PASS: failed control cannot pass.")


def test_zero_total_cannot_pass():
    code = runner.campaign_exit_code(
        passed_count=0, total=0, control_discriminated_count=0, audit_ok=True
    )
    assert code == 3, f"empty/zero selected inventory must be blocked 3, got exit {code}"
    print("PASS: zero-total campaign is blocked 3, not mismatch 1.")


def test_matching_fixtures_and_controls_can_pass():
    code = runner.campaign_exit_code(
        passed_count=2, total=2, control_discriminated_count=2, audit_ok=True
    )
    assert code == 0, f"expected exit 0 when fixtures and controls pass, got {code}"
    print("PASS: matching fixtures plus controls can pass.")


def _scenario_spec():
    return [
        {"id": "S01", "requirement": "SF01", "fixtures": ["F03"], "tasks": ["2.2"]},
        {"id": "S13", "requirement": "SF04", "fixtures": ["F13"], "tasks": ["2.2"]},
        {"id": "S14", "requirement": "SF04", "fixtures": ["F13"], "tasks": ["2.2"]},
        {"id": "S39", "requirement": "RC01", "fixtures": ["F25"], "tasks": ["2.4"]},
        {"id": "S40", "requirement": "RC01", "fixtures": ["F01"], "tasks": ["2.4", "2.5"]},
        {"id": "S41", "requirement": "RC02", "fixtures": ["F25"], "tasks": ["5.1"]},
        {"id": "S42", "requirement": "RC02", "fixtures": ["F27"], "tasks": ["5.1"]},
        {"id": "S43", "requirement": "RC03", "fixtures": ["F15", "F24"], "tasks": ["5.2"]},
        {"id": "S44", "requirement": "RC03", "fixtures": ["F08", "F26"], "tasks": ["5.2"]},
        {"id": "S48", "requirement": "RC04", "fixtures": ["F37"], "tasks": ["5.1"]},
        {"id": "S64", "requirement": "EV02", "fixtures": ["F25"], "tasks": ["7.4", "8.4"]},
        {"id": "S66", "requirement": "EV03", "fixtures": ["F25"], "tasks": ["7.3", "8.1"]},
        {"id": "S67", "requirement": "EV03", "fixtures": ["F01"], "tasks": ["7.3", "7.5"]},
        {"id": "S76", "requirement": "SF07", "fixtures": ["F25"], "tasks": ["2.5"]},
        {"id": "S78", "requirement": "RC06", "fixtures": ["F25"], "tasks": ["2.4", "5.1"]},
        {"id": "S79", "requirement": "RC06", "fixtures": ["F24"], "tasks": ["5.2"]},
        {"id": "S80", "requirement": "EV04", "fixtures": ["F01"], "tasks": ["8.6"]},
        {"id": "S81", "requirement": "EV05", "fixtures": ["F27", "F47"], "tasks": ["7.3", "7.6"]},
        {"id": "S84", "requirement": "RC05", "fixtures": ["F41"], "tasks": ["5.1"]},
        {"id": "S90", "requirement": "EV06", "fixtures": ["F33", "F38"], "tasks": ["7.1"]},
        {"id": "S98", "requirement": "PB06", "fixtures": ["F27"], "tasks": ["7.6"]},
        {"id": "S99", "requirement": "PB06", "fixtures": ["F25", "F40", "F47"], "tasks": ["7.6"]},
    ]


def _all_pass_map():
    ids = {
        "F01", "F03", "F08", "F13", "F15", "F24", "F25", "F26", "F27",
        "F33", "F37", "F38", "F40", "F41", "F47",
    }
    return {fid: True for fid in ids}


def test_scenarios_are_bounded_observations_not_verified():
    recs = runner.build_scenario_records(_scenario_spec(), _all_pass_map())
    for sid in (
        "S01", "S39", "S40", "S41", "S42", "S43", "S44", "S48",
        "S64", "S66", "S67", "S76", "S78", "S79", "S81", "S84",
        "S90", "S98", "S99",
    ):
        status = recs[sid]["status"]
        assert status not in VERIFIED_STATUSES, f"{sid} inferred acceptance via {status}"
        assert status == "bounded_fixture_observation", f"{sid} status {status}"
        denied = recs[sid].get("does_not_accept") or []
        for cls in (
            "theorem_acceptance",
            "projection_acceptance",
            "mutation_acceptance",
            "inventory_acceptance",
        ):
            assert cls in denied, f"{sid} must not infer {cls}"
        assert "theorems" not in recs[sid], f"{sid} attached hardcoded theorem names"
        assert recs[sid].get("universal_obligation") != "open_for_p20" or status != "theorem_proved_codec_roundtrip"
    print("PASS: scenario output is bounded observation, not verified/theorem/projection/mutation/inventory.")


def test_unrelated_fixture_ids_do_not_verify_special_scenarios():
    recs = runner.build_scenario_records(_scenario_spec(), _all_pass_map())
    assert recs["S39"]["fixtures"] == ["F25"]
    assert recs["S76"]["fixtures"] == ["F25"]
    assert recs["S64"]["fixtures"] == ["F25"]
    assert recs["S66"]["fixtures"] == ["F25"]
    assert recs["S67"]["fixtures"] == ["F01"]
    for sid in ("S39", "S76", "S64", "S66", "S67", "S81", "S90", "S98", "S99"):
        assert recs[sid]["status"] != "verified_by_fixture", sid
        assert recs[sid]["evidence"] != "both_fixture_and_lean_proof", sid
    print("PASS: F25/F01 and ordinary runtime fixtures do not verify codec/mutation/projection/inventory scenarios.")


def test_s13_s14_s80_remain_open():
    recs = runner.build_scenario_records(_scenario_spec(), _all_pass_map())
    for sid in ("S13", "S14", "S80"):
        assert recs[sid]["status"] == "open", f"{sid} status {recs[sid]['status']}"
        assert recs[sid]["evidence"] == "not_discharged_by_mapped_fixture"
    print("PASS: S13/S14/S80 remain open for wrong evidence class.")


def test_failed_mapped_fixture_is_failed_observation():
    recs = runner.build_scenario_records(
        [{"id": "S01", "requirement": "SF01", "fixtures": ["F03"], "tasks": ["2.2"]}],
        {"F03": False},
    )
    assert recs["S01"]["status"] == "failed"
    assert recs["S01"]["status"] not in VERIFIED_STATUSES
    print("PASS: failed mapped fixture is a failed observation, not verified.")


def test_unexecuted_mapped_fixture_is_not_executed_not_failed():
    recs = runner.build_scenario_records(
        [
            {"id": "S01", "requirement": "SF01", "fixtures": ["F03"], "tasks": ["2.2"]},
            {"id": "S84", "requirement": "RC07", "fixtures": ["F37", "F41"], "tasks": ["5.1"]},
        ],
        {"F41": True},
    )
    assert recs["S01"]["status"] in ("open", "not_executed"), recs["S01"]
    assert recs["S01"]["status"] != "failed"
    assert recs["S01"].get("evidence") == "not_executed"
    assert recs["S84"]["status"] in ("open", "not_executed")
    assert recs["S84"]["status"] != "failed"
    assert recs["S84"].get("evidence") == "not_executed"
    print("PASS: absent/unexecuted mapped fixtures are open/not_executed, not failed.")


def test_independent_expected_preserves_frozen_f41_labels():
    f41 = load_f41()
    frozen_assumptions = copy.deepcopy(f41["expected"]["assumptions"])
    frozen_failure = copy.deepcopy(f41["expected"]["failure"])
    ie = runner.independent_expected(f41)
    assert ie["assumptions"] == frozen_assumptions
    assert ie["failure"] == frozen_failure
    assert ie["assumptions"]["environment-authenticity"] == "missing"
    assert ie["assumptions"]["replay-prevention-outside-model"] == "present"
    assert ie["outstanding"] == ["sourceRefinement"]
    print("PASS: independent_expected preserves frozen F41 labels and still applies outstanding correction.")


def test_independent_expected_codec_correction_not_from_actual():
    raw = json.dumps({"source_map": {"b": "2", "a": "1"}}, separators=(",", ":"))
    assert list(json.loads(raw)["source_map"].keys()) == ["b", "a"]
    fix = {
        "id": "F13x",
        "kind": "codec",
        "inputs": {"raw_utf8": raw},
        "expected": {"result": {"status": "ok", "failure": None, "ir": "{}"}},
    }
    ie = runner.independent_expected(fix)
    assert ie["result"]["status"] == "malformed"
    assert ie["result"]["failure"]["ctor"] == "noncanonicalWhitespace"
    print("PASS: codec independent_expected stays input-literal, not checker output.")


def test_f41_companion_expected_from_six_class_contract_not_actual():
    f41 = load_f41()
    reviewed = load_reviewed_companions()
    garbage_actual = {
        "status": "accepted",
        "failure": None,
        "assumptions": {k: "present" for k in runner.SIX_ASSUMPTION_CLASSES},
        "judgments": [{"family": "assumptionsDeclared", "outcome": "true", "claimed": False, "match": False}],
        "world": {"forged": True},
    }
    replay = next(c for c in reviewed["companions"] if c["id"] == "F41-replay-missing-corrected")
    env_missing = next(c for c in reviewed["companions"] if c["id"] == "F41-S55-environment-missing")

    replay_expected = runner.companion_expected_for(f41, replay, actual=garbage_actual)
    env_expected = runner.companion_expected_for(f41, env_missing, actual=garbage_actual)

    assert replay_expected != garbage_actual
    assert env_expected != garbage_actual
    assert replay_expected.get("world") != {"forged": True}
    assert replay_expected["world"] == f41["expected"]["world"]
    assert replay_expected["receipt"] == f41["expected"]["receipt"]
    assert replay_expected["assumptions"] == replay["expected_assumption_labels"]
    assert replay_expected["failure"] == replay["expected_failure"]
    assert replay_expected["status"] == "incomplete"
    decl = next(j for j in replay_expected["judgments"] if j["family"] == "assumptionsDeclared")
    assert decl == replay["expected_assumptionsDeclared"]
    assert replay_expected["outstanding"] == ["sourceRefinement"]

    assert env_expected["assumptions"] == env_missing["expected_assumption_labels"]
    assert env_expected["failure"] == env_missing["expected_failure"]
    env_decl = next(j for j in env_expected["judgments"] if j["family"] == "assumptionsDeclared")
    assert env_decl == env_missing["expected_assumptionsDeclared"]
    assert env_expected["world"] == f41["expected"]["world"]

    frozen_ie = runner.independent_expected(f41)
    assert replay_expected["assumptions"] != frozen_ie["assumptions"]
    assert replay_expected["failure"] != frozen_ie["failure"]
    print("PASS: F41 companion expected is six-class contract + frozen kernel fields, not actual output.")


def test_f41_frozen_bytes_and_reviewed_companions_remain_bound():
    assert sha256_file(FROZEN_FIXTURES) == FROZEN_FIXTURES_SHA256
    assert sha256_file(REVIEWED_COMPANIONS) == REVIEWED_COMPANIONS_SHA256
    binding = runner.f41_companion_binding(REPO)
    assert binding["frozen_fixtures_sha256"] == FROZEN_FIXTURES_SHA256
    assert binding["reviewed_companions_sha256"] == REVIEWED_COMPANIONS_SHA256
    assert binding["rewrite_original_forbidden"] is True
    f41 = load_f41()
    present = f41["inputs"]["assumptions"]
    labels = runner.six_class_labels(present)
    assert labels["environment-authenticity"] == "present"
    assert labels["replay-prevention-outside-model"] == "missing"
    assert runner.first_missing_class(present) == "replay-prevention-outside-model"
    frozen_labels = f41["expected"]["assumptions"]
    assert frozen_labels != labels
    print("PASS: original frozen JSON preserved; six-class labels explain the F41 expectation change.")


def test_f41_acceptance_requires_frozen_mismatch_and_companion():
    frozen_pass = {
        "id": "F41",
        "match": True,
        "control_discriminated": True,
        "frozen_match": True,
        "companion_match": True,
        "frozen_expectation_inconsistent": True,
        "exit_code": 0,
    }
    companion_only = {
        "id": "F41",
        "match": False,
        "control_discriminated": True,
        "frozen_match": False,
        "companion_match": True,
        "frozen_expectation_inconsistent": True,
        "exit_code": 0,
    }
    no_control = dict(companion_only, control_discriminated=False)
    no_companion = dict(companion_only, companion_match=False)
    nonzero = dict(companion_only, exit_code=1)
    assert not runner.fixture_record_accepted(frozen_pass)
    assert runner.fixture_record_accepted(companion_only)
    assert not runner.fixture_record_accepted(no_control)
    assert not runner.fixture_record_accepted(no_companion)
    assert not runner.fixture_record_accepted(nonzero)
    print("PASS: F41 cannot pass on frozen match; companion plus exposed mismatch plus control plus exit 0 required.")


def test_ordinary_fixture_acceptance_requires_match_and_control():
    ok = {"id": "F01", "match": True, "control_discriminated": True, "exit_code": 0}
    assert runner.fixture_record_accepted(ok)
    assert not runner.fixture_record_accepted(dict(ok, control_discriminated=False))
    assert not runner.fixture_record_accepted(dict(ok, match=False))
    print("PASS: ordinary fixture acceptance requires match and control discrimination.")


def test_nonzero_subprocess_matching_json_cannot_be_accepted():
    rec = {"id": "F01", "match": True, "control_discriminated": True, "exit_code": 1}
    assert not runner.fixture_record_accepted(rec)
    rec_none = {"id": "F01", "match": True, "control_discriminated": True, "exit_code": None}
    assert not runner.fixture_record_accepted(rec_none)
    assert runner.child_records_incomplete([rec])
    code = runner.campaign_exit_code(
        passed_count=1, total=1, control_discriminated_count=1, audit_ok=True, accepted_count=0,
        child_incomplete=True,
    )
    assert code == 3, f"nonzero child must be outer blocked 3, got {code}"
    print("PASS: matching JSON from a nonzero/missing subprocess cannot be accepted; outer blocked 3.")


def test_companion_set_rejects_nonzero_or_missing_child_exit():
    good = {"id": "F41-replay-missing-corrected", "match": True, "control_discriminated": True, "exit_code": 0}
    injected = {"id": "F41-S55-environment-missing", "match": True, "control_discriminated": True, "exit_code": 1}
    missing = {"id": "F41-replay-missing-corrected", "match": True, "control_discriminated": True, "exit_code": None}
    assert runner.companion_set_accepted([good, dict(injected, exit_code=0)])
    assert not runner.companion_set_accepted([good, injected])
    assert not runner.companion_set_accepted([missing])
    assert not runner.companion_set_accepted([])
    f41_incomplete = {
        "id": "F41",
        "match": False,
        "control_discriminated": True,
        "exit_code": 0,
        "frozen_expectation_inconsistent": True,
        "frozen_match": False,
        "companion_match": False,
        "companions": [good, injected],
    }
    assert runner.child_records_incomplete([f41_incomplete])
    assert runner.campaign_exit_code(
        passed_count=0, total=1, control_discriminated_count=1, audit_ok=True, accepted_count=0,
        child_incomplete=True,
    ) == 3
    print("PASS: companion_match requires every child exit 0, including inherited origin; incomplete companion is outer 3.")


def test_select_fixtures_requires_exact_requested_coverage():
    inventory = [{"id": "F25", "name": "ok"}, {"id": "F01", "name": "empty"}]
    selected, err = runner.select_fixtures(inventory, ["F25", "DOES_NOT_EXIST"])
    assert err is not None, "unknown requested ID must block"
    assert selected == []
    selected, err = runner.select_fixtures(inventory, ["F25", "F25"])
    assert err is not None, "duplicate requested IDs must block"
    selected, err = runner.select_fixtures(inventory, [])
    assert err is not None, "empty requested selection must block"
    selected, err = runner.select_fixtures([], None)
    assert err is not None, "empty inventory must block"
    dup_inv = [{"id": "F25"}, {"id": "F25"}]
    selected, err = runner.select_fixtures(dup_inv, None)
    assert err is not None, "duplicate inventory IDs must block"
    selected, err = runner.select_fixtures(inventory, ["F01", "F25"])
    assert err is None
    assert [f["id"] for f in selected] == ["F01", "F25"]
    selected, err = runner.select_fixtures(inventory, None)
    assert err is None
    assert [f["id"] for f in selected] == ["F25", "F01"]
    print("PASS: exact requested-ID coverage; empty/missing/duplicate inventory blocked.")


def _invoke_runner(out_dir, extra=None, env=None, fixtures_path=None):
    cmd = [sys.executable, str(REPO / "scripts/run_certificate_fixtures.py"), "--out", str(out_dir)]
    if fixtures_path is not None:
        cmd.extend(["--fixtures", str(fixtures_path)])
    if extra:
        cmd.extend(extra)
    return subprocess.run(cmd, cwd=REPO, capture_output=True, text=True, env=env)


def test_main_unknown_and_valid_selection_blocks_before_evidence():
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / "out"
        proc = _invoke_runner(out, extra=["--fixture", "F25", "--fixture", "DOES_NOT_EXIST"])
        assert proc.returncode == 3, f"expected blocked 3, got {proc.returncode}\n{proc.stderr}\n{proc.stdout[-500:]}"
        assert not (out / "fixture-results.json").exists()
        assert "DOES_NOT_EXIST" in (proc.stderr + proc.stdout)
    print("PASS: main --fixture F25 --fixture DOES_NOT_EXIST is blocked 3 with no accepted evidence.")


def test_main_empty_inventory_and_empty_selection_blocked_3():
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        empty_fix = tmp_path / "empty-fixtures.json"
        empty_fix.write_text(json.dumps({"fixtures": []}) + "\n", encoding="utf-8")
        out_empty = tmp_path / "out-empty-inv"
        proc_inv = _invoke_runner(out_empty, fixtures_path=empty_fix)
        assert proc_inv.returncode == 3, f"empty inventory got {proc_inv.returncode}\n{proc_inv.stderr}"
        assert not (out_empty / "fixture-results.json").exists()

        out_sel = tmp_path / "out-empty-sel"
        proc_sel = _invoke_runner(out_sel, extra=["--fixture", ""])
        assert proc_sel.returncode == 3, f"empty selection got {proc_sel.returncode}\n{proc_sel.stderr}"
        assert not (out_sel / "fixture-results.json").exists()
    print("PASS: main empty inventory and empty selection are blocked 3.")


def test_main_duplicate_requested_ids_blocked_3():
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / "out-dup"
        proc = _invoke_runner(out, extra=["--fixture", "F25", "--fixture", "F25"])
        assert proc.returncode == 3, f"duplicate request got {proc.returncode}\n{proc.stderr}"
        assert not (out / "fixture-results.json").exists()
    print("PASS: main duplicate requested IDs are blocked 3.")


def test_main_nonzero_child_matching_output_not_accepted():
    fixtures = json.loads(FROZEN_FIXTURES.read_text(encoding="utf-8"))
    f01 = next(fix for fix in fixtures["fixtures"] if fix["id"] == "F01")
    payload = json.dumps(f01["expected"], separators=(",", ":"), ensure_ascii=False)
    real_lake = shutil.which("lake")
    assert real_lake, "lake must be on PATH for the explicit nonzero-child simulation"
    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        payload_path = tmp_path / "child.json"
        payload_path.write_text(payload + "\n", encoding="utf-8")
        wrap = tmp_path / "wrap"
        wrap.mkdir()
        shim = wrap / "lake"
        shim.write_text(
            "#!/usr/bin/env python3\n"
            "import os, sys\n"
            "from pathlib import Path\n"
            f"REAL = {str(Path(real_lake).resolve())!r}\n"
            f"PAYLOAD = {str(payload_path)!r}\n"
            "if '--run' in sys.argv:\n"
            "    sys.stdout.write(Path(PAYLOAD).read_text(encoding='utf-8'))\n"
            "    sys.stdout.flush()\n"
            "    raise SystemExit(1)\n"
            "os.execv(REAL, [REAL, *sys.argv[1:]])\n",
            encoding="utf-8",
        )
        shim.chmod(shim.stat().st_mode | stat.S_IEXEC)
        env = os.environ.copy()
        env["PATH"] = str(wrap) + os.pathsep + env.get("PATH", "")
        out = tmp_path / "out-nonzero"
        proc = _invoke_runner(out, extra=["--fixture", "F01"], env=env)
        assert proc.returncode == 3, (
            f"nonzero matching child must be outer blocked 3, got {proc.returncode}\n"
            f"{proc.stderr}\n{proc.stdout[-800:]}"
        )
        results_path = out / "fixture-results.json"
        assert results_path.is_file(), "keep evidence of the child exit and raw output"
        results = json.loads(results_path.read_text(encoding="utf-8"))
        rec = results["fixtures"][0]
        assert rec["id"] == "F01"
        assert rec["exit_code"] == 1
        assert rec.get("actual") == f01["expected"]
        assert rec.get("match") is True
        assert results.get("accepted") == 0
        assert not runner.fixture_record_accepted(rec)
    print("PASS: main matching JSON from simulated nonzero child is retained, accepted 0, outer blocked 3.")


def test_main_nonempty_intact_selection_control():
    with tempfile.TemporaryDirectory() as tmp:
        out = Path(tmp) / "out-intact"
        proc = _invoke_runner(out, extra=["--fixture", "F01"])
        assert proc.returncode == 0, f"intact F01 got {proc.returncode}\n{proc.stderr}\n{proc.stdout[-800:]}"
        results = json.loads((out / "fixture-results.json").read_text(encoding="utf-8"))
        assert results["total"] == 1
        assert results["accepted"] == 1
        assert results["controls_discriminated"] == 1
        rec = results["fixtures"][0]
        assert rec["id"] == "F01"
        assert rec["exit_code"] == 0
        scenarios = json.loads((out / "scenario-results.json").read_text(encoding="utf-8"))
        assert scenarios["scenarios"]["S01"]["status"] in ("open", "not_executed")
        assert scenarios["scenarios"]["S01"]["status"] != "failed"
        assert scenarios["scenarios"]["S40"]["status"] == "bounded_fixture_observation"
    print("PASS: main nonempty intact F01 selection exits 0; unexecuted scenarios are not failed.")


def main():
    tests = [
        test_zero_controls_cannot_pass,
        test_missing_controls_cannot_pass,
        test_failed_control_cannot_pass,
        test_zero_total_cannot_pass,
        test_matching_fixtures_and_controls_can_pass,
        test_scenarios_are_bounded_observations_not_verified,
        test_unrelated_fixture_ids_do_not_verify_special_scenarios,
        test_s13_s14_s80_remain_open,
        test_failed_mapped_fixture_is_failed_observation,
        test_independent_expected_preserves_frozen_f41_labels,
        test_independent_expected_codec_correction_not_from_actual,
        test_f41_companion_expected_from_six_class_contract_not_actual,
        test_f41_frozen_bytes_and_reviewed_companions_remain_bound,
        test_f41_acceptance_requires_frozen_mismatch_and_companion,
        test_ordinary_fixture_acceptance_requires_match_and_control,
        test_unexecuted_mapped_fixture_is_not_executed_not_failed,
        test_nonzero_subprocess_matching_json_cannot_be_accepted,
        test_companion_set_rejects_nonzero_or_missing_child_exit,
        test_select_fixtures_requires_exact_requested_coverage,
        test_main_unknown_and_valid_selection_blocks_before_evidence,
        test_main_empty_inventory_and_empty_selection_blocked_3,
        test_main_duplicate_requested_ids_blocked_3,
        test_main_nonzero_child_matching_output_not_accepted,
        test_main_nonempty_intact_selection_control,
    ]
    print("Running fixture-runner truthful-outcome regressions against actual runner functions...")
    for test in tests:
        test()
    print(f"\nALL {len(tests)} FIXTURE RUNNER TRUTH REGRESSIONS PASSED.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
