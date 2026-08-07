// The EXISTING style, for comparison: redeem takes the trove as a parameter.
// Same protocol, same domains; only the selection mechanism differs.
module liq_nondet {
  import sorted.* from "./sorted"

  pure val IDS: Set[int] = Set(1, 2, 3)
  pure val RATES: Set[int] = Set(5, 10, 20)
  pure val AMTS: Set[int] = Set(30, 90, 150)

  var troves: int -> Trove
  var freeBold: int
  var boldSupply: int
  var totalColl: int
  var price: int

  action init = all {
    troves' = Map(), freeBold' = 300, boldSupply' = 0,
    totalColl' = 0, price' = WAD,
  }

  action openTrove(id: int, rate: int): bool = all {
    IDS.contains(id), not(troves.keys().contains(id)),
    troves' = troves.put(id, { id: id, rate: rate, debt: 100, coll: 200, active: true }),
    boldSupply' = boldSupply + 100, totalColl' = totalColl + 200,
    freeBold' = freeBold + 100, price' = price,
  }

  action adjustRate(id: int, rate: int): bool = all {
    troves.keys().contains(id),
    troves.get(id).rate != rate,
    troves' = troves.set(id, { ...troves.get(id), rate: rate }),
    boldSupply' = boldSupply, totalColl' = totalColl,
    freeBold' = freeBold, price' = price,
  }

  /// redeem FROM A GIVEN TROVE -- the deleted-ordering form
  action redeem(u: int, amount: int): bool = all {
    troves.keys().contains(u),
    troves.get(u).active,
    amount > 0, amount <= troves.get(u).debt, freeBold >= amount,
    val t = troves.get(u)
    val coll = amount * WAD / price
    all {
      coll <= t.coll,
      troves' = troves.set(u, { ...t, debt: t.debt - amount, coll: t.coll - coll,
                                 active: t.debt - amount > 0 }),
      freeBold' = freeBold - amount, boldSupply' = boldSupply - amount,
      totalColl' = totalColl - coll, price' = price,
    }
  }

  action step = any {
    nondet id = IDS.oneOf()
    nondet rt = RATES.oneOf()
    openTrove(id, rt),
    nondet id = IDS.oneOf()
    nondet rt = RATES.oneOf()
    adjustRate(id, rt),
    nondet u = IDS.oneOf()
    nondet a = AMTS.oneOf()
    redeem(u, a),
  }

  val supplyInv: bool = boldSupply == troves.keys().fold(0, (s, k) => s + troves.get(k).debt)

  /// THE REGRESSION GUARD, applied to the abstract spec: does redemption always
  /// hit the lowest-rate trove? A violation means the ordering is not modelled.
  /// (Negated so `quint run` reports the counterexample.)
  val redemptionHitsLowestRate: bool = {
    val l = canonical(troves.keys().map(k => troves.get(k)))
    l.length() < 2 or
      l.indices().forall(i => i == l.length() - 1 or l[i].debt == 100 or l[i + 1].debt == 0)
  }
}
