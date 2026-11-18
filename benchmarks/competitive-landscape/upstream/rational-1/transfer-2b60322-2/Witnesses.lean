import Model

set_option synthInstance.maxSize 4096

namespace RationalTransfer.Witnesses

def capabilities : Finset Capability :=
  [.invoke .vault .transfer, .invoke .vault .deposit, .invoke .vault .withdraw,
   .supply .vault false, .supply .vault true].toFinset ∪
    (([.alice, .bob, .vault, .pool] : List Account).flatMap fun account =>
      [Asset.cash, .shareA, .shareB].map fun asset => Capability.debit .vault account asset).toFinset

def initial (amount : ℚ) (nonnegative : 0 ≤ amount) : PublicState where
  ledger := ⟨fun cell => if cell = (.alice, .usd) then amount else 0,
    fun cell => by
      split_ifs
      · exact nonnegative
      · exact le_refl 0⟩
  rates := fun vaultB => if vaultB then 5/3 else 3/2
  capabilities := capabilities
  history := []

def cells : List Cell := DefiKernel.Examples.allCells
def assets : List Asset := [.cash, .shareA, .shareB]

def observeEvent (e : Event) : RecordedCall × List ℚ × List ℚ × List ℚ :=
  (e.call, cells.map e.delta, assets.map e.issued, assets.map e.burned)

def observe (s : PublicState) :
    List ℚ × List ℚ × List ℚ × Finset Capability × List (RecordedCall × List ℚ × List ℚ × List ℚ) :=
  (cells.map s.ledger.balance, assets.map s.supply, [s.rates false, s.rates true],
    s.capabilities, s.history.map observeEvent)

def refusedExactly (result : Result) (reason : Reason) (state : PublicState) : Bool :=
  match result with
  | .refused actual post => decide (actual = reason ∧ observe post = observe state)
  | .success _ => false

def send (state : PublicState) (target : String) (amount : ℚ) : Result :=
  execute state (.transfer "operator" "alice" target "cash" (.exact amount))

def transferredExactly (result : Result) (state : PublicState) (target : Account)
    (amount alice bob : ℚ) : Bool :=
  match result with
  | .refused _ _ => false
  | .success post =>
    decide (post.ledger.balance (.alice, .usd) = alice ∧ post.ledger.balance (.bob, .usd) = bob ∧
      post.supply .cash = state.supply .cash ∧
      post.rates false = 3/2 ∧ post.rates true = 5/3 ∧ post.capabilities = state.capabilities ∧
      post.history.map observeEvent =
        [(.transfer .vault .alice target .cash amount,
          cells.map (fun cell => (-amount * (if cell = (.alice, .usd) then 1 else 0) +
            amount * (if cell = (target, .usd) then 1 else 0))), [0,0,0], [0,0,0])])

def fractional : PublicState := initial (5/7) (by norm_num)
def selfState : PublicState := initial (1/3) (by norm_num)
def zeroState : PublicState := initial 0 (by norm_num)
def unboundedAmount : ℚ := (2^200+1)/3^50
def unbounded : PublicState := initial unboundedAmount (by norm_num [unboundedAmount])
def noAuthority : PublicState := { zeroState with capabilities := ∅ }

def checks : List (String × Bool) := [
  ("transfer_fractional", transferredExactly (send fractional "bob" (2/7)) fractional .bob (2/7) (3/7) (2/7)),
  ("transfer_self", transferredExactly (send selfState "alice" (1/3)) selfState .alice (1/3) (1/3) 0 &&
    refusedExactly (send selfState "alice" (2/3)) .insufficientFunds selfState),
  ("transfer_zero", transferredExactly (send zeroState "bob" 0) zeroState .bob 0 0 0),
  ("transfer_unbounded", transferredExactly (send unbounded "bob" unboundedAmount)
    unbounded .bob unboundedAmount 0 unboundedAmount),
  ("bad_target_precedes_amount", refusedExactly
    (execute noAuthority (.transfer "operator" "unknown" "bob" "cash" (.exact (-1)))) .badTarget noAuthority),
  ("bad_target_precedes_number", refusedExactly
    (execute noAuthority (.transfer "operator" "unknown" "bob" "cash" (.malformed "0.5"))) .badTarget noAuthority),
  ("bad_number", refusedExactly
    (execute noAuthority (.transfer "operator" "alice" "bob" "cash" (.malformed "0.5"))) .badNumber noAuthority),
  ("bad_amount_precedes_authority", refusedExactly (send noAuthority "bob" (-1)) .badAmount noAuthority),
  ("authority_precedes_funds", refusedExactly (send noAuthority "bob" 1) .unauthorized noAuthority),
  ("zero_requires_authority", refusedExactly (send noAuthority "bob" 0) .unauthorized noAuthority),
  ("self_requires_authority", refusedExactly (send noAuthority "alice" 0) .unauthorized noAuthority),
  ("bad_operation", refusedExactly (execute noAuthority (.unsupported "unknown")) .badOperation noAuthority)
]

def main : IO Unit := do
  for (name, passed) in checks do
    if passed then IO.println s!"WITNESS {name} passed"
    else throw (IO.userError s!"WITNESS {name} FAILED")
  match send fractional "bob" (2/7) with
  | .success state => IO.println s!"FRACTIONAL {state.ledger.balance (.alice, .usd)} {state.ledger.balance (.bob, .usd)} SUPPLY {state.supply .cash} EVENTS {state.history.length}"
  | .refused reason _ => IO.println s!"REFUSED {repr reason}"

#eval main

end RationalTransfer.Witnesses
