# Existing regression replay at Sprint 6 source freeze

All seven existing regression commands passed against frozen source candidate
`7cb4807d1ff22c5ac804b03feb4a2530c46146f2`.
No source edits or new Parallel regression commands were performed by this task.

| Existing suite | Observed result |
| --- | --- |
| Sprint 4 typed source mutations | 24/24 detected; 189 complete comparisons per control/mutant; 3 protected positives per mutant |
| Sprint 5 composition source mutations | 12/12 detected; 93 complete comparisons per control/mutant; 6 protected positives per mutant |
| Composition runner controls | 36/36 actual CLI classifications passed |
| Typed runner controls | 17/17 actual CLI classifications passed |
| Kernel axiom-audit controls | 99/99 assertions passed |
| Typed compiler controls | One executed positive and three expected unit type errors |
| Corpus normalization controls | 20/20 tests; 76 real CLI invocations recorded |

These are bounded sensitivity and regression results. A compiler refusal in the
typing suite is classified as a type error, not a financial semantic detection.
Expected failure/setup cases in runner and corpus controls are retained in their
full logs; the encompassing harnesses verified their intended classifications.
The axiom-audit controls deliberately introduce forbidden dependencies in isolated
fixtures; those fixtures are outside the accepted Lean import closure.

## Identity and execution

`../regression-runs.json` records each exact command, working directory, start/end
UTC timestamp, observed Git HEAD, exit, duration, script hash and complete log hash.
All seven commands reported the frozen candidate HEAD at start and finish.
Each script's `--help` was executed and retained before its suite.
The existing Sprint 5 saved command arrays were reused with freshly allocated
outside output paths. At most three independent harnesses ran concurrently.

`source-binding.json` binds 106 tracked inputs to both SHA-256 and their exact
Git blob objects in the candidate. This scope includes tracked Lean/scripts,
corpus inputs and preserved lanes, the source plan, and both historical mutation
specifications. Before/after snapshots matched exactly. Tool identity includes
the actual Lean and Python versions, executable paths and executable SHA-256,
plus Git version. The individual suites also retain their own input/tool records.

The final independent saved-evidence inspection passed 93 assertions, including
exact mutation inventories, full unchanged/mutant comparison inventories,
designated false checks, protected positives, generated source fingerprints,
runner classification counts, axiom assertion outcomes, and typing/corpus results.
See `verify-results.py` and `verified-outcomes.json`.

## Artifact preservation

Full generated mutation sources, compiler fixtures, isolated runner fixtures,
individual stdout/stderr logs, source manifests and suite result records were
copied from the fresh external run directories into their corresponding folders.
The corpus suite deletes its own temporary fixture directories as part of normal
unittest teardown; its complete 76-invocation output and source bindings remain.

Two synthetic fixture repositories created by the historical runner-control
scripts contained nested `.git` directories. Their copied metadata was archived
as `fixture-repo/git-metadata.tar` before removing the copied nested `.git`
directories, to avoid adding embedded Git repositories to the evidence commit.
Every archived member's bytes were compared to the copied original first.
`git-metadata-archives.json` records archive and member hashes. Original external
run directories remain intact. Dependency-package and deliberate control symlinks
are preserved as links; their targets are recorded without traversing them.

`artifact-manifest.json` inventories the final browsable/archived evidence bytes
and symlink targets. Its hash is recorded in `../regression-runs.json`.
The replay harness source is retained as `run-all.py`; it is an execution record,
and its fixed destination should not be reused over accepted evidence.

Full Lean builds, new Parallel mutations and native acceptance review are separate
parent tasks. This report does not claim those gates passed.
