# Hardening the convex-geometry result

Run 2026-08-04. Reproducible from `/root/DefiElements/formal/v2` with `node <file>.mjs`.
New files: `digraph.mjs`, `antiexchange2.mjs`, `exhaustive.mjs`, `composition.mjs`
(+ `.out` transcripts). Nothing outside `formal/v2/` and `lean/` was modified.

---

## Headline

1. **Anti-exchange survives, and is no longer a conjecture on a bound.** It is a
   *theorem* covering all `2^58` subsets, because `Cn` is reachability in a
   **15-arc, depth-1 DAG** and that DAG has no directed cycle. `conj:convex` in
   `atlas.tex` should be promoted to a proposition with a two-line proof.
2. **`ex` is compositional**, by the explicit local formula
   `ex(Cn(A u B)) = min_<=( ex(A) u ex(B) )`. Proved, formalised in Lean, and
   measured with zero failures.
3. **The object is far smaller than the paper implies.** The definite fragment is
   15 arcs over 58 elements; **38 elements are completely inert**; sources and
   targets are disjoint so the poset has **height 1**. See "What the structure
   actually is". The theorem is stronger than the measurement; the *object* is
   weaker than the prose.
4. **A methodological defect was found and fixed mid-run** (degenerate RNG). See
   "Errata".

---

## 0. Reproduction of the existing result

```
$ node antiexchange.mjs
ground set: 58 elements
closed sets tested: 1697 (from all singletons and pairs)

anti-exchange premises found: 22585
VIOLATIONS: 0

unique minimal generator: 1696 closed sets; NON-unique: 0
```

Exact match with `atlas.tex` Measurements `meas:antiexchange` / `meas:unique`.
The starting point is sound.

---

## B (taken first, because it dissolves A). The structure

### B.1 Cn is a digraph reachability closure

`cl()` fires a law when **any** subject is present, then adds each definite
(single-alternative, non-external) consequent. That is a set of rules `s -> e`
with one element on each side, i.e. a set of **arcs**.

> **Theorem 1 (additivity / reachability).** If every rule is `s -> e`, then
> `Cn(S) = union of R(s) for s in S`, where `R(s)` is reachability from `s` in the
> digraph `D` of the rules. In particular `Cn` is **additive**:
> `Cn(A u B) = Cn(A) u Cn(B)`.

Verified, not assumed. `digraph.mjs` compares `reach()` against the original
`cl()` on the empty set, every singleton, every pair, and 20,000 random seeds:

```
$ node digraph.mjs
elements: 58
arcs (with multiplicity over laws): 16
distinct arcs: 15
self-loops: 0 []
arcs whose endpoint is outside MECH (dropped): 0

cl == reach agreement: 21712/21712  (mismatches: 0)
SCCs: 58  (nontrivial, size>1: 0)
mutually-reachable distinct pairs: 0 []

=> digraph is ACYCLIC up to self-loops.

arcs:
  L1: Pl->Ct Im->Ct Cd->Ct Pf->Ct Op->Ct
  L3: Uc->Aw Uc->At
  L4: Pf->Ex Pf->Ct Pf->Li
  L5: Py->Ep Py->Rd
  L19: Of->Xm Of->Xf
  L20: Rl->Au
  L21: Gs->Au
```

Additivity independently re-checked on 100,000 random pairs in `exhaustive.mjs`:
`failures=0`.

### B.2 The general theorem, and the answer to the question posed

Question: *if every rule has the form `s -> e`, is the induced closure always
anti-exchange?*

> **Answer: NO, not in general.** But it is governed by one cheap decidable
> criterion, and our instance satisfies it.

> **Theorem 2 (characterisation).** Let `Cn` be the reachability closure of a
> digraph `D` on `E`. The following are equivalent:
> * (a) `Cn` satisfies anti-exchange;
> * (b) no two **distinct** vertices are mutually reachable (every SCC is trivial);
> * (c) the reachability preorder `<=` is a **partial order**.

