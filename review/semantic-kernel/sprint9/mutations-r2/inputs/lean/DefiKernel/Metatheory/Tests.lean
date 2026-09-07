import DefiKernel.Metatheory.Examples
import DefiKernel.Metatheory.Observation
import DefiKernel.Metatheory.Contexts
import DefiKernel.Metatheory.OperatorFixtures

/-! Named runtime checks use independently constructed complete cursors. Synthetic observer
pairs are explicitly distinguished from actual execution counterexamples. -/
namespace DefiKernel.Metatheory.Tests
open Typed Composition Typed.Examples Examples
open Parallel.Examples (output evaluatedTransfer)

abbrev G := SeqGroup P A D
def leaf (inv : Inv) : G := .step (.invoke inv)
def first : G := leaf draw7
def second : G := leaf consume3
def third : G := leaf return1
def pair : G := .seq first second
def leftGrouped : G := .seq pair third
def rightGrouped : G := .seq first (.seq second third)
def refusing : G := .seq (.seq first (leaf refuse6)) (leaf (movement 1 carol))
def issueGroup : G := .step (.issue grantInvoke)
def useGroup : G := leaf adminMove
def revokeGroup : G := .step (.revoke ⟨1⟩)
def administration : G := .seq (.seq issueGroup useGroup)
  (.seq revokeGroup (.seq useGroup (leaf (movement 1 carol))))
def run (group : G) (entry : Cur := initial) : Cur := runGroup cfg mainBoundary entry group

def reverseEvent := rawTransfer 0 refuse6 aliceCell carolCell 6
  (world 10 0 0) (world 4 0 6) 4
def reverseExpected : Cur := cursor (world 4 0 6) [reverseEvent] [output 0 0 .usd 4] 1
  (some ⟨1, some (.invoke draw7), .kernel .insufficientFunds⟩)
def suffixEvent := rawTransfer 1 (movement 1 carol) aliceCell carolCell 1
  (world 3 7 0) (world 2 7 1) 2
def suffixExpected : Cur := cursor (world 2 7 1) [firstEvent, suffixEvent]
  [output 0 0 .usd 3, output 1 0 .usd 2] 2
/-- Separately written nonempty equal control, without projecting an actual run. -/
def equalFirst : Cur :=
  ⟨world 3 7 0,
    [⟨0, .invoke draw7, world 10 0 0,
      ⟨world 3 7 0, .invoked ⟨⟨10⟩, [.bob], [⟨.amount .usd, 7⟩], mainCaps, none⟩
        (evaluatedTransfer aliceCell bobCell 7), [output 0 0 .usd 3]⟩⟩],
    [output 0 0 .usd 3], 1, none⟩

