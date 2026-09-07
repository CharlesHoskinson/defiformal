/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: DefiElements
-/
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Data.Fintype.Basic

/-!
# Polarity and the closure properties of the model classes

Machine-checked counterparts of paper `lem:polarity` and `thm:closure`.

A clause over a ground set `E` is a pair of finsets: the positive literals and the negative
literals. A set `X ⊆ E` satisfies it when some positive literal is present or some negative
literal is absent.

## Main results

* `sat_union_of_dualHorn` / `dualHorn_union_closed` — dual-Horn clause sets (at most one
  negative literal) are preserved by union.
* `sat_inter_of_horn` / `horn_inter_closed` — Horn clause sets (at most one positive literal)
  are preserved by intersection.
* `req_models_union_closed`, `warrant_models_union_closed`, `proh_models_inter_closed` — the
  same statements phrased in the paper's own vocabulary of requirements, warrants and
  prohibitions.
* `dualHorn_not_inter_closed`, `pureNeg_not_union_closed` — the *negative* halves of
  `thm:closure`: these closure properties do not hold in the other direction. Both are
  witnessed by explicit three-element counterexamples, checked by `decide`.
-/

set_option linter.unusedSectionVars false

namespace Defialgebra

namespace Polarity

/-- A clause over the ground set `E`: a finset of positive literals and a finset of negative
literals. The clause is read as `⋁_{e ∈ pos} e ∨ ⋁_{e ∈ neg} ¬e`. -/
structure Clause (E : Type*) where
  /-- The positive literals. -/
  pos : Finset E
  /-- The negative literals. -/
  neg : Finset E
  deriving DecidableEq

variable {E : Type*} [DecidableEq E]

/-- `X` satisfies the clause `c`: some positive literal is present, or some negative literal
is absent. -/
def Sat (X : Finset E) (c : Clause E) : Prop :=
  (∃ e ∈ c.pos, e ∈ X) ∨ (∃ e ∈ c.neg, e ∉ X)

instance (X : Finset E) (c : Clause E) : Decidable (Sat X c) := by
  unfold Sat; infer_instance

/-- A clause is **dual-Horn** when it has at most one negative literal. -/
def DualHorn (c : Clause E) : Prop := c.neg.card ≤ 1

instance (c : Clause E) : Decidable (DualHorn c) := by unfold DualHorn; infer_instance

/-- A clause is **Horn** when it has at most one positive literal. -/
def Horn (c : Clause E) : Prop := c.pos.card ≤ 1

instance (c : Clause E) : Decidable (Horn c) := by unfold Horn; infer_instance

/-- A clause is **purely negative** when it has no positive literal at all. This is the shape
of the paper's prohibitions, and a special case of `Horn`. -/
def PureNeg (c : Clause E) : Prop := c.pos = ∅

lemma horn_of_pureNeg {c : Clause E} (h : PureNeg c) : Horn c := by
  have h2 : c.pos = ∅ := h
  simp [Horn, h2]

/-- `X` satisfies the clause *set* `S`. -/
def Models (X : Finset E) (S : Set (Clause E)) : Prop := ∀ c ∈ S, Sat X c

/-! ## The two preservation lemmas -/

/-- **Union preservation, clause level.** A dual-Horn clause satisfied by `X` and by `Y` is
satisfied by `X ∪ Y`. -/
theorem sat_union_of_dualHorn {c : Clause E} (hc : DualHorn c) {X Y : Finset E}
    (hX : Sat X c) (hY : Sat Y c) : Sat (X ∪ Y) c := by
  rcases hX with ⟨e, he, heX⟩ | ⟨e, he, heX⟩
  · exact Or.inl ⟨e, he, Finset.mem_union_left _ heX⟩
  rcases hY with ⟨f, hf, hfY⟩ | ⟨f, hf, hfY⟩
  · exact Or.inl ⟨f, hf, Finset.mem_union_right _ hfY⟩
  -- Both witnesses are negative literals, and there is at most one of those.
  have hef : e = f := Finset.card_le_one.mp hc e he f hf
  refine Or.inr ⟨e, he, ?_⟩
  rw [Finset.mem_union]
  rintro (h | h)
  · exact heX h
  · exact hfY (hef ▸ h)

/-- **Intersection preservation, clause level.** A Horn clause satisfied by `X` and by `Y` is
satisfied by `X ∩ Y`. -/
theorem sat_inter_of_horn {c : Clause E} (hc : Horn c) {X Y : Finset E}
    (hX : Sat X c) (hY : Sat Y c) : Sat (X ∩ Y) c := by
  rcases hX with ⟨e, he, heX⟩ | ⟨e, he, heX⟩
  · rcases hY with ⟨f, hf, hfY⟩ | ⟨f, hf, hfY⟩
    · -- Both witnesses are positive literals, and there is at most one of those.
      have hef : e = f := Finset.card_le_one.mp hc e he f hf
      exact Or.inl ⟨e, he, Finset.mem_inter.mpr ⟨heX, hef ▸ hfY⟩⟩
    · exact Or.inr ⟨f, hf, fun h => hfY (Finset.mem_inter.mp h).2⟩
  · exact Or.inr ⟨e, he, fun h => heX (Finset.mem_inter.mp h).1⟩

