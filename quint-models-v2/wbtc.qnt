// WBTC — two-phase merchant/custodian mint (convention 6h re-spec)
// SOURCE: protocol-repos/bridge/WrappedBTC_bitcoin-token-smart-contracts
//         ethereum/contracts/factory/Factory.sol
//         addMintRequest, confirmMintRequest (onlyCustodian), rejectMintRequest,
//         burn, confirmBurnRequest
//
// WHY: GATE-1.1B-PAIR4.md — v1 confirmMint(id) deleted onlyCustodian; autonomy
// law untestable. This re-spec models caller authority so the law can be scored.
//
// AUTHORITY 6h MODELLED:
//   addMintRequest / merchantBurn: caller == MERCHANT
//   confirmMint / rejectMint / confirmBurn: caller == CUSTODIAN
//
// ABSTRACTED: one merchant, one custodian, aggregate supply, no pause/multi-merchant

module wbtc {
  pure val MERCHANT: str = "merchant"
  pure val CUSTODIAN: str = "custodian"
  pure val ACTORS: Set[str] = Set("merchant", "custodian", "mallory")
  pure val AMOUNTS: Set[int] = Set(1, 2, 3, 5)
  pure val REQ_IDS: Set[int] = Set(0, 1, 2)

  pure val ST_EMPTY: int = 0
  pure val ST_PENDING: int = 1
  pure val ST_APPROVED: int = 2
  pure val ST_REJECTED: int = 3

  var totalSupply: int
  var mintStatus: int -> int
  var mintAmt: int -> int
  var burnStatus: int -> int
  var burnAmt: int -> int
  var nextMintId: int
  var nextBurnId: int
  var pendingBtcPayout: int
  var lastActor: str
  var lastAction: str

  action init: bool = all {
    totalSupply' = 0,
    mintStatus' = REQ_IDS.mapBy(_ => ST_EMPTY),
    mintAmt' = REQ_IDS.mapBy(_ => 0),
    burnStatus' = REQ_IDS.mapBy(_ => ST_EMPTY),
    burnAmt' = REQ_IDS.mapBy(_ => 0),
    nextMintId' = 0,
    nextBurnId' = 0,
    pendingBtcPayout' = 0,
    lastActor' = "",
    lastAction' = "init",
  }

  // Factory.addMintRequest — merchant
  action addMintRequest(caller: str, amt: int): bool = all {
    caller == MERCHANT,
    AMOUNTS.contains(amt),
    nextMintId < 3,
    mintStatus' = mintStatus.put(nextMintId, ST_PENDING),
    mintAmt' = mintAmt.put(nextMintId, amt),
    nextMintId' = nextMintId + 1,
    totalSupply' = totalSupply,
    burnStatus' = burnStatus,
    burnAmt' = burnAmt,
    nextBurnId' = nextBurnId,
    pendingBtcPayout' = pendingBtcPayout,
    lastActor' = caller,
    lastAction' = "addMintRequest",
  }

  // Factory.confirmMintRequest — onlyCustodian; mints WBTC
  action confirmMint(caller: str, id: int): bool = all {
    caller == CUSTODIAN,
    REQ_IDS.contains(id),
    id < nextMintId,
    mintStatus.get(id) == ST_PENDING,
    mintStatus' = mintStatus.put(id, ST_APPROVED),
    totalSupply' = totalSupply + mintAmt.get(id),
    mintAmt' = mintAmt,
    burnStatus' = burnStatus,
    burnAmt' = burnAmt,
    nextMintId' = nextMintId,
    nextBurnId' = nextBurnId,
    pendingBtcPayout' = pendingBtcPayout,
    lastActor' = caller,
    lastAction' = "confirmMint",
  }

  // Factory.rejectMintRequest — onlyCustodian
  action rejectMint(caller: str, id: int): bool = all {
    caller == CUSTODIAN,
    REQ_IDS.contains(id),
    id < nextMintId,
    mintStatus.get(id) == ST_PENDING,
    mintStatus' = mintStatus.put(id, ST_REJECTED),
    totalSupply' = totalSupply,
    mintAmt' = mintAmt,
    burnStatus' = burnStatus,
    burnAmt' = burnAmt,
    nextMintId' = nextMintId,
    nextBurnId' = nextBurnId,
    pendingBtcPayout' = pendingBtcPayout,
    lastActor' = caller,
    lastAction' = "rejectMint",
  }

  // Factory.burn — merchant
  action merchantBurn(caller: str, amt: int): bool = all {
    caller == MERCHANT,
    AMOUNTS.contains(amt),
    nextBurnId < 3,
    totalSupply >= amt,
    burnStatus' = burnStatus.put(nextBurnId, ST_PENDING),
    burnAmt' = burnAmt.put(nextBurnId, amt),
    totalSupply' = totalSupply - amt,
    nextBurnId' = nextBurnId + 1,
    pendingBtcPayout' = pendingBtcPayout + amt,
    mintStatus' = mintStatus,
    mintAmt' = mintAmt,
    nextMintId' = nextMintId,
    lastActor' = caller,
    lastAction' = "merchantBurn",
  }

  // Factory.confirmBurnRequest — custodian
  action confirmBurn(caller: str, id: int): bool = all {
    caller == CUSTODIAN,
    REQ_IDS.contains(id),
    id < nextBurnId,
    burnStatus.get(id) == ST_PENDING,
    burnStatus' = burnStatus.put(id, ST_APPROVED),
    pendingBtcPayout' = pendingBtcPayout - burnAmt.get(id),
    totalSupply' = totalSupply,
    mintStatus' = mintStatus,
    mintAmt' = mintAmt,
    burnAmt' = burnAmt,
    nextMintId' = nextMintId,
    nextBurnId' = nextBurnId,
    lastActor' = caller,
    lastAction' = "confirmBurn",
  }

  // Autonomy: can merchant reach approved mint without custodian? No.
  // Mallory cannot confirm.
  val inv_confirm_auth: bool =
    lastAction != "confirmMint" or lastActor == CUSTODIAN
  val inv_reject_auth: bool =
    lastAction != "rejectMint" or lastActor == CUSTODIAN
  val inv_supply_nonneg: bool = totalSupply >= 0 and pendingBtcPayout >= 0
  val inv_all: bool =
    inv_confirm_auth and inv_reject_auth and inv_supply_nonneg

  action step: bool = any {
    nondet c = ACTORS.oneOf(); nondet a = AMOUNTS.oneOf(); addMintRequest(c, a),
    nondet c = ACTORS.oneOf(); nondet i = REQ_IDS.oneOf(); confirmMint(c, i),
    nondet c = ACTORS.oneOf(); nondet i = REQ_IDS.oneOf(); rejectMint(c, i),
    nondet c = ACTORS.oneOf(); nondet a = AMOUNTS.oneOf(); merchantBurn(c, a),
    nondet c = ACTORS.oneOf(); nondet i = REQ_IDS.oneOf(); confirmBurn(c, i),
  }
}
