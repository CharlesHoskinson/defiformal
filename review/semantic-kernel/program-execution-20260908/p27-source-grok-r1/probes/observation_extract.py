#!/usr/bin/env python3
"""Extract pinned GMX funding/equity/liquidation source excerpts.

Read-only. Does not execute Solidity, tests, or capture scripts.
Empty excerpt set is a blocked check, not a pass.
"""
from __future__ import annotations

import datetime
import hashlib
import json
import sys
from pathlib import Path

SANDBOX = Path("/home/charl/.cache/defiformal-program/program-execution-20260908/p27-source-grok-r1-sandbox")
SRC = SANDBOX / "review/semantic-kernel/program-execution-20260908/p27-gmx-source-preparation-attempt2"

EXCERPTS = [
    {
        "id": "liquidation-equity",
        "path": "source/contracts/position/PositionUtils.sol",
        "start": 400,
        "end": 450,
        "needles": ["info.remainingCollateralUsd =", "if (info.remainingCollateralUsd <= 0)"],
    },
    {
        "id": "collateral-no-positive-pnl",
        "path": "source/contracts/position/PositionUtils.sol",
        "start": 470,
        "end": 520,
        "needles": ["if (values.realizedPnlUsd < 0)"],
    },
    {
        "id": "liquidatable-position-guard",
        "path": "source/contracts/position/PositionUtils.sol",
        "start": 280,
        "end": 330,
        "needles": ["revert Errors.LiquidatablePosition("],
    },
    {
        "id": "insolvent-close-admission",
        "path": "source/contracts/position/DecreasePositionCollateralUtils.sol",
        "start": 70,
        "end": 95,
        "needles": ["collateralCache.isInsolventCloseAllowed ="],
    },
    {
        "id": "cost-refusal",
        "path": "source/contracts/position/DecreasePositionCollateralUtils.sol",
        "start": 620,
        "end": 660,
        "needles": ["revert Errors.InsufficientFundsToPayForCosts(", "PositionEventUtils.emitInsolventClose("],
    },
    {
        "id": "funding-shortfall-and-holding",
        "path": "source/contracts/position/DecreasePositionCollateralUtils.sol",
        "start": 240,
        "end": 290,
        "needles": ["revert Errors.EmptyHoldingAddress();", "PositionEventUtils.emitInsufficientFundingFeePayment("],
    },
    {
        "id": "pay-for-cost-rounding",
        "path": "source/contracts/position/DecreasePositionCollateralUtils.sol",
        "start": 540,
        "end": 620,
        "needles": [
            "if (params.order.initialCollateralDeltaAmount() > values.remainingCollateralAmount)",
            "Calc.roundUpDivision(costUsd, collateralTokenPrice.min)",
            "remainingCostInOutputToken * collateralTokenPrice.min / secondaryOutputTokenPrice.min",
        ],
    },
    {
        "id": "funding-fee-versus-claimables",
        "path": "source/contracts/pricing/PositionPricingUtils.sol",
        "start": 460,
        "end": 530,
        "needles": ["fundingFees.fundingFeeAmount = MarketUtils.getFundingAmount("],
    },
    {
        "id": "funding-cumulative-difference",
        "path": "source/contracts/market/MarketUtils.sol",
        "start": 1970,
        "end": 2020,
        "needles": ["uint256 fundingDiffFactor = (latestFundingAmountPerSize - positionFundingAmountPerSize);"],
    },
    {
        "id": "claimable-account-key",
        "path": "source/contracts/market/MarketUtils.sol",
        "start": 590,
        "end": 670,
        "needles": ["Keys.claimableFundingAmountKey(market, token, account)", "MarketToken(payable(market)).transferOut("],
    },
    {
        "id": "liquidation-utils",
        "path": "source/contracts/liquidation/LiquidationUtils.sol",
        "start": 1,
        "end": 160,
        "needles": ["function createLiquidationOrder"],
    },
    {
        "id": "errors-selected-reverts",
        "path": "source/contracts/error/Errors.sol",
        "start": 1,
        "end": 400,
        "needles": ["error InsufficientFundsToPayForCosts", "error LiquidatablePosition", "error EmptyHoldingAddress"],
    },
]


def sha256_path(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    started = datetime.datetime.now(datetime.timezone.utc).isoformat()
    result = {
        "probe": "p27-observation-extract",
        "started_utc": started,
        "sandbox": str(SANDBOX),
        "excerpts": [],
        "failures": [],
        "source_execution": False,
        "solc_executed": False,
        "tests_executed": False,
        "network": False,
        "P27_accepted": False,
    }

    def fail(name, detail):
        result["failures"].append({"name": name, "detail": detail})

    if not EXCERPTS:
        fail("empty_excerpt_spec_blocked", 0)
        result["excerpt_count"] = 0
        result["empty_check_blocked"] = True
        result["finished_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
        json.dump(result, sys.stdout, indent=2)
        sys.stdout.write("\n")
        return 3

    for spec in EXCERPTS:
        path = SRC / spec["path"]
        if not path.is_file():
            fail("missing_source", spec)
            continue
        lines = path.read_text(encoding="utf-8").splitlines()
        start = spec["start"]
        end = min(spec["end"], len(lines))
        if start < 1 or start > len(lines):
            fail("bad_range", spec)
            continue
        body = "\n".join(f"{i}|{lines[i-1]}" for i in range(start, end + 1))
        missing = [needle for needle in spec["needles"] if needle not in "\n".join(lines)]
        excerpt = {
            "id": spec["id"],
            "path": spec["path"],
            "sha256": sha256_path(path),
            "start": start,
            "end": end,
            "needles": spec["needles"],
            "missing_needles": missing,
            "text": body,
        }
        if missing:
            fail("missing_needles", {"id": spec["id"], "missing": missing})
        result["excerpts"].append(excerpt)

    result["excerpt_count"] = len(result["excerpts"])
    result["failure_count"] = len(result["failures"])
    result["empty_check_blocked"] = result["excerpt_count"] == 0
    result["finished_utc"] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    json.dump(result, sys.stdout, indent=2)
    sys.stdout.write("\n")
    if result["empty_check_blocked"]:
        return 3
    if result["failure_count"]:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
