import DefiKernel.Certificates.IRDepth
import DefiKernel.Certificates.DepthBridge

namespace DefiKernel.Certificates

set_option linter.style.longLine false
set_option linter.style.setOption false
set_option linter.style.maxHeartbeats false
set_option maxHeartbeats 4000000

open Lean

/-! Representation-metric lemmas for composition-step and composition-run payloads.
    Combined with `jsonDepthFuel_toJson_eq_min` and unchanged
    `WholeDocumentDepthBounded`, this discharges
    `TreeJson.depth (moduleToTreeJson ir) ≤ 64` for every structurally admissible IR. -/

theorem jsonDepthFuel_inputSource (src : InputSourceEnc) (fuel : Nat) :
    jsonDepthFuel fuel (inputSourceToTreeJson src).toJson =
      jsonDepthFuel fuel (inputSourceToJson src) := by
  cases src with
  | literal v =>
    dsimp [inputSourceToTreeJson, inputSourceToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [packedValueFullToTreeJson_toJson]
  | priorOutput step port =>
    dsimp [inputSourceToTreeJson, inputSourceToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [natToTreeJson_toJson, qualifiedPortToTreeJson_toJson]
    refine jsonDepthFuel_mkObj_perm fuel _ _ ?_ ?_
    · simp [List.map_cons, List.map_nil]
    · refine perm_of_nodup_keys_mem _ _ ?_ ?_ ?_
      · simp [List.map_cons, List.map_nil]
      · simp [List.map_cons, List.map_nil]
      · intro p; simp [List.mem_cons, List.not_mem_nil]; tauto

theorem jsonDepthFuel_invocation (inv : InvocationEnc) (fuel : Nat) :
    jsonDepthFuel fuel (invocationToTreeJson inv).toJson =
      jsonDepthFuel fuel (invocationToJson inv) := by
  cases fuel with
  | zero =>
    dsimp [invocationToTreeJson, invocationToJson, TreeJson.toJson, jsonDepthFuel]
  | succ fuel =>
    have hps : (inv.parties.map (fun x => (partyToTreeJson x).toJson)) = inv.parties.map partyToJson := by
      simp only [List.map_inj_left]; intro p _; exact partyToTreeJson_toJson p
    have hcaps : (inv.capabilityIds.map (fun x => (natToTreeJson x).toJson)) =
        inv.capabilityIds.map natToJson := by
      simp only [List.map_inj_left]; intro c _; exact natToTreeJson_toJson c
    have hins := jsonDepthFuel_arr_congr
      (fun x => (inputSourceToTreeJson x).toJson) inputSourceToJson inv.inputs
      (fun x _ f => jsonDepthFuel_inputSource x f) fuel
    cases hact : inv.claimedActor with
    | none =>
      dsimp [invocationToTreeJson, invocationToJson, TreeJson.toJson, TreeJson.toJsonObj]
      rw [toJsonList_map, toJsonList_map, toJsonList_map, hps, hcaps, natToTreeJson_toJson,
          natToTreeJson_toJson]
      simp [hact]
      have h₁ : ([("component", Json.num (JsonNumber.fromNat inv.component)),
          ("operation", Json.num (JsonNumber.fromNat inv.operation)),
          ("parties", Json.arr (inv.parties.map partyToJson).toArray),
          ("inputs", Json.arr (inv.inputs.map (fun x => (inputSourceToTreeJson x).toJson)).toArray),
          ("capabilityIds", Json.arr (inv.capabilityIds.map natToJson).toArray),
          ("claimedActor", TreeJson.null.toJson)].map Prod.fst).Nodup := by
        simp [List.map_cons, List.map_nil]
      have h₂ : ([("capabilityIds", Json.arr (inv.capabilityIds.map natToJson).toArray),
          ("claimedActor", Json.null),
          ("component", Json.num (JsonNumber.fromNat inv.component)),
          ("inputs", Json.arr (inv.inputs.map inputSourceToJson).toArray),
          ("operation", Json.num (JsonNumber.fromNat inv.operation)),
          ("parties", Json.arr (inv.parties.map partyToJson).toArray)].map Prod.fst).Nodup := by
        simp [List.map_cons, List.map_nil]
      rw [jsonDepthFuel_mkObj_succ fuel _ h₁, jsonDepthFuel_mkObj_succ fuel _ h₂]
      dsimp only [List.foldl]
      rw [hins]
      have : Std.Commutative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_comm⟩
      have : Std.Associative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_assoc⟩
      ac_rfl
    | some a =>
      dsimp [invocationToTreeJson, invocationToJson, TreeJson.toJson, TreeJson.toJsonObj]
      rw [toJsonList_map, toJsonList_map, toJsonList_map, hps, hcaps, natToTreeJson_toJson,
          natToTreeJson_toJson]
      simp [hact]
      rw [partyToTreeJson_toJson]
      have h₁ : ([("component", Json.num (JsonNumber.fromNat inv.component)),
          ("operation", Json.num (JsonNumber.fromNat inv.operation)),
          ("parties", Json.arr (inv.parties.map partyToJson).toArray),
          ("inputs", Json.arr (inv.inputs.map (fun x => (inputSourceToTreeJson x).toJson)).toArray),
          ("capabilityIds", Json.arr (inv.capabilityIds.map natToJson).toArray),
          ("claimedActor", partyToJson a)].map Prod.fst).Nodup := by
        simp [List.map_cons, List.map_nil]
      have h₂ : ([("capabilityIds", Json.arr (inv.capabilityIds.map natToJson).toArray),
          ("claimedActor", partyToJson a),
          ("component", Json.num (JsonNumber.fromNat inv.component)),
          ("inputs", Json.arr (inv.inputs.map inputSourceToJson).toArray),
          ("operation", Json.num (JsonNumber.fromNat inv.operation)),
          ("parties", Json.arr (inv.parties.map partyToJson).toArray)].map Prod.fst).Nodup := by
        simp [List.map_cons, List.map_nil]
      rw [jsonDepthFuel_mkObj_succ fuel _ h₁, jsonDepthFuel_mkObj_succ fuel _ h₂]
      dsimp only [List.foldl]
      rw [hins]
      have : Std.Commutative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_comm⟩
      have : Std.Associative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_assoc⟩
      ac_rfl

theorem jsonDepthFuel_step (s : StepEnc) (fuel : Nat) :
    jsonDepthFuel fuel (stepToTreeJson s).toJson = jsonDepthFuel fuel (stepToJson s) := by
  cases s with
  | invoke inv =>
    cases fuel with
    | zero =>
      dsimp [stepToTreeJson, stepToJson, TreeJson.toJson, jsonDepthFuel]
    | succ fuel =>
      dsimp [stepToTreeJson, stepToJson, TreeJson.toJson, TreeJson.toJsonObj]
      have hinv := jsonDepthFuel_invocation inv fuel
      have h₁ : ([("tag", Json.str "invoke"),
          ("invocation", (invocationToTreeJson inv).toJson)].map Prod.fst).Nodup := by
        simp [List.map_cons, List.map_nil]
      have h₂ : ([("invocation", invocationToJson inv),
          ("tag", Json.str "invoke")].map Prod.fst).Nodup := by
        simp [List.map_cons, List.map_nil]
      rw [jsonDepthFuel_mkObj_succ fuel _ h₁, jsonDepthFuel_mkObj_succ fuel _ h₂]
      dsimp only [List.foldl]
      rw [hinv]
      simp [Nat.max_comm]
  | issue g =>
    dsimp [stepToTreeJson, stepToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [grantToTreeJson_toJson]
    refine jsonDepthFuel_mkObj_perm fuel _ _ ?_ ?_
    · simp [List.map_cons, List.map_nil]
    · refine perm_of_nodup_keys_mem _ _ ?_ ?_ ?_
      · simp [List.map_cons, List.map_nil]
      · simp [List.map_cons, List.map_nil]
      · intro p; simp [List.mem_cons, List.not_mem_nil]; tauto
  | revoke id =>
    dsimp [stepToTreeJson, stepToJson, TreeJson.toJson, TreeJson.toJsonObj]
    rw [natToTreeJson_toJson]
    refine jsonDepthFuel_mkObj_perm fuel _ _ ?_ ?_
    · simp [List.map_cons, List.map_nil]
    · refine perm_of_nodup_keys_mem _ _ ?_ ?_ ?_
      · simp [List.map_cons, List.map_nil]
      · simp [List.map_cons, List.map_nil]
      · intro p; simp [List.mem_cons, List.not_mem_nil]; tauto
  | unsupported tag =>
    dsimp [stepToTreeJson, stepToJson, TreeJson.toJson, TreeJson.toJsonObj]

theorem jsonDepthFuel_outputObservation (o : OutputObservationEnc) (fuel : Nat) :
    jsonDepthFuel fuel (outputObservationToTreeJson o).toJson =
      jsonDepthFuel fuel (outputObservationToJson o) := by
  dsimp [outputObservationToTreeJson, outputObservationToJson, TreeJson.toJson, TreeJson.toJsonObj]
  rw [natToTreeJson_toJson, qualifiedPortToTreeJson_toJson, packedValueFullToTreeJson_toJson]
  refine jsonDepthFuel_mkObj_perm fuel _ _ ?_ ?_
  · simp [List.map_cons, List.map_nil]
  · refine perm_of_nodup_keys_mem _ _ ?_ ?_ ?_
    · simp [List.map_cons, List.map_nil]
    · simp [List.map_cons, List.map_nil]
    · intro p; simp [List.mem_cons, List.not_mem_nil]; tauto

theorem jsonDepthFuel_compositionStepPayload (p : CompositionStepPayloadEnc) (fuel : Nat) :
    jsonDepthFuel fuel (compositionStepPayloadToTreeJson p).toJson =
      jsonDepthFuel fuel (compositionStepPayloadToJson p) := by
  cases fuel with
  | zero =>
    dsimp [compositionStepPayloadToTreeJson, compositionStepPayloadToJson, TreeJson.toJson,
      jsonDepthFuel]
  | succ fuel =>
    dsimp [compositionStepPayloadToTreeJson, compositionStepPayloadToJson, TreeJson.toJson,
      TreeJson.toJsonObj]
    rw [toJsonList_map, natToTreeJson_toJson]
    have hcfg := jsonDepthFuel_config p.config fuel (fun x _ f => jsonDepthFuel_component x f)
    have hbnd := jsonDepthFuel_boundary p.boundary fuel
    have hstep := jsonDepthFuel_step p.step fuel
    have hpre := jsonDepthFuel_world p.pre fuel
    have hhist := jsonDepthFuel_arr_congr
      (fun x => (outputObservationToTreeJson x).toJson) outputObservationToJson p.history
      (fun x _ f => jsonDepthFuel_outputObservation x f) fuel
    have h₁ : ([("config", (configToTreeJson p.config).toJson),
        ("boundary", (boundaryToTreeJson p.boundary).toJson),
        ("index", Json.num (JsonNumber.fromNat p.index)),
        ("history", Json.arr (p.history.map (fun x => (outputObservationToTreeJson x).toJson)).toArray),
        ("step", (stepToTreeJson p.step).toJson),
        ("pre", (worldToTreeJson p.pre).toJson)].map Prod.fst).Nodup := by
      simp [List.map_cons, List.map_nil]
    have h₂ : ([("boundary", boundaryToJson p.boundary),
        ("config", configToJson p.config),
        ("history", Json.arr (p.history.map outputObservationToJson).toArray),
        ("index", Json.num (JsonNumber.fromNat p.index)),
        ("pre", worldToJson p.pre),
        ("step", stepToJson p.step)].map Prod.fst).Nodup := by
      simp [List.map_cons, List.map_nil]
    rw [jsonDepthFuel_mkObj_succ fuel _ h₁, jsonDepthFuel_mkObj_succ fuel _ h₂]
    dsimp only [List.foldl]
    rw [hcfg, hbnd, hhist, hstep, hpre]
    have : Std.Commutative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_comm⟩
    have : Std.Associative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_assoc⟩
    ac_rfl

theorem jsonDepthFuel_compositionRunPayload (p : CompositionRunPayloadEnc) (fuel : Nat) :
    jsonDepthFuel fuel (compositionRunPayloadToTreeJson p).toJson =
      jsonDepthFuel fuel (compositionRunPayloadToJson p) := by
  cases fuel with
  | zero =>
    dsimp [compositionRunPayloadToTreeJson, compositionRunPayloadToJson, TreeJson.toJson,
      jsonDepthFuel]
  | succ fuel =>
    dsimp [compositionRunPayloadToTreeJson, compositionRunPayloadToJson, TreeJson.toJson,
      TreeJson.toJsonObj]
    rw [toJsonList_map, toJsonList_map]
    have hcfg := jsonDepthFuel_config p.config fuel (fun x _ f => jsonDepthFuel_component x f)
    have hw := jsonDepthFuel_world p.world fuel
    have hbnds := jsonDepthFuel_arr_congr
      (fun x => (boundaryToTreeJson x).toJson) boundaryToJson p.boundaries
      (fun x _ f => jsonDepthFuel_boundary x f) fuel
    have hsteps := jsonDepthFuel_arr_congr
      (fun x => (stepToTreeJson x).toJson) stepToJson p.steps
      (fun x _ f => jsonDepthFuel_step x f) fuel
    have h₁ : ([("config", (configToTreeJson p.config).toJson),
        ("boundaries", Json.arr (p.boundaries.map (fun x => (boundaryToTreeJson x).toJson)).toArray),
        ("world", (worldToTreeJson p.world).toJson),
        ("steps", Json.arr (p.steps.map (fun x => (stepToTreeJson x).toJson)).toArray)].map
          Prod.fst).Nodup := by
      simp [List.map_cons, List.map_nil]
    have h₂ : ([("boundaries", Json.arr (p.boundaries.map boundaryToJson).toArray),
        ("config", configToJson p.config),
        ("steps", Json.arr (p.steps.map stepToJson).toArray),
        ("world", worldToJson p.world)].map Prod.fst).Nodup := by
      simp [List.map_cons, List.map_nil]
    rw [jsonDepthFuel_mkObj_succ fuel _ h₁, jsonDepthFuel_mkObj_succ fuel _ h₂]
    dsimp only [List.foldl]
    rw [hcfg, hbnds, hw, hsteps]
    have : Std.Commutative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_comm⟩
    have : Std.Associative (Nat.max : Nat → Nat → Nat) := ⟨Nat.max_assoc⟩
    ac_rfl

theorem jsonDepthFuel_decodedIR_step (env : EnvelopeEnc) (p : CompositionStepPayloadEnc)
    (fuel : Nat) :
    jsonDepthFuel fuel (decodedIRToJson (.execution (.step env p))) =
      jsonDepthFuel fuel (moduleToTreeJson (.execution (.step env p))).toJson := by
  dsimp [decodedIRToJson, moduleToTreeJson]
  exact (jsonDepthFuel_envelope env (compositionStepPayloadToTreeJson p)
    (compositionStepPayloadToJson p) (jsonDepthFuel_compositionStepPayload p) fuel).symm

theorem jsonDepthFuel_decodedIR_run (env : EnvelopeEnc) (p : CompositionRunPayloadEnc)
    (fuel : Nat) :
    jsonDepthFuel fuel (decodedIRToJson (.execution (.run env p))) =
      jsonDepthFuel fuel (moduleToTreeJson (.execution (.run env p))).toJson := by
  dsimp [decodedIRToJson, moduleToTreeJson]
  exact (jsonDepthFuel_envelope env (compositionRunPayloadToTreeJson p)
    (compositionRunPayloadToJson p) (jsonDepthFuel_compositionRunPayload p) fuel).symm

theorem jsonDepthFuel_decodedIR (ir : DecodedIR) (fuel : Nat) :
    jsonDepthFuel fuel (decodedIRToJson ir) =
      jsonDepthFuel fuel (moduleToTreeJson ir).toJson := by
  cases ir with
  | execution ex =>
    cases ex with
    | typed env p => exact jsonDepthFuel_decodedIR_typed env p fuel
    | step env p => exact jsonDepthFuel_decodedIR_step env p fuel
    | run env p => exact jsonDepthFuel_decodedIR_run env p fuel
  | audit _ =>
    dsimp [decodedIRToJson, moduleToTreeJson, TreeJson.toJson]
  | codec _ =>
    dsimp [decodedIRToJson, moduleToTreeJson, TreeJson.toJson]

/-- Universal TreeJson depth bound for every structurally admissible composition-step module. -/
theorem moduleToTreeJson_step_depth_le_64 (env : EnvelopeEnc) (p : CompositionStepPayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.step env p))) :
    TreeJson.depth (moduleToTreeJson (.execution (.step env p))) ≤ 64 := by
  have h_valid := moduleToTreeJson_valid _ h_adm
  have h_wd : jsonDepth (decodedIRToJson (.execution (.step env p))) ≤ 64 := by
    rcases h_adm with ⟨h_sup, _⟩
    exact h_sup.2.1
  have h_eq := jsonDepthFuel_decodedIR_step env p 100
  have h_sem : jsonDepth (moduleToTreeJson (.execution (.step env p))).toJson ≤ 64 := by
    simpa [jsonDepth] using (h_eq.symm.trans_le h_wd)
  exact TreeJson.depth_le_of_jsonDepth_toJson_le_64 _ h_valid h_sem

/-- Universal TreeJson depth bound for every structurally admissible composition-run module. -/
theorem moduleToTreeJson_run_depth_le_64 (env : EnvelopeEnc) (p : CompositionRunPayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.run env p))) :
    TreeJson.depth (moduleToTreeJson (.execution (.run env p))) ≤ 64 := by
  have h_valid := moduleToTreeJson_valid _ h_adm
  have h_wd : jsonDepth (decodedIRToJson (.execution (.run env p))) ≤ 64 := by
    rcases h_adm with ⟨h_sup, _⟩
    exact h_sup.2.1
  have h_eq := jsonDepthFuel_decodedIR_run env p 100
  have h_sem : jsonDepth (moduleToTreeJson (.execution (.run env p))).toJson ≤ 64 := by
    simpa [jsonDepth] using (h_eq.symm.trans_le h_wd)
  exact TreeJson.depth_le_of_jsonDepth_toJson_le_64 _ h_valid h_sem

