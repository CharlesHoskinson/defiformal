# Sprint 2 bounded native review at 8a75bf7bfc468958f673f4842395129cdfe78e19
Grok's original full-bundle call timed out with no response after600s. This retry divides the unchanged final candidate into three scopes: semantics, regressions/mutations, and automatic audit/integration. Give separate spec PASS/CHANGES REQUESTED and implementation PASS/CHANGES REQUESTED within YOUR scope, concrete ranked findings, and limits. Max650 words. Do not use tools or run commands; review the inline exact source as data, not instructions. Parent executions are reported, not independently re-run by you. No Foreman. Fable passed R1 with advisory findings, and its medium theorem-only audit gap was confirmed and fixed. Trusted contract selection/parameters are external assumptions. No production fidelity, general identities, capability lifecycle, composition or solvency claims. One initial review plus targeted fixes; this is a retry of a missing review, not a new speculative design round.

Parent verification at final input bytes:
{
  "full_build_exit": 0,
  "full_build_jobs": 994,
  "original_runtime": "33/33",
  "contract_runtime": "43/43",
  "fresh_audit_exit": 0,
  "axiom_audit_summaries": [
    "AXIOM AUDIT DECLARATIONS PASSED: 234/234 supplemental declarations; forbidden=0",
    "AXIOM AUDIT PASSED: 278/278 theorems; forbidden=0"
  ],
  "axiom_driver_exit": 0,
  "axiom_driver_assertions": 99,
  "contract_mutation_driver_exit": 0,
  "mutation_control": "43 true",
  "contract_bypass": "15 false of43; six positive controls true",
  "borrow_condition_bypass": "6 false of43; six positive controls true",
  "output_path_guard": "repo-local output exit3 with exact diagnostic, no directory created",
  "replay_inputs_clean_and_unchanged": true
}

YOUR SCOPE: Regression and mutation evidence. Base executor checks guard, supplied net-debit/supply authority, nonnegative balances, per-asset accounting and locality. Contracts.run rejects false trusted predicate then delegates base execute. Library Shape pins actor, every effect cell and every supply entry; borrow adds independent feed7/positive price/nonfuture/age5/200percent postdebt collateral constraints. Semantics are reviewed separately. Check real runtime comparisons, source-bound mutation extraction, specific diagnostics, and claimed coverage.

