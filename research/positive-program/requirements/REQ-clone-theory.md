# Requirements from universal algebra and clone theory

## 0. Position in one paragraph

The prior work used Pol–Inv in the wrong direction. It fixed the operation (∪), then asked whether the relation (Adm) was invariant under it, and — finding it was not — asked for a maximum union-closed subfamily. That last question is unnamed in the literature because it is not an algebraic question: the Galois connection is between closure systems, not between cardinalities, which is exactly why Geiger's theorems "carry no cardinality-extremal content." The offensive move is the dual: **fix the relation and compute its polymorphism clone.** Adm is closed under every operation in Pol(Adm) *by definition of Pol* — closure by construction, total, no maximisation, no measurement. The whole content then migrates to one question with a finite, checkable answer: **is Pol(Adm) nontrivial, and where does it sit relative to the maximal clones?** On the current carrier the answer is forced and bad, for a reason that is a theorem rather than a fact about DeFi: on a two-element domain the only idempotent conservative binary operations are min and max. A protocol modelled as a *subset* of E therefore admits ∪ and ∩ as its only candidate composition operators, and nothing else exists to be found. The obstruction is not about finance; it is about |{0,1}| = 2. The requirement that follows is the whole of this document: **give the carrier arity and a domain of size ≥ 3, and completeness becomes Rosenberg's criterion — a finite list of six ways to fail, each with a witness.**

## 1. Carrier and signature

**A protocol is not a subset. It is a morphism.**

Work in a **multi-sorted (heterogeneous) algebraic theory** in the sense of Lawvere (1963), in the many-sorted form of Adámek–Rosický–Vitale (*Algebraic Theories*, 2011); the polymorphism machinery is the **multi-sorted Pol–Inv Galois connection of Bulatov–Jeavons** (*Algebraic structures in combinatorial problems*, 2001), which extends Geiger (1968) and Bodnarchuk–Kalužnin–Kotov–Romov (1969) verbatim to sorted domains.

- **Sorts** `S`. Not the 16 groups. Sorts are the interfaces mechanisms consume and produce: `Ledger` (a conserved balance sheet), `Claim` (a redeemable position), `Price` (a scalar fact with provenance), `Rate` (price of credit per unit time), `Party` (an authority-bearing name carrying a cardinality: `1 | k-of-n | delegated | permissionless`), `Flow` (a signed magnitude), `Time` (epoch/schedule), `Msg` (a cross-domain fact). Each sort `s` has a finite domain `A_s` with `|A_s| ≥ 3`.
- **Signature** `Σ`. Each of the 58 elements becomes a typed operation symbol `f : s₁ × … × s_n → t`. Examples of the discipline: `Sh : Ledger → Claim`; `Cp : Ledger × Ledger → Price`; `Ct : Claim × Price → Flow`; `Pl : Claim × Price × Rate → Claim × Claim`; `Ba : Flow^n → Price` (essentially *n*-ary, not decomposable).
- **A protocol** is a morphism `t : s₁×…×s_m → u₁×…×u_k` in the free finite-product category on Σ modulo an equational theory `E` — i.e. a tuple of Σ-terms. A **deployed** protocol is such a morphism together with an interpretation (a model).
- **The clone** `Clo(Σ)` is the set of all term operations: all mechanisms derivable from the primitives by superposition, with projections (pass-through) and permitted duplication and deletion of arguments. Cartesian, not linear: one oracle must be allowed to feed two markets (duplication) and a fee stream must be allowed to be discarded (deletion). This is precisely why the object is a Lawvere theory rather than a coloured operad.

**Group and stratum.** `G01..G16` is *not* the sorting; it is a coarse classification that should be **derived** as the equivalence "same input/output sort profile," and is a testable prediction of the arity assignment. `Stratum 0..4` **is** a grading: I require `deg(f) = 1 + max_i deg(s_i)` on the sort-DAG, so that stratum is the depth of the sort dependency, not a label. Then `Clo_0 ⊆ Clo_1 ⊆ … ⊆ Clo_4` is a filtration and completeness may be proved by induction on degree — five local theorems instead of one global one.

**Formalization discipline.** A row is complete iff every term of it names a *machine-evaluable relation over the sorted domain* — a finite subset of `A_{s₁}×…×A_{s_n}`. Prose is not a row and is not counted. Prohibitions may not be written at all: one writes an **invariant** `ρ` with its arity and its extension, and the prohibition is whatever `Pol(ρ)` excludes. This inverts the prior discipline and makes the 9 prose prohibition rows structurally unwritable rather than merely unwritten.

## 2. Composition

Composition is **substitution in the theory**: given `g : t₁×…×t_n → u` and `f_i : s̄ → t_i`, the composite is `g ∘ ⟨f₁,…,f_n⟩`. 

