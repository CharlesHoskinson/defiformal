// SparkLend — Aave V3 fork whose borrow rate tracks an external savings rate.
// Source: protocol-repos/lend/sparkdotfi_sparklend-v1-core/ (Aave pool fork)
// Profile (supp-02): base/kink rates = fixed spread over another protocol's SSR;
// rate moves when upstream moves, with no local tx.
// Model: same shape as aave_v3, plus externalRate and spread-driven IRM.

module sparklend {
  import common.* from "./common"

  pure val LT_BPS: int = 8500
  pure val SPREAD_BASE_BPS: int = 50     // fixed spread over SSR
  pure val SPREAD_KINK_BPS: int = 100
  pure val SLOPE2: int = 3000
  pure val KINK: int = 8000
  pure val USERS: Set[str] = Set("alice", "bob")

  var liquidityIndex: int
  var variableBorrowIndex: int
  var totalSupplyScaled: int
  var totalBorrowScaled: int
  var userSupplyScaled: str -> int
  var userBorrowScaled: str -> int
  var oraclePrice: int
  var externalSSR: int                   // upstream savings rate (bps)

  action init: bool = all {
    liquidityIndex' = INDEX_BASE,
    variableBorrowIndex' = INDEX_BASE,
    totalSupplyScaled' = 100,
    totalBorrowScaled' = 0,
    userSupplyScaled' = USERS.mapBy(u => if (u == "alice") 100 else 0),
    userBorrowScaled' = USERS.mapBy(_ => 0),
    oraclePrice' = 10,
    externalSSR' = 500,  // 5% abstract
  }

  pure def supplyOf(s: int, i: int): int = presentFromScaled(s, i)
  pure def debtOf(s: int, i: int): int = presentFromScaled(s, i)

  /// Spark IRM: base = SSR + spread; kink rate similarly elevated
  pure def sparkBorrowRate(utilBps: int, ssr: int): int = {
    val base = ssr + SPREAD_BASE_BPS
    val slope1 = SPREAD_KINK_BPS
    twoSlopeRate(utilBps, base, slope1, SLOPE2, KINK)
  }

  pure def healthy(u: str, sup: str -> int, bor: str -> int,
                   li: int, bi: int, price: int): bool = {
    val debt = debtOf(bor.get(u), bi)
    if (debt == 0) true
    else isHealthy(supplyOf(sup.get(u), li), price, debt, price, LT_BPS)
  }

  action supply(u: str, amount: int): bool = all {
    USERS.contains(u), amount > 0,
    val sc = scaledFromPresent(amount, liquidityIndex)
    all {
      sc > 0,
      totalSupplyScaled' = totalSupplyScaled + sc,
      userSupplyScaled' = userSupplyScaled.put(u, userSupplyScaled.get(u) + sc),
      userBorrowScaled' = userBorrowScaled,
      liquidityIndex' = liquidityIndex,
      variableBorrowIndex' = variableBorrowIndex,
      totalBorrowScaled' = totalBorrowScaled,
      oraclePrice' = oraclePrice,
      externalSSR' = externalSSR,
    }
  }

  action borrow(u: str, amount: int): bool = all {
    USERS.contains(u), amount > 0,
    val sc = scaledFromPresent(amount, variableBorrowIndex)
    val newBor = userBorrowScaled.put(u, userBorrowScaled.get(u) + sc)
    all {
      sc > 0,
      supplyOf(totalSupplyScaled, liquidityIndex) >=
        debtOf(totalBorrowScaled, variableBorrowIndex) + amount,
      healthy(u, userSupplyScaled, newBor, liquidityIndex, variableBorrowIndex, oraclePrice),
      totalBorrowScaled' = totalBorrowScaled + sc,
      userBorrowScaled' = newBor,
      userSupplyScaled' = userSupplyScaled,
      liquidityIndex' = liquidityIndex,
      variableBorrowIndex' = variableBorrowIndex,
      totalSupplyScaled' = totalSupplyScaled,
      oraclePrice' = oraclePrice,
      externalSSR' = externalSSR,
    }
  }

  action repay(u: str, amount: int): bool = all {
    USERS.contains(u), amount > 0,
    val debt = debtOf(userBorrowScaled.get(u), variableBorrowIndex)
    val pay = min(amount, debt)
    val sc = scaledFromPresent(pay, variableBorrowIndex)
    all {
      debt > 0, sc > 0, sc <= userBorrowScaled.get(u),
      totalBorrowScaled' = totalBorrowScaled - sc,
      userBorrowScaled' = userBorrowScaled.put(u, userBorrowScaled.get(u) - sc),
      userSupplyScaled' = userSupplyScaled,
      liquidityIndex' = liquidityIndex,
      variableBorrowIndex' = variableBorrowIndex,
      totalSupplyScaled' = totalSupplyScaled,
      oraclePrice' = oraclePrice,
      externalSSR' = externalSSR,
    }
  }

  /// Upstream SSR moves without a Spark transaction
  action externalRateUpdate(newSSR: int): bool = all {
    newSSR >= 0,
    externalSSR' = newSSR,
    liquidityIndex' = liquidityIndex,
    variableBorrowIndex' = variableBorrowIndex,
    totalSupplyScaled' = totalSupplyScaled,
    totalBorrowScaled' = totalBorrowScaled,
    userSupplyScaled' = userSupplyScaled,
    userBorrowScaled' = userBorrowScaled,
    oraclePrice' = oraclePrice,
  }

  action accrue(dt: int): bool = all {
    dt > 0,
    val util = utilization(
      debtOf(totalBorrowScaled, variableBorrowIndex),
      supplyOf(totalSupplyScaled, liquidityIndex)
    )
    val br = sparkBorrowRate(util, externalSSR)
    all {
      variableBorrowIndex' = accrueIndex(variableBorrowIndex, br, dt),
      liquidityIndex' = accrueIndex(liquidityIndex, mulDivDown(br, util, 10000), dt),
      totalSupplyScaled' = totalSupplyScaled,
      totalBorrowScaled' = totalBorrowScaled,
      userSupplyScaled' = userSupplyScaled,
      userBorrowScaled' = userBorrowScaled,
      oraclePrice' = oraclePrice,
      externalSSR' = externalSSR,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(20).oneOf()
    nondet dt = 1.to(3).oneOf()
    nondet ssr = 0.to(2000).oneOf()
    any {
      supply(u, amt),
      borrow(u, amt),
      repay(u, amt),
      externalRateUpdate(ssr),
      accrue(dt),
    }
  }

  val reserveSolvency: bool =
    supplyOf(totalSupplyScaled, liquidityIndex) >=
    debtOf(totalBorrowScaled, variableBorrowIndex)

  val supplyConservation: bool =
    USERS.fold(0, (acc, u) => acc + userSupplyScaled.get(u)) == totalSupplyScaled
}
