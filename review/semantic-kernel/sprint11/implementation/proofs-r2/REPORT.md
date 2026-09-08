# Sprint11 proofs-r2

Requested worker: `grok-4.6`. Reported worker: `Grok 4.6`. Checker assigned: `gpt-6-astra` (not executed here). No Foreman. No commit, push, archive, or self-acceptance.

Head: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
Private build cwd: `/home/charl/.cache/defiformal-sprint11-builds/proof`.
Lean: `4.33.0-rc2` (`d8b18978322de05a8f3dba51ef03cf5461676c17`). Lake: `5.0.0-src+d8b1897`.

r1 evidence under `implementation/proofs-r1/` is unchanged.

## Compile result

All six owned modules elaborated in the private cache.

| Command | Exit |
| --- | --- |
| `lake build` of Soundness, LocalOrder, Trace, Completion, Preservation, Interference together (941 jobs) | 0 |
| `lake env lean DefiKernel/Nary/{Soundness,LocalOrder,Trace,Completion,Preservation,Interference}.lean` | 0 each |

Worktree and private Lean/config source hashes matched after the last sync (`hashes/worktree-lean-sources.sha256` equals `hashes/private-lean-sources.sha256`). Owned module hashes matched in both locations (`hashes/owned-modules.sha256`). Repository-cache `lake` was not run.

Failed private attempts are kept: `logs/00` through `logs/02` (Soundness), `logs/04` (LocalOrder), `logs/06` (Trace), `logs/09`–`logs/10` (Preservation). The first Soundness attempt failed in core `Schedule.lean` (`sum_count_cons`); this lane did not edit Schedule. A later core-r3 Schedule compiled and was reused.

## Owned sources

Edited only:

- `lean/DefiKernel/Nary/Soundness.lean`
- `lean/DefiKernel/Nary/LocalOrder.lean`
- `lean/DefiKernel/Nary/Trace.lean`
- `lean/DefiKernel/Nary/Completion.lean`
- `lean/DefiKernel/Nary/Preservation.lean`
- `lean/DefiKernel/Nary/Interference.lean`

Core/runtime/fixtures/root config were not modified. Private sources were not copied back over other owners.

`AdvanceSound` / `Reachable` / `advance_sound` remain in core `Execution.lean`. Proofs reuse those constructors and the core skip/refuse/accept lemmas. No duplicate inductive definitions.

## Elaborated obligations

Generic, arbitrary `B` with `DecidableEq` (no fixed three-participant split):

- Attempt append equations none/error/success and `AttemptSound` / `Reachable.attempts`
- `nextIndex = min consumed length`, `attempt_index`
- Attempt chain, local history/order/projection, first-refusal stability
- Complete counts, active exhaustion, exhausted-or-refused
- Signed successful receipt accounting, fixed store, analyzed `analyzeAll` frames, nonnegativity
- Initialized simultaneous interference: all entry invariants, selected actual `executeStep = .ok` local preservation/guarantee, cross-inclusion, peer stability; skip/refusal use world identity; final invariants are conclusions

Source scan of owned files: no `sorry`, `native_decide`, or `axiom`. That is not an imported axiom inventory.

## Remaining work

- Imported axiom inventory on these modules
- `InterfaceInstances` / F18, `BinaryCorrespondence`, `Causal`
- Runtime fixtures, mutations, integrated root `lake build`
- Independent GPT-6 check
- Flexible-simp and unused-simp-argument warnings remain; they did not fail the private builds
