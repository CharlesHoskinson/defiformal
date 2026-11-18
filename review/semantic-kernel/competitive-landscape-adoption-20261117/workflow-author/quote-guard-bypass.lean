import DefiKernel.Composition.ShareQuote
import DefiKernel.Composition.Preservation

/-! Fixed raw-unit deposit, then a hypothetical quote of its minted sUSDS.
The synthetic quote register is neither pool storage nor cash settlement. -/
namespace DefiKernel.Composition.VaultQuoteWorkflow
open Typed
abbrev Party := Vault.Addr
abbrev Domain := Vault.Domain
inductive Asset | usds | susds | quoteSqrtP
  deriving DecidableEq, Repr
instance : Fintype Asset := ⟨{.usds, .susds, .quoteSqrtP}, by intro a; cases a <;> simp⟩
abbrev C := Cell Party Asset Domain
abbrev W := World Party Asset Domain
abbrev S := Step Party Asset Domain

def senderUsds : C := (.vault, .S, .usds)
def vaultUsds : C := (.vault, .vault, .usds)
def mintedShares : C := (.vault, .R, .susds)
def quoteCell : C := (.vault, .R, .quoteSqrtP)
def depositId : OperationId := ⟨0⟩
def quoteId : OperationId := ⟨1⟩
def preQ : ℚ := ConcentratedLiquidity.Token0Bridge.preQ
def postQ : ℚ := ConcentratedLiquidity.Token0Bridge.postQ

/-- Concrete specialization of the accepted deposit at assets=shares=one raw unit. -/
def depositTemplate : Template Party Asset Domain where
  signature := []
  domain := .vault
  partyArity := 0
  guard := .lit true
  deltas := [⟨.usds, ⟨.vault, .literal .S⟩, .lit (-1)⟩,
    ⟨.usds, ⟨.vault, .literal .vault⟩, .lit 1⟩,
    ⟨.susds, ⟨.vault, .literal .R⟩, .lit 1⟩]
  supplyDeltas := [⟨.vault, .usds, .lit 0⟩, ⟨.vault, .susds, .lit 1⟩]
  stateReads := []
  envReads := []
  writes := [⟨.usds, ⟨.vault, .literal .S⟩⟩,
    ⟨.usds, ⟨.vault, .literal .vault⟩⟩, ⟨.susds, ⟨.vault, .literal .R⟩⟩]

/-- Accept the raw Word used by the native share-to-token0 theorem.
The quote spends no shares; it writes only the synthetic quote register. -/
def quoteTemplate : Template Party Asset Domain where
  signature := [.amount .susds]
  domain := .vault
  partyArity := 0
  guard := .lit true
  deltas := [⟨.quoteSqrtP, ⟨.vault, .literal .R⟩, .lit (postQ - preQ)⟩]
  supplyDeltas := [⟨.vault, .quoteSqrtP, .lit (postQ - preQ)⟩]
  stateReads := []
  envReads := []
  writes := [⟨.quoteSqrtP, ⟨.vault, .literal .R⟩⟩]

def registry : Registry Party Asset Domain := fun id =>
  if id = depositId then some depositTemplate else if id = quoteId then some quoteTemplate else none

def depositInterface : OperationInterface Party Asset Domain :=
  ⟨depositId, [], [⟨⟨0⟩, mintedShares⟩]⟩
def quoteInterface : OperationInterface Party Asset Domain :=
  ⟨quoteId, [⟨⟨0⟩, .amount .susds⟩], [⟨⟨1⟩, quoteCell⟩]⟩
def catalog : Catalog Party Asset Domain := [
  ⟨⟨0⟩, [senderUsds, vaultUsds, mintedShares], [], [], [depositInterface]⟩,
  ⟨⟨1⟩, [quoteCell], [], [], [quoteInterface]⟩]
def cfg : Config Party Asset Domain := ⟨registry, fun _ => .vault, catalog⟩
def boundary (index : Nat) : Boundary Party Asset Domain :=
  ⟨⟨if index = 0 then .S else .R, .vault⟩, fun _ => none, 0⟩
