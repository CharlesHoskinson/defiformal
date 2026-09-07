import DefiKernel.Parallel.Compatibility
import DefiKernel.Composition.Examples

/-! Bounded admission controls with independently specified footprint lists and financial siblings.
These are development fixtures; generic proof obligations are in Compatibility. -/
namespace DefiKernel.Parallel.CompatibilityTests
open Typed Composition Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev F := Footprint Party Asset Domain
abbrev I := Invocation Party Asset Domain

def aliceUSD : C := (.main, .alice, .usd)
def bobUSD : C := (.main, .bob, .usd)
def vaultShare : C := (.main, .vault, .share)
def aliceShare : C := (.main, .alice, .share)
def common : C := (.main, .alice, .collateral)
def cellRef (c : C) : CellRef Party Asset Domain c.2.2 := ⟨c.1, .literal c.2.1⟩
def packed (c : C) : PackedCellRef Party Asset Domain := ⟨c.2.2, cellRef c⟩
def transferOp (a : Asset) (sender recipient : Party) (q : ℚ) : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, ref a (.literal sender), .lit (-q)⟩,
    ⟨a, ref a (.literal recipient), .lit q⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef a (.literal sender), packedRef a (.literal recipient)]
def usdOp := transferOp .usd .alice .bob 3
def shareOp := transferOp .share .vault .alice 4
def readOnly (c : C) : Op := { usdOp with
  guard := .binary (.le (.amount c.2.2)) (.lit 0) (.balance (cellRef c))
  deltas := [], writes := [], stateReads := [packed c] }
def hidden (t : Op) (c : C) : Op := { t with
  guard := .ite (.lit true) t.guard
    (.binary (.le (.amount c.2.2)) (.lit 0) (.balance (cellRef c)))
  stateReads := [packed c] }
