import DefiKernel.CapabilityProvenance.Observation
import DefiKernel.Composition.Preservation

/-! OriginAt and lifetime/current-use/refusal facts over initialized `TraceSound`.
These theorems use the existing execution relation; they do not introduce a second
executor or a final-state legitimacy premise. -/
namespace DefiKernel.CapabilityProvenance

open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def eventIssueCount (event : Event P A D) : Nat :=
  match event.step with
  | .issue _ => 1
  | _ => 0

def issueCount (events : List (Event P A D)) : Nat :=
  (events.map eventIssueCount).sum

/-- Origin extracted from an initialized prefix: trusted initial grant, or an actual
preceding successful issue equation. Event membership without that equation is not
an origin certificate. -/
def OriginAt (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (trusted : TrustedRoot P A D) (initial : World P A D)
    (events : List (Event P A D)) (id : CapabilityId) : Origin P A D → Prop
  | .initial grant =>
    ∃ cap, initial.capabilities.lookup id = some cap ∧
      cap.toGrant = grant ∧ trusted id grant
  | .issued eventIndex grant =>
    ∃ event, event ∈ events ∧ event.index = eventIndex ∧
      event.step = .issue grant ∧ event.result.receipt = .issued id ∧
      issueCapability cfg.authority (boundaries event.index).ctx
        event.before.capabilities grant =
          .ok (id, event.result.world.capabilities)

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false

theorem lookup_lt {store : CapabilityStore P A D} {id : CapabilityId}
    {cap : Capability P A D} (h : store.lookup id = some cap) :
    id.value < store.entries.length :=
  (List.getElem?_eq_some_iff.mp h).1

theorem issueCount_nil : issueCount ([] : List (Event P A D)) = 0 := rfl

theorem issueCount_append (xs ys : List (Event P A D)) :
    issueCount (xs ++ ys) = issueCount xs + issueCount ys := by
  simp [issueCount, List.map_append, List.sum_append]

theorem issueCount_singleton_invoke (event : Event P A D) (inv : Invocation P A D)
    (h : event.step = .invoke inv) : issueCount [event] = 0 := by
  simp [issueCount, eventIssueCount, h]

theorem issueCount_singleton_issue (event : Event P A D) (grant : Grant P A D)
    (h : event.step = .issue grant) : issueCount [event] = 1 := by
  simp [issueCount, eventIssueCount, h]

theorem issueCount_singleton_revoke (event : Event P A D) (id : CapabilityId)
    (h : event.step = .revoke id) : issueCount [event] = 0 := by
  simp [issueCount, eventIssueCount, h]

theorem originAt_append (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (trusted : TrustedRoot P A D) (initial : World P A D)
    (events more : List (Event P A D)) (id : CapabilityId) (origin : Origin P A D)
    (h : OriginAt cfg boundaries trusted initial events id origin) :
    OriginAt cfg boundaries trusted initial (events ++ more) id origin := by
  cases origin with
  | initial grant => exact h
  | issued eventIndex grant =>
    obtain ⟨event, mem, hi, hs, hr, heq⟩ := h
    exact ⟨event, List.mem_append.mpr (Or.inl mem), hi, hs, hr, heq⟩

theorem stepSound_issue_equation {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {grant : Grant P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.issue grant) pre result) :
    ∃ id store,
      result.receipt = .issued id ∧ result.outputs = [] ∧
      result.world.state = pre.state ∧ result.world.capabilities = store ∧
      issueCapability cfg.authority boundary.ctx pre.capabilities grant = .ok (id, store) := by
  cases h with
  | issue grant pre id store hi =>
    exact ⟨id, store, rfl, rfl, rfl, rfl, hi⟩

theorem stepSound_revoke_equation {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {id : CapabilityId}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.revoke id) pre result) :
    ∃ store,
      result.receipt = .revoked id ∧ result.outputs = [] ∧
      result.world.state = pre.state ∧ result.world.capabilities = store ∧
      revokeCapability cfg.authority boundary.ctx pre.capabilities id = .ok store := by
  cases h with
  | revoke id pre store hr =>
    exact ⟨store, rfl, rfl, rfl, rfl, hr⟩

theorem stepSound_length {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history step pre result) :
    result.world.capabilities.entries.length =
      pre.capabilities.entries.length + eventIssueCount ⟨index, step, pre, result⟩ := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    have hs := execute_preserves_capabilities _ _ _ _ _ _ _ _ hx
    simp [eventIssueCount, hs]
  | issue grant pre id store hi =>
    obtain ⟨_, _, _, rfl, rfl⟩ := (issueCapability_ok_iff ..).mp hi
    simp [eventIssueCount, CapabilityStore.nextId]
  | revoke id pre store hr =>
    obtain ⟨_, _, _, rfl⟩ := (revokeCapability_ok_iff ..).mp hr
    simp [eventIssueCount, CapabilityStore.nextId, List.length_set]

theorem stepSound_preserves_allocated {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history step pre result)
    (id : CapabilityId) (cap : Capability P A D)
    (hlook : pre.capabilities.lookup id = some cap) :
    ∃ cap', result.world.capabilities.lookup id = some cap' ∧
      cap'.toGrant = cap.toGrant := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    have hs := execute_preserves_capabilities _ _ _ _ _ _ _ _ hx
    exact ⟨cap, by simp [hs, hlook], rfl⟩
  | issue grant pre nid store hi =>
    have hne := issueCapability_ne_existing _ _ _ _ _ _ _ _ hi hlook
    have hp := issueCapability_preserves_other _ _ _ _ _ id _ hi hne.symm
    exact ⟨cap, by simp [hp, hlook], rfl⟩
  | revoke rid pre store hr =>
    by_cases heq : id = rid
    · subst heq
      obtain ⟨cap', hc, ht, _⟩ := revokeCapability_tombstone _ _ _ _ _ hr
      rw [hlook] at hc
      cases hc
      exact ⟨{ cap with live := false }, ht, rfl⟩
    · have hp := revokeCapability_preserves_other _ _ _ rid id store hr heq
      exact ⟨cap, by simp [hp, hlook], rfl⟩

theorem stepSound_preserves_dead {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history step pre result)
    (id : CapabilityId) (cap : Capability P A D)
    (hlook : pre.capabilities.lookup id = some cap) (hdead : cap.live = false) :
    ∃ cap', result.world.capabilities.lookup id = some cap' ∧
      cap'.live = false ∧ cap'.toGrant = cap.toGrant := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    have hs := execute_preserves_capabilities _ _ _ _ _ _ _ _ hx
    exact ⟨cap, by simp [hs, hlook], hdead, rfl⟩
  | issue grant pre nid store hi =>
    have hne := issueCapability_ne_existing _ _ _ _ _ _ _ _ hi hlook
    have hp := issueCapability_preserves_other _ _ _ _ _ id _ hi hne.symm
    exact ⟨cap, by simp [hp, hlook], hdead, rfl⟩
  | revoke rid pre store hr =>
    by_cases heq : id = rid
    · subst heq
      obtain ⟨cap', hc, ht, _⟩ := revokeCapability_tombstone _ _ _ _ _ hr
      rw [hlook] at hc
      cases hc
      exact ⟨{ cap with live := false }, ht, rfl, rfl⟩
    · have hp := revokeCapability_preserves_other _ _ _ rid id store hr heq
      exact ⟨cap, by simp [hp, hlook], hdead, rfl⟩

theorem traceBefore {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (event : Event P A D) (mem : event ∈ events) :
    ∃ front hist suffix,
      events = front ++ event :: suffix ∧
      TraceSound cfg boundaries initial front event.before hist event.index := by
  induction h with
  | nil => cases mem
  | @snoc evs pre hist idx previous step result accepted ih =>
    simp only [List.mem_append, List.mem_singleton] at mem
    rcases mem with mem | rfl
    · obtain ⟨front, hist', suffix, heq, hpre⟩ := ih mem
      refine ⟨front, hist', suffix ++ [⟨idx, step, pre, result⟩], ?_, hpre⟩
      simp [heq]
    · exact ⟨evs, hist, [], by simp, previous⟩

theorem trace_allocation_count {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    final.capabilities.entries.length =
      initial.capabilities.entries.length + issueCount events := by
  induction h with
  | nil => simp [issueCount]
  | snoc previous step result accepted ih =>
    rw [stepSound_length accepted, ih, issueCount_append]
    cases step with
    | invoke inv => simp [issueCount, eventIssueCount]
    | issue grant => simp [issueCount, eventIssueCount, Nat.add_assoc]
    | revoke id => simp [issueCount, eventIssueCount]

theorem trace_persistent_grant {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (id : CapabilityId) (cap : Capability P A D)
    (hlook : initial.capabilities.lookup id = some cap) :
    ∃ cap', final.capabilities.lookup id = some cap' ∧ cap'.toGrant = cap.toGrant := by
  induction h with
  | nil => exact ⟨cap, hlook, rfl⟩
  | snoc previous step result accepted ih =>
    obtain ⟨cap', hc, hg⟩ := ih
    obtain ⟨cap'', hc'', hg''⟩ := stepSound_preserves_allocated accepted id cap' hc
    exact ⟨cap'', hc'', hg''.trans hg⟩

theorem trace_dead_stays_dead {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (id : CapabilityId) (cap : Capability P A D)
    (hlook : initial.capabilities.lookup id = some cap) (hdead : cap.live = false) :
    ∃ cap', final.capabilities.lookup id = some cap' ∧ cap'.live = false ∧
      cap'.toGrant = cap.toGrant := by
  induction h with
  | nil => exact ⟨cap, hlook, hdead, rfl⟩
  | snoc previous step result accepted ih =>
    obtain ⟨cap', hc, hd, hg⟩ := ih
    obtain ⟨cap'', hc'', hd'', hg''⟩ := stepSound_preserves_dead accepted id cap' hc hd
    exact ⟨cap'', hc'', hd'', hg''.trans hg⟩

theorem trace_before_length_ge {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (event : Event P A D) (mem : event ∈ events) :
    initial.capabilities.entries.length ≤
      event.before.capabilities.entries.length := by
  obtain ⟨front, hist, suffix, _, hpre⟩ := traceBefore h event mem
  have hc := trace_allocation_count hpre
  rw [hc]
  exact Nat.le_add_right _ _

theorem issued_event_equation {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (event : Event P A D) (mem : event ∈ events) (grant : Grant P A D)
    (id : CapabilityId) (hs : event.step = .issue grant)
    (hr : event.result.receipt = .issued id) :
    issueCapability cfg.authority (boundaries event.index).ctx
      event.before.capabilities grant =
        .ok (id, event.result.world.capabilities) := by
  obtain ⟨prior, accepted⟩ := Composition.TraceSound.steps h event mem
  have hacc : StepSound cfg (boundaries event.index) event.index prior
      (.issue grant) event.before event.result := hs ▸ accepted
  obtain ⟨id', store, hrec, _, _, hstore, hi⟩ := stepSound_issue_equation hacc
  rw [hr] at hrec
  cases hrec
  simpa [hstore] using hi

theorem originAt_complete {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {trusted : TrustedRoot P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (trace : TraceSound cfg boundaries initial events final history index)
    (roots : RootsAccepted trusted initial.capabilities)
    (id : CapabilityId) (cap : Capability P A D)
    (hlook : final.capabilities.lookup id = some cap) :
    ∃ origin, OriginAt cfg boundaries trusted initial events id origin ∧
      origin.grant = cap.toGrant := by
  induction trace generalizing id cap with
  | nil =>
    exact ⟨.initial cap.toGrant, ⟨cap, hlook, rfl, roots id cap hlook⟩, rfl⟩
  | @snoc evs pre hist idx previous step result accepted ih =>
    cases accepted with
    | invoke inv preW post iface request e hp hx he ha =>
      have hs := execute_preserves_capabilities _ _ _ _ _ _ _ _ hx
      have hpre : pre.capabilities.lookup id = some cap := by
        simpa [hs] using hlook
      obtain ⟨origin, ho, hg⟩ := ih id cap hpre
      exact ⟨origin, originAt_append _ _ _ _ _ _ id origin ho, hg⟩
    | issue grant preW nid store hi =>
      by_cases heq : id = nid
      · subst heq
        have hf := (issueCapability_fresh _ _ _ _ _ _ hi).2.1
        have hgrant : cap.toGrant = grant := by
          rw [hf] at hlook
          cases hlook
          rfl
        refine ⟨.issued idx grant, ?_, hgrant.symm⟩
        refine ⟨⟨idx, .issue grant, pre,
          ⟨⟨pre.state, store⟩, .issued id, []⟩⟩, by simp, rfl, rfl, rfl, ?_⟩
        simpa using hi
      · have hp := issueCapability_preserves_other _ _ _ _ _ id _ hi heq
        have hpre : pre.capabilities.lookup id = some cap := by
          simpa [hp] using hlook
        obtain ⟨origin, ho, hg⟩ := ih id cap hpre
        exact ⟨origin, originAt_append _ _ _ _ _ _ id origin ho, hg⟩
    | revoke rid preW store hr =>
      by_cases heq : id = rid
      · subst heq
        obtain ⟨cap0, hpreLook, hpost, _⟩ := revokeCapability_tombstone _ _ _ _ _ hr
        obtain ⟨origin, ho, hg⟩ := ih id cap0 hpreLook
        refine ⟨origin, originAt_append _ _ _ _ _ _ id origin ho, ?_⟩
        rw [hpost] at hlook
        cases hlook
        exact hg
      · have hp := revokeCapability_preserves_other _ _ _ rid id store hr heq
        have hpre : pre.capabilities.lookup id = some cap := by
          simpa [hp] using hlook
        obtain ⟨origin, ho, hg⟩ := ih id cap hpre
        exact ⟨origin, originAt_append _ _ _ _ _ _ id origin ho, hg⟩

theorem trace_index_lt {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (event : Event P A D) (mem : event ∈ events) : event.index < index := by
  induction h with
  | nil => cases mem
  | snoc previous step result accepted ih =>
    simp only [List.mem_append, List.mem_singleton] at mem
    rcases mem with mem | rfl
    · exact Nat.lt_trans (ih mem) (Nat.lt_succ_self _)
    · exact Nat.lt_succ_self _

theorem trace_unique_index {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (e1 e2 : Event P A D) (m1 : e1 ∈ events) (m2 : e2 ∈ events)
    (hi : e1.index = e2.index) : e1 = e2 := by
  revert m1 m2 hi
  induction h with
  | nil =>
    intro m1 m2 hi
    cases m1
  | snoc previous step result accepted ih =>
    intro m1 m2 hi
    simp only [List.mem_append, List.mem_singleton] at m1 m2
    rcases m1 with m1 | rfl
    · rcases m2 with m2 | rfl
      · exact ih m1 m2 hi
      · have := trace_index_lt previous e1 m1
        exact (Nat.ne_of_lt this hi).elim
    · rcases m2 with m2 | rfl
      · have := trace_index_lt previous e2 m2
        exact (Nat.ne_of_lt this hi.symm).elim
      · rfl

theorem trace_event_result_le_final {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (event : Event P A D) (mem : event ∈ events) :
    event.result.world.capabilities.entries.length ≤
      final.capabilities.entries.length := by
  induction h with
  | nil => cases mem
  | snoc previous step result accepted ih =>
    simp only [List.mem_append, List.mem_singleton] at mem
    rcases mem with mem | rfl
    · have hle := ih mem
      have hlen := stepSound_length accepted
      omega
    · exact Nat.le_refl _

theorem trace_later_before_ge_after {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (e1 e2 : Event P A D) (m1 : e1 ∈ events) (m2 : e2 ∈ events)
    (hlt : e1.index < e2.index) :
    e1.result.world.capabilities.entries.length ≤
      e2.before.capabilities.entries.length := by
  revert m1 m2 hlt
  induction h with
  | nil =>
    intro m1 m2 hlt
    cases m1
  | snoc previous step result accepted ih =>
    intro m1 m2 hlt
    simp only [List.mem_append, List.mem_singleton] at m1 m2
    rcases m1 with m1 | rfl
    · rcases m2 with m2 | rfl
      · exact ih m1 m2 hlt
      · exact trace_event_result_le_final previous e1 m1
    · rcases m2 with m2 | rfl
      · have hlt' := trace_index_lt previous e2 m2
        exact absurd hlt' (Nat.lt_asymm hlt)
      · exact (Nat.lt_irrefl _ hlt).elim

theorem originAt_issued_nextId {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {trusted : TrustedRoot P A D} {initial : World P A D}
    {events : List (Event P A D)} {id : CapabilityId} {idx : Nat}
    {grant : Grant P A D}
    (h : OriginAt cfg boundaries trusted initial events id (.issued idx grant)) :
    ∃ event, event ∈ events ∧ event.index = idx ∧ event.step = .issue grant ∧
      event.result.receipt = .issued id ∧
      id = event.before.capabilities.nextId := by
  obtain ⟨event, mem, hi, hs, hr, heq⟩ := h
  obtain ⟨_, _, _, hid, _⟩ := (issueCapability_ok_iff ..).mp heq
  exact ⟨event, mem, hi, hs, hr, hid⟩

theorem originAt_unique {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {trusted : TrustedRoot P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (trace : TraceSound cfg boundaries initial events final history index)
    (roots : RootsAccepted trusted initial.capabilities)
    (id : CapabilityId) (o1 o2 : Origin P A D)
    (h1 : OriginAt cfg boundaries trusted initial events id o1)
    (h2 : OriginAt cfg boundaries trusted initial events id o2) : o1 = o2 := by
  cases o1 with
  | initial g1 =>
    cases o2 with
    | initial g2 =>
      obtain ⟨c1, l1, e1, _⟩ := h1
      obtain ⟨c2, l2, e2, _⟩ := h2
      rw [l1] at l2
      cases l2
      cases e1
      cases e2
      rfl
    | issued idx g2 =>
      obtain ⟨c1, l1, _, _⟩ := h1
      obtain ⟨event, mem, _, _, _, heq⟩ := h2
      obtain ⟨_, _, _, hid, _⟩ := (issueCapability_ok_iff ..).mp heq
      have hlt := lookup_lt l1
      have hge := trace_before_length_ge trace event mem
      have hv : id.value = event.before.capabilities.entries.length := by
        simp [hid, CapabilityStore.nextId]
      exact (Nat.lt_irrefl _ (hlt.trans_le (hge.trans (le_of_eq hv.symm)))).elim
  | issued idx1 g1 =>
    cases o2 with
    | initial g2 =>
      obtain ⟨c2, l2, _, _⟩ := h2
      obtain ⟨event, mem, _, _, _, heq⟩ := h1
      obtain ⟨_, _, _, hid, _⟩ := (issueCapability_ok_iff ..).mp heq
      have hlt := lookup_lt l2
      have hge := trace_before_length_ge trace event mem
      have hv : id.value = event.before.capabilities.entries.length := by
        simp [hid, CapabilityStore.nextId]
      exact (Nat.lt_irrefl _ (hlt.trans_le (hge.trans (le_of_eq hv.symm)))).elim
    | issued idx2 g2 =>
      obtain ⟨e1, m1, i1, s1, r1, q1⟩ := h1
      obtain ⟨e2, m2, i2, s2, r2, q2⟩ := h2
      obtain ⟨_, _, _, hid1, _⟩ := (issueCapability_ok_iff ..).mp q1
      obtain ⟨_, _, _, hid2, _⟩ := (issueCapability_ok_iff ..).mp q2
      rcases lt_trichotomy e1.index e2.index with hlt | heq | hgt
      · have hge := trace_later_before_ge_after trace e1 e2 m1 m2 hlt
        have hf := (issueCapability_fresh _ _ _ _ _ _ q1).2.2
        have hplus : e1.result.world.capabilities.entries.length =
            e1.before.capabilities.entries.length + 1 := by
          simpa [CapabilityStore.nextId] using hf
        have : e1.before.capabilities.entries.length <
            e2.before.capabilities.entries.length := by omega
        have hlen : e1.before.capabilities.entries.length =
            e2.before.capabilities.entries.length := by
          have hids : e1.before.capabilities.nextId = e2.before.capabilities.nextId :=
            hid1.symm.trans hid2
          simp [CapabilityStore.nextId] at hids
          exact hids
        exact (Nat.lt_irrefl _ (this.trans_eq hlen.symm)).elim
      · have hev := trace_unique_index trace e1 e2 m1 m2 heq
        subst hev
        have hg : g1 = g2 := by
          rw [s1] at s2
          injection s2
        have hidx : idx1 = idx2 := i1.symm.trans i2
        cases hg
        cases hidx
        rfl
      · have hge := trace_later_before_ge_after trace e2 e1 m2 m1 hgt
        have hf := (issueCapability_fresh _ _ _ _ _ _ q2).2.2
        have hplus : e2.result.world.capabilities.entries.length =
            e2.before.capabilities.entries.length + 1 := by
          simpa [CapabilityStore.nextId] using hf
        have : e2.before.capabilities.entries.length <
            e1.before.capabilities.entries.length := by omega
        have hlen : e1.before.capabilities.entries.length =
            e2.before.capabilities.entries.length := by
          have hids : e1.before.capabilities.nextId = e2.before.capabilities.nextId :=
            hid1.symm.trans hid2
          simp [CapabilityStore.nextId] at hids
          exact hids
        exact (Nat.lt_irrefl _ (this.trans_eq hlen)).elim

theorem originOf_sound {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {trusted : TrustedRoot P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (trace : TraceSound cfg boundaries initial events final history index)
    (roots : RootsAccepted trusted initial.capabilities)
    (id : CapabilityId) (origin : Origin P A D)
    (h : originOf initial events id = some origin) :
    OriginAt cfg boundaries trusted initial events id origin := by
  cases hlook : initial.capabilities.lookup id with
  | some cap =>
    simp [originOf, hlook] at h
    cases h
    exact ⟨cap, hlook, rfl, roots id cap hlook⟩
  | none =>
    simp [originOf, hlook] at h
    obtain ⟨event, grant, mem, rfl, hs, hr⟩ := issuedOrigin_sound_raw events id origin h
    exact ⟨event, mem, rfl, hs, hr,
      issued_event_equation trace event mem grant id hs hr⟩

theorem hasAuthority_origin_witness {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {trusted : TrustedRoot P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (trace : TraceSound cfg boundaries initial events final history index)
    (roots : RootsAccepted trusted initial.capabilities)
    (ids : List CapabilityId) (ctx : InvocationContext P D)
    (operation : OperationId) (right : Right P A D)
    (hauth : hasAuthority final.capabilities ids ctx operation right = true) :
    ∃ id origin, id ∈ ids ∧
      authorizesId final.capabilities ctx operation right id = true ∧
      OriginAt cfg boundaries trusted initial events id origin := by
  obtain ⟨id, hid, ha⟩ := (hasAuthority_iff ..).mp hauth
  obtain ⟨cap, hlook, _⟩ := (authorizesId_iff ..).mp ha
  obtain ⟨origin, ho, _⟩ := originAt_complete trace roots id cap hlook
  exact ⟨id, origin, hid, ha, ho⟩

theorem accepted_invoke_current_authority {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {trusted : TrustedRoot P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (trace : TraceSound cfg boundaries initial events final history index)
    (roots : RootsAccepted trusted initial.capabilities)
    (event : Event P A D) (mem : event ∈ events) (inv : Invocation P A D)
    (request : Request P A D) (e : Evaluated P A D)
    (hs : event.step = .invoke inv)
    (hr : event.result.receipt = .invoked request e) :
    hasAuthority event.before.capabilities request.capabilityIds
      (boundaries event.index).ctx request.operation .invoke = true ∧
    (∀ c, e.effect c < 0 →
      hasAuthority event.before.capabilities request.capabilityIds
        (boundaries event.index).ctx request.operation (.debit c) = true) ∧
    (∀ d a, e.supply d a ≠ 0 →
      hasAuthority event.before.capabilities request.capabilityIds
        (boundaries event.index).ctx request.operation (.changeSupply d a) = true) ∧
    (∀ right, hasAuthority event.before.capabilities request.capabilityIds
        (boundaries event.index).ctx request.operation right = true →
      ∃ id origin, id ∈ request.capabilityIds ∧
        authorizesId event.before.capabilities (boundaries event.index).ctx
          request.operation right id = true ∧
        OriginAt cfg boundaries trusted initial events id origin) := by
  have hauth := Composition.TraceSound.authority trace event mem
  rw [hr] at hauth
  obtain ⟨front, hist, suffix, heq, hpre⟩ := traceBefore trace event mem
  refine ⟨hauth.1, hauth.2.1, hauth.2.2, ?_⟩
  intro right ha
  obtain ⟨id, origin, hid, hai, ho⟩ :=
    hasAuthority_origin_witness hpre roots request.capabilityIds
      (boundaries event.index).ctx request.operation right ha
  rw [heq]
  exact ⟨id, origin, hid, hai,
    originAt_append _ _ _ _ _ (event :: suffix) id origin ho⟩

theorem executeStep_issue_error {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {grant : Grant P A D}
    {pre : World P A D} {reason : AuthorityFailure}
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hi : issueCapability cfg.authority boundary.ctx pre.capabilities grant = .error reason) :
    executeStep cfg boundary index history (.issue grant) pre = .error (.authority reason) := by
  simp [executeStep, hv, hi, Except.mapError, bind, Except.bind]

theorem executeStep_revoke_error {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {id : CapabilityId}
    {pre : World P A D} {reason : AuthorityFailure}
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hr : revokeCapability cfg.authority boundary.ctx pre.capabilities id = .error reason) :
    executeStep cfg boundary index history (.revoke id) pre = .error (.authority reason) := by
  simp [executeStep, hv, hr, Except.mapError, bind, Except.bind]

theorem advance_rejected_prefix {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {cursor : Cursor P A D}
    {step : Step P A D} {reason : Failure}
    (hf : cursor.failure = none)
    (he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex
      cursor.outputs step cursor.world = .error reason) :
    (advance cfg boundaries cursor step).world = cursor.world ∧
    (advance cfg boundaries cursor step).events = cursor.events ∧
    (advance cfg boundaries cursor step).outputs = cursor.outputs ∧
    (advance cfg boundaries cursor step).nextIndex = cursor.nextIndex ∧
    (advance cfg boundaries cursor step).failure =
      some ⟨cursor.nextIndex, some step, reason⟩ := by
  simp [advance, hf, he]

theorem revoke_unknown_before_admin {config : AuthorityConfig P D}
    {ctx : InvocationContext P D} {store : CapabilityStore P A D}
    {id : CapabilityId} (h : store.lookup id = none) :
    revokeCapability config ctx store id = .error .unknownCapability := by
  simp [revokeCapability, h]

theorem issue_unauthorized_before_domains {config : AuthorityConfig P D}
    {ctx : InvocationContext P D} {store : CapabilityStore P A D}
    {grant : Grant P A D} (h : isDomainAdmin config ctx grant.domain = false) :
    issueCapability config ctx store grant = .error .unauthorizedAdmin := by
  simp [issueCapability, h]

theorem originOf_complete_initial {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {trusted : TrustedRoot P A D}
    {initial : World P A D} {events : List (Event P A D)} {id : CapabilityId}
    {grant : Grant P A D}
    (h : OriginAt cfg boundaries trusted initial events id (.initial grant)) :
    originOf initial events id = some (.initial grant) := by
  obtain ⟨cap, hlook, hg, _⟩ := h
  simp [originOf, hlook, hg]

theorem issuedOrigin_of_unique {events : List (Event P A D)} {id : CapabilityId}
    {event : Event P A D} {grant : Grant P A D}
    (hs : event.step = .issue grant)
    (hr : event.result.receipt = .issued id)
    (mem : event ∈ events)
    (unique : ∀ e ∈ events, e.result.receipt = .issued id → e = event) :
    issuedOrigin events id = some (.issued event.index grant) := by
  revert unique mem
  induction events with
  | nil =>
    intro mem unique
    cases mem
  | cons head rest ih =>
    intro mem unique
    simp only [List.mem_cons] at mem
    rcases mem with rfl | mem
    · simp [issuedOrigin, hs, hr]
    · match hs' : head.step, hr' : head.result.receipt with
      | .issue g, .issued other =>
        by_cases heq : other = id
        · subst heq
          have hhd := unique head (List.mem_cons.mpr (Or.inl rfl)) (by simp [hr'])
          subst hhd
          simp [issuedOrigin, hs, hr]
        · simp [issuedOrigin, hs', hr', heq]
          exact ih mem (fun e hm hrr ↦
            unique e (List.mem_cons.mpr (Or.inr hm)) hrr)
      | .issue g, .invoked request ev =>
        simp [issuedOrigin, hs', hr']
        exact ih mem (fun e hm hrr ↦ unique e (List.mem_cons.mpr (Or.inr hm)) hrr)
      | .issue g, .revoked rid =>
        simp [issuedOrigin, hs', hr']
        exact ih mem (fun e hm hrr ↦ unique e (List.mem_cons.mpr (Or.inr hm)) hrr)
      | .invoke inv, rec =>
        simp [issuedOrigin, hs']
        exact ih mem (fun e hm hrr ↦ unique e (List.mem_cons.mpr (Or.inr hm)) hrr)
      | .revoke rid, rec =>
        simp [issuedOrigin, hs']
        exact ih mem (fun e hm hrr ↦ unique e (List.mem_cons.mpr (Or.inr hm)) hrr)

end DefiKernel.CapabilityProvenance


