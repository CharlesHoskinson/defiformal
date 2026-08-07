/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charles Hoskinson
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Fintype.Basic
import Mathlib.Tactic.Linarith

/-!
# M3 — n-ary binding and bracket-independent agreement

`INTERFACE-COUNCIL.md` §2: pair-local `κ` makes associativity *unstatable*, because
`κ` is attached to a pair, not to an object. The remedy is **stable port names**
plus **n-ary composition over a global binding set**.

## What is proved

* `Binding` — a finite set of port-pairs (global names).
* `Agrees` — state agreement on every bound pair.
* `agrees_iff_agrees_sym` — agreement depends only on the symmetric closure
  (pair orientation does not matter).
* `agrees_union`, `union_assoc`, `agrees_union_assoc` — multi-party composition
  is constraint-union; union is associative, so bracketing does not change
  agreement.
* `agrees_of_same_symClosure` — **two-binding reindex:** if two bindings have
  equal symmetric closures, they induce the same agreement predicate (listing
  order / pair orientation / redundant reverse edges do not matter).
* `pairLocal_excludes_skip` — **negative companion.** Pair-local edges on a
  binary cut cannot include a skip edge with both ends on the same side.
* `skip_not_pairLocal_witness` — concrete three-port witness.

## What is not proved

* Operational transition systems / reachability.
* Lifting M1 conservation through transitions.
* Corpus adequacy (M4).
-/

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false

namespace Defialgebra.Nary

variable {Idx : Type*} [DecidableEq Idx]

/-- A construction exposes a finite set of globally named ports. -/
structure Machine (Idx : Type*) where
  ports : Finset Idx

/-- Global binding: port-pairs that must carry equal state. -/
structure Binding (Idx : Type*) where
  pairs : Finset (Idx × Idx)

def St (Idx : Type*) : Type _ := Idx → ℤ

def PairAgrees (s : St Idx) (p : Idx × Idx) : Prop :=
  s p.1 = s p.2

def Agrees (B : Binding Idx) (s : St Idx) : Prop :=
  ∀ p ∈ B.pairs, PairAgrees s p

def symClosure (P : Finset (Idx × Idx)) : Finset (Idx × Idx) :=
  P ∪ P.image (fun p => (p.2, p.1))

theorem agrees_iff_agrees_sym (B : Binding Idx) (s : St Idx) :
    Agrees B s ↔ (∀ p ∈ symClosure B.pairs, PairAgrees s p) := by
  constructor
  · intro h p hp
    simp only [symClosure, Finset.mem_union, Finset.mem_image] at hp
    rcases hp with hp | ⟨q, hq, rfl⟩
    · exact h p hp
    · exact (h q hq).symm
  · intro h p hp
    exact h p (by
      simp only [symClosure, Finset.mem_union]
      exact Or.inl hp)

def Binding.union (B₁ B₂ : Binding Idx) : Binding Idx where
  pairs := B₁.pairs ∪ B₂.pairs

theorem agrees_union (B₁ B₂ : Binding Idx) (s : St Idx) :
    Agrees (B₁.union B₂) s ↔ Agrees B₁ s ∧ Agrees B₂ s := by
  constructor
  · intro h
    exact ⟨fun p hp => h p (Finset.mem_union_left _ hp),
           fun p hp => h p (Finset.mem_union_right _ hp)⟩
  · rintro ⟨h₁, h₂⟩ p hp
    cases Finset.mem_union.1 hp with
    | inl hp => exact h₁ p hp
    | inr hp => exact h₂ p hp

theorem union_assoc (B₁ B₂ B₃ : Binding Idx) :
    (B₁.union B₂).union B₃ = B₁.union (B₂.union B₃) := by
  cases B₁; cases B₂; cases B₃
  simp [Binding.union, Finset.union_assoc]

theorem union_comm (B₁ B₂ : Binding Idx) :
    B₁.union B₂ = B₂.union B₁ := by
  cases B₁; cases B₂
  simp [Binding.union, Finset.union_comm]

/-- **Bracket independence.** Agreement under `((B₁ ∪ B₂) ∪ B₃)` iff under
`(B₁ ∪ (B₂ ∪ B₃))`. -/
theorem agrees_union_assoc (B₁ B₂ B₃ : Binding Idx) (s : St Idx) :
    Agrees ((B₁.union B₂).union B₃) s ↔ Agrees (B₁.union (B₂.union B₃)) s := by
  rw [union_assoc]

/-- **Two-binding reindex (M3-DESIGN item 4).** Bindings with the same symmetric
closure of pairs induce the same agreement predicate. Parenthesization of n-ary
composition is already ; this covers reordering and
re-orienting the declared pair list. -/
theorem agrees_of_same_symClosure (B₁ B₂ : Binding Idx) (s : St Idx)
    (h : symClosure B₁.pairs = symClosure B₂.pairs) :
    Agrees B₁ s ↔ Agrees B₂ s := by
  rw [agrees_iff_agrees_sym, agrees_iff_agrees_sym, h]

structure BinaryCut (Idx : Type*) where
  left : Finset Idx
  right : Finset Idx
  disjoint : Disjoint left right

/-- Pair-local κ: every edge spans the cut. -/
def PairLocal (C : BinaryCut Idx) (P : Finset (Idx × Idx)) : Prop :=
  ∀ p ∈ P,
    (p.1 ∈ C.left ∧ p.2 ∈ C.right) ∨ (p.1 ∈ C.right ∧ p.2 ∈ C.left)

/-- Skip edge: both ends on the left side (cannot be stated by pair-local κ). -/
def SkipEdge (C : BinaryCut Idx) (p : Idx × Idx) : Prop :=
  p.1 ∈ C.left ∧ p.2 ∈ C.left ∧ p.1 ≠ p.2

/-- **Negative companion.** Pair-local edge sets exclude skip edges. -/
theorem pairLocal_excludes_skip (C : BinaryCut Idx) (P : Finset (Idx × Idx))
    (hPL : PairLocal C P) {p : Idx × Idx} (hp : p ∈ P) (hS : SkipEdge C p) :
    False := by
  rcases hPL p hp with ⟨_, hR⟩ | ⟨hR, _⟩
  · exact Finset.disjoint_left.1 C.disjoint hS.2.1 hR
  · exact Finset.disjoint_left.1 C.disjoint hS.1 hR

private theorem cut02_1_disjoint :
    Disjoint ({(0 : Fin 3), 2} : Finset (Fin 3)) {1} := by
  decide

private def cut02_1 : BinaryCut (Fin 3) :=
  ⟨{0, 2}, {1}, cut02_1_disjoint⟩

private theorem skip02 : SkipEdge cut02_1 ((0 : Fin 3), 2) := by
  unfold SkipEdge cut02_1
  refine ⟨?_, ?_, ?_⟩
  · exact Finset.mem_insert_self (0 : Fin 3) {2}
  · exact Finset.mem_insert_of_mem (Finset.mem_singleton_self (2 : Fin 3))
  · exact by decide

/-- Concrete three-port witness: cut `{0,2} | {1}`, skip `(0,2)` is not pair-local
for any edge set containing it. -/
theorem skip_not_pairLocal_witness :
    ∃ (C : BinaryCut (Fin 3)) (p : Fin 3 × Fin 3),
      SkipEdge C p ∧
      ∀ P : Finset (Fin 3 × Fin 3), p ∈ P → ¬ PairLocal C P := by
  refine ⟨cut02_1, (0, 2), skip02, ?_⟩
  intro P hp hPL
  exact pairLocal_excludes_skip cut02_1 P hPL hp skip02

end Defialgebra.Nary
