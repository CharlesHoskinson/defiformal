# Requirements from order theory, lattice theory and closure systems

## 0. Position in one paragraph

The convex geometry is correct and it is thin, but its thinness has a *cause*, and
the cause is not DeFi. I recomputed the definite digraph `D` from the published
requirement table: **18 distinct subject-headed singleton-term arcs**, sources
`{Pl,Im,Cd,Pf,Op,Uc,Py,Tr,Xf,Up,Of,Rl,Gs}`, targets
`{Ct,Aw,At,Ex,Li,Ep,Rd,Sv,Xm,Tg,Xf,Au}`. Sources and targets meet only in `Xf`, so
`(E,≼)` has **height 2** — one 2-chain (`Of ≽ Xf ≽ Xm`) and 15 height-1 arcs, on a
poset that could carry height 57. That is the whole of the thinness. The reason is
not that requirements are few: it is that a requirement *term of width > 1
contributes no arc at all*. A closure system sees implications; it is blind to
disjunction. And the 24 non-empty terms in that table are, by direct check,
**23/24 contained in a single group `G01–G16`** — and of the 8 genuinely
disjunctive terms, **7/8** are single-group, several being a full group cell minus
the elements the same row names separately (`(Sh|Ix|Rb) = G01` exactly;
`(Li|Ad|Sl|Bs) = G06∖{Ct}` in a row that pins `Ct`; `(Ex|Tp|At) = G08∖{Oa}`;
`(Rd|Ps) = G13∖{As}`). The disjunctions are not disjunctions. They are **sort
annotations misread as choices**. The requirement is therefore: lift to a
two-sorted closure system over `E ⊎ G`, in which every one of those terms becomes
an implication with a singleton premise, `D` roughly doubles from the *same table*,
and completing the 15 empty rows takes it to the informativeness threshold I
quantify in §3. The 15 arcs are the shadow of a sorted base under the forgetful
functor that erases sorts.

## 1. Carrier and signature

**Sorts.** Two: `E` (58 mechanism atoms) and `G` (16 groups), with a total sort map
`g : E → G`. Optionally a third sort `Π` of parties (§6). The stratum `σ : E → {0..4}`
is *not* a sort; it is a filtration (§6, PO-ORD-9).

**Signature.** An implication base `Σ` over `E ⊎ G` in which **every premise is a
singleton**. This is not stylistic: by Caspard–Monjardet (*Some lattices of closure
systems on a finite set*, 2004, §3) singleton premises force the induced closure
system to be **union-stable**; by Edelman–Jamison (*The theory of convex geometries*,
1985, Thm 3.2) a union-closed alignment is a convex geometry iff it is the down-set
alignment of a poset; and by Edelman (1980, Thm 3.3) that is equivalent to the
closure lattice being **meet-distributive**. Singleton premises are exactly the
price of keeping the good theorems, so they are a *requirement on the signature*,
not an observation about the data.

**Carrier.** A protocol is **a closed set of the sorted closure system**, presented
by its unique minimal generator. Formally `Prot = O(E ⊎ G, ≼)`, the lattice of
down-sets of the specialization order of `Σ`; by Birkhoff's representation theorem
this is a distributive lattice whose join-irreducibles are exactly the principal
down-sets `↓x`, i.e. the atoms of the vocabulary. **Not** "a subset of `E`": a
subset is a presentation, a down-set is the object, and `ex(X) = max_≼(X)` is the
normal form. Meet-distributivity is what makes `ex` well-defined and unique.

**Row completeness (formalization discipline).** A requirement row `L` is *complete*
iff (i) its subject column is a non-empty set of named atoms; (ii) every term `T_j`
is a non-empty subset of `E`; (iii) every `T_j` satisfies `|g(T_j)| = 1`, so that
`L` translates to the implications `s → γ_j` for `s` a subject and `γ_j = g(T_j)`;
(iv) `L` is machine-evaluable by a fixed evaluator against any `X ⊆ E`. Prose is
not a constraint. `[ext]` is not a term. A row failing (iii) is not rejected — it
is a **refinement demand** on `G` (PO-ORD-4).

## 2. Composition

`A ⊕ B := Cn(A ∪ B)`, which under union-stability is `A ∪ B` for closed `A,B`. On
`Prot` this is the lattice **join**: total, closed, associative, commutative,
idempotent, by construction of the carrier and not by measurement. The prior
work's `ex(A ⊕ B) = max_≼(ex A ∪ ex B)` is then the statement that `ex` is a join
homomorphism onto the antichain representation; it is near-union today only
because `max_≼` deletes nothing when `ι` (§3) is 1%.

