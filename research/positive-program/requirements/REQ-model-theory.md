# Requirements from Model Theory and Definability

## 0. Position in one paragraph

"All useful DeFi is constructible from `P`" has no truth conditions because the quantifier has no domain. My requirement is that we stop trying to quantify over intentions and instead do what Post did: fix a **closure operator**, fix an **independently given semantics**, and state completeness as an **adequacy theorem relative to both**. Completeness is then never absolute — it is completeness *with respect to a declared list of construction operations*, exactly as Post's functional completeness is completeness with respect to superposition. Three clauses are non-negotiable and the prior work had only the first: (i) **coverage** — every reference behaviour is the semantics of some construction; (ii) **separation** — the construction map reflects observable distinctions, so that non-isomorphic protocols get non-isomorphic specifications (this is what USDT/USD1 refutes today); (iii) **independence** — no primitive is implicitly definable from the rest, by Beth. Without (ii), `P = {⊤}` is complete and the theorem is worthless. Every clause below carries an explicit refuter: a finite object whose exhibition kills the claim.

## 1. Carrier and signature

Work in an **institution** `𝓘 = (Sign, Sen, Mod, ⊨)` in the sense of Goguen–Burstall, with structured specifications à la Sannella–Tarlecki (CASL; Mossakowski's Hets is the reference implementation).

**Signatures.** `Σ = (S, F, Π)` many-sorted, with sorts fixed as a minimum:
`Party`, `Asset`, `Amount` (ordered abelian group), `Scope` (one atomic settlement scope — a transaction), `Time`, `Claim`, `Protocol`. `Amount` and `Time` come with theory extensions (LRA/LIA); `Party` and `Scope` are pure sorts with finite relations (`holds`, `quorum : Party → ℕ`, `inScope : Scope × Event`).

**A primitive is not an atom.** Each `e ∈ E` is a **parameterized specification** `e = (Σ_e^param ↪ Σ_e, Ax_e)` — a theory presentation with a declared interface. `Sh`, `Ix`, `Cp` are not letters; they are axiom sets over small signatures.

**A protocol is not a subset.** A protocol is a **colimit of a finite diagram** `D : J → Spec` whose nodes are instances of elements of `P`, together with its model class `Mod(colim D)`. The prior carrier is the image of this under the forgetful functor `U : Spec → 𝒫(E)` that remembers only which elements occur. **`U` is not faithful, and that is the entire USDT/USD1 phenomenon** (Section 3, clause (ii)).

**Grading.** Stratum is not decoration: define `deg(S) = ` length of the longest chain of non-conservative signature extensions in any diagram presenting `S`. Requirement `PO-MOD-6`: the recorded strata `0..4` agree with `deg` on the 58 elements. If they do, induction on stratum is legitimate and free constructions by degree are available; if they do not, the grading is a naming convention and must be discarded.

## 2. Composition

**Composition is pushout, not union.** Given `S₁` over `Σ₁`, `S₂` over `Σ₂` and a shared interface `S₀ ↪ S₁`, `S₀ ↪ S₂`, the composite is `S₁ +_{S₀} S₂`.

- **Totality** holds by construction: `Sign` is cocomplete (finitely presented many-sorted signatures have pushouts), so the syntactic composite always exists. There is no side condition on the syntax.
- **Closure of the semantics** is *not* automatic. It is precisely the **amalgamation property** (Goguen–Burstall exactness): `Mod` must send signature pushouts to pullbacks, so that a model of `S₁` and a model of `S₂` agreeing on `S₀` amalgamate to a unique model of the composite. **Requirement: the institution must be semi-exact.** Many-sorted FOL with inclusive signature morphisms is exact; adding partial functions or empty sorts breaks it, which is why non-empty sorts are mandatory.

The prior operator is the pushout **over the empty interface**. Composition over the empty interface identifies nothing and constrains nothing, so every genuine interaction shows up as a global side condition — a prohibition — rather than as a mismatch at an interface. That is the structural diagnosis of X21 (`Fl` co-present with `Xf`/`Rl`/`Of`, credited with 147 of 185 failures): the paper itself observes of the Uniswap fee mechanism that "the flash path lives inside a pool's settlement scope and the burn path on a bridge days later, and an element set has no way to say that the two never meet." With a `Scope` sort, "never meet" is a sentence, the composite is a pushout over a scope-disjointness interface, and the prohibition is discharged rather than armed.

**Craig interpolation is what makes modular verification work.** The requirement is the institution-level statement (Diaconescu; Găină–Popescu; Borzyszkowski for structured specifications): for `Σ₁ ← Σ₀ → Σ₂` in a designated class of morphism pairs, if `T₁ ∪ T₂ ⊨ φ` then there is `ψ` over `Σ₀` with `T₁ ⊨ ψ` and `T₂ ∪ {ψ} ⊨ φ`. `ψ` **is** the interface assertion — the assume-guarantee contract that lets you certify the composite from certified components. Without interpolation there exist true composite properties admitting no component-local decomposition; verification is then necessarily monolithic, which is the `2^58` search the prior work hit. Craig fails for arbitrary first-order *theories*, so the discipline is: **component theories may be rich; interface assertions must live in a fragment with effective interpolation** — QF-LRA/LIA plus EUF, combined by Yorsh–Musuvathi, interpolants extracted by McMillan's procedure.

## 3. Completeness theorem (formal statement)

**The reference class move.** I reject the Lindström route: Lindström's characterisation needs an independently given class of abstract logics closed under the right operations, and no such class exists here. I also reject "all useful DeFi". I take the **closure-of-corpus plus independent-semantics** route.

Let `C` be the 60 deployed applications. Let `β : C → B` be an **independently specified observational semantics** — a trace semantics of the deployed code, computed without reference to `E` (this independence is load-bearing; if `β` is read off the element table the theorem is circular). Let `Ops` be a *declared finite list*: pushout composition, parameter instantiation, hiding (reduct along `σ`), quotient, and replication over `Party`. Define the reference class

`Ref := Cl_Ops(β[C]) ⊆ B`.

This is the move that makes the quantifier legal: "all useful DeFi" is *not* everything anyone might build; it is everything reachable from observed practice by the operations by which DeFi is in fact built. It is defensible because completeness is *always* relative to a closure operator — Post's is relative to superposition — and because `Ops` is finite, published, and auditable.

**Theorem (target) — Generative adequacy with separation and independence.**
`P ⊆ Spec` is *functionally complete for* `(Ref, β)` iff

- **(C1) Coverage.** For every `b ∈ Ref` there is a finite diagram `D` over `P` with `β⟦colim D⟧ = b`.
- **(C2) Separation.** For `b ≠ b'` in `Ref`, the corresponding specifications are non-isomorphic in `Spec`: the composite `Ref → Spec/≅` is injective. Equivalently, `U` (Section 1) is replaced by a functor that **reflects isomorphism** on `Ref`.
- **(C3) Independence.** No `e ∈ P` is implicitly definable from `P ∖ {e}`.
- **(C4) Stability.** Every enrichment used is a conservative extension (Section 6).

**The analogue of Post's maximal clones.** `P` fails to be complete exactly when `Cl_Ops(P)` is contained in some **maximal proper closed class**. Each such class is Galois-closed for a preservation property (the Pol/Inv pattern; Rosenberg's classification is the model for enumerating them). Five candidates, each definable as the class of specifications invariant under a stated semantic operation:

