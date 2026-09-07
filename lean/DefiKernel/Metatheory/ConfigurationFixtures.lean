import DefiKernel.Metatheory.ConfigurationGroups
import DefiKernel.Metatheory.OperatorLifting
import DefiKernel.Metatheory.Examples
import DefiKernel.Metatheory.OperatorFixtures

/-! Concrete extension witnesses. This proof-only module is excluded from runtime test imports.
The operator witnesses retain arbitrary boundaries, schedules and atomic policy; they do not
assert that every such input is admitted or succeeds. -/
namespace DefiKernel.Metatheory.ConfigurationFixtures
open Typed Composition Parallel
open DefiKernel.Metatheory.Examples

def references : ReferenceSet := ⟨{(⟨0⟩, ⟨10⟩)}, {⟨10⟩}⟩
def mainGroup : SeqGroup P A D :=
  .seq (.step (.invoke draw7)) (.seq (.step (.invoke consume3)) (.step (.invoke return1)))
def administrationGroup : SeqGroup P A D :=
  .seq (.step (.issue grantInvoke))
    (.seq (.step (.invoke adminMove))
      (.seq (.step (.revoke ⟨1⟩)) (.step (.invoke adminMove))))
def leftBranch : Branch P A D := [draw7, refuse6]
def rightBranch : Branch P A D := [return1]
def atomicReferences : ReferenceSet :=
  ⟨{(⟨100⟩, ⟨100⟩), (⟨101⟩, ⟨101⟩), (⟨108⟩, ⟨108⟩)}, {⟨100⟩, ⟨101⟩, ⟨108⟩}⟩

-- BEGIN PROOFS

/-- Changing the output declaration keeps the complete registry, not just one lookup. -/
theorem changedOutput_registry_remaining : cfg.registry = changedOutput.registry := rfl

theorem changedAdmin_registry_remaining : cfg.registry = changedAdmin.registry := rfl

theorem grantOnly_catalog_remaining : grantOnlyCfg.catalog = grantOnlyChanged.catalog := rfl

/-- The grant-only domain change preserves the invoked operation; operation 77 differs. -/
theorem grantOnly_invoked_registry_remaining :
    grantOnlyCfg.registry ⟨10⟩ = grantOnlyChanged.registry ⟨10⟩ := rfl

theorem changedRegistry_admins_remaining (domain : D) :
    cfg.domainAdmin domain = changedRegistry.domainAdmin domain := rfl

theorem changedOutput_admins_remaining (domain : D) :
    cfg.domainAdmin domain = changedOutput.domainAdmin domain := rfl

theorem grantOnly_admins_remaining (domain : D) :
    grantOnlyCfg.domainAdmin domain = grantOnlyChanged.domainAdmin domain := rfl

theorem atomic_extension_agreement :
    ConfigAgreement Atomic.Examples.atomCfg OperatorFixtures.extendedAtomic atomicReferences := by
  refine ⟨by decide, by decide, ?_, ?_, fun _ ↦ rfl⟩
  · intro op hop
    simp only [atomicReferences, Set.mem_insert_iff, Set.mem_singleton_iff] at hop
    rcases hop with rfl | rfl | rfl <;> rfl
  · intro component op hop
    simp only [atomicReferences, Set.mem_insert_iff, Set.mem_singleton_iff] at hop
    rcases hop with h | h | h <;> cases h <;> rfl

theorem atomic_draw_supported (q : ℚ) :
    SupportedStep atomicReferences (.invoke (Atomic.Examples.draw q)) := by
  exact ⟨Or.inl rfl, Or.inl rfl⟩

theorem atomic_repay_supported (q : ℚ) :
    SupportedStep atomicReferences (.invoke (Atomic.Examples.repay q)) := by
  exact ⟨Or.inr (Or.inl rfl), Or.inr (Or.inl rfl)⟩

theorem atomic_mint_supported :
    SupportedStep atomicReferences (.invoke Atomic.Examples.mintUSD) := by
  exact ⟨Or.inr (Or.inr rfl), Or.inr (Or.inr rfl)⟩

theorem atomic_settlement_branch_supported (q : ℚ) :
    SupportedBranch atomicReferences [Atomic.Examples.draw 7, Atomic.Examples.repay q] := by
  simp only [supportedBranch_cons, supportedBranch_nil, and_true]
  exact ⟨atomic_draw_supported _, atomic_repay_supported _⟩

theorem atomic_supply_branch_supported :
    SupportedBranch atomicReferences [Atomic.Examples.mintUSD] := by
  simp only [supportedBranch_cons, supportedBranch_nil, and_true]
  exact atomic_mint_supported

/-- Both exact repayment and the residual-bearing underpayment fixture use this agreement. -/
theorem atomic_settlement_extension (under : Bool) :
    OperatorFixtures.settleRun Atomic.Examples.atomCfg under =
      OperatorFixtures.settleRun OperatorFixtures.extendedAtomic under :=
  runAtomic_config_eq atomic_extension_agreement Atomic.Examples.atomBoundary 74
    Atomic.Examples.basePolicy Atomic.Examples.atomInitial _ [] [.left, .left]
    (atomic_settlement_branch_supported _) (supportedBranch_nil _)

/-- The actual supply-aborting input has an instantiated sufficient configuration premise. -/
theorem atomic_supply_extension :
    Atomic.runAtomic Atomic.Examples.atomCfg Atomic.Examples.atomBoundary 75
        Atomic.Examples.basePolicy Atomic.Examples.atomInitial
        [Atomic.Examples.mintUSD] [] [.left] =
      Atomic.runAtomic OperatorFixtures.extendedAtomic Atomic.Examples.atomBoundary 75
        Atomic.Examples.basePolicy Atomic.Examples.atomInitial
        [Atomic.Examples.mintUSD] [] [.left] :=
  runAtomic_config_eq atomic_extension_agreement Atomic.Examples.atomBoundary 75
    Atomic.Examples.basePolicy Atomic.Examples.atomInitial _ [] [.left]
    atomic_supply_branch_supported (supportedBranch_nil _)

