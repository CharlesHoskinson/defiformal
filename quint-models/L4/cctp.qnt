// Circle CCTP — burn-mint USDC bridge with attested once-only messages.
// Sources:
//   circlefin_evm-cctp-contracts/src/TokenMessenger.sol depositForBurn (L169)
//   MessageTransmitter.sol sendMessage/receiveMessage (L108, L250)
//   TokenMinter.sol mint/burn (L85, L111)
// Scope: two domains (src=0, dst=1), one token, threshold attestation abstracted
// as a single "attested" flag set by a trusted attester action.
// NOT covered: multi-attester threshold, replaceDepositForBurn, burn limits,
// destinationCaller restriction, TokenController localToken registry.

module cctp {
  import common.* from "./common"

  pure val DOMAINS: Set[int] = Set(0, 1)
  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val AMOUNTS: Set[int] = Set(1, 2, 3, 5)
  pure val NONCES: Set[int] = Set(0, 1, 2, 3, 4)

  type BurnMsg = {
    srcDomain: int,
    dstDomain: int,
    amount: int,
    recipient: int,
    attested: bool,
  }

  pure def emptyMsg: BurnMsg =
    { srcDomain: 0, dstDomain: 1, amount: 0, recipient: 0, attested: false }

  var supply: int -> int
  var usedNonces: Set[int]
  var nextNonce: int
  var messages: int -> BurnMsg
  var balances: int -> int

  action init: bool = all {
    supply' = Map(0 -> 20, 1 -> 20),
    usedNonces' = Set(),
    nextNonce' = 0,
    messages' = NONCES.mapBy(_ => emptyMsg),
    balances' = USERS.mapBy(u => if (u == 1) 20 else if (u == 2) 20 else 0),
  }

  /// TokenMessenger.depositForBurn — burn on src, emit message, reserve nonce.
  action depositForBurn(user: int, amt: int, dst: int, recipient: int): bool = all {
    USERS.contains(user),
    USERS.contains(recipient),
    AMOUNTS.contains(amt),
    DOMAINS.contains(dst),
    dst == 1,
    nextNonce < 5,
    balances.get(user) >= amt,
    canBurnMintSend(supply.get(0), amt),
    canDeliverOnce(usedNonces, nextNonce),
    val n = nextNonce
    all {
      balances' = balances.put(user, balances.get(user) - amt),
      supply' = supply.put(0, applyBurnOnSrc(supply.get(0), amt)),
      messages' = messages.put(n, {
        srcDomain: 0, dstDomain: dst, amount: amt,
        recipient: recipient, attested: false
      }),
      nextNonce' = n + 1,
      usedNonces' = usedNonces,
    }
  }

  /// Off-chain attesters sign; abstract as a single attestation step.
  action attest(nonce: int): bool = all {
    NONCES.contains(nonce),
    nonce < nextNonce,
    val m = messages.get(nonce)
    all {
      m.amount > 0 and not(m.attested),
      messages' = messages.put(nonce, { ...m, attested: true }),
      supply' = supply,
      usedNonces' = usedNonces,
      nextNonce' = nextNonce,
      balances' = balances,
    }
  }

  /// MessageTransmitter.receiveMessage → TokenMinter.mint
  action receiveMessage(nonce: int): bool = all {
    NONCES.contains(nonce),
    nonce < nextNonce,
    canDeliverOnce(usedNonces, nonce),
    val m = messages.get(nonce)
    all {
      m.attested and m.amount > 0,
      usedNonces' = markUsed(usedNonces, nonce),
      supply' = supply.put(m.dstDomain, applyMintOnDst(supply.get(m.dstDomain), m.amount)),
      balances' = balances.put(m.recipient, balances.get(m.recipient) + m.amount),
      messages' = messages,
      nextNonce' = nextNonce,
    }
  }

  action step: bool = any {
    nondet u = USERS.oneOf()
    nondet a = AMOUNTS.oneOf()
    nondet r = USERS.oneOf()
    depositForBurn(u, a, 1, r),
    nondet n = NONCES.oneOf()
    attest(n),
    nondet n2 = NONCES.oneOf()
    receiveMessage(n2),
  }

  val globalSupplyConserved: bool = {
    val inFlight = NONCES.fold(0, (acc, n) => {
      val m = messages.get(n)
      if (m.amount > 0 and not(usedNonces.contains(n))) acc + m.amount else acc
    })
    supply.get(0) + supply.get(1) + inFlight == 40
  }

  val usedImpliesAttested: bool =
    usedNonces.forall(n => messages.get(n).attested)
}
