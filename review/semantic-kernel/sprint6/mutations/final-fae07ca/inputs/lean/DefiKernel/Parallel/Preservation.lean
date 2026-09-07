import DefiKernel.Parallel.Commutation
import DefiKernel.Composition.Preservation

/-! Joined accounting, point-of-use authority in the fixed input store, and supported ledger
invariants. Nonnegativity is proof-carrying; initialization and local preservation are premises. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Net supply from both actual successful branch receipt sequences, including refused prefixes. -/
def Joined.supply (joined : Joined P A D) (domain : D) (asset : A) : ℚ :=
  traceSupply joined.left.events domain asset + traceSupply joined.right.events domain asset

-- BEGIN PROOFS

theorem mergeWorld_balance_sum (lf rf : Footprint P A D) (initial left right : World P A D)
    (hd : ∀ c ∈ lf.writes, c ∉ rf.writes)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (c : Cell P A D) :
    (mergeWorld lf rf initial left right).state.balance c =
      left.state.balance c + right.state.balance c - initial.state.balance c := by
  by_cases hcl : c ∈ lf.writes
  · simp [mergeWorld, hcl, hr c (hd c hcl)]
  · by_cases hcr : c ∈ rf.writes
    · simp [mergeWorld, hcl, hcr, hl c hcl]
    · simp [mergeWorld, hcl, hcr, hl c hcl, hr c hcr]

theorem mergeWorld_accounting (lf rf : Footprint P A D) (initial left right : World P A D)
    (hd : ∀ c ∈ lf.writes, c ∉ rf.writes)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (d : D) (a : A) :
    total (mergeWorld lf rf initial left right).state d a =
      total left.state d a + total right.state d a - total initial.state d a := by
  simp only [total, mergeWorld_balance_sum lf rf initial left right hd hl hr,
    Finset.sum_sub_distrib, Finset.sum_add_distrib]

