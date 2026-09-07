## 1. Baseline and acceptance inventory

- [ ] 1.1 Record the starting commit, clean/dirty worktree, tool versions, and preserved proof/corpus hashes in `review/semantic-kernel/sprint5/baseline.json`; verify the manifest resolves to actual files and the Sprint 4 delivery history.
- [ ] 1.2 Run the existing full Lean build, typed runtime/audit, and legacy runtime/audit drivers listed below; save commands, exits, and logs, and resolve failures before adding composition code.
- [ ] 1.3 Create a scenario-to-check/proof map for all four delta specs in `review/semantic-kernel/sprint5/coverage.md`; verify every requirement and scenario has an assigned implementation task and an intended executable check or theorem.

## 2. Component interfaces and contracts

- [ ] 2.1 Add stable component/port identities, typed input and selected-cell output declarations, operation membership, and signature validation in `lean/DefiKernel/Composition/Interfaces.lean`; verify valid declarations and each duplicate, unknown-operation, ownership-ambiguity, and wrong-signature refusal.
- [ ] 2.2 Add private ownership and exact shared import/export access validation; verify overlap, private-as-shared, cell/domain/asset mismatch, and read-only-write negatives beside valid shared read/write siblings.
- [ ] 2.3 Resolve actual operation references and check required/declared reads, writes, both expression branches, and output selections against interface access; verify a funded foreign-private target refuses despite a live debit grant, while a matching shared target succeeds.
- [ ] 2.4 Add closed literal/prior-output input bindings and unit checks; verify correct USD routing and wrong-unit, unknown-port, forward-reference, and unavailable-output refusals without financial changes.
- [ ] 2.5 Add initialization, assumptions, invariant/guarantee obligations, and ledger predicate support in `Contracts.lean`; verify definitions elaborate and a small initialized fixture proves its invariant only with explicit required premises.

## 3. Single-step adapter and receipts

- [ ] 3.1 Add world, immutable configuration, trusted position-indexed boundary inputs, and invocation/issue/revoke step types in `Execution.lean`; verify caller data cannot select the trusted principal, registry, or operation body and an actor mismatch preserves the kernel refusal.
- [ ] 3.2 Implement structural configuration rejection and ordered membership/binding/interface prechecks; verify each failure preserves the input world and delegated well-formed calls retain existing kernel refusal precedence.
- [ ] 3.3 Wrap `Typed.execute` and extract actual evaluated effect/supply/write receipts against the same pre-world; prove extraction total on accepted execution and receipt correspondence, with no default receipt or derived post-minus-pre supply.
- [ ] 3.4 Route issue/revoke through the existing administrative APIs using configuration derived from the same registry; prove accepted administration preserves the ledger, accepted invocation preserves the store, and refused steps preserve both.
- [ ] 3.5 Prove the step soundness relation for invocation and administration and verify selected-cell outputs equal successful post-state snapshots; confirm refused and internally inconsistent adapter outcomes commit nothing and emit no successful output.

## 4. Sequential execution and observations

- [ ] 4.1 Implement the ordered runner and trace/result types in `Sequence.lean`; verify empty identity, consecutive transfers using current balances, and exact event positions.
- [ ] 4.2 Implement first-refusal termination with preserved successful prefix; verify first-step and middle-step failures retain the correct world, reason, and index and do not execute a funded suffix.
- [ ] 4.3 Carry typed historical outputs and current capabilities across successful steps; verify later writes do not alter snapshots and issue/use/revoke/use rejects the final use without undoing the earlier use.
- [ ] 4.4 Implement continuation with existing world/history, absolute next index, and terminal status; verify a suffix consumes an earlier output, uses its absolute trusted boundary input, and cannot resume execution after refusal.
- [ ] 4.5 Prove runner trace soundness and successful-prefix/final-world correspondence; verify all trace events link to their immediately preceding worlds and omitted/refused suffix steps have no receipts.

## 5. Sequence preservation and frame proofs

