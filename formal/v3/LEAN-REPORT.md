# Lean 4 formalization report — v3 (targets T1–T4)

Repo: `/root/DefiElements`. Lean project: `/root/DefiElements/lean`.
Toolchain `leanprover/lean4:v4.33.0-rc2`, mathlib rev `v4.33.0-rc2`.

Files touched (all under `lean/`, nothing else in the repo modified):

| Path | Status |
|---|---|
| `/root/DefiElements/lean/Defialgebra.lean` | modified (added two imports) |
| `/root/DefiElements/lean/Defialgebra/Polarity.lean` | **new** (T1) |
| `/root/DefiElements/lean/Defialgebra/Lattice.lean` | **new** (T2) |
| `/root/DefiElements/lean/Defialgebra/ConvexGeometry.lean` | appended (T3, T4); nothing deleted |
| `/root/DefiElements/lean/Defialgebra/Obstruction.lean` | untouched |

## 0. Build

```
$ cd /root/DefiElements/lean && lake build
...
✔ [733/734] Built Defialgebra (845ms)
Build completed successfully (734 jobs).
=== EXIT: 0 ===
```

No `sorry`, no `axiom` declarations, no `native_decide` anywhere:

```
$ cd /root/DefiElements/lean && grep -rn "sorry\|^axiom \|native_decide" Defialgebra/ Defialgebra.lean
Defialgebra/ConvexGeometry.lean:352:on strictly fewer). No `sorry`, no new axioms.
```

(the single hit is prose inside a doc comment).

Every new declaration depends on at most the three standard Lean axioms
`[propext, Classical.choice, Quot.sound]`; several depend on strictly fewer.
There is **one** non-fatal warning in the whole build: a `push_neg` deprecation notice at
`ConvexGeometry.lean:476`.

---

## T1 — Polarity ⟹ union/intersection closure (`lem:polarity`, `thm:closure`)

**File:** `/root/DefiElements/lean/Defialgebra/Polarity.lean` — **VERIFIED**

Clauses are modelled as `structure Clause (E) where pos : Finset E; neg : Finset E`, with
`Sat X c := (∃ e ∈ c.pos, e ∈ X) ∨ (∃ e ∈ c.neg, e ∉ X)`,
`DualHorn c := c.neg.card ≤ 1`, `Horn c := c.pos.card ≤ 1`, `PureNeg c := c.pos = ∅`, and
`Models X S := ∀ c ∈ S, Sat X c`.

### `#print axioms` (verbatim from the build log)

