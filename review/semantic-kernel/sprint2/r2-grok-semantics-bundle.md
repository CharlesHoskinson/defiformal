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

YOUR SCOPE: Contract semantics and general proofs. Judge trusted shape and independent borrow conditions, success/refusal/inherited properties. Regression script details are reviewed separately.

## docs/superpowers/specs/2026-09-06-operation-contracts-design.md SHA256 44dfaf33cb87f1bf6370e2a9a552a80d549cd1584a9b600b3bb95ab24fa848ad
```
# Sprint 2: trusted operation contracts and automatic axiom coverage

This sprint executes packages 2 and 4 of the approved migration. User authorized
starting the next sprint after publishing the first increment on 2026-09-06.
Base: `4c25efc41c4c2b6d6ad3c9fd68d081e71043f387`; continue on
`semantic-kernel-pivot`. GPT-6 implements through native Codex agents; native
Grok and Fable independently review. No Foreman.

## Decision

Add a trusted contract wrapper over the unchanged finite kernel. A contract
checks the actor and complete financial effect of an operation against trusted
parameters and independently checks its required environment conditions. The
caller-supplied transition cannot choose its own contract. The existing broad
policy and its accepted counterexamples remain evidence.

Alternatives considered: tightening only the debit/supply booleans cannot
express the exchange between cash, shares and debt; introducing protocol-kind
primitives would hard-code libraries into the kernel. A generic contract check
with library instances supplies the missing boundary without either change.
General identities and dimensioned expressions remain separate increments.

Review amendment: Fable's first review identified that theorem-only dependency
inspection can miss unused custom axioms and sorry-dependent definitions. The
automatic audit also inspects imported axiom, definition and opaque constants
in the same module scope. This enforces the existing accepted-source restriction
more directly; it does not expand the financial claims of this sprint.

## Behavior and trust boundary

`Contracts.lean` adds a decidable, state/environment/transition-dependent
contract with an execution wrapper. Contract refusal is distinguishable from
base-kernel refusal. A successful execution entails both the contract predicate
and the existing exact update/check premises. An always-true contract recovers
base execution. A failed contract exposes no successful post-state.

`ContractExamples.lean` supplies contracts for transfer, deposit, withdrawal and
borrow using explicit trusted actor, amount and source/destination parameters
where applicable. Check complete effects and supply change extensionally across
the finite domain, including unrelated cells; do not inspect constructor names
or trust a label supplied with the proposal. Borrow must check its required
oracle and collateral conditions independently of a replaceable proposal guard.
A trusted operation selection is an assumption, not authentication, issuance,
revocation, serialization or a general claim lifecycle.

`ContractAcceptance.lean` proves and executes successful reference operations
and refused hostile proposals. The original vault drain, unbacked issue and
debt erasure must still pass the old checker and be refused by the corresponding
trusted contracts. Include a wrong recipient/unrelated-cell effect, wrong
amount or supply, and a forged-true borrow guard with stale or zero-price data.
Show execution post-states and base refusal propagation, not only predicate
truth. Prove useful general constructor acceptance/shape facts and inherited
accounting/locality conditional on actual wrapper success.

## Automatic audit coverage

Replace the manual-only disclosure boundary with inspection of Lean's elaborated
environment. Discover theorem declarations in loaded pilot modules, report the
exact names and axiom dependencies, and fail on `sorryAx` or nonstandard axioms.
Avoid source-regex theorem discovery. The scope is imported pilot modules;
unimported files are not automatically covered and that must be explicit.
An empty scope must fail. Standard allowed axioms are `propext`,
`Classical.choice`, and `Quot.sound`.

Wire the check into the normal kernel build and provide an explicit fresh-run
command. Test the actual audit mechanism with a newly introduced theorem, a
custom-axiom-dependent theorem, an empty scope, and a clean positive control.
Keep historical manual disclosures as historical evidence; current audit is
computed from the environment rather than depending on that list's maintenance.

## Acceptance and review

- Existing pilot and algebra results remain unchanged and build.
- Wrapper proofs and live positive/negative cases are checked by Lean, without
  `sorry`, custom axioms or `native_decide` in accepted sources.
- Demonstrate sensitivity by disabling the contract check and the independent
  borrow environmental condition in temporary copies: the relevant explicit
  acceptance comparison must fail. A compilation error alone is insufficient.
- Automatic audit rejects a forbidden axiom and empty scope and includes a new
  declaration without editing a disclosure list; record exact output.
- Full build, fresh runtime audits, source-bound input hashes and mutations are
  recorded. Reviewers analyze exact candidate files and observed evidence;
  their judgments do not constitute independent Lean execution.
- One initial native review round and one focused remediation round if needed.
  A failed invocation may be retried with its failure retained.

This is a finite operation-contract increment. It establishes no deployed
contract fidelity, general solvency, composition rule, authenticated authority,
full capability lifecycle, dimensioned IR or serialized certificate checking.
Corpus normalization remains the next independent work package.

```

## lean/DefiKernel/Core.lean SHA256 767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d
```
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

```

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

## lean/DefiKernel/Contracts.lean SHA256 22ec064df455f9472d7c48b956d27f700fc54862f1d7f0bb0acb1051b84e84b2
```
import DefiKernel.Core

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

-- BEGIN PROOFS

theorem liftBase_ok_iff (result : Except Refusal State) (s' : State) :
    liftBase result = .ok s' ↔ result = .ok s' := by
  cases result <;> simp [liftBase]

/-- Success means both trusted contract satisfaction and actual base execution success. -/
theorem run_ok_iff {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) :
    run contract p env t s = .ok s' ↔
      contract.accepts s env t = true ∧ execute p env t s = .ok s' := by
  by_cases hc : contract.accepts s env t = true
  · simp [run, hc, liftBase_ok_iff]
  · simp [run, hc]

/-- Successful execution retains every original check and the exact update equation. -/
theorem run_valid_update {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s') :
    contract.accepts s env t = true ∧
      ∃ hv : Valid p env t s, applyEffect s t hv.2.2.2.1 = s' := by
  obtain ⟨hc, hb⟩ := (run_ok_iff contract p env t s s').mp h
  exact ⟨hc, (execute_ok_iff p env t s s').mp hb⟩

theorem run_always {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
    run (always E) p env t s = liftBase (execute p env t s) := rfl

theorem run_contract_refused {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s : State) (hc : contract.accepts s env t = false) :
    run contract p env t s = .error .contract := by simp [run, hc]

theorem run_base_refused {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s : State) (reason : Refusal)
    (hc : contract.accepts s env t = true) (hb : execute p env t s = .error reason) :
    run contract p env t s = .error (.base reason) := by simp [run, hc, hb, liftBase]

theorem run_accounting {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s') (a : Asset) :
    total s' a = total s a + t.supplyChange a :=
  execute_accounting p env t s s' ((run_ok_iff contract p env t s s').mp h).2 a

theorem run_locality {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s')
    (c : Cell) (hc : c ∉ t.writes) : s'.balance c = s.balance c :=
  execute_locality p env t s s' ((run_ok_iff contract p env t s s').mp h).2 c hc

theorem run_authority {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s') :
    DebitAuthorized p t ∧ SupplyAuthorized p t :=
  execute_authority p env t s s' ((run_ok_iff contract p env t s s').mp h).2

end DefiKernel.Contracts

```

## lean/DefiKernel/ContractExamples.lean SHA256 4423c79ae828489f07d5e1a2db93285a6c30b56912b467df40767026f2e0e51b
```
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

```