- **Total**: composition of morphisms is defined whenever the sorts match, and sort matching is decidable in linear time. It is total on the typed carrier by the definition of a category; there is no side condition to discover empirically.
- **Closed**: hom-sets are closed under composition because that is a category axiom. This is the brief's "closed by construction of the carrier rather than by accident," discharged definitionally.
- Prohibitions never re-enter as a closure question. `X2` is not a set-membership test on `{Cp, Fl, Pl}`; it is the statement that the composite term admits a cycle in its `Flow` graph with strictly positive net extraction. That is a **computable invariant of a term** (a functor from the theory to a value semiring), evaluated once per morphism. Union-closure of a family of subsets is not a question the carrier can pose.

Where composition genuinely *is* partial — resource exclusivity, a lock that two sub-terms both claim — the partiality is a **linear** sort, and the correct structure is a symmetric monoidal (not cartesian) sub-theory on that sort alone: duplication is forbidden for `Rl` resource locks and permitted everywhere else. That is a mixed cartesian/monoidal theory, standard, and it localises partiality to one sort instead of contaminating the operator.

## 3. Completeness theorem (formal statement)

Separate two notions; conflating them is what wrecked the prior work.

**(a) Generation completeness (coverage).** `∀ P ∈ Corpus60. P ∈ Clo(Σ)`. Falsified by one deployed protocol that is not a Σ-term. This is a measurement, not a theorem.

**(b) Functional completeness relative to declared invariants.** Let `𝔈` be the finite set of declared economic invariants (value conservation, solvency, no-free-mint, authority monotonicity, fungibility partitions). 

> **Target Theorem (Completeness).** `Clo(Σ) = Pol(𝔈)`.

Equivalently, by Geiger/BKKR (which holds verbatim on a finite multi-sorted domain), `Inv(Σ)` is the relational clone generated by `𝔈` under primitive-positive definitions. **Falsification** takes either dual form: exhibit an operation preserving all of `𝔈` that is not a Σ-term, or exhibit an invariant preserved by Σ that is not pp-definable from `𝔈`. Both are decidable over a finite domain via the **indicator problem** `IP(Γ,k)` of Jeavons–Cohen–Gyssens (*Closure properties of constraints*, JACM 1997).

**The analogue of Post's maximal clones.** Post (1941) characterised Boolean completeness by five maximal clones: `T₀, T₁, M, D, L`. The correct generalisation to `|A| = k ≥ 3` is **Rosenberg's completeness theorem** (1965/1970): `F` is complete iff `F ⊄ Pol(ρ)` for every `ρ` in six explicitly described families, and for fixed `k` that list is finite and effectively enumerable. Post's five are the `k = 2` instance (`T₀,T₁` are unary central relations, `M` a bounded order, `D` a prime permutation, `L` the prime-affine relation over ℤ₂). **This is the finite checkable failure list the brief asks for.** Its DeFi reading, with the escape witness each requires:

| # | Rosenberg family | DeFi meaning: P is trapped if… | Escape witness required in P |
|---|---|---|---|
| R1 | bounded partial order | every mechanism is monotone in seniority | `Li`, `Ad` — payoff non-monotone in the borrower's position |
| R2 | nontrivial equivalence | every mechanism respects a fixed compartment/fungibility partition | `Sl`, `Xf`, `Ag` — a mechanism that *merges* compartments |
| R3 | prime permutation | every mechanism is equivariant under relabelling of parties | `Aw`, `Gp`, `Fz` — requires the **Party sort**; a party-free vocabulary cannot escape R3 |
| R4 | prime affine | every mechanism is linear / pro-rata | `Cp`, `St`, `Cl`, `Op` — a strictly convex invariant or a kink |
| R5 | central relation | no mechanism can leave the safe centre | `Uc`, `Sl`, `Ad` — a mechanism that can *reach insolvency* |
| R6 | h-regular relation | every mechanism decomposes across a family of partitions | `Ba`, `In` — genuinely essential high arity |

Two consequences deserve to be stated flatly.

**R3 makes the party sort mandatory, not desirable.** A vocabulary with no way to name *who* is automatically equivariant under permutation of holders, hence contained in `Pol(π)`, hence provably incomplete. The 135 party-obligations in the residue are not a coverage gap; they are the signature of a maximal clone.

**R5 inverts the role of prohibitions.** A functionally complete DeFi vocabulary **must contain a mechanism capable of producing a bad state.** A vocabulary all of whose mechanisms preserve solvency is contained in the central-relation clone and cannot express the protocols that fail. Prohibitions are therefore not constraints on the algebra; they are the invariants whose *escape* is a completeness requirement. This explains, without recourse to any defect, why the prior work's prohibitions did 100% of the exclusion: they were the only place the vocabulary escaped a maximal clone.

