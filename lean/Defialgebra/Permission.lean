/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.

# Permission-freedom and the closure of the basis

`BASIS.md` §5 defines a *construction* as `M = (S, s₀, →)` with `→` a finite set of
guarded updates `g ⊳ u`, and defines closure under a composition operator `⋈`.
`sigma/CHARACTERISATION.md` factors the state as `S ≅ P × R` — positions and a role
assignment — and calls a transition *permission-free* when its guard and effect
factor through `P`, so that `R` is a spectator coordinate.

This file proves the load-bearing lemma of that argument.

* `PermFree.seq`, `PermFree.restrict` — permission-freedom survives the two ways the
  closure builds composites: sequencing, and strengthening a guard by another.
* `permFree_of_gen` — hence every member of the closure of permission-free
  generators is permission-free.
* `not_gen_of_not_permFree` — so a permission-dependent transition lies outside it.
* `gated_not_permFree`, `mandate_not_in_closure` — and such a transition exists, so
  the statement is not vacuous.

The mathematical content is deliberately small, and that is the point. Once the state
is factored, irreducibility of the delegated allocation mandate is a spectator-
coordinate argument, not an argument about arithmetic. Nothing below constrains the
generators to be *conservative* — which matters, because the mandate satisfies
conservation exactly, and `BASIS.md`'s own stated refutation condition is therefore
blind to it.
-/

namespace Defialgebra.Permission

universe u v

/-- The state of a construction, factored into the **position** coordinate — every
sort the basis families read and write — and the **role** coordinate, the assignment
of permissions to principals. -/
structure St (Pos : Type u) (Role : Type v) where
  /-- Positions: quantities, scalars, time, phase. -/
  pos : Pos
  /-- The role assignment. -/
  role : Role

variable {Pos : Type u} {Role : Type v}

/-- A guarded update `g ⊳ u`. -/
structure Tr (Pos : Type u) (Role : Type v) where
  /-- The guard `g`. -/
  guard : St Pos Role → Prop
  /-- The simultaneous assignment `u`. -/
  eff : St Pos Role → St Pos Role

/-- A transition is **permission-free** when the role coordinate is a spectator: the
guard and the computed position both factor through `pos`, and the role is never
written. Every basis family has this property; the mandate does not. -/
structure PermFree (t : Tr Pos Role) : Prop where
  /-- The guard factors through the position coordinate. -/
  guard_indep : ∀ s s' : St Pos Role, s.pos = s'.pos → t.guard s → t.guard s'
  /-- The computed position factors through the position coordinate. -/
  eff_pos_indep : ∀ s s' : St Pos Role, s.pos = s'.pos → (t.eff s).pos = (t.eff s').pos
  /-- The role coordinate is never written. -/
  eff_role_fixed : ∀ s : St Pos Role, (t.eff s).role = s.role

/-- Sequential composition: run `t₁`, then `t₂`. -/
def seq (t₁ t₂ : Tr Pos Role) : Tr Pos Role where
  guard s := t₁.guard s ∧ t₂.guard (t₁.eff s)
  eff s := t₂.eff (t₁.eff s)

/-- Guard strengthening: `t₁`'s update, fired only when `t₂` is also enabled. This is
the `(g₁ ∧ g₂) ⊳ (u₁ ∥ u₂)` shape of a fused transition in the case where the two
updates agree, which is exactly the side condition `⋈` imposes on a coupling. -/
def restrict (t₁ t₂ : Tr Pos Role) : Tr Pos Role where
  guard s := t₁.guard s ∧ t₂.guard s
  eff := t₁.eff

/-- Permission-freedom survives sequencing. -/
theorem PermFree.seq {t₁ t₂ : Tr Pos Role} (h₁ : PermFree t₁) (h₂ : PermFree t₂) :
    PermFree (Defialgebra.Permission.seq t₁ t₂) where
  guard_indep s s' hp hg :=
    ⟨h₁.guard_indep s s' hp hg.1,
     h₂.guard_indep _ _ (h₁.eff_pos_indep s s' hp) hg.2⟩
  eff_pos_indep s s' hp := h₂.eff_pos_indep _ _ (h₁.eff_pos_indep s s' hp)
  eff_role_fixed s := by
    show (t₂.eff (t₁.eff s)).role = s.role
    rw [h₂.eff_role_fixed, h₁.eff_role_fixed]

/-- Permission-freedom survives guard strengthening. -/
theorem PermFree.restrict {t₁ t₂ : Tr Pos Role} (h₁ : PermFree t₁) (h₂ : PermFree t₂) :
    PermFree (Defialgebra.Permission.restrict t₁ t₂) where
  guard_indep s s' hp hg :=
    ⟨h₁.guard_indep s s' hp hg.1, h₂.guard_indep s s' hp hg.2⟩
  eff_pos_indep := h₁.eff_pos_indep
  eff_role_fixed := h₁.eff_role_fixed

/-- The closure of a family of generators under sequencing and guard strengthening. -/
inductive Gen (G : Tr Pos Role → Prop) : Tr Pos Role → Prop where
  /-- A generator is in the closure. -/
  | base {t : Tr Pos Role} : G t → Gen G t
  /-- The closure is closed under sequencing. -/
  | seq {t₁ t₂ : Tr Pos Role} :
      Gen G t₁ → Gen G t₂ → Gen G (Defialgebra.Permission.seq t₁ t₂)
  /-- The closure is closed under guard strengthening. -/
  | restrict {t₁ t₂ : Tr Pos Role} :
      Gen G t₁ → Gen G t₂ → Gen G (Defialgebra.Permission.restrict t₁ t₂)

/-- **The closure lemma.** If every generator is permission-free then so is every
composite: the role coordinate is a spectator for the entire closure. -/
theorem permFree_of_gen {G : Tr Pos Role → Prop} (hG : ∀ t, G t → PermFree t)
    {t : Tr Pos Role} (h : Gen G t) : PermFree t := by
  induction h with
  | base hb => exact hG _ hb
  | seq _ _ ih₁ ih₂ => exact ih₁.seq ih₂
  | restrict _ _ ih₁ ih₂ => exact ih₁.restrict ih₂

/-- **Irreducibility.** A permission-dependent transition is not in the closure of
permission-free generators. -/
theorem not_gen_of_not_permFree {G : Tr Pos Role → Prop} (hG : ∀ t, G t → PermFree t)
    {t : Tr Pos Role} (ht : ¬ PermFree t) : ¬ Gen G t :=
  fun h => ht (permFree_of_gen hG h)

/-- A minimal permission-dependent transition: enabled exactly when the caller holds
the role. This is `onlyAllocatorRole` with everything else stripped away. -/
def gated : Tr Unit Bool where
  guard s := s.role = true
  eff s := s

/-- The gate is not permission-free — identical positions, different role, different
enablement. -/
theorem gated_not_permFree : ¬ PermFree gated := by
  intro h
  have hfalse : gated.guard ⟨(), false⟩ :=
    h.guard_indep ⟨(), true⟩ ⟨(), false⟩ rfl rfl
  exact Bool.noConfusion hfalse

/-- **The theorem the programme needs.** No family of permission-free generators
generates the mandate, whatever those generators are. Conservation is irrelevant to
the obstruction: nothing above constrains the generators beyond the role coordinate
being a spectator for them. -/
theorem mandate_not_in_closure {G : Tr Unit Bool → Prop} (hG : ∀ t, G t → PermFree t) :
    ¬ Gen G gated :=
  not_gen_of_not_permFree hG gated_not_permFree

end Defialgebra.Permission
