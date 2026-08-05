// Across Protocol — optimistic fill bridge (intent-like deposit + relayer fill).
// Sources:
//   across-protocol_contracts/contracts/spoke-pools/SpokePool.sol
//     depositV3 (L583), fillRelay (L958), fillStatuses (L115)
//     relayerRefund (L119), relayRootBundle (L347)
//   HubPool.sol proposeRootBundle / executeRootBundle — LP reserve reimbursement
// Scope: single origin pool + destination inventory; fast fill path only.
// NOT covered: exclusivity deadline, slow fill merkle leaves, speedUpDeposit,
// multi-chain repayment, HubPool LP share math beyond abstract refund.

module across {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val RELAYERS: Set[int] = Set(10, 11)
  pure val AMOUNTS: Set[int] = Set(1, 2, 3, 5)
  pure val DEP_IDS: Set[int] = Set(0, 1, 2)

  type Deposit = {
    depositor: int,
    recipient: int,
    inputAmount: int,
    outputAmount: int,
    status: FillStatus,
    relayer: int,
  }

  pure def emptyDep: Deposit =
    { depositor: 0, recipient: 0, inputAmount: 0, outputAmount: 0,
      status: Unfilled, relayer: 0 }

  var originPool: int
  var relayerInv: int -> int
  var userBal: int -> int
  var recipientBal: int -> int
  var deposits: int -> Deposit
  var nextDepId: int
  var relayerRefundOwed: int -> int

  action init: bool = all {
    originPool' = 0,
    relayerInv' = RELAYERS.mapBy(_ => 20),
    userBal' = USERS.mapBy(u => if (u == 1) 15 else if (u == 2) 10 else 5),
    recipientBal' = USERS.mapBy(_ => 0),
    deposits' = DEP_IDS.mapBy(_ => emptyDep),
    nextDepId' = 0,
    relayerRefundOwed' = RELAYERS.mapBy(_ => 0),
  }

  /// depositV3 — lock input on origin; emit FundsDeposited for relayers.
  action deposit(depositor: int, recipient: int, inputAmt: int, outputAmt: int): bool = all {
    USERS.contains(depositor),
    USERS.contains(recipient),
    AMOUNTS.contains(inputAmt),
    AMOUNTS.contains(outputAmt),
    outputAmt <= inputAmt,
    canDeposit(inputAmt),
    userBal.get(depositor) >= inputAmt,
    nextDepId < 3,
    val id = nextDepId
    all {
      userBal' = userBal.put(depositor, userBal.get(depositor) - inputAmt),
      originPool' = applyEscrowDeposit(originPool, inputAmt),
      deposits' = deposits.put(id, {
        depositor: depositor, recipient: recipient,
        inputAmount: inputAmt, outputAmount: outputAmt,
        status: Unfilled, relayer: 0
      }),
      nextDepId' = id + 1,
      relayerInv' = relayerInv,
      recipientBal' = recipientBal,
      relayerRefundOwed' = relayerRefundOwed,
    }
  }

  /// fillRelay — relayer pays output from inventory; marks filled; accrues refund.
  action fill(id: int, relayer: int): bool = all {
    DEP_IDS.contains(id),
    RELAYERS.contains(relayer),
    id < nextDepId,
    val d = deposits.get(id)
    all {
      d.status == Unfilled and d.outputAmount > 0,
      relayerInv.get(relayer) >= d.outputAmount,
      relayerInv' = relayerInv.put(relayer, relayerInv.get(relayer) - d.outputAmount),
      recipientBal' = recipientBal.put(d.recipient,
        recipientBal.get(d.recipient) + d.outputAmount),
      deposits' = deposits.put(id, { ...d, status: Filled, relayer: relayer }),
      relayerRefundOwed' = relayerRefundOwed.put(relayer,
        relayerRefundOwed.get(relayer) + d.inputAmount),
      originPool' = originPool,
      userBal' = userBal,
      nextDepId' = nextDepId,
    }
  }

  /// Abstract refund execution (root bundle leaf): pay relayer from origin pool.
  action refundRelayer(relayer: int, amt: int): bool = all {
    RELAYERS.contains(relayer),
    AMOUNTS.contains(amt),
    relayerRefundOwed.get(relayer) >= amt,
    canEscrowWithdraw(originPool, amt),
    originPool' = applyEscrowWithdraw(originPool, amt),
    relayerInv' = relayerInv.put(relayer, relayerInv.get(relayer) + amt),
    relayerRefundOwed' = relayerRefundOwed.put(relayer,
      relayerRefundOwed.get(relayer) - amt),
    userBal' = userBal,
    recipientBal' = recipientBal,
    deposits' = deposits,
    nextDepId' = nextDepId,
  }

  action step: bool = any {
    nondet dep = USERS.oneOf()
    nondet rec = USERS.oneOf()
    nondet ia = AMOUNTS.oneOf()
    nondet oa = AMOUNTS.oneOf()
    deposit(dep, rec, ia, oa),
    nondet id = DEP_IDS.oneOf()
    nondet rel = RELAYERS.oneOf()
    fill(id, rel),
    nondet r2 = RELAYERS.oneOf()
    nondet a = AMOUNTS.oneOf()
    refundRelayer(r2, a),
  }

  val poolBalanced: bool = {
    val unfilledLocked = DEP_IDS.fold(0, (acc, id) => {
      val d = deposits.get(id)
      if (d.status == Unfilled and d.inputAmount > 0) acc + d.inputAmount else acc
    })
    val owed = RELAYERS.fold(0, (acc, r) => acc + relayerRefundOwed.get(r))
    originPool == unfilledLocked + owed
  }

  val noDoubleFill: bool =
    DEP_IDS.forall(id =>
      deposits.get(id).status != Filled or deposits.get(id).relayer != 0
    )
}