| Maximal class `M_i` | Closed under | Escape check |
|---|---|---|
| `M_party` — party-blind specs | any bijective relabelling of holders | some `p ∈ P` mentions `Party` non-trivially |
| `M_qual` — magnitude-free specs | any order-preserving rescaling of `Amount` | some `p ∈ P` asserts a threshold |
| `M_flat` — scope-flat specs | arbitrary re-bracketing of events into scopes | some `p ∈ P` asserts atomicity/conservation |
| `M_ground` — first-order-level specs | any reinterpretation of other protocols | some `p ∈ P` takes a `Protocol` parameter |
| `M_pos` — positive specs | model extension (Łoś–Tarski) | some `p ∈ P` asserts an obligation *cannot arise* |

`P` escapes `M_i` iff some primitive is **not** preserved by the operation defining `M_i` — five decidable preservation checks, not a search over `2^58`. **The present `P` is inside `M_party`, `M_qual`, `M_flat`, `M_ground` and `M_pos` simultaneously** (Brief §4). This is not a defect of DeFi; it is a complete and constructive diagnosis of exactly which five closures must be broken, and each is broken by adding one sort or one sentence form.

**Refutation conditions (explicit, finite objects).** The theorem is refuted by exhibiting any of:

- **R1 — a separating pair.** Deployed `b ≠ b'` with `β(b) ≠ β(b')` but every representing specification isomorphic. *USDT/USD1 with divergent solvency is exactly such an object, and it refutes the present `P` today.* The criterion therefore has bite.
- **R2 — an unreachable behaviour.** A deployed `b ∈ C` outside the image of `Cl_Ops(P)`, **certified by exhibiting an invariant** — a preservation property holding of every `p ∈ P` and violated by `b`. The certificate requirement is what the prior work's unfalsifiable conjecture lacked: an existential over an object of size `10^16` with no finite witness type is not a refutation condition. Here the witness is one invariant plus one protocol.
- **R3 — a redundancy witness.** An `e ∈ P` implicitly definable from `P ∖ {e}`, refuting (C3).

