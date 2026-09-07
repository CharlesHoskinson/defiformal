## Why

Sprint 5 gives ordered workflows but does not establish when independent workflows
can execute in either order without changing their financial results or refusals.
Sprint 6 adds a conservative disjoint parallel operator and proves correspondence
to actual sequential re-execution, closing that specific composition gap.

## What Changes

- Analyze concrete registered invocations for conservative ledger read/write regions,
  including expression reads, debit targets, and selected output snapshots.
- Admit two finite invocation-only branches whose writes do not conflict with the
  other branch's reads or writes; use one immutable capability store and trusted
  boundary inputs indexed by branch identity and local position.
- Run each branch with Sprint 5 prefix/refusal semantics, retain both outcomes, and
  merge only the admitted write regions. One branch's refusal does not cancel its peer.
- Prove state-dependency framing, independent invocation commutation, and equivalence
  of the parallel result to left-then-right and right-then-left re-execution.
- Lift accounting, point-of-use authority, nonnegativity, and supported ledger frames;
  add complete financial fixtures, actual source mutants, and audit coverage.
- Require independent Fable and GPT-6 planning audits to pass before implementation;
  retain native Grok/Fable review of substantive implementation results.

## Capabilities

### New Capabilities

- `parallel-compatibility`: Conservative concrete footprints, conflict rejection,
  fixed capability-store discipline, and branch-local trusted input identities.
- `parallel-workflow-execution`: Binary fork/join execution with checked state merge,
  branch-local output histories and independent successful-prefix/refusal outcomes.
- `parallel-preservation`: Executor dependency proofs, commutation and serial-order
  correspondence, and financial preservation with explicit premises.
- `parallel-regression-evidence`: Discriminating financial examples, source mutations,
  honest proof inventory, independent audits, and source-bound delivery.

### Modified Capabilities

None. Existing sequential behavior and refusal precedence remain unchanged.

## Impact

New namespace/modules under `lean/DefiKernel/Parallel/`, new audit import in
`lean/DefiKernel.lean`, scoped mutation runner and controls under `scripts/`, and
Sprint 6 evidence under `review/semantic-kernel/sprint6/`. Existing Typed and
Composition APIs are consumed without changing historical theorem statements.
No new external dependency, Quint model, public deployment, or change to main is
required. Shared-state interleaving, atomic synchronization/rollback, capability
provenance, arbitrary nested networks, claims, machine arithmetic and deployed
protocol fidelity remain later roadmap work.
