# Sprint 2 contract implementation report

Task 1 is ready for integration/review. Implemented through the native GPT-6 Codex agent;
no Foreman, no commit, and no edits to the parent/other agent's files.

## Files and behavior

- `lean/DefiKernel/Contracts.lean`: generic executable trusted predicate, distinct contract/base
  failure, unchanged base-execution embedding, observation, nine general proofs.
- `lean/DefiKernel/ContractExamples.lean`: complete actor/effect/supply shape constraints for
  transfer, fixed-rate deposit/withdrawal, and borrow; independent oracle/collateral conditions;
  hostile fixtures and eleven general shape/constructor/collateral proofs.
- `lean/DefiKernel/ContractAcceptance.lean`: 43 kernel-checked finite comparisons with
  `by decide +kernel`. Positive operations observe all sixteen cells; refusals preserve exact reasons.
- `lean/DefiKernel/ContractAudit.lean`: executes the same 43 Boolean comparisons, refuses an
  empty list, prints all comparisons, and throws a specific error if any comparison is false.

`Core.lean`, `Examples.lean`, `Acceptance.lean`, and `Audit.lean` have no diff from HEAD.
No dependency changes. This task's four modules are stable for parent candidate capture.

## Verification and identities

Pinned tool output: `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`.
Measured source base: `95c1360709b6df4c85bcb32876a8e85b82036f57`; new contract inputs were untracked
at this implementation measurement. `mutation-run-2/source-manifest.json` records per-input
statuses, HEAD before/after, SHA-256 before/after, tool identity, and script hash. All captured
source hashes were unchanged after replay. Inputs are copied byte-for-byte into `inputs/`.

Commands run from `/home/charl/defiformal/lean` unless stated otherwise:

1. Before wrapper creation:
   `lake env lean /tmp/defiformal-sprint2-contract-evidence/InitialAcceptance.lean`.
   `initial-failure.log` contains the expected missing `DefiKernel.ContractExamples.olean`
   compiler error for concrete transfer-poststate/vault-drain refusal targets. The surrounding
   shell displayed the log last, so its exit code was masked; the captured compiler diagnostic
   is the initial-failure evidence. The same fixture now exits 0 (`initial-target-now-passes.log`).
2. Incremental `lake build DefiKernel.Contracts`, then `lake build DefiKernel.ContractExamples`:
   exit 0. Lean LSP reported no errors. Initial cosmetic warnings were repaired.
3. `lake build DefiKernel.ContractAcceptance DefiKernel.ContractAudit`: exit 0, 926 jobs;
   `module-build.log`. Only the existing Core header warning remains. All 43 checks true.
4. `lake env lean DefiKernel/ContractAudit.lean`: exit 0;
   `fresh-contract-audit.log`, 43/43 true comparisons.
5. `lake env lean /tmp/defiformal-sprint2-contract-evidence/PrintContractAxioms.lean`:
   exit 0; `contract-axioms.log`, 63 disclosures, all axiom sets contained in
   `propext`, `Classical.choice`, `Quot.sound`. This supplementary inventory used source names
   to request Lean's actual disclosures; it does not replace the other agent's automatic
   elaborated-environment discovery. Full names are in `theorem-inventory.txt` and below.

## Mutation replay

Portable driver: `/tmp/defiformal-sprint2-contract-evidence/replay_contract_mutations.py`.
Validated current output: `/tmp/defiformal-sprint2-contract-evidence/mutation-run-2/`.
Earlier run-1 is retained; run-2 adds the requested before/after Git/input-state checks.

To replay in a checkout, use a fresh output directory:

```bash
python3 /tmp/defiformal-sprint2-contract-evidence/replay_contract_mutations.py \
  --repo /home/charl/defiformal \
  --out /tmp/contract-replay-candidate \
  --expected /tmp/defiformal-sprint2-contract-evidence/mutation-run-2/source-manifest.json
```

`--expected` requires exact equality to the prior input SHA-256 mapping, independent of
checkout path and Git revision; omit it only when deliberately creating evidence for new inputs.
The parent may copy the portable script into the frozen review bundle and pass its new location.
The output directory must not already exist; setup failures use exit 3, sensitivity failures
exit 1, and a discriminating nonempty control plus both mutants exits 0.

The driver takes actual executable prefixes of Contracts and ContractExamples, with exactly
one explicit `-- BEGIN PROOFS` boundary per file and checked namespace closure. It excludes
the proof tails, removes only imports, and appends the entire actual ContractAudit body.
It imports/rebuilds the unchanged Examples/Core with pinned Lake dependencies. Proof tails
are excluded so runtime comparisons can evaluate intentionally defective implementations;
these temporary mutants are never accepted proof-library imports.

It hashes original sources, exact generated fixtures and logs. It checks command status and
requires all 43 uniquely named comparisons, unchanged positive controls, an explicit targeted
false comparison, and exactly the expected runtime comparison error. Compilation errors or
missing observations produce a blocked result, never a successful mutation verdict.

| Fixture | Lean exit | Comparisons | False comparisons |
| --- | --- | --- | --- |
| Actual unchanged executable definitions | 0 | 43 | 0 |
| `if contract.accepts s env t then` → `if true then` | 1 | 43 | 15 |
| independent `decide (BorrowConditions actor q s oracle)` → `true` | 1 | 43 | 6 |

The contract mutant includes `vault_drain_refused: false`; the environment mutant includes
`forged_isolated_zero_price_refused: false`, plus stale/future/feed/zero-price/excess-credit
refusals. All six successful-operation controls remain true in both mutants.
Exact false-name sets and argv/exit/log identities are in `mutation-run-2/results.json`.

## Proof boundaries and remaining integration