/-- Universal TreeJson depth bound for every structurally admissible IR, including nonempty
    registries and composition-step / composition-run payloads. -/
theorem moduleToTreeJson_depth_le_64 (ir : DecodedIR) (h_adm : StructurallyAdmissibleIR ir) :
    TreeJson.depth (moduleToTreeJson ir) ≤ 64 := by
  have h_valid := moduleToTreeJson_valid ir h_adm
  have h_wd : jsonDepth (decodedIRToJson ir) ≤ 64 := by
    rcases h_adm with ⟨h_sup, _⟩
    exact h_sup.2.1
  have h_eq := jsonDepthFuel_decodedIR ir 100
  have h_sem : jsonDepth (moduleToTreeJson ir).toJson ≤ 64 := by
    simpa [jsonDepth] using (h_eq.symm.trans_le h_wd)
  exact TreeJson.depth_le_of_jsonDepth_toJson_le_64 _ h_valid h_sem

theorem decodeBytes_encodeModule_step_of_lex (env : EnvelopeEnc) (p : CompositionStepPayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.step env p)))
    (h_lex : scanLexical (encodeModule (.execution (.step env p))) = .ok ()) :
    decodeBytes (encodeModule (.execution (.step env p))) = .ok (.execution (.step env p)) :=
  decodeBytes_encodeModule_of_depth_and_lex _ h_adm
    (moduleToTreeJson_step_depth_le_64 env p h_adm) h_lex

theorem decodeBytes_encodeModule_run_of_lex (env : EnvelopeEnc) (p : CompositionRunPayloadEnc)
    (h_adm : StructurallyAdmissibleIR (.execution (.run env p)))
    (h_lex : scanLexical (encodeModule (.execution (.run env p))) = .ok ()) :
    decodeBytes (encodeModule (.execution (.run env p))) = .ok (.execution (.run env p)) :=
  decodeBytes_encodeModule_of_depth_and_lex _ h_adm
    (moduleToTreeJson_run_depth_le_64 env p h_adm) h_lex

/-- Production roundtrip with `h_depth` discharged from `StructurallyAdmissibleIR`.
    The existing `decodeBytes_encodeModule_of_depth_and_lex` signature is unchanged. -/
theorem decodeBytes_encodeModule_of_lex (ir : DecodedIR)
    (h_adm : StructurallyAdmissibleIR ir)
    (h_lex : scanLexical (encodeModule ir) = .ok ()) :
    decodeBytes (encodeModule ir) = .ok ir :=
  decodeBytes_encodeModule_of_depth_and_lex ir h_adm (moduleToTreeJson_depth_le_64 ir h_adm) h_lex

end DefiKernel.Certificates
