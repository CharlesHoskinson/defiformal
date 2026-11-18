import ReuseModel
import ComposeWitnesses
namespace RationalWorkflow.ReuseWitnesses
open ComposeWitnesses

def entry : PublicState :=
  { initial 4 (by norm_num) with rates := fun v => if v then 7/5 else 3/2 }
def amounts : List ℚ := [7/5,2/3,1/3,1/5]
def expected : Cell → ℚ
  | (.alice,.usd) => 14/5 | (.bob,.usd) => 4/15 | (.pool,.usd) => 14/15
  | (.alice,.collateral) => 1/3 | (.bob,.collateral) => 1/3 | _ => 0

def result := runCalls entry (workflowCalls .vault true amounts)
def reuseCheck : Bool :=
  decide (result.failure = none ∧ result.committed = 4 ∧
    cells.map result.state.ledger.balance = cells.map expected ∧
    assets.map result.state.supply = [4,0,2/3] ∧
    result.state.rates false = 3/2 ∧ result.state.rates true = 7/5 ∧
    result.state.capabilities = entry.capabilities ∧
    result.state.history.map observeEvent = (workflowCalls .vault true amounts).map (expectedEvent entry.rates) ∧
    surplus result.state true = surplus entry true)

def depositResult := execute entry (.deposit .vault false true (7/5))
def expectedDeposit : Cell → ℚ
  | (.alice,.usd) => 13/5 | (.pool,.usd) => 7/5 | (.alice,.collateral) => 1 | _ => 0

def distinctRateCheck : Bool :=
  match depositResult with
  | .refused _ _ => false
  | .success post => decide (
      cells.map post.ledger.balance = cells.map expectedDeposit ∧
      assets.map post.supply = [4,0,1] ∧ post.rates false = 3/2 ∧ post.rates true = 7/5 ∧
      post.capabilities = entry.capabilities ∧
      post.history.map observeEvent = [expectedEvent entry.rates (.deposit .vault false true (7/5))])

def main : IO Unit := do
  for (name,passed) in [("reuse_vault_b",reuseCheck),("reuse_rate_distinct",distinctRateCheck)] do
    if passed then IO.println s!"WITNESS {name} passed"
    else throw (IO.userError s!"WITNESS {name} FAILED")
  IO.println s!"OBSERVE reuse_vault_b failure={repr result.failure} committed={result.committed} full={repr (observe result.state)}"
  match depositResult with
  | .refused reason state => IO.println s!"OBSERVE reuse_rate_distinct refusal={repr reason} full={repr (observe state)}"
  | .success state => IO.println s!"OBSERVE reuse_rate_distinct full={repr (observe state)}"

#eval main
end RationalWorkflow.ReuseWitnesses
