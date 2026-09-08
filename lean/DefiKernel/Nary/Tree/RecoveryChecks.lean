import DefiKernel.Nary.Tree.Recovery
import DefiKernel.Parallel.Examples

/-! Recorded auxiliary for the compatible-recovery lane.
Independent literals: F13 conflict directions and shared-read, F20 unowned
sentinel 11 vs 22, F15 competing-write incompatibility, canonical projection
iff, admitIsolated after tree admission, funded F06 success-then-refusal, and
actual opposite-order competition execution. Does not import Nary.Examples and
does not claim F01–F20 / 313 labels. -/
namespace DefiKernel.Nary.Tree.RecoveryChecks
open Typed Composition Parallel
open DefiKernel.Nary.Tree

abbrev P := Bool
abbrev A := Bool
abbrev D := Bool
abbrev W := World P A D

def emptyRegistry : Registry P A D := fun _ => none
def emptyCatalog : Catalog P A D := []
def emptyCfg : Config P A D := ⟨emptyRegistry, fun _ => false, emptyCatalog⟩
def dupCatalog : Catalog P A D :=
  [⟨⟨0⟩, [], [], [], []⟩, ⟨⟨0⟩, [], [], [], []⟩]
def dupCfg : Config P A D := ⟨emptyRegistry, fun _ => false, dupCatalog⟩

def cellV : Cell P A D := (false, false, false)
def cellS : Cell P A D := (true, false, false)
def cellO : Cell P A D := (false, true, false)

def mkBal (v s o : ℚ) : Cell P A D → ℚ := fun c =>
  if c = cellV then v else if c = cellS then s else if c = cellO then o else 0

def mkWorld (v s o : ℚ) (hv : 0 ≤ v) (hs : 0 ≤ s) (ho : 0 ≤ o) : W :=
  ⟨⟨mkBal v s o, fun c => by
      simp only [mkBal]
      split_ifs
      · exact hv
      · exact hs
      · exact ho
      · exact le_rfl⟩, CapabilityStore.empty⟩

def initial : W := mkWorld 10 11 0 (by decide) (by decide) (by decide)
def leftWorld : W := mkWorld 3 22 0 (by decide) (by decide) (by decide)
def rightWorld : W := mkWorld 10 22 7 (by decide) (by decide) (by decide)

def fpWriteV : Footprint P A D := ⟨[cellV], [cellV]⟩
def fpReadV : Footprint P A D := ⟨[cellV], []⟩
def fpWriteO : Footprint P A D := ⟨[cellO], [cellO]⟩
def fpEmpty : Footprint P A D := .empty

def emptyRoster : Roster Empty := Roster.empty Empty.elim
def fin2Roster : Roster (Fin 2) where
  order := [0, 1]
  nodup := by decide
  complete := by
    intro b
    match b with
    | ⟨0, _⟩ => exact List.Mem.head _
    | ⟨1, _⟩ => exact List.Mem.tail _ (List.Mem.head _)

def emptyBounds : Boundaries Empty P A D := fun b => nomatch b
def emptyBranches : Branches Empty P A D := fun b => nomatch b
def fin2Bounds : Boundaries (Fin 2) P A D := fun _ _ =>
  ⟨⟨false, false⟩, fun _ => none, 0⟩
def fin2None : Branches (Fin 2) P A D := fun _ => []
def fin2Fork : Tree (Fin 2) := .fork (.leaf 0) (.leaf 1)
def fin2ForkSwap : Tree (Fin 2) := .fork (.leaf 1) (.leaf 0)

def merged : W := mergeOwned fpWriteV fpWriteO initial leftWorld rightWorld

def assocOK : List (Fin 2 × Footprint P A D) :=
  [(0, fpWriteV), (1, fpWriteO)]
def assocWW : List (Fin 2 × Footprint P A D) :=
  [(0, fpWriteV), (1, fpWriteV)]
def assocShared : List (Fin 2 × Footprint P A D) :=
  [(0, fpReadV), (1, fpReadV)]

def locA : CanonicalLocal P A D := ⟨1, ⟨[], [], 1, none⟩⟩
def locB : CanonicalLocal P A D := ⟨1, ⟨[], [], 1, some ⟨0, none, .configuration⟩⟩⟩
def obsA : CanonicalObservation (Fin 2) P A D := ⟨initial, [(0, locA), (1, locA)]⟩
def obsB : CanonicalObservation (Fin 2) P A D := ⟨initial, [(0, locA), (1, locB)]⟩
def obsWorld : CanonicalObservation (Fin 2) P A D := ⟨leftWorld, [(0, locA), (1, locA)]⟩

