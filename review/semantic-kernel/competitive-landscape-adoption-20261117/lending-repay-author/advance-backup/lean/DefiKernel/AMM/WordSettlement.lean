import DefiKernel.AMM.Settlement
import DefiKernel.AMM.Checked

/-! Checked quote to actual Typed settlement, with explicit raw-scale1 pool-state binding. -/
namespace DefiKernel.AMM.WordSettlement
open DefiKernel.Typed DefiKernel.Arithmetic DefiKernel.AMM.Settlement

inductive Refusal where
  | reserveMismatch
  | quote (reason : Checked.Refusal)
  | typed (reason : Typed.Refusal)
  deriving DecidableEq, Repr

def matchesPool (pool : Checked.Pool) (pre : S) : Bool :=
  decide (pre.balance (.pool, .pool, .x) = (pool.reserveX.value : ℚ) ∧
    pre.balance (.pool, .pool, .y) = (pool.reserveY.value : ℚ))

/-- A supplied Word pool must equal the actual pre-ledger reserve cells before quoting. -/
def run (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee) (store : Store) (pre : S) :
    Except Refusal W := do
  if !matchesPool pool pre then throw .reserveMismatch
  let quoted ← (Checked.swapPool pool amount fee).mapError Refusal.quote
  (Typed.execute (Settlement.registry amount.value quoted.output.value) store
    context environment 0 request pre).mapError Refusal.typed

theorem mismatch_refusal (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee)
    (store : Store) (pre : S) (mismatch : matchesPool pool pre = false) :
    run pool amount fee store pre = .error .reserveMismatch := by
  simp [run, mismatch, bind, Except.bind]
  rfl

theorem matches_iff (pool : Checked.Pool) (pre : S) :
    matchesPool pool pre = true ↔
      pre.balance (.pool, .pool, .x) = (pool.reserveX.value : ℚ) ∧
      pre.balance (.pool, .pool, .y) = (pool.reserveY.value : ℚ) := by
  simp [matchesPool]

/-- The checked wrapper reads exactly the inherited two pool quote cells for compatibility. -/
theorem matches_reads (pool : Checked.Pool) (before after : S)
    (agree : ∀ cell ∈ quoteReads, before.balance cell = after.balance cell) :
    matchesPool pool before = matchesPool pool after := by
  have hx := agree (.pool, .pool, .x) (by simp [quoteReads])
  have hy := agree (.pool, .pool, .y) (by simp [quoteReads])
  simp only [matchesPool, hx, hy]

theorem run_ok_iff (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee)
    (store : Store) (pre : S) (post : W) :
    run pool amount fee store pre = .ok post ↔
      matchesPool pool pre = true ∧ ∃ quoted, Checked.swapPool pool amount fee = .ok quoted ∧
        Typed.execute (Settlement.registry amount.value quoted.output.value) store
          context environment 0 request pre = .ok post := by
  cases matched : matchesPool pool pre with
  | false =>
    rw [mismatch_refusal pool amount fee store pre matched]
    simp [matched]
  | true =>
    cases native : Checked.swapPool pool amount fee with
    | error reason => simp [run, matched, native, Except.mapError, bind, Except.bind]
    | ok quoted =>
      cases executed : Typed.execute (Settlement.registry amount.value quoted.output.value)
        store context environment 0 request pre <;>
        simp [run, matched, native, executed, Except.mapError, bind, Except.bind]

/-- Full native arithmetic success is derived from Admissible; real rights/funding settle it. -/
theorem funded_success (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee)
    (store : Store) (pre : S) (domain : Checked.Admissible pool amount fee)
    (compatible : matchesPool pool pre = true)
    (funded : (amount.value : ℚ) ≤ pre.balance (.pool, .trader, .x))
    (invoke : hasAuthority store request.capabilityIds context operation .invoke = true)
    (traderDebit : hasAuthority store request.capabilityIds context operation
      (.debit (.pool, .trader, .x)) = true)
    (poolDebit : hasAuthority store request.capabilityIds context operation
      (.debit (.pool, .pool, .y)) = true) :
    ∃ post, run pool amount fee store pre = .ok post := by
  have native := Checked.success pool amount fee domain
  have outputBound : (Checked.computed pool amount fee domain).output.value < pool.reserveY.value :=
    Checked.floor_lt_reserve pool amount fee domain.reserveX_pos domain.reserveY_pos domain.fee_valid
  have liquidity : ((Checked.computed pool amount fee domain).output.value : ℚ) ≤
      pre.balance (.pool, .pool, .y) := by
    rw [(matches_iff pool pre).mp compatible |>.2]
    exact_mod_cast le_of_lt outputBound
  obtain ⟨post, executed⟩ := Settlement.execute_exists amount.value
    (Checked.computed pool amount fee domain).output.value store pre (Nat.cast_nonneg _)
    (Nat.cast_nonneg _) funded liquidity invoke traderDebit poolDebit
  exact ⟨post, (run_ok_iff pool amount fee store pre post).mpr ⟨compatible, _, native, executed⟩⟩

