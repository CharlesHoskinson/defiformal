import DefiKernel.Typed.Transition
import DefiKernel.Vault.Operations
import DefiKernel.Arithmetic.Quantity
import DefiKernel.Arithmetic.Reference
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.Ring

/-! Honest vault deposit template derived from a successful library conversion.
`e.Valid` is a precondition on the pre-state.
Post equality is a separate `execute_ok_iff` conjunct. -/
namespace DefiKernel.Vault.Adapter
open DefiKernel.Typed
open DefiKernel.Vault
open DefiKernel.Arithmetic

abbrev P := Addr
abbrev A := Asset
abbrev D := Domain

def depositOp : OperationId := ⟨0⟩

/-- D0 library input. Template quantities are this word after checked conversion. -/
def libraryAssets : Word 256 := ⟨WAD, WAD_lt_u256⟩
def scale1 : ℚ := 1
theorem scale1_pos : (0 : ℚ) < scale1 := by decide

def wadQ : ℚ :=
  (Quantity.toQuantity (A := Asset) Asset.usds scale1 scale1_pos libraryAssets).amount

/-- Share word is the D0 conversion output; equal to `libraryAssets` after the proof below. -/
def librarySharesWord : Word 256 := libraryAssets
def sharesQ : ℚ :=
  (Quantity.toQuantity (A := Asset) Asset.susds scale1 scale1_pos librarySharesWord).amount

def depositTemplate (assets shares : ℚ) : Template P A D where
  signature := []
  domain := .vault
  partyArity := 0
  guard := .lit true
  deltas := [
    ⟨.usds, ⟨.vault, .literal .S⟩, .lit (-assets)⟩,
    ⟨.usds, ⟨.vault, .literal .vault⟩, .lit assets⟩,
    ⟨.susds, ⟨.vault, .literal .R⟩, .lit shares⟩]
  supplyDeltas := [
    ⟨.vault, .usds, .lit 0⟩,
    ⟨.vault, .susds, .lit shares⟩]
  stateReads := []
  envReads := []
  writes := [
    ⟨.usds, ⟨.vault, .literal .S⟩⟩,
    ⟨.usds, ⟨.vault, .literal .vault⟩⟩,
    ⟨.susds, ⟨.vault, .literal .R⟩⟩]

def registry (assets shares : ℚ) : Registry P A D :=
  fun op => if op = depositOp then some (depositTemplate assets shares) else none

def evaluated (assets shares : ℚ) : Evaluated P A D :=
  ⟨true,
    [((.vault, .S, .usds), -assets),
      ((.vault, .vault, .usds), assets),
      ((.vault, .R, .susds), shares)],
    [((.vault, .usds), 0), ((.vault, .susds), shares)],
    [], [], [], [],
    [(.vault, .S, .usds), (.vault, .vault, .usds), (.vault, .R, .susds)]⟩

def netEffect (assets shares : ℚ) (cell : Cell P A D) : ℚ :=
  (if (.vault, .S, .usds) = cell then -assets else 0) +
    (if (.vault, .vault, .usds) = cell then assets else 0) +
    (if (.vault, .R, .susds) = cell then shares else 0)

def store : CapabilityStore P A D :=
  ⟨[⟨⟨.S, .vault, depositOp, .invoke⟩, true⟩,
    ⟨⟨.S, .vault, depositOp, .debit (.vault, .S, .usds)⟩, true⟩,
    ⟨⟨.S, .vault, depositOp, .changeSupply .vault .susds⟩, true⟩]⟩

def ctx : InvocationContext P D := ⟨.S, .vault⟩
def env : Environment A D := fun _ => none
def req : Request P A D := ⟨depositOp, [], [], [⟨0⟩, ⟨1⟩, ⟨2⟩], none⟩

def fundedState (assets : ℚ) (h : 0 ≤ assets) : State P A D where
  balance
    | (.vault, .S, .usds) => assets
    | _ => 0
  nonneg := by
    intro c
    rcases c with ⟨d, p, a⟩
    cases d; cases p <;> cases a <;> simp [h]