```
'Defialgebra.Polarity.sat_union_of_dualHorn' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.sat_inter_of_horn' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.dualHorn_union_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.horn_inter_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.pureNeg_inter_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.horn_of_pureNeg' depends on axioms: [propext, Quot.sound]
'Defialgebra.Polarity.dualHorn_reqClause' depends on axioms: [propext, Quot.sound]
'Defialgebra.Polarity.pureNeg_prohClause' depends on axioms: [propext, Quot.sound]
'Defialgebra.Polarity.horn_prohClause' depends on axioms: [propext, Quot.sound]
'Defialgebra.Polarity.sat_reqClause_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.sat_prohClause_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.req_models_union_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.warrant_models_union_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.proh_models_inter_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.dualHorn_not_inter_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.req_not_inter_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.pureNeg_not_union_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Polarity.proh_not_union_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Content classification

| Theorem | Class | Justification |
|---|---|---|
| `sat_union_of_dualHorn` | **REAL (modest)** | Genuine four-way case split; the load-bearing step is collapsing two *distinct* negative witnesses via `Finset.card_le_one`, which is exactly where "at most one negative literal" is used. |
| `sat_inter_of_horn` | **REAL (modest)** | Same argument dualised; `Horn` is used to identify two positive witnesses. |
| `dualHorn_union_closed` | TRIVIAL | One-line pointwise lift of the clause lemma over a clause set (`fun c hc => …`). |
| `horn_inter_closed` | TRIVIAL | Ditto. |
| `pureNeg_inter_closed` | TRIVIAL | Composition of `horn_inter_closed` with `horn_of_pureNeg`. |
| `horn_of_pureNeg` | TRIVIAL | `card ∅ = 0 ≤ 1`. |
| `dualHorn_reqClause` | TRIVIAL | `card {s} = 1 ≤ 1` by `simp`. |
| `pureNeg_prohClause` | TRIVIAL | `rfl`. |
| `horn_prohClause` | TRIVIAL | Immediate from the previous two. |
| `sat_reqClause_iff` | **REAL (modest)** | The actual bridge between the clause encoding and the paper's condition `s ∈ X → (T ∩ X).Nonempty`; a real (classical) case split, not definitional. |
| `sat_prohClause_iff` | **REAL (modest)** | Same for `¬ H ⊆ X`; needs `Finset.not_subset` in one direction. |
| `req_models_union_closed` | DERIVED (paper-faithful) | The literal paper statement. Its proof is a two-line transport along `sat_reqClause_iff` into `sat_union_of_dualHorn`. The mathematics sits in those two; this theorem is what certifies the *instantiation* is legitimate, which is why it is stated separately rather than skipped. |
| `warrant_models_union_closed` | **TRIVIAL** | Honest disclosure: this is *literally* `req_models_union_closed` with variables renamed (`(e,C)` vs `(s,T)`), because the paper's warrant clause has exactly the same shape as its requirement clause. It adds zero content and is included only for name-level correspondence with `lem:polarity`. |
| `proh_models_inter_closed` | DERIVED (paper-faithful) | As `req_models_union_closed`, via `sat_prohClause_iff` and `sat_inter_of_horn`. |
| `dualHorn_not_inter_closed` | **REAL claim / trivial proof** | The negative half of `thm:closure` for `ℛ`, `𝒲`: an existential refutation, so the *claim* is substantive, but the proof is four `decide` calls on `Fin 3`. Witness: `c = ⟨{1,2},{0}⟩`, `X = {0,1}`, `Y = {0,2}`, `X ∩ Y = {0}` fails. |
| `req_not_inter_closed` | **REAL claim / trivial proof** | Same counterexample in the paper's requirement vocabulary (`(0, {1,2})`), so the refutation is stated against the paper's own definition, not only the encoding. |
| `pureNeg_not_union_closed` | **REAL claim / trivial proof** | Negative half for `ℋ`: prohibition `{0,1}`, `X = {0}`, `Y = {1}`, `X ∪ Y = {0,1}` fails. |
| `proh_not_union_closed` | **REAL claim / trivial proof** | Same in the paper's prohibition vocabulary. |

Note on scope: this formalizes the *combinatorial* content of `thm:closure` directly. It does
**not** formalize the Pol–Inv Galois connection the paper cites as its proof; the Lean proof is
a direct argument, which is strictly stronger as evidence for the statement and weaker as
evidence for the citation.

---

## T2 — `cor:lattice` / `prop:joinmeet`

**File:** `/root/DefiElements/lean/Defialgebra/Lattice.lean` — **VERIFIED, and low-content, as suspected.**

`UnionClosedFamily E` bundles `carrier : Set (Finset E)` with `∅ ∈ carrier`,
`univ ∈ carrier` and binary union-closure. The deliverable is a genuine
`noncomputable instance completeLattice : CompleteLattice F.carrier`.

**mathlib search result (honest):** mathlib does *not* hand this over in one line.
`Mathlib/Order/CompleteSublattice.lean` defines `CompleteSublattice`, but it demands closure
under **both** `sSup` and `sInf` — our family is not inf-closed, so it does not apply.
`Mathlib/Order/SupClosed.lean` has `SupClosed` and a `CompleteSemilatticeSup`-builder
(line 408) but keyed on sup-closed *subsets of a lattice*, not on the subtype we need.
What mathlib does supply, and what is used, is `completeLatticeOfSup` — which reduces the
whole target to "define `sSup` and prove it is a least upper bound". So the target is
**mostly a mathlib call**, with exactly one real step (see table).

### `#print axioms` (verbatim)

