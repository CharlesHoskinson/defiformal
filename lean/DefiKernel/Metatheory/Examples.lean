import DefiKernel.Atomic.Examples

/-! Exact development fixtures. Carol is the opaque existing `pool` identity. Every expected
world, raw event and cursor below is constructed without invoking any execution or observer. -/
namespace DefiKernel.Metatheory.Examples
open Typed Composition Typed.Examples
open Parallel.Examples (cells cellRef packed evaluatedTransfer output)

abbrev P := Party
abbrev A := Asset
abbrev D := Domain
abbrev W := World P A D
abbrev C := Cell P A D
abbrev Cur := Cursor P A D
abbrev Inv := Invocation P A D
abbrev Action := Step P A D
abbrev RawEvent := Event P A D

/-- Fixture-only name: the pre-existing opaque pool ID denotes Carol here. -/
def carol : P := .pool
def aliceCell : C := (.main, .alice, .usd)
def bobCell : C := (.main, .bob, .usd)
def carolCell : C := (.main, carol, .usd)
def vaultCell : C := (.main, .vault, .usd)
def collateralCell : C := (.main, .alice, .collateral)
def aliceDebit : Capability P A D := ⟨⟨.alice, .main, ⟨10⟩, .debit aliceCell⟩, true⟩
def aliceInvoke : Capability P A D := ⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩
def bobDebit : Capability P A D := ⟨⟨.bob, .main, ⟨10⟩, .debit bobCell⟩, true⟩
def bobInvoke : Capability P A D := ⟨⟨.bob, .main, ⟨10⟩, .invoke⟩, true⟩
def mainStore : Store := ⟨[aliceDebit, aliceInvoke, bobDebit, bobInvoke]⟩
def mainCaps : List CapabilityId := [⟨0⟩, ⟨1⟩, ⟨2⟩, ⟨3⟩]
def balances (alice bob carolAmount vault : Nat) : C → ℚ := fun c ↦
  if c = aliceCell then alice else if c = bobCell then bob
  else if c = carolCell then carolAmount else if c = vaultCell then vault
  else if c = collateralCell then 9 else 0

def world (alice bob carolAmount : Nat) (store : Store := mainStore)
    (vault : Nat := 0) : W :=
  ⟨⟨balances alice bob carolAmount vault, by
    intro c
    simp only [balances]
    repeat' split
    all_goals positivity⟩, store⟩

def cfg : Config P A D :=
  Parallel.Examples.config Typed.Examples.transfer Parallel.Examples.noOp [aliceCell] []
def constantBoundary (_ : Nat) : Boundary P A D := ⟨aliceContext, fresh, 100⟩
def mainBoundary (index : Nat) : Boundary P A D :=
  ⟨⟨if index = 2 then .bob else .alice, .main⟩, fresh, 100 + index⟩
def movement (q : ℚ) (recipient : P) (ids : List CapabilityId := mainCaps) : Inv :=
  ⟨⟨0⟩, ⟨10⟩, [recipient], [.literal ⟨.amount .usd, q⟩], ids, none⟩
def draw7 : Inv := movement 7 .bob
def consume3 : Inv := { movement 3 carol with inputs := [.priorOutput 0 ⟨⟨0⟩, ⟨0⟩⟩] }
def return1 : Inv := movement 1 .alice
def refuse6 : Inv := movement 6 carol

def rawTransfer (index : Nat) (inv : Inv) (sender recipient : C) (amount : ℚ)
    (pre post : W) (snapshot : ℚ) : RawEvent :=
  ⟨index, .invoke inv, pre,
    ⟨post, .invoked ⟨inv.operation, inv.parties, [⟨.amount .usd, amount⟩],
      inv.capabilityIds, inv.claimedActor⟩ (evaluatedTransfer sender recipient amount),
      [output index 0 .usd snapshot]⟩⟩
def cursor (w : W) (events : List RawEvent) (history : List (OutputObservation A))
    (index : Nat) (failure : Option (LocatedFailure P A D) := none) : Cur :=
  ⟨w, events, history, index, failure⟩
