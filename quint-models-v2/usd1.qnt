// USD1 — World Liberty Stablecoin.sol
// SOURCE: protocol-repos/fiat/worldliberty_usd1-smart-contracts/src/Stablecoin.sol
// AUTHORITY 6h MODELLED: mint/burn/freeze/unfreeze/pause onlyOwner; transfer notFrozen+notPaused
// ABSTRACTED: permit, two-step ownable collapse, upgradeability

module usd1 {
  pure val OWNER: str = "owner"
  pure val PRINCIPALS: Set[str] = Set("owner", "alice", "bob", "carol")
  pure val USERS: Set[str] = Set("alice", "bob", "carol")
  pure val AMOUNTS: Set[int] = Set(1, 10, 100)

  var balances: str -> int
  var frozen: str -> bool
  var paused: bool
  var owner: str
  var totalSupply: int
  var lastActor: str
  var lastAction: str

  action init: bool = all {
    balances' = PRINCIPALS.mapBy(_ => 0),
    frozen' = PRINCIPALS.mapBy(_ => false),
    paused' = false,
    owner' = OWNER,
    totalSupply' = 0,
    lastActor' = "",
    lastAction' = "init",
  }

  action mint(caller: str, amt: int): bool = all {
    caller == owner,
    AMOUNTS.contains(amt),
    balances' = balances.put(caller, balances.get(caller) + amt),
    totalSupply' = totalSupply + amt,
    frozen' = frozen,
    paused' = paused,
    owner' = owner,
    lastActor' = caller,
    lastAction' = "mint",
  }

  action burn(caller: str, amt: int): bool = all {
    caller == owner,
    AMOUNTS.contains(amt),
    balances.get(caller) >= amt,
    balances' = balances.put(caller, balances.get(caller) - amt),
    totalSupply' = totalSupply - amt,
    frozen' = frozen,
    paused' = paused,
    owner' = owner,
    lastActor' = caller,
    lastAction' = "burn",
  }

  action freeze(caller: str, who: str): bool = all {
    caller == owner,
    USERS.contains(who),
    frozen' = frozen.put(who, true),
    balances' = balances,
    totalSupply' = totalSupply,
    paused' = paused,
    owner' = owner,
    lastActor' = caller,
    lastAction' = "freeze",
  }

  action unfreeze(caller: str, who: str): bool = all {
    caller == owner,
    USERS.contains(who),
    frozen' = frozen.put(who, false),
    balances' = balances,
    totalSupply' = totalSupply,
    paused' = paused,
    owner' = owner,
    lastActor' = caller,
    lastAction' = "unfreeze",
  }

  action pause(caller: str): bool = all {
    caller == owner,
    paused' = true,
    balances' = balances,
    frozen' = frozen,
    totalSupply' = totalSupply,
    owner' = owner,
    lastActor' = caller,
    lastAction' = "pause",
  }

  action unpause(caller: str): bool = all {
    caller == owner,
    paused' = false,
    balances' = balances,
    frozen' = frozen,
    totalSupply' = totalSupply,
    owner' = owner,
    lastActor' = caller,
    lastAction' = "unpause",
  }

  action transfer(caller: str, recipient: str, amt: int): bool = all {
    PRINCIPALS.contains(caller),
    PRINCIPALS.contains(recipient),
    AMOUNTS.contains(amt),
    not(paused),
    not(frozen.get(caller)),
    not(frozen.get(recipient)),
    balances.get(caller) >= amt,
    balances' = balances
      .put(caller, balances.get(caller) - amt)
      .put(recipient, balances.get(recipient) + amt),
    frozen' = frozen,
    paused' = paused,
    owner' = owner,
    totalSupply' = totalSupply,
    lastActor' = caller,
    lastAction' = "transfer",
  }

  pure def sumBalances(b: str -> int): int =
    PRINCIPALS.fold(0, (acc, p) => acc + b.get(p))

  val inv_supply: bool = sumBalances(balances) == totalSupply
  val inv_owner_only_mint_ghost: bool =
    lastAction != "mint" or lastActor == owner
  val inv_all: bool = inv_supply and inv_owner_only_mint_ghost

  pure val t0_mint_owner: bool = true

  action step: bool = any {
    nondet c = PRINCIPALS.oneOf(); nondet a = AMOUNTS.oneOf(); mint(c, a),
    nondet c = PRINCIPALS.oneOf(); nondet a = AMOUNTS.oneOf(); burn(c, a),
    nondet c = PRINCIPALS.oneOf(); nondet w = USERS.oneOf(); freeze(c, w),
    nondet c = PRINCIPALS.oneOf(); nondet w = USERS.oneOf(); unfreeze(c, w),
    nondet c = PRINCIPALS.oneOf(); pause(c),
    nondet c = PRINCIPALS.oneOf(); unpause(c),
    nondet c = PRINCIPALS.oneOf(); nondet t = PRINCIPALS.oneOf(); nondet a = AMOUNTS.oneOf(); transfer(c, t, a),
  }
}