Prohibitions do not live in the carrier. They are a **clutter** `X` of forbidden
configurations, and `Adm = {A ∈ Prot : ∀H ∈ X, H ⊄ A}`. Requirement:

> **(R-SAT)** Every prohibition is `≼`-saturated: `H = Cn(H)`. Then `armed(·)`
> factors through `Cn`, and `Adm` is a **union of `≼`-intervals** in `Prot`, hence
> **order-convex** (`A ⊆ C ⊆ B` with `A,B ∈ Adm` ⟹ `C ∈ Adm`).

Order-convexity is precisely the object the brief asks for. Admissibility is closed
neither upward nor downward — nor should it be; upward-closed is trivial and
downward-closed is a simplicial complex. The correct demand is the *conjunction of
the two failures*: an **order-convex subfamily of a meet-distributive lattice**,
which is exactly a union of intervals `[gen, Cn(gen)]`, and each interval is itself
a Boolean lattice. Construction inside an interval is free.

Composition of *protocols into a family* is partial, and its exact side condition
is `Cn(A∪B)` arming no member of the clutter. The pairwise-safe family is a graph;
the safe families are its **clique complex**, a flag simplicial complex. Flag
complexes are down-closed, hence **accessible**: safe families can always be grown
one protocol at a time. This converts the prior "maximum clique" remark from a
hardness note into the structural guarantee that incremental assembly never dead-ends
below a maximal safe family.

**Accessibility on the admissible side.** The recorded witness — `{Ex,Op}` admissible,
neither singleton admissible — is a **warrant 2-cycle**: `Op ∈ consumers(Ex)` and
`Ex ∈ consumers(Op)` in the published warrant table. Warrant-admissibility is
`X ⊆ W(X)` where `W(X) = {e : C_e ∩ X ≠ ∅}` is monotone, so warrant-admissible sets
are the **post-fixpoints of a monotone map on a complete lattice**: a complete
lattice by Knaster–Tarski, hence union-closed, and *never* accessible when `W` has a
cycle. So the two facts are one fact, and the fix is granularity:

> **(R-SCC)** The quantum of construction is a strongly connected component of the
> warrant digraph, not an element. On the condensation — a DAG — warrant-admissible
> sets are exactly the down-sets, i.e. the feasible sets of the **poset shelling
> antimatroid** of Korte–Lovász. That family is accessible, union-closed, and greedy.

Non-accessibility is thereby localized to a computable invariant: `maxSCC`, the
largest warrant SCC. `maxSCC = 1` ⟺ element-wise accessibility. Report it; do not
re-derive the counterexample.

## 3. Completeness theorem (formal statement)

Let `L = O(E ⊎ G, ≼)` be the closure lattice of a complete base `Σ`.

> **Theorem (target).** `P ⊆ E` is *complete* iff `Cn(P) = E ⊎ G`, and
> `Cn(P) = ⊤` iff `P ⊄ M` for every coatom `M` of `L`. In the down-set lattice of a
> poset the coatoms are exactly `E ∖ {m}` for `m` maximal in `≼`. Hence
> **`P` is complete iff `P ⊇ Max(≼)`, and the minimum complete set is `Max(≼)`, uniquely.**

This is the exact analogue of Post's completeness criterion (Post 1941: a set of
Boolean functions is complete iff contained in no maximal clone, of which there are
five). Here the maximal clones are the coatoms of the closure lattice, they are
finite in number and *enumerable in linear time*, and the completeness certificate
is a membership check. Falsification: exhibit a corpus application whose element
set is not in `Cn(P)` — i.e. an atom outside `↓P`.

**The density requirement, stated exactly.** Today `|Max(≼)| = 58 − 12 = 46`: the
minimum complete primitive set is 46 of 58, and the theorem is nearly vacuous.
Density is what shrinks it. Define comparability density `ι = |≺| / C(n,2)` and
absorption `α = E[(|ex A| + |ex B| − |ex(A⊕B)|)/(|ex A| + |ex B|)]` over corpus pairs.

- Now: `ι = 18/1653 = 1.1%`, `height(≼) = 2`, `α ≈ 0`, `|Max| = 46`.
- Sorting alone (§1, no new formalization): the same table yields ≈32 sorted arcs,
  `ι ≈ 1.2%` on 74 vertices but `height ≥ 3`.