def initial : Cur := cursor (world 10 0 0) [] [] 0
def firstEvent := rawTransfer 0 draw7 aliceCell bobCell 7 (world 10 0 0) (world 3 7 0) 3
def secondEvent := rawTransfer 1 consume3 aliceCell carolCell 3 (world 3 7 0) (world 0 7 3) 0
def thirdEvent := rawTransfer 2 return1 bobCell aliceCell 1 (world 0 7 3) (world 1 6 3) 1
def afterFirst : Cur := cursor (world 3 7 0) [firstEvent] [output 0 0 .usd 3] 1
def afterSecond : Cur := cursor (world 0 7 3) [firstEvent, secondEvent]
  [output 0 0 .usd 3, output 1 0 .usd 0] 2
def afterThird : Cur := cursor (world 1 6 3) [firstEvent, secondEvent, thirdEvent]
  [output 0 0 .usd 3, output 1 0 .usd 0, output 2 0 .usd 1] 3
def middleRefusal : Cur := { afterFirst with
  failure := some ⟨1, some (.invoke refuse6), .kernel .insufficientFunds⟩ }

/-- Independent full data comparator includes raw before and post worlds omitted by cursorEq. -/
def worldMatches (a b : W) : Bool :=
  decide ((∀ cell, a.state.balance cell = b.state.balance cell) ∧
    a.capabilities = b.capabilities)
def eventMatches (a b : RawEvent) : Bool :=
  worldMatches a.before b.before && worldMatches a.result.world b.result.world &&
    decide (a.index = b.index ∧ a.step = b.step ∧ a.result.receipt = b.result.receipt ∧
      a.result.outputs = b.result.outputs)
def fullCursorEq (a b : Cur) : Bool :=
  worldMatches a.world b.world && decide (a.events.length = b.events.length) &&
    (a.events.zip b.events).all (fun (x, y) ↦ eventMatches x y) &&
    decide (a.outputs = b.outputs ∧ a.nextIndex = b.nextIndex ∧ a.failure = b.failure)


def grantInvoke : Grant P A D := ⟨.alice, .main, ⟨10⟩, .invoke⟩
def adminStore : Store := ⟨[aliceDebit]⟩
def issuedStore : Store := ⟨[aliceDebit, aliceInvoke]⟩
def deadStore : Store := ⟨[aliceDebit, { aliceInvoke with live := false }]⟩
def adminMove : Inv := movement 1 .bob [⟨0⟩, ⟨1⟩]
def adminBoundary (index : Nat) : Boundary P A D :=
  ⟨if index = 5 ∨ index = 7 then adminContext else aliceContext, fresh, 100 + index⟩
def adminPrefix : RawEvent := ⟨4, .issue ⟨.alice, .main, ⟨10⟩, .debit aliceCell⟩,
  world 3 7 0 ⟨[]⟩,
  ⟨world 3 7 0 adminStore, .issued ⟨0⟩, []⟩⟩
def adminInitial : Cur := cursor (world 3 7 0 adminStore) [adminPrefix]
  [] 5
def issueEvent : RawEvent := ⟨5, .issue grantInvoke, world 3 7 0 adminStore,
  ⟨world 3 7 0 issuedStore, .issued ⟨1⟩, []⟩⟩
def adminUseEvent : RawEvent := rawTransfer 6 adminMove aliceCell bobCell 1
  (world 3 7 0 issuedStore) (world 2 8 0 issuedStore) 2
def revokeEvent : RawEvent := ⟨7, .revoke ⟨1⟩, world 2 8 0 issuedStore,
  ⟨world 2 8 0 deadStore, .revoked ⟨1⟩, []⟩⟩
def adminIssued : Cur := cursor (world 3 7 0 issuedStore) [adminPrefix, issueEvent]
  [] 6
def adminUsed : Cur := cursor (world 2 8 0 issuedStore)
  [adminPrefix, issueEvent, adminUseEvent] [output 6 0 .usd 2] 7
def adminRevoked : Cur := cursor (world 2 8 0 deadStore)
  [adminPrefix, issueEvent, adminUseEvent, revokeEvent]
  [output 6 0 .usd 2] 8
