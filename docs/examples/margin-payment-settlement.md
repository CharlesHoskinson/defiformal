# Actual Typed binding of native margin payment

`DefiKernel.Margin.PaymentSettlement` binds the accepted native rounded-payment
quote to actual Typed execution in a fixed reference custody universe. The three
source buckets are primary output, position collateral in the primary token, and
secondary output. The guard requires their quoted raw integer casts to equal the
SAME pre-ledger cells that execution will debit. Fractional/inconsistent buckets
refuse this reference validation. No decimal normalization or unrelated quoted
ledger is substituted.

Five actual Typed deltas debit the three computed paid amounts and credit a
fixed cost recipient in primary/secondary tokens. Supply changes are empty.
Claims use separate `claimPrimary`/`claimSecondary` assets and remain unchanged;
claim counters, the pool and other owner balances do not fund these three buckets.
The cost recipient is a declared reference account, not proved GMX recipient,
holding-address or handler refinement. Only the quoted buckets require raw integer
compatibility; other nonnegative rational cells have no Word256 bounds.

`execute_ok_iff`/`run_ok_iff` connect the actual executor to actor binding, real
invocation/debit checks, evaluated validity, actual post-balances and the same
computed quote metadata. `success_compatible` derives compatibility from success.
`actual_buckets` proves actual source remainders equal native outputs;
`actual_recipient_gains`, `actual_frame`, `claim_counters_frame` and
`actual_accounting` prove real gains, full outside frame and per-asset conservation.
Gains are differences from pre-balances, not assumed-zero recipient balances.

`actual_financial_reconciliation` proves
`cost + ceilDust = actualPrimaryGain*pC + actualSecondaryGain*pS + sourceResidual + floorDust`.
`actual_economic_shortfall` proves returned economic shortfall equals
`max(0,cost-actualPaidUsd)`. Both statements refer to executed gains and actual
returned metadata, not only an independently quoted template.

`execute_exists`/`run_exists` construct execution from compatibility and real
invoke/three-debit rights; funding is derived from native bucket bounds rather
than an assumed Valid or successful output certificate. Genuine administrative
provisioning and exact rights are proved. The sufficient conditions grant all
three debits, while exact execution permits missing rights for zero payments.
`sufficient_primary_execution` uses actual primary liquidity to construct a run,
prove zero source residual and prove actual executed gains cover the exact cost.
This is a single-cost reference payment result, not the final liquidation lifecycle
or unconditional market-solvency theorem.

The primitive deliberately permits partial payment and retains source/economic
shortfalls. An actual invoke-only zero-fund cost1,pC1,pS2 call transfers nothing
and succeeds with source residual0/economic shortfall1. Another positive-secondary
call pays one token but retains economic shortfall1. A cost20/collateral3 case
returns source/economic residual17. Such helper successes are not full liquidation
or ordinary-close decisions; those require the subsequent source-specific stages.

`mismatch_refusal` gives exact `.guard` after actor/invocation checks when a
bucket binding is false. This is reference validation, not the selected GMX
`PositionShouldNotBeLiquidated` financial rejection. Controls isolate all three
bucket mismatches, fractional input, authority and actor priority. Errors return
no post-world and establish no observed rollback or intermediate debit ordering.

```sh
python3 scripts/replay_margin_payment_settlement.py --toolchain /path/to/lean-4.33.0-rc2
```

With pinned dependencies installed, this builds the model and freshly executes
22 nonempty fail-on-false controls, reporting model/audit/Types/Payment/tool
hashes. Exit 0 means finite comparisons passed, 1 means contradiction/build
failure, 3 means missing/empty/unreadable/unavailable inputs. Generic proofs,
axiom disclosure and kernel replays are separate evidence. Kernel replay trusts
imports, does not rerun `#eval`, and is not outside reproduction.

Actual altered API-prefix probes remove the binding guard and admit an unrelated
zero quote, or redirect both the primary credit and declared write to the pool.
The latter reaches pool102 while the cost recipient stays10; per-asset totals
still conserve, but the required recipient comparison fails. Runtime false
comparisons and unchanged-proof compiler rejection are distinct; the intact
settlement cache is not imported by those probes. Accepted native Payment bytes
and earlier source-helper measurements remain unchanged.

[Component accounting](../../benchmarks/component-accounting/margin-payment-settlement.json)
records exhaustive hash-bound physical ranges and a shared wall interval, not
active effort/person-hours or historical separate effort. Source-specific funding,
funded positive-PnL realization, ordered close, preserved claims/snapshots,
selected financial refusal, exceptional bankruptcy and separate lifecycle solvency
remain open, as do universal/deployed source refinement and external reproduction.
Authentication/registry truth and validity of upstream observed costs/prices are
explicit inputs; this primitive proves no GMX handler authorization.
