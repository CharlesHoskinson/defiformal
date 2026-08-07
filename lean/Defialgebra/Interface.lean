/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.

# The interface discipline for `⋈`

`BASIS.md` §5 composes constructions along a coupling `κ` that "identifies only
carriers of the same sort". `P1 · Led` has carrier `(N ⇀ Q) × Q` — a balance map and
a declared total — with the law `‖bal‖ = sup`. But `sup` is merely sort `Q`, so `κ`
may glue it to an unrelated `Q` of the partner, whose transitions then write it while
the balance map is untouched. **Conservation dies under plain interleaving, with no
fusion involved**, and the invariant induction §5 relies on has no proof.

Four independent designs (`sigma/INTERFACE-COUNCIL.md`) converged on one fix:
*the declared total is not a shareable thing*. This file is the Lean statement of it.

* `Ledger.sup_not_port` — the discipline, carried as a well-formedness field rather
  than proved. This is the whole fix.
* `cons_of_portConfined` — a foreign transition confined to a ledger's ports, and
  `Q`-neutral on the ports it shares, preserves `‖bal‖ = sup`.
* `cons_broken_if_sup_is_port` — **the negative companion.** Drop `sup ∉ ports` and
  the same theorem is false, by explicit counterexample. Without this the result
  could hold vacuously, which is the failure mode this programme keeps finding.

SCOPE, stated plainly. Sorts are not modelled: state here is `Idx → ℤ`, because
conservation quantifies over `Q` alone and the sort discipline is a separate
concern. Fusion, polarity of `Q` flows, and associativity are M2/M3 and are absent.
What is proved is exactly the milestone: the coupling defect is real, and
`sup ∉ ports` closes it.
-/
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.Ring.Int

namespace Defialgebra.Interface

variable {Idx : Type*} [DecidableEq Idx]

/-- The state of a construction, restricted to its `Q` carriers. -/
def St (Idx : Type*) : Type _ := Idx → ℤ

/-- A `Led` block: the balance indices, the declared total, and the ports it
exposes to a coupling.

`bal : N ⇀ Q` is modelled as `N`-many `Q`-carriers rather than one map carrier.
That is faithful to §5's "`S` a finite product of carriers", and it is what makes
the defect *sayable*: `sup` is a different index from every balance, so a port list
can contain the balances and exclude the total. -/
structure Ledger (Idx : Type*) where
  /-- The indices holding individual balances. -/
  bals : Finset Idx
  /-- The index holding the declared total. -/
  sup : Idx
  /-- The indices a coupling is permitted to bind. -/
  ports : Finset Idx
  /-- The total is not one of the balances. -/
  sup_not_bal : sup ∉ bals
  /-- **THE INTERFACE DISCIPLINE.** The declared total is never a port, so no
  coupling can bind it and no foreign transition can write it. Carried as a
  well-formedness condition, not derived. -/
  sup_not_port : sup ∉ ports

/-- `P1 · Led`'s law: `‖bal‖ = sup`. -/
def Cons (L : Ledger Idx) (s : St Idx) : Prop :=
  ∑ i ∈ L.bals, s i = s L.sup

/-- `f` touches nothing outside `P` — what a coupling confines a partner to. -/
def WritesWithin (P : Finset Idx) (f : St Idx → St Idx) : Prop :=
  ∀ s i, i ∉ P → f s i = s i

/-- `f` moves no net quantity across the ports it shares with `L`. A transfer that
debits one shared balance and credits another satisfies this; a mint into a shared
balance does not. -/
def QNeutralOn (P : Finset Idx) (L : Ledger Idx) (f : St Idx → St Idx) : Prop :=
  ∀ s, ∑ i ∈ L.bals.filter (· ∈ P), f s i
        = ∑ i ∈ L.bals.filter (· ∈ P), s i

/-- **The milestone.** A foreign transition confined to `L`'s ports and `Q`-neutral
on the shared balances preserves conservation.

