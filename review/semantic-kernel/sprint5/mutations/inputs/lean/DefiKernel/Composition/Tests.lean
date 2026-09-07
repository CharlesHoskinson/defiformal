import DefiKernel.Composition.Examples
namespace DefiKernel.Composition.Tests
open Typed Typed.Examples Examples

/-- Independent complete 32-cell oracle in allCells order. -/
def balances (alice bob vault shares : ℚ) : List ℚ :=
  [alice, shares, 10, 2, bob, 0, 0, 0, vault, 0, 0, 0, 100, 0, 0, 0] ++
    List.replicate 16 0

def worldEq (world : W) (values : List ℚ) (store : Store := expectedStore) : Bool :=
  decide (allCells.map world.state.balance = values ∧ world.capabilities = store)
def listEq {α} (eq : α → α → Bool) (xs ys : List α) : Bool :=
  xs.length == ys.length && (xs.zip ys).all (fun (a,b) ↦ eq a b)
def sourceEq : InputSource Asset → InputSource Asset → Bool
  | .literal a, .literal b => decide (a = b)
  | .priorOutput i p, .priorOutput j q => i == j && p == q
  | _, _ => false
def stepEq : S → S → Bool
  | .invoke a, .invoke b => a.component == b.component && a.operation == b.operation &&
      decide (a.parties = b.parties ∧ a.capabilityIds = b.capabilityIds ∧
        a.claimedActor = b.claimedActor) && listEq sourceEq a.inputs b.inputs
  | .issue a, .issue b => a == b
  | .revoke a, .revoke b => a == b
  | _, _ => false
def outputEq (a b : OutputObservation Asset) : Bool :=
  a.step == b.step && a.port == b.port && decide (a.value = b.value)
def obs (index component port : Nat) (asset : Asset) (q : ℚ) : OutputObservation Asset :=
  ⟨index, ⟨⟨component⟩, ⟨port⟩⟩, ⟨.amount asset, q⟩⟩

structure ExpectedEvent where
  step : S
  before : List ℚ
  after : List ℚ
  preStore : Store := expectedStore
  postStore : Store := expectedStore
  arguments : List (PackedValue Asset) := []
  deltas : List (C × ℚ) := []
  supplies : List ((Domain × Asset) × ℚ) := []
  writes : List C := []
  outputs : List (OutputObservation Asset) := []
  adminId : CapabilityId := ⟨0⟩
  envReads : List (EnvRead Domain) := []

def eventEq (index : Nat) (a : Event Party Asset Domain) (e : ExpectedEvent) : Bool :=
  a.index == index && stepEq a.step e.step && worldEq a.before e.before e.preStore &&
  worldEq a.result.world e.after e.postStore && listEq outputEq a.result.outputs e.outputs &&
  match a.result.receipt, e.step with
  | .invoked request value, .invoke inv =>
    request.operation == inv.operation && decide (request.parties = inv.parties ∧
      request.arguments = e.arguments ∧ request.capabilityIds = inv.capabilityIds ∧
      request.claimedActor = inv.claimedActor) &&
    decide (value.guard = true ∧ value.deltas = e.deltas ∧ value.supplies = e.supplies ∧
      value.writes = e.writes ∧ value.requiredStateReads = [] ∧
      value.requiredEnvReads = e.envReads ∧ value.declaredStateReads = [] ∧
      value.declaredEnvReads = e.envReads) &&
    (allCells.all fun c ↦ decide (value.effect c =
      ((e.deltas.filter (fun d ↦ d.1 == c)).map Prod.snd).sum)) &&
    ([Domain.main, .other].all fun d ↦ [Asset.usd, .share, .collateral, .debt].all fun a ↦
      decide (aSupply value d a = ((e.supplies.filter (fun s ↦ s.1 == (d,a))).map Prod.snd).sum))
  | .issued id, .issue _ => id == e.adminId
  | .revoked id, .revoke _ => id == e.adminId
  | _, _ => false
