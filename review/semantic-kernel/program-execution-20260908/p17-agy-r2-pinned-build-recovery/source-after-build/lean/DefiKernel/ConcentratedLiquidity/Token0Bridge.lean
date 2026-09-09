import DefiKernel.Typed.Transition
import DefiKernel.Arithmetic.Quantity
import DefiKernel.ConcentratedLiquidity.SqrtPriceMath

/-! Model-only quote-register wrap of the delivered token0 library.
Not Uniswap pool storage, not cash settlement, not a source observation. -/
namespace DefiKernel.ConcentratedLiquidity.Token0Bridge
open DefiKernel.Typed
open DefiKernel.ConcentratedLiquidity
open DefiKernel.Arithmetic
open SqrtPriceMath
open FullMath

inductive Party | quoteHolder
  deriving DecidableEq, Repr
inductive Asset | quoteSqrtP
  deriving DecidableEq, Repr
inductive Domain | quote
  deriving DecidableEq, Repr

instance : Fintype Party := ⟨{.quoteHolder}, by intro p; cases p; simp⟩
instance : Fintype Asset := ⟨{.quoteSqrtP}, by intro a; cases a; simp⟩
instance : Fintype Domain := ⟨{.quote}, by intro d; cases d; simp⟩

def op : OperationId := ⟨1⟩
def scale1 : ℚ := 1
theorem scale1_pos : (0 : ℚ) < scale1 := by decide

def sqrtP_Q96 : U160 := ⟨2 ^ 96, by decide⟩
def L1 : U128 := ⟨1, by decide⟩
def amt1 : U256 := ⟨1, by decide⟩
def amt0 : U256 := ⟨0, by decide⟩

def libraryWord (sqrtP : U160) (L : U128) (amount : U256) (add : Bool) :
    Except Failure U160 :=
  getNextSqrtPriceFromAmount0RoundingUp sqrtP L amount add

def lift (w : U160) : Quantity Asset.quoteSqrtP :=
  Quantity.toQuantity Asset.quoteSqrtP scale1 scale1_pos
    (⟨w.value, Nat.lt_trans w.bound two_pow_160_lt_256⟩ : Word 256)

def quoteTemplate (pre post : ℚ) : Template Party Asset Domain where
  signature := []
  domain := .quote
  partyArity := 0
  guard := .lit true
  deltas := [⟨.quoteSqrtP, ⟨.quote, .literal .quoteHolder⟩, .lit (post - pre)⟩]
  supplyDeltas := [⟨.quote, .quoteSqrtP, .lit (post - pre)⟩]
  stateReads := []
  envReads := []
  writes := [⟨.quoteSqrtP, ⟨.quote, .literal .quoteHolder⟩⟩]

def registry (pre post : ℚ) : Registry Party Asset Domain :=
  fun selected => if selected = op then some (quoteTemplate pre post) else none

def evaluated (pre post : ℚ) : Evaluated Party Asset Domain :=
  ⟨true, [((.quote, .quoteHolder, .quoteSqrtP), post - pre)],
    [((.quote, .quoteSqrtP), post - pre)], [], [], [], [],
    [(.quote, .quoteHolder, .quoteSqrtP)]⟩

def store : CapabilityStore Party Asset Domain :=
  ⟨[⟨⟨.quoteHolder, .quote, op, .invoke⟩, true⟩,
    ⟨⟨.quoteHolder, .quote, op, .debit (.quote, .quoteHolder, .quoteSqrtP)⟩, true⟩,
    ⟨⟨.quoteHolder, .quote, op, .changeSupply .quote .quoteSqrtP⟩, true⟩]⟩

def ctx : InvocationContext Party Domain := ⟨.quoteHolder, .quote⟩
def env : Environment Asset Domain := fun _ => none
def req : Request Party Asset Domain := ⟨op, [], [], [⟨0⟩, ⟨1⟩, ⟨2⟩], none⟩

def preRegister (pre : ℚ) (h : 0 ≤ pre) : State Party Asset Domain where
  balance := fun _ => pre
  nonneg := by
    intro _c
    exact h

-- BEGIN PROOFS

theorem two_pow_96_lt_160 : 2 ^ 96 < 2 ^ 160 :=
  Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 96 < 160)

theorem sqrtP_Q96_value : sqrtP_Q96.value = 2 ^ 96 := rfl

theorem two_pow_95_lt_160 : 2 ^ 95 < 2 ^ 160 :=
  Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 95 < 160)

