// L1 shared primitives — empirical recurrences across spot exchange + lending.
// Source-traced from Uniswap/Raydium CPAMM, Morpho/Aave share+index accounting,
// and collateralized-debt health checks. Instantiated by protocol modules in this lane.

module common {

  // ---------------------------------------------------------------------------
  // Arithmetic helpers (integer, non-negative domains assumed by callers)
  // ---------------------------------------------------------------------------

  pure def min(a: int, b: int): int = if (a < b) a else b
  pure def max(a: int, b: int): int = if (a > b) a else b

  pure def mulDivDown(a: int, b: int, d: int): int =
    if (d <= 0) 0 else (a * b) / d

  pure def mulDivUp(a: int, b: int, d: int): int =
    if (d <= 0) 0 else (a * b + d - 1) / d

  // ---------------------------------------------------------------------------
  // Candidate primitive: CONSTANT_PRODUCT_SWAP (Cp)
  // UniswapV2Pair.swap, Raydium ConstantProductCurve::swap_base_input_without_fees
  // (reserveIn + amountInWithFee) * (reserveOut - amountOut) >= reserveIn * reserveOut
  // ---------------------------------------------------------------------------

  /// Output amount for a constant-product swap with fee taken from input.
  /// feeNum/feeDen: e.g. Uni V2 uses 997/1000 (0.3% fee).
  pure def cpAmountOut(
    reserveIn: int, reserveOut: int, amountIn: int, feeNum: int, feeDen: int
  ): int = {
    if (amountIn <= 0 or reserveIn <= 0 or reserveOut <= 0 or feeDen <= 0)
      0
    else {
      val amountInWithFee = amountIn * feeNum
      val numerator = amountInWithFee * reserveOut
      val denominator = reserveIn * feeDen + amountInWithFee
      numerator / denominator
    }
  }

  /// Post-swap reserves (input token grows, output shrinks).
  pure def cpApplySwap(
    reserveIn: int, reserveOut: int, amountIn: int, feeNum: int, feeDen: int
  ): (int, int) = {
    val out = cpAmountOut(reserveIn, reserveOut, amountIn, feeNum, feeDen)
    (reserveIn + amountIn, reserveOut - out)
  }

  /// Invariant: product of reserves is non-decreasing after a fee-bearing swap.
  pure def cpProduct(r0: int, r1: int): int = r0 * r1

  pure def cpKHolds(r0: int, r1: int, r0p: int, r1p: int): bool =
    cpProduct(r0p, r1p) >= cpProduct(r0, r1)

  // ---------------------------------------------------------------------------
  // Candidate primitive: PRO_RATA_SHARES (Sh)
  // Morpho toSharesDown/toAssetsDown; Uni V2 mint liquidity = amount * supply / reserve
  // ---------------------------------------------------------------------------

  /// Shares minted for a deposit of `assets` into a pool with totals.
  pure def sharesFromAssets(assets: int, totalAssets: int, totalShares: int): int =
    if (assets <= 0) 0
    else if (totalShares == 0 or totalAssets == 0) assets
    else mulDivDown(assets, totalShares, totalAssets)

  /// Assets redeemed for burning `shares`.
  pure def assetsFromShares(shares: int, totalAssets: int, totalShares: int): int =
    if (shares <= 0 or totalShares <= 0) 0
    else mulDivDown(shares, totalAssets, totalShares)

  /// CPAMM first deposit: geometric mean of amounts (Uni V2: sqrt(a0*a1) - MINIMUM).
  pure def geometricMint(a0: int, a1: int): int = {
    // integer sqrt via linear search bound — small domains only
    val p = a0 * a1
    if (p <= 0) 0
    else {
      // For small ints used in models, floor(sqrt(p)) by binary search
      // Unrolled for quint purity without loops: use fold over candidates.
      // Callers in our models use amounts where sqrt is exact or we take min.
      // Practical: return min(a0, a1) as a conservative lower bound only when equal;
      // protocol specs override with domain-specific mint formula.
      if (a0 == a1) a0 else min(a0, a1)
    }
  }

