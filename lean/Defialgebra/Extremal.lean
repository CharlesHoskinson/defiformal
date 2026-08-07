/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charles Hoskinson
-/
import Mathlib.Data.List.Basic
import Mathlib.Data.List.Sort
import Mathlib.Tactic.Linarith

/-!
# Gate 0.2 — extremal prefix allocation vs the sum-local filter class

## Formal claim (precise)

Let `SumAgg` be the observation interface `(totalSize, count, demand)` and let a
**sum-local selector** be any `phi : Claim → SumAgg → Bool`. The class
`LocalSel phi` is closed under the finite grammar `SumLocalProg` (atomic
selectors and conjunction). No program in that class can match **general**
extremal prefix fill on both of the two-claim unit-demand populations below.

That is the invariant every `SumLocalProg` composite preserves (still some
`LocalSel`) and extremal prefix fill breaks.

## What this is not

* Not the full F9 record of `REFUTATION.md` (no settlement price, limit vector,
  or conservation game). Extremal here is the **priority-order demand prefix**
  fragment used by R2 (Liquity-style walk).
* Not a claim that every Quint fold in the corpus is definitionally `LocalSel`.
  The reproducible bridge is the fold census artifact
  `sigma/GATE-0.2-FOLD-CENSUS.md` (**52** `acc + ...` folds and **1** identity fold);
  the formal theorem is about the sum-local filter class that census motivates.
* Not the delegated-allocation mandate refuter.
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

/-- Priority-then-id total preorder (ascending: earlier first). -/
def prioLE (a b : Claim) : Prop :=
  a.priority < b.priority ∨ (a.priority = b.priority ∧ a.id ≤ b.id)

instance : DecidableRel prioLE := fun a b => by
  dsimp [prioLE]; infer_instance

def prioLeB (a b : Claim) : Bool :=
  decide (prioLE a b)

/-- Take a demand-bounded prefix of an already priority-sorted list.
Partial last fill: the last claim is kept with `size` reduced to residual demand. -/
def takeDemand : List Claim → Nat → List Claim
  | _, 0 => []
  | [], _ => []
  | c :: rest, d =>
      if c.size ≥ d then
        [{ c with size := d }]
      else
        c :: takeDemand rest (d - c.size)

/-- **General extremal prefix fill:** sort by `prioLE`, then `takeDemand`. -/
def extremalFill (cs : List Claim) (demand : Nat) : List Claim :=
  takeDemand (cs.insertionSort prioLE) demand

/-- Selected claim ids (ignores partial-size annotation on the last fill). -/
def fillIds (cs : List Claim) (demand : Nat) : List Nat :=
  (extremalFill cs demand).map (fun c => c.id)

/-- Local (sum-aggregate) selection filter. -/
def LocalSel (phi : Claim → SumAgg → Bool) (cs : List Claim) (demand : Nat) :
    List Claim :=
  cs.filter (fun c => phi c (sumAgg cs demand))

def localIds (phi : Claim → SumAgg → Bool) (cs : List Claim) (demand : Nat) :
    List Nat :=
  (LocalSel phi cs demand).map (fun c => c.id)

/-! ## Sum-local program grammar and closure -/

/-- Finite programs that only ever filter by sum-local predicates. -/
inductive SumLocalProg : Type where
  | atom (phi : Claim → SumAgg → Bool)
  | and (p q : SumLocalProg)

/-- Interpretation: every program is some single filter predicate. -/
def SumLocalProg.eval : SumLocalProg → Claim → SumAgg → Bool
  | atom phi, c, g => phi c g
  | and p q, c, g => p.eval c g && q.eval c g

/-- Running a program is exactly `LocalSel` of its evaluation. -/
theorem run_eq_localSel (p : SumLocalProg) (cs : List Claim) (d : Nat) :
    cs.filter (fun c => p.eval c (sumAgg cs d)) = LocalSel p.eval cs d := by
  rfl

/-- **Closure / composite invariant:** conjunction of sum-local selectors is
still a sum-local selector (the evaluation of `and`). -/
theorem sumLocal_and_eval (p q : SumLocalProg) :
    (SumLocalProg.and p q).eval =
      fun c g => p.eval c g && q.eval c g := by
  rfl

/-- Conjunction of programs is still an evaluated selector (class closed under `and`). -/
theorem eval_and (p q : SumLocalProg) :
    (SumLocalProg.and p q).eval = fun c g => p.eval c g && q.eval c g := rfl

/-- Filtering by an `and` program equals sequential filtering at the same aggregate. -/
theorem localSel_and (p q : SumLocalProg) (cs : List Claim) (d : Nat) :
    LocalSel (SumLocalProg.and p q).eval cs d =
      (LocalSel p.eval cs d).filter (fun c => q.eval c (sumAgg cs d)) := by
  simp [LocalSel, SumLocalProg.eval, List.filter_filter, Bool.and_comm]

/-- Atomic programs are sum-local by definition. -/
theorem atom_is_local (phi : Claim → SumAgg → Bool) (cs : List Claim) (d : Nat) :
    LocalSel (SumLocalProg.atom phi).eval cs d = LocalSel phi cs d := by
  rfl

/-! ## Concrete separation witnesses -/

def cA : Claim := ⟨0, 1, 5⟩
def cB : Claim := ⟨1, 1, 10⟩
def cC : Claim := ⟨2, 1, 3⟩

theorem sumAgg_AB : sumAgg [cA, cB] 1 = ⟨2, 2, 1⟩ := by decide
theorem sumAgg_AC : sumAgg [cA, cC] 1 = ⟨2, 2, 1⟩ := by decide
theorem sumAgg_eq : sumAgg [cA, cB] 1 = sumAgg [cA, cC] 1 := by
  simp [sumAgg_AB, sumAgg_AC]

