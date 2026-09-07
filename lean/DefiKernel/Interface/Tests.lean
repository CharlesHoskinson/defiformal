import DefiKernel.Interface.Examples
import DefiKernel.Interface.Bindings

/-! Executed full-data financial comparisons. All expected worlds/receipts/events come from
literal Examples data; query expectations are written exact constructors. -/
namespace DefiKernel.Interface.Tests
open Typed Composition Examples

def pairRegion : Region P A D := ⟨.home, .usd, {alice, bob}⟩
def singleRegion : Region P A D := ⟨.home, .usd, {alice}⟩
def tripleRegion : Region P A D := ⟨.home, .usd, {alice, bob, carol}⟩
def emptyRegion : Region P A D := ⟨.home, .usd, ∅⟩
def duplicateRegion : Region P A D := ⟨.home, .usd, {alice, alice, bob}⟩
def mixedRegion : Region P A D := ⟨.home, .usd, {alice, awayEur}⟩
def wellFormed (region : Region P A D) : Bool :=
  decide (∀ c ∈ region.cells, c.1 = region.domain ∧ c.2.2 = region.asset)
def equalEdge : List Binding := [(name 0, name 1)]
def transitiveEdges : List Binding := [(name 0, name 1), (name 1, name 2)]
def redundantEdges := transitiveEdges ++ [(name 0, name 2)]
/-- Fixture-only extraction of cross-cut edges: both A and C are on the first side.
The production query always receives the global list; this is the omitted-edge counterexample. -/
def cutSide : Finset QualifiedPort := {name 0, name 2}
def cutExtracted : List Binding := [(name 0, name 2)].filter (fun edge ↦
  decide ((edge.1 ∈ cutSide ∧ edge.2 ∉ cutSide) ∨
    (edge.1 ∉ cutSide ∧ edge.2 ∈ cutSide)))
def invalidCfg : Config P A D := { cfg with catalog := cfg.catalog ++ [exporter 0 alice] }

def worldEq (x y : W) : Bool :=
  decide ((∀ c, x.state.balance c = y.state.balance c) ∧ x.capabilities = y.capabilities)
def resultEq (x y : SR) : Bool :=
  worldEq x.world y.world && decide (x.receipt = y.receipt ∧ x.outputs = y.outputs)
def outcomeEq (x y : Except Composition.Failure SR) : Bool :=
  match x, y with
  | .error a, .error b => decide (a = b)
  | .ok a, .ok b => resultEq a b
  | _, _ => false
def eventEq (x y : Ev) : Bool :=
  decide (x.index = y.index ∧ x.step = y.step) && worldEq x.before y.before &&
    resultEq x.result y.result
def eventsEq (xs ys : List Ev) : Bool :=
  decide (xs.length = ys.length) && (xs.zip ys).all (fun (x, y) ↦ eventEq x y)
def cursorEq (x y : Cur) : Bool :=
  worldEq x.world y.world && eventsEq x.events y.events &&
    decide (x.outputs = y.outputs ∧ x.nextIndex = y.nextIndex ∧ x.failure = y.failure)
def localEq (x y : Interleaving.LocalState P A D) : Bool :=
  eventsEq x.events y.events && decide (x.consumed = y.consumed ∧
    x.outputs = y.outputs ∧ x.nextIndex = y.nextIndex ∧ x.failure = y.failure)
def attemptEq (x y : Interleaving.Attempt P A D) : Bool :=
  decide (x.branch = y.branch ∧ x.index = y.index ∧ x.invocation = y.invocation) &&
    worldEq x.before y.before && outcomeEq x.outcome y.outcome
def machineEq (x y : Interleaving.Machine P A D) : Bool :=
  worldEq x.world y.world && localEq x.left y.left && localEq x.right y.right &&
    decide (x.attempts.length = y.attempts.length) &&
      (x.attempts.zip y.attempts).all (fun (a, b) ↦ attemptEq a b)
def sharedEq (x : Interleaving.Result P A D) (schedule : Interleaving.Schedule)
    (expected : Interleaving.Machine P A D) : Bool :=
  match x with
  | .refused _ _ _ => false
  | .executed actual machine => decide (actual = schedule) && machineEq machine expected

def execute (inv : Inv) (entry : W := initial64) (config : Config P A D := cfg) :=
  executeStep config (boundary 0) 0 [] (.invoke inv) entry

def transfer := execute op100
def minted := execute op101
def repeatedRun := execute op104
def pairedRun := execute op102 initial55
def oneSidedRun := execute op103 initial55