def groupChecks : List (String × Bool) := [
  ("metatheory.fixture.catalog", validateCatalog cfg.registry cfg.catalog),
  ("metatheory.positive.single-leaf", fullCursorEq
    (runGroup cfg constantBoundary initial first) afterFirst),
  ("metatheory.positive.equal-observation", cursorEq afterFirst equalFirst),
  ("metatheory.group.world-chain", fullCursorEq
    (runGroup cfg constantBoundary initial (.seq first (leaf worldChainCall))) worldChainExpected),
  ("metatheory.group.store-chain", fullCursorEq
    (runGroup cfg adminBoundary adminInitial (.seq issueGroup useGroup)) adminUsed),
  ("metatheory.group.history-chain", fullCursorEq
    (runGroup cfg constantBoundary initial
      (.seq (leaf historyChainProducer) (leaf historyChainConsumer))) historyChainExpected),
  ("metatheory.group.index-chain", fullCursorEq
    (runGroup timedCfg indexChainBoundary indexChainInitial
      (.seq (leaf indexChainFirst) (leaf indexChainSecond))) indexChainExpected),
  ("metatheory.group.refusal-absorption", fullCursorEq (run refusing) middleRefusal),
  ("metatheory.group.child-executed", fullCursorEq
    (runGroup cfg constantBoundary initial (.seq .empty (leaf childExecutionCall)))
    childExecutionExpected),
  ("metatheory.group.ordered", fullCursorEq (run rightGrouped) afterThird),
  ("metatheory.group.boundary-index", fullCursorEq
    (runGroup timedCfg timedBoundary timedInitial (.seq (leaf timedFirst) (leaf timedSecond)))
    timedExpected),
  ("metatheory.group.empty", fullCursorEq (run .empty afterFirst) afterFirst),
  ("metatheory.group.empty.left", fullCursorEq (run (.seq .empty first)) afterFirst),
  ("metatheory.group.empty.right", fullCursorEq (run (.seq first .empty)) afterFirst),
  ("metatheory.group.failed-entry", fullCursorEq (run leftGrouped middleRefusal) middleRefusal),
  ("metatheory.group.funded-suffix", fullCursorEq
    (run (leaf (movement 1 carol)) afterFirst) suffixExpected),
  ("metatheory.group.reverse-refusal", fullCursorEq
    (run (.seq (leaf refuse6) first)) reverseExpected),
  ("metatheory.group.forward-refusal", fullCursorEq
    (run (.seq first (leaf refuse6))) middleRefusal),
  ("metatheory.group.admin.issue", fullCursorEq
    (runGroup cfg adminBoundary adminInitial issueGroup) adminIssued),
  ("metatheory.group.admin.revoke", fullCursorEq
    (runGroup cfg adminBoundary adminInitial (.seq (.seq issueGroup useGroup) revokeGroup))
    adminRevoked),
  ("metatheory.group.admin.denied", fullCursorEq
    (runGroup cfg adminBoundary adminInitial administration) adminDenied),
  ("metatheory.group.flat.success", fullCursorEq
    (Composition.continueRun cfg mainBoundary initial
      [.invoke draw7, .invoke consume3, .invoke return1]) afterThird),
  ("metatheory.group.flat.admin", fullCursorEq
    (Composition.continueRun cfg adminBoundary adminInitial
      [.issue grantInvoke, .invoke adminMove, .revoke ⟨1⟩, .invoke adminMove,
        .invoke (movement 1 carol)]) adminDenied),
  ("metatheory.group.assoc.failure.left", fullCursorEq
    (run (.seq (.seq first (leaf refuse6)) third)) middleRefusal),
  ("metatheory.group.assoc.failure.right", fullCursorEq
    (run (.seq first (.seq (leaf refuse6) third))) middleRefusal),
  ("metatheory.group.continuation", fullCursorEq (run (.seq second third) afterFirst) afterThird)
]

/-- All changed pairs below are synthetic observer inputs, not two reachable executions. -/
def different (changed : Cur) : Bool := !cursorEq afterFirst changed
def alteredEvent (event : RawEvent) : Cur := { afterFirst with events := [event] }
def alteredReceipt (receipt : Receipt P A D) : Cur := alteredEvent
  { firstEvent with result := { firstEvent.result with receipt := receipt } }
def receiptChanged : Receipt P A D := .invoked
  ⟨⟨10⟩, [.bob], [⟨.amount .usd, 6⟩], mainCaps, none⟩
  (evaluatedTransfer aliceCell bobCell 7)
def evaluatedChanged : Receipt P A D := .invoked
  ⟨⟨10⟩, [.bob], [⟨.amount .usd, 7⟩], mainCaps, none⟩
  (evaluatedTransfer aliceCell bobCell 6)
def evaluatedReadChanged : Receipt P A D := .invoked
  ⟨⟨10⟩, [.bob], [⟨.amount .usd, 7⟩], mainCaps, none⟩
  { evaluatedTransfer aliceCell bobCell 7 with declaredStateReads := [collateralCell] }
def failureChanged (failure : LocatedFailure P A D) : Bool :=
  !cursorEq middleRefusal { middleRefusal with failure := some failure }
def changedCollateral : W :=
  ⟨⟨fun c ↦ if c = collateralCell then 10 else (world 3 7 0).state.balance c,
    fun c ↦ by
      split
      · norm_num
      · exact (world 3 7 0).state.nonneg c⟩, mainStore⟩
