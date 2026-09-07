import DefiKernel.Atomic.Policy
import DefiKernel.Parallel.Examples

/-! Independent exact-rational Atomic fixture data. Expected worlds, receipts and outputs never
select an Atomic or Interleaving execution result. These are development examples, not fidelity. -/
namespace DefiKernel.Atomic.Examples
open Typed Composition Parallel Typed.Examples
open Parallel.Examples (C W I B Evt Obs cells cellRef packed output event transferEvent observed)

abbrev P := Party
abbrev A := Asset
abbrev D := Domain

def usdVault : C := (.main, .vault, .usd)
def usdAlice : C := (.main, .alice, .usd)
def usdBob : C := (.main, .bob, .usd)
def shareVault : C := (.main, .vault, .share)
def shareAlice : C := (.main, .alice, .share)
def otherVault : C := (.other, .vault, .usd)
def otherAlice : C := (.other, .alice, .usd)
def collateral : C := (.main, .alice, .collateral)
def refAt (d : D) (a : A) (p : PartyRef P) : CellRef P A D a := ⟨d, p⟩
def packedAt (d : D) (a : A) (p : PartyRef P) : PackedCellRef P A D := ⟨a, refAt d a p⟩

def transferAt (d : D) (a : A) (sender recipient : PartyRef P) : Op where
  signature := [.amount a]
  domain := d
  partyArity := 0
  guard := nonnegative a (.arg .here)
  deltas := [⟨a, refAt d a sender, negate a (.arg .here)⟩,
    ⟨a, refAt d a recipient, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedAt d a sender, packedAt d a recipient]

def drawTemplate := transferAt .main .usd (.literal .vault) .caller
def repayTemplate := transferAt .main .usd .caller (.literal .vault)
def drawShareTemplate := transferAt .main .share (.literal .vault) .caller
def repayShareTemplate := transferAt .main .share .caller (.literal .vault)
def drawOtherTemplate := transferAt .other .usd (.literal .vault) .caller
def repayOtherTemplate := transferAt .other .usd .caller (.literal .vault)
def noopTemplate : Op := { drawTemplate with deltas := [], writes := [] }
def repeatedTemplate : Op := { drawTemplate with
  deltas := [⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd .caller,
      .binary (.add (.amount Asset.usd)) (.arg .here) (.arg .here)⟩] }
def mintAt (a : A) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, refAt .main a .caller, .arg .here⟩]
  supplyDeltas := [⟨.main, a, .arg .here⟩]
  stateReads := []
  envReads := []
  writes := [packedAt .main a .caller]
def timedDrawTemplate : Op where
  signature := [.amount .usd, .scalar]
  domain := .main
  partyArity := 0
  guard := .binary (.eq .scalar) .now (.arg (.there .here))
  deltas := [⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd .caller, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := [.currentTime]
  writes := [packedAt .main .usd (.literal .vault), packedAt .main .usd .caller]
def liveDrawTemplate : Op := { drawTemplate with
  deltas := [⟨.usd, cellRef usdVault,
    .binary (.scale (.amount Asset.usd)) (.lit (-1 / 2 : ℚ)) (.balance (cellRef usdVault))⟩,
    ⟨.usd, refAt .main .usd .caller,
      .binary (.scale (.amount Asset.usd)) (.lit (1 / 2 : ℚ)) (.balance (cellRef usdVault))⟩]
  stateReads := [packed usdVault] }

structure FixtureOp where
  id : Nat
  template : Op
  output : C

def operations : List FixtureOp := [
  ⟨100, drawTemplate, usdVault⟩, ⟨101, repayTemplate, usdVault⟩,
  ⟨102, drawShareTemplate, shareVault⟩, ⟨103, repayShareTemplate, shareVault⟩,
  ⟨104, drawOtherTemplate, otherVault⟩, ⟨105, repayOtherTemplate, otherVault⟩,
  ⟨106, noopTemplate, usdVault⟩, ⟨107, repeatedTemplate, usdVault⟩,
  ⟨108, mintAt .usd, usdAlice⟩, ⟨109, mintAt .share, shareAlice⟩,
  ⟨110, timedDrawTemplate, usdVault⟩, ⟨111, liveDrawTemplate, usdVault⟩]

def fixtureComponent (op : FixtureOp) : Component P A D :=
  ⟨⟨op.id⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨999⟩, ⟨n⟩⟩, c, true⟩),
    [⟨⟨op.id⟩, op.template.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨10 + n⟩, u⟩),
      [⟨⟨0⟩, op.output⟩]⟩]⟩
def atomCfg : Config P A D where
  registry id := (operations.find? (fun op ↦ id = ⟨op.id⟩)).map FixtureOp.template
  domainAdmin := domainAdmin
  catalog := operations.map fixtureComponent ++
    [⟨⟨999⟩, [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c, true⟩), [], []⟩]

