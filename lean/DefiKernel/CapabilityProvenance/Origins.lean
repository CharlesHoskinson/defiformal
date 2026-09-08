import DefiKernel.Composition.Sequence

/-! Read-only capability origin queries. These functions observe actual or caller-supplied
data; they are not certificates unless an initialized TraceSound premise is supplied. -/
namespace DefiKernel.CapabilityProvenance

open Typed Composition

/-- Explicitly supplied root policy. Not inferred from well-formedness or final-store membership. -/
abbrev TrustedRoot (P A D : Type) := CapabilityId → Grant P A D → Prop

/-- Every successful initial lookup, including initially dead allocated entries, satisfies the
supplied root policy on its complete grant. -/
def RootsAccepted {P A D : Type} (trusted : TrustedRoot P A D)
    (store : CapabilityStore P A D) : Prop :=
  ∀ id cap, store.lookup id = some cap → trusted id cap.toGrant

inductive Origin (P A D : Type) where
  | initial (grant : Grant P A D)
  | issued (eventIndex : Nat) (grant : Grant P A D)
  deriving DecidableEq, Repr

def Origin.grant {P A D : Type} : Origin P A D → Grant P A D
  | .initial grant => grant
  | .issued _ grant => grant

/-- In-order scan of matching `.issue grant` / `.issued issuedId` pairs. First match wins.
This query does not authenticate the event list. -/
def issuedOrigin {P A D : Type} :
    List (Event P A D) → CapabilityId → Option (Origin P A D)
  | [], _ => none
  | event :: rest, id =>
    match event.step, event.result.receipt with
    | .issue grant, .issued issuedId =>
      if issuedId = id then some (.issued event.index grant) else issuedOrigin rest id
    | _, _ => issuedOrigin rest id

/-- Initial lookup first; otherwise the issued-event scan. -/
def originOf {P A D : Type} (initial : World P A D) (events : List (Event P A D))
    (id : CapabilityId) : Option (Origin P A D) :=
  match initial.capabilities.lookup id with
  | some cap => some (.initial cap.toGrant)
  | none => issuedOrigin events id

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- First requested ID for which the *current* store authorizes the exact right, paired with
`originOf`. Missing current authority or missing origin yields none. Does not authenticate
`ctx`. -/
def currentAuthorityOrigin (initial : World P A D) (cursor : Cursor P A D)
    (ctx : InvocationContext P D) (operation : OperationId)
    (right : Right P A D) (ids : List CapabilityId) :
    Option (CapabilityId × Origin P A D) :=
  match ids with
  | [] => none
  | id :: rest =>
    if authorizesId cursor.world.capabilities ctx operation right id then
      match originOf initial cursor.events id with
      | some origin => some (id, origin)
      | none => none
    else
      currentAuthorityOrigin initial cursor ctx operation right rest

structure OriginRequest (P A D : Type) where
  originIds : List CapabilityId
  ctx : InvocationContext P D
  operation : OperationId
  right : Right P A D
  authorityIds : List CapabilityId

structure AuditReport (P A D : Type) where
  cursor : Cursor P A D
  origins : List (CapabilityId × Option (Origin P A D))
  current : Option (CapabilityId × Origin P A D)

variable [Fintype P] [Fintype A] [Fintype D]

