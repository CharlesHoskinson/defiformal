import DefiKernel.Atomic.Policy

/-! Finite region observations of the existing ledger and actual receipts. These functions
introduce no executor or admission check. Mixed regions have an exact sum; dimensioned
contracts separately require `Region.WellFormed`. -/
namespace DefiKernel.Interface
open Typed Composition

structure Region (P A D : Type) where
  domain : D
  asset : A
  cells : Finset (Cell P A D)

variable {P A D : Type}

def Region.WellFormed (region : Region P A D) : Prop :=
  ∀ c ∈ region.cells, c.1 = region.domain ∧ c.2.2 = region.asset

def balanceSum (region : Region P A D) (state : State P A D) : ℚ :=
  region.cells.sum state.balance

variable [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- Every repeated target contributes its signed amount. Administrative receipts contribute zero. -/
def receiptCellEffect (receipt : Receipt P A D) (cell : Cell P A D) : ℚ :=
  match receipt with
  | .invoked _ e => (e.deltas.map (fun d ↦ if d.1 = cell then d.2 else 0)).sum
  | .issued _ | .revoked _ => 0

def receiptDelta (region : Region P A D) (receipt : Receipt P A D) : ℚ :=
  region.cells.sum (receiptCellEffect receipt)

def ValueSupports (support : Set (Cell P A D)) (value : State P A D → ℚ) : Prop :=
  ∀ s t, Composition.AgreeOn support s t → value s = value t

def WritesWithin (cells : Finset (Cell P A D)) (receipt : Receipt P A D) : Prop :=
  ∀ c ∈ receipt.writes, c ∈ cells

def NeutralOn (region : Region P A D) (cells : Finset (Cell P A D))
    (receipt : Receipt P A D) : Prop :=
  (region.cells ∩ cells).sum (receiptCellEffect receipt) = 0

-- BEGIN PROOFS

@[simp] theorem receiptCellEffect_eq_receiptEffect (receipt : Receipt P A D)
    (cell : Cell P A D) : receiptCellEffect receipt cell = Atomic.receiptEffect receipt cell := by
  cases receipt <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem balanceSum_empty (domain : D) (asset : A) (state : State P A D) :
    balanceSum ⟨domain, asset, ∅⟩ state = 0 := by simp [balanceSum]

@[simp] theorem receiptDelta_empty (domain : D) (asset : A) (receipt : Receipt P A D) :
    receiptDelta ⟨domain, asset, ∅⟩ receipt = 0 := by simp [receiptDelta]

@[simp] theorem receiptCellEffect_issued (id : CapabilityId) (cell : Cell P A D) :
    receiptCellEffect (Receipt.issued id) cell = 0 := rfl

@[simp] theorem receiptCellEffect_revoked (id : CapabilityId) (cell : Cell P A D) :
    receiptCellEffect (Receipt.revoked id) cell = 0 := rfl

@[simp] theorem receiptDelta_issued (region : Region P A D) (id : CapabilityId) :
    receiptDelta region (Receipt.issued id) = 0 := by
  change region.cells.sum (fun _ ↦ (0 : ℚ)) = 0
  exact Finset.sum_const_zero

@[simp] theorem receiptDelta_revoked (region : Region P A D) (id : CapabilityId) :
    receiptDelta region (Receipt.revoked id) = 0 := by
  change region.cells.sum (fun _ ↦ (0 : ℚ)) = 0
  exact Finset.sum_const_zero

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem valueSupports_const (support : Set (Cell P A D)) (q : ℚ) :
    ValueSupports support (fun _ ↦ q) := by intro _ _ _; rfl

end DefiKernel.Interface
