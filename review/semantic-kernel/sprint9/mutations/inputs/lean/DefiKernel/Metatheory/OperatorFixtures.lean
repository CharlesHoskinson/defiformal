import DefiKernel.Metatheory.Examples
import DefiKernel.Atomic.Observation

/-! Nonempty old/new configuration executions through the actual existing operators.
Independent full raw cursors and attempts supplement each production public observation. -/
namespace DefiKernel.Metatheory.OperatorFixtures
open Typed Composition Typed.Examples Examples
open Parallel (BranchId)
open Parallel.Examples (output)

abbrev B := Parallel.Branch P A D
abbrev IM := Interleaving.Machine P A D
def boundary (_ : BranchId) : Nat → Boundary P A D := constantBoundary
def unknown : Inv := { draw7 with component := ⟨88⟩, operation := ⟨88⟩ }
def badSuffix : B := [movement 11 .bob, unknown]
def stepResultMatches (a b : StepResult P A D) : Bool :=
  worldMatches a.world b.world && decide (a.receipt = b.receipt ∧ a.outputs = b.outputs)
def outcomeMatches (a b : Except Composition.Failure (StepResult P A D)) : Bool :=
  match a, b with
  | .ok x, .ok y => stepResultMatches x y
  | .error x, .error y => decide (x = y)
  | _, _ => false
def attemptMatches (a b : Interleaving.Attempt P A D) : Bool :=
  decide (a.branch = b.branch ∧ a.index = b.index ∧ a.invocation = b.invocation) &&
    worldMatches a.before b.before && outcomeMatches a.outcome b.outcome
def localMatches (a b : Interleaving.LocalState P A D) (w : W) : Bool :=
  decide (a.consumed = b.consumed) &&
    fullCursorEq (a.toCursor w) (b.toCursor w)
def machineMatches (a b : IM) : Bool :=
  worldMatches a.world b.world && localMatches a.left b.left a.world &&
    localMatches a.right b.right a.world && decide (a.attempts.length = b.attempts.length) &&
    (a.attempts.zip b.attempts).all (fun (x, y) ↦ attemptMatches x y)
def firstAttempt : Interleaving.Attempt P A D :=
  ⟨.left, 0, draw7, world 10 0 0, .ok firstEvent.result⟩
def firstMachine : IM := ⟨world 3 7 0,
  ⟨1, [firstEvent], [output 0 0 .usd 3], 1, none⟩, {}, [firstAttempt]⟩
def failureMachine : IM := ⟨world 3 7 0,
  ⟨2, [firstEvent], [output 0 0 .usd 3], 1, middleRefusal.failure⟩, {},
  [firstAttempt, ⟨.left, 1, refuse6, world 3 7 0, .error (.kernel .insufficientFunds)⟩]⟩
def parallelMatches (actual : Parallel.Result P A D) (w : W) (left right : Cur) : Bool :=
  match actual with
  | .refused _ _ => false
  | .executed joined => worldMatches joined.world w && fullCursorEq joined.left left &&
      fullCursorEq joined.right right
def parallelRefused (actual : Parallel.Result P A D) : Bool :=
  match actual with
  | .refused reason w => worldMatches w initial.world &&
      decide (reason = .structural .left ⟨1, .interface .unknownOperation⟩)
  | _ => false
def interMatches (actual : Interleaving.Result P A D) (schedule : Interleaving.Schedule)
    (expected : IM) : Bool :=
  match actual with
  | .executed actualSchedule m => decide (actualSchedule = schedule) && machineMatches m expected
  | _ => false
def interRefused (actual : Interleaving.Result P A D) : Bool :=
  match actual with
  | .refused reason w schedule => worldMatches w initial.world &&
      decide (schedule = [.left, .left] ∧
        reason = .structural .left ⟨1, .interface .unknownOperation⟩)
  | _ => false

def batchPolicy : Atomic.Policy P A D := ⟨[], [.alice]⟩
def zero : D → A → ℚ := fun _ _ ↦ 0
def firstInner : Atomic.InnerObservation P A D :=
  ⟨.left, 0, draw7, firstEvent.result.receipt, [output 0 0 .usd 3]⟩
