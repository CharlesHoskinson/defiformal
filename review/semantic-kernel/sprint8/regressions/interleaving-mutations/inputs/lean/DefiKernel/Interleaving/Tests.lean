import DefiKernel.Interleaving.Examples
import DefiKernel.Parallel.ObservationTests

/-! Named finite comparisons use direct complete expectations. They are bounded evidence. -/
namespace DefiKernel.Interleaving.Tests
open Typed Composition Parallel Typed.Examples Parallel.Examples Interleaving.Examples
private def expected (actual : Interleaving.Result Party Asset Domain) (balance : C → ℚ)
    (left right : Obs) (lc rc : Nat) (s : Store := store) : Bool :=
  Interleaving.Examples.matchesExpected actual balance left right lc rc s

def observationEvent : Event Party Asset Domain := Parallel.ObservationTests.event
def observationMachine : M := ⟨initial,
  ⟨1, [observationEvent], observationEvent.result.outputs, 1, none⟩, {}, []⟩
def comparison (m : M) : Interleaving.Result Party Asset Domain := .executed [.left] m
def changedLeft (f : LocalState Party Asset Domain → LocalState Party Asset Domain) : M :=
  { observationMachine with left := f observationMachine.left }
def changedEvent (f : Event Party Asset Domain → Event Party Asset Domain) : M :=
  changedLeft fun l ↦ { l with events := [f observationEvent] }
def different (m : M) := !Interleaving.observationsEqual
  (comparison observationMachine) (comparison m)
def withFailure (n : Nat) (inv : I) (reason : Composition.Failure) :=
  changedLeft fun l ↦ {l with failure := failure n inv reason}
def compareFailures (n : Nat) (inv : I) (reason : Composition.Failure) :=
  !Interleaving.observationsEqual (comparison (withFailure 1 (usd 2) (.kernel .guard)))
    (comparison (withFailure n inv reason))
def changeOutput (out : OutputObservation Asset) :=
  different (changedEvent fun e ↦ {e with result := {e.result with outputs := [out]}})

def requestChanges : List (String × Request Party Asset Domain) := [
  ("operation", { Parallel.ObservationTests.request with operation := ⟨99⟩ }),
  ("parties", { Parallel.ObservationTests.request with parties := [.vault] }),
  ("arguments", { Parallel.ObservationTests.request with arguments := [⟨.amount .usd, 4⟩] }),
  ("capabilities", { Parallel.ObservationTests.request with capabilityIds := [] }),
  ("actor", { Parallel.ObservationTests.request with claimedActor := some .bob })]

def observationChecks : List (String × Bool) := [
  ("interleaving.observe.equal", Interleaving.observationsEqual
    (comparison observationMachine) (comparison observationMachine)),
  ("interleaving.observe.failure", different (withFailure 1 (usd 2) (.kernel .guard))),
  ("interleaving.observe.failure.reason", compareFailures 1 (usd 2) (.kernel .insufficientFunds)),
  ("interleaving.observe.failure.index", compareFailures 2 (usd 2) (.kernel .guard)),
  ("interleaving.observe.failure.step", compareFailures 1 (usd 3) (.kernel .guard)),
  ("interleaving.observe.failure.equal", !compareFailures 1 (usd 2) (.kernel .guard)),
  ("interleaving.observe.successful.index", different
    (changedLeft fun l ↦ {l with nextIndex := 2})),
  ("interleaving.observe.history", different (changedLeft fun l ↦ {l with outputs := []})),
  ("interleaving.observe.events", different (changedLeft fun l ↦ {l with events := []})),
  ("interleaving.observe.peer",
    different {observationMachine with right := observationMachine.left}),
  ("interleaving.observe.event.index", different (changedEvent fun e ↦ {e with index := 2})),
  ("interleaving.observe.event.step", different
    (changedEvent fun e ↦ {e with step := .invoke (usd 9)})),
  ("interleaving.observe.event.outputs", different (changedEvent fun e ↦
    {e with result := {e.result with outputs := []}})),
  ("interleaving.observe.output.unit", changeOutput ⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .share, 7⟩⟩),
  ("interleaving.observe.output.value", changeOutput ⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 8⟩⟩),
  ("interleaving.observe.output.producer", changeOutput ⟨2, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩),
  ("interleaving.observe.output.component", changeOutput ⟨0, ⟨⟨2⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩),
  ("interleaving.observe.output.port", changeOutput ⟨0, ⟨⟨0⟩, ⟨3⟩⟩, ⟨.amount .usd, 7⟩⟩),
  ("interleaving.observe.ledger", different {observationMachine with world := sharedInitial}),
  ("interleaving.observe.store", different {observationMachine with world := revokedInitial}),
  ("interleaving.observe.omitted.context", let altered := changedEvent fun e ↦
      { e with before := sharedInitial, result := { e.result with world := sharedInitial } }
    Interleaving.observationsEqual (comparison observationMachine)
      (.executed [.right] { altered with left := { altered.left with consumed := 9 } }))] ++
  Parallel.ObservationTests.receiptChanges.map fun (label, receipt) ↦
    ("interleaving.observe.receipt." ++ label.replace "-" ".",
      different (changedEvent fun e ↦ {e with result := {e.result with receipt}}))