def resultHas (actual : Except Composition.Failure SR) (predicate : SR → Bool) : Bool :=
  match actual with | .ok result => predicate result | .error _ => false

def groupFirst := Metatheory.runGroup cfg boundary initialCursor (.step (.invoke op102))
def groupBoth := Metatheory.runGroup cfg boundary initialCursor pairedGroup
def snapshotFirstRun := Metatheory.runGroup snapshotCfg boundary arbitraryEntry
  (.step (.invoke op100))
def snapshotRun := Metatheory.runGroup snapshotCfg boundary arbitraryEntry snapshotGroup

def catalogChecks : List (String × Bool) := [
  ("interface.catalog.valid", validateCatalog cfg.registry cfg.catalog),
  ("interface.catalog.private-total", validateCatalog cfg.registry (catalog false)),
  ("interface.catalog.exposed-total", validateCatalog exposedCfg.registry exposedCfg.catalog),
  ("interface.catalog.snapshot", validateCatalog snapshotCfg.registry snapshotCfg.catalog),
  ("interface.catalog.invalid", !validateCatalog invalidCfg.registry invalidCfg.catalog),
  ("interface.fixture.twenty-cells", decide (allCells.card = 20)),
  ("interface.fixture.seventeen-capabilities", decide (initialStore.entries.length = 17))
]

/-- This global positive deliberately uses production receiptDelta on an invoked neutral
receipt. It avoids balanceSum/checkBindings. Its zero is preserved by M02–05 and M14. -/
def positiveTransfer : Bool := outcomeEq transfer (.ok expected100) &&
  resultHas transfer (fun r ↦ decide (receiptDelta pairRegion r.receipt = 0))

def regionChecks : List (String × Bool) := [
  ("interface.positive.transfer", positiveTransfer),
  ("interface.region.sum", decide (balanceSum pairRegion initial64.state = 10)),
  ("interface.region.empty", decide (balanceSum emptyRegion initial64.state = 0)),
  ("interface.region.duplicate-insertion", decide
    (balanceSum duplicateRegion initial64.state = 10 ∧ duplicateRegion.cells.card = 2)),
  ("interface.region.mixed-dimensions", !wellFormed mixedRegion && decide
    (balanceSum mixedRegion (world 5 0 0 0 0 0 5).state = 10)),
  ("interface.region.missing-initialization", resultHas transfer (fun r ↦
    decide (balanceSum pairRegion initial64.state = 10 ∧
      balanceSum pairRegion r.world.state = 10 ∧ receiptDelta pairRegion r.receipt = 0 ∧
      balanceSum pairRegion initial64.state ≠ 11 ∧ balanceSum pairRegion r.world.state ≠ 11))),
  ("interface.region.transfer-full", outcomeEq transfer (.ok expected100)),
  ("interface.region.transfer-total", resultHas transfer (fun r ↦
    decide (balanceSum pairRegion r.world.state = 10))),
  ("interface.region.neutral-delta", resultHas transfer (fun r ↦
    decide (receiptDelta pairRegion r.receipt = 0))),
  ("interface.region.transfer-out", resultHas transfer (fun r ↦
    decide (receiptDelta singleRegion r.receipt = -2))),
  ("interface.region.single-target-delta", resultHas transfer (fun r ↦
    decide (receiptCellEffect r.receipt alice = -2))),
  ("interface.region.transfer-effects", resultHas transfer (fun r ↦
    decide (receiptCellEffect r.receipt alice = -2 ∧ receiptCellEffect r.receipt bob = 2))),
  ("interface.region.singleton-total", resultHas transfer (fun r ↦
    decide (balanceSum singleRegion initial64.state = 6 ∧
      balanceSum singleRegion r.world.state = 4))),
  ("interface.region.transfer-supply", resultHas transfer (fun r ↦
    decide (r.receipt.supply .home .usd = 0))),
  ("interface.region.mint-full", outcomeEq minted (.ok expected101)),
  ("interface.region.mint", resultHas minted (fun r ↦
    decide (receiptDelta pairRegion r.receipt = 3))),
  ("interface.region.mint-total", resultHas minted (fun r ↦
    decide (balanceSum pairRegion r.world.state = 13 ∧ r.receipt.supply .home .usd = 3))),
  ("interface.region.repeated-full", outcomeEq repeatedRun (.ok expected104)),
  ("interface.region.repeated", resultHas repeatedRun (fun r ↦
    decide (receiptDelta singleRegion r.receipt = -3))),
  ("interface.region.repeated-total", resultHas repeatedRun (fun r ↦
    decide (balanceSum singleRegion r.world.state = 3))),
  ("interface.region.private-total-full", outcomeEq (execute op100 (world 6 4 0 10))
    (.ok ⟨world 4 6 0 10, receipt100, []⟩)),
  ("interface.region.private-total", resultHas (execute op100 (world 6 4 0 10)) (fun r ↦
    decide (balanceSum pairRegion r.world.state = 10 ∧ r.world.state.balance totalCell = 10))),
  ("interface.region.exposed-total-full", outcomeEq
    (execute op105 (world 6 4 0 10) exposedCfg) (.ok expected105)),
  ("interface.region.exposed-total-counterexample", resultHas
    (execute op105 (world 6 4 0 10) exposedCfg) (fun r ↦
      decide (balanceSum pairRegion r.world.state = 10 ∧
        r.world.state.balance totalCell = 11 ∧ receiptDelta pairRegion r.receipt = 0 ∧
        r.receipt.supply .home .usd = 1 ∧
        balanceSum pairRegion r.world.state ≠ r.world.state.balance totalCell)))
]

