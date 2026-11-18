import DefiKernel.Margin.PaymentSettlement
open DefiKernel DefiKernel.Typed DefiKernel.Margin
private def initial : Ledger where
  balance
    | (.margin,.output,.primary) => 1
    | (.margin,.position,.primary) => 1
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> decide
private def zero : Ledger := ⟨fun _=>0,by intro; decide⟩
private def prices : Payment.Prices := ⟨3,4,by decide,by decide⟩
private def input : Payment.Inputs := ⟨5,1,1,0⟩
private def run := PaymentSettlement.run prices input PaymentSettlement.fixtureStore ownerContext
  PaymentSettlement.ids initial
private def checks : List (String × Bool) := [
  ("actual_administrative_provision",decide (PaymentSettlement.provisioned prices input=
    .ok PaymentSettlement.fixtureStore)),
  ("actual_bound_three_bucket_payment",match run with
    | .error _ => false
    | .ok (post,quote) => decide (post.state.balance (.margin,.output,.primary)=0 ∧
        post.state.balance (.margin,.position,.primary)=0 ∧
        post.state.balance (.margin,.costRecipient,.primary)=2 ∧
        quote.ceilDustUsd=1 ∧ quote.economicShortfallUsd=0)),
  ("wrong_quote_buckets_refuse_guard",match PaymentSettlement.run prices ⟨5,0,0,0⟩
      PaymentSettlement.fixtureStore ownerContext PaymentSettlement.ids initial with
    | .ok _ => false | .error reason => decide (reason=Typed.Refusal.guard)),
  ("zero_transfers_preserve_positive_economic_shortfall",match PaymentSettlement.run
      ⟨1,2,by decide,by decide⟩ ⟨1,0,0,0⟩ ⟨PaymentSettlement.fixtureStore.entries.take 1⟩
      ownerContext [⟨0⟩] zero with
    | .error _ => false
    | .ok (post,quote) => decide (quote.sourceRemainingCostUsd=0 ∧ quote.economicShortfallUsd=1 ∧
        post.state.balance (.margin,.costRecipient,.primary)=0 ∧
        post.state.balance (.margin,.costRecipient,.secondary)=0))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty settlement controls")
  for (name,passed) in checks do IO.println s!"MARGIN_SETTLEMENT_FIRST {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual first settlement comparison")
