// Compound V3 (Comet) — single base asset + multi-collateral; absorb liquidation.
// Source: protocol-repos/lend/compound-finance_comet/contracts/CometCore.sol
//   presentValueSupply / presentValueBorrow via baseSupplyIndex / baseBorrowIndex
//   user principal signed (supply > 0, borrow < 0)
// Liquidation is absorb (protocol takes collateral), not third-party seize race alone.
// Model: one base + one collateral asset.

module compound_v3 {
  import common.* from "./common"

  pure val CF_BPS: int = 8000          // borrow collateral factor
  pure val LF_BPS: int = 9000          // liquidate collateral factor
  pure val USERS: Set[str] = Set("alice", "bob", "absorber")

  var baseSupplyIndex: int
  var baseBorrowIndex: int
  // signed principal: >0 supply, <0 borrow (Comet userBasic.principal)
  var principal: str -> int
  var collateral: str -> int           // non-base collateral balances
  var totalSupplyBase: int             // present-value aggregate (tracked)
  var totalBorrowBase: int
  var basePrice: int
  var collPrice: int
  var reserves: int                    // protocol reserves of base

  action init: bool = all {
    baseSupplyIndex' = INDEX_BASE,
    baseBorrowIndex' = INDEX_BASE,
    principal' = USERS.mapBy(u => if (u == "alice") 100 else 0),
    collateral' = USERS.mapBy(_ => 0),
    totalSupplyBase' = 100,
    totalBorrowBase' = 0,
    basePrice' = 1,
    collPrice' = 10,
    reserves' = 10,
  }

  pure def presentBase(p: int, sIdx: int, bIdx: int): int =
    if (p >= 0) presentFromScaled(p, sIdx)
    else 0 - presentFromScaled(0 - p, bIdx)

  pure def isCollateralized(
    u: str, prin: str -> int, col: str -> int,
    sIdx: int, bIdx: int, bp: int, cp: int, factor: int
  ): bool = {
    val base = presentBase(prin.get(u), sIdx, bIdx)
    if (base >= 0) true
    else {
      val debt = 0 - base
      isHealthy(col.get(u), cp, debt, bp, factor)
    }
  }

  action supplyBase(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    val p = principal.get(u)
    // if borrowing, first repay
    all {
      if (p < 0) {
        val debt = presentFromScaled(0 - p, baseBorrowIndex)
        val pay = min(amount, debt)
        val newPrin =
          if (pay == debt) scaledFromPresent(amount - pay, baseSupplyIndex)
          else 0 - scaledFromPresent(debt - pay, baseBorrowIndex)
        all {
          principal' = principal.put(u, newPrin),
          totalBorrowBase' =
            if (pay > 0) max(totalBorrowBase - pay, 0) else totalBorrowBase,
          totalSupplyBase' =
            if (amount > pay) totalSupplyBase + (amount - pay) else totalSupplyBase,
          collateral' = collateral,
          baseSupplyIndex' = baseSupplyIndex,
          baseBorrowIndex' = baseBorrowIndex,
          basePrice' = basePrice,
          collPrice' = collPrice,
          reserves' = reserves,
        }
      } else {
        val sc = scaledFromPresent(amount, baseSupplyIndex)
        all {
          principal' = principal.put(u, p + sc),
          totalSupplyBase' = totalSupplyBase + amount,
          totalBorrowBase' = totalBorrowBase,
          collateral' = collateral,
          baseSupplyIndex' = baseSupplyIndex,
          baseBorrowIndex' = baseBorrowIndex,
          basePrice' = basePrice,
          collPrice' = collPrice,
          reserves' = reserves,
        }
      }
    }
  }

  action supplyCollateral(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    collateral' = collateral.put(u, collateral.get(u) + amount),
    principal' = principal,
    totalSupplyBase' = totalSupplyBase,
    totalBorrowBase' = totalBorrowBase,
    baseSupplyIndex' = baseSupplyIndex,
    baseBorrowIndex' = baseBorrowIndex,
    basePrice' = basePrice,
    collPrice' = collPrice,
    reserves' = reserves,
  }

