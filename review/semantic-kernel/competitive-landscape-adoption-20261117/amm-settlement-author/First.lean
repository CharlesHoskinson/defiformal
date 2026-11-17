import DefiKernel.AMM.Settlement
open DefiKernel.AMM.Settlement
private def pre : S where
  balance | (.pool, .trader, .x) => 5
          | (.pool, .pool, .x) => 10
          | (.pool, .trader, .y) => 0
          | (.pool, .pool, .y) => 20
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> norm_num
private def positive : Bool := match run 2 (1/2) fullStore pre with
  | .error _ => false
  | .ok post => decide (post.state.balance (.pool,.trader,.x)=3 ∧
      post.state.balance (.pool,.pool,.x)=12 ∧
      post.state.balance (.pool,.trader,.y)=20/11 ∧
      post.state.balance (.pool,.pool,.y)=200/11 ∧ post.capabilities=fullStore)
#eval do
  IO.println s!"SETTLEMENT_FIRST {positive}"
  if !positive then throw (IO.userError "FAIL: actual funded settlement")
