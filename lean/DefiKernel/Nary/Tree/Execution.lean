import DefiKernel.Nary.Tree.Paths
import DefiKernel.Nary.Execution

/-! Recursive tree dispatch. `advanceIn` returns `none` when the token is absent
from the current subtree; `advanceTree` then keeps the original machine.
This does not flatten and does not call `Nary.advance`. -/
namespace DefiKernel.Nary.Tree
open Typed Composition

structure TreeMachine (B P A D : Type) where
  world : World P A D
  locals : LocalTree B P A D
  attempts : List (Nary.Attempt B P A D) := []

inductive TreeResult (B P A D : Type) where
  | refused (reason : TreeAdmissionFailure B P A D) (world : World P A D)
      (schedule : Schedule B)
  | executed (schedule : Schedule B) (machine : TreeMachine B P A D)

inductive PathResult (B P A D : Type) where
  | decodeRefused (reason : PathFailure) (paths : List Path) (world : World P A D)
  | decoded (paths : List Path) (result : TreeResult B P A D)

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Genesis locals; the entire initial world and capability store are retained. -/
def startTree (tree : Tree B) (initial : World P A D) : TreeMachine B P A D :=
  ⟨initial, emptyLocals tree, []⟩

def lookupLeaf : LocalTree B P A D → B → Option (Interleaving.LocalState P A D)
  | .empty, _ => none
  | .leaf id localState, b => if id = b then some localState else none
  | .fork left right, b =>
    match lookupLeaf left b with
    | some localState => some localState
    | none => lookupLeaf right b

/-- Raw totality: first depth-first match. Missing identity is none. -/
def firstLeaf : LocalTree B P A D → B → Option (Interleaving.LocalState P A D) :=
  lookupLeaf

def skipSelected (own : Interleaving.LocalState P A D) : Interleaving.LocalState P A D :=
  { own with consumed := own.consumed + 1 }

def refusedConsumed (own : Interleaving.LocalState P A D) : Nat :=
  own.consumed + 1

def refuseSelected (own : Interleaving.LocalState P A D) (inv : Invocation P A D)
    (reason : Composition.Failure) : Interleaving.LocalState P A D :=
  { own with
    consumed := refusedConsumed own
    failure := some ⟨own.nextIndex, some (.invoke inv), reason⟩ }

def anyFailed : LocalTree B P A D → Bool
  | .empty => false
  | .leaf _ own => own.failure.isSome
  | .fork left right => anyFailed left || anyFailed right

def acceptSelected (own : Interleaving.LocalState P A D) (inv : Invocation P A D)
    (before : World P A D) (result : StepResult P A D) : Interleaving.LocalState P A D :=
  ⟨own.consumed + 1,
    own.events ++ [⟨own.nextIndex, .invoke inv, before,
      { result with receipt := result.receipt }⟩],
    own.outputs ++ result.outputs, own.nextIndex + 1, none⟩

def publishedWorld (result : StepResult P A D) : World P A D :=
  result.world

def selectedLeftMember (b : B) (leftShape : Tree B) : Bool :=
  decide (b ∈ Tree.leaves leftShape)

def rebuildFork (selectedLeft : Bool) (leftUpdated rightUpdated
    left right : LocalTree B P A D) : LocalTree B P A D :=
  if selectedLeft then .fork leftUpdated right else .fork left rightUpdated

def leafHistory (own : Interleaving.LocalState P A D) :
    List (OutputObservation A) :=
  own.outputs

/-- Not the production leaf argument. M06 switches stepLeaf to this walk. -/
def concatenatedOutputs : LocalTree B P A D → List (OutputObservation A)
  | .empty => []
  | .leaf _ own => own.outputs
  | .fork left right => concatenatedOutputs left ++ concatenatedOutputs right

def siblingFailureBlocks (_locals : LocalTree B P A D) : Bool :=
  false