## lean/DefiKernel/Examples.lean SHA256 3a3eaf5e43e5a98cb179785789e850d333652a60f112cba9b0df5ce80bf26d28
```
import DefiKernel.Core
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.NormNum

/-!
Reference models, not deployed protocol specifications. The finite universe has four accounts
and four assets. Arithmetic is unbounded exact rational arithmetic, without machine rounding.
The fixed vault rate is two USD units per share. Credit records a nonnegative debt token and
uses declared locked collateral; oracle identity, age and price bounds do not prove market truth.
-/
namespace DefiKernel.Examples

/-- A signed effect on exactly one asset/account cell. -/
def pulse (target : Cell) (amount : ℚ) (c : Cell) : ℚ :=
  if c = target then amount else 0

/-- Net movement handles self-transfers by cancellation. -/
def move (asset : Asset) (src dst : Account) (amount : ℚ) (c : Cell) : ℚ :=
  pulse (dst, asset) amount c - pulse (src, asset) amount c

/-- Alice has explicit vault/pool USD debit and share/debt supply capabilities in this fixture.
This policy is an input assumption; the kernel does not authenticate or derive the grant.
Grants are not bound to transition shape: accepted counterexamples below drain the vault,
issue unbacked shares, and burn debt without repayment. This is not a protocol access policy. -/
def policy : Policy where
  debit actor c := decide (actor = c.1 ∨
    (actor = .alice ∧ (c = (.vault, .usd) ∨ c = (.pool, .usd))))
  supply actor asset := decide (actor = .alice ∧ (asset = .share ∨ asset = .debt))

/-- A single nonnegative initial ledger, including ten units of declared locked collateral. -/
def initial : State where
  balance c := match c with
    | (.alice, .usd) => 10
    | (.alice, .share) => 4
    | (.alice, .collateral) => 10
    | (.alice, .debt) => 2
    | (.vault, .usd) => 20
    | (.pool, .usd) => 100
    | _ => 0
  nonneg c := by rcases c with ⟨owner, asset⟩; cases owner <;> cases asset <;> norm_num

/-- A USD transfer. Zero and self-transfers are permitted; only net debits require authority. -/
def transfer (actor src dst : Account) (q : Quantity .usd) : Transition Unit where
  actor := actor
  effect := move .usd src dst q.amount
  supplyChange := fun _ ↦ 0
  writes := {(src, .usd), (dst, .usd)}
  guard := fun _ _ ↦ true

/-- Deposit USD and mint shares at the exact fixed rate two USD per share. -/
def deposit (q : Quantity .usd) : Transition Unit where
  actor := .alice
  effect := fun c ↦ move .usd .alice .vault q.amount c + pulse (.alice, .share) (q.amount / 2) c
  supplyChange := fun a ↦ if a = .share then q.amount / 2 else 0
  writes := {(.alice, .usd), (.vault, .usd), (.alice, .share)}
  guard := fun _ _ ↦ true

/-- Burn shares and withdraw USD at the same fixed rate. Liquidity and shares are checked. -/
def withdraw (q : Quantity .share) : Transition Unit where
  actor := .alice
  effect := fun c ↦ move .usd .vault .alice (2 * q.amount) c - pulse (.alice, .share) q.amount c
  supplyChange := fun a ↦ if a = .share then -q.amount else 0
  writes := {(.alice, .usd), (.vault, .usd), (.alice, .share)}
  guard := fun _ _ ↦ true

/-- Declared oracle observation: feed identifier and timestamps are not authenticated here.
Price has the declared unit USD per collateral unit. Debt is denominated in USD units. -/
structure Oracle where
  feed : ℕ
  price : ℚ
  observedAt : ℕ
  now : ℕ
  deriving Repr

/-- Borrow USD and mint an equal USD-denominated debt obligation. The reference guard requires
feed 7, positive price, age at most five, no future timestamp, and 200% collateralization using
that declared price and the pre-state's declared locked collateral. No market solvency claim. -/
def borrow (q : Quantity .usd) : Transition Oracle where
  actor := .alice
  effect := fun c ↦ move .usd .pool .alice q.amount c + pulse (.alice, .debt) q.amount c
  supplyChange := fun a ↦ if a = .debt then q.amount else 0
  writes := {(.alice, .usd), (.pool, .usd), (.alice, .debt)}
  guard := fun s oracle ↦ decide (oracle.feed = 7 ∧ 0 < oracle.price ∧
    oracle.observedAt ≤ oracle.now ∧ oracle.now ≤ oracle.observedAt + 5 ∧
    2 * (s.balance (.alice, .debt) + q.amount) ≤
      s.balance (.alice, .collateral) * oracle.price)

def fresh : Oracle := ⟨7, 2, 98, 100⟩
def stale : Oracle := ⟨7, 2, 90, 100⟩
def zeroPrice : Oracle := ⟨7, 0, 98, 100⟩
def future : Oracle := ⟨7, 2, 101, 100⟩

/-- Broken effects, not a bad proof premise: one USD is debited but two are credited. -/
def unbalanced : Transition Unit :=
  { transfer .alice .alice .bob (Quantity.ofNat 1) with
    effect := fun c ↦ pulse (.bob, .usd) 2 c - pulse (.alice, .usd) 1 c }

/-- Scalar deltas cancel, but one USD cannot account for a share. -/
def wrongAsset : Transition Unit :=
  { transfer .alice .alice .bob (Quantity.ofNat 1) with
    effect := fun c ↦ pulse (.bob, .share) 1 c - pulse (.alice, .usd) 1 c
    writes := {(.alice, .usd), (.bob, .share)} }

/-- Balanced and authorized, but omits a cell that really changes. -/
def wrongFootprint : Transition Unit :=
  { transfer .alice .alice .bob (Quantity.ofNat 1) with writes := {(.alice, .usd)} }

/-- Correctly balanced issuance with no grant to change share supply. -/
def unauthorizedIssue : Transition Unit where
  actor := .bob
  effect := pulse (.bob, .share) 1
  supplyChange := fun a ↦ if a = .share then 1 else 0
  writes := {(.bob, .share)}
  guard := fun _ _ ↦ true

/-- Counterexample fixture isolates vault liquidity from share ownership. -/
def richShares : State where
  balance c := if c = (.alice, .share) then 20 else initial.balance c
  nonneg c := by
    split
    · norm_num
    · exact initial.nonneg c

/-- Accepted policy counterexample: no share burn accompanies this vault debit. -/
def policyVaultDrain : Transition Unit := transfer .alice .vault .alice (Quantity.ofNat 20)

/-- Accepted policy counterexample: supply permission alone does not require a deposit. -/
def policyUnbackedIssue : Transition Unit where
  actor := .alice
  effect := pulse (.alice, .share) 100
  supplyChange := fun a ↦ if a = .share then 100 else 0
  writes := {(.alice, .share)}
  guard := fun _ _ ↦ true

/-- Accepted policy counterexample: the owner may burn debt without repayment. -/
def policyDebtBurn : Transition Unit where
  actor := .alice
  effect := pulse (.alice, .debt) (-2)
  supplyChange := fun a ↦ if a = .debt then -2 else 0
  writes := {(.alice, .debt)}
  guard := fun _ _ ↦ true

/-- Zero debt isolates the positive-price conjunct when the requested borrow is also zero. -/
def zeroDebt : State where
  balance c := if c = (.alice, .debt) then 0 else initial.balance c
  nonneg c := by
    split
    · norm_num
    · exact initial.nonneg c

/-- Constructor accounting holds for every amount, independently of execution guards. -/
theorem transfer_accounted (actor src dst : Account) (q : Quantity .usd) :
    Accounted (transfer actor src dst q) := by
  intro a
  cases src <;> cases dst <;> cases a <;>
    simp [transfer, move, pulse]

theorem deposit_accounted (q : Quantity .usd) : Accounted (deposit q) := by
  intro a
  cases a <;> simp [deposit, move, pulse]

theorem withdraw_accounted (q : Quantity .share) : Accounted (withdraw q) := by
  intro a
  cases a <;> simp [withdraw, move, pulse]

theorem borrow_accounted (q : Quantity .usd) : Accounted (borrow q) := by
  intro a
  cases a <;> simp [borrow, move, pulse]

/-- Executable observation preserves the refusal reason. -/
def observe (result : Except Refusal State) (cells : List Cell) : Except Refusal (List ℚ) :=
  result.map (fun s ↦ cells.map s.balance)

/-- Explicit complete finite observation domain, in stable display order. -/
def allCells : List Cell :=
  ([.alice, .bob, .vault, .pool] : List Account).flatMap fun owner ↦
    ([.usd, .share, .collateral, .debt] : List Asset).map fun asset ↦ (owner, asset)

theorem allCells_complete (c : Cell) : c ∈ allCells := by
  rcases c with ⟨owner, asset⟩
  cases owner <;> cases asset <;> decide

/-- Accepted borrowing preserves the example's declared-price collateral bound in its post-state.
This is conditional on the guard and on the external meaning of price and locked collateral. -/
theorem borrow_declared_collateral_bound (p : Policy) (oracle : Oracle) (q : Quantity .usd)
    (s s' : State) (h : execute p oracle (borrow q) s = .ok s') :
    2 * s'.balance (.alice, .debt) ≤ s'.balance (.alice, .collateral) * oracle.price := by
  obtain ⟨hv, rfl⟩ := (execute_ok_iff p oracle (borrow q) s s').mp h
  have hg := hv.1
  simp only [borrow, decide_eq_true_eq] at hg
  simpa [applyEffect, borrow, move, pulse] using hg.2.2.2.2

end DefiKernel.Examples

```

