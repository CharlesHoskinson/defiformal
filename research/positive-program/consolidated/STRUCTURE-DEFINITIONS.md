# The Missing Structure — definitions, foundational properties, and alignment with the Quint corpus

Seven schools converged on one demand stated seven ways: *give the elements the
structure they currently lack*. This document discharges that demand. It defines
the structure formally, states its foundational properties, and checks it against
57 typechecked Quint specifications built from protocol source code.

**Status discipline.** Definitions are definitions. Properties marked **[imm]** are
immediate from the definitions. Properties marked **[PO-…]** are proof obligations,
not yet discharged. Empirical claims cite a lane ledger or a spec. Nothing here is
asserted as proved that is not.

---

## Part I — The one object

### 0. Why the seven names are one thing

| School | Its name | What it adds to an element |
|---|---|---|
| Clone theory | arity | an input/output sort profile |
| Category theory | ports & colours | typed wires in and out |
| Type theory | port signature + atomic region | typed wires + the scope they live in |
| Order theory | sorts by group | a sort drawn from `G01–G16` |
| Sheaf theory | live-set into a horizon chain | the scope alone |
| Model theory | `Party` + `Scope` sorts | two new sorts |
| Synthesis | `Mag` interval abstraction | a magnitude sort |

Every one of these is an **annotation on the 58 elements that turns a bare symbol
into a typed operation**. They differ in *which* annotation is emphasised, not in
kind. The union is a single object with four independent components: **sorts**,
**arity**, **scope**, **polarity**. We define it once.

The prior carrier was `2^E` — a protocol is a *set* of symbols. The defect is now
statable in one line: **a set records that a mechanism is present and nothing about
what it consumes, what it produces, when it is live, or whether its output may be
copied.** Every recorded expressiveness failure is an instance of that one defect.

---

### Definition 1 (Sorts / colours)

Let `C` be a finite set of **colours**. A colour is what may flow on a wire between
mechanisms. We fix `C` empirically — from what the 57 Quint specs actually pass
between definitions — rather than by taxonomy:

| colour | written | carries | evidence (lane §5) |
|---|---|---|---|
| Asset | `A` | a fungible quantity of value | `BALANCE_LEDGER` (L6, 6+ protocols) |
| Claim | `K` | a pro-rata or fixed right against a pool | `PRO_RATA_SHARES` (L1), `SHARE_SUPPLY_LEDGER` (L5) |
| Liability | `K*` | an obligation to deliver | `FIRST_LOSS_COVER` (L1), tranche waterfall (L3) |
| Price | `P` | a valuation, with its provenance | `NAV_PRICE_EXCHANGE` (L5), `ADMIN_POSTED_PRICE` (L5) |
| Verdict | `V` | a boolean predicate on state | `COLLATERALIZED_HEALTH` (L1), `isMarginSolvent` (L5) |
| Authority | `U` | a permission to act, held by a party | `RESTRICTED_ADDRESS` (L6), `MINTER_ALLOWANCE` (L6) |
| Capacity | `Q` | a consumable quantitative envelope | `LINEAR_REFILL_RATE_LIMIT` (L6), `RateLimit` (L3, L4) |
| Message | `M` | an attested cross-domain fact | `ATTESTED_MESSAGE_ONCE` (L4) |
| Index | `I` | a monotone accrual accumulator | `INDEX_ACCRUAL` (L1), `AccrualIndex` (L3) |

`|C| = 9`. Clone theory predicted "~8 sorts" from pure algebra before any code was
read; the empirical count is 9. That agreement is the first alignment result and it
was not fitted.

### Definition 2 (Polarity)

A map `λ : C → {lin, cls}` marking each colour **linear** (may be neither
duplicated nor discarded) or **classical** (freely copyable and discardable).

```
λ(A) = λ(K) = λ(K*) = λ(Q) = lin
λ(P) = λ(V) = λ(M) = λ(I) = cls
λ(U) = aff        (affine: may be discarded, not duplicated)
```

