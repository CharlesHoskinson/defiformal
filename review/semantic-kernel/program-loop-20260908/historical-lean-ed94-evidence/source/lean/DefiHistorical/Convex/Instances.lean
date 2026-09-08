import DefiHistorical.Convex.Data
import DefiHistorical.Convex.Saturation

/-! The two frozen, loop-normalized unary graphs. Ranks are checked on the actual named edge
lists. Paper specialization is reversed: a reaches b means a specializes above b. -/
namespace DefiHistorical.Convex
open Defialgebra.ConvexGeometry
open Data

/-- Every target has rank one and every source rank zero in these two literal graphs. -/
def rankName (name : String) : Nat :=
  if name ∈ ["Ct", "Aw", "At", "Ep", "Rd", "Xm", "Xf", "Au", "Ex", "Li"] then 1 else 0

def rank (v : Vertex) : Nat := rankName (decode v)

instance (i : Instance) : DecidableRel (Relation.ReflTransGen (edge i)) :=
  reachableDecidable (edge i)

def instanceClosure (i : Instance) (S : Finset Vertex) : Finset Vertex := saturate (edge i) S

/-- Intrinsic deletion test; this definition contains no maximal-element predicate. -/
def intrinsic (i : Instance) (S : Finset Vertex) : Finset Vertex :=
  S.filter (fun a ↦ a ∉ instanceClosure i (S.erase a))

/-- Maximal in the paper's reversed specialization order, minimal in forward reach order. -/
def paperMaximal (i : Instance) (S : Finset Vertex) : Finset Vertex :=
  S.filter (fun a ↦ ∀ b ∈ S, Relation.ReflTransGen (edge i) b a → b = a)

-- BEGIN PROOFS

/-- Kernel reduction checks every actual distinct pair, not a printed SCC count. -/
theorem named_edges_ranked (i : Instance) :
    ∀ pair ∈ relationEdges i, rankName pair.1 < rankName pair.2 := by
  cases i <;> decide

theorem edge_ranked (i : Instance) {a b : Vertex} (h : edge i a b) : rank a < rank b :=
  named_edges_ranked i (decode a, decode b) h

theorem edge_loopless (i : Instance) (a : Vertex) : ¬ edge i a a := by
  intro h
  exact Nat.lt_irrefl _ (edge_ranked i h)

/-- Generic path proof: strict edge ranks give equality or strict rank growth along a path. -/
theorem path_rank {E : Type} (r : E → E → Prop) (rank : E → Nat)
    (step : ∀ a b, r a b → rank a < rank b) {a b : E}
    (h : Relation.ReflTransGen r a b) : a = b ∨ rank a < rank b := by
  induction h with
  | refl => exact .inl rfl
  | @tail b c _ h ih =>
    rcases ih with he | hl
    · subst b
      exact .inr (step _ _ h)
    · exact .inr (Nat.lt_trans hl (step _ _ h))

theorem ranked_antisymm {E : Type} (r : E → E → Prop) (rank : E → Nat)
    (step : ∀ a b, r a b → rank a < rank b) (a b : E)
    (hab : Relation.ReflTransGen r a b) (hba : Relation.ReflTransGen r b a) : a = b := by
  rcases path_rank r rank step hab with he | hl
  · exact he
  rcases path_rank r rank step hba with he | hr
  · exact he.symm
  · exact False.elim (Nat.lt_asymm hl hr)

theorem instance_antisymm (i : Instance) (a b : Vertex)
    (hab : Relation.ReflTransGen (edge i) a b)
    (hba : Relation.ReflTransGen (edge i) b a) : a = b :=
  ranked_antisymm (edge i) rank (fun _ _ h ↦ edge_ranked i h) a b hab hba

/-- All 2^58 inputs, including empty and full sets, follow from the finite generic proof. -/
theorem instance_saturation (i : Instance) (S : Finset Vertex) :
    instanceClosure i S = reachSet (edge i) S := saturate_eq_reachSet (edge i) S

theorem instanceClosure_eq_reachCl (i : Instance) (S : Finset Vertex) :
    instanceClosure i S = reachCl (edge i) S := instance_saturation i S

