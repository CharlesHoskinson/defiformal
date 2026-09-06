# R2 bounded kernel remediation — implementer report

All requested Fable R1 source findings were handled using the parent's minimum-scope decision.
Grok R1 added no findings. No kernel access-control redesign was introduced; the policy limitations
are now executable accepted counterexamples. Only Examples, Acceptance and Audit changed. Core,
the root import and lakefile remain unchanged from R1. No commit or reviewer invocation was performed
by this implementer. No source edits followed the R2 freeze notice.

## Review findings and changes

1. **Fixture grants are not bound to transition shape.** Before editing source, a scratch Lean probe
   checked Fable's three exact transitions against R1. It compiled with exit 0, and all three `#eval`
   results were `none` (accepted). The probe is `/tmp/defiformal-kernel-r2-review-probe.lean`, with full
   output in the adjacent `.log`. The revised source adds named fixtures `policyVaultDrain`,
   `policyUnbackedIssue` and `policyDebtBurn`, three accepted-check theorems, three execute post-state
   theorems and six corresponding runtime comparisons. Observed results:
   - Vault drain: Alice USD 30, vault USD 0, Alice shares 4. No shares burned.
   - Unbacked issue: Alice USD 10, vault USD 20, Alice shares 104. No deposit occurred.
   - Debt burn: Alice USD 10, pool USD 100, Alice debt 0. No repayment occurred.
   The policy docstring explicitly says it is not a protocol access policy and names these behaviors.
2. **Positive-price guard isolation.** `zeroDebt` has no Alice debt. A zero-amount borrow with a fresh
   zero-price observation fails the guard, while the corresponding positive-price case accepts.
   The collateral inequality is true in the zero-price case, so this test isolates strict positivity.
   A new mutation deletes only `0 < oracle.price` from `borrow`; exactly
   `isolated_zero_price_refused` becomes false, while the original non-isolated zero-price case stays true.
3. **Liquidity docstring.** It now states that twenty USD cannot redeem the requested eleven shares,
   despite twenty shares being held. The actual executable fixture is unchanged.
4. **Mutation completeness and provenance.** The portable recipe accepts required `--repo` and
   `--output` paths. It includes all twenty-two check-based Acceptance theorems before the first
   execution observation and compares that set with every check-based theorem in the complete file.
   It records input hashes, captured HEAD, complete and input-specific dirty status, recipe hash,
   toolchain, lakefile and lake-manifest hashes, exact commands and generated-source hashes.
   Input source bytes are rechecked after the run. Runtime booleans must be present for every contract;
   a compiler error without a false comparison does not count as mutant discrimination.
5. **Axiom coverage.** The manually maintained print list was regenerated and compared one time to
   every named theorem in Core, Examples and Acceptance, then to the actual fresh axiom output.
   All three lists contain exactly fifty-one matching names. Evidence is
   `/tmp/defiformal-kernel-r2-axiom-coverage.json`. This comparison does not create an automatic future
   theorem-discovery mechanism in Lean; parent will document that maintenance boundary.

New acceptance statements were written before their named fixtures existed. The initial contract
check failed due to missing helpers (exit 1); this is missing-feature evidence, not a financial
counterexample. The reviewer counterexamples themselves were independently confirmed first by the
successful scratch probe described above.

## Observed checks

Lean working directory: `/home/charl/defiformal/lean`.

| Command | Exit | Evidence |
|---|---:|---|
| `lake env lean /tmp/defiformal-kernel-r2-review-probe.lean` | 0 | Three accepted check results; adjacent `.log` |
| `lake env lean DefiKernel/Acceptance.lean` before new fixtures | 1 | `/tmp/defiformal-kernel-r2-contract-red.log` |
| `lake build DefiKernel.Acceptance` | 0 | `/tmp/defiformal-kernel-r2-acceptance.log`, 923 jobs |
| `lake build DefiKernel` | 0 | `/tmp/defiformal-kernel-r2-build.log`, 926 jobs |
| `lake env lean DefiKernel/Audit.lean` | 0 | `/tmp/defiformal-kernel-r2-audit.log`, 33/33 runtime and 51 axiom lines |
| `lake build` | 0 | `/tmp/defiformal-kernel-r2-full-build.log`, 988 jobs |
| `git diff --check` from repo root | 0 | No output |
| `python3 /tmp/defiformal-kernel-r2-check-mutations.py --repo /home/charl/defiformal --output /tmp/defiformal-kernel-r2-mutations` | 0 | `/tmp/defiformal-kernel-r2-mutations.log` and output directory |

