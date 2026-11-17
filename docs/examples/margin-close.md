# Selected margin close payment prefix

`DefiKernel.Margin.Close` executes selected admission, two funded output legs and
ordered payments on one actual reference ledger. It ends at the payment-prefix
boundary. Kind `complete` means that prefix completed; it is not complete original
`processCollateral`, caller position removal, withdrawal/output handling, final
validation, bank custody or a deployed GMX handler.

Raw quoted primary output, primary position collateral and secondary output must
first equal the SAME actual pre-ledger cells. This wrapper validation refuses
fractional/inconsistent buckets before selected financial admission. Its footprint
reads those three cells; actual pool debits/funding are checked by the subsequent
Typed executor. Primary collateral is the long token, secondary the short token,
with NoSwap routing. Prices/amounts retain raw units, without decimal normalization.

The health equity is `C*pMin + markedPnl + healthImpact - (F+healthOtherFees)*pMin`.
`F` is the SAME position/factor funding quote; health-other fees exclude funding
and liquidation fees. `equity_funding_contribution` states its negative direction.
Source-priority admission tests equity below min collateral, nonpositive equity,
then equity below the leverage threshold. A healthy liquidation returns the exact
selected reason/equity/threshold refusal. ADL does not bypass a liquidation order's
guard. Only a non-liquidation order omits this selected guard. Source health impact
is a nonpositive capped observation; oracle truth, upstream source computations,
registry/authentication and earlier handler validation remain explicit assumptions.

Marked health PnL/impact and computed close base PnL/total impact are distinct
observations. No universal equality or source calculation is proved. After
admission, the model calls actual `Realization.run` first for positive close base
PnL, then for positive capped close impact. Each floors the payout at the SAME
selected PnL-token max price, debits the remaining actual selected pool, and credits
matching output. The reusable receipt parameter named basePnlUsd is labelled
separately by the outer base/impact fields. Index-impact-pool capping, ceil index
pool debit and its bookkeeping are upstream assumptions, not implemented Typed
index-pool accounting. No implicit or duplicated positive-PnL/impact cash is added.

The model then calls actual `Funding.run` and actual `PaymentSettlement.run` for
negative close PnL, nonfunding fee tokens*pMin, negative close impact, then positive
impact-difference USD. Funding and fees run even at zero; inactive signed cost
branches are skipped. Each next quote binds the actual previous post-buckets.
One genuinely issued store has eight noncolliding capabilities: funding/payment
IDs 0–3, holding claim IDs 4–5, realization IDs 6–7. The store persists throughout.
Physical payments credit a fixed reference costRecipient escrow. Subsequent GMX
fee receiver/pool/rebate/UI-fee/impact-pool allocation is not proved by this escrow.

The result retains actual executed pre/post states, cost/quote entries, the first
stopped stage/residual and later skipped active cost quotes. A positive source
residual permits exceptional helper success only when actual position size equals
sizeDelta AND the order is liquidation or secondary ADL. Otherwise the model
returns exact InsufficientFundsToPayForCosts(residual,step). Errors contain no
post-world and imply no observed rollback, atomicity or confidentiality result.
The residual belongs to one stage, not aggregate skipped debt or forgiveness.

Allowed exceptional returns zero represented charge fields and preserve pending
owner funding claims/latest factors. Fees also zero on secondary fee payment even
when source residual is zero, matching the selected source rule. Owner funding
claims remain separate from holding collateral claims and remain pending; caller
claim increments, snapshot/size commit and position removal are separate. No event,
insurance transfer or legal liability is invented.

`liquidation_correct`, `run_prefix`, `run_policy` and `run_pending` prove concrete
admission, exact active-cost prefix, first positive residual/eligibility and retained
claim metadata. `remaining_ordered` fixes source stage order. `run_chain` connects
all payment pre/post worlds to actual preparation, not unrelated ledgers.
`run_accounting` proves actual physical conservation, position/capability frame and
unchanged owner funding counters. `run_financial` binds every payment to its actual
pre/post ledger, the SAME native quote, raw remaining buckets and two-dust identity:
`cost + ceilDust = actualPaidUsd + sourceResidual + floorDust`.

Separate `constructive_solvency` assumes concrete arithmetic admission and initial
raw binding, sufficient actual selected pool custody for the SUM of both positive
floor payouts, then primary O+C plus derived primary payouts covering funding
primary tokens plus SUM of active ceil(cost/pMin) obligations, and genuine rights.
It constructs the whole actual execution, kind complete, nonnegative custody and
actual per-stage USD gains covering costs, with economic/source shortfalls zero.
It assumes no successful output or zero-residual certificate. A formal non-vacuity
witness uses funding 10/collateral 10, zero other costs/PnL/impact, equity 0 and real
issued rights. Exact zero-transfer execution can need fewer rights than the
stronger sufficient theorem.

Source residual zero alone does not imply economic payment. An actual complete
prefix with funding cost 1,pC 1,pS 2 and empty buckets pays nothing, returns source
residual 0/economic shortfall 1 and remains outside the sufficient primary budget.
Later-cost skipping and empty-fee claim retention are separately checked.
Rich fixtures with independently chosen marked/close observations are synthetic
reference-model controls, not evidence a complete original handler produces every
combination.

The pinned GMX source is `a85ea3491c19c93bb4b5a002d9b358fb769b7849`.
A fresh branch adapter compiles 91 unchanged original sources plus its wrapper,
with empty links and a new exact runtime/ABI. Its accepted 23 calls comprise 16
values, six financial reverts and one arithmetic Panic. Exact excerpts and explicit
upstream/store/event stubs give conditional branch observations; unchanged internal
funding/payment/getEmptyFees helpers are called. No full original handler/events or
storage execution is claimed. Two fresh Native Close admission calls compare all
nine projected input words and exact healthy error fields against two reused
accepted EVM records; they do not rerun EVM or establish universal refinement.
Other source campaign observations remain separate bounded evidence. Source
comparison additionally requires all uint256/int256 inputs/intermediates/casts to
fit, positive prices and valid upstream observation relationships. Native proofs
use unbounded integer amounts and nonnegative rational custody.

```sh
python3 scripts/replay_margin_close.py --toolchain /path/to/lean-4.33.0-rc2
```

With pinned dependencies, this builds the model and freshly runs 26 nonempty
fail-on-false comparisons, reporting model/dependency/tool hashes. Exit 0 means
finite comparisons passed, exit 1 contradiction/build failure, exit 3 missing,
empty, unreadable, unavailable input or timeout. Axiom audits/kernel replay are
separate; replay trusts imports and does not rerun controls or establish outside
reproduction. Six actual changed implementation probes fail runtime comparisons
and unchanged generic proofs separately: fee sign, ADL bypass, wrong cost order,
claim loss, fictitious pool cash and erasing economic shortfall. No intact Close
cache stands in for altered source.

[Component accounting](../../benchmarks/component-accounting/margin-close.json)
and the [dated addendum](../research/competitive-landscape-2026-11/liquidation-library-addendum-2026-11-17.md)
state scope and attribution. Historical report bytes/benchmarks remain unchanged.
Final independent acceptance/publication and effective matrix reconciliation are
separate records; historical effort, external reproduction/adoption, complete
handler/source refinement and the wider roadmap receive no completion credit here.