**Beth as the independence criterion.** `e` is *implicitly definable* from `P∖{e}` iff any two models of `Th(P)` that agree on the reduct along `Σ ∖ e ↪ Σ` agree on `e`; equivalently `Th(P) ∪ Th(P)[e ↦ e'] ⊨ ∀x (e(x) ↔ e'(x))` — a single entailment check. Beth's theorem (1953) gives implicit ⟹ explicit, so a redundant primitive comes with an explicit *defining term*: not merely "drop it" but "here is what it abbreviates". Beth follows from Craig, which is why Section 2's interpolation requirement does double duty. Caveat with the force of a requirement: **Beth fails for many-sorted logic with possibly-empty sorts** (Feferman) — hence `PO-MOD-4`.

## 4. Construction / synthesis

**Synthesis problem.** Given a specification `S` over `Σ`, find a finite diagram `D` over `P` and a **theory interpretation** `ι : S → colim D` (a signature morphism `σ` with `colim D ⊨ σ(φ)` for every axiom `φ` of `S`) — relative interpretation in the Tarski–Mostowski–Robinson sense.

**Certificate.** The pair `(σ, π)` where `π` is a proof object for each `⊨ σ(φ)`. Checking is polynomial in `|π|`; this is the certificate that a construction discharges a specification, and it is independent of how the construction was found.

**Complexity.** Unbounded search is NP-hard (it contains the completion problem the prior work identifies as NP-complete). It is **fixed-parameter tractable in the number of interface sorts**, because interpolation bounds the interface vocabulary and hence the branching of the diagram. Requirement `PO-MOD-7`.

## 5. Disposition of the prior obstructions

- **"Admissibility not union-closed."** *Localized to a degenerate fragment*: union is pushout over the empty interface. Over non-empty interfaces closure is amalgamation, which holds by exactness.
- **X21 / the 79% concentration.** *Converted to a computable invariant*: the scope-disjointness interpolant over the shared `Scope` vocabulary. Armed only when the interpolant is unsatisfiable.
- **"The positive theory excludes nothing."** *Dissolves*: a theory of empty clauses has model class `Mod(Σ)`. Replaced by a **formalization discipline** — a row counts iff every term is a `Σ`-sentence and `Th ⊨ row` is machine-checkable. Prose is not a constraint.
- **Bilattice diagonal; Kripke–Kleene collapse to `(⊥,⊤)`.** *Localized*: both are facts about fixpoints over a powerset. Over `Spec`, `⊥` is the empty theory, whose model class is everything, and no collapse statement transfers.
- **USDT/USD1 collision.** *Promoted to clause (C2)* — from an embarrassment to the sharpest refutation condition in the theorem.
- **"Conjecture not falsifiable as stated."** *Structurally excluded*: every claim above ships with a finite witness type (R1/R2/R3).
- **`Ct` primitive in none, consequence in all.** *Converted to a Beth question*, and to the near-term test below.

## 6. Minimal viable enrichment (ranked)

Ranked by (structural payoff)/(formalization cost). **Conservativity is the gate on all of them**: enrichment along `σ : Σ → Σ'` must be conservative — `Mod(σ)` surjective on models — so that `Th' ⊨ σ(φ) ⟺ Th ⊨ φ` and no prior verdict is invalidated.