*Proof.*
(b) => (a). Let `A` be closed, `x != y`, with `x,y` not in `A`. By Theorem 1,
`Cn(A u {y}) = A u R(y)`. The premise `x in Cn(A u {y})` with `x` not in `A` gives
`x in R(y)`, i.e. `y <= x`. If the conclusion failed then `y in Cn(A u {x}) = A u R(x)`,
and `y` not in `A` gives `x <= y`. Then `x,y` are distinct and mutually reachable,
contradicting (b).

(a) => (b). Suppose `x != y` are mutually reachable. `{}` is closed
(`Cn({}) = {}`, since no rule has an empty antecedent) and `x,y` are not in `{}`.
Then `x in R(y) = Cn({y})` and `y in R(x) = Cn({x})` -- exactly a failure of
anti-exchange at `(A,x,y) = ({},x,y)`. QED

So the intuition in the brief was right in shape and needed one correction:
definite closures are *exactly* digraph reachability closures, but they are
**not** automatically anti-exchange. The rule set `{a->b, b->a}` is definite and
its closure fails anti-exchange at `A = {}`. What is true is that anti-exchange
is **equivalent** to acyclicity of the rule digraph -- a linear-time check, not a
search. **This is the statement that belongs in the paper**: it explains the
measurement rather than recording it, and it names exactly what would break the
result.

Our `D` is acyclic, so `(E, Cn)` **is** a convex geometry on all of `2^58`.

### B.3 Corollaries

> **Theorem 3.** Under (b), for closed `A`, `ex(A) = min_<=(A)`, and it is the
> unique **minimum** (not merely minimal) generator: `Cn(ex(A)) = A`, and `ex(A)`
> is a subset of **every** `G` with `Cn(G) = A`.

Hence `ex` is a bijection between closed sets and antichains of `(E,<=)`, and
`Fix(Cn)` is the lattice of up-sets of `(E,<=)`. That re-derives for free two
separately-measured facts: the definite fragment is **distributive** (up-set
lattices are), and the corresponding family is **accessible / an antimatroid**.

---

## A. Break it or bound it

Run anyway against the **original cl() verbatim** -- no digraph shortcut -- so
this is an independent check on Theorem 2, not a restatement of it.

```
$ node antiexchange2.mjs
T0 empty+singletons                seeds=    59  closedSets=    59  premises=     833  VIOLATIONS=0
T1 all pairs (original bound)      seeds=  1653  closedSets=  1648  premises=   21865  VIOLATIONS=0
T2 ALL triples                     seeds= 30856  closedSets= 30547  premises=  381596  VIOLATIONS=0
T3 random |S|=4..12 (40k)          seeds= 40000  closedSets= 39966  premises=  369891  VIOLATIONS=0
T4 real protocol sets (68)         seeds=    68  closedSets=    68  premises=     707  VIOLATIONS=0
T5 adversarial (subject-saturating) seeds= 14486  closedSets= 13153  premises=  123149  VIOLATIONS=0

--- summary ---
total closed sets tested (with overlap): 85441
total anti-exchange premise instances : 898041
total VIOLATIONS                      : 0
```

T5 (adversarial) is: the full subject set; the subjects of all disjunctive laws;
all of `E`; every pair of subjects; the subject list of each law; every
(subject, element) pair; all 58 co-singletons; and all 4-subsets of the subject
set. Only the 10 subject elements can force anything, so saturating them is the
strongest available stress.

**No counterexample at any tier.** T4 found 68 distinct element-sets, not 72:
four of the 72 protocols duplicate the element set of another exactly.

### A2. Exhaustive, not sampled

`Cn` is additive and 38 of 58 elements are inert, so the lattice factorises: a
closed set is (a closed subset of the 20 *active* elements) u (an arbitrary
subset of the 38 inert ones). Enumerating all closed subsets of the active 20,
with `x,y` ranging over **all 58**, is therefore a complete check of the whole
lattice.

