# Exact-rational lending reference API: conventions, 2026-11-17

This is a new `DefiKernel.Lending` namespace and reference API. Historical
`Typed.Examples.borrow`, declared locked collateral, old permissive debt-burn
policy and all original theorem statements remain unchanged. First implementation
slice is actual repayment; the other operations below remain planned until built.

The finite universe has borrowers Alice/Bob, one shared cash pool, a distinct
locked-collateral custody account for each borrower, and an administrative account.
Assets are cash, collateral and debt; there is one lending domain. Free collateral
is the borrower's collateral cell; locked collateral is the same asset at that
borrower's separate custody cell. Deposit/withdraw move it between those two cells,
with no collateral supply creation or receipt token. Debt belongs to the borrower,
not the custody account. Owner-to-party/custody maps are explicit and distinct.

Debt denomination is exactly one cash unit per debt unit, expressed with Typed
price/conversion operations. Debt is an accounting liability, not spendable cash
or a pool cash asset. Borrow increases debt and its declared debt supply while
transferring existing pool cash to the borrower. Repay transfers existing borrower
cash to the pool and burns the corresponding debt plus negative debt supply.
Repay amount is cash-denominated: require `0 ≤ amount ≤ outstanding debt cash value`.
Over-repayment refuses by guard; there is no clamp, donation or silent forgiveness.
Insufficient cash remains an actual Typed insufficientFunds refusal. Repay/deposit
do not consult an oracle or require health restoration, including unhealthy debt.
All transfer quantities permit zero. Borrow zero still checks price/freshness;
withdraw zero still checks the specified post-withdrawal health condition.

Accrual uses exact rational nonnegative rate r per abstract time unit and caller-
supplied nonnegative elapsed duration dt. Each call computes increment D*r*dt
from current debt D, adds it to that borrower's debt and debt supply, and moves
no cash/collateral. There is no persistent last-accrual timestamp or replay guard.
Repeated application of the same supplied interval accrues again: twice yields
D*(1+r*dt)^2, generally different from one call with duration 2*dt. Interpretation
as distinct/nonoverlapping real intervals and rate authenticity are external
caller/configuration assumptions. No elapsed-time lifecycle fidelity or replay
protection is claimed. A later time-indexed API would be a separate obligation.
Accrual has no health guard: it may successfully turn a healthy position unhealthy.
Proofs will preserve nonnegativity/accounting and explicitly demonstrate that case,
rather than assuming post-solvency or inventing an insolvency refusal.

Borrow and collateral withdrawal use observation key lending/feed7, units
`price collateral cash`, a strictly positive price, and freshness
`observedAt ≤ now ≤ observedAt+5`. Oracle truth/authenticity remains assumed.
Health means `2 * debt cash value ≤ locked collateral * price`. Borrow checks
post-increase debt, actual locked custody and actual pool cash funding. Withdrawal
checks nonnegative quantity, quantity ≤ locked collateral, and the remaining
locked collateral against current debt; it never counts free collateral.
Missing/wrong-unit observations can be evaluation refusals before guard rejection:
Typed Boolean expressions eagerly evaluate all operands, even if another guard
is false. Future/stale/nonpositive-price observations with well-typed supplied
values are guard failures. Exact observable constructor/priority claims will be
confirmed against actual registered execution; they are not inferred from prose.

Every public operation binds the intended borrower through a constructed request
with claimedActor=that borrower's party and uses the authenticated context passed
to actual Typed.execute. Literal borrower/custody targets and the actual actor
check prevent a successful public call from acting for a different principal.
Request construction/registry selection are part of this reference API; arbitrary
low-level Typed requests are outside its secured entry-point claim. The registry
will contain only borrow, repay, accrue, collateral deposit and withdrawal. No
arbitrary debt-burn operation is exposed. Op IDs: borrow0, repay1, accrue2,
depositCollateral3, withdrawCollateral4; unavailable operations remain unknown
until their implementation slice is accepted. Rights are operation-scoped invoke,
actual debit and debt changeSupply grants. Administrative provisioning uses the
existing capability API; authentication/registry truth remain framework assumptions.

All operations call actual registered Typed execution with declared reads,
observations, writes and supply effects. Cash/collateral totals are conserved;
debt total instead reconciles with its signed supply delta. No all-asset constant-
total claim is made for debt issuance/accrual/burn. Checks use aggregate net effects,
not intermediate debit ordering, allowances, reentrancy or transactional rollback.
Errors return no post-world. First decisive regression: repay1 on cash3/pool10/
debt2 must produce cash2/pool11/debt1 with custody unchanged; over-repay and
insufficient-cash controls isolate the actual guard and funding mechanisms.
A zero-cash-movement debt-burn mutant must execute to the wrong accepted ledger,
separate from unchanged-proof compiler rejection. No capability-cell update occurs
until all five operations and their evidence are independently accepted.
