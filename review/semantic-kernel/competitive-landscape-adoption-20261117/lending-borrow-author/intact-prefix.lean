import DefiKernel.Lending.Oracle
import DefiKernel.Lending.Support
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.Ring

namespace DefiKernel.Lending.Borrow
open DefiKernel.Typed
def signature : List (Unit Asset) := [.amount .cash]
def amount : E signature (.amount Asset.cash) := .arg .here
def debtMint : E signature (.amount Asset.debt) :=
  .binary (.unconvert Asset.debt Asset.cash) amount (.lit 1)
def guard (borrower : Borrower) : E signature .bool := Oracle.allGuards [
  .binary (.le (.amount Asset.cash)) (.lit 0) amount,
  .binary (.lt (.price Asset.collateral Asset.cash)) (.lit 0) Oracle.price,
  .binary (.le .scalar) (.timestamp Oracle.key) .now,
  .binary (.le .scalar) .now (.binary (.add .scalar) (.timestamp Oracle.key) (.lit Oracle.maxAge)),
  .binary (.le (.amount Asset.cash))
    (.binary (.scale (.amount Asset.cash)) (.lit 2)
      (.binary (.add (.amount Asset.cash)) (Oracle.debtCash borrower) amount))
    (Oracle.lockedCash borrower)]
def template (borrower : Borrower) : Op where
  signature := signature
  domain := .lending
  partyArity := 0
  guard := guard borrower
  deltas := [⟨.cash,ref .cash .pool,.unary (.neg (.amount Asset.cash)) amount⟩,
    ⟨.cash,ref .cash borrower.party,amount⟩,⟨.debt,ref .debt borrower.party,debtMint⟩]
  supplyDeltas := [⟨.lending,.debt,debtMint⟩]
  stateReads := [packedRef .debt borrower.party,packedRef .collateral borrower.custody]
  envReads := [.observation Oracle.key,.currentTime]
  writes := [packedRef .cash .pool,packedRef .cash borrower.party,packedRef .debt borrower.party]
private def registry (borrower : Borrower) : Registry Party Asset Domain :=
  fun op => if op = borrowId then some (template borrower) else none
def request (borrower : Borrower) (ids : List CapabilityId) (quantity : ℚ) : Request Party Asset Domain :=
  ⟨borrowId,[],[⟨.amount .cash,quantity⟩],ids,some borrower.party⟩
def run (borrower : Borrower) (store : Store) (ctx : InvocationContext Party Domain)
    (ids : List CapabilityId) (quantity : ℚ) (env : Environment Asset Domain) (now : Nat)
    (pre : Ledger) : Except Typed.Refusal World :=
  Typed.execute (registry borrower) store ctx env now (request borrower ids quantity) pre
def grants (borrower : Borrower) : List (Grant Party Asset Domain) := [
  ⟨borrower.party,.lending,borrowId,.invoke⟩,
  ⟨borrower.party,.lending,borrowId,.debit (.lending,.pool,.cash)⟩,
  ⟨borrower.party,.lending,borrowId,.changeSupply .lending .debt⟩]
def provisioned (borrower : Borrower) : Except AuthorityFailure Store :=
  Support.provision (registry borrower) (grants borrower)
def fixtureStore (borrower : Borrower) : Store := ⟨(grants borrower).map (fun grant => ⟨grant,true⟩)⟩
def ids : List CapabilityId := [⟨0⟩,⟨1⟩,⟨2⟩]

end DefiKernel.Lending.Borrow

namespace DefiKernel.Lending.BorrowAudit
open DefiKernel.Typed
private def initial (pool free locked debt : Nat) : Ledger where
  balance
    | (.lending,.alice,.cash) => 3
    | (.lending,.pool,.cash) => pool
    | (.lending,.alice,.debt) => debt
    | (.lending,.alice,.collateral) => free
    | (.lending,.aliceLocked,.collateral) => locked
    | (.lending,.bob,.cash) => 4
    | (.lending,.bob,.debt) => 7
    | (.lending,.bob,.collateral) => 1
    | (.lending,.bobLocked,.collateral) => 20
    | _ => 0
  nonneg := by intro ⟨d,p,a⟩;cases d;cases p <;> cases a <;> simp
