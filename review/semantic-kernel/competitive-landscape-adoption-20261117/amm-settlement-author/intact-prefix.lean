import DefiKernel.AMM.Rational
import DefiKernel.Typed.Transition
import Mathlib.Data.Fintype.Basic

/-! Actual rational pool quoting and registered Typed wallet settlement at raw scale1. -/
namespace DefiKernel.AMM.Settlement
open DefiKernel.Typed

inductive Party where | trader | pool deriving DecidableEq, Repr
inductive Asset where | x | y deriving DecidableEq, Repr
inductive Domain where | pool deriving DecidableEq, Repr
instance : Fintype Party := ⟨{.trader, .pool}, by intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.x, .y}, by intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.pool}, by intro d; cases d; simp⟩

abbrev S := State Party Asset Domain
abbrev Store := CapabilityStore Party Asset Domain
abbrev W := ExecutionResult Party Asset Domain

def operation : OperationId := ⟨0⟩
def context : InvocationContext Party Domain := ⟨.trader, .pool⟩
def environment : Environment Asset Domain := fun _ => none
def request : Request Party Asset Domain := ⟨operation, [], [], [⟨0⟩, ⟨1⟩, ⟨2⟩], none⟩
def quoteReads : List (Cell Party Asset Domain) :=
  [(.pool, .pool, .x), (.pool, .pool, .y)]

def quotePool (pre : S) : Rational.Pool :=
  ⟨pre.balance (.pool, .pool, .x), pre.balance (.pool, .pool, .y)⟩

def template (amount output : ℚ) : Template Party Asset Domain where
  signature := []
  domain := .pool
  partyArity := 0
  guard := .lit true
  deltas := [
    ⟨.x, ⟨.pool, .literal .trader⟩, .lit (-amount)⟩,
    ⟨.x, ⟨.pool, .literal .pool⟩, .lit amount⟩,
    ⟨.y, ⟨.pool, .literal .trader⟩, .lit output⟩,
    ⟨.y, ⟨.pool, .literal .pool⟩, .lit (-output)⟩]
  supplyDeltas := []
  stateReads := [⟨.x, ⟨.pool, .literal .pool⟩⟩, ⟨.y, ⟨.pool, .literal .pool⟩⟩]
  envReads := []
  writes := [⟨.x, ⟨.pool, .literal .trader⟩⟩, ⟨.x, ⟨.pool, .literal .pool⟩⟩,
    ⟨.y, ⟨.pool, .literal .trader⟩⟩, ⟨.y, ⟨.pool, .literal .pool⟩⟩]

def registry (amount output : ℚ) : Registry Party Asset Domain :=
  fun op => if op = operation then some (template amount output) else none

def evaluated (amount output : ℚ) : Evaluated Party Asset Domain :=
  ⟨true, [((.pool, .trader, .x), -amount), ((.pool, .pool, .x), amount),
    ((.pool, .trader, .y), output), ((.pool, .pool, .y), -output)],
    [], [], [], quoteReads, [],
    [(.pool, .trader, .x), (.pool, .pool, .x), (.pool, .trader, .y), (.pool, .pool, .y)]⟩

/-- Native quote uses the same pre-state later passed to Typed.execute; no external reserves. -/
def run (amount fee : ℚ) (store : Store) (pre : S) :
    Except (Rational.Refusal ⊕ Typed.Refusal) W := do
  let quoted ← (Rational.swapPool (quotePool pre) amount fee).mapError Sum.inl
  (Typed.execute (registry amount quoted.output) store context environment 0 request pre).mapError Sum.inr

def fullStore : Store :=
  ⟨[⟨⟨.trader, .pool, operation, .invoke⟩, true⟩,
    ⟨⟨.trader, .pool, operation, .debit (.pool, .trader, .x)⟩, true⟩,
    ⟨⟨.trader, .pool, operation, .debit (.pool, .pool, .y)⟩, true⟩]⟩


end DefiKernel.AMM.Settlement