- Completing the 15 empty and 7 partial rows at the observed rate (≈3.3 terms/row,
  ≈1.4 subjects/row) yields ≈110–150 arcs.
- **Informativeness threshold.** Corpus protocols carry ~20 atoms; a random 20-set
  contains `190ι` comparable pairs; absorbing half of `ex` needs ≈10 usable
  relations inside it, so `ι ≳ 0.053` as a floor and `ι ≥ 0.10` allowing for
  unusable ones. **Require `ι ≥ 0.10`, `height(≼) ≥ 4` (matching the five strata),
  `α ≥ 0.35`, `|Max(≼)| ≤ 25`.** `ι = 0.10` on 58 vertices is ~165 comparable
  pairs — i.e. **the completed table lands exactly on the threshold.** The base is
  not far from informative; it is one finished table away.

**What "canonical" means for a DeFi implication base.** The target object is the
**Guigues–Duquenne canonical basis** (Guigues & Duquenne 1986): for a finite closure
system, the unique minimum-cardinality complete implicational base, whose premises
are the pseudo-closed sets. Canonicity here requires five conditions: (a) *sound* —
no counterexample among the 60; (b) *complete* — every implication valid in the
intended domain is entailed; (c) *minimum* — cardinality-minimal, hence the DG
basis, hence unique; (d) *unit and direct* — I additionally require the **canonical
direct unit basis** (Bertet–Monjardet 2010; Adaricheva–Nation–Rand, *Ordered direct
implicational basis of a finite closure system*), which is also unique and computes
`Cn` in a **single pass**, matching and actually justifying the O(k) composition
claim; (e) *row-complete* in the §1 sense. Note honestly: deciding pseudo-closedness
is coNP-complete (Kuznetsov 2004) and the DG basis is not enumerable with polynomial
delay in the lectic order unless P=NP (Distel–Sertkaya 2011). At `|E ⊎ G| = 74` and
60 objects this is irrelevant — the context is tiny.

**How to compute it from the 60 applications rather than hand-write it.** Build the
formal context `K = (60 applications × 74 sorted attributes)` and run **Ganter's
NextClosure** to get the stem base of `Imp(K)` (Ganter & Wille, *Formal Concept
Analysis*, 1999). That base is sound on the corpus by construction and requires no
hand-writing. It will over-fit: with 60 objects many implications hold by accident.
The remedy is the standard one and it is exactly the procedure for finishing an
unfinished table: **attribute exploration** (Ganter; Ganter & Obiedkov,
*Conceptual Exploration*, 2016). The algorithm proposes each candidate implication
in turn; the domain expert either accepts it as a law or supplies a counterexample
protocol, which is added to the context. It terminates with a base complete for the
*domain*, not the sample, and every rejected implication leaves behind a new object.
Accidental implications are separated from laws by attaching support/confidence
(Luxenburger 1991, partial implications) and refusing to promote anything with
support < 3 without an expert accept.

## 4. Construction / synthesis

**Problem.** Given a specification `S` (a set of obligations, each an atom or a sort
demand `γ ∈ G`), find a minimal `P₀ ⊆ E` with `S ⊆ Cn(P₀)` and `Cn(P₀) ∈ Adm`.

**Without prohibitions:** in a convex geometry the answer is unique and greedy —
`P₀ = max_≼(S)`, computable in `O(|E| + |Σ|)` with the canonical direct unit basis.
Uniqueness is meet-distributivity; this is the one place the convex geometry pays
off immediately.

**With prohibitions:** the problem becomes minimum transversal of the clutter
restricted to `↓S`, NP-hard in general, but the clutter is a handful of rows and
`|E| = 58`; brute force is instant. Blocker duality (Lawler–Lenstra–Rinnooy Kan,
Fulkerson) gives minimal repair for free.

**Certificate** that a construction discharges a spec — three parts, each checkable
in linear time: (1) `ex(P₀)`, an antichain; (2) a derivation forest in `D` from `P₀`
covering `S`, one arc per discharged obligation, labelled with its base row; (3) for
each `H ∈ X`, a witness element of `H ∖ Cn(P₀)`. Absence of any part is a rejection
with an address.

## 5. Disposition of the prior obstructions

- **"The convex geometry is thin."** *Localized to a degenerate fragment and
  measured.* Thinness = `height(≼)=2`, `ι=1.1%`, and its cause is width->1 terms
  contributing zero arcs. Sorting recovers 23 of 24 terms as implications. Invariants:
  `ι, α, height, |Max(≼)|`.
