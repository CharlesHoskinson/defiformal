# Bounded selected close-payment prefix

Proposed implementation boundary under the accepted P27 entry. Source pin:
`gmx-io/gmx-synthetics@a85ea3491c19c93bb4b5a002d9b358fb769b7849`.
No new planning criterion or source/financial implementation is accepted by this note.

The input is the SAME actual reference ledger/capability store and explicit
position/factor observations used by Funding, plus sizeDeltaUsd, order-kind
(liquidation/ordinary), secondary-ADL flag, primary/secondary positive prices,
PnL-token side/max price, health-other-fee tokens, min-collateral/min-leverage
thresholds, computed close base PnL, capped close total impact, nonfunding fee
tokens and positive impact-difference USD. Primary collateral is long token;
secondary is short token; NoSwap route. Initial raw O/C/S must bind exact actual
ledger cells. General upstream source computation/validity is conditional.

## Admission and observation relationship

Use pre-close C*pMin + position.markedPnl + position.healthImpact
− (computedFundingFeeTokens + observedHealthOtherFeeTokens)*pMin.
Health impact is the supplied source-capped observation (nonpositive under the
selected source health computation). Health-other fees exclude funding and
liquidation fees. The funding fee is derived from the SAME position size,
snapshots/latest factors, not an unrelated successful arithmetic certificate.
Thresholds are observed source outputs, not newly proved oracle/factor calculations.

Liquidation admission uses exact source priority: equity < minCollateral,
then equity <= 0, then equity < minLeverage; otherwise selected healthy refusal
PositionShouldNotBeLiquidated(reason,equity,minCollateral,minLeverage), reason
empty in that refusal. Earlier source validation/authorization is not implemented.
Ordinary/secondary-ADL routes do not invent a liquidation guard.

Marked health PnL/impact and computed close base PnL/total impact are distinct
observations. Their compatibility with the pinned source is an explicit upstream
context obligation: no universal equality is assumed or proved. The wrapper
accepts conditional source-observation inputs, not claims of their computation.

## Two actual preparation cash legs

After admission, first execute Realization for positive computed close base PnL;
then execute the same floor-transfer operation for positive capped close total
impact, using the SAME PnL-token side and max price. Nonpositive observations skip
the corresponding cash leg. Positive values below one token produce zero payout.
Both legs debit the SAME actual selected pool and credit the matching actual output
in source cash-leg order. Neither marked observation nor a claim counter mints cash.
The second call explicitly labels its input as impact despite the reusable API's
parameter/receipt name basePnlUsd; its proved arithmetic/transfer does not depend
on the financial label. Both receipts retain their distinct observation role.

Source positive-impact capping, available index-impact-pool observation, ceil index
pool debit and resulting index-pool bookkeeping are explicit upstream assumptions,
not implemented Typed index-pool accounting. The model must not claim this is full
processCollateral, market storage or handler refinement. It does implement both
selected PnL-token cash payouts; no silent zeroing or duplicate impact output credit.
No additional precredited impact amount is added unless separately frozen and bound
in the initial actual O/S buckets as an independent upstream output observation.

## Ordered actual payments and return metadata

Funding.run executes first with updated raw output buckets bound to preparation's
actual post-ledger. Then execute accepted PaymentSettlement for active negative
close PnL, nonfunding fee tokens*pMin (always), negative total close impact, then
positive impact-difference USD. Funding and nonfunding-fee helpers run even at zero;
signed cost branches are skipped when their source predicate is false. Keep these
conditional skips distinct from unprocessed stages after an early return.

Each actual payment goes to the fixed reference costRecipient accounting escrow.
This proves actual custody debit/credit and per-token conservation, not GMX's
subsequent fee receiver, pool, rebate, UI-fee or impact-pool storage allocation.
Those source bookkeeping effects are conditional boundary observations/remaining
refinement obligations; no executed insurance, swap or bank transfer is invented.

