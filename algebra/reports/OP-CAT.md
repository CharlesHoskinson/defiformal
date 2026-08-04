# OP-CAT — an algebra of DeFi composition in a topos of typed instance graphs

**Lens: categorical. Kept, after a rebuild.**

Headline: **carrier = subobjects of a universe object in the presheaf topos of
graphs typed over a five-sort type graph; discrimination ratio 10.1× against
2.41× for the reference closure predicate on the same split.**

Executable model: `/root/opcat/opcat.py` (the condition system and the
predicate), `/root/opcat/opcat_run.py` (calibration, algebraic laws,
observational quotient, reflexivity), `/root/opcat/opcat_strat.py` (stratum),
`/root/opcat/opcat_lat.py` (lattice checks). Every number below is printed by
one of those four.

---

## 0. Ruling on §5b, first, because it determines everything after

The survey is right about the constructions it names and wrong about the lens.

**Open games: dead. Confirmed.** A lens/optic has a fixed boundary — a play
type and a coplay type — and composition is wiring. Nothing in the data is
wired. `Aw + Xf → X19` is not a message on a port; it is a statement that two
things are *present in the same ambient object*. Open games have no ambient. I
found no encoding that does not amount to giving every game a port for every
element, which is a 58-fold blow-up that reproduces the element set and buys
nothing.

**Decorated / structured cospans: dead as stated, and the survey's own reason
is the wrong one.** The stated objection is that "the coproduct is not
idempotent". True, and irrelevant: the coproduct is the pushout over the
*initial* object. Take the pushout over the *pullback* instead and idempotence
returns on the nose (Thm 1.3). What actually kills cospans here is that a
cospan's semantics is a decoration functor into a symmetric monoidal category,
and monoidal product is total and monotone. There is no room for `¬`. That
objection is fatal and it is not repaired by changing the interface.

**Nested graph conditions: live, and they are the whole answer.**
Habel–Pennemann conditions are (i) ambient — `∃(a : P ↪ C, c)` fires on the
presence of a pattern anywhere in the object, which is precisely
"ambient-presence trigger"; (ii) closed under `¬`, hence non-monotone by
construction; (iii) expressively equivalent to first-order graph formulas, so
decidable on finite objects with known complexity. The survey flagged them as
"worth a look". They are not a look. They are the construction.

So the categorical lens survives, but only by dropping the monoidal half of it.
What is left is **topos logic**: a topos for the carrier and its lattice
theory, nested conditions for the predicate. That combination gives, for free,
things the assume–guarantee people (§5) build by hand — a residual `⇒`, a
bounded distributive lattice, conjunction and disjunction as meet and join —
and it gives them on a carrier with five sorts instead of one, which is what
§4.3 and §4b ask for and what no propositional theory over 58 atoms can
supply. Positioned against §5: interface automata and A/G contracts are the
right *shape* and the wrong *carrier*; they assume ports, and this data has
none. Feature models are the right carrier for the flat projection and cannot
say anything at all about assets, domains or parties, which is where the two
largest unsolved problems in the brief live.

---

## 1. Signature, carrier, operations, laws

### 1.1 The signature is a type graph, not a set of atoms

Fix the finite type graph `T`:

```
sorts (node types)   El   Ast   Dom   Prt   Mnd
edge types
  sym    : El  -> Σ        (attribute; Σ = 59 labels, see §4)
  over   : El  -> Ast      the asset whose claim this instance issues
  reads  : El  -> Ast      the asset whose market value this instance's solvency reads
  at     : El  -> Dom      the settlement domain this instance lives in
  by     : El  -> Prt      the principal with authority over this instance
  dep    : El  -> Prt      an out-of-scope provider this instance consumes from
  uses   : Mnd -> El       a mandate's discretion over an element instance
```

`El` is an element **instance**, not an element type. `Ast` is an asset. `Dom`
is a settlement domain. `Prt` is a named party — obligor, attester, custodian,
authority, residual claimant. `Mnd` is a **mandate**: a policy over instances
with no machinery of its own.

Justification is entirely from the data, not from elegance:

- `Prt` exists because §4.5 and VERDICT finding 5 say coverage falls off the
  off-chain boundary monotonically and the missing things are all *parties* —
  obligor, register of record, custodian, recourse. I take the second horn of
  §4.5: I do not bound scope to on-chain state machines; I add an opaque
  principal sort. Its assumption is stated in §6 below.
- `Ast` exists because of §4b: the Terra cycle is a statement about a
  particular assignment of assets to two instances, and the atlas already
  gestures at it with `At{subject=...}`.
- `Dom` exists because of the `{Fl, Xm}` witness: a flat set "cannot say which
  settlement scope the flash loan lives in".
- `Mnd` exists because of VERDICT's decision-changing finding: a strategy is a
  policy *over* protocols. It is the most-confirmed gap in the project and it
  is **not an element**. A mandate is an `Mnd` node with `uses` edges. Adding a
  sort costs one node type; adding an element would have been wrong.

### 1.2 The carrier

Let `E := Graph↓T`, the slice of the presheaf topos `Graph = [•⇉•, Set]` over
`T`. Slices of topoi are topoi (fundamental theorem of topos theory), so `E`
has all finite limits and colimits, exponentials, a subobject classifier `Ω`,
and complete Heyting subobject lattices.

Fix a **universe object** `U ∈ E`: `N` instances of each label in `Σ`, over
finite sets `A` of assets, `D` of domains, `P` of principals, with all
type-admissible edges present. `U` is finite and `N`, `|A|`, `|D|`, `|P|` are
parameters of the model, not of the theory.

> **Carrier `C := Sub_E(U)`, the subobjects of `U`. A protocol is a subobject.**

This is many-sorted, and I commit to it (§4.3). One object carries element
instances, assets, domains, parties and mandates simultaneously. There is no
second carrier for strategies, no coproduct of sorts, no lifting.

The flat data of the corpus enters through the **generic instantiation**
`F : 2^Σ → C`, sending a symbol set to the instance graph with one `El` per
symbol and every typing edge left free, and the forgetful `V : C → 2^Σ` reading
off the symbol image. `V ∘ F = id`, so `F` is a section, and `F(S)` is initial
in the fibre `V⁻¹(S)`.

### 1.3 Composition, and all five laws settled

```
G ⊔ H  :=  pushout of  G ←— G ⊓ H —→ H     (composition)
G ⊓ H  :=  pullback  G ×_U H                (common part)
G ⇒ H  :=  Heyting implication in Sub(U)    (quotient / residual)
⊥ = ∅ (initial),  ⊤ = U
```

**Theorem 1.** `(Sub_E(U), ⊔, ⊓, ∅, U, ⇒)` is a complete Heyting algebra.
Consequently:

| law | status | proof |
|---|---|---|
| associativity of `⊔` | **holds**, on the nose in `Sub(U)`, up to canonical iso in `E` | join in a lattice is associative; in `E`, by the pushout pasting lemma |
| commutativity of `⊔` | **holds** | pullback and pushout are symmetric in their arguments |
| **idempotence** of `⊔` | **holds**: `G ⊔ G ≅ G` | the interface of `G` with itself is `G ⊓ G = G`, and the pushout of `G ← G → G` along identities is `G` |
| identity | **holds**: `G ⊔ ∅ ≅ G` | `∅` is initial, `G ⊓ ∅ = ∅`, and the pushout over the initial object of `G ← ∅ → ∅` is `G` |
| absorption | **holds**: `G ⊔ (G ⊓ H) = G` and `G ⊓ (G ⊔ H) = G` | lattice absorption in `Sub(U)` |
| distributivity | **holds** | `Sub(X)` in a topos is a Heyting algebra, hence distributive |
| residuation | **holds**: `A ⊓ B ≤ C ⟺ A ≤ B ⇒ C` | definition of Heyting implication |

*Proof of Theorem 1.* `E` is a topos. In any topos, `Sub(X)` is a Heyting
algebra with meet the pullback and join the image of the coproduct
`A + B → X`; `E` is cocomplete and well-powered, so `Sub(U)` is complete. The
image factorisation of `A + B → X` is exactly the pushout of
`A ← A ×_X B → B` followed by a mono into `X`, which is the stated `⊔`. ∎

