import DefiKernel.Typed.Transition

namespace DefiKernel.Typed
namespace TransitionTests

abbrev T := Template Bool Bool Bool
abbrev R := Request Bool Bool Bool
abbrev S := State Bool Bool Bool
abbrev C := CapabilityStore Bool Bool Bool
abbrev Result := Except Refusal (ExecutionResult Bool Bool Bool)

def alice : CellRef Bool Bool Bool false := ⟨false, .caller⟩
def bob : CellRef Bool Bool Bool false := ⟨false, .literal true⟩
def state : S := ⟨fun _ ↦ 10, by intro c; decide⟩
def context : InvocationContext Bool Bool := ⟨false, false⟩
def environment : Environment Bool Bool := fun _ ↦ some ⟨⟨.amount false, 3⟩, 10⟩
def key : ObservationKey Bool := ⟨false, ⟨0⟩⟩

def transfer : T :=
  { signature := [], domain := false, partyArity := 0, guard := .lit true
    deltas := [⟨false, alice, .lit (-3)⟩, ⟨false, bob, .lit 3⟩]
    supplyDeltas := [], stateReads := [], envReads := []
    writes := [⟨false, alice⟩, ⟨false, bob⟩] }

def registry (template : T) : Registry Bool Bool Bool :=
  fun op ↦ if op = ⟨0⟩ then some template else none

/-- Every test capability is issued under configuration derived from the execution registry. -/
def capabilities (template : T) : C :=
  ([Right.invoke, .debit (false, false, false),
      .changeSupply false false, .changeSupply false true] : List (Right Bool Bool Bool)).foldl
    (fun store right ↦
      match issueCapability (registryAuthorityConfig (registry template) (fun _ ↦ false))
          context store ⟨false, false, ⟨0⟩, right⟩ with
      | .ok (_, updated) => updated
      | .error _ => store) .empty

def request : R := ⟨⟨0⟩, [], [], [⟨0⟩, ⟨1⟩, ⟨2⟩, ⟨3⟩], none⟩

def runWith (template : T) (req : R) (caps : C) (ctx : InvocationContext Bool Bool) : Result :=
  execute (registry template) caps ctx environment 10 req state

def run (template : T) : Result := runWith template request (capabilities template) context

def accepted : Result → Bool
  | .ok _ => true
  | .error _ => false

def refused (reason : Refusal) : Result → Bool
  | .error actual => actual == reason
  | .ok _ => false

def transferExact : Result → Bool
  | .error _ => false
  | .ok post => post.state.balance (false, false, false) == 7 &&
      post.state.balance (false, true, false) == 13 &&
      post.state.balance (true, false, false) == 10 &&
      post.capabilities == capabilities transfer

def guardRead : T :=
  { transfer with guard := .binary (.le (.amount false)) (.balance alice) (.lit 100)
                  stateReads := [⟨false, alice⟩] }

def effectRead : T :=
  { transfer with
    deltas := [⟨false, alice, .unary (.neg (.amount false)) (.balance alice)⟩,
      ⟨false, bob, .balance alice⟩]
    stateReads := [⟨false, alice⟩] }

def observed : T :=
  { transfer with
    deltas := [⟨false, alice, .unary (.neg (.amount false)) (.observe ⟨key⟩)⟩,
      ⟨false, bob, .observe ⟨key⟩⟩]
    envReads := [.observation key] }

def mint : T :=
  { transfer with deltas := [⟨false, bob, .lit 3⟩]
                  supplyDeltas := [⟨false, false, .lit 3⟩] }

def supplyRead : T :=
  { mint with deltas := [⟨false, bob, .balance alice⟩]
              supplyDeltas := [⟨false, false, .balance alice⟩]
              stateReads := [⟨false, alice⟩] }

def supplyOnlyRead : T :=
  { mint with supplyDeltas := [⟨false, false,
      .ite (.lit true) (.lit 3) (.balance alice)⟩]
              stateReads := [⟨false, alice⟩] }

def inactiveRead : T :=
  { transfer with
    guard := .ite (.lit true) (.lit true)
      (.binary (.le (.amount false)) (.balance alice) (.lit 100))
    stateReads := [⟨false, alice⟩] }

def foreignRead : T :=
  { transfer with
    guard := .binary (.le (.amount false)) (.balance ⟨true, .caller⟩) (.lit 100)
    stateReads := [⟨false, ⟨true, .caller⟩⟩] }

def repeated : T :=
  { transfer with deltas := [⟨false, alice, .lit (-1)⟩, ⟨false, alice, .lit (-2)⟩,
      ⟨false, bob, .lit 1⟩, ⟨false, bob, .lit 2⟩] }

def repeatedSupply : T :=
  { mint with supplyDeltas := [⟨false, false, .lit 1⟩, ⟨false, false, .lit 2⟩] }

def revoked : C :=
  match revokeCapability (registryAuthorityConfig (registry transfer) (fun _ ↦ false))
      context (capabilities transfer) ⟨1⟩ with
  | .ok store => store
  | .error _ => .empty

