// PayPal USD (PYUSD) — same PaxosTokenV2 economic machine as USDG.
// Source: protocol-repos/fiat/paxosglobal_pyusd-contract/contracts/PYUSD.sol
//   thin name/symbol/decimals override only.
// Implementation shared: paxosglobal_paxos-token-contracts (PaxosTokenV2,
// SupplyControl, RateLimit, freeze/wipe).
// Differs from USDG only by constants (decimals/branding/roles) and reward
// distribution that is out of scope for the core ledger.
// Parameterized here via pure vals to make the const-only difference explicit.

module pyusd {
  import common.* from "./common"

  pure val USERS: Set[str] = Set("controller", "alice", "bob", "carol")
  pure val MINT_CAPACITY: int = 300
  pure val MINT_SLOPE: int = 15

  var balances: str -> int
  var totalSupply: int
  var frozen: str -> bool
  var paused: bool
  var mintLimit: RateLimit
  var clock: int
  var reserve: int

  action init: bool = all {
    balances' = USERS.mapBy(u => 0),
    totalSupply' = 0,
    frozen' = USERS.mapBy(_ => false),
    paused' = false,
    mintLimit' = {
      capacity: MINT_CAPACITY,
      remaining: MINT_CAPACITY,
      slope: MINT_SLOPE,
      lastTime: 0
    },
    clock' = 0,
    reserve' = 0,
  }

  action mint(dst: str, amount: int): bool = all {
    not(paused),
    USERS.contains(dst),
    not(isRestricted(frozen, dst)),
    canConsume(mintLimit, clock, amount),
    val minted = applyMint(balances, totalSupply, dst, amount)
    all {
      balances' = minted._1,
      totalSupply' = minted._2,
      frozen' = frozen,
      paused' = paused,
      mintLimit' = consumeLimit(mintLimit, clock, amount),
      clock' = clock,
      reserve' = reserve + amount,
    }
  }

  action burn(src: str, amount: int): bool = all {
    not(paused),
    USERS.contains(src),
    not(isRestricted(frozen, src)),
    canBurnFrom(balances, src, amount),
    reserve >= amount,
    val burned = applyBurn(balances, totalSupply, src, amount)
    all {
      balances' = burned._1,
      totalSupply' = burned._2,
      frozen' = frozen,
      paused' = paused,
      mintLimit' = refundLimit(mintLimit, clock, amount),
      clock' = clock,
      reserve' = reserve - amount,
    }
  }

  action xfer(src: str, dst: str, amount: int): bool = all {
    not(paused),
    USERS.contains(src),
    USERS.contains(dst),
    not(eitherRestricted(frozen, src, dst)),
    canTransfer(balances, src, dst, amount),
    balances' = applyTransfer(balances, src, dst, amount),
    totalSupply' = totalSupply,
    frozen' = frozen,
    paused' = paused,
    mintLimit' = mintLimit,
    clock' = clock,
    reserve' = reserve,
  }

  action freeze(user: str): bool = all {
    USERS.contains(user),
    balances' = balances,
    totalSupply' = totalSupply,
    frozen' = setRestricted(frozen, user, true),
    paused' = paused,
    mintLimit' = mintLimit,
    clock' = clock,
    reserve' = reserve,
  }

  action wipeFrozen(user: str): bool = all {
    USERS.contains(user),
    isRestricted(frozen, user),
    val bal = balances.get(user)
    all {
      bal > 0,
      balances' = balances.put(user, 0),
      totalSupply' = totalSupply - bal,
      frozen' = frozen,
      paused' = paused,
      mintLimit' = mintLimit,
      clock' = clock,
      reserve' = reserve,
    }
  }

  action tick: bool = all {
    balances' = balances,
    totalSupply' = totalSupply,
    frozen' = frozen,
    paused' = paused,
    mintLimit' = mintLimit,
    clock' = clock + 1,
    reserve' = reserve,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet v = USERS.oneOf()
    nondet amt = 1.to(30).oneOf()
    any {
      mint(u, amt),
      burn(u, amt),
      xfer(u, v, amt),
      freeze(u),
      wipeFrozen(u),
      tick,
    }
  }

  val inv_supply_conserved: bool =
    supplyConserved(balances, USERS, totalSupply)

  val inv_nonneg: bool =
    totalSupply >= 0 and USERS.forall(u => balances.get(u) >= 0)

  val inv_rate_limit_bounded: bool =
    mintLimit.remaining >= 0 and mintLimit.remaining <= mintLimit.capacity

  val inv_reserve_covers: bool =
    reserveCovers(reserve, totalSupply)
}
