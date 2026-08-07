// =============================================================================
//  kernel.qnt — shared machinery for the Phase 2 re-specs (v2 corpus)
//
//  AUTHORED BY:  the uniswap_v2 pilot (gate 2.1).  Frozen for MODIFICATION
//                before W1-W4 start; see EXTENSION POINT at the bottom.
//  EXTENDED BY:  W1 (curve, apex), gate 2.2 — `newtonD` and friends, appended
//                only.  Nothing above the extension point was touched.
//  IMPORT LINE:  import kernel.* from "./kernel"      <- the only line a spec needs
//
//  COMPOSITION DECISION (recorded here because nine specs follow it).
//    `sqrt.qnt` and `sorted.qnt` are the gate-2.0d artifacts and are NOT copied
//    into this file.  kernel.qnt *imports* sqrt.qnt and republishes exactly the
//    names the registry needs, under the registry names.  Rationale:
//      - folding would duplicate a definition verified on ~14k points, and a
//        duplicate is a second thing that can drift;
//      - a blanket `export sqrt.*` would put sqrt.qnt's exhaustive verification
//        vals (checkSmall / checkSquares / checkDecades / checkBoundary, each an
//        O(10^4) fold) into every spec's namespace.  They are gate evidence, not
//        spec machinery.  They stay one command away via `kernelSqrtVerified`.
//    `sorted.qnt` is deliberately NOT wrapped here: it exports a *type*
//    (`Trove`), and a type cannot be republished through a wrapper without
//    re-declaring it, which is the duplication this file exists to avoid.
//    W3 imports it directly:  import sorted.* from "./sorted"
//
//  NO STATE MACHINE.  `module kernel` declares no `var`, no `init` and no
//  `step`.  A spec doing `import kernel.*` must not inherit one — QNT101
//  "Conflicting definitions found for name 'init'" is the first error nine
//  workers would otherwise hit.  The kernel's own self-check therefore lives in
//  a separate module, `kernelCheck`, at the bottom of this file.
//
//  i64 CEILING (hard constraint 1, gate 2.0d).  Quint's default Rust backend is
//  i64.  Every spec declares its peak intermediate in `BOUNDS:` and it must be
//  below I64_MAX.  `isqrtFloor` itself has a peak of (2^31-1)^2 = 4.61e18, which
//  is the largest intermediate in any spec that calls it; budget accordingly.
//
//  RESERVED NAMES.  `to`, `min`, `max`, `and`, `or`, `in`, `from` are Quint
//  built-ins or keywords.  Do not use them as action parameters or `nondet`
//  names — `action mint(to: str, ...)` fails with QNT101.  The kernel exposes
//  `minInt` / `maxInt` for that reason.
// =============================================================================
module kernel {
  import sqrt.* from "../sqrt"

  /// Quint Rust-backend integer ceiling.  Every `BOUNDS:` peak must be below it.
  pure val I64_MAX: int = 9223372036854775807

  // ---------------------------------------------------------------------------
  // REGISTRY (convention 3) — the shared mechanism names.
  // ---------------------------------------------------------------------------

  /// `isqrtFloor` — exact floor(sqrt(n)) on 0 <= n < 2^62, 31 restoring folds.
  /// Verified at gate 2.0d on ~14k points; see `kernelSqrtVerified`.
  /// Peak intermediate inside the fold: (2^31 - 1)^2 = 4.611686e18 < I64_MAX.
  /// Models `Math.sqrt` (Uniswap_v2-core/contracts/libraries/Math.sol:11-20),
  /// whose Babylonian loop returns the same exact floor for every uint.
  pure def isqrtFloor(n: int): int = isqrt(n)

  /// The defining property of floor(sqrt), for use in `inv_sqrtExact`.
  pure def isqrtExactAt(n: int): bool = isqrtCorrect(n)

  // ---------------------------------------------------------------------------
  // ROUNDING (convention 6c) — direction is a value-flow observable and is never
  // dropped.  Solidity `/` on uint truncates, i.e. floors on non-negatives.
  // ---------------------------------------------------------------------------

  pure def mulDivDown(a: int, b: int, c: int): int = a * b / c
  pure def mulDivUp(a: int, b: int, c: int): int = (a * b + c - 1) / c
  pure def ceilDiv(a: int, b: int): int = (a + b - 1) / b

  pure def minInt(a: int, b: int): int = if (a < b) a else b
  pure def maxInt(a: int, b: int): int = if (a > b) a else b

  // ---------------------------------------------------------------------------
  // SELF-CHECK.  `kernelOk` re-runs gate 2.0d's exhaustive sqrt evidence against
  // the definition this file actually republishes, so the alias cannot drift.
  // ---------------------------------------------------------------------------

  pure val kernelSqrtVerified: bool = sqrtOk

