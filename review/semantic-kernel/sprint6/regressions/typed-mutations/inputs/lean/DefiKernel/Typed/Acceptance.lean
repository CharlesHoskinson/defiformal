import DefiKernel.Typed.Examples

/-! Executed reference outcomes, refused requests and kernel-checked concrete examples.
Development-template changes below are trusted test fixtures, not request payload features. -/
namespace DefiKernel.Typed
namespace Acceptance
open Examples

def expectedInitial : List ℚ :=
  [10, 4, 10, 2, 0, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedTransfer : List ℚ :=
  [7, 4, 10, 2, 3, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedRepeatedTransfer : List ℚ :=
  [4, 4, 10, 2, 6, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedDeposit : List ℚ :=
  [6, 6, 10, 2, 0, 0, 0, 0, 24, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedWithdraw : List ℚ :=
  [14, 2, 10, 2, 0, 0, 0, 0, 16, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedBorrow : List ℚ :=
  [13, 4, 10, 5, 0, 0, 0, 0, 20, 0, 0, 0, 97, 0, 0, 0] ++ List.replicate 16 0
def expectedBoundaryBorrow : List ℚ :=
  [18, 4, 10, 10, 0, 0, 0, 0, 20, 0, 0, 0, 92, 0, 0, 0] ++ List.replicate 16 0
def expectedFractionalDeposit : List ℚ :=
  [9, 9 / 2, 10, 2, 0, 0, 0, 0, 21, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedZeroExposure : List ℚ :=
  [10, 4, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0

def refused (result : Except ReferenceFailure Result) (reason : Refusal) : Bool :=
  match result with
  | .error actual => decide (actual = .execution reason)
  | .ok _ => false

def postMatches (result : Except ReferenceFailure Result) (balances : List ℚ) : Bool :=
  decide (observe result = .ok balances)

def preservesCapabilities (request : Call) : Bool :=
  match provisioned, run request with
  | .ok before, .ok after => decide (after.capabilities = before)
  | _, _ => false

def provisionedIds : Except AuthorityFailure (List CapabilityId) :=
  provisioned.map fun store ↦ (List.range store.entries.length).map CapabilityId.mk

def revokedTransferInvoke : Except AuthorityFailure Store := do
  let store ← provisioned
  revokeCapability authorityConfig adminContext store ⟨0⟩

def issueAfterRevocation : Except AuthorityFailure (CapabilityId × Store) := do
  let revoked ← revokedTransferInvoke
  issueCapability authorityConfig adminContext revoked (grant transferId .invoke)

def runReissued (request : Call) : Except ReferenceFailure Result := do
  let (id, store) ← issueAfterRevocation.mapError .authority
  runWith store aliceContext fresh 100 { request with capabilityIds := id :: request.capabilityIds }

/-- Both calls use exactly the same request; the second uses the first call's state and store. -/
def repeatedTransfer : Except ReferenceFailure Result := do
  let first ← run (transferRequest 3)
  runWith first.capabilities aliceContext fresh 100 (transferRequest 3) first.state

/-- Actual issue/use/revoke/use: preserve the successful state and revoke in its capability store
before submitting the unchanged request again. A live repeat is separately checked above. -/
def transferLifecycle : Except ReferenceFailure (List ℚ × Except Refusal (List ℚ)) := do
  let first ← run (transferRequest 3)
  let revoked ← (revokeCapability authorityConfig adminContext first.capabilities ⟨0⟩)
    |>.mapError .authority
  let second := execute registry revoked aliceContext fresh 100 (transferRequest 3) first.state
  return (allCells.map first.state.balance, second.map fun post ↦ allCells.map post.state.balance)

def unauthorizedGrant : Except AuthorityFailure (CapabilityId × Store) :=
  issueCapability authorityConfig bobContext .empty (grant transferId .invoke)

def unauthorizedRevoke : Except AuthorityFailure Store := do
  let store ← provisioned
  revokeCapability authorityConfig bobContext store ⟨0⟩

/-- A trusted development registry variant; caller requests still contain no template. -/
def runDevelopmentTemplate (template : Op) (request : Call) : Except ReferenceFailure Result := do
  let developmentRegistry : Registry Party Asset Domain := fun id ↦
    if id = request.operation then some template else registry id
  let config := registryAuthorityConfig developmentRegistry domainAdmin
  let issued : Except AuthorityFailure Store := grants.foldlM
    (fun store g ↦ (issueCapability config adminContext store g).map Prod.snd) .empty
  let store ← issued.mapError .authority
  (execute developmentRegistry store aliceContext fresh 100 request initial).mapError .execution

def missingWrites : Op := { transfer with writes := [] }
def missingOracleReads : Op := { borrow with envReads := [] }
def missingBorrowStateReads : Op := { borrow with stateReads := [] }

def quantityWithRead : E usdSignature (.amount .usd) :=
  .binary (.add (.amount Asset.usd)) usdQuantity
    (.binary (.scale (.amount Asset.usd)) (.lit 0) (.balance (ref .usd .caller)))

def effectReadTransfer : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, negate .usd quantityWithRead⟩,
    ⟨.usd, ref .usd (.argument 0), quantityWithRead⟩]
  stateReads := [packedRef .usd .caller] }

def missingEffectRead : Op := { effectReadTransfer with stateReads := [] }

def unbalancedTransfer : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.argument 0), .binary (.add (.amount Asset.usd)) usdQuantity (.lit 1)⟩] }

def wrongAssetTransfer : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.share, ref .share (.argument 0), .lit 3⟩]
  writes := [packedRef .usd .caller, packedRef .share (.argument 0)] }

