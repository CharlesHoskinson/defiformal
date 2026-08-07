import pathlib

r = pathlib.Path("/root/DefiElements/research/positive-program/ROADMAP.md")
t = r.read_text(encoding="utf-8")

t = t.replace(
    "| 2.1 re-spec the ten | **READY** | 2.0d passed; needs contrast-set review, then execution |",
    "| 2.0e plan review | **FAILED** | `phase2/P2-REVIEW.md`: plan not sound as written; five repairs required |\n"
    "| 2.1 re-spec the ten | **BLOCKED** | blocked on 2.0e repairs — do NOT start until all five land |")

t = t.replace(
    "**Next gate: 2.1 — write the ten re-specs.** Unblocked.",
    """**Next gate: 2.0e — repair the plan.** Five required changes, ranked by damage
prevented. Do not write a single re-spec until all five land.

### The five repairs

1. **Delete the parsimony step.** `P2-FIDELITY` section 3 step 3 instructs the
   worker to remove any distinction the mutant suite does not need, iterated to a
   fixed point. That is the *fourth trap* — the same shape as the other three
   (the check passes because the stressing states were removed), except here it
   is mandated. It also contradicts section 2's contract-facing droppability
   rule, and it makes the generation measurement circular: the corpus becomes a
   function of the ten contrast sets.
2. **Add T0 conformance vectors.** The acceptance test is cheatable for eight of
   the ten, because it checks the *shape* of a definition and never its *value*.
   Worked cheat on `derive`: decorate the deleted constant with a per-scenario
   factor and the min-invariant becomes a tautology about any fold-min while the
   witness is violated by construction. Fix: at least three exact
   (input, output) pairs read off the contract, asserted as `pure val`s.
3. **Extend the nondet convention.** It catches 3 of 10 (liquity, derive,
   polymarket; partly huma) and is silent on sqrt, Newton, the absorb haircut,
   the bad-debt no-op, the missing fee, and the absent impact function.
4. **Mandate three contrast-set members.** Distant rivals are free to kill —
   Curve's own blend beats a contrast set of constant-sum plus constant-product.
   Require: the v1 shortcut body itself, a chaos relaxation, and a near
   neighbour agreeing with the target on at least 90% of the domain, sourced
   from a sibling protocol already in the corpus.
5. **Fix i64 for three protocols.** `morpho_blue`'s acceptance item 4 literally
   cannot run (`WAD^2 = 10^36`); `compound_v3` chains two 1e18 factors; and
   `gmx`'s permitted linearisation deletes the convexity that *is* the impact
   mechanism — revoke that permission, since a descaled domain hosts exponent 2
   fine. The damage path is second-order: overflow is loud, the worker escapes
   it by shrinking the domain, and **that is exactly how Curve reached
   `bal0 = bal1 = 100`** and lost its discrimination witness.

### Regression guard strengthened in response

`respec_lint.py` D3 now matches **trailing** comments, not only standalone ones —
the form of the confirmed `apex.qnt:145` defect
(`marginPool' = marginPool, // simplified: collateral absorbed`). D3 findings on
v1 went 2 -> 7; new baseline **185 findings / 57 specs**.

### apex: three further losses beyond the three recorded

Confirmed against source. There is no close/burn path at all, so the fee is
absent on the exit side too; the LP-mint branch at `:184` is **dead**
(`lpShares` is seeded at 100 and only ever increases, so `lpShares == 0` is
unreachable) and it deletes the permanent MINIMUM_LIQUIDITY lock, itself one of
the twelve unmatched candidate primitives; and `liquidate`'s **trigger** is
deleted as well as its settlement — the contract prices via `getMarkPriceAcc`,
making liquidatability size-dependent, where the spec uses an exogenous scalar.""")

r.write_text(t, encoding="utf-8")
print("ROADMAP updated: 2.0e FAILED, 2.1 BLOCKED")
