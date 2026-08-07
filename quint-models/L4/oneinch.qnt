// 1inch Limit Order Protocol — taker-fills signed maker orders.
// Sources:
//   1inch_limit-order-protocol/contracts/OrderMixin.sol
//     fillOrder (L129), cancelOrder (L80)
//     remainingInvalidator / bitInvalidator (L50-57)
// Scope: remaining-based partial fills, single pair, maker sells A for B.
// NOT covered: predicates, extensions, Dutch auction, Permit2, interactions.

module oneinch {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val ORDER_IDS: Set[int] = Set(0, 1, 2)
  pure val AMOUNTS: Set[int] = Set(1, 2, 3, 5)

  var balA: int -> int
  var balB: int -> int
  var orders: int -> SignedOrder
  var nextOrderId: int

  pure def emptyO: SignedOrder = emptyOrder(0, 0, 0)

  action init: bool = all {
    balA' = USERS.mapBy(u => if (u == 1) 20 else if (u == 2) 5 else 5),
    balB' = USERS.mapBy(u => if (u == 1) 5 else if (u == 2) 20 else 5),
    orders' = ORDER_IDS.mapBy(_ => emptyO),
    nextOrderId' = 0,
  }

  action createOrder(maker: int, making: int, taking: int): bool = all {
    USERS.contains(maker),
    AMOUNTS.contains(making),
    AMOUNTS.contains(taking),
    nextOrderId < 3,
    balA.get(maker) >= making,
    orders' = orders.put(nextOrderId, emptyOrder(maker, making, taking)),
    nextOrderId' = nextOrderId + 1,
    balA' = balA,
    balB' = balB,
  }

  action fillOrder(id: int, taker: int, fillMaking: int): bool = all {
    ORDER_IDS.contains(id),
    USERS.contains(taker),
    AMOUNTS.contains(fillMaking),
    id < nextOrderId,
    val o = orders.get(id)
    all {
      canFillOrder(o, fillMaking),
      taker != o.maker,
      val take = takingForFill(o, fillMaking)
      all {
        balA.get(o.maker) >= fillMaking,
        balB.get(taker) >= take,
        balA' = balA
          .put(o.maker, balA.get(o.maker) - fillMaking)
          .put(taker, balA.get(taker) + fillMaking),
        balB' = balB
          .put(taker, balB.get(taker) - take)
          .put(o.maker, balB.get(o.maker) + take),
        orders' = orders.put(id, applyFillOrder(o, fillMaking)),
        nextOrderId' = nextOrderId,
      }
    }
  }

  action cancelOrder(id: int): bool = all {
    ORDER_IDS.contains(id),
    id < nextOrderId,
    val o = orders.get(id)
    all {
      not(o.cancelled) and o.remaining > 0,
      orders' = orders.put(id, applyCancelOrder(o)),
      balA' = balA,
      balB' = balB,
      nextOrderId' = nextOrderId,
    }
  }

  action step: bool = any {
    nondet m = USERS.oneOf()
    nondet mk = AMOUNTS.oneOf()
    nondet tk = AMOUNTS.oneOf()
    createOrder(m, mk, tk),
    nondet id = ORDER_IDS.oneOf()
    nondet t = USERS.oneOf()
    nondet fm = AMOUNTS.oneOf()
    fillOrder(id, t, fm),
    nondet id2 = ORDER_IDS.oneOf()
    cancelOrder(id2),
  }

  val remainingOk: bool =
    ORDER_IDS.forall(id => remainingBounded(orders.get(id)))

  val tokenAConserved: bool =
    USERS.fold(0, (acc, u) => acc + balA.get(u)) == 30

  val tokenBConserved: bool =
    USERS.fold(0, (acc, u) => acc + balB.get(u)) == 30
}
