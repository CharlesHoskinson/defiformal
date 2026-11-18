import DefiKernel.Typed.Transition
import Mathlib.Data.Fintype.Basic

/-! Exact-rational lending reference roles. Locked custody holds the same collateral asset. -/
namespace DefiKernel.Lending
open DefiKernel.Typed
inductive Party where
  | alice | bob | pool | aliceLocked | bobLocked | admin
  deriving DecidableEq, Repr
inductive Asset where | cash | collateral | debt deriving DecidableEq, Repr
inductive Domain where | lending deriving DecidableEq, Repr
inductive Borrower where | alice | bob deriving DecidableEq, Repr
instance : Fintype Party := ⟨{.alice,.bob,.pool,.aliceLocked,.bobLocked,.admin}, by
  intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.cash,.collateral,.debt}, by intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.lending}, by intro d; cases d; simp⟩
def Borrower.party : Borrower → Party | .alice => .alice | .bob => .bob
def Borrower.custody : Borrower → Party | .alice => .aliceLocked | .bob => .bobLocked
abbrev Ledger := State Party Asset Domain
abbrev Store := CapabilityStore Party Asset Domain
abbrev World := ExecutionResult Party Asset Domain
abbrev Op := Template Party Asset Domain
abbrev E (signature : List (Unit Asset)) := Expr Party Asset Domain signature
def ref (asset : Asset) (party : Party) : CellRef Party Asset Domain asset :=
  ⟨.lending, .literal party⟩
def packedRef (asset : Asset) (party : Party) : PackedCellRef Party Asset Domain :=
  ⟨asset, ref asset party⟩
def borrowId : OperationId := ⟨0⟩
def repayId : OperationId := ⟨1⟩
def accrueId : OperationId := ⟨2⟩
def depositCollateralId : OperationId := ⟨3⟩
def withdrawCollateralId : OperationId := ⟨4⟩
def borrowerContext (borrower : Borrower) : InvocationContext Party Domain :=
  ⟨borrower.party, .lending⟩

theorem borrower_ne_pool (borrower : Borrower) : borrower.party ≠ Party.pool := by
  cases borrower <;> decide

theorem borrower_ne_custody (borrower : Borrower) : borrower.party ≠ borrower.custody := by
  cases borrower <;> decide

end DefiKernel.Lending
