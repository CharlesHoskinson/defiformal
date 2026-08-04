/-
Copyright (c) 2026. Released under Apache 2.0 license.
Authors: DefiElements
-/
import Mathlib.Order.Basic
import Mathlib.Order.Closure
import Mathlib.Order.CompleteLattice.Basic

/-!
# Obstruction theorems for the mechanism-composition algebra

Machine-checked counterparts of results in `paper/atlas.tex`. Each theorem is
cross-referenced to the paper by its label.

## Main results

* `aft_obstruction` — paper Theorem `thm:aft`
* `fix_iterate` — paper Proposition `prop:repair`
* `adm_univ_of_consistent` — the reason the obstruction is fatal rather than awkward
-/

namespace Defialgebra

variable {α : Type*}

/-! ## The AFT obstruction (paper: `thm:aft`)

An approximator must preserve consistency: its lower component is bounded by its
upper. Placing an *inflationary* operator in the lower slot and a *deflationary*
one in the upper forces both to be the identity, so the assignment is backwards
and no non-trivial approximator of that shape exists.

Note what the proof does not use: no exactness, no `≤_p`-monotonicity, no
completeness, not even monotonicity of the operators. A partial order suffices.
-/

section AFT

variable [PartialOrder α] (Γ Δ : α → α)

/-- `Γ` is inflationary (extensive): every point lies below its image. -/
def Inflationary : Prop := ∀ x, x ≤ Γ x

/-- `Δ` is deflationary (contractive): every image lies below its point. -/
def Deflationary : Prop := ∀ x, Δ x ≤ x

/-- Consistency, as required of every AFT approximator, read on the diagonal. -/
def Consistent : Prop := ∀ x, Γ x ≤ Δ x

/-- **The AFT obstruction.** An inflationary lower slot, a deflationary upper
slot and consistency together collapse both operators to the identity. -/
theorem aft_obstruction
    (hΓ : Inflationary Γ) (hΔ : Deflationary Δ) (hc : Consistent Γ Δ) :
    ∀ x, Γ x = x ∧ Δ x = x := by
  intro x
  have hΓx : Γ x = x := le_antisymm (le_trans (hc x) (hΔ x)) (hΓ x)
  have hxΔ : x ≤ Δ x := by
    calc x = Γ x := hΓx.symm
      _ ≤ Δ x := hc x
  exact ⟨hΓx, le_antisymm (hΔ x) hxΔ⟩

/-- The two operators coincide, and are the identity. -/
theorem aft_obstruction_eq
    (hΓ : Inflationary Γ) (hΔ : Deflationary Δ) (hc : Consistent Γ Δ) :
    Γ = Δ := by
  funext x
  obtain ⟨h1, h2⟩ := aft_obstruction Γ Δ hΓ hΔ hc x
  rw [h1, h2]

end AFT

/-! ## Non-idempotence is immaterial (paper: `prop:repair`)

The warrant operator is deflationary and monotone but measured *not* idempotent.
Admissibility is defined by fixed points, so any repair preserving them is free.
-/

section Repair

/-- A fixed point of `Δ` is a fixed point of every iterate of `Δ`. -/
theorem fix_iterate (Δ : α → α) (x : α) (hx : Δ x = x) : ∀ n, Δ^[n] x = x := by
  intro n
  induction n with
  | zero => rfl
  | succ k ih => rw [Function.iterate_succ_apply', ih, hx]

end Repair

/-! ## The diagonal (paper: `prop:moore`) -/

section Diagonal

variable [PartialOrder α] (Γ Δ : α → α)

/-- Admissible points: the common fixed points of the two operators. -/
def Adm : Set α := {x | Γ x = x ∧ Δ x = x}

/-- Under the AFT hypotheses the diagonal is everything. This is why the
framework carries no information here, rather than merely fitting poorly. -/
theorem adm_univ_of_consistent
    (hΓ : Inflationary Γ) (hΔ : Deflationary Δ) (hc : Consistent Γ Δ) :
    Adm Γ Δ = Set.univ := by
  ext x
  simp only [Adm, Set.mem_univ, iff_true]
  exact aft_obstruction Γ Δ hΓ hΔ hc x

end Diagonal

end Defialgebra
