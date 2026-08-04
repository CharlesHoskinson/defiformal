# Brief: a complete and composable algebra of DeFi

You are one of nine mathematicians working independently on the same problem.
Three of you share each of three model families; you will not see each other's
work until adjudication. Disagreement between you is the point.

---

## 0. The problem, stated precisely

We have an empirical vocabulary of **58 mechanisms** ("elements") observed
across real DeFi protocols, **29 composition laws**, and **20 hazard rules**.
It behaves like a taxonomy. We want to know whether it can be made into an
**algebra**.

Deliver a formal system in which:

- **P1 — Protocols are terms.** Every one of the 60 decomposed real protocols
  (§4) is expressible as a term over your signature.
- **P2 — Composition is an operation.** There is at least one binary operation
  combining protocols into protocols, with stated laws (associativity?
  commutativity? identity? absorption?). Say which hold and *prove or refute*.
- **P3 — Validity is decidable.** There is a predicate — well-typedness,
  closure, satisfaction, whatever your framing — that separates admissible from
  inadmissible terms, and it is decidable at realistic scale.
- **P4 — The known deaths are inadmissible, or explicitly out of scope.** Three
  protocols in the corpus died. Your system should either reject them or say
  precisely why the failure is outside any algebra of this kind. **Both are
  acceptable answers; pretending is not.**

**Completeness** here means: *coverage of the corpus*, not a proof over all
possible DeFi. Every precedent we found (§5) establishes completeness by
benchmarking against an external corpus and extending the language when the
corpus resists. That is the standard you are held to.

**Composability** means: the validity predicate on `A ⊕ B` is computable from
facts about `A` and `B` — you do not have to re-analyse the whole system. If
that fails, say so; a proof that DeFi composition is *not* compositional in
this sense would be a major result.

---

## 1. What the data actually is (read this before modelling)

Each element has: a **family** (16 of them, defined as mutual substitutes), a
**stratum** S0–S4 (asserted prerequisite depth), a **status**, and an
**asynchrony** property (native / repairable / impossible — exactly one element
is impossible).

The 29 laws have the shape

```
(subject₁ | subject₂ | …)  →  term₁ + term₂ + …
```

where each term is a disjunction of element symbols. A law fires when any
subject is present; it is satisfied when every term has ≥1 alternative present.
So the laws are **a conjunction of disjunctions over a set** — closer to a
Horn-ish constraint system than to an edge relation.

## 2. The measured defects — do not model the idealised version

These are computed facts from two independent implementations (a TypeScript
engine and a Quint model that agree):

| Fact | Value |
|---|---|
| Laws total | 29 |
| Laws that can ever fire (element subject) | **25** — L14, L23, L25, L26 have prose subjects |
| Requirement terms total | 77 |
| Terms naming an element | **25** |
| Terms that are prose ("exit-liquidity", "a terminal loss path") | **52** |
| Hazard rows | 20 (19 numbered families) |
| Hazard rules decidable from element membership | **1** (X2) |
| Hazard rules that fire on any real protocol | **0** |
| In-degree over laws | max 4, most 0–2 |
| Requirement cycles in the corpus | **none** — reflexivity is not in the law graph |

**Two thirds of the requirement content is natural language.** Any algebra that
assumes total formalisation is modelling a system we do not have. You may
propose promoting prose terms to formal ones — that is a legitimate and
probably necessary contribution — but say which, and what each promotion costs.

## 3. Closure results on the 12-protocol corpus

Closes: Aave v3, Uniswap v3, Maker/Sky, Liquity v1, GMX v2, CoW Protocol.
Does not close: Lido v2, CCTP v2 Fast, Centrifuge, Terra ✝, Mango ✝, Euler ✝.

**Note the embarrassment and take it seriously:** three *live, working*
protocols fail closure, and one dead protocol (Euler) fails for a reason
unrelated to why it died. Any of these is possible:
(a) the laws are overstated, (b) the element lists are incomplete,
(c) closure is the wrong validity predicate. Rule on which.

## 4. The corpus you must cover

60 protocols across 12 categories, decomposed into this vocabulary with
residue and forced fits recorded per protocol. **Attached separately** — this
is your benchmark and your completeness test.

Categories: spot DEX · lending · CDP stablecoins · liquid staking & restaking ·
perpetuals · yield & vaults · bridges · intents & aggregation · RWA & private
credit · options & structured · fiat stablecoin issuers · prediction markets.

Pay attention to the residue column. Where the vocabulary failed is where the
algebra must either extend or explicitly bound its scope.

## 4b. What the corpus measurement already found — the hard part of your job

The 60-protocol decomposition is not a formality we ran to hand you data. It
returned three results that a candidate algebra must confront directly.