/-- **Paper `thm:closure`, positive half for `ℛ` and `𝒲`.** A dual-Horn clause set has a
union-closed model class. -/
theorem dualHorn_union_closed {S : Set (Clause E)} (hS : ∀ c ∈ S, DualHorn c)
    {X Y : Finset E} (hX : Models X S) (hY : Models Y S) : Models (X ∪ Y) S :=
  fun c hc => sat_union_of_dualHorn (hS c hc) (hX c hc) (hY c hc)

/-- **Paper `thm:closure`, positive half for `ℋ`.** A Horn clause set has an
intersection-closed model class. -/
theorem horn_inter_closed {S : Set (Clause E)} (hS : ∀ c ∈ S, Horn c)
    {X Y : Finset E} (hX : Models X S) (hY : Models Y S) : Models (X ∩ Y) S :=
  fun c hc => sat_inter_of_horn (hS c hc) (hX c hc) (hY c hc)

/-- The purely negative case, which is what the paper's prohibitions actually are. -/
theorem pureNeg_inter_closed {S : Set (Clause E)} (hS : ∀ c ∈ S, PureNeg c)
    {X Y : Finset E} (hX : Models X S) (hY : Models Y S) : Models (X ∩ Y) S :=
  horn_inter_closed (fun c hc => horn_of_pureNeg (hS c hc)) hX hY

/-! ## The paper's actual clause shapes

A requirement `(s, T)` contributes `¬s ∨ ⋁_{e ∈ T} e`; a warrant `(e, C)` has the same shape;
a prohibition `H` contributes `⋁_{e ∈ H} ¬e`.
-/

/-- The clause `¬s ∨ ⋁_{e ∈ T} e` of a requirement `(s, T)` (equally, of a warrant `(s, T)`).
-/
def reqClause (s : E) (T : Finset E) : Clause E := ⟨T, {s}⟩

/-- The clause `⋁_{e ∈ H} ¬e` of a prohibition `H`. -/
def prohClause (H : Finset E) : Clause E := ⟨∅, H⟩

/-- **Paper `lem:polarity`, requirements and warrants.** -/
theorem dualHorn_reqClause (s : E) (T : Finset E) : DualHorn (reqClause s T) := by
  simp [DualHorn, reqClause]

/-- **Paper `lem:polarity`, prohibitions: purely negative.** -/
theorem pureNeg_prohClause (H : Finset E) : PureNeg (prohClause H) := rfl

/-- **Paper `lem:polarity`, prohibitions: hence Horn.** -/
theorem horn_prohClause (H : Finset E) : Horn (prohClause H) :=
  horn_of_pureNeg (pureNeg_prohClause H)

/-- Satisfaction of a requirement clause is the paper's condition
`s ∈ X → T ∩ X ≠ ∅`. -/
theorem sat_reqClause_iff (s : E) (T X : Finset E) :
    Sat X (reqClause s T) ↔ (s ∈ X → (T ∩ X).Nonempty) := by
  simp only [Sat, reqClause, Finset.mem_singleton, exists_eq_left]
  constructor
  · rintro (⟨e, heT, heX⟩ | hs) hsX
    · exact ⟨e, Finset.mem_inter.mpr ⟨heT, heX⟩⟩
    · exact absurd hsX hs
  · intro h
    by_cases hs : s ∈ X
    · obtain ⟨e, he⟩ := h hs
      exact Or.inl ⟨e, (Finset.mem_inter.mp he).1, (Finset.mem_inter.mp he).2⟩
    · exact Or.inr hs

/-- Satisfaction of a prohibition clause is the paper's condition `H ⊄ X`. -/
theorem sat_prohClause_iff (H X : Finset E) : Sat X (prohClause H) ↔ ¬ H ⊆ X := by
  constructor
  · rintro (⟨e, he, -⟩ | ⟨e, heH, heX⟩)
    · exact absurd he (Finset.notMem_empty e)
    · exact fun hsub => heX (hsub heH)
  · intro h
    obtain ⟨e, heH, heX⟩ := Finset.not_subset.mp h
    exact Or.inr ⟨e, heH, heX⟩

/-- **Paper-level statement for requirements**: the models of a requirement `(s, T)` are
closed under union. -/
theorem req_models_union_closed (s : E) (T X Y : Finset E)
    (hX : s ∈ X → (T ∩ X).Nonempty) (hY : s ∈ Y → (T ∩ Y).Nonempty) :
    s ∈ X ∪ Y → (T ∩ (X ∪ Y)).Nonempty := by
  rw [← sat_reqClause_iff] at hX hY ⊢
  exact sat_union_of_dualHorn (dualHorn_reqClause s T) hX hY

