import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod
import Mathlib.Tactic.Linarith

/-!
A finite reference ledger with exact rational arithmetic. Asset indices distinguish units;
nonnegative quantities and states exclude negative holdings. Effects are signed changes.
Authority policy and environment inputs are supplied assumptions, not authenticated facts.
Authority checks concern net debits, not intermediate execution traces.
Only write locality is checked: this pilot does not track reads or prove composition.
-/
namespace DefiKernel

inductive Account where
  | alice | bob | vault | pool
  deriving DecidableEq, Repr

inductive Asset where
  | usd | share | collateral | debt
  deriving DecidableEq, Repr

instance : Fintype Account := ⟨{.alice, .bob, .vault, .pool}, by
  intro x; cases x <;> simp⟩

instance : Fintype Asset := ⟨{.usd, .share, .collateral, .debt}, by
  intro x; cases x <;> simp⟩

abbrev Cell := Account × Asset

/-- Exact nonnegative quantity in the unit of asset `a`. -/
structure Quantity (a : Asset) where
  amount : ℚ
  nonneg : 0 ≤ amount

def Quantity.ofNat {a : Asset} (n : ℕ) : Quantity a := ⟨n, by positivity⟩

/-- Debt is a separate nonnegative obligation token, not a negative cash balance. -/
structure State where
  balance : Cell → ℚ
  nonneg : ∀ c, 0 ≤ balance c

/-- External capability policy. Permission to debit and to change supply are separate. -/
structure Policy where
  debit : Account → Cell → Bool
  supply : Account → Asset → Bool

/-- A proposal with explicit net effects, per-asset issuance/burn, and write footprint. -/
structure Transition (Env : Type) where
  actor : Account
  effect : Cell → ℚ
  supplyChange : Asset → ℚ
  writes : Finset Cell
  guard : State → Env → Bool

inductive Refusal where
  | guard | unauthorizedDebit | unauthorizedSupply | insufficientFunds | accounting | footprint
  deriving DecidableEq, Repr

def DebitAuthorized {E : Type} (p : Policy) (t : Transition E) : Prop :=
  ∀ c, t.effect c < 0 → p.debit t.actor c = true

def SupplyAuthorized {E : Type} (p : Policy) (t : Transition E) : Prop :=
  ∀ a, t.supplyChange a ≠ 0 → p.supply t.actor a = true

def NonnegativeUpdate {E : Type} (s : State) (t : Transition E) : Prop :=
  ∀ c, 0 ≤ s.balance c + t.effect c

def Accounted {E : Type} (t : Transition E) : Prop :=
  ∀ a, ∑ owner, t.effect (owner, a) = t.supplyChange a

def Local {E : Type} (t : Transition E) : Prop :=
  ∀ c, c ∉ t.writes → t.effect c = 0

instance {E : Type} (p : Policy) (t : Transition E) : Decidable (DebitAuthorized p t) :=
  inferInstanceAs (Decidable (∀ c, t.effect c < 0 → p.debit t.actor c = true))
instance {E : Type} (p : Policy) (t : Transition E) : Decidable (SupplyAuthorized p t) :=
  inferInstanceAs (Decidable (∀ a, t.supplyChange a ≠ 0 → p.supply t.actor a = true))
instance {E : Type} (s : State) (t : Transition E) : Decidable (NonnegativeUpdate s t) :=
  inferInstanceAs (Decidable (∀ c, 0 ≤ s.balance c + t.effect c))
instance {E : Type} (t : Transition E) : Decidable (Accounted t) :=
  inferInstanceAs (Decidable (∀ a, ∑ owner, t.effect (owner, a) = t.supplyChange a))
instance {E : Type} (t : Transition E) : Decidable (Local t) :=
  inferInstanceAs (Decidable (∀ c, c ∉ t.writes → t.effect c = 0))