def observationChecks : List (String × Bool) := [
  ("metatheory.observe.world-diff", different { afterFirst with world := changedCollateral }),
  ("metatheory.observe.store-diff", different
    { afterFirst with world := world 3 7 0 ⟨[aliceDebit]⟩ }),
  ("metatheory.observe.output-diff", different
    { afterFirst with outputs := [output 0 0 .usd 2] }),
  ("metatheory.observe.failure-diff", different
    { afterFirst with failure := some ⟨1, some (.invoke refuse6), .kernel .insufficientFunds⟩ }),
  ("metatheory.observe.receipt-diff", different (alteredReceipt evaluatedChanged)),
  ("metatheory.observe.request.arguments", different (alteredReceipt receiptChanged)),
  ("metatheory.observe.next-index-diff", different { afterFirst with nextIndex := 2 }),
  ("metatheory.observe.output.unit", different
    { afterFirst with outputs := [output 0 0 .share 3] }),
  ("metatheory.observe.output.producer", different
    { afterFirst with outputs := [output 1 0 .usd 3] }),
  ("metatheory.observe.output.component", different
    { afterFirst with outputs := [output 0 1 .usd 3] }),
  ("metatheory.observe.output.port", different { afterFirst with
    outputs := [⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 3⟩⟩] }),
  ("metatheory.observe.output.order", !cursorEq afterSecond
    { afterSecond with outputs := [output 1 0 .usd 0, output 0 0 .usd 3] }),
  ("metatheory.observe.store.tombstone", different { afterFirst with
    world := world 3 7 0 ⟨[aliceDebit, { aliceInvoke with live := false }, bobDebit, bobInvoke]⟩ }),
  ("metatheory.observe.event.index", different (alteredEvent { firstEvent with index := 1 })),
  ("metatheory.observe.event.action", different
    (alteredEvent { firstEvent with step := .invoke refuse6 })),
  ("metatheory.observe.event.output", different (alteredEvent
    { firstEvent with result := { firstEvent.result with outputs := [output 0 0 .usd 2] } })),
  ("metatheory.observe.event.evaluated", different (alteredReceipt evaluatedReadChanged)),
  ("metatheory.observe.event.length", different { afterFirst with events := [] }),
  ("metatheory.observe.event.order", !cursorEq afterSecond
    { afterSecond with events := [secondEvent, firstEvent] }),
  ("metatheory.observe.event.issue-id", !cursorEq adminIssued { adminIssued with
    events := [adminPrefix, { issueEvent with result := { issueEvent.result with
      receipt := .issued ⟨2⟩ } }] }),
  ("metatheory.observe.event.revoke-id", !cursorEq adminRevoked { adminRevoked with
    events := [adminPrefix, issueEvent, adminUseEvent,
      { revokeEvent with result := { revokeEvent.result with receipt := .revoked ⟨0⟩ } }] }),
  ("metatheory.observe.failure.reason", failureChanged
    ⟨1, some (.invoke refuse6), .kernel .guard⟩),
  ("metatheory.observe.failure.position", failureChanged
    ⟨2, some (.invoke refuse6), .kernel .insufficientFunds⟩),
  ("metatheory.observe.failure.action", failureChanged
    ⟨1, some (.invoke draw7), .kernel .insufficientFunds⟩),
  ("metatheory.observe.failure.absent-action", failureChanged
    ⟨1, none, .kernel .insufficientFunds⟩),
  ("metatheory.observe.raw-before.omitted", cursorEq afterFirst
    (alteredEvent { firstEvent with before := world 99 0 0 })),
  ("metatheory.observe.raw-post.omitted", cursorEq afterFirst
    (alteredEvent { firstEvent with result := { firstEvent.result with world := world 99 0 0 } }))
]

def historyOther : Cur := { afterFirst with outputs := [output 0 0 .usd 2] }
def historyOtherEvent := rawTransfer 1 consume3 aliceCell carolCell 2
  (world 3 7 0) (world 1 7 2) 1
def historyOtherExpected : Cur := cursor (world 1 7 2) [firstEvent, historyOtherEvent]
  [output 0 0 .usd 2, output 1 0 .usd 1] 2
def originalHidden : Cur := { fundingInitial with
  failure := some ⟨0, some (.invoke firstHidden), .kernel .insufficientFunds⟩ }
def hiddenSuffix := movement 1 carol fundingCaps
def fundingDifference : Cur := { fundingExposed with
  failure := some ⟨2, some (.invoke hiddenSuffix), .kernel .insufficientFunds⟩ }
