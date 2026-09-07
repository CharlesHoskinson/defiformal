# Sprint 5 scenario coverage

Status: source/check/proof mapping complete for the frozen implementation and bound to the successful full build, runtime and imported-axiom audit. The frozen-source semantic mutation suite passes. Required native reviews are accepted with limitations in `ADJUDICATION.md`; source/evidence delivery is verified in `delivery.json`, and archive validation is recorded in `archive-validation.json`.

All 19 requirements and 42 scenarios are mapped. Two interface scenarios were added after initial review: conflicting exports and cross-domain snapshots. Each row names concrete source declarations, executed comparison labels, or a recorded acceptance action.

| Spec | SHA-256 | Requirements | Scenarios |
| --- | --- | ---: | ---: |
| `composition-regression-evidence` | `bea7d8d7a7ad9642eeddeab0ef86984fd4ea165c63442618b6a4568bb34fcb49` | 4 | 8 |
| `sequential-preservation` | `793d51a056fa74eed3cebb244cdb6052064b00e72ae4eee5c6854fcfa8bc7c93` | 6 | 9 |
| `sequential-workflow-execution` | `df7daac2ac265847b0183eb9ab3cecbd4030ff7ce8756f9e40af5db3a71e287e` | 5 | 12 |
| `typed-component-interfaces` | `cbc6387cd050c8cf45f20049cc7abedf0198e9c3bd88c3a4bd796206de3e7978` | 4 | 13 |

## composition-regression-evidence

Source: `../../../openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/specs/composition-regression-evidence/spec.md`.

### R1: Composed reference workflow coverage

Implementation/acceptance tasks: 6.1, 6.2, 6.4, 6.5, 6.6. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R1.S1: Positive and negative siblings | 6.4, 6.5, 6.6 | `interface.foreign-funded-kernel-control`; `interface.foreign-write`; `interface.shared-write`; `workflows.admin.revocation`; `workflows.admin.live.repeat`; `workflows.snapshot`; `workflows.output.unit`; `workflows.isolation.private`; `workflows.isolation.shared`; `workflows.isolation.readonly` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R1.S2: Composed financial reference | 6.1, 6.2 | `workflows.initial.complete`; `workflows.transfer.deposit.withdraw` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R2: Discriminating source mutations

Implementation/acceptance tasks: 7.1, 7.2, 7.3, 7.4, 7.5. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R2.S1: Executable mutant | 7.1, 7.2, 7.3, 7.5 | `scripts/check_composition_mutations.py`; `mutation-spec.json` | execution/measurement | `mutations/summary.json`:12/12 compiled mutants detected;93 comparisons each |
| R2.S2: Invalid or vacuous mutation run | 7.4, 7.5 | `scripts/test_composition_mutation_runner.py` | execution | `runner-controls-scoped/summary.json`:36/36 actual CLI controls; `mutations/summary.json` |
### R3: Honest verification and proof scope

Implementation/acceptance tasks: 1.2, 5.7, 6.8, 8.1. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R3.S1: New imported proof | 5.7, 6.8, 8.1 | `DefiKernel/Composition/Verify.lean`; `proof-inventory.json` | audit/measurement | `proof-inventory.json`; `final-axioms.log`; `build-verification.json` — passed |
| R3.S2: Existing regression failure | 1.2, 8.1 | `baseline.json`; `regression-runs.json` | execution/measurement | `build-verification.json`; `final-typed-runtime.log`; `final-typed-axioms.log`; `final-legacy-runtime.log`; `final-contract-runtime.log`; `final-legacy-axioms.log`; `regression-runs.json` — passed recorded regressions |
### R4: Independent review and source-bound delivery