def adminDenied : Cur := { adminRevoked with
  failure := some ⟨8, some (.invoke adminMove), .kernel .unauthorizedInvoke⟩ }

def timedCfg : Config P A D := Parallel.Examples.config
  (Parallel.Examples.timedTemplate .usd) Parallel.Examples.noOp [aliceCell] []
def timedBoundary (index : Nat) : Boundary P A D :=
  ⟨⟨if index = 5 then .bob else .alice, .main⟩, fresh, 100 + index⟩
def timedMove (amount time : ℚ) (recipient : P) : Inv :=
  { movement amount recipient with
    inputs := [.literal ⟨.amount .usd, amount⟩, .literal ⟨.scalar, time⟩] }
def timedFirst := timedMove 3 104 .bob
def timedSecond := timedMove 1 105 .alice
def timedRaw (index : Nat) (inv : Inv) (sender recipient : C) (amount time : ℚ)
    (pre post : W) (snapshot : ℚ) : RawEvent :=
  ⟨index, .invoke inv, pre, ⟨post,
    .invoked ⟨inv.operation, inv.parties, [⟨.amount .usd, amount⟩, ⟨.scalar, time⟩],
      inv.capabilityIds, inv.claimedActor⟩
      { evaluatedTransfer sender recipient amount with
        requiredEnvReads := [.currentTime], declaredEnvReads := [.currentTime] },
    [output index 0 .usd snapshot]⟩⟩
def timedInitial : Cur := cursor (world 10 0 0) [] [] 4
def timedEvent1 := timedRaw 4 timedFirst aliceCell bobCell 3 104 (world 10 0 0) (world 7 3 0) 7
def timedEvent2 := timedRaw 5 timedSecond bobCell aliceCell 1 105 (world 7 3 0) (world 8 2 0) 8
def timedExpected : Cur := cursor (world 8 2 0) [timedEvent1, timedEvent2]
  [output 4 0 .usd 7, output 5 0 .usd 8] 6


/-- Literal continuation distinguishes current-world threading from history threading. -/
def worldChainCall : Inv := movement 1 carol
def worldChainEvent := rawTransfer 1 worldChainCall aliceCell carolCell 1
  (world 3 7 0) (world 2 7 1) 2
def worldChainExpected : Cur := cursor (world 2 7 1) [firstEvent, worldChainEvent]
  [output 0 0 .usd 3, output 1 0 .usd 2] 2

/-- The zero-dollar producer preserves the entry ledger but publishes a nonzero snapshot. -/
def historyChainProducer : Inv := movement 0 .bob
def historyChainConsumer : Inv :=
  { movement 10 carol with inputs := [.priorOutput 0 ⟨⟨0⟩, ⟨0⟩⟩] }
def historyProducerEvent := rawTransfer 0 historyChainProducer aliceCell bobCell 0
  (world 10 0 0) (world 10 0 0) 10
def historyConsumerEvent := rawTransfer 1 historyChainConsumer aliceCell carolCell 10
  (world 10 0 0) (world 0 0 10) 0
def historyChainExpected : Cur := cursor (world 0 0 10)
  [historyProducerEvent, historyConsumerEvent] [output 0 0 .usd 10, output 1 0 .usd 0] 2

/-- Literal inputs and index-selected times exercise position without a prior-output read. -/
def indexChainBoundary (index : Nat) : Boundary P A D :=
  ⟨aliceContext, fresh, 200 + index⟩
def indexChainInitial : Cur := cursor (world 10 0 0) [] [] 9
def indexChainFirst : Inv := timedMove 2 209 .bob
def indexChainSecond : Inv := timedMove 1 210 carol
def indexChainEvent1 := timedRaw 9 indexChainFirst aliceCell bobCell 2 209
  (world 10 0 0) (world 8 2 0) 8
def indexChainEvent2 := timedRaw 10 indexChainSecond aliceCell carolCell 1 210
  (world 8 2 0) (world 7 2 1) 7
def indexChainExpected : Cur := cursor (world 7 2 1) [indexChainEvent1, indexChainEvent2]
  [output 9 0 .usd 8, output 10 0 .usd 7] 11

