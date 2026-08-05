// L2 shared primitives — empirical recurrences across CDP + liquid staking / restaking.
// Source: factored from Liquity, crvUSD, Sky sDAI, Lido, EigenLayer, ether.fi, Babylon.
// Every definition here appears in at least two protocol specs (or is a pure building block
// of one that does).

module common {

  // ---------------------------------------------------------------------------
  // Fixed-point scales (abstracted to small ints for simulation)
  // ---------------------------------------------------------------------------

  /// Unit scale for rates / ICR (stand-in for 1e18 WAD).
  pure val WAD: int = 1000

  /// Ray scale for continuous rate accumulators (stand-in for 1e27 RAY).
  pure val RAY: int = 1000000

  /// Basis points denominator.
  pure val BPS: int = 10000

  // ---------------------------------------------------------------------------
  // Share ↔ asset conversion (ERC-4626 / stETH / eETH / StrategyBase shape)
  // ---------------------------------------------------------------------------
  // Instantiated by: Lido, ether.fi, EigenLayer StrategyBase, Sky sDAI.
  // Differs by: empty-pool bootstrap, virtual offsets, rounding direction.

  /// shares = assets * totalShares / totalAssets  (floor)
  pure def assetsToShares(assets: int, totalAssets: int, totalShares: int): int =
    if (totalAssets == 0 or totalShares == 0) assets
    else (assets * totalShares) / totalAssets

  /// assets = shares * totalAssets / totalShares  (floor)
  pure def sharesToAssets(shares: int, totalAssets: int, totalShares: int): int =
    if (totalShares == 0) 0
    else (shares * totalAssets) / totalShares

  /// Ceiling division for protocol-favouring withdrawal share burn.
  pure def ceilDiv(a: int, b: int): int =
    if (b == 0) 0 else (a + b - 1) / b

  /// shares = ceil(assets * totalShares / totalAssets)
  pure def assetsToSharesCeil(assets: int, totalAssets: int, totalShares: int): int =
    if (totalAssets == 0 or totalShares == 0) assets
    else ceilDiv(assets * totalShares, totalAssets)

  // ---------------------------------------------------------------------------
  // Index-based accrual (chi / rate_mul / exchange-rate scalar)
  // ---------------------------------------------------------------------------
  // Instantiated by: Sky pot.chi (sDAI), crvUSD loan.rate_mul, WBETH exchangeRate.
  // Differs by: who may write the index (protocol drip vs admin assert).

  /// Value of principal after index growth: principal * newIndex / oldIndex
  pure def accrueByIndex(principal: int, oldIndex: int, newIndex: int): int =
    if (oldIndex == 0) principal
    else (principal * newIndex) / oldIndex

  /// Mint shares against an index: shares = assets * SCALE / index
  pure def sharesFromIndex(assets: int, index: int, scale: int): int =
    if (index == 0) 0 else (assets * scale) / index

  /// Redeem assets from shares: assets = shares * index / SCALE
  pure def assetsFromIndex(shares: int, index: int, scale: int): int =
    (shares * index) / scale

  // ---------------------------------------------------------------------------
  // Collateralised debt position — health / ICR
  // ---------------------------------------------------------------------------
  // Instantiated by: Liquity (ICR), crvUSD (_health), Sky vat (implicit).
  // Differs by: liquidation path (hard vs soft/LLAMMA), who sets the rate.

  pure def collateralRatio(coll: int, debt: int, price: int): int =
    if (debt == 0) WAD * 100
    else (coll * price) / debt

  pure def isHealthy(coll: int, debt: int, price: int, threshold: int): bool =
    debt == 0 or collateralRatio(coll, debt, price) >= threshold

  pure def collValue(coll: int, price: int): int = coll * price / WAD

  // ---------------------------------------------------------------------------
  // Conservation helpers
  // ---------------------------------------------------------------------------

  pure def mapSum(m: int -> int, ks: Set[int]): int =
    ks.fold(0, (acc, k) => acc + m.get(k))

  pure def nonNegMap(m: int -> int, ks: Set[int]): bool =
    ks.forall(k => m.get(k) >= 0)

  // ---------------------------------------------------------------------------
  // Withdrawal queue entry (shared shape; finalisation differs)
  // ---------------------------------------------------------------------------
  // Instantiated by: Lido WithdrawalQueue, ether.fi WithdrawRequestNFT.
  // Differs by: rate freeze at finalise vs claim, operator allocation gate.

  type QueueEntry = {
    owner: int,
    shares: int,
    assetsAtRequest: int,
    finalized: bool,
    claimed: bool,
  }

  pure def emptyQueueEntry(owner: int): QueueEntry = {
    owner: owner,
    shares: 0,
    assetsAtRequest: 0,
    finalized: false,
    claimed: false,
  }
}