Implementation/acceptance tasks: 8.3, 8.4, 8.5, 9.1, 9.2, 9.3, 9.4. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R4.S1: Candidate changes after review | 8.3, 8.4, 8.5 | `candidate source/hash binding and refreshed affected review records` | measurement/review | `review-summary.json`; `candidate-binding.json`; `commit-source-verification.json`; `ADJUDICATION.md` — both required final reviews accepted with limitations; all 27 committed input hashes match |
| R4.S2: Delivery record | 9.1, 9.2, 9.3, 9.4 | `delivery.json`; `final OpenSpec/archive validation` | measurement | `delivery.json`: remote source/evidence head verified; `archive-action.json` and `archive-validation.json`: archive/spec validation completed |

## sequential-preservation

Source: `../../../openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/specs/sequential-preservation/spec.md`.

### R1: Step and trace correspondence

Implementation/acceptance tasks: 3.3, 3.5, 4.2, 4.5. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R1.S1: Accepted invocation receipt | 3.3, 3.5, 4.5 | `DefiKernel.Composition.extractReceipt_total`; `DefiKernel.Composition.extractReceipt_correspondence`; `DefiKernel.Composition.executeStep_sound`; `DefiKernel.Composition.snapshot_of_selected`; `DefiKernel.Composition.run_trace_sound` | proof | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R1.S2: Refused suffix | 4.2, 4.5 | `DefiKernel.Composition.run_trace_sound`; `DefiKernel.Composition.run_order`; `DefiKernel.Composition.run_refusal_sound`; `DefiKernel.Composition.continueRun_failed`; `workflows.order.transfer.first` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R2: Cumulative accounting and nonnegativity

Implementation/acceptance tasks: 5.1, 6.2, 6.3. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R2.S1: Mint then burn | 5.1, 6.2 | `DefiKernel.Composition.run_accounting`; `workflows.transfer.deposit.withdraw`; `DefiKernel.Composition.Examples.workflow_accounting` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R2.S2: Accounting at refusal | 5.1, 6.3 | `DefiKernel.Composition.run_accounting`; `workflows.order.deposit.first`; `DefiKernel.Composition.Examples.refused_mint_prefix_accounting` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R3: Authority at the point of use

Implementation/acceptance tasks: 5.3, 6.5. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R3.S1: Successful use followed by revocation | 5.3, 6.5 | `DefiKernel.Composition.TraceSound.authority`; `DefiKernel.Composition.TraceSound.steps`; `DefiKernel.Composition.StepSound.issue_admin`; `DefiKernel.Composition.StepSound.revoke_admin`; `workflows.admin.revocation`; `DefiKernel.Composition.TraceSound.administration` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R4: Initialized invariant preservation

Implementation/acceptance tasks: 2.5, 5.2, 6.1. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R4.S1: Inductive guarantee | 2.5, 5.2, 6.1 | `DefiKernel.Composition.TraceSound.invariant`; `DefiKernel.Composition.TraceSound.event_invariants`; `DefiKernel.Composition.run_contract`; `DefiKernel.Composition.Examples.collateralContract_obligations`; `DefiKernel.Composition.Examples.collateral_initialized`; `DefiKernel.Composition.Examples.workflow_conditional_invariant`; `DefiKernel.Composition.Examples.boundaryContract_obligations`; `DefiKernel.Composition.run_prefix_nonnegative`; `DefiKernel.Composition.Examples.workflow_nonnegative` | conditional proof | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R5: Write locality and supported-predicate framing

Implementation/acceptance tasks: 5.4, 5.5, 6.7. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R5.S1: Protected ledger predicate | 5.4, 5.5, 6.7 | `DefiKernel.Composition.TraceSound.locality`; `DefiKernel.Composition.run_frame`; `DefiKernel.Composition.Examples.collateral_supported`; `workflows.frame.collateral`; `DefiKernel.Composition.Examples.workflow_collateral_frame`; `DefiKernel.Composition.Examples.workflow_protected_writes` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R5.S2: Unsupported predicate counterexample | 5.5, 6.7 | `workflows.frame.unsupported.counterexample`; `DefiKernel.Composition.Examples.unsupported_predicate_counterexample`; `DefiKernel.Composition.Examples.dropping_disjointness_counterexample` | counterexample | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R6: Scoped sequential composition law

