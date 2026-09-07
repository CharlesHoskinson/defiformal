/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charles Hoskinson
-/

/-!
# Pairwise independence of the reduced basis `P = {Led, Prop, Cmp, Post}`

Gate 1.2: no primitive is a term over the others.

Toy term language whose constructors are the four generators plus constants.
For each primitive `X` we exhibit a target that uses `X`, and prove every term
in the language with `X` deleted has `usesX = false`.

Corpus witnesses: `research/positive-program/sigma/GATE-1.2-WITNESSES.md`.
-/

namespace Defialgebra.Independence

/-- Sorts of the toy algebra (subset of BASIS six). `Sort` is reserved in Lean. -/
inductive Ty where
  | qty    -- quantity Q
  | scalar -- Σ
  | bool   -- B
  | phase  -- Φ
  deriving DecidableEq, Repr

/-- Term constructors = reduced basis + constants. -/
inductive Term where
  | qConst (n : Int)
  | sConst (n : Int)
  | phConst (n : Nat)
  | ledCredit (amt : Term)
  | ledMove (amt : Term)
  | prop (a b c : Term)
  | cmpLe (a b : Term)
  | postS (v : Term)
  | postPh (v : Term)
  deriving Repr

/-- Typing (selected rules sufficient for targets). -/
inductive HasType : Term → Ty → Prop where
  | qConst (n : Int) : HasType (.qConst n) .qty
  | sConst (n : Int) : HasType (.sConst n) .scalar
  | phConst (n : Nat) : HasType (.phConst n) .phase
  | ledCredit {amt : Term} (h : HasType amt .qty) : HasType (.ledCredit amt) .qty
  | ledMove {amt : Term} (h : HasType amt .qty) : HasType (.ledMove amt) .qty
  | prop {a b c : Term}
      (ha : HasType a .qty) (hb : HasType b .qty) (hc : HasType c .qty) :
      HasType (.prop a b c) .qty
  | cmpLe {a b : Term} (ha : HasType a .qty) (hb : HasType b .qty) :
      HasType (.cmpLe a b) .bool
  | postS {v : Term} (h : HasType v .scalar) : HasType (.postS v) .scalar
  | postPh {v : Term} (h : HasType v .phase) : HasType (.postPh v) .phase

def usesLed : Term → Bool
  | .qConst _ | .sConst _ | .phConst _ => false
  | .ledCredit a => true || usesLed a
  | .ledMove a => true || usesLed a
  | .prop a b c => usesLed a || usesLed b || usesLed c
  | .cmpLe a b => usesLed a || usesLed b
  | .postS v | .postPh v => usesLed v

def usesProp : Term → Bool
  | .qConst _ | .sConst _ | .phConst _ => false
  | .ledCredit a | .ledMove a => usesProp a
  | .prop a b c => true || usesProp a || usesProp b || usesProp c
  | .cmpLe a b => usesProp a || usesProp b
  | .postS v | .postPh v => usesProp v

def usesCmp : Term → Bool
  | .qConst _ | .sConst _ | .phConst _ => false
  | .ledCredit a | .ledMove a => usesCmp a
  | .prop a b c => usesCmp a || usesCmp b || usesCmp c
  | .cmpLe a b => true || usesCmp a || usesCmp b
  | .postS v | .postPh v => usesCmp v

def usesPost : Term → Bool
  | .qConst _ | .sConst _ | .phConst _ => false
  | .ledCredit a | .ledMove a => usesPost a
  | .prop a b c => usesPost a || usesPost b || usesPost c
  | .cmpLe a b => usesPost a || usesPost b
  | .postS v => true || usesPost v
  | .postPh v => true || usesPost v

/-! ### Languages with one primitive deleted -/

inductive TermNoLed where
  | qConst (n : Int)
  | sConst (n : Int)
  | phConst (n : Nat)
  | prop (a b c : TermNoLed)
  | cmpLe (a b : TermNoLed)
  | postS (v : TermNoLed)
  | postPh (v : TermNoLed)

def TermNoLed.toTerm : TermNoLed → Term
  | .qConst n => .qConst n
  | .sConst n => .sConst n
  | .phConst n => .phConst n
  | .prop a b c => .prop a.toTerm b.toTerm c.toTerm
  | .cmpLe a b => .cmpLe a.toTerm b.toTerm
  | .postS v => .postS v.toTerm
  | .postPh v => .postPh v.toTerm

theorem TermNoLed.toTerm_not_usesLed (t : TermNoLed) : usesLed t.toTerm = false := by
  induction t <;> simp [TermNoLed.toTerm, usesLed, *]

inductive TermNoProp where
  | qConst (n : Int)
  | sConst (n : Int)
  | phConst (n : Nat)
  | ledCredit (a : TermNoProp)
  | ledMove (a : TermNoProp)
  | cmpLe (a b : TermNoProp)
  | postS (v : TermNoProp)
  | postPh (v : TermNoProp)

