# P19 host/compiler evidence design and root empty-scope preparation

**HOST_BOUNDARY_DESIGN_ONLY_FULL_P19_OPEN**

Requested model: `grok-4.6` high. Independent auditor. Frozen sandbox only. No network, subagents, Foreman, publishing, primary mutation, live AGY author access, or shared cache. AGY parser/universal-codec work was not inspected.

This is a completed **preparation and host-boundary design** review. It is not full P19 implementation acceptance, not F44/F45/F46 acceptance, and not a fresh candidate review.

Frozen sandbox: `/home/charl/.cache/defiformal-program/program-execution-20260908/p19-host-boundary-grok-r1-sandbox`  
All 28 `inputs.json` hashes matched. Root-preparation manifest and `source-inputs.json` hashes matched the copied files. Planning fixtures remain 54. Audit fixtures are F44/F45/F46 only.

Pinned toolchain identity probe (`lean --version` only; no empty-scope rerun): `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`. Trampoline sha256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550` matches the receipt `compiler_sha256`.

## Verdict

**DESIGN_ACCEPTED_WITH_REQUIRED_BINDINGS.** Root preparation does not overclaim F46 or a production host. The empty-scope control is a recorded negative compiler observation with preserved first-attempt setup failure. It is not completed F46.

An explicit IO host **can** validate candidate/source/compiler/command/import/scopes and reuse exact matching evidence without violating pure `checkIR`/`rawExecute` or the no-ambient-registry/environment/config contract, **if and only if** discharge lives outside those pure functions and outside untrusted envelope fields.

The next AGY boundary repair must close the public audit success paths listed below. This review does not substitute for a later fresh candidate review of that repair.

`acceptance`: false. `whole_P19_accepted`: false. `F44_accepted`/`F45_accepted`/`F46_accepted`: false. `production_host_implemented`: false.

## What was read

Root preparation: `README.md`, `readiness.json`, `empty-scope-receipt.json`, `source-inputs.json`, `manifest.json`, `attempt1-setup-failure.json`, `audit-module-build.json` plus stdout/stderr, `empty-scope.stdout`/`stderr`, `empty-scope-attempt1.stdout`/`stderr`, `EmptyCertificatesScope.lean`.

Root context: `P19-PLANNING-ACCEPTANCE.md`, `p19-evidence-boundary-agy-queued-repair.txt`, both supplied root adjudications.

Frozen grammar/result/PB05/source/harness: `grammar.json`, `result-algebra.json`, `runtime-proof-boundary/spec.md`, `fixtures.json` F44–F46, `AxiomAudit.lean`, `Certificates/{Audit,Verify,Check,RunFixtures}.lean`, `scripts/run_certificate_fixtures.py`.

Static corroboration only: copied stdout matches `AxiomAudit.lean` empty-scope error text; attempt1 stdout is a missing `AxiomAudit.olean`; build stdout reports `Built DefiKernel.AxiomAudit`. This review did not rerun the compiler on the wrapper and does not fabricate a reproduced compiler result.

## 1. Explicit IO host versus the pure contract

Yes. Keep these **pure** and free of compiler IO:

- `decodeBytes`
- `rawExecute` (DecodedExecution only)
- `checkIR` / `checkTyped` / `checkStep` / `checkRun` (execution Reports)
- `checkAudit` as an untrusted document classifier

The accepted `no_ambient_inputs` ban is about payload registry/environment/config, not about a host that takes an explicit evidence object. Do not read `LEAN_PATH`, lake-manifest, ambient env, or a process-global compiler registry from Lean checker functions. Host evidence is an argument or an explicit file the caller supplies.

`SourcePin.compiler_record` and `audit_record` already exist and are null on frozen fixtures. Filling them in JSON does **not** authenticate. A standalone caller who supplies counts, command strings, prefix lists, or a record-shaped object must not obtain proof-discharge credit.

### Public audit success paths that must change

These frozen-R5 paths currently let a caller obtain an audit `passed` (or a campaign pass that includes S58) from supplied document fields, with at most a sidecar compiler scan:

1. `DefiKernel.Certificates.checkAudit` (`Check.lean` 751–766). `imported_theorems == some 0` → `blocked emptyScope`. Nonempty `forbidden_claimed_roots` → `passed` with `claimed_covered=false`. Else extract prefixes from `commands` / `auditPrefix` / default `DefiKernel` and return `passed`. `imported_theorems_min` is unused. No IO.
2. `checkIR` audit arm (`Check.lean` 768–774) and `checkBytes` (`776–780`). Grammar says audit IR SHALL NOT be passed to `checkIR`; the implementation still routes it. Do not repair this by adding IO to `checkIR`.
3. `checkCertificateBytes` aliases `checkBytes`.
4. `RunFixtures.lean` `check` mode prints `encodeOutcome` of `checkBytes`. A standalone `lake env lean --run … RunFixtures.lean check <audit.json>` is a public success path.
5. `scripts/run_certificate_fixtures.py` non-codec branch writes the F44/F45/F46 **document** and scores `deep_compare` against expected `passed`/`blocked`. F44 then attaches `compiler_audit_binding` as metadata. F45 is labelled `declared_root_list_inspection`. F46 is labelled `check_audit_empty_scope_refusal_negative_control`. Process exit also requires a global `Verify.lean` scan, but F44/F45/F46 fixture rows can still match from `checkAudit` JSON.
6. The global `lake env lean DefiKernel/Certificates/Verify.lean` plus `parse_and_validate_audit` is real campaign-level compiler evidence for **that** wrapper. It does not authenticate an arbitrary envelope. `which lean` is not a pinned identity. The five synthetic-string parser controls discriminate the log regex; they are not F44–F46 host controls.

A fixture-only check after the public driver has already returned an unauthenticated pass does not repair the driver. That is the current python architecture.

### Required layering

```
decodeBytes / checkAudit     untrusted classification
rawExecute / checkIR         pure execution (no audit IO)
hostCheckAudit(evidence)     only path that may emit discharged-pass/blocked-empty
```

Reuse: if the evidence object still matches the identity tuple in section 2, do not recompile and do not require signing. Recompilation is required only on mismatch, missing evidence, or compiler failure.

Honest contract amendment, without new grammar fields or failure constructors:

- Keep `AuditResult` constructors `passed | failed | blocked` and `empty_theorem_scope = blocked`.
- Record as an implementation interpretation (separate from frozen planning bytes): `AuditResult.passed` from `checkAudit` is classification of a request, not compiler discharge. S58/S59/S60 discharge is the host decision.
- Do not add envelope fields for “actual inventory”, “compiler_invoked”, or a new `AuditResult.discharged` unless a later reviewed overlay explicitly amends `result-algebra.json`.
- Optional later alignment: stop passing audit IR to `checkIR` so the implementation matches `checkIR_domain`. Not required to close the host hole, and not an IO change.

## 2. Minimal evidence identity and replay

Two environments. Never mix their inventories.

| | F44/F45 candidate | F46 empty wrapper |
|---|---|---|
| Wrapper | `lean/DefiKernel/Certificates/Verify.lean` sha256 `47ba130e824c224e37b63c590329486a6c642403f8e70a7874743a4dc0d53f16` on this snapshot | `EmptyCertificatesScope.lean` sha256 `c63063a793bde62dff5b614f70c275028955f613ba41c67897a9176c03657b75` |
| Imports | Audit, Correspondence, Soundness, Observation, Check, Decode, Schema, Tests, AxiomAudit | `AxiomAudit` alone |
| Commands | three `#audit_axioms` prefixes | one `#audit_axioms DefiKernel.Certificates` |
| Expected compiler observation | exit 0; each prefix `modules` nonempty; imported theorems > 0; forbidden = 0 | exit ≠ 0; `modules=[]`; `theorems=0`; blocked empty scope |
| Current module | Verify. `importedTheorems` uses `getModuleIdxFor?` and **excludes the current module**. Verify declares no theorems in the frozen file. | EmptyCertificatesScope. Likewise excluded. |

