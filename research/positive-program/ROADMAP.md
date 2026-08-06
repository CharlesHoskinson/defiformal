# Roadmap to the paper

**Target.** A paper exhibiting a finite basis of primitive mechanisms and proving
every useful DeFi application is constructible from it — functional completeness
for DeFi, with the corpus as evidence the basis spans the field.

**Realistic total: 8–12 weeks.** The critical path is Phase 2.

---

## Phase 0 — close what is open *(days)*

**0.1 Re-state the Q/Σ invariant testably.**
`BASIS.md` claims "no `Q`-sorted state variable is ever assigned a value that
isn't an arithmetic term over prior `Q`s", corpus-wide over 388 state variables.
Three good-faith operationalisations (`sigma/qsigma{,2,3}.py`) all yield a
trivial partition. Until it is stated precisely enough to test, `|P| = 4` and the
six-sort split are unsupported.
*Gate:* a script produces a non-trivial partition, or `|P| = 4` is withdrawn.

**0.2 Prove `F9` (extremal allocation) irreducible.**
Settled empirically — every fold in the corpus is `fold(0, (acc,x) => acc + …)`,
a commutative sum; zero extremal selections. Needs the theorem: an invariant
every `⋈`-composite preserves and extremal selection breaks.
*Gate:* theorem, or a counterexample construction.

---

## Phase 1 — fix the basis *(1–2 weeks)*

**1.1 Enumerate the families with signatures and laws.**
Current estimate ~16, not 8. Named so far: trading function, valuation
*application* `(A,P)→V`, tranche subordination, custody, once-only delivery,
limit orders, delegation, plain ledger, authz, rate curves — plus the survivors
`F2 F3 F5 F6 F7 F8` and the allocation rule `F9`.
*Gate:* every family has ≥2 corpus witnesses and a law that fails for its
neighbours. A family with no law is a name.

**1.2 Pairwise independence.**
*Gate:* each family has a separating trace, as `F7` got via the interest-only
trace (no deposit, no redemption, constant price, index strictly increases).

**1.3 Non-degeneracy and sufficiency.**
The finite failure list exists (≤15 colour classes, each `Ω_c` closed under `⊗`
because `⊗` matches existing ports and creates no colour) but gives only the
**necessary** direction. Post's theorem is an *iff*.
*Gate:* sufficiency proved, or the claim weakened explicitly in the paper.

---

## Phase 2 — an honest corpus *(2–3 weeks — CRITICAL PATH)*

**2.1 Re-spec the 10 ungenerated protocols without abstracting the hard parts.**
`uniswap_v2`, `curve`, `compound_v3`, `morpho_blue`, `liquity`, `apex`, `gmx`,
`huma`, `derive`, `polymarket`.

This is the single most important step. Today's specs deleted exactly what the
theorem must survive:
- `liquity.qnt:130` — `action redeem(u, boldAmt)` takes the trove as a
  *parameter*, chosen by `nondet u = USERS.oneOf()`. The real contract does
  `sortedTroves.getLast()` then walks `getPrev()` (`TroveManager.sol:770,785`).
- `common.qnt:76–92` — `geometricMint` returns `min(a0,a1)` instead of
  `√(a₀a₁)`, self-documented as "unrolled for quint purity without loops".
- `curve.qnt:22–30` — `approxD` substitutes a "weighted blend" for Newton
  iteration.
*Gate:* the re-specs typecheck and contain the ordering and the exact arithmetic.

**2.2 Spec the missing applications.** The corpus names 72; only 51 have specs.
One unformalised — Steakhouse Financial — is a known refuter (delegated
allocation authority).

**2.3 Re-run generation against the honest corpus.**
*Gate:* a number defensible under review.

---

## Phase 3 — the theorems *(3–4 weeks)*

**3.1 Generation.** `P` generates the corpus, or the residue names the closure.
Both are publishable; one is stronger.
**3.2 Composition.** `⋈` totality by construction, not by measurement.
**3.3 Construction.** Synthesis plus a certificate checkable in time linear in
the construction.
**3.4 Lean.** Mechanise basis, laws and generation. The development exists at
`/root/DefiElements/lean` — sorry-free, no custom axioms.

---

## Phase 4 — write it *(2–3 weeks)*

Basis, laws, generation theorem, failure list, the corpus as evidence, residue as
future work.

---

## The decision that shapes the paper

**Step 2.1 decides what the paper is.** If the honest re-specs show the basis
cannot reach the AMMs and the order-dependent protocols, the paper becomes:

> *A basis for pool-shaped DeFi, plus a proof that extremal allocation is
> irreducible to it.*

That is a strong paper and it is the one the current evidence supports. It is not
a negative result — it exhibits a finite basis and delimits it exactly.

