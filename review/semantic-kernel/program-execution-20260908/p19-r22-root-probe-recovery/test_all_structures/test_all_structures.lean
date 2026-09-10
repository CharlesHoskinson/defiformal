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
  TreeJson.obj [("id", TreeJson.num p.id), ("unit", unitToTreeJson p.unit)]

theorem inputPortToTreeJson_encode (p : InputPortEnc) :
    (inputPortToTreeJson p).encode = encodeInputPort p := by
  dsimp [inputPortToTreeJson, encodeInputPort]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [unitToTreeJson_encode]
  rfl

theorem inputPortToTreeJson_valid (p : InputPortEnc) :
    TreeJson.Valid (inputPortToTreeJson p) := by
  dsimp [inputPortToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, unitToTreeJson_valid p.unit, trivial⟩

def cellToTreeJson (c : CellEnc) : TreeJson :=
  TreeJson.obj [
    ("domain", domainToTreeJson c.domain),
    ("party", partyToTreeJson c.party),
    ("asset", assetToTreeJson c.asset)
  ]

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

def outputPortToTreeJson (p : OutputPortEnc) : TreeJson :=
  TreeJson.obj [("id", TreeJson.num p.id), ("cell", cellToTreeJson p.cell)]

theorem outputPortToTreeJson_encode (p : OutputPortEnc) :
    (outputPortToTreeJson p).encode = encodeOutputPort p := by
  dsimp [outputPortToTreeJson, encodeOutputPort]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [cellToTreeJson_encode]
  rfl

theorem outputPortToTreeJson_valid (p : OutputPortEnc) :
    TreeJson.Valid (outputPortToTreeJson p) := by
  dsimp [outputPortToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, cellToTreeJson_valid p.cell, trivial⟩

def resourcePortToTreeJson (p : ResourcePortEnc) : TreeJson :=
  TreeJson.obj [("id", TreeJson.num p.id), ("cell", cellToTreeJson p.cell), ("writable", TreeJson.bool p.writable)]

theorem resourcePortToTreeJson_encode (p : ResourcePortEnc) :
    (resourcePortToTreeJson p).encode = encodeResourcePort p := by
  dsimp [resourcePortToTreeJson, encodeResourcePort]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [cellToTreeJson_encode]
  cases p.writable <;> rfl

theorem resourcePortToTreeJson_valid (p : ResourcePortEnc) :
    TreeJson.Valid (resourcePortToTreeJson p) := by
  dsimp [resourcePortToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, cellToTreeJson_valid p.cell, trivial, trivial⟩

def qualifiedPortToTreeJson (p : QualifiedPortEnc) : TreeJson :=
  TreeJson.obj [("component", TreeJson.num p.component), ("port", TreeJson.num p.port)]

theorem qualifiedPortToTreeJson_encode (p : QualifiedPortEnc) :
    (qualifiedPortToTreeJson p).encode = encodeQualifiedPort p := by
  dsimp [qualifiedPortToTreeJson, encodeQualifiedPort]
  rw [encode_obj_eq_jsonObj]
  rfl

theorem qualifiedPortToTreeJson_valid (p : QualifiedPortEnc) :
    TreeJson.Valid (qualifiedPortToTreeJson p) := by
  dsimp [qualifiedPortToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial, trivial, trivial⟩

def resourceImportToTreeJson (p : ResourceImportEnc) : TreeJson :=
  TreeJson.obj [("source", qualifiedPortToTreeJson p.source), ("cell", cellToTreeJson p.cell), ("writable", TreeJson.bool p.writable)]

theorem resourceImportToTreeJson_encode (p : ResourceImportEnc) :
    (resourceImportToTreeJson p).encode = encodeResourceImport p := by
  dsimp [resourceImportToTreeJson, encodeResourceImport]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [qualifiedPortToTreeJson_encode, cellToTreeJson_encode]
  cases p.writable <;> rfl

theorem resourceImportToTreeJson_valid (p : ResourceImportEnc) :
    TreeJson.Valid (resourceImportToTreeJson p) := by
  dsimp [resourceImportToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, qualifiedPortToTreeJson_valid p.source, cellToTreeJson_valid p.cell, trivial, trivial⟩

def operationInterfaceToTreeJson (op : OperationInterfaceEnc) : TreeJson :=
  TreeJson.obj [
    ("operation", TreeJson.num op.operation),
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
    simp only [List.map_inj_left]; intro p _; exact inputPortToTreeJson_encode p
  have h_outs : (op.outputs.map (fun x => (outputPortToTreeJson x).encode)) = op.outputs.map encodeOutputPort := by
    simp only [List.map_inj_left]; intro p _; exact outputPortToTreeJson_encode p
  rw [h_ins, h_outs]
  rfl

theorem operationInterfaceToTreeJson_valid (op : OperationInterfaceEnc)
    (h_ins : op.inputs.length ≤ 4096)
    (h_outs : op.outputs.length ≤ 4096) :
    TreeJson.Valid (operationInterfaceToTreeJson op) := by
  dsimp [operationInterfaceToTreeJson, TreeJson.Valid, TreeJson.ValidObj]
  simp only [List.map_cons, List.map_nil]
  refine ⟨by decide, trivial,
          valid_arr_map inputPortToTreeJson op.inputs h_ins (fun p _ => inputPortToTreeJson_valid p),
          valid_arr_map outputPortToTreeJson op.outputs h_outs (fun p _ => outputPortToTreeJson_valid p),
          trivial⟩


def componentToTreeJson (c : ComponentEnc) : TreeJson :=
  TreeJson.obj [
    ("id", TreeJson.num c.id),
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
  have h_p : (c.privateCells.map (fun x => (cellToTreeJson x).encode)) = c.privateCells.map encodeCell := by
    simp only [List.map_inj_left]; intro x _; exact cellToTreeJson_encode x
  have h_e : (c.exports.map (fun x => (resourcePortToTreeJson x).encode)) = c.exports.map encodeResourcePort := by
    simp only [List.map_inj_left]; intro x _; exact resourcePortToTreeJson_encode x
  have h_i : (c.imports.map (fun x => (resourceImportToTreeJson x).encode)) = c.imports.map encodeResourceImport := by
    simp only [List.map_inj_left]; intro x _; exact resourceImportToTreeJson_encode x
  have h_o : (c.operations.map (fun x => (operationInterfaceToTreeJson x).encode)) = c.operations.map encodeOperationInterface := by
    simp only [List.map_inj_left]; intro x _; exact operationInterfaceToTreeJson_encode x
  rw [h_p, h_e, h_i, h_o]
  rfl

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

def registryEntryToTreeJson (e : RegistryEntryEnc) : TreeJson :=
  TreeJson.obj [("id", TreeJson.num e.id), ("template", templateToTreeJson e.template)]

theorem registryEntryToTreeJson_encode (e : RegistryEntryEnc) :
    (registryEntryToTreeJson e).encode = encodeRegistryEntry e := by
  dsimp [registryEntryToTreeJson, encodeRegistryEntry]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [templateToTreeJson_encode]
  rfl

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
  rw [registryToTreeJson_encode, encode_arr_map, encode_arr_map]
  have h_da : (c.domainAdmin.map (fun x => (domainAdminToTreeJson x).encode)) = c.domainAdmin.map encodeDomainAdmin := by
    simp only [List.map_inj_left]; intro x _; exact domainAdminToTreeJson_encode x
  have h_cat : (c.catalog.map (fun x => (componentToTreeJson x).encode)) = c.catalog.map encodeComponent := by
    simp only [List.map_inj_left]; intro x _; exact componentToTreeJson_encode x
  rw [h_da, h_cat]


def packedValueFullToTreeJson (v : PackedValueEnc) : TreeJson :=
  TreeJson.obj [("unit", unitToTreeJson v.unit), ("value", packedValueToTreeJson v)]

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

def inputSourceToTreeJson : InputSourceEnc → TreeJson
  | .literal v => TreeJson.obj [("tag", TreeJson.str "literal"), ("value", packedValueFullToTreeJson v)]
  | .priorOutput step port => TreeJson.obj [("tag", TreeJson.str "priorOutput"), ("step", TreeJson.num step), ("port", qualifiedPortToTreeJson port)]

theorem inputSourceToTreeJson_encode (src : InputSourceEnc) :
    (inputSourceToTreeJson src).encode = encodeInputSource src := by
  cases src with
  | literal v =>
    dsimp [inputSourceToTreeJson, encodeInputSource]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [packedValueFullToTreeJson_encode]
    rfl
  | priorOutput step port =>
    dsimp [inputSourceToTreeJson, encodeInputSource]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [qualifiedPortToTreeJson_encode]
    rfl

def invocationToTreeJson (inv : InvocationEnc) : TreeJson :=
  TreeJson.obj [
    ("component", TreeJson.num inv.component),
    ("operation", TreeJson.num inv.operation),
    ("parties", TreeJson.arr (inv.parties.map partyToTreeJson)),
    ("inputs", TreeJson.arr (inv.inputs.map inputSourceToTreeJson)),
    ("capabilityIds", TreeJson.arr (inv.capabilityIds.map TreeJson.num)),
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
  have h_caps : (inv.capabilityIds.map (fun x => (TreeJson.num x).encode)) = inv.capabilityIds.map toString := by
    simp only [List.map_inj_left]; intro x _; rfl
  rw [h_ps, h_ins, h_caps]
  cases inv.claimedActor with
  | none => rfl
  | some a =>
    dsimp
    rw [partyToTreeJson_encode]
    rfl

def rightToTreeJson : RightEnc → TreeJson
  | .invoke => TreeJson.obj [("tag", TreeJson.str "invoke")]
  | .debit c => TreeJson.obj [("tag", TreeJson.str "debit"), ("cell", cellToTreeJson c)]
  | .changeSupply d a =>
    TreeJson.obj [
      ("tag", TreeJson.str "changeSupply"),
      ("domain", domainToTreeJson d),
      ("asset", assetToTreeJson a)
    ]

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

def grantToTreeJson (g : GrantEnc) : TreeJson :=
  TreeJson.obj [
    ("holder", partyToTreeJson g.holder),
    ("domain", domainToTreeJson g.domain),
    ("operation", TreeJson.num g.operation),
    ("right", rightToTreeJson g.right)
  ]

theorem grantToTreeJson_encode (g : GrantEnc) :
    (grantToTreeJson g).encode = encodeGrant g := by
  dsimp [grantToTreeJson, encodeGrant]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [partyToTreeJson_encode, domainToTreeJson_encode, rightToTreeJson_encode]

def stepToTreeJson : StepEnc → TreeJson
  | .invoke inv => TreeJson.obj [("tag", TreeJson.str "invoke"), ("invocation", invocationToTreeJson inv)]
  | .issue g => TreeJson.obj [("tag", TreeJson.str "issue"), ("grant", grantToTreeJson g)]
  | .revoke id => TreeJson.obj [("tag", TreeJson.str "revoke"), ("id", TreeJson.num id)]
  | .unsupported tag => TreeJson.obj [("tag", TreeJson.str tag)]

theorem stepToTreeJson_encode (s : StepEnc) :
    (stepToTreeJson s).encode = encodeStep s := by
  cases s with
  | invoke inv =>
    dsimp [stepToTreeJson, encodeStep]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [invocationToTreeJson_encode]
    rfl
  | issue g =>
    dsimp [stepToTreeJson, encodeStep]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [grantToTreeJson_encode]
    rfl
  | revoke id =>
    dsimp [stepToTreeJson, encodeStep]
    rw [encode_obj_eq_jsonObj]
    rfl
  | unsupported tag =>
    dsimp [stepToTreeJson, encodeStep]
    rw [encode_obj_eq_jsonObj]
    dsimp [List.map]
    rw [escapeTreeString_eq_escapeJsonString]

def outputObservationToTreeJson (o : OutputObservationEnc) : TreeJson :=
  TreeJson.obj [
    ("step", TreeJson.num o.step),
    ("port", qualifiedPortToTreeJson o.port),
    ("value", packedValueFullToTreeJson o.value)
  ]

theorem outputObservationToTreeJson_encode (o : OutputObservationEnc) :
    (outputObservationToTreeJson o).encode = encodeOutputObservation o := by
  dsimp [outputObservationToTreeJson, encodeOutputObservation]
  rw [encode_obj_eq_jsonObj]
  dsimp [List.map]
  rw [qualifiedPortToTreeJson_encode, packedValueFullToTreeJson_encode]
  rfl