/-- Positive siblings use the same executor and expose the expected refusal precedence. -/
def checks : List (String × Bool) :=
  [ ("transition_transfer_exact", transferExact (run transfer))
  , ("transition_issue_all_rights", decide ((capabilities transfer).entries.length = 4))
  , ("transition_unknown_operation", refused .unknownOperation
      (runWith transfer { request with operation := ⟨99⟩ } (capabilities transfer) context))
  , ("transition_claimed_actor_ok", transferExact
      (runWith transfer { request with claimedActor := some false } (capabilities transfer) context))
  , ("transition_claimed_actor_wrong", refused .actorMismatch
      (runWith transfer { request with claimedActor := some true } (capabilities transfer) context))
  , ("transition_wrong_cap_holder", refused .unauthorizedInvoke
      (runWith transfer request (capabilities transfer) ⟨true, false⟩))
  , ("transition_context_domain", refused .domainMismatch
      (runWith transfer request (capabilities transfer) ⟨false, true⟩))
  , ("transition_party_arity", refused .partyArity
      (runWith transfer { request with parties := [true] } (capabilities transfer) context))
  , ("transition_argument_count", refused (.evaluation .argumentCount)
      (runWith transfer { request with arguments := [⟨.scalar, 3⟩] } (capabilities transfer) context))
  , ("transition_invoke_required", refused .unauthorizedInvoke
      (runWith transfer { request with capabilityIds := [⟨1⟩, ⟨2⟩, ⟨3⟩] }
        (capabilities transfer) context))
  , ("transition_guard_false", refused .guard (run { transfer with guard := .lit false }))
  , ("transition_guard_read_ok", accepted (run guardRead))
  , ("transition_guard_read_missing", refused .stateReadFootprint
      (run { guardRead with stateReads := [] }))
  , ("transition_effect_read_ok", accepted (run effectRead))
  , ("transition_effect_read_missing", refused .stateReadFootprint
      (run { effectRead with stateReads := [] }))
  , ("transition_inactive_read_ok", accepted (run inactiveRead))
  , ("transition_inactive_read_missing", refused .stateReadFootprint
      (run { inactiveRead with stateReads := [] }))
  , ("transition_supply_read_ok", accepted (run supplyRead))
  , ("transition_supply_only_read_ok", accepted (run supplyOnlyRead))
  , ("transition_supply_only_read_missing", refused .stateReadFootprint
      (run { supplyOnlyRead with stateReads := [] }))
  , ("transition_observed_ok", transferExact (run observed))
  , ("transition_env_read_missing", refused .envReadFootprint
      (run { observed with envReads := [] }))
  , ("transition_observation_missing", refused (.evaluation .missingObservation)
      (execute (registry observed) (capabilities observed) context (fun _ ↦ none) 10 request state))
  , ("transition_foreign_state_read", refused .crossDomain (run foreignRead))
  , ("transition_foreign_effect", refused .crossDomain
      (run { transfer with deltas := [⟨false, alice, .lit (-3)⟩,
        ⟨false, ⟨true, .literal true⟩, .lit 3⟩] }))
  , ("transition_debit_required", refused .unauthorizedDebit
      (runWith transfer { request with capabilityIds := [⟨0⟩, ⟨2⟩, ⟨3⟩] }
        (capabilities transfer) context))
  , ("transition_revoked_debit", refused .unauthorizedDebit
      (runWith transfer request revoked context))
  , ("transition_mint_ok", accepted (run mint))
  , ("transition_supply_required", refused .unauthorizedSupply
      (runWith mint { request with capabilityIds := [⟨0⟩, ⟨1⟩] } (capabilities mint) context))
  , ("transition_insufficient_funds", refused .insufficientFunds
      (run { transfer with deltas := [⟨false, alice, .lit (-11)⟩, ⟨false, bob, .lit 11⟩] }))
  , ("transition_unbalanced", refused .accounting
      (run { transfer with deltas := [⟨false, alice, .lit (-3)⟩, ⟨false, bob, .lit 4⟩] }))
  , ("transition_mismatched_supply", refused .accounting
      (run { mint with supplyDeltas := [⟨false, false, .lit 2⟩] }))
  , ("transition_wrong_asset_accounting", refused .accounting
      (run { mint with supplyDeltas := [⟨false, true, .lit 3⟩] }))
  , ("transition_missing_write", refused .writeFootprint
      (run { transfer with writes := [⟨false, alice⟩] }))
  , ("transition_repeated_effects_sum", transferExact (run repeated))
  , ("transition_repeated_supply_sum", accepted (run repeatedSupply))
  , ("transition_duplicate_cap_ids", transferExact
      (runWith transfer { request with capabilityIds := ⟨1⟩ :: request.capabilityIds }
        (capabilities transfer) context))
  ]

end TransitionTests

-- BEGIN PROOFS

#eval show IO _root_.Unit from do
  let comparisons := TransitionTests.checks
  if comparisons.isEmpty then throw (IO.userError "Typed runtime comparisons empty")
  for (label, ok) in comparisons do IO.println s!"{label}: {ok}"
  let failures := comparisons.filter (fun entry ↦ !entry.2)
  if !failures.isEmpty then
    throw (IO.userError s!"Typed runtime comparisons failed: {failures.length}")

end DefiKernel.Typed
