/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: DefiElements
-/
import Mathlib.Order.CompleteLattice.Defs
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.Fintype.Powerset

/-!
# Union-closed families are complete lattices

Machine-checked counterpart of paper `cor:lattice` and `prop:joinmeet`.

A family `F ⊆ 2^E` on a finite ground set which contains `∅` and `E` and is closed under
binary union is a complete lattice under inclusion, with `⊔ = ∪`.

## Implementation note

This is *low-content*: mathlib already supplies `completeLatticeOfSup`, which builds a
`CompleteLattice` from any `SupSet` whose `sSup` is a least upper bound. All that is left is
(i) to define `sSup` on the subtype as the union of a finite subfamily, and (ii) to check that
this union stays in `F` — which is exactly `Finset.sup_induction` fed with `∅ ∈ F` and binary
union-closure. Over a `Fintype` ground set every subset of `F` is finite, so binary closure
upgrades to arbitrary `sSup` for free; this is the only genuinely mathematical step.

## Main results

* `UnionClosedFamily.completeLattice` — the `CompleteLattice` instance.
* `UnionClosedFamily.coe_sup` — the join is literally union (paper `prop:joinmeet`).
* `UnionClosedFamily.inf_eq_sSup` — the meet is the join of all common lower bounds *inside
  the family*, i.e. `⋃ {C ∈ F : C ⊆ A ∩ B}`, not the intersection.
* `meet_ne_inter` — an explicit union-closed family containing `∅` and `univ` in which the
  intersection of two members is not a member; so meet really is not intersection.
-/

set_option linter.unusedSectionVars false

namespace Defialgebra

namespace Lattice

/-- A family of subsets of a finite ground set containing `∅` and the whole set and closed
under binary union. Paper: the family `ℛ ∩ 𝒲`. -/
structure UnionClosedFamily (E : Type*) [Fintype E] [DecidableEq E] where
  /-- The underlying family of subsets. -/
  carrier : Set (Finset E)
  /-- The empty set is a member. -/
  empty_mem : (∅ : Finset E) ∈ carrier
  /-- The whole ground set is a member. -/
  univ_mem : (Finset.univ : Finset E) ∈ carrier
  /-- The family is closed under binary union. -/
  union_mem : ∀ ⦃A B : Finset E⦄, A ∈ carrier → B ∈ carrier → A ∪ B ∈ carrier

namespace UnionClosedFamily

variable {E : Type*} [Fintype E] [DecidableEq E] (F : UnionClosedFamily E)

/-- The underlying finset of the (necessarily finite) subfamily `S`. -/
noncomputable def toFinsetFamily (S : Set F.carrier) : Finset (Finset E) :=
  letI := Classical.decPred
    (fun A : Finset E => ∃ a : F.carrier, a ∈ S ∧ (a : Finset E) = A)
  Finset.univ.filter (fun A : Finset E => ∃ a : F.carrier, a ∈ S ∧ (a : Finset E) = A)

@[simp] lemma mem_toFinsetFamily {S : Set F.carrier} {A : Finset E} :
    A ∈ F.toFinsetFamily S ↔ ∃ a : F.carrier, a ∈ S ∧ (a : Finset E) = A := by
  classical
  simp [toFinsetFamily]

/-- The candidate supremum: the union of all members of the subfamily `S`. -/
noncomputable def famSup (S : Set F.carrier) : Finset E := (F.toFinsetFamily S).sup id

/-- **The one mathematical step.** An arbitrary union of members of `F` is again a member:
over a `Fintype` ground set the subfamily is finite, so `∅ ∈ F` plus binary union-closure
suffice, by induction on the finite `Finset.sup`. -/
lemma famSup_mem (S : Set F.carrier) : F.famSup S ∈ F.carrier := by
  refine Finset.sup_induction F.empty_mem (fun a ha b hb => F.union_mem ha hb) ?_
  intro A hA
  obtain ⟨a, _, rfl⟩ := F.mem_toFinsetFamily.mp hA
  exact a.2

noncomputable instance : SupSet F.carrier := ⟨fun S => ⟨F.famSup S, F.famSup_mem S⟩⟩

lemma coe_sSup (S : Set F.carrier) : ((sSup S : F.carrier) : Finset E) = F.famSup S := rfl

lemma isLUB_sSup' (S : Set F.carrier) : IsLUB S (sSup S) := by
  constructor
  · intro a ha
    show (a : Finset E) ≤ F.famSup S
    exact Finset.le_sup (f := id) (F.mem_toFinsetFamily.mpr ⟨a, ha, rfl⟩)
  · intro b hb
    show F.famSup S ≤ (b : Finset E)
    refine Finset.sup_le ?_
    intro A hA
    obtain ⟨a, ha, rfl⟩ := F.mem_toFinsetFamily.mp hA
    exact hb ha

