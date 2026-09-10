import DefiKernel.Certificates.Schema
import DefiKernel.Certificates.Decode
import DefiKernel.Certificates.Check
import DefiKernel.Certificates.Observation

namespace DefiKernel.Certificates.Tests

open DefiKernel.Certificates

def defaultSourcePin : SourcePinEnc := {
  git := "a12b7cac05a818cc8d35c2ca440b7170a2807e92"
  lean_toolchain := "leanprover/lean4:v4.33.0-rc2"
  mathlib_rev := "51e6992efd06126df61a496bebf8f49482a4e129"
  checker_candidate := "unimplemented"
  compiler_record := none
  audit_record := none
}

def defaultAuditRoots : List String := [
  "DefiKernel.Certificates",
  "DefiKernel.Typed",
  "DefiKernel.Composition"
]

def defaultEnvelope : EnvelopeEnc := {
  schema_version := 1
  mode := "typed-execute"
  source_pin := defaultSourcePin
  audit_roots := defaultAuditRoots
  types := {
    parties := [.alice, .bob, .vault, .pool]
    assets := [.usd, .share, .collateral, .debt]
    domains := [.main, .other]
  }
  assumptions := [
    "registry-trust",
    "administrator-trust",
    "context-authenticity",
    "observation-truth",
    "environment-authenticity",
    "replay-prevention-outside-model"
  ]
  invariants := []
  libraries := []
  source_map := [("transfer", "lean/DefiKernel/Typed/Examples.lean:transfer")]
  claimed_judgments := []
  claimed_next_state := none
  require_library_discharge := false
  require_invariant_discharge := false
}

def initialCells : List StateCellEnc :=
  let spec : List ((Domain × Party × Asset) × RatEnc) := [
    ((.main, .alice, .usd), ⟨10, 1⟩),
    ((.main, .alice, .share), ⟨4, 1⟩),
    ((.main, .alice, .collateral), ⟨10, 1⟩),
    ((.main, .alice, .debt), ⟨2, 1⟩),
    ((.main, .vault, .usd), ⟨20, 1⟩),
    ((.main, .pool, .usd), ⟨100, 1⟩)
  ]
  let domains : List Domain := [.main, .other]
  let parties : List Party := [.alice, .bob, .vault, .pool]
  let assets : List Asset := [.usd, .share, .collateral, .debt]
  domains.flatMap fun d ↦
    parties.flatMap fun p ↦
      assets.map fun a ↦
        let amt := match spec.find? (·.1 == (d, p, a)) with
          | some (_, r) => r
          | none => ⟨0, 1⟩
        ⟨d, p, a, amt⟩

def initialStateEnc : StateEnc := ⟨initialCells⟩

def defaultStore12 : StoreEnc := ⟨[
  ⟨.alice, .main, 0, .invoke, true⟩,
  ⟨.alice, .main, 0, .debit ⟨.main, .alice, .usd⟩, true⟩,
  ⟨.alice, .main, 1, .invoke, true⟩,
  ⟨.alice, .main, 1, .debit ⟨.main, .alice, .usd⟩, true⟩,
  ⟨.alice, .main, 1, .changeSupply .main .share, true⟩,
  ⟨.alice, .main, 2, .invoke, true⟩,
  ⟨.alice, .main, 2, .debit ⟨.main, .vault, .usd⟩, true⟩,
  ⟨.alice, .main, 2, .debit ⟨.main, .alice, .share⟩, true⟩,
  ⟨.alice, .main, 2, .changeSupply .main .share, true⟩,
  ⟨.alice, .main, 3, .invoke, true⟩,
  ⟨.alice, .main, 3, .debit ⟨.main, .pool, .usd⟩, true⟩,
  ⟨.alice, .main, 3, .changeSupply .main .debt, true⟩
]⟩

