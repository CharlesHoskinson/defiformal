# BRIEF: The DeFi Primitives Positive Program

You are a mathematician engaged to write **requirements on a mathematical structure**.
You are not writing a paper. You are not evaluating feasibility. You are specifying
what the structure must satisfy so that a stated goal is achievable, and you are
doing it from your own school's first principles.

---

## 0. THE IRON RULE

We are solving three problems, positively:

1. **COMPLETENESS.** There is a finite set of primitives `P` such that every
   useful DeFi application is constructible from `P`. We intend to argue this is
   *functional completeness*: all useful DeFi can be built from `P`.
2. **COMPOSITION.** Composing constructions yields a construction. The class of
   things we build is closed under the composition operator, by construction of
   the carrier rather than by accident.
3. **CONSTRUCTION.** Given a specification of what an application must do, we can
   *build* a construction discharging it, and verify that we did.

The evidence base is a corpus of **60 deployed DeFi applications across 12
categories** (the top members by capital or volume). Success means: the 60 are
constructible from `P`, and we can say precisely in what sense `P` is complete.

**You may not produce a negative result.** Impossibility theorems, no-go results,
obstruction-only findings, and "this cannot be done" conclusions are out of scope.
That work has already been done and it produced a useless paper. If your school's
machinery yields an obstruction, your job is to state **what must change about the
carrier, the signature, or the notion of composition so the obstruction does not
arise**. An obstruction is an input to a requirement, never an output.