Counts are separate: 37 Acceptance theorems = 22 check behaviors + 11 execution observations +
4 negative witnesses. Runtime executes the 33 check/observation comparisons. There are 51 total
named theorems across the three source modules. Seven mutation probes each evaluate all 22
check comparisons; they do not mutate execution or sequence behavior.

The six generic-check mutants and the positive-price-only mutant each produced exit 1 with explicit
false runtime comparisons. The unchanged control produced exit 0 and 22/22 true comparisons.

| Mutation | False comparisons |
|---|---|
| guard | stale_oracle_refused, zero_price_refused, future_oracle_refused, excess_credit_refused, wrong_feed_refused, isolated_zero_price_refused |
| debit | transfer_unauthorized |
| supply | unauthorized_issue_refused |
| nonnegative | transfer_insufficient, insufficient_shares_refused, insufficient_vault_liquidity_refused |
| accounting | unbalanced_refused, wrong_asset_refused |
| footprint | wrong_footprint_refused |
| positive_price_only | isolated_zero_price_refused |

## Provenance and remaining limits

This implementer run used a dirty precommit source snapshot. Its captured HEAD was
`150c2accb31700d2c7267eb8152b02d36c815605`, and `input_sources_dirty_at_capture` is
`true`. That HEAD alone does not identify the revised sources;
the input hashes in `results.json` identify the exact bytes tested. Parent will replay the same recipe
after committing the revised candidate so its review results bind the clean candidate.

R1 artifacts remain unchanged. The R2 recipe and generated sources/logs/results use new R2 paths.
The mutation lift checks the real checker, example fixtures and all check contracts; it excludes
execution, constructor proofs and multi-step theorems. Passing the unmodified control prevents an
empty or malformed lift from being reported as successful mutation testing.

No semantic restriction was added to the fixture policy. Vault drains, unbacked share issuance and
debt erasure remain accepted by design in this bounded example. The code now shows this directly.
Economic authority must later bind grants to operation constraints. Oracle feed, price and timestamps
remain declared values, and declared collateral locking has no global enforcement. Quantity asset
indices distinguish input types, but rates and extracted raw rational effects do not provide a complete
checked unit system. No complete composition, solvency, liveness, deployed fidelity, serialized IR,
certificate-checker or machine-arithmetic claim follows from these results.

## Frozen source hashes

- `lean/DefiKernel.lean`: `3d183700381dc42b3ccea34037d56f4a4dffff5b086ad558d1d97a3b128c83fa`
- `lean/DefiKernel/Core.lean`: `767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d`
- `lean/DefiKernel/Examples.lean`: `3a3eaf5e43e5a98cb179785789e850d333652a60f112cba9b0df5ce80bf26d28`
- `lean/DefiKernel/Acceptance.lean`: `9635558b7bb16a66375358a4936ec73d7ea4b07ee959bf3d2583197584e7ff11`
- `lean/DefiKernel/Audit.lean`: `7843c62e722e2c218e44c532d0f850f66c7ab7eed18715bc5a03dc773b17d400`
- `lean/lakefile.toml`: `4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86`

## Exact axiom disclosures

```text
'DefiKernel.check_eq_none_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.applyEffect_accounting' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.applyEffect_locality' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.applyEffect_frame' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.execute_ok_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.execute_authority' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.execute_accounting' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.execute_locality' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.Examples.transfer_accounted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.Examples.deposit_accounted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.Examples.withdraw_accounted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.Examples.borrow_accounted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.Examples.allCells_complete' depends on axioms: [propext]
'DefiKernel.Examples.borrow_declared_collateral_bound' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.transfer_accept' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.transfer_unauthorized' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.transfer_insufficient' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.deposit_accept' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.withdraw_accept' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.borrow_accept' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.stale_oracle_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.zero_price_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.future_oracle_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.excess_credit_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.unbalanced_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.wrong_asset_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.wrong_footprint_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.unauthorized_issue_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.wrong_feed_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.insufficient_shares_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.insufficient_vault_liquidity_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.isolated_zero_price_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.zero_borrow_positive_price_accept' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.policy_overgrant_vault_drain_accepted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.policy_overgrant_unbacked_issue_accepted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.policy_overgrant_debt_burn_accepted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.transfer_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.deposit_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.withdraw_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.borrow_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.vault_round_trip' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.repeated_borrow_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.unauthorized_execute_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.self_transfer_noop' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.policy_overgrant_vault_drain_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.policy_overgrant_unbacked_issue_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.policy_overgrant_debt_burn_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.wrong_asset_scalar_cancels' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.wrong_asset_not_accounted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.unbalanced_not_accounted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.missing_footprint_changes_balance' depends on axioms: [propext, Classical.choice, Quot.sound]
```
