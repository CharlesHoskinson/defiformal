# P19 evidence reconciliation

This maps **all 99 scenarios in 37 requirements** to the correct evidence classes. Final update: the exact candidate is accepted for program20.1–20.4 in P19-ACCEPTANCE.md, supported by P19-FINAL-INDEPENDENT-RECONCILIATION.json. Frozen scenario/task text remains unchanged; P20 qualification is excluded. The historical gap analysis below is preserved where explicitly identified.

Evidence keys (paths below are relative to this directory unless stated):

- **P — planning/provenance:** `../program-execution-20260908/P19-PLANNING-ACCEPTANCE.md`, accepted official-r4 review, `S80-EVIDENCE-REUSE.md`, and frozen plan inventories under main `openspec/changes/serialized-kernel-certificates/`.
- **F — bounded fixtures:** `P19-FULL-FIXTURE-REVIEW.md`, `p19-current-full-fixtures/fixture-results.json`; this is historical adjusted54 evidence, not the final repaired runner. Final source review `p19-fixture-final-candidate/REVIEW.md` and actual `p19-final-main-fixtures/fixture-results.json` now supersede affected observations/reporting:54 accepted,54 controls,53 literal matches plus two F41 corrected companions, all children exit0. `P19-EncodeReport-unsupported-probe.json` verifies optional unsupported serialization.
- **C — codec:** `P19-CODEC-CONTROLS-ACCEPTANCE.md`, S14 accepted addendum/review, `astra-grok-r3-review/REVIEW.md` and its compiled contract probes; existing admitted-domain proof scope remains exactly as reviewed.
- **M — mutations/runtime/projection:** `P19-MUTATION-CAMPAIGN-REVIEW.md`, `P19-MUTATION-CAMPAIGN-RECONCILIATION.json`, `P19-MUTATION-SPEC-CHECK.json`, `astra-p19-mutation-runner-review/REVIEW.md`; actual16 source mutants,43 checks per intact/mutant, historical adverse controls.
- **K — kernel/policy:** `astra-focused-compatibility-review/REVIEW-DIAGNOSTIC.md`, unchanged accepted Correspondence/Soundness/KernelCorrespondence source and fresh dependent build recorded in `p19-assumptions-judgment-proof-check.json`. These do not themselves close P20.
- **H — host:** `astra-p19-host-review/REVIEW-ARTIFACT.md`, actual compiled-artifact/fake-tool discrimination and main validation receipts.
- **A — assumptions:** `P19-ASSUMPTIONS-CONTRACT-REVIEW.md`, `astra-p19-assumptions-review/REVIEW-JUDGMENT.md` and actual64/128-case report probes; integrated main regression/build.
- **T — resources/timeouts:** `p19-resource-controls/RESULTS.json`, input identities/raw stdout, `lean-timeout.json` plus stderr, and separately preserved version-timeout record. Existing43-check suite covers array4095/4096/4097 and depth63/64/65 classification.
- **I — source-bound inventories:** main `mutation-projection.json`, `planned-mutations.json`, `fixtures.json`, accepted runner snapshot and M manifests. See concrete checks below.
- **V — compiler audit:** current historical `p19-current-full-fixtures/compiler-axiom-audit.log`, source-bound scope records, five parser/empty-scope controls; reviewed Verify/root import; final main audit passed:2589/457/287 theorems,3056/824/408 supplemental declarations, forbidden0; see `P19-FINAL-MAIN-CHECKS.json`.

