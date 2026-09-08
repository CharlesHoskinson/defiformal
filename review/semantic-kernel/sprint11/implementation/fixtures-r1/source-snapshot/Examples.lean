import DefiKernel.Nary.Schedule
import DefiKernel.Nary.Execution
import DefiKernel.Nary.CausalRuntime
import DefiKernel.Interface.Examples
import DefiKernel.Interface.Regions
import DefiKernel.Interface.Bindings

/-! Independent Nary runtime fixtures F01–F19. Expected worlds, stores, receipts, outputs,
events, attempts, failures and monitor phases are literal tables. None is produced by
`runNary`, `runPrefix`, `continueRun` or a compared binary runner. -/
namespace DefiKernel.Nary.Examples
open Typed Composition Parallel
open DefiKernel.Nary
open Interface (Region Binding balanceSum checkBindings bindingsHold)

inductive Party
  | vault | donor0 | donor1 | donor2 | recipient | recipient1 | budget | admin
  deriving DecidableEq, Repr
inductive Asset | usd | eur
  deriving DecidableEq, Repr
inductive Domain | home | away
  deriving DecidableEq, Repr

instance : Fintype Party :=
  ⟨{.vault, .donor0, .donor1, .donor2, .recipient, .recipient1, .budget, .admin}, by
    intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .eur}, by intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.home, .away}, by intro d; cases d <;> simp⟩

abbrev P := Party
abbrev A := Asset
abbrev D := Domain
abbrev C := Cell P A D
abbrev W := World P A D
abbrev Store := CapabilityStore P A D
abbrev Inv := Invocation P A D
abbrev Ev := Event P A D
abbrev SR := StepResult P A D
abbrev LS := Interleaving.LocalState P A D
abbrev M3 := Machine (Fin 3) P A D
abbrev M2 := Machine (Fin 2) P A D
abbrev MB := Machine BranchId P A D
abbrev MU := Machine Unit P A D
abbrev ME := Machine Empty P A D

def vaultC : C := (.home, .vault, .usd)
def donor0C : C := (.home, .donor0, .usd)
def donor1C : C := (.home, .donor1, .usd)
def donor2C : C := (.home, .donor2, .usd)
def recipientC : C := (.home, .recipient, .usd)
def recipient1C : C := (.home, .recipient1, .usd)
def budgetC : C := (.home, .budget, .usd)
def adminC : C := (.home, .admin, .usd)
def sentinelC : C := (.away, .recipient, .eur)

def p0 : Fin 3 := 0
def p1 : Fin 3 := 1
def p2 : Fin 3 := 2
def q0 : Fin 2 := 0
def q1 : Fin 2 := 1

def cellRef (owner : Party) : CellRef P A D .usd := ⟨.home, .literal owner⟩
def packed (owner : Party) : PackedCellRef P A D := ⟨.usd, cellRef owner⟩
def argRef (i : Nat) : CellRef P A D .usd := ⟨.home, .argument i⟩
def packedArg (i : Nat) : PackedCellRef P A D := ⟨.usd, argRef i⟩

def ids (values : List Nat) : List CapabilityId := values.map (⟨·⟩)
def name (component port : Nat) : QualifiedPort := ⟨⟨component⟩, ⟨port⟩⟩
def emptyEnv : Environment A D := fun _ ↦ none
def bound (principal : P) : Boundary P A D := ⟨⟨principal, .home⟩, emptyEnv, 0⟩
def vaultBound := bound .vault
def donor0Bound := bound .donor0
def donor1Bound := bound .donor1
def donor2Bound := bound .donor2
def budgetBound := bound .budget
def adminBound := bound .admin

def cap (holder : P) (op : Nat) (right : Right P A D) : Capability P A D :=
  ⟨⟨holder, .home, ⟨op⟩, right⟩, true⟩
def storeOf (entries : List (Capability P A D)) : Store := ⟨entries⟩

def mainUsd (v d0 d1 d2 r r1 b ad : ℚ) : C → ℚ := fun c ↦
  if c = vaultC then v else if c = donor0C then d0 else if c = donor1C then d1
  else if c = donor2C then d2 else if c = recipientC then r else if c = recipient1C then r1
  else if c = budgetC then b else if c = adminC then ad
  else if c = sentinelC then 11 else 0

def mkWorld (v d0 d1 d2 r r1 b ad : ℚ) (store : Store) : W :=
  ⟨⟨mainUsd v d0 d1 d2 r r1 b ad, by
      intro c
      simp only [mainUsd]
      repeat' split
      all_goals decide⟩, store⟩

def f02Store : Store := storeOf [
  cap .vault 10 .invoke, cap .vault 10 (.debit vaultC),
  cap .donor1 11 .invoke, cap .donor1 11 (.debit donor1C),
  cap .donor2 12 .invoke, cap .donor2 12 (.debit donor2C)]
def f07Store : Store := storeOf (f02Store.entries ++ [
  cap .vault 13 .invoke, cap .vault 13 (.debit vaultC)])
def f03Store : Store := storeOf [
  cap .vault 14 .invoke, cap .vault 14 (.debit vaultC),
  cap .vault 15 .invoke, cap .vault 15 (.debit vaultC)]
def f11Store : Store := storeOf [
  cap .vault 14 .invoke, cap .vault 14 (.debit vaultC)]
def f04Store : Store := storeOf [
  cap .vault 10 .invoke, cap .vault 10 (.debit vaultC)]
def f14Store : Store := storeOf [cap .vault 17 .invoke]
def f10Store : Store := storeOf [
  cap .vault 200 .invoke,
  cap .vault 201 .invoke, cap .vault 201 (.debit vaultC),
  cap .donor1 202 .invoke, cap .donor1 202 (.debit donor1C),
  cap .donor2 203 .invoke, cap .donor2 203 (.debit donor2C)]
def f05Store : Store := storeOf [
  cap .donor0 18 .invoke, cap .donor0 18 (.debit donor0C),
  cap .budget 18 .invoke, cap .budget 18 (.debit budgetC),
  cap .vault 19 .invoke, cap .vault 19 (.debit vaultC)]
def f12Store : Store := storeOf (f10Store.entries ++ [
  cap .vault 16 .invoke, cap .vault 16 (.debit vaultC)])
def f16Store : Store := storeOf [
  cap .vault 210 .invoke,
  cap .vault 201 .invoke, cap .vault 201 (.debit vaultC),
  cap .donor1 202 .invoke, cap .donor1 202 (.debit donor1C)]
def f17Store : Store := f10Store

/-- F02 initial: vault 10, donor1 2, donor2 3, recipient 0, budget 6, sentinel 11. -/
def f02Initial : W := mkWorld 10 0 2 3 0 0 6 0 f02Store
/-- 10 − 1 = 9; recipient 0 + 1 = 1. -/
def f02After0 : W := mkWorld 9 0 2 3 1 0 6 0 f02Store
/-- 9 + 1 = 10; donor1 2 − 1 = 1. -/
def f02After1 : W := mkWorld 10 0 1 3 1 0 6 0 f02Store
/-- 10 + 2 = 12; donor2 3 − 2 = 1. -/
def f02After2 : W := mkWorld 12 0 1 1 1 0 6 0 f02Store
def f04Initial : W := mkWorld 10 0 0 0 0 0 0 0 f04Store
def f04After : W := mkWorld 9 0 0 0 1 0 0 0 f04Store
def f10Initial : W := mkWorld 10 0 2 3 0 0 6 0 f10Store
def f05Initial : W := mkWorld 10 6 0 0 0 0 0 0 f05Store
def f11Initial : W := mkWorld 10 0 0 0 0 0 0 0 f11Store
def f11After : W := mkWorld 3 0 0 0 7 0 0 0 f11Store
def f14Initial : W := mkWorld 3 0 0 0 0 0 0 0 f14Store
def f03Initial : W := mkWorld 10 0 0 0 0 0 0 0 f03Store
def f03AfterLeft : W := mkWorld 3 0 0 0 7 0 0 0 f03Store
def f03AfterRight : W := mkWorld 4 0 6 0 0 0 0 0 f03Store

