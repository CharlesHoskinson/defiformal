// JustLend V1 — Compound V2 fork: per-market cToken, exchange rate, fixed close factor.
// Source: protocol-repos/lend/justlend_justlend-protocol/contracts/CToken.sol
//   exchangeRateStoredInternal: (cash + borrows - reserves) / totalSupply
//   borrowIndex accrual per block, liquidateBorrow with closeFactorMantissa.
// Distinct: exchange-rate share (not dual aToken/debtToken indices); rate per block.

module justlend {
  import common.* from "./common"

  pure val CLOSE_FACTOR_BPS: int = 5000
  pure val LIQ_INCENTIVE_BPS: int = 10800
  pure val COLLATERAL_FACTOR_BPS: int = 7500
  pure val USERS: Set[str] = Set("alice", "bob", "liquidator")

  var cash: int
  var totalBorrows: int
  var totalReserves: int
  var totalSupply: int              // cToken supply
  var borrowIndex: int
  var cTokenBal: str -> int
  var borrowPrincipal: str -> int   // principal at user's borrowIndex snapshot
  var userBorrowIndex: str -> int
  var oraclePrice: int              // underlying price
  // single market = collateral and borrow asset (self-collateral simplified)

  action init: bool = all {
    cash' = 100,
    totalBorrows' = 0,
    totalReserves' = 0,
    totalSupply' = 100,
    borrowIndex' = INDEX_BASE,
    cTokenBal' = USERS.mapBy(u => if (u == "alice") 100 else 0),
    borrowPrincipal' = USERS.mapBy(_ => 0),
    userBorrowIndex' = USERS.mapBy(_ => INDEX_BASE),
    oraclePrice' = 10,
  }

  pure def exchangeRate(cash: int, borrows: int, reserves: int, supply: int): int =
    if (supply <= 0) INDEX_BASE
    else mulDivDown((cash + borrows - reserves) * INDEX_BASE, 1, supply)

  pure def borrowBalance(principal: int, userIdx: int, globalIdx: int): int =
    if (principal == 0 or userIdx <= 0) 0
    else mulDivDown(principal * globalIdx, 1, userIdx)

  pure def underlyingBal(cTokens: int, rate: int): int =
    mulDivDown(cTokens * rate, 1, INDEX_BASE)

  pure def healthy(
    u: str, cBal: str -> int, bPrin: str -> int, uIdx: str -> int,
    cash: int, borrows: int, reserves: int, supply: int, gIdx: int, price: int
  ): bool = {
    val rate = exchangeRate(cash, borrows, reserves, supply)
    val coll = underlyingBal(cBal.get(u), rate)
    val debt = borrowBalance(bPrin.get(u), uIdx.get(u), gIdx)
    isHealthy(coll, price, debt, price, COLLATERAL_FACTOR_BPS)
  }

  action mint(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    val rate = exchangeRate(cash, totalBorrows, totalReserves, totalSupply)
    val tokens = mulDivDown(amount * INDEX_BASE, 1, rate)
    all {
      tokens > 0,
      cash' = cash + amount,
      totalSupply' = totalSupply + tokens,
      cTokenBal' = cTokenBal.put(u, cTokenBal.get(u) + tokens),
      totalBorrows' = totalBorrows,
      totalReserves' = totalReserves,
      borrowIndex' = borrowIndex,
      borrowPrincipal' = borrowPrincipal,
      userBorrowIndex' = userBorrowIndex,
      oraclePrice' = oraclePrice,
    }
  }

  action redeem(u: str, tokens: int): bool = all {
    USERS.contains(u),
    tokens > 0,
    cTokenBal.get(u) >= tokens,
    val rate = exchangeRate(cash, totalBorrows, totalReserves, totalSupply)
    val amount = underlyingBal(tokens, rate)
    val newBal = cTokenBal.put(u, cTokenBal.get(u) - tokens)
    all {
      amount > 0,
      cash >= amount,
      healthy(u, newBal, borrowPrincipal, userBorrowIndex,
              cash - amount, totalBorrows, totalReserves, totalSupply - tokens,
              borrowIndex, oraclePrice),
      cash' = cash - amount,
      totalSupply' = totalSupply - tokens,
      cTokenBal' = newBal,
      totalBorrows' = totalBorrows,
      totalReserves' = totalReserves,
      borrowIndex' = borrowIndex,
      borrowPrincipal' = borrowPrincipal,
      userBorrowIndex' = userBorrowIndex,
      oraclePrice' = oraclePrice,
    }
  }

  action borrow(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    cash >= amount,
    // refresh principal to current index then add
    val curDebt = borrowBalance(borrowPrincipal.get(u), userBorrowIndex.get(u), borrowIndex)
    val newDebt = curDebt + amount
    val newPrin = newDebt  // store at current index
    val newBP = borrowPrincipal.put(u, newPrin)
    val newUI = userBorrowIndex.put(u, borrowIndex)
    all {
      healthy(u, cTokenBal, newBP, newUI,
              cash - amount, totalBorrows + amount, totalReserves, totalSupply,
              borrowIndex, oraclePrice),
      cash' = cash - amount,
      totalBorrows' = totalBorrows + amount,
      borrowPrincipal' = newBP,
      userBorrowIndex' = newUI,
      cTokenBal' = cTokenBal,
      totalSupply' = totalSupply,
      totalReserves' = totalReserves,
      borrowIndex' = borrowIndex,
      oraclePrice' = oraclePrice,
    }
  }