/-- Exact grants for funded Alice/Bob controls. First entry authorizes Alice's USD draw. -/
def atomStore : Store := ⟨operations.flatMap fun op ↦
  [Party.alice, .bob].flatMap fun actor ↦
    ([Right.invoke, .debit (op.template.domain, .alice, op.output.2.2),
      .debit (op.template.domain, .bob, op.output.2.2),
      .debit (op.template.domain, .vault, op.output.2.2),
      .changeSupply op.template.domain op.output.2.2]).map fun right ↦
        ⟨⟨actor, op.template.domain, ⟨op.id⟩, right⟩, true⟩⟩
def atomCaps : List CapabilityId := (List.range 120).map CapabilityId.mk
def revokedStore : Store := ⟨atomStore.entries.set 0
  ⟨⟨.alice, .main, ⟨100⟩, .invoke⟩, false⟩⟩

/-- Complete tables retain protected collateral9 and set every unlisted cell to zero. -/
def balanceTable (alice bob vault ash vsh oa ov : ℚ) : C → ℚ := fun c ↦
  if c = usdAlice then alice else if c = usdBob then bob else if c = usdVault then vault
  else if c = shareAlice then ash else if c = shareVault then vsh
  else if c = otherAlice then oa else if c = otherVault then ov
  else if c = collateral then 9 else 0

def atomWorld (alice bob vault ash vsh oa ov : Nat) (store : Store := atomStore) : W :=
  ⟨⟨balanceTable alice bob vault ash vsh oa ov, by
    intro c
    simp only [balanceTable]
    repeat' split
    all_goals positivity⟩, store⟩
def atomInitial := atomWorld 1 7 10 8 10 8 10
def afterDraw := atomWorld 8 7 3 8 10 8 10
def afterUnder := atomWorld 2 7 9 8 10 8 10
def afterOver := atomWorld 0 7 11 8 10 8 10
def afterPeerReturn := atomWorld 8 0 10 8 10 8 10
def afterAssetReturn := atomWorld 8 7 3 1 17 8 10
def afterDomainReturn := atomWorld 8 7 3 8 10 1 17
def afterLastLane := atomWorld 1 7 10 9 9 8 10
def afterLastParticipant := atomWorld 1 14 3 8 10 8 10
def afterLaneMint := atomWorld 4 7 10 8 10 8 10
def afterNonlaneMint := atomWorld 1 7 10 11 10 8 10
def afterDrawNonlaneMint := atomWorld 8 7 3 11 10 8 10
def revokedInitial := atomWorld 1 7 10 8 10 8 10 revokedStore