def batchObservation : Atomic.Observation P A D :=
  ⟨73, [.left], .committed, world 3 7 0, [⟨73, [.left], [firstInner]⟩], zero⟩
def batchAbortReason : Atomic.AbortReason P A D :=
  .kernel .left 1 1 refuse6 (.kernel .insufficientFunds)
def batchAbortObservation : Atomic.Observation P A D :=
  ⟨73, [.left, .left], .aborted batchAbortReason, world 10 0 0, [], zero⟩
def batchRefusedObservation : Atomic.Observation P A D :=
  ⟨73, [.left, .left], .refused (.structural .left ⟨1, .interface .unknownOperation⟩),
    world 10 0 0, [], zero⟩
def tableMatches (a : Atomic.Outstanding P A D) (owed : List (Atomic.Residual P A D)) : Bool :=
  decide (∀ d asset vaultParty principal,
    a ⟨d, asset, vaultParty⟩ principal = Atomic.Examples.expectedOutstanding owed
      ⟨d, asset, vaultParty⟩ principal)
def atomicDiagnostics (actual : Atomic.Result P A D) (entry : W) (expected : IM)
    (position : Nat) (abort : Option (Atomic.AbortReason P A D))
    (owed : List (Atomic.Residual P A D)) : Bool :=
  match actual with
  | .refused _ _ _ _ => false
  | .committed _ _ m | .aborted _ _ _ m =>
      worldMatches m.entryWorld entry && machineMatches m.speculative expected &&
        decide (m.position = position ∧ m.abort = abort) && tableMatches m.outstanding owed

def batchRun (config : Config P A D) (left : B) : Atomic.Result P A D :=
  Atomic.runAtomic config boundary 73 batchPolicy initial.world left []
    (left.map (fun _ ↦ BranchId.left))
def atomicMatches (actual : Atomic.Result P A D) (expected : Atomic.Observation P A D) : Bool :=
  Atomic.observationEq (Atomic.observe actual) expected

def extendedAtomic : Config P A D := { Atomic.Examples.atomCfg with
  registry := fun op ↦ if op = ⟨998⟩ then some Parallel.Examples.noOp
    else Atomic.Examples.atomCfg.registry op
  catalog := Atomic.Examples.atomCfg.catalog ++ [⟨⟨998⟩, [], [], [], [⟨⟨998⟩, [], []⟩]⟩] }
/-- Reconstruct raw expected events from predeclared expected receipt data and literal worlds. -/
def raw (e : Parallel.EventObservation P A D) (pre post : W) : RawEvent :=
  ⟨e.index, e.step, pre, ⟨post, e.receipt, e.outputs⟩⟩
def settleDraw : RawEvent := raw Atomic.Examples.drawEvent
  Atomic.Examples.atomInitial Atomic.Examples.afterDraw
def settleReturn (under : Bool) : RawEvent :=
  raw (Atomic.Examples.repayEvent 1 (if under then 6 else 7) (if under then 9 else 10))
    Atomic.Examples.afterDraw
    (if under then Atomic.Examples.afterUnder else Atomic.Examples.atomInitial)
def settleMachine (under : Bool) : IM :=
  let last := settleReturn under
  ⟨last.result.world, ⟨2, [settleDraw, last],
    [output 0 100 .usd 3, output 1 101 .usd (if under then 9 else 10)], 2, none⟩, {},
    [⟨.left, 0, Atomic.Examples.draw 7, Atomic.Examples.atomInitial, .ok settleDraw.result⟩,
      ⟨.left, 1, Atomic.Examples.repay (if under then 6 else 7), Atomic.Examples.afterDraw,
        .ok last.result⟩]⟩
def settleObservation (under : Bool) : Atomic.Observation P A D :=
  if under then
    ⟨74, [.left, .left], .aborted (.unsettled Atomic.Examples.underResiduals),
      Atomic.Examples.atomInitial, [], zero⟩
  else ⟨74, [.left, .left], .committed, Atomic.Examples.atomInitial,
    [⟨74, [.left, .left],
      [⟨.left, 0, Atomic.Examples.draw 7, settleDraw.result.receipt, settleDraw.result.outputs⟩,
        ⟨.left, 1, Atomic.Examples.repay 7, (settleReturn false).result.receipt,
          (settleReturn false).result.outputs⟩]⟩], zero⟩
