# Sprint 5 scenario coverage plan

Status: **planned**. Every identifier below is an intended check/proof obligation, not an existing Lean declaration or completed evidence. Task 8.2 must replace or bind these identifiers to actual built declarations, executed comparisons, and source-bound evidence paths. Baseline results in `baseline.json` concern existing Sprint 4 and legacy code only.

The four delta specs contain 19 requirements and 40 scenarios. Requirement rows inherit the union of their scenario obligations. General proofs, finite executions, counterexamples, measurements, and external assumptions remain separate. Native review is advisory and does not replace Lean proof.

| Spec | SHA-256 | Requirements | Scenarios |
| --- | --- | ---: | ---: |
| `composition-regression-evidence` | `bea7d8d7a7ad9642eeddeab0ef86984fd4ea165c63442618b6a4568bb34fcb49` | 4 | 8 |
| `sequential-preservation` | `793d51a056fa74eed3cebb244cdb6052064b00e72ae4eee5c6854fcfa8bc7c93` | 6 | 9 |
| `sequential-workflow-execution` | `df7daac2ac265847b0183eb9ab3cecbd4030ff7ce8756f9e40af5db3a71e287e` | 5 | 12 |
| `typed-component-interfaces` | `00da744c1e9cd06753279e894004d94c675ec35c378b64e2f90982cf0a225eb5` | 4 | 11 |

## composition-regression-evidence

Source: `../../../openspec/changes/typed-interfaces-sequential-composition/specs/composition-regression-evidence/spec.md`.

### R1: Composed reference workflow coverage

Implementation/acceptance tasks: 6.1, 6.2, 6.4, 6.5, 6.6. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R1.S1: Positive and negative siblings | 6.4, 6.5, 6.6 | `check_sibling_private_shared`; `check_sibling_revoked_live`; `check_sibling_output_units` | execution | planned |
| R1.S2: Composed financial reference | 6.1, 6.2 | `check_transfer_deposit_withdraw_complete_world` | execution | planned |
### R2: Discriminating source mutations

Implementation/acceptance tasks: 7.1, 7.2, 7.3, 7.4, 7.5. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R2.S1: Executable mutant | 7.1, 7.2, 7.3, 7.5 | `check_required_mutants_compile_and_discriminate` | execution/measurement | planned |
| R2.S2: Invalid or vacuous mutation run | 7.4, 7.5 | `check_runner_negative_controls_and_positive_sibling` | execution | planned |
### R3: Honest verification and proof scope

Implementation/acceptance tasks: 1.2, 5.7, 6.8, 8.1. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R3.S1: New imported proof | 5.7, 6.8, 8.1 | `check_composition_imported_axioms`; `check_proof_inventory` | audit/measurement | planned |
| R3.S2: Existing regression failure | 1.2, 8.1 | `check_preserved_regressions`; `check_baseline_hashes` | execution/measurement | planned |
### R4: Independent review and source-bound delivery

Implementation/acceptance tasks: 8.3, 8.4, 8.5, 9.1, 9.2, 9.3, 9.4. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R4.S1: Candidate changes after review | 8.3, 8.4, 8.5 | `check_review_candidate_binding_and_refreshed_evidence` | measurement/review | planned |
| R4.S2: Delivery record | 9.1, 9.2, 9.3, 9.4 | `check_accepted_tasks_and_remote_head`; `check_archived_specs` | measurement | planned |

## sequential-preservation

Source: `../../../openspec/changes/typed-interfaces-sequential-composition/specs/sequential-preservation/spec.md`.

### R1: Step and trace correspondence

Implementation/acceptance tasks: 3.3, 3.5, 4.2, 4.5. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R1.S1: Accepted invocation receipt | 3.3, 3.5, 4.5 | `receipt_extraction_total`; `receipt_correspondence`; `step_sound`; `trace_sound` | proof | planned |
| R1.S2: Refused suffix | 4.2, 4.5 | `trace_successful_prefix_final_world`; `check_funded_suffix_not_executed` | proof/execution | planned |
### R2: Cumulative accounting and nonnegativity

