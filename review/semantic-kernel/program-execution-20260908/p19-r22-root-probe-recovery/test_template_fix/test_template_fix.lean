import Lean.Data.Json
import DefiKernel.Certificates.Correspondence

open Lean DefiKernel.Certificates

theorem toJsonList_map {α : Type} (f : α → TreeJson) (xs : List α) :
    TreeJson.toJsonList (xs.map f) = xs.map (fun x => (f x).toJson) := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    dsimp [List.map, TreeJson.toJsonList]
    rw [ih]

theorem encodeList_map {α : Type} (f : α → TreeJson) (xs : List α) :
    TreeJson.encodeList (xs.map f) = String.intercalate "," (xs.map (fun x => (f x).encode)) := by
  rw [encodeList_eq_intercalate]
  simp only [List.map_map]
  rfl

theorem encode_arr_map {α : Type} (f : α → TreeJson) (xs : List α) :
    TreeJson.encode (.arr (xs.map f)) = jsonArr (xs.map (fun x => (f x).encode)) := by
  dsimp [TreeJson.encode, jsonArr]
  rw [encodeList_map]

theorem toJson_arr_map {α : Type} (f : α → TreeJson) (xs : List α) :
    (TreeJson.arr (xs.map f)).toJson = Lean.Json.arr (xs.map (fun x => (f x).toJson)).toArray := by
  dsimp [TreeJson.toJson]
  rw [toJsonList_map]

theorem validList_map {α : Type} (f : α → TreeJson) (xs : List α)
    (h : ∀ x ∈ xs, TreeJson.Valid (f x)) :
    TreeJson.ValidList (xs.map f) := by
  induction xs with
  | nil => trivial
  | cons x xs ih =>
    dsimp [List.map, TreeJson.ValidList]
    refine ⟨h x (List.Mem.head xs), ih (fun y hy => h y (List.Mem.tail x hy))⟩

theorem valid_arr_map {α : Type} (f : α → TreeJson) (xs : List α)
    (h_len : xs.length ≤ 4096)
    (h : ∀ x ∈ xs, TreeJson.Valid (f x)) :
    TreeJson.Valid (TreeJson.arr (xs.map f)) := by
  dsimp [TreeJson.Valid]
  rw [List.length_map]
  exact ⟨h_len, validList_map f xs h⟩

def envReadToTreeJson : EnvReadEnc → TreeJson
  | .observation k => TreeJson.obj [("tag", TreeJson.str "observation"), ("key", observationKeyToTreeJson k)]
  | .currentTime => TreeJson.obj [("tag", TreeJson.str "currentTime")]

