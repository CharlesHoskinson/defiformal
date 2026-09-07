# Verdict: ACCEPT WITH LIMITATIONS

Reviewer: Claude Fable 5.1 (model ID `claude-fable-5-1`), native evidence review only. No tools were run and nothing here claims independent execution. Source candidate reviewed is `fae07caa2620c7a1d4ba1a39cb9a9be171ff137d`; Lean inputs are byte-identical to `7cb4807d1ff22c5ac804b03feb4a2530c46146f2`, and this review does not replace the earlier Lean proof audits.

## What I verified against the raw artifacts

**Mutant and comparison counts.** I recounted the control inventory from the four check generators. The totals below match the summary, the CLI log and the integrated audit log.

| Inventory | Count |
| --- | --- |
| CompatibilityTests | 42 |
| ObservationTests (14 direct + 10 receipt) | 24 |
| ExecutionTests | 6 |
| Tests (31 direct + 14 serial pairs) | 59 |
| Control total per variant | 131 |
| Variants executed (1 control + 14 mutants) | 15, so 1965 comparisons |

For every one of the 14 mutants I confirmed in `results.json` that each `required_false` name appears in `false_comparisons`, that all five protected positives read `true`, that the inventory keys equal the control keys, and that exit was 1. False counts match the report table (14, 9, 2, 14, 1, 9, 5, 20, 28, 20, 1, 1, 1, 26).

**Composite mutants.** Mutant 2's needle is exactly `(template.requiredStateReads ++ template.stateReads)`, so both read sources are removed together, and the funded siblings stay true. Mutant 4's needle is the shared `writes` list construction, which feeds both `reads ++ writes ++ ...` and the footprint `writes` field, so the target is removed from both. Mutant 1 removes all three guards, as the design record says it must because writes are also reads.

**Peer-history mutant.** The consumer `source (usd 0) 1` reads the peer's step-0 output, which is Pool USD after the peer transfer, value 5. The supplemental diagnostic shows the control refusing at local index 1 with Alice/Bob USD 7/3, and the mutant succeeding to index 2 with 2/8. That is a real USD 5 transfer, not merely an extra output entry. Both diagnostic base hashes equal the production control and mutant fixture hashes.

**Fail-closed runner controls.** The runner blocks on unapplied, non-unique or no-op edits before any Lean run; blocks on empty, duplicate, malformed, missing-positive and partial inventories; requires exactly one error line ending in the expected runtime failure for a mutant; and blocks when a compiler error appears beside a real false comparison. Compile-only failure cannot be counted. The stale-cache control compiles an `.olean` at value 4, changes source to 5, and the flattened projection correctly fails, which demonstrates that local cached oleans are not consulted. I recounted the 45 harness cases: 5 exit 0, 4 exit 1, 36 exit 3, matching the summary.

**Malformed-label fix.** The parser now exempts only two exact diagnostic prefixes. Any other non-observation line starting with a label-like token still blocks, so the fix errs toward blocking rather than acceptance. The uppercase, leading-dot and empty-segment controls still block, and the added warning control asserts both the linter warning and both continuation lines.

**Bindings.** All 30 executed inputs match `git show fae07ca:` objects, scoped status was empty, and captured bytes were unchanged after replay. The control log hash `b8d41e3b...` is identical to the integrated `parallel-audit.log` produced from the normal Lake build at 7cb4807. That byte-identity ties the flattened projection to the real module build. The 24 Lean inputs carry the same SHA-256 values in both `source-binding.json` and `git-object-binding.json`.

**Axiom audit implementation.** Discovery uses constant kinds and module provenance, not source text. `Name.isPrefixOf` is component-wise, so `DefiKernel.ParallelFoo` would not leak in. A custom `axiom` under the prefix would be classed `axiom` with itself in its transitive set and rejected; `sorryAx` and `Lean.ofReduceBool` are outside the allowlist. Empty theorem scope throws. The 388 theorem lines include generated equation and injectivity lemmas, so the 126 explicit theorems remain the meaningful number.

**Earlier evidence-visibility gap.** The issue/revoke compiler controls are now supplied: positive branch compiles cleanly, and both refusals fail with the expected `Step` versus `Invocation` type mismatch.

## Findings

- **[Low] Compiler controls not re-run at the frozen head.** `compatibility-evidence/runs.json` records head `2267e005`, a pre-freeze working tree. Mitigation: the two Lean sources they import hash to the frozen values, and `Branch` is an abbreviation for an invocation list, so the type refusal is structural. Re-run once at delivery for a clean binding.
- **[Low] Integrated `lake build` was incremental.** The build step finished in 0.67 seconds, so it verified an existing cache rather than performing a clean rebuild. Mitigation: Lake rebuilds on source hash change, and the flattened control reproduces the audit log byte for byte. A clean rebuild before delivery would close this.
- **[Low] Needle uniqueness is checked on the proof-stripped projection, not the accepted file.** Mutant 2's needle also occurs inside `analyzeInvocation_ok` after the proof marker. This is correct for the scratch fixture but should be stated in the runner documentation so nobody assumes uniqueness in the committed file.
- **[Low] Four mutants rest on a single failing comparison.** Reverse conflict, left boundary reuse, dropped peer supply and live capability store are each detected by exactly one oracle. The oracles are independent expected values, so the detections stand, but there is no redundancy.
- **[Low] Two mutants share one designated oracle.** Whole-world replacement and doubled balances both name `parallel.fixture.basic.complete`. Their failure signatures differ, and the doubling mutant uniquely fails the empty-branch checks, so the classes remain distinguishable.
- **[Low] Auxiliary checker sources not supplied.** The artifact-integrity script, the Git-binding script and the appended history diagnostic source were not in the bundle. I verified the primary `results.json`, manifests and logs directly, so this affects only the secondary assertion counts of 160 and 470.
- **[Low] "Only three new files at fae07ca" is not independently checkable here.** No diff listing was provided. I confirmed all 27 Lean and Lake inputs are byte-identical across both heads, which is what the mutation evidence needs.
- **[Low] Dependency packages are trusted through the manifest pin.** Mathlib oleans in `.lake/packages` are not hashed; only the Lean executable and `lake-manifest.json` are. This is the declared trusted-environment boundary.
- **[Low] Stale coverage labels.** `coverage.md` still marks S29, S31, S33, S34 and S35 as pending. That is correct today since no delivery is claimed, but it must be refreshed from the final artifacts without rewriting hash-bound logs.
- **[Info] Toy harness uses `run_cmd` while production uses `#eval`.** The runtime error suffix assertion was nevertheless exercised by fourteen real production mutants, and the production control matches the integrated audit output, so the driver difference is covered.

## Limits that remain in force

Bounded mutation sensitivity is not proof fidelity, holdout coverage or deployed fidelity. Proof suffixes are stripped only from scratch projections, so a mutant that would break a theorem is not detected through the proofs, only through runtime oracles. Serial references are admission-gated; `LocalPreservation` quantifies over invariant-satisfying pre-worlds under `StepSound` transitions; trusted boundary, environment, capability store authenticity and deployed correspondence stay assumptions. The first blocked production attempt contributes zero detections, and later replays re-detect the same 14 mutants rather than adding new ones.

## Recommendation

Accept the Sprint 6 mutation runner, production mutation results, runner controls, historical regressions, axiom-audit implementation and Git bindings as evidence, subject to the limitations above. Before delivery: re-run the issue/revoke compiler controls and a clean `lake build` at the final head, refresh the coverage map, and include the auxiliary checker scripts in the bundle. None of the findings is blocking.
