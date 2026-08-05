// Liquity v2 with the ORDERING PRESERVED: redemption target is a function of
// state (lowest interest rate first), not a nondet parameter.
module liq_sorted {
  import sorted.* from "./sorted"

  pure val IDS: Set[int] = Set(1, 2, 3)
  pure val RATES: Set[int] = Set(5, 10, 20)
  pure val AMTS: Set[int] = Set(30, 90, 150)

  var troves: List[Trove]
  var freeBold: int
  var boldSupply: int
  var totalColl: int
  var price: int
  var lastTouched: int

  action init = all {
    troves' = List(),
    freeBold' = 300,
    boldSupply' = 0,
    totalColl' = 0,
    price' = WAD,
    lastTouched' = 0,
  }

  action openTrove(id: int, rate: int): bool = all {
    IDS.contains(id),
    troves.select(t => t.id == id).length() == 0,
    val t = { id: id, rate: rate, debt: 100, coll: 200, active: true }
    all {
      troves' = insertSorted(troves, t),
      boldSupply' = boldSupply + 100,
      totalColl' = totalColl + 200,
      freeBold' = freeBold + 100,
      price' = price,
      lastTouched' = lastTouched,
    }
  }

  /// SortedTroves.reInsert -- rate change moves the trove in the order
  action adjustRate(id: int, rate: int): bool = all {
    troves.select(t => t.id == id).length() == 1,
    val t = troves.select(t => t.id == id).head()
    all {
      t.rate != rate,
      troves' = reInsert(troves, { ...t, rate: rate }),
      boldSupply' = boldSupply, totalColl' = totalColl,
      freeBold' = freeBold, price' = price, lastTouched' = lastTouched,
    }
  }

  /// redeemCollateral -- NO trove parameter. The walk selects.
  action redeem(amount: int): bool = all {
    troves.length() > 0,
    freeBold >= amount,
    val r = redeemFrom(troves, amount, price)
    all {
      r.touched > 0,
      troves' = r.rev,
      freeBold' = freeBold - (amount - r.remaining),
      boldSupply' = boldSupply - (amount - r.remaining),
      totalColl' = totalColl - r.collOut,
      price' = price,
      lastTouched' = r.touched,
    }
  }

  action step = any {
    nondet id = IDS.oneOf()
    nondet rt = RATES.oneOf()
    openTrove(id, rt),
    nondet id = IDS.oneOf()
    nondet rt = RATES.oneOf()
    adjustRate(id, rt),
    nondet a = AMTS.oneOf()
    redeem(a),
  }

  // ---- invariants ----
  val sortedInv: bool = isSorted(troves)
  val extremalAgrees: bool =
    troves.length() == 0 or getLast(troves).id == minByRate(troves).id
  val supplyInv: bool =
    boldSupply == troves.foldl(0, (s, t) => s + t.debt)
  val collInv: bool =
    totalColl >= troves.foldl(0, (s, t) => s + t.coll)
  val noNegative: bool = troves.indices().forall(i => troves[i].debt >= 0 and troves[i].coll >= 0)

  /// THE MECHANISM CHECK, at every reachable state, over the whole amount domain.
  val redeemExtremal: bool =
    AMTS.forall(a => redeemIsExtremal(troves, a, price))

  /// Witness that the mechanism is EXERCISED, not merely satisfied vacuously:
  /// some reachable state admits a redemption that drains one trove and
  /// partially redeems the next one up the order.
  val multiTroveRedeemReachable: bool =
    not(AMTS.exists(a => redeemFrom(troves, a, price).touched >= 2))

  /// ZERO EXTRA STATE: the list equals the canonical sort of its own element
  /// set at every reachable state, so |List states| == |Set states|.
  val listIsCanonical: bool = isCanonical(troves)

  /// the same regression guard, applied to the FAITHFUL spec
  val redemptionHitsLowestRate: bool =
    troves.length() < 2 or
      troves.indices().forall(i =>
        i == troves.length() - 1 or troves[i].debt == 100 or troves[i + 1].debt == 0)

  val allInv = and { sortedInv, extremalAgrees, supplyInv, collInv, noNegative,
                     redeemExtremal, listIsCanonical }
}
