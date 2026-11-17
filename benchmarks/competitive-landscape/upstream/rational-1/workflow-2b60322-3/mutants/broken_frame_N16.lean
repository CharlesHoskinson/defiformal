import ComposeModel
set_option synthInstance.maxSize 8192
namespace RationalWorkflow.ComposeWitnesses

def capabilities : Finset Capability :=
  [.invoke .vault .transfer,.invoke .vault .deposit,.invoke .vault .withdraw,
   .supply .vault false,.supply .vault true].toFinset ∪
  (([.alice,.bob,.vault,.pool] : List Account).flatMap fun a =>
    [Asset.cash,.shareA,.shareB].map fun e => Capability.debit .vault a e).toFinset

def initial (cash : ℚ) (positive : 0 ≤ cash) : PublicState where
  ledger := ⟨fun c => if c = (.alice,.usd) then cash else 0,
    fun c => by split_ifs; exact positive; exact le_refl 0⟩
  rates := fun v => if v then 5/3 else 3/2
  capabilities := capabilities
  history := []

def cells : List Cell := DefiKernel.Examples.allCells
def assets : List Asset := [.cash,.shareA,.shareB]
def observeEvent (e : Event) : List Call × List ℚ × List ℚ × List ℚ :=
  (e.calls,cells.map e.delta,assets.map e.issued,assets.map e.burned)
def allCapabilities : List Capability :=
  ([.alice,.bob,.vault,.pool] : List Principal).flatMap fun p =>
    [.invoke p .transfer,.invoke p .deposit,.invoke p .withdraw,.supply p false,.supply p true] ++
    (([.alice,.bob,.vault,.pool] : List Account).flatMap fun a =>
      [Asset.cash,.shareA,.shareB].map fun e => Capability.debit p a e)
def observe (s : PublicState) :=
  (cells.map s.ledger.balance,assets.map s.supply,[s.rates false,s.rates true],
    allCapabilities.filter (fun c => decide (c ∈ s.capabilities)),s.history.map observeEvent)

-- Independent receipt formulas used only for finite acceptance observations.
def expectedDelta (rates : Vault → ℚ) (call : Call) (c : Cell) : ℚ :=
  match call with
  | .transfer _ a b e q =>
    -q * (if c = (a,e.native) then 1 else 0) + q * (if c = (b,e.native) then 1 else 0)
  | .deposit _ u v q =>
    -q * (if c = (userAccount u,.usd) then 1 else 0) +
    q * (if c = (vaultAccount v,.usd) then 1 else 0) +
    (q / rates v) * (if c = (userAccount u,(shareAsset v).native) then 1 else 0)
  | .withdraw _ u v q =>
    -q * (if c = (userAccount u,(shareAsset v).native) then 1 else 0) -
    (q * rates v) * (if c = (vaultAccount v,.usd) then 1 else 0) +
    (q * rates v) * (if c = (userAccount u,.usd) then 1 else 0)
  | _ => 0

def expectedEvent (rates : Vault → ℚ) (call : Call) : List Call × List ℚ × List ℚ × List ℚ :=
  ([call],cells.map (expectedDelta rates call),
    assets.map (fun e => match call with
      | .deposit _ _ v q => if e = shareAsset v then q/rates v else 0 | _ => 0),
    assets.map (fun e => match call with
      | .withdraw _ _ v q => if e = shareAsset v then q else 0 | _ => 0))

def expectedBalances (aliceCash bobCash vaultCash aliceShares bobShares : ℚ) : Cell → ℚ
  | (.alice,.usd) => aliceCash | (.bob,.usd) => bobCash | (.vault,.usd) => vaultCash
  | (.alice,.share) => aliceShares | (.bob,.share) => bobShares | _ => 0

def checkResult (state : PublicState) (amounts : List ℚ)
    (aliceCash bobCash vaultCash aliceShares bobShares : ℚ) : Bool :=
  let calls := workflowCalls .vault false amounts
  let result := runCalls state calls
  decide (result.failure = none ∧ result.committed = amounts.length ∧
    cells.map result.state.ledger.balance = cells.map (expectedBalances aliceCash bobCash vaultCash aliceShares bobShares) ∧
    assets.map result.state.supply = [state.supply .cash,aliceShares+bobShares,0] ∧
    result.state.rates = state.rates ∧ result.state.capabilities = state.capabilities ∧
    result.state.history.map observeEvent = state.history.map observeEvent ++ calls.map (expectedEvent state.rates) ∧
    surplus result.state false = surplus state false)

def cycle : List ℚ := [3/2,1,1,3/2]
def independent : List ℚ := [3/2,2/3,1/3,1/4]
def fourCycles := cycle ++ cycle ++ cycle ++ cycle
def fourIndependent := independent ++ independent ++ independent ++ independent

def control : Bool := checkResult (initial 6 (by norm_num)) fourCycles 6 0 0 0 0
#eval do
  IO.println s!"CONTROL broken_frame {control}"
  let result := runCalls (initial 6 (by norm_num)) (workflowCalls .vault false fourCycles)
  IO.println s!"OBSERVE failure={repr result.failure} committed={result.committed} full={repr (observe result.state)}"
  match execute (initial 6 (by norm_num)) (.deposit .vault false false (3/2)) with
  | .success post => IO.println s!"DEPOSIT alice_share={post.ledger.balance (.alice,.share)} supply={post.supply .shareA}"
  | .refused reason _ => IO.println s!"DEPOSIT REFUSED {repr reason}"
end RationalWorkflow.ComposeWitnesses
