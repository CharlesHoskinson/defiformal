/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: DefiElements
-/
import Defialgebra.Polarity

/-!
# Discharge by construction

Stage-4 extension. The requirement language of `Polarity.reqClause` admits exactly one way
to discharge a term `T` of a requirement `(s, T)`: exhibit an element of `T`. The corpus
exhibits a second — the obligation is *closed by construction*, so it cannot arise.

We model this by **widening the head**: a requirement `(s, T)` acquires a finset `V` of
*voiding* witnesses and becomes `(s, T ∪ V)`.

## Main results

* `dualHorn_voidReq` — the repaired row is still dual-Horn, so `lem:polarity` survives
  verbatim.
* `voidReq_union_closed`, `voidReq_models_union_closed` — the repaired model class is still
  union-closed, so `thm:closure` and `cor:lattice` survive verbatim. **The repair is free on
  the structure theorems.**
* `sat_voidReq_of_sat` — no protocol that was admissible becomes inadmissible: the model
  class only grows.
* `sat_voidReq_of_void` — the new discharge route: a voiding witness satisfies the row with
  no member of `T` present at all.
* `voidReq_strictly_larger` — the repair is not vacuous.
* `voidReq_not_definite` — **the price**: a widened singleton head is no longer a singleton,
  so the row leaves the definite fragment of `def:cn` and its arc leaves the digraph `D`.
  This is the only result the repair costs.
-/

set_option linter.unusedSectionVars false

namespace Defialgebra

namespace Polarity

variable {E : Type*} [DecidableEq E]

/-- The requirement `(s, T)` with voiding witnesses `V`: the term is discharged either by an
element of `T` (a mechanism that satisfies it) or by an element of `V` (a construction under
which the obligation cannot arise). -/
def voidReq (s : E) (T V : Finset E) : Clause E := reqClause s (T ∪ V)

/-- **Polarity is preserved.** The repaired row still has exactly one negative literal, so
`lem:polarity` holds of the repaired system with no change to its proof. -/
theorem dualHorn_voidReq (s : E) (T V : Finset E) : DualHorn (voidReq s T V) :=
  dualHorn_reqClause s (T ∪ V)

/-- Satisfaction of the repaired row, in the paper's own vocabulary. -/
theorem sat_voidReq_iff (s : E) (T V X : Finset E) :
    Sat X (voidReq s T V) ↔ (s ∈ X → ((T ∪ V) ∩ X).Nonempty) :=
  sat_reqClause_iff s (T ∪ V) X

/-- **The model class only grows.** Anything satisfying the original requirement satisfies
the repaired one, so no protocol previously judged admissible becomes inadmissible. -/
theorem sat_voidReq_of_sat {s : E} {T V X : Finset E} (h : Sat X (reqClause s T)) :
    Sat X (voidReq s T V) := by
  rcases h with ⟨e, heT, heX⟩ | hneg
  · exact Or.inl ⟨e, Finset.mem_union_left _ heT, heX⟩
  · exact Or.inr hneg

/-- **The new discharge route.** A voiding witness present in `X` discharges the term, with
no member of `T` required. This is the sentence the current language cannot say. -/
theorem sat_voidReq_of_void {s : E} {T V X : Finset E} {v : E} (hv : v ∈ V) (hvX : v ∈ X) :
    Sat X (voidReq s T V) :=
  Or.inl ⟨v, Finset.mem_union_right _ hv, hvX⟩

/-- **Union-closure is preserved, clause level** — `thm:closure` survives. -/
theorem sat_union_voidReq {s : E} {T V X Y : Finset E}
    (hX : Sat X (voidReq s T V)) (hY : Sat Y (voidReq s T V)) :
    Sat (X ∪ Y) (voidReq s T V) :=
  sat_union_of_dualHorn (dualHorn_voidReq s T V) hX hY

