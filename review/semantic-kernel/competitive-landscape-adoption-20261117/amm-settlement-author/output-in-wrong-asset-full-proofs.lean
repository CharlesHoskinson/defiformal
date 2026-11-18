import DefiKernel.AMM.Rational
import DefiKernel.Typed.Transition
import Mathlib.Data.Fintype.Basic

/-! Actual rational pool quoting and registered Typed wallet settlement at raw scale1. -/
namespace DefiKernel.AMM.Settlement
open DefiKernel.Typed

inductive Party where | trader | pool deriving DecidableEq, Repr
inductive Asset where | x | y deriving DecidableEq, Repr
inductive Domain where | pool deriving DecidableEq, Repr
instance : Fintype Party := ⟨{.trader, .pool}, by intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.x, .y}, by intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.pool}, by intro d; cases d; simp⟩

abbrev S := State Party Asset Domain
abbrev Store := CapabilityStore Party Asset Domain
abbrev W := ExecutionResult Party Asset Domain

def operation : OperationId := ⟨0⟩
def context : InvocationContext Party Domain := ⟨.trader, .pool⟩
def environment : Environment Asset Domain := fun _ => none
def request : Request Party Asset Domain := ⟨operation, [], [], [⟨0⟩, ⟨1⟩, ⟨2⟩], none⟩
def quoteReads : List (Cell Party Asset Domain) :=
  [(.pool, .pool, .x), (.pool, .pool, .y)]

def quotePool (pre : S) : Rational.Pool :=
  ⟨pre.balance (.pool, .pool, .x), pre.balance (.pool, .pool, .y)⟩

def template (amount output : ℚ) : Template Party Asset Domain where
  signature := []
  domain := .pool
  partyArity := 0
  guard := .lit true
  deltas := [
    ⟨.x, ⟨.pool, .literal .trader⟩, .lit (-amount)⟩,
    ⟨.x, ⟨.pool, .literal .pool⟩, .lit amount⟩,
    ⟨.x, ⟨.pool, .literal .trader⟩, .lit output⟩,
    ⟨.x, ⟨.pool, .literal .pool⟩, .lit (-output)⟩]
  supplyDeltas := []
  stateReads := [⟨.x, ⟨.pool, .literal .pool⟩⟩, ⟨.y, ⟨.pool, .literal .pool⟩⟩]
  envReads := []
  writes := [⟨.x, ⟨.pool, .literal .trader⟩⟩, ⟨.x, ⟨.pool, .literal .pool⟩⟩,
    ⟨.y, ⟨.pool, .literal .trader⟩⟩, ⟨.y, ⟨.pool, .literal .pool⟩⟩]

def registry (amount output : ℚ) : Registry Party Asset Domain :=
  fun op => if op = operation then some (template amount output) else none

def evaluated (amount output : ℚ) : Evaluated Party Asset Domain :=
  ⟨true, [((.pool, .trader, .x), -amount), ((.pool, .pool, .x), amount),
    ((.pool, .trader, .y), output), ((.pool, .pool, .y), -output)],
    [], [], [], quoteReads, [],
    [(.pool, .trader, .x), (.pool, .pool, .x), (.pool, .trader, .y), (.pool, .pool, .y)]⟩

/-- Native quote uses the same pre-state later passed to Typed.execute; no external reserves. -/
def run (amount fee : ℚ) (store : Store) (pre : S) :
    Except (Rational.Refusal ⊕ Typed.Refusal) W := do
  let quoted ← (Rational.swapPool (quotePool pre) amount fee).mapError Sum.inl
  (Typed.execute (registry amount quoted.output) store context environment 0 request pre).mapError Sum.inr

def fullStore : Store :=
  ⟨[⟨⟨.trader, .pool, operation, .invoke⟩, true⟩,
    ⟨⟨.trader, .pool, operation, .debit (.pool, .trader, .x)⟩, true⟩,
    ⟨⟨.trader, .pool, operation, .debit (.pool, .pool, .y)⟩, true⟩]⟩

theorem full_store_authorities :
    hasAuthority fullStore request.capabilityIds context operation .invoke = true ∧
      hasAuthority fullStore request.capabilityIds context operation
        (.debit (.pool, .trader, .x)) = true ∧
      hasAuthority fullStore request.capabilityIds context operation
        (.debit (.pool, .pool, .y)) = true := by decide