def fieldInv : Invocation P A D := ⟨⟨0⟩, ⟨99⟩, [], [], [], none⟩
def fieldStep : Composition.Step P A D := .revoke ⟨0⟩
def fieldReceiptA : Composition.Receipt P A D := .issued ⟨0⟩
def fieldReceiptB : Composition.Receipt P A D := .revoked ⟨0⟩
def fieldOutA : OutputObservation A := ⟨0, ⟨⟨0⟩, ⟨0⟩⟩, ⟨.amount false, (1 : ℚ)⟩⟩
def fieldOutB : OutputObservation A := ⟨0, ⟨⟨0⟩, ⟨0⟩⟩, ⟨.amount false, (2 : ℚ)⟩⟩
def fieldEvtReceiptA : Parallel.EventObservation P A D := ⟨0, fieldStep, fieldReceiptA, []⟩
def fieldEvtReceiptB : Parallel.EventObservation P A D := ⟨0, fieldStep, fieldReceiptB, []⟩
def locReceiptA : CanonicalLocal P A D := ⟨1, ⟨[fieldEvtReceiptA], [], 1, none⟩⟩
def locReceiptB : CanonicalLocal P A D := ⟨1, ⟨[fieldEvtReceiptB], [], 1, none⟩⟩
def locConsumed : CanonicalLocal P A D := ⟨2, ⟨[], [], 1, none⟩⟩
def locOutA : CanonicalLocal P A D := ⟨1, ⟨[], [fieldOutA], 1, none⟩⟩
def locOutB : CanonicalLocal P A D := ⟨1, ⟨[], [fieldOutB], 1, none⟩⟩
def obsReceiptA : CanonicalObservation (Fin 2) P A D := ⟨initial, [(0, locReceiptA), (1, locA)]⟩
def obsReceiptB : CanonicalObservation (Fin 2) P A D := ⟨initial, [(0, locReceiptB), (1, locA)]⟩
def obsConsumed : CanonicalObservation (Fin 2) P A D := ⟨initial, [(0, locConsumed), (1, locA)]⟩
def obsOutA : CanonicalObservation (Fin 2) P A D := ⟨initial, [(0, locOutA), (1, locA)]⟩
def obsOutB : CanonicalObservation (Fin 2) P A D := ⟨initial, [(0, locOutB), (1, locA)]⟩
def fieldResult (w : W) : Composition.StepResult P A D := ⟨w, fieldReceiptA, []⟩
def fieldEvent (before : W) : Composition.Event P A D :=
  ⟨0, fieldStep, before, fieldResult initial⟩
def fieldLocal (before : W) : Interleaving.LocalState P A D :=
  { consumed := 1, events := [fieldEvent before], nextIndex := 1 }
def tmRawWorldA : TreeMachine (Fin 2) P A D :=
  ⟨initial, .fork (.leaf 0 (fieldLocal initial)) (.leaf 1 {}), []⟩
def tmRawWorldB : TreeMachine (Fin 2) P A D :=
  ⟨initial, .fork (.leaf 0 (fieldLocal leftWorld)) (.leaf 1 {}), []⟩
def fieldAttempt : Nary.Attempt (Fin 2) P A D :=
  ⟨0, 0, fieldInv, initial, .error .configuration⟩
def tmAttemptsA : TreeMachine (Fin 2) P A D := ⟨initial, emptyLocals fin2Fork, []⟩
def tmAttemptsB : TreeMachine (Fin 2) P A D := ⟨initial, emptyLocals fin2Fork, [fieldAttempt]⟩

