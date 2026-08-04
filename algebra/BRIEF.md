# Build an algebra of DeFi composition

You are one of nine mathematicians working independently. Your job is to
**build a model** — a working algebra, stated formally, that classifies real
protocols. Not an assessment of whether one is possible. Not a survey. A model.

Where you are uncertain, **make a choice and state it as a choice.** A crisp
wrong answer is more useful to us than a hedged right one, because we can test
it. Do not write "it depends", do not list alternatives you will not pick, and
do not spend pages on limitations. One short section at the end for what breaks
is enough.

---

## 1. The data

All paths under `/root/DefiElements`:

| File | What |
|---|---|
| `viz/src/data.ts` | 58 elements (mechanism, family, stratum S0–S4), 29 laws, 20 hazard rules |
| `viz/src/laws.ts` | our reference parser + closure engine, in TypeScript |
| `corpus50/lanes/*.json` | 72 real protocols decomposed, with residue and forced fits |
| `corpus50/VERDICT.md` | what the corpus benchmark found |
| `formal/atlas.qnt` | a Quint model of the same thing, 7 tests passing |
| `algebra/blind-test-set.json` | **your test set — 156 element-sets** |

An element is a recurring on-chain mechanism. A protocol is a set of elements.
A law has the form `(subj₁|subj₂|…) → term₁ + term₂ + …`, each term a
disjunction of elements; it fires if any subject is present and is satisfied if
every term has at least one alternative present.

## 2. The observation map — fixed, not negotiable

You do not get to choose what counts as observable. We fix it, because an
algebra that picks its own semantics can make anything equivalent:

> **⟦t⟧ = the set of reachable net-payoff outcomes per agent class**
> (depositor, borrower, liquidity provider, operator, governance),
> quantified over an adversarial environment: all price paths, all transaction
> orderings, and composition with any other term over the same signature.
>
> `t₁ ≃ t₂` iff no composition context `C[·]` built from the signature
> distinguishes `⟦C[t₁]⟧` from `⟦C[t₂]⟧`.

Contexts are restricted to terms over the signature itself. You may not appeal
to a distinguishing environment that could not be built out of the vocabulary.

## 3. What you must deliver

**A signature and carrier.** Stated formally. Justify from the data, not from
elegance.

**At least one composition operation**, with its laws settled — associativity,
commutativity, idempotence, identity, absorption. Prove or refute each. Do not
leave one open.

**A decidable validity predicate**, with its complexity.

**A classification of all 156 cases** in `algebra/blind-test-set.json` as
`ADMISSIBLE` or `INADMISSIBLE`. Some are real deployed protocols; some are
synthetic corruptions. You are not told which, or in what proportion. Write your
answers to `algebra/verdicts/<your-id>.json` as
`{"id":"T001","verdict":"ADMISSIBLE"}, …` — all 156, no omissions.

**This is how you are scored.** Our own closure predicate accepts 50% of real
protocols and 15% of random noise — a discrimination ratio of **3.3×**. Beat it.
An algebra that accepts everything scores 1.0× and fails, no matter how elegant.

## 4. Five facts the corpus established. Do not model the idealised version.

1. **Two thirds of the law content is prose.** 52 of 77 requirement terms name
   no element. 4 of 29 laws can never fire. 19 of 20 hazard rules are
   undecidable from membership. You may promote prose to formal — say which and
   what it costs.
2. **Decomposition is not injective, and the fibres are not homogeneous.**
   USDT ≡ USD1, USDC ≡ PYUSD, USYC ≡ BUIDL, SparkLend ⊂ Aave V3, and the top
   three bridges by TVL ($17.8B) share an identical five symbols. USDT and USD1
   are one point and are not one credit. **If your algebra cannot separate them,
   say so explicitly and identify the generator that would.**
3. **A strategy is a missing level.** A Yearn or Steakhouse vault is a *policy
   over protocols* — "borrow against stETH to 80% LTV, unwind at 85%" — not a
   mechanism. It has no on-chain machinery of its own. One sort will not hold
   this. Decide whether your carrier is many-sorted, and commit.
