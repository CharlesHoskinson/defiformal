import DefiKernel.Certificates.Correspondence
import Std.Data.TreeMap.Raw.Lemmas
import Std.Data.TreeMap.Raw.WF
import Mathlib.Logic.OpClass
import Mathlib.Data.List.Perm.Basic

namespace DefiKernel.Certificates

set_option linter.style.longLine false
set_option linter.style.setOption false
set_option linter.style.maxHeartbeats false
set_option maxHeartbeats 4000000

open Lean
open Std

/-! Depth-bridge helpers relating `TreeJson.depth` to `jsonDepthFuel` on `toJson` images.

    `Json.mkObj` stores a `TreeMap.Raw`. Duplicate keys drop earlier values, so the object
    identity requires distinct keys. `TreeJson.Valid` supplies that condition. Boolean `Json`
    equality via private `beq'` is not used. -/

theorem max_max_right_comm (b x y : Nat) : (b.max x).max y = (b.max y).max x := by
  simp only [Nat.max_assoc]
  congr 1
  exact Nat.max_comm x y

theorem foldl_max_init_shift {α : Type} (xs : List α) (f : α → Nat) (a : Nat) :
    xs.foldl (fun acc x => acc.max (f x)) a =
      a.max (xs.foldl (fun acc x => acc.max (f x)) 0) := by
  induction xs generalizing a with
  | nil => simp [List.foldl, Nat.max_comm]
  | cons x xs ih =>
    simp [List.foldl]
    rw [ih (a.max (f x)), ih (f x)]
    simpa using Nat.max_assoc a (f x) (xs.foldl (fun acc y => acc.max (f y)) 0)

theorem toJsonList_eq_map (xs : List TreeJson) :
    TreeJson.toJsonList xs = xs.map TreeJson.toJson := by
  induction xs with
  | nil => rfl
  | cons _ xs ih =>
    dsimp [TreeJson.toJsonList]
    rw [ih]
    rfl

theorem toJsonObj_eq_map (kvs : List (String × TreeJson)) :
    TreeJson.toJsonObj kvs = kvs.map (fun p => (p.1, p.2.toJson)) := by
  induction kvs with
  | nil => rfl
  | cons kv kvs ih =>
    rcases kv with ⟨_, _⟩
    dsimp [TreeJson.toJsonObj]
    rw [ih]
    rfl

theorem depthList_eq_foldl (xs : List TreeJson) :
    TreeJson.depthList xs = xs.foldl (fun acc x => acc.max x.depth) 0 := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    simp [TreeJson.depthList, List.foldl]
    rw [foldl_max_init_shift, ih]

theorem depthObj_eq_foldl (kvs : List (String × TreeJson)) :
    TreeJson.depthObj kvs = kvs.foldl (fun acc kv => acc.max kv.2.depth) 0 := by
  induction kvs with
  | nil => rfl
  | cons kv kvs ih =>
    rcases kv with ⟨_, v⟩
    simp [TreeJson.depthObj, List.foldl]
    rw [foldl_max_init_shift, ih]

theorem max_min_left (fuel a b : Nat) : (min fuel a).max (min fuel b) = min fuel (a.max b) := by
  simp [Nat.min_def, Nat.max_def]
  split_ifs <;> omega

theorem foldl_max_min_eq_min_foldl_max {α : Type} (xs : List α) (d : α → Nat) (fuel : Nat) :
    xs.foldl (fun acc x => acc.max (min fuel (d x))) 0 =
      min fuel (xs.foldl (fun acc x => acc.max (d x)) 0) := by
  induction xs with
  | nil => simp [List.foldl]
  | cons x xs ih =>
    simp [List.foldl]
    rw [foldl_max_init_shift (f := fun y => min fuel (d y)),
        foldl_max_init_shift (f := d), ih]
    exact max_min_left fuel (d x) (xs.foldl (fun acc y => acc.max (d y)) 0)

theorem pairwise_compare_ne_of_nodup_keys (kvs : List (String × Json))
    (h : (kvs.map Prod.fst).Nodup) :
    kvs.Pairwise (fun a b => ¬ compare a.1 b.1 = .eq) := by
  have hpw : (kvs.map Prod.fst).Pairwise (fun a b => a ≠ b) := h
  rw [List.pairwise_map] at hpw
  refine hpw.imp ?_
  intro a b hne heq
  exact hne (LawfulEqOrd.compare_eq_iff_eq.mp heq)

theorem nodup_pairs_of_nodup_keys {α β : Type} (kvs : List (α × β))
    (h : (kvs.map Prod.fst).Nodup) : kvs.Nodup := by
  have hpw : (kvs.map Prod.fst).Pairwise (fun a b => a ≠ b) := h
  rw [List.pairwise_map] at hpw
  refine hpw.imp ?_
  intro a b hne hab
  exact hne (congrArg Prod.fst hab)

