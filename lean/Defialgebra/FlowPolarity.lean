/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charles Hoskinson
-/
import Mathlib.Data.Nat.Basic
import Mathlib.Algebra.Order.Floor.Div
import Mathlib.Tactic.Linarith

/-!
# M2 — polarity of Q flows

`INTERFACE-COUNCIL.md` §3: invariant (iii) "rounding never favours the caller" is
not a state predicate. It is the polarity of a Q flow. Given polarity it is
statable — ceil on inbound, floor on outbound.

## What is proved

* `settle` / `AntiCaller` / `antiCaller_settle` — the local anti-caller inequalities.
* `DirectedEdge.antiCaller_both` — a connected transfer has **outbound at the
  source and inbound at the sink**; both endpoints satisfy `AntiCaller`.
* `antiCaller_broken_if_polarity_flipped` — floor used as an inbound charge
  under-charges the caller (negative companion).
* `directedEdge_broken_if_same_polarity` — if both ends are tagged outbound, the
  sink fails the inbound inequality under floor settlement.

## What is not proved (honest scope)

* No fusion, no full `Prop` algebra, no n-ary composition / associativity (M3).
* No signed quantities beyond the polarity tag; amounts remain `Nat`.
* No corpus mapping (M4). Denominator zero is excluded by `Flow.hc`.
-/

namespace Defialgebra.FlowPolarity

/-- Direction of a Q flow relative to a construction.
* `inbound` — the caller pays the machine.
* `outbound` — the machine pays the caller. -/
inductive Pol where
  | inbound
  | outbound
  deriving DecidableEq, Repr

/-- Floor fused proportion `π(a,b,c) = ⌊a·b/c⌋` (zero when `c = 0`). -/
def floorDiv (a b c : Nat) : Nat :=
  if c = 0 then 0 else a * b / c

/-- Ceil fused proportion (zero when `c = 0`). -/
def ceilDiv (a b c : Nat) : Nat :=
  if c = 0 then 0 else (a * b + (c - 1)) / c

/-- The anti-caller policy: ceil inbound, floor outbound. -/
def settle (p : Pol) (a b c : Nat) : Nat :=
  match p with
  | .inbound => ceilDiv a b c
  | .outbound => floorDiv a b c

/-- `settle` never favours the caller relative to `a·b/c`. -/
def AntiCaller (p : Pol) (a b c : Nat) : Prop :=
  match p with
  | .outbound => c * settle .outbound a b c ≤ a * b
  | .inbound => c = 0 ∨ a * b ≤ c * settle .inbound a b c

theorem floorDiv_le (a b c : Nat) : c * floorDiv a b c ≤ a * b := by
  unfold floorDiv
  split_ifs with h
  · simp [h]
  · exact Nat.mul_div_le (a * b) c

theorem le_ceilDiv (a b c : Nat) (hc : c ≠ 0) :
    a * b ≤ c * ceilDiv a b c := by
  unfold ceilDiv
  simp only [hc, ↓reduceIte]
  have hcpos : 0 < c := Nat.pos_of_ne_zero hc
  have hle : a * b ≤ c * ((a * b) ⌈/⌉ c) :=
    le_smul_ceilDiv (α := ℕ) (β := ℕ) (b := a * b) hcpos
  convert hle using 2
  rw [Nat.ceilDiv_eq_add_pred_div]
  congr 1
  omega

theorem antiCaller_settle (p : Pol) (a b c : Nat) : AntiCaller p a b c := by
  cases p with
  | outbound =>
    simpa [AntiCaller, settle] using floorDiv_le a b c
  | inbound =>
    simp only [AntiCaller, settle]
    by_cases hc : c = 0
    · exact Or.inl hc
    · exact Or.inr (le_ceilDiv a b c hc)

/-- A well-formed proportional settlement request: positive denominator. -/
structure Flow where
  /-- Polarity relative to the construction that owns this endpoint. -/
  pol : Pol
  a : Nat
  b : Nat
  c : Nat
  /-- Non-economic `c = 0` inputs are excluded. -/
  hc : c ≠ 0

/-- Settled amount under the anti-caller policy. -/
def Flow.amount (f : Flow) : Nat := settle f.pol f.a f.b f.c

theorem Flow.antiCaller (f : Flow) : AntiCaller f.pol f.a f.b f.c :=
  antiCaller_settle f.pol f.a f.b f.c

/-- **Directed composition of polarities.** A Q transfer across a boundary is
outbound at the source construction and inbound at the sink. This is the M2
stand-in for the directed subcategory before M3's n-ary global binding. -/
structure DirectedEdge where
  src : Flow
  dst : Flow
  hsrc : src.pol = .outbound
  hdst : dst.pol = .inbound

/-- Both endpoints of a correctly-oriented edge satisfy the anti-caller law. -/
theorem DirectedEdge.antiCaller_both (e : DirectedEdge) :
    AntiCaller .outbound e.src.a e.src.b e.src.c ∧
    AntiCaller .inbound e.dst.a e.dst.b e.dst.c := by
  constructor
  · have := e.src.antiCaller
    simpa [e.hsrc] using this
  · have := e.dst.antiCaller
    simpa [e.hdst] using this

/-- Negative companion (local): floor used as inbound charge under-charges. -/
theorem antiCaller_broken_if_polarity_flipped :
    ∃ (a b c : Nat),
      AntiCaller .outbound a b c ∧
      AntiCaller .inbound a b c ∧
      ¬ (a * b ≤ c * floorDiv a b c) ∧
      floorDiv a b c ≠ ceilDiv a b c := by
  refine ⟨1, 1, 2, ?_, ?_, ?_, ?_⟩
  · simp [AntiCaller, settle, floorDiv]
  · simp [AntiCaller, settle, ceilDiv]
  · simp [floorDiv]
  · simp [floorDiv, ceilDiv]

/-- **Negative companion (compositional).** Tag both ends outbound and settle the
sink with floor: the inbound inequality fails on `(1,1,2)`. Orientation is
load-bearing for the directed edge, not decorative. -/
theorem directedEdge_broken_if_same_polarity :
    ∃ (src dst : Flow),
      src.pol = .outbound ∧
      dst.pol = .outbound ∧
      AntiCaller .outbound src.a src.b src.c ∧
      ¬ (dst.a * dst.b ≤ dst.c * floorDiv dst.a dst.b dst.c) := by
  let src : Flow := ⟨.outbound, 2, 1, 1, by decide⟩
  let dst : Flow := ⟨.outbound, 1, 1, 2, by decide⟩
  refine ⟨src, dst, rfl, rfl, ?_, ?_⟩
  · simp [AntiCaller, settle, floorDiv, src]
  · simp [floorDiv, dst]

end Defialgebra.FlowPolarity
