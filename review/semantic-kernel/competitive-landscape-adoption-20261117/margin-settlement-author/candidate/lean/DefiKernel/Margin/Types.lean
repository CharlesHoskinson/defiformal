import DefiKernel.Typed.Transition
import Mathlib.Data.Fintype.Basic

/-! Reference margin custody roles. Claim counters are distinct assets, never physical cash. -/
namespace DefiKernel.Margin
open DefiKernel.Typed
inductive Party where
  | owner | position | output | costRecipient | pool | holding | admin
  deriving DecidableEq, Repr
inductive Asset where
  | primary | secondary | claimPrimary | claimSecondary
  deriving DecidableEq, Repr
inductive Domain where | margin deriving DecidableEq, Repr
instance : Fintype Party := ⟨{.owner,.position,.output,.costRecipient,.pool,.holding,.admin},by
  intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.primary,.secondary,.claimPrimary,.claimSecondary},by
  intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.margin},by intro d; cases d; simp⟩
abbrev Ledger := State Party Asset Domain
abbrev Store := CapabilityStore Party Asset Domain
abbrev World := ExecutionResult Party Asset Domain
abbrev Op := Template Party Asset Domain
abbrev E (signature : List (Unit Asset)) := Expr Party Asset Domain signature
def ref (asset : Asset) (party : Party) : CellRef Party Asset Domain asset := ⟨.margin,.literal party⟩
def packedRef (asset : Asset) (party : Party) : PackedCellRef Party Asset Domain := ⟨asset,ref asset party⟩
def ownerContext : InvocationContext Party Domain := ⟨.owner,.margin⟩
end DefiKernel.Margin
