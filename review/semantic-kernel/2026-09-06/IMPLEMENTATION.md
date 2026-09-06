# Bounded Lean semantic kernel pilot — implementer report

Implementation is complete in the six owned source paths listed below. No commit, external reviewer,
Foreman process, or publishing action was performed by this implementer. Parent owns integration and review.
Sources were frozen before report collation; no source edits followed the freeze notice.

## Delivered semantics

- A fixed finite identity universe: four Account constructors, four Asset constructors, sixteen cells.
- `Quantity a` is nonnegative exact rational quantity in asset `a`; `State` carries a proof of nonnegative
  balances at every cell. There is no machine width, overflow behavior, or integer rounding model.
- `Transition E` has actor, net signed cell effects, per-asset supply changes, a declared write set,
  and a State/environment guard. All examples use this representation and the same executable checks.
- `check` returns the first refusal: guard, unauthorized net debit, unauthorized supply change,
  negative resulting balance, asset accounting mismatch, or undeclared changed cell.
- `execute` returns either a refusal without a post-state or a constructed nonnegative post-state.
  `execute_ok_iff` connects actual execution to every checked condition and its precise update.
- Generic accounting and authority theorems concern each asset separately and net effects.
  Locality protects cells outside writes. The frame theorem explicitly requires the predicate to depend
  only on those protected observations; it does not infer this dependency.
- Reference examples: general-account USD transfer; Alice's deposit/withdrawal in a vault with exact
  rate two USD per share; Alice's borrowing from a pool with equal debt-token creation.
- Credit checks declared feed 7, positive price, age at most five, no future observation, and a
  200% collateral bound using pre-state debt and declared locked collateral. A theorem proves the
  corresponding post-state bound after successful borrowing, using the declared price.

## Checks and observed exits

Working directory for Lean commands: `/home/charl/defiformal/lean`.
Full logs are preserved under `/tmp`; parent should copy the final evidence into its review bundle.

| Command | Observed exit | Full log / result |
|---|---:|---|
| `lake env lean DefiKernel/Acceptance.lean` before Core/Examples existed | 1 | `/tmp/defiformal-kernel-red.log` |
| `lake env lean DefiKernel/Core.lean`, first pass | 1 | `/tmp/defiformal-kernel-core-1.log` |
| `lake env lean DefiKernel/Core.lean`, repaired imports/proofs | 0 | `/tmp/defiformal-kernel-core-2.log` |
| `lake build DefiKernel.Examples`, first/second pass | 1, 1 | `/tmp/defiformal-kernel-examples-1.log`, `-2.log` |
| `lake build DefiKernel.Examples`, third pass | 0 | `/tmp/defiformal-kernel-examples-3.log` |
| `lake build DefiKernel.Acceptance`, initial ordinary decide | 1 | `/tmp/defiformal-kernel-acceptance-1.log` |
| `lake build DefiKernel.Acceptance`, kernel decide | 0 | `/tmp/defiformal-kernel-acceptance-2.log` |
| `lake env lean DefiKernel/Acceptance.lean` before observation helpers | 1 | `/tmp/defiformal-kernel-observation-red.log` |
| `lake build DefiKernel.Acceptance`, expanded fixture first pass | 1 | `/tmp/defiformal-kernel-acceptance-3.log` |
| `lake build DefiKernel.Acceptance`, corrected fixture proof | 0 | `/tmp/defiformal-kernel-acceptance-4.log` |
| `lake build DefiKernel` | 0 | `/tmp/defiformal-kernel-build.log`; 926 jobs |
| `lake build` | 0 | `/tmp/defiformal-kernel-full-build.log`; 988 jobs |
| `lake env lean DefiKernel/Audit.lean` | 0 | `/tmp/defiformal-kernel-audit.log`; 25/25 executable checks and 43 axiom disclosures |
| `git diff --check` from repository root | 0 | No output |
| `python3 /tmp/defiformal-kernel-mutations.py` final version | 0 | `/tmp/defiformal-kernel-mutations.log`, generated directory below |

The initial failures were missing-feature checks and ordinary proof/import debugging, not certified
financial counterexamples. First fourteen concrete acceptance contracts were written before Core and
Examples. The transfer signature was clarified to include explicit actor, source and destination before
implementation. Observation/sequence contracts preceded observation helpers and liquidity fixture.

Ordinary `decide` got stuck on reduction through finite-type instances. `decide +kernel` then checked the
proof terms using kernel reduction. This is not `native_decide`. Axiom output independently confirms no
`Lean.ofReduceBool` or `sorryAx`. No custom axioms, unsafe declarations or opaque declarations occur in
these pilot files. There are four cosmetic Mathlib copyright-header warnings (Core, Examples, Acceptance,
Audit); no license was invented to satisfy that style rule. Legacy warnings remain in the full build.

## Finite executable and counterexample coverage

