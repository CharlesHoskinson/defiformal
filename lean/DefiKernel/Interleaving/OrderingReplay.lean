import DefiKernel.Interleaving.Examples

/-! Fresh bounded replay of the existing development fixture. Both invocations authenticate
Alice; the right invocation pays Bob. This is not a deployed-protocol or universal-scheduler claim. -/
namespace DefiKernel.Interleaving.OrderingReplay
open Typed Composition Parallel Typed.Examples Parallel.Examples Interleaving.Examples

/-- Independent complete expected attempt chain for right-before-left. -/
def rightFirstAttempts : List ExpectedAttempt := [
  ⟨.right, 0, peerUSD 6, sharedBalance 0 0 10, sharedBalance 0 6 4,
    .ok (transferEvent 0 (peerUSD 6) vaultUSD bobUSD 6 [output 0 1 .usd 6])⟩,
  ⟨.left, 0, usd 7, sharedBalance 0 6 4, sharedBalance 0 6 4,
    .error (.kernel .insufficientFunds)⟩]

def completeResult (actual : Interleaving.Examples.R) (expectedSchedule : Schedule)
    (balance : C → ℚ) (left right : Obs) : Bool :=
  match actual with
  | .refused _ _ _ => false
  | .executed schedule _ => decide (schedule = expectedSchedule) &&
      Interleaving.Examples.matchesExpected actual balance left right 1 1

def financialBound (actual : Interleaving.Examples.R) : Bool :=
  match actual with
  | .refused _ _ _ => false
  | .executed _ m => decide (
      m.world.state.balance aliceUSD + m.world.state.balance bobUSD +
        m.world.state.balance vaultUSD = 10 ∧
      m.world.state.balance aliceUSD + m.world.state.balance bobUSD ≤ 10 ∧
      m.world.state.balance protectedCell = 9 ∧
      ∀ d a, m.supply d a = 0)

def checks : List (String × Bool) := [
  ("initial_full_ledger", decide (∀ c, sharedInitial.state.balance c = sharedBalance 0 0 10 c)),
  ("initial_exact_capabilities", decide (sharedInitial.capabilities = store)),
  ("left_right_full_result", completeResult sharedLR [.left, .right] (sharedBalance 7 0 3)
    withdrawalLeft (observed [] (failure 0 (peerUSD 6) (.kernel .insufficientFunds)))),
  ("right_left_full_result", completeResult sharedRL [.right, .left] (sharedBalance 0 6 4)
    (observed [] (failure 0 (usd 7) (.kernel .insufficientFunds))) withdrawalRight),
  ("left_right_full_attempt_chain", attemptsMatch sharedLR sharedLRAttempts),
  ("right_left_full_attempt_chain", attemptsMatch sharedRL rightFirstAttempts),
  ("order_independence_refuted", !Interleaving.observationsEqual sharedLR sharedRL),
  ("left_right_observed_conservation_bound", financialBound sharedLR),
  ("right_left_observed_conservation_bound", financialBound sharedRL),
  ("reject_changed_expected_ledger", !completeResult sharedLR [.left, .right]
    (sharedBalance 8 0 2) withdrawalLeft
    (observed [] (failure 0 (peerUSD 6) (.kernel .insufficientFunds)))),
  ("reject_changed_refusal_location", !completeResult sharedRL [.right, .left]
    (sharedBalance 0 6 4)
    (observed [] (failure 1 (usd 7) (.kernel .insufficientFunds))) withdrawalRight),
  ("reject_changed_refusal_reason", !completeResult sharedLR [.left, .right]
    (sharedBalance 7 0 3) withdrawalLeft
    (observed [] (failure 0 (peerUSD 6) (.kernel .guard))))]

def printActual (name : String) (actual : Interleaving.Examples.R) : IO Unit := do
  match actual with
  | .refused reason _ _ => IO.println s!"RESULT {name} admission_refused {reprStr reason}"
  | .executed schedule m =>
    IO.println s!"RESULT {name} schedule={reprStr schedule} attempts={m.attempts.length}"
    for cell in cells do
      IO.println s!"LEDGER {name} {reprStr cell} {m.world.state.balance cell}"
    IO.println s!"CAPABILITIES {name} {reprStr m.world.capabilities}"
    for branch in [BranchId.left, .right] do
      let localState := m.local branch
      IO.println s!"BRANCH {name} {reprStr branch} consumed={localState.consumed} nextIndex={localState.nextIndex} events={localState.events.length} outputs={localState.outputs.length}"
      match localState.failure with
      | none => IO.println s!"REFUSAL {name} {reprStr branch} none"
      | some refused =>
        IO.println s!"REFUSAL {name} {reprStr branch} index={refused.index} reason={reprStr refused.reason}"

def runChecks : IO Unit := do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty ordering inventory")
  if !decide (checks.map Prod.fst).Nodup then
    throw (IO.userError "BLOCKED: duplicate ordering inventory")
  printActual "left_right" sharedLR
  printActual "right_left" sharedRL
  for (name, passed) in checks do
    IO.println s!"ORDERING {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: ordering comparison")
  IO.println s!"ORDERING PASSED {checks.length}/{checks.length}"

#eval runChecks

end DefiKernel.Interleaving.OrderingReplay
