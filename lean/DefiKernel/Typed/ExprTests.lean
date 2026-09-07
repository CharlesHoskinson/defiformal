import DefiKernel.Typed.Expr
import Mathlib.Tactic.NormNum

/-! Executed expression checks and kernel-checked examples. These are reference examples,
not deployed-protocol fidelity tests. -/
namespace DefiKernel.Typed
namespace ExprTests

inductive TestAsset where
  | usd | share | collateral | debt
  deriving DecidableEq, Repr

instance : Fintype TestAsset := ⟨{.usd, .share, .collateral, .debt}, by
  intro a; cases a <;> simp⟩

abbrev E := Expr Bool TestAsset Bool []
abbrev Context := EvalContext Bool TestAsset Bool []

def priceKey : ObservationKey Bool := ⟨false, ⟨0⟩⟩
def otherKey : ObservationKey Bool := ⟨false, ⟨1⟩⟩
def usdCell : CellRef Bool TestAsset Bool TestAsset.usd := ⟨false, .caller⟩

def initialState : State Bool TestAsset Bool :=
  ⟨fun c ↦ if c = (false, false, TestAsset.usd) then 10 else 0, by
    intro c; split <;> decide⟩

def changedState : State Bool TestAsset Bool :=
  ⟨fun c ↦ if c = (false, true, TestAsset.usd) then 99 else initialState.balance c, by
    intro c; split
    · decide
    · exact initialState.nonneg c⟩

def environment : Environment TestAsset Bool := fun key ↦
  if key = priceKey then some ⟨⟨.price TestAsset.collateral TestAsset.usd, 2⟩, 20⟩ else none

def context : Context := ⟨initialState, environment, false, [true], .nil, 25⟩
def changedContext : Context := { context with state := changedState }
def missingContext : Context := { context with env := fun _ ↦ none }
def wrongUnitContext : Context :=
  { context with env := fun _ ↦ some ⟨⟨.scalar, 2⟩, 20⟩ }

def priced : E (.amount TestAsset.usd) :=
  .binary (.convert TestAsset.collateral TestAsset.usd) (.lit 3) (.observe ⟨priceKey⟩)

def debtValued : E (.amount TestAsset.usd) :=
  .binary (.convert TestAsset.debt TestAsset.usd) (.lit 7) (.lit 1)

def shares : E (.amount TestAsset.share) :=
  .binary (.unconvert TestAsset.share TestAsset.usd) (.lit 10) (.lit 2)

def freshness : E .bool :=
  .binary (.le .scalar) (.binary (.sub .scalar) .now (.timestamp priceKey)) (.lit 10)

def ledgerRead : E (.amount TestAsset.usd) := .balance usdCell

def withInactiveRead : E (.amount TestAsset.usd) :=
  .ite (.lit true) ledgerRead (.observe ⟨otherKey⟩)

def withInactiveStateRead : E (.amount TestAsset.usd) :=
  .ite (.lit true) ledgerRead (.balance ⟨false, .literal true⟩)

def badParty : E (.amount TestAsset.usd) := .balance ⟨false, .argument 2⟩
def validParty : E (.amount TestAsset.usd) := .balance ⟨false, .argument 0⟩

def argumentValue (values : List (PackedValue TestAsset)) : Except EvalFailure ℚ := do
  let args ← Args.check [.amount TestAsset.usd] values
  return args.get .here

