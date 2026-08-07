# Requirements from category theory and operads

## 0. Position in one paragraph

Composition is not a property to be tested; it is the thing a category *is*. The prior
carrier had no interfaces, so its composition operator had to be set union, and union
has no reason to respect a predicate. Give the objects interfaces and composition
becomes plugging, which is closed by definition and total exactly when types match.
I therefore require the carrier to be a **coloured PROP** (equivalently a symmetric
monoidal category presented by generators and relations; Mac Lane 1965, Lack 2004
*Composing PROPs*) whose colours are the things that travel on a wire between two
protocols, whose generators are the 58 elements, and whose relations are the laws that
make dangling debt ill-formed. The requirement table already *is* an arity assignment
written in the wrong notation: a requirement row "s ⟹ (T₁)(T₂)(T₃)" says that
generator `s` has three input ports, and the alternatives inside a term Tⱼ are the
generators inhabiting that port's colour. Read that way, the 15-arc digraph `D` is the
shadow of the port-inhabitation relation restricted to colours with a **unique**
inhabitant, and its thinness is a measurement of how monochrome the vocabulary is —
not a fact about DeFi. The `[ext]` terms are not holes: each is a named colour with
**zero** inhabitants, i.e. a precisely stated request for a generator. That converts
the whole "unformalized table" problem into a generation problem, which is the side
of the Galois connection where positive answers live.

## 1. Carrier and signature

**Colours (what is on a wire).** A finite set `C`, built from seven base colours with
parameters ranging over finite classification sets (not over all tokens):

| colour | reading | polarity |
|---|---|---|
| `A(u)` | **asset**: bearer quantity of unit-class `u` | linear |
| `K(u,π,σ)` | **claim**: redeemable position on obligor `π`, seniority `σ` | linear |
| `A*`, `K*` | **liability/deficit**: the dual object | linear |
| `P(u/u′,g)` | **price** with provenance grade `g ∈ {spot, twap, attested, asserted}` | classical |
| `V` | **verdict**: evaluation of a state predicate (solvent, defaulted, filled) | classical |
| `T` | **trigger**: a time- or epoch-indexed enabling token | classical |
| `U(scope,π)` | **authority**: capability over `scope` held by party shape `π ∈ {key, k-of-n, delegate, permissionless}` | classical |
| `M(dom,g)` | **message**: attested extra-domain fact at verification grade `g` | classical |

**Linear colours carry no comonoid.** `A`, `K` and their duals admit neither copy `Δ`
nor delete `!`. Classical colours `P,V,T,U,M` are each equipped with a **special
commutative Frobenius algebra** — Coecke–Pavlovic–Vicary's theorem that classical
structures are exactly the copyable ones is the licence: a price feed may be read by
many consumers, a dollar may not. This is Benton's linear/non-linear split (LNL, 1994)
realised as a two-tone colouring, and it is one bit per colour to specify.

**Objects** of the carrier are finite lists of colours (with symmetry). **Morphisms**
`φ : A → B` are *open protocols*: a wiring diagram of generators with input ports typed
`A` and output ports typed `B`. A closed application is a morphism `I → I` — every wire
plugged.

**Signature.** Each of the 58 elements `e` becomes an operation
`e : c₁ ⊗ … ⊗ c_k → d₁ ⊗ … ⊗ d_m`, its arity read off the requirement row whose subject
is `e`. Worked instances from the recorded table:

- `L4` (`Pf`, perpetual funding) → `Pf : A(u) ⊗ P(u,twap⁺) ⊗ V ⊗ K*(…) → K(…)`.
  Its three terms `(Ex)(Ct)(Li|Ad|Sl|Bs)` are the ports of colour `P`, `V`, and the
  **dual** colour `K*`.
- `L1` subjects `{Pl,Im,Cd,Pf,Op}` share the same three ports; the term
  `(Li|Ad|Sl|Bs)` is a `K*`-port with four inhabitants.
- `L5` (`Py`) `(Sh|Ix|Rb)(Ep)(Rd)` → ports of colour `K`-accounting, `T`, and a
  redemption port with the single inhabitant `Rd`.

**The decisive consequence.** "Every credit mechanism must name a loss absorber" is not
a clause. It is the statement that the diagram has **no dangling wire of dual colour**.
In a compact closed category (debt creation = the unit `η : I → K ⊗ K*`, repayment =
the counit `ε`, subject to the snake equations) a closed morphism cannot leave a `K*`
port open, because that is not a morphism `I → I`. The single largest family of
requirement rows is discharged by well-formedness of the carrier, at zero encoding cost.

