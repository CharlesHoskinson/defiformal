import DefiKernel.Nary.Schedule
import DefiKernel.Nary.Execution
import DefiKernel.Nary.Observation
import DefiKernel.Nary.CausalRuntime
import DefiKernel.Nary.Examples
import DefiKernel.Interface.Regions
import DefiKernel.Interface.Bindings

/-! Unique nonempty runtime comparisons against independent Examples literals.
Expected values are not taken from `runNary` or a compared runner. -/
namespace DefiKernel.Nary.Tests
open Typed Composition Parallel Interface
open DefiKernel.Nary
open DefiKernel.Nary.Examples

def worldEq {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D] (x y : World P A D) : Bool :=
  decide ((∀ c, x.state.balance c = y.state.balance c) ∧ x.capabilities = y.capabilities)

def resultEq {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D] (x y : StepResult P A D) : Bool :=
  worldEq x.world y.world && decide (x.receipt = y.receipt ∧ x.outputs = y.outputs)

def outcomeEq {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D]
    (x y : Except Composition.Failure (StepResult P A D)) : Bool :=
  match x, y with
  | .error a, .error b => decide (a = b)
  | .ok a, .ok b => resultEq a b
  | _, _ => false

def eventEq {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D] (x y : Event P A D) : Bool :=
  decide (x.index = y.index ∧ x.step = y.step) && worldEq x.before y.before &&
    resultEq x.result y.result

def eventsEq {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D] (xs ys : List (Event P A D)) : Bool :=
  decide (xs.length = ys.length) && (xs.zip ys).all fun (x, y) ↦ eventEq x y

def localEq {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D] (x y : Interleaving.LocalState P A D) : Bool :=
  eventsEq x.events y.events && decide (x.consumed = y.consumed ∧ x.outputs = y.outputs ∧
    x.nextIndex = y.nextIndex ∧ x.failure = y.failure)

def attemptEq {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D] (x y : Attempt B P A D) : Bool :=
  decide (x.participant = y.participant ∧ x.index = y.index ∧ x.invocation = y.invocation) &&
    worldEq x.before y.before && outcomeEq x.outcome y.outcome

def localsEq {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D] (roster : Roster B)
    (x y : B → Interleaving.LocalState P A D) : Bool :=
  roster.order.all fun b ↦ localEq (x b) (y b)

def fullMachineEq {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D] (roster : Roster B)
    (x y : Machine B P A D) : Bool :=
  worldEq x.world y.world && localsEq roster x.locals y.locals &&
    decide (x.attempts.length = y.attempts.length) &&
      (x.attempts.zip y.attempts).all fun (a, b) ↦ attemptEq a b

def cmpMachine {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D] (roster : Roster B)
    (x y : Machine B P A D) : Bool :=
  machineEq roster x y && fullMachineEq roster x y

def executedEq {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D] (roster : Roster B)
    (actual : Result B P A D) (schedule : Schedule B) (expected : Machine B P A D) : Bool :=
  match actual with
  | .executed s m => decide (s = schedule) && cmpMachine roster m expected
  | .refused _ _ _ => false

