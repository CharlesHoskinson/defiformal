// Pendle V2 — principal/yield split over a Standardized Yield (SY) wrapper.
// Source: protocol-repos/yield/pendle-finance_pendle-core-v2-public/contracts/core/
//   YieldContracts/PendleYieldToken.sol mintPY/redeemPY, _pyIndexCurrent (HWM)
//   YieldContracts/PendlePrincipalToken.sol mintByYT/burnByYT
// Core machine: SY in → mint equal PT + YT sized by asset units at pyIndex;
// pre-expiry redeem burns PT+YT → SY; post-expiry PT alone redeems at frozen index;
// index is max(SY.exchangeRate, stored) — never falls.

module pendle {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val SCALE: int = 100           // index scale (1.0 = 100)
  pure val INIT_INDEX: int = 100
  pure val EXPIRY: int = 50

  var syLocked: int                   // SY held by YT contract
  var ptSupply: int
  var ytSupply: int
  var ptOf: int -> int
  var ytOf: int -> int
  var index: AccrualIndex             // pyIndex
  var syRate: int                     // SY.exchangeRate() external
  var time: int
  var expired: bool
  var firstIndexPostExpiry: int       // postExpiry.firstPYIndex

  action init: bool = all {
    syLocked' = 0,
    ptSupply' = 0,
    ytSupply' = 0,
    ptOf' = USERS.mapBy(_ => 0),
    ytOf' = USERS.mapBy(_ => 0),
    index' = initIndex(INIT_INDEX),
    syRate' = INIT_INDEX,
    time' = 0,
    expired' = false,
    firstIndexPostExpiry' = 0,
  }

  // Refresh pyIndex = max(syRate, stored) (PendleYieldToken.sol:403-410)
  action updateIndex: bool = all {
    not(expired),
    index' = ratchetIndex(index, syRate, time),
    syLocked' = syLocked,
    ptSupply' = ptSupply,
    ytSupply' = ytSupply,
    ptOf' = ptOf,
    ytOf' = ytOf,
    syRate' = syRate,
    time' = time,
    expired' = expired,
    firstIndexPostExpiry' = firstIndexPostExpiry,
  }

  // mintPY (PendleYieldToken.sol:90) — SY in, equal PT+YT out
  action mintPY(u: int, syIn: int): bool = all {
    USERS.contains(u),
    not(expired),
    syIn > 0,
    val ix = max(index.stored, syRate)
    val py = mintPyAmount(syIn, ix, SCALE)
    all {
      py > 0,
      syLocked' = syLocked + syIn,
      ptSupply' = ptSupply + py,
      ytSupply' = ytSupply + py,
      ptOf' = ptOf.put(u, ptOf.get(u) + py),
      ytOf' = ytOf.put(u, ytOf.get(u) + py),
      index' = { stored: ix, lastTime: time },
      syRate' = syRate,
      time' = time,
      expired' = expired,
      firstIndexPostExpiry' = firstIndexPostExpiry,
    }
  }

  // redeemPY pre-expiry (PendleYieldToken.sol:131) — burn equal PT+YT
  action redeemPY(u: int, py: int): bool = all {
    USERS.contains(u),
    not(expired),
    py > 0,
    py <= ptOf.get(u),
    py <= ytOf.get(u),
    val ix = max(index.stored, syRate)
    val syOut = redeemSyFromPy(py, ix, SCALE)
    all {
      syOut > 0,
      syOut <= syLocked,
      syLocked' = syLocked - syOut,
      ptSupply' = ptSupply - py,
      ytSupply' = ytSupply - py,
      ptOf' = ptOf.put(u, ptOf.get(u) - py),
      ytOf' = ytOf.put(u, ytOf.get(u) - py),
      index' = { stored: ix, lastTime: time },
      syRate' = syRate,
      time' = time,
      expired' = expired,
      firstIndexPostExpiry' = firstIndexPostExpiry,
    }
  }

