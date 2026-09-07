## 1. Planning and baseline gates

- [x] 1.1 Save proposal/design/four specs/tasks and the wiki decision index; run strict OpenSpec validation and verify every scenario maps to an implementation task and planned evidence type.
- [x] 1.2 Freeze the candidate and context bundle, obtain separate GPT-6 and native Fable planning verdicts, resolve blocking findings and save exact candidate/model/hash metadata; verify both passing reviews bind the same final candidate before any implementation.
- [x] 1.3 Record a current full Lean/runtime/axiom baseline and protected-source inventory at the base revision; verify every required baseline command below exits zero and no preserved source bytes drift.

## 2. Schedule representation and admission

- [x] 2.1 Add `Interleaving/Schedule.lean` with token counts and typed mismatch details; verify exact counts, empty branches, missing/excess tokens and balanced alternating schedules, and prove accepted-count equivalence.
- [x] 2.2 Add ordered catalog/left/right/schedule preflight reusing whole-branch analysis without compatibility rejection; verify funded shared writes are admitted, unreachable malformed suffixes refuse, and competing preflight errors follow the specified precedence.
- [x] 2.3 Prove complete schedules consume each branch's static slots in order and admitted footprints cover each selected invocation; verify original Parallel admission implies shared structural admission for complete schedules.

## 3. Shared execution and observations

- [x] 3.1 Add `Interleaving/Execution.lean` with one-world machine, local states, successful next indices, consumed counts, exact attempts and initialization; verify empty identity and balanced singleton execution against complete expected worlds.
- [x] 3.2 Implement token advancement and finite-prefix folding through real `Composition.executeStep` with local boundary/history and current shared world; verify competing USD10 withdrawals and replenishment order with exact receipts and failure reasons.
- [x] 3.3 Implement permanent branch-local halting and inert suffix/out-of-range token handling; verify immediate/middle/dual refusal, no retry after replenishment, retained prefix, continued peer and absence of skipped attempts.
- [x] 3.4 Expose full schedule/attempt results and named canonical projection/comparison; verify each preserved observation field with changed/equal pairs, including exact failure and full store/ledger, and document deliberately omitted global order/raw foreign worlds.
- [x] 3.5 Add real shared-key snapshot and peer-only-history examples using current versus captured values; verify own history, qualified ports/units and local boundary indices with independently funded successful siblings.

## 4. Sound traces and preservation

- [x] 4.1 Add `Interleaving/Soundness.lean` inductive machine reachability and prove actual prefix execution sound, including exact failed calls; verify initial/final world continuity and that successful branch events project from actual attempts.
- [x] 4.2 Prove local invocation order/history isolation, refusal stability, skipped-slot inertia, full schedule slot completion and fixed capability store; verify each theorem is about the actual runner rather than a supplied unrelated trace.
- [x] 4.3 Add `Interleaving/Preservation.lean` actual-receipt supply aggregation and generic prefix accounting; verify independent nonzero supply in both branches plus a refused suffix and prove per-domain/asset equality.
- [x] 4.4 Prove point-of-use authority at actual pre-worlds/local boundaries and derive initial-store authority, plus reached-world nonnegativity; verify live/revoked and unauthorized/authorized financial siblings and expose state/trust premises.
- [x] 4.5 Prove locality outside actual writes and analyzed union writes, supported predicate frames, and identity for admission/refusal/skip; verify protected collateral and a concrete missing-support counterexample.

## 5. Interference and disjoint recovery

- [x] 5.1 Add `Interleaving/Interference.lean` ledger relations and independently quantified local preservation/guarantee obligations; prove initialized two-invariant prefix preservation from cross-inclusion and stability without peer-invariant or whole-run premises.
- [x] 5.2 Instantiate both invariants for overlapping USD10 transfer workflows with equality-of-total rely/guarantee relations; verify local no-supply template proofs, concrete initialization and every schedule-prefix conclusion, plus counterexamples to omitted initialization and peer stability.
- [x] 5.3 Add `Interleaving/Recovery.lean` prefix simulation with isolated cursors and dependency-region agreement; prove each success/refusal matches the isolated branch using existing dependency lemmas, including local outputs after peer writes outside their region.
- [x] 5.4 Prove every complete admitted disjoint schedule has the existing parallel canonical observation and derive LR/RL reference correspondence; verify the theorem includes stopped branches and supplied equality/success assumptions are absent.
- [x] 5.5 Prove empty/one-empty and full-block serial laws; verify all six disjoint 2+2 schedules against independent expected results, a disjoint refused-prefix case, and a shared-source counterexample to unrestricted order equivalence.

## 6. Reference coverage and imported audit

- [x] 6.1 Complete `Interleaving/Examples.lean` and `Tests.lean` with all seven design fixture families; verify independent complete ledgers/stores, receipts, typed outputs, exact failure reasons/indices and protected successful controls.
- [x] 6.2 Add `Interleaving/Audit.lean` with a nonempty unique named runtime inventory and `Verify.lean` with automatic imported theorem/supplemental axiom checks; add the new root import and verify zero forbidden dependencies and full runtime success.
- [x] 6.3 Save named theorem statements/premises and classify generic results, instances, counterexamples and generated declarations; finish a one-to-one scenario inventory and verify every planned scenario has actual evidence without calling finite executions generic proofs.

