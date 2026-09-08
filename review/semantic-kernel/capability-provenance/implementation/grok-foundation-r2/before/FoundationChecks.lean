import DefiKernel.CapabilityProvenance.Trace

/-! Independent literal foundation checks. These are not F01–F20, not production mutation
evidence, and do not import old Tests/Acceptance modules. -/
namespace DefiKernel.CapabilityProvenance.FoundationChecks

open Typed Composition CapabilityProvenance

abbrev P := Fin 2
abbrev A := Fin 1
abbrev D := Fin 2

def op : OperationId := ⟨0⟩

def registry : Registry P A D := fun id ↦
  if id = op then some
    { signature := []
      domain := 0
      partyArity := 0
      guard := .lit true
      deltas := []
      supplyDeltas := []
      stateReads := []
      envReads := []
      writes := [] }
  else none

def catalog : Catalog P A D :=
  [{ id := ⟨0⟩
     privateCells := []
     exports := []
     imports := []
     operations := [{ operation := op, inputs := [], outputs := [] }] }]

def cfg : Config P A D := ⟨registry, fun _ ↦ 0, catalog⟩
def env : Environment A D := fun _ ↦ none
def admin : Boundary P A D := ⟨⟨0, 0⟩, env, 0⟩
def holder : InvocationContext P D := ⟨1, 0⟩
def bounds (_ : Nat) : Boundary P A D := admin

def emptyState : State P A D where
  balance _ := 0
  nonneg _ := le_rfl

def emptyWorld : World P A D := ⟨emptyState, .empty⟩

def liveGrant : Grant P A D := ⟨1, 0, op, .invoke⟩
def deadGrant : Grant P A D := ⟨1, 0, op, .debit (0, 1, 0)⟩

def nonemptyStore : CapabilityStore P A D :=
  ⟨[⟨liveGrant, true⟩, ⟨deadGrant, false⟩]⟩

def nonemptyWorld : World P A D := ⟨emptyState, nonemptyStore⟩

def allRoots : TrustedRoot P A D := fun _ _ ↦ True

def issueStep : Step P A D := .issue liveGrant
def revokeStep : Step P A D := .revoke ⟨0⟩

def forgedEvent : Event P A D :=
  ⟨99, .issue liveGrant, emptyWorld,
    ⟨⟨emptyState, ⟨[⟨liveGrant, true⟩]⟩⟩, .issued ⟨0⟩, []⟩⟩

def capLive : Capability P A D := ⟨liveGrant, true⟩
def capHolder : Capability P A D := { capLive with holder := 0 }
def capDomain : Capability P A D := { capLive with domain := 1 }
def capOp : Capability P A D := { capLive with operation := ⟨1⟩ }
def capRight : Capability P A D := { capLive with right := .debit (0, 1, 0) }
def capDead : Capability P A D := { capLive with live := false }

def policy : SupportPolicy P A D := ⟨[(0, 0, 0)], [⟨0⟩], true⟩
def policyHidden : SupportPolicy P A D := ⟨[(0, 0, 0)], [⟨0⟩], false⟩
def policyLive : SupportPolicy P A D := ⟨[(0, 0, 0)], [⟨1⟩], false⟩

def worldA : World P A D := nonemptyWorld
def worldB : World P A D :=
  ⟨emptyState, ⟨[⟨liveGrant, true⟩, ⟨deadGrant, true⟩]⟩⟩

def issuedCursor := run cfg bounds emptyWorld [issueStep]
def revokedCursor := run cfg bounds nonemptyWorld [revokeStep]
def mixedBounds : Nat → Boundary P A D
  | 0 => admin
  | _ => ⟨holder, env, 0⟩
def rejectedAdmin := run cfg mixedBounds emptyWorld [issueStep, issueStep]

def req : OriginRequest P A D :=
  ⟨[⟨0⟩], holder, op, .invoke, [⟨0⟩]⟩

def forgedOrigin := issuedOrigin [forgedEvent] ⟨0⟩

