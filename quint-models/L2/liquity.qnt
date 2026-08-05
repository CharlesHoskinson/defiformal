// Liquity V2 (BOLD) — core economic state machine.
// Sources:
//   liquity_bold/contracts/src/BorrowerOperations.sol  (openTrove, closeTrove, adjust)
//   liquity_bold/contracts/src/TroveManager.sol         (batchLiquidateTroves, redeemCollateral)
//   liquity_bold/contracts/src/Types/LatestTroveData.sol
//   liquity_bold/contracts/src/Dependencies/LiquityMath.sol (_computeCR)
//   liquity_bold/contracts/src/StabilityPool.sol
// Scope: single branch, hard liquidation via SP offset, borrower-chosen rate.
// NOT covered: SortedTroves, gas compensation, multi-collateral, branch shutdown, redistribution.

module liquity {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val MCR: int = 1100
  pure val CCR: int = 1500
  pure val MIN_DEBT: int = 10

  type Trove = {
    coll: int,
    debt: int,
    rate: int,
    active: bool,
  }

  pure def emptyTrove: Trove = { coll: 0, debt: 0, rate: 0, active: false }

  var troves: int -> Trove
  var boldSupply: int       // total BOLD = system debt
  var freeBold: int         // BOLD not in stability pool (user wallets aggregate)
  var spDeposits: int       // BOLD in stability pool
  var spColl: int
  var price: int
  var totalColl: int

  pure def icr(t: Trove, p: int): int =
    collateralRatio(t.coll, t.debt, p)

  pure def systemTCR(coll: int, debt: int, p: int): int =
    collateralRatio(coll, debt, p)

  pure def canOpen(collAmt: int, debtAmt: int, p: int, tcrColl: int, tcrDebt: int): bool =
    and {
      collAmt > 0,
      debtAmt >= MIN_DEBT,
      isHealthy(collAmt, debtAmt, p, MCR),
      systemTCR(tcrColl + collAmt, tcrDebt + debtAmt, p) >= CCR,
    }

  pure def isLiquidatable(t: Trove, p: int): bool =
    t.active and t.debt > 0 and icr(t, p) < MCR

  action init: bool = all {
    troves' = USERS.mapBy(_ => emptyTrove),
    boldSupply' = 0,
    freeBold' = 0,
    spDeposits' = 0,
    spColl' = 0,
    price' = 2000,
    totalColl' = 0,
  }

  /// openTrove — BorrowerOperations.sol:201
  action openTrove(u: int, collAmt: int, debtAmt: int, rate: int): bool = all {
    USERS.contains(u),
    not(troves.get(u).active),
    rate > 0,
    canOpen(collAmt, debtAmt, price, totalColl, boldSupply),
    troves' = troves.put(u, { coll: collAmt, debt: debtAmt, rate: rate, active: true }),
    boldSupply' = boldSupply + debtAmt,
    freeBold' = freeBold + debtAmt,
    totalColl' = totalColl + collAmt,
    spDeposits' = spDeposits,
    spColl' = spColl,
    price' = price,
  }

  /// closeTrove — BorrowerOperations.sol:682 — burns free BOLD
  action closeTrove(u: int): bool = {
    val t = troves.get(u)
    all {
      USERS.contains(u),
      t.active,
      freeBold >= t.debt,
      systemTCR(totalColl - t.coll, boldSupply - t.debt, price) >= CCR
        or boldSupply == t.debt,
      troves' = troves.put(u, emptyTrove),
      boldSupply' = boldSupply - t.debt,
      freeBold' = freeBold - t.debt,
      totalColl' = totalColl - t.coll,
      spDeposits' = spDeposits,
      spColl' = spColl,
      price' = price,
    }
  }

  /// provideToSP — move free BOLD into stability pool
  action provideToSP(amt: int): bool = all {
    amt > 0,
    freeBold >= amt,
    freeBold' = freeBold - amt,
    spDeposits' = spDeposits + amt,
    troves' = troves,
    boldSupply' = boldSupply,
    spColl' = spColl,
    price' = price,
    totalColl' = totalColl,
  }

  /// batchLiquidateTroves offset — TroveManager.sol:417
  action liquidateViaSP(u: int): bool = {
    val t = troves.get(u)
    all {
      USERS.contains(u),
      isLiquidatable(t, price),
      spDeposits >= t.debt,
      troves' = troves.put(u, emptyTrove),
      boldSupply' = boldSupply - t.debt,
      spDeposits' = spDeposits - t.debt,
      spColl' = spColl + t.coll,
      totalColl' = totalColl - t.coll,
      freeBold' = freeBold,
      price' = price,
    }
  }

  /// redeemCollateral — TroveManager.sol:747 — burns free BOLD for coll.
  /// Full-debt redeem leaves residual coll as surplus out of ActivePool
  /// (CollSurplusPool in the real system); we drop it from totalColl entirely.
  action redeem(u: int, boldAmt: int): bool = {
    val t = troves.get(u)
    val collOut = (boldAmt * WAD) / price
    val newDebt = t.debt - boldAmt
    val newColl = t.coll - collOut
    all {
      USERS.contains(u),
      boldAmt > 0,
      t.active,
      boldAmt <= t.debt,
      freeBold >= boldAmt,
      collOut <= t.coll,
      price > 0,
      if (newDebt == 0) all {
        // close trove: all remaining coll leaves ActivePool (surplus + redeemed)
        troves' = troves.put(u, emptyTrove),
        boldSupply' = boldSupply - boldAmt,
        freeBold' = freeBold - boldAmt,
        totalColl' = totalColl - t.coll,
        spDeposits' = spDeposits,
        spColl' = spColl,
        price' = price,
      } else all {
        troves' = troves.put(u, { coll: newColl, debt: newDebt, rate: t.rate, active: true }),
        boldSupply' = boldSupply - boldAmt,
        freeBold' = freeBold - boldAmt,
        totalColl' = totalColl - collOut,
        spDeposits' = spDeposits,
        spColl' = spColl,
        price' = price,
      },
    }
  }

  action setPrice(p: int): bool = all {
    p > 0,
    p <= 10000,
    price' = p,
    troves' = troves,
    boldSupply' = boldSupply,
    freeBold' = freeBold,
    spDeposits' = spDeposits,
    spColl' = spColl,
    totalColl' = totalColl,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet collAmt = 1.to(50).oneOf()
    nondet debtAmt = 10.to(40).oneOf()
    nondet rate = 1.to(20).oneOf()
    nondet amt = 1.to(20).oneOf()
    nondet p = 500.to(3000).oneOf()
    any {
      openTrove(u, collAmt, debtAmt, rate),
      closeTrove(u),
      provideToSP(amt),
      liquidateViaSP(u),
      redeem(u, amt),
      setPrice(p),
    }
  }

  /// Debt conservation: sum trove debts == boldSupply
  val debtConservation: bool =
    mapSum(USERS.mapBy(u => troves.get(u).debt), USERS) == boldSupply

  /// BOLD partition: free + SP == supply
  val boldPartition: bool =
    freeBold + spDeposits == boldSupply

  val collConservation: bool =
    mapSum(USERS.mapBy(u => troves.get(u).coll), USERS) == totalColl

  val nonNegative: bool = and {
    boldSupply >= 0,
    freeBold >= 0,
    spDeposits >= 0,
    spColl >= 0,
    totalColl >= 0,
    nonNegMap(USERS.mapBy(u => troves.get(u).coll), USERS),
    nonNegMap(USERS.mapBy(u => troves.get(u).debt), USERS),
  }

  val safety: bool = and {
    debtConservation,
    boldPartition,
    collConservation,
    nonNegative,
  }
}