The three-way split is forced by the corpus: a price may be read by any number of
consumers (`cls`); an asset may not (`lin`); an authority may be revoked without
being exercised but must not be exercised twice (`aff`).

**The load-bearing content of Definition 2 is a missing rule.** Dereliction
`!A ⊸ A` exists; there is no `A ⊸ !A`. That absence *is* the no-counterfeit law,
stated once for the whole vocabulary instead of once per prohibition row.

### Definition 3 (Arity)

A map `ar : E → C* × C*`, written `ar(e) = (in(e); out(e))`, assigning every one of
the 58 elements a finite sequence of input colours and output colours.

**This is not new fieldwork.** Category theory's observation, verified against
`formal-data.tex:87` (the authoritative source; quoted verbatim):

```
L4 :  Pf  →  (Ex) (Ct) (Li) (Ad|Sl|Bs)
```

is not a clause. It is the statement that `Pf` has **four input ports**, and that
the bracketed alternatives are exactly the elements inhabiting each port's colour.
Reading the 29 rows this way converts them into arity declarations at the cost of
one table pass.

> **Correction (recorded).** An earlier revision of this document transcribed the
> row as three terms, `(Ex)(Ct)(Li|Ad|Sl|Bs)`, conflating `L4`'s subject with
> `L1`'s third term (`L1 : Pl,Im,Cd,Pf,Op → (Ex|Tp|At)(Ct)(Li|Ad|Sl|Bs)`,
> `formal-data.tex:84`). The error deletes the arc `Pf → Li` and understates
> `ar(Pf)` by one port. `formal-data.tex` is authoritative over every derived
> document, and the 15/18 arc reconciliation below holds only under the correct
> four-term reading.

Order theory's independent measurement corroborates: **23 of 24 non-empty
requirement terms already lie inside a single `G01–G16` group**. A term that lies in
one group *is* a colour annotation already written down.

**The 15-vs-18 arc discrepancy is closed, mechanically.** Both counts are correct
readings of the same table: **18** is every singleton requirement term; **15**
excludes the three singletons that sit inside an `[ext]`-marked term — `Tr→Sv`,
`Xf→Xm`, `Up→Tg`. Neither figure is a recount error, and the reconciliation is
arithmetic rather than judgement. Any density statistic must therefore declare
which convention it uses. (Verified by script against `formal-data.tex`; the
reconciliation requires the four-term `L4` above.)

### Definition 4 (Horizon and liveness)

Let `H = (h₀ < h₁ < h₂ < h₃ < h₄)` be the **horizon chain** of settlement scopes:

```
h₀  intra-transaction (atomic)
h₁  intra-block
h₂  epoch / batch
h₃  challenge or dispute window
h₄  governance timelock
```

A map `ℓ : E → 𝒫(H)`, the **live set**, giving the horizons at which an element's
effect is observable. Two elements are **co-live** iff `ℓ(e) ∩ ℓ(e′) ≠ ∅`.

**Foundational reinterpretation.** The existing `stratum : E → {0,…,4}` column is
*read as* `H`. The grading was always there; it was recorded as a taxonomy rank and
never used. Sheaf theory's contribution is the observation that it is a **time**
grading.

### Definition 5 (Party)

A sort `Π` of **party shapes** with a cardinality function, entering only as a
parameter on colours `U` and `K`:

```
Π = { eoa, quorum(n,k), delegate, obligor, none }
```

Existentially encoded: the signature records *that* a holder shape exists, never
*which*. Order theory verified this encoding preserves every structural result —
recording *which* introduces mutual-exclusion clauses `¬quorum ∨ ¬singleKey` that
are purely negative and destroy union-closure.

### Definition 6 (The signature)

A **scoped coloured signature** is
```
Σ = (E, C, λ, ar, H, ℓ, Π)
```
with `E` the 58 elements, and Definitions 1–5 supplying the rest.

### Definition 7 (Construction)