where aSupply := Evaluated.supply

def cursorEq (actual : Cursor Party Asset Domain) (events : List ExpectedEvent)
    (final : List ℚ) (failure : Option (S × Failure) := none)
    (store : Store := expectedStore) : Bool :=
  worldEq actual.world final store && actual.nextIndex == events.length &&
  actual.events.length == events.length &&
  (actual.events.zip events).zipIdx.all (fun ((a,e),i) ↦ eventEq i a e) &&
  listEq outputEq actual.outputs (events.flatMap ExpectedEvent.outputs) &&
  match actual.failure, failure with
  | none, none => true
  | some a, some (step, reason) => a.index == events.length && a.reason == reason &&
      (match a.step with | some s => stepEq s step | none => false)
  | _, _ => false

def tEvent (i : Nat) (q beforeAlice beforeBob afterAlice afterBob : ℚ)
    (shares : ℚ := 4) (vault : ℚ := 20) : ExpectedEvent :=
  ⟨transferStep q, balances beforeAlice beforeBob vault shares,
    balances afterAlice afterBob vault shares, expectedStore, expectedStore,
    [⟨.amount .usd,q⟩], [(aliceUsd,-q),(bobUsd,q)], [], [aliceUsd,bobUsd],
    [obs i 0 1 .usd afterAlice], ⟨0⟩, []⟩
def dEvent (i : Nat) (step : S) (q beforeAlice afterAlice bob beforeVault afterVault
    beforeShare afterShare : ℚ) : ExpectedEvent :=
  ⟨step, balances beforeAlice bob beforeVault beforeShare,
    balances afterAlice bob afterVault afterShare, expectedStore, expectedStore,
    [⟨.amount .usd,q⟩], [(aliceUsd,-q),(vaultUsd,q),(aliceShare,q/2)],
    [((.main,.share),q/2)], [aliceUsd,vaultUsd,aliceShare],
    [obs i 1 3 .share afterShare, obs i 1 4 .usd afterAlice], ⟨0⟩, []⟩
def wEvent : ExpectedEvent :=
  ⟨withdrawStep 2, balances 3 3 24 6, balances 7 3 20 4, expectedStore, expectedStore,
    [⟨.amount .share,2⟩], [(vaultUsd,-4),(aliceUsd,4),(aliceShare,-2)],
    [((.main,.share),-2)], [vaultUsd,aliceUsd,aliceShare], [obs 2 1 6 .usd 7], ⟨0⟩, []⟩
def execute (steps : List S) := Composition.run cfg boundary initialWorld steps

def t3 := tEvent 0 3 10 0 7 3
def d4 := dEvent 0 (depositStep 4) 4 10 6 0 20 24 4 6
def route7 := dEvent 1 (routedDeposit 0) 7 7 0 3 20 27 4 (15/2)

def adminGrant : Grant Party Asset Domain := grant transferId .invoke
def adminStore : Store := ⟨expectedStore.entries.drop 1⟩
/-- The issued ID is 11; the old invoke entry was removed only in the initial fixture. -/
def issuedStore : Store := ⟨adminStore.entries ++ [⟨adminGrant, true⟩]⟩
def revokedStore : Store := ⟨adminStore.entries ++ [⟨adminGrant, false⟩]⟩
def adminUse : S := .invoke
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd,3⟩], [⟨0⟩,⟨11⟩], none⟩
def adminBounds (i : Nat) : Boundary Party Asset Domain :=
  ⟨if i = 0 ∨ i = 2 then adminContext else aliceContext, fresh, 100+i⟩
def issueEvent : ExpectedEvent :=
  { step := .issue adminGrant, before := balances 10 0 20 4, after := balances 10 0 20 4,
    preStore := adminStore, postStore := issuedStore, adminId := ⟨11⟩ }
def useEvent : ExpectedEvent :=
  { (tEvent 1 3 10 0 7 3) with
    step := adminUse
    preStore := issuedStore
    postStore := issuedStore }