theorem runBranch_accounting (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (d : D) (a : A) :
    total (runBranch cfg boundary initial branch).world.state d a =
      total initial.state d a + traceSupply (runBranch cfg boundary initial branch).events d a :=
  run_accounting cfg boundary initial (branch.map Step.invoke) d a

/-- Actual successful receipt supplies from both independent runs determine joined accounting. -/
theorem runParallel_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf)) (d : D) (a : A) :
    total (mergeWorld lf rf initial
      (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state d a =
      total initial.state d a +
        traceSupply (runBranch cfg (boundaries .left) initial left).events d a +
        traceSupply (runBranch cfg (boundaries .right) initial right).events d a := by
  obtain ⟨hv, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf hadmit
  rw [mergeWorld_accounting lf rf initial _ _ hc.1
    (runBranch_frame cfg (boundaries .left) initial left lf hl).1
    (runBranch_frame cfg (boundaries .right) initial right rf hr).1]
  rw [runBranch_accounting, runBranch_accounting]
  linarith

theorem runBranch_events_invoke (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ∃ inv ∈ branch, event.step = .invoke inv := by
  obtain ⟨accepted, remaining, hs, he⟩ :=
    run_order cfg boundary initial (branch.map Step.invoke)
  intro event hm
  have hstep : event.step ∈ accepted := he ▸ List.mem_map.mpr ⟨event, hm, rfl⟩
  have hall : event.step ∈ branch.map Step.invoke := by
    rw [hs]
    exact List.mem_append_left _ hstep
  obtain ⟨inv, hi, hh⟩ := List.mem_map.mp hall
  exact ⟨inv, hi, hh.symm⟩

theorem trace_invoke_stores {cfg : Config P A D} {boundary : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundary initial events final history index)
    (hi : ∀ event ∈ events, ∃ inv, event.step = .invoke inv) :
    final.capabilities = initial.capabilities ∧
      ∀ event ∈ events, event.before.capabilities = initial.capabilities ∧
        event.result.world.capabilities = initial.capabilities := by
  induction h with
  | nil => exact ⟨rfl, by simp⟩
  | @snoc events pre history index previous step result sound ih =>
    obtain ⟨hp, he⟩ := ih (by
      intro event hm
      exact hi event (List.mem_append_left _ hm))
    obtain ⟨inv, hstep⟩ := hi ⟨index, step, pre, result⟩ (by simp)
    change step = .invoke inv at hstep
    have hcap : result.world.capabilities = pre.capabilities := by
      rw [hstep] at sound
      exact sound.invoke_preserves_capabilities
    refine ⟨hcap.trans hp, ?_⟩
    intro event hm
    rcases List.mem_append.mp hm with hm | hm
    · exact he event hm
    · have eq := List.mem_singleton.mp hm
      subst event
      exact ⟨hp, hcap.trans hp⟩

/-- Every successful invocation uses authority from the initial fixed store, including prefixes
whose later invocation refuses. The actual local boundary remains attached to each event. -/
theorem runBranch_authority (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ReceiptAuthorized initial (boundary event.index) event.result.receipt := by
  have ht := run_trace_sound cfg boundary initial (branch.map Step.invoke)
  have hi : ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ∃ inv, event.step = .invoke inv := by
    intro event hm
    obtain ⟨inv, _, he⟩ := runBranch_events_invoke cfg boundary initial branch event hm
    exact ⟨inv, he⟩
  have hs := trace_invoke_stores ht hi
  intro event hm
  have ha := ht.authority event hm
  have hc := (hs.2 event hm).1
  cases hr : event.result.receipt <;> simp only [hr, ReceiptAuthorized] at ha ⊢
  simpa only [hc] using ha

theorem runBranch_prefix_nonnegative (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events, ∀ c,
      0 ≤ event.before.state.balance c ∧ 0 ≤ event.result.world.state.balance c :=
  run_prefix_nonnegative cfg boundary initial (branch.map Step.invoke)

/-- The join frames every predicate whose explicit support avoids both write regions. -/
theorem mergeWorld_supported_frame (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (predicate : State P A D → Prop) (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ∧ c ∉ rf.writes) :
    predicate initial.state ↔ predicate (mergeWorld lf rf initial left right).state := by
  apply supported_frame support
  intro c hc
  exact (mergeWorld_outside lf rf initial left right c
    (untouched c hc).1 (untouched c hc).2).symm

theorem mergeWorld_agrees_left (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (locality : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (peer : ∀ c ∈ region, c ∉ rf.writes) :
    AgreeOn region left.state (mergeWorld lf rf initial left right).state := by
  intro c hc
  by_cases hw : c ∈ lf.writes
  · simp [mergeWorld, hw]
  · simp [mergeWorld, hw, peer c hc, locality c hw]

theorem mergeWorld_agrees_right (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (locality : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (peer : ∀ c ∈ region, c ∉ lf.writes) :
    AgreeOn region right.state (mergeWorld lf rf initial left right).state := by
  intro c hc
  by_cases hw : c ∈ rf.writes
  · simp [mergeWorld, hw, peer c hc]
  · simp [mergeWorld, hw, peer c hc, locality c hw]

theorem mergeWorld_two_invariants (lf rf : Footprint P A D)
    (initial left right : World P A D) (ls rs : Set (Cell P A D))
    (lp rp : State P A D → Prop) (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp left.state) (ri : rp right.state) :
    lp (mergeWorld lf rf initial left right).state ∧
      rp (mergeWorld lf rf initial left right).state :=
  ⟨(supported_frame lSupport (mergeWorld_agrees_left lf rf initial left right ls hl lpeer)).mp li,
    (supported_frame rSupport (mergeWorld_agrees_right lf rf initial left right rs hr rpeer)).mp ri⟩

/-- Non-circular initialized induction obligations for a branch's own ledger predicate. -/
def LocalPreservation (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (predicate : State P A D → Prop) : Prop :=
  ∀ n outputs step pre result, StepSound cfg (boundary n) n outputs step pre result →
    predicate pre.state → predicate result.world.state

theorem runBranch_invariant (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (predicate : State P A D → Prop)
    (initialized : predicate initial.state) (preserves : LocalPreservation cfg boundary predicate) :
    predicate (runBranch cfg boundary initial branch).world.state :=
  (run_trace_sound cfg boundary initial (branch.map Step.invoke)).invariant
    (fun w ↦ predicate w.state) initialized preserves

theorem evaluated_supplies_empty (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (hn : template.supplyDeltas = []) (he : template.evaluate ctx = .ok e) :
    e.supplies = [] := by
  unfold Template.evaluate at he
  rw [hn] at he
  simp only [List.mapM_nil, bind, Except.bind, pure, Except.pure] at he
  repeat' first | split at he | contradiction
  cases he
  rfl

theorem extractReceipt_supplies_empty (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D) (e : Evaluated P A D)
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (he : extractReceipt cfg boundary request pre = .ok e) : e.supplies = [] := by
  unfold extractReceipt at he
  cases hs : cfg.registry request.operation with
  | none => simp [hs, bind, Except.bind] at he
  | some template =>
    simp only [hs, bind, Except.bind] at he
    cases ha : Args.check template.signature request.arguments with
    | error reason => simp [ha, Except.mapError] at he
    | ok args =>
      simp only [ha, Except.mapError, bind, Except.bind] at he
      cases hv : template.evaluate
          ⟨pre.state, boundary.env, boundary.ctx.principal, request.parties, args, boundary.now⟩
          <;> simp only [hv, Except.mapError] at he
      · contradiction
      · cases he
        exact evaluated_supplies_empty template _ _ (hn _ _ hs) hv

theorem step_no_supply {cfg : Config P A D} {boundary : Boundary P A D}
    {n : Nat} {outputs : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (hs : StepSound cfg boundary n outputs step pre result) (d : D) (a : A) :
    result.receipt.supply d a = 0 := by
  cases hs with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have he := extractReceipt_supplies_empty cfg boundary request pre e hn extracted
    simp [Receipt.supply, Evaluated.supply, he]
  | issue => rfl
  | revoke => rfl

theorem local_total_preservation (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (d : D) (a : A) (amount : ℚ) :
    LocalPreservation cfg boundary (fun s ↦ total s d a = amount) := by
  intro n outputs step pre result hs hi
  rw [hs.accounting d a, step_no_supply hn hs d a, add_zero]
  exact hi

theorem supports_total (d : D) (a : A) (predicate : ℚ → Prop) :
    Supports {c : Cell P A D | c.1 = d ∧ c.2.2 = a}
      (fun s ↦ predicate (total s d a)) := by
  intro pre post h
  have ht : total pre d a = total post d a := by
    apply Finset.sum_congr rfl
    intro party hp
    exact h (d, party, a) ⟨rfl, rfl⟩
  change predicate (total pre d a) ↔ predicate (total post d a)
  rw [ht]

/-- Both branch invariants are initialized and preserved individually before supported join. -/
theorem runParallel_two_invariants (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (ls rs : Set (Cell P A D)) (lp rp : State P A D → Prop)
    (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp initial.state) (ri : rp initial.state)
    (lPreserves : LocalPreservation cfg (boundaries .left) lp)
    (rPreserves : LocalPreservation cfg (boundaries .right) rp) :
    lp (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state ∧
    rp (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state := by
  obtain ⟨_, hl, hr, _⟩ := admit_ok cfg boundaries left right lf rf hadmit
  exact mergeWorld_two_invariants lf rf initial _ _ ls rs lp rp lSupport rSupport
    (runBranch_frame cfg (boundaries .left) initial left lf hl).1
    (runBranch_frame cfg (boundaries .right) initial right rf hr).1 lpeer rpeer
    (runBranch_invariant cfg (boundaries .left) initial left lp li lPreserves)
    (runBranch_invariant cfg (boundaries .right) initial right rp ri rPreserves)

/-- Accounting binds the public executed result to both of its actual receipt sequences. -/
theorem runParallel_executed_accounting (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) (d : D) (a : A) :
    total joined.world.state d a = total initial.state d a + joined.supply d a := by
  cases hadmit : admit cfg boundaries left right with
  | error reason => simp [runParallel, hadmit] at hx
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    simp only [runParallel, hadmit, Result.executed.injEq] at hx
    subst joined
    simpa only [Joined.supply, add_assoc] using
      runParallel_accounting cfg boundaries initial left right lf rf hadmit d a

theorem runParallel_executed_authority (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ event ∈ joined.left.events,
      ReceiptAuthorized initial (boundaries .left event.index) event.result.receipt) ∧
    (∀ event ∈ joined.right.events,
      ReceiptAuthorized initial (boundaries .right event.index) event.result.receipt) := by
  cases hadmit : admit cfg boundaries left right with
  | error reason => simp [runParallel, hadmit] at hx
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    simp only [runParallel, hadmit, Result.executed.injEq] at hx
    subst joined
    exact ⟨runBranch_authority cfg (boundaries .left) initial left,
      runBranch_authority cfg (boundaries .right) initial right⟩

theorem runParallel_executed_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ c, c ∉ lf.writes → c ∉ rf.writes →
      joined.world.state.balance c = initial.state.balance c) ∧
      joined.world.capabilities = initial.capabilities := by
  simp only [runParallel, hadmit, Result.executed.injEq] at hx
  subst joined
  exact ⟨mergeWorld_outside lf rf initial _ _, rfl⟩

theorem runParallel_executed_nonnegative (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ c, 0 ≤ joined.world.state.balance c) ∧
    (∀ event ∈ joined.left.events ++ joined.right.events, ∀ c,
      0 ≤ event.before.state.balance c ∧ 0 ≤ event.result.world.state.balance c) := by
  exact ⟨joined.world.state.nonneg,
    fun event _ c ↦ ⟨event.before.state.nonneg c, event.result.world.state.nonneg c⟩⟩

theorem runParallel_executed_supported_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ∧ c ∉ rf.writes) :
    predicate initial.state ↔ predicate joined.world.state := by
  apply supported_frame support
  intro c hc
  exact ((runParallel_executed_frame cfg boundaries initial left right lf rf joined hadmit hx).1
    c (untouched c hc).1 (untouched c hc).2).symm

theorem runParallel_executed_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined)
    (ls rs : Set (Cell P A D)) (lp rp : State P A D → Prop)
    (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp initial.state) (ri : rp initial.state)
    (lPreserves : LocalPreservation cfg (boundaries .left) lp)
    (rPreserves : LocalPreservation cfg (boundaries .right) rp) :
    lp joined.world.state ∧ rp joined.world.state := by
  simp only [runParallel, hadmit, Result.executed.injEq] at hx
  subst joined
  exact runParallel_two_invariants cfg boundaries initial left right lf rf hadmit
    ls rs lp rp lSupport rSupport lpeer rpeer li ri lPreserves rPreserves

end DefiKernel.Parallel