def cfg (left : Op := usdOp) (right : Op := shareOp)
    (leftOutput : List C := []) (rightOutput : List C := []) : Config Party Asset Domain where
  registry op := if op = ⟨10⟩ then some left else if op = ⟨11⟩ then some right else none
  domainAdmin := domainAdmin
  catalog := [⟨⟨0⟩, ([Domain.main, .other].flatMap fun d ↦
    [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
      [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)), [], [],
    [⟨⟨10⟩, [], leftOutput.map (fun c ↦ ⟨⟨0⟩, c⟩)⟩,
     ⟨⟨11⟩, [], rightOutput.map (fun c ↦ ⟨⟨1⟩, c⟩)⟩]⟩]
def boundary (_ : BranchId) (_ : Nat) : Boundary Party Asset Domain :=
  ⟨aliceContext, fresh, 100⟩
def left : I := ⟨⟨0⟩, ⟨10⟩, [], [], [⟨0⟩, ⟨1⟩], none⟩
def right : I := ⟨⟨0⟩, ⟨11⟩, [], [], [⟨2⟩, ⟨3⟩], none⟩
def leftFP : F := ⟨[aliceUSD, bobUSD, aliceUSD, bobUSD],
  [aliceUSD, bobUSD, aliceUSD, bobUSD]⟩
def rightFP : F := ⟨[vaultShare, aliceShare, vaultShare, aliceShare],
  [vaultShare, aliceShare, vaultShare, aliceShare]⟩
def initial : World Party Asset Domain := ⟨⟨fun c ↦
  if c = aliceUSD then 10 else if c = vaultShare then 20 else 0,
  by
    intro c
    split
    · decide
    · split <;> decide⟩,
  ⟨[⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .main, ⟨10⟩, .debit aliceUSD⟩, true⟩,
    ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .main, ⟨11⟩, .debit vaultShare⟩, true⟩]⟩⟩
def accepted {E X : Type} : Except E X → Bool
  | .ok _ => true
  | .error _ => false
def resultEq {E X : Type} [DecidableEq E] [DecidableEq X]
    (actual expected : Except E X) : Bool := decide (actual = expected)
def funded (config : Config Party Asset Domain) (inv : I) : Bool :=
  accepted (executeStep config (boundary .left 0) 0 [] (.invoke inv) initial)
def fundedExact (inv : I) (expected : C → ℚ) : Bool :=
  match executeStep cfg (boundary .left 0) 0 [] (.invoke inv) initial with
  | .error _ => false
  | .ok result => decide ((∀ c, result.world.state.balance c = expected c) ∧
      result.world.capabilities = initial.capabilities)
def overlap (kind : ConflictKind) (cell : C) :
    Except (AdmissionFailure Party Asset Domain) (F × F) :=
  .error (.conflict kind cell)
def zeroTarget : Op := { (readOnly common) with
  guard := .lit true
  stateReads := []
  deltas := [⟨.usd, cellRef aliceUSD, .lit 0⟩] }
def hiddenDelta : Op := { shareOp with
  deltas := shareOp.deltas.map (fun d ↦ { d with
    amount := .ite (.lit true) d.amount
      (.binary (.unconvert d.asset .usd) (.balance (cellRef aliceUSD)) (.lit 1)) })
  stateReads := [packed aliceUSD] }
def hiddenSupply : Op := { shareOp with
  supplyDeltas := [⟨.main, .usd,
    .ite (.lit true) (.lit 0) (.balance (cellRef aliceUSD))⟩]
  stateReads := [packed aliceUSD] }
def malformed : Op := { usdOp with stateReads := [packedRef .usd (.argument 3)] }
def deniedCfg : Config Party Asset Domain := { cfg with
  catalog := (cfg.catalog.map fun c ↦ { c with privateCells := [vaultShare, aliceShare] }) }
def checks : List (String × Bool) := [
  ("parallel.compat.catalog-positive", validateCatalog cfg.registry cfg.catalog),
  ("parallel.compat.invocation-exact-left", resultEq
    (analyzeInvocation cfg (boundary .left 0) left) (.ok leftFP)),
  ("parallel.compat.invocation-exact-right", resultEq
    (analyzeInvocation cfg (boundary .right 0) right) (.ok rightFP)),
  ("parallel.compat.funded-left-complete", fundedExact left
    (fun c ↦ if c = aliceUSD then 7 else if c = bobUSD then 3 else initial.state.balance c)),
  ("parallel.compat.funded-right-complete", fundedExact right
    (fun c ↦ if c = vaultShare then 16 else if c = aliceShare then 4 else initial.state.balance c)),
  ("parallel.compat.independent", resultEq (admit cfg boundary [left] [right])
    (.ok (leftFP, rightFP))),
  ("parallel.compat.empty", resultEq (admit cfg boundary [] []) (.ok (.empty, .empty))),
  ("parallel.compat.left-empty", resultEq (admit cfg boundary [] [right])
    (.ok (.empty, rightFP))),
  ("parallel.compat.common-read", accepted
    (admit (cfg (hidden usdOp common) (hidden shareOp common)) boundary [left] [right])),
  ("parallel.compat.write-write-witness", resultEq (admit cfg boundary [left] [left])
    (overlap .writeWrite aliceUSD)),
  ("parallel.compat.forward-read", resultEq
    (admit (cfg usdOp (readOnly aliceUSD)) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.reverse-read", resultEq
    (admit (cfg (readOnly vaultShare) shareOp) boundary [left] [right])
    (overlap .rightWriteLeftRead vaultShare)),
  ("parallel.compat.hidden-inactive-guard", resultEq
    (admit (cfg usdOp (hidden shareOp aliceUSD)) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-inactive-guard-funded",
    funded (cfg usdOp (hidden shareOp aliceUSD)) right),
  ("parallel.compat.hidden-delta", resultEq
    (admit (cfg usdOp hiddenDelta) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-delta-funded", funded (cfg usdOp hiddenDelta) right),
  ("parallel.compat.hidden-supply", resultEq
    (admit (cfg usdOp hiddenSupply) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-supply-funded", funded (cfg usdOp hiddenSupply) right),
  ("parallel.compat.output-dependency", resultEq
    (admit (cfg usdOp shareOp [] [aliceUSD]) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.output-exact", resultEq
    (analyzeInvocation (cfg usdOp shareOp [] [aliceUSD]) (boundary .right 0) right)
    (.ok ⟨rightFP.reads ++ [aliceUSD], rightFP.writes⟩)),
  ("parallel.compat.zero-target", resultEq
    (admit (cfg usdOp zeroTarget) boundary [left] [right]) (overlap .writeWrite aliceUSD)),
  ("parallel.compat.zero-target-funded", funded (cfg usdOp zeroTarget) right),
  ("parallel.compat.zero-target-exact", resultEq
    (analyzeInvocation (cfg usdOp zeroTarget) (boundary .right 0) right)
    (.ok ⟨[aliceUSD], [aliceUSD]⟩)),
  ("parallel.compat.unreachable-suffix", resultEq
    (admit cfg boundary [{left with capabilityIds := []}, right] [right])
    (overlap .writeWrite vaultShare)),
  ("parallel.compat.numeric-input-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0)
      {left with inputs := [.literal ⟨.amount .usd, -500⟩]}) (.ok leftFP)),
  ("parallel.compat.prior-output-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0)
      {left with inputs := [.priorOutput 9 ⟨⟨99⟩, ⟨99⟩⟩]}) (.ok leftFP)),
  ("parallel.compat.capability-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0) {left with capabilityIds := []}) (.ok leftFP)),
  ("parallel.compat.catalog-first", resultEq
    (admit {cfg with catalog := cfg.catalog ++ cfg.catalog} boundary
      [{left with operation := ⟨99⟩}] []) (.error .configuration)),
  ("parallel.compat.left-before-right", resultEq
    (admit cfg boundary [{left with operation := ⟨99⟩}] [{right with operation := ⟨98⟩}])
    (.error (.structural .left ⟨0, .interface .unknownOperation⟩))),
  ("parallel.compat.local-order", resultEq
    (admit cfg boundary [left, {left with operation := ⟨99⟩}, {left with operation := ⟨98⟩}] [])
    (.error (.structural .left ⟨1, .interface .unknownOperation⟩))),
  ("parallel.compat.structural-before-conflict", resultEq
    (admit cfg boundary [left] [left, {right with operation := ⟨99⟩}])
    (.error (.structural .right ⟨1, .interface .unknownOperation⟩))),
  ("parallel.compat.malformed-reference", resultEq
    (admit (cfg malformed shareOp) boundary [left] [right])
    (.error (.structural .left ⟨0, .interface (.resolution .partyArgument)⟩))),
  ("parallel.compat.access-check", resultEq
    (admit deniedCfg boundary [left] [right])
    (.error (.structural .left ⟨0, .interface .writeAccess⟩))),
  ("parallel.compat.forward-funded", funded (cfg usdOp (readOnly aliceUSD)) right),
  ("parallel.compat.reverse-funded", funded (cfg (readOnly vaultShare) shareOp) left),
  ("parallel.compat.output-funded", funded (cfg usdOp shareOp [] [aliceUSD]) right),
  ("parallel.compat.guard-read-exact", resultEq
    (analyzeInvocation (cfg usdOp (hidden shareOp aliceUSD)) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.delta-read-exact", resultEq
    (analyzeInvocation (cfg usdOp hiddenDelta) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.supply-read-exact", resultEq
    (analyzeInvocation (cfg usdOp hiddenSupply) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.forward-before-reverse", resultEq
    (checkCompatibility (⟨[bobUSD], [aliceUSD]⟩ : F) ⟨[aliceUSD], [bobUSD]⟩)
    (.error (.conflict .leftWriteRightRead aliceUSD))),
  ("parallel.compat.common-read-no-writes", resultEq
    (admit (cfg (readOnly common) (readOnly common)) boundary [left] [right])
    (.ok (⟨[common, common], []⟩, ⟨[common, common], []⟩))),
  ("parallel.compat.first-list-witness", resultEq
    (checkCompatibility (⟨[bobUSD, aliceUSD], [bobUSD, aliceUSD]⟩ : F) leftFP)
    (.error (.conflict .writeWrite bobUSD))) ]

end DefiKernel.Parallel.CompatibilityTests
