import DefiKernel.Nary.Tree.Observation

/-! Recorded local auxiliary for the M4 foundation lane.
Independent literals compared against the actual Tree runtime. Expected values are not
taken from `advanceTree`, `runTree`, `runTreePaths`, `flattenMachine` or `Nary.advance`.
Does not import `Nary.Examples`. Full F01–F20 fixtures remain a later lane. -/
namespace DefiKernel.Nary.Tree.FoundationChecks
open Typed Composition Parallel
open DefiKernel.Nary.Tree

abbrev P := Bool
abbrev A := Bool
abbrev D := Bool
abbrev W := World P A D
abbrev Inv := Invocation P A D

def emptyRegistry : Registry P A D := fun _ => none
def emptyCatalog : Catalog P A D := []
def dupCatalog : Catalog P A D :=
  [⟨⟨0⟩, [], [], [], []⟩, ⟨⟨0⟩, [], [], [], []⟩]
def emptyCfg : Config P A D := ⟨emptyRegistry, fun _ => false, emptyCatalog⟩
def dupCfg : Config P A D := ⟨emptyRegistry, fun _ => false, dupCatalog⟩

def genesisState : State P A D :=
  ⟨fun _ => 0, fun _ => le_rfl⟩
def genesis : W := ⟨genesisState, CapabilityStore.empty⟩
def bound : Boundary P A D := ⟨⟨false, false⟩, fun _ => none, 0⟩
def dummyInv : Inv := ⟨⟨0⟩, ⟨99⟩, [], [], [], none⟩

def emptyRoster : Roster Empty := Roster.empty Empty.elim
def unitRoster : Roster Unit := Roster.singleton () (fun x => by cases x; rfl)
def boolRoster : Roster Bool where
  order := [false, true]
  nodup := by decide
  complete := fun b => by cases b <;> simp
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
def unitBounds : Boundaries Unit P A D := fun _ _ => bound
def unitNone : Branches Unit P A D := fun _ => []
def unitUnknown : Branches Unit P A D := fun _ => [dummyInv]
def boolBounds : Boundaries Bool P A D := fun _ _ => bound
def boolNone : Branches Bool P A D := fun _ => []
def fin2Bounds : Boundaries (Fin 2) P A D := fun _ _ => bound
def fin2None : Branches (Fin 2) P A D := fun _ => []

def emptyTree : Tree Empty := .empty
def unitLeaf : Tree Unit := .leaf ()
def boolFork : Tree Bool := .fork (.leaf false) (.leaf true)
def fin2Fork : Tree (Fin 2) := .fork (.leaf 0) (.leaf 1)

def ownA : Interleaving.LocalState P A D := { consumed := 3 }
def ownB : Interleaving.LocalState P A D := { consumed := 9 }
def dupLocals : LocalTree Unit P A D :=
  .fork (.leaf () ownA) (.leaf () ownB)
def dupMachine : TreeMachine Unit P A D := ⟨genesis, dupLocals, []⟩
def skipLiteral : Interleaving.LocalState P A D := { consumed := 1 }
def skipMachine : TreeMachine Unit P A D := ⟨genesis, .leaf () skipLiteral, []⟩
def startLiteral : TreeMachine Unit P A D := ⟨genesis, .leaf () {}, []⟩
def emptyStartLiteral : TreeMachine Empty P A D := ⟨genesis, .empty, []⟩

def emptyStart := startTree emptyTree genesis
def unitStart := startTree unitLeaf genesis
def boolStart := startTree boolFork genesis
def fin2Start := startTree fin2Fork genesis

def emptyRun :=
  runTree emptyCfg emptyRoster emptyBounds emptyBranches genesis emptyTree []
def emptyPaths :=
  runTreePaths emptyCfg emptyRoster emptyBounds emptyBranches genesis emptyTree []
def dupCfgEmpty :=
  runTree dupCfg emptyRoster emptyBounds emptyBranches genesis emptyTree []
def unitTreeFail :=
  runTree emptyCfg unitRoster unitBounds unitNone genesis (.empty : Tree Unit) []
def unitUnknownRun :=
  runTree emptyCfg unitRoster unitBounds unitUnknown genesis unitLeaf [()]
def unitSkip :=
  advanceTree emptyCfg unitBounds unitNone unitStart ()
def dupAdvance :=
  advanceTree emptyCfg unitBounds unitNone dupMachine ()
def badPath : Path := [.left, .left]
def badPaths : List Path := [[.left], badPath]
def fin2DecodeRefuse :=
  runTreePaths emptyCfg fin2Roster fin2Bounds fin2None genesis fin2Fork badPaths

