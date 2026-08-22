// CIAN Yield Layer — account manager + delegated execute (6h critical)
// SOURCE: protocol-repos/yield/cian-ai_cian-protocol/contracts/core/accountManager/AccountManager.sol
// WHY: residue named keeper/automation dependency; Steakhouse sibling
// AUTHORITY 6h MODELLED: addAccounts/setAuthorization onlyOwner; executeOnAdapter auth; withdraw owner-local
// ABSTRACTED: single adapter markets, multi-call collapsed, delay window omitted

module cian {
  pure val OWNER: str = "owner"
  pure val KEEPER: str = "keeper"
  pure val USERS: Set[str] = Set("alice", "bob")
  pure val ACTORS: Set[str] = Set("owner", "keeper", "alice", "bob", "mallory")
  pure val AMOUNTS: Set[int] = Set(20, 50, 100)
  pure val MARKETS: Set[int] = Set(0, 1)

  var accounts: str -> bool
  var authorized: str -> bool
  var idle: str -> int
  var deployed: str -> (int -> int)
  var lastActor: str
  var lastAction: str
  var lastWasExecute: bool

  pure def marketSum(m: int -> int): int =
    MARKETS.fold(0, (acc, k) => acc + m.get(k))

  pure def ownsNothing(who: str): bool =
    not(USERS.contains(who))

  action init: bool = all {
    accounts' = ACTORS.mapBy(a => USERS.contains(a)),
    authorized' = ACTORS.mapBy(a => a == KEEPER or a == OWNER),
    idle' = ACTORS.mapBy(a => if (USERS.contains(a)) 200 else 0),
    deployed' = ACTORS.mapBy(_ => MARKETS.mapBy(_ => 0)),
    lastActor' = "",
    lastAction' = "init",
    lastWasExecute' = false,
  }

  action addAccount(caller: str, who: str): bool = all {
    caller == OWNER,
    ACTORS.contains(who),
    accounts' = accounts.put(who, true),
    authorized' = authorized,
    idle' = idle,
    deployed' = deployed,
    lastActor' = caller,
    lastAction' = "addAccount",
    lastWasExecute' = false,
  }

  action setAuthorization(caller: str, executor: str, ok: bool): bool = all {
    caller == OWNER,
    ACTORS.contains(executor),
    authorized' = authorized.put(executor, ok),
    accounts' = accounts,
    idle' = idle,
    deployed' = deployed,
    lastActor' = caller,
    lastAction' = "setAuthorization",
    lastWasExecute' = false,
  }

  action deposit(caller: str, amt: int): bool = all {
    USERS.contains(caller),
    accounts.get(caller),
    AMOUNTS.contains(amt),
    idle' = idle.put(caller, idle.get(caller) + amt),
    accounts' = accounts,
    authorized' = authorized,
    deployed' = deployed,
    lastActor' = caller,
    lastAction' = "deposit",
    lastWasExecute' = false,
  }

  // executeOnAdapter — authorized keeper reallocates user funds (conservation)
  action executeFromIdle(caller: str, account: str, mTo: int, amt: int): bool = all {
    authorized.get(caller),
    accounts.get(account),
    USERS.contains(account),
    MARKETS.contains(mTo),
    AMOUNTS.contains(amt),
    idle.get(account) >= amt,
    idle' = idle.put(account, idle.get(account) - amt),
    deployed' = deployed.put(account,
      deployed.get(account).put(mTo, deployed.get(account).get(mTo) + amt)),
    accounts' = accounts,
    authorized' = authorized,
    lastActor' = caller,
    lastAction' = "executeOnAdapter",
    lastWasExecute' = true,
  }

  action executeRebalance(caller: str, account: str, mFrom: int, mTo: int, amt: int): bool = all {
    authorized.get(caller),
    accounts.get(account),
    USERS.contains(account),
    MARKETS.contains(mFrom),
    MARKETS.contains(mTo),
    AMOUNTS.contains(amt),
    deployed.get(account).get(mFrom) >= amt,
    idle' = idle,
    deployed' = deployed.put(account,
      deployed.get(account)
        .put(mFrom, deployed.get(account).get(mFrom) - amt)
        .put(mTo, deployed.get(account).get(mTo) + amt)),
    accounts' = accounts,
    authorized' = authorized,
    lastActor' = caller,
    lastAction' = "executeOnAdapter",
    lastWasExecute' = true,
  }

  action withdrawAssets(caller: str, amt: int): bool = all {
    USERS.contains(caller),
    accounts.get(caller),
    AMOUNTS.contains(amt),
    idle.get(caller) >= amt,
    idle' = idle.put(caller, idle.get(caller) - amt),
    accounts' = accounts,
    authorized' = authorized,
    deployed' = deployed,
    lastActor' = caller,
    lastAction' = "withdrawAssets",
    lastWasExecute' = false,
  }

  val inv_nonneg: bool =
    USERS.forall(u => idle.get(u) >= 0)
  val inv_execute_auth: bool =
    not(lastWasExecute) or authorized.get(lastActor)
  val inv_all: bool = inv_nonneg and inv_execute_auth

  pure val t0_keeper_not_depositor: bool = ownsNothing(KEEPER)

  action step: bool = any {
    nondet c = ACTORS.oneOf(); nondet w = ACTORS.oneOf(); addAccount(c, w),
    nondet c = ACTORS.oneOf(); nondet e = ACTORS.oneOf(); nondet ok = Set(true, false).oneOf(); setAuthorization(c, e, ok),
    nondet c = USERS.oneOf(); nondet a = AMOUNTS.oneOf(); deposit(c, a),
    nondet c = ACTORS.oneOf(); nondet acc = USERS.oneOf(); nondet mt = MARKETS.oneOf(); nondet a = AMOUNTS.oneOf(); executeFromIdle(c, acc, mt, a),
    nondet c = ACTORS.oneOf(); nondet acc = USERS.oneOf(); nondet mf = MARKETS.oneOf(); nondet mt = MARKETS.oneOf(); nondet a = AMOUNTS.oneOf(); executeRebalance(c, acc, mf, mt, a),
    nondet c = USERS.oneOf(); nondet a = AMOUNTS.oneOf(); withdrawAssets(c, a),
  }
}
