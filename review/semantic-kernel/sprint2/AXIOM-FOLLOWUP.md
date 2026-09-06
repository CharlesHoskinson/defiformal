# Sprint 2 axiom audit follow-up: unused declarations

## R1 finding and isolated feasibility investigation

Frozen R1 candidate: `b1167bf496755d72137fa9f39410854796279c93`.
Fable's advisory finding identifies a real scope limitation: theorem-only discovery can
pass despite an unused custom axiom or a definition/opaque constant that depends on `sorryAx`.
AGENTS.md prohibits those constructs in accepted proof sources. The original documentation
accurately limited the audit to theorem constants; this follow-up strengthens the actual gate.

Before the parent authorized candidate edits, all experiments stayed under
`/tmp/defiformal-sprint2-axiom-followup`. `candidate-unchanged.json` confirms that AxiomAudit,
VerifyAxioms, and the replay script still matched R1 HEAD at the end of that investigation.
The parent subsequently authorized implementation while native Grok continued reviewing the
immutable R1 bundle. The source changes below therefore belong to a later R2 candidate.

The R1 reproduction imported a fixture with an independent clean theorem plus one extra
unused declaration. All fixtures compiled; compiler warnings from explicit sorry fixtures
were preserved. Results:

| Fixture declaration | R1 theorem-only audit | Temporary supplemental scan |
| --- | --- | --- |
| `def innocent : Nat := 0` | exit 0, 1/1 theorems | exit 0 |
| `axiom unusedSeed : Nat` | exit 0, 1/1 theorems | exit 1, exact `unusedSeed` axiom |
| `def unfinished : Nat := by sorry` | exit 0, 1/1 theorems | exit 1, exact `sorryAx` dependency |
| `opaque unfinished : Nat := by sorry` | exit 0, 1/1 theorems | exit 1, exact `sorryAx` dependency |

Exact inputs, commands, timing, outputs, and assertions are preserved under that temporary
directory in `reproduce.py`, `reproduction-results.json`, `*-source.lean`, `*-old.log`, and
`*-extended.log`. The helper bytes used were the R1 helper, copied before implementation.
The reproduction script was run at R1; running it against the corrected checkout is expected
to break its assertions that the old gap passes. Recover R1 helper bytes with
`git show b1167bf496755d72137fa9f39410854796279c93:lean/DefiKernel/AxiomAudit.lean`
when replaying that historical gap.

A temporary full-scope inspection found 230 `.defnInfo`, `.opaqueInfo`, and `.axiomInfo`
constants in the imported pilot modules, all with allowed dependencies. All eight original
AxiomAudit definitions passed. No metaprogram module exemption is necessary on this candidate.
`InspectDefinitions.lean`, `inspect-definitions-r2.log`, and `inspect-command-r2.json` record
that observation (exit 0, approximately 2.85 seconds).

A prototype inserted the supplemental command into a copied AxiomAudit module itself, so its
own new helper definitions were included. The full candidate still passed 278/278 original
theorems and 235/235 supplemental declarations in approximately 2.92 seconds. Evidence:
`full/DefiKernel/AxiomAudit.lean`, `full-prototype-audit.log`, and
`full-prototype-results.json`. Full pilot `.olean` files were copied into the temporary module
root to avoid Lean's first-prefix-directory import shadowing. Those experiments reuse the
already built candidate imports; they are not a fresh source build of the complete project.
A separate fresh invocation of unchanged R1 VerifyAxioms reported 278/278 in approximately
2.28 seconds (`baseline-current-audit.log` and its command JSON). Timings are single-run local
measurements, not a benchmark or performance guarantee.

## Authorized R2 implementation

Edited only:

- `lean/DefiKernel/AxiomAudit.lean`
- `scripts/test_kernel_axiom_audit.py`

No changes to VerifyAxioms, README, plans, or other parent-owned files; no commit.

`importedSupplemental` enumerates `.defnInfo`, `.opaqueInfo`, and `.axiomInfo` with the same
imported-module provenance/prefix rule used by the original theorem discovery. It includes
private and generated constants present in the environment and makes no module exemption.
Each supplemental declaration receives an exact name/module/kind/axiom report. Lean's official
transitive collector and the same three-axiom allowlist apply. An unused custom axiom is itself
an inspected constant, so its own name appears in the forbidden dependency set.

The original theorem report and denominator remain intact. Both categories are inspected
before final success. Any forbidden supplemental declaration causes its own specific diagnostic
and aggregate failure; the original theorem PASSED line is withheld in that case. A genuinely
empty supplemental category is disclosed as a zero count without claiming a vacuous 0/0 pass.
The existing requirement for nonempty imported theorem scope remains unchanged.

