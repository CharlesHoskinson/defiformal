#!/usr/bin/env python3
"""P16 r3 stored-field binding for T0-REQ-SKIP strict-underflow denominator.

Reads caller-supplied fixtures.json and planned-mutations.json. Recomputes
the wrapped uint256 subtraction from the stored P16-REQ-STRICT inputs and
compares both stored denominator fields plus public result 1, designated
false, equality baseline, and ordinary-add control.

Planning diagnostic only. Not solc, not EVM, not Lean, not production
mutation credit. Exit 0 = nonempty binding held. Exit 1 = stored field
mismatch or malformed input. Exit 3 = empty/blocked (no corpus).
"""
from __future__ import annotations

import sys

sys.dont_write_bytecode = True

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

U256 = 2**256
U160 = 2**160
EXACT_WRAPPED = U256 - (2**96)
EXACT_WRAPPED_DEC = str(EXACT_WRAPPED)
WRONG_U256_DEC = str(U256)


class Blocked(Exception):
    pass


class CheckError(Exception):
    pass


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def parse_args(argv: list[str]) -> dict:
    out: dict = {
        "fixtures": None,
        "mutations": None,
        "out": None,
        "empty": False,
        "corrupt_fixtures": False,
        "corrupt_mutations": False,
    }
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == "--empty-corpus":
            out["empty"] = True
            i += 1
            continue
        if a == "--corrupt-fixtures-denom":
            out["corrupt_fixtures"] = True
            i += 1
            continue
        if a == "--corrupt-mutations-denom":
            out["corrupt_mutations"] = True
            i += 1
            continue
        if a == "--fixtures":
            if i + 1 >= len(argv):
                raise Blocked("missing --fixtures path")
            out["fixtures"] = Path(argv[i + 1])
            i += 2
            continue
        if a == "--mutations":
            if i + 1 >= len(argv):
                raise Blocked("missing --mutations path")
            out["mutations"] = Path(argv[i + 1])
            i += 2
            continue
        if a == "--out":
            if i + 1 >= len(argv):
                raise Blocked("missing --out path")
            out["out"] = Path(argv[i + 1])
            i += 2
            continue
        raise CheckError(f"unknown argument {a}")
    return out


def by_id(items, key: str, wanted: str, label: str):
    if not isinstance(items, list) or not items:
        raise CheckError(f"empty or missing {label} list")
    for item in items:
        if isinstance(item, dict) and item.get("id") == wanted:
            return item
    raise CheckError(f"missing {label} id={wanted}")


def parse_inputs(obj: dict, label: str) -> dict:
    inp = obj.get("inputs")
    if not isinstance(inp, dict):
        raise CheckError(f"{label} missing inputs object")
    try:
        sqrt_p = int(inp["sqrtPX96"])
        liq = int(inp["liquidity"])
        amount = int(inp["amount"])
        add = inp["add"]
    except (KeyError, TypeError, ValueError) as e:
        raise CheckError(f"{label} inputs not bindable: {e}") from e
    if not isinstance(add, bool):
        raise CheckError(f"{label} inputs.add is not JSON boolean")
    return {"sqrtPX96": sqrt_p, "liquidity": liq, "amount": amount, "add": add}


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


def recompute_req_skip(sqrt_p: int, liq: int, amount: int) -> dict:
    """Delete only numerator1 > product. Keep product-fit. Native wrap sub."""
    if amount == 0:
        return {"status": "ok", "value": sqrt_p, "branch": "identity"}
    n1 = liq << 96
    wrapped_product = (amount * sqrt_p) % U256
    if amount == 0 or wrapped_product // amount != sqrt_p:
        return {"status": "error", "name": "require", "branch": "product_fit", "numerator1": n1}
    product = amount * sqrt_p
    denom = (n1 - product) % U256
    fm = ceil_muldiv(n1, sqrt_p, denom)
    if fm[0] == "error":
        return {
            "status": "error",
            "name": fm[1],
            "branch": "fullmath",
            "numerator1": n1,
            "product": product,
            "wrapped_denominator": denom,
        }
    if fm[1] >= U160:
        return {
            "status": "error",
            "name": "uint160Overflow",
            "wrapped_denominator": denom,
            "numerator1": n1,
            "product": product,
        }
    return {
        "status": "ok",
        "value": fm[1],
        "wrapped_denominator": denom,
        "numerator1": n1,
        "product": product,
        "branch": "wrapped_sub",
    }