Fix `Σ`. A **construction** is a finite directed wiring `X = (N, w)` where `N` is a
multiset of elements of `E` and `w` is a partial matching of output ports to input
ports, such that:

1. **(Colour)** every matched pair agrees in colour;
2. **(Linearity)** every port of linear colour is matched exactly once; every port
   of affine colour at most once; classical ports without restriction;
3. **(Scope)** every matched pair is co-live: `ℓ(e) ∩ ℓ(e′) ≠ ∅`;
4. **(Closure)** every unmatched input port of linear colour is closed by an
   explicit boundary declaration.

`X` is **complete** when it has no unmatched linear ports at all.

This replaces "a protocol is a subset of `E`" with "a protocol is a well-typed
diagram over `E`". Note that a construction *determines* a subset (its support) but
a subset does not determine a construction — which is precisely the non-faithfulness
model theory identified as the USDT/USD1 collision.

### Definition 8 (Composition)

For constructions `X, Y`, the composite `X ⊗ Y` is the disjoint union of their
wirings followed by matching any output port of one to a compatible free input port
of the other, where **compatible** means: same colour, co-live horizons, and
linearity budget respected.

---

## Part II — Foundational properties

**P1 (Composition is total on its domain).** **[imm]** `⊗` is defined whenever the
colour, liveness and linearity side conditions hold, and its result satisfies them
by construction — the conditions are pointwise on matched pairs and matching only
adds pairs already checked. *Closure is definitional, not measured.* This is the
whole point of the change of carrier: the prior work had to test 1,830 pairs and
found 185 failures; here the failures are not compositions at all, they are
ill-typed matchings rejected before composition.

**P2 (Conservation).** **[imm from Def. 2]** In a complete construction, for every
linear colour `c`, the multiset of `c`-outputs equals the multiset of `c`-inputs.
No value is created or destroyed except at declared boundaries.

*This is exactly Uniswap v4's deferred net settlement.* L1 modelled it as
`deltasNetZero` and recorded that `Fl` is the wrong symbol: "nothing is borrowed
here — pure conservation law over a transaction scope". The property that the prior
carrier could not state is the definition here.

**P3 (Scope non-interference).** **[imm]** If `ℓ(e) ∩ ℓ(e′) = ∅` then `e` and `e′`
are never matched, and no constraint may relate them. **Corollary:** every
co-presence prohibition whose arms are not co-live is unstatable — not false,
*unstatable*. `X21` is such a row.

**P4 (Filtration).** **[PO-ORD-9 / PO-SYN-E]** With the single repair `σ(Gs) := 4`,
`σ` is a filtration `E₀ ⊆ … ⊆ E₄` with `Cn(E_k) ⊆ E_k`, licensing induction on
stratum. Two schools independently verified exactly one violating arc, `Gs(3)→Au(4)`,
by different methods (order theory over 18 arcs, synthesis over 68). **One table
cell.**

**P5 (Vacuous discharge).** **[imm]** An obligation whose type is uninhabited under
`Σ` is discharged by a refutation `T ⊸ 0`, on the same footing as a witness. A venue
escrowing maximum payoff at trade time closes its `K*` port at trade time, so the
loss-absorption term is *discharged*, not left open. The Lean lemma already exists
(`lean/Defialgebra/Discharge.lean`, `voidReq`).

**P6 (Separation).** **[PO-MOD-2]** Constructions distinguish protocols that subsets
do not, because wiring is retained. Necessary for completeness clause (C2); currently
false, and the reason `P` is complete for no reference class today.

**P7 (Synthesis tractability).** **[PO-SYN-7]** Construction from a specification is
a CSP whose primal graph has measured treewidth `5 ≤ tw ≤ 8` on the present tables,
with bucket elimination at `2⁹·9·93 ≈ 4×10⁵` operations. The open risk is that
filling the 15 `[ext]` rows raises the width; synthesis budgets `tw ≤ 12` and
measures ~4 units of headroom per row filled.

---

## Part III — Alignment with the Quint corpus

