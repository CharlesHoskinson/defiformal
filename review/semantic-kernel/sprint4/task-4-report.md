# Sprint 4 Task 4: registered reference libraries

Status: completed in assigned files only; no commits. Parent owns integration, imported-scope audit, source mutations and native reviewer evidence.

## Results and verification

- `lake build DefiKernel.Typed.Examples`: exit 0, 922 jobs at initial API freeze.
- Final `lake build DefiKernel.Typed.Acceptance`: exit 0, 923 jobs; all 70 named runtime comparisons true. Imported Transition linter warnings were replayed; neither assigned file has a warning.
- Final `lake env lean DefiKernel/Typed/Acceptance.lean`: fresh file verification, exit 0, 70/70 true comparisons, including complete observed post-states and explicit refusal reasons.
- Lean LSP standalone import of Acceptance plus #print axioms for all 11 named theorems: success true. allCells_nodup has no axioms, allCells_complete uses propext, and nine Acceptance theorems use only propext/Classical.choice/Quot.sound.
- Lean 4.33.0-rc2, x86_64-unknown-linux-gnu, compiler commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release.
- LSP file diagnostics initially reported stale imports; Lake dependency builds and fresh file checks supplied the validation. Named axiom disclosures are supplemental; parent automatic audit remains required.

## Reference semantics

Original four parties and four assets are fixture types for the parametric kernel. Domain has main/other. Initial main balances are Alice USD10/share4/collateral10/debt2, vault USD20, pool USD100; all remaining main and other balances are zero. allCells has all 32 distinct cells, with completeness and no-duplicates proofs.

| Registered template | Input and exact effect | Full main-domain post; all unspecified cells unchanged |
| --- | --- | --- |
| transfer ID0 | Three USD from caller Alice to party argument Bob | Alice USD7; Bob USD3 |
| deposit ID1 | Four USD, explicit price 2 USD/share | Alice USD6/share6; vault USD24 |
| withdraw ID2 | Two shares, explicit price 2 USD/share | Alice USD14/share2; vault USD16 |
| borrow ID3 | Three USD, explicit price 1 USD/debt | Alice USD13/debt5; pool USD97 |

Every requested quantity is guarded nonnegative. Borrow uses only feed-key7, positive price, observedAt <= now <= observedAt+5 and twice the USD value of post-debt <= declared collateral USD value. The 1 USD/debt denomination and 2 USD/share price are dimensioned expressions, not scalar casts. Timestamp/current-time and collateral/debt reads are explicitly declared.

## Authority and registry boundary

Vault is the fixture administrative principal. All 12 grants are actually issued through issueCapability and registryAuthorityConfig: operation-specific invoke rights plus exact USD/share debit and share/debt supply rights. Provisioning failure is propagated as ReferenceFailure.authority. Ordinary run delegates to execute and maps its refusals to ReferenceFailure.execution.

The issue/use/revoke/use sequence takes the first successful execution result, revokes its invocation capability in result.capabilities, then submits the identical request against result.state. A live repeated request separately succeeds (Alice USD4/Bob USD6), proving funds do not mask revocation. Fresh issuance after revocation returns ID12; the old ID remains tombstoned.

The trusted development-template helper derives its authority configuration and issues all grants from the same developmentRegistry used for execution. It is a test fixture for checking modified templates, not a feature allowing request payloads to carry operations.

## Exported API

Namespace DefiKernel.Typed.Examples:

- Fixture types Party/Asset/Domain and aliases Ledger, Store, Op, Call, Result, E signature.
- initial : Ledger; ref asset owner / packedRef asset owner; allGuards; nonnegative; negate.
- transfer/deposit/withdraw/borrow : Op; usdSignature/shareSignature and typed quantity/rate/value/guard expressions.
- transferId/depositId/withdrawId/borrowId; registry : Registry Party Asset Domain.
- domainAdmin; authorityConfig; adminContext/aliceContext/bobContext; grant operation right; grants.
- issueGrants store grants : Except AuthorityFailure Store; provisioned : Except AuthorityFailure Store; allCapabilityIds.
- transferRequest q recipient (default Bob), depositRequest q, withdrawRequest q, borrowRequest q : Call.
- oracle feed price observedAt : Environment Asset Domain; fresh; priceKey.
- ReferenceFailure.authority AuthorityFailure / .execution Refusal.
- runWith store context environment now request state (state defaults initial); run request; runOracle env now request; runContext ctx request; runRevoked id request.
- allCells : List (Cell Party Asset Domain); observe : Except ReferenceFailure Result -> Except ReferenceFailure (List Rat).

Namespace DefiKernel.Typed.Acceptance:

- checks : List (String × Bool), 70 unique reference_ snake_case labels.
- Explicit full expected balance lists; refused result reason and postMatches result balances helpers.
- preservesCapabilities, provisionedIds, revokedTransferInvoke, issueAfterRevocation, runReissued, repeatedTransfer, transferLifecycle.
- unauthorizedGrant/unauthorizedRevoke; runDevelopmentTemplate; missing footprint, accounting, wrong-asset and zero-divisor fixture templates.
- illiquid/illiquidBorrow; zeroExposure/zeroExposureBorrow for independently testing price positivity.