**Magnitudes.** Do not put numbers in colours. Decorate: use Fong's **decorated
cospans** (2015) / Baez–Courser **structured cospans**, with a lax symmetric monoidal
functor `F : (Cospan-of-interfaces) → (Poset of semialgebraic constraints)`. A protocol
is `(φ, δ)` with `δ ∈ F(∂φ)` recording thresholds, caps, LTVs, rates and slashable
stake. Composition is pushout of interfaces together with the laxator on decorations.
Laxity — not strictness — is what keeps composition total while magnitudes vary.

**Formalization discipline.** A requirement row is **complete** iff (i) its subject
column names a generator, (ii) every term carries a colour, (iii) every colour so used
is **inhabited** (some generator has it as an output). Prose is never a constraint. An
`[ext]` term is recorded as a named, *uninhabited* colour and becomes a work item, so the
15 empty rows convert into an enumerated list of missing generators rather than silence.

## 2. Composition

Two operations, both definitional:

- **Sequential `∘`**: total on composable pairs, i.e. `φ : A→B`, `ψ : B→C`. Partiality
  is *typing*, not a side condition — a colour mismatch means there is no pair to compose.
- **Monoidal `⊗`**: total, always. Two protocols side by side with no shared wires is
  always a protocol.

Closure is free: `Hom(A,C)` contains `ψ∘φ` because that is the definition of a category.
There is nothing to preserve and nothing to measure.

**Prohibitions must be discharged by colour refinement, never by predicate
intersection.** This is the central requirement. The recorded counterexample — Uniswap
∪ Aave arming `X2` — is, ported, the statement that an asset wire leaving a flash-liquidity
generator can reach a collateral test's price port through a spot-price emitter. Refine
the grade parameter: `Cp,Wg,St,Cl` emit `P(·,spot)`; `Tp,Oa,At` emit `P(·,twap/attested)`;
`Ct` demands `P(·,twap⁺)`. Then **the bad composite is not a term**. It was never in the
carrier, so no closure property was violated. Every prohibition that names a
configuration must be relocated into `C` this way, or else demoted to a decoration
inequality that is **monotone**: `risk(ψ∘φ) ≤ risk(φ) ⊔ risk(ψ)` in an ordered semiring,
making "safe" a downset and safety compositional by a numeric bound rather than by a
lattice miracle. Prohibitions kept as forbidden sub-diagrams are exactly negative
application conditions in graph transformation (Habel–Heckel–Taentzer), which are known
not to be preserved by composition; that is why they must not stay in that form.

**Curators and aggregators** — the missing level above the protocol — are handled by
making the carrier an **algebra over Spivak's operad of wiring diagrams** `𝒲_C`
(Spivak 2013; Vagner–Spivak–Lerman on open dynamical systems). A curator allocating
across venues is an operation *of the operad*, applied to sub-algebras left
unspecified. No internal hom is needed; operadic composition supplies the second level.

## 3. Completeness theorem (formal statement)

Let `Σ` be the coloured signature above, `𝐅(Σ)` the free coloured PROP on it, `R` the
relations (Frobenius laws on classical colours, snake equations on financial duals,
routing idempotence), and `𝐏 = 𝐅(Σ)/R`. Let `𝐒` be a semantic PROP of decorated
relations on ledger states, and `⟦−⟧ : 𝐏 → 𝐒` the interpretation. Let each of the 60
applications be presented as a wiring diagram `W_i` with observed interface `A_i → B_i`.

> **Theorem (aimed) — Generation.** For every `i` there is `φ_i ∈ 𝐏(A_i, B_i)` with
> `⟦φ_i⟧ ≈ ⟦W_i⟧`, where `≈` is black-box equivalence at the interface
> (Baez–Fong–Pollard black-boxing). Equivalently: the smallest sub-PROP of `𝐒`
> containing `⟦Σ⟧` and closed under `∘`, `⊗`, symmetries and the classical structures
> contains every `⟦W_i⟧`.

"Functionally complete" means: `Σ` generates the DeFi-realizable sub-PROP of `𝐒`.
Falsified by exhibiting one application whose black-box behaviour lies outside the
generated sub-PROP — which requires an invariant, i.e. a functor separating it.

