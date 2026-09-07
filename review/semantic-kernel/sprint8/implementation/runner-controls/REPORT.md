# Atomic runner development controls

All **63/63 actual CLI controls passed**: 52 retained controls and 11 additional
proof-tail cases. Exit classifications: 9 accepted (0), 4 expected semantic
failures (1), 50 blocked inputs/executions (3). These are synthetic development
Lean fixtures, not the 18 production Atomic mutations or protocol evidence.

Actual command: `python3 scripts/test_atomic_mutation_runner.py --repo . --out /tmp/sprint8-atomic-runner-controls-r2`,
working directory `/home/charl/defiformal`, observed exit 0. UTC interval:
`2026-09-07T08:18:21.510212+00:00` to `2026-09-07T08:19:37.958830+00:00`. Source HEAD recorded by harness:
`80c56c48a322316b75b3928904526932d8d5be2c`. New scripts are not yet production Git-frozen.

Runner SHA-256: `ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007`.
Harness SHA-256: `df33373ddb7071d2268f809bc27bb0859db059b18539ff07ac55c54e953cefc5`.
Lean: `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`; executable SHA-256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`.
Full case commands, exact classifications/diagnostics, logs and source manifests
are retained here. Independent reconciliation checked 29 source manifests,
175 exact Git-object/SHA source bindings and 233 log hashes.

The first scope test failed against the existing Interleaving-only runner as
expected. The pre-fix Atomic adaptation then silently accepted six attributed or
command declarations after the proof marker; two valid siblings passed. The
scanner fix passed its focused 9-case rerun. All final controls include raw-string
and character-literal siblings and defeating attributed declarations. The scanner
masks nested comments and ordinary/raw strings/character literals before checking
known runtime declaration and command tokens. It is a bounded lexical guard:
arbitrary command macros defined before the marker still require source review.

Every accepted fixture executes a retained Atomic prefix that references an
imported dependency theorem: Interleaving in eight cases and SharedFixture in
the nonkernel case. The projection retains that theorem and strips only the
Atomic proof tail. All 52 established classifications and
specific diagnostics were checked against the previous harness inventory.

The first full attempt in `/tmp/sprint8-atomic-runner-controls-r1` was stopped after
Lean reported an incompatible mathlib olean header. Parent identified accidental
v4.33.1 dependency compilation and repaired the exact affected cache with pinned
v4.33.0-rc2. That attempt is preserved as environment-blocked and is not semantic
or runner-regression evidence. This successful run used a fresh directory.

Limits remain 600 seconds per runner Lean/Git command, 1500 seconds per harness
case, 60 seconds for identity/setup commands and 240 seconds for stale-dependency
fixture compilation. Production closure timing and 18 production mutations await
parent source freeze. Specification schema remains 1; roots must be Atomic and
include `DefiKernel.Atomic.Audit`. Audit emits unique `name: true|false` lines and
exactly `Atomic runtime comparisons failed: {failures}` on comparison failure.
Git binding of the final production spec/driver remains a separate freeze step.

The fixture repository and `.lake/packages` symlink are outside the source repo.
For repository evidence copying, exclude nested `.git` directories and symlinks;
`fixture-history.bundle` retains verified synthetic Git history. The artifact
inventory declares excluded paths. No original script, Lean or corpus file was
modified by this task. No commit or production mutation execution was performed.
