# IV.4 lending lifecycle after AMM work

Implement a reusable reference-model lending API in a new namespace; preserve historical `Examples.borrow`, its permissive policy counterexamples and all theorem statements. The existing example's Alice collateral cell means declared locked collateral. Do not silently reinterpret it as an unlocked wallet.

Model free and locked collateral distinctly. Provide borrow, repay, interest accrual, collateral deposit and collateral withdrawal through actual kernel execution with declared authority, effects, supply changes and guards. Reuse existing accounting/transition mechanisms. Document the exact-rational model and its input assumptions; no deployed-protocol fidelity or market-price authenticity claim.

Repayment must transfer cash to the pool and reduce debt together, with insufficient-cash and over-repayment behavior specified. Accrual must record the debt increase explicitly without inventing a cash transfer; state the chosen rate/time convention. Collateral deposit moves an existing asset into locked custody. Withdrawal must check the remaining collateral against debt under the declared oracle contract. Borrow and withdrawal must keep oracle freshness, positive-price and collateralization assumptions explicit. Interest can make a position undercollateralized; do not claim preservation of solvency by assuming it in an accrual theorem or inventing a refusal just to make the claim pass.

Prove the actual operation/accounting effects and useful generic preservation/refusal results; run nonempty representative success and refusal cases for every operation. Include a decisive wrong-effect or missing-guard control against the real implementation. Preserve the older debt-burn-without-repayment negative result as evidence about that older policy, not as a theorem to rewrite.

Update the dated capability addendum only after all operations and their evidence are accepted. Keep the historical report unchanged. Ship a compiled evidence refresh for each accepted integration and preserve the external reproduction/effort limitations.
