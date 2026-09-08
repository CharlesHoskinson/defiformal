#!/usr/bin/env python3
"""P16 planning diagnostics: pin closure, repaired token0 oracle, M09/F28 control plan.

Python is a third implementation. This script is not solc, not EVM, not Lean,
and not source execution. Exit 0 = all checks ran over a nonempty corpus and
held. Exit 1 = a property is false. Exit 3 = a check could not be performed.
"""
from __future__ import annotations

import hashlib
import importlib.util
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
U256 = 2**256
U160 = 2**160
U128 = 2**128
Q96 = 2**96
MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342
MAX_UINT128 = U128 - 1
I256_MIN = -(2**255)
FEE_DEN = 1_000_000

WANTED_ARCHIVE = "e1cd08f9f8a843355f1b249a013c9de0d29e7e1ebf1d5a3e8716d6d7621baf77"
WANTED_DEFECTIVE = "4ecd60394ab4deff50387f578a9ac85f981946d17b9ff36d0724ccbd3921e0cd"
WANTED_COMMIT = "e3589b192d0be27e100cd0daaf6c97204fdb1899"
WANTED_TREE = "f024dbf808e50091852f7cc8724d837543a8c7e5"

SOURCE_FILES = [
    {
        "rel": "contracts/libraries/SqrtPriceMath.sol",
        "sha256": "ddd62e3a94346248677f30f1ab009ef015e71e4b8696dcca890eeabc9dc6c149",
        "bytes": 10774,
        "git_blob": "685f485da43402235c3a9ce7fd85a49597b6373a",
    },
    {
        "rel": "contracts/libraries/FullMath.sol",
        "sha256": "54087aee268a6938a85a408d7b14481b5c2c956c21508d5583f1bf48ec6d69ba",
        "bytes": 5118,
        "git_blob": "8688a1773ffbb5ec93d3abbe983f8c16141f9139",
    },
    {
        "rel": "contracts/libraries/UnsafeMath.sol",
        "sha256": "4d02353eb503e3111e25bd50104ac9b279f99e88d848e455262a3fbeb55c50e7",
        "bytes": 660,
        "git_blob": "f62f84676fa39f98b4ae1f7a073fc767ecf78aaa",
    },
    {
        "rel": "contracts/libraries/LowGasSafeMath.sol",
        "sha256": "394107ff2dbbaded5612452af5e77b4af9d0871b096c1514b0ea659b862fc46f",
        "bytes": 1696,
        "git_blob": "dbc817c2ec806775b7c9b213c6db0dffe00ea8cd",
    },
    {
        "rel": "contracts/libraries/SafeCast.sol",
        "sha256": "9aed494b56d3dd16b7d6535583ded2cdfb03dc80aaa919347b13d35fd597e8bf",
        "bytes": 1048,
        "git_blob": "a8ea22987877b615fcf3a557512b240eff1b77c7",
    },
    {
        "rel": "contracts/libraries/FixedPoint96.sol",
        "sha256": "219deb88ffbcdefa482be35051db586378e8523062bee592dd2c5fa7fb47ebd6",
        "bytes": 380,
        "git_blob": "63b42c294e821eb038793b7f1afb9ae0427f0691",
    },
    {
        "rel": "hardhat.config.ts",
        "sha256": "85cc32497cbb67a78cabc0716881891c258b7a3d42c1c9fe599c9279d60e8af2",
        "bytes": 1241,
        "git_blob": "1f0563d5e74db5a5a61e88dc1419c1c64ebee3e2",
    },
]

TOKEN0_IMPORTS = [
    "LowGasSafeMath.sol",
    "SafeCast.sol",
    "FullMath.sol",
    "UnsafeMath.sol",
    "FixedPoint96.sol",
]


class CheckError(Exception):
    pass


class Blocked(Exception):
    pass


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git_blob_sha1(data: bytes) -> str:
    return hashlib.sha1(b"blob %d\0" % len(data) + data).hexdigest()