def hiddenGroup : G := leaf firstHidden
def hiddenLong : G := .seq hiddenGroup (leaf hiddenSuffix)
def contextChecks : List (String × Bool) := [
  ("metatheory.context.history.original", fullCursorEq (run second afterFirst) afterSecond),
  ("metatheory.context.history.changed", fullCursorEq
    (run second historyOther) historyOtherExpected),
  ("metatheory.context.history.material", !cursorEq
    (run second afterFirst) (run second historyOther)),
  ("metatheory.context.index.original", fullCursorEq
    (runGroup timedCfg timedBoundary timedInitial (leaf timedFirst))
    (cursor (world 7 3 0) [timedEvent1] [output 4 0 .usd 7] 5)),
  ("metatheory.context.index.changed", fullCursorEq
    (runGroup timedCfg timedBoundary { timedInitial with nextIndex := 5 } (leaf timedFirst))
    (cursor (world 10 0 0) [] [] 5 (some ⟨5, some (.invoke timedFirst), .kernel .guard⟩))),
  ("metatheory.context.one-entry.short", fullCursorEq
    (runGroup fundingCfg fundingBoundary fundingInitial hiddenGroup) originalHidden),
  ("metatheory.context.one-entry.long", fullCursorEq
    (runGroup fundingCfg fundingBoundary fundingInitial hiddenLong) originalHidden),
  ("metatheory.context.funded.short", fullCursorEq
    (runGroup fundingCfg fundingBoundary fundingInitial (.seq (leaf fundingCall) hiddenGroup))
    fundingExposed),
  ("metatheory.context.funded.long", fullCursorEq
    (runGroup fundingCfg fundingBoundary fundingInitial (.seq (leaf fundingCall) hiddenLong))
    fundingDifference),
  ("metatheory.context.prefix-suffix.left", fullCursorEq (run leftGrouped) afterThird),
  ("metatheory.context.prefix-suffix.right", fullCursorEq (run rightGrouped) afterThird)
]


def oneStep (config : Config P A D) (boundary : Boundary P A D) (entry : Cur)
    (action : Action) : Cur := runGroup config (fun _ ↦ boundary) entry (.step action)
def appendedGrant : Store := ⟨mainStore.entries ++ [⟨grantInvoke, true⟩]⟩
def issueMainEvent : RawEvent := ⟨0, .issue grantInvoke, world 10 0 0,
  ⟨world 10 0 0 appendedGrant, .issued ⟨4⟩, []⟩⟩
def issueMainExpected : Cur := cursor (world 10 0 0 appendedGrant) [issueMainEvent] [] 1
def emptyStoreInitial : Cur := cursor (world 10 0 0 ⟨[]⟩) [] [] 0
def issueEmptyEvent : RawEvent := ⟨0, .issue grantInvoke, world 10 0 0 ⟨[]⟩,
  ⟨world 10 0 0 ⟨[aliceInvoke]⟩, .issued ⟨0⟩, []⟩⟩
def issueEmptyExpected : Cur := cursor (world 10 0 0 ⟨[aliceInvoke]⟩) [issueEmptyEvent] [] 1
def grantOnlyEvent : RawEvent := ⟨0, .issue grantOnly, world 10 0 0,
  ⟨world 10 0 0 grantOnlyStore, .issued ⟨4⟩, []⟩⟩