def leBalance {sig : List (Typed.Unit A)} (q : ℚ) (owner : PartyRef P) :
    Expr P A D sig .bool :=
  .binary (.le (.amount .usd)) (.lit q) (.balance ⟨.home, owner⟩)
def nonnegative {sig : List (Typed.Unit A)}
    (q : Expr P A D sig (.amount .usd)) : Expr P A D sig .bool :=
  .binary (.le (.amount .usd)) (.lit (0 : ℚ)) q
def andBool {sig : List (Typed.Unit A)}
    (x y : Expr P A D sig .bool) : Expr P A D sig .bool :=
  .binary .and x y
def litAmt {sig : List (Typed.Unit A)} (q : ℚ) : Expr P A D sig (.amount .usd) := .lit q
def negAmt {sig : List (Typed.Unit A)} (q : ℚ) : Expr P A D sig (.amount .usd) := .lit (-q)

def constTransfer (src dst : Party) (q : ℚ) : Template P A D where
  signature := []
  domain := .home
  partyArity := 0
  guard := leBalance q (.literal src)
  deltas := [⟨.usd, cellRef src, negAmt q⟩, ⟨.usd, cellRef dst, litAmt q⟩]
  supplyDeltas := []
  stateReads := [packed src]
  envReads := []
  writes := [packed src, packed dst]

def identityOp : Template P A D where
  signature := []
  domain := .home
  partyArity := 0
  guard := .lit true
  deltas := []
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := []

def producerSnapshot : Template P A D := identityOp

def falseProducer : Template P A D where
  signature := []
  domain := .home
  partyArity := 0
  guard := .lit false
  deltas := []
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := []

def usdArg : Expr P A D [.amount .usd] (.amount .usd) := .arg .here

def consumerTransfer (dst : Party) : Template P A D where
  signature := [.amount .usd]
  domain := .home
  partyArity := 0
  guard := andBool (nonnegative usdArg)
    (.binary (.le (.amount .usd)) usdArg (.balance (cellRef .vault)))
  deltas := [⟨.usd, cellRef .vault, .unary (.neg (.amount .usd)) usdArg⟩,
    ⟨.usd, cellRef dst, usdArg⟩]
  supplyDeltas := []
  stateReads := [packed .vault]
  envReads := []
  writes := [packed .vault, packed dst]

/-- One parameterized producer: amount argument plus source/target party arguments. -/
def parameterizedProducer : Template P A D where
  signature := [.amount .usd]
  domain := .home
  partyArity := 2
  guard := andBool (nonnegative usdArg)
    (.binary (.le (.amount .usd)) usdArg (.balance (argRef 0)))
  deltas := [⟨.usd, argRef 0, .unary (.neg (.amount .usd)) usdArg⟩,
    ⟨.usd, argRef 1, usdArg⟩]
  supplyDeltas := []
  stateReads := [packedArg 0]
  envReads := []
  writes := [packedArg 0, packedArg 1]

def parameterizedConsumer : Template P A D where
  signature := [.amount .usd]
  domain := .home
  partyArity := 1
  guard := andBool (nonnegative usdArg)
    (.binary (.le (.amount .usd)) usdArg (.balance (cellRef .vault)))
  deltas := [⟨.usd, cellRef .vault, .unary (.neg (.amount .usd)) usdArg⟩,
    ⟨.usd, argRef 0, usdArg⟩]
  supplyDeltas := []
  stateReads := [packed .vault]
  envReads := []
  writes := [packed .vault, packedArg 0]

def registry (op : OperationId) : Option (Template P A D) :=
  match op.value with
  | 10 => some (constTransfer .vault .recipient 1)
  | 11 => some (constTransfer .donor1 .vault 1)
  | 12 => some (constTransfer .donor2 .vault 2)
  | 13 => some (constTransfer .vault .recipient 20)
  | 14 => some (constTransfer .vault .recipient 7)
  | 15 => some (constTransfer .vault .donor1 6)
  | 16 => some (constTransfer .vault .donor1 3)
  | 17 => some identityOp
  | 21 => some (constTransfer .vault .donor1 7)
  | 18 => some parameterizedProducer
  | 19 => some parameterizedConsumer
  | 200 => some producerSnapshot
  | 201 => some (consumerTransfer .recipient)
  | 202 => some (constTransfer .donor1 .vault 1)
  | 203 => some (constTransfer .donor2 .vault 2)
  | 210 => some falseProducer
  | _ => none

def exportPort (id : Nat) (cell : C) : ResourcePort P A D := ⟨⟨id⟩, cell, true⟩
def opIface (op : Nat) (inputs : List (InputPort A)) (outputs : List (OutputPort P A D)) :
    OperationInterface P A D := ⟨⟨op⟩, inputs, outputs⟩

def fundedCatalog : Catalog P A D := [
  ⟨⟨0⟩, [],
    [exportPort 0 vaultC, exportPort 1 donor1C, exportPort 2 donor2C,
      exportPort 3 recipientC, exportPort 4 budgetC],
    [],
    [opIface 10 [] [], opIface 11 [] [], opIface 12 [] [], opIface 13 [] [],
      opIface 14 [] [], opIface 15 [] [], opIface 16 [] [], opIface 17 [] [],
      opIface 21 [] []]⟩]
def f10Catalog : Catalog P A D := [
  ⟨⟨0⟩, [],
    [exportPort 0 vaultC, exportPort 1 donor1C, exportPort 2 donor2C,
      exportPort 3 recipientC, exportPort 4 budgetC],
    [],
    [opIface 200 [] [⟨⟨7⟩, budgetC⟩],
      opIface 201 [⟨⟨8⟩, .amount .usd⟩] [],
      opIface 202 [] [], opIface 203 [] []]⟩]
def f05Catalog : Catalog P A D := [
  ⟨⟨0⟩, [],
    [exportPort 0 vaultC, exportPort 1 donor0C, exportPort 2 donor1C,
      exportPort 3 recipientC, exportPort 4 recipient1C, exportPort 5 budgetC],
    [],
    [opIface 18 [⟨⟨20⟩, .amount .usd⟩] [⟨⟨7⟩, budgetC⟩],
      opIface 19 [⟨⟨8⟩, .amount .usd⟩] []]⟩]
def f16Catalog : Catalog P A D := [
  ⟨⟨0⟩, [],
    [exportPort 0 vaultC, exportPort 1 donor1C, exportPort 3 recipientC, exportPort 4 budgetC],
    [],
    [opIface 210 [] [⟨⟨7⟩, budgetC⟩],
      opIface 201 [⟨⟨8⟩, .amount .usd⟩] [],
      opIface 202 [] []]⟩]
def f12Catalog : Catalog P A D := [
  ⟨⟨0⟩, [],
    [exportPort 0 vaultC, exportPort 1 donor1C, exportPort 2 donor2C,
      exportPort 3 recipientC, exportPort 4 budgetC],
    [],
    [opIface 200 [] [⟨⟨7⟩, budgetC⟩],
      opIface 201 [⟨⟨8⟩, .amount .usd⟩] [],
      opIface 16 [] []]⟩]
def invalidCatalog : Catalog P A D :=
  fundedCatalog ++ [⟨⟨0⟩, [], [], [], []⟩]

