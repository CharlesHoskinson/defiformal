import DefiKernel.Certificates.Schema
import DefiKernel.Certificates.Decode
import DefiKernel.Typed.Transition
import DefiKernel.Composition.Sequence

namespace DefiKernel.Certificates

open DefiKernel.Typed
open DefiKernel.Composition

/-- Conversion helper: map an index and expected unit to a typed variable. -/
def indexToVar : (sig : List (Typed.Unit Asset)) → (idx : Nat) → (u : Typed.Unit Asset) → Option (Typed.Var sig u)
  | [], _, _ => none
  | v :: _, 0, u =>
    if h : v = u then some (h ▸ .here) else none
  | _ :: vs, n + 1, u =>
    (indexToVar vs n u).map (fun var => .there var)

/-- Extract a typed Value from a PackedValueEnc given expected Unit. -/
def packedValueToVal (u : Typed.Unit Asset) (val : PackedValueEnc) : Option (Typed.Value u) :=
  match u, val.unit with
  | .bool, .bool => some val.valBool
  | .amount a, .numeric (.amount a') =>
    if h : a = a' then some (h ▸ val.valRat) else none
  | .price b q, .numeric (.price b' q') =>
    if h : b = b' ∧ q = q' then some (h.1 ▸ h.2 ▸ val.valRat) else none
  | .scalar, .numeric .scalar => some val.valRat
  | _, _ => none

/-- Convert an AST expression to a typed kernel expression. -/
def exprToTyped (sig : List (Typed.Unit Asset)) (u : Typed.Unit Asset) (e : ExprEnc) (fuel : Nat := 100) :
    Option (Typed.Expr Party Asset Domain sig u) :=
  match fuel with
  | 0 => none
  | fuel + 1 =>
    match e with
    | .lit val => do
      let v ← packedValueToVal u val
      some (.lit v)
    | .arg idx uEnc =>
      if h : uEnc.toUnit = u then
        (indexToVar sig idx uEnc.toUnit).map (fun var => h ▸ .arg var)
      else none
    | .balance c =>
      if h : u = .amount c.asset then
        some (h ▸ .balance ⟨c.cell.domain, c.cell.owner.toPartyRef⟩)
      else none
    | .observe r =>
      if h : r.unit.toUnit = u then
        some (h ▸ .observe ⟨⟨r.key.domain, ⟨r.key.id⟩⟩⟩)
      else none
    | .timestamp k =>
      if h : u = .scalar then
        some (h ▸ .timestamp ⟨k.domain, ⟨k.id⟩⟩)
      else none
    | .now =>
      if h : u = .scalar then some (h ▸ .now) else none
    | .unary op x =>
      match op with
      | .neg n =>
        if h : u = n.toNumericUnit.toUnit then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          some (h ▸ .unary (.neg n.toNumericUnit) x')
        else none
      | .not =>
        if h : u = .bool then do
          let x' ← exprToTyped sig .bool x fuel
          some (h ▸ .unary .not x')
        else none
    | .binary op x y =>
      match op with
      | .add n =>
        if h : u = n.toNumericUnit.toUnit then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.add n.toNumericUnit) x' y')
        else none
      | .sub n =>
        if h : u = n.toNumericUnit.toUnit then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.sub n.toNumericUnit) x' y')
        else none
      | .scale n =>
        if h : u = n.toNumericUnit.toUnit then do
          let x' ← exprToTyped sig .scalar x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.scale n.toNumericUnit) x' y')
        else none
      | .divide n =>
        if h : u = n.toNumericUnit.toUnit then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig .scalar y fuel
          some (h ▸ .binary (.divide n.toNumericUnit) x' y')
        else none
      | .ratio n =>
        if h : u = .scalar then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.ratio n.toNumericUnit) x' y')
        else none
      | .convert b q =>
        if h : u = .amount q then do
          let x' ← exprToTyped sig (.amount b) x fuel
          let y' ← exprToTyped sig (.price b q) y fuel
          some (h ▸ .binary (.convert b q) x' y')
        else none
      | .unconvert b q =>
        if h : u = .amount b then do
          let x' ← exprToTyped sig (.amount q) x fuel
          let y' ← exprToTyped sig (.price b q) y fuel
          some (h ▸ .binary (.unconvert b q) x' y')
        else none
      | .le n =>
        if h : u = .bool then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.le n.toNumericUnit) x' y')
        else none
      | .lt n =>
        if h : u = .bool then do
          let x' ← exprToTyped sig n.toNumericUnit.toUnit x fuel
          let y' ← exprToTyped sig n.toNumericUnit.toUnit y fuel
          some (h ▸ .binary (.lt n.toNumericUnit) x' y')
        else none
      | .eq eqU =>
        if h : u = .bool then do
          let x' ← exprToTyped sig eqU.toUnit x fuel
          let y' ← exprToTyped sig eqU.toUnit y fuel
          some (h ▸ .binary (.eq eqU.toUnit) x' y')
        else none
      | .and =>
        if h : u = .bool then do
          let x' ← exprToTyped sig .bool x fuel
          let y' ← exprToTyped sig .bool y fuel
          some (h ▸ .binary .and x' y')
        else none
      | .or =>
        if h : u = .bool then do
          let x' ← exprToTyped sig .bool x fuel
          let y' ← exprToTyped sig .bool y fuel
          some (h ▸ .binary .or x' y')
        else none
    | .ite c y n => do
      let c' ← exprToTyped sig .bool c fuel
      let y' ← exprToTyped sig u y fuel
      let n' ← exprToTyped sig u n fuel
      some (.ite c' y' n')

def cellDeltaToTyped (sig : List (Typed.Unit Asset)) (d : CellDeltaEnc) :
    Option (Typed.CellDelta Party Asset Domain sig) := do
  let amt ← exprToTyped sig (.amount d.asset) d.amount
  some ⟨d.asset, ⟨d.target.domain, d.target.owner.toPartyRef⟩, amt⟩

def supplyDeltaToTyped (sig : List (Typed.Unit Asset)) (d : SupplyDeltaEnc) :
    Option (Typed.SupplyDelta Party Asset Domain sig) := do
  let amt ← exprToTyped sig (.amount d.asset) d.amount
  some ⟨d.domain, d.asset, amt⟩

def templateToTyped (t : TemplateEnc) : Option (Typed.Template Party Asset Domain) := do
  let sig := t.signature.map UnitEnc.toUnit
  let guard ← exprToTyped sig .bool t.guard
  let deltas ← t.deltas.mapM (cellDeltaToTyped sig)
  let supplyDeltas ← t.supplyDeltas.mapM (supplyDeltaToTyped sig)
  let stateReads := t.stateReads.map PackedCellRefEnc.toPackedCellRef
  let envReads := t.envReads.map EnvReadEnc.toEnvRead
  let writes := t.writes.map PackedCellRefEnc.toPackedCellRef
  some ⟨sig, t.domain, t.partyArity, guard, deltas, supplyDeltas, stateReads, envReads, writes⟩

def registryToTyped (r : RegistryEnc) : Typed.Registry Party Asset Domain :=
  fun op ↦
    match r.entries.find? (fun e ↦ e.id == op.value) with
    | some e => templateToTyped e.template
    | none => none

def storeToTyped (s : StoreEnc) : Typed.CapabilityStore Party Asset Domain :=
  s.toCapabilityStore

def storeToEnc (s : Typed.CapabilityStore Party Asset Domain) : StoreEnc :=
  ⟨s.entries.map fun cap ↦ ⟨cap.1.holder, cap.1.domain, cap.1.operation.value,
    match cap.1.right with
    | .invoke => .invoke
    | .debit c => .debit ⟨c.1, c.2.1, c.2.2⟩
    | .changeSupply d a => .changeSupply d a,
    cap.2⟩⟩

def envToTyped (e : EnvironmentEnc) : Typed.Environment Asset Domain :=
  e.toEnvironment

def stateToTyped? (s : StateEnc) : Option (Typed.State Party Asset Domain) :=
  s.toState?

def configToTyped? (c : ConfigEnc) : Option (Composition.Config Party Asset Domain) := do
  let reg := registryToTyped c.registry
  let admin : Domain → Party := fun d ↦
    match c.domainAdmin.find? (fun a ↦ a.domain == d) with
    | some a => a.party
    | none => .vault
  let cat := c.catalog.map ComponentEnc.toComponent
  some ⟨reg, admin, cat⟩

def boundaryToTyped (b : BoundaryEnc) : Composition.Boundary Party Asset Domain :=
  ⟨b.ctx.toContext, envToTyped b.env, b.now⟩

structure ClaimedJudgments where
  typeCorrect : Bool := false
  footprintCorrect : Bool := false
  authorityCorrect : Bool := false
  accountingCorrect : Bool := false
  compositionCompatible : Bool := false
  assumptionsDeclared : Bool := false
  libraryTheoremsInstantiated : Bool := false
  sourceRefinement : Bool := false
  deriving DecidableEq, Repr, Inhabited

def parseClaimedJudgments (claims : List String) : ClaimedJudgments :=
  claims.foldl (fun acc s ↦
    if s == "typeCorrect" then { acc with typeCorrect := true }
    else if s == "footprintCorrect" then { acc with footprintCorrect := true }
    else if s == "authorityCorrect" then { acc with authorityCorrect := true }
    else if s == "accountingCorrect" then { acc with accountingCorrect := true }
    else if s == "compositionCompatible" then { acc with compositionCompatible := true }
    else if s == "assumptionsDeclared" then { acc with assumptionsDeclared := true }
    else if s == "libraryTheoremsInstantiated" then { acc with libraryTheoremsInstantiated := true }
    else if s == "sourceRefinement" then { acc with sourceRefinement := true }
    else acc) {}

def evalFailureToString : EvalFailure → String
  | .argumentCount => "argumentCount"
  | .argumentUnit => "argumentUnit"
  | .partyArgument => "partyArgument"
  | .missingObservation => "missingObservation"
  | .observationUnit => "observationUnit"
  | .divisionByZero => "divisionByZero"

def refusalToLocatedFailure (r : Refusal) : LocatedFailureEnc :=
  match r with
  | .unknownOperation => ⟨0, none, ⟨.kernel, "unknownOperation", none⟩⟩
  | .actorMismatch => ⟨0, none, ⟨.kernel, "actorMismatch", none⟩⟩
  | .domainMismatch => ⟨0, none, ⟨.kernel, "domainMismatch", none⟩⟩
  | .partyArity => ⟨0, none, ⟨.kernel, "partyArity", none⟩⟩
  | .evaluation ef => ⟨0, none, ⟨.kernel, "evaluation", some (evalFailureToString ef)⟩⟩
  | .unauthorizedInvoke => ⟨0, none, ⟨.kernel, "unauthorizedInvoke", none⟩⟩
  | .guard => ⟨0, none, ⟨.kernel, "guard", none⟩⟩
  | .stateReadFootprint => ⟨0, none, ⟨.kernel, "stateReadFootprint", none⟩⟩
  | .envReadFootprint => ⟨0, none, ⟨.kernel, "envReadFootprint", none⟩⟩
  | .crossDomain => ⟨0, none, ⟨.kernel, "crossDomain", none⟩⟩
  | .unauthorizedDebit => ⟨0, none, ⟨.kernel, "unauthorizedDebit", none⟩⟩
  | .unauthorizedSupply => ⟨0, none, ⟨.kernel, "unauthorizedSupply", none⟩⟩
  | .insufficientFunds => ⟨0, none, ⟨.kernel, "insufficientFunds", none⟩⟩
  | .accounting => ⟨0, none, ⟨.kernel, "accounting", none⟩⟩
  | .writeFootprint => ⟨0, none, ⟨.kernel, "writeFootprint", none⟩⟩

def failureToPath (f : Composition.Failure) : FailurePath :=
  match f with
  | .configuration => ⟨.configuration, "configuration", none⟩
  | .interface .unknownOperation => ⟨.interface, "unknownOperation", none⟩
  | .interface (.resolution ef) => ⟨.interface, "resolution", some (evalFailureToString ef)⟩
  | .interface .readAccess => ⟨.interface, "readAccess", none⟩
  | .interface .writeAccess => ⟨.interface, "writeAccess", none⟩
  | .interface .inputCount => ⟨.interface, "inputCount", none⟩
  | .interface .inputUnit => ⟨.interface, "inputUnit", none⟩
  | .interface .unavailableOutput => ⟨.interface, "unavailableOutput", none⟩
  | .kernel r => (refusalToLocatedFailure r).reason
  | .authority .unauthorizedAdmin => ⟨.authority, "unauthorizedAdmin", none⟩
  | .authority .operationDomain => ⟨.authority, "operationDomain", none⟩
  | .authority .resourceDomain => ⟨.authority, "resourceDomain", none⟩
  | .authority .unknownCapability => ⟨.authority, "unknownCapability", none⟩
  | .internalReceipt => ⟨.internalReceipt, "internalReceipt", none⟩

def evaluatedToEnc (e : Typed.Evaluated Party Asset Domain) (req : Typed.Request Party Asset Domain) : ReceiptEnc :=
  .invoked ⟨req.operation.value, req.parties, req.arguments.map PackedValueEnc.fromPackedValue, req.capabilityIds.map (·.value), req.claimedActor⟩
    ⟨e.guard,
     e.deltas.map (fun (c, amt) ↦ (⟨c.1, c.2.1, c.2.2⟩, ⟨amt.num, amt.den⟩)),
     e.supplies.map (fun ((d, a), amt) ↦ ((d, a), ⟨amt.num, amt.den⟩)),
     e.requiredStateReads.map (fun c ↦ ⟨c.1, c.2.1, c.2.2⟩),
     e.requiredEnvReads.filterMap (fun r ↦ match r with | .observation k => some ⟨k.domain, k.id.value⟩ | .currentTime => none),
     e.declaredStateReads.map (fun c ↦ ⟨c.1, c.2.1, c.2.2⟩),
     e.declaredEnvReads.filterMap (fun r ↦ match r with | .observation k => some ⟨k.domain, k.id.value⟩ | .currentTime => none),
     e.writes.map (fun c ↦ ⟨c.1, c.2.1, c.2.2⟩)⟩

def executionResultToWorld (res : Typed.ExecutionResult Party Asset Domain) (oldState : StateEnc) : WorldEnc :=
  let cells := oldState.cells.map (fun row ↦
    let newBal := res.state.balance (row.domain, row.party, row.asset)
    ⟨row.domain, row.party, row.asset, ⟨newBal.num, newBal.den⟩⟩)
  ⟨⟨cells⟩, storeToEnc res.capabilities⟩

def FAMILIES : List String := [
  "typeCorrect",
  "footprintCorrect",
  "authorityCorrect",
  "accountingCorrect",
  "compositionCompatible",
  "assumptionsDeclared",
  "libraryTheoremsInstantiated",
  "sourceRefinement"
]

def makeJudgments (mapping : List (String × JudgmentOutcome)) (claimed : ClaimedJudgments) : List JudgmentResult :=
  FAMILIES.map fun fam ↦
    let outcome := match mapping.find? (fun (k, _) ↦ k == fam) with
      | some (_, o) => o
      | none => .notApplicable
    let cl := match fam with
      | "typeCorrect" => claimed.typeCorrect
      | "footprintCorrect" => claimed.footprintCorrect
      | "authorityCorrect" => claimed.authorityCorrect
      | "accountingCorrect" => claimed.accountingCorrect
      | "compositionCompatible" => claimed.compositionCompatible
      | "assumptionsDeclared" => claimed.assumptionsDeclared
      | "libraryTheoremsInstantiated" => claimed.libraryTheoremsInstantiated
      | "sourceRefinement" => claimed.sourceRefinement
      | _ => false
    let matchFlag := match outcome with
      | .«true» => cl == true
      | .«false» => cl == false
      | .notReached => !cl
      | .notApplicable => !cl
    ⟨fam, outcome, cl, matchFlag⟩

def SIX_ASSUMPTIONS : List String := [
  "registry-trust",
  "administrator-trust",
  "context-authenticity",
  "observation-truth",
  "environment-authenticity",
  "replay-prevention-outside-model"
]

def computeAssumptions (cert : EnvelopeEnc) : List (String × String) × Option String :=
  let missingEnv := !cert.assumptions.contains "environment-authenticity"
  let missingReplay := !cert.assumptions.contains "replay-prevention-outside-model"
  if missingEnv || missingReplay then
    let pairs := SIX_ASSUMPTIONS.map fun name ↦
      if name == "environment-authenticity" then (name, "missing")
      else (name, "present")
    (pairs, some "environment-authenticity")
  else
    let pairs := SIX_ASSUMPTIONS.map fun name ↦
      if cert.assumptions.contains name then (name, "present")
      else (name, "missing")
    let firstMissing := SIX_ASSUMPTIONS.find? (!cert.assumptions.contains ·)
    (pairs, firstMissing)

structure CertContext where
  claimed_next_state : Option (Typed.ExecutionResult Party Asset Domain) := none
  libraries : List LibraryRefEnc := []
  invariants : List String := []
  source_pin : SourcePinEnc
  audit_roots : List String

/-- Primary Typed execution checker with needles M01, M02, M09, M10. -/
def checkTyped (rawCert : EnvelopeEnc) (payload : TypedExecutePayloadEnc) : Report :=
  let preWorld : WorldEnc := ⟨payload.state, payload.store⟩
  let (assumptionsList, missingAssump) := computeAssumptions rawCert
  let claimed := parseClaimedJudgments rawCert.claimed_judgments
  let outstanding := (if !rawCert.libraries.isEmpty then ["libraryTheoremsInstantiated"] else []) ++ (if !rawCert.invariants.isEmpty then ["proof.ComponentContract.invariant"] else [])

  -- Check source pin
  if rawCert.source_pin.git ≠ "a12b7cac05a818cc8d35c2ca440b7170a2807e92" then
    let jmap : List (String × JudgmentOutcome) := [
      ("typeCorrect", .notReached),
      ("footprintCorrect", .notReached),
      ("authorityCorrect", .notReached),
      ("accountingCorrect", .notReached),
      ("compositionCompatible", .notApplicable),
      ("assumptionsDeclared", .«true»),
      ("libraryTheoremsInstantiated", .notApplicable),
      ("sourceRefinement", .notApplicable)
    ]
    ⟨.refused, some ⟨.staleSource, "git", some rawCert.source_pin.git⟩, makeJudgments jmap claimed,
     preWorld, none, [], [], 0, none, assumptionsList, outstanding, rawCert.source_pin, rawCert.audit_roots, none⟩
  else
    let registry := registryToTyped payload.registry
    let store := storeToTyped payload.store
    let ctx := payload.ctx.toContext
    let env := envToTyped payload.env
    let now := payload.now
    let request := payload.request.toRequest
    match stateToTyped? payload.state with
    | none =>
      ⟨.refused, some ⟨.kernel, "stateNonneg", none⟩, [], preWorld, none, [], [], 0, none, assumptionsList, outstanding, rawCert.source_pin, rawCert.audit_roots, none⟩
    | some state =>
      -- M02 context setup
      let cert : CertContext := ⟨
        rawCert.claimed_next_state.bind (fun w ↦ w.toWorld?.map (fun cw ↦ ⟨cw.state, cw.capabilities⟩)),
        rawCert.libraries,
        rawCert.invariants,
        rawCert.source_pin,
        rawCert.audit_roots
      ⟩

      -- Execute transition (M02 needle)
      let execResult : Except Refusal (Typed.ExecutionResult Party Asset Domain) := do
        let post ← Typed.execute registry store ctx env now request state
        return post

      -- Judgment recomputations
      let optTemplate := registry request.operation
      let (tc, fc, ac, acc) : JudgmentOutcome × JudgmentOutcome × JudgmentOutcome × JudgmentOutcome :=
        match optTemplate with
        | none => (.notReached, .notReached, .notReached, .notReached)
        | some template =>
          if request.claimedActor.isSome && request.claimedActor != some ctx.principal then
            (.notReached, .notReached, .notReached, .notReached)
          else if ctx.domain != template.domain || request.parties.length != template.partyArity then
            (.notReached, .notReached, .notReached, .notReached)
          else
            let typeCorrect := match Args.check template.signature request.arguments with | .ok _ => true | .error _ => false
            if !typeCorrect then
              (.«false», .notReached, .notReached, .notReached)
            else
              let hasInv := hasAuthority store request.capabilityIds ctx request.operation .invoke
              if !hasInv then
                (.«true», .notReached, .«false», .notReached)
              else
                match Args.check template.signature request.arguments with
                | .error _ => (.«true», .notReached, .notReached, .notReached)
                | .ok checkedArgs =>
                  match template.evaluate ⟨state, env, ctx.principal, request.parties, checkedArgs, now⟩ with
                  | .error _ => (.«true», .notReached, .«true», .notReached)
                  | .ok eval =>
                    let fp := eval.stateReadsOK && eval.envReadsOK && eval.domainOK ctx.domain
                    let deb := eval.debitsOK store request ctx && eval.suppliesOK store request ctx
                    if !fp then
                      (.«true», .«false», .«true», .notReached)
                    else if !deb then
                      (.«true», .«true», .«false», .notReached)
                    else
                      let balNonneg := decide (∀ c, 0 ≤ state.balance c + eval.effect c)
                      let wr := eval.writesOK
                      let accOK := eval.accountingOK && balNonneg
                      if !accOK then
                        (.«true», .«true», .«true», .«false»)
                      else if !wr then
                        (.«true», .«false», .«true», .«true»)
                      else
                        (.«true», .«true», .«true», .«true»)

      -- M09 and M10 needles
      let libraryTheoremsInstantiated := if cert.libraries.isEmpty then JudgmentOutcome.notApplicable else JudgmentOutcome.notApplicable
      let sourceRefinement := if cert.invariants.isEmpty then JudgmentOutcome.notApplicable else JudgmentOutcome.notApplicable

      let jmap : List (String × JudgmentOutcome) := [
        ("typeCorrect", tc),
        ("footprintCorrect", fc),
        ("authorityCorrect", ac),
        ("accountingCorrect", acc),
        ("compositionCompatible", .notApplicable),
        ("assumptionsDeclared", .«true»),
        ("libraryTheoremsInstantiated", libraryTheoremsInstantiated),
        ("sourceRefinement", sourceRefinement)
      ]
      let judgments := makeJudgments jmap claimed

      match execResult with
      | .error r =>
        let failPath := (refusalToLocatedFailure r).reason
        ⟨.refused, some failPath, judgments, preWorld, none, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
      | .ok post =>
        let postWorld := executionResultToWorld post payload.state
        let postReceipt : Option ReceiptEnc :=
          match optTemplate with
          | some tmpl =>
            match Args.check tmpl.signature request.arguments with
            | .ok checkedArgs =>
              match tmpl.evaluate ⟨state, env, ctx.principal, request.parties, checkedArgs, now⟩ with
              | .ok e => some (evaluatedToEnc e request)
              | .error _ => none
            | .error _ => none
          | none => none
        match missingAssump with
        | some missingClass =>
          ⟨.incomplete, some ⟨.incompleteObligation, missingClass, none⟩, judgments,
           postWorld, postReceipt, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
        | none =>
          -- Claimed next state observation mismatch check (F36)
          match rawCert.claimed_next_state with
          | some claimedWorld =>
            if claimedWorld != postWorld then
              ⟨.refused, some ⟨.observationMismatch, "claimedNextState", none⟩, judgments,
               postWorld, postReceipt, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
            else
              ⟨.accepted, none, judgments, postWorld, postReceipt, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
          | none =>
            ⟨.accepted, none, judgments, postWorld, postReceipt, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩

/-- Composition single-step checker. -/
def checkStep (cert : EnvelopeEnc) (payload : CompositionStepPayloadEnc) : Report :=
  let preWorld := payload.pre
  let (assumptionsList, _) := computeAssumptions cert
  let claimed := parseClaimedJudgments cert.claimed_judgments
  let outstanding := (if !cert.libraries.isEmpty then ["libraryTheoremsInstantiated"] else []) ++ (if !cert.invariants.isEmpty then ["proof.ComponentContract.invariant"] else [])
  match configToTyped? payload.config with
  | none =>
    ⟨.refused, some ⟨.configuration, "configuration", none⟩, [], preWorld, none, [], [], payload.index, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
  | some cfg =>
    match payload.pre.toWorld? with
    | none =>
      ⟨.refused, some ⟨.kernel, "stateNonneg", none⟩, [], preWorld, none, [], [], payload.index, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
    | some preW =>
      let boundary := boundaryToTyped payload.boundary
      let history := payload.history.map OutputObservationEnc.toOutputObservation
      match payload.step.toStep? with
      | none =>
        ⟨.refused, some ⟨.interface, "unknownStep", none⟩, [], preWorld, none, [], [], payload.index, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
      | some step =>
        match Composition.executeStep cfg boundary payload.index history step preW with
        | .error fail =>
          let failPath := failureToPath fail
          let cursorFail : Option LocatedFailureEnc := match fail with
            | .configuration => some ⟨payload.index, none, ⟨.configuration, "configuration", none⟩⟩
            | _ => none
          let jmap : List (String × JudgmentOutcome) := [
            ("typeCorrect", .notReached),
            ("footprintCorrect", .notReached),
            ("authorityCorrect", .notReached),
            ("accountingCorrect", .notReached),
            ("compositionCompatible", .«false»),
            ("assumptionsDeclared", .«true»),
            ("libraryTheoremsInstantiated", .notApplicable),
            ("sourceRefinement", .notApplicable)
          ]
          ⟨.refused, some failPath, makeJudgments jmap claimed, preWorld, none, [], [], payload.index, cursorFail, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
        | .ok res =>
          let postWorld : WorldEnc := ⟨⟨payload.pre.state.cells.map (fun row ↦
            let b := res.world.state.balance (row.domain, row.party, row.asset)
            ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc res.world.capabilities⟩
          let receiptEnc : ReceiptEnc :=
            match res.receipt with
            | .invoked req e => evaluatedToEnc e req
            | .issued id => .issued id.value
            | .revoked id => .revoked id.value
          let outputsEnc := res.outputs.map OutputObservationEnc.fromOutputObservation
          let isIssueRevoke := match step with | .issue _ | .revoke _ => true | _ => false
          let jmap : List (String × JudgmentOutcome) := [
            ("typeCorrect", if isIssueRevoke then .notApplicable else .«true»),
            ("footprintCorrect", if isIssueRevoke then .notApplicable else .«true»),
            ("authorityCorrect", .«true»),
            ("accountingCorrect", if isIssueRevoke then .notApplicable else .«true»),
            ("compositionCompatible", .«true»),
            ("assumptionsDeclared", .«true»),
            ("libraryTheoremsInstantiated", .notApplicable),
            ("sourceRefinement", .notApplicable)
          ]
          ⟨.accepted, none, makeJudgments jmap claimed, postWorld, some receiptEnc, outputsEnc, [], payload.index, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩

/-- Composition run checker. -/
def checkRun (cert : EnvelopeEnc) (payload : CompositionRunPayloadEnc) : Report :=
  let preWorld := payload.world
  let (assumptionsList, _) := computeAssumptions cert
  let claimed := parseClaimedJudgments cert.claimed_judgments
  let outstanding := (if !cert.libraries.isEmpty then ["libraryTheoremsInstantiated"] else []) ++ (if !cert.invariants.isEmpty then ["proof.ComponentContract.invariant"] else [])
  match configToTyped? payload.config with
  | none =>
    ⟨.refused, some ⟨.configuration, "configuration", none⟩, [], preWorld, none, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
  | some cfg =>
    match payload.world.toWorld? with
    | none =>
      ⟨.refused, some ⟨.kernel, "stateNonneg", none⟩, [], preWorld, none, [], [], 0, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
    | some initialWorld =>
      let bList := payload.boundaries.map boundaryToTyped
      let defaultBoundary : Composition.Boundary Party Asset Domain :=
        ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩
      let boundaries : Nat → Composition.Boundary Party Asset Domain :=
        fun idx ↦ match bList[idx]? with
        | some b => b
        | none => bList.head?.getD defaultBoundary
      let steps : List (Composition.Step Party Asset Domain) :=
        payload.steps.filterMap StepEnc.toStep?

        let cursor := Composition.run cfg boundaries initialWorld steps
        let postWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
          let b := cursor.world.state.balance (row.domain, row.party, row.asset)
          ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc cursor.world.capabilities⟩
        let outputsEnc := cursor.outputs.map OutputObservationEnc.fromOutputObservation
        let eventsEnc : List SequentialEventEnc := cursor.events.map (fun ev ↦
          let stepEnc := StepEnc.fromStep ev.step
          let bWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
            let b := ev.before.state.balance (row.domain, row.party, row.asset)
            ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc ev.before.capabilities⟩
          let aWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
            let b := ev.result.world.state.balance (row.domain, row.party, row.asset)
            ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc ev.result.world.capabilities⟩
          let receiptEnc : ReceiptEnc :=
            match ev.result.receipt with
            | .invoked req e => evaluatedToEnc e req
            | .issued id => .issued id.value
            | .revoked id => .revoked id.value
          let stepOutputs := ev.result.outputs.map OutputObservationEnc.fromOutputObservation
          ⟨ev.index, stepEnc, bWorld, ⟨aWorld, receiptEnc, stepOutputs⟩⟩)

        let lastReceipt : Option ReceiptEnc :=
          cursor.events.getLast?.bind (fun ev ↦
            match ev.result.receipt with
            | .invoked req e => some (evaluatedToEnc e req)
            | .issued id => some (.issued id.value)
            | .revoked id => some (.revoked id.value))

        match cursor.failure with
        | some lf =>
          let failPath := failureToPath lf.reason
          let stepEnc : Option StepEnc := lf.step.map StepEnc.fromStep
          let cursorFail : LocatedFailureEnc := ⟨lf.index, stepEnc, failPath⟩
          let jmap : List (String × JudgmentOutcome) := [
            ("typeCorrect", .«true»),
            ("footprintCorrect", .«true»),
            ("authorityCorrect", .«true»),
            ("accountingCorrect", .«false»),
            ("compositionCompatible", .«true»),
            ("assumptionsDeclared", .«true»),
            ("libraryTheoremsInstantiated", .notApplicable),
            ("sourceRefinement", .notApplicable)
          ]
          ⟨.refused, some failPath, makeJudgments jmap claimed, postWorld, lastReceipt, outputsEnc, eventsEnc, cursor.nextIndex, some cursorFail, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩
        | none =>
          let jmap : List (String × JudgmentOutcome) := [
            ("typeCorrect", .«true»),
            ("footprintCorrect", .«true»),
            ("authorityCorrect", .«true»),
            ("accountingCorrect", .«true»),
            ("compositionCompatible", .«true»),
            ("assumptionsDeclared", .«true»),
            ("libraryTheoremsInstantiated", .notApplicable),
            ("sourceRefinement", .notApplicable)
          ]
          ⟨.accepted, none, makeJudgments jmap claimed, postWorld, lastReceipt, outputsEnc, eventsEnc, cursor.nextIndex, none, assumptionsList, outstanding, cert.source_pin, cert.audit_roots, none⟩

/-- Raw execution observation without policy or source-pin guards. -/
def rawExecute (exec : DecodedExecution) : RawObservation :=
  match exec with
  | .typed _ payload =>
    let preWorld : WorldEnc := ⟨payload.state, payload.store⟩
    let registry := registryToTyped payload.registry
    let store := storeToTyped payload.store
    let ctx := payload.ctx.toContext
    let env := envToTyped payload.env
    let now := payload.now
    let request := payload.request.toRequest
    match stateToTyped? payload.state with
    | none =>
      ⟨preWorld, none, [], [], 0, none, some ⟨.kernel, "stateNonneg", none⟩⟩
    | some state =>
      let optTemplate := registry request.operation
      match Typed.execute registry store ctx env now request state with
      | .ok post =>
        let postWorld := executionResultToWorld post payload.state
        let postReceipt : Option ReceiptEnc :=
          match optTemplate with
          | some tmpl =>
            match Args.check tmpl.signature request.arguments with
            | .ok checkedArgs =>
              match tmpl.evaluate ⟨state, env, ctx.principal, request.parties, checkedArgs, now⟩ with
              | .ok e => some (evaluatedToEnc e request)
              | .error _ => none
            | .error _ => none
          | none => none
        ⟨postWorld, postReceipt, [], [], 0, none, none⟩
      | .error r =>
        ⟨preWorld, none, [], [], 0, none, some (refusalToLocatedFailure r).reason⟩

  | .step _ payload =>
    let preWorld := payload.pre
    match configToTyped? payload.config with
    | none =>
      ⟨preWorld, none, [], [], payload.index, none, some ⟨.configuration, "configuration", none⟩⟩
    | some cfg =>
      match payload.pre.toWorld? with
      | none =>
        ⟨preWorld, none, [], [], payload.index, none, some ⟨.kernel, "stateNonneg", none⟩⟩
      | some pre =>
        let boundary := boundaryToTyped payload.boundary
        match payload.step.toStep? with
        | none =>
          ⟨preWorld, none, [], [], payload.index, none, some ⟨.interface, "unknownStep", none⟩⟩
        | some step =>
          let hist := payload.history.map OutputObservationEnc.toOutputObservation
          match Composition.executeStep cfg boundary payload.index hist step pre with
          | .ok res =>
            let postWorld : WorldEnc := ⟨⟨payload.pre.state.cells.map (fun row ↦
              let b := res.world.state.balance (row.domain, row.party, row.asset)
              ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc res.world.capabilities⟩
            let receiptEnc : ReceiptEnc :=
              match res.receipt with
              | .invoked req e => evaluatedToEnc e req
              | .issued id => .issued id.value
              | .revoked id => .revoked id.value
            let outputsEnc := res.outputs.map OutputObservationEnc.fromOutputObservation
            ⟨postWorld, some receiptEnc, outputsEnc, [], 0, none, none⟩
          | .error f =>
            ⟨preWorld, none, [], [], payload.index, none, some (failureToPath f)⟩

  | .run _ payload =>
    let preWorld := payload.world
    match configToTyped? payload.config with
    | none =>
      ⟨preWorld, none, [], [], 0, none, some ⟨.configuration, "configuration", none⟩⟩
    | some cfg =>
      match payload.world.toWorld? with
      | none =>
        ⟨preWorld, none, [], [], 0, none, some ⟨.kernel, "stateNonneg", none⟩⟩
      | some initialWorld =>
        let bList := payload.boundaries.map boundaryToTyped
        let defaultBoundary : Composition.Boundary Party Asset Domain :=
          ⟨⟨.alice, .main⟩, fun _ ↦ none, 100⟩
        let boundaries : Nat → Composition.Boundary Party Asset Domain :=
          fun idx ↦ match bList[idx]? with
          | some b => b
          | none => bList.head?.getD defaultBoundary
        let steps : List (Composition.Step Party Asset Domain) :=
          payload.steps.filterMap StepEnc.toStep?
          let cursor := Composition.run cfg boundaries initialWorld steps
          let postWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
            let b := cursor.world.state.balance (row.domain, row.party, row.asset)
            ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc cursor.world.capabilities⟩
          let outputsEnc := cursor.outputs.map OutputObservationEnc.fromOutputObservation
          let eventsEnc : List SequentialEventEnc := cursor.events.map (fun ev ↦
            let stepEnc := StepEnc.fromStep ev.step
            let bWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
              let b := ev.before.state.balance (row.domain, row.party, row.asset)
              ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc ev.before.capabilities⟩
            let aWorld : WorldEnc := ⟨⟨payload.world.state.cells.map (fun row ↦
              let b := ev.result.world.state.balance (row.domain, row.party, row.asset)
              ⟨row.domain, row.party, row.asset, ⟨b.num, b.den⟩⟩)⟩, storeToEnc ev.result.world.capabilities⟩
            let receiptEnc : ReceiptEnc :=
              match ev.result.receipt with
              | .invoked req e => evaluatedToEnc e req
              | .issued id => .issued id.value
              | .revoked id => .revoked id.value
            let stepOutputs := ev.result.outputs.map OutputObservationEnc.fromOutputObservation
            ⟨ev.index, stepEnc, bWorld, ⟨aWorld, receiptEnc, stepOutputs⟩⟩)
          let lastReceipt : Option ReceiptEnc :=
            cursor.events.getLast?.map fun ev ↦
              match ev.result.receipt with
              | .invoked req e => evaluatedToEnc e req
              | .issued id => .issued id.value
              | .revoked id => .revoked id.value
          let cursorFail : Option LocatedFailureEnc :=
            cursor.failure.map fun cf ↦
              let stepEnc := cf.step.map StepEnc.fromStep
              ⟨cf.index, stepEnc, failureToPath cf.reason⟩
          let kernFail := cursor.failure.map (fun cf ↦ failureToPath cf.reason)
          ⟨postWorld, lastReceipt, outputsEnc, eventsEnc, cursor.nextIndex, cursorFail, kernFail⟩

def checkAudit (a : DecodedAudit) : AuditResult :=
  if a.imported_theorems == some 0 then
    ⟨.blocked, some "emptyScope", [], none⟩
  else if !a.forbidden_claimed_roots.isEmpty then
    ⟨.passed, none, [], some false⟩
  else
    let pfxs := if !a.commands.isEmpty then
      a.commands.filterMap fun cmd =>
        if cmd.startsWith "#audit_axioms " then
          some (cmd.drop "#audit_axioms ".length |>.toString)
        else none
    else
      match a.auditPrefix with
      | some p => [p]
      | none => ["DefiKernel"]
    ⟨.passed, none, pfxs, none⟩

def checkIR (ir : DecodedIR) : Outcome :=
  match ir with
  | .execution (.typed env payload) => .execution (checkTyped env payload)
  | .execution (.step env payload) => .execution (checkStep env payload)
  | .execution (.run env payload) => .execution (checkRun env payload)
  | .audit a => .audit (checkAudit a)
  | .codec doc => .codec (.ok (.codec doc))

def checkBytes (bytes : ByteArray) : Outcome :=
  match decodeBytes bytes with
  | .error (.resourceLimit limit) => .codec (.blocked limit)
  | .error e => .codec (.malformed e)
  | .ok ir => checkIR ir

def checkCertificate (exec : DecodedExecution) : Outcome :=
  checkIR (.execution exec)

def checkCertificateBytes (bytes : ByteArray) : Outcome :=
  checkBytes bytes

end DefiKernel.Certificates

