// L3 shared primitives — empirical factorings from perp + yield protocols.
// Every definition here is instantiated by ≥2 protocols in this lane, or is the
// candidate primitive the ledger records as recurring.

module common {

  // ---------- arithmetic helpers (integer, no reals) ----------

  pure def min(a: int, b: int): int = if (a < b) a else b
  pure def max(a: int, b: int): int = if (a > b) a else b
  pure def abs(x: int): int = if (x >= 0) x else (0 - x)

  // Floor division, non-negative numerators/denominators only in callers.
  pure def divFloor(a: int, b: int): int =
    if (b <= 0) 0 else a / b

  // ---------- ShareVault: pro-rata claim (Yearn, Beefy, Convex pool, Huma tranche) ----------
  // Code: Yearn VaultV3._convert_to_shares/assets; BeefyVaultV6 deposit/withdraw;
  //       Convex Booster deposit (1:1 receipt); Huma TrancheVault convertToShares.

  type ShareVault = {
    totalAssets: int,
    totalShares: int,
  }

  pure def emptyShareVault: ShareVault = { totalAssets: 0, totalShares: 0 }

  // shares = assets * totalShares / totalAssets  (or assets if empty)
  pure def assetsToShares(v: ShareVault, assets: int): int =
    if (assets <= 0) 0
    else if (v.totalShares == 0 or v.totalAssets == 0) assets
    else divFloor(assets * v.totalShares, v.totalAssets)

  pure def sharesToAssets(v: ShareVault, shares: int): int =
    if (shares <= 0) 0
    else if (v.totalShares == 0) 0
    else divFloor(shares * v.totalAssets, v.totalShares)

  pure def canDeposit(v: ShareVault, assets: int): bool = assets > 0

  pure def applyDeposit(v: ShareVault, assets: int): ShareVault = {
    val s = assetsToShares(v, assets)
    { totalAssets: v.totalAssets + assets, totalShares: v.totalShares + s }
  }

  pure def canRedeem(v: ShareVault, shares: int): bool =
    shares > 0 and shares <= v.totalShares

  pure def applyRedeem(v: ShareVault, shares: int): ShareVault = {
    val a = sharesToAssets(v, shares)
    { totalAssets: v.totalAssets - a, totalShares: v.totalShares - shares }
  }

  // Conservation: assets mapped through shares round-trip within 1 unit of dust.
  pure def shareSolvency(v: ShareVault): bool =
    v.totalAssets >= 0 and v.totalShares >= 0 and
    (v.totalShares == 0 implies v.totalAssets == 0)

  // ---------- AccrualIndex: monotonic high-water exchange rate (Pendle pyIndex, Convex rpt) ----------
  // Code: PendleYieldToken._pyIndexCurrent max(SY.exchangeRate, stored);
  //       BaseRewardPool.rewardPerTokenStored += rate * dt / supply.

  type AccrualIndex = {
    stored: int,     // last committed index (scaled, e.g. 1e18 = 1.0)
    lastTime: int,
  }

  pure def initIndex(scale: int): AccrualIndex = { stored: scale, lastTime: 0 }

  // Ratchet: index never falls (Pendle HWM). newRate is the source exchange rate.
  pure def ratchetIndex(ix: AccrualIndex, newRate: int, now: int): AccrualIndex =
    { stored: max(ix.stored, newRate), lastTime: now }

  // Streaming accrual: add (rate * elapsed) / supply units (Convex-style reward index).
  pure def streamIndex(ix: AccrualIndex, rate: int, supply: int, now: int): AccrualIndex = {
    val elapsed = max(0, now - ix.lastTime)
    val delta =
      if (supply <= 0 or rate <= 0 or elapsed == 0) 0
      else divFloor(rate * elapsed, supply)
    { stored: ix.stored + delta, lastTime: now }
  }

  pure def indexMonotone(before: AccrualIndex, after: AccrualIndex): bool =
    after.stored >= before.stored

  // ---------- MarginPosition: signed size + collateral (ApeX, GMX) ----------
  // Code: IMargin.Position {quoteSize, baseSize, tradeSize};
  //       GMX Position.Props {sizeInUsd, collateralAmount, isLong}.

  type Side = Long | Short | Flat

  type MarginPosition = {
    posSize: int,      // notional / quote size (always >= 0)
    collateral: int,   // margin posted (always >= 0)
    side: Side,
    entryNotional: int // cost basis for unrealized PnL (tradeSize / sizeInTokens equiv)
  }

  pure def emptyPosition: MarginPosition =
    { posSize: 0, collateral: 0, side: Flat, entryNotional: 0 }

  // Mark-to-market value of size at price (price in same unit as collateral).
  pure def positionValue(p: MarginPosition, price: int): int =
    if (p.side == Flat) 0 else p.posSize * price

  // Unrealized PnL: long = mark - entry; short = entry - mark.
  pure def unrealizedPnl(p: MarginPosition, price: int): int =
    if (p.side == Flat or p.posSize == 0) 0
    else if (p.side == Long) positionValue(p, price) - p.entryNotional
    else p.entryNotional - positionValue(p, price)

  pure def equity(p: MarginPosition, price: int): int =
    p.collateral + unrealizedPnl(p, price)

