// ether.fi — eETH rebasing share pool + weETH wrapper + withdrawal request.
// Sources:
//   etherfi-protocol_smart-contracts/src/core/LiquidityPool.sol
//     deposit, rebase (455), requestWithdraw (313),
//     getTotalPooledEther (730) = totalValueOutOfLp + totalValueInLp,
//     sharesForAmount (738), amountForShare (767)
//   .../core/WeETH.sol — wrap/unwrap at share rate
// Scope: dual pool-value counters, share mint/burn, admin rebase with bound,
//        standard withdrawal request (instant/priority doors collapsed).
// NOT covered: AuctionManager bids, EigenPod restaking, rate-limit buckets, blacklist.

module etherfi {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val MAX_QUEUE: int = 5
  pure val MAX_REBASE_BPS: int = 1000

  var shares: int -> int
  var totalShares: int
  var totalValueInLp: int
  var totalValueOutOfLp: int
  var queue: int -> QueueEntry
  var nextRequestId: int
  var weethShares: int -> int

  pure def totalPooledEther(inLp: int, outLp: int): int = inLp + outLp

  pure def toShares(amount: int, tpe: int, ts: int): int =
    if (tpe == 0) amount else assetsToShares(amount, tpe, ts)

  action init: bool = all {
    shares' = USERS.mapBy(_ => 0),
    totalShares' = 0,
    totalValueInLp' = 0,
    totalValueOutOfLp' = 0,
    queue' = 1.to(MAX_QUEUE).mapBy(_ => emptyQueueEntry(0)),
    nextRequestId' = 1,
    weethShares' = USERS.mapBy(_ => 0),
  }

  action deposit(u: int, amount: int): bool = {
    val tpe = totalPooledEther(totalValueInLp, totalValueOutOfLp)
    val sh = if (totalShares == 0) amount else toShares(amount, tpe, totalShares)
    all {
      USERS.contains(u),
      amount > 0,
      sh > 0,
      shares' = shares.put(u, shares.get(u) + sh),
      totalShares' = totalShares + sh,
      totalValueInLp' = totalValueInLp + amount,
      totalValueOutOfLp' = totalValueOutOfLp,
      queue' = queue,
      nextRequestId' = nextRequestId,
      weethShares' = weethShares,
    }
  }

  /// rebase — LiquidityPool.sol:455
  action rebase(accrued: int): bool = {
    val tpe = totalPooledEther(totalValueInLp, totalValueOutOfLp)
    val maxUp = if (tpe == 0) 50 else (tpe * MAX_REBASE_BPS) / BPS
    all {
      accrued >= 0 - 50,
      accrued <= 50,
      accrued <= 0 or accrued <= maxUp or tpe == 0,
      totalValueOutOfLp + accrued >= 0,
      totalValueOutOfLp' = totalValueOutOfLp + accrued,
      totalValueInLp' = totalValueInLp,
      shares' = shares,
      totalShares' = totalShares,
      queue' = queue,
      nextRequestId' = nextRequestId,
      weethShares' = weethShares,
    }
  }

  action stakeOut(amount: int): bool = all {
    amount > 0,
    totalValueInLp >= amount,
    totalValueInLp' = totalValueInLp - amount,
    totalValueOutOfLp' = totalValueOutOfLp + amount,
    shares' = shares,
    totalShares' = totalShares,
    queue' = queue,
    nextRequestId' = nextRequestId,
    weethShares' = weethShares,
  }

  action requestWithdraw(u: int, amount: int): bool = {
    val tpe = totalPooledEther(totalValueInLp, totalValueOutOfLp)
    val sh = if (tpe == 0) 0 else assetsToSharesCeil(amount, tpe, totalShares)
    val rid = nextRequestId
    val fromOut = if (totalValueOutOfLp >= amount) amount else totalValueOutOfLp
    val fromIn = amount - fromOut
    all {
      USERS.contains(u),
      amount > 0,
      sh > 0,
      shares.get(u) >= sh,
      rid <= MAX_QUEUE,
      totalValueInLp + totalValueOutOfLp >= amount,
      shares' = shares.put(u, shares.get(u) - sh),
      totalShares' = totalShares - sh,
      totalValueOutOfLp' = totalValueOutOfLp - fromOut,
      totalValueInLp' = totalValueInLp - fromIn,
      queue' = queue.put(rid, {
        owner: u,
        shares: sh,
        assetsAtRequest: amount,
        finalized: true,
        claimed: false,
      }),
      nextRequestId' = rid + 1,
      weethShares' = weethShares,
    }
  }

  /// wrap eETH → weETH (WeETH.sol:98)
  action wrap(u: int, eethAmount: int): bool = {
    val tpe = totalPooledEther(totalValueInLp, totalValueOutOfLp)
    val sh = toShares(eethAmount, tpe, totalShares)
    all {
      USERS.contains(u),
      eethAmount > 0,
      sh > 0,
      shares.get(u) >= sh,
      shares' = shares.put(u, shares.get(u) - sh),
      weethShares' = weethShares.put(u, weethShares.get(u) + sh),
      totalShares' = totalShares,
      totalValueInLp' = totalValueInLp,
      totalValueOutOfLp' = totalValueOutOfLp,
      queue' = queue,
      nextRequestId' = nextRequestId,
    }
  }

  action unwrap(u: int, weAmt: int): bool = all {
    USERS.contains(u),
    weAmt > 0,
    weethShares.get(u) >= weAmt,
    weethShares' = weethShares.put(u, weethShares.get(u) - weAmt),
    shares' = shares.put(u, shares.get(u) + weAmt),
    totalShares' = totalShares,
    totalValueInLp' = totalValueInLp,
    totalValueOutOfLp' = totalValueOutOfLp,
    queue' = queue,
    nextRequestId' = nextRequestId,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amount = 1.to(30).oneOf()
    nondet accruedRaw = 0.to(30).oneOf()
    nondet stakeAmt = 1.to(20).oneOf()
    any {
      deposit(u, amount),
      rebase(accruedRaw - 10),
      stakeOut(stakeAmt),
      requestWithdraw(u, amount),
      wrap(u, amount),
      unwrap(u, amount),
    }
  }

  val pooledNonNeg: bool =
    totalValueInLp >= 0 and totalValueOutOfLp >= 0

  val nonNegative: bool = and {
    totalShares >= 0,
    nonNegMap(shares, USERS),
    nonNegMap(weethShares, USERS),
  }

  val shareBound: bool =
    mapSum(shares, USERS) + mapSum(weethShares, USERS) <= totalShares
    or totalShares == 0

  val safety: bool = and {
    pooledNonNeg,
    nonNegative,
    shareBound,
  }
}
