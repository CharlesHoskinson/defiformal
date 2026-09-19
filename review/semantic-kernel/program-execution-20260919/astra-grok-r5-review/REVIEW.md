# Independent Grok R5 review

**Reject the production checker; accept the exact two-file arithmetic helper closure with limitations.** R5 does not close P19, P20, task 21.3, qualified certificate delivery, or P37. This is a scoped judgment on useful implementation, not rejection merely because the full campaign is unfinished.

Reviewer assignment: `gpt-6-astra`, medium reasoning, independent of native Grok `grok-4.6` / reported `grok-4.6-build`. This names the actual harness assignment; no additional provider telemetry is claimed. Root owns integration. No production repairs, commit, or push were performed.

## Scope accepted for integration

The exact source hashes in `verdict.json` authorize integration of:

- `lean/DefiKernel/Certificates/LibraryInstantiation.lean`
- `lean/DefiKernel/Certificates/TrustedHost.lean`

These files add genuine arithmetic work: extracting recipient pre-balance, request amount, and claimed/recomputed post-balance as Word64; executing accepted `Operations.add`; checking theorem/module/token metadata; and proving `addHolds_iff`, transfer-three credit/debit instances, and name-only refusal without a compiler record. They are independently usable without importing Delivered or routing a CLI. Their external direct imports, Schema and Arithmetic.Operations, match the current root workspace byte-for-byte. TrustedHost is accepted as static constants and token comparison functions, not as a verified build-attestation or host-inventory validator.

This approval does not authorize default-root changes, RunFixtures routing, a full certificate-discharge claim, or general transfer semantics. `extractTransferCredit` is a specific arithmetic projection; it is not a theorem proving that every selected registry operation is a transfer. The current soundness theorem connects `addHolds` to checked addition, but there is no complete theorem relating certificate acceptance, extraction, actual kernel result, and compiler evidence. The arithmetic source hash is currently correct; the validator does not enforce that fact against drift. Keep those distinctions in any integration description.

## Production blockers

`findings.json` contains exact locations, evidence, and repairs.

**The live CLI accepts a compatibility failure.** `cli-overlap.stdout` is an actual invocation of the frozen `RunFixtures.lean check` command, not a private checker copy. Two valid components each transfer USD 3 between alice and bob. The sequence executes successfully to alice 4/bob 6, while the recomputed compatibility outcome is false. The CLI emits `status: accepted`, `failure: null`, and `compositionCompatible: false`. Delivered.checkRun never gates acceptance on that outcome. This violates the frozen report-policy requirement that required reached families be true.

**Host evidence is still incompletely bound.** Isolated Python controls pass the intact inventory and refuse empty dependencies, but also pass missing/substituted library compiler inventories, modified Arithmetic.Operations source, and modified TrustedHost constants. The repaired validator checks required 11 paths and JSON metadata, yet never verifies the added library record or compiled host constants. These are realistic source/inventory drift controls, not a claim that the present addition theorem is false.

**Compatibility has a real boundary repair but an unresolved branch contract.** The actual adapter correctly returns false for two-component overlap. With a caller-relative transfer, preserving alice/vault step boundaries returns true; incorrectly reusing boundary 0 returns false. This confirms the R4 boundary bug is repaired. Repeated component 0 invocations still return true against an empty other branch; revoke-only returns notApplicable. That is consistent with the new comment, but the comment alone does not supply decoded branch semantics or a correspondence theorem for the required composition contract. The separate CompatibilityExamples domain exercises Parallel.admit, not the certificate adapter. Its exact conflict constructor was independently confirmed, despite its broader error predicate.

**Correspondence remains partial at named fields and branches.** New source guards and raw-to-report policy projections are valid statements. Typed raw success still omits receipt. Historical raw step success omits world/receipt/outputs; historical raw run covers outputs/index/cursorFailure only. The delivered run theorem assumes no kernel failure and omits receipt/cursorFailure. Full source guards and delivered step-error are missing; the inventory omits the required step-error mapping. Raw step-error also preserves payload.index while the frozen statement says nextIndex 0, which needs explicit reconciliation. The accepted universal codec roundtrip and canonical-byte inverse remain valid; this review does not reopen them.

**Codec/scenario evidence remains incomplete.** The Lean encode/decode positive check is useful, but is not the independent raw-input/expectedIR positive oracle and changed-IR comparator control requested after R4. S13/S14/S80 are honestly open. Full 54 fixture and 16-mutant campaigns were not rerun for R5; the review makes no R5 claim from inherited R4 campaigns.

Smaller report issues: a discharged library still appears in outstanding; an invalid audit_record reports compiler_record with a null payload. Neither invalidates the scoped arithmetic theorems.

## Verification

All 1438 frozen files match, as do the author 116 seal entries and 42 source entries. Frozen archive SHA256 is `64092ff16a945cc825cc076eecc0df01a27fc36e19ffa0fc7a65293604f20b2a`. Review used only the dedicated R5 sandbox and its private cache moved from the completed R4 review. No shared cache writer was used.

Fresh pinned `lake build DefiKernel.Certificates.Verify` exits 0, 955 jobs. The log marks the changed/new certificate modules Built and records 38/38 runtime checks true. Nonempty module-provenance axiom audits cover Certificates 2563 theorems+2991 supplemental declarations, Typed 457+824, Composition 287+408; forbidden 0 throughout. Independent helper audits cover LibraryInstantiation 19+45 and Arithmetic.Operations 36+3, also forbidden 0. Full inventories, including generated/private constants, remain in raw logs.

The author's `axioms-new-r5` exit 1 was not a forbidden-axiom finding: encode_decode_roundtrip is defined in Lexical, which that probe did not import. A corrected independent probe imports Lexical and checks all public theorem declarations from LibraryInstantiation and KernelCorrespondence plus both codec endpoints, exiting 0 with standard axioms only. The review's first targeted attempt reproduced the missing-import error; its file and failure are retained. The first adapter probe also failed because Parallel.Examples uses a different Party/Asset/Domain type; the corrected probe uses the actual certificate domain and passes. No partial output from those failed attempts is the sole evidence for a conclusion.

Production CLI controls independently confirm valid library discharge and wrong-toolchain refusal; direct Delivered controls cover wrong mathlib, compiler token, audit token, and module. Changing amount 3 to 4 while recomputing the true post-world still accepts, correctly demonstrating parameterized arithmetic rather than a fixture-only literal test. These bounded results supplement, rather than replace, universal proofs.

`record.py` records literal argv/cwd, start/end, exit, raw stdout/stderr and hashes for substantive runs. Preliminary read-only inspection and review-file construction are visible in the tool transcript but not individually recorded in commands.jsonl. All runtime/build/audit commands were terminal before sealing. `final-verification.json` records final source, seal, command-log, dependency-pin and executable identity checks; `MANIFEST.json` seals the completed review artifacts.