This is not a request to be dishonest. It is a change of question. The prior work
asked a **preservation** question ("is admissibility preserved under composition?")
and preservation questions over a flat carrier answer negatively almost by
construction. We are asking a **generation** question ("is every application in the
closure of the primitives?"). These are dual — Pol vs Inv in the Galois connection —
and the generation side is where positive answers live. Stay on the generation side.

---

## 1. WHAT WAS TRIED, AND WHY IT WENT NEGATIVE

A prior effort ("An algebra of mechanism composition") modelled a protocol as a
finite subset `X ⊆ E` of a 58-element vocabulary of mechanisms, constrained by:

- **Requirements** `(s,T)`: `s ∈ X ⟹ every term T_j meets X`. Clause form
  `¬s ∨ ⋁_{e∈T_j} e` — one negative literal, **dual-Horn**, union-closed.
- **Prohibitions** `H ⊆ E`: `H ⊄ X`. Clause form `⋁_{e∈H} ¬e` — purely negative,
  **Horn**, intersection-closed.
- **Warrants** `(e,C)`: `e ∈ X ⟹ C ∩ X ≠ ∅` ("what `e` is for"; an element with
  no consumer is unwarranted). Also dual-Horn.

Admissible = satisfies requirements and warrants, arms no prohibition.

Its results, in brief:

- The positive part (models of requirements + warrants) is a **complete lattice**
  under union. Proved from clause polarity alone.
- Prohibitions are Horn, Horn classes are not union-closed, so **admissibility is
  not preserved by composition**. Counterexample: Uniswap ∪ Aave v3 covers the
  prohibition X2 that neither covers alone.
- On the **definite fragment** (requirements with a single consequent), the closure
  `Cn` is reachability in an acyclic digraph `D`, hence a **convex geometry**;
  every closed set has a **unique minimal generator** `ex(A)`; and
  `ex(A ⊕ B) = max_≼(ex(A) ∪ ex(B))` in `O(|ex(A)|+|ex(B)|)` word operations.
- Composition safety = **clique** in a compatibility graph; largest safe family =
  maximum clique. Conjectured perfect on a sub-predicate; untested.
- Two "obstructions": the diagonal of admissibility is not reachable from a
  componentwise product by a stated family of bilattice operations; and a
  consistent inflationary/deflationary bounding pair forces both maps to be the
  identity.
- Bottom-up reasoning over the powerset **collapses** for any operator with the
  right fixpoints: the Kripke–Kleene fixpoint is `(⊥,⊤)`, carrying no information.

And its two damaging measurements:

- **The positive theory does not bind.** Of 93 clauses encoding admissibility, the
  79 positive ones (closure, warrant, grounding) **exclude zero elements across all
  72 seeds**. Median fraction of candidates excluded: 0.0%. All 61 exclusions
  come from two hand-written prohibitions.
- **Structure and content are in tension.** Replacing the fitted consumer table by
  the true order-theoretic residual restores invariance and gives a lattice by
  Tarski — but the repaired operator then fixes only 13 of 72 real protocols vs
  25 of 84 synthetic corruptions, i.e. it is **anti-correlated with reality**.

Coverage of the 60 applications was **45.3%** permissive, **29.0%** strict.
689 of 1,259 recorded obligations are discharged by no element at all.

---

## 2. THE CRITICAL FINDING: THE NEGATIVE RESULTS MEASURE AN UNFINISHED TABLE

A knowledge graph was built over the paper (680 nodes, 1,909 edges, 95% of edges
EXTRACTED rather than inferred). Reading the authoritative constraint tables
through the graph establishes the following, and **this is the single most
important input to your work**:

**The requirement table is almost entirely unformalized.** Of the 29 recorded
requirement rows:

- **15 rows are FULLY unformalized** — every term is written `[ext] ()`, an empty
  term marked "external / natural language" that names no element whatsoever:
  L9, L10, L11, L12, L13, L16, L17, L18, L22, L24, L25, L26, L27, L28, L29.
  The largest offenders: L27 (5 of 5 terms empty), L12/L17/L28 (4 of 4),
  L11/L18/L22/L25/L26 (3 of 3).
- **7 rows are partially unformalized**: L2 (1 of 2 terms empty), L3 (1 of 4),
  L6 (3 of 4), L19 (1 of 4), L20 (4 of 5), L21 (2 of 3), L23 (1 of 2).
- **Only L1, L4 and L5 contain no `[ext]` term at all.** Three rows out of 29.
- **4 rows have a blank subject column** (L14, L23, L25, L26) — they are triggered
  by no named element and therefore fire on nothing.

**The prohibition table is half prose.** Of the 20 listed prohibition rows,
**9 name no element symbol at all** (X3, X5, X6, X7, X8, X12, X14, X16, X17) —
they are English sentences. Only **one row (X2) is a positive element set** and
therefore enforceable by membership.

**And the decisive one:** the clause **X21 — which the paper's own measurement
credits with 147 of the 185 composition failures, i.e. 79% of every failure
observed — does not appear anywhere in the table of 20 listed prohibition rows.**
Its forbidden configuration is stated nowhere in the reproduced tables.

The consequences for your brief:

1. "The positive theory excludes nothing" is **not a discovery about DeFi**. It is
   an arithmetic consequence of 15 of 29 requirement rows being empty and 4 more
   firing on no subject. A theory made of empty clauses excludes nothing; this is
   a tautology, not a finding.
2. "Composition fails" rests on a prohibition table of which one row is machine-
   checkable and the dominant row is unpublished.
3. Therefore **the obstructions are not known to be intrinsic**. They have never
   been tested against a fully formalized constraint system. No result in the
   prior work rules out the positive program. Treat the prior obstructions as
   *facts about a particular unfinished encoding*, not as facts about DeFi.

Do not repeat that mistake. Any structure you specify must come with a
**formalization discipline**: a statement of what it means for a row to be
complete, and a refusal to count prose as a constraint.

---

## 3. THE ASSET YOU ARE BUILDING ON: THE VOCABULARY IS ALREADY GRADED

This is the strongest positive lead in the corpus and the prior work never used it
algebraically. Each of the 58 elements carries **a group `G01..G16`** (a kind) and
**a stratum `0..4`** (a level). The strata:

- **Stratum 0** — `Sh` pro-rata share accounting, `Ix` index-based accrual,
  `Rb` rebasing accounting. (Group G01: accounting.)
- **Stratum 1** — `Cp` constant-product invariant, `Wg` weighted-geometric
  invariant, `St` stable-hybrid invariant, `Cl` concentrated liquidity,
  `Pm` oracle-priced inventory curve (G02: pool pricing); `Ob` on-chain order
  book, `Rf` request for quote (G03: execution); `Ag` aggregation & routing,
  `Fl` atomic flash liquidity (G04: liquidity catalysis).
- **Stratum 2** — `Ba` batch-auction clearing (G03); `Ex` external data oracle,
  `Tp` time-weighted price, `Oa` optimistic assertion oracle, `At` reserve/NAV
  attestation (G08: truth); `Sr` streaming accrual, `Ep` epoch-gated transition,
  `Wq` withdrawal queue (G09: time); `Em` protocol-funded emissions, `Fd` surplus
  & fee distribution (G10: incentive); `Aw` permission/identity gate,
  `Sb` shielded-balance state, `Sd` selective-disclosure proof, `Fz` freeze /
  forced transfer (G14: access).
- **Stratum 3** — `Pl` pooled lending, `Im` isolated lending market,
  `Cd` collateralized-debt minting, `Uc` undercollateralized credit,
  `Ft` fixed-term debt (G05: credit); `Ct` collateral-threshold test,
  `Li` incentivized liquidation, `Ad` auto-deleveraging, `Sl` socialized-loss
  allocation, `Bs` staked backstop (G06: solvency); `Pf` perpetual funding
  transfer, `Op` option payoff, `Tr` tranche waterfall, `Cv` mutual cover pool,
  `Py` principal/yield separation, `Sv` servicing & determination discretion,
  `Dp` directional position & hedge maintenance (G07: risk transfer);
  `Gs` sponsored-fee liability (G11); `Rd` direct redemption right, `Ps` peg-swap
  module, `As` algorithmic supply adjustment (G13: stability); `Vl` staking &
  validator lifecycle (G16).
- **Stratum 4** — `In` intent & solver execution (G03); `Tg` delayed-governance
  execution, `Up` mutable implementation proxy, `Gp` guardian or pause,
  `Au` delegated execution scope (G11: control); `Xm` cross-domain message
  verification, `Xf` cross-domain asset transfer, `Rl` resource lock/reservation,
  `Of` optimistic fill & reimbursement (G12: cross-domain); `Rs` restaking /
  shared security (G15).

Observations you should weigh:

- The definite requirement digraph `D` has only **15 arcs on 58 vertices** and is
  acyclic. The convex geometry is real but *thin* — most elements are their own
  canonical form. The prior work concedes its structure result "is also thin, and
  its thinness is the same fact as the vacuity of the positive theory."
- The prior work found `Ct` (collateral-threshold test) is **a consequence in every
  protocol that has it and a primitive in none** — evidence that a genuine
  derivation order exists and has been partially captured.
- Six independent order-book perpetuals venues have canonical forms omitting
  **exactly** `{Ct, Ex, Li}`, while the one oracle-priced pool venue omits none.
  Independent implementations agreeing to the symbol is evidence the derivation
  relation is real rather than fitted.
- 4 of the 58 elements are used by no protocol in the corpus (`Wg`, `Cv`, `Sb`,
  `Sd`), and 2 are carried by more than two-thirds of it (`Up`, `Gp`) — and both
  of those are control-plane rather than financial.

**A grading is a gift.** Graded/filtered structures, generation by degree,
induction on stratum, and free constructions over a graded signature are all
available and were never used. Consider whether stratum is a genuine grading
(does composition add strata? is there a degree function?), whether group is a
sorting (a many-sorted signature, or the colours of a coloured operad), and what
the 15 arcs of `D` are the shadow of.

---

## 4. WHAT THE MODEL PROVABLY COULD NOT SAY

These are the recorded failures of *expressiveness*. Each is a requirement on your
carrier — the structure you specify must be able to state these, or must say
explicitly and with reasons that it declines to.

- **No party sort.** 135 of 385 classified residue obligations (35.1%) turn on
  naming *who* holds an authority and *how many* of them there are: an externally
  owned account, a quorum, a delegated agent, an obligor. No protocol, custodian
  or obligor can be named. Two protocols with identical element sets and
  materially different solvency cannot be separated (USDT vs USD1 collide
  exactly, and the collision survives canonical forms).
- **No magnitudes.** The model records *whether*, never *how much*. Every
  prohibition that depends on a threshold ("manipulation cost < position value",
  "value at risk exceeds the bridge's economic security", "securing value
  exceeding slashable stake") is therefore prose. This is why 9 of 20 prohibition
  rows name no element.
- **No rate / price of credit.** No element anywhere names an interest rate. The
  utilisation curve that every lending market runs — and competes on — has no
  symbol. Reached independently by the lending lane and the CDP-stablecoin lane.
- **No level above the protocol.** A curator allocating across venues, an
  aggregator routing to aggregators, a strategy expressed over *other protocols'*
  mechanisms. Yield vaults collapse to two claim symbols plus control-plane
  furniture because of this.
- **No conservation laws.** Deferred net settlement (Uniswap v4) requires that
  accumulated deltas cancel at release — a conservation law over a transaction.
  No symbol states it.
- **No ports / typed interfaces.** The prior work explicitly identifies this as
  why interface automata and assume-guarantee contract algebra "do not transfer
  wholesale": its protocols have no ports, and composition is set union followed
  by closure. Half the operations of a contract algebra depend on ported objects.
- **No "obligation cannot arise".** The requirement language admits exactly one
  way to discharge a term — name an element that satisfies it — so a venue that
  escrows the maximum payoff at trade time (and therefore *cannot* have a margin
  call) is scored as leaving the term open. The rejection is correct about the
  table and wrong about the protocol.
- **Over-collapsed symbols.** One symbol asserts sameness the code refutes:
  `Vl` covers at least five separable mechanisms in one protocol and names
  non-validators in two others; `Op` collapses at least six risk-material
  distinctions (exercise style, cash vs physical settlement, P2P vs peer-to-pool
  underwriting, upfront vs streamed premium, isolated vs portfolio margin,
  model- vs book-priced); `Xf`/`Xm` are too coarse by roughly a factor of four.

---

## 5. YOUR TASK

Write the **requirements on the mathematical structure** that your school demands,
so that completeness, composition and construction are all achievable over this
subject matter. Reason from first principles. Use the facts above as data, not as
conclusions.

Concretely, answer these, in your own idiom:

1. **Carrier.** What is a protocol, in your structure? (Not "a subset of E" unless
   you can defend it.) What are the objects, and what is the ambient category /
   algebra / theory? State the signature and its sorts.
2. **Composition.** What is the composition operator, and what makes it **total**
   and **closed** — by construction, not by measurement? If composition must be
   partial, what is the exact side condition, and what structure does the partial
   operation carry?
3. **Completeness.** State the completeness theorem you would aim to prove, as a
   formal statement. What is the precise sense of "functionally complete"? What
   would falsify it? What is the analogue of Post's maximal clones — i.e. what are
   the ways a candidate primitive set could *fail* to be complete, and how do we
   check we escape all of them?
4. **Construction.** What is the synthesis problem, formally? What structure makes
   it decidable, and at what complexity? What is the certificate that a
   construction discharges a specification?
5. **What the prior obstructions become.** For each of the prior work's negative
   results that touches your area, say what happens to it in your structure — it
   should dissolve, be localized to a degenerate fragment, or be converted into a
   computable invariant. Say which, and why.
6. **Minimal viable structure.** If we can only afford *one* enrichment of the
   carrier this quarter, which one, and what does it buy? Rank your requirements
   by (structural payoff) / (formalization cost).
7. **Falsifiable near-term test.** Name one computation over the existing 60-
   application corpus that would confirm or refute your proposed structure within
   days, not months. Be specific about the input, the procedure and the verdict
   condition.

### Constraints on your answer

- **Be a mathematician, not a reviewer.** Specify structure; do not audit the old
  paper. You may cite its facts; do not grade it.
- **No hedging.** Do not write "it may be possible that". State requirements.
  Where you are uncertain, state the uncertainty **as a proof obligation with a
  name**, not as a qualification of your claim.
- **Name real mathematics.** Cite actual theorems, structures and literature by
  name (author, result). Made-up machinery is worthless here. If the theorem you
  need does not exist, say precisely what it would say and call it a conjecture
  with a name.
- **Respect the empirical constraint.** Whatever you specify must accommodate a
  vocabulary that is dirty, graded, partially unformalized, and drawn from
  practice. A structure that requires a clean signature is modelling a different
  object and will fail exactly as the prior work did.
- Target **1,200–2,000 words**. Dense and specific beats long and general.

### Output

Write your answer to the exact absolute path given at the end of your instructions
using the Write tool. Use this skeleton:

```markdown
# Requirements from <your school>
## 0. Position in one paragraph
## 1. Carrier and signature
## 2. Composition
## 3. Completeness theorem (formal statement)
## 4. Construction / synthesis
## 5. Disposition of the prior obstructions
## 6. Minimal viable enrichment (ranked)
## 7. Falsifiable near-term test
## 8. Named proof obligations
```

End with a short `## 8. Named proof obligations` list: each a one-line formal
statement with a handle (e.g. `PO-CAT-1: ...`) that a later worker could discharge.
