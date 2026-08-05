# P2 — EXPRESSIBILITY

**Verdict: the inexpressibility claim is false.** All three "hard parts" are expressible in
Quint 0.32.0. Every fragment below was written, typechecked, and executed before being
put in this document. Two of the three are *cheaper* to model faithfully than the
abstraction that replaced them.

Working sources (all typecheck, all run):
`…/scratchpad/p2-quint/{sqrt,sqrtNewton,sqrtHarness,sorted,liq_sorted,liq_nondet,curveD,curvePool,univ2}.qnt`

Final verification pass, all nine files:

```
=========== TYPECHECK ===========          =========== RUN ===========
sqrt.qnt           PASS                    sqrt: exhaustive isqrtCorrect   [ok] (167ms)
sqrtHarness.qnt    PASS                    univ2: exact geometric mint     [ok] (1555ms, 1929 tr/s)
sqrtNewton.qnt     PASS                    curve: Newton + obligation      [ok] (685ms, 8759 tr/s)
sorted.qnt         PASS                    liquity: sorted+extremal+prefix [ok] (1092ms, 5495 tr/s)
liq_sorted.qnt     PASS
liq_nondet.qnt     PASS                    === WITNESSES (violation = exercised) ===
curveD.qnt         PASS                    liquity: multi-trove redemption [violation]
curvePool.qnt      PASS                    univ2: old shortcut differs     [violation]
univ2.qnt          PASS                    nondet spec fails order guard   [violation]
```

---

## 0. A finding that constrains everything else: Quint has two integer widths

Before any of the three parts. The default Rust backend is **i64, not bignum**:

```
$ quint -q -r sqrt.qnt::sqrt "2^63"
runtime error: Error [QNT601]: Integer overflow in arithmetic operations: 2 ^ 63

$ quint -q --backend=typescript -r sqrt.qnt::sqrt "2^63" "10^18 * 10^18"
9223372036854775808
1000000000000000000000000000000000000
```

`10^18 * 10^18` — an ordinary WAD-scaled product — **overflows the default backend**. The
TypeScript backend is arbitrary precision but roughly an order of magnitude slower.

This is not a footnote. It means every re-spec must state its integer domain and which
backend it is executable on, and it independently justifies the corpus's use of small
scaled amounts. It is also the *only* genuine expressibility limit I found — and it is a
limit on the *evaluator*, not the language. Every fragment below is written for the Rust
backend and states its exact domain.

---

## 1. Extremal selection over a ledger — the blocker

Expressible. Faithful. And it **shrinks** the search space rather than blowing it up.

### Source mechanism

`TroveManager.sol:770` takes `sortedTroves.getLast()` (lowest annual interest rate) and
walks `getPrev()` (`:785`), redeeming `min(remaining, trove.debt)` from each, skipping
troves with ICR < 100%, stopping when `remainingBold == 0`. The order is mutable:
`SortedTroves.reInsert` moves a trove when its rate changes.

### (a) Insert maintaining order

The corpus's `List` + `head`/`tail` FIFO (`lighter.qnt:27,68,84`) is indeed not a
solution — it is insertion order. The fix is a single fold with a "placed" flag:

```quint
pure def before(a: Trove, b: Trove): bool =
  a.rate > b.rate or (a.rate == b.rate and a.id < b.id)   // total order; ties by id

pure def insertSorted(l: List[Trove], t: Trove): List[Trove] = {
  val r = l.foldl((List(), false), (acc, e) =>
    if (acc._2) (acc._1.append(e), true)
    else if (before(t, e)) (acc._1.append(t).append(e), true)
    else (acc._1.append(e), false))
  if (r._2) r._1 else r._1.append(t)
}

pure def removeById(l: List[Trove], id: int): List[Trove] =
  l.foldl(List(), (acc, e) => if (e.id == id) acc else acc.append(e))

pure def reInsert(l: List[Trove], t: Trove): List[Trove] =   // SortedTroves.reInsert
  insertSorted(removeById(l, t.id), t)
```

The `id` tie-break is load-bearing — see §1(d).

### (b) Extremal selection

```quint
pure def getLast(l: List[Trove]): Trove = l[l.length() - 1]  // lowest rate
pure def minByRate(l: List[Trove]): Trove =                  // same thing by fold
  l.tail().foldl(l.head(), (m, e) => if (before(m, e)) e else m)
```

