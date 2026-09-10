// Curve StableSwap get_D -- faithful Newton iteration with the real
// termination condition carried, not a fixed-depth approximation.
// Source: curvefi/curve-contract StableSwap3Pool.vy get_D (L195-217),
// specialised to N_COINS = 2.
module curveD {

  pure val N: int = 2

  /// unrolling depth. Chosen from measurement (see report), not guessed.
  pure val MAXITER: int = 8

  type DState = { d: int, dprev: int, done: bool, iters: int }

  /// One Newton step, exactly as the Vyper writes it (same rounding, same order).
  ///   D_P = D*D*D / (x*N * y*N)   -- computed as two sequential floor-divisions
  ///   D   = (Ann*S + D_P*N)*D / ((Ann-1)*D + (N+1)*D_P)
  pure def dStep(x: int, y: int, ann: int, s: int, st: DState): DState =
    if (st.done) st
    else {
      val dp1 = st.d * st.d / (x * N)
      val dp  = dp1  * st.d / (y * N)
      val num = (ann * s + dp * N) * st.d
      val den = (ann - 1) * st.d + (N + 1) * dp
      val dNew = num / den
      { d: dNew, dprev: st.d, iters: st.iters + 1,
        done: if (dNew > st.d) dNew - st.d <= 1 else st.d - dNew <= 1 }
    }

  /// D with the loop unrolled to `maxIter` steps. `done` records whether the
  /// real contract`s break condition fired; `iters` is the real iteration count.
  pure def getDFull(x: int, y: int, amp: int, maxIter: int): DState = {
    val s = x + y
    if (s == 0) { d: 0, dprev: 0, done: true, iters: 0 }
    else if (x <= 0 or y <= 0) { d: 0, dprev: 0, done: true, iters: 0 }
    else {
      val ann = amp * N
      range(0, maxIter).foldl({ d: s, dprev: 0, done: false, iters: 0 },
                              (st, _) => dStep(x, y, ann, s, st))
    }
  }

  /// The value the contract returns. Callers must also assert `.done`.
  pure def getD(x: int, y: int, amp: int): int = getDFull(x, y, amp, MAXITER).d

  /// Proof obligation exported by the unrolling: the loop really did terminate
  /// the way the contract`s `break` would. If this ever fails, the unrolling
  /// depth is too small and the spec is unsound -- it does not fail silently.
  pure def dConverged(x: int, y: int, amp: int): bool = getDFull(x, y, amp, MAXITER).done

  /// The invariant D is meant to solve, as a residual (should be ~0):
  ///   Ann*S*D^(n) ... expressed via the fixed-point form of the iteration:
  ///   D == (Ann*S + D_P*n)*D / ((Ann-1)*D + (n+1)*D_P)
  pure def dResidual(x: int, y: int, amp: int): int = {
    val d = getD(x, y, amp)
    val s = x + y
    val ann = amp * N
    val dp = d * d / (x * N) * d / (y * N)
    val num = (ann * s + dp * N) * d
    val den = (ann - 1) * d + (N + 1) * dp
    val dNext = num / den
    if (dNext > d) dNext - d else d - dNext
  }

  // ---- measurement over the domain the specs actually use ----
  pure val DOM: Set[int] = Set(1, 2, 5, 17, 100, 999, 5000, 12345, 100000, 1000000)
  pure val AMPS: Set[int] = Set(1, 10, 100, 2000)

  pure val maxIters: int =
    DOM.fold(0, (m, x) => DOM.fold(m, (m2, y) => AMPS.fold(m2, (m3, a) => {
      val it = getDFull(x, y, a, 16).iters
      if (it > m3) it else m3 })))

  pure val allConverged: bool =
    DOM.forall(x => DOM.forall(y => AMPS.forall(a => dConverged(x, y, a))))

  pure val maxResidual: int =
    DOM.fold(0, (m, x) => DOM.fold(m, (m2, y) => AMPS.fold(m2, (m3, a) => {
      val r = dResidual(x, y, a)
      if (r > m3) r else m3 })))

  /// Curve`s own bounds: D lies between the geometric-mean-like lower bound and S.
  pure val dSandwich: bool =
    DOM.forall(x => DOM.forall(y => AMPS.forall(a => {
      val d = getD(x, y, a)
      and { d > 0, d <= x + y }
    })))
}