General wrapper success entails contract truth, actual base success, all `Valid` premises,
and exact `applyEffect`. Accounting, write locality and debit/supply authority follow only
under actual wrapper success. True-contract execution equals the embedded base result.
For arbitrary successful borrow proposals, shape plus independently checked conditions
establish the declared-price collateral inequality in the actual post-state.

Contracts are selected with trusted actor/amount/account parameters outside the proposal.
They compare complete finite effects and supply, not constructor tags, guard identity or
labels. Shape is extensional: self-transfer cancellation and other identical net effects
retain the existing semantics; this does not authenticate a nominal request history.
Write footprint and the proposal guard remain additional base checks. Replacing that guard
cannot remove the independent borrow requirements.

Scope remains four accounts, four assets, exact rational arithmetic, fixed vault rate two,
and supplied oracle/locked collateral meaning. There is no authentication, issuance/revocation,
serialization, general solvency, composition, deployment correspondence or completed migration
claim. These are development fixtures, not untouched holdouts.

Parent owns full integration, automatic axiom discovery, frozen source capture, committed-input
mutation replay, native Grok/Fable review, documentation, commits and push. No implementation
concern is currently open in this task. Review judgments do not replace Lean proof checking.

## Theorem inventory

- `DefiKernel.Contracts.liftBase_ok_iff`
- `DefiKernel.Contracts.run_ok_iff`
- `DefiKernel.Contracts.run_valid_update`
- `DefiKernel.Contracts.run_always`
- `DefiKernel.Contracts.run_contract_refused`
- `DefiKernel.Contracts.run_base_refused`
- `DefiKernel.Contracts.run_accounting`
- `DefiKernel.Contracts.run_locality`
- `DefiKernel.Contracts.run_authority`
- `DefiKernel.ContractExamples.shape_self`
- `DefiKernel.ContractExamples.transfer_shape`
- `DefiKernel.ContractExamples.deposit_shape`
- `DefiKernel.ContractExamples.withdraw_shape`
- `DefiKernel.ContractExamples.borrow_shape`
- `DefiKernel.ContractExamples.transfer_constructor_accepts`
- `DefiKernel.ContractExamples.deposit_constructor_accepts`
- `DefiKernel.ContractExamples.withdraw_constructor_accepts`
- `DefiKernel.ContractExamples.borrow_constructor_accepts_iff`
- `DefiKernel.ContractExamples.borrow_accepts_conditions`
- `DefiKernel.ContractExamples.borrow_run_collateral_bound`
- `DefiKernel.ContractAcceptance.transfer_post`
- `DefiKernel.ContractAcceptance.deposit_post`
- `DefiKernel.ContractAcceptance.withdraw_post`
- `DefiKernel.ContractAcceptance.borrow_post`
- `DefiKernel.ContractAcceptance.vault_drain_base_accepted`
- `DefiKernel.ContractAcceptance.vault_drain_refused`
- `DefiKernel.ContractAcceptance.unbacked_issue_base_accepted`
- `DefiKernel.ContractAcceptance.unbacked_issue_refused`
- `DefiKernel.ContractAcceptance.debt_erasure_base_accepted`
- `DefiKernel.ContractAcceptance.debt_erasure_refused`
- `DefiKernel.ContractAcceptance.wrong_recipient_base_accepted`
- `DefiKernel.ContractAcceptance.wrong_recipient_refused`
- `DefiKernel.ContractAcceptance.wrong_source_base_accepted`
- `DefiKernel.ContractAcceptance.wrong_source_refused`
- `DefiKernel.ContractAcceptance.unrelated_cell_base_accepted`
- `DefiKernel.ContractAcceptance.unrelated_cell_refused`
- `DefiKernel.ContractAcceptance.wrong_amount_base_accepted`
- `DefiKernel.ContractAcceptance.wrong_amount_refused`
- `DefiKernel.ContractAcceptance.wrong_actor_base_accepted`
- `DefiKernel.ContractAcceptance.wrong_actor_refused`
- `DefiKernel.ContractAcceptance.wrong_supply_refused`
- `DefiKernel.ContractAcceptance.forged_stale_base_accepted`
- `DefiKernel.ContractAcceptance.forged_stale_refused`
- `DefiKernel.ContractAcceptance.forged_zero_price_base_accepted`
- `DefiKernel.ContractAcceptance.forged_zero_price_refused`
- `DefiKernel.ContractAcceptance.forged_isolated_zero_price_base_accepted`
- `DefiKernel.ContractAcceptance.forged_isolated_zero_price_refused`
- `DefiKernel.ContractAcceptance.forged_future_base_accepted`
- `DefiKernel.ContractAcceptance.forged_future_refused`
- `DefiKernel.ContractAcceptance.forged_wrong_feed_base_accepted`
- `DefiKernel.ContractAcceptance.forged_wrong_feed_refused`
- `DefiKernel.ContractAcceptance.forged_excess_credit_base_accepted`
- `DefiKernel.ContractAcceptance.forged_excess_credit_refused`
- `DefiKernel.ContractAcceptance.forged_fresh_post`
- `DefiKernel.ContractAcceptance.zero_borrow_positive_price_post`
- `DefiKernel.ContractAcceptance.base_insufficient_refused`
- `DefiKernel.ContractAcceptance.base_unauthorized_refused`
- `DefiKernel.ContractAcceptance.base_footprint_refused`
- `DefiKernel.ContractAcceptance.base_guard_refused`
- `DefiKernel.ContractAcceptance.base_supply_refused`
- `DefiKernel.ContractAcceptance.always_base_accounting_refused`
- `DefiKernel.ContractAcceptance.withdraw_liquidity_refused`
- `DefiKernel.ContractAcceptance.withdraw_shares_refused`
