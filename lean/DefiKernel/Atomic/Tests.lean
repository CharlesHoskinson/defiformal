import DefiKernel.Atomic.Examples
import DefiKernel.Atomic.Observation
import DefiKernel.Interleaving.Examples
import DefiKernel.Parallel.ObservationTests

/-! Named bounded checks compare production execution with independent complete expectations. -/
namespace DefiKernel.Atomic.Tests
open Typed Composition Parallel Typed.Examples Atomic.Examples
open Parallel.Examples (C W I B Evt output observed event)

abbrev O := Observation P A D
abbrev R := Atomic.Result P A D
abbrev Inner := InnerObservation P A D

def expectedInner (branch : BranchId) (e : Evt) : Inner :=
  ⟨branch, e.index, match e.step with | .invoke inv => inv | _ => draw 0,
    e.receipt, e.outputs⟩
def inners (branch : BranchId) (events : List Evt) : List Inner :=
  events.map (expectedInner branch)
def supplyZero : D → A → ℚ := fun _ _ ↦ 0
def shareSupply : D → A → ℚ := fun d a ↦ if d = .main ∧ a = .share then 3 else 0

def expectedCommit (schedule : Interleaving.Schedule) (world : W) (events : List Inner)
    (supply : D → A → ℚ := supplyZero) : O :=
  ⟨42, schedule, .committed, world, [⟨42, schedule, events⟩], supply⟩
def expectedAbort (schedule : Interleaving.Schedule) (reason : AbortReason P A D)
    (world : W := atomInitial) : O := ⟨42, schedule, .aborted reason, world, [], supplyZero⟩
def expectedRefused (schedule : Interleaving.Schedule) (reason : Atomic.AdmissionFailure P A D)
    (world : W := atomInitial) : O := ⟨42, schedule, .refused reason, world, [], supplyZero⟩
def run (left right : B) (schedule : Interleaving.Schedule)
    (policy : Policy P A D := basePolicy) (boundary : ParallelBoundary P A D := atomBoundary)
    (world : W := atomInitial) : R := runAtomic atomCfg boundary 42 policy world left right schedule

def checkExpected (actual : R) (expected : O) : Bool := observationEq (observe actual) expected

def allLanes : List (Lane P A D) := Parallel.Examples.cells.map fun c ↦ ⟨c.1, c.2.2, c.2.1⟩
def tableMatches (actual : Outstanding P A D) (expected : List (Residual P A D)) : Bool :=
  allLanes.all fun lane ↦ [Party.alice, .bob, .vault, .pool].all fun p ↦
    decide (actual lane p = expectedOutstanding expected lane p)
def machineMatches (m : Atomic.Machine P A D) (count position : Nat) (world : W)
    (owed : List (Residual P A D)) (events : List Inner) : Bool :=
  worldEq m.speculative.world world && worldEq m.entryWorld atomInitial &&
    decide (m.speculative.attempts.length = count ∧ m.position = position) &&
    tableMatches m.outstanding owed && decide ((diagnosticEvent 42 [] m).inner = events)
def diagnosticMatches (actual : R) (count position : Nat) (world : W)
    (owed : List (Residual P A D)) (events : List Inner) : Bool :=
  match actual with
  | .refused _ _ _ _ => false
  | .aborted _ _ _ m | .committed _ _ m => machineMatches m count position world owed events

def drawReturn := run drawReturnLeft [] [.left, .left]
def underReturn := run underLeft [] [.left, .left]
def overReturn := run overLeft [] [.left, .left]
def creditReturn := run creditLeft [] [.left, .left, .left]
def peerReturn := run [draw 7] [repay 7] [.left, .right] multiParticipantPolicy peerBoundary
def assetReturn := run [draw 7] [repayShare 7] [.left, .right] multiLanePolicy
def domainReturn := run [draw 7] [repayOther 7] [.left, .right] domainPolicy otherBoundary
def noOpRun := run noOpLeft [] [.left, .left]
def repeatedRun := run [repeatedDraw, repay 7] [] [.left, .left]
def nonlaneRun := run nonlaneLeft [] [.left, .left, .left]
def firstFail := run [draw 11, draw 1] [mintShare] [.left, .right, .left]
def middleFail := run [draw 7, draw 6, draw 1] [mintShare] [.left, .right, .left, .left]
def mintFail := run [mintShare, draw 11] [] [.left, .left]
def abortFirst : AbortReason P A D := .kernel .left 0 0 (draw 11) (.kernel .insufficientFunds)
def abortMiddle : AbortReason P A D := .kernel .left 1 2 (draw 6) (.kernel .insufficientFunds)
def abortMint : AbortReason P A D := .kernel .left 1 1 (draw 11) (.kernel .insufficientFunds)
def mintFirstEvent := mintEvent 0 mintShare shareAlice 3 11

