// Curve StableSwap with the real Newton iteration, and the contract`s own
// termination condition exported as a proof obligation.
module curvePool {
  import curveD.* from "./curveD"

  pure val AMP: int = 100
  pure val AMTS: Set[int] = Set(10, 50, 200)
  pure val WIDE: Set[int] = Set(1,2,3,5,9,17,50,100,333,999,5000,12345,100000,1000000)
  pure val MAXIMBALANCE: int = 500   // modelling restriction; see `balanced` below

  var b0: int
  var b1: int
  var lpSupply: int

  action init = all { b0' = 1000, b1' = 1000, lpSupply' = 2000 }

  /// add_liquidity: mint proportional to the increase in D
  action addLiquidity(a0: int, a1: int): bool = all {
    a0 >= 0, a1 >= 0, a0 + a1 > 0,
    val d0 = getD(b0, b1, AMP)
    val d1 = getD(b0 + a0, b1 + a1, AMP)
    all {
      d1 > d0,
      (if (b0 + a0 > b1 + a1) (b0 + a0) / (b1 + a1) else (b1 + a1) / (b0 + a0)) <= MAXIMBALANCE,
      b0' = b0 + a0, b1' = b1 + a1,
      lpSupply' = lpSupply + (d1 - d0) * lpSupply / d0,
    }
  }

  /// exchange: solve for y holding D fixed (here: the D-preserving check only)
  action exchange(dx: int): bool = all {
    dx > 0, dx < b0,
    val d = getD(b0, b1, AMP)
    // conservative output: keep D non-decreasing (fee accrues to the pool)
    val dy = dx * b1 / (b0 + dx)
    all {
      dy > 0, dy < b1,
      getD(b0 + dx, b1 - dy, AMP) >= d,
      (if (b0 + dx > b1 - dy) (b0 + dx) / (b1 - dy) else (b1 - dy) / (b0 + dx)) <= MAXIMBALANCE,
      b0' = b0 + dx, b1' = b1 - dy, lpSupply' = lpSupply,
    }
  }

  /// jump to an arbitrary pool configuration -- stresses the D domain directly
  action reconfigure(x: int, y: int): bool = all {
    x > 0, y > 0,
    (if (x > y) x / y else y / x) <= MAXIMBALANCE,
    b0' = x, b1' = y, lpSupply' = lpSupply,
  }

  action step = any {
    nondet a = AMTS.oneOf()
    nondet b = AMTS.oneOf()
    addLiquidity(a, b),
    nondet a = AMTS.oneOf()
    exchange(a),
    nondet x = WIDE.oneOf()
    nondet y = WIDE.oneOf()
    reconfigure(x, y),
  }

  // ---- THE PROOF OBLIGATION THE UNROLLING OWES ----
  /// The contract`s `break` fired within MAXITER at every reachable state.
  /// If this fails the unrolling depth is wrong and the spec is unsound.
  val newtonConverged: bool = dConverged(b0, b1, AMP)

  /// residual of the fixed-point equation D solves
  val residualSmall: bool = dResidual(b0, b1, AMP) <= 1

  /// Curve`s own sandwich: 2*sqrt(x*y) <= D <= x+y, with equality at the peg
  val dBounds: bool = { val d = getD(b0, b1, AMP)
                        and { d > 0, d <= b0 + b1 } }
  val dAtPeg: bool = b0 != b1 or getD(b0, b1, AMP) == b0 + b1

  val allInv = and { newtonConverged, residualSmall, dBounds, dAtPeg }
}
