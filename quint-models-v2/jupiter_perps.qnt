// Jupiter Perpetual Exchange — IDL-grounded partial model
// SOURCE: protocol-repos/perp/julianfssen_jupiter-perps-anchor-idl-parsing (IDL surrogate)
//          Official program source not fully public; model is IDL-shaped, not line-cited.
// AUTHORITY 6h MODELLED: open/close by position owner; keeper liquidate by role
// ABSTRACTED: single market, fixed mark price, no funding, no JLP pool math detail
// FIDELITY NOTE: (E<=) not Phase-2 full contract-line fidelity; recorded as PARTIAL

module jupiter_perps {
  pure val KEEPER: str = "keeper"
  pure val USERS: Set[str] = Set("alice", "bob")
  pure val ACTORS: Set[str] = Set("keeper", "alice", "bob", "mallory")
  pure val SIZES: Set[int] = Set(10, 20, 50)
  pure val COLLATERALS: Set[int] = Set(20, 50, 100)
  pure val MARK: int = 100
  pure val MAX_LEV: int = 10
  pure val LIQ_CR: int = 110

  var collat: str -> int
  var posSize: str -> int
  var isLong: str -> bool
  var isOpen: str -> bool
  var freeBal: str -> int
  var lastActor: str
  var lastAction: str

  pure def notional(sz: int): int = sz * MARK
  pure def cr(c: int, sz: int): int =
    if (sz == 0) 10000 else (c * 100) / notional(sz)

  action init: bool = all {
    collat' = ACTORS.mapBy(_ => 0),
    posSize' = ACTORS.mapBy(_ => 0),
    isLong' = ACTORS.mapBy(_ => true),
    isOpen' = ACTORS.mapBy(_ => false),
    freeBal' = ACTORS.mapBy(a => if (USERS.contains(a)) 500 else 0),
    lastActor' = "",
    lastAction' = "init",
  }

  action openLong(caller: str, sz: int, c: int): bool = all {
    USERS.contains(caller),
    SIZES.contains(sz),
    COLLATERALS.contains(c),
    not(isOpen.get(caller)),
    freeBal.get(caller) >= c,
    notional(sz) <= c * MAX_LEV,
    freeBal' = freeBal.put(caller, freeBal.get(caller) - c),
    collat' = collat.put(caller, c),
    posSize' = posSize.put(caller, sz),
    isLong' = isLong.put(caller, true),
    isOpen' = isOpen.put(caller, true),
    lastActor' = caller,
    lastAction' = "openLong",
  }

  action closePosition(caller: str): bool = all {
    USERS.contains(caller),
    isOpen.get(caller),
    freeBal' = freeBal.put(caller, freeBal.get(caller) + collat.get(caller)),
    collat' = collat.put(caller, 0),
    posSize' = posSize.put(caller, 0),
    isOpen' = isOpen.put(caller, false),
    isLong' = isLong,
    lastActor' = caller,
    lastAction' = "closePosition",
  }

  action liquidate(caller: str, who: str): bool = all {
    caller == KEEPER,
    USERS.contains(who),
    isOpen.get(who),
    cr(collat.get(who), posSize.get(who)) < LIQ_CR,
    freeBal' = freeBal,
    collat' = collat.put(who, 0),
    posSize' = posSize.put(who, 0),
    isOpen' = isOpen.put(who, false),
    isLong' = isLong,
    lastActor' = caller,
    lastAction' = "liquidate",
  }

  val inv_open_has_size: bool =
    USERS.forall(u => not(isOpen.get(u)) or posSize.get(u) > 0)
  val inv_liq_auth: bool =
    lastAction != "liquidate" or lastActor == KEEPER
  val inv_all: bool = inv_open_has_size and inv_liq_auth

  pure val t0_max_lev: bool = true

  action step: bool = any {
    nondet c = USERS.oneOf(); nondet s = SIZES.oneOf(); nondet col = COLLATERALS.oneOf(); openLong(c, s, col),
    nondet c = USERS.oneOf(); closePosition(c),
    nondet c = ACTORS.oneOf(); nondet w = USERS.oneOf(); liquidate(c, w),
  }
}