---

## Gate status (updated each loop pass)

| gate | state | evidence / blocker |
|---|---|---|
| 0.1 Q/Σ invariant testable | **RESOLVED — claim false, `\|P\|=4` WITHDRAWN** | `sigma/QSIGMA-VERDICT.md`; the prior "three operationalisations" were two, and both scanned `init` |
| 0.2 `F9` irreducible | **empirically settled, theorem open** | zero extremal selections corpus-wide |
| 1.x fix the basis | not started | blocked on 0.1 |
| 2.0 find all ten deletions | **PASSED** | `phase2/P2-SCOPE.md`, all ten with line numbers |
| 2.0b fidelity criterion | **PASSED** | `phase2/P2-FIDELITY.md`, quotient formulation |
| 2.0c regression guard | **PASSED** | `phase2/respec_lint.py`; v1 baseline **180 findings / 57 specs** |
| 2.0d kernel (`isqrt`, Newton, sorted walk) | **PASSED** | `phase2/kernel/` 9/9 typecheck (independently verified); sorted walk costs **zero extra reachable states**, Apalache-proved to depth 3 |
| 2.0e plan review | **repairs delivered** | R1+R4 applied to `P2-FIDELITY`; R2/R3/R5 in `phase2/P2-CONTRACT.md` |
| 2.0f close three carry-forwards | **CLOSED** | CF1 closed (constant-crossing rule); CF2 closed as convention 6g, half-lintable; CF3 resolved then **corrected** |
| 2.1a pilot (`uniswap_v2`) | **PASSED** | lint 0, typecheck clean, `inv_conservation` ok, 13 `wit_*` all violated as required; 22 T0 vectors |
| 2.1b the remaining nine | **DELIVERED, record incomplete** | all 10 targets present; 13/13 typecheck and lint 5/13 re-verified pass 7; **W2 has no delivery section** |
| 2.1c close W1's curve carry-in | **PASSED** | K=8 does not truncate — the guard refuses; `inv_all` ok to depth 20 |
| 2.2 spec the missing 21 | not started | 72 named, 51 specced |
| 2.3 re-run generation | blocked | needs 2.1b's record closed |

**Next gate: 2.0f — close three carry-forwards.** The five repairs landed, but
delivering them surfaced three items that must be closed before any re-spec is
written.

### Carry-forward 1 — CLOSED (`phase2/P2-CARRYFORWARD.md`)

Diagnosis: convention 8's `<= 200` conflated **value magnitude** with
**branching factor**. Only branching costs runtime. Replaced by 8a (branching:
at most 8 enumerated values per `nondet`), 8b (magnitude: declare the peak,
`< 9.22e18`), and 8c **constant-crossing** — the domain must contain values on
both sides of every protocol constant appearing in a comparison, subtraction or
min/max.

Applying 8c retroactively to the old `<= 200` cap: **six of the ten protocols
were dead, not merely degraded** — `uniswap_v2` and `apex` (both underflow
`MINIMUM_LIQUIDITY = 1000`), `gmx` (`d <= 200 < FLOAT_PRECISION`, so impact is
identically 0), `liquity` (`MIN_DEBT = 2000`), `morpho_blue`
(`VIRTUAL_SHARES = 10^6`, so a share balance is not even representable), and
`derive` (spot `10^4`). Two degraded, two survived.

Pilot domain: mint amounts `{1000..20000}`. `(1000, 1000)` yields 0 and hosts the
`INSUFFICIENT_LIQUIDITY_MINTED` revert branch; `(4000, 9000)` yields minter LP
**5000 > 0** with 1000 permanently locked.

**Three collisions carried into 2.1 as decisions:** liquity's `MIN_DEBT = 2000`
is a live second instance of CF1 that survives even the repaired contract
domain (debts there are `<= 300`); morpho's `MAX_LIF` branch is unreachable
without varying `LLTV`, which needs a scope amendment since multi-market was
dropped; and apex's two declared ranges are mutually unreachable once the sqrt
bootstrap runs.

### Carry-forward 2 — CLOSED as a convention, OPEN as a linter

New convention **6g, dependency parity**: for each `nondet`-supplied or
literal-substituted quantity, the spec must read every contract-storage variable
the contract's expression depends on, restricted to variables the spec models.
It measures *storage dependence*, not "outside-ness" — an oracle's storage
footprint is empty in the contract too, so parity holds and oracles are not
banned. In apex it permits the oracle price and forbids `markPrice`, whose
footprint is `{reserveBase, reserveQuote, position size}` via `getMarkPriceAcc`.

