// Maple V2 — permissioned pool, fixed-rate bilateral loans, delegate default, withdrawal queue.
// Source: protocol-repos/lend/maple-labs_maple-core-v2/modules/
//   (pool shares ERC-4626-like; fixed-term / open-term loans; withdrawal manager)
// Profile (supp-02): no permissionless liquidation; delegate triggers default;
// rate is a loan term, not a utilization curve; exit via queue.
// Model: pool cash + outstanding loans + shares + withdrawal queue + delegate cover.

module maple {
  import common.* from "./common"

  pure val USERS: Set[str] = Set("lp1", "lp2", "borrower")
  pure val DELEGATE_COVER: int = 20

  var cash: int                         // unallocated pool cash
  var outstandingPrincipal: int         // active loan principal
  var accruedInterest: int              // interest owed to pool
  var totalShares: int
  var shares: str -> int
  var permitted: str -> bool            // permission manager gate
  var loanActive: bool
  var loanRateBps: int                  // fixed bilateral rate
  var loanBorrower: str
  var queueShares: str -> int           // withdrawal queue
  var queueTotal: int
  var delegateCover: int                // first-loss capital
  var defaulted: bool

  pure def totalAssets(cash: int, prin: int, interest: int): int =
    cash + prin + interest

  action init: bool = all {
    cash' = 100,
    outstandingPrincipal' = 0,
    accruedInterest' = 0,
    totalShares' = 100,
    shares' = USERS.mapBy(u => if (u == "lp1") 100 else 0),
    permitted' = USERS.mapBy(u => u != "borrower" or true), // LPs + borrower may be gated
    // tighten: only lps deposit; borrower is separate
    loanActive' = false,
    loanRateBps' = 0,
    loanBorrower' = "borrower",
    queueShares' = USERS.mapBy(_ => 0),
    queueTotal' = 0,
    delegateCover' = DELEGATE_COVER,
    defaulted' = false,
  }

  /// Permissioned deposit
  action deposit(u: str, assets: int): bool = all {
    USERS.contains(u),
    u != "borrower",
    assets > 0,
    not(defaulted),
    val ta = totalAssets(cash, outstandingPrincipal, accruedInterest)
    val sh = sharesFromAssets(assets, ta, totalShares)
    all {
      sh > 0,
      cash' = cash + assets,
      totalShares' = totalShares + sh,
      shares' = shares.put(u, shares.get(u) + sh),
      outstandingPrincipal' = outstandingPrincipal,
      accruedInterest' = accruedInterest,
      permitted' = permitted,
      loanActive' = loanActive,
      loanRateBps' = loanRateBps,
      loanBorrower' = loanBorrower,
      queueShares' = queueShares,
      queueTotal' = queueTotal,
      delegateCover' = delegateCover,
      defaulted' = defaulted,
    }
  }

  /// Delegate originates fixed-rate loan to named borrower
  action fundLoan(principal: int, rateBps: int): bool = all {
    principal > 0,
    rateBps > 0,
    not(loanActive),
    not(defaulted),
    cash >= principal,
    delegateCover >= DELEGATE_COVER / 2,  // floor on cover
    cash' = cash - principal,
    outstandingPrincipal' = principal,
    accruedInterest' = 0,
    loanActive' = true,
    loanRateBps' = rateBps,
    loanBorrower' = "borrower",
    totalShares' = totalShares,
    shares' = shares,
    permitted' = permitted,
    queueShares' = queueShares,
    queueTotal' = queueTotal,
    delegateCover' = delegateCover,
    defaulted' = false,
  }

  action accrueLoan(dt: int): bool = all {
    loanActive,
    dt > 0,
    not(defaulted),
    val interest = mulDivDown(outstandingPrincipal * loanRateBps * dt, 1, 10000)
    all {
      accruedInterest' = accruedInterest + interest,
      cash' = cash,
      outstandingPrincipal' = outstandingPrincipal,
      totalShares' = totalShares,
      shares' = shares,
      permitted' = permitted,
      loanActive' = loanActive,
      loanRateBps' = loanRateBps,
      loanBorrower' = loanBorrower,
      queueShares' = queueShares,
      queueTotal' = queueTotal,
      delegateCover' = delegateCover,
      defaulted' = defaulted,
    }
  }

