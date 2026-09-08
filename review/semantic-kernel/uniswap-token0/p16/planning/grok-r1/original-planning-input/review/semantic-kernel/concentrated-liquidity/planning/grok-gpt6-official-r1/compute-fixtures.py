#!/usr/bin/env python3
"""Compute independent concentrated-liquidity fixture literals and write inventories."""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from cl_oracle import (
    FEE_DEN,
    I256_MIN,
    MAX_SQRT_RATIO,
    MAX_TICK,
    MIN_SQRT_RATIO,
    MIN_TICK,
    Q96,
    U128,
    U256,
    add_delta,
    catch,
    compress_tick,
    compute_swap_step,
    dec,
    fee_spacing_valid,
    get_amount0_delta,
    get_amount1_delta,
    get_next_sqrt_price_from_amount0_rounding_up,
    get_next_sqrt_price_from_input,
    get_sqrt_ratio_at_tick,
    greatest_tick_at_or_below,
    mul_div,
    mul_div_rounding_up,
    next_initialized_tick_within_one_word,
    position,
    product_fits_u256,
)

CHECKS = []


def ck(name: str, cond) -> None:
    CHECKS.append({"check": name, "passed": bool(cond)})
    if not cond:
        raise SystemExit(f"ORACLE SELF-CHECK FAILED: {name}")


def ok(v):
    return {"ok": dec(v) if isinstance(v, int) else v}


def err(name):
    return {"error": name}


def fx(fid, operation, inputs, expected, scenarios, label, notes=""):
    rec = {
        "id": fid,
        "operation": operation,
        "inputs": inputs,
        "expected": expected,
        "scenarios": scenarios,
        "label": label,
        "execution": "not_run",
        "oracle": "cl_oracle.py independent Python integer arithmetic",
        "status": "PROPOSED_LITERAL_EXPECTATIONS_NOT_RUN",
    }
    if notes:
        rec["notes"] = notes
    return rec