def comparisons : List (String × Bool) := [
  ("recovery.f13.write-write",
    decide (checkPair (0 : Fin 2) 1 fpWriteV fpWriteV =
      .error ⟨0, 1, .writeWrite, cellV⟩)),
  ("recovery.f13.left-write-right-read",
    decide (checkPair (0 : Fin 2) 1 fpWriteV fpReadV =
      .error ⟨0, 1, .leftWriteRightRead, cellV⟩)),
  ("recovery.f13.right-write-left-read",
    decide (checkPair (0 : Fin 2) 1 fpReadV fpWriteV =
      .error ⟨0, 1, .rightWriteLeftRead, cellV⟩)),
  ("recovery.f13.shared-read",
    decide (checkPair (0 : Fin 2) 1 fpReadV fpReadV = .ok ())),
  ("recovery.f13.disjoint-writes",
    decide (checkPair (0 : Fin 2) 1 fpWriteV fpWriteO = .ok ())),
  ("recovery.f13.pairwise-ok",
    decide (checkPairwise assocOK = .ok ())),
  ("recovery.f13.pairwise-ww",
    match checkPairwise assocWW with
    | .error e => decide (e.kind = .writeWrite ∧ e.cell = cellV)
    | .ok _ => false),
  ("recovery.f13.pairwise-shared",
    decide (checkPairwise assocShared = .ok ())),
  ("recovery.f20.sentinel11",
    decide (merged.state.balance cellS = 11)),
  ("recovery.f20.not22",
    decide (merged.state.balance cellS ≠ 22)),
  ("recovery.f20.owner-left",
    decide (merged.state.balance cellV = 3)),
  ("recovery.f20.owner-right",
    decide (merged.state.balance cellO = 7)),
  ("recovery.f20.store-fixed",
    decide (merged.capabilities = initial.capabilities)),
  ("recovery.f15.competing-not-compatible",
    match checkPair (0 : Fin 2) 1 fpWriteV fpWriteV with
    | .error e => decide (e.kind = .writeWrite)
    | .ok _ => false),
  ("recovery.canonical.refl",
    canonicalEq obsA obsA),
  ("recovery.canonical.failure-diff",
    !canonicalEq obsA obsB),
  ("recovery.canonical.world-diff",
    !canonicalEq obsA obsWorld),
  ("recovery.canonical.receipt-diff",
    !canonicalEq obsReceiptA obsReceiptB),
  ("recovery.canonical.consumed-diff",
    !canonicalEq obsA obsConsumed),
  ("recovery.canonical.output-diff",
    !canonicalEq obsOutA obsOutB),
  ("recovery.canonical.raw-event-world-omitted",
    canonicalEq (canonicalOf fin2Roster tmRawWorldA) (canonicalOf fin2Roster tmRawWorldB)),
  ("recovery.full.raw-event-world-rejected",
    !fullMachineEq fin2Roster tmRawWorldA tmRawWorldB),
  ("recovery.canonical.attempts-omitted",
    canonicalEq (canonicalOf fin2Roster tmAttemptsA) (canonicalOf fin2Roster tmAttemptsB)),
  ("recovery.full.attempts-rejected",
    !fullMachineEq fin2Roster tmAttemptsA tmAttemptsB),
  ("recovery.r1.locals-eq-leaves",
    decide ((runIsolatedTree emptyCfg fin2Bounds initial fin2None [] fin2Fork).2.map Prod.fst =
      Tree.leaves fin2Fork)),
  ("recovery.r1.dfs-not-roster",
    decide ((runIsolatedTree emptyCfg fin2Bounds initial fin2None [] fin2ForkSwap).2.map Prod.fst =
      [1, 0]) &&
      decide (fin2Roster.order = [0, 1])),
  ("recovery.r1.lookup-normalized",
    decide (lookupIsolatedLocal
        (runIsolatedTree emptyCfg fin2Bounds initial fin2None [] fin2ForkSwap).2 0 =
      lookupIsolatedLocal
        (isolatedLocals emptyCfg fin2Bounds initial fin2None fin2Roster.order) 0) &&
      decide (lookupIsolatedLocal
        (runIsolatedTree emptyCfg fin2Bounds initial fin2None [] fin2ForkSwap).2 1 =
      lookupIsolatedLocal
        (isolatedLocals emptyCfg fin2Bounds initial fin2None fin2Roster.order) 1)),
  ("recovery.r1.empty-left-locals",
    decide ((runIsolatedTree emptyCfg fin2Bounds initial fin2None []
        ((Tree.empty : Tree (Fin 2)).fork fin2Fork)).2 =
      (runIsolatedTree emptyCfg fin2Bounds initial fin2None [] fin2Fork).2)),
  ("recovery.r1.assoc-locals",
    decide ((runIsolatedTree emptyCfg fin2Bounds initial fin2None []
        (((Tree.leaf (0 : Fin 2)).fork (Tree.leaf 1)).fork Tree.empty)).2 =
      (runIsolatedTree emptyCfg fin2Bounds initial fin2None []
        ((Tree.leaf (0 : Fin 2)).fork ((Tree.leaf 1).fork Tree.empty))).2)),
  ("recovery.admit.isolated-empty",
    match admitIsolated emptyCfg emptyRoster emptyBounds emptyBranches [] Tree.empty with
    | .ok assoc => decide (assoc = [])
    | .error _ => false),
  ("recovery.admit.isolated-dup-catalog",
    match admitIsolated dupCfg emptyRoster emptyBounds emptyBranches [] Tree.empty with
    | .error (.inl (.base .configuration)) => true
    | _ => false),
  ("recovery.isolated.consumed-empty",
    decide (isolatedConsumed ([] : Parallel.Branch P A D) = 0)),
  ("recovery.runIsolated.empty-tree",
    Parallel.worldEq
      (runIsolatedTree emptyCfg emptyBounds initial emptyBranches []
        (Tree.empty : Tree Empty)).1
      initial)
]

