// ApeX Protocol — AMM-backed perpetual margin.
// Source: protocol-repos/perp/ApeX-Protocol_apex-protocol/contracts/core/{Margin,Amm}.sol
//         interfaces/IMargin.sol Position {quoteSize, baseSize, tradeSize}
// Core machine: deposit margin → open/close against constant-product AMM → funding (CPF)
// → liquidate under-margined positions. LP mints shares of (base,quote) reserves.

module apex {
  import common.* from "./common"

  pure val TRADERS: Set[int] = Set(1, 2, 3)
  pure val MAINT_BPS: int = 500       // 5% maintenance (abstracted from config)
  pure val INIT_PRICE: int = 10       // base per quote unit (abstract)
  pure val INIT_BASE: int = 1000
  pure val INIT_QUOTE: int = 10000

  type TraderState = {
    position: MarginPosition,
    fundingCheckpoint: int,
  }

  var traders: int -> TraderState
  var reserveBase: int          // AMM base reserve (Margin.reserve / Amm.baseReserve)
  var reserveQuote: int         // AMM quote reserve
  var lpShares: int             // LiquidityERC20 totalSupply
  var marginPool: int           // base token held as trader margin (Margin.reserve)
  var funding: FundingState
  var markPrice: int
  var time: int

  pure def emptyTrader: TraderState =
    { position: emptyPosition, fundingCheckpoint: 0 }

  action init: bool = all {
    traders' = TRADERS.mapBy(_ => emptyTrader),
    reserveBase' = INIT_BASE,
    reserveQuote' = INIT_QUOTE,
    lpShares' = 100,            // seeded LP
    marginPool' = 0,
    funding' = initFunding,
    markPrice' = INIT_PRICE,
    time' = 0,
  }

  // --- pure economics ---

  // Constant-product swap quote: dy out for dx in on (x,y).
  pure def swapOut(x: int, y: int, dx: int): int =
    if (x + dx <= 0 or dx <= 0) 0
    else divFloor(y * dx, x + dx)

  pure def openLong(p: MarginPosition, quoteAmt: int, baseCost: int): MarginPosition =
    { posSize: p.posSize + quoteAmt,
      collateral: p.collateral,   // margin already in pool
      side: Long,
      entryNotional: p.entryNotional + baseCost }

  pure def openShort(p: MarginPosition, quoteAmt: int, baseCredit: int): MarginPosition =
    { posSize: p.posSize + quoteAmt,
      collateral: p.collateral,
      side: Short,
      entryNotional: p.entryNotional + baseCredit }

  // --- actions ---

