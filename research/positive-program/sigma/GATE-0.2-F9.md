# Gate 0.2 — F9 extremal allocation irreducible

**Status: CLOSED (2026-08-07)**

## Claim
An invariant preserved by sum-local selection (the measured corpus fragment) is
broken by extremal prefix allocation (F9).

## Mechanisation
`lean/Defialgebra/Extremal.lean`

- `LocalSel phi` — selection by `phi : Claim -> SumAgg -> Bool` (own fields + sum aggregates only).
- `extremalFill` — sort by priority, take demand-bounded prefix.
- `f9_irreducible_to_sum_local` / `extremal_not_local` — no `phi` matches extremal on both:
  - claims priorities (5,10), demand 1 → fill id 0
  - claims priorities (5,3), demand 1 → fill id 2
  Same local view of claim A (size 1, prio 5, SumAgg (2,2,1)) is accepted then rejected.

## Corpus link
Every fold in the v1 corpus is commutative sum (`REFUTATION.md` / ROADMAP). That is
the class `LocalSel` abstracts. Liquity-style redemption is `extremalFill`.

## Scope
Does not mechanise full operational `bowtie` of BASIS.md machines; abstracts the
sum-local invariant the corpus actually exhibits. Delegated allocation is a separate
refuter (`REFUTER-DELEGATED-ALLOCATION.md`).