theorem envReadToTreeJson_toJson (er : EnvReadEnc) :
    (envReadToTreeJson er).toJson = envReadToJson er := by
  cases er with
  | observation k =>
    dsimp [envReadToTreeJson, envReadToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [observationKeyToTreeJson_toJson]
  | currentTime => rfl

theorem envReadToTreeJson_encode (er : EnvReadEnc) :
    (envReadToTreeJson er).encode = encodeEnvRead er := by
  cases er with
  | observation k =>
    dsimp [envReadToTreeJson, encodeEnvRead]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [observationKeyToTreeJson_encode]
    rfl
  | currentTime => rfl

theorem envReadToTreeJson_valid (er : EnvReadEnc) :
    TreeJson.Valid (envReadToTreeJson er) := by
  cases er with
  | observation k =>
    dsimp [envReadToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, observationKeyToTreeJson_valid k, trivial⟩
  | currentTime =>
    dsimp [envReadToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩

def cellDeltaToTreeJson (d : CellDeltaEnc) : TreeJson :=
  TreeJson.obj [
    ("asset", assetToTreeJson d.asset),
    ("target", cellRefToTreeJson d.target),
    ("amount", exprToTreeJson d.amount)
  ]

theorem cellDeltaToTreeJson_toJson (d : CellDeltaEnc) :
    (cellDeltaToTreeJson d).toJson = cellDeltaToJson d := by
  dsimp [cellDeltaToTreeJson, cellDeltaToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [assetToTreeJson_toJson, cellRefToTreeJson_toJson, exprToTreeJson_toJson]

theorem cellDeltaToTreeJson_encode (d : CellDeltaEnc) :
    (cellDeltaToTreeJson d).encode = encodeCellDelta d := by
  dsimp [cellDeltaToTreeJson, encodeCellDelta]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [assetToTreeJson_encode, cellRefToTreeJson_encode, exprToTreeJson_encode]

theorem cellDeltaToTreeJson_valid (d : CellDeltaEnc) :
    TreeJson.Valid (cellDeltaToTreeJson d) := by
  dsimp [cellDeltaToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, assetToTreeJson_valid d.asset, cellRefToTreeJson_valid d.target, exprToTreeJson_valid d.amount, trivial⟩

def supplyDeltaToTreeJson (d : SupplyDeltaEnc) : TreeJson :=
  TreeJson.obj [
    ("domain", domainToTreeJson d.domain),
    ("asset", assetToTreeJson d.asset),
    ("amount", exprToTreeJson d.amount)
  ]

theorem supplyDeltaToTreeJson_toJson (d : SupplyDeltaEnc) :
    (supplyDeltaToTreeJson d).toJson = supplyDeltaToJson d := by
  dsimp [supplyDeltaToTreeJson, supplyDeltaToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [domainToTreeJson_toJson, assetToTreeJson_toJson, exprToTreeJson_toJson]

theorem supplyDeltaToTreeJson_encode (d : SupplyDeltaEnc) :
    (supplyDeltaToTreeJson d).encode = encodeSupplyDelta d := by
  dsimp [supplyDeltaToTreeJson, encodeSupplyDelta]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [domainToTreeJson_encode, assetToTreeJson_encode, exprToTreeJson_encode]

theorem supplyDeltaToTreeJson_valid (d : SupplyDeltaEnc) :
    TreeJson.Valid (supplyDeltaToTreeJson d) := by
  dsimp [supplyDeltaToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, domainToTreeJson_valid d.domain, assetToTreeJson_valid d.asset, exprToTreeJson_valid d.amount, trivial⟩

def templateToTreeJson (t : TemplateEnc) : TreeJson :=
  TreeJson.obj [
    ("signature", TreeJson.arr (t.signature.map unitToTreeJson)),
    ("domain", domainToTreeJson t.domain),
    ("partyArity", TreeJson.num t.partyArity),
    ("guard", exprToTreeJson t.guard),
    ("deltas", TreeJson.arr (t.deltas.map cellDeltaToTreeJson)),
    ("supplyDeltas", TreeJson.arr (t.supplyDeltas.map supplyDeltaToTreeJson)),
    ("stateReads", TreeJson.arr (t.stateReads.map packedCellRefToTreeJson)),
    ("envReads", TreeJson.arr (t.envReads.map envReadToTreeJson)),
    ("writes", TreeJson.arr (t.writes.map packedCellRefToTreeJson))
  ]

theorem templateToTreeJson_toJson (t : TemplateEnc) :
    (templateToTreeJson t).toJson = templateToJson t := by
  dsimp [templateToTreeJson, templateToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map, toJsonList_map, toJsonList_map, toJsonList_map, toJsonList_map, toJsonList_map]
  have h_sig : (t.signature.map (fun x => (unitToTreeJson x).toJson)) = t.signature.map unitToJson := by
    simp only [List.map_inj_left]; intro u _; exact unitToTreeJson_toJson u
  have h_del : (t.deltas.map (fun x => (cellDeltaToTreeJson x).toJson)) = t.deltas.map cellDeltaToJson := by
    simp only [List.map_inj_left]; intro d _; exact cellDeltaToTreeJson_toJson d
  have h_sdel : (t.supplyDeltas.map (fun x => (supplyDeltaToTreeJson x).toJson)) = t.supplyDeltas.map supplyDeltaToJson := by
    simp only [List.map_inj_left]; intro sd _; exact supplyDeltaToTreeJson_toJson sd
  have h_srd : (t.stateReads.map (fun x => (packedCellRefToTreeJson x).toJson)) = t.stateReads.map packedCellRefToJson := by
    simp only [List.map_inj_left]; intro sr _; exact packedCellRefToTreeJson_toJson sr
  have h_erd : (t.envReads.map (fun x => (envReadToTreeJson x).toJson)) = t.envReads.map envReadToJson := by
    simp only [List.map_inj_left]; intro er _; exact envReadToTreeJson_toJson er
  have h_wrt : (t.writes.map (fun x => (packedCellRefToTreeJson x).toJson)) = t.writes.map packedCellRefToJson := by
    simp only [List.map_inj_left]; intro w _; exact packedCellRefToTreeJson_toJson w
  rw [h_sig, h_del, h_sdel, h_srd, h_erd, h_wrt]
  rw [domainToTreeJson_toJson, exprToTreeJson_toJson]

theorem templateToTreeJson_encode (t : TemplateEnc) :
    (templateToTreeJson t).encode = encodeTemplate t := by
  dsimp [templateToTreeJson, encodeTemplate]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map, encode_arr_map, encode_arr_map, encode_arr_map, encode_arr_map, encode_arr_map]
  have h_sig : (t.signature.map (fun x => (unitToTreeJson x).encode)) = t.signature.map encodeUnit := by
    simp only [List.map_inj_left]; intro u _; exact unitToTreeJson_encode u
  have h_del : (t.deltas.map (fun x => (cellDeltaToTreeJson x).encode)) = t.deltas.map cellDeltaToJson_encode := by
    simp only [List.map_inj_left]; intro d _; exact cellDeltaToTreeJson_encode d
  have h_sdel : (t.supplyDeltas.map (fun x => (supplyDeltaToTreeJson x).encode)) = t.supplyDeltas.map supplyDeltaToJson_encode := by
    simp only [List.map_inj_left]; intro sd _; exact supplyDeltaToTreeJson_encode sd
  have h_srd : (t.stateReads.map (fun x => (packedCellRefToTreeJson x).encode)) = t.stateReads.map encodePackedCellRef := by
    simp only [List.map_inj_left]; intro sr _; exact packedCellRefToTreeJson_encode sr
  have h_erd : (t.envReads.map (fun x => (envReadToTreeJson x).encode)) = t.envReads.map encodeEnvRead := by
    simp only [List.map_inj_left]; intro er _; exact envReadToTreeJson_encode er
  have h_wrt : (t.writes.map (fun x => (packedCellRefToTreeJson x).encode)) = t.writes.map encodePackedCellRef := by
    simp only [List.map_inj_left]; intro w _; exact packedCellRefToTreeJson_encode w
  rw [h_sig, h_del, h_sdel, h_srd, h_erd, h_wrt]
  rw [domainToTreeJson_encode, exprToTreeJson_encode]
  dsimp [TreeJson.encode]
  rfl

theorem templateToTreeJson_valid (t : TemplateEnc)
    (h_sig : t.signature.length ≤ 4096)
    (h_del : t.deltas.length ≤ 4096)
    (h_sdel : t.supplyDeltas.length ≤ 4096)
    (h_srd : t.stateReads.length ≤ 4096)
    (h_erd : t.envReads.length ≤ 4096)
    (h_wrt : t.writes.length ≤ 4096) :
    TreeJson.Valid (templateToTreeJson t) := by
  dsimp [templateToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide,
          valid_arr_map unitToTreeJson t.signature h_sig (fun u _ => unitToTreeJson_valid u),
          domainToTreeJson_valid t.domain,
          trivial,
          exprToTreeJson_valid t.guard,
          valid_arr_map cellDeltaToTreeJson t.deltas h_del (fun d _ => cellDeltaToTreeJson_valid d),
          valid_arr_map supplyDeltaToTreeJson t.supplyDeltas h_sdel (fun sd _ => supplyDeltaToTreeJson_valid sd),
          valid_arr_map packedCellRefToTreeJson t.stateReads h_srd (fun sr _ => packedCellRefToTreeJson_valid sr),
          valid_arr_map envReadToTreeJson t.envReads h_erd (fun er _ => envReadToTreeJson_valid er),
          valid_arr_map packedCellRefToTreeJson t.writes h_wrt (fun w _ => packedCellRefToTreeJson_valid w),
          trivial⟩

def registryEntryToTreeJson (e : RegistryEntryEnc) : TreeJson :=
  TreeJson.obj [("id", TreeJson.num e.id), ("template", templateToTreeJson e.template)]

theorem registryEntryToTreeJson_toJson (e : RegistryEntryEnc) :
    (registryEntryToTreeJson e).toJson = registryEntryToJson e := by
  dsimp [registryEntryToTreeJson, registryEntryToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [templateToTreeJson_toJson]
  rfl

theorem registryEntryToTreeJson_encode (e : RegistryEntryEnc) :
    (registryEntryToTreeJson e).encode = encodeRegistryEntry e := by
  dsimp [registryEntryToTreeJson, encodeRegistryEntry]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map, TreeJson.encode]
  rw [templateToTreeJson_encode]
  rfl

theorem registryEntryToTreeJson_valid (e : RegistryEntryEnc)
    (h_sig : e.template.signature.length ≤ 4096)
    (h_del : e.template.deltas.length ≤ 4096)
    (h_sdel : e.template.supplyDeltas.length ≤ 4096)
    (h_srd : e.template.stateReads.length ≤ 4096)
    (h_erd : e.template.envReads.length ≤ 4096)
    (h_wrt : e.template.writes.length ≤ 4096) :
    TreeJson.Valid (registryEntryToTreeJson e) := by
  dsimp [registryEntryToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, templateToTreeJson_valid e.template h_sig h_del h_sdel h_srd h_erd h_wrt, trivial⟩

def registryToTreeJson (r : RegistryEnc) : TreeJson :=
  TreeJson.obj [("entries", TreeJson.arr (r.entries.map registryEntryToTreeJson))]

theorem registryToTreeJson_toJson (r : RegistryEnc) :
    (registryToTreeJson r).toJson = registryToJson r := by
  dsimp [registryToTreeJson, registryToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map]
  have h_map : (r.entries.map (fun x => (registryEntryToTreeJson x).toJson)) = r.entries.map registryEntryToJson := by
    simp only [List.map_inj_left]; intro e _; exact registryEntryToTreeJson_toJson e
  rw [h_map]

theorem registryToTreeJson_encode (r : RegistryEnc) :
    (registryToTreeJson r).encode = encodeRegistry r := by
  dsimp [registryToTreeJson, encodeRegistry]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map]
  have h_map : (r.entries.map (fun x => (registryEntryToTreeJson x).encode)) = r.entries.map encodeRegistryEntry := by
    simp only [List.map_inj_left]; intro e _; exact registryEntryToTreeJson_encode e
  rw [h_map]

