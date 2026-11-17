# Proposed P27 source-entry contract: signed margin and full-close payment

Status: task 28.1 candidate awaiting independent entry acceptance. No Margin
implementation, P27 completion or source-runtime result is claimed by this packet.
The binding pin is `gmx-io/gmx-synthetics` commit
`a85ea3491c19c93bb4b5a002d9b358fb769b7849`, tree
`0cc923c20087fdfab3659d672af6ce8a02665b19`. SOURCE-BINDINGS.json binds exact
original files, line excerpts and existing preparation seals. Their historical
roles/dates remain unchanged. The 91-source solc compilation is prior preparation,
with ten unresolved library objects, not a new campaign or deployed identity.

The selected reference boundary is full-size close eligibility and signed
funding/equity observations, followed by ordered source-rounded payment buckets.
Use distinct primary collateral and secondary output tokens, NoSwap routing, one
market and an explicit account/position. Preserve raw token identities and
market/token/account claimable keys. This is a bounded source slice, not the
entire GMX protocol, handler authorization, oracle or deployment lifecycle.

## Inputs, units and arithmetic domain

Freeze raw integer position collateral, primary/secondary output buckets, position
size and full-close size delta, cumulative funding factors and snapshots, signed
computed position PnL and capped impact, computed fee amounts, min-collateral and
leverage thresholds, and positive min/max price records. Signed computed upstream
PnL/impact/fee inputs are explicit observation parameters; this does not prove
their oracle/market computation. Full size means exact sizeDeltaUsd=sizeInUsd.

Source USD values use FLOAT_PRECISION=10^30; token amounts are raw token integers.
A raw token amount times its supplied source price has the source's raw USD units.
Do not infer token-decimal normalization or equate either token with USD. Funding
uses sizeUsd*factorDelta/10^45 (10^30*10^15). Fees round up, separately keyed long
and short claimables round down. Require nondecreasing unsigned factor snapshots.
Fee liability has a negative equity direction; a claimable increment is not a
spendable-token increment. Claiming requires its separate source key clear and
funded transfer, rather than implicit netting against a position.

The mathematical model may use exact unbounded integer arithmetic. Source
comparison is restricted to valid uint256/int256 inputs and intermediates: safe
casts and signed sums, cost+primaryPrice-1 and secondary-conversion products must
fit the source widths; prices/divisors must be nonzero; mulDiv output must fit.
These explicit arithmetic-domain conditions are not an assumed successful model
result. Solidity panics, ABI failures, infrastructure failures and out-of-domain
values are distinct observations outside this financial success/refusal relation.
No EVM256 equivalence theorem is inferred from mathematical arithmetic.

## Equity and the selected actual rejection

Source liquidation-health equity is E=C*pMin+signedPnL+cappedImpact-totalCost*pMin.
For a liquidation check with min validation enabled, the position is liquidatable
if E<minCollateral, E<=0, or E<minLeverage, in that source priority. Thresholds and
cost inputs are the source-computed observations; the health fee call excludes
liquidation fees. This health valuation is not spendable token custody.

Select `Errors.PositionShouldNotBeLiquidated(reason,E,minCollateral,minLeverage)`
from DecreasePositionUtils220–238 as the task 28.1 rejection guard. For a liquidation
order reaching that branch, a false liquidatable predicate rejects. This is not a
claim about earlier error priority or whole transaction execution. A healthy
example E13,minCollateral1,minLeverage4 has source reason empty and selected error
arguments [empty,13,1,4]. Actual ABI bytes are not observed in this packet.

Positive unsettled PnL does not change pre-close spendable custody. At close the
source explicitly realizes positive base PnL by debiting the PnL-token pool and
crediting primary/secondary output, floor(basePnl/pnlPrice.max). Model that actual
funded transfer and its rounding separately; do not prohibit genuine realized
output from paying costs or silently credit an unfunded PnL-as-cash amount.

## Ordered payment, dust and exceptional success

Freeze the ordered stages funding, negative realized PnL, other fees, negative
impact, then positive impact-difference cost. At each nonzero USD cost K and
positive prices pC,pS: A=ceil(K/pC); spend primary output first, then position
collateral, so a=min(A,O+C), R=A-a; B=floor(R*pC/pS); spend b=min(B,S) secondary.
The source result is residual=(B-b)*pS, not an exact rational debt. Zero cost pays
nothing. Keep the split output/collateral amounts and all actual residual buckets.

Let up=A*pC-K and down=R*pC-B*pS. Prove constructive payment reconciliation
K+up=a*pC+b*pS+residual+down, with 0<=up<pC and 0<=down<pS. Economic shortfall is
max(0,K-a*pC-b*pS), distinct from the source variable. With K1,pC1,pS2 and all
buckets zero, source residual is zero, no payment occurs, down=1 and exact USD
shortfall is 1. This required witness refutes residual-zero=>fully-paid.

