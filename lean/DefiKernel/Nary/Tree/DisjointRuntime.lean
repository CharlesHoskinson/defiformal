import DefiKernel.Nary.Tree.Observation
import DefiKernel.Parallel.Execution

/-! Pairwise compatibility diagnostics and independent isolated references.
`Parallel.checkCompatibility` is the runtime checker. `Parallel.Compatible` is
referenced only from the proof-only Compatibility module. Ordinary `runTree`
does not consult this API. -/
namespace DefiKernel.Nary.Tree
open Typed Composition

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

structure PairConflict (B P A D : Type) where
  left : B
  right : B
  kind : Parallel.ConflictKind
  cell : Cell P A D
  deriving DecidableEq, Repr

/-- Same three `firstOverlap` tests as `Parallel.checkCompatibility`, retaining both
roster identities. Direct `match` on `checkCompatibility` is avoided because its
`PUnit` universe is not a Tree return type. -/
def checkPair (leftId rightId : B) (left right : Parallel.Footprint P A D) :
    Except (PairConflict B P A D) Unit :=
  match Parallel.firstOverlap left.writes right.writes with
  | some cell => .error ⟨leftId, rightId, .writeWrite, cell⟩
  | none =>
    match Parallel.firstOverlap left.writes right.reads with
    | some cell => .error ⟨leftId, rightId, .leftWriteRightRead, cell⟩
    | none =>
      match Parallel.firstOverlap right.writes left.reads with
      | some cell => .error ⟨leftId, rightId, .rightWriteLeftRead, cell⟩
      | none => .ok ()

def checkAgainst (head : B × Parallel.Footprint P A D) :
    List (B × Parallel.Footprint P A D) → Except (PairConflict B P A D) Unit
  | [] => .ok ()
  | other :: others =>
    match checkPair head.1 other.1 head.2 other.2 with
    | .error err => .error err
    | .ok _ => checkAgainst head others

/-- Roster-order unordered pairs: each earlier identity against each later one.
The `assoc` argument is the admitted association retained for callers. -/
def checkPairwiseFrom (assoc : List (B × Parallel.Footprint P A D)) :
    List (B × Parallel.Footprint P A D) → Except (PairConflict B P A D) Unit
  | [] => .ok ()
  | head :: rest =>
    match checkAgainst head rest with
    | .error err => .error err
    | .ok _ => checkPairwiseFrom assoc rest

def checkPairwise (assoc : List (B × Parallel.Footprint P A D)) :
    Except (PairConflict B P A D) Unit :=
  checkPairwiseFrom assoc assoc

def footprintOf (assoc : List (B × Parallel.Footprint P A D)) (b : B) :
    Parallel.Footprint P A D :=
  match assoc.find? (fun pair => decide (pair.1 = b)) with
  | some pair => pair.2
  | none => Parallel.Footprint.empty

def unionLeaves (assoc : List (B × Parallel.Footprint P A D)) : Tree B → Parallel.Footprint P A D
  | .empty => .empty
  | .leaf b => footprintOf assoc b
  | .fork left right => Parallel.Footprint.append (unionLeaves assoc left) (unionLeaves assoc right)

/-- Named balance selection. M13 mutates only the middle branch. The nonneg
proof below must inhabit both the baseline type (0 ≤ right.balance) and the
sum-mutant type (0 ≤ left.balance + right.balance). `first` tries the right
conjunct, then `add_nonneg`. That is a proof/type dependency, not a compiled
Tree feature. -/
def mergeBalance (leftFp rightFp : Parallel.Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D) : ℚ :=
  if c ∈ leftFp.writes then left.state.balance c
  else if c ∈ rightFp.writes then right.state.balance c
  else initial.state.balance c

def mergeNonneg (leftFp rightFp : Parallel.Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D) :
    0 ≤ mergeBalance leftFp rightFp initial left right c := by
  have hl := left.state.nonneg c
  have hr := right.state.nonneg c
  have hi := initial.state.nonneg c
  unfold mergeBalance
  split
  · exact hl
  · split
    · first | exact hr | exact add_nonneg hl hr
    · exact hi

/-- Owner-selecting merge. Never sums two complete balance states in the
baseline. Unowned cells and the entire capability store stay at the initial
world. The nonneg proof is independent of the selected numeric branch. -/
def mergeOwned (leftFp rightFp : Parallel.Footprint P A D)
    (initial left right : World P A D) : World P A D :=
  ⟨⟨mergeBalance leftFp rightFp initial left right,
    mergeNonneg leftFp rightFp initial left right⟩,
    initial.capabilities⟩

structure IsolatedRef (P A D : Type) where
  world : World P A D
  cursor : Cursor P A D

