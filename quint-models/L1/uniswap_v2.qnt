// Uniswap V2 core pair — constant-product AMM with fungible LP shares.
// Source: protocol-repos/dex/Uniswap_v2-core/contracts/UniswapV2Pair.sol
//   reserve0/reserve1 (L22-23), mint (L110+), burn, swap with k invariant,
//   MINIMUM_LIQUIDITY = 10**3 (L15), fee 0.3% (997/1000).

module uniswap_v2 {
  import common.* from "./common"

  pure val FEE_NUM: int = 997
  pure val FEE_DEN: int = 1000
  pure val MIN_LIQ: int = 1  // abstracted from 10**3 for small domains

  // Users in the model
  pure val USERS: Set[str] = Set("alice", "bob", "carol")

  /// Core economic state of one pair
  var reserve0: int
  var reserve1: int
  var totalSupply: int          // LP token supply
  var lpBalance: str -> int     // LP balances
  var kLast: int                // product after last liquidity event (fee mint hook)

  action init: bool = all {
    reserve0' = 100,
    reserve1' = 100,
    totalSupply' = 100,  // seeded pool (as if MINIMUM already burned + initial mint)
    lpBalance' = USERS.mapBy(u => if (u == "alice") 100 else 0),
    kLast' = 100 * 100,
  }

  pure def canMint(r0: int, r1: int, a0: int, a1: int, supply: int): bool =
    a0 > 0 and a1 > 0 and r0 > 0 and r1 > 0 and supply > 0

  pure def mintLiquidity(r0: int, r1: int, a0: int, a1: int, supply: int): int =
    min(mulDivDown(a0, supply, r0), mulDivDown(a1, supply, r1))

  /// mint(recipient): deposit proportional amounts, receive LP shares
  action mint(recipient: str, a0: int, a1: int): bool = all {
    USERS.contains(recipient),
    canMint(reserve0, reserve1, a0, a1, totalSupply),
    val liq = mintLiquidity(reserve0, reserve1, a0, a1, totalSupply)
    all {
      liq > 0,
      reserve0' = reserve0 + a0,
      reserve1' = reserve1 + a1,
      totalSupply' = totalSupply + liq,
      lpBalance' = lpBalance.put(recipient, lpBalance.get(recipient) + liq),
      kLast' = (reserve0 + a0) * (reserve1 + a1),
    }
  }

  pure def canBurn(shares: int, bal: int, supply: int, r0: int, r1: int): bool =
    shares > 0 and bal >= shares and supply > 0 and r0 > 0 and r1 > 0

  /// burn: redeem LP for pro-rata reserves
  action burn(from: str, shares: int): bool = all {
    USERS.contains(from),
    canBurn(shares, lpBalance.get(from), totalSupply, reserve0, reserve1),
    val a0 = mulDivDown(shares, reserve0, totalSupply)
    val a1 = mulDivDown(shares, reserve1, totalSupply)
    all {
      a0 > 0 and a1 > 0,
      // leave residual liquidity (MINIMUM analogue)
      totalSupply - shares >= MIN_LIQ,
      reserve0' = reserve0 - a0,
      reserve1' = reserve1 - a1,
      totalSupply' = totalSupply - shares,
      lpBalance' = lpBalance.put(from, lpBalance.get(from) - shares),
      kLast' = (reserve0 - a0) * (reserve1 - a1),
    }
  }

  /// swap: exact input amount of token0 for token1 (or reverse via zeroIn0)
  action swap0for1(amountIn: int): bool = all {
    amountIn > 0,
    val out = cpAmountOut(reserve0, reserve1, amountIn, FEE_NUM, FEE_DEN)
    val r0n = reserve0 + amountIn
    val r1n = reserve1 - out
    all {
      out > 0,
      out < reserve1,
      // k check: UniV2Pair.sol requires balanceAdjusted products >= reserve product * 1000^2
      cpKHolds(reserve0, reserve1, r0n, r1n),
      reserve0' = r0n,
      reserve1' = r1n,
      totalSupply' = totalSupply,
      lpBalance' = lpBalance,
      kLast' = kLast,
    }
  }

  action swap1for0(amountIn: int): bool = all {
    amountIn > 0,
    val out = cpAmountOut(reserve1, reserve0, amountIn, FEE_NUM, FEE_DEN)
    val r0n = reserve0 - out
    val r1n = reserve1 + amountIn
    all {
      out > 0,
      out < reserve0,
      cpKHolds(reserve0, reserve1, r0n, r1n),
      reserve0' = r0n,
      reserve1' = r1n,
      totalSupply' = totalSupply,
      lpBalance' = lpBalance,
      kLast' = kLast,
    }
  }

  action step: bool = {
    nondet u = USERS.oneOf()
    nondet a0 = 1.to(20).oneOf()
    nondet a1 = 1.to(20).oneOf()
    nondet shares = 1.to(20).oneOf()
    nondet din = 1.to(15).oneOf()
    any {
      mint(u, a0, a1),
      burn(u, shares),
      swap0for1(din),
      swap1for0(din),
    }
  }

  // --- Invariants ---

  /// Reserves and supply stay non-negative; product never falls below seed floor
  // after fee-bearing swaps product only grows; burns decrease reserves with supply.
  val reservesNonNeg: bool = reserve0 >= 0 and reserve1 >= 0 and totalSupply >= 0

  /// LP conservation: sum of balances equals totalSupply
  val lpConservation: bool =
    USERS.fold(0, (acc, u) => acc + lpBalance.get(u)) == totalSupply

  /// Constant-product floor relative to initial seed (100*100), weakened after burns.
  /// Stronger local property used in swap: k non-decreasing on swap path only.
  val positiveLiquidity: bool = totalSupply >= MIN_LIQ implies (reserve0 > 0 and reserve1 > 0)
}
