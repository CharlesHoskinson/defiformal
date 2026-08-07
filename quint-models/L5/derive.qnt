// Derive (Lyra v2) — cash-margined European options with portfolio settlement.
// Sources:
//   derivexyz_v2-core/src/assets/CashAsset.sol deposit (L155), withdraw (L203)
//   derivexyz_v2-core/src/assets/OptionAsset.sol
//     calcSettlementValue / _getSettlementValue (L124-158)
//   derivexyz_v2-core/src/feeds/LyraForwardFeed.sol
//     SETTLEMENT_TWAP_DURATION = 30 minutes (L28)
//   risk-managers/BaseManager.sol settleOptions path (L358)
//   liquidation/DutchAuction.sol — solvent/insolvent phases; SM + socialize
//   SecurityModule.sol — owner-funded treasury (no stake/slash)
// Scope: one account, one option instrument, cash collateral, European cash settle.
// NOT covered: full PMRM scenario matrix, OI fees, perps, multi-asset portfolio,
//   dutch auction price path detail, subaccount NFT ownership.

module derive {
  import common.* from "./common"

  pure val STRIKES: Set[int] = Set(100, 110, 90)
  pure val SIZES: Set[int] = Set(1, 2)
  pure val SPOTS: Set[int] = Set(80, 100, 120)
  pure val CASH_AMTS: Set[int] = Set(10, 20, 50)
  pure val MAINT_PER_SHORT: int = 15   // abstract maintenance per short unit

  type OptKind = Call | Put
  type PosPhase = None | Open | Settled

  type OptionPos = {
    phase: PosPhase,
    isCall: bool,
    strike: int,
    size: int,        // >0 long, <0 short (abstracted: we use signed via isLong)
    isLong: bool,
    settledPayout: int,
  }

  pure def emptyOpt: OptionPos =
    { phase: None, isCall: true, strike: 0, size: 0, isLong: true, settledPayout: 0 }

  var account: MarginAccount
  var option: OptionPos
  var spot: int              // mark / settlement index
  var settlementPrice: int   // locked TWAP at expiry; 0 if not settled
  var expired: bool
  var securityModule: int    // SM cash that can cover insolvent deficit
  var cashSupply: int        // total cash units in system (account + SM + socialized)

  action init: bool = all {
    account' = { cash: 0, mtm: 0, maintenance: 0 },
    option' = emptyOpt,
    spot' = 100,
    settlementPrice' = 0,
    expired' = false,
    securityModule' = 50,
    cashSupply' = 50,
  }

  /// CashAsset.deposit
  action deposit(amt: int): bool = all {
    CASH_AMTS.contains(amt),
    canDepositCash(amt),
    account' = applyDepositCash(account, amt),
    cashSupply' = cashSupply + amt,
    option' = option,
    spot' = spot,
    settlementPrice' = settlementPrice,
    expired' = expired,
    securityModule' = securityModule,
  }

  /// CashAsset.withdraw — blocked if post-withdraw insolvent.
  action withdraw(amt: int): bool = all {
    CASH_AMTS.contains(amt),
    canWithdrawCash(account, amt),
    account' = applyWithdrawCash(account, amt),
    cashSupply' = cashSupply - amt,
    option' = option,
    spot' = spot,
    settlementPrice' = settlementPrice,
    expired' = expired,
    securityModule' = securityModule,
  }