def checks : List (String × Bool) := [
  ("expr_exact_price_conversion", decide (priced.eval context = .ok 6)),
  ("expr_explicit_debt_valuation", decide (debtValued.eval context = .ok 7)),
  ("expr_inverse_price_conversion", decide (shares.eval context = .ok 5)),
  ("expr_exact_fractional_conversion", decide
    ((Expr.binary (.convert TestAsset.collateral TestAsset.usd) (.lit (1 / 3)) (.lit (3 / 2)) :
      E (.amount TestAsset.usd)).eval context = .ok (1 / 2))),
  ("expr_same_unit_addition", decide
    ((Expr.binary (.add (.amount TestAsset.usd)) (.lit 2) (.lit 3) :
      E (.amount TestAsset.usd)).eval context = .ok 5)),
  ("expr_scalar_scaling", decide
    ((Expr.binary (.scale (.amount TestAsset.usd)) (.lit 2) (.lit 3) :
      E (.amount TestAsset.usd)).eval context = .ok 6)),
  ("expr_signed_negation", decide
    ((Expr.unary (.neg (.amount TestAsset.usd)) (.lit 2) :
      E (.amount TestAsset.usd)).eval context = .ok (-2))),
  ("expr_safe_scalar_division", decide
    ((Expr.binary (.divide (.amount TestAsset.usd)) (.lit 3) (.lit 2) :
      E (.amount TestAsset.usd)).eval context = .ok (3 / 2))),
  ("expr_zero_scalar_division_refused", decide
    ((Expr.binary (.divide (.amount TestAsset.usd)) (.lit 3) (.lit 0) :
      E (.amount TestAsset.usd)).eval context = .error .divisionByZero)),
  ("expr_safe_ratio", decide
    ((Expr.binary (.ratio (.amount TestAsset.usd)) (.lit 3) (.lit 2) :
      E .scalar).eval context = .ok (3 / 2))),
  ("expr_zero_ratio_refused", decide
    ((Expr.binary (.ratio (.amount TestAsset.usd)) (.lit 3) (.lit 0) :
      E .scalar).eval context = .error .divisionByZero)),
  ("expr_zero_inverse_price_refused", decide
    ((Expr.binary (.unconvert TestAsset.share TestAsset.usd) (.lit 10) (.lit 0) :
      E (.amount TestAsset.share)).eval context = .error .divisionByZero)),
  ("expr_missing_observation_refused", decide
    (priced.eval missingContext = .error .missingObservation)),
  ("expr_wrong_observation_unit_refused", decide
    (priced.eval wrongUnitContext = .error .observationUnit)),
  ("expr_tracked_freshness", decide (freshness.eval context = .ok true)),
  ("expr_stale_observation", decide (freshness.eval { context with now := 40 } = .ok false)),
  ("expr_missing_timestamp_refused", decide
    ((Expr.timestamp priceKey : E .scalar).eval missingContext = .error .missingObservation)),
  ("expr_fresh_time_tracked", decide (.currentTime ∈ freshness.envReads)),
  ("expr_timestamp_observation_tracked", decide (.observation priceKey ∈ freshness.envReads)),
  ("expr_inactive_environment_branch_tracked", decide
    (.observation otherKey ∈ withInactiveRead.envReads)),
  ("expr_inactive_state_branch_tracked", decide (withInactiveStateRead.stateReads =
    [⟨TestAsset.usd, usdCell⟩, ⟨TestAsset.usd, ⟨false, .literal true⟩⟩])),
  ("expr_inactive_missing_branch_not_evaluated", decide (withInactiveRead.eval context = .ok 10)),
  ("expr_boolean_and_is_eager", decide
    ((Expr.binary .and (.lit false) (.observe ⟨otherKey⟩) : E .bool).eval context =
      .error .missingObservation)),
  ("expr_boolean_or_is_eager", decide
    ((Expr.binary .or (.lit true) (.observe ⟨otherKey⟩) : E .bool).eval context =
      .error .missingObservation)),
  ("expr_successful_party_lookup", decide (validParty.eval context = .ok 0)),
  ("expr_failed_party_lookup_refused", decide (badParty.eval context = .error .partyArgument)),
  ("expr_concrete_read_resolution", decide
    (ledgerRead.resolveStateReads false [] = .ok [(false, false, TestAsset.usd)])),
  ("expr_footprint_party_lookup_refused", decide
    (badParty.resolveStateReads false [true] = .error .partyArgument)),
  ("expr_checked_argument", decide (argumentValue [⟨.amount TestAsset.usd, 7⟩] = .ok 7)),
  ("expr_wrong_argument_unit_refused", decide
    (argumentValue [⟨.amount TestAsset.debt, 7⟩] = .error .argumentUnit)),
  ("expr_missing_argument_refused", decide (argumentValue [] = .error .argumentCount)),
  ("expr_excess_argument_refused", decide
    (argumentValue [⟨.amount TestAsset.usd, 7⟩, ⟨.amount TestAsset.usd, 8⟩] =
      .error .argumentCount)),
  ("expr_unrelated_balance_change", decide
    (ledgerRead.eval changedContext = ledgerRead.eval context)),
  ("expr_read_change_observed", decide
    (ledgerRead.eval { context with caller := true } = .ok 0))
]

end ExprTests

-- BEGIN PROOFS

namespace ExprTests

#eval do
  let mut failed := 0
  for (label, passed) in checks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Typed runtime comparisons failed: {failed}")

/-- This is a kernel-checked exact arithmetic fact, separate from the executed comparisons. -/
theorem price_conversion_exact : priced.eval context = .ok 6 := by
  norm_num [priced, Expr.eval, readObservation, context, environment, BinaryOp.eval,
    bind, Except.bind]

theorem inverse_price_exact : shares.eval context = .ok 5 := by
  norm_num [shares, Expr.eval, BinaryOp.eval, bind, Except.bind]

theorem zero_division_refused :
    (Expr.binary (.divide (.amount TestAsset.usd)) (.lit 3) (.lit 0) :
      E (.amount TestAsset.usd)).eval context = .error .divisionByZero := by decide

/-- Read dependence transports the result without evaluating the arithmetic expression. -/
theorem unrelated_balance_preserved : ledgerRead.eval context = ledgerRead.eval changedContext := by
  apply ledgerRead.eval_congr context changedContext rfl
  · intro ref href
    simp only [ledgerRead, Expr.stateReads, List.mem_singleton] at href
    subst ref
    rfl
  · intro key hkey
    simp [ledgerRead, Expr.envReads] at hkey

-- These commands must fail to elaborate their terms. Runtime unit checks are separate above.
#check_failure (Expr.binary (.add (.amount TestAsset.usd)) ledgerRead
  (.lit 1 : E (.amount TestAsset.debt)) : E (.amount TestAsset.usd))

#check_failure (Expr.binary (.convert TestAsset.collateral TestAsset.usd)
  (.lit 1 : E (.amount TestAsset.collateral))
  (.lit 2 : E (.price TestAsset.usd TestAsset.collateral)) : E (.amount TestAsset.usd))

#check_failure (Expr.binary (.scale (.amount TestAsset.debt)) (.lit 1)
  (.lit 2 : E (.amount TestAsset.debt)) : E (.amount TestAsset.usd))

end ExprTests
end DefiKernel.Typed
