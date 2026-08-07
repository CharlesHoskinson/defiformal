# Gate 0.2 — extremal prefix vs sum-local filter class

**Status: CLOSED (formal claim below), 2026-08-07 — reworked after Sol REVISE**

## Precise claim (what Lean proves)

In `lean/Defialgebra/Extremal.lean`:

1. **`extremalFill`** — general definition: `insertionSort` by priority-then-id,
   then demand-bounded prefix with partial last fill (`takeDemand`).
2. **`SumLocalProg`** — grammar of sum-local filter programs: atomic
   `phi : Claim → SumAgg → Bool` and `and`. Evaluation is always a single `phi`.
3. **Closure:** conjunction stays inside the class (`eval_and`, `localSel_and`).
4. **Separation:** `f9_irreducible_to_sum_local` /
   `extremal_not_sumLocalProg` — no program matches extremal fill ids on both
   two-claim unit-demand witnesses (same local view of claim A accepted then rejected).

`SumAgg = (totalSize, count, demand)` is the **fixed observation interface** of
the formal class (not “every possible sum of claim fields”).

## Corpus bridge (empirical, reproducible)

`sigma/GATE-0.2-FOLD-CENSUS.md` / `sigma/fold_census.py`: balanced-fold scan of
`quint-models/L*/*.qnt` finds **52/53** folds with `acc + …` and **1/53**
accumulator-preserving identity fold (Apex, no population order statistics).
That motivates the sum-local class; it is not a mechanised Quint-AST reduction
to `LocalSel`.

## Witnesses

| Population | Priorities | Demand | Extremal ids |
|------------|------------|--------|--------------|
| cA, cB | 5, 10 | 1 | [0] |
| cA, cC | 5, 3 | 1 | [2] |

Shared `SumAgg (2,2,1)` and claim A fields `(id=0,size=1,priority=5)`.

## Out of scope (honest)

* Full F9 record (settlement price, limit vectors, conservation games) from
  `REFUTATION.md` definition block.
* Operational `⋈` of BASIS machines.
* Delegated-allocation mandate (`REFUTER-DELEGATED-ALLOCATION.md`).
* Claim that every Quint composite (including multi-step state machines) is a
  `SumLocalProg`.

## Axioms

`#print axioms` on headline theorems: only `propext` / `Quot.sound` (see
`lean/Axioms.lean`).