```
'Defialgebra.Lattice.UnionClosedFamily.mem_toFinsetFamily' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Lattice.UnionClosedFamily.famSup_mem' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Lattice.UnionClosedFamily.isLUB_sSup'' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Lattice.UnionClosedFamily.completeLattice' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Lattice.UnionClosedFamily.coe_sup' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Lattice.UnionClosedFamily.inf_eq_sSup' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Lattice.UnionClosedFamily.coe_inf' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Lattice.UnionClosedFamily.top_eq_univ' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.Lattice.meet_ne_inter' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Content classification

| Declaration | Class | Justification |
|---|---|---|
| `famSup_mem` | **REAL CONTENT** (the only one here) | This is the binary → arbitrary upgrade: over a `Fintype` ground set an arbitrary subfamily is finite, so `Finset.sup_induction` fed with `∅ ∈ F` and binary union-closure shows the union of *any* subfamily stays in `F`. Nothing in mathlib does this for us. |
| `mem_toFinsetFamily` | TRIVIAL | `simp` on a classical `Finset.filter` over `Finset.univ`. |
| `isLUB_sSup'` | ROUTINE | Two applications of `Finset.le_sup` / `Finset.sup_le`; no idea in it, but it is the obligation `completeLatticeOfSup` demands. |
| `completeLattice` | **LOW-CONTENT (mathlib)** | Literally `completeLatticeOfSup _ F.isLUB_sSup'`. Reported as low-content rather than dressed up. |
| `coe_sup` | ROUTINE | Join = union (paper `prop:joinmeet`); two-sided `le_antisymm` using `union_mem` to know `A ∪ B` is a *member*. |
| `inf_eq_sSup` | TRIVIAL | `a ⊓ b = sSup {x | x ≤ a ∧ x ≤ b}` holds in *every* complete lattice; proved generically by `le_sSup`/`sSup_le`. It is recorded because it is the paper's `prop:joinmeet` meet formula, not because it is hard. |
| `coe_inf` | ROUTINE | Rewrites the previous line into `⋃ {C ∈ F : C ⊆ A ∩ B}` explicitly. |
| `top_eq_univ` | TRIVIAL | Antisymmetry against `Finset.subset_univ`; the only place `univ_mem` is needed. |
| `meet_ne_inter` | **REAL claim / trivial proof** | Explicit family `{∅, {0,1}, {0,2}, univ}` on `Fin 3`: contains `∅` and `univ`, is union-closed, and `{0,1} ∩ {0,2} = {0}` is not a member. Proof is `decide`. This is what makes `inf_eq_sSup` a real distinction rather than a restatement. |

---

## T3 — `thm:convex`, strengthened

**File:** `/root/DefiElements/lean/Defialgebra/ConvexGeometry.lean` (appended) — **VERIFIED**

### `#print axioms` (verbatim)

