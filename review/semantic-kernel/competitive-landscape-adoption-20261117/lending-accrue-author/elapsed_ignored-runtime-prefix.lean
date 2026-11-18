import DefiKernel.Lending.Support
import Mathlib.Tactic.Ring

/-! Unindexed per-call simple interest on current debt. Repeated intervals accrue again. -/
namespace DefiKernel.Lending.Accrue
open DefiKernel.Typed
def signature : List (Unit Asset) := [.scalar,.scalar]
def rate : E signature .scalar := .arg .here
def elapsed : E signature .scalar := .arg (.there .here)
def rateTime : E signature .scalar := rate
def increment (borrower : Borrower) : E signature (.amount Asset.debt) :=
  .binary (.scale (.amount Asset.debt)) rateTime (.balance (ref .debt borrower.party))
def template (borrower : Borrower) : Op where
  signature := signature
  domain := .lending
  partyArity := 0
  guard := .binary .and (.binary (.le .scalar) (.lit 0) rate)
    (.binary (.le .scalar) (.lit 0) elapsed)
  deltas := [⟨.debt,ref .debt borrower.party,increment borrower⟩]
  supplyDeltas := [⟨.lending,.debt,increment borrower⟩]
  stateReads := [packedRef .debt borrower.party]
  envReads := []
  writes := [packedRef .debt borrower.party]
private def registry (borrower : Borrower) : Registry Party Asset Domain :=
  fun op => if op = accrueId then some (template borrower) else none
def request (borrower : Borrower) (ids : List CapabilityId) (rate elapsed : ℚ) : Request Party Asset Domain :=
  ⟨accrueId,[],[⟨.scalar,rate⟩,⟨.scalar,elapsed⟩],ids,some borrower.party⟩