def settlementChecks : List (String × Bool) := [
  ("atomic.fixture.catalog", validateCatalog atomCfg.registry atomCfg.catalog),
  ("atomic.fixture.store", decide (atomStore.entries.length = 120)),
  ("atomic.fixture.empty", checkExpected (run [] [] []) (expectedCommit [] atomInitial [])),
  ("atomic.fixture.empty.batch", checkExpected (run [] [] [] batchPolicy)
    (expectedCommit [] atomInitial [])),
  ("atomic.fixture.settlement.draw.return", checkExpected drawReturn
    (expectedCommit [.left, .left] atomInitial (inners .left drawReturnEvents))),
  ("atomic.fixture.settlement.draw.prefix", machineMatches
    (runPrefix atomCfg atomBoundary basePolicy atomInitial drawReturnLeft [] [.left])
    1 1 afterDraw drawResiduals (inners .left [drawEvent])),
  ("atomic.fixture.settlement.initial.table", machineMatches (Atomic.start atomInitial)
    0 0 atomInitial [] []),
  ("atomic.fixture.settlement.clear.table", diagnosticMatches drawReturn
    2 2 atomInitial [] (inners .left drawReturnEvents)),
  ("atomic.fixture.settlement.under", checkExpected underReturn
    (expectedAbort [.left, .left] (.unsettled underResiduals))),
  ("atomic.fixture.settlement.under.diagnostic", diagnosticMatches underReturn
    2 2 afterUnder underResiduals (inners .left underEvents)),
  ("atomic.fixture.settlement.over", checkExpected overReturn
    (expectedAbort [.left, .left] (.unsettled overResiduals))),
  ("atomic.fixture.settlement.credit.prefix", machineMatches
    (runPrefix atomCfg atomBoundary basePolicy atomInitial creditLeft [] [.left, .left])
    2 2 afterOver overResiduals (inners .left overEvents)),
  ("atomic.fixture.settlement.credit.commit", checkExpected creditReturn
    (expectedCommit [.left, .left, .left] atomInitial (inners .left creditEvents))),
  ("atomic.fixture.settlement.cross.principal", checkExpected peerReturn
    (expectedAbort [.left, .right] (.unsettled peerResiduals))),
  ("atomic.fixture.settlement.cross.principal.table", diagnosticMatches peerReturn
    2 2 afterPeerReturn peerResiduals
    [expectedInner .left drawEvent, expectedInner .right (repayEvent 0 7 10 .bob)]),
  ("atomic.fixture.settlement.cross.asset", checkExpected assetReturn
    (expectedAbort [.left, .right] (.unsettled assetResiduals))),
  ("atomic.fixture.settlement.cross.domain", checkExpected domainReturn
    (expectedAbort [.left, .right] (.unsettled domainResiduals))),
  ("atomic.fixture.settlement.last.lane", checkExpected
    (run [drawShare 1] [] [.left] multiLanePolicy)
    (expectedAbort [.left] (.unsettled lastLaneResiduals))),
  ("atomic.fixture.settlement.last.participant", checkExpected
    (run [] [draw 7] [.right] multiParticipantPolicy peerBoundary)
    (expectedAbort [.right] (.unsettled lastParticipantResiduals))),
  ("atomic.fixture.settlement.noop", checkExpected noOpRun
    (expectedAbort [.left, .left] (.unsettled drawResiduals))),
  ("atomic.fixture.settlement.noop.table", diagnosticMatches noOpRun
    2 2 afterDraw drawResiduals (inners .left [drawEvent, noOpEvent])),
  ("atomic.fixture.settlement.repeated.prefix", machineMatches
    (runPrefix atomCfg atomBoundary basePolicy atomInitial [repeatedDraw, repay 7] [] [.left])
    1 1 afterDraw drawResiduals (inners .left [repeatedEvent])),
  ("atomic.fixture.settlement.repeated.commit", checkExpected repeatedRun
    (expectedCommit [.left, .left] atomInitial (inners .left [repeatedEvent, repayEvent 1 7 10]))),
  ("atomic.fixture.supply.lane.nonvault", checkExpected (run [mintUSD] [] [.left])
    (expectedAbort [.left] (.laneSupply .left 0 0 mintUSD usdLane 3))),
  ("atomic.fixture.supply.lane.diagnostic", diagnosticMatches (run [mintUSD] [] [.left])
    1 1 afterLaneMint [] (inners .left [laneMintEvent])),
  ("atomic.fixture.supply.nonlane", checkExpected nonlaneRun
    (expectedCommit [.left, .left, .left] afterNonlaneMint
      (inners .left nonlaneEvents) shareSupply)),
  ("atomic.fixture.abort.first.public", checkExpected firstFail
    (expectedAbort [.left, .right, .left] abortFirst)),
  ("atomic.fixture.abort.first.stopped", diagnosticMatches firstFail 1 1 atomInitial [] []),
  ("atomic.fixture.abort.middle.public", checkExpected middleFail
    (expectedAbort [.left, .right, .left, .left] abortMiddle)),
  ("atomic.fixture.abort.middle.stopped", diagnosticMatches middleFail 3 3 afterDrawNonlaneMint
    drawResiduals [expectedInner .left drawEvent, expectedInner .right mintFirstEvent]),
  ("atomic.fixture.abort.outputs", decide ((observe middleFail).events = [])),
  ("atomic.fixture.abort.supply", checkExpected mintFail
    (expectedAbort [.left, .left] abortMint)),
  ("atomic.fixture.abort.supply.diagnostic", diagnosticMatches mintFail 2 2 afterNonlaneMint []
    (inners .left [mintFirstEvent])),
  ("atomic.fixture.collateral", decide ((observe nonlaneRun).world.state.balance collateral = 9 ∧
    (observe middleFail).world.state.balance collateral = 9)),
  ("atomic.fixture.capability.revoked", checkExpected
    (run drawReturnLeft [] [.left, .left] basePolicy atomBoundary revokedInitial)
    (expectedAbort [.left, .left]
      (.kernel .left 0 0 (draw 7) (.kernel .unauthorizedInvoke)) revokedInitial)),
  ("atomic.fixture.capability.live", checkExpected drawReturn
    (expectedCommit [.left, .left] atomInitial (inners .left drawReturnEvents))) ]