def original_remove_require(sqrt_p: int, liq: int, amount: int) -> dict:
    if amount == 0:
        return {"status": "ok", "value": sqrt_p, "branch": "identity"}
    n1 = liq << 96
    wrapped_product = (amount * sqrt_p) % U256
    if wrapped_product // amount != sqrt_p:
        return {"status": "error", "name": "require", "branch": "remove_require"}
    product = amount * sqrt_p
    if n1 <= product:
        return {"status": "error", "name": "require", "branch": "remove_require", "numerator1": n1, "product": product}
    denom = n1 - product
    fm = ceil_muldiv(n1, sqrt_p, denom)
    if fm[0] == "error":
        return {"status": "error", "name": fm[1], "branch": "remove_fullmath"}
    if fm[1] >= U160:
        return {"status": "error", "name": "uint160Overflow", "branch": "remove_safecast"}
    return {"status": "ok", "value": fm[1], "branch": "remove_primary"}


def ordinary_add(sqrt_p: int, liq: int, amount: int) -> dict:
    if amount == 0:
        return {"status": "ok", "value": sqrt_p, "branch": "identity"}
    n1 = liq << 96
    wrapped_product = (amount * sqrt_p) % U256
    if wrapped_product // amount != sqrt_p:
        raise CheckError("P16-ADD control expected product-fit primary path")
    product = amount * sqrt_p
    denom = (n1 + product) % U256
    if denom < n1:
        raise CheckError("P16-ADD control expected non-wrapping sum")
    fm = ceil_muldiv(n1, sqrt_p, denom)
    if fm[0] == "error":
        return {"status": "error", "name": fm[1]}
    return {"status": "ok", "value": fm[1] % U160}


def dec(n: int) -> str:
    return str(n)


