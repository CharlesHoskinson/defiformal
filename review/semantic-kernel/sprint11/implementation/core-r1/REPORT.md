# Sprint11 core-r1: finite-participant runtime foundation

Requested worker: `grok-4.6`. Reported worker: Grok 4.6.
Assigned checker: `gpt-6-astra`. This worker did not run that check.
Baseline HEAD: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
No Foreman. No commit, push, archive, or self-acceptance.

Owned files only: `lean/DefiKernel/Nary/{Schedule,Execution,Observation,CausalRuntime}.lean` and this evidence directory. Root imports, lake config, old modules, sealed planning bytes, and other Nary files were not edited.

## API implemented

Namespace `DefiKernel.Nary`. Signatures match `proposed-api.json`.

- Schedule: `Roster` (order/nodup/complete), `Branches`, `Boundaries`, `Schedule`, `ScheduleMismatch`, `AdmissionFailure`, `checkCountsFrom`, `checkSchedule`, `analyzeAll`, `admit`. Empty/singleton roster constructors. Catalog, then all-branch analysis in roster order, then counts. No `Fintype B`.
- Execution: `Attempt`, `Machine` (`locals : B → Interleaving.LocalState`), `Result`, `setLocal` (Boolean/equality update), `skip`/`refuse`/`accept`, real `executeStep` dispatch, `continueRun`/`runPrefix`/`runNary`, `failedAttempt`. Accept stores identity `storedReceipt := result.receipt` in the local event and the original result in the attempt.
- Observation: full `machineEq`/`resultEq` (world, every roster local including event before/world/receipt/outputs, full attempts, exact schedule and admission reason). `machineEq_iff` / `resultEq_iff` to exact equality via extensionality and proof irrelevance.
- CausalRuntime: `MonitorInput`, `advanceMonitored` with `post.attempts[pre.attempts.length]?` and `attempt := appended`, `continueMonitored` fold of the accumulated pair.

One `-- BEGIN PROOFS` marker per module. Executable and shared Prop declarations precede it. Runtime modules do not import later Nary proof helpers.

## Mutation anchors

All 16 planned needles occur exactly once in the runtime prefix. M13 and M15 share the unique `let appended := post.attempts[pre.attempts.length]?` line. No unavoidable changed anchors. See `needle-check.json`.

## Builds (actual)

CWD: `lean/`. LSP (`lean-language-server`) was not found; CLI fallback used.

| Command | Exit |
|---|---|
| `lake build DefiKernel.Nary.Schedule` | 0 |
| `lake build DefiKernel.Nary.Execution` | 0 |
| `lake build DefiKernel.Nary.Observation` | 0 |
| `lake build DefiKernel.Nary.CausalRuntime` | 0 |
| `lake env lean DefiKernel/Nary/Schedule.lean` | 0 |
| `lake env lean DefiKernel/Nary/Execution.lean` | 0 |
| `lake env lean DefiKernel/Nary/Observation.lean` | 0 |
| `lake env lean DefiKernel/Nary/CausalRuntime.lean` | 0 |

`lean4-skills-sorry-analyzer` on each owned file: `total_count: 0`.
No `sorry`, `native_decide`, custom `axiom`, `Fintype B`, or `noncomputable` runtime. Flexible-tactic lints remain on some proof `simp`s (same class as existing kernel modules).

Source hashes: `source-hashes.json`.

## Foundational lemmas included

Schedule: count mismatch iff, first-head error, `checkSchedule_ok_iff` ↔ `Complete`, catalog/analyze/count admission soundness and completeness, invalid-catalog and analyze-error precedence.
Execution: update-at/away, skip/refuse/accept world/attempts/unselected, `advance_sound`, `Reachable` for prefix continuation, consumed-count laws, capability-store preservation, admission-refusal identity.
Observation: `machineEq`/`resultEq` true iff exact equality.
CausalRuntime: monitor erasure to `advance`/`continueRun`, append/common-prefix fold, skip supplies none, refuse/accept append at `pre.attempts.length`.

Not proved here (not tractable in this pass, or owned later): `Complete.length` / roster count-sum, `analyzeAll_cons_ok` characterization, full event/history local-order, signed receipt accounting, binary correspondence, interference instances, funded causal witness.

## Outstanding (honest remainder)

This is the foundation task, not Sprint11.

- Examples/Tests/Audit/fixtures F01–F19 and named runtime checks are not this worker.
- Binary correspondence, interference, causal witness/negatives, mutation SPECs, inherited 65-control runner, root import, and axiom inventory remain.
- Independent GPT-6 check of this implementation is not done.
- `implementation_accepted` remains false.

Sibling untracked Nary files (`Examples`, `Tests`, `Soundness`, …) belong to other workers and were not edited.