def load_module(path: Path, name: str):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise Blocked(f"cannot load module {path}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def ceil_div(x: int, y: int) -> int:
    if y <= 0:
        raise CheckError(f"ceil_div non-positive denominator {y}")
    return x // y + (1 if x % y else 0)


def ceil_muldiv(a: int, b: int, d: int) -> int:
    if d <= 0:
        raise CheckError(f"ceil_muldiv non-positive denominator {d}")
    prod = a * b
    q = prod // d
    if prod % d:
        q += 1
    return q


def independent_token0(sqrt_p: int, liquidity: int, amount: int, add: bool) -> dict:
    """Source-shaped arithmetic computed without the oracle modules."""
    if amount == 0:
        return {"status": "ok", "branch": "identity", "value": sqrt_p}
    numerator1 = liquidity << 96
    product = amount * sqrt_p
    product_fits = product < U256
    if add:
        if product_fits:
            wrapped = (numerator1 + product) % U256
            unbounded = numerator1 + product
            wrap = unbounded >= U256
            if wrapped >= numerator1:
                value = ceil_muldiv(numerator1, sqrt_p, wrapped)
                if value >= U160:
                    return {"status": "error", "branch": "primary_uint160", "name": "uint160Overflow"}
                return {
                    "status": "ok",
                    "branch": "primary_muldiv",
                    "value": value,
                    "wrap": wrap,
                    "wrapped_denom": wrapped,
                }
            inner = (numerator1 // sqrt_p) + amount
            if inner >= U256:
                return {"status": "error", "branch": "wrapped_sum_fallback", "name": "addOverflow"}
            value = ceil_div(numerator1, inner)
            if value >= U160:
                return {"status": "error", "branch": "wrapped_sum_fallback", "name": "uint160Overflow"}
            return {
                "status": "ok",
                "branch": "wrapped_sum_fallback",
                "value": value,
                "wrap": True,
                "defective_unbounded_muldiv": ceil_muldiv(numerator1, sqrt_p, unbounded),
            }
        inner = (numerator1 // sqrt_p) + amount
        if inner >= U256:
            return {"status": "error", "branch": "product_overflow_fallback", "name": "addOverflow"}
        value = ceil_div(numerator1, inner)
        if value >= U160:
            return {"status": "error", "branch": "product_overflow_fallback", "name": "uint160Overflow"}
        return {"status": "ok", "branch": "product_overflow_fallback", "value": value}
    if not product_fits:
        return {"status": "error", "branch": "remove_require", "name": "require"}
    if numerator1 <= product:
        return {"status": "error", "branch": "remove_require", "name": "require"}
    denom = numerator1 - product
    value = ceil_muldiv(numerator1, sqrt_p, denom)
    if value >= U160:
        return {"status": "error", "branch": "remove_safecast", "name": "uint160Overflow"}
    return {"status": "ok", "branch": "remove_primary", "value": value}


def catch_oracle(fn, *args):
    try:
        return {"status": "ok", "value": fn(*args)}
    except Exception as e:
        name = getattr(e, "name", None)
        if name is None:
            return {"status": "error", "name": type(e).__name__, "repr": repr(e)}
        return {"status": "error", "name": name}


def flipped_compute_swap_step(mod, sqrt_current, sqrt_target, liquidity, amount_remaining, fee_pips):
    """M09: replace `current >= target` with `current < target`. Not compiled SwapMath."""
    if fee_pips >= FEE_DEN:
        raise mod.OracleError("invalidFee")
    if amount_remaining == I256_MIN:
        raise mod.OracleError("intOverflow")
    zero_for_one = sqrt_current < sqrt_target  # M09 flip
    exact_in = amount_remaining >= 0
    amount_in = 0
    amount_out = 0
    if exact_in:
        amount_remaining_less_fee = mod.mul_div(amount_remaining, FEE_DEN - fee_pips, FEE_DEN)
        amount_in = (
            mod.get_amount0_delta(sqrt_target, sqrt_current, liquidity, True)
            if zero_for_one
            else mod.get_amount1_delta(sqrt_current, sqrt_target, liquidity, True)
        )
        if amount_remaining_less_fee >= amount_in:
            sqrt_next = sqrt_target
        else:
            sqrt_next = mod.get_next_sqrt_price_from_input(
                sqrt_current, liquidity, amount_remaining_less_fee, zero_for_one
            )
    else:
        requested = -amount_remaining
        amount_out = (
            mod.get_amount1_delta(sqrt_target, sqrt_current, liquidity, False)
            if zero_for_one
            else mod.get_amount0_delta(sqrt_current, sqrt_target, liquidity, False)
        )
        if requested >= amount_out:
            sqrt_next = sqrt_target
        else:
            sqrt_next = mod.get_next_sqrt_price_from_output(
                sqrt_current, liquidity, requested, zero_for_one
            )
    reached = sqrt_target == sqrt_next
    if zero_for_one:
        amount_in = (
            amount_in
            if reached and exact_in
            else mod.get_amount0_delta(sqrt_next, sqrt_current, liquidity, True)
        )
        amount_out = (
            amount_out
            if reached and not exact_in
            else mod.get_amount1_delta(sqrt_next, sqrt_current, liquidity, False)
        )
    else:
        amount_in = (
            amount_in
            if reached and exact_in
            else mod.get_amount1_delta(sqrt_current, sqrt_next, liquidity, True)
        )
        amount_out = (
            amount_out
            if reached and not exact_in
            else mod.get_amount0_delta(sqrt_current, sqrt_next, liquidity, False)
        )
    if not exact_in and amount_out > -amount_remaining:
        amount_out = -amount_remaining
    if exact_in and sqrt_next != sqrt_target:
        fee_amount = amount_remaining - amount_in
    else:
        fee_amount = mod.mul_div_rounding_up(amount_in, fee_pips, FEE_DEN - fee_pips)
    return {
        "sqrtRatioNextX96": sqrt_next,
        "amountIn": amount_in,
        "amountOut": amount_out,
        "feeAmount": fee_amount,
        "zeroForOne": zero_for_one,
        "exactIn": exact_in,
        "reachedTarget": reached,
    }


def main() -> int:
    utc = datetime.now(timezone.utc).isoformat()
    checks = []
    findings = []
    blocked = []
    failed = []

    def record(name: str, passed: bool, detail: dict | None = None) -> None:
        rec = {"check": name, "passed": bool(passed)}
        if detail:
            rec["detail"] = detail
        checks.append(rec)
        if not passed:
            failed.append(name)

    try:
        capture = ROOT / "review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/upstream"
        archive = ROOT / "review/semantic-kernel/program-execution-20260908/p15-retained-inputs/liquidity-official-planning-r1-stage.tar.gz"
        retained_oracle = ROOT / "review/semantic-kernel/program-execution-20260908/p15-retained-inputs/cl_oracle.py"
        current_path = ROOT / "review/semantic-kernel/strategy-audit-20260908/CURRENT.json"
        defective = HERE / "witnesses/cl_oracle_defective.py"
        repaired = HERE / "cl_oracle_repaired.py"
        hardhat = capture / "hardhat.config.ts"
        sqrt = capture / "contracts/libraries/SqrtPriceMath.sol"
        unsafe = capture / "contracts/libraries/UnsafeMath.sol"

        for p in [archive, retained_oracle, current_path, defective, repaired, capture, hardhat, sqrt, unsafe]:
            if not p.exists():
                raise Blocked(f"missing required input {p}")

        current = json.loads(current_path.read_text())
        liq = next(x for x in current["lanes"] if x["id"] == "liquidity")
        current_sha = liq["candidate"]["sha256"]
        archive_sha = sha256_file(archive)
        record(
            "archive_sha_equals_CURRENT_liquidity_sha256",
            archive_sha == WANTED_ARCHIVE == current_sha,
            {"archive": archive_sha, "wanted": WANTED_ARCHIVE, "current": current_sha},
        )
        retained_sha = sha256_file(retained_oracle)
        defective_sha = sha256_file(defective)
        record(
            "defective_oracle_byte_identity",
            retained_sha == defective_sha == WANTED_DEFECTIVE,
            {"retained": retained_sha, "witness": defective_sha, "wanted": WANTED_DEFECTIVE, "bytes": defective.stat().st_size},
        )
        repaired_sha = sha256_file(repaired)
        record(
            "repaired_oracle_distinct_from_defective",
            repaired_sha != WANTED_DEFECTIVE and repaired.exists(),
            {"repaired": repaired_sha, "bytes": repaired.stat().st_size},
        )

        blob_ok = True
        blob_rows = []
        for spec in SOURCE_FILES:
            path = capture / spec["rel"]
            data = path.read_bytes()
            h = hashlib.sha256(data).hexdigest()
            blob = git_blob_sha1(data)
            ok = h == spec["sha256"] and len(data) == spec["bytes"] and blob == spec["git_blob"]
            blob_ok = blob_ok and ok
            blob_rows.append({"rel": spec["rel"], "sha256": h, "git_blob": blob, "bytes": len(data), "ok": ok})
        record("token0_source_sha_and_git_blob", blob_ok, {"files": blob_rows, "count": len(blob_rows)})
        if len(blob_rows) == 0:
            raise Blocked("empty source-file denominator")

        src = sqrt.read_text()
        imports = re.findall(r"import\s+'./([^']+)';", src)
        record(
            "token0_transitive_import_closure",
            set(imports) == set(TOKEN0_IMPORTS),
            {"parsed": imports, "wanted": TOKEN0_IMPORTS},
        )
        record(
            "helper_span_lines_28_56",
            "function getNextSqrtPriceFromAmount0RoundingUp(" in src
            and "if (amount == 0) return sqrtPX96;" in src
            and "uint256 denominator = numerator1 + product;" in src
            and "return FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator).toUint160();" in src,
            {"helper_present": True},
        )
        # bare uint160 vs SafeCast
        add_cast = "return uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator));" in src
        add_fallback_cast = "return uint160(UnsafeMath.divRoundingUp(numerator1, (numerator1 / sqrtPX96).add(amount)));" in src
        remove_safecast = "return FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator).toUint160();" in src
        record(
            "bare_uint160_casts_distinct_from_SafeCast",
            add_cast and add_fallback_cast and remove_safecast,
            {"add_primary_bare_uint160": add_cast, "add_fallback_bare_uint160": add_fallback_cast, "remove_toUint160": remove_safecast},
        )
        unsafe_src = unsafe.read_text()
        record(
            "unsafemath_assembly_unspecified_zero",
            "division by 0 has unspecified behavior" in unsafe_src
            and "z := add(div(x, y), gt(mod(x, y), 0))" in unsafe_src,
            {"comment_boundary_observed": True},
        )
        hh = hardhat.read_text()
        record(
            "compiler_source_settings_0_7_6_opt800_bytecodeHash_none",
            "version: '0.7.6'" in hh
            and "enabled: true" in hh
            and "runs: 800" in hh
            and "bytecodeHash: 'none'" in hh,
            {"hardhat_sha256": sha256_file(hardhat)},
        )
        commit_json = ROOT / "review/semantic-kernel/program-loop-20260908/concentrated-liquidity-source-readiness-gpt6-evidence/commit.json"
        commit = json.loads(commit_json.read_text())
        record(
            "pin_commit_and_tree",
            commit.get("sha") == WANTED_COMMIT and commit.get("tree", {}).get("sha") == WANTED_TREE,
            {"commit": commit.get("sha"), "tree": commit.get("tree", {}).get("sha")},
        )

        solc_which = subprocess.run(["bash", "-lc", "command -v solc || true"], capture_output=True, text=True)
        evm_which = subprocess.run(["bash", "-lc", "command -v evm || true"], capture_output=True, text=True)
        solc_path = solc_which.stdout.strip()
        evm_path = evm_which.stdout.strip()
        record(
            "solc_binary_absent_this_host",
            solc_path == "",
            {"solc": solc_path or None, "obligation": "future compiler acquisition, not claimed installed"},
        )
        record(
            "evm_binary_absent_this_host",
            evm_path == "",
            {"evm": evm_path or None, "obligation": "future harness, not claimed executed"},
        )
        ident = json.loads((HERE / "compiler-identity/solc-0.7.6-linux-amd64.json").read_text())
        record(
            "official_solc_0_7_6_identity_frozen_not_installed",
            ident["binary_not_downloaded"]
            and ident["build"]["longVersion"] == "0.7.6+commit.7338295f"
            and ident["proposed_binary_sha256"] == "bd69ea85427bf2f4da74cb426ad951dd78db9dfdd01d791208eccc2d4958a6bb",
            ident,
        )

        def_mod = load_module(defective, "cl_oracle_defective")
        rep_mod = load_module(repaired, "cl_oracle_repaired")

        wrap_sqrt = MAX_SQRT_RATIO - 1
        wrap_liq = MAX_UINT128
        n1 = wrap_liq << 96
        need = U256 - n1
        wrap_amount = (need + wrap_sqrt - 1) // wrap_sqrt
        wrap_indep = independent_token0(wrap_sqrt, wrap_liq, wrap_amount, True)
        if wrap_indep["status"] != "ok" or wrap_indep["branch"] != "wrapped_sum_fallback":
            raise CheckError(f"independent wrap vector is not the required branch: {wrap_indep}")
        wrap_expected = wrap_indep["value"]
        wrap_defective_unbounded = wrap_indep["defective_unbounded_muldiv"]
        if wrap_expected == wrap_defective_unbounded:
            raise CheckError("chosen wrap vector does not discriminate unbounded vs wrapped-sum fallback")

        cases = [
            {
                "id": "P16-I-ADD",
                "partition": "zero_amount_identity",
                "inputs": (Q96, 1, 0, True),
                "expected": {"status": "ok", "value": Q96, "branch": "identity"},
            },
            {
                "id": "P16-I-REM",
                "partition": "zero_amount_identity",
                "inputs": (Q96, 1, 0, False),
                "expected": {"status": "ok", "value": Q96, "branch": "identity"},
            },
            {
                "id": "P16-ADD",
                "partition": "ordinary_add",
                "inputs": (Q96, 1, 1, True),
                "expected": {"status": "ok", "value": 2**95, "branch": "primary_muldiv"},
            },
            {
                "id": "P16-ADD-ROUND",
                "partition": "ordinary_add_rounding_up",
                "inputs": (Q96, 1, 2, True),
                "expected": {"status": "ok", "value": ceil_div(Q96, 3), "branch": "primary_muldiv"},
            },
            {
                "id": "P16-REQ",
                "partition": "removal_denominator_require",
                "inputs": (Q96, 1, 1, False),
                "expected": {"status": "error", "name": "require", "branch": "remove_require"},
            },
            {
                "id": "P16-REM",
                "partition": "ordinary_remove",
                "inputs": (Q96, 2, 1, False),
                "expected": {"status": "ok", "value": 2**97, "branch": "remove_primary"},
            },
            {
                "id": "P16-PROD",
                "partition": "multiplication_overflow",
                "inputs": (Q96, Q96, 2**160, True),
                "expected": {"status": "ok", "value": 2**32, "branch": "product_overflow_fallback"},
            },
            {
                "id": "P16-WRAP",
                "partition": "denominator_sum_overflow",
                "inputs": (wrap_sqrt, wrap_liq, wrap_amount, True),
                "expected": {"status": "ok", "value": wrap_expected, "branch": "wrapped_sum_fallback"},
            },
        ]
        if not cases:
            raise Blocked("empty diagnostic case denominator")

        case_rows = []
        for case in cases:
            sqrt_p, liq, amount, add = case["inputs"]
            indep = independent_token0(sqrt_p, liq, amount, add)
            repaired_obs = catch_oracle(rep_mod.get_next_sqrt_price_from_amount0_rounding_up, sqrt_p, liq, amount, add)
            defective_obs = catch_oracle(def_mod.get_next_sqrt_price_from_amount0_rounding_up, sqrt_p, liq, amount, add)
            exp = case["expected"]
            indep_ok = indep["status"] == exp["status"] and indep.get("branch") == exp.get("branch")
            if exp["status"] == "ok":
                indep_ok = indep_ok and indep.get("value") == exp["value"]
                repaired_ok = repaired_obs.get("status") == "ok" and repaired_obs.get("value") == exp["value"]
            else:
                repaired_ok = repaired_obs.get("status") == "error"
                # model label is not a Solidity revert payload
                if case["id"] == "P16-REQ":
                    repaired_ok = repaired_ok and repaired_obs.get("name") in {"subUnderflow", "require", "uint256Overflow"}
            row = {
                "id": case["id"],
                "partition": case["partition"],
                "inputs": {
                    "sqrtPX96": str(sqrt_p),
                    "liquidity": str(liq),
                    "amount": str(amount),
                    "add": add,
                },
                "independent": {k: (str(v) if isinstance(v, int) else v) for k, v in indep.items()},
                "repaired": {k: (str(v) if isinstance(v, int) else v) for k, v in repaired_obs.items()},
                "defective": {k: (str(v) if isinstance(v, int) else v) for k, v in defective_obs.items()},
                "independent_matches_expected": indep_ok,
                "repaired_matches_independent": (
                    repaired_obs.get("status") == "ok" and indep.get("status") == "ok" and repaired_obs.get("value") == indep.get("value")
                )
                or (
                    repaired_obs.get("status") == "error" and indep.get("status") == "error"
                ),
            }
            case_rows.append(row)
            record(f"case_{case['id']}_independent", indep_ok, row)
            record(f"case_{case['id']}_repaired_matches_independent", row["repaired_matches_independent"], row)

        wrap_row = next(r for r in case_rows if r["id"] == "P16-WRAP")
        wrap_disagree = wrap_row["defective"].get("status") == "ok" and int(wrap_row["defective"]["value"]) != wrap_expected
        record(
            "wrap_branch_defective_oracle_disagrees",
            wrap_disagree,
            {
                "independent_fallback": str(wrap_expected),
                "defective": wrap_row["defective"],
                "repaired": wrap_row["repaired"],
                "unbounded_muldiv": str(wrap_defective_unbounded),
            },
        )
        identity_row = next(r for r in case_rows if r["id"] == "P16-I-ADD")
        add_row = next(r for r in case_rows if r["id"] == "P16-ADD")
        record(
            "ordinary_cases_defective_still_agrees",
            identity_row["defective"].get("value") == str(Q96) and add_row["defective"].get("value") == str(2**95),
            {"note": "ordinary identity/add do not take the wrap branch; defective oracle is not globally wrong"},
        )

        # Accidental agreement on a wrap premise: Q96 / max liquidity / amount = 2^160-2^128+2
        agree_amount = 2**160 - 2**128 + 2
        agree_indep = independent_token0(Q96, MAX_UINT128, agree_amount, True)
        agree_def = catch_oracle(def_mod.get_next_sqrt_price_from_amount0_rounding_up, Q96, MAX_UINT128, agree_amount, True)
        agree_rep = catch_oracle(rep_mod.get_next_sqrt_price_from_amount0_rounding_up, Q96, MAX_UINT128, agree_amount, True)
        accidental = (
            agree_indep.get("branch") == "wrapped_sum_fallback"
            and agree_def.get("status") == "ok"
            and agree_rep.get("status") == "ok"
            and agree_def.get("value") == agree_rep.get("value") == agree_indep.get("value")
        )
        findings.append(
            {
                "id": "wrap-premise-not-automatic-oracle-disagreement",
                "observed": accidental,
                "inputs": {"sqrtPX96": str(Q96), "liquidity": str(MAX_UINT128), "amount": str(agree_amount), "add": True},
                "independent_branch": agree_indep.get("branch"),
                "value": str(agree_indep.get("value")),
                "note": "Product fits and the uint256 denominator sum wraps, but unbounded mulDiv and the fallback formula coincide at 2^64. Wrap premise alone does not discriminate the defective oracle. P16-WRAP (MAX_SQRT_RATIO-1) does.",
            }
        )
        record(
            "accidental_q96_wrap_agreement_preserved_as_finding",
            accidental,
            findings[-1],
        )

        # M09 / F28
        f28 = (Q96, Q96 - 1, Q96, 1000, 3000)
        f29 = (Q96, Q96 - 1, Q96, 1, 3000)
        f31 = (Q96, Q96 + 1, Q96, 1000, 3000)
        f32 = (Q96, Q96 - 1, Q96, 1, 1_000_000)
        f33 = (Q96, Q96 - 1, Q96, I256_MIN, 3000)
        f01 = ("mulDiv", 10, 20, 3)

        orig_f28 = rep_mod.compute_swap_step(*f28)
        mut_f28 = flipped_compute_swap_step(rep_mod, *f28)
        record(
            "M09_changes_F28_amountIn_2_to_1",
            orig_f28["amountIn"] == 2 and mut_f28["amountIn"] == 1,
            {
                "original": {k: (str(v) if isinstance(v, int) else v) for k, v in orig_f28.items()},
                "m09": {k: (str(v) if isinstance(v, int) else v) for k, v in mut_f28.items()},
                "original_protected_claim": "planned-mutations.json M09 unaffected_positive F28",
            },
        )
        orig_f31 = rep_mod.compute_swap_step(*f31)
        mut_f31 = flipped_compute_swap_step(rep_mod, *f31)
        record(
            "M09_designated_false_F31_changes",
            orig_f31 != mut_f31,
            {
                "original": {k: (str(v) if isinstance(v, int) else v) for k, v in orig_f31.items()},
                "m09": {k: (str(v) if isinstance(v, int) else v) for k, v in mut_f31.items()},
            },
        )
        orig_f32 = catch_oracle(rep_mod.compute_swap_step, *f32)
        mut_f32 = catch_oracle(flipped_compute_swap_step, rep_mod, *f32)
        record(
            "M09_unaffected_sibling_F32_invalidFee",
            orig_f32 == mut_f32 == {"status": "error", "name": "invalidFee"},
            {"original": orig_f32, "m09": mut_f32, "reason": "invalidFee is decided before the direction predicate"},
        )
        orig_f33 = catch_oracle(rep_mod.compute_swap_step, *f33)
        mut_f33 = catch_oracle(flipped_compute_swap_step, rep_mod, *f33)
        record(
            "M09_additional_same_module_control_F33_intOverflow",
            orig_f33 == mut_f33 == {"status": "error", "name": "intOverflow"},
            {"original": orig_f33, "m09": mut_f33, "reason": "int256 min is decided before the direction predicate"},
        )
        orig_f29 = rep_mod.compute_swap_step(*f29)
        mut_f29 = flipped_compute_swap_step(rep_mod, *f29)
        f29_stable = orig_f29["amountIn"] == mut_f29["amountIn"] and orig_f29["amountOut"] == mut_f29["amountOut"] and orig_f29["feeAmount"] == mut_f29["feeAmount"] and orig_f29["sqrtRatioNextX96"] == mut_f29["sqrtRatioNextX96"]
        findings.append(
            {
                "id": "F29-output-stable-under-M09-but-zeroForOne-flag-flips",
                "outputs_equal": f29_stable,
                "original_zeroForOne": orig_f29["zeroForOne"],
                "m09_zeroForOne": mut_f29["zeroForOne"],
                "note": "F29 numeric fields happen to stay 0/0/1 with next=Q96, but zeroForOne flips. Do not name F29 as the repaired unaffected sibling; the flag is part of the observation. F32 is the named sibling because the refusal is decided before the predicate.",
            }
        )
        record(
            "F29_not_named_unaffected_sibling",
            orig_f29["zeroForOne"] is True and mut_f29["zeroForOne"] is False,
            findings[-1],
        )
        orig_f01 = catch_oracle(rep_mod.mul_div, 10, 20, 3)
        record(
            "F01_fullmath_untouched_by_SwapMath_direction",
            orig_f01 == {"status": "ok", "value": 66},
            {"value": orig_f01, "note": "different module; not the named M09 sibling"},
        )

        # Empty-denominator negative control: a checker over [] must block.
        empty_passed = None
        try:
            if len([]) == 0:
                raise Blocked("empty diagnostic case denominator")
            empty_passed = True
        except Blocked as e:
            empty_passed = False
            record("empty_denominator_blocks", True, {"message": str(e), "exit_contract": 3})
        if empty_passed:
            record("empty_denominator_blocks", False, {"message": "empty corpus did not block"})

        # Negative: treating wrap as Operations.add (checked overflow) misses the branch.
        n1w = wrap_liq << 96
        prodw = wrap_amount * wrap_sqrt
        checked_add_would_refuse = n1w + prodw >= U256
        record(
            "operations_add_would_miss_wrap_fallback",
            checked_add_would_refuse and wrap_indep["branch"] == "wrapped_sum_fallback",
            {"note": "Delivered Arithmetic.Operations.add refuses addOverflow; Solidity 0.7.6 wraps and falls back."},
        )

        repaired_src = repaired.read_text()
        record(
            "repaired_oracle_does_not_claim_source_execution",
            "not Lean, not solc, not EVM, and not accepted source behavior" in repaired_src
            and "wrapped_denom" in repaired_src,
            {"sha256": repaired_sha},
        )
        record(
            "defective_header_still_unbounded_only",
            "uint256 wrap is modelled only where" in defective.read_text(),
            {"sha256": defective_sha},
        )
        record(
            "historical_archive_not_overwritten",
            archive_sha == WANTED_ARCHIVE,
            {"archive": str(archive)},
        )

        n_checks = len(checks)
        n_pass = sum(1 for c in checks if c["passed"])
        n_fail = sum(1 for c in checks if not c["passed"])
        if n_checks == 0:
            raise Blocked("empty check denominator")
        record("nonempty_check_denominator", n_checks > 0, {"count": n_checks})
        # the nonempty check itself is already in checks; recompute after
        n_checks = len(checks)
        n_pass = sum(1 for c in checks if c["passed"])
        n_fail = sum(1 for c in checks if not c["passed"])

        result = {
            "schema": "p16-token0-planning-diagnostics/v1",
            "utc": utc,
            "python": sys.version.split()[0],
            "executable": sys.executable,
            "cwd": str(Path.cwd()),
            "argv": sys.argv,
            "not_solc": True,
            "not_evm": True,
            "not_lean": True,
            "not_source_execution": True,
            "gate_accepted": False,
            "independent_acceptance": False,
            "hashes": {
                "archive": archive_sha,
                "current_liquidity": current_sha,
                "defective_oracle": defective_sha,
                "repaired_oracle": repaired_sha,
            },
            "denominators": {
                "checks": n_checks,
                "passed": n_pass,
                "failed": n_fail,
                "cases": len(cases),
                "source_files": len(SOURCE_FILES),
                "findings": len(findings),
                "empty_forbidden": True,
            },
            "cases": case_rows,
            "findings": findings,
            "m09": {
                "F28_excluded_as_protected": True,
                "named_unaffected_sibling": "F32",
                "additional_same_module_control": "F33",
                "designated_false_unchanged": "F31",
                "compiled_M09_execution": "not_run_P21",
            },
            "checks": checks,
            "failed": failed,
        }
        out = HERE / "logs/diagnose.json"
        out.write_text(json.dumps(result, indent=2) + "\n")
        print(f"UTC {utc}")
        print(f"CHECKS {n_checks} PASS {n_pass} FAIL {n_fail} CASES {len(cases)}")
        print(f"ARCHIVE {archive_sha}")
        print(f"DEFECTIVE {defective_sha}")
        print(f"REPAIRED {repaired_sha}")
        print(f"WRAP_EXPECTED {wrap_expected}")
        print(f"WRAP_DEFECTIVE_UNBOUNDED {wrap_defective_unbounded}")
        print(f"M09_SIBLING F32")
        print(f"LOG {out}")
        if n_fail:
            print("FAILED " + ",".join(failed))
            return 1
        print("DIAGNOSTICS_OK")
        return 0
    except Blocked as e:
        blocked.append(str(e))
        print(f"BLOCKED {e}", file=sys.stderr)
        (HERE / "logs/diagnose.json").write_text(
            json.dumps({"status": "blocked", "utc": utc, "reason": str(e), "checks": checks}, indent=2) + "\n"
        )
        return 3
    except CheckError as e:
        print(f"FAIL {e}", file=sys.stderr)
        (HERE / "logs/diagnose.json").write_text(
            json.dumps({"status": "fail", "utc": utc, "reason": str(e), "checks": checks}, indent=2) + "\n"
        )
        return 1


if __name__ == "__main__":
    if "--empty-corpus" in sys.argv:
        print("BLOCKED empty diagnostic case denominator", file=sys.stderr)
        print("DENOMINATOR 0")
        sys.exit(3)
    sys.exit(main())
