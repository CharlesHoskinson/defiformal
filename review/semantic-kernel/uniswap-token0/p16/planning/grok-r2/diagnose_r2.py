#!/usr/bin/env python3
"""P16 r2 planning diagnostic supplement.

New witness expectations and source-shaped mutant arithmetic only.
No production mutation credit, no solc/EVM, no Lean.
Does not write into grok-r1. Replaying r1 diagnose.py redirects its
logs/diagnose.json write here and denies other Path.write_text calls.
"""
from __future__ import annotations

import sys

sys.dont_write_bytecode = True

import hashlib
import importlib.util
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
R1 = ROOT / "review/semantic-kernel/uniswap-token0/p16/planning/grok-r1"
CHANGE = ROOT / "openspec/changes/uniswap-token0-p16"

U256 = 2**256
U160 = 2**160
Q96 = 2**96

R1_DIAGNOSE_SHA = "ad14dc08c1d3ea01eeaf5baf3b79d1ca3c460c47190c833f08a201aae8f2c20f"
R1_REPAIRED_SHA = "d4ff08d0ebdee3818c24e13ac8abd2f6095f414282289930cacc740d88016279"
R1_DEFECTIVE_SHA = "4ecd60394ab4deff50387f578a9ac85f981946d17b9ff36d0724ccbd3921e0cd"
R1_DIAGNOSE_JSON_SHA = "174b14e1fdc4c4865bbd915bd3de9375bee65cd47c6960bedbdd02816ec7ad13"

WRAP_SQRT = 1461446703485210103287273052203988822378723970341
WRAP_LIQ = 2**128 - 1
WRAP_AMOUNT = 79231140577496994670249413376
WRAP_OK = 340269576638287423012608907232989748562
WRAP_SKIP_MUTANT = 1430089493431239948923811608424801982436782118539
WRAP_SKIP_BEFORE = 26959946667150639797558606217781773540764640863681657483196324910731
PROD_AMOUNT = 2**160
SAFECAST_SQRT = 2**159
SAFECAST_LIQ = 2**63 + 1
SAFECAST_QUOTIENT = 2**222 + 2**159


class Blocked(Exception):
    pass


class CheckError(Exception):
    pass


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def ceil_div(x: int, y: int) -> int:
    if y <= 0:
        raise CheckError(f"ceil_div non-positive {y}")
    return x // y + (1 if x % y else 0)


def ceil_muldiv(a: int, b: int, d: int):
    if d == 0:
        return ("error", "divisionByZero")
    prod = a * b
    q = prod // d
    if prod % d:
        q += 1
    if q >= U256:
        return ("error", "quotientOverflow")
    return ("ok", q)


def product_fits_source(amount: int, sqrt_p: int) -> bool:
    """Solidity 0.7.6: (product = amount * sqrtPX96) / amount == sqrtPX96 for amount != 0."""
    if amount == 0:
        return False
    wrapped = (amount * sqrt_p) % U256
    return wrapped // amount == sqrt_p


