import Lean.Data.Json
import DefiKernel.Certificates.Correspondence

open Lean DefiKernel.Certificates

theorem numToTreeJson_encode_nat (n : Nat) : (TreeJson.num (n : Int)).encode = toString n := rfl
theorem numToTreeJson_toJson_nat (n : Nat) : (TreeJson.num (n : Int)).toJson = Lean.Json.num n := rfl

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

theorem encode_arr_str (xs : List String) :
    TreeJson.encode (.arr (xs.map TreeJson.str)) = jsonArr (xs.map escapeJsonString) := by
  rw [encode_arr_map]
  have h_eq : (xs.map (fun s => (TreeJson.str s).encode)) = xs.map escapeJsonString := by
    simp only [List.map_inj_left]
    intro s _
    exact escapeTreeString_eq_escapeJsonString s
  rw [h_eq]

theorem toJson_arr_str (xs : List String) :
    (TreeJson.arr (xs.map TreeJson.str)).toJson = Lean.Json.arr (xs.map Lean.Json.str).toArray := by
  rw [toJson_arr_map]
  rfl

theorem valid_arr_str (xs : List String) (h_len : xs.length ≤ 4096) :
    TreeJson.Valid (TreeJson.arr (xs.map TreeJson.str)) := by
  apply valid_arr_map
  · exact h_len
  · intro _ _; trivial

def packedValueFullToTreeJson (v : PackedValueEnc) : TreeJson :=
  TreeJson.obj [("unit", unitToTreeJson v.unit), ("value", packedValueToTreeJson v)]