def revokeEvent : ExpectedEvent :=
  { step := .revoke ⟨11⟩, before := balances 7 3 20 4, after := balances 7 3 20 4,
    preStore := issuedStore, postStore := revokedStore, adminId := ⟨11⟩ }
def adminRun (steps : List S) := Composition.run cfg adminBounds ⟨initial,adminStore⟩ steps

def isolatedCatalog (shared writable : Bool) : Catalog Party Asset Domain := [
  ⟨⟨0⟩, [bobUsd], [⟨⟨10⟩, aliceUsd, true⟩], [], [transferInterface]⟩,
  ⟨⟨1⟩, [aliceShare], [], [⟨⟨⟨0⟩,⟨10⟩⟩,aliceUsd,true⟩] ++
    (if shared then [⟨⟨⟨2⟩,⟨20⟩⟩,vaultUsd,writable⟩] else []),
    [depositInterface,withdrawInterface]⟩,
  ⟨⟨2⟩, if shared then [collateral] else [collateral,vaultUsd],
    if shared then [⟨⟨20⟩,vaultUsd,true⟩] else [], [], []⟩]
def isolatedRun (shared writable : Bool) (steps : List S) :=
  Composition.run { cfg with catalog := isolatedCatalog shared writable }
    boundary initialWorld steps

def hiddenTransfer : Op := { transfer with
  guard := .ite (.lit true) transfer.guard
    (.binary (.le (.amount Asset.collateral)) (.lit 0) (.balance (ref .collateral .caller))) }
def hiddenCfg : Config Party Asset Domain := { cfg with
  registry := fun id ↦ if id = transferId then some hiddenTransfer else registry id }
def wrongComponent : S := .invoke
  ⟨⟨1⟩,transferId,[.bob],[.literal ⟨.amount .usd,3⟩],allCapabilityIds,none⟩
def actorMismatch : S := .invoke
  ⟨⟨0⟩,transferId,[.bob],[.literal ⟨.amount .usd,3⟩],allCapabilityIds,some .bob⟩
def sharedWithdrawEvent : ExpectedEvent :=
  ⟨withdrawStep 2,balances 10 0 20 4,balances 14 0 16 2,expectedStore,expectedStore,
    [⟨.amount .share,2⟩],[(vaultUsd,-4),(aliceUsd,4),(aliceShare,-2)],
    [((.main,.share),-2)],[vaultUsd,aliceUsd,aliceShare],[obs 0 1 6 .usd 14],⟨0⟩, []⟩

/-- Position zero is an administrator, later positions are Alice. -/
def resumeBounds (i : Nat) : Boundary Party Asset Domain :=
  ⟨if i = 0 then adminContext else aliceContext,fresh,100+i⟩
def resumeStore : Store := ⟨expectedStore.entries ++ [⟨adminGrant,true⟩]⟩
def resumeIssue : ExpectedEvent :=
  { issueEvent with preStore := expectedStore, postStore := resumeStore, adminId := ⟨12⟩ }
def resumeTransfer : ExpectedEvent :=
  { (tEvent 1 3 10 0 7 3) with preStore := resumeStore, postStore := resumeStore }
def resumeDeposit : ExpectedEvent :=
  { (dEvent 2 (routedDeposit 1) 7 7 0 3 20 27 4 (15/2)) with
    preStore := resumeStore
    postStore := resumeStore }
def resumePrefix := Composition.run cfg resumeBounds initialWorld [.issue adminGrant,transferStep 3]

def timedDeposit : Op := { deposit with
  guard := .binary .and deposit.guard (.binary (.le .scalar) (.lit 102) .now)
  envReads := [.currentTime] }
def timedCfg : Config Party Asset Domain := { cfg with
  registry := fun id ↦ if id = depositId then some timedDeposit else registry id }
def timedPrefix :=
  Composition.run timedCfg resumeBounds initialWorld [.issue adminGrant, transferStep 3]
