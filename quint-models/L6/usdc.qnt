// Circle USDC — FiatToken core on-chain state machine.
// Source: protocol-repos/fiat/circlefin_stablecoin-evm/contracts/v1/FiatTokenV1.sol
//   mint with minterAllowed consumption (L121–145)
//   burn by minter of own balance (L363–378)
//   configureMinter / removeMinter (L329–355)
//   transfer + notBlacklisted (L287–321)
//   blacklist / unBlacklist (Blacklistable.sol) — blocks transfer, NO wipe
//   pause (Pausable)
// Off-chain reserve attested separately (At); not a contract storage field.

module usdc {
  import common.* from "./common"

  pure val USERS: Set[str] = Set("master", "minter", "alice", "bob", "carol")
  pure val MASTER: str = "master"
  pure val MINTER: str = "minter"

  var balances: str -> int
  var totalSupply: int
  var restricted: str -> bool
  var paused: bool
  var isMinter: str -> bool
  var minterAllowed: str -> int
  var reserve: int

  action init: bool = all {
    balances' = USERS.mapBy(u => 0),
    totalSupply' = 0,
    restricted' = USERS.mapBy(_ => false),
    paused' = false,
    isMinter' = USERS.mapBy(u => u == MINTER),
    minterAllowed' = USERS.mapBy(u => if (u == MINTER) 500 else 0),
    reserve' = 0,
  }

  /// masterMinter configures minter allowance (L329–338)
  action configureMinter(minter: str, allowance: int): bool = all {
    not(paused),
    USERS.contains(minter),
    allowance >= 0,
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = restricted,
    paused' = paused,
    isMinter' = isMinter.put(minter, true),
    minterAllowed' = minterAllowed.put(minter, allowance),
    reserve' = reserve,
  }

  /// mint(dst, amount): onlyMinters, consumes allowance (L121–145)
  action mint(minter: str, dst: str, amount: int): bool = all {
    not(paused),
    USERS.contains(minter),
    USERS.contains(dst),
    not(eitherRestricted(restricted, minter, dst)),
    canMintWithAllowance(isMinter, minterAllowed, minter, amount),
    val minted = applyMint(balances, totalSupply, dst, amount)
    all {
      balances' = minted._1,
      totalSupply' = minted._2,
      restricted' = restricted,
      paused' = paused,
      isMinter' = isMinter,
      minterAllowed' = consumeAllowance(minterAllowed, minter, amount),
      reserve' = reserve + amount,
    }
  }

  /// burn(amount): minter burns own tokens (L363–378)
  action burn(minter: str, amount: int): bool = all {
    not(paused),
    USERS.contains(minter),
    isMinter.get(minter),
    not(isRestricted(restricted, minter)),
    canBurnFrom(balances, minter, amount),
    reserve >= amount,
    val burned = applyBurn(balances, totalSupply, minter, amount)
    all {
      balances' = burned._1,
      totalSupply' = burned._2,
      restricted' = restricted,
      paused' = paused,
      isMinter' = isMinter,
      minterAllowed' = minterAllowed,
      reserve' = reserve - amount,
    }
  }

  action xfer(src: str, dst: str, amount: int): bool = all {
    not(paused),
    USERS.contains(src),
    USERS.contains(dst),
    not(eitherRestricted(restricted, src, dst)),
    canTransfer(balances, src, dst, amount),
    balances' = applyTransfer(balances, src, dst, amount),
    totalSupply' = totalSupply,
    restricted' = restricted,
    paused' = paused,
    isMinter' = isMinter,
    minterAllowed' = minterAllowed,
    reserve' = reserve,
  }

  /// blacklist — no supply wipe (unlike USDT destroyBlackFunds)
  action blacklist(user: str): bool = all {
    USERS.contains(user),
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = setRestricted(restricted, user, true),
    paused' = paused,
    isMinter' = isMinter,
    minterAllowed' = minterAllowed,
    reserve' = reserve,
  }

  action unblacklist(user: str): bool = all {
    USERS.contains(user),
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = setRestricted(restricted, user, false),
    paused' = paused,
    isMinter' = isMinter,
    minterAllowed' = minterAllowed,
    reserve' = reserve,
  }

  action pause: bool = all {
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = restricted,
    paused' = true,
    isMinter' = isMinter,
    minterAllowed' = minterAllowed,
    reserve' = reserve,
  }

  action unpause: bool = all {
    balances' = balances,
    totalSupply' = totalSupply,
    restricted' = restricted,
    paused' = false,
    isMinter' = isMinter,
    minterAllowed' = minterAllowed,
    reserve' = reserve,
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet v = USERS.oneOf()
    nondet amt = 1.to(40).oneOf()
    nondet allow = 1.to(100).oneOf()
    any {
      configureMinter(MINTER, allow),
      mint(MINTER, u, amt),
      burn(MINTER, amt),
      xfer(u, v, amt),
      blacklist(u),
      unblacklist(u),
      pause,
      unpause,
    }
  }

  val inv_supply_conserved: bool =
    supplyConserved(balances, USERS, totalSupply)

  val inv_nonneg: bool =
    totalSupply >= 0 and
    USERS.forall(u => balances.get(u) >= 0) and
    USERS.forall(u => minterAllowed.get(u) >= 0)

  /// Blacklisted tokens remain in totalSupply (no wipe) — liability persists.
  val inv_reserve_covers: bool =
    reserveCovers(reserve, totalSupply)
}
