import WorkflowControl

namespace RationalWorkflow.ControlWitnesses

def accounts : List Account := [.alice, .bob, .vault, .pool]
def assets : List Asset := [.cash, .shareA, .shareB]
def nativeAssets : List DefiKernel.Asset := [.usd, .share, .collateral, .debt]
def cells : List Cell := accounts.flatMap fun a => nativeAssets.map fun e => (a,e)
def capabilitiesFor (p : Principal) : List Capability :=
  [Capability.invoke p .transfer, Capability.invoke p .deposit, Capability.invoke p .withdraw,
    Capability.supply p false, Capability.supply p true] ++
    accounts.flatMap (fun a => assets.map (fun e => Capability.debit p a e))
def allCapabilities : List Capability := accounts.flatMap capabilitiesFor
def fullCapabilities : Finset Capability := (capabilitiesFor .vault).toFinset

def initial (cash : ℚ) (nonnegative : 0 ≤ cash) : PublicState where
  ledger := ⟨fun cell => if cell = (.alice, .usd) then cash else 0, by
    intro cell; split <;> simp_all⟩
  rates := fun v => if v then 5/3 else 3/2
  capabilities := fullCapabilities
  history := []

structure EventView where
  calls : List Call
  delta : List ℚ
  issued : List ℚ
  burned : List ℚ
  deriving DecidableEq, Repr
structure StateView where
  balances : List ℚ
  supply : List ℚ
  rates : List ℚ
  capabilities : List Bool
  history : List EventView
  deriving DecidableEq, Repr

def eventView (ev : Event) : EventView :=
  ⟨ev.calls, cells.map ev.delta, assets.map ev.issued, assets.map ev.burned⟩
def view (state : PublicState) : StateView :=
  ⟨cells.map state.ledger.balance, assets.map state.supply,
    [state.rates false, state.rates true],
    allCapabilities.map (fun cap => decide (cap ∈ state.capabilities)), state.history.map eventView⟩
def samePublic (left right : PublicState) : Bool := decide (view left = view right)
def check (label : String) (ok : Bool) : IO Unit :=
  unless ok do throw (IO.userError ("ASSERTION FAILED " ++ label))
def report (label : String) (result : SequenceResult) : IO Unit := do
  IO.println s!"ACTUAL {label}: committed={result.committed}, failure={reprStr result.failure}"
  IO.println (reprStr (view result.state))
def success (result : Result) : IO PublicState := match result with
  | .success state => pure state
  | .refused reason _ => throw (IO.userError ("unexpected refusal " ++ reprStr reason))
def refused (result : Result) (reason : Reason) (state : PublicState) : Bool := match result with
  | .refused actual post => decide (actual = reason) && samePublic post state
  | .success _ => false

def send (source target : String) (q : ℚ) : RawCall :=
  .transfer "operator" source target "cash" (.exact q)
def prefixCalls : List RawCall :=
  [send "alice" "bob" 1, send "bob" "alice" 2, send "alice" "bob" 1, send "alice" "bob" 1]
def cycleCalls : List RawCall :=
  [.deposit "operator" "alice" "vaultA" (.exact (3/2)),
   .transfer "operator" "alice" "bob" "shareA" (.exact 1),
   .withdraw "operator" "bob" "vaultA" (.exact 1), send "bob" "alice" (3/2)]
def rollbackCalls : List RawCall :=
  [.deposit "operator" "alice" "vaultA" (.exact (3/2)),
   .revoke "admin" (.invoke "operator" "withdraw"),
   .withdraw "operator" "alice" "vaultA" (.exact 1), send "alice" "bob" 1]

def refusalPrefix : IO Unit := do
  let entry := initial 2 (by norm_num)
  let actual := runRaw entry prefixCalls
  let first ← success (rawExecute entry (send "alice" "bob" 1))
  check "refusal_prefix" (decide (actual.failure = some (.insufficientFunds,1)) &&
    decide (actual.committed = 1) && samePublic actual.state first &&
    decide (actual.state.ledger.balance (.alice,.usd) = 1) &&
    decide (actual.state.ledger.balance (.bob,.usd) = 1) && decide (actual.state.history.length = 1))
  report "refusal_prefix" actual
  IO.println "WITNESS refusal_prefix passed"

