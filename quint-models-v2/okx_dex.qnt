// OKX DEX Router — multi-hop aggregator (simplified)
// SOURCE: protocol-repos/intent/okxlabs_Web3-DEX-Router-EVM-V1 contracts/8/
// AUTHORITY 6h MODELLED: swap permissionless for token holders; setAdapter onlyOwner
// ABSTRACTED: one CP pool; multi-adapter path collapsed; no RFQ/permit

module okx_dex {
  pure val OWNER: str = "owner"
  pure val USERS: Set[str] = Set("alice", "bob")
  pure val ACTORS: Set[str] = Set("owner", "alice", "bob", "mallory")
  pure val AMTS: Set[int] = Set(5, 10, 20)

  var balA: str -> int
  var balB: str -> int
  var reserveA: int
  var reserveB: int
  var adapterEnabled: bool
  var lastActor: str
  var lastAction: str

  pure def getAmountOut(amountIn: int, resIn: int, resOut: int): int =
    if (resIn + amountIn == 0) 0 else (amountIn * resOut) / (resIn + amountIn)

  action init: bool = all {
    balA' = ACTORS.mapBy(a => if (USERS.contains(a)) 100 else 0),
    balB' = ACTORS.mapBy(_ => 0),
    reserveA' = 1000,
    reserveB' = 1000,
    adapterEnabled' = true,
    lastActor' = "",
    lastAction' = "init",
  }

  action setAdapter(caller: str, en: bool): bool = all {
    caller == OWNER,
    adapterEnabled' = en,
    balA' = balA,
    balB' = balB,
    reserveA' = reserveA,
    reserveB' = reserveB,
    lastActor' = caller,
    lastAction' = "setAdapter",
  }

  action swapAtoB(caller: str, amtIn: int): bool = all {
    USERS.contains(caller),
    adapterEnabled,
    AMTS.contains(amtIn),
    balA.get(caller) >= amtIn,
    getAmountOut(amtIn, reserveA, reserveB) > 0,
    balA' = balA.put(caller, balA.get(caller) - amtIn),
    balB' = balB.put(caller, balB.get(caller) + getAmountOut(amtIn, reserveA, reserveB)),
    reserveA' = reserveA + amtIn,
    reserveB' = reserveB - getAmountOut(amtIn, reserveA, reserveB),
    adapterEnabled' = adapterEnabled,
    lastActor' = caller,
    lastAction' = "swapAtoB",
  }

  val inv_reserves_pos: bool = reserveA > 0 and reserveB > 0
  val inv_all: bool = inv_reserves_pos

  pure val t0_amount_out_example: bool =
    getAmountOut(10, 1000, 1000) == 9

  action step: bool = any {
    nondet c = ACTORS.oneOf(); nondet e = Set(true, false).oneOf(); setAdapter(c, e),
    nondet c = USERS.oneOf(); nondet a = AMTS.oneOf(); swapAtoB(c, a),
  }
}