theorem template_evaluate (amount output : ℚ)
    (ctx : EvalContext Party Asset Domain (template amount output).signature) :
    (template amount output).evaluate ctx = .ok (evaluated amount output) := rfl

/-- Pure wrapper quote reads: agreement on these exact cells determines the native pool. -/
theorem quote_pool_reads (before after : S)
    (agree : ∀ cell ∈ quoteReads, before.balance cell = after.balance cell) :
    quotePool before = quotePool after := by
  have hx := agree (.pool, .pool, .x) (by simp [quoteReads])
  have hy := agree (.pool, .pool, .y) (by simp [quoteReads])
  simp only [quotePool, hx, hy]

/-- The registered constant transfer expressions have no syntactic balance reads;
    the declared footprint separately includes the wrapper's two quote reads. -/
theorem declared_quote_reads (amount output : ℚ) :
    (evaluated amount output).declaredStateReads = quoteReads ∧
      (evaluated amount output).requiredStateReads = [] := ⟨rfl, rfl⟩

theorem effect_values (amount output : ℚ) :
    (evaluated amount output).effect (.pool, .trader, .x) = -amount ∧
    (evaluated amount output).effect (.pool, .pool, .x) = amount ∧
    (evaluated amount output).effect (.pool, .trader, .y) = output ∧
    (evaluated amount output).effect (.pool, .pool, .y) = -output := by
  simp [Evaluated.effect, evaluated]

theorem sum_parties (f : Party → ℚ) : ∑ p, f p = f .trader + f .pool := by
  rw [show (Finset.univ : Finset Party) = {.trader, .pool} from rfl]
  simp

theorem total_eq (state : S) (asset : Asset) :
    total state .pool asset = state.balance (.pool, .trader,asset) +
      state.balance (.pool, .pool,asset) := by
  exact sum_parties (fun party => state.balance (.pool,party,asset))

theorem supply_zero (amount output : ℚ) (domain : Domain) (asset : Asset) :
    (evaluated amount output).supply domain asset = 0 := rfl

theorem evaluated_valid (amount output : ℚ) (store : Store) (pre : S)
    (amountNonneg : 0 ≤ amount) (outputNonneg : 0 ≤ output)
    (funded : amount ≤ pre.balance (.pool, .trader, .x))
    (liquid : output ≤ pre.balance (.pool, .pool, .y))
    (traderDebit : hasAuthority store request.capabilityIds context operation
      (.debit (.pool, .trader, .x)) = true)
    (poolDebit : hasAuthority store request.capabilityIds context operation
      (.debit (.pool, .pool, .y)) = true) :
    (evaluated amount output).Valid store context request pre := by
  have nonneg : ∀ cell, 0 ≤ pre.balance cell + (evaluated amount output).effect cell := by
    intro ⟨domain,party,asset⟩
    cases domain
    cases party <;> cases asset <;> simp [Evaluated.effect, evaluated]
    · linarith
    · linarith [pre.nonneg (.pool, .trader, .y)]
    · linarith [pre.nonneg (.pool, .pool, .x)]
    · linarith
  refine ⟨rfl, rfl, rfl, ?_, ?_, ?_, nonneg, ?_, ?_⟩
  · simp only [Evaluated.domainOK, decide_eq_true_eq]
    refine ⟨by simp [evaluated], ?_, ?_⟩
    · intro ⟨d,p,a⟩ _; cases d; trivial
    · intro d a _; cases d; trivial
  · simp only [Evaluated.debitsOK, decide_eq_true_eq]
    intro ⟨d,p,a⟩ negative
    cases d
    cases p <;> cases a <;> simp [Evaluated.effect, evaluated] at negative ⊢
    · exact traderDebit
    · linarith
    · linarith
    · exact poolDebit
  · simp [Evaluated.suppliesOK, supply_zero]
  · simp only [Evaluated.accountingOK, decide_eq_true_eq]
    intro d a
    cases d
    rw [sum_parties]
    cases a <;> simp [Evaluated.effect, evaluated, Evaluated.supply]
  · simp only [Evaluated.writesOK, decide_eq_true_eq]
    intro ⟨d,p,a⟩ outside
    cases d
    cases p <;> cases a <;> simp [evaluated] at outside