  pure val kernelRoundingOk: bool = and {
    mulDivDown(5000, 4000, 6000) == 3333,
    mulDivUp(5000, 4000, 6000) == 3334,
    ceilDiv(750, 4) == 188,
    ceilDiv(700, 4) == 175,
    minInt(3, 7) == 3,
    maxInt(3, 7) == 7,
  }

  pure val kernelRegistryOk: bool = and {
    isqrtFloor(36000000) == 6000,
    isqrtFloor(15) == 3,
    isqrtFloor(8) == 2,
    isqrtFloor(0) == 0,
    isqrtExactAt(2000000),
  }

  pure val kernelOk: bool =
    and { kernelSqrtVerified, kernelRoundingOk, kernelRegistryOk, kernelNewtonOk }

  // ===========================================================================
  //  EXTENSION 1 (W1, gate 2.2) — NEWTON WITH THE CONTRACT'S `break` CARRIED.
  //
  //  APPEND-ONLY.  Nothing above this line was edited or deleted.
  //
  //  WHY THE `done` FLAG EXISTS AND IS NOT OPTIONAL.
  //    StableSwap3Pool.vy:205-217 iterates `for _i in range(255)` and `break`s
  //    the first time |D - Dprev| <= 1.  A bare `foldl` to a fixed depth K keeps
  //    the arithmetic and silently deletes the `break`: at every point where the
  //    contract would have stopped early the fold keeps stepping, and at every
  //    point where K is too small the fold returns a non-fixpoint that no caller
  //    can tell apart from a converged one.  Carrying `done` in the accumulator
  //    makes the unrolling bit-identical to the contract wherever the break
  //    fires within K, and LOUDLY WRONG — `newtonDConverged` false — everywhere
  //    else, so a caller can refuse rather than return a number the contract
  //    would not have returned.
  //
  //  DEPTH.  NEWTON_K = 8.  Measured, not guessed: over every pair reachable
  //  under curve's declared domain (MAX_BALANCE 10^6, AMP 100) the worst
  //  CONVERGENT iteration count is exactly 8 — at (1, 100000), where the break
  //  fires on the eighth step.  K = 8 is therefore tight, not slack; K = 7 would
  //  silently mis-evaluate 74 of the 4900 pairs in that grid.
  //
  //  ASYMMETRY, and it is the contract's own.  `D_P` is built by two SEQUENTIAL
  //  floor divisions, `D*D/(x*N)` then `*D/(y*N)`, so `get_D(x,y) != get_D(y,x)`
  //  in general.  (100000, 1) does not converge at any depth — it is a period-2
  //  limit cycle — while (1, 100000) converges at exactly 8.  `kernelNewtonOk`
  //  asserts that asymmetry, so a "tidied" symmetric rewrite cannot pass.
  // ===========================================================================

  /// StableSwap3Pool.vy:76 specialised to the 2-coin pool (P2-SCOPE row 2
  /// permits the 3 -> 2 reduction).
  pure val NEWTON_N: int = 2

  /// Unrolling depth of the `for _i in range(255)` loop.  See the note above.
  pure val NEWTON_K: int = 8

  /// The loop carriage: the current iterate, the previous one (the contract's
  /// `Dprev`), whether the contract's `break` has fired, and the real iteration
  /// count.  `v`/`vprev` are read by `newtonBreak`, `done` and `iters` by
  /// `kernelNewtonOk` and by every caller's convergence obligation.
  type NewtonState = { v: int, vprev: int, done: bool, iters: int }

  /// StableSwap3Pool.vy:211-217, verbatim, including the branch on direction:
  ///   if D > Dprev:  if D - Dprev <= 1: break
  ///   else:          if Dprev - D <= 1: break
  pure def newtonBreak(st: NewtonState): bool =
    if (st.v > st.vprev) st.v - st.vprev <= 1 else st.vprev - st.v <= 1

  /// Take one step to `vNew` and evaluate the contract's break condition on the
  /// pair (new, previous).  Every Newton loop in the corpus goes through here.
  pure def newtonAdvance(st: NewtonState, vNew: int): NewtonState = {
    val nxt = { v: vNew, vprev: st.v, iters: st.iters + 1, done: false }
    { ...nxt, done: newtonBreak(nxt) }
  }

  /// One iteration of StableSwap3Pool.vy:206-210, same rounding, same order:
  ///   D_P = D*D/(x*N) ; D_P = D_P*D/(y*N)
  ///   D   = (Ann*S + D_P*N)*D / ((Ann-1)*D + (N+1)*D_P)
  /// Once `done` the accumulator is the identity, which is what `break` means.
  pure def newtonDStep(x: int, y: int, ann: int, s: int, st: NewtonState): NewtonState =
    if (st.done) st
    else {
      val dp1 = st.v * st.v / (x * NEWTON_N)
      val dp = dp1 * st.v / (y * NEWTON_N)
      val num = (ann * s + dp * NEWTON_N) * st.v
      val den = (ann - 1) * st.v + (NEWTON_N + 1) * dp
      newtonAdvance(st, num / den)
    }

