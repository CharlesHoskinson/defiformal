import DefiKernel.Vault.ConversionDomain
import DefiKernel.Vault.Adapter

/-! Native checked conversion drives the exact-rational deposit at raw scale 1.
Zero fees are explicit in the full sender debit and vault credit. This is not native-Ledger
or Solidity refinement; the Typed invocation uses the accepted fixed parties/capability layout. -/
namespace DefiKernel.Vault.ComputedDeposit
open DefiKernel.Arithmetic DefiKernel.Typed

abbrev P := Addr
abbrev A := Asset
abbrev D := Domain
abbrev W := ExecutionResult P A D
abbrev Store := CapabilityStore P A D
abbrev S := State P A D

def assetsQ (assets : Word 256) : ℚ :=
  (Arithmetic.Quantity.toQuantity Asset.usds 1 (by decide) assets).amount
def sharesQ (shares : Word 256) : ℚ :=
  (Arithmetic.Quantity.toQuantity Asset.susds 1 (by decide) shares).amount

theorem assetsQ_value (assets : Word 256) : assetsQ assets = (assets.value : ℚ) := by
  simp [assetsQ, Arithmetic.Quantity.toQuantity_amount]
theorem sharesQ_value (shares : Word 256) : sharesQ shares = (shares.value : ℚ) := by
  simp [sharesQ, Arithmetic.Quantity.toQuantity_amount]

/-- Arithmetic refusals and execution refusals are disjoint constructors. -/
def run (assets : Word 256) (chi : Word 192) (store : Store) (pre : S) :
    Except (Vault.Failure ⊕ Typed.Refusal) W := do
  let shares ← (convertToShares assets chi).mapError Sum.inl
  (Typed.execute (Adapter.registry (assetsQ assets) (sharesQ shares)) store
    Adapter.ctx Adapter.env 0 Adapter.req pre).mapError Sum.inr

/-- No conversion-success premise: native_success derives the computed Word from admissibility. -/
theorem run_eq_typed (assets : Word 256) (chi : Word 192)
    (domain : ConversionDomain.Admissible assets chi) (store : Store) (pre : S) :
    run assets chi store pre =
      (Typed.execute (Adapter.registry (assetsQ assets)
        (sharesQ (ConversionDomain.floorWord assets chi domain))) store
        Adapter.ctx Adapter.env 0 Adapter.req pre).mapError Sum.inr := by
  unfold run
  rw [ConversionDomain.native_success assets chi domain]
  rfl

theorem run_ok_iff_typed (assets : Word 256) (chi : Word 192)
    (domain : ConversionDomain.Admissible assets chi) (store : Store) (pre : S) (post : W) :
    run assets chi store pre = .ok post ↔
      Typed.execute (Adapter.registry (assetsQ assets)
        (sharesQ (ConversionDomain.floorWord assets chi domain))) store
        Adapter.ctx Adapter.env 0 Adapter.req pre = .ok post := by
  rw [run_eq_typed assets chi domain store pre]
  cases Typed.execute (Adapter.registry (assetsQ assets)
    (sharesQ (ConversionDomain.floorWord assets chi domain))) store
    Adapter.ctx Adapter.env 0 Adapter.req pre <;> simp [Except.mapError]

/-- Logical characterization of the actual Typed checks, with invoke authority kept explicit. -/
theorem typed_ok_iff (assets shares : ℚ) (store : Store) (pre : S) (post : W) :
    Typed.execute (Adapter.registry assets shares) store Adapter.ctx Adapter.env 0 Adapter.req pre =
      .ok post ↔
    hasAuthority store Adapter.req.capabilityIds Adapter.ctx Adapter.depositOp .invoke = true ∧
      (Adapter.evaluated assets shares).Valid store Adapter.ctx Adapter.req pre ∧
      post.capabilities = store ∧
      ∀ c, post.state.balance c = pre.balance c + (Adapter.evaluated assets shares).effect c := by
  have correspondence := Typed.execute_ok_iff (Adapter.registry assets shares) store
    Adapter.ctx Adapter.env 0 Adapter.req pre post
  constructor
  · intro success
    obtain ⟨template, registered, actor, dom, arity, args, checked, invoke, e, evaluated,
      valid, capabilities, balances⟩ := correspondence.mp success
    have templateEq : template = Adapter.depositTemplate assets shares := by
      rw [Adapter.registry_deposit] at registered
      exact (Option.some.inj registered).symm
    subst template
    have evaluatedEq : e = Adapter.evaluated assets shares := by
      have expected := Adapter.template_evaluate assets shares
        ⟨pre, Adapter.env, Adapter.ctx.principal, Adapter.req.parties, args, 0⟩
      rw [evaluated] at expected
      exact Except.ok.inj expected
    subst e
    exact ⟨by simpa [Adapter.req_operation] using invoke, valid, capabilities, balances⟩
  · rintro ⟨invoke, valid, capabilities, balances⟩
    apply correspondence.mpr
    refine ⟨Adapter.depositTemplate assets shares, Adapter.registry_deposit assets shares,
      ?_, rfl, rfl, Args.nil, rfl, ?_, Adapter.evaluated assets shares, ?_,
      valid, capabilities, balances⟩
    · simp [Adapter.req]
    · simpa [Adapter.req_operation] using invoke
    · exact Adapter.template_evaluate assets shares
        ⟨pre, Adapter.env, .S, [], Args.nil, 0⟩