def TermNoProp.toTerm : TermNoProp → Term
  | .qConst n => .qConst n
  | .sConst n => .sConst n
  | .phConst n => .phConst n
  | .ledCredit a => .ledCredit a.toTerm
  | .ledMove a => .ledMove a.toTerm
  | .cmpLe a b => .cmpLe a.toTerm b.toTerm
  | .postS v => .postS v.toTerm
  | .postPh v => .postPh v.toTerm

theorem TermNoProp.toTerm_not_usesProp (t : TermNoProp) : usesProp t.toTerm = false := by
  induction t <;> simp [TermNoProp.toTerm, usesProp, *]

inductive TermNoCmp where
  | qConst (n : Int)
  | sConst (n : Int)
  | phConst (n : Nat)
  | ledCredit (a : TermNoCmp)
  | ledMove (a : TermNoCmp)
  | prop (a b c : TermNoCmp)
  | postS (v : TermNoCmp)
  | postPh (v : TermNoCmp)

def TermNoCmp.toTerm : TermNoCmp → Term
  | .qConst n => .qConst n
  | .sConst n => .sConst n
  | .phConst n => .phConst n
  | .ledCredit a => .ledCredit a.toTerm
  | .ledMove a => .ledMove a.toTerm
  | .prop a b c => .prop a.toTerm b.toTerm c.toTerm
  | .postS v => .postS v.toTerm
  | .postPh v => .postPh v.toTerm

theorem TermNoCmp.toTerm_not_usesCmp (t : TermNoCmp) : usesCmp t.toTerm = false := by
  induction t <;> simp [TermNoCmp.toTerm, usesCmp, *]

inductive TermNoPost where
  | qConst (n : Int)
  | sConst (n : Int)
  | phConst (n : Nat)
  | ledCredit (a : TermNoPost)
  | ledMove (a : TermNoPost)
  | prop (a b c : TermNoPost)
  | cmpLe (a b : TermNoPost)

def TermNoPost.toTerm : TermNoPost → Term
  | .qConst n => .qConst n
  | .sConst n => .sConst n
  | .phConst n => .phConst n
  | .ledCredit a => .ledCredit a.toTerm
  | .ledMove a => .ledMove a.toTerm
  | .prop a b c => .prop a.toTerm b.toTerm c.toTerm
  | .cmpLe a b => .cmpLe a.toTerm b.toTerm

theorem TermNoPost.toTerm_not_usesPost (t : TermNoPost) : usesPost t.toTerm = false := by
  induction t <;> simp [TermNoPost.toTerm, usesPost, *]

/-! ### Targets -/

def targetLed : Term := .ledCredit (.qConst 1)

theorem targetLed_usesLed : usesLed targetLed = true := by
  native_decide

theorem targetLed_typed : HasType targetLed .qty :=
  .ledCredit (.qConst 1)

def targetProp : Term := .prop (.qConst 100) (.qConst 50) (.qConst 200)

theorem targetProp_usesProp : usesProp targetProp = true := by
  native_decide

theorem targetProp_typed : HasType targetProp .qty :=
  .prop (.qConst 100) (.qConst 50) (.qConst 200)

def targetCmp : Term := .cmpLe (.qConst 150) (.qConst 100)

theorem targetCmp_usesCmp : usesCmp targetCmp = true := by
  native_decide

theorem targetCmp_typed : HasType targetCmp .bool :=
  .cmpLe (.qConst 150) (.qConst 100)

def targetPost : Term := .postS (.sConst 42)

theorem targetPost_usesPost : usesPost targetPost = true := by
  native_decide

theorem targetPost_typed : HasType targetPost .scalar :=
  .postS (.sConst 42)

/-! ### Non-definability -/

theorem led_not_definable_from_rest (t : TermNoLed) :
    usesLed t.toTerm ≠ usesLed targetLed := by
  rw [t.toTerm_not_usesLed, targetLed_usesLed]
  decide

theorem prop_not_definable_from_rest (t : TermNoProp) :
    usesProp t.toTerm ≠ usesProp targetProp := by
  rw [t.toTerm_not_usesProp, targetProp_usesProp]
  decide

theorem cmp_not_definable_from_rest (t : TermNoCmp) :
    usesCmp t.toTerm ≠ usesCmp targetCmp := by
  rw [t.toTerm_not_usesCmp, targetCmp_usesCmp]
  decide

theorem post_not_definable_from_rest (t : TermNoPost) :
    usesPost t.toTerm ≠ usesPost targetPost := by
  rw [t.toTerm_not_usesPost, targetPost_usesPost]
  decide

theorem pairwise_independence :
    (∀ t : TermNoLed, usesLed t.toTerm ≠ usesLed targetLed) ∧
    (∀ t : TermNoProp, usesProp t.toTerm ≠ usesProp targetProp) ∧
    (∀ t : TermNoCmp, usesCmp t.toTerm ≠ usesCmp targetCmp) ∧
    (∀ t : TermNoPost, usesPost t.toTerm ≠ usesPost targetPost) :=
  ⟨led_not_definable_from_rest, prop_not_definable_from_rest,
   cmp_not_definable_from_rest, post_not_definable_from_rest⟩

end Defialgebra.Independence