namespace Funded
open Typed Composition Parallel
open Typed.Examples
open DefiKernel.Nary.Tree

def fundedCfg := Parallel.Examples.cfg
def fundedInitial := Parallel.Examples.initial
def aliceBound : Boundary Party Asset Domain := ⟨aliceContext, fresh, 100⟩
def naryBounds : Boundaries (Fin 2) Party Asset Domain := fun _ _ => aliceBound

def f06Branch : Parallel.Branch Party Asset Domain :=
  [Parallel.Examples.usd 3, Parallel.Examples.usd 8]
def isoPrefix : Cursor Party Asset Domain :=
  isolated fundedCfg (fun _ => aliceBound) fundedInitial f06Branch 1
def isoRefused : Cursor Party Asset Domain :=
  isolated fundedCfg (fun _ => aliceBound) fundedInitial f06Branch 2

def firstStep : Except Composition.Failure (StepResult Party Asset Domain) :=
  executeStep fundedCfg aliceBound 0 [] (.invoke (Parallel.Examples.usd 3)) fundedInitial

def afterSuccess : World Party Asset Domain :=
  match firstStep with
  | .ok result => result.world
  | .error _ => fundedInitial

def secondStep : Except Composition.Failure (StepResult Party Asset Domain) :=
  match firstStep with
  | .ok result =>
    executeStep fundedCfg aliceBound 1 result.outputs
      (.invoke (Parallel.Examples.usd 8)) result.world
  | .error reason => .error reason

def fin2Roster : Roster (Fin 2) where
  order := [0, 1]
  nodup := by decide
  complete := by
    intro b
    match b with
    | ⟨0, _⟩ => exact List.Mem.head _
    | ⟨1, _⟩ => exact List.Mem.tail _ (List.Mem.head _)

def fin2Fork : Tree (Fin 2) := .fork (.leaf 0) (.leaf 1)

def disjBranches : Branches (Fin 2) Party Asset Domain := fun b =>
  if b = 0 then [Parallel.Examples.usd 3] else [Parallel.Examples.shares 4]

/-- Auxiliary companion: USD3 versus USD8 from 10. Not the assigned D7 F15. -/
def f15Branches : Branches (Fin 2) Party Asset Domain := fun b =>
  if b = 0 then [Parallel.Examples.usd 3] else [Parallel.Examples.usd 8]

/-- Assigned F15: withdrawals 7 and 6 from USD10, residuals 3 and 4. -/
def f15NormativeBranches : Branches (Fin 2) Party Asset Domain := fun b =>
  if b = 0 then [Parallel.Examples.usd 7] else [Parallel.Examples.usd 6]

/-- Compatible nonempty-write success-prefix then financial refusal plus disjoint peer. -/
def refuseBranches : Branches (Fin 2) Party Asset Domain := fun b =>
  if b = 0 then [Parallel.Examples.usd 3, Parallel.Examples.usd 8]
  else [Parallel.Examples.shares 4]

def mLR : Nary.Machine (Fin 2) Party Asset Domain :=
  Nary.runPrefix fundedCfg naryBounds fundedInitial f15Branches [0, 1]
def mRL : Nary.Machine (Fin 2) Party Asset Domain :=
  Nary.runPrefix fundedCfg naryBounds fundedInitial f15Branches [1, 0]

def tmLR : TreeMachine (Fin 2) Party Asset Domain :=
  runTreePrefix fundedCfg naryBounds fundedInitial fin2Fork f15Branches [0, 1]
