import DefiKernel.Certificates.Roundtrip
import DefiKernel.Certificates.DepthBridge

namespace DefiKernel.Certificates

set_option linter.style.longLine false
set_option linter.style.setOption false
set_option linter.style.maxHeartbeats false
set_option maxHeartbeats 4000000

open Lean

/-! Representation-metric lemmas: `jsonDepthFuel` of `*ToJson` equals `jsonDepthFuel` of
    `(*ToTreeJson).toJson` for constructors whose `mkObj` field orders differ. Combined with
    `jsonDepthFuel_toJson_eq_min` this discharges `TreeJson.depth (moduleToTreeJson ir) ≤ 64`
    from `WholeDocumentDepthBounded`. -/

theorem jsonDepthFuel_libraryRef (lib : LibraryRefEnc) (fuel : Nat) :
    jsonDepthFuel fuel (libraryRefToTreeJson lib).toJson = jsonDepthFuel fuel (libraryRefToJson lib) := by
  dsimp [libraryRefToTreeJson, libraryRefToJson]
  cases lib.moduleName with
  | none =>
    dsimp [TreeJson.toJson, TreeJson.toJsonObj]
  | some m =>
    dsimp [TreeJson.toJson, TreeJson.toJsonObj]
    refine jsonDepthFuel_mkObj_perm fuel _ _ ?_ (List.Perm.swap _ _ [])
    simp [List.map_cons, List.map_nil]