4. **Validity is non-monotone.** Adding an element can satisfy a law and arm a
   hazard simultaneously. Most pleasant theorems assume monotonicity. Deal with
   it.
5. **There is an off-chain boundary and coverage falls off it monotonically** —
   obligor, register of record, reserve, custody, legal recourse. It is
   inversely correlated with capital held. Either bound your scope to on-chain
   state machines and say so, or add an opaque-obligor generator with stated
   assumptions. Choose one.


## 4b. What the model checker settled. These are results, not opinions.

Apalache and exhaustive enumeration over the full 58-element vocabulary. Treat
these as fixed points your algebra must reproduce or explicitly overturn.

**There is a lattice, but only for closure.** Closed sets are union-closed
(satisfaction is monotone), contain the empty set and the top, and therefore
form a complete lattice. But **meet is not intersection** --
`{Xm,Xf,Of,Bs} n {Xm,Xf,Of,Sl}` is open. And **hazards destroy even the join**:
`{Xm,Xf} u {Aw}` arms X19. So closure alone is lattice-structured and validity
is not. Build on this; do not re-derive it.

**Stratum is not derivable.** Derived topological rank agrees with the
hand-assigned stratum on 3 of 58 elements, and all three agreements are the
trivial 0=0 case. Rank ranges 0-2 against a stratum range of 0-4, because 45
elements have no outgoing element-expressible requirement. Exactly one genuine
inversion exists: `L21: Gs(S3) -> Au(S4)`. This independently confirms the FCA
result that concept lattices are not graded. Stratum stays asserted, or you
replace it with something else and say what.

**There are unlisted hazards, and here is the complete list up to size 5.**
`{Fl, Xm}` is closed under all 25 fireable laws, arms none of the 20 hazard
rows, and is reachable -- flash atomicity (`Fl` is the vocabulary's only
async-impossible element: repay within one settlement scope or revert)
co-present with a cross-domain element. X2 covers flash-loan price manipulation;
nothing covers flash atomicity crossing a domain boundary. Second witness of the
same shape: `{Fl, Au, Rl}`. A third, `{Au, Gs}`, is a stratum inversion -- a
defect in our table rather than in DeFi.

The bound is honest and it is tight: all 5,038,954 subsets of size <= 5 were
exhaustively enumerated, of which 1,458,840 are closed and written-hazard-free.
Within that space the minimal witness list is exactly those three plus 30
inexpressible-requirement sets. **Nothing is claimed at size >= 6, and finding a
size-6 witness would be a real contribution.**

**Reflexivity is provably not expressible over element types.** The requirement
relation over all 58 elements taking every alternative is a DAG with no
self-loops, so no subset can contain a cycle. Terra's collapse becomes a
2-cycle only over `(element, asset)` pairs under a `backs` relation:
`(As,UST) -> (Rd,LUNA) -> (As,UST)`. If your carrier is element sets, you cannot
express the thing that killed Terra. **That is a constraint on the carrier, and
it is the single strongest argument in this brief for a richer one.**

**One element is unrealizable.** `Uc` (undercollateralized credit) has zero
hazard-free completion. The hazard table forbids every way of building one of
its own elements. Either the table is wrong or `Uc` should not be in the
vocabulary. Rule on it.

## 5. Prior art — position against it, briefly

**Interface automata** (de Alfaro & Henzinger 2001) — input assumptions, output
guarantees, optimistic composition (compatible iff *some* environment works),
decidable, with refinement. Closest existing analogue to our closure criterion.
**Assume-guarantee contracts** (Benveniste et al. 2018) — composition,
conjunction, quotient, refinement, already an algebra. **Feature models** — the
same problem industrially, compiled to SAT. **Formal Concept Analysis** — the
Duquenne–Guigues base is minimal and entails all implications; are our 29 laws
reducible? **Financial contract algebras** — Peyton Jones & Eber, the semiring
rework (FLOPS 2024), ACTUS, Marlowe. No completeness theorem exists for any
financial contract language; claims are coverage claims.

