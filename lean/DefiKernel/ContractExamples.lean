import DefiKernel.Contracts
import DefiKernel.Examples

/-! Financial library contracts over complete finite effects and explicit trusted parameters.
The vault has the reference rate two USD per share. These are not deployed protocol specifications.
Contract selection, actor identity, oracle provenance and locked-collateral meaning remain trusted.
Guard and write-set equality are deliberately absent: execution still enforces both base checks. -/
namespace DefiKernel.ContractExamples
open Examples Contracts

/-- Complete extensional shape: no unexamined balance cell or supply asset is permitted. -/
def Shape {E : Type} (t : Transition E) (actor : Account)
    (effect : Cell → ℚ) (supply : Asset → ℚ) : Prop :=
  t.actor = actor ∧ (∀ c, t.effect c = effect c) ∧ (∀ a, t.supplyChange a = supply a)

instance {E : Type} (t : Transition E) (actor : Account)
    (effect : Cell → ℚ) (supply : Asset → ℚ) : Decidable (Shape t actor effect supply) :=
  inferInstanceAs (Decidable (t.actor = actor ∧
    (∀ c, t.effect c = effect c) ∧ (∀ a, t.supplyChange a = supply a)))

def transferContract (actor src dst : Account) (q : Quantity .usd) : Contract Unit where
  accepts _ _ t := decide (Shape t actor (move .usd src dst q.amount) (fun _ ↦ 0))

def depositContract (actor vaultAccount : Account) (q : Quantity .usd) : Contract Unit where
  accepts _ _ t := decide (Shape t actor
    (fun c ↦ move .usd actor vaultAccount q.amount c + pulse (actor, .share) (q.amount / 2) c)
    (fun a ↦ if a = .share then q.amount / 2 else 0))

def withdrawContract (actor vaultAccount : Account) (q : Quantity .share) : Contract Unit where
  accepts _ _ t := decide (Shape t actor
    (fun c ↦ move .usd vaultAccount actor (2 * q.amount) c - pulse (actor, .share) q.amount c)
    (fun a ↦ if a = .share then -q.amount else 0))

/-- Independent pre-state oracle and collateral requirements, never read from the proposal guard. -/
def BorrowConditions (actor : Account) (q : Quantity .usd) (s : State) (oracle : Oracle) : Prop :=
  oracle.feed = 7 ∧ 0 < oracle.price ∧ oracle.observedAt ≤ oracle.now ∧
    oracle.now ≤ oracle.observedAt + 5 ∧
    2 * (s.balance (actor, .debt) + q.amount) ≤ s.balance (actor, .collateral) * oracle.price

instance (actor : Account) (q : Quantity .usd) (s : State) (oracle : Oracle) :
    Decidable (BorrowConditions actor q s oracle) :=
  inferInstanceAs (Decidable (oracle.feed = 7 ∧ 0 < oracle.price ∧
    oracle.observedAt ≤ oracle.now ∧ oracle.now ≤ oracle.observedAt + 5 ∧
    2 * (s.balance (actor, .debt) + q.amount) ≤ s.balance (actor, .collateral) * oracle.price))

def borrowContract (actor poolAccount : Account) (q : Quantity .usd) : Contract Oracle where
  accepts s oracle t := decide (Shape t actor
    (fun c ↦ move .usd poolAccount actor q.amount c + pulse (actor, .debt) q.amount c)
    (fun a ↦ if a = .debt then q.amount else 0)) &&
    decide (BorrowConditions actor q s oracle)

/-- Preserve the intended borrow shape while making the untrusted proposal guard always true. -/
def forgedBorrow (q : Quantity .usd) : Transition Oracle :=
  { borrow q with guard := fun _ _ ↦ true }

/-- A balanced extra transfer outside the intended operation's two USD cells. -/
def unrelatedEffect : Transition Unit :=
  { transfer .alice .alice .bob (Quantity.ofNat 3) with
    effect := fun c ↦ move .usd .alice .bob 3 c + move .usd .vault .pool 1 c
    writes := {(.alice, .usd), (.bob, .usd), (.vault, .usd), (.pool, .usd)} }

