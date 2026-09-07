import DefiHistorical.Convex.Instances

/-! Small checked counterexamples. These finite graphs are deliberately separate from the
58-name instances; failures of false universal claims are not compiler-error evidence. -/
namespace DefiHistorical.Convex.Counterexamples
open Defialgebra.ConvexGeometry

abbrev V := Fin 2

def chain (a b : V) : Prop := a = 0 ∧ b = 1
instance : DecidableRel chain := fun _ _ ↦ inferInstanceAs (Decidable (_ ∧ _))

def reverseChain (a b : V) : Prop := chain b a
instance : DecidableRel reverseChain := fun a b ↦ inferInstanceAs (Decidable (chain b a))

def cycle (a b : V) : Prop := a ≠ b
instance : DecidableRel cycle := fun a b ↦ inferInstanceAs (Decidable (a ≠ b))
instance : DecidableRel (Relation.ReflTransGen cycle) := reachableDecidable cycle

def deletionExtreme (r : V → V → Prop) [DecidableRel r] (S : Finset V) : Finset V :=
  S.filter (fun a ↦ a ∉ saturate r (S.erase a))

def omittedDeletion (r : V → V → Prop) [DecidableRel r] (S : Finset V) : Finset V :=
  S.filter (fun a ↦ a ∉ saturate r S)

-- BEGIN PROOFS

theorem empty_input : saturate chain (∅ : Finset V) = ∅ := by decide

theorem full_input : saturate chain (Finset.univ : Finset V) = Finset.univ := by decide

theorem chain_forward : saturate chain ({0} : Finset V) = {0, 1} := by decide

theorem chain_reversed : saturate reverseChain ({0} : Finset V) = {0} := by decide

theorem orientation_matters : saturate chain ({0} : Finset V) ≠
    saturate reverseChain {0} := by decide

theorem chain_ranked : ∀ a b : V, chain a b → a.val < b.val := by decide

theorem reverse_rank_rejected : ¬ ∀ a b : V, reverseChain a b → a.val < b.val := by decide

theorem cycle_reach_forward : Relation.ReflTransGen cycle (0 : V) 1 :=
  Relation.ReflTransGen.single (by decide)

theorem cycle_reach_backward : Relation.ReflTransGen cycle (1 : V) 0 :=
  Relation.ReflTransGen.single (by decide)

theorem cycle_not_antisymmetric : ¬ ∀ a b : V,
    Relation.ReflTransGen cycle a b → Relation.ReflTransGen cycle b a → a = b := by
  intro h
  exact (by decide : (0 : V) ≠ 1) (h 0 1 cycle_reach_forward cycle_reach_backward)

theorem cycle_not_antiExchange : ¬ AntiExchange (reachCl cycle) := by
  intro h
  exact cycle_not_antisymmetric ((reachCl_antiExchange_iff cycle).mp h)

theorem isolated_singleton_intrinsic :
    deletionExtreme (fun _ _ : V ↦ False) {0} = {0} := by decide

theorem omitted_deletion_loses_singleton :
    omittedDeletion (fun _ _ : V ↦ False) {0} = ∅ := by decide

theorem deletion_is_material : deletionExtreme (fun _ _ : V ↦ False) {0} ≠
    omittedDeletion (fun _ _ : V ↦ False) {0} := by decide

theorem chain_intrinsic : deletionExtreme chain {0, 1} = {0} := by decide

theorem cycle_has_no_extremes : deletionExtreme cycle {0, 1} = ∅ := by decide

theorem cycle_extremes_do_not_generate :
    saturate cycle (deletionExtreme cycle {0, 1}) ≠ ({0, 1} : Finset V) := by decide

/-- The singleton is not closed; silently treating every input as closed loses an actual edge. -/
theorem missing_closed_input : saturate chain ({0} : Finset V) ≠ {0} := by decide

/-- This is the actual Pl→Ct edge in the frozen encoding, not a renamed toy graph. -/
theorem actual_edge_and_rank (i : Data.Instance) :
    Data.edge i (14 : Data.Vertex) 19 ∧ rank (14 : Data.Vertex) < rank 19 := by
  cases i <;> decide

theorem actual_reversed_rank_rejected : ¬ rank (19 : Data.Vertex) < rank 14 := by decide

end DefiHistorical.Convex.Counterexamples
