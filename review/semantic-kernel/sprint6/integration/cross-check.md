# Independent integrated evidence cross-check

All **73 assertions passed**. No hash, count, source-binding, or reporting discrepancy was found
within this inspected evidence scope. [cross-check.json](cross-check.json) contains each actual
assertion, input hashes, exact revision identities, findings, limits, and the checker source.

- All 10 integrated Lean commands exited zero. Their full log hashes match. The 49 recorded
  source hashes match the working tree and Git objects at `7cb4807` and `fae07ca`; the full `lean/`
  tree has no diff between those revisions.
- Runtime logs contain exactly 131 Parallel, 93 Composition, 189 Typed, 33 legacy and 43 contract
  comparisons, each inventory nonempty, unique and all true.
- Imported axiom logs contain exactly 388/419 Parallel, 328/583 Composition, 524/978 Typed and
  278/234 legacy theorem/supplemental declarations. Every listed dependency is standard; all
  reported denominators match actual unique records and forbidden counts are zero.
- All 388 elaborated proof rows match the proof inventory's names, modules, statements and
  axioms, and the fresh Verify theorem set. The 126 explicit source declarations resolve at
  their recorded lines: 88 generic, 35 reference and 3 counterexamples; 262 generated theorems
  remain separately classified.
- Preservation checks reproduce 165 original files, 32 protected kernel files and 435 tracked
  Lean files unchanged. The permitted 436th tracked Lean file is the import root, whose only
  change adds `import DefiKernel.Parallel.Verify`. All eight baseline log hashes/exits match.
- All seven legacy regression commands exited zero and 106 input SHA-256/Git-blob bindings
  match both revisions. All 778 packaged artifact hashes or symlink targets match, with no
  missing or unlisted payload files. Both archived Git metadata files and all 50 member hashes
  match without extracting them.
- Actual mutation logs reproduce 24 typed and 12 composition detections, 189/93 complete
  comparisons and 3/6 protected positives each. No compiler-only failure is counted. Saved
  runner classifications reproduce 36/36 and 17/17; axiom controls 99/99; typing controls one
  positive plus three exact type errors; corpus output 20 tests and 76 real CLI invocations.
  The saved post-verification report's 93 assertions and outcome counts reconcile.

This independently inspects saved executions and Git objects; it does not rerun Lean or the
regression harnesses. Expected control failures are not financial counterexamples. New Parallel
production mutations and native reviewer artifacts are outside this requested cross-check scope.
Compiler/tool authenticity and hash collision resistance remain assumptions. Native review,
final adjudication, source changes after this snapshot, and delivery still need their own evidence.
