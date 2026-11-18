import DefiKernel.Margin.Types
import DefiKernel.Margin.Payment
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise

/-! A reference cost recipient receives computed payments. GMX recipient/handler refinement is separate. -/
namespace DefiKernel.Margin.PaymentSettlement
open DefiKernel.Typed
def payId : OperationId := ⟨0⟩
def guard (input : Payment.Inputs) : E [] .bool :=
  .binary .and
    (.binary (.eq (.amount Asset.primary)) (.balance (ref .primary .output)) (.lit input.primaryOutput))
    (.binary .and
      (.binary (.eq (.amount Asset.primary)) (.balance (ref .primary .position)) (.lit input.collateral))
      (.binary (.eq (.amount Asset.secondary)) (.balance (ref .secondary .output)) (.lit input.secondaryOutput)))
def template (prices : Payment.Prices) (input : Payment.Inputs) : Op :=
  let quote := Payment.payCost prices input
  {signature:=[],domain:=.margin,partyArity:=0,guard:=.lit true,
   deltas:=[⟨.primary,ref .primary .output,.lit (-(quote.paidPrimaryOutput:ℚ))⟩,
     ⟨.primary,ref .primary .position,.lit (-(quote.paidCollateral:ℚ))⟩,
     ⟨.secondary,ref .secondary .output,.lit (-(quote.paidSecondary:ℚ))⟩,
     ⟨.primary,ref .primary .costRecipient,.lit (quote.paidPrimaryOutput+quote.paidCollateral)⟩,
     ⟨.secondary,ref .secondary .costRecipient,.lit quote.paidSecondary⟩],
   supplyDeltas:=[],
   stateReads:=[packedRef .primary .output,packedRef .primary .position,packedRef .secondary .output],
   envReads:=[],writes:=[packedRef .primary .output,packedRef .primary .position,
     packedRef .secondary .output,packedRef .primary .costRecipient,packedRef .secondary .costRecipient]}
private def registry (prices : Payment.Prices) (input : Payment.Inputs) : Registry Party Asset Domain :=
  fun id => if id=payId then some (template prices input) else none
def request (ids : List CapabilityId) : Request Party Asset Domain := ⟨payId,[],[],ids,some .owner⟩
def execute (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) :
    Except Typed.Refusal World :=
  Typed.execute (registry prices input) store ctx (fun _=>none) 0 (request ids) pre
def run (prices : Payment.Prices) (input : Payment.Inputs) (store : Store)
    (ctx : InvocationContext Party Domain) (ids : List CapabilityId) (pre : Ledger) :
    Except Typed.Refusal (World × Payment.Result) := do
  let post ← execute prices input store ctx ids pre
  return (post,Payment.payCost prices input)
def grants : List (Grant Party Asset Domain) := [⟨.owner,.margin,payId,.invoke⟩,
  ⟨.owner,.margin,payId,.debit (.margin,.output,.primary)⟩,
  ⟨.owner,.margin,payId,.debit (.margin,.position,.primary)⟩,
  ⟨.owner,.margin,payId,.debit (.margin,.output,.secondary)⟩]
def provisioned (prices : Payment.Prices) (input : Payment.Inputs) : Except AuthorityFailure Store :=
  grants.foldlM (fun store grant => do
    let (_,next) ← issueCapability (registryAuthorityConfig (registry prices input) (fun _ => .admin))
      ⟨.admin,.margin⟩ store grant
    return next) .empty
def fixtureStore : Store := ⟨grants.map (fun grant=>⟨grant,true⟩)⟩
def ids : List CapabilityId := [⟨0⟩,⟨1⟩,⟨2⟩,⟨3⟩]



end DefiKernel.Margin.PaymentSettlement

namespace DefiKernel.Margin.PaymentSettlementAudit
open DefiKernel.Typed
private def initial (output collateral secondary : Nat) : Ledger where
  balance
    | (.margin,.output,.primary) => output
    | (.margin,.position,.primary) => collateral
    | (.margin,.output,.secondary) => secondary
    | (.margin,.costRecipient,.primary) => 10
    | (.margin,.costRecipient,.secondary) => 20
    | (.margin,.owner,.primary) => 3
    | (.margin,.owner,.secondary) => 4
    | (.margin,.owner,.claimPrimary) => 7
    | (.margin,.owner,.claimSecondary) => 11
    | (.margin,.holding,.claimSecondary) => 5
    | (.margin,.pool,.primary) => 100
    | (.margin,.pool,.secondary) => 200
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def fractional : Ledger where
  balance
    | (.margin,.output,.primary) => 1/2
    | cell => (initial 0 0 0).balance cell
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> norm_num [initial]
private def p12 : Payment.Prices := ⟨1,2,by decide,by decide⟩
private def p11 : Payment.Prices := ⟨1,1,by decide,by decide⟩
private def p32 : Payment.Prices := ⟨3,2,by decide,by decide⟩
private def p34 : Payment.Prices := ⟨3,4,by decide,by decide⟩
private def run (p : Payment.Prices) (i : Payment.Inputs)
    (store : Store := PaymentSettlement.fixtureStore) :=
  PaymentSettlement.run p i store ownerContext PaymentSettlement.ids
    (initial i.primaryOutput i.collateral i.secondaryOutput)
