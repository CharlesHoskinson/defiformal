# Oracle-guarded lending borrow (2026-11-17)

[Borrow.run](../../lean/DefiKernel/Lending/Borrow.lean) executes a registered Typed
cash loan for the bound borrower: pool cash decreases by quantity, borrower cash
and debt increase by quantity, and debt supply increases by that same amount.
One cash unit denominates one debt unit through explicit dimensioned conversion.
Cash/collateral totals are conserved; debt total reconciles with issuance.
Free and locked collateral cells remain unchanged.

The guard uses the borrower's **locked custody**, never the free collateral
wallet. It checks nonnegative quantity, a strictly positive collateral/cash price,
`observedAt ≤ now ≤ observedAt+5`, and
`2*(current debt cash value+quantity) ≤ locked collateral*price`.
The shared [oracle model](../../lean/DefiKernel/Lending/Oracle.lean) selects lending
feed7 with exact `price collateral cash` units. Oracle authenticity and clock truth
remain assumptions; the proof does not establish market solvency or deployed fidelity.

`template_evaluate` factors actual guard evaluation from the actual effects for
arbitrary environments. `guard_evaluate` proves equality with explicit Conditions
for any correctly typed observed price/timestamp. `actual_collateralization` derives
positive price, freshness and **actual post-debt health** from execution success
and that explicit oracle point; it does not assume post-health. `funded_success`
constructs execution from those admission conditions, actual pool cash funding
and real invoke/debit/supply rights, without a `Valid` or successful-output premise.
`actual_effects` and `actual_accounting` apply to actual successful execution.
Real administrative provisioning is proved exact for both borrowers.

The request always claims the selected borrower's principal. The private operation
registry and actual Typed actor check bind the literal borrower/custody targets.
Arbitrary low-level Typed requests are outside this public-entry-point claim.
Rights in the funded theorem are sufficient; zero borrowing can require invoke
alone, but still checks positive/fresh price and collateralization.

Typed Boolean operands evaluate eagerly. With binding/invoke passed, missing or
wrongly typed oracle values can yield evaluation refusals even when another guard
is false. Well-typed stale/future/nonpositive prices fail the guard. Actor/invoke
checks precede oracle evaluation. Pool funding is an actual kernel check after
policy admission, not assumed from collateral value.

[BorrowAudit](../../lean/DefiKernel/Lending/BorrowAudit.lean) checks 25 observations:
provisioning, both borrowers, fractional/zero loans, locked versus free custody,
post-increase debt, price and exact time boundaries, missing/wrong-unit/wrong-feed
data, funding, permissions, owner binding and per-asset totals. With installed
pinned Lean4.33.0-rc2 dependencies:

```sh
python3 scripts/replay_lending_borrow.py --toolchain /absolute/lean-4.33.0-rc2
```

The CLI builds current source, freshly evaluates controls, requires 25 unique
nonempty labels/completion, and records model/roles/oracle/support/control/tool
hashes. Intact returns 0; wrong expected cash returns 1. Missing, empty, unreadable
controls and empty inventory block with 3. Isolated byte-identical source/runner
fixtures protect frozen review files; installed dependency artifacts are shared.

Real API-prefix mutants admit an unhealthy loan by omitting requested debt from
the guard, or issue debt without cash movement. Both execute to explicit wrong
ledgers and fail comparisons; unchanged full proofs reject separately. The focused
math audit checks 140 theorem constants/125 supplemental declarations, forbidden 0;
standard named axioms only. All four new modules pass default same-kernel replay,
which trusts imports and does not rerun controls. Counts include generated/private
constants. Default build imports the controls and nonempty lending audit.

Accepted repayment and historical borrow/debt-burn evidence remain unchanged.
Accrual and collateral deposit/withdrawal remain separate slices under the
[accepted conventions](../../review/semantic-kernel/competitive-landscape-adoption-20261117/lending/CONVENTIONS.md).
IV.4/capability completion is not claimed here. The reference universe has two
borrowers, shared pool, separate custody, three assets and one domain. Authentication,
registry truth and aggregate net-effect semantics remain assumptions; an error
contains no post-world and proves no rollback. [Accounting](../../benchmarks/component-accounting/lending-borrow.json)
separates shared support/integration and records wall time, not active/person-hours
or recovered historical effort. Outside reproduction/adoption remain open.