A positive residual at the first unpaid stage invokes handleEarlyReturn. Allowed
exceptional success requires full close AND (liquidation order OR secondary ADL).
It retains residual and step and emits InsolventClose; the ordinary case rejects
InsufficientFundsToPayForCosts(residual,step). This ordinary rejection is distinct
from the selected healthy-liquidation guard. Allowed bankruptcy is not refusal,
insurance compensation or a proof of unconditional solvency.

Retain the completed prefix, stopped stage, skipped quoted costs and source-rounded
residual separately. Do not interpret the stage residual as aggregate later debt
or skipped quotes as newly imposed source liabilities. getEmptyFees zeroes fee
amounts but preserves long/short claimables and latest funding snapshots; the
caller still increments claimables. Those records must not be wiped or treated as
cash. Full-close position removal/output handling and any later caller validation
are separate from an internal helper's successful exceptional return.

## Proposed implementation and theorem obligations after entry acceptance

New DefiKernel.Margin modules must preserve old sources and existing negative
results. Separate signed position/health observations from nonnegative Typed
custody, charge and claimable records. Actual payment/realization operations must
read or bind their quotes to the same ledger cells they debit and credit; genuine
capabilities and funding remain actual executor checks. Do not reuse a nominal
source quote with unrelated custody. Expose the selected admission refusal and
allowed exceptional outcome as different result constructors.

First prove generic rounded-payment success, exact bucket bounds and the two-dust
identity. Then connect actual Typed funding/realization/payment effects and
per-token conservation to those computed amounts. Funding observation updates
must derive the fee's signed equity contribution and preserve separate claimables.
Prove liquidation correctness over actual model execution: selected admission,
full-close/exception eligibility, actual completed payment prefix, output/custody
poststates, stopped-stage residual and preserved claims. No event name alone
constitutes an executed insurance transfer or a stored GMX debt ledger.

Prove solvency separately with a useful sufficient liquidity condition, such as
actual available primary output+collateral covering the sum of per-stage rounded
primary obligations, plus real authority and upstream observation validity.
Conclude actual execution, real payments covering the exact processed costs,
nonnegative custody and reconciliation. Do not merely restate that liquidity
inequality, assume payment success or erase dust/residual/skipped observations.
Keep the source-independent residual-zero negative and the separate PnL-as-cash
mutant; both must challenge the actual new behavior rather than a cached model.

## Actual campaign plan and evidence boundary

After entry acceptance, build a thin new wrapper exposing unchanged GMX internal
pure MarketUtils.getFundingAmount and DecreasePositionCollateralUtils.payForCost.
Import exact original source/dependency bytes. Freeze generated wrapper, compiler
standard JSON, settings, runtime and invocation identities. Use solc0.8.29 with
Cancun and the pinned optimizer settings; require the wrapper's own linkReferences
to be empty before any EVM invocation. Historical unresolved library objects do
not count as runtime setup. A separately pinned EVM runner/runtime is still to be
acquired/verified. TOOL-READINESS.json binds the old Linux receipts and records
that their exact paths and selected native cache locations are absent here;
Node/npm are available. This is a selected inspection, not exhaustive filesystem
absence, missing source or a completed campaign. Target cmd/evm v1.15.11 and
compiler 0.8.29+ab55807c; verify newly acquired platform-specific bytes/licenses
rather than reusing the old Linux binary hashes as current identity.

Run nonempty differential cases including inexact fee/claimable rounding, primary
and secondary payments, zero-residual dust and sufficient liquidity. If a source
branch adapter is used for admission/exception tests, freeze its exact excerpt
recipe and explicit stubbed upstream inputs: adapter output is not a full GMX
handler execution. Actual Lean tests must cover funding, allowed full liquidation/
bankruptcy success, the frozen selected refusal, ordinary shortfall rejection,
PnL-as-cash mutation and source-independent equity/payment-equation negatives.
Record success values, semantic refusals and infrastructure/panic/malformed
observations separately, never coercing unavailable evidence into a refusal match.

Full GMX source refinement, deployed bytecode identity, unresolved original links,
LiquidationHandler/AdlHandler roles, oracle authenticity/finality, bank-controller
custody, holding-address configuration and omitted swaps/handlers are unproved or
explicit assumptions outside this boundary. Any later claim using one must first
acquire and verify its actual inputs. No historical compiler campaign is repeated
or upgraded in this entry packet; no matrix cell is closed before implementation,
proof/execution evidence and independent acceptance.