/-- **Paper-level statement for warrants**: identical shape, `(e, C)` in place of `(s, T)`. -/
theorem warrant_models_union_closed (e : E) (C X Y : Finset E)
    (hX : e ∈ X → (C ∩ X).Nonempty) (hY : e ∈ Y → (C ∩ Y).Nonempty) :
    e ∈ X ∪ Y → (C ∩ (X ∪ Y)).Nonempty :=
  req_models_union_closed e C X Y hX hY

/-- **Paper-level statement for prohibitions**: the models of a prohibition `H` are closed
under intersection. -/
theorem proh_models_inter_closed (H X Y : Finset E)
    (hX : ¬ H ⊆ X) (hY : ¬ H ⊆ Y) : ¬ H ⊆ X ∩ Y := by
  rw [← sat_prohClause_iff] at hX hY ⊢
  exact sat_inter_of_horn (horn_prohClause H) hX hY

/-! ## The negative halves of `thm:closure`

Dual-Horn model classes need not be intersection-closed, and purely negative model classes
need not be union-closed. Both witnessed on `Fin 3`, checked by kernel evaluation.
-/

/-- **Paper `thm:closure`, negative half for `ℛ` and `𝒲`.** The dual-Horn clause
`¬0 ∨ 1 ∨ 2` is satisfied by `{0,1}` and by `{0,2}` but not by their intersection `{0}`. -/
theorem dualHorn_not_inter_closed :
    ∃ (c : Clause (Fin 3)) (X Y : Finset (Fin 3)),
      DualHorn c ∧ Sat X c ∧ Sat Y c ∧ ¬ Sat (X ∩ Y) c :=
  ⟨⟨{1, 2}, {0}⟩, {0, 1}, {0, 2}, by decide, by decide, by decide, by decide⟩

/-- The same counterexample stated in the paper's requirement vocabulary: the requirement
`(0, {1,2})` is satisfied by `{0,1}` and `{0,2}` but fails on `{0}`. -/
theorem req_not_inter_closed :
    ∃ (s : Fin 3) (T X Y : Finset (Fin 3)),
      (s ∈ X → (T ∩ X).Nonempty) ∧ (s ∈ Y → (T ∩ Y).Nonempty) ∧
        ¬ (s ∈ X ∩ Y → (T ∩ (X ∩ Y)).Nonempty) := by
  refine ⟨0, {1, 2}, {0, 1}, {0, 2}, ?_, ?_, ?_⟩ <;> decide

/-- **Paper `thm:closure`, negative half for `ℋ`.** The purely negative clause `¬0 ∨ ¬1`
(the prohibition `{0,1}`) is satisfied by `{0}` and by `{1}` but not by their union. -/
theorem pureNeg_not_union_closed :
    ∃ (c : Clause (Fin 3)) (X Y : Finset (Fin 3)),
      PureNeg c ∧ Sat X c ∧ Sat Y c ∧ ¬ Sat (X ∪ Y) c :=
  ⟨prohClause {0, 1}, {0}, {1}, rfl, by decide, by decide, by decide⟩

/-- The same counterexample in the paper's prohibition vocabulary. -/
theorem proh_not_union_closed :
    ∃ (H X Y : Finset (Fin 3)), ¬ H ⊆ X ∧ ¬ H ⊆ Y ∧ ¬ (¬ H ⊆ X ∪ Y) := by
  refine ⟨{0, 1}, {0}, {1}, ?_, ?_, ?_⟩ <;> decide

section AxiomAudit

#print axioms Defialgebra.Polarity.sat_union_of_dualHorn
#print axioms Defialgebra.Polarity.sat_inter_of_horn
#print axioms Defialgebra.Polarity.dualHorn_union_closed
#print axioms Defialgebra.Polarity.horn_inter_closed
#print axioms Defialgebra.Polarity.pureNeg_inter_closed
#print axioms Defialgebra.Polarity.horn_of_pureNeg
#print axioms Defialgebra.Polarity.dualHorn_reqClause
#print axioms Defialgebra.Polarity.pureNeg_prohClause
#print axioms Defialgebra.Polarity.horn_prohClause
#print axioms Defialgebra.Polarity.sat_reqClause_iff
#print axioms Defialgebra.Polarity.sat_prohClause_iff
#print axioms Defialgebra.Polarity.req_models_union_closed
#print axioms Defialgebra.Polarity.warrant_models_union_closed
#print axioms Defialgebra.Polarity.proh_models_inter_closed
#print axioms Defialgebra.Polarity.dualHorn_not_inter_closed
#print axioms Defialgebra.Polarity.req_not_inter_closed
#print axioms Defialgebra.Polarity.pureNeg_not_union_closed
#print axioms Defialgebra.Polarity.proh_not_union_closed

end AxiomAudit

end Polarity

end Defialgebra