def requestChecks : List (String × Bool) := requestChanges.map fun (label, request) ↦
  ("interleaving.observe.request." ++ label,
    different (changedEvent fun e ↦ { e with result :=
      { e.result with receipt := .invoked request Parallel.ObservationTests.evaluated } }))

def checks : List (String × Bool) := [
  ("interleaving.fixture.snapshot.both.own", expected
    (runInterleaving snapshotCfg boundaries initial [usd 2, snapshotConsumer]
      [usd 1, snapshotConsumer] [.left, .right, .left, .right])
    (balanceTable 2 8 20 0)
    (observed [leftEvent 0 2 2,
      transferEvent 1 snapshotConsumer aliceUSD bobUSD 2 [output 1 0 .usd 5]])
    (observed [leftEvent 0 1 3,
      transferEvent 1 snapshotConsumer aliceUSD bobUSD 3 [output 1 0 .usd 8]]) 2 2),
  ("interleaving.fixture.shared.lr", expected sharedLR (sharedBalance 7 0 3) withdrawalLeft
    (observed [] (failure 0 (peerUSD 6) (.kernel .insufficientFunds))) 1 1),
  ("interleaving.fixture.shared.rl", expected sharedRL (sharedBalance 0 6 4)
    (observed [] (failure 0 (usd 7) (.kernel .insufficientFunds))) withdrawalRight 1 1),
  ("interleaving.fixture.shared.order", !Interleaving.observationsEqual sharedLR sharedRL),
  ("interleaving.fixture.shared.attempts", attemptsMatch sharedLR sharedLRAttempts),
  ("interleaving.fixture.replenish.funded", expected replenishLR (sharedBalance 3 7 0)
    depositExpected (observed [
      transferEvent 0 (peerUSD 6) vaultUSD bobUSD 6 [output 0 1 .usd 6],
      transferEvent 1 (peerUSD 1) vaultUSD bobUSD 1 [output 1 1 .usd 7]]) 1 2),
  ("interleaving.fixture.replenish.halted", expected replenishRL (sharedBalance 3 0 7)
    depositExpected (observed [] (failure 0 (peerUSD 6) (.kernel .insufficientFunds))) 1 2),
  ("interleaving.fixture.replenish.attempts", attemptsMatch replenishRL replenishRLAttempts),
  ("interleaving.fixture.live.complete", expected liveRun
    (balanceTable (9 / 2) (19 / 2) 20 0 16 1) liveLeft liveRight 2 1),
  ("interleaving.fixture.snapshot.own", expected snapshotRun (balanceTable 3 7 20 0)
    snapshotLeft snapshotRight 2 1),
  ("interleaving.fixture.snapshot.distinct", match snapshotRun with
    | .refused _ _ _ => false
    | .executed _ m => decide (m.left.outputs.head? = some (output 0 0 .usd 3) ∧
        m.right.outputs.head? = some (output 0 0 .usd 4))),
  ("interleaving.fixture.history.peer.only", expected peerOnlyRun
    (balanceTable 7 3 20 0 16 5) peerOnlyLeft peerOnlyRight 2 1),
  ("interleaving.fixture.history.funded.literal", expected
    (runInterleaving sameAssetCfg boundaries initial [usd 3, usd 5] [peerUSD 4]
      [.left, .right, .left]) (balanceTable 2 8 20 0 16 5)
    (observed [leftEvent 0 3 3, leftEvent 1 5 8]) peerOnlyRight 2 1),
  ("interleaving.fixture.history.own", expected
    (runInterleaving sameAssetCfg boundaries initial [usd 3, snapshotConsumer] [peerUSD 4]
      [.left, .right, .left]) (balanceTable 4 6 20 0 16 5)
    (observed [leftEvent 0 3 3,
      transferEvent 1 snapshotConsumer aliceUSD bobUSD 3 [output 1 0 .usd 6]]) peerOnlyRight 2 1),
  ("interleaving.fixture.refusal.immediate", expected immediateRun (balanceTable 10 0 14 6)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) continuedRight 2 2),
  ("interleaving.fixture.refusal.middle", expected middleRun (balanceTable 7 3 14 6)
    middleLeft continuedRight 3 2),
  ("interleaving.fixture.refusal.dual", expected dualRun (balanceTable 7 3 16 4)
    middleLeft (observed [rightEvent 0 4 4]
      (failure 1 (shares 17) (.kernel .insufficientFunds))) 3 3),
  ("interleaving.fixture.refusal.skips", match immediateRun, middleRun, dualRun with
    | .executed _ i, .executed _ m, .executed _ d =>
      decide (i.attempts.length = 3 ∧ m.attempts.length = 4 ∧ d.attempts.length = 4)
    | _, _, _ => false),
  ("interleaving.fixture.empty.both", expected
    (runInterleaving cfg boundaries initial [] [] []) (balanceTable 10 0 20 0)
    (observed []) (observed []) 0 0),
  ("interleaving.fixture.empty.left", expected
    (runInterleaving cfg boundaries initial [] [shares 4] [.right]) (balanceTable 10 0 16 4)
    (observed []) basicRight 0 1),
  ("interleaving.fixture.empty.right", expected
    (runInterleaving cfg boundaries initial [usd 3] [] [.left]) (balanceTable 7 3 20 0)
    basicLeft (observed []) 1 0),
  ("interleaving.fixture.supply.complete", expected supplyRun (balanceTable 12 0 17 0)
    supplyLeft supplyRight 3 1),
  ("interleaving.fixture.supply.aggregate", match supplyRun with
    | .refused _ _ _ => false
    | .executed _ m => decide (∀ d a, m.supply d a =
        if d = .main ∧ a = .usd then 2 else if d = .main ∧ a = .share then -3 else 0)),
  ("interleaving.fixture.collateral.protected", match sharedLR, liveRun, supplyRun with
    | .executed _ a, .executed _ b, .executed _ c => decide
      (a.world.state.balance protectedCell = 9 ∧ b.world.state.balance protectedCell = 9 ∧
        c.world.state.balance protectedCell = 9)
    | _, _, _ => false),
  ("interleaving.fixture.boundary.local", expected
    (runInterleaving timedCfg timedBoundaries initial timedLeft timedRight
      [.right, .left, .left, .right]) (balanceTable 8 2 14 6)
    timedExpectedLeft timedExpectedRight 2 2),
  ("interleaving.fixture.capability.revoked", expected
    (runInterleaving cfg boundaries revokedInitial [usd 3] [shares 4] [.right, .left])
    (balanceTable 7 3 20 0) basicLeft
    (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) 1 1 revokedStore),
  ("interleaving.fixture.capability.live", expected
    (runInterleaving cfg boundaries initial [usd 3] [shares 4] [.right, .left])
    (balanceTable 7 3 16 4) basicLeft basicRight 1 1),
  ("interleaving.fixture.capability.unauthorized", let missing := {usd 3 with capabilityIds := []}
    expected (runInterleaving cfg boundaries initial [missing] [shares 4] [.left, .right])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 missing (.kernel .unauthorizedInvoke))) basicRight 1 1),
  ("interleaving.fixture.capability.debit", let missing := {usd 3 with capabilityIds := [⟨0⟩]}
    expected (runInterleaving cfg boundaries initial [missing] [shares 4] [.left, .right])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 missing (.kernel .unauthorizedDebit))) basicRight 1 1),
  ("interleaving.fixture.history.unit", let wrong :=
      {usd 3 with inputs := [.literal ⟨.amount .share, 3⟩]}
    expected (runInterleaving cfg boundaries initial [wrong] [shares 4] [.right, .left])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 wrong (.interface .inputUnit))) basicRight 1 1),
  ("interleaving.fixture.malformed.suffix", let bad := {usd 1 with operation := ⟨99⟩}
    Interleaving.Examples.admissionRefused
      (runInterleaving cfg boundaries initial [usd 11, bad] [shares 4] [.left, .right, .left])
      (.structural .left ⟨1, .interface .unknownOperation⟩) [.left, .right, .left]),
  ("interleaving.fixture.malformed.schedule", Interleaving.Examples.admissionRefused
    (runInterleaving cfg boundaries initial [usd 3] [shares 4] [.left])
    (.schedule ⟨1, 1, 1, 0⟩) [.left])
  ] ++ schedules.flatMap (fun (label, schedule) ↦
    let actual := runInterleaving cfg boundaries initial disjointLeft disjointRight schedule
    let refused := runInterleaving cfg boundaries initial [usd 3, usd 8] disjointRight schedule
    [("interleaving.fixture.disjoint." ++ label ++ ".complete", expected actual
        (balanceTable 5 5 14 6) disjointLeftExpected continuedRight 2 2),
     ("interleaving.fixture.disjoint." ++ label ++ ".parallel", matchesParallel actual
        (runParallel cfg boundaries initial disjointLeft disjointRight)),
     ("interleaving.fixture.disjoint." ++ label ++ ".refused.complete", expected refused
        (balanceTable 7 3 14 6) middleLeft continuedRight 2 2),
     ("interleaving.fixture.disjoint." ++ label ++ ".refused.parallel", matchesParallel refused
        (runParallel cfg boundaries initial [usd 3, usd 8] disjointRight))]) ++
  observationChecks ++ requestChecks

end DefiKernel.Interleaving.Tests
