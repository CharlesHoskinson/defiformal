// USDD Peg Stability Module only — the sole USDD contract present in the corpus clone.
// Sources:
//   decentralized-usd_psm/src/psm.sol
//     sellGem (143): stablecoin → USDD, fee = gemAmt * tin / WAD
//     buyGem  (164): USDD → stablecoin, fee = gemAmt * tout / WAD
// Scope: par peg-swap with asymmetric fees. Full CDP vault core not in repository.

module usdd_psm {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)

  var tin: int
  var tout: int
  var sellEnabled: bool
  var buyEnabled: bool
  var usddSupply: int
  var gemReserve: int
  var userUsdd: int -> int
  var userGem: int -> int

  action init: bool = all {
    tin' = 0,
    tout' = 10,
    sellEnabled' = true,
    buyEnabled' = true,
    usddSupply' = 0,
    gemReserve' = 0,
    userUsdd' = USERS.mapBy(_ => 0),
    userGem' = USERS.mapBy(_ => 100),
  }

  /// sellGem — psm.sol:143
  action sellGem(u: int, gemAmt: int): bool = {
    val fee = (gemAmt * tin) / WAD
    val usddOut = gemAmt - fee
    all {
      USERS.contains(u),
      sellEnabled,
      gemAmt > 0,
      userGem.get(u) >= gemAmt,
      usddOut > 0,
      userGem' = userGem.put(u, userGem.get(u) - gemAmt),
      userUsdd' = userUsdd.put(u, userUsdd.get(u) + usddOut),
      gemReserve' = gemReserve + gemAmt,
      usddSupply' = usddSupply + usddOut,
      tin' = tin,
      tout' = tout,
      sellEnabled' = sellEnabled,
      buyEnabled' = buyEnabled,
    }
  }

  /// buyGem — psm.sol:164
  action buyGem(u: int, gemAmt: int): bool = {
    val fee = (gemAmt * tout) / WAD
    val usddIn = gemAmt + fee
    all {
      USERS.contains(u),
      buyEnabled,
      gemAmt > 0,
      userUsdd.get(u) >= usddIn,
      gemReserve >= gemAmt,
      userUsdd' = userUsdd.put(u, userUsdd.get(u) - usddIn),
      userGem' = userGem.put(u, userGem.get(u) + gemAmt),
      gemReserve' = gemReserve - gemAmt,
      usddSupply' = usddSupply - usddIn,
      tin' = tin,
      tout' = tout,
      sellEnabled' = sellEnabled,
      buyEnabled' = buyEnabled,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet amt = 1.to(40).oneOf()
    any {
      sellGem(u, amt),
      buyGem(u, amt),
    }
  }

  val supplyConservation: bool =
    mapSum(userUsdd, USERS) == usddSupply

  val nonNegative: bool = and {
    usddSupply >= 0,
    gemReserve >= 0,
    nonNegMap(userUsdd, USERS),
    nonNegMap(userGem, USERS),
  }

  val reserveCoversSupplyWhenTinZero: bool =
    tin != 0 or gemReserve >= usddSupply

  val safety: bool = and {
    supplyConservation,
    nonNegative,
  }
}