1. **`Party` sort with counting.** Cost: one sort, one relation, one cardinality function; no arithmetic theory; no threat to decidability or interpolation. Payoff: breaks `M_party`, splits the four collision classes, and is a **necessary condition of the theorem** — without it (C2) is false, so `P` is not complete for any `Ref` at all. Take this one.
2. **`Scope` sort with atomicity.** Cost: one sort, one relation, quantifier-free. Payoff: 147 of 185 composition failures, and conservation laws (Uniswap v4 deferred settlement) become statable.
3. **`Protocol` parameter (level above the protocol).** Cost: near zero — parameterized specifications already provide it in CASL. Payoff: vaults, curators, aggregator-of-aggregators.
4. **`Amount` sort with thresholds.** Cost: high — drags in an arithmetic theory, threatens both decidability and interpolation; must be confined behind a QF-LRA interface. Payoff: 9 of 20 prohibition rows, interest rates. Defer.

## 7. Falsifiable near-term test

**The Beth redundancy scan.** Days, not months, and it is a *refutation* test.

- **Input.** The 60 element-set decompositions and the 15 arcs of the definite digraph `D`. Nothing else.
- **Procedure.** Treat each decomposition as a finite model over the 58 unary predicates. For each `e ∈ E`, test finite-model implicit definability: does there exist a pair of corpus models agreeing on all of `E ∖ {e}` but disagreeing on `e`? A table scan, `O(60² · 58)` ≈ 200k comparisons.
- **Verdict.** If such a pair exists, `e` is **not** implicitly definable and is independent on this corpus. If no such pair exists for `e`, `e` is a redundancy *candidate*, and Beth then demands an explicit defining term over `E ∖ {e}`, to be produced or the candidacy withdrawn.
- **Prediction, stated in advance so the test can fail.** `Ct` (collateral-threshold test) yields no separating pair — it is implicitly definable — because the paper records it as a consequence in every protocol that has it and a primitive in none. **If `Ct` does have a separating pair, my derivation-order claim is refuted on this fragment.**
- **Bonus verdict, same scan.** Report all collided pairs. The four known classes (USDT/USD1, LiquidMesh/KyberSwap, Binance Wallet/OKX DEX, Jupiter/1inch) are the current R1 refuters; **the enrichment of §6.1 succeeds iff all four split and no previously distinct pair merges.** The second half is the conservativity check and must be run.
- **Asymmetry, stated honestly.** Failure of implicit definability on 60 models is *conclusive* (implicit definability quantifies over all models). Success on 60 models is *evidence only*, discharged at theory level via `PO-MOD-3`.

## 8. Named proof obligations

- **PO-MOD-1** (Exactness): `𝓘_DeFi` is semi-exact — `Mod` sends pushouts of inclusive signature morphisms to pullbacks — so composition over a non-empty interface is closed by construction.
- **PO-MOD-2** (Interpolation): `𝓘_DeFi` has Craig interpolation for the class of interface morphisms, with interpolants effectively computable in QF-LRA + EUF.
- **PO-MOD-3** (Beth independence): for each `e ∈ P`, `Th(P∖{e}) ⊭ ` implicit definition of `e`; equivalently no explicit term over `P∖{e}` defines `e`.
- **PO-MOD-4** (Non-degeneracy): all sorts of every `Σ` are non-empty and all signature morphisms inclusive, so Beth is not defeated by the empty-sort counterexample.
- **PO-MOD-5** (Separation): the assignment `Ref → Spec/≅` is injective; equivalently no R1 object exists after the §6.1 enrichment.
- **PO-MOD-6** (Grading is real): the recorded stratum function on the 58 elements equals `deg` (longest chain of non-conservative extensions); otherwise the grading is discarded.
- **PO-MOD-7** (Synthesis): the interpretation-search problem is FPT in the number of interface sorts; certificates `(σ, π)` are polynomial-time checkable.
- **PO-MOD-8** (Conservativity of enrichment): each `σ : Σ → Σ'` of §6 has `Mod(σ)` surjective, hence `Th' ⊨ σ(φ) ⟺ Th ⊨ φ`; no prior verdict is invalidated.
- **PO-MOD-9** (Clone escape): `Cl_Ops(P)` is contained in none of `M_party, M_qual, M_flat, M_ground, M_pos`, witnessed by five preservation counterexamples.
- **PO-MOD-10** (Adequacy): `β` is definable without reference to `E`, and (C1) holds for `Ref = Cl_Ops(β[C])`.
- **PO-MOD-11** (Formalization discipline): every requirement and prohibition row is a `Σ`-sentence; rows containing `[ext]` terms are not constraints and are excluded from every measurement.
