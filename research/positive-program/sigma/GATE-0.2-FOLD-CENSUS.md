# Gate 0.2 — fold census (corpus bridge artifact)

Reproducible scan of balanced `.fold( ... )` expressions in
`quint-models/L*/*.qnt` (line comments stripped). Matching is confined to each
balanced fold; later folds cannot supply `acc +` for an earlier fold.

- **Total balanced `.fold(` expressions:** 53
- **`acc + …` (sum folds):** 52
- **Accumulator-preserving / non-sum (`acc` present, no `acc +`):** 1
- **Other:** 0

## Role for Gate 0.2

Empirical motivation for the formal `SumLocalProg` / `SumAgg` class in
`lean/Defialgebra/Extremal.lean`. This file is **not** a Lean theorem that every
Quint program is a `LocalSel`. The Lean theorem proves extremal prefix fill is
outside the sum-local **filter program** class (closed under conjunction).

The sum-fold majority (and the absence of extremal/`min` folds) supports using
a sum-aggregate observation interface. The single non-sum identity fold is
sum-neutral (does not introduce population order statistics).

## Regeneration

```bash
python3 research/positive-program/sigma/fold_census.py
```

## Examples: acc_neutral

- `quint-models/L3/apex.qnt`: `.fold(0, (acc, t) => { val p = traders.get(t).position if (p.side == Flat) acc else acc })`