def grantOnlyExpected : Cur := cursor (world 10 0 0 grantOnlyStore) [grantOnlyEvent] [] 1
def missingCall : Inv := { draw7 with component := ⟨88⟩, operation := ⟨88⟩ }
def deniedRevoke := failedInitial (.revoke ⟨0⟩) (.authority .unauthorizedAdmin)
def missingRevoke := failedInitial (.revoke ⟨80⟩) (.authority .unknownCapability)
def configurationChecks : List (String × Bool) := [
  ("metatheory.config.extended.valid", validateCatalog extendedCfg.registry extendedCfg.catalog),
  ("metatheory.config.extended.group", fullCursorEq
    (runGroup extendedCfg mainBoundary initial leftGrouped) afterThird),
  ("metatheory.config.extended.refusal", fullCursorEq
    (runGroup extendedCfg mainBoundary initial refusing) middleRefusal),
  ("metatheory.config.extended.admin", fullCursorEq
    (runGroup extendedCfg adminBoundary adminInitial administration) adminDenied),
  ("metatheory.config.extended.step", fullCursorEq
    (oneStep extendedCfg (constantBoundary 0) initial (.invoke draw7)) afterFirst),
  ("metatheory.config.registry.valid",
    validateCatalog changedRegistry.registry changedRegistry.catalog),
  ("metatheory.config.registry.changed", fullCursorEq
    (oneStep changedRegistry (constantBoundary 0) initial (.invoke draw7))
    (failedInitial (.invoke draw7) (.kernel .guard))),
  ("metatheory.config.lookup.valid", validateCatalog changedOutput.registry changedOutput.catalog),
  ("metatheory.config.lookup.changed", fullCursorEq
    (oneStep changedOutput (constantBoundary 0) initial (.invoke draw7)) changedOutputExpected),
  ("metatheory.config.invalid.catalog",
    !validateCatalog invalidAdded.registry invalidAdded.catalog),
  ("metatheory.config.invalid.lookup-unchanged", decide
    (lookupOperation cfg.catalog ⟨0⟩ ⟨10⟩ = lookupOperation invalidAdded.catalog ⟨0⟩ ⟨10⟩)),
  ("metatheory.config.invalid.refusal", fullCursorEq
    (oneStep invalidAdded (constantBoundary 0) initial (.invoke draw7))
    (failedInitial (.invoke draw7) .configuration)),
  ("metatheory.config.issue.original", fullCursorEq
    (oneStep cfg issueBoundary initial (.issue grantInvoke)) issueMainExpected),
  ("metatheory.config.issue.extended", fullCursorEq
    (oneStep extendedCfg issueBoundary initial (.issue grantInvoke)) issueMainExpected),
  ("metatheory.config.issue.empty-store", fullCursorEq
    (oneStep cfg issueBoundary emptyStoreInitial (.issue grantInvoke)) issueEmptyExpected),
  ("metatheory.config.admin.changed", fullCursorEq
    (oneStep changedAdmin issueBoundary initial (.issue grantInvoke))
    (failedInitial (.issue grantInvoke) (.authority .unauthorizedAdmin))),
  ("metatheory.config.grant-only.old-valid",
    validateCatalog grantOnlyCfg.registry grantOnlyCfg.catalog),
  ("metatheory.config.grant-only.new-valid",
    validateCatalog grantOnlyChanged.registry grantOnlyChanged.catalog),
  ("metatheory.config.grant-only.uncataloged", decide
    (lookupOperation grantOnlyCfg.catalog ⟨77⟩ ⟨77⟩ = none ∧
      lookupOperation grantOnlyChanged.catalog ⟨77⟩ ⟨77⟩ = none)),
  ("metatheory.config.grant-only.issue", fullCursorEq
    (oneStep grantOnlyCfg issueBoundary initial (.issue grantOnly)) grantOnlyExpected),
  ("metatheory.config.grant-only.domain", fullCursorEq
    (oneStep grantOnlyChanged issueBoundary initial (.issue grantOnly))
    (failedInitial (.issue grantOnly) (.authority .operationDomain))),
  ("metatheory.config.lookup.absent.old", fullCursorEq
    (oneStep cfg (constantBoundary 0) initial (.invoke missingCall))
    (failedInitial (.invoke missingCall) (.interface .unknownOperation))),
  ("metatheory.config.lookup.absent.new", fullCursorEq
    (oneStep extendedCfg (constantBoundary 0) initial (.invoke missingCall))
    (failedInitial (.invoke missingCall) (.interface .unknownOperation))),
  ("metatheory.config.revoke.denied.old", fullCursorEq
    (oneStep cfg (constantBoundary 0) initial (.revoke ⟨0⟩)) deniedRevoke),
  ("metatheory.config.revoke.denied.new", fullCursorEq
    (oneStep extendedCfg (constantBoundary 0) initial (.revoke ⟨0⟩)) deniedRevoke),
  ("metatheory.config.revoke.missing.old", fullCursorEq
    (oneStep cfg issueBoundary initial (.revoke ⟨80⟩)) missingRevoke),
  ("metatheory.config.revoke.missing.new", fullCursorEq
    (oneStep extendedCfg issueBoundary initial (.revoke ⟨80⟩)) missingRevoke)
]


def requestReceipt (request : Request P A D) : Receipt P A D :=
  .invoked request (evaluatedTransfer aliceCell bobCell 7)
