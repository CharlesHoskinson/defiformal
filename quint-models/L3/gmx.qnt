// GMX v2 Synthetics — pool-backed perpetual positions.
// Source: protocol-repos/perp/gmx-io_gmx-synthetics/contracts/
//   position/Position.sol Props {sizeInUsd, collateralAmount, isLong}
//   market/MarketUtils.sol poolAmount, longOpenInterest, shortOpenInterest, impact pool
// Core machine: deposit collateral → increase/decrease position against multi-asset pool
// → OI tracks long/short; pool value backs open interest; liquidate under-margined.

module gmx {
  import common.* from "./common"

  pure val TRADERS: Set[int] = Set(1, 2, 3)
  pure val MAINT_BPS: int = 100       // ~1% maintenance abstract
  pure val INIT_POOL: int = 10000
  pure val INIT_PRICE: int = 100

  var positions: int -> MarginPosition
  var poolAmount: int                 // MarketUtils poolAmount (collateral token)
  var longOI: int                     // long open interest (USD)
  var shortOI: int                    // short open interest (USD)
  var impactPool: int                 // position impact pool amount
  var markPrice: int
  var funding: FundingState
  var time: int

  action init: bool = all {
    positions' = TRADERS.mapBy(_ => emptyPosition),
    poolAmount' = INIT_POOL,
    longOI' = 0,
    shortOI' = 0,
    impactPool' = 0,
    markPrice' = INIT_PRICE,
    funding' = initFunding,
    time' = 0,
  }

  // Deposit collateral into a (possibly new) position — IncreaseOrder path simplified
  action depositCollateral(t: int, amount: int): bool = all {
    TRADERS.contains(t),
    amount > 0,
    amount <= poolAmount,  // cannot deposit more than available abstract capacity
    val p = positions.get(t)
    all {
      positions' = positions.put(t, { ...p, collateral: p.collateral + amount }),
      // collateral sits in market pool
      poolAmount' = poolAmount + amount,
      longOI' = longOI,
      shortOI' = shortOI,
      impactPool' = impactPool,
      markPrice' = markPrice,
      funding' = funding,
      time' = time,
    }
  }

  // Increase long size (IncreasePositionUtils)
  action increaseLong(t: int, sizeUsd: int): bool = all {
    TRADERS.contains(t),
    sizeUsd > 0,
    val p = positions.get(t)
    all {
      p.side == Flat or p.side == Long,
      p.collateral > 0,
      // pool must cover new OI at mark
      poolAmount * markPrice >= (longOI + sizeUsd),
      positions' = positions.put(t, {
        posSize: p.posSize + sizeUsd,
        collateral: p.collateral,
        side: Long,
        entryNotional: p.entryNotional + sizeUsd  // size already in USD
      }),
      longOI' = longOI + sizeUsd,
      shortOI' = shortOI,
      poolAmount' = poolAmount,
      impactPool' = impactPool,
      markPrice' = markPrice,
      funding' = funding,
      time' = time,
    }
  }

  action increaseShort(t: int, sizeUsd: int): bool = all {
    TRADERS.contains(t),
    sizeUsd > 0,
    val p = positions.get(t)
    all {
      p.side == Flat or p.side == Short,
      p.collateral > 0,
      poolAmount * markPrice >= (shortOI + sizeUsd),
      positions' = positions.put(t, {
        posSize: p.posSize + sizeUsd,
        collateral: p.collateral,
        side: Short,
        entryNotional: p.entryNotional + sizeUsd
      }),
      shortOI' = shortOI + sizeUsd,
      longOI' = longOI,
      poolAmount' = poolAmount,
      impactPool' = impactPool,
      markPrice' = markPrice,
      funding' = funding,
      time' = time,
    }
  }

  // Decrease / close position fully (DecreasePositionUtils)
  action closePosition(t: int): bool = all {
    TRADERS.contains(t),
    val p = positions.get(t)
    all {
      p.side != Flat and p.posSize > 0,
      val pnl = unrealizedPnl(p, markPrice)
      // settle: collateral + pnl returned from/to pool (bounded)
      val payout = max(0, p.collateral + pnl)
      all {
        payout <= poolAmount + p.collateral, // pool has funds (simplified)
        positions' = positions.put(t, emptyPosition),
        longOI' = if (p.side == Long) longOI - p.posSize else longOI,
        shortOI' = if (p.side == Short) shortOI - p.posSize else shortOI,
        // net: remove collateral that was in pool accounting, pay out
        poolAmount' = poolAmount - min(poolAmount, payout) + 0,
        impactPool' = impactPool,
        markPrice' = markPrice,
        funding' = funding,
        time' = time,
      }
    }
  }

  // Liquidate under-margined (PositionUtils.isPositionLiquidatable path)
  action liquidate(t: int): bool = all {
    TRADERS.contains(t),
    val p = positions.get(t)
    all {
      canLiquidate(p, markPrice, MAINT_BPS),
      positions' = positions.put(t, emptyPosition),
      longOI' = if (p.side == Long) longOI - p.posSize else longOI,
      shortOI' = if (p.side == Short) shortOI - p.posSize else shortOI,
      // residual collateral → impact / fee pool abstract
      impactPool' = impactPool + max(0, p.collateral),
      poolAmount' = poolAmount,
      markPrice' = markPrice,
      funding' = funding,
      time' = time,
    }
  }

  action setMarkPrice(p: int): bool = all {
    p > 0,
    markPrice' = p,
    positions' = positions,
    poolAmount' = poolAmount,
    longOI' = longOI,
    shortOI' = shortOI,
    impactPool' = impactPool,
    funding' = funding,
    time' = time,
  }

  action tickFunding(rate: int): bool = all {
    funding' = advanceFunding(funding, rate, time + 1),
    time' = time + 1,
    positions' = positions,
    poolAmount' = poolAmount,
    longOI' = longOI,
    shortOI' = shortOI,
    impactPool' = impactPool,
    markPrice' = markPrice,
  }

  action step: bool = {
    nondet t = TRADERS.oneOf()
    nondet amt = 1.to(50).oneOf()
    nondet sz = 10.to(100).oneOf()
    nondet price = 50.to(150).oneOf()
    nondet rate = Set(0 - 1, 0, 1).oneOf()
    any {
      depositCollateral(t, amt),
      increaseLong(t, sz),
      increaseShort(t, sz),
      closePosition(t),
      liquidate(t),
      setMarkPrice(price),
      tickFunding(rate),
    }
  }

  // OI is covered by pool at mark (solvency of market makers / LPs)
  val oiCovered: bool =
    longOI >= 0 and shortOI >= 0 and poolAmount >= 0 and
    (longOI + shortOI) <= poolAmount * markPrice + impactPool * markPrice

  // Position sizes match aggregate OI
  val oiMatchesPositions: bool = {
    val sumLong = TRADERS.fold(0, (acc, t) => {
      val p = positions.get(t)
      if (p.side == Long) acc + p.posSize else acc
    })
    val sumShort = TRADERS.fold(0, (acc, t) => {
      val p = positions.get(t)
      if (p.side == Short) acc + p.posSize else acc
    })
    sumLong == longOI and sumShort == shortOI
  }
}
