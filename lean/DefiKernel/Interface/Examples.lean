import DefiKernel.Interleaving.Execution
import DefiKernel.Metatheory.SequentialGroups

/-! Literal financial data for F01–F20. Expected receipts, events, worlds and cursors are
constructed independently of executors and Interface queries. Every unspecified cell is zero. -/
namespace DefiKernel.Interface.Examples
open Typed Composition

inductive Party | alice | bob | carol | total | admin
  deriving DecidableEq, Repr
inductive Asset | usd | eur
  deriving DecidableEq, Repr
inductive Domain | home | away
  deriving DecidableEq, Repr
instance : Fintype Party := ⟨{.alice, .bob, .carol, .total, .admin}, by intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .eur}, by intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.home, .away}, by intro d; cases d <;> simp⟩

abbrev P := Party
abbrev A := Asset
abbrev D := Domain
abbrev C := Cell P A D
abbrev W := World P A D
abbrev Store := CapabilityStore P A D
abbrev Inv := Invocation P A D
abbrev Cur := Cursor P A D
abbrev SR := StepResult P A D
abbrev Ev := Event P A D

def alice : C := (.home, .alice, .usd)
def bob : C := (.home, .bob, .usd)
def carol : C := (.home, .carol, .usd)
def totalCell : C := (.home, .total, .usd)
def eurCell : C := (.home, .alice, .eur)
def awayCell : C := (.away, .alice, .usd)
def awayEur : C := (.away, .alice, .eur)
def allCells : Finset C := Finset.univ

def cap (op : Nat) (right : Right P A D) : Capability P A D :=
  ⟨⟨.alice, .home, ⟨op⟩, right⟩, true⟩
def initialStore : Store := ⟨[
  cap 100 .invoke, cap 100 (.debit alice),
  cap 101 .invoke, cap 101 (.changeSupply .home .usd),
  cap 102 .invoke, cap 102 (.debit alice), cap 102 (.debit bob),
  cap 103 .invoke, cap 103 (.debit alice),
  cap 104 .invoke, cap 104 (.debit alice),
  cap 105 .invoke, cap 105 (.changeSupply .home .usd),
  cap 106 .invoke, cap 106 (.debit alice),
  cap 107 .invoke, cap 107 (.debit bob)]⟩

def balances (a b c t u v w : Nat) : C → ℚ := fun cell ↦
  if cell = alice then a else if cell = bob then b else if cell = carol then c
  else if cell = totalCell then t else if cell = eurCell then u
  else if cell = awayCell then v else if cell = awayEur then w else 0

def world (a b : Nat) (c : Nat := 0) (t : Nat := 0) (u : Nat := 0)
    (v : Nat := 0) (w : Nat := 0) (store : Store := initialStore) : W :=
  ⟨⟨balances a b c t u v w, by
    intro cell
    simp only [balances]
    repeat' split
    all_goals positivity⟩, store⟩
def initial64 := world 6 4
def initial55 := world 5 5
def paired1 := world 4 4 2
def paired2 := world 3 3 4

def ref (p : P) : CellRef P A D .usd := ⟨.home, .literal p⟩
def packed (p : P) : PackedCellRef P A D := ⟨.usd, ref p⟩
def delta (p : P) (q : ℚ) : CellDelta P A D [] := ⟨.usd, ref p, .lit q⟩
def constantTemplate (deltas : List (CellDelta P A D [])) (writes : List P)
    (supplies : List (SupplyDelta P A D []) := []) : Template P A D :=
  ⟨[], .home, 0, .lit true, deltas, supplies, [], [], writes.map packed⟩
def transfer2 := constantTemplate [delta .alice (-2), delta .bob 2] [.alice, .bob]
def mint3 := constantTemplate [delta .bob 3] [.bob] [⟨.home, .usd, .lit 3⟩]
def paired := constantTemplate [delta .alice (-1), delta .bob (-1), delta .carol 2]
  [.alice, .bob, .carol]
def oneSided := constantTemplate [delta .alice (-1), delta .carol 1] [.alice, .carol]
def repeated := constantTemplate [delta .alice (-1), delta .alice (-2), delta .bob 3]
  [.alice, .bob]
def increment := constantTemplate [delta .total 1] [.total] [⟨.home, .usd, .lit 1⟩]
def transfer7 := constantTemplate [delta .alice (-7), delta .carol 7] [.alice, .carol]
def halfInput : Expr P A D [.amount .usd] (.amount .usd) :=
  .binary (.divide (.amount Asset.usd)) (.arg .here) (.lit 2)
def returnHalf : Template P A D :=
  ⟨[.amount .usd], .home, 0, .lit true,
    [⟨.usd, ref .bob, .unary (.neg (.amount Asset.usd)) halfInput⟩,
     ⟨.usd, ref .alice, halfInput⟩], [], [], [], [packed .bob, packed .alice]⟩
def registry (op : OperationId) : Option (Template P A D) :=
  match op.value with
  | 100 => some transfer2 | 101 => some mint3 | 102 => some paired
  | 103 => some oneSided | 104 => some repeated | 105 => some increment
  | 106 => some transfer7 | 107 => some returnHalf | _ => none

