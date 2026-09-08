import DefiKernel.Nary.Tree.Execution
import DefiKernel.Nary.Observation
import DefiKernel.Parallel.Observation

/-! Flattening is an observation conversion, never the production dispatcher.
Full comparison retains world, store, every local field including consumed,
raw events and global attempts. -/
namespace DefiKernel.Nary.Tree
open Typed Composition

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def emptyLocal : Interleaving.LocalState P A D := {}

def collectLocals : LocalTree B P A D → List (B × Interleaving.LocalState P A D)
  | .empty => []
  | .leaf b localState => [(b, localState)]
  | .fork left right => collectLocals left ++ collectLocals right

def lookupCollected (pairs : List (B × Interleaving.LocalState P A D)) (b : B) :
    Interleaving.LocalState P A D :=
  match pairs.find? (fun pair => decide (pair.1 = b)) with
  | some pair => pair.2
  | none => emptyLocal

/-- Specification conversion only. Not the production dispatch path. -/
def flattenMachine (roster : Roster B) (tm : TreeMachine B P A D) : Nary.Machine B P A D :=
  let pairs := collectLocals tm.locals
  ⟨tm.world, fun b => lookupCollected pairs b, tm.attempts⟩

def Rep (roster : Roster B) (tm : TreeMachine B P A D) (m : Nary.Machine B P A D) : Prop :=
  Nary.MachineEquivalent roster (flattenMachine roster tm) m

structure CanonicalLocal (P A D : Type) where
  consumed : Nat
  observation : Parallel.BranchObservation P A D
  deriving DecidableEq

def toCanonicalLocal (localState : Interleaving.LocalState P A D)
    (world : World P A D) : CanonicalLocal P A D :=
  ⟨localState.consumed, Parallel.observeBranch (localState.toCursor world)⟩

def canonicalLocals (roster : Roster B) (tm : TreeMachine B P A D) :
    List (B × CanonicalLocal P A D) :=
  roster.order.map fun b =>
    (b, toCanonicalLocal (lookupCollected (collectLocals tm.locals) b) tm.world)

structure CanonicalObservation (B P A D : Type) where
  world : World P A D
  locals : List (B × CanonicalLocal P A D)

def canonicalOf (roster : Roster B) (tm : TreeMachine B P A D) :
    CanonicalObservation B P A D :=
  ⟨tm.world, canonicalLocals roster tm⟩

def canonicalReceiptEq (left right : Receipt P A D) : Bool :=
  decide (left = right)

def canonicalEventEq (left right : Parallel.EventObservation P A D) : Bool :=
  decide (left.index = right.index) && decide (left.step = right.step) &&
    canonicalReceiptEq left.receipt right.receipt &&
    decide (left.outputs = right.outputs)

def canonicalEventsEq : List (Parallel.EventObservation P A D) →
    List (Parallel.EventObservation P A D) → Bool
  | [], [] => true
  | a :: as, b :: bs => canonicalEventEq a b && canonicalEventsEq as bs
  | _, _ => false

def canonicalBranchEq (left right : Parallel.BranchObservation P A D) : Bool :=
  canonicalEventsEq left.events right.events &&
    decide (left.outputs = right.outputs) &&
    decide (left.nextIndex = right.nextIndex) &&
    decide (left.failure = right.failure)

def canonicalLocalEq (left right : CanonicalLocal P A D) : Bool :=
  decide (left.consumed = right.consumed) &&
    canonicalBranchEq left.observation right.observation

def canonicalLocalsEq : List (B × CanonicalLocal P A D) →
    List (B × CanonicalLocal P A D) → Bool
  | [], [] => true
  | a :: as, b :: bs =>
    decide (a.1 = b.1) && canonicalLocalEq a.2 b.2 && canonicalLocalsEq as bs
  | _, _ => false

def canonicalEq (left right : CanonicalObservation B P A D) : Bool :=
  Parallel.worldEq left.world right.world &&
    canonicalLocalsEq left.locals right.locals

def fullAttemptsConjunct (left right : List (Nary.Attempt B P A D)) : Bool :=
  Nary.attemptsEq left right

/-- Full comparison uses world, roster locals including consumed, and this
attempt conjunct. It does not delegate production dispatch to flattenMachine. -/
def fullMachineEq (roster : Roster B) (left right : TreeMachine B P A D) : Bool :=
  let l := flattenMachine roster left
  let r := flattenMachine roster right
  Parallel.worldEq l.world r.world &&
    Nary.localsEq roster.order l.locals r.locals &&
    fullAttemptsConjunct left.attempts right.attempts