**Cheap sufficient criterion.** Where `Σ` contains all unary operations of a sort and `|A| ≥ 3`, **Słupecki's criterion** (1939) applies: completeness follows from a single surjective, essentially-at-least-binary operation.

## 4. Construction / synthesis

**The synthesis problem.** A specification is a relation `R ⊆ A_{s₁}×…×A_{s_n}` on the *interface* sorts (small `n`; the interface, not the state). A construction is a **primitive-positive definition** of `R` from `Γ = Inv(Σ)`: an existentially quantified conjunction of atoms. 

- **Certificate**: the pp-formula itself. Verification is evaluation of a conjunctive query — polynomial in `|A|^n` and independent of the search that produced it. Finding is hard; checking is cheap; this is the correct shape.
- **Decidability**: pp-definability from a finite `Γ` over a finite domain is decidable via `IP(Γ, n)` (Jeavons–Cohen–Gyssens 1997).
- **Complexity, exactly**: by the **CSP dichotomy** (Bulatov 2017; Zhuk 2017/2020; conjectured Feder–Vardi 1998, algebraic form Bulatov–Jeavons–Krokhin 2005), synthesis against `Γ` is in **P** iff `Pol(Γ)` contains a **weak near-unanimity** operation, and NP-complete otherwise. This is a *design requirement on the primitive set*: choose sorts and invariants so that `Pol(𝔈)` has a WNU term. Tractable synthesis is a property one engineers, not one one hopes for.
- **Decomposability**: by **Baker–Pixley (1975)**, if `Pol(𝔈)` contains a near-unanimity operation of arity `d+1`, every relation is determined by its `d`-ary projections. With `d = 2` (a majority polymorphism) local consistency suffices, synthesis is `d`-wise, and the prior work's "composition safety = clique in a compatibility graph" is *proved* rather than conjectured.

## 5. Disposition of the prior obstructions