theorem nodup_keys_of_toJsonObj (kvs : List (String × TreeJson))
    (h : (kvs.map Prod.fst).Nodup) :
    ((TreeJson.toJsonObj kvs).map Prod.fst).Nodup := by
  rw [toJsonObj_eq_map, List.map_map]
  change (kvs.map (fun p => p.1)).Nodup
  exact h

theorem mem_ofList_toList_iff (kvs : List (String × Json))
    (h_nodup : (kvs.map Prod.fst).Nodup) (p : String × Json) :
    p ∈ (TreeMap.Raw.ofList kvs compare).toList ↔ p ∈ kvs := by
  rcases p with ⟨k, v⟩
  have hWF : (TreeMap.Raw.ofList kvs compare).WF := TreeMap.Raw.WF.ofList
  have hdist := pairwise_compare_ne_of_nodup_keys kvs h_nodup
  constructor
  · intro hmem
    have hget : (TreeMap.Raw.ofList kvs compare)[k]? = some v :=
      (TreeMap.Raw.mem_toList_iff_getElem?_eq_some hWF).mp hmem
    have hcont : (TreeMap.Raw.ofList kvs compare).contains k = true := by
      rw [TreeMap.Raw.contains_eq_isSome_getElem? hWF]
      simp [hget]
    have hcontains : (kvs.map Prod.fst).contains k = true := by
      simpa [TreeMap.Raw.contains_ofList (cmp := compare)] using hcont
    have hk : k ∈ kvs.map Prod.fst := List.contains_iff_mem.mp hcontains
    obtain ⟨q, hq, hkq⟩ := List.mem_map.mp hk
    rcases q with ⟨k', v'⟩
    dsimp at hkq
    cases hkq
    have hget' : (TreeMap.Raw.ofList kvs compare)[k]? = some v' :=
      TreeMap.Raw.getElem?_ofList_of_mem compare_self hdist hq
    have hv : v' = v := Option.some.inj (hget'.symm.trans hget)
    rwa [hv] at hq
  · intro hmem
    have hget : (TreeMap.Raw.ofList kvs compare)[k]? = some v :=
      TreeMap.Raw.getElem?_ofList_of_mem compare_self hdist hmem
    exact (TreeMap.Raw.mem_toList_iff_getElem?_eq_some hWF).mpr hget

theorem toList_ofList_perm_of_nodup (kvs : List (String × Json))
    (h_nodup : (kvs.map Prod.fst).Nodup) :
    (TreeMap.Raw.ofList kvs compare).toList.Perm kvs := by
  have hWF : (TreeMap.Raw.ofList kvs compare).WF := TreeMap.Raw.WF.ofList
  have d₁ : ((TreeMap.Raw.ofList kvs compare).toList).Nodup := by
    have hkeys := TreeMap.Raw.distinct_keys_toList (t := TreeMap.Raw.ofList kvs compare) hWF
    refine hkeys.imp ?_
    intro a b hne hab
    apply hne
    rw [LawfulEqOrd.compare_eq_iff_eq]
    exact congrArg Prod.fst hab
  have d₂ : kvs.Nodup := nodup_pairs_of_nodup_keys kvs h_nodup
  exact (List.perm_ext_iff_of_nodup d₁ d₂).mpr (fun p => mem_ofList_toList_iff kvs h_nodup p)

instance foldl_max_jsonDepth_rightComm (fuel : Nat) :
    RightCommutative (fun (acc : Nat) (p : String × Json) => acc.max (jsonDepthFuel fuel p.2)) where
  right_comm := fun b a1 a2 => max_max_right_comm b (jsonDepthFuel fuel a1.2) (jsonDepthFuel fuel a2.2)

theorem jsonDepthFuel_mkObj_succ (fuel : Nat) (kvs : List (String × Json))
    (h_nodup : (kvs.map Prod.fst).Nodup) :
    jsonDepthFuel (fuel + 1) (Json.mkObj kvs) =
      1 + kvs.foldl (fun acc kv => acc.max (jsonDepthFuel fuel kv.2)) 0 := by
  dsimp [Json.mkObj, jsonDepthFuel]
  rw [TreeMap.Raw.foldl_eq_foldl_toList]
  have hperm := toList_ofList_perm_of_nodup kvs h_nodup
  have hfold :=
    (List.Perm.foldl_eq (f := fun acc p => acc.max (jsonDepthFuel fuel p.2)) hperm) 0
  exact congrArg (fun n => 1 + n) hfold