def honestPost (assets shares : ℚ) (h : 0 ≤ assets) (hs : 0 ≤ shares) : State P A D where
  balance
    | (.vault, .S, .usds) => 0
    | (.vault, .vault, .usds) => assets
    | (.vault, .R, .susds) => shares
    | _ => 0
  nonneg := by
    intro c
    rcases c with ⟨d, p, a⟩
    cases d; cases p <;> cases a <;> simp [h, hs]

def noCreditCandidate (assets shares : ℚ) (_h : 0 ≤ assets) (hs : 0 ≤ shares) : State P A D where
  balance
    | (.vault, .S, .usds) => 0
    | (.vault, .vault, .usds) => 0
    | (.vault, .R, .susds) => shares
    | _ => 0
  nonneg := by
    intro c
    rcases c with ⟨d, p, a⟩
    cases d; cases p <;> cases a <;> simp [hs]

-- BEGIN PROOFS

theorem req_operation : req.operation = depositOp := rfl

theorem registry_deposit (assets shares : ℚ) :
    registry assets shares req.operation = some (depositTemplate assets shares) := by
  rw [req_operation]
  rfl

theorem template_evaluate (assets shares : ℚ)
    (ectx : EvalContext P A D (depositTemplate assets shares).signature) :
    (depositTemplate assets shares).evaluate ectx = .ok (evaluated assets shares) := rfl

theorem evaluated_effect (assets shares : ℚ) (cell : Cell P A D) :
    (evaluated assets shares).effect cell = netEffect assets shares cell := by
  simp [Evaluated.effect, evaluated, netEffect, add_assoc]

theorem vault_usds_effect (assets shares : ℚ) :
    (evaluated assets shares).effect (.vault, .vault, .usds) = assets := by
  simp [evaluated_effect, netEffect]

theorem sender_usds_effect (assets shares : ℚ) :
    (evaluated assets shares).effect (.vault, .S, .usds) = -assets := by
  simp [evaluated_effect, netEffect]

theorem receiver_susds_effect (assets shares : ℚ) :
    (evaluated assets shares).effect (.vault, .R, .susds) = shares := by
  simp [evaluated_effect, netEffect]

theorem evaluated_supply_susds (assets shares : ℚ) :
    (evaluated assets shares).supply .vault .susds = shares := by
  simp [Evaluated.supply, evaluated]

theorem evaluated_supply_usds (assets shares : ℚ) :
    (evaluated assets shares).supply .vault .usds = 0 := by
  simp [Evaluated.supply, evaluated]

theorem evaluated_writesOK (assets shares : ℚ) :
    (evaluated assets shares).writesOK = true := by
  simp only [Evaluated.writesOK, decide_eq_true_eq]
  intro cell hnin
  simp [evaluated, List.mem_cons, List.not_mem_nil, or_false, not_or] at hnin
  rw [evaluated_effect, netEffect]
  simp [Ne.symm hnin.1, Ne.symm hnin.2.1, Ne.symm hnin.2.2]

theorem sum_if_party (a : Addr) (b : ℚ) :
    ∑ p : Addr, (if a = p then b else 0) = b := by
  simp [Finset.sum_ite_eq, Finset.mem_univ]

theorem evaluated_accountingOK (assets shares : ℚ) :
    (evaluated assets shares).accountingOK = true := by
  simp only [Evaluated.accountingOK, decide_eq_true_eq]
  intro d a
  cases d
  cases a with
  | usds =>
    simp [Evaluated.effect, Evaluated.supply, evaluated]
    rw [Finset.sum_add_distrib, sum_if_party, sum_if_party]
    ring
  | susds =>
    simp [Evaluated.effect, Evaluated.supply, evaluated]

