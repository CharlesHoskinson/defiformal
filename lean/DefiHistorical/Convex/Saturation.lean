import Defialgebra.ConvexGeometry
import Lean.Elab.Tactic.Omega

/-! Independent finite synchronous saturation. Membership is proved before its decidability
instance is constructed; no reachability decider or desired equality is a proof premise. -/
namespace DefiHistorical.Convex
open Defialgebra.ConvexGeometry

variable {E : Type} [Fintype E] [DecidableEq E]
variable (r : E → E → Prop) [DecidableRel r]

/-- Add all immediate consequences of the current set, retaining every seed. -/
def round (S : Finset E) : Finset E :=
  S ∪ Finset.univ.filter (fun b ↦ ∃ a ∈ S, r a b)

def rounds : Nat → Finset E → Finset E
  | 0, S => S
  | n + 1, S => round r (rounds n S)

/-- A fixed, executable number of rounds determined only by the finite vocabulary. -/
def saturate (S : Finset E) : Finset E := rounds r (Fintype.card E) S

def RelationClosed (S : Finset E) : Prop := ∀ a ∈ S, ∀ b, r a b → b ∈ S

-- BEGIN PROOFS

@[simp] theorem mem_round (S : Finset E) (b : E) :
    b ∈ round r S ↔ b ∈ S ∨ ∃ a ∈ S, r a b := by simp [round]

theorem subset_round (S : Finset E) : S ⊆ round r S := Finset.subset_union_left

theorem round_mono {S T : Finset E} (h : S ⊆ T) : round r S ⊆ round r T := by
  intro b hb
  rcases (mem_round r S b).mp hb with hb | ⟨a, ha, hab⟩
  · exact (mem_round r T b).mpr (.inl (h hb))
  · exact (mem_round r T b).mpr (.inr ⟨a, h ha, hab⟩)

theorem round_eq_iff (S : Finset E) : round r S = S ↔ RelationClosed r S := by
  constructor
  · intro h a ha b hab
    rw [← h]
    exact (mem_round r S b).mpr (.inr ⟨a, ha, hab⟩)
  · intro h
    apply Finset.Subset.antisymm _ (subset_round r S)
    intro b hb
    rcases (mem_round r S b).mp hb with hb | ⟨a, ha, hab⟩
    · exact hb
    · exact h a ha b hab

theorem subset_rounds (n : Nat) (S : Finset E) : S ⊆ rounds r n S := by
  induction n with
  | zero => exact Finset.Subset.refl _
  | succ n ih => exact Finset.Subset.trans ih (subset_round r _)

theorem rounds_mono (n : Nat) {S T : Finset E} (h : S ⊆ T) :
    rounds r n S ⊆ rounds r n T := by
  induction n with
  | zero => exact h
  | succ n ih => exact round_mono r ih

/-- Either growth has stopped, or each elapsed round increased cardinality. -/
theorem rounds_fixed_or_card (n : Nat) (S : Finset E) :
    round r (rounds r n S) = rounds r n S ∨ n + S.card ≤ (rounds r n S).card := by
  induction n with
  | zero => exact .inr (by simp [rounds])
  | succ n ih =>
    rcases ih with h | h
    · exact .inl (by simpa only [rounds, h] using h)
    · by_cases he : round r (rounds r n S) = rounds r n S
      · exact .inl (by simpa only [rounds, he] using he)
      · have strict : (rounds r n S).card < (round r (rounds r n S)).card :=
          Finset.card_lt_card (Finset.ssubset_iff_subset_ne.mpr
            ⟨subset_round r _, Ne.symm he⟩)
        exact .inr (by simp only [rounds]; omega)

theorem saturate_fixed (S : Finset E) : round r (saturate r S) = saturate r S := by
  rcases rounds_fixed_or_card r (Fintype.card E) S with h | h
  · exact h
  · have bound := Finset.card_le_univ (rounds r (Fintype.card E) S)
    have full : rounds r (Fintype.card E) S = Finset.univ :=
      Finset.eq_univ_of_card _ (by omega)
    simp only [saturate, full]
    exact Finset.Subset.antisymm (Finset.subset_univ _) (subset_round r _)

theorem saturate_closed (S : Finset E) : RelationClosed r (saturate r S) :=
  (round_eq_iff r _).mp (saturate_fixed r S)

theorem rounds_least (n : Nat) {S T : Finset E} (hST : S ⊆ T)
    (hT : RelationClosed r T) : rounds r n S ⊆ T := by
  induction n with
  | zero => exact hST
  | succ n ih =>
    intro b hb
    rcases (mem_round r _ b).mp hb with hb | ⟨a, ha, hab⟩
    · exact ih hb
    · exact hT a (ih ha) b hab