def tmRL : TreeMachine (Fin 2) Party Asset Domain :=
  runTreePrefix fundedCfg naryBounds fundedInitial fin2Fork f15Branches [1, 0]

def tmDisjLR : TreeMachine (Fin 2) Party Asset Domain :=
  runTreePrefix fundedCfg naryBounds fundedInitial fin2Fork disjBranches [0, 1]
def tmDisjRL : TreeMachine (Fin 2) Party Asset Domain :=
  runTreePrefix fundedCfg naryBounds fundedInitial fin2Fork disjBranches [1, 0]

def disjAssoc : List (Fin 2 × Footprint Party Asset Domain) :=
  match Nary.analyzeAll fundedCfg naryBounds disjBranches [0, 1] with
  | .ok assoc => assoc
  | .error _ => []

def isoDisj : CanonicalObservation (Fin 2) Party Asset Domain :=
  isolatedCanonical fin2Roster fundedCfg naryBounds fundedInitial disjBranches
    disjAssoc fin2Fork

def tmF15NormLR : TreeMachine (Fin 2) Party Asset Domain :=
  runTreePrefix fundedCfg naryBounds fundedInitial fin2Fork f15NormativeBranches [0, 1]
def tmF15NormRL : TreeMachine (Fin 2) Party Asset Domain :=
  runTreePrefix fundedCfg naryBounds fundedInitial fin2Fork f15NormativeBranches [1, 0]

def refuseSched001 : Schedule (Fin 2) := [0, 0, 1]
def refuseSched100 : Schedule (Fin 2) := [1, 0, 0]
def tmRefuse001 : TreeMachine (Fin 2) Party Asset Domain :=
  runTreePrefix fundedCfg naryBounds fundedInitial fin2Fork refuseBranches refuseSched001
def tmRefuse100 : TreeMachine (Fin 2) Party Asset Domain :=
  runTreePrefix fundedCfg naryBounds fundedInitial fin2Fork refuseBranches refuseSched100

def refuseAdmit001 :=
  admitIsolated fundedCfg fin2Roster naryBounds refuseBranches refuseSched001 fin2Fork
def refuseAdmit100 :=
  admitIsolated fundedCfg fin2Roster naryBounds refuseBranches refuseSched100 fin2Fork

def f15failure (m : Nary.Machine (Fin 2) Party Asset Domain) (b : Fin 2) : Bool :=
  (m.locals b).failure.isSome

def treeFailure (tm : TreeMachine (Fin 2) Party Asset Domain) (b : Fin 2) : Bool :=
  match lookupLeaf tm.locals b with
  | some own => own.failure.isSome
  | none => false

def treeFailureReason (tm : TreeMachine (Fin 2) Party Asset Domain) (b : Fin 2) :
    Option Composition.Failure :=
  match lookupLeaf tm.locals b with
  | some own => own.failure.map LocatedFailure.reason
  | none => none

def refuseCheck (tm : TreeMachine (Fin 2) Party Asset Domain)
    (assoc : List (Fin 2 × Footprint Party Asset Domain)) : Bool :=
  let iso := isolatedCanonical fin2Roster fundedCfg naryBounds fundedInitial
    refuseBranches assoc fin2Fork
  canonicalEq (canonicalOf fin2Roster tm) iso &&
    decide (tm.world.state.balance Parallel.Examples.aliceUSD = 7) &&
    decide (tm.world.state.balance Parallel.Examples.bobUSD = 3) &&
    decide (tm.world.state.balance Parallel.Examples.aliceShare = 4) &&
    decide (tm.world.state.balance Parallel.Examples.vaultShare = 16) &&
    decide (tm.world.state.balance Parallel.Examples.protectedCell = 9) &&
    decide (tm.world.state.balance Parallel.Examples.protectedCell ≠ 0) &&
    decide (tm.world.capabilities = fundedInitial.capabilities) &&
    match lookupLeaf tm.locals 0, lookupLeaf tm.locals 1 with
    | some own0, some own1 =>
      decide (own0.consumed = 2) && decide (own1.consumed = 1) &&
        decide (own0.events.length = 1) && decide (own1.events.length = 1) &&
        decide (!own0.outputs.isEmpty) && decide (!own1.outputs.isEmpty) &&
        match own0.failure, own1.failure with
        | some f0, none => decide (f0.reason = .kernel .insufficientFunds)
        | _, _ => false
    | _, _ => false

