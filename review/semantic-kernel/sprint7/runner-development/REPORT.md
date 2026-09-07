# Sprint 7 runner development

The final script bytes pass **52/52 actual CLI controls**: six accepted controls,
four correctly failed assertions (exit 1), and 42 correctly blocked checks (exit 3).
The complete real-Lean suite exited zero. These are synthetic development fixtures,
not production source mutation evidence or mathematical proofs.

## Inputs and evidence

- [Final command and exit](final-controls/invocation.json), [console](final-controls/cli.log),
  [full control summary](final-controls/summary.json), and [typed handoff](handoff.json).
- Runner SHA-256: `73033e6ee85a7d31255568489076c9ce044967022e40ce07cf8ecae7aa983c14`.
- Harness SHA-256: `74e8e7b7316d4fb5f3614fb0324d2ab62fde0f5d4f6dcc30942aaf4f8fb0d56d`.
- Source-repository HEAD observed by the harness: `f2744c37b3e86c275b36239b63ed2ca91bc27763`.
  The new scripts were development working-tree inputs; their exact byte hashes,
  rather than this HEAD alone, identify this measurement. Each isolated synthetic
  Lean input was committed in its own fixture repository before runner execution.
- Lean 4.33.0-rc2, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`;
  executable SHA-256 `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`. Python 3.14.4.
- Started `2026-09-07T06:50:25.097003+00:00`; finished `2026-09-07T06:51:39.567255+00:00`.
  Implementation used the inherited GPT-6 stock Codex task without Foreman.
  Separate provider identity telemetry was unavailable.

## Runner contract

The CLI accepts `--repo`, `--spec`, and a fresh external `--out`; optional
`--timeout-seconds` defaults to 600 per command. The schema remains version 1,
with `modules`, `mutations`, and `positive_checks`. The required audit root is
`DefiKernel.Interleaving.Audit`; mutation-site roots must be in the new namespace.
The harness additionally supports repeated `--case NAME` for focused controls.

The runner recursively captures the actual local import closure, including local
imports outside `DefiKernel`. It retains dependency proofs and removes only marked
Interleaving theorem tails from isolated execution copies. Ordinary runtime
`def`/`abbrev`/`opaque`/`instance`/type declarations after the boundary block.
The projection remains a bounded source-format adapter: ordinary unindented
single imports, an exact namespace closure, and a unique explicit proof boundary.
It is not a general Lean parser. Accepted source files are untouched.

Every mutation must edit its actual projected source exactly once. The unchanged
control establishes a nonempty unique runtime inventory with all designated and
protected labels present. Every mutant must execute exactly that inventory,
report its designated false comparisons and retain all protected true comparisons.
Compile errors, malformed logs, survivors and failed positives retain their distinct
blocked/failed classifications; compile failures are never mutation detections.

Captured Lean/config inputs must equal their recorded HEAD Git objects. Dirty and
staged byte mismatches block. After each Lean variant and at completion, the runner
checks source, specification, driver and HEAD drift. Integrity flags are refreshed
before reading inputs, so a later failure cannot retain an earlier variant's
success flag. Specification and driver bytes are hashed; their Git-object binding
remains a separate mandatory production-freeze obligation. External dependency
package trees are not independently byte-inventoried; installed tool executable
and project toolchain/lock identities are recorded.

The 600-second timeout increases the earlier runner's 240-second limit because
retained local dependency proofs can enlarge the projection. The synthetic suite's
longest Lean projection took 1.074191 seconds and longest
runner invocation took 3.866796 seconds. Those measurements do not
size the still-pending production projection. The harness allows 1500 seconds per
complete CLI case; production execution may use a measured larger explicit limit.

## Controls and development history

All 45 established Parallel runner controls were adapted to the new namespace.
Seven additions cover a non-kernel local dependency, dirty source, staged source,
source drift during control, source drift during mutant after a valid control,
specification drift during execution, and a runtime definition after the proof
boundary. Source/specification drift is caused by actual Lean IO in the isolated
fixture, exercising the real CLI rather than reproducing checker logic.

- `red-3`: dirty/staged inputs incorrectly accepted by the initial adapted runner.
- `red-2`: a late runtime definition incorrectly accepted. Its initial dirty/staged
  fixture placed a comment after the closure and hit a different diagnostic;
  those two records are retained but are not the source-binding red evidence.
- `red-4`: a local non-kernel dependency was omitted before capture was extended.
- `full-1`: first 23 cases passed; fixture setup then blocked because a redundant
  `git add` targeted the deliberately deleted manifest. The redundant add was
  removed, and `green-2` verifies that case and the local dependency control.
- `full-2`: 51/51 controls passed before the additional late-drift flag control.
- `red-5`: late drift returned exit 3 but retained a stale manifest success flag.
  `green-3` verifies its repair beside an accepted control.
- `final-controls`: all 52 controls pass on the final script hashes above.

Raw earlier failures are preserved as development history, not accepted production
results. Copies retain original absolute execution paths; synthetic repository
`.git`/`.lake` folders and the deliberately dangling output symlink are excluded.

## Remaining work

Task 7.4 runner controls are implemented and measured. Task 7.1's runner is
implemented; its unchanged *production* execution remains pending the parent's
source freeze. Parent work must bind actual Lean/spec/driver Git objects, execute
the fourteen production mutants, and obtain native Grok/Fable reviews plus full
integration evidence. No old runner, Lean source, mutation specification, commit,
or acceptance checkbox was changed by this subtask.
