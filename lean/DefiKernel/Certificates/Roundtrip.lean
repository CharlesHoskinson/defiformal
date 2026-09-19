import DefiKernel.Certificates.Correspondence
import DefiKernel.Certificates.DepthBridge

namespace DefiKernel.Certificates

set_option linter.style.longLine false

open Lean

/-! # Universal Roundtrip Module for P19 Typed/Sequential Certificates
    Provides TreeJson structural representations, encoding/toJson lemmas,
    and parser roundtrip proofs for all accepted certificate forms. -/

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

/-- Explicit Nat-to-TreeJson mapping avoiding ambiguous List coercions. -/
def natToTreeJson (n : Nat) : TreeJson := TreeJson.num (Int.ofNat n)

theorem natToTreeJson_encode (n : Nat) : (natToTreeJson n).encode = toString n := rfl

theorem natToTreeJson_toJson (n : Nat) : (natToTreeJson n).toJson = Json.num (JsonNumber.fromNat n) := rfl

theorem natToTreeJson_valid (n : Nat) : TreeJson.Valid (natToTreeJson n) := trivial

/-- Packed value unit-and-value object representation in TreeJson. -/
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
    dsimp [packedValueToTreeJson]
    rw [h]
    dsimp
    cases v.valBool <;> rfl
  | numeric nu =>
    dsimp [packedValueToTreeJson]
    rw [h]
    dsimp
    rw [ratToTreeJson_encode]
    rfl

theorem packedValueFullToTreeJson_valid (v : PackedValueEnc) :
    TreeJson.Valid (packedValueFullToTreeJson v) := by
  dsimp [packedValueFullToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, unitToTreeJson_valid v.unit, ?_, trivial⟩
  cases h : v.unit with
  | bool =>
    dsimp [packedValueToTreeJson]
    rw [h]
    dsimp
    cases v.valBool <;> trivial
  | numeric nu =>
    dsimp [packedValueToTreeJson]
    rw [h]
    dsimp
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
    ("operation", natToTreeJson g.operation),
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
  rw [partyToTreeJson_encode, domainToTreeJson_encode, rightToTreeJson_encode, natToTreeJson_encode]

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
    ("operation", natToTreeJson c.operation),
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
  rw [partyToTreeJson_encode, domainToTreeJson_encode, rightToTreeJson_encode, natToTreeJson_encode]
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
    simp only [List.map_inj_left]; intro c _; exact capabilityToTreeJson_toJson c
  rw [h_map]

theorem storeToTreeJson_encode (s : StoreEnc) :
    (storeToTreeJson s).encode = encodeStore s := by
  dsimp [storeToTreeJson, encodeStore]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map]
  have h_map : (s.entries.map (fun x => (capabilityToTreeJson x).encode)) = s.entries.map encodeCapability := by
    simp only [List.map_inj_left]; intro c _; exact capabilityToTreeJson_encode c
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
    simp only [List.map_inj_left]; intro c _; exact stateCellToTreeJson_toJson c
  rw [h_map]

theorem stateToTreeJson_encode (s : StateEnc) :
    (stateToTreeJson s).encode = encodeState s := by
  dsimp [stateToTreeJson, encodeState]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map]
  have h_map : (s.cells.map (fun x => (stateCellToTreeJson x).encode)) = s.cells.map encodeStateCell := by
    simp only [List.map_inj_left]; intro c _; exact stateCellToTreeJson_encode c
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
    ("timestamp", natToTreeJson o.timestamp)
  ]

theorem observationToTreeJson_toJson (o : ObservationEnc) :
    (observationToTreeJson o).toJson = observationToJson o := by
  dsimp [observationToTreeJson, observationToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [packedValueFullToTreeJson_toJson, natToTreeJson_toJson]

theorem observationToTreeJson_encode (o : ObservationEnc) :
    (observationToTreeJson o).encode = encodeObservation o := by
  dsimp [observationToTreeJson, encodeObservation]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [packedValueFullToTreeJson_encode, natToTreeJson_encode]


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
    simp only [List.map_inj_left]; intro e _; exact environmentEntryToTreeJson_toJson e
  rw [h_map]

theorem environmentToTreeJson_encode (env : EnvironmentEnc) :
    (environmentToTreeJson env).encode = encodeEnvironment env := by
  dsimp [environmentToTreeJson, encodeEnvironment]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map]
  have h_map : (env.entries.map (fun x => (environmentEntryToTreeJson x).encode)) = env.entries.map encodeEnvironmentEntry := by
    simp only [List.map_inj_left]; intro e _; exact environmentEntryToTreeJson_encode e
  rw [h_map]

theorem environmentToTreeJson_valid (env : EnvironmentEnc) (h_len : env.entries.length ≤ 4096) :
    TreeJson.Valid (environmentToTreeJson env) := by
  dsimp [environmentToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, valid_arr_map environmentEntryToTreeJson env.entries h_len (fun e _ => environmentEntryToTreeJson_valid e), trivial⟩

def requestToTreeJson (r : RequestEnc) : TreeJson :=
  TreeJson.obj [
    ("operation", natToTreeJson r.operation),
    ("parties", TreeJson.arr (r.parties.map partyToTreeJson)),
    ("arguments", TreeJson.arr (r.arguments.map packedValueFullToTreeJson)),
    ("capabilityIds", TreeJson.arr (r.capabilityIds.map natToTreeJson)),
    ("claimedActor", match r.claimedActor with | some a => partyToTreeJson a | none => TreeJson.null)
  ]

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
  have h_caps : (r.capabilityIds.map (fun x => (natToTreeJson x).encode)) = r.capabilityIds.map toString := by
    simp only [List.map_inj_left]; intro x _; exact natToTreeJson_encode x
  rw [h_ps, h_args, h_caps, natToTreeJson_encode]
  cases r.claimedActor with
  | none => rfl
  | some a =>
    dsimp
    rw [partyToTreeJson_encode]

theorem decodeRequest_requestToTreeJson (r : RequestEnc) (h_can : RequestCanonical r) :
    decodeRequest (requestToTreeJson r).toJson = .ok r := by
  cases r with | mk op parties args caps actor =>
  dsimp [requestToTreeJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map, toJsonList_map, toJsonList_map]
  have h_ps : (parties.map (fun x => (partyToTreeJson x).toJson)) = parties.map partyToJson := by
    simp only [List.map_inj_left]; intro p _; exact partyToTreeJson_toJson p
  have h_args : (args.map (fun x => (packedValueFullToTreeJson x).toJson)) = args.map packedValueFullToJson := by
    simp only [List.map_inj_left]; intro v _; exact packedValueFullToTreeJson_toJson v
  have h_caps : (caps.map (fun x => (natToTreeJson x).toJson)) = caps.map natToJson := by
    simp only [List.map_inj_left]; intro c _; exact natToTreeJson_toJson c
  rw [h_ps, h_args, h_caps, natToTreeJson_toJson]
  cases actor with
  | none =>
    simp only [TreeJson.toJson]
    have h_order : decodeRequest (Json.mkObj [
        ("operation", Json.num (JsonNumber.fromNat op)),
        ("parties", Json.arr (parties.map partyToJson).toArray),
        ("arguments", Json.arr (args.map packedValueFullToJson).toArray),
        ("capabilityIds", Json.arr (caps.map natToJson).toArray),
        ("claimedActor", Json.null)]) =
      decodeRequest (Json.mkObj [
        ("arguments", Json.arr (args.map packedValueFullToJson).toArray),
        ("capabilityIds", Json.arr (caps.map natToJson).toArray),
        ("claimedActor", Json.null),
        ("operation", Json.num (JsonNumber.fromNat op)),
        ("parties", Json.arr (parties.map partyToJson).toArray)]) := by rfl
    rw [h_order]
    have h_req : decodeRequest (requestToJson ⟨op, parties, args, caps, none⟩) = .ok ⟨op, parties, args, caps, none⟩ :=
      decodeRequest_requestToJson ⟨op, parties, args, caps, none⟩ h_can
    exact h_req
  | some a =>
    have h_a : (partyToTreeJson a).toJson = partyToJson a := partyToTreeJson_toJson a
    dsimp
    rw [h_a]
    have h_order : decodeRequest (Json.mkObj [
        ("operation", Json.num (JsonNumber.fromNat op)),
        ("parties", Json.arr (parties.map partyToJson).toArray),
        ("arguments", Json.arr (args.map packedValueFullToJson).toArray),
        ("capabilityIds", Json.arr (caps.map natToJson).toArray),
        ("claimedActor", partyToJson a)]) =
      decodeRequest (Json.mkObj [
        ("arguments", Json.arr (args.map packedValueFullToJson).toArray),
        ("capabilityIds", Json.arr (caps.map natToJson).toArray),
        ("claimedActor", partyToJson a),
        ("operation", Json.num (JsonNumber.fromNat op)),
        ("parties", Json.arr (parties.map partyToJson).toArray)]) := by rfl
    rw [h_order]
    have h_req : decodeRequest (requestToJson ⟨op, parties, args, caps, some a⟩) = .ok ⟨op, parties, args, caps, some a⟩ :=
      decodeRequest_requestToJson ⟨op, parties, args, caps, some a⟩ h_can
    exact h_req

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
          valid_arr_map natToTreeJson r.capabilityIds h_caps (fun _ _ => trivial),
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
  dsimp [List.map, TreeJson.encode]
  have h_git : escapeTreeString pin.git = escapeJsonString pin.git := escapeTreeString_eq_escapeJsonString pin.git
  have h_tc : escapeTreeString pin.lean_toolchain = escapeJsonString pin.lean_toolchain := escapeTreeString_eq_escapeJsonString pin.lean_toolchain
  have h_ml : escapeTreeString pin.mathlib_rev = escapeJsonString pin.mathlib_rev := escapeTreeString_eq_escapeJsonString pin.mathlib_rev
  have h_cc : escapeTreeString pin.checker_candidate = escapeJsonString pin.checker_candidate := escapeTreeString_eq_escapeJsonString pin.checker_candidate
  rw [h_git, h_tc, h_ml, h_cc]
  cases pin.compiler_record <;> cases pin.audit_record <;> dsimp [TreeJson.encode] <;> try rw [escapeTreeString_eq_escapeJsonString] <;> rfl

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
    simp only [List.map_inj_left]; intro p _; exact partyToTreeJson_toJson p
  have h_as : (t.assets.map (fun x => (assetToTreeJson x).toJson)) = t.assets.map assetToJson := by
    simp only [List.map_inj_left]; intro a _; exact assetToTreeJson_toJson a
  have h_ds : (t.domains.map (fun x => (domainToTreeJson x).toJson)) = t.domains.map domainToJson := by
    simp only [List.map_inj_left]; intro d _; exact domainToTreeJson_toJson d
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

theorem libraryRefToTreeJson_encode (lib : LibraryRefEnc) :
    (libraryRefToTreeJson lib).encode = encodeLibraryRef lib := by
  dsimp [libraryRefToTreeJson, encodeLibraryRef]
  cases h : lib.moduleName with
  | none =>
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map, TreeJson.encode]
    rw [escapeTreeString_eq_escapeJsonString]
  | some m =>
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map, TreeJson.encode]
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

def worldToTreeJson (w : WorldEnc) : TreeJson :=
  TreeJson.obj [("state", stateToTreeJson w.state), ("capabilities", storeToTreeJson w.capabilities)]

theorem worldToTreeJson_encode (w : WorldEnc) :
    (worldToTreeJson w).encode = encodeWorld w := by
  dsimp [worldToTreeJson, encodeWorld]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [stateToTreeJson_encode, storeToTreeJson_encode]

def boundaryToTreeJson (b : BoundaryEnc) : TreeJson :=
  TreeJson.obj [("ctx", contextToTreeJson b.ctx), ("env", environmentToTreeJson b.env), ("now", natToTreeJson b.now)]

theorem boundaryToTreeJson_encode (b : BoundaryEnc) :
    (boundaryToTreeJson b).encode = encodeBoundary b := by
  dsimp [boundaryToTreeJson, encodeBoundary]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [contextToTreeJson_encode, environmentToTreeJson_encode, natToTreeJson_encode]

def envelopeToTreeJson (env : EnvelopeEnc) (payload : TreeJson) : TreeJson :=
  TreeJson.obj [
    ("schema_version", natToTreeJson env.schema_version),
    ("mode", TreeJson.str env.mode),
    ("source_pin", sourcePinToTreeJson env.source_pin),
    ("audit_roots", TreeJson.arr (env.audit_roots.map TreeJson.str)),
    ("types", typesEnumToTreeJson env.types),
    ("assumptions", TreeJson.arr (env.assumptions.map TreeJson.str)),
    ("invariants", TreeJson.arr (env.invariants.map TreeJson.str)),
    ("libraries", TreeJson.arr (env.libraries.map libraryRefToTreeJson)),
    ("source_map", sourceMapToTreeJson env.source_map),
    ("payload", payload),
    ("claimed_judgments", TreeJson.arr (env.claimed_judgments.map TreeJson.str)),
    ("claimed_next_state", match env.claimed_next_state with | some w => worldToTreeJson w | none => TreeJson.null),
    ("require_library_discharge", TreeJson.bool env.require_library_discharge),
    ("require_invariant_discharge", TreeJson.bool env.require_invariant_discharge)
  ]

theorem envelopeToTreeJson_encode (env : EnvelopeEnc) (payload : TreeJson)
    (h_sm : SourceMapSorted env.source_map) :
    (envelopeToTreeJson env payload).encode = encodeEnvelope env payload.encode := by
  dsimp [envelopeToTreeJson, encodeEnvelope]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_str, encode_arr_str, encode_arr_str, encode_arr_str, encode_arr_map]
  have h_libs : (env.libraries.map (fun x => (libraryRefToTreeJson x).encode)) = env.libraries.map encodeLibraryRef := by
    simp only [List.map_inj_left]; intro lib _; exact libraryRefToTreeJson_encode lib
  rw [h_libs]
  rw [sourceMapToTreeJson_encode env.source_map h_sm]
  rw [sourcePinToTreeJson_encode, typesEnumToTreeJson_encode, natToTreeJson_encode]
  have h_mode : (TreeJson.str env.mode).encode = escapeJsonString env.mode := escapeTreeString_eq_escapeJsonString env.mode
  rw [h_mode]
  cases env.claimed_next_state with
  | none =>
    cases env.require_library_discharge <;> cases env.require_invariant_discharge <;> rfl
  | some w =>
    rw [worldToTreeJson_encode]
    cases env.require_library_discharge <;> cases env.require_invariant_discharge <;> rfl

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

def envReadToTreeJson : EnvReadEnc → TreeJson
  | .observation k => TreeJson.obj [("tag", TreeJson.str "observation"), ("key", observationKeyToTreeJson k)]
  | .currentTime => TreeJson.obj [("tag", TreeJson.str "currentTime")]

theorem envReadToTreeJson_encode (e : EnvReadEnc) :
    (envReadToTreeJson e).encode = encodeEnvRead e := by
  cases e with
  | observation k =>
    dsimp [envReadToTreeJson, encodeEnvRead]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map, TreeJson.encode]
    rw [observationKeyToTreeJson_encode]
    rfl
  | currentTime => rfl

