// Morpho Blue — isolated market singleton: fixed LLTV, share accounting, bad-debt socialize.
// Source: protocol-repos/lend/morpho-org_morpho-blue/src/Morpho.sol
//   Market { totalSupplyAssets, totalSupplyShares, totalBorrowAssets, totalBorrowShares }
//   Position { supplyShares, borrowShares, collateral }
//   liquidate (L347+), _accrueInterest, insufficient liquidity check on withdraw/borrow.
// Distinct vs Aave: no shared risk pool; market params immutable; IRM is external controller.

module morpho_blue {
  import common.* from "./common"

  pure val LLTV_BPS: int = 8600
  pure val LIQ_INCENTIVE_BPS: int = 11500  // derived from LLTV in code; fixed here
  pure val USERS: Set[str] = Set("alice", "bob", "liquidator")

  var totalSupplyAssets: int
  var totalSupplyShares: int
  var totalBorrowAssets: int
  var totalBorrowShares: int
  var supplyShares: str -> int
  var borrowShares: str -> int
  var collateral: str -> int
  var collPrice: int
  // loan token price fixed at 1 (base)

  action init: bool = all {
    totalSupplyAssets' = 100,
    totalSupplyShares' = 100,
    totalBorrowAssets' = 0,
    totalBorrowShares' = 0,
    supplyShares' = USERS.mapBy(u => if (u == "alice") 100 else 0),
    borrowShares' = USERS.mapBy(_ => 0),
    collateral' = USERS.mapBy(_ => 0),
    collPrice' = 10,
  }

  pure def healthy(u: str, borSh: str -> int, col: str -> int,
                   tBA: int, tBS: int, price: int): bool = {
    val debt = if (tBS == 0) 0 else assetsFromShares(borSh.get(u), tBA, tBS)
    isHealthy(col.get(u), price, debt, 1, LLTV_BPS)
  }

  action supply(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    val sh = sharesFromAssets(assets, totalSupplyAssets, totalSupplyShares)
    all {
      sh > 0,
      totalSupplyAssets' = totalSupplyAssets + assets,
      totalSupplyShares' = totalSupplyShares + sh,
      supplyShares' = supplyShares.put(u, supplyShares.get(u) + sh),
      borrowShares' = borrowShares,
      collateral' = collateral,
      totalBorrowAssets' = totalBorrowAssets,
      totalBorrowShares' = totalBorrowShares,
      collPrice' = collPrice,
    }
  }

  action withdraw(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    val sh = sharesFromAssets(assets, totalSupplyAssets, totalSupplyShares)
    // Morpho uses shares-up for withdraw; approximate
    all {
      sh > 0,
      supplyShares.get(u) >= sh,
      totalBorrowAssets <= totalSupplyAssets - assets,  // INSUFFICIENT_LIQUIDITY
      totalSupplyAssets' = totalSupplyAssets - assets,
      totalSupplyShares' = totalSupplyShares - sh,
      supplyShares' = supplyShares.put(u, supplyShares.get(u) - sh),
      borrowShares' = borrowShares,
      collateral' = collateral,
      totalBorrowAssets' = totalBorrowAssets,
      totalBorrowShares' = totalBorrowShares,
      collPrice' = collPrice,
    }
  }

  action supplyCollateral(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    collateral' = collateral.put(u, collateral.get(u) + assets),
    supplyShares' = supplyShares,
    borrowShares' = borrowShares,
    totalSupplyAssets' = totalSupplyAssets,
    totalSupplyShares' = totalSupplyShares,
    totalBorrowAssets' = totalBorrowAssets,
    totalBorrowShares' = totalBorrowShares,
    collPrice' = collPrice,
  }

  action borrow(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    val sh =
      if (totalBorrowShares == 0) assets
      else sharesFromAssets(assets, totalBorrowAssets, totalBorrowShares)
    // Morpho uses toSharesUp on borrow
    val newBor = borrowShares.put(u, borrowShares.get(u) + sh)
    all {
      sh > 0,
      totalBorrowAssets + assets <= totalSupplyAssets,
      healthy(u, newBor, collateral, totalBorrowAssets + assets,
              totalBorrowShares + sh, collPrice),
      totalBorrowAssets' = totalBorrowAssets + assets,
      totalBorrowShares' = totalBorrowShares + sh,
      borrowShares' = newBor,
      supplyShares' = supplyShares,
      collateral' = collateral,
      totalSupplyAssets' = totalSupplyAssets,
      totalSupplyShares' = totalSupplyShares,
      collPrice' = collPrice,
    }
  }