## 7. Production mutations and runner controls

- [x] 7.1 Add `scripts/check_interleaving_mutations.py` with explicit repo/spec/out, fresh source projection, byte manifests and complete inventory enforcement; verify an unchanged real execution control with all comparisons true and protected positive labels present.
- [x] 7.2 Add mutants for count bypass, overlap rejection, stale initial execution, isolated-world replacement, global cancellation, prefix rollback and halted retry; verify all seven compile and each designated independent runtime oracle detects the actual source change.
- [x] 7.3 Add mutants for peer history, snapshot recomputation, global boundary index, wrong local invocation, dropped peer supply, revoked-grant resurrection and failure-observation omission; verify all seven compile and each designated oracle fails while its protected sibling remains true.
- [x] 7.4 Add `scripts/test_interleaving_mutation_runner.py` with actual CLI valid/empty/partial/duplicate/unknown/malformed inventory, missing/nonunique/no-op edit, compile failure, survivor, failed-positive, source-drift and unsafe-output controls; verify intended diagnostics and distinguish violated from blocked results.
- [x] 7.5 Freeze mutation source/spec/driver inputs and execute all fourteen mutations and runner controls in fresh external directories; verify complete per-variant inventories, input Git-object bindings, artifact hashes and unchanged source, retaining failed attempts without counting them as detections.

## 8. Integration and independent implementation review

- [x] 8.1 Freeze source and run new/full legacy Lean drivers, typed/composition/parallel mutations, their runner controls, compiler typing controls, axiom controls and corpus regressions; verify actual exits/logs and protected bytes, with fresh source manifests and no reused old pass claims.
- [x] 8.2 Complete scenario/proof/tool/source manifests and perform an independent artifact cross-check; verify all scenario mappings are nonempty, every counted artifact exists and hashes/counts bind the reviewed source revision.
- [x] 8.3 Obtain native Grok/Fable implementation and evidence audits using exact frozen source bundles; save requested/reported identities and raw responses, and verify each required scope has a substantive passing verdict.
- [x] 8.4 Resolve blockers and refresh affected checks/review on the revised candidate; save adjudication with limitations and retained dissent, verifying no waived normative proof, mutation or review obligation.

## 9. Wiki roadmap delivery and archive

- [x] 9.1 Update roadmap/progress/wiki and task states from actual accepted evidence; verify atomic settlement, changing capabilities, general associativity and fidelity remain open and wiki notes link to source/evidence.
- [x] 9.2 Validate this OpenSpec strictly and check current editorial whitespace/local links; verify raw hash-bound artifacts remain byte-identical when their display contains whitespace warnings.
- [x] 9.3 Commit/push to `semantic-kernel-pivot`, verify the actual remote head and record delivery metadata; verify no merge to main or unrelated change is included.
- [ ] 9.4 Archive only `shared-state-interleaving`, validate four synchronized main specs and repaired archive links, then push metadata; verify final remote identity, completed task states and clean worktree.

The 37 checkboxes are acceptance obligations, not completed results. Dependencies:
1 gates all implementation; 2→3→4; 4→5; fixtures grow with 2–5; 6 completes their
inventory; 7 requires the actual behaviors; 8 and 9 close integration and delivery.
Execution uses the already approved stock GPT-6 harness and branch. No Foreman.

Verification instructions (save actual command arrays, full logs, exits, UTC times,
source hashes and versions when run; these instructions are not evidence):

```sh
# Repository root
openspec validate shared-state-interleaving --strict --json --no-interactive
openspec status --change shared-state-interleaving --json
git diff --check
# lean/; baseline excludes the two new Interleaving drivers only
lake build
lake env lean DefiKernel/Interleaving/Audit.lean
lake env lean DefiKernel/Interleaving/Verify.lean
lake env lean DefiKernel/Parallel/Audit.lean
lake env lean DefiKernel/Parallel/Verify.lean
lake env lean DefiKernel/Composition/Audit.lean
lake env lean DefiKernel/Composition/Verify.lean
lake env lean DefiKernel/Typed/Audit.lean
lake env lean DefiKernel/Typed/Verify.lean
lake env lean DefiKernel/Audit.lean
lake env lean DefiKernel/ContractAudit.lean
lake env lean DefiKernel/VerifyAxioms.lean
```

Run Python regressions using the exact established command arrays in
`review/semantic-kernel/sprint6/integration/` and mutation/runner manifests after
checking the actual drivers' help. Allocate new output paths and bind current
inputs. New driver command:
`python3 scripts/check_interleaving_mutations.py --repo . --spec review/semantic-kernel/sprint7/mutation-spec.json --out /tmp/NEW-UNIQUE-DIRECTORY`.
The runner must own creation of a fresh output directory. For a fresh package
rebuild use `lake clean defialgebra` followed by `lake build`; bare `lake clean`
also cleans dependency packages and is not the intended regression procedure.