/-- Quantified Word-to-rational transition correspondence over the entire arithmetic domain. -/
theorem execute_ok_iff_computed (assets : Word 256) (chi : Word 192)
    (domain : ConversionDomain.Admissible assets chi) (store : Store) (pre : S) (post : W) :
    run assets chi store pre = .ok post ↔
      hasAuthority store Adapter.req.capabilityIds Adapter.ctx Adapter.depositOp .invoke = true ∧
      (Adapter.evaluated (assetsQ assets) (sharesQ (ConversionDomain.floorWord assets chi domain))).Valid
        store Adapter.ctx Adapter.req pre ∧ post.capabilities = store ∧
      ∀ c, post.state.balance c = pre.balance c +
        (Adapter.evaluated (assetsQ assets)
          (sharesQ (ConversionDomain.floorWord assets chi domain))).effect c :=
  (run_ok_iff_typed assets chi domain store pre post).trans (typed_ok_iff _ _ store pre post)

/-- Full asset debit equals full vault credit: this model charges zero fees. -/
theorem zero_fee_effects (assets : Word 256) (chi : Word 192)
    (domain : ConversionDomain.Admissible assets chi) (store : Store) (pre : S) (post : W)
    (success : run assets chi store pre = .ok post) :
    pre.balance (.vault, .S, .usds) - post.state.balance (.vault, .S, .usds) = assets.value ∧
      post.state.balance (.vault, .vault, .usds) - pre.balance (.vault, .vault, .usds) = assets.value ∧
      post.state.balance (.vault, .R, .susds) - pre.balance (.vault, .R, .susds) =
        (ConversionDomain.floorWord assets chi domain).value := by
  obtain ⟨_, _, _, balances⟩ := (execute_ok_iff_computed assets chi domain store pre post).mp success
  have sender := balances (.vault, .S, .usds)
  have vault := balances (.vault, .vault, .usds)
  have receiver := balances (.vault, .R, .susds)
  rw [Adapter.sender_usds_effect, assetsQ_value] at sender
  rw [Adapter.vault_usds_effect, assetsQ_value] at vault
  rw [Adapter.receiver_susds_effect, sharesQ_value] at receiver
  constructor
  · linarith
  · constructor <;> linarith

/-- Every arithmetic error remains distinct from every Typed execution refusal. -/
theorem arithmetic_refusal_iff (assets : Word 256) (chi : Word 192)
    (store : Store) (pre : S) (failure : Vault.Failure) :
    run assets chi store pre = .error (Sum.inl failure) ↔
      convertToShares assets chi = .error failure := by
  unfold run
  cases converted : convertToShares assets chi with
  | error native => simp [Except.mapError, bind, Except.bind]
  | ok shares =>
    cases executed : Typed.execute (Adapter.registry (assetsQ assets) (sharesQ shares)) store
      Adapter.ctx Adapter.env 0 Adapter.req pre <;>
      simp [executed, Except.mapError, bind, Except.bind]

theorem arithmetic_errors (assets : Word 256) (chi : Word 192)
    (store : Store) (pre : S) (failure : Vault.Failure) :
    run assets chi store pre = .error (Sum.inl failure) ↔
      (2 ^ 256 ≤ assets.value * RAY ∧ failure = .mulOverflow) ∨
      (assets.value * RAY < 2 ^ 256 ∧ chi.value = 0 ∧ failure = .divisionByZero) :=
  (arithmetic_refusal_iff assets chi store pre failure).trans
    (ConversionDomain.native_error_iff assets chi failure)

theorem typed_refusal_iff (assets : Word 256) (chi : Word 192)
    (domain : ConversionDomain.Admissible assets chi) (store : Store) (pre : S)
    (reason : Typed.Refusal) :
    run assets chi store pre = .error (Sum.inr reason) ↔
      Typed.execute (Adapter.registry (assetsQ assets)
        (sharesQ (ConversionDomain.floorWord assets chi domain))) store
        Adapter.ctx Adapter.env 0 Adapter.req pre = .error reason := by
  rw [run_eq_typed assets chi domain store pre]
  cases Typed.execute (Adapter.registry (assetsQ assets)
    (sharesQ (ConversionDomain.floorWord assets chi domain))) store
    Adapter.ctx Adapter.env 0 Adapter.req pre <;> simp [Except.mapError]

