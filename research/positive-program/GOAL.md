# THE GOAL — read this before doing anything

**Write a paper that exhibits a finite set of primitive mechanisms and proves that
every useful DeFi application can be built from them.**

Functional completeness for DeFi, in the sense Post proved it for Boolean
connectives: a small basis, plus an argument that nothing outside it is needed.

Three claims, in strict priority order:

1. **COMPLETENESS** — here is the basis `P`; every useful DeFi protocol is
   constructible from it. The 60 applications across 12 categories are the
   evidence that `P` spans the field. **This is the paper.**
2. **COMPOSITION** — constructions compose into constructions.
3. **CONSTRUCTION** — given a specification of what an application must do,
   build one and check it.

The paper says: *here are the elements of DeFi, here is why they are complete,
here is how they combine.* Nothing else.

> ## STATUS 2026-08-05 (pass 6) — GATE 2.1 OPEN, PILOT RE-SPEC IN FLIGHT
>
> **Basis.** The eight-family basis is refuted: `basis/generate.py` gives 743 of
> 820 definitions generated, **10 specs ungenerated**, and `basis/families.py`
> gives 57 of 183 lane primitives outside the basis entirely. `F4` is a law not
> an operation (three independent arguments). `F1` is the permutation-symmetric
> instance of an allocation rule `F9`. Current estimate: a 4-primitive substrate
> plus ~16 families — but `|P| = 4` is **UNSUPPORTED**, because the `Q`/`Σ`
> invariant it rests on failed to reproduce under three operationalisations
> (`sigma/qsigma{,2,3}.py`).
>
> **The crux is settled.** Every fold in all 57 specs is `fold(0, (acc,x) =>
> acc + …)` — a commutative sum. Zero extremal selections corpus-wide. `⋈` does
> not need to generate order-dependent operations because the specs never
> contained any. Cause found: Quint forbids loops and mutable locals
> (`quint-lang/guidelines/constraints.md` §4, §5), and **`fold` over a `Set` is
> order-independent**, so extremal selection requires an explicitly maintained
> sorted `List` walked by `indices()`.
>
> **Consequence.** The 743/820 figure was measured against a corpus with the
> difficulty pre-removed. True incompleteness is worse; that number is a floor.
>
> **All ten deletions are now identified with line numbers** — see
> `phase2/P2-SCOPE.md`. Worst: `morpho_blue.qnt:156` carries a comment naming
> bad-debt socialisation above three identity assignments, so its headline
> invariant survives only because the mechanism that stresses it was deleted.
>
> **Fidelity is a quotient, not a refinement.** No refinement relation in any
> direction separates the two failure modes: an over-approximating spec is
> refined by everything, and a transliteration is bisimilar to the contract.
> Faithful = coarsest system still equivalent on the declared observables
> (`phase2/P2-FIDELITY.md`).
>
> **Pass 4 update — every Phase 2 preliminary is green; gate 2.1 is unblocked.**
> The kernel is built and independently verified: `phase2/kernel/` 9/9 typecheck.
> The inexpressibility claim ("unrolled for quint purity without loops") is
> **false on all three counts**. Extremal selection is not merely expressible
> but *cheaper*: zero extra reachable states (machine-checked by a
> `listIsCanonical` invariant), ~1.6x wall clock, flat from 3 to 24 troves,
> branching drops, and Apalache proved the 7-part mechanism invariant to depth 3.
> `isqrt` is exact on `0 <= n < 2^62`. Fixed-depth Newton was measured and
> rejected.
>
> Five hard constraints now bind every re-spec (see ROADMAP gate 2.0d): i64
> backend overflow; Newton needs a `done` flag or it silently deletes the
> contract's break, at depth K=8; convergence obligations must not sit in a
> precondition; history-based regression guards are unsound; and Curve's integer
> Newton genuinely fails to converge on 2.8% of a 1372-point grid.
>
>
> **Pass 5 — the plan review failed and gate 2.1 is BLOCKED again.**
> `phase2/P2-REVIEW.md`: the plan's guards cover the ordering class of deletion
> well and the arithmetic and missing-state classes barely at all. Five repairs
> required.
>
> **The fourth trap was inside the plan.** `P2-FIDELITY` F3 (parsimony)
> instructed the worker to collapse any distinction the mutant suite did not
> need and iterate to a fixed point. The worker also authors the mutant suite,
> so a thin suite licensed deleting almost anything — and it made the generation
> measurement circular, the corpus becoming a function of the ten contrast sets.
> Same shape as the other three traps, except mandated. **Repaired**: F3 is now
> reporting-only, and deletion additionally requires the contract-facing
> droppability test.
>
> **The acceptance test was cheatable for eight of ten** — it checks the shape
> of a definition, never its value. Repair: exact conformance vectors read off
> the contract.
>
> **The `nondet` convention catches 3 of 10** and is silent on every arithmetic
> and missing-state deletion.
>
> Repairs 1 and 4 are applied. Repairs 2, 3 and 5 are in flight as the repaired
> execution contract.
>
> **Guard strengthened:** `respec_lint.py` D3 now matches trailing comments, the
> form of the confirmed `apex.qnt:145` defect. D3 findings went 2 -> 7; baseline
> is now **185 findings / 57 specs**.
>
> **apex has six deletions, not three** — all confirmed against source, and it
> was the one protocol nobody had independently checked.
>
> **Pass 6 — all Phase 2 preliminaries closed; writing has started.**
> Gate 2.0f CLOSED. The pilot re-spec of `uniswap_v2` is in flight into
> `quint-models-v2/`, seeded with the verified `sqrt.qnt` and `sorted.qnt`.
>
> Two corrections landed, one of them to my own work. The Curve domain
> recommendation of `10^5..10^7` was justified against the **product of the
> balances**; the binding quantity is the peak Newton intermediate, which is
> cubic at extreme imbalance and reaches `5.0e20` at `(10^7, 1)` — overflowing
> i64. Corrected cap `10^6` (peak `5.0e17`, 18x headroom, witness still hosted).
>
> And the old range cap of 200 did not merely degrade the corpus. Applying the
> new constant-crossing rule retroactively, **six of the ten protocols were dead
> under it** — `uniswap_v2` and `apex` (`MINIMUM_LIQUIDITY = 1000`), `gmx`
> (`FLOAT_PRECISION`), `liquity` (`MIN_DEBT = 2000`), `morpho_blue`
> (`VIRTUAL_SHARES = 10^6`), `derive` (spot `10^4`).
>
> Convention 6g (dependency parity) closed the last uncovered deletion and
> independently re-caught four already covered by different rules — evidence it
> is the right generalisation rather than another patch.
>
> **Still unsupported:** `|P| = 4` and the six sorts. Gate 0.1 remains FAILED.



