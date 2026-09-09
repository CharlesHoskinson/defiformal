#!/usr/bin/env python3
"""P17 r2 planning diagnostics. Not source execution, not mutation credit.

Exit 0 intact; 1 genuine wrong literal/property; 3 empty or unavailable.
"""
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
UINT256 = 2**256
UINT256_MAX = UINT256 - 1


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


def lift_def(text: str, header: str) -> str | None:
    matches = list(re.finditer(rf"^{re.escape(header)}\b", text, re.M))
    if len(matches) != 1:
        return None
    start = matches[0].start()
    rest = text[start:]
    nxt = re.search(r"\n(?:def |theorem |variable )", rest[1:])
    block = rest if nxt is None else rest[: nxt.start() + 1]
    if not block.strip().endswith("true") and "Prop :=" not in block and ":=" not in block:
        return None
    return block


def valid_params(block: str) -> list[str] | None:
    header = block.split(": Prop", 1)[0] if ": Prop" in block else block
    names = re.findall(r"\(([A-Za-z][A-Za-z0-9_]*)\s*:", header)
    return names


def merge_pre(construction: dict, domain: str, overrides: dict) -> dict:
    pre = dict(construction["defaults"])
    pre.update(construction.get("domain_overlay", {}).get(domain, {}))
    pre.update(overrides or {})
    return pre


def conversion(op: str, assets: int | None, shares: int | None, chi: int) -> tuple[int, int]:
    if chi <= 0:
        raise ValueError("chi")
    if op in ("deposit",):
        assert assets is not None
        prod = assets * RAY
        if prod >= UINT256:
            raise OverflowError("Panic(0x11)")
        return assets, prod // chi
    if op == "mint":
        assert shares is not None
        prod = shares * chi
        if prod >= UINT256:
            raise OverflowError("Panic(0x11)")
        return divup(prod, RAY), shares
    if op == "withdraw":
        assert assets is not None
        prod = assets * RAY
        if prod >= UINT256:
            raise OverflowError("Panic(0x11)")
        return assets, divup(prod, chi)
    if op == "redeem":
        assert shares is not None
        prod = shares * chi
        if prod >= UINT256:
            raise OverflowError("Panic(0x11)")
        return prod // RAY, shares
    raise ValueError(op)


