// Fluid — shared liquidity layer + DEX inventory that can be smart collateral/debt.
// Source: protocol-repos/dex/Instadapp_fluid-contracts-public/contracts/liquidity/
//   common/variables.sol totalSupply/totalBorrow raw * exchangePrice,
//   userModule operate(supplyAmount, borrowAmount).
// Distinct: one capital unit is simultaneously supply, borrowable, and AMM inventory.

module fluid {
  import common.* from "./common"

  pure val FEE_NUM: int = 997
  pure val FEE_DEN: int = 1000
  pure val LTV_BPS: int = 8000
  pure val USERS: Set[str] = Set("alice", "bob")

  // Liquidity layer (single asset abstract dual: "col" and "debt" tokens for vault)
  var supplyIndex: int
  var borrowIndex: int
  var totalSupplyScaled: int
  var totalBorrowScaled: int
  // Per-user vault position: collateral shares + debt shares
  var userCol: str -> int
  var userDebt: str -> int
  // DEX inventory drawn from the layer (smart collateral/debt abstraction)
  var dexReserve0: int
  var dexReserve1: int
  // Oracle prices
  var price0: int
  var price1: int

  action init: bool = all {
    supplyIndex' = INDEX_BASE,
    borrowIndex' = INDEX_BASE,
    totalSupplyScaled' = 100,
    totalBorrowScaled' = 0,
    userCol' = USERS.mapBy(u => if (u == "alice") 100 else 0),
    userDebt' = USERS.mapBy(_ => 0),
    dexReserve0' = 50,
    dexReserve1' = 50,
    price0' = 1,
    price1' = 1,
  }

  pure def supplyAssets(scaled: int, idx: int): int = presentFromScaled(scaled, idx)
  pure def borrowAssets(scaled: int, idx: int): int = presentFromScaled(scaled, idx)

  action supply(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    val sc = scaledFromPresent(amount, supplyIndex)
    all {
      sc > 0,
      totalSupplyScaled' = totalSupplyScaled + sc,
      userCol' = userCol.put(u, userCol.get(u) + sc),
      userDebt' = userDebt,
      supplyIndex' = supplyIndex,
      borrowIndex' = borrowIndex,
      totalBorrowScaled' = totalBorrowScaled,
      dexReserve0' = dexReserve0,
      dexReserve1' = dexReserve1,
      price0' = price0,
      price1' = price1,
    }
  }

  action borrow(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    val debtSc = scaledFromPresent(amount, borrowIndex)
    val newDebt = borrowAssets(userDebt.get(u) + debtSc, borrowIndex)
    val col = supplyAssets(userCol.get(u), supplyIndex)
    all {
      isHealthy(col, price0, newDebt, price1, LTV_BPS),
      // liquidity available
      supplyAssets(totalSupplyScaled, supplyIndex) >=
        borrowAssets(totalBorrowScaled, borrowIndex) + amount,
      totalBorrowScaled' = totalBorrowScaled + debtSc,
      userDebt' = userDebt.put(u, userDebt.get(u) + debtSc),
      userCol' = userCol,
      supplyIndex' = supplyIndex,
      borrowIndex' = borrowIndex,
      totalSupplyScaled' = totalSupplyScaled,
      dexReserve0' = dexReserve0,
      dexReserve1' = dexReserve1,
      price0' = price0,
      price1' = price1,
    }
  }

  /// Deploy supply into DEX inventory (smart collateral path)
  action deployToDex(amount0: int, amount1: int): bool = all {
    amount0 > 0, amount1 > 0,
    val avail =
      supplyAssets(totalSupplyScaled, supplyIndex) -
      borrowAssets(totalBorrowScaled, borrowIndex)
    all {
      amount0 + amount1 <= avail,
      dexReserve0' = dexReserve0 + amount0,
      dexReserve1' = dexReserve1 + amount1,
      supplyIndex' = supplyIndex,
      borrowIndex' = borrowIndex,
      totalSupplyScaled' = totalSupplyScaled,
      totalBorrowScaled' = totalBorrowScaled,
      userCol' = userCol,
      userDebt' = userDebt,
      price0' = price0,
      price1' = price1,
    }
  }

  /// Swap against DEX inventory; fees reduce debt conceptually (smart debt)
  action swap0for1(amountIn: int): bool = all {
    amountIn > 0,
    dexReserve0 > 0, dexReserve1 > 0,
    val out = cpAmountOut(dexReserve0, dexReserve1, amountIn, FEE_NUM, FEE_DEN)
    val fee = mulDivDown(amountIn, FEE_DEN - FEE_NUM, FEE_DEN)
    all {
      out > 0, out < dexReserve1,
      dexReserve0' = dexReserve0 + amountIn,
      dexReserve1' = dexReserve1 - out,
      // fee amortizes aggregate borrow (smart debt payoff abstraction)
      borrowIndex' = borrowIndex,
      totalBorrowScaled' =
        if (totalBorrowScaled > 0 and fee > 0)
          max(totalBorrowScaled - scaledFromPresent(fee, borrowIndex), 0)
        else totalBorrowScaled,
      supplyIndex' = supplyIndex,
      totalSupplyScaled' = totalSupplyScaled,
      userCol' = userCol,
      userDebt' = userDebt,
      price0' = price0,
      price1' = price1,
    }
  }

  action accrue(dt: int): bool = all {
    dt > 0,
    val util = utilization(
      borrowAssets(totalBorrowScaled, borrowIndex),
      supplyAssets(totalSupplyScaled, supplyIndex)
    )
    val rate = twoSlopeRate(util, 0, 400, 3000, 8000)
    all {
      borrowIndex' = accrueIndex(borrowIndex, rate, dt),
      supplyIndex' = accrueIndex(supplyIndex, rate / 2, dt),
      totalSupplyScaled' = totalSupplyScaled,
      totalBorrowScaled' = totalBorrowScaled,
      userCol' = userCol,
      userDebt' = userDebt,
      dexReserve0' = dexReserve0,
      dexReserve1' = dexReserve1,
      price0' = price0,
      price1' = price1,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(20).oneOf()
    nondet a0 = 1.to(10).oneOf()
    nondet a1 = 1.to(10).oneOf()
    nondet din = 1.to(10).oneOf()
    nondet dt = 1.to(3).oneOf()
    any {
      supply(u, amt),
      borrow(u, amt),
      deployToDex(a0, a1),
      swap0for1(din),
      accrue(dt),
    }
  }

  /// Layer solvency: total supply assets >= total borrow assets
  val layerSolvency: bool =
    supplyAssets(totalSupplyScaled, supplyIndex) >=
    borrowAssets(totalBorrowScaled, borrowIndex)

  val nonNeg: bool =
    totalSupplyScaled >= 0 and totalBorrowScaled >= 0 and
    dexReserve0 >= 0 and dexReserve1 >= 0
}
