# Sprint10 planning input readiness

The accepted Sprint9 dependency is bound: source eec499d613688137a341f3556cd80ca461dd2ee9,
source/evidence ec9ed80457d7a9c4064d26ab193591579027abae, archive/verified remote
9908d9b56be2d5ed2b58a16fa8d28b23f33733ff. Later checkpoint c168329 records delivery
metadata; it does not replace those identities. The exact root-owned remote
readback is retained separately. No pending Sprint9 acceptance claim remains in
these current S10 planning inputs.

The plan/wiki now agree on4 capabilities,17 requirements,57 scenarios,34 unchecked
tasks,20 fixture contracts,14 planned source mutations and65 inherited controls.
F07 includes the initialized two-op102 recursive-group companion with independent
5/5/0 →4/4/2 →3/3/4 cursors and prefix queries; F16 remains arbitrary-entry total/
history evidence, not initialized A=B. F19/F20 peer continuation and failed-suffix
skip remain explicit. All expected cases remain planned, not executed M2 results.

Fresh strict OpenSpec and author validation pass. The dependency checker passes
359 checks:116 integrated source files equal the accepted source, archive and
current checkpoint;16 actual Lean commands,14 mutations and65 controls retain
eec execution identity. Thirteen historical suites retain c880 identity, with
independently checked declared source/tool closure equality and actual log hashes.
No suite is relabelled as freshly run. Scope and caveats survive in the complete
`dependency-baseline.json`; `dependency-review.json` omits mechanical check labels
and repeated invocation metadata while preserving commands/results/closures/tools
and hashes of all referenced originals. Historical test limitations remain.

The predecessor runner enforces two global positives. Its14 per-mutant siblings
were separately measured in execution-evidence reconciliation. The planned S10
contract requires each sibling to remain true and keeps those obligations distinct
from the schema-level global positives. The65-case adaptation lists are unexecuted
S10 contracts; their actual S9 predecessor executions are completed and bound.

`build-planning-bundle.py --plan` checks the input list and strict1.4MB size limit
without an official freeze. After root commits the inputs, run it with
`--candidate FULL_SHA --label r1`. The builder requires every input to equal that
commit, expands all repository-local imports of selected relevant source roots,
retains every source verbatim, compacts JSON with separate original/rendered hashes,
checks repeat rendering equality and source stability, and refuses to overwrite a
prior bundle. Large retained baseline logs and mechanical assertion labels remain
exactly reference-bound rather than duplicated in the planning prompt.

The next gate is nonauthor stock GPT-6 plus native Fable5.1 medium on that same
candidate/bundle. Request `claude-fable-5-1[1m]` with `--effort medium`, recording the
actual returned model. This author preparation performs no native review, M2
implementation, source mutation, commit or delivery. Root alone freezes/commits.
Earlier provisional reports/wiki bytes are retained under `before/` and their
separate prior refresh directories; those historical statuses are not current gates.
