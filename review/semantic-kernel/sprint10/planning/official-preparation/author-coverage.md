# Planning author coverage

4 capabilities; 17 requirements; 57 scenarios; 34 unchecked tasks; 14 planned mutations. No implementation or independent approval.

| Scenario | Requirement | Tasks | Planned evidence |
|---|---|---|---|
| RA01 Empty region | Finite typed region observations | 2.1, 5.1 | balanceSum_set, region_wellformed, F01, M01 |
| RA02 Duplicate declarations | Finite typed region observations | 2.1, 5.1 | balanceSum_set, region_wellformed, F01, M01 |
| RA03 Typed membership | Finite typed region observations | 2.1, 5.1 | balanceSum_set, region_wellformed, F01, M01 |
| RA04 Neutral nonzero transfer | Exact signed actual receipt accounting | 2.2, 2.3, 5.1 | actual_region_accounting, receiptCellEffect_eq, F01, F02, F03, F04, M02, M03, M04, M05 |
| RA05 Boundary-crossing transfer | Exact signed actual receipt accounting | 2.2, 2.3, 5.1 | actual_region_accounting, receiptCellEffect_eq, F01, F02, F03, F04, M02, M03, M04, M05 |
| RA06 Nonzero issuance | Exact signed actual receipt accounting | 2.2, 2.3, 5.1 | actual_region_accounting, receiptCellEffect_eq, F01, F02, F03, F04, M02, M03, M04, M05 |
| RA07 Repeated targets | Exact signed actual receipt accounting | 2.2, 2.3, 5.1 | actual_region_accounting, receiptCellEffect_eq, F01, F02, F03, F04, M02, M03, M04, M05 |
| RA08 Issue and revoke | Administrative balance identity | 2.3, 5.4 | administrative_region_identity, F18, M14 |
| RA09 Refused administration | Administrative balance identity | 2.3, 5.4 | administrative_region_identity, F18, M14 |
| RA10 Successful prefix followed by refusal | Actual successful prefix accounting | 2.4, 4.1, 4.2, 5.4 | sequential_receipt_fold, shared_receipt_fold, F15, F17, F19, F20 |
| RA11 Shared global receipt fold | Actual successful prefix accounting | 2.4, 4.1, 4.2, 5.4 | sequential_receipt_fold, shared_receipt_fold, F15, F17, F19, F20 |
| RA12 Peer continues after refusal | Actual successful prefix accounting | 2.4, 4.1, 4.2, 5.4 | sequential_receipt_fold, shared_receipt_fold, F15, F17, F19, F20 |
| RA13 Failed suffix skip before peer | Actual successful prefix accounting | 2.4, 4.1, 4.2, 5.4 | sequential_receipt_fold, shared_receipt_fold, F15, F17, F19, F20 |
| IT01 Nonvacuous shared cancellation | Conditional port-confined conservation | 3.1, 5.2 | confined_neutral_preserves, F01, F02 |
| IT02 Supply neutrality is insufficient | Conditional port-confined conservation | 3.1, 5.2 | confined_neutral_preserves, F01, F02 |
| IT03 Complement framed | Conditional port-confined conservation | 3.1, 5.2 | confined_neutral_preserves, F01, F02 |
| IT04 Fixed declared quantity | Supported declared total | 3.2, 3.3, 5.2 | ValueSupports, supported_total_preserves, ghost_total_preserves, F05 |
| IT05 Private total support | Supported declared total | 3.2, 3.3, 5.2 | ValueSupports, supported_total_preserves, ghost_total_preserves, F05 |
| IT06 Missing initialization | Supported declared total | 3.2, 3.3, 5.2 | ValueSupports, supported_total_preserves, ghost_total_preserves, F05 |
| IT07 Exposed total changes | Actual writable-total counterexample | 3.3, 5.2 | writable_total_counterexample, F06 |
| IT08 Exact missing premise | Actual writable-total counterexample | 3.3, 5.2 | writable_total_counterexample, F06 |
| IT09 Nonzero-index group | Initialized operational total lifting | 3.4, 4.1, 4.2, 4.3, 5.4 | total_prefix_preservation, total_group_preservation, total_shared_preservation, F16, F17, F19, F20 |
| IT10 Shared total invariant | Initialized operational total lifting | 3.4, 4.1, 4.2, 4.3, 5.4 | total_prefix_preservation, total_group_preservation, total_shared_preservation, F16, F17, F19, F20 |
| IT11 Absorbed failure | Initialized operational total lifting | 3.4, 4.1, 4.2, 4.3, 5.4 | total_prefix_preservation, total_group_preservation, total_shared_preservation, F16, F17, F19, F20 |
| GB01 Exact qualified identity | Exact typed global binding query | 2.5, 2.6, 5.3 | checkBindings_ok_iff, binding_failure_first, F08, F10, F11, F12, F13, M06, M07, M08, M09, M10, M11, M12, M13 |
| GB02 Missing endpoint kind and side | Exact typed global binding query | 2.5, 2.6, 5.3 | checkBindings_ok_iff, binding_failure_first, F08, F10, F11, F12, F13, M06, M07, M08, M09, M10, M11, M12, M13 |
| GB03 Dimensional mismatch | Exact typed global binding query | 2.5, 2.6, 5.3 | checkBindings_ok_iff, binding_failure_first, F08, F10, F11, F12, F13, M06, M07, M08, M09, M10, M11, M12, M13 |
| GB04 Failure precedence | Exact typed global binding query | 2.5, 2.6, 5.3 | checkBindings_ok_iff, binding_failure_first, F08, F10, F11, F12, F13, M06, M07, M08, M09, M10, M11, M12, M13 |
| GB05 Catalog precedes emptiness | Exact typed global binding query | 2.5, 2.6, 5.3 | checkBindings_ok_iff, binding_failure_first, F08, F10, F11, F12, F13, M06, M07, M08, M09, M10, M11, M12, M13 |
| GB06 Outputs are not live resources | Exact typed global binding query | 2.5, 2.6, 5.3 | checkBindings_ok_iff, binding_failure_first, F08, F10, F11, F12, F13, M06, M07, M08, M09, M10, M11, M12, M13 |
| GB07 Positive distinct-cell equality | Binding meaning and actual alias distinction | 2.6, 4.4, 5.3 | Agrees, query_agreement, import_export_identity, F07, F08, F13, F14 |
| GB08 One-sided accepted write | Binding meaning and actual alias distinction | 2.6, 4.4, 5.3 | Agrees, query_agreement, import_export_identity, F07, F08, F13, F14 |
| GB09 Existing resource alias | Binding meaning and actual alias distinction | 2.6, 4.4, 5.3 | Agrees, query_agreement, import_export_identity, F07, F08, F13, F14 |
| GB10 Self binding | Binding meaning and actual alias distinction | 2.6, 4.4, 5.3 | Agrees, query_agreement, import_export_identity, F07, F08, F13, F14 |
| GB11 Nonzero paired effects | Initialized actual binding preservation | 4.1, 4.2, 4.3, 4.4, 5.3, 5.4 | paired_effect_preserves, binding_prefix_preservation, binding_group_preservation, binding_shared_preservation, F07, F15, F17, F18, F19, F20 |
| GB12 Sequential refusal retained | Initialized actual binding preservation | 4.1, 4.2, 4.3, 4.4, 5.3, 5.4 | paired_effect_preserves, binding_prefix_preservation, binding_group_preservation, binding_shared_preservation, F07, F15, F17, F18, F19, F20 |
| GB13 Shared peer progression | Initialized actual binding preservation | 4.1, 4.2, 4.3, 4.4, 5.3, 5.4 | paired_effect_preserves, binding_prefix_preservation, binding_group_preservation, binding_shared_preservation, F07, F15, F17, F18, F19, F20 |
| GB14 Administrative or skipped step | Initialized actual binding preservation | 4.1, 4.2, 4.3, 4.4, 5.3, 5.4 | paired_effect_preserves, binding_prefix_preservation, binding_group_preservation, binding_shared_preservation, F07, F15, F17, F18, F19, F20 |
| GB15 Union and orientation | Global constraint algebra and scope | 4.5, 5.3 | agrees_append, agrees_reverse, agrees_idempotent, agrees_assoc, agrees_permutation, binding_law_prefix, F09, F10 |
| GB16 Global skip edge | Global constraint algebra and scope | 4.5, 5.3 | agrees_append, agrees_reverse, agrees_idempotent, agrees_assoc, agrees_permutation, binding_law_prefix, F09, F10 |
| GB17 Diagnostic distinction | Global constraint algebra and scope | 4.5, 5.3 | agrees_append, agrees_reverse, agrees_idempotent, agrees_assoc, agrees_permutation, binding_law_prefix, F09, F10 |
| GB18 Sufficient closure criterion | Symmetric closure is sufficient only | 4.6, 5.3 | same_symClosure_sufficient, symClosure_not_necessary, F10 |
| GB19 Redundant transitive edge | Symmetric closure is sufficient only | 4.6, 5.3 | same_symClosure_sufficient, symClosure_not_necessary, F10 |
| GB20 Independent omitted edge | Symmetric closure is sufficient only | 4.6, 5.3 | same_symClosure_sufficient, symClosure_not_necessary, F10 |
| RE01 Independent expected data | Independent funded observations and negative companions | 5.1, 5.2, 5.3, 5.4, 5.5 | F01-F20, fixture-manifest, runtime-manifest |
| RE02 Broken premise succeeds operationally | Independent funded observations and negative companions | 5.1, 5.2, 5.3, 5.4, 5.5 | F01-F20, fixture-manifest, runtime-manifest |
| RE03 Nonempty audit | Independent funded observations and negative companions | 5.1, 5.2, 5.3, 5.4, 5.5 | F01-F20, fixture-manifest, runtime-manifest |
| RE04 Compiled discriminating mutation | Actual mutation and defensive control evidence | 6.1, 6.2, 6.3, 6.4 | M01-M14, inherited-controls, mutation-report, runner-controls |
| RE05 Compiler failure gets no credit | Actual mutation and defensive control evidence | 6.1, 6.2, 6.3, 6.4 | M01-M14, inherited-controls, mutation-report, runner-controls |
| RE06 Production and proof-tail controls | Actual mutation and defensive control evidence | 6.1, 6.2, 6.3, 6.4 | M01-M14, inherited-controls, mutation-report, runner-controls |
| RE07 Drift or missing inputs | Actual mutation and defensive control evidence | 6.1, 6.2, 6.3, 6.4 | M01-M14, inherited-controls, mutation-report, runner-controls |
| RE08 Imported proof discovery | Complete proof and regression evidence | 1.3, 5.5, 7.1, 7.2, 7.3 | proof-inventory, baseline, integration, legacy-regressions |
| RE09 Exact regression identity | Complete proof and regression evidence | 1.3, 5.5, 7.1, 7.2, 7.3 | proof-inventory, baseline, integration, legacy-regressions |
| RE10 Protected source preservation | Complete proof and regression evidence | 1.3, 5.5, 7.1, 7.2, 7.3 | proof-inventory, baseline, integration, legacy-regressions |
| RE11 Accepted dependency binding | Dependency and independent acceptance gates | 1.1, 1.2, 7.4, 8.1, 8.2 | dependency-gate, planning-audits, native-results, delivery |
| RE12 Reviewer identity | Dependency and independent acceptance gates | 1.1, 1.2, 7.4, 8.1, 8.2 | dependency-gate, planning-audits, native-results, delivery |
| RE13 Material finding and delivery | Dependency and independent acceptance gates | 1.1, 1.2, 7.4, 8.1, 8.2 | dependency-gate, planning-audits, native-results, delivery |
