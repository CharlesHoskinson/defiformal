// CoW Protocol (GPv2) — batch auction settlement of signed orders.
// Sources:
//   cowprotocol_contracts/src/contracts/GPv2Settlement.sol
//     settle (L121) onlySolver; filledAmount (L47)
//     computeTradeExecution updates filledAmount (L337-421)
//     invalidateOrder sets filledAmount to max (L250)
// Scope: two tokens, uniform clearing prices, partial fills, solver-gated.
// NOT covered: EIP-712 recovery, pre-signatures, vault internal balances,
// free-form interactions, fee token surplus, allowlist authenticator dynamics.

module cow {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val ORDER_IDS: Set[int] = Set(0, 1, 2)
  pure val AMOUNTS: Set[int] = Set(1, 2, 3, 5)
  pure val PRICES: Set[int] = Set(1, 2, 3)

  var bal0: int -> int
  var bal1: int -> int
  var orders: int -> SignedOrder
  var nextOrderId: int
  var feeSurplus0: int
  var feeSurplus1: int

  pure def emptyO: SignedOrder = emptyOrder(0, 0, 0)

  action init: bool = all {
    bal0' = USERS.mapBy(u => if (u == 1) 20 else if (u == 2) 5 else 5),
    bal1' = USERS.mapBy(u => if (u == 1) 5 else if (u == 2) 20 else 5),
    orders' = ORDER_IDS.mapBy(_ => emptyO),
    nextOrderId' = 0,
    feeSurplus0' = 0,
    feeSurplus1' = 0,
  }

  /// Off-chain signed sell order (token0 for token1).
  action placeSellOrder(maker: int, sellAmt: int, buyAmt: int): bool = all {
    USERS.contains(maker),
    AMOUNTS.contains(sellAmt),
    AMOUNTS.contains(buyAmt),
    nextOrderId < 3,
    bal0.get(maker) >= sellAmt,
    orders' = orders.put(nextOrderId, emptyOrder(maker, sellAmt, buyAmt)),
    nextOrderId' = nextOrderId + 1,
    bal0' = bal0,
    bal1' = bal1,
    feeSurplus0' = feeSurplus0,
    feeSurplus1' = feeSurplus1,
  }

  /// settle one trade at clearing prices.
  action settleTrade(
    id: int, fillMaking: int, price0: int, price1: int, fee: int
  ): bool = all {
    ORDER_IDS.contains(id),
    id < nextOrderId,
    AMOUNTS.contains(fillMaking),
    PRICES.contains(price0),
    PRICES.contains(price1),
    fee >= 0 and fee < fillMaking,
    val o = orders.get(id)
    all {
      canFillOrder(o, fillMaking),
      clearsAtLimit(fillMaking, takingForFill(o, fillMaking), price0, price1),
      val take = takingForFill(o, fillMaking)
      val maker = o.maker
      all {
        bal0.get(maker) >= fillMaking,
        val others1 = USERS.fold(0, (acc, u) =>
          if (u != maker) acc + bal1.get(u) else acc)
        others1 >= take,
        val src = if (maker != 2 and bal1.get(2) >= take) 2 else 3
        all {
          bal1.get(src) >= take,
          // Maker sells token0 (minus fee skim) to counterparty; buys token1 from them.
          bal0' = bal0
            .put(maker, bal0.get(maker) - fillMaking)
            .put(src, bal0.get(src) + (fillMaking - fee)),
          bal1' = bal1.put(src, bal1.get(src) - take).put(maker, bal1.get(maker) + take),
          orders' = orders.put(id, applyFillOrder(o, fillMaking)),
          feeSurplus0' = feeSurplus0 + fee,
          feeSurplus1' = feeSurplus1,
          nextOrderId' = nextOrderId,
        }
      }
    }
  }

  /// invalidateOrder — owner sets remaining to 0.
  action invalidate(id: int): bool = all {
    ORDER_IDS.contains(id),
    id < nextOrderId,
    val o = orders.get(id)
    all {
      not(o.cancelled) and o.remaining > 0,
      orders' = orders.put(id, applyCancelOrder(o)),
      bal0' = bal0,
      bal1' = bal1,
      nextOrderId' = nextOrderId,
      feeSurplus0' = feeSurplus0,
      feeSurplus1' = feeSurplus1,
    }
  }

  action step: bool = any {
    nondet m = USERS.oneOf()
    nondet s = AMOUNTS.oneOf()
    nondet b = AMOUNTS.oneOf()
    placeSellOrder(m, s, b),
    nondet id = ORDER_IDS.oneOf()
    nondet fm = AMOUNTS.oneOf()
    nondet p0 = PRICES.oneOf()
    nondet p1 = PRICES.oneOf()
    settleTrade(id, fm, p0, p1, 0),
    nondet id2 = ORDER_IDS.oneOf()
    invalidate(id2),
  }

  val remainingOk: bool =
    ORDER_IDS.forall(id => remainingBounded(orders.get(id)))

  val token0Conserved: bool =
    USERS.fold(0, (acc, u) => acc + bal0.get(u)) + feeSurplus0 == 30

  val token1Conserved: bool =
    USERS.fold(0, (acc, u) => acc + bal1.get(u)) + feeSurplus1 == 30
}
