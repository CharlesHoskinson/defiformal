## Why

The kernel has a `Typed.ClaimId` identifier and ledger accounting, but no claim store or repayment lifecycle. Its borrowing example issues a debt-denominated asset; rejecting a debt-erasing borrow proposal does not implement repayment. Resource conservation alone cannot say whether a debtor's liability was paid, forgiven or defaulted.

## What Changes

Add a separate `DefiKernel.Claims` namespace with an augmented world, permanent claim IDs, fixed rational unconditional obligations, funded loan creation, creditor transfer, due-date extension, actual cash repayment, explicit forgiveness and recorded default. Loan funding/payment and claim mutation publish together after the actual Composition executor and exact payment checks succeed. Preserve successful prefixes and exact refusal diagnostics.

Prove reachable claim validity, authorized lifecycle changes, no disappearance or ID reuse, actual receipt-to-payment correspondence, paid-versus-forgiven accounting, and conservative legacy execution for embedded claim-free programs. Add full-state financial controls and actual source mutations with independent expectations.

This is an author planning draft. It grants no implementation or acceptance. Conditional/indexed payoffs, interest, collateral liquidation, debt-token correspondence, async settlement, third-party repayment, cryptographic authorization and deployed/legal fidelity remain separate work.

## Capabilities

### New Capabilities

- `fixed-claim-state`: permanent claim records and explicit bounded terms/status.
- `authorized-claim-lifecycle`: role-bound creation, transfer, extension, forgiveness and default.
- `ledger-backed-claim-payments`: atomic funding/repayment through actual registered execution.
- `claim-trace-preservation`: full observations, no disappearance and conservative legacy projection.
- `claim-lifecycle-evidence`: exact fixtures, mutations, proof inventory and independent gates.

### Modified Capabilities

None. Historical World, Right, ClaimId, kernel operators and theorem statements remain unchanged.

## Impact

Future new modules under `lean/DefiKernel/Claims/`, a dedicated Verify/import target, `scripts/claims_gate.py`, `scripts/test_claims_gate.py`, and `mutations/claims.json`. Parent-owned root import/build registration is an integration change after planning acceptance. Evidence goes under `review/semantic-kernel/claims-lifecycle/implementation/`. No existing corpus, source packet, official review bundle or historical proof is rewritten. Exact accepted source/API and inherited runner control bindings must be refreshed before official plan freeze.
