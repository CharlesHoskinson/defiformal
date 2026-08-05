// Panoptic — perpetual options via Uniswap concentrated-liquidity chunks.
// Sources:
//   panoptic-labs_panoptic-v2-core/contracts/PanopticPool.sol dispatch (L697)
//   contracts/CollateralTracker.sol deposit/withdraw (L557, L708), settleMint/Burn
//   contracts/RiskEngine.sol — isAccountSolvent, utilization collateral, force exercise
//   protocol-analysis/invariants.md:
//     totalAssets = deposited + inAMM + unrealizedInterest
//     solvency at oracle tick; liquidation bonus; force-exercise cost
// Scope: one pool, one collateral token, abstract long/short "chunk" positions,
//   utilization-scaled collateral, liquidate + force-exercise.
// NOT covered: multi-leg tokenId encoding, SFPM mint/burn Uniswap details,
//   premia streamia math (VEGOID), oracle EMA/median ring, builder fees.

module panoptic {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2)
  pure val AMOUNTS: Set[int] = Set(10, 20, 40)
  pure val NOTIONALS: Set[int] = Set(10, 20)
  pure val BASE_BPS: int = 2000      // 20% base collateral
  pure val UTIL_BPS: int = 50        // +0.5% per util point (abstract)
  pure val MAX_UTIL: int = 90

  type Side = Long | Short | Flat

  type Chunk = {
    side: Side,
    notional: int,
    // liquidity removed (long) or added (short), abstract units
  }

  pure def emptyChunk: Chunk = { side: Flat, notional: 0 }

  var deposited: int           // CollateralTracker s_depositedAssets
  var inAmm: int               // assets deployed in Uniswap via short positions
  var totalShares: int
  var shares: int -> int
  var position: int -> Chunk
  var required: int -> int     // maintenance collateral requirement per user
  var poolLocked: bool

  pure def totalAssets(dep: int, amm: int): int = dep + amm

  pure def poolUtil(amm: int, dep: int): int =
    utilization(amm, dep + amm)

  action init: bool = all {
    // virtual share stone like ERC4626 offset
    deposited' = 1,
    inAmm' = 0,
    totalShares' = 1,
    shares' = USERS.mapBy(_ => 0),
    position' = USERS.mapBy(_ => emptyChunk),
    required' = USERS.mapBy(_ => 0),
    poolLocked' = false,
  }

  /// CollateralTracker.deposit — ERC4626 shares against totalAssets.
  action deposit(u: int, assets: int): bool = {
    val ta = totalAssets(deposited, inAmm)
    val sh = if (totalShares == 0) assets
             else mulDivDown(assets, totalShares, ta)
    all {
      USERS.contains(u),
      AMOUNTS.contains(assets),
      assets > 0,
      not(poolLocked),
      sh > 0,
      deposited' = deposited + assets,
      totalShares' = totalShares + sh,
      shares' = shares.put(u, shares.get(u) + sh),
      inAmm' = inAmm,
      position' = position,
      required' = required,
      poolLocked' = poolLocked,
    }
  }

  /// CollateralTracker.withdraw — only if solvent after and no lock.
  action withdraw(u: int, sh: int): bool = {
    val ta = totalAssets(deposited, inAmm)
    val assets = mulDivDown(sh, ta, totalShares)
    val pos = position.get(u)
    all {
      USERS.contains(u),
      AMOUNTS.contains(sh),
      sh > 0,
      shares.get(u) >= sh,
      // free shares value must still cover requirement after withdraw
      mulDivDown(shares.get(u) - sh, ta, totalShares) >= required.get(u),
      deposited >= assets,
      not(poolLocked),
      // cannot withdraw while short without closing (simplified: any open pos blocks)
      pos.side == Flat,
      deposited' = deposited - assets,
      totalShares' = totalShares - sh,
      shares' = shares.put(u, shares.get(u) - sh),
      inAmm' = inAmm,
      position' = position,
      required' = required,
      poolLocked' = poolLocked,
    }
  }

  /// dispatch mint short — add liquidity chunk to AMM; borrow from PLPs.
  action mintShort(u: int, notional: int): bool = {
    val util = poolUtil(inAmm + notional, deposited)
    val req = utilCollateralReq(notional, util, BASE_BPS, UTIL_BPS)
    val ta = totalAssets(deposited, inAmm)
    val collat = mulDivDown(shares.get(u), ta, totalShares)
    all {
      USERS.contains(u),
      NOTIONALS.contains(notional),
      position.get(u).side == Flat,
      notional > 0,
      not(poolLocked),
      util <= MAX_UTIL,
      collat >= req,
      deposited >= notional, // move deposited → inAmm
      deposited' = deposited - notional,
      inAmm' = inAmm + notional,
      position' = position.put(u, { side: Short, notional: notional }),
      required' = required.put(u, req),
      totalShares' = totalShares,
      shares' = shares,
      poolLocked' = poolLocked,
    }
  }

  /// dispatch mint long — remove seller liquidity from AMM (buy option).
  action mintLong(u: int, notional: int): bool = {
    val util = poolUtil(inAmm, deposited) // util from existing shorts
    val req = utilCollateralReq(notional, util, BASE_BPS / 2, UTIL_BPS) // buyers lighter
    val ta = totalAssets(deposited, inAmm)
    val collat = mulDivDown(shares.get(u), ta, totalShares)
    all {
      USERS.contains(u),
      NOTIONALS.contains(notional),
      position.get(u).side == Flat,
      notional > 0,
      not(poolLocked),
      inAmm >= notional, // must have short liquidity to remove
      collat >= req,
      inAmm' = inAmm - notional,
      deposited' = deposited + notional, // tokens return to tracker
      position' = position.put(u, { side: Long, notional: notional }),
      required' = required.put(u, req),
      totalShares' = totalShares,
      shares' = shares,
      poolLocked' = poolLocked,
    }
  }

  /// burn / close position — reverse of mint.
  action burn(u: int): bool = {
    val pos = position.get(u)
    all {
      USERS.contains(u),
      pos.side != Flat,
      not(poolLocked),
      if (pos.side == Short)
        all {
          inAmm >= pos.notional,
          inAmm' = inAmm - pos.notional,
          deposited' = deposited + pos.notional,
        }
      else all {
          // long close: put liquidity back into AMM
          deposited >= pos.notional,
          deposited' = deposited - pos.notional,
          inAmm' = inAmm + pos.notional,
        },
      position' = position.put(u, emptyChunk),
      required' = required.put(u, 0),
      totalShares' = totalShares,
      shares' = shares,
      poolLocked' = poolLocked,
    }
  }

  /// dispatchFrom liquidate — target insolvent; liquidator receives bonus shares.
  action liquidate(liq: int, target: int): bool = {
    val ta = totalAssets(deposited, inAmm)
    val collat = mulDivDown(shares.get(target), ta, totalShares)
    val req = required.get(target)
    val pos = position.get(target)
    val bonus = min(collat / 2, max(0, req - collat))
    val move = min(shares.get(target), max(1, bonus))
    all {
      USERS.contains(liq),
      USERS.contains(target),
      liq != target,
      pos.side != Flat,
      collat < req, // insolvent
      not(poolLocked),
      // close target position
      if (pos.side == Short)
        all {
          inAmm >= pos.notional,
          inAmm' = inAmm - pos.notional,
          deposited' = deposited + pos.notional,
        }
      else all {
          deposited' = deposited,
          inAmm' = inAmm,
        },
      // transfer bonus shares target → liquidator (if target has shares)
      shares.get(target) >= move,
      shares' = shares
        .put(target, shares.get(target) - move)
        .put(liq, shares.get(liq) + move),
      position' = position.put(target, emptyChunk),
      required' = required.put(target, 0),
      totalShares' = totalShares,
      poolLocked' = poolLocked,
    }
  }

  /// forceExercise — seller forces long out-of-range; pays fee to long.
  action forceExercise(seller: int, buyer: int, fee: int): bool = {
    val bpos = position.get(buyer)
    all {
      USERS.contains(seller),
      USERS.contains(buyer),
      seller != buyer,
      bpos.side == Long,
      AMOUNTS.contains(fee),
      fee >= 0,
      shares.get(seller) >= fee, // fee in shares abstractly
      not(poolLocked),
      // restore liquidity to AMM
      deposited >= bpos.notional,
      deposited' = deposited - bpos.notional,
      inAmm' = inAmm + bpos.notional,
      shares' = shares
        .put(seller, shares.get(seller) - fee)
        .put(buyer, shares.get(buyer) + fee),
      position' = position.put(buyer, emptyChunk),
      required' = required.put(buyer, 0),
      totalShares' = totalShares,
      poolLocked' = poolLocked,
    }
  }

  /// Guardian lockPool
  action lockPool: bool = all {
    poolLocked' = true,
    deposited' = deposited,
    inAmm' = inAmm,
    totalShares' = totalShares,
    shares' = shares,
    position' = position,
    required' = required,
  }

  action unlockPool: bool = all {
    poolLocked' = false,
    deposited' = deposited,
    inAmm' = inAmm,
    totalShares' = totalShares,
    shares' = shares,
    position' = position,
    required' = required,
  }

  action step: bool = any {
    nondet u = USERS.oneOf()
    nondet a = AMOUNTS.oneOf()
    deposit(u, a),
    nondet u2 = USERS.oneOf()
    nondet s = AMOUNTS.oneOf()
    withdraw(u2, s),
    nondet u3 = USERS.oneOf()
    nondet n = NOTIONALS.oneOf()
    mintShort(u3, n),
    nondet u4 = USERS.oneOf()
    nondet n2 = NOTIONALS.oneOf()
    mintLong(u4, n2),
    nondet u5 = USERS.oneOf()
    burn(u5),
    nondet l = USERS.oneOf()
    nondet t = USERS.oneOf()
    liquidate(l, t),
    nondet se = USERS.oneOf()
    nondet bu = USERS.oneOf()
    nondet f = AMOUNTS.oneOf()
    forceExercise(se, bu, f),
    lockPool,
    unlockPool,
  }

  /// CollateralTracker invariant (simplified, no interest):
  /// totalAssets = deposited + inAmm; totalShares = 1 + user shares.
  val assetShareConsistency: bool = {
    val userSum = mapSum(shares, USERS)
    and {
      deposited >= 0,
      inAmm >= 0,
      totalShares == 1 + userSum,
      totalAssets(deposited, inAmm) >= 1,
      nonNegMap(shares, USERS),
      nonNegMap(required, USERS),
    }
  }

  /// InAMM notional equals sum of short position notionals
  /// minus sum of long notionals removed (long removes from AMM).
  /// After mintShort: inAmm += n; mintLong: inAmm -= n.
  /// At any time: inAmm == sum(short.notional) is NOT true after longs.
  /// Conservation: deposited + inAmm is preserved by mint/burn (moved, not created).
  val noNegativeInventory: bool = deposited >= 0 and inAmm >= 0
}