Implementation/acceptance tasks: 4.4, 5.6, 6.7. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R6.S1: Boundary-sensitive composition | 4.4, 5.6, 6.7 | `DefiKernel.Composition.continueRun_append`; `workflows.resume.time`; `workflows.resume.time.negative`; `workflows.resume.boundary` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |

## sequential-workflow-execution

Source: `../../../openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/specs/sequential-workflow-execution/spec.md`.

### R1: Validated initialization and trusted execution inputs

Implementation/acceptance tasks: 2.1, 2.2, 3.1, 3.2. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R1.S1: Invalid initial configuration | 2.1, 2.2, 3.2 | `DefiKernel.Composition.executeStep_configuration`; `execution.configuration`; `DefiKernel.Composition.run_refusal_sound`; `workflows.configuration` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R1.S2: Caller cannot replace authority context | 3.1, 3.2 | `execution.actor.precedes.authority`; `DefiKernel.Composition.executeStep_delegated_refusal`; `workflows.actor` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R2: Current-world propagation

Implementation/acceptance tasks: 3.4, 4.1, 4.3, 6.5, 6.7. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R2.S1: Consecutive funded transfers | 4.1, 6.7 | `workflows.consecutive`; `DefiKernel.Composition.run_trace_sound` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R2.S2: Issue use revoke use | 3.4, 4.3, 6.5 | `DefiKernel.Composition.StepSound.issue_preserves_ledger`; `DefiKernel.Composition.StepSound.revoke_preserves_ledger`; `DefiKernel.Composition.StepSound.invoke_preserves_capabilities`; `workflows.admin.revocation`; `workflows.admin.live.repeat` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R3: Ordered first-refusal execution

Implementation/acceptance tasks: 4.1, 4.2, 6.3, 6.7. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R3.S1: Empty workflow | 4.1, 6.7 | `DefiKernel.Composition.continueRun_nil`; `workflows.empty` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R3.S2: First step refusal | 4.2, 6.7 | `DefiKernel.Composition.run_refusal_sound`; `workflows.first.refusal` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R3.S3: Middle refusal preserves prefix | 4.2, 6.3, 6.7 | `DefiKernel.Composition.continueRun_failed`; `DefiKernel.Composition.run_order`; `workflows.order.transfer.first` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R3.S4: Ordering changes observations | 4.1, 4.2, 6.3 | `workflows.order.transfer.first`; `workflows.order.deposit.first` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R4: Observable receipts and refusal provenance

Implementation/acceptance tasks: 3.2, 3.4, 3.5, 4.3, 6.4, 6.5. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R4.S1: Delegated refusal | 3.2, 3.4, 3.5, 6.5 | `DefiKernel.Composition.executeStep_delegated_refusal`; `DefiKernel.Composition.run_refusal_sound`; `execution.kernel.authority`; `execution.issue.unauthorized`; `execution.revoke.unknown`; `workflows.admin.revocation` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R4.S2: Snapshot remains historical | 3.5, 4.3, 6.4 | `DefiKernel.Composition.snapshot_of_selected`; `DefiKernel.Composition.run_trace_sound`; `workflows.snapshot`; `workflows.output.index` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R5: Continuation preserves history and boundary position

Implementation/acceptance tasks: 4.4, 5.6, 6.7. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R5.S1: Successful prefix resumed | 4.4, 5.6, 6.7 | `DefiKernel.Composition.continueRun_append`; `workflows.resume.output`; `workflows.resume.time`; `workflows.resume.time.negative`; `workflows.resume.boundary` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R5.S2: Failed prefix resumed | 4.4, 5.6, 6.7 | `DefiKernel.Composition.continueRun_failed`; `DefiKernel.Composition.continueRun_append`; `workflows.resume.terminal` | proof/execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |

