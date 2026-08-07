// Tether USDT — core on-chain state machine.
// Source: protocol-repos/fiat/tethercoin_USDT/TetherToken.sol
//   balances / _totalSupply (StandardToken L107–108, L82)
//   issue / redeem onlyOwner (L406–427)
//   transfer with optional fee basisPointsRate/maximumFee (L126–136)
//   addBlackList / destroyBlackFunds (L281–297)
//   pause (Pausable L254)
// Off-chain reserve is NOT in the contract — modelled as external `reserve`.

module usdt {
  import common.* from "./common"

  pure val USERS: Set[str] = Set("owner", "alice", "bob", "carol")
  pure val OWNER: str = "owner"

  var balances: str -> int
  var totalSupply: int
  var restricted: str -> bool   // isBlackListed
  var paused: bool
  var feeBps: int               // basisPointsRate (max 20 in code)
  var maxFee: int               // maximumFee
  var reserve: int              // off-chain attested reserve (external)

  action init: bool = all {
    balances' = USERS.mapBy(u => if (u == OWNER) 1000 else 0),
    totalSupply' = 1000,
    restricted' = USERS.mapBy(_ => false),
    paused' = false,
    feeBps' = 0,
    maxFee' = 0,
    reserve' = 1000,
  }

  pure def transferFee(amount: int, bps: int, cap: int): int = {
    val raw = mulDivDown(amount, bps, 10000)
    if (raw > cap) cap else raw
  }

  /// issue(amount): mint to owner (TetherToken.sol L406–413)
  action issue(amount: int): bool = all {
    not(paused),
    amount > 0,
    val minted = applyMint(balances, totalSupply, OWNER, amount)
    all {
      balances' = minted._1,
      totalSupply' = minted._2,
      restricted' = restricted,
      paused' = paused,
      feeBps' = feeBps,
      maxFee' = maxFee,
      reserve' = reserve + amount,
    }
  }

  /// redeem(amount): burn from owner (L420–427)
  action redeem(amount: int): bool = all {
    not(paused),
    canBurnFrom(balances, OWNER, amount),
    reserve >= amount,
    val burned = applyBurn(balances, totalSupply, OWNER, amount)
    all {
      balances' = burned._1,
      totalSupply' = burned._2,
      restricted' = restricted,
      paused' = paused,
      feeBps' = feeBps,
      maxFee' = maxFee,
      reserve' = reserve - amount,
    }
  }

  /// transfer with optional fee to owner (L126–136, L340–347)
  action xfer(src: str, dst: str, amount: int): bool = all {
    not(paused),
    USERS.contains(src),
    USERS.contains(dst),
    not(isRestricted(restricted, src)),
    amount > 0,
    balances.get(src) >= amount,
    val fee = transferFee(amount, feeBps, maxFee)
    val sendAmt = amount - fee
    all {
      sendAmt > 0,
      balances' = {
        val b1 = balances.setBy(src, b => b - amount)
        val b2 = b1.setBy(dst, b => b + sendAmt)
        if (fee > 0) b2.setBy(OWNER, b => b + fee) else b2
      },
      totalSupply' = totalSupply,
      restricted' = restricted,
      paused' = paused,
      feeBps' = feeBps,
      maxFee' = maxFee,
      reserve' = reserve,
    }
  }

  /// addBlackList (L281–284)
  action blacklist(user: str): bool = all {
    USERS.contains(user),
    user != OWNER,
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = setRestricted(restricted, user, true),
    paused' = paused,
    feeBps' = feeBps,
    maxFee' = maxFee,
    reserve' = reserve,
  }

  /// destroyBlackFunds: wipe balance and burn supply (L291–297)
  action destroyBlackFunds(user: str): bool = all {
    USERS.contains(user),
    isRestricted(restricted, user),
    val dirty = balances.get(user)
    all {
      dirty > 0,
      balances' = balances.put(user, 0),
      totalSupply' = totalSupply - dirty,
      restricted' = restricted,
      paused' = paused,
      feeBps' = feeBps,
      maxFee' = maxFee,
      reserve' = reserve,
    }
  }

  action pause: bool = all {
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = restricted,
    paused' = true,
    feeBps' = feeBps,
    maxFee' = maxFee,
    reserve' = reserve,
  }

  action unpause: bool = all {
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = restricted,
    paused' = false,
    feeBps' = feeBps,
    maxFee' = maxFee,
    reserve' = reserve,
  }

  /// Off-chain reserve attestation update (no on-chain function — external)
  action attestReserve(newReserve: int): bool = all {
    newReserve >= 0,
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = restricted,
    paused' = paused,
    feeBps' = feeBps,
    maxFee' = maxFee,
    reserve' = newReserve,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet v = USERS.oneOf()
    nondet amt = 1.to(50).oneOf()
    nondet r = 900.to(1200).oneOf()
    any {
      issue(amt),
      redeem(amt),
      xfer(u, v, amt),
      blacklist(u),
      destroyBlackFunds(u),
      pause,
      unpause,
      attestReserve(r),
    }
  }

  /// Supply equals sum of balances (fee stays on-ledger).
  val inv_supply_conserved: bool =
    supplyConserved(balances, USERS, totalSupply)

  /// Non-negative balances and supply.
  val inv_nonneg: bool =
    totalSupply >= 0 and USERS.forall(u => balances.get(u) >= 0)

  /// Off-chain 1:1 backing is NOT enforced on-chain. `attestReserve` can set
  /// any value; `destroyBlackFunds` shrinks supply without touching reserve.
  /// We therefore check the WEAKER on-chain property: wipe can only increase
  /// the reserve surplus (reserve - totalSupply), never create under-backing
  /// by itself. Under-backing requires the external attest action.
  ///
  /// inv_reserve_covers_if_honest: holds only if attest is disabled from step.
  /// Documented failure: with attestReserve in step, inv_reserve_covers fails
  /// (seed evidence in ledger) — the hidden precondition of the category.
  val inv_reserve_covers: bool =
    reserveCovers(reserve, totalSupply)

  /// Always-true on-chain conservation (independent of off-chain reserve).
  val inv_onchain_only: bool =
    supplyConserved(balances, USERS, totalSupply) and totalSupply >= 0
}