def name (component : Nat) (port : Nat := 0) : QualifiedPort := ⟨⟨component⟩, ⟨port⟩⟩
def interfaces (snapshot : Bool := false) : List (OperationInterface P A D) := [
  ⟨⟨100⟩, [], if snapshot then [⟨⟨10⟩, alice⟩] else []⟩,
  ⟨⟨101⟩, [], []⟩, ⟨⟨102⟩, [], []⟩, ⟨⟨103⟩, [], []⟩,
  ⟨⟨104⟩, [], []⟩, ⟨⟨105⟩, [], []⟩, ⟨⟨106⟩, [], []⟩,
  ⟨⟨107⟩, [⟨⟨11⟩, .amount .usd⟩], []⟩]
def exporter (id : Nat) (cell : C) : Component P A D :=
  ⟨⟨id⟩, [], [⟨⟨0⟩, cell, true⟩], [], []⟩
def catalog (exposed : Bool := false) (snapshot : Bool := false) : Catalog P A D := [
  ⟨⟨0⟩, [], [⟨⟨0⟩, alice, true⟩],
    [⟨name 1, bob, true⟩, ⟨name 2, carol, true⟩] ++
      if exposed then [⟨name 6, totalCell, true⟩] else [], interfaces snapshot⟩,
  exporter 1 bob, exporter 2 carol, exporter 3 eurCell,
  exporter 4 awayCell, exporter 5 awayEur,
  if exposed then exporter 6 totalCell else ⟨⟨6⟩, [totalCell], [], [], []⟩,
  ⟨⟨7⟩, [], [], [⟨name 0, alice, true⟩], []⟩]
def config (exposed : Bool := false) (snapshot : Bool := false) : Config P A D :=
  ⟨registry, fun _ ↦ .admin, catalog exposed snapshot⟩
def cfg := config
def exposedCfg := config true
def snapshotCfg := config false true

def ids (values : List Nat) : List CapabilityId := values.map (⟨·⟩)
def invocation (op : Nat) (caps : List Nat) (inputs : List (InputSource A) := []) : Inv :=
  ⟨⟨0⟩, ⟨op⟩, [], inputs, ids caps, none⟩
def op100 := invocation 100 [0, 1]
def op101 := invocation 101 [2, 3]
def op102 := invocation 102 [4, 5, 6]
def op103 := invocation 103 [7, 8]
def op104 := invocation 104 [9, 10]
def op105 := invocation 105 [11, 12]
def op106 := invocation 106 [13, 14]
def op107 := invocation 107 [15, 16] [.priorOutput 2 (name 0 10)]
def boundary (_ : Nat) : Boundary P A D := ⟨⟨.alice, .home⟩, fun _ ↦ none, 0⟩
def adminBoundary (_ : Nat) : Boundary P A D := ⟨⟨.admin, .home⟩, fun _ ↦ none, 0⟩
def sharedBoundary (_ : Parallel.BranchId) : Nat → Boundary P A D := boundary

/-- Expected evaluated records use their own literal lists, never template.evaluate. -/
def evaluated (deltas : List (C × ℚ)) (writes : List C)
    (supplies : List ((D × A) × ℚ) := []) : Evaluated P A D :=
  ⟨true, deltas, supplies, [], [], [], [], writes⟩
def receipt100 : Receipt P A D := .invoked ⟨⟨100⟩, [], [], ids [0, 1], none⟩
  (evaluated [(alice, -2), (bob, 2)] [alice, bob])
def receipt101 : Receipt P A D := .invoked ⟨⟨101⟩, [], [], ids [2, 3], none⟩
  (evaluated [(bob, 3)] [bob] [((.home, .usd), 3)])
def receipt102 : Receipt P A D := .invoked ⟨⟨102⟩, [], [], ids [4, 5, 6], none⟩
  (evaluated [(alice, -1), (bob, -1), (carol, 2)] [alice, bob, carol])
def receipt103 : Receipt P A D := .invoked ⟨⟨103⟩, [], [], ids [7, 8], none⟩
  (evaluated [(alice, -1), (carol, 1)] [alice, carol])
def receipt104 : Receipt P A D := .invoked ⟨⟨104⟩, [], [], ids [9, 10], none⟩
  (evaluated [(alice, -1), (alice, -2), (bob, 3)] [alice, bob])
def receipt105 : Receipt P A D := .invoked ⟨⟨105⟩, [], [], ids [11, 12], none⟩
  (evaluated [(totalCell, 1)] [totalCell] [((.home, .usd), 1)])
def receipt107 : Receipt P A D := .invoked
  ⟨⟨107⟩, [], [⟨.amount .usd, 4⟩], ids [15, 16], none⟩
  (evaluated [(bob, -2), (alice, 2)] [bob, alice])