def mkCfg (catalog : Catalog P A D) : Config P A D := ⟨registry, fun _ ↦ .admin, catalog⟩
def fundedCfg := mkCfg fundedCatalog
def f10Cfg := mkCfg f10Catalog
def f05Cfg := mkCfg f05Catalog
def f16Cfg := mkCfg f16Catalog
def f12Cfg := mkCfg f12Catalog
def invalidCfg := mkCfg invalidCatalog

def invoke (op : Nat) (caps : List Nat) (parties : List P := [])
    (inputs : List (InputSource A) := []) : Inv :=
  ⟨⟨0⟩, ⟨op⟩, parties, inputs, ids caps, none⟩

def inv10 := invoke 10 [0, 1]
def inv11 := invoke 11 [2, 3]
def inv12 := invoke 12 [4, 5]
def inv13 := invoke 13 [6, 7]
def inv14 := invoke 14 [0, 1]
def inv15 := invoke 15 [2, 3]
def inv16 := invoke 16 [7, 8]
def inv17 := invoke 17 [0]
def inv21 := invoke 21 [0, 1]
def inv18 (src dst : P) (q : ℚ) (caps : List Nat) : Inv :=
  invoke 18 caps [src, dst] [.literal ⟨.amount .usd, q⟩]
def inv19 (dst : P) (caps : List Nat) : Inv :=
  invoke 19 caps [dst] [.priorOutput 0 (name 0 7)]
def inv200 := invoke 200 [0]
def inv201 := invoke 201 [1, 2] [] [.priorOutput 0 (name 0 7)]
def inv202 := invoke 202 [3, 4]
def inv203 := invoke 203 [5, 6]
def inv210 := invoke 210 [0]
def inv999 := invoke 999 []

def evaluated (guard : Bool) (deltas : List (C × ℚ)) (reads writes : List C) :
    Evaluated P A D :=
  ⟨guard, deltas, [], reads, [], reads, [], writes⟩
def recConst (op : Nat) (caps : List Nat) (deltas : List (C × ℚ)) (src dst : C) :
    Receipt P A D :=
  .invoked ⟨⟨op⟩, [], [], ids caps, none⟩ (evaluated true deltas [src] [src, dst])
def recIdentity (op : Nat) (caps : List Nat) : Receipt P A D :=
  .invoked ⟨⟨op⟩, [], [], ids caps, none⟩ (evaluated true [] [] [])
def recProducer (op : Nat := 200) (caps : List Nat := [0]) : Receipt P A D :=
  recIdentity op caps
def recConsumer (q : ℚ) (op : Nat := 201) (caps : List Nat := [1, 2])
    (args : List (PackedValue A) := [⟨.amount .usd, q⟩]) : Receipt P A D :=
  .invoked ⟨⟨op⟩, [], args, ids caps, none⟩
    (evaluated true [(vaultC, -q), (recipientC, q)] [vaultC] [vaultC, recipientC])

def rec10 := recConst 10 [0, 1] [(vaultC, -1), (recipientC, 1)] vaultC recipientC
def rec11 := recConst 11 [2, 3] [(donor1C, -1), (vaultC, 1)] donor1C vaultC
def rec12 := recConst 12 [4, 5] [(donor2C, -2), (vaultC, 2)] donor2C vaultC
def rec14 := recConst 14 [0, 1] [(vaultC, -7), (recipientC, 7)] vaultC recipientC
def rec15 := recConst 15 [2, 3] [(vaultC, -6), (donor1C, 6)] vaultC donor1C
def rec16 := recConst 16 [7, 8] [(vaultC, -3), (donor1C, 3)] vaultC donor1C
def rec17 := recIdentity 17 [0]
def rec21 := recConst 21 [0, 1] [(vaultC, -7), (donor1C, 7)] vaultC donor1C
def rec200 := recProducer
def rec201 := recConsumer 6
def rec202 := recConst 202 [3, 4] [(donor1C, -1), (vaultC, 1)] donor1C vaultC
def rec203 := recConst 203 [5, 6] [(donor2C, -2), (vaultC, 2)] donor2C vaultC

def rec18 (src dst : P) (q : ℚ) (srcC dstC : C) (caps : List Nat) (budgetAmt : ℚ) :
    Receipt P A D :=
  .invoked ⟨⟨18⟩, [src, dst], [⟨.amount .usd, q⟩], ids caps, none⟩
    (evaluated true [(srcC, -q), (dstC, q)] [srcC] [srcC, dstC])
def rec19 (dst : P) (q : ℚ) (dstC : C) : Receipt P A D :=
  .invoked ⟨⟨19⟩, [dst], [⟨.amount .usd, q⟩], ids [4, 5], none⟩
    (evaluated true [(vaultC, -q), (dstC, q)] [vaultC] [vaultC, dstC])

def sr (w : W) (receipt : Receipt P A D) (outs : List (OutputObservation A) := []) : SR :=
  ⟨w, receipt, outs⟩
def ev (index : Nat) (inv : Inv) (before : W) (result : SR) : Ev :=
  ⟨index, .invoke inv, before, result⟩
def localSucc (evs : List Ev) (outs : List (OutputObservation A) := []) : LS :=
  ⟨evs.length, evs, outs, evs.length, none⟩
def localFail (consumed nextIndex : Nat) (evs : List Ev)
    (outs : List (OutputObservation A)) (failure : LocatedFailure P A D) : LS :=
  ⟨consumed, evs, outs, nextIndex, some failure⟩
def emptyLocal : LS := {}

def locals3 (l0 l1 l2 : LS) : Fin 3 → LS :=
  fun b ↦ if b = 0 then l0 else if b = 1 then l1 else l2
def locals2 (l0 l1 : LS) : Fin 2 → LS :=
  fun b ↦ if b = 0 then l0 else l1
def emptyLocals3 : Fin 3 → LS := fun _ ↦ emptyLocal
def emptyMachine3 (w : W) : M3 := ⟨w, emptyLocals3, []⟩

def attempt3 (b : Fin 3) (index : Nat) (inv : Inv) (before : W)
    (outcome : Except Composition.Failure SR) : Attempt (Fin 3) P A D :=
  ⟨b, index, inv, before, outcome⟩

def budgetOut (index : Nat) (amount : ℚ := 6) : OutputObservation A :=
  ⟨index, name 0 7, ⟨.amount .usd, amount⟩⟩

def toFin3 : Nat → Fin 3
  | 0 => 0
  | 1 => 1
  | _ => 2
def sched3 (ns : List Nat) : List (Fin 3) := ns.map toFin3

def fin3Roster : Roster (Fin 3) where
  order := [0, 1, 2]
  nodup := by decide
  complete := by
    intro b
    match b with
    | ⟨0, _⟩ => exact List.Mem.head _
    | ⟨1, _⟩ => exact List.Mem.tail _ (List.Mem.head _)
    | ⟨2, _⟩ => exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))

def fin2Roster : Roster (Fin 2) where
  order := [0, 1]
  nodup := by decide
  complete := by
    intro b
    match b with
    | ⟨0, _⟩ => exact List.Mem.head _
    | ⟨1, _⟩ => exact List.Mem.tail _ (List.Mem.head _)

def unitRoster : Roster Unit :=
  Roster.singleton () (fun x ↦ by cases x; rfl)

def emptyRoster : Roster Empty :=
  Roster.empty Empty.elim

def binaryRoster : Roster BranchId where
  order := [.left, .right]
  nodup := by decide
  complete := fun b ↦ by cases b <;> simp

def fundedBounds : Boundaries (Fin 3) P A D :=
  fun b _ ↦ if b = 0 then vaultBound else if b = 1 then donor1Bound else donor2Bound
def fundedBranches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv10] else if b = 1 then [inv11] else [inv12]
def f02Schedule : Schedule (Fin 3) := [0, 1, 2]

