# Sprint11 proofs-r3

Requested worker: `grok-4.6`. Reported worker: `Grok 4.6`. GPT-6 coverage findings from `gpt6-review/proof-preliminary.md`. No Foreman. No commit, push, archive, or self-acceptance.

Head: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
Private cwd: `/home/charl/.cache/defiformal-sprint11-builds/proof`.
Lean in that directory: `4.33.0-rc2` (`d8b18978322de05a8f3dba51ef03cf5461676c17`).

r1 and r2 evidence directories are unchanged.

## Compile

| Command | Exit |
| --- | --- |
| Combined `lake build` of all six owned modules (957 jobs) | **0** |
| `lake env lean` of each of the six | **0** each |

Worktree and private source hashes matched. Owned module hashes matched in both locations. Repository-cache `lake` was not run. Interference, Soundness, LocalOrder, and Completion hashes are identical to r2.

## P1. Per-cell signed receipt effects

Added in `Preservation.lean`, importing proof-only `DefiKernel.Interface.Accounting`.

- `Attempt.cellEffect` / `Machine.cellEffect`: error attempts contribute 0; successful attempts use `Interface.receiptCellEffect`.
- `AdvanceSound.cell_accounting` and `continueRun_cell_accounting`: arbitrary-entry difference form. New successful receipts change the cell; skips and errors add 0. Pre-entry effects are not counted twice against the entry world.
- `Reachable.cell_accounting` / `runPrefix_cell_accounting`: genesis telescope from `start`.
- Bridge: `Interface.step_receipt_cell` on the actual `executeStep = .ok` equation.

Existing domain-total `supply` theorems remain. They are not relabeled as transfer routing.

## P2. Exact own-history and stored indices

Added in `Trace.lean`. Genesis `Reachable` only.

- `ownHistory prefix b`: flattened successful outputs of `b` from an attempt-list prefix.
- `Reachable.own_history`: `(m.locals b).outputs = ownHistory m.attempts b`.
- `AttemptChain.prefix_before`: the attempt at global index `i` has `before` equal to the chain world after `attempts.take i`.
- `Reachable.attempt_exact`: that attempt's `executeStep` uses `ownHistory (take i) participant` at `attempt.index`/`attempt.before`; `attempt.index` equals the count of prior successful own events; the prefix chain is `AttemptChain`. Not an existential dummy history.
- `Reachable.event_index_seq`: `events.map Event.index = List.range events.length` (positions `0 .. length-1`).
- `Reachable.event_index_at`: the stored event at local slot `n` has `index = n`.
- `runPrefix_*` corollaries.

First-refusal stability is unchanged. Skips do not append attempts, so they do not invent a new own-history. Synthetic entry machines are not covered by `attempt_exact` / `event_index_seq`.

## Interference

Unchanged (hash `82a0cf1a…`). Generic `B`, actual `executeStep = .ok`, initialized own G / cross / stable, `continueRun_invariants` still requires genesis `Reachable`.

## Remaining

- Imported axiom inventory
- InterfaceInstances / F18, BinaryCorrespondence, Causal
- Fixtures, mutations, integrated root build
- Independent GPT-6 re-review of these r3 statements
- Flexible-simp / unused-simp-argument warnings (did not fail the private builds)
