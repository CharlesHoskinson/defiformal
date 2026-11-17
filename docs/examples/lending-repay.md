# Lending repayment reference API (2026-11-17)

[Repay.run](../../lean/DefiKernel/Lending/Repay.lean) executes a registered Typed
repayment: cash moves from the borrower to the pool, while that borrower's debt
and declared debt supply both decrease. One cash unit denominates one debt unit,
using explicit dimensioned conversion. Debt is a liability, not spendable cash.
The guard requires `0 ≤ quantity ≤ outstanding debt`; overpayment refuses rather
than clamping. Insufficient cash is checked by actual kernel execution. No oracle
or health-restoration condition is imposed: unhealthy positions can repay.

The [shared roles](../../lean/DefiKernel/Lending/Types.lean) distinguish Alice/Bob,
the pool, each borrower's separate locked-collateral custody and administration.
Free/locked collateral use the same asset at distinct accounts. Repayment changes
neither. The constructed request binds claimedActor to the selected borrower;
success proves the authenticated actual caller matches. The private registry
exposes only this implemented operation. Arbitrary low-level Typed requests are
outside this public entry-point claim. Real administrative capability provisioning
is proved exact for both borrowers; no fallback store replaces a provisioning error.

`actual_effects` proves coupled cash/debt changes, cap/nonnegativity and borrower
binding. `actual_accounting` conserves cash/collateral and reconciles debt total
with its negative supply delta. `funded_success` derives actual execution from
cash funding, the debt cap and real invoke/debit/supply rights, without a `Valid`
or successful-output premise. Those rights are sufficient; zero repayment can
execute with invoke alone. `run_ok_iff` retains the exact actual checks.
`over_repay_refusal` proves guard refusal with binding/invoke, and
`insufficient_cash_ne_success` excludes success when cash is inadequate.

[RepayAudit](../../lean/DefiKernel/Lending/RepayAudit.lean) checks 17 observations:
real provisioning, both borrowers, fractional/full/zero repayment, unchanged
collateral, caps, funding, permissions, overgranted wrong-caller rights, and
per-asset totals. With installed pinned Lean4.33.0-rc2 dependencies:

```sh
python3 scripts/replay_lending_repay.py --toolchain /absolute/lean-4.33.0-rc2
```

The CLI builds current repayment source, freshly evaluates its controls, checks
17 nonempty unique labels/completion, and records model/role/control/tool hashes.
Intact returns 0. A wrong expected cash balance returns 1 after a false comparison;
missing, empty, unreadable controls and empty inventory block with 3. Negative CLI
controls use byte-identical source/runner in an isolated project-build fixture;
installed dependency artifacts are shared. The default kernel entry point imports
the lending controls and nonempty axiom audit.

Actual source-prefix mutants burn debt without moving cash or omit owner binding.
Both execute to explicit wrong money/owner observations and fail comparisons;
unchanged full proofs reject separately. Model-prefix probes omit semantic proofs
and the own-module import, preserving real implementation bodies. The focused
math audit checks 141 theorem constants/119 supplemental declarations, forbidden 0;
standard named axioms only. Types/model/control kernel replay uses the same kernel
and trusts imports. These counts include generated/private declarations.

The original [permissive debt-burn result](../../lean/DefiKernel/Acceptance.lean)
and historical borrow remain unchanged. This is the first operation in the new
family; borrow, accrual and collateral movement remain separate implementation
slices under the [accepted conventions](../../review/semantic-kernel/competitive-landscape-adoption-20261117/lending/CONVENTIONS.md).
IV.4 and its capability update remain open. Authentication/registry truth and
aggregate net-effect semantics remain framework assumptions; errors return no
post-world and prove no rollback. No deployed fidelity/outside adoption is claimed.
[Accounting](../../benchmarks/component-accounting/lending-repay.json) separates
shared role support and integration, records shared wall time, and leaves active,
human/person-hours and historical per-component effort unknown.