theorem prioLE_AB : prioLE cA cB := by dsimp [prioLE, cA, cB]; decide
theorem not_prioLE_AC : ¬ prioLE cA cC := by dsimp [prioLE, cA, cC]; decide
theorem prioLE_CA : prioLE cC cA := by dsimp [prioLE, cC, cA]; decide

/-- insertionSort of two elements when the first is already earlier. -/
theorem sort_AB : [cA, cB].insertionSort prioLE = [cA, cB] := by
  rw [List.insertionSort_cons, List.insertionSort_cons, List.insertionSort_nil]
  -- orderedInsert cA (orderedInsert cB [])
  have hb : List.orderedInsert (r := prioLE) cB ([] : List Claim) = [cB] := by
    simp [List.orderedInsert]
  rw [hb]
  exact List.orderedInsert_cons_of_le (r := prioLE) (a := cA) (b := cB) (l := []) prioLE_AB

theorem sort_AC : [cA, cC].insertionSort prioLE = [cC, cA] := by
  rw [List.insertionSort_cons, List.insertionSort_cons, List.insertionSort_nil]
  have hc : List.orderedInsert (r := prioLE) cC ([] : List Claim) = [cC] := by
    simp [List.orderedInsert]
  rw [hc]
  have h := List.orderedInsert_of_not_le (r := prioLE) (a := cA) (b := cC) (l := []) not_prioLE_AC
  rw [h]
  have ha : List.orderedInsert (r := prioLE) cA ([] : List Claim) = [cA] := by
    simp [List.orderedInsert]
  rw [ha]

theorem takeDemand_unit (c : Claim) (hc : c.size = 1) :
    takeDemand [c] 1 = [{ c with size := 1 }] := by
  simp [takeDemand, hc]

theorem extremal_AB :
    (extremalFill [cA, cB] 1).map (fun c => c.id) = [0] := by
  unfold extremalFill
  rw [sort_AB]
  simp [takeDemand, cA]

theorem extremal_AC :
    (extremalFill [cA, cC] 1).map (fun c => c.id) = [2] := by
  unfold extremalFill
  rw [sort_AC]
  -- takeDemand [cC, cA] 1 = [{cC with size := 1}]
  simp [takeDemand, cC]

theorem mem_localSel_iff (phi : Claim → SumAgg → Bool) (c : Claim)
    (cs : List Claim) (d : Nat) :
    c ∈ LocalSel phi cs d ↔ c ∈ cs ∧ phi c (sumAgg cs d) = true := by
  simp [LocalSel, List.mem_filter]

theorem phi_accepts_cA_of_AB (phi : Claim → SumAgg → Bool)
    (h : localIds phi [cA, cB] 1 = [0]) :
    phi cA (sumAgg [cA, cB] 1) = true := by
  have hin : 0 ∈ localIds phi [cA, cB] 1 := by simp [h]
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

theorem phi_rejects_cA_of_AC (phi : Claim → SumAgg → Bool)
    (h : localIds phi [cA, cC] 1 = [2]) :
    phi cA (sumAgg [cA, cC] 1) = false := by
  by_contra hne
  have ht : phi cA (sumAgg [cA, cC] 1) = true := by
    cases hphi : phi cA (sumAgg [cA, cC] 1) with
    | true => rfl
    | false => exact (hne hphi).elim
  have hmem : cA ∈ LocalSel phi [cA, cC] 1 :=
    (mem_localSel_iff phi cA [cA, cC] 1).2 ⟨by simp, ht⟩
  have : 0 ∈ localIds phi [cA, cC] 1 := by
    refine List.mem_map.2 ?_
    exact ⟨cA, hmem, rfl⟩
  simp [h] at this

/-- No sum-local **filter** matches general extremal fill on both witnesses. -/
theorem extremal_not_local :
    ¬ ∃ (phi : Claim → SumAgg → Bool),
      localIds phi [cA, cB] 1 = fillIds [cA, cB] 1 ∧
      localIds phi [cA, cC] 1 = fillIds [cA, cC] 1 := by
  rintro ⟨phi, hAB, hAC⟩
  have hAB' : localIds phi [cA, cB] 1 = [0] := by
    simpa [fillIds, extremal_AB] using hAB
  have hAC' : localIds phi [cA, cC] 1 = [2] := by
    simpa [fillIds, extremal_AC] using hAC
  have ht := phi_accepts_cA_of_AB phi hAB'
  have hf := phi_rejects_cA_of_AC phi hAC'
  rw [sumAgg_eq] at ht
  simp [ht] at hf

/-- **Main gate theorem:** no `SumLocalProg` (including composites under `and`)
matches extremal prefix fill on both witnesses. -/
theorem extremal_not_sumLocalProg :
    ¬ ∃ (p : SumLocalProg),
      localIds p.eval [cA, cB] 1 = fillIds [cA, cB] 1 ∧
      localIds p.eval [cA, cC] 1 = fillIds [cA, cC] 1 := by
  rintro ⟨p, hAB, hAC⟩
  exact extremal_not_local ⟨p.eval, hAB, hAC⟩

/-- Roadmap name: F9-style extremal prefix is outside the sum-local program class. -/
theorem f9_irreducible_to_sum_local :
    ¬ ∃ (p : SumLocalProg),
      localIds p.eval [cA, cB] 1 = fillIds [cA, cB] 1 ∧
      localIds p.eval [cA, cC] 1 = fillIds [cA, cC] 1 :=
  extremal_not_sumLocalProg

end Defialgebra.Extremal