- **"Admissibility not preserved by composition."** Localised to the operator `∪`, and explained: the only idempotent conservative binary operations on a 2-element domain are min and max (a special case of Bulatov's conservative classification, *Complexity of conservative CSP*, 2011). On the sorted carrier one does not *choose* the operator; composition is substitution, and closure is a category axiom. **Dissolves.**
- **"Maximum union-closed subfamily of `(Adm, ∪)` — unnamed, unstudied."** *Wrong carrier.* It is an extremal set-theory problem reached by fixing the operation before the relation. The Galois-correct replacement is: compute `Pol(Adm)`; if trivial, enrich the domain until it is not. **Abandoned and replaced by a program.**
- **"Clique perfection conjecture."** Becomes the decidable question: does `Adm` admit a majority polymorphism? By Baker–Pixley that is exactly 2-decomposability, i.e. pairwise composability ⟹ joint composability. **Converted into a computation** (see §7). No perfection result needed.
- **"Positive theory excludes nothing."** Under R5 this is *diagnostic*, not damning: a theory whose clauses all preserve a central relation is by construction contained in a maximal clone. The repair is to write invariants whose escape is witnessed, not more clauses. **Converted into a completeness obligation.**
- **"Kripke–Kleene fixpoint is `(⊥,⊤)`, carrying no information."** An artifact of a powerset carrier with no arity: with no operation of arity ≥ 1 there is nothing for a fixpoint to iterate over. **Dissolves under arity.**
- **"USDT and USD1 collide exactly."** Two protocols with the same element multiset are different *morphisms*: the wiring differs even when the symbol bag agrees. **Dissolves under arity.**
- **"No ports, so interface theories do not transfer."** Arity *is* ports. **Dissolves by fiat of the carrier.**
- **"Obligation cannot arise."** A venue that escrows the maximum payoff has a `Flow` conservation equation making the margin-call term *unreachable*. Unreachability is a computable property of a term, not an unfilled table cell. **Converted into an invariant.**
- **"Over-collapsed symbols (`Vl`, `Op`, `Xf`/`Xm`)."** Under arity the splits are *forced*, not chosen: two mechanisms with different sort profiles are different operation symbols. **Converted into a mechanical procedure.**

## 6. Minimal viable enrichment (ranked by payoff / cost)

1. **Arity.** Assign each of the 58 elements an input/output sort profile over ~8 sorts. Cost: 58 rows × 4 fields, one pass. Payoff: everything downstream — without arity there is no clone, no term, no synthesis, no certificate; and arity alone breaks `|A| = 2` and therefore the Boolean trap. **If we can afford one enrichment this quarter, it is this one.**
2. **Party sort with cardinality.** Required to escape R3; separates USDT/USD1; discharges 35.1% of the classified residue. Cost: one column with four values.
3. **Magnitude / conservation (`Flow` over a value semiring).** Escapes R4 and R6; makes the 9 prose prohibitions machine-checkable; expresses deferred net settlement as a conservation equation.
4. **Rate sort.** High content payoff (all of lending), low structural payoff — it is magnitude-over-time, an instance of (3).
5. **Symbol splitting.** Do last; (1) performs it automatically.

## 7. Falsifiable near-term test

**Compute `Pol(Adm)` exhaustively up to arity 3 on the existing carrier.** This is the offensive use of Pol–Inv, at zero modelling cost, and both verdicts are decisions.

- **Input.** The recorded admissible element-sets as 58-bit vectors — the 72 seeds used by `/root/DefiElements/formal/v2/composition.mjs`, plus the 144 labelled cases in `/root/DefiElements/algebra/blind-test-set.json` restricted to the admissible ones.
- **Procedure.** Enumerate all 4 unary, 16 binary and 256 ternary Boolean operations. For each `f` of arity `r`, test coordinatewise application over all `r`-tuples from `Adm`: `f` ∈ Pol(Adm) iff `f(A₁,…,A_r) ∈ Adm` for every tuple. Cost: `276 × 72³ × 58` bit-operations ≈ 6×10⁷ — minutes in any language. Report the resulting clone's position in Post's lattice by testing containment in `T₀, T₁, M, D, L`.
- **Verdict A** — some essentially binary or ternary operation preserves `Adm`. Then a composition operator *exists on the present carrier*, the "composition fails" headline is localised to `∪` specifically, and if the operation is `maj` then by Baker–Pixley `Adm` is 2-decomposable and the clique reformulation is a theorem.
- **Verdict B** — only projections survive. Then the flat Boolean carrier provably admits no composition operator at arity ≤ 3, the enrichment to a sorted domain with `|A| ≥ 3` is *forced by proof rather than by preference*, and the quarter's design decision is discharged.

Run in parallel and at trivial cost: **the grading check.** Take the 15 arcs of the definite digraph `D` (`/root/DefiElements/formal/v2/digraph.mjs`) and test `u → v ⟹ stratum(u) > stratum(v)`. If all 15 hold, stratum is a genuine degree function and induction-by-degree is licensed. Compare `D`-height `h(e)` with declared `stratum(e)`: `Σ_e (stratum(e) − h(e))` is a **derived lower bound on the number of requirement arcs the table has never written** — the first quantitative estimate of the unformalized remainder that does not depend on reading prose.

## 8. Named proof obligations

- **PO-CLONE-1**: Compute `Pol(Adm)` up to arity 3 and locate it in Post's lattice; report the generating operations or prove only projections survive.
- **PO-CLONE-2**: Prove that on any 2-element domain the only idempotent conservative binary operations are `min` and `max`, hence a subset-carrier admits no composition operator besides `∪` and `∩`.
- **PO-CLONE-3**: Assign every one of the 58 elements a typed profile `f : s₁×…×s_n → t` over the sort set `S`, and verify that `deg(f) = 1 + max_i deg(s_i)` reproduces the declared stratum for at least 50 of 58.
- **PO-CLONE-4**: Exhibit, for each of Rosenberg's six maximal-clone families, a primitive in `Σ` and a witness tuple proving `Σ ⊄ Pol(ρ)`; six witnesses constitute the completeness certificate.
- **PO-CLONE-5**: Prove `Clo(Σ) = Pol(𝔈)` for the declared invariant set `𝔈`, or exhibit a `𝔈`-preserving operation that is not a Σ-term.
- **PO-CLONE-6**: Decide whether `Pol(𝔈)` contains a weak near-unanimity operation; by Bulatov/Zhuk this settles the complexity of protocol synthesis (P vs NP-complete) outright.
- **PO-CLONE-7**: Prove that arity ≤ 3 suffices to detect nontriviality of a Boolean polymorphism clone, or supply the arity bound that does (Post's finite generation of every Boolean clone is the expected route).
- **PO-CLONE-8**: Decide whether `Adm` admits a majority polymorphism; by Baker–Pixley this settles the pairwise-implies-joint composability conjecture without any perfect-graph result.
- **PO-CONJ-Grading**: *Conjecture (Stratified generation).* Every deployed protocol of stratum `k` lies in `Clo_k(Σ)` — the sub-clone generated by primitives of stratum ≤ `k`. Falsified by one stratum-3 protocol requiring a stratum-4 primitive.
- **PO-CLONE-9**: Verify that the derived equivalence "same sort profile" refines to the declared groups `G01..G16`; discrepancies are either mis-grouped elements or over-collapsed symbols, and the procedure names which.
