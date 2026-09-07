# Schedule and admission implementation handoff

Scope: `lean/DefiKernel/Interleaving/Schedule.lean` and `ScheduleTests.lean`.
Planning candidate `bf3fb509b211d7cd92eb68410fb49dc5f4e20e7d` passed both
required planning reviews before this implementation began. This report is an
implementation handoff by the stock GPT-6 agent, not an independent implementation
review. No Foreman, commit, root-import edit, task edit, or historical source edit
was performed by this agent.

## Implemented behavior

The API matches the agreed parent interface. `Schedule` is a list of branch IDs;
`Complete left right schedule` means the left and right occurrence counts equal
their static branch lengths. `checkSchedule` reports all four exact counts on
failure. Its return annotation fixes `PUnit` to `Type` to avoid universe
metavariables when clients compare an error result computationally.

Admission checks catalog validity, full left structural analysis, full right
structural analysis, and schedule counts in that order. It reuses the existing
branch analysis without invoking compatibility. Errors retain their branch and
local structural location. No world is passed to admission or updated by it.
Public execution's initial-world/empty-attempt refusal laws belong to the parent
Execution module, not this module.

Eighteen generic theorems prove exact success/error characterization, additive
count/length laws, empty and branch-head schedule laws, prefix count bounds, valid
next-slot bounds, admission extraction/reconstruction, admission recovery from
Parallel plus completeness, and admitted left/right invocation footprint
containment. `admit_ok` takes `cfg boundaries left right schedule lf rf h` and
returns catalog validity, left analysis, right analysis, then completeness.
`admit_of_parallel` takes the same objects followed by original admission and
completeness. `Complete.left_slot/right_slot` bound the branch-local count before
a selected token, useful for the parent's machine and recovery proofs.

Tasks 2.1 and 2.2 are implemented in this bounded scope. Task 2.3 has schedule and
admission lemmas available, but actual machine slot consumption and runner order
remain the parent's Soundness work. This report does not mark that whole task
complete prematurely.

## Actual verification

[Final verification](final/verification.json) records exact command arrays, source
hashes, UTC completion time, driver text and log hashes. All four commands exit 0:

1. Targeted Lake build of `DefiKernel.Interleaving.Schedule` and `ScheduleTests`:
   932 jobs, successful. Only existing Typed transition linter warnings remain.
2. A temporary Lean driver imports the real tests, rejects empty/duplicate names,
   prints every comparison and fails if any comparison is false: 24/24 unique
   comparisons true. It covers alternating/block/empty schedules, symmetric
   missing/excess counts, extra empty-branch tokens, both counts wrong,
   disjoint/shared admission, individually funded/authorized overlap controls,
   malformed unreachable suffixes on both sides, and all four precedence levels.
3. A temporary `#print axioms` driver checks the exact set of 18 named theorems:
   observed names equal the source theorem inventory; only `propext`,
   `Classical.choice`, and `Quot.sound` occur. This is named theorem checking,
   not the eventual automatic imported supplemental declaration audit.
4. Lean identity: version `4.33.0-rc2`, commit
   `d8b18978322de05a8f3dba51ef03cf5461676c17`, release build.

Final source hashes:

- Schedule: `a531621726138ef20d1b45edf8c680869a4e35bee4697cfc93d80c250e2b6ad9`.
- ScheduleTests: `e67ad6d37c49db6ef8f4f19fc805e56f1085b51751763d193556a4eef9286164`.

Both files remained byte-identical during final checks. LSP diagnostics on the
final Schedule source also report success with zero messages. The tests expose
`DefiKernel.Interleaving.ScheduleTests.checks` for the parent's combined audit;
there is no embedded runtime invocation to duplicate output during import.

## Initial checks and development corrections

The Lean4 skill was read and LSP tools were discovered and used first. Before
implementation, `lean_run_code` with
`import DefiKernel.Parallel.Compatibility` followed by
`#check DefiKernel.Interleaving.checkSchedule` returned `success: false`, with
`Unknown identifier DefiKernel.Interleaving.checkSchedule` at line 2. This was a
missing-feature check, not a behavioral counterexample or mutation detection.

Development diagnostics caught simplification issues in the exact-error proof,
an unconstrained `PUnit` universe in runtime error comparisons, and use of the
reserved token `prefix` as a binder. These were corrected and the final checks
above passed. One manual object-output attempt was blocked because its new output
directory did not exist; creating that build-artifact directory and using a
targeted Lake build fixed the setup. LSP also reported stale imports after a
manual object build; the targeted Lake build established normal import artifacts.
The first successful verification logs are retained one directory above `final/`;
a subsequent line-wrap fix prompted the final rerun. No failed compile or stale
import result was counted as a success or mutation detection.

## Remaining integration obligations

The parent must connect the 24 checks to its complete runtime inventory, prove
machine completion/order/refusal identity, run the automatic imported axiom audit,
execute source mutations 1 and 2 through the real scoped runner, and run the full
regression/native-review gates. No source mutant was executed in this subtask,
and targeted builds do not discharge the full Sprint 7 integration requirement.