After each active stage, a positive source residual stops immediately. Retain
actual executed prefix worlds/payments (including the partial stopped attempt),
fully processed earlier stages, stopped stage/residual and later skipped quoted
costs. The residual is only that stage's source-rounded residual, not aggregate
later debt or forgiveness. Exact economic shortfall remains separately recorded.

Derive fullSize from ACTUAL position.sizeUsd = sizeDeltaUsd. Exceptional helper
success requires fullSize && (liquidation || secondaryADL). Otherwise return exact
InsufficientFundsToPayForCosts(residual,step). Do not report a returned post-world
or observed rollback for an error. Allowed outcome is exceptional success with
remaining custody/outputs and stop metadata, not an automatic insurer or solvency
claim. Source events are not claimed executed by the reference model.

Project getEmptyFees to represented fee fields: zero charges, retain pending owner
funding claims and latest factors. Apply this projection on allowed early return.
Also preserve the source fees-stage rule: if source residual is zero AND secondary
payment is zero, fee metadata remains; otherwise empty fees, even if secondary
payment makes source residual zero. Later stages use already quoted costs, not a
new liability fabricated from zeroed display fees.

Caller claim increments, position removal, size/snapshot commit and final output
handling remain separate. The selected normal result means payment-prefix complete;
it does not claim execution of processCollateral's later initialCollateralDelta
adjustment/withdrawal suffix, full caller validation, bank or handler. Pending owner
claims/latest snapshots survive the selected prefix, including empty-fee outcomes.

## Proof obligations and constructive solvency

Prove admission/result correspondence, actual same-ledger preparation/payment chain,
correct active-stage order, real authorities, actual per-asset conservation, raw
bucket correspondence and every executed payment's two-dust reconciliation. Prove
successful helper outcomes expose either complete selected prefix or exact first
stopped stage with allowed eligibility and preserved claim/latest projection.
Ordinary refusal must retain exact financial constructor/arguments, without
assuming that positive source residual is full economic insolvency.

Separate solvency theorem: sufficient actual selected-pool custody for the SUM of
the two positive floor payouts, plus real preparation rights, constructs both cash
legs. Concrete primary output+collateral after those derived payouts must cover the
sum of all active per-stage rounded primary obligations; genuine payment rights and
holding rights/configuration when needed construct the whole selected execution.
Conclude completed prefix, actual gains covering each exact cost, nonnegative
custody and reconciliation. Do not assume successful outputs or replace economic
coverage by sourceResidual=0. Holding configuration is only needed for positive
secondary funding; under sufficient primary liquidity it is not used.

Use one genuinely provisioned capability store with noncolliding IDs across both
APIs, preserving the store across all execution. Existing single-operation fixture
IDs are not pasted into an unrelated overwritten store. No new executor/framework.

## Next decisive source branch experiment

Freshly compile a new branch adapter with the pinned solc0.8.29/settings/Cancun
using unchanged original dependency bytes. Bind new ABI/runtime and require empty
creation/runtime linkReferences. Keep exact source equity/priority/healthy-error
and insolvency-allowed/ordinary-revert excerpts, with explicit stubbed upstream
observations. Call actual unchanged getEmptyFees; preserve all copied GMX notices
and source terms. Stubbed calculations/storage/events receive no implementation
credit. Old runtime is reused only for old helper observations, never the new ABI.

Fresh controls: positive funding round-up/primary payment; positive secondary
funding and holding guard; healthy selected financial error with exact ABI args;
liquidatable priority/boundary successes; full liquidation/full ADL allowed early
return; ordinary and partial close refusal with exact residual/step; getEmptyFees
preserved claims/latest. Classify Solidity Panics/out-of-domain ABI errors separately
from financial reverts, VM/infrastructure faults and timeouts. EVM process exit0
alone is not semantic success. Preserve raw calldata/stdout/stderr/receipts.

Native negatives must separately challenge signed equity, actual PnL-as-cash
behavior, sourceResidual-zero economic-shortfall inference and claim/snapshot loss.
Reused accepted exact Payment/Funding/Realization evidence remains unchanged;
new source branches and full selected close execution receive fresh records only.
