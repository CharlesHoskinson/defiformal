// Babylon — Bitcoin-native staking registration (protocol holds nothing).
// Sources:
//   babylonlabs-io_babylon/x/btcstaking/types/btc_delegation.go
//     BTCDelegation status: PENDING → VERIFIED → ACTIVE → UNBONDED/EXPIRED
//     GetStatus (119), GetTotalSat, UnbondingTime
//   .../keeper/msg_server.go
//     CreateBTCDelegation (121), BTCUndelegate (545), SelectiveSlashingEvidence (687)
// Scope: per-delegation state machine, FP fixed at lock, sats off-protocol,
//        slash fraction; no transferable receipt token.
// NOT covered: covenant sigs, BTC light client proofs, EOTS, costaking.

module babylon {

  pure val STAKERS: Set[int] = Set(1, 2, 3)
  pure val PROVIDERS: Set[int] = Set(10, 11)
  pure val MAX_DELS: int = 6
  pure val SLASH_FRACTION_BPS: int = 1000
  pure val BPS: int = 10000
  pure val UNBONDING_TIME: int = 3
  pure val MAX_STAKING_TIME: int = 20

  type DelStatus = Pending | Verified | Active | Unbonding | Unbonded | Slashed | Expired

  type Delegation = {
    staker: int,
    provider: int,
    sats: int,
    startHeight: int,
    endHeight: int,
    status: DelStatus,
    unbondingHeight: int,
  }

  pure def emptyDel: Delegation = {
    staker: 0,
    provider: 0,
    sats: 0,
    startHeight: 0,
    endHeight: 0,
    status: Pending,
    unbondingHeight: 0,
  }

  var delegations: int -> Delegation
  var nextDelId: int
  var btcHeight: int
  var totalActiveSats: int
  var totalSlashedSats: int
  var providerPower: int -> int

  action init: bool = all {
    delegations' = 1.to(MAX_DELS).mapBy(_ => emptyDel),
    nextDelId' = 1,
    btcHeight' = 1,
    totalActiveSats' = 0,
    totalSlashedSats' = 0,
    providerPower' = PROVIDERS.mapBy(_ => 0),
  }

