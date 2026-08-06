// ---------------------------------------------------------------------------
//  MetaMorpho — the delegated allocation mandate
//
//  SOURCE: protocol-repos/lend/morpho-org_metamorpho, rev 58e758b (2026-07-31),
//          src/MetaMorpho.sol
//
//  WHY THIS SPEC EXISTS
//    corpus50/VERDICT.md §1 calls the delegated allocation mandate the
//    most-confirmed gap in the project, reached independently by all three
//    lanes.  TODO recorded it as "a known refuter … needs no further work",
//    which is a refutation asserted rather than exhibited.  It was never
//    formalised because stating it requires caller identity, and 0 of 17
//    gate-opening actions in the v1 corpus model any caller
//    (GATE-1.1B-PAIR4.md).  This is the first spec in the corpus written under
//    convention 6h, and therefore the first that can state the mechanism at all.
//
//  WHAT IT IS BUILT TO SHOW, and the claim is machine-checked below:
//    `reallocate` satisfies conservation EXACTLY — MetaMorpho.sol:414 enforces
//    `totalWithdrawn == totalSupplied` — while a principal who owns none of the
//    assets redistributes them.  So `inv_conservation` reports [ok] over the
//    whole reachable space, and the mechanism is invisible to it.  Phase 2 found
//    that conservation never once detected a DELETED mechanism; here it fails to
//    detect a PRESENT one, for the same reason.  What distinguishes the mandate
//    is who chose, and conservation has no term for that.
//
//  AUTHORITY (convention 6h)
//    Modelled, not omitted.  `onlyAllocatorRole` (MetaMorpho.sol:147-155) admits
//    isAllocator[sender], the curator, or the owner.  `setIsAllocator` (:195) and
//    `setCurator` (:186) are onlyOwner, so the GRANTING of authority is itself a
//    transition and is modelled — a spec that froze the role set as a constant
//    would delete it.
//
//  ABSTRACTED, each an (E<=) restriction:
//    - 3 markets, no market params beyond a cap.  Morpho Blue underneath is a
//      balance per market; its interest accrual is out of scope and its absence
//      cannot flatter the result, since accrual is owner-local.
//    - the timelock on cap increases (:273 submitCap → pendingCap) is collapsed
//      to an immediate set.  It bounds WHEN a cap moves, never WHO reallocates,
//      so it cannot host the witness.
//    - `reallocate` takes a single (from, to, amount) triple rather than an
//      arbitrary MarketAllocation[].  A vector is a fold of triples and each
//      element carries the same authority guard; the arity is not what the
//      witness turns on.  Recorded because it IS a restriction.
//    - fees, skim, guardian revocation: no guard in the cited functions reads
//      them.
// ---------------------------------------------------------------------------

module metamorpho {

  // ---------------------------------------------------------------------------
  // PROTOCOL CONSTANTS (convention 4)
  // ---------------------------------------------------------------------------

  pure val OWNER: str = "owner"
  /// Principals. `mallory` holds no shares and is granted the allocator role —
  /// the witness account. `alice`/`bob` are depositors and never hold a role.
  pure val PRINCIPALS: Set[str] = Set("owner", "curator", "mallory", "alice", "bob")
  pure val DEPOSITORS: Set[str] = Set("alice", "bob")
  pure val MARKETS: Set[int] = Set(0, 1, 2)

  /// Convention 8a: at most 8 enumerated values per nondet.
  pure val DEPOSIT_AMOUNTS: Set[int] = Set(100, 250, 400)
  pure val MOVE_AMOUNTS: Set[int] = Set(50, 100, 200)
  /// Convention 8c: the domain must cross the cap. CAP_HI admits a full move,
  /// CAP_LO refuses one, and CAP_ZERO is the UnauthorizedMarket branch (:400).
  pure val CAP_VALUES: Set[int] = Set(0, 150, 1000)

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  /// MetaMorpho.sol:186 — settable by the owner.
  var curator: str
  /// MetaMorpho.sol:195 — isAllocator mapping, settable by the owner.
  var isAllocator: str -> bool
  /// config[id].cap — MetaMorpho.sol:273.
  var caps: int -> int
  /// The vault's supply position in each Morpho Blue market.
  var supplied: int -> int
  /// Vault assets not currently in any market.
  var idle: int
  /// ERC4626 shares, by depositor.
  var shares: str -> int
  var totalShares: int

