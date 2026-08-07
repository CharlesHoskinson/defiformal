// L5 shared primitives — empirical recurrences across tokenised RWA + options.
// Factored from Ondo RWAHub, Centrifuge AsyncRequestManager, Hegic OperationalTreasury,
// Derive OptionAsset/CashAsset/PMRM, Panoptic CollateralTracker/RiskEngine.
// Every definition here is instantiated by at least two protocol modules or is the
// pure building block of one that is.

module common {

  // ---------------------------------------------------------------------------
  // Arithmetic helpers
  // ---------------------------------------------------------------------------

  pure def min(a: int, b: int): int = if (a < b) a else b
  pure def max(a: int, b: int): int = if (a > b) a else b

  pure def mulDivDown(a: int, b: int, d: int): int =
    if (d <= 0) 0 else (a * b) / d

  pure def mulDivUp(a: int, b: int, d: int): int =
    if (d <= 0) 0 else (a * b + d - 1) / d

  pure def mapSum(m: int -> int, ks: Set[int]): int =
    ks.fold(0, (acc, k) => acc + m.get(k))

  pure def nonNegMap(m: int -> int, ks: Set[int]): bool =
    ks.forall(k => m.get(k) >= 0)

  // ---------------------------------------------------------------------------
  // Candidate primitive: NAV_PRICE_EXCHANGE
  // Ondo RWAHub: rwaOwed = deposit * 1e18 / price  (_getMintAmountForPrice L689)
  //              collateral = rwa * price / 1e18   (_getRedemptionAmountForRwa L705)
  // Centrifuge: assetToShareAmount via pricePoolPerShare (PricingLib / convertToShares)
  // USYC/BUIDL profiles: same shape — share count = cash / NAV; cash = shares * NAV
  // Value accrues in the *price*, not the balance (except BUIDL yield-via-mint).
  // Differs by: who sets price (admin vs oracle aggregator), bid/ask asymmetry.
  // ---------------------------------------------------------------------------

  /// Mint shares against a posted NAV price. scale is abstract 1e18 stand-in.
  pure def sharesFromNav(assets: int, price: int, scale: int): int =
    if (price <= 0) 0 else mulDivDown(assets, scale, price)

  /// Redeem assets from shares at a posted NAV price.
  pure def assetsFromNav(shares: int, price: int, scale: int): int =
    mulDivDown(shares, price, scale)

  /// Round-trip floor: redeem(mint(a)) <= a when price, scale fixed.
  pure def navRoundTripLeq(assets: int, price: int, scale: int): bool = {
    val sh = sharesFromNav(assets, price, scale)
    assetsFromNav(sh, price, scale) <= assets
  }

  // ---------------------------------------------------------------------------
  // Candidate primitive: ASYNC_REQUEST_CLAIM
  // Ondo: requestSubscription → setPriceIdForDeposits → claimMint
  //       requestRedemption  → setPriceIdForRedemptions → claimRedemption
  //       (RWAHub.sol:141,239,193,262,355,380)
  // Centrifuge: requestDeposit → fulfillDepositRequest → deposit/mint claim
  //             requestRedeem  → fulfillRedeemRequest  → redeem/withdraw
  //             (AsyncRequestManager.sol:84,112,281,313,361,414)
  // Maple profile: deposit instant; redeem via FIFO queue (Wq) — different.
  // Status: Empty | Pending | Priced | Claimable (Centrifuge merges Priced+Claimable)
  // ---------------------------------------------------------------------------

  type ReqPhase = Empty | Pending | Priced | Claimed

  type AsyncRequest = {
    owner: int,
    amount: int,       // assets in for deposit; shares in for redeem
    price: int,        // 0 until admin/issuer prices it
    phase: ReqPhase,
  }

  pure def emptyAsyncReq: AsyncRequest =
    { owner: 0, amount: 0, price: 0, phase: Empty }

  pure def canRequest(amount: int): bool = amount > 0

  pure def applyRequest(owner: int, amount: int): AsyncRequest =
    { owner: owner, amount: amount, price: 0, phase: Pending }

  pure def canPrice(r: AsyncRequest, price: int): bool =
    r.phase == Pending and price > 0

  pure def applyPrice(r: AsyncRequest, price: int): AsyncRequest =
    { ...r, price: price, phase: Priced }

