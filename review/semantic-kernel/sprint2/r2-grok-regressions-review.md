The prompt was truncated; I’ll read the full offloaded request first so the review uses the exact source, then stay inside the regression/mutation scope.**Scope:** regression and mutation evidence only. Semantics, Core identities, and audit/integration wiring are out of scope. Parent runs are accepted as reported, not re-executed.

## Verdicts

| Layer | Result |
|---|---|
| Spec (this scope) | **PASS** |
| Implementation (this scope) | **PASS** |

The 43 executable comparisons, two source-bound mutants, exact comparison diagnostic, path guard, and parent counts are consistent with the inlined sources. No blocking defect in this retry.

## Ranked findings (advisory)

**1. Mutation gate is sentinel-based, not set-based.**
`check-contract-mutations.py` requires one named false (`vault_drain_refused` / `forged_isolated_zero_price_refused`), six named positives true, a single `error: Contract runtime comparisons failed: N`, and a nonzero exit. It does **not** lock the parent-reported false sets (15 and 6 names). A weaker mutant that flipped only the sentinel could still exit 0. Full lists are stored in `results.json` / logs when the driver is run, but they are not the pass criterion.

**2. Per-asset accounting is witnessed only by same-asset `unbalanced`.**
`always_base_accounting_refused` catches +1 USD net (`pulse bob 2 − pulse alice 1`). `wrongAsset` (USD debit, share credit) is defined in `Examples.lean` and is **not** in the 43. A regression from per-asset accounting to global scalar cancellation would not fail this suite. Original `33/33` is not in this bundle.

**3. `wrong_supply_refused` has no `*_base_accepted` pair.**
Other shape failures show `check = none` then `.error .contract`. Supply-shape isolation is weaker than actor/cell/amount/borrow-condition pairs.

None of these falsify the claimed two-mutant design or the parent numbers.

## What the evidence actually covers

**Runtime (43 names, 1:1 with `ContractAcceptance` kernel theorems, `#eval` prints `name: bool`).**

Base execute, after a true predicate:

| Check class | Witness | Expected |
|---|---|---|
| Guard | `base_guard_refused` | `.base .guard` |
| Net-debit authority | `base_unauthorized_refused` (bob, amount 3) | `.unauthorizedDebit` |
| Supply authority | `base_supply_refused` (policy `supply := false`) | `.unauthorizedSupply` |
| Nonnegative | `base_insufficient_refused` (11 vs 10); `withdraw_liquidity_refused` (22 vs vault 20, `richShares`); `withdraw_shares_refused` (5 vs 4) | `.insufficientFunds` |
| Accounting | `always_base_accounting_refused` via `always Unit` | `.accounting` |
| Locality | `base_footprint_refused` / `wrongFootprint` | `.footprint` |

`wrong_actor` with amount **0** is the right shape-vs-authority split: base `check = none` (no net debit), contract `.contract`.

**`Contracts.run`:** each `*_refused` expects `.error .contract` while the paired base `check` is `none`. Happy posts match the ledger: transfer 3 → `[7,…,3,…]`; deposit 4 → alice 6 USD / 6 share, vault 24; withdraw 2 → 14 / 2 / 16; borrow 3 / `fresh` → 13 USD, debt 5, pool 97. Collateral 10 is unchanged.

**Borrow library constraints (independent conjuncts on `forgedBorrow`, not `Examples.borrow.guard`):** feed 8; `zeroPrice` and isolated `q=0`/`zeroDebt` (200% holds at price 0, so only `0 < price` fails); `future`; stale age 10; excess `q=9` (`2*(2+9)=22 > 10*2`). `forged_fresh_post` and `zero_borrow_positive_price_post` are the positives that must stay true under both mutants.

**Mutants (extraction, not proof modules):** `-- BEGIN PROOFS` prefixes of `Contracts` / `ContractExamples` + `ContractAudit` minus its `ContractAcceptance` import; uniqueness `count==1`; `if contract.accepts s env t then` → `if true then`; `decide (BorrowConditions actor q s oracle)` → `true`. That predicts **15** shape refusals false under accept-bypass and **6** borrow-condition refusals false under `BorrowConditions` bypass — matching parent `15 false of 43` and `6 false of 43`. Control: 43 true, no `: error:`.

**Binding:** hashes of Core/Examples/Contracts/ContractExamples/Acceptance/Audit + toolchain/Lake; git HEAD/porcelain; `sources_after`; evidence dir must be outside the repo (`exist_ok=False`). Parent: exit 3, exact diagnostic, no directory for repo-local `--out`.

## Limits

- `Contracts.lean` / `ContractExamples.lean` prefixes are not inlined; site uniqueness is taken from parent exit 0.
- No mutant of Core execute (guard, accounting, footprint, debit, supply).
- `forged_fresh_post` observes four cells, not `allCells`.
- No production, capability, composition, or solvency claim.
