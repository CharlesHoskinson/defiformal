import DefiKernel.Atomic.PolicyProofs
import DefiKernel.Atomic.Soundness
import DefiKernel.Interleaving.LocalOrder

/-! Receipt-derived obligations are an independent fold of actual attempts. Every reachable
prefix conserves each lane's cash plus the complete signed participant sum, including the
successful step that triggers a lane-supply abort. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def attemptOutstanding (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (owed : Outstanding P A D) (attempt : Attempt P A D) : Outstanding P A D :=
  match attempt.outcome with
  | .error _ => owed
  | .ok result => updateOutstanding policy owed
      (boundaries attempt.branch attempt.index).ctx.principal result.receipt

def outstandingFromAttempts (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (attempts : List (Attempt P A D)) : Outstanding P A D :=
  attempts.foldl (attemptOutstanding policy boundaries) zeroOutstanding

variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

/-- The same evaluated receipt used by execution gives the exact change at every cell. -/
theorem step_receipt_balance {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history step pre result) (cell : Cell P A D) :
    result.world.state.balance cell =
      pre.state.balance cell + receiptEffect result.receipt cell := by
  cases h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    exact ((applyEvaluated_ok_iff _ _ _ _ _ _).mp applied).2.2 cell
  | issue => simp [receiptEffect]
  | revoke => simp [receiptEffect]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem outstandingFromAttempts_append (policy : Policy P A D)
    (boundaries : ParallelBoundary P A D) (xs ys : List (Attempt P A D)) :
    outstandingFromAttempts policy boundaries (xs ++ ys) =
      ys.foldl (attemptOutstanding policy boundaries)
        (outstandingFromAttempts policy boundaries xs) := List.foldl_append

/-- Supply rejection retains the just-updated diagnostic table. -/
theorem advance_outstanding (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (b : BranchId) (active : m.abort = none) :
    (advance cfg boundaries policy left right m b).outstanding =
      match (Interleaving.advance cfg boundaries left right m.speculative b).attempts[
          m.speculative.attempts.length]? with
      | none => m.outstanding
      | some attempt => attemptOutstanding policy boundaries m.outstanding attempt := by
  cases hg : (Interleaving.advance cfg boundaries left right m.speculative b).attempts[
      m.speculative.attempts.length]? with
  | none => simp [advance, active, hg]
  | some attempt =>
    cases he : attempt.outcome with
    | error reason => simp [advance, active, hg, attemptOutstanding, he]
    | ok result =>
      simp only [advance, active, hg, attemptOutstanding, he]
      split <;> rfl

/-- Actual attempts, including the final successful supply-violating receipt, determine debt. -/
theorem advance_outstanding_fold (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId)
    (old : m.outstanding = outstandingFromAttempts policy boundaries m.speculative.attempts) :
    (advance cfg boundaries policy left right m b).outstanding =
      outstandingFromAttempts policy boundaries
        (advance cfg boundaries policy left right m b).speculative.attempts := by
  cases ha : m.abort with
  | some reason => simpa only [advance_aborted _ _ _ _ _ _ _ reason ha] using old
  | none =>
    rw [advance_outstanding _ _ _ _ _ _ _ ha, advance_speculative _ _ _ _ _ _ _ ha]
    cases hf : (m.speculative.local b).failure with
    | some failure =>
      simp only [Interleaving.advance, hf]
      cases b <;> simpa [Interleaving.Machine.skip, Interleaving.Machine.setLocal] using old
    | none =>
      cases hs : (selectBranch left right b)[(m.speculative.local b).consumed]? with
      | none =>
        simp only [Interleaving.advance, hf, hs]
        cases b <;> simpa [Interleaving.Machine.skip, Interleaving.Machine.setLocal] using old
      | some inv =>
        rw [interleaving_advance_appended _ _ _ _ _ _ _ hf hs]
        simp [outstandingFromAttempts_append, old]

theorem Reachable.outstanding_fold {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {policy : Policy P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries policy left right initial m) :
    m.outstanding = outstandingFromAttempts policy boundaries m.speculative.attempts := by
  induction h with
  | start => rfl
  | next b previous ih => exact advance_outstanding_fold _ _ _ _ _ _ _ ih

/-- A real accepted invocation preserves lane cash plus all qualified outstanding entries. -/
theorem accepted_cash_owed {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (executed : executeStep cfg boundary index history (.invoke inv) pre = .ok result)
    (policy : Policy P A D) (owed : Outstanding P A D) (lane : Lane P A D)
    (hlane : lane ∈ policy.lanes) (hn : policy.participants.Nodup)
    (hp : boundary.ctx.principal ∈ policy.participants) :
    result.world.state.balance lane.cell +
      (policy.participants.map
        (updateOutstanding policy owed boundary.ctx.principal result.receipt lane)).sum =
      pre.state.balance lane.cell + (policy.participants.map (owed lane)).sum := by
  rw [step_receipt_balance (executeStep_sound _ _ _ _ _ _ _ executed),
    updateOutstanding_sum _ _ _ _ _ hlane hn hp]
  rw [add_assoc, ← add_sub_assoc, add_sub_cancel_left]

/-- Every reachable diagnostic prefix conserves lane cash plus signed participant obligations. -/
theorem Reachable.cash_owed {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {policy : Policy P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries policy left right initial m)
    (admitted : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    m.speculative.world.state.balance lane.cell +
      (policy.participants.map (m.outstanding lane)).sum = initial.state.balance lane.cell := by
  induction h with
  | start =>
    change initial.state.balance lane.cell +
      (policy.participants.map (fun _ ↦ (0 : ℚ))).sum = initial.state.balance lane.cell
    simp
  | @next m b previous ih =>
    cases ha : m.abort with
    | some reason => simpa only [advance_aborted _ _ _ _ _ _ _ reason ha] using ih
    | none =>
      have hf := previous.no_failures ha b
      rw [advance_outstanding _ _ _ _ _ _ _ ha, advance_speculative _ _ _ _ _ _ _ ha]
      cases hs : (selectBranch left right b)[(m.speculative.local b).consumed]? with
      | none =>
        simp only [Interleaving.advance, hf, hs]
        cases b <;> simpa [Interleaving.Machine.skip, Interleaving.Machine.setLocal] using ih
      | some inv =>
        have hidx := previous.interleaving.attempt_index b hf inv hs
        have hp := checkPolicy_covers policy boundaries left right admitted b
          (m.speculative.local b).nextIndex (by
            rw [hidx]
            exact (List.getElem?_eq_some_iff.mp hs).1)
        have hg := interleaving_advance_attempt cfg boundaries left right m.speculative b inv hf hs
        rw [hg]
        cases he : executeStep cfg (boundaries b (m.speculative.local b).nextIndex)
            (m.speculative.local b).nextIndex (m.speculative.local b).outputs
            (.invoke inv) m.speculative.world with
        | error reason =>
          simp only [he, attemptOutstanding, Interleaving.advance, hf, hs]
          cases b <;> simpa [Interleaving.Machine.refuse, Interleaving.Machine.setLocal] using ih
        | ok result =>
          simp only [he, attemptOutstanding, Interleaving.advance, hf, hs]
          have hstep := accepted_cash_owed he policy m.outstanding lane hlane
            (checkPolicy_participants_nodup _ _ _ _ admitted) hp
          cases b <;>
            simpa [Interleaving.Machine.accept, Interleaving.Machine.setLocal] using hstep.trans ih

theorem runPrefix_cash_owed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) (admitted : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    (runPrefix cfg boundaries policy initial left right schedule).speculative.world.state.balance
      lane.cell + (policy.participants.map
        ((runPrefix cfg boundaries policy initial left right schedule).outstanding lane)).sum =
      initial.state.balance lane.cell :=
  (runPrefix_reachable _ _ _ _ _ _ _).cash_owed admitted lane hlane

/-- Full pointwise clearance restores each configured vault cell exactly. -/
theorem Reachable.cleared_cash {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {policy : Policy P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries policy left right initial m)
    (admitted : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (cleared : residuals policy m.outstanding = [])
    (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    m.speculative.world.state.balance lane.cell = initial.state.balance lane.cell := by
  have hall := (residuals_eq_nil_iff policy m.outstanding).mp cleared lane hlane
  have hs : (policy.participants.map (m.outstanding lane)).sum = 0 :=
    List.sum_eq_zero (by intro p hp; rcases List.mem_map.mp hp with ⟨q, hq, rfl⟩; exact hall q hq)
  simpa [hs] using h.cash_owed admitted lane hlane

end DefiKernel.Atomic
