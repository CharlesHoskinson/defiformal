# P19 R2 mutation runner diagnostic

**DIAGNOSTIC_ONLY_NO_ACCEPTANCE**

Requested model: `grok-4.6` high. Reported model: `grok-4.6`. Fresh session, one auditor. Future full-candidate review remains a later fresh Grok pass, not historical GPT/Opus.

This is a bounded audit of `scripts/run_certificate_mutations.py`, `scripts/test_certificate_mutation_runner.py`, and the frozen R2 16-mutant campaign. It does not accept P19, the checker, 54 fixtures, or 99 scenarios. Root completeness findings on the encoder stub, incomplete full-report comparisons, hardcoded audit/comparator outcomes, and missing quantified proofs are taken as given and were not rediscovered.

Verdict: **bounded support with limitations**. The 16 stored discriminations are supported as historical 19-check evidence against frozen production bytes. The runner did not credit compilation failure, spoofed Git identity, missing/duplicate checks, no-op mutation, or a wrong production anchor in the probes run here.

## Identities verified

| Item | SHA256 / id |
|---|---|
| R2 archive | `e0d89571f3783199aa1b8b250ef88c1577308654d7b3cd97a55053899a9a9b7e` (1301 files, incomplete, unaccepted) |
| `inputs.json` | `4ac124b85071e3b70178b575be94a27dcdb9b5d58b108dde8d775c6567413490` |
| inputs.json file hashes | 1558/1558 matched sandbox bytes; 0 missing |
| mutation source bundle | `875707986fc294616ca2e19845812d638cabbbe2f39e816043ab74b3528a7614` |
| bundle HEAD | `a38f2b87bd412f3ad48c04f404fb2f5c4374c52c` |
| runner | `883a40b14c6f8857632b9eef5e54b1ceb37a441ad334a84a130fdf60b7c8c701` |
| harness | `e2bd8d6d14e1b4c27e61c4242d6d6dc1d93fa26e0c9a171e83adf4fb1a428946` |
| planned-mutations.json | `64f6d3321b1060a0560f7a4e85375108fb5ce2cd0fe836ac6167a2ba35ca31d0` |
| Lean | 4.33.0-rc2, commit `d8b18978322de05a8f3dba51ef03cf5461676c17` |
| `lake env which lean` | `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550` |

All 17 bound campaign inputs (Certificates Check/Schema/Decode/Audit/Tests/Observation, Typed Types/Expr/Authority/Transition, Composition Interfaces/Execution/Contracts/Sequence, toolchain/manifest/lakefile) match across sandbox production, stored mutant `inputs/`, and the auditor-private bundle clone. Git blob IDs recorded in M01's manifest resolve to the same bytes in the clone.

`git bundle verify` failed first (`need a repository to verify a bundle`). That attempt is preserved. Direct `git clone` of the supplied bundle into this output tree succeeded at HEAD `a38f2b87`. Lake packages were symlinked from the frozen sandbox cache only, not from `/tmp/p19-mirror` or the live author worktree. Historical absolute paths in R2 receipts were not reused as mutation targets.

## Scope of the 19 checks

`DefiKernel.Certificates.Tests.runtimeChecks` is a 19-element list. `Audit.main` prints those names and throws `Certificate runtime comparisons failed: N` when any are false. Specs name one protected positive each. The runner requires the full printed set to appear on both control and mutant.

This is **not** the accepted planning totals of 54 fixtures / 99 scenarios. A shared 19-boolean subset cannot prove full report projection, audit compiler discharge, or encoder roundtrip.

The 19 checks do call production entrypoints, not a duplicated substitute oracle: `checkTyped` (10), `checkStep` (7), `decodeRational` (2), `decodeStep` (1), `reportEq` (1). Generated fixtures inline the local Certificates/Typed/Composition closure, strip `-- BEGIN PROOFS` tails, and keep Mathlib/Lean imports external.

## 16-row reconciliation

Each stored record is a separate one-mutant spec. Control: exit 0, 19 true, no error lines. Mutant: exit 1, designated false observed, protected positive true, sole error suffix `Certificate runtime comparisons failed: N`. Needle count in production/clone/stored input/generated control is 1. Generated mutant is the control fixture with that one replacement.