**The analogue of Post's maximal clones.** `Σ` fails to be complete exactly when it is
contained in a proper sub-PROP closed under `∘, ⊗, σ`. Six such maximal obstructions are
identifiable, each with an escape test, and each corresponds one-to-one with a recorded
expressiveness failure:

1. **Colour clone.** The output colours of `Σ` generate only `C′ ⊊ C`. *Escape:* every
   colour is inhabited. (↔ the `[ext]` terms.)
2. **Conservation clone.** Every generator is conservative for some monoidal functor
   `𝐏 → (ℝ,+)`. *Escape:* `Em` (emissions), `Sl` (socialized loss) leak. (↔ no
   conservation laws.)
3. **Filtration clone.** If stratum is subadditive, `Σ ⊆ 𝐏_{≤k}` generates only
   `𝐏_{≤k}`. *Escape:* a generator at every stratum 0–4. (↔ the grading, never used.)
4. **Party-symmetric clone.** Every generator invariant under permuting party roles.
   *Escape:* a generator distinguishing obligor from holder. (↔ USDT/USD1 collision.)
5. **Affine clone.** Every decoration affine in magnitudes. *Escape:* `Op` payoff
   `max(S−K,0)` and the `Ct` threshold. (↔ no magnitudes, 9 prose prohibitions.)
6. **No-copy clone.** No classical structure supplied. *Escape:* `Δ, !` given as
   generators on `P,V,T,U,M`. (↔ one price feeding many consumers.)

## 4. Construction / synthesis

**Problem.** Given a specification `(A → B, δ_spec)` — an interface plus a downward-closed
predicate on decorations — find `φ ∈ 𝐏(A,B)` with `δ(φ) ⊑ δ_spec`.

**Decidability.** Terms of a given colour over a finite coloured signature form a
**regular tree language**; the generators are a regular tree grammar, and inhabitation is
grammar non-emptiness — linear time (Comon et al., *TATA*). Adding higher-order ports
(curators over unspecified sub-algebras) makes it typed-combinator inhabitation, PSPACE-
complete (Statman 1979); the first-order fragment we need is an AND-OR reachability
problem, PTIME. With monotone lattice-valued decorations and a downset spec, least-
fixed-point search stays polynomial; general semiring decorations are NP.

**Certificate.** The derivation term `φ` together with its typing derivation (the wiring
diagram with every port assigned and no dangling dual wire) and the evaluated decoration.
Checking is syntax-directed and linear in `|φ|`: propositions-as-types — the well-typed
term *is* the proof that the construction discharges the specification.

## 5. Disposition of the prior obstructions

- **Admissibility not union-closed.** *Dissolves.* Composition is no longer union and
  admissibility is no longer a predicate on carriers; prohibitions become typing.
- **`X2` counterexample.** *Converted into a colour.* The grade parameter on `P` makes
  the composite untypable; it was never a term.
- **Bilattice / diagonal obstruction.** *Converted into structure.* The diagonal is `Δ`.
  Its absence on financial colours is precisely the conservation law the prior work
  said it could not state. The obstruction is the feature.
- **Inflationary/deflationary pair forces identity.** *Localized.* It assumes a strict
  adjoint pair. Black-boxing is genuinely **lax** monoidal, not an adjoint pair, so the
  collapse argument does not apply to the decorated carrier.
- **Kripke–Kleene collapse to `(⊥,⊤)`.** *Localized to the powerset.* Over a free operad
  generation is by term depth, well-founded (acyclicity of `D` is the base case), and the
  fixpoint is reached in height-many steps carrying full information.
- **Max-clique compatibility / maximum union-closed subfamily.** *Retired.* Every typed
  composite is admissible; there is no subfamily to extract.
- **Coverage 45.3 % / 689 undischarged obligations.** *Converted into a computable
  invariant:* the colour-inhabitation deficit. Each undischarged obligation is a named
  uninhabited colour, i.e. a specification for a missing generator.
- **The 15-arc digraph `D`.** *Explained.* It is the sub-relation of port-inhabitation
  where the colour has exactly one inhabitant. The convex geometry (Edelman–Jamison) is
  the deterministic special case of the tree grammar; where colours have several
  inhabitants, unique minimal generators become antichains of derivations.

## 6. Minimal viable enrichment (ranked by payoff / cost)

