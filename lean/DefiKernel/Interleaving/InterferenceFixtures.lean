import DefiKernel.Interleaving.Interference
import DefiKernel.Interleaving.Preservation
import DefiKernel.Interleaving.Examples
import DefiKernel.Parallel.Preservation

/-! Shared-liquidity development instances and counterexamples. Conservation has a local proof
independent of the invariant antecedent; the generic rely/guarantee rule still exposes it. -/
namespace DefiKernel.Interleaving.InterferenceFixtures
open Typed Composition Parallel Typed.Examples Parallel.Examples Interleaving.Examples

abbrev Ledger := State Party Asset Domain

def dollars (amount : ℚ) (_ : BranchId) (s : Ledger) : Prop := total s .main .usd = amount
def sameDollars (_ : BranchId) (pre post : Ledger) : Prop :=
  total post .main .usd = total pre .main .usd

def leftFP : Footprint Party Asset Domain :=
  ⟨[vaultUSD, aliceUSD, vaultUSD, aliceUSD, aliceUSD], [vaultUSD, aliceUSD, vaultUSD, aliceUSD]⟩
def rightFP : Footprint Party Asset Domain :=
  ⟨[vaultUSD, bobUSD, vaultUSD, bobUSD, bobUSD], [vaultUSD, bobUSD, vaultUSD, bobUSD]⟩
def collateral (s : Ledger) : Prop := s.balance protectedCell = 9

def fragile : BranchId → Ledger → Prop
  | .left, s => s.balance bobUSD = 0
  | .right, s => total s .main .usd = 10

def rightPrefix := runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight [.right]
def leftPrefix := runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight [.left]

-- BEGIN PROOFS

theorem shared_supply_free : ∀ op template, sharedCfg.registry op = some template →
    template.supplyDeltas = [] := by
  intro op template selected
  change (if op = ⟨10⟩ then some (transferTemplate .usd (.literal .vault) (.literal .alice))
    else if op = ⟨11⟩ then some (transferTemplate .usd (.literal .vault) (.literal .bob))
    else none) = some template at selected
  split_ifs at selected <;> cases selected <;> rfl

/-- The local total relation needs no invariant antecedent or peer assumption. -/
theorem shared_step_total (boundary : Boundary Party Asset Domain) (index : Nat)
    (history : List (OutputObservation Asset)) (inv : I) (pre : W)
    (result : StepResult Party Asset Domain)
    (h : StepSound sharedCfg boundary index history (.invoke inv) pre result) :
    total result.world.state .main .usd = total pre.state .main .usd := by
  rw [h.accounting, step_no_supply shared_supply_free h, add_zero]

theorem shared_local_obligation (amount : ℚ) :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight (dollars amount) sameDollars := by
  intro b index inv _ history pre result initialized step
  have totalEq := shared_step_total _ _ _ _ _ _ step
  exact ⟨totalEq.trans initialized, totalEq⟩

theorem shared_cross : CrossInclusion sameDollars sameDollars := by
  intro b peer _ pre post h
  exact h

theorem shared_stable (amount : ℚ) : Stable (dollars amount) sameDollars := by
  intro b pre post initialized same
  exact same.trans initialized

theorem shared_initialized : ∀ b, dollars 10 b sharedInitial.state := by
  intro b
  change total sharedInitial.state .main .usd = 10
  decide +kernel

theorem shared_every_prefix (schedule : Schedule) (length : Nat) :
    ∀ b, dollars 10 b (runPrefix sharedCfg boundaries sharedInitial
      sharedLeft sharedRight (schedule.take length)).world.state :=
  every_prefix_two_invariants sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule
    (dollars 10) sameDollars sameDollars shared_initialized (shared_local_obligation 10)
    shared_cross (shared_stable 10) length

theorem shared_all_tokens (schedule : Schedule) :
    total (runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule).world.state
      .main .usd = 10 :=
  runPrefix_two_invariants sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule
    (dollars 10) sameDollars sameDollars shared_initialized (shared_local_obligation 10)
    shared_cross (shared_stable 10) .left

theorem shared_left_analyzed : analyzeBranch sharedCfg (boundaries .left) sharedLeft =
    .ok leftFP := by decide +kernel

theorem shared_right_analyzed : analyzeBranch sharedCfg (boundaries .right) sharedRight =
    .ok rightFP := by decide +kernel

theorem shared_overlap : vaultUSD ∈ leftFP.writes ∧ vaultUSD ∈ rightFP.writes := by decide

theorem collateral_supported : Supports {protectedCell} collateral :=
  supports_balance protectedCell (· = 9)