  /// GHOST — trace labels. Read only by wit_* and by nothing else; no guard and
  /// no `pure def` may read them (P2-FIDELITY §1).
  var lastActor: str
  var lastWasReallocate: bool

  // ---------------------------------------------------------------------------
  // PURE DEFS
  // ---------------------------------------------------------------------------

  pure def marketSum(s: int -> int): int =
    MARKETS.fold(0, (acc, m) => acc + s.get(m))

  /// Total assets under management. MetaMorpho.sol:414 is exactly the statement
  /// that `reallocate` preserves this.
  pure def totalAssets(s: int -> int, i: int): int = marketSum(s) + i

  /// onlyAllocatorRole — MetaMorpho.sol:147-155.
  pure def hasAllocatorRole(who: str, alloc: str -> bool, cur: str): bool =
    alloc.get(who) or who == cur or who == OWNER

  /// onlyCuratorRole — MetaMorpho.sol:139-144.
  pure def hasCuratorRole(who: str, cur: str): bool =
    who == cur or who == OWNER

  /// OWNER-LOCALITY, the property the refutation turns on: a transition changes
  /// only positions attributable to its caller. Every basis family satisfies it.
  pure def ownsNothing(who: str, sh: str -> int): bool =
    not(DEPOSITORS.contains(who)) or sh.get(who) == 0

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  action init: bool = all {
    curator' = "curator",
    isAllocator' = PRINCIPALS.mapBy(_ => false),
    caps' = MARKETS.mapBy(_ => 1000),
    supplied' = MARKETS.mapBy(_ => 0),
    idle' = 0,
    shares' = PRINCIPALS.mapBy(_ => 0),
    totalShares' = 0,
    lastActor' = "",
    lastWasReallocate' = false,
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  /// ERC4626 deposit. Owner-local: moves only the caller's own position.
  action deposit(caller: str, amt: int): bool = all {
    DEPOSITORS.contains(caller),
    DEPOSIT_AMOUNTS.contains(amt),
    shares' = shares.put(caller, shares.get(caller) + amt),
    totalShares' = totalShares + amt,
    idle' = idle + amt,
    curator' = curator,
    isAllocator' = isAllocator,
    caps' = caps,
    supplied' = supplied,
    lastActor' = caller,
    lastWasReallocate' = false,
  }

  /// MetaMorpho.sol:195 setIsAllocator — onlyOwner. The GRANTING of the mandate.
  action setIsAllocator(caller: str, who: str, flag: bool): bool = all {
    caller == OWNER,
    PRINCIPALS.contains(who),
    isAllocator' = isAllocator.put(who, flag),
    curator' = curator,
    caps' = caps,
    supplied' = supplied,
    idle' = idle,
    shares' = shares,
    totalShares' = totalShares,
    lastActor' = caller,
    lastWasReallocate' = false,
  }

  /// MetaMorpho.sol:186 setCurator — onlyOwner. The second authority-granting
  /// transition, and the reason `curator` is a `var`: a spec that froze it would
  /// delete the owner's power to replace the curator, which is itself part of
  /// the mandate. Added after respec_lint D2 reported `curator` as declared but
  /// never driven — a true positive.
  action setCurator(caller: str, who: str): bool = all {
    caller == OWNER,
    PRINCIPALS.contains(who),
    who != curator,
    curator' = who,
    isAllocator' = isAllocator,
    caps' = caps,
    supplied' = supplied,
    idle' = idle,
    shares' = shares,
    totalShares' = totalShares,
    lastActor' = caller,
    lastWasReallocate' = false,
  }

  /// ERC4626 withdraw, restricted to idle assets.
  ///   AUTHORITY OMITTED: none — withdraw is owner-local by construction.
  ///   (E<=) the real vault walks the withdraw queue, pulling from markets when
  ///   idle is short (MetaMorpho.sol:323 updateWithdrawQueue). Restricting to
  ///   idle removes transitions, never adds one, and the queue walk is
  ///   owner-local so it cannot host the witness either way. Added after
  ///   respec_lint D2 reported `totalShares` as written once and never driven.
  action withdraw(caller: str, amt: int): bool = all {
    DEPOSITORS.contains(caller),
    DEPOSIT_AMOUNTS.contains(amt),
    shares.get(caller) >= amt,
    idle >= amt,
    shares' = shares.put(caller, shares.get(caller) - amt),
    totalShares' = totalShares - amt,
    idle' = idle - amt,
    curator' = curator,
    isAllocator' = isAllocator,
    caps' = caps,
    supplied' = supplied,
    lastActor' = caller,
    lastWasReallocate' = false,
  }

  /// MetaMorpho.sol:273 submitCap — onlyCuratorRole. Timelock collapsed; see
  /// ABSTRACTED.
  action submitCap(caller: str, m: int, newCap: int): bool = all {
    hasCuratorRole(caller, curator),
    MARKETS.contains(m),
    CAP_VALUES.contains(newCap),
    newCap >= supplied.get(m),
    caps' = caps.put(m, newCap),
    curator' = curator,
    isAllocator' = isAllocator,
    supplied' = supplied,
    idle' = idle,
    shares' = shares,
    totalShares' = totalShares,
    lastActor' = caller,
    lastWasReallocate' = false,
  }

  /// Move idle assets into a market. Guarded by the cap, as :400/:402.
  action allocateIdle(caller: str, m: int, amt: int): bool = all {
    hasAllocatorRole(caller, isAllocator, curator),
    MARKETS.contains(m),
    MOVE_AMOUNTS.contains(amt),
    idle >= amt,
    caps.get(m) > 0,
    supplied.get(m) + amt <= caps.get(m),
    supplied' = supplied.put(m, supplied.get(m) + amt),
    idle' = idle - amt,
    curator' = curator,
    isAllocator' = isAllocator,
    caps' = caps,
    shares' = shares,
    totalShares' = totalShares,
    lastActor' = caller,
    lastWasReallocate' = true,
  }

  /// MetaMorpho.sol:366 `reallocate` — onlyAllocatorRole.
  ///
  /// THE MECHANISM. A principal chosen by the owner redistributes assets that
  /// belong to the depositors, bounded only by:
  ///   :400  the target market must have a non-zero cap
  ///   :402  supplyAssets + suppliedAssets > supplyCap reverts
  ///   :414  totalWithdrawn == totalSupplied — exact conservation
  /// Nothing in those three constraints mentions who the caller is, beyond the
  /// role gate, and nothing at all mentions the depositors.
  action reallocate(caller: str, mFrom: int, mTo: int, amt: int): bool = all {
    hasAllocatorRole(caller, isAllocator, curator),
    MARKETS.contains(mFrom),
    MARKETS.contains(mTo),
    mFrom != mTo,
    MOVE_AMOUNTS.contains(amt),
    supplied.get(mFrom) >= amt,
    caps.get(mTo) > 0,
    supplied.get(mTo) + amt <= caps.get(mTo),
    supplied' = supplied.put(mFrom, supplied.get(mFrom) - amt)
                        .put(mTo, supplied.get(mTo) + amt),
    idle' = idle,
    curator' = curator,
    isAllocator' = isAllocator,
    caps' = caps,
    shares' = shares,
    totalShares' = totalShares,
    lastActor' = caller,
    lastWasReallocate' = true,
  }

  action step: bool = any {
    nondet u = DEPOSITORS.oneOf()
    nondet a = DEPOSIT_AMOUNTS.oneOf()
    deposit(u, a),

    nondet w = PRINCIPALS.oneOf()
    setIsAllocator(OWNER, w, true),

    nondet w = PRINCIPALS.oneOf()
    setCurator(OWNER, w),

    nondet u = DEPOSITORS.oneOf()
    nondet a = DEPOSIT_AMOUNTS.oneOf()
    withdraw(u, a),

    nondet c = PRINCIPALS.oneOf()
    nondet m = MARKETS.oneOf()
    nondet k = CAP_VALUES.oneOf()
    submitCap(c, m, k),

    nondet c = PRINCIPALS.oneOf()
    nondet m = MARKETS.oneOf()
    nondet a = MOVE_AMOUNTS.oneOf()
    allocateIdle(c, m, a),

    nondet c = PRINCIPALS.oneOf()
    nondet f = MARKETS.oneOf()
    nondet t = MARKETS.oneOf()
    nondet a = MOVE_AMOUNTS.oneOf()
    reallocate(c, f, t, a),
  }

  // ---------------------------------------------------------------------------
  // INVARIANTS — these all HOLD, and that is the point
  // ---------------------------------------------------------------------------

  /// MetaMorpho.sol:414. The vault's assets are conserved by every transition
  /// that redistributes them.
  val inv_conservation: bool =
    totalAssets(supplied, idle) == totalShares

  val inv_capsRespected: bool =
    MARKETS.forall(m => supplied.get(m) <= caps.get(m) or caps.get(m) == 0)

  val inv_nonNegative: bool = and {
    MARKETS.forall(m => supplied.get(m) >= 0),
    idle >= 0,
    PRINCIPALS.forall(u => shares.get(u) >= 0),
  }

  /// Share accounting is untouched by reallocation, which is exactly why no
  /// share-based invariant can see it either.
  val inv_sharesSum: bool =
    PRINCIPALS.fold(0, (acc, u) => acc + shares.get(u)) == totalShares

  val inv_all: bool = and {
    inv_conservation,
    inv_capsRespected,
    inv_nonNegative,
    inv_sharesSum,
  }

  // ---------------------------------------------------------------------------
  // WITNESSES — each must report [violation], i.e. the state IS reachable
  // ---------------------------------------------------------------------------

  /// THE REFUTER, as a reachability obligation. A state in which the last
  /// transition was a reallocation performed by a principal owning none of the
  /// assets it moved. Owner-locality fails here and holds for every basis family.
  val wit_nonLocalReallocation: bool = not(and {
    lastWasReallocate,
    ownsNothing(lastActor, shares),
    totalShares > 0,
  })

  /// Sharper: the actor is a depositor-set outsider entirely — `mallory` holds
  /// no shares and never can, yet moves assets that alice and bob deposited.
  val wit_outsiderMovesDepositorAssets: bool = not(and {
    lastWasReallocate,
    lastActor == "mallory",
    marketSum(supplied) > 0,
    totalShares > 0,
  })

  /// The mandate is GRANTED, not innate — mallory holds the role only because
  /// the owner said so. A spec freezing the role set could not host this.
  val wit_mandateGranted: bool = not(isAllocator.get("mallory"))

  /// Convention 8c: the cap must actually bind somewhere reachable.
  val wit_capBinds: bool =
    not(MARKETS.exists(m => caps.get(m) == 150 and supplied.get(m) == 150))

  // ---------------------------------------------------------------------------
  // T0 CONFORMANCE VECTORS — exact values read off the contract
  // ---------------------------------------------------------------------------

  /// onlyAllocatorRole admits three principals and refuses the rest (:147-155).
  pure val t0_role_a: bool =
    hasAllocatorRole("mallory", Map("mallory" -> true), "curator")
  /// NOTE: `alloc.get(who)` is evaluated even when a later disjunct would
  /// succeed, so every vector must pass a map containing the queried key. The
  /// first cut of these vectors passed Map("mallory" -> ...) while querying
  /// "curator" and died with QNT507 -- caught by inv_T0, which is what it is for.
  pure val t0_role_b: bool =
    hasAllocatorRole("curator", Map("curator" -> false), "curator")
  pure val t0_role_c: bool =
    hasAllocatorRole(OWNER, Map("owner" -> false), "curator")
  pure val t0_role_d: bool =
    not(hasAllocatorRole("alice", Map("alice" -> false), "curator"))

  /// onlyCuratorRole is strictly narrower than onlyAllocatorRole (:139-144).
  pure val t0_role_e: bool = not(hasCuratorRole("mallory", "curator"))

  /// Conservation is a property of the totals, not of the distribution.
  pure val t0_cons_a: bool =
    totalAssets(Map(0 -> 100, 1 -> 200, 2 -> 0), 50) == 350
  pure val t0_cons_b: bool =
    totalAssets(Map(0 -> 0, 1 -> 300, 2 -> 0), 50) == 350

  /// Owner-locality, evaluated at the witness account.
  pure val t0_local_a: bool = ownsNothing("mallory", Map("mallory" -> 0))
  pure val t0_local_b: bool = not(ownsNothing("alice", Map("alice" -> 100)))

  val inv_T0: bool = and {
    t0_role_a, t0_role_b, t0_role_c, t0_role_d, t0_role_e,
    t0_cons_a, t0_cons_b, t0_local_a, t0_local_b,
  }
}