/-- Earlier reference fixtures retain independent complete event expectations. -/
def oldRun (cfg : Config P A D) (boundary : ParallelBoundary P A D) (world : W)
    (left right : B) (schedule : Interleaving.Schedule) : R :=
  runAtomic cfg boundary 42 ⟨[], [.alice, .bob, .vault, .pool]⟩ world left right schedule

def liveRun := oldRun Interleaving.Examples.liveCfg Parallel.Examples.boundaries
  Parallel.Examples.initial [Parallel.Examples.usd 0, Parallel.Examples.usd 0]
  [Parallel.Examples.peerUSD 4] [.left, .right, .left]
def liveWorld : W := ⟨⟨Parallel.Examples.balanceTable (9 / 2) (19 / 2) 20 0 16 1, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals norm_num⟩, Parallel.Examples.store⟩
def liveEvents : List Inner := [
  expectedInner .left (Parallel.Examples.statefulEvent 0 5 5),
  expectedInner .right (Parallel.Examples.transferEvent 0 (Parallel.Examples.peerUSD 4)
    Parallel.Examples.vaultUSD Parallel.Examples.aliceUSD 4 [output 0 1 .usd 9]),
  expectedInner .left (Parallel.Examples.statefulEvent 1 (9 / 2) (19 / 2))]
def peerOnlyRun := oldRun Parallel.Examples.sameAssetCfg Parallel.Examples.boundaries
  Parallel.Examples.initial [Parallel.Examples.usd 3, Interleaving.Examples.peerOnly]
  [Parallel.Examples.peerUSD 4] [.left, .right, .left]
def ownRun := oldRun Parallel.Examples.sameAssetCfg Parallel.Examples.boundaries
  Parallel.Examples.initial [Parallel.Examples.usd 3, Interleaving.Examples.snapshotConsumer]
  [Parallel.Examples.peerUSD 4] [.left, .right, .left]