Ten-way test: uniquely catches the apex trigger (the target), independently
re-catches compound_v3, liquity, huma and derive — which were each already
caught by a *different* convention, evidence that 6g is the right
generalisation — is silent on five, and produces **zero false positives**.

Lintable in half: D5a (undeclared `nondet`, or a non-empty declared footprint on
a `nondet`) and D5b (declared footprint minus identifiers actually read) are pure
syntax. The classification itself is not mechanisable — every declaration-free
heuristic fires on compound_v3, morpho and gmx, all genuine oracle reads. A
three-question reviewer checklist covers that half.

### Original CF1 statement (superseded, retained for the record)

Convention 8 caps ranges at 200. `MINIMUM_LIQUIDITY = 1000` is a **protocol
constant, not a scale**, so on the pilot `uniswap_v2`:

    isqrt(200 * 200) - 1000  =  -800     underflow

The initial-mint lock — the pilot's headline mechanism and one of the twelve
unmatched candidate primitives — cannot occur at all. A cap of at least 2000 is
required for a non-zero first mint. Fix the convention before the pilot is
written, or the pilot certifies a domain in which its own mechanism is absent.

### Carry-forward 2 — one deletion no convention reaches (VERIFIED)

`apex`'s liquidation **trigger**: an endogenous argument was replaced by a
legitimate exogenous one, which convention 6 explicitly *permits*. Conventions
6b-6f do not reach it either. This is a named hole, not an oversight — it needs
a new convention or an explicit per-protocol check.

Related and verified: apex's fee is **invisible at ordinary trade sizes** — at
`(in=200, rIn=1000, rOut=1000)` the 999/1000 form and the zero-fee form both
return 166. A "safe small trade" domain silently re-deletes the fee. This is
exactly the second-order damage path the review predicted for i64.

### Carry-forward 3 — RESOLVED by direct computation (`evidence/curve_reconcile.py`)

- Expressibility (gate 2.0d): Curve's integer Newton fails to converge on
  **2.8% of a 1372-point grid**, at any depth up to 96 — a period-2 limit cycle.
- Contract (gate 2.0e): swept **all 200x200 pairs at AMP=100, K=8 — zero
  non-converging**, worst case 3 iterations.

These are probably not contradictory; they are different domains. But that is
the point: **the smaller domain is exactly where the pathology is invisible**,
which is the same failure by which Curve's spec reached `bal0 = bal1 = 100` and
lost its discrimination witness. Do not adopt the `<=200` sweep as evidence that
Curve converges. Reconciled. Faithful integer `get_D` (StableSwap n=2) swept directly:

| domain | amp | K | points | non-converging | rate | worst iters |
|---|---|---|---|---|---|---|
| 1..200 | 100 | 8 | 40000 | 0 | 0.00% | 3 |
| 1..200 | 100 | 96 | 40000 | 0 | 0.00% | 3 |
| 1..2000 | 100 | 8 | 23716 | 0 | 0.00% | 5 |
| 1..10^5 | 100 | 8 | 20449 | 18 | 0.09% | 8 |
| 1..10^7 | 100 | 8 | 20449 | 280 | 1.37% | 8 |
| 1..10^7 | 100 | 96 | 20449 | 75 | 0.37% | 17 |

**Both agents were right on their own domain, and that is the finding.** The
pathology is real and lives *exactly outside* the `<=200` domain. Threshold is
between 10^4 (converges, 6 iterations) and 10^5 (does not converge at any depth
up to 96). Every non-converging point sits at extreme imbalance — the first
five all have `y = 1`. Raising depth from K=8 to K=96 reduces the rate
(1.37% -> 0.37%) but never eliminates it, which is consistent with the
period-2 limit cycle reported at gate 2.0d.

**Consequence, and it is the whole lesson of Phase 2 in one instance:** adopting
the `<=200` sweep as evidence that Curve converges would repeat, exactly, the
failure by which Curve's v1 spec reached `bal0 = bal1 = 100` and lost its
discrimination witness. A small domain does not prove convergence; it hides
divergence.

**Resolution for the re-spec — CORRECTED at gate 2.0f.**

The first resolution here said `10^5..10^7` was safe because
`10^7 * 10^7 = 10^14`. **That checked the wrong quantity** — the product of the
two balances, not the peak intermediate inside the Newton step. At extreme
imbalance `D_P` is *cubic* in `D`, so the numerator
`(Ann*S + D_P*N) * D` grows far faster than `x*y`. Verified
(`evidence/curve_peak.py`):

| point | peak intermediate | x*y | fits i64 |
|---|---|---|---|
| (10^4, 1) | 520,204,015,200 | 10,000 | yes |
| (10^6, 1) | 500,202,000,401,500,200 | 1,000,000 | yes |
| (10^7, 1) | **500,020,200,004,015,000,200** | 10,000,000 | **NO** |