def f02Ev0 := ev 0 inv10 f02Initial (sr f02After0 rec10)
def f02Ev1 := ev 0 inv11 f02After0 (sr f02After1 rec11)
def f02Ev2 := ev 0 inv12 f02After1 (sr f02After2 rec12)
def f02At0 := attempt3 0 0 inv10 f02Initial (.ok (sr f02After0 rec10))
def f02At1 := attempt3 1 0 inv11 f02After0 (.ok (sr f02After1 rec11))
def f02At2 := attempt3 2 0 inv12 f02After1 (.ok (sr f02After2 rec12))
def f02Expected : M3 :=
  ⟨f02After2, locals3 (localSucc [f02Ev0]) (localSucc [f02Ev1]) (localSucc [f02Ev2]),
    [f02At0, f02At1, f02At2]⟩

def f01UnknownBranches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv10] else if b = 1 then [inv11, inv999] else [inv12]
def f01ValidBranches : Branches (Fin 3) P A D := fundedBranches
def f01MismatchSchedule : Schedule (Fin 3) := [0, 1]
def f01BothBadSchedule : Schedule (Fin 3) := [0]
def f01ExpectedConfig : AdmissionFailure (Fin 3) P A D := .configuration
def f01ExpectedUnknown : AdmissionFailure (Fin 3) P A D :=
  .structural 1 ⟨1, .interface .unknownOperation⟩
def f01ExpectedFinal : AdmissionFailure (Fin 3) P A D :=
  .schedule ⟨2, 1, 0⟩

def f03Branches : Branches BranchId P A D :=
  fun b ↦ match b with | .left => [inv14] | .right => [inv15]
def f03Bounds : Boundaries BranchId P A D := fun _ _ ↦ vaultBound
def f03LR : Schedule BranchId := [.left, .right]
def f03RL : Schedule BranchId := [.right, .left]
def f03EmptySched : Schedule BranchId := []
def f03BothCount : ScheduleMismatch BranchId := ⟨.left, 1, 0⟩
def f03FourNats : Nat × Nat × Nat × Nat := (1, 0, 1, 0)
def f03LeftFail : LocatedFailure P A D :=
  ⟨0, some (.invoke inv14), .kernel .guard⟩
def f03RightFail : LocatedFailure P A D :=
  ⟨0, some (.invoke inv15), .kernel .guard⟩
def f03LRExpected : MB :=
  ⟨f03AfterLeft,
    fun b ↦ match b with
      | .left => localSucc [ev 0 inv14 f03Initial (sr f03AfterLeft rec14)]
      | .right => localFail 1 0 [] [] f03RightFail,
    [⟨.left, 0, inv14, f03Initial, .ok (sr f03AfterLeft rec14)⟩,
      ⟨.right, 0, inv15, f03AfterLeft, .error (.kernel .guard)⟩]⟩
def f03RLExpected : MB :=
  ⟨f03AfterRight,
    fun b ↦ match b with
      | .left => localFail 1 0 [] [] f03LeftFail
      | .right => localSucc [ev 0 inv15 f03Initial (sr f03AfterRight rec15)],
    [⟨.right, 0, inv15, f03Initial, .ok (sr f03AfterRight rec15)⟩,
      ⟨.left, 0, inv14, f03AfterRight, .error (.kernel .guard)⟩]⟩

def unitBounds : Boundaries Unit P A D := fun _ _ ↦ vaultBound
def unitBranches : Branches Unit P A D := fun _ ↦ [inv10]
def unitComplete : Schedule Unit := [()]
def unitMissing : Schedule Unit := []
def emptyBounds : Boundaries Empty P A D := fun b ↦ nomatch b
def emptyBranches : Branches Empty P A D := fun b ↦ nomatch b
def emptySchedule : Schedule Empty := []
def f04Expected : MU :=
  ⟨f04After, fun _ ↦ localSucc [ev 0 inv10 f04Initial (sr f04After rec10)],
    [⟨(), 0, inv10, f04Initial, .ok (sr f04After rec10)⟩]⟩
def f04EmptyExpected : ME := ⟨f04Initial, fun b ↦ nomatch b, []⟩
def f04Missing : AdmissionFailure Unit P A D := .schedule ⟨(), 1, 0⟩

def f05Prod0 := inv18 .donor0 .budget 6 [0, 1]
def f05Prod1 := inv18 .budget .donor1 4 [2, 3]
def f05Cons0 := inv19 .recipient [4, 5]
def f05Cons1 := inv19 .recipient1 [4, 5]
def f05Bounds : Boundaries (Fin 2) P A D :=
  fun b _ ↦ if b = 0 then donor0Bound else budgetBound
def f05ConsBounds : Boundaries (Fin 2) P A D :=
  fun _ _ ↦ vaultBound
/-- Producers run under donor0/budget; consumers under vault. Index0 vs index1. -/
def f05AllBounds : Boundaries (Fin 2) P A D :=
  fun b idx ↦
    if idx = 0 then (if b = 0 then donor0Bound else budgetBound) else vaultBound
def f05Branches : Branches (Fin 2) P A D :=
  fun b ↦ if b = 0 then [f05Prod0, f05Cons0] else [f05Prod1, f05Cons1]
def f05Schedule : Schedule (Fin 2) := [0, 1, 0, 1]
def f05AfterProd0 : W := mkWorld 10 0 0 0 0 0 6 0 f05Store
def f05AfterProd1 : W := mkWorld 10 0 4 0 0 0 2 0 f05Store
def f05AfterCons0 : W := mkWorld 4 0 4 0 6 0 2 0 f05Store
def f05AfterCons1 : W := mkWorld 2 0 4 0 6 2 2 0 f05Store
def rec18a := rec18 .donor0 .budget 6 donor0C budgetC [0, 1] 6
def rec18b := rec18 .budget .donor1 4 budgetC donor1C [2, 3] 2
def rec19a := rec19 .recipient 6 recipientC
def rec19b := rec19 .recipient1 2 recipient1C
def f05Out0 := budgetOut 0 6
def f05Out1 := budgetOut 0 2
def f05EvP0 := ev 0 f05Prod0 f05Initial (sr f05AfterProd0 rec18a [f05Out0])
def f05EvP1 := ev 0 f05Prod1 f05AfterProd0 (sr f05AfterProd1 rec18b [f05Out1])
def f05EvC0 := ev 1 f05Cons0 f05AfterProd1 (sr f05AfterCons0 rec19a)
def f05EvC1 := ev 1 f05Cons1 f05AfterCons0 (sr f05AfterCons1 rec19b)
def f05Expected : M2 :=
  ⟨f05AfterCons1,
    locals2 (localSucc [f05EvP0, f05EvC0] [f05Out0]) (localSucc [f05EvP1, f05EvC1] [f05Out1]),
    [⟨0, 0, f05Prod0, f05Initial, .ok (sr f05AfterProd0 rec18a [f05Out0])⟩,
      ⟨1, 0, f05Prod1, f05AfterProd0, .ok (sr f05AfterProd1 rec18b [f05Out1])⟩,
      ⟨0, 1, f05Cons0, f05AfterProd1, .ok (sr f05AfterCons0 rec19a)⟩,
      ⟨1, 1, f05Cons1, f05AfterCons0, .ok (sr f05AfterCons1 rec19b)⟩]⟩
def f05SharedBranches : Branches (Fin 2) P A D :=
  fun _ ↦ [inv10]
def f05SharedBounds : Boundaries (Fin 2) P A D := fun _ _ ↦ vaultBound

def f06Bounds : Boundaries (Fin 3) P A D :=
  fun b idx ↦
    if b = 0 then (if idx = 0 then vaultBound else adminBound) else donor1Bound
def f06Branches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv10, inv10] else if b = 1 then [inv11] else []
def f06Schedule : Schedule (Fin 3) := [0, 0, 1]
def f06Fail : LocatedFailure P A D :=
  ⟨1, some (.invoke inv10), .kernel .unauthorizedInvoke⟩