def ownWorld : W := ⟨⟨Parallel.Examples.balanceTable 4 6 20 0 16 5, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩
def timedRun := oldRun Parallel.Examples.timedCfg Parallel.Examples.timedBoundaries
  Parallel.Examples.initial Parallel.Examples.timedLeft Parallel.Examples.timedRight
  [.right, .left, .left, .right]
def timedWorld : W := ⟨⟨Parallel.Examples.balanceTable 8 2 14 6, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩

def historyChecks : List (String × Bool) := [
  ("atomic.fixture.live.complete", checkExpected liveRun
    (expectedCommit [.left, .right, .left] liveWorld liveEvents)),
  ("atomic.fixture.history.peer.only", checkExpected peerOnlyRun
    (expectedAbort [.left, .right, .left]
      (.kernel .left 1 2 Interleaving.Examples.peerOnly (.interface .unavailableOutput))
      Parallel.Examples.initial)),
  ("atomic.fixture.history.own", checkExpected ownRun
    (expectedCommit [.left, .right, .left] ownWorld [
      expectedInner .left (Parallel.Examples.leftEvent 0 3 3),
      expectedInner .right (Parallel.Examples.peerEvent 0 4 5),
      expectedInner .left (Parallel.Examples.transferEvent 1
        Interleaving.Examples.snapshotConsumer Parallel.Examples.aliceUSD Parallel.Examples.bobUSD
        3 [output 1 0 .usd 6])])),
  ("atomic.fixture.boundary.local", checkExpected timedRun
    (expectedCommit [.right, .left, .left, .right] timedWorld [
      expectedInner .right (Parallel.Examples.timedEvent 0
        (Parallel.Examples.timedInvocation 1 11 .share 4 200 .alice)
        Parallel.Examples.vaultShare Parallel.Examples.aliceShare 4 200 4),
      expectedInner .left (Parallel.Examples.timedEvent 0
        (Parallel.Examples.timedInvocation 0 10 .usd 3 100 .bob)
        Parallel.Examples.aliceUSD Parallel.Examples.bobUSD 3 100 3),
      expectedInner .left (Parallel.Examples.timedEvent 1
        (Parallel.Examples.timedInvocation 0 10 .usd 1 101 .alice)
        Parallel.Examples.bobUSD Parallel.Examples.aliceUSD 1 101 2),
      expectedInner .right (Parallel.Examples.timedEvent 1
        (Parallel.Examples.timedInvocation 1 11 .share 2 201 .alice)
        Parallel.Examples.vaultShare Parallel.Examples.aliceShare 2 201 6)])) ]

def invalidCfg : Config P A D := { atomCfg with catalog := atomCfg.catalog ++ atomCfg.catalog }
def unknown : I := { draw 1 with operation := ⟨9999⟩ }
def laterBoundary (_ : BranchId) (index : Nat) : Boundary P A D :=
  ⟨⟨if index = 0 then .alice else .bob, .main⟩, fresh, 100⟩
def missingCap : I := { draw 7 with capabilityIds := [] }
def debitMissing : I := { draw 7 with capabilityIds := [⟨0⟩] }
def batchSingle := run [draw 7] [] [.left] batchPolicy

