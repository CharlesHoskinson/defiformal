## Why

Sequential and shared-state execution preserve a successful prefix when a later
invocation refuses. Financial synchronization also needs an explicit transaction
boundary that commits a fully settled result or restores the exact initial world.

## What Changes

- Add finite atomic execution over explicit binary schedules with one speculative
  shared world, branch-local histories and global abort on the first refusal.
- Separate committed financial observations from aborted speculative diagnostics;
  failed admission, failed execution and failed final settlement preserve the
  initial ledger and capability store and publish no committed receipts/outputs.
- Add a bounded, receipt-derived clearing policy for temporary vault obligations,
  with typed vault/domain/asset lanes, authenticated principal attribution and
  checked zero outstanding obligations at commit. Spendable balances remain
  proof-carrying nonnegative throughout.
- Prove actual atomic trace soundness, rollback, committed accounting/authority/
  frames, clearing conservation and conditional success correspondence with the
  existing interleaving executor.
- Add independent financial success/refusal fixtures, real runtime mutations,
  defensive runner controls and exact source-bound evidence with native reviews.

## Capabilities

### New Capabilities

- `atomic-execution`: Admission, speculative execution, first-failure abort and
  exact public committed/aborted observations.
- `atomic-settlement`: Receipt-derived typed clearing obligations, policy checks
  and deterministic final-settlement refusal.
- `atomic-preservation`: Generic actual-run rollback/preservation, clearing
  conservation and conditional correspondence to existing execution.
- `atomic-regression-evidence`: Financial fixtures, live source mutations,
  complete runner controls and frozen proof/review/delivery evidence.

### Modified Capabilities

None. Existing sequential, disjoint parallel and shared interleaving semantics
retain their accepted behavior.

## Impact

New Lean namespace and modules under `lean/DefiKernel/Atomic/`, root verification
import, focused Python mutation/control drivers and versioned Sprint 8 review
artifacts. OpenSpec holds requirements and `wiki-llm` records decisions. Existing
proofs, runtime constructors, source corpus and dependency versions are preserved.

This is a finite, fixed-capability, exact-arithmetic reference model. It does not
claim general signed spendable balances, capability mutation inside a transaction,
unbounded liveness, reentrant hooks, fees/gas, distributed atomicity, full Balancer
semantics or deployed-protocol fidelity. Those remain separate roadmap obligations.