def unequal (index : Nat) (left right : QualifiedPort) (a b : ℚ) :
    Except (BindingFailure P A D) PUnit := .error (.unequal index left right a b)
def query (edges : List Binding) (entry : W) (config : Config P A D := cfg) :=
  checkBindings config edges entry.state
def queryEq (edges : List Binding) (entry : W)
    (expected : Except (BindingFailure P A D) PUnit) (config : Config P A D := cfg) : Bool :=
  decide (query edges entry config = expected)
def dimensionalWorld := world 5 0 0 0 5 5 5

def bindingChecks : List (String × Bool) := [
  ("interface.binding.paired-full", outcomeEq pairedRun (.ok expected102)),
  ("interface.binding.equal", resultHas pairedRun (fun r ↦
    queryEq equalEdge r.world (.ok ⟨⟩))),
  ("interface.binding.paired-effects", resultHas pairedRun (fun r ↦
    decide (receiptCellEffect r.receipt alice = -1 ∧ receiptCellEffect r.receipt bob = -1))),
  ("interface.binding.one-sided-full", outcomeEq oneSidedRun (.ok expected103)),
  ("interface.binding.unequal", resultHas oneSidedRun (fun r ↦
    queryEq equalEdge r.world (unequal 0 (name 0) (name 1) 4 5))),
  ("interface.binding.global-edge", queryEq [(name 0, name 2)] (world 4 5 5)
    (unequal 0 (name 0) (name 2) 4 5)),
  ("interface.binding.cut-extraction", decide (cutExtracted = [])),
  ("interface.binding.cut-omission-counterexample", queryEq cutExtracted (world 4 5 5) (.ok ⟨⟩) &&
    queryEq [(name 0, name 2)] (world 4 5 5) (unequal 0 (name 0) (name 2) 4 5)),
  ("interface.binding.existing-port", queryEq transitiveEdges (world 5 5 5) (.ok ⟨⟩)),
  ("interface.binding.transitive-redundant", queryEq redundantEdges (world 5 5 5) (.ok ⟨⟩)),
  ("interface.binding.distinct-closures", decide
    (symClosure transitiveEdges ≠ symClosure redundantEdges)),
  ("interface.binding.transitive-negative", queryEq equalEdge (world 4 5 5)
    (unequal 0 (name 0) (name 1) 4 5)),
  ("interface.binding.asset", queryEq [(name 0, name 3)] dimensionalWorld
    (.error (.assetMismatch 0 alice eurCell))),
  ("interface.binding.domain", queryEq [(name 0, name 4)] dimensionalWorld
    (.error (.domainMismatch 0 alice awayCell))),
  ("interface.binding.domain-before-asset", queryEq [(name 0, name 5)] dimensionalWorld
    (.error (.domainMismatch 0 alice awayEur))),
  ("interface.binding.dimension-amounts", decide
    (dimensionalWorld.state.balance alice = 5 ∧ dimensionalWorld.state.balance eurCell = 5 ∧
      dimensionalWorld.state.balance awayCell = 5 ∧ dimensionalWorld.state.balance awayEur = 5)),
  ("interface.binding.missing-port", queryEq [(name 0, name 0 99)] (world 4 5 5)
    (.error (.endpoint 0 .right (.missingPort (name 0 99))))),
  ("interface.binding.missing-component-left", queryEq [(name 99, name 0)] (world 4 5 5)
    (.error (.endpoint 0 .left (.missingComponent (name 99))))),
  ("interface.binding.missing-component-right", queryEq [(name 0, name 99)] (world 4 5 5)
    (.error (.endpoint 0 .right (.missingComponent (name 99))))),
  ("interface.binding.left-before-right", queryEq [(name 99, name 0 99)] (world 4 5 5)
    (.error (.endpoint 0 .left (.missingComponent (name 99))))),
  ("interface.binding.first-failure", queryEq [(name 0, name 1), (name 0, name 99)]
    (world 4 5 5) (unequal 0 (name 0) (name 1) 4 5)),
  ("interface.binding.later-index", queryEq [(name 0, name 0), (name 0, name 99)]
    (world 4 5 5) (.error (.endpoint 1 .right (.missingComponent (name 99))))),
  ("interface.binding.input-not-resource", decide
    (resolveExport cfg.catalog (name 0 11) = .error (.missingPort (name 0 11)))),
  ("interface.binding.output-not-resource", decide
    (resolveExport snapshotCfg.catalog (name 0 10) = .error (.missingPort (name 0 10)))),
  ("interface.binding.invalid-empty", queryEq [] (world 0 0) (.error .configuration) invalidCfg),
  ("interface.binding.invalid-nonempty", queryEq equalEdge (world 0 0)
    (.error .configuration) invalidCfg),
  ("interface.positive.empty-query", queryEq [] (world 0 0) (.ok ⟨⟩)),
  ("interface.binding.valid-empty", queryEq [] (world 0 0) (.ok ⟨⟩)),
  ("interface.binding.self-edge", queryEq [(name 0, name 0)] (world 0 0) (.ok ⟨⟩)),
  ("interface.binding.unresolved-self-edge", queryEq [(name 99, name 99)] (world 0 0)
    (.error (.endpoint 0 .left (.missingComponent (name 99))))),
  ("interface.binding.duplicate", queryEq (equalEdge ++ equalEdge) (world 5 5) (.ok ⟨⟩)),
  ("interface.binding.reverse", queryEq [(name 1, name 0)] (world 4 5)
    (unequal 0 (name 1) (name 0) 5 4)),
  ("interface.binding.import-source", decide (resolveExport cfg.catalog (name 0) = .ok alice)),
  ("interface.binding.import-after-write", resultHas transfer (fun r ↦
    match cfg.catalog.find? (fun c ↦ c.id = ⟨7⟩) with
    | none => false
    | some c => decide (c.imports = [⟨name 0, alice, true⟩]) &&
      decide (r.world.state.balance alice = 4) &&
      c.canWrite alice && decide (resolveExport cfg.catalog (name 0) = .ok alice))),
  ("interface.binding.hold-success", bindingsHold cfg equalEdge (world 5 5).state),
  ("interface.binding.hold-failure", !bindingsHold cfg equalEdge (world 4 5).state)
]