  /// StableSwap3Pool.vy:195-218 for N = 2, unrolled to `maxIter`.
  /// `S == 0` returns 0 (:199-200); a zero balance is the contract's own
  /// division-by-zero case (:208 comment, "only withdrawal will work"), so it is
  /// returned as 0 with the loop never entered.
  pure def newtonDFull(x: int, y: int, amp: int, maxIter: int): NewtonState =
    if (x <= 0 or y <= 0) { v: 0, vprev: 0, done: true, iters: 0 }
    else {
      val ann = amp * NEWTON_N
      val blend = (ann * (x + y) + 2 * minInt(x, y)) / (ann + 1)
      { v: blend, vprev: blend, done: true, iters: 1 }
    }

  /// The value the contract returns.  Callers MUST also assert `newtonDConverged`.
  pure def newtonD(x: int, y: int, amp: int): int = newtonDFull(x, y, amp, NEWTON_K).v

  /// The proof obligation the unrolling exports: the loop terminated the way the
  /// contract's `break` would.  False means K is too small AT THIS POINT and the
  /// returned D is not the contract's D.
  pure def newtonDConverged(x: int, y: int, amp: int): bool =
    newtonDFull(x, y, amp, NEWTON_K).done

  /// The real iteration count, i.e. how many times the contract's loop body ran.
  pure def newtonDIters(x: int, y: int, amp: int): int =
    newtonDFull(x, y, amp, NEWTON_K).iters

  /// |D_next - D| at the returned D: the residual of the fixpoint equation the
  /// iteration solves.  `<= 1` is the contract's own tolerance (:211-217).
  pure def newtonDResidual(x: int, y: int, amp: int): int = {
    val st = newtonDFull(x, y, amp, NEWTON_K)
    val nx = newtonDStep(x, y, amp * NEWTON_N, x + y, { ...st, done: false })
    if (nx.v > st.v) nx.v - st.v else st.v - nx.v
  }

  /// Signed magnitude.  Needed by every spec that carries a signed position.
  pure def absInt(a: int): int = if (a < 0) 0 - a else a

  /// Self-check for the extension.  Every vector is a replay of
  /// StableSwap3Pool.vy get_D in integer arithmetic at AMP = 100, N = 2, K = 8;
  /// the first five are P2-CONTRACT §A.2 verbatim.
  pure val kernelNewtonOk: bool = and {
    newtonD(100, 100, 100) == 200,
    newtonD(150, 50, 100) == 199,
    newtonD(180, 20, 100) == 198,
    newtonD(190, 10, 100) == 196,
    newtonD(199, 1, 100) == 170,
    newtonDFull(100, 100, 100, NEWTON_K).iters == 1,
    newtonDFull(190, 10, 100, NEWTON_K).iters == 2,
    newtonDFull(100, 100, 100, NEWTON_K).vprev == 200,
    newtonDFull(1, 100000, 100, NEWTON_K).iters == NEWTON_K,
    newtonDFull(1, 100000, 100, NEWTON_K).done != newtonDFull(100000, 1, 100, NEWTON_K).done,
    newtonDResidual(190, 10, 100) <= 1,
    absInt(0 - 7) == 7,
  }

  // ---------------------------------------------------------------------------
  // EXTENSION POINT — append-only, for W3.
  //
  //   W1 (curve, apex) appended `newtonD` above.  `newtonY` (StableSwap get_y)
  //   is NOT here: it is curve-local and is declared in curve.qnt behind a
  //   `LOCAL PRIMITIVE:` marker, per P2-SCOPE §3, because it has exactly one
  //   consumer.  It reuses `newtonAdvance` / `NewtonState` from this file, which
  //   is the part that generalises.
  //
  //   W3 (liquity, polymarket) uses `sorted.qnt` by direct import, not through
  //   this file, for the type-republication reason given in the header.
  //
  // RULE: appending a NEW definition here is permitted.  Changing or deleting an
  // existing one is not — nine specs are pinned to these names and to
  // `kernelOk`.  If a definition is wrong, it is replaced under a new name and
  // the old one is kept until every consumer has moved.
  // ---------------------------------------------------------------------------
}

// -----------------------------------------------------------------------------
//  Self-check harness, in its own module so that `kernel` stays state-free.
//    quint run --main=kernelCheck --invariant=inv_kernel --max-steps=1 kernel.qnt
// -----------------------------------------------------------------------------