def admissionChecks : List (String × Bool) := [
  ("atomic.fixture.batch.single", checkExpected batchSingle
    (expectedCommit [.left] afterDraw (inners .left [drawEvent]))),
  ("atomic.fixture.order.commit", checkExpected (run [draw 7] [repay 7] [.left, .right])
    (expectedCommit [.left, .right] atomInitial
      [expectedInner .left drawEvent, expectedInner .right (repayEvent 0 7 10)])),
  ("atomic.fixture.order.abort", checkExpected (run [draw 7] [repay 7] [.right, .left])
    (expectedAbort [.right, .left]
      (.kernel .right 0 0 (repay 7) (.kernel .insufficientFunds)))),
  ("atomic.fixture.capability.missing", checkExpected (run [missingCap] [] [.left])
    (expectedAbort [.left] (.kernel .left 0 0 missingCap (.kernel .unauthorizedInvoke)))),
  ("atomic.fixture.capability.debit", checkExpected (run [debitMissing] [] [.left])
    (expectedAbort [.left] (.kernel .left 0 0 debitMissing (.kernel .unauthorizedDebit)))),
  ("atomic.admission.configuration", checkExpected
    (runAtomic invalidCfg atomBoundary 42 duplicateLanePolicy atomInitial [unknown] [] [])
    (expectedRefused [] .configuration)),
  ("atomic.admission.left", checkExpected
    (run [draw 11, unknown] [unknown] [] duplicateLanePolicy)
    (expectedRefused [] (.structural .left ⟨1, .interface .unknownOperation⟩))),
  ("atomic.admission.right", checkExpected (run [draw 7] [unknown] [] duplicateLanePolicy)
    (expectedRefused [] (.structural .right ⟨0, .interface .unknownOperation⟩))),
  ("atomic.admission.lane.alternate.vault", checkExpected
    (run [draw 7] [] [] duplicateLanePolicy)
    (expectedRefused [] (.policy (.duplicateLane 0 1 usdLane ⟨.main, .usd, .pool⟩)))),
  ("atomic.admission.lane.same.vault", checkExpected
    (run [] [] [] ⟨[usdLane, usdLane], [.alice]⟩)
    (expectedRefused [] (.policy (.duplicateLane 0 1 usdLane usdLane)))),
  ("atomic.admission.participant.duplicate", checkExpected
    (run [] [] [] duplicateParticipantPolicy)
    (expectedRefused [] (.policy (.duplicateParticipant 0 2 .alice)))),
  ("atomic.admission.participant.peer", checkExpected
    (run [draw 7] [repay 7] [] basePolicy peerBoundary)
    (expectedRefused [] (.policy (.uncoveredParticipant .right 0 .bob)))),
  ("atomic.admission.participant.suffix", checkExpected
    (run [draw 11, draw 0] [] [] basePolicy laterBoundary)
    (expectedRefused [] (.policy (.uncoveredParticipant .left 1 .bob)))),
  ("atomic.admission.schedule.missing", checkExpected (run [draw 7] [repay 7] [.left])
    (expectedRefused [.left] (.schedule ⟨1, 1, 1, 0⟩))),
  ("atomic.admission.schedule.excess", checkExpected (run [] [] [.right])
    (expectedRefused [.right] (.schedule ⟨0, 0, 0, 1⟩))),
  ("atomic.admission.extra.participant", checkExpected
    (run drawReturnLeft [] [.left, .left] multiParticipantPolicy)
    (expectedCommit [.left, .left] atomInitial (inners .left drawReturnEvents))) ]

def baselineObservation : O := expectedCommit [.left] afterDraw (inners .left [drawEvent])
def baselineInner : Inner := expectedInner .left drawEvent
def differentObservation (changed : O) : Bool := !observationEq baselineObservation changed
def changedInner (f : Inner → Inner) : O :=
  { baselineObservation with events := [⟨42, [.left], [f baselineInner]⟩] }
def changedOutput (output : OutputObservation A) : Bool :=
  differentObservation (changedInner fun e ↦ {e with outputs := [output]})
def abortObservation (reason : AbortReason P A D) : O :=
  expectedAbort [.left, .right, .left, .left] reason
def abortDifference (reason : AbortReason P A D) : Bool :=
  !observationEq (abortObservation abortMiddle) (abortObservation reason)
def residualObservation (entries : List (Residual P A D)) : O :=
  expectedAbort [.left, .right] (.unsettled entries)
def residualDifference (entries : List (Residual P A D)) : Bool :=
  !observationEq (residualObservation peerResiduals) (residualObservation entries)
def supplyObservation (reason : AbortReason P A D) : O := expectedAbort [.left] reason
def supplyDifference (reason : AbortReason P A D) : Bool :=
  !observationEq (supplyObservation (.laneSupply .left 0 0 mintUSD usdLane 3))
    (supplyObservation reason)

