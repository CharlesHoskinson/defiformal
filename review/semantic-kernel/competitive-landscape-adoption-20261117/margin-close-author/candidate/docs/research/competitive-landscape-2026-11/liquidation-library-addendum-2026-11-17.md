# Liquidation library capability addendum — 2026-11-17

This source/proof record supplements the
[historical report](defiformal-competition-tech-strategy.html). Its HTML, original
cell statuses, source revision, benchmark provenance and measurements remain
unchanged. Effective cell reconciliation requires separate independent acceptance
and final compiled-publication records; this note supplies no outside reproduction
or adoption credit.

The new evidence supports the following scoped interpretations for both report
matrices 1.1/1.2. **Supported** here always means the selected reference payment
prefix and its explicit assumptions, not a complete caller, handler or protocol.

| Historical cell | Historical status | Scoped evidence |
| --- | --- | --- |
| `cell:liquidation:liquidation_correctness` | unknown: not modelled | `Margin.Close.liquidation_correct`, `run_prefix`, `run_policy`, `run_chain`, `run_pending` and `run_accounting`: selected admission, actual two-cash-leg preparation, actual ordered Typed payments, first stopped source residual, full-size exceptional eligibility, pending claims/latest receipts, actual ledger chain/conservation. |
| `cell:liquidation:solvency` | unknown: not modelled | Separate `Margin.Close.constructive_solvency`: concrete admission, actual SUM pool budget, SUM rounded primary budget and genuine rights construct actual completion, nonnegative custody and actual per-cost economic coverage. |
| `primitive:liquidation` | unknown: planned P27 | Supported within the declared signed-margin/NoSwap reference admission/preparation/payment-prefix API, with conditional source branch observations. Caller removal/withdrawal/output handling, complete source storage/handler refinement and unconditional market solvency are excluded. |

The [API guide](../../examples/margin-close.md) states exact assumptions. Funding
uses ceil fees/floor pending claims at denominator 10^45 and separates negative
health expense from actual custody movement. Source health/marked PnL and close
base PnL/impact are explicit different observations, without an invented equality.
Two actual pool-funded floor payouts occur in order: positive close base PnL, then
positive capped close impact. Source index-impact-pool capping/debit remains an
upstream observation/bookkeeping assumption, not implemented Typed index-pool
accounting. No PnL or claim counter silently creates physical cash.

The payment order is funding, active negative close PnL, nonfunding fees, active
negative close impact, then positive impact-difference cost. One ledger and eight
genuinely issued, noncolliding operation-scoped capabilities serve all calls.
Actual payments credit a fixed reference costRecipient escrow; this is not the
subsequent source fee/pool/UI-fee/rebate or impact-pool allocation proof. Source
residual, exact economic shortfall, skipped quoted costs and pending claim metadata
remain separate. Allowed exceptional helper success requires actual full-size
comparison and liquidation/ADL eligibility. ADL never bypasses a liquidation
admission guard. Empty fees preserve owner claims/latest snapshots; caller commits
and position removal remain separate.

The simple formal constructive witness pays funding 10 from collateral 10 at
equity 0, with zero other costs/PnL/impact and real rights. Conversely, a complete
source-residual 0 prefix can pay nothing and retain economic shortfall 1. The latter
refutes a zero-residual=>fully-paid inference and does not satisfy the concrete
solvency budget. The theorem is conditional coverage, not a claim that every
liquidatable position is solvent or that exceptional bankruptcy means rollback,
insurance, debt forgiveness or a whole handler transaction executed.

The source pin is GMX `a85ea3491c19c93bb4b5a002d9b358fb769b7849`.
The frozen newly compiled branch adapter has 23 observations: 16 returned values,
six exact financial reverts and one arithmetic Panic. Exact source excerpts,
unchanged internal funding/payment/getEmptyFees calls, explicit upstream/stored
observation stubs and skipped event/storage paths define its boundary. Two fresh
Native Close admission comparisons reuse two accepted EVM records with identical
nine-word inputs/error fields; they add no new EVM executions or universal
simulation claim. Original source/excerpt notices and terms remain intact.

The new source runner executes 26 actual fail-on-false controls, including both
cash-leg funding, healthy refusal, ordinary/partial refusal, allowed bankruptcy,
later-cost skipping, secondary-fee metadata emptying and pending claims. Rich
independent observation fixtures remain synthetic reference controls. Six altered
Close implementation probes produce false runtime comparisons; unchanged-proof
compiler rejection is recorded separately. Named axiom audits and kernel replay
have their trusted-import boundary. Compiled coverage is determined by the exact
artifact target manifest; it does not rerun `#eval` or constitute outside review.

Actual matrix/status moves require final acceptance plus publication, as recorded
separately. This note does not edit the historical HTML or complete unavailable
historical authoring-effort measurements, separate-effort reuse, external
reproduction/adoption, universal/deployed refinement or the wider roadmap.
