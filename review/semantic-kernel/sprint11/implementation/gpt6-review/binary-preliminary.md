# Binary draft semantic review

**PRELIMINARY; NO IMPLEMENTATION VERDICT.** No new blocking semantic defect was found in the inspected draft. Native Grok still owns compilation and may change source. This review ran only bounded source reads and hash/text comparisons, with no Lean/Lake/LSP process, feature edit, or root-cache operation. Transient proof elaboration issues were not evaluated as semantic defects.

## Bound inputs

The hashes below were captured during the substantive read and reproduced at its end:

| Input | SHA256 |
| --- | --- |
| Nary/Observation.lean (18,727 bytes) | `154ac0b69fa1a45197a7e9f435ce3ea472280101dcc1d1880df20f266c7316f0` |
| Nary/BinaryCorrespondence.lean (28,726 bytes) | `167a3d2ada212e473dd0947b678b69ebb3a3c645fbf4f3cc15ceb9bc8d1fc462` |
| Interleaving/Schedule.lean | `a531621726138ef20d1b45edf8c680869a4e35bee4697cfc93d80c250e2b6ad9` |
| Interleaving/Execution.lean | `8a39ccbaf6cf03479a5b16a156c52a2b6f5bd97a9198b633be27be3b1b899d21` |
| finite-binary-continuation-correspondence/spec.md | `330640dfdd04dc545e127697ad4cfd827d8e2d7fc94f4d2e63e088f0870f7e2f` |
| proposed-api.json | `890e732a30646f4f9d9c777ce6897ca0f98782e6b5730a9c7811ccd7e8345eb7` |

The actual accepted Interleaving source definitions were read for machine/attempt/local/result layouts, admission order, count payload order, all single-token cases, continuation and complete runner. Nary Observation was compared with the preserved core-r3 source: removing only the new shared-binary-executable block makes the file byte-identical to the accepted core-r3 version. The old complete observation definitions and proofs were not rewritten in this draft. The new block is before `-- BEGIN PROOFS`; BinaryCorrespondence imports Observation and contributes proofs after its own marker.

## Semantic findings

**Every-field machine conversion is explicit.** Observation:108–140 copies the actual world, both whole Interleaving.LocalState records, and the ordered attempt list. Local records retain consumed, nextIndex, failure, outputs and complete raw events. Attempt conversion changes only the participant/branch field label and retains index, invocation, raw before world and full Except outcome, including result world/receipt/outputs. BinaryCorrespondence:25–77 states both attempt/list/machine round trips; functional locals and branch selectors are handled extensionally. This does not pass through the older lossy `observe` projection.

**Results and diagnostics retain the required data.** Observation:144 reconstructs expectedLeft, observedLeft, expectedRight, observedRight from the original branches and retained schedule. It deliberately ignores the Nary first-mismatch payload, which cannot supply the peer pair. Configuration and structural reasons preserve their constructor, participant and local failure. `toBinaryResult` preserves refused world/schedule or executed schedule/full machine. An arbitrary refusal projection is contextual, not an unconditional invertible mapping between the two error types; no false arbitrary-result round trip is claimed.

**The binary target is the actual accepted operator.** `existingBinaryAdmit`, `existingBinaryAdvance`, `existingBinaryContinue`, `existingBinaryPrefix` and `existingBinaryRun` directly call the real Interleaving definitions with unchanged boundaries, left/right branches and token list. The proof targets are not aliases of the Nary dispatcher. Boundaries retain branch and successful local index unchanged.

**Single-token and arbitrary-entry simulation have the right scope.** BinaryCorrespondence:167 `toBinary_advance` has arbitrary machine and token, without Reachable, Complete or supplied simulation premise. Its case split covers prior failure, exhaustion, actual executeStep error and actual success. The case lemmas preserve consumed increments, permanent first failure, world identity on skipped/refused selections, full successful result and peer state. `toBinary_continueRun` inducts over the schedule and remains valid for populated or synthetic entries. Machine round trips cover arbitrary binary entries as well. Prefix correspondence starts from the shared literal start state.

**Admission and complete results agree for all inputs.** The checkSchedule projection reconstructs both count pairs even when both mismatch. `analyzeAll_binary` preserves left-before-right structural analysis. `admit_correspondence` handles invalid catalog first, then both analyses, then counts; it does not stop analysis at the runnable prefix or require a complete schedule premise. Its auxiliary projection of success returns a pair only for the exact ordered two footprints. `admit_ok_projected` separately rules out the fallback branch on actual success. `toBinary_runNary` composes admission and full prefix equality, retains original schedule on both constructors, and has no desired full-result equality premise. `Complete_binary` establishes the count predicate specialization separately.

**Chunking preserves the same token sequence.** `continueRun_three_chunk` and `continueRun_chunk_assoc` apply existing arbitrary-entry append equations. They make no claim that opposite schedules or regrouped participant trees commute.

**The new runtime comparison is complete by source inspection.** It checks exact world/store, both full locals, all attempts, refusal reason, and retained schedule. Draft iff theorems connect each binary comparator to exact equality; the existing Nary machine iff theorem remains unchanged. These theorem bodies still need frozen compile and axiom evidence.

## Required completion evidence

1. Preserve these substantive theorem statements through compile repair. At freeze, provide source/snapshot/private hashes, successful fresh elaboration logs and imported axiom inventories for round trips, actual one-step/continuation/full-result simulation, count projection, admission and complete comparators. No circular premises may be introduced to close a tactic failure.
2. F03 runtime integration remains open. The insertion fragment must actually execute Interleaving and Nary through the shared Observation conversions, and retain the independent literal LR/RL full-result checks. It must exercise the both-count mismatch and retain all four original-input naturals. The accepted malformed-suffix admission case and arbitrary-prefix failure/exhaustion coverage must remain represented in final correspondence evidence; no boolean constant or private duplicate conversion can substitute for the actual runtime comparison.
3. Keep runtime code in allowed runtime roots and proofs in BinaryCorrespondence. The fragment must not import this proof-only module into Tests/Audit. After insertion, run the fresh integrated Audit and verify its complete unique nonempty inventory; the accepted 288 fixture-r2 results alone do not cover the new Observation block or binary comparisons.
4. Rebind the literal sixteen mutation anchors and execute their prescribed separate SPECs on the final integrated source. This preliminary read gives no production mutation credit.

These are the remaining accepted-contract gates, not new financial requirements. Full binary acceptance waits for the native author's freeze; this report does not label still-compiling draft code as a compiled API.