def fullResultEq (roster : Roster B) (left right : TreeResult B P A D) : Bool :=
  match left, right with
  | .refused lr lw ls, .refused rr rw rs =>
    decide (lr = rr) && Parallel.worldEq lw rw && decide (ls = rs)
  | .executed ls lm, .executed rs rm =>
    decide (ls = rs) && fullMachineEq roster lm rm
  | _, _ => false

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false
set_option linter.dupNamespace false

theorem emptyLocal_eq : (emptyLocal : Interleaving.LocalState P A D) = {} := rfl

theorem collectLocals_empty :
    collectLocals (LocalTree.empty : LocalTree B P A D) = [] := rfl

theorem collectLocals_leaf (b : B) (own : Interleaving.LocalState P A D) :
    collectLocals (.leaf b own) = [(b, own)] := rfl

theorem collectLocals_fork (left right : LocalTree B P A D) :
    collectLocals (.fork left right) = collectLocals left ++ collectLocals right := rfl

theorem lookupCollected_nil (b : B) :
    lookupCollected ([] : List (B × Interleaving.LocalState P A D)) b = emptyLocal := rfl

theorem flattenMachine_world (roster : Roster B) (tm : TreeMachine B P A D) :
    (flattenMachine roster tm).world = tm.world := rfl

theorem flattenMachine_attempts (roster : Roster B) (tm : TreeMachine B P A D) :
    (flattenMachine roster tm).attempts = tm.attempts := rfl

theorem flattenMachine_locals (roster : Roster B) (tm : TreeMachine B P A D) (b : B) :
    (flattenMachine roster tm).locals b =
      lookupCollected (collectLocals tm.locals) b := rfl

theorem lookupCollected_cons_eq (b : B) (own : Interleaving.LocalState P A D)
    (rest : List (B × Interleaving.LocalState P A D)) :
    lookupCollected ((b, own) :: rest) b = own := by
  simp [lookupCollected]

theorem lookupCollected_cons_ne (id b : B) (own : Interleaving.LocalState P A D)
    (rest : List (B × Interleaving.LocalState P A D)) (h : id ≠ b) :
    lookupCollected ((id, own) :: rest) b = lookupCollected rest b := by
  simp [lookupCollected, h]

theorem find?_collectLocals (locals : LocalTree B P A D) (b : B) :
    (collectLocals locals).find? (fun p => decide (p.1 = b)) =
      (lookupLeaf locals b).map (fun own => (b, own)) := by
  induction locals with
  | empty => rfl
  | leaf id own =>
    by_cases h : id = b
    · subst h
      simp [collectLocals, lookupLeaf]
    · simp [collectLocals, lookupLeaf, h]
  | fork left right ihL ihR =>
    simp [collectLocals, lookupLeaf, List.find?_append, ihL, ihR]
    cases lookupLeaf left b <;> simp

theorem lookupCollected_eq_lookupLeaf (locals : LocalTree B P A D) (b : B) :
    lookupCollected (collectLocals locals) b = (lookupLeaf locals b).getD emptyLocal := by
  simp [lookupCollected, find?_collectLocals]
  cases lookupLeaf locals b <;> rfl

theorem flatten_startTree (roster : Roster B) (tree : Tree B) (initial : World P A D) :
    flattenMachine roster (startTree tree initial) =
      ⟨initial, fun b => lookupCollected (collectLocals (emptyLocals tree)) b, []⟩ := rfl

theorem Rep_iff (roster : Roster B) (tm : TreeMachine B P A D) (m : Nary.Machine B P A D) :
    Rep roster tm m ↔ flattenMachine roster tm = m :=
  Nary.machineEquivalent_iff roster _ _

theorem fullMachineEq_eq_machineEq (roster : Roster B) (left right : TreeMachine B P A D) :
    fullMachineEq roster left right =
      Nary.machineEq roster (flattenMachine roster left) (flattenMachine roster right) := by
  simp [fullMachineEq, Nary.machineEq, fullAttemptsConjunct, flattenMachine_attempts]

theorem fullMachineEq_iff (roster : Roster B) (left right : TreeMachine B P A D) :
    fullMachineEq roster left right = true ↔
      flattenMachine roster left = flattenMachine roster right := by
  rw [fullMachineEq_eq_machineEq, Nary.machineEq_iff]

end DefiKernel.Nary.Tree