Implementation/acceptance tasks: 5.1, 6.2, 6.3. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R2.S1: Mint then burn | 5.1, 6.2 | `sequence_accounting`; `check_deposit_withdraw_supply_receipts` | proof/execution | planned |
| R2.S2: Accounting at refusal | 5.1, 6.3 | `sequence_accounting`; `check_supply_prefix_refusal` | proof/execution | planned |
### R3: Authority at the point of use

Implementation/acceptance tasks: 5.3, 6.5. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R3.S1: Successful use followed by revocation | 5.3, 6.5 | `sequence_authority_at_pre_store`; `check_use_then_revoke_authority` | proof/execution | planned |
### R4: Initialized invariant preservation

Implementation/acceptance tasks: 2.5, 5.2, 6.1. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R4.S1: Inductive guarantee | 2.5, 5.2, 6.1 | `sequence_initialized_invariant`; `sequence_prefix_nonnegative` | conditional proof | planned |
### R5: Write locality and supported-predicate framing

Implementation/acceptance tasks: 5.4, 5.5, 6.7. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R5.S1: Protected ledger predicate | 5.4, 5.5, 6.7 | `sequence_write_locality`; `sequence_supported_frame`; `check_protected_collateral` | proof/execution | planned |
| R5.S2: Unsupported predicate counterexample | 5.5, 6.7 | `check_frame_without_support_counterexample`; `check_frame_without_disjointness_counterexample` | counterexample | planned |
### R6: Scoped sequential composition law

Implementation/acceptance tasks: 4.4, 5.6, 6.7. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R6.S1: Boundary-sensitive composition | 4.4, 5.6, 6.7 | `sequence_append_continue`; `check_absolute_boundary_suffix` | proof/execution | planned |

## sequential-workflow-execution

Source: `../../../openspec/changes/typed-interfaces-sequential-composition/specs/sequential-workflow-execution/spec.md`.

### R1: Validated initialization and trusted execution inputs

Implementation/acceptance tasks: 2.1, 2.2, 3.1, 3.2. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R1.S1: Invalid initial configuration | 2.1, 2.2, 3.2 | `check_invalid_configuration_no_events` | execution | planned |
| R1.S2: Caller cannot replace authority context | 3.1, 3.2 | `check_actor_mismatch_delegated_reason` | execution | planned |
### R2: Current-world propagation

Implementation/acceptance tasks: 3.4, 4.1, 4.3, 6.5, 6.7. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R2.S1: Consecutive funded transfers | 4.1, 6.7 | `check_two_transfers_current_world` | execution | planned |
| R2.S2: Issue use revoke use | 3.4, 4.3, 6.5 | `admin_preserves_ledger`; `invocation_preserves_store`; `check_issue_use_revoke_use` | proof/execution | planned |
### R3: Ordered first-refusal execution

Implementation/acceptance tasks: 4.1, 4.2, 6.3, 6.7. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R3.S1: Empty workflow | 4.1, 6.7 | `check_empty_sequence_identity` | execution | planned |
| R3.S2: First step refusal | 4.2, 6.7 | `check_first_refusal_complete_world` | execution | planned |
| R3.S3: Middle refusal preserves prefix | 4.2, 6.3, 6.7 | `check_middle_refusal_no_funded_suffix` | execution | planned |
| R3.S4: Ordering changes observations | 4.1, 4.2, 6.3 | `check_transfer_then_deposit_order`; `check_deposit_then_transfer_order` | execution | planned |
### R4: Observable receipts and refusal provenance

Implementation/acceptance tasks: 3.2, 3.4, 3.5, 4.3, 6.4, 6.5. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R4.S1: Delegated refusal | 3.2, 3.4, 3.5, 6.5 | `step_refusal_preserves_world`; `check_delegated_refusal_provenance` | proof/execution | planned |
| R4.S2: Snapshot remains historical | 3.5, 4.3, 6.4 | `output_snapshot_correspondence`; `check_historical_output_stability` | proof/execution | planned |
### R5: Continuation preserves history and boundary position

