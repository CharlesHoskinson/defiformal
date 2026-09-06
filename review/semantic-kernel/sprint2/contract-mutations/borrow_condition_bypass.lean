import DefiKernel.Examples

/-! Trusted contracts constrain proposals before the unchanged finite executor runs.
The caller selecting a contract and its parameters is trusted; this is not authentication. -/
namespace DefiKernel.Contracts

/-- Executable state/environment/proposal predicate selected outside the untrusted proposal. -/
structure Contract (E : Type) where
  accepts : State → E → Transition E → Bool

/-- Contract rejection and each original executor rejection remain distinguishable. -/
inductive Failure where
  | contract
  | base (reason : Refusal)
  deriving DecidableEq, Repr

/-- Embed the original result without changing its state or refusal reason. -/
def liftBase (result : Except Refusal State) : Except Failure State :=
  match result with
  | .error reason => .error (.base reason)
  | .ok s => .ok s

/-- A failed contract returns no successful state. The proposal cannot replace this predicate. -/
def run {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s : State) : Except Failure State :=
  if contract.accepts s env t then liftBase (execute p env t s) else .error .contract

/-- The vacuous contract is useful for stating conservative recovery of base execution. -/
def always (E : Type) : Contract E := ⟨fun _ _ _ ↦ true⟩

/-- Observe exact balances while retaining the wrapper refusal. -/
def observe (result : Except Failure State) (cells : List Cell) : Except Failure (List ℚ) :=
  result.map (fun s ↦ cells.map s.balance)

end DefiKernel.Contracts

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
    true

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

end DefiKernel.ContractExamples

/-! Fresh executable comparisons over the actual contract wrapper and financial library. -/
namespace DefiKernel.ContractAudit
open Examples Contracts ContractExamples