def transferTemplate : TemplateEnc := {
  signature := [.numeric (.amount .usd)]
  domain := .main
  partyArity := 1
  guard := .binary (.le (.amount .usd)) (.lit ⟨.numeric (.amount .usd), 0, false⟩) (.arg 0 (.numeric (.amount .usd)))
  deltas := [
    ⟨.usd, ⟨.main, .caller⟩, .unary (.neg (.amount .usd)) (.arg 0 (.numeric (.amount .usd)))⟩,
    ⟨.usd, ⟨.main, .argument 0⟩, .arg 0 (.numeric (.amount .usd))⟩
  ]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [
    ⟨.usd, ⟨.main, .caller⟩⟩,
    ⟨.usd, ⟨.main, .argument 0⟩⟩
  ]
}

def vaultGuardedTransfer : TemplateEnc :=
  let t := transferTemplate
  let vaultBal : ExprEnc := .balance ⟨.usd, ⟨.main, .literal .vault⟩⟩
  let ge0 : ExprEnc := .binary (.le (.amount .usd)) (.lit ⟨.numeric (.amount .usd), 0, false⟩) vaultBal
  { t with
    guard := .binary .and t.guard ge0,
    stateReads := [⟨.usd, ⟨.main, .literal .vault⟩⟩]
  }

def observeTransfer : TemplateEnc :=
  let t := transferTemplate
  let key : ObservationKeyEnc := ⟨.main, 7⟩
  let obs : ExprEnc := .observe ⟨key, .numeric (.amount .usd)⟩
  { t with
    deltas := [
      ⟨.usd, ⟨.main, .caller⟩, .unary (.neg (.amount .usd)) obs⟩,
      ⟨.usd, ⟨.main, .argument 0⟩, obs⟩
    ],
    envReads := [.observation key]
  }

def unbalancedTemplate : TemplateEnc := {
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit ⟨.bool, 0, true⟩
  deltas := [
    ⟨.usd, ⟨.main, .caller⟩, .unary (.neg (.amount .usd)) (.lit ⟨.numeric (.amount .usd), 3, false⟩)⟩,
    ⟨.usd, ⟨.main, .literal .bob⟩, .lit ⟨.numeric (.amount .usd), 4, false⟩⟩
  ]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [
    ⟨.usd, ⟨.main, .caller⟩⟩,
    ⟨.usd, ⟨.main, .literal .bob⟩⟩
  ]
}

def defaultRegistry : RegistryEnc := ⟨[
  ⟨0, transferTemplate⟩,
  ⟨4, vaultGuardedTransfer⟩,
  ⟨6, observeTransfer⟩
]⟩

def defaultContext : ContextEnc := ⟨.alice, .main⟩

def defaultRequest : RequestEnc := {
  operation := 0
  parties := [.bob]
  arguments := [⟨.numeric (.amount .usd), 3, false⟩]
  capabilityIds := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  claimedActor := none
}

def defaultPayload : TypedExecutePayloadEnc := {
  registry := defaultRegistry
  store := defaultStore12
  ctx := defaultContext
  env := ⟨[]⟩
  now := 100
  request := defaultRequest
  state := initialStateEnc
}

def catalogOk : List ComponentEnc := [
  {
    id := 0
    privateCells := [⟨.main, .bob, .usd⟩]
    exports := [⟨10, ⟨.main, .alice, .usd⟩, true⟩]
    imports := []
    operations := [{
      operation := 0
      inputs := [⟨0, .numeric (.amount .usd)⟩]
      outputs := [⟨1, ⟨.main, .alice, .usd⟩⟩]
    }]
  },
  {
    id := 1
    privateCells := [⟨.main, .vault, .usd⟩, ⟨.main, .alice, .share⟩]
    exports := []
    imports := [⟨⟨0, 10⟩, ⟨.main, .alice, .usd⟩, true⟩]
    operations := []
  },
  {
    id := 2
    privateCells := [⟨.main, .alice, .collateral⟩]
    exports := []
    imports := []
    operations := []
  }
]