`AxiomAudit.lean` discovers `.thmInfo` constants whose **declaring module** is under the requested prefix. Supplemental defs/opaques/axioms are extra. Empty theorem scope throws before a `0 of 0` pass.

### Required interpretation of PB05 S58

Spec text says Certificates includes Correspondence/Soundness/Verify. Under declaring-module provenance, Verify as the **wrapper** will not appear in the imported theorem list. Correspondence and Soundness must appear as imported declaring modules under the Certificates prefix. Verify must appear as the **host wrapper identity** (path/hash/imports/commands), not as an imported theorem module. Record this interpretation explicitly. Do not add a grammar field to force Verify into `importedTheorems`. Do not invent a second wrapper that imports Verify solely to satisfy a literal reading.

### Identity tuple (reuse key)

Bind all of:

1. Wrapper source sha256 and resolved path.
2. `AxiomAudit.lean` sha256 (`4a8e330d…` on this snapshot).
3. Import-closure sources that can change discovered theorems for that wrapper (F44: Correspondence, Soundness, and other imported Certificates/Typed/Composition modules actually loaded; F46: AxiomAudit only). At implementation, hash the **final** candidate bytes, not only this frozen R5 copy.
4. Requested declaring-module prefixes and the exact command strings.
5. Pinned toolchain: `leanprover/lean4:v4.33.0-rc2`, version string with githash `d8b18978322de05a8f3dba51ef03cf5461676c17`, resolved `lake`/`lean` argv (not `which lean`). Receipt `compiler_sha256` is the 9024-byte trampoline; implementation should also pin `libleanshared.so` or treat the version-commit plus trampoline as the toolchain identity.
6. `cwd` / package identity (`lake-manifest` / `mathlib_rev` already on `SourcePin`).
7. Process exit, stdout sha256, stderr sha256.
8. Parsed per-scope: `modules=[…]` from `AXIOM AUDIT scope:` lines (do not assume PASSED-line order equals the scopes array), theorem count, forbidden count, and for F44 Certificates a check that Correspondence and Soundness occur as declaring modules.
9. Evidence class tag: `candidate-verify` or `empty-import-wrapper`.

