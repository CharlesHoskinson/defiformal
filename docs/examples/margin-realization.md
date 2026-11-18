# Actual pool-funded close-PnL realization

`DefiKernel.Margin.Realization` takes an explicit signed computed close
`basePnlUsd`, positive PnL-token max price and primary/secondary token selector.
The close observation is distinct from the marked valuation PnL retained in
`Funding.Position`. No universal equality or proof of their source computation
is assumed. The later close contract must state its upstream observation relation.

For positive base PnL, the quote is `floor(basePnlUsd / maxPrice)` raw tokens,
with the exact remainder as USD floor dust. Two actual Typed deltas debit the
selected actual pool cell and credit the matching output cell. Supply changes
are empty. The real pool balance must fund the debit, and the caller needs actual
operation-scoped invocation/debit capabilities. PnL itself does not create pool
custody. Both token routes preserve per-asset totals, all unrelated cells, claims,
position data and capability state. The recipient need not start with zero output.

`execute_ok_iff`/`run_ok_iff` bind the real executor to the operation;
`actual_pool_and_output`, `actual_frame` and `actual_accounting` prove its executed
movements and conservation. `actual_floor_value` proves actual output gain times
max price plus returned dust equals the nonnegative part of the explicit close
observation, with dust below max price. `run_exists` constructively derives success
from sufficient actual pool custody and real rights, without assuming successful
output. The ledger permits nonnegative rational balances; source comparison would
add raw-integer/width compatibility rather than imply all ledger cells are Word256.

Zero/negative PnL makes this local operation a no-op and requires no capabilities.
It does not settle negative PnL costs or bypass outer close admission. Positive
subtoken PnL executes a zero transfer: invoke is still required, debit authority
is unnecessary for that exact zero movement. The sufficient success theorem may
grant a debit even then. Refusals return no post-world, with no observed rollback
claim.

The pinned source `a85ea3491c19c93bb4b5a002d9b358fb769b7849`,
`DecreasePositionCollateralUtils`119–143, uses positive base PnL, divides by
`pnlTokenPrice.max`, debits the PnL-token pool and credits primary output when the
token matches, otherwise secondary output. This module proves the declared
reference-ledger behavior. It does not newly execute that Solidity branch or prove
source storage, bank custody, handler or deployed equivalence. Explicit source
arithmetic-domain bounds and a later source-bound branch campaign remain required.

Positive impact180–220 has additional index-impact-pool bookkeeping and a separate
PnL-token pool payout. It is not silently zeroed, duplicated or implemented by this
base-PnL stage. The coherent close design must bind already processed incoming
impact outputs or model that preprocessing separately, with its scope explicit.

```sh
python3 scripts/replay_margin_realization.py --toolchain /path/to/lean-4.33.0-rc2
```

With pinned dependencies, the runner builds the model and freshly executes 18
nonempty fail-on-false controls, reporting model/dependency/tool hashes. Exit 0
means finite comparisons passed, exit 1 means contradiction/build failure, exit 3
means missing/empty/unreadable/unavailable input or timeout. Generic proofs,
nonempty axiom audits and kernel replays are separate. Kernel replay trusts
imports, does not rerun controls and is not outside reproduction.

The controls cover floor dust/exact multiples, both token routes, depleted and
insufficient pools, real authorities, nonpositive no-op and marked 100 vs close 10
observations. Actual mutated API-prefix programs ceil the payout or inject
fictitious pool cash before execution. The latter credits output while leaving
the original pool undepleted, lets an insufficient pool succeed and increases
physical totals. Exact runtime comparisons fail; unchanged full generic proofs
separately reject both mutations. No intact Realization cache substitutes for an
altered implementation.

[Component accounting](../../benchmarks/component-accounting/margin-realization.json)
counts declared ranges with shared dependencies excluded. Shared wall intervals
are not complete active effort/person-hours; historical separate effort remains
unknown. Ordered costs/close, selected healthy refusal, allowed exceptional return,
claim/snapshot caller commit, source branch observations, separate constructive
lifecycle solvency and full IV.3/P27 remain open, as do universal/deployed source
refinement and outside reproduction.