theorem evaluated_domainOK (assets shares : ℚ) :
    (evaluated assets shares).domainOK .vault = true := by
  simp only [Evaluated.domainOK, decide_eq_true_eq]
  refine ⟨by simp [evaluated], ?_, ?_⟩
  · intro cell hne
    rcases cell with ⟨d, p, a⟩
    cases d
    trivial
  · intro d a hne
    cases d
    trivial

theorem evaluated_stateReadsOK (assets shares : ℚ) :
    (evaluated assets shares).stateReadsOK = true := by
  simp [Evaluated.stateReadsOK, evaluated]

theorem evaluated_envReadsOK (assets shares : ℚ) :
    (evaluated assets shares).envReadsOK = true := by
  simp [Evaluated.envReadsOK, evaluated]

theorem has_invoke :
    hasAuthority store req.capabilityIds ctx depositOp .invoke = true := by
  decide

theorem has_debit_S :
    hasAuthority store req.capabilityIds ctx depositOp (.debit (.vault, .S, .usds)) = true := by
  decide

theorem has_supply_susds :
    hasAuthority store req.capabilityIds ctx depositOp (.changeSupply .vault .susds) = true := by
  decide

theorem evaluated_debitsOK (assets shares : ℚ) (hassets : 0 ≤ assets) (hshares : 0 ≤ shares) :
    (evaluated assets shares).debitsOK store req ctx = true := by
  simp only [Evaluated.debitsOK, decide_eq_true_eq]
  intro cell hlt
  rw [evaluated_effect, netEffect] at hlt
  by_cases hS : cell = (.vault, .S, .usds)
  · subst hS
    simpa [req_operation] using has_debit_S
  · by_cases hV : cell = (.vault, .vault, .usds)
    · subst hV
      simp at hlt
      exact (not_lt.mpr hassets hlt).elim
    · by_cases hR : cell = (.vault, .R, .susds)
      · subst hR
        simp at hlt
        exact (not_lt.mpr hshares hlt).elim
      · simp [Ne.symm hS, Ne.symm hV, Ne.symm hR] at hlt

theorem evaluated_suppliesOK (assets shares : ℚ) :
    (evaluated assets shares).suppliesOK store req ctx = true := by
  simp only [Evaluated.suppliesOK, decide_eq_true_eq]
  intro d a hne
  cases d
  cases a with
  | usds =>
    rw [evaluated_supply_usds] at hne
    exact (hne rfl).elim
  | susds =>
    simpa [req_operation] using has_supply_susds

theorem wad_mul_ray_lt_u256 : WAD * RAY < 2 ^ 256 := by
  have hmul : WAD * RAY < 2 ^ 64 * 2 ^ 90 :=
    Nat.mul_lt_mul_of_lt_of_le WAD_lt_u64 (Nat.le_of_lt RAY_lt_u90)
      (Nat.pow_pos (by decide : 0 < 2))
  rw [← Nat.pow_add] at hmul
  exact Nat.lt_trans hmul
    (Nat.pow_lt_pow_right (by decide : 1 < 2) (by decide : 154 < 256))

theorem library_prod_lt :
    libraryAssets.value * rayWord.value < 2 ^ 256 := by
  change WAD * RAY < 2 ^ 256
  exact wad_mul_ray_lt_u256

theorem library_convert :
    convertToShares libraryAssets rayChi = .ok librarySharesWord := by
  have hchi : 0 < rayChi.value := by
    rw [rayChi_value]
    exact RAY_pos
  rw [convertToShares_ok libraryAssets rayChi librarySharesWord hchi library_prod_lt]
  have hdvd : rayChi.value ∣ libraryAssets.value * rayWord.value := by
    rw [rayChi_value, rayWord_value]
    change RAY ∣ WAD * RAY
    rw [Nat.mul_comm]
    exact Nat.dvd_mul_right RAY WAD
  have hexact := Rounding.divideNat_exact .down
    (libraryAssets.value * rayWord.value) rayChi.value hchi hdvd
  have hquot : libraryAssets.value * rayWord.value / rayChi.value = librarySharesWord.value := by
    rw [rayChi_value, rayWord_value]
    change WAD * RAY / RAY = WAD
    exact Nat.mul_div_left WAD RAY_pos
  rw [hquot] at hexact
  exact hexact

