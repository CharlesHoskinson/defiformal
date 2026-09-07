import DefiKernel.Composition.Interfaces
import DefiKernel.Typed.Examples

/-! Bounded independent siblings for structural interfaces. Kernel execution supplies a
funding/authority control; sequence commit preservation belongs to the adapter tests. -/
namespace DefiKernel.Composition.InterfaceTests
open Typed Typed.Examples

abbrev C := Component Party Asset Domain
abbrev I := OperationInterface Party Asset Domain

def aliceUSD : Cell Party Asset Domain := (.main, .alice, .usd)
def bobUSD : Cell Party Asset Domain := (.main, .bob, .usd)
def vaultUSD : Cell Party Asset Domain := (.main, .vault, .usd)
def iface : I := ⟨transferId, [⟨⟨0⟩, .amount .usd⟩], [⟨⟨1⟩, aliceUSD⟩]⟩
def owner : C := ⟨⟨0⟩, [aliceUSD, bobUSD], [], [], [iface]⟩
def foreign : C := ⟨⟨1⟩, [vaultUSD], [], [], []⟩
def exporter : C := ⟨⟨1⟩, [], [⟨⟨10⟩, vaultUSD, true⟩], [], []⟩
def shared : C := { owner with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, vaultUSD, true⟩] }
def readOnly : C := { shared with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, vaultUSD, false⟩] }
def accepted (r : Except InterfaceFailure PUnit) : Bool :=
  match r with | .ok _ => true | .error _ => false

def failure {α : Type} (r : Except InterfaceFailure α) (expected : InterfaceFailure) : Bool :=
  match r with | .ok _ => false | .error e => decide (e = expected)

def sevenUSD (r : Except InterfaceFailure (List (PackedValue Asset))) : Bool :=
  match r with | .ok [⟨.amount .usd, q⟩] => decide (q = 7) | _ => false

def history : List (OutputObservation Asset) := [⟨2, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩]
def binding : List (InputSource Asset) := [.priorOutput 2 ⟨⟨0⟩, ⟨1⟩⟩]
def hiddenGuard : Op := { transfer with
  guard := .ite (.lit true) (.lit true)
    (.binary (.le (.amount .usd)) (.balance (ref .usd (.literal .vault))) (.lit 100)) }
def hiddenEffect : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, .balance (ref .usd (.literal .vault))⟩] }
def hiddenSupply : Op := { transfer with
  supplyDeltas := [⟨.main, .usd, .balance (ref .usd (.literal .vault))⟩] }
def fundedKernelControl : Bool := match provisioned with
  | .error _ => false
  | .ok store => match Typed.execute registry store aliceContext fresh 100
      (transferRequest 3 .vault) initial with
    | .error _ => false
    | .ok post => decide (post.state.balance aliceUSD = 7 ∧ post.state.balance vaultUSD = 23)

