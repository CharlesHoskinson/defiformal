import DefiKernel.Arithmetic.Examples

/-! Full observations are independent of production query/executor implementation. -/
namespace DefiKernel.Arithmetic.Tests
open Typed Examples

def wordResultEq (actual expected : WordResult) : Bool := decide (actual = expected)

def quoteResultEq (actual expected : QuoteResult) : Bool := decide (actual = expected)

def quantityEq (actualAmount expectedAmount : ℚ) (actualWord expectedWord : WordResult) : Bool :=
  decide (actualAmount = expectedAmount) && wordResultEq actualWord expectedWord

def pureObservationEq (actual expected : PureObservation) : Bool :=
  match actual, expected with
  | .word a, .word e => wordResultEq a e
  | .quote a, .quote e => quoteResultEq a e
  | .quantity a aw, .quantity e ew => quantityEq a e aw ew
  | _, _ => false

def stateEq (actual expected : State Party Asset Domain) : Bool :=
  allCells.all (fun cell ↦ decide (actual.balance cell = expected.balance cell))

def executionResultEq (actual expected : Except Refusal (ExecutionResult Party Asset Domain)) :
    Bool :=
  match actual, expected with
  | .error a, .error e => decide (a = e)
  | .ok a, .ok e => stateEq a.state e.state && decide (a.capabilities = e.capabilities)
  | _, _ => false

def referenceObservationEq (actual expected : Except Arithmetic.Failure ReferenceObservation) :
    Bool :=
  match actual, expected with
  | .error a, .error e => decide (a = e)
  | .ok a, .ok e => stateEq a.1.1 e.1.1 && decide (a.1.2 = e.1.2) &&
      executionResultEq a.2 e.2
  | _, _ => false

def runtimeChecks : List (String × Bool) :=
  literalInputs.map fun name ↦
    (name, match pureCases.lookup name, expectedPureCases.lookup name with
      | some actual, some expected => pureObservationEq actual expected
      | none, none => match referenceCases.lookup name, expectedReferenceCases.lookup name with
        | some actual, some expected => referenceObservationEq actual expected
        | _, _ => false
      | _, _ => false)

-- BEGIN PROOFS

theorem stateEq_iff (actual expected : State Party Asset Domain) :
    stateEq actual expected = true ↔ actual = expected := by
  unfold stateEq
  rw [List.all_eq_true]
  constructor
  · intro h
    have balances : actual.balance = expected.balance := by
      funext cell
      exact of_decide_eq_true (h cell (allCells_complete cell))
    cases actual
    cases expected
    simp_all
  · rintro rfl
    intro cell _
    simp

end DefiKernel.Arithmetic.Tests
