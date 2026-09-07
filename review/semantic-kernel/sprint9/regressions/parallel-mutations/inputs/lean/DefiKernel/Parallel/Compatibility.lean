import DefiKernel.Composition.Execution

/-! Conservative admission for invocation-only branches. Lists preserve deterministic witnesses. -/
namespace DefiKernel.Parallel
open Typed Composition

inductive BranchId where
  | left
  | right
  deriving DecidableEq, Repr
abbrev Branch (P A D : Type) := List (Invocation P A D)
abbrev ParallelBoundary (P A D : Type) := BranchId → Nat → Boundary P A D
structure Footprint (P A D : Type) where
  reads : List (Cell P A D)
  writes : List (Cell P A D)
  deriving DecidableEq, Repr
structure LocalFailure where
  index : Nat
  reason : Composition.Failure
  deriving DecidableEq, Repr
inductive ConflictKind where
  | writeWrite
  | leftWriteRightRead
  | rightWriteLeftRead
  deriving DecidableEq, Repr
inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : LocalFailure)
  | conflict (kind : ConflictKind) (cell : Cell P A D)
  deriving DecidableEq, Repr
variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
def Footprint.empty : Footprint P A D := ⟨[], []⟩
def Footprint.append (a b : Footprint P A D) : Footprint P A D :=
  ⟨a.reads ++ b.reads, a.writes ++ b.writes⟩
/-- Lookup, read resolution, write/target resolution, then access checks.
No financial values are evaluated. -/
def analyzeInvocation (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) : Except Composition.Failure (Footprint P A D) := do
  let (component, iface) ← match lookupOperation cfg.catalog inv.component inv.operation with
    | none => .error (.interface .unknownOperation)
    | some pair => .ok pair
  let template ← match cfg.registry inv.operation with
    | none => .error (.kernel .unknownOperation)
    | some template => .ok template
  let reads ← (resolveRefs boundary.ctx.principal inv.parties
    (template.requiredStateReads ++ template.stateReads)).mapError
      (fun e ↦ .interface (.resolution e))
  let writes ← (resolveRefs boundary.ctx.principal inv.parties
    (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))).mapError
      (fun e ↦ .interface (.resolution e))
  let _ ← (checkAccess component template boundary.ctx inv.parties).mapError .interface
  return ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩
/-- Structural analysis covers the entire suffix even when a financial prefix would refuse. -/
def analyzeBranchFrom (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) : Branch P A D → Except LocalFailure (Footprint P A D)
  | [] => .ok .empty
  | inv :: tail => do
    let head ← (analyzeInvocation cfg (boundary index) inv).mapError (⟨index, ·⟩)
    let rest ← analyzeBranchFrom cfg boundary (index + 1) tail
    return head.append rest
def analyzeBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) : Except LocalFailure (Footprint P A D) :=
  analyzeBranchFrom cfg boundary 0 branch
def firstOverlap (xs ys : List (Cell P A D)) : Option (Cell P A D) :=
  xs.find? (fun c ↦ decide (c ∈ ys))
def checkCompatibility (left right : Footprint P A D) :
    Except (AdmissionFailure P A D) PUnit :=
  match firstOverlap left.writes right.writes with
  | some c => .error (.conflict .writeWrite c)
  | none => match firstOverlap left.writes right.reads with
    | some c => .error (.conflict .leftWriteRightRead c)
    | none => match firstOverlap right.writes left.reads with
      | some c => .error (.conflict .rightWriteLeftRead c)
      | none => .ok ⟨⟩