  /// CreateBTCDelegation — msg_server.go:121
  action createDelegation(staker: int, provider: int, sats: int, stakingTime: int): bool = {
    val id = nextDelId
    all {
      STAKERS.contains(staker),
      PROVIDERS.contains(provider),
      sats > 0,
      stakingTime > 0,
      stakingTime <= MAX_STAKING_TIME,
      id <= MAX_DELS,
      delegations' = delegations.put(id, {
        staker: staker,
        provider: provider,
        sats: sats,
        startHeight: btcHeight,
        endHeight: btcHeight + stakingTime,
        status: Pending,
        unbondingHeight: 0,
      }),
      nextDelId' = id + 1,
      btcHeight' = btcHeight,
      totalActiveSats' = totalActiveSats,
      totalSlashedSats' = totalSlashedSats,
      providerPower' = providerPower,
    }
  }

  action activate(id: int): bool = {
    val d = delegations.get(id)
    all {
      id < nextDelId,
      id >= 1,
      d.status == Pending,
      d.sats > 0,
      delegations' = delegations.put(id, {
        staker: d.staker,
        provider: d.provider,
        sats: d.sats,
        startHeight: d.startHeight,
        endHeight: d.endHeight,
        status: Active,
        unbondingHeight: 0,
      }),
      totalActiveSats' = totalActiveSats + d.sats,
      providerPower' = providerPower.put(d.provider,
        providerPower.get(d.provider) + d.sats),
      nextDelId' = nextDelId,
      btcHeight' = btcHeight,
      totalSlashedSats' = totalSlashedSats,
    }
  }

  action undelegate(id: int): bool = {
    val d = delegations.get(id)
    all {
      id < nextDelId,
      d.status == Active,
      delegations' = delegations.put(id, {
        staker: d.staker,
        provider: d.provider,
        sats: d.sats,
        startHeight: d.startHeight,
        endHeight: d.endHeight,
        status: Unbonding,
        unbondingHeight: btcHeight,
      }),
      totalActiveSats' = totalActiveSats - d.sats,
      providerPower' = providerPower.put(d.provider,
        providerPower.get(d.provider) - d.sats),
      nextDelId' = nextDelId,
      btcHeight' = btcHeight,
      totalSlashedSats' = totalSlashedSats,
    }
  }

  action completeUnbonding(id: int): bool = {
    val d = delegations.get(id)
    all {
      id < nextDelId,
      d.status == Unbonding,
      btcHeight >= d.unbondingHeight + UNBONDING_TIME,
      delegations' = delegations.put(id, {
        staker: d.staker,
        provider: d.provider,
        sats: d.sats,
        startHeight: d.startHeight,
        endHeight: d.endHeight,
        status: Unbonded,
        unbondingHeight: d.unbondingHeight,
      }),
      nextDelId' = nextDelId,
      btcHeight' = btcHeight,
      totalActiveSats' = totalActiveSats,
      totalSlashedSats' = totalSlashedSats,
      providerPower' = providerPower,
    }
  }

  action expire(id: int): bool = {
    val d = delegations.get(id)
    all {
      id < nextDelId,
      d.status == Active,
      btcHeight >= d.endHeight,
      delegations' = delegations.put(id, {
        staker: d.staker,
        provider: d.provider,
        sats: d.sats,
        startHeight: d.startHeight,
        endHeight: d.endHeight,
        status: Expired,
        unbondingHeight: d.unbondingHeight,
      }),
      totalActiveSats' = totalActiveSats - d.sats,
      providerPower' = providerPower.put(d.provider,
        providerPower.get(d.provider) - d.sats),
      nextDelId' = nextDelId,
      btcHeight' = btcHeight,
      totalSlashedSats' = totalSlashedSats,
    }
  }

  /// SelectiveSlashingEvidence — destroy SLASH_FRACTION; protocol never held BTC
  action slash(id: int): bool = {
    val d = delegations.get(id)
    val destroyed = (d.sats * SLASH_FRACTION_BPS) / BPS
    all {
      id < nextDelId,
      d.status == Active,
      destroyed > 0,
      delegations' = delegations.put(id, {
        staker: d.staker,
        provider: d.provider,
        sats: d.sats - destroyed,
        startHeight: d.startHeight,
        endHeight: d.endHeight,
        status: Slashed,
        unbondingHeight: d.unbondingHeight,
      }),
      totalActiveSats' = totalActiveSats - d.sats,
      totalSlashedSats' = totalSlashedSats + destroyed,
      providerPower' = providerPower.put(d.provider,
        providerPower.get(d.provider) - d.sats),
      nextDelId' = nextDelId,
      btcHeight' = btcHeight,
    }
  }

  action tick: bool = all {
    btcHeight' = btcHeight + 1,
    delegations' = delegations,
    nextDelId' = nextDelId,
    totalActiveSats' = totalActiveSats,
    totalSlashedSats' = totalSlashedSats,
    providerPower' = providerPower,
  }

  action step: bool = {
    nondet staker = STAKERS.oneOf()
    nondet provider = PROVIDERS.oneOf()
    nondet sats = 1.to(50).oneOf()
    nondet stakingTime = 1.to(MAX_STAKING_TIME).oneOf()
    nondet id = 1.to(MAX_DELS).oneOf()
    any {
      createDelegation(staker, provider, sats, stakingTime),
      activate(id),
      undelegate(id),
      completeUnbonding(id),
      expire(id),
      slash(id),
      tick,
    }
  }

  val activeSatsConsistent: bool =
    1.to(MAX_DELS).fold(0, (acc, id) => {
      val d = delegations.get(id)
      if (d.status == Active) acc + d.sats else acc
    }) == totalActiveSats

  val powerConsistent: bool =
    PROVIDERS.fold(0, (acc, p) => acc + providerPower.get(p)) == totalActiveSats
    and PROVIDERS.forall(p => providerPower.get(p) >= 0)

  val nonNegative: bool = and {
    totalActiveSats >= 0,
    totalSlashedSats >= 0,
    btcHeight >= 1,
    nextDelId >= 1,
  }

  val safety: bool = and {
    activeSatsConsistent,
    powerConsistent,
    nonNegative,
  }
}
