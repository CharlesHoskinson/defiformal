# Candidate mathematical structures for an algebra of DeFi protocol composition

Research brief prepared 2026-08-04. Seven candidate frameworks assessed against the actual
data shape:

- **58 elements** (recurring on-chain financial mechanisms), each with a *family* (mutual
  substitutes), a *stratum* S0–S4 (asserted prerequisite depth), and an async property.
- **A protocol is a SET of elements.** Not a wiring diagram, not a sequence, not a tree.
- **29 laws** `(subj1|subj2|...) -> term1 + term2 + ...`, each term a disjunction of elements.
  Fires if *any* subject is present; satisfied if *every* term has ≥1 alternative present.
  Formally: a **conjunction of disjunctions guarded by a disjunctive trigger**, evaluated
  over a set. This is a definite/Horn-*like* clause but **not Horn** — the head is
  disjunctive, which puts it in the class of *general clauses* (CNF), not Horn.
- **20 hazard rules** naming forbidden or risky element combinations.
- **Non-monotone validity**: adding an element can satisfy a law *and* arm a hazard.
- **The decomposition map is not injective**: USDT and USD1 decompose to the same element
  set but are wildly different credits.

Two structural facts about the data dominate everything below, and should be stated in the
brief up front because they eliminate most of the fashionable candidates immediately:

1. **The carrier is a set with idempotent union and no interfaces.** `E ∪ E = E`. Every
   framework built on *coproduct* (⊔ of disjoint copies) or *cartesian product* of state
   spaces is structurally wrong: those products are not idempotent, and they presuppose
   boundary ports the data does not contain.
2. **Validity is a predicate on the whole, not a property preserved by composition.**
   Frameworks whose central theorem is "composition preserves refinement / functoriality"
   are answering a different question than "is this set legal".

---

## 1. Symmetric monoidal categories / PROPs, decorated and structured cospans

### Signature and carrier

