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
| `algebra/blind-test-set.json` | **your test set — 144 element-sets** |

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

**A classification of all 144 cases** in `algebra/blind-test-set.json` as
`ADMISSIBLE` or `INADMISSIBLE`. Some are real deployed protocols; some are
synthetic corruptions. You are not told which, or in what proportion. Write your
answers to `algebra/verdicts/<your-id>.json` as
`{"id":"T001","verdict":"ADMISSIBLE"}, …` — all 144, no omissions.

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

And `algebra/verdicts/<your-id>.json` with all 144 classifications.

Be direct. State results as results.