- [ ] 5.1 Prove cumulative per-domain/per-asset accounting in `Preservation.lean` from actual evaluated supply receipts; verify a mint/burn example and a supply-changing prefix ending in refusal instantiate the theorem.
- [ ] 5.2 Prove nonnegativity at every reachable prefix and initialization-based invariant preservation under explicit local/boundary premises; verify the concrete reference initialization witnesses instantiate both results.
- [ ] 5.3 Lift invocation, debit, supply, and administrative authorization to traces at each step's pre-store; verify a successful use followed by revocation needs no live final-store grant.
- [ ] 5.4 Prove write-union locality and per-invocation domain restrictions; verify untouched cells remain equal even when the trace ends in refusal or includes administrative steps.
- [ ] 5.5 Prove the ledger supported-predicate frame theorem from support and protected/write disjointness; verify a protected collateral predicate and a concrete counterexample to dropping the support/disjointness premises.
- [ ] 5.6 Prove append/continuation equivalence including output histories, absolute positions, and terminal failures; verify an output-consuming, boundary-sensitive suffix and document that this is a finite-list law.
- [ ] 5.7 Save a named proof inventory with quantification, premises, and limits in `review/semantic-kernel/sprint5/proof-inventory.json`; verify every listed theorem exists in the built source and no bounded comparison is labeled a general theorem.

## 6. Composed reference workflows

- [ ] 6.1 Build explicit component catalogs, permissions, capabilities, and initialization witnesses in `Examples.lean` over the existing finite reference ledger; verify the catalogs pass validation and all initial cells/store entries match independent fixtures.
- [ ] 6.2 In `Tests.lean`, check transfer 3 USD, deposit 4 USD, withdraw 2 shares: Alice ends with 7 USD and 4 shares, Bob with 3 USD, vault with 20 USD; verify all other cells, supply receipts (+2 then -2 shares), outputs, and event order independently.
- [ ] 6.3 Check ordering siblings from the same initial world: transfer 8 then deposit 4 retains Alice 2/Bob 8 USD on deposit refusal; deposit 4 then transfer 8 retains Alice 6 USD/6 shares and vault 24 USD on transfer refusal; verify complete worlds and no suffix execution.
- [ ] 6.4 Check transfer 3 emits Alice's 7 USD snapshot, then deposit consumes that 7: Alice ends with 0 USD and 15/2 shares, vault with 27 USD, Bob with 3 USD; verify stale-snapshot stability and wrong-share-unit/unavailable-output siblings.
- [ ] 6.5 Add valid administrative issue/use/revoke/use and live-repeat siblings with sufficient funds; verify exact capability stores, unchanged administrative ledgers, successful-prefix balances, and final refusal provenance.
- [ ] 6.6 Add funded private-interference, explicit shared-write, read-only, hidden-read, and wrong-component siblings; verify each refusal targets interface isolation rather than missing funds or unrelated authority.
- [ ] 6.7 Add empty/first/middle refusal, protected-cell, and append/resume boundary fixtures; verify complete finite worlds, every event/output, and a support-premise counterexample.
- [ ] 6.8 Add `Audit.lean` and `Verify.lean`, import composition from `lean/DefiKernel.lean`, and run their drivers; verify a nonempty named comparison inventory and imported theorem/supplemental declaration audit with zero forbidden dependencies.

## 7. Source mutations and runner controls