## typed-component-interfaces

Source: `../../../openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/specs/typed-component-interfaces/spec.md`.

### R1: Stable typed port declarations

Implementation/acceptance tasks: 2.1, 3.2, 6.1, 6.8. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R1.S1: Valid declared operation | 2.1, 6.1 | `interface.valid`; `interface.snapshot-exact`; `DefiKernel.Composition.snapshots_length`; `DefiKernel.Composition.snapshot_of_selected`; `interface.crossdomain-output` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R1.S2: Invalid declarations | 2.1, 3.2 | `interface.duplicate-component`; `interface.duplicate-output`; `interface.input-output-collision`; `interface.duplicate-export`; `interface.duplicate-import`; `interface.unknown-operation`; `interface.ambiguous-owner`; `interface.wrong-signature`; `DefiKernel.Composition.executeStep_configuration`; `interface.crossdomain-output` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R1.S3: Cross-domain snapshot | 2.1, 3.2, 6.8 | `interface.crossdomain-output`; `interface.snapshot-exact`; `DefiKernel.Composition.executeStep_configuration` | execution/proof | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R2: Private ownership and explicit shared access

Implementation/acceptance tasks: 2.2, 2.3, 3.2, 6.6, 6.8. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R2.S1: Overlapping ownership | 2.2, 3.2 | `interface.private-overlap`; `interface.private-export`; `interface.private-import`; `interface.import-cell`; `interface.import-domain`; `interface.import-asset`; `interface.import-rights`; `interface.unique-export-provider`; `DefiKernel.Composition.validateCatalog_export_not_private` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R2.S2: Conflicting exports | 2.2, 3.2, 6.8 | `interface.unique-export-provider`; `interface.writable-export-selfwrite`; `interface.readonly-export-selfwrite`; `interface.shared-write-valid` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R2.S3: Authorized shared use | 2.2, 2.3, 6.6 | `interface.shared-write-valid`; `interface.shared-read-valid`; `interface.shared-write`; `interface.shared-read`; `workflows.isolation.catalogs`; `workflows.isolation.shared`; `DefiKernel.Composition.StepSound.component_writes`; `DefiKernel.Composition.StepSound.component_locality`; `DefiKernel.Composition.TraceSound.component_locality`; `interface.unique-export-provider`; `DefiKernel.Composition.validateCatalog_export_not_private` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R2.S4: Read-only import | 2.2, 2.3, 6.6 | `interface.readonly-write`; `interface.shared-write`; `workflows.isolation.readonly`; `workflows.isolation.shared`; `DefiKernel.Composition.StepSound.component_writes`; `DefiKernel.Composition.StepSound.component_locality`; `DefiKernel.Composition.TraceSound.component_locality` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R2.S5: Funded foreign-private interference | 2.3, 6.6 | `interface.foreign-funded-kernel-control`; `interface.foreign-write`; `interface.actual-target`; `interface.shared-write`; `workflows.isolation.private`; `workflows.isolation.shared`; `workflows.isolation.wrong.component`; `DefiKernel.Composition.StepSound.component_writes`; `DefiKernel.Composition.StepSound.component_locality`; `DefiKernel.Composition.TraceSound.component_locality` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R2.S6: Undeclared reads | 2.3, 6.6 | `interface.hidden-branch`; `interface.hidden-effect`; `interface.hidden-supply`; `interface.output-hidden`; `interface.declared-read`; `interface.shared-read`; `workflows.isolation.hidden.read`; `DefiKernel.Composition.checkAccess_ok_iff` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R3: Typed values do not transfer resource rights