Diagnostics added:

- `AXIOM AUDIT declaration: <name>; module=<module>; kind=<kind>; axioms=<set>`
- `AXIOM AUDIT DECLARATION FORBIDDEN: <name>; kind=<kind>; axioms=<set>`
- `AXIOM AUDIT DECLARATIONS FAILED: <bad>/<total> supplemental declarations use forbidden axioms`
- `AXIOM AUDIT DECLARATIONS PASSED: <total>/<total> supplemental declarations; forbidden=0`

## Final verification and replay

From `/home/charl/defiformal`:

```sh
python3 scripts/test_kernel_axiom_audit.py --output /tmp/defiformal-sprint2-axiom-tests-r6
```

Exit 0: `passed: 99 assertions; evidence=/tmp/defiformal-sprint2-axiom-tests-r6`.
The script preserves all previous behavioral cases and adds a clean unused definition,
a clean opaque constant, an unused custom axiom, a sorry-dependent definition, and a
sorry-dependent opaque constant. It asserts exact declaration identity/kind/axiom diagnostics,
exact exit, preserved theorem reports, absence of unrelated compiler errors, and no theorem
success message on supplemental failure. The tests use the real copied helper and elaborate
imported Lean modules; there is no source-text declaration discovery.

All required source hashes are captured before execution, copied helper identity is checked,
and original inputs are asserted unchanged after execution. Git HEAD, per-input dirty status,
Lean executable hash/version, fixture bytes and hashes, commands/cwd/LEAN_PATH, and all output
are recorded in `results.json`. Repeat with a new output path outside the repository:

```sh
python3 scripts/test_kernel_axiom_audit.py --output /tmp/defiformal-axiom-r2-replay-NEW
```

The older r4 attempt caught a syntax error in the newly wrapped `throwError` message before
fixtures could run; its full compiler error remains in the r4 evidence directory. After that
correction r5 passed 98 assertions. R6 adds the explicit zero-supplemental-category behavior
and passes 99. R6 is the final acceptance record.

From `/home/charl/defiformal/lean`:

```sh
lake build DefiKernel.AxiomAudit
lake env lean --json DefiKernel/VerifyAxioms.lean
```

Both exit 0. `library-commands.json`, `helper-build.log`, and `integrated-audit.log` under the
r6 evidence directory record complete outputs and commands. The fresh audit took approximately
3.55 seconds and reported:

```text
AXIOM AUDIT DECLARATIONS PASSED: 234/234 supplemental declarations; forbidden=0
AXIOM AUDIT PASSED: 278/278 theorems; forbidden=0
```

The 234 count differs from the temporary prototype's 235 because final implementation uses
one supplemental discovery function within the existing command, rather than a second
elaborator command. The supplemental counts by imported module are:

- `DefiKernel.Audit`: 3 supplemental declarations.
- `DefiKernel.AxiomAudit`: 12 supplemental declarations.
- `DefiKernel.ContractAudit`: 1 supplemental declarations.
- `DefiKernel.ContractExamples`: 13 supplemental declarations.
- `DefiKernel.Contracts`: 34 supplemental declarations.
- `DefiKernel.Core`: 130 supplemental declarations.
- `DefiKernel.Examples`: 41 supplemental declarations.

`git diff --check -- lean/DefiKernel/AxiomAudit.lean scripts/test_kernel_axiom_audit.py` also
exited 0. Final replay source hashes, identical before and after:

- `lean/DefiKernel/AxiomAudit.lean`: `4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524`
- `lean/lean-toolchain`: `0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6`
- `lean/lake-manifest.json`: `8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002`
- `scripts/test_kernel_axiom_audit.py`: `b40c73684a40e0cadabf45c29e55e19861614a4e6ba975cacbf8f18d81966c5b`

## Limits and review accounting

This extends axiom auditing to the specified loaded declaration kinds. It is not a claim of
authenticated authority, capability lifecycle, complete proofchecker verification, or full
migration completion. Imported-module scope still excludes unimported files and current-module
declarations. Inductive/constructor/recursor constants are not separate supplemental roots,
though dependency traversal follows them when reached from the inspected declarations. Lean's
compiler, axiom collector, and loaded artifacts remain trusted. Parent owns the full project
build, final frozen revision, re-review, and documentation updates.

Fable's separate statement that both replay scripts reject repository-local output paths was
inaccurate for the contract mutation script. The axiom replay script has that guard; the
contract script did not at the time of review. Parent owns that recipe correction; this agent
made no contract-script edit.
