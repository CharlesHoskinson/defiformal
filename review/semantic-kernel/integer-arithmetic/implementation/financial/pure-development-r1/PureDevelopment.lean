import DefiKernel.Arithmetic.Operations
import DefiKernel.Arithmetic.Fees
import DefiKernel.Arithmetic.Quantity
import DefiKernel.Typed.Transition

/-! Frozen F01–F45 literal fixtures. Expected values are separate literal tables.
All reference ledgers cover sixteen cells, including protected cells with balance nine.
F40/F41 use aggregate net effects with payer coincidence, not gross debit-order semantics. -/
namespace DefiKernel.Arithmetic.Examples
open Typed

inductive Party | alice | bob | treasury | observer
  deriving DecidableEq, Repr
inductive Asset | usd | alt
  deriving DecidableEq, Repr
inductive Domain | «local» | remote
  deriving DecidableEq, Repr
instance : Fintype Party := ⟨{.alice, .bob, .treasury, .observer}, by intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .alt}, by intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.local, .remote}, by intro d; cases d <;> simp⟩

abbrev C := Cell Party Asset Domain
abbrev WordResult := Except Arithmetic.Failure Nat
abbrev QuoteResult := Except Arithmetic.Failure (Nat × Nat × Nat × Nat)
abbrev ReferenceObservation := (State Party Asset Domain × CapabilityStore Party Asset Domain) ×
  Except Refusal (ExecutionResult Party Asset Domain)

inductive PureObservation
  | word (result : WordResult)
  | quote (result : QuoteResult)
  | quantity (amount : ℚ) (result : WordResult)

def allCells : List C :=
  [(.local, .alice, .usd),
    (.local, .alice, .alt),
    (.local, .bob, .usd),
    (.local, .bob, .alt),
    (.local, .treasury, .usd),
    (.local, .treasury, .alt),
    (.local, .observer, .usd),
    (.local, .observer, .alt),
    (.remote, .alice, .usd),
    (.remote, .alice, .alt),
    (.remote, .bob, .usd),
    (.remote, .bob, .alt),
    (.remote, .treasury, .usd),
    (.remote, .treasury, .alt),
    (.remote, .observer, .usd),
    (.remote, .observer, .alt)]

def literalInputs : List String :=
  ["arithmetic.fixture.f01",
    "arithmetic.fixture.f02",
    "arithmetic.fixture.f03",
    "arithmetic.fixture.f04",
    "arithmetic.fixture.f05",
    "arithmetic.fixture.f06",
    "arithmetic.fixture.f07",
    "arithmetic.fixture.f08",
    "arithmetic.fixture.f09",
    "arithmetic.fixture.f10",
    "arithmetic.fixture.f11",
    "arithmetic.fixture.f12",
    "arithmetic.fixture.f13",
    "arithmetic.fixture.f14",
    "arithmetic.fixture.f15",
    "arithmetic.fixture.f16",
    "arithmetic.fixture.f17",
    "arithmetic.fixture.f18",
    "arithmetic.fixture.f19",
    "arithmetic.fixture.f20",
    "arithmetic.fixture.f21",
    "arithmetic.fixture.f22",
    "arithmetic.fixture.f23",
    "arithmetic.fixture.f24",
    "arithmetic.fixture.f25",
    "arithmetic.fixture.f26",
    "arithmetic.fixture.f27",
    "arithmetic.fixture.f28",
    "arithmetic.fixture.f29",
    "arithmetic.fixture.f30",
    "arithmetic.fixture.f31",
    "arithmetic.fixture.f32",
    "arithmetic.fixture.f33",
    "arithmetic.fixture.f34",
    "arithmetic.fixture.f35",
    "arithmetic.fixture.f36",
    "arithmetic.fixture.f37",
    "arithmetic.fixture.f38",
    "arithmetic.fixture.f39",
    "arithmetic.fixture.f40",
    "arithmetic.fixture.f41",
    "arithmetic.fixture.f42",
    "arithmetic.fixture.f43",
    "arithmetic.fixture.f44",
    "arithmetic.fixture.f45"]