private def run (quantity : ℚ) (pre : Ledger := initial 10 5 10 2)
    (env : Environment Asset Domain := Oracle.feed 2 98) (now : Nat := 100)
    (store : Store := Borrow.fixtureStore .alice) : Except Typed.Refusal World :=
  Borrow.run .alice store (borrowerContext .alice) Borrow.ids quantity env now pre
private def resultMatches (borrower : Borrower) (actual : Except Typed.Refusal World)
    (cash pool debt : ℚ) (store : Store := Borrow.fixtureStore .alice) : Bool :=
  match actual with
  | .error _ => false
  | .ok post => decide (post.state.balance (.lending,borrower.party,.cash)=cash ∧
      post.state.balance (.lending,.pool,.cash)=pool ∧
      post.state.balance (.lending,borrower.party,.debt)=debt ∧ post.capabilities=store)
private def refusalMatches (actual : Except Typed.Refusal World) (expected : Typed.Refusal) : Bool :=
  match actual with
  | .ok _ => false
  | .error reason => decide (reason=expected)
private def invokeOnly : Store := ⟨(Borrow.fixtureStore .alice).entries.take 1⟩
private def noPoolDebit : Store := ⟨(Borrow.fixtureStore .alice).entries.set 1
  ⟨⟨.alice,.lending,borrowId,.debit (.lending,.pool,.cash)⟩,false⟩⟩
private def noDebtSupply : Store := ⟨(Borrow.fixtureStore .alice).entries.set 2
  ⟨⟨.alice,.lending,borrowId,.changeSupply .lending .debt⟩,false⟩⟩
private def overgrantedBob : Store :=
  ⟨(Borrow.fixtureStore .alice).entries.map (fun cap => {cap with holder:=.bob})⟩
private def wrongUnit : Environment Asset Domain := fun key =>
  if key=Oracle.key then some ⟨⟨.scalar,2⟩,98⟩ else none
private def wrongFeed : Environment Asset Domain := fun key =>
  if key=⟨.lending,⟨8⟩⟩ then some ⟨⟨.price .collateral .cash,2⟩,98⟩ else none