def run (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (rate elapsed : ℚ) (pre : Ledger) : Except Typed.Refusal World :=
  Typed.execute (registry borrower) store ctx (fun _ => none) 0 (request borrower ids rate elapsed) pre
def grants (borrower : Borrower) : List (Grant Party Asset Domain) := [
  ⟨borrower.party,.lending,accrueId,.invoke⟩,
  ⟨borrower.party,.lending,accrueId,.changeSupply .lending .debt⟩]
def provisioned (borrower : Borrower) : Except AuthorityFailure Store :=
  Support.provision (registry borrower) (grants borrower)
def fixtureStore (borrower : Borrower) : Store := ⟨(grants borrower).map (fun grant => ⟨grant,true⟩)⟩
def ids : List CapabilityId := [⟨0⟩,⟨1⟩]



end DefiKernel.Lending.Accrue

namespace DefiKernel.Lending.AccrueAudit
open DefiKernel.Typed
private def initial (debt : Nat := 2) : Ledger where
  balance
    | (.lending,.alice,.cash) => 3
    | (.lending,.pool,.cash) => 10
    | (.lending,.alice,.debt) => debt
    | (.lending,.alice,.collateral) => 5
    | (.lending,.aliceLocked,.collateral) => 2
    | (.lending,.bob,.cash) => 4
    | (.lending,.bob,.debt) => 7
    | (.lending,.bob,.collateral) => 1
    | (.lending,.bobLocked,.collateral) => 20
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩; cases d; cases p <;> cases a <;> simp
private def run (rate elapsed : ℚ) (pre : Ledger := initial)
    (store : Store := Accrue.fixtureStore .alice) : Except Typed.Refusal World :=
  Accrue.run .alice store (borrowerContext .alice) Accrue.ids rate elapsed pre
private def resultMatches (borrower : Borrower) (actual : Except Typed.Refusal World)
    (debt : ℚ) (store : Store := Accrue.fixtureStore .alice) : Bool :=
  match actual with
  | .error _ => false
  | .ok post => decide (post.state.balance (.lending,borrower.party,.debt)=debt ∧
      post.capabilities=store)
private def refusalMatches (actual : Except Typed.Refusal World) (expected : Typed.Refusal) : Bool :=
  match actual with
  | .ok _ => false
  | .error reason => decide (reason=expected)
private def invokeOnly : Store := ⟨(Accrue.fixtureStore .alice).entries.take 1⟩
private def noSupply : Store := ⟨(Accrue.fixtureStore .alice).entries.set 1
  ⟨⟨.alice,.lending,accrueId,.changeSupply .lending .debt⟩,false⟩⟩
private def overgrantedBob : Store :=
  ⟨(Accrue.fixtureStore .alice).entries.map (fun cap => {cap with holder:=.bob})⟩
private def checks : List (String × Bool) := [
  ("real_provisioning_alice",decide (Accrue.provisioned .alice=.ok (Accrue.fixtureStore .alice))),
  ("real_provisioning_bob",decide (Accrue.provisioned .bob=.ok (Accrue.fixtureStore .bob))),
  ("actual_debt_increment",resultMatches .alice (run 1 1) 4),
  ("fractional_rate_and_interval",resultMatches .alice (run (1/4) (1/2)) (9/4)),
  ("bob_owned_debt",resultMatches .bob
    (Accrue.run .bob (Accrue.fixtureStore .bob) (borrowerContext .bob) Accrue.ids 1 1 initial)
      14 (Accrue.fixtureStore .bob)),
  ("cash_and_all_collateral_frame",match run 1 1 with
    | .error _ => false
    | .ok post => decide (post.state.balance (.lending,.alice,.cash)=3 ∧
        post.state.balance (.lending,.pool,.cash)=10 ∧ post.state.balance (.lending,.bob,.cash)=4 ∧
        post.state.balance (.lending,.alice,.collateral)=5 ∧
        post.state.balance (.lending,.aliceLocked,.collateral)=2 ∧
        post.state.balance (.lending,.bob,.collateral)=1 ∧
        post.state.balance (.lending,.bobLocked,.collateral)=20 ∧
        post.state.balance (.lending,.bob,.debt)=7)),
  ("healthy_becomes_unhealthy_successfully",match run 1 1 with
    | .error _ => false
    | .ok post => decide (2*(initial.balance (.lending,.alice,.debt)) ≤
        initial.balance (.lending,.aliceLocked,.collateral)*2 ∧
        post.state.balance (.lending,.aliceLocked,.collateral)*2 <
          2*post.state.balance (.lending,.alice,.debt))),
  ("already_unhealthy_accrues_without_oracle",resultMatches .alice (run 1 1 (initial 10)) 20),
  ("same_interval_compounds_again",match run 1 1 with
    | .error _ => false
    | .ok post => resultMatches .alice
        (Accrue.run .alice post.capabilities (borrowerContext .alice) Accrue.ids 1 1 post.state) 8),
  ("single_combined_interval_is_different",resultMatches .alice (run 1 2) 6),
  ("zero_rate_invoke_only",resultMatches .alice (run 0 1 initial invokeOnly) 2 invokeOnly),
  ("zero_interval_invoke_only",resultMatches .alice (run 1 0 initial invokeOnly) 2 invokeOnly),
  ("zero_debt_invoke_only",resultMatches .alice (run 1 1 (initial 0) invokeOnly) 0 invokeOnly),
  ("negative_rate",refusalMatches (run (-1) 1) .guard),
  ("negative_interval",refusalMatches (run 1 (-1)) .guard),
  ("two_negatives_still_refuse",refusalMatches (run (-1) (-1)) .guard),
  ("negative_parameter_zero_increment_still_refuses",refusalMatches (run (-1) 0) .guard),
  ("invoke_before_guard",refusalMatches (run (-1) 1 initial ⟨[]⟩) .unauthorizedInvoke),
  ("positive_increment_requires_supply_right",refusalMatches (run 1 1 initial noSupply) .unauthorizedSupply),
  ("owner_binding_before_guard",refusalMatches
    (Accrue.run .alice overgrantedBob (borrowerContext .bob) Accrue.ids (-1) 1 initial) .actorMismatch),
  ("cash_collateral_conservation_debt_supply_increase",match run 1 1 with
    | .error _ => false
    | .ok post => decide (total post.state .lending .cash=17 ∧
        total post.state .lending .collateral=28 ∧ total post.state .lending .debt=11))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty accrue controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate accrue controls")
  match run 1 1 with
  | .error reason => IO.println s!"ACCRUE_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"ACCRUE_OBSERVATION {post.state.balance (.lending,.alice,.cash)} {post.state.balance (.lending,.pool,.cash)} {post.state.balance (.lending,.alice,.debt)} {post.state.balance (.lending,.aliceLocked,.collateral)}"
  match run (1/4) (1/2) with
  | .error reason => IO.println s!"ACCRUE_FRACTIONAL_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"ACCRUE_FRACTIONAL_OBSERVATION {post.state.balance (.lending,.alice,.debt)}"
  match run (-1) (-1) with
  | .error reason => IO.println s!"ACCRUE_NEGATIVE_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"ACCRUE_NEGATIVE_OBSERVATION {post.state.balance (.lending,.alice,.debt)}"
  for (name,passed) in checks do IO.println s!"ACCRUE_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual accrue comparison")
  IO.println s!"ACCRUE_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Lending.AccrueAudit