| ID | Planned/actual module | Designated false | Protected | Extra false | Unique edit | Mutant exit | Re-run |
|---|---|---|---|---|---|---|---|
| M01 | Certificates.Check | cert.typing.recomputed | cert.transfer.alice7 | — | single needle | 1 | yes |
| M02 | Certificates.Check | cert.execute.recomputed | cert.typing.recomputed | — | single needle | 1 | static |
| M03 | Typed.Transition | cert.accounting.recomputed | cert.transfer.alice7 | — | single needle | 1 | static |
| M04 | Typed.Transition | cert.authority.debit | cert.transfer.alice7 | — | single needle | 1 | static |
| M05 | Composition.Interfaces | cert.catalog.nodup | cert.catalog.export-not-private | — | single needle | 1 | static |
| M06 | Composition.Interfaces | cert.access.reads | cert.step.alice7 | — | single needle | 1 | static |
| M07 | Certificates.Decode | cert.rational.canonical | cert.rational.zero-den | — | single needle | 1 | static |
| M08 | Typed.Transition | cert.precedence.actor-mismatch | cert.transfer.alice7 | — | single needle | 1 | static |
| M09 | Certificates.Check | cert.library.outstanding | cert.prop.not-executable | — | single needle | 1 | static |
| M10 | Certificates.Check | cert.prop.not-executable | cert.library.outstanding | — | single needle | 1 | static |
| M11 | Certificates.Observation | cert.refusal.constructor | cert.funds.insufficient | — | single needle | 1 | static |
| M12 | Typed.Transition | cert.transfer.alice7 | cert.accounting.recomputed | execute.recomputed, step.alice7 | single needle | 1 | static |
| M13 | Typed.Authority | cert.capability.fresh-id | cert.authority.debit | — | single needle | 1 | static |
| M14 | Composition.Interfaces | cert.catalog.export-not-private | cert.catalog.nodup | — | single needle | 1 | static |
| M15 | Typed.Expr | cert.env.missing-observation | cert.typing.recomputed | — | single needle | 1 | static |
| M16 | Certificates.Decode | cert.unsupported.rejected | cert.rational.canonical | — | single needle | 1 | yes |

Needles and replacements match accepted `planned-mutations.json`. Protected spec labels match planned `expected_protected_check`. Planned `protected_positive` fixture ids (F25, F15, …) are the planning names for those labels, not additional executed fixtures in this campaign.

M12 extra falses are expected: skipping effect application also drops alice7 on `checkStep`/`checkTyped` execute comparison. The designated transfer check is in the false set; accounting remains true.

M09/M10 change judgment-field tautologies (`notApplicable else notApplicable` → `true` on nonempty libraries/invariants). They are planned metadata/judgment mutations, still observed through `checkTyped`, not theorem-only edits.

M13 generated control fixture hash `971c3bcd…` differs from the other 15 (`64b6dd7c…`) because import capture visits Authority before Expr. Observations remain the same 19 trues.

## Independent re-execution

Auditor clone: `p19-mutation-evidence-grok-r1/clone/p19-r2-mutation-source` at `a38f2b87`. Runner invoked from frozen sandbox bytes. Outputs under this review tree only.

**M01** (Certificates.Check claimed-typeCorrect): exit 0 overall. Control fixture `64b6dd7c4ab5f4806725f13cc9abeedf4eeb10d685f29bd2c2bb207812e315dc`. Mutant fixture `984dfb97a177de5e5183d8bc82f2163f9539fd5ee4e1eee7e56e3ec94a919f44`. Both equal stored R2. Observations equal stored 19 lines. Mutant log SHA differs only on the absolute `.lean` path in the error line.

**M16** (Decode quiet-accept nary): same control fixture hash. Mutant fixture `4d2269c9144282ba69fbc413e0c2c9654bb23270ba4255f43b40586ea6872a89`, equal stored. Designated `cert.unsupported.rejected: false`; other 18 true. Historical attempt 1 (`unknown identifier 'rest'`) remains uncredited compile failure. Production `decodeStep` now binds `let rest := j` so `decodeInvoke rest` elaborates.

Generated M01 mutant contains `let typeCorrect := claimed.typeCorrect` at the live `checkTyped` site. Generated M16 mutant contains `| "treeJoin" | "naryAdvance" => decodeInvoke rest` at the live `decodeStep` site. Control files retain the planned needles.

## False-positive controls

Selected harness cases, all matched expected classification:

| Case | Expected | Observed |
|---|---|---|
| production-eval-discriminating-mutant | DISCRIMINATES exit 0 | matched |
| live-discriminating-mutant | DISCRIMINATES exit 0 | matched |
| all-true-mutant | FAIL exit 1 | matched |
| positive-control-flipped | FAIL exit 1 | matched |
| compilation-only-failure | BLOCKED exit 3 | matched |
| compiler-error-with-runtime-failure | BLOCKED exit 3 | matched |
| duplicate-observations | BLOCKED exit 3 | matched |
| duplicate-required-check | BLOCKED exit 3 | matched |
| missing-required-observation | BLOCKED exit 3 | matched |
| no-op-mutation | BLOCKED exit 3 | matched |
| missing-mutation-needle | BLOCKED exit 3 | matched |
| reserved-mutation-name | BLOCKED exit 3 | matched |
| mutation-module-outside-inventory | BLOCKED exit 3 | matched |
| dirty-source-before-run | BLOCKED exit 3 | matched |
| fresh-dependency-source-failure | BLOCKED exit 3 | matched |

Compilation-only-failure child log (independent of JSON `passed`):

```
error(lean.unknownIdentifier): Unknown identifier `runnerUndefinedConstant`
runner_positive: true
runner_sensitivity: true
```

Plausible true/true observations with a compile error were **not** credited. The runner requires the sole error line to be the runtime comparison throw.

Independent production wrong-anchor (M03 accounting needle on Decode): exit 3, `mutation did not apply exactly once`. No DISCRIMINATES line.

Git identity: dirty/staged source before run is BLOCKED (`input differs from frozen Git revision`). Fresh dependency source after a stale `.olean` is BLOCKED as control compilation/execution failure.

## What the runner will and will not credit

Credit (exit 0, prints DISCRIMINATES) requires: nonempty control with all printed comparisons true; mutant with the same check names; required false names actually false; protected positives still true; mutant process exit nonzero; exactly one Lean `error:` line ending in `Certificate runtime comparisons failed: N`.

Blocked (exit 3): compile errors, extra error lines, missing/duplicate observation names, needle not unique, no-op replacement, dirty Git blobs, missing audit root, malformed/duplicate JSON, output inside repo, runtime declarations after `-- BEGIN PROOFS` (except the four hashed Prop allowlist entries).

Fail (exit 1): control has false comparisons, mutant still all-true, required false not observed, protected positive flipped.

Timeouts become uncaught `TimeoutExpired` → exit 3. That is blocked, not credited. Child logs may be missing on timeout; this run had no timeouts.

## What can be carried vs what must rerun

Carry as historical R2 evidence: the 16 specs/results/generated fixtures, 17-file Git bindings at `a38f2b87`, runner/harness hashes, M16 attempt-1 compile-failure record, and this auditor's M01/M16 fixture hashes plus 19 observation lines.

Must rerun when R3 changes production bytes of Check, Decode, Tests, Audit, Observation, Typed runtime prefixes, Composition Interfaces/Execution/Contracts/Sequence, or the runner itself. New receipts must use a new clone and a new evidence directory. Do not write into `/tmp/p19-mirror` or the live author worktree.

Do not carry JSON `passed`/`discriminated: true` as proof without the generated fixture, log observations, and source hashes.

## Remaining repairs for R3

1. After encoder/`checkTyped`/Tests work, rerun each affected mutant as a separate one-mutant spec against the new production Git identity.
2. Keep this 19-check campaign labeled diagnostic. Do not treat it as 54-fixture or 99-scenario acceptance.
3. Keep a `rest`/payload binding in `decodeStep` so M16's planned replacement compiles. Compiler failure earns no detection credit.
4. Publish new mutation evidence under `agy-r3`. Leave R2 bytes frozen.
5. Do not treat control fixture SHA256 as a global constant (M13 order already differs).
6. Optional: add a production-module wrong-anchor case to the harness.
7. Encoder stub, incomplete 14-field comparator, hardcoded audit/comparator results, and quantified correspondence proofs remain required by root completeness. They are outside this diagnostic and still block full P19 acceptance.

## Unverified in this run

- M02–M15 were not re-executed. Support is unique-edit reconstruction plus stored logs/hashes.
- The full harness case list was not rerun.
- Mathlib package file hashes behind the sandbox `.lake/packages` symlink were not enumerated.
- 54 fixtures and 99 scenarios were not run.
- Live author worktree and `/tmp/p19-mirror` were listed as present and not entered.

Full P19 acceptance review remains required after a completed candidate. Root adjudicates and forwards required fixes to AGY at the next preserved boundary.