def store : CapabilityStore Party Asset Domain := ⟨[
  ⟨⟨.S, .vault, depositId, .invoke⟩, true⟩,
  ⟨⟨.S, .vault, depositId, .debit senderUsds⟩, true⟩,
  ⟨⟨.S, .vault, depositId, .changeSupply .vault .susds⟩, true⟩,
  ⟨⟨.R, .vault, quoteId, .invoke⟩, true⟩,
  ⟨⟨.R, .vault, quoteId, .debit quoteCell⟩, true⟩,
  ⟨⟨.R, .vault, quoteId, .changeSupply .vault .quoteSqrtP⟩, true⟩]⟩

def initialState (funding : ℚ) (h : 0 ≤ funding) : State Party Asset Domain where
  balance c := if c = senderUsds then funding else if c = quoteCell then preQ else 0
  nonneg c := by
    split
    · exact h
    · split
      · exact ConcentratedLiquidity.Token0Bridge.preQ_nonneg
      · exact le_refl 0

def initialWorld : W := ⟨initialState 1 (by decide), store⟩
def unfundedWorld : W := ⟨initialState 0 (by decide), store⟩
def depositStep : S := .invoke ⟨⟨0⟩, depositId, [], [], [⟨0⟩, ⟨1⟩, ⟨2⟩], none⟩
def quoteFrom (source : InputSource Asset) : S := .invoke
  ⟨⟨1⟩, quoteId, [], [source], [⟨3⟩, ⟨4⟩, ⟨5⟩], none⟩
def quoteStep : S := quoteFrom (.priorOutput 0 ⟨⟨0⟩, ⟨0⟩⟩)
def workflow : List S := [depositStep, quoteStep]
def result : Cursor Party Asset Domain := Composition.run cfg boundary initialWorld workflow


def embedAsset : Vault.Asset → Asset
  | .usds => .usds
  | .susds => .susds
def embedCell (c : Cell Party Vault.Asset Domain) : C := (c.1, c.2.1, embedAsset c.2.2)
def depositEvaluated : Evaluated Party Asset Domain :=
  ⟨true, [(senderUsds, -1), (vaultUsds, 1), (mintedShares, 1)],
    [((.vault, .usds), 0), ((.vault, .susds), 1)], [], [], [], [],
    [senderUsds, vaultUsds, mintedShares]⟩

/-- The common-universe deposit really evaluates to the projected accepted adapter effects. -/
theorem deposit_evaluates (context : EvalContext Party Asset Domain []) :
    depositTemplate.evaluate context = .ok depositEvaluated := rfl

theorem deposit_effect_projection (c : Cell Party Vault.Asset Domain) :
    depositEvaluated.effect (embedCell c) = (Vault.Adapter.evaluated 1 1).effect c := by
  rcases c with ⟨d, p, a⟩
  cases d; cases p <;> cases a <;>
    simp [depositEvaluated, senderUsds, vaultUsds, mintedShares, embedCell, embedAsset,
      Evaluated.effect, Vault.Adapter.evaluated]

theorem deposit_supply_projection (a : Vault.Asset) :
    depositEvaluated.supply .vault (embedAsset a) =
      (Vault.Adapter.evaluated 1 1).supply .vault a := by
  cases a <;> rfl

theorem accepted_deposit_specialization
    (context : EvalContext Party Vault.Asset Domain []) :
    (Vault.Adapter.depositTemplate 1 1).evaluate context =
      .ok (Vault.Adapter.evaluated 1 1) := Vault.Adapter.template_evaluate 1 1 context

/-- Economic backing at the fixed chi=RAY rate, excluding the synthetic quote asset. -/
def reserves (w : W) : ℚ := w.state.balance vaultUsds
def shares (w : W) : ℚ := total w.state .vault .susds
def backed (w : W) : Prop := shares w ≤ reserves w

/-- A matched change in collateral reserves and issued raw shares preserves unit-rate backing.
Both a real deposit (delta=1) and a quote with no financial deltas (delta=0) use this lemma. -/
theorem matched_backing_change (oldReserves oldShares newReserves newShares delta : ℚ)
    (before : oldShares ≤ oldReserves)
    (reserveChange : newReserves = oldReserves + delta)
    (shareChange : newShares = oldShares + delta) : newShares ≤ newReserves := by
  rw [reserveChange, shareChange]
  simpa only [add_comm] using add_le_add_right before delta

