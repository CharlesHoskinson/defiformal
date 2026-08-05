// Lido — stETH share ledger + oracle rebase + withdrawal queue.
// Sources:
//   lidofinance_core/contracts/0.4.24/StETH.sol
//     getSharesByPooledEth (318), getPooledEthByShares (329)
//   lidofinance_core/contracts/0.4.24/Lido.sol
//     submit (508), _submit (1253)
//   lidofinance_core/contracts/0.8.9/WithdrawalQueueBase.sol
// Scope: pooled share accounting, rebase of totalPooledEther, simple withdrawal queue.
// NOT covered: staking modules, DepositSecurityModule, validator exit signalling, CSM, stVaults.

module lido {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val MAX_QUEUE: int = 5

  var shares: int -> int
  var totalShares: int
  var totalPooledEther: int
  var queue: int -> QueueEntry
  var nextRequestId: int
  var lastFinalizedId: int
  var ethBuffered: int

  pure def ethToShares(ethAmt: int, tpe: int, ts: int): int =
    assetsToShares(ethAmt, tpe, ts)

  pure def sharesToEth(sh: int, tpe: int, ts: int): int =
    sharesToAssets(sh, tpe, ts)

  action init: bool = all {
    shares' = USERS.mapBy(_ => 0),
    totalShares' = 1,
    totalPooledEther' = 1,
    queue' = 1.to(MAX_QUEUE).mapBy(_ => emptyQueueEntry(0)),
    nextRequestId' = 1,
    lastFinalizedId' = 0,
    ethBuffered' = 0,
  }

  /// submit — Lido.sol:508
  action submit(u: int, ethAmt: int): bool = {
    val sh = ethToShares(ethAmt, totalPooledEther, totalShares)
    all {
      USERS.contains(u),
      ethAmt > 0,
      sh > 0,
      shares' = shares.put(u, shares.get(u) + sh),
      totalShares' = totalShares + sh,
      totalPooledEther' = totalPooledEther + ethAmt,
      ethBuffered' = ethBuffered + ethAmt,
      queue' = queue,
      nextRequestId' = nextRequestId,
      lastFinalizedId' = lastFinalizedId,
    }
  }

  action rebase(delta: int): bool = all {
    totalPooledEther + delta >= 1,
    delta >= 0 - 50,
    delta <= 50,
    totalPooledEther' = totalPooledEther + delta,
    ethBuffered' = if (delta > 0) ethBuffered + delta else ethBuffered,
    shares' = shares,
    totalShares' = totalShares,
    queue' = queue,
    nextRequestId' = nextRequestId,
    lastFinalizedId' = lastFinalizedId,
  }

  action requestWithdraw(u: int, sh: int): bool = {
    val assets = sharesToEth(sh, totalPooledEther, totalShares)
    val rid = nextRequestId
    all {
      USERS.contains(u),
      sh > 0,
      shares.get(u) >= sh,
      rid <= MAX_QUEUE,
      shares' = shares.put(u, shares.get(u) - sh),
      totalShares' = totalShares - sh,
      totalPooledEther' = totalPooledEther - assets,
      queue' = queue.put(rid, {
        owner: u,
        shares: sh,
        assetsAtRequest: assets,
        finalized: false,
        claimed: false,
      }),
      nextRequestId' = rid + 1,
      lastFinalizedId' = lastFinalizedId,
      ethBuffered' = ethBuffered,
    }
  }

  action finalize(rid: int): bool = {
    val e = queue.get(rid)
    all {
      rid > lastFinalizedId,
      rid < nextRequestId,
      not(e.finalized),
      not(e.claimed),
      ethBuffered >= e.assetsAtRequest,
      ethBuffered' = ethBuffered - e.assetsAtRequest,
      queue' = queue.put(rid, {
        owner: e.owner,
        shares: e.shares,
        assetsAtRequest: e.assetsAtRequest,
        finalized: true,
        claimed: false,
      }),
      lastFinalizedId' = rid,
      shares' = shares,
      totalShares' = totalShares,
      totalPooledEther' = totalPooledEther,
      nextRequestId' = nextRequestId,
    }
  }

  action claim(rid: int): bool = {
    val e = queue.get(rid)
    all {
      e.finalized,
      not(e.claimed),
      queue' = queue.put(rid, {
        owner: e.owner,
        shares: e.shares,
        assetsAtRequest: e.assetsAtRequest,
        finalized: true,
        claimed: true,
      }),
      shares' = shares,
      totalShares' = totalShares,
      totalPooledEther' = totalPooledEther,
      nextRequestId' = nextRequestId,
      lastFinalizedId' = lastFinalizedId,
      ethBuffered' = ethBuffered,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet ethAmt = 1.to(30).oneOf()
    nondet sh = 1.to(20).oneOf()
    nondet delta = 0.to(40).oneOf()
    nondet rid = 1.to(MAX_QUEUE).oneOf()
    any {
      submit(u, ethAmt),
      // positive-only rebase in step to avoid negative-range syntax issues;
      // negative rebase exercised by setting delta small via separate path:
      rebase(delta - 20),
      requestWithdraw(u, sh),
      finalize(rid),
      claim(rid),
    }
  }

  val nonNegative: bool = and {
    totalShares >= 1,
    totalPooledEther >= 1,
    ethBuffered >= 0,
    nonNegMap(shares, USERS),
  }

  val rateDefined: bool = totalShares > 0 and totalPooledEther > 0

  val queueConsistent: bool =
    1.to(MAX_QUEUE).forall(rid => {
      val e = queue.get(rid)
      not(e.claimed) or e.finalized
    })

  val shareBound: bool = mapSum(shares, USERS) <= totalShares

  val safety: bool = and {
    nonNegative,
    rateDefined,
    queueConsistent,
    shareBound,
  }
}