1. **Ports and colours (do this one).** Re-read the same 29 rows and assign each term a
   colour and each element an output colour. Cost: one table, no new fieldwork. Buys:
   composition closed by construction; the `[ext]` holes become an enumerated deficit;
   the loss-absorption family of requirements discharged by well-formedness.
2. **Linear/classical polarity.** One bit per colour. Buys conservation laws and the
   Uniswap v4 deferred-settlement condition (a Frobenius spider: wires at a node net to zero).
3. **Compact closure on `K`/`K*`.** Buys "obligation cannot arise" — a venue that escrows
   the maximum payoff has its `K*` port closed by `ε` at trade time, so the term is
   discharged rather than left open.
4. **Decorations.** Buys the 9 prose prohibitions and every threshold.
5. **Party parameter on `U` and `K`.** Buys the 135 residue obligations and USDT/USD1.
6. **Operad-of-wiring-diagrams level.** Buys curators and aggregators-of-aggregators.

## 7. Falsifiable near-term test

**Input:** the 58 elements, the 29 requirement rows, the 72 decompositions, the recorded
15 arcs of `D`.
**Procedure:** (a) assign each element an output colour and each requirement term a
colour, giving every element an arity (a half-day of table work); (b) compute
`inhab(c) = {e : out(e) = c}`; (c) form
`D′ = {(s,t) : c ∈ ports(s), inhab(c) = {t}}`; (d) for each of the 72 protocols, attempt a
well-typed wiring of its recorded element multiset.
**Verdict:** the structure is **confirmed** if `D′ ⊇ D` and `D′` is acyclic, and if
`D′ = D` exactly then the colouring retrodicts the only real structure the prior work
found, with no fitting. It is **confirmed further** if ≥ 80 % of the 72 element sets admit
a total wiring whose only open ports have globally uninhabited colours. It is **refuted**
for any arc of `D` that `D′` contradicts — that colour assignment is then wrong and must
be repaired before proceeding. Sharp prediction available immediately: the six order-book
perpetuals venues omit exactly `{Ct, Ex, Li}` because `Pf`'s `V`, `P` and `K*` ports are
singleton-inhabited, while Jupiter carries `Pm`, which declares none of those ports.

## 8. Named proof obligations

- **PO-CAT-1:** Every requirement term admits a colour in `C`, and the induced map
  `e ↦ arity(e)` is well defined on all 58 elements.
- **PO-CAT-2 (Colour-Determinacy Conjecture):** `D = {(s,t) : ∃c ∈ ports(s), inhab(c) = {t}}`.
- **PO-CAT-3:** `𝐏 = 𝐅(Σ)/R` is a coloured PROP in which `∘` is total on typed pairs and
  `⊗` is total, and every closed morphism `I → I` has no dangling dual-coloured wire.
- **PO-CAT-4:** Every recorded prohibition is either (i) realizable as a colour refinement
  making the forbidden composite untypable, or (ii) a monotone decoration inequality; in
  particular exhibit the refinement discharging `X2` and `X21`.
- **PO-CAT-5 (Stratum Filtration):** stratum is a filtration on `𝐏` with
  `deg(ψ∘φ) = deg(φ⊗ψ) = max(deg φ, deg ψ)`, and each inclusion `𝐏_{≤k} ⊂ 𝐏_{≤k+1}` is
  strict, witnessed by an application in the corpus.
- **PO-CAT-6 (Generation Theorem):** for each of the 60 applications there is
  `φ_i ∈ 𝐏` with `⟦φ_i⟧ ≈ ⟦W_i⟧` under black-boxing.
- **PO-CAT-7 (Escape from the six clones):** `Σ` is not contained in any of the colour,
  conservation, filtration, party-symmetric, affine or no-copy sub-PROPs; give the
  witness generator for each.
- **PO-CAT-8:** Inhabitation in `𝐏` restricted to first-order ports with lattice-valued
  decorations and a downset specification is PTIME; give the algorithm and its certificate
  checker.
- **PO-CAT-9:** The decoration functor `F` is lax symmetric monoidal, and black-boxing
  `⟦−⟧` is lax rather than an adjoint pair — hence the inflationary/deflationary collapse
  does not apply.
- **PO-CAT-10:** The colour-inhabitation deficit computed from the corpus equals the 689
  undischarged obligations up to the classification of residue, giving each a named
  missing generator.