  // External SY rate move (source yield accrues or drawdown)
  action setSyRate(r: int): bool = all {
    r > 0,
    syRate' = r,
    // index only updates on interaction; stored may lag
    syLocked' = syLocked,
    ptSupply' = ptSupply,
    ytSupply' = ytSupply,
    ptOf' = ptOf,
    ytOf' = ytOf,
    index' = index,
    time' = time,
    expired' = expired,
    firstIndexPostExpiry' = firstIndexPostExpiry,
  }

  // Cross expiry (MiniHelpers.isCurrentlyExpired)
  action expire: bool = all {
    not(expired),
    time >= EXPIRY,
    expired' = true,
    firstIndexPostExpiry' = max(index.stored, syRate),
    index' = { stored: max(index.stored, syRate), lastTime: time },
    syLocked' = syLocked,
    ptSupply' = ptSupply,
    ytSupply' = ytSupply,
    ptOf' = ptOf,
    ytOf' = ytOf,
    syRate' = syRate,
    time' = time,
  }

  // Post-expiry: redeem PT only (YT burned already conceptually; PT redeems at firstIndex)
  action redeemPTPostExpiry(u: int, pt: int): bool = all {
    USERS.contains(u),
    expired,
    pt > 0,
    pt <= ptOf.get(u),
    val syOut = redeemSyFromPy(pt, firstIndexPostExpiry, SCALE)
    all {
      syOut <= syLocked,
      syLocked' = syLocked - syOut,
      ptSupply' = ptSupply - pt,
      ptOf' = ptOf.put(u, ptOf.get(u) - pt),
      // YT no longer needed for redeem; yt supply unchanged or already zeroed abstract
      ytSupply' = ytSupply,
      ytOf' = ytOf,
      index' = index,
      syRate' = syRate,
      time' = time,
      expired' = expired,
      firstIndexPostExpiry' = firstIndexPostExpiry,
    }
  }

  action tick: bool = all {
    time' = time + 1,
    syLocked' = syLocked,
    ptSupply' = ptSupply,
    ytSupply' = ytSupply,
    ptOf' = ptOf,
    ytOf' = ytOf,
    index' = index,
    syRate' = syRate,
    expired' = expired,
    firstIndexPostExpiry' = firstIndexPostExpiry,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(20).oneOf()
    nondet rate = 90.to(120).oneOf()
    any {
      updateIndex,
      mintPY(u, amt),
      redeemPY(u, amt),
      setSyRate(rate),
      expire,
      redeemPTPostExpiry(u, amt),
      tick,
    }
  }

  // PT supply == YT supply pre-expiry (mint/redeem symmetry)
  val ptYtParity: bool =
    expired or ptSupply == ytSupply

  // Index is a high-water mark relative to any past stored (monotone on update)
  val indexNonNeg: bool = index.stored > 0 and syRate > 0

  // SY locked covers PT notional at current index (pre-expiry)
  val backing: bool =
    if (expired) syLocked >= 0
    else pyBackingHolds(syLocked, ptSupply, ytSupply, max(index.stored, syRate), SCALE) or
         ptSupply == 0

  // ---------------------------------------------------------------------
  //  WITNESS (added by the interface-discipline council, 2026-08-06).
  //  `backing` (:196) is evaluated at max(index.stored, syRate) -- the RATCHETED
  //  index (common.qnt:71) -- while setSyRate (:104) permits syRate to FALL.
  //  If a reachable state has the index above the true rate, backing can hold on
  //  the stale index while failing on the real one. This asserts that cannot
  //  happen; [violation] means it can.
  // ---------------------------------------------------------------------
  val wit_staleIndexBacking: bool = not(and {
    syRate < index.stored,
    ptSupply > 0,
    not(pyBackingHolds(syLocked, ptSupply, ytSupply, syRate, SCALE)),
    backing,
  })

  // User balances match supplies
  val supplyMatch: bool =
    USERS.fold(0, (acc, u) => acc + ptOf.get(u)) == ptSupply and
    USERS.fold(0, (acc, u) => acc + ytOf.get(u)) == ytSupply
}
