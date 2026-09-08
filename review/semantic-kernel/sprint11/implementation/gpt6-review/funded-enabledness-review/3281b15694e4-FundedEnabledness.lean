import DefiKernel.Nary.Examples
import DefiKernel.Typed.Transition

/-! Reusable F10 enabledness: actual `executeStep = .ok` under current store, history and
funding hypotheses. Success is constructed from catalog/access/typed guard/nonnegative
effects/extract, not assumed, not derived from StepSound, and not a whole-run fact.
Extra current hypotheses are only those FundedK already maintains. -/
namespace DefiKernel.Nary.FundedEnabledness
open Typed Composition
open DefiKernel.Nary
open DefiKernel.Nary.Examples

def producerIface : OperationInterface P A D := ⟨⟨200⟩, [], [⟨⟨7⟩, budgetC⟩]⟩
def consumerIface : OperationInterface P A D := ⟨⟨201⟩, [⟨⟨8⟩, .amount .usd⟩], []⟩
def deposit1Iface : OperationInterface P A D := ⟨⟨202⟩, [], []⟩
def deposit2Iface : OperationInterface P A D := ⟨⟨203⟩, [], []⟩

def producerRequest : Request P A D := ⟨⟨200⟩, [], [], ids [0], none⟩
def consumerRequest : Request P A D :=
  ⟨⟨201⟩, [], [⟨.amount .usd, (6 : ℚ)⟩], ids [1, 2], none⟩
def deposit1Request : Request P A D := ⟨⟨202⟩, [], [], ids [3, 4], none⟩
def deposit2Request : Request P A D := ⟨⟨203⟩, [], [], ids [5, 6], none⟩

def producerEval : Evaluated P A D := evaluated true [] [] []
def consumerEval : Evaluated P A D :=
  evaluated true [(vaultC, -6), (recipientC, 6)] [vaultC] [vaultC, recipientC]
def deposit1Eval : Evaluated P A D :=
  evaluated true [(donor1C, -1), (vaultC, 1)] [donor1C] [donor1C, vaultC]
def deposit2Eval : Evaluated P A D :=
  evaluated true [(donor2C, -2), (vaultC, 2)] [donor2C] [donor2C, vaultC]

def applyWorld (pre : W) (e : Evaluated P A D)
    (hn : ∀ c, 0 ≤ pre.state.balance c + e.effect c) : W :=
  ⟨⟨fun c ↦ pre.state.balance c + e.effect c, hn⟩, pre.capabilities⟩

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem f10_catalog_valid : validateCatalog f10Cfg.registry f10Cfg.catalog = true := by
  decide

theorem f10_bounds_producer (n : Nat) : f10Bounds (0 : Fin 3) n = vaultBound := rfl
theorem f10_bounds_deposit1 (n : Nat) : f10Bounds (1 : Fin 3) n = donor1Bound := rfl
theorem f10_bounds_deposit2 (n : Nat) : f10Bounds (2 : Fin 3) n = donor2Bound := rfl

theorem prepare_producer :
    prepareInvocation f10Cfg vaultBound 0 [] inv200 = .ok (producerIface, producerRequest) := by
  decide +kernel

#print axioms prepare_producer

end DefiKernel.Nary.FundedEnabledness