def catalogDupIds : List ComponentEnc :=
  let other : ComponentEnc := {
    id := 0
    privateCells := [⟨.other, .pool, .debt⟩]
    exports := []
    imports := []
    operations := []
  }
  [catalogOk[0]!, other, catalogOk[1]!, catalogOk[2]!]

def catalogExportPrivate : List ComponentEnc :=
  let c0 := catalogOk[0]!
  let bad0 : ComponentEnc := { c0 with
    exports := [⟨10, ⟨.main, .alice, .usd⟩, true⟩, ⟨11, ⟨.main, .bob, .usd⟩, true⟩],
    operations := [{
      operation := 0,
      inputs := [⟨0, .numeric (.amount .usd)⟩],
      outputs := [⟨1, ⟨.main, .alice, .usd⟩⟩]
    }]
  }
  [bad0, catalogOk[1]!, catalogOk[2]!]

def catalogNoVaultRead : List ComponentEnc :=
  let c0 := catalogOk[0]!
  let c0' : ComponentEnc := { c0 with
    operations := c0.operations ++ [{
      operation := 4,
      inputs := [⟨2, .numeric (.amount .usd)⟩],
      outputs := [⟨3, ⟨.main, .alice, .usd⟩⟩]
    }]
  }
  [c0', catalogOk[1]!, catalogOk[2]!]

def defaultConfig : ConfigEnc := {
  registry := defaultRegistry
  domainAdmin := [⟨.main, .vault⟩, ⟨.other, .vault⟩]
  catalog := catalogOk
}

def defaultStep : StepEnc := .invoke {
  component := 0
  operation := 0
  parties := [.bob]
  inputs := [.literal ⟨.numeric (.amount .usd), 3, false⟩]
  capabilityIds := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  claimedActor := none
}

def defaultStepPayload : CompositionStepPayloadEnc := {
  config := defaultConfig
  boundary := ⟨defaultContext, ⟨[]⟩, 100⟩
  index := 0
  history := []
  step := defaultStep
  pre := ⟨initialStateEnc, defaultStore12⟩
}

-- 19 runtime comparison checks

def checkTypingRecomputed : Bool :=
  let rep := checkTyped { defaultEnvelope with claimed_judgments := ["typeCorrect"] }
    { defaultPayload with request := { defaultRequest with arguments := [⟨.numeric (.amount .share), 3, false⟩] } }
  rep.judgments.any (fun j => j.family == "typeCorrect" ∧ j.outcome == .«false»)

def checkTransferAlice7 : Bool :=
  let rep := checkTyped defaultEnvelope defaultPayload
  rep.status == .accepted ∧
  rep.world.state.cells.any (fun c => c.domain == .main ∧ c.party == .alice ∧ c.asset == .usd ∧ c.amount == ⟨7, 1⟩)

def checkExecuteRecomputed : Bool :=
  let rep := checkTyped { defaultEnvelope with claimed_next_state := some ⟨initialStateEnc, defaultStore12⟩ } defaultPayload
  rep.status == .refused ∧ rep.failure == some ⟨.observationMismatch, "claimedNextState", none⟩

def checkAccountingRecomputed : Bool :=
  let reg23 : RegistryEnc := ⟨defaultRegistry.entries ++ [⟨11, unbalancedTemplate⟩]⟩
  let st23 : StoreEnc := ⟨defaultStore12.entries ++ [
    ⟨.alice, .main, 11, .invoke, true⟩,
    ⟨.alice, .main, 11, .debit ⟨.main, .alice, .usd⟩, true⟩
  ]⟩
  let req23 : RequestEnc := {
    operation := 11
    parties := []
    arguments := []
    capabilityIds := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    claimedActor := none
  }
  let rep := checkTyped defaultEnvelope { defaultPayload with registry := reg23, store := st23, request := req23 }
  rep.failure == some ⟨.kernel, "accounting", none⟩

def checkAuthorityDebit : Bool :=
  let rep := checkTyped defaultEnvelope { defaultPayload with request := { defaultRequest with capabilityIds := [0] } }
  rep.failure == some ⟨.kernel, "unauthorizedDebit", none⟩

def checkCatalogNodup : Bool :=
  let rep := checkStep defaultEnvelope { defaultStepPayload with config := { defaultConfig with catalog := catalogDupIds } }
  rep.failure == some ⟨.configuration, "configuration", none⟩

def checkCatalogExportNotPrivate : Bool :=
  let rep := checkStep defaultEnvelope { defaultStepPayload with config := { defaultConfig with catalog := catalogExportPrivate } }
  rep.failure == some ⟨.configuration, "configuration", none⟩

def checkAccessReads : Bool :=
  let st47 : StoreEnc := ⟨defaultStore12.entries ++ [
    ⟨.alice, .main, 4, .invoke, true⟩,
    ⟨.alice, .main, 4, .debit ⟨.main, .alice, .usd⟩, true⟩
  ]⟩
  let step47 : StepEnc := .invoke {
    component := 0
    operation := 4
    parties := [.bob]
    inputs := [.literal ⟨.numeric (.amount .usd), 3, false⟩]
    capabilityIds := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    claimedActor := none
  }
  let rep := checkStep defaultEnvelope { defaultStepPayload with
    config := { defaultConfig with catalog := catalogNoVaultRead },
    step := step47,
    pre := ⟨initialStateEnc, st47⟩
  }
  rep.failure == some ⟨.interface, "readAccess", none⟩

def checkStepAlice7 : Bool :=
  let rep := checkStep defaultEnvelope defaultStepPayload
  rep.status == .accepted ∧
  rep.world.state.cells.any (fun c => c.domain == .main ∧ c.party == .alice ∧ c.asset == .usd ∧ c.amount == ⟨7, 1⟩)

def checkRationalCanonical : Bool :=
  match decodeRational 2 4 with
  | Except.error (DecodeFailure.illegalRational IllegalRationalReason.noncanonical) => true
  | _ => false

def checkRationalZeroDen : Bool :=
  match decodeRational 1 0 with
  | Except.error (DecodeFailure.illegalRational IllegalRationalReason.zeroDenominator) => true
  | _ => false

def checkPrecedenceActorMismatch : Bool :=
  let rep := checkTyped defaultEnvelope { defaultPayload with request := { defaultRequest with claimedActor := some .bob, capabilityIds := [] } }
  rep.failure == some ⟨.kernel, "actorMismatch", none⟩

def checkLibraryOutstanding : Bool :=
  let rep := checkTyped { defaultEnvelope with libraries := [⟨"asset_delta_balance", none⟩] } defaultPayload
  rep.judgments.any (fun j => j.family == "libraryTheoremsInstantiated" ∧ j.outcome == .notApplicable) ∧
  rep.outstanding.contains "asset_delta_balance"

def checkPropNotExecutable : Bool :=
  let rep := checkTyped { defaultEnvelope with invariants := ["10 ≤ collateral"] } defaultPayload
  rep.judgments.any (fun j => j.family == "sourceRefinement" ∧ j.outcome == .notApplicable) ∧
  rep.outstanding.contains "10 ≤ collateral"

def checkRefusalConstructor : Bool :=
  let r1 : Report := {
    status := .refused
    failure := some ⟨.kernel, "insufficientFunds", none⟩
    judgments := []
    world := ⟨initialStateEnc, defaultStore12⟩
    receipt := none
    outputs := []
    events := []
    nextIndex := 0
    cursorFailure := none
    assumptions := []
    outstanding := []
    source_pin := defaultSourcePin
    audit_roots := defaultAuditRoots
  }
  let r2 : Report := { r1 with failure := some ⟨.kernel, "unauthorizedDebit", none⟩ }
  !reportEq r1 r2

def checkFundsInsufficient : Bool :=
  let rep := checkTyped defaultEnvelope { defaultPayload with request := { defaultRequest with arguments := [⟨.numeric (.amount .usd), 11, false⟩] } }
  rep.failure == some ⟨.kernel, "insufficientFunds", none⟩

def checkCapabilityFreshId : Bool :=
  let adminBoundary : BoundaryEnc := { ctx := ⟨.vault, .main⟩, env := ⟨[]⟩, now := 100 }
  let issueStep : StepEnc := .issue ⟨.bob, .main, 0, .invoke⟩
  let rep := checkStep defaultEnvelope { defaultStepPayload with boundary := adminBoundary, step := issueStep }
  rep.status == .accepted ∧ rep.receipt == some (.issued 12)

def checkEnvMissingObservation : Bool :=
  let st40 : StoreEnc := ⟨defaultStore12.entries ++ [
    ⟨.alice, .main, 6, .invoke, true⟩
  ]⟩
  let req40 : RequestEnc := { defaultRequest with
    operation := 6
    capabilityIds := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
  }
  let rep := checkTyped defaultEnvelope { defaultPayload with
    store := st40,
    env := ⟨[]⟩,
    request := req40
  }
  rep.failure == some ⟨.kernel, "evaluation", some "missingObservation"⟩

def checkUnsupportedRejected : Bool :=
  let f53Step : Lean.Json := Lean.Json.mkObj [
    ("tag", Lean.Json.str "treeJoin"),
    ("invocation", Lean.Json.mkObj [
      ("component", Lean.Json.num 0),
      ("operation", Lean.Json.num 0),
      ("parties", Lean.Json.arr #[Lean.Json.str "bob"]),
      ("inputs", Lean.Json.arr #[Lean.Json.mkObj [
        ("tag", Lean.Json.str "literal"),
        ("value", Lean.Json.mkObj [
          ("unit", Lean.Json.mkObj [("tag", Lean.Json.str "amount"), ("asset", Lean.Json.str "usd")]),
          ("value", Lean.Json.mkObj [("num", Lean.Json.num 3), ("den", Lean.Json.num 1)])
        ])
      ]]),
      ("capabilityIds", Lean.Json.arr (#[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map Lean.Json.num)),
      ("claimedActor", Lean.Json.null)
    ])
  ]
  match decodeStep f53Step with
  | Except.error (DecodeFailure.unsupportedForm _) => true
  | _ => false

def runtimeChecks : List (String × Bool) := [
  ("cert.typing.recomputed", checkTypingRecomputed),
  ("cert.transfer.alice7", checkTransferAlice7),
  ("cert.execute.recomputed", checkExecuteRecomputed),
  ("cert.accounting.recomputed", checkAccountingRecomputed),
  ("cert.authority.debit", checkAuthorityDebit),
  ("cert.catalog.nodup", checkCatalogNodup),
  ("cert.catalog.export-not-private", checkCatalogExportNotPrivate),
  ("cert.access.reads", checkAccessReads),
  ("cert.step.alice7", checkStepAlice7),
  ("cert.rational.canonical", checkRationalCanonical),
  ("cert.rational.zero-den", checkRationalZeroDen),
  ("cert.precedence.actor-mismatch", checkPrecedenceActorMismatch),
  ("cert.library.outstanding", checkLibraryOutstanding),
  ("cert.prop.not-executable", checkPropNotExecutable),
  ("cert.refusal.constructor", checkRefusalConstructor),
  ("cert.funds.insufficient", checkFundsInsufficient),
  ("cert.capability.fresh-id", checkCapabilityFreshId),
  ("cert.env.missing-observation", checkEnvMissingObservation),
  ("cert.unsupported.rejected", checkUnsupportedRejected)
]

end DefiKernel.Certificates.Tests