**Method.** Six lanes modelled 60 applications across 12 categories from protocol
source, producing **57 specifications, all typechecking**, and six structured
ledgers. The question: *does the empirical evidence support this structure, and do
construction and composition go through?*

### III.1 The primitives the code actually shows

Independently recurring across lanes, with the number of lanes that found them:

| empirical primitive | lanes | proposed arity under `Σ` |
|---|---|---|
| Pro-rata share ledger | **6/6** | `(A) → (K)`, `(K) → (A)` |
| Deferred claim / two-phase request | **5/6** | `(K) → (K@h₂)`, epoch-gated |
| Rate-limit / flow envelope | **5/6** | `(Q, A) → (A, Q)` — consumes capacity |
| Conservation / supply invariant | **4/6** | boundary condition on `A`, `K` |
| Index accrual | 3/6 | `(I, P) → (I)`, monotone |
| Health / margin predicate | 4/6 | `(K, K*, P) → (V)` |
| Valuation source | 4/6 | `() → (P)` with provenance grade |
| Payoff function | 2/6 | `(P) → (A)` |

Eight families. Clone theory's prior prediction: "~8 sorts". The families are not
the sorts, but the coincidence of scale is real and the arities above type-check by
hand against the lane definitions.

### III.2 The single strongest empirical finding

**`LINEAR_REFILL_RATE_LIMIT` — `current = min(cap, remaining + slope·Δt)`.**