def public_token0(sqrt_p: int, liq: int, amount: int, add: bool) -> dict:
    """Source-shaped public helper. Independent of r1 oracle modules."""
    if amount == 0:
        return {"status": "ok", "branch": "identity", "value": sqrt_p}
    n1 = liq << 96
    if add:
        fits = product_fits_source(amount, sqrt_p)
        if fits:
            product = amount * sqrt_p
            wrapped_denom = (n1 + product) % U256
            if wrapped_denom >= n1:
                fm = ceil_muldiv(n1, sqrt_p, wrapped_denom)
                if fm[0] == "error":
                    return {"status": "error", "branch": "primary_fullmath", "name": fm[1]}
                return {
                    "status": "ok",
                    "branch": "primary_muldiv",
                    "value": fm[1] % U160,
                    "before_cast": fm[1],
                }
            if sqrt_p == 0:
                return {"status": "error", "branch": "fallback", "name": "unspecified_div0"}
            inner = (n1 // sqrt_p) + amount
            if inner >= U256:
                return {"status": "error", "branch": "fallback", "name": "addOverflow"}
            val = ceil_div(n1, inner)
            return {"status": "ok", "branch": "wrapped_sum_fallback", "value": val % U160, "before_cast": val}
        if sqrt_p == 0:
            return {"status": "error", "branch": "fallback", "name": "unspecified_div0"}
        inner = (n1 // sqrt_p) + amount
        if inner >= U256:
            return {"status": "error", "branch": "fallback", "name": "addOverflow"}
        val = ceil_div(n1, inner)
        return {"status": "ok", "branch": "product_overflow_fallback", "value": val % U160, "before_cast": val}
    fits = product_fits_source(amount, sqrt_p)
    if not fits or n1 <= (amount * sqrt_p if fits else 0):
        if not fits:
            return {"status": "error", "branch": "remove_require", "name": "require"}
        product = amount * sqrt_p
        if n1 <= product:
            return {"status": "error", "branch": "remove_require", "name": "require"}
    product = amount * sqrt_p
    denom = n1 - product
    fm = ceil_muldiv(n1, sqrt_p, denom)
    if fm[0] == "error":
        return {"status": "error", "branch": "remove_fullmath", "name": fm[1], "fullmath_quotient": None}
    if fm[1] >= U160:
        return {
            "status": "error",
            "branch": "remove_safecast",
            "name": "uint160Overflow",
            "fullmath_quotient": fm[1],
        }
    return {"status": "ok", "branch": "remove_primary", "value": fm[1]}


def mutant_req_skip(sqrt_p: int, liq: int, amount: int) -> dict:
    """Delete only numerator1 > product. Keep product-fit require."""
    if amount == 0:
        return {"status": "ok", "value": sqrt_p, "branch": "identity"}
    n1 = liq << 96
    if not product_fits_source(amount, sqrt_p):
        return {"status": "error", "name": "require", "branch": "product_fit"}
    product = amount * sqrt_p
    denom = (n1 - product) % U256
    fm = ceil_muldiv(n1, sqrt_p, denom)
    if fm[0] == "error":
        return {"status": "error", "name": fm[1], "branch": "fullmath", "wrapped_denominator": denom}
    if fm[1] >= U160:
        return {"status": "error", "name": "uint160Overflow", "fullmath_quotient": fm[1], "wrapped_denominator": denom}
    return {"status": "ok", "value": fm[1], "wrapped_denominator": denom, "branch": "wrapped_sub"}


def mutant_wrap_skip(sqrt_p: int, liq: int, amount: int) -> dict:
    """Keep wrapped sum; replace denominator >= numerator1 with true."""
    if amount == 0:
        return {"status": "ok", "value": sqrt_p}
    n1 = liq << 96
    if not product_fits_source(amount, sqrt_p):
        inner = (n1 // sqrt_p) + amount
        val = ceil_div(n1, inner)
        return {"status": "ok", "value": val % U160, "before_cast": val, "branch": "fallback"}
    product = amount * sqrt_p
    wrapped_denom = (n1 + product) % U256
    fm = ceil_muldiv(n1, sqrt_p, wrapped_denom)
    if fm[0] == "error":
        return {"status": "error", "name": fm[1]}
    return {"status": "ok", "value": fm[1] % U160, "before_cast": fm[1], "branch": "forced_primary"}


def mutant_prod_skip(sqrt_p: int, liq: int, amount: int) -> dict:
    """Retain wrapped product assignment; skip fit test (if true)."""
    if amount == 0:
        return {"status": "ok", "value": sqrt_p}
    n1 = liq << 96
    product = (amount * sqrt_p) % U256
    wrapped_denom = (n1 + product) % U256
    if wrapped_denom >= n1:
        fm = ceil_muldiv(n1, sqrt_p, wrapped_denom)
        if fm[0] == "error":
            return {"status": "error", "name": fm[1]}
        return {"status": "ok", "value": fm[1] % U160, "before_cast": fm[1]}
    inner = (n1 // sqrt_p) + amount
    val = ceil_div(n1, inner)
    return {"status": "ok", "value": val % U160, "before_cast": val}


def mutant_floor(sqrt_p: int, liq: int, amount: int) -> dict:
    if amount == 0:
        return {"status": "ok", "value": sqrt_p}
    n1 = liq << 96
    if not product_fits_source(amount, sqrt_p):
        raise CheckError("floor mutant expected primary path")
    product = amount * sqrt_p
    wrapped_denom = (n1 + product) % U256
    if wrapped_denom < n1:
        raise CheckError("floor mutant expected primary path")
    if wrapped_denom == 0:
        return {"status": "error", "name": "divisionByZero"}
    q = (n1 * sqrt_p) // wrapped_denom
    return {"status": "ok", "value": q}


def mutant_checked_add(sqrt_p: int, liq: int, amount: int) -> dict:
    if amount == 0:
        return {"status": "ok", "value": sqrt_p}
    n1 = liq << 96
    if not product_fits_source(amount, sqrt_p):
        inner = (n1 // sqrt_p) + amount
        val = ceil_div(n1, inner)
        return {"status": "ok", "value": val % U160, "branch": "fallback"}
    product = amount * sqrt_p
    if n1 + product >= U256:
        return {"status": "error", "name": "LowGasSafeMath.add", "branch": "checked_sum"}
    denom = n1 + product
    fm = ceil_muldiv(n1, sqrt_p, denom)
    if fm[0] == "error":
        return {"status": "error", "name": fm[1]}
    return {"status": "ok", "value": fm[1] % U160}


def id_skip_source_path(amount: int) -> dict:
    """Inspect Solidity path after deleting identity. Do not use product_fits_u256(amount==0)."""
    if amount != 0:
        raise CheckError("id-skip path inspection is for amount==0")
    return {
        "reaches_high_level_division_by_amount": True,
        "amount": 0,
        "python_product_fits_amount0_is_true": True,
        "python_identity_deletion_is_not_this_mutant": True,
        "public_successful_return": False,
        "evm_classification": "record at compiled implementation",
    }


def replay_r1_diagnose() -> dict:
    script = R1 / "diagnose.py"
    dest = HERE / "logs" / "diagnose-r1-replay.json"
    orig = Path.write_text
    denied = []

    def patched(self: Path, data, *args, **kwargs):
        target = self if self.is_absolute() else (Path.cwd() / self)
        resolved = target.resolve()
        r1_out = (R1 / "logs" / "diagnose.json").resolve()
        if resolved == r1_out:
            dest.parent.mkdir(parents=True, exist_ok=True)
            return orig(dest, data, *args, **kwargs)
        denied.append(str(resolved))
        raise PermissionError(f"write denied: {resolved}")

    Path.write_text = patched  # type: ignore[method-assign]
    try:
        spec = importlib.util.spec_from_file_location("p16_r1_diagnose_replay", script)
        if spec is None or spec.loader is None:
            raise Blocked("cannot load r1 diagnose.py")
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        rc = mod.main()
    finally:
        Path.write_text = orig  # type: ignore[method-assign]
    if denied:
        raise CheckError(f"r1 replay attempted extra writes: {denied}")
    if rc != 0:
        raise CheckError(f"r1 diagnose replay exit {rc}")
    if not dest.exists():
        raise CheckError("r1 replay did not produce redirected diagnose.json")
    data = json.loads(dest.read_text())
    if data.get("denominators", {}).get("failed") != 0:
        raise CheckError("r1 replay reported failures")
    return {
        "exit": rc,
        "redirected": str(dest.relative_to(ROOT)),
        "checks": data["denominators"]["checks"],
        "cases": data["denominators"]["cases"],
        "r1_script_sha256": sha256_file(script),
        "r1_original_log_sha256": sha256_file(R1 / "logs" / "diagnose.json"),
        "r1_original_log_unchanged": sha256_file(R1 / "logs" / "diagnose.json") == R1_DIAGNOSE_JSON_SHA,
    }


def main() -> int:
    utc = datetime.now(timezone.utc).isoformat()
    checks = []
    failed = []

    def record(name: str, passed: bool, detail=None) -> None:
        rec = {"check": name, "passed": bool(passed)}
        if detail is not None:
            rec["detail"] = detail
        checks.append(rec)
        if not passed:
            failed.append(name)

    try:
        if "--empty-corpus" in sys.argv:
            print("BLOCKED empty r2 diagnostic case denominator", file=sys.stderr)
            print("DENOMINATOR 0")
            return 3

        for p in [R1 / "diagnose.py", R1 / "cl_oracle_repaired.py", CHANGE / "fixtures.json", CHANGE / "planned-mutations.json"]:
            if not p.exists():
                raise Blocked(f"missing {p}")

        record("r1_diagnose_py_unchanged", sha256_file(R1 / "diagnose.py") == R1_DIAGNOSE_SHA)
        record("r1_repaired_oracle_unchanged", sha256_file(R1 / "cl_oracle_repaired.py") == R1_REPAIRED_SHA)
        record("r1_defective_oracle_unchanged", sha256_file(R1 / "witnesses/cl_oracle_defective.py") == R1_DEFECTIVE_SHA)
        record("r1_diagnose_json_unchanged", sha256_file(R1 / "logs" / "diagnose.json") == R1_DIAGNOSE_JSON_SHA)

        fixtures = json.loads((CHANGE / "fixtures.json").read_text())
        mutants = json.loads((CHANGE / "planned-mutations.json").read_text())
        api = json.loads((CHANGE / "proposed-api.json").read_text())
        design = (CHANGE / "design.md").read_text()
        by_id = {m["id"]: m for m in mutants["token0_production_mutants"]}

        new_cases = [
            ("P16-I-ZERO-LIQ", (Q96, 0, 0, False), {"status": "ok", "value": Q96, "branch": "identity"}),
            ("P16-REQ-STRICT", (Q96, 1, 2, False), {"status": "error", "name": "require", "branch": "remove_require"}),
            ("P16-SAFECAST", (SAFECAST_SQRT, SAFECAST_LIQ, 1, False), {"status": "error", "name": "uint160Overflow", "branch": "remove_safecast"}),
            ("P16-ADD-DEN0", (0, 0, 1, True), {"status": "error", "name": "divisionByZero", "branch": "primary_fullmath"}),
        ]
        if not new_cases:
            raise Blocked("empty new-case denominator")

        case_rows = []
        for cid, inputs, exp in new_cases:
            got = public_token0(*inputs)
            ok = got.get("status") == exp["status"] and got.get("branch") == exp.get("branch")
            if exp["status"] == "ok":
                ok = ok and got.get("value") == exp["value"]
            else:
                ok = ok and got.get("name") == exp["name"]
            if cid == "P16-SAFECAST":
                ok = ok and got.get("fullmath_quotient") == SAFECAST_QUOTIENT
            case_rows.append({"id": cid, "got": {k: (str(v) if isinstance(v, int) else v) for k, v in got.items()}, "ok": ok})
            record(f"witness_{cid}", ok, case_rows[-1])

        eq = public_token0(Q96, 1, 1, False)
        record("P16-REQ_equality_still_requires", eq.get("status") == "error" and eq.get("name") == "require")

        skip_eq = mutant_req_skip(Q96, 1, 1)
        record(
            "T0-REQ-SKIP_equality_still_publicly_refuses",
            skip_eq.get("status") == "error" and skip_eq.get("name") == "divisionByZero",
            {k: (str(v) if isinstance(v, int) else v) for k, v in skip_eq.items()},
        )
        skip_strict = mutant_req_skip(Q96, 1, 2)
        record(
            "T0-REQ-SKIP_strict_returns_1",
            skip_strict.get("status") == "ok" and skip_strict.get("value") == 1
            and skip_strict.get("wrapped_denominator") == U256 - Q96,
            {k: (str(v) if isinstance(v, int) else v) for k, v in skip_strict.items()},
        )
        orig_strict = public_token0(Q96, 1, 2, False)
        record("P16-REQ-STRICT_original_requires", orig_strict.get("status") == "error")

        wrap_skip = mutant_wrap_skip(WRAP_SQRT, WRAP_LIQ, WRAP_AMOUNT)
        record(
            "T0-WRAP-SKIP_public_truncated_word",
            wrap_skip.get("status") == "ok"
            and wrap_skip.get("value") == WRAP_SKIP_MUTANT
            and wrap_skip.get("before_cast") == WRAP_SKIP_BEFORE,
            {k: (str(v) if isinstance(v, int) else v) for k, v in wrap_skip.items()},
        )
        wrap_base = public_token0(WRAP_SQRT, WRAP_LIQ, WRAP_AMOUNT, True)
        record("P16-WRAP_baseline_unchanged", wrap_base.get("value") == WRAP_OK)

        prod_skip = mutant_prod_skip(Q96, Q96, PROD_AMOUNT)
        record("T0-PROD-SKIP_returns_Q96", prod_skip.get("status") == "ok" and prod_skip.get("value") == Q96)
        prod_base = public_token0(Q96, Q96, PROD_AMOUNT, True)
        record("P16-PROD_baseline_2_32", prod_base.get("value") == 2**32)

        fl = mutant_floor(Q96, 1, 2)
        record("T0-FLOOR_designated", fl.get("value") == 26409387504754779197847983445)
        add_round = public_token0(Q96, 1, 2, True)
        record("P16-ADD-ROUND_ceil", add_round.get("value") == 26409387504754779197847983446)
        add_ok = public_token0(Q96, 1, 1, True)
        record("P16-ADD_unaffected_2_95", add_ok.get("value") == 2**95)

        ch = mutant_checked_add(WRAP_SQRT, WRAP_LIQ, WRAP_AMOUNT)
        record("T0-CHECKED-ADD_wrap_reverts_LowGasSafeMath", ch.get("status") == "error" and ch.get("name") == "LowGasSafeMath.add")
        ch_add = mutant_checked_add(Q96, 1, 1)
        record("T0-CHECKED-ADD_ordinary_add_unaffected", ch_add.get("status") == "ok" and ch_add.get("value") == 2**95)

        idp = id_skip_source_path(0)
        record("T0-ID-SKIP_high_level_div_by_amount", idp["reaches_high_level_division_by_amount"] and not idp["public_successful_return"])

        record("plan_T0-REQ-SKIP_designated_P16-REQ-STRICT", by_id["T0-REQ-SKIP"]["designated_false"] == "P16-REQ-STRICT")
        record("plan_T0-REQ-SKIP_equality_baseline", by_id["T0-REQ-SKIP"].get("equality_baseline_control") == "P16-REQ")
        record("plan_T0-WRAP-SKIP_if_true", "if (true)" in by_id["T0-WRAP-SKIP"]["actual_source_change"])
        record("plan_T0-PROD-SKIP_keeps_assignment", "product = amount * sqrtPX96" in by_id["T0-PROD-SKIP"]["actual_source_change"])
        record("plan_T0-CHECKED-ADD_lowgassafe", "numerator1.add(product)" in by_id["T0-CHECKED-ADD"]["actual_source_change"])
        record(
            "plan_T0-CHECKED-ADD_not_operations_add",
            "Operations.add" not in by_id["T0-CHECKED-ADD"]["actual_source_change"],
        )
        record("plan_T0-ID-SKIP_not_python_identity", "product_fits_u256" in by_id["T0-ID-SKIP"]["not_the_same_mutation"])
        record("plan_no_signed_permission", "Do **not** declare `Signed`" in design)
        record("api_signed_not_in_p16", api.get("types_in_p16", {}).get("Signed", "").startswith("not in P16"))
        fx_ids = {f["id"] for f in fixtures["fixtures"]}
        record("fixture_P16-REQ-STRICT_present", "P16-REQ-STRICT" in fx_ids)
        record("fixture_P16-SAFECAST_present", "P16-SAFECAST" in fx_ids)
        record("fixture_P16-ADD-DEN0_present", "P16-ADD-DEN0" in fx_ids)
        record("fixture_P16-I-ZERO-LIQ_present", "P16-I-ZERO-LIQ" in fx_ids)
        m09 = mutants["m09_control_plan_repair"]
        record("m09_f32_model_side", "model-side" in m09.get("repaired_unaffected_scope", ""))

        replay = replay_r1_diagnose()
        record("r1_diagnose_replay_redirected", replay["exit"] == 0 and replay["r1_original_log_unchanged"], replay)

        n = len(checks)
        n_pass = sum(1 for c in checks if c["passed"])
        n_fail = sum(1 for c in checks if not c["passed"])
        if n == 0:
            raise Blocked("empty check denominator")
        result = {
            "schema": "p16-token0-planning-r2-diagnostics/v1",
            "utc": utc,
            "python": sys.version.split()[0],
            "not_solc": True,
            "not_evm": True,
            "not_lean": True,
            "production_mutation_credit": 0,
            "gate_accepted": False,
            "r1_provenance": {
                "diagnose_py": R1_DIAGNOSE_SHA,
                "repaired_oracle": R1_REPAIRED_SHA,
                "defective_oracle": R1_DEFECTIVE_SHA,
                "diagnose_json": R1_DIAGNOSE_JSON_SHA,
                "reused_not_rewritten": True,
            },
            "denominators": {
                "checks": n,
                "passed": n_pass,
                "failed": n_fail,
                "new_witnesses": len(new_cases),
                "empty_forbidden": True,
            },
            "cases": case_rows,
            "replay": replay,
            "checks": checks,
            "failed": failed,
        }
        out = HERE / "logs" / "diagnose_r2.json"
        out.write_text(json.dumps(result, indent=2) + "\n")
        print(f"UTC {utc}")
        print(f"CHECKS {n} PASS {n_pass} FAIL {n_fail} NEW_WITNESSES {len(new_cases)}")
        print(f"R1_REPLAY_EXIT {replay['exit']} R1_LOG_UNCHANGED {replay['r1_original_log_unchanged']}")
        print(f"LOG {out}")
        if n_fail:
            print("FAILED " + ",".join(failed))
            return 1
        print("R2_DIAGNOSTICS_OK")
        return 0
    except Blocked as e:
        print(f"BLOCKED {e}", file=sys.stderr)
        return 3
    except CheckError as e:
        print(f"FAIL {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    if "--empty-corpus" in sys.argv:
        print("BLOCKED empty r2 diagnostic case denominator", file=sys.stderr)
        print("DENOMINATOR 0")
        sys.exit(3)
    sys.exit(main())