  pure def canClaim(r: AsyncRequest): bool =
    r.phase == Priced and r.price > 0 and r.amount > 0

  pure def applyClaim(r: AsyncRequest): AsyncRequest =
    { ...r, phase: Claimed }

  // ---------------------------------------------------------------------------
  // Candidate primitive: ADMIN_POSTED_PRICE
  // Centrifuge Spoke.pricePoolPerShare — hub posts; spokes copy via message
  // Ondo Pricer / PRICE_ID_SETTER_ROLE — discrete price IDs, not continuous feed
  // USYC profile: once-per-business-day NAV behind AggregatorV3Interface
  // BUIDL profile: no on-chain price at all (par assumed) — degenerate case
  // No dispute window, challenge bond, or deviation bound in any of the three.
  // ---------------------------------------------------------------------------

  type PostedPrice = {
    value: int,
    updatedAt: int,   // abstract round/epoch, not wall clock
  }

  pure def canPostPrice(p: int): bool = p > 0

  pure def applyPostPrice(old: PostedPrice, p: int, t: int): PostedPrice =
    { value: p, updatedAt: t }

  // ---------------------------------------------------------------------------
  // Candidate primitive: FULLY_RESERVED_WRITE
  // Hegic OperationalTreasury._lockLiquidity (L101-133):
  //   totalLocked += negativePNL; require totalLocked+lockedPremium <= bal+cover
  // Rysk profile: seller escrows max payoff at trade (underlying or strike*size)
  // Solvency discharged *by construction* — no margin call path exists.
  // Differs by: peer-to-pool (Hegic treasury) vs bilateral escrow (Rysk).
  // ---------------------------------------------------------------------------

  type ReservedBook = {
    totalLocked: int,     // sum of max-loss reservations
    lockedPremium: int,   // premiums held against open positions
    balance: int,         // treasury / pool token balance
    coverAvailable: int,  // first-loss / cover pool drawable
  }

  pure def emptyReserved: ReservedBook =
    { totalLocked: 0, lockedPremium: 0, balance: 0, coverAvailable: 0 }

  pure def capacity(b: ReservedBook): int =
    b.balance + b.coverAvailable

  pure def canReserve(b: ReservedBook, maxLoss: int, premium: int): bool =
    and {
      maxLoss > 0,
      premium >= 0,
      b.totalLocked + maxLoss + b.lockedPremium + premium <= capacity(b) + premium,
    }

  /// Lock max-loss reservation and take premium into the book.
  pure def applyReserve(b: ReservedBook, maxLoss: int, premium: int): ReservedBook = {
    totalLocked: b.totalLocked + maxLoss,
    lockedPremium: b.lockedPremium + premium,
    balance: b.balance + premium,
    coverAvailable: b.coverAvailable,
  }

  pure def canRelease(b: ReservedBook, maxLoss: int, premium: int): bool =
    and {
      maxLoss >= 0,
      premium >= 0,
      b.totalLocked >= maxLoss,
      b.lockedPremium >= premium,
    }

  pure def applyRelease(b: ReservedBook, maxLoss: int, premium: int): ReservedBook = {
    totalLocked: b.totalLocked - maxLoss,
    lockedPremium: b.lockedPremium - premium,
    balance: b.balance,
    coverAvailable: b.coverAvailable,
  }

  /// Pay a claim out of balance, optionally drawing cover.
  pure def applyPayClaim(b: ReservedBook, amount: int): ReservedBook = {
    val fromBal = min(b.balance, amount)
    val fromCover = amount - fromBal
    {
      totalLocked: b.totalLocked,
      lockedPremium: b.lockedPremium,
      balance: b.balance - fromBal,
      coverAvailable: b.coverAvailable - fromCover,
    }
  }

  pure def reservedSolvent(b: ReservedBook): bool =
    and {
      b.totalLocked >= 0,
      b.lockedPremium >= 0,
      b.balance >= 0,
      b.coverAvailable >= 0,
      b.totalLocked + b.lockedPremium <= capacity(b) or b.totalLocked == 0,
    }