Checked as an invariant that the two agree at every reachable state (`extremalAgrees`).

### (c) Prefix consumption under an amount budget

The redemption walk is a fold over the reversed list carrying the remaining budget:

```quint
pure def redeemOne(acc: RedeemAcc, t: Trove): RedeemAcc =
  if (acc.remaining <= 0 or not(t.active)) { ...acc, rev: acc.rev.append(t) }
  else if (not(icrOk(t, acc.price))) { ...acc, rev: acc.rev.append(t) }  // skip, keep walking
  else {
    val lot = if (acc.remaining < t.debt) acc.remaining else t.debt
    val coll = lot * WAD / acc.price
    val t2 = { ...t, debt: t.debt - lot, coll: t.coll - coll, active: t.debt - lot > 0 }
    { rev: acc.rev.append(t2), remaining: acc.remaining - lot,
      collOut: acc.collOut + coll, touched: acc.touched + 1, price: acc.price }
  }

pure def redeemFrom(l: List[Trove], amount: int, price: int): RedeemAcc = {
  val walked = rev(l).foldl(
    { rev: List(), remaining: amount, collOut: 0, touched: 0, price: price },
    (acc, t) => redeemOne(acc, t))
  { ...walked, rev: rev(walked.rev) }
}
```

The action then takes **no trove parameter at all** — that is the whole point:

```quint
action redeem(amount: int): bool = all {
  troves.length() > 0, freeBold >= amount,
  val r = redeemFrom(troves, amount, price)
  all { r.touched > 0, troves' = r.rev, ... }
}
```

### (d) State-space cost — measured, not asserted

**Zero extra reachable states.** Because insert is deterministic and the order is total
(rate, then id), the sorted list is a *function* of its own element set. This is machine
checked, not argued:

```quint
pure def canonical(s: Set[Trove]): List[Trove] = s.fold(List(), (l, t) => insertSorted(l, t))
pure def isCanonical(l: List[Trove]): bool = l == canonical(l.indices().map(i => l[i]))

val listIsCanonical: bool = isCanonical(troves)   // holds at every reachable state
```

`|List states| == |Set states|`. The ordering is free. **Drop the `id` tie-break and this
fails** — equal-rate troves become permutable and the list starts carrying real extra
states. The tie-break is the entire cost control.

**Branching factor goes *down*.** `redeem(u, amt)` has `|IDS| × |AMTS|` successor choices
per step; `redeem(amt)` has `|AMTS|`. At 24 troves and 3 budget values that is 72 → 3, and
the faithful step has 147 nondet combinations against the abstract spec's 216. Over a
25-step trace that is ~10³ fewer paths. Modelling the order faithfully *removes* the
nondeterminism that stood in for it.

**Wall-clock cost, `quint run`, 2000 samples × 30 steps:**

| troves | sorted, `supplyInv` | map+nondet, `supplyInv` | sorted, full `allInv` |
|---|---|---|---|
| 3  | 10,989 tr/s | 17,857 tr/s | 3,540 tr/s |
| 8  |  9,217 tr/s | 16,129 tr/s | 2,186 tr/s |
| 16 | 11,050 tr/s | 15,504 tr/s | 1,980 tr/s |
| 24 |  9,615 tr/s | 13,158 tr/s | 1,931 tr/s |

**~1.6× per trace, flat from 3 to 24 troves.** The `allInv` column (~5×) is the cost of
*checking* the mechanism, not running it — `redeemIsExtremal` is O(|budgets| · n²) per
state. No restriction on user count is needed. If one is wanted anyway, cap trove count
at 8 and budget values at 3 — that is already comfortable.

**Apalache verifies it.** Not sampling — symbolic bounded model checking:

```
quint verify liq_sorted.qnt --invariant=sortedInv   --max-steps=3  → [ok] (6,434ms)
quint verify liq_sorted.qnt --invariant=allInv      --max-steps=3  → [ok] (255,566ms)
```

The second proves all seven sub-invariants including `redeemIsExtremal` and
`listIsCanonical` over *all* reachable states to depth 3. A faithful sorted structure is
not merely runnable; it is verifiable.

### (e) The mechanism check — and a trap that cost me two attempts