Found by **five of six lanes** in **five different categories**: L2 (ether.fi, Lido
exit budget), L3 (Spark `RateLimits.sol`), L4 (Coinbase `MintForwarder`), L6 (USDG,
PYUSD, Grove — *"identical elapsed-time refill; strongest cross-category recurrence
in this lane"*). L6 found the same arithmetic in two unrelated repositories.

**The 58-symbol vocabulary has no symbol for it.** Every lane independently recorded
that `Ep` (epochs), `Gp` (pause) and `Au` (delegated scope) all fail to name it.

Under `Σ` it is exactly the colour `Q`: a **linear** resource replenished by a
horizon-indexed law. It cannot be expressed in a carrier without linear colours,
which is why five lanes found it and no symbol exists. *This is the clearest
vindication of Definition 2 in the corpus, and it was found bottom-up from code.*

### III.3 Third independent confirmation of the scope finding

L1 modelled Uniswap v4 `PoolManager.unlock` and PancakeSwap `SettlementGuard` and
recorded, unprompted, in its "mechanisms with no symbol" table:

> "`Fl` is borrow-repay; here nothing is borrowed — pure conservation law over a
> transaction scope."

This is a **third** independent route to the same conclusion, now from source code:

| method | route | result |
|---|---|---|
| Type theory | paper's own failure triage | ≥79% of failures are scope artifacts |
| Sheaf theory | recomputation under scoped semantics | 119 → 21 failing pairs, **82.4%** |
| Quint lane L1 | reading Uniswap v4 / PancakeSwap source | `Fl` is the wrong symbol; it is scope + conservation |

Definitions 4 and P3 are the structure that makes all three statements the same
statement.

### III.4 Does composition go through?

**Yes, on the evidence available, and the failure mode changes character.**

L1–L6 §8 record the real composition surface between protocols — where one
protocol's state is another's input. Under `Σ` these are port matchings, and each
carries a colour and a horizon. The prior work's flagship counterexample —
Uniswap ∪ Aave covering `X2` — is, under `Σ`, an attempted match between `Fl`'s
`A@h₀` port and a lending `A@h₃` port. **Not co-live, therefore not a composition.**

What survives is `X2` at common horizon `h₀` — a genuine same-transaction
coincidence, and, as sheaf theory notes, precisely the one row whose statement
carries a magnitude. That is the residue: **one triangle,
`{Fl@h₀, {Cp,Cl}, {Pl,Cd}}`**, which is the entire non-acyclic part of the corpus
under GYO reduction.

So composition is not "preserved" — it is **total by construction**, and the former
failures are re-classified into two disjoint kinds: ill-typed matchings (~80%,
dissolved) and one genuine magnitude-dependent hazard (~20%, requiring `Mag`).

### III.5 Does construction go through?

**Yes, with one measured caveat.** Synthesis measured the CSP directly on
`formal/v2/tables.mjs` and the 60 obligation ledgers: 35 non-isolated vertices, 88
edges, max clique 6 so `tw ≥ 5`, min-fill order of width 8 so `tw ≤ 8`, and adding
any one of the 60 applications' ledgers leaves the upper bound at 8 — **for all 60**.
Bucket elimination at ~4×10⁵ operations yields satisfiability, minimum-cardinality,
counting and polynomial-delay enumeration in one pass.

`454 of 570` non-empty obligation terms are singletons and max arity is 5, so
Grohe's theorem applies and treewidth is *the* parameter.

**The caveat is honest and named**: filling the 15 `[ext]` rows could raise the
width, since a 5-term row can add a 6-clique. Budget `tw ≤ 12`; headroom ~4 units
per row. This is `PO-SYN-7` and it is the one genuine risk in the construction half.

---

## Part IV — What is now required

### IV.1 The three tables to write

1. **`ar` — the arity table.** 58 rows × (input colours; output colours). Seed from
   the 29 requirement rows, which already encode it. Half a day.
2. **`ℓ` — the live-set table.** 58 rows × subset of `H`. Sheaf theory requires this
   be assigned **blind** — from each element's definition alone, without seeing any
   protocol or prohibition row — so the dissolution result is a prediction and not a
   fit. One afternoon.
3. **`λ`, `Π`.** One column each.

### IV.2 The open design decision

**Ports vs scope primacy.** Sheaf theory: *"do not buy ported interfaces yet — with
`ℓ` in place, the nerve overlaps **are** the ports."* Category and type theory: ports
first, scope as an annotation on them. Definitions 3 and 4 above are deliberately
**independent**, so the decision is empirical: build both tables, and measure which
explains more of `D` and more of the failure dissolution. Tests T3 and T6 are
exactly this comparison and both are afternoon-scale.

### IV.3 Proof obligations opened by these definitions

- **PO-STR-1.** `⊗` is associative and unital up to wiring isomorphism — i.e. `Σ`
  presents a coloured symmetric operad. (Required for P1 to mean what it says.)
- **PO-STR-2.** Every one of the 60 corpus applications admits a complete
  construction over `Σ`. This is completeness clause (C1) and it is *checkable*,
  since 57 typechecked Quint specs already give the state machines.
- **PO-STR-3.** The support map `supp : Constructions → 2^E` is not injective, and
  its fibres separate the four known collision classes. (C2.)
- **PO-STR-4.** No element is implicitly definable from the rest under `Σ` (Beth
  independence, C3), decidable on the corpus by T5.
- **PO-STR-5.** Enrichment from the flat carrier to `Σ` is conservative: no verdict
  reachable before becomes unreachable. (C4.)
- **PO-STR-6.** The eight empirical primitive families of §III.1 generate, under
  `⊗`, every construction exhibited in the 57 Quint specs. *This is the completeness
  theorem in its testable form and it is the single most valuable next computation.*

### IV.4 The verdict asked for

> *Are construction and composition possible given these structures?*

**Composition: yes, by construction** (P1), with ~80% of recorded failures
re-classified as ill-typed rather than as failures, confirmed by three independent
methods, and a named residue of one triangle requiring magnitudes.

**Construction: yes, tractably**, with measured treewidth `5 ≤ tw ≤ 8` and a DP at
~4×10⁵ operations, subject to one named width risk on completing the tables.

**Completeness: not yet — and now for the first time it is a well-posed question.**
It has four clauses (C1 coverage, C2 separation, C3 independence, C4 conservativity);
C2 is *false today* and becomes true with `Π`; and PO-STR-6 states the generation
theorem in a form the existing 57 specs can test within days.