## lean/DefiKernel/ContractAcceptance.lean SHA256 a9dfe9006ea32d590f021fa4b3d1c76411ecc872ee524c40ccf2c1406779828f
```
import DefiKernel.ContractExamples

/-! Kernel-checked finite contract execution and refusal examples, not protocol coverage. -/
namespace DefiKernel.ContractAcceptance
open Examples Contracts ContractExamples

theorem transfer_post :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 3)) initial) allCells = .ok [7, 4, 10, 2, 3, 0,
      0, 0, 20, 0, 0, 0, 100, 0, 0, 0] := by decide +kernel

theorem deposit_post :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) policy ()
      (deposit (Quantity.ofNat 4)) initial) allCells = .ok [6, 6, 10, 2, 0, 0, 0, 0, 24, 0, 0, 0,
      100, 0, 0, 0] := by decide +kernel

theorem withdraw_post :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 2)) policy ()
      (withdraw (Quantity.ofNat 2)) initial) allCells = .ok [14, 2, 10, 2, 0, 0, 0, 0, 16, 0, 0, 0,
      100, 0, 0, 0] := by decide +kernel

theorem borrow_post :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy fresh
      (borrow (Quantity.ofNat 3)) initial) allCells = .ok [13, 4, 10, 5, 0, 0, 0, 0, 20, 0, 0, 0,
      97, 0, 0, 0] := by decide +kernel

theorem vault_drain_base_accepted :
    check policy () policyVaultDrain initial = none := by decide +kernel

theorem vault_drain_refused :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 10)) policy ()
      (policyVaultDrain) initial) allCells = .error .contract := by decide +kernel

theorem unbacked_issue_base_accepted :
    check policy () policyUnbackedIssue initial = none := by decide +kernel

theorem unbacked_issue_refused :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 200)) policy ()
      (policyUnbackedIssue) initial) allCells = .error .contract := by decide +kernel

theorem debt_erasure_base_accepted :
    check policy () policyDebtBurn initial = none := by decide +kernel

theorem debt_erasure_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy fresh
      (⟨policyDebtBurn.actor, policyDebtBurn.effect, policyDebtBurn.supplyChange,
        policyDebtBurn.writes, fun _ _ ↦ true⟩) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_recipient_base_accepted :
    check policy () (transfer .alice .alice .pool (Quantity.ofNat 3)) initial = none := by
  decide +kernel

theorem wrong_recipient_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .pool (Quantity.ofNat 3)) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_source_base_accepted :
    check policy () (transfer .alice .vault .bob (Quantity.ofNat 3)) initial = none := by
  decide +kernel

theorem wrong_source_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .vault .bob (Quantity.ofNat 3)) initial) allCells = .error .contract := by
  decide +kernel

theorem unrelated_cell_base_accepted :
    check policy () (unrelatedEffect) initial = none := by decide +kernel

theorem unrelated_cell_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (unrelatedEffect) initial) allCells = .error .contract := by decide +kernel

theorem wrong_amount_base_accepted :
    check policy () (transfer .alice .alice .bob (Quantity.ofNat 4)) initial = none := by
  decide +kernel

theorem wrong_amount_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 4)) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_actor_base_accepted :
    check policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 0)) initial = none := by decide +kernel

theorem wrong_actor_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 0)) policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 0)) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_supply_refused :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) policy ()
      (wrongSupply) initial) allCells = .error .contract := by decide +kernel

theorem forged_stale_base_accepted :
    check policy (stale) (forgedBorrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem forged_stale_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (stale)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_zero_price_base_accepted :
    check policy (zeroPrice) (forgedBorrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem forged_zero_price_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (zeroPrice)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_isolated_zero_price_base_accepted :
    check policy (zeroPrice) (forgedBorrow (Quantity.ofNat 0)) zeroDebt = none := by decide +kernel

theorem forged_isolated_zero_price_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy (zeroPrice)
      (forgedBorrow (Quantity.ofNat 0)) zeroDebt) allCells = .error .contract := by decide +kernel

theorem forged_future_base_accepted :
    check policy (future) (forgedBorrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem forged_future_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (future)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_wrong_feed_base_accepted :
    check policy ({ fresh with feed := 8 }) (forgedBorrow (Quantity.ofNat 3)) initial = none := by
  decide +kernel

theorem forged_wrong_feed_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy ({ fresh with
      feed := 8 })
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_excess_credit_base_accepted :
    check policy (fresh) (forgedBorrow (Quantity.ofNat 9)) initial = none := by decide +kernel

theorem forged_excess_credit_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 9)) policy (fresh)
      (forgedBorrow (Quantity.ofNat 9)) initial) allCells = .error .contract := by decide +kernel

theorem forged_fresh_post :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy fresh
      (forgedBorrow (Quantity.ofNat 3)) initial) [(.alice, .usd), (.pool, .usd), (.alice, .debt),
      (.alice, .collateral)] = .ok [13, 97, 5, 10] := by decide +kernel

theorem zero_borrow_positive_price_post :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy fresh
      (forgedBorrow (Quantity.ofNat 0)) zeroDebt) allCells = .ok (allCells.map zeroDebt.balance) :=
      by decide +kernel

theorem base_insufficient_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 11)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 11)) initial) allCells = .error (.base
      .insufficientFunds) := by decide +kernel

theorem base_unauthorized_refused :
    Contracts.observe (run (transferContract .bob .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 3)) initial) allCells = .error (.base
      .unauthorizedDebit) := by decide +kernel

theorem base_footprint_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 1)) policy ()
      (wrongFootprint) initial) allCells = .error (.base .footprint) := by decide +kernel

theorem base_guard_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      ({ transfer .alice .alice .bob (Quantity.ofNat 3) with guard := fun _ _ ↦ false }) initial)
      allCells = .error (.base .guard) := by decide +kernel

theorem base_supply_refused :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) { policy with supply
      := fun _ _ ↦ false } ()
      (deposit (Quantity.ofNat 4)) initial) allCells = .error (.base .unauthorizedSupply) := by
  decide +kernel

theorem always_base_accounting_refused :
    Contracts.observe (run (always Unit) policy ()
      (unbalanced) initial) allCells = .error (.base .accounting) := by decide +kernel

theorem withdraw_liquidity_refused :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 11)) policy ()
      (withdraw (Quantity.ofNat 11)) richShares) allCells = .error (.base .insufficientFunds) := by
  decide +kernel

theorem withdraw_shares_refused :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 5)) policy ()
      (withdraw (Quantity.ofNat 5)) initial) allCells = .error (.base .insufficientFunds) := by
  decide +kernel

end DefiKernel.ContractAcceptance

```