Largest `x` at `y = 1` whose peak fits i64 is **2,642,111**. The corrected cap is
**10^6**: peak `5.0 * 10^17`, about 18x headroom, and the witness is still
hosted — 250 of 381 sampled points non-converging at K=8. Adopt `<= 10^6`, not
`10^7`, and assert the divergence witness explicitly.

This correction is itself an instance of the Phase 2 lesson: a domain bound was
justified against a plausible-looking quantity that was not the binding one.

### The fifth trap, found by the contract in its own output

T0 conformance vectors are `pure val`s, hence true in every state **including one
where the pinned `pure def` is never called** — the arithmetic present as a
library and absent as a mechanism. Already live at `apex.qnt:184`. Countered by a
`wit_used_<f>` violation obligation plus one `T0-LIVE:` vector per protocol whose
obligation is a *trace*, not an equality. This is the fifth instance of one
shape: **the check passes because the mechanism never ran.**

### The five repairs

1. **Delete the parsimony step.** `P2-FIDELITY` section 3 step 3 instructs the
   worker to remove any distinction the mutant suite does not need, iterated to a
   fixed point. That is the *fourth trap* — the same shape as the other three
   (the check passes because the stressing states were removed), except here it
   is mandated. It also contradicts section 2's contract-facing droppability
   rule, and it makes the generation measurement circular: the corpus becomes a
   function of the ten contrast sets.
2. **Add T0 conformance vectors.** The acceptance test is cheatable for eight of
   the ten, because it checks the *shape* of a definition and never its *value*.
   Worked cheat on `derive`: decorate the deleted constant with a per-scenario
   factor and the min-invariant becomes a tautology about any fold-min while the
   witness is violated by construction. Fix: at least three exact
   (input, output) pairs read off the contract, asserted as `pure val`s.
3. **Extend the nondet convention.** It catches 3 of 10 (liquity, derive,
   polymarket; partly huma) and is silent on sqrt, Newton, the absorb haircut,
   the bad-debt no-op, the missing fee, and the absent impact function.
4. **Mandate three contrast-set members.** Distant rivals are free to kill —
   Curve's own blend beats a contrast set of constant-sum plus constant-product.
   Require: the v1 shortcut body itself, a chaos relaxation, and a near
   neighbour agreeing with the target on at least 90% of the domain, sourced
   from a sibling protocol already in the corpus.
5. **Fix i64 for three protocols.** `morpho_blue`'s acceptance item 4 literally
   cannot run (`WAD^2 = 10^36`); `compound_v3` chains two 1e18 factors; and
   `gmx`'s permitted linearisation deletes the convexity that *is* the impact
   mechanism — revoke that permission, since a descaled domain hosts exponent 2
   fine. The damage path is second-order: overflow is loud, the worker escapes
   it by shrinking the domain, and **that is exactly how Curve reached
   `bal0 = bal1 = 100`** and lost its discrimination witness.

### Regression guard strengthened in response

`respec_lint.py` D3 now matches **trailing** comments, not only standalone ones —
the form of the confirmed `apex.qnt:145` defect
(`marginPool' = marginPool, // simplified: collateral absorbed`). D3 findings on
v1 went 2 -> 7; new baseline **185 findings / 57 specs**.

### apex: three further losses beyond the three recorded

Confirmed against source. There is no close/burn path at all, so the fee is
absent on the exit side too; the LP-mint branch at `:184` is **dead**
(`lpShares` is seeded at 100 and only ever increases, so `lpShares == 0` is
unreachable) and it deletes the permanent MINIMUM_LIQUIDITY lock, itself one of
the twelve unmatched candidate primitives; and `liquidate`'s **trigger** is
deleted as well as its settlement — the contract prices via `getMarkPriceAcc`,
making liquidatability size-dependent, where the spec uses an exogenous scalar.

### Hard constraints discovered at 2.0d (these bind every re-spec)

1. **Quint's default Rust backend is i64, not bignum.** `10^18 * 10^18`
   overflows. Every re-spec must keep its domain inside i64, or pay a large
   speed cost via `--backend=typescript`. This is the only genuine
   expressibility limit found.
2. **A fixed unrolling of Newton is NOT faithful.** A bare `foldl` silently
   deletes the contract's `break`; carrying a `done` flag makes it bit-identical
   where the break fires. Depth **K = 8** (measured worst case 7 — the brief's
   "about 4" was wrong).
3. **Convergence obligations must not live in an action precondition.** Doing so
   made every depth pass, including K = 3, by pruning the very states it was
   meant to expose. That is `approxD`'s failure mode in disguise.