theorem wadQ_from_library : wadQ = (libraryAssets.value : ℚ) * scale1 :=
  Quantity.toQuantity_amount Asset.usds scale1 scale1_pos libraryAssets

theorem sharesQ_from_library : sharesQ = (librarySharesWord.value : ℚ) * scale1 :=
  Quantity.toQuantity_amount Asset.susds scale1 scale1_pos librarySharesWord

theorem sharesQ_eq_wadQ : sharesQ = wadQ := by
  rw [sharesQ_from_library, wadQ_from_library]
  rfl

theorem library_derivation :
    convertToShares libraryAssets rayChi = .ok librarySharesWord ∧
      wadQ = (libraryAssets.value : ℚ) * scale1 ∧
      sharesQ = (librarySharesWord.value : ℚ) * scale1 ∧
      0 < scale1 :=
  ⟨library_convert, wadQ_from_library, sharesQ_from_library, scale1_pos⟩

theorem wad_nonneg : 0 ≤ wadQ := by
  rw [wadQ_from_library, scale1]
  exact_mod_cast Nat.zero_le WAD

theorem wad_pos : 0 < wadQ := by
  rw [wadQ_from_library, scale1]
  exact_mod_cast (by
    unfold WAD
    exact Nat.pow_pos (by decide : 0 < 10) : 0 < WAD)

theorem shares_nonneg : 0 ≤ sharesQ := by
  rw [sharesQ_eq_wadQ]
  exact wad_nonneg

theorem evaluated_nonneg (assets shares : ℚ) (hassets : 0 ≤ assets) (hshares : 0 ≤ shares)
    (pre : State P A D) (hpre : pre.balance (.vault, .S, .usds) = assets)
    (hpre0 : ∀ c, c ≠ (.vault, .S, .usds) → pre.balance c = 0) :
    ∀ c, 0 ≤ pre.balance c + (evaluated assets shares).effect c := by
  intro c
  rw [evaluated_effect, netEffect]
  by_cases hS : c = (.vault, .S, .usds)
  · subst hS
    simp [hpre]
  · by_cases hV : c = (.vault, .vault, .usds)
    · subst hV
      simp [hpre0 (.vault, .vault, .usds) (by decide), hassets]
    · by_cases hR : c = (.vault, .R, .susds)
      · subst hR
        simp [hpre0 (.vault, .R, .susds) (by decide), hshares]
      · simp [Ne.symm hS, Ne.symm hV, Ne.symm hR, hpre0 c hS]

theorem evaluated_Valid (assets shares : ℚ) (hassets : 0 ≤ assets) (hshares : 0 ≤ shares)
    (pre : State P A D) (hpre : pre.balance (.vault, .S, .usds) = assets)
    (hpre0 : ∀ c, c ≠ (.vault, .S, .usds) → pre.balance c = 0) :
    (evaluated assets shares).Valid store ctx req pre := by
  refine ⟨rfl, evaluated_stateReadsOK assets shares, evaluated_envReadsOK assets shares,
    evaluated_domainOK assets shares, evaluated_debitsOK assets shares hassets hshares,
    evaluated_suppliesOK assets shares, ?_, evaluated_accountingOK assets shares,
    evaluated_writesOK assets shares⟩
  exact evaluated_nonneg assets shares hassets hshares pre hpre hpre0

theorem funded_pre_S (assets : ℚ) (h : 0 ≤ assets) :
    (fundedState assets h).balance (.vault, .S, .usds) = assets := rfl

theorem funded_pre_other (assets : ℚ) (h : 0 ≤ assets) (c : Cell P A D)
    (hc : c ≠ (.vault, .S, .usds)) :
    (fundedState assets h).balance c = 0 := by
  rcases c with ⟨d, p, a⟩
  cases d; cases p <;> cases a <;> simp [fundedState] at hc ⊢