private def checks : List (String × Bool) := [
  ("real_provisioning_alice",decide (Borrow.provisioned .alice=.ok (Borrow.fixtureStore .alice))),
  ("real_provisioning_bob",decide (Borrow.provisioned .bob=.ok (Borrow.fixtureStore .bob))),
  ("actual_cash_debt_movement",resultMatches .alice (run 3) 6 7 5),
  ("fractional_borrow",resultMatches .alice (run (1/2)) (7/2) (19/2) (5/2)),
  ("bob_owned_position",resultMatches .bob
    (Borrow.run .bob (Borrow.fixtureStore .bob) (borrowerContext .bob) Borrow.ids 2
      (Oracle.feed 2 98) 100 (initial 10 5 10 2)) 6 8 9 (Borrow.fixtureStore .bob)),
  ("free_and_locked_collateral_unchanged",match run 3 with
    | .error _ => false
    | .ok post => decide (post.state.balance (.lending,.alice,.collateral)=5 ∧
        post.state.balance (.lending,.aliceLocked,.collateral)=10 ∧
        post.state.balance (.lending,.bob,.collateral)=1 ∧ post.state.balance (.lending,.bobLocked,.collateral)=20)),
  ("free_collateral_does_not_back_debt",refusalMatches (run 1 (initial 10 100 0 2)) .guard),
  ("post_debt_includes_requested_increase",refusalMatches (run 2 (initial 10 5 3 2)) .guard),
  ("zero_amount_invoke_only",resultMatches .alice
    (run 0 (initial 0 0 0 0) (Oracle.feed 2 98) 100 invokeOnly) 3 0 0 invokeOnly),
  ("zero_exposure_still_requires_positive_price",refusalMatches
    (run 0 (initial 0 0 0 0) (Oracle.feed 0 98)) .guard),
  ("negative_price",refusalMatches (run 0 (initial 0 0 0 0) (Oracle.feed (-2) 98)) .guard),
  ("negative_amount",refusalMatches (run (-1)) .guard),
  ("missing_oracle",refusalMatches (run 1 (initial 10 5 10 2) (fun _ => none)) (.evaluation .missingObservation)),
  ("missing_oracle_eager_negative_amount",refusalMatches
    (run (-1) (initial 10 5 10 2) (fun _ => none)) (.evaluation .missingObservation)),
  ("wrong_oracle_unit",refusalMatches (run 1 (initial 10 5 10 2) wrongUnit) (.evaluation .observationUnit)),
  ("wrong_feed_key",refusalMatches (run 1 (initial 10 5 10 2) wrongFeed) (.evaluation .missingObservation)),
  ("future_timestamp",refusalMatches (run 1 (initial 10 5 10 2) (Oracle.feed 2 101)) .guard),
  ("stale_timestamp",refusalMatches (run 1 (initial 10 5 10 2) (Oracle.feed 2 94)) .guard),
  ("oldest_fresh_boundary",resultMatches .alice (run 1 (initial 10 5 10 2) (Oracle.feed 2 95)) 4 9 3),
  ("pool_funding_after_health",refusalMatches (run 11 (initial 10 5 100 2)) .insufficientFunds),
  ("invoke_before_oracle_evaluation",refusalMatches
    (run 1 (initial 10 5 10 2) (fun _ => none) 100 ⟨[]⟩) .unauthorizedInvoke),
  ("pool_debit_authority",refusalMatches (run 1 (initial 10 5 10 2) (Oracle.feed 2 98) 100 noPoolDebit) .unauthorizedDebit),
  ("debt_supply_authority",refusalMatches (run 1 (initial 10 5 10 2) (Oracle.feed 2 98) 100 noDebtSupply) .unauthorizedSupply),
  ("owner_binding_before_oracle_evaluation",refusalMatches
    (Borrow.run .alice overgrantedBob (borrowerContext .bob) Borrow.ids 1 (fun _ => none) 100
      (initial 10 5 10 2)) .actorMismatch),
  ("cash_collateral_conservation_debt_issuance",match run 3 with
    | .error _ => false
    | .ok post => decide (total post.state .lending .cash=17 ∧
        total post.state .lending .collateral=36 ∧ total post.state .lending .debt=12))]
#eval do
  if checks.isEmpty then throw (IO.userError "BLOCKED: empty borrow controls")
  if !decide (checks.map Prod.fst).Nodup then throw (IO.userError "BLOCKED: duplicate borrow controls")
  match run 3 with
  | .error reason => IO.println s!"BORROW_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"BORROW_OBSERVATION {post.state.balance (.lending,.alice,.cash)} {post.state.balance (.lending,.pool,.cash)} {post.state.balance (.lending,.alice,.debt)}"
  match run 2 (initial 10 5 3 2) with
  | .error reason => IO.println s!"BORROW_HEALTH_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"BORROW_HEALTH_OBSERVATION {post.state.balance (.lending,.alice,.cash)} {post.state.balance (.lending,.pool,.cash)} {post.state.balance (.lending,.alice,.debt)} {post.state.balance (.lending,.aliceLocked,.collateral)}"
  match run 1 (initial 10 100 0 2) with
  | .error reason => IO.println s!"BORROW_FREE_OBSERVATION refused {repr reason}"
  | .ok post => IO.println s!"BORROW_FREE_OBSERVATION {post.state.balance (.lending,.alice,.cash)} {post.state.balance (.lending,.pool,.cash)} {post.state.balance (.lending,.alice,.debt)} {post.state.balance (.lending,.aliceLocked,.collateral)}"
  for (name,passed) in checks do IO.println s!"BORROW_CONTROL {name} {passed}"
  if !checks.all Prod.snd then throw (IO.userError "FAIL: actual borrow comparison")
  IO.println s!"BORROW_CONTROL PASSED {checks.length}/{checks.length}"
end DefiKernel.Lending.BorrowAudit