```
'Defialgebra.ConvexGeometry.reachSet_union' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.ConvexGeometry.reachCl_union' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.ConvexGeometry.reachCl_union_of_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.ConvexGeometry.reachSet_eq_self_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.ConvexGeometry.thm_convex' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Content classification

| Theorem | Class | Justification |
|---|---|---|
| `reachSet_union : reachSet r (A ∪ B) = reachSet r A ∪ reachSet r B` | **REAL (modest)** | This is the paper's `lem:cm` content for singleton premises — the fact that makes `A ⊕ B = A ∪ B`. The Lean proof is short (an `ext` plus a witness case split) precisely *because* the premises are singletons; that shortness is the mathematical point, not padding. |
| `reachCl_union` | TRIVIAL | Same statement at the `ClosureOperator` level; `rfl`-transport of the above. |
| `reachCl_union_of_closed` | TRIVIAL | `rw` of the previous plus the two closedness hypotheses. Included because it is the exact form `thm:excomp` consumes. |
| `reachSet_eq_self_iff : reachSet r A = A ↔ ∀ a ∈ A, ∀ b, ReflTransGen r a b → b ∈ A` | **REAL (modest)** | The "closed sets are exactly the down-sets of the specialization preorder" half of `thm:convex`. Genuine two-directional argument, though each direction is three lines. |
| `thm_convex` (bundle) | **TRIVIAL** | Honest disclosure: it is a `⟨_, _, _⟩` of `reachCl_union`, `reachSet_eq_self_iff` and the pre-existing `reachCl_antiExchange_iff`. It contributes **zero** new mathematics; it exists so that a single named theorem matches the paper's `thm:convex` statement. Do not count it as a fourth result. |

Note on the "partial order" clause of `thm:convex`: antisymmetry of `ReflTransGen r` is stated
as the explicit hypothesis `∀ x y, ReflTransGen r x y → ReflTransGen r y x → x = y` rather than
by installing a `PartialOrder E` instance. Reflexivity and transitivity are `ReflTransGen.refl`
and `.trans`, so the hypothesis *is* exactly "the specialization preorder is a partial order".
No separate instance is built; that is a presentation choice, not a gap.

---

## T4 — `thm:excomp` (the real statement)

**File:** `/root/DefiElements/lean/Defialgebra/ConvexGeometry.lean` (appended) — **VERIFIED**

The pre-existing `ex_reachCl_union` was, as flagged, *not* the paper claim: it filters by
minimality over `A ∪ B`. The new theorem filters only over the generators
`ex A ∪ ex B`, which is what makes `thm:excomp` a compositionality statement computable in
`|ex A| + |ex B|`.

```lean
theorem ex_reachCl_union_ex
    (hanti : ∀ x y : E, ReflTransGen r x y → ReflTransGen r y x → x = y)
    (A B : Finset E) :
    ex (reachCl r) (A ∪ B)
      = (ex (reachCl r) A ∪ ex (reachCl r) B).filter
          (fun a => ∀ b ∈ ex (reachCl r) A ∪ ex (reachCl r) B,
            Relation.ReflTransGen r b a → b = a)
```

Orientation: the paper's preorder is `a ≽ b ↔ b ∈ Cn {a}`, i.e. `a ≽ b` iff `a` reaches `b`.
Hence a `≼`-**maximal** element of a set is one no *other* element of the set reaches, i.e.
reachability-**minimal** — which is precisely the predicate above and the one already used by
`ex_reachCl`. So `ex = max_≼` in the paper's sense. This is recorded in a comment in the file.

### `#print axioms` (verbatim)