| Requirement | Scenarios | Evidence and limit |
|---|---|---|
| SF01 | S01, S02, S03, S04 | C,F: literal rational positives/negatives; F28 canonical companion preserves original negative. |
| SF02 | S05, S06, S07 | F,M: identifiers, negative IDs, capability revoke/issue observations. |
| SF03 | S08, S09, S10 | F,M: decoded catalog duplicates, repeated-delta and duplicate-ID behavior. |
| SF04 | S11, S12, S13 | C,F: unknown fields/duplicate keys; accepted canonical/permuted pair for S13. |
| SF05 | S14, S15, S16 | C,F: accepted S14 companion/addendum; empty/missing envelope failures. |
| SF06 | S17, S18 | F,M: supported step and unsupported Tree tag. |
| CC01 | S19, S20 | F,M: actual Args.check and changed-claim M01. |
| CC02 | S21, S22, S23 | F,M: exact state/env/write footprint constructors; reachable custom operations. |
| CC03 | S24, S25, S26 | F,M: actual authority, debit, revoked IDs and unaffected positives. |
| CC04 | S27, S28, S29 | F,M: accounting/funds, funded 32-cell transfer. |
| CC05 | S30, S31, S32 | F,M: catalog/executeStep/receipt/output observations. |
| CC06 | S33, S34, S35 | F,M: actor/unknown-operation precedence; exact distinct refusal constructors. |
| CC07 | S36, S37, S38 | F,M,A: theorem/tag/Prop non-evidence; outstanding retained. |
| RC01 | S39, S40 | C,M: full-IR positive roundtrip check for S39, malformed-no-kernel behavior for S40; no universal promotion. |
| RC02 | S41, S42 | F,K: bounded Typed/step/run observations and accepted conditional proof sources; P20 qualification remains separate. |
| RC03 | S43, S44 | F,K: exact errors and pre-world preservation; no fixture-as-universal claim. |
| RC04 | S45, S46 | F: independent literal 32-cell expectations and claimed-world mismatch; final truthful runner reviewed and current main campaign passed. |
| RC05 | S47, S48 | H,F: compiled host binding plus stale-source runtime refusal. |
| PB01 | S49, S50 | F,M: outstanding Prop/library obligations and discriminating M09/M10. |
| PB02 | S51, S52, S53 | F,A: declared trust; observation value use/missing observation refusal. |
| PB03 | S54, S55 | A: all64 subsets, actual report fields and six classes; S55 additive env-missing companion, originalF41 preserved. |
| PB04 | S56, S57 | F,H: outstanding source/library fields; do not count theorem-name tags as acceptance. |
| PB05 | S58, S59, S60 | V: actual three-scope audit and empty-scope controls; final integrated audit passed in all three nonempty scopes. |
| EV01 | S61, S62 | F,P: literal inventory and malformed/refusal siblings; final runner controls passed with explicit simulated-process test identity preserved. |
| EV02 | S63, S64, S65 | M,P: exact16 planned source edits, designatedfalse and protectedpositive; actual campaigns. |
| EV03 | S66, S67 | M,T: exact four-field SPEC gate; actual projected-Lean timeout exit3 and preserved blocked records. |
| EV05 | S68, S69, S70, S71, S72, S73, S74, S75, S81 | M,F,I: current nine-target projection inventory, F47–F54 bounded observations and intact projected controls. |
| SF07 | S76 | C,M: full defaultPayload IR equality and transfer constructor definitions, not report-only F25 comparison. |
| SF08 | S77 | F,T,M: raw lexical refusal, byte/depth/array blocked outcomes and actual timeout. |
| RC06 | S78, S79 | C,K: named admitted-domain codec proof + bounded kernel correspondence; S78/S79 not full P20 acceptance. |
| EV04 | S80 | P: author43, failed68 suite, independent71 CLI controls accurately attributed; satisfied bounded planning-control obligation. |
| RC07 | S82, S83, S84, S85, S86 | F,K,A: raw kernel/report separation, stale/mismatch/incomplete/step/run observations; universal qualification reserved. |
| EV06 | S87, S88, S89, S90 | F,M,I: live scoped grants, F47 invoke/debit, F18 matching unit, M09/M10 JudgmentOutcome constructors. |
| CC08 | S91, S92, S93, S94 | F,K: actual reached-stage accounting/funds/error policy and issue/revoke nonapplicability; bounded. |
| SF09 | S95, S96 | C,M: canonical compact bytes/nested key order, full-IR companion, accepted production encoder/decoder proofs. |
| SF10 | S97 | ExecutionAPI narrow public checkIR now implements DecodedExecution → Report; actual RunFixtures routes through its separate byte dispatcher. Static/routing compatibility proofs compiled and all11 checks passed. |
| PB06 | S98, S99 | I,M: exact four Prop allowlist pins, runtime-token guard, nine targets/consumer closure; all16 intact projected siblings. |

S39/S76 are not inferred from F25's report: main `lean/DefiKernel/Certificates/Tests.lean` defines `checkCanonicalPositiveRoundtrip`, constructs `.execution (.typed env defaultPayload)` from independent literals with canonical source_map, and tests **entire decoded IR equality**, including enumerations, registry/templates, store/request/state. `cert.codec.canonical-positive` is actually true in every reviewed43-check intact log. DefaultPayload is the funded transfer-three payload, and its transfer template carries the lit/arg/unary-neg/binary-le and caller/argument constructors. The accepted production codec theorem additionally proves exact inversion under its unchanged admitted-domain premise; that does not silently prove arbitrary DecodedIR or all P20 gates. Source-map companion values are named canonical test inputs, not a rewrite of frozen F25/F13.

Mutation snapshot reuse is justified, not re-dated: independently compared all30 captured source hashes with current main; only Check and Delivered differ. Their changes are the reviewed six-class membership/outcome repair. Actual runtime-check envelope inputs retain all six classes; mutations do not modify those assumptions. The one literal report with `assumptions := []` is the reportEq constructor test, not an envelope passed to the changed helper. Complete-class helper/outcome values are unchanged, mutation needles/replacements and Tests/Audit are unchanged, and the same kernel computations execute. Retain the old exact hashes and terminal times, add this dependency assessment and current complete-sibling/build evidence. Missing-class behavior is separately covered by A. This supports reuse without rerunning16 or pretending hashes are equal.