theorem packedValueFullToTreeJson_toJson (v : PackedValueEnc) :
    (packedValueFullToTreeJson v).toJson = packedValueFullToJson v := by
  dsimp [packedValueFullToTreeJson, packedValueFullToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [unitToTreeJson_toJson, packedValueToTreeJson_toJson]

theorem packedValueFullToTreeJson_encode (v : PackedValueEnc) :
    (packedValueFullToTreeJson v).encode = encodePackedValue v := by
  dsimp [packedValueFullToTreeJson, encodePackedValue]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [unitToTreeJson_encode]
  cases h : v.unit with
  | bool =>
    dsimp [encodeUnit]
    dsimp [packedValueToTreeJson]
    rw [h]
    dsimp
    cases v.valBool <;> rfl
  | numeric nu =>
    dsimp [encodeUnit]
    dsimp [packedValueToTreeJson]
    rw [h]
    dsimp
    rw [ratToTreeJson_encode]

theorem packedValueFullToTreeJson_valid (v : PackedValueEnc) :
    TreeJson.Valid (packedValueFullToTreeJson v) := by
  dsimp [packedValueFullToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, unitToTreeJson_valid v.unit, ?_, trivial⟩
  cases h : v.unit with
  | bool =>
    dsimp [packedValueToTreeJson]
    rw [h]
    trivial
  | numeric nu =>
    dsimp [packedValueToTreeJson]
    rw [h]
    exact ratToTreeJson_valid ⟨v.valRat.num, v.valRat.den⟩

theorem map_encode_str_pairs (entries : List (String × String)) :
    (entries.map (fun (k, v) => (k, TreeJson.str v))).map (fun (k, v) => (k, TreeJson.encode v)) =
    entries.map (fun (k, v) => (k, escapeJsonString v)) := by
  induction entries with
  | nil => rfl
  | cons kv rest ih =>
    rcases kv with ⟨k, v⟩
    dsimp [List.map]
    have h_esc : (TreeJson.str v).encode = escapeJsonString v := escapeTreeString_eq_escapeJsonString v
    rw [h_esc, ih]

def sourceMapToTreeJson (entries : List (String × String)) : TreeJson :=
  TreeJson.obj (entries.map (fun (k, v) => (k, TreeJson.str v)))

theorem toJsonObj_map_str (entries : List (String × String)) :
    TreeJson.toJsonObj (entries.map (fun (k, v) => (k, TreeJson.str v))) =
    entries.map (fun (k, v) => (k, Lean.Json.str v)) := by
  induction entries with
  | nil => rfl
  | cons kv rest ih =>
    rcases kv with ⟨k, v⟩
    dsimp [List.map, TreeJson.toJsonObj, TreeJson.toJson]
    rw [ih]

theorem sourceMapToTreeJson_toJson (entries : List (String × String)) :
    (sourceMapToTreeJson entries).toJson = Lean.Json.mkObj (entries.map (fun (k, v) => (k, Lean.Json.str v))) := by
  dsimp [sourceMapToTreeJson, TreeJson.toJson]
  rw [toJsonObj_map_str]

theorem sourceMapToTreeJson_encode (entries : List (String × String)) (h_sm : SourceMapSorted entries) :
    (sourceMapToTreeJson entries).encode = encodeSourceMap entries := by
  dsimp [sourceMapToTreeJson, encodeSourceMap]
  rw [h_sm]
  dsimp
  rw [encode_obj_eq_jsonObj]
  rw [map_encode_str_pairs]

def stateCellToTreeJson (c : StateCellEnc) : TreeJson :=
  TreeJson.obj [
    ("domain", domainToTreeJson c.domain),
    ("party", partyToTreeJson c.party),
    ("asset", assetToTreeJson c.asset),
    ("amount", ratToTreeJson c.amount)
  ]

theorem stateCellToTreeJson_toJson (c : StateCellEnc) :
    (stateCellToTreeJson c).toJson = stateCellToJson c := by
  dsimp [stateCellToTreeJson, stateCellToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [domainToTreeJson_toJson, partyToTreeJson_toJson, assetToTreeJson_toJson, ratToTreeJson_toJson]

theorem stateCellToTreeJson_encode (c : StateCellEnc) :
    (stateCellToTreeJson c).encode = encodeStateCell c := by
  dsimp [stateCellToTreeJson, encodeStateCell]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [domainToTreeJson_encode, partyToTreeJson_encode, assetToTreeJson_encode, ratToTreeJson_encode]

theorem stateCellToTreeJson_valid (c : StateCellEnc) :
    TreeJson.Valid (stateCellToTreeJson c) := by
  dsimp [stateCellToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, domainToTreeJson_valid c.domain, partyToTreeJson_valid c.party,
          assetToTreeJson_valid c.asset, ratToTreeJson_valid c.amount, trivial⟩

def cellToTreeJson (c : CellEnc) : TreeJson :=
  TreeJson.obj [
    ("domain", domainToTreeJson c.domain),
    ("party", partyToTreeJson c.party),
    ("asset", assetToTreeJson c.asset)
  ]

theorem cellToTreeJson_toJson (c : CellEnc) :
    (cellToTreeJson c).toJson = cellToJson c := by
  dsimp [cellToTreeJson, cellToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [domainToTreeJson_toJson, partyToTreeJson_toJson, assetToTreeJson_toJson]

theorem cellToTreeJson_encode (c : CellEnc) :
    (cellToTreeJson c).encode = encodeCell c := by
  dsimp [cellToTreeJson, encodeCell]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [domainToTreeJson_encode, partyToTreeJson_encode, assetToTreeJson_encode]

theorem cellToTreeJson_valid (c : CellEnc) :
    TreeJson.Valid (cellToTreeJson c) := by
  dsimp [cellToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, domainToTreeJson_valid c.domain, partyToTreeJson_valid c.party,
          assetToTreeJson_valid c.asset, trivial⟩

def rightToTreeJson : RightEnc → TreeJson
  | .invoke => TreeJson.obj [("tag", TreeJson.str "invoke")]
  | .debit c => TreeJson.obj [("tag", TreeJson.str "debit"), ("cell", cellToTreeJson c)]
  | .changeSupply d a =>
    TreeJson.obj [
      ("tag", TreeJson.str "changeSupply"),
      ("domain", domainToTreeJson d),
      ("asset", assetToTreeJson a)
    ]

theorem rightToTreeJson_toJson (r : RightEnc) :
    (rightToTreeJson r).toJson = rightToJson r := by
  cases r with
  | invoke => rfl
  | debit c =>
    dsimp [rightToTreeJson, rightToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [cellToTreeJson_toJson]
  | changeSupply d a =>
    dsimp [rightToTreeJson, rightToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [domainToTreeJson_toJson, assetToTreeJson_toJson]

theorem rightToTreeJson_encode (r : RightEnc) :
    (rightToTreeJson r).encode = encodeRight r := by
  cases r with
  | invoke => rfl
  | debit c =>
    dsimp [rightToTreeJson, encodeRight]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [cellToTreeJson_encode]
    rfl
  | changeSupply d a =>
    dsimp [rightToTreeJson, encodeRight]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [domainToTreeJson_encode, assetToTreeJson_encode]
    rfl

theorem rightToTreeJson_valid (r : RightEnc) :
    TreeJson.Valid (rightToTreeJson r) := by
  cases r with
  | invoke =>
    dsimp [rightToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩
  | debit c =>
    dsimp [rightToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, cellToTreeJson_valid c, trivial⟩
  | changeSupply d a =>
    dsimp [rightToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, domainToTreeJson_valid d, assetToTreeJson_valid a, trivial⟩

def grantToTreeJson (g : GrantEnc) : TreeJson :=
  TreeJson.obj [
    ("holder", partyToTreeJson g.holder),
    ("domain", domainToTreeJson g.domain),
    ("operation", TreeJson.num g.operation),
    ("right", rightToTreeJson g.right)
  ]

theorem grantToTreeJson_toJson (g : GrantEnc) :
    (grantToTreeJson g).toJson = grantToJson g := by
  dsimp [grantToTreeJson, grantToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [partyToTreeJson_toJson, domainToTreeJson_toJson, rightToTreeJson_toJson]
  rfl

theorem grantToTreeJson_encode (g : GrantEnc) :
    (grantToTreeJson g).encode = encodeGrant g := by
  dsimp [grantToTreeJson, encodeGrant]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [partyToTreeJson_encode, domainToTreeJson_encode, rightToTreeJson_encode]
  rfl

theorem grantToTreeJson_valid (g : GrantEnc) :
    TreeJson.Valid (grantToTreeJson g) := by
  dsimp [grantToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, partyToTreeJson_valid g.holder, domainToTreeJson_valid g.domain,
          trivial, rightToTreeJson_valid g.right, trivial⟩

def capabilityToTreeJson (c : CapabilityEnc) : TreeJson :=
  TreeJson.obj [
    ("holder", partyToTreeJson c.holder),
    ("domain", domainToTreeJson c.domain),
    ("operation", TreeJson.num c.operation),
    ("right", rightToTreeJson c.right),
    ("live", TreeJson.bool c.live)
  ]

theorem capabilityToTreeJson_toJson (c : CapabilityEnc) :
    (capabilityToTreeJson c).toJson = capabilityToJson c := by
  dsimp [capabilityToTreeJson, capabilityToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [partyToTreeJson_toJson, domainToTreeJson_toJson, rightToTreeJson_toJson]
  rfl

theorem capabilityToTreeJson_encode (c : CapabilityEnc) :
    (capabilityToTreeJson c).encode = encodeCapability c := by
  dsimp [capabilityToTreeJson, encodeCapability]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [partyToTreeJson_encode, domainToTreeJson_encode, rightToTreeJson_encode]
  cases c.live <;> rfl

theorem capabilityToTreeJson_valid (c : CapabilityEnc) :
    TreeJson.Valid (capabilityToTreeJson c) := by
  dsimp [capabilityToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, partyToTreeJson_valid c.holder, domainToTreeJson_valid c.domain,
          trivial, rightToTreeJson_valid c.right, trivial, trivial⟩

def storeToTreeJson (s : StoreEnc) : TreeJson :=
  TreeJson.obj [("entries", TreeJson.arr (s.entries.map capabilityToTreeJson))]

theorem storeToTreeJson_toJson (s : StoreEnc) :
    (storeToTreeJson s).toJson = storeToJson s := by
  dsimp [storeToTreeJson, storeToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map]
  have h_map : (s.entries.map (fun x => (capabilityToTreeJson x).toJson)) = s.entries.map capabilityToJson := by
    simp only [List.map_inj_left]
    intro c _
    exact capabilityToTreeJson_toJson c
  rw [h_map]

theorem storeToTreeJson_encode (s : StoreEnc) :
    (storeToTreeJson s).encode = encodeStore s := by
  dsimp [storeToTreeJson, encodeStore]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map]
  have h_map : (s.entries.map (fun x => (capabilityToTreeJson x).encode)) = s.entries.map encodeCapability := by
    simp only [List.map_inj_left]
    intro c _
    exact capabilityToTreeJson_encode c
  rw [h_map]

theorem storeToTreeJson_valid (s : StoreEnc) (h_len : s.entries.length ≤ 4096) :
    TreeJson.Valid (storeToTreeJson s) := by
  dsimp [storeToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, valid_arr_map capabilityToTreeJson s.entries h_len (fun c _ => capabilityToTreeJson_valid c), trivial⟩

def stateToTreeJson (s : StateEnc) : TreeJson :=
  TreeJson.obj [("cells", TreeJson.arr (s.cells.map stateCellToTreeJson))]

theorem stateToTreeJson_toJson (s : StateEnc) :
    (stateToTreeJson s).toJson = stateToJson s := by
  dsimp [stateToTreeJson, stateToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map]
  have h_map : (s.cells.map (fun x => (stateCellToTreeJson x).toJson)) = s.cells.map stateCellToJson := by
    simp only [List.map_inj_left]
    intro c _
    exact stateCellToTreeJson_toJson c
  rw [h_map]

theorem stateToTreeJson_encode (s : StateEnc) :
    (stateToTreeJson s).encode = encodeState s := by
  dsimp [stateToTreeJson, encodeState]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map]
  have h_map : (s.cells.map (fun x => (stateCellToTreeJson x).encode)) = s.cells.map encodeStateCell := by
    simp only [List.map_inj_left]
    intro c _
    exact stateCellToTreeJson_encode c
  rw [h_map]

theorem stateToTreeJson_valid (s : StateEnc) (h_len : s.cells.length ≤ 4096) :
    TreeJson.Valid (stateToTreeJson s) := by
  dsimp [stateToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, valid_arr_map stateCellToTreeJson s.cells h_len (fun c _ => stateCellToTreeJson_valid c), trivial⟩

def contextToTreeJson (ctx : ContextEnc) : TreeJson :=
  TreeJson.obj [
    ("principal", partyToTreeJson ctx.principal),
    ("domain", domainToTreeJson ctx.domain)
  ]

theorem contextToTreeJson_toJson (ctx : ContextEnc) :
    (contextToTreeJson ctx).toJson = contextToJson ctx := by
  dsimp [contextToTreeJson, contextToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [partyToTreeJson_toJson, domainToTreeJson_toJson]

theorem contextToTreeJson_encode (ctx : ContextEnc) :
    (contextToTreeJson ctx).encode = encodeContext ctx := by
  dsimp [contextToTreeJson, encodeContext]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [partyToTreeJson_encode, domainToTreeJson_encode]

theorem contextToTreeJson_valid (ctx : ContextEnc) :
    TreeJson.Valid (contextToTreeJson ctx) := by
  dsimp [contextToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, partyToTreeJson_valid ctx.principal, domainToTreeJson_valid ctx.domain, trivial⟩

def observationToTreeJson (o : ObservationEnc) : TreeJson :=
  TreeJson.obj [
    ("value", packedValueFullToTreeJson o.value),
    ("timestamp", TreeJson.num o.timestamp)
  ]

theorem observationToTreeJson_toJson (o : ObservationEnc) :
    (observationToTreeJson o).toJson = observationToJson o := by
  dsimp [observationToTreeJson, observationToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [packedValueFullToTreeJson_toJson]
  rfl

theorem observationToTreeJson_encode (o : ObservationEnc) :
    (observationToTreeJson o).encode = encodeObservation o := by
  dsimp [observationToTreeJson, encodeObservation]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [packedValueFullToTreeJson_encode]
  rfl

theorem observationToTreeJson_valid (o : ObservationEnc) :
    TreeJson.Valid (observationToTreeJson o) := by
  dsimp [observationToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, packedValueFullToTreeJson_valid o.value, trivial, trivial⟩

def environmentEntryToTreeJson (e : EnvironmentEntryEnc) : TreeJson :=
  TreeJson.obj [
    ("key", observationKeyToTreeJson e.key),
    ("observation", observationToTreeJson e.observation)
  ]

theorem environmentEntryToTreeJson_toJson (e : EnvironmentEntryEnc) :
    (environmentEntryToTreeJson e).toJson = environmentEntryToJson e := by
  dsimp [environmentEntryToTreeJson, environmentEntryToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [observationKeyToTreeJson_toJson, observationToTreeJson_toJson]

theorem environmentEntryToTreeJson_encode (e : EnvironmentEntryEnc) :
    (environmentEntryToTreeJson e).encode = encodeEnvironmentEntry e := by
  dsimp [environmentEntryToTreeJson, encodeEnvironmentEntry]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [observationKeyToTreeJson_encode, observationToTreeJson_encode]

theorem environmentEntryToTreeJson_valid (e : EnvironmentEntryEnc) :
    TreeJson.Valid (environmentEntryToTreeJson e) := by
  dsimp [environmentEntryToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, observationKeyToTreeJson_valid e.key, observationToTreeJson_valid e.observation, trivial⟩

def environmentToTreeJson (env : EnvironmentEnc) : TreeJson :=
  TreeJson.obj [("entries", TreeJson.arr (env.entries.map environmentEntryToTreeJson))]

theorem environmentToTreeJson_toJson (env : EnvironmentEnc) :
    (environmentToTreeJson env).toJson = environmentToJson env := by
  dsimp [environmentToTreeJson, environmentToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map]
  have h_map : (env.entries.map (fun x => (environmentEntryToTreeJson x).toJson)) = env.entries.map environmentEntryToJson := by
    simp only [List.map_inj_left]
    intro e _
    exact environmentEntryToTreeJson_toJson e
  rw [h_map]

theorem environmentToTreeJson_encode (env : EnvironmentEnc) :
    (environmentToTreeJson env).encode = encodeEnvironment env := by
  dsimp [environmentToTreeJson, encodeEnvironment]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map]
  have h_map : (env.entries.map (fun x => (environmentEntryToTreeJson x).encode)) = env.entries.map encodeEnvironmentEntry := by
    simp only [List.map_inj_left]
    intro e _
    exact environmentEntryToTreeJson_encode e
  rw [h_map]

theorem environmentToTreeJson_valid (env : EnvironmentEnc) (h_len : env.entries.length ≤ 4096) :
    TreeJson.Valid (environmentToTreeJson env) := by
  dsimp [environmentToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, valid_arr_map environmentEntryToTreeJson env.entries h_len (fun e _ => environmentEntryToTreeJson_valid e), trivial⟩

def requestToTreeJson (r : RequestEnc) : TreeJson :=
  TreeJson.obj [
    ("operation", TreeJson.num r.operation),
    ("parties", TreeJson.arr (r.parties.map partyToTreeJson)),
    ("arguments", TreeJson.arr (r.arguments.map packedValueFullToTreeJson)),
    ("capabilityIds", TreeJson.arr (r.capabilityIds.map (fun x => TreeJson.num (x : Int)))),
    ("claimedActor", match r.claimedActor with | some a => partyToTreeJson a | none => TreeJson.null)
  ]

theorem requestToTreeJson_toJson (r : RequestEnc) :
    (requestToTreeJson r).toJson = requestToJson r := by
  dsimp [requestToTreeJson, requestToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map, toJsonList_map, toJsonList_map]
  have h_ps : (r.parties.map (fun x => (partyToTreeJson x).toJson)) = r.parties.map partyToJson := by
    simp only [List.map_inj_left]; intro p _; exact partyToTreeJson_toJson p
  have h_args : (r.arguments.map (fun x => (packedValueFullToTreeJson x).toJson)) = r.arguments.map packedValueFullToJson := by
    simp only [List.map_inj_left]; intro v _; exact packedValueFullToTreeJson_toJson v
  rw [h_ps, h_args]
  cases r.claimedActor with
  | none => rfl
  | some a =>
    dsimp
    rw [partyToTreeJson_toJson]

theorem requestToTreeJson_encode (r : RequestEnc) :
    (requestToTreeJson r).encode = encodeRequest r := by
  dsimp [requestToTreeJson, encodeRequest]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map, encode_arr_map, encode_arr_map]
  have h_ps : (r.parties.map (fun x => (partyToTreeJson x).encode)) = r.parties.map encodeParty := by
    simp only [List.map_inj_left]; intro p _; exact partyToTreeJson_encode p
  have h_args : (r.arguments.map (fun x => (packedValueFullToTreeJson x).encode)) = r.arguments.map encodePackedValue := by
    simp only [List.map_inj_left]; intro v _; exact packedValueFullToTreeJson_encode v
  have h_caps : (r.capabilityIds.map (fun x => (TreeJson.num (x : Int)).encode)) = r.capabilityIds.map toString := by
    simp only [List.map_inj_left]; intro x _; rfl
  rw [h_ps, h_args, h_caps]
  cases r.claimedActor with
  | none => rfl
  | some a =>
    dsimp
    rw [partyToTreeJson_encode]
    rfl

theorem requestToTreeJson_valid (r : RequestEnc)
    (h_ps : r.parties.length ≤ 4096)
    (h_args : r.arguments.length ≤ 4096)
    (h_caps : r.capabilityIds.length ≤ 4096) :
    TreeJson.Valid (requestToTreeJson r) := by
  dsimp [requestToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial,
          valid_arr_map partyToTreeJson r.parties h_ps (fun p _ => partyToTreeJson_valid p),
          valid_arr_map packedValueFullToTreeJson r.arguments h_args (fun v _ => packedValueFullToTreeJson_valid v),
          valid_arr_map (fun x => TreeJson.num (x : Int)) r.capabilityIds h_caps (fun _ _ => trivial),
          ?_, trivial⟩
  cases r.claimedActor with
  | none => trivial
  | some a => exact partyToTreeJson_valid a

def sourcePinToTreeJson (pin : SourcePinEnc) : TreeJson :=
  TreeJson.obj [
    ("git", TreeJson.str pin.git),
    ("lean_toolchain", TreeJson.str pin.lean_toolchain),
    ("mathlib_rev", TreeJson.str pin.mathlib_rev),
    ("checker_candidate", TreeJson.str pin.checker_candidate),
    ("compiler_record", match pin.compiler_record with | some r => TreeJson.str r | none => TreeJson.null),
    ("audit_record", match pin.audit_record with | some r => TreeJson.str r | none => TreeJson.null)
  ]

theorem sourcePinToTreeJson_toJson (pin : SourcePinEnc) :
    (sourcePinToTreeJson pin).toJson = sourcePinToJson pin := by
  dsimp [sourcePinToTreeJson, sourcePinToJson, TreeJson.toJson, TreeJson.toJsonObj]
  cases pin.compiler_record <;> cases pin.audit_record <;> rfl

theorem sourcePinToTreeJson_encode (pin : SourcePinEnc) :
    (sourcePinToTreeJson pin).encode = encodeSourcePin pin := by
  dsimp [sourcePinToTreeJson, encodeSourcePin]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  have h_git : (TreeJson.str pin.git).encode = escapeJsonString pin.git := escapeTreeString_eq_escapeJsonString pin.git
  have h_tc : (TreeJson.str pin.lean_toolchain).encode = escapeJsonString pin.lean_toolchain := escapeTreeString_eq_escapeJsonString pin.lean_toolchain
  have h_ml : (TreeJson.str pin.mathlib_rev).encode = escapeJsonString pin.mathlib_rev := escapeTreeString_eq_escapeJsonString pin.mathlib_rev
  have h_cc : (TreeJson.str pin.checker_candidate).encode = escapeJsonString pin.checker_candidate := escapeTreeString_eq_escapeJsonString pin.checker_candidate
  rw [h_git, h_tc, h_ml, h_cc]
  cases pin.compiler_record <;> cases pin.audit_record <;> dsimp [escapeTreeString_eq_escapeJsonString] <;> rfl

theorem sourcePinToTreeJson_valid (pin : SourcePinEnc) :
    TreeJson.Valid (sourcePinToTreeJson pin) := by
  dsimp [sourcePinToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, trivial, trivial, trivial, ?_, ?_, trivial⟩
  · cases pin.compiler_record <;> trivial
  · cases pin.audit_record <;> trivial

def typesEnumToTreeJson (t : TypesEnumEnc) : TreeJson :=
  TreeJson.obj [
    ("parties", TreeJson.arr (t.parties.map partyToTreeJson)),
    ("assets", TreeJson.arr (t.assets.map assetToTreeJson)),
    ("domains", TreeJson.arr (t.domains.map domainToTreeJson))
  ]

theorem typesEnumToTreeJson_toJson (t : TypesEnumEnc) :
    (typesEnumToTreeJson t).toJson = typesEnumToJson t := by
  dsimp [typesEnumToTreeJson, typesEnumToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map, toJsonList_map, toJsonList_map]
  have h_ps : (t.parties.map (fun x => (partyToTreeJson x).toJson)) = t.parties.map partyToJson := by
    simp profile_map; intro p _; exact partyToTreeJson_toJson p
  have h_as : (t.assets.map (fun x => (assetToTreeJson x).toJson)) = t.assets.map assetToJson := by
    simp profile_map; intro a _; exact assetToTreeJson_toJson a
  have h_ds : (t.domains.map (fun x => (domainToTreeJson x).toJson)) = t.domains.map domainToJson := by
    simp profile_map; intro d _; exact domainToTreeJson_toJson d
  rw [h_ps, h_as, h_ds]

theorem typesEnumToTreeJson_encode (t : TypesEnumEnc) :
    (typesEnumToTreeJson t).encode = encodeTypesEnum t := by
  dsimp [typesEnumToTreeJson, encodeTypesEnum]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map, encode_arr_map, encode_arr_map]
  have h_ps : (t.parties.map (fun x => (partyToTreeJson x).encode)) = t.parties.map encodeParty := by
    simp only [List.map_inj_left]; intro p _; exact partyToTreeJson_encode p
  have h_as : (t.assets.map (fun x => (assetToTreeJson x).encode)) = t.assets.map encodeAsset := by
    simp only [List.map_inj_left]; intro a _; exact assetToTreeJson_encode a
  have h_ds : (t.domains.map (fun x => (domainToTreeJson x).encode)) = t.domains.map encodeDomain := by
    simp only [List.map_inj_left]; intro d _; exact domainToTreeJson_encode d
  rw [h_ps, h_as, h_ds]

theorem typesEnumToTreeJson_valid (t : TypesEnumEnc)
    (h_ps : t.parties.length ≤ 4096)
    (h_as : t.assets.length ≤ 4096)
    (h_ds : t.domains.length ≤ 4096) :
    TreeJson.Valid (typesEnumToTreeJson t) := by
  dsimp [typesEnumToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide,
          valid_arr_map partyToTreeJson t.parties h_ps (fun p _ => partyToTreeJson_valid p),
          valid_arr_map assetToTreeJson t.assets h_as (fun a _ => assetToTreeJson_valid a),
          valid_arr_map domainToTreeJson t.domains h_ds (fun d _ => domainToTreeJson_valid d),
          trivial⟩

def libraryRefToTreeJson (lib : LibraryRefEnc) : TreeJson :=
  match lib.moduleName with
  | some m => TreeJson.obj [("theorem", TreeJson.str lib.theoremName), ("module", TreeJson.str m)]
  | none => TreeJson.obj [("theorem", TreeJson.str lib.theoremName)]

theorem libraryRefToTreeJson_toJson (lib : LibraryRefEnc) :
    (libraryRefToTreeJson lib).toJson = libraryRefToJson lib := by
  cases lib.moduleName with
  | none => rfl
  | some m => rfl

theorem libraryRefToTreeJson_encode (lib : LibraryRefEnc) :
    (libraryRefToTreeJson lib).encode = encodeLibraryRef lib := by
  dsimp [libraryRefToTreeJson, encodeLibraryRef]
  cases lib.moduleName with
  | none =>
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [escapeTreeString_eq_escapeJsonString]
  | some m =>
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [escapeTreeString_eq_escapeJsonString, escapeTreeString_eq_escapeJsonString]

theorem libraryRefToTreeJson_valid (lib : LibraryRefEnc) :
    TreeJson.Valid (libraryRefToTreeJson lib) := by
  dsimp [libraryRefToTreeJson]
  cases lib.moduleName with
  | none =>
    dsimp [TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩
  | some m =>
    dsimp [TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial, trivial⟩

def envReadToTreeJson : EnvReadEnc → TreeJson
  | .observation k => TreeJson.obj [("tag", TreeJson.str "observation"), ("key", observationKeyToTreeJson k)]
  | .currentTime => TreeJson.obj [("tag", TreeJson.str "currentTime")]

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

theorem templateToTreeJson_encode (t : TemplateEnc) :
    (templateToTreeJson t).encode = encodeTemplate t := by
  dsimp [templateToTreeJson, encodeTemplate]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map, encode_arr_map, encode_arr_map, encode_arr_map, encode_arr_map, encode_arr_map]
  have h_sig : (t.signature.map (fun x => (unitToTreeJson x).encode)) = t.signature.map encodeUnit := by
    simp only [List.map_inj_left]; intro u _; exact unitToTreeJson_encode u
  have h_del : (t.deltas.map (fun x => (cellDeltaToTreeJson x).encode)) = t.deltas.map encodeCellDelta := by
    simp only [List.map_inj_left]; intro d _; exact cellDeltaToTreeJson_encode d
  have h_sdel : (t.supplyDeltas.map (fun x => (supplyDeltaToTreeJson x).encode)) = t.supplyDeltas.map encodeSupplyDelta := by
    simp only [List.map_inj_left]; intro sd _; exact supplyDeltaToTreeJson_encode sd
  have h_srd : (t.stateReads.map (fun x => (packedCellRefToTreeJson x).encode)) = t.stateReads.map encodePackedCellRef := by
    simp only [List.map_inj_left]; intro sr _; exact packedCellRefToTreeJson_encode sr
  have h_erd : (t.envReads.map (fun x => (envReadToTreeJson x).encode)) = t.envReads.map encodeEnvRead := by
    simp only [List.map_inj_left]; intro er _; exact envReadToTreeJson_encode er
  have h_wrt : (t.writes.map (fun x => (packedCellRefToTreeJson x).encode)) = t.writes.map encodePackedCellRef := by
    simp only [List.map_inj_left]; intro w _; exact packedCellRefToTreeJson_encode w
  rw [h_sig, h_del, h_sdel, h_srd, h_erd, h_wrt]
  rw [domainToTreeJson_encode, exprToTreeJson_encode]
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

theorem registryEntryToTreeJson_encode (e : RegistryEntryEnc) :
    (registryEntryToTreeJson e).encode = encodeRegistryEntry e := by
  dsimp [registryEntryToTreeJson, encodeRegistryEntry]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
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

theorem registryToTreeJson_encode (r : RegistryEnc) :
    (registryToTreeJson r).encode = encodeRegistry r := by
  dsimp [registryToTreeJson, encodeRegistry]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map]
  have h_map : (r.entries.map (fun x => (registryEntryToTreeJson x).encode)) = r.entries.map encodeRegistryEntry := by
    simp only [List.map_inj_left]; intro e _; exact registryEntryToTreeJson_encode e
  rw [h_map]

theorem registryToTreeJson_valid (r : RegistryEnc)
    (h_r : r.entries.length ≤ 4096)
    (h_entries : ∀ e ∈ r.entries,
      e.template.signature.length ≤ 4096 ∧
      e.template.deltas.length ≤ 4096 ∧
      e.template.supplyDeltas.length ≤ 4096 ∧
      e.template.stateReads.length ≤ 4096 ∧
      e.template.envReads.length ≤ 4096 ∧
      e.template.writes.length ≤ 4096) :
    TreeJson.Valid (registryToTreeJson r) := by
  dsimp [registryToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, valid_arr_map registryEntryToTreeJson r.entries h_r ?_, trivial⟩
  intro e he
  rcases h_entries e he with ⟨h_sig, h_del, h_sdel, h_srd, h_erd, h_wrt⟩
  exact registryEntryToTreeJson_valid e h_sig h_del h_sdel h_srd h_erd h_wrt

def typedExecutePayloadToTreeJson (p : TypedExecutePayloadEnc) : TreeJson :=
  TreeJson.obj [
    ("registry", registryToTreeJson p.registry),
    ("store", storeToTreeJson p.store),
    ("ctx", contextToTreeJson p.ctx),
    ("env", environmentToTreeJson p.env),
    ("now", TreeJson.num p.now),
    ("request", requestToTreeJson p.request),
    ("state", stateToTreeJson p.state)
  ]

theorem typedExecutePayloadToTreeJson_encode (p : TypedExecutePayloadEnc) :
    (typedExecutePayloadToTreeJson p).encode = encodeTypedExecutePayload p := by
  dsimp [typedExecutePayloadToTreeJson, encodeTypedExecutePayload]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [registryToTreeJson_encode, storeToTreeJson_encode, contextToTreeJson_encode,
      environmentToTreeJson_encode, requestToTreeJson_encode, stateToTreeJson_encode]
  rfl

theorem typedExecutePayloadToTreeJson_valid (p : TypedExecutePayloadEnc)
    (h_store : p.store.entries.length ≤ 4096)
    (h_env : p.env.entries.length ≤ 4096)
    (h_ps : p.request.parties.length ≤ 4096)
    (h_args : p.request.arguments.length ≤ 4096)
    (h_caps : p.request.capabilityIds.length ≤ 4096)
    (h_state : p.state.cells.length ≤ 4096)
    (h_r : p.registry.entries.length ≤ 4096)
    (h_entries : ∀ e ∈ p.registry.entries,
      e.template.signature.length ≤ 4096 ∧
      e.template.deltas.length ≤ 4096 ∧
      e.template.supplyDeltas.length ≤ 4096 ∧
      e.template.stateReads.length ≤ 4096 ∧
      e.template.envReads.length ≤ 4096 ∧
      e.template.writes.length ≤ 4096) :
    TreeJson.Valid (typedExecutePayloadToTreeJson p) := by
  dsimp [typedExecutePayloadToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide,
          registryToTreeJson_valid p.registry h_r h_entries,
          storeToTreeJson_valid p.store h_store,
          contextToTreeJson_valid p.ctx,
          environmentToTreeJson_valid p.env h_env,
          trivial,
          requestToTreeJson_valid p.request h_ps h_args h_caps,
          stateToTreeJson_valid p.state h_state,
          trivial⟩