theorem intrinsic_eq_ex (i : Instance) (S : Finset Vertex) :
    intrinsic i S = ex (reachCl (edge i)) S := by
  ext a
  simp only [intrinsic, Finset.mem_filter, mem_ex, instanceClosure_eq_reachCl]

theorem intrinsic_eq_paperMaximal (i : Instance) (S : Finset Vertex) :
    intrinsic i S = paperMaximal i S := by
  rw [intrinsic_eq_ex, ex_reachCl]
  ext a
  simp only [paperMaximal, Finset.mem_filter]

theorem instance_antiExchange_iff (i : Instance) :
    AntiExchange (reachCl (edge i)) ↔
      ∀ a b, Relation.ReflTransGen (edge i) a b →
        Relation.ReflTransGen (edge i) b a → a = b := reachCl_antiExchange_iff (edge i)

theorem instance_antiExchange (i : Instance) : AntiExchange (reachCl (edge i)) :=
  (instance_antiExchange_iff i).mpr (instance_antisymm i)

/-- Exact specialization of the unchanged generic bundled theorem. -/
theorem instance_convex (i : Instance) :
    (∀ A B : Finset Vertex,
      reachCl (edge i) (A ∪ B) = reachCl (edge i) A ∪ reachCl (edge i) B) ∧
    (∀ A : Finset Vertex, reachCl (edge i) A = A ↔
      ∀ a ∈ A, ∀ b, Relation.ReflTransGen (edge i) a b → b ∈ A) ∧
    (AntiExchange (reachCl (edge i)) ↔
      ∀ a b, Relation.ReflTransGen (edge i) a b →
        Relation.ReflTransGen (edge i) b a → a = b) := thm_convex (edge i)

theorem instance_unique_minimum_generator (i : Instance) {A : Finset Vertex}
    (closed : instanceClosure i A = A) :
    ∃! G : Finset Vertex, instanceClosure i G = A ∧
      ∀ G' : Finset Vertex, instanceClosure i G' = A → G ⊆ G' := by
  simpa only [instanceClosure_eq_reachCl] using
    unique_minimum_generator (reachCl (edge i)) (instance_antiExchange i)
      (by simpa only [← instanceClosure_eq_reachCl] using closed)

theorem intrinsic_generates (i : Instance) {A : Finset Vertex}
    (closed : instanceClosure i A = A) : instanceClosure i (intrinsic i A) = A := by
  rw [instanceClosure_eq_reachCl, intrinsic_eq_ex]
  exact closure_ex (reachCl (edge i)) (instance_antiExchange i)
    (by simpa only [← instanceClosure_eq_reachCl] using closed)

theorem intrinsic_contained_in_generator (i : Instance) {A G : Finset Vertex}
    (generates : instanceClosure i G = A) : intrinsic i A ⊆ G := by
  rw [intrinsic_eq_ex]
  exact ex_subset_of_generates (reachCl (edge i))
    (by simpa only [← instanceClosure_eq_reachCl] using generates)

theorem intrinsic_union (i : Instance) (A B : Finset Vertex) :
    intrinsic i (A ∪ B) = paperMaximal i (intrinsic i A ∪ intrinsic i B) := by
  simp only [intrinsic_eq_ex, paperMaximal]
  rw [ex_reachCl_union_ex (edge i) (instance_antisymm i) A B]
  ext a
  simp only [Finset.mem_filter]

/-- Closed-input hypotheses are retained explicitly for the composite closure theorem. -/
theorem intrinsic_oplus (i : Instance) {A B : Finset Vertex}
    (closedA : instanceClosure i A = A) (closedB : instanceClosure i B = B) :
    intrinsic i (instanceClosure i (A ∪ B)) =
      paperMaximal i (intrinsic i A ∪ intrinsic i B) := by
  simp only [intrinsic_eq_ex, instanceClosure_eq_reachCl, paperMaximal]
  rw [ex_oplus (edge i) (instance_antisymm i)
    (by simpa only [← instanceClosure_eq_reachCl] using closedA)
    (by simpa only [← instanceClosure_eq_reachCl] using closedB)]
  ext a
  simp only [Finset.mem_filter]

end DefiHistorical.Convex
