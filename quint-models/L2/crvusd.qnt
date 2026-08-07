// crvUSD (Curve stablecoin / LLAMMA) — core economic state machine.
// Sources:
//   curvefi_curve-stablecoin/curve_stablecoin/controller.vy
//     create_loan (639), debt/_debt (340), total_debt (382),
//     _update_total_debt (229), _preview_total_debt (221)
// Scope: single controller market, hard health gate on open/adjust, interest via rate_mul,
//        liquidation as debt wipe when health < 0 (band mechanics collapsed).
// NOT covered: N-band LLAMMA AMM math, PegKeeper, monetary policy curve, callbacks/leverage zaps.

module crvusd {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val LIQ_DISCOUNT: int = 50
  pure val MIN_COLL: int = 1
  pure val MIN_DEBT: int = 1

  type Loan = {
    coll: int,
    debt: int,
    rateMul: int,
    active: bool,
  }

  pure def emptyLoan: Loan = { coll: 0, debt: 0, rateMul: RAY, active: false }

  var loans: int -> Loan
  var totalDebt: int
  var totalColl: int
  var rateMul: int
  var price: int
  var minted: int
  var redeemed: int

  pure def debtNow(loan: Loan, globalRate: int): int =
    if (not(loan.active) or loan.rateMul == 0) 0
    else accrueByIndex(loan.debt, loan.rateMul, globalRate)

  pure def health(coll: int, debt: int, p: int): int =
    collValue(coll, p) - (debt * (WAD - LIQ_DISCOUNT) / WAD)

  pure def isUnhealthy(coll: int, debt: int, p: int): bool =
    debt > 0 and health(coll, debt, p) < 0

  pure def canCreate(collAmt: int, debtAmt: int, p: int): bool =
    and {
      collAmt >= MIN_COLL,
      debtAmt >= MIN_DEBT,
      health(collAmt, debtAmt, p) >= 0,
    }

  action init: bool = all {
    loans' = USERS.mapBy(_ => emptyLoan),
    totalDebt' = 0,
    totalColl' = 0,
    rateMul' = RAY,
    price' = 2000,
    minted' = 0,
    redeemed' = 0,
  }

  /// create_loan — controller.vy:639
  action createLoan(u: int, collAmt: int, debtAmt: int): bool = {
    val existing = loans.get(u)
    all {
      USERS.contains(u),
      not(existing.active),
      canCreate(collAmt, debtAmt, price),
      loans' = loans.put(u, {
        coll: collAmt,
        debt: debtAmt,
        rateMul: rateMul,
        active: true,
      }),
      totalDebt' = totalDebt + debtAmt,
      totalColl' = totalColl + collAmt,
      minted' = minted + debtAmt,
      rateMul' = rateMul,
      price' = price,
      redeemed' = redeemed,
    }
  }

  action repay(u: int, amt: int): bool = {
    val loan = loans.get(u)
    val d = debtNow(loan, rateMul)
    val newDebt = d - amt
    all {
      USERS.contains(u),
      loan.active,
      amt > 0,
      amt <= d,
      if (newDebt == 0) all {
        loans' = loans.put(u, emptyLoan),
        totalDebt' = totalDebt - d,
        totalColl' = totalColl - loan.coll,
        redeemed' = redeemed + amt,
        minted' = minted,
        rateMul' = rateMul,
        price' = price,
      } else all {
        loans' = loans.put(u, {
          coll: loan.coll,
          debt: newDebt,
          rateMul: rateMul,
          active: true,
        }),
        totalDebt' = totalDebt - amt,
        totalColl' = totalColl,
        redeemed' = redeemed + amt,
        minted' = minted,
        rateMul' = rateMul,
        price' = price,
      },
    }
  }

  action liquidate(u: int): bool = {
    val loan = loans.get(u)
    val d = debtNow(loan, rateMul)
    all {
      USERS.contains(u),
      loan.active,
      isUnhealthy(loan.coll, d, price),
      loans' = loans.put(u, emptyLoan),
      totalDebt' = totalDebt - d,
      totalColl' = totalColl - loan.coll,
      redeemed' = redeemed + d,
      minted' = minted,
      rateMul' = rateMul,
      price' = price,
    }
  }

  action accrueInterest(delta: int): bool = {
    val newRate = rateMul + delta
    all {
      delta > 0,
      delta <= 100,
      rateMul' = newRate,
      totalDebt' = accrueByIndex(totalDebt, rateMul, newRate),
      loans' = loans,
      totalColl' = totalColl,
      price' = price,
      minted' = minted,
      redeemed' = redeemed,
    }
  }

  action setPrice(p: int): bool = all {
    p > 0,
    p <= 10000,
    price' = p,
    loans' = loans,
    totalDebt' = totalDebt,
    totalColl' = totalColl,
    rateMul' = rateMul,
    minted' = minted,
    redeemed' = redeemed,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet collAmt = 1.to(50).oneOf()
    nondet debtAmt = 1.to(30).oneOf()
    nondet amt = 1.to(20).oneOf()
    nondet delta = 1.to(50).oneOf()
    nondet p = 500.to(3000).oneOf()
    any {
      createLoan(u, collAmt, debtAmt),
      repay(u, amt),
      liquidate(u),
      accrueInterest(delta),
      setPrice(p),
    }
  }

  val nonNegative: bool = and {
    totalDebt >= 0,
    totalColl >= 0,
    minted >= 0,
    redeemed >= 0,
    rateMul > 0,
    nonNegMap(USERS.mapBy(u => loans.get(u).coll), USERS),
  }

  val collConservation: bool =
    mapSum(USERS.mapBy(u => loans.get(u).coll), USERS) == totalColl

  val activeHasDebt: bool =
    USERS.forall(u => {
      val ln = loans.get(u)
      not(ln.active) or ln.debt > 0
    })

  val safety: bool = and {
    nonNegative,
    collConservation,
    activeHasDebt,
  }
}