private def resultMatches (actual : Except Typed.Refusal (World × Payment.Result))
    (output collateral secondary recipientPrimary recipientSecondary residual shortfall : ℚ)
    (store : Store := PaymentSettlement.fixtureStore) : Bool :=
  match actual with
  | .error _ => false
  | .ok (post,q) => decide (post.state.balance (.margin,.output,.primary)=output ∧
      post.state.balance (.margin,.position,.primary)=collateral ∧
      post.state.balance (.margin,.output,.secondary)=secondary ∧
      post.state.balance (.margin,.costRecipient,.primary)=recipientPrimary ∧
      post.state.balance (.margin,.costRecipient,.secondary)=recipientSecondary ∧
      (q.sourceRemainingCostUsd:ℚ)=residual ∧ (q.economicShortfallUsd:ℚ)=shortfall ∧
      post.capabilities=store)
private def refusalMatches (actual : Except Typed.Refusal (World × Payment.Result))
    (expected : Typed.Refusal) : Bool :=
  match actual with | .ok _ => false | .error reason => decide (reason=expected)
private def invokeOnly : Store := ⟨PaymentSettlement.fixtureStore.entries.take 1⟩
private def noOutput : Store := ⟨PaymentSettlement.fixtureStore.entries.set 1
  ⟨⟨.owner,.margin,PaymentSettlement.payId,.debit (.margin,.output,.primary)⟩,false⟩⟩
private def noCollateral : Store := ⟨PaymentSettlement.fixtureStore.entries.set 2
  ⟨⟨.owner,.margin,PaymentSettlement.payId,.debit (.margin,.position,.primary)⟩,false⟩⟩
private def noSecondary : Store := ⟨PaymentSettlement.fixtureStore.entries.set 3
  ⟨⟨.owner,.margin,PaymentSettlement.payId,.debit (.margin,.output,.secondary)⟩,false⟩⟩
private def overgrantedPool : Store :=
  ⟨PaymentSettlement.fixtureStore.entries.map (fun cap=>{cap with holder:=.pool})⟩
