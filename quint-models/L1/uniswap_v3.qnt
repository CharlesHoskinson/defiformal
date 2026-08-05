// Uniswap V3 core — concentrated liquidity (active-range abstraction).
// Source: protocol-repos/dex/Uniswap_v3-core/contracts/UniswapV3Pool.sol
//   slot0.sqrtPriceX96/tick (L58-60), liquidity (L90), positions mapping (L97),
//   feeGrowthGlobal (L77-79), mint/burn/swap.
// Model: single active tick range; positions outside range hold idle inventory.

module uniswap_v3 {
  import common.* from "./common"

  pure val FEE_NUM: int = 997
  pure val FEE_DEN: int = 1000
  pure val USERS: Set[str] = Set("alice", "bob")

  // Price as integer tick proxy (higher = more token1 per token0)
  var price: int
  // Active in-range liquidity (virtual L)
  var activeL: int
  // Real reserves held by the pool
  var reserve0: int
  var reserve1: int
  // Per-user position: liquidity + range bounds (tickLower, tickUpper abstract ints)
  var posL: str -> int
  var posLo: str -> int
  var posHi: str -> int
  // Fee growth (simplified accumulator in token0 units)
  var feeGrowth: int
  var feesOwed: str -> int

  action init: bool = all {
    price' = 100,
    activeL' = 50,
    reserve0' = 50,
    reserve1' = 50,
    posL' = USERS.mapBy(u => if (u == "alice") 50 else 0),
    posLo' = USERS.mapBy(_ => 50),
    posHi' = USERS.mapBy(_ => 150),
    feeGrowth' = 0,
    feesOwed' = USERS.mapBy(_ => 0),
  }

  pure def inRange(price: int, lo: int, hi: int): bool =
    price >= lo and price < hi

  /// mint: add concentrated liquidity in [lo, hi]; only counts as activeL if price in range
  action mint(u: str, lo: int, hi: int, liq: int, a0: int, a1: int): bool = all {
    USERS.contains(u),
    liq > 0, a0 > 0, a1 > 0, lo < hi,
    posL' = posL.put(u, posL.get(u) + liq),
    posLo' = posLo.put(u, lo),
    posHi' = posHi.put(u, hi),
    reserve0' = reserve0 + a0,
    reserve1' = reserve1 + a1,
    activeL' = if (inRange(price, lo, hi)) activeL + liq else activeL,
    price' = price,
    feeGrowth' = feeGrowth,
    feesOwed' = feesOwed,
  }

  /// burn: remove liquidity from a position
  action burn(u: str, liq: int): bool = all {
    USERS.contains(u),
    liq > 0,
    posL.get(u) >= liq,
    val lo = posLo.get(u)
    val hi = posHi.get(u)
    val wasActive = inRange(price, lo, hi)
    // pro-rata principal return from reserves weighted by liq/activeL or pos share
    val a0 = if (activeL > 0 and wasActive) mulDivDown(liq, reserve0, activeL) else 0
    val a1 = if (activeL > 0 and wasActive) mulDivDown(liq, reserve1, activeL) else 0
    all {
      posL' = posL.put(u, posL.get(u) - liq),
      posLo' = posLo,
      posHi' = posHi,
      reserve0' = reserve0 - a0,
      reserve1' = reserve1 - a1,
      activeL' = if (wasActive) max(activeL - liq, 0) else activeL,
      price' = price,
      feeGrowth' = feeGrowth,
      feesOwed' = feesOwed,
    }
  }

  /// swap0for1: moves price down; fee accrues to active L
  action swap0for1(amountIn: int): bool = all {
    amountIn > 0,
    activeL > 0,
    reserve1 > 0,
    val out = cpAmountOut(reserve0, reserve1, amountIn, FEE_NUM, FEE_DEN)
    all {
      out > 0,
      out < reserve1,
      reserve0' = reserve0 + amountIn,
      reserve1' = reserve1 - out,
      // price moves against the trade
      price' = max(price - 1, 1),
      // fee slice to feeGrowth
      feeGrowth' = feeGrowth + max(amountIn / 1000, 0),
      activeL' = activeL,
      posL' = posL,
      posLo' = posLo,
      posHi' = posHi,
      feesOwed' = feesOwed,
    }
  }

  /// After price moves, recompute activeL from positions (tick-crossing abstraction)
  action recomputeActive: bool = all {
    val newActive = USERS.fold(0, (acc, u) =>
      acc + (if (inRange(price, posLo.get(u), posHi.get(u))) posL.get(u) else 0)
    )
    all {
      activeL' = newActive,
      price' = price,
      reserve0' = reserve0,
      reserve1' = reserve1,
      posL' = posL,
      posLo' = posLo,
      posHi' = posHi,
      feeGrowth' = feeGrowth,
      feesOwed' = feesOwed,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet liq = 1.to(20).oneOf()
    nondet a0 = 1.to(20).oneOf()
    nondet a1 = 1.to(20).oneOf()
    nondet lo = 1.to(80).oneOf()
    nondet hi = 100.to(200).oneOf()
    nondet din = 1.to(10).oneOf()
    any {
      mint(u, lo, hi, liq, a0, a1),
      burn(u, liq),
      swap0for1(din),
      recomputeActive,
    }
  }

  val reservesNonNeg: bool = reserve0 >= 0 and reserve1 >= 0 and activeL >= 0

  /// Active liquidity never exceeds sum of position liquidities
  val activeBounded: bool =
    activeL <= USERS.fold(0, (acc, u) => acc + posL.get(u))
}
