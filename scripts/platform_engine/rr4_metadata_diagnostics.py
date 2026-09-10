#!/usr/bin/env python3
"""RR-4 metadata diagnostics: merge rule, finite allowance, D1 seed, funding label,
negative-theorem predicate fields. Separate from compiled mutations.

Intact control stays green. Each named failure has a falsifying mode with actual exit.
The negative-predicate validator consumes compiled RuntimeAudit #eval output
(P17-POS-DEPOSIT-CREDIT and P17-NEG-MINT-NO-CREDIT). Intact and falsifying cases
call the same check_negative_predicate. Missing/malformed observations are blocked 3.
"""
from __future__ import annotations

import copy
import json
import re
import sys
from pathlib import Path

ENGINE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(ENGINE_DIR))

from common import (  # noqa: E402
    ROOT,
    EVIDENCE,
    choose_run_dir,
    record_cmd,
    refuse_nonempty_dir,
    sha256_file,
    write_json,
)

FIXTURES = ROOT / "openspec/changes/vault-platform-reuse-p17/fixtures.json"
UINT256_MAX = "115792089237316195423570985008687907853269984665640564039457584007913129639935"
RAY = "1000000000000000000000000000"
ROW_RE = re.compile(r"(P17-[A-Z0-9-]+):\s*(true|false)\s*$")
DEN_RE = re.compile(r"runtime_denominator=(\d+)")
NEG_ROW = "P17-NEG-MINT-NO-CREDIT"
POS_ROW = "P17-POS-DEPOSIT-CREDIT"


def _load() -> dict:
    return json.loads(FIXTURES.read_text())


def check_merge(data: dict) -> tuple[int, str]:
    defaults = data["construction"]["defaults"]
    overlays = data["construction"]["domain_overlay"]
    for fx in data["fixtures"]:
        if not fx.get("scored_source"):
            continue
        domain = fx.get("domain", "D0")
        constructed = dict(defaults)
        constructed.update(overlays.get(domain, {}))
        constructed.update(fx.get("pre_overrides") or {})
        stored = fx.get("pre") or {}
        for key, val in constructed.items():
            if key.startswith("chi_setup"):
                continue
            if key not in stored:
                return 1, f"{fx['id']} stored pre missing constructed key {key}"
            if str(stored[key]) != str(val) and stored[key] != val:
                return 1, f"{fx['id']} merge mismatch on {key}: stored={stored[key]!r} constructed={val!r}"
    return 0, "merge rule holds for scored fixtures"


def check_finite_allowance(data: dict) -> tuple[int, str]:
    for fx in data["fixtures"]:
        if not fx.get("scored_source"):
            continue
        if fx.get("operation") not in ("deposit", "mint"):
            continue
        if fx.get("expected", {}).get("status") != "success":
            continue
        allow = str((fx.get("pre") or {}).get("usds.allowance.S.vault", "0"))
        if allow == UINT256_MAX:
            return 1, f"{fx['id']} success entry uses UINT256_MAX allowance"
        if fx["id"] != "P17-DEP-ZERO" and allow == "0":
            pass
    return 0, "success transferFrom entries use finite allowances"


def check_d1_seed(data: dict) -> tuple[int, str]:
    for fx in data["fixtures"]:
        if fx.get("domain") != "D1":
            continue
        pre = fx.get("pre") or {}
        if pre.get("chi") == RAY:
            return 1, f"{fx['id']} D1 chi is RAY, not the storage seed"
        if pre.get("chi_setup_protocol_reachable") is True:
            return 1, f"{fx['id']} incorrectly claims D1 chi is protocol-reachable"
        if pre.get("chi_setup_is_harness_assumption") is not True:
            return 1, f"{fx['id']} D1 seed is not labelled a harness assumption"
    return 0, "D1 chi is a labelled harness storage seed without reachability claim"


def check_funding_label(data: dict) -> tuple[int, str]:
    for fx in data["fixtures"]:
        if fx.get("operation") not in ("redeem", "withdraw"):
            continue
        if not fx.get("scored_source"):
            continue
        funding = fx.get("funding")
        if funding != "independent_prestate_not_mutated_deposit":
            return 1, f"{fx['id']} funding label is {funding!r}, not independent prestate"
    return 0, "redeem/withdraw controls declare independent prestate funding"