/-- Bounded regression observations; source mutation replay runs these same comparisons. -/
def runtimeChecks : List (String × Bool) := [
  ("transfer_post", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 3)) initial) allCells = .ok [7, 4, 10, 2, 3, 0,
      0, 0, 20, 0, 0, 0, 100, 0, 0, 0])),
  ("deposit_post", decide (
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) policy ()
      (deposit (Quantity.ofNat 4)) initial) allCells = .ok [6, 6, 10, 2, 0, 0, 0, 0, 24, 0, 0, 0,
      100, 0, 0, 0])),
  ("withdraw_post", decide (
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 2)) policy ()
      (withdraw (Quantity.ofNat 2)) initial) allCells = .ok [14, 2, 10, 2, 0, 0, 0, 0, 16, 0, 0, 0,
      100, 0, 0, 0])),
  ("borrow_post", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy fresh
      (borrow (Quantity.ofNat 3)) initial) allCells = .ok [13, 4, 10, 5, 0, 0, 0, 0, 20, 0, 0, 0,
      97, 0, 0, 0])),
  ("vault_drain_base_accepted", decide (
    check policy () policyVaultDrain initial = none)),
  ("vault_drain_refused", decide (
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 10)) policy ()
      (policyVaultDrain) initial) allCells = .error .contract)),
  ("unbacked_issue_base_accepted", decide (
    check policy () policyUnbackedIssue initial = none)),
  ("unbacked_issue_refused", decide (
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 200)) policy ()
      (policyUnbackedIssue) initial) allCells = .error .contract)),
  ("debt_erasure_base_accepted", decide (
    check policy () policyDebtBurn initial = none)),
  ("debt_erasure_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy fresh
      (⟨policyDebtBurn.actor, policyDebtBurn.effect, policyDebtBurn.supplyChange,
        policyDebtBurn.writes, fun _ _ ↦ true⟩) initial) allCells = .error .contract)),
  ("wrong_recipient_base_accepted", decide (
    check policy () (transfer .alice .alice .pool (Quantity.ofNat 3)) initial = none)),
  ("wrong_recipient_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .pool (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("wrong_source_base_accepted", decide (
    check policy () (transfer .alice .vault .bob (Quantity.ofNat 3)) initial = none)),
  ("wrong_source_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .vault .bob (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("unrelated_cell_base_accepted", decide (
    check policy () (unrelatedEffect) initial = none)),
  ("unrelated_cell_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (unrelatedEffect) initial) allCells = .error .contract)),
  ("wrong_amount_base_accepted", decide (
    check policy () (transfer .alice .alice .bob (Quantity.ofNat 4)) initial = none)),
  ("wrong_amount_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 4)) initial) allCells = .error .contract)),
  ("wrong_actor_base_accepted", decide (
    check policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 0)) initial = none)),
  ("wrong_actor_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 0)) policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 0)) initial) allCells = .error .contract)),
  ("wrong_supply_refused", decide (
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) policy ()
      (wrongSupply) initial) allCells = .error .contract)),
  ("forged_stale_base_accepted", decide (
    check policy (stale) (forgedBorrow (Quantity.ofNat 3)) initial = none)),
  ("forged_stale_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (stale)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("forged_zero_price_base_accepted", decide (
    check policy (zeroPrice) (forgedBorrow (Quantity.ofNat 3)) initial = none)),
  ("forged_zero_price_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (zeroPrice)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("forged_isolated_zero_price_base_accepted", decide (
    check policy (zeroPrice) (forgedBorrow (Quantity.ofNat 0)) zeroDebt = none)),
  ("forged_isolated_zero_price_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy (zeroPrice)
      (forgedBorrow (Quantity.ofNat 0)) zeroDebt) allCells = .error .contract)),
  ("forged_future_base_accepted", decide (
    check policy (future) (forgedBorrow (Quantity.ofNat 3)) initial = none)),
  ("forged_future_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (future)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("forged_wrong_feed_base_accepted", decide (
    check policy ({ fresh with feed := 8 }) (forgedBorrow (Quantity.ofNat 3)) initial = none)),
  ("forged_wrong_feed_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy ({ fresh with
      feed := 8 })
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("forged_excess_credit_base_accepted", decide (
    check policy (fresh) (forgedBorrow (Quantity.ofNat 9)) initial = none)),
  ("forged_excess_credit_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 9)) policy (fresh)
      (forgedBorrow (Quantity.ofNat 9)) initial) allCells = .error .contract)),
  ("forged_fresh_post", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy fresh
      (forgedBorrow (Quantity.ofNat 3)) initial) [(.alice, .usd), (.pool, .usd), (.alice, .debt),
      (.alice, .collateral)] = .ok [13, 97, 5, 10])),
  ("zero_borrow_positive_price_post", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy fresh
      (forgedBorrow (Quantity.ofNat 0)) zeroDebt) allCells = .ok (allCells.map zeroDebt.balance))),
  ("base_insufficient_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 11)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 11)) initial) allCells = .error (.base
      .insufficientFunds))),
  ("base_unauthorized_refused", decide (
    Contracts.observe (run (transferContract .bob .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 3)) initial) allCells = .error (.base
      .unauthorizedDebit))),
  ("base_footprint_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 1)) policy ()
      (wrongFootprint) initial) allCells = .error (.base .footprint))),
  ("base_guard_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      ({ transfer .alice .alice .bob (Quantity.ofNat 3) with guard := fun _ _ ↦ false }) initial)
      allCells = .error (.base .guard))),
  ("base_supply_refused", decide (
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) { policy with supply
      := fun _ _ ↦ false } ()
      (deposit (Quantity.ofNat 4)) initial) allCells = .error (.base .unauthorizedSupply))),
  ("always_base_accounting_refused", decide (
    Contracts.observe (run (always Unit) policy ()
      (unbalanced) initial) allCells = .error (.base .accounting))),
  ("withdraw_liquidity_refused", decide (
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 11)) policy ()
      (withdraw (Quantity.ofNat 11)) richShares) allCells = .error (.base .insufficientFunds))),
  ("withdraw_shares_refused", decide (
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 5)) policy ()
      (withdraw (Quantity.ofNat 5)) initial) allCells = .error (.base .insufficientFunds)))]

#eval show IO Unit from do
  if runtimeChecks.isEmpty then throw (IO.userError "No contract runtime checks were collected")
  let mut failures := 0
  for (name, passed) in runtimeChecks do
    IO.println s!"{name}: {passed}"
    if !passed then failures := failures + 1
  let passed := runtimeChecks.length - failures
  IO.println s!"Contract runtime checks passed: {passed}/{runtimeChecks.length}"
  if failures != 0 then
    throw (IO.userError s!"Contract runtime comparisons failed: {failures}")

end DefiKernel.ContractAudit