theorem protected_collateral_all_tokens (schedule : Schedule) :
    collateral (runPrefix sharedCfg boundaries sharedInitial
      sharedLeft sharedRight schedule).world.state := by
  have frame := (runPrefix_reachable sharedCfg boundaries sharedInitial sharedLeft sharedRight
    schedule).analyzed_predicate_frame leftFP rightFP shared_left_analyzed shared_right_analyzed
    {protectedCell} collateral collateral_supported
  have untouched : ∀ c ∈ ({protectedCell} : Set C), c ∉ leftFP.writes ++ rightFP.writes := by
    intro c member
    have eq := Set.mem_singleton_iff.mp member
    subst c
    decide
  apply (frame untouched).mp
  change sharedInitial.state.balance protectedCell = 9
  decide +kernel

/-- All noninitial premises hold for total USD11, but even the empty prefix has total USD10. -/
theorem missing_initialization_counterexample :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight (dollars 11) sameDollars ∧
    CrossInclusion sameDollars sameDollars ∧ Stable (dollars 11) sameDollars ∧
    ¬ dollars 11 .left
      (runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight []).world.state := by
  refine ⟨shared_local_obligation 11, shared_cross, shared_stable 11, ?_⟩
  change total sharedInitial.state .main .usd ≠ 11
  rw [shared_initialized .left]
  decide

/-- StepSound version of the analyzed target frame for local universal obligations. -/
theorem sound_target_frame {cfg : Config Party Asset Domain}
    {boundary : Boundary Party Asset Domain} {index : Nat}
    {history : List (OutputObservation Asset)} {inv : I} {pre : W}
    {result : StepResult Party Asset Domain} (fp : Footprint Party Asset Domain)
    (analyzed : analyzeInvocation cfg boundary inv = .ok fp)
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∀ c, c ∉ fp.writes → result.world.state.balance c = pre.state.balance c := by
  cases h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    obtain ⟨op, parties, _⟩ := prepareInvocation_shape _ _ _ _ _ _ _ prepared
    apply execute_target_frame cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state post {c | c ∈ fp.writes} _ executed
    intro template selected
    rw [op] at selected
    rw [parties]
    exact (analyzed_dependencies _ _ _ _ analyzed template selected).2.1

theorem fragile_local_obligation :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight fragile sameDollars := by
  intro b index inv selected history pre result initialized step
  have totalEq := shared_step_total _ _ _ _ _ _ step
  refine ⟨?_, totalEq⟩
  cases b with
  | right => exact totalEq.trans initialized
  | left =>
    cases index with
    | zero =>
      simp only [selectBranch, sharedLeft, List.getElem?_cons_zero, Option.some.injEq] at selected
      subst inv
      have analyzed : analyzeInvocation sharedCfg (boundaries .left 0) (usd 7) =
          .ok leftFP := by decide +kernel
      exact (sound_target_frame leftFP analyzed step bobUSD (by decide)).trans initialized
    | succ n => simp [selectBranch, sharedLeft] at selected

theorem fragile_initialized : ∀ b, fragile b sharedInitial.state := by
  intro b
  cases b
  · change sharedInitial.state.balance bobUSD = 0
    decide +kernel
  · exact shared_initialized .right

/-- The peer transfers six dollars to Bob while conserving total USD; this breaks Bob=0. -/
theorem missing_peer_stability_counterexample :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight fragile sameDollars ∧
    CrossInclusion sameDollars sameDollars ∧ (∀ b, fragile b sharedInitial.state) ∧
    sameDollars .left sharedInitial.state rightPrefix.world.state ∧
    ¬ fragile .left rightPrefix.world.state := by
  refine ⟨fragile_local_obligation, shared_cross, fragile_initialized, ?_, ?_⟩
  · exact (shared_all_tokens [.right]).trans (shared_initialized .left).symm
  · change rightPrefix.world.state.balance bobUSD ≠ 0
    decide +kernel

theorem fragile_not_stable : ¬ Stable fragile sameDollars := by
  intro stable
  have witness := missing_peer_stability_counterexample
  exact witness.2.2.2.2 (stable .left _ _ (fragile_initialized .left) witness.2.2.2.1)

/-- Empty region agreement alone cannot protect a financial predicate on a written cell. -/
theorem missing_frame_support_counterexample :
    AgreeOn (∅ : Set C) sharedInitial.state leftPrefix.world.state ∧
    sharedInitial.state.balance aliceUSD = 0 ∧ leftPrefix.world.state.balance aliceUSD ≠ 0 := by
  refine ⟨?_, ?_, ?_⟩
  · intro c impossible
    cases impossible
  · decide +kernel
  · decide +kernel

theorem empty_support_is_false :
    ¬ Supports (∅ : Set C) (fun s : Ledger ↦ s.balance aliceUSD = 0) := by
  intro support
  have witness := missing_frame_support_counterexample
  exact witness.2.2 ((support _ _ witness.1).mp witness.2.1)

end DefiKernel.Interleaving.InterferenceFixtures