def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) : Except (AdmissionFailure P A D)
      (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← checkCompatibility lf rf
  return (lf, rf)

-- BEGIN PROOFS

def Compatible (left right : Footprint P A D) : Prop :=
  (∀ c ∈ left.writes, c ∉ right.writes) ∧
  (∀ c ∈ left.writes, c ∉ right.reads) ∧
  (∀ c ∈ right.writes, c ∉ left.reads)
theorem firstOverlap_none_iff (xs ys : List (Cell P A D)) :
    firstOverlap xs ys = none ↔ ∀ c ∈ xs, c ∉ ys := by
  simp [firstOverlap, List.find?_eq_none]
theorem checkCompatibility_ok_iff (left right : Footprint P A D) :
    checkCompatibility left right = .ok PUnit.unit ↔ Compatible left right := by
  unfold Compatible
  simp only [← firstOverlap_none_iff]
  unfold checkCompatibility
  cases hww : firstOverlap left.writes right.writes <;>
    cases hlr : firstOverlap left.writes right.reads <;>
    cases hrl : firstOverlap right.writes left.reads <;>
    simp_all
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem compatible_symm {left right : Footprint P A D} (h : Compatible left right) :
    Compatible right left := by
  exact ⟨fun c hr hl ↦ h.1 c hl hr, h.2.2, h.2.1⟩
theorem analyzeInvocation_ok (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template reads writes,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.requiredStateReads ++ template.stateReads) = .ok reads ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) = .ok writes ∧
      checkAccess component template boundary.ctx inv.parties = .ok PUnit.unit ∧
      fp = ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩ := by
  unfold analyzeInvocation at h
  simp only [bind, Except.bind, Except.mapError, pure, Except.pure] at h
  split at h
  · contradiction
  rename_i pair hl
  rcases pair with ⟨component, iface⟩
  split at h
  · contradiction
  rename_i template ht
  split at h
  · contradiction
  rename_i reads hr
  split at h
  · contradiction
  rename_i writes hw
  split at h
  · contradiction
  rename_i token hc
  cases token
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨component, iface, template, reads, writes, hl, ht,
    unmap _ _ _ hr, unmap _ _ _ hw, unmap _ _ _ hc, (Except.ok.inj h).symm⟩
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_member (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) :
    ∃ cell ∈ cells, ref.2.resolve caller parties = .ok cell := by
  induction refs generalizing cells with
  | nil => simp at hr
  | cons head tail ih =>
    simp only [resolveRefs, List.mapM_cons, bind, Except.bind] at h
    cases hh : head.2.resolve caller parties with
    | error e => simp [hh] at h
    | ok cell =>
      cases ht : resolveRefs caller parties tail with
      | error e =>
        simp only [resolveRefs] at ht
        simp [hh, ht] at h
      | ok rest =>
        have htt := ht
        simp only [resolveRefs] at ht
        simp only [hh, ht, pure, Except.pure,
          Except.ok.injEq] at h
        subst cells
        rcases List.mem_cons.mp hr with he | hm
        · subst ref; exact ⟨cell, by simp, hh⟩
        · obtain ⟨c, hc, resolved⟩ := ih rest htt hm
          exact ⟨c, List.mem_cons_of_mem _ hc, resolved⟩