theorem jsonDepthFuel_arr_succ (fuel : Nat) (xs : List Json) :
    jsonDepthFuel (fuel + 1) (Json.arr xs.toArray) =
      1 + xs.foldl (fun acc j => acc.max (jsonDepthFuel fuel j)) 0 := by
  simp [jsonDepthFuel, Array.foldl_toList]

theorem perm_of_nodup_keys_mem (l₁ l₂ : List (String × Json))
    (h₁ : (l₁.map Prod.fst).Nodup) (h₂ : (l₂.map Prod.fst).Nodup)
    (hmem : ∀ p, p ∈ l₁ ↔ p ∈ l₂) : l₁.Perm l₂ :=
  (List.perm_ext_iff_of_nodup (nodup_pairs_of_nodup_keys l₁ h₁)
    (nodup_pairs_of_nodup_keys l₂ h₂)).mpr hmem

theorem jsonDepthFuel_mkObj_perm (fuel : Nat) (l₁ l₂ : List (String × Json))
    (h_nodup : (l₁.map Prod.fst).Nodup) (h_perm : l₁.Perm l₂) :
    jsonDepthFuel fuel (Json.mkObj l₁) = jsonDepthFuel fuel (Json.mkObj l₂) := by
  cases fuel with
  | zero => rfl
  | succ fuel =>
    have h₂ : (l₂.map Prod.fst).Nodup :=
      ((h_perm.map Prod.fst).nodup_iff).mp h_nodup
    rw [jsonDepthFuel_mkObj_succ fuel l₁ h_nodup, jsonDepthFuel_mkObj_succ fuel l₂ h₂]
    have hfold :=
      (List.Perm.foldl_eq (f := fun acc p => acc.max (jsonDepthFuel fuel p.2)) h_perm) 0
    exact congrArg (fun n => 1 + n) hfold

theorem foldl_max_map_toJson (xs : List TreeJson) (fuel init : Nat) :
    (xs.map TreeJson.toJson).foldl (fun acc j => acc.max (jsonDepthFuel fuel j)) init =
      xs.foldl (fun acc x => acc.max (jsonDepthFuel fuel x.toJson)) init := by
  induction xs generalizing init with
  | nil => rfl
  | cons _ xs ih =>
    simp [List.map, List.foldl]
    exact ih _

theorem foldl_max_map_toJsonObj (kvs : List (String × TreeJson)) (fuel init : Nat) :
    (kvs.map (fun p => (p.1, p.2.toJson))).foldl
        (fun acc kv => acc.max (jsonDepthFuel fuel kv.2)) init =
      kvs.foldl (fun acc kv => acc.max (jsonDepthFuel fuel kv.2.toJson)) init := by
  induction kvs generalizing init with
  | nil => rfl
  | cons kv kvs ih =>
    rcases kv with ⟨_, _⟩
    simp [List.map, List.foldl]
    exact ih _

/-- For a Valid TreeJson, fuel-bounded semantic depth is `min fuel` of syntactic depth. -/
theorem jsonDepthFuel_toJson_eq_min (t : TreeJson) (fuel : Nat) (h : TreeJson.Valid t) :
    jsonDepthFuel fuel t.toJson = min fuel (TreeJson.depth t) := by
  revert fuel h
  refine Nat.strongRecOn (motive := fun n =>
      ∀ (t : TreeJson), TreeJson.size t = n → ∀ fuel, TreeJson.Valid t →
        jsonDepthFuel fuel t.toJson = min fuel t.depth) t.size ?_ t rfl
  intro n ih t ht fuel hval
  cases t with
  | null =>
    cases fuel <;> simp [jsonDepthFuel, TreeJson.toJson, TreeJson.depth]
  | bool _ =>
    cases fuel <;> simp [jsonDepthFuel, TreeJson.toJson, TreeJson.depth]
  | num _ =>
    cases fuel <;> simp [jsonDepthFuel, TreeJson.toJson, TreeJson.depth]
  | str _ =>
    cases fuel <;> simp [jsonDepthFuel, TreeJson.toJson, TreeJson.depth]
  | arr xs =>
    cases fuel with
    | zero =>
      simp [jsonDepthFuel, TreeJson.toJson, TreeJson.depth]
    | succ fuel =>
      dsimp [TreeJson.Valid] at hval
      rcases hval with ⟨_, hvl⟩
      dsimp [TreeJson.toJson, TreeJson.depth]
      rw [jsonDepthFuel_arr_succ, toJsonList_eq_map, foldl_max_map_toJson]
      have hcongr :
          xs.foldl (fun acc x => acc.max (jsonDepthFuel fuel x.toJson)) 0 =
            xs.foldl (fun acc x => acc.max (min fuel x.depth)) 0 := by
        refine foldl_max_congr xs (fun x => jsonDepthFuel fuel x.toJson)
          (fun x => min fuel x.depth) 0 ?_
        intro x hx
        have hv := TreeJson.valid_of_mem_validList x xs hvl hx
        have hsz : TreeJson.size x < n := by
          have := TreeJson.mem_sizeList x xs hx
          dsimp [TreeJson.size] at ht
          omega
        exact ih (TreeJson.size x) hsz x rfl fuel hv
      rw [hcongr, foldl_max_min_eq_min_foldl_max, ← depthList_eq_foldl]
      omega
  | obj kvs =>
    cases fuel with
    | zero =>
      simp [jsonDepthFuel, TreeJson.toJson, TreeJson.depth]
    | succ fuel =>
      dsimp [TreeJson.Valid] at hval
      rcases hval with ⟨hnodup, hvo⟩
      dsimp [TreeJson.toJson, TreeJson.depth]
      have hkeys := nodup_keys_of_toJsonObj kvs hnodup
      rw [jsonDepthFuel_mkObj_succ fuel (TreeJson.toJsonObj kvs) hkeys, toJsonObj_eq_map,
          foldl_max_map_toJsonObj]
      have hcongr :
          kvs.foldl (fun acc kv => acc.max (jsonDepthFuel fuel kv.2.toJson)) 0 =
            kvs.foldl (fun acc kv => acc.max (min fuel kv.2.depth)) 0 := by
        refine foldl_max_congr kvs (fun kv => jsonDepthFuel fuel kv.2.toJson)
          (fun kv => min fuel kv.2.depth) 0 ?_
        intro kv hkv
        rcases kv with ⟨k, v⟩
        have hv := TreeJson.valid_of_mem_validObj k v kvs hvo hkv
        have hsz : TreeJson.size v < n := by
          have := TreeJson.mem_sizeObj k v kvs hkv
          dsimp [TreeJson.size] at ht
          omega
        exact ih (TreeJson.size v) hsz v rfl fuel hv
      rw [hcongr, foldl_max_min_eq_min_foldl_max, ← depthObj_eq_foldl]
      omega

