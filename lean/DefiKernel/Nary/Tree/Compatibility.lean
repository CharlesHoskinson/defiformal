import DefiKernel.Nary.Tree.DisjointRuntime

/-! Proof-only references to `Parallel.Compatible`. Runtime pairwise checking lives in
DisjointRuntime and does not mention this proposition. -/
namespace DefiKernel.Nary.Tree
open Typed Composition Parallel

variable {B P A D : Type} [DecidableEq B] [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false
set_option linter.unusedFintypeInType false
set_option linter.dupNamespace false

def PairwiseCompatible (assoc : List (B × Footprint P A D)) : Prop :=
  ∀ p ∈ assoc, ∀ q ∈ assoc, p.1 ≠ q.1 → Compatible p.2 q.2

theorem checkPair_ok_iff (leftId rightId : B) (left right : Footprint P A D) :
    checkPair leftId rightId left right = .ok () ↔ Compatible left right := by
  constructor
  · intro h
    have hww : firstOverlap left.writes right.writes = none := by
      revert h; simp [checkPair]; cases firstOverlap left.writes right.writes <;> simp
    have hlr : firstOverlap left.writes right.reads = none := by
      revert h; simp [checkPair, hww]; cases firstOverlap left.writes right.reads <;> simp
    have hrl : firstOverlap right.writes left.reads = none := by
      revert h; simp [checkPair, hww, hlr]
      cases firstOverlap right.writes left.reads <;> simp
    exact ⟨(firstOverlap_none_iff _ _).mp hww,
      (firstOverlap_none_iff _ _).mp hlr,
      (firstOverlap_none_iff _ _).mp hrl⟩
  · intro hc
    have hww := (firstOverlap_none_iff left.writes right.writes).mpr hc.1
    have hlr := (firstOverlap_none_iff left.writes right.reads).mpr hc.2.1
    have hrl := (firstOverlap_none_iff right.writes left.reads).mpr hc.2.2
    simp [checkPair, hww, hlr, hrl]

theorem checkPair_error_iff (leftId rightId : B) (left right : Footprint P A D)
    (k : ConflictKind) (c : Cell P A D) :
    checkPair leftId rightId left right = .error ⟨leftId, rightId, k, c⟩ ↔
      checkCompatibility left right = .error (.conflict k c) := by
  unfold checkPair checkCompatibility
  cases hww : firstOverlap left.writes right.writes <;>
    cases hlr : firstOverlap left.writes right.reads <;>
    cases hrl : firstOverlap right.writes left.reads <;>
    simp_all [PairConflict.mk.injEq]

theorem checkAgainst_ok_iff (head : B × Footprint P A D) :
    ∀ rest, checkAgainst head rest = .ok () ↔ ∀ q ∈ rest, Compatible head.2 q.2
  | [] => by simp [checkAgainst]
  | other :: others => by
    constructor
    · intro hok q hq
      have hp : checkPair head.1 other.1 head.2 other.2 = .ok () := by
        revert hok; simp [checkAgainst]; cases checkPair head.1 other.1 head.2 other.2 <;> simp
      have ht : checkAgainst head others = .ok () := by
        revert hok; simp [checkAgainst, hp]
      simp only [List.mem_cons] at hq
      rcases hq with hqe | hq
      · rw [hqe]
        exact (checkPair_ok_iff head.1 other.1 head.2 other.2).mp hp
      · exact (checkAgainst_ok_iff head others).mp ht q hq
    · intro hall
      have hp := (checkPair_ok_iff head.1 other.1 head.2 other.2).mpr
        (hall other (by simp))
      simp [checkAgainst, hp]
      exact (checkAgainst_ok_iff head others).mpr fun q hq =>
        hall q (by simp [hq])

theorem checkAgainst_ok_of (head : B × Footprint P A D)
    (rest : List (B × Footprint P A D))
    (h : ∀ q ∈ rest, Compatible head.2 q.2) :
    checkAgainst head rest = .ok () :=
  (checkAgainst_ok_iff head rest).mpr h

/-- Distinct-identity checker. Self-pairs are not required; that would force empty writes. -/
theorem checkPairwiseFrom_ok_of (assoc : List (B × Footprint P A D)) :
    ∀ rest, (rest.map Prod.fst).Nodup →
      (∀ p ∈ rest, ∀ q ∈ rest, p.1 ≠ q.1 → Compatible p.2 q.2) →
      checkPairwiseFrom assoc rest = .ok ()
  | [] => fun _ _ => rfl
  | head :: others => by
    intro hnodup hall
    have hkeys : (head.1 :: others.map Prod.fst).Nodup := by simpa using hnodup
    have hhead : head.1 ∉ others.map Prod.fst := (List.nodup_cons.mp hkeys).1
    have hrest : (others.map Prod.fst).Nodup := (List.nodup_cons.mp hkeys).2
    have hagainst := checkAgainst_ok_of head others fun q hq =>
      hall head (by simp) q (by simp [hq]) (by
        intro heq
        exact hhead (List.mem_map.mpr ⟨q, hq, heq.symm⟩))
    simp [checkPairwiseFrom, hagainst]
    exact checkPairwiseFrom_ok_of assoc others hrest fun p hp q hq hne =>
      hall p (by simp [hp]) q (by simp [hq]) hne

theorem checkPairwise_ok_of (assoc : List (B × Footprint P A D))
    (hn : (assoc.map Prod.fst).Nodup) (h : PairwiseCompatible assoc) :
    checkPairwise assoc = .ok () :=
  checkPairwiseFrom_ok_of assoc assoc hn h

theorem checkPairwiseFrom_ok_implies (assoc : List (B × Footprint P A D)) :
    ∀ rest, checkPairwiseFrom assoc rest = .ok () →
      ∀ p ∈ rest, ∀ q ∈ rest, p.1 ≠ q.1 → Compatible p.2 q.2
  | [] => fun _ _ hp => by cases hp
  | head :: others => by
    intro hok p hp q hq hne
    have hagainst : checkAgainst head others = .ok () := by
      revert hok; simp [checkPairwiseFrom]; cases checkAgainst head others <;> simp
    have htail : checkPairwiseFrom assoc others = .ok () := by
      revert hok; simp [checkPairwiseFrom, hagainst]
    simp only [List.mem_cons] at hp hq
    rcases hp with hp | hp <;> rcases hq with hq | hq
    · rw [hp, hq] at hne; exact (hne rfl).elim
    · rw [hp]
      exact (checkAgainst_ok_iff head others).mp hagainst q hq
    · rw [hq]
      exact compatible_symm ((checkAgainst_ok_iff head others).mp hagainst p hp)
    · exact checkPairwiseFrom_ok_implies assoc others htail p hp q hq hne

theorem checkPairwise_ok_iff (assoc : List (B × Footprint P A D))
    (hn : (assoc.map Prod.fst).Nodup) :
    checkPairwise assoc = .ok () ↔ PairwiseCompatible assoc := by
  constructor
  · intro h
    exact checkPairwiseFrom_ok_implies assoc assoc h
  · intro h
    exact checkPairwise_ok_of assoc hn h

theorem mem_unionLeaves_writes (assoc : List (B × Footprint P A D)) :
    ∀ tree c, c ∈ (unionLeaves assoc tree).writes ↔
      ∃ b ∈ Tree.leaves tree, c ∈ (footprintOf assoc b).writes
  | .empty, c => by simp [unionLeaves, Tree.leaves, Footprint.empty]
  | .leaf b, c => by simp [unionLeaves, Tree.leaves]
  | .fork left right, c => by
    simp [unionLeaves, Tree.leaves, Footprint.append, List.mem_append,
      mem_unionLeaves_writes assoc left c, mem_unionLeaves_writes assoc right c]
    constructor
    · rintro (⟨b, hb, hw⟩ | ⟨b, hb, hw⟩)
      · exact ⟨b, Or.inl hb, hw⟩
      · exact ⟨b, Or.inr hb, hw⟩
    · rintro ⟨b, hb, hw⟩
      cases hb with
      | inl hL => exact Or.inl ⟨b, hL, hw⟩
      | inr hR => exact Or.inr ⟨b, hR, hw⟩

theorem mem_unionLeaves_reads (assoc : List (B × Footprint P A D)) :
    ∀ tree c, c ∈ (unionLeaves assoc tree).reads ↔
      ∃ b ∈ Tree.leaves tree, c ∈ (footprintOf assoc b).reads
  | .empty, c => by simp [unionLeaves, Tree.leaves, Footprint.empty]
  | .leaf b, c => by simp [unionLeaves, Tree.leaves]
  | .fork left right, c => by
    simp [unionLeaves, Tree.leaves, Footprint.append, List.mem_append,
      mem_unionLeaves_reads assoc left c, mem_unionLeaves_reads assoc right c]
    constructor
    · rintro (⟨b, hb, hr⟩ | ⟨b, hb, hr⟩)
      · exact ⟨b, Or.inl hb, hr⟩
      · exact ⟨b, Or.inr hb, hr⟩
    · rintro ⟨b, hb, hr⟩
      cases hb with
      | inl hL => exact Or.inl ⟨b, hL, hr⟩
      | inr hR => exact Or.inr ⟨b, hR, hr⟩

theorem unionLeaves_compatible (assoc : List (B × Footprint P A D))
    (left right : Tree B)
    (h : ∀ b ∈ Tree.leaves left, ∀ c ∈ Tree.leaves right,
      Compatible (footprintOf assoc b) (footprintOf assoc c)) :
    Compatible (unionLeaves assoc left) (unionLeaves assoc right) := by
  refine ⟨?_, ?_, ?_⟩
  · intro cell hwL hwR
    obtain ⟨b, hb, hwb⟩ := (mem_unionLeaves_writes assoc left cell).mp hwL
    obtain ⟨c, hc, hwc⟩ := (mem_unionLeaves_writes assoc right cell).mp hwR
    exact (h b hb c hc).1 cell hwb hwc
  · intro cell hwL hrR
    obtain ⟨b, hb, hwb⟩ := (mem_unionLeaves_writes assoc left cell).mp hwL
    obtain ⟨c, hc, hrc⟩ := (mem_unionLeaves_reads assoc right cell).mp hrR
    exact (h b hb c hc).2.1 cell hwb hrc
  · intro cell hwR hrL
    obtain ⟨c, hc, hwc⟩ := (mem_unionLeaves_writes assoc right cell).mp hwR
    obtain ⟨b, hb, hrb⟩ := (mem_unionLeaves_reads assoc left cell).mp hrL
    exact (h b hb c hc).2.2 cell hwc hrb

theorem unionLeaves_empty_left (assoc : List (B × Footprint P A D)) (tree : Tree B) :
    Compatible (unionLeaves assoc (Tree.empty : Tree B)) (unionLeaves assoc tree) := by
  refine ⟨?_, ?_, ?_⟩
  · intro cell hw; simp [unionLeaves, Footprint.empty] at hw
  · intro cell hw; simp [unionLeaves, Footprint.empty] at hw
  · intro cell _ hr; simp [unionLeaves, Footprint.empty] at hr

theorem unionLeaves_empty_right (assoc : List (B × Footprint P A D)) (tree : Tree B) :
    Compatible (unionLeaves assoc tree) (unionLeaves assoc (Tree.empty : Tree B)) := by
  refine ⟨?_, ?_, ?_⟩
  · intro cell _ hw; simp [unionLeaves, Footprint.empty] at hw
  · intro cell _ hr; simp [unionLeaves, Footprint.empty] at hr
  · intro cell hw; simp [unionLeaves, Footprint.empty] at hw

end DefiKernel.Nary.Tree
