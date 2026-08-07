// LayerZero V2 — messaging layer + default OFT burn-mint token path.
// Sources:
//   EndpointV2.sol send (L83), verify (L151), lzReceive (L172)
//   outboundNonce[sender][dstEid][receiver] (L60)
//   OFT.sol _debit burns (L56), _credit mints (L78)
// Scope: one OApp pathway (srcEid=1 → dstEid=2), OFT burn-mint token.
// Verification is a single DVN threshold abstracted as one verify action.
// NOT covered: multi-DVN thresholds, compose, libraries, fee payment, adapters.

module layerzero {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val AMOUNTS: Set[int] = Set(1, 2, 3)
  pure val NONCES: Set[int] = Set(1, 2, 3, 4, 5)

  type PacketStatus = Sent | Verified | Delivered

  type Packet = {
    nonce: int,
    amount: int,
    recipient: int,
    status: PacketStatus,
  }

  pure def emptyPkt: Packet =
    { nonce: 0, amount: 0, recipient: 0, status: Delivered }

  var supplySrc: int
  var supplyDst: int
  var balancesSrc: int -> int
  var balancesDst: int -> int
  var outboundNonce: int
  var packets: int -> Packet
  var inboundPayload: Set[int]

  action init: bool = all {
    supplySrc' = 15,
    supplyDst' = 15,
    balancesSrc' = USERS.mapBy(u => if (u == 1) 10 else if (u == 2) 5 else 0),
    balancesDst' = USERS.mapBy(u => if (u == 3) 15 else 0),
    outboundNonce' = 0,
    packets' = NONCES.mapBy(_ => emptyPkt),
    inboundPayload' = Set(),
  }

  /// OFT.send → Endpoint.send: burn on src, emit packet, bump outbound nonce.
  action oftSend(user: int, amt: int, recipient: int): bool = all {
    USERS.contains(user),
    USERS.contains(recipient),
    AMOUNTS.contains(amt),
    balancesSrc.get(user) >= amt,
    canBurnMintSend(supplySrc, amt),
    outboundNonce < 5,
    val n = outboundNonce + 1
    all {
      balancesSrc' = balancesSrc.put(user, balancesSrc.get(user) - amt),
      supplySrc' = applyBurnOnSrc(supplySrc, amt),
      packets' = packets.put(n, {
        nonce: n, amount: amt, recipient: recipient, status: Sent
      }),
      outboundNonce' = n,
      supplyDst' = supplyDst,
      balancesDst' = balancesDst,
      inboundPayload' = inboundPayload,
    }
  }

  /// Endpoint.verify — receive library inserts payload hash into channel.
  action verify(nonce: int): bool = all {
    NONCES.contains(nonce),
    nonce <= outboundNonce,
    val p = packets.get(nonce)
    all {
      p.status == Sent and p.amount > 0,
      packets' = packets.put(nonce, { ...p, status: Verified }),
      inboundPayload' = inboundPayload.union(Set(nonce)),
      supplySrc' = supplySrc,
      supplyDst' = supplyDst,
      balancesSrc' = balancesSrc,
      balancesDst' = balancesDst,
      outboundNonce' = outboundNonce,
    }
  }

  /// Endpoint.lzReceive — clear payload then OFT _credit mint on dst.
  action lzReceive(nonce: int): bool = all {
    NONCES.contains(nonce),
    inboundPayload.contains(nonce),
    val p = packets.get(nonce)
    all {
      p.status == Verified,
      inboundPayload' = inboundPayload.exclude(Set(nonce)),
      packets' = packets.put(nonce, { ...p, status: Delivered }),
      supplyDst' = applyMintOnDst(supplyDst, p.amount),
      balancesDst' = balancesDst.put(p.recipient, balancesDst.get(p.recipient) + p.amount),
      supplySrc' = supplySrc,
      balancesSrc' = balancesSrc,
      outboundNonce' = outboundNonce,
    }
  }

  action step: bool = any {
    nondet u = USERS.oneOf()
    nondet a = AMOUNTS.oneOf()
    nondet r = USERS.oneOf()
    oftSend(u, a, r),
    nondet n = NONCES.oneOf()
    verify(n),
    nondet n2 = NONCES.oneOf()
    lzReceive(n2),
  }

  val oftSupplyConserved: bool = {
    val inFlight = NONCES.fold(0, (acc, n) => {
      val p = packets.get(n)
      if (p.status == Sent or p.status == Verified) acc + p.amount else acc
    })
    supplySrc + supplyDst + inFlight == 30
  }

  val noDoubleDelivery: bool =
    NONCES.forall(n =>
      packets.get(n).status != Delivered or not(inboundPayload.contains(n))
    )
}
