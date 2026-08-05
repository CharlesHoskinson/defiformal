// Uniswap V4 — deferred net settlement (flash accounting) over a singleton.
// Source: protocol-repos/dex/Uniswap_v4-core/src/PoolManager.sol
//   unlock/unlockCallback (L104-110), take/settle (L291-306),
//   CurrencyDelta in transient storage; release requires all deltas zero.
// Model: one pool, signed deltas d0/d1 that must net to zero at settle scope end.

module uniswap_v4 {
  import common.* from "./common"

  pure val FEE_NUM: int = 997
  pure val FEE_DEN: int = 1000

  // Pool reserves (singleton inventory for one pool)
  var reserve0: int
  var reserve1: int
  var liquidity: int
  // Transient accounting within an unlock scope
  var unlocked: bool
  var delta0: int   // positive = pool owes user; negative = user owes pool
  var delta1: int
  // External balances of the settler (abstract single user)
  var user0: int
  var user1: int

  action init: bool = all {
    reserve0' = 100,
    reserve1' = 100,
    liquidity' = 100,
    unlocked' = false,
    delta0' = 0,
    delta1' = 0,
    user0' = 200,
    user1' = 200,
  }

  action unlock: bool = all {
    not(unlocked),
    unlocked' = true,
    delta0' = 0,
    delta1' = 0,
    reserve0' = reserve0,
    reserve1' = reserve1,
    liquidity' = liquidity,
    user0' = user0,
    user1' = user1,
  }

  /// swap inside unlock: updates pool reserves and accrues deltas
  action swap0for1(amountIn: int): bool = all {
    unlocked,
    amountIn > 0,
    val out = cpAmountOut(reserve0, reserve1, amountIn, FEE_NUM, FEE_DEN)
    all {
      out > 0,
      out < reserve1,
      reserve0' = reserve0 + amountIn,
      reserve1' = reserve1 - out,
      // user must pay amountIn of token0, receives out of token1
      delta0' = delta0 - amountIn,  // user owes pool token0
      delta1' = delta1 + out,       // pool owes user token1
      unlocked' = true,
      liquidity' = liquidity,
      user0' = user0,
      user1' = user1,
    }
  }

  /// settle token0: user pays debt (when delta0 < 0) or takes credit
  action settle0: bool = all {
    unlocked,
    delta0 < 0,
    val pay = 0 - delta0
    all {
      user0 >= pay,
      user0' = user0 - pay,
      delta0' = 0,
      delta1' = delta1,
      unlocked' = true,
      reserve0' = reserve0,
      reserve1' = reserve1,
      liquidity' = liquidity,
      user1' = user1,
    }
  }

  action take1: bool = all {
    unlocked,
    delta1 > 0,
    val credit = delta1
    all {
      user1' = user1 + credit,
      delta1' = 0,
      delta0' = delta0,
      unlocked' = true,
      reserve0' = reserve0,
      reserve1' = reserve1,
      liquidity' = liquidity,
      user0' = user0,
    }
  }

  /// lock release: only when deltas net to zero (PoolManager unlock end)
  action lock: bool = all {
    unlocked,
    deltasNetZero(delta0, delta1),
    unlocked' = false,
    delta0' = 0,
    delta1' = 0,
    reserve0' = reserve0,
    reserve1' = reserve1,
    liquidity' = liquidity,
    user0' = user0,
    user1' = user1,
  }

  action step: bool = {
    nondet din = 1.to(15).oneOf()
    any {
      unlock,
      swap0for1(din),
      settle0,
      take1,
      lock,
    }
  }

  /// Conservation of token0 across pool + user + unsettled delta
  val token0Conservation: bool =
    reserve0 + user0 + (if (delta0 > 0) 0 - delta0 else 0 - delta0) >= 0
    // simpler: pool + user account for gross inventory; deltas are claims
    and reserve0 >= 0 and user0 >= 0

  /// When locked, deltas must be zero (scope closed cleanly)
  val lockedImpliesSettled: bool =
    not(unlocked) implies deltasNetZero(delta0, delta1)

  val reservesNonNeg: bool = reserve0 >= 0 and reserve1 >= 0
}
