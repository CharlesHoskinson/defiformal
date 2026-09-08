import DefiKernel.CapabilityProvenance.FoundationChecks

/-! Reviewer-owned literal audit for CF1. The fabricated stale-store cursor below is
only a negative data control; it has no initialized-trace certificate. No kernel
implementation or accepted namespace is changed. This is not a production mutant. -/
namespace P05Reviewer
open DefiKernel.Typed DefiKernel.Composition DefiKernel.CapabilityProvenance
open DefiKernel.CapabilityProvenance.FoundationChecks

def staleStoreCursor : Cursor P A D := { revokedCursor with world := nonemptyWorld }

def revokedIdExpected (cursor : Cursor P A D) : Bool :=
  match cursor.world.capabilities.lookup ⟨0⟩ with
  | some cap => decide (cap.toGrant = liveGrant ∧ cap.live = false) &&
      decide (authorizesId cursor.world.capabilities holder op .invoke ⟨0⟩ = false) &&
      decide (currentAuthorityOrigin nonemptyWorld cursor holder op .invoke [⟨0⟩] = none)
  | none => false

def rows : List (String × Bool) := [
  ("CF1.before.id0.live.same-full-grant",
    decide (nonemptyWorld.capabilities.lookup ⟨0⟩ = some ⟨liveGrant, true⟩)),
  ("CF1.before.id0.invoke.authorized",
    authorizesId nonemptyWorld.capabilities holder op .invoke ⟨0⟩),
  ("CF1.actual.revoke.id0.receipt",
    match revokedCursor.events with
    | [e] =>
      match e.step, e.result.receipt with
      | .revoke rid, .revoked receiptId => decide (e.index = 0 ∧ rid = ⟨0⟩ ∧ receiptId = ⟨0⟩)
      | _, _ => false
    | _ => false),
  ("CF1.actual.revoke.id0.complete-expectation", revokedIdExpected revokedCursor),
  ("CF1.same-grant.live-id1.positive",
    authorizesId reissueCursor.world.capabilities holder op .invoke ⟨1⟩ &&
      decide (currentAuthorityOrigin emptyWorld reissueCursor holder op .invoke [⟨1⟩] =
        some (⟨1⟩, .issued 2 liveGrant))),
  ("CF1.stale-store.control.rejected", !revokedIdExpected staleStoreCursor),
  ("CF1.stale-store.control.old-authority-present",
    authorizesId staleStoreCursor.world.capabilities holder op .invoke ⟨0⟩ &&
      decide (currentAuthorityOrigin nonemptyWorld staleStoreCursor holder op .invoke [⟨0⟩] =
        some (⟨0⟩, .initial liveGrant))),
  ("CF1.old-peer-row.remains-only-peer-preservation",
    decide (staleStoreCursor.world.capabilities.lookup ⟨1⟩ = some ⟨deadGrant, false⟩))
]

def runAudit : IO Unit := do
  if rows.isEmpty then throw (IO.userError "BLOCKED empty CF1 audit")
  for (name, passed) in rows do
    IO.println s!"P05_REVIEW {name}: {passed}"
    if !passed then throw (IO.userError s!"CF1 literal failure: {name}")
  IO.println s!"P05_REVIEW_COUNT {rows.length}"
#eval runAudit
end P05Reviewer