Implementation/acceptance tasks: 4.4, 5.6, 6.7. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R5.S1: Successful prefix resumed | 4.4, 5.6, 6.7 | `sequence_append_continue`; `check_resume_output_and_boundary` | proof/execution | planned |
| R5.S2: Failed prefix resumed | 4.4, 5.6, 6.7 | `sequence_append_continue`; `check_terminal_resume_identity` | proof/execution | planned |

## typed-component-interfaces

Source: `../../../openspec/changes/typed-interfaces-sequential-composition/specs/typed-component-interfaces/spec.md`.

### R1: Stable typed port declarations

Implementation/acceptance tasks: 2.1, 3.2, 6.1. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R1.S1: Valid declared operation | 2.1, 6.1 | `check_valid_operation_signature_and_output_unit` | execution | planned |
| R1.S2: Invalid declarations | 2.1, 3.2 | `check_duplicate_ports`; `check_unknown_operation`; `check_ambiguous_owner`; `check_signature_mismatch` | execution | planned |
### R2: Private ownership and explicit shared access

Implementation/acceptance tasks: 2.2, 2.3, 3.2, 6.6. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R2.S1: Overlapping ownership | 2.2, 3.2 | `check_private_overlap`; `check_private_as_shared`; `check_shared_cell_domain_asset_mismatch` | execution | planned |
| R2.S2: Authorized shared use | 2.2, 2.3, 6.6 | `check_shared_read_write_authorized` | execution | planned |
| R2.S3: Read-only import | 2.2, 2.3, 6.6 | `check_read_only_write_refusal_live_grant` | execution | planned |
| R2.S4: Funded foreign-private interference | 2.3, 6.6 | `check_funded_private_interference_live_grant`; `check_wrong_component` | execution | planned |
| R2.S5: Undeclared reads | 2.3, 6.6 | `check_hidden_guard_effect_supply_output_reads`; `check_unselected_branch_reads` | execution | planned |
### R3: Typed values do not transfer resource rights

Implementation/acceptance tasks: 2.4, 3.2, 3.5, 6.4. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R3.S1: Valid snapshot binding | 2.4, 3.5, 6.4 | `check_transfer_snapshot_deposit_7_usd`; `check_value_binding_no_resource_rights` | execution | planned |
| R3.S2: Wrong unit or unavailable output | 2.4, 3.2, 6.4 | `check_wrong_unit`; `check_unknown_output`; `check_forward_output`; `check_unavailable_output` | execution | planned |
### R4: Explicit semantic contract premises

Implementation/acceptance tasks: 2.5, 5.2, 5.7, 6.1, 8.2. Requirement coverage: all scenario rows below; status **planned**.

| Scenario | Tasks | Planned check/proof IDs | Evidence kind | Status |
| --- | --- | --- | --- | --- |
| R4.S1: Initialized invariant reasoning | 2.5, 5.2, 6.1 | `sequence_initialized_invariant`; `reference_initialization_witness` | conditional proof | planned |
| R4.S2: Missing external assumption | 2.5, 5.7, 8.2 | `check_proof_inventory_external_assumptions`; `sequence_initialized_invariant` | conditional proof/measurement | planned |

## Acceptance binding still required

Task 8.2 must record actual evidence paths and exact source identity for every row. Task 5.7 records theorem quantification, initialization/local/boundary premises, and limits. The finite-list append law includes world, output history, absolute positions, and terminal refusal; it does not establish a general network law. Frame predicates are ledger-only and require support and disjointness proofs. Structural validation does not prove observation truth or arbitrary semantic contracts.

Tasks 7.1–7.5 must distinguish real compiled/executed semantic detections from unapplied, noncompiling, unexecuted, empty, or surviving mutants. Tasks 8.3–9.4 require exact-candidate native review, refreshed affected evidence after fixes, accepted task completion, and recorded remote delivery before archive.