  action repay(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    val curDebt = borrowBalance(borrowPrincipal.get(u), userBorrowIndex.get(u), borrowIndex)
    val pay = min(amount, curDebt)
    all {
      curDebt > 0,
      cash' = cash + pay,
      totalBorrows' = max(totalBorrows - pay, 0),
      borrowPrincipal' = borrowPrincipal.put(u, curDebt - pay),
      userBorrowIndex' = userBorrowIndex.put(u, borrowIndex),
      cTokenBal' = cTokenBal,
      totalSupply' = totalSupply,
      totalReserves' = totalReserves,
      borrowIndex' = borrowIndex,
      oraclePrice' = oraclePrice,
    }
  }

  action liquidate(borrower: str, repayAmt: int): bool = all {
    USERS.contains(borrower),
    borrower != "liquidator",
    repayAmt > 0,
    not(healthy(borrower, cTokenBal, borrowPrincipal, userBorrowIndex,
                cash, totalBorrows, totalReserves, totalSupply, borrowIndex, oraclePrice)),
    val debt = borrowBalance(borrowPrincipal.get(borrower),
                             userBorrowIndex.get(borrower), borrowIndex)
    val maxRepay = mulDivDown(debt, CLOSE_FACTOR_BPS, 10000)
    val pay = min(repayAmt, maxRepay)
    val seizeUnderlying = seizeCollateral(pay, oraclePrice, oraclePrice, LIQ_INCENTIVE_BPS)
    val rate = exchangeRate(cash, totalBorrows, totalReserves, totalSupply)
    val seizeTokens = mulDivDown(seizeUnderlying * INDEX_BASE, 1, rate)
    all {
      pay > 0,
      seizeTokens > 0,
      cTokenBal.get(borrower) >= seizeTokens,
      cash' = cash + pay,
      totalBorrows' = max(totalBorrows - pay, 0),
      borrowPrincipal' =
        borrowPrincipal.put(borrower, debt - pay),
      userBorrowIndex' =
        userBorrowIndex.put(borrower, borrowIndex),
      cTokenBal' =
        cTokenBal
          .put(borrower, cTokenBal.get(borrower) - seizeTokens)
          .put("liquidator", cTokenBal.get("liquidator") + seizeTokens),
      totalSupply' = totalSupply,
      totalReserves' = totalReserves,
      borrowIndex' = borrowIndex,
      oraclePrice' = oraclePrice,
    }
  }

  /// Accrue per-block interest (JustLend quotes rate per block)
  action accrueBlock(blocks: int, rateBpsPerBlock: int): bool = all {
    blocks > 0,
    rateBpsPerBlock >= 0,
    val interest = mulDivDown(totalBorrows * rateBpsPerBlock * blocks, 1, 10000)
    val reserveAdd = mulDivDown(interest, 1000, 10000)  // 10% reserve factor abstract
    all {
      totalBorrows' = totalBorrows + interest,
      totalReserves' = totalReserves + reserveAdd,
      borrowIndex' = accrueIndex(borrowIndex, rateBpsPerBlock, blocks),
      cash' = cash,
      totalSupply' = totalSupply,
      cTokenBal' = cTokenBal,
      borrowPrincipal' = borrowPrincipal,
      userBorrowIndex' = userBorrowIndex,
      oraclePrice' = oraclePrice,
    }
  }

  action shockPrice(p: int): bool = all {
    p > 0,
    oraclePrice' = p,
    cash' = cash,
    totalBorrows' = totalBorrows,
    totalReserves' = totalReserves,
    totalSupply' = totalSupply,
    borrowIndex' = borrowIndex,
    cTokenBal' = cTokenBal,
    borrowPrincipal' = borrowPrincipal,
    userBorrowIndex' = userBorrowIndex,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(20).oneOf()
    nondet blocks = 1.to(5).oneOf()
    nondet rate = 1.to(10).oneOf()
    nondet p = 1.to(15).oneOf()
    any {
      mint(u, amt),
      redeem(u, amt),
      borrow(u, amt),
      repay(u, amt),
      liquidate("alice", amt),
      liquidate("bob", amt),
      accrueBlock(blocks, rate),
      shockPrice(p),
    }
  }

  /// Exchange-rate accounting identity: cash + borrows >= reserves
  val cashIdentity: bool = cash + totalBorrows >= totalReserves

  val cTokenConservation: bool =
    USERS.fold(0, (acc, u) => acc + cTokenBal.get(u)) == totalSupply

  val nonNeg: bool =
    cash >= 0 and totalBorrows >= 0 and totalSupply >= 0 and borrowIndex > 0
}
