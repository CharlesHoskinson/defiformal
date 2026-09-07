# Sprint 8 accepted-source baseline

**PASS: all 12 fresh Lean commands succeeded before any Atomic implementation.** Actual execution revision throughout: `b0f9bbf3dbaab05c6c7918a28f23f607387a50fd`. Its 130 captured source/driver/corpus/specification inputs match their Git blobs and the accepted Sprint 7 proof source `bea105ec72e633a2dd66c663b96d0b552e1814a8`; all remained byte-identical before and after execution. Concurrent OpenSpec archive/documentation work was recorded separately and did not change these inputs. HEAD did not advance during the commands.

Execution ran from 2026-09-07T07:57:39.393373+00:00 through 2026-09-07T07:58:04.901847+00:00. `lake build` completed successfully with 1,050 jobs. The remaining eleven commands directly executed the established runtime and axiom roots. Their complete outputs also match the accepted Sprint 7 reference outputs exactly.

| Runtime scope | Executed true comparisons |
| --- | ---: |
| Interleaving | 116 |
| Parallel | 131 |
| Composition | 93 |
| Typed | 189 |
| Original kernel | 33 |
| Contract wrappers | 43 |

All five automatic proof audits passed with zero forbidden dependencies: Interleaving 262 theorems/271 supplemental declarations; Parallel 388/419; Composition 328/583; Typed 524/978; original kernel verification 278/234. These imported audit scopes overlap and are not additive counts of distinct declarations. Every observed axiom list contains only `propext`, `Classical.choice`, and `Quot.sound`.

Python regression suites were not rerun for this baseline. `legacy-python-carry.json` preserves the nine actual successful Sprint 7 executions at `6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c`, their original commands/log hashes, and checked current dependency identities. Typed/composition/Parallel mutation closures contain 13/18/27 unchanged files; typing and axiom controls retain their five/four inputs; corpus/normalizer inputs and isolated runner harnesses remain unchanged. Lean, Lake, Python and Git executable hashes also match those historical executions. The broad historical 128-file capture differs at `Interleaving/Verify.lean` only; that import root is outside the actual nine Python suite dependencies and was freshly executed here. No historical run is relabeled as fresh or as having the current HEAD.

`verify-baseline.py` passed 334 saved-evidence assertions, including nonempty exact runtime/proof inventories, full log hashes, actual source Git/current identities, source stability and relevant legacy-input equivalence. The exact command arrays, UTC times, per-command HEADs, complete separate stdout/stderr, tool versions/executable hashes, before/after source manifests and worktree-status observations are retained beside this report. The pinned compiler is Lean 4.33.0-rc2, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`.

This report closes the requested fresh-baseline check. It does not itself substitute for the independent planning verdicts or Sprint 7 accepted delivery gate. No Atomic files, existing source edits, provider calls, Foreman run or commit were made by this baseline agent.