def localFields (own : Interleaving.LocalState P A D)
    (consumed nextIndex : Nat) : Bool :=
  decide (own.consumed = consumed ∧ own.nextIndex = nextIndex) &&
    own.events.isEmpty && own.outputs.isEmpty && own.failure.isNone

def emptyRefusedBase (actual : TreeResult Empty P A D)
    (reason : TreeAdmissionFailure Empty P A D) (world : W) (schedule : Schedule Empty) : Bool :=
  match actual with
  | .refused r w s => decide (r = reason ∧ s = schedule) && Parallel.worldEq w world
  | .executed _ _ => false

def unitRefusedBase (actual : TreeResult Unit P A D)
    (reason : TreeAdmissionFailure Unit P A D) (world : W) (schedule : Schedule Unit) : Bool :=
  match actual with
  | .refused r w s => decide (r = reason ∧ s = schedule) && Parallel.worldEq w world
  | .executed _ _ => false

def comparisons : List (String × Bool) := [
  ("foundation.catalog.empty", validateCatalog emptyCfg.registry emptyCfg.catalog),
  ("foundation.catalog.dup", !validateCatalog dupCfg.registry dupCfg.catalog),
  ("foundation.shape.empty.leaves", decide (Tree.leaves (Tree.empty : Tree Unit) = [])),
  ("foundation.shape.empty.count", decide (Tree.count (Tree.empty : Tree Unit) () = 0)),
  ("foundation.shape.leaf.leaves", decide (Tree.leaves unitLeaf = [()])),
  ("foundation.shape.leaf.count", decide (Tree.count unitLeaf () = 1)),
  ("foundation.shape.fork.leaves",
    decide (Tree.leaves boolFork = [false, true])),
  ("foundation.shape.emptyLocals",
    decide ((emptyLocals unitLeaf : LocalTree Unit P A D).shape = unitLeaf)),
  ("foundation.check.empty-roster",
    decide (checkTree emptyRoster emptyTree = .ok ())),
  ("foundation.check.unit-leaf",
    decide (checkTree unitRoster unitLeaf = .ok ())),
  ("foundation.check.unit-empty-tree",
    decide (checkTree unitRoster (.empty : Tree Unit) = .error ⟨(), 1, 0⟩)),
  ("foundation.check.bool-fork",
    decide (checkTree boolRoster boolFork = .ok ())),
  ("foundation.lookup.empty",
    decide (lookupLeaf (LocalTree.empty : LocalTree Unit P A D) () = none)),
  ("foundation.lookup.leaf",
    match lookupLeaf (emptyLocals unitLeaf : LocalTree Unit P A D) () with
    | some own => localFields own 0 0
    | none => false),
  ("foundation.lookup.duplicate-first-dfs",
    match lookupLeaf dupLocals (), firstLeaf dupLocals () with
    | some a, some b => decide (a.consumed = 3 ∧ b.consumed = 3)
    | _, _ => false),
  ("foundation.advanceIn.empty-none",
    (advanceIn emptyCfg unitBounds unitNone unitStart () .empty).isNone),
  ("foundation.advanceIn.unmatched-leaf",
    (advanceIn emptyCfg boolBounds boolNone boolStart true (.leaf false {})).isNone),
  ("foundation.advanceTree.absent-preserves",
    fullMachineEq boolRoster
      (advanceTree emptyCfg boolBounds boolNone
        (startTree (.leaf false : Tree Bool) genesis) true)
      (startTree (.leaf false : Tree Bool) genesis)),
  ("foundation.start.empty.world-store",
    Parallel.worldEq emptyStart.world genesis && emptyStart.attempts.isEmpty &&
      match emptyStart.locals with | .empty => true | _ => false),
  ("foundation.start.unit.literal",
    fullMachineEq unitRoster unitStart startLiteral),
  ("foundation.start.empty.literal",
    fullMachineEq emptyRoster emptyStart emptyStartLiteral),
  ("foundation.skip.consumed-only",
    fullMachineEq unitRoster unitSkip skipMachine &&
      match lookupLeaf unitSkip.locals () with
      | some own =>
          localFields own 1 0 && Parallel.worldEq unitSkip.world genesis &&
            unitSkip.attempts.isEmpty
      | none => false),
  ("foundation.duplicate.selected-only",
    match dupAdvance.locals with
    | .fork (.leaf _ left) (.leaf _ right) =>
        decide (left.consumed = 4 ∧ right.consumed = 9) &&
          left.events.isEmpty && right.events.isEmpty &&
          left.failure.isNone && right.failure.isNone &&
          dupAdvance.attempts.isEmpty && Parallel.worldEq dupAdvance.world genesis
    | _ => false),
  ("foundation.run.empty.executed",
    match emptyRun with
    | .executed s m =>
        decide (s = []) && fullMachineEq emptyRoster m emptyStartLiteral
    | .refused _ _ _ => false),
  ("foundation.run.dup-catalog.base",
    emptyRefusedBase dupCfgEmpty (.base .configuration) genesis []),
  ("foundation.run.unit-empty-tree",
    unitRefusedBase unitTreeFail (.tree ⟨(), 1, 0⟩) genesis []),
  ("foundation.run.unknown-op.base",
    match unitUnknownRun with
    | .refused (.base (.structural () ⟨0, .interface .unknownOperation⟩)) w s =>
        decide (s = [()]) && Parallel.worldEq w genesis
    | _ => false),
  ("foundation.paths.encode.leaf", decide (encodeOne unitLeaf () = [])),
  ("foundation.paths.encode.left",
    decide (encodeOne fin2Fork (0 : Fin 2) = [.left])),
  ("foundation.paths.encode.right",
    decide (encodeOne fin2Fork (1 : Fin 2) = [.right])),
  ("foundation.paths.resolve.leaf",
    decide (resolve unitLeaf [] = .ok () ∧ leafOf unitLeaf [] = some ())),
  ("foundation.paths.resolve.empty",
    decide (resolve (Tree.empty : Tree Unit) [] = .error [])),
  ("foundation.paths.resolve.fork-nil",
    decide (resolve fin2Fork [] = .error [])),
  ("foundation.paths.decode.empty",
    decide (decodePaths unitLeaf [] = .ok [])),
  ("foundation.paths.decode.roundtrip",
    decide (decodePaths fin2Fork (encodePaths fin2Fork [0, 1]) = .ok [0, 1])),
  ("foundation.paths.decode.bad-fullpath",
    decide (decodePaths fin2Fork [badPath] = .error ⟨0, badPath⟩)),
  ("foundation.paths.decode.second-offset",
    decide (decodePaths fin2Fork badPaths = .error ⟨1, badPath⟩)),
  ("foundation.paths.run.decode-refused.world",
    match fin2DecodeRefuse with
    | .decodeRefused reason paths world =>
        decide (reason.tokenIndex = 1 ∧ reason.fullPath = badPath ∧ paths = badPaths) &&
          Parallel.worldEq world genesis
    | .decoded _ _ => false),
  ("foundation.paths.run.empty-decoded",
    match emptyPaths with
    | .decoded paths (.executed s m) =>
        decide (paths = [] ∧ s = []) && fullMachineEq emptyRoster m emptyStartLiteral
    | _ => false),
  ("foundation.flatten.start.unit",
    Nary.machineEq unitRoster (flattenMachine unitRoster unitStart) (Nary.start genesis)),
  ("foundation.flatten.start.empty",
    Nary.machineEq emptyRoster (flattenMachine emptyRoster emptyStart) (Nary.start genesis)),
  ("foundation.flatten.skip.full",
    Nary.machineEq unitRoster (flattenMachine unitRoster unitSkip)
      (Nary.Machine.skip (Nary.start (B := Unit) genesis) ())),
  ("foundation.obs.fullMachineEq.refl",
    fullMachineEq unitRoster unitStart unitStart),
  ("foundation.obs.canonical.consumed",
    decide (((canonicalLocals unitRoster unitStart).head?.map fun p => p.2.consumed) = some 0)),
  ("foundation.regroup.empty-unit-shape",
    decide (Tree.leaves ((Tree.empty : Tree Unit).fork unitLeaf) = Tree.leaves unitLeaf)),
  ("foundation.regroup.fork-assoc-leaves",
    decide (Tree.leaves (((Tree.leaf false).fork (Tree.leaf true)).fork (Tree.leaf false)) =
      Tree.leaves ((Tree.leaf false).fork ((Tree.leaf true).fork (Tree.leaf false)))))
]

def main : IO Unit := do
  if comparisons.isEmpty then
    throw (IO.userError "foundation comparisons empty")
  if !(comparisons.map Prod.fst).Nodup then
    throw (IO.userError "foundation comparison names are duplicated")
  for (name, passed) in comparisons do
    IO.println s!"{name}: {passed}"
  let failures := comparisons.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"foundation comparisons failed: {failures}")

#eval main

end DefiKernel.Nary.Tree.FoundationChecks