The proof is three lines and every one of them is the discipline doing work: the
total is untouched *because it is not a port*; the private balances are untouched
*because the transition is confined to ports*; the shared balances net to zero *by
hypothesis*. Remove `sup_not_port` and the first line fails — see
`cons_broken_if_sup_is_port`. -/
theorem cons_of_portConfined (L : Ledger Idx) (f : St Idx → St Idx)
    (hw : WritesWithin L.ports f) (hq : QNeutralOn L.ports L f)
    (s : St Idx) (h : Cons L s) : Cons L (f s) := by
  have hsup : f s L.sup = s L.sup := hw s L.sup L.sup_not_port
  have hsum : ∑ i ∈ L.bals, f s i = ∑ i ∈ L.bals, s i := by
    rw [← Finset.sum_filter_add_sum_filter_not L.bals (· ∈ L.ports) (f s),
        ← Finset.sum_filter_add_sum_filter_not L.bals (· ∈ L.ports) s, hq s]
    congr 1
    refine Finset.sum_congr rfl ?_
    intro i hi
    exact hw s i (by simpa using (Finset.mem_filter.mp hi).2)
  unfold Cons at h ⊢
  rw [hsum, hsup, h]

omit [DecidableEq Idx] in
/-- The frame case: a transition touching none of a ledger's carriers preserves
conservation. Immediate, and worth stating because it is what makes composition
with an unrelated machine free. -/
theorem cons_of_disjoint (L : Ledger Idx) (f : St Idx → St Idx)
    (P : Finset Idx) (hw : WritesWithin P f)
    (hb : ∀ i ∈ L.bals, i ∉ P) (hs : L.sup ∉ P)
    (s : St Idx) (h : Cons L s) : Cons L (f s) := by
  have hsum : ∑ i ∈ L.bals, f s i = ∑ i ∈ L.bals, s i :=
    Finset.sum_congr rfl fun i hi => hw s i (hb i hi)
  unfold Cons at h ⊢
  rw [hsum, hw s L.sup hs, h]

/-- **The negative companion, and the point of the whole file.**

Drop `sup ∉ ports` and `cons_of_portConfined` is false. Here is the witness: one
balance, one total, and a partner permitted to bind the total. The partner writes
only its permitted index and is `Q`-neutral on the shared balances — vacuously, since
it shares none — yet conservation breaks.

This is exactly the coupling `BASIS.md` §5 admits, since `sup` is merely sort `Q`
and `κ` identifies same-sort carriers. -/
theorem cons_broken_if_sup_is_port :
    ∃ (bals : Finset Bool) (sup : Bool) (ports : Finset Bool)
      (f : St Bool → St Bool) (s : St Bool),
      sup ∉ bals ∧
      sup ∈ ports ∧                                    -- the discipline VIOLATED
      WritesWithin ports f ∧                           -- confined to its ports
      (∀ t, ∑ i ∈ bals.filter (· ∈ ports), f t i
            = ∑ i ∈ bals.filter (· ∈ ports), t i) ∧     -- Q-neutral on shared bals
      (∑ i ∈ bals, s i) = s sup ∧                      -- conservation HOLDS
      (∑ i ∈ bals, f s i) ≠ f s sup := by              -- and FAILS after
  -- No `classical`: `Bool` already has `DecidableEq`, and introducing
  -- `Classical.dec` makes the two `∅`s carry different instances, so
  -- `Finset.sum_empty` rewrites one side and not the other.
  refine ⟨{false}, true, {true},
          fun t i => if i = true then t i + 1 else t i,
          fun _ => 0, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · decide
  · decide
  · intro t i hi
    have : i ≠ true := by
      intro h; exact hi (by simp [h])
    simp [this]
  · -- The two sums are equal POINTWISE on an empty index set. Computing both to
    -- `0` via `Finset.sum_empty` rewrites only one side here; congruence avoids
    -- the question entirely.
    intro t
    refine Finset.sum_congr rfl ?_
    intro i hi
    have hfil : ({false} : Finset Bool).filter (· ∈ ({true} : Finset Bool)) = ∅ := by
      decide
    rw [hfil] at hi
    exact absurd hi (Finset.notMem_empty i)
  · simp
  · simp

end Defialgebra.Interface