Two paragraphs of positioning. Not a literature review.


## 5b. Where the ground has already been surveyed

We ran a survey so you do not have to. Three candidates are live; three are dead
ends that will each cost you a month. This is to save you time, not to pick your
answer -- if the survey is wrong, prove it wrong.

**Live, ranked:**

1. **Feature models / software product lines.** Near-exact structural fit. Our
   families are xor/or-groups, strata are `requires` chains, hazards are
   `excludes`, and the 29 laws are precisely the case Batory added arbitrary
   propositional cross-tree constraints for. Non-monotone validity is native in
   both directions -- the semantics is an arbitrary subset of 2^F. Real tooling
   (flamapy, UVL, FeatureIDE). Composition exists: FAMILIAR's intersection,
   union, difference, product and slice, associative and commutative *up to
   semantic equivalence*.
2. **Assume-guarantee contracts** (Incer 2022 supersedes Benveniste 2018).
   The best actual algebra: conjunction, disjunction, composition and merging
   are all idempotent commutative monoids with identity; bounded distributive
   lattice; four semirings; quotient is a true residual. Saturation gives you
   "law relieved when subject absent" for free and carries disjunctive heads
   natively. Encode a hazard as `A = [[hazard]], G = empty` -- the naive
   `(true, not hazard)` provably destroys every law's conditional structure
   under conjunction. Caveat: composition needs ports we do not have, and
   dropping it costs six of the eight operations.
3. **Formal Concept Analysis** -- an audit tool, not an algebra. The
   Duquenne-Guigues base is minimum in *number* of implications, not total size.
   Two hard walls: disjunctive conclusions are structurally outside Horn, since
   intents are intersection-closed by construction; and **stratum is not
   recoverable as lattice level** -- concept lattices are not graded. Worth
   running on the 58 to find redundancy. USDT and USD1 clarify into one row.

**Dead ends:** open games (wiring plus cartesian product, no ambient-presence
triggers), decorated cospans (total, monotone, and coproduct is not idempotent,
plus zero finance applications), institution theory (amalgamation fails in CASL
itself; conservativity is not r.e.).

All three live candidates independently diagnose this data as **a propositional
theory over 58 atoms** -- cheap and decidable. The two genuinely open problems
are composition of *sets without ports*, which nobody has solved, and the
non-injectivity, which is a modelling defect no algebra will fix. Worth a look:
nested graph conditions / negative application conditions (Habel-Pennemann),
equivalent to first-order graph formulas and inherently non-monotone.

## 6. Answer these directly

1. What is the carrier? Sets, multisets, terms, or something with more structure?
2. Is composition a join? If so, is the structure a lattice, and are the laws a
   closure operator in the Galois sense?
3. Are the 58 elements independent, or is there a smaller generating set? Name
   the redundant ones.
4. Is stratum derivable as rank, or must it stay asserted? Where would a derived
   rank disagree?
5. Terra died of reflexivity and there is **no requirement cycle in the law
   graph**. Define the relation in which its collapse *is* a cycle, or show none
   exists.

## 7. Your lens

You have been assigned one of: **categorical** (monoidal categories, props,
decorated cospans, open games), **order-theoretic** (lattices, closure
operators, Galois connections, FCA), or **logical** (Horn theories, SAT/SMT,
interface automata, assume-guarantee).

Start there. **Abandon it if it does not fit** — say so and switch. We assigned
lenses to stop nine people converging on the same monoidal-category answer, not
to constrain the result.

## 8. Output

Write to `algebra/reports/<your-id>.md`:

1. Signature, carrier, operations, laws — formal, with proofs.
2. The validity predicate and its complexity.
3. Answers to §6, numbered.
4. What you added to the vocabulary and what you cut.
5. Your self-assessed discrimination ratio on the blind set.
6. One short section: what breaks.

And `algebra/verdicts/<your-id>.json` with all 156 classifications.

Be direct. State results as results.