def postWord : U160 := ⟨2 ^ 95, two_pow_95_lt_160⟩

theorem amt1_pos : amt1.value ≠ 0 := by decide

theorem ordinary_product : product amt1 sqrtP_Q96 = 2 ^ 96 := by
  simp [product, amt1, sqrtP_Q96]

theorem ordinary_numerator1 : numerator1 L1 = 2 ^ 96 := by
  simp [numerator1, Q96, L1]

theorem ordinary_product_fit : product amt1 sqrtP_Q96 < 2 ^ 256 := by
  rw [ordinary_product]
  exact Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 96 < 256)

theorem two_pow_96_mul : (2 ^ 96) * (2 ^ 96) = 2 ^ 192 := (Nat.pow_add 2 96 96).symm

theorem two_pow_96_add : 2 ^ 96 + 2 ^ 96 = 2 ^ 97 := by
  have h : 2 ^ 96 + 2 ^ 96 = 2 * 2 ^ 96 := by ring
  rw [h, Nat.mul_comm, ← Nat.pow_succ]

theorem two_pow_95_mul_97 : (2 ^ 95) * (2 ^ 97) = 2 ^ 192 := (Nat.pow_add 2 95 97).symm

theorem two_pow_97_lt_256 : 2 ^ 97 < 2 ^ 256 :=
  Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 97 < 256)

theorem ordinary_divup :
    Rounding.divideNat .up ((2 ^ 96) * (2 ^ 96)) (2 ^ 97) = .ok (2 ^ 95) := by
  have hpos : 0 < 2 ^ 97 := Nat.pow_pos (by decide : 0 < 2)
  have hdiv : 2 ^ 97 ∣ 2 ^ 192 := Nat.pow_dvd_pow 2 (by decide : 97 ≤ 192)
  have hquot : 2 ^ 192 / 2 ^ 97 = 2 ^ 95 :=
    Nat.pow_div (by decide : 97 ≤ 192) (by decide : 0 < 2)
  rw [two_pow_96_mul]
  have hexact := Rounding.divideNat_exact .up (2 ^ 192) (2 ^ 97) hpos hdiv
  rw [hquot] at hexact
  exact hexact

theorem ordinary_den : numerator1 L1 + product amt1 sqrtP_Q96 = 2 ^ 97 := by
  rw [ordinary_numerator1, ordinary_product, two_pow_96_add]

theorem ordinary_wrap :
    wrap256 (numerator1 L1 + product amt1 sqrtP_Q96) =
      numerator1 L1 + product amt1 sqrtP_Q96 :=
  Nat.mod_eq_of_lt (ordinary_den ▸ two_pow_97_lt_256)

theorem ordinary_mulDiv :
    Rounding.mulDiv (w := 256) .up (numerator1Word L1) (widen160 sqrtP_Q96)
      (wrapWord (numerator1 L1 + product amt1 sqrtP_Q96)).value =
    .ok ⟨2 ^ 95, Nat.lt_trans two_pow_95_lt_160 two_pow_160_lt_256⟩ := by
  rw [Rounding.mulDiv_ok_iff]
  have hv1 : (numerator1Word L1).value = 2 ^ 96 := ordinary_numerator1
  have hv2 : (widen160 sqrtP_Q96).value = 2 ^ 96 := sqrtP_Q96_value
  have hv3 : (wrapWord (numerator1 L1 + product amt1 sqrtP_Q96)).value = 2 ^ 97 := by
    change wrap256 (numerator1 L1 + product amt1 sqrtP_Q96) = 2 ^ 97
    rw [ordinary_wrap, ordinary_den]
  rw [hv1, hv2, hv3]
  exact ordinary_divup

theorem ordinary_liftMulDiv :
    mulDivRoundingUp (numerator1Word L1) (widen160 sqrtP_Q96)
      (wrapWord (numerator1 L1 + product amt1 sqrtP_Q96)) =
    .ok ⟨2 ^ 95, Nat.lt_trans two_pow_95_lt_160 two_pow_160_lt_256⟩ := by
  rw [mulDivRoundingUp, liftMulDiv_ok_iff]
  exact ordinary_mulDiv