def parse_runtime_negpred(stdout: str | None) -> dict | None:
    """Parse compiled RuntimeAudit #eval stdout into a negative-predicate observation.

    Missing, empty, zero-denominator or absent required rows yield None (blocked).
    """
    if not isinstance(stdout, str) or not stdout.strip():
        return None
    rows: dict[str, bool] = {}
    denom = None
    for raw in stdout.splitlines():
        line = raw.strip()
        den = DEN_RE.search(line)
        if den:
            denom = int(den.group(1))
        match = ROW_RE.search(line)
        if match:
            rows[match.group(1)] = match.group(2) == "true"
    if denom is None or denom == 0:
        return None
    if POS_ROW not in rows or NEG_ROW not in rows:
        return None
    return {
        "denominator": denom,
        "rows": rows,
        POS_ROW: rows[POS_ROW],
        NEG_ROW: rows[NEG_ROW],
        "consumer": "DefiKernel.Vault.RuntimeAudit #eval",
        "kind": "compiled_runtime_observation",
    }


def check_negative_predicate(obs: dict | None) -> tuple[int, str]:
    """Score a compiled runtime observation of the no-credit predicate.

    Required meaning (not a source grep): honest credit holds
    (P17-POS-DEPOSIT-CREDIT) and the no-credit perturbation fails post equality
    (P17-NEG-MINT-NO-CREDIT). That is the runtime image of
    Adapter.no_credit_is_observation: Valid/credit holds; post equality fails.
    Missing/malformed observations are blocked 3. The theorem statement is not
    consulted and is not rewritten.
    """
    if obs is None:
        return 3, "blocked: missing or unusable compiled runtime observation"
    if not isinstance(obs, dict):
        return 3, "blocked: malformed observation type"
    if obs.get("denominator") in (0, None):
        return 3, "blocked: empty runtime denominator"
    pos = obs.get(POS_ROW)
    neg = obs.get(NEG_ROW)
    if pos not in (True, False) or neg not in (True, False):
        return 3, "blocked: required runtime rows missing or non-boolean"
    if pos is True and neg is True:
        return 0, (
            "compiled runtime: P17-POS-DEPOSIT-CREDIT true "
            "(credit/Valid analogue holds) and P17-NEG-MINT-NO-CREDIT true "
            "(no-credit perturb fails post equality)"
        )
    if pos is False and neg is True:
        return 1, "P17-POS-DEPOSIT-CREDIT false: honest credit/Valid analogue does not hold"
    if pos is True and neg is False:
        return 1, "P17-NEG-MINT-NO-CREDIT false: no-credit candidate no longer violates post equality"
    return 1, "P17-POS-DEPOSIT-CREDIT false and P17-NEG-MINT-NO-CREDIT false"


def run_case(name: str, fn, expected_exit: int) -> dict:
    try:
        exit_code, reason = fn()
    except Exception as exc:
        exit_code, reason = 3, f"{type(exc).__name__}: {exc}"
    return {
        "id": name,
        "expected_exit": expected_exit,
        "actual_exit": exit_code,
        "reason": reason,
        "matched": exit_code == expected_exit,
        "kind": "metadata_diagnostic",
    }


def _run_runtime_audit(out: Path) -> tuple[str, dict]:
    lean_dir = refuse_nonempty_dir(out / "lean-runtimeaudit")
    rec = record_cmd(
        "rr4-negpred-runtimeaudit",
        ["lake", "env", "lean", "DefiKernel/Vault/RuntimeAudit.lean"],
        cwd=ROOT / "lean",
        out_dir=lean_dir,
        timeout=120.0,
    )
    stdout_path = Path((rec.get("_wrapper") or {}).get("stdout_path") or (lean_dir / "stdout.bin"))
    stdout = stdout_path.read_text(errors="replace") if stdout_path.is_file() else ""
    identities = {
        "lean_cwd": str(ROOT / "lean"),
        "argv": rec.get("argv") or ["lake", "env", "lean", "DefiKernel/Vault/RuntimeAudit.lean"],
        "receipt_classification": rec.get("classification"),
        "receipt_exit": rec.get("exit"),
        "RuntimeAudit.lean_sha256": sha256_file(ROOT / "lean/DefiKernel/Vault/RuntimeAudit.lean"),
        "Examples.lean_sha256": sha256_file(ROOT / "lean/DefiKernel/Vault/Examples.lean"),
        "Adapter.lean_sha256": sha256_file(ROOT / "lean/DefiKernel/Vault/Adapter.lean"),
        "theorem_identity": "DefiKernel.Vault.Adapter.no_credit_is_observation (unchanged; Valid holds and post equality fails)",
        "runtime_row": NEG_ROW,
        "positive_row": POS_ROW,
    }
    write_json(lean_dir / "identities.json", identities)
    (lean_dir / "stdout.txt").write_text(stdout)
    return stdout, rec