def settleRun (config : Config P A D) (under : Bool) : Atomic.Result P A D :=
  Atomic.runAtomic config Atomic.Examples.atomBoundary 74 Atomic.Examples.basePolicy
    Atomic.Examples.atomInitial
    [Atomic.Examples.draw 7, Atomic.Examples.repay (if under then 6 else 7)] [] [.left, .left]
def settlementCheck (config : Config P A D) (under : Bool) : Bool :=
  let actual := settleRun config under
  atomicMatches actual (settleObservation under) &&
    atomicDiagnostics actual Atomic.Examples.atomInitial (settleMachine under) 2 none
      (if under then Atomic.Examples.underResiduals else [])

def checks : List (String × Bool) := [
  ("metatheory.operator.parallel.old", parallelMatches
    (Parallel.runParallel cfg boundary initial.world [draw7] []) (world 3 7 0) afterFirst initial),
  ("metatheory.operator.parallel.extended", parallelMatches
    (Parallel.runParallel extendedCfg boundary initial.world [draw7] [])
    (world 3 7 0) afterFirst initial),
  ("metatheory.operator.parallel.failure.old", parallelMatches
    (Parallel.runParallel cfg boundary initial.world [draw7, refuse6] [])
    (world 3 7 0) middleRefusal initial),
  ("metatheory.operator.parallel.failure.extended", parallelMatches
    (Parallel.runParallel extendedCfg boundary initial.world [draw7, refuse6] [])
    (world 3 7 0) middleRefusal initial),
  ("metatheory.operator.parallel.admission.old", parallelRefused
    (Parallel.runParallel cfg boundary initial.world badSuffix [])),
  ("metatheory.operator.parallel.admission.extended", parallelRefused
    (Parallel.runParallel extendedCfg boundary initial.world badSuffix [])),
  ("metatheory.operator.interleaving.old", interMatches
    (Interleaving.runInterleaving cfg boundary initial.world [draw7] [] [.left])
    [.left] firstMachine),
  ("metatheory.operator.interleaving.extended", interMatches
    (Interleaving.runInterleaving extendedCfg boundary initial.world [draw7] [] [.left])
    [.left] firstMachine),
  ("metatheory.operator.interleaving.failure.old", interMatches
    (Interleaving.runInterleaving cfg boundary initial.world [draw7, refuse6] [] [.left, .left])
    [.left, .left] failureMachine),
  ("metatheory.operator.interleaving.failure.extended", interMatches
    (Interleaving.runInterleaving extendedCfg boundary initial.world
      [draw7, refuse6] [] [.left, .left])
    [.left, .left] failureMachine),
  ("metatheory.operator.interleaving.admission.old", interRefused
    (Interleaving.runInterleaving cfg boundary initial.world badSuffix [] [.left, .left])),
  ("metatheory.operator.interleaving.admission.extended", interRefused
    (Interleaving.runInterleaving extendedCfg boundary initial.world badSuffix [] [.left, .left])),
  ("metatheory.operator.atomic.batch.old", atomicMatches (batchRun cfg [draw7]) batchObservation &&
    atomicDiagnostics (batchRun cfg [draw7]) initial.world firstMachine 1 none []),
  ("metatheory.operator.atomic.batch.extended", atomicMatches
    (batchRun extendedCfg [draw7]) batchObservation &&
    atomicDiagnostics (batchRun extendedCfg [draw7]) initial.world firstMachine 1 none []),
  ("metatheory.operator.atomic.kernel.old", atomicMatches
    (batchRun cfg [draw7, refuse6]) batchAbortObservation &&
    atomicDiagnostics (batchRun cfg [draw7, refuse6]) initial.world failureMachine 2
      (some batchAbortReason) []),
  ("metatheory.operator.atomic.kernel.extended", atomicMatches
    (batchRun extendedCfg [draw7, refuse6]) batchAbortObservation &&
    atomicDiagnostics (batchRun extendedCfg [draw7, refuse6]) initial.world failureMachine 2
      (some batchAbortReason) []),
  ("metatheory.operator.atomic.admission.old", atomicMatches
    (batchRun cfg badSuffix) batchRefusedObservation),
  ("metatheory.operator.atomic.admission.extended", atomicMatches
    (batchRun extendedCfg badSuffix) batchRefusedObservation),
  ("metatheory.operator.atomic.settlement.old", settlementCheck Atomic.Examples.atomCfg false),
  ("metatheory.operator.atomic.settlement.extended", settlementCheck extendedAtomic false),
  ("metatheory.operator.atomic.unsettled.old", settlementCheck Atomic.Examples.atomCfg true),
  ("metatheory.operator.atomic.unsettled.extended", settlementCheck extendedAtomic true),
  ("metatheory.operator.atomic.extended.valid", validateCatalog extendedAtomic.registry
    extendedAtomic.catalog)
]