/-- The actually executed ledger pool equals the actually returned native Word post-pool. -/
theorem native_post_reserves (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee)
    (store : Store) (pre : S) (post : W) (quoted : Checked.Swap)
    (compatible : matchesPool pool pre = true)
    (native : Checked.swapPool pool amount fee = .ok quoted)
    (executed : Typed.execute (Settlement.registry amount.value quoted.output.value) store
      context environment 0 request pre = .ok post) :
    post.state.balance (.pool, .pool, .x) = (quoted.post.reserveX.value : ℚ) ∧
      post.state.balance (.pool, .pool, .y) = (quoted.post.reserveY.value : ℚ) := by
  have domain := (Checked.exists_success_iff pool amount fee).mp ⟨quoted, native⟩
  have same : Checked.computed pool amount fee domain = quoted := Except.ok.inj
    ((Checked.success pool amount fee domain).symm.trans native)
  subst quoted
  have compatibility := (matches_iff pool pre).mp compatible
  obtain ⟨_, _, _, balances⟩ := (Settlement.typed_ok_iff _ _ store pre post).mp executed
  constructor
  · change post.state.balance (.pool, .pool, .x) =
      ((pool.reserveX.value + amount.value : Nat) : ℚ)
    rw [Nat.cast_add]
    simpa [Evaluated.effect, Settlement.evaluated, compatibility.1] using
      balances (.pool, .pool, .x)
  · change post.state.balance (.pool, .pool, .y) =
      ((pool.reserveY.value - Checked.floorValue pool amount fee : Nat) : ℚ)
    rw [Nat.cast_sub (le_of_lt (Checked.floor_lt_reserve pool amount fee domain.reserveX_pos
      domain.reserveY_pos domain.fee_valid))]
    simpa [Evaluated.effect, Settlement.evaluated, compatibility.2, Checked.computed,
      Checked.floorOutput, sub_eq_add_neg] using balances (.pool, .pool, .y)

/-- Actual input/output transfers, exact native postreserves, zero supply, and per-asset totals. -/
theorem run_correspondence (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee)
    (store : Store) (pre : S) (post : W)
    (success : run pool amount fee store pre = .ok post) :
    matchesPool pool pre = true ∧ ∃ quoted, Checked.swapPool pool amount fee = .ok quoted ∧
      post.state.balance (.pool, .pool, .x) = (quoted.post.reserveX.value : ℚ) ∧
      post.state.balance (.pool, .pool, .y) = (quoted.post.reserveY.value : ℚ) ∧
      pre.balance (.pool, .trader, .x) - post.state.balance (.pool, .trader, .x) = (amount.value : ℚ) ∧
      post.state.balance (.pool, .trader, .y) - pre.balance (.pool, .trader, .y) = (quoted.output.value : ℚ) ∧
      (∀ asset, total post.state .pool asset = total pre .pool asset) ∧ post.capabilities = store := by
  obtain ⟨compatible, quoted, native, executed⟩ := (run_ok_iff pool amount fee store pre post).mp success
  have reserves := native_post_reserves pool amount fee store pre post quoted compatible native executed
  obtain ⟨_, _, capabilities, balances⟩ := (Settlement.typed_ok_iff _ _ store pre post).mp executed
  refine ⟨compatible, quoted, native, reserves.1, reserves.2, ?_, ?_,
    Settlement.typed_conservation _ _ store pre post executed, capabilities⟩
  · have observed := balances (.pool, .trader, .x)
    simp [Evaluated.effect, Settlement.evaluated] at observed
    linarith
  · have observed := balances (.pool, .trader, .y)
    simp [Evaluated.effect, Settlement.evaluated] at observed
    linarith