/-- Checks actual finite effects. The first failing check determines the refusal reason. -/
def check {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
    Option Refusal :=
  if t.guard s env = false then some .guard
  else if ¬ DebitAuthorized p t then some .unauthorizedDebit
  else if ¬ SupplyAuthorized p t then some .unauthorizedSupply
  else if ¬ NonnegativeUpdate s t then some .insufficientFunds
  else if ¬ Accounted t then some .accounting
  else if ¬ Local t then some .footprint
  else none

/-- The explicit conjunction checked by `check`; no inference of external truth is claimed. -/
def Valid {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) : Prop :=
  t.guard s env = true ∧ DebitAuthorized p t ∧ SupplyAuthorized p t ∧
    NonnegativeUpdate s t ∧ Accounted t ∧ Local t

theorem check_eq_none_iff {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
    check p env t s = none ↔ Valid p env t s := by
  by_cases hg : t.guard s env = true
  · by_cases hd : DebitAuthorized p t <;>
      by_cases hs : SupplyAuthorized p t <;>
      by_cases hn : NonnegativeUpdate s t <;>
      by_cases ha : Accounted t <;>
      by_cases hl : Local t <;> simp [check, Valid, hg, hd, hs, hn, ha, hl]
  · have hf : t.guard s env = false := Bool.eq_false_iff.mpr hg
    simp [check, Valid, hf]

/-- Apply a checked effect; its nonnegativity proof constructs the resulting state. -/
def applyEffect {E : Type} (s : State) (t : Transition E) (h : NonnegativeUpdate s t) : State :=
  ⟨fun c ↦ s.balance c + t.effect c, h⟩

/-- Refusal has no post-state; successful execution constructs a nonnegative state. -/
def execute {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
    Except Refusal State :=
  match h : check p env t s with
  | some reason => .error reason
  | none => .ok (applyEffect s t ((check_eq_none_iff p env t s).mp h).2.2.2.1)

def total (s : State) (a : Asset) : ℚ := ∑ owner, s.balance (owner, a)

/-- Accounting is asset-wise and includes explicit authorized issuance or burn. -/
theorem applyEffect_accounting {E : Type} (s : State) (t : Transition E)
    (h : NonnegativeUpdate s t) (ha : Accounted t) (a : Asset) :
    total (applyEffect s t h) a = total s a + t.supplyChange a := by
  simp only [total, applyEffect, Finset.sum_add_distrib, ha a]

theorem applyEffect_locality {E : Type} (s : State) (t : Transition E)
    (h : NonnegativeUpdate s t) (hl : Local t) (c : Cell) (hc : c ∉ t.writes) :
    (applyEffect s t h).balance c = s.balance c := by
  simp [applyEffect, hl c hc]

/-- A framed predicate must explicitly depend only on observations outside the write set. -/
theorem applyEffect_frame {E : Type} (s : State) (t : Transition E)
    (h : NonnegativeUpdate s t) (hl : Local t) (P : State → Prop)
    (depends : ∀ s₁ s₂ : State,
      (∀ c, c ∉ t.writes → s₁.balance c = s₂.balance c) → (P s₁ ↔ P s₂))
    (hp : P s) : P (applyEffect s t h) := by
  apply (depends s (applyEffect s t h) ?_).mp hp
  intro c hc
  exact (applyEffect_locality s t h hl c hc).symm

/-- Success entails the checks and the precise state update, linking execution to the proofs. -/
theorem execute_ok_iff {E : Type} (p : Policy) (env : E) (t : Transition E)
    (s s' : State) : execute p env t s = .ok s' ↔
      ∃ h : Valid p env t s, applyEffect s t h.2.2.2.1 = s' := by
  unfold execute
  split
  next reason he =>
    simp only [reduceCtorEq, false_iff, not_exists]
    intro hv
    have hn := (check_eq_none_iff p env t s).mpr hv
    simp [he] at hn
  next he =>
    constructor
    · intro hs
      exact ⟨(check_eq_none_iff p env t s).mp he, Except.ok.inj hs⟩
    · rintro ⟨hv, rfl⟩
      rfl

/-- Every accepted net debit has the supplied policy's authority.
Identity authentication is external. -/
theorem execute_authority {E : Type} (p : Policy) (env : E) (t : Transition E)
    (s s' : State) (h : execute p env t s = .ok s') :
    DebitAuthorized p t ∧ SupplyAuthorized p t := by
  obtain ⟨hv, _⟩ := (execute_ok_iff p env t s s').mp h
  exact ⟨hv.2.1, hv.2.2.1⟩

theorem execute_accounting {E : Type} (p : Policy) (env : E) (t : Transition E)
    (s s' : State) (h : execute p env t s = .ok s') (a : Asset) :
    total s' a = total s a + t.supplyChange a := by
  obtain ⟨hv, rfl⟩ := (execute_ok_iff p env t s s').mp h
  exact applyEffect_accounting s t hv.2.2.2.1 hv.2.2.2.2.1 a

theorem execute_locality {E : Type} (p : Policy) (env : E) (t : Transition E)
    (s s' : State) (h : execute p env t s = .ok s') (c : Cell) (hc : c ∉ t.writes) :
    s'.balance c = s.balance c := by
  obtain ⟨hv, rfl⟩ := (execute_ok_iff p env t s s').mp h
  exact applyEffect_locality s t hv.2.2.2.1 hv.2.2.2.2.2 c hc

end DefiKernel