def zeroPriceDeposit : Op := { deposit with
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.literal .vault), usdQuantity⟩,
    ⟨.share, ref .share .caller,
      .binary (.unconvert Asset.share Asset.usd) usdQuantity (.lit 0)⟩] }

def illiquid : Ledger :=
  ⟨fun c ↦ if c = (.main, .pool, .usd) then 1 else initial.balance c, by
    intro c; split
    · decide
    · exact initial.nonneg c⟩

def illiquidBorrow : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext fresh 100 (borrowRequest 3) illiquid

/-- Both sides of the collateral inequality are zero, independently of the supplied price.
This isolates strict price positivity instead of letting the collateral guard mask it. -/
def zeroExposure : Ledger :=
  ⟨fun c ↦ if c = (.main, .alice, .debt) ∨ c = (.main, .alice, .collateral)
    then 0 else initial.balance c, by
      intro c; split
      · decide
      · exact initial.nonneg c⟩

def zeroExposureBorrow (price : ℚ) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext (oracle 7 price 98) 100 (borrowRequest 0) zeroExposure

def checks : List (String × Bool) := [
  ("reference_initial_all_cells", decide (allCells.map initial.balance = expectedInitial)),
  ("reference_provisioned_twelve_grants", decide
    (provisionedIds = .ok ((List.range 12).map CapabilityId.mk))),
  ("reference_transfer_full_post", postMatches (run (transferRequest 3)) expectedTransfer),
  ("reference_deposit_full_post", postMatches (run (depositRequest 4)) expectedDeposit),
  ("reference_withdraw_full_post", postMatches (run (withdrawRequest 2)) expectedWithdraw),
  ("reference_borrow_full_post", postMatches (run (borrowRequest 3)) expectedBorrow),
  ("reference_collateral_boundary_accept", postMatches
    (run (borrowRequest 8)) expectedBoundaryBorrow),
  ("reference_fractional_deposit", postMatches (run (depositRequest 1)) expectedFractionalDeposit),
  ("reference_zero_transfer", postMatches (run (transferRequest 0)) expectedInitial),
  ("reference_self_transfer", postMatches (run (transferRequest 3 .alice)) expectedInitial),
  ("reference_zero_deposit", postMatches (run (depositRequest 0)) expectedInitial),
  ("reference_zero_withdraw", postMatches (run (withdrawRequest 0)) expectedInitial),
  ("reference_zero_borrow", postMatches (run (borrowRequest 0)) expectedInitial),
  ("reference_negative_transfer", refused (run (transferRequest (-1))) .guard),
  ("reference_negative_deposit", refused (run (depositRequest (-1))) .guard),
  ("reference_negative_withdraw", refused (run (withdrawRequest (-1))) .guard),
  ("reference_negative_borrow", refused (run (borrowRequest (-1))) .guard),
  ("reference_transfer_capabilities_preserved", preservesCapabilities (transferRequest 3)),
  ("reference_deposit_capabilities_preserved", preservesCapabilities (depositRequest 4)),
  ("reference_withdraw_capabilities_preserved", preservesCapabilities (withdrawRequest 2)),
  ("reference_borrow_capabilities_preserved", preservesCapabilities (borrowRequest 3)),
  ("reference_unknown_operation", refused
    (run { transferRequest 3 with operation := ⟨99⟩ }) .unknownOperation),
  ("reference_wrong_holder", refused
    (runContext bobContext (transferRequest 3)) .unauthorizedInvoke),
  ("reference_claimed_actor_mismatch", refused
    (run { transferRequest 3 with claimedActor := some .bob }) .actorMismatch),
  ("reference_claimed_actor_correct", postMatches
    (run { transferRequest 3 with claimedActor := some .alice }) expectedTransfer),
  ("reference_wrong_domain", refused
    (runContext ⟨.alice, .other⟩ (transferRequest 3)) .domainMismatch),
  ("reference_wrong_operation_capabilities", refused
    (run { depositRequest 4 with capabilityIds := [⟨0⟩, ⟨1⟩] }) .unauthorizedInvoke),
  ("reference_unknown_capability", refused
    (run { transferRequest 3 with capabilityIds := [⟨99⟩] }) .unauthorizedInvoke),
  ("reference_missing_debit", refused
    (run { transferRequest 3 with capabilityIds := [⟨0⟩] }) .unauthorizedDebit),
  ("reference_missing_share_supply", refused
    (run { depositRequest 4 with capabilityIds := [⟨2⟩, ⟨3⟩] }) .unauthorizedSupply),
  ("reference_missing_debt_supply", refused
    (run { borrowRequest 3 with capabilityIds := [⟨9⟩, ⟨10⟩] }) .unauthorizedSupply),
  ("reference_duplicate_capabilities", postMatches
    (run { transferRequest 3 with capabilityIds := [⟨0⟩, ⟨0⟩, ⟨1⟩, ⟨1⟩] }) expectedTransfer),
  ("reference_revoked_invocation", refused
    (runRevoked ⟨0⟩ (transferRequest 3)) .unauthorizedInvoke),
  ("reference_live_repeat_same_request", postMatches repeatedTransfer expectedRepeatedTransfer),
  ("reference_issue_use_revoke_same_request", decide
    (transferLifecycle = .ok (expectedTransfer, .error .unauthorizedInvoke))),
  ("reference_resource_revoked_same_request", refused
    (runRevoked ⟨1⟩ (transferRequest 3)) .unauthorizedDebit),
  ("reference_unrelated_revocation", postMatches
    (runRevoked ⟨9⟩ (transferRequest 3)) expectedTransfer),
  ("reference_revocation_tombstone", decide
    ((revokedTransferInvoke.map fun s ↦ (s.lookup ⟨0⟩).map Capability.live) = .ok (some false))),
  ("reference_reissue_fresh_id", decide ((issueAfterRevocation.map Prod.fst) = .ok ⟨12⟩)),
  ("reference_reissued_new_id_works", postMatches
    (runReissued (transferRequest 3)) expectedTransfer),
  ("reference_old_id_stays_revoked", decide
    ((issueAfterRevocation.map fun p ↦
      authorizesId p.2 aliceContext transferId .invoke ⟨0⟩) = .ok false)),
  ("reference_unauthorized_issue", decide (unauthorizedGrant = .error .unauthorizedAdmin)),
  ("reference_unauthorized_revoke", decide (unauthorizedRevoke = .error .unauthorizedAdmin)),
  ("reference_oracle_age_boundary_accept", postMatches
    (runOracle (oracle 7 2 95) 100 (borrowRequest 3)) expectedBorrow),
  ("reference_oracle_stale", refused (runOracle (oracle 7 2 94) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_zero", refused (runOracle (oracle 7 0 98) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_negative", refused
    (runOracle (oracle 7 (-1) 98) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_positive_zero_exposure", postMatches
    (zeroExposureBorrow 2) expectedZeroExposure),
  ("reference_oracle_zero_independent", refused (zeroExposureBorrow 0) .guard),
  ("reference_oracle_negative_independent", refused (zeroExposureBorrow (-1)) .guard),
  ("reference_oracle_future", refused (runOracle (oracle 7 2 101) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_wrong_feed", refused
    (runOracle (oracle 8 2 98) 100 (borrowRequest 3)) (.evaluation .missingObservation)),
  ("reference_oracle_missing", refused
    (runOracle (fun _ ↦ none) 100 (borrowRequest 3)) (.evaluation .missingObservation)),
  ("reference_oracle_wrong_dimension", refused
    (runOracle (fun _ ↦ some ⟨⟨.price .usd .collateral, 2⟩, 98⟩) 100 (borrowRequest 3))
    (.evaluation .observationUnit)),
  ("reference_collateral_exceeded", refused (run (borrowRequest 9)) .guard),
  ("reference_transfer_insufficient", refused (run (transferRequest 11)) .insufficientFunds),
  ("reference_deposit_insufficient", refused (run (depositRequest 11)) .insufficientFunds),
  ("reference_withdraw_insufficient", refused (run (withdrawRequest 5)) .insufficientFunds),
  ("reference_pool_illiquid", refused illiquidBorrow .insufficientFunds),
  ("reference_wrong_argument_dimension", refused
    (run { depositRequest 4 with arguments := [⟨.amount .share, 4⟩] }) (.evaluation .argumentUnit)),
  ("reference_missing_argument", refused
    (run { transferRequest 3 with arguments := [] }) (.evaluation .argumentCount)),
  ("reference_missing_party", refused (run { transferRequest 3 with parties := [] }) .partyArity),
  ("reference_missing_write", refused
    (runDevelopmentTemplate missingWrites (transferRequest 3)) .writeFootprint),
  ("reference_missing_guard_state_read", refused
    (runDevelopmentTemplate missingBorrowStateReads (borrowRequest 3)) .stateReadFootprint),
  ("reference_missing_guard_env_read", refused
    (runDevelopmentTemplate missingOracleReads (borrowRequest 3)) .envReadFootprint),
  ("reference_declared_effect_read", postMatches
    (runDevelopmentTemplate effectReadTransfer (transferRequest 3)) expectedTransfer),
  ("reference_missing_effect_read", refused
    (runDevelopmentTemplate missingEffectRead (transferRequest 3)) .stateReadFootprint),
  ("reference_unbalanced", refused
    (runDevelopmentTemplate unbalancedTransfer (transferRequest 3)) .accounting),
  ("reference_wrong_asset_accounting", refused
    (runDevelopmentTemplate wrongAssetTransfer (transferRequest 3)) .accounting),
  ("reference_zero_divisor", refused
    (runDevelopmentTemplate zeroPriceDeposit (depositRequest 4)) (.evaluation .divisionByZero))
]

end Acceptance

-- BEGIN PROOFS

namespace Acceptance
open Examples

#eval do
  let mut failed := 0
  for (label, passed) in checks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Typed runtime comparisons failed: {failed}")

set_option maxRecDepth 10000 in
theorem transfer_executed : observe (run (transferRequest 3)) = .ok expectedTransfer := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem deposit_executed : observe (run (depositRequest 4)) = .ok expectedDeposit := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem withdraw_executed : observe (run (withdrawRequest 2)) = .ok expectedWithdraw := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem borrow_executed : observe (run (borrowRequest 3)) = .ok expectedBorrow := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem revoked_request_refused :
    observe (runRevoked ⟨0⟩ (transferRequest 3)) = .error (.execution .unauthorizedInvoke) := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem stale_oracle_refused :
    observe (runOracle (oracle 7 2 94) 100 (borrowRequest 3)) = .error (.execution .guard) := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem issued_used_revoked_refused :
    transferLifecycle = .ok (expectedTransfer, .error .unauthorizedInvoke) := by
  decide +kernel

/-- The reference registry inherits the actual executor's authority result, conditional on
the supplied authenticated context and successful execution. -/
theorem reference_invocation_authority (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger) (post : Result)
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .invoke :=
  execute_invocation_authority registry store ctx env now request state post h

theorem reference_capabilities_preserved (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger) (post : Result)
    (h : execute registry store ctx env now request state = .ok post) : post.capabilities = store :=
  execute_preserves_capabilities registry store ctx env now request state post h

end Acceptance
end DefiKernel.Typed