Replay: if 1–6 still match current inputs and 7–8 are present, reuse. On any mismatch, missing file, or substituted class tag, refuse discharge and re-run or fail.

### Controls

**F44 positive.** Host must admit only evidence class `candidate-verify` with the three prefixes, exit 0, nonempty imported theorems each, forbidden 0, Correspondence/Soundness declaring-module provenance. Parser control: `checkAudit` on the F44 document may still extract those prefixes; that is **not** S58.

**F44 missing.** No evidence object / no wrapper path / no hash → no discharge.

**F44 stale.** Wrapper or import-closure hash ≠ bound hash → no discharge, even if counts still look right.

**F44 substituted candidate.** Empty-wrapper evidence, a different file with the same commands, or `compiler_record` JSON without file-backed hashes → no discharge.

**F44 substituted scope.** Commands/prefixes other than the three declared roots, or a Nary/Claims/Arithmetic inventory, → no discharge.

**F45.** Inspect the **candidate Verify environment’s actual claimed roots**: wrapper commands, observed imported module prefixes from the F44 evidence, and execution-envelope `audit_roots`. Forbidden `{DefiKernel.Nary, Claims, Arithmetic, Atomic}` must be absent. `checkAudit` on a caller-supplied `forbidden_claimed_roots` list remains a parser control (`passed`, `claimed_covered=false`). It does not prove those modules were not imported.

**F46.** Host must admit only evidence class `empty-import-wrapper`. Recorded root stdout is the shape: `modules=[]` and `AXIOM AUDIT BLOCKED: … theorems=0`. `checkAudit` on `imported_theorems: 0` remains a parser control of the classifier. A supplied 1 or 999 must not select a fabricated host result. Do not reuse the F44 nonempty inventory.

`imported_theorems_min` stays in the F44 document. If it remains, the host enforces it against the **actual** parsed count. Do not add a new field.

Do not use execution `FailurePath` constructors for audit. Do not treat timeout/`ResourceLimit` as semantic `passed`.

## 3. Root preparation: claims versus causal limits

Root does **not** claim completed F46, F44, F45, or a production host. `readiness.json` and the receipt both set those flags false. README states the control is one empty-scope observation and that Verify is a different nonempty environment.

Internally consistent recorded chain:

1. Attempt1 stdout: missing `AxiomAudit.olean` at the overlay probe-tree build path. `empty_scope_observed: false`.
2. `lake build DefiKernel.AxiomAudit --offline` exit 0, stdout sha256 `bacc3ace…`.
3. Second compile of `EmptyCertificatesScope.lean` via pinned `lake env lean`, exit 1, empty stderr, stdout sha256 `51b46697…` with `modules=[]` and `theorems=0`.

Static checks performed here: all of those files hash as recorded; the review-dir wrapper is the same 141-byte source; `AxiomAudit.lean` matches `audit_module_sha256`; trampoline sha256 and `--version` string match the receipt. Copied stdout text matches the current `AxiomAudit.lean` throw/log format.

Limits of the copied receipt (not a reproduction):

- No `.olean` or `.lake` cache is in the preparation package. This review cannot show which object file the compiler loaded.
- `argv` points at `p19-host-boundary-preparation/EmptyCertificatesScope.lean`; `cwd` is `p19-overlay-grok-r1/probes/lean-tree`. The sandbox copy hashes the same, but implementation must bind the **final** wrapper path in the candidate tree.
- `source-inputs.json` snapshot root is `p19-overlay-grok-r1-sandbox` (“frozen R5”). Live author source is separate. Do not treat these hashes as the eventual candidate.
- `compiler_sha256` is the 9024-byte `bin/lean` trampoline, not `libleanshared.so`.
- `attempt1-setup-failure.json` is a short classification; the stdout is the actual evidence.
- `audit-module-build.json` does not record compiler sha256 (the empty-scope receipt does).