/-- One contract covers both operations; its local guarantees are proved below for actual prefixes. -/
def contract : ComponentContract Party Asset Domain (Boundary Party Asset Domain) where
  initial w := w = initialWorld
  assumes _ _ := True
  invariant := backed
  guarantees _ pre post := ∃ delta,
    reserves post = reserves pre + delta ∧ shares post = shares pre + delta

def afterDeposit : Cursor Party Asset Domain :=
  Composition.run cfg boundary initialWorld [depositStep]
def resolvedShareInput : Except InterfaceFailure (List (PackedValue Asset)) :=
  resolveInputs 1 afterDeposit.outputs quoteInterface [.priorOutput 0 ⟨⟨0⟩, ⟨0⟩⟩]

set_option maxRecDepth 10000 in
set_option maxHeartbeats 2000000 in
theorem routed_share_input : resolvedShareInput =
    .ok [⟨.amount .susds, (ConcentratedLiquidity.Token0Bridge.amt1.value : ℚ)⟩] := by
  decide +kernel

/-- The actual resolved typed output, native vault conversion, and native quote share one Word. -/
theorem routed_input_native_quote : ∃ word : Arithmetic.Word 256,
    Vault.convertToShares ConcentratedLiquidity.Token0Bridge.amt1 Vault.rayChi = .ok word ∧
    resolvedShareInput = .ok [⟨.amount .susds, (word.value : ℚ)⟩] ∧
    ConcentratedLiquidity.Token0Bridge.libraryWord
      ConcentratedLiquidity.Token0Bridge.sqrtP_Q96 ConcentratedLiquidity.Token0Bridge.L1
      word true = .ok ConcentratedLiquidity.Token0Bridge.postWord :=
  ⟨ConcentratedLiquidity.Token0Bridge.amt1, ShareQuote.raw_share_conversion,
    routed_share_input, ConcentratedLiquidity.Token0Bridge.library_ordinary_add⟩

set_option maxRecDepth 10000 in
set_option maxHeartbeats 2000000 in
theorem initially_backed : backed initialWorld := by
  unfold backed
  decide +kernel

theorem contract_obligations : ContractObligations contract := by
  constructor
  · intro w h
    change w = initialWorld at h
    subst w
    exact initially_backed
  · intro b pre post before _ guarantee
    obtain ⟨delta, hv, hs⟩ := guarantee
    exact matched_backing_change _ _ _ _ delta before hv hs

set_option maxRecDepth 10000 in
set_option maxHeartbeats 2000000 in
theorem deposit_local_guarantee : contract.guarantees (boundary 0) initialWorld afterDeposit.world := by
  refine ⟨1, ?_, ?_⟩ <;> decide +kernel

set_option maxRecDepth 10000 in
set_option maxHeartbeats 2000000 in
theorem quote_local_guarantee : contract.guarantees (boundary 1) afterDeposit.world result.world := by
  refine ⟨0, ?_, ?_⟩ <;> decide +kernel

theorem deposit_preserves_backing : backed afterDeposit.world := by
  obtain ⟨delta, hv, hs⟩ := deposit_local_guarantee
  exact matched_backing_change _ _ _ _ delta initially_backed hv hs

theorem quote_preserves_backing : backed result.world := by
  obtain ⟨delta, hv, hs⟩ := quote_local_guarantee
  exact matched_backing_change _ _ _ _ delta deposit_preserves_backing hv hs

/-- No universal localGuarantee assumption: both actual local obligations are discharged above. -/
theorem actual_workflow_contract : contract.invariant result.world := quote_preserves_backing


set_option maxRecDepth 10000 in
set_option maxHeartbeats 2000000 in
theorem two_steps_succeed : result.failure.isNone = true ∧ result.events.length = 2 := by
  decide +kernel

set_option maxRecDepth 10000 in
set_option maxHeartbeats 2000000 in
theorem final_quote_balance : result.world.state.balance quoteCell =
    (ConcentratedLiquidity.Token0Bridge.lift ConcentratedLiquidity.Token0Bridge.postWord).amount := by
  decide +kernel

