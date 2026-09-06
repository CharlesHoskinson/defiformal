import DefiKernel.Core

/-! Trusted contracts constrain proposals before the unchanged finite executor runs.
The caller selecting a contract and its parameters is trusted; this is not authentication. -/
namespace DefiKernel.Contracts

/-- Executable state/environment/proposal predicate selected outside the untrusted proposal. -/
structure Contract (E : Type) where
  accepts : State → E → Transition E → Bool

/-- Contract rejection and each original executor rejection remain distinguishable. -/
inductive Failure where
  | contract
  | base (reason : Refusal)
  deriving DecidableEq, Repr

/-- Embed the original result without changing its state or refusal reason. -/
def liftBase (result : Except Refusal State) : Except Failure State :=
  match result with
  | .error reason => .error (.base reason)
  | .ok s => .ok s

/-- A failed contract returns no successful state. The proposal cannot replace this predicate. -/
def run {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s : State) : Except Failure State :=
  if contract.accepts s env t then liftBase (execute p env t s) else .error .contract

/-- The vacuous contract is useful for stating conservative recovery of base execution. -/
def always (E : Type) : Contract E := ⟨fun _ _ _ ↦ true⟩

/-- Observe exact balances while retaining the wrapper refusal. -/
def observe (result : Except Failure State) (cells : List Cell) : Except Failure (List ℚ) :=
  result.map (fun s ↦ cells.map s.balance)

-- BEGIN PROOFS

theorem liftBase_ok_iff (result : Except Refusal State) (s' : State) :
    liftBase result = .ok s' ↔ result = .ok s' := by
  cases result <;> simp [liftBase]

/-- Success means both trusted contract satisfaction and actual base execution success. -/
theorem run_ok_iff {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) :
    run contract p env t s = .ok s' ↔
      contract.accepts s env t = true ∧ execute p env t s = .ok s' := by
  by_cases hc : contract.accepts s env t = true
  · simp [run, hc, liftBase_ok_iff]
  · simp [run, hc]

/-- Successful execution retains every original check and the exact update equation. -/
theorem run_valid_update {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s') :
    contract.accepts s env t = true ∧
      ∃ hv : Valid p env t s, applyEffect s t hv.2.2.2.1 = s' := by
  obtain ⟨hc, hb⟩ := (run_ok_iff contract p env t s s').mp h
  exact ⟨hc, (execute_ok_iff p env t s s').mp hb⟩

theorem run_always {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
    run (always E) p env t s = liftBase (execute p env t s) := rfl

theorem run_contract_refused {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s : State) (hc : contract.accepts s env t = false) :
    run contract p env t s = .error .contract := by simp [run, hc]

theorem run_base_refused {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s : State) (reason : Refusal)
    (hc : contract.accepts s env t = true) (hb : execute p env t s = .error reason) :
    run contract p env t s = .error (.base reason) := by simp [run, hc, hb, liftBase]

theorem run_accounting {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s') (a : Asset) :
    total s' a = total s a + t.supplyChange a :=
  execute_accounting p env t s s' ((run_ok_iff contract p env t s s').mp h).2 a

theorem run_locality {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s')
    (c : Cell) (hc : c ∉ t.writes) : s'.balance c = s.balance c :=
  execute_locality p env t s s' ((run_ok_iff contract p env t s s').mp h).2 c hc

theorem run_authority {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s') :
    DebitAuthorized p t ∧ SupplyAuthorized p t :=
  execute_authority p env t s s' ((run_ok_iff contract p env t s s').mp h).2

end DefiKernel.Contracts