  // Margin.addMargin (Margin.sol:50)
  action addMargin(t: int, amount: int): bool = all {
    TRADERS.contains(t),
    amount > 0,
    val ts = traders.get(t)
    all {
      traders' = traders.put(t, {
        ...ts,
        position: { ...ts.position, collateral: ts.position.collateral + amount }
      }),
      marginPool' = marginPool + amount,
      reserveBase' = reserveBase,
      reserveQuote' = reserveQuote,
      lpShares' = lpShares,
      funding' = funding,
      markPrice' = markPrice,
      time' = time,
    }
  }

  // Margin.openPosition long (Margin.sol:111) — trader buys base with quote notional via AMM
  action openLongPos(t: int, quoteAmt: int): bool = all {
    TRADERS.contains(t),
    quoteAmt > 0,
    val ts = traders.get(t)
    val baseCost = swapOut(reserveQuote, reserveBase, quoteAmt)
    all {
      ts.position.side == Flat or ts.position.side == Long,
      ts.position.collateral > 0,
      baseCost > 0,
      baseCost <= reserveBase,
      // open against AMM: quote reserve up, base reserve down
      reserveQuote' = reserveQuote + quoteAmt,
      reserveBase' = reserveBase - baseCost,
      traders' = traders.put(t, {
        ...ts,
        position: openLong(ts.position, quoteAmt, baseCost)
      }),
      marginPool' = marginPool,
      lpShares' = lpShares,
      funding' = funding,
      markPrice' = markPrice,
      time' = time,
    }
  }

  // Margin.openPosition short
  action openShortPos(t: int, quoteAmt: int): bool = all {
    TRADERS.contains(t),
    quoteAmt > 0,
    val ts = traders.get(t)
    val baseCredit = swapOut(reserveBase, reserveQuote, quoteAmt)
    all {
      ts.position.side == Flat or ts.position.side == Short,
      ts.position.collateral > 0,
      baseCredit > 0,
      // short: sell base into AMM → base up, quote down (simplified)
      quoteAmt <= reserveQuote,
      reserveBase' = reserveBase + quoteAmt,  // abstract: size in base units for short path
      reserveQuote' = reserveQuote - baseCredit,
      traders' = traders.put(t, {
        ...ts,
        position: openShort(ts.position, quoteAmt, baseCredit)
      }),
      marginPool' = marginPool,
      lpShares' = lpShares,
      funding' = funding,
      markPrice' = markPrice,
      time' = time,
    }
  }

  // Margin.liquidate (Margin.sol:253)
  action liquidate(t: int): bool = all {
    TRADERS.contains(t),
    val ts = traders.get(t)
    all {
      canLiquidate(ts.position, markPrice, MAINT_BPS),
      // close position, residual margin stays in pool (bonus abstracted)
      traders' = traders.put(t, emptyTrader),
      marginPool' = marginPool,  // simplified: collateral absorbed, not redistributed
      reserveBase' = reserveBase,
      reserveQuote' = reserveQuote,
      lpShares' = lpShares,
      funding' = funding,
      markPrice' = markPrice,
      time' = time,
    }
  }

  // Margin.updateCPF (Margin.sol:429)
  action tickFunding(rate: int): bool = all {
    funding' = advanceFunding(funding, rate, time + 1),
    time' = time + 1,
    traders' = traders,
    reserveBase' = reserveBase,
    reserveQuote' = reserveQuote,
    lpShares' = lpShares,
    marginPool' = marginPool,
    markPrice' = markPrice,
  }

  // Oracle / mark price move (external)
  action setMarkPrice(p: int): bool = all {
    p > 0,
    markPrice' = p,
    traders' = traders,
    reserveBase' = reserveBase,
    reserveQuote' = reserveQuote,
    lpShares' = lpShares,
    marginPool' = marginPool,
    funding' = funding,
    time' = time,
  }

  // Amm.mint simplified: add base liquidity, mint shares
  action addLiquidity(baseIn: int): bool = all {
    baseIn > 0,
    val newShares =
      if (lpShares == 0) baseIn
      else divFloor(baseIn * lpShares, reserveBase)
    all {
      newShares > 0,
      reserveBase' = reserveBase + baseIn,
      reserveQuote' = reserveQuote + divFloor(baseIn * reserveQuote, reserveBase),
      lpShares' = lpShares + newShares,
      traders' = traders,
      marginPool' = marginPool,
      funding' = funding,
      markPrice' = markPrice,
      time' = time,
    }
  }

  action step: bool = {
    nondet t = TRADERS.oneOf()
    nondet amt = 1.to(20).oneOf()
    nondet price = 5.to(20).oneOf()
    nondet rate = Set(0 - 1, 0, 1).oneOf()
    any {
      addMargin(t, amt),
      openLongPos(t, amt),
      openShortPos(t, amt),
      liquidate(t),
      tickFunding(rate),
      setMarkPrice(price),
      addLiquidity(amt),
    }
  }

  // Invariants
  // AMM reserves non-negative; margin pool non-negative.
  val reservesNonNeg: bool = reserveBase >= 0 and reserveQuote >= 0 and marginPool >= 0

  // Sum of trader collateral ≤ margin pool (equality under our model without fees).
  val marginConserved: bool =
    TRADERS.fold(0, (acc, t) => acc + traders.get(t).position.collateral) <= marginPool +
      TRADERS.fold(0, (acc, t) => {
        val p = traders.get(t).position
        if (p.side == Flat) acc else acc  // collateral already counted
      })

  val marginSolvent: bool =
    TRADERS.fold(0, (acc, t) => acc + traders.get(t).position.collateral) <= marginPool and
    marginPool >= 0 and reserveBase >= 0 and reserveQuote >= 0
}