- [ ] 7.1 Add a scoped `scripts/check_composition_mutations.py` with `--repo`, `--spec`, and `--out`, separate executable projection, exact source hashes, and nonempty inventory checks; verify an unchanged positive run compiles and all comparisons pass in an isolated scratch output directory.
- [ ] 7.2 Define actual source mutants for reverse/drop ordering, continue-after-refusal, reset-ledger, reset-capability-store, and omit-revocation-propagation in `review/semantic-kernel/sprint5/mutation-spec.json`; verify every mutant compiles and fails its designated executed comparison.
- [ ] 7.3 Add interface-write-bypass, wrong-output-index/unit, dropped-supply-receipt, and reset-continuation-index mutants; verify designated comparisons discriminate each mutant and unrelated positive controls remain meaningful.
- [ ] 7.4 Add `scripts/test_composition_mutation_runner.py` controls for empty inventories, duplicate/unknown checks, missing or non-unique mutation sites, unchanged replacements, compile failures, surviving mutants, malformed evidence, and output-location misuse; verify actual CLI rejection and a valid accepted sibling for the runner.
- [ ] 7.5 Run the complete composition mutation suite and runner controls against the candidate and save machine-readable outcomes; verify no unapplied, noncompiling, unexecuted, empty, or surviving required mutant is counted as a semantic detection.

## 8. Integration and independent review

- [ ] 8.1 Run the full build, composition and existing typed/legacy runtime and axiom drivers, existing typing/mutation/audit controls, and corpus regressions; save commands/exits and verify preserved baseline files plus all required checks.
- [ ] 8.2 Complete the scenario coverage map with actual check/theorem identifiers and evidence paths; verify no spec scenario is uncovered and distinguish proofs, executions, measurements, counterexamples, and external assumptions.
- [ ] 8.3 Commit a concrete candidate and prepare scoped review bundles for interfaces/contracts, execution/proofs, and regression/evidence; verify bundles and tool identities resolve to that exact source commit.
- [ ] 8.4 Run independent native Grok and Fable review of each scope through the stock workflow, without Foreman; save raw requests/responses and verify all findings, limits, or unavailable-review statuses are recorded honestly.
- [ ] 8.5 Resolve blocking findings and rerun affected verification/review against any changed candidate; save `ADJUDICATION.md` and candidate binding and verify no required review or blocking finding remains outstanding.

## 9. Acceptance and delivery

- [ ] 9.1 Update `roadmap.md`, the progress ledger, and this checklist from actual accepted evidence; verify broader composition, claim lifecycle, and fidelity work remains open and this sprint's completed boxes have evidence.
- [ ] 9.2 Run strict OpenSpec validation and whitespace/link checks on the final change; verify validation passes and all referenced delivery evidence exists.
- [ ] 9.3 Commit and push Sprint 5 source/evidence on the authorized branch, verify remote head equals the intended local delivery head, and save the delivery record; verify the final worktree contains no unexplained changes.
- [ ] 9.4 Archive the implemented OpenSpec change using the CLI and validate the resulting main specs; verify archiving occurs only after accepted implementation and deliver the archive/metadata commit on the same branch.

Verification commands are execution instructions, not evidence of completed runs.
Run Lean commands from `lean/`:

```sh
lake build
lake env lean DefiKernel/Composition/Audit.lean
lake env lean DefiKernel/Composition/Verify.lean
lake env lean DefiKernel/Typed/Audit.lean
lake env lean DefiKernel/Typed/Verify.lean
lake env lean DefiKernel/Audit.lean
lake env lean DefiKernel/ContractAudit.lean
lake env lean DefiKernel/VerifyAxioms.lean
```

Run Python checks from the repository root. The composition runner will use the
same `--repo . --spec PATH --out PATH` convention as the existing typed runner;
each evidence output must be a new directory outside the repository. Capture the
exact generated scratch path and command in the run manifest, then copy accepted
evidence into the sprint directory. Obtain existing control-script arguments from
their actual `--help`, retaining the Sprint 4 verified invocations as the baseline.

Planning and final validation from the repository root:

```sh
openspec validate typed-interfaces-sequential-composition --strict --json --no-interactive
openspec status --change typed-interfaces-sequential-composition --json
git diff --check
```

Dependencies follow section order. Sections 2 and 3 must establish their
correspondence obligations before section 5 relies on them. Build discriminating
fixtures alongside each feature; section 6 completes their composed coverage.
Review and delivery gates apply to the implemented candidate, not to this plan.