theorem jsonDepthFuel_world (w : WorldEnc) (fuel : Nat) :
    jsonDepthFuel fuel (worldToTreeJson w).toJson = jsonDepthFuel fuel (worldToJson w) := by
  dsimp [worldToTreeJson, worldToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [stateToTreeJson_toJson, storeToTreeJson_toJson]
  refine jsonDepthFuel_mkObj_perm fuel _ _ ?_ (List.Perm.swap _ _ [])
  simp [List.map_cons, List.map_nil]

theorem jsonDepthFuel_boundary (b : BoundaryEnc) (fuel : Nat) :
    jsonDepthFuel fuel (boundaryToTreeJson b).toJson = jsonDepthFuel fuel (boundaryToJson b) := by
  dsimp [boundaryToTreeJson, boundaryToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [contextToTreeJson_toJson, environmentToTreeJson_toJson, natToTreeJson_toJson]

theorem jsonDepthFuel_operationInterface (op : OperationInterfaceEnc) (fuel : Nat) :
    jsonDepthFuel fuel (operationInterfaceToTreeJson op).toJson =
      jsonDepthFuel fuel (operationInterfaceToJson op) := by
  dsimp [operationInterfaceToTreeJson, operationInterfaceToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [toJsonList_map, toJsonList_map]
  have hins : (op.inputs.map (fun x => (inputPortToTreeJson x).toJson)) = op.inputs.map inputPortToJson := by
    simp only [List.map_inj_left]; intro p _; exact inputPortToTreeJson_toJson p
  have houts : (op.outputs.map (fun x => (outputPortToTreeJson x).toJson)) = op.outputs.map outputPortToJson := by
    simp only [List.map_inj_left]; intro p _; exact outputPortToTreeJson_toJson p
  rw [hins, houts, natToTreeJson_toJson]
  refine jsonDepthFuel_mkObj_perm fuel _ _ ?_ ?_
  · simp [List.map_cons, List.map_nil]
  · refine perm_of_nodup_keys_mem _ _ ?_ ?_ ?_
    · simp [List.map_cons, List.map_nil]
    · simp [List.map_cons, List.map_nil]
    · intro p
      simp [List.mem_cons, List.not_mem_nil]
      tauto

theorem jsonDepthFuel_request (r : RequestEnc) (fuel : Nat) :
    jsonDepthFuel fuel (requestToTreeJson r).toJson = jsonDepthFuel fuel (requestToJson r) := by
  cases r with | mk op parties args caps actor =>
  have hps : (parties.map (fun x => (partyToTreeJson x).toJson)) = parties.map partyToJson := by
    simp only [List.map_inj_left]; intro p _; exact partyToTreeJson_toJson p
  have hargs : (args.map (fun x => (packedValueFullToTreeJson x).toJson)) = args.map packedValueFullToJson := by
    simp only [List.map_inj_left]; intro v _; exact packedValueFullToTreeJson_toJson v
  have hcaps : (caps.map (fun x => (natToTreeJson x).toJson)) = caps.map natToJson := by
    simp only [List.map_inj_left]; intro c _; exact natToTreeJson_toJson c
  cases actor with
  | none =>
    dsimp [requestToTreeJson, requestToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [toJsonList_map, toJsonList_map, toJsonList_map, hps, hargs, hcaps, natToTreeJson_toJson]
    refine jsonDepthFuel_mkObj_perm fuel _ _ ?_ ?_
    · simp [List.map_cons, List.map_nil]
    · refine perm_of_nodup_keys_mem _ _ ?_ ?_ ?_
      · simp [List.map_cons, List.map_nil]
      · simp [List.map_cons, List.map_nil]
      · intro p; simp [List.mem_cons, List.not_mem_nil]; tauto
  | some a =>
    dsimp [requestToTreeJson, requestToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [toJsonList_map, toJsonList_map, toJsonList_map, hps, hargs, hcaps, natToTreeJson_toJson,
        partyToTreeJson_toJson]
    refine jsonDepthFuel_mkObj_perm fuel _ _ ?_ ?_
    · simp [List.map_cons, List.map_nil]
    · refine perm_of_nodup_keys_mem _ _ ?_ ?_ ?_
      · simp [List.map_cons, List.map_nil]
      · simp [List.map_cons, List.map_nil]
      · intro p; simp [List.mem_cons, List.not_mem_nil]; tauto

theorem jsonDepthFuel_config (c : ConfigEnc) (fuel : Nat)
    (hcat : ∀ x ∈ c.catalog, ∀ f, jsonDepthFuel f (componentToTreeJson x).toJson =
      jsonDepthFuel f (componentToJson x)) :
    jsonDepthFuel fuel (configToTreeJson c).toJson = jsonDepthFuel fuel (configToJson c) := by
  cases fuel with
  | zero =>
    dsimp [configToTreeJson, configToJson, TreeJson.toJson, jsonDepthFuel]
  | succ fuel =>
    dsimp [configToTreeJson, configToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [toJsonList_map, toJsonList_map, registryToTreeJson_toJson]
    have hda : (c.domainAdmin.map (fun x => (domainAdminToTreeJson x).toJson)) =
        c.domainAdmin.map domainAdminToJson := by
      simp only [List.map_inj_left]; intro d _; exact domainAdminToTreeJson_toJson d
    rw [hda]
    have h₁ : ([("registry", registryToJson c.registry),
        ("domainAdmin", Json.arr (c.domainAdmin.map domainAdminToJson).toArray),
        ("catalog", Json.arr (c.catalog.map (fun x => (componentToTreeJson x).toJson)).toArray)].map
          Prod.fst).Nodup := by
      simp [List.map_cons, List.map_nil]
    have h₂ : ([("catalog", Json.arr (c.catalog.map componentToJson).toArray),
        ("domainAdmin", Json.arr (c.domainAdmin.map domainAdminToJson).toArray),
        ("registry", registryToJson c.registry)].map Prod.fst).Nodup := by
      simp [List.map_cons, List.map_nil]
    rw [jsonDepthFuel_mkObj_succ fuel _ h₁, jsonDepthFuel_mkObj_succ fuel _ h₂]
    simp [List.foldl]
    have harr := jsonDepthFuel_arr_congr
      (fun x => (componentToTreeJson x).toJson) componentToJson c.catalog hcat fuel
    rw [harr]
    simp [Nat.max_comm, Nat.max_left_comm]

theorem jsonDepthFuel_component (c : ComponentEnc) (fuel : Nat) :
    jsonDepthFuel fuel (componentToTreeJson c).toJson = jsonDepthFuel fuel (componentToJson c) := by
  cases fuel with
  | zero =>
    dsimp [componentToTreeJson, componentToJson, TreeJson.toJson, jsonDepthFuel]
  | succ fuel =>
    dsimp [componentToTreeJson, componentToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [toJsonList_map, toJsonList_map, toJsonList_map, toJsonList_map, natToTreeJson_toJson]
    have hpriv : (c.privateCells.map (fun x => (cellToTreeJson x).toJson)) = c.privateCells.map cellToJson := by
      simp only [List.map_inj_left]; intro x _; exact cellToTreeJson_toJson x
    have hexp : (c.exports.map (fun x => (resourcePortToTreeJson x).toJson)) = c.exports.map resourcePortToJson := by
      simp only [List.map_inj_left]; intro x _; exact resourcePortToTreeJson_toJson x
    have himp : (c.imports.map (fun x => (resourceImportToTreeJson x).toJson)) =
        c.imports.map resourceImportToJson := by
      simp only [List.map_inj_left]; intro x _; exact resourceImportToTreeJson_toJson x
    rw [hpriv, hexp, himp]
    have hops := jsonDepthFuel_arr_congr
      (fun x => (operationInterfaceToTreeJson x).toJson) operationInterfaceToJson c.operations
      (fun x _ f => jsonDepthFuel_operationInterface x f) fuel
    have h₁ : ([("id", Json.num (JsonNumber.fromNat c.id)),
        ("privateCells", Json.arr (c.privateCells.map cellToJson).toArray),
        ("exports", Json.arr (c.exports.map resourcePortToJson).toArray),
        ("imports", Json.arr (c.imports.map resourceImportToJson).toArray),
        ("operations", Json.arr (c.operations.map (fun x => (operationInterfaceToTreeJson x).toJson)).toArray)].map
          Prod.fst).Nodup := by
      simp [List.map_cons, List.map_nil]
    have h₂ : ([("exports", Json.arr (c.exports.map resourcePortToJson).toArray),
        ("id", Json.num (JsonNumber.fromNat c.id)),
        ("imports", Json.arr (c.imports.map resourceImportToJson).toArray),
        ("operations", Json.arr (c.operations.map operationInterfaceToJson).toArray),
        ("privateCells", Json.arr (c.privateCells.map cellToJson).toArray)].map Prod.fst).Nodup := by
      simp [List.map_cons, List.map_nil]
    rw [jsonDepthFuel_mkObj_succ fuel _ h₁, jsonDepthFuel_mkObj_succ fuel _ h₂]
    simp [List.foldl]
    rw [hops]
    simp [Nat.max_comm, Nat.max_left_comm]

theorem jsonDepthFuel_typedExecutePayload (p : TypedExecutePayloadEnc) (fuel : Nat) :
    jsonDepthFuel fuel (typedExecutePayloadToTreeJson p).toJson =
      jsonDepthFuel fuel (typedExecutePayloadToJson p) := by
  cases fuel with
  | zero =>
    dsimp [typedExecutePayloadToTreeJson, typedExecutePayloadToJson, TreeJson.toJson, jsonDepthFuel]
  | succ fuel =>
    dsimp [typedExecutePayloadToTreeJson, typedExecutePayloadToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [registryToTreeJson_toJson, storeToTreeJson_toJson, contextToTreeJson_toJson,
        environmentToTreeJson_toJson, natToTreeJson_toJson, stateToTreeJson_toJson]
    have hreq := jsonDepthFuel_request p.request fuel
    have h₁ : ([("registry", registryToJson p.registry),
        ("store", storeToJson p.store),
        ("ctx", contextToJson p.ctx),
        ("env", environmentToJson p.env),
        ("now", Json.num (JsonNumber.fromNat p.now)),
        ("request", (requestToTreeJson p.request).toJson),
        ("state", stateToJson p.state)].map Prod.fst).Nodup := by
      simp [List.map_cons, List.map_nil]
    have h₂ : ([("ctx", contextToJson p.ctx),
        ("env", environmentToJson p.env),
        ("now", Json.num (JsonNumber.fromNat p.now)),
        ("registry", registryToJson p.registry),
        ("request", requestToJson p.request),
        ("state", stateToJson p.state),
        ("store", storeToJson p.store)].map Prod.fst).Nodup := by
      simp [List.map_cons, List.map_nil]
    rw [jsonDepthFuel_mkObj_succ fuel _ h₁, jsonDepthFuel_mkObj_succ fuel _ h₂]
    simp [List.foldl]
    rw [hreq]
    simp [Nat.max_comm, Nat.max_left_comm]

theorem jsonDepthFuel_envelope (env : EnvelopeEnc) (payload : TreeJson) (payloadJson : Json)
    (h_payload : ∀ f, jsonDepthFuel f payload.toJson = jsonDepthFuel f payloadJson)
    (fuel : Nat) :
    jsonDepthFuel fuel (envelopeToTreeJson env payload).toJson =
      jsonDepthFuel fuel (envelopeToJson env payloadJson) := by
  cases fuel with
  | zero =>
    dsimp [envelopeToTreeJson, envelopeToJson, TreeJson.toJson, jsonDepthFuel]
  | succ fuel =>
    dsimp [envelopeToTreeJson, envelopeToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [natToTreeJson_toJson, sourcePinToTreeJson_toJson, typesEnumToTreeJson_toJson,
        sourceMapToTreeJson_toJson, toJsonList_map, toJsonList_map, toJsonList_map, toJsonList_map,
        toJsonList_map]
    have hstr (xs : List String) :
        (xs.map (fun s => (TreeJson.str s).toJson)) = xs.map Json.str := by
      simp only [List.map_inj_left]; intro s _; rfl
    rw [hstr, hstr, hstr, hstr]
    have hlibs := jsonDepthFuel_arr_congr
      (fun x => (libraryRefToTreeJson x).toJson) libraryRefToJson env.libraries
      (fun x _ f => jsonDepthFuel_libraryRef x f) fuel
    cases hns : env.claimed_next_state with
    | none =>
      simp [hns]
      have h₁ : ([("schema_version", Json.num (JsonNumber.fromNat env.schema_version)),
          ("mode", Json.str env.mode),
          ("source_pin", sourcePinToJson env.source_pin),
          ("audit_roots", Json.arr (env.audit_roots.map Json.str).toArray),
          ("types", typesEnumToJson env.types),
          ("assumptions", Json.arr (env.assumptions.map Json.str).toArray),
          ("invariants", Json.arr (env.invariants.map Json.str).toArray),
          ("libraries", Json.arr (env.libraries.map (fun x => (libraryRefToTreeJson x).toJson)).toArray),
          ("source_map", Json.mkObj (env.source_map.map (fun x => (x.1, Json.str x.2)))),
          ("payload", payload.toJson),
          ("claimed_judgments", Json.arr (env.claimed_judgments.map Json.str).toArray),
          ("claimed_next_state", TreeJson.null.toJson),
          ("require_library_discharge", Json.bool env.require_library_discharge),
          ("require_invariant_discharge", Json.bool env.require_invariant_discharge)].map
            Prod.fst).Nodup := by
        simp [List.map_cons, List.map_nil]
      have h₂ : ([("assumptions", Json.arr (env.assumptions.map Json.str).toArray),
          ("audit_roots", Json.arr (env.audit_roots.map Json.str).toArray),
          ("claimed_judgments", Json.arr (env.claimed_judgments.map Json.str).toArray),
          ("claimed_next_state", Json.null),
          ("invariants", Json.arr (env.invariants.map Json.str).toArray),
          ("libraries", Json.arr (env.libraries.map libraryRefToJson).toArray),
          ("mode", Json.str env.mode),
          ("payload", payloadJson),
          ("require_invariant_discharge", Json.bool env.require_invariant_discharge),
          ("require_library_discharge", Json.bool env.require_library_discharge),
          ("schema_version", Json.num (JsonNumber.fromNat env.schema_version)),
          ("source_map", Json.mkObj (env.source_map.map (fun x => (x.1, Json.str x.2)))),
          ("source_pin", sourcePinToJson env.source_pin),
          ("types", typesEnumToJson env.types)].map Prod.fst).Nodup := by
        simp [List.map_cons, List.map_nil]
      rw [jsonDepthFuel_mkObj_succ fuel _ h₁, jsonDepthFuel_mkObj_succ fuel _ h₂]
      dsimp only [List.foldl]
      rw [hlibs, h_payload fuel]
      have : Std.Commutative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_comm⟩
      have : Std.Associative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_assoc⟩
      ac_rfl
    | some w =>
      simp [hns]
      have hw := jsonDepthFuel_world w fuel
      have h₁ : ([("schema_version", Json.num (JsonNumber.fromNat env.schema_version)),
          ("mode", Json.str env.mode),
          ("source_pin", sourcePinToJson env.source_pin),
          ("audit_roots", Json.arr (env.audit_roots.map Json.str).toArray),
          ("types", typesEnumToJson env.types),
          ("assumptions", Json.arr (env.assumptions.map Json.str).toArray),
          ("invariants", Json.arr (env.invariants.map Json.str).toArray),
          ("libraries", Json.arr (env.libraries.map (fun x => (libraryRefToTreeJson x).toJson)).toArray),
          ("source_map", Json.mkObj (env.source_map.map (fun x => (x.1, Json.str x.2)))),
          ("payload", payload.toJson),
          ("claimed_judgments", Json.arr (env.claimed_judgments.map Json.str).toArray),
          ("claimed_next_state", (worldToTreeJson w).toJson),
          ("require_library_discharge", Json.bool env.require_library_discharge),
          ("require_invariant_discharge", Json.bool env.require_invariant_discharge)].map
            Prod.fst).Nodup := by
        simp [List.map_cons, List.map_nil]
      have h₂ : ([("assumptions", Json.arr (env.assumptions.map Json.str).toArray),
          ("audit_roots", Json.arr (env.audit_roots.map Json.str).toArray),
          ("claimed_judgments", Json.arr (env.claimed_judgments.map Json.str).toArray),
          ("claimed_next_state", worldToJson w),
          ("invariants", Json.arr (env.invariants.map Json.str).toArray),
          ("libraries", Json.arr (env.libraries.map libraryRefToJson).toArray),
          ("mode", Json.str env.mode),
          ("payload", payloadJson),
          ("require_invariant_discharge", Json.bool env.require_invariant_discharge),
          ("require_library_discharge", Json.bool env.require_library_discharge),
          ("schema_version", Json.num (JsonNumber.fromNat env.schema_version)),
          ("source_map", Json.mkObj (env.source_map.map (fun x => (x.1, Json.str x.2)))),
          ("source_pin", sourcePinToJson env.source_pin),
          ("types", typesEnumToJson env.types)].map Prod.fst).Nodup := by
        simp [List.map_cons, List.map_nil]
      rw [jsonDepthFuel_mkObj_succ fuel _ h₁, jsonDepthFuel_mkObj_succ fuel _ h₂]
      dsimp only [List.foldl]
      rw [hlibs, h_payload fuel, hw]
      have : Std.Commutative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_comm⟩
      have : Std.Associative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_assoc⟩
      ac_rfl

theorem jsonDepthFuel_decodedIR_typed (env : EnvelopeEnc) (p : TypedExecutePayloadEnc) (fuel : Nat) :
    jsonDepthFuel fuel (decodedIRToJson (.execution (.typed env p))) =
      jsonDepthFuel fuel (moduleToTreeJson (.execution (.typed env p))).toJson := by
  dsimp [decodedIRToJson, moduleToTreeJson]
  exact (jsonDepthFuel_envelope env (typedExecutePayloadToTreeJson p) (typedExecutePayloadToJson p)
    (jsonDepthFuel_typedExecutePayload p) fuel).symm

/-- Universal TreeJson depth bound for every structurally admissible typed-execute module,
    including arbitrary nonempty registries and templates. -/
theorem moduleToTreeJson_typed_depth_le_64 (env : EnvelopeEnc) (p : TypedExecutePayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.typed env p))) :
    TreeJson.depth (moduleToTreeJson (.execution (.typed env p))) ≤ 64 := by
  have h_valid := moduleToTreeJson_valid _ h_adm
  have h_wd : jsonDepth (decodedIRToJson (.execution (.typed env p))) ≤ 64 := by
    rcases h_adm with ⟨h_sup, _⟩
    exact h_sup.2.1
  have h_eq := jsonDepthFuel_decodedIR_typed env p 100
  have h_sem : jsonDepth (moduleToTreeJson (.execution (.typed env p))).toJson ≤ 64 := by
    simpa [jsonDepth] using (h_eq.symm.trans_le h_wd)
  exact TreeJson.depth_le_of_jsonDepth_toJson_le_64 _ h_valid h_sem

theorem decodeBytes_encodeModule_typed_of_lex (env : EnvelopeEnc) (p : TypedExecutePayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.typed env p)))
    (h_lex : scanLexical (encodeModule (.execution (.typed env p))) = .ok ()) :
    decodeBytes (encodeModule (.execution (.typed env p))) = .ok (.execution (.typed env p)) :=
  decodeBytes_encodeModule_of_depth_and_lex _ h_adm
    (moduleToTreeJson_typed_depth_le_64 env p h_adm) h_lex

end DefiKernel.Certificates