/-- The actual trader Y gain is one floor below the accepted exact fee-aware rational quote. -/
theorem actual_output_floor (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee)
    (store : Store) (pre : S) (post : W)
    (success : run pool amount fee store pre = .ok post) :
    post.state.balance (.pool, .trader, .y) - pre.balance (.pool, .trader, .y) ≤
        (Rational.computed (Checked.rationalPool pool) amount.value (Checked.rationalFee fee)).output ∧
      (Rational.computed (Checked.rationalPool pool) amount.value (Checked.rationalFee fee)).output <
        post.state.balance (.pool, .trader, .y) - pre.balance (.pool, .trader, .y) + 1 := by
  obtain ⟨_, quoted, native, _, _, _, gain, _, _⟩ :=
    run_correspondence pool amount fee store pre post success
  have domain := (Checked.exists_success_iff pool amount fee).mp ⟨quoted, native⟩
  have same : Checked.computed pool amount fee domain = quoted := Except.ok.inj
    ((Checked.success pool amount fee domain).symm.trans native)
  rw [gain]
  rw [←same]
  exact Checked.rational_floor_interval pool amount fee domain

theorem ledger_product_nondecrease (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee)
    (store : Store) (pre : S) (post : W)
    (success : run pool amount fee store pre = .ok post) :
    pre.balance (.pool, .pool, .x) * pre.balance (.pool, .pool, .y) ≤
      post.state.balance (.pool, .pool, .x) * post.state.balance (.pool, .pool, .y) := by
  obtain ⟨compatible, quoted, native, postX, postY, _, _, _, _⟩ :=
    run_correspondence pool amount fee store pre post success
  have domain := (Checked.exists_success_iff pool amount fee).mp ⟨quoted, native⟩
  have same : Checked.computed pool amount fee domain = quoted := Except.ok.inj
    ((Checked.success pool amount fee domain).symm.trans native)
  have product := Checked.product_nondecrease pool amount fee domain
  rw [same] at product
  have castProduct : (pool.reserveX.value : ℚ) * pool.reserveY.value ≤
      (quoted.post.reserveX.value : ℚ) * quoted.post.reserveY.value := by exact_mod_cast product
  have compatibility := (matches_iff pool pre).mp compatible
  rw [compatibility.1, compatibility.2, postX, postY]
  exact castProduct

theorem mismatch_refusal_iff (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee)
    (store : Store) (pre : S) :
    run pool amount fee store pre = .error .reserveMismatch ↔ matchesPool pool pre = false := by
  cases matched : matchesPool pool pre with
  | false =>
    rw [mismatch_refusal pool amount fee store pre matched]
    simp [matched]
  | true =>
    cases native : Checked.swapPool pool amount fee with
    | error reason => simp [run, matched, native, Except.mapError, bind, Except.bind]
    | ok quoted =>
      cases executed : Typed.execute (Settlement.registry amount.value quoted.output.value)
        store context environment 0 request pre <;>
        simp [run, matched, native, executed, Except.mapError, bind, Except.bind]

theorem quote_refusal_iff (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee)
    (store : Store) (pre : S) (reason : Checked.Refusal) :
    run pool amount fee store pre = .error (.quote reason) ↔
      matchesPool pool pre = true ∧ Checked.swapPool pool amount fee = .error reason := by
  cases matched : matchesPool pool pre with
  | false =>
    rw [mismatch_refusal pool amount fee store pre matched]
    simp [matched]
  | true =>
    cases native : Checked.swapPool pool amount fee with
    | error refusal => simp [run, matched, native, Except.mapError, bind, Except.bind]
    | ok quoted =>
      cases executed : Typed.execute (Settlement.registry amount.value quoted.output.value)
        store context environment 0 request pre <;>
        simp [run, matched, native, executed, Except.mapError, bind, Except.bind]

theorem typed_refusal_iff (pool : Checked.Pool) (amount : Word 256) (fee : Checked.Fee)
    (store : Store) (pre : S) (reason : Typed.Refusal) :
    run pool amount fee store pre = .error (.typed reason) ↔
      matchesPool pool pre = true ∧ ∃ quoted, Checked.swapPool pool amount fee = .ok quoted ∧
        Typed.execute (Settlement.registry amount.value quoted.output.value) store
          context environment 0 request pre = .error reason := by
  cases matched : matchesPool pool pre with
  | false =>
    rw [mismatch_refusal pool amount fee store pre matched]
    simp [matched]
  | true =>
    cases native : Checked.swapPool pool amount fee with
    | error refusal => simp [run, matched, native, Except.mapError, bind, Except.bind]
    | ok quoted =>
      cases executed : Typed.execute (Settlement.registry amount.value quoted.output.value)
        store context environment 0 request pre <;>
        simp [run, matched, native, executed, Except.mapError, bind, Except.bind]

end DefiKernel.AMM.WordSettlement