The property that says "extremal selection consuming a minimal prefix" **cannot be
written as a state predicate over history**. I tried twice and both failed on real
behaviour, not on bugs:

- *Attempt 1* ("partially-redeemed troves form a suffix"): broken by `adjustRate` moving
  a redeemed trove up the order.
- *Attempt 2* ("if trove i is reduced then trove i+1 is drained"): broken by **opening a
  new trove**, which inserts *below* an already-redeemed one. Counterexample found in
  27ms — trove 2 (rate 10) redeemed to debt 70, then trove 3 opened at rate 10, id 3 > 2
  so it sorts after, and the guard fires spuriously.

The correct form quantifies over *hypothetical* redemptions from every reachable state —
a state predicate in form, a transition property in content:

```quint
pure def redeemIsExtremal(l: List[Trove], amount: int, price: int): bool = {
  val r = redeemFrom(l, amount, price)
  val touched = l.indices().filter(i => r.rev[i].debt < l[i].debt)
  and {
    // (A) ORDER-RESPECT: nothing touched before everything of lower rate is drained
    touched.forall(i => (i + 1).to(l.length() - 1).forall(j =>
      not(eligible(l[j], price)) or r.rev[j].debt == 0)),
    // (B) MINIMAL PREFIX: at most one trove left partially redeemed
    l.indices().filter(i => r.rev[i].debt > 0 and r.rev[i].debt < l[i].debt).size() <= 1,
    // (C) ENDOGENOUS CUTOFF: stop exactly when budget spent, or all eligible drained
    r.remaining == 0 or l.indices().forall(j =>
      not(eligible(l[j], price)) or r.rev[j].debt == 0),
    // (D) CONSERVATION: bold burned == debt destroyed
    amount - r.remaining == l.indices().fold(0, (s, i) => s + l[i].debt - r.rev[i].debt),
  }
}

val redeemExtremal: bool = AMTS.forall(a => redeemIsExtremal(troves, a, price))
```

`[ok]` on 5000 traces × 12 steps in 355ms, and Apalache-proved to depth 3.

**Directive for the regression guard: it must be a transition property.** Any
history-based state predicate is unsound the moment the order is mutable — which it is,
by both `reInsert` and insertion.

Two witnesses confirm the mechanism is *exercised*, not vacuously satisfied:
`multiTroveRedeemReachable` (a state exists where one redemption drains one trove and
partially redeems the next) → `[violation]`, i.e. reachable. And the same ordering guard
applied to the abstract `redeem(u, amt)` spec → `[violation]` in 20ms. The guard
discriminates.

---

## 2. Integer square root

Expressible and **exact**. Method: **restoring (binary digit-by-digit) square root**, not
Newton.

```quint
/// Exact floor(sqrt(n)) for 0 <= n < 4^bits. `bits` fold steps.
pure def isqrtBits(n: int, bits: int): int =
  if (n <= 0) 0
  else range(0, bits).foldl(0, (res, i) => {
    val cand = res + 2^(bits - 1 - i)
    if (cand * cand <= n) cand else res
  })

pure def isqrt(n: int): int     = isqrtBits(n, 31)   // Rust backend  (i64)
pure def isqrtWide(n: int): int = isqrtBits(n, 64)   // TypeScript backend (bignum)

pure val MINIMUM_LIQUIDITY: int = 1000
pure def geometricMintExact(a0: int, a1: int): int =   // UniswapV2Pair.mint, first deposit
  if (a0 <= 0 or a1 <= 0) 0 else isqrt(a0 * a1) - MINIMUM_LIQUIDITY
```

**Domain of exactness.** `isqrt` is exact on `0 ≤ n < 2^62 = 4611686018427387904` (the
largest intermediate is `(2^31)² = 2^62`, the i64 ceiling). `isqrtWide` is exact on
`0 ≤ n < 2^128`, TypeScript backend only. For `√(a₀·a₁)` on the Rust backend this means
reserves up to ~2.1e9 each.

**Verified, not claimed.** ~14,000 points checked as a `quint run` invariant in 167ms:
`isqrtCorrect` (`r² ≤ n < (r+1)²`) exhaustively on 0..4095; `isqrt(k²)=k`,
`isqrt(k²−1)=k−1`, `isqrt(k²+k)=k` for k in 1..3000; `isqrtCorrect(10^e + d)` for
e in 0..18, d in 0..40; and the boundary `isqrt(2^62 − 1) == 2^31 − 1`.

