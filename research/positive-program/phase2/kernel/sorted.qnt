// Sorted-by-key collection with extremal selection and budgeted prefix consumption.
// Models Liquity v2 SortedTroves + TroveManager.redeemCollateral.
// Source: liquity_bold/contracts/src/SortedTroves.sol (insert/remove, ordered by
// annual interest rate) and TroveManager.sol:770,785 (getLast(), getPrev() walk).
module sorted {

  type Trove = { id: int, rate: int, debt: int, coll: int, active: bool }

  // ---------------------------------------------------------------------------
  // (a) INSERT MAINTAINING ORDER
  // SortedTroves.sol _insertSlice: list is ordered by annual interest rate
  // DESCENDING (head = highest rate), so getLast() is the lowest rate.
  // Ties broken by id so insertion is a total function of the key set --
  // this is what keeps the structure from adding reachable states.
  // ---------------------------------------------------------------------------

  /// true iff `a` must come strictly before `b` in the list
  pure def before(a: Trove, b: Trove): bool =
    a.rate > b.rate or (a.rate == b.rate and a.id < b.id)

  pure def insertSorted(l: List[Trove], t: Trove): List[Trove] = {
    val r = l.foldl((List(), false), (acc, e) =>
      if (acc._2) (acc._1.append(e), true)
      else if (before(t, e)) (acc._1.append(t).append(e), true)
      else (acc._1.append(e), false))
    if (r._2) r._1 else r._1.append(t)
  }

  pure def removeById(l: List[Trove], id: int): List[Trove] =
    l.foldl(List(), (acc, e) => if (e.id == id) acc else acc.append(e))

  /// re-insert after a key change (SortedTroves.reInsert)
  pure def reInsert(l: List[Trove], t: Trove): List[Trove] =
    insertSorted(removeById(l, t.id), t)

  /// the ordering invariant the structure must satisfy at every state
  pure def isSorted(l: List[Trove]): bool =
    l.indices().forall(i => i + 1 >= l.length() or before(l[i], l[i + 1]))

  // ---------------------------------------------------------------------------
  // (b) EXTREMAL SELECTION
  // sortedTroves.getLast() == the trove with the LOWEST interest rate.
  // Deterministic: a function of state, not a nondet choice.
  // ---------------------------------------------------------------------------

  pure def getFirst(l: List[Trove]): Trove = l.head()          // highest rate
  pure def getLast(l: List[Trove]): Trove = l[l.length() - 1]  // lowest rate

  /// The same extremum computed by fold, to show the two agree (see `extremalAgrees`).
  pure def minByRate(l: List[Trove]): Trove =
    l.tail().foldl(l.head(), (m, e) => if (before(m, e)) e else m)

  // ---------------------------------------------------------------------------
  // (c) CONSUME A PREFIX UNDER AN AMOUNT BUDGET
  // TroveManager.redeemCollateral: walk from getLast() backwards via getPrev(),
  // redeeming min(remaining, trove.debt) from each, stopping when remaining == 0.
  // Skips troves with ICR < 100% (kept: it is part of the mechanism).
  // ---------------------------------------------------------------------------

  type RedeemAcc = {
    rev: List[Trove],   // troves rebuilt in reverse-walk order
    remaining: int,
    collOut: int,
    touched: int,       // how many troves the walk actually hit
    price: int,
  }

  pure def icrOk(t: Trove, price: int): bool = t.coll * price >= t.debt * WAD

  pure val WAD: int = 1000000

  /// one step of the getPrev() walk, applied to the trove at the tail first
  pure def redeemOne(acc: RedeemAcc, t: Trove): RedeemAcc =
    if (acc.remaining <= 0 or not(t.active)) { ...acc, rev: acc.rev.append(t) }
    else if (not(icrOk(t, acc.price))) { ...acc, rev: acc.rev.append(t) }  // skip, keep walking
    else {
      val lot = if (acc.remaining < t.debt) acc.remaining else t.debt
      val coll = lot * WAD / acc.price
      val t2 = { ...t, debt: t.debt - lot, coll: t.coll - coll,
                 active: t.debt - lot > 0 }
      { rev: acc.rev.append(t2), remaining: acc.remaining - lot,
        collOut: acc.collOut + coll, touched: acc.touched + 1, price: acc.price }
    }

  /// reverse a list (walk order is tail -> head)
  pure def rev(l: List[Trove]): List[Trove] =
    l.foldl(List(), (acc, e) => List(e).concat(acc))

  /// Full redemption: minimal prefix of the reversed list, cut off endogenously.
  pure def redeemFrom(l: List[Trove], amount: int, price: int): RedeemAcc = {
    val walked = rev(l).foldl(
      { rev: List(), remaining: amount, collOut: 0, touched: 0, price: price },
      (acc, t) => redeemOne(acc, t))
    { ...walked, rev: rev(walked.rev) }   // back to head-first order
  }

  // ---------------------------------------------------------------------------
  // THE MECHANISM CHECK
  // Three properties that together say "extremal selection consuming a minimal
  // prefix, cut off endogenously by the redemption amount". A spec that redeems
  // from a nondet trove fails (A) and (B).
  // ---------------------------------------------------------------------------

  pure def eligible(t: Trove, price: int): bool = t.active and icrOk(t, price)

  pure def redeemIsExtremal(l: List[Trove], amount: int, price: int): bool = {
    val r = redeemFrom(l, amount, price)
    val touched = l.indices().filter(i => r.rev[i].debt < l[i].debt)
    and {
      // (A) ORDER-RESPECT: nothing is touched before everything with a strictly
      //     lower rate (= a deeper index) has been fully drained.
      touched.forall(i =>
        (i + 1).to(l.length() - 1).forall(j =>
          not(eligible(l[j], price)) or r.rev[j].debt == 0)),
      // (B) MINIMAL PREFIX: at most one trove is left partially redeemed.
      l.indices().filter(i => r.rev[i].debt > 0 and r.rev[i].debt < l[i].debt).size() <= 1,
      // (C) ENDOGENOUS CUTOFF: the walk stops exactly when the budget is spent,
      //     or when every eligible trove has been exhausted.
      r.remaining == 0 or
        l.indices().forall(j => not(eligible(l[j], price)) or r.rev[j].debt == 0),
      // (D) CONSERVATION: bold burned == debt destroyed.
      amount - r.remaining ==
        l.indices().fold(0, (s, i) => s + l[i].debt - r.rev[i].debt),
    }
  }

  // ---------------------------------------------------------------------------
  // CANONICALITY: the sorted list is a FUNCTION of the unordered trove set.
  // Insert is deterministic and the order is total (rate, then id), so the list
  // carries no information the set does not already carry. This is the whole
  // state-space-cost argument, and it is machine-checkable.
  // ---------------------------------------------------------------------------

  /// insertion-sort the set into the canonical order, independent of the list
  pure def canonical(s: Set[Trove]): List[Trove] =
    s.fold(List(), (l, t) => insertSorted(l, t))

  pure def isCanonical(l: List[Trove]): bool =
    l == canonical(l.indices().map(i => l[i]))
}
