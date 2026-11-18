import DefiKernel.Lending.Types
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.Ring

/-! Repayment is a cash transfer plus capped liability/supply burn; no oracle or health guard. -/
namespace DefiKernel.Lending.Repay
open DefiKernel.Typed DefiKernel.Lending

def signature : List (Unit Asset) := [.amount .cash]
def amount : E signature (.amount Asset.cash) := .arg .here
/-- Explicit denomination: one cash unit per debt unit. -/
def debtBurn : E signature (.amount Asset.debt) :=
  .binary (.unconvert Asset.debt Asset.cash) amount (.lit 1)
def outstanding (borrower : Borrower) : E signature (.amount Asset.cash) :=
  .binary (.convert Asset.debt Asset.cash) (.balance (ref .debt borrower.party)) (.lit 1)
def template (borrower : Borrower) : Op where
  signature := signature
  domain := .lending
  partyArity := 0
  guard := .binary .and (.binary (.le (.amount Asset.cash)) (.lit 0) amount)
    (.binary (.le (.amount Asset.cash)) amount (outstanding borrower))
  deltas := [
    ⟨.cash, ref .cash borrower.party, .lit 0⟩,
    ⟨.cash, ref .cash .pool, .lit 0⟩,
    ⟨.debt, ref .debt borrower.party, .unary (.neg (.amount Asset.debt)) debtBurn⟩]
  supplyDeltas := [⟨.lending, .debt, .unary (.neg (.amount Asset.debt)) debtBurn⟩]
  stateReads := [packedRef .debt borrower.party]
  envReads := []
  writes := [packedRef .cash borrower.party, packedRef .cash .pool, packedRef .debt borrower.party]
private def registry (borrower : Borrower) : Registry Party Asset Domain :=
  fun op => if op = repayId then some (template borrower) else none

def request (borrower : Borrower) (ids : List CapabilityId) (quantity : ℚ) : Request Party Asset Domain :=
  ⟨repayId, [], [⟨.amount .cash, quantity⟩], ids, some borrower.party⟩
