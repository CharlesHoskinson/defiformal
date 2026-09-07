## Why

Sprint 6 proves composition for disjoint branches, but financial workflows often
compete for the same liquidity or observe balances changed by a peer. We need
explicit shared-state execution and conditional preservation across schedules,
including different success/refusal outcomes when order matters.

## What Changes

- Add finite binary invocation interleaving over one evolving world, with separate
  local histories, stable trusted boundaries and retained successful prefixes.
- Validate complete schedules and structural interfaces before execution; permit
  overlapping footprints. Keep runtime admission distinct from proof obligations.
- Define successful-event interference relations and initialized, noncircular
  rely/guarantee premises; prove accounting, authority, locality and invariants.
- Recover Sprint 6 canonical observations for every complete disjoint schedule.
- Add independently specified financial fixtures, production source mutations,
  axiom coverage, exact review records and a linked `wiki-llm/` decision record.

## Capabilities

### New Capabilities

- `interleaving-execution`: schedules, shared execution, refusal and observations.
- `interleaving-preservation`: sound traces, interference and preservation proofs.
- `interleaving-disjoint-recovery`: correspondence to disjoint parallel behavior.
- `interleaving-regression-evidence`: financial checks, mutations and review gates.

### Modified Capabilities

None. Existing sequential and disjoint parallel requirements remain intact.

## Impact

New Lean modules live in `lean/DefiKernel/Interleaving/`; the kernel import root
adds their verification driver. New scoped mutation tooling and evidence live in
`scripts/` and `review/semantic-kernel/sprint7/`. Roadmap/progress and wiki notes
track accepted work. Exact rational arithmetic and existing dependencies remain.

## Non-goals

Atomic synchronization, rollback, capability issue/revoke inside branches,
capability provenance, unbounded fairness/liveness, arbitrary shared-state
schedule equivalence, N-ary associativity and deployed-protocol fidelity are
separate work. These examples are development cases, not untouched holdouts.