def stepLeaf (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B)
    (own : Interleaving.LocalState P A D) :
    Interleaving.LocalState P A D × World P A D × List (Nary.Attempt B P A D) :=
  if own.failure.isSome then
    (skipSelected own, m.world, m.attempts)
  else
    match (branches b)[own.consumed]? with
    | none => (skipSelected own, m.world, m.attempts)
    | some inv =>
      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex
        (leafHistory own) (.invoke inv) m.world
      match outcome with
      | .error reason =>
        (refuseSelected own inv reason, m.world,
          m.attempts ++ [⟨b, own.nextIndex, inv, m.world, .error reason⟩])
      | .ok result =>
        (acceptSelected own inv m.world result, publishedWorld result,
          m.attempts ++ [⟨b, own.nextIndex, inv, m.world, .ok result⟩])

/-- Recurse a subtree. `none` means the token is absent from this subtree.
The reconstructed locals have the same shape as the argument. An unmatched
leaf or empty node does not return the parent machine. -/
def advanceIn (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B) :
    LocalTree B P A D →
      Option (LocalTree B P A D × World P A D × List (Nary.Attempt B P A D))
  | .empty => none
  | .leaf id own =>
    if id = b then
      let (own', world', attempts') := stepLeaf cfg boundaries branches m b own
      some (.leaf id own', world', attempts')
    else none
  | .fork left right =>
    if siblingFailureBlocks (.fork left right) then
      some (.fork left right, m.world, m.attempts)
    else
      let selectedLeft := selectedLeftMember b left.shape
      if selectedLeft then
        match advanceIn cfg boundaries branches m b left with
        | some (leftUpdated, world', attempts') =>
          some (rebuildFork true leftUpdated right left right, world', attempts')
        | none => none
      else
        match advanceIn cfg boundaries branches m b right with
        | some (rightUpdated, world', attempts') =>
          some (rebuildFork false left rightUpdated left right, world', attempts')
        | none => none

/-- Absent token: return the entire original machine, including nested empty
and unmatched paths. First depth-first match still updates a duplicate leaf. -/
def advanceTree (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B) :
    TreeMachine B P A D :=
  match advanceIn cfg boundaries branches m b m.locals with
  | none => m
  | some (locals', world', attempts') =>
    { m with locals := locals', world := world', attempts := attempts' }

def continueTree (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (schedule : Schedule B) :
    TreeMachine B P A D :=
  schedule.foldl (advanceTree cfg boundaries branches) m

def runTreePrefix (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (tree : Tree B) (branches : Branches B P A D)
    (schedule : Schedule B) : TreeMachine B P A D :=
  continueTree cfg boundaries branches (startTree tree initial) schedule

def runTree (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (initial : World P A D) (tree : Tree B) (schedule : Schedule B) :
    TreeResult B P A D :=
  match admitTree cfg roster boundaries branches schedule tree with
  | .error reason => .refused reason initial schedule
  | .ok _ => .executed schedule (runTreePrefix cfg boundaries initial tree branches schedule)

def runTreePaths (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (initial : World P A D) (tree : Tree B) (paths : List Path) :
    PathResult B P A D :=
  match decodePaths tree paths with
  | .error reason => .decodeRefused reason paths initial
  | .ok schedule => .decoded paths (runTree cfg roster boundaries branches initial tree schedule)

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false
set_option linter.dupNamespace false

theorem startTree_world (tree : Tree B) (initial : World P A D) :
    (startTree tree initial).world = initial := rfl

theorem startTree_attempts (tree : Tree B) (initial : World P A D) :
    (startTree tree initial).attempts = [] := rfl

theorem startTree_locals (tree : Tree B) (initial : World P A D) :
    (startTree tree initial).locals = emptyLocals tree := rfl

theorem startTree_shape (tree : Tree B) (initial : World P A D) :
    (startTree tree initial).locals.shape = tree :=
  emptyLocals_shape tree

theorem lookupLeaf_empty (b : B) :
    lookupLeaf (LocalTree.empty : LocalTree B P A D) b = none := rfl

theorem lookupLeaf_leaf_eq (b : B) (own : Interleaving.LocalState P A D) :
    lookupLeaf (.leaf b own) b = some own := by
  simp [lookupLeaf]

theorem lookupLeaf_leaf_ne (id b : B) (own : Interleaving.LocalState P A D) (h : id ≠ b) :
    lookupLeaf (.leaf id own) b = none := by
  simp [lookupLeaf, h]

theorem firstLeaf_eq_lookupLeaf (locals : LocalTree B P A D) (b : B) :
    firstLeaf locals b = lookupLeaf locals b := rfl

theorem siblingFailureBlocks_false (locals : LocalTree B P A D) :
    siblingFailureBlocks locals = false := rfl

theorem rebuildFork_true (leftUpdated rightUpdated left right : LocalTree B P A D) :
    rebuildFork true leftUpdated rightUpdated left right = .fork leftUpdated right := rfl

theorem rebuildFork_false (leftUpdated rightUpdated left right : LocalTree B P A D) :
    rebuildFork false leftUpdated rightUpdated left right = .fork left rightUpdated := rfl

theorem leafHistory_eq (own : Interleaving.LocalState P A D) :
    leafHistory own = own.outputs := rfl

theorem publishedWorld_eq (result : StepResult P A D) :
    publishedWorld result = result.world := rfl

theorem skipSelected_consumed (own : Interleaving.LocalState P A D) :
    (skipSelected own).consumed = own.consumed + 1 := rfl

theorem skipSelected_world_fields (own : Interleaving.LocalState P A D) :
    (skipSelected own).events = own.events ∧
    (skipSelected own).outputs = own.outputs ∧
    (skipSelected own).nextIndex = own.nextIndex ∧
    (skipSelected own).failure = own.failure :=
  ⟨rfl, rfl, rfl, rfl⟩

theorem advanceIn_empty (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B) :
    advanceIn cfg boundaries branches m b .empty = none := rfl

theorem advanceIn_leaf_ne (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (id b : B)
    (own : Interleaving.LocalState P A D) (h : id ≠ b) :
    advanceIn cfg boundaries branches m b (.leaf id own) = none := by
  simp [advanceIn, h]

theorem advanceTree_none (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B)
    (h : advanceIn cfg boundaries branches m b m.locals = none) :
    advanceTree cfg boundaries branches m b = m := by
  simp [advanceTree, h]

theorem continueTree_nil (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) :
    continueTree cfg boundaries branches m [] = m := rfl

theorem continueTree_cons (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (b : B) (rest : Schedule B) :
    continueTree cfg boundaries branches m (b :: rest) =
      continueTree cfg boundaries branches (advanceTree cfg boundaries branches m b) rest :=
  rfl

theorem continueTree_append (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (branches : Branches B P A D) (m : TreeMachine B P A D) (s t : Schedule B) :
    continueTree cfg boundaries branches m (s ++ t) =
      continueTree cfg boundaries branches (continueTree cfg boundaries branches m s) t :=
  List.foldl_append

theorem runTree_refused (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (initial : World P A D) (tree : Tree B) (schedule : Schedule B)
    (reason : TreeAdmissionFailure B P A D)
    (h : admitTree cfg roster boundaries branches schedule tree = .error reason) :
    runTree cfg roster boundaries branches initial tree schedule =
      .refused reason initial schedule := by
  simp [runTree, h]

theorem runTree_executed (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (initial : World P A D) (tree : Tree B) (schedule : Schedule B)
    (fp : List (B × Parallel.Footprint P A D))
    (h : admitTree cfg roster boundaries branches schedule tree = .ok fp) :
    runTree cfg roster boundaries branches initial tree schedule =
      .executed schedule (runTreePrefix cfg boundaries initial tree branches schedule) := by
  simp [runTree, h]

theorem runTreePaths_decodeRefused (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (initial : World P A D) (tree : Tree B) (paths : List Path)
    (reason : PathFailure)
    (h : decodePaths tree paths = .error reason) :
    runTreePaths cfg roster boundaries branches initial tree paths =
      .decodeRefused reason paths initial := by
  simp [runTreePaths, h]

theorem runTreePaths_decoded (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (initial : World P A D) (tree : Tree B) (paths : List Path)
    (schedule : Schedule B)
    (h : decodePaths tree paths = .ok schedule) :
    runTreePaths cfg roster boundaries branches initial tree paths =
      .decoded paths (runTree cfg roster boundaries branches initial tree schedule) := by
  simp [runTreePaths, h]

end DefiKernel.Nary.Tree