4. **History-based state predicates are unsound as regression guards** — broken
   by insertion, not only by rate changes. The sound form quantifies over
   hypothetical redemptions.
5. **Curve's integer Newton genuinely fails to converge on 2.8% of a 1372-point
   grid**, at any depth up to 96 — a period-2 limit cycle with residual
   oscillating 20 to 21. This is a fact about Curve that `approxD` concealed.

### What the kernel bought

- Extremal selection is not merely expressible, it is **cheaper**: zero extra
  reachable states (machine-checked by a `listIsCanonical` invariant proving the
  list is a function of its element set — the id tie-break is what buys this),
  about 1.6x wall clock per trace, **flat from 3 to 24 troves**, and branching
  *drops* (147 vs 216 nondet combinations per step at N = 24). No restriction on
  user count is needed.
- `isqrt` is **exact** on `0 <= n < 2^62` via 31 folds, verified on ~14k points.
  Newton was measured and rejected: fixed-depth Newton never becomes exact,
  plateauing at 64 wrong values with error 1 at depths 16, 32 and 64.
- The independently built regression linter confirms the fix: `liq_nondet.qnt`
  flags `redeem(u)` as identity selection used as a map key; `liq_sorted.qnt`
  has no trove parameter at all.


---

## Gate 2.1a — pilot result and what it changed

**Passed on every check, independently verified.** Lint 0 findings; `kernel.qnt`,
`uniswap_v2.qnt` and a mutant all typecheck; `inv_conservation` clean over
20 steps x 2000 samples in 91 ms; all 13 `wit_*` obligations report `[violation]`
as required. Conformance vectors, recomputed here:

| input | `isqrtFloor(a0*a1) - 1000` | v1 `min` shortcut |
|---|---|---|
| (4000, 9000) | **5000** | 3000 |
| (2000, 8000) | **3000** | 1000 |
| (1000, 2000) | **414** | 0 (refused) |

All off-diagonal, which is the point: `min` is correct exactly on the diagonal,
where every rival agrees.

### The pilot invalidated its own headline, correctly

It reported that **the v1 spec of the same protocol also scores 0** on the
linter. Confirmed. All five detectors were blind to both of `uniswap_v2`'s
deletions, so the baseline contained nothing from the protocol that motivated
Phase 2. "0 findings" was therefore not evidence of improvement.

**Fixed by adding detector D6** — state with substantive writes and zero reads.
It catches v1's `kLast` (3 writes, read by nothing, because its only consumer
`_mintFee` was absent) and does not fire on the pilot. The comparison is now
meaningful. D6 finds **19 instances corpus-wide**: `funding` twice, `queue`,
`feesOwed`, `feeGrowth`, `protocolFees0`, `loanBorrower`, `permitted`. New v1
baseline **204 findings / 57 specs**, up from 185.

**Also fixed — pilot trap K5, a bug in the guard itself:** `respec_lint.py` was
skipping any file named `kernel.qnt`, leaving the most load-bearing file in the
tree unchecked. Exemption removed; the kernel lints clean.

### Two corrections that bind the remaining nine

1. **Peak intermediate is 4.61e18, not 4e8.** It lives inside `isqrtFloor`'s fold
   (`(2^31-1)^2`), so every spec calling it inherits that floor — **2.00x i64
   headroom, not 1e10x**. Verified. Far tighter than `P2-CONTRACT` assumed.
2. **R4's "near neighbour agreeing on >=90%" is unsatisfiable for
   `geometricMint`.** Exhaustive enumeration over all 49 domain pairs gives a
   best of 30.6% (ceil-sqrt), because the geometric mean is extremal — every
   rival separates off the diagonal. Reported with the measured figure rather
   than faked.

### Known state of `quint-models-v2/`

`kernel.qnt` imports `sqrt.qnt` rather than folding it, and `sorted.qnt` is
deliberately **not** wrapped because it exports a type, which Quint cannot
republish through a wrapper. `sorted.qnt` carries **3 D1 findings**
(`collOut`, `price`, `touched` — fields carried but never read in a guard).
These are gate-2.0d demonstration scaffolding. **The ordered-structures worker
must not inherit them uncritically.**

Ten traps for the nine are documented in `quint-models-v2/PILOT-NOTES.md` (K1-K10),
including three further linter defects: D2 misreads a wrapped assignment (K3),
D3 fires on ordinary commentary (K4), and `--invariant` is a single-state
predicate with no two-state form (K6).

---

## Gate 2.1b — W1 (`curve`, `apex`) delivered

Both typecheck; all invariants clean; 34 + 42 T0 vectors; 12 + 18 `wit_*` trace
obligations all violated as required; lint 0 on `curve`, 1 justified on `apex`.
Mutants confirm the separation: on both M1s `inv_conservation` still reports
**[ok]** while `inv_T0` is violated — i.e. the conservation invariant alone does
not detect the deleted mechanism.