def f06Expected : M3 :=
  ⟨f02After1,
    locals3
      (localFail 2 1 [f02Ev0] [] f06Fail)
      (localSucc [ev 0 inv11 f02After0 (sr f02After1 rec11)])
      emptyLocal,
    [f02At0,
      attempt3 0 1 inv10 f02After0 (.error (.kernel .unauthorizedInvoke)),
      attempt3 1 0 inv11 f02After0 (.ok (sr f02After1 rec11))]⟩

def f07Initial : W := mkWorld 10 0 2 3 0 0 6 0 f07Store
def f07After0 : W := mkWorld 9 0 2 3 1 0 6 0 f07Store
def f07After1 : W := mkWorld 10 0 1 3 1 0 6 0 f07Store
def f07After2 : W := mkWorld 12 0 1 1 1 0 6 0 f07Store
def f07Branches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv10, inv13] else if b = 1 then [inv11] else [inv12]
def f07Bounds : Boundaries (Fin 3) P A D :=
  fun b _ ↦ if b = 0 then vaultBound else if b = 1 then donor1Bound else donor2Bound
def f07Schedule : Schedule (Fin 3) := [0, 0, 0, 1, 2]
def f07Fail : LocatedFailure P A D :=
  ⟨1, some (.invoke inv13), .kernel .guard⟩
def rec10s := recConst 10 [0, 1] [(vaultC, -1), (recipientC, 1)] vaultC recipientC
def rec11s := recConst 11 [2, 3] [(donor1C, -1), (vaultC, 1)] donor1C vaultC
def rec12s := recConst 12 [4, 5] [(donor2C, -2), (vaultC, 2)] donor2C vaultC
def f07Ev0 := ev 0 inv10 f07Initial (sr f07After0 rec10s)
def f07Expected : M3 :=
  ⟨f07After2,
    locals3
      (localFail 3 1 [f07Ev0] [] f07Fail)
      (localSucc [ev 0 inv11 f07After0 (sr f07After1 rec11s)])
      (localSucc [ev 0 inv12 f07After1 (sr f07After2 rec12s)]),
    [attempt3 0 0 inv10 f07Initial (.ok (sr f07After0 rec10s)),
      attempt3 0 1 inv13 f07After0 (.error (.kernel .guard)),
      attempt3 1 0 inv11 f07After0 (.ok (sr f07After1 rec11s)),
      attempt3 2 0 inv12 f07After1 (.ok (sr f07After2 rec12s))]⟩

def f08Branches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv10] else []
def f08Bounds : Boundaries (Fin 3) P A D := fundedBounds
def f08Prefix : Schedule (Fin 3) := [0, 0]
def f08After : W := mkWorld 9 0 2 3 1 0 6 0 f02Store
def f08Expected : M3 :=
  ⟨f08After,
    locals3 (⟨2, [ev 0 inv10 f02Initial (sr f08After rec10)], [], 1, none⟩) emptyLocal emptyLocal,
    [attempt3 0 0 inv10 f02Initial (.ok (sr f08After rec10))]⟩

def f09Old0 : W := mkWorld 10 0 2 3 0 0 6 0 f02Store
def f09Old1 : W := mkWorld 9 0 2 3 1 0 6 0 f02Store
def f09EntryWorld : W := mkWorld 8 0 2 3 2 0 6 0 f02Store
def f09Fail : LocatedFailure P A D :=
  ⟨1, some (.invoke inv11), .kernel .guard⟩
def f09EvA := ev 0 inv10 f09Old0 (sr f09Old1 rec10)
def f09EvB := ev 1 inv10 f09Old1 (sr f09EntryWorld rec10)
def f09Entry : M3 :=
  ⟨f09EntryWorld,
    locals3
      ⟨2, [f09EvA, f09EvB], [], 2, none⟩
      (localFail 3 1 [] [] f09Fail)
      emptyLocal,
    [attempt3 0 0 inv10 f09Old0 (.ok (sr f09Old1 rec10)),
      attempt3 0 1 inv10 f09Old1 (.ok (sr f09EntryWorld rec10)),
      attempt3 1 1 inv11 f09Old1 (.error (.kernel .guard))]⟩
def f09Suffix : Schedule (Fin 3) := [2]
def f09After : W := mkWorld 10 0 2 1 2 0 6 0 f02Store
def f09Expected : M3 :=
  ⟨f09After,
    locals3
      ⟨2, [f09EvA, f09EvB], [], 2, none⟩
      (localFail 3 1 [] [] f09Fail)
      (localSucc [ev 0 inv12 f09EntryWorld (sr f09After rec12)]),
    f09Entry.attempts ++
      [attempt3 2 0 inv12 f09EntryWorld (.ok (sr f09After rec12))]⟩
def f09WorldDiff : M3 :=
  { f09Entry with world := mkWorld 0 0 0 0 0 0 0 0 f02Store }
def f09StoreDiff : M3 :=
  { f09Entry with world := mkWorld 8 0 2 3 2 0 6 0 (storeOf []) }
def f09LocalDiff : M3 :=
  { f09Entry with locals := locals3 { f09Entry.locals 0 with consumed := 99 }
    (f09Entry.locals 1) (f09Entry.locals 2) }
def f09ReceiptDiff : M3 :=
  let loc0 := f09Entry.locals 0
  let badEv := match loc0.events with
    | e :: rest =>
        { e with result := { e.result with receipt := recIdentity 10 [0, 1] } } :: rest
    | [] => loc0.events
  { f09Entry with locals := locals3 { loc0 with events := badEv }
    (f09Entry.locals 1) (f09Entry.locals 2) }
def f09OutputDiff : M3 :=
  { f09Entry with locals := locals3 { f09Entry.locals 0 with outputs := [budgetOut 0] }
    (f09Entry.locals 1) (f09Entry.locals 2) }
def f09FailureDiff : M3 :=
  { f09Entry with locals := locals3
    { f09Entry.locals 0 with failure := some f09Fail }
    (f09Entry.locals 1) (f09Entry.locals 2) }
def f09AttemptDiff : M3 :=
  match f09Entry.attempts with
  | a :: rest => { f09Entry with attempts := { a with participant := 2 } :: rest }
  | [] => f09Entry
def f09RawEventDiff : M3 :=
  let loc0 := f09Entry.locals 0
  let badEv := match loc0.events with
    | e :: rest => { e with before := f09After } :: rest
    | [] => loc0.events
  { f09Entry with locals := locals3 { loc0 with events := badEv }
    (f09Entry.locals 1) (f09Entry.locals 2) }

inductive ReservePhase where
  | awaiting | ready6 | consumed
  deriving DecidableEq, Repr

structure F10Row where
  schedule : List Nat
  participant : Nat
  ownIndex : Nat
  operation : Nat
  before : List ℚ
  after : List ℚ
  producerOutput : Bool
  monitor : ReservePhase
  localsNC : List Nat

