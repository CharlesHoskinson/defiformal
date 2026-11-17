# Rounded funding with actual payment and pending receipts

`DefiKernel.Margin.Funding` computes the funding stage and executes payment in
one fixed reference ledger. The selected primary collateral token is the market's
long token; secondary is its short token. Raw factors are unsigned and nondecreasing from the
position snapshots. With `Q = 10^45`, the fee in primary tokens is
`ceil(sizeUsd * feeFactorDelta / Q)`; pending primary/secondary funding claims
are `floor(sizeUsd * claimFactorDelta / Q)`. Generic bounds prove these rounding
contracts. Converting the rounded token fee to USD at the positive primary price
requires exactly that many primary tokens, without a second primary rounding loss.

`run` calls the accepted `PaymentSettlement.run` with cost `feePrimary * pC`.
Its three quoted buckets must equal the SAME actual pre-ledger output-primary,
position-collateral-primary and output-secondary cells. Actual invocation/debit
rights and funding checks apply. Positive marked PnL, owner claims and unrelated
pool funds do not automatically enter these buckets. The fixed cost recipient is
a reference account, not proved GMX recipient/handler refinement.

A positive secondary payment then requires a configured holding destination and
executes an operation-scoped Typed claim-counter increase. The distinct keys are
`(holding, claimSecondary)` for **holding claimable collateral** and
`(owner, claimPrimary/claimSecondary)` for **owner claimable funding**. They share
a generic counter asset in this fixed universe but have different roles; this
proves no interchangeability, cash value or redemption behavior. Only the holding
counter and its declared counter supply increase. Both physical token totals
conserve. Owner funding counters, PnL, impact, position size and all snapshots
remain unchanged. The receipt contains pending owner claims and latest factors;
the later caller commit/removal is deliberately separate.

`run_ok_iff` and `actual_effects` bind actual execution to the same computed quote,
all post-balances and capabilities. `run_exists` constructs success from exact
bucket compatibility, genuine operation-scoped rights and holding configuration
when secondary payment is positive. It assumes no successful-output certificate.
Its sufficient rights include holding invocation/supply rights even when unused;
exact zero-secondary execution needs neither those rights nor configuration.

`actual_reconciliation` relates the returned source residual and both rounding
dusts to actual recipient gains. The primary-payment warning, source residual and
exact economic shortfall are separate fields. Full secondary coverage still sets
the warning if primary payment is below the expected funding-token fee. The
warning is receipt data, not an observed GMX event or automatic compensation.
The stage permits partial payment; subsequent ordinary-close or exceptional
bankruptcy decisions are not made here.

`signedFundingCharge_nonpositive` states the negative fee contribution separately.
`primary_paid_equity` proves that full primary-collateral payment, with no primary
output, changes actual marked collateral equity by that rounded negative charge.
The post-collateral balance already incorporates payment: subtracting the same fee
again would double-count it. This marked valuation excludes other health fees and
is not the full source liquidation-health computation. Signed PnL/impact remain
upstream observations here. Positive-impact preprocessing must be explicitly bound
to incoming output buckets or separately executed in the later close model.

The pinned GMX source is `a85ea3491c19c93bb4b5a002d9b358fb769b7849`.
`PositionPricingUtils.getFundingFees` selects ceil for the fee and floor for each
claim; `MarketUtils.getFundingAmount` supplies the unchanged helper used by the
EVM probe. Seven fresh helper observations match seven fresh native quote values,
including nonzero snapshots, zero delta and zero size. The existing frozen
92-source wrapper/runtime and exact Cancun tools are reused without a new compile
or full-handler claim. Source comparison requires every uint256 intermediate and
rounded result to fit; the native model uses unbounded naturals. Unsigned factor
underflow is excluded by explicit admissibility, not silently converted to a
financial refusal. Original source-helper arithmetic Panic observations remain
separate from reference Typed/configuration errors.

```sh
python3 scripts/replay_margin_funding.py --toolchain /path/to/lean-4.33.0-rc2
```

With pinned dependencies, this builds the model and freshly executes 21 nonempty
fail-on-false controls. It reports source/dependency/tool identities. Exit 0 is
finite consistency, 1 is contradiction/build failure, 3 is missing, empty,
unreadable or unavailable input/timeout. Refusals return no post-world; they prove
no observed rollback or confidentiality of intermediate computations. Generic
proofs, nonempty axiom audits and kernel replays are separate. Kernel replay trusts
imports, does not rerun controls and is not external reproduction.

Actual altered implementation probes floor the fee, prematurely advance snapshots,
or credit the holding collateral claim to the owner. Each executes the altered
body and fails exact runtime comparisons; unchanged generic proofs also reject it.
No intact Funding cache stands in for an altered implementation.

[Component accounting](../../benchmarks/component-accounting/margin-funding.json)
counts declared physical ranges, shared dependencies separately and no invented
historical/person-hours. Full caller claim/snapshot commit, pool-funded PnL
realization, ordered close, selected source financial refusal/allowed bankruptcy,
source branch observations, separate constructive lifecycle solvency and IV.3
remain open. Universal/deployed source refinement and outside reproduction remain
open. Observed factors, prices and upstream position data are explicit trusted
inputs, not proved oracle/handler truths.