/-- Moving a commit boundary changes which successful prefix remains publicly visible. -/
def splitFirst : Atomic.Result P A D := batchRun cfg [draw7]
def splitSecond : Atomic.Result P A D :=
  Atomic.runAtomic cfg boundary 74 batchPolicy splitFirst.publicWorld [refuse6] [] [.left]
def splitReason : Atomic.AbortReason P A D :=
  .kernel .left 0 0 refuse6 (.kernel .insufficientFunds)
def splitExpected : Atomic.Observation P A D :=
  ⟨74, [.left], .aborted splitReason, world 3 7 0, [], zero⟩
def splitMachine : IM := ⟨world 3 7 0,
  ⟨1, [], [], 0, some ⟨0, some (.invoke refuse6), .kernel .insufficientFunds⟩⟩, {},
  [⟨.left, 0, refuse6, world 3 7 0, .error (.kernel .insufficientFunds)⟩]⟩
def laneMintRaw : RawEvent := raw Atomic.Examples.laneMintEvent
  Atomic.Examples.atomInitial Atomic.Examples.afterLaneMint
def laneMintMachine : IM := ⟨Atomic.Examples.afterLaneMint,
  ⟨1, [laneMintRaw], [output 0 108 .usd 4], 1, none⟩, {},
  [⟨.left, 0, Atomic.Examples.mintUSD, Atomic.Examples.atomInitial, .ok laneMintRaw.result⟩]⟩
def laneMintReason : Atomic.AbortReason P A D :=
  .laneSupply .left 0 0 Atomic.Examples.mintUSD Atomic.Examples.usdLane 3
def laneMintExpected : Atomic.Observation P A D :=
  ⟨75, [.left], .aborted laneMintReason, Atomic.Examples.atomInitial, [], zero⟩
def laneMintCheck (config : Config P A D) : Bool :=
  let actual := Atomic.runAtomic config Atomic.Examples.atomBoundary 75 Atomic.Examples.basePolicy
    Atomic.Examples.atomInitial [Atomic.Examples.mintUSD] [] [.left]
  atomicMatches actual laneMintExpected && atomicDiagnostics actual Atomic.Examples.atomInitial
    laneMintMachine 1 (some laneMintReason) []
def boundaryChecks : List (String × Bool) := [
  ("metatheory.boundary.combined", atomicMatches
    (batchRun cfg [draw7, refuse6]) batchAbortObservation &&
    atomicDiagnostics (batchRun cfg [draw7, refuse6]) initial.world failureMachine 2
      (some batchAbortReason) []),
  ("metatheory.boundary.split.first", atomicMatches splitFirst batchObservation &&
    atomicDiagnostics splitFirst initial.world firstMachine 1 none []),
  ("metatheory.boundary.split.second", atomicMatches splitSecond splitExpected &&
    atomicDiagnostics splitSecond (world 3 7 0) splitMachine 1 (some splitReason) []),
  ("metatheory.boundary.material", !worldMatches
    (batchRun cfg [draw7, refuse6]).publicWorld splitSecond.publicWorld),
  ("metatheory.operator.atomic.supply.old", laneMintCheck Atomic.Examples.atomCfg),
  ("metatheory.operator.atomic.supply.extended", laneMintCheck extendedAtomic)
]

-- BEGIN PROOFS

end DefiKernel.Metatheory.OperatorFixtures
