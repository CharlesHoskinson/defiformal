import DefiKernel.AMM.WordSettlement
open DefiKernel.AMM
open DefiKernel.Arithmetic DefiKernel.AMM.Settlement DefiKernel.AMM.WordSettlement
private def word (n : Nat) (bound : n < 2^256 := by decide) : Word 256 := ⟨n,bound⟩
private def pre : S where
  balance | (.pool, .trader, .x) => 5
          | (.pool, .pool, .x) => 10
          | (.pool, .trader, .y) => 0
          | (.pool, .pool, .y) => 20
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> norm_num
private def noPoolDebit : Store := ⟨fullStore.entries.take 2⟩
private def zeroOutputSettles : Bool :=
  match WordSettlement.run ⟨word 10, word 20⟩ (word 1) ⟨word 1,word 2⟩ noPoolDebit pre with
  | .error _ => false
  | .ok post => decide (post.state.balance (.pool,.trader,.x)=4 ∧
      post.state.balance (.pool,.pool,.x)=11 ∧
      post.state.balance (.pool,.trader,.y)=0 ∧
      post.state.balance (.pool,.pool,.y)=20 ∧ post.capabilities=noPoolDebit)
private def mismatchRefuses : Bool :=
  match WordSettlement.run ⟨word 11,word 20⟩ (word 1) ⟨word 1,word 2⟩ fullStore pre with
  | .ok _ => false
  | .error reason => decide (reason = DefiKernel.AMM.WordSettlement.Refusal.reserveMismatch)
#eval do
  IO.println s!"WORD_SETTLEMENT_FIRST {zeroOutputSettles} {mismatchRefuses}"
  if !(zeroOutputSettles && mismatchRefuses) then throw (IO.userError "FAIL: actual Word settlement")