namespace DefiKernel.AMM.SettlementAudit
open DefiKernel.Typed DefiKernel.AMM.Settlement
private def initial (wallet x y : Nat) : S where
  balance
    | (.pool, .trader, .x) => wallet
    | (.pool, .pool, .x) => x
    | (.pool, .trader, .y) => 0
    | (.pool, .pool, .y) => y
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def resultMatches (actual : Except (Rational.Refusal ⊕ Typed.Refusal) W)
    (traderX poolX traderY poolY : ℚ) : Bool :=
  match actual with
  | .error _ => false
  | .ok post => decide (post.state.balance (.pool, .trader, .x) = traderX ∧
      post.state.balance (.pool, .pool, .x) = poolX ∧
      post.state.balance (.pool, .trader, .y) = traderY ∧
      post.state.balance (.pool, .pool, .y) = poolY ∧ post.capabilities = fullStore)
private def refusalMatches (actual : Except (Rational.Refusal ⊕ Typed.Refusal) W)
    (reason : Rational.Refusal ⊕ Typed.Refusal) : Bool :=
  match actual with
  | .ok _ => false
  | .error observed => decide (observed = reason)
private def noTraderDebit : Store :=
  ⟨[⟨⟨.trader, .pool, operation, .invoke⟩, true⟩,
    ⟨⟨.trader, .pool, operation, .debit (.pool, .pool, .y)⟩, true⟩]⟩
private def noPoolDebit : Store := ⟨fullStore.entries.take 2⟩
private def revokedPoolDebit : Store :=
  ⟨[⟨⟨.trader, .pool, operation, .invoke⟩, true⟩,
    ⟨⟨.trader, .pool, operation, .debit (.pool, .trader, .x)⟩, true⟩,
    ⟨⟨.trader, .pool, operation, .debit (.pool, .pool, .y)⟩, false⟩]⟩
private def checks : List (String × Bool) := [
  ("fee_retained_actual_four_balances", resultMatches (run 2 (1/2) fullStore (initial 5 10 20))
    3 12 (20/11) (200/11)),
  ("zero_fee_unrounded_four_balances", resultMatches (run 2 0 fullStore (initial 5 10 20))
    3 12 (10/3) (50/3)),
  ("all_input_funded_exactly", resultMatches (run 2 (1/2) fullStore (initial 2 10 20))
    0 12 (20/11) (200/11)),
  ("zero_x_reserve", refusalMatches (run 2 0 fullStore (initial 5 0 20)) (.inl .badReserve)),
  ("zero_y_reserve", refusalMatches (run 2 0 fullStore (initial 5 10 0)) (.inl .badReserve)),
  ("zero_amount", refusalMatches (run 0 0 fullStore (initial 5 10 20)) (.inl .badAmount)),
  ("negative_amount", refusalMatches (run (-1) 0 fullStore (initial 5 10 20)) (.inl .badAmount)),
  ("negative_fee", refusalMatches (run 2 (-1/2) fullStore (initial 5 10 20)) (.inl .badFee)),
  ("full_fee", refusalMatches (run 2 1 fullStore (initial 5 10 20)) (.inl .badFee)),
  ("quote_before_typed_authority", refusalMatches (run 0 1 ⟨[]⟩ (initial 5 10 20)) (.inl .badAmount)),
  ("actual_invoke_authority", refusalMatches (run 2 (1/2) ⟨[]⟩ (initial 5 10 20)) (.inr .unauthorizedInvoke)),
  ("actual_trader_debit_authority", refusalMatches (run 2 (1/2) noTraderDebit (initial 5 10 20))
    (.inr .unauthorizedDebit)),
  ("actual_pool_debit_authority", refusalMatches (run 2 (1/2) noPoolDebit (initial 5 10 20))
    (.inr .unauthorizedDebit)),
  ("actual_revoked_pool_debit", refusalMatches (run 2 (1/2) revokedPoolDebit (initial 5 10 20))
    (.inr .unauthorizedDebit)),
  ("actual_trader_insufficient_funds", refusalMatches (run 2 (1/2) fullStore (initial 1 10 20))
    (.inr .insufficientFunds))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty settlement controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate settlement controls")
  match run 2 (1/2) fullStore (initial 5 10 20) with
  | .error reason => IO.println s!"SETTLEMENT_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"SETTLEMENT_OBSERVATION {post.state.balance (.pool, .trader, .x)} {post.state.balance (.pool, .pool, .x)} {post.state.balance (.pool, .trader, .y)} {post.state.balance (.pool, .pool, .y)}"
  for (name, passed) in checks do IO.println s!"SETTLEMENT_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual settlement comparison")
  IO.println s!"SETTLEMENT_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.AMM.SettlementAudit