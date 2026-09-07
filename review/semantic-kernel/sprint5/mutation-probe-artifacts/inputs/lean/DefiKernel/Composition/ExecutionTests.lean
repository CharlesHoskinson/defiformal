import DefiKernel.Composition.Execution
import DefiKernel.Typed.Examples

namespace DefiKernel.Composition.ExecutionTests
open Typed Typed.Examples

def iface : OperationInterface Party Asset Domain :=
  ⟨transferId, [⟨⟨0⟩, .amount .usd⟩], [⟨⟨1⟩, (.main, .alice, .usd)⟩]⟩

def component : Component Party Asset Domain :=
  ⟨⟨0⟩, [(.main, .alice, .usd), (.main, .bob, .usd)], [], [], [iface]⟩

def cfg : Config Party Asset Domain := ⟨registry, domainAdmin, [component]⟩
def boundary : Boundary Party Asset Domain := ⟨aliceContext, fresh, 100⟩
def adminBoundary : Boundary Party Asset Domain := ⟨adminContext, fresh, 100⟩
def invocation : Invocation Party Asset Domain :=
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd, 3⟩], allCapabilityIds, none⟩

def run (step : Step Party Asset Domain) (b := boundary) (config := cfg) :
    Except Failure (StepResult Party Asset Domain) := do
  let store ← provisioned.mapError Failure.authority
  executeStep config b 0 [] step ⟨initial, store⟩

def refuses (result : Except Failure (StepResult Party Asset Domain)) (reason : Failure) : Bool :=
  match result with
  | .error err => err == reason
  | .ok _ => false

def checks : List (String × Bool) := [
  ("execution.catalog", validateCatalog registry cfg.catalog),
  ("execution.transfer.receipt.snapshots", match run (.invoke invocation) with
    | .error _ => false
    | .ok r => decide (r.world.state.balance (.main, .alice, .usd) = 7 ∧
        r.world.state.balance (.main, .bob, .usd) = 3) &&
      (match r.receipt with
        | .invoked request e => request.operation == transferId &&
          decide (e.effect (.main, .alice, .usd) = -3 ∧ e.supply .main .usd = 0) &&
          decide (e.writes = [(.main, .alice, .usd), (.main, .bob, .usd)])
        | _ => false) &&
      (match r.outputs with
        | [obs] => obs.step == 0 && obs.port == ⟨⟨0⟩, ⟨1⟩⟩ &&
          (match obs.value with
            | ⟨.amount a, q⟩ => a == .usd && decide (q = 7)
            | _ => false)
        | _ => false)),
  ("execution.actor.precedes.authority", refuses
    (run (.invoke { invocation with claimedActor := some .bob, capabilityIds := [] }))
    (.kernel .actorMismatch)),
  ("execution.kernel.authority", refuses
    (run (.invoke { invocation with capabilityIds := [] })) (.kernel .unauthorizedInvoke)),
  ("execution.membership", refuses
    (run (.invoke { invocation with component := ⟨99⟩ })) (.interface .unknownOperation)),
  ("execution.binding.unit", refuses
    (run (.invoke { invocation with inputs := [.literal ⟨.amount .share, 3⟩] }))
    (.interface .inputUnit)),
  ("execution.configuration", refuses
    (run (.invoke invocation) boundary { cfg with catalog := [component, component] })
    .configuration),
  ("execution.issue.ledger.receipt",
    match run (.issue (grant transferId .invoke)) adminBoundary with
    | .error _ => false
    | .ok r => decide ((∀ c, r.world.state.balance c = initial.balance c) ∧ r.outputs = []) &&
      (match r.receipt with | .issued id => id == ⟨12⟩ | _ => false) &&
      decide (r.world.capabilities.nextId = ⟨13⟩)),
  ("execution.issue.unauthorized", refuses
    (run (.issue (grant transferId .invoke))) (.authority .unauthorizedAdmin)),
  ("execution.revoke.ledger.receipt", match run (.revoke ⟨0⟩) adminBoundary with
    | .error _ => false
    | .ok r => decide ((∀ c, r.world.state.balance c = initial.balance c) ∧ r.outputs = []) &&
      (match r.receipt with | .revoked id => id == ⟨0⟩ | _ => false) &&
      !authorizesId r.world.capabilities aliceContext transferId .invoke ⟨0⟩),
  ("execution.revoke.unknown", refuses (run (.revoke ⟨99⟩) adminBoundary)
    (.authority .unknownCapability))]

-- BEGIN PROOFS

#eval show IO _root_.Unit from do
  if checks.isEmpty then throw (IO.userError "Execution comparisons empty")
  for (label, ok) in checks do IO.println s!"{label}: {ok}"
  let failures := checks.filter (fun entry ↦ !entry.2)
  if !failures.isEmpty then
    throw (IO.userError s!"Execution comparisons failed: {failures.length}")

end DefiKernel.Composition.ExecutionTests
