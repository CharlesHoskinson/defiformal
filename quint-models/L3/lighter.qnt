// Lighter (ZkLighter) — proven sequencer with priority requests and desert mode.
// Source: protocol-repos/perp/elliottech_lighter-contracts/contracts/
//   ZkLighter.sol deposit/withdraw/createOrder/activateDesertMode/performDesert
//   Storage.sol PriorityRequest, StoredBatchInfo, desertMode
//   Config.sol PRIORITY_EXPIRATION = 14 days
// Core machine (on-chain surface): deposit → priority request queue → batch commit/verify
// → execute; if oldest priority expires unexecuted → desertMode → proof-based exit.

module lighter {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val PRIORITY_EXPIRATION: int = 14

  type Mode = Normal | Desert
  type ReqKind = DepositReq | WithdrawReq

  type PriorityReq = {
    owner: int,
    amount: int,
    readyAt: int,
    kind: ReqKind,
  }

  var balances: int -> int          // L1 balances held by user (withdrawn / not yet on L2)
  var l2Balances: int -> int        // abstract L2 account tree
  var priorityQueue: List[PriorityReq]
  var executedPriority: int
  var committedBatches: int
  var verifiedBatches: int
  var mode: Mode
  var time: int
  var totalDeposited: int           // USDC locked in the L1 contract

  action init: bool = all {
    balances' = USERS.mapBy(_ => 0),
    l2Balances' = USERS.mapBy(_ => 0),
    priorityQueue' = List(),
    executedPriority' = 0,
    committedBatches' = 0,
    verifiedBatches' = 0,
    mode' = Normal,
    time' = 0,
    totalDeposited' = 0,
  }

  // ZkLighter.deposit — lock USDC, enqueue L2 credit
  action deposit(u: int, amount: int): bool = all {
    USERS.contains(u),
    mode == Normal,
    amount > 0,
    totalDeposited' = totalDeposited + amount,
    priorityQueue' = priorityQueue.append({
      owner: u, amount: amount, readyAt: time + PRIORITY_EXPIRATION, kind: DepositReq
    }),
    balances' = balances,
    l2Balances' = l2Balances,
    executedPriority' = executedPriority,
    committedBatches' = committedBatches,
    verifiedBatches' = verifiedBatches,
    mode' = mode,
    time' = time,
  }

  // Sequencer executes head priority request
  action executePriority: bool = all {
    mode == Normal,
    priorityQueue.length() > 0,
    val hd = priorityQueue.head()
    all {
      if (hd.kind == DepositReq)
        all {
          l2Balances' = l2Balances.put(hd.owner, l2Balances.get(hd.owner) + hd.amount),
          balances' = balances,
          totalDeposited' = totalDeposited,
        }
      else
        all {
          // withdraw: L2 already debited at request time; pay out on L1
          balances' = balances.put(hd.owner, balances.get(hd.owner) + hd.amount),
          totalDeposited' = totalDeposited - hd.amount,
          l2Balances' = l2Balances,
        },
      priorityQueue' = priorityQueue.tail(),
      executedPriority' = executedPriority + 1,
      committedBatches' = committedBatches + 1,
      verifiedBatches' = verifiedBatches + 1,
      mode' = mode,
      time' = time,
    }
  }

  // ZkLighter.withdraw — debit L2, enqueue L1 payout
  action requestWithdraw(u: int, amount: int): bool = all {
    USERS.contains(u),
    mode == Normal,
    amount > 0,
    amount <= l2Balances.get(u),
    l2Balances' = l2Balances.put(u, l2Balances.get(u) - amount),
    priorityQueue' = priorityQueue.append({
      owner: u, amount: amount, readyAt: time + PRIORITY_EXPIRATION, kind: WithdrawReq
    }),
    balances' = balances,
    executedPriority' = executedPriority,
    committedBatches' = committedBatches,
    verifiedBatches' = verifiedBatches,
    totalDeposited' = totalDeposited,
    mode' = mode,
    time' = time,
  }

  // ZkLighter.activateDesertMode — oldest priority past expiration
  action activateDesert: bool = all {
    mode == Normal,
    priorityQueue.length() > 0,
    priorityQueue.head().readyAt <= time,
    mode' = Desert,
    balances' = balances,
    l2Balances' = l2Balances,
    priorityQueue' = priorityQueue,
    executedPriority' = executedPriority,
    committedBatches' = committedBatches,
    verifiedBatches' = verifiedBatches,
    totalDeposited' = totalDeposited,
    time' = time,
  }

  // performDesert — exit L2 balance against frozen root
  action desertExit(u: int): bool = all {
    USERS.contains(u),
    mode == Desert,
    val amt = l2Balances.get(u)
    all {
      amt > 0,
      amt <= totalDeposited,
      l2Balances' = l2Balances.put(u, 0),
      balances' = balances.put(u, balances.get(u) + amt),
      totalDeposited' = totalDeposited - amt,
      priorityQueue' = priorityQueue,
      executedPriority' = executedPriority,
      committedBatches' = committedBatches,
      verifiedBatches' = verifiedBatches,
      mode' = mode,
      time' = time,
    }
  }

  action tick: bool = all {
    time' = time + 1,
    balances' = balances,
    l2Balances' = l2Balances,
    priorityQueue' = priorityQueue,
    executedPriority' = executedPriority,
    committedBatches' = committedBatches,
    verifiedBatches' = verifiedBatches,
    mode' = mode,
    totalDeposited' = totalDeposited,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(20).oneOf()
    any {
      deposit(u, amt),
      executePriority,
      requestWithdraw(u, amt),
      activateDesert,
      desertExit(u),
      tick,
    }
  }

  // Funds non-negative
  val fundsNonNeg: bool =
    totalDeposited >= 0 and
    USERS.forall(u => balances.get(u) >= 0 and l2Balances.get(u) >= 0)

  // Locked USDC covers L2 balances + outstanding withdraw requests still in queue
  val depositedCovers: bool = {
    val qWithdraw = priorityQueue.foldl(0, (acc, r) =>
      if (r.kind == WithdrawReq) acc + r.amount else acc)
    val qDeposit = priorityQueue.foldl(0, (acc, r) =>
      if (r.kind == DepositReq) acc + r.amount else acc)
    val l2 = USERS.fold(0, (acc, u) => acc + l2Balances.get(u))
    // totalDeposited = l2 + qDeposit + qWithdraw  (withdraw still locked until execute)
    totalDeposited == l2 + qDeposit + qWithdraw
  }

  val batchOrder: bool = verifiedBatches <= committedBatches
}