def runIsolatedLeaf (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Parallel.Branch P A D) : IsolatedRef P A D :=
  let cursor := Parallel.runBranch cfg boundary initial branch
  ⟨cursor.world, cursor⟩

def isolatedConsumed (branch : Parallel.Branch P A D) : Nat :=
  branch.length

def isolatedCanonicalLocal (cursor : Cursor P A D) (branch : Parallel.Branch P A D) :
    CanonicalLocal P A D :=
  ⟨isolatedConsumed branch, Parallel.observeBranch cursor⟩

def runIsolatedTree (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D)
    (assoc : List (B × Parallel.Footprint P A D)) :
    Tree B → World P A D × List (B × CanonicalLocal P A D)
  | .empty => (initial, [])
  | .leaf b =>
    let ran := runIsolatedLeaf cfg (boundaries b) initial (branches b)
    (ran.world, [(b, isolatedCanonicalLocal ran.cursor (branches b))])
  | .fork left right =>
    let (lw, ll) := runIsolatedTree cfg boundaries initial branches assoc left
    let (rw, rl) := runIsolatedTree cfg boundaries initial branches assoc right
    (mergeOwned (unionLeaves assoc left) (unionLeaves assoc right) initial lw rw,
      ll ++ rl)

/-- Flat isolated reference: each roster identity independently from the same
entry world. World fold uses owner-selecting merge, never a full-state sum. -/
def foldIsolatedWorld (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D)
    (assoc : List (B × Parallel.Footprint P A D)) : List B → World P A D
  | [] => initial
  | b :: rest =>
    let ran := runIsolatedLeaf cfg (boundaries b) initial (branches b)
    mergeOwned (footprintOf assoc b) (unionLeaves assoc
        (rest.foldl (fun t x => t.fork (.leaf x)) Tree.empty))
      initial ran.world
      (foldIsolatedWorld cfg boundaries initial branches assoc rest)

def isolatedLocals (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D) (order : List B) :
    List (B × CanonicalLocal P A D) :=
  order.map fun b =>
    let ran := runIsolatedLeaf cfg (boundaries b) initial (branches b)
    (b, isolatedCanonicalLocal ran.cursor (branches b))

def isolatedCanonical (roster : Roster B) (cfg : Config P A D)
    (boundaries : Boundaries B P A D) (initial : World P A D)
    (branches : Branches B P A D) (assoc : List (B × Parallel.Footprint P A D))
    (tree : Tree B) : CanonicalObservation B P A D :=
  ⟨(runIsolatedTree cfg boundaries initial branches assoc tree).1,
    isolatedLocals cfg boundaries initial branches roster.order⟩

