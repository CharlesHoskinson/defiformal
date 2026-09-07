# Initialized interference proof handoff

`Interference.lean` and `InterferenceFixtures.lean` compile with Lean 4.33.0-rc2.
The 92 financial runtime comparisons remain true after whitespace-only wrapping
of the existing Examples/Tests files. Exact focused commands, logs, times and
current source hashes are in `interference-verification.json`. This worker did
not run a full build or native reviewer; parent integration owns those gates.

The two proof modules contain 24 named theorems. The exact named axiom disclosure
set is recorded in `interference-axiom-driver.lean`, `interference-axioms.log` and
`interference-axioms.json`. Only `propext`, `Classical.choice` and `Quot.sound`
appear. Parent automatic imported/supplemental auditing remains required.
No `sorry`, custom axiom or `native_decide` is introduced.

## Generic rule

`Reachable.two_invariants`, `runPrefix_two_invariants`, and
`every_prefix_two_invariants` prove both ledger invariants on actual reachable
machines, every supplied finite token sequence, and each `take` prefix.
They require:

- both invariants at the initial ledger;
- local obligations universally quantified over branch, local index, selected
  invocation, arbitrary own history, pre-world and actual StepSound result;
- the selected branch's own invariant alone to derive its post-invariant and
  guarantee;
- every branch guarantee included in each other branch's rely;
- independent stability of each invariant under its rely.

The induction uses `Reachable.attempt_index` to identify the consumed static
invocation index with the actual successful index before an attempt. A successful
step obtains own preservation from its independent local obligation and peer
preservation from cross-inclusion/stability. Refusal and skipped tokens are world
identities. No peer invariant appears in a local obligation, and no local premise
assumes the whole-run conclusion or a supplied unrelated trace.

## Concrete instance and limits

`shared_supply_free` checks both registered transfer templates have no supply.
`shared_step_total` derives USD-total equality for any successful StepSound of
that registry and arbitrary pre-world/history/boundary. This lemma does not need
an own-invariant antecedent. `shared_local_obligation amount` then proves the
parameterized own invariant plus total-equality guarantee. `shared_cross`,
`shared_stable` and `shared_initialized` discharge the remaining hypotheses.
`shared_every_prefix` and `shared_all_tokens` prove total USD 10 for the two actual
overlapping vault-transfer workflows for every finite schedule/prefix.
`shared_left_analyzed`, `shared_right_analyzed` and `shared_overlap` establish
both static write footprints and their shared vaultUSD cell.

`collateral_supported` proves support on the exact collateral singleton.
`protected_collateral_all_tokens` uses the actual analyzed union-write frame to
preserve collateral 9 for every finite token sequence. It imposes no disjointness
between the two branches. `sound_target_frame` is a generic StepSound frame helper
specialized to the finite financial identity types; it requires actual invocation
analysis and StepSound, then frames cells outside the analyzed writes.

## Certified omitted-premise counterexamples

`missing_initialization_counterexample` proves all three noninitial R/G premises
for total USD 11, then proves the actual empty prefix fails that invariant because
its total is USD 10.

`fragile_local_obligation` has real nonempty financial branches: the left branch
preserves Bob=0 because its vault-to-Alice write footprint excludes Bob; the right
branch preserves total USD 10. Both guarantee total equality and both invariants
are initialized (`fragile_initialized`).
`missing_peer_stability_counterexample` proves those local, cross and initial
premises, plus an actual right-prefix step satisfying total-equality rely while
breaking the left Bob=0 invariant. `fragile_not_stable` derives failure of the
missing stability premise. No branch uses an empty or impossible local obligation.

`missing_frame_support_counterexample` gives actual empty-region agreement across
a left-prefix transfer, initial Alice USD 0, and changed final Alice USD 7.
`empty_support_is_false` proves that this financial predicate has no empty support.

These are Lean proofs of the stated conditional rules and concrete counterexamples.
They make no protocol fidelity, solvency, liveness, atomicity or capability-race
claim. Imported historical proof statements and runtime fixture behavior are unchanged.