theorem saturate_least {S T : Finset E} (hST : S ⊆ T) (hT : RelationClosed r T) :
    saturate r S ⊆ T := rounds_least r _ hST hT

theorem rounds_reachable (n : Nat) (S : Finset E) {b : E} (hb : b ∈ rounds r n S) :
    ∃ a ∈ S, Relation.ReflTransGen r a b := by
  induction n generalizing b with
  | zero => exact ⟨b, hb, .refl⟩
  | succ n ih =>
    rcases (mem_round r _ b).mp hb with hb | ⟨a, ha, hab⟩
    · exact ih hb
    · obtain ⟨s, hs, hsa⟩ := ih ha
      exact ⟨s, hs, hsa.tail hab⟩

omit [Fintype E] [DecidableEq E] [DecidableRel r] in
theorem reachable_mem_of_closed {S : Finset E} (hS : RelationClosed r S)
    {a b : E} (ha : a ∈ S) (hab : Relation.ReflTransGen r a b) : b ∈ S := by
  induction hab with
  | refl => exact ha
  | tail _ hbc ih => exact hS _ ih _ hbc

/-- Universal membership correspondence, independent of a reachability decider. -/
theorem mem_saturate (S : Finset E) (b : E) :
    b ∈ saturate r S ↔ ∃ a ∈ S, Relation.ReflTransGen r a b := by
  constructor
  · exact rounds_reachable r _ S
  · rintro ⟨a, ha, hab⟩
    exact reachable_mem_of_closed r (saturate_closed r S)
      (subset_rounds r _ S ha) hab

/-- Constructive finite decision procedure, justified by the preceding independent theorem. -/
@[instance_reducible] def reachableDecidable : DecidableRel (Relation.ReflTransGen r) := fun a b ↦
  decidable_of_iff (b ∈ saturate r {a}) (by simp only [mem_saturate, Finset.mem_singleton,
    exists_eq_left])

theorem saturate_eq_reachSet [DecidableRel (Relation.ReflTransGen r)] (S : Finset E) :
    saturate r S = reachSet r S := by
  ext b
  exact (mem_saturate r S b).trans (mem_reachSet r).symm

/-- Correct deciders affect execution strategy, never the filtered finite result. -/
theorem reachSet_decider_independent (d₁ d₂ : DecidableRel (Relation.ReflTransGen r))
    (S : Finset E) : @reachSet E _ r d₁ S = @reachSet E _ r d₂ S := by
  ext b
  exact (@mem_reachSet E _ _ r d₁ S b).trans (@mem_reachSet E _ _ r d₂ S b).symm

theorem saturate_empty : saturate r (∅ : Finset E) = ∅ := by
  ext b
  simp [mem_saturate]

theorem saturate_univ : saturate r (Finset.univ : Finset E) = Finset.univ :=
  Finset.Subset.antisymm (Finset.subset_univ _) (subset_rounds r _ _)

omit [Fintype E] [DecidableRel r] in
/-- Discarding self-loops preserves reflexive-transitive reachability. -/
theorem remove_loops_reachable (a b : E) :
    Relation.ReflTransGen (fun x y ↦ r x y ∧ x ≠ y) a b ↔
      Relation.ReflTransGen r a b := by
  constructor
  · intro h
    induction h with
    | refl => exact .refl
    | tail _ h ih => exact ih.tail h.1
  · intro h
    induction h with
    | refl => exact .refl
    | @tail b c _ h ih =>
      by_cases he : b = c
      · simpa only [← he] using ih
      · exact ih.tail ⟨h, he⟩

theorem rounds_add (m n : Nat) (S : Finset E) :
    rounds r (m + n) S = rounds r n (rounds r m S) := by
  induction n with
  | zero => rfl
  | succ n ih => exact congrArg (round r) ih

theorem rounds_of_fixed (n : Nat) (S : Finset E) (fixed : round r S = S) :
    rounds r n S = S := by
  induction n with
  | zero => rfl
  | succ n ih => simpa only [rounds, ih] using fixed

/-- Every extra finite round after the cardinality bound leaves the saturated result intact. -/
theorem saturated_after_extra_rounds (S : Finset E) (n : Nat) :
    rounds r (Fintype.card E + n) S = saturate r S := by
  rw [rounds_add]
  exact rounds_of_fixed r n _ (saturate_fixed r S)

theorem remove_loops_saturate (S : Finset E) :
    saturate (fun a b ↦ r a b ∧ a ≠ b) S = saturate r S := by
  ext b
  simp only [mem_saturate, remove_loops_reachable]

end DefiHistorical.Convex