How the actual final source must be bound during implementation: recompute the identity tuple on the repaired candidate; store wrapper/import-closure hashes from **that** tree; refuse stale R5 hashes if sources moved. This preparation is a negative-control template, not the F46 fixture artifact.

## 4. Author-ready acceptance checklist

Do not mark F44/F45/F46 or P19 accepted until a **fresh** candidate review sees this list exercised on final source.

### Architecture

- [ ] `decodeBytes`, `checkIR`, `rawExecute`, `checkAudit` remain pure. No compiler IO, no ambient registry/env/config.
- [ ] New host entrypoint takes an explicit evidence object (file or argument). Not `SourcePin.compiler_record` as self-attested truth.
- [ ] Every public audit success path in section 1 either stops advertising classification as discharge or gates on validated evidence **before** returning the success the caller consumes.
- [ ] `RunFixtures check` and python `deep_compare` against F44 `expected.status=passed` are not S58.
- [ ] Sidecar `compiler_audit_binding` after an unauthenticated pass is rejected as a repair.
- [ ] Matching evidence is reused by the identity tuple. No signing. No per-certificate recompile when the tuple still matches.
- [ ] Any API/result amendment is a separate reviewed note. Frozen planning bytes stay intact unless an explicit overlay is reviewed.
- [ ] Preserve 54 fixtures, 99 scenarios, 38 tasks, 16 mutants, and full Typed+Composition+Certificates core. Do not drop parser controls.

### F44

- [ ] Positive control uses the Verify wrapper environment, not the empty wrapper.
- [ ] Three prefixes, exit 0, nonempty imported theorems, forbidden 0.
- [ ] Correspondence and Soundness appear as imported declaring modules under Certificates.
- [ ] Verify is bound as wrapper identity, not required in `importedTheorems`.
- [ ] Missing, stale, substituted-candidate, and substituted-scope controls fail discharge.
- [ ] If `imported_theorems_min` remains, compare it to actual inventory.

### F45

- [ ] Covered-root inspection uses actual F44 candidate commands/modules/`audit_roots`.
- [ ] Nary/Claims/Arithmetic/Atomic are absent from that actual set.
- [ ] Caller-supplied `forbidden_claimed_roots` is labelled parser/list inspection, not compiler evidence.

### F46

- [ ] Separate empty-import wrapper (`import DefiKernel.AxiomAudit` only).
- [ ] Actual compiler blocked, `theorems=0`, `modules=[]`.
- [ ] Document field `imported_theorems: 0` is not the S60 observation.
- [ ] F44 inventory is never reused as F46.
- [ ] This preparation receipt is not accepted F46.

### Distinctions that must remain

- Pure classification ≠ validated host evidence ≠ library theorem instantiation ≠ source-refinement/deployed fidelity.
- PB04 library/source-map outstanding stays informational. An audit pass does not set `libraryTheoremsInstantiated` true and does not discharge source maps.
- Parser-only controls remain, labelled as such.
- Universal encode/decode theorem remains the separate AGY proof batch. Not restated here.

## Architectural cautions on root’s proposal

Root README is aligned with the accepted planning interpretation and with P19-EB-04/05. It is not a production design to reject.

Misread risks the author must not implement:

1. Treating “compiler record” as trusting `SourcePin.compiler_record` / `audit_record` JSON. Host must validate file-backed identities and logs.
2. Putting IO inside `checkAudit`/`checkIR`/`checkBytes` to “make every public path require evidence”. That violates the pure-API sentence in the same README. Change the **driver and any advertised audit CLI**, or add a distinct host function.
3. Using `parse_and_validate_audit` PASSED-line order as scope identity, or `which lean` as compiler identity.
4. Requiring Verify to appear in the imported theorem list.
5. Making supplemental-declaration nonempty a substitute for theorem nonempty. The empty wrapper blocks on theorems=0 first. F44 may have supplementals; do not invent a new constructor if they are empty.
6. Scoring S58 from F44 JSON `passed` while the global Verify scan only affects process exit.

No new unsupported grammar fields are required for this repair.

## Out of scope

Universal codec theorem; OV-01 decoded-IR equality; OV-02 overlay identity binding; P20 library/quantified correspondence; live R7 author source; full 54-fixture execution in this review; mutant campaigns; this review as final candidate acceptance.
