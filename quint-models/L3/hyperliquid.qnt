// Hyperliquid Bridge2 — the only open-sourced surface of Hyperliquid.
// Source: protocol-repos/perp/hyperliquid-dex_contracts/Bridge2.sol
// Core machine: deposit USDC → L1 account (off-chain HyperCore not modelled);
// requestWithdrawal with validator quorum → dispute period → finalize.
// Finding: the perp state machine (book, margin, ADL, HLP) is NOT in this repo —
// only the custody bridge with hot/cold validator sets and emergency lock.

module hyperliquid {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val DISPUTE_PERIOD: int = 5     // abstract of disputePeriodSeconds
  pure val VALIDATOR_POWER: int = 100
  pure val QUORUM: int = 67            // >2/3

  type WStatus = Pending | Finalized | Invalidated

  type Withdrawal = {
    user: int,
    amount: int,
    requestedAt: int,
    status: WStatus,
  }

  var bridgeBalance: int              // USDC locked in Bridge2
  var userDeposited: int -> int       // cumulative net deposits (off-chain ledger proxy)
  var withdrawals: int -> Withdrawal  // keyed by nonce id
  var nextNonce: int
  var locked: bool                    // emergency lock (locker threshold)
  var time: int

  pure def emptyWd: Withdrawal =
    { user: 0, amount: 0, requestedAt: 0, status: Finalized }

  action init: bool = all {
    bridgeBalance' = 0,
    userDeposited' = USERS.mapBy(_ => 0),
    withdrawals' = 0.to(20).mapBy(_ => emptyWd),
    nextNonce' = 0,
    locked' = false,
    time' = 0,
  }

  // depositWithPermit (Bridge2.sol:798) — simplified deposit
  action deposit(u: int, amount: int): bool = all {
    USERS.contains(u),
    not(locked),
    amount > 0,
    bridgeBalance' = bridgeBalance + amount,
    userDeposited' = userDeposited.put(u, userDeposited.get(u) + amount),
    withdrawals' = withdrawals,
    nextNonce' = nextNonce,
    locked' = locked,
    time' = time,
  }

  // requestWithdrawal (Bridge2.sol:277) — requires validator signatures (abstracted as power)
  action requestWithdrawal(u: int, amount: int, power: int): bool = all {
    USERS.contains(u),
    not(locked),
    amount > 0,
    power >= QUORUM,
    amount <= userDeposited.get(u),
    amount <= bridgeBalance,
    nextNonce < 20,
    val n = nextNonce
    all {
      withdrawals' = withdrawals.put(n, {
        user: u, amount: amount, requestedAt: time, status: Pending
      }),
      nextNonce' = nextNonce + 1,
      // funds still in bridge during dispute
      bridgeBalance' = bridgeBalance,
      userDeposited' = userDeposited,
      locked' = locked,
      time' = time,
    }
  }

  // batchedFinalizeWithdrawals after dispute period (Bridge2.sol:376)
  action finalizeWithdrawal(n: int): bool = all {
    n >= 0 and n < nextNonce,
    val w = withdrawals.get(n)
    all {
      w.status == Pending,
      time >= w.requestedAt + DISPUTE_PERIOD,
      w.amount <= bridgeBalance,
      withdrawals' = withdrawals.put(n, { ...w, status: Finalized }),
      bridgeBalance' = bridgeBalance - w.amount,
      userDeposited' = userDeposited.put(w.user, userDeposited.get(w.user) - w.amount),
      nextNonce' = nextNonce,
      locked' = locked,
      time' = time,
    }
  }

  // invalidateWithdrawals (Bridge2.sol:676) — cold validators during dispute
  action invalidateWithdrawal(n: int, coldPower: int): bool = all {
    n >= 0 and n < nextNonce,
    coldPower >= QUORUM,
    val w = withdrawals.get(n)
    all {
      w.status == Pending,
      time < w.requestedAt + DISPUTE_PERIOD,
      withdrawals' = withdrawals.put(n, { ...w, status: Invalidated }),
      bridgeBalance' = bridgeBalance,
      userDeposited' = userDeposited,
      nextNonce' = nextNonce,
      locked' = locked,
      time' = time,
    }
  }

  // voteEmergencyLock (Bridge2.sol:746)
  action emergencyLock: bool = all {
    not(locked),
    locked' = true,
    bridgeBalance' = bridgeBalance,
    userDeposited' = userDeposited,
    withdrawals' = withdrawals,
    nextNonce' = nextNonce,
    time' = time,
  }

  action tick: bool = all {
    time' = time + 1,
    bridgeBalance' = bridgeBalance,
    userDeposited' = userDeposited,
    withdrawals' = withdrawals,
    nextNonce' = nextNonce,
    locked' = locked,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(30).oneOf()
    nondet power = Set(50, 67, 80, 100).oneOf()
    nondet n = 0.to(5).oneOf()
    any {
      deposit(u, amt),
      requestWithdrawal(u, amt, power),
      finalizeWithdrawal(n),
      invalidateWithdrawal(n, power),
      emergencyLock,
      tick,
    }
  }

  // Bridge balance and user ledgers non-negative.
  // NOTE: bridgeBalance >= sum(pending) does NOT hold in code — requestWithdrawal
  // only checks the individual amount against bridgeBalance/userDeposited; validators
  // may co-sign overlapping withdrawals. Finalize checks per-message. Recorded as
  // finding: over-subscription of pending withdrawals is a code-level hazard.
  val bridgeNonNeg: bool = bridgeBalance >= 0

  val depositsNonNeg: bool =
    USERS.forall(u => userDeposited.get(u) >= 0)

  // Stronger property we hoped for (fails without validator honesty) — kept as witness target
  val bridgeCoversPending: bool = {
    val pending = 0.to(20).fold(0, (acc, n) => {
      val w = withdrawals.get(n)
      if (w.status == Pending) acc + w.amount else acc
    })
    bridgeBalance >= pending
  }
}
