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
This policy is an input assumption; the kernel does not authenticate or derive the grant. -/
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

/-- Counterexample fixture isolates vault liquidity from share ownership. -/
def richShares : State where
  balance c := if c = (.alice, .share) then 20 else initial.balance c
  nonneg c := by
    split
    · norm_num
    · exact initial.nonneg c

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