theorem analyzeBranchFrom_cons (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (inv : Invocation P A D) (tail : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index (inv :: tail) = .ok fp) :
    ∃ head rest, analyzeInvocation cfg (boundary index) inv = .ok head ∧
      analyzeBranchFrom cfg boundary (index + 1) tail = .ok rest ∧ fp = head.append rest := by
  unfold analyzeBranchFrom at h
  cases hh : analyzeInvocation cfg (boundary index) inv with
  | error e => simp [hh, Except.mapError, bind, Except.bind] at h
  | ok head =>
    cases ht : analyzeBranchFrom cfg boundary (index + 1) tail with
    | error e => simp [hh, ht, Except.mapError, bind, Except.bind] at h
    | ok rest =>
      simp only [hh, ht, Except.mapError, bind, Except.bind, pure, Except.pure,
        Except.ok.injEq] at h
      exact ⟨head, rest, rfl, rfl, h.symm⟩
theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧ Compatible lf rf := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i token hc
  cases token
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr,
    (checkCompatibility_ok_iff _ _).mp hc⟩

theorem admit_compatible (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) : Compatible lf rf :=
  (admit_ok cfg boundaries left right lf rf h).2.2.2

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_mem_of_resolve (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) (cell : Cell P A D)
    (resolved : ref.2.resolve caller parties = .ok cell) : cell ∈ cells := by
  obtain ⟨c, hc, he⟩ := resolveRefs_member caller parties refs cells h ref hr
  rw [resolved] at he
  cases he
  exact hc

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_append_ok (caller : P) (parties : List P)
    (xs ys : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties (xs ++ ys) = .ok cells) :
    ∃ left right, resolveRefs caller parties xs = .ok left ∧
      resolveRefs caller parties ys = .ok right ∧ cells = left ++ right := by
  simp only [resolveRefs, List.mapM_append] at h
  change ((resolveRefs caller parties xs).bind fun left ↦
    (resolveRefs caller parties ys).bind fun right ↦ .ok (left ++ right)) = .ok cells at h
  cases hx : resolveRefs caller parties xs with
  | error e => simp [hx, Except.bind] at h
  | ok left =>
    cases hy : resolveRefs caller parties ys with
    | error e => simp [hx, hy, Except.bind] at h
    | ok right =>
      simp only [hx, hy, Except.bind, Except.ok.injEq] at h
      exact ⟨left, right, rfl, rfl, h.symm⟩

/-- Accepted analysis covers every syntactic/declared read, every potential write and target,
and every output, regardless of whether the invocation would execute successfully. -/
theorem analyzeInvocation_coverage (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      (∀ ref ∈ template.requiredStateReads ++ template.stateReads,
        ∃ c ∈ fp.reads, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ ref ∈ template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩),
        ∃ c ∈ fp.writes, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ output ∈ iface.outputs, output.cell ∈ fp.reads) ∧
      (∀ c ∈ fp.writes, c ∈ fp.reads) := by
  obtain ⟨component, iface, template, reads, writes, hl, ht, hr, hw, _, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp h
  refine ⟨component, iface, template, hl, ht, ?_, ?_, ?_, ?_⟩
  · intro ref hm
    obtain ⟨c, hc, he⟩ := resolveRefs_member _ _ _ _ hr ref hm
    exact ⟨c, by simp [hc], he⟩
  · intro ref hm
    exact resolveRefs_member _ _ _ _ hw ref hm
  · intro output hm
    simp only [List.mem_append, List.mem_map]
    exact Or.inr ⟨output, hm, rfl⟩
  · intro c hc
    simp [hc]

theorem analyzeInvocation_writes_read (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∀ c ∈ fp.writes, c ∈ fp.reads := by
  obtain ⟨_, _, _, _, _, _, _, _, hw⟩ := analyzeInvocation_coverage cfg boundary inv fp h
  exact hw

/-- Every local invocation has its own analyzed footprint contained in the whole branch. -/
theorem analyzeBranchFrom_member (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (branch : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (n : Nat) (inv : Invocation P A D) (atIndex : branch[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundary (index + n)) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ fp.reads) ∧ (∀ c ∈ part.writes, c ∈ fp.writes) := by
  induction branch generalizing index fp n with
  | nil => simp at atIndex
  | cons head tail ih =>
    obtain ⟨hf, tf, hh, ht, rfl⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ h
    cases n with
    | zero =>
      simp only [List.getElem?_cons_zero, Option.some.injEq] at atIndex
      subst inv
      exact ⟨hf, by simpa using hh,
        fun c hc ↦ List.mem_append_left _ hc, fun c hc ↦ List.mem_append_left _ hc⟩
    | succ n =>
      simp only [List.getElem?_cons_succ] at atIndex
      obtain ⟨part, hl, hr, hw⟩ := ih (index + 1) tf ht n atIndex
      refine ⟨part, ?_, fun c hc ↦ List.mem_append_right _ (hr c hc),
        fun c hc ↦ List.mem_append_right _ (hw c hc)⟩
      simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using hl

end DefiKernel.Parallel