def atomBoundary (_ : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨.alice, .main⟩, fresh, 100⟩
def peerBoundary (branch : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨if branch = .left then .alice else .bob, .main⟩, fresh, 100⟩
def otherBoundary (branch : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨.alice, if branch = .left then .main else .other⟩, fresh, 100⟩
def localBoundary (branch : BranchId) (index : Nat) : Boundary P A D :=
  ⟨⟨if branch = .right then .bob else .alice, .main⟩, fresh,
    (if branch = .left then 100 else 200) + index⟩

def invocation (op : Nat) (a : A) (q : ℚ) : I :=
  ⟨⟨op⟩, ⟨op⟩, [], [.literal ⟨.amount a, q⟩], atomCaps, none⟩
def draw (q : ℚ) := invocation 100 .usd q
def repay (q : ℚ) := invocation 101 .usd q
def drawShare (q : ℚ) := invocation 102 .share q
def repayShare (q : ℚ) := invocation 103 .share q
def drawOther (q : ℚ) := invocation 104 .usd q
def repayOther (q : ℚ) := invocation 105 .usd q
def noop := invocation 106 .usd 0
def repeatedDraw := invocation 107 .usd (7 / 2)
def mintUSD := invocation 108 .usd 3
def mintShare := invocation 109 .share 3
def timedDraw (q time : ℚ) : I :=
  ⟨⟨110⟩, ⟨110⟩, [], [.literal ⟨.amount .usd, q⟩, .literal ⟨.scalar, time⟩], atomCaps, none⟩
def liveDraw := invocation 111 .usd 0

def drawReturnLeft : B := [draw 7, repay 7]
def underLeft : B := [draw 7, repay 6]
def overLeft : B := [draw 7, repay 8]
def creditLeft : B := [draw 7, repay 8, draw 1]
def noOpLeft : B := [draw 7, noop]
def nonlaneLeft : B := [draw 7, mintShare, repay 7]

def expectedTransfer (index : Nat) (inv : I) (sender recipient : C) (q cash : ℚ) : Evt :=
  transferEvent index inv sender recipient q [output index inv.component.value sender.2.2 cash]
def drawEvent (index : Nat := 0) (actor : P := .alice) : Evt :=
  expectedTransfer index (draw 7) usdVault (.main, actor, .usd) 7 3
def repayEvent (index : Nat) (q cash : ℚ) (actor : P := .alice) : Evt :=
  expectedTransfer index (repay q) (.main, actor, .usd) usdVault q cash
def drawReturnEvents : List Evt := [drawEvent, repayEvent 1 7 10]
def underEvents : List Evt := [drawEvent, repayEvent 1 6 9]
def overEvents : List Evt := [drawEvent, repayEvent 1 8 11]
def creditEvents : List Evt := overEvents ++
  [expectedTransfer 2 (draw 1) usdVault usdAlice 1 10]
def peerReturnEvents : List Evt := [drawEvent, repayEvent 0 7 10 .bob]
def assetReturnEvents : List Evt := [drawEvent,
  expectedTransfer 0 (repayShare 7) shareAlice shareVault 7 17]
def domainReturnEvents : List Evt := [drawEvent,
  expectedTransfer 0 (repayOther 7) otherAlice otherVault 7 17]
def lastLaneEvents : List Evt := [expectedTransfer 0 (drawShare 1) shareVault shareAlice 1 9]
def lastParticipantEvents : List Evt := [drawEvent 0 .bob]
def noOpEvent : Evt := event 1 noop [⟨.amount .usd, 0⟩]
  ⟨true, [], [], [], [], [], [], []⟩ [output 1 106 .usd 3]
def repeatedEvent : Evt := event 0 repeatedDraw [⟨.amount .usd, 7 / 2⟩]
  ⟨true, [(usdVault, -7 / 2), (usdVault, -7 / 2), (usdAlice, 7)],
    [], [], [], [], [], [usdVault, usdAlice]⟩ [output 0 107 .usd 3]
def mintEvent (index : Nat) (inv : I) (cell : C) (amount post : ℚ) : Evt :=
  event index inv [⟨.amount cell.2.2, amount⟩]
    ⟨true, [(cell, amount)], [((cell.1, cell.2.2), amount)], [], [], [], [], [cell]⟩
    [output index inv.component.value cell.2.2 post]
def laneMintEvent := mintEvent 0 mintUSD usdAlice 3 4
def nonlaneMintEvent := mintEvent 1 mintShare shareAlice 3 11
def nonlaneEvents : List Evt := [drawEvent, nonlaneMintEvent, repayEvent 2 7 10]


def usdLane : Lane P A D := ⟨.main, .usd, .vault⟩
def shareLane : Lane P A D := ⟨.main, .share, .vault⟩
def otherLane : Lane P A D := ⟨.other, .usd, .vault⟩
def basePolicy : Policy P A D := ⟨[usdLane], [.alice]⟩
def multiLanePolicy : Policy P A D := ⟨[usdLane, shareLane], [.alice]⟩
def domainPolicy : Policy P A D := ⟨[usdLane, otherLane], [.alice]⟩
def multiParticipantPolicy : Policy P A D := ⟨[usdLane], [.alice, .bob]⟩
def batchPolicy : Policy P A D := ⟨[], [.alice, .bob]⟩
def duplicateLanePolicy : Policy P A D := ⟨[usdLane, ⟨.main, .usd, .pool⟩], [.alice]⟩
def duplicateParticipantPolicy : Policy P A D := ⟨[usdLane], [.alice, .bob, .alice]⟩

def drawResiduals : List (Residual P A D) := [⟨usdLane, .alice, 7⟩]
def underResiduals : List (Residual P A D) := [⟨usdLane, .alice, 1⟩]
def overResiduals : List (Residual P A D) := [⟨usdLane, .alice, -1⟩]
def peerResiduals : List (Residual P A D) := [⟨usdLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]
def assetResiduals : List (Residual P A D) :=
  [⟨usdLane, .alice, 7⟩, ⟨shareLane, .alice, -7⟩]
def domainResiduals : List (Residual P A D) :=
  [⟨usdLane, .alice, 7⟩, ⟨otherLane, .alice, -7⟩]
def lastLaneResiduals : List (Residual P A D) := [⟨shareLane, .alice, 1⟩]
def lastParticipantResiduals : List (Residual P A D) := [⟨usdLane, .bob, 7⟩]

/-- A direct finite expected table, independent of production update and residual enumeration. -/
def expectedOutstanding (entries : List (Residual P A D)) : Outstanding P A D :=
  fun lane principal ↦ match entries.find? (fun entry ↦
      decide (entry.lane = lane ∧ entry.principal = principal)) with
    | some entry => entry.amount
    | none => 0

-- BEGIN PROOFS

end DefiKernel.Atomic.Examples
