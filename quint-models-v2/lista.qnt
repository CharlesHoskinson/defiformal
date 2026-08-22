// Lista CDP — deposit / borrow / payback / withdraw (Interaction.sol)
// SOURCE: protocol-repos/cdp/lista-dao_lista-dao-contracts/contracts/Interaction.sol
// AUTHORITY 6h MODELLED: deposit whitelisted; borrow/payback/withdraw owner-local; paybackFor third party
// ABSTRACTED: single collateral, fixed PRICE, rate=1, no drip, no liquidation path
// AUTHORITY OMITTED: blacklist / collateral live switches frozen live=1

module lista {
  pure val USERS: Set[str] = Set("alice", "bob", "carol")
  pure val ACTORS: Set[str] = Set("alice", "bob", "carol", "mallory")
  pure val COLLAT_AMTS: Set[int] = Set(50, 100, 200)
  pure val DEBT_AMTS: Set[int] = Set(10, 40, 80)
  pure val PRICE: int = 2
  pure val MIN_CR: int = 150

  var collat: str -> int
  var debt: str -> int
  var freeCollat: str -> int
  var freeHay: str -> int
  var whitelisted: str -> bool
  var lastActor: str
  var lastAction: str

  pure def cr(c: int, d: int): int =
    if (d == 0) 10000 else (c * PRICE * 100) / d

  pure def safe(c: int, d: int): bool =
    d == 0 or cr(c, d) >= MIN_CR

  action init: bool = all {
    collat' = ACTORS.mapBy(_ => 0),
    debt' = ACTORS.mapBy(_ => 0),
    freeCollat' = ACTORS.mapBy(a => if (USERS.contains(a)) 500 else 0),
    freeHay' = ACTORS.mapBy(_ => 0),
    whitelisted' = ACTORS.mapBy(a => USERS.contains(a)),
    lastActor' = "",
    lastAction' = "init",
  }

  // Interaction.sol:173 deposit
  action deposit(caller: str, participant: str, amt: int): bool = all {
    ACTORS.contains(caller),
    USERS.contains(participant),
    COLLAT_AMTS.contains(amt),
    whitelisted.get(participant),
    freeCollat.get(caller) >= amt,
    freeCollat' = freeCollat.put(caller, freeCollat.get(caller) - amt),
    collat' = collat.put(participant, collat.get(participant) + amt),
    debt' = debt,
    freeHay' = freeHay,
    whitelisted' = whitelisted,
    lastActor' = caller,
    lastAction' = "deposit",
  }

  // Interaction.sol:205 borrow
  action borrow(caller: str, amt: int): bool = all {
    USERS.contains(caller),
    DEBT_AMTS.contains(amt),
    safe(collat.get(caller), debt.get(caller) + amt),
    debt' = debt.put(caller, debt.get(caller) + amt),
    freeHay' = freeHay.put(caller, freeHay.get(caller) + amt),
    collat' = collat,
    freeCollat' = freeCollat,
    whitelisted' = whitelisted,
    lastActor' = caller,
    lastAction' = "borrow",
  }

  // Interaction.sol:236 payback
  action payback(caller: str, amt: int): bool = all {
    USERS.contains(caller),
    DEBT_AMTS.contains(amt),
    freeHay.get(caller) >= amt,
    debt.get(caller) >= amt,
    freeHay' = freeHay.put(caller, freeHay.get(caller) - amt),
    debt' = debt.put(caller, debt.get(caller) - amt),
    collat' = collat,
    freeCollat' = freeCollat,
    whitelisted' = whitelisted,
    lastActor' = caller,
    lastAction' = "payback",
  }

  // Interaction.sol:247 paybackFor
  action paybackFor(caller: str, borrower: str, amt: int): bool = all {
    ACTORS.contains(caller),
    USERS.contains(borrower),
    DEBT_AMTS.contains(amt),
    freeHay.get(caller) >= amt,
    debt.get(borrower) >= amt,
    freeHay' = freeHay.put(caller, freeHay.get(caller) - amt),
    debt' = debt.put(borrower, debt.get(borrower) - amt),
    collat' = collat,
    freeCollat' = freeCollat,
    whitelisted' = whitelisted,
    lastActor' = caller,
    lastAction' = "paybackFor",
  }

  // Interaction.sol:337 withdraw
  action withdraw(caller: str, amt: int): bool = all {
    USERS.contains(caller),
    COLLAT_AMTS.contains(amt),
    collat.get(caller) >= amt,
    safe(collat.get(caller) - amt, debt.get(caller)),
    collat' = collat.put(caller, collat.get(caller) - amt),
    freeCollat' = freeCollat.put(caller, freeCollat.get(caller) + amt),
    debt' = debt,
    freeHay' = freeHay,
    whitelisted' = whitelisted,
    lastActor' = caller,
    lastAction' = "withdraw",
  }

  val inv_safe_positions: bool =
    USERS.forall(u => safe(collat.get(u), debt.get(u)))
  val inv_nonneg: bool =
    USERS.forall(u => collat.get(u) >= 0 and debt.get(u) >= 0)
  val inv_all: bool = inv_safe_positions and inv_nonneg

  pure val t0_price_2: bool = (100 * 2 * 100) / 80 == 250

  action step: bool = any {
    nondet c = ACTORS.oneOf(); nondet p = USERS.oneOf(); nondet a = COLLAT_AMTS.oneOf(); deposit(c, p, a),
    nondet c = USERS.oneOf(); nondet a = DEBT_AMTS.oneOf(); borrow(c, a),
    nondet c = USERS.oneOf(); nondet a = DEBT_AMTS.oneOf(); payback(c, a),
    nondet c = ACTORS.oneOf(); nondet b = USERS.oneOf(); nondet a = DEBT_AMTS.oneOf(); paybackFor(c, b, a),
    nondet c = USERS.oneOf(); nondet a = COLLAT_AMTS.oneOf(); withdraw(c, a),
  }
}