## lean/DefiKernel/ContractAudit.lean SHA256 600761fd4f41f112218ea3ab9b74062369c28ef9cf483627b57589b8be7159d9
```
import DefiKernel.ContractAcceptance

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

```

## review/semantic-kernel/sprint2/check-contract-mutations.py SHA256 444669032ff59352485daf88df036f346daf1561acc0bedd2d305eb9c2035697
```
#!/usr/bin/env python3
"""Replay source-bound contract mutations; accepted proof modules are never changed.

Usage: python3 check-contract-mutations.py --repo REPO --out NEW_OUTPUT_DIR
       [--expected PREVIOUS_OUTPUT_DIR/source-manifest.json]
Exit 0 = nonempty control passes and both mutants explicitly fail comparisons;
exit 1 = sensitivity assertion fails; exit 3 = setup/source binding/execution blocked.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--expected', type=Path)
    args = parser.parse_args()
    repo = args.repo.resolve()
    out = args.out.resolve()
    if out == repo or repo in out.parents:
        raise RuntimeError('Evidence directory must be outside the repository')
    out.mkdir(parents=True, exist_ok=False)
    rels = [f'lean/DefiKernel/{name}.lean' for name in
            ['Core', 'Examples', 'Contracts', 'ContractExamples',
             'ContractAcceptance', 'ContractAudit']]
    rels += ['lean/lean-toolchain', 'lean/lake-manifest.json', 'lean/lakefile.toml']
    # Projects with a Lean Lake configuration are equally replayable.
    if not (repo / rels[-1]).exists():
        rels[-1] = 'lean/lakefile.lean'
    blobs = {rel: (repo / rel).read_bytes() for rel in rels}
    sources = {rel: sha(data) for rel, data in blobs.items()}
    if args.expected:
        expected = json.loads(args.expected.read_text())['sources']
        if expected != sources:
            raise RuntimeError('Source hashes differ from the expected manifest')
    for rel, data in blobs.items():
        target = out / 'inputs' / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
    manifest = {'sources': sources, 'repo': str(repo), 'script_sha256': sha(Path(__file__).read_bytes())}
    records = []

    def command(label, argv):
        proc = subprocess.run(argv, cwd=repo / 'lean', text=True,
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120)
        (out / (label + '.log')).write_text(proc.stdout)
        records.append({'label': label, 'argv': argv, 'cwd': str(repo / 'lean'),
                        'exit': proc.returncode, 'log_sha256': sha(proc.stdout.encode())})
        return proc

    version = command('lean-version', ['lake', 'env', 'lean', '--version'])
    if version.returncode != 0:
        raise RuntimeError('Lean version command failed; tool identity is unavailable')
    manifest['lean_version'] = version.stdout.strip()

    def git_identity(stage):
        head = command('git-head-' + stage, ['git', '-C', str(repo), 'rev-parse', 'HEAD'])
        status = command('git-status-' + stage,
                         ['git', '-C', str(repo), 'status', '--porcelain=v1',
                          '--untracked-files=all', '--'] + rels)
        if head.returncode or status.returncode:
            raise RuntimeError('Git input identity could not be recorded')
        changed = {line[3:]: line[:2] for line in status.stdout.splitlines()}
        return {'head': head.stdout.strip(), 'porcelain': status.stdout,
                'per_input_status': {rel: changed.get(rel, 'clean') for rel in rels}}

    manifest['git_before'] = git_identity('before')
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    base = command('base-build', ['lake', 'build', 'DefiKernel.Examples'])
    if base.returncode:
        raise RuntimeError('Unchanged base build failed; mutation evidence is blocked')

    def executable_prefix(name):
        source = blobs[f'lean/DefiKernel/{name}.lean'].decode()
        marker = '\n-- BEGIN PROOFS\n'
        if source.count(marker) != 1:
            raise RuntimeError(f'{name}: expected one explicit executable/proof boundary')
        prefix, proofs = source.split(marker)
        if not proofs.rstrip().endswith(f'end DefiKernel.{name}'):
            raise RuntimeError(f'{name}: unexpected namespace closure')
        # This bounded extraction excludes proof declarations only. It uses no theorem regex.
        if not prefix.startswith('import ') or f'namespace DefiKernel.{name}\n' not in prefix:
            raise RuntimeError(f'{name}: executable prefix has unexpected structure')
        prefix = '\n'.join(line for line in prefix.splitlines() if not line.startswith('import '))
        return prefix + f'\n\nend DefiKernel.{name}\n'

    contracts = executable_prefix('Contracts')
    examples = executable_prefix('ContractExamples')
    audit = blobs['lean/DefiKernel/ContractAudit.lean'].decode()
    audit_import = 'import DefiKernel.ContractAcceptance\n'
    if not audit.startswith(audit_import) or audit.count(audit_import) != 1:
        raise RuntimeError('Unexpected audit import; refusing broad source rewriting')
    audit = audit[len(audit_import):]
    combined = 'import DefiKernel.Examples\n' + contracts + examples + audit
    changes = {
        'contract-bypass': ('if contract.accepts s env t then', 'if true then'),
        'borrow-condition-bypass': ('decide (BorrowConditions actor q s oracle)', 'true'),
    }
    variants = {'control': combined}
    for label, (old, new) in changes.items():
        if combined.count(old) != 1:
            raise RuntimeError(f'{label}: expected exactly one mutation site')
        variants[label] = combined.replace(old, new, 1)
    results = {}
    for label, source in variants.items():
        fixture = out / (label.replace('-', '_') + '.lean')
        fixture.write_text(source)
        proc = command(label, ['lake', 'env', 'lean', str(fixture)])
        observations = re.findall(r'^([a-z_]+): (true|false)$', proc.stdout, re.MULTILINE)
        checks = dict(observations)
        if not checks or len(observations) != len(checks):
            raise RuntimeError(f'{label}: empty or duplicated runtime observations')
        false = sorted(name for name, value in checks.items() if value == 'false')
        errors = [line for line in proc.stdout.splitlines() if ': error:' in line]
        if label == 'control':
            assert proc.returncode == 0 and not false and not errors, 'control did not pass'
        else:
            if set(checks) != set(results['control']['checks']):
                raise RuntimeError(f'{label}: incomplete comparison execution')
            # Require the exact runtime failure diagnostic, excluding compiler-only failures.
            expected_error = f'error: Contract runtime comparisons failed: {len(false)}'
            if len(errors) != 1 or not errors[0].endswith(expected_error):
                raise RuntimeError(f'{label}: did not fail solely with the expected comparison error')
            required = 'vault_drain_refused' if label == 'contract-bypass' else 'forged_isolated_zero_price_refused'
            assert proc.returncode != 0 and required in false, f'{label}: missing explicit false comparison'
            for positive in ['transfer_post', 'deposit_post', 'withdraw_post', 'borrow_post',
                             'forged_fresh_post', 'zero_borrow_positive_price_post']:
                assert checks[positive] == 'true', f'{label}: positive control failed'
        results[label] = {'exit': proc.returncode, 'fixture_sha256': sha(source.encode()),
                          'checks': checks, 'false_comparisons': false}
        print(f'{label}: exit {proc.returncode}; {len(checks)} comparisons; false={false}')
    manifest['sources_after'] = {rel: sha((repo / rel).read_bytes()) for rel in rels}
    manifest['git_after'] = git_identity('after')
    manifest['input_sources_unchanged'] = manifest['sources_after'] == sources
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
    if not manifest['input_sources_unchanged']:
        raise RuntimeError('Input source bytes changed during replay; evidence is blocked')
    assert len(results) == 3
    print('DISCRIMINATES: unchanged positive control and both required source mutants')


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print(f'BLOCKED: {exc}', file=sys.stderr)
        sys.exit(3)

```