  // ---------------------------------------------------------------------------
  // Candidate primitive: CASH_SETTLED_EUROPEAN
  // Derive OptionAsset._getSettlementValue (L141-158):
  //   call ITM: (S - K) * balance; put ITM: (K - S) * balance; else 0
  // Aevo profile: same cash difference vs index at 08:00 UTC
  // Hegic payOffAmount is strategy-specific but still cash USDC, not delivery.
  // Differs by: settlement price source (TWAP vs spot vs admin vol model).
  // ---------------------------------------------------------------------------

  pure def callPayoff(spot: int, strike: int, qty: int): int =
    if (spot > strike) mulDivDown(spot - strike, qty, 1) else 0

  pure def putPayoff(spot: int, strike: int, qty: int): int =
    if (strike > spot) mulDivDown(strike - spot, qty, 1) else 0

  pure def europeanPayoff(isCall: bool, spot: int, strike: int, qty: int): int =
    if (isCall) callPayoff(spot, strike, qty) else putPayoff(spot, strike, qty)

  /// Long receives +payoff; short pays -payoff. signedQty: >0 long, <0 short.
  pure def signedSettlement(isCall: bool, spot: int, strike: int, signedQty: int): int = {
    val absQty = if (signedQty >= 0) signedQty else -signedQty
    val unit = europeanPayoff(isCall, spot, strike, absQty)
    if (signedQty >= 0) unit else -unit
  }

  // ---------------------------------------------------------------------------
  // Candidate primitive: PORTFOLIO_CASH_MARGIN
  // Derive: CashAsset deposit/withdraw + manager handleAdjustment margin check
  //         PMRM/StandardManager: portfolio MTM + scenario maxLoss vs cash
  // Aevo profile: Scenario Margin + Floor Margin under Portfolio Margin
  // Simplified here to: cash + mtm >= maintenance (scenario engine is external).
  // Differs by: scenario families, oracle contingency, OI caps.
  // ---------------------------------------------------------------------------

  type MarginAccount = {
    cash: int,
    mtm: int,           // mark-to-market of open derivatives (can be negative)
    maintenance: int,   // required maintenance margin (>= 0)
  }

  pure def equity(a: MarginAccount): int = a.cash + a.mtm

  pure def isMarginSolvent(a: MarginAccount): bool =
    equity(a) >= a.maintenance

  pure def canDepositCash(amt: int): bool = amt > 0

  pure def applyDepositCash(a: MarginAccount, amt: int): MarginAccount =
    { ...a, cash: a.cash + amt }

  pure def canWithdrawCash(a: MarginAccount, amt: int): bool =
    and {
      amt > 0,
      a.cash >= amt,
      // post-withdraw solvency
      (a.cash - amt) + a.mtm >= a.maintenance,
    }

  pure def applyWithdrawCash(a: MarginAccount, amt: int): MarginAccount =
    { ...a, cash: a.cash - amt }

  // ---------------------------------------------------------------------------
  // Candidate primitive: UTILIZATION_COLLATERAL
  // Panoptic RiskEngine: collateral requirements scale with pool utilisation
  //   up to SATURATED_POOL_UTIL; buyer up to 10x, seller 5x under normal util
  // Hegic: utilisation is implicit (totalLocked / capacity) and gates *writes*
  // Distinct: Panoptic re-prices *open* margin; Hegic only gates new writes.
  // ---------------------------------------------------------------------------

  pure def utilization(used: int, total: int): int =
    if (total <= 0) 0 else mulDivDown(used, 100, total)

  /// Simple linear collateral requirement: base + util/k (abstract).
  pure def utilCollateralReq(notional: int, utilPct: int, baseBps: int, utilBps: int): int =
    mulDivDown(notional, baseBps + mulDivDown(utilPct * utilBps, 100, 1), 10000)

  // ---------------------------------------------------------------------------
  // Candidate primitive: SHARE_SUPPLY_LEDGER
  // Ondo/Centrifuge/USYC/Maple/Panoptic CollateralTracker: totalSupply of shares
  // Conservation: mint increases, burn decreases; never negative.
  // ---------------------------------------------------------------------------

  pure def canMintSupply(totalSupply: int, amt: int): bool =
    amt > 0

  pure def applyMintSupply(totalSupply: int, amt: int): int =
    totalSupply + amt

  pure def canBurnSupply(totalSupply: int, amt: int): bool =
    amt > 0 and totalSupply >= amt

  pure def applyBurnSupply(totalSupply: int, amt: int): int =
    totalSupply - amt
}