```
$ node exhaustive.mjs
sources=10 Pl,Im,Cd,Uc,Pf,Op,Py,Gs,Rl,Of
targets=10 Ct,Li,Ex,At,Ep,Au,Xm,Xf,Rd,Aw
source n target = 0  -> DAG depth = 1
active=20  isolated=38

additivity cl(AuB)=cl(A)ucl(B): 100000/100000 tested, failures=0
closed subsets of the active 20: 52500
EXHAUSTIVE premise instances: 202000   VIOLATIONS: 0

TOTAL closed sets in the full lattice = 52500 * 2^38 = 14431090114560000
(the published bound of 1,697 covers 1.1759333401208832e-11 % of it)
```

> **Largest bound at which anti-exchange holds: all of it.** All
> `1.443 x 10^16` closed sets, machine-checked exhaustively (modulo the verified
> factorisation) and proved outright by Theorem 2. **No counterexample exists.**

---

## What the structure actually is -- the deflationary part

Put this in front of the author before the paper claim goes out.

* The definite fragment is **15 arcs from 7 laws** (L1, L3, L4, L5, L19, L20, L21).
  The other laws contribute nothing definite.
* Sources and targets are **disjoint** (`source n target = 0`), so the DAG has
  **depth 1**. `Cn` reaches its fixed point in one iteration. Every closed set is
  `S` plus the immediate consequents of `S`.
* **38 of 58 elements are inert** -- they neither force nor are forced.
* `Ct` is forced by five different elements, `Au` by two, everything else by one.
* So `ex(A)` is "A minus the elements that some other member of A directly
  forces". The canonical form is genuine and well defined, but it is a *one-step*
  redundancy strip, not a deep normal form.
* The 1,697 closed sets in the current measurement are essentially 1,697
  *seeds*: a random pair is closed already, or becomes closed after one addition.
  The number sounds like coverage and is not.

None of this makes the theorem false. It makes the sentence "every protocol has a
canonical form" weaker than it sounds: the canonical form differs from the
element set of the protocol only when the protocol contains one of 10 elements
together with one of its at-most-3 immediate consequents. **Recommend the paper
state the arc count and the depth explicitly.** The honest headline is not "the
atlas has a convex geometry" but "the definite fragment is the up-set lattice of
a height-1 poset with 15 covering relations, hence a convex geometry" -- a proof
rather than a conjecture, and worth more for being small and certain.

---

## C. Lean formalisation

`/root/DefiElements/lean/Defialgebra/ConvexGeometry.lean`, 386 lines, 24
declarations, wired into `Defialgebra.lean`.

```
$ cd /root/DefiElements/lean && lake build
...
Build completed successfully (732 jobs).
EXIT=0
$ grep -n "sorry\|admit" Defialgebra/ConvexGeometry.lean
352:on strictly fewer). No `sorry`, no new axioms.      <- docstring prose only
```

Definitions (ASCII rendering here; the file uses real unicode):

```
def AntiExchange (c : ClosureOperator (Finset E)) : Prop :=
  forall A, c A = A -> forall x y, x notin A -> y notin A -> x != y ->
    x in c (insert y A) -> y notin c (insert x A)

def ex (c : ClosureOperator (Finset E)) (A : Finset E) : Finset E :=
  A.filter (fun a => a notin c (A.erase a))
```

Abstract results. These hold for **any** anti-exchange closure operator on a
finite carrier, with no reachability assumed:

```
theorem ex_subset_of_generates (c) {A G} (h : c G = A) : ex c A subset G
theorem maximal_closed_gap2 (c) (hae : AntiExchange c) {A C} ... : exists x, A \ C = {x}
theorem closure_ex (c) (hae : AntiExchange c) {A} (hA : c A = A) : c (ex c A) = A
theorem unique_minimum_generator (c) (hae : AntiExchange c) {A} (hA : c A = A) :
    exists! G, c G = A and forall G2, c G2 = A -> G subset G2
```

Theorem 2, **both directions**, as an iff:

```
def reachSet (S : Finset E) : Finset E :=
  Finset.univ.filter (fun x => exists s in S, Relation.ReflTransGen r s x)
def reachCl : ClosureOperator (Finset E) := <reachSet r, ...>

theorem reachCl_antiExchange_iff :
    AntiExchange (reachCl r) <->
      forall x y, Relation.ReflTransGen r x y -> Relation.ReflTransGen r y x -> x = y
```