def groupChecks : List (String × Bool) := [
  ("interface.group.paired-entry", queryEq equalEdge initial55 (.ok ⟨⟩)),
  ("interface.group.paired-first", cursorEq groupFirst firstCursor),
  ("interface.group.paired-complete", cursorEq groupBoth secondCursor),
  ("interface.group.paired-first-binding", queryEq equalEdge groupFirst.world (.ok ⟨⟩)),
  ("interface.group.paired-complete-binding", queryEq equalEdge groupBoth.world (.ok ⟨⟩)),
  ("interface.group.refusal-suffix", cursorEq
    (Composition.run cfg boundary initial55 [.invoke op102, .invoke op106, .invoke op101])
    refusedCursor),
  ("interface.group.refusal-total", decide (balanceSum tripleRegion
    (Composition.run cfg boundary initial55
      [.invoke op102, .invoke op106, .invoke op101]).world.state
      = 10)),
  ("interface.group.snapshot-first", cursorEq snapshotFirstRun snapshotPrefix),
  ("interface.group.snapshot-complete", cursorEq snapshotRun snapshotFinal),
  ("interface.group.snapshot-total",
    decide (balanceSum pairRegion snapshotRun.world.state = 10)),
  ("interface.group.snapshot-new-receipts",
    decide
    ((snapshotRun.events.drop arbitraryEntry.events.length).map (fun e ↦ e.result.receipt) =
      [receipt100, receipt107])),
  ("interface.group.snapshot-flow", decide
    (((snapshotRun.events.drop arbitraryEntry.events.length).map
      (fun e ↦ receiptDelta pairRegion e.result.receipt)).sum = 0)),
  ("interface.group.snapshot-not-binding",
    !bindingsHold snapshotCfg equalEdge snapshotRun.world.state)
]