/-- **Paper `cor:lattice`.** A union-closed family containing `∅` and the ground set is a
complete lattice under inclusion. Obtained from mathlib's `completeLatticeOfSup`. -/
noncomputable instance completeLattice : CompleteLattice F.carrier :=
  completeLatticeOfSup _ F.isLUB_sSup'

/-- **Paper `prop:joinmeet`, join.** The join is union. -/
lemma coe_sup (a b : F.carrier) :
    ((a ⊔ b : F.carrier) : Finset E) = (a : Finset E) ∪ (b : Finset E) := by
  set u : F.carrier := ⟨(a : Finset E) ∪ (b : Finset E), F.union_mem a.2 b.2⟩ with hu
  have hau : a ≤ u := show (a : Finset E) ⊆ (a : Finset E) ∪ (b : Finset E) from
    Finset.subset_union_left
  have hbu : b ≤ u := show (b : Finset E) ⊆ (a : Finset E) ∪ (b : Finset E) from
    Finset.subset_union_right
  have h1 : ((a ⊔ b : F.carrier) : Finset E) ⊆ (a : Finset E) ∪ (b : Finset E) :=
    sup_le hau hbu
  have h2 : (a : Finset E) ∪ (b : Finset E) ⊆ ((a ⊔ b : F.carrier) : Finset E) :=
    Finset.union_subset (le_sup_left (a := a) (b := b)) (le_sup_right (a := a) (b := b))
  exact Finset.Subset.antisymm h1 h2

/-- **Paper `prop:joinmeet`, meet.** The meet of `A` and `B` is the join of *all members of the
family* below both, i.e. `⋃ {C ∈ F : C ⊆ A ∩ B}` — not `A ∩ B`. -/
lemma inf_eq_sSup (a b : F.carrier) : a ⊓ b = sSup {x : F.carrier | x ≤ a ∧ x ≤ b} := by
  refine le_antisymm (le_sSup ⟨inf_le_left, inf_le_right⟩) (sSup_le ?_)
  rintro x ⟨hx1, hx2⟩
  exact le_inf hx1 hx2

/-- Concretely: the meet is the union of all members of `F` contained in `A ∩ B`. -/
lemma coe_inf (a b : F.carrier) :
    ((a ⊓ b : F.carrier) : Finset E) =
      F.famSup {x : F.carrier | (x : Finset E) ⊆ (a : Finset E) ∩ (b : Finset E)} := by
  rw [inf_eq_sSup, coe_sSup]
  congr 1
  ext x
  constructor
  · rintro ⟨h1, h2⟩
    exact Finset.subset_inter h1 h2
  · intro h
    exact ⟨h.trans Finset.inter_subset_left, h.trans Finset.inter_subset_right⟩

/-- The top of the lattice is the whole ground set (this is where `univ_mem` is used). -/
lemma top_eq_univ : ((⊤ : F.carrier) : Finset E) = Finset.univ :=
  Finset.Subset.antisymm (Finset.subset_univ _)
    (le_top (a := (⟨Finset.univ, F.univ_mem⟩ : F.carrier)))

end UnionClosedFamily

/-- **Meet is not intersection.** An explicit union-closed family on `Fin 3` containing `∅`
and `univ` whose members `{0,1}` and `{0,2}` have intersection `{0}` outside the family.
Together with `UnionClosedFamily.inf_eq_sSup` this shows the meet of the complete lattice
cannot be intersection. -/
theorem meet_ne_inter :
    ∃ C : Finset (Finset (Fin 3)),
      (∅ ∈ C) ∧ (Finset.univ ∈ C) ∧ (∀ A ∈ C, ∀ B ∈ C, A ∪ B ∈ C) ∧
        ∃ A ∈ C, ∃ B ∈ C, A ∩ B ∉ C := by
  refine ⟨{∅, {0, 1}, {0, 2}, Finset.univ}, ?_, ?_, ?_, ?_⟩ <;> decide

section AxiomAudit

#print axioms Defialgebra.Lattice.UnionClosedFamily.mem_toFinsetFamily
#print axioms Defialgebra.Lattice.UnionClosedFamily.famSup_mem
#print axioms Defialgebra.Lattice.UnionClosedFamily.isLUB_sSup'
#print axioms Defialgebra.Lattice.UnionClosedFamily.completeLattice
#print axioms Defialgebra.Lattice.UnionClosedFamily.coe_sup
#print axioms Defialgebra.Lattice.UnionClosedFamily.inf_eq_sSup
#print axioms Defialgebra.Lattice.UnionClosedFamily.coe_inf
#print axioms Defialgebra.Lattice.UnionClosedFamily.top_eq_univ
#print axioms Defialgebra.Lattice.meet_ne_inter

end AxiomAudit

end Lattice

end Defialgebra