---

## The basis, as it now stands

The 58-symbol vocabulary is **not** the basis. It was named over the protocols,
not derived from them: across 57 typechecked Quint specifications built from
protocol source, only **6 of the 58 symbols** appear at all (`Ba, Cp, Fz, Gp, Ix,
Sh`). Two independent readings of the same 60 protocols overlap on six symbols.

What *did* come out of the code, bottom-up and independently across lanes, is
eight families. These are the basis candidate:

| # | family | lanes | signature (proposed) |
|---|---|---|---|
| F1 | Pro-rata share ledger | 6/6 | `(A) → (K)`, `(K) → (A)` |
| F2 | Deferred claim / two-phase request | 5/6 | `(K) → (K@later)` |
| F3 | Rate-limit / flow envelope | 3/6 | `(Q, A) → (A, Q)` |
| F4 | Conservation law | 6/6 | boundary condition on `A`, `K` |
| F5 | Health / margin predicate | 4/6 | `(K, K*, P) → (V)` |
| F6 | Valuation source | 4/6 | `() → (P)` |
| F7 | Index accrual | 3/6 | `(I, P) → (I)`, monotone |
| F8 | Payoff function | 2/6 | `(P) → (A)` |

Evidence lives in `research/positive-program/insights/INSIGHT-L*.md` §5, and the
specs in `quint-models/L*/`.

### Counts are now scripted, and two were wrong

Recomputed by `sigma/count_families.py` over the six ledger section-5 tables
(52 candidate-primitive rows total). Corrections to the hand tabulation:
**F3 is 3/6, not 5/6** (the extra sightings were in section 7, a different table);
**F4 is 6/6, not 4/6**.

### The basis is incomplete: 12 of 52 rows match no family

These recorded candidate primitives are not generated by any of F1-F8 and are the
first place to look for missing basis elements:

`CONSTANT_PRODUCT_SWAP` (L1), `UTILIZATION_TWO_SLOPE` (L1), custody-free
delegation state machine (L2), tranche waterfall (L3), permanent one-way lock
(L3), `ATTESTED_MESSAGE_ONCE` (L4), `OPTIMISTIC_FILL` (L4),
`SIGNED_ORDER_REMAINING` (L4), `DELEGATED_INTENT_STATUS` (L4), `ESCROW_BALANCE`
(L4), `RESTRICTED_ADDRESS` (L6), `MINTER_ALLOWANCE` (L6).

**The most glaring omission is the pricing curve.** `CONSTANT_PRODUCT_SWAP` is
instantiated by six protocols in L1 alone and is arguably the most iconic
mechanism in DeFi; it is absent from the eight families. Any basis that cannot
build an AMM is not a basis for DeFi. Treat F1-F8 as a floor, not the answer.

---

## The theorem to prove

> **Generation.** Every one of the 60 corpus applications lies in the closure of
> `P` under composition.

With three conditions that stop it being trivially true:

- **Non-degeneracy.** The basis must not admit the trivial reading under which
  everything is generated. (A basis of one universal element "generates"
  everything and says nothing — Post's `P = {⊤}` problem.)
- **Independence.** No family is generated by the others. If `F7` is definable
  from `F1` and `F6`, it is not a primitive and must be dropped.
- **Refutability.** There must be a statable object whose exhibition refutes
  completeness — a DeFi application not generated by `P`.

A completeness claim with no refutation condition is not a theorem.

---

## Banned

- Methodology work. Blinding protocols, inter-rater statistics, permutation
  nulls, p-values. If a quantity needs a significance test, we are not doing
  mathematics — find the exact question instead.
- Re-auditing the prior paper. Its results are inputs at most.
- Any enrichment of the carrier (party sorts, magnitudes, horizons, scopes)
  **unless** it is required to state or prove the generation theorem. Enrichments
  are downstream of having a basis.
- New corpora, new protocols, new tooling.

If a task does not directly serve "the eight families generate the 60", it is a
side goal. Kill it.
