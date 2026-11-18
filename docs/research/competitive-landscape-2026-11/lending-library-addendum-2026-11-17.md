# Lending library capability addendum — 2026-11-17

This source/proof record supplements the
[historical competitive report](defiformal-competition-tech-strategy.html).
Its original HTML, source revision, cell statuses, benchmark classifications and
measurements remain unchanged. Separate exact-candidate review, delivery and
artifact records establish acceptance/publication; this note gives no outside
reproduction or adoption credit.

The historical `primitive:lending` cell was partial, with borrow-only coverage.
The new scoped `primitive:lending` status is **supported within this exact-rational reference API**.
New `DefiKernel.Lending` source provides five borrower-bound exact-rational public
operations through actual Typed execution, with explicit authority, declared
footprints and accounting. Historical `Typed.Examples.borrow` and the permissive
old debt-burn policy/counterexample remain unchanged.

| Operation | Actual effects and checked policy |
| --- | --- |
| [Repay](../../examples/lending-repay.md) | Transfer existing borrower cash to pool while reducing that borrower's debt and declared debt supply; nonnegative amount capped at debt, actual cash funding and rights. |
| [Borrow](../../examples/lending-borrow.md) | Transfer actual pool cash to borrower and increase owner debt/supply; locked-custody health after requested debt increase, positive fresh oracle, actual funding and rights. |
| [Accrue](../../examples/lending-accrue.md) | Increase current owner debt and supply by `D*r*dt`, with nonnegative rate/interval and no cash/collateral movement or health refusal. |
| [Deposit collateral](../../examples/lending-deposit-collateral.md) | Move existing free collateral to that owner's distinct locked custody, with actual funding/debit right, no minting or oracle/health-restoration requirement. |
| [Withdraw collateral](../../examples/lending-withdraw-collateral.md) | Move locked collateral to the same owner's free balance with quantity cap, positive fresh oracle and actual remaining-collateral health. |

Each operation has generic actual-execution/effect/accounting correspondence and
constructive success results, plus qualified refusal results and finite controls.
The finite per-operation inventories contain 17 repayment, 25 borrowing, 21
accrual, 18 deposit and 27 withdrawal comparisons. The separate lifecycle audit
executes all five actual APIs using one ledger and 13 genuinely issued,
noncolliding operation-scoped capabilities; its 8 comparisons include the entire
final finite ledger and refusal of withdrawal using borrow rights. This bounded
coherence evidence is not a general program-composition or solvency theorem.

Debt is a liability denominated one-for-one in cash, not cash itself. Cash and
collateral totals are conserved; debt total instead reconciles with signed debt
supply changes. Free and locked collateral are distinct cells of the same asset,
with separate custody for each borrower. Borrow/withdraw use lending/feed7,
collateral/cash price units, `p > 0`, inclusive age bounds
`observedAt <= now <= observedAt+5`, and health `2D <= Cp` at the observed price.
Authentication, registry correctness, oracle authenticity and clock truth remain
explicit input assumptions. Eager guard evaluation means missing/wrong-unit
oracle observations can refuse by evaluation before other guard conditions.

Accrual is deliberately unindexed: each call applies `D' = D*(1+r*dt)` to current
debt, so repeated supplied intervals compound again, not idempotently. Distinct
nonoverlapping real intervals and authentic rates are external obligations.
Actual controls distinguish health-threshold failure at zero equity from negative
equity and allow both accrual successes. No complete temporal lending protocol,
interest schedule, market solvency, bankruptcy, liquidation or deployed-source
fidelity is proved here. The historical `primitive:liquidation` unknown cell is
not changed by this lending evidence.

Operation mutations execute altered source bodies and fail exact runtime
comparisons; unchanged-proof compiler rejection is recorded separately. Named
axiom audits and kernel replays are mathematical evidence with their stated
trusted-import boundary. Public source runners freshly execute comparisons;
compiled artifact replay does not rerun `#eval`. Coverage is determined by the
particular archive's exact target manifest, not this note. Historical
per-component effort, independently measured separate-effort reuse, real outside
developer reproduction and corroborated adoption remain open.
