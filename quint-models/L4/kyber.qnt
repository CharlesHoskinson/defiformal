// KyberSwap Smart Intent — delegated intent with guardian-gated execution.
// Sources:
//   KyberNetwork_smart-intent-sc/src/KSSmartIntentRouter.sol
//     execute (L98), executeWithSignedIntent (L110)
//     _delegate (L140): NOT_DELEGATED → DELEGATED
//     _execute (L160): require DELEGATED, unordered nonce, call action
// Scope: one-shot intent lifecycle; token pull on delegate; pause.
// NOT covered: multi-action selectors, hook fee splits, merkle conditions.

module kyber {
  import common.* from "./common"

  pure val USERS: Set[int] = Set(1, 2, 3)
  pure val INTENT_IDS: Set[int] = Set(0, 1, 2)
  pure val AMOUNTS: Set[int] = Set(1, 2, 3, 5)

  type Intent = {
    owner: int,
    amountIn: int,
    minOut: int,
    status: IntentStatus,
  }

  pure def emptyIntent: Intent =
    { owner: 0, amountIn: 0, minOut: 0, status: Revoked }

  var balA: int -> int
  var balB: int -> int
  var intents: int -> Intent
  var nextId: int
  var paused: bool
  var routerA: int

  action init: bool = all {
    balA' = USERS.mapBy(u => if (u == 1) 15 else if (u == 2) 10 else 5),
    balB' = USERS.mapBy(u => if (u == 1) 5 else if (u == 2) 10 else 15),
    intents' = INTENT_IDS.mapBy(_ => emptyIntent),
    nextId' = 0,
    paused' = false,
    routerA' = 0,
  }

  action delegate(owner: int, amountIn: int, minOut: int): bool = all {
    not(paused),
    USERS.contains(owner),
    AMOUNTS.contains(amountIn),
    AMOUNTS.contains(minOut),
    minOut > 0 and minOut <= amountIn * 2,
    nextId < 3,
    balA.get(owner) >= amountIn,
    canDelegate(NotDelegated),
    balA' = balA.put(owner, balA.get(owner) - amountIn),
    routerA' = routerA + amountIn,
    intents' = intents.put(nextId, {
      owner: owner, amountIn: amountIn, minOut: minOut, status: Delegated
    }),
    nextId' = nextId + 1,
    balB' = balB,
    paused' = paused,
  }

  action execute(id: int, amountOut: int): bool = all {
    not(paused),
    INTENT_IDS.contains(id),
    id < nextId,
    AMOUNTS.contains(amountOut),
    val it = intents.get(id)
    all {
      canExecute(it.status),
      amountOut >= it.minOut,
      routerA >= it.amountIn,
      val liq = if (it.owner != 3) 3 else 2
      all {
        balB.get(liq) >= amountOut,
        routerA' = routerA - it.amountIn,
        balB' = balB
          .put(liq, balB.get(liq) - amountOut)
          .put(it.owner, balB.get(it.owner) + amountOut),
        balA' = balA.put(liq, balA.get(liq) + it.amountIn),
        intents' = intents.put(id, { ...it, status: applyExecute(it.status) }),
        nextId' = nextId,
        paused' = paused,
      }
    }
  }

  action revoke(id: int): bool = all {
    INTENT_IDS.contains(id),
    id < nextId,
    val it = intents.get(id)
    all {
      canRevoke(it.status),
      val refund = if (it.status == Delegated) it.amountIn else 0
      all {
        routerA' = routerA - refund,
        balA' = balA.put(it.owner, balA.get(it.owner) + refund),
        intents' = intents.put(id, { ...it, status: applyRevoke(it.status) }),
        balB' = balB,
        nextId' = nextId,
        paused' = paused,
      }
    }
  }

  action setPaused(p: bool): bool = all {
    paused' = p,
    balA' = balA,
    balB' = balB,
    intents' = intents,
    nextId' = nextId,
    routerA' = routerA,
  }

  action step: bool = any {
    nondet o = USERS.oneOf()
    nondet ai = AMOUNTS.oneOf()
    nondet mo = AMOUNTS.oneOf()
    delegate(o, ai, mo),
    nondet id = INTENT_IDS.oneOf()
    nondet ao = AMOUNTS.oneOf()
    execute(id, ao),
    nondet id2 = INTENT_IDS.oneOf()
    revoke(id2),
    setPaused(true),
    setPaused(false),
  }

  val routerMatchesDelegated: bool = {
    val delegated = INTENT_IDS.fold(0, (acc, id) => {
      val it = intents.get(id)
      if (it.status == Delegated) acc + it.amountIn else acc
    })
    routerA == delegated
  }

  val tokenAConserved: bool =
    USERS.fold(0, (acc, u) => acc + balA.get(u)) + routerA == 30
}