theorem assets_nonneg (assets : Word 256) : 0 ≤ assetsQ assets := by
  rw [assetsQ_value]
  exact_mod_cast Nat.zero_le assets.value
theorem shares_nonneg (shares : Word 256) : 0 ≤ sharesQ shares := by
  rw [sharesQ_value]
  exact_mod_cast Nat.zero_le shares.value

def fundedPre (assets : Word 256) : S := Adapter.fundedState (assetsQ assets) (assets_nonneg assets)
def fundedPost (assets : Word 256) (chi : Word 192)
    (domain : ConversionDomain.Admissible assets chi) : W :=
  ⟨Adapter.honestPost (assetsQ assets) (sharesQ (ConversionDomain.floorWord assets chi domain))
    (assets_nonneg assets) (shares_nonneg _), Adapter.store⟩

/-- Constructive success for every admissible amount/rate, with funded prestate and real grants. -/
theorem funded_success (assets : Word 256) (chi : Word 192)
    (domain : ConversionDomain.Admissible assets chi) :
    run assets chi Adapter.store (fundedPre assets) = .ok (fundedPost assets chi domain) := by
  apply (execute_ok_iff_computed assets chi domain Adapter.store (fundedPre assets)
    (fundedPost assets chi domain)).mpr
  refine ⟨Adapter.has_invoke, ?_, rfl, ?_⟩
  · apply Adapter.evaluated_Valid _ _ (assets_nonneg assets) (shares_nonneg _)
    · exact Adapter.funded_pre_S _ _
    · exact Adapter.funded_pre_other _ _
  · intro c
    rcases c with ⟨d, p, a⟩
    cases d; cases p <;> cases a <;>
      simp [fundedPost, fundedPre, Adapter.honestPost, Adapter.fundedState,
        Adapter.evaluated_effect, Adapter.netEffect]

theorem wadDomain : ConversionDomain.Admissible Adapter.libraryAssets rayChi :=
  ⟨by simpa [rayChi] using RAY_pos,
    by simpa only [rayWord_value] using Adapter.library_prod_lt⟩

theorem wad_floorWord : ConversionDomain.floorWord Adapter.libraryAssets rayChi wadDomain =
    Adapter.librarySharesWord := by
  apply Except.ok.inj
  exact (ConversionDomain.native_success Adapter.libraryAssets rayChi wadDomain).symm.trans
    Adapter.library_convert

/-- The historical fixed-WAD adapter is a specialization of the quantified computed transition. -/
theorem fixed_wad_corollary (store : Store) (pre : S) :
    run Adapter.libraryAssets rayChi store pre =
      (Typed.execute (Adapter.registry Adapter.wadQ Adapter.sharesQ) store
        Adapter.ctx Adapter.env 0 Adapter.req pre).mapError Sum.inr := by
  rw [run_eq_typed Adapter.libraryAssets rayChi wadDomain store pre, wad_floorWord]
  have input : assetsQ Adapter.libraryAssets = Adapter.wadQ := by
    rw [assetsQ_value, Adapter.wadQ_from_library]
    simp [Adapter.scale1]
  have output : sharesQ Adapter.librarySharesWord = Adapter.sharesQ := by
    rw [sharesQ_value, Adapter.sharesQ_from_library]
    simp [Adapter.scale1]
  rw [input, output]

/-- Native checked success, the exact-rational floor interval, and equality of executable transitions.
The shares are computed, amounts/rates quantified, raw scale 1, and fees remain zero by zero_fee_effects. -/
theorem word_rational_correspondence (assets : Word 256) (chi : Word 192)
    (domain : ConversionDomain.Admissible assets chi) (store : Store) (pre : S) :
    convertToShares assets chi = .ok (ConversionDomain.floorWord assets chi domain) ∧
      (sharesQ (ConversionDomain.floorWord assets chi domain) ≤
          assetsQ assets * RAY / chi.value ∧
        assetsQ assets * RAY / chi.value < sharesQ (ConversionDomain.floorWord assets chi domain) + 1) ∧
      run assets chi store pre =
        (Typed.execute (Adapter.registry (assetsQ assets)
          (sharesQ (ConversionDomain.floorWord assets chi domain))) store
          Adapter.ctx Adapter.env 0 Adapter.req pre).mapError Sum.inr := by
  refine ⟨ConversionDomain.native_success assets chi domain, ?_,
    run_eq_typed assets chi domain store pre⟩
  simpa only [sharesQ_value, assetsQ_value] using
    ConversionDomain.rational_floor_interval assets chi domain

end DefiKernel.Vault.ComputedDeposit
