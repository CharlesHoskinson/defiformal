All65 actual CLI controls passed:52 retained,11 proof-tail controls,2 production-form `#eval` controls. Synthetic Lean fixtures are runner evidence only.

Command: `python3 scripts/test_atomic_mutation_runner.py --repo . --out /tmp/sprint8-atomic-runner-controls-r3`; cwd `/home/charl/defiformal`; exit0. UTC 2026-09-07T08:49:09.997136+00:00 to 2026-09-07T08:50:32.063961+00:00. HEAD88aa4906102f2e304d1039d2e70942503ec9b341; harness is an uncommitted revised input at this run, bound by SHAfab5b082d592cdc5cca5a84ab24ba386f4b647b172cab586c728452ff956c2ce. Runner SHAab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007 is unchanged.

The production-form fixture has the same `def main : IO Unit`, `#eval main`, `IO.userError`, unique nonempty inventory guards and numeric failure count as fixed production Audit. Accepted discrimination exits0; a designated observation that remains true exits1 despite a separate real false comparison. Both paths verify exact bare positive/sensitivity labels and one numeric error1 in actual pinned Lean output. No subprocess mock or expected-classification change was used.

Crosscheck: 31 manifests, 187 Git-object/SHA bindings, 247 log hashes. All original63 classifications retained. Limits remain600 seconds per runner command and1500 per harness case. Proof-tail scanner remains lexical; arbitrary earlier-defined command macro expansion needs source review.

Focused r1 blocked both cases because new fixture omitted the blank line required by existing proof-tail closure syntax. Focused r2 classified both exits correctly, but an added harness assertion incorrectly required an accepted probe result after the runner stopped at a failed designated-false assertion. The corrected assertion checks actual saved Lean output. Both attempts are retained as development failures, not accepted evidence. Original63-control evidence is preserved separately without modification.

No nested Git directory or symlink is copied. Verified fixture-history.bundle retains synthetic source history. The final source freeze and18 production mutants remain pending.