def entryStore : CapabilityStore Party Asset Domain :=
  ⟨[⟨⟨.alice, .local, ⟨7⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .local, ⟨7⟩, .debit (.local, .alice, .usd)⟩, true⟩,
    ⟨⟨.observer, .remote, ⟨8⟩, .invoke⟩, false⟩,
    ⟨⟨.observer, .remote, ⟨8⟩, .invoke⟩, true⟩]⟩

def expectedStore : CapabilityStore Party Asset Domain :=
  ⟨[⟨⟨.alice, .local, ⟨7⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .local, ⟨7⟩, .debit (.local, .alice, .usd)⟩, true⟩,
    ⟨⟨.observer, .remote, ⟨8⟩, .invoke⟩, false⟩,
    ⟨⟨.observer, .remote, ⟨8⟩, .invoke⟩, true⟩]⟩

def referenceContext : InvocationContext Party Domain := ⟨.alice, .local⟩

def referenceEnvironment : Environment Asset Domain := fun _ ↦ none

def pureCases : List (String × PureObservation) :=
  [("arithmetic.fixture.f01",
      .word ((ofNat 8 255).map Word.value)),
    ("arithmetic.fixture.f02",
      .word ((ofNat 8 256).map Word.value)),
    ("arithmetic.fixture.f03",
      .word ((Operations.add (⟨254, by decide⟩ : Word 8) (⟨1, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f04",
      .word ((Operations.add (⟨255, by decide⟩ : Word 8) (⟨1, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f05",
      .word ((Operations.sub (⟨0, by decide⟩ : Word 8) (⟨1, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f06",
      .word ((Operations.mul (⟨16, by decide⟩ : Word 8) (⟨16, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f07",
      .word ((Rounding.mulDiv .down (⟨200, by decide⟩ : Word 8) (⟨2, by decide⟩ : Word 8) 2).map Word.value)),
    ("arithmetic.fixture.f08",
      .word ((Rounding.mulDiv .down (⟨255, by decide⟩ : Word 8) (⟨255, by decide⟩ : Word 8) 0).map Word.value)),
    ("arithmetic.fixture.f09",
      .word ((Rounding.mulDiv .down (⟨7, by decide⟩ : Word 8) (⟨5, by decide⟩ : Word 8) 3).map Word.value)),
    ("arithmetic.fixture.f10",
      .word ((Rounding.mulDiv .up (⟨7, by decide⟩ : Word 8) (⟨5, by decide⟩ : Word 8) 3).map Word.value)),
    ("arithmetic.fixture.f11",
      .word ((Rounding.mulDiv .up (⟨6, by decide⟩ : Word 8) (⟨5, by decide⟩ : Word 8) 3).map Word.value)),
    ("arithmetic.fixture.f12",
      .word ((Rounding.mulDiv .down (⟨254, by decide⟩ : Word 8) (⟨254, by decide⟩ : Word 8) 253).map Word.value)),
    ("arithmetic.fixture.f13",
      .word ((Rounding.mulDiv .up (⟨254, by decide⟩ : Word 8) (⟨254, by decide⟩ : Word 8) 253).map Word.value)),
    ("arithmetic.fixture.f14",
      .quote ((Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 1 3).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f15",
      .quote ((Fees.feeFromGross .up (⟨100, by decide⟩ : Word 8) 1 3).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f16",
      .quote ((Fees.feeOnTop .up (⟨100, by decide⟩ : Word 8) 1 3).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f17",
      .quote ((Fees.feeOnTop .up (⟨255, by decide⟩ : Word 8) 1 1).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f18",
      .quote ((Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 0 0).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f19",
      .quote ((Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 2 1).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f20",
      .quote ((Fees.feeFromGross .up (⟨0, by decide⟩ : Word 8) 1 3).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f21",
      let q := Quantity.toQuantity Asset.usd (1/4) (by norm_num) (⟨7, by decide⟩ : Word 8)
      .quantity q.amount ((Quantity.fromRat 8 (1/4) q.amount).map Word.value)),
    ("arithmetic.fixture.f22",
      .word ((Quantity.fromRat 8 (1/4) (7/8)).map Word.value)),
    ("arithmetic.fixture.f23",
      .word ((Quantity.fromRat 8 (0) (-1)).map Word.value)),
    ("arithmetic.fixture.f24",
      .word ((Quantity.fromRat 8 (1) (-1)).map Word.value)),
    ("arithmetic.fixture.f29",
      .quote ((Fees.feeFromGross .down (⟨100, by decide⟩ : Word 8) 300 600).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f30",
      .word ((ofNat 0 0).map Word.value)),
    ("arithmetic.fixture.f31",
      .word ((ofNat 0 1).map Word.value)),
    ("arithmetic.fixture.f32",
      .word ((Operations.mul (⟨15, by decide⟩ : Word 8) (⟨17, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f33",
      .word ((Operations.sub (⟨255, by decide⟩ : Word 8) (⟨1, by decide⟩ : Word 8)).map Word.value)),
    ("arithmetic.fixture.f34",
      .word ((Rounding.mulDiv .up (⟨0, by decide⟩ : Word 8) (⟨255, by decide⟩ : Word 8) 3).map Word.value)),
    ("arithmetic.fixture.f35",
      .quote ((Fees.feeFromGross .up (⟨100, by decide⟩ : Word 8) 0 1).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f36",
      .quote ((Fees.feeFromGross .up (⟨100, by decide⟩ : Word 8) 1 1).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f37",
      .quote ((Fees.feeFromGross .up (⟨1, by decide⟩ : Word 8) 1 3).map
      (fun q ↦ (q.principal.value, q.fee.value, q.charged.value, q.received.value)))),
    ("arithmetic.fixture.f38",
      .word ((Quantity.fromRat 8 (1/4) (64)).map Word.value)),
    ("arithmetic.fixture.f39",
      .word ((Rounding.mulDiv .down (⟨255, by decide⟩ : Word 8) (⟨255, by decide⟩ : Word 8) 300).map Word.value)),
    ("arithmetic.fixture.f44",
      .word (Rounding.divideNat .up 65025 1)),
    ("arithmetic.fixture.f45",
      .word (Rounding.divideNat .down 0 0))]

def expectedPureCases : List (String × PureObservation) :=
  [("arithmetic.fixture.f01", .word (.ok 255)),
    ("arithmetic.fixture.f02", .word (.error .inputOverflow)),
    ("arithmetic.fixture.f03", .word (.ok 255)),
    ("arithmetic.fixture.f04", .word (.error .addOverflow)),
    ("arithmetic.fixture.f05", .word (.error .subUnderflow)),
    ("arithmetic.fixture.f06", .word (.error .mulOverflow)),
    ("arithmetic.fixture.f07", .word (.ok 200)),
    ("arithmetic.fixture.f08", .word (.error .divisionByZero)),
    ("arithmetic.fixture.f09", .word (.ok 11)),
    ("arithmetic.fixture.f10", .word (.ok 12)),
    ("arithmetic.fixture.f11", .word (.ok 10)),
    ("arithmetic.fixture.f12", .word (.ok 255)),
    ("arithmetic.fixture.f13", .word (.error .quotientOverflow)),
    ("arithmetic.fixture.f14", .quote (.ok (100, 33, 100, 67))),
    ("arithmetic.fixture.f15", .quote (.ok (100, 34, 100, 66))),
    ("arithmetic.fixture.f16", .quote (.ok (100, 34, 134, 100))),
    ("arithmetic.fixture.f17", .quote (.error .addOverflow)),
    ("arithmetic.fixture.f18", .quote (.error .invalidRate)),
    ("arithmetic.fixture.f19", .quote (.error .invalidRate)),
    ("arithmetic.fixture.f20", .quote (.ok (0, 0, 0, 0))),
    ("arithmetic.fixture.f21", .quantity (7/4) (.ok 7)),
    ("arithmetic.fixture.f22", .word (.error .nonIntegralQuantity)),
    ("arithmetic.fixture.f23", .word (.error .nonPositiveScale)),
    ("arithmetic.fixture.f24", .word (.error .negativeQuantity)),
    ("arithmetic.fixture.f29", .quote (.ok (100, 50, 100, 50))),
    ("arithmetic.fixture.f30", .word (.ok 0)),
    ("arithmetic.fixture.f31", .word (.error .inputOverflow)),
    ("arithmetic.fixture.f32", .word (.ok 255)),
    ("arithmetic.fixture.f33", .word (.ok 254)),
    ("arithmetic.fixture.f34", .word (.ok 0)),
    ("arithmetic.fixture.f35", .quote (.ok (100, 0, 100, 100))),
    ("arithmetic.fixture.f36", .quote (.ok (100, 100, 100, 0))),
    ("arithmetic.fixture.f37", .quote (.ok (1, 1, 1, 0))),
    ("arithmetic.fixture.f38", .word (.error .inputOverflow)),
    ("arithmetic.fixture.f39", .word (.ok 216)),
    ("arithmetic.fixture.f44", .word (.ok 65025)),
    ("arithmetic.fixture.f45", .word (.error .divisionByZero))]

def inputF25 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF25 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF25 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (100)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (67)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (33)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF26 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF26 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF26 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (100)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (100)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF27 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (99)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF27 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (99)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF28 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF28 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF40 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (33)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF40 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (33)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF40 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (0)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (33)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF41 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (0)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF41 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (0)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF41 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (0)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (9)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (9)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF42 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (50)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF42 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (50)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF42 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (25)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (67/4)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (33/4)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def inputF43 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedInputF43 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (200)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (0)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (0)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num

def expectedPostF43 : State Party Asset Domain where
  balance
    | (.local, .alice, .usd) => (66)
    | (.local, .alice, .alt) => (9)
    | (.local, .bob, .usd) => (100)
    | (.local, .bob, .alt) => (9)
    | (.local, .treasury, .usd) => (34)
    | (.local, .treasury, .alt) => (9)
    | (.local, .observer, .usd) => (9)
    | (.local, .observer, .alt) => (9)
    | (.remote, .alice, .usd) => (9)
    | (.remote, .alice, .alt) => (9)
    | (.remote, .bob, .usd) => (9)
    | (.remote, .bob, .alt) => (9)
    | (.remote, .treasury, .usd) => (9)
    | (.remote, .treasury, .alt) => (9)
    | (.remote, .observer, .usd) => (9)
    | (.remote, .observer, .alt) => (9)
  nonneg := by
    intro ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> norm_num


end DefiKernel.Arithmetic.Examples

/-! Full observations are independent of production query/executor implementation. -/
namespace DefiKernel.Arithmetic.Tests
open Typed Examples

def wordResultEq (actual expected : WordResult) : Bool := decide (actual = expected)

def quoteResultEq (actual expected : QuoteResult) : Bool := decide (actual = expected)

def quantityEq (actualAmount expectedAmount : ℚ) (actualWord expectedWord : WordResult) : Bool :=
  decide (actualAmount = expectedAmount) && wordResultEq actualWord expectedWord

def pureObservationEq (actual expected : PureObservation) : Bool :=
  match actual, expected with
  | .word a, .word e => wordResultEq a e
  | .quote a, .quote e => quoteResultEq a e
  | .quantity a aw, .quantity e ew => quantityEq a e aw ew
  | _, _ => false

def stateEq (actual expected : State Party Asset Domain) : Bool :=
  allCells.all (fun cell ↦ decide (actual.balance cell = expected.balance cell))

def executionResultEq (actual expected : Except Refusal (ExecutionResult Party Asset Domain)) :
    Bool :=
  match actual, expected with
  | .error a, .error e => decide (a = e)
  | .ok a, .ok e => stateEq a.state e.state && decide (a.capabilities = e.capabilities)
  | _, _ => false


#eval do
  for (name, actual) in Examples.pureCases do
    let passed := match Examples.expectedPureCases.lookup name with
      | some expected => pureObservationEq actual expected
      | none => false
    IO.println s!"{name}: {passed}"
end DefiKernel.Arithmetic.Tests