**Decorated cospans** (Fong, [arXiv:1502.00872](https://arxiv.org/abs/1502.00872); thesis
[arXiv:1609.05382](https://arxiv.org/abs/1609.05382)). Given a category `C` with finite
colimits and a lax braided monoidal functor `F : (C, +) -> (D, ⊗)`, objects are objects of
`C`; a morphism is a pair — a cospan `X -> N <- Y` in `C` together with an element
`1 -> F N` in `D`. With `D = (Set, ×)`, a decoration is literally an element `s ∈ F N`.
Morphisms of the resulting category are **isomorphism classes** of decorated cospans.

**Structured cospans** (Baez & Courser, [arXiv:1911.04630](https://arxiv.org/abs/1911.04630)).
Given a left adjoint `L : A -> X` (`A`, `X` with finite colimits), a structured cospan is a
diagram `L(a) -> x <- L(b)` *in X*, with `a, b ∈ A`. Yields a symmetric monoidal **double
category** `_L Csp(X)`: objects = objects of `A`; vertical 1-morphisms = morphisms of `A`;
horizontal 1-cells = structured cospans; 2-cells = commuting diagrams.

Baez, Courser & Vasilakopoulou ([arXiv:2101.09363](https://arxiv.org/abs/2101.09363),
*Compositionality* 4, 2022) generalise decorations to a pseudofunctor `F : A -> Cat` and
prove the two constructions **isomorphic** when `X = ∫F`, the Grothendieck category. Baez's
2025 survey ([arXiv:2509.22584](https://arxiv.org/abs/2509.22584)) unifies both under
"hypergraph double category".

### Operations and which laws hold

| Operation | Definition | Law status |
|---|---|---|
| Composition `;` | pushout of the apex over the shared leg; decorations combined via the **laxator** `φ_{n,m} : Fn × Fm -> F(n+m)` then pushed forward | **Associative only up to canonical iso.** Pushout is a colimit. Baez–Master, [arXiv:1808.05415](https://arxiv.org/abs/1808.05415), state it explicitly: because "composition is defined only up to isomorphism" they move to a symmetric monoidal double category. A strict category is recovered only by quotienting to iso-classes — which loses information. |
| Monoidal `⊗` | coproduct in `C` (disjoint union) | Symmetric (commutative **up to** the symmetry iso). Unit = initial object. |
| Idempotence | — | **Fails.** `N + N ≇ N` in Set. *(Derived from the definition — coproduct is not idempotent — not quoted from a source.)* |
| Frobenius | each object carries a special commutative Frobenius monoid | Holds: decorated cospan categories are **hypergraph categories** (Fong–Spivak, [arXiv:1806.08304](https://arxiv.org/abs/1806.08304)). Fong's *Decorated Corelations* ([arXiv:1703.09888](https://arxiv.org/abs/1703.09888)) proves *every* hypergraph category is hypergraph-equivalent to a decorated corelation category. |

### Constraint satisfaction on composition — no

Cospan composition is **total and gluing-only**. The hypothesis "`X` has finite colimits"
*guarantees* every pushout exists, so every pair of composable cospans has a composite, by
construction. No predicate gates composition anywhere in Fong 1502.00872, Baez–Courser
1911.04630, Baez–Courser–Vasilakopoulou 2101.09363, Baez–Master 1808.05415, or the 2025
survey. `Partial monoidal` / `premonoidal` categories exist (Power–Robinson) but address a
*different* failure — `⊗` not being a bifunctor in the presence of effects — not validity
gating. No work was found making cospan composition partial.

### Non-monotonicity — cannot express it

Composition is functorial and total; a symmetric monoidal (double) functor sends composites
to composites unconditionally. Nothing in this literature lets a valid whole become invalid
on adding a part.

**The adjacent framework that *does*** is **algebraic graph rewriting with nested
application conditions**: Habel & Pennemann, "Nested Constraints and Application Conditions
for High-Level Structures" (Springer LNCS 3393); Ehrig, Ehrig, Habel & Pennemann, "Theory
of Constraints and Application Conditions: From Graphs to High-Level Structures"
(*Fundamenta Informaticae*, 2006). A **negative application condition** `¬∃a` is inherently
non-monotone: adding structure destroys satisfaction. Nested graph conditions are
**expressively equivalent to first-order graph formulas** (Habel–Pennemann), and the
translation theorems convert *global* constraints into *local* application conditions and
yield weakest preconditions. **This is the piece of the categorical world worth pointing
the mathematicians at — not cospans.**

### Decidability and tooling

**AlgebraicJulia is real and usable.** Catlab.jl (*Categorical Data Structures for Technical
Computing*, [arXiv:2106.04703](https://arxiv.org/abs/2106.04703)) computes limits/colimits of
ACSets, **homomorphism search** (CSP-style backtracking over C-Set homs), functorial data
migration, and the **chase** for embedded dependencies in regular logic.
AlgebraicRewriting.jl ([arXiv:2111.03784](https://arxiv.org/abs/2111.03784)) implements
DPO/SPO/SqPO rewriting **with positive and negative application conditions** (`AppCond`,
`LiftCond`). AlgebraicPetri.jl and AlgebraicDynamics.jl back Libkind et al.,
[arXiv:2203.16345](https://arxiv.org/abs/2203.16345) (*Phil. Trans. R. Soc. A* 380:20210309).
No model checker. `HomomorphismQuery` (full hom-set via limits) is noted as not
re-implemented in Catlab v0.17.

### Finance / smart-contract application

**Essentially none.** No decorated/structured-cospan work on finance or smart contracts was
found. "Formal Analysis of Composable DeFi Protocols" (Springer, FC'21 workshops) is
**process-algebraic, not categorical**. "Higher Categorical Cryptoeconomics" appears only on
ResearchGate — treat as non-credible.

### Verdict

> **Poor fit.** Cospans model *gluing along interfaces* with total, monotone, functorial
> composition; the data is an idempotent set with no interfaces and non-monotone hazards.
> Take the **nested application conditions** machinery and leave the PROP behind.

---

## 2. Open games / compositional game theory; categorical cybernetics, optics and lenses

### Signature and carrier

Ghani, Hedges, Winschel & Zahn, *Compositional Game Theory*, LICS 2018
([arXiv:1603.04641](https://arxiv.org/abs/1603.04641)), Definition 3. An **open game**
`G : (X,S) -> (Y,R)` is a 4-tuple `G = (Σ_G, P_G, C_G, B_G)`:

- `Σ_G` — set of strategy profiles
- `P_G : Σ_G × X -> Y` — **play**
- `C_G : Σ_G × X × R -> S` — **coplay** (coutility)
- `B_G : X × (Y -> R) -> Rel(Σ_G)` — **best response**: given an observation and a
  *continuation* `k : Y -> R`, a relation on strategy profiles.

Verbatim from the paper: *"In general, we impose no conditions whatsoever on these
components."* `X` = observation in, `S` = coutility out (contravariant), `Y` = move out,
`R` = utility in from the future. These `(X,S)/(Y,R)` boundary pairs are exactly **lens /
optic** boundaries, which is why later work reformulates everything in terms of optics
(Riley, *Categories of Optics*, [arXiv:1809.00738](https://arxiv.org/abs/1809.00738)).

### Operations and which laws hold

Sequential composition (Def 9) for `G:(X,S)->(Y,R)`, `H:(Y,R)->(Z,Q)`:
`Σ_{H∘G} = Σ_G × Σ_H`; `P_{H∘G}((σ,τ),x) = P_H(τ, P_G(σ,x))`;
`C_{H∘G}((σ,τ),x,q) = C_G(σ, x, C_H(τ, P_G(σ,x), q))`; and
`((σ,τ),(σ',τ')) ∈ B_{H∘G}(x,k)` iff `(σ,σ') ∈ B_G(x,k')` **and** `(τ,τ') ∈ B_H(P_G(σ,x), k)`.

Tensor (Def 12): `Σ_{G₁⊗G₂} = Σ_{G₁} × Σ_{G₂}`, play/coplay componentwise, equilibrium the
**conjunction** of both components' conditions.

**Associativity.** The paper is explicit: *"Open games trivially cannot form a category,
because this composition operator is not associative on the nose"* — because
`(Σ_G × Σ_H) × Σ_I ≠ Σ_G × (Σ_H × Σ_I)`. Def 10 fixes this by an equivalence relation
identifying open games with isomorphic strategy sets. So: **SMC of equivalence classes;
strictly associative only after quotienting.**

There is **no** claim that open games form a symmetric monoidal *bicategory*. What exists:
Hedges, *Morphisms of open games* ([arXiv:1711.07059](https://arxiv.org/abs/1711.07059)) — a
symmetric monoidal **double category** (horizontal 1-cells = open games, vertical
1-morphisms = lenses). Atkey, Gavranović, Ghani, Kupke, Ledent & Nordvall Forsberg,
*Compositional Game Theory, Compositionally* ([arXiv:2101.12045](https://arxiv.org/abs/2101.12045),
ACT 2020) builds the SMC via a colimit over sets-and-bijections — *"taking the colimit over
the category of sets and bijective functions is crucial… This quotient is important to
prove the associativity of arrow composition"* — and criticises the original 8-tuple
definition as itself non-compositional. Capucci, Gavranović, Hedges & Rischel, *Towards
foundations of categorical cybernetics*
([arXiv:2105.06332](https://arxiv.org/abs/2105.06332)) is where the **bicategory** lives:
`Para_•(C)` is a bicategory, and parametrised optics `Para_⊛(Optic(C,D))` (optic hom given by
the coend `∫^M C(X, M•Y) × D(M•Y', X')`) is the central object; open games are recovered as
parametrised optics plus a selection/equilibrium predicate. Capucci, Ghani, Ledent &
Nordvall Forsberg, *Translating Extensive Form Games to Open Games with Agency*
([arXiv:2105.06763](https://arxiv.org/abs/2105.06763), ACT 2021) adds explicit **player /
agency**, which base open games lack.

### Real DeFi / smart-contract application — thin but non-zero

- **20squares** (20squares.xyz, spinout, 2023) and the **CyberCat Institute** (non-profit, 2024).
- **Open Games Engine × HEVM** (blog.20squares.xyz/hevm/): OGE wired to the Haskell EVM so
  *deployed Solidity* is executed rather than reimplemented. Examples repo
  `github.com/CyberCat-Institute/hevm-games`. Two cases: a Prisoner's Dilemma contract
  (toy), and **Lido's Dual Governance** safety module for (w)stETH holders — ~600 lines of
  state-machine code, a genuinely shipped Ethereum mechanism (activated 2025). What is
  computed: **equilibrium checking of a supplied strategy profile**, plus enumeration of
  profitable deviations.
- **PBS auctions**: Genovese & Palombi, "Making sense of PBS auctions via compositional
  game theory", EthCC talk, 17 July 2023. **No peer-reviewed paper or artifact found —
  talk only.**
- An `amm.act` example exists in the engine repo. **No AMM security result found.**

Blunt: consultancy-grade modelling of *individual* mechanisms. Not a library of composable
DeFi primitives, not automated verification. Lido Dual Governance is the strongest datapoint.

### Fit and non-monotonicity

Open games compose by **wiring typed boundaries**; strategy sets compose by **cartesian
product**, not union — so no idempotence. A component's behaviour depends *only on what is
wired into its ports*, never on the ambient presence of another element elsewhere in the
diagram. The 29 laws are ambient-presence triggers over an unstructured set; there is no
such thing in open games. Using this framework requires inventing the wiring the data does
not have — and the non-injectivity observation (USDT ≡ USD1 as element sets) says precisely
that the wiring is the *missing* information.

Non-monotonicity: open games *are* non-monotone in **equilibria** (adding a subgame changes
`B` of the whole; the continuation `k` must be recomputed). But that non-monotonicity lives
in the **semantics**, never in **well-formedness**. Every type-correct composite is a legal
open game; there is no forbidden-combination notion. A degenerate encoding exists — since
`B` is an arbitrary relation with no conditions imposed, a hazard component with `B = ∅`
makes the whole composite have no equilibrium by the conjunctive rule — but this is a global
poison: it does not localise which combination fired and abuses equilibrium as a validity flag.

### Decidability and tooling

The definition imposes **no computability conditions** (`Σ` an arbitrary set, `B` an
arbitrary function into `Rel(Σ)`), so equilibrium checking is **undecidable in general**.
For finite games the library handles, checking one profile costs one payoff evaluation per
unilateral deviation per player, `O(Σ_i |Σ_i|)` runs of play-then-coplay through the diagram.
*Finding* equilibria is the hard part.

`open-games-hs` / `CyberCat-Institute/open-game-engine` (Haskell, ~193 stars, 366 commits,
self-described *"work in progress"*): you write the game in a block DSL, **supply a strategy
profile yourself**, and it reports equilibrium yes/no plus deviations. **A checker, not a
solver** — no equilibrium search.

### Verdict

> **Wrong tool.** Open games encode wired, typed strategic interaction with product-composed
> strategies. They have no representation for a set of components, presence-triggered laws,
> or forbidden-combination hazards. Fashionable, and genuinely deployed on Lido — but it
> answers "is this mechanism incentive-compatible", not "is this set of mechanisms legal".

---

## 3. Interface automata and assume-guarantee contract algebra

**This is the richest algebra in the survey, and the sources are unusually precise about
which laws hold. Read this section closely — the received wisdom in the 2018 monograph has
been superseded by Incer's 2022 thesis on three separate points.**

Primary sources: Benveniste, Caillaud, Nickovic, Passerone, Raclet, Reinkemeier,
Sangiovanni-Vincentelli, Damm, Henzinger & Larsen, *Contracts for System Design*, FnT-EDA
2018 ([CPS School copy](https://www.cpsschool.eu/wp-content/uploads/2018/09/main_contracts.pdf);
[INRIA RR-8147](https://people.rennes.inria.fr/Albert.Benveniste/pub/RR-8147.pdf)); Iñigo
Incer, *The Algebra of Contracts*, UC Berkeley EECS-2022-99; Incer & Benveniste,
*AG contract algebras are dp-algebras* ([arXiv:2402.12514](https://arxiv.org/html/2402.12514v3));
Incer, *Composition and Merging Are Tensor Products* ([arXiv:2405.06052](https://arxiv.org/abs/2405.06052));
Pacti ([arXiv:2303.17751](https://ar5iv.labs.arxiv.org/html/2303.17751)).

### 3.1 Carrier and saturation

Fix variables `V`, domain `D`; an **assertion** is a set of behaviors. A **contract** is a
pair `C = (A, G)`. Verbatim (monograph §5.1):

> *"any component M such that `M ⊆ G ∪ ¬A` is an implementation of C. Thus, contract
> `C = (A,G)` is consistent iff `∅ ≠ G ∪ ¬A`, and in this case `M_C = G ∪ ¬A` is the maximal
> (for set inclusion) implementation of C."*
>
> *"Say that contract `C = (A,G)` is **saturated** if `G = G ∪ ¬A`, or, equivalently, if
> (5.6) `G ∪ A = ⊤` … C is equivalent to its saturated form `(A, G ∪ ¬A)`."*

Boolean-algebra version (arXiv:2402.12514): `(a,g)` is saturated iff `g = g ∨ ¬a`,
equivalently `a ∨ g = 1`, equivalently `¬a ∧ ¬g = 0`.

**Why saturation matters.** Two contracts with equal `A` and equal `G ∪ ¬A` have *identical
implementation sets*, hence are equivalent. Saturation picks the canonical representative,
turning the refinement preorder into a **partial order** and letting every operation be given
in closed form on pairs. Monograph Comment 5.4: *"getting saturated contracts is important in
applying this contract algebra"* — it requires computing `G ∪ ¬A`, i.e. the entailment
`A ⇒ G`. Incer's thesis Fig. 7.1 is titled **"Contract saturation is not injective"**: the
syntax carries more than the denotation. **Note this for later — it is the same phenomenon as
your USDT/USD1 problem, and the theory deliberately quotients it away.**

### 3.2 The operations, with real formulas

All for **saturated** contracts over an identical alphabet.

| Op | Formula | Source |
|---|---|---|
| **Refinement `≼`** | `C₂ ≼ C₁ iff A₂ ⊇ A₁ and G₂ ⊆ G₁` | Benveniste Def. 5.4.1 |
| **Composition `⊗`** | `G = G₁ ∩ G₂`, `A = (A₁ ∩ A₂) ∪ ¬(G₁ ∩ G₂)` | Benveniste eq. 5.7 |
| **Conjunction `∧`** (GLB) | `C₁ ∧ C₂ = (A₁ ∪ A₂, G₁ ∩ G₂)` | Benveniste Def. 5.4.2 |
| **Disjunction `∨`** (LUB) | `C ∨ C′ = (A ∩ A′, G ∪ G′)` | Incer thesis |
| **Quotient `/`** | `C₁/C₂ = max{C | C ⊗ C₂ ≼ C₁}`; closed form `C/C′ = (A ∩ (¬A′ ∪ G′), (A′∩G) ∪ ¬A ∪ (A′∩¬G′))` | Incer / Pacti |
| **Merging `•`** (fusion) | `C₁ • C₂ = (A₁ ∩ A₂, (G₁∩G₂) ∪ ¬A₁ ∪ ¬A₂)` | Incer Def. 5.1.1 |

**Refinement direction confirmed**: the *refining* contract has **weaker (larger)
assumptions and stronger (smaller) guarantees**.

**Important correction.** The 2018 monograph states verbatim, on the same page as its
composition theorem: *"No Least Upper Bound and no quotient are known for A/G contracts."*
**Incer's thesis explicitly cites that sentence (p. 188) and supersedes it** — both `∨` and
`/` now have closed forms. Do not brief the mathematicians off the 2018 monograph alone.

**Quotient is a true residual.** Meta-theory (4.10) plus **Property 7**:
`C ≼ C₁/C₂ ⟺ C ⊗ C₂ ≼ C₁`. That is a genuine **Galois adjunction**, conditional on Axiom 3
(the max exists and is unique) and Axiom 1.2 (LUB exists).

**Merging is not conjunction.** Incer proves merging is a *factor of the GLB* and composition
is a *factor of the LUB* — a real duality. Merging has its own adjoint, **separation**. With
implication and coimplication (adjoints of `∧`/`∨`), the thesis reports **eight** operations.

### 3.3 Which laws actually hold — verified

**Incer, Prop. 6.10.1 (verbatim):** `(C(B), ∧, 1)`, `(C(B), ∨, 0)`, `(C(B), ∥, id)`,
`(C(B), •, id)` are **idempotent, commutative monoids**. So **all four of `∧`, `∨`, `⊗`, `•`
are associative, commutative, idempotent, with identity.** Lemma 5.3.4: the composition and
merging identities coincide, `1_c = 1_m = (B(Σ), B(Σ))`; the lattice bounds are `(∅, B(Σ))`
and `(B(Σ), ∅)`.

**Lattice.** arXiv:2402.12514: *"the poset C(B) is in fact a **bounded distributive
lattice**"*, meet `(a,b)∧(c,d)=(a∪c, b∩d)`, join `(a,b)∨(c,d)=(a∩c, b∪d)`, `⊥=(1,0)`,
`⊤=(0,1)`; both meet- and join-pseudocomplements exist; Stone and co-Stone equalities hold.
Adding composition, the same paper concludes `C(B)` is a **bounded three-valued Sugihara
monoid**. **Completeness of the lattice (as opposed to boundedness) was not verified** — it
would inherit from completeness of `B`.

**Distributivity — the point the literature is routinely misread on.**

- Benveniste **Property 6 (sub-distributivity)**:
  `[(C₁₁ ∧ C₂₁) ⊗ (C₁₂ ∧ C₂₂)] ≼ [(C₁₁ ⊗ C₁₂) ∧ (C₂₁ ⊗ C₂₂)]`, with the explicit remark
  *"only refinement, not equality, holds"*. **This is a four-contract interchange/medial law,
  not plain distributivity.**
- Incer **Table 6.5 / Prop. 6.10.4** gives plain three-contract distributivity **with
  equality** in the Boolean-algebra AG algebra. Verbatim from the proof of Prop. 6.10.6:
  composition **distributes over disjunction**; conjunction distributes over disjunction;
  disjunction distributes over conjunction; merging distributes over conjunction;
  **"composition does not distribute over merging"**; **"merging does not distribute over
  composition"**.
- **Prop. 6.10.6: there are exactly four semirings** — `(C,∧,∨,1,0)`, `(C,∨,∧,0,1)`,
  `(C,∥,∨,id,0)`, `(C,•,∧,id,1)`.

> **So: `⊗` over `∧` holds with equality in the concrete AG/Boolean algebra; only
> sub-distributivity holds in the abstract meta-theory, and the meta-theory statement is a
> different (interchange) law. Do not conflate them.** This is the single most likely place
> for nine mathematicians to derive contradictory results from the same literature.

**Residuated lattice / quantale?** You have a commutative idempotent monoid `(⊗, id)`,
monotone in `≼`, on a bounded distributive lattice, with a residual satisfying Property 7 —
that *is* a commutative residuated lattice. **But no fetched source states "residuated
lattice" or "quantale" verbatim.** The closest verbatim claim is "bounded three-valued
Sugihara monoid" (a commutative distributive residuated lattice), plus Incer arXiv:2405.06052
describing composition and merging as *"part of the **tensor product structure** of the
algebra of contracts"*. **Treat the residuated-lattice reading as a well-supported inference,
not a quoted theorem** — and see §7c: this is a good problem to hand to one of the nine.

### 3.4 Interface automata (monograph Def. 8.5, after de Alfaro–Henzinger 2001)

Composition is defined only if `out₁ ∩ out₂ = ∅`. Then:

1. Pre-composition `C₁ × C₂` (i/o-automaton product).
2. **Illegal state** `q=(q₁,q₂)`: `∃ i,j ∈ {1,2}, j≠i, ∃ a ∈ shared-out` such that
   `qᵢ --a--> ` but `qⱼ` cannot accept `a` (eq. 8.23).
3. **Exception states** `E` = smallest set containing all illegal states and closed under: if
   `q --a--> q′` with `a ∈ out` and `q′ ∈ E`, then `q ∈ E`. **Backward closure over outputs
   only — precisely the uncontrollable-predecessor attractor of a safety game.**
4. **Pruning**: delete exception states and incoming transitions; iterate to a fixpoint
   `C^(K)`, reached *"in finitely many steps"*. `C₁ ⊗ C₂` is consistent and compatible
   **iff `Q^(K) ≠ ∅`**.

Optimism, verbatim: *"C₁ and C₂ are considered compatible as long as there is **some** input
behavior that ensures that, for **all** output behaviors, the illegal states are avoided …
compatible if there is some environment in which they can be used correctly together."*

Refinement = **alternating simulation** (Def. 8.4). Quotient: `(C₁ ⊗ C₂^⊥)^⊥` where `^⊥`
swaps inputs/outputs — *"the greatest interface compatible with C₂ such that their
composition refines C₁."*

**Associativity — decisive, and it goes AGAINST the original claim.** Verbatim from the
monograph:

> *"In [64,66] **Bujtor and Vogler proved that the parallel composition of Interface Automata
> fails to be associative.** The previous theorem shows that it is at least sub-associative."*

Modal Interfaces are worse: *"Axiom 4 of the meta-theory does not hold for Modal Interfaces …
Figure 8.1 shows a counterexample"*, and **Raclet et al.'s associativity claim is recorded as
erroneous**. By contrast **A/G contracts ARE associative** (Theorem 5.3: Axiom 4 holds;
*"Hence contract composition is associative"*). Also flagged in the monograph: for interface
automata *"no simple formula for the conjunction of contracts is known"*, and with variable
alphabets *"for conjunction no satisfactory construction exists."*

### 3.5 Non-monotone validity

Confirmed structurally: because binary IA/contract composition is only **sub-associative**,
the monograph says *"we must directly define the contract composition for **any arity**"* —
the *n*-ary composite is **not** recoverable from binary steps. **That is the formal
fingerprint of exactly the non-monotonicity you are chasing.**

**I did not find a verbatim theorem stating "adding a third interface can break a compatible
pair"** — flagged as unverified-as-quoted. It follows from the existential-over-environments
definition (the witness environment is not preserved when a third component instantiates part
of it) and from the associativity counterexamples, but it is an inference.

For A/G contracts the same effect is visible directly in eq. (5.7): composing in `C₃` gives
`G = G₁∩G₂∩G₃` (guarantees only shrink) and `A = (A₁∩A₂∩A₃) ∪ ¬(G₁∩G₂∩G₃)` — assumptions can
shrink, and the composite can become **inconsistent** (`G ∪ ¬A = ∅`). Analytic consequence of
the formula, not a quoted theorem.

**Independent implementability is a WEAKER guarantee — be precise, this is the trap.**
Property 3: *"Compatible contracts can be independently implemented."* Property 4
(independent refinement): if the `Cᵢ` are compatible and `Cᵢ′ ≼ Cᵢ`, then the `Cᵢ′` are
compatible **and** `⊗Cᵢ′ ≼ ⊗Cᵢ`. That is **monotonicity in refinement of a FIXED set of
components**. It says nothing about *enlarging* the set.

> **Refinement-monotone ≠ extension-monotone.** Brief the nine on this explicitly; it is the
> distinction most likely to be fumbled.

### 3.6 Decidability and complexity

- **Finite-state IA**: compatibility is **decidable** — the pruning fixpoint terminates in
  finitely many steps. The monograph says only *"see [103] for issues of computational
  complexity"* and **gives no numbers**. **No complexity figure was verified from a primary
  source this session.** The standard folklore (safety-game solving polynomial in the
  product; product exponential in the number of components; alternating simulation in PTIME)
  is **not** re-verified — do not put numbers in the brief without checking.
- **Pacti / polyhedral**: *"The terms are linear inequalities with real coefficients"*;
  variable elimination by refining/relaxing linear inequalities; **containment checking by
  linear programming**. The paper **provides no explicit complexity bounds** (verbatim from
  the ar5iv rendering).
- **LTL / temporal (OCRA)**: refinement reduced to entailment checks discharged by nuXmv /
  HyCOMP. **No complexity figure verified.** The commonly-cited 2EXPTIME is the LTL
  *realizability/synthesis* bound, not verified here and not obviously the right number.

### 3.7 Tooling

- **Pacti** (`pacti-org/pacti`, Incer & Sangiovanni-Vincentelli, Caltech–JPL): **alive**.
  Implements **composition, quotient, merging, refinement** over `PolyhedralIoContract` —
  linear inequalities/equalities over the reals. ~499 commits; journal version *Pacti:
  Assume-Guarantee Contracts for Efficient Compositional Analysis and Design*, **ACM TCPS
  2025**. Conjunction is not surfaced as a named user-facing operation in the getting-started
  docs.
- **OCRA** (FBK): alive-but-static. CLI for logic-based contract refinement; discrete and
  hybrid linear-time temporal logics; backed by nuXmv and HyCOMP; last release **v2.1.0,
  7 Feb 2021**; AF3-OCRA plugin for AutoFOCUS3.
- **Ticc, MICA, MIO Workbench, Chase, AGREE**: **status and capabilities could not be
  verified this session.** Do not assert anything about them.

### 3.8 Fit — blunt

**Interface automata: no. Drop them entirely.** Your carrier has no traces, no input/output
polarity, no receptiveness, no notion of "an output nobody can consume". Illegal states,
pruning, alternating simulation and the compatibility game have nothing to bite on.
Everything that makes IA interesting (optimism, environments, games) requires directed
communication your data does not contain. They are also **not associative**, which is a bad
foundation to hand nine mathematicians.

**A/G contract algebra: the best partial fit in the survey — you get the lattice half, and
none of the composition half.** Instantiate `B = 2^{58}` (the Boolean algebra of protocol
configurations), which is exactly the setting of the dp-algebra paper. Then:

- **The 29 laws encode cleanly and correctly.** Law `(s₁|s₂) → ⋀ₖ ⋁ⱼ eₖⱼ` becomes
  `C = (A, G)` with `A = ⟦s₁ ∨ s₂⟧`, `G = ⟦⋀ₖ ⋁ⱼ eₖⱼ⟧`; the saturated form `G ∪ ¬A` **is**
  the implication. **Note this beats FCA outright: the guarantee is an arbitrary Boolean
  assertion, so disjunctive conclusions are native, no doubled alphabet required.**
- **Conjunction gives exactly your intended semantics.** `(⋃Aᵢ, ⋂Gᵢ)`: the union of
  assumptions is "fires if any subject present", the intersection of guarantees is "every
  fired law must hold". Monograph Comment 5.1 states precisely this: when `A₂` fails, `C₂` is
  relieved of `G₂` but `C₁` survives. And by Prop. 6.10.1 the 29 laws form an **associative,
  commutative, idempotent monoid under `∧` with identity** — conjoin the rulebook in any
  order, duplicates free.
- **Refinement is a real, cheap win.** `L₁ ≼ L₂ iff A₁ ⊇ A₂ and G₁ ⊆ G₂` is a rigorous
  "L₁ is strictly stricter than L₂", directly usable to **detect redundant and subsumed laws
  among the 29** — the same job you hoped the DG base would do, but on the correct
  (disjunction-carrying) syntax.
- **Hazards encode, but only one way works.** The naive `(⊤, ¬(e₁∧e₂∧e₃))` is **fatal**:
  conjoining it with the laws takes the **union** of assumptions, which collapses to `⊤` and
  destroys the conditional structure of every law. The correct encoding is
  **`A = ⟦e₁∧e₂∧e₃⟧, G = ∅`** — saturating to `G ∪ ¬A = ¬(e₁∧e₂∧e₃)`, a contract that is
  globally consistent but has **no implementation under the hazardous environment**. That is
  the right algebraic reading of "forbidden combination" and it composes correctly with the
  laws. **Put this encoding in the brief verbatim; it is the highest-value single result in
  this document.**
- **Composition `⊗` is meaningless here, and therefore so is quotient.** `⊗` presupposes a
  component-composition on the carrier modelling two *interacting* objects. Protocols do not
  interact through ports; "combining" two protocols is set union of elements, whose
  spec-level counterpart is conjunction/merging, not `⊗`. Since the quotient is *defined as
  the residual of `⊗`* (Property 7), killing `⊗` kills `/`, `•`, and separation. **You lose
  roughly six of the eight operations.** What survives — `≼`, `∧`, `∨` — is exactly the
  bounded distributive lattice, i.e. the powerset lattice you already have.
- **Non-injectivity is fatal to the abstraction, and contract algebra cannot repair it.** The
  theory is denotational: objects with equal denotation *are* equal. If
  `α(USDT) = α(USD1)` as element sets, every operation is invariant on the fiber `α⁻¹(S)` and
  will faithfully report the two as equivalent. Incer's thesis makes the same point in the
  opposite direction (Fig. 7.2, *"the contract syntax carries more information than its
  denotations"*) — there the surplus is deliberately quotiented away. **No algebra recovers
  information the abstraction discarded.**

### Verdict

> **The single best fit, but only its lattice fragment — and it says your composition
> question is the wrong question.** Take the assumption/guarantee split with saturation (which
> reproduces "relieved when the subject is absent" for free, and carries disjunctive heads
> natively), the refinement preorder for deduplicating the rulebook, and the
> `A = hazard, G = ∅` encoding. Leave composition, quotient, merging, separation, and
> interface automata behind — they need ports you do not have.

---

## 4. Feature models / software product lines

### Why it matters most, stated first

Your data maps onto feature-model constructs almost one-to-one, and this correspondence is
the reason to chase it down properly:

| Your object | Feature-model construct |
|---|---|
| 58 elements | features |
| **family** (mutual substitutes) | **alternative / XOR group** (or OR group if co-selection is allowed) |
| **stratum S0–S4** (prerequisite depth) | **tree depth / chains of `requires`** |
| protocol = SET of elements | a **configuration** ⊆ 2^F |
| 29 laws `(s₁|s₂) → ⋀ₖ⋁ⱼ eₖⱼ` | **cross-tree constraints** — arbitrary propositional formulas, so **disjunctive heads are native** |
| 20 hazard rules | **`excludes`** constraints |
| non-monotone validity | **native** — `excludes` means adding a feature invalidates a configuration |

**No other framework in this survey takes all seven rows without an encoding trick.**

### Signature and carrier

`FM = (F, CT)`: a finite feature set `F` plus constraints `CT`, split into **hierarchical
constraints** (the parent–child tree: mandatory / optional / or-group / alternative-xor-group)
and **cross-tree constraints** (arbitrary propositional formulas over `F`). Verified verbatim,
Sundermann et al., *Exploiting d-DNNFs for Repetitive Counting Queries on Feature Models*
([arXiv:2303.12383](https://arxiv.org/abs/2303.12383), §3.1): *"we define feature models as
tuple FM = (FT, CT)… It is well-known that each hierarchical constraint (i.e., alternative,
or, mandatory, and optional) can be translated to a propositional formula."*

A configuration is `C = (I, E)` with `I ∩ E = ∅`; **complete** if `I ∪ E = F`, else
**partial**; **valid** iff complete and satisfying all of `CT`. **`⟦FM⟧ = VC_FM ⊆ 2^F`** — the
semantics of a feature model is exactly a set of subsets of `F`. Everything else is derived.

### Compilation to propositional logic (Batory, SPLC 2005 / UT TR-05-14) — read directly

Batory routes feature diagrams through **iterative tree grammars**, then to formulas.
Variables = tokens (leaf features) ∪ non-terminal names ∪ **pattern names**. Verbatim rules,
for `r : P1 | … | Pn`:

| Reference | Formula |
|---|---|
| `r` | `r ⇔ choose1(P1,…,Pn)` |
| `r+` | `r ⇔ (P1 ∨ … ∨ Pn)` |

where `choose1(e1…ek)` = **"at most one of `e1…ek` is true"**, generalised to `choose_{n,m}`
= "at least n and at most m"; `r*` is encoded as `[r+]`. **Patterns**: for pattern `P` with
all-mandatory terms `t1…tn`, `P⇔t1 ∧ … ∧ P⇔tn`; for `Q = t1 [t2] … tn` with `t2` optional,
`Q⇔t1 ∧ t2⇒Q ∧ … ∧ Q⇔tn`. **Grammar** = conjunction of every production and pattern formula
plus the premise `root = true`. Batory's worked example:
`e = true ∧ e⇔r ∧ e⇔s ∧ r⇔choose1(G,H,I) ∧ s⇔A ∧ s⇔C ∧ B⇒s`.

Flattened to the per-construct form every modern tool actually emits (FeatureIDE / flamapy /
UVL), parent `p`, children `c₁…cₙ`:

- **root**: `r`
- **mandatory** child `c`: `c ⇔ p`
- **optional** child `c`: `c ⇒ p`
- **or-group**: `(c₁ ∨ … ∨ cₙ) ⇔ p`
- **xor / alternative**: `(c₁ ∨ … ∨ cₙ) ⇔ p  ∧  ⋀_{i<j} ¬(cᵢ ∧ cⱼ)`
- **requires** `a→b`: `a ⇒ b`
- **excludes** `a↮b`: `¬(a ∧ b)`

> **Implementation trap:** Batory's `choose1` is literally defined as *"at most one"*;
> exactly-one falls out of the biconditional with the parent plus root-truth. If you
> implement from his table alone you will get it wrong — use the expanded xor clause above.

**Batory explicitly rejects requires/excludes as sufficient**: *"we concluded that non-grammar
constraints should be arbitrary propositional formulas"*, with motivating examples
`F implies A or B or C` and `F implies (A and X) or (B and (Y or Z)) or C`. **That second
example is exactly the shape of your 29 laws.** He also notes feature diagrams have **no
unique representation** — many diagrams, one formula; two FDs are equivalent iff their
formulas are.

### The standard analyses (Benavides, Segura & Ruiz-Cortés, *Information Systems* 2010; cross-checked against the live flamapy operation list)

**SAT-level** (one or few solver calls): *void FM* (`SAT(φ)` false); *valid product*
(`SAT(φ ∧ ⋀I ∧ ⋀¬E)`); *valid partial configuration*; *dead feature* `f` (`φ ∧ f` UNSAT);
*core feature* `f` (`φ ∧ ¬f` UNSAT — equivalently the SAT **backbone**); *false-optional* `f`
(declared optional but `φ ∧ parent(f) ∧ ¬f` UNSAT); *conditionally dead*; *redundant
constraint* `c` (`φ∖c ∧ ¬c` UNSAT); *wrong cardinality*; *atomic sets* (maximal feature groups
that always co-occur — polytime by mandatory-edge collapsing, or exactly via implication
equivalence classes).

**Counting-level** (verbatim Defs. 1–3 of arXiv:2303.12383): *number of products*
`#FM = #SAT(φ)`; *feature cardinality* `#f = #SAT(φ ∧ f)`; *partial-config cardinality*.
Derived: *commonality* `#f/#FM`; *variability factor* `#FM/2^|F|`; *homogeneity*;
feature-inclusion probability; uniform random sampling.

**Edit-level**: the Thüm/Batory/Kästner classification of `FM → FM'` into **refactoring**
(`⟦FM⟧ = ⟦FM'⟧`), **specialization** (`⟦FM'⟧ ⊂ ⟦FM⟧`), **generalization** (`⟦FM'⟧ ⊃ ⟦FM⟧`),
**arbitrary edit** — decided by two implication checks. *(Recalled, not re-read this session.)*

**Explanations**: why a feature is dead / a constraint redundant / the model void = extract a
**minimal unsatisfiable subset (MUS/MUC)**, or run diagnosis (FastDiag / QuickXplain).
flamapy exposes `Diagnosis` and `Conflict Detection`.

### Complexity — verified

- Void FM, valid product, dead / core / false-optional, redundancy, refactoring and
  specialization checks: **NP-complete / coNP-complete** (plain SAT and UNSAT queries). Dead
  features naively `|F|` SAT calls; core `|F|` more; in practice **one backbone computation**.
- Counting (`#products`, commonality, variability factor, homogeneity, feature
  probabilities): **#P-complete** (#SAT). Hence the field compiles once to **d-DNNF**
  (linear-time counting in the size of the compiled circuit) and reuses it: *"compiling to
  d-DNNF is similarly complex as solving a #SAT problem"* but amortizes over thousands of
  queries and is *"substantially faster than compiling to binary decision diagrams"*.
- Genuinely polynomial: atomic sets by tree collapsing, depth/branching metrics, leaf counts,
  syntactic well-formedness.
- Empirically SAT on real feature models is easy (Mendonça et al.). **At 58 elements this is
  milliseconds and total enumeration of `⟦FM⟧` is often outright feasible.**

### Composition of feature models — yes, and it is a real operator algebra

Acher, Collet, Lahire & France, *Composing Feature Models* (SLE 2009) and the **FAMILIAR**
DSL (*Science of Computer Programming* 78(6):657–681, 2013). The operator set was confirmed
**directly in the FAMILIAR source**: `fr.familiar.operations.FMLMerger` declares
`intersection()` and `union()`; `MergeAnalyzer` switches on `Mode.Intersection`,
`Mode.StrictUnion`, `Mode.Diff`; plus `AggregatorFM`, `FMSlicer`.

Semantics on configuration sets:

| Operator | Semantics |
|---|---|
| `merge intersection(FM1, FM2)` | `⟦R⟧ = ⟦FM1⟧ ∩ ⟦FM2⟧` |
| `merge sunion` (strict union) | `⟦R⟧ = ⟦FM1⟧ ∪ ⟦FM2⟧` |
| `merge diff` | `⟦R⟧ = ⟦FM1⟧ ∖ ⟦FM2⟧` |
| `aggregate` | new synthetic root, both models as mandatory subtrees — Cartesian product `⟦FM1⟧ × ⟦FM2⟧` when feature sets are disjoint |
| `insert` | graft FM2's tree under a designated feature of FM1 |
| `slice(FM, F′)` | projection `{ c ∩ F′ | c ∈ ⟦FM⟧ }` — existential quantification of eliminated variables |

**Laws.** At the **semantic** level `∩` and `∪` are associative, commutative and idempotent;
`diff` is neither. **Caveat that matters:** FAMILIAR returns a *diagram*, and diagram
synthesis from a formula is non-unique (Batory's own observation), so **associativity and
commutativity hold up to `⟦·⟧`-equivalence, not syntactically.**

FAMILIAR is **legacy-alive**: LGPL, Java/Xtext, last meaningful push 2026-01-07, Docker
`familiarlang/familiar:1.2` (beta). **Treat it as a reference for semantics, not a
dependency.** The umbrella term for the multi-model setting is **multi software product lines
(MSPL)**.

### The feature algebras — two different things, do not conflate

**(a) Höfner, Khedri & Möller, "Feature Algebra" (FM 2006) / "An algebra of product families"
(SoSyM 2011).** A **product family algebra** is a **commutative idempotent semiring**
`(S, +, ·, 0, 1)`: elements are product families; `+` is **choice** between families; `·` is
**mandatory composition**; `0` the empty family; `1` the family containing only a featureless
pseudo-product. Axioms: `+` associative, commutative, idempotent with identity `0`; `·`
associative with identity `1`; `·` distributes over `+` on both sides; `0` an **annihilator**.
The canonical model is sets of sets of features with `·` = pairwise union, **which makes `·`
commutative and idempotent**.
> *Flag: the paper itself could not be opened (hoefner-online.de unreachable, Springer
> gated). The reading of `+`, `·`, `0`, `1` is from a secondary summary; the axiom list is the
> standard mathematical definition, not a quotation. **Verify before relying on it.***

**(b) Apel, Lengauer, Möller & Kästner, "An Algebra for Features and Feature Composition"
(AMAST 2008, LNCS 5140:36–50).** Read in full. This is about **feature implementations** (code
trees), not configuration sets. Verbatim axioms:

- Introduction sum `⊕ : I × I → I` forms a **non-commutative idempotent monoid** `(I, ⊕, ξ)`:
  associativity `(k ⊕ j) ⊕ i = k ⊕ (j ⊕ i)`; identity `ξ ⊕ i = i ⊕ ξ = i`.
- **Non-commutativity**, verbatim: *"Since we consider superimposition of terminals,
  introduction sum is not generally commutative. We consider the right operand to be
  introduced first."*
- **Distant idempotence**: `i ⊕ j ⊕ i = j ⊕ i`; with `j = ξ`, direct idempotence `i ⊕ i = i`
  follows.
- Modification composition `• : M × M → M` forms a **non-commutative, non-idempotent monoid**
  `(M, •, ζ)`.
- `•` **left**-distributes over `⊕`: `m • (iₙ ⊕ … ⊕ i₁) = (m•iₙ) ⊕ … ⊕ (m•i₁)`.
- Together `(I, ⊕, ξ)` is a **semimodule** over `(M, •, ζ)`. **Not a semiring** — no
  annihilator, no inverses. Features are **quarks** `⟨g, i, l⟩`.

> **So: composition of *code* is NOT commutative (last-wins overriding); composition of
> *families* in (a) IS commutative, because it is set union. Both are idempotent, in different
> senses. Your protocols are sets — you want (a), not (b).** This distinction is the most
> likely thing for nine mathematicians to get wrong from a casual reading.

### Non-monotonicity — confirmed, and it is native

`excludes(a,b) ≡ ¬(a∧b)`: `{a}` valid, `{a,b}` invalid — **adding an element destroys
validity.** Symmetrically, mandatory / or-group constraints make it **not anti-monotone
either**: `{a}` may be invalid while `{a,b}` is valid, since `a ⇒ (b ∨ c)` forces a companion.
So `⟦FM⟧` is in general **neither upward- nor downward-closed under `⊆`; it is an arbitrary
subset of `2^F`**, since cross-tree constraints are arbitrary propositional formulas (Batory's
explicit design decision — any Boolean function is realizable).

> **Feature models are exactly the formalism for non-monotone set validity. No other candidate
> in this survey gets both directions for free.** And note that your data exhibits *both*: laws
> give the "adding an element makes an invalid set valid" direction, hazards the reverse.

### Tooling — verified live, August 2026

- **FeatureIDE** (Eclipse): **alive**. v3.12.0 released 2026-03-11, repo pushed 2026-04-29,
  146★, 127 open issues.
- **flamapy** (Python): **alive**, `flamapy_fw` pushed 2026-07-03; 40+ operations; back-ends
  PySAT (10+ solvers), CUDD BDD, ApproxMC/UniGen (approximate counting + uniform sampling),
  Z3, SharpSAT. Browser IDE `flamapy.ide`. **This is the pragmatic choice.**
- **UVL** (Universal Variability Language): the community-standard text format; three levels
  (Boolean / Arithmetic / Type); parser repo pushed 2026-07-02; consumed by FeatureIDE and
  flamapy; UVLHub is the model repository. Paper: Benavides, Sundermann, Feichtinger, Galindo,
  Rabiser & Thüm, *JSS* 2024.
- **FaMa / FLAMA**: superseded by flamapy. **SPLOT**: legacy, largely unmaintained.
  **Clafer / ClaferMoo**: dormant. Compilers **c2d / d4 / dSharp / sharpSAT / ddnnife** are the
  counting substrate.

### Fit — and what it cannot do

**Mapping.** 58 elements → `F`. Family (mutual substitutes) → **alternative/xor-group** under
a synthetic family root — **use an or-group instead if two members of a family can co-occur;
check this per family, it changes the clauses.** Stratum S0–S4 → *not* tree depth in general,
but assertable as `⋀ (e ⇒ ⋁ prerequisites at stratum−1)`. Protocol → a configuration `C ⊆ F`.
The 29 laws → cross-tree constraints, *precisely* the shape Batory added arbitrary
propositional constraints for. The 20 hazard rules → `excludes`.

**What you get for free at `|F| = 58`:** void check, **dead elements** (mechanisms no protocol
can use), **core elements** (universal), **false-optionals** (things you *declared* optional
that are actually forced), **redundant laws**, **MUS explanations for every hazard**,
commonality per element, and the refactoring/specialization/generalization test for **every
edit to the law set**. SAT is trivial, `#SAT` is trivial, and you can likely enumerate `⟦FM⟧`
outright.

**What feature models cannot do:**

1. **The non-injectivity is invisible to the formalism.** If USDT and USD1 have identical
   feature sets they are *the same point* in `⟦FM⟧`. Feature models quotient reality by the
   feature alphabet; any real difference (credit quality, issuer solvency, redemption legal
   enforceability) that is not a feature simply does not exist. Options: add discriminating
   features, or move to **attributed / extended feature models** (numeric attributes +
   CSP/SMT instead of SAT) — flamapy supports attributes and Z3, but **you lose the cheap
   #SAT story**.
2. **No quantities, no degree.** A Boolean core cannot say "80% collateralized".
3. **No dynamics.** No time, no state transitions, no "this protocol became insolvent". A
   static configuration space, not a process.
4. **No semantics for strata beyond implication.** S0–S4 is your assertion; the formalism will
   happily accept a stratum assignment that contradicts your requires-chains. **Check
   consistency explicitly — it is a cycle/level check on the implication graph, polytime.**
5. **Composition is over configuration sets only.** `merge`/`aggregate` give `∩`, `∪`, `∖`, `×`
   on config sets, but nothing about whether the composed protocol *behaves* correctly.

### Verdict

> **Near-exact fit — your object *is* a feature model.** Families are xor/or-groups, strata
> are `requires`-chains, the 29 laws are literally the case Batory introduced arbitrary
> propositional cross-tree constraints for, hazards are `excludes`, and non-monotone validity
> is native in both directions. Encode it in **UVL** and analyse with **flamapy** rather than
> building anything. Composition exists and is real (FAMILIAR `∩`/`∪`/`∖`/`×`/`slice`), with
> the honest caveat that the laws hold up to semantic equivalence, not syntactically.

---

## 5. Formal Concept Analysis, concept lattices, the Duquenne–Guigues base

### Signature and carrier

A **formal context** `K = (G, M, I)`, `I ⊆ G × M`. **Derivation operators** (verbatim, Babin
& Kuznetsov): `A′ = {m ∈ M | gIm ∀g ∈ A}` for `A ⊆ G`; `B′ = {g ∈ G | gIm ∀m ∈ B}` for
`B ⊆ M`. Antitone Galois connection: `A₁ ⊆ A₂ ⇒ A₂′ ⊆ A₁′`, `A ⊆ A″`, `A′ = A‴`. Both `(·)″`
are closure operators (idempotent, extensive, monotone).

A **formal concept** is `(A,B)` with `A′ = B`, `B′ = A`. Order:
`(A₁,B₁) ≤ (A₂,B₂) :⟺ A₁ ⊆ A₂ ⟺ B₁ ⊇ B₂`. The **concept lattice** `B(K)` is complete:
`⋀(Aₜ,Bₜ) = (⋂Aₜ, (⋃Bₜ)″)`, `⋁(Aₜ,Bₜ) = ((⋃Aₜ)″, ⋂Bₜ)`.

**Basic theorem (Wille 1982)**: `V ≅ B(G,M,I)` iff there exist `γ: G -> V`, `μ: M -> V` with
`γ(G)` supremum-dense, `μ(M)` infimum-dense, `gIm ⟺ γg ≤ μm`. **Corollary: every complete
lattice is isomorphic to some concept lattice.** Finite case: `L ≅ B(J(L), M(L), ≤)` —
join-irreducibles × meet-irreducibles, the *standard context*.

**For your data the context is textbook: objects = protocols, attributes = elements.**

### Implications and the DG base

`X → Y` **holds in K iff `X′ ⊆ Y′`** (equivalently `Y ⊆ X″`). Armstrong rules (verbatim):
`A → A`; `(A → B) / (A ∪ C → B)`; `(A → B, B ∪ C → D) / (A ∪ C → D)`. Intents form a closure
system; the valid implications are exactly a **pure Horn theory** whose models are the intents.

**Pseudo-intent**, verbatim (Babin & Kuznetsov): *"a set `P ⊆ M` is a pseudo-intent if
`P ≠ P″` and `Q″ ⊂ P` for every pseudo-intent `Q ⊂ P`."* Equivalently: a nonclosed `P` is a
pseudo-intent iff `P` is **quasi-closed** (for any `R ⊆ P`, `R″ ⊆ P` or `R″ = P″`) and
`Q″ ⊆ P` for any quasi-closed `Q ⊂ P`.

**Duquenne–Guigues base** = `{P → P″ \ P : P pseudo-intent}` (Guigues & Duquenne 1986). Also
called the *stem base* or *canonical base*.

### Minimality — get this right

- **Minimum in the NUMBER of implications** among all complete sets. Confirmed.
- **Canonical**: the set of pseudo-intents is uniquely determined by `K`. But
  minimum-cardinality bases in general are **not unique** — other bases of the same size
  exist whose premises need not be pseudo-intents (though their closures are the *essential
  intents*, `A = P″` for `P` pseudo-intent).
- **NOT minimum in total size** (sum of premise + conclusion cardinalities). Minimum-total-size
  bases are a different object, the **optimum base**. *(NP-hardness of minimum covers in the
  functional-dependency setting — Ausiello/D'Atri/Saccà — is recalled, not re-verified.)*
- Bertet & Monjardet's **canonical direct basis** is a third object: the unique minimal
  *direct* (single-pass closure) basis, coinciding with five independently-proposed bases;
  generally **larger** than the DG base.

### Computation and complexity — verified

- **NextClosure** (Ganter 1984) enumerates closed *and* pseudo-closed sets in **lectic
  order**, yielding the DG base. Because it emits all intents too, it is **not**
  output-polynomial in `|DG base|`.
- **Kuznetsov, JUCS 10(8), 2004**: the stem base can be **exponential** in `|K|`, and
  determining its size is **#P-hard**. (Kuznetsov & Obiedkov, *DAM* 156(11):1994–2003, 2008,
  "Counting pseudo-intents and #P-completeness".) Since *recognition* is coNP-complete,
  "#P-hard" is the safe claim.
- **Babin & Kuznetsov, CLA 2010** (verified from PDF): *"The problem of recognizing whether a
  subset of attributes is a pseudo-intent is shown to be coNP-hard, which together with the
  previous results means that this problem is **coNP-complete**."* Recognizing an **essential
  intent is NP-complete**; recognizing the lectically largest pseudo-intent is coNP-hard,
  hence **pseudo-intents cannot be generated with polynomial delay in the dual-lectic order
  unless P = NP**. Their own conclusion: whether they can be generated with polynomial delay
  in *arbitrary* order *"remains an important open problem."*
- **Distel & Sertkaya, DAM 159(6):450–466, 2011**: pseudo-intents *"cannot be enumerated in a
  specified lexicographic order with polynomial delay unless P = NP"*; unordered, the problem
  is *"at least as hard as enumerating minimal transversals of a given hypergraph"*;
  recognizing **minimal** pseudo-intents is polynomial, yet they *"cannot be enumerated in
  output-polynomial time unless P = NP."*
- **Output-polynomial computation of the DG base is OPEN.** Distel, ICFCA 2011, verbatim:
  *"…This leaves the question whether it can be enumerated in output-polynomial time. Until
  now, no output-polynomial algorithm has been found, and it is also not known whether such
  an algorithm exists."* Still described as unsettled in 2022 ([arXiv:2202.05536](https://arxiv.org/html/2202.05536)).
  **At 58 attributes this is a non-issue in practice — but do not let anyone claim it is easy
  in general.**

### Stratum as a lattice level — NO

There is **no standard rank function on concept lattices**. Gradedness needs the
Jordan–Dedekind chain condition, and by the basic theorem *every* complete lattice is a
concept lattice, so concept lattices are arbitrary and generally **not graded**. Searches for
"graded concept lattice" return only **fuzzy / L-graded FCA** (Bělohlávek), which means
graded *attributes* — a different thing entirely. Non-canonical surrogates: intent
cardinality `|B|`, or diagram height (not an invariant unless graded).

> **Encode stratum as extra attributes by ordinal scaling** — four columns `s≥1, s≥2, s≥3,
> s≥4`. This is standard conceptual scaling and it is the honest move. Adjacent formalism
> worth naming in the brief: **Knowledge Space Theory** (Doignon–Falmagne) handles
> prerequisite depth natively and links to FCA via Birkhoff.

### Composition — real operators, one clean law

- **Apposition `K₁ | K₂`**: same `G`, disjoint attributes — `(G, M₁ ⊎ M₂, I₁ ⊎ I₂)`. Since
  `B′ = (B∩M₁)′₁ ∩ (B∩M₂)′₂`, the extents are exactly the intersections `X ∩ Y`. `B(K₁|K₂)`
  embeds injectively and meet-preservingly into `B(K₁) × B(K₂)`. **But
  `Th(K₁|K₂) ⊋ Th(K₁) ∪ Th(K₂)`** — cross-implications appear, so **bases do not compose**.
- **Subposition `K₁ / K₂`**: same `M`, disjoint objects. Here `X′ = X′₁ ∪ X′₂`, so
  **`X → Y` holds in `K₁/K₂` iff it holds in both**: `Th(K₁/K₂) = Th(K₁) ∩ Th(K₂)`. This is
  the one genuinely clean compositional law — adding protocols only *removes* laws (monotone),
  and it is exactly how attribute exploration extends a context by counterexamples. **The DG
  base of a subposition is still not derivable from the two DG bases; it must be recomputed.**
- **Relational Concept Analysis (RCA)** — verified: extends FCA to a *relational context
  family* (several contexts plus inter-object relations), iteratively scaling relations into
  new "relational attributes" and returning a *family* of mutually-referencing lattices as a
  least fixed point (Euzenat 2023 refoundation; Bazin et al. 2018 on-demand RCA). This is the
  genuine "composition of related contexts" story.
- Wille's subdirect decomposition (*Algebra Universalis* 1983), tensorial decomposition
  (*Order* 1985), and gluings via complete tolerance relations. **Citations from recall, not
  re-verified.**

### Non-monotonicity — better than expected

FCA implications are definite Horn clauses; the closure operator is monotone. But:

1. **`X → M` (implication into the full attribute set) is valid iff `X′ = ∅`** — i.e. "this
   combination cannot occur". **So mutual exclusion and invalidity are already expressible
   with no extension at all.** This is the single most useful fact here for the 20 hazard rules.
2. **Dichotomic / complemented scaling**: apposition `K | K̄` where
   `K̄ = (G, {¬m}, I̅)`, `g I̅ ¬m ⟺ ¬(gIm)`. Then `{a} → {¬b}` states incompatibility
   per-attribute. **Cost**: `|M|` doubles, and the doubled context contains large
   **contranominal scales** `(G,M,≠)` in which *every* subset of `M` is closed —
   `2^|M|` concepts (Babin & Kuznetsov). Intents and the DG base blow up badly. The theory
   stays Horn over the doubled alphabet: **you gain negative literals, not disjunction.**

### The fit — and the one real structural mismatch

- **Disjunctive premise `(s1|s2) -> T`: fully expressible**, split losslessly into
  `{s1} → T` and `{s2} → T`. The only cost is that the baseline implication count is the
  *split* count, not 29.
- **Disjunctive conclusion `X → (t1|t2)`: NOT an FCA implication, and not merely as a matter
  of notation — structurally.** Horn theories are exactly those whose model sets are closed
  under intersection, and the intents of any context are intersection-closed *by construction*.
  A disjunctive conclusion breaks intersection-closure, so **no context has such an
  implication among its valid implications.** *(Searches for disjunctive / generalized
  attribute implications found nothing standard — a negative search result, not a proof of
  nonexistence.)*
- **Workable encoding**: in the doubled context, `X → (t1 ∨ t2)` becomes the two *Horn*
  implications `X ∪ {¬t1} → {t2}` and `X ∪ {¬t2} → {t1}`. Correct logic (a clause with `k`
  positive literals splits into `k` definite clauses over the extended alphabet), but it
  requires the negated columns to be **real data**, and minimality then applies to 116
  attributes, not 58.

**Can the 29 laws be reduced to a smaller base?** Yes, well-defined *provided* every law is
Horn after premise-splitting: the split set generates a closure operator on `2^58`;
NextClosure runs on any closure operator given as a black box (this is what conexp-clj's
`canonical-base` does), and the DG base is minimum-cardinality. Because the split set is
itself complete for that closure system, **|DG base| ≤ |split set|** — a guaranteed
non-increase, **not** a guaranteed decrease. A real win needs genuine Armstrong-redundancy
among the 29. Two warnings: the DG-base premises are *pseudo-intents*, sets that need not
correspond to any law anyone wrote, which typically costs interpretability; and the DG base
is a base for the **closure system**, not for your asserted-law syntax — laws with
disjunctive conclusions must be excluded from the computation entirely or they silently
corrupt the closure operator.

### Non-injectivity: USDT vs USD1 — FCA gives you the diagnosis

**Clarification**: `K` is clarified if no two objects have identical intents and no two
attributes identical extents; clarifying replaces each class of identical rows/columns by one
representative, and `B(K) ≅ B(K_clarified)`. **Reduction**: additionally remove objects that
are intersections of other object rows (dually for attributes); the lattice stays isomorphic.
The reduced context of a finite lattice is its **standard context** `(J(L), M(L), ≤)`.

Consequence: **USDT and USD1 are literally the same object to FCA** — same object concept
`γg = ({g}″, {g}′)`, clarified into one row, contributing nothing beyond the first copy to
the implication theory. No implication and no DG base will ever distinguish them. That is not
an FCA defect; it is FCA handing you the diagnosis: **the element set is not a complete
invariant of a protocol.** Either add attributes (issuer, governance, collateral type,
jurisdiction, attestation regime) until the rows separate, or accept that the model is about
*mechanism classes*, not protocols.

### Tooling

**conexp-clj** (Borchmann, Clojure) — actively maintained, computes the canonical base and
runs attribute exploration; the practical default. **LinCbO** ("LinCbO: Fast algorithm for
computation of the Duquenne–Guigues basis", *Information Processing Letters*, 2021) is the
current fast DG-basis algorithm — point an implementation at this. Concept enumeration:
**In-Close** (Andrews), **FCbO/PCbO** (Krajča, Outrata, Vychodil). Python: **`concepts`**
(Sebastian Bank), **fcapy** (Dudyrev). *(conexp/Java, ToscanaJ, Galicia, FCART, LatViz —
recalled, not verified this session.)*

### Verdict

> **Best descriptive fit; cannot carry disjunctive heads, and is not a composition theory.**
> Objects = protocols, attributes = elements is exactly a formal context; hazards are already
> expressible as `X → M`; the DG base is the right notion of "the smallest set of laws"; and
> subposition gives the one clean composition law (`Th(K₁/K₂) = Th(K₁) ∩ Th(K₂)`). But
> disjunctive conclusions are structurally outside Horn, stratum is not recoverable as
> lattice level, and USDT/USD1 get clarified into a single row. **Use FCA to audit and
> minimise the law set, not to build the algebra.**

---

## 6. Institution theory / algebraic specification (CASL, Goguen–Burstall)

### Signature and carrier

Goguen & Burstall, *Institutions: Abstract Model Theory for Specification and Programming*,
**JACM 39(1):95–146, 1992**, Definition 1 (p.102). An institution is:
(1) a category **Sign** of signatures; (2) a functor **Sen: Sign -> Set**; (3) a functor
**Mod: Sign -> Cat^op**; (4) a relation **⊨_Σ ⊆ |Mod(Σ)| × Sen(Σ)** for each Σ, such that
for each `φ: Σ -> Σ′` the **Satisfaction Condition** holds:

> `m′ ⊨_Σ′ Sen(φ)(e)` **iff** `Mod(φ)(m′) ⊨_Σ e`

Slogan: *truth is invariant under change of notation*. Sentences translate covariantly,
models contravariantly (reduct). Goguen notes the earlier version used `Mod: Sign -> Set^op`;
`Cat` was adopted so that liberal institutions *are* institutions. Establishing the
Satisfaction Condition "can be nontrivial" even for equational logic.

### Operations (CASL structuring, model-class semantics — Fig. 4 of Mossakowski–Haxthausen–Sannella–Tarlecki)

Each `SP` determines `Sig[SP]` and `⟦SP⟧ ⊆ Mod(Sig[SP])`:

| Operator | Model-class semantics |
|---|---|
| **basic** | `{M ∈ Mod(Σ) | M ⊨ Γ}` |
| **union** `SP1 and SP2` | `Σ = Σ1 ∪ Σ2`; `{M | M|_Σi ∈ Mi, i=1,2}` — intersection-after-reduct |
| **translation** `SP with σ` | `{M ∈ Mod(Σ′) | M|_σ ∈ ⟦SP⟧}` — closed under preimage; renaming only |
| **hiding** `SP hide σ` | `{M|_σ | M ∈ ⟦SP⟧}` — direct image; **existential, second-order** |
| **extension** `then` | local-environment sugar over union |
| **free** `then free {SP2}` | `{M | M` is `Mod(ι)`-free over `M′ ∈ M2}`; initiality is the special case |
| **generic spec / instantiation** | parameters + fitting morphism; *"corresponds to a pushout construction"* — but the paper notes *"since parameterization may be expressed in terms of union and translation, we omit its semantics"*. **Pushout instantiation is derived, not primitive.** |

### Which laws hold

Union inherits associativity / commutativity / idempotence from signature union `∪` and set
intersection. **This is a derivation from the Fig. 4 rule; no explicit law-list theorem was
found in the fetched sources — treat as unverified.**

Pushouts require the signature category to be **finitely cocomplete** and the institution to
**admit amalgamation** (= exactness: `Mod` maps colimit cocones to limit cones; pushouts to
pullbacks).

**Blunt, verified finding: the CASL institution does NOT have amalgamation.** Klin,
Mossakowski & Tarlecki, *Amalgamation in the Semantics of CASL*: *"A major problem with the
semantics is the failure of the so-called amalgamation property in the Casl institution."*
The culprit is **subsorts** — implicit subsort embeddings are model components not named in
signatures. The fix is **enriched CASL signatures**, where subsort embeddings form a
*category* rather than a preorder; the extended model functor then has amalgamation and
definitional completeness. Relatedly, **Craig interpolation fails** for CASL's `SubPCFOL^=`,
holding only for the subsort-free sublanguage — and interpolation plus weak amalgamation are
exactly what the structured proof calculus needs for completeness.

### The "adding a generator conservatively" problem — this is the one thing it does uniquely well

CASL distinguishes three notions (footnote 3, verbatim): **model-theoretic** — `σ: SP1->SP2`
is conservative iff each `SP1`-model is the `σ`-reduct of some `SP2`-model;
**consequence-theoretic** — `SP2 ⊨ σ(φ)` implies `SP1 ⊨ φ`; **proof-theoretic** —
`SP2 ⊢ σ(φ)` implies `SP1 ⊢ φ` (coincides with consequence-theoretic for complete logics).
**The refinement calculus requires the model-theoretic notion**, and the `Derive` rule is
gated on a conservativity *oracle*.

Decidability, verified: *"checking conservativeness is at least as complicated as checking
non-provability… even checking conservativeness in first-order logic is **not recursively
enumerable**, and thus there is no recursively axiomatized complete calculus for this task."*
Worse (footnote 4): model-theoretic conservativity *"corresponds to second-order existential
quantification"* — one can build a specification whose extension is conservative **iff the
continuum hypothesis holds**.

Description-logic side (Lutz, Walther & Wolter, IJCAI-07, abstract verbatim): consequence-
theoretic conservative extension is **2ExpTime-complete for ALC**, *"2ExpTime-complete in
ALCQI, but **undecidable in ALCQIO**"*, and *"if conservative extensions are defined
**model-theoretically** rather than in terms of the consequence relation, they are
**undecidable already in ALC**."* (A summariser's table on the fetched PDF said "ExpTime" —
that was an error; the abstract is authoritative.)

Hets tooling: `Common/Consistency.hs` defines the lattice
`Inconsistent | Unknown | None | PCons | Cons | Mono | Def` (proof-theoretic → semantic →
monomorphic → definitional) plus a `ConservativityChecker` interface. CASL checks
conservativity by **syntactic sufficient criteria** — free types and recursive definitions
over them are always conservative.

### Tooling reality, 2026

**Hets**: alive but barely — last commit **7 Oct 2025**, 20,657 commits, **639 open issues**,
with a gap from Sept 2023 to Oct 2025. Bursty maintenance by a shrinking group. Haskell
build, notoriously painful. **CASL** is a stable standard, effectively frozen. **Maude**
status could not be verified. **OBJ3** and **Specware** are dead. Treat the whole stack as
academic infrastructure, not production tooling.

### Non-monotonicity — cannot express it, and this is forced

Institution-based specification is **structurally monotone**, forced by the Satisfaction
Condition plus the Fig. 4 semantics. Adding axioms shrinks the model class; `and` is
*intersection* of reduct-preimages, so adding a spec only ever constrains further; `with` is
closed under preimage. **There is no operator in the calculus whose model class grows when
you add a component.** You can *state* a hazard as an axiom `¬(X ∧ Y)`, but then it is a
global constraint that was always there, not something *armed* by addition. `hide` is the one
genuinely non-trivial (existential, second-order) operator, but it hides symbols, not validity.

### Verdict

> **Too heavy, and the core semantics is monotone in exactly the wrong way.** Bringing
> institutions to 58 elements and 29 clauses is bringing category theory to a SAT fight —
> and you would pay for a framework whose central theorem (amalgamation) **fails in its own
> flagship language**. Steal two things and nothing else: (a) the three-way
> model-theoretic / consequence-theoretic / proof-theoretic split of *conservativity* and the
> Hets `Cons/Mono/Def` grading, as design vocabulary for "does adding this generator change
> what was derivable"; (b) the framing of parameterised instantiation as a pushout, so
> sharing is computed rather than left to name-collision luck.

---

## 7. Semiring / quantale structures for contracts

*(Researched directly; the session's web-search budget was exhausted partway, so several
items below rest on source code and bibliographic records rather than paper text — flagged
individually.)*

### 7a. Rigged Contracts (FLOPS 2024)

**Confirmed bibliographic record**: Alexander Vandenbroucke & Tom Schrijvers, *"Declarative
Pearl: Rigged Contracts"*, FLOPS 2024, pp. 99–114, DOI `10.1007/978-981-97-2300-3_6`.
Code: `github.com/tschrijv/RiggedContracts` (`Contract.hs`).

**I could not retrieve the paper text** (Springer paywall redirect; no README in the repo;
search budget exhausted). What follows is read **directly off the source code**, which is
unambiguous about the algebra even though it states no laws in comments.

The class is a **rig** (semiring, no additive inverses):

```haskell
class Semiring r where
  nil   :: r          -- additive identity
  unit  :: r          -- multiplicative identity
  plus  :: r -> r -> r
  times :: r -> r -> r
```

The contract language is Peyton Jones & Eber's (*Composing contracts: an adventure in
financial engineering*, ICFP 2000) combinators:

```haskell
data Contract obs = Zero | Both c c | Or c c | Give c | Truncate Time c
                  | Thereafter c c | One Currency | Scale obs c | Get c | Anytime c
```

**The actual claim, as realised in code.** `Contract obs` is *itself* given a `Semiring`
instance — `nil = expired`, `unit = zero`, `plus = or`, `times = both` — and valuation

```haskell
worth :: Multiplicative r => Financial r obs -> Contract obs -> Time -> r
```

is a **semiring homomorphism** out of it:

```
worth (Both c1 c2) = worth c1 `times` worth c2
worth (Or   c1 c2) = worth c1 `plus`  worth c2
worth Zero         = unit
worth (One k)      = exch k time
worth (Give c)     = inv (worth c)          -- multiplicative inverse
worth (Scale o c)  = eval o time (worth c)
```

So: **`Both` is the semiring product, `Or` is the semiring sum, `Zero` is the multiplicative
unit, `Give` is multiplicative inversion.** The instances shipped are `Double`
(`plus=(+)`, `times=(*)`), `Max a` and `Min a` (**tropical**: `plus = max`/`min`, `times`
defined piecewise), `Time` (`plus = max`, `times = min` — a horizon semiring), `Contract obs`
itself, and `Gradient a` (dual numbers, `times` by the product rule) plus
`Max (Gradient Double)`.

**The point of the pearl** is therefore: instantiate the *same* evaluator at different rigs
to get different analyses from one definition. In the **max-plus tropical rig** the
homomorphism reproduces exactly Peyton Jones & Eber's intended semantics — `Both` becomes
addition of cashflows, `Or` becomes `max`, `Zero` becomes 0, `Give` becomes negation. In the
`Gradient` rig you get **greeks by automatic differentiation** for free; in `Time` you get
horizon computation; `snell` in the `Financial` class handles American-style optionality via
the Snell envelope. *(This reading of the pearl's thesis is my inference from the code, not
a quotation from the paper — flagged.)*

**Laws.** A `Semiring` class with `nil/unit/plus/times` presupposes the usual rig axioms —
`plus` commutative monoid with `nil`, `times` monoid with `unit`, `times` distributes over
`plus`, `nil` annihilates. **The code states no laws in comments and I could not confirm from
the paper which are claimed or proved**, in particular whether `Or` is idempotent
(`Or c c = c`) — it is on `Max`/`Min` but *not* on `Double`, where `plus = (+)`. Note the
`Double` instance is **not** a faithful pricing model (`Both` would multiply values); the
tropical instances are the meaningful ones for money.

**Related DeFi realisation**: Biryukov, Khovratovich & Tikhomirov, *Findel: Secure Derivative
Contracts for Ethereum* (FC 2017; orbilu.uni.lu/handle/10993/30975) — *"a purely declarative
financial domain-specific language (DSL) well suited for implementation in blockchain
networks"*, with an Ethereum marketplace contract and gas-cost measurements. This is the
existence proof that PJ&E-style composable contracts run on chain. Also Frankau et al.,
"Commercial Uses: Going Functional on Exotic Trades" (Barclays, *JFP* 2009) — production use.

**Verdict (7a)**

> **Right shape, wrong subject.** The rig here is over *cashflow valuations of one
> contract's syntax tree*, not over *sets of mechanisms*. It gives no notion of validity,
> compatibility, or hazard. But it is the single best template in the literature for the
> move you may actually want: **make the decomposition semiring-valued rather than boolean**,
> so that USDT and USD1 differ in the weights, not the element set.

### 7b. c-semirings and soft/valued constraint satisfaction

Bistarelli, Montanari & Rossi, *Semiring-Based Constraint Satisfaction and Optimization*,
**JACM 44(2):201–236, March 1997**, DOI `10.1145/256303.256306`. Confirmed venue and claim:
the framework associates each tuple in a soft constraint with an element of an algebraic
structure, and "is able to express fuzzy, classical, weighted, valued and over-constrained
constraint problems".

**I could not extract the numbered axiom list from a primary source in this session** — three
PDF fetches (the JACM version, Bistarelli's survey PDF, and a Simons Institute slide deck)
all returned unparseable binary. The standard statement of a **c-semiring** is
`<A, +, ×, 0, 1>` with `+` commutative, associative, **idempotent**, `0` its unit and `1` its
absorbing element; `×` commutative, associative, `1` its unit, `0` its annihilator; `×`
distributes over `+`; and `+` defined over arbitrary subsets so the induced order
`a ≤ b ⟺ a + b = b` makes `A` a complete lattice with `+` as lub. **Do not put this in the
brief as a quotation — have someone check it against the JACM paper.** The load-bearing
consequence is well known and safe to state: **idempotence of `+` induces a partial order,
and the whole framework is therefore monotone by construction.**

Tractability: Kolmogorov, Krokhin & Rolinek, *The Complexity of General-Valued CSPs*
([arXiv:1502.07327](https://arxiv.org/abs/1502.07327)) — verified abstract; the result is that
"if a constraint language satisfies this algebraic necessary condition, and the feasibility
CSP corresponding to the VCSP with this language is tractable, then the VCSP is tractable",
reducing general-valued to finite-valued plus feasibility. The algebraic machinery is
weighted/fractional polymorphisms; see also Cohen, Cooper, Creed, Jeavons & Žívný, *An
Algebraic Theory of Complexity for Discrete Optimisation*
([arXiv:1207.6692](https://arxiv.org/abs/1207.6692), *SICOMP* 2013), which introduces weighted
polymorphisms and a Galois connection, with a complete classification in the Boolean case.
**The exact BLP-tightness dichotomy statement could not be extracted from the abstract pages
— verify before quoting.**

**Non-monotonicity: no.** The order is *defined* by `+`; combination `⊗` is monotone in that
order. A soft constraint can assign a *bad* (low) value to a combination — which is how you
would encode a hazard as a cost rather than a prohibition — but the framework has no
mechanism by which adding an element flips a satisfied constraint to unsatisfied. Encoding a
hazard as `0` (the annihilator) works and does propagate, but then it is just a hard
constraint again, and hardness is a property of the *constraint*, not an emergent property
of composition.

**Verdict (7b)**

> **The best available answer to the non-injectivity problem, and nothing else.** c-semirings
> give a principled, well-studied way to make the decomposition *graded* rather than boolean —
> USDT and USD1 get different values over the same element set — with real tractability
> theory attached. They do **not** give you composition, and they are monotone.

### 7c. Quantales, residuated lattices, Kleene algebra

A **quantale** is a complete lattice `Q` with an associative multiplication
`* : Q × Q -> Q` distributing over **arbitrary** joins on both sides (verified). **Unital**
if there is `e` with `x*e = x = e*x`, making `(Q,*,e)` a monoid. **Involutive** if there is
`˚` with `(xy)˚ = y˚x˚` and `(⋁ xᵢ)˚ = ⋁ xᵢ˚`. Examples given: frames with meet (strictly
two-sided commutative quantales), `[0,1]` under multiplication, ideal lattices of rings and
of C*-/von Neumann algebras.

The property that matters here: because `*` preserves arbitrary joins, it has **right
adjoints** — the left and right **residuals** `x \ z` and `z / y`, characterised by
`x * y ≤ z ⟺ y ≤ x \ z ⟺ x ≤ z / y`. **This is exactly the shape of contract quotient**
(see §3): a quotient/residual is the adjoint of composition. **The Wikipedia source did not
state the residuals; the adjunction above is standard but was not verified against a primary
source in this session.** If assume-guarantee contracts do form a residuated structure, the
quantale is the right abstract home for it, and that is a concrete question worth handing to
one of the nine mathematicians: *is the A/G contract algebra a (commutative, unital) quantale
or only a residuated poset?*

Kleene algebra with tests (Kozen) is the standard idempotent-semiring-with-`*` setting for
program equivalence. **The PSPACE-completeness of the KAT equational theory could not be
verified from source in this session** (the Cohen–Kozen–Smith PDF failed to parse); do not
quote a complexity figure without checking.

**Non-monotonicity: no.** Quantales and Kleene algebras are ordered structures in which
multiplication is monotone in both arguments by construction (it preserves joins, hence
order). Non-monotone validity is not expressible without leaving the structure.

**Verdict (7c)**

> **Not a candidate on its own; the right *frame* for candidate 3.** Point the
> mathematicians at quantales only as the abstract setting in which "composition has a
> residual/quotient" is a theorem rather than a definition.

---

## Cross-cutting: the four questions, answered side by side

### Can it express NON-MONOTONE validity?

| Candidate | Non-monotone? | Mechanism |
|---|---|---|
| **4. Feature models** | **Yes, native, both directions** | `excludes` gives `{a}` valid, `{a,b}` invalid; or-groups give `{a}` invalid, `{a,b}` valid. `⟦FM⟧` is an arbitrary subset of `2^F`. |
| **3. A/G contracts** | **Yes, with the right encoding** | `A = ⟦hazard⟧, G = ∅` saturates to `¬hazard`; composing in `C₃` shrinks `G` and can make the composite inconsistent (`G ∪ ¬A = ∅`). |
| **3′. Interface automata** | Yes, but useless here | Optimistic composition + only **sub-associative** (Bujtor & Vogler); *n*-ary composition is not built from binary. Needs ports you lack. |
| **5. FCA** | **Partly** | `X → M` is valid iff `X′ = ∅` — expresses "this combination cannot occur" with no extension. But the closure operator is monotone and Horn; disjunctive heads are structurally impossible. |
| **7b. c-semirings** | **No** | The order is *defined* by `+`; combination is monotone in it. Hazard-as-annihilator degenerates to a hard constraint. |
| **1. Cospans / PROPs** | **No** | Composition is total and functorial. (The fix lives next door, in nested application conditions.) |
| **2. Open games** | **No, not the right kind** | Non-monotone in *equilibria*, never in *well-formedness*. Every type-correct composite is legal. |
| **6. Institutions** | **No, and it is forced** | Satisfaction Condition + `and` = intersection of reduct-preimages. No operator's model class grows on adding a component. |

### Can it carry a DISJUNCTIVE head (`X → t1 ∨ t2`)?

**Yes, natively:** feature models (arbitrary propositional cross-tree constraints — Batory's
explicit design decision), A/G contracts (`G` is an arbitrary assertion).
**No, structurally:** FCA — Horn theories are exactly those whose model sets are
intersection-closed, and intents are intersection-closed by construction; the only fix is the
doubled 116-attribute alphabet.
**Not applicable:** cospans, open games, institutions, semirings — they have no notion of a
guarded clause over a set at all.

### Is validity DECIDABLE, and at what cost, at your scale?

Every candidate that actually fits reduces to propositional logic over 58 atoms:
**SAT / NP-complete for validity, #SAT / #P-complete for counting — both milliseconds here,
with full enumeration of the configuration space plausibly feasible.** The expensive results
in this document (coNP-completeness of pseudo-intent recognition; non-r.e. conservativity in
FOL; 2EXPTIME conservative extensions in ALC; undecidability of open-game equilibrium) all
concern the *general* case and are irrelevant at n=58. **Do not let the complexity theory
scare anyone off — but do not let anyone claim these problems are easy in general either.**

### Does it have working tooling?

**Real and current:** flamapy + UVL + FeatureIDE (§4); Pacti (§3, ACM TCPS 2025); conexp-clj
and LinCbO (§5); Catlab.jl / AlgebraicRewriting.jl (§1).
**Alive but static:** OCRA (last release 2021), FAMILIAR (reference only), open-game-engine
(self-described work in progress).
**Effectively dead:** Hets (barely), SPLOT, Clafer, OBJ3, Specware.

---

## Ranked verdict

Ranked by fit to *this* data — 58 elements, protocol-as-set, 29 guarded CNF laws, 20 hazards,
non-monotone validity, non-injective decomposition.

**1. Feature models / software product lines (§4) — near-exact fit. Adopt.**
Your object *is* a feature model. Families are xor/or-groups; strata are `requires`-chains;
the 29 laws are literally the case Batory introduced arbitrary propositional cross-tree
constraints for; hazards are `excludes`; non-monotone validity is native in *both* directions.
It brings a catalogue of ~30 analyses you have not yet run (dead elements, core elements,
false-optionals, redundant laws, MUS explanations per hazard, edit classification), live
tooling (flamapy, UVL, FeatureIDE), and a genuine composition algebra (FAMILIAR `∩`/`∪`/`∖`/
`×`/`slice`, associative and commutative up to semantic equivalence). Its honest content is
"compile to propositional logic and call SAT", which at n=58 is the right engineering answer.

**2. Assume-guarantee contract algebra (§3) — the best *algebra*, but only its lattice
fragment. Adopt selectively.**
The richest law-set in the survey and the sources are precise: `∧`, `∨`, `⊗`, `•` are all
**idempotent commutative monoids with identity** (Incer Prop. 6.10.1); the poset is a
**bounded distributive lattice**; there are **exactly four semirings**; quotient is a **true
residual** via a Galois adjunction. Three things transfer directly: the **assumption/guarantee
split with saturation**, which reproduces "law relieved when no subject is present" for free
and carries disjunctive heads natively; the **refinement preorder** `C₂ ≼ C₁ iff A₂ ⊇ A₁ and
G₂ ⊆ G₁` as a rigorous test for redundant and subsumed laws; and the **`A = hazard, G = ∅`
encoding** — the highest-value single result in this document, because the naive
`(⊤, ¬hazard)` encoding provably destroys the conditional structure of every law under
conjunction. But `⊗` presupposes interacting components with ports, which you do not have, and
killing `⊗` kills quotient, merging and separation — **you lose six of eight operations.**
Also brief the nine explicitly on two traps: **⊗-over-∧ distributes with equality in the
concrete Boolean AG algebra but only sub-distributes (a four-contract interchange law) in the
abstract meta-theory**; and **refinement-monotone ≠ extension-monotone** (independent
implementability is about refining a *fixed* component set).

**3. Formal Concept Analysis (§5) — the right *audit* tool, not the algebra. Adopt for the
law set only.**
Objects = protocols, attributes = elements is a textbook formal context, and the DG base is
the correct notion of "the smallest complete set of laws" (minimum in *number* of
implications, canonical, though **not** minimum in total size). Hazards are already
expressible with no extension as `X → M`. Subposition gives the one clean composition law,
`Th(K₁/K₂) = Th(K₁) ∩ Th(K₂)`. Two hard limits, both verified: **disjunctive conclusions are
structurally outside Horn**, so the 29 laws cannot all be fed to a DG-base computation without
either dropping them or paying the 116-attribute doubled alphabet; and **stratum is not
recoverable as lattice level** — concept lattices are not graded (every complete lattice is a
concept lattice), so encode strata by ordinal scaling. Expect **|DG base| ≤ |split set|**, a
guaranteed non-increase but not a guaranteed decrease.

— **Line of real candidacy. Everything below is either wrong for this data or too heavy.** —

**4. Semiring / c-semiring grading (§7) — not a candidate, but the only principled answer to
your non-injectivity problem.**
Every framework above is denotational and will faithfully report USDT ≡ USD1. c-semirings
(Bistarelli, Montanari & Rossi, JACM 1997) give a well-studied way to make the decomposition
**graded rather than Boolean**, with real tractability theory (Kolmogorov–Krokhin–Rolinek).
"Rigged Contracts" (Vandenbroucke & Schrijvers, FLOPS 2024) is the template for the move: make
the evaluator a **semiring homomorphism** and instantiate at different rigs. Worth one
mathematician, not nine. It gives you no composition and it is monotone.

**5. Institution theory / CASL (§6) — too heavy, and monotone in exactly the wrong way. Reject,
steal one idea.**
Bringing category theory to a SAT fight, and you would inherit a framework whose central
theorem (**amalgamation**) *fails in its own flagship language* because of subsorts. Steal only
the **three-way model-theoretic / consequence-theoretic / proof-theoretic split of
conservativity** and the Hets `Cons/Mono/Def` grading, as design vocabulary for "does adding
this generator change what was derivable". The literature's own answer is discouraging:
conservativity is **not r.e. in first-order logic**, and model-theoretically **undecidable
already in ALC**.

**6. Open games / categorical cybernetics (§2) — fashionable and genuinely deployed, and wrong
for you. Reject.**
Real work exists (Lido Dual Governance via the Open Games Engine × HEVM), so this is not
vapourware — but open games compose by **wiring typed boundaries** with strategy sets combined
by **cartesian product**, and a component never reacts to the *ambient presence* of another.
Your 29 laws are ambient-presence triggers over an unstructured set. The framework has no slot
for hazards at all (the `B = ∅` trick is a global poison that cannot localise the fault). And
the non-injectivity observation says precisely that **the wiring is the information your data
is missing** — so this framework demands as input the thing you do not have. It answers "is
this mechanism incentive-compatible", not "is this set of mechanisms legal".

**7. Symmetric monoidal categories / structured & decorated cospans (§1) — the most fashionable
and the worst fit. Reject the PROP; take one thing from next door.**
Cospan composition is **total, gluing-only, monotone by functoriality, and associative only up
to iso**; the monoidal product is coproduct, which is **not idempotent**, while your set union
is. There is essentially **no finance or smart-contract application** in this literature. The
one genuinely valuable pointer is adjacent, not in the cospan papers: **nested graph conditions
/ negative application conditions** (Habel–Pennemann; Ehrig et al.), which are
**expressively equivalent to first-order graph formulas**, inherently non-monotone, come with
theorems translating global constraints into local application conditions and weakest
preconditions, and are **implemented in AlgebraicRewriting.jl**. If anyone on the team wants to
do category theory, point them there.

### What to actually tell the nine

The blunt synthesis: **you have a propositional theory — 29 guarded CNF implications and 20
negative clauses over 58 atoms — and three independent literatures (§3, §4, §5) converge on
that same diagnosis from different directions.** That is decidable, cheap, and has mature
tooling. The genuinely open and mathematically interesting questions are the two that *no*
framework in this survey answers:

1. **What is the right notion of composition when protocols are sets with no ports?** Every
   candidate either assumes interfaces (§1, §2, §3's `⊗`) or offers only lattice operations on
   configuration sets (§4's merge, §5's subposition). Nobody has an algebra of
   *set-of-mechanisms* composition with a validity predicate. **This is the actual research
   question and it should be stated as such in the brief.**
2. **How do you defeat the non-injectivity?** `α(USDT) = α(USD1)` means the element set is not
   a complete invariant, and every denotational framework will faithfully report them as equal.
   No algebra recovers information the abstraction discarded. Either add discriminating
   elements, or go graded (§7b). **Frame this as a modelling defect to be fixed before the
   algebra is designed, not a problem the algebra will solve** — otherwise nine mathematicians
   will spend a month building machinery on top of a lossy abstraction.

One process note: on current evidence the three fashionable categorical framings (§1, §2, and
§6) will each independently look attractive to at least one mathematician, and each will burn a
month before hitting the same wall — *no ports in the data*. Say so explicitly in the brief.

---

## What I could not verify

**Method note.** This survey was assembled from primary papers via seven parallel research
lanes. The session's web-search budget (200 calls) was exhausted partway through, so later
lanes worked from direct fetches and, where noted, recall. Several PDFs (JACM, Springer,
Simons slide decks, Cohen–Kozen–Smith) returned unparseable binary. Nothing below was made up;
it is listed so nobody quotes it as established.

**Laws I could not confirm from a source:**
- Whether the A/G contract lattice is **complete** (as opposed to bounded) — arXiv:2402.12514
  states bounded distributive; completeness would inherit from completeness of `B`.
- Whether "**residuated lattice**" or "**quantale**" is applied to A/G contracts verbatim
  anywhere. The inference is well supported (commutative idempotent monoid + bounded
  distributive lattice + Property 7 residual), and the closest quoted claim is "bounded
  three-valued Sugihara monoid". **This is a good problem to hand to one of the nine.**
- The residuation adjunction for quantales (`x*y ≤ z ⟺ y ≤ x\z ⟺ x ≤ z/y`) — standard, but
  the Wikipedia source did not state it.
- Idempotence and unit claims for the cospan monoidal product — **derived** from "monoidal
  product = coproduct", not quoted.
- Whether Rigged Contracts' `Or` is claimed idempotent. The code states **no laws in
  comments**, and the paper text was unreachable (Springer paywall, no README, search budget
  gone). The reading of the pearl's thesis — that `worth` is a semiring homomorphism and the
  **max-plus tropical rig** recovers Peyton Jones & Eber's intended semantics — is **my
  inference from `Contract.hs`**, not a quotation.
- The **c-semiring axiom list**, in full. Three separate PDF fetches failed. The standard
  statement is given in §7b explicitly marked "do not quote". **Have someone check it against
  JACM 44(2):201–236.**
- The **Höfner/Khedri/Möller product-family-algebra axioms as printed** (hoefner-online.de
  unreachable, Springer gated). The commutative-idempotent-semiring reading is from a secondary
  summary. *(By contrast, the Apel et al. AMAST 2008 axioms in §4 were read in full and are
  quoted verbatim.)*
- Explicit associativity/commutativity **law-list theorems** for CASL union — derived from the
  Fig. 4 rule, not quoted.

**Complexity figures I could not verify — do not put numbers in the brief without checking:**
- **Any** complexity figure for interface-automaton compatibility. The monograph defers to a
  citation and gives no numbers. The folklore (safety games polynomial in the product, product
  exponential in component count, alternating simulation in PTIME) is **not** re-verified.
- Any complexity figure for LTL/temporal contracts. The commonly cited 2EXPTIME is the LTL
  *realizability* bound and is not obviously the right number for contract refinement.
- Pacti provides **no explicit complexity bounds** (confirmed absent, not merely unfound).
- **PSPACE-completeness of the KAT equational theory** — the Cohen–Kozen–Smith PDF failed to
  parse. Widely believed; not confirmed here.
- The exact **BLP-tightness / fractional-polymorphism dichotomy statement** for VCSP — only the
  abstract-level claim was retrieved.
- **NP-hardness of minimum covers** in the functional-dependency setting (Ausiello/D'Atri/Saccà)
  — recall.

**Claims I expected to find and did not:**
- A **verbatim theorem** stating "adding a third interface can break a compatible pair". It
  follows from the existential-over-environments definition and from the associativity
  counterexamples, but it is an **inference**, not a quotation. Given that this is the exact
  property you care about, it is worth someone finding the citation.
- Any **extension of FCA implications carrying disjunctive conclusions**. Searches returned
  nothing standard. **This is a negative search result, not a proof of nonexistence** — though
  the intersection-closure argument makes it a theorem for FCA *implications* proper.
- Any **decorated/structured-cospan application to finance or smart contracts**. None found.
- A published artifact for the **PBS/MEV compositional-game-theory work** — EthCC talk only.
- Any **AMM security result** from the open-games line; `amm.act` is an example file.
- A paper by "Cadiou", or "Master, open systems with conditions" — **could not confirm this
  reference exists.**
- **"Higher Categorical Cryptoeconomics"** appears only on ResearchGate — treat as
  non-credible.

**Sources unreachable or unread:**
- Hedges' 2016 QMUL thesis (full text); Czarnecki & Wąsowski SPLC'07; Schobbens/Heymans/Trigaux
  FFD; Thüm et al. ICSE'09 edit-classification details; Benavides et al. IS 2010 full
  30-operation table verbatim (obtained secondhand plus the live flamapy operation list); FODA
  (1990) — reachable at the SEI URL but not read.
- Exact numbered definitions and the associativity clause in Baez–Courser 1911.04630 — PDF text
  extraction failed; abstracts plus nLab were used.
- Ganter & Wille's book statements on apposition/subposition — the extent/intent
  characterisations in §5 were **derived from the derivation operators**, not quoted. Wille's
  subdirect (1983) and tensorial (1985) decomposition citations are recall.
- Bertet & Monjardet's exact list of coinciding bases; Selman & Kautz Horn approximation.
- **Tool status for Ticc, MICA, MIO Workbench, Chase, AGREE** (§3) and Maude (§6) — nothing was
  verified; assert nothing about them.

**Open in the literature (not a gap in this survey):**
- Whether the **Duquenne–Guigues base can be computed in output-polynomial time** is **open**.
  Distel, ICFCA 2011, verbatim: *"no output-polynomial algorithm has been found, and it is also
  not known whether such an algorithm exists."* Still described as unsettled in 2022. Related:
  whether pseudo-intents can be generated with polynomial delay in *arbitrary* order is
  explicitly flagged by Babin & Kuznetsov as "an important open problem". Irrelevant at n=58,
  but do not let anyone state it as easy.