def funded : List (String × Bool) := [
  ("recovery.f06.catalog", validateCatalog fundedCfg.registry fundedCfg.catalog),
  ("recovery.f06.first-ok",
    match firstStep with
    | .ok _ => true
    | .error _ => false),
  ("recovery.f06.second-insufficientFunds",
    match secondStep with
    | .error (.kernel .insufficientFunds) => true
    | _ => false),
  ("recovery.f06.prefix-retained",
    decide (isoRefused.events.length = 1) &&
      decide (isoPrefix.failure = none) &&
      decide (isoRefused.failure.isSome)),
  ("recovery.f06.refusal-kernel",
    match isoRefused.failure with
    | some f => decide (f.reason = .kernel .insufficientFunds)
    | none => false),
  ("recovery.f06.store-fixed",
    decide (isoRefused.world.capabilities = fundedInitial.capabilities) &&
      decide (afterSuccess.capabilities = fundedInitial.capabilities)),
  ("recovery.f06.world-alice7",
    decide (isoRefused.world.state.balance Parallel.Examples.aliceUSD = 7) &&
      decide (afterSuccess.state.balance Parallel.Examples.aliceUSD = 7)),
  ("recovery.f06.world-bob3",
    decide (isoRefused.world.state.balance Parallel.Examples.bobUSD = 3)),
  -- Auxiliary companion: USD3/USD8 from 10. Assigned F15 is the 7/6 rows below.
  ("recovery.f15.lr-right-refuses",
    decide (!f15failure mLR 0) && f15failure mLR 1),
  ("recovery.f15.rl-left-refuses",
    f15failure mRL 0 && decide (!f15failure mRL 1)),
  ("recovery.f15.worlds-differ",
    !Parallel.worldEq mLR.world mRL.world),
  ("recovery.f15.canonical-differ",
    !canonicalEq (canonicalOf fin2Roster tmLR) (canonicalOf fin2Roster tmRL)),
  ("recovery.f15.competing-ww",
    match Nary.analyzeAll fundedCfg naryBounds f15Branches [0, 1] with
    | .ok assoc =>
      match checkPairwise assoc with
      | .error e => decide (e.kind = .writeWrite)
      | .ok _ => false
    | .error _ => false),
  ("recovery.f15.normative.lr-alice3",
    decide (tmF15NormLR.world.state.balance Parallel.Examples.aliceUSD = 3)),
  ("recovery.f15.normative.rl-alice4",
    decide (tmF15NormRL.world.state.balance Parallel.Examples.aliceUSD = 4)),
  ("recovery.f15.normative.lr-right-refuses",
    decide (!treeFailure tmF15NormLR 0) && treeFailure tmF15NormLR 1 &&
      decide (treeFailureReason tmF15NormLR 1 = some (.kernel .insufficientFunds))),
  ("recovery.f15.normative.rl-left-refuses",
    treeFailure tmF15NormRL 0 && decide (!treeFailure tmF15NormRL 1) &&
      decide (treeFailureReason tmF15NormRL 0 = some (.kernel .insufficientFunds))),
  ("recovery.f15.normative.canonical-differ",
    !canonicalEq (canonicalOf fin2Roster tmF15NormLR) (canonicalOf fin2Roster tmF15NormRL)),
  ("recovery.f15.normative.competing-ww",
    match Nary.analyzeAll fundedCfg naryBounds f15NormativeBranches [0, 1] with
    | .ok assoc =>
      match checkPairwise assoc with
      | .error e => decide (e.kind = .writeWrite)
      | .ok _ => false
    | .error _ => false),
  ("recovery.refuse.admit-001",
    match refuseAdmit001 with
    | .ok assoc => decide (assoc ≠ []) && decide (checkPairwise assoc = .ok ())
    | .error _ => false),
  ("recovery.refuse.admit-100",
    match refuseAdmit100 with
    | .ok assoc => decide (assoc ≠ []) && decide (checkPairwise assoc = .ok ())
    | .error _ => false),
  ("recovery.refuse.canonical-001",
    match refuseAdmit001 with
    | .ok assoc => refuseCheck tmRefuse001 assoc
    | .error _ => false),
  ("recovery.refuse.canonical-100",
    match refuseAdmit100 with
    | .ok assoc => refuseCheck tmRefuse100 assoc
    | .error _ => false),
  ("recovery.refuse.schedule-independence",
    canonicalEq (canonicalOf fin2Roster tmRefuse001) (canonicalOf fin2Roster tmRefuse100)),
  ("recovery.canonical.disjoint-schedules",
    canonicalEq (canonicalOf fin2Roster tmDisjLR) (canonicalOf fin2Roster tmDisjRL)),
  ("recovery.canonical.disjoint-isolated",
    canonicalEq (canonicalOf fin2Roster tmDisjLR) isoDisj &&
      canonicalEq (canonicalOf fin2Roster tmDisjRL) isoDisj)
]