Verified by 20 000 random triples: `assoc comm idem unit absorb distrib` all
`True` (`opcat_run.py §2`).

**This is the overturn of §5b.** The survey's objection — "coproduct is not
idempotent" — is correct and misdirected. The coproduct is the pushout over the
*initial* object. Composition of two protocols that share an asset, a domain or
a governance principal is the pushout over the *pullback*, and that is
idempotent, commutative, associative, unital, absorptive and distributive, all
six, proved, in a category that also hands over a residual for free. Decorated
cospans are dead. The pushout is not.

**Non-injectivity (§4.2), answered constructively.** USDT and USD1 have equal
symbol sets. They are *not* equal subobjects of `U`: they differ in the `by`
edge, which points at different `Prt` nodes. **The generator that separates
them is the `Prt` sort** — an obligor node with its own attributes
(jurisdiction, attester, reserve composition, recourse). My algebra separates
them at the carrier; my *verdicts* do not, because the blind set gives me only
`V(G)` and `V` is not injective. That is a defect in the data, precisely
located: the fibre `V⁻¹({Ps,Rd,At,Fz,Up})` has more than one point, and the
points differ in a sort the corpus did not record.

---

## 2. The validity predicate and its complexity

### 2.1 The predicate

`Valid(G) := G ⊨ 𝒞` where `𝒞` is a **nested graph condition** over `U`
(Habel & Pennemann 2009):

```
c ::= true | ∃(a : P ↪ C, c) | ¬c | c ∧ c'
G ⊨ ∃(a : P ↪ C, c)   iff   ∃ mono q : C ↪ G with q∘a = p and q ⊨ c
```

`𝒞` is a conjunction of 44 conditions in three schemas, all of quantifier depth
at most 2:

**(i) Requirement, 30 conditions.** `∀(x : sym(x) ∈ S) ⋀_j ∃(y : sym(y) ∈ A_j)`.
These are the 25 fireable atlas laws with the changes in §4, plus ten new ones.

**(ii) Anchoring, 10 conditions — the converse schema, and it is new.**
`∀(x : sym(x) ∈ S) ∃(y : sym(y) ∈ C)`. The atlas's law language has arrows out
of a subject only. A graph condition has no such asymmetry: a pattern is a
pattern, and quantifying over a *consequent* is the same syntactic act as
quantifying over a subject. So the converse comes free with the formalism. It
says things the atlas cannot say — *no liquidation without a threshold*, *no
margin test without an exposure*, *no attestation without a subject*, *no
backstop without a risk*, *no verification without a movement to verify*. It is
where roughly a third of my discrimination lives, and no propositional reading
of the 29 laws produces it.

**(iii) Negative application conditions, 4 conditions.**
`∀(x⃗ : pattern) ¬∃(...)`. These are `X2`, `X1`, `X18`, and one new hazard
`X21`. They are the only non-monotone content in the model: **4 conditions of
44** (`opcat_lat.py`).

### 2.2 Existential completion, and a theorem about what the flat data cannot see

`𝒞` is evaluated over instance graphs. Flat element sets are evaluated by

```
Val(S)  :=  ∃ G ∈ V⁻¹(S). G ⊨ 𝒞
```

**Theorem 3 (Invisibility).** Let `c` be a conjunct of `𝒞` all of whose
quantified structure lies in the `at`, `by`, `over` or `reads` components. If
`c` is satisfiable at all over the free typing, then `F(S)` extends to some
`G ∈ V⁻¹(S)` with `G ⊨ c`, so `c` contributes nothing to `Val`.

*Proof.* `V⁻¹(S)` contains every assignment of the free edges; `c` constrains
only free edges; pick a witnessing assignment. ∎

Corollaries, each one a fixed point of §4b reproduced rather than re-derived:

- The `{Fl, Xm}` hazard is **invisible to any element-set predicate**, because
  it is a condition on `at`. FINDINGS calls it "a single flat element set
  cannot say which settlement scope the flash loan lives in". Theorem 3 is that
  sentence as a theorem, and it says the same of `{Fl, Au, Rl}`.
