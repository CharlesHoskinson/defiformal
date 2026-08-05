// Aave V3 — pooled multi-reserve lending with dual indices and health factor.
// Source: protocol-repos/lend/aave-dao_aave-v3-origin/src/contracts/protocol/
//   libraries/logic/ReserveLogic.sol (liquidityIndex, variableBorrowIndex)
//   libraries/logic/SupplyLogic.sol, BorrowLogic.sol, LiquidationLogic.sol
//   libraries/logic/GenericLogic.sol (healthFactor)
// Model: one reserve (asset) as collateral and borrow; index accrual; HF liquidation.

module aave_v3 {
  import common.* from "./common"

  pure val LT_BPS: int = 8500          // liquidation threshold
  pure val CLOSE_FACTOR_BPS: int = 5000 // max half when HF high (simplified always half-cap)
  pure val LIQ_BONUS_BPS: int = 10500  // 5% bonus
  pure val USERS: Set[str] = Set("alice", "bob", "liquidator")

  var liquidityIndex: int
  var variableBorrowIndex: int
  var totalSupplyScaled: int
  var totalBorrowScaled: int
  var userSupplyScaled: str -> int
  var userBorrowScaled: str -> int
  var collEnabled: str -> bool
  var oraclePrice: int                 // asset price in base currency
  // interest model params (two-slope)
  pure val BASE_BPS: int = 0
  pure val SLOPE1: int = 400
  pure val SLOPE2: int = 3000
  pure val KINK: int = 8000

  action init: bool = all {
    liquidityIndex' = INDEX_BASE,
    variableBorrowIndex' = INDEX_BASE,
    totalSupplyScaled' = 100,
    totalBorrowScaled' = 0,
    userSupplyScaled' = USERS.mapBy(u => if (u == "alice") 100 else 0),
    userBorrowScaled' = USERS.mapBy(_ => 0),
    collEnabled' = USERS.mapBy(u => u == "alice"),
    oraclePrice' = 10,
  }

  pure def supplyOf(scaled: int, idx: int): int = presentFromScaled(scaled, idx)
  pure def debtOf(scaled: int, idx: int): int = presentFromScaled(scaled, idx)

  pure def userHF(
    u: str,
    sup: str -> int, bor: str -> int, coll: str -> bool,
    liqIdx: int, borIdx: int, price: int
  ): bool = {
    val debt = debtOf(bor.get(u), borIdx)
    if (debt == 0) true
    else if (not(coll.get(u))) false
    else isHealthy(supplyOf(sup.get(u), liqIdx), price, debt, price, LT_BPS)
  }

  action supply(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    val sc = scaledFromPresent(amount, liquidityIndex)
    all {
      sc > 0,
      totalSupplyScaled' = totalSupplyScaled + sc,
      userSupplyScaled' = userSupplyScaled.put(u, userSupplyScaled.get(u) + sc),
      userBorrowScaled' = userBorrowScaled,
      collEnabled' = collEnabled,
      liquidityIndex' = liquidityIndex,
      variableBorrowIndex' = variableBorrowIndex,
      totalBorrowScaled' = totalBorrowScaled,
      oraclePrice' = oraclePrice,
    }
  }

  action setCollateral(u: str, asCollateral: bool): bool = all {
    USERS.contains(u),
    collEnabled' = collEnabled.put(u, asCollateral),
    // cannot disable if it would break HF
    asCollateral or userHF(u, userSupplyScaled, userBorrowScaled, collEnabled.put(u, asCollateral),
                      liquidityIndex, variableBorrowIndex, oraclePrice),
    userSupplyScaled' = userSupplyScaled,
    userBorrowScaled' = userBorrowScaled,
    liquidityIndex' = liquidityIndex,
    variableBorrowIndex' = variableBorrowIndex,
    totalSupplyScaled' = totalSupplyScaled,
    totalBorrowScaled' = totalBorrowScaled,
    oraclePrice' = oraclePrice,
  }

  action borrow(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    collEnabled.get(u),
    val sc = scaledFromPresent(amount, variableBorrowIndex)
    val newBor = userBorrowScaled.put(u, userBorrowScaled.get(u) + sc)
    all {
      sc > 0,
      // available liquidity
      supplyOf(totalSupplyScaled, liquidityIndex) >=
        debtOf(totalBorrowScaled, variableBorrowIndex) + amount,
      userHF(u, userSupplyScaled, newBor, collEnabled,
             liquidityIndex, variableBorrowIndex, oraclePrice),
      totalBorrowScaled' = totalBorrowScaled + sc,
      userBorrowScaled' = newBor,
      userSupplyScaled' = userSupplyScaled,
      collEnabled' = collEnabled,
      liquidityIndex' = liquidityIndex,
      variableBorrowIndex' = variableBorrowIndex,
      totalSupplyScaled' = totalSupplyScaled,
      oraclePrice' = oraclePrice,
    }
  }

  action repay(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    val debt = debtOf(userBorrowScaled.get(u), variableBorrowIndex)
    val pay = min(amount, debt)
    val sc = scaledFromPresent(pay, variableBorrowIndex)
    all {
      debt > 0,
      sc > 0,
      sc <= userBorrowScaled.get(u),
      totalBorrowScaled' = totalBorrowScaled - sc,
      userBorrowScaled' = userBorrowScaled.put(u, userBorrowScaled.get(u) - sc),
      userSupplyScaled' = userSupplyScaled,
      collEnabled' = collEnabled,
      liquidityIndex' = liquidityIndex,
      variableBorrowIndex' = variableBorrowIndex,
      totalSupplyScaled' = totalSupplyScaled,
      oraclePrice' = oraclePrice,
    }
  }