/-- A funded second leaf after an empty first child needs no changed intermediate cursor. -/
def childExecutionCall : Inv := movement 2 .bob
def childExecutionEvent := rawTransfer 0 childExecutionCall aliceCell bobCell 2
  (world 10 0 0) (world 8 2 0) 8
def childExecutionExpected : Cur := cursor (world 8 2 0) [childExecutionEvent]
  [output 0 0 .usd 8] 1

def extendedCfg : Config P A D := { cfg with
  registry := fun op ↦ if op = ⟨99⟩ then some Parallel.Examples.noOp else cfg.registry op
  catalog := cfg.catalog ++ [⟨⟨99⟩, [], [], [], [⟨⟨99⟩, [], []⟩]⟩] }
def changedRegistry : Config P A D := { cfg with
  registry := fun op ↦
    if op = ⟨10⟩ then some { Typed.Examples.transfer with guard := .lit false }
    else cfg.registry op }
def changedOutput : Config P A D := Parallel.Examples.config
  Typed.Examples.transfer Parallel.Examples.noOp [bobCell] []
def invalidAdded : Config P A D := { cfg with catalog := cfg.catalog ++ cfg.catalog }
def changedAdmin : Config P A D := { cfg with domainAdmin := fun _ ↦ .bob }
def grantOnlyCfg : Config P A D := { cfg with
  registry := fun op ↦
    if op = ⟨77⟩ then some Parallel.Examples.noOp else cfg.registry op }
def grantOnlyChanged : Config P A D := { cfg with
  registry := fun op ↦
    if op = ⟨77⟩ then some { Parallel.Examples.noOp with domain := .other }
    else cfg.registry op }
def grantOnly : Grant P A D := ⟨.alice, .main, ⟨77⟩, .invoke⟩
def issueBoundary : Boundary P A D := ⟨adminContext, fresh, 100⟩
def grantOnlyStore : Store := ⟨mainStore.entries ++ [⟨grantOnly, true⟩]⟩
def changedOutputExpected : Cur := { afterFirst with
  events := [{ firstEvent with result := { firstEvent.result with
    outputs := [output 0 0 .usd 7] } }]
  outputs := [output 0 0 .usd 7] }
def failedInitial (action : Action) (reason : Composition.Failure) : Cur :=
  { initial with failure := some ⟨0, some action, reason⟩ }

/-- Exact one-entry counterexample: the funded prefix moves one dollar from Carol to Alice. -/
def fundingStore : Store := ⟨mainStore.entries ++
  [⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
   ⟨⟨.alice, .main, ⟨11⟩, .debit carolCell⟩, true⟩]⟩
def fundingCaps : List CapabilityId := [⟨0⟩, ⟨1⟩, ⟨2⟩, ⟨3⟩, ⟨4⟩, ⟨5⟩]
def fundingInitial : Cur := cursor (world 0 0 2 fundingStore) [] [] 0
def fundingCfg : Config P A D := Parallel.Examples.config Typed.Examples.transfer
  (Parallel.Examples.transferTemplate .usd (.literal carol) (.literal .alice)) [aliceCell] []
def fundingBoundary : Nat → Boundary P A D := constantBoundary
def fundingCall : Inv := ⟨⟨1⟩, ⟨11⟩, [], [.literal ⟨.amount .usd, 1⟩], fundingCaps, none⟩
def firstHidden : Inv := movement 1 .bob fundingCaps
def fundingEvent : RawEvent := ⟨0, .invoke fundingCall, world 0 0 2 fundingStore,
  ⟨world 1 0 1 fundingStore,
    .invoked ⟨⟨11⟩, [], [⟨.amount .usd, 1⟩], fundingCaps, none⟩
      (evaluatedTransfer carolCell aliceCell 1), []⟩⟩
def exposedEvent := rawTransfer 1 firstHidden aliceCell bobCell 1
  (world 1 0 1 fundingStore) (world 0 1 1 fundingStore) 0
def fundingExposed : Cur := cursor (world 0 1 1 fundingStore) [fundingEvent, exposedEvent]
  [output 1 0 .usd 0] 2

-- BEGIN PROOFS

end DefiKernel.Metatheory.Examples