/-- Exact `Composition.run` delegation plus requested origin/authority readbacks.
No second executor, store normalization, grant rewrite, or failure replacement. -/
def auditRun (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (world : World P A D) (steps : List (Step P A D)) (request : OriginRequest P A D) :
    AuditReport P A D :=
  let cursor := Composition.run cfg boundaries world steps
  { cursor := cursor
    origins := request.originIds.map (fun id ↦ (id, originOf world cursor.events id))
    current := currentAuthorityOrigin world cursor request.ctx request.operation
      request.right request.authorityIds }

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem rootsAccepted_empty (trusted : TrustedRoot P A D) :
    RootsAccepted trusted CapabilityStore.empty := by
  intro id cap h
  simp [CapabilityStore.empty, CapabilityStore.lookup] at h

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem issuedOrigin_nil (id : CapabilityId) :
    issuedOrigin ([] : List (Event P A D)) id = none := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem originOf_initial_lookup (initial : World P A D) (events : List (Event P A D))
    (id : CapabilityId) (cap : Capability P A D)
    (h : initial.capabilities.lookup id = some cap) :
    originOf initial events id = some (.initial cap.toGrant) := by
  simp [originOf, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem originOf_issued_absent (initial : World P A D) (events : List (Event P A D))
    (id : CapabilityId) (h : initial.capabilities.lookup id = none) :
    originOf initial events id = issuedOrigin events id := by
  simp [originOf, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem issuedOrigin_cons_hit (event : Event P A D) (rest : List (Event P A D))
    (id : CapabilityId) (grant : Grant P A D)
    (hs : event.step = .issue grant) (hr : event.result.receipt = .issued id) :
    issuedOrigin (event :: rest) id = some (.issued event.index grant) := by
  simp [issuedOrigin, hs, hr]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem issuedOrigin_cons_skip_id (event : Event P A D) (rest : List (Event P A D))
    (id other : CapabilityId) (grant : Grant P A D) (hne : other ≠ id)
    (hs : event.step = .issue grant) (hr : event.result.receipt = .issued other) :
    issuedOrigin (event :: rest) id = issuedOrigin rest id := by
  simp [issuedOrigin, hs, hr, hne]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem issuedOrigin_cons_skip_kind (event : Event P A D) (rest : List (Event P A D))
    (id : CapabilityId)
    (hskip : ∀ grant issuedId,
      ¬(event.step = .issue grant ∧ event.result.receipt = .issued issuedId)) :
    issuedOrigin (event :: rest) id = issuedOrigin rest id := by
  match hs : event.step, hr : event.result.receipt with
  | .issue grant, .issued issuedId =>
    exact (hskip grant issuedId ⟨hs, hr⟩).elim
  | .issue grant, .invoked request e => simp [issuedOrigin, hs, hr]
  | .issue grant, .revoked rid => simp [issuedOrigin, hs, hr]
  | .invoke inv, _ => simp [issuedOrigin, hs]
  | .revoke rid, _ => simp [issuedOrigin, hs]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem issuedOrigin_sound_raw (events : List (Event P A D)) (id : CapabilityId)
    (origin : Origin P A D) (h : issuedOrigin events id = some origin) :
    ∃ event grant, event ∈ events ∧ origin = .issued event.index grant ∧
      event.step = .issue grant ∧ event.result.receipt = .issued id := by
  induction events with
  | nil => simp [issuedOrigin] at h
  | cons event rest ih =>
    match hs : event.step, hr : event.result.receipt with
    | .issue grant, .issued issuedId =>
      simp only [issuedOrigin, hs, hr] at h
      split_ifs at h with heq
      · cases h
        refine ⟨event, grant, List.mem_cons.mpr (Or.inl rfl), rfl, hs, ?_⟩
        simp [hr, heq]
      · obtain ⟨e, g, mem, ho, hstep, hrec⟩ := ih h
        exact ⟨e, g, List.mem_cons.mpr (Or.inr mem), ho, hstep, hrec⟩
    | .issue grant, .invoked request e =>
      simp only [issuedOrigin, hs, hr] at h
      obtain ⟨ev, g, mem, ho, hstep, hrec⟩ := ih h
      exact ⟨ev, g, List.mem_cons.mpr (Or.inr mem), ho, hstep, hrec⟩
    | .issue grant, .revoked rid =>
      simp only [issuedOrigin, hs, hr] at h
      obtain ⟨ev, g, mem, ho, hstep, hrec⟩ := ih h
      exact ⟨ev, g, List.mem_cons.mpr (Or.inr mem), ho, hstep, hrec⟩
    | .invoke inv, rec =>
      simp only [issuedOrigin, hs] at h
      obtain ⟨ev, g, mem, ho, hstep, hrec⟩ := ih h
      exact ⟨ev, g, List.mem_cons.mpr (Or.inr mem), ho, hstep, hrec⟩
    | .revoke rid, rec =>
      simp only [issuedOrigin, hs] at h
      obtain ⟨ev, g, mem, ho, hstep, hrec⟩ := ih h
      exact ⟨ev, g, List.mem_cons.mpr (Or.inr mem), ho, hstep, hrec⟩

omit [Fintype P] [Fintype A] [Fintype D] in
theorem currentAuthorityOrigin_nil (initial : World P A D) (cursor : Cursor P A D)
    (ctx : InvocationContext P D) (operation : OperationId) (right : Right P A D) :
    currentAuthorityOrigin initial cursor ctx operation right [] = none := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem currentAuthorityOrigin_cons_hit (initial : World P A D) (cursor : Cursor P A D)
    (ctx : InvocationContext P D) (operation : OperationId) (right : Right P A D)
    (id : CapabilityId) (rest : List CapabilityId) (origin : Origin P A D)
    (hauth : authorizesId cursor.world.capabilities ctx operation right id = true)
    (horigin : originOf initial cursor.events id = some origin) :
    currentAuthorityOrigin initial cursor ctx operation right (id :: rest) =
      some (id, origin) := by
  simp [currentAuthorityOrigin, hauth, horigin]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem currentAuthorityOrigin_cons_unauthorized (initial : World P A D) (cursor : Cursor P A D)
    (ctx : InvocationContext P D) (operation : OperationId) (right : Right P A D)
    (id : CapabilityId) (rest : List CapabilityId)
    (hauth : authorizesId cursor.world.capabilities ctx operation right id = false) :
    currentAuthorityOrigin initial cursor ctx operation right (id :: rest) =
      currentAuthorityOrigin initial cursor ctx operation right rest := by
  simp [currentAuthorityOrigin, hauth]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem currentAuthorityOrigin_cons_authorized_no_origin (initial : World P A D)
    (cursor : Cursor P A D) (ctx : InvocationContext P D) (operation : OperationId)
    (right : Right P A D) (id : CapabilityId) (rest : List CapabilityId)
    (hauth : authorizesId cursor.world.capabilities ctx operation right id = true)
    (horigin : originOf initial cursor.events id = none) :
    currentAuthorityOrigin initial cursor ctx operation right (id :: rest) = none := by
  simp [currentAuthorityOrigin, hauth, horigin]

theorem auditRun_delegates (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (world : World P A D) (steps : List (Step P A D)) (request : OriginRequest P A D) :
    (auditRun cfg boundaries world steps request).cursor =
      Composition.run cfg boundaries world steps := rfl

theorem auditRun_origins (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (world : World P A D) (steps : List (Step P A D)) (request : OriginRequest P A D) :
    (auditRun cfg boundaries world steps request).origins =
      request.originIds.map (fun id ↦
        (id, originOf world (Composition.run cfg boundaries world steps).events id)) := rfl

theorem auditRun_current (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (world : World P A D) (steps : List (Step P A D)) (request : OriginRequest P A D) :
    (auditRun cfg boundaries world steps request).current =
      currentAuthorityOrigin world (Composition.run cfg boundaries world steps)
        request.ctx request.operation request.right request.authorityIds := rfl

end DefiKernel.CapabilityProvenance
