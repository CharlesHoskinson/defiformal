VERDICT: ACCEPT WITH LIMITATIONS

Reviewer: Claude Fable 5.1 (claude-fable-5-1), source-only read of candidate 6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c against approved plan bf3fb509. No build, proof check or runtime was executed by me. The two supplied logs are parent evidence, not my execution.

Scope reviewed: Interleaving Schedule, Execution, Soundness, LocalOrder, Trace, Preservation, Interference, InterferenceFixtures, Recovery (Reference/Step/Simulation/root), Examples, ScheduleTests, Tests, Audit, Verify, plus the unchanged Typed/Composition/Parallel base they depend on.

Material blockers: none found.

What I checked and found consistent with the specs/design

1. One evolving world. `Interleaving.advance` runs `Composition.executeStep` with `boundaries b own.nextIndex`, `own.nextIndex`, `own.outputs` and `m.world`. Success replaces the shared world and appends the real event and post-state outputs; refusal keeps the world, records `⟨own.nextIndex, some (.invoke inv), reason⟩` and halts only that branch; a halted or exhausted branch only bumps `consumed`. Peer state is untouched (`advance_peer_local`). Refusal stability is proved (`AdvanceSound.refusal_stable`, `continueRun_refusal_stable`).

2. Trace continuity and local order. `Reachable.attempt_chain` links each attempt's pre-world to the previous post-world or unchanged refused world. `branch_projection`, `local_history`, `local_event_index`, `local_order`, `failure_index` are all derived from the runner via `advance_sound`, not assumed. `Reachable.attempt_index` gives nextIndex = consumed exactly for a selected active attempt, which is the required reading (not after refusal or exhausted skip). Boundaries are therefore branch-local; the `boundary.local` fixture (`timedBoundaries` with 100+i / 200+i and principal switching at index 1, schedule R,L,L,R) does discriminate global-position lookup.

3. Accounting/authority/store. `Reachable.accounting` sums `Attempt.supply` from actual receipts with refusals contributing zero. `Reachable.authority` is at the attempt's real pre-world and `boundaries attempt.branch attempt.index`; `before_stores` and `initial_store_authority` pin every store to the initial one. Nonnegativity is the proof-carrying `State.nonneg` witness, stated as such.

4. Locality and supported frames. Both the actual-writes frame (`Reachable.locality`, `predicate_frame`) and the analyzed-footprint frame (`analyzed_locality`, `analyzed_predicate_frame`) exist; the latter needs only analysis, not compatibility, and is instantiated on the overlapping `sharedCfg` with `shared_overlap` proving vaultUSD is written by both branches while collateral is framed.

5. Rely/guarantee. `LocalObligation` quantifies over all positions, histories and own-invariant worlds with the fixed local boundary and mentions neither the peer invariant nor the run result. `Reachable.two_invariants` discharges the accepted case through `attempt_index`. Initialization and stability counterexamples (`missing_initialization_counterexample`, `fragile_not_stable`, `empty_support_is_false`) are concrete and non-vacuous; `fragile_local_obligation` uses the analyzed footprint at index 0 rather than a run result.

6. Universal disjoint recovery. `Simulates` maintains `CursorAgrees` (state on own reads, store, observed events, outputs, nextIndex, failure) between each branch's live cursor and `isolated` prefix. Own-token step: `isolated_step`/`advance_own_cursor` show both sides are the same `Composition.advance` call, then `cursor_advance_congr`; exhausted tokens use `isolated_exhausted`; halted branches reduce to identity. Peer-token step uses `advance_branch_frame` plus `Compatible`. `runPrefix_parallel` closes with `runPrefix_complete_counts`, `isolated_full` and `analyzeBranchFrom_writes_read` so the merged world is matched on write regions and `continue_outside` elsewhere. Refusals are inside `CursorAgrees.failure`, so failure cases are covered generically, not only in the six finite schedules. LR/RL and empty specializations transport through `runParallel_serialLR/RL` and `runParallel_empty_*`.

7. Canonical fields. `ProjectedEquivalent`/`matchesParallel` retain final ledger, store, events (index, step, receipt, outputs), history, successful index and exact failure, and omit only consumed counts, attempt order and raw event worlds. The `observe.omitted.context` and `observe.peer` checks confirm exactly that.

8. Fixtures. I recomputed the ledgers, receipts, outputs and failure sites for shared LR/RL, replenish, live, snapshot (both.own and distinct), peer-only, immediate/middle/dual, supply, boundary, revoked/unauthorized/debit, unit, malformed, and the 2+2 disjoint family; all agree with the direct tables. Authority entries in `Parallel.Examples.store` cover every debit/supply used.

9. Axiom coverage. The supplied audit lists only propext, Classical.choice and Quot.sound across 259 theorems and 271 supplemental declarations; the source uses `decide +kernel`, never `native_decide`, `sorry` or custom axioms. The runtime log names match the source inventory one-for-one, and `Audit.main` blocks empty or duplicate inventories.

Non-blocking findings (smallest fix each)

F1. Spec "Complete slot consumption" asks that each branch has exhausted its invocations or retains its first refusal. `runPrefix_complete_counts` proves the counts; the disjunction is only derivable from `Reachable.active_index`. Add a one-line corollary in `Interleaving/LocalOrder.lean`, e.g. `runPrefix_complete_local`: `Complete left right schedule → ∀ b, (local b).failure = none → (local b).nextIndex = (selectBranch left right b).length`.

F2. No named identity theorem for admission refusal (`runInterleaving_refuses`), unlike `Parallel.runParallel_refuses`. It holds by construction and is exercised by `admissionRefused`; add a `simp [runInterleaving, h]` lemma in `Interleaving/Recovery.lean` or `Execution.lean`.

F3. `Interleaving.observationsEqual` ignores the schedule in the refused case (consistent with the Parallel comparator); `admissionRefused` does compare it. Worth a docstring sentence so nobody reads the comparator as schedule-sensitive.

Limits and scope

Advisory review, not mathematical proof; I did not compile, replay `decide +kernel` obligations, or rerun the audit. Proof acceptance rests on the supplied parent build/axiom logs. The mutation runner, its 14 mutants, runner CLI controls, full legacy regressions and comprehensive final evidence are outside this audit and receive no approval here. No prior implementation reviews were available to cross-check.