def observationChecks : List (String × Bool) := [
  ("atomic.observe.equal", observationEq baselineObservation
    ⟨42, [.left], .committed, atomWorld 8 7 3 8 10 8 10,
      [⟨42, [.left], [⟨.left, 0, draw 7,
        (Parallel.Examples.transferEvent 0 (draw 7) usdVault usdAlice 7
          [output 0 100 .usd 3]).receipt, [output 0 100 .usd 3]⟩]⟩], fun _ _ ↦ 0⟩),
  ("atomic.observe.kind", differentObservation {baselineObservation with
    outcome := .aborted (.unsettled drawResiduals)}),
  ("atomic.observe.label", differentObservation {baselineObservation with label := 43}),
  ("atomic.observe.schedule", differentObservation {baselineObservation with schedule := [.right]}),
  ("atomic.observe.world", differentObservation {baselineObservation with world := atomInitial}),
  ("atomic.observe.store", differentObservation {baselineObservation with
    world := {afterDraw with capabilities := revokedStore}}),
  ("atomic.observe.supply", differentObservation {baselineObservation with supply := shareSupply}),
  ("atomic.observe.events", differentObservation {baselineObservation with events := []}),
  ("atomic.observe.event.label", differentObservation {baselineObservation with
    events := [⟨43, [.left], [baselineInner]⟩]}),
  ("atomic.observe.event.schedule", differentObservation {baselineObservation with
    events := [⟨42, [.right], [baselineInner]⟩]}),
  ("atomic.observe.event.inner", differentObservation {baselineObservation with
    events := [⟨42, [.left], []⟩]}),
  ("atomic.observe.inner.branch",
    differentObservation (changedInner fun e ↦ {e with branch := .right})),
  ("atomic.observe.inner.index", differentObservation (changedInner fun e ↦ {e with index := 1})),
  ("atomic.observe.inner.invocation", differentObservation
    (changedInner fun e ↦ {e with invocation := draw 8})),
  ("atomic.observe.inner.outputs",
    differentObservation (changedInner fun e ↦ {e with outputs := []})),
  ("atomic.observe.output.index", changedOutput (output 1 100 .usd 3)),
  ("atomic.observe.output.component", changedOutput (output 0 101 .usd 3)),
  ("atomic.observe.output.port", changedOutput ⟨0, ⟨⟨100⟩, ⟨1⟩⟩, ⟨.amount .usd, 3⟩⟩),
  ("atomic.observe.output.asset", changedOutput (output 0 100 .share 3)),
  ("atomic.observe.output.amount", changedOutput (output 0 100 .usd 4)),
  ("atomic.observe.abort.equal", observationEq (abortObservation abortMiddle)
    (expectedAbort [.left, .right, .left, .left]
      (.kernel .left 1 2 (draw 6) (.kernel .insufficientFunds)))),
  ("atomic.observe.abort.reason", abortDifference (.kernel .left 1 2 (draw 6) (.kernel .guard))),
  ("atomic.observe.abort.branch", abortDifference
    (.kernel .right 1 2 (draw 6) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.index", abortDifference
    (.kernel .left 0 2 (draw 6) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.position", abortDifference
    (.kernel .left 1 1 (draw 6) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.invocation", abortDifference
    (.kernel .left 1 2 (draw 7) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.label", !observationEq (abortObservation abortMiddle)
    {abortObservation abortMiddle with label := 43}),
  ("atomic.observe.abort.schedule", !observationEq (abortObservation abortMiddle)
    {abortObservation abortMiddle with schedule := [.left]}),
  ("atomic.observe.residual.equal", observationEq (residualObservation peerResiduals)
    (residualObservation [⟨usdLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩])),
  ("atomic.observe.residual.amount", residualDifference
    [⟨usdLane, .alice, 8⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.principal", residualDifference
    [⟨usdLane, .vault, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.asset", residualDifference
    [⟨shareLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.domain", residualDifference
    [⟨otherLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.vault", residualDifference
    [⟨⟨.main, .usd, .pool⟩, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.order", residualDifference
    [⟨usdLane, .bob, -7⟩, ⟨usdLane, .alice, 7⟩]),
  ("atomic.observe.residual.omitted", residualDifference [⟨usdLane, .alice, 7⟩]),
  ("atomic.observe.supply.abort.amount",
    supplyDifference (.laneSupply .left 0 0 mintUSD usdLane 4)),
  ("atomic.observe.supply.abort.lane",
    supplyDifference (.laneSupply .left 0 0 mintUSD shareLane 3)),
  ("atomic.observe.supply.abort.branch",
    supplyDifference (.laneSupply .right 0 0 mintUSD usdLane 3)),
  ("atomic.observe.supply.abort.index", supplyDifference (.laneSupply .left 1 0 mintUSD usdLane 3)),
  ("atomic.observe.supply.abort.position",
    supplyDifference (.laneSupply .left 0 1 mintUSD usdLane 3)),
  ("atomic.observe.supply.abort.invocation", supplyDifference
    (.laneSupply .left 0 0 mintShare usdLane 3)),
  ("atomic.observe.admission.reason", !observationEq (expectedRefused [] .configuration)
    (expectedRefused [] (.policy (.duplicateParticipant 0 1 .alice)))),
  ("atomic.observe.admission.label", !observationEq (expectedRefused [] .configuration)
    {expectedRefused [] .configuration with label := 43}),
  ("atomic.observe.admission.schedule", !observationEq (expectedRefused [] .configuration)
    (expectedRefused [.left] .configuration)),
  ("atomic.observe.diagnostic.erased", observationsEqual
    (.aborted 42 [.left] abortFirst (Atomic.start atomInitial))
    (.aborted 42 [.left] abortFirst
      {Atomic.start atomInitial with speculative := Interleaving.start afterDraw})) ]

def receiptRequest : Request P A D := ⟨⟨100⟩, [], [⟨.amount .usd, 7⟩], atomCaps, none⟩
def receiptEvaluated := Parallel.Examples.evaluatedTransfer usdVault usdAlice 7

def requestChanges : List (String × Request P A D) := [
  ("operation", {receiptRequest with operation := ⟨101⟩}),
  ("parties", {receiptRequest with parties := [.bob]}),
  ("arguments", {receiptRequest with arguments := [⟨.amount .usd, 8⟩]}),
  ("capabilities", {receiptRequest with capabilityIds := []}),
  ("actor", {receiptRequest with claimedActor := some .bob}) ]
def evaluatedChanges : List (String × Evaluated P A D) := [
  ("guard", {receiptEvaluated with guard := false}),
  ("deltas", {receiptEvaluated with deltas := [(usdVault, -6), (usdAlice, 6)]}),
  ("supply", {receiptEvaluated with supplies := [((.main, .usd), 1)]}),
  ("required.state", {receiptEvaluated with requiredStateReads := [usdAlice]}),
  ("required.environment", {receiptEvaluated with requiredEnvReads := [.currentTime]}),
  ("declared.state", {receiptEvaluated with declaredStateReads := [usdAlice]}),
  ("declared.environment", {receiptEvaluated with declaredEnvReads := [.currentTime]}),
  ("writes", {receiptEvaluated with writes := [usdVault]}) ]
def receiptChecks : List (String × Bool) :=
  requestChanges.map (fun (name, request) ↦ ("atomic.observe.request." ++ name,
    differentObservation (changedInner fun e ↦
      {e with receipt := .invoked request receiptEvaluated}))) ++
  evaluatedChanges.map (fun (name, evaluated) ↦ ("atomic.observe.receipt." ++ name,
    differentObservation (changedInner fun e ↦
      {e with receipt := .invoked receiptRequest evaluated}))) ++
  [("atomic.observe.receipt.constructor", differentObservation
    (changedInner fun e ↦ {e with receipt := .revoked ⟨0⟩}))]

def afterDrawLaneMint := atomWorld 11 7 3 8 10 8 10
def laneMintAfterDrawEvent := mintEvent 1 mintUSD usdAlice 3 11
def laneMintAfterDraw := run [draw 7, mintUSD, repay 7] [noop]
  [.left, .left, .right, .left]
def fundedWorld : W := ⟨⟨Parallel.Examples.balanceTable 2 8 20 0 16 5, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩
def snapshotWorld : W := ⟨⟨Parallel.Examples.balanceTable 2 8 20 0, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩

def extendedChecks : List (String × Bool) := [
  ("atomic.fixture.settlement.over.diagnostic", diagnosticMatches overReturn
    2 2 afterOver overResiduals (inners .left overEvents)),
  ("atomic.fixture.settlement.cross.asset.table", diagnosticMatches assetReturn
    2 2 afterAssetReturn assetResiduals [expectedInner .left drawEvent,
      expectedInner .right (expectedTransfer 0 (repayShare 7) shareAlice shareVault 7 17)]),
  ("atomic.fixture.settlement.cross.domain.table", diagnosticMatches domainReturn
    2 2 afterDomainReturn domainResiduals [expectedInner .left drawEvent,
      expectedInner .right (expectedTransfer 0 (repayOther 7) otherAlice otherVault 7 17)]),
  ("atomic.fixture.settlement.last.lane.table", diagnosticMatches
    (run [drawShare 1] [] [.left] multiLanePolicy) 1 1 afterLastLane lastLaneResiduals
    (inners .left lastLaneEvents)),
  ("atomic.fixture.settlement.last.participant.table", diagnosticMatches
    (run [] [draw 7] [.right] multiParticipantPolicy peerBoundary)
    1 1 afterLastParticipant lastParticipantResiduals (inners .right lastParticipantEvents)),
  ("atomic.fixture.supply.lane.after.draw", checkExpected laneMintAfterDraw
    (expectedAbort [.left, .left, .right, .left]
      (.laneSupply .left 1 1 mintUSD usdLane 3))),
  ("atomic.fixture.supply.lane.after.draw.table", diagnosticMatches laneMintAfterDraw
    2 2 afterDrawLaneMint drawResiduals (inners .left [drawEvent, laneMintAfterDrawEvent])),
  ("atomic.fixture.history.funded.literal", checkExpected
    (oldRun Parallel.Examples.sameAssetCfg Parallel.Examples.boundaries Parallel.Examples.initial
      [Parallel.Examples.usd 3, Parallel.Examples.usd 5] [Parallel.Examples.peerUSD 4]
      [.left, .right, .left])
    (expectedCommit [.left, .right, .left] fundedWorld [
      expectedInner .left (Parallel.Examples.leftEvent 0 3 3),
      expectedInner .right (Parallel.Examples.peerEvent 0 4 5),
      expectedInner .left (Parallel.Examples.leftEvent 1 5 8)])),
  ("atomic.fixture.history.both.own", checkExpected
    (oldRun Interleaving.Examples.snapshotCfg Parallel.Examples.boundaries Parallel.Examples.initial
      [Parallel.Examples.usd 2, Interleaving.Examples.snapshotConsumer]
      [Parallel.Examples.usd 1, Interleaving.Examples.snapshotConsumer]
      [.left, .right, .left, .right])
    (expectedCommit [.left, .right, .left, .right] snapshotWorld [
      expectedInner .left (Parallel.Examples.leftEvent 0 2 2),
      expectedInner .right (Parallel.Examples.leftEvent 0 1 3),
      expectedInner .left (Parallel.Examples.transferEvent 1 Interleaving.Examples.snapshotConsumer
        Parallel.Examples.aliceUSD Parallel.Examples.bobUSD 2 [output 1 0 .usd 5]),
      expectedInner .right (Parallel.Examples.transferEvent 1 Interleaving.Examples.snapshotConsumer
        Parallel.Examples.aliceUSD Parallel.Examples.bobUSD 3 [output 1 0 .usd 8])])) ]

/-- Public-world chaining starts a fresh history even after a speculative USD snapshot. -/
def abortedProducer := run [mintUSD, draw 11] [] [.left, .left] batchPolicy
def abortedSnapshotConsumer : I :=
  { draw 4 with inputs := [.priorOutput 0 ⟨⟨108⟩, ⟨0⟩⟩] }
def followup := run [noop, abortedSnapshotConsumer] [] [.left, .left]
  batchPolicy atomBoundary abortedProducer.publicWorld
def followupFunded := run [noop, draw 4] [] [.left, .left]
  batchPolicy atomBoundary abortedProducer.publicWorld
def initialNoOpEvent : Evt := event 0 noop [⟨.amount .usd, 0⟩]
  ⟨true, [], [], [], [], [], [], []⟩ [output 0 106 .usd 10]
def followupChecks : List (String × Bool) := [
  ("atomic.fixture.followup.producer.aborted", checkExpected abortedProducer
    (expectedAbort [.left, .left]
      (.kernel .left 1 1 (draw 11) (.kernel .insufficientFunds)))),
  ("atomic.fixture.followup.producer.diagnostic", diagnosticMatches abortedProducer
    2 2 afterLaneMint [] (inners .left [laneMintEvent])),
  ("atomic.fixture.followup.fresh.history", checkExpected followup
    (expectedAbort [.left, .left]
      (.kernel .left 1 1 abortedSnapshotConsumer (.interface .unavailableOutput)))),
  ("atomic.fixture.followup.funded.literal", checkExpected followupFunded
    (expectedCommit [.left, .left] (atomWorld 5 7 6 8 10 8 10)
      (inners .left [initialNoOpEvent, expectedTransfer 1 (draw 4) usdVault usdAlice 4 6]))) ]

def runtimeChecks : List (String × Bool) :=
  settlementChecks ++ historyChecks ++ admissionChecks ++ observationChecks ++
    receiptChecks ++ extendedChecks ++ followupChecks

-- BEGIN PROOFS

end DefiKernel.Atomic.Tests