def expected100 : SR := ⟨world 4 6, receipt100, []⟩
def expected101 : SR := ⟨world 6 7, receipt101, []⟩
def expected104 : SR := ⟨world 3 7, receipt104, []⟩
def expected102 : SR := ⟨paired1, receipt102, []⟩
def expected103 : SR := ⟨world 4 5 1, receipt103, []⟩
def expected105 : SR := ⟨world 6 4 0 11, receipt105, []⟩
def firstPaired : Ev := ⟨0, .invoke op102, initial55, expected102⟩
def secondPaired : Ev := ⟨1, .invoke op102, paired1, ⟨paired2, receipt102, []⟩⟩
def initialCursor : Cur := ⟨initial55, [], [], 0, none⟩
def firstCursor : Cur := ⟨paired1, [firstPaired], [], 1, none⟩
def secondCursor : Cur := ⟨paired2, [firstPaired, secondPaired], [], 2, none⟩
def refusedCursor : Cur := { firstCursor with
  failure := some ⟨1, some (.invoke op106), .kernel .insufficientFunds⟩ }
def pairedGroup : Metatheory.SeqGroup P A D :=
  .seq (.step (.invoke op102)) (.step (.invoke op102))

def output (index port : Nat) (value : ℚ) : OutputObservation A :=
  ⟨index, name 0 port, ⟨.amount .usd, value⟩⟩
def priorOutput := output 1 12 9
def snapshotOutput := output 2 10 4
def arbitraryEntry : Cur := ⟨initial64, [], [priorOutput], 2, none⟩
def snapshotFirst : Ev :=
  ⟨2, .invoke op100, initial64, ⟨world 4 6, receipt100, [snapshotOutput]⟩⟩
def snapshotSecond : Ev :=
  ⟨3, .invoke op107, world 4 6, ⟨initial64, receipt107, []⟩⟩
def snapshotPrefix : Cur :=
  ⟨world 4 6, [snapshotFirst], [priorOutput, snapshotOutput], 3, none⟩
def snapshotFinal : Cur :=
  ⟨initial64, [snapshotFirst, snapshotSecond], [priorOutput, snapshotOutput], 4, none⟩
def snapshotGroup : Metatheory.SeqGroup P A D :=
  .seq (.step (.invoke op100)) (.step (.invoke op107))

def grant : Grant P A D := ⟨.bob, .home, ⟨100⟩, .invoke⟩
def issuedStore : Store := ⟨initialStore.entries ++ [⟨grant, true⟩]⟩
def revokedStore : Store := ⟨initialStore.entries ++ [⟨grant, false⟩]⟩
def issuedWorld := world 6 4 0 0 0 0 0 issuedStore
def revokedWorld := world 6 4 0 0 0 0 0 revokedStore
def issuedResult : SR := ⟨issuedWorld, .issued ⟨17⟩, []⟩
def revokedResult : SR := ⟨revokedWorld, .revoked ⟨17⟩, []⟩
def issueEvent : Ev := ⟨0, .issue grant, initial64, issuedResult⟩
def revokeEvent : Ev := ⟨1, .revoke ⟨17⟩, issuedWorld, revokedResult⟩
def adminFinal : Cur := ⟨revokedWorld, [issueEvent, revokeEvent], [], 2, none⟩

/-- Literal shared machines preserve each raw world and the actual attempt order. -/
def leftFailure : LocatedFailure P A D :=
  ⟨1, some (.invoke op106), .kernel .insufficientFunds⟩
def rightPaired : Ev := ⟨0, .invoke op102, paired1, ⟨paired2, receipt102, []⟩⟩
def leftLocal (consumed : Nat) : Interleaving.LocalState P A D :=
  ⟨consumed, [firstPaired], [], 1, some leftFailure⟩
def rightLocal : Interleaving.LocalState P A D := ⟨1, [rightPaired], [], 1, none⟩
def acceptedLeft : Interleaving.Attempt P A D :=
  ⟨.left, 0, op102, initial55, .ok expected102⟩
def acceptedRight : Interleaving.Attempt P A D :=
  ⟨.right, 0, op102, paired1, .ok ⟨paired2, receipt102, []⟩⟩
def refusedLeft (pre : W) : Interleaving.Attempt P A D :=
  ⟨.left, 1, op106, pre, .error (.kernel .insufficientFunds)⟩
def expectedF17 : Interleaving.Machine P A D :=
  ⟨paired2, leftLocal 2, rightLocal, [acceptedLeft, acceptedRight, refusedLeft paired2]⟩
def expectedF19 : Interleaving.Machine P A D :=
  ⟨paired2, leftLocal 2, rightLocal, [acceptedLeft, refusedLeft paired1, acceptedRight]⟩
def expectedF20 : Interleaving.Machine P A D :=
  ⟨paired2, leftLocal 3, rightLocal, [acceptedLeft, refusedLeft paired1, acceptedRight]⟩
def expectedSharedFirst : Interleaving.Machine P A D :=
  ⟨paired1, ⟨1, [firstPaired], [], 1, none⟩, {}, [acceptedLeft]⟩
def expectedSharedRefused : Interleaving.Machine P A D :=
  ⟨paired1, leftLocal 2, {}, [acceptedLeft, refusedLeft paired1]⟩
def expectedSharedSkipped : Interleaving.Machine P A D :=
  ⟨paired1, leftLocal 3, {}, [acceptedLeft, refusedLeft paired1]⟩

-- BEGIN PROOFS

end DefiKernel.Interface.Examples