### Why not Newton — measured

Fixed-depth Heron `x ← (x + n/x)/2` from `x₀ = n`, wrong-count against exact `isqrt` over
n ∈ [0, 20000]:

| depth | wrong | max error | guarded variant, wrong |
|---|---|---|---|
| 4  | 19,913 | 1113 | 19,966 |
| 8  | 12,321 | 8    | 17,579 |
| 16 | **64** | **1** | **0** |
| 32 | **64** | **1** | **0** |
| 64 | **64** | **1** | **0** |

**Fixed-depth Newton never becomes exact.** It plateaus at 64 wrong values with error 1
and stays there at depth 32 and 64 — the integer iteration oscillates and one more step
does not help. Newton is exact only with the termination guard
(`stop when x_{k+1} ≥ x_k`, the "guarded" column), which needs depth 16 *and* a flag.

Restoring binary sqrt is exact at exactly 31 steps by construction, with no convergence
argument, no guard, and no proof obligation. That is why it is the right choice: it is
the only one of the three whose correctness is structural rather than empirical.

**Cost: zero state-space.** It is a `pure def`. The Uniswap V2 spec with the exact mint
runs at 1929 traces/s (3000 × 12), and its regression guard —
`geometricMintExact(a,b) == min(a,b)` — is `[violation]` for every `a ≠ b`: the old
shortcut and the real formula are demonstrably different functions.

---

## 3. Newton iteration (Curve `D`)

Expressible. But the honest answer to "is a fixed unrolling faithful?" is **no — and here
is the fix.**

### The argument

A bare fixed unrolling is **not faithful**, and not because it is imprecise. It is
unfaithful because it *deletes the contract's termination condition*. Curve's `get_D`
loops up to 255 times and `break`s when `|D − D_prev| ≤ 1`. A `foldl` over `range(0, K)`
returns the K-th iterate whether or not the break would have fired — it fails **silently**,
returning a number that looks like a `D` and is not one. That is the same class of defect
as `approxD`, just better disguised.

A fixed unrolling **is** faithful if it carries the break condition and exports it as a
proof obligation:

```quint
pure def dStep(x: int, y: int, ann: int, s: int, st: DState): DState =
  if (st.done) st                                    // <-- the contract's `break`
  else {
    val dp1 = st.d * st.d / (x * N)                  // same rounding, same order
    val dp  = dp1  * st.d / (y * N)                  //   as the Vyper
    val num = (ann * s + dp * N) * st.d
    val den = (ann - 1) * st.d + (N + 1) * dp
    val dNew = num / den
    { d: dNew, dprev: st.d, iters: st.iters + 1,
      done: if (dNew > st.d) dNew - st.d <= 1 else st.d - dNew <= 1 }
  }

pure def getDFull(x, y, amp, maxIter): DState =
  range(0, maxIter).foldl({ d: x + y, dprev: 0, done: false, iters: 0 },
                          (st, _) => dStep(x, y, amp * N, x + y, st))

pure def dConverged(x, y, amp): bool = getDFull(x, y, amp, MAXITER).done

val newtonConverged: bool = dConverged(b0, b1, AMP)   // <-- INVARIANT, never a guard
```

With `done` carried, the unrolling is **bit-identical to the Vyper** on every input where
the break fires within `MAXITER`, and *loudly wrong* everywhere else. The abstraction has
become an auditable claim.

### (a) Iterations used: 8

`MAXITER = 8`. Measured, not guessed. Over a 14×14×7 = 1372-point grid
(`x,y ∈ {1,2,3,5,9,17,50,100,333,999,5000,12345,100000,1000000}`,
`amp ∈ {1,2,10,50,100,500,2000}`), worst iteration count among all converging points is
**6** at imbalance ratio ≤ 100 and **7** at ratio ≤ 500. 8 gives one step of headroom.
The brief's "roughly 4" is right for near-peg pools; 7 is what the tail actually costs.

### (b) Residual error — and a genuine non-convergence result

**Curve's integer Newton iteration does not converge on all inputs.** 39 of 1372 grid
points (2.8%) never satisfy `|D − D_prev| ≤ 1`, at *any* depth — verified at K = 4, 8, 16,
24, 32, 48, 64 and 96. The residual settles into a **period-2 limit cycle oscillating
between 20 and 21**. Floor division, not slow convergence.