```
'Defialgebra.ConvexGeometry.exists_ex_reach_aux' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.ConvexGeometry.exists_ex_reach' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.ConvexGeometry.ex_reachCl_union_ex' depends on axioms: [propext, Classical.choice, Quot.sound]
'Defialgebra.ConvexGeometry.ex_oplus' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Content classification

| Theorem | Class | Justification |
|---|---|---|
| `exists_ex_reach_aux` | **REAL CONTENT** | The descent lemma: every `b ∈ S` is reached by some `b' ∈ ex S`. Proved by strong induction on `n ≥ card (S.filter (· ≼ b))`; at each step a witness `y ∈ S` with `y ≼ b`, `y ≠ b` gives `{x ∈ S : x ≼ y} ⊊ {x ∈ S : x ≼ b}`, the strictness coming from `b ∉` the smaller set — and *that* is exactly where antisymmetry is consumed. This is the whole technical weight of T4. |
| `exists_ex_reach` | TRIVIAL | Wrapper instantiating `n := card`, `le_rfl`. |
| `ex_reachCl_union_ex` | **REAL CONTENT** | The paper's `thm:excomp`. Forward inclusion is routine (`ex A ∪ ex B ⊆ A ∪ B`). The reverse is the substantive one: given `a` minimal among the *generators* and an arbitrary `b ∈ A ∪ B` with `b ≼ a`, descend `b` to `b' ∈ ex A ∪ ex B` with `b' ≼ b ≼ a`, conclude `b' = a` by minimality over the generators, then `a ≼ b` and `b ≼ a` force `a = b` by antisymmetry. |
| `ex_oplus` | DERIVED (paper-faithful) | The `⊕` form for closed `A`, `B`: `rw [reachCl_union_of_closed]` then the theorem above. Two lines, but it is the literal shape of `thm:excomp` (`ex (A ⊕ B) = max_≼ (ex A ∪ ex B)`), so it is stated rather than left implicit. |

### Where antisymmetry is needed (honest answer: it is genuinely needed)

Antisymmetry is consumed in exactly two places, both inside the reverse inclusion:
1. in `exists_ex_reach_aux`, to show the down-set strictly shrinks (otherwise the induction
   does not terminate, and indeed `ex S` can be **empty** for nonempty `S`);
2. at the last step of `ex_reachCl_union_ex`, to turn `a ≼ b ∧ b ≼ a` into `a = b`.

**Counterexample without antisymmetry** (argued, *not* machine-checked — see limitations):
take `E = {x, y, z}` with arcs `x → y`, `y → x`, `x → z`, `y → z`. Then
`ex {x, y} = ∅` (each of `x, y` is reached by the other), so with `A = {z}`, `B = {x, y}`:
`ex A ∪ ex B = {z}`, and the right-hand side filters to `{z}`; but
`ex (A ∪ B) = ex {x, y, z} = ∅`, since `x ≼ z` and `x ≠ z`. So the claim fails.
The hypothesis is not an artifact of the proof.

---

## Limitations / not attempted

* The no-antisymmetry counterexample for `thm:excomp` above is argued in prose, **not**
  formalized. Formalizing it needs a `DecidableRel (ReflTransGen r)` instance for a concrete
  4-arc relation, which was outside the time budget. Everything else in this report is
  machine-checked.
* `thm:closure` is proved directly, not via the Pol–Inv Galois connection the paper cites.
* The paper's `cor:ourconvex` (the concrete 58-element vocabulary is acyclic) is a
  *measurement* about a specific dataset, not a theorem, and was not in scope.
* `T3`'s "closed sets = down-sets of a partial order" is stated with antisymmetry as a
  hypothesis rather than by constructing a `PartialOrder E` instance.

## Summary count (new declarations only)

* **REAL CONTENT:** `famSup_mem`, `exists_ex_reach_aux`, `ex_reachCl_union_ex` (3)
* **REAL but modest:** `sat_union_of_dualHorn`, `sat_inter_of_horn`, `sat_reqClause_iff`,
  `sat_prohClause_iff`, `reachSet_union`, `reachSet_eq_self_iff` (6)
* **REAL claim, `decide` proof (refutations):** `dualHorn_not_inter_closed`,
  `req_not_inter_closed`, `pureNeg_not_union_closed`, `proh_not_union_closed`,
  `meet_ne_inter` (5)
* **DERIVED / paper-faithful transports:** `req_models_union_closed`,
  `proh_models_inter_closed`, `ex_oplus` (3)
* **ROUTINE:** `isLUB_sSup'`, `coe_sup`, `coe_inf` (3)
* **TRIVIAL / low-content (declared as such):** `dualHorn_union_closed`, `horn_inter_closed`,
  `pureNeg_inter_closed`, `horn_of_pureNeg`, `dualHorn_reqClause`, `pureNeg_prohClause`,
  `horn_prohClause`, `warrant_models_union_closed`, `mem_toFinsetFamily`, `completeLattice`,
  `inf_eq_sSup`, `top_eq_univ`, `reachCl_union`, `reachCl_union_of_closed`, `thm_convex`,
  `exists_ex_reach` (16)