/-- Semantic `jsonDepth` of a Valid tree is `min 100` of syntactic depth. -/
theorem jsonDepth_toJson_eq_min (t : TreeJson) (h : TreeJson.Valid t) :
    jsonDepth t.toJson = min 100 (TreeJson.depth t) :=
  jsonDepthFuel_toJson_eq_min t 100 h

/-- If semantic depth of the Valid `toJson` image is ≤ 64, syntactic depth is ≤ 64. -/
theorem TreeJson.depth_le_of_jsonDepth_toJson_le_64 (t : TreeJson) (h : TreeJson.Valid t)
    (h_sem : jsonDepth t.toJson ≤ 64) : TreeJson.depth t ≤ 64 := by
  have := jsonDepth_toJson_eq_min t h
  omega

theorem foldl_max_map_json {α : Type} (φ : α → Json) (xs : List α) (fuel init : Nat) :
    (xs.map φ).foldl (fun acc j => acc.max (jsonDepthFuel fuel j)) init =
      xs.foldl (fun acc x => acc.max (jsonDepthFuel fuel (φ x))) init := by
  induction xs generalizing init with
  | nil => rfl
  | cons _ xs ih =>
    simp [List.map, List.foldl]
    exact ih _

theorem jsonDepthFuel_arr_congr {α : Type} (f g : α → Json) (xs : List α)
    (h : ∀ x ∈ xs, ∀ fuel, jsonDepthFuel fuel (f x) = jsonDepthFuel fuel (g x))
    (fuel : Nat) :
    jsonDepthFuel fuel (Json.arr (xs.map f).toArray) =
      jsonDepthFuel fuel (Json.arr (xs.map g).toArray) := by
  cases fuel with
  | zero => rfl
  | succ fuel =>
    rw [jsonDepthFuel_arr_succ, jsonDepthFuel_arr_succ, foldl_max_map_json, foldl_max_map_json]
    refine congrArg (fun n => 1 + n) ?_
    refine foldl_max_congr xs (fun x => jsonDepthFuel fuel (f x))
      (fun x => jsonDepthFuel fuel (g x)) 0 ?_
    intro x hx
    exact h x hx fuel

theorem jsonDepthFuel_mkObj_of_nodup_keys (fuel : Nat) (kvs : List (String × Json))
    (h_nodup : (kvs.map Prod.fst).Nodup) :
    jsonDepthFuel fuel (Json.mkObj kvs) =
      match fuel with
      | 0 => 0
      | fuel + 1 => 1 + kvs.foldl (fun acc kv => acc.max (jsonDepthFuel fuel kv.2)) 0 := by
  cases fuel with
  | zero => rfl
  | succ fuel => exact jsonDepthFuel_mkObj_succ fuel kvs h_nodup

end DefiKernel.Certificates