Implementation/acceptance tasks: 2.4, 3.2, 3.5, 6.4. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R3.S1: Valid snapshot binding | 2.4, 3.5, 6.4 | `interface.literal`; `interface.snapshot-binding`; `workflows.snapshot`; `workflows.output.index` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R3.S2: Wrong unit or unavailable output | 2.4, 3.2, 6.4 | `interface.wrong-unit`; `interface.wrong-output-unit`; `interface.unknown-port`; `interface.forward`; `interface.current-index`; `interface.unavailable`; `workflows.output.unit`; `workflows.output.forward`; `workflows.output.unknown`; `DefiKernel.Composition.resolveSource_not_prior` | execution | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
### R4: Explicit semantic contract premises

Implementation/acceptance tasks: 2.5, 5.2, 5.7, 6.1, 8.2. All scenario rows below contribute to this requirement.

| Scenario | Tasks | Concrete check/proof IDs | Evidence kind | Evidence/status |
| --- | --- | --- | --- | --- |
| R4.S1: Initialized invariant reasoning | 2.5, 5.2, 6.1 | `DefiKernel.Composition.initialized_invariants`; `DefiKernel.Composition.run_contract`; `DefiKernel.Composition.TraceSound.event_invariants`; `DefiKernel.Composition.Examples.collateralContract_obligations`; `DefiKernel.Composition.Examples.collateral_initialized`; `DefiKernel.Composition.Examples.workflow_conditional_invariant`; `DefiKernel.Composition.Examples.boundaryContract_obligations` | conditional proof | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |
| R4.S2: Missing external assumption | 2.5, 5.7, 8.2 | `ContractObligations`; `DefiKernel.Composition.run_contract`; `DefiKernel.Composition.Examples.collateralContract_obligations`; `proof-inventory.json` | conditional proof/measurement | `final-runtime.log` / `proof-inventory.json` / `build-verification.json` — mapped checks/proofs passed; explicit theorem premises retained |

## Evidence binding and scope

Final build/runtime/imported-axiom audit evidence: `build-verification.json` records exact commands/exits and current source/log hashes. `final-build.log`: 1016 jobs, exit 0. `final-runtime.log`: 93 distinct comparisons, all true. `final-axioms.log`: 328 theorem and 583 supplemental declarations, forbidden dependencies 0; all 70 named source theorems are disclosed. Earlier `core-build.json`, `interfaces-runtime.log`, `workflows-report.md`, and `workflows-runtime.log` are historical intermediate checks and do not certify revised source bytes. `proof-inventory.json` records all named source theorem statements, exact hashes, quantification, premises and limits; generated declarations are separately audited.

The concrete `Examples.workflow_conditional_invariant` retains `localGuarantee`: each admitted invariant pre-world must satisfy boundary `now = 100` and the nondecreasing-collateral guarantee. Those premises are not inferred by catalog validation or advertised as discharged by this theorem. Actual concrete protected-collateral framing is separately proved by `Examples.workflow_collateral_frame`, with support and computed write disjointness discharged. `Examples.collateralContract_obligations` separately illustrates a mathematical price assumption; boundary time is not used as that price.

Financial authority uses each event pre-store through `TraceSound.authority`; administrative issue/revoke authority is separately lifted by `TraceSound.administration`. `TraceSound.component_locality` proves per-invocation interface isolation. The ledger frame theorem requires support and write disjointness and covers neither capability-store predicates nor arbitrary network composition. The append law is a finite-list law preserving full cursors, output history, absolute positions and terminal refusal. Nonnegativity relies on the proof-carrying State type.

Semantic mutation acceptance is recorded in `mutations/summary.json`:12/12 required source mutations apply, compile, execute93 comparisons each, and fail all designated comparisons while retaining six positive controls. The36 actual runner CLI controls are separate rejection evidence; runner-control rejection is not a semantic detection. Native Grok/Fable initial dissent and both final ACCEPT WITH LIMITATIONS verdicts are retained in `review-summary.json` and `ADJUDICATION.md`. Exact source bytes are bound to the reviewed Git objects in `commit-source-verification.json`. Delivery/archive actions are recorded only after execution.