/-- The public request always binds the intended borrower to the authenticated actual caller. -/
def run (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (pre : Ledger) : Except Typed.Refusal World :=
  Typed.execute (registry borrower) store ctx (fun _ => none) 0 (request borrower ids quantity) pre

def authorityConfig (borrower : Borrower) : AuthorityConfig Party Domain :=
  registryAuthorityConfig (registry borrower) (fun _ => .admin)
def grants (borrower : Borrower) : List (Grant Party Asset Domain) := [
  ⟨borrower.party,.lending,repayId,.invoke⟩,
  ⟨borrower.party,.lending,repayId,.debit (.lending,borrower.party,.cash)⟩,
  ⟨borrower.party,.lending,repayId,.debit (.lending,borrower.party,.debt)⟩,
  ⟨borrower.party,.lending,repayId,.changeSupply .lending .debt⟩]
def issueGrants (borrower : Borrower) (store : Store) :
    List (Grant Party Asset Domain) → Except AuthorityFailure Store
  | [] => .ok store
  | grant::rest => do
    let (_, next) ← issueCapability (authorityConfig borrower) ⟨.admin,.lending⟩ store grant
    issueGrants borrower next rest
def provisioned (borrower : Borrower) : Except AuthorityFailure Store :=
  issueGrants borrower .empty (grants borrower)
def ids : List CapabilityId := [⟨0⟩,⟨1⟩,⟨2⟩,⟨3⟩]
def evaluated (borrower : Borrower) (quantity : ℚ) (pre : Ledger) :
    Evaluated Party Asset Domain :=
  ⟨decide (0 ≤ quantity) && decide (quantity ≤ pre.balance (.lending,borrower.party,.debt)),
    [((.lending,borrower.party,.cash),-quantity), ((.lending,.pool,.cash),quantity),
      ((.lending,borrower.party,.debt),-quantity)],
    [((.lending,.debt),-quantity)],
    [(.lending,borrower.party,.debt)], [], [(.lending,borrower.party,.debt)], [],
    [(.lending,borrower.party,.cash), (.lending,.pool,.cash), (.lending,borrower.party,.debt)]⟩

def fixtureStore (borrower : Borrower) : Store := ⟨(grants borrower).map (fun grant => ⟨grant,true⟩)⟩

end DefiKernel.Lending.Repay

namespace DefiKernel.Lending.RepayAudit
open DefiKernel.Typed DefiKernel.Lending
private def initial (cash debt : Nat) : Ledger where
  balance
    | (.lending,.alice,.cash) => cash
    | (.lending,.pool,.cash) => 10
    | (.lending,.alice,.debt) => debt
    | (.lending,.alice,.collateral) => 5
    | (.lending,.bob,.cash) => 4
    | (.lending,.bob,.debt) => 7
    | (.lending,.bobLocked,.collateral) => 20
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def resultMatches (borrower : Borrower) (store : Store)
    (actual : Except Typed.Refusal World) (cash poolCash debt : ℚ) : Bool :=
  match actual with
  | .error _ => false
  | .ok post => decide (post.state.balance (.lending,borrower.party,.cash)=cash ∧
      post.state.balance (.lending,.pool,.cash)=poolCash ∧
      post.state.balance (.lending,borrower.party,.debt)=debt ∧ post.capabilities=store)
private def refusalMatches (actual : Except Typed.Refusal World) (expected : Typed.Refusal) : Bool :=
  match actual with
  | .ok _ => false
  | .error reason => decide (reason=expected)
private def noCashDebit : Store :=
  ⟨(Repay.fixtureStore .alice).entries.set 1
    ⟨⟨.alice,.lending,repayId,.debit (.lending,.alice,.cash)⟩,false⟩⟩
private def noDebtDebit : Store :=
  ⟨(Repay.fixtureStore .alice).entries.set 2
    ⟨⟨.alice,.lending,repayId,.debit (.lending,.alice,.debt)⟩,false⟩⟩
private def noDebtSupply : Store :=
  ⟨(Repay.fixtureStore .alice).entries.set 3
    ⟨⟨.alice,.lending,repayId,.changeSupply .lending .debt⟩,false⟩⟩
private def invokeOnly : Store := ⟨(Repay.fixtureStore .alice).entries.take 1⟩
private def overgrantedBob : Store :=
  ⟨(Repay.fixtureStore .alice).entries.map (fun cap => {cap with holder:=.bob})⟩
private def run (quantity : ℚ) (pre : Ledger := initial 3 2)
    (store : Store := Repay.fixtureStore .alice) : Except Typed.Refusal World :=
  Repay.run .alice store (borrowerContext .alice) Repay.ids quantity pre
private def checks : List (String × Bool) := [
  ("real_provisioning_alice", decide (Repay.provisioned .alice = .ok (Repay.fixtureStore .alice))),
  ("real_provisioning_bob", decide (Repay.provisioned .bob = .ok (Repay.fixtureStore .bob))),
  ("cash_and_debt_move_together_unhealthy", resultMatches .alice (Repay.fixtureStore .alice) (run 1) 2 11 1),
  ("fractional_repayment", resultMatches .alice (Repay.fixtureStore .alice) (run (1/2)) (5/2) (21/2) (3/2)),
  ("exact_full_debt_repayment", resultMatches .alice (Repay.fixtureStore .alice) (run 2) 1 12 0),
  ("bob_position_bound", resultMatches .bob (Repay.fixtureStore .bob)
    (Repay.run .bob (Repay.fixtureStore .bob) (borrowerContext .bob) Repay.ids 2 (initial 3 2)) 2 12 5),
  ("all_collateral_and_other_debt_unchanged", match run 1 with
    | .error _ => false
    | .ok post => decide (post.state.balance (.lending,.alice,.collateral)=5 ∧
        post.state.balance (.lending,.aliceLocked,.collateral)=0 ∧
        post.state.balance (.lending,.bobLocked,.collateral)=20 ∧
        post.state.balance (.lending,.bob,.debt)=7)),
  ("zero_repay_invoke_only", resultMatches .alice invokeOnly (run 0 (initial 3 2) invokeOnly) 3 10 2),
  ("over_repayment_guard", refusalMatches (run 3 (initial 10 2)) .guard),
  ("negative_repayment_guard", refusalMatches (run (-1)) .guard),
  ("cash_insufficient_funds", refusalMatches (run 1 (initial 0 2)) .insufficientFunds),
  ("invoke_permission", refusalMatches (run 1 (initial 3 2) ⟨[]⟩) .unauthorizedInvoke),
  ("cash_debit_permission", refusalMatches (run 1 (initial 3 2) noCashDebit) .unauthorizedDebit),
  ("debt_debit_permission", refusalMatches (run 1 (initial 3 2) noDebtDebit) .unauthorizedDebit),
  ("debt_supply_permission", refusalMatches (run 1 (initial 3 2) noDebtSupply) .unauthorizedSupply),
  ("owner_binding_before_overgranted_rights", refusalMatches
    (Repay.run .alice overgrantedBob (borrowerContext .bob) Repay.ids 1 (initial 3 2)) .actorMismatch),
  ("cash_conservation_debt_supply_reconciliation", match run 1 with
    | .error _ => false
    | .ok post => decide (total post.state .lending .cash=17 ∧
        total post.state .lending .collateral=25 ∧ total post.state .lending .debt=8))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty repayment controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate repayment controls")
  match run 1 with
  | .error reason => IO.println s!"REPAY_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"REPAY_OBSERVATION {post.state.balance (.lending,.alice,.cash)} {post.state.balance (.lending,.pool,.cash)} {post.state.balance (.lending,.alice,.debt)}"
  match Repay.run .alice overgrantedBob (borrowerContext .bob) Repay.ids 1 (initial 3 2) with
  | .error reason => IO.println s!"REPAY_BINDING_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"REPAY_BINDING_OBSERVATION {post.state.balance (.lending,.alice,.cash)} {post.state.balance (.lending,.pool,.cash)} {post.state.balance (.lending,.alice,.debt)}"
  for (name,passed) in checks do IO.println s!"REPAY_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual repayment comparison")
  IO.println s!"REPAY_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Lending.RepayAudit