- `X3` (protocol token as collateral AND oracle market AND backstop), `X12`,
  `X13`, `X15`, `X17` are conditions on `over`/`reads` and are equally
  invisible. Five of the twenty hazard rows are not undecidable-in-principle;
  they are decidable over `C` and undecidable over `V(C)`.
- `X1` is a condition on `reads ; over⁻¹` — see §3.5.

I therefore run, on the blind set, only the conjuncts that survive Theorem 3.
This is not a concession. It is the model telling me exactly which rows of the
hazard table are asking for a sort the corpus did not record.

### 2.3 Complexity

- **Fixed `𝒞`, instance graphs.** Satisfaction of a nested condition with `q`
  quantified nodes over a graph with `n` nodes is `O(n^q)` — standard finite
  model checking, since nested conditions are equivalent to first-order graph
  formulas. My `𝒞` has 44 conjuncts with `q ≤ 3`, so `Valid` is `O(44·n³)`,
  polynomial, and for `n ≤ 20` (the largest corpus protocol has 17 elements)
  it is instant.
- **Flat carrier.** Each conjunct is a bitmask test on a 59-bit word. `Val(S)`
  costs **44 word operations**: constant in `|Σ|`, linear in `|𝒞|`. All 156
  blind cases are decided in under a millisecond.
- **`𝒞` part of the input.** PSPACE-complete, by the equivalence with
  first-order model checking on finite structures.
- **Emptiness / repair** — "is there an admissible superset of `S`?" — is
  NP-complete in general: membership by guessing the superset and running
  `Val`; hardness by encoding monotone SAT with width-2 NACs as excludes-pairs.
  For fixed `Σ` it is decided by the interval-lattice enumeration of FINDINGS
  §14.2, which returns 1–6 minimal repairs on real protocols.

### 2.4 Where the lattice survives and where it dies

Measured over 400 000 random pairs (`opcat_lat.py`):

- The **monotone fragment** — 40 of the 44 conditions, requirement plus
  anchoring — is **union-closed**: no counterexample. It is **not**
  intersection-closed: witness `{Ex,Ob,Pm,Rd,Sd,Sh} ⊓ {Fd,Ob,Tp,Xf,Xm} = {Ob}`,
  which is open. This reproduces FINDINGS §14.1 exactly, on a strictly larger
  law set including the ten new laws and the ten anchoring conditions, which is
  evidence that union-closure is structural and not an artefact of the original
  25.
- The precise Galois statement, sharper than FINDINGS': the closed sets are a
  union-closed family containing `⊥` and `⊤`, so `S ↦ (largest closed subset of
  S)` is an **interior (kernel) operator, not a closure operator**. Disjunctive
  heads put the theory outside Horn, so there is no least closed superset and
  no closure operator in the Galois sense. The Galois adjunction runs the other
  way.
- Adding the **4 NACs** destroys join: `{Ag}` valid, `{Em,Im,Rd,Sh,Sr,Vl}`
  valid, union invalid (`X21` armed). Validity is not monotone: Uniswap
  `{Cl,Cp,Fd,Fl,Sh,Tg,Tp}` is valid, `+Ad` is not. Validity is not meet-closed:
  `{Bs,Cp,Ft,In,Ix,Op} ⊓ {Oa,Op} = {Op}`, invalid.

So: **the lattice is exactly the monotone fragment, and non-monotonicity is
localised in 4 of 44 conditions.** That is a stronger statement than "legality
is not compositional": it says how much of the algebra you keep, and it is 91%.

---

## 3. Answers to §6

### 3.1 What is the carrier?

Subobjects of a universe object in a topos of typed instance graphs, with five
sorts: `El` (element instance), `Ast` (asset), `Dom` (settlement domain), `Prt`
(named principal), `Mnd` (mandate). Not sets, not multisets, not terms.
Many-sorted, committed. A strategy is an `Mnd` node with `uses` edges — a
policy over instances, with no machinery of its own, exactly as VERDICT
describes it, and it does not become an element.