private def checks : List (String × Bool) := [
  ("real_administrative_provision",decide (PaymentSettlement.provisioned p34 ⟨5,1,1,0⟩=
    .ok PaymentSettlement.fixtureStore)),
  ("actual_bound_bucket_payments",resultMatches (run p34 ⟨5,1,1,0⟩) 0 0 0 12 20 0 0),
  ("actual_positive_secondary_dust_shortfall",resultMatches (run p34 ⟨5,0,0,1⟩) 0 0 0 10 21 0 1),
  ("actual_positive_secondary_fully_paid",resultMatches (run p32 ⟨6,0,0,3⟩) 0 0 0 10 23 0 0),
  ("primary_output_priority",resultMatches (run p34 ⟨5,1,5,2⟩) 0 4 2 12 20 0 0),
  ("partial_cost_retains_positive_source_residual",resultMatches (run p11 ⟨20,0,3,0⟩) 0 0 0 13 20 17 17),
  ("zero_transfers_retain_economic_shortfall",resultMatches (run p12 ⟨1,0,0,0⟩ invokeOnly)
    0 0 0 10 20 0 1 invokeOnly),
  ("zero_cost_invoke_only",resultMatches (run p34 ⟨0,1,1,2⟩ invokeOnly)
    1 1 2 10 20 0 0 invokeOnly),
  ("unused_secondary_right_may_be_absent",resultMatches (run p34 ⟨5,1,1,0⟩ noSecondary)
    0 0 0 12 20 0 0 noSecondary),
  ("wrong_quote_primary_output",refusalMatches (PaymentSettlement.run p34 ⟨5,0,1,0⟩
    PaymentSettlement.fixtureStore ownerContext PaymentSettlement.ids (initial 1 1 0)) .guard),
  ("wrong_quote_position_collateral",refusalMatches (PaymentSettlement.run p34 ⟨5,1,0,0⟩
    PaymentSettlement.fixtureStore ownerContext PaymentSettlement.ids (initial 1 1 0)) .guard),
  ("wrong_quote_secondary_even_when_unused",refusalMatches (PaymentSettlement.run p34 ⟨5,1,1,1⟩
    PaymentSettlement.fixtureStore ownerContext PaymentSettlement.ids (initial 1 1 0)) .guard),
  ("zero_quote_cannot_ignore_actual_funds",refusalMatches (PaymentSettlement.run p12 ⟨1,0,0,0⟩
    PaymentSettlement.fixtureStore ownerContext PaymentSettlement.ids (initial 1 1 0)) .guard),
  ("fractional_bucket_not_raw_integer",refusalMatches (PaymentSettlement.run p12 ⟨1,0,0,0⟩
    PaymentSettlement.fixtureStore ownerContext PaymentSettlement.ids fractional) .guard),
  ("invoke_before_binding_guard",refusalMatches (PaymentSettlement.run p34 ⟨5,0,0,0⟩
    ⟨[]⟩ ownerContext PaymentSettlement.ids (initial 1 1 0)) .unauthorizedInvoke),
  ("actor_binding_before_guard",refusalMatches (PaymentSettlement.run p34 ⟨5,0,0,0⟩
    overgrantedPool ⟨.pool,.margin⟩ PaymentSettlement.ids (initial 1 1 0)) .actorMismatch),
  ("actual_primary_output_debit_authority",refusalMatches (run p34 ⟨5,1,1,0⟩ noOutput) .unauthorizedDebit),
  ("actual_position_debit_authority",refusalMatches (run p34 ⟨5,1,1,0⟩ noCollateral) .unauthorizedDebit),
  ("actual_secondary_debit_authority",refusalMatches (run p32 ⟨6,0,0,3⟩ noSecondary) .unauthorizedDebit),
  ("claim_counters_are_not_spendable_buckets",resultMatches (run p34 ⟨5,0,0,0⟩) 0 0 0 10 20 4 5),
  ("physical_and_claim_totals_conserved",match run p34 ⟨5,1,1,0⟩ with
    | .error _ => false
    | .ok (post,_) => decide (total post.state .margin .primary=115 ∧
        total post.state .margin .secondary=224 ∧ total post.state .margin .claimPrimary=7 ∧
        total post.state .margin .claimSecondary=16)),
  ("unrelated_pool_owner_and_claims_frame",match run p34 ⟨5,1,1,0⟩ with
    | .error _ => false
    | .ok (post,_) => decide (post.state.balance (.margin,.pool,.primary)=100 ∧
        post.state.balance (.margin,.pool,.secondary)=200 ∧ post.state.balance (.margin,.owner,.primary)=3 ∧
        post.state.balance (.margin,.owner,.secondary)=4 ∧ post.state.balance (.margin,.owner,.claimPrimary)=7 ∧
        post.state.balance (.margin,.owner,.claimSecondary)=11 ∧ post.state.balance (.margin,.holding,.claimSecondary)=5))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty margin settlement controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate margin settlement controls")
  match run p34 ⟨5,1,1,0⟩ with
  | .error reason => IO.println s!"MARGIN_SETTLEMENT_OBSERVATION refused {repr reason}"
  | .ok (post,q) => IO.println s!"MARGIN_SETTLEMENT_OBSERVATION {post.state.balance (.margin,.output,.primary)} {post.state.balance (.margin,.position,.primary)} {post.state.balance (.margin,.output,.secondary)} {post.state.balance (.margin,.costRecipient,.primary)} {post.state.balance (.margin,.costRecipient,.secondary)} {q.sourceRemainingCostUsd} {q.economicShortfallUsd} {post.state.balance (.margin,.pool,.primary)}"
  match PaymentSettlement.run p12 ⟨1,0,0,0⟩ PaymentSettlement.fixtureStore ownerContext PaymentSettlement.ids (initial 1 1 0) with
  | .error reason => IO.println s!"MARGIN_SETTLEMENT_BINDING_OBSERVATION refused {repr reason}"
  | .ok (post,q) => IO.println s!"MARGIN_SETTLEMENT_BINDING_OBSERVATION {post.state.balance (.margin,.output,.primary)} {post.state.balance (.margin,.position,.primary)} {post.state.balance (.margin,.costRecipient,.primary)} {q.sourceRemainingCostUsd} {q.economicShortfallUsd}"
  for (name,passed) in checks do IO.println s!"MARGIN_SETTLEMENT_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual margin settlement comparison")
  IO.println s!"MARGIN_SETTLEMENT_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Margin.PaymentSettlementAudit