- **"Admissible sets are not accessible; not an antimatroid."** *Converted to an
  invariant.* It is a warrant SCC phenomenon; on the condensation the family is the
  poset shelling antimatroid, which is accessible. Invariant: `maxSCC`.
- **"Admissibility closed neither up nor down."** *Dissolved.* The right object is
  order-convexity, obtained from (R-SAT). `Adm` is a union of Boolean intervals.
- **"Composition not preserved (Uniswap ∪ Aave arms X2)."** *Localized.* Join is
  total on `Prot`; safety is a flag complex, down-closed and accessible. The prior
  statement is about `Adm`, not about the carrier.
- **"Kripke–Kleene fixpoint is `(⊥,⊤)`, carrying no information."** *Inapplicable.*
  We never iterate an operator from `⊥` over `2^E`. NextClosure enumerates closed
  sets in lectic order with polynomial delay per set; `ex` is computed from a
  presentation, never from the empty set.
- **"Bilattice diagonal unreachable; inflationary/deflationary pair forces the
  identity."** *Dissolved by change of ambient.* Both are theorems about a bilattice
  over `2^E`. `Prot = O(≼)` is a distributive lattice with a single order; there is no
  second order and hence no such pair.
- **"`Ct` is a consequence in every protocol and a primitive in none"; six perps
  venues omitting exactly `{Ct,Ex,Li}`.** *Promoted to evidence.* `Ct` has in-degree 5
  in `D` and out-degree 0 — it is a `≼`-minimum of its component. Six independent
  implementations agreeing on the same omitted principal down-set is a
  **replication of a poset relation**, and it is the strongest single datum that
  `≼` is real. It should be the seed of the attribute exploration.

## 6. Minimal viable enrichment (ranked by structural payoff / formalization cost)

1. **Sort the signature by group** (`E ⊎ G`, `g : E → G`). *Cost: nearly zero* —
   the group column already exists and 23/24 terms already comply. *Payoff:* every
   disjunctive term becomes an implication, `D` roughly doubles from the existing
   table, `height ≥ 3`, and all of Caspard–Monjardet / Edelman–Jamison survive
   verbatim because premises stay singletons. **Do this one.**
2. **`≼`-saturate the prohibitions** (R-SAT). Cost: one pass over 20 rows. Payoff:
   order-convexity of `Adm`, hence interval construction.
3. **SCC-condense the warrant digraph** (R-SCC). Cost: one Tarjan run. Payoff:
   accessibility, greedy construction, and `maxSCC` as the reported defect.
4. **Party sort, existentially encoded.** The prior work already proves the encoding
   preserves everything provided it records *that* a holder shape exists and not
   *which* — the mutual-exclusion clauses that would kill union-closure are exactly
   what the existential encoding avoids. Cost: moderate. Payoff: separates USDT/USD1.
5. **Magnitudes as a chain-valued grading** (`E → C` for a chain `C`, thresholds as
   implications into `C`). Highest cost, unlocks the 9 prose prohibition rows.
   Defer past this quarter.

**On the grading.** Stratum is **not** the rank function of `≼`, and I checked every
arc: 11 of 18 arcs join same-stratum elements (`Pl(3)→Ct(3)`, `Xf(4)→Xm(4)`,
`Up(4)→Tg(4)`, `Of(4)→Xm(4)`, `Rl(4)→Au(4)`, …), 6 strictly descend, and exactly one
**ascends**: `Gs(3) → Au(4)` (row L20/L21; `Gs` is the only stratum-3 member of the
stratum-4 group G11). Groups are not stratum-homogeneous either — G03 spans strata
{1,1,2,4}. So `(g, σ)` is a genuine **bigrading**, not a rank function, and the
correct claim is weaker and still useful: **`σ` is a filtration** `E_0 ⊆ … ⊆ E_4`
with `Cn(E_k) ⊆ E_k` for all `k` — which holds on 17 of 18 arcs with `Gs → Au` the
unique violation. One reassignment (`σ(Gs) := 4`) or one design reason makes the
filtration exact, and then induction on stratum is available for every proof about
`Cn`, and `height(≼) ≤ 4` becomes a *theorem* rather than a measurement. That is a
cheap and high-value repair.

## 7. Falsifiable near-term test

**The single-group test, then attribute exploration.** Days, not months.

*Input.* The 29-row requirement table, the 27-row warrant table, `g : E → G`,
`σ : E → {0..4}`, and the 60 applications' element sets.