### (i) The decomposition map is not injective, and its fibres are not semantically homogeneous

Distinct protocols decompose to **identical element sets**:

| Fibre | Members |
|---|---|
| `{Ps, Rd, At, Fz, Up}` | Tether USDT · World Liberty USD1 |
| `{Ps, Rd, At, Fz, Xm, Xf, Up, Gp}` | Circle USDC · PayPal PYUSD |
| `{Aw, Sh, At, Ex, Rd, Fz, Up, Gp}` | Circle USYC · BlackRock BUIDL |
| options CLOB set | Derive · Aevo |
| CTF+CLOB+UMA set | Polymarket · Predict.fun · OPINION · InsightX |

Non-injectivity is not by itself a defect — a quotient is a legitimate
abstraction. **The defect is that the quotient does not respect the property we
care about.** USDT and USD1 are the same point in this space and are not
remotely the same credit. So:

> **Q9. Is decomposition a homomorphism onto anything?** State the semantic
> function you claim your algebra preserves, then check it is constant on the
> fibres above. If it is not, you have proved that no function of the element
> set can predict solvency — which is a real theorem, and probably the most
> important one available here. Prove it or exhibit the missing generators that
> separate the fibres.

### (ii) Resolution is inversely correlated with capital at risk

The vocabulary spends **five symbols** (`Cp`, `Wg`, `St`, `Cl`, `Pm`)
distinguishing algebraic variants of a scalar function on a two-asset pool, and
**one symbol** (`Op`) for the entire options universe — collapsing at least six
risk-relevant distinctions: European/American/perpetual exercise, cash vs
physical settlement, peer-to-peer vs peer-to-pool underwriting, upfront vs
streamed premium, isolated vs portfolio margin, model-priced vs book-priced.

Measured coverage: RWA 39% · options 63% · fiat stablecoins **25%** ·
prediction/other 44%. Lane-wide ≈41% unweighted. Weighted by *components that
determine whether a holder gets paid*, fiat stablecoins fall to near zero.

$183B of USDT resolves to five symbols, three of them forced fits, with an
honest core of **two**: `Fz` and `Up`. Every symbol it uses is control-plane
(`Fz`, `Up`, `Gp`, `At`, `Aw`), not mechanism.

> **Q10. Is the signature's granularity principled or historical?** The
> resolution appears to track *how many independent Ethereum codebases were
> written for a thing*, not economic significance. If so, the vocabulary is a
> census of implementations rather than a basis. Say whether your algebra
> inherits that bias, and whether a **normal form** exists that would expose it.

### (iii) There is a boundary, and coverage degrades monotonically across it

Expressibility falls as the off-chain fraction of a protocol rises — and the
off-chain fraction is *inversely* correlated with how much money the protocol
holds. Fifteen named gaps, in priority order, all of them off-chain or
institutional:

obligor & recourse · register of record (is the chain authoritative or a mirror
of a transfer agent's book?) · reserve composition & custody · bankruptcy
remoteness & claim perfection · central counterparty / clearing & novation ·
conditional-token split & merge · peer-to-pool payoff underwriting · delegated
discretionary allocation mandate · portfolio/scenario margin · pricing model /
volatility surface · instrument listing & expiry-cycle definition · rulebook
(natural-language settlement criteria) · off-chain matching with on-chain
settlement · terminal settlement-price fixing · investment discretion.

Two of these deserve separate notice:

- **Conditional-token split/merge** — deposit $1, receive one YES and one NO;
  return both, get $1. A *state* partition of collateral. `Py` partitions along
  **time**; nothing partitions along **state**. This is the founding primitive
  of an entire sector and it is absent. If your algebra has a tensor or a
  coproduct, this is the obvious thing for it to be.
- **Delegated discretionary allocation mandate** — a named human party choosing
  exposures for depositors' capital, for a fee, with no on-chain recourse.
  DefiLlama's #9 and #12 categories by TVL, $16.5B combined, **zero coverage**.
  The fastest-growing organisational form in DeFi has no symbol. Note this is
  not a mechanism at all; it is an *agent with discretion*, and it may be
  categorically outside anything a term algebra can express.

> **Q11. Where do you draw the boundary, and can you draw it formally?** The
> honest reading is that this is a vocabulary of **on-chain state machines**.
> Options: (a) declare the boundary and bound your completeness claim to it —
> respectable, and it makes the algebra provable; (b) add an *opaque obligor*
> generator with stated assumptions and no internal structure, in the spirit of
> interface automata's environment assumptions; (c) argue the boundary is
> illusory. Pick one and defend it. **Do not quietly cover the gap with prose
> terms — that is what produced the 52 prose requirement terms already.**

### What this means for P1

P1 said "every one of the 60 protocols is expressible as a term". Given the
above, **weaken it honestly rather than satisfy it cheaply**: an algebra in
which USDT is a term is trivial to build and worthless. The real target is an
algebra in which USDT is a term *and the terms that differ from it are the ones
that behave differently*. If that is impossible at this abstraction level, prove
it — see Q9.

## 5. Prior art you are expected to engage with

Do not reinvent these. Position your system relative to them.

- **Interface automata** — de Alfaro & Henzinger, ESEC/FSE 2001. Components
  carry *input assumptions* and *output guarantees*; composition is
  **optimistic** — compatible iff *there exists an environment* making them
  work. Decidable, with a refinement relation. This is the closest existing
  formal analogue to our closure criterion. **If you do not build on it, say
  why not.**
- **Feature models / software product lines.** A vocabulary plus cross-tree
  `requires`/`excludes` constraints, compiled to SAT, with established analyses:
  void model, dead feature, false-optional feature, redundant constraint. The
  industrial version of our problem. Empirical warning (Nešić et al., ESEC/FSE
  2019): practitioners avoid complex cross-tree constraints because they defeat
  comprehension.
- **Formal Concept Analysis.** Objects × attributes → concept lattice, plus the
  **Duquenne–Guigues implication base**: a minimal set of implications entailing
  all others. Directly relevant — *are our 29 laws reducible to a smaller
  base?* And is stratum recoverable as lattice level rather than assertion?
- **Zwicky's General Morphological Analysis / Cross-Consistency Assessment.**
  Configurations grow factorially; pairwise consistency judgements grow only
  quadratically, so a few hundred pairwise judgements constrain ~10⁵
  configurations. Also distinguishes **logical** vs **empirical** vs
  **normative** inconsistency. Our 29 laws almost certainly conflate all three —
  this may be the actual explanation for §3.
- **Financial contract algebras.** Peyton Jones & Eber (combinators with
  denotational semantics; later reworked around a **semiring** — "Rigged
  Contracts", FLOPS 2024); ACTUS (32 contract types, completeness by census);
  Marlowe (five constructs, completeness claimed only as "a small number of
  constructs that in combination can describe many contracts", and **extended
  when benchmarked against ACTUS**); DAML (authorization closure checked per
  transaction).
- **Architectural mismatch** — Garlan, Allen & Ockerbloom 1995, restated 2009.
  Component assumptions "are almost always implicit". Our 52 prose terms are
  the expected result, not an anomaly. Thirty years of interface formalism did
  not close this gap.
- **Compositional MEV** — Bartoletti et al. 2026 propose **MEV
  non-interference** as the safety criterion for composition: safe if it does
  not increase extractable value from existing contracts. Note this is
  deliberately *semantic and adversarial* rather than syntactic. Argue for or
  against a syntactic criterion in light of it.

## 6. Specific questions to answer

1. **What is the carrier?** Sets of elements? Multisets? Terms over a signature?
   Something with more structure (a lattice, a semiring, a monoidal category)?
   Justify from the data, not from elegance.
2. **Is the natural operation a join?** Protocol composition looks like set
   union with side conditions. If it is a join, is the structure a lattice, and
   do the laws form a closure operator in the Galois sense?
3. **`|` alternatives:** nondeterministic choice, refinement, or a lattice of
   legal configurations? This decides whether "the space of protocols satisfying
   the same laws" is a real object.
4. **Is closure a monotone operator?** If adding elements can *satisfy* a law
   but also *arm* a hazard, validity is non-monotone — which breaks many
   pleasant theorems. Confirm and deal with it.
5. **Can stratum be derived** as rank/height rather than asserted, and where
   would a derived rank disagree with the recorded S0–S4?
6. **Reflexivity is not in the law graph.** Should it be a *derived* property (a
   cycle in a suitably-defined dependency relation) rather than an asserted
   hazard? If so, define the relation in which the loop is a cycle.
7. **What is the minimal generating set?** Are all 58 elements independent, or
   is there a smaller basis from which the rest are definable?
8. **State the impossibility result if there is one.** A crisp theorem that some
   desirable property cannot hold would be worth more than a workable system.

## 7. Deliverable

- The signature and carrier, stated formally.
- The operations and their laws, with proofs or counterexamples.
- The validity predicate and its decidability/complexity.
- A **coverage table**: for each of the 60 protocols, expressible or not, and
  what was needed.
- What you had to **add** to the vocabulary, and what you would **cut**.
- The **honest limits**: what your algebra cannot express, and what breaks.
- If you conclude no useful algebra exists at this level of abstraction, say so
  and prove it. That is a legitimate deliverable.

Length: as long as it needs to be, but every claim either proved, cited, or
labelled a conjecture.
