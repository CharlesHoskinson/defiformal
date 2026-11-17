import WorkflowModel

namespace RationalWorkflow

structure SequenceResult where
  state : PublicState
  failure : Option (Reason × Nat)
  committed : Nat

def SequenceResult.bump (result : SequenceResult) : SequenceResult :=
  ⟨result.state, result.failure.map (fun (reason, index) => (reason, index + 1)),
    result.committed + 1⟩

def runWith {Instruction : Type} (step : PublicState → Instruction → Result)
    (state : PublicState) : List Instruction → SequenceResult
  | [] => ⟨state, none, 0⟩
  | call :: calls => match step state call with
    | .refused reason _ => ⟨state, some (reason, 0), 0⟩
    | .success post => (runWith step post calls).bump

def runCalls := runWith execute
def runRaw := runWith rawExecute

def atomicRaw (state : PublicState) (calls : List RawCall) : SequenceResult :=
  let staged := runRaw state calls
  match staged.failure with
  | none => staged
  | some located => ⟨state, some located, 0⟩

-- Raw decoding is a specification operation, separate from execution and its ledger effects.
def decodeRaw : RawCall → Except Reason Call
  | .unsupported _ => .error .badOperation
  | .transfer p s t e q =>
    match decodePrincipal p, decodeAccount s, decodeAccount t, decodeAsset e with
    | some p, some s, some t, some e => match q with
      | .exact q => .ok (.transfer p s t e q)
      | .malformed _ => .error .badNumber
    | _, _, _, _ => .error .badTarget
  | .deposit p u v q =>
    match decodePrincipal p, decodeUser u, decodeVault v with
    | some p, some u, some v => match q with
      | .exact q => .ok (.deposit p u v q)
      | .malformed _ => .error .badNumber
    | _, _, _ => .error .badTarget
  | .withdraw p u v q =>
    match decodePrincipal p, decodeUser u, decodeVault v with
    | some p, some u, some v => match q with
      | .exact q => .ok (.withdraw p u v q)
      | .malformed _ => .error .badNumber
    | _, _, _ => .error .badTarget
  | .grant p c => match decodePrincipal p, decodeCapability c with
    | some p, some c => .ok (.grant p c)
    | _, _ => .error .badTarget
  | .revoke p c => match decodePrincipal p, decodeCapability c with
    | some p, some c => .ok (.revoke p c)
    | _, _ => .error .badTarget

def expectedRefusal (state : PublicState) (call : Call) : Option Reason :=
  if ¬ AmountValid call then some .badAmount
  else if ¬ Authorized state.capabilities call then some .unauthorized
  else if ¬ Funded state.ledger.balance state.rates call then some .insufficientFunds
  else none

def RawStepSpec (state : PublicState) (raw : RawCall) (result : Result) : Prop :=
  match decodeRaw raw with
  | .error reason => result = .refused reason state
  | .ok call => match expectedRefusal state call with
    | some reason => result = .refused reason state
    | none => ∃ post, result = .success post ∧ SuccessDomain state call ∧ LocalClaims state post call

inductive RawExecutionSpec : PublicState → List RawCall → SequenceResult → Prop
  | done (state) : RawExecutionSpec state [] ⟨state, none, 0⟩
  | refused (state raw calls reason)
      (step : RawStepSpec state raw (.refused reason state)) :
      RawExecutionSpec state (raw :: calls) ⟨state, some (reason, 0), 0⟩
  | success (state post raw calls result)
      (step : RawStepSpec state raw (.success post))
      (rest : RawExecutionSpec post calls result) :
      RawExecutionSpec state (raw :: calls) result.bump

def R4Canonical : Prop := ∀ state calls, ValidState state → calls.length = 4 →
  RawExecutionSpec state calls (runRaw state calls) ∧
  (runRaw state calls).committed ≤ 4 ∧
  ((runRaw state calls).failure = none → (runRaw state calls).committed = 4) ∧
  (∀ reason index, (runRaw state calls).failure = some (reason, index) →
    (runRaw state calls).committed = index ∧ index < 4 ∧
    ∀ suffix, runRaw state (calls ++ suffix) = runRaw state calls) ∧
  ∃ events, (runRaw state calls).state.history = state.history ++ events ∧
    events.length = (runRaw state calls).committed

def R6Canonical : Prop := ∀ state calls, ValidState state → calls.length = 4 →
  RawExecutionSpec state calls (runRaw state calls) ∧
  ((runRaw state calls).failure = none →
    atomicRaw state calls = runRaw state calls ∧ (atomicRaw state calls).committed = 4 ∧
    ∃ events, (atomicRaw state calls).state.history = state.history ++ events ∧ events.length = 4) ∧
  (∀ reason index, (runRaw state calls).failure = some (reason, index) →
    atomicRaw state calls = ⟨state, some (reason, index), 0⟩)

def adminUpdate (state : PublicState) (call : Call) : PublicState :=
  { state with
    capabilities := nextCapabilities state.capabilities call
    history := state.history ++ [event state.rates call] }

def R5Canonical : Prop :=
  (∀ state call cap, ValidState state → SuccessDomain state call → cap ∈ requiredCapabilities call →
    ∃ first revoked,
      execute state call = .success first ∧ LocalClaims state first call ∧
      execute first (.revoke .pool cap) = .success revoked ∧
      revoked = adminUpdate first (.revoke .pool cap) ∧ cap ∉ revoked.capabilities ∧
      execute revoked call = .refused .unauthorized revoked ∧
      execute revoked (.grant .pool cap) = .success (adminUpdate revoked (.grant .pool cap)) ∧
      cap ∈ (adminUpdate revoked (.grant .pool cap)).capabilities) ∧
  (∀ state cap, ValidState state →
    execute state (.grant .pool cap) = .success (adminUpdate state (.grant .pool cap)) ∧
    execute state (.revoke .pool cap) = .success (adminUpdate state (.revoke .pool cap)) ∧
    (∀ actor, actor ≠ .pool →
      execute state (.grant actor cap) = .refused .unauthorized state ∧
      execute state (.revoke actor cap) = .refused .unauthorized state) ∧
    nextCapabilities (nextCapabilities state.capabilities (.grant .pool cap)) (.grant .pool cap) =
      nextCapabilities state.capabilities (.grant .pool cap) ∧
    nextCapabilities (nextCapabilities state.capabilities (.revoke .pool cap)) (.revoke .pool cap) =
      nextCapabilities state.capabilities (.revoke .pool cap))

end RationalWorkflow
