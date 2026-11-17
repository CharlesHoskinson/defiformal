# Borrower-bound collateral deposit

`DefiKernel.Lending.DepositCollateral` moves existing exact-rational collateral
from the intended borrower's free balance to that same borrower's distinct locked
custody cell. It calls actual Typed execution with a nonnegative collateral-unit
quantity, two declared writes and no state-expression or oracle reads. There is
no collateral supply creation, receipt token, cash transfer or debt change.
Literal owner/custody targets and a claimed-actor request bind the API to the
invocation principal. The private registry exposes only this operation; arbitrary
low-level requests are outside this public-entry claim.

`template_evaluate` and `run_ok_iff` connect the model to the actual executor.
`actual_effects` derives owner authentication, free balance minus quantity, own
locked custody plus quantity and unchanged capabilities. `actual_frame` preserves
every other cell, and `actual_accounting` conserves each asset total with zero
supply delta. `funded_success` constructs execution from nonnegative quantity,
actual free-balance funding and invocation/free-debit authority, without assuming
a successful result or Valid certificate. Real administrative provisioning and
rights are checked for both borrowers; authentication and registry truth remain
framework input assumptions.

Zero quantity permits invocation rights alone. Negative quantity is an exact
guard refusal once owner binding and invocation authority are established.
Insufficient free balance cannot succeed; existing locked collateral does not
fund this debit. The executable controls check the actual insufficientFunds
constructor after the other checks pass, and distinguish missing/wrong debit
rights and wrong-principal requests. Refusals return no post-world; no observed
rollback or intermediate debit ordering is claimed.

Deposit needs neither an oracle nor health restoration. The positive control
moves free/locked collateral `5/2 -> 4/3` with debt 100 and cash unchanged, so it
can leave the borrower unhealthy. `health_preserved_at_price` separately proves
that a successful deposit cannot worsen `2D <= Cp` at any explicitly supplied
nonnegative illustrative price. It does not fetch or authenticate that price and
does not claim to restore the inequality when it was false before the deposit.

With the pinned Lean 4.33.0-rc2 toolchain and project dependencies installed:

```sh
python3 scripts/replay_lending_deposit_collateral.py --toolchain /path/to/lean-4.33.0-rc2
```

The command builds the actual model and freshly executes 18 nonempty,
fail-on-false controls, recording source/dependency/tool hashes. Exit 0 means
those finite comparisons passed; 1 means a contradiction/build failure; 3 means
missing, empty, unreadable or unavailable inputs. Generic proofs, named axiom
disclosure and kernel replays are separate evidence. Kernel replay trusts imports
and is not an independent verifier or external reproduction. A wrong-custody
probe changes the actual credit and declared-write targets to the pool: execution
then produces free 4, own custody 2 and pool collateral 1. The expected custody
comparison fails; separately, the unchanged proofs reject the altered source.
It does not import the intact DepositCollateral cache as the mutant operation.

[Component accounting](../../benchmarks/component-accounting/lending-deposit-collateral.json)
classifies exhaustive hash-bound physical line ranges, excluding shared support.
The recorded prospective interval includes command waits and proof repairs; it
is not measured active effort or person-hours. Historical effort and the
separate-effort reuse scenario remain unavailable. Withdrawal, five-operation
coherence evidence, full IV.4, outside reproduction and deployed-source refinement
remain open here. Existing Types, Repay, Borrow and Accrue math is unchanged.