def bind(args: dict) -> dict:
    fx_path: Path = args["fixtures"]
    mu_path: Path = args["mutations"]
    if fx_path is None or mu_path is None:
        raise Blocked("missing --fixtures/--mutations stored-field corpus")
    if not fx_path.is_file() or not mu_path.is_file():
        raise Blocked("fixtures or mutations path is not a file")

    fx_bytes = fx_path.read_bytes()
    mu_bytes = mu_path.read_bytes()
    if not fx_bytes or not mu_bytes:
        raise Blocked("empty fixtures or mutations file denominator")
    fx_sha = hashlib.sha256(fx_bytes).hexdigest()
    mu_sha = hashlib.sha256(mu_bytes).hexdigest()

    try:
        fixtures = json.loads(fx_bytes.decode("utf-8"))
        mutants = json.loads(mu_bytes.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as e:
        raise CheckError(f"malformed JSON: {e}") from e

    if not isinstance(fixtures, dict) or not isinstance(mutants, dict):
        raise CheckError("fixtures/mutations root is not an object")

    strict = by_id(fixtures.get("fixtures"), "id", "P16-REQ-STRICT", "fixtures")
    equality = by_id(fixtures.get("fixtures"), "id", "P16-REQ", "fixtures")
    add = by_id(fixtures.get("fixtures"), "id", "P16-ADD", "fixtures")
    skip = by_id(mutants.get("token0_production_mutants"), "id", "T0-REQ-SKIP", "token0_production_mutants")

    strict_inputs = parse_inputs(strict, "P16-REQ-STRICT")
    eq_inputs = parse_inputs(equality, "P16-REQ")
    add_inputs = parse_inputs(add, "P16-ADD")

    mutant_block = skip.get("mutant_public_strict")
    fixture_block = strict.get("t0_req_skip_mutant")
    if not isinstance(mutant_block, dict) or not isinstance(fixture_block, dict):
        raise CheckError("missing t0_req_skip_mutant or mutant_public_strict object")

    stored_fx_denom = fixture_block.get("wrapped_denominator")
    stored_mu_denom = mutant_block.get("wrapped_denominator")
    stored_fx_ok = fixture_block.get("ok")
    stored_mu_ok = mutant_block.get("ok")

    if args["corrupt_fixtures"]:
        fixture_block = dict(fixture_block)
        fixture_block["wrapped_denominator"] = WRONG_U256_DEC
        stored_fx_denom = fixture_block["wrapped_denominator"]
    if args["corrupt_mutations"]:
        mutant_block = dict(mutant_block)
        mutant_block["wrapped_denominator"] = WRONG_U256_DEC
        stored_mu_denom = mutant_block["wrapped_denominator"]

    recomputed = recompute_req_skip(
        strict_inputs["sqrtPX96"],
        strict_inputs["liquidity"],
        strict_inputs["amount"],
    )
    original_strict = original_remove_require(
        strict_inputs["sqrtPX96"],
        strict_inputs["liquidity"],
        strict_inputs["amount"],
    )
    original_eq = original_remove_require(
        eq_inputs["sqrtPX96"],
        eq_inputs["liquidity"],
        eq_inputs["amount"],
    )
    mutant_eq = recompute_req_skip(
        eq_inputs["sqrtPX96"],
        eq_inputs["liquidity"],
        eq_inputs["amount"],
    )
    add_got = ordinary_add(
        add_inputs["sqrtPX96"],
        add_inputs["liquidity"],
        add_inputs["amount"],
    )

    checks = []
    failed = []

    def record(name: str, passed: bool, detail=None) -> None:
        rec = {"check": name, "passed": bool(passed)}
        if detail is not None:
            rec["detail"] = detail
        checks.append(rec)
        if not passed:
            failed.append(name)

    record(
        "stored_strict_inputs_add_false",
        strict_inputs["add"] is False,
        strict_inputs,
    )
    record(
        "recomputed_from_stored_inputs",
        recomputed.get("status") == "ok"
        and recomputed.get("value") == 1
        and recomputed.get("wrapped_denominator") == EXACT_WRAPPED,
        {k: (dec(v) if isinstance(v, int) else v) for k, v in recomputed.items()},
    )
    record(
        "fixtures_wrapped_denominator_matches_recompute",
        stored_fx_denom == dec(recomputed.get("wrapped_denominator", -1))
        and stored_fx_denom == EXACT_WRAPPED_DEC,
        {
            "stored": stored_fx_denom,
            "recomputed": dec(recomputed.get("wrapped_denominator", -1)) if isinstance(recomputed.get("wrapped_denominator"), int) else None,
            "field": "fixtures[id=P16-REQ-STRICT].t0_req_skip_mutant.wrapped_denominator",
        },
    )
    record(
        "mutations_wrapped_denominator_matches_recompute",
        stored_mu_denom == dec(recomputed.get("wrapped_denominator", -1))
        and stored_mu_denom == EXACT_WRAPPED_DEC,
        {
            "stored": stored_mu_denom,
            "recomputed": dec(recomputed.get("wrapped_denominator", -1)) if isinstance(recomputed.get("wrapped_denominator"), int) else None,
            "field": "token0_production_mutants[id=T0-REQ-SKIP].mutant_public_strict.wrapped_denominator",
        },
    )
    record(
        "fixtures_mutant_ok_is_1",
        stored_fx_ok == "1" and stored_fx_ok == dec(recomputed.get("value", -1)),
        {"stored": stored_fx_ok, "recomputed": dec(recomputed.get("value", -1)) if isinstance(recomputed.get("value"), int) else None},
    )
    record(
        "mutations_mutant_ok_is_1",
        stored_mu_ok == "1" and stored_mu_ok == dec(recomputed.get("value", -1)),
        {"stored": stored_mu_ok, "recomputed": dec(recomputed.get("value", -1)) if isinstance(recomputed.get("value"), int) else None},
    )
    record(
        "designated_false_is_P16-REQ-STRICT",
        skip.get("designated_false") == "P16-REQ-STRICT",
        skip.get("designated_false"),
    )
    record(
        "equality_baseline_is_P16-REQ",
        skip.get("equality_baseline_control") == "P16-REQ",
        skip.get("equality_baseline_control"),
    )
    record(
        "unaffected_positive_is_P16-ADD",
        skip.get("unaffected_positive") == "P16-ADD",
        skip.get("unaffected_positive"),
    )
    record(
        "original_strict_still_requires",
        original_strict.get("status") == "error" and original_strict.get("name") == "require",
        original_strict,
    )
    record(
        "stored_original_public_strict_error",
        isinstance(skip.get("original_public_strict"), dict)
        and skip["original_public_strict"].get("error") == "require",
        skip.get("original_public_strict"),
    )
    record(
        "equality_original_still_requires",
        original_eq.get("status") == "error" and original_eq.get("name") == "require" and eq_inputs["add"] is False,
        original_eq,
    )
    record(
        "equality_mutant_still_refuses",
        mutant_eq.get("status") == "error" and mutant_eq.get("name") == "divisionByZero",
        {k: (dec(v) if isinstance(v, int) else v) for k, v in mutant_eq.items()},
    )
    stored_add_ok = (add.get("expected") or {}).get("ok")
    record(
        "add_control_matches_stored_expected",
        add_got.get("status") == "ok"
        and stored_add_ok == dec(add_got.get("value", -1))
        and add_inputs["add"] is True,
        {"stored_expected_ok": stored_add_ok, "recomputed": dec(add_got.get("value", -1)) if isinstance(add_got.get("value"), int) else None},
    )
    record(
        "strict_and_equality_inputs_differ_by_amount",
        strict_inputs["amount"] != eq_inputs["amount"]
        and strict_inputs["sqrtPX96"] == eq_inputs["sqrtPX96"]
        and strict_inputs["liquidity"] == eq_inputs["liquidity"],
        {"strict_amount": strict_inputs["amount"], "equality_amount": eq_inputs["amount"]},
    )

    n = len(checks)
    n_pass = sum(1 for c in checks if c["passed"])
    n_fail = sum(1 for c in checks if not c["passed"])
    if n == 0:
        raise Blocked("empty check denominator")

    result = {
        "schema": "p16-token0-planning-r3-stored-field-binding/v1",
        "utc": datetime.now(timezone.utc).isoformat(),
        "python": sys.version.split()[0],
        "not_solc": True,
        "not_evm": True,
        "not_lean": True,
        "production_mutation_credit": 0,
        "gate_accepted": False,
        "corrupt_fixtures_denom": bool(args["corrupt_fixtures"]),
        "corrupt_mutations_denom": bool(args["corrupt_mutations"]),
        "inputs": {
            "fixtures_path": str(fx_path),
            "fixtures_sha256": fx_sha,
            "fixtures_bytes": len(fx_bytes),
            "mutations_path": str(mu_path),
            "mutations_sha256": mu_sha,
            "mutations_bytes": len(mu_bytes),
        },
        "fields_bound": [
            "fixtures[id=P16-REQ-STRICT].inputs",
            "fixtures[id=P16-REQ-STRICT].t0_req_skip_mutant.wrapped_denominator",
            "fixtures[id=P16-REQ-STRICT].t0_req_skip_mutant.ok",
            "fixtures[id=P16-REQ].inputs",
            "fixtures[id=P16-ADD].inputs",
            "fixtures[id=P16-ADD].expected.ok",
            "token0_production_mutants[id=T0-REQ-SKIP].designated_false",
            "token0_production_mutants[id=T0-REQ-SKIP].equality_baseline_control",
            "token0_production_mutants[id=T0-REQ-SKIP].unaffected_positive",
            "token0_production_mutants[id=T0-REQ-SKIP].original_public_strict",
            "token0_production_mutants[id=T0-REQ-SKIP].mutant_public_strict.ok",
            "token0_production_mutants[id=T0-REQ-SKIP].mutant_public_strict.wrapped_denominator",
        ],
        "stored_strict_inputs": {k: (dec(v) if isinstance(v, int) else v) for k, v in strict_inputs.items()},
        "recomputed_from_stored_inputs": {
            k: (dec(v) if isinstance(v, int) else v) for k, v in recomputed.items()
        },
        "exact_wrapped_denominator": EXACT_WRAPPED_DEC,
        "stored_denominators": {
            "fixtures": stored_fx_denom,
            "mutations": stored_mu_denom,
        },
        "denominators": {
            "checks": n,
            "passed": n_pass,
            "failed": n_fail,
            "empty_forbidden": True,
        },
        "checks": checks,
        "failed": failed,
    }
    out_path = args["out"]
    if out_path is not None:
        out_path = Path(out_path)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(result, indent=2) + "\n")
        result["wrote"] = str(out_path)
    print(f"UTC {result['utc']}")
    print(f"FIXTURES_SHA256 {fx_sha}")
    print(f"MUTATIONS_SHA256 {mu_sha}")
    print(f"CHECKS {n} PASS {n_pass} FAIL {n_fail}")
    print(f"RECOMPUTED_DENOM {EXACT_WRAPPED_DEC}")
    print(f"STORED_FIXTURES_DENOM {stored_fx_denom}")
    print(f"STORED_MUTATIONS_DENOM {stored_mu_denom}")
    if out_path is not None:
        print(f"LOG {out_path}")
    if n_fail:
        print("FAILED " + ",".join(failed))
        return 1
    print("R3_STORED_FIELD_BINDING_OK")
    return 0


def main(argv: list[str] | None = None) -> int:
    argv = list(sys.argv[1:] if argv is None else argv)
    try:
        args = parse_args(argv)
        if args["empty"]:
            print("BLOCKED empty r3 stored-field diagnostic case denominator", file=sys.stderr)
            print("DENOMINATOR 0")
            return 3
        return bind(args)
    except Blocked as e:
        print(f"BLOCKED {e}", file=sys.stderr)
        print("DENOMINATOR 0")
        return 3
    except CheckError as e:
        print(f"FAIL {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