And the composition law:

```
theorem ex_reachCl (A) : ex (reachCl r) A =
    A.filter (fun a => forall b in A, Relation.ReflTransGen r b a -> b = a)

theorem ex_reachCl_union (A B) : ex (reachCl r) (A union B) =
    (ex (reachCl r) A union ex (reachCl r) B).filter
      (fun a => forall b in (A union B), Relation.ReflTransGen r b a -> b = a)
```

`#print axioms` on all 24 declarations (a `section AxiomAudit` at the end of the
file) is uniform:

```
depends on axioms: [propext, Classical.choice, Quot.sound]
```

No `sorryAx`, no custom axioms. `Classical.choice` enters through mathlib, not
through anything stated here; `reachSet` is itself computable
(`[DecidableRel (Relation.ReflTransGen r)]`, not `Classical.dec`).

**Honest gap.** `ex_reachCl_union` filters over `A union B`. The paper-facing form
of Theorem 4 filters over `ex A union ex B` only. The two coincide for closed
`A,B` (the extra comparisons are redundant), but that reduction is **not proved
in Lean**. It is a short additional lemma and it is not currently there.

---

## D. Composition

### D.0 A triviality that must be cleared first

`ex` is a bijection between closed sets and antichains (Theorem 3). So the
literal question "is ex(Cn(A u B)) computable from ex(A) and ex(B) alone?"
answers *yes* vacuously: `ex(A)` determines `A`, so **every** function of `(A,B)`
is a function of `(ex A, ex B)`. That is not a result.

The non-vacuous claim is that the computation is **local**: a formula in the
ambient order using only pairwise comparisons, with no closure computation.

### D.1 The theorem

> **Theorem 4 (composition).** For closed `A,B`:
> `ex(Cn(A u B)) = min_<=( ex(A) u ex(B) )`.
> In particular `ex(Cn(A u B))` is a subset of `ex(A) u ex(B)` -- the **subset
> law**: composition never invents a new extreme point.

*Proof.* By additivity `Cn(A u B) = A u B`.
(subset) Let `a in min(A u B)`, say `a in A`. Nothing in `A` is strictly below
`a`, so `a in ex(A)`; and `a` minimal in the larger set `A u B` is minimal in the
subset `ex(A) u ex(B)`.
(superset) Let `a in min(ex A u ex B)` and suppose some `b in A u B` has `b < a`.
Take `b` minimal in `A u B` with `b <= a`; by the first part `b in ex(A) u ex(B)`,
and `b < a` contradicts minimality of `a` in `ex(A) u ex(B)`. QED

This is the join of antichains in the up-set lattice, transported through `ex`.
Composition on canonical forms costs `O(|ex A| * |ex B|)` comparisons and no
closure work.

### D.2 Measurement

```
$ node composition.mjs
=== (1) reduced ground sets, EXHAUSTIVE over all closed sets AND all pairs ===
reduced |E|=8    closed=   84 pairs=   7056(EXHAUSTIVE) ex-gen-fail=0 ex-inj-fail=0 FORMULA=7056/7056 subset-law=7056/7056
reduced |E|=11   closed=  350 pairs= 122500(EXHAUSTIVE) ex-gen-fail=0 ex-inj-fail=0 FORMULA=122500/122500 subset-law=122500/122500
reduced |E|=16   closed= 5625 pairs= 600000(sampled)    ex-gen-fail=0 ex-inj-fail=0 FORMULA=600000/600000 subset-law=600000/600000

=== (2) the ACTIVE 20 of the real atlas ===
active-20        closed=52500 pairs= 600000(sampled)    ex-gen-fail=0 ex-inj-fail=0 FORMULA=600000/600000 subset-law=600000/600000

=== (3) full 58, sampled closed sets ===
58-element       closed= 1500 pairs= 400000(sampled)    ex-gen-fail=0 ex-inj-fail=0 FORMULA=400000/400000 subset-law=400000/400000

=== (4) RANDOM DIGRAPHS: is the formula general, or about our instance? ===
random DAG n=8 p=.15     graphs=40 (nontrivial SCC: 0)   ex-generates-fails=0   formula=379044/379044 = 100.0000%
random DAG n=9 p=.35     graphs=40 (nontrivial SCC: 0)   ex-generates-fails=0   formula=61296/61296 = 100.0000%
random DAG n=10 p=.20    graphs=40 (nontrivial SCC: 0)   ex-generates-fails=0   formula=1145603/1145603 = 100.0000%
random CYCLIC n=7 p=.20  graphs=40 (nontrivial SCC: 30)  ex-generates-fails=63  formula=11409/11755 = 97.0566%
random CYCLIC n=7 p=.35  graphs=40 (nontrivial SCC: 39)  ex-generates-fails=52  formula=964/1062 = 90.7721%
```

