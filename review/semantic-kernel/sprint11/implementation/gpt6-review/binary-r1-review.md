# Binary r1 independent frozen-source review

**ACCEPT WITH LIMITATIONS for Observation's additive binary definitions and BinaryCorrespondence's proof layer.** No required semantic correction remains in these two frozen files. F03's direct runtime comparisons are not yet integrated or executed and remain a separate open gate. This verdict is not Sprint11 acceptance.

GPT-6 acted as nonauthor checker. Native author requested `grok-4.6`; the independently inspected terminal record identifies actual `grok-4.6-build`, session `01a07f17-ae7b-70e3-b83e-c496ce302adf`, stop reason `end_turn`. Both compressed and decompressed native-stream hashes match the parent identity record. This terminal evidence supplies the precise model identity that the author's in-process report could not provide; the report was not rewritten.

## Frozen inputs and checks

| Source | Bytes | SHA256 |
| --- | --- | --- |
| Observation.lean | 18,727 | `154ac0b69fa1a45197a7e9f435ce3ea472280101dcc1d1880df20f266c7316f0` |
| BinaryCorrespondence.lean | 28,726 | `167a3d2ada212e473dd0947b678b69ebb3a3c645fbf4f3cc15ceb9bc8d1fc462` |

These match both the author's manifest/snapshots and the exact draft bytes inspected in `binary-preliminary.md`. Removing only Observation's new executable binary block yields byte-for-byte the accepted core-r3 Observation file. Schedule, Execution and CausalRuntime still match their preserved core-r3 snapshots. Thus the prior detailed semantic read applies to this compiled candidate without an intervening source change.

The four saved final commands have status 0 and empty stderr: two Lake builds and two fresh source elaborations. Both build logs record successful completion. I independently ran only `lake env lean --stdin` in the authorized idle worktree `lean/` cache, using `binary-r1-introspection.lean.txt`; exit **0**, stderr empty, 19,452-byte stdout preserved untruncated. No build or feature edit was performed by this checker.

The command prints full `@` statements and imported axiom dependencies for 27 declarations: both attempt and machine round trips; generic and four-case advance; arbitrary continuation and prefix; three-chunk laws; Complete/count projection; ordered analysis and admission; full runner equality; complete machine/result iff comparators; and runtime agreement corollaries. All inventories are either empty or subsets of `propext`, `Classical.choice`, `Quot.sound`. There is no `sorryAx` or custom axiom in these theorem dependencies. This is a targeted inventory, not the final all-project axiom gate.

`binary-r1-inputs.json` binds the exact source/evidence/compiled inputs, 17 local source dependencies, command, stdin and stdout hash. All 83 captured inputs retained identical bytes and mtimes across the independent command. The capture excludes mutable Tests and other fixture-owned files. Full raw-stream JSON was parsed for terminal identity without displaying or treating tool output text as instructions.

## Substantive conclusions

**Complete conversion and observation.** Observation:108–140 directly preserves worlds and both complete local records, including consumed, nextIndex, outputs, located failures and raw events. Ordered attempt conversion preserves participant/branch, index, invocation, raw before world and full error/success outcome. Both-direction machine/attempt round trips are compiled for arbitrary values. No old lossy branch observation is used. Successful result conversion keeps full machine plus retained schedule; refusals retain world/schedule and project the reason. The binary and Nary full comparison iff theorems are compiled as exact equality, including the schedule and every stored field.

**Both mismatch counts come from the original inputs.** `projectBinaryCounts` / `projectScheduleMismatch_eq` recompute left/right expected lengths and observed token counts. They do not copy the first Nary mismatch as a fabricated binary payload. `checkSchedule_error_project` relates an actual Nary error to the actual Interleaving count checker. Both-mismatch inputs are covered without needing to recover lost peer information from the one-participant error.

**Actual accepted binary execution is the target.** The `existingBinary*` wrappers directly invoke Interleaving.admit/advance/continueRun/runPrefix/runInterleaving. Their source was checked against the actual accepted binary definitions during the draft review. The shared executable conversions live in allowed runtime Observation before its proof marker. BinaryCorrespondence is proof-only and is not needed by runtime callers.

**Arbitrary-entry simulation is noncircular.** Compiled `toBinary_advance` and `toBinary_continueRun` quantify over arbitrary machines and schedules with no Reachable, Complete, own-history validity or target simulation premise. Actual prior-failure, exhaustion, refused-call and successful-call cases retain the same machine fields and select the same boundaries/indices/history. The case-specific success/refusal equations are the actual `executeStep` outcomes; they are not assumed final-run conclusions. Round trips make the scope cover arbitrary binary entries as well as arbitrary converted Nary entries.

**Admission precedence and full results are preserved.** `analyzeAll_binary` states exact left-then-right structural analysis, including full branch suffixes. Invalid catalog is handled before analysis; counts follow both analyses. `admit_correspondence` preserves configuration/structural/count reasons; `admit_ok_projected` proves an actual successful ordered footprint list cannot use the projection fallback. `toBinary_runNary` then proves full equality to actual runInterleaving for every supplied schedule, without a completeness or assumed equality premise. `Complete_binary` independently identifies the two count predicates.

**Chunk equality keeps the identical token order.** The compiled three-chunk and parenthesization laws are generic over arbitrary `B` and arbitrary entry machine. They have no `Fintype B` requirement and do not identify conflicting schedules or regrouped participant trees.

## Remaining limits

The supplied `f03-insertion.lean` was inspected as a pending fragment, not accepted as executed code. It proposes independent malformed-suffix and failed/exhausted-prefix expectations, four exact mismatch naturals, and supplementary direct binary calls through the shared Observation helpers while preserving existing LR/RL literals. Fixture author integration, source binding and fresh full Audit evidence must close that gate. The accepted 288-comparison fixture-r2 run predates this integration and cannot supply those results.

Production mutation execution, final runtime closure/complete inventory, integrated fresh root checks and financial/causal instances remain separate gates. The source identity and proof acceptance here do not authorize relabeling draft fixture rows as executed evidence. No feature code, old review or author evidence was changed.
