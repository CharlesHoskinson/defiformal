import DefiKernel.Atomic.Examples
import DefiKernel.Atomic.Preservation
import DefiKernel.Atomic.Settlement
import DefiKernel.Interleaving.InterferenceFixtures

/-! Nonempty transient instances of the initialized invariant rule, with independently
checked negative witnesses for scalar clearing and unrestricted predicate frames. -/
namespace DefiKernel.Atomic.InvariantFixtures
open Typed Composition Parallel Interleaving Typed.Examples Atomic.Examples

def drawFootprint : Footprint P A D :=
  ⟨[usdVault, usdAlice, usdVault, usdAlice, usdVault],
    [usdVault, usdAlice, usdVault, usdAlice]⟩
def repayFootprint : Footprint P A D :=
  ⟨[usdAlice, usdVault, usdAlice, usdVault, usdVault],
    [usdAlice, usdVault, usdAlice, usdVault]⟩
def collateralInvariant (_ : BranchId) (s : State P A D) : Prop := s.balance collateral = 9
def unchangedCollateral (_ : BranchId) (pre post : State P A D) : Prop :=
  post.balance collateral = pre.balance collateral
def drawPrefix := Atomic.runPrefix atomCfg atomBoundary basePolicy atomInitial drawReturnLeft []
  [.left]
def unpaidInterleaving := Interleaving.runPrefix atomCfg atomBoundary atomInitial [draw 7] []
  [.left]
def unpaidAtomic := runAtomic atomCfg atomBoundary 8 basePolicy atomInitial [draw 7] [] [.left]

-- BEGIN PROOFS

theorem draw_analyzed (b : BranchId) (index : Nat) :
    analyzeInvocation atomCfg (atomBoundary b index) (draw 7) = .ok drawFootprint := by
  change analyzeInvocation atomCfg (atomBoundary .left 0) (draw 7) = .ok drawFootprint
  decide +kernel

theorem repay_analyzed (b : BranchId) (index : Nat) :
    analyzeInvocation atomCfg (atomBoundary b index) (repay 7) = .ok repayFootprint := by
  change analyzeInvocation atomCfg (atomBoundary .left 0) (repay 7) = .ok repayFootprint
  decide +kernel

theorem draw_return_local_obligation : LocalObligation atomCfg atomBoundary
    drawReturnLeft [] collateralInvariant unchangedCollateral := by
  intro b index inv selected history pre result initialized step
  suffices same : result.world.state.balance collateral = pre.state.balance collateral from
    ⟨same.trans initialized, same⟩
  cases b with
  | right => simp [selectBranch] at selected
  | left =>
    cases index with
    | zero =>
      simp only [selectBranch, drawReturnLeft, List.getElem?_cons_zero,
        Option.some.injEq] at selected
      subst inv
      exact Interleaving.InterferenceFixtures.sound_target_frame drawFootprint
        (draw_analyzed .left 0) step collateral (by decide)
    | succ n =>
      cases n with
      | zero =>
        simp only [selectBranch, drawReturnLeft, List.getElem?_cons_succ,
          List.getElem?_cons_zero, Option.some.injEq] at selected
        subst inv
        exact Interleaving.InterferenceFixtures.sound_target_frame repayFootprint
          (repay_analyzed .left 1) step collateral (by decide)
      | succ n => simp [selectBranch, drawReturnLeft] at selected

theorem collateral_cross : CrossInclusion unchangedCollateral unchangedCollateral := by
  intro b peer _ pre post same
  exact same

theorem collateral_stable : Stable collateralInvariant unchangedCollateral := by
  intro b pre post initialized same
  exact same.trans initialized

theorem collateral_initialized : ∀ b, collateralInvariant b atomInitial.state := by
  intro b
  change atomInitial.state.balance collateral = 9
  decide +kernel

theorem draw_return_public_invariant (schedule : Schedule) :
    ∀ b, collateralInvariant b (runAtomic atomCfg atomBoundary 8 basePolicy atomInitial
      drawReturnLeft [] schedule).publicWorld.state :=
  runAtomic_two_invariants atomCfg atomBoundary 8 basePolicy atomInitial drawReturnLeft [] schedule
    collateralInvariant unchangedCollateral unchangedCollateral collateral_initialized
    draw_return_local_obligation collateral_cross collateral_stable

theorem draw_return_diagnostic_invariant (schedule : Schedule) :
    ∀ b, collateralInvariant b (Atomic.runPrefix atomCfg atomBoundary basePolicy atomInitial
      drawReturnLeft [] schedule).speculative.world.state :=
  (Atomic.runPrefix_reachable atomCfg atomBoundary basePolicy atomInitial
    drawReturnLeft [] schedule).interleaving.two_invariants
      collateralInvariant unchangedCollateral unchangedCollateral
      collateral_initialized draw_return_local_obligation collateral_cross collateral_stable

/-- The invariant holds during a real draw while the qualified obligation is nonzero. -/
theorem nonempty_transient_invariant : basePolicy.lanes ≠ [] ∧
    drawPrefix.outstanding usdLane .alice = 7 ∧
    drawPrefix.speculative.world.state.balance usdVault = 3 ∧
    ∀ b, collateralInvariant b drawPrefix.speculative.world.state := by
  refine ⟨by decide, by decide +kernel, by decide +kernel,
    draw_return_diagnostic_invariant [.left]⟩

/-- Cancelling signed amounts across authenticated borrowers does not clear either key. -/
theorem scalar_netting_counterexample :
    (peerResiduals.map Residual.amount).sum = 0 ∧
    residuals multiParticipantPolicy (expectedOutstanding peerResiduals) = peerResiduals ∧
    peerResiduals ≠ [] := by decide +kernel

theorem missing_frame_support_counterexample :
    AgreeOn (∅ : Set (Cell P A D)) atomInitial.state drawPrefix.speculative.world.state ∧
    atomInitial.state.balance usdAlice = 1 ∧
    drawPrefix.speculative.world.state.balance usdAlice ≠ 1 := by
  refine ⟨?_, by decide +kernel, by decide +kernel⟩
  intro c impossible
  cases impossible

theorem empty_support_is_false :
    ¬ Supports (∅ : Set (Cell P A D)) (fun s : State P A D => s.balance usdAlice = 1) := by
  intro support
  have witness := missing_frame_support_counterexample
  exact witness.2.2 ((support _ _ witness.1).mp witness.2.1)

/-- Actual underlying financial success leaves debt; omitting clearance changes publication. -/
theorem underlying_success_does_not_imply_commit :
    unpaidInterleaving.left.failure = none ∧ unpaidInterleaving.left.nextIndex = 1 ∧
    (observe unpaidAtomic).outcome = .aborted (.unsettled drawResiduals) := by decide +kernel

end DefiKernel.Atomic.InvariantFixtures