  action withdraw(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    val sc = scaledFromPresent(amount, liquidityIndex)
    val newSup = userSupplyScaled.put(u, userSupplyScaled.get(u) - sc)
    all {
      sc > 0,
      userSupplyScaled.get(u) >= sc,
      supplyOf(totalSupplyScaled, liquidityIndex) -
        debtOf(totalBorrowScaled, variableBorrowIndex) >= amount,
      userHF(u, newSup, userBorrowScaled, collEnabled,
             liquidityIndex, variableBorrowIndex, oraclePrice),
      totalSupplyScaled' = totalSupplyScaled - sc,
      userSupplyScaled' = newSup,
      userBorrowScaled' = userBorrowScaled,
      collEnabled' = collEnabled,
      liquidityIndex' = liquidityIndex,
      variableBorrowIndex' = variableBorrowIndex,
      totalBorrowScaled' = totalBorrowScaled,
      oraclePrice' = oraclePrice,
    }
  }

  /// liquidate: repay up to close-factor of debt, seize collateral at bonus
  action liquidate(borrower: str, repayAmt: int): bool = all {
    USERS.contains(borrower),
    borrower != "liquidator",
    repayAmt > 0,
    not(userHF(borrower, userSupplyScaled, userBorrowScaled, collEnabled,
               liquidityIndex, variableBorrowIndex, oraclePrice)),
    val debt = debtOf(userBorrowScaled.get(borrower), variableBorrowIndex)
    val maxRepay = mulDivDown(debt, CLOSE_FACTOR_BPS, 10000)
    val pay = min(repayAmt, maxRepay)
    val debtSc = scaledFromPresent(pay, variableBorrowIndex)
    val seized = seizeCollateral(pay, oraclePrice, oraclePrice, LIQ_BONUS_BPS)
    val colSc = scaledFromPresent(seized, liquidityIndex)
    all {
      pay > 0,
      debtSc <= userBorrowScaled.get(borrower),
      colSc <= userSupplyScaled.get(borrower),
      userBorrowScaled' =
        userBorrowScaled.put(borrower, userBorrowScaled.get(borrower) - debtSc),
      userSupplyScaled' =
        userSupplyScaled
          .put(borrower, userSupplyScaled.get(borrower) - colSc)
          .put("liquidator", userSupplyScaled.get("liquidator") + colSc),
      totalBorrowScaled' = totalBorrowScaled - debtSc,
      // supply total unchanged (transfer of aTokens)
      totalSupplyScaled' = totalSupplyScaled,
      collEnabled' = collEnabled,
      liquidityIndex' = liquidityIndex,
      variableBorrowIndex' = variableBorrowIndex,
      oraclePrice' = oraclePrice,
    }
  }

  action accrue(dt: int): bool = all {
    dt > 0,
    val util = utilization(
      debtOf(totalBorrowScaled, variableBorrowIndex),
      supplyOf(totalSupplyScaled, liquidityIndex)
    )
    val br = twoSlopeRate(util, BASE_BPS, SLOPE1, SLOPE2, KINK)
    all {
      variableBorrowIndex' = accrueIndex(variableBorrowIndex, br, dt),
      liquidityIndex' = accrueIndex(liquidityIndex, mulDivDown(br, util, 10000), dt),
      totalSupplyScaled' = totalSupplyScaled,
      totalBorrowScaled' = totalBorrowScaled,
      userSupplyScaled' = userSupplyScaled,
      userBorrowScaled' = userBorrowScaled,
      collEnabled' = collEnabled,
      oraclePrice' = oraclePrice,
    }
  }

  action shockPrice(newPrice: int): bool = all {
    newPrice > 0,
    oraclePrice' = newPrice,
    liquidityIndex' = liquidityIndex,
    variableBorrowIndex' = variableBorrowIndex,
    totalSupplyScaled' = totalSupplyScaled,
    totalBorrowScaled' = totalBorrowScaled,
    userSupplyScaled' = userSupplyScaled,
    userBorrowScaled' = userBorrowScaled,
    collEnabled' = collEnabled,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(20).oneOf()
    nondet dt = 1.to(3).oneOf()
    nondet p = 1.to(15).oneOf()
    any {
      supply(u, amt),
      borrow(u, amt),
      repay(u, amt),
      withdraw(u, amt),
      liquidate("alice", amt),
      liquidate("bob", amt),
      accrue(dt),
      shockPrice(p),
    }
  }

  /// Protocol solvency: total supplied assets >= total borrowed assets
  val reserveSolvency: bool =
    supplyOf(totalSupplyScaled, liquidityIndex) >=
    debtOf(totalBorrowScaled, variableBorrowIndex)

  /// Scaled supply conservation vs user sum
  val supplyConservation: bool =
    USERS.fold(0, (acc, u) => acc + userSupplyScaled.get(u)) == totalSupplyScaled

  val borrowConservation: bool =
    USERS.fold(0, (acc, u) => acc + userBorrowScaled.get(u)) == totalBorrowScaled
}