Inventory checks: mutation-projection has exactly nine existing targets; M03/M04/M08/M12 share Transition consumers including Execution/Sequence, and M06's designated F47/protected F27 pair matches the planned SPEC. M09/M10 replacements use JudgmentOutcome.true versus notApplicable, verified directly in planned-mutations. All four Execution/Sequence allowlist input hashes match current main; inspected declarations StepSound, ReceiptAuthorized, TraceSound and RefusalSound have sort Prop after their proof markers. Accepted runner blocks other runtime tokens and any altered allowlist-source hash, captures local consumers, and all16 actual projected intact siblings compile/execute. These are inventory/projection evidence for S81/S90/S98/S99, not unrelated F27/F33 passes.

EV04/task8.6 adjudication: **the literal original requirement is satisfied by the accurately attributed existing planning controls.** It requires author actual isolated intact/empty/missing/changed/spec-drift CLI runs, their records, failure on nondiscrimination, and preservation of synthetic history. It does not require a new successful author campaign on the final71-entry seal. `S80-EVIDENCE-REUSE.md` already verified the author43-entry eight-control record, the actual failed68-entry reseal suite (outer1), and independent71-entry ten-command controls. Use the43 record for authorship,68 failure for suite discrimination,71 review for final planning validation; preserve r1 synthetic history. No new author71 claim or waiver is needed.

Actual timeout: `p19-resource-controls/lean-timeout.json` records a projected Lean control command timing out after3 seconds, outer exit3, empty stdout and a TimeoutExpired blocked diagnostic (00:37:23–00:37:31 UTC on2026-09-20). It is blocked evidence, never mutant detection. The separate1-second version timeout is not substituted for this actual projected-Lean timeout. Prior14 historical controls were not themselves an observed timeout campaign.

Candidate task mapping: 1.1–1.3→P; 2.1–2.3/2.5–2.6→C/F/T plus SF10 disposition; 2.4→C's existing proof/bounded scope, full qualification reserved to P20; 3.1–3.5/4.1–4.4→F/M/K; 5.1–5.2→bounded K/F with universal P20 boundary; 5.3→H; 5.4→F and encoding probe; 6.1–6.3→F/A/H; 6.4→V; 7.1→F/P/I; 7.2–7.6→M/I/T; 8.1–8.2→final main1146-job build/V passed; 8.3→this mapping plus final54 receipts; 8.4→P19-ACCEPTANCE.md and exact38-input independent reconciliation; 8.5→subsequent authorized branch publication/readback (not falsely claimed complete by this review); 8.6→P as adjudicated above. Program20.1–20.4 are accepted in the explicit P19-only scope.

Historical pre-API finding (now resolved by reviewed ExecutionAPI): SF10 literally says `checkIR : DecodedExecution → Report`, whereas both main Check.checkIR and Delivered.checkIR have `DecodedIR → Outcome`; checkBytes calls them for audit/codec. They safely return separate sum constructors, so no promotion to an execution Report was found, but the stated API shape is not implemented. Resolve through an explicit narrow API-role correction/additive execution-only API while preserving existing theorem statements; do not silently label the literal signature satisfied. Apart from that narrow issue and the already active fixture-runner/integration work, this reconciliation identifies no additional P19 runtime defect. Do not import P20 compatibility/library/universal-delivery obligations into this P19 decision.

Historical proposed SF10 implementation (implemented in the separate ExecutionAPI module to preserve historical theorem dependencies): introduce `DefiKernel.Certificates.Delivered.Execution.checkIR : DecodedExecution → Report`, matching typed/step/run to the existing Delivered.checkTyped/checkStep/checkRun. The spec gives no fully qualified namespace requirement, so this public named execution-only entrypoint can be explicitly designated as its checkIR. Preserve historical Check.checkIR and Delivered.checkIR as compatibility sum dispatchers and preserve all theorem statements. Route Delivered.checkBytes's successfully decoded execution branch through `.execution (Execution.checkIR exec)`; audit/codec retain their separate outcomes. Add a short API-role note and focused type/routing checks. This is a concrete remaining source addition, not a waiver or demand to rename proof APIs; outputs should remain definitionally identical.

Final evidence reconciliation: fixture-only summary honestly leaves S13/S14/S80 open and labels96 entries bounded observations. S13/S14 close through the separately accepted source-bound codec companions and contract addendum; S80 closes through accurately attributed planning CLI controls. These are not99 universal theorem proofs. The old16-mutant snapshot is reused with the complete-assumption dependency assessment above; final API proves byte-for-byte outcome compatibility and leaves historical Check/Delivered unchanged. Final accepted runner/Encode/API changes do not alter the mutation targets or Tests/Audit checks. No historical run is re-dated. Root publication/readback is the remaining delivery action; P20 qualified semantic checker acceptance remains excluded.