theorem wad_Valid :
    (evaluated wadQ sharesQ).Valid store ctx req (fundedState wadQ wad_nonneg) :=
  evaluated_Valid wadQ sharesQ wad_nonneg shares_nonneg _ (funded_pre_S wadQ wad_nonneg)
    (funded_pre_other wadQ wad_nonneg)

/-- Specializes unchanged `Typed.execute_ok_iff` at library-derived D0 quantities. -/
theorem execute_ok_iff_deposit (post : ExecutionResult P A D) :
    execute (registry wadQ sharesQ) store ctx env 0 req (fundedState wadQ wad_nonneg) = .ok post ↔
      (evaluated wadQ sharesQ).Valid store ctx req (fundedState wadQ wad_nonneg) ∧
        post.capabilities = store ∧
        ∀ c, post.state.balance c = (fundedState wadQ wad_nonneg).balance c +
          (evaluated wadQ sharesQ).effect c := by
  have hiff := execute_ok_iff (registry wadQ sharesQ) store ctx env 0 req
    (fundedState wadQ wad_nonneg) post
  constructor
  · intro h
    obtain ⟨template, hr, hactor, hdom, harity, args, hargs, hauth, e, he, hv, hcap, hbal⟩ :=
      hiff.mp h
    have ht : template = depositTemplate wadQ sharesQ := by
      rw [registry_deposit] at hr
      exact (Option.some.inj hr).symm
    subst ht
    have he' : e = evaluated wadQ sharesQ := by
      have hte := template_evaluate wadQ sharesQ ⟨fundedState wadQ wad_nonneg, env, ctx.principal,
        req.parties, args, 0⟩
      rw [he] at hte
      exact Except.ok.inj hte
    subst he'
    exact ⟨hv, hcap, hbal⟩
  · intro ⟨hv, hcap, hbal⟩
    refine hiff.mpr ?_
    refine ⟨depositTemplate wadQ sharesQ, registry_deposit wadQ sharesQ, ?_, rfl, rfl,
      Args.nil, rfl, ?_, evaluated wadQ sharesQ, ?_, hv, hcap, hbal⟩
    · simp [req]
    · simpa [req_operation] using has_invoke
    · exact template_evaluate wadQ sharesQ ⟨fundedState wadQ wad_nonneg, env, .S, [], Args.nil, 0⟩

theorem positive_credit (post : ExecutionResult P A D)
    (h : execute (registry wadQ sharesQ) store ctx env 0 req
      (fundedState wadQ wad_nonneg) = .ok post) :
    post.state.balance (.vault, .vault, .usds) =
      (fundedState wadQ wad_nonneg).balance (.vault, .vault, .usds) + wadQ := by
  obtain ⟨_, _, hbal⟩ := (execute_ok_iff_deposit post).mp h
  simpa [vault_usds_effect] using hbal (.vault, .vault, .usds)

theorem no_credit_mismatch :
    ¬ ∀ c, (noCreditCandidate wadQ sharesQ wad_nonneg shares_nonneg).balance c =
      (fundedState wadQ wad_nonneg).balance c + (evaluated wadQ sharesQ).effect c := by
  intro h
  have hv := h (.vault, .vault, .usds)
  simp [noCreditCandidate, fundedState, vault_usds_effect] at hv
  exact (ne_of_gt wad_pos) hv.symm

theorem no_credit_is_observation :
    (evaluated wadQ sharesQ).Valid store ctx req (fundedState wadQ wad_nonneg) ∧
      ¬ ∀ c, (noCreditCandidate wadQ sharesQ wad_nonneg shares_nonneg).balance c =
        (fundedState wadQ wad_nonneg).balance c + (evaluated wadQ sharesQ).effect c :=
  ⟨wad_Valid, no_credit_mismatch⟩

end DefiKernel.Vault.Adapter
