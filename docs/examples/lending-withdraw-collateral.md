# Collateral withdrawal and finite lending coherence

`DefiKernel.Lending.WithdrawCollateral` moves exact-rational collateral from the
intended borrower's locked custody into that borrower's free balance through
actual Typed execution. It changes no cash, debt or supply. The request binds the
borrower to the invocation principal; real invocation and custody-debit rights
are required for positive movement. Zero movement needs only invocation rights,
while still satisfying the full oracle and health policy.

The actual guard checks nonnegative quantity, quantity no greater than the actual
locked balance, strictly positive collateral/cash price, inclusive freshness
`observedAt <= now <= observedAt + 5`, and `2D <= (C - q) * p`. Debt is converted
one-for-one into cash; free collateral never backs debt. The observation key is
lending/feed7 with collateral/cash price units. Oracle authenticity, clock truth,
authentication and registry truth remain explicit framework/input assumptions.
The expression-read footprint is locked/debt/locked; the declared footprint covers
both cells. Price and time reads are declared separately.

`guard_evaluate` proves the exact six-condition correspondence for any well-typed
observed point. `run_ok_iff`, `actual_effects`, `actual_frame` and
`actual_accounting` connect actual execution to own custody minus quantity, own
free balance plus quantity, every other cell unchanged and per-asset total
conservation. `actual_collateralization` derives health of the actual post-ledger.
`funded_success` constructs execution from the policy, observed point and actual
rights, without an assumed Valid/result certificate or a separate hidden funding
premise: the policy bounds quantity by the same pre-ledger custody cell.

`policy_refusal` proves exact guard refusal when actor/invocation checks pass,
the observation is well typed, and a policy condition fails. It does not apply to
missing/wrong-unit observations. Boolean guard operands evaluate eagerly: missing
oracle plus negative quantity is an evaluation refusal, not a guard refusal.
Well-typed over-locked requests refuse by guard before funding; no
insufficientFunds priority is invented. Future/stale/nonpositive-price inputs and
zero-quantity unhealthy positions also refuse. Errors return no post-world and
establish no observed rollback or intermediate debit-order guarantee.

`DefiKernel.Lending.LifecycleAudit` supplies separate finite coherence evidence
through all five unchanged public APIs on one common Types/ledger universe.
Actual administrative provisioning issues 13 noncolliding operation-scoped
capabilities. Each actual returned state/capability store is passed to the next
operation, in the following fixed scenario (cash/pool/debt/free/locked):

| Step | Actual balances |
| --- | --- |
| Initial | 5 / 100 / 0 / 10 / 0 |
| Deposit 8 | 5 / 100 / 0 / 2 / 8 |
| Borrow 4 at price 2 | 9 / 96 / 4 / 2 / 8 |
| Accrue rate 1/4, interval 1 | 9 / 96 / 5 / 2 / 8 |
| Repay 2 | 7 / 98 / 3 / 2 / 8 |
| Withdraw 3 at price 2 | 7 / 98 / 3 / 5 / 5 |

The final control checks the entire finite ledger, with every other cell zero,
unchanged capabilities, cash total 105, collateral total 10 and debt total 3.
Borrow capability IDs do not authorize withdrawal. This is one finite coherence
execution, not a general composed-lifecycle, solvency, temporal-replay or
protocol-refinement theorem. Accrual retains its unindexed per-call semantics.

```sh
python3 scripts/replay_lending_withdraw_collateral.py --toolchain /path/to/lean-4.33.0-rc2
```

With project dependencies installed, this builds the five actual models and
freshly executes 27 withdrawal and 8 lifecycle fail-on-false comparisons, checking
both nonempty inventories separately and reporting all relevant source/tool
hashes. Exit 0 means these finite comparisons passed, 1 means contradiction/build
failure, and 3 means missing, empty, unreadable or unavailable input. Generic
proofs, named axiom disclosure and kernel replays are separate evidence. Kernel
replay trusts imports and does not rerun executable controls or constitute
outside reproduction. A mutant using pre-withdrawal collateral actually accepts
quantity 9 to free/locked/debt 14/1/2, violating post-health; its runtime comparison
fails, and its unchanged generic proofs fail separately. The mutant source prefix
executes without importing the intact WithdrawCollateral cache.

[Line accounting](../../benchmarks/component-accounting/lending-withdraw-collateral.json)
uses explicit exhaustive hash-bound physical ranges, with shared support and
lifecycle evidence separate from withdrawal counts. The recorded wall interval
includes repairs and command waits, not measured active/person effort. Historical
per-component effort, the separate-effort scenario, outside reproduction/adoption,
oracle truth and deployed-source refinement remain open. See the
[dated lending capability addendum](../research/competitive-landscape-2026-11/lending-library-addendum-2026-11-17.md)
for the scoped five-operation source claim. Exact review/delivery/publication
status is established by separate repository records.