  // ---------------------------------------------------------------------------
  // Candidate primitive: INDEX_ACCRUAL (Ix)
  // Aave liquidityIndex / variableBorrowIndex; JustLend borrowIndex;
  // Compound baseSupplyIndex / baseBorrowIndex; Fluid exchangePrice.
  // present = scaled * index / INDEX_BASE
  // ---------------------------------------------------------------------------

  pure val INDEX_BASE: int = 1000000  // 1e6 scale (abstracted from ray/wad)

  pure def presentFromScaled(scaled: int, index: int): int =
    mulDivDown(scaled, index, INDEX_BASE)

  pure def scaledFromPresent(present: int, index: int): int =
    if (index <= 0) 0 else mulDivDown(present, INDEX_BASE, index)

  /// Accrue index by simple interest: index' = index * (BASE + rateBps * dt) / BASE
  /// rateBps is basis points per time unit (abstract).
  pure def accrueIndex(index: int, rateBps: int, dt: int): int =
    if (dt <= 0 or rateBps < 0) index
    else mulDivDown(index, INDEX_BASE + rateBps * dt, INDEX_BASE)

  // ---------------------------------------------------------------------------
  // Candidate primitive: COLLATERALIZED_HEALTH (Ct / Li precondition)
  // Morpho _isHealthy: collateral * price * lltv >= borrow * ORACLE_SCALE
  // Aave HF = collateral * liqThreshold / debt
  // ---------------------------------------------------------------------------

  /// Healthy iff collateralValue * ltvBps >= debtValue * 10000.
  /// Prices are abstract positive integers; values = amount * price.
  pure def collValue(amount: int, price: int): int = amount * price

  pure def isHealthy(
    collAmount: int, collPrice: int,
    debtAmount: int, debtPrice: int,
    ltvBps: int
  ): bool = {
    if (debtAmount <= 0) true
    else {
      val c = collValue(collAmount, collPrice)
      val d = collValue(debtAmount, debtPrice)
      c * ltvBps >= d * 10000
    }
  }

  /// Seized collateral for a repayment at liquidation incentive (bps, e.g. 10500 = 5% bonus).
  pure def seizeCollateral(
    repayDebt: int, debtPrice: int, collPrice: int, incentiveBps: int
  ): int =
    if (collPrice <= 0) 0
    else mulDivDown(repayDebt * debtPrice * incentiveBps, 1, collPrice * 10000)

  // ---------------------------------------------------------------------------
  // Candidate primitive: UTILIZATION_RATE (feeds two-slope IRMs)
  // util = totalBorrow / totalSupply (capped)
  // ---------------------------------------------------------------------------

  pure def utilization(totalBorrow: int, totalSupply: int): int =
    if (totalSupply <= 0) 0
    else mulDivDown(totalBorrow * 10000, 1, totalSupply)

  /// Two-slope kinked borrow rate (Aave-style), returns rate in bps.
  pure def twoSlopeRate(
    utilBps: int, baseBps: int, slope1Bps: int, slope2Bps: int, kinkBps: int
  ): int =
    if (utilBps <= kinkBps)
      baseBps + mulDivDown(slope1Bps * utilBps, 1, max(kinkBps, 1))
    else
      baseBps + slope1Bps + mulDivDown(slope2Bps * (utilBps - kinkBps), 1, max(10000 - kinkBps, 1))

  // ---------------------------------------------------------------------------
  // Candidate primitive: NET_DELTA_SETTLEMENT (v4 / Infinity flash accounting)
  // Unlock scope: signed currency deltas must net to zero before lock release.
  // ---------------------------------------------------------------------------

  pure def deltasNetZero(d0: int, d1: int): bool = d0 == 0 and d1 == 0
}