### Five corrections from W1, all load-bearing

1. **K=8's worst case is 8, not 7.** K=8 is *tight*, not slack; K=7 would
   silently mis-evaluate pairs that need all eight. Verified independently:
   49 of 4900 sampled pairs need exactly 8 at a 10^5 cap.
2. **`get_D` is asymmetric, and the asymmetry is the contract's own.** `D_P` is
   two *sequential* floor divisions, so `(10^5, 1)` is a period-2 limit cycle
   that never converges at any depth, while `(1, 10^5)` converges at exactly 8.
   Verified: `(10^6, 1)` diverges, `(1, 10^6)` converges in 10. A "tidied"
   symmetric rewrite must therefore fail, and `kernelNewtonOk` asserts it does.
3. **The residual bound of 1 is FALSE for the contract.** `get_D`'s break bounds
   the *step* `|D - Dprev| <= 1`, not the *residual* at the returned D. At
   `(100010, 1)` it breaks with residual 3. Shipped with the true bound.
4. **`inv_kMonotone` does not kill apex's fee deletion.** Measured on the mutant:
   with 999/1000 removed entirely, `inv_kMonotone` still reports **[ok]**,
   because integer flooring alone makes k non-decreasing. **A prescribed positive
   check that the deleted mechanism satisfies** — the same shape as the other
   traps. Only T0 separates them. It is also *false as stated* for closes and
   liquidations, where an underwater settlement makes k fall.
5. **`PILOT-NOTES` mis-cites apex's M3 agreement as 7/49; it is 0/49** — the v1
   body has no `MINIMUM_LIQUIDITY` subtraction at all, so it cannot agree even on
   the diagonal.

### NEW — a correction to this roadmap's own curve domain (`evidence/curve_k.py`)

Carry-forward 3 recommended a **10^6** cap for curve. That is wrong for K=8:

| cap | worst converging | K=8 verdict |
|---|---|---|
| 10^4 | 6 iters | sufficient |
| 10^5 | 8 iters | **exactly tight** |
| 10^6 | **12 iters** | **truncates 97 of 4900 converging pairs** |

W1 measured K=8 tight on a grid topping out near 10^5, then the domain shipped
at 10^6. A bound validated on a domain smaller than the one it ships against is
the same failure this whole phase exists to prevent — and this instance is in
the roadmap's own recommendation, not a worker's.

**Resolution:** either cap curve at **10^5** (K=8 exactly tight, divergence
witness still hosted — 10 non-converging in a 4900 sample — and vast i64
headroom), or keep 10^6 and raise **K >= 12**. The 10^5 option is cheaper and
keeps the verified kernel unchanged. **W1's shipped curve domain must be checked
against this before 2.1b closes.**

---

## Gate 2.1b — W3 (`liquity`, `polymarket`) and W4 (`derive`, `huma`) delivered

All four typecheck. W3: 8 + 8 invariants hold, **18 + 14** witnesses violated,
21 + 13 T0 groups. W4: 9 + 7 invariants hold, **22 + 24** witnesses violated,
42 + 38 T0 vectors.

### The structural result of the whole phase

**Value signatures cannot kill a selection-shaped deletion, and neither can the
mechanism invariant.**

W3 asserted a value signature (`debtsOf(troves) == List(4000,0,0)`) unreachable
under its mutant, then *built and ran* the mutant: it reached that exact state at
depth 3, by touching trove 3, then 2, then 1 across separate transitions. Quint's
`--invariant` is a single-state predicate (trap K6), so no predicate can say "in
one transition". For a mechanism whose content is *which elements were selected
together*, the discriminating observable is the **arity of the selection**.

Measured on `liquity_M1`: `inv_T0`, `inv_conservation`, `inv_bounds`,
`inv_listCanonical`, **`inv_redeemPrefix`** and `inv_all` all `[ok]`. It dies to a
single ghost-counter witness. `inv_redeemPrefix` is the *mechanism* invariant and
it does not discriminate either, because it quantifies over a hypothetical
application at the current state rather than over the transition taken.

W4 confirmed this independently with a purpose-built mutant,
`huma_M6_oneTranche`, which keeps the cap and every arithmetic definition and
only refuses to serve both tranches in one epoch: all six invariants and all four
value-level witnesses behave exactly as on the target; only
`wit_arity_bothTranches` dies.

Ghosts were justified against on-chain observables in both cases — liquity's
one `TroveUpdated` event per touched trove; huma's one
`executeRedemptionSummary` per served tranche; derive's `scenarios.length`
(which `PMRMLib.sol:97` reverts on) and `worstScenario` (which `DutchAuction`
stores as `auctions[].scenarioId`).