/-- **Union-closure is preserved, set level.** A whole requirement system repaired by voiding
witnesses still has a union-closed model class, hence `cor:lattice` — a complete lattice under
inclusion with join = union — survives unchanged. -/
theorem voidReq_union_closed {S : Set (Clause E)}
    (hS : ∀ c ∈ S, ∃ s T V, c = voidReq s T V)
    {X Y : Finset E} (hX : Models X S) (hY : Models Y S) : Models (X ∪ Y) S := by
  refine dualHorn_union_closed (fun c hc => ?_) hX hY
  obtain ⟨s, T, V, rfl⟩ := hS c hc
  exact dualHorn_voidReq s T V

/-- The same statement in the paper's requirement vocabulary. -/
theorem voidReq_models_union_closed (s : E) (T V X Y : Finset E)
    (hX : s ∈ X → ((T ∪ V) ∩ X).Nonempty) (hY : s ∈ Y → ((T ∪ V) ∩ Y).Nonempty) :
    s ∈ X ∪ Y → ((T ∪ V) ∩ (X ∪ Y)).Nonempty :=
  req_models_union_closed s (T ∪ V) X Y hX hY

/-- **The repair is not vacuous.** On `Fin 3`, the requirement `(0, {1})` is unsatisfied by
`{0, 2}`, while the same requirement with voiding witness `2` is satisfied by it. This is the
Rysk/Hegic shape: subject present, no satisfying mechanism, obligation closed anyway. -/
theorem voidReq_strictly_larger :
    ∃ (s : Fin 3) (T V X : Finset (Fin 3)),
      ¬ Sat X (reqClause s T) ∧ Sat X (voidReq s T V) := by
  refine ⟨0, {1}, {2}, {0, 2}, ?_, ?_⟩ <;> decide

/-- A clause is **definite** when its head is a single element; these are exactly the rows
that contribute an arc to the digraph `D` of `def:cn`. -/
def Definite (c : Clause E) : Prop := c.pos.card = 1

/-- **The price of the repair, and the only one.** Widening a head by a witness outside it
destroys definiteness: the row no longer contributes an arc to `D`, so the definite fragment
— and with it `cor:ex` (canonical forms) and `thm:excomp` (linear composition) — is computed
on a strictly smaller digraph. Nothing else in the theory changes. -/
theorem voidReq_not_definite {s : E} {T V : Finset E} {t v : E}
    (ht : t ∈ T) (hv : v ∈ V) (hne : t ≠ v) : ¬ Definite (voidReq s T V) := by
  intro h
  have hcard : (T ∪ V).card ≤ 1 := le_of_eq h
  exact hne (Finset.card_le_one.mp hcard t (Finset.mem_union_left _ ht)
    v (Finset.mem_union_right _ hv))

/-- Acyclicity is *not* threatened: widening only ever deletes arcs from `D`, and deleting
arcs from an acyclic digraph leaves it acyclic. Stated here as the fact that the repaired row
contributes an arc only when it contributed one before. -/
theorem definite_voidReq_imp_definite {s : E} {T V : Finset E}
    (hV : V ⊆ T) (h : Definite (voidReq s T V)) : Definite (reqClause s T) := by
  have : T ∪ V = T := Finset.union_eq_left.mpr hV
  simpa [Definite, voidReq, reqClause, this] using h

section AxiomAudit

#print axioms Defialgebra.Polarity.dualHorn_voidReq
#print axioms Defialgebra.Polarity.sat_voidReq_iff
#print axioms Defialgebra.Polarity.sat_voidReq_of_sat
#print axioms Defialgebra.Polarity.sat_voidReq_of_void
#print axioms Defialgebra.Polarity.sat_union_voidReq
#print axioms Defialgebra.Polarity.voidReq_union_closed
#print axioms Defialgebra.Polarity.voidReq_models_union_closed
#print axioms Defialgebra.Polarity.voidReq_strictly_larger
#print axioms Defialgebra.Polarity.voidReq_not_definite
#print axioms Defialgebra.Polarity.definite_voidReq_imp_definite

end AxiomAudit

end Polarity

end Defialgebra
