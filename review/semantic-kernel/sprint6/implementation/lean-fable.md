**Verdict: ACCEPT WITH LIMITATIONS** for candidate `7cb4807d1ff22c5ac804b03feb4a2530c46146f2`, Lean implementation scope only.

The core proof chain is sound and non-circular as written. Admission, dependency, congruence, locality, region merge, LR/RL correspondence, accounting, authority and framing all discharge their premises from checked admission and the existing Sprint 5 executor. No premise assumes the advertised conclusion. The limitations below are evidence-scope and fixture gaps, not proof defects. The mutation runner and legacy Python regression gates remain open and are not waived by this review.

## Proof soundness

I traced the dependency chain from `Expr.eval_congr_of_resolved` through to the schedule theorems and found no hidden obligation.

- **Expression and template dependency.** `evaluate_congr` in `Dependency.lean` reduces every guard, delta and supply expression to the syntactic read inventory. Both `ite` arms are included because `Expr.stateReads` is syntactic. Errors are covered because the whole `Except` result is equated.
- **Implicit funding dependency.** `evaluated_effect_zero_outside` derives zero effect outside resolved delta targets from `evaluated_targets`, with no `writesOK` premise. `funds_iff` then uses only the input states' nonnegativity witnesses. `applyEvaluated_congr` therefore preserves every exact refusal constructor, including refusals that occur after the funds check.
- **Executor congruence.** `execute_congr` handles every state-independent precheck by case split and rewrites through `evaluate_congr`. The store is a single fixed parameter, so authority checks are identical by construction.
- **Adapter lift.** `executeStep_congr` in `Dependency/Adapter.lean` obtains read and target containment from `analyzed_dependencies`, snapshot equality from `analyzed_outputs`, and receipt equality from `extractReceipt_congr` using each execution's own prestate. `executeStep_target_frame` frames outside the analyzed writes, which contain all delta targets.
- **Branch lift.** `continueRun_congr` threads the local index against the analyzed boundary index and keeps histories identical via the outputs component of `CursorAgrees`. The refused-prefix case is closed by the failure component. `continueRun_frame` composes head and tail frames correctly.
- **Serial correspondence.** `merge_serialLR` is the crux and is correct by three cases on cell membership. The right-written case relies on `analyzeBranchFrom_writes_read`, which is why writes are included in reads. `runParallel_serialRL` reuses the same lemma with swapped boundaries plus `mergeWorld_swap`. `runParallel_serialLR` and `runParallel_serialRL` carry no premise beyond the definitions. `serial_orders_equivalent` and `singleton_commutation` are honest corollaries.
- **Preservation.** `runParallel_accounting` derives the merge frames from `runBranch_frame` and disjointness from `admit_ok`, then uses actual receipt supplies. `runBranch_authority` justifies replacing each event's pre-store by the initial store through `trace_invoke_stores`, which is proved rather than assumed. `runParallel_two_invariants` separates own-branch induction from peer-support disjointness, so there is no assume-guarantee circle.

The observation definitions are financially complete in the stated sense. `observeBranch` retains steps with input sources, resolved requests, full `Evaluated` receipts, ordered typed snapshots, next index and exact located failure. Only `Event.before` and `StepResult.world` are dropped, which matches the design.

## Findings

**[Medium, pending evidence] Mutation and legacy regression gates are open.** Nothing in this bundle demonstrates the fourteen source mutants or the Python regression suite. The native evidence audit must confirm each required item separately. Two mutant-specific risks deserve attention there. Mutant 2 will survive unless the admission collector drops both syntactic reads and declared reads, because the `hidden` fixture template in `CompatibilityTests.lean` keeps a declared read for its funded kernel sibling. Mutant 4 must remove targets from both writes and reads, since either list alone still yields the `zero-target` conflict.

**[Low, evidence scope] Axiom audit implementation not in the reviewed text.** `Verify.lean` invokes `#audit_axioms`, but `AxiomAudit.lean` is only identified by hash in `lean-runs.json`. I cannot confirm from supplied source that the 388/419 counts and the forbidden-zero result are computed over the full transitive closure. The stated theorem counts are likewise reported, not independently verified here.

**[Low, modeled semantics] Serial references are admission-gated.** `runSerialLR` and `runSerialRL` in `Execution.lean` call `admit` before running. The refused branch of the correspondence theorem is therefore definitional. This matches the spec wording "for every admitted branch pair", but reports should not describe the theorem as relating the parallel operator to unconditional sequential execution of arbitrary pairs.

**[Low, proof scope] Local preservation obligations are stronger than reachable-state induction.** `LocalPreservation` in `Preservation.lean` quantifies over every `StepSound` transition from every world, including issue and revoke steps. This is sound and non-circular, but a contract that only holds on reachable states cannot be discharged. `local_total_preservation` shows the intended supply-free route. Document this as a limitation of the invariant API.

**[Low, coverage] No compiler control for the administrative-exclusion scenario.** The spec scenario "Administrative input excluded" is satisfied by `Branch` being a list of invocations, but no `#check_failure` fixture records that `Step.issue` cannot appear. A one-line control in `CompatibilityTests.lean` or `Tests.lean` would bind the scenario to evidence.

**[Info] Trivial nonnegativity theorems are labeled honestly.** `runParallel_executed_nonnegative` and `runBranch_prefix_nonnegative` only expose existing state witnesses, and the preservation report says so. Keep that wording in the roadmap.

**[Info] Shared-qualified-key fixture uses one invocation in both slots.** `routing.shared-qualified-key` runs the same component-0 no-op in both branches. This is inherent to "same fully qualified key" and is acceptable, but it should not be cited as a two-component routing case.

## Fixtures, scenarios and evidence classification

I checked the independently written expectations against the templates and store by hand. All arithmetic I recomputed matches: core USD 7/3 and shares 16/4, same-asset vault 16 and pool 5, stateful 5 then 5/2 with guard refusal at local index 2, stateful supply 30 then 45, mint/burn 12 and 17, timed boundaries USD 8/2 and shares 14/6 with per-branch principals and times. The capability revocation fixture binds `revokedStore` to an actual `revokeCapability` call. The peer-only routing refusal is genuinely caused by history isolation, since the peer key has the correct unit and a funded literal sibling succeeds. Fourteen scenarios are compared against the same independent records under LR and RL, not merely against the parallel implementation.

Every normative scenario in the four specs maps to at least one named proof, fixture or counterexample, with the single compiler-control gap noted above. Evidence classes are kept distinct as required:

- **Generic proofs:** dependency, congruence, correspondence, accounting, authority, frame and invariant theorems, universally quantified over finite identity types.
- **Kernel-checked reference instances:** `PreservationFixtures.lean` and `Dependency/Fixtures.lean` via `decide +kernel`, no `native_decide`.
- **Counterexamples:** unsupported and written-support frame failures, poor-state funding dependence.
- **Bounded runtime comparisons:** the 131-entry inventory in `Audit.lean`, which is development evidence rather than holdout evidence.
- **Environmental assumptions:** boundary authenticity, environment truth, registry and catalog trust, and the finite reference universe, all inherited unchanged from earlier sprints.

Required before acceptance: complete the mutation and legacy regression gates with the two mutant caveats above resolved. Recommended: add the administrative-exclusion compiler control and include the axiom-audit source in the next review bundle.
