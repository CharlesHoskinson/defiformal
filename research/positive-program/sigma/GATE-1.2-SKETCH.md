# Gate 1.2 — pairwise independence (sketch, not closed)

**Depends on:** 1.1b PARTIAL (characteristic laws named).

## Claim to prove

No P_i is a term over `{P_j : j≠i} ∪ KERNEL`.

## Proof obligations (from BASIS §2)

| delete | residual expressivity loss |
|---|---|
| Led | reachable Q frozen at init |
| Prop | reachable Q stays in ℕ-span of init (no mul/div) |
| Cmp | every guard ≡ true; debit loses partiality |
| Post | Σ/Φ constant for all time (no exogenous write) |

## Status

**NOT STARTED as a formal gate close.** Obligations listed; need either:

1. Lean model of term language over P with non-definability theorems, or
2. Corpus-level constructive witnesses (spec that becomes impossible when P_i removed).

Option 2 is cheaper and matches programme style. Next: for each P_i, cite one
corpus action that fails without it (already partially in BASIS).