def admitIsolated (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (schedule : Schedule B) (tree : Tree B) :
    Except (TreeAdmissionFailure B P A D ⊕ PairConflict B P A D)
      (List (B × Parallel.Footprint P A D)) :=
  match admitTree cfg roster boundaries branches schedule tree with
  | .error reason => .error (.inl reason)
  | .ok assoc =>
    match checkPairwise assoc with
    | .error conflict => .error (.inr conflict)
    | .ok _ => .ok assoc

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false
set_option linter.dupNamespace false
set_option linter.defProp false
set_option linter.unusedTactic false
set_option linter.unreachableTactic false

theorem checkPair_ok (leftId rightId : B) (left right : Parallel.Footprint P A D)
    (h : Parallel.checkCompatibility left right = .ok ⟨⟩) :
    checkPair leftId rightId left right = .ok () := by
  have hc := (Parallel.checkCompatibility_ok_iff left right).mp h
  have hww := (Parallel.firstOverlap_none_iff left.writes right.writes).mpr hc.1
  have hlr := (Parallel.firstOverlap_none_iff left.writes right.reads).mpr hc.2.1
  have hrl := (Parallel.firstOverlap_none_iff right.writes left.reads).mpr hc.2.2
  simp [checkPair, hww, hlr, hrl]

theorem checkPair_conflict_writeWrite (leftId rightId : B)
    (left right : Parallel.Footprint P A D) (cell : Cell P A D)
    (h : Parallel.firstOverlap left.writes right.writes = some cell) :
    checkPair leftId rightId left right = .error ⟨leftId, rightId, .writeWrite, cell⟩ := by
  simp [checkPair, h]

theorem checkAgainst_nil (head : B × Parallel.Footprint P A D) :
    checkAgainst head [] = .ok () := rfl

theorem checkPairwise_nil :
    checkPairwise ([] : List (B × Parallel.Footprint P A D)) = .ok () := rfl

theorem footprintOf_nil (b : B) :
    footprintOf ([] : List (B × Parallel.Footprint P A D)) b = .empty := rfl

theorem footprintOf_cons_eq (b : B) (fp : Parallel.Footprint P A D)
    (rest : List (B × Parallel.Footprint P A D)) :
    footprintOf ((b, fp) :: rest) b = fp := by
  simp [footprintOf]

theorem footprintOf_cons_ne (id b : B) (fp : Parallel.Footprint P A D)
    (rest : List (B × Parallel.Footprint P A D)) (h : id ≠ b) :
    footprintOf ((id, fp) :: rest) b = footprintOf rest b := by
  simp [footprintOf, h]

theorem unionLeaves_empty (assoc : List (B × Parallel.Footprint P A D)) :
    unionLeaves assoc (Tree.empty : Tree B) = .empty := rfl

theorem unionLeaves_leaf (assoc : List (B × Parallel.Footprint P A D)) (b : B) :
    unionLeaves assoc (Tree.leaf b) = footprintOf assoc b := rfl

theorem unionLeaves_fork (assoc : List (B × Parallel.Footprint P A D))
    (left right : Tree B) :
    unionLeaves assoc (left.fork right) =
      Parallel.Footprint.append (unionLeaves assoc left) (unionLeaves assoc right) :=
  rfl

theorem mergeBalance_left (leftFp rightFp : Parallel.Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D) (h : c ∈ leftFp.writes) :
    mergeBalance leftFp rightFp initial left right c = left.state.balance c := by
  simp [mergeBalance, h]

theorem mergeBalance_right (leftFp rightFp : Parallel.Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D)
    (hl : c ∉ leftFp.writes) (hr : c ∈ rightFp.writes) :
    mergeBalance leftFp rightFp initial left right c = right.state.balance c := by
  simp [mergeBalance, hl, hr]

theorem mergeBalance_outside (leftFp rightFp : Parallel.Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D)
    (hl : c ∉ leftFp.writes) (hr : c ∉ rightFp.writes) :
    mergeBalance leftFp rightFp initial left right c = initial.state.balance c := by
  simp [mergeBalance, hl, hr]

theorem mergeOwned_store (leftFp rightFp : Parallel.Footprint P A D)
    (initial left right : World P A D) :
    (mergeOwned leftFp rightFp initial left right).capabilities = initial.capabilities :=
  rfl

theorem mergeOwned_balance (leftFp rightFp : Parallel.Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D) :
    (mergeOwned leftFp rightFp initial left right).state.balance c =
      mergeBalance leftFp rightFp initial left right c :=
  rfl

theorem runIsolatedLeaf_world (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Parallel.Branch P A D) :
    (runIsolatedLeaf cfg boundary initial branch).world =
      (Parallel.runBranch cfg boundary initial branch).world :=
  rfl

theorem runIsolatedLeaf_cursor (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Parallel.Branch P A D) :
    (runIsolatedLeaf cfg boundary initial branch).cursor =
      Parallel.runBranch cfg boundary initial branch :=
  rfl

theorem isolatedConsumed_eq (branch : Parallel.Branch P A D) :
    isolatedConsumed branch = branch.length :=
  rfl

theorem runIsolatedTree_empty (cfg : Config P A D) (boundaries : Boundaries B P A D)
    (initial : World P A D) (branches : Branches B P A D)
    (assoc : List (B × Parallel.Footprint P A D)) :
    runIsolatedTree cfg boundaries initial branches assoc .empty = (initial, []) :=
  rfl

theorem admitIsolated_base (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (schedule : Schedule B) (tree : Tree B)
    (reason : TreeAdmissionFailure B P A D)
    (h : admitTree cfg roster boundaries branches schedule tree = .error reason) :
    admitIsolated cfg roster boundaries branches schedule tree = .error (.inl reason) := by
  simp [admitIsolated, h]

theorem admitIsolated_conflict (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (schedule : Schedule B) (tree : Tree B)
    (assoc : List (B × Parallel.Footprint P A D)) (conflict : PairConflict B P A D)
    (hAdmit : admitTree cfg roster boundaries branches schedule tree = .ok assoc)
    (hPair : checkPairwise assoc = .error conflict) :
    admitIsolated cfg roster boundaries branches schedule tree = .error (.inr conflict) := by
  simp [admitIsolated, hAdmit, hPair]

theorem admitIsolated_ok (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (schedule : Schedule B) (tree : Tree B)
    (assoc : List (B × Parallel.Footprint P A D))
    (hAdmit : admitTree cfg roster boundaries branches schedule tree = .ok assoc)
    (hPair : checkPairwise assoc = .ok ()) :
    admitIsolated cfg roster boundaries branches schedule tree = .ok assoc := by
  simp [admitIsolated, hAdmit, hPair]

end DefiKernel.Nary.Tree
