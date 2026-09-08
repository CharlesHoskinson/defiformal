import DefiKernel.Nary.Schedule
import DefiKernel.Interleaving.Execution

/-! Finite participant trees and canonical admission. Base Nary admission runs first;
tree multiplicity is roster-first expected-one. Compatibility is not required. -/
namespace DefiKernel.Nary.Tree
open Typed Composition

inductive Tree (B : Type) where
  | empty
  | leaf (b : B)
  | fork (left right : Tree B)
  deriving DecidableEq, Repr

inductive LocalTree (B P A D : Type) where
  | empty
  | leaf (b : B) (localState : Interleaving.LocalState P A D)
  | fork (left right : LocalTree B P A D)

structure TreeMultiplicity (B : Type) where
  participant : B
  expected : Nat
  observed : Nat
  deriving DecidableEq, Repr

inductive TreeAdmissionFailure (B P A D : Type) where
  | base (reason : Nary.AdmissionFailure B P A D)
  | tree (failure : TreeMultiplicity B)
  deriving DecidableEq, Repr

variable {B P A D : Type} [DecidableEq B]

def Tree.leaves : Tree B → List B
  | .empty => []
  | .leaf b => [b]
  | .fork left right => Tree.leaves left ++ Tree.leaves right

def Tree.count (tree : Tree B) (b : B) : Nat :=
  (Tree.leaves tree).count b

def emptyLocals : Tree B → LocalTree B P A D
  | .empty => .empty
  | .leaf b => .leaf b {}
  | .fork left right => .fork (emptyLocals left) (emptyLocals right)

def LocalTree.shape : LocalTree B P A D → Tree B
  | .empty => .empty
  | .leaf b _ => .leaf b
  | .fork left right => .fork left.shape right.shape

/-- Roster-order first mismatch. Expected count is exactly one.
No Fintype B and no Finset.toList enumeration. -/
def checkTreeFrom (tree : Tree B) : List B → Except (TreeMultiplicity B) Unit
  | [] => .ok ()
  | b :: rest =>
    let observed := Tree.count tree b
    if observed ≠ (1 : Nat) then .error ⟨b, 1, observed⟩
    else checkTreeFrom tree rest

def checkTree (roster : Roster B) (tree : Tree B) :
    Except (TreeMultiplicity B) Unit :=
  checkTreeFrom tree roster.order

variable [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- Base Nary admission first, then tree multiplicities.
Compatibility is not required. -/
def admitTree (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (schedule : Schedule B) (tree : Tree B) :
    Except (TreeAdmissionFailure B P A D) (List (B × Parallel.Footprint P A D)) :=
  match Nary.admit cfg roster boundaries branches schedule with
  | .error reason => .error (.base reason)
  | .ok footprints =>
    match checkTree roster tree with
    | .error failure => .error (.tree failure)
    | .ok _ => .ok footprints

/-- Every roster identity occurs in exactly one leaf. Roster.complete implies there
are no extra identities. Empty root is well formed only when B is uninhabited. -/
def WellFormed (roster : Roster B) (tree : Tree B) : Prop :=
  ∀ b ∈ roster.order, Tree.count tree b = 1

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.dupNamespace false

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem leaves_empty : Tree.leaves (Tree.empty : Tree B) = [] := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem leaves_leaf (b : B) : Tree.leaves (Tree.leaf b) = [b] := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem leaves_fork (left right : Tree B) :
    Tree.leaves (left.fork right) = Tree.leaves left ++ Tree.leaves right := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem count_eq_leaves (tree : Tree B) (b : B) :
    Tree.count tree b = (Tree.leaves tree).count b := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem emptyLocals_shape (tree : Tree B) :
    (emptyLocals tree : LocalTree B P A D).shape = tree := by
  induction tree with
  | empty => rfl
  | leaf b => rfl
  | fork left right ihL ihR =>
    simp [emptyLocals, LocalTree.shape, ihL, ihR]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem checkTreeFrom_nil (tree : Tree B) :
    checkTreeFrom tree [] = .ok () := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem checkTreeFrom_ok_iff (tree : Tree B) :
    ∀ order, checkTreeFrom tree order = .ok () ↔
      ∀ b ∈ order, Tree.count tree b = 1
  | [] => by simp [checkTreeFrom]
  | b :: rest => by
    by_cases h : Tree.count tree b = 1
    · simp [checkTreeFrom, h, checkTreeFrom_ok_iff tree rest]
    · constructor
      · intro hok
        simp [checkTreeFrom, h] at hok
      · intro hall
        exact (h (hall b (by simp))).elim

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem checkTreeFrom_error_head (tree : Tree B) (b : B) (rest : List B)
    (h : Tree.count tree b ≠ 1) :
    checkTreeFrom tree (b :: rest) = .error ⟨b, 1, Tree.count tree b⟩ := by
  simp [checkTreeFrom, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem checkTree_ok_iff (roster : Roster B) (tree : Tree B) :
    checkTree roster tree = .ok () ↔ ∀ b ∈ roster.order, Tree.count tree b = 1 := by
  simp [checkTree, checkTreeFrom_ok_iff]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem wellFormed_iff_check (roster : Roster B) (tree : Tree B) :
    WellFormed roster tree ↔ checkTree roster tree = .ok () :=
  (checkTree_ok_iff roster tree).symm

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem wellFormed_count (roster : Roster B) (tree : Tree B)
    (h : WellFormed roster tree) (b : B) : Tree.count tree b = 1 :=
  h b (roster.complete b)

theorem admitTree_base (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (schedule : Schedule B) (tree : Tree B)
    (reason : Nary.AdmissionFailure B P A D)
    (h : Nary.admit cfg roster boundaries branches schedule = .error reason) :
    admitTree cfg roster boundaries branches schedule tree = .error (.base reason) := by
  simp [admitTree, h]

theorem admitTree_tree (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (schedule : Schedule B) (tree : Tree B)
    (fp : List (B × Parallel.Footprint P A D))
    (failure : TreeMultiplicity B)
    (hAdmit : Nary.admit cfg roster boundaries branches schedule = .ok fp)
    (hTree : checkTree roster tree = .error failure) :
    admitTree cfg roster boundaries branches schedule tree = .error (.tree failure) := by
  simp [admitTree, hAdmit, hTree]

theorem admitTree_ok (cfg : Config P A D) (roster : Roster B)
    (boundaries : Boundaries B P A D) (branches : Branches B P A D)
    (schedule : Schedule B) (tree : Tree B)
    (fp : List (B × Parallel.Footprint P A D))
    (hAdmit : Nary.admit cfg roster boundaries branches schedule = .ok fp)
    (hTree : checkTree roster tree = .ok ()) :
    admitTree cfg roster boundaries branches schedule tree = .ok fp := by
  simp [admitTree, hAdmit, hTree]

end DefiKernel.Nary.Tree
