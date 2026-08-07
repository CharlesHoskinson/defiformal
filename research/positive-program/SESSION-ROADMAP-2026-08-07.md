# Session roadmap — 2026-08-07

Live tree: `/root/DefiElements` on `positive-program/phase2-honest-corpus` @ `f559c47` (+ M2).
Clone mirror: `/root/defiformal` (same origin commit at session start).

## Audit snapshot

| Area | Status |
|------|--------|
| Lean build | Clean, mathlib v4.33.0-rc2, no `sorry` / custom `axiom` |
| M1 Interface | DONE — `sup_not_port`, `cons_of_portConfined`, negative companion |
| M2 FlowPolarity | DONE this session — polarity policy + negative companion |
| M3 Associativity | OPEN — needs n-ary global binding, not binary bowtie patch |
| M4 Acceptance | OPEN — re-check 60 cross-carrier invariants under discipline |
| Gate 0.1 P=4 | WITHDRAWN (`sigma/QSIGMA-VERDICT.md`) |
| Gate 2.3 (ten) | Measured; ungenerated rate ~16.6% flat |
| Pendle bug | OPEN — `wit_staleIndexBacking` violation |
| Graphify | Rebuilt on lean + positive-program + algebra + paper |

## Ordered work

1. **M3 — associativity** — n-ary composition over a global binding set (do not patch binary kappa).
2. **M4 — corpus adequacy** — re-annotate L3 total*; fix Pendle; count how many of 60 invariants become derivable.
3. **Phase 1.1b re-order** — 2.2 acquisitions before more independence laws (authority walls).
4. **Gate 2.2** — 19 unspecced applications; justify as coverage not correction.
5. **Paper** — GOAL.md second branch (composition discipline) is better supported than pure generation after retractions.

## Traps (from RESUME)

- Quint: parenthesize disjunctive assignments of primed vars.
- Witness [ok] may mean harness bug — always dual observation.
- Conservation alone never catches deleted mechanisms.