*Procedure.* (1) For every non-empty term `T_j`, compute `|g(T_j)|`. (2) Report the
single-group rate `ρ = #{j : |g(T_j)| = 1} / #{j : T_j ≠ ∅}`. (3) Build the sorted
base `Σ_G` by replacing each single-group term with `s → g(T_j)`; recompute `D`,
`ι`, `height`, `|Max(≼)|`, `α` over the 60. (4) Build the 60×74 context and run
NextClosure for the stem base; run 50 rounds of attribute exploration seeded with the
`{Ct,Ex,Li}` perps replication.

*Verdict.* **Confirms** if `ρ ≥ 0.85` (my hand count on the published table gives
23/24 = 0.958, so this is a real prediction, not a tautology) **and** the sorted
`D` has at least 28 arcs and `height ≥ 3`. **Refutes** if `ρ < 0.6` — that would
mean the disjunctions are genuine choices, the group column is not the kernel of the
requirement relation, and sorting buys nothing. **Additionally refutes the whole
programme** if, after all 29 rows are completed by exploration, `ι < 0.05` — that
would establish thinness as intrinsic rather than as an artifact of the table.

*Bonus check, five minutes.* Reconcile the published arc count. I count **18**
distinct arcs from the published table; the paper states **15**. Three arcs are
unaccounted for in one direction or the other. Either count may be right; the
discrepancy is itself a row-completeness failure and must be closed before any
density number is trusted.

## 8. Named proof obligations

- **PO-ORD-1.** `(E ⊎ G, Cn_Σ)` with all premises singletons is union-stable
  (Caspard–Monjardet §3) and, if `D_Σ` is acyclic, a convex geometry
  (Edelman–Jamison Thm 3.2); prove acyclicity of `D_Σ` after sorting.
- **PO-ORD-2.** Reconcile the arc count: the published table yields 18 distinct
  subject-headed singleton-term arcs against a stated 15. Publish the arc list.
- **PO-ORD-3.** `ρ := #{single-group terms}/#{non-empty terms} ≥ 0.85`. Hand count
  on the published table: 23/24.
- **PO-ORD-4.** Every term with `|g(T_j)| > 1` (currently only `(Bs|Tr)`, L3) is
  either refined by splitting a group or admitted as a genuine cross-sort choice
  with a stated reason.
- **PO-ORD-5.** `Adm` is order-convex once every prohibition is `≼`-saturated
  (R-SAT); equivalently `Adm` is a union of intervals `[B, Cn(B)]` in `Prot`.
- **PO-ORD-6.** Warrant-admissible sets are the post-fixpoints of the monotone map
  `W(X) = {e : C_e ∩ X ≠ ∅}`, hence a complete lattice by Knaster–Tarski; and they
  are accessible on the SCC condensation, where they form the Korte–Lovász poset
  shelling antimatroid. Compute `maxSCC`.
- **PO-ORD-7.** `P ⊆ E` is complete iff `P ⊇ Max(≼)`; the minimum complete set is
  unique and equals `Max(≼)`. Currently `|Max(≼)| = 46`; target `≤ 25`.
- **PO-ORD-8.** The finished base attains `ι ≥ 0.10`, `height(≼) ≥ 4`, `α ≥ 0.35`.
  Below these the composition theorem is near-union and carries no information.
- **PO-ORD-9.** `σ` is a filtration: `Cn(E_k) ⊆ E_k` for `k = 0..4`. Holds on 17 of
  18 arcs; the unique violation is `Gs(3) → Au(4)`. Repair or justify.
- **PO-ORD-10.** The canonical direct unit basis of `Σ_G` (Bertet–Monjardet;
  Adaricheva–Nation–Rand) exists, is unique, and computes `Cn` in one pass — this,
  not the set identity, is what licenses the O(k) composition claim.
- **PO-ORD-11.** Attribute exploration over the 60×74 context terminates with a
  Guigues–Duquenne basis; every implication is either expert-accepted or killed by a
  counterexample protocol added to the context. Report the accept/counterexample ratio.
- **PO-ORD-12.** The existential party sort preserves union-closure; the *exact*
  holder-shape sort does not (its mutual-exclusion clauses are purely negative).
  Any party enrichment must be existential.
- **PO-ORD-13 (conjecture, "sorted density").** For a vocabulary whose constraint
  terms are single-sorted at rate `ρ`, the sorted specialization order has
  comparability density at least `ρ` times the term count over `C(n,2)`; hence
  finishing the 29 rows at the observed term rate yields `ι ∈ [0.07, 0.10]`.