Both files close inner namespaces before their single -- BEGIN PROOFS marker; all computational definitions are above it. Acceptance standalone #eval driver and proofs are below it. Central Audit can import executable-only projections without duplicate driver output.

## Independent refusal coverage and limits

Wrong-holder requests have claimedActor=none, avoiding actor-mismatch masking. Invalid requests test wrong actor/domain/operation/capabilities, missing debit/supply, duplicate IDs, revocation, unauthorized administration, dimensions/arity, liquidity and every financial guard. All successful expectations include untouched cells.

Oracle positivity is independently tested with Alice debt0/collateral0 and borrow0: price2 accepts the full unchanged state, price0 and price-1 refuse solely on positivity. Separate age5 success/age6 refusal, future timestamp, and collateral boundary8 success/9 refusal constrain the other guard conjuncts.

These are exact finite reference semantics and conditional executor properties, not deployed fidelity, authentication cryptography, market truth, general solvency, operational composition, machine arithmetic or rounding. Locked collateral is declared model state. Wrong-feed refusal is missingObservation because a value under feed8 cannot replace required key7. Net-effect authority retains the parent kernel limitations.

The 70 runtime comparisons are measured behavior. Eleven named Lean theorems are proof evidence. Source-mutation sensitivity and independent native review are parent work; this report does not claim them complete.

## Source identities

- `Examples.lean` SHA-256 `640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41`
- `Acceptance.lean` SHA-256 `4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1`

## Exact named theorem statements

```lean
theorem allCells_complete (cell : Cell Party Asset Domain) : cell ∈ allCells
theorem allCells_nodup : allCells.Nodup
theorem transfer_executed : observe (run (transferRequest 3)) = .ok expectedTransfer
theorem deposit_executed : observe (run (depositRequest 4)) = .ok expectedDeposit
theorem withdraw_executed : observe (run (withdrawRequest 2)) = .ok expectedWithdraw
theorem borrow_executed : observe (run (borrowRequest 3)) = .ok expectedBorrow
theorem revoked_request_refused :
    observe (runRevoked ⟨0⟩ (transferRequest 3)) = .error (.execution .unauthorizedInvoke)
theorem stale_oracle_refused :
    observe (runOracle (oracle 7 2 94) 100 (borrowRequest 3)) = .error (.execution .guard)
theorem issued_used_revoked_refused :
    transferLifecycle = .ok (expectedTransfer, .error .unauthorizedInvoke)
theorem reference_invocation_authority (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger) (post : Result)
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .invoke
theorem reference_capabilities_preserved (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger) (post : Result)
    (h : execute registry store ctx env now request state = .ok post) : post.capabilities = store
```

## Frozen check labels

- reference_initial_all_cells
- reference_provisioned_twelve_grants
- reference_transfer_full_post
- reference_deposit_full_post
- reference_withdraw_full_post
- reference_borrow_full_post
- reference_collateral_boundary_accept
- reference_fractional_deposit
- reference_zero_transfer
- reference_self_transfer
- reference_zero_deposit
- reference_zero_withdraw
- reference_zero_borrow
- reference_negative_transfer
- reference_negative_deposit
- reference_negative_withdraw
- reference_negative_borrow
- reference_transfer_capabilities_preserved
- reference_deposit_capabilities_preserved
- reference_withdraw_capabilities_preserved
- reference_borrow_capabilities_preserved
- reference_unknown_operation
- reference_wrong_holder
- reference_claimed_actor_mismatch
- reference_claimed_actor_correct
- reference_wrong_domain
- reference_wrong_operation_capabilities
- reference_unknown_capability
- reference_missing_debit
- reference_missing_share_supply
- reference_missing_debt_supply
- reference_duplicate_capabilities
- reference_revoked_invocation
- reference_live_repeat_same_request
- reference_issue_use_revoke_same_request
- reference_resource_revoked_same_request
- reference_unrelated_revocation
- reference_revocation_tombstone
- reference_reissue_fresh_id
- reference_reissued_new_id_works
- reference_old_id_stays_revoked
- reference_unauthorized_issue
- reference_unauthorized_revoke
- reference_oracle_age_boundary_accept
- reference_oracle_stale
- reference_oracle_zero
- reference_oracle_negative
- reference_oracle_positive_zero_exposure
- reference_oracle_zero_independent
- reference_oracle_negative_independent
- reference_oracle_future
- reference_oracle_wrong_feed
- reference_oracle_missing
- reference_oracle_wrong_dimension
- reference_collateral_exceeded
- reference_transfer_insufficient
- reference_deposit_insufficient
- reference_withdraw_insufficient
- reference_pool_illiquid
- reference_wrong_argument_dimension
- reference_missing_argument
- reference_missing_party
- reference_missing_write
- reference_missing_guard_state_read
- reference_missing_guard_env_read
- reference_declared_effect_read
- reference_missing_effect_read
- reference_unbalanced
- reference_wrong_asset_accounting
- reference_zero_divisor