theorem typed_ok_iff (amount output : ℚ) (store : Store) (pre : S) (post : W) :
    Typed.execute (registry amount output) store context environment 0 request pre = .ok post ↔
      hasAuthority store request.capabilityIds context operation .invoke = true ∧
      (evaluated amount output).Valid store context request pre ∧
      post.capabilities = store ∧
      ∀ cell, post.state.balance cell = pre.balance cell + (evaluated amount output).effect cell := by
  have correspondence := Typed.execute_ok_iff (registry amount output) store
    context environment 0 request pre post
  constructor
  · intro success
    obtain ⟨selected, registered, actor, dom, arity, args, checked, invoke, e,
      observed, valid, capabilities, balances⟩ := correspondence.mp success
    have selectedEq : selected = template amount output := by
      simpa [registry, request] using registered.symm
    subst selected
    have expected := template_evaluate amount output
      ⟨pre, environment, context.principal, request.parties, args, 0⟩
    have same : e = evaluated amount output := Except.ok.inj (observed.symm.trans expected)
    subst e
    exact ⟨invoke, valid, capabilities, balances⟩
  · rintro ⟨invoke, valid, capabilities, balances⟩
    apply correspondence.mpr
    refine ⟨template amount output, ?_, ?_, rfl, rfl, Args.nil, rfl, invoke,
      evaluated amount output, ?_, valid, capabilities, balances⟩
    · simp [registry, request]
    · simp [request]
    · exact template_evaluate amount output ⟨pre, environment, .trader, [], Args.nil, 0⟩

/-- Actual guards and rights/funding prove executable success, without a Valid premise. -/
theorem execute_exists (amount output : ℚ) (store : Store) (pre : S)
    (amountNonneg : 0 ≤ amount) (outputNonneg : 0 ≤ output)
    (funded : amount ≤ pre.balance (.pool, .trader, .x))
    (liquid : output ≤ pre.balance (.pool, .pool, .y))
    (invoke : hasAuthority store request.capabilityIds context operation .invoke = true)
    (traderDebit : hasAuthority store request.capabilityIds context operation
      (.debit (.pool, .trader, .x)) = true)
    (poolDebit : hasAuthority store request.capabilityIds context operation
      (.debit (.pool, .pool, .y)) = true) :
    ∃ post, Typed.execute (registry amount output) store context environment 0 request pre = .ok post := by
  have valid := evaluated_valid amount output store pre amountNonneg outputNonneg
    funded liquid traderDebit poolDebit
  have nonneg : ∀ cell, 0 ≤ pre.balance cell + (evaluated amount output).effect cell := valid.2.2.2.2.2.2.1
  let post : W := ⟨⟨fun cell => pre.balance cell + (evaluated amount output).effect cell, nonneg⟩, store⟩
  exact ⟨post, (typed_ok_iff amount output store pre post).mpr ⟨invoke, valid, rfl, by intro cell; rfl⟩⟩

theorem run_ok_iff (amount fee : ℚ) (store : Store) (pre : S) (post : W) :
    run amount fee store pre = .ok post ↔
      ∃ quoted, Rational.swapPool (quotePool pre) amount fee = .ok quoted ∧
        Typed.execute (registry amount quoted.output) store context environment 0 request pre = .ok post := by
  unfold run
  cases native : Rational.swapPool (quotePool pre) amount fee with
  | error reason => simp [Except.mapError, bind, Except.bind]
  | ok quoted =>
    cases executed : Typed.execute (registry amount quoted.output) store
      context environment 0 request pre <;> simp [executed, Except.mapError, bind, Except.bind]

/-- Generic funded rational success; reserves are the actual pre-ledger pool cells. -/
theorem funded_success (amount fee : ℚ) (store : Store) (pre : S)
    (hx : 0 < pre.balance (.pool, .pool, .x)) (hy : 0 < pre.balance (.pool, .pool, .y))
    (hd : 0 < amount) (hf0 : 0 ≤ fee) (hf1 : fee < 1)
    (funded : amount ≤ pre.balance (.pool, .trader, .x))
    (invoke : hasAuthority store request.capabilityIds context operation .invoke = true)
    (traderDebit : hasAuthority store request.capabilityIds context operation
      (.debit (.pool, .trader, .x)) = true)
    (poolDebit : hasAuthority store request.capabilityIds context operation
      (.debit (.pool, .pool, .y)) = true) :
    ∃ post, run amount fee store pre = .ok post := by
  have native := Rational.success (quotePool pre) amount fee hx hy hd hf0 hf1
  have positive := Rational.output_pos (quotePool pre) amount fee hx hy hd hf1
  have bound := Rational.output_lt_reserve (quotePool pre) amount fee hx hy hd hf1
  obtain ⟨post, executed⟩ := execute_exists amount (Rational.computed (quotePool pre) amount fee).output
    store pre (le_of_lt hd) (le_of_lt positive) funded (le_of_lt bound) invoke traderDebit poolDebit
  exact ⟨post, (run_ok_iff amount fee store pre post).mpr ⟨_, native, executed⟩⟩