def checks : List (String × Bool) := [
  ("interface.unique-export-provider", !validateCatalog registry
    [{ owner with exports := [⟨⟨10⟩, vaultUSD, true⟩] },
     { exporter with exports := [⟨⟨10⟩, vaultUSD, false⟩] }]),
  ("interface.missing-import-source", !validateCatalog registry
    [{ shared with imports := [⟨⟨⟨99⟩, ⟨10⟩⟩, vaultUSD, true⟩] }, exporter]),
  ("interface.wrong-import-port", !validateCatalog registry
    [{ shared with imports := [⟨⟨⟨1⟩, ⟨99⟩⟩, vaultUSD, true⟩] }, exporter]),
  ("interface.self-import", !validateCatalog registry
    [owner, { exporter with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, vaultUSD, true⟩] }]),
  ("interface.self-readonly-import-writable-export", !validateCatalog registry
    [owner, { exporter with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, vaultUSD, false⟩] }]),
  ("interface.readonly-export-selfwrite",
    !({ exporter with exports := [⟨⟨10⟩, vaultUSD, false⟩] } : C).canWrite vaultUSD),
  ("interface.writable-export-selfwrite", exporter.canWrite vaultUSD),
  ("interface.crossdomain-output", !validateCatalog registry
    [{ owner with
      privateCells := owner.privateCells ++ [(.other, .alice, .usd)]
      operations := [{ iface with outputs := [⟨⟨1⟩, (.other, .alice, .usd)⟩] }] }]),
  ("interface.valid", validateCatalog registry [owner, foreign]),
  ("interface.duplicate-component", !validateCatalog registry [owner, owner]),
  ("interface.duplicate-output", !validateCatalog registry
    [{ owner with operations := [{ iface with outputs := [⟨⟨1⟩, aliceUSD⟩, ⟨⟨1⟩, bobUSD⟩] }] }]),
  ("interface.input-output-collision", !validateCatalog registry
    [{ owner with operations := [{ iface with inputs := [⟨⟨1⟩, .amount .usd⟩] }] }]),
  ("interface.duplicate-export", !validateCatalog registry
    [shared, { exporter with exports := [⟨⟨10⟩, vaultUSD, true⟩, ⟨⟨10⟩, vaultUSD, true⟩] }]),
  ("interface.duplicate-import", !validateCatalog registry
    [{ shared with imports := shared.imports ++ shared.imports }, exporter]),
  ("interface.unknown-operation", !validateCatalog registry
    [{ owner with operations := [{ iface with operation := ⟨99⟩ }] }]),
  ("interface.ambiguous-owner", !validateCatalog registry
    [owner, { foreign with privateCells := [], operations := [{ iface with outputs := [] }] }]),
  ("interface.wrong-signature", !validateCatalog registry
    [{ owner with operations := [{ iface with inputs := [⟨⟨0⟩, .amount .share⟩] }] }]),
  ("interface.private-overlap", !validateCatalog registry
    [owner, { foreign with privateCells := [aliceUSD] }]),
  ("interface.private-export", !validateCatalog registry
    [owner, { foreign with exports := [⟨⟨10⟩, vaultUSD, true⟩] }]),
  ("interface.private-import", !validateCatalog registry [shared, foreign]),
  ("interface.shared-write-valid", validateCatalog registry [shared, exporter]),
  ("interface.shared-read-valid", validateCatalog registry [readOnly, exporter]),
  ("interface.import-cell", !validateCatalog registry
    [{ shared with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, (.main, .pool, .usd), true⟩] }, exporter]),
  ("interface.import-domain", !validateCatalog registry
    [{ shared with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, (.other, .vault, .usd), true⟩] }, exporter]),
  ("interface.import-asset", !validateCatalog registry
    [{ shared with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, (.main, .vault, .share), true⟩] }, exporter]),
  ("interface.import-rights", !validateCatalog registry
    [shared, { exporter with exports := [⟨⟨10⟩, vaultUSD, false⟩] }]),
  ("interface.output-hidden", !validateCatalog registry
    [{ owner with operations := [{ iface with outputs := [⟨⟨1⟩, vaultUSD⟩] }] }]),
  ("interface.lookup-owner", (lookupOperation [owner, foreign] ⟨0⟩ transferId).isSome),
  ("interface.lookup-foreign", (lookupOperation [owner, foreign] ⟨1⟩ transferId).isNone),
  ("interface.private-access", accepted (checkAccess owner transfer aliceContext [.bob])),
  ("interface.foreign-funded-kernel-control", fundedKernelControl),
  ("interface.foreign-write",
    failure (checkAccess owner transfer aliceContext [.vault]) .writeAccess),
  ("interface.shared-write", accepted (checkAccess shared transfer aliceContext [.vault])),
  ("interface.readonly-write",
    failure (checkAccess readOnly transfer aliceContext [.vault]) .writeAccess),
  ("interface.actual-target", failure (checkAccess owner
    { transfer with writes := [] } aliceContext [.vault]) .writeAccess),
  ("interface.hidden-branch",
    failure (checkAccess owner hiddenGuard aliceContext [.bob]) .readAccess),
  ("interface.hidden-effect",
    failure (checkAccess owner hiddenEffect aliceContext [.bob]) .readAccess),
  ("interface.hidden-supply",
    failure (checkAccess owner hiddenSupply aliceContext [.bob]) .readAccess),
  ("interface.shared-read", accepted (checkAccess readOnly hiddenGuard aliceContext [.bob])),
  ("interface.declared-write", failure (checkAccess owner
    { transfer with writes := transfer.writes ++ [packedRef .usd (.literal .vault)] }
    aliceContext [.bob]) .writeAccess),
  ("interface.declared-read", failure (checkAccess owner
    { transfer with stateReads := [packedRef .usd (.literal .vault)] }
    aliceContext [.bob]) .readAccess),
  ("interface.missing-party", failure (checkAccess owner transfer aliceContext [])
    (.resolution .partyArgument)),
  ("interface.literal", sevenUSD (resolveInputs 3 [] iface [.literal ⟨.amount .usd, 7⟩])),
  ("interface.snapshot-binding", sevenUSD (resolveInputs 3 history iface binding)),
  ("interface.wrong-unit", failure (resolveInputs 3 history iface
    [.literal ⟨.amount .share, 7⟩]) .inputUnit),
  ("interface.wrong-output-unit", failure (resolveInputs 3
    [⟨2, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .share, 7⟩⟩] iface binding) .inputUnit),
  ("interface.unknown-port", failure (resolveInputs 3 history iface
    [.priorOutput 2 ⟨⟨0⟩, ⟨99⟩⟩]) .unavailableOutput),
  ("interface.forward", failure (resolveInputs 1 history iface binding) .unavailableOutput),
  ("interface.current-index", failure (resolveInputs 2 history iface binding) .unavailableOutput),
  ("interface.unavailable", failure (resolveInputs 3 [] iface binding) .unavailableOutput),
  ("interface.input-count", failure (resolveInputs 3 history iface []) .inputCount),
  ("interface.snapshot-exact", match snapshots 2 ⟨0⟩ iface initial with
    | [⟨2, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, q⟩⟩] => decide (q = 10)
    | _ => false)
]

-- BEGIN PROOFS

#eval show IO _root_.Unit from do
  if checks.isEmpty then throw (IO.userError "Interface comparison inventory empty")
  for (label, ok) in checks do IO.println s!"{label}: {ok}"
  let failures := checks.filter (fun entry ↦ !entry.2)
  if !failures.isEmpty then throw (IO.userError s!"Interface failures: {failures.length}")

end DefiKernel.Composition.InterfaceTests
