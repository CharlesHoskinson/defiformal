# Sprint11 proofs-r1

Requested worker: `grok-4.6`. Reported worker: `Grok 4.6` (session system identity). Checker assigned: `gpt-6-astra` (not executed in this task). No Foreman. No commit, push, archive, or self-acceptance.

Head: `ed94e6050d092e67f945df7b9762d3096ab0feda`.

## Owned sources

New proof-only modules under `DefiKernel.Nary`:

| Module | Path |
| --- | --- |
| Soundness | `lean/DefiKernel/Nary/Soundness.lean` |
| LocalOrder | `lean/DefiKernel/Nary/LocalOrder.lean` |
| Trace | `lean/DefiKernel/Nary/Trace.lean` |
| Completion | `lean/DefiKernel/Nary/Completion.lean` |
| Preservation | `lean/DefiKernel/Nary/Preservation.lean` |
| Interference | `lean/DefiKernel/Nary/Interference.lean` |

Hashes are in `hashes.json`. Each module has one `-- BEGIN PROOFS` marker. Source scan found no `sorry`, `native_decide`, or `axiom` token in owned files (`source-scan.txt`). That scan is not a Lean axiom audit.

Core runtime files were inspected and not edited: `Schedule.lean`, `Execution.lean`, `Observation.lean`, `CausalRuntime.lean`. Examples/Tests/Audit and root/config were not edited.

## What the proofs claim (authored)

`AdvanceSound` and `Reachable` are defined in core `Execution.lean`, and `advance_sound` / `runPrefix_reachable` / consumed / store lemmas are already proved there from the actual `advance` match. This lane does not redefine those constructors and does not assume a desired trace equality.

Owned modules add, for arbitrary `B` with `DecidableEq` (equality cases, not a fixed three-participant split):

- Attempt append equations: none / error / success, plus `AttemptSound` lifting.
- Active `nextIndex = min consumed branchlength`, `attempt_index`, complete active exhaustion.
- Full local history, event order, first-refusal stability.
- Fixed capability store (core `Reachable.store` plus `runPrefix_store`), signed successful receipt accounting, analyzed `analyzeAll` frames, nonnegativity.
- Generic initialized interference: all entry invariants, selected actual `executeStep = .ok` local preservation/guarantee, cross-inclusion and peer stability. Skip and refusal use world identity. Final invariants are conclusions, not premises.

`LocalObligation` quantifies an actual successful invocation equation, not `StepSound` and not a whole-run result.

## Compile

Not run by this worker. `review/semantic-kernel/sprint11/implementation/core-r1/BUILD-RELEASED.json` is absent, so lake commands in this cache were forbidden.

Observed (not owned): core-r1 recorded `exit=0` for `lake build` and `lake env lean` of Schedule, Execution, Observation, and CausalRuntime. Those logs do not elaborate the owned proof modules.

Pending compile tasks are listed in `compile-status.json`. Root should dispatch a compile/fix followup after core release.

PATH `lean --version` was `4.33.1`. Project toolchain is `leanprover/lean4:v4.33.0-rc2`. PATH lean was not used to elaborate these modules.

## Missing obligations

- Lean elaboration of all six owned modules; no proved-by-Lean status yet.
- Imported axiom inventory after elaboration.
- `InterfaceInstances` / F18 M2 total and global-binding instances (not this lane).
- `BinaryCorrespondence` and `Causal` proof modules (other lanes).
- Runtime fixtures, mutation production, and integrated Verify import (other lanes / later integration).
- Independent GPT-6 check of this implementation (assigned, not executed here).