  // Maintenance: equity * ratio >= size * price  (ratio as percent, e.g. 5 means 5%).
  pure def maintainsMargin(p: MarginPosition, price: int, maintBps: int): bool =
    if (p.side == Flat or p.posSize == 0) true
    else equity(p, price) * 10000 >= p.posSize * price * maintBps

  pure def canLiquidate(p: MarginPosition, price: int, maintBps: int): bool =
    p.side != Flat and p.posSize > 0 and not(maintainsMargin(p, price, maintBps))

  // ---------- FundingTransfer: long/short continuous payment (ApeX CPF, GMX funding) ----------
  // Code: Margin.updateCPF / calFundingFee; GMX fundingFeeAmountPerSize.

  type FundingState = {
    cumulative: int,   // cumulative premium factor (signed)
    lastTime: int,
  }

  pure def initFunding: FundingState = { cumulative: 0, lastTime: 0 }

  // ratePerTime is signed: positive means longs pay shorts.
  pure def advanceFunding(f: FundingState, ratePerTime: int, now: int): FundingState = {
    val elapsed = max(0, now - f.lastTime)
    { cumulative: f.cumulative + ratePerTime * elapsed, lastTime: now }
  }

  // Funding owed by position since checkpoint (positive = trader pays).
  pure def fundingOwed(cumNow: int, cumCheckpoint: int, posSize: int, side: Side): int = {
    val delta = cumNow - cumCheckpoint
    if (side == Long) posSize * delta
    else if (side == Short) 0 - posSize * delta
    else 0
  }

  // ---------- WithdrawalQueue / delayed exit (Hyperliquid Bridge, Lighter priority, Huma epoch) ----------

  type QueueItem = {
    owner: int,
    amount: int,
    readyAt: int,   // time or epoch when claimable
  }

  pure def queueSum(q: List[QueueItem]): int =
    q.foldl(0, (acc, it) => acc + it.amount)

  pure def canEnqueue(amount: int): bool = amount > 0

  pure def enqueue(q: List[QueueItem], owner: int, amount: int, readyAt: int): List[QueueItem] =
    q.append({ owner: owner, amount: amount, readyAt: readyAt })

  pure def headReady(q: List[QueueItem], now: int): bool =
    q.length() > 0 and q.head().readyAt <= now

  // ---------- RateLimit envelope (Spark ALM RateLimits.sol) ----------
  // current = min(maxAmount, lastAmount + slope * (now - lastUpdated))

  type RateLimit = {
    maxAmount: int,
    slope: int,
    lastAmount: int,
    lastUpdated: int,
  }

  pure def currentLimit(rl: RateLimit, now: int): int = {
    val elapsed = max(0, now - rl.lastUpdated)
    min(rl.maxAmount, rl.lastAmount + rl.slope * elapsed)
  }

  pure def canConsume(rl: RateLimit, amount: int, now: int): bool =
    amount > 0 and amount <= currentLimit(rl, now)

  pure def consume(rl: RateLimit, amount: int, now: int): RateLimit = {
    val cur = currentLimit(rl, now)
    { maxAmount: rl.maxAmount, slope: rl.slope,
      lastAmount: cur - amount, lastUpdated: now }
  }

  // ---------- Tranche waterfall (Huma Pool._distributeLoss) ----------
  // Loss hits junior first, then senior. Recovery reverse.

  type Tranches = {
    senior: int,
    junior: int,
  }

  pure def totalTranche(t: Tranches): int = t.senior + t.junior

  pure def applyLoss(t: Tranches, loss: int): Tranches = {
    val toJunior = min(t.junior, loss)
    val rem = loss - toJunior
    val toSenior = min(t.senior, rem)
    { senior: t.senior - toSenior, junior: t.junior - toJunior }
  }

  pure def applyProfit(t: Tranches, profit: int, seniorShareBps: int): Tranches = {
    val toSenior = divFloor(profit * seniorShareBps, 10000)
    { senior: t.senior + toSenior, junior: t.junior + (profit - toSenior) }
  }

  pure def seniorFirstRedeem(t: Tranches, seniorReq: int, juniorReq: int, available: int)
    : (Tranches, int, int) = {
    val fillS = min(seniorReq, available)
    val rem = available - fillS
    val fillJ = min(juniorReq, rem)
    ({ senior: t.senior - fillS, junior: t.junior - fillJ }, fillS, fillJ)
  }

  // ---------- PT/YT principal-yield split (Pendle) ----------
  // mint: SY in → equal PT and YT out, sized by asset = SY * index / scale
  // redeem (pre-expiry): burn equal PT+YT → SY out

  pure def syToAsset(sy: int, index: int, scale: int): int =
    if (scale <= 0) 0 else divFloor(sy * index, scale)

  pure def assetToSy(asset: int, index: int, scale: int): int =
    if (index <= 0) 0 else divFloor(asset * scale, index)

  pure def mintPyAmount(syIn: int, index: int, scale: int): int =
    syToAsset(syIn, index, scale)

  pure def redeemSyFromPy(py: int, index: int, scale: int): int =
    assetToSy(py, index, scale)

  // Conservation at mint: SY locked covers PT notional at current index.
  pure def pyBackingHolds(syLocked: int, ptSupply: int, ytSupply: int, index: int, scale: int): bool =
    ptSupply == ytSupply and syToAsset(syLocked, index, scale) >= ptSupply
}