  /// Open a long or short option (matching is off-chain; settlement on-chain).
  /// Premium paid upfront from cash for longs; short receives premium.
  action openOption(isCall: bool, strike: int, qty: int, isLong: bool, premium: int): bool = {
    val newMaint = if (isLong) 0 else qty * MAINT_PER_SHORT
    val cashAfter = if (isLong) account.cash - premium else account.cash + premium
    val newAcc = { cash: cashAfter, mtm: 0, maintenance: newMaint }
    all {
      option.phase == None,
      not(expired),
      STRIKES.contains(strike),
      SIZES.contains(qty),
      CASH_AMTS.contains(premium),
      premium > 0,
      cashAfter >= 0,
      isMarginSolvent(newAcc),
      account' = newAcc,
      option' = {
        phase: Open,
        isCall: isCall,
        strike: strike,
        size: qty,
        isLong: isLong,
        settledPayout: 0,
      },
      spot' = spot,
      settlementPrice' = settlementPrice,
      expired' = expired,
      securityModule' = securityModule,
      cashSupply' = cashSupply, // premium is internal transfer (peer is off-model)
    }
  }

  /// Mark price update (feed). MTM ≈ intrinsic as simplified mark.
  action updateMark(s: int): bool = {
    val intrinsic = if (option.phase == Open)
      europeanPayoff(option.isCall, s, option.strike, option.size)
    else 0
    val mtm = if (option.phase != Open) 0
              else if (option.isLong) intrinsic else -intrinsic
    all {
      SPOTS.contains(s),
      spot' = s,
      account' = { ...account, mtm: mtm },
      option' = option,
      settlementPrice' = settlementPrice,
      expired' = expired,
      securityModule' = securityModule,
      cashSupply' = cashSupply,
    }
  }

  /// Lock settlement TWAP and expire (LyraForwardFeed SETTLEMENT_TWAP path).
  action expire(s: int): bool = all {
    SPOTS.contains(s),
    option.phase == Open,
    not(expired),
    expired' = true,
    settlementPrice' = s,
    spot' = s,
    account' = account,
    option' = option,
    securityModule' = securityModule,
    cashSupply' = cashSupply,
  }

  /// BaseManager.settleOptions → OptionAsset.calcSettlementValue
  action settle(): bool = {
    val unit = europeanPayoff(option.isCall, settlementPrice, option.strike, option.size)
    val payout = if (option.isLong) unit else -unit
    val newCash = account.cash + payout
    val deficit = if (newCash < 0) -newCash else 0
    all {
      option.phase == Open,
      expired,
      settlementPrice > 0,
      // long payout comes from short (off-model) or from SM if short under water
      option' = { ...option, phase: Settled, settledPayout: payout },
      account' = { cash: max(0, newCash), mtm: 0, maintenance: 0 },
      // if short cannot pay, SM covers deficit
      securityModule' = securityModule - deficit,
      cashSupply' = cashSupply, // conservation across account + SM
      spot' = spot,
      settlementPrice' = settlementPrice,
      expired' = expired,
    }
  }

  /// Insolvent auction residual: socialize by reducing cash supply (CashAsset exchange rate).
  /// Models temporaryWithdrawFeeEnabled haircut path at a high level.
  action socialize(loss: int): bool = all {
    CASH_AMTS.contains(loss),
    loss > 0,
    securityModule == 0,
    cashSupply >= loss,
    cashSupply' = cashSupply - loss,
    // haircut account cash pro-rata abstractly
    account' = { ...account, cash: max(0, account.cash - loss) },
    option' = option,
    spot' = spot,
    settlementPrice' = settlementPrice,
    expired' = expired,
    securityModule' = securityModule,
  }

  action step: bool = any {
    nondet a = CASH_AMTS.oneOf()
    deposit(a),
    nondet w = CASH_AMTS.oneOf()
    withdraw(w),
    // long call
    nondet k = STRIKES.oneOf()
    nondet sz = SIZES.oneOf()
    nondet pr = CASH_AMTS.oneOf()
    openOption(true, k, sz, true, pr),
    // short put
    nondet k2 = STRIKES.oneOf()
    nondet sz2 = SIZES.oneOf()
    nondet pr2 = CASH_AMTS.oneOf()
    openOption(false, k2, sz2, false, pr2),
    nondet s = SPOTS.oneOf()
    updateMark(s),
    nondet s2 = SPOTS.oneOf()
    expire(s2),
    settle,
    nondet l = CASH_AMTS.oneOf()
    socialize(l),
  }

  /// Account cash + SM + (if open short, ignore) — simplified global non-neg.
  val cashNonNeg: bool =
    account.cash >= 0 and securityModule >= 0 and cashSupply >= 0

  /// After settle, option is Settled and maintenance is zero.
  /// While open and not expired, short accounts must meet maintenance at last mark.
  val marginSafety: bool =
    if (option.phase == Open and not(expired))
      isMarginSolvent(account)
    else
      account.maintenance == 0 or option.phase != Settled or account.maintenance == 0

  /// Settlement payoff matches European formula when Settled.
  val settlementCorrect: bool =
    if (option.phase == Settled)
      option.settledPayout
        == (if (option.isLong)
              europeanPayoff(option.isCall, settlementPrice, option.strike, option.size)
            else
              -europeanPayoff(option.isCall, settlementPrice, option.strike, option.size))
    else true
}
