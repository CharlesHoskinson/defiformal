# Frozen Interleaving runner controls

**52/52 real CLI controls passed**, exit 0, on source revision
`6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c`: six accepted controls (exit 0), four correctly failed assertions
(exit 1), and 42 correctly blocked checks (exit 3).

[Invocation](invocation.json), [console](cli.log), [complete summary](summary.json),
and [artifact cross-check](artifact-crosscheck.json) bind the exact commands,
log bytes, runner/harness/spec Git objects, tool identity and outcomes.
The test started `2026-09-07T07:08:09.886896+00:00` and finished `2026-09-07T07:10:16.274001+00:00`.
Runner SHA-256: `73033e6ee85a7d31255568489076c9ce044967022e40ce07cf8ecae7aa983c14`.
Harness SHA-256: `74e8e7b7316d4fb5f3614fb0324d2ab62fde0f5d4f6dcc30942aaf4f8fb0d56d`.

The production mutation specification is bound as freeze context; each CLI
control uses its separately recorded synthetic specification.

These controls use synthetic committed fixture repositories and real Lean
computations through the actual runner. They do not substitute for the separate
fourteen production source mutations. The inherited 45 cases and seven new
source/dependency/proof-boundary controls are all present, including dirty/staged
source, changes during actual control and mutant execution, specification drift,
and clearing stale integrity flags after a valid control.

All original output files are copied with their original absolute execution
paths. No nested `.git` directory or external/dangling symlink is copied.
[Excluded symlink targets](excluded-symlinks.json) preserve that setup metadata;
the full synthetic Git history is retained in
[fixture-history.bundle](fixture-history.bundle), with its real
[bundle verification](fixture-bundle-verification.json). Fixture source and the
stale compiled local dependency remain present for replay and inspection.
The installed external dependency package tree remains an identified tool input,
not a byte-copied or independently proved artifact.
