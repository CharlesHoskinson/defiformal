import DefiKernel.Parallel.Dependency.Adapter
import DefiKernel.Typed.TransitionTests

/-! Kernel-checked dependency fixtures over eight cells. These are development examples,
including malformed write declarations that refuse after the funds check. -/
namespace DefiKernel.Parallel.DependencyFixtures
open Typed Composition Typed.TransitionTests

def foreignState : S :=
  ⟨fun c ↦ if c = (true, true, true) then 99 else state.balance c, by
    intro c; split
    · decide
    · exact state.nonneg c⟩

def poorState : S :=
  ⟨fun c ↦ if c = (false, false, false) then 1 else state.balance c, by
    intro c; split
    · decide
    · exact state.nonneg c⟩

def targetRegion : Set (Cell Bool Bool Bool) :=
  {(false, false, false), (false, true, false)}

def malformed : T := { transfer with writes := [] }
def unbalanced : T := { transfer with supplyDeltas := [⟨false, false, .lit 1⟩] }
def dividing : T :=
  { transfer with
    deltas := [⟨false, alice,
      .binary (.divide (.amount false)) (.balance alice) (.lit 0)⟩]
    stateReads := [⟨false, alice⟩] }
def missingObservation : T :=
  { transfer with guard := .binary (.le (.amount false)) (.observe ⟨key⟩) (.lit 100)
                  envReads := [.observation key] }
def inactiveReads : T :=
  { transfer with
    guard := .ite (.lit true)
      (.binary (.le (.amount false)) (.balance alice) (.lit 100))
      (.binary (.le (.amount false)) (.balance bob) (.lit 100))
    stateReads := [⟨false, alice⟩, ⟨false, bob⟩] }

def evaluated : Evaluated Bool Bool Bool :=
  ⟨true, [((false, false, false), -3), ((false, true, false), 3)], [], [], [], [], [], []⟩

def exec (template : T) (pre : S) : Result :=
  Typed.execute (registry template) (capabilities template) context environment 10 request pre

-- BEGIN PROOFS

theorem foreign_agrees : AgreeOn targetRegion state foreignState := by
  intro c hc
  rcases hc with rfl | rfl <;> rfl

theorem foreign_differs : state.balance (true, true, true) ≠
    foreignState.balance (true, true, true) := by decide

theorem malformed_evaluates : malformed.evaluate
    ⟨state, environment, false, [], .nil, 10⟩ = .ok evaluated := by rfl

theorem malformed_targets : TargetsWithin malformed false [] targetRegion := by
  intro d hd c hc
  change d ∈ transfer.deltas at hd
  have hm := List.mem_cons.mp hd
  have hm' : d = transfer.deltas[0] ∨ d = transfer.deltas[1] := by
    rcases hm with h | h
    · exact Or.inl h
    · exact Or.inr (List.mem_singleton.mp h)
  rcases hm' with rfl | rfl
  · have he : (false, false, false) = c := Except.ok.inj hc
    subst c
    simp [targetRegion]
  · have he : (false, true, false) = c := Except.ok.inj hc
    subst c
    simp [targetRegion]

/-- The syntactic target theorem applies although the declared write list is empty. -/
theorem malformed_effect_outside (c : Cell Bool Bool Bool) (hc : c ∉ targetRegion) :
    evaluated.effect c = 0 :=
  evaluated_effect_zero_outside malformed _ evaluated malformed_evaluates targetRegion
    malformed_targets c hc

theorem malformed_writes_fail : evaluated.writesOK = false := by decide +kernel

theorem foreign_funds_iff :
    (∀ c, 0 ≤ state.balance c + evaluated.effect c) ↔
      (∀ c, 0 ≤ foreignState.balance c + evaluated.effect c) :=
  funds_iff state foreignState evaluated targetRegion foreign_agrees malformed_effect_outside

theorem target_balance_is_needed :
    (∀ c, 0 ≤ state.balance c + evaluated.effect c) ∧
      ¬ (∀ c, 0 ≤ poorState.balance c + evaluated.effect c) := by decide +kernel

theorem refused_iff (reason : Typed.Refusal) (result : Result) :
    refused reason result = true ↔ result = .error reason := by
  cases result with
  | error e => simp only [refused, beq_iff_eq, Except.error.injEq]
  | ok p =>
    constructor
    · intro h
      cases h
    · intro h
      cases h

theorem funded_malformed_refusal : exec malformed state = .error .writeFootprint := by
  apply (refused_iff _ _).mp
  decide +kernel

theorem foreign_malformed_refusal : exec malformed foreignState = .error .writeFootprint := by
  apply (execute_refusal_iff (registry malformed) (capabilities malformed) context environment 10
    request state foreignState targetRegion foreign_agrees _ _ .writeFootprint).mp
    funded_malformed_refusal
  · intro template hs
    have he : template = malformed := (Option.some.inj hs).symm
    subst template
    simp [ResolvedReadsAgree, Template.requiredStateReads, malformed, transfer, Expr.stateReads]
  · intro template hs
    have he : template = malformed := (Option.some.inj hs).symm
    subst template
    exact malformed_targets

theorem poor_malformed_refusal : exec malformed poorState = .error .insufficientFunds := by
  apply (refused_iff _ _).mp
  decide +kernel

theorem accounting_refusal : exec unbalanced foreignState = .error .accounting := by
  apply (refused_iff _ _).mp
  decide +kernel

theorem division_evaluation : dividing.evaluate
    ⟨state, environment, false, [], .nil, 10⟩ = .error .divisionByZero := by rfl

theorem division_execution : exec dividing foreignState = .error (.evaluation .divisionByZero) := by
  apply (refused_iff _ _).mp
  decide +kernel

theorem observation_error : missingObservation.evaluate
    ⟨foreignState, (fun _ ↦ none), false, [], .nil, 10⟩ = .error .missingObservation := by rfl

/-- Both branches contribute to the proved read premise, even though the condition is true. -/
theorem inactive_evaluation_congr : inactiveReads.evaluate
    ⟨state, environment, false, [], .nil, 10⟩ = inactiveReads.evaluate
      ⟨foreignState, environment, false, [], .nil, 10⟩ := by
  apply evaluate_congr
  intro ref hr c hc
  simp [inactiveReads, transfer, Template.requiredStateReads, Expr.stateReads] at hr
  rcases hr with rfl | rfl <;>
    simp only [alice, bob, CellRef.resolve, PartyRef.resolve, bind, Except.bind,
      pure, Except.pure, Except.ok.injEq] at hc <;>
    subst c <;> rfl

theorem foreign_success : accepted (exec transfer foreignState) = true := by decide +kernel

end DefiKernel.Parallel.DependencyFixtures