theorem funded_catalog :
    validateCatalog fundedCfg.registry fundedCfg.catalog = true := by decide

theorem funded_disj_complete :
    Nary.Complete disjBranches ([0, 1] : Schedule (Fin 2)) := by
  intro b
  match b with
  | ⟨0, _⟩ => simp [disjBranches]
  | ⟨1, _⟩ => simp [disjBranches]

theorem funded_f15_complete :
    Nary.Complete f15Branches ([0, 1] : Schedule (Fin 2)) := by
  intro b
  match b with
  | ⟨0, _⟩ => simp [f15Branches]
  | ⟨1, _⟩ => simp [f15Branches]

theorem funded_wf : WellFormed fin2Roster fin2Fork := by
  intro b hb
  match b with
  | ⟨0, _⟩ => simp [fin2Fork, Tree.count, Tree.leaves]
  | ⟨1, _⟩ => simp [fin2Fork, Tree.count, Tree.leaves]

theorem funded_refuse_complete_001 :
    Nary.Complete refuseBranches refuseSched001 := by
  intro b
  match b with
  | ⟨0, _⟩ => simp [refuseBranches, refuseSched001]
  | ⟨1, _⟩ => simp [refuseBranches, refuseSched001]

theorem funded_refuse_complete_100 :
    Nary.Complete refuseBranches refuseSched100 := by
  intro b
  match b with
  | ⟨0, _⟩ => simp [refuseBranches, refuseSched100]
  | ⟨1, _⟩ => simp [refuseBranches, refuseSched100]

theorem funded_f15_normative_complete :
    Nary.Complete f15NormativeBranches ([0, 1] : Schedule (Fin 2)) := by
  intro b
  match b with
  | ⟨0, _⟩ => simp [f15NormativeBranches]
  | ⟨1, _⟩ => simp [f15NormativeBranches]

theorem funded_f15_normative_complete_rl :
    Nary.Complete f15NormativeBranches ([1, 0] : Schedule (Fin 2)) := by
  intro b
  match b with
  | ⟨0, _⟩ => simp [f15NormativeBranches]
  | ⟨1, _⟩ => simp [f15NormativeBranches]

theorem funded_refuse_canonicalEq_001
    (assoc : List (Fin 2 × Footprint Party Asset Domain))
    (h : admitIsolated fundedCfg fin2Roster naryBounds refuseBranches refuseSched001 fin2Fork
      = .ok assoc) :
    canonicalEq
      (canonicalOf fin2Roster tmRefuse001)
      (isolatedCanonical fin2Roster fundedCfg naryBounds fundedInitial refuseBranches
        assoc fin2Fork) = true :=
  complete_schedule_canonicalEq_of_admitIsolated fundedCfg naryBounds fundedInitial
    refuseBranches fin2Roster assoc fin2Fork refuseSched001 h

theorem funded_refuse_canonicalEq_100
    (assoc : List (Fin 2 × Footprint Party Asset Domain))
    (h : admitIsolated fundedCfg fin2Roster naryBounds refuseBranches refuseSched100 fin2Fork
      = .ok assoc) :
    canonicalEq
      (canonicalOf fin2Roster tmRefuse100)
      (isolatedCanonical fin2Roster fundedCfg naryBounds fundedInitial refuseBranches
        assoc fin2Fork) = true :=
  complete_schedule_canonicalEq_of_admitIsolated fundedCfg naryBounds fundedInitial
    refuseBranches fin2Roster assoc fin2Fork refuseSched100 h