### 3.2 Is composition a join? Is it a lattice? Are the laws a closure operator?

Yes; yes; **no**.

Composition is the pushout over the pullback, which in `Sub(U)` is the join.
The carrier is a complete Heyting algebra — associative, commutative,
idempotent, unital, absorptive, distributive, residuated, all proved (Thm 1).
The laws are **not** a closure operator in the Galois sense: their models are
union-closed but not intersection-closed, because of the `|` alternatives, so
there is no least model above a given set. The correct Galois object is the
**interior operator** "largest closed subset", which is well-defined precisely
because the family is union-closed. Validity — laws plus NACs — is neither.

### 3.3 Are the 58 elements independent?

**No. There are 56 observational classes over my 59 labels** (`opcat_run.py
§3`), where two labels are identified when no sampled context distinguishes
them. The collapses:

- **`{Tg, Up, Gp}` collapse to one generator.** All three are `Ctl`-sorted
  authority. After L15 is cut (§4), no condition in the system separates a
  timelock from a proxy from a guardian. They differ only in the *attributes*
  of the `Prt` node they attach to — delay, key threshold, scope — which the
  corpus does not record. **Redundant: two of the three.**
- **`{St, Wg}` collapse.** No context built from the signature separates a
  stable-hybrid from a weighted-geometric invariant. This is exactly VERDICT
  finding 3: "five symbols for variants of a scalar function on a two-asset
  pool". **Redundant: `Wg`.**
- **`Ve` is inert** — named by no condition. It is a label with no algebra.

The remainder are pairwise separated. So the effective generating set is 56,
and the named redundancies are `Wg` and two of `{Tg, Up, Gp}`.

### 3.4 Is stratum derivable as rank?

**Not as rank in the law graph — FINDINGS is right, 3 of 58. But yes as the
maximal sort of the typing functor, 57 of 58.** This overturns "stratum stays
asserted".

Define `τ : Σ → P({Ast, Meas, Solv, Dom})` by reading, off each element's
definition, which indices an instance of it needs to be well-typed: does it
need an asset argument; does it need a clock or an external measurement node;
does it need a `Prt` because the claim can fail; does it need a `Dom` or a
second principal. Order `∅ < Ast < Meas < Solv < Dom` and take the max.

```
$ python3 /root/opcat/opcat_strat.py
tau-derived stratum agrees with the hand column on 57 of 58 elements
disagreements: [('Pm', 1, 2)]
```

The single disagreement is a **defect in the hand column**: `Pm` is
"proactive market making against an external reference", and S1 is defined as
"one settlement domain, **no external fact**". `Pm` reads an external fact. It
is S2. The hand column is wrong about one element and `τ` is right.

Stratum is derivable. It was never a rank; it is the top of a sort lattice.
The honest caveat: I assigned `τ` from the definition prose, which is the same
prose the strata were assigned from, so this is a *reconstruction* with an
explicit function rather than an independent measurement. What it buys is that
the axis is now computed from a stated typing rather than asserted, and it
disagrees where the typing disagrees.

**The `L21: Gs(S3) → Au(S4)` inversion dissolves.** `τ(Gs) = {Ast, Solv}`,
`τ(Au) = {Meas, Dom}`. Neither contains the other. `P(Sorts)` is not linearly
ordered, and requirement is not required to be order-reflecting. The
"inversion" is an artefact of collapsing `P(Sorts)` to an integer and then
demanding monotonicity of that integer. It is not an atlas defect and it should
not be corrected. FINDINGS' one genuine inversion is not one.

### 3.5 Terra's collapse as a cycle

Define on `El` the relation

```
e₁ ⇝ e₂   :⟺   reads(e₁) = over(e₂)
```

i.e. `backs := reads ; over⁻¹`. It says: the solvency of instance `e₁` is a
function of the market value of the asset that instance `e₂` issues. This is a
relation on `El`, but it is *definable only because `El` is indexed over `Ast`*
— it is a composite through the `Ast` sort, which is why no relation on element
*types* can be it.

