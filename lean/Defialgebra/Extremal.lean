/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charles Hoskinson
-/
import Mathlib.Data.List.Basic
import Mathlib.Tactic.Linarith

/-!
# Gate 0.2 — F9 extremal allocation is irreducible to local sum-rules

`ROADMAP.md` section 0.2; `basis/REFUTATION.md` R2.

Pool-shaped composites expose own claim fields and commutative sum aggregates
only. Extremal allocation walks a global preorder and takes a demand-bounded
prefix.

## Main result

`f9_irreducible_to_sum_local`: no predicate `phi : Claim -> SumAgg -> Bool`
reproduces extremal fill on both two-claim instances. The local view
(size=1, priority=5, SumAgg=(2,2,1)) is selected in one population and rejected
in the other.
-/

namespace Defialgebra.Extremal

structure Claim where
  id : Nat
  size : Nat
  priority : Nat
  deriving DecidableEq, Repr, Inhabited

structure SumAgg where
  totalSize : Nat
  count : Nat
  demand : Nat
  deriving DecidableEq, Repr

def sumAgg (cs : List Claim) (demand : Nat) : SumAgg where
  totalSize := (cs.map (fun c => c.size)).sum
  count := cs.length
  demand := demand

def LocalSel (phi : Claim -> SumAgg -> Bool) (cs : List Claim) (demand : Nat) :
    List Claim :=
  cs.filter (fun c => phi c (sumAgg cs demand))

/-- Earlier in the preorder: strictly smaller priority, or equal priority and smaller id. -/
def earlier (a b : Claim) : Prop :=
  a.priority < b.priority ∨ (a.priority = b.priority ∧ a.id ≤ b.id)

instance : DecidableRel earlier := fun a b => by
  dsimp [earlier]
  infer_instance

/-- For a two-element population with unit sizes and demand 1, extremal fill is
the earlier claim under `earlier`. -/
def extremalFill2 (a b : Claim) : Claim :=
  if earlier a b then a else b

/-- Extremal fill for the two-claim unit-demand case used by the gate. -/
def extremalFill (cs : List Claim) (demand : Nat) : List Claim :=
  match cs, demand with
  | [a, b], 1 => [extremalFill2 a b]
  | _, _ => cs

def cA : Claim := ⟨0, 1, 5⟩
def cB : Claim := ⟨1, 1, 10⟩
def cC : Claim := ⟨2, 1, 3⟩

theorem sumAgg_AB : sumAgg [cA, cB] 1 = ⟨2, 2, 1⟩ := by decide
theorem sumAgg_AC : sumAgg [cA, cC] 1 = ⟨2, 2, 1⟩ := by decide

theorem earlier_AB : earlier cA cB := by
  dsimp [earlier, cA, cB]; decide

theorem not_earlier_AC : ¬ earlier cA cC := by
  dsimp [earlier, cA, cC]; decide

theorem extremalFill2_AB : extremalFill2 cA cB = cA := by
  simp [extremalFill2, earlier_AB]

theorem extremalFill2_AC : extremalFill2 cA cC = cC := by
  have : ¬ earlier cA cC := not_earlier_AC
  simp [extremalFill2, this]

theorem extremal_AB_ids :
    (extremalFill [cA, cB] 1).map (fun c => c.id) = [0] := by
  simp only [extremalFill]
  rw [extremalFill2_AB]
  rfl

theorem extremal_AC_ids :
    (extremalFill [cA, cC] 1).map (fun c => c.id) = [2] := by
  simp only [extremalFill]
  rw [extremalFill2_AC]
  rfl

theorem mem_localSel_iff (phi : Claim -> SumAgg -> Bool) (c : Claim)
    (cs : List Claim) (d : Nat) :
    c ∈ LocalSel phi cs d ↔ c ∈ cs ∧ phi c (sumAgg cs d) = true := by
  simp [LocalSel, List.mem_filter]

theorem phi_accepts_cA_of_AB (phi : Claim -> SumAgg -> Bool)
    (h : (LocalSel phi [cA, cB] 1).map (fun c => c.id) = [0]) :
    phi cA (sumAgg [cA, cB] 1) = true := by
  have hin : 0 ∈ (LocalSel phi [cA, cB] 1).map (fun c => c.id) := by simp [h]
  rcases List.mem_map.1 hin with ⟨c, hc, hid⟩
  have hcAB : c ∈ [cA, cB] := ((mem_localSel_iff phi c [cA, cB] 1).1 hc).1
  have hphi : phi c (sumAgg [cA, cB] 1) = true :=
    ((mem_localSel_iff phi c [cA, cB] 1).1 hc).2
  have hcA : c = cA := by
    have fine : c = cA ∨ c = cB := by
      simpa [List.mem_cons, List.mem_singleton] using hcAB
    rcases fine with hEq | hEq
    · exact hEq
    · have : c.id = 1 := by simp [hEq, cB]
      simp [this] at hid
  simpa [hcA] using hphi

theorem phi_rejects_cA_of_AC (phi : Claim -> SumAgg -> Bool)
    (h : (LocalSel phi [cA, cC] 1).map (fun c => c.id) = [2]) :
    phi cA (sumAgg [cA, cC] 1) = false := by
  by_contra hne
  have ht : phi cA (sumAgg [cA, cC] 1) = true := by
    cases hphi : phi cA (sumAgg [cA, cC] 1) with
    | true => rfl
    | false => exact (hne hphi).elim
  have hmem : cA ∈ LocalSel phi [cA, cC] 1 :=
    (mem_localSel_iff phi cA [cA, cC] 1).2 ⟨by simp, ht⟩
  have : 0 ∈ (LocalSel phi [cA, cC] 1).map (fun c => c.id) := by
    refine List.mem_map.2 ?_
    exact ⟨cA, hmem, rfl⟩
  simp [h] at this

theorem sumAgg_eq : sumAgg [cA, cB] 1 = sumAgg [cA, cC] 1 := by
  simp [sumAgg_AB, sumAgg_AC]

theorem extremal_not_local :
    ¬ ∃ (phi : Claim -> SumAgg -> Bool),
      (LocalSel phi [cA, cB] 1).map (fun c => c.id) =
        (extremalFill [cA, cB] 1).map (fun c => c.id) ∧
      (LocalSel phi [cA, cC] 1).map (fun c => c.id) =
        (extremalFill [cA, cC] 1).map (fun c => c.id) := by
  rintro ⟨phi, hAB, hAC⟩
  have hAB' : (LocalSel phi [cA, cB] 1).map (fun c => c.id) = [0] := by
    simpa [extremal_AB_ids] using hAB
  have hAC' : (LocalSel phi [cA, cC] 1).map (fun c => c.id) = [2] := by
    simpa [extremal_AC_ids] using hAC
  have ht := phi_accepts_cA_of_AB phi hAB'
  have hf := phi_rejects_cA_of_AC phi hAC'
  rw [sumAgg_eq] at ht
  simp [ht] at hf

theorem f9_irreducible_to_sum_local :
    ¬ ∃ (phi : Claim -> SumAgg -> Bool),
      (LocalSel phi [cA, cB] 1).map (fun c => c.id) =
        (extremalFill [cA, cB] 1).map (fun c => c.id) ∧
      (LocalSel phi [cA, cC] 1).map (fun c => c.id) =
        (extremalFill [cA, cC] 1).map (fun c => c.id) :=
  extremal_not_local

end Defialgebra.Extremal