theorem library_ordinary_add : libraryWord sqrtP_Q96 L1 amt1 true = .ok postWord := by
  have hp : Nat.blt (product amt1 sqrtP_Q96) (2 ^ 256) = true := by
    rw [Nat.blt_eq]
    exact ordinary_product_fit
  have hble : Nat.ble (numerator1 L1)
      (wrap256 (numerator1 L1 + product amt1 sqrtP_Q96)) = true := by
    rw [Nat.ble_eq, ordinary_wrap, ordinary_numerator1, ordinary_product]
    exact Nat.le_add_right _ _
  have hprim : addPrimary sqrtP_Q96 L1 amt1 = .ok postWord := by
    unfold addPrimary
    rw [ordinary_liftMulDiv]
    apply congrArg Except.ok
    apply Word.ext
    exact bareToUint160_value_of_lt _ two_pow_95_lt_160
  unfold libraryWord getNextSqrtPriceFromAmount0RoundingUp
  rw [if_neg amt1_pos, hp, hble]
  exact hprim

theorem library_identity_zero : libraryWord sqrtP_Q96 L1 amt0 true = .ok sqrtP_Q96 := by
  unfold libraryWord getNextSqrtPriceFromAmount0RoundingUp
  simp [amt0]

theorem lift_scale_one (w : U160) : (lift w).amount = (w.value : ℚ) := by
  simp [lift, Quantity.toQuantity_amount, scale1]

def preQ : ℚ := (2 ^ 96 : Nat)
def postQ : ℚ := (2 ^ 95 : Nat)

theorem preQ_nonneg : 0 ≤ preQ := by
  unfold preQ
  exact_mod_cast Nat.zero_le _

theorem postQ_lt_preQ : postQ < preQ := by
  unfold preQ postQ
  exact_mod_cast (Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 95 < 96))

theorem ordinary_effect_nonzero : postQ - preQ ≠ 0 := by
  intro h
  have := sub_eq_zero.mp h
  exact (ne_of_gt postQ_lt_preQ) this.symm

theorem template_evaluate (pre post : ℚ)
    (ectx : EvalContext Party Asset Domain (quoteTemplate pre post).signature) :
    (quoteTemplate pre post).evaluate ectx = .ok (evaluated pre post) := rfl

theorem evaluated_effect (pre post : ℚ) :
    (evaluated pre post).effect (.quote, .quoteHolder, .quoteSqrtP) = post - pre := by
  simp [Evaluated.effect, evaluated]

theorem evaluated_writesOK (pre post : ℚ) :
    (evaluated pre post).writesOK = true := by
  simp only [Evaluated.writesOK, decide_eq_true_eq]
  intro cell hnin
  rcases cell with ⟨d, p, a⟩
  cases d; cases p; cases a
  simp [evaluated] at hnin

theorem party_card_one : Fintype.card Party = 1 := by decide

theorem evaluated_accountingOK (pre post : ℚ) :
    (evaluated pre post).accountingOK = true := by
  simp only [Evaluated.accountingOK, decide_eq_true_eq]
  intro d a
  cases d; cases a
  simp [Evaluated.effect, Evaluated.supply, evaluated, party_card_one]

theorem req_operation : req.operation = op := rfl

theorem registry_quote (pre post : ℚ) :
    registry pre post req.operation = some (quoteTemplate pre post) := by
  rw [req_operation]
  rfl

theorem evaluated_domainOK (pre post : ℚ) :
    (evaluated pre post).domainOK .quote = true := by
  simp only [Evaluated.domainOK, decide_eq_true_eq]
  refine ⟨by simp [evaluated], ?_, ?_⟩
  · intro cell hne
    rcases cell with ⟨d, p, a⟩
    cases d
    trivial
  · intro d a hne
    cases d
    trivial

theorem evaluated_stateReadsOK (pre post : ℚ) :
    (evaluated pre post).stateReadsOK = true := by
  simp [Evaluated.stateReadsOK, evaluated]

theorem evaluated_envReadsOK (pre post : ℚ) :
    (evaluated pre post).envReadsOK = true := by
  simp [Evaluated.envReadsOK, evaluated]

theorem has_invoke :
    hasAuthority store req.capabilityIds ctx op .invoke = true := by
  decide

theorem has_debit :
    hasAuthority store req.capabilityIds ctx op
      (.debit (.quote, .quoteHolder, .quoteSqrtP)) = true := by
  decide

theorem has_supply :
    hasAuthority store req.capabilityIds ctx op (.changeSupply .quote .quoteSqrtP) = true := by
  decide