/-- The actual routed input and actual committed register are bound to the same native output. -/
theorem actual_financial_io : ∃ word : Arithmetic.Word 256,
    Vault.convertToShares ConcentratedLiquidity.Token0Bridge.amt1 Vault.rayChi = .ok word ∧
    resolvedShareInput = .ok [⟨.amount .susds, (word.value : ℚ)⟩] ∧
    ConcentratedLiquidity.Token0Bridge.libraryWord
      ConcentratedLiquidity.Token0Bridge.sqrtP_Q96 ConcentratedLiquidity.Token0Bridge.L1
      word true = .ok ConcentratedLiquidity.Token0Bridge.postWord ∧
    result.world.state.balance quoteCell =
      (ConcentratedLiquidity.Token0Bridge.lift ConcentratedLiquidity.Token0Bridge.postWord).amount := by
  obtain ⟨word, converted, routed, quoted⟩ := routed_input_native_quote
  exact ⟨word, converted, routed, quoted, final_quote_balance⟩

/-- Every actual successful prefix is backed, including the nonzero deposit and zero-delta quote. -/
theorem actual_prefix_contract (n : Nat) (bound : n ≤ 2) :
    contract.invariant (Composition.run cfg boundary initialWorld (workflow.take n)).world := by
  cases n with
  | zero => exact initially_backed
  | succ n =>
    cases n with
    | zero => exact deposit_preserves_backing
    | succ n =>
      have hn : n = 0 := by omega
      subst n
      exact quote_preserves_backing

/-- Exact refusal position/reason and complete ledger/capability prefix preservation. -/
def refusalMatches (cursor expected : Cursor Party Asset Domain)
    (index : Nat) (reason : Composition.Failure) : Bool :=
  (match cursor.failure with
    | none => false
    | some failure => decide (failure.index = index ∧ failure.reason = reason)) &&
  decide (cursor.events.length = expected.events.length) &&
  decide (cursor.nextIndex = expected.nextIndex) &&
  decide (cursor.outputs.length = expected.outputs.length) &&
  decide (cursor.world.capabilities = expected.world.capabilities) &&
  decide (∀ cell, cursor.world.state.balance cell = expected.world.state.balance cell)

def financialChecks : List (String × Bool) := [
  ("catalog", validateCatalog registry catalog),
  ("two_successful_steps", result.failure.isNone && result.events.length == 2),
  ("sender_debited", decide (result.world.state.balance senderUsds = 0)),
  ("vault_credited", decide (result.world.state.balance vaultUsds = 1)),
  ("shares_minted_and_unspent", decide (result.world.state.balance mintedShares = 1)),
  ("native_quote_result", decide (result.world.state.balance quoteCell = postQ)),
  ("wrong_unit_refused", refusalMatches (Composition.run cfg boundary initialWorld
    [depositStep, quoteFrom (.literal ⟨.amount .usds, 1⟩)]) afterDeposit 1 (.interface .inputUnit)),
  ("unavailable_output_refused", refusalMatches (Composition.run cfg boundary initialWorld
    [depositStep, quoteFrom (.priorOutput 1 ⟨⟨0⟩, ⟨0⟩⟩)]) afterDeposit 1
      (.interface .unavailableOutput)),
  ("wrong_share_amount_refused", refusalMatches (Composition.run cfg boundary initialWorld
    [depositStep, quoteFrom (.literal ⟨.amount .susds, 0⟩)]) afterDeposit 1 (.kernel .guard)),
  ("unfunded_deposit_refused", refusalMatches (Composition.run cfg boundary unfundedWorld workflow)
    (startCursor cfg unfundedWorld) 0 (.kernel .insufficientFunds))]

#eval do
  if financialChecks.isEmpty then throw (IO.userError "BLOCKED: empty financial checks")
  if !decide (financialChecks.map Prod.fst).Nodup then
    throw (IO.userError "FAILED: duplicate financial check labels")
  for (name, passed) in financialChecks do
    IO.println s!"FINANCIAL {name} {passed}"
  if !financialChecks.all Prod.snd then throw (IO.userError "FAILED: financial workflow check")
  IO.println s!"FINANCIAL PASSED {financialChecks.length}/{financialChecks.length}"

end DefiKernel.Composition.VaultQuoteWorkflow