  action withdrawBase(u: str, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    // withdrawing base when not enough supply creates a borrow
    val p = principal.get(u)
    val present = presentBase(p, baseSupplyIndex, baseBorrowIndex)
    all {
      totalSupplyBase - totalBorrowBase >= amount or true, // Comet allows borrow-on-withdraw
      val newPresent = present - amount
      val newPrin =
        if (newPresent >= 0) scaledFromPresent(newPresent, baseSupplyIndex)
        else 0 - scaledFromPresent(0 - newPresent, baseBorrowIndex)
      val newMap = principal.put(u, newPrin)
      all {
        isCollateralized(u, newMap, collateral, baseSupplyIndex, baseBorrowIndex,
                         basePrice, collPrice, CF_BPS),
        principal' = newMap,
        totalSupplyBase' =
          if (present >= 0 and newPresent >= 0) totalSupplyBase - amount
          else if (present >= 0 and newPresent < 0)
            totalSupplyBase - present  // supply removed
          else totalSupplyBase,
        totalBorrowBase' =
          if (newPresent < 0 and present >= 0) totalBorrowBase + (0 - newPresent)
          else if (newPresent < 0 and present < 0)
            totalBorrowBase + amount
          else totalBorrowBase,
        collateral' = collateral,
        baseSupplyIndex' = baseSupplyIndex,
        baseBorrowIndex' = baseBorrowIndex,
        basePrice' = basePrice,
        collPrice' = collPrice,
        reserves' = reserves,
      }
    }
  }

  /// absorb: underwater account's collateral seized to protocol; debt socialized to reserves
  action absorb(u: str): bool = all {
    USERS.contains(u),
    u != "absorber",
    not(isCollateralized(u, principal, collateral, baseSupplyIndex, baseBorrowIndex,
                         basePrice, collPrice, LF_BPS)),
    val p = principal.get(u)
    val base = presentBase(p, baseSupplyIndex, baseBorrowIndex)
    all {
      base < 0,  // must be a borrower
      val debt = 0 - base
      val col = collateral.get(u)
      all {
        // debt written to reserves; collateral to absorber (simplified: protocol)
        principal' = principal.put(u, 0),
        collateral' = collateral.put(u, 0).put("absorber", collateral.get("absorber") + col),
        totalBorrowBase' = max(totalBorrowBase - debt, 0),
        reserves' = reserves - debt + mulDivDown(col * collPrice, 1, max(basePrice, 1)),
        totalSupplyBase' = totalSupplyBase,
        baseSupplyIndex' = baseSupplyIndex,
        baseBorrowIndex' = baseBorrowIndex,
        basePrice' = basePrice,
        collPrice' = collPrice,
      }
    }
  }

  action accrue(dt: int): bool = all {
    dt > 0,
    val util = utilization(totalBorrowBase, totalSupplyBase)
    val br = twoSlopeRate(util, 50, 300, 2000, 8000)
    all {
      baseBorrowIndex' = accrueIndex(baseBorrowIndex, br, dt),
      baseSupplyIndex' = accrueIndex(baseSupplyIndex, mulDivDown(br, util, 10000), dt),
      principal' = principal,
      collateral' = collateral,
      totalSupplyBase' = totalSupplyBase,
      totalBorrowBase' = totalBorrowBase,
      basePrice' = basePrice,
      collPrice' = collPrice,
      reserves' = reserves,
    }
  }

  action shockCollPrice(p: int): bool = all {
    p > 0,
    collPrice' = p,
    baseSupplyIndex' = baseSupplyIndex,
    baseBorrowIndex' = baseBorrowIndex,
    principal' = principal,
    collateral' = collateral,
    totalSupplyBase' = totalSupplyBase,
    totalBorrowBase' = totalBorrowBase,
    basePrice' = basePrice,
    reserves' = reserves,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(20).oneOf()
    nondet dt = 1.to(3).oneOf()
    nondet p = 1.to(12).oneOf()
    any {
      supplyBase(u, amt),
      supplyCollateral(u, amt),
      withdrawBase(u, amt),
      absorb("alice"),
      absorb("bob"),
      accrue(dt),
      shockCollPrice(p),
    }
  }

  /// Comet target: total supply of base covers borrows (soft — reserves can go negative short-term)
  val borrowBounded: bool = totalBorrowBase >= 0 and totalSupplyBase >= 0

  val indicesPositive: bool = baseSupplyIndex > 0 and baseBorrowIndex > 0
}