theorem evaluated_debitsOK :
    (evaluated preQ postQ).debitsOK store req ctx = true := by
  simp only [Evaluated.debitsOK, decide_eq_true_eq]
  intro cell hlt
  rcases cell with ⟨d, p, a⟩
  cases d; cases p; cases a
  simpa [req_operation] using has_debit

theorem evaluated_suppliesOK :
    (evaluated preQ postQ).suppliesOK store req ctx = true := by
  simp only [Evaluated.suppliesOK, decide_eq_true_eq]
  intro d a hne
  cases d; cases a
  simpa [req_operation] using has_supply

theorem evaluated_nonneg (pre : State Party Asset Domain)
    (hpre : pre.balance (.quote, .quoteHolder, .quoteSqrtP) = preQ) :
    ∀ c, 0 ≤ pre.balance c + (evaluated preQ postQ).effect c := by
  intro c
  rcases c with ⟨d, p, a⟩
  cases d; cases p; cases a
  rw [evaluated_effect, hpre]
  have hsum : preQ + (postQ - preQ) = postQ := by ring
  rw [hsum]
  unfold postQ
  exact_mod_cast Nat.zero_le (2 ^ 95)

theorem evaluated_Valid :
    (evaluated preQ postQ).Valid store ctx req (preRegister preQ preQ_nonneg) := by
  refine ⟨rfl, evaluated_stateReadsOK preQ postQ, evaluated_envReadsOK preQ postQ,
    evaluated_domainOK preQ postQ, evaluated_debitsOK, evaluated_suppliesOK, ?_,
    evaluated_accountingOK preQ postQ, evaluated_writesOK preQ postQ⟩
  exact evaluated_nonneg _ rfl

theorem execute_ok_iff_quote (post : ExecutionResult Party Asset Domain) :
    execute (registry preQ postQ) store ctx env 0 req (preRegister preQ preQ_nonneg) = .ok post ↔
      (evaluated preQ postQ).Valid store ctx req (preRegister preQ preQ_nonneg) ∧
        post.capabilities = store ∧
        ∀ c, post.state.balance c = (preRegister preQ preQ_nonneg).balance c +
          (evaluated preQ postQ).effect c := by
  have hiff := execute_ok_iff (registry preQ postQ) store ctx env 0 req
    (preRegister preQ preQ_nonneg) post
  constructor
  · intro h
    obtain ⟨template, hr, hactor, hdom, harity, args, hargs, hauth, e, he, hv, hcap, hbal⟩ :=
      hiff.mp h
    have ht : template = quoteTemplate preQ postQ := by
      rw [registry_quote] at hr
      exact (Option.some.inj hr).symm
    subst ht
    have he' : e = evaluated preQ postQ := by
      have hte := template_evaluate preQ postQ ⟨preRegister preQ preQ_nonneg, env, ctx.principal,
        req.parties, args, 0⟩
      rw [he] at hte
      exact Except.ok.inj hte
    subst he'
    exact ⟨hv, hcap, hbal⟩
  · intro ⟨hv, hcap, hbal⟩
    refine hiff.mpr ⟨quoteTemplate preQ postQ, registry_quote preQ postQ, ?_, rfl, rfl,
      Args.nil, rfl, ?_, evaluated preQ postQ, template_evaluate preQ postQ
        ⟨preRegister preQ preQ_nonneg, env, .quoteHolder, [], Args.nil, 0⟩, hv, hcap, hbal⟩
    · simp [req]
    · simpa [req_operation] using has_invoke

theorem ordinary_add_nonzero_debit (post : ExecutionResult Party Asset Domain)
    (h : execute (registry preQ postQ) store ctx env 0 req
      (preRegister preQ preQ_nonneg) = .ok post) :
    post.state.balance (.quote, .quoteHolder, .quoteSqrtP) =
      (preRegister preQ preQ_nonneg).balance (.quote, .quoteHolder, .quoteSqrtP) + (postQ - preQ) ∧
      postQ - preQ ≠ 0 := by
  obtain ⟨_, _, hbal⟩ := (execute_ok_iff_quote post).mp h
  constructor
  · simpa [evaluated_effect] using hbal (.quote, .quoteHolder, .quoteSqrtP)
  · exact ordinary_effect_nonzero

/- Scope (not theorems): this adapter is a model-only quote register. It is not
Uniswap pool storage and not cash settlement. See `ordinary_add_nonzero_debit`. -/

end DefiKernel.ConcentratedLiquidity.Token0Bridge

