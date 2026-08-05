// Spark ALM Controller — rate-limited capital deployment envelope.
// Source: protocol-repos/yield/sparkdotfi_spark-alm-controller/src/
//   RateLimits.sol current = min(max, last + slope * dt); triggerDecrease
//   MainnetController.sol mintUSDS, depositERC4626, depositAave, swap*, transferAsset
// Note: the sUSDS savings token (administered rate + drip) is NOT in this repo;
// this model captures the ALM controller surface: relayer acts only through
// enumerated rate-limited actions over protocol capital.
// Profile claims about savings rate → see ledger (profile vs code).

module spark {
  import common.* from "./common"

  pure val MAX_ACTIONS: int = 5
  // Action keys: 0=mintUSDS, 1=deposit4626, 2=depositAave, 3=swap, 4=transfer
  pure val KEYS: Set[int] = Set(0, 1, 2, 3, 4)

  var limits: int -> RateLimit
  var usdsBalance: int              // controller-proxied USDS
  var deployed: int -> int          // capital sitting in venue k
  var totalMinted: int              // net USDS minted against surplus (debt to vat)
  var time: int
  var frozen: bool                  // ALMProxyFreezable

  pure def defaultLimit: RateLimit =
    { maxAmount: 1000, slope: 10, lastAmount: 1000, lastUpdated: 0 }

  action init: bool = all {
    limits' = KEYS.mapBy(_ => defaultLimit),
    usdsBalance' = 0,
    deployed' = KEYS.mapBy(_ => 0),
    totalMinted' = 0,
    time' = 0,
    frozen' = false,
  }

  // mintUSDS (MainnetController.sol:364) — creates USDS, increases protocol debt
  action mintUSDS(amount: int): bool = all {
    not(frozen),
    canConsume(limits.get(0), amount, time),
    amount > 0,
    limits' = limits.put(0, consume(limits.get(0), amount, time)),
    usdsBalance' = usdsBalance + amount,
    totalMinted' = totalMinted + amount,
    deployed' = deployed,
    time' = time,
    frozen' = frozen,
  }

  // burnUSDS (MainnetController.sol:381)
  action burnUSDS(amount: int): bool = all {
    not(frozen),
    amount > 0,
    amount <= usdsBalance,
    amount <= totalMinted,
    usdsBalance' = usdsBalance - amount,
    totalMinted' = totalMinted - amount,
    limits' = limits,
    deployed' = deployed,
    time' = time,
    frozen' = frozen,
  }

  // depositERC4626 / depositAave — move USDS into a venue under rate limit
  action deploy(key: int, amount: int): bool = all {
    not(frozen),
    KEYS.contains(key),
    key != 0,  // 0 is mint
    canConsume(limits.get(key), amount, time),
    amount > 0,
    amount <= usdsBalance,
    limits' = limits.put(key, consume(limits.get(key), amount, time)),
    usdsBalance' = usdsBalance - amount,
    deployed' = deployed.put(key, deployed.get(key) + amount),
    totalMinted' = totalMinted,
    time' = time,
    frozen' = frozen,
  }

  // withdraw back from venue
  action recall(key: int, amount: int): bool = all {
    not(frozen),
    KEYS.contains(key),
    amount > 0,
    amount <= deployed.get(key),
    deployed' = deployed.put(key, deployed.get(key) - amount),
    usdsBalance' = usdsBalance + amount,
    limits' = limits,
    totalMinted' = totalMinted,
    time' = time,
    frozen' = frozen,
  }

  // Freezer multisig (ALMProxyFreezable) — can freeze, cannot deploy
  action freeze: bool = all {
    not(frozen),
    frozen' = true,
    limits' = limits,
    usdsBalance' = usdsBalance,
    deployed' = deployed,
    totalMinted' = totalMinted,
    time' = time,
  }

  action unfreeze: bool = all {
    frozen,
    frozen' = false,
    limits' = limits,
    usdsBalance' = usdsBalance,
    deployed' = deployed,
    totalMinted' = totalMinted,
    time' = time,
  }

  // Slope regenerates capacity with time (RateLimits.getCurrentRateLimit)
  action tick: bool = all {
    time' = time + 1,
    limits' = limits,  // regeneration is pure in currentLimit(now)
    usdsBalance' = usdsBalance,
    deployed' = deployed,
    totalMinted' = totalMinted,
    frozen' = frozen,
  }

  action step: bool = {
    nondet key = KEYS.oneOf()
    nondet amt = 1.to(100).oneOf()
    any {
      mintUSDS(amt),
      burnUSDS(amt),
      deploy(key, amt),
      recall(key, amt),
      freeze,
      unfreeze,
      tick,
    }
  }

  // Conservation: minted USDS = cash + sum(deployed)
  val capitalConserved: bool =
    totalMinted == usdsBalance + KEYS.fold(0, (acc, k) => acc + deployed.get(k)) and
    totalMinted >= 0 and usdsBalance >= 0

  // Rate limits never negative
  val limitsNonNeg: bool =
    KEYS.forall(k => currentLimit(limits.get(k), time) >= 0)

  // When frozen, deployed capital still exists (freeze ≠ seize)
  val freezePreserves: bool =
    not(frozen) or capitalConserved
}
