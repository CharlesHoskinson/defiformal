# TODO — the positive program

Live task list. `ROADMAP.md` holds the phase structure and the gate table;
`GOAL.md` holds the goal and the current measured status. This file is what to
do next.

**The goal, unchanged:** exhibit a finite basis of primitive mechanisms and prove
every useful DeFi application is constructible from it. Completeness first, then
composition, then construction.

---

## Now — Phase 2, the honest corpus

- [ ] **2.2 — spec the 21 unspecced applications.** The corpus names 72; only 51
      had specs. One of the unformalised, **Steakhouse Financial**, is a known
      refuter (delegated allocation authority) and needs no further work to
      count against completeness.
- [ ] **2.3 — re-run generation against the honest corpus.** This is the payoff.
      Everything since the eight-family refutation has been building the ability
      to measure; this is the measurement. Compare against the v1 figure of
      743/820 definitions, 10 specs ungenerated, 57 of 183 lane primitives
      outside the basis — but note that figure was taken against specs with the
      difficulty deleted, so it is a floor, not a baseline.

### Carried into 2.2 / 2.3 from the re-spec

- [ ] **Check W1's shipped curve domain against the K=8 truncation finding.**
      `evidence/curve_k.py`: at a 10^6 cap the worst converging pair needs 12
      iterations and 97 of 4900 converging pairs exceed K=8. Either cap curve at
      10^5 (K=8 exactly tight, divergence witness still hosted) or raise K >= 12.
- [ ] **Adopt the configuration-vector clause as convention 6b.** A T0 block
      written entirely in explicit arguments pins the *function*, not the
      *configuration* — `absorbHaircut(5000, 9000)` survives a mutation of
      `LIQUIDATION_FACTOR`. Every spec needs vectors evaluated at the market's
      own constants, not only at literals.
- [ ] **Adopt the arity-witness rule.** Value signatures cannot kill a
      selection-shaped deletion, and neither can the mechanism invariant. For any
      mechanism whose content is *which elements were selected together*, add a
      ghost recording the arity of the selection, justified against an on-chain
      observable.
- [ ] Correct `PILOT-NOTES` §7: apex's M3 agreement is 0/49, not 7/49.
- [ ] Correct `P2-CONTRACT` §A.10: the polymarket batch row is not economically
      realisable (implies a taker contribution of -30).
- [ ] Fold the three linter refinements the workers asked for: D4 should not fire
      when the action body re-derives the selection criterion from `var`s; D4
      matches `pure def` bodies as well as driver call sites; D4 cannot see
      through a nested call, so `batchLiquidate(List(u, v))` is silently exempt.

---

## Blocked — Phase 0/1, and deliberately visible

- [ ] **0.1 — state the `Q`/`Sigma` invariant testably, or withdraw `|P| = 4`.**
      **This gate is FAILED.** Three good-faith operationalisations
      (`sigma/qsigma{,2,3}.py`) all produce a trivial partition. `|P| = 4` and
      the six-sort split are the deepest claims in the programme and the only
      load-bearing ones with no script behind them. The Phase-2 loop restates
      each pass that it will never act on this, precisely so it does not become
      an assumption by neglect. **Someone must pick it up deliberately.**
- [ ] **0.2 — prove `F9` (extremal allocation) irreducible.** Settled
      empirically: every fold in all 57 v1 specs is a commutative sum, and there
      is not one extremal selection in the corpus. Needs the theorem — an
      invariant every composite preserves and extremal selection breaks.
- [ ] **1.1 — enumerate the ~16 families with signatures and laws.** Gate: every
      family has >= 2 corpus witnesses and a law that fails for its neighbours.
- [ ] **1.2 — pairwise independence**, each with a separating trace, as `F7` got
      via the interest-only trace.
- [ ] **1.3 — sufficiency.** The failure list (<= 15 colour classes) gives only
      the *necessary* direction. Post's theorem is an *iff*.

---

## Later — Phases 3 and 4

- [ ] 3.1 Generation theorem. 3.2 Composition totality. 3.3 Construction plus a
      linear-time certificate. 3.4 Mechanise in Lean (the development exists,
      sorry-free, no custom axioms).
- [ ] 4 Write the paper.

---

## Standing discipline

Seven times now, a check has passed **because the stressing states were
removed** — in the v1 invariants, in the plan's parsimony step (mandated), in an
acceptance test that checked shape not value, in conformance vectors true when
the function never runs, in a <=200 domain that "proves" Curve converges, in a
domain bound validated on a smaller grid than it shipped against, and in T0
blocks that pin the function but not the configuration.

Assume an eighth exists in whatever is written next.

Two rules that follow, and are not negotiable:

1. **Never report a mutant killed without running it.** W3 asserted a value
   signature unreachable, built the mutant, and watched it reach that state at
   depth 3.
2. **Conservation never once detected a deleted mechanism** — across morpho,
   compound, gmx, liquity and derive, `inv_conservation` reported `[ok]` on every
   mutant. A spec whose only invariant is conservation has tested nothing.
