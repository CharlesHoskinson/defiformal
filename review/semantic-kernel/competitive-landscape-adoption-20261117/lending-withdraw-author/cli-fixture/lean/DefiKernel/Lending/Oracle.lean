import DefiKernel.Lending.Types

/-! Reference oracle contract: price collateral/cash at feed7; provenance truth remains assumed. -/
namespace DefiKernel.Lending.Oracle
open DefiKernel.Typed
def key : ObservationKey Domain := ⟨.lending,⟨7⟩⟩
def maxAge : Nat := 5
def price {signature : List (Unit Asset)} : E signature (.price Asset.collateral Asset.cash) :=
  .observe ⟨key⟩
def debtCash {signature : List (Unit Asset)} (borrower : Borrower) : E signature (.amount Asset.cash) :=
  .binary (.convert Asset.debt Asset.cash) (.balance (ref .debt borrower.party)) (.lit 1)
def lockedCash {signature : List (Unit Asset)} (borrower : Borrower) : E signature (.amount Asset.cash) :=
  .binary (.convert Asset.collateral Asset.cash) (.balance (ref .collateral borrower.custody)) price
def allGuards {signature : List (Unit Asset)} : List (E signature .bool) → E signature .bool
  | [] => .lit true
  | guard::rest => .binary .and guard (allGuards rest)
def feed (price : ℚ) (observedAt : Nat) : Environment Asset Domain := fun lookup =>
  if lookup = key then some ⟨⟨.price .collateral .cash,price⟩,observedAt⟩ else none
end DefiKernel.Lending.Oracle
