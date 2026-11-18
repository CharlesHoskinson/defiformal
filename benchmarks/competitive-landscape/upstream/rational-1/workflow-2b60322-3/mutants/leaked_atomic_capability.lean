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

def entry : PublicState := initial 3 (by norm_num)
def actual : SequenceResult := atomicRaw entry rollbackCalls
def probe : Bool :=
  decide (actual.failure = some (.unauthorized,2)) &&
  decide (actual.state.capabilities = entry.capabilities)

#eval do
  report "leaked_atomic_capability" actual
  IO.println s!"CONTROL leaked_atomic_capability {probe}"

end RationalWorkflow.ControlWitnesses
