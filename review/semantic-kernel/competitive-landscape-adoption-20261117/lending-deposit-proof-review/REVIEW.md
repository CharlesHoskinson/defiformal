# Collateral deposit proof/runtime review

ACCEPT_WITH_LIMITATIONS. No required repair.

Exact baseline a9c46eb4c19130d7c7bec342b0d06fd295eb1c30. All three frozen file hashes and lengths match. The isolated reviewer baseline matched all252 tracked Lean/configuration inputs before candidate copying. INPUTS.json binds exact inputs and author evidence; original financial proofs and prior lending operations remain unchanged.

Actual run uses a private borrower-specific registry, a claimedActor-bound request and the existing Typed executor. Two same-asset deltas debit that borrower's free collateral and credit their distinct custody; no supply delta exists. Declared reads/observations are empty because the expressions use only the argument, while actual transition funding checks the debit against the ledger. Explicit write cells cover both effects. Real administrative provisioning and sufficient invoke/free-cell debit rights are proved for both borrowers.

actual_effects derives ownership, nonnegative quantity, exact free/custody balances and unchanged capabilities from actual success. actual_frame preserves every other cell, including debt, cash and other borrowers. actual_accounting proves conservation for every asset. funded_success derives actual Valid and constructs a result from quantity nonnegativity, actual free funding and real rights; no opaque Valid, assumed success, health or oracle premise appears. A zero transfer may need only invoke authority, as the finite control demonstrates; the generic funding theorem's debit right is sufficient, not claimed necessary.

negative_quantity_refusal proves exact guard refusal after owner/invoke premises, preserving earlier actual refusals. insufficient_free_ne_success proves generic non-success for underfunding; it is not an unqualified exact-constructor theorem. Separate finite controls observe insufficientFunds with otherwise admitted inputs and show a large locked balance cannot fund a free-cell debit.

health_preserved_at_price is an algebraic preservation theorem: given actual success, an explicit nonnegative price and a pre-existing factor-two health inequality, unchanged debt plus increased custody preserves that inequality. There is no oracle query/authentication/freshness claim, no assumption that every deposit starts healthy and no claim that it restores unhealthy positions. The actual debt100 positive-deposit controls demonstrate successful operation without health restoration.

Independent checks passed: targeted Lending.Verify build, fresh18/18 actual source controls, scoped139 theorem constants/128 supplemental declarations with forbidden0, both new module kernel replays, intact prefix, wrong-custody runtime failure and unchanged-proof rejection. Generated/private constants are included in audit counts; standard axioms propext, Classical.choice and Quot.sound are disclosed. The mutant changes both actual credit and declared write target to pool, so it really succeeds to free4/ownlocked2/poolcollateral1/debt100 before the custody comparison fails. Its runtime prefix does not import cached intact DepositCollateral. Full-proof rejection remains a separate observation.

Limits: exact rational reference lending and framework authentication/registry assumptions, net-effect execution, same-kernel trusted imports. Finite observations do not replace generic proofs. Public CLI/docs and compiled package/publication remain separate. Withdrawal/lifecycle coherence and IV.4 remain open; no deployed refinement, outside reproduction or historical effort claim.

Requested reviewer: gpt-6-astra, medium. Actual provider-returned model/effort identity is unavailable and no attestation is claimed.
