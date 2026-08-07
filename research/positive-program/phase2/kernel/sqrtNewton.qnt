module sqrtNewton {
  import sqrt.* from "./sqrt"

  /// Newton/Heron with a FIXED unrolling and no convergence guard --
  /// the shape a naive "fixed unrolling" answer would take.
  pure def isqrtNewton(n: int, k: int): int =
    if (n <= 0) 0
    else range(0, k).foldl(n, (x, _) => (x + n / x) / 2)

  /// Newton with the same guard discipline as the Curve D iteration:
  /// carry a `done` flag so a too-shallow unrolling cannot fail silently.
  pure def isqrtNewtonGuarded(n: int, k: int): (int, bool) =
    if (n <= 0) (0, true)
    else range(0, k).foldl((n, false), (st, _) =>
      if (st._2) st
      else { val xn = (st._1 + n / st._1) / 2
             if (xn >= st._1) (st._1, true) else (xn, false) })

  pure def newtonExactAt(n: int, k: int): bool = isqrtNewton(n, k) == isqrt(n)
  pure def guardedExactAt(n: int, k: int): bool = {
    val r = isqrtNewtonGuarded(n, k)
    r._2 and r._1 == isqrt(n)
  }

  /// how many n in 0..N-1 does fixed-depth-k Newton get WRONG
  pure def newtonWrongCount(k: int, hi: int): int =
    0.to(hi).fold(0, (c, n) => if (newtonExactAt(n, k)) c else c + 1)
  pure def guardedWrongCount(k: int, hi: int): int =
    0.to(hi).fold(0, (c, n) => if (guardedExactAt(n, k)) c else c + 1)
  /// worst overshoot of fixed-depth Newton
  pure def newtonMaxErr(k: int, hi: int): int =
    0.to(hi).fold(0, (m, n) => { val d = isqrtNewton(n, k) - isqrt(n)
                                 val a = if (d < 0) 0 - d else d
                                 if (a > m) a else m })
}
