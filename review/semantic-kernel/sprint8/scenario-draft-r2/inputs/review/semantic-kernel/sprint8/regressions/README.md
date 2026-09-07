# Fresh Sprint 8 legacy regressions

All eleven requested legacy suites executed successfully against
`88aa4906102f2e304d1039d2e70942503ec9b341`. The run used at most three concurrent suite subprocesses,
new output paths below `/tmp/defiformal-sprint8-regressions-6k8xcda_`, and pinned Lean 4.33.0-rc2.
The nine previous command arrays were retained exactly except for their fresh
output paths; the Interleaving mutation and runner-control suites were added.
All eleven help commands were executed before their corresponding runs.

[Execution records](../regression-runs.json) retain commands, timestamps, exits,
source and executable identities, raw stdout/stderr hashes and copy manifests.
[Verified outcomes](verified-outcomes.json) pass all 2477 saved-evidence
assertions. The complete 147-file source binding matched frozen Git objects
and remained identical across execution. These results retain their actual
`88aa4906` identity if Atomic-only source changes follow; they are not relabeled
as newly executed results at a later revision.

| Suite | Verified fresh result |
| --- | --- |
| Typed mutations | 24 compiling mutants detected; 189 comparisons each; 3 protected positives |
| Composition mutations | 12 compiling mutants detected; 93 comparisons each; 6 protected positives |
| Parallel mutations | 14 compiling mutants detected; 131 comparisons each; 5 protected positives |
| Interleaving mutations | 14 compiling mutants detected; 116 comparisons each; 9 protected positives |
| Typed runner controls | 17/17 actual CLI classifications |
| Composition runner controls | 36/36 actual CLI classifications |
| Parallel runner controls | 45/45 actual CLI classifications |
| Interleaving runner controls | 52/52 actual CLI classifications |
| Axiom controls | 99/99 behavioral assertions |
| Typing controls | One compiled/executed positive and three expected compiler type errors |
| Corpus controls | 20 tests, including 76 observed CLI invocations |

Every control runtime inventory was nonempty, unique and entirely true. Each
mutation retained its complete inventory, its designated false comparisons and
all protected positives; its only Lean error was the expected runtime assertion.
The four runner-control suites' copied CLI logs match their recorded hashes.
Artifact copies preserve file/symlink identities. Four isolated fixture Git
metadata directories are saved as member-verified archives, with no embedded
repositories in the evidence directory. The pre-verification artifact manifest
contains 1963 entries; verification outputs and this report have
separate hashes in the execution record.

These are bounded mutation/control executions and compiler checks. They do not
establish a new generic mathematical theorem, deployed fidelity, the new Atomic
18-mutant result, native-review acceptance or sprint delivery. No old runtime log
was counted as a fresh run, and no source file or historical statement was edited
for this task. All eleven actual suite runs completed without blocked attempts.