`Audit.runtimeChecks` executes 25 named comparisons and fails on an empty list or any false comparison.
It covers acceptance of transfer, deposit, withdrawal and borrowing; each of the six refusal categories;
wrong feed, stale observation, zero price, future observation and excessive debt; share insufficiency
and independently isolated vault liquidity insufficiency; four exact post-state snapshots; a
vault deposit/withdraw round trip observed at all sixteen cells; two successive accepted borrows followed
by a debt-sensitive refusal; an executed unauthorized refusal; and a net-zero self-transfer.

`Acceptance` has 29 checked theorems: the same twenty-five behaviors plus four negative witnesses.
The witnesses show wrong-asset scalar effects cancel while asset-wise accounting fails, unbalanced
accounting fails, and an undeclared footprint cell actually has nonzero effect. `allCells_complete`
proves the round-trip observation list contains every cell. These are finite examples, not an exhaustive
state exploration, protocol coverage statistic, or source-fidelity check.

## Six actual checker mutation probes

Recipe: `/tmp/defiformal-kernel-mutations.py`. Generated exact sources, complete logs, hashes, commands
and results: `/tmp/defiformal-kernel-mutations/` (including `results.json`).
The script lifts the actual Core prefix through `check`, the actual Examples prefix through the broken
fixtures, and the first fourteen actual Acceptance contracts using unique bounded source markers. It
asserts nonempty source and counts (one checker, fourteen contracts). It runs an unchanged control, then
six single-branch mutations replacing one check condition by False. These are source-lift mutations,
not in-place changes to the repository and not a full mutation of execute/proof linkage.

The control compiles with exit 0 and evaluates 14/14 comparisons true. Every mutant compiles with exit 1
and, crucially, evaluates at least one explicit false comparison from the same source contracts:

| Disabled checker branch | Runtime comparisons that become false |
|---|---|
| guard | stale oracle, zero price, future oracle, excess credit |
| debit authority | unauthorized transfer |
| supply authority | unauthorized issue |
| resulting nonnegativity | insufficient transfer |
| asset accounting | unbalanced effects, wrong-asset effects |
| write footprint | wrong footprint |

The first mutation harness draft assumed Lean's error text would say “evaluated to false”; it instead
reported failed reduction for a false `decide +kernel` proposition. That draft's assertion failed and was
not counted as mutation evidence. The final harness explicitly evaluates all fourteen comparisons;
proof compilation failure alone is insufficient for its mutant verdict. Broken Transition fixtures
in the ordinary suite and these six source mutations are different evidence categories.

## Trust boundaries and limitations

- Policy is supplied and unauthenticated. The fixture grants Alice vault/pool USD debits and share/debt
  issuance; the checker does not prove those grants are justified by an external protocol.
- Debit authority is for net effects. A self-transfer with no net debit needs no debit capability,
  even if its nominal amount exceeds holdings; an explicit example documents this behavior.
- Guards are supplied Lean functions. The kernel checks their Boolean result, not that a chosen guard
  captures a desired economic policy. Authorized supply changes are accounted but not economically
  justified by generic accounting alone. There is no separate global supply field in State.
- Oracle feed identifier, timestamp/current time, price meaning and collateral lock are declared inputs
  or interpretation assumptions. Freshness/positivity checks do not authenticate any source or establish
  market truth. Other transitions could change collateral; there is no global credit-solvency invariant
  or composition theorem. Debt tokens are a visible bounded obligation representation, not a complete
  claim lifecycle, repayment, interest, liquidation or enforceability model.
- Writes concern ledger cells only. No read footprints, causal assume-guarantee discharge, intermediate
  trace semantics, event observations, serialized IR or third-party certificate checker are provided.
- The algebraic vault and credit models are not ERC-20/ERC-4626/deployed-contract fidelity results.
  No generic solvency, liveness, complete composition, machine arithmetic refinement, runtime adapter
  correctness or deployment security is claimed.

## Source manifest

- `lean/DefiKernel.lean` — `3d183700381dc42b3ccea34037d56f4a4dffff5b086ad558d1d97a3b128c83fa`
- `lean/DefiKernel/Core.lean` — `767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d`
- `lean/DefiKernel/Examples.lean` — `7bae38ce1b62470a72dbed2ef0bd6eca8d25791b8a9b2fd40d38c86814e7d4c4`
- `lean/DefiKernel/Acceptance.lean` — `ebf07d92387c514b1d1b2d516fdb450152ffd814ebec57542b5d64875627b4b8`
- `lean/DefiKernel/Audit.lean` — `3dc378fffd1a9bb87c63ce0e44abaf44effcddda85832ff4d99e7e7d0d3e5c50`
- `lean/lakefile.toml` — `4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86`

## Exact theorem axiom output

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
'DefiKernel.transfer_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.deposit_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.withdraw_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.borrow_post' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.vault_round_trip' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.repeated_borrow_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.unauthorized_execute_refused' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.self_transfer_noop' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.wrong_asset_scalar_cancels' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.wrong_asset_not_accounted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.unbalanced_not_accounted' depends on axioms: [propext, Classical.choice, Quot.sound]
'DefiKernel.missing_footprint_changes_balance' depends on axioms: [propext, Classical.choice, Quot.sound]
```