def timedEvent : ExpectedEvent := { resumeDeposit with envReads := [.currentTime] }

def invalidRun := Composition.run { cfg with catalog := catalog ++ catalog }
  boundary initialWorld [transferStep 3]

def checks : List (String × Bool) := [
  ("workflows.isolation.catalogs", [isolatedCatalog false false,isolatedCatalog true false,
    isolatedCatalog true true].all (validateCatalog registry)),
  ("workflows.isolation.private", cursorEq (isolatedRun false false [withdrawStep 2]) []
    (balances 10 0 20 4) (some (withdrawStep 2,.interface .writeAccess)) &&
    hasAuthority expectedStore allCapabilityIds aliceContext withdrawId (.debit vaultUsd)),
  ("workflows.isolation.shared", cursorEq (isolatedRun true true [withdrawStep 2])
    [sharedWithdrawEvent] (balances 14 0 16 2)),
  ("workflows.isolation.readonly", cursorEq (isolatedRun true false [withdrawStep 2]) []
    (balances 10 0 20 4) (some (withdrawStep 2,.interface .writeAccess))),
  ("workflows.isolation.hidden.read", cursorEq
    (Composition.run hiddenCfg boundary initialWorld [transferStep 3]) []
    (balances 10 0 20 4) (some (transferStep 3,.interface .readAccess))),
  ("workflows.isolation.wrong.component", cursorEq (execute [wrongComponent]) []
    (balances 10 0 20 4) (some (wrongComponent,.interface .unknownOperation))),
  ("workflows.actor", cursorEq (execute [actorMismatch]) [] (balances 10 0 20 4)
    (some (actorMismatch,.kernel .actorMismatch))),
  ("workflows.configuration", let result := invalidRun
    worldEq result.world (balances 10 0 20 4) && result.events.isEmpty && result.outputs.isEmpty &&
    result.nextIndex == 0 && (match result.failure with
      | some f => f.index == 0 && f.step.isNone && f.reason == .configuration | none => false)),
  ("workflows.resume.time", cursorEq
    (continueRun timedCfg resumeBounds timedPrefix [routedDeposit 1])
    [resumeIssue,resumeTransfer,timedEvent] (balances 0 3 27 (15/2)) none resumeStore &&
    cursorEq (Composition.run timedCfg resumeBounds initialWorld
      [.issue adminGrant,transferStep 3,routedDeposit 1])
    [resumeIssue,resumeTransfer,timedEvent] (balances 0 3 27 (15/2)) none resumeStore),
  ("workflows.resume.time.negative", cursorEq
    (continueRun timedCfg boundary timedPrefix [routedDeposit 1])
    [resumeIssue,resumeTransfer] (balances 7 3 20 4)
    (some (routedDeposit 1,.kernel .guard)) resumeStore),
  ("workflows.resume.boundary", cursorEq
    (continueRun cfg resumeBounds resumePrefix [routedDeposit 1])
    [resumeIssue,resumeTransfer,resumeDeposit] (balances 0 3 27 (15/2)) none resumeStore &&
    cursorEq (Composition.run cfg resumeBounds initialWorld
      [.issue adminGrant,transferStep 3,routedDeposit 1])
    [resumeIssue,resumeTransfer,resumeDeposit] (balances 0 3 27 (15/2)) none resumeStore),
  ("workflows.catalog", validateCatalog registry catalog),
  ("workflows.initial.complete", worldEq initialWorld (balances 10 0 20 4) &&
    (match provisioned with | .ok s => s == expectedStore | _ => false)),
  ("workflows.empty", cursorEq (execute []) [] (balances 10 0 20 4)),
  ("workflows.transfer.deposit.withdraw", cursorEq (execute workflow)
    [t3, dEvent 1 (depositStep 4) 4 7 3 3 20 24 4 6, wEvent] (balances 7 3 20 4)),
  ("workflows.consecutive", cursorEq (execute [transferStep 3,transferStep 3])
    [t3,tEvent 1 3 7 3 4 6] (balances 4 6 20 4)),
  ("workflows.order.transfer.first", cursorEq
    (execute [transferStep 8,depositStep 4,transferStep 1]) [tEvent 0 8 10 0 2 8]
    (balances 2 8 20 4) (some (depositStep 4,.kernel .insufficientFunds))),
  ("workflows.order.deposit.first", cursorEq
    (execute [depositStep 4,transferStep 8,transferStep 1]) [d4]
    (balances 6 0 24 6) (some (transferStep 8,.kernel .insufficientFunds))),
  ("workflows.snapshot", cursorEq (execute [transferStep 3,routedDeposit 0])
    [t3,route7] (balances 0 3 27 (15/2))),
  ("workflows.output.index", cursorEq
    (execute [transferStep 3,transferStep 2,routedDeposit 1])
    [t3,tEvent 1 2 7 3 5 5,dEvent 2 (routedDeposit 1) 5 5 0 5 20 25 4 (13/2)]
    (balances 0 5 25 (13/2))),
  ("workflows.output.unit", let bad := depositSource (.priorOutput 0 ⟨⟨1⟩,⟨3⟩⟩)
    cursorEq (execute [depositStep 4,bad,transferStep 1]) [d4] (balances 6 0 24 6)
      (some (bad,.interface .inputUnit))),
  ("workflows.output.forward", cursorEq (execute [routedDeposit 1]) []
    (balances 10 0 20 4) (some (routedDeposit 1,.interface .unavailableOutput))),
  ("workflows.output.unknown", let bad := depositSource (.priorOutput 0 ⟨⟨0⟩,⟨99⟩⟩)
    cursorEq (execute [transferStep 3,bad]) [t3] (balances 7 3 20 4)
      (some (bad,.interface .unavailableOutput))),
  ("workflows.first.refusal", cursorEq (execute [transferStep 11,transferStep 1]) []
    (balances 10 0 20 4) (some (transferStep 11,.kernel .insufficientFunds))),
  ("workflows.admin.revocation", cursorEq
    (adminRun [.issue adminGrant,adminUse,.revoke ⟨11⟩,adminUse])
    [issueEvent,useEvent,revokeEvent] (balances 7 3 20 4)
    (some (adminUse,.kernel .unauthorizedInvoke)) revokedStore),
  ("workflows.admin.live.repeat", cursorEq
    (Composition.run cfg (fun i ↦ if i = 0 then adminBounds 0 else boundary i)
      ⟨initial,adminStore⟩ [.issue adminGrant,adminUse,adminUse])
    [issueEvent,useEvent,{ (tEvent 2 3 7 3 4 6) with
      step := adminUse
      preStore := issuedStore
      postStore := issuedStore }] (balances 4 6 20 4) none issuedStore),
  ("workflows.resume.output", cursorEq
    (continueRun cfg boundary (execute [transferStep 3]) [routedDeposit 0])
    [t3,route7] (balances 0 3 27 (15/2))),
  ("workflows.resume.terminal", cursorEq
    (continueRun cfg boundary (execute [depositStep 4,transferStep 8]) [transferStep 1])
    [d4] (balances 6 0 24 6) (some (transferStep 8,.kernel .insufficientFunds))),
  ("workflows.frame.collateral", (execute workflow).world.state.balance collateral == 10),
  ("workflows.frame.unsupported.counterexample",
    initial.balance aliceUsd == 10 &&
      (execute [transferStep 3]).world.state.balance aliceUsd != 10)]

-- BEGIN PROOFS
#eval show IO _root_.Unit from do
  if checks.isEmpty then throw (IO.userError "Composition workflow checks empty")
  for (label, ok) in checks do IO.println s!"{label}: {ok}"
  if checks.any (fun entry ↦ !entry.2) then
    throw (IO.userError "Composition workflow checks failed")
end DefiKernel.Composition.Tests