theorem envReadToTreeJson_valid (e : EnvReadEnc) :
    TreeJson.Valid (envReadToTreeJson e) := by
  cases e with
  | observation k =>
    dsimp [envReadToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, observationKeyToTreeJson_valid k, trivial⟩
  | currentTime =>
    dsimp [envReadToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩

def templateToTreeJson (t : TemplateEnc) : TreeJson :=
  TreeJson.obj [
    ("signature", TreeJson.arr (t.signature.map unitToTreeJson)),
    ("domain", domainToTreeJson t.domain),
    ("partyArity", natToTreeJson t.partyArity),
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
  rw [domainToTreeJson_encode, exprToTreeJson_encode, natToTreeJson_encode]

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
  TreeJson.obj [("id", natToTreeJson e.id), ("template", templateToTreeJson e.template)]

theorem registryEntryToTreeJson_encode (e : RegistryEntryEnc) :
    (registryEntryToTreeJson e).encode = encodeRegistryEntry e := by
  dsimp [registryEntryToTreeJson, encodeRegistryEntry]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [natToTreeJson_encode, templateToTreeJson_encode]

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

def domainAdminToTreeJson (d : DomainAdminEnc) : TreeJson :=
  TreeJson.obj [("domain", domainToTreeJson d.domain), ("party", partyToTreeJson d.party)]

theorem domainAdminToTreeJson_encode (d : DomainAdminEnc) :
    (domainAdminToTreeJson d).encode = encodeDomainAdmin d := by
  dsimp [domainAdminToTreeJson, encodeDomainAdmin]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [domainToTreeJson_encode, partyToTreeJson_encode]

theorem domainAdminToTreeJson_valid (d : DomainAdminEnc) :
    TreeJson.Valid (domainAdminToTreeJson d) := by
  dsimp [domainAdminToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, domainToTreeJson_valid d.domain, partyToTreeJson_valid d.party, trivial⟩

def inputPortToTreeJson (p : InputPortEnc) : TreeJson :=
  TreeJson.obj [("id", natToTreeJson p.id), ("unit", unitToTreeJson p.unit)]

theorem inputPortToTreeJson_encode (p : InputPortEnc) :
    (inputPortToTreeJson p).encode = encodeInputPort p := by
  dsimp [inputPortToTreeJson, encodeInputPort]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [natToTreeJson_encode, unitToTreeJson_encode]

theorem inputPortToTreeJson_valid (p : InputPortEnc) :
    TreeJson.Valid (inputPortToTreeJson p) := by
  dsimp [inputPortToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, unitToTreeJson_valid p.unit, trivial⟩

def outputPortToTreeJson (p : OutputPortEnc) : TreeJson :=
  TreeJson.obj [("id", natToTreeJson p.id), ("cell", cellToTreeJson p.cell)]

theorem outputPortToTreeJson_encode (p : OutputPortEnc) :
    (outputPortToTreeJson p).encode = encodeOutputPort p := by
  dsimp [outputPortToTreeJson, encodeOutputPort]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [natToTreeJson_encode, cellToTreeJson_encode]

theorem outputPortToTreeJson_valid (p : OutputPortEnc) :
    TreeJson.Valid (outputPortToTreeJson p) := by
  dsimp [outputPortToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, cellToTreeJson_valid p.cell, trivial⟩

def resourcePortToTreeJson (p : ResourcePortEnc) : TreeJson :=
  TreeJson.obj [
    ("id", natToTreeJson p.id),
    ("cell", cellToTreeJson p.cell),
    ("writable", TreeJson.bool p.writable)
  ]

theorem resourcePortToTreeJson_encode (p : ResourcePortEnc) :
    (resourcePortToTreeJson p).encode = encodeResourcePort p := by
  dsimp [resourcePortToTreeJson, encodeResourcePort]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [natToTreeJson_encode, cellToTreeJson_encode]
  cases p.writable <;> rfl

theorem resourcePortToTreeJson_valid (p : ResourcePortEnc) :
    TreeJson.Valid (resourcePortToTreeJson p) := by
  dsimp [resourcePortToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, cellToTreeJson_valid p.cell, trivial, trivial⟩

def qualifiedPortToTreeJson (qp : QualifiedPortEnc) : TreeJson :=
  TreeJson.obj [("component", natToTreeJson qp.component), ("port", natToTreeJson qp.port)]

theorem qualifiedPortToTreeJson_encode (qp : QualifiedPortEnc) :
    (qualifiedPortToTreeJson qp).encode = encodeQualifiedPort qp := by
  dsimp [qualifiedPortToTreeJson, encodeQualifiedPort]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [natToTreeJson_encode, natToTreeJson_encode]

theorem qualifiedPortToTreeJson_valid (qp : QualifiedPortEnc) :
    TreeJson.Valid (qualifiedPortToTreeJson qp) := by
  dsimp [qualifiedPortToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, trivial, trivial⟩

def resourceImportToTreeJson (ri : ResourceImportEnc) : TreeJson :=
  TreeJson.obj [
    ("source", qualifiedPortToTreeJson ri.source),
    ("cell", cellToTreeJson ri.cell),
    ("writable", TreeJson.bool ri.writable)
  ]

theorem resourceImportToTreeJson_encode (ri : ResourceImportEnc) :
    (resourceImportToTreeJson ri).encode = encodeResourceImport ri := by
  dsimp [resourceImportToTreeJson, encodeResourceImport]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [qualifiedPortToTreeJson_encode, cellToTreeJson_encode]
  cases ri.writable <;> rfl

theorem resourceImportToTreeJson_valid (ri : ResourceImportEnc) :
    TreeJson.Valid (resourceImportToTreeJson ri) := by
  dsimp [resourceImportToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, qualifiedPortToTreeJson_valid ri.source, cellToTreeJson_valid ri.cell, trivial, trivial⟩

def operationInterfaceToTreeJson (op : OperationInterfaceEnc) : TreeJson :=
  TreeJson.obj [
    ("operation", natToTreeJson op.operation),
    ("inputs", TreeJson.arr (op.inputs.map inputPortToTreeJson)),
    ("outputs", TreeJson.arr (op.outputs.map outputPortToTreeJson))
  ]

theorem operationInterfaceToTreeJson_encode (op : OperationInterfaceEnc) :
    (operationInterfaceToTreeJson op).encode = encodeOperationInterface op := by
  dsimp [operationInterfaceToTreeJson, encodeOperationInterface]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map, encode_arr_map]
  have h_ins : (op.inputs.map (fun x => (inputPortToTreeJson x).encode)) = op.inputs.map encodeInputPort := by
    simp only [List.map_inj_left]; intro x _; exact inputPortToTreeJson_encode x
  have h_outs : (op.outputs.map (fun x => (outputPortToTreeJson x).encode)) = op.outputs.map encodeOutputPort := by
    simp only [List.map_inj_left]; intro x _; exact outputPortToTreeJson_encode x
  rw [h_ins, h_outs, natToTreeJson_encode]

def componentToTreeJson (c : ComponentEnc) : TreeJson :=
  TreeJson.obj [
    ("id", natToTreeJson c.id),
    ("privateCells", TreeJson.arr (c.privateCells.map cellToTreeJson)),
    ("exports", TreeJson.arr (c.exports.map resourcePortToTreeJson)),
    ("imports", TreeJson.arr (c.imports.map resourceImportToTreeJson)),
    ("operations", TreeJson.arr (c.operations.map operationInterfaceToTreeJson))
  ]

theorem componentToTreeJson_encode (c : ComponentEnc) :
    (componentToTreeJson c).encode = encodeComponent c := by
  dsimp [componentToTreeJson, encodeComponent]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map, encode_arr_map, encode_arr_map, encode_arr_map]
  have h_privs : (c.privateCells.map (fun x => (cellToTreeJson x).encode)) = c.privateCells.map encodeCell := by
    simp only [List.map_inj_left]; intro x _; exact cellToTreeJson_encode x
  have h_exps : (c.exports.map (fun x => (resourcePortToTreeJson x).encode)) = c.exports.map encodeResourcePort := by
    simp only [List.map_inj_left]; intro x _; exact resourcePortToTreeJson_encode x
  have h_imps : (c.imports.map (fun x => (resourceImportToTreeJson x).encode)) = c.imports.map encodeResourceImport := by
    simp only [List.map_inj_left]; intro x _; exact resourceImportToTreeJson_encode x
  have h_ops : (c.operations.map (fun x => (operationInterfaceToTreeJson x).encode)) = c.operations.map encodeOperationInterface := by
    simp only [List.map_inj_left]; intro x _; exact operationInterfaceToTreeJson_encode x
  rw [h_privs, h_exps, h_imps, h_ops, natToTreeJson_encode]

def configToTreeJson (c : ConfigEnc) : TreeJson :=
  TreeJson.obj [
    ("registry", registryToTreeJson c.registry),
    ("domainAdmin", TreeJson.arr (c.domainAdmin.map domainAdminToTreeJson)),
    ("catalog", TreeJson.arr (c.catalog.map componentToTreeJson))
  ]

theorem configToTreeJson_encode (c : ConfigEnc) :
    (configToTreeJson c).encode = encodeConfig c := by
  dsimp [configToTreeJson, encodeConfig]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map, encode_arr_map]
  have h_adm : (c.domainAdmin.map (fun x => (domainAdminToTreeJson x).encode)) = c.domainAdmin.map encodeDomainAdmin := by
    simp only [List.map_inj_left]; intro x _; exact domainAdminToTreeJson_encode x
  have h_cat : (c.catalog.map (fun x => (componentToTreeJson x).encode)) = c.catalog.map encodeComponent := by
    simp only [List.map_inj_left]; intro x _; exact componentToTreeJson_encode x
  rw [h_adm, h_cat, registryToTreeJson_encode]

def inputSourceToTreeJson : InputSourceEnc → TreeJson
  | .literal v => TreeJson.obj [("tag", TreeJson.str "literal"), ("value", packedValueFullToTreeJson v)]
  | .priorOutput step port =>
    TreeJson.obj [
      ("tag", TreeJson.str "priorOutput"),
      ("step", natToTreeJson step),
      ("port", qualifiedPortToTreeJson port)
    ]

theorem inputSourceToTreeJson_encode (i : InputSourceEnc) :
    (inputSourceToTreeJson i).encode = encodeInputSource i := by
  cases i with
  | literal v =>
    dsimp [inputSourceToTreeJson, encodeInputSource]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map, TreeJson.encode]
    rw [packedValueFullToTreeJson_encode]
    rfl
  | priorOutput step port =>
    dsimp [inputSourceToTreeJson, encodeInputSource]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map, TreeJson.encode]
    rw [natToTreeJson_encode, qualifiedPortToTreeJson_encode]
    rfl

def invocationToTreeJson (inv : InvocationEnc) : TreeJson :=
  TreeJson.obj [
    ("component", natToTreeJson inv.component),
    ("operation", natToTreeJson inv.operation),
    ("parties", TreeJson.arr (inv.parties.map partyToTreeJson)),
    ("inputs", TreeJson.arr (inv.inputs.map inputSourceToTreeJson)),
    ("capabilityIds", TreeJson.arr (inv.capabilityIds.map natToTreeJson)),
    ("claimedActor", match inv.claimedActor with | some a => partyToTreeJson a | none => TreeJson.null)
  ]

theorem invocationToTreeJson_encode (inv : InvocationEnc) :
    (invocationToTreeJson inv).encode = encodeInvocation inv := by
  dsimp [invocationToTreeJson, encodeInvocation]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [encode_arr_map, encode_arr_map, encode_arr_map]
  have h_ps : (inv.parties.map (fun x => (partyToTreeJson x).encode)) = inv.parties.map encodeParty := by
    simp only [List.map_inj_left]; intro x _; exact partyToTreeJson_encode x
  have h_ins : (inv.inputs.map (fun x => (inputSourceToTreeJson x).encode)) = inv.inputs.map encodeInputSource := by
    simp only [List.map_inj_left]; intro x _; exact inputSourceToTreeJson_encode x
  have h_caps : (inv.capabilityIds.map (fun x => (natToTreeJson x).encode)) = inv.capabilityIds.map toString := by
    simp only [List.map_inj_left]; intro x _; exact natToTreeJson_encode x
  rw [h_ps, h_ins, h_caps, natToTreeJson_encode, natToTreeJson_encode]
  cases inv.claimedActor with
  | none => rfl
  | some a =>
    dsimp
    rw [partyToTreeJson_encode]

def stepToTreeJson : StepEnc → TreeJson
  | .invoke inv => TreeJson.obj [("tag", TreeJson.str "invoke"), ("invocation", invocationToTreeJson inv)]
  | .issue g => TreeJson.obj [("tag", TreeJson.str "issue"), ("grant", grantToTreeJson g)]
  | .revoke id => TreeJson.obj [("tag", TreeJson.str "revoke"), ("id", natToTreeJson id)]
  | .unsupported tag => TreeJson.obj [("tag", TreeJson.str tag)]

theorem stepToTreeJson_encode (s : StepEnc) (h_can : StepCanonical s) :
    (stepToTreeJson s).encode = encodeStep s := by
  cases s with
  | invoke inv =>
    dsimp [stepToTreeJson, encodeStep]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map, TreeJson.encode]
    rw [invocationToTreeJson_encode]
    rfl
  | issue g =>
    dsimp [stepToTreeJson, encodeStep]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map, TreeJson.encode]
    rw [grantToTreeJson_encode]
    rfl
  | revoke id =>
    dsimp [stepToTreeJson, encodeStep]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map, TreeJson.encode]
    rw [natToTreeJson_encode]
    rfl
  | unsupported tag =>
    cases h_can

def outputObservationToTreeJson (o : OutputObservationEnc) : TreeJson :=
  TreeJson.obj [
    ("step", natToTreeJson o.step),
    ("port", qualifiedPortToTreeJson o.port),
    ("value", packedValueFullToTreeJson o.value)
  ]

theorem outputObservationToTreeJson_encode (o : OutputObservationEnc) :
    (outputObservationToTreeJson o).encode = encodeOutputObservation o := by
  dsimp [outputObservationToTreeJson, encodeOutputObservation]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [natToTreeJson_encode, qualifiedPortToTreeJson_encode, packedValueFullToTreeJson_encode]

def typedExecutePayloadToTreeJson (p : TypedExecutePayloadEnc) : TreeJson :=
  TreeJson.obj [
    ("registry", registryToTreeJson p.registry),
    ("store", storeToTreeJson p.store),
    ("ctx", contextToTreeJson p.ctx),
    ("env", environmentToTreeJson p.env),
    ("now", natToTreeJson p.now),
    ("request", requestToTreeJson p.request),
    ("state", stateToTreeJson p.state)
  ]

theorem typedExecutePayloadToTreeJson_encode (p : TypedExecutePayloadEnc) :
    (typedExecutePayloadToTreeJson p).encode = encodeTypedExecutePayload p := by
  dsimp [typedExecutePayloadToTreeJson, encodeTypedExecutePayload]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [registryToTreeJson_encode, storeToTreeJson_encode, contextToTreeJson_encode,
      environmentToTreeJson_encode, natToTreeJson_encode, requestToTreeJson_encode,
      stateToTreeJson_encode]

def compositionStepPayloadToTreeJson (p : CompositionStepPayloadEnc) : TreeJson :=
  TreeJson.obj [
    ("config", configToTreeJson p.config),
    ("boundary", boundaryToTreeJson p.boundary),
    ("index", natToTreeJson p.index),
    ("history", TreeJson.arr (p.history.map outputObservationToTreeJson)),
    ("step", stepToTreeJson p.step),
    ("pre", worldToTreeJson p.pre)
  ]

theorem compositionStepPayloadToTreeJson_encode (p : CompositionStepPayloadEnc) (h_can : StepCanonical p.step) :
    (compositionStepPayloadToTreeJson p).encode = encodeCompositionStepPayload p := by
  dsimp [compositionStepPayloadToTreeJson, encodeCompositionStepPayload]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [configToTreeJson_encode, boundaryToTreeJson_encode, natToTreeJson_encode, encode_arr_map]
  have h_hist : (p.history.map (fun x => (outputObservationToTreeJson x).encode)) = p.history.map encodeOutputObservation := by
    simp only [List.map_inj_left]; intro x _; exact outputObservationToTreeJson_encode x
  rw [h_hist]
  rw [stepToTreeJson_encode p.step h_can, worldToTreeJson_encode]

def compositionRunPayloadToTreeJson (p : CompositionRunPayloadEnc) : TreeJson :=
  TreeJson.obj [
    ("config", configToTreeJson p.config),
    ("boundaries", TreeJson.arr (p.boundaries.map boundaryToTreeJson)),
    ("world", worldToTreeJson p.world),
    ("steps", TreeJson.arr (p.steps.map stepToTreeJson))
  ]

theorem compositionRunPayloadToTreeJson_encode (p : CompositionRunPayloadEnc) (h_can : ∀ s ∈ p.steps, StepCanonical s) :
    (compositionRunPayloadToTreeJson p).encode = encodeCompositionRunPayload p := by
  dsimp [compositionRunPayloadToTreeJson, encodeCompositionRunPayload]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [configToTreeJson_encode, encode_arr_map, worldToTreeJson_encode, encode_arr_map]
  have h_bs : (p.boundaries.map (fun x => (boundaryToTreeJson x).encode)) = p.boundaries.map encodeBoundary := by
    simp only [List.map_inj_left]; intro x _; exact boundaryToTreeJson_encode x
  have h_ss : (p.steps.map (fun x => (stepToTreeJson x).encode)) = p.steps.map encodeStep := by
    simp only [List.map_inj_left]; intro s hs; exact stepToTreeJson_encode s (h_can s hs)
  rw [h_bs, h_ss]

def moduleToTreeJson : DecodedIR → TreeJson
  | .execution (.typed env p) =>
    envelopeToTreeJson env (typedExecutePayloadToTreeJson p)
  | .execution (.step env p) =>
    envelopeToTreeJson env (compositionStepPayloadToTreeJson p)
  | .execution (.run env p) =>
    envelopeToTreeJson env (compositionRunPayloadToTreeJson p)
  | .audit _ => TreeJson.null
  | .codec _ => TreeJson.null

theorem moduleToTreeJson_encode (ir : DecodedIR) (h_adm : StructurallyAdmissibleIR ir) :
    (moduleToTreeJson ir).encode = encodeModuleString ir := by
  rcases h_adm with ⟨h_sup, h_can⟩
  dsimp [SupportedIR] at h_sup
  rcases h_sup with ⟨h_byte, h_depth, h_arr, h_ir_sup⟩
  cases ir with
  | execution ex =>
    cases ex with
    | typed env p =>
      dsimp [moduleToTreeJson, encodeModuleString]
      dsimp [CanonicalIR] at h_can
      rcases h_can with ⟨h_sm, _⟩
      rw [envelopeToTreeJson_encode env (typedExecutePayloadToTreeJson p) h_sm]
      rw [typedExecutePayloadToTreeJson_encode]
    | step env p =>
      dsimp [moduleToTreeJson, encodeModuleString]
      dsimp [CanonicalIR] at h_can
      rcases h_can with ⟨h_sm, _, _, h_step_can, _⟩
      rw [envelopeToTreeJson_encode env (compositionStepPayloadToTreeJson p) h_sm]
      rw [compositionStepPayloadToTreeJson_encode p h_step_can]
    | run env p =>
      dsimp [moduleToTreeJson, encodeModuleString]
      dsimp [CanonicalIR] at h_can
      rcases h_can with ⟨h_sm, _, _, h_steps_can, _⟩
      rw [envelopeToTreeJson_encode env (compositionRunPayloadToTreeJson p) h_sm]
      rw [compositionRunPayloadToTreeJson_encode p h_steps_can]
  | audit a =>
    dsimp [CanonicalIR] at h_can
  | codec doc =>
    dsimp [CanonicalIR] at h_can

theorem cellDeltaToTreeJson_toJson (d : CellDeltaEnc) :
    (cellDeltaToTreeJson d).toJson = cellDeltaToJson d := by
  dsimp [cellDeltaToTreeJson, cellDeltaToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [assetToTreeJson_toJson, cellRefToTreeJson_toJson, exprToTreeJson_toJson]

theorem supplyDeltaToTreeJson_toJson (d : SupplyDeltaEnc) :
    (supplyDeltaToTreeJson d).toJson = supplyDeltaToJson d := by
  dsimp [supplyDeltaToTreeJson, supplyDeltaToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [domainToTreeJson_toJson, assetToTreeJson_toJson, exprToTreeJson_toJson]

theorem envReadToTreeJson_toJson (e : EnvReadEnc) :
    (envReadToTreeJson e).toJson = envReadToJson e := by
  cases e with
  | observation k =>
    dsimp [envReadToTreeJson, envReadToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [observationKeyToTreeJson_toJson]
  | currentTime =>
    rfl

theorem templateToTreeJson_toJson (t : TemplateEnc) :
    (templateToTreeJson t).toJson = templateToJson t := by
  dsimp [templateToTreeJson, templateToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map, toJsonList_map, toJsonList_map, toJsonList_map, toJsonList_map, toJsonList_map]
  have h_sig : (t.signature.map (fun x => (unitToTreeJson x).toJson)) = t.signature.map unitToJson := by
    simp only [List.map_inj_left]; intro u _; exact unitToTreeJson_toJson u
  have h_del : (t.deltas.map (fun x => (cellDeltaToTreeJson x).toJson)) = t.deltas.map cellDeltaToJson := by
    simp only [List.map_inj_left]; intro x _; exact cellDeltaToTreeJson_toJson x
  have h_sdel : (t.supplyDeltas.map (fun x => (supplyDeltaToTreeJson x).toJson)) = t.supplyDeltas.map supplyDeltaToJson := by
    simp only [List.map_inj_left]; intro x _; exact supplyDeltaToTreeJson_toJson x
  have h_srd : (t.stateReads.map (fun x => (packedCellRefToTreeJson x).toJson)) = t.stateReads.map packedCellRefToJson := by
    simp only [List.map_inj_left]; intro x _; exact packedCellRefToTreeJson_toJson x
  have h_erd : (t.envReads.map (fun x => (envReadToTreeJson x).toJson)) = t.envReads.map envReadToJson := by
    simp only [List.map_inj_left]; intro x _; exact envReadToTreeJson_toJson x
  have h_wrt : (t.writes.map (fun x => (packedCellRefToTreeJson x).toJson)) = t.writes.map packedCellRefToJson := by
    simp only [List.map_inj_left]; intro x _; exact packedCellRefToTreeJson_toJson x
  rw [h_sig, h_del, h_sdel, h_srd, h_erd, h_wrt]
  rw [domainToTreeJson_toJson, natToTreeJson_toJson, exprToTreeJson_toJson]

theorem registryEntryToTreeJson_toJson (e : RegistryEntryEnc) :
    (registryEntryToTreeJson e).toJson = registryEntryToJson e := by
  dsimp [registryEntryToTreeJson, registryEntryToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [natToTreeJson_toJson, templateToTreeJson_toJson]

theorem registryToTreeJson_toJson (r : RegistryEnc) :
    (registryToTreeJson r).toJson = registryToJson r := by
  dsimp [registryToTreeJson, registryToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map]
  have h_map : (r.entries.map (fun x => (registryEntryToTreeJson x).toJson)) = r.entries.map registryEntryToJson := by
    simp only [List.map_inj_left]; intro e _; exact registryEntryToTreeJson_toJson e
  rw [h_map]

theorem decodeWorld_worldToTreeJson (w : WorldEnc)
    (h_st_valid : ∀ c ∈ w.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_st_unique : (w.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = w.state.cells.length) :
    decodeWorld (worldToTreeJson w).toJson = .ok w := by
  dsimp [worldToTreeJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [stateToTreeJson_toJson, storeToTreeJson_toJson]
  unfold decodeWorld
  dsimp [Json.mkObj]
  have h_dec : (do
      checkObjectKeys
          (Std.TreeMap.Raw.ofList [("state", stateToJson w.state), ("capabilities", storeToJson w.capabilities)]
              compare).toList
          ["state", "capabilities"]
      let sJ ←
        getField
            (Std.TreeMap.Raw.ofList [("state", stateToJson w.state), ("capabilities", storeToJson w.capabilities)]
                compare).toList
            "state"
      let state ← decodeState sJ
      let cJ ←
        getField
            (Std.TreeMap.Raw.ofList [("state", stateToJson w.state), ("capabilities", storeToJson w.capabilities)]
                compare).toList
            "capabilities"
      let caps ← decodeStore cJ
      Except.ok (⟨state, caps⟩ : WorldEnc)) = (do
      let state ← decodeState (stateToJson w.state)
      let caps ← decodeStore (storeToJson w.capabilities)
      Except.ok (⟨state, caps⟩ : WorldEnc)) := rfl
  rw [h_dec]
  have h_st := decodeState_stateToJson w.state h_st_valid h_st_unique
  have h_store := decodeStore_storeToJson w.capabilities
  rw [h_st, h_store]
  rfl

theorem decodeLibraryRef_libraryRefToTreeJson (lib : LibraryRefEnc) :
    decodeLibraryRef (libraryRefToTreeJson lib).toJson = .ok lib := by
  cases lib with | mk t m =>
  cases m with
  | none =>
    dsimp [libraryRefToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, decodeLibraryRef, checkObjectKeys, getField, getField?]
    rfl
  | some m' =>
    dsimp [libraryRefToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, decodeLibraryRef, checkObjectKeys, getField, getField?]
    rfl

theorem qualifiedPortToTreeJson_toJson (qp : QualifiedPortEnc) :
    (qualifiedPortToTreeJson qp).toJson = qualifiedPortToJson qp := by
  dsimp [qualifiedPortToTreeJson, qualifiedPortToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [natToTreeJson_toJson, natToTreeJson_toJson]

theorem decodeOutputObservation_outputObservationToTreeJson (o : OutputObservationEnc)
    (h_can : PackedValueCanonical o.value) :
    decodeOutputObservation (outputObservationToTreeJson o).toJson = .ok o := by
  have h_def : decodeOutputObservation (outputObservationToTreeJson o).toJson = (do
      let port ← decodeQualifiedPort (qualifiedPortToTreeJson o.port).toJson
      let val ← decodePackedValue (packedValueFullToTreeJson o.value).toJson
      .ok ⟨o.step, port, val⟩) := rfl
  rw [h_def]
  have h_port := decodeQualifiedPort_qualifiedPortToJson o.port
  have h_val := decodePackedValue_canonical o.value h_can
  rw [qualifiedPortToTreeJson_toJson]
  rw [packedValueFullToTreeJson_toJson]
  rw [h_port, h_val]
  rfl

set_option maxHeartbeats 3000000 in
-- Definitional reduction of TreeMap key sorting for 7 typedExecute payload fields
theorem decodeTypedExecutePayload_typedExecutePayloadToTreeJson (p : TypedExecutePayloadEnc)
    (h_reg_can : RegistryCanonical p.registry)
    (h_env_can : EnvironmentCanonical p.env)
    (h_req_can : RequestCanonical p.request)
    (h_state_valid : ∀ c ∈ p.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_state_unique : (p.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = p.state.cells.length) :
    decodeTypedExecutePayload (typedExecutePayloadToTreeJson p).toJson = .ok p := by
  have h_def : decodeTypedExecutePayload (typedExecutePayloadToTreeJson p).toJson = (do
      let reg_dec ← decodeRegistry (registryToTreeJson p.registry).toJson
      let store_dec ← decodeStore (storeToTreeJson p.store).toJson
      let ctx_dec ← decodeContext (contextToTreeJson p.ctx).toJson
      let env_dec ← decodeEnvironment (environmentToTreeJson p.env).toJson
      let req_dec ← decodeRequest (requestToTreeJson p.request).toJson
      let st_dec ← decodeState (stateToTreeJson p.state).toJson
      .ok ⟨reg_dec, store_dec, ctx_dec, env_dec, p.now, req_dec, st_dec⟩) := rfl
  rw [h_def]
  rw [registryToTreeJson_toJson, storeToTreeJson_toJson, contextToTreeJson_toJson, environmentToTreeJson_toJson, stateToTreeJson_toJson]
  have h_reg := decodeRegistry_registryToJson p.registry h_reg_can
  have h_store := decodeStore_storeToJson p.store
  have h_ctx := decodeContext_contextToJson p.ctx
  have h_env := decodeEnvironment_environmentToJson p.env h_env_can
  have h_req := decodeRequest_requestToTreeJson p.request h_req_can
  have h_state := decodeState_stateToJson p.state h_state_valid h_state_unique
  rw [h_reg, h_store, h_ctx, h_env, h_req, h_state]
  rfl

theorem inputPortToTreeJson_toJson (p : InputPortEnc) :
    (inputPortToTreeJson p).toJson = inputPortToJson p := by
  dsimp [inputPortToTreeJson, inputPortToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [unitToTreeJson_toJson, natToTreeJson_toJson]

theorem outputPortToTreeJson_toJson (p : OutputPortEnc) :
    (outputPortToTreeJson p).toJson = outputPortToJson p := by
  dsimp [outputPortToTreeJson, outputPortToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [cellToTreeJson_toJson, natToTreeJson_toJson]

theorem resourcePortToTreeJson_toJson (rp : ResourcePortEnc) :
    (resourcePortToTreeJson rp).toJson = resourcePortToJson rp := by
  dsimp [resourcePortToTreeJson, resourcePortToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [cellToTreeJson_toJson, natToTreeJson_toJson]

theorem resourceImportToTreeJson_toJson (ri : ResourceImportEnc) :
    (resourceImportToTreeJson ri).toJson = resourceImportToJson ri := by
  dsimp [resourceImportToTreeJson, resourceImportToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [qualifiedPortToTreeJson_toJson, cellToTreeJson_toJson]

theorem domainAdminToTreeJson_toJson (d : DomainAdminEnc) :
    (domainAdminToTreeJson d).toJson = domainAdminToJson d := by
  dsimp [domainAdminToTreeJson, domainAdminToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [domainToTreeJson_toJson, partyToTreeJson_toJson]

set_option maxHeartbeats 3000000 in
theorem decodeOperationInterface_operationInterfaceToTreeJson (op : OperationInterfaceEnc) :
    decodeOperationInterface (operationInterfaceToTreeJson op).toJson = .ok op := by
  cases op with | mk num ins outs =>
  have h_def : decodeOperationInterface (operationInterfaceToTreeJson ⟨num, ins, outs⟩).toJson = (do
      let inputs ← ((TreeJson.toJsonList (ins.map inputPortToTreeJson)).toArray).toList.mapM decodeInputPort
      let outputs ← ((TreeJson.toJsonList (outs.map outputPortToTreeJson)).toArray).toList.mapM decodeOutputPort
      .ok ⟨num, inputs, outputs⟩) := rfl
  rw [h_def]
  rw [toJsonList_map, toJsonList_map]
  have h_ins : (ins.map (fun x => (inputPortToTreeJson x).toJson)).mapM decodeInputPort = .ok ins := by
    apply list_mapM_decode_ok; intro p _; rw [inputPortToTreeJson_toJson]; exact decodeInputPort_inputPortToJson p
  have h_outs : (outs.map (fun x => (outputPortToTreeJson x).toJson)).mapM decodeOutputPort = .ok outs := by
    apply list_mapM_decode_ok; intro p _; rw [outputPortToTreeJson_toJson]; exact decodeOutputPort_outputPortToJson p
  rw [h_ins, h_outs]
  rfl

set_option maxHeartbeats 3000000 in
theorem decodeComponent_componentToTreeJson (c : ComponentEnc) :
    decodeComponent (componentToTreeJson c).toJson = .ok c := by
  cases c with | mk id priv exp imp ops =>
  have h_def : decodeComponent (componentToTreeJson ⟨id, priv, exp, imp, ops⟩).toJson = (do
      let privateCells ← ((TreeJson.toJsonList (priv.map cellToTreeJson)).toArray).toList.mapM decodeCell
      let exports ← ((TreeJson.toJsonList (exp.map resourcePortToTreeJson)).toArray).toList.mapM decodeResourcePort
      let imports ← ((TreeJson.toJsonList (imp.map resourceImportToTreeJson)).toArray).toList.mapM decodeResourceImport
      let operations ← ((TreeJson.toJsonList (ops.map operationInterfaceToTreeJson)).toArray).toList.mapM decodeOperationInterface
      .ok ⟨id, privateCells, exports, imports, operations⟩) := rfl
  rw [h_def]
  rw [toJsonList_map, toJsonList_map, toJsonList_map, toJsonList_map]
  have h_priv : (priv.map (fun x => (cellToTreeJson x).toJson)).mapM decodeCell = .ok priv := by
    apply list_mapM_decode_ok; intro x _; rw [cellToTreeJson_toJson]; exact decodeCell_cellToJson x
  have h_exp : (exp.map (fun x => (resourcePortToTreeJson x).toJson)).mapM decodeResourcePort = .ok exp := by
    apply list_mapM_decode_ok; intro x _; rw [resourcePortToTreeJson_toJson]; exact decodeResourcePort_resourcePortToJson x
  have h_imp : (imp.map (fun x => (resourceImportToTreeJson x).toJson)).mapM decodeResourceImport = .ok imp := by
    apply list_mapM_decode_ok; intro x _; rw [resourceImportToTreeJson_toJson]; exact decodeResourceImport_resourceImportToJson x
  have h_ops : (ops.map (fun x => (operationInterfaceToTreeJson x).toJson)).mapM decodeOperationInterface = .ok ops := by
    apply list_mapM_decode_ok; intro x _; exact decodeOperationInterface_operationInterfaceToTreeJson x
  rw [h_priv, h_exp, h_imp, h_ops]
  rfl

set_option maxHeartbeats 3000000 in
theorem decodeConfig_configToTreeJson (c : ConfigEnc) (h_reg_can : RegistryCanonical c.registry) :
    decodeConfig (configToTreeJson c).toJson = .ok c := by
  cases c with | mk reg da cat =>
  have h_def : decodeConfig (configToTreeJson ⟨reg, da, cat⟩).toJson = (do
      let reg_dec ← decodeRegistry (registryToTreeJson reg).toJson
      let da_dec ← ((TreeJson.toJsonList (da.map domainAdminToTreeJson)).toArray).toList.mapM decodeDomainAdmin
      let cat_dec ← ((TreeJson.toJsonList (cat.map componentToTreeJson)).toArray).toList.mapM decodeComponent
      .ok ⟨reg_dec, da_dec, cat_dec⟩) := rfl
  rw [h_def]
  rw [registryToTreeJson_toJson]
  have h_reg := decodeRegistry_registryToJson reg h_reg_can
  rw [h_reg]
  rw [toJsonList_map, toJsonList_map]
  have h_da : (da.map (fun x => (domainAdminToTreeJson x).toJson)).mapM decodeDomainAdmin = .ok da := by
    apply list_mapM_decode_ok; intro x _; rw [domainAdminToTreeJson_toJson]; exact decodeDomainAdmin_domainAdminToJson x
  have h_cat : (cat.map (fun x => (componentToTreeJson x).toJson)).mapM decodeComponent = .ok cat := by
    apply list_mapM_decode_ok; intro x _; exact decodeComponent_componentToTreeJson x
  rw [h_da, h_cat]
  rfl

set_option maxHeartbeats 3000000 in
theorem decodeBoundary_boundaryToTreeJson (b : BoundaryEnc) (h_env : EnvironmentCanonical b.env) :
    decodeBoundary (boundaryToTreeJson b).toJson = .ok b := by
  have h_def : decodeBoundary (boundaryToTreeJson b).toJson = (do
      let ctx ← decodeContext (contextToTreeJson b.ctx).toJson
      let env ← decodeEnvironment (environmentToTreeJson b.env).toJson
      .ok ⟨ctx, env, b.now⟩) := rfl
  rw [h_def]
  rw [contextToTreeJson_toJson, environmentToTreeJson_toJson]
  have h_ctx := decodeContext_contextToJson b.ctx
  have h_e := decodeEnvironment_environmentToJson b.env h_env
  rw [h_ctx, h_e]
  rfl

theorem decodeInputSource_inputSourceToTreeJson (i : InputSourceEnc) (h_can : InputSourceCanonical i) :
    decodeInputSource (inputSourceToTreeJson i).toJson = .ok i := by
  cases i with
  | literal v =>
    have h_def : decodeInputSource (inputSourceToTreeJson (.literal v)).toJson = (do
        let val ← decodePackedValue (packedValueFullToTreeJson v).toJson
        .ok (.literal val)) := rfl
    rw [h_def]
    rw [packedValueFullToTreeJson_toJson]
    have h_val := decodePackedValue_canonical v h_can
    rw [h_val]
    rfl
  | priorOutput step port =>
    have h_def : decodeInputSource (inputSourceToTreeJson (.priorOutput step port)).toJson = (do
        let p ← decodeQualifiedPort (qualifiedPortToTreeJson port).toJson
        .ok (.priorOutput step p)) := rfl
    rw [h_def]
    rw [qualifiedPortToTreeJson_toJson]
    have h_p := decodeQualifiedPort_qualifiedPortToJson port
    rw [h_p]
    rfl

set_option maxHeartbeats 3000000 in
theorem decodeInvocation_invocationToTreeJson (inv : InvocationEnc)
    (h_can : ∀ i ∈ inv.inputs, InputSourceCanonical i) :
    decodeInvocation (invocationToTreeJson inv).toJson = .ok inv := by
  cases inv with | mk comp op ps ins caps ca =>
  cases ca with
  | none =>
    have h_def : decodeInvocation (invocationToTreeJson ⟨comp, op, ps, ins, caps, none⟩).toJson = (do
        let ps_dec ← ((TreeJson.toJsonList (ps.map partyToTreeJson)).toArray).toList.mapM decodeParty
        let ins_dec ← ((TreeJson.toJsonList (ins.map inputSourceToTreeJson)).toArray).toList.mapM decodeInputSource
        let caps_dec ← ((TreeJson.toJsonList (caps.map natToTreeJson)).toArray).toList.mapM (fun x => match x with | .num n => Except.ok n.mantissa.toNat | _ => Except.error (DecodeFailure.jsonType "capabilityId"))
        .ok ⟨comp, op, ps_dec, ins_dec, caps_dec, none⟩) := rfl
    rw [h_def]
    rw [toJsonList_map, toJsonList_map, toJsonList_map]
    have h_ps : (ps.map (fun x => (partyToTreeJson x).toJson)).mapM decodeParty = .ok ps := by
      apply list_mapM_decode_ok; intro p _; rw [partyToTreeJson_toJson]; exact decodeParty_partyToJson p
    have h_ins : (ins.map (fun x => (inputSourceToTreeJson x).toJson)).mapM decodeInputSource = .ok ins := by
      apply list_mapM_decode_ok; intro i hi; exact decodeInputSource_inputSourceToTreeJson i (h_can i hi)
    have h_caps : (caps.map (fun x => (natToTreeJson x).toJson)).mapM (fun x => match x with | .num n => Except.ok n.mantissa.toNat | _ => Except.error (DecodeFailure.jsonType "capabilityId")) = Except.ok caps := by
      apply list_mapM_decode_ok; intro c _; rfl
    rw [h_ps, h_ins, h_caps]
    rfl
  | some a =>
    have h_def : decodeInvocation (invocationToTreeJson ⟨comp, op, ps, ins, caps, some a⟩).toJson = (do
        let ps_dec ← ((TreeJson.toJsonList (ps.map partyToTreeJson)).toArray).toList.mapM decodeParty
        let ins_dec ← ((TreeJson.toJsonList (ins.map inputSourceToTreeJson)).toArray).toList.mapM decodeInputSource
        let caps_dec ← ((TreeJson.toJsonList (caps.map natToTreeJson)).toArray).toList.mapM (fun x => match x with | .num n => Except.ok n.mantissa.toNat | _ => Except.error (DecodeFailure.jsonType "capabilityId"))
        let ca_dec ← (decodeParty (partyToTreeJson a).toJson).map some
        .ok ⟨comp, op, ps_dec, ins_dec, caps_dec, ca_dec⟩) := rfl
    rw [h_def]
    rw [toJsonList_map, toJsonList_map, toJsonList_map]
    have h_ps : (ps.map (fun x => (partyToTreeJson x).toJson)).mapM decodeParty = .ok ps := by
      apply list_mapM_decode_ok; intro p _; rw [partyToTreeJson_toJson]; exact decodeParty_partyToJson p
    have h_ins : (ins.map (fun x => (inputSourceToTreeJson x).toJson)).mapM decodeInputSource = .ok ins := by
      apply list_mapM_decode_ok; intro i hi; exact decodeInputSource_inputSourceToTreeJson i (h_can i hi)
    have h_caps : (caps.map (fun x => (natToTreeJson x).toJson)).mapM (fun x => match x with | .num n => Except.ok n.mantissa.toNat | _ => Except.error (DecodeFailure.jsonType "capabilityId")) = Except.ok caps := by
      apply list_mapM_decode_ok; intro c _; rfl
    rw [h_ps, h_ins, h_caps]
    rw [partyToTreeJson_toJson, decodeParty_partyToJson a]
    rfl

set_option maxHeartbeats 3000000 in
theorem decodeStep_stepToTreeJson (s : StepEnc) (h_can : StepCanonical s) :
    decodeStep (stepToTreeJson s).toJson = .ok s := by
  cases s with
  | invoke inv =>
    have h_def : decodeStep (stepToTreeJson (.invoke inv)).toJson = (do
        let inv_dec ← decodeInvocation (invocationToTreeJson inv).toJson
        .ok (.invoke inv_dec)) := rfl
    rw [h_def]
    have h_inv := decodeInvocation_invocationToTreeJson inv h_can
    rw [h_inv]
    rfl
  | issue g =>
    have h_def : decodeStep (stepToTreeJson (.issue g)).toJson = (do
        let g_dec ← decodeGrant (grantToTreeJson g).toJson
        .ok (.issue g_dec)) := rfl
    rw [h_def]
    rw [grantToTreeJson_toJson]
    have h_g := decodeGrant_grantToJson g
    rw [h_g]
    rfl
  | revoke id =>
    rfl
  | unsupported tag =>
    cases h_can

set_option maxHeartbeats 3000000 in
theorem decodeCompositionStepPayload_compositionStepPayloadToTreeJson (p : CompositionStepPayloadEnc)
    (h_cfg_can : RegistryCanonical p.config.registry)
    (h_bnd_can : EnvironmentCanonical p.boundary.env)
    (h_hist_can : ∀ o ∈ p.history, PackedValueCanonical o.value)
    (h_step_can : StepCanonical p.step)
    (h_pre_valid : ∀ c ∈ p.pre.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_pre_unique : (p.pre.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = p.pre.state.cells.length) :
    decodeCompositionStepPayload (compositionStepPayloadToTreeJson p).toJson = .ok p := by
  have h_def : decodeCompositionStepPayload (compositionStepPayloadToTreeJson p).toJson = (do
      let cfg_dec ← decodeConfig (configToTreeJson p.config).toJson
      let bnd_dec ← decodeBoundary (boundaryToTreeJson p.boundary).toJson
      let hist_dec ← ((TreeJson.toJsonList (p.history.map outputObservationToTreeJson)).toArray).toList.mapM decodeOutputObservation
      let step_dec ← decodeStep (stepToTreeJson p.step).toJson
      let pre_dec ← decodeWorld (worldToTreeJson p.pre).toJson
      .ok ⟨cfg_dec, bnd_dec, p.index, hist_dec, step_dec, pre_dec⟩) := rfl
  rw [h_def]
  have h_cfg := decodeConfig_configToTreeJson p.config h_cfg_can
  have h_bnd := decodeBoundary_boundaryToTreeJson p.boundary h_bnd_can
  rw [toJsonList_map]
  have h_hist : (p.history.map (fun x => (outputObservationToTreeJson x).toJson)).mapM decodeOutputObservation = .ok p.history := by
    apply list_mapM_decode_ok; intro o ho; exact decodeOutputObservation_outputObservationToTreeJson o (h_hist_can o ho)
  have h_step := decodeStep_stepToTreeJson p.step h_step_can
  have h_pre := decodeWorld_worldToTreeJson p.pre h_pre_valid h_pre_unique
  rw [h_cfg, h_bnd, h_hist, h_step, h_pre]
  rfl

set_option maxHeartbeats 3000000 in
theorem decodeCompositionRunPayload_compositionRunPayloadToTreeJson (p : CompositionRunPayloadEnc)
    (h_cfg_can : RegistryCanonical p.config.registry)
    (h_bnds_can : ∀ b ∈ p.boundaries, EnvironmentCanonical b.env)
    (h_steps_can : ∀ s ∈ p.steps, StepCanonical s)
    (h_w_valid : ∀ c ∈ p.world.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_w_unique : (p.world.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = p.world.state.cells.length) :
    decodeCompositionRunPayload (compositionRunPayloadToTreeJson p).toJson = .ok p := by
  have h_def : decodeCompositionRunPayload (compositionRunPayloadToTreeJson p).toJson = (do
      let cfg_dec ← decodeConfig (configToTreeJson p.config).toJson
      let bnds_dec ← ((TreeJson.toJsonList (p.boundaries.map boundaryToTreeJson)).toArray).toList.mapM decodeBoundary
      let world_dec ← decodeWorld (worldToTreeJson p.world).toJson
      let steps_dec ← ((TreeJson.toJsonList (p.steps.map stepToTreeJson)).toArray).toList.mapM decodeStep
      .ok ⟨cfg_dec, bnds_dec, world_dec, steps_dec⟩) := rfl
  rw [h_def]
  have h_cfg := decodeConfig_configToTreeJson p.config h_cfg_can
  rw [toJsonList_map, toJsonList_map]
  have h_bnds : (p.boundaries.map (fun x => (boundaryToTreeJson x).toJson)).mapM decodeBoundary = .ok p.boundaries := by
    apply list_mapM_decode_ok; intro b hb; exact decodeBoundary_boundaryToTreeJson b (h_bnds_can b hb)
  have h_world := decodeWorld_worldToTreeJson p.world h_w_valid h_w_unique
  have h_steps : (p.steps.map (fun x => (stepToTreeJson x).toJson)).mapM decodeStep = .ok p.steps := by
    apply list_mapM_decode_ok; intro s hs; exact decodeStep_stepToTreeJson s (h_steps_can s hs)
  rw [h_cfg, h_bnds, h_world, h_steps]
  rfl


theorem nodup_of_pairwise_lt_string : ∀ (xs : List String),
    xs.Pairwise (· < ·) → xs.Nodup
  | [], _ => List.nodup_nil
  | x :: xs, h => by
    cases h with
    | cons h_head h_tail =>
      refine List.nodup_cons.mpr ⟨?_, nodup_of_pairwise_lt_string xs h_tail⟩
      intro h_mem
      have h_lt := h_head x h_mem
      exact String.lt_irrefl x h_lt

theorem validObj_str_map (entries : List (String × String)) :
    TreeJson.ValidObj (entries.map (fun (k, v) => (k, TreeJson.str v))) := by
  induction entries with
  | nil => trivial
  | cons e es ih =>
    dsimp [List.map, TreeJson.ValidObj]
    exact ⟨trivial, ih⟩

theorem sourceMapToTreeJson_valid (entries : List (String × String))
    (h_sm : SourceMapSorted entries) :
    TreeJson.Valid (sourceMapToTreeJson entries) := by
  dsimp [sourceMapToTreeJson, TreeJson.Valid]
  have h_nd : ((entries.map (fun (k, v) => (k, TreeJson.str v))).map Prod.fst).Nodup := by
    have h_map_eq : (entries.map (fun (k, v) => (k, TreeJson.str v))).map Prod.fst = entries.map Prod.fst := by
      simp only [List.map_map, Function.comp_def]
    rw [h_map_eq]
    dsimp [SourceMapSorted] at h_sm
    have h_pw := pairwise_lt_of_isSortedStrictAscending (entries.map Prod.fst) h_sm
    exact nodup_of_pairwise_lt_string (entries.map Prod.fst) h_pw
  refine ⟨h_nd, validObj_str_map entries⟩

theorem registryToTreeJson_valid (r : RegistryEnc)
    (h_len : r.entries.length ≤ 4096)
    (h_tmpl : ∀ e ∈ r.entries, TemplateLengthBounds e.template) :
    TreeJson.Valid (registryToTreeJson r) := by
  dsimp [registryToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, valid_arr_map registryEntryToTreeJson r.entries h_len (fun e he => by
    have hb := h_tmpl e he
    rcases hb with ⟨h1, h2, h3, h4, h5, h6⟩
    exact registryEntryToTreeJson_valid e h1 h2 h3 h4 h5 h6), trivial⟩

theorem worldToTreeJson_valid (w : WorldEnc)
    (h_cells : w.state.cells.length ≤ 4096)
    (h_caps : w.capabilities.entries.length ≤ 4096) :
    TreeJson.Valid (worldToTreeJson w) := by
  dsimp [worldToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, stateToTreeJson_valid w.state h_cells, storeToTreeJson_valid w.capabilities h_caps, trivial⟩

theorem boundaryToTreeJson_valid (b : BoundaryEnc)
    (h_env : b.env.entries.length ≤ 4096) :
    TreeJson.Valid (boundaryToTreeJson b) := by
  dsimp [boundaryToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, contextToTreeJson_valid b.ctx, environmentToTreeJson_valid b.env h_env, trivial, trivial⟩

theorem operationInterfaceToTreeJson_valid (op : OperationInterfaceEnc)
    (h_in : op.inputs.length ≤ 4096)
    (h_out : op.outputs.length ≤ 4096) :
    TreeJson.Valid (operationInterfaceToTreeJson op) := by
  dsimp [operationInterfaceToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial,
          valid_arr_map inputPortToTreeJson op.inputs h_in (fun p _ => inputPortToTreeJson_valid p),
          valid_arr_map outputPortToTreeJson op.outputs h_out (fun p _ => outputPortToTreeJson_valid p),
          trivial⟩

theorem componentToTreeJson_valid (c : ComponentEnc)
    (h_priv : c.privateCells.length ≤ 4096)
    (h_exp : c.exports.length ≤ 4096)
    (h_imp : c.imports.length ≤ 4096)
    (h_op : c.operations.length ≤ 4096)
    (h_op_in : ∀ op ∈ c.operations, op.inputs.length ≤ 4096)
    (h_op_out : ∀ op ∈ c.operations, op.outputs.length ≤ 4096) :
    TreeJson.Valid (componentToTreeJson c) := by
  dsimp [componentToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial,
          valid_arr_map cellToTreeJson c.privateCells h_priv (fun cell _ => cellToTreeJson_valid cell),
          valid_arr_map resourcePortToTreeJson c.exports h_exp (fun p _ => resourcePortToTreeJson_valid p),
          valid_arr_map resourceImportToTreeJson c.imports h_imp (fun ri _ => resourceImportToTreeJson_valid ri),
          valid_arr_map operationInterfaceToTreeJson c.operations h_op (fun op hop => operationInterfaceToTreeJson_valid op (h_op_in op hop) (h_op_out op hop)),
          trivial⟩

theorem configToTreeJson_valid (c : ConfigEnc)
    (h_cfg : ConfigLengthBounds c) :
    TreeJson.Valid (configToTreeJson c) := by
  rcases h_cfg with ⟨h_reg, h_tmpl, h_da, h_cat, h_cat_bounds⟩
  dsimp [configToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, registryToTreeJson_valid c.registry h_reg h_tmpl,
          valid_arr_map domainAdminToTreeJson c.domainAdmin h_da (fun da _ => domainAdminToTreeJson_valid da),
          valid_arr_map componentToTreeJson c.catalog h_cat (fun comp hcomp => by
            have hb := h_cat_bounds comp hcomp
            rcases hb with ⟨h1, h2, h3, h4, h5⟩
            exact componentToTreeJson_valid comp h1 h2 h3 h4
              (fun op hop => (h5 op hop).1)
              (fun op hop => (h5 op hop).2)),
          trivial⟩

theorem inputSourceToTreeJson_valid (i : InputSourceEnc) :
    TreeJson.Valid (inputSourceToTreeJson i) := by
  cases i with
  | literal v =>
    dsimp [inputSourceToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, packedValueFullToTreeJson_valid v, trivial⟩
  | priorOutput step port =>
    dsimp [inputSourceToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial, qualifiedPortToTreeJson_valid port, trivial⟩

theorem invocationToTreeJson_valid (inv : InvocationEnc)
    (h_ps : inv.parties.length ≤ 4096)
    (h_ins : inv.inputs.length ≤ 4096)
    (h_caps : inv.capabilityIds.length ≤ 4096) :
    TreeJson.Valid (invocationToTreeJson inv) := by
  dsimp [invocationToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, trivial,
          valid_arr_map partyToTreeJson inv.parties h_ps (fun p _ => partyToTreeJson_valid p),
          valid_arr_map inputSourceToTreeJson inv.inputs h_ins (fun i _ => inputSourceToTreeJson_valid i),
          valid_arr_map natToTreeJson inv.capabilityIds h_caps (fun n _ => natToTreeJson_valid n),
          by cases inv.claimedActor with | none => trivial | some a => exact partyToTreeJson_valid a,
          trivial⟩

theorem stepToTreeJson_valid (s : StepEnc)
    (h_bounds : StepLengthBounds s) :
    TreeJson.Valid (stepToTreeJson s) := by
  cases s with
  | invoke inv =>
    rcases h_bounds with ⟨h_ins, h_caps, h_ps⟩
    dsimp [stepToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, invocationToTreeJson_valid inv h_ps h_ins h_caps, trivial⟩
  | issue g =>
    dsimp [stepToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, grantToTreeJson_valid g, trivial⟩
  | revoke id =>
    dsimp [stepToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial, trivial⟩
  | unsupported tag =>
    dsimp [stepToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
    simp only [List.map_cons, List.map_nil]
    refine ⟨by decide, trivial, trivial⟩

theorem outputObservationToTreeJson_valid (o : OutputObservationEnc) :
    TreeJson.Valid (outputObservationToTreeJson o) := by
  dsimp [outputObservationToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, qualifiedPortToTreeJson_valid o.port, packedValueFullToTreeJson_valid o.value, trivial⟩

theorem typedExecutePayloadToTreeJson_valid (p : TypedExecutePayloadEnc)
    (h_b : TypedPayloadLengthBounds p) :
    TreeJson.Valid (typedExecutePayloadToTreeJson p) := by
  rcases h_b with ⟨h_cells, h_reg, h_tmpl, h_store, h_env, h_args, h_caps, h_ps⟩
  dsimp [typedExecutePayloadToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, registryToTreeJson_valid p.registry h_reg h_tmpl,
          storeToTreeJson_valid p.store h_store,
          contextToTreeJson_valid p.ctx,
          environmentToTreeJson_valid p.env h_env,
          trivial,
          requestToTreeJson_valid p.request h_ps h_args h_caps,
          stateToTreeJson_valid p.state (by omega),
          trivial⟩

theorem compositionStepPayloadToTreeJson_valid (p : CompositionStepPayloadEnc)
    (h_b : StepPayloadLengthBounds p) :
    TreeJson.Valid (compositionStepPayloadToTreeJson p) := by
  rcases h_b with ⟨h_cfg, h_cells, h_caps, h_env, h_hist, h_step⟩
  dsimp [compositionStepPayloadToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, configToTreeJson_valid p.config h_cfg,
          boundaryToTreeJson_valid p.boundary h_env,
          trivial,
          valid_arr_map outputObservationToTreeJson p.history h_hist (fun o _ => outputObservationToTreeJson_valid o),
          stepToTreeJson_valid p.step h_step,
          worldToTreeJson_valid p.pre (by omega) h_caps,
          trivial⟩

theorem compositionRunPayloadToTreeJson_valid (p : CompositionRunPayloadEnc)
    (h_b : RunPayloadLengthBounds p) :
    TreeJson.Valid (compositionRunPayloadToTreeJson p) := by
  rcases h_b with ⟨h_cfg, h_cells, h_caps, h_bnds, h_bnd_envs, h_steps, h_step_bounds⟩
  dsimp [compositionRunPayloadToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, configToTreeJson_valid p.config h_cfg,
          valid_arr_map boundaryToTreeJson p.boundaries h_bnds (fun b hb => boundaryToTreeJson_valid b (h_bnd_envs b hb)),
          worldToTreeJson_valid p.world (by omega) h_caps,
          valid_arr_map stepToTreeJson p.steps h_steps (fun s hs => stepToTreeJson_valid s (h_step_bounds s hs)),
          trivial⟩

theorem envelopeToTreeJson_valid (env : EnvelopeEnc) (payload : TreeJson)
    (h_env : EnvelopeLengthBounds env)
    (h_sm : SourceMapSorted env.source_map)
    (h_p : TreeJson.Valid payload) :
    TreeJson.Valid (envelopeToTreeJson env payload) := by
  rcases h_env with ⟨h_roots, h_asms, h_invs, h_libs, h_sm_len, h_cj, h_ps, h_as, h_ds, h_cns⟩
  dsimp [envelopeToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, trivial, sourcePinToTreeJson_valid env.source_pin,
          valid_arr_map TreeJson.str env.audit_roots h_roots (fun _ _ => trivial),
          typesEnumToTreeJson_valid env.types h_ps h_as h_ds,
          valid_arr_map TreeJson.str env.assumptions h_asms (fun _ _ => trivial),
          valid_arr_map TreeJson.str env.invariants h_invs (fun _ _ => trivial),
          valid_arr_map libraryRefToTreeJson env.libraries h_libs (fun l _ => libraryRefToTreeJson_valid l),
          sourceMapToTreeJson_valid env.source_map h_sm,
          h_p,
          valid_arr_map TreeJson.str env.claimed_judgments h_cj (fun _ _ => trivial),
          ?_,
          trivial, trivial, trivial⟩
  cases h_w : env.claimed_next_state with
  | none => trivial
  | some w =>
    have hc : ClaimedNextStateLengthBounds env.claimed_next_state = true := h_cns
    rw [h_w] at hc
    dsimp [ClaimedNextStateLengthBounds] at hc
    have hc_w : w.state.cells.length ≤ 4096 := by
      revert hc
      simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq]
      intro ⟨h1, _⟩
      omega
    have hc_caps : w.capabilities.entries.length ≤ 4096 := by
      revert hc
      simp only [Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq]
      intro ⟨_, h2⟩
      exact h2
    exact worldToTreeJson_valid w hc_w hc_caps

theorem moduleToTreeJson_valid (ir : DecodedIR) (h_adm : StructurallyAdmissibleIR ir) :
    TreeJson.Valid (moduleToTreeJson ir) := by
  rcases h_adm with ⟨h_sup, h_can⟩
  dsimp [SupportedIR] at h_sup
  rcases h_sup with ⟨h_byte, h_depth, h_arr, h_ir_sup⟩
  cases ir with
  | execution ex =>
    cases ex with
    | typed env p =>
      rcases h_ir_sup with ⟨h_ver, h_mode, h_types, h_cells, h_keys, h_pos, h_store, h_nodup, h_env, h_p⟩
      dsimp [CanonicalIR] at h_can
      rcases h_can with ⟨h_sm, _⟩
      dsimp [moduleToTreeJson]
      exact envelopeToTreeJson_valid env (typedExecutePayloadToTreeJson p) h_env h_sm (typedExecutePayloadToTreeJson_valid p h_p)
    | step env p =>
      rcases h_ir_sup with ⟨h_ver, h_mode, h_types, h_step_unsupp, h_cells, h_keys, h_pos, h_store, h_nodup, h_env, h_p⟩
      dsimp [CanonicalIR] at h_can
      rcases h_can with ⟨h_sm, _⟩
      dsimp [moduleToTreeJson]
      exact envelopeToTreeJson_valid env (compositionStepPayloadToTreeJson p) h_env h_sm (compositionStepPayloadToTreeJson_valid p h_p)
    | run env p =>
      rcases h_ir_sup with ⟨h_ver, h_mode, h_types, h_steps_unsupp, h_cells, h_keys, h_pos, h_store, h_nodup, h_env, h_p⟩
      dsimp [CanonicalIR] at h_can
      rcases h_can with ⟨h_sm, _⟩
      dsimp [moduleToTreeJson]
      exact envelopeToTreeJson_valid env (compositionRunPayloadToTreeJson p) h_env h_sm (compositionRunPayloadToTreeJson_valid p h_p)
  | audit a => contradiction
  | codec doc => contradiction

theorem parseCanonicalJson_encodeModuleString_tree (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_valid : TreeJson.Valid (moduleToTreeJson ir))
    (h_depth : TreeJson.depth (moduleToTreeJson ir) ≤ 64) :
    parseCanonicalJson (encodeModuleString ir) = .ok ((moduleToTreeJson ir).toJson) := by
  have h_enc := moduleToTreeJson_encode ir h_adm
  rw [← h_enc]
  exact parseCanonicalJson_tree (moduleToTreeJson ir) h_valid h_depth

theorem parseCanonicalJson_encodeModuleString_tree_of_depth (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_depth : TreeJson.depth (moduleToTreeJson ir) ≤ 64) :
    parseCanonicalJson (encodeModuleString ir) = .ok ((moduleToTreeJson ir).toJson) :=
  parseCanonicalJson_encodeModuleString_tree ir h_adm (moduleToTreeJson_valid ir h_adm) h_depth

theorem depthList_le (xs : List TreeJson) (n : Nat) (h : ∀ x ∈ xs, TreeJson.depth x ≤ n) :
    TreeJson.depthList xs ≤ n := by
  induction xs with
  | nil => dsimp [TreeJson.depthList]; omega
  | cons x xs ih =>
    dsimp [TreeJson.depthList]
    have hx := h x (by simp)
    have hxs := ih (fun y hy => h y (by simp [hy]))
    omega

theorem depthObj_le (kvs : List (String × TreeJson)) (n : Nat) (h : ∀ k v, (k, v) ∈ kvs → TreeJson.depth v ≤ n) :
    TreeJson.depthObj kvs ≤ n := by
  induction kvs with
  | nil => dsimp [TreeJson.depthObj]; omega
  | cons kv kvs ih =>
    rcases kv with ⟨k, v⟩
    dsimp [TreeJson.depthObj]
    have hv := h k v (by simp)
    have hkvs := ih (fun k' v' hmem => h k' v' (by simp [hmem]))
    omega

theorem depthList_map_le {α : Type} (f : α → TreeJson) (xs : List α) (n : Nat)
    (h : ∀ x ∈ xs, TreeJson.depth (f x) ≤ n) :
    TreeJson.depthList (xs.map f) ≤ n := by
  apply depthList_le
  intro y hy
  rcases List.mem_map.mp hy with ⟨x, hx, rfl⟩
  exact h x hx

def envelopeTreeFields (env : EnvelopeEnc) (payload : TreeJson) : List (String × Lean.Json) := [
  ("assumptions", Lean.Json.arr (TreeJson.toJsonList (env.assumptions.map TreeJson.str)).toArray),
  ("audit_roots", Lean.Json.arr (TreeJson.toJsonList (env.audit_roots.map TreeJson.str)).toArray),
  ("claimed_judgments", Lean.Json.arr (TreeJson.toJsonList (env.claimed_judgments.map TreeJson.str)).toArray),
  ("claimed_next_state", match env.claimed_next_state with | some w => (worldToTreeJson w).toJson | none => Lean.Json.null),
  ("invariants", Lean.Json.arr (TreeJson.toJsonList (env.invariants.map TreeJson.str)).toArray),
  ("libraries", Lean.Json.arr (TreeJson.toJsonList (env.libraries.map libraryRefToTreeJson)).toArray),
  ("mode", Lean.Json.str env.mode),
  ("payload", payload.toJson),
  ("require_invariant_discharge", Lean.Json.bool env.require_invariant_discharge),
  ("require_library_discharge", Lean.Json.bool env.require_library_discharge),
  ("schema_version", (natToTreeJson env.schema_version).toJson),
  ("source_map", (sourceMapToTreeJson env.source_map).toJson),
  ("source_pin", (sourcePinToTreeJson env.source_pin).toJson),
  ("types", (typesEnumToTreeJson env.types).toJson)
]

set_option maxHeartbeats 1000000 in
theorem envelopeToTreeJson_fields (env : EnvelopeEnc) (payload : TreeJson) :
    (match (envelopeToTreeJson env payload).toJson with
    | .obj m => m.toList
    | _ => []) = envelopeTreeFields env payload := by
  dsimp [envelopeToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, envelopeTreeFields]
  cases env.claimed_next_state <;> rfl

theorem decodeLibraries_tree_ok (libs : List LibraryRefEnc) :
    ((TreeJson.toJsonList (libs.map libraryRefToTreeJson)).toArray.toList.mapM decodeLibraryRef) = Except.ok libs := by
  rw [toJsonList_map]
  apply list_mapM_decode_ok
  intro l _
  exact decodeLibraryRef_libraryRefToTreeJson l

theorem decodeClaimedNextState_tree_some (w : WorldEnc) (h : WorldCanonical w) :
    decodeClaimedNextState (worldToTreeJson w).toJson = .ok (some w) := by
  cases w with | mk st caps =>
  have h_valid := world_valid_of_canonical ⟨st, caps⟩ h
  have h_unique := world_unique_of_canonical ⟨st, caps⟩ h
  have h_world := decodeWorld_worldToTreeJson ⟨st, caps⟩ h_valid h_unique
  change (do
    let w ← decodeWorld (worldToTreeJson ⟨st, caps⟩).toJson
    .ok (some w)) = .ok (some ⟨st, caps⟩)
  rw [h_world]
  rfl

theorem decodeEnvelope_treeFields (env : EnvelopeEnc) (payload : TreeJson)
    (h_ver : env.schema_version = 1)
    (h_sm : SourceMapSorted env.source_map)
    (h_cns : ClaimedNextStateCanonical env.claimed_next_state) :
    decodeEnvelope (envelopeTreeFields env payload) = .ok env := by
  cases env with | mk ver mode sp roots types asms invs libs sm cj cns rld rid =>
  dsimp at h_ver h_sm h_cns
  subst h_ver
  have h_sp : decodeSourcePin (sourcePinToTreeJson sp).toJson = .ok sp := by
    rw [sourcePinToTreeJson_toJson]; exact decodeSourcePin_sourcePinToJson sp
  have h_roots : (TreeJson.toJsonList (roots.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "root")) = Except.ok roots := by
    rw [toJsonList_map]; exact decodeStringList_ok roots
  have h_types : decodeTypesEnum (typesEnumToTreeJson types).toJson = .ok types := by
    rw [typesEnumToTreeJson_toJson]; exact decodeTypesEnum_typesEnumToJson types
  have h_asms : (TreeJson.toJsonList (asms.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "assumption")) = Except.ok asms := by
    rw [toJsonList_map]; apply list_mapM_decode_ok; intro s _; rfl
  have h_invs : (TreeJson.toJsonList (invs.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "invariant")) = Except.ok invs := by
    rw [toJsonList_map]; apply list_mapM_decode_ok; intro s _; rfl
  have h_libs := decodeLibraries_tree_ok libs
  have h_sm_dec : decodeSourceMap (sourceMapToTreeJson sm).toJson = .ok sm := by
    rw [sourceMapToTreeJson_toJson]; exact decodeSourceMap_sourceMapToJson sm h_sm
  have h_cj : (TreeJson.toJsonList (cj.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "claimedJudgment")) = Except.ok cj := by
    rw [toJsonList_map]; apply list_mapM_decode_ok; intro s _; rfl
  cases cns with
  | none =>
    have h_cns_dec : decodeClaimedNextState Lean.Json.null = .ok none := rfl
    have h_def : decodeEnvelope (envelopeTreeFields ⟨1, mode, sp, roots, types, asms, invs, libs, sm, cj, none, rld, rid⟩ payload) = (do
        let source_pin ← decodeSourcePin (sourcePinToTreeJson sp).toJson
        let audit_roots ← (TreeJson.toJsonList (roots.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "root"))
        let types ← decodeTypesEnum (typesEnumToTreeJson types).toJson
        let assumptions ← (TreeJson.toJsonList (asms.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "assumption"))
        let invariants ← (TreeJson.toJsonList (invs.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "invariant"))
        let libraries ← (TreeJson.toJsonList (libs.map libraryRefToTreeJson)).toArray.toList.mapM decodeLibraryRef
        let source_map ← decodeSourceMap (sourceMapToTreeJson sm).toJson
        let claimed_judgments ← (TreeJson.toJsonList (cj.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "claimedJudgment"))
        let claimed_next_state ← decodeClaimedNextState Lean.Json.null
        .ok ⟨1, mode, source_pin, audit_roots, types, assumptions, invariants, libraries, source_map, claimed_judgments, claimed_next_state, rld, rid⟩) := rfl
    rw [h_def, h_sp, h_roots, h_types, h_asms, h_invs, h_libs, h_sm_dec, h_cj, h_cns_dec]
    rfl
  | some w =>
    have h_cns_dec := decodeClaimedNextState_tree_some w h_cns
    have h_def : decodeEnvelope (envelopeTreeFields ⟨1, mode, sp, roots, types, asms, invs, libs, sm, cj, some w, rld, rid⟩ payload) = (do
        let source_pin ← decodeSourcePin (sourcePinToTreeJson sp).toJson
        let audit_roots ← (TreeJson.toJsonList (roots.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "root"))
        let types ← decodeTypesEnum (typesEnumToTreeJson types).toJson
        let assumptions ← (TreeJson.toJsonList (asms.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "assumption"))
        let invariants ← (TreeJson.toJsonList (invs.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "invariant"))
        let libraries ← (TreeJson.toJsonList (libs.map libraryRefToTreeJson)).toArray.toList.mapM decodeLibraryRef
        let source_map ← decodeSourceMap (sourceMapToTreeJson sm).toJson
        let claimed_judgments ← (TreeJson.toJsonList (cj.map TreeJson.str)).toArray.toList.mapM (fun x => match x with | .str s => (Except.ok s : Except DecodeFailure String) | _ => Except.error (.jsonType "claimedJudgment"))
        let claimed_next_state ← decodeClaimedNextState (worldToTreeJson w).toJson
        .ok ⟨1, mode, source_pin, audit_roots, types, assumptions, invariants, libraries, source_map, claimed_judgments, claimed_next_state, rld, rid⟩) := rfl
    rw [h_def, h_sp, h_roots, h_types, h_asms, h_invs, h_libs, h_sm_dec, h_cj, h_cns_dec]
    rfl

set_option maxHeartbeats 1000000 in
theorem decodeDecodedIR_envelopeToTreeJson_eq (env : EnvelopeEnc) (payload : TreeJson) (raw : String) :
    decodeDecodedIR ((envelopeToTreeJson env payload).toJson) raw = (do
      let env_dec ← decodeEnvelope (envelopeTreeFields env payload)
      let payloadJ_dec ← getField (envelopeTreeFields env payload) "payload"
      match env_dec.mode with
      | "typed-execute" =>
        let payload_dec ← decodeTypedExecutePayload payloadJ_dec
        Except.ok (DecodedIR.execution (.typed env_dec payload_dec))
      | "composition-step" =>
        let payload_dec ← decodeCompositionStepPayload payloadJ_dec
        Except.ok (DecodedIR.execution (.step env_dec payload_dec))
      | "composition-run" =>
        let payload_dec ← decodeCompositionRunPayload payloadJ_dec
        Except.ok (DecodedIR.execution (.run env_dec payload_dec))
      | "codec" => Except.ok (DecodedIR.codec ⟨some env_dec, raw⟩)
      | "audit" =>
        let payload_dec ← decodeAuditPayload env_dec payloadJ_dec true
        Except.ok (DecodedIR.audit payload_dec)
      | s => Except.error (.unknownIdentifier s)) := by
  dsimp [decodeDecodedIR, envelopeToTreeJson, TreeJson.toJson, TreeJson.toJsonObj, envelopeTreeFields]
  cases env.claimed_next_state <;> rfl

theorem decodeDecodedIR_fields_tree_typed (env : EnvelopeEnc) (payload : TypedExecutePayloadEnc)
    (h_ver : env.schema_version = 1)
    (h_mode : env.mode = "typed-execute")
    (h_sm : SourceMapSorted env.source_map)
    (h_cns : ClaimedNextStateCanonical env.claimed_next_state)
    (h_reg_can : RegistryCanonical payload.registry)
    (h_env_can : EnvironmentCanonical payload.env)
    (h_req_can : RequestCanonical payload.request)
    (h_state_valid : ∀ c ∈ payload.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_state_unique : (payload.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.state.cells.length)
    (raw : String) :
    decodeDecodedIR ((envelopeToTreeJson env (typedExecutePayloadToTreeJson payload)).toJson) raw =
      Except.ok (DecodedIR.execution (.typed env payload)) := by
  rw [decodeDecodedIR_envelopeToTreeJson_eq]
  have h_env := decodeEnvelope_treeFields env (typedExecutePayloadToTreeJson payload) h_ver h_sm h_cns
  have h_p := decodeTypedExecutePayload_typedExecutePayloadToTreeJson payload h_reg_can h_env_can h_req_can h_state_valid h_state_unique
  rw [h_env]
  dsimp [bind, Except.bind]
  have h_fld : getField (envelopeTreeFields env (typedExecutePayloadToTreeJson payload)) "payload" = .ok (typedExecutePayloadToTreeJson payload).toJson := rfl
  rw [h_fld]
  dsimp [bind, Except.bind]
  rw [h_mode]
  rw [h_p]
  rfl

theorem decodeDecodedIR_fields_tree_step (env : EnvelopeEnc) (payload : CompositionStepPayloadEnc)
    (h_ver : env.schema_version = 1)
    (h_mode : env.mode = "composition-step")
    (h_sm : SourceMapSorted env.source_map)
    (h_cns : ClaimedNextStateCanonical env.claimed_next_state)
    (h_cfg_can : RegistryCanonical payload.config.registry)
    (h_bnd_can : BoundaryCanonical payload.boundary)
    (h_hist_can : HistoryCanonical payload.history)
    (h_step_can : StepCanonical payload.step)
    (h_pre_valid : ∀ c ∈ payload.pre.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_pre_unique : (payload.pre.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.pre.state.cells.length)
    (raw : String) :
    decodeDecodedIR ((envelopeToTreeJson env (compositionStepPayloadToTreeJson payload)).toJson) raw =
      Except.ok (DecodedIR.execution (.step env payload)) := by
  rw [decodeDecodedIR_envelopeToTreeJson_eq]
  have h_env := decodeEnvelope_treeFields env (compositionStepPayloadToTreeJson payload) h_ver h_sm h_cns
  have h_p := decodeCompositionStepPayload_compositionStepPayloadToTreeJson payload h_cfg_can h_bnd_can h_hist_can h_step_can h_pre_valid h_pre_unique
  rw [h_env]
  dsimp [bind, Except.bind]
  have h_fld : getField (envelopeTreeFields env (compositionStepPayloadToTreeJson payload)) "payload" = .ok (compositionStepPayloadToTreeJson payload).toJson := rfl
  rw [h_fld]
  dsimp [bind, Except.bind]
  rw [h_mode]
  rw [h_p]
  rfl

theorem decodeDecodedIR_fields_tree_run (env : EnvelopeEnc) (payload : CompositionRunPayloadEnc)
    (h_ver : env.schema_version = 1)
    (h_mode : env.mode = "composition-run")
    (h_sm : SourceMapSorted env.source_map)
    (h_cns : ClaimedNextStateCanonical env.claimed_next_state)
    (h_cfg_can : RegistryCanonical payload.config.registry)
    (h_bnds_can : ∀ b ∈ payload.boundaries, BoundaryCanonical b)
    (h_steps_can : ∀ s ∈ payload.steps, StepCanonical s)
    (h_w_valid : ∀ c ∈ payload.world.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0)
    (h_w_unique : (payload.world.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.world.state.cells.length)
    (raw : String) :
    decodeDecodedIR ((envelopeToTreeJson env (compositionRunPayloadToTreeJson payload)).toJson) raw =
      Except.ok (DecodedIR.execution (.run env payload)) := by
  rw [decodeDecodedIR_envelopeToTreeJson_eq]
  have h_env := decodeEnvelope_treeFields env (compositionRunPayloadToTreeJson payload) h_ver h_sm h_cns
  have h_p := decodeCompositionRunPayload_compositionRunPayloadToJson payload h_cfg_can h_bnds_can h_steps_can h_w_valid h_w_unique
  rw [h_env]
  dsimp [bind, Except.bind]
  have h_fld : getField (envelopeTreeFields env (compositionRunPayloadToTreeJson payload)) "payload" = .ok (compositionRunPayloadToTreeJson payload).toJson := rfl
  rw [h_fld]
  dsimp [bind, Except.bind]
  rw [h_mode]
  have h_p_tree := decodeCompositionRunPayload_compositionRunPayloadToTreeJson payload h_cfg_can h_bnds_can h_steps_can h_w_valid h_w_unique
  rw [h_p_tree]
  rfl

theorem decodeDecodedIR_moduleToTreeJson_of_structurallyAdmissible (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir) (raw : String) :
    decodeDecodedIR ((moduleToTreeJson ir).toJson) raw = .ok ir := by
  rcases ir with ⟨exec⟩ | ⟨audit_val⟩ | ⟨codec_val⟩
  · rcases exec with ⟨env, payload⟩ | ⟨env, payload⟩ | ⟨env, payload⟩
    · -- typed-execute
      rcases h_adm with ⟨h_sup, h_can⟩
      dsimp [SupportedIR] at h_sup
      dsimp [CanonicalIR] at h_can
      rcases h_sup with ⟨_, _, _, h_ver, h_mode, _, h_len, h_map, h_all_pos, _, h_nodup, _⟩
      rcases h_can with ⟨h_sm, h_cns, h_all_gcd, h_tmpl, h_req, h_env⟩
      have h_reg : RegistryCanonical payload.registry := ⟨h_nodup, h_tmpl⟩
      have h_st_valid : ∀ c ∈ payload.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0 := by
        intro c hc
        have h1 := all_mem_of_all_eq_true _ _ h_all_pos c hc
        have h2 := all_mem_of_all_eq_true _ _ h_all_gcd c hc
        simp only [decide_eq_true_eq] at h1 h2
        refine ⟨by omega, h2, by omega⟩
      have h_st_unique : (payload.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.state.cells.length := by
        rw [h_map, standard32CellKeys_eraseDups_len, h_len]
      dsimp [moduleToTreeJson]
      exact decodeDecodedIR_fields_tree_typed env payload h_ver h_mode h_sm h_cns h_reg h_env h_req h_st_valid h_st_unique raw
    · -- composition-step
      rcases h_adm with ⟨h_sup, h_can⟩
      dsimp [SupportedIR] at h_sup
      dsimp [CanonicalIR] at h_can
      rcases h_sup with ⟨_, _, _, h_ver, h_mode, _, _, h_len, h_map, h_all_pos, _, h_nodup, _⟩
      rcases h_can with ⟨h_sm, h_cns, h_all_gcd, h_step, h_tmpl, h_hist, h_bnd⟩
      have h_cfg : RegistryCanonical payload.config.registry := ⟨h_nodup, h_tmpl⟩
      have h_pre_valid : ∀ c ∈ payload.pre.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0 := by
        intro c hc
        have h1 := all_mem_of_all_eq_true _ _ h_all_pos c hc
        have h2 := all_mem_of_all_eq_true _ _ h_all_gcd c hc
        simp only [decide_eq_true_eq] at h1 h2
        refine ⟨by omega, h2, by omega⟩
      have h_pre_unique : (payload.pre.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.pre.state.cells.length := by
        rw [h_map, standard32CellKeys_eraseDups_len, h_len]
      dsimp [moduleToTreeJson]
      exact decodeDecodedIR_fields_tree_step env payload h_ver h_mode h_sm h_cns h_cfg h_bnd h_hist h_step h_pre_valid h_pre_unique raw
    · -- composition-run
      rcases h_adm with ⟨h_sup, h_can⟩
      dsimp [SupportedIR] at h_sup
      dsimp [CanonicalIR] at h_can
      rcases h_sup with ⟨_, _, _, h_ver, h_mode, _, _, h_len, h_map, h_all_pos, _, h_nodup, _⟩
      rcases h_can with ⟨h_sm, h_cns, h_all_gcd, h_steps, h_tmpl, h_bnds⟩
      have h_cfg : RegistryCanonical payload.config.registry := ⟨h_nodup, h_tmpl⟩
      have h_w_valid : ∀ c ∈ payload.world.state.cells, c.amount.den ≠ 0 ∧ Int.gcd c.amount.num.natAbs c.amount.den = 1 ∧ c.amount.num ≥ 0 := by
        intro c hc
        have h1 := all_mem_of_all_eq_true _ _ h_all_pos c hc
        have h2 := all_mem_of_all_eq_true _ _ h_all_gcd c hc
        simp only [decide_eq_true_eq] at h1 h2
        refine ⟨by omega, h2, by omega⟩
      have h_w_unique : (payload.world.state.cells.map (fun c => (c.domain, c.party, c.asset))).eraseDups.length = payload.world.state.cells.length := by
        rw [h_map, standard32CellKeys_eraseDups_len, h_len]
      dsimp [moduleToTreeJson]
      exact decodeDecodedIR_fields_tree_run env payload h_ver h_mode h_sm h_cns h_cfg h_bnds h_steps h_w_valid h_w_unique raw
  · -- audit: not supported
    rcases h_adm with ⟨h_sup, _⟩
    dsimp [SupportedIR] at h_sup
    rcases h_sup with ⟨_, _, _, h_f⟩
    contradiction
  · -- codec: not supported
    rcases h_adm with ⟨h_sup, _⟩
    dsimp [SupportedIR] at h_sup
    rcases h_sup with ⟨_, _, _, h_f⟩
    contradiction

theorem decodeBytes_encodeModule_of_valid_and_depth (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_valid : TreeJson.Valid (moduleToTreeJson ir))
    (h_depth : TreeJson.depth (moduleToTreeJson ir) ≤ 64)
    (h_dec : decodeDecodedIR ((moduleToTreeJson ir).toJson) (encodeModuleString ir) = .ok ir)
    (h_lex : scanLexical (encodeModule ir) = .ok ()) :
    decodeBytes (encodeModule ir) = .ok ir := by
  have h_parse := parseCanonicalJson_encodeModuleString_tree ir h_adm h_valid h_depth
  apply decodeBytes_eq_of_steps (encodeModule ir) (encodeModuleString ir) ((moduleToTreeJson ir).toJson) ir
  · exact h_lex
  · exact string_fromUTF8_encodeModule ir
  · exact h_parse
  · exact h_dec
  · rfl

theorem decodeBytes_encodeModule_of_depth (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_depth : TreeJson.depth (moduleToTreeJson ir) ≤ 64)
    (h_dec : decodeDecodedIR ((moduleToTreeJson ir).toJson) (encodeModuleString ir) = .ok ir)
    (h_lex : scanLexical (encodeModule ir) = .ok ()) :
    decodeBytes (encodeModule ir) = .ok ir :=
  decodeBytes_encodeModule_of_valid_and_depth ir h_adm (moduleToTreeJson_valid ir h_adm) h_depth h_dec h_lex

theorem decodeBytes_encodeModule_of_depth_and_lex (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_depth : TreeJson.depth (moduleToTreeJson ir) ≤ 64)
    (h_lex : scanLexical (encodeModule ir) = .ok ()) :
    decodeBytes (encodeModule ir) = .ok ir :=
  decodeBytes_encodeModule_of_depth ir h_adm h_depth
    (decodeDecodedIR_moduleToTreeJson_of_structurallyAdmissible ir h_adm (encodeModuleString ir))
    h_lex
theorem arr_depth_le (xs : List TreeJson) (n : Nat) (h : TreeJson.depthList xs ≤ n) :
    TreeJson.depth (TreeJson.arr xs) ≤ n + 1 := by
  dsimp [TreeJson.depth]; omega

theorem obj_depth_le (kvs : List (String × TreeJson)) (n : Nat) (h : TreeJson.depthObj kvs ≤ n) :
    TreeJson.depth (TreeJson.obj kvs) ≤ n + 1 := by
  dsimp [TreeJson.depth]; omega

theorem natToTreeJson_depth (n : Nat) : TreeJson.depth (natToTreeJson n) = 0 := rfl

theorem ratToTreeJson_depth (r : RatEnc) : TreeJson.depth (ratToTreeJson r) = 1 := by
  dsimp [ratToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rfl

theorem partyToTreeJson_depth (p : Party) : TreeJson.depth (partyToTreeJson p) = 0 := by
  cases p <;> rfl

theorem domainToTreeJson_depth (d : Domain) : TreeJson.depth (domainToTreeJson d) = 0 := by
  cases d <;> rfl

theorem assetToTreeJson_depth (a : Asset) : TreeJson.depth (assetToTreeJson a) = 0 := by
  cases a <;> rfl

theorem sourcePinToTreeJson_depth (pin : SourcePinEnc) : TreeJson.depth (sourcePinToTreeJson pin) = 1 := by
  dsimp [sourcePinToTreeJson, TreeJson.depth, TreeJson.depthObj]
  cases pin.compiler_record <;> cases pin.audit_record <;> rfl

theorem libraryRefToTreeJson_depth (lib : LibraryRefEnc) : TreeJson.depth (libraryRefToTreeJson lib) = 1 := by
  dsimp [libraryRefToTreeJson, TreeJson.depth, TreeJson.depthObj]
  cases lib.moduleName <;> rfl

theorem cellToTreeJson_depth (c : CellEnc) : TreeJson.depth (cellToTreeJson c) = 1 := by
  dsimp [cellToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [domainToTreeJson_depth, partyToTreeJson_depth, assetToTreeJson_depth]
  rfl

theorem stateCellToTreeJson_depth (c : StateCellEnc) : TreeJson.depth (stateCellToTreeJson c) = 2 := by
  dsimp [stateCellToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [domainToTreeJson_depth, partyToTreeJson_depth, assetToTreeJson_depth, ratToTreeJson_depth]
  rfl

theorem stateToTreeJson_depth_le (s : StateEnc) : TreeJson.depth (stateToTreeJson s) ≤ 4 := by
  dsimp [stateToTreeJson]
  apply obj_depth_le
  dsimp [TreeJson.depthObj]
  have h_list : TreeJson.depthList (s.cells.map stateCellToTreeJson) ≤ 2 := by
    apply depthList_map_le
    intro c _
    rw [stateCellToTreeJson_depth]
  have h_arr := arr_depth_le (s.cells.map stateCellToTreeJson) 2 h_list
  omega

theorem rightToTreeJson_depth_le (r : RightEnc) : TreeJson.depth (rightToTreeJson r) ≤ 2 := by
  cases r with
  | invoke => dsimp [rightToTreeJson, TreeJson.depth, TreeJson.depthObj]; decide
  | debit c =>
    dsimp [rightToTreeJson, TreeJson.depth, TreeJson.depthObj]
    rw [cellToTreeJson_depth]
    decide
  | changeSupply d a =>
    dsimp [rightToTreeJson, TreeJson.depth, TreeJson.depthObj]
    rw [domainToTreeJson_depth, assetToTreeJson_depth]
    decide

theorem capabilityToTreeJson_depth_le (c : CapabilityEnc) : TreeJson.depth (capabilityToTreeJson c) ≤ 3 := by
  dsimp [capabilityToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [partyToTreeJson_depth, domainToTreeJson_depth, natToTreeJson_depth]
  have h_r := rightToTreeJson_depth_le c.right
  cases c.live <;> omega

theorem storeToTreeJson_depth_le (st : StoreEnc) : TreeJson.depth (storeToTreeJson st) ≤ 5 := by
  dsimp [storeToTreeJson]
  apply obj_depth_le
  dsimp [TreeJson.depthObj]
  have h_list : TreeJson.depthList (st.entries.map capabilityToTreeJson) ≤ 3 := by
    apply depthList_map_le
    intro c _
    exact capabilityToTreeJson_depth_le c
  have h_arr := arr_depth_le (st.entries.map capabilityToTreeJson) 3 h_list
  omega

theorem worldToTreeJson_depth_le (w : WorldEnc) : TreeJson.depth (worldToTreeJson w) ≤ 6 := by
  dsimp [worldToTreeJson]
  apply obj_depth_le
  dsimp [TreeJson.depthObj]
  have h_s := stateToTreeJson_depth_le w.state
  have h_c := storeToTreeJson_depth_le w.capabilities
  omega

theorem typesEnumToTreeJson_depth_le (t : TypesEnumEnc) :
    TreeJson.depth (typesEnumToTreeJson t) ≤ 2 := by
  dsimp [typesEnumToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · apply arr_depth_le
    apply depthList_map_le; intro p _; rw [partyToTreeJson_depth]
  · apply arr_depth_le
    apply depthList_map_le; intro a _; rw [assetToTreeJson_depth]
  · apply arr_depth_le
    apply depthList_map_le; intro d _; rw [domainToTreeJson_depth]

theorem sourceMapToTreeJson_depth_le (entries : List (String × String)) :
    TreeJson.depth (sourceMapToTreeJson entries) ≤ 1 := by
  dsimp [sourceMapToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  rcases List.mem_map.mp hmem with ⟨⟨k', v'⟩, _, h_eq⟩
  injection h_eq with _ h_veq
  rw [← h_veq]
  rfl

theorem envelopeToTreeJson_depth_le (env : EnvelopeEnc) (payload : TreeJson)
    (h_payload : TreeJson.depth payload ≤ 63) :
    TreeJson.depth (envelopeToTreeJson env payload) ≤ 64 := by
  dsimp [envelopeToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ |
                    ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ |
                    ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · rw [natToTreeJson_depth]; omega
  · dsimp [TreeJson.depth]; omega
  · rw [sourcePinToTreeJson_depth]; omega
  · apply arr_depth_le
    apply depthList_map_le; intro _ _; dsimp [TreeJson.depth]; omega
  · have ht := typesEnumToTreeJson_depth_le env.types; omega
  · apply arr_depth_le
    apply depthList_map_le; intro _ _; dsimp [TreeJson.depth]; omega
  · apply arr_depth_le
    apply depthList_map_le; intro _ _; dsimp [TreeJson.depth]; omega
  · have : TreeJson.depthList (env.libraries.map libraryRefToTreeJson) ≤ 1 := by
      apply depthList_map_le; intro lib _; rw [libraryRefToTreeJson_depth]
    have h_arr := arr_depth_le (env.libraries.map libraryRefToTreeJson) 1 this
    omega
  · have h_sm := sourceMapToTreeJson_depth_le env.source_map; omega
  · exact h_payload
  · apply arr_depth_le
    apply depthList_map_le; intro _ _; dsimp [TreeJson.depth]; omega
  · cases env.claimed_next_state with
    | none =>
      dsimp [TreeJson.depth]
      omega
    | some w =>
      change (worldToTreeJson w).depth ≤ 63
      have hw := worldToTreeJson_depth_le w
      omega
  · cases env.require_library_discharge <;> decide
  · cases env.require_invariant_discharge <;> decide

theorem expr_depth_ge_1 (e : ExprEnc) : e.depth ≥ 1 := by
  cases e <;> dsimp [ExprEnc.depth] <;> omega

theorem numericUnitToTreeJson_depth (nu : NumericUnitEnc) :
    TreeJson.depth (numericUnitToTreeJson nu) = 1 := by
  cases nu <;> dsimp [numericUnitToTreeJson, TreeJson.depth, TreeJson.depthObj] <;> rfl

theorem unitToTreeJson_depth_le (u : UnitEnc) :
    TreeJson.depth (unitToTreeJson u) ≤ 1 := by
  cases u with
  | bool => dsimp [unitToTreeJson, TreeJson.depth, TreeJson.depthObj]; decide
  | numeric nu =>
    dsimp [unitToTreeJson]
    rw [numericUnitToTreeJson_depth]

theorem unaryOpToTreeJson_depth_le (op : UnaryOpEnc) :
    TreeJson.depth (unaryOpToTreeJson op) ≤ 2 := by
  cases op with
  | not => dsimp [unaryOpToTreeJson, TreeJson.depth, TreeJson.depthObj]; decide
  | neg nu =>
    dsimp [unaryOpToTreeJson, TreeJson.depth, TreeJson.depthObj]
    rw [numericUnitToTreeJson_depth]
    decide

theorem binaryOpToTreeJson_depth_le (op : BinaryOpEnc) :
    TreeJson.depth (binaryOpToTreeJson op) ≤ 2 := by
  cases op with
  | add nu | sub nu | scale nu | divide nu | ratio nu | lt nu | le nu =>
    dsimp [binaryOpToTreeJson, TreeJson.depth, TreeJson.depthObj]
    rw [numericUnitToTreeJson_depth]
    decide
  | eq u =>
    dsimp [binaryOpToTreeJson, TreeJson.depth, TreeJson.depthObj]
    have := unitToTreeJson_depth_le u
    omega
  | convert a b | unconvert a b =>
    dsimp [binaryOpToTreeJson, TreeJson.depth, TreeJson.depthObj]
    rw [assetToTreeJson_depth, assetToTreeJson_depth]
    decide
  | and | or =>
    dsimp [binaryOpToTreeJson, TreeJson.depth, TreeJson.depthObj]
    decide

theorem partyRefToTreeJson_depth_le (p : PartyRefEnc) :
    TreeJson.depth (partyRefToTreeJson p) ≤ 1 := by
  cases p with
  | caller => dsimp [partyRefToTreeJson, TreeJson.depth, TreeJson.depthObj]; decide
  | literal p =>
    dsimp [partyRefToTreeJson, TreeJson.depth, TreeJson.depthObj]
    rw [partyToTreeJson_depth]
    decide
  | argument idx =>
    dsimp [partyRefToTreeJson, TreeJson.depth, TreeJson.depthObj]
    rfl

theorem cellRefToTreeJson_depth_le (c : CellRefEnc) :
    TreeJson.depth (cellRefToTreeJson c) ≤ 2 := by
  dsimp [cellRefToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [domainToTreeJson_depth]
  have := partyRefToTreeJson_depth_le c.owner
  omega

theorem packedCellRefToTreeJson_depth_le (c : PackedCellRefEnc) :
    TreeJson.depth (packedCellRefToTreeJson c) ≤ 3 := by
  dsimp [packedCellRefToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [assetToTreeJson_depth]
  have := cellRefToTreeJson_depth_le c.cell
  omega

theorem observationKeyToTreeJson_depth (k : ObservationKeyEnc) :
    TreeJson.depth (observationKeyToTreeJson k) = 1 := by
  dsimp [observationKeyToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [domainToTreeJson_depth]
  rfl

theorem observationRefToTreeJson_depth_le (r : ObservationRefEnc) :
    TreeJson.depth (observationRefToTreeJson r) ≤ 2 := by
  dsimp [observationRefToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [observationKeyToTreeJson_depth]
  have := unitToTreeJson_depth_le r.unit
  omega

theorem exprToTreeJson_depth_le (e : ExprEnc) :
    TreeJson.depth (exprToTreeJson e) ≤ e.depth + 3 := by
  induction e with
  | lit v =>
    dsimp [exprToTreeJson, ExprEnc.depth, TreeJson.depth, TreeJson.depthObj]
    cases h : v.unit with
    | bool =>
      dsimp [TreeJson.depth, TreeJson.depthObj]
      decide
    | numeric nu =>
      dsimp [TreeJson.depth, TreeJson.depthObj]
      rw [ratToTreeJson_depth, numericUnitToTreeJson_depth]
      decide
  | arg idx u =>
    dsimp [exprToTreeJson, ExprEnc.depth, TreeJson.depth, TreeJson.depthObj]
    have hu := unitToTreeJson_depth_le u
    omega
  | balance c =>
    dsimp [exprToTreeJson, ExprEnc.depth, TreeJson.depth, TreeJson.depthObj]
    have hc := packedCellRefToTreeJson_depth_le c
    omega
  | observe r =>
    dsimp [exprToTreeJson, ExprEnc.depth, TreeJson.depth, TreeJson.depthObj]
    have hr := observationRefToTreeJson_depth_le r
    omega
  | timestamp k =>
    dsimp [exprToTreeJson, ExprEnc.depth, TreeJson.depth, TreeJson.depthObj]
    rw [observationKeyToTreeJson_depth]
    decide
  | now =>
    dsimp [exprToTreeJson, ExprEnc.depth, TreeJson.depth, TreeJson.depthObj]
    decide
  | unary op x ih =>
    dsimp [exprToTreeJson, ExprEnc.depth, TreeJson.depth, TreeJson.depthObj]
    have hop := unaryOpToTreeJson_depth_le op
    have hx := expr_depth_ge_1 x
    omega
  | binary op x y ihx ihy =>
    dsimp [exprToTreeJson, ExprEnc.depth, TreeJson.depth, TreeJson.depthObj]
    have hop := binaryOpToTreeJson_depth_le op
    have hx := expr_depth_ge_1 x
    have hy := expr_depth_ge_1 y
    omega
  | ite c y n ihc ihy ihn =>
    dsimp [exprToTreeJson, ExprEnc.depth, TreeJson.depth, TreeJson.depthObj]
    omega

theorem packedValueFullToTreeJson_depth_le (v : PackedValueEnc) :
    TreeJson.depth (packedValueFullToTreeJson v) ≤ 2 := by
  dsimp [packedValueFullToTreeJson, TreeJson.depth, TreeJson.depthObj]
  cases h : v.unit with
  | bool =>
    dsimp [unitToTreeJson, packedValueToTreeJson]
    rw [h]
    dsimp
    cases v.valBool <;> decide
  | numeric nu =>
    dsimp [unitToTreeJson, packedValueToTreeJson]
    rw [h]
    dsimp
    rw [ratToTreeJson_depth, numericUnitToTreeJson_depth]
    decide

theorem contextToTreeJson_depth (ctx : ContextEnc) : TreeJson.depth (contextToTreeJson ctx) = 1 := by
  dsimp [contextToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [partyToTreeJson_depth, domainToTreeJson_depth]
  rfl

theorem observationToTreeJson_depth_le (o : ObservationEnc) :
    TreeJson.depth (observationToTreeJson o) ≤ 3 := by
  dsimp [observationToTreeJson, TreeJson.depth, TreeJson.depthObj]
  have h_v := packedValueFullToTreeJson_depth_le o.value
  rw [natToTreeJson_depth]
  omega

theorem environmentEntryToTreeJson_depth_le (e : EnvironmentEntryEnc) :
    TreeJson.depth (environmentEntryToTreeJson e) ≤ 4 := by
  dsimp [environmentEntryToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [observationKeyToTreeJson_depth]
  have h_o := observationToTreeJson_depth_le e.observation
  omega

theorem environmentToTreeJson_depth_le (env : EnvironmentEnc) :
    TreeJson.depth (environmentToTreeJson env) ≤ 6 := by
  dsimp [environmentToTreeJson]
  apply obj_depth_le
  dsimp [TreeJson.depthObj]
  have h_list : TreeJson.depthList (env.entries.map environmentEntryToTreeJson) ≤ 4 := by
    apply depthList_map_le
    intro e _
    exact environmentEntryToTreeJson_depth_le e
  have h_arr := arr_depth_le (env.entries.map environmentEntryToTreeJson) 4 h_list
  omega

theorem boundaryToTreeJson_depth_le (b : BoundaryEnc) :
    TreeJson.depth (boundaryToTreeJson b) ≤ 7 := by
  dsimp [boundaryToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [contextToTreeJson_depth, natToTreeJson_depth]
  have h_env := environmentToTreeJson_depth_le b.env
  omega

theorem qualifiedPortToTreeJson_depth (qp : QualifiedPortEnc) :
    TreeJson.depth (qualifiedPortToTreeJson qp) = 1 := by
  dsimp [qualifiedPortToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [natToTreeJson_depth]
  rfl

theorem outputObservationToTreeJson_depth_le (o : OutputObservationEnc) :
    TreeJson.depth (outputObservationToTreeJson o) ≤ 3 := by
  dsimp [outputObservationToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [natToTreeJson_depth, qualifiedPortToTreeJson_depth]
  have h_v := packedValueFullToTreeJson_depth_le o.value
  omega

theorem inputSourceToTreeJson_depth_le (i : InputSourceEnc) :
    TreeJson.depth (inputSourceToTreeJson i) ≤ 3 := by
  cases i with
  | literal v =>
    dsimp [inputSourceToTreeJson, TreeJson.depth, TreeJson.depthObj]
    have h_v := packedValueFullToTreeJson_depth_le v
    omega
  | priorOutput step port =>
    dsimp [inputSourceToTreeJson, TreeJson.depth, TreeJson.depthObj]
    rw [natToTreeJson_depth, qualifiedPortToTreeJson_depth]
    decide

theorem grantToTreeJson_depth_le (g : GrantEnc) :
    TreeJson.depth (grantToTreeJson g) ≤ 3 := by
  dsimp [grantToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [partyToTreeJson_depth, domainToTreeJson_depth, natToTreeJson_depth]
  have h_r := rightToTreeJson_depth_le g.right
  omega

theorem invocationToTreeJson_depth_le (inv : InvocationEnc) :
    TreeJson.depth (invocationToTreeJson inv) ≤ 5 := by
  dsimp [invocationToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · rw [natToTreeJson_depth]; omega
  · rw [natToTreeJson_depth]; omega
  · have h_p : TreeJson.depthList (inv.parties.map partyToTreeJson) ≤ 0 := by
      apply depthList_map_le; intro p _; rw [partyToTreeJson_depth]
    have := arr_depth_le (inv.parties.map partyToTreeJson) 0 h_p
    omega
  · have h_in : TreeJson.depthList (inv.inputs.map inputSourceToTreeJson) ≤ 3 := by
      apply depthList_map_le; intro i _; exact inputSourceToTreeJson_depth_le i
    have := arr_depth_le (inv.inputs.map inputSourceToTreeJson) 3 h_in
    omega
  · have h_c : TreeJson.depthList (inv.capabilityIds.map natToTreeJson) ≤ 0 := by
      apply depthList_map_le; intro c _; rw [natToTreeJson_depth]
    have := arr_depth_le (inv.capabilityIds.map natToTreeJson) 0 h_c
    omega
  · cases inv.claimedActor with
    | none => dsimp [TreeJson.depth]; omega
    | some a => rw [partyToTreeJson_depth]; omega

theorem stepToTreeJson_depth_le (s : StepEnc) :
    TreeJson.depth (stepToTreeJson s) ≤ 6 := by
  cases s with
  | invoke inv =>
    dsimp [stepToTreeJson, TreeJson.depth, TreeJson.depthObj]
    have := invocationToTreeJson_depth_le inv
    omega
  | issue g =>
    dsimp [stepToTreeJson, TreeJson.depth, TreeJson.depthObj]
    have := grantToTreeJson_depth_le g
    omega
  | revoke id =>
    dsimp [stepToTreeJson, TreeJson.depth, TreeJson.depthObj]
    rw [natToTreeJson_depth]
    decide
  | unsupported tag =>
    dsimp [stepToTreeJson, TreeJson.depth, TreeJson.depthObj]
    decide

theorem domainAdminToTreeJson_depth_le (d : DomainAdminEnc) :
    TreeJson.depth (domainAdminToTreeJson d) ≤ 1 := by
  dsimp [domainAdminToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [domainToTreeJson_depth, partyToTreeJson_depth]
  decide

theorem requestToTreeJson_depth_le (req : RequestEnc) :
    TreeJson.depth (requestToTreeJson req) ≤ 4 := by
  dsimp [requestToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · rw [natToTreeJson_depth]; omega
  · have h_p : TreeJson.depthList (req.parties.map partyToTreeJson) ≤ 0 := by
      apply depthList_map_le; intro p _; rw [partyToTreeJson_depth]
    have := arr_depth_le (req.parties.map partyToTreeJson) 0 h_p
    omega
  · have h_args : TreeJson.depthList (req.arguments.map packedValueFullToTreeJson) ≤ 2 := by
      apply depthList_map_le; intro a _; exact packedValueFullToTreeJson_depth_le a
    have := arr_depth_le (req.arguments.map packedValueFullToTreeJson) 2 h_args
    omega
  · have h_c : TreeJson.depthList (req.capabilityIds.map natToTreeJson) ≤ 0 := by
      apply depthList_map_le; intro c _; rw [natToTreeJson_depth]
    have := arr_depth_le (req.capabilityIds.map natToTreeJson) 0 h_c
    omega
  · cases req.claimedActor with
    | none => dsimp [TreeJson.depth]; omega
    | some a => rw [partyToTreeJson_depth]; omega

theorem canonicalWitnessIR_depth_le_64 :
    TreeJson.depth (moduleToTreeJson canonicalWitnessIR) ≤ 64 := by
  dsimp [canonicalWitnessIR, moduleToTreeJson]
  apply envelopeToTreeJson_depth_le
  dsimp [typedExecutePayloadToTreeJson, registryToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · decide
  · have := storeToTreeJson_depth_le ⟨[]⟩; omega
  · rw [contextToTreeJson_depth]; omega
  · have := environmentToTreeJson_depth_le ⟨[]⟩; omega
  · rw [natToTreeJson_depth]; omega
  · have := requestToTreeJson_depth_le ⟨0, [.alice], [], [], some .alice⟩; omega
  · have := stateToTreeJson_depth_le ⟨standard32Cells⟩; omega

theorem collisionIR_depth_le_64 :
    TreeJson.depth (moduleToTreeJson collisionIR) ≤ 64 := by
  dsimp [collisionIR, withSourceMap, canonicalWitnessIR, moduleToTreeJson]
  apply envelopeToTreeJson_depth_le
  dsimp [typedExecutePayloadToTreeJson, registryToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · decide
  · have := storeToTreeJson_depth_le ⟨[]⟩; omega
  · rw [contextToTreeJson_depth]; omega
  · have := environmentToTreeJson_depth_le ⟨[]⟩; omega
  · rw [natToTreeJson_depth]; omega
  · have := requestToTreeJson_depth_le ⟨0, [.alice], [], [], some .alice⟩; omega
  · have := stateToTreeJson_depth_le ⟨standard32Cells⟩; omega

theorem decodeBytes_encodeModule_canonicalWitnessIR
    (h_lex : scanLexical (encodeModule canonicalWitnessIR) = .ok ()) :
    decodeBytes (encodeModule canonicalWitnessIR) = .ok canonicalWitnessIR :=
  decodeBytes_encodeModule_of_depth_and_lex canonicalWitnessIR
    structurallyAdmissible_nonempty canonicalWitnessIR_depth_le_64 h_lex

theorem decodeBytes_encodeModule_collisionIR
    (h_lex : scanLexical (encodeModule collisionIR) = .ok ()) :
    decodeBytes (encodeModule collisionIR) = .ok collisionIR :=
  decodeBytes_encodeModule_of_depth_and_lex collisionIR
    escapedKeyCollision_admissible collisionIR_depth_le_64 h_lex

theorem resourcePortToTreeJson_depth_le (p : ResourcePortEnc) :
    TreeJson.depth (resourcePortToTreeJson p) ≤ 2 := by
  dsimp [resourcePortToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [natToTreeJson_depth, cellToTreeJson_depth]
  cases p.writable <;> decide

theorem inputPortToTreeJson_depth_le (p : InputPortEnc) :
    TreeJson.depth (inputPortToTreeJson p) ≤ 2 := by
  dsimp [inputPortToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [natToTreeJson_depth]
  have := unitToTreeJson_depth_le p.unit
  omega

theorem outputPortToTreeJson_depth_le (p : OutputPortEnc) :
    TreeJson.depth (outputPortToTreeJson p) ≤ 2 := by
  dsimp [outputPortToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [natToTreeJson_depth, cellToTreeJson_depth]
  rfl

theorem resourceImportToTreeJson_depth_le (ri : ResourceImportEnc) :
    TreeJson.depth (resourceImportToTreeJson ri) ≤ 2 := by
  dsimp [resourceImportToTreeJson, TreeJson.depth, TreeJson.depthObj]
  rw [qualifiedPortToTreeJson_depth, cellToTreeJson_depth]
  cases ri.writable <;> decide

theorem operationInterfaceToTreeJson_depth_le (op : OperationInterfaceEnc) :
    TreeJson.depth (operationInterfaceToTreeJson op) ≤ 4 := by
  dsimp [operationInterfaceToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · rw [natToTreeJson_depth]; omega
  · have h_ins : TreeJson.depthList (op.inputs.map inputPortToTreeJson) ≤ 2 := by
      apply depthList_map_le; intro p _; exact inputPortToTreeJson_depth_le p
    have := arr_depth_le (op.inputs.map inputPortToTreeJson) 2 h_ins
    omega
  · have h_outs : TreeJson.depthList (op.outputs.map outputPortToTreeJson) ≤ 2 := by
      apply depthList_map_le; intro p _; exact outputPortToTreeJson_depth_le p
    have := arr_depth_le (op.outputs.map outputPortToTreeJson) 2 h_outs
    omega

theorem componentToTreeJson_depth_le (c : ComponentEnc) :
    TreeJson.depth (componentToTreeJson c) ≤ 6 := by
  dsimp [componentToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · rw [natToTreeJson_depth]; omega
  · have h_privs : TreeJson.depthList (c.privateCells.map cellToTreeJson) ≤ 1 := by
      apply depthList_map_le; intro cell _; rw [cellToTreeJson_depth]
    have := arr_depth_le (c.privateCells.map cellToTreeJson) 1 h_privs
    omega
  · have h_exps : TreeJson.depthList (c.exports.map resourcePortToTreeJson) ≤ 2 := by
      apply depthList_map_le; intro p _; exact resourcePortToTreeJson_depth_le p
    have := arr_depth_le (c.exports.map resourcePortToTreeJson) 2 h_exps
    omega
  · have h_imps : TreeJson.depthList (c.imports.map resourceImportToTreeJson) ≤ 2 := by
      apply depthList_map_le; intro p _; exact resourceImportToTreeJson_depth_le p
    have := arr_depth_le (c.imports.map resourceImportToTreeJson) 2 h_imps
    omega
  · have h_ops : TreeJson.depthList (c.operations.map operationInterfaceToTreeJson) ≤ 4 := by
      apply depthList_map_le; intro op _; exact operationInterfaceToTreeJson_depth_le op
    have := arr_depth_le (c.operations.map operationInterfaceToTreeJson) 4 h_ops
    omega

theorem envReadToTreeJson_depth_le (er : EnvReadEnc) :
    TreeJson.depth (envReadToTreeJson er) ≤ 2 := by
  cases er with
  | observation k =>
    dsimp [envReadToTreeJson, TreeJson.depth, TreeJson.depthObj]
    rw [observationKeyToTreeJson_depth]
    decide
  | currentTime =>
    dsimp [envReadToTreeJson, TreeJson.depth, TreeJson.depthObj]
    decide

theorem cellDeltaToTreeJson_depth_le (d : CellDeltaEnc) :
    TreeJson.depth (cellDeltaToTreeJson d) ≤ max 2 (TreeJson.depth (exprToTreeJson d.amount)) + 1 := by
  dsimp [cellDeltaToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · rw [assetToTreeJson_depth]; omega
  · have := cellRefToTreeJson_depth_le d.target; omega
  · omega

theorem supplyDeltaToTreeJson_depth_le (s : SupplyDeltaEnc) :
    TreeJson.depth (supplyDeltaToTreeJson s) ≤ TreeJson.depth (exprToTreeJson s.amount) + 1 := by
  dsimp [supplyDeltaToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · rw [domainToTreeJson_depth]; omega
  · rw [assetToTreeJson_depth]; omega
  · omega

theorem templateToTreeJson_depth_le (t : TemplateEnc) (M : Nat)
    (h_guard : TreeJson.depth (exprToTreeJson t.guard) ≤ M)
    (h_deltas : ∀ d ∈ t.deltas, TreeJson.depth (cellDeltaToTreeJson d) ≤ M + 1)
    (h_supply : ∀ s ∈ t.supplyDeltas, TreeJson.depth (supplyDeltaToTreeJson s) ≤ M + 1) :
    TreeJson.depth (templateToTreeJson t) ≤ max 4 (M + 2) + 1 := by
  dsimp [templateToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ |
                    ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · have h_sig : TreeJson.depthList (t.signature.map unitToTreeJson) ≤ 1 := by
      apply depthList_map_le; intro u _; exact unitToTreeJson_depth_le u
    have := arr_depth_le (t.signature.map unitToTreeJson) 1 h_sig
    omega
  · rw [domainToTreeJson_depth]; omega
  · rw [natToTreeJson_depth]; omega
  · omega
  · have h_d : TreeJson.depthList (t.deltas.map cellDeltaToTreeJson) ≤ M + 1 := by
      apply depthList_map_le; intro d hd; exact h_deltas d hd
    have := arr_depth_le (t.deltas.map cellDeltaToTreeJson) (M + 1) h_d
    omega
  · have h_s : TreeJson.depthList (t.supplyDeltas.map supplyDeltaToTreeJson) ≤ M + 1 := by
      apply depthList_map_le; intro s hs; exact h_supply s hs
    have := arr_depth_le (t.supplyDeltas.map supplyDeltaToTreeJson) (M + 1) h_s
    omega
  · have h_sr : TreeJson.depthList (t.stateReads.map packedCellRefToTreeJson) ≤ 3 := by
      apply depthList_map_le; intro r _; exact packedCellRefToTreeJson_depth_le r
    have := arr_depth_le (t.stateReads.map packedCellRefToTreeJson) 3 h_sr
    omega
  · have h_er : TreeJson.depthList (t.envReads.map envReadToTreeJson) ≤ 2 := by
      apply depthList_map_le; intro er _; exact envReadToTreeJson_depth_le er
    have := arr_depth_le (t.envReads.map envReadToTreeJson) 2 h_er
    omega
  · have h_w : TreeJson.depthList (t.writes.map packedCellRefToTreeJson) ≤ 3 := by
      apply depthList_map_le; intro w _; exact packedCellRefToTreeJson_depth_le w
    have := arr_depth_le (t.writes.map packedCellRefToTreeJson) 3 h_w
    omega

theorem registryEntryToTreeJson_depth_le (e : RegistryEntryEnc) (n : Nat)
    (h : TreeJson.depth (templateToTreeJson e.template) ≤ n) :
    TreeJson.depth (registryEntryToTreeJson e) ≤ n + 1 := by
  dsimp [registryEntryToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · rw [natToTreeJson_depth]; omega
  · omega

theorem registryToTreeJson_depth_le (r : RegistryEnc) (n : Nat)
    (h : ∀ e ∈ r.entries, TreeJson.depth (registryEntryToTreeJson e) ≤ n) :
    TreeJson.depth (registryToTreeJson r) ≤ n + 2 := by
  dsimp [registryToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩
  have h_entries : TreeJson.depthList (r.entries.map registryEntryToTreeJson) ≤ n := by
    apply depthList_map_le; intro e he; exact h e he
  have := arr_depth_le (r.entries.map registryEntryToTreeJson) n h_entries
  omega

theorem registryToTreeJson_empty_depth :
    TreeJson.depth (registryToTreeJson ⟨[]⟩) = 2 := by
  dsimp [registryToTreeJson, TreeJson.depth, TreeJson.depthObj, TreeJson.depthList]
  decide

theorem configToTreeJson_depth_le (c : ConfigEnc) (n : Nat)
    (h : TreeJson.depth (registryToTreeJson c.registry) ≤ n) :
    TreeJson.depth (configToTreeJson c) ≤ max 7 n + 1 := by
  dsimp [configToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · omega
  · have h_da : TreeJson.depthList (c.domainAdmin.map domainAdminToTreeJson) ≤ 1 := by
      apply depthList_map_le; intro d _; exact domainAdminToTreeJson_depth_le d
    have := arr_depth_le (c.domainAdmin.map domainAdminToTreeJson) 1 h_da
    omega
  · have h_cat : TreeJson.depthList (c.catalog.map componentToTreeJson) ≤ 6 := by
      apply depthList_map_le; intro comp _; exact componentToTreeJson_depth_le comp
    have := arr_depth_le (c.catalog.map componentToTreeJson) 6 h_cat
    omega

theorem typedExecutePayloadToTreeJson_depth_le (p : TypedExecutePayloadEnc) (n : Nat)
    (h : TreeJson.depth (registryToTreeJson p.registry) ≤ n) :
    TreeJson.depth (typedExecutePayloadToTreeJson p) ≤ max 6 n + 1 := by
  dsimp [typedExecutePayloadToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · omega
  · have := storeToTreeJson_depth_le p.store; omega
  · rw [contextToTreeJson_depth]; omega
  · have := environmentToTreeJson_depth_le p.env; omega
  · rw [natToTreeJson_depth]; omega
  · have := requestToTreeJson_depth_le p.request; omega
  · have := stateToTreeJson_depth_le p.state; omega

theorem compositionStepPayloadToTreeJson_depth_le (p : CompositionStepPayloadEnc) (n : Nat)
    (h : TreeJson.depth (configToTreeJson p.config) ≤ n) :
    TreeJson.depth (compositionStepPayloadToTreeJson p) ≤ max 7 n + 1 := by
  dsimp [compositionStepPayloadToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · omega
  · have := boundaryToTreeJson_depth_le p.boundary; omega
  · rw [natToTreeJson_depth]; omega
  · have h_hist : TreeJson.depthList (p.history.map outputObservationToTreeJson) ≤ 3 := by
      apply depthList_map_le; intro o _; exact outputObservationToTreeJson_depth_le o
    have := arr_depth_le (p.history.map outputObservationToTreeJson) 3 h_hist
    omega
  · have := stepToTreeJson_depth_le p.step; omega
  · have := worldToTreeJson_depth_le p.pre; omega

theorem compositionRunPayloadToTreeJson_depth_le (p : CompositionRunPayloadEnc) (n : Nat)
    (h : TreeJson.depth (configToTreeJson p.config) ≤ n) :
    TreeJson.depth (compositionRunPayloadToTreeJson p) ≤ max 8 n + 1 := by
  dsimp [compositionRunPayloadToTreeJson]
  apply obj_depth_le
  apply depthObj_le
  intro k v hmem
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hmem
  rcases hmem with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · omega
  · have h_bnds : TreeJson.depthList (p.boundaries.map boundaryToTreeJson) ≤ 7 := by
      apply depthList_map_le; intro b _; exact boundaryToTreeJson_depth_le b
    have := arr_depth_le (p.boundaries.map boundaryToTreeJson) 7 h_bnds
    omega
  · have := worldToTreeJson_depth_le p.world; omega
  · have h_steps : TreeJson.depthList (p.steps.map stepToTreeJson) ≤ 6 := by
      apply depthList_map_le; intro s _; exact stepToTreeJson_depth_le s
    have := arr_depth_le (p.steps.map stepToTreeJson) 6 h_steps
    omega

theorem typedExecutePayloadToTreeJson_empty_registry_depth_le (p : TypedExecutePayloadEnc)
    (h_empty : p.registry.entries = []) :
    TreeJson.depth (typedExecutePayloadToTreeJson p) ≤ 7 := by
  have h_r : TreeJson.depth (registryToTreeJson p.registry) ≤ 2 := by
    have : p.registry = ⟨[]⟩ := congrArg RegistryEnc.mk h_empty
    rw [this]
    exact le_of_eq registryToTreeJson_empty_depth
  have h_le := typedExecutePayloadToTreeJson_depth_le p 2 h_r
  omega

theorem moduleToTreeJson_empty_registry_depth_le_64 (env : EnvelopeEnc) (p : TypedExecutePayloadEnc)
    (h_empty : p.registry.entries = []) :
    TreeJson.depth (moduleToTreeJson (.execution (.typed env p))) ≤ 64 := by
  dsimp [moduleToTreeJson]
  apply envelopeToTreeJson_depth_le
  have := typedExecutePayloadToTreeJson_empty_registry_depth_le p h_empty
  omega

theorem compositionStepPayloadToTreeJson_empty_registry_depth_le (p : CompositionStepPayloadEnc)
    (h_empty : p.config.registry.entries = []) :
    TreeJson.depth (compositionStepPayloadToTreeJson p) ≤ 9 := by
  have h_r : TreeJson.depth (registryToTreeJson p.config.registry) ≤ 2 := by
    have : p.config.registry = ⟨[]⟩ := congrArg RegistryEnc.mk h_empty
    rw [this]
    exact le_of_eq registryToTreeJson_empty_depth
  have h_cfg := configToTreeJson_depth_le p.config 2 h_r
  have h_le := compositionStepPayloadToTreeJson_depth_le p (max 7 2 + 1) h_cfg
  omega

theorem moduleToTreeJson_step_empty_registry_depth_le_64 (env : EnvelopeEnc) (p : CompositionStepPayloadEnc)
    (h_empty : p.config.registry.entries = []) :
    TreeJson.depth (moduleToTreeJson (.execution (.step env p))) ≤ 64 := by
  dsimp [moduleToTreeJson]
  apply envelopeToTreeJson_depth_le
  have := compositionStepPayloadToTreeJson_empty_registry_depth_le p h_empty
  omega

theorem compositionRunPayloadToTreeJson_empty_registry_depth_le (p : CompositionRunPayloadEnc)
    (h_empty : p.config.registry.entries = []) :
    TreeJson.depth (compositionRunPayloadToTreeJson p) ≤ 9 := by
  have h_r : TreeJson.depth (registryToTreeJson p.config.registry) ≤ 2 := by
    have : p.config.registry = ⟨[]⟩ := congrArg RegistryEnc.mk h_empty
    rw [this]
    exact le_of_eq registryToTreeJson_empty_depth
  have h_cfg := configToTreeJson_depth_le p.config 2 h_r
  have h_le := compositionRunPayloadToTreeJson_depth_le p (max 7 2 + 1) h_cfg
  omega

theorem moduleToTreeJson_run_empty_registry_depth_le_64 (env : EnvelopeEnc) (p : CompositionRunPayloadEnc)
    (h_empty : p.config.registry.entries = []) :
    TreeJson.depth (moduleToTreeJson (.execution (.run env p))) ≤ 64 := by
  dsimp [moduleToTreeJson]
  apply envelopeToTreeJson_depth_le
  have := compositionRunPayloadToTreeJson_empty_registry_depth_le p h_empty
  omega

theorem decodeBytes_encodeModule_typed_empty_registry
    (env : EnvelopeEnc) (p : TypedExecutePayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.typed env p)))
    (h_empty : p.registry.entries = [])
    (h_lex : scanLexical (encodeModule (.execution (.typed env p))) = .ok ()) :
    decodeBytes (encodeModule (.execution (.typed env p))) = .ok (.execution (.typed env p)) :=
  decodeBytes_encodeModule_of_depth_and_lex (.execution (.typed env p))
    h_adm (moduleToTreeJson_empty_registry_depth_le_64 env p h_empty) h_lex

theorem decodeBytes_encodeModule_step_empty_registry
    (env : EnvelopeEnc) (p : CompositionStepPayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.step env p)))
    (h_empty : p.config.registry.entries = [])
    (h_lex : scanLexical (encodeModule (.execution (.step env p))) = .ok ()) :
    decodeBytes (encodeModule (.execution (.step env p))) = .ok (.execution (.step env p)) :=
  decodeBytes_encodeModule_of_depth_and_lex (.execution (.step env p))
    h_adm (moduleToTreeJson_step_empty_registry_depth_le_64 env p h_empty) h_lex

theorem decodeBytes_encodeModule_run_empty_registry
    (env : EnvelopeEnc) (p : CompositionRunPayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.run env p)))
    (h_empty : p.config.registry.entries = [])
    (h_lex : scanLexical (encodeModule (.execution (.run env p))) = .ok ()) :
    decodeBytes (encodeModule (.execution (.run env p))) = .ok (.execution (.run env p)) :=
  decodeBytes_encodeModule_of_depth_and_lex (.execution (.run env p))
    h_adm (moduleToTreeJson_run_empty_registry_depth_le_64 env p h_empty) h_lex

theorem scanLexicalCheckNum_nil : scanLexicalCheckNum [] = .ok () := rfl

theorem scanLexicalFuel_zero (chars : List Char) (depth : Nat) (scopes : List LexScope)
    (currentNum : List Char) (foundWhitespace : Bool) :
    scanLexicalFuel 0 chars depth scopes currentNum foundWhitespace = .error (.resourceLimit "maxBytes") := rfl

theorem scanLexicalFuel_empty (fuel : Nat) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) [] depth scopes [] false = .ok () := rfl

theorem scanLexicalFuel_lbrace (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope)
    (h_depth : depth + 1 ≤ 64) :
    scanLexicalFuel (fuel + 1) ('{' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest (depth + 1) (LexScope.inObj [] true :: scopes) [] false := by
  dsimp [scanLexicalFuel]
  have : ¬ (depth + 1 > 64) := by omega
  rw [if_neg this]

theorem scanLexicalFuel_lbracket (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope)
    (h_depth : depth + 1 ≤ 64) :
    scanLexicalFuel (fuel + 1) ('[' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest (depth + 1) (LexScope.inArr 0 :: scopes) [] false := by
  dsimp [scanLexicalFuel]
  have : ¬ (depth + 1 > 64) := by omega
  rw [if_neg this]

theorem scanLexicalFuel_rbrace (fuel : Nat) (rest : List Char) (depth : Nat) (sc : LexScope) (scopes : List LexScope)
    (h_depth : depth > 0) :
    scanLexicalFuel (fuel + 1) ('}' :: rest) depth (sc :: scopes) [] false =
      scanLexicalFuel fuel rest (depth - 1) scopes [] false := by
  dsimp [scanLexicalFuel, scanLexicalCheckNum]
  have : (if depth > 0 then depth - 1 else 0) = depth - 1 := if_pos h_depth
  rw [this]

theorem scanLexicalFuel_rbracket (fuel : Nat) (rest : List Char) (depth : Nat) (sc : LexScope) (scopes : List LexScope)
    (h_depth : depth > 0) :
    scanLexicalFuel (fuel + 1) (']' :: rest) depth (sc :: scopes) [] false =
      scanLexicalFuel fuel rest (depth - 1) scopes [] false := by
  dsimp [scanLexicalFuel, scanLexicalCheckNum]
  have : (if depth > 0 then depth - 1 else 0) = depth - 1 := if_pos h_depth
  rw [this]

theorem scanLexicalFuel_colon (fuel : Nat) (rest : List Char) (depth : Nat) (scopes : List LexScope) :
    scanLexicalFuel (fuel + 1) (':' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest depth scopes [] false := rfl

theorem scanLexicalFuel_comma_obj (fuel : Nat) (rest : List Char) (depth : Nat)
    (keys : List String) (restScopes : List LexScope) :
    scanLexicalFuel (fuel + 1) (',' :: rest) depth (LexScope.inObj keys false :: restScopes) [] false =
      scanLexicalFuel fuel rest depth (LexScope.inObj keys true :: restScopes) [] false := rfl

theorem scanLexicalFuel_comma_arr (fuel : Nat) (rest : List Char) (depth : Nat)
    (cnt : Nat) (h_cnt : cnt + 1 ≤ 4096) (restScopes : List LexScope) :
    scanLexicalFuel (fuel + 1) (',' :: rest) depth (LexScope.inArr cnt :: restScopes) [] false =
      scanLexicalFuel fuel rest depth (LexScope.inArr (cnt + 1) :: restScopes) [] false := by
  dsimp [scanLexicalFuel, scanLexicalCheckNum]
  have : ¬ (cnt + 1 > 4096) := by omega
  rw [if_neg this]

theorem scanLexicalFuel_step_key (fuel : Nat) (s : String) (rest rest' : List Char) (depth : Nat)
    (keys : List String) (restScopes : List LexScope)
    (h_lex : lexString [] rest = .ok (s, rest'))
    (h_nodup : keys.contains s = false) :
    scanLexicalFuel (fuel + 1) ('\"' :: rest) depth (LexScope.inObj keys true :: restScopes) [] false =
      scanLexicalFuel fuel rest' depth (LexScope.inObj (s :: keys) false :: restScopes) [] false := by
  dsimp [scanLexicalFuel, scanLexicalCheckNum]
  rw [h_lex]
  dsimp
  rw [h_nodup]
  rfl

theorem scanLexicalFuel_step_str_val (fuel : Nat) (s : String) (rest rest' : List Char) (depth : Nat)
    (scopes : List LexScope)
    (h_not_key : match scopes with | LexScope.inObj _ true :: _ => false | _ => true)
    (h_lex : lexString [] rest = .ok (s, rest')) :
    scanLexicalFuel (fuel + 1) ('\"' :: rest) depth scopes [] false =
      scanLexicalFuel fuel rest' depth scopes [] false := by
  dsimp [scanLexicalFuel, scanLexicalCheckNum]
  cases scopes with
  | nil =>
    dsimp
    rw [h_lex]
  | cons sc tail =>
    cases sc with
    | inArr _ =>
      dsimp
      rw [h_lex]
    | inObj keys exp =>
      cases exp with
      | false =>
        dsimp
        rw [h_lex]
      | true =>
        contradiction

end DefiKernel.Certificates


