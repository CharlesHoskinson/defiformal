# Borrow proof review

ACCEPT_WITH_LIMITATIONS. No required repair.

Exact baseline: `02261bc20db515b91a1c706ebe9c3ec3900b2dc6`. All five frozen file hashes and lengths match. INPUTS.json records full identities and evidence hashes. Before copying the candidate into the isolated cached baseline, all 246 tracked Lean/configuration inputs matched baseline Git objects. Historical borrow/debt-burn sources remain unchanged.

The public API selects the borrower-specific registry and constructs claimedActor, so actual Typed execution enforces principal ownership before invocation and observation evaluation. Literal borrower/custody cells are distinct. Administrative provisioning calls issueCapability and is proved to yield the fixture store for both borrowers. Pool debit and debt supply rights are operation-scoped. The constructive success theorem requires sufficient rights; it does not claim these rights are necessary for a zero-amount call.

The actual eager expression requires nonnegative quantity, strictly positive collateral/cash price, observedAt ≤ now ≤ observedAt+5, and twice post-increase debt bounded by locked custody value. guard_evaluate bridges the expression to Conditions for the supplied well-typed oracle point. success_conditions and actual_collateralization derive this policy and actual post-state health from success; they do not assume health closure. funded_success derives Valid from explicit policy, liquidity and rights and constructs the resulting world without a Valid or successful-result premise.

Actual effects transfer existing pool cash to the borrower and issue equal debt/supply at rate one. Cash and collateral totals are conserved; debt total increases by quantity. Collateral is framed for every party, and run_ok_iff plus effect_outside frames other cells. Supply is the transition's declared accounting delta, not a separate global supply register. This is the existing Typed net-effect semantics.

Independent verification passed: targeted Lending.Verify build; fresh 25/25 actual execution controls; scoped audit 140 theorem constants and 125 supplemental declarations, forbidden=0; all four new module kernel replays; intact runtime prefix; both actual mutated-body regressions; and both unchanged-proof mutant compile rejections. Standard reported axioms are propext, Classical.choice and Quot.sound. Generated/private theorem constants are included in audit counts. Logs and exact command identities are in independent-verification.json.

Controls explicitly distinguish missing/wrong-unit observations from guard failures, eager missing observation with negative amount, owner/invoke precedence, age boundary, free versus locked collateral, insufficient liquidity, missing debit/supply rights, and zero amount with invoke-only capability. These are finite constructor/priority observations, not a newly proved exhaustive refusal-classification theorem. Runtime mutations execute unhealthy cash5/pool8/debt4/locked3 and missing-cash-transfer cash3/pool10/debt5 ledgers and fail their comparisons; full-proof failures are separate. Neither runtime mutation imports cached intact Borrow.

Limits: oracle authenticity, clock truth, registry/configuration and context authentication remain framework assumptions. Exact rational reference lending is not deployed-market refinement or global solvency. Accrual and collateral movement remain future work. No IV.4 closure, public CLI acceptance, compiled-package acceptance, outside reproduction or historical effort credit follows from this proof review.

Requested reviewer: gpt-6-astra, medium. Actual provider-returned model/effort identity is unavailable in this runtime; this report does not attest it.