Block (4) is the control, and it is the reason to believe the rest. The formula
is checked on **random digraphs**, not only ours, so the claim is about the
*shape* of the closure. On acyclic random digraphs it holds universally
(1,585,943 of 1,585,943). On **cyclic** random digraphs it fails -- as it must,
since `ex` is not even well defined there: a nontrivial SCC has no minimal
element, so `Cn(ex A) != A` (`ex-generates-fails` = 63 and 52). The test can fail,
and what buys the result is exactly acyclicity, i.e. Theorem 2(b).

### D.3 Answer

> **Yes, ex is compositional**, by the explicit local formula
> `ex(A join B) = min(ex A u ex B)` -- proved (Theorem 4), formalised (Lean
> `ex_reachCl_union`, modulo the gap noted in C), and measured with zero failures
> exhaustively on reduced ground sets of 8 and 11 elements and on 1.6M sampled
> pairs at larger scale.
> Caveat: this is compositionality **for the definite fragment only**. `Gamma`,
> the disjunctive part, is not additive, has no such canonical form, and nothing
> here extends to it. That is the same boundary R5/R7 already record.

---

## Errata: a defect in this run, found and fixed

The first version of `antiexchange2.mjs` / `exhaustive.mjs` / `composition.mjs`
used the LCG `seed = (seed*1103515245 + 12345) & 0x7fffffff`. In JavaScript the
multiply exceeds `2^53` and loses low bits, so the generator degenerates:
**14,469 distinct values in 200,000 draws**. Every *sampled* tier was therefore
drawing from a far smaller effective pool than reported. The symptom that
exposed it: `composition.mjs` block (3) hung, because a `while (distinct < 1500)`
loop could not reach 1500.

Replaced with mulberry32 (`Math.imul`-based): **199,989 distinct in 200,000**,
mean 0.4993. All numbers above are from the re-run. Effect of the fix, for
calibration: `antiexchange2` tier T3 went from 1,640 distinct closed sets to
**39,966** (and from 15,386 to 369,891 premise instances) -- still zero
violations.

**No conclusion changed**, because every load-bearing result here is either
exhaustive enumeration (all triples; all 52,500 closed sets of the active 20;
all closed sets and all pairs at |E| = 8 and 11) or a proof. Recorded because
the same LCG idiom appears elsewhere in `formal/v2` and should be replaced there
too.

## Variants tried (per the no-tuning rule)

None. The closure was not modified. `cl()` in `antiexchange2.mjs`,
`exhaustive.mjs` and `composition.mjs` is identical to the one in
`antiexchange.mjs`. `digraph.mjs` exists specifically to *verify* that the
digraph reformulation agrees with `cl()` rather than to replace it; agreement is
checked on 21,712 seeds.

## What would break this

* Any new **definite** law whose arc closes a directed cycle. Anti-exchange dies
  immediately at `A = {}` by Theorem 2. `node digraph.mjs` is the check, and it
  should become a regression test.
* A law with a **conjunctive** antecedent (`s1 and s2 -> e`). That leaves the
  reachability class entirely; Theorem 1 fails and everything above with it. All
  current laws are disjunctive in the antecedent, which is why "fires if any
  subject present" yields unary rules.