theorem extension_agreement : ConfigAgreement cfg extendedCfg references := by
  refine ⟨by decide, by decide, ?_, ?_, fun _ ↦ rfl⟩
  · intro op hop
    have heq : op = ⟨10⟩ := hop
    subst op
    rfl
  · intro component op hop
    have heq : (component, op) = (⟨0⟩, ⟨10⟩) := hop
    cases heq
    rfl

theorem movement_supported (q : ℚ) (recipient : P) (ids : List CapabilityId) :
    SupportedStep references (.invoke (movement q recipient ids)) := by
  exact ⟨rfl, rfl⟩

theorem draw7_supported : SupportedStep references (.invoke draw7) := by
  exact ⟨rfl, rfl⟩

theorem consume3_supported : SupportedStep references (.invoke consume3) := by
  exact ⟨rfl, rfl⟩

theorem return1_supported : SupportedStep references (.invoke return1) := by
  exact ⟨rfl, rfl⟩

theorem refuse6_supported : SupportedStep references (.invoke refuse6) := by
  exact ⟨rfl, rfl⟩

theorem adminMove_supported : SupportedStep references (.invoke adminMove) := by
  exact ⟨rfl, rfl⟩

theorem grantInvoke_supported : SupportedStep references (.issue grantInvoke) := by rfl

theorem revoke_supported (id : CapabilityId) :
    SupportedStep (P := P) (A := A) (D := D) references (.revoke id) := by trivial

theorem mainGroup_supported : SupportedGroup references mainGroup := by
  simp only [mainGroup, supportedGroup_seq, supportedGroup_step]
  exact ⟨draw7_supported, consume3_supported, return1_supported⟩

theorem administrationGroup_supported : SupportedGroup references administrationGroup := by
  simp only [administrationGroup, supportedGroup_seq, supportedGroup_step]
  exact ⟨grantInvoke_supported, adminMove_supported, revoke_supported _, adminMove_supported⟩

theorem leftBranch_supported : SupportedBranch references leftBranch := by
  simp only [leftBranch, supportedBranch_cons, supportedBranch_nil, and_true]
  exact ⟨draw7_supported, refuse6_supported⟩

theorem rightBranch_supported : SupportedBranch references rightBranch := by
  simp only [rightBranch, supportedBranch_cons, supportedBranch_nil, and_true]
  exact return1_supported

/-- A nonempty output-consuming group preserves the entire actual cursor across extension. -/
theorem main_group_extension :
    runGroup cfg mainBoundary initial mainGroup =
      runGroup extendedCfg mainBoundary initial mainGroup :=
  runGroup_config_eq extension_agreement mainBoundary initial mainGroup mainGroup_supported

/-- The input cursor has history and index five; issuance, use and revocation continue it. -/
theorem administration_group_extension :
    runGroup cfg adminBoundary adminInitial administrationGroup =
      runGroup extendedCfg adminBoundary adminInitial administrationGroup :=
  runGroup_config_eq extension_agreement adminBoundary adminInitial administrationGroup
    administrationGroup_supported

theorem parallel_extension (boundaries : ParallelBoundary P A D) :
    runParallel cfg boundaries initial.world leftBranch rightBranch =
      runParallel extendedCfg boundaries initial.world leftBranch rightBranch :=
  runParallel_config_eq extension_agreement boundaries initial.world leftBranch rightBranch
    leftBranch_supported rightBranch_supported

theorem serialLR_extension (boundaries : ParallelBoundary P A D) :
    runSerialLR cfg boundaries initial.world leftBranch rightBranch =
      runSerialLR extendedCfg boundaries initial.world leftBranch rightBranch :=
  runSerialLR_config_eq extension_agreement boundaries initial.world leftBranch rightBranch
    leftBranch_supported rightBranch_supported

theorem serialRL_extension (boundaries : ParallelBoundary P A D) :
    runSerialRL cfg boundaries initial.world leftBranch rightBranch =
      runSerialRL extendedCfg boundaries initial.world leftBranch rightBranch :=
  runSerialRL_config_eq extension_agreement boundaries initial.world leftBranch rightBranch
    leftBranch_supported rightBranch_supported

theorem interleaving_extension (boundaries : ParallelBoundary P A D)
    (schedule : Interleaving.Schedule) :
    Interleaving.runInterleaving cfg boundaries initial.world leftBranch rightBranch schedule =
      Interleaving.runInterleaving extendedCfg boundaries initial.world
        leftBranch rightBranch schedule :=
  runInterleaving_config_eq extension_agreement boundaries initial.world leftBranch rightBranch
    schedule leftBranch_supported rightBranch_supported

theorem atomic_extension (boundaries : ParallelBoundary P A D) (label : Nat)
    (policy : Atomic.Policy P A D) (schedule : Interleaving.Schedule) :
    Atomic.runAtomic cfg boundaries label policy initial.world leftBranch rightBranch schedule =
      Atomic.runAtomic extendedCfg boundaries label policy initial.world
        leftBranch rightBranch schedule :=
  runAtomic_config_eq extension_agreement boundaries label policy initial.world leftBranch
    rightBranch schedule leftBranch_supported rightBranch_supported

end DefiKernel.Metatheory.ConfigurationFixtures