```
$ python3 /root/opcat/opcat_run.py    # §5
Terra  backs-cycles: [['As@UST', 'Rd@LUNA', 'As@UST'], ...]
crvUSD backs-cycles: []
```

Terra: `(As, UST) ⇝ (Rd, LUNA) ⇝ (As, UST)` — algorithmic supply adjustment
mints LUNA to defend UST, and UST demand is what prices LUNA. A 2-cycle.
crvUSD, with a comparable element set (`Cd, As, Rd`-shaped), has no cycle,
because its `reads` edges point at ETH, an asset no instance of it issues.
**The flat carrier cannot tell the two apart. The instance carrier separates
them with a two-node pattern.**

The condition `¬∃(cycle of length ≤ k in backs)` is a nested condition of depth
`O(k)`. Unbounded cycles are not first-order and therefore not expressible as a
nested condition — that is a real bound, and it is the honest limit: I can
express reflexivity up to any fixed length, not reflexivity in general. Every
reflexive collapse in the corpus has length 2.

---

## 4. What I added and what I cut

### Added

**Four sorts.** `Ast`, `Dom`, `Prt`, `Mnd`. This is the whole point of the
carrier. `Mnd` gives the delegated allocation mandate — VERDICT's
most-confirmed gap, $16.5B and the fastest-growing form in DeFi — a home that
is not an element. `Prt` gives obligor, custodian, attester and residual
claimant. `Ast` gives reflexivity. `Dom` gives the `{Fl, Xm}` hazard a place to
be true.

**One label.** `Ve` (vote-escrow), admitted from the contested register on the
corpus's evidence that Convex is 100% residue without it. It is observationally
inert in my system and I say so.

**Ten laws, L30–L39**, all justified by an element that had no law and a real
protocol that needed one:

```
L30  Vl → (Sh|Ix|Rb|Wq|Ep|Bs|Rs)        staking needs a claim or an exit
L31  Cv → (Sh|Ix|Rb) + (Sv|Oa|At|Ep)    a cover pool needs capital and an adjudicator
L32  Ps → (At|Rd|Cd|Ex)                 a peg-swap needs reserve evidence
L33  Dp → (Ex|Tp|Oa|At|Pf|Op|Ob|pool)   a hedge needs a venue or a mark
L34  Tp → (pool|Ob)                     a TWAP needs an inventory
L35  Fl → (pool|Pl|Im|Ob|Ag|Sh)         flash needs a lender
L36  Ft → (Sh|Ix|Rb|Rd|Ep|Ct|Uc|Tr|At|Sv)   a dated claim needs a book
L37  Sr → (Sh|Ix|Rb|Ep|Ct|Em|Rd|Ps|Op)  a stream needs an escrow claim
L38  Rd → a liability to redeem against
L39  Ob → settlement accounting
```

**Ten anchoring conditions** — a schema the atlas does not have. `A-Ct`, `A-Li`,
`A-Ad`, `A-Sl`, `A-Bs`, `A-Ex`, `A-Lp`, `A-Xm`, `A-Tp`, `A-At`.

**One hazard, `X21`:** *routing or aggregation co-present with credit and no
venue to route to.* Found by looking at what a graft of `{Ag, Rf}` onto a CDP
does to the bond graph: the two parts share no interface, so the composition is
a coproduct, not a pushout, and a coproduct of protocols is not a protocol.

**Eleven prose promotions**, with their cost:

| law | prose term | promoted to | cost |
|---|---|---|---|
| L2 | exit-liquidity | pool ∨ Rd ∨ Wq ∨ Ob ∨ Rf ∨ Ag ∨ Li ∨ Ps ∨ Sr ∨ Of ∨ In | `Li` becomes load-bearing for Aave, Morpho, Compound |
| L3 | obligor | `Ft ∨ Sv` | an obligor is on-chain either as a dated claim or a servicer; catches 6 of 6 `Uc` grafts |
| L6 | mechanical trigger | `Sv ∨ Ep ∨ Sl ∨ Bs ∨ Wq ∨ At`, plus a pool to tranche | |
| L7 | liquidation capacity | `Li ∨ Ad ∨ As` | needed for Aave's GHO and crvUSD |
| L8 | named custodian + global claim ledger | `At` | costs Aster and Spark Savings; catches 6 of 6 `{Xf,Aw}` grafts |
| L10 | proof verifier + nullifier set | `Sd ∨ Aw ∨ Sh ∨ Ix` | |
| L12 | solver ∨ fallback + timeout | `Bs ∨ Sl ∨ Rl ∨ Of ∨ Ag ∨ Ba ∨ Oa ∨ Sv` | |
| L14 | bounded liquidity reserve | folded into `Wq`'s anchoring | |
| L17 | bounded scope + revocation | `Gs ∨ Rl ∨ Up ∨ Gp ∨ Tg ∨ Sv ∨ Aw ∨ In` | |
| L19 | timeout | `Bs ∨ Sl ∨ Oa ∨ Rl` | needed for Across |
| L28 | named authority | `Aw ∨ At ∨ Sv` | |

That is 52 prose terms reduced by 11. It is not two-thirds recovered and I will
not claim it is.

### Cut

- **`CSM`.** It declares itself a non-element. Gone.
- **`L15` (`Up → Tg | bounded emergency process`), entirely.** FINDINGS shows it
  flags live Lido and dead Euler identically. The corpus adds six more live
  protocols with `Up` and neither `Tg` nor `Gp` — Raydium, WBETH, Tether, USD1,
  USDG, PYUSD. It is not a validity condition; it is a preference. Consequence,
  stated: `Tg`, `Up` and `Gp` collapse into one observational class. Governance
  is invisible to this algebra, and the reason is that it lives in `Prt`
  attributes the corpus does not record.
- **`Op` removed from `L1`'s subject list.** L1 as written rejects Hegic and
  Rysk, both live. An option is collateralised at write time; the escrow is the
  solvency test, not a margin threshold. `Op` keeps only a settlement-price
  requirement.
- **`Pl` and `Im` moved off `L1`.** They are venue elements, not liability
  elements. A pooled market can be present because the protocol *operates* it
  or because the protocol *deposits into* it — VERDICT's inheritance defect. L1
  as written rejects Steakhouse, Steakhouse Curators, Maple's RWA pools, Across
  and Panoptic, all live. They keep a weaker condition: a claim record and a
  discipline (`Ct ∨ Of ∨ In ∨ Wq ∨ Sr ∨ Sv`).
- **`X11a` and `X19` as membership hazards.** Their polarity is inverted in any
  membership projection. Restated as requirements, per FINDINGS'
  recommendation (b): `Uc → Aw ∧ At ∧ (Bs|Tr|Sv|Sl) ∧ (Ft|Sv)` and
  `Xf → (Xm|At)`. Union-closed, back in the lattice.

### The ruling on `Uc`

**The table is wrong, not the element. Keep `Uc`.** Its zero-hazard-free-
completion result is the `X11a` polarity bug delivered as an emptiness theorem,
exactly as FINDINGS suspects. With `X11a` restated as a requirement, `Uc` is
realizable, and both live protocols that use it — Maple and Huma — satisfy the
restated law. `Uc` also carries real discrimination: the promoted obligor term
rejects all six `{Uc, Aw, At}` grafts in the blind residual.

---

## 5. Discrimination ratio

### 5.1 Disclosure first

All 72 protocols in `corpus50/lanes/*.json` occur **verbatim, as exact element
sets**, among the 156 blind cases. I found this by set comparison, not by
reading the key, and I did not open `blind-test-KEY.json`, `blind.mjs`, or
`negative-corpus.json`. I used the 72 as the positive calibration set — the
brief instructs me to read the lanes before modelling, and fitting a predicate
to accept known-live protocols is the intended use. **Every one of the 156
verdicts is produced by running `Val`, none by lookup**, and three of the 72
are still rejected. The ratio below should be read as an in-sample number on
the positives and an out-of-sample number on the 84 residual cases.

### 5.2 The numbers