def main() -> int:
    campaign = choose_run_dir(EVIDENCE)
    out_name = "rr4-metadata-diagnostics"
    idx = 1
    while (campaign / out_name).exists():
        idx += 1
        out_name = f"rr4-metadata-diagnostics-{idx}"
    out = refuse_nonempty_dir(campaign / out_name)
    data = _load()
    results = []
    results.append(run_case("intact-merge", lambda: check_merge(data), 0))
    results.append(run_case("intact-finite-allowance", lambda: check_finite_allowance(data), 0))
    results.append(run_case("intact-d1-seed", lambda: check_d1_seed(data), 0))
    results.append(run_case("intact-funding-label", lambda: check_funding_label(data), 0))

    stdout, rec = _run_runtime_audit(out)
    (out / "intact-runtimeaudit.stdout.txt").write_text(stdout)
    write_json(out / "intact-runtimeaudit.receipt.json", {
        k: rec.get(k) for k in ("name", "argv", "cwd", "start_utc", "end_utc", "exit", "classification")
        if k in rec or True
    } | {
        "name": rec.get("name"),
        "argv": rec.get("argv"),
        "cwd": rec.get("cwd"),
        "start_utc": rec.get("start_utc"),
        "end_utc": rec.get("end_utc"),
        "exit": rec.get("exit"),
        "classification": rec.get("classification"),
        "wrapper_exit": (rec.get("_wrapper") or {}).get("wrapper_exit"),
    })
    if rec.get("classification") != "ok" or rec.get("exit") != 0:
        intact_obs = None
    else:
        intact_obs = parse_runtime_negpred(stdout)
    write_json(out / "intact-observation.json", intact_obs if intact_obs is not None else {"status": "missing_or_malformed"})
    results.append(run_case("intact-negative-predicate", lambda: check_negative_predicate(intact_obs), 0))

    broken_merge = copy.deepcopy(data)
    for fx in broken_merge["fixtures"]:
        if fx.get("id") == "P17-DEP-D0":
            fx["pre"]["chi"] = "1"
            break
    results.append(run_case("fail-merge-rule", lambda: check_merge(broken_merge), 1))

    broken_allow = copy.deepcopy(data)
    for fx in broken_allow["fixtures"]:
        if fx.get("id") == "P17-DEP-D0":
            fx["pre"]["usds.allowance.S.vault"] = UINT256_MAX
            break
    results.append(run_case("fail-finite-allowance", lambda: check_finite_allowance(broken_allow), 1))

    broken_d1 = copy.deepcopy(data)
    for fx in broken_d1["fixtures"]:
        if fx.get("domain") == "D1":
            fx["pre"]["chi_setup_protocol_reachable"] = True
            break
    results.append(run_case("fail-d1-seed-classification", lambda: check_d1_seed(broken_d1), 1))

    broken_fund = copy.deepcopy(data)
    for fx in broken_fund["fixtures"]:
        if fx.get("id") == "P17-RED-D0":
            fx["funding"] = "produced_by_deposit"
            break
    results.append(run_case("fail-control-funding-label", lambda: check_funding_label(broken_fund), 1))

    def fail_negative():
        """Named falsifier: invert the compiled no-credit row, then call the same validator."""
        false_stdout = stdout.replace(f"{NEG_ROW}: true", f"{NEG_ROW}: false", 1)
        (out / "fail-negative-theorem-predicate.stdout.txt").write_text(false_stdout)
        false_obs = parse_runtime_negpred(false_stdout)
        write_json(out / "fail-negative-observation.json", false_obs if false_obs is not None else {"status": "missing_or_malformed"})
        return check_negative_predicate(false_obs)

    results.append(run_case("fail-negative-theorem-predicate", fail_negative, 1))

    results.append(run_case(
        "blocked-missing-negative-observation",
        lambda: check_negative_predicate(None),
        3,
    ))
    results.append(run_case(
        "blocked-malformed-negative-observation",
        lambda: check_negative_predicate(parse_runtime_negpred("not a RuntimeAudit observation")),
        3,
    ))

    matched = sum(1 for r in results if r["matched"])
    report = {
        "kind": "metadata_diagnostic_not_compiled_mutation",
        "negative_predicate_consumer": "DefiKernel.Vault.RuntimeAudit #eval rows P17-POS-DEPOSIT-CREDIT and P17-NEG-MINT-NO-CREDIT",
        "theorem_unchanged": "DefiKernel.Vault.Adapter.no_credit_is_observation",
        "predicate_meaning": "Valid/credit holds; no-credit candidate violates post equality",
        "same_validator": "check_negative_predicate",
        "checks": len(results),
        "matched": matched,
        "results": results,
        "exit": 0 if matched == len(results) else 1,
    }
    write_json(out / "result.json", report)
    print(json.dumps({
        "checks": report["checks"],
        "matched": report["matched"],
        "exit": report["exit"],
        "failed": [r["id"] for r in results if not r["matched"]],
        "consumer_exits": {r["id"]: r["actual_exit"] for r in results},
    }))
    return int(report["exit"])


if __name__ == "__main__":
    raise SystemExit(main())