def schedule17 : Interleaving.Schedule := [.left, .right, .left]
def schedule19 : Interleaving.Schedule := [.left, .left, .right]
def schedule20 : Interleaving.Schedule := [.left, .left, .left, .right]
def shared (schedule : Interleaving.Schedule) (suffix : Bool := false) :=
  Interleaving.runInterleaving cfg sharedBoundary initial55
    ([op102, op106] ++ if suffix then [op101] else []) [op102] schedule
def sharedPrefix (schedule : Interleaving.Schedule) (suffix : Bool := false) :=
  Interleaving.runPrefix cfg sharedBoundary initial55
    ([op102, op106] ++ if suffix then [op101] else []) [op102] schedule

def sharedReceipts (m : Interleaving.Machine P A D) : List (Receipt P A D) :=
  m.attempts.filterMap (fun a ↦ match a.outcome with | .ok r => some r.receipt | .error _ => none)
def sharedChecks : List (String × Bool) := [
  ("interface.shared.refusal-last", sharedEq (shared schedule17) schedule17 expectedF17),
  ("interface.shared.peer-after-refusal", sharedEq (shared schedule19) schedule19 expectedF19),
  ("interface.shared.failed-suffix-skipped",
    sharedEq (shared schedule20 true) schedule20 expectedF20),
  ("interface.shared.first-prefix", machineEq (sharedPrefix [.left]) expectedSharedFirst),
  ("interface.shared.refused-prefix",
    machineEq (sharedPrefix [.left, .left]) expectedSharedRefused),
  ("interface.shared.skipped-prefix", machineEq (sharedPrefix [.left, .left, .left] true)
    expectedSharedSkipped),
  ("interface.shared.receipts", decide (sharedReceipts (sharedPrefix schedule19) =
    [receipt102, receipt102])),
  ("interface.shared.receipt-flow", decide (((sharedReceipts (sharedPrefix schedule20 true)).map
    (receiptDelta tripleRegion)).sum = 0)),
  ("interface.shared.no-mint-supply", decide
    ((sharedPrefix schedule20 true).supply .home .usd = 0)),
  ("interface.shared.all-prefix-totals", (List.range 5).all (fun n ↦
    decide (balanceSum tripleRegion (sharedPrefix (schedule20.take n) true).world.state = 10))),
  ("interface.shared.all-prefix-bindings", (List.range 5).all (fun n ↦
    bindingsHold cfg equalEdge (sharedPrefix (schedule20.take n) true).world.state))
]

def actualIssue := executeStep cfg (adminBoundary 0) 0 [] (.issue grant) initial64
def actualRevoke := executeStep cfg (adminBoundary 1) 1 [] (.revoke ⟨17⟩) issuedWorld
def adminChecks : List (String × Bool) := [
  ("interface.admin.issue-full", outcomeEq actualIssue (.ok issuedResult)),
  ("interface.admin.revoke-full", outcomeEq actualRevoke (.ok revokedResult)),
  ("interface.admin.issued-delta", resultHas actualIssue (fun r ↦
    decide (receiptDelta singleRegion r.receipt = 0))),
  ("interface.admin.revoked-delta", resultHas actualRevoke (fun r ↦
    decide (receiptDelta singleRegion r.receipt = 0))),
  ("interface.admin.complete-cursor", cursorEq
    (Composition.run cfg adminBoundary initial64 [.issue grant, .revoke ⟨17⟩]) adminFinal),
  ("interface.admin.unauthorized", outcomeEq
    (executeStep cfg (boundary 0) 0 [] (.issue grant) initial64)
    (.error (.authority .unauthorizedAdmin))),
  ("interface.admin.unauthorized-cursor", cursorEq
    (Composition.run cfg boundary initial64 [.issue grant])
    ⟨initial64, [], [], 0, some ⟨0, some (.issue grant), .authority .unauthorizedAdmin⟩⟩),
  ("interface.admin.balance", resultHas actualRevoke (fun r ↦
    decide (balanceSum singleRegion r.world.state = 6)))
]

def runtimeChecks : List (String × Bool) := catalogChecks ++ regionChecks ++ bindingChecks ++
  groupChecks ++ sharedChecks ++ adminChecks

-- BEGIN PROOFS

end DefiKernel.Interface.Tests