theorem funded_refuse_independence_of_admit
    (assoc : List (Fin 2 × Footprint Party Asset Domain))
    (h001 : admitIsolated fundedCfg fin2Roster naryBounds refuseBranches refuseSched001 fin2Fork
      = .ok assoc)
    (h100 : admitIsolated fundedCfg fin2Roster naryBounds refuseBranches refuseSched100 fin2Fork
      = .ok assoc) :
    canonicalEq (canonicalOf fin2Roster tmRefuse001) (canonicalOf fin2Roster tmRefuse100) = true :=
  canonicalEq_trans
    (canonicalOf fin2Roster tmRefuse001)
    (isolatedCanonical fin2Roster fundedCfg naryBounds fundedInitial refuseBranches assoc fin2Fork)
    (canonicalOf fin2Roster tmRefuse100)
    (funded_refuse_canonicalEq_001 assoc h001)
    (canonicalEq_symm
      (canonicalOf fin2Roster tmRefuse100)
      (isolatedCanonical fin2Roster fundedCfg naryBounds fundedInitial refuseBranches assoc
        fin2Fork)
      (funded_refuse_canonicalEq_100 assoc h100))

set_option maxHeartbeats 400000 in
theorem funded_refuse_admit_001_isOk :
    (match refuseAdmit001 with
      | .ok _ => true
      | .error _ => false) = true := by
  decide +kernel

theorem funded_refuse_admit_001_exists :
    ∃ assoc, refuseAdmit001 = .ok assoc := by
  have h := funded_refuse_admit_001_isOk
  cases hs : refuseAdmit001 with
  | error _ =>
    rw [hs] at h
    exact (Bool.false_ne_true h).elim
  | ok assoc => exact ⟨assoc, rfl⟩

set_option maxHeartbeats 400000 in
theorem funded_f15_normative_lr_alice3 :
    tmF15NormLR.world.state.balance Parallel.Examples.aliceUSD = 3 := by
  decide +kernel

set_option maxHeartbeats 400000 in
theorem funded_f15_normative_rl_alice4 :
    tmF15NormRL.world.state.balance Parallel.Examples.aliceUSD = 4 := by
  decide +kernel

theorem funded_f15_normative_canonical_ne :
    canonicalEq (canonicalOf fin2Roster tmF15NormLR) (canonicalOf fin2Roster tmF15NormRL) =
      false := by
  have h3 := funded_f15_normative_lr_alice3
  have h4 := funded_f15_normative_rl_alice4
  have hne : (3 : ℚ) ≠ 4 := by decide
  cases hcanon : (canonicalEq (canonicalOf fin2Roster tmF15NormLR)
      (canonicalOf fin2Roster tmF15NormRL) : Bool)
  · rfl
  · have ⟨hw, _⟩ := (canonicalEq_iff
      (canonicalOf fin2Roster tmF15NormLR)
      (canonicalOf fin2Roster tmF15NormRL)).mp hcanon
    have hbal := hw.1 Parallel.Examples.aliceUSD
    simp [canonicalOf] at hbal
    cases hne (h3.symm.trans (hbal.trans h4))

set_option maxHeartbeats 400000 in
theorem funded_f15_normative_incompatible_check :
    (match Nary.analyzeAll fundedCfg naryBounds f15NormativeBranches [0, 1] with
      | .ok assoc =>
        match checkPairwise assoc with
        | .error _ => true
        | .ok _ => false
      | .error _ => false) = true := by
  decide +kernel

theorem funded_f15_normative_incompatible :
    match Nary.analyzeAll fundedCfg naryBounds f15NormativeBranches [0, 1] with
    | .ok assoc => checkPairwise assoc ≠ .ok ()
    | .error _ => False := by
  have h := funded_f15_normative_incompatible_check
  cases ha : Nary.analyzeAll fundedCfg naryBounds f15NormativeBranches [0, 1] with
  | error _ =>
    rw [ha] at h
    exact (Bool.false_ne_true h).elim
  | ok assoc =>
    intro hop
    rw [ha] at h
    simp [hop] at h

end Funded

def allComparisons : List (String × Bool) :=
  comparisons ++ Funded.funded

def main : IO Unit := do
  if allComparisons.isEmpty then
    throw (IO.userError "recovery comparisons empty")
  if !(allComparisons.map Prod.fst).Nodup then
    throw (IO.userError "recovery comparison names are duplicated")
  for (name, passed) in allComparisons do
    IO.println s!"{name}: {passed}"
  let failures := allComparisons.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"recovery comparisons failed: {failures}")

#eval main

end DefiKernel.Nary.Tree.RecoveryChecks