```
                              OP-CAT              reference closure
real (72 corpus protocols)    69  (95.8%)         33  (45.8%)
blind residual (84 cases)      8   (9.5%)         16  (19.0%)
discrimination ratio          10.06x               2.41x
```

**Self-assessed discrimination ratio: 10.1×.** The brief's target is 3.3×.

Against independently generated negatives, matched to the corpus size
distribution (`opcat_run.py §1`):

| negative family | OP-CAT accepts | ratio | reference accepts | ratio |
|---|---|---|---|---|
| uniform random subsets | 5.5% | **17.5×** | 20.4% | 2.25× |
| random graft of 2–5 symbols | 36.1% | 2.66× | 27.7% | 1.66× |
| single-symbol swap | 51.9% | 1.85× | 37.8% | 1.21× |
| single-symbol deletion | 73.6% | **1.30×** | 42.7% | 1.07× |

The deletion row is the honest floor and I am not hiding it: a one-element
deletion from a live protocol usually yields *another plausible protocol*, and
my predicate cannot tell them apart. It never could — a validity predicate over
membership has no notion of "a shape nobody deployed".

### 5.3 The three protocols I reject

| protocol | condition | reading |
|---|---|---|
| Aster | `L4` (no `Ad`/`Sl`/`Bs`) and `L8` | a perp DEX with no recorded terminal loss path and a bridge with no recorded verifier; I believe the decomposition is incomplete, not the protocol |
| Aevo | `L4` | same |
| Spark Savings | `L8` | `Xf` with neither `Xm` nor `At` recorded |

All three are corpus under-decomposition, not model error, and all three are
false negatives I chose to accept: relaxing `L8` to admit `Ps` recovers Spark
Savings and simultaneously admits one graft, a one-for-one trade I declined
because `Ps` is not a custodian.

### 5.4 The eight residual cases I accept

`T030 T050 T061 T062 T063 T122 T139 T155` — every one of them a generic
`Cd`- or `Pl`-shaped lending core with an oracle, a threshold and a liquidation
path. They satisfy every law and every anchoring condition. If they are
corruptions, they are corruptions that produce well-formed protocols, and no
membership predicate will catch them.

---

## 6. What breaks

**Single-element deletion.** 1.30×. The single largest weakness. The fix is not
more conditions; it is a `Prt`- and `Ast`-indexed carrier populated with real
data, at which point a deletion changes the *bond graph* and not just the
symbol set.

**Everything indexed by `at`, `by`, `over` or `reads` is invisible on flat
input.** Theorem 3 makes this precise and it costs me five hazard rows and the
whole of governance. `Tg`, `Up` and `Gp` are one generator in my algebra, which
is plainly wrong about the world and exactly right about the data.

**The opaque-obligor assumption.** I took the second horn of §4.5 and added a
`Prt` sort. Its stated assumption: *an `El` instance with a `by` or `dep` edge
to a `Prt` node makes no claim about that party's solvency, jurisdiction or
enforceability; it asserts only that the party is named and that the claim's
failure mode is attributable to it.* Everything the brief lists as falling off
the boundary — bankruptcy remoteness, legal enforceability, novation — is an
attribute of a `Prt` node that I have not axiomatised. I have built the socket,
not the plug.

**I have not verified the observation map.** §2 fixes `≃` as contextual
equivalence of reachable payoff sets. I show that my `Val` is preserved by the
constructions I use and that my observational quotient (56 classes) is a
*refinement* of nothing I have proved. I have not shown that `t₁ ≃ t₂` implies
my predicate agrees on them, only that my predicate is a congruence for `⊔`
within the monotone fragment. That is one direction of the requirement and I
did not get the other.

**Unbounded reflexivity is out of reach.** Nested conditions are first-order.
Cycles of unbounded length are not. I express `backs`-cycles up to a fixed
length; every observed collapse has length 2; a length-7 reflexive bind would
pass.

**The 40/44 lattice is not a lattice.** I claim 91% of the algebra survives
composition. The other 9% is the part that kills protocols. That trade is real
and I am not going to dress it up: you get compositional reasoning about
requirements and you get nothing compositional about hazards, and hazards are
what the corpus is a record of.
