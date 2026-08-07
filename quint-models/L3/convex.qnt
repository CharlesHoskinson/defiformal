// Convex Finance — gauge booster + permanent CRV escrow + streaming rewards.
// Source: protocol-repos/yield/convex-eth_platform/contracts/contracts/
//   Booster.sol deposit/withdraw/earmarkRewards (1:1 LP stake into Curve gauge)
//   CrvDepositor.sol deposit → cvxCRV, locks CRV permanently via _lockCurve
//   BaseRewardPool.sol rewardPerToken streaming index
// Core machines (two):
//   (1) Pool stake: LP in → receipt 1:1, withdraw anytime, harvest streams rewards
//   (2) CRV lock: CRV in → permanent escrow, cvxCRV out, no redeem

module convex {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val DURATION: int = 7          // reward stream duration abstract

  // --- Pool staking (Booster + BaseRewardPool) ---
  var staked: int -> int              // per-user LP staked (1:1 receipt)
  var totalStaked: int
  var rewardIndex: AccrualIndex
  var rewardRate: int
  var userPaid: int -> int            // userRewardPerTokenPaid
  var earned: int -> int              // accrued but unclaimed
  var rewardBudget: int               // tokens left to stream

  // --- Permanent CRV escrow (CrvDepositor) ---
  var crvEscrow: int                  // permanent locked CRV
  var cvxCrvSupply: int
  var cvxCrvOf: int -> int
  var time: int

  action init: bool = all {
    staked' = USERS.mapBy(_ => 0),
    totalStaked' = 0,
    rewardIndex' = initIndex(0),
    rewardRate' = 0,
    userPaid' = USERS.mapBy(_ => 0),
    earned' = USERS.mapBy(_ => 0),
    rewardBudget' = 0,
    crvEscrow' = 0,
    cvxCrvSupply' = 0,
    cvxCrvOf' = USERS.mapBy(_ => 0),
    time' = 0,
  }

  pure def pending(u: int, stakedU: int, paid: int, ix: int): int =
    divFloor(stakedU * (ix - paid), 1)   // index already per-token units

  // Booster.deposit (Booster.sol:250) — 1:1 stake
  action depositLP(u: int, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    // settle rewards first (updateReward)
    val ix = rewardIndex.stored
    val e = earned.get(u) + pending(u, staked.get(u), userPaid.get(u), ix)
    all {
      staked' = staked.put(u, staked.get(u) + amount),
      totalStaked' = totalStaked + amount,
      earned' = earned.put(u, e),
      userPaid' = userPaid.put(u, ix),
      rewardIndex' = rewardIndex,
      rewardRate' = rewardRate,
      rewardBudget' = rewardBudget,
      crvEscrow' = crvEscrow,
      cvxCrvSupply' = cvxCrvSupply,
      cvxCrvOf' = cvxCrvOf,
      time' = time,
    }
  }

  // Booster.withdraw (Booster.sol:326) — anytime, no fee
  action withdrawLP(u: int, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    amount <= staked.get(u),
    val ix = rewardIndex.stored
    val e = earned.get(u) + pending(u, staked.get(u), userPaid.get(u), ix)
    all {
      staked' = staked.put(u, staked.get(u) - amount),
      totalStaked' = totalStaked - amount,
      earned' = earned.put(u, e),
      userPaid' = userPaid.put(u, ix),
      rewardIndex' = rewardIndex,
      rewardRate' = rewardRate,
      rewardBudget' = rewardBudget,
      crvEscrow' = crvEscrow,
      cvxCrvSupply' = cvxCrvSupply,
      cvxCrvOf' = cvxCrvOf,
      time' = time,
    }
  }

  // earmarkRewards (Booster.sol:440) → queueNewRewards on BaseRewardPool
  action earmark(reward: int): bool = all {
    reward > 0,
    // set new rate over duration
    rewardRate' = divFloor(reward, DURATION),
    rewardBudget' = rewardBudget + reward,
    rewardIndex' = streamIndex(rewardIndex, rewardRate, max(1, totalStaked), time),
    staked' = staked,
    totalStaked' = totalStaked,
    userPaid' = userPaid,
    earned' = earned,
    crvEscrow' = crvEscrow,
    cvxCrvSupply' = cvxCrvSupply,
    cvxCrvOf' = cvxCrvOf,
    time' = time,
  }

  action claim(u: int): bool = all {
    USERS.contains(u),
    val ix = rewardIndex.stored
    val e = earned.get(u) + pending(u, staked.get(u), userPaid.get(u), ix)
    all {
      e > 0,
      e <= rewardBudget,
      earned' = earned.put(u, 0),
      userPaid' = userPaid.put(u, ix),
      rewardBudget' = rewardBudget - e,
      staked' = staked,
      totalStaked' = totalStaked,
      rewardIndex' = rewardIndex,
      rewardRate' = rewardRate,
      crvEscrow' = crvEscrow,
      cvxCrvSupply' = cvxCrvSupply,
      cvxCrvOf' = cvxCrvOf,
      time' = time,
    }
  }

  // CrvDepositor.deposit (CrvDepositor.sol:107) — permanent lock, mint cvxCRV 1:1
  action lockCrv(u: int, amount: int): bool = all {
    USERS.contains(u),
    amount > 0,
    crvEscrow' = crvEscrow + amount,
    cvxCrvSupply' = cvxCrvSupply + amount,
    cvxCrvOf' = cvxCrvOf.put(u, cvxCrvOf.get(u) + amount),
    // NO redeem path — permanent
    staked' = staked,
    totalStaked' = totalStaked,
    rewardIndex' = rewardIndex,
    rewardRate' = rewardRate,
    userPaid' = userPaid,
    earned' = earned,
    rewardBudget' = rewardBudget,
    time' = time,
  }

  action tick: bool = all {
    time' = time + 1,
    rewardIndex' = streamIndex(rewardIndex, rewardRate, max(1, totalStaked), time + 1),
    staked' = staked,
    totalStaked' = totalStaked,
    rewardRate' = rewardRate,
    userPaid' = userPaid,
    earned' = earned,
    rewardBudget' = rewardBudget,
    crvEscrow' = crvEscrow,
    cvxCrvSupply' = cvxCrvSupply,
    cvxCrvOf' = cvxCrvOf,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(30).oneOf()
    any {
      depositLP(u, amt),
      withdrawLP(u, amt),
      earmark(amt),
      claim(u),
      lockCrv(u, amt),
      tick,
    }
  }

  // 1:1 stake conservation
  val stakeConserved: bool =
    totalStaked == USERS.fold(0, (acc, u) => acc + staked.get(u)) and totalStaked >= 0

  // Permanent escrow: cvxCRV supply equals CRV locked; no unlock action exists
  val escrowConserved: bool =
    crvEscrow == cvxCrvSupply and
    cvxCrvSupply == USERS.fold(0, (acc, u) => acc + cvxCrvOf.get(u)) and
    crvEscrow >= 0

  // Reward budget covers unclaimed (loose: budget >= 0)
  val rewardsBounded: bool = rewardBudget >= 0 and rewardIndex.stored >= 0
}
