import DefiKernel.Typed.Transition
import DefiKernel.Vault.Operations
import DefiKernel.Arithmetic.Quantity
import DefiKernel.Arithmetic.Reference

/-! Honest vault deposit template derived from a successful library conversion.
`e.Valid` is a precondition on the pre-state. Post equality is a separate `execute_ok_iff` conjunct. -/
namespace DefiKernel.Vault.Adapter
open DefiKernel.Typed
open DefiKernel.Vault
open DefiKernel.Arithmetic

abbrev P := Addr
abbrev A := Asset
abbrev D := Domain

def depositOp : OperationId := ⟨0⟩
def wadQ : ℚ := (WAD : Nat)

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
  (if cell = (.vault, .S, .usds) then -assets else 0) +
    (if cell = (.vault, .vault, .usds) then assets else 0) +
    (if cell = (.vault, .R, .susds) then shares else 0)

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

def noCreditCandidate (assets shares : ℚ) (h : 0 ≤ assets) (hs : 0 ≤ shares) : State P A D where
  balance
    | (.vault, .S, .usds) => 0
    | (.vault, .vault, .usds) => 0
    | (.vault, .R, .susds) => shares
    | _ => 0
  nonneg := by
    intro c
    rcases c with ⟨d, p, a⟩
    cases d; cases p <;> cases a <;> simp [h, hs]

-- BEGIN PROOFS

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
  simp [hnin.1, hnin.2.1, hnin.2.2]

theorem evaluated_accountingOK (assets shares : ℚ) :
    (evaluated assets shares).accountingOK = true := by
  simp only [Evaluated.accountingOK, decide_eq_true_eq]
  intro d a
  cases d; cases a <;> simp [Evaluated.effect, Evaluated.supply, evaluated]

theorem evaluated_domainOK (assets shares : ℚ) :
    (evaluated assets shares).domainOK .vault = true := by
  simp only [Evaluated.domainOK, decide_eq_true_eq]
  refine ⟨by simp [evaluated], ?_, ?_⟩
  · intro cell hne
    rcases cell with ⟨d, p, a⟩
    cases d
    rfl
  · intro d a hne
    cases d
    rfl

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
    simpa using has_debit_S
  · by_cases hV : cell = (.vault, .vault, .usds)
    · subst hV
      simp at hlt
      exact (not_lt.mpr hassets hlt).elim
    · by_cases hR : cell = (.vault, .R, .susds)
      · subst hR
        simp at hlt
        exact (not_lt.mpr hshares hlt).elim
      · simp [hS, hV, hR] at hlt

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
    exact has_supply_susds

theorem wad_nonneg : 0 ≤ wadQ := by
  unfold wadQ WAD
  exact_mod_cast Nat.zero_le _

theorem wad_pos : 0 < wadQ := by
  unfold wadQ WAD
  norm_num

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
      · simp [hS, hV, hR, hpre0 c hS]

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
    (evaluated wadQ wadQ).Valid store ctx req (fundedState wadQ wad_nonneg) :=
  evaluated_Valid wadQ wadQ wad_nonneg wad_nonneg _ (funded_pre_S wadQ wad_nonneg)
    (funded_pre_other wadQ wad_nonneg)

theorem execute_ok_iff_deposit (post : ExecutionResult P A D) :
    execute (registry wadQ wadQ) store ctx env 0 req (fundedState wadQ wad_nonneg) = .ok post ↔
      (evaluated wadQ wadQ).Valid store ctx req (fundedState wadQ wad_nonneg) ∧
        post.capabilities = store ∧
        ∀ c, post.state.balance c = (fundedState wadQ wad_nonneg).balance c +
          (evaluated wadQ wadQ).effect c := by
  have hiff := execute_ok_iff (registry wadQ wadQ) store ctx env 0 req
    (fundedState wadQ wad_nonneg) post
  constructor
  · intro h
    obtain ⟨template, hr, hactor, hdom, harity, args, hargs, hauth, e, he, hv, hcap, hbal⟩ :=
      hiff.mp h
    have ht : template = depositTemplate wadQ wadQ := by
      simp [registry, depositOp] at hr
      exact hr.symm
    subst ht
    have he' : e = evaluated wadQ wadQ := by
      have := template_evaluate wadQ wadQ ⟨fundedState wadQ wad_nonneg, env, ctx.principal,
        req.parties, args, 0⟩
      simp [he] at this
      exact this.symm
    subst he'
    exact ⟨hv, hcap, hbal⟩
  · intro ⟨hv, hcap, hbal⟩
    refine hiff.mpr ?_
    refine ⟨depositTemplate wadQ wadQ, ?_, ?_, rfl, rfl, Args.nil, rfl, has_invoke,
      evaluated wadQ wadQ, ?_, hv, hcap, hbal⟩
    · simp [registry, depositOp]
    · simp [req]
    · exact template_evaluate wadQ wadQ ⟨fundedState wadQ wad_nonneg, env, .S, [], Args.nil, 0⟩

theorem positive_credit (post : ExecutionResult P A D)
    (h : execute (registry wadQ wadQ) store ctx env 0 req (fundedState wadQ wad_nonneg) = .ok post) :
    post.state.balance (.vault, .vault, .usds) =
      (fundedState wadQ wad_nonneg).balance (.vault, .vault, .usds) + wadQ := by
  obtain ⟨_, _, hbal⟩ := (execute_ok_iff_deposit post).mp h
  simpa [vault_usds_effect] using hbal (.vault, .vault, .usds)

theorem no_credit_mismatch :
    ¬ ∀ c, (noCreditCandidate wadQ wadQ wad_nonneg wad_nonneg).balance c =
      (fundedState wadQ wad_nonneg).balance c + (evaluated wadQ wadQ).effect c := by
  intro h
  have hv := h (.vault, .vault, .usds)
  simp [noCreditCandidate, fundedState, vault_usds_effect] at hv
  exact (ne_of_gt wad_pos) hv.symm

theorem no_credit_is_observation :
    (evaluated wadQ wadQ).Valid store ctx req (fundedState wadQ wad_nonneg) ∧
      ¬ ∀ c, (noCreditCandidate wadQ wadQ wad_nonneg wad_nonneg).balance c =
        (fundedState wadQ wad_nonneg).balance c + (evaluated wadQ wadQ).effect c :=
  ⟨wad_Valid, no_credit_mismatch⟩

end DefiKernel.Vault.Adapter
