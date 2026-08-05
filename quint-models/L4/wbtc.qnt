// WBTC — custodial wrap with two-phase merchant/custodian mint & burn.
// Sources:
//   WrappedBTC.../ethereum/contracts/factory/Factory.sol
//     addMintRequest (L94), confirmMintRequest (L152), burn (L212),
//     confirmBurnRequest (L253)
//   Controller.sol mint/burn onlyFactory (L63-70)
//   token/WBTC.sol — standard mintable/burnable ERC-20, no blacklist
// Scope: one merchant, one custodian, aggregate supply. Off-chain BTC reserve
// is NOT observed on-chain (the bridge *is* the custodian confirmation).
// NOT covered: multi-merchant registry, Members multisig, pause, multi-chain.

module wbtc {
  import common.* from "./common"

  pure val MERCHANT: int = 1
  pure val CUSTODIAN: int = 2
  pure val AMOUNTS: Set[int] = Set(1, 2, 3, 5)
  pure val REQ_IDS: Set[int] = Set(0, 1, 2)

  var wrap: WrapSupply
  var mintReqs: int -> CustodianRequest
  var burnReqs: int -> CustodianRequest
  var nextMintId: int
  var nextBurnId: int
  var pendingBtcPayout: int

  pure def emptyReq: CustodianRequest =
    { requester: 0, amount: 0, status: Approved }

  action init: bool = all {
    wrap' = emptyWrap,
    mintReqs' = REQ_IDS.mapBy(_ => emptyReq),
    burnReqs' = REQ_IDS.mapBy(_ => emptyReq),
    nextMintId' = 0,
    nextBurnId' = 0,
    pendingBtcPayout' = 0,
  }

  /// Factory.addMintRequest — merchant posts BTC deposit evidence off-chain.
  action addMintRequest(amt: int): bool = all {
    AMOUNTS.contains(amt),
    nextMintId < 3,
    mintReqs' = mintReqs.put(nextMintId, {
      requester: MERCHANT, amount: amt, status: Pending
    }),
    nextMintId' = nextMintId + 1,
    wrap' = wrap,
    burnReqs' = burnReqs,
    nextBurnId' = nextBurnId,
    pendingBtcPayout' = pendingBtcPayout,
  }

  /// Factory.confirmMintRequest — onlyCustodian; mints WBTC to merchant.
  action confirmMint(id: int): bool = all {
    REQ_IDS.contains(id),
    id < nextMintId,
    val r = mintReqs.get(id)
    all {
      canConfirmMint(r),
      canMintWrap(wrap, r.amount),
      mintReqs' = mintReqs.put(id, applyApprove(r)),
      wrap' = applyMintWrap(wrap, r.amount),
      burnReqs' = burnReqs,
      nextMintId' = nextMintId,
      nextBurnId' = nextBurnId,
      pendingBtcPayout' = pendingBtcPayout,
    }
  }

  /// Factory.rejectMintRequest — onlyCustodian.
  action rejectMint(id: int): bool = all {
    REQ_IDS.contains(id),
    id < nextMintId,
    val r = mintReqs.get(id)
    all {
      r.status == Pending,
      mintReqs' = mintReqs.put(id, applyReject(r)),
      wrap' = wrap,
      burnReqs' = burnReqs,
      nextMintId' = nextMintId,
      nextBurnId' = nextBurnId,
      pendingBtcPayout' = pendingBtcPayout,
    }
  }

  /// Factory.burn — merchant burns WBTC; creates pending burn request.
  action merchantBurn(amt: int): bool = all {
    AMOUNTS.contains(amt),
    nextBurnId < 3,
    canBurnWrap(wrap, amt),
    burnReqs' = burnReqs.put(nextBurnId, {
      requester: MERCHANT, amount: amt, status: Pending
    }),
    wrap' = applyBurnWrap(wrap, amt),
    nextBurnId' = nextBurnId + 1,
    mintReqs' = mintReqs,
    nextMintId' = nextMintId,
    pendingBtcPayout' = pendingBtcPayout + amt,
  }

  /// Factory.confirmBurnRequest — custodian attests BTC sent off-chain.
  action confirmBurn(id: int): bool = all {
    REQ_IDS.contains(id),
    id < nextBurnId,
    val r = burnReqs.get(id)
    all {
      r.status == Pending,
      burnReqs' = burnReqs.put(id, applyApprove(r)),
      wrap' = wrap,
      mintReqs' = mintReqs,
      nextMintId' = nextMintId,
      nextBurnId' = nextBurnId,
      pendingBtcPayout' = pendingBtcPayout - r.amount,
    }
  }

  action step: bool = any {
    nondet a = AMOUNTS.oneOf()
    addMintRequest(a),
    nondet i = REQ_IDS.oneOf()
    confirmMint(i),
    nondet j = REQ_IDS.oneOf()
    rejectMint(j),
    nondet b = AMOUNTS.oneOf()
    merchantBurn(b),
    nondet k = REQ_IDS.oneOf()
    confirmBurn(k),
  }

  val supplyNonNegative: bool = wrap.totalSupply >= 0 and pendingBtcPayout >= 0

  val mintBurnBook: bool = {
    val approvedMint = REQ_IDS.fold(0, (acc, id) => {
      val r = mintReqs.get(id)
      if (r.status == Approved) acc + r.amount else acc
    })
    val burned = REQ_IDS.fold(0, (acc, id) => {
      val r = burnReqs.get(id)
      if (r.amount > 0 and (r.status == Pending or r.status == Approved))
        acc + r.amount
      else acc
    })
    wrap.totalSupply == approvedMint - burned
  }
}
