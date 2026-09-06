# Sprint 2 Task 2: automatic axiom audit

Implemented with native Codex GPT-6; no Foreman or external reviewer invocation in this subtask.
Parent owns integration and native Grok/Fable review. No commit made by this agent.
Observed repository HEAD during replay: `95c1360709b6df4c85bcb32876a8e85b82036f57`. Implementation files were uncommitted;
`results.json` records the exact per-input dirty status. HEAD alone does not identify these new bytes.

## Files and mechanism

- `lean/DefiKernel/AxiomAudit.lean`: generic command `#audit_axioms DefiKernel`.
  Imports Lean command elaboration and Lean's official axiom collector, no pilot or contract imports.
- `lean/DefiKernel/VerifyAxioms.lean`: imports historical Audit and the generic helper;
  invokes the command. Parent adds ContractAudit after its implementation is available.
- `scripts/test_kernel_axiom_audit.py`: bounded replay of the real helper source, copied to an
  isolated directory outside the repository. No accepted library imports any negative fixture.

`Environment.constants.fold` inspects `.thmInfo` declarations. `getModuleIdxFor?` and
`Environment.header.moduleNames` determine provenance. A `Name.isPrefixOf` comparison selects
imported modules under the command's module prefix. The theorem name's namespace is irrelevant.
All discovered theorem constants, including generated equation/proof helpers and private
constants present in the imported environment, are included and sorted with `Name.lt`.
For each, `Lean.collectAxioms` reports exact transitive dependencies, also sorted by Lean.
The allowlist is exactly `propext`, `Classical.choice`, `Quot.sound`. Every other dependency
is rejected. The command reports all discovered theorems before the aggregate failure.
A zero-theorem scope throws an explicit BLOCKED diagnostic.

Pinned API source inspected locally:
`/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/src/lean/Lean/Environment.lean`
and `Lean/Util/CollectAxioms.lean` under the same `src/lean` directory.
The collector reads checked constants and the exported axiom extension for imported declarations;
this uses the installed Lean implementation rather than a custom dependency traversal.

## Verified commands and observed output

From `/home/charl/defiformal`:

```sh
python3 scripts/test_kernel_axiom_audit.py --output /tmp/defiformal-sprint2-axiom-tests-r3
```

Exit 0; `passed: 57 assertions; evidence=/tmp/defiformal-sprint2-axiom-tests-r3`.
This is seven behavioral audit invocations plus fixture compilation and evidence checks.

| Run | Lean exit | Required observed result |
| --- | --- | --- |
| control | 0 | Exact `OutsidePilotNamespace.control` theorem from `DefiKernel.AuditProbe`, axioms `[]`; 1/1 pass |
| added | 0 | Appended `AnotherNamespace.freshlyAdded` automatically included; 2/2 pass; audit command bytes identical to control |
| transitive-control | 0 | Theorem through `ForeignAssumptions.helper`, axiom-free; 1/1 pass |
| custom-axiom | 1 | Exact forbidden `ForeignAssumptions.seed` dependency on `OutsidePilotNamespace.transitive`; 1/1 rejected |
| sorry-axiom | 1 | Exact forbidden `sorryAx` dependency on the same theorem; 1/1 rejected |
| empty | 1 | Imported `DefiKernel.AuditProbe` contains no theorem constants; exact BLOCKED empty-scope diagnostic, no success |
| missing | 1 | No imported module matches `UnimportedPilot`; exact BLOCKED empty-scope diagnostic, no success |

The custom and sorry dependency paths cross an imported module and a proof-valued definition.
Negative fixtures compile to `.olean` successfully first. Tests then assert the actual command's
specific diagnostic and exit, and reject unrelated compilation errors as evidence of axiom detection.
The fixtures also show that selection follows module provenance rather than theorem namespaces.

Fresh library checks, from `/home/charl/defiformal/lean`:

```sh
lake build DefiKernel.AxiomAudit
lake env lean --json DefiKernel/VerifyAxioms.lean
```

Both exit 0. The helper build reports 2 jobs. Fresh audit reports
`AXIOM AUDIT PASSED: 150/150 theorems; forbidden=0` before contract integration.
Imported scope is `DefiKernel.Core`, `DefiKernel.Examples`, `DefiKernel.Acceptance`,
`DefiKernel.Audit`, and `DefiKernel.AxiomAudit`. Counts by provenance:

- `DefiKernel.Acceptance`: 74 theorem constants.
- `DefiKernel.Core`: 58 theorem constants.
- `DefiKernel.Examples`: 18 theorem constants.

Every name and exact axiom set is in `library-audit.log`; the count exceeds the historical 51 named
manual disclosures because automatic coverage includes generated theorem constants. This count
is an observation at these inputs, not a hardcoded acceptance threshold.

## Evidence and replay

Evidence directory: `/tmp/defiformal-sprint2-axiom-tests-r3`.

- `results.json`: each assertion, every fixture command with absolute executable/cwd/LEAN_PATH,
  exit, complete output log location, source hashes before and after, copied fixture hashes,
  Git HEAD, per-input dirty state, executable SHA-256.
- `lean-version.log`: Lean 4.33.0-rc2, commit
  `d8b18978322de05a8f3dba51ef03cf5461676c17`, x86_64 Linux Release.
- `control.log`, `added.log`, `transitive-control.log`, `custom-axiom.log`, `sorry-axiom.log`,
  `empty.log`, `missing.log`: full JSON diagnostics, untruncated.
- `*-source.lean`, `*-dependency.lean`, and per-run `.lean` files: exact fixture variants.
  `fixtures/DefiKernel/AxiomAudit.lean` is the byte-identical helper copy.
- `library-commands.json`, `library-helper-build.log`, `library-audit.log`: independent fresh
  old-pilot commands with exact exits and full output.

Replay from a checkout containing the implementation, with its pinned Lean installed:

```sh
python3 scripts/test_kernel_axiom_audit.py --output /tmp/defiformal-axiom-replay-NEW
```

Use a new output directory; the script refuses existing outputs and repository-local outputs.
The replay regenerates fixtures in order, recompiles the copied real helper and each imported
module with the pinned Lean binary, and captures all output. Its isolated `LEAN_PATH` contains
only the fixture directory; Lean's built-in libraries are resolved by its own installation.
No project `.olean` is reused for the fixture helper. No theorem declaration source parsing occurs.
The driver reads helper/script/toolchain/manifest SHA-256 before copying/running, checks helper
copy identity, and asserts those inputs remain unchanged after execution. VerifyAxioms is not a
fixture input and is excluded so independent parent integration cannot misbind the replay.

Inputs captured before execution, unchanged afterward:

- `lean/DefiKernel/AxiomAudit.lean`: `4a3aff3e534cbacffcba3bb45e1af6c068a9ccfddd8c021afc32e7fadeee8cd7`
- `lean/lean-toolchain`: `0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6`
- `lean/lake-manifest.json`: `8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002`
- `scripts/test_kernel_axiom_audit.py`: `0b6960ea4c97f227d2b98d5f4e5857b034c91db5352fe26ed3918e1c29df4bde`

Development evidence retained separately: the initial driver run in
`/tmp/defiformal-sprint2-axiom-tests` failed its success-diagnostic assertion because Lean's JSON
severity is `information`, not `info`; the parser expectation was corrected. The r2 run passed
50 behavioral/setup assertions. R3 adds pre-execution source binding and records 57 passed
assertions. These earlier runs are not the final acceptance record.

## Scope and limitations

- Imported pilot module prefix only. Unimported files are not discovered, current-module
  declarations are excluded, and later declarations are not covered. Keep theorem sources
  in imported modules; VerifyAxioms itself is the audit entrypoint, not a theorem library.
- Scope includes imported theorem constants available in Lean's environment, including private
  and generated ones there. It is not a filesystem theorem inventory or proof-source linter.
- Axiom audit targets `.thmInfo` declarations. Unused custom axiom declarations or proof-valued
  definitions are not independently enumerated, but any such dependency reachable from an
  inspected theorem is collected transitively and rejected.
- Lean's compiler and imported `.olean` artifacts are trusted. Fresh library audit against stale
  imports is insufficient for changed cross-file source; parent must rebuild before final audit.
- Lean command failures use process exit 1 for both forbidden axioms and empty scope; distinct
  `FORBIDDEN`/`FAILED` versus `BLOCKED` diagnostics disambiguate them. No claim of Lean exit 3.
- This is axiom disclosure/rejection, not a mathematical proof of the metaprogram, financial
  validity, or complete migration. Full project build, contract imports, integrated final counts,
  source freeze, external review, and publication remain parent responsibilities.