def baseRequest : Request P A D := ⟨⟨10⟩, [.bob], [⟨.amount .usd, 7⟩], mainCaps, none⟩
def detailChecks : List (String × Bool) := [
  ("metatheory.observe.request.operation", different (alteredReceipt
    (requestReceipt { baseRequest with operation := ⟨11⟩ }))),
  ("metatheory.observe.request.parties", different (alteredReceipt
    (requestReceipt { baseRequest with parties := [carol] }))),
  ("metatheory.observe.request.capabilities", different (alteredReceipt
    (requestReceipt { baseRequest with capabilityIds := [⟨0⟩] }))),
  ("metatheory.observe.request.claimed-actor", different (alteredReceipt
    (requestReceipt { baseRequest with claimedActor := some .alice }))),
  ("metatheory.observe.receipt.supply", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with
      supplies := [((.main, .usd), 1)] }))),
  ("metatheory.observe.receipt.writes", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with writes := [] }))),
  ("metatheory.observe.receipt.guard", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with guard := false }))),
  ("metatheory.observe.receipt.state-read", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with
      requiredStateReads := [aliceCell] }))),
  ("metatheory.observe.receipt.env-read", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with
      requiredEnvReads := [.currentTime] }))),
  ("metatheory.observe.receipt.declared-state-read", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with
      declaredStateReads := [aliceCell] }))),
  ("metatheory.observe.receipt.declared-env-read", different (alteredReceipt
    (.invoked baseRequest { evaluatedTransfer aliceCell bobCell 7 with
      declaredEnvReads := [.currentTime] }))),
  ("metatheory.config.registry.remaining", decide
    (cfg.catalog = changedRegistry.catalog ∧
      cfg.domainAdmin .main = changedRegistry.domainAdmin .main)),
  ("metatheory.config.lookup.remaining", decide
    (cfg.domainAdmin .main = changedOutput.domainAdmin .main)),
  ("metatheory.config.grant-only.remaining", decide
    (grantOnlyCfg.catalog = grantOnlyChanged.catalog ∧
      grantOnlyCfg.domainAdmin .main = grantOnlyChanged.domainAdmin .main)),
  ("metatheory.config.admin.remaining", decide
    (cfg.catalog = changedAdmin.catalog)),
  ("metatheory.context.store.material", !cursorEq
    (oneStep cfg issueBoundary initial (.issue grantInvoke))
    (oneStep cfg issueBoundary emptyStoreInitial (.issue grantInvoke)))
]


/-- The selected observer omits old raw worlds even after an actual snapshot-consuming suffix. -/
def rawBeforeOther : Cur := alteredEvent { firstEvent with before := world 99 0 0 }
def rawPostOther : Cur := alteredEvent
  { firstEvent with result := { firstEvent.result with world := world 99 0 0 } }
def surrounding : SeqContext P A D := .after (.before first .hole) third
def failedSurrounding : SeqContext P A D :=
  .after (.before first .hole) (leaf (movement 1 carol))
def closureChecks : List (String × Bool) := [
  ("metatheory.config.admin.valid", validateCatalog changedAdmin.registry changedAdmin.catalog),
  ("metatheory.config.registry.all-admins", decide
    (∀ d, cfg.domainAdmin d = changedRegistry.domainAdmin d)),
  ("metatheory.config.lookup.all-admins", decide
    (∀ d, cfg.domainAdmin d = changedOutput.domainAdmin d)),
  ("metatheory.config.grant-only.all-admins", decide
    (∀ d, grantOnlyCfg.domainAdmin d = grantOnlyChanged.domainAdmin d)),
  ("metatheory.context.raw-before.expected", fullCursorEq (run second rawBeforeOther)
    { afterSecond with events := [{ firstEvent with before := world 99 0 0 }, secondEvent] }),
  ("metatheory.context.raw-post.expected", fullCursorEq (run second rawPostOther)
    { afterSecond with events := [{ firstEvent with result :=
      { firstEvent.result with world := world 99 0 0 } }, secondEvent] }),
  ("metatheory.context.raw-before.equivalent", cursorEq
    (run second afterFirst) (run second rawBeforeOther)),
  ("metatheory.context.raw-post.equivalent", cursorEq
    (run second afterFirst) (run second rawPostOther)),
  ("metatheory.context.fill.original", fullCursorEq (run (fill surrounding second)) afterThird),
  ("metatheory.context.fill.replacement", fullCursorEq
    (run (fill surrounding (.seq .empty second))) afterThird),
  ("metatheory.context.fill.failed.original", fullCursorEq
    (run (fill failedSurrounding (leaf refuse6))) middleRefusal),
  ("metatheory.context.fill.failed.replacement", fullCursorEq
    (run (fill failedSurrounding (.seq .empty (leaf refuse6)))) middleRefusal)
]

def runtimeChecks : List (String × Bool) :=
  groupChecks ++ observationChecks ++ contextChecks ++ configurationChecks ++
    OperatorFixtures.checks ++ OperatorFixtures.boundaryChecks ++ detailChecks ++ closureChecks

-- BEGIN PROOFS

end DefiKernel.Metatheory.Tests