### The predicted cheat was built, run, and passes the prescribed checks

`mutants/derive_M1prime.qnt` is the plan review's decoration cheat, one
substitution at the definition site:

| obligation | result |
|---|---|
| `inv_marginIsMin` | **[ok]** — the cheat passes the P2-SCOPE prescribed check |
| `inv_worstIsFirst` | **[ok]** |
| `inv_conservation` | **[ok]** |
| `inv_T0` | [violation] |
| `wit_splitSensitiveArgmin` | T0-LIVE state unreachable — the kill |
| `wit_arity_fullScan` | the arity half also kills it |

**A re-spec shipping only the three named acceptance criteria would have signed
the deletion off.** T0 vectors and the arity witness are what separate them.

### The transferable rule (W4)

- An **under-approximating** deletion (uniswap) is caught by a *reachability
  witness* and not by an invariant.
- A **relaxing** deletion (huma) is caught by an *invariant* and not by a
  reachability witness — the mutant's reachable set strictly contains the
  target's.

W4's first `wit_juniorCapped` was violated by the mutant too, measured; pinning
it to the instant with `lastOp == OP_EPOCH` fixed it.

### Contract errors found by running rather than reading

1. **`inv_seniorRatio` is not a contract invariant.** Junior is first-loss, so
   `lossToTranches(700,200,300) = (600, 0)` leaves senior 600 against junior 0 —
   `Pool.sol:235-238` says so. v1 was right that it breaks and wrong about why.
2. **`inv_marginIsMin` is a shape property** that passes under the deleted
   mechanism — measured, not argued.
3. **`P2-CONTRACT` §A.10's polymarket batch row is not economically
   realisable**: it implies a taker contribution of **-30**.
4. **`sorted.qnt`'s 3 D1 findings were TRUE positives**, not the false positives
   `PILOT-NOTES` §2 guessed — a payout nothing constrained, a counter nothing
   read, a price nothing asserted unchanged. Now 3 -> 0.
5. **Quint's `/` truncates toward zero** (`(-7)/2 == -3`), matching Solidity
   `int` division, so `mulDivDown` is a floor only on non-negative operands.
   derive is signed throughout and pins the direction locally.
6. **R4's agreement percentage must be reported per returned component.** M4
   (correct magnitude, index discarded) agrees **100% on the value** and 68.1%
   on the index. A contrast set scored on the value column alone reports "no
   rival separates" and is wrong.
7. **6g's decisive demonstration is inside liquity.** `batchLiquidateTroves`
   takes ids from calldata (footprint empty — legitimate `nondet`);
   `redeemCollateral` derives them from `getLast()`/`getPrev()` (footprint
   non-empty — rejected). One protocol, two identity-valued inputs, and 6g
   separates them where convention 6 alone cannot.

### Three linter bugs found by the workers, all fixed

- `keyed` was computed and discarded into message text, so the linter scored a
  **repaired** `redeemCollateral(boldAmt)` exactly as loudly as the defective
  `redeem(u, boldAmt)` — it could not tell a defect from its own repair. Split
  into **D4a** (keys state: told WHICH element) and **D4b** (exogenous quantity).
- `keyed` was always false anyway: the body regex terminated on the first nested
  `val`, and `val t = troves.get(u)` is typically the first line of the body.
  Replaced with a bounded character window.
- `keyed` was then computed once per *action* but attributed per *argument*, so
  in `startAuction(u, sid)` the integer `sid` was reported as D4a because `u`
  keys. Now decided per argument by positional binding.

Verified after all three: v1 `liquity` reports **2 x D4a**, v2 `liquity` reports
**1 x D4b**, the pilot stays clean, and `startAuction` splits `u` -> D4a,
`sid` -> D4b.

---

## Pass 7 — independent re-verification of the Phase 2 artifacts

Everything below was re-run rather than read off the prior record.

**Confirmed as claimed.**

| claim | command | result |
|---|---|---|
| 13/13 v2 specs typecheck | `quint typecheck *.qnt` | 13 OK |
| lint 5 findings / 13 files | `respec_lint.py *.qnt` | 5 (apex D4a, derive D4a+D4b, liquity D4b, polymarket D4a) |
| curve invariants hold | `quint run curve.qnt --invariant=inv_all --max-steps=20 --max-samples=2000` | `[ok]`, 3317 traces/s |
| K=8 truncates at 10^6 | `evidence/curve_k.py` | worst converging 12 iters at (214396, 1); 97 of 4900 over K=8 |