def refusedEq {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
    [Fintype P] [Fintype A] [Fintype D]
    (actual : Result B P A D) (reason : AdmissionFailure B P A D)
    (world : World P A D) (schedule : Schedule B) : Bool :=
  match actual with
  | .refused r w s => decide (r = reason ∧ s = schedule) && worldEq w world
  | .executed _ _ => false

def run3 (cfg : Config P A D) (bounds : Boundaries (Fin 3) P A D)
    (initial : W) (branches : Branches (Fin 3) P A D) (schedule : Schedule (Fin 3)) :=
  runNary cfg fin3Roster bounds initial branches schedule

def prefix3 (cfg : Config P A D) (bounds : Boundaries (Fin 3) P A D)
    (initial : W) (branches : Branches (Fin 3) P A D) (schedule : Schedule (Fin 3)) :=
  runPrefix cfg bounds initial branches schedule

def monitored3 (update : ReservePhase → MonitorInput (Fin 3) P A D → ReservePhase)
    (entry : ReservePhase) (schedule : Schedule (Fin 3)) :=
  continueMonitored f10Cfg f10Bounds f10Branches update (entry, start f10Initial) schedule

def countMonitored (entry : Nat) (bounds : Boundaries (Fin 3) P A D)
    (initial : W) (_branches : Branches (Fin 3) P A D) (schedule : Schedule (Fin 3)) :=
  continueMonitored fundedCfg bounds fundedBranches countUpdate
    (entry, start initial) schedule

def receiptGuardTrue (m : M3) (b : Fin 3) : Bool :=
  match (m.locals b).events.head? with
  | some e =>
    match e.result.receipt with
    | .invoked _ evaluated => evaluated.guard
    | _ => false
  | none => false

def noFailures (m : M3) : Bool :=
  decide ((m.locals 0).failure.isNone ∧ (m.locals 1).failure.isNone ∧
    (m.locals 2).failure.isNone) &&
    m.attempts.all fun a ↦ match a.outcome with | .ok _ => true | .error _ => false

def distinctLocals (m : M3) : Bool :=
  match (m.locals 0).events.head?, (m.locals 1).events.head?, (m.locals 2).events.head? with
  | some e0, some e1, some e2 =>
    decide (e0.step = .invoke inv10 ∧ e1.step = .invoke inv11 ∧ e2.step = .invoke inv12)
  | _, _, _ => false

def vaultOf (w : W) : ℚ := w.state.balance vaultC
def firstSuccessWorld (m : M3) : Option W :=
  match m.attempts.head? with
  | some ⟨_, _, _, _, .ok result⟩ => some result.world
  | _ => none

def f02Run := run3 fundedCfg fundedBounds f02Initial fundedBranches f02Schedule
def f01ConfigRun :=
  runNary invalidCfg fin3Roster fundedBounds f02Initial f01UnknownBranches f01BothBadSchedule
def f01UnknownRun :=
  runNary fundedCfg fin3Roster fundedBounds f02Initial f01UnknownBranches f01BothBadSchedule
def f01FinalRun :=
  runNary fundedCfg fin3Roster fundedBounds f02Initial f01ValidBranches f01MismatchSchedule
def f03LRRun := runNary fundedCfg binaryRoster f03Bounds f03Initial f03Branches f03LR
def f03RLRun := runNary fundedCfg binaryRoster f03Bounds f03Initial f03Branches f03RL
def f03CountRun :=
  runNary fundedCfg binaryRoster f03Bounds f03Initial f03Branches f03EmptySched
def f03MalformedBranches : Branches BranchId P A D
  | .left => [inv14, inv999]
  | .right => [inv15]
def f03MalformedSchedule : Schedule BranchId := []
def f03MalformedReason : AdmissionFailure BranchId P A D :=
  .structural .left ⟨1, .interface .unknownOperation⟩
def f03MalformedRun :=
  runNary fundedCfg binaryRoster f03Bounds f03Initial f03MalformedBranches
    f03MalformedSchedule
def f03FailedPrefix : Schedule BranchId := [.left, .right, .right]
def f03ExhaustedPrefix : Schedule BranchId := [.left, .right, .left]
def f03FailedPrefixRun :=
  runPrefix fundedCfg f03Bounds f03Initial f03Branches f03FailedPrefix
def f03ExhaustedPrefixRun :=
  runPrefix fundedCfg f03Bounds f03Initial f03Branches f03ExhaustedPrefix
/-- Extra token consumes a slot and appends no attempt. Built from F03 LR literals. -/
def f03FailedPrefixExpected : MB :=
  ⟨f03AfterLeft,
    fun b ↦ match b with
      | .left => localSucc [ev 0 inv14 f03Initial (sr f03AfterLeft rec14)]
      | .right => localFail 2 0 [] [] f03RightFail,
    [⟨.left, 0, inv14, f03Initial, .ok (sr f03AfterLeft rec14)⟩,
      ⟨.right, 0, inv15, f03AfterLeft, .error (.kernel .guard)⟩]⟩
def f03ExhaustedPrefixExpected : MB :=
  ⟨f03AfterLeft,
    fun b ↦ match b with
      | .left => ⟨2, [ev 0 inv14 f03Initial (sr f03AfterLeft rec14)], [], 1, none⟩
      | .right => localFail 1 0 [] [] f03RightFail,
    [⟨.left, 0, inv14, f03Initial, .ok (sr f03AfterLeft rec14)⟩,
      ⟨.right, 0, inv15, f03AfterLeft, .error (.kernel .guard)⟩]⟩
def f03ProjectedCounts :=
  projectScheduleMismatch f03Branches f03EmptySched f03BothCount
def f04EmptyRun :=
  runNary fundedCfg emptyRoster emptyBounds f04Initial emptyBranches emptySchedule
def f04InvalidEmpty :=
  runNary invalidCfg emptyRoster emptyBounds f04Initial emptyBranches emptySchedule
def f04UnitRun :=
  runNary fundedCfg unitRoster unitBounds f04Initial unitBranches unitComplete
def f04MissingRun :=
  runNary fundedCfg unitRoster unitBounds f04Initial unitBranches unitMissing
def f05Run := runNary f05Cfg fin2Roster f05AllBounds f05Initial f05Branches f05Schedule
def f05SharedRun :=
  runNary fundedCfg fin2Roster f05SharedBounds f04Initial f05SharedBranches [0, 1]
def f06Run := run3 fundedCfg f06Bounds f02Initial f06Branches f06Schedule
def f07Run := run3 fundedCfg f07Bounds f07Initial f07Branches f07Schedule
def f08Run := prefix3 fundedCfg f08Bounds f02Initial f08Branches f08Prefix
def f08Count :=
  continueMonitored fundedCfg f08Bounds f08Branches countUpdate (0, start f02Initial) f08Prefix
def f09Run := continueRun f09Cfg f09Bounds f09Branches f09Entry f09Cont
def f09Chunked :=
  continueRun f09Cfg f09Bounds f09Branches
    (continueRun f09Cfg f09Bounds f09Branches f09Entry f09Chunk1) f09Chunk2
def f09Mon :=
  continueMonitored f09Cfg f09Bounds f09Branches countUpdate
    (f09MonitorEntry, f09Entry) f09Cont
def f09MonChunked :=
  continueMonitored f09Cfg f09Bounds f09Branches countUpdate
    (continueMonitored f09Cfg f09Bounds f09Branches countUpdate
      (f09MonitorEntry, f09Entry) f09Chunk1) f09Chunk2
def f10Run (s : List (Fin 3)) := run3 f10Cfg f10Bounds f10Initial f10Branches s
def f10Mon (s : List (Fin 3)) := monitored3 reserveUpdate .awaiting s
def f10Trace (s : List (Fin 3)) :=
  continueMonitored f10Cfg f10Bounds f10Branches observeReserve
    (⟨.awaiting, []⟩, start f10Initial) s
def f11Run := run3 fundedCfg f11Bounds f11Initial f11Branches [0]
def f12Run := run3 f12Cfg f12Bounds f12Initial f12Branches f12Schedule
def f13Run := run3 fundedCfg f13Bounds f13Initial f13Branches [1]
def f14Run := run3 fundedCfg f14Bounds f14Initial f14Branches [0, 1, 2]
def f16Run := run3 f16Cfg f16Bounds f16Initial f16Branches f16Schedule
def f16Mon :=
  continueMonitored f16Cfg f16Bounds f16Branches reserveUpdate (.awaiting, start f16Initial)
    f16Schedule
def f17Run := prefix3 f10Cfg f17Bounds f10Initial f17Branches f17Schedule
def f17Mon :=
  continueMonitored f10Cfg f17Bounds f17Branches reserveUpdate (.awaiting, start f10Initial)
    f17Schedule
def f18Run (s : List (Fin 3)) :=
  runNary f18Cfg f18Roster f18Bounds f18Initial f18Branches s
def f19Run := runNary f18Cfg f18Roster f18Bounds f18Initial f19Branches f19Schedule

def f01Checks : List (String × Bool) := [
  ("nary.f01.ids", decide (fixtureIds.length = 19 ∧ fixtureIds.Nodup)),
  ("nary.f01.class", decide (classification "F01" = .admissionRefusal)),
  ("nary.f01.configuration", refusedEq f01ConfigRun f01ExpectedConfig f02Initial
    f01BothBadSchedule),
  ("nary.admission.suffix_precedence", refusedEq f01UnknownRun f01ExpectedUnknown f02Initial
    f01BothBadSchedule),
  ("nary.schedule.final_participant", refusedEq f01FinalRun f01ExpectedFinal f02Initial
    f01MismatchSchedule),
  ("nary.f01.four-nats", decide (f03FourNats = (1, 0, 1, 0)))]

def f02Checks : List (String × Bool) := [
  ("nary.f02.class", decide (classification "F02" = .fundedExecution)),
  ("nary.f02.complete", executedEq fin3Roster f02Run f02Schedule f02Expected),
  ("nary.world.exact", match f02Run with
    | .executed _ m =>
        decide (vaultOf m.world = 12) &&
          match firstSuccessWorld m with | some w => decide (vaultOf w = 9) | none => false
    | _ => false),
  ("nary.store.exact", match f02Run with
    | .executed _ m => decide (m.world.capabilities = f02Store)
    | _ => false),
  ("nary.routing.locals", match f02Run with
    | .executed _ m => distinctLocals m &&
        decide ((m.locals 0).consumed = 1 ∧ (m.locals 1).consumed = 1 ∧
          (m.locals 2).consumed = 1)
    | _ => false),
  ("nary.success.index", match f02Run with
    | .executed _ m => decide ((m.locals 0).nextIndex = 1 ∧ (m.locals 1).nextIndex = 1 ∧
        (m.locals 2).nextIndex = 1)
    | _ => false),
  ("nary.receipt.evaluated", match f02Run with
    | .executed _ m => receiptGuardTrue m 0
    | _ => false),
  ("nary.no_failure.exact", match f02Run with
    | .executed _ m => noFailures m
    | _ => false),
  ("nary.f02.donors", match f02Run with
    | .executed _ m => decide (m.world.state.balance donor1C = 1 ∧
        m.world.state.balance donor2C = 1 ∧ m.world.state.balance recipientC = 1 ∧
        m.world.state.balance budgetC = 6 ∧ m.world.state.balance sentinelC = 11)
    | _ => false),
  ("nary.f02.attempts", match f02Run with
    | .executed _ m => decide (m.attempts.length = 3) &&
        match m.attempts with
        | a0 :: a1 :: a2 :: [] =>
            decide (a0.participant = 0 ∧ a1.participant = 1 ∧ a2.participant = 2)
        | _ => false
    | _ => false)]

def f03Checks : List (String × Bool) := [
  ("nary.f03.class", decide (classification "F03" = .binaryInstance)),
  ("nary.f03.lr", executedEq binaryRoster f03LRRun f03LR f03LRExpected),
  ("nary.f03.rl", executedEq binaryRoster f03RLRun f03RL f03RLExpected),
  ("nary.f03.lr.vault3", match f03LRRun with
    | .executed _ m => decide (vaultOf m.world = 3)
    | _ => false),
  ("nary.f03.rl.vault4", match f03RLRun with
    | .executed _ m => decide (vaultOf m.world = 4)
    | _ => false),
  ("nary.f03.both-count", refusedEq f03CountRun (.schedule f03BothCount) f03Initial
    f03EmptySched),
  ("nary.f03.independent-counts", decide
    ((f03Branches .left).length = 1 ∧ f03EmptySched.count .left = 0 ∧
      (f03Branches .right).length = 1 ∧ f03EmptySched.count .right = 0)),
  ("nary.f03.both-count-projection",
    decide (f03ProjectedCounts.expectedLeft = 1 ∧
      f03ProjectedCounts.observedLeft = 0 ∧
      f03ProjectedCounts.expectedRight = 1 ∧
      f03ProjectedCounts.observedRight = 0)),
  ("nary.f03.both-count-direct",
    binaryAdmitAgrees fundedCfg f03Bounds f03Branches f03EmptySched),
  ("nary.f03.malformed-suffix",
    refusedEq f03MalformedRun f03MalformedReason f03Initial f03MalformedSchedule),
  ("nary.f03.malformed-suffix-direct",
    binaryAdmitAgrees fundedCfg f03Bounds f03MalformedBranches f03MalformedSchedule),
  ("nary.f03.failed-prefix",
    cmpMachine binaryRoster f03FailedPrefixRun f03FailedPrefixExpected),
  ("nary.f03.failed-prefix-direct",
    binaryPrefixAgrees fundedCfg f03Bounds f03Initial f03Branches f03FailedPrefix),
  ("nary.f03.exhausted-prefix",
    cmpMachine binaryRoster f03ExhaustedPrefixRun f03ExhaustedPrefixExpected),
  ("nary.f03.exhausted-prefix-direct",
    binaryPrefixAgrees fundedCfg f03Bounds f03Initial f03Branches f03ExhaustedPrefix),
  ("nary.f03.lr-direct",
    binaryRunAgrees fundedCfg f03Bounds f03Initial f03Branches f03LR),
  ("nary.f03.rl-direct",
    binaryRunAgrees fundedCfg f03Bounds f03Initial f03Branches f03RL)]

def f04Checks : List (String × Bool) := [
  ("nary.f04.class", decide (classification "F04" = .typedRoster)),
  ("nary.empty.exact", executedEq emptyRoster f04EmptyRun emptySchedule f04EmptyExpected),
  ("nary.f04.invalid-empty", refusedEq f04InvalidEmpty .configuration f04Initial emptySchedule),
  ("nary.f04.singleton", executedEq unitRoster f04UnitRun unitComplete f04Expected),
  ("nary.f04.missing", refusedEq f04MissingRun f04Missing f04Initial unitMissing),
  ("nary.f04.singleton.vault9", match f04UnitRun with
    | .executed _ m => decide (vaultOf m.world = 9)
    | _ => false)]

def f05Checks : List (String × Bool) := [
  ("nary.f05.class", decide (classification "F05" = .fundedExecution)),
  ("nary.f05.catalog-one-producer", decide
    ((f05Catalog.head?.map fun c ↦
      (c.operations.filter fun i ↦ i.operation = ⟨18⟩).length) = some 1)),
  ("nary.history.own_input", executedEq fin2Roster f05Run f05Schedule f05Expected),
  ("nary.f05.final", match f05Run with
    | .executed _ m => decide (vaultOf m.world = 2 ∧ m.world.state.balance budgetC = 2 ∧
        m.world.state.balance donor0C = 0 ∧ m.world.state.balance donor1C = 4 ∧
        m.world.state.balance recipientC = 6 ∧ m.world.state.balance recipient1C = 2)
    | _ => false),
  ("nary.f05.outputs-6-2", match f05Run with
    | .executed _ m => decide ((m.locals 0).outputs = [budgetOut 0 6] ∧
        (m.locals 1).outputs = [budgetOut 0 2])
    | _ => false),
  ("nary.f05.shared-principal", executedEq fin2Roster f05SharedRun [0, 1] f05SharedExpected)]

def f06Checks : List (String × Bool) := [
  ("nary.f06.class", decide (classification "F06" = .actualRefusal)),
  ("nary.boundary.index1", match f06Run with
    | .executed _ m =>
        decide ((m.locals 0).failure = some f06Fail) &&
          executedEq fin3Roster f06Run f06Schedule f06Expected
    | _ => false),
  ("nary.f06.peer-success", match f06Run with
    | .executed _ m => decide ((m.locals 1).failure.isNone ∧ (m.locals 1).consumed = 1)
    | _ => false)]

def f07Checks : List (String × Bool) := [
  ("nary.f07.class", decide (classification "F07" = .fundedExecution)),
  ("nary.refusal.peer_continues", match f07Run with
    | .executed _ m => decide (vaultOf m.world = 12) &&
        executedEq fin3Roster f07Run f07Schedule f07Expected
    | _ => false),
  ("nary.refusal.attempt", match f07Run with
    | .executed _ m =>
        decide (m.attempts.length = 4 ∧
          (m.attempts.filter (fun a ↦ match a.outcome with
            | .error _ => true | .ok _ => false)).length = 1)
    | _ => false),
  ("nary.f07.skip-no-attempt", match f07Run with
    | .executed _ m => decide ((m.locals 0).consumed = 3 ∧ (m.locals 0).nextIndex = 1 ∧
        (m.locals 0).events.length = 1)
    | _ => false)]

def f08Checks : List (String × Bool) := [
  ("nary.f08.class", decide (classification "F08" = .arbitraryPrefix)),
  ("nary.skip.consumed", decide ((f08Run.locals 0).consumed = 2 ∧
      (f08Run.locals 0).nextIndex = 1 ∧ f08Run.attempts.length = 1) &&
    cmpMachine fin3Roster f08Run f08Expected),
  ("nary.monitor.skip_no_replay", decide (f08Count.1 = 1)),
  ("nary.f08.vault-unchanged", decide (vaultOf f08Run.world = 9))]

def synth (name : String) (mutant : M3) : List (String × Bool) :=
  [("nary.f09.candidate." ++ name, !machineEq fin3Roster f09Entry mutant),
    ("nary.f09.independent." ++ name, !fullMachineEq fin3Roster f09Entry mutant)]

def f09Checks : List (String × Bool) :=
  [("nary.f09.class.entry", decide (classification "F09" = .arbitraryEntry)),
    ("nary.f09.class.synthetic", decide (f09SyntheticClass = .syntheticObservation)),
    ("nary.f09.continuation", cmpMachine fin3Roster f09Run f09Expected),
    ("nary.f09.chunked", cmpMachine fin3Roster f09Chunked f09Expected &&
      cmpMachine fin3Roster f09Chunked f09Run),
    ("nary.f09.raw-worlds-retained",
      eventsEq (f09Run.locals 0).events (f09Expected.locals 0).events),
    ("nary.f09.history-consumed",
      decide ((f09Run.locals 0).outputs = [f09Out0, f09Out1] ∧
        (f09Run.locals 0).nextIndex = 3 ∧ (f09Run.locals 0).consumed = 3)),
    ("nary.f09.monitor.entry", decide (f09Mon.1 = f09MonitorExpected)),
    ("nary.f09.monitor.chunked", decide (f09MonChunked.1 = f09MonitorExpected ∧
      f09MonChunked.1 = f09Mon.1)),
    ("nary.f09.candidate.equal", machineEq fin3Roster f09Entry f09Entry),
    ("nary.f09.independent.equal", fullMachineEq fin3Roster f09Entry f09Entry)] ++
    (synth "world" f09WorldDiff) ++
    (synth "store" f09StoreDiff) ++
    (synth "consumed" f09ConsumedDiff) ++
    (synth "nextIndex" f09NextIndexDiff) ++
    (synth "localOutputs" f09LocalOutputsDiff) ++
    (synth "localFailure" f09LocalFailureDiff) ++
    (synth "eventIndex" f09EventIndexDiff) ++
    (synth "eventStep" f09EventStepDiff) ++
    (synth "eventBefore" f09EventBeforeDiff) ++
    (synth "resultWorld" f09ResultWorldDiff) ++
    (synth "resultOutputs" f09ResultOutputsDiff) ++
    (synth "evGuard" f09EvGuardDiff) ++
    (synth "evDeltas" f09EvDeltasDiff) ++
    (synth "evSupplies" f09EvSuppliesDiff) ++
    (synth "evReqReads" f09EvReqReadsDiff) ++
    (synth "evReqEnv" f09EvReqEnvDiff) ++
    (synth "evDeclReads" f09EvDeclReadsDiff) ++
    (synth "evDeclEnv" f09EvDeclEnvDiff) ++
    (synth "evWrites" f09EvWritesDiff) ++
    (synth "reqOp" f09ReqOpDiff) ++
    (synth "reqParties" f09ReqPartiesDiff) ++
    (synth "reqArgs" f09ReqArgsDiff) ++
    (synth "reqCaps" f09ReqCapsDiff) ++
    (synth "reqActor" f09ReqActorDiff) ++
    (synth "receiptCtor" f09ReceiptCtorDiff) ++
    (synth "locOutStep" f09LocOutStepDiff) ++
    (synth "locOutPort" f09LocOutPortDiff) ++
    (synth "locOutValue" f09LocOutValueDiff) ++
    (synth "evOutStep" f09EvOutStepDiff) ++
    (synth "evOutPort" f09EvOutPortDiff) ++
    (synth "evOutValue" f09EvOutValueDiff) ++
    (synth "failIndex" f09FailIndexDiff) ++
    (synth "failStep" f09FailStepDiff) ++
    (synth "failReason" f09FailReasonDiff) ++
    (synth "atParticipant" f09AtParticipantDiff) ++
    (synth "atIndex" f09AtIndexDiff) ++
    (synth "atInv" f09AtInvDiff) ++
    (synth "atBefore" f09AtBeforeDiff) ++
    (synth "atOutcomeCtor" f09AtOutcomeCtorDiff) ++
    (synth "atOkWorld" f09AtOkWorldDiff) ++
    (synth "atOkOutputs" f09AtOkOutputsDiff) ++
    (synth "atOkGuard" f09AtOkGuardDiff)

def schedTag (s : List (Fin 3)) : String :=
  s.foldl (fun acc b ↦ acc ++ toString b.val) ""

def f10ActualOk (s : List (Fin 3)) : Bool :=
  let expected := expectedF10 (s.map Fin.val)
  executedEq fin3Roster (f10Run s) s expected &&
    decide (vaultOf expected.world = 7 ∧ expected.world.state.balance donor1C = 1 ∧
      expected.world.state.balance donor2C = 1 ∧
      expected.world.state.balance recipientC = 6 ∧
      expected.world.state.balance budgetC = 6 ∧
      expected.world.state.balance sentinelC = 11 ∧
      expected.world.capabilities = f10Store)

def localsNCEq (m : M3) (nc : List Nat) : Bool :=
  match nc with
  | [a, b, c] =>
      decide ((m.locals 0).consumed = a ∧ (m.locals 0).nextIndex = a ∧
        (m.locals 1).consumed = b ∧ (m.locals 1).nextIndex = b ∧
        (m.locals 2).consumed = c ∧ (m.locals 2).nextIndex = c)
  | _ => false

def f10PrefixExact (s : List (Fin 3)) (n : Nat) : Bool :=
  let ns := s.map Fin.val
  let expectedM := expectedF10Prefix ns n
  let actualM := prefix3 f10Cfg f10Bounds f10Initial f10Branches (s.take n)
  let tr := f10Trace (s.take n)
  machineEq fin3Roster actualM expectedM &&
    fullMachineEq fin3Roster actualM expectedM &&
    decide (tr.1.phase = expectedF10PrefixPhase ns n) &&
    localsNCEq actualM (expectedF10PrefixNC ns n) &&
    decide (vaultOf actualM.world ≥ 4 ∧ actualM.world.state.balance sentinelC = 11)

def f10PrefixReserve (s : List (Fin 3)) : Bool :=
  (List.range (s.length + 1)).all fun n ↦
    let pre := prefix3 f10Cfg f10Bounds f10Initial f10Branches (s.take n)
    decide (vaultOf pre.world ≥ 4 ∧ pre.world.state.balance sentinelC = 11)

def f10ScheduleChecks : List (String × Bool) :=
  f10Schedules.map fun s ↦ (s!"nary.f10.sched.{schedTag s}.final", f10ActualOk s)

def f10PrefixChecks : List (String × Bool) :=
  f10Schedules.map fun s ↦ (s!"nary.f10.sched.{schedTag s}.reserve", f10PrefixReserve s)

def f10EachPrefixChecks : List (String × Bool) :=
  f10Schedules.flatMap fun s ↦
    (List.range (s.length + 1)).map fun n ↦
      (s!"nary.f10.sched.{schedTag s}.prefix{n}", f10PrefixExact s n)

def f10MonitorChecks : List (String × Bool) :=
  f10Schedules.map fun s ↦
    (s!"nary.f10.sched.{schedTag s}.monitor", decide ((f10Trace s).1.phase = .consumed))

def f10CoreChecks : List (String × Bool) := [
  ("nary.f10.class", decide (classification "F10" = .genericProofInstance)),
  ("nary.f10.twelve", decide (f10Schedules.length = 12 ∧ f10OracleRows.length = 48)),
  ("nary.f10.catalog", validateCatalog f10Cfg.registry f10Cfg.catalog),
  ("nary.monitor.actual_producer", decide ((f10Trace [0]).1.phase = .ready6)),
  ("nary.monitor.success_input",
    match (f10Trace [0]).1 with
    | ⟨.ready6, [some a]⟩ =>
        isReadyProducer a && attemptEq a expectedProducerAttempt
    | _ => false),
  ("nary.monitor.retained_phase",
    decide ((f10Trace [0, 1]).1.phase = .ready6 ∧
      (f10Trace [0, 1, 0, 2]).1.phase = .consumed)),
  ("nary.f10.extra-skip-consumed",
    decide ((f10Mon f10ExtraSkip).1 = .consumed) &&
      let m := prefix3 f10Cfg f10Bounds f10Initial f10Branches f10ExtraSkip
      decide ((m.locals 0).consumed = 3 ∧ m.attempts.length = 4)),
  ("nary.f10.overschedule.refused",
    refusedEq (f10Run f10ExtraSkip) (.schedule ⟨0, 2, 3⟩) f10Initial f10ExtraSkip)]

def f11Checks : List (String × Bool) := [
  ("nary.f11.class", decide (classification "F11" = .fundedNegative)),
  ("nary.f11.success", executedEq fin3Roster f11Run [0] f11Expected),
  ("nary.f11.vault3", match f11Run with
    | .executed _ m => decide (vaultOf m.world = 3 ∧ m.world.state.balance recipientC = 7 ∧
        vaultOf m.world < 4)
    | _ => false)]

def f12Checks : List (String × Bool) := [
  ("nary.f12.class", decide (classification "F12" = .fundedNegative)),
  ("nary.f12.complete", executedEq fin3Roster f12Run f12Schedule f12Expected),
  ("nary.f12.vault1", match f12Run with
    | .executed _ m => decide (vaultOf m.world = 1 ∧ m.world.state.balance recipientC = 6 ∧
        m.world.state.balance donor1C = 3)
    | _ => false)]

def f13Checks : List (String × Bool) := [
  ("nary.f13.class", decide (classification "F13" = .fundedNegative)),
  ("nary.f13.peer7", executedEq fin3Roster f13Run [1] f13Expected),
  ("nary.f13.vault3", match f13Run with
    | .executed _ m => decide (vaultOf m.world = 3 ∧ vaultOf m.world < 4)
    | _ => false)]

def f14Checks : List (String × Bool) := [
  ("nary.f14.class", decide (classification "F14" = .fundedNegative)),
  ("nary.f14.identity", executedEq fin3Roster f14Run [0, 1, 2] f14Expected),
  ("nary.f14.uninitialized", match f14Run with
    | .executed _ m => decide (vaultOf m.world = 3 ∧ vaultOf m.world < 4)
    | _ => false)]

def f15Checks : List (String × Bool) := [
  ("nary.f15.class", decide (classification "F15" = .logicalCounterexample)),
  ("nary.f15.circular", f15Implications && !f15Facts)]

def f16Checks : List (String × Bool) := [
  ("nary.f16.class", decide (classification "F16" = .actualRefusal)),
  ("nary.f16.refused-producer", executedEq fin3Roster f16Run f16Schedule f16Expected),
  ("nary.f16.awaiting", decide (f16Mon.1 = .awaiting)),
  ("nary.f16.peer-deposit", match f16Run with
    | .executed _ m => decide (vaultOf m.world = 11 ∧ (m.locals 0).events.isEmpty ∧
        (m.locals 0).consumed = 2 ∧ m.attempts.length = 2)
    | _ => false)]

def f17Checks : List (String × Bool) := [
  ("nary.f17.class", decide (classification "F17" = .snapshotProvenanceNegative)),
  ("nary.f17.lookalike", cmpMachine fin3Roster f17Run f17Expected),
  ("nary.f17.awaiting", decide (f17Mon.1 = .awaiting)),
  ("nary.f17.peer-output", decide ((f17Run.locals 1).outputs = [budgetOut 0]))]

def f18PrefixHolds (s : List (Fin 3)) : Bool :=
  (List.range (s.length + 1)).all fun n ↦
    let pre := runPrefix f18Cfg f18Bounds f18Initial f18Branches (s.take n)
    let w := f18WorldAfter n
    worldEq pre.world w &&
      decide (balanceSum f18Region pre.world.state = 10) &&
      bindingsHold f18Cfg f18Edges pre.world.state &&
      decide (pre.world.capabilities = f18Store)

def f18Ok (s : List (Fin 3)) : Bool :=
  executedEq f18Roster (f18Run s) s (expectedF18 s) && f18PrefixHolds s &&
    match f18Run s with
    | .executed _ m =>
        decide ((m.locals 0).nextIndex = 1 ∧ (m.locals 1).nextIndex = 1 ∧
          (m.locals 2).nextIndex = 1 ∧
          (m.locals 0).events.head?.map (fun e ↦ e.index) = some 0 ∧
          (m.locals 1).events.head?.map (fun e ↦ e.index) = some 0 ∧
          (m.locals 2).events.head?.map (fun e ↦ e.index) = some 0) &&
        m.attempts.all fun a ↦ match a.outcome with
          | .ok r => decide (r.receipt = f18Receipt)
          | .error _ => false
    | _ => false

def f18Checks : List (String × Bool) :=
  [("nary.f18.class", decide (classification "F18" = .m2Instance)),
    ("nary.f18.six", decide (f18Schedules.length = 6)),
    ("nary.f18.op102", decide (f18Op = Interface.Examples.op102)),
    ("nary.f18.receipt102", decide (f18Receipt = Interface.Examples.receipt102))] ++
    f18Schedules.map fun s ↦ (s!"nary.f18.sched.{schedTag s}", f18Ok s)

def f19Checks : List (String × Bool) := [
  ("nary.f19.class", decide (classification "F19" = .m2Negative)),
  ("nary.f19.complete", executedEq f18Roster f19Run f19Schedule f19Expected),
  ("nary.f19.receipt103", match f19Run with
    | .executed _ m => match m.attempts.head? with
      | some ⟨_, _, _, _, .ok r⟩ => decide (r.receipt = Interface.Examples.receipt103)
      | _ => false
    | _ => false),
  ("nary.f19.balances", match f19Run with
    | .executed _ m => decide (m.world.state.balance Interface.Examples.alice = 4 ∧
        m.world.state.balance Interface.Examples.bob = 5 ∧
        m.world.state.balance Interface.Examples.carol = 1 ∧
        balanceSum f18Region m.world.state = 10 ∧
        m.world.capabilities = f18Store)
    | _ => false),
  ("nary.f19.empty-edges", match f19Run with
    | .executed _ m => bindingsHold f18Cfg f18EmptyEdges m.world.state
    | _ => false),
  ("nary.f19.global-edge", match f19Run with
    | .executed _ m => decide (checkBindings f18Cfg f18Edges m.world.state = f19BindingError) &&
        !bindingsHold f18Cfg f18Edges m.world.state
    | _ => false)]

def catalogChecks : List (String × Bool) := [
  ("nary.catalog.funded", validateCatalog fundedCfg.registry fundedCfg.catalog),
  ("nary.catalog.f10", validateCatalog f10Cfg.registry f10Cfg.catalog),
  ("nary.catalog.f05", validateCatalog f05Cfg.registry f05Cfg.catalog),
  ("nary.catalog.invalid", !validateCatalog invalidCfg.registry invalidCfg.catalog),
  ("nary.labels.false-sixteen", decide (mutationFalseLabels.length = 16 ∧
    mutationFalseLabels.Nodup)),
  ("nary.labels.protected", decide (protectedPositiveLabels.contains "nary.empty.exact" ∧
    protectedPositiveLabels.contains "nary.no_failure.exact"))]

def runtimeComparisons : List (String × Bool) :=
  catalogChecks ++ f01Checks ++ f02Checks ++ f03Checks ++ f04Checks ++ f05Checks ++
    f06Checks ++ f07Checks ++ f08Checks ++ f09Checks ++ f10CoreChecks ++
    f10ScheduleChecks ++ f10PrefixChecks ++ f10EachPrefixChecks ++ f10MonitorChecks ++
    f11Checks ++ f12Checks ++ f13Checks ++ f14Checks ++ f15Checks ++
    f16Checks ++ f17Checks ++ f18Checks ++ f19Checks

-- BEGIN PROOFS

end DefiKernel.Nary.Tests