theorem typed_conservation (amount output : ℚ) (store : Store) (pre : S) (post : W)
    (executed : Typed.execute (registry amount output) store context environment 0 request pre = .ok post) :
    ∀ asset, total post.state .pool asset = total pre .pool asset := by
  obtain ⟨_, _, _, balances⟩ := (typed_ok_iff amount output store pre post).mp executed
  intro asset
  simp only [total_eq, balances]
  cases asset <;> simp [Evaluated.effect, evaluated] <;> ring

/-- Native successful quote, actual pool reserves, unchanged capabilities and ledger totals. -/
theorem run_correspondence (amount fee : ℚ) (store : Store) (pre : S) (post : W)
    (success : run amount fee store pre = .ok post) :
    Rational.swapPool (quotePool pre) amount fee =
        .ok (Rational.computed (quotePool pre) amount fee) ∧
      post.state.balance (.pool, .pool, .x) =
        (Rational.computed (quotePool pre) amount fee).post.reserveX ∧
      post.state.balance (.pool, .pool, .y) =
        (Rational.computed (quotePool pre) amount fee).post.reserveY ∧
      (∀ asset, total post.state .pool asset = total pre .pool asset) ∧
      post.capabilities = store := by
  obtain ⟨quoted, native, executed⟩ := (run_ok_iff amount fee store pre post).mp success
  obtain ⟨_, _, _, _, _, same⟩ := (Rational.success_iff _ _ _ _).mp native
  subst quoted
  obtain ⟨_, _, capabilities, balances⟩ := (typed_ok_iff _ _ store pre post).mp executed
  refine ⟨native, ?_, ?_, typed_conservation _ _ store pre post executed, capabilities⟩
  · simpa [Evaluated.effect, evaluated, quotePool, Rational.computed] using
      balances (.pool, .pool, .x)
  · simpa [Evaluated.effect, evaluated, quotePool, Rational.computed, sub_eq_add_neg] using
      balances (.pool, .pool, .y)

theorem ledger_product_nondecrease (amount fee : ℚ) (store : Store) (pre : S) (post : W)
    (success : run amount fee store pre = .ok post) :
    pre.balance (.pool, .pool, .x) * pre.balance (.pool, .pool, .y) ≤
      post.state.balance (.pool, .pool, .x) * post.state.balance (.pool, .pool, .y) := by
  have observation := run_correspondence amount fee store pre post success
  obtain ⟨hx, hy, hd, hf0, hf1, _⟩ := (Rational.success_iff _ _ _ _).mp observation.1
  rw [observation.2.1, observation.2.2.1]
  exact Rational.product_nondecrease (quotePool pre) amount fee hx hy hd hf0 hf1

/-- Quote refusals precede Typed execution and retain their exact native constructor. -/
theorem quote_refusal_iff (amount fee : ℚ) (store : Store) (pre : S) (reason : Rational.Refusal) :
    run amount fee store pre = .error (.inl reason) ↔
      Rational.swapPool (quotePool pre) amount fee = .error reason := by
  unfold run
  cases native : Rational.swapPool (quotePool pre) amount fee with
  | error refusal => simp [Except.mapError, bind, Except.bind]
  | ok quoted =>
    cases executed : Typed.execute (registry amount quoted.output) store
      context environment 0 request pre <;> simp [executed, Except.mapError, bind, Except.bind]

theorem typed_refusal_iff (amount fee : ℚ) (store : Store) (pre : S) (reason : Typed.Refusal) :
    run amount fee store pre = .error (.inr reason) ↔
      ∃ quoted, Rational.swapPool (quotePool pre) amount fee = .ok quoted ∧
        Typed.execute (registry amount quoted.output) store context environment 0 request pre = .error reason := by
  unfold run
  cases native : Rational.swapPool (quotePool pre) amount fee with
  | error refusal => simp [Except.mapError, bind, Except.bind]
  | ok quoted =>
    cases executed : Typed.execute (registry amount quoted.output) store
      context environment 0 request pre <;> simp [executed, Except.mapError, bind, Except.bind]

end DefiKernel.AMM.Settlement