**Gate 2.1c — W1's curve carry-in is closed, and the roadmap's own recommendation
was the wrong question.** This roadmap told W1 to either cap curve at 10^5 or
raise K >= 12. The shipped spec did neither, and is nonetheless sound: the K=8
unrolling **refuses rather than approximates**. `newtonDFull` carries the `done`
flag, every action conjoins the convergence of the state it leaves and the state
it enters (`addLiquidity` guards all three of `st0/st1/st2`; `exchange*` guards
`st`, `sy` and `after`), and `inv_dConverged` re-asserts it at every reached
state. A converging-but-slow pair therefore costs a *transition*, not a *value*.
That is an (E<=) restriction, which `P2-FIDELITY` permits and which the spec
declares.

The general lesson, since this phase collects them: **"the bound is too small"
and "the spec is unsound" are different claims, and the second does not follow
from the first when the unrolling carries a termination flag.** The roadmap
asserted the second from the first.

**Correction found while closing it.** `curve.qnt:79` declares "36 of 4900
balance pairs never break". The pairs the `done` guard actually refuses on
`curve_k.py`'s uniform 10^6 grid number **117 of 4900** — 20 non-converging plus
97 needing more than 8 iterations (`evidence/curve_refused.py`, new). The
populations are genuinely different — the spec means its own reachable grid, the
sweep means a uniform one — but **both are 4900**, so the figures are trivially
confusable and one of them is silently the wrong denominator for the other's
claim. Carried into TODO as a disambiguation item.

**The one real gap: W2 has no delivery record.** `P2-SCOPE` §110 assigns
`compound_v3`, `morpho_blue` and `gmx` to W2. All three specs are present,
typecheck, and are substantive rather than thin —

| spec | T0 refs | `wit_*` | `inv_*` |
|---|---|---|---|
| compound_v3 | 50 | 18 | 7 |
| morpho_blue | 41 | 19 | 7 |
| gmx | 48 | 16 | 7 |

— comparable to W1, W3 and W4 on every column. But this roadmap has a
"W1 delivered", a "W3 and W4 delivered" and **no W2 section**, so three of the
ten protocols carry no recorded corrections. Every other lane produced
load-bearing ones: W1 five, W3/W4 seven, the pilot two. A lane that produced zero
is not a lane that found nothing; it is a lane nobody wrote down. **2.1b must not
be marked closed, and 2.3 must not be run, until W2's three specs get the same
cold read the others got.**


---

## Gate 0.1 — resolved, and `|P| = 4` is withdrawn

Full argument and reproduction in `sigma/QSIGMA-VERDICT.md`. Three points.

**The gate was FAILED for a harness bug, not a fact about the corpus.** The
"three good-faith operationalisations" were two — `qsigma3.py` is byte-identical
to `qsigma2.py` but for its output filename — and both scanned `init`, whose
literal assignments are replacements by construction, so `Q` collapsed to empty
before any protocol was consulted. Excluding the initialiser makes the partition
non-trivial immediately. Seven passes restated "gate 0.1 remains FAILED" without
re-running it.

This is the mirror of the phase's recurring trap. There: *a check passes because
the stressing states were removed.* Here: **a check fails because states that
were never in scope were included.** Both are the harness deciding the answer.

**The partition is real and does not mean what the basis needs.**

| | Q | Sigma | balances in Q | prices in Sigma |
|---|---|---|---|---|
| qsigma2/3 (init included) | 0 | 388 | 0.0% | 0.0% |
| qsigma4 (init excluded) | 300 | 88 | 86.0% | 42.9% |
| qsigma5 (+ binding resolution) | 334 | 54 | **95.5%** | **36.5%** |

The balance axis is sharp. The price axis fails, because accrual indices
(`liquidityIndex`, `variableBorrowIndex`, `baseSupplyIndex`, `rateMul`, …) evolve
multiplicatively from their own prior value. They are **exogenous in provenance
and endogenous in update form**, and no syntactic test on assignment form
separates provenance. That is the finding, not an artifact to tune away.

**`BASIS.md`'s own witness refutes it.** The claim is argued from USDT's reserve
"moving only in lockstep", citing `L6/usdt.qnt:51,68`. The variable is also
assigned at `:157` — `reserve' = newReserve` in `attestReserve`, commented at
`:148` as *external*, with the spec recording at `:191` that `inv_reserve_covers`
fails when that action is in `step`. A wholesale overwrite by an external writer
is `BASIS.md`'s own definition of a `Sigma`.

**Consequence for the roadmap.** Phase 1 is unblocked, and unblocked *without*
`|P| = 4`. 1.1 proceeds on the independent ~16-family estimate, which never
depended on the six-sort split. The replacement/update partition is available to
1.1 as a candidate law about update form, on the same terms as any other family:
at least two corpus witnesses and a law that fails for its neighbours.