def refusalPrecedence : IO Unit := do
  let entry := { initial 0 (by norm_num) with capabilities := ∅ }
  check "bad_target_before_amount" (refused (rawExecute entry (send "unknown" "bob" (-1))) .badTarget entry)
  check "bad_amount_before_authority" (refused (rawExecute entry (send "alice" "bob" (-1))) .badAmount entry)
  check "authority_before_funds" (refused (rawExecute entry (send "alice" "bob" 1)) .unauthorized entry)
  IO.println ("ACTUAL refusal_precedence: badTarget, badAmount, unauthorized; unchanged=" ++ reprStr (view entry))
  IO.println "WITNESS refusal_precedence passed"

def revokeBetweenCalls : IO Unit := do
  let entry := initial 3 (by norm_num)
  let first ← success (rawExecute entry (send "alice" "bob" 1))
  let revoked ← success (rawExecute first (.revoke "admin" (.debit "operator" "alice" "cash")))
  let last := rawExecute revoked (send "alice" "bob" 1)
  check "revoke_between_calls" (refused last .unauthorized revoked &&
    decide (revoked.ledger.balance (.alice,.usd) = 2) &&
    decide (revoked.ledger.balance (.bob,.usd) = 1) && decide (revoked.history.length = 2) &&
    decide (Capability.debit .vault .alice .cash ∉ revoked.capabilities))
  IO.println ("ACTUAL revoke_between_calls: unauthorized; " ++ reprStr (view last.publicState))
  IO.println "WITNESS revoke_between_calls passed"

def adminOnly : IO Unit := do
  let cap := Capability.debit .vault .alice .cash
  let entry := { initial 0 (by norm_num) with capabilities := fullCapabilities.erase cap }
  check "unauthorized_grant" (refused (rawExecute entry (.grant "alice" (.debit "operator" "alice" "cash"))) .unauthorized entry)
  let granted ← success (rawExecute entry (.grant "admin" (.debit "operator" "alice" "cash")))
  check "admin_grant" (decide (cap ∈ granted.capabilities) && decide (granted.history.length = 1) &&
    samePublic granted (adminUpdate entry (.grant .pool cap)))
  IO.println ("ACTUAL admin_only: Alice unauthorized; admin success; " ++ reprStr (view granted))
  IO.println "WITNESS admin_only passed"

def atomicRollback : IO Unit := do
  let entry := initial 3 (by norm_num)
  let staged := runRaw entry rollbackCalls
  let actual := atomicRaw entry rollbackCalls
  check "atomic_rollback_staging" (decide (staged.failure = some (.unauthorized,2)) &&
    decide (staged.committed = 2) && decide (staged.state.supply .shareA = 1) &&
    decide (Capability.invoke .vault .withdraw ∉ staged.state.capabilities))
  check "atomic_rollback" (decide (actual.failure = some (.unauthorized,2)) &&
    decide (actual.committed = 0) && samePublic actual.state entry)
  report "atomic_rollback staged" staged
  report "atomic_rollback public" actual
  IO.println "WITNESS atomic_rollback passed"

def atomicSuccess : IO Unit := do
  let entry := initial (3/2) (by norm_num)
  let sequential := runRaw entry cycleCalls
  let atomic := atomicRaw entry cycleCalls
  check "atomic_success" (decide (atomic.failure = none) && decide (atomic.committed = 4) &&
    samePublic atomic.state sequential.state && decide (atomic.state.history.length = 4) &&
    decide (atomic.state.ledger.balance (.alice,.usd) = 3/2) &&
    decide (atomic.state.ledger.balance (.bob,.usd) = 0) && decide (atomic.state.supply .shareA = 0))
  report "atomic_success" atomic
  IO.println "WITNESS atomic_success passed"

def main : IO Unit := do
  refusalPrefix
  refusalPrecedence
  revokeBetweenCalls
  adminOnly
  atomicRollback
  atomicSuccess

#eval main

end RationalWorkflow.ControlWitnesses