  action repay(u: str, assets: int): bool = all {
    USERS.contains(u),
    assets > 0,
    totalBorrowShares > 0,
    val sh = sharesFromAssets(assets, totalBorrowAssets, totalBorrowShares)
    all {
      sh > 0,
      borrowShares.get(u) >= sh,
      totalBorrowAssets' = max(totalBorrowAssets - assets, 0),
      totalBorrowShares' = totalBorrowShares - sh,
      borrowShares' = borrowShares.put(u, borrowShares.get(u) - sh),
      supplyShares' = supplyShares,
      collateral' = collateral,
      totalSupplyAssets' = totalSupplyAssets,
      totalSupplyShares' = totalSupplyShares,
      collPrice' = collPrice,
    }
  }

  action liquidate(borrower: str, seizedCol: int): bool = all {
    USERS.contains(borrower),
    borrower != "liquidator",
    seizedCol > 0,
    not(healthy(borrower, borrowShares, collateral,
                totalBorrowAssets, totalBorrowShares, collPrice)),
    collateral.get(borrower) >= seizedCol,
    // repay shares corresponding to seized collateral / incentive
    val repaidAssets = mulDivDown(seizedCol * collPrice * 10000, 1, LIQ_INCENTIVE_BPS)
    val repSh =
      if (totalBorrowShares == 0) 0
      else sharesFromAssets(repaidAssets, totalBorrowAssets, totalBorrowShares)
    all {
      repSh > 0,
      borrowShares.get(borrower) >= repSh,
      collateral' = collateral
        .put(borrower, collateral.get(borrower) - seizedCol)
        .put("liquidator", collateral.get("liquidator") + seizedCol),
      borrowShares' = borrowShares.put(borrower, borrowShares.get(borrower) - repSh),
      totalBorrowAssets' = max(totalBorrowAssets - repaidAssets, 0),
      totalBorrowShares' = totalBorrowShares - repSh,
      // bad debt: if collateral wiped but debt remains, socialize
      supplyShares' = supplyShares,
      totalSupplyAssets' = totalSupplyAssets,
      totalSupplyShares' = totalSupplyShares,
      collPrice' = collPrice,
    }
  }

  /// Accrue interest: both totalBorrowAssets and totalSupplyAssets grow (Morpho L490)
  action accrue(interest: int): bool = all {
    interest > 0,
    totalBorrowAssets > 0,
    totalBorrowAssets' = totalBorrowAssets + interest,
    totalSupplyAssets' = totalSupplyAssets + interest,
    totalSupplyShares' = totalSupplyShares,
    totalBorrowShares' = totalBorrowShares,
    supplyShares' = supplyShares,
    borrowShares' = borrowShares,
    collateral' = collateral,
    collPrice' = collPrice,
  }

  action shockPrice(p: int): bool = all {
    p > 0,
    collPrice' = p,
    totalSupplyAssets' = totalSupplyAssets,
    totalSupplyShares' = totalSupplyShares,
    totalBorrowAssets' = totalBorrowAssets,
    totalBorrowShares' = totalBorrowShares,
    supplyShares' = supplyShares,
    borrowShares' = borrowShares,
    collateral' = collateral,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(20).oneOf()
    nondet p = 1.to(15).oneOf()
    nondet interest = 1.to(5).oneOf()
    any {
      supply(u, amt),
      withdraw(u, amt),
      supplyCollateral(u, amt),
      borrow(u, amt),
      repay(u, amt),
      liquidate("alice", amt),
      liquidate("bob", amt),
      accrue(interest),
      shockPrice(p),
    }
  }

  /// Morpho's hard liquidity invariant (code require on withdraw/borrow)
  val liquidityInvariant: bool = totalBorrowAssets <= totalSupplyAssets

  val shareConservation: bool =
    USERS.fold(0, (acc, u) => acc + supplyShares.get(u)) == totalSupplyShares and
    USERS.fold(0, (acc, u) => acc + borrowShares.get(u)) == totalBorrowShares

  val nonNeg: bool =
    totalSupplyAssets >= 0 and totalBorrowAssets >= 0 and collPrice > 0
}