/-- Identical intended balance effects, but a mismatched supply entry. -/
def wrongSupply : Transition Unit :=
  { deposit (Quantity.ofNat 4) with supplyChange := fun a ↦ if a = .share then 3 else 0 }

-- BEGIN PROOFS

/-- Complete shape equality is decidable without equality of functions or constructor tags. -/
theorem shape_self {E : Type} (t : Transition E) : Shape t t.actor t.effect t.supplyChange :=
  ⟨rfl, fun _ ↦ rfl, fun _ ↦ rfl⟩

theorem transfer_shape (actor src dst : Account) (q : Quantity .usd) :
    Shape (transfer actor src dst q) actor (move .usd src dst q.amount) (fun _ ↦ 0) :=
  shape_self _

theorem deposit_shape (q : Quantity .usd) :
    Shape (deposit q) .alice
      (fun c ↦ move .usd .alice .vault q.amount c + pulse (.alice, .share) (q.amount / 2) c)
      (fun a ↦ if a = .share then q.amount / 2 else 0) := shape_self _

theorem withdraw_shape (q : Quantity .share) :
    Shape (withdraw q) .alice
      (fun c ↦ move .usd .vault .alice (2 * q.amount) c - pulse (.alice, .share) q.amount c)
      (fun a ↦ if a = .share then -q.amount else 0) := shape_self _

theorem borrow_shape (q : Quantity .usd) :
    Shape (borrow q) .alice
      (fun c ↦ move .usd .pool .alice q.amount c + pulse (.alice, .debt) q.amount c)
      (fun a ↦ if a = .debt then q.amount else 0) := shape_self _

theorem transfer_constructor_accepts (actor src dst : Account) (q : Quantity .usd) (s : State) :
    (transferContract actor src dst q).accepts s () (transfer actor src dst q) = true := by
  simpa [transferContract] using transfer_shape actor src dst q

theorem deposit_constructor_accepts (q : Quantity .usd) (s : State) :
    (depositContract .alice .vault q).accepts s () (deposit q) = true := by
  simpa [depositContract] using deposit_shape q

theorem withdraw_constructor_accepts (q : Quantity .share) (s : State) :
    (withdrawContract .alice .vault q).accepts s () (withdraw q) = true := by
  simpa [withdrawContract] using withdraw_shape q

theorem borrow_constructor_accepts_iff (q : Quantity .usd) (s : State) (oracle : Oracle) :
    (borrowContract .alice .pool q).accepts s oracle (borrow q) = true ↔
      BorrowConditions .alice q s oracle := by
  simp [borrowContract, borrow_shape]

/-- Any accepted proposal, even one with a forged guard, satisfies the independent conditions. -/
theorem borrow_accepts_conditions (actor poolAccount : Account) (q : Quantity .usd)
    (s : State) (oracle : Oracle) (t : Transition Oracle)
    (h : (borrowContract actor poolAccount q).accepts s oracle t = true) :
    BorrowConditions actor q s oracle := by
  simp only [borrowContract, Bool.and_eq_true, decide_eq_true_eq] at h
  exact h.2

/-- Trusted effects preserve the declared collateral bound for arbitrary successful proposals. -/
theorem borrow_run_collateral_bound (actor poolAccount : Account) (q : Quantity .usd)
    (p : Policy) (s s' : State) (oracle : Oracle) (t : Transition Oracle)
    (h : run (borrowContract actor poolAccount q) p oracle t s = .ok s') :
    2 * s'.balance (actor, .debt) ≤ s'.balance (actor, .collateral) * oracle.price := by
  obtain ⟨hc, hv, rfl⟩ := run_valid_update (borrowContract actor poolAccount q) p oracle t s s' h
  simp only [borrowContract, Bool.and_eq_true, decide_eq_true_eq] at hc
  have he := hc.1.2.1
  have hb := hc.2.2.2.2.2
  simpa [applyEffect, he, move, pulse] using hb

end DefiKernel.ContractExamples