/-- Literal F10 prefix table copied from accepted fixtures.json; 10−6=4, 4+1=5, 5+2=7 and
the eleven sibling schedules. Values are not taken from a Nary run. -/
def f10OracleRows : List F10Row := [
  ⟨[0, 0, 1, 2], 0, 0, 200, [10, 2, 3, 0, 6, 0], [10, 2, 3, 0, 6, 0], true, .ready6, [1, 0, 0]⟩,
  ⟨[0, 0, 1, 2], 0, 1, 201, [10, 2, 3, 0, 6, 0], [4, 2, 3, 6, 6, 0], false, .consumed, [2, 0, 0]⟩,
  ⟨[0, 0, 1, 2], 1, 0, 202, [4, 2, 3, 6, 6, 0], [5, 1, 3, 6, 6, 0], false, .consumed, [2, 1, 0]⟩,
  ⟨[0, 0, 1, 2], 2, 0, 203, [5, 1, 3, 6, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[0, 0, 2, 1], 0, 0, 200, [10, 2, 3, 0, 6, 0], [10, 2, 3, 0, 6, 0], true, .ready6, [1, 0, 0]⟩,
  ⟨[0, 0, 2, 1], 0, 1, 201, [10, 2, 3, 0, 6, 0], [4, 2, 3, 6, 6, 0], false, .consumed, [2, 0, 0]⟩,
  ⟨[0, 0, 2, 1], 2, 0, 203, [4, 2, 3, 6, 6, 0], [6, 2, 1, 6, 6, 0], false, .consumed, [2, 0, 1]⟩,
  ⟨[0, 0, 2, 1], 1, 0, 202, [6, 2, 1, 6, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[0, 1, 0, 2], 0, 0, 200, [10, 2, 3, 0, 6, 0], [10, 2, 3, 0, 6, 0], true, .ready6, [1, 0, 0]⟩,
  ⟨[0, 1, 0, 2], 1, 0, 202, [10, 2, 3, 0, 6, 0], [11, 1, 3, 0, 6, 0], false, .ready6, [1, 1, 0]⟩,
  ⟨[0, 1, 0, 2], 0, 1, 201, [11, 1, 3, 0, 6, 0], [5, 1, 3, 6, 6, 0], false, .consumed, [2, 1, 0]⟩,
  ⟨[0, 1, 0, 2], 2, 0, 203, [5, 1, 3, 6, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[0, 1, 2, 0], 0, 0, 200, [10, 2, 3, 0, 6, 0], [10, 2, 3, 0, 6, 0], true, .ready6, [1, 0, 0]⟩,
  ⟨[0, 1, 2, 0], 1, 0, 202, [10, 2, 3, 0, 6, 0], [11, 1, 3, 0, 6, 0], false, .ready6, [1, 1, 0]⟩,
  ⟨[0, 1, 2, 0], 2, 0, 203, [11, 1, 3, 0, 6, 0], [13, 1, 1, 0, 6, 0], false, .ready6, [1, 1, 1]⟩,
  ⟨[0, 1, 2, 0], 0, 1, 201, [13, 1, 1, 0, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[0, 2, 0, 1], 0, 0, 200, [10, 2, 3, 0, 6, 0], [10, 2, 3, 0, 6, 0], true, .ready6, [1, 0, 0]⟩,
  ⟨[0, 2, 0, 1], 2, 0, 203, [10, 2, 3, 0, 6, 0], [12, 2, 1, 0, 6, 0], false, .ready6, [1, 0, 1]⟩,
  ⟨[0, 2, 0, 1], 0, 1, 201, [12, 2, 1, 0, 6, 0], [6, 2, 1, 6, 6, 0], false, .consumed, [2, 0, 1]⟩,
  ⟨[0, 2, 0, 1], 1, 0, 202, [6, 2, 1, 6, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[0, 2, 1, 0], 0, 0, 200, [10, 2, 3, 0, 6, 0], [10, 2, 3, 0, 6, 0], true, .ready6, [1, 0, 0]⟩,
  ⟨[0, 2, 1, 0], 2, 0, 203, [10, 2, 3, 0, 6, 0], [12, 2, 1, 0, 6, 0], false, .ready6, [1, 0, 1]⟩,
  ⟨[0, 2, 1, 0], 1, 0, 202, [12, 2, 1, 0, 6, 0], [13, 1, 1, 0, 6, 0], false, .ready6, [1, 1, 1]⟩,
  ⟨[0, 2, 1, 0], 0, 1, 201, [13, 1, 1, 0, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[1, 0, 0, 2], 1, 0, 202, [10, 2, 3, 0, 6, 0], [11, 1, 3, 0, 6, 0], false, .awaiting, [0, 1, 0]⟩,
  ⟨[1, 0, 0, 2], 0, 0, 200, [11, 1, 3, 0, 6, 0], [11, 1, 3, 0, 6, 0], true, .ready6, [1, 1, 0]⟩,
  ⟨[1, 0, 0, 2], 0, 1, 201, [11, 1, 3, 0, 6, 0], [5, 1, 3, 6, 6, 0], false, .consumed, [2, 1, 0]⟩,
  ⟨[1, 0, 0, 2], 2, 0, 203, [5, 1, 3, 6, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[1, 0, 2, 0], 1, 0, 202, [10, 2, 3, 0, 6, 0], [11, 1, 3, 0, 6, 0], false, .awaiting, [0, 1, 0]⟩,
  ⟨[1, 0, 2, 0], 0, 0, 200, [11, 1, 3, 0, 6, 0], [11, 1, 3, 0, 6, 0], true, .ready6, [1, 1, 0]⟩,
  ⟨[1, 0, 2, 0], 2, 0, 203, [11, 1, 3, 0, 6, 0], [13, 1, 1, 0, 6, 0], false, .ready6, [1, 1, 1]⟩,
  ⟨[1, 0, 2, 0], 0, 1, 201, [13, 1, 1, 0, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[1, 2, 0, 0], 1, 0, 202, [10, 2, 3, 0, 6, 0], [11, 1, 3, 0, 6, 0], false, .awaiting, [0, 1, 0]⟩,
  ⟨[1, 2, 0, 0], 2, 0, 203, [11, 1, 3, 0, 6, 0], [13, 1, 1, 0, 6, 0], false, .awaiting, [0, 1, 1]⟩,
  ⟨[1, 2, 0, 0], 0, 0, 200, [13, 1, 1, 0, 6, 0], [13, 1, 1, 0, 6, 0], true, .ready6, [1, 1, 1]⟩,
  ⟨[1, 2, 0, 0], 0, 1, 201, [13, 1, 1, 0, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[2, 0, 0, 1], 2, 0, 203, [10, 2, 3, 0, 6, 0], [12, 2, 1, 0, 6, 0], false, .awaiting, [0, 0, 1]⟩,
  ⟨[2, 0, 0, 1], 0, 0, 200, [12, 2, 1, 0, 6, 0], [12, 2, 1, 0, 6, 0], true, .ready6, [1, 0, 1]⟩,
  ⟨[2, 0, 0, 1], 0, 1, 201, [12, 2, 1, 0, 6, 0], [6, 2, 1, 6, 6, 0], false, .consumed, [2, 0, 1]⟩,
  ⟨[2, 0, 0, 1], 1, 0, 202, [6, 2, 1, 6, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[2, 0, 1, 0], 2, 0, 203, [10, 2, 3, 0, 6, 0], [12, 2, 1, 0, 6, 0], false, .awaiting, [0, 0, 1]⟩,
  ⟨[2, 0, 1, 0], 0, 0, 200, [12, 2, 1, 0, 6, 0], [12, 2, 1, 0, 6, 0], true, .ready6, [1, 0, 1]⟩,
  ⟨[2, 0, 1, 0], 1, 0, 202, [12, 2, 1, 0, 6, 0], [13, 1, 1, 0, 6, 0], false, .ready6, [1, 1, 1]⟩,
  ⟨[2, 0, 1, 0], 0, 1, 201, [13, 1, 1, 0, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩,
  ⟨[2, 1, 0, 0], 2, 0, 203, [10, 2, 3, 0, 6, 0], [12, 2, 1, 0, 6, 0], false, .awaiting, [0, 0, 1]⟩,
  ⟨[2, 1, 0, 0], 1, 0, 202, [12, 2, 1, 0, 6, 0], [13, 1, 1, 0, 6, 0], false, .awaiting, [0, 1, 1]⟩,
  ⟨[2, 1, 0, 0], 0, 0, 200, [13, 1, 1, 0, 6, 0], [13, 1, 1, 0, 6, 0], true, .ready6, [1, 1, 1]⟩,
  ⟨[2, 1, 0, 0], 0, 1, 201, [13, 1, 1, 0, 6, 0], [7, 1, 1, 6, 6, 0], false, .consumed, [2, 1, 1]⟩]

def f10Schedules : List (List (Fin 3)) := [
  [0, 0, 1, 2], [0, 0, 2, 1], [0, 1, 0, 2], [0, 1, 2, 0], [0, 2, 0, 1], [0, 2, 1, 0],
  [1, 0, 0, 2], [1, 0, 2, 0], [1, 2, 0, 0], [2, 0, 0, 1], [2, 0, 1, 0], [2, 1, 0, 0]]

def f10Final : W := mkWorld 7 0 1 1 6 0 6 0 f10Store
def f10Branches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv200, inv201] else if b = 1 then [inv202] else [inv203]
def f10Bounds : Boundaries (Fin 3) P A D :=
  fun b _ ↦ if b = 0 then vaultBound else if b = 1 then donor1Bound else donor2Bound

def worldOfMain : List ℚ → W
  | [v, d1, d2, r, b, a] => mkWorld v 0 d1 d2 r 0 b a f10Store
  | _ => f10Initial

def invOf : Nat → Inv
  | 200 => inv200
  | 201 => inv201
  | 202 => inv202
  | 203 => inv203
  | _ => inv200

def receiptOf : Nat → Receipt P A D
  | 200 => rec200
  | 201 => rec201
  | 202 => rec202
  | 203 => rec203
  | _ => rec200

def rowsFor (sched : List Nat) : List F10Row :=
  f10OracleRows.filter (fun row ↦ row.schedule = sched)

def expectAccept (m : M3) (row : F10Row) : M3 :=
  let b := toFin3 row.participant
  let before := worldOfMain row.before
  let after := worldOfMain row.after
  let inv := invOf row.operation
  let outs := if row.producerOutput then [budgetOut row.ownIndex] else []
  let result := sr after (receiptOf row.operation) outs
  let own := m.locals b
  let event := ev row.ownIndex inv before result
  let loc : LS := ⟨own.consumed + 1, own.events ++ [event], own.outputs ++ outs,
    own.nextIndex + 1, none⟩
  ⟨after, fun p ↦ if p = b then loc else m.locals p,
    m.attempts ++ [attempt3 b row.ownIndex inv before (.ok result)]⟩

def expectedF10 (sched : List Nat) : M3 :=
  (rowsFor sched).foldl expectAccept (emptyMachine3 f10Initial)

def expectedF10Phase (sched : List Nat) : ReservePhase :=
  match (rowsFor sched).getLast? with
  | some row => row.monitor
  | none => .awaiting

def f10ProducerPrefix : List Nat := [0]
def f10ProducerThenDeposit : List Nat := [0, 1]
def f10ExtraSkip : Schedule (Fin 3) := [0, 0, 1, 2, 0]

def isReadyProducer (attempt : Attempt (Fin 3) P A D) : Bool :=
  decide (attempt.participant = 0 ∧ attempt.index = 0 ∧ attempt.invocation.operation = ⟨200⟩) &&
    match attempt.outcome with
    | .ok result => decide (result.outputs = [budgetOut 0] ∧ result.receipt = rec200)
    | .error _ => false

def isConsumedConsumer (attempt : Attempt (Fin 3) P A D) : Bool :=
  decide (attempt.participant = 0 ∧ attempt.index = 1 ∧ attempt.invocation.operation = ⟨201⟩) &&
    match attempt.outcome with
    | .ok result => decide (result.receipt = rec201)
    | .error _ => false

def reserveUpdate (q : ReservePhase) (input : MonitorInput (Fin 3) P A D) : ReservePhase :=
  match input.attempt with
  | none => q
  | some attempt =>
    match q with
    | .awaiting => if isReadyProducer attempt then .ready6 else .awaiting
    | .ready6 => if isConsumedConsumer attempt then .consumed else .ready6
    | .consumed => .consumed

def countUpdate (n : Nat) (input : MonitorInput (Fin 3) P A D) : Nat :=
  match input.attempt with
  | some _ => n + 1
  | none => n

def f11Branches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv14] else []
def f11Bounds : Boundaries (Fin 3) P A D := fun _ _ ↦ vaultBound
def f11Expected : M3 :=
  ⟨f11After, locals3 (localSucc [ev 0 inv14 f11Initial (sr f11After rec14)]) emptyLocal emptyLocal,
    [attempt3 0 0 inv14 f11Initial (.ok (sr f11After rec14))]⟩

def f12Initial : W := mkWorld 10 0 0 0 0 0 6 0 f12Store
def f12AfterProd : W := mkWorld 10 0 0 0 0 0 6 0 f12Store
def f12AfterPeer : W := mkWorld 7 0 3 0 0 0 6 0 f12Store
def f12AfterCons : W := mkWorld 1 0 3 0 6 0 6 0 f12Store
def f12Branches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv200, inv201] else if b = 1 then [inv16] else []
def f12Bounds : Boundaries (Fin 3) P A D :=
  fun b _ ↦ if b = 1 then vaultBound else if b = 0 then vaultBound else donor2Bound
def f12Schedule : Schedule (Fin 3) := [0, 1, 0]
def rec16s := recConst 16 [7, 8] [(vaultC, -3), (donor1C, 3)] vaultC donor1C
def f12Expected : M3 :=
  ⟨f12AfterCons,
    locals3
      (localSucc [ev 0 inv200 f12Initial (sr f12AfterProd rec200 [budgetOut 0]),
        ev 1 inv201 f12AfterPeer (sr f12AfterCons rec201)] [budgetOut 0])
      (localSucc [ev 0 inv16 f12AfterProd (sr f12AfterPeer rec16s)])
      emptyLocal,
    [attempt3 0 0 inv200 f12Initial (.ok (sr f12AfterProd rec200 [budgetOut 0])),
      attempt3 1 0 inv16 f12AfterProd (.ok (sr f12AfterPeer rec16s)),
      attempt3 0 1 inv201 f12AfterPeer (.ok (sr f12AfterCons rec201))]⟩

def f13Store : Store := storeOf [
  cap .vault 21 .invoke, cap .vault 21 (.debit vaultC)]
def f13Initial : W := mkWorld 10 0 0 0 0 0 0 0 f13Store
def f13After : W := mkWorld 3 0 7 0 0 0 0 0 f13Store
def f13Branches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 1 then [inv21] else []
def f13Bounds : Boundaries (Fin 3) P A D := fun _ _ ↦ vaultBound
def f13Expected : M3 :=
  ⟨f13After, locals3 emptyLocal
    (localSucc [ev 0 inv21 f13Initial (sr f13After rec21)]) emptyLocal,
    [attempt3 1 0 inv21 f13Initial (.ok (sr f13After rec21))]⟩

def f14Branches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv17] else if b = 1 then [inv17] else [inv17]
def f14Bounds : Boundaries (Fin 3) P A D := fun _ _ ↦ vaultBound
def f14Expected : M3 :=
  ⟨f14Initial,
    locals3
      (localSucc [ev 0 inv17 f14Initial (sr f14Initial rec17)])
      (localSucc [ev 0 inv17 f14Initial (sr f14Initial rec17)])
      (localSucc [ev 0 inv17 f14Initial (sr f14Initial rec17)]),
    [attempt3 0 0 inv17 f14Initial (.ok (sr f14Initial rec17)),
      attempt3 1 0 inv17 f14Initial (.ok (sr f14Initial rec17)),
      attempt3 2 0 inv17 f14Initial (.ok (sr f14Initial rec17))]⟩

def f15Left : Prop := False
def f15Right : Prop := False
def f15Implications : Bool := decide ((f15Left → f15Right) ∧ (f15Right → f15Left))
def f15Facts : Bool := decide (f15Left ∨ f15Right)

def f16Initial : W := mkWorld 10 0 2 0 0 0 6 0 f16Store
def f16AfterPeer : W := mkWorld 11 0 1 0 0 0 6 0 f16Store
def f16Branches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv210, inv201] else if b = 1 then [inv202] else []
def f16Bounds : Boundaries (Fin 3) P A D :=
  fun b _ ↦ if b = 0 then vaultBound else donor1Bound
def f16Schedule : Schedule (Fin 3) := [0, 0, 1]
def f16Fail : LocatedFailure P A D :=
  ⟨0, some (.invoke inv210), .kernel .guard⟩
def rec202s := recConst 202 [3, 4] [(donor1C, -1), (vaultC, 1)] donor1C vaultC
def f16Expected : M3 :=
  ⟨f16AfterPeer,
    locals3
      (localFail 2 0 [] [] f16Fail)
      (localSucc [ev 0 inv202 f16Initial (sr f16AfterPeer rec202s)])
      emptyLocal,
    [attempt3 0 0 inv210 f16Initial (.error (.kernel .guard)),
      attempt3 1 0 inv202 f16Initial (.ok (sr f16AfterPeer rec202s))]⟩

def f17Branches : Branches (Fin 3) P A D :=
  fun b ↦ if b = 0 then [inv200, inv201] else if b = 1 then [inv200] else []
def f17Bounds : Boundaries (Fin 3) P A D := fun _ _ ↦ vaultBound
def f17Schedule : Schedule (Fin 3) := [1]
def f17After : W := f10Initial
def f17Expected : M3 :=
  ⟨f17After,
    locals3 emptyLocal (localSucc [ev 0 inv200 f10Initial (sr f10Initial rec200 [budgetOut 0])]
      [budgetOut 0]) emptyLocal,
    [attempt3 1 0 inv200 f10Initial (.ok (sr f10Initial rec200 [budgetOut 0]))]⟩

abbrev IP := Interface.Examples.P
abbrev IA := Interface.Examples.A
abbrev ID := Interface.Examples.D
abbrev IW := Interface.Examples.W
abbrev IM3 := Machine (Fin 3) IP IA ID

def f18Cfg := Interface.Examples.cfg
def f18Initial := Interface.Examples.initial55
def f18Op := Interface.Examples.op102
def f18Receipt := Interface.Examples.receipt102
def f18Store := Interface.Examples.initialStore
def f18Region : Region IP IA ID :=
  ⟨.home, .usd, {Interface.Examples.alice, Interface.Examples.bob, Interface.Examples.carol}⟩
def f18Edges : List Binding := [(Interface.Examples.name 0, Interface.Examples.name 1)]
def f18EmptyEdges : List Binding := []
def f18Value : ℚ := 10
def f18Roster := fin3Roster
def f18Bounds : Boundaries (Fin 3) IP IA ID := fun _ _ ↦ Interface.Examples.boundary 0
def f18Branches : Branches (Fin 3) IP IA ID := fun _ ↦ [f18Op]
def f18Schedules : List (List (Fin 3)) := [
  [0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]

/-- After k successful op102 steps: alice/bob = 5−k, carol = 2k. 5−1=4, 5−2=3, 5−3=2. -/
def f18WorldAfter : Nat → IW
  | 0 => Interface.Examples.initial55
  | 1 => Interface.Examples.paired1
  | 2 => Interface.Examples.paired2
  | _ => Interface.Examples.world 2 2 6

def f18ResultAfter (n : Nat) : Interface.Examples.SR :=
  ⟨f18WorldAfter n, f18Receipt, []⟩

def expectedF18 (sched : List (Fin 3)) : IM3 :=
  Id.run do
    let mut w := f18Initial
    let mut locals : Fin 3 → Interleaving.LocalState IP IA ID := fun _ ↦ {}
    let mut attempts : List (Attempt (Fin 3) IP IA ID) := []
    let mut k : Nat := 0
    for b in sched do
      let before := w
      k := k + 1
      let after := f18WorldAfter k
      let result : StepResult IP IA ID := ⟨after, f18Receipt, []⟩
      let own := locals b
      let event : Event IP IA ID := ⟨0, .invoke f18Op, before, result⟩
      locals := fun p ↦ if p = b then
        ⟨own.consumed + 1, own.events ++ [event], own.outputs, own.nextIndex + 1, none⟩
      else locals p
      attempts := attempts ++ [⟨b, 0, f18Op, before, .ok result⟩]
      w := after
    pure ⟨w, locals, attempts⟩

def f19Op := Interface.Examples.op103
def f19Receipt := Interface.Examples.receipt103
def f19Branches : Branches (Fin 3) IP IA ID :=
  fun b ↦ if b = 0 then [f19Op] else []
def f19Schedule : Schedule (Fin 3) := [0]
def f19World : IW := Interface.Examples.world 4 5 1
def f19Expected : IM3 :=
  ⟨f19World,
    fun b ↦ if b = 0 then
      ⟨1, [⟨0, .invoke f19Op, f18Initial, ⟨f19World, f19Receipt, []⟩⟩], [], 1, none⟩
    else {},
    [⟨0, 0, f19Op, f18Initial, .ok ⟨f19World, f19Receipt, []⟩⟩]⟩
def f19BindingError : Except (BindingFailure IP IA ID) PUnit :=
  .error (.unequal 0 (Interface.Examples.name 0) (Interface.Examples.name 1) 4 5)

inductive EvidenceClass where
  | admissionRefusal
  | fundedExecution
  | binaryInstance
  | typedRoster
  | actualRefusal
  | arbitraryPrefix
  | syntheticObservation
  | genericProofInstance
  | fundedNegative
  | snapshotProvenanceNegative
  | logicalCounterexample
  | m2Instance
  | m2Negative
  deriving DecidableEq, Repr

def fixtureIds : List String :=
  ["F01", "F02", "F03", "F04", "F05", "F06", "F07", "F08", "F09",
    "F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17", "F18", "F19"]

def classification : String → EvidenceClass
  | "F01" => .admissionRefusal
  | "F02" => .fundedExecution
  | "F03" => .binaryInstance
  | "F04" => .typedRoster
  | "F05" => .fundedExecution
  | "F06" => .actualRefusal
  | "F07" => .fundedExecution
  | "F08" => .arbitraryPrefix
  | "F09" => .syntheticObservation
  | "F10" => .genericProofInstance
  | "F11" => .fundedNegative
  | "F12" => .fundedNegative
  | "F13" => .fundedNegative
  | "F14" => .fundedNegative
  | "F15" => .logicalCounterexample
  | "F16" => .actualRefusal
  | "F17" => .snapshotProvenanceNegative
  | "F18" => .m2Instance
  | "F19" => .m2Negative
  | _ => .logicalCounterexample

def mutationFalseLabels : List String := [
  "nary.admission.suffix_precedence",
  "nary.boundary.index1",
  "nary.history.own_input",
  "nary.monitor.actual_producer",
  "nary.monitor.retained_phase",
  "nary.monitor.skip_no_replay",
  "nary.monitor.success_input",
  "nary.receipt.evaluated",
  "nary.refusal.attempt",
  "nary.refusal.peer_continues",
  "nary.routing.locals",
  "nary.schedule.final_participant",
  "nary.skip.consumed",
  "nary.store.exact",
  "nary.success.index",
  "nary.world.exact"]

def protectedPositiveLabels : List String := [
  "nary.empty.exact",
  "nary.no_failure.exact",
  "nary.monitor.actual_producer",
  "nary.routing.locals"]

-- BEGIN PROOFS

end DefiKernel.Nary.Examples