def simulate_source(fx: dict) -> dict:
    pre = fx["pre"]
    op = fx["operation"]
    inp = fx["inputs"]
    chi = int(pre["chi"])
    if str(pre["timestamp"]) != str(pre["rho"]):
        return {"status": "remainder", "error": "time_not_stable"}
    if chi == 0:
        return {"status": "revert", "error": "divisionByZero"}
    recv = inp.get("receiver")
    sender = inp.get("msg.sender")
    owner = inp.get("owner", sender)
    try:
        if op == "deposit":
            assets, shares = conversion(op, int(inp["assets"]), None, chi)
        elif op == "mint":
            assets, shares = conversion(op, None, int(inp["shares"]), chi)
        elif op == "withdraw":
            assets, shares = conversion(op, int(inp["assets"]), None, chi)
        elif op == "redeem":
            assets, shares = conversion(op, None, int(inp["shares"]), chi)
        else:
            return {"status": "remainder", "error": f"unsimulated:{op}"}
    except OverflowError:
        return {"status": "revert", "error": "Panic(0x11)"}

    if op in ("deposit", "mint"):
        if recv in ("ZERO", "vault"):
            return {"status": "revert", "error": "SUsds/invalid-address", "assets": assets, "shares": shares}
        bal = int(pre[f"usds.balance.{sender}"])
        if bal < assets:
            return {"status": "revert", "error": "Usds/insufficient-balance", "assets": assets, "shares": shares}
        allow = int(pre["usds.allowance.S.vault"] if sender == "S" else pre["usds.allowance.O.vault"])
        if allow != UINT256_MAX and allow < assets:
            return {"status": "revert", "error": "Usds/insufficient-allowance", "assets": assets, "shares": shares}
        return {"status": "success", "assets": assets, "shares": shares}

    # burn path
    own_bal = int(pre[f"susds.balance.{owner}"])
    if own_bal < shares:
        return {"status": "revert", "error": "SUsds/insufficient-balance", "assets": assets, "shares": shares}
    if owner != sender:
        allow = int(pre["susds.allowance.O.P"])
        if allow != UINT256_MAX and allow < shares:
            return {"status": "revert", "error": "SUsds/insufficient-allowance", "assets": assets, "shares": shares}
    vault_usds = int(pre["usds.balance.vault"])
    if vault_usds < assets:
        return {"status": "revert", "error": "Usds/insufficient-balance", "assets": assets, "shares": shares}
    return {"status": "success", "assets": assets, "shares": shares}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--empty-corpus", action="store_true")
    parser.add_argument("--wrong-literal", action="store_true")
    parser.add_argument("--unavailable", action="store_true")
    parser.add_argument("--out", type=Path, default=None)
    args = parser.parse_args()
    if sum(bool(x) for x in (args.empty_corpus, args.wrong_literal, args.unavailable)) > 1:
        print("blocked: mutually exclusive diagnostic modes", file=sys.stderr)
        return 3

    root = repo_root()
    change = root / "openspec/changes/vault-platform-reuse-p17"
    capture = root / "review/semantic-kernel/program-execution-20260908/p17-source-acquisition"
    transition = root / "lean/DefiKernel/Typed/Transition.lean"
    if args.unavailable:
        transition = root / "lean/DefiKernel/Typed/Transition.lean.missing"

    failures: list[str] = []
    checks: list[dict] = []

    def check(name: str, ok: bool, detail: object) -> None:
        checks.append({"name": name, "ok": bool(ok), "detail": detail})
        if not ok:
            failures.append(name)

    source_pin = load_json(change / "source-pin.json")
    fixtures_doc = load_json(change / "fixtures.json")
    mutations_doc = load_json(change / "planned-mutations.json")
    remaining = load_json(change / "remaining-gates.json")
    reuse = load_json(change / "reuse-design.json")
    compiler = load_json(change / "compiler-harness-plan.json")
    scenario_map = load_json(change / "scenario-map.json")
    proofs = load_json(change / "proof-obligations.json")
    obs = load_json(change / "observation-contract.json")

    if args.empty_corpus:
        fixtures_doc = {
            "fixtures": [],
            "partitions": [],
            "construction": fixtures_doc.get("construction"),
            "max_or_assets": None,
        }
        mutations_doc = {"vault_production_mutants": []}

    if args.wrong_literal:
        for fx in fixtures_doc.get("fixtures") or []:
            if fx.get("id") == "P17-DEP-D1":
                fx.setdefault("expected", {})["ok_shares"] = str(WAD)

    fixtures = list(fixtures_doc.get("fixtures") or [])
    mutants = list(mutations_doc.get("vault_production_mutants") or [])
    partitions = list(fixtures_doc.get("partitions") or [])
    construction = fixtures_doc.get("construction") or {}
    by_id = {f.get("id"): f for f in fixtures if isinstance(f, dict)}

    check("nonempty_fixtures", len(fixtures) > 0, {"count": len(fixtures)})
    check("nonempty_partitions", len(partitions) > 0, {"count": len(partitions)})
    check("nonempty_mutants", len(mutants) > 0, {"count": len(mutants)})
    ids = [f.get("id") for f in fixtures]
    check(
        "unique_fixture_ids",
        len(ids) == len(set(ids)) and all(isinstance(i, str) and i for i in ids),
        ids,
    )
    blob = json.dumps(fixtures_doc)
    check("no_max_or_assets", "max_or_assets" not in blob or fixtures_doc.get("max_or_assets") is None, fixtures_doc.get("max_or_assets"))
    check("no_max_or_assets_string", "max_or_assets" not in json.dumps(fixtures), json.dumps(fixtures).count("max_or_assets"))

    if not args.empty_corpus:
        expected_d1_deposit = str(WAD * RAY // CHI_D1)
        expected_d1_mint = str(divup(WAD * CHI_D1, RAY))
        check(
            "independent_P17-DEP-D0",
            by_id.get("P17-DEP-D0", {}).get("expected", {}).get("ok_shares") == str(WAD),
            by_id.get("P17-DEP-D0", {}).get("expected"),
        )
        check(
            "independent_P17-DEP-D1",
            by_id.get("P17-DEP-D1", {}).get("expected", {}).get("ok_shares") == expected_d1_deposit,
            {"expected": expected_d1_deposit, "got": by_id.get("P17-DEP-D1", {}).get("expected", {}).get("ok_shares")},
        )
        check(
            "independent_P17-MINT-D1",
            by_id.get("P17-MINT-D1", {}).get("expected", {}).get("ok_assets") == expected_d1_mint,
            {"expected": expected_d1_mint, "got": by_id.get("P17-MINT-D1", {}).get("expected")},
        )
        mint_d1 = by_id.get("P17-MINT-D1", {})
        check(
            "d1_mint_usds_funded",
            mint_d1.get("pre", {}).get("usds.balance.S") == expected_d1_mint
            and mint_d1.get("pre", {}).get("usds.allowance.S.vault") == expected_d1_mint,
            mint_d1.get("pre"),
        )
        ovf = UINT256 // RAY + 1
        check(
            "independent_P17-DEP-MUL-OVF",
            by_id.get("P17-DEP-MUL-OVF", {}).get("inputs", {}).get("assets") == str(ovf),
            {"expected": str(ovf)},
        )
        check("negative_present", "P17-NEG-MINT-NO-CREDIT" in by_id, list(by_id))
        check("positive_present", "P17-POS-DEPOSIT-CREDIT" in by_id, list(by_id))

        scored = [f for f in fixtures if f.get("scored_source") is True]
        check("scored_source_nonempty", len(scored) >= 16, len(scored))
        for fx in scored:
            fid = fx["id"]
            merged = merge_pre(construction, fx.get("domain"), fx.get("pre_overrides") or {})
            check(f"pre_merge_{fid}", fx.get("pre") == merged, {"merged": merged, "stored": fx.get("pre")})
            required = set(construction.get("defaults", {}))
            check(f"pre_complete_{fid}", required <= set(fx.get("pre") or {}), sorted(required - set(fx.get("pre") or {})))
            sim = simulate_source(fx)
            exp = fx.get("expected") or {}
            want_status = exp.get("status")
            check(f"partition_sim_{fid}", sim.get("status") == want_status, {"sim": sim, "want": want_status})
            if want_status == "success":
                if "ok_shares" in exp:
                    check(f"sim_shares_{fid}", str(sim.get("shares")) == str(exp["ok_shares"]), sim)
                if "ok_assets" in exp:
                    check(f"sim_assets_{fid}", str(sim.get("assets")) == str(exp["ok_assets"]), sim)
                check(f"success_has_post_{fid}", isinstance(exp.get("post"), dict) and exp.get("post"), None)
                logs = exp.get("full_logs") or []
                check(f"success_has_full_logs_{fid}", isinstance(logs, list) and len(logs) >= 4, logs)
                if fx["operation"] in ("deposit", "mint"):
                    usds_tx = [e for e in logs if e.get("emitter") == "usds" and e.get("name") == "Transfer"]
                    check(f"usds_transfer_in_full_logs_{fid}", len(usds_tx) == 1, usds_tx)
                    vault_proj = [e for e in logs if e.get("emitter") == "vault"]
                    check(
                        f"vault_projection_{fid}",
                        all(e.get("emitter") == "vault" for e in vault_proj) and len(vault_proj) == 3,
                        vault_proj,
                    )
                    if fid != "P17-DEP-ZERO":
                        check(
                            f"finite_allowance_consumed_{fid}",
                            exp.get("post", {}).get("usds.allowance.S.vault") == "0"
                            and int(fx["pre"]["usds.allowance.S.vault"]) > 0
                            and int(fx["pre"]["usds.allowance.S.vault"]) != UINT256_MAX,
                            fx["pre"].get("usds.allowance.S.vault"),
                        )
            if want_status == "revert":
                check(f"sim_error_{fid}", sim.get("error") == exp.get("error"), {"sim": sim, "want": exp.get("error")})
                check(f"refusal_omits_post_{fid}", exp.get("post") == "omitted", exp.get("post"))
                check(f"pre_retained_{fid}", exp.get("pre_retained") is True, exp.get("pre_retained"))
                check(f"not_rollback_claim_{fid}", exp.get("rollback_verification") is False, exp.get("rollback_verification"))

        for cid in ("P17-RED-D0", "P17-RED-D1", "P17-RED-ALLOW", "P17-WD-D0", "P17-WD-D1"):
            fx = by_id.get(cid, {})
            check(
                f"independent_funding_{cid}",
                fx.get("funding") == "independent_prestate_not_mutated_deposit",
                fx.get("funding"),
            )
        check(
            "d1_chi_seed",
            by_id.get("P17-DEP-D1", {}).get("pre", {}).get("chi_setup") == "storage_seed_chi_after_initialize"
            and by_id.get("P17-DEP-D1", {}).get("pre", {}).get("chi_setup_protocol_reachable") is False,
            by_id.get("P17-DEP-D1", {}).get("pre"),
        )

        d0 = by_id.get("P17-DEP-D0", {})
        logs = (d0.get("expected") or {}).get("full_logs") or []
        check(
            "dep_d0_second_is_usds_transfer",
            len(logs) >= 2 and logs[1].get("emitter") == "usds" and logs[1].get("name") == "Transfer",
            logs,
        )

    fixture_ids = set(by_id)
    for mutant in mutants:
        mid = mutant.get("id")
        designated = mutant.get("designated_false")
        unaffected = mutant.get("unaffected_positive")
        change_text = str(mutant.get("actual_source_change"))
        check(
            f"mutant_{mid}_designated_in_fixtures",
            isinstance(designated, str) and designated in fixture_ids,
            {"designated": designated},
        )
        check(
            f"mutant_{mid}_unaffected_in_fixtures",
            isinstance(unaffected, str) and unaffected in fixture_ids and unaffected != designated,
            {"unaffected": unaffected},
        )
        check(
            f"mutant_{mid}_one_solidity_edit",
            mutant.get("language") == "Solidity" and ("Delete" in change_text or "Replace" in change_text),
            mutant.get("actual_source_change"),
        )
        check(
            f"mutant_{mid}_independent_controls",
            mutant.get("controls_independently_funded") is True
            and mutant.get("control_funding_must_not_use_mutated_deposit") is True,
            mutant,
        )
        for cid in (
            mutant.get("unaffected_positive"),
            mutant.get("additional_unaffected"),
            mutant.get("additional_unaffected_authorization"),
        ):
            ufx = by_id.get(cid) or {}
            if ufx.get("operation") in ("redeem", "withdraw"):
                check(
                    f"mutant_{mid}_{cid}_redeem_independent",
                    ufx.get("funding") == "independent_prestate_not_mutated_deposit",
                    ufx.get("funding"),
                )

    check("gate_accepted_false", remaining.get("gate_accepted") is False, remaining.get("gate_accepted"))
    check("platform_reuse_false", remaining.get("p17_platform_reuse") is False, remaining.get("p17_platform_reuse"))
    check("independent_not_run", remaining.get("independent_gpt6") == "required_not_run", remaining.get("independent_gpt6"))
    check("p16_gate_not_assumed", remaining.get("p16_source_gate_assumed_closed") is False, None)
    check("composition_unclaimed", reuse.get("composition_integration_claimed") is False, None)
    check("wrapper_rejected", reuse.get("common_harness_engine", {}).get("wrapper_around_separate_engines") is False, None)
    check("arithmetic_cannot_open_gate", reuse.get("arithmetic_only_opens_platform_gate") is False, None)
    check("p30_not_prerequisite", reuse.get("p30_dependency") is False, None)
    check("quote_model_only", reuse.get("token0_library_to_kernel_bridge", {}).get("model_only") is True, None)
    check("quote_not_pool", reuse.get("token0_library_to_kernel_bridge", {}).get("pool_storage") is False, None)
    check("quote_not_cash", reuse.get("token0_library_to_kernel_bridge", {}).get("cash_settlement") is False, None)
    check("quote_scale_1", reuse.get("token0_library_to_kernel_bridge", {}).get("scale") == "1", None)
    check(
        "quote_pre_register",
        "sqrtPX96" in str(reuse.get("token0_library_to_kernel_bridge", {}).get("pre_register_binding")),
        reuse.get("token0_library_to_kernel_bridge", {}).get("pre_register_binding"),
    )
    check("library_derived", reuse.get("token0_library_to_kernel_bridge", {}).get("library_derived_template") is True, None)
    check("engine_still_required", reuse.get("common_harness_engine", {}).get("still_required_for_platform_reuse") is True, None)
    check("smoke_not_campaign", compiler.get("administrative_smoke", {}).get("is_campaign_bytecode") is False, None)
    check("solc_not_run", fixtures_doc.get("solc_executed") is False or args.empty_corpus, None)
    check(
        "planning_not_mutation_credit",
        mutations_doc.get("planning_validation_is_not_production_mutation_credit") is True or args.empty_corpus,
        None,
    )
    check("obs_usds_allowance", obs.get("vault_stateful", {}).get("usds_allowance_observed") is True, None)
    check("obs_usds_transfer", obs.get("vault_stateful", {}).get("usds_transfer_in_full_logs") is True, None)
    check("obs_not_rollback", obs.get("vault_stateful", {}).get("retaining_prestate_is_rollback_verification") is False, None)
    check("obs_unrelated_retained", "retained" in str(obs.get("vault_stateful", {}).get("unrelated_logs")), None)

    neg = next((o for o in proofs.get("obligations", []) if o.get("id") == "P17-TH-NEGATIVE"), {})
    check("neg_predicate_observation", neg.get("predicate") == "observation_correspondence", neg.get("predicate"))
    check("neg_not_valid_predicate", neg.get("not_predicate") == "Evaluated.Valid", neg.get("not_predicate"))
    check("neg_not_executor_refusal", neg.get("executor_refusal") is False, neg.get("executor_refusal"))
    check("neg_assets_positive", neg.get("assets_positive") is True, neg.get("assets_positive"))
    check("neg_same_premises", neg.get("same_premises") is True and neg.get("positive_witness") == "P17-POS-DEPOSIT-CREDIT", neg)
    check("neg_desired_not_assumed", neg.get("desired_postcondition_assumed") is False, None)
    check(
        "neg_derived_post_field",
        neg.get("derived_post") == "post.USDS.vault = pre.USDS.vault + assets",
        neg.get("derived_post"),
    )
    check(
        "neg_rejected_candidate_field",
        neg.get("rejected_candidate") == "candidate.USDS.vault = pre.USDS.vault",
        neg.get("rejected_candidate"),
    )
    stmt = str(neg.get("statement") or "")
    check("neg_statement_not_valid_post", "not e.Valid" not in stmt and "not Valid for the deposit" not in stmt, stmt)
    pos = by_id.get("P17-POS-DEPOSIT-CREDIT", {})
    nfx = by_id.get("P17-NEG-MINT-NO-CREDIT", {})
    check("pos_same_effects", pos.get("effects") == nfx.get("effects") and pos.get("assets_positive") is True, None)
    check("pos_execute_ok_iff", pos.get("derived_from") == "DefiKernel.Typed.execute_ok_iff", pos.get("derived_from"))
    check("neg_kind_model", nfx.get("kind") == "model_observation" and nfx.get("scored_source") is False, nfx.get("kind"))

    if not transition.is_file():
        check("evaluated_valid_lift", False, {"path": str(transition), "reason": "missing"})
        result = _result(args, root, checks, failures, fixtures, mutants, 0, 0, 0)
        _write(args, result)
        return 3

    text = transition.read_text()
    valid_block = lift_def(text, "def Evaluated.Valid")
    check("evaluated_valid_lift", valid_block is not None and len(valid_block) > 80, None if valid_block is None else len(valid_block))
    if valid_block:
        params = valid_params(valid_block)
        check(
            "evaluated_valid_params",
            params == ["store", "ctx", "request", "state", "e"],
            params,
        )
        check("evaluated_valid_no_post_param", params is not None and "post" not in params, params)
        header = valid_block.split(": Prop", 1)[0]
        check("evaluated_valid_header_no_post", re.search(r"\bpost\b", header) is None, header)
    okiff = lift_def(text, "theorem execute_ok_iff")
    check("execute_ok_iff_lift", okiff is not None, None if okiff is None else len(okiff))
    if okiff:
        rhs = okiff.split(":=", 1)[0]
        check(
            "execute_ok_iff_post_eq",
            "post.state.balance c = state.balance c + e.effect c" in rhs.replace("\n", " "),
            rhs[-400:],
        )
        check(
            "execute_ok_iff_valid_prestate",
            "e.Valid store ctx request state" in rhs.replace("\n", " "),
            None,
        )

    if not args.empty_corpus and not args.unavailable:
        main_rel = capture / "capture/src/SUsds.sol"
        l2_rel = capture / "capture/src/l2/SUsds.sol"
        if not main_rel.is_file() or not l2_rel.is_file():
            check("source_files_present", False, {"main": str(main_rel), "l2": str(l2_rel)})
        else:
            main_sha = sha256_file(main_rel)
            l2_sha = sha256_file(l2_rel)
            check(
                "main_sha",
                main_sha == source_pin["pin"]["sha256"] and main_rel.stat().st_size == source_pin["pin"]["bytes"],
                {"actual": main_sha, "size": main_rel.stat().st_size},
            )
            check(
                "l2_sha",
                l2_sha == source_pin["rejected_l2"]["sha256"] and l2_rel.stat().st_size == source_pin["rejected_l2"]["bytes"],
                {"actual": l2_sha, "size": l2_rel.stat().st_size},
            )
            check("main_vs_l2", main_sha != l2_sha, {"main": main_sha, "l2": l2_sha})
            closure_ok = True
            closure_rows = []
            for entry in source_pin["compiler_source_keys"]:
                key = entry["key"]
                path = capture / "compile-source-closure" / key
                if not path.is_file() and key.startswith("src/"):
                    path = capture / "capture" / key
                if not path.is_file():
                    closure_ok = False
                    closure_rows.append({"key": key, "missing": str(path)})
                    continue
                actual = sha256_file(path)
                size = path.stat().st_size
                match = actual == entry["sha256"] and size == entry["bytes"]
                closure_ok = closure_ok and match
                closure_rows.append({"key": key, "match": match})
            check(
                "closure_hashes",
                closure_ok and len(source_pin["compiler_source_keys"]) == 10,
                {"count": len(source_pin["compiler_source_keys"]), "ok": closure_ok},
            )

    reqs, scenarios, names = spec_counts(change)
    check("requirements_nonempty", reqs > 0, reqs)
    check("scenarios_nonempty", scenarios > 0, scenarios)
    check("scenario_names_unique", len(names) == len(set(names)), names)
    mapped = [row["scenario"] for row in scenario_map.get("scenarios", [])]
    check("scenario_map_covers_specs", set(names) == set(mapped), {"spec": names, "map": mapped})
    tasks_text = (change / "tasks.md").read_text()
    checked_n = len(re.findall(r"^- \[x\]", tasks_text, re.M))
    unchecked = len(re.findall(r"^- \[ \]", tasks_text, re.M))
    check("tasks_unchecked", checked_n == 0 and unchecked > 0, {"checked": checked_n, "unchecked": unchecked})

    result = _result(args, root, checks, failures, fixtures, mutants, reqs, scenarios, unchecked)
    _write(args, result)
    if args.empty_corpus or args.unavailable:
        return 3
    if failures:
        return 1
    if len(checks) == 0:
        return 3
    return 0


def _result(args, root, checks, failures, fixtures, mutants, reqs, scenarios, unchecked) -> dict:
    return {
        "schema": "p17-vault-planning-diagnose/v2",
        "empty_corpus": args.empty_corpus,
        "wrong_literal": args.wrong_literal,
        "unavailable": args.unavailable,
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
            "tasks_checked": 0,
        },
        "production_mutation_credit": 0,
        "solc_executed": False,
        "evm_executed": False,
        "lean_executed": False,
        "python_is_source_execution": False,
        "planning_validation_is_not_source_execution": True,
    }


def _write(args, result: dict) -> None:
    text = json.dumps(result, indent=2) + "\n"
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(text)
    else:
        sys.stdout.write(text)


if __name__ == "__main__":
    sys.exit(main())