def main() -> None:
    tick0 = get_sqrt_ratio_at_tick(0)
    tick1 = get_sqrt_ratio_at_tick(1)
    tickm1 = get_sqrt_ratio_at_tick(-1)
    tick_min = get_sqrt_ratio_at_tick(MIN_TICK)
    tick_max = get_sqrt_ratio_at_tick(MAX_TICK)
    ck("tick0 is Q96", tick0 == Q96)
    ck("MIN_TICK matches named constant", tick_min == MIN_SQRT_RATIO)
    ck("MAX_TICK matches named constant", tick_max == MAX_SQRT_RATIO)
    ck("tick1 > tick0", tick1 > tick0)
    ck("tick-1 < tick0", tickm1 < tick0)
    ck("inverse of Q96 is 0", greatest_tick_at_or_below(Q96) == 0)
    ck("inverse of MIN is MIN_TICK", greatest_tick_at_or_below(MIN_SQRT_RATIO) == MIN_TICK)
    ck("tick1 inverse", greatest_tick_at_or_below(tick1) == 1)
    ck("tick-1 inverse", greatest_tick_at_or_below(tickm1) == -1)

    phantom = mul_div(2**128, 2**128, 2**128)
    ck("phantom product 2^256 / 2^128", phantom == 2**128)
    ck("floor 10*20/3", mul_div(10, 20, 3) == 66)
    ck("ceil 10*20/3", mul_div_rounding_up(10, 20, 3) == 67)
    ck("exact 10*20/5", mul_div(10, 20, 5) == 40 and mul_div_rounding_up(10, 20, 5) == 40)

    a1_exact_down = get_amount1_delta(Q96, Q96 + 1, Q96, False)
    a1_exact_up = get_amount1_delta(Q96, Q96 + 1, Q96, True)
    ck("amount1 exact both 1", a1_exact_down == 1 and a1_exact_up == 1)
    a1_round_down = get_amount1_delta(Q96, Q96 + 1, 1, False)
    a1_round_up = get_amount1_delta(Q96, Q96 + 1, 1, True)
    ck("amount1 tiny rounding", a1_round_down == 0 and a1_round_up == 1)
    a0_round_down = get_amount0_delta(Q96, Q96 + 1, 1, False)
    a0_round_up = get_amount0_delta(Q96, Q96 + 1, 1, True)
    ck("amount0 tiny rounding", a0_round_down == 0 and a0_round_up == 1)
    a0_pow = get_amount0_delta(Q96, 2 * Q96, Q96, False)
    ck("amount0 power-of-two", a0_pow == 2**95)

    ck("zero amount short-circuit", get_next_sqrt_price_from_amount0_rounding_up(Q96, Q96, 0, True) == Q96)
    ck("overflow product detected", not product_fits_u256(2**160, Q96))
    fallback = get_next_sqrt_price_from_amount0_rounding_up(Q96, Q96, 2**160, True)
    ck("overflow fallback nonzero", fallback > 0)

    step_reach = compute_swap_step(Q96, Q96 - 1, Q96, 1000, 3000)
    ck("reach-target next", step_reach["sqrtRatioNextX96"] == Q96 - 1)
    ck("reach-target in", step_reach["amountIn"] == 2)
    ck("reach-target out", step_reach["amountOut"] == 1)
    ck("reach-target fee", step_reach["feeAmount"] == 1)
    ck("reach-target flag", step_reach["reachedTarget"] is True)

    step_fee = compute_swap_step(Q96, Q96 - 1, Q96, 1, 3000)
    ck("remainder-fee next stays", step_fee["sqrtRatioNextX96"] == Q96)
    ck("remainder-fee in0", step_fee["amountIn"] == 0)
    ck("remainder-fee out0", step_fee["amountOut"] == 0)
    ck("remainder-fee all remaining", step_fee["feeAmount"] == 1)
    ck("remainder-fee not target", step_fee["reachedTarget"] is False)

    step_cap = compute_swap_step(Q96, Q96 - 100, 2**97, -1, 3000)
    ck("exact-out cap out", step_cap["amountOut"] == 1)
    ck("exact-out cap in", step_cap["amountIn"] == 3)
    ck("exact-out cap fee", step_cap["feeAmount"] == 1)
    ck("exact-out next moved", step_cap["sqrtRatioNextX96"] == Q96 - 1)
    ck("exact-out not far target", step_cap["reachedTarget"] is False)

    step_one_for_zero = compute_swap_step(Q96, Q96 + 1, Q96, 1000, 3000)
    ck("oneForZero direction", step_one_for_zero["zeroForOne"] is False)
    ck("oneForZero reached", step_one_for_zero["reachedTarget"] is True)

    ck("compress -61/60 floor", compress_tick(-61, 60) == -2)
    ck("compress -60/60", compress_tick(-60, 60) == -1)
    ck("compress 60/60", compress_tick(60, 60) == 1)
    ck("position -1", position(-1) == (-1, 255))
    ck("position 0", position(0) == (0, 0))
    ck("position 256", position(256) == (1, 0))

    n_incl, init_incl = next_initialized_tick_within_one_word({0: 1}, 0, 1, True)
    ck("lte inclusive initialized", n_incl == 0 and init_incl is True)
    n_empty, init_empty = next_initialized_tick_within_one_word({0: 0}, 0, 1, True)
    ck("lte empty word edge", n_empty == 0 and init_empty is False)
    n_gt, init_gt = next_initialized_tick_within_one_word({}, 0, 1, False)
    ck("gt uninitialized word edge", n_gt == 255 and init_gt is False)
    n_neg, init_neg = next_initialized_tick_within_one_word({-1: 1 << 255}, -1, 1, True)
    ck("negative word -1 bit 255", n_neg == -1 and init_neg is True)

    ck("addDelta plus", add_delta(10, 5) == 15)
    ck("addDelta minus", add_delta(10, -3) == 7)
    ck("fee 3000/60", fee_spacing_valid(3000, 60) is True)
    ck("fee 1e6 invalid", fee_spacing_valid(1_000_000, 60) is False)
    ck("spacing 0 invalid", fee_spacing_valid(3000, 0) is False)
    ck("spacing 16384 invalid", fee_spacing_valid(3000, 16384) is False)

    fixtures = [
        fx("F01", "mulDiv", {"a": "10", "b": "20", "d": "3"}, ok(66), ["W01", "W07", "E01"],
           "cl.fixture.f01"),
        fx("F02", "mulDivRoundingUp", {"a": "10", "b": "20", "d": "3"}, ok(67), ["W02", "W07", "E01"],
           "cl.fixture.f02"),
        fx("F03", "mulDiv+mulDivRoundingUp", {"a": "10", "b": "20", "d": "5"},
           {"ok_down": "40", "ok_up": "40"}, ["W03", "E01"], "cl.fixture.f03"),
        fx("F04", "mulDiv", {"a": dec(2**128), "b": dec(2**128), "d": dec(2**128)},
           ok(2**128), ["W04", "W07", "E01"], "cl.fixture.f04",
           "Exact product is 2^256; documented FullMath permits this phantom overflow. Existing Arithmetic.Rounding.mulDiv at width 256 has the same natural-product specification."),
        fx("F05", "mulDiv", {"a": "1", "b": "1", "d": "0"}, err("divisionByZero"), ["W05", "E02"],
           "cl.fixture.f05"),
        fx("F06", "mulDiv", {"a": dec(U256 - 1), "b": "2", "d": "1"}, err("quotientOverflow"),
           ["W06", "E02"], "cl.fixture.f06"),
        fx("F07", "mulDivRoundingUp", {"a": dec(U256 - 1), "b": "1", "d": "1"},
           ok(U256 - 1), ["W02", "E01"], "cl.fixture.f07",
           "Exact product; remainder 0 so rounding-up does not increment."),
        fx("F08", "mulDivRoundingUp", {"a": dec(U256 - 1), "b": "3", "d": "2"},
           err("quotientOverflow"), ["W06", "E02"], "cl.fixture.f08",
           "floor((2^256-1)*3/2) already overflows uint256."),
        fx("F09", "mulDiv", {"a": "0", "b": dec(2**255), "d": "7"}, ok(0), ["W08", "E01"],
           "cl.fixture.f09"),
        fx("F10", "getSqrtRatioAtTick", {"tick": "0"}, ok(tick0), ["T01", "T06", "E01"],
           "cl.fixture.f10"),
        fx("F11", "getSqrtRatioAtTick", {"tick": "1"}, ok(tick1), ["T01", "E01"],
           "cl.fixture.f11"),
        fx("F12", "getSqrtRatioAtTick", {"tick": "-1"}, ok(tickm1), ["T01", "E01"],
           "cl.fixture.f12"),
        fx("F13", "getSqrtRatioAtTick", {"tick": dec(MIN_TICK)}, ok(tick_min), ["T02", "T06", "E01"],
           "cl.fixture.f13"),
        fx("F14", "getSqrtRatioAtTick", {"tick": dec(MAX_TICK)}, ok(tick_max), ["T02", "T06", "E01"],
           "cl.fixture.f14"),
        fx("F15", "getSqrtRatioAtTick", {"tick": "887273"}, err("tickOutOfBounds"), ["T03", "E02"],
           "cl.fixture.f15"),
        fx("F16", "getTickAtSqrtRatio", {"sqrtPriceX96": dec(Q96)}, ok(0), ["T04", "T06", "E01"],
           "cl.fixture.f16",
           "Independent spec: greatest tick whose forward price is <= input. Lean implements the source log algorithm and must match this value."),
        fx("F17", "getTickAtSqrtRatio", {"sqrtPriceX96": dec(MIN_SQRT_RATIO)}, ok(MIN_TICK),
           ["T04", "T05", "E01"], "cl.fixture.f17"),
        fx("F18", "getTickAtSqrtRatio", {"sqrtPriceX96": dec(MAX_SQRT_RATIO)}, err("ratioOutOfBounds"),
           ["T05", "E02"], "cl.fixture.f18", "Maximum ratio is exclusive."),
        fx("F19", "getTickAtSqrtRatio", {"sqrtPriceX96": dec(MIN_SQRT_RATIO - 1)}, err("ratioOutOfBounds"),
           ["T05", "E02"], "cl.fixture.f19"),
        fx("F20", "getAmount1Delta",
           {"sqrtA": dec(Q96), "sqrtB": dec(Q96 + 1), "liquidity": dec(Q96), "roundUp": False},
           {"ok_down": "1", "ok_up": "1"}, ["S01", "S08", "E01"], "cl.fixture.f20"),
        fx("F21", "getAmount1Delta",
           {"sqrtA": dec(Q96), "sqrtB": dec(Q96 + 1), "liquidity": "1", "roundUp": None},
           {"ok_down": "0", "ok_up": "1"}, ["S02", "S08", "E01"], "cl.fixture.f21"),
        fx("F22", "getAmount0Delta",
           {"sqrtA": dec(Q96), "sqrtB": dec(Q96 + 1), "liquidity": "1", "roundUp": None},
           {"ok_down": "0", "ok_up": "1"}, ["S02", "S08", "E01"], "cl.fixture.f22"),
        fx("F23", "getAmount0Delta",
           {"sqrtA": dec(Q96), "sqrtB": dec(2 * Q96), "liquidity": dec(Q96), "roundUp": False},
           ok(2**95), ["S01", "E01"], "cl.fixture.f23"),
        fx("F24", "getNextSqrtPriceFromAmount0RoundingUp",
           {"sqrtPX96": dec(Q96), "liquidity": dec(Q96), "amount": "0", "add": True},
           ok(Q96), ["S03", "E01"], "cl.fixture.f24"),
        fx("F25", "getNextSqrtPriceFromInput",
           {"sqrtPX96": "0", "liquidity": "1", "amountIn": "1", "zeroForOne": True},
           err("priceZero"), ["S04", "E02"], "cl.fixture.f25"),
        fx("F26", "getNextSqrtPriceFromInput",
           {"sqrtPX96": dec(Q96), "liquidity": "0", "amountIn": "1", "zeroForOne": True},
           err("liquidityZero"), ["S04", "E02"], "cl.fixture.f26"),
        fx("F27", "getNextSqrtPriceFromAmount0RoundingUp",
           {"sqrtPX96": dec(Q96), "liquidity": dec(Q96), "amount": dec(2**160), "add": True},
           ok(fallback), ["S05", "E01"], "cl.fixture.f27",
           "amount*sqrtPX96 = 2^256 does not fit uint256; 0.7.6 wrap-check fails and the source overflow-fallback expression is used. Not an algebraic identity with the non-overflow formula."),
        fx("F28", "computeSwapStep",
           {"sqrtCurrent": dec(Q96), "sqrtTarget": dec(Q96 - 1), "liquidity": dec(Q96),
            "amountRemaining": "1000", "feePips": "3000"},
           {"ok": {"sqrtRatioNextX96": dec(step_reach["sqrtRatioNextX96"]),
                   "amountIn": dec(step_reach["amountIn"]),
                   "amountOut": dec(step_reach["amountOut"]),
                   "feeAmount": dec(step_reach["feeAmount"])}},
           ["S06", "S08", "E01"], "cl.fixture.f28"),
        fx("F29", "computeSwapStep",
           {"sqrtCurrent": dec(Q96), "sqrtTarget": dec(Q96 - 1), "liquidity": dec(Q96),
            "amountRemaining": "1", "feePips": "3000"},
           {"ok": {"sqrtRatioNextX96": dec(step_fee["sqrtRatioNextX96"]),
                   "amountIn": dec(step_fee["amountIn"]),
                   "amountOut": dec(step_fee["amountOut"]),
                   "feeAmount": dec(step_fee["feeAmount"])}},
           ["S07", "S08", "E01"], "cl.fixture.f29",
           "Exact-input remainder-as-fee: target not reached, unused remaining becomes fee."),
        fx("F30", "computeSwapStep",
           {"sqrtCurrent": dec(Q96), "sqrtTarget": dec(Q96 - 100), "liquidity": dec(2**97),
            "amountRemaining": "-1", "feePips": "3000"},
           {"ok": {"sqrtRatioNextX96": dec(step_cap["sqrtRatioNextX96"]),
                   "amountIn": dec(step_cap["amountIn"]),
                   "amountOut": dec(step_cap["amountOut"]),
                   "feeAmount": dec(step_cap["feeAmount"])}},
           ["S09", "S08", "E01"], "cl.fixture.f30",
           "Exact-output cap: computed amountOut 2 is capped to requested 1."),
        fx("F31", "computeSwapStep",
           {"sqrtCurrent": dec(Q96), "sqrtTarget": dec(Q96 + 1), "liquidity": dec(Q96),
            "amountRemaining": "1000", "feePips": "3000"},
           {"ok": {"sqrtRatioNextX96": dec(step_one_for_zero["sqrtRatioNextX96"]),
                   "amountIn": dec(step_one_for_zero["amountIn"]),
                   "amountOut": dec(step_one_for_zero["amountOut"]),
                   "feeAmount": dec(step_one_for_zero["feeAmount"]),
                   "zeroForOne": False}},
           ["S10", "E01"], "cl.fixture.f31"),
        fx("F32", "computeSwapStep",
           {"sqrtCurrent": dec(Q96), "sqrtTarget": dec(Q96 - 1), "liquidity": dec(Q96),
            "amountRemaining": "1", "feePips": "1000000"},
           err("invalidFee"), ["S11", "E02"], "cl.fixture.f32",
           "Lean refuses feePips >= 1e6. Source SwapMath does not check; 0.7.6 1e6-feePips would wrap. Named model strengthening; factory context requires fee < 1e6."),
        fx("F33", "computeSwapStep",
           {"sqrtCurrent": dec(Q96), "sqrtTarget": dec(Q96 - 1), "liquidity": dec(Q96),
            "amountRemaining": dec(I256_MIN), "feePips": "3000"},
           err("intOverflow"), ["S12", "E02"], "cl.fixture.f33",
           "Exact-output path would negate int256 min. Source 0.7.6 wraps; Lean refuses. Named gap, not wrap-as-checked equivalence."),
        fx("F34", "compressTick", {"tick": "-61", "spacing": "60"}, ok(-2), ["B01", "E01"],
           "cl.fixture.f34"),
        fx("F35", "compressTick", {"tick": "-60", "spacing": "60"}, ok(-1), ["B01", "E01"],
           "cl.fixture.f35"),
        fx("F36", "position", {"compressed": "-1"}, {"ok": {"wordPos": "-1", "bitPos": "255"}},
           ["B02", "E01"], "cl.fixture.f36"),
        fx("F37", "nextInitializedTickWithinOneWord",
           {"words": {"0": "1"}, "tick": "0", "spacing": "1", "lte": True},
           {"ok": {"next": "0", "initialized": True}}, ["B03", "E01"], "cl.fixture.f37"),
        fx("F38", "nextInitializedTickWithinOneWord",
           {"words": {}, "tick": "0", "spacing": "1", "lte": False},
           {"ok": {"next": "255", "initialized": False}}, ["B04", "E01"], "cl.fixture.f38"),
        fx("F39", "nextInitializedTickWithinOneWord",
           {"words": {"-1": dec(1 << 255)}, "tick": "-1", "spacing": "1", "lte": True},
           {"ok": {"next": "-1", "initialized": True}}, ["B02", "B03", "E01"], "cl.fixture.f39"),
        fx("F40", "addDelta", {"x": "10", "y": "5"}, ok(15), ["B05", "E01"], "cl.fixture.f40"),
        fx("F41", "addDelta", {"x": "10", "y": "-3"}, ok(7), ["B05", "E01"], "cl.fixture.f41"),
        fx("F42", "addDelta", {"x": "10", "y": "-11"}, err("liquidityUnderflow"), ["B06", "E02"],
           "cl.fixture.f42"),
        fx("F43", "addDelta", {"x": dec(U128 - 1), "y": "1"}, err("liquidityOverflow"), ["B06", "E02"],
           "cl.fixture.f43"),
        fx("F44", "feeSpacingValid",
           {"cases": [
               {"fee": "500", "spacing": "10", "ok": True},
               {"fee": "3000", "spacing": "60", "ok": True},
               {"fee": "10000", "spacing": "200", "ok": True},
               {"fee": "1000000", "spacing": "60", "ok": False},
               {"fee": "3000", "spacing": "0", "ok": False},
               {"fee": "3000", "spacing": "16384", "ok": False},
           ]},
           {"ok": "all_six_match"}, ["B07", "E01", "E02"], "cl.fixture.f44"),
        fx("F45", "toInt256",
           {"in_range": dec(2**255 - 1), "overflow": dec(2**255)},
           {"ok": dec(2**255 - 1), "error": "intOverflow"}, ["W09", "E01", "E02"],
           "cl.fixture.f45"),
    ]

    ids = [f["id"] for f in fixtures]
    ck("45 fixtures", len(fixtures) == 45)
    ck("unique fixture ids", len(set(ids)) == 45)

    positives = [f["id"] for f in fixtures if "ok" in f["expected"] or "ok_down" in f["expected"]]
    negatives = [f["id"] for f in fixtures if f["expected"].get("error")]
    ck("nonempty positives", len(positives) >= 20)
    ck("nonempty negatives", len(negatives) >= 10)

    out_dir = Path(__file__).resolve().parents[3]  # repo root via concentrated-liquidity/planning/r1? 
    # file is review/semantic-kernel/concentrated-liquidity/planning/grok-gpt6-official-r1/compute-fixtures.py
    repo = Path(__file__).resolve().parents[5]
    change = repo / "openspec/changes/concentrated-liquidity-library"
    change.mkdir(parents=True, exist_ok=True)
    payload = {
        "status": "PROPOSED_LITERAL_EXPECTATIONS_NOT_RUN",
        "oracle": {
            "module": "review/semantic-kernel/concentrated-liquidity/planning/grok-gpt6-official-r1/cl_oracle.py",
            "kind": "independent Python integer arithmetic",
            "not_lean": True,
            "not_solc": True,
            "not_evm": True,
        },
        "self_checks": CHECKS,
        "constants": {
            "Q96": dec(Q96),
            "MIN_TICK": dec(MIN_TICK),
            "MAX_TICK": dec(MAX_TICK),
            "MIN_SQRT_RATIO": dec(MIN_SQRT_RATIO),
            "MAX_SQRT_RATIO": dec(MAX_SQRT_RATIO),
            "FEE_DEN": dec(FEE_DEN),
            "tick0": dec(tick0),
            "tick1": dec(tick1),
            "tickMinus1": dec(tickm1),
        },
        "fixtures": fixtures,
        "counts": {
            "fixtures": len(fixtures),
            "positive_or_mixed": len(positives),
            "negative": len(negatives),
        },
    }
    (change / "fixtures.json").write_text(json.dumps(payload, indent=2) + "\n")
    r1 = Path(__file__).resolve().parent
    (r1 / "oracle-self-checks.json").write_text(json.dumps({"passed": True, "checks": CHECKS}, indent=2) + "\n")
    print(json.dumps({"wrote": str(change / "fixtures.json"), "fixtures": len(fixtures),
                      "tick0": dec(tick0), "tick1": dec(tick1), "tickm1": dec(tickm1),
                      "fallback": dec(fallback),
                      "step_reach": {k: (dec(v) if isinstance(v, int) else v) for k, v in step_reach.items()},
                      "step_fee": {k: (dec(v) if isinstance(v, int) else v) for k, v in step_fee.items()},
                      "step_cap": {k: (dec(v) if isinstance(v, int) else v) for k, v in step_cap.items()},
                      "step_ofz": {k: (dec(v) if isinstance(v, int) else v) for k, v in step_one_for_zero.items()},
                      }, indent=2))


if __name__ == "__main__":
    main()