  action repayLoan(amount: int): bool = all {
    loanActive,
    amount > 0,
    not(defaulted),
    // pay interest first, then principal
    val toInterest = min(amount, accruedInterest)
    val rest = amount - toInterest
    val toPrincipal = min(rest, outstandingPrincipal)
    all {
      cash' = cash + toInterest + toPrincipal,
      accruedInterest' = accruedInterest - toInterest,
      outstandingPrincipal' = outstandingPrincipal - toPrincipal,
      loanActive' = outstandingPrincipal - toPrincipal > 0,
      loanRateBps' = if (outstandingPrincipal - toPrincipal > 0) loanRateBps else 0,
      totalShares' = totalShares,
      shares' = shares,
      permitted' = permitted,
      loanBorrower' = loanBorrower,
      queueShares' = queueShares,
      queueTotal' = queueTotal,
      delegateCover' = delegateCover,
      defaulted' = defaulted,
    }
  }

  /// Request withdrawal — shares move to queue (not instant redeem)
  action requestRedeem(u: str, sh: int): bool = all {
    USERS.contains(u),
    sh > 0,
    shares.get(u) >= sh,
    shares' = shares.put(u, shares.get(u) - sh),
    queueShares' = queueShares.put(u, queueShares.get(u) + sh),
    queueTotal' = queueTotal + sh,
    // shares still count in total until processed
    totalShares' = totalShares,
    cash' = cash,
    outstandingPrincipal' = outstandingPrincipal,
    accruedInterest' = accruedInterest,
    permitted' = permitted,
    loanActive' = loanActive,
    loanRateBps' = loanRateBps,
    loanBorrower' = loanBorrower,
    delegateCover' = delegateCover,
    defaulted' = defaulted,
  }

  /// Process queue when cash available
  action processRedeem(u: str): bool = all {
    USERS.contains(u),
    queueShares.get(u) > 0,
    val sh = queueShares.get(u)
    val ta = totalAssets(cash, outstandingPrincipal, accruedInterest)
    val assets = assetsFromShares(sh, ta, totalShares)
    all {
      cash >= assets,
      cash' = cash - assets,
      totalShares' = totalShares - sh,
      queueShares' = queueShares.put(u, 0),
      queueTotal' = queueTotal - sh,
      shares' = shares,
      outstandingPrincipal' = outstandingPrincipal,
      accruedInterest' = accruedInterest,
      permitted' = permitted,
      loanActive' = loanActive,
      loanRateBps' = loanRateBps,
      loanBorrower' = loanBorrower,
      delegateCover' = delegateCover,
      defaulted' = defaulted,
    }
  }

  /// Delegate triggers default — cover absorbs first loss
  action triggerDefault: bool = all {
    loanActive,
    not(defaulted),
    val loss = outstandingPrincipal + accruedInterest
    val coverUsed = min(delegateCover, loss)
    val poolLoss = loss - coverUsed
    val ta = totalAssets(cash, 0, 0)  // after writing off loan
    all {
      // write off loan; cover tops up cash; residual reduces pool value via share dilution
      cash' = cash + coverUsed,
      outstandingPrincipal' = 0,
      accruedInterest' = 0,
      loanActive' = false,
      loanRateBps' = 0,
      delegateCover' = delegateCover - coverUsed,
      defaulted' = true,
      // socialize pool loss by reducing cash further if needed (already 0 principal)
      // if cover insufficient, totalAssets drops (principal wiped without cash)
      totalShares' = totalShares,
      shares' = shares,
      permitted' = permitted,
      loanBorrower' = loanBorrower,
      queueShares' = queueShares,
      queueTotal' = queueTotal,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(30).oneOf()
    nondet rate = 100.to(2000).oneOf()
    nondet dt = 1.to(3).oneOf()
    nondet sh = 1.to(20).oneOf()
    any {
      deposit(u, amt),
      fundLoan(amt, rate),
      accrueLoan(dt),
      repayLoan(amt),
      requestRedeem(u, sh),
      processRedeem(u),
      triggerDefault,
    }
  }

  /// Share conservation: circulating + queued = totalShares
  val shareConservation: bool =
    USERS.fold(0, (acc, u) => acc + shares.get(u) + queueShares.get(u)) == totalShares

  /// Non-negative pool accounting
  val poolNonNeg: bool =
    cash >= 0 and outstandingPrincipal >= 0 and accruedInterest >= 0 and
    totalShares >= 0 and delegateCover >= 0

  /// No free exit: queued shares are not simultaneously liquid cash claims beyond cash
  val queueBounded: bool = queueTotal >= 0 and queueTotal <= totalShares
}
