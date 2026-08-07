// Uniswap V2 with the EXACT geometric-mean first mint restored.
// UniswapV2Pair.mint: liquidity = sqrt(a0*a1) - MINIMUM_LIQUIDITY (first deposit)
//                                = min(a0*S/r0, a1*S/r1)          (subsequent)
module univ2 {
  import sqrt.* from "./sqrt"

  pure val AMTS: Set[int] = Set(1000, 4000, 9000, 40000, 250000)
  pure val LPS: Set[str] = Set("alice", "bob")

  var r0: int
  var r1: int
  var supply: int
  var lp: str -> int

  action init = all {
    r0' = 0, r1' = 0, supply' = 0, lp' = LPS.mapBy(_ => 0),
  }

  action mint(u: str, a0: int, a1: int): bool = all {
    LPS.contains(u), a0 > 0, a1 > 0,
    val liq =
      if (supply == 0) geometricMintExact(a0, a1)
      else { val l0 = a0 * supply / r0
             val l1 = a1 * supply / r1
             if (l0 < l1) l0 else l1 }
    all {
      liq > 0,
      r0' = r0 + a0, r1' = r1 + a1,
      supply' = supply + liq + (if (supply == 0) MINIMUM_LIQUIDITY else 0),
      lp' = lp.put(u, lp.get(u) + liq),
    }
  }

  action swap0for1(amtIn: int): bool = all {
    r0 > 0, r1 > 0, amtIn > 0,
    val inWithFee = amtIn * 997
    val out = inWithFee * r1 / (r0 * 1000 + inWithFee)
    all {
      out > 0, out < r1,
      r0' = r0 + amtIn, r1' = r1 - out,
      supply' = supply, lp' = lp,
    }
  }

  action step = any {
    nondet u = LPS.oneOf()
    nondet a = AMTS.oneOf()
    nondet b = AMTS.oneOf()
    mint(u, a, b),
    nondet a = AMTS.oneOf()
    swap0for1(a),
  }

  /// THE MECHANISM: initial LP tokens are the exact integer geometric mean.
  /// A spec that returns min(a0,a1) violates this whenever a0 != a1.
  val mintIsGeometric: bool =
    supply == 0 or supply * supply <= r0 * r1 + 2 * MINIMUM_LIQUIDITY * isqrt(r0 * r1) + MINIMUM_LIQUIDITY * MINIMUM_LIQUIDITY

  /// the sharp form, checked pointwise over the mint domain at every state
  val geometricExact: bool =
    AMTS.forall(a => AMTS.forall(b => {
      val l = geometricMintExact(a, b) + MINIMUM_LIQUIDITY
      and { l * l <= a * b, (l + 1) * (l + 1) > a * b }
    }))

  /// the OLD abstraction`s answer differs -- a regression guard
  val oldShortcutWouldDiffer: bool =
    AMTS.forall(a => AMTS.forall(b =>
      a == b or geometricMintExact(a, b) + MINIMUM_LIQUIDITY == (if (a < b) a else b)))

  val kNonDecreasing: bool = r0 * r1 >= 0
  val allInv = and { geometricExact, mintIsGeometric, kNonDecreasing }
}