```
K:        4       8      16      24      32      48      64      96
residual: 98743   18916  20      21      20      21      20      21
non-conv: 154     49     20      20      20      20      20      20
```

The failing points are all extreme imbalance (smallest bad ratio 999; examples
`(999,1,amp=1)`, `(1000000,17,amp=10)`, `(100000,1,amp=100)`), and the boundary is
**not** a clean ratio threshold — non-convergence is scattered, since some ratio-10⁶
points converge fine. That is exactly why the `done` flag, not a domain assumption, has
to be the mechanism.

**On the stated domain the residual is ≤ 1** — the contract's own break condition,
checked as `residualSmall` at every reachable state.

Sweep of `quint run curvePool.qnt --invariant=allInv` (25 steps × 6000 samples, AMP=100,
a `reconfigure` action jumping to arbitrary grid pairs):

| max imbalance | K=3 | K=5 | K=6 | K=7 | K=8 | K=16 | K=32 | K=64 |
|---|---|---|---|---|---|---|---|---|
| ≤ 100     | ok | ok | ok | ok | ok | ok | ok | ok |
| ≤ 500     | **viol** | ok | ok | ok | ok | ok | ok | ok |
| ≤ 1000    | **viol** | ok | ok | ok | ok | ok | ok | ok |
| ≤ 100000  | **viol** | **viol** | **viol** | **viol** | **viol** | **viol** | **viol** | **viol** |

Both the depth and the domain are load-bearing, and both are caught by the invariant.

### (c) Faithfulness, argued honestly

A fixed unrolling with `done` carried is faithful **relative to a stated domain
restriction**, and the restriction is the only real abstraction. Concretely:

- On `{(x,y,amp) : dConverged}` the spec computes exactly what the contract computes.
- Off it, the spec **fails an invariant** rather than returning a plausible wrong number.
- The real contract on those inputs returns a non-converged `D` after 255 iterations
  (older pools) or reverts (newer). The spec models neither — it declares the input out
  of scope. **That is the abstraction, and it should be written in the spec header.**

So: not "a fixed unrolling is faithful", but "a *guarded* fixed unrolling is faithful on a
domain the spec names and the checker enforces". That is a materially different and
weaker claim than the one the brief invited, and it is the one the evidence supports.

### (d) A trap worth recording

My first version put `dConverged(...)` in the action **preconditions**. Every depth
passed, including `MAXITER = 3`. The guard silently pruned exactly the states it was
meant to expose — a fresh instance of the same failure mode as `approxD`. **The
convergence obligation must be an invariant, never an action guard.** This generalises:
any "the abstraction is valid here" condition placed in a precondition converts an
unsound spec into a vacuous one.

**Cost: zero state-space.** `D` is a `pure def`; the pool spec has three variables and
runs at 8759 traces/s.

---

## Summary

| Part | Expressible? | Method | Exact on | State cost | Runs |
|---|---|---|---|---|---|
| Extremal selection | **Yes** | sorted `List` + fold walk, total order with id tie-break | all | **zero extra states**; ~1.6× wall-clock, flat to 24 troves; branching *reduced* | `quint run` 5495 tr/s; **Apalache-proved to depth 3** |
| Integer sqrt | **Yes, exact** | restoring binary sqrt, 31 folds | `0 ≤ n < 2^62` (Rust); `< 2^128` (TS) | zero (`pure def`) | 14k points, 167ms |
| Newton `D` | **Yes, guarded** | 8-step unrolling carrying the contract's `break` | imbalance ≤ 500, residual ≤ 1 | zero (`pure def`) | 8759 tr/s |

**Nothing here is inexpressible.** The single real limit is the Rust backend's i64 width,
which caps domains rather than mechanisms and is escapable via `--backend=typescript` at a
speed cost.

Three directives for the executor, each earned from a failure above:

1. **The regression guard must be a transition property.** State predicates over history
   are unsound whenever the order is mutable — and it always is.
2. **Validity conditions go in invariants, never in preconditions.** In a guard they
   convert unsoundness into vacuity, which is harder to detect.
3. **Every unrolled loop must carry its source's termination condition** as an exported
   obligation. An unrolling that cannot fail loudly is an abstraction wearing a
   mechanism's clothes.