def checks : List (String × Bool) := [
  ("foundation.catalog.valid", validateCatalog cfg.registry cfg.catalog),
  ("foundation.empty.origin.none",
    decide (originOf emptyWorld [] ⟨0⟩ = none)),
  ("foundation.nonempty.live.initial",
    decide (originOf nonemptyWorld [] ⟨0⟩ = some (.initial liveGrant))),
  ("foundation.nonempty.dead.initial",
    decide (originOf nonemptyWorld [] ⟨1⟩ = some (.initial deadGrant))),
  ("foundation.issue.id.zero",
    match issuedCursor.events with
    | [e] =>
      match e.result.receipt with
      | .issued id => decide (id = ⟨0⟩)
      | _ => false
    | _ => false),
  ("foundation.issue.origin.issued",
    decide (originOf emptyWorld issuedCursor.events ⟨0⟩ =
      some (.issued 0 liveGrant))),
  ("foundation.revoke.keeps.id",
    match nonemptyWorld.capabilities.lookup ⟨1⟩, revokedCursor.world.capabilities.lookup ⟨1⟩ with
    | some pre, some post => decide (pre.toGrant = post.toGrant ∧ post.live = false)
    | _, _ => false),
  ("foundation.current.authority.first-valid",
    match currentAuthorityOrigin nonemptyWorld
        { world := nonemptyWorld, events := [], outputs := [], nextIndex := 0, failure := none }
        holder op .invoke [⟨99⟩, ⟨1⟩, ⟨0⟩] with
    | some (id, .initial g) => decide (id = ⟨0⟩ ∧ g = liveGrant)
    | _ => false),
  ("foundation.current.skips.dead",
    decide (authorizesId nonemptyStore holder op .invoke ⟨1⟩ = false)),
  ("foundation.forged.query.reads.without.certificate",
    decide (forgedOrigin = some (.issued 99 liveGrant))),
  ("foundation.auditRun.delegates",
    let a := auditRun cfg bounds emptyWorld [issueStep] req
    let b := run cfg bounds emptyWorld [issueStep]
    decide (a.cursor.nextIndex = b.nextIndex) &&
      decide (a.cursor.failure.isNone = b.failure.isNone) &&
      decide (a.cursor.events.length = b.events.length)),
  ("foundation.rejected.admin.prefix",
    decide (rejectedAdmin.events.length = 1 ∧
      rejectedAdmin.failure.isSome ∧
      rejectedAdmin.world.capabilities.entries.length = 1)),
  ("foundation.capEq.equal", capEq capLive capLive),
  ("foundation.capEq.holder.negative", !capEq capLive capHolder),
  ("foundation.capEq.domain.negative", !capEq capLive capDomain),
  ("foundation.capEq.operation.negative", !capEq capLive capOp),
  ("foundation.capEq.right.negative", !capEq capLive capRight),
  ("foundation.capEq.live.negative", !capEq capLive capDead),
  ("foundation.viewEq.equal",
    viewEq (observeWorld policy worldA) (observeWorld policy worldA)),
  ("foundation.viewEq.live.negative",
    !viewEq (observeWorld policyLive worldA) (observeWorld policyLive worldB)),
  ("foundation.viewEq.nextId.hidden.ignores.allocation",
    viewEq (observeWorld policyHidden worldA)
      (observeWorld policyHidden
        ⟨emptyState, ⟨nonemptyStore.entries ++ [⟨liveGrant, true⟩]⟩⟩)),
  ("foundation.viewEq.nextId.observed.differs",
    !viewEq (observeWorld policy worldA)
      (observeWorld policy
        ⟨emptyState, ⟨nonemptyStore.entries ++ [⟨liveGrant, true⟩]⟩⟩)),
  ("foundation.selected.not.full.store",
    decide (worldA.capabilities ≠ worldB.capabilities) &&
      decide (worldA.capabilities.lookup ⟨0⟩ = worldB.capabilities.lookup ⟨0⟩))
]

def main : IO Unit := do
  if checks.isEmpty then throw (IO.userError "Empty capability foundation inventory")
  let names := checks.map Prod.fst
  if names.eraseDups.length != names.length then
    throw (IO.userError "Duplicate capability foundation names")
  let mut failed := 0
  for (label, passed) in checks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then
    throw (IO.userError s!"Capability foundation comparisons failed: {failed}")

#eval main

-- BEGIN PROOFS

theorem empty_roots : RootsAccepted allRoots (CapabilityStore.empty : CapabilityStore P A D) :=
  rootsAccepted_empty allRoots

theorem nonempty_roots : RootsAccepted allRoots nonemptyStore := by
  intro id cap h
  trivial

theorem empty_world_roots : RootsAccepted allRoots emptyWorld.capabilities :=
  empty_roots

end DefiKernel.CapabilityProvenance.FoundationChecks
