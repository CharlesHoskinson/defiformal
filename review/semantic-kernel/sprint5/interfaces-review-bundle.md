Independently review the supplied Sprint 5 interfaces candidate at exact git revision ba3661f3e875ef6c48e71300fec339d333dab697. You are a native external reviewer, not the implementer. Analyze source correctness, OpenSpec compliance within this scope, proof strength/premises, missing checks, false evidence claims, and discriminating tests. Report ACCEPT WITH LIMITATIONS or REQUEST CHANGES, with ranked concrete file/line findings, exploit/counterexample where possible, and limits. Do not claim independent execution: tools are disabled and source is supplied. Full financial workflows/mutation evidence are still under implementation and will have a separate review; assess these core declarations and their stated claims now. Do not assume unchecked assumptions are proofs. No Foreman. Return concise actionable findings, preserving dissent.


## FILE openspec/changes/typed-interfaces-sequential-composition/design.md sha256=a56fd804e10659c13549c6c8b9e597c99a50dffa14cf21a3ca6295842a775cca

## Context

See [proposal.md](proposal.md) for motivation and scope. Sprint 4 supplies a
registered, typed, single-transition executor and capability administration.
Its successful-execution theorems expose evaluated effects, scoped authority,
accounting, nonnegativity, and locality. It has no component catalog or sequence
semantics. The historical `Defialgebra.Interface` and `Nary` results remain intact;
their structural port laws do not establish operational workflow laws.

The implementation is additive under `DefiKernel.Composition`. Lean remains the
proof authority. This design describes work to implement; it reports no new
proofs, runtime results, or independent review acceptance.

## Goals / Non-Goals

**Goals:** Make finite ordered workflows executable and observable, with checked
component boundaries and explicit theorem premises. Reuse the trusted Sprint 4
executor and lift its actual guarantees by induction over committed steps.

**Non-Goals:** See proposal exclusions. In particular, ledger framing does not
prove confidentiality, capability provenance, solvency, or arbitrary semantic
contracts. Value routing is limited to literals and previous output snapshots.

## Decisions

### 1. Separate immutable configuration, mutable world, and trusted boundary

`World` contains the existing typed ledger and capability store. Immutable
configuration contains a component catalog, one operation registry, and domain
administrators; derive issuance configuration from that same registry.

The trusted adapter supplies authenticated invocation context, observations,
and time separately from caller-controlled steps. Index these boundary inputs
by absolute step position. Requests cannot replace the registry, operation body,
guard, principal, or domain. Invocation steps identify a component, registered
operation, parties, argument bindings, and capability IDs; administrative steps
request issuance or revocation through the existing authority API.

This avoids duplicating the authority model or accepting authentication facts
from workflow data. Administration changes only the store. Ordinary invocation
changes only the ledger. Both consume the immediately preceding world.

### 2. Stable ports and explicit resource visibility

Use stable `(ComponentId, PortId)` names, with duplicate identities rejected.
Keep value ports separate from resource ports:

- Input value ports declare existing `Typed.Unit` types and map to the registered
  operation's ordered argument signature.
- Output value ports select ledger cells visible to the component and return
  typed post-state balance snapshots. They are total after successful execution.
- Resource ports identify exact cells, including domain and asset, with read or
  read/write access. Shared imports must match declared exports and cannot
  escalate access.

Each component owns a finite private cell set and an operation allowlist.
Private ownership is disjoint and excludes every other component's resource
access. Operations have unambiguous component ownership. Resolve operation cell
references using the actual context/parties/arguments; conservatively check all
required and declared reads and writes against permitted component access before
calling the executor. Include guards, both expression branches, supply-related
reads, and output selections. Existing domain and capability checks still apply.
A valid debit grant does not override interface isolation. Read access does not
imply write access. Passing a numeric value grants no resource access.

An untyped port dictionary would move unit errors into financial execution.
Arbitrary output expressions would introduce a second evaluator and possible
post-commit failures. Selected-cell snapshots provide sufficient first-sprint
composition without those costs.

### 3. Structural validation and proof-level contracts have separate roles

Validate finite structural configuration before execution: identities, ownership,
port links, operation membership/signatures, and resource access declarations.
Invalid configuration returns a configuration refusal with the initial world,
no events, and no outputs.

Define `ComponentContract` using Lean predicates for initialization, boundary
assumptions, invariants, and guarantees. Define global `Initial cfg world` and
local preservation obligations. The executable runner may start from any typed
world; it does not decide arbitrary propositions. Reachability and contract
theorems require an explicit initialization witness and proofs of the relevant
local obligations and external assumptions. Concrete examples supply witnesses.
Contracts are not caller callbacks or accepted certificate labels.

This keeps externally assumed observation truth and authentic configuration
visible. Automatic assume-guarantee discharge is a later sprint.

### 4. Execute the successful prefix and stop at the first refusal

Execute steps in list order. Successful steps commit their world and receipt.
The first refused step leaves its input world unchanged and terminates the run;
no output or successful receipt is produced for that step or the suffix. The
empty list is identity. There is no rollback, retry, or skip.

Input bindings are a closed datatype: literal packed value or earlier absolute
step index plus qualified output port. Only an earlier successful invocation can
provide an output. Resolve bindings and check units before financial execution;
reject unknown, forward, missing, or incompatible bindings. Configuration errors
precede steps; within a step, validate membership/bindings/interface access before
delegating to the kernel. Once delegated, preserve its existing refusal order and
reason, wrapping kernel and administrative failures without reclassification.

Return final world, successful events, typed output history, and an optional
failure containing absolute index, step identity, and reason. Preserve these
fields across continuation. The append/resume theorem includes output history,
absolute boundary position, and the terminal-failure flag: resuming a failed
prefix executes nothing. This proves a finite-list law, not general behavioral
associativity of networks.

Atomic rollback would discard the successful prefix and belongs to the separate
atomic composition operator on the roadmap.

### 5. Receipts must correspond to actual evaluated effects

Wrap existing `Typed.execute`; do not implement another financial executor.
For accepted invocations, extract the evaluated template/effects using the same
registry, arguments, pre-state, context, observations, and time. An executable
second evaluation is acceptable for these bounded references. Prove extraction
cannot fail after genuine executor success, using `execute_ok_iff` and
`execute_evaluated`. Any internal extraction inconsistency must stop without
committing; never insert defaults or fabricate a receipt.

The receipt records actual evaluated deltas, supply changes, and checked writes,
plus selected post-state output snapshots. Supply is not defined as observed
post-minus-pre balance; that would make accounting tautological. Administrative
receipts record the corresponding store transition and zero ledger effects.

`StepSound` relates each receipt to its actual pre-world and existing executor or
administrative API. `TraceSound` chains those relations. Prove runner soundness
and delegated acceptance/refusal correspondence, including receipt extraction.

### 6. Lift only justified properties, with explicit support for framing

Induct over the successful event prefix, including runs ending in refusal:

- Accounting: each domain/asset's final total equals its initial total plus the
  sum of actual successful invocation supply receipts. Administration and refusal
  contribute zero.
- Nonnegativity: every reachable ledger has nonnegative balances.
- Authority: each successful invocation, debit, and supply change has the existing
  witness in that step's pre-store. A later revocation need not leave it live in
  the final store. Administrative steps satisfy their own authorization relation.
- Locality: cells outside the union of successful checked writes are unchanged;
  refused steps contribute no writes. Domain restrictions remain per operation.
- Initialization: a proved initial predicate and local invariant-preservation
  premises imply the invariant at every reachable prefix.

Define `AgreeOn protected s t` and `Supports protected predicate`: agreement on
those ledger cells implies equivalent predicate truth. Disjointness between the
protected set and the successful write union yields a ledger frame theorem, then
the supported-predicate theorem. Arbitrary predicates and capability-dependent
predicates are excluded from this ledger-only frame theorem. Capability changes
are instead covered by exact step/store propagation statements.

### 7. Add narrow modules and evidence without rewriting historical semantics

| Planned path | Responsibility |
| --- | --- |
| `lean/DefiKernel/Composition/Interfaces.lean` | Catalog, ports, ownership, access and binding validation |
| `lean/DefiKernel/Composition/Contracts.lean` | Initial predicates, assumptions, guarantees and support |
| `lean/DefiKernel/Composition/Execution.lean` | World, trusted boundary, steps, receipts and step correspondence |
| `lean/DefiKernel/Composition/Sequence.lean` | Ordered runner, observations, histories and trace soundness |
| `lean/DefiKernel/Composition/Preservation.lean` | Inductive preservation, append/resume and frame theorems |
| `lean/DefiKernel/Composition/Examples.lean` | Composed reference configurations and initialization witnesses |
| `lean/DefiKernel/Composition/Tests.lean` | Named comparisons and executable success/refusal checks |
| `lean/DefiKernel/Composition/Audit.lean`, `Verify.lean` | Imported axiom coverage and verification drivers |
| `scripts/check_composition_mutations.py` | Actual source mutations and machine-readable evidence |
| `scripts/test_composition_mutation_runner.py` | Real CLI positive and negative controls |
| `review/semantic-kernel/sprint5/` | Source-bound build, runtime, proof, mutation and native-review evidence |

Add the composition import to `lean/DefiKernel.lean`. Keep executable definitions
and runtime fixtures available to mutation projection, with proofs and drivers
separated consistently with the existing audit approach. The typed mutation
runner is namespace-specific; add a scoped composition runner rather than
assuming it accepts a different namespace. Preserve its historical controls.

## Risks / Trade-offs

- Component boundaries can be weaker than capability checks if only IDs are
  checked → resolve concrete reads/writes and test foreign-private interference
  with an otherwise valid capability and funded balance.
- Trace theorems can accidentally describe fresh execution from the initial
  state → require pre-world adjacency and mutants that reset ledger or store.
- Receipts can restate the intended conclusion → extract genuine evaluated
  supplies and prove correspondence before proving cumulative accounting.
- Proof-level assumptions can look executable → distinguish structural rejection
  from theorem premises in APIs, examples, and reports.
- Snapshot outputs and repeated evaluation cost extra work → accept this bounded
  reference cost; performance and a one-pass refinement are later optimizations.
- Successful footprint guarantees do not imply absence of observations during
  refusal → make no general confidentiality or full noninterference claim.
- Exact rational reference behavior can be mistaken for deployed behavior → keep
  machine arithmetic and implementation refinement explicitly deferred.

## Migration Plan

Implement in the order in [tasks.md](tasks.md): baseline, interfaces/contracts,
step adapter, sequence runner, proofs, reference checks, adversarial evidence,
then independent review and delivery. Keep original proof and corpus files intact.
Run the full existing build and regression drivers alongside the new drivers.
Bind review to an exact candidate commit; fixes invalidate affected review and
verification evidence. GPT-6 implements using the stock harness; native Grok and
Fable review the results. Do not use Foreman.

Rollback consists of reverting additive composition changes and the new root
import; no data migration or change to Sprint 4 execution is required. This
OpenSpec package remains a plan until its implementation tasks and evidence are
completed. Archive it only after actual implementation and verification.


## FILE openspec/changes/typed-interfaces-sequential-composition/specs/typed-component-interfaces/spec.md sha256=00da744c1e9cd06753279e894004d94c675ec35c378b64e2f90982cf0a225eb5

## Purpose

Describe component boundaries and typed connections so workflows can exchange
values and share resources without silently expanding access or proof claims.

## ADDED Requirements

### Requirement: Stable typed port declarations
The system SHALL identify ports by stable component and port identities, distinguish
value inputs, value outputs, and resource access, and reject duplicate identities,
unknown operations, ambiguous operation ownership, and incompatible signatures.

#### Scenario: Valid declared operation
- **WHEN** a uniquely owned registered operation has inputs matching its signature and valid selected-cell outputs
- **THEN** its interface is accepted and every output has the selected cell's asset unit

#### Scenario: Invalid declarations
- **WHEN** declarations contain duplicate port identities, an unknown operation, ambiguous ownership, or a signature mismatch
- **THEN** configuration validation refuses before any workflow step executes

### Requirement: Private ownership and explicit shared access
The system SHALL enforce disjoint private ownership and explicitly matched shared
resource imports and exports, including exact cell identity, domain, asset, and
access rights. Private cells SHALL NOT be accessible as another component's
resources. A component SHALL access only its permitted reads and writes.

#### Scenario: Overlapping ownership
- **WHEN** two components claim the same private cell or another component imports that cell as shared
- **THEN** configuration validation refuses without changing the world

#### Scenario: Authorized shared use
- **WHEN** a component accesses an explicitly exported and matching shared resource within its granted access and kernel authority
- **THEN** the interface boundary permits the operation

#### Scenario: Read-only import
- **WHEN** a component attempts to write a resource imported for reading only
- **THEN** interface validation refuses the step even if a debit capability is otherwise valid

#### Scenario: Funded foreign-private interference
- **WHEN** an operation targets another component's funded private cell with an otherwise valid live debit capability
- **THEN** the interface boundary refuses without changing the world

#### Scenario: Undeclared reads
- **WHEN** a guard, effect, supply expression, output selection, or unselected expression branch references a cell outside permitted read access
- **THEN** the interface boundary rejects the declaration or refuses the step before delegated financial execution

### Requirement: Typed values do not transfer resource rights
The system SHALL route literal values and outputs of earlier successful steps only
when their units match the receiving inputs. Value transfer SHALL NOT create
resource aliases, authorize writes, or move balances by itself.

#### Scenario: Valid snapshot binding
- **WHEN** a USD output from an earlier successful step is bound to a USD input
- **THEN** the receiving operation uses that recorded value and still requires its own resource and capability permissions

#### Scenario: Wrong unit or unavailable output
- **WHEN** a binding has the wrong unit or names an unknown, forward, or unavailable output
- **THEN** the step refuses before financial execution and produces no output

### Requirement: Explicit semantic contract premises
The system SHALL represent initialization, assumptions, invariants, and guarantees
as explicit proof obligations. Arbitrary semantic predicates SHALL NOT be treated
as automatically checked by structural validation or as proved by declaration.

#### Scenario: Initialized invariant reasoning
- **WHEN** an initial-state witness, required boundary assumptions, and local invariant-preservation proofs are supplied
- **THEN** the corresponding workflow invariant theorem is available with those premises recorded

#### Scenario: Missing external assumption
- **WHEN** a declared guarantee relies on observation truth without a proof or supplied premise
- **THEN** the guarantee remains conditional and is not reported as unconditionally verified


## FILE openspec/changes/typed-interfaces-sequential-composition/specs/sequential-workflow-execution/spec.md sha256=df7daac2ac265847b0183eb9ab3cecbd4030ff7ce8756f9e40af5db3a71e287e

## Purpose

Specify observable ordered execution with explicit state, capability changes,
output histories, and preservation of the successful prefix on refusal.

## ADDED Requirements

### Requirement: Validated initialization and trusted execution inputs
The system SHALL validate structural configuration before execution and receive
authenticated context, observations, and time separately from workflow requests.
Boundary inputs SHALL be indexed by absolute step position. Malformed
configuration SHALL return the unchanged initial world with no executed events.

#### Scenario: Invalid initial configuration
- **WHEN** a workflow is submitted with invalid component ownership or bindings in its configuration
- **THEN** execution returns a configuration refusal and no step runs

#### Scenario: Caller cannot replace authority context
- **WHEN** a request claims an actor different from the adapter's authenticated principal
- **THEN** the existing actor-consistency refusal is preserved for an otherwise well-formed invocation

### Requirement: Current-world propagation
The system SHALL execute each step against the immediately preceding ledger and
capability store. Invocation success SHALL preserve the store, administrative
success SHALL preserve the ledger, and every refusal SHALL preserve its input world.

#### Scenario: Consecutive funded transfers
- **WHEN** Alice starts with 10 USD and two authorized transfers of 3 USD to Bob execute
- **THEN** Alice ends with 4 USD and Bob gains 6 USD

#### Scenario: Issue use revoke use
- **WHEN** a capability is validly issued, used successfully, revoked, and then requested again
- **THEN** the first use remains committed and the second use refuses under the updated store

### Requirement: Ordered first-refusal execution
The system SHALL execute in submitted order, stop at the first refusal, retain all
earlier successful changes, and execute no suffix. Empty execution SHALL be identity.

#### Scenario: Empty workflow
- **WHEN** an empty workflow runs from a valid configuration
- **THEN** it succeeds with the unchanged world and empty event and output histories

#### Scenario: First step refusal
- **WHEN** the first step refuses
- **THEN** the initial world is returned with failure index zero and no successful events or outputs

#### Scenario: Middle refusal preserves prefix
- **WHEN** a successful transfer is followed by an insufficient-funds deposit and a funded later action
- **THEN** only the transfer remains committed and the funded suffix action does not execute

#### Scenario: Ordering changes observations
- **WHEN** transfer-then-deposit and deposit-then-transfer encounter different intermediate balances
- **THEN** each run reports its own ordered successful prefix, resulting world, and first refusal

### Requirement: Observable receipts and refusal provenance
The system SHALL expose successful step identities, actual evaluated ledger effects
and supply changes, administrative store changes, selected post-state outputs,
and final world. A failure SHALL include its absolute position, step identity, and
reason. Failed steps SHALL produce no successful receipt or output.

#### Scenario: Delegated refusal
- **WHEN** an interface-valid and correctly bound step is refused by the financial executor or capability administrator
- **THEN** its original refusal reason is retained with the workflow position

#### Scenario: Snapshot remains historical
- **WHEN** a later step changes a cell previously emitted as an output
- **THEN** the earlier output remains its original post-step snapshot

### Requirement: Continuation preserves history and boundary position
The system SHALL make execution of an appended list agree with continuation from
its prefix, carrying the world, outputs, next absolute index, and terminal status.

#### Scenario: Successful prefix resumed
- **WHEN** a suffix consumes a prefix output and a position-dependent trusted input
- **THEN** resumed execution equals one-pass execution in final world, events, outputs, and failure

#### Scenario: Failed prefix resumed
- **WHEN** a suffix is appended to a prefix that has already refused
- **THEN** continuation returns the failed prefix unchanged and executes no additional steps


## FILE openspec/changes/typed-interfaces-sequential-composition/specs/sequential-preservation/spec.md sha256=793d51a056fa74eed3cebb244cdb6052064b00e72ae4eee5c6854fcfa8bc7c93

## Purpose

State the proof obligations needed to lift trusted transition properties to
finite workflows without hiding initialization, authority, or frame premises.

## ADDED Requirements

### Requirement: Step and trace correspondence
The system SHALL prove that every successful event corresponds to the existing
registered executor or administrative operation at its immediately preceding
world and that accepted invocation receipts contain the actual evaluated effects.
It SHALL prove receipt extraction succeeds whenever delegated execution succeeds.

#### Scenario: Accepted invocation receipt
- **WHEN** an invocation appears in a successful trace prefix
- **THEN** a proof connects its pre-world, evaluated effects, output snapshots, and post-world to the registered execution

#### Scenario: Refused suffix
- **WHEN** a trace ends in refusal
- **THEN** its final world equals the world after exactly its successful prefix

### Requirement: Cumulative accounting and nonnegativity
The system SHALL prove that every final domain/asset total equals its initial total
plus the sum of actual successful invocation supply changes and that every
reachable balance remains nonnegative. Administration and refusal SHALL contribute
zero ledger change.

#### Scenario: Mint then burn
- **WHEN** a valid deposit and withdrawal mint and burn shares within a workflow
- **THEN** cumulative accounting sums both evaluated supplies and applies separately to every domain and asset

#### Scenario: Accounting at refusal
- **WHEN** one supply-changing step succeeds and a later step refuses
- **THEN** accounting includes the successful supply change and excludes the refused step and suffix

### Requirement: Authority at the point of use
The system SHALL prove invocation, debit, and supply authority using each
successful step's pre-store and administrative authorization using the existing
administrative relation. It SHALL NOT require earlier grants to remain live in
the final store.

#### Scenario: Successful use followed by revocation
- **WHEN** a successful authorized operation is followed by valid revocation
- **THEN** the operation's authority witness is proved at its execution point even though the grant is no longer live afterward

### Requirement: Initialized invariant preservation
The system SHALL prove invariant preservation at every reachable prefix from an
explicit initialization proof and applicable local preservation and boundary
assumptions. Missing premises SHALL remain visible in the statement.

#### Scenario: Inductive guarantee
- **WHEN** initialization establishes an invariant and each admitted step preserves it under stated assumptions
- **THEN** the invariant holds at every successful prefix and at the final world of a refused run

### Requirement: Write locality and supported-predicate framing
The system SHALL prove unchanged ledger cells outside the union of successful
checked writes. It SHALL prove preservation of a predicate only given a proof that
the predicate depends solely on protected ledger cells disjoint from that union.
This frame guarantee SHALL be restricted to ledger predicates.

#### Scenario: Protected ledger predicate
- **WHEN** a predicate is supported on protected cells untouched by all successful steps
- **THEN** its truth is equivalent before and after the workflow, including a workflow ending in refusal

#### Scenario: Unsupported predicate counterexample
- **WHEN** a proposed predicate depends on a balance modified by a successful transfer
- **THEN** a concrete counterexample demonstrates why the frame theorem cannot omit its support and disjointness premises

### Requirement: Scoped sequential composition law
The system SHALL prove the finite-list append/continuation law with preserved
history and absolute boundary positions, including failure short-circuiting.
It SHALL describe this result without claiming general network associativity.

#### Scenario: Boundary-sensitive composition
- **WHEN** a suffix uses time or principal inputs dependent on its absolute position
- **THEN** the append theorem compares execution with the same positions and does not reset them at the suffix


## FILE lean/DefiKernel/Composition/Interfaces.lean sha256=0f85b76f3066423ead95a3973a4721b7fdf7a5a2552d34d59950a0d26a21c5de

import DefiKernel.Typed.Transition

/-! Finite component declarations, concrete access checks and immutable value snapshots.
Catalog validation is structural; it does not discharge semantic contracts or kernel authority. -/
namespace DefiKernel.Composition
open Typed

structure ComponentId where
  value : Nat
  deriving DecidableEq, Repr

structure PortId where
  value : Nat
  deriving DecidableEq, Repr

structure QualifiedPort where
  component : ComponentId
  port : PortId
  deriving DecidableEq, Repr

structure InputPort (Asset : Type) where
  id : PortId
  unit : Typed.Unit Asset
  deriving DecidableEq, Repr

structure OutputPort (Party Asset Domain : Type) where
  id : PortId
  cell : Cell Party Asset Domain
  deriving DecidableEq, Repr

structure ResourcePort (Party Asset Domain : Type) where
  id : PortId
  cell : Cell Party Asset Domain
  writable : Bool
  deriving DecidableEq, Repr

structure ResourceImport (Party Asset Domain : Type) where
  source : QualifiedPort
  cell : Cell Party Asset Domain
  writable : Bool
  deriving DecidableEq, Repr

structure OperationInterface (Party Asset Domain : Type) where
  operation : OperationId
  inputs : List (InputPort Asset)
  outputs : List (OutputPort Party Asset Domain)
  deriving DecidableEq, Repr

structure Component (Party Asset Domain : Type) where
  id : ComponentId
  privateCells : List (Cell Party Asset Domain)
  exports : List (ResourcePort Party Asset Domain)
  imports : List (ResourceImport Party Asset Domain)
  operations : List (OperationInterface Party Asset Domain)
  deriving DecidableEq, Repr

abbrev Catalog (Party Asset Domain : Type) := List (Component Party Asset Domain)

inductive InterfaceFailure where
  | unknownOperation
  | resolution (reason : EvalFailure)
  | readAccess
  | writeAccess
  | inputCount
  | inputUnit
  | unavailableOutput
  deriving DecidableEq, Repr

inductive InputSource (Asset : Type) where
  | literal (value : PackedValue Asset)
  | priorOutput (step : Nat) (port : QualifiedPort)

structure OutputObservation (Asset : Type) where
  step : Nat
  port : QualifiedPort
  value : PackedValue Asset

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def Component.canRead (component : Component Party Asset Domain)
    (cell : Cell Party Asset Domain) : Bool :=
  decide (cell ∈ component.privateCells) ||
    component.exports.any (fun p ↦ decide (p.cell = cell)) ||
    component.imports.any (fun p ↦ decide (p.cell = cell))

def Component.canWrite (component : Component Party Asset Domain)
    (cell : Cell Party Asset Domain) : Bool :=
  decide (cell ∈ component.privateCells) ||
    component.exports.any (fun p ↦ decide (p.cell = cell) && p.writable) ||
    component.imports.any (fun p ↦ decide (p.cell = cell) && p.writable)

def lookupOperation (catalog : Catalog Party Asset Domain) (componentId : ComponentId)
    (operationId : OperationId) :
    Option (Component Party Asset Domain × OperationInterface Party Asset Domain) := do
  let component ← catalog.find? (fun c ↦ decide (c.id = componentId))
  let interface ← component.operations.find? (fun i ↦ decide (i.operation = operationId))
  return (component, interface)

def Component.portIds (component : Component Party Asset Domain) : List PortId :=
  component.exports.map ResourcePort.id ++ component.operations.flatMap
    (fun i ↦ i.inputs.map InputPort.id ++ i.outputs.map OutputPort.id)

/-- Private ownership excludes all shared ports, including the owner's own exports.
An import may reduce write access, but cannot grant more rights than its exact export. -/
def validateCatalog (registry : Registry Party Asset Domain)
    (catalog : Catalog Party Asset Domain) : Bool :=
  decide ((catalog.map Component.id).Nodup) &&
  decide ((catalog.flatMap (fun c ↦ c.operations.map OperationInterface.operation)).Nodup) &&
  decide ((catalog.flatMap Component.privateCells).Nodup) &&
  catalog.all (fun c ↦
    decide (c.portIds.Nodup) && decide ((c.imports.map ResourceImport.source).Nodup) &&
    c.exports.all (fun p ↦
      !(catalog.any (fun owner ↦ decide (p.cell ∈ owner.privateCells)))) &&
    c.imports.all (fun p ↦
      !(catalog.any (fun owner ↦ decide (p.cell ∈ owner.privateCells))) &&
      catalog.any (fun source ↦ decide (source.id = p.source.component) &&
        source.exports.any (fun e ↦ decide (e.id = p.source.port) &&
          decide (e.cell = p.cell) && (!p.writable || e.writable)))) &&
    c.operations.all (fun i ↦
      (match registry i.operation with
       | none => false
       | some template => decide (i.inputs.map InputPort.unit = template.signature)) &&
      i.outputs.all (fun o ↦ c.canRead o.cell)))

/-- Resolve references without evaluating financial expressions. Both expression branches,
supply/guard reads, declared reads, declared writes and every delta target are checked. -/
def checkAccess (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) : Except InterfaceFailure PUnit := do
  let reads ← (resolveRefs ctx.principal parties
    (template.requiredStateReads ++ template.stateReads)).mapError .resolution
  let writes ← (resolveRefs ctx.principal parties
    (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))).mapError .resolution
  if !(reads.all component.canRead) then throw .readAccess
  if !(writes.all component.canWrite) then throw .writeAccess
  return ⟨⟩

/-- Earlier absolute positions are necessary even if an untrusted history contains a future key.
The runner additionally ensures history contains only actual successful snapshots. -/
def resolveSource (index : Nat) (history : List (OutputObservation Asset)) :
    InputSource Asset → Except InterfaceFailure (PackedValue Asset)
  | .literal value => .ok value
  | .priorOutput step port =>
    if step < index then
      match history.find? (fun o ↦ decide (o.step = step ∧ o.port = port)) with
      | some output => .ok output.value
      | none => .error .unavailableOutput
    else .error .unavailableOutput

def resolveInputs (index : Nat) (history : List (OutputObservation Asset))
    (interface : OperationInterface Party Asset Domain) (sources : List (InputSource Asset)) :
    Except InterfaceFailure (List (PackedValue Asset)) := do
  if sources.length != interface.inputs.length then throw .inputCount
  let values ← sources.mapM (resolveSource index history)
  if values.map Sigma.fst != interface.inputs.map InputPort.unit then throw .inputUnit
  return values

/-- Output units are intrinsic to the selected cell and balances are copied after commitment. -/
def snapshots (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain) :
    List (OutputObservation Asset) :=
  interface.outputs.map (fun o ↦
    ⟨index, ⟨component, o.id⟩, ⟨.amount o.cell.2.2, state.balance o.cell⟩⟩)

-- BEGIN PROOFS

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem snapshots_length (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain) :
    (snapshots index component interface state).length = interface.outputs.length := by
  simp [snapshots]

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem snapshot_of_selected (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain)
    (output : OutputPort Party Asset Domain) (h : output ∈ interface.outputs) :
    (⟨index, ⟨component, output.id⟩,
      ⟨.amount output.cell.2.2, state.balance output.cell⟩⟩ : OutputObservation Asset) ∈
      snapshots index component interface state := by
  exact List.mem_map.mpr ⟨output, h, rfl⟩

omit [DecidableEq Asset] in
theorem resolveSource_literal (index : Nat) (history : List (OutputObservation Asset))
    (value : PackedValue Asset) : resolveSource index history (.literal value) = .ok value := rfl

omit [DecidableEq Asset] in
theorem resolveSource_not_prior (index step : Nat) (history : List (OutputObservation Asset))
    (port : QualifiedPort) (h : ¬step < index) :
    resolveSource index history (.priorOutput step port) = .error .unavailableOutput := by
  simp [resolveSource, h]

end DefiKernel.Composition


## FILE lean/DefiKernel/Composition/Contracts.lean sha256=d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c

import DefiKernel.Typed.Transition

/-! Proof-level contracts and ledger support. These predicates are not executable certificates;
initialization, environment truth, and local guarantees require separate proof premises. -/
namespace DefiKernel.Composition

open Typed

abbrev World (Party Asset Domain : Type) := ExecutionResult Party Asset Domain

/-- Semantic obligations are separate from finite interface validation. -/
structure ComponentContract (Party Asset Domain Boundary : Type) where
  initial : World Party Asset Domain → Prop
  assumes : Boundary → World Party Asset Domain → Prop
  invariant : World Party Asset Domain → Prop
  guarantees : Boundary → World Party Asset Domain → World Party Asset Domain → Prop

variable {Party Asset Domain Boundary : Type}

/-- Initialization and the inductive rule must actually be proved by a contract instance. -/
structure ContractObligations
    (contract : ComponentContract Party Asset Domain Boundary) : Prop where
  initialized : ∀ w, contract.initial w → contract.invariant w
  preserved : ∀ b pre post, contract.invariant pre → contract.assumes b pre →
    contract.guarantees b pre post → contract.invariant post

def Initial (contracts : List (ComponentContract Party Asset Domain Boundary))
    (world : World Party Asset Domain) : Prop :=
  ∀ contract ∈ contracts, contract.initial world

def AgreeOn (region : Set (Cell Party Asset Domain))
    (pre post : State Party Asset Domain) : Prop :=
  ∀ cell ∈ region, pre.balance cell = post.balance cell

/-- Only ledger predicates are framed; this definition does not cover capability-store reads. -/
def Supports (region : Set (Cell Party Asset Domain))
    (predicate : State Party Asset Domain → Prop) : Prop :=
  ∀ pre post, AgreeOn region pre post → (predicate pre ↔ predicate post)

-- BEGIN PROOFS

theorem AgreeOn.refl (region : Set (Cell Party Asset Domain))
    (state : State Party Asset Domain) : AgreeOn region state state := by
  intro cell hc
  rfl

theorem AgreeOn.symm {region : Set (Cell Party Asset Domain)}
    {s t : State Party Asset Domain} (h : AgreeOn region s t) : AgreeOn region t s := by
  intro cell hc
  exact (h cell hc).symm

theorem AgreeOn.trans {region : Set (Cell Party Asset Domain)}
    {s t u : State Party Asset Domain} (hst : AgreeOn region s t)
    (htu : AgreeOn region t u) : AgreeOn region s u := by
  intro cell hc
  exact (hst cell hc).trans (htu cell hc)

theorem supported_frame {region : Set (Cell Party Asset Domain)}
    {predicate : State Party Asset Domain → Prop} (support : Supports region predicate)
    {pre post : State Party Asset Domain} (unchanged : AgreeOn region pre post) :
    predicate pre ↔ predicate post := support pre post unchanged

theorem supports_balance (cell : Cell Party Asset Domain) (predicate : ℚ → Prop) :
    Supports {cell} (fun state ↦ predicate (state.balance cell)) := by
  intro pre post h
  change predicate (pre.balance cell) ↔ predicate (post.balance cell)
  rw [h cell (Set.mem_singleton cell)]

theorem initialized_invariants
    (contracts : List (ComponentContract Party Asset Domain Boundary))
    (obligations : ∀ c ∈ contracts, ContractObligations c)
    (world : World Party Asset Domain) (initial : Initial contracts world) :
    ∀ c ∈ contracts, c.invariant world := by
  intro c hc
  exact (obligations c hc).initialized world (initial c hc)

end DefiKernel.Composition


## FILE lean/DefiKernel/Composition/InterfaceTests.lean sha256=38d512c55cab3278b5eaaf06fa6b5545937166947386be555813a6b67cc1f17a

import DefiKernel.Composition.Interfaces
import DefiKernel.Typed.Examples

/-! Bounded independent siblings for structural interfaces. Kernel execution supplies a
funding/authority control; sequence commit preservation belongs to the adapter tests. -/
namespace DefiKernel.Composition.InterfaceTests
open Typed Typed.Examples

abbrev C := Component Party Asset Domain
abbrev I := OperationInterface Party Asset Domain

def aliceUSD : Cell Party Asset Domain := (.main, .alice, .usd)
def bobUSD : Cell Party Asset Domain := (.main, .bob, .usd)
def vaultUSD : Cell Party Asset Domain := (.main, .vault, .usd)
def iface : I := ⟨transferId, [⟨⟨0⟩, .amount .usd⟩], [⟨⟨1⟩, aliceUSD⟩]⟩
def owner : C := ⟨⟨0⟩, [aliceUSD, bobUSD], [], [], [iface]⟩
def foreign : C := ⟨⟨1⟩, [vaultUSD], [], [], []⟩
def exporter : C := ⟨⟨1⟩, [], [⟨⟨10⟩, vaultUSD, true⟩], [], []⟩
def shared : C := { owner with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, vaultUSD, true⟩] }
def readOnly : C := { shared with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, vaultUSD, false⟩] }
def accepted (r : Except InterfaceFailure PUnit) : Bool :=
  match r with | .ok _ => true | .error _ => false

def failure {α : Type} (r : Except InterfaceFailure α) (expected : InterfaceFailure) : Bool :=
  match r with | .ok _ => false | .error e => decide (e = expected)

def sevenUSD (r : Except InterfaceFailure (List (PackedValue Asset))) : Bool :=
  match r with | .ok [⟨.amount .usd, q⟩] => decide (q = 7) | _ => false

def history : List (OutputObservation Asset) := [⟨2, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩]
def binding : List (InputSource Asset) := [.priorOutput 2 ⟨⟨0⟩, ⟨1⟩⟩]
def hiddenGuard : Op := { transfer with
  guard := .ite (.lit true) (.lit true)
    (.binary (.le (.amount .usd)) (.balance (ref .usd (.literal .vault))) (.lit 100)) }
def hiddenEffect : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, .balance (ref .usd (.literal .vault))⟩] }
def hiddenSupply : Op := { transfer with
  supplyDeltas := [⟨.main, .usd, .balance (ref .usd (.literal .vault))⟩] }
def fundedKernelControl : Bool := match provisioned with
  | .error _ => false
  | .ok store => match Typed.execute registry store aliceContext fresh 100
      (transferRequest 3 .vault) initial with
    | .error _ => false
    | .ok post => decide (post.state.balance aliceUSD = 7 ∧ post.state.balance vaultUSD = 23)

def checks : List (String × Bool) := [
  ("interface.valid", validateCatalog registry [owner, foreign]),
  ("interface.duplicate-component", !validateCatalog registry [owner, owner]),
  ("interface.duplicate-output", !validateCatalog registry
    [{ owner with operations := [{ iface with outputs := [⟨⟨1⟩, aliceUSD⟩, ⟨⟨1⟩, bobUSD⟩] }] }]),
  ("interface.input-output-collision", !validateCatalog registry
    [{ owner with operations := [{ iface with inputs := [⟨⟨1⟩, .amount .usd⟩] }] }]),
  ("interface.duplicate-export", !validateCatalog registry
    [shared, { exporter with exports := [⟨⟨10⟩, vaultUSD, true⟩, ⟨⟨10⟩, vaultUSD, true⟩] }]),
  ("interface.duplicate-import", !validateCatalog registry
    [{ shared with imports := shared.imports ++ shared.imports }, exporter]),
  ("interface.unknown-operation", !validateCatalog registry
    [{ owner with operations := [{ iface with operation := ⟨99⟩ }] }]),
  ("interface.ambiguous-owner", !validateCatalog registry
    [owner, { foreign with privateCells := [], operations := [{ iface with outputs := [] }] }]),
  ("interface.wrong-signature", !validateCatalog registry
    [{ owner with operations := [{ iface with inputs := [⟨⟨0⟩, .amount .share⟩] }] }]),
  ("interface.private-overlap", !validateCatalog registry
    [owner, { foreign with privateCells := [aliceUSD] }]),
  ("interface.private-export", !validateCatalog registry
    [owner, { foreign with exports := [⟨⟨10⟩, vaultUSD, true⟩] }]),
  ("interface.private-import", !validateCatalog registry [shared, foreign]),
  ("interface.shared-write-valid", validateCatalog registry [shared, exporter]),
  ("interface.shared-read-valid", validateCatalog registry [readOnly, exporter]),
  ("interface.import-cell", !validateCatalog registry
    [{ shared with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, (.main, .pool, .usd), true⟩] }, exporter]),
  ("interface.import-domain", !validateCatalog registry
    [{ shared with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, (.other, .vault, .usd), true⟩] }, exporter]),
  ("interface.import-asset", !validateCatalog registry
    [{ shared with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, (.main, .vault, .share), true⟩] }, exporter]),
  ("interface.import-rights", !validateCatalog registry
    [shared, { exporter with exports := [⟨⟨10⟩, vaultUSD, false⟩] }]),
  ("interface.output-hidden", !validateCatalog registry
    [{ owner with operations := [{ iface with outputs := [⟨⟨1⟩, vaultUSD⟩] }] }]),
  ("interface.lookup-owner", (lookupOperation [owner, foreign] ⟨0⟩ transferId).isSome),
  ("interface.lookup-foreign", (lookupOperation [owner, foreign] ⟨1⟩ transferId).isNone),
  ("interface.private-access", accepted (checkAccess owner transfer aliceContext [.bob])),
  ("interface.foreign-funded-kernel-control", fundedKernelControl),
  ("interface.foreign-write",
    failure (checkAccess owner transfer aliceContext [.vault]) .writeAccess),
  ("interface.shared-write", accepted (checkAccess shared transfer aliceContext [.vault])),
  ("interface.readonly-write",
    failure (checkAccess readOnly transfer aliceContext [.vault]) .writeAccess),
  ("interface.actual-target", failure (checkAccess owner
    { transfer with writes := [] } aliceContext [.vault]) .writeAccess),
  ("interface.hidden-branch",
    failure (checkAccess owner hiddenGuard aliceContext [.bob]) .readAccess),
  ("interface.hidden-effect",
    failure (checkAccess owner hiddenEffect aliceContext [.bob]) .readAccess),
  ("interface.hidden-supply",
    failure (checkAccess owner hiddenSupply aliceContext [.bob]) .readAccess),
  ("interface.shared-read", accepted (checkAccess readOnly hiddenGuard aliceContext [.bob])),
  ("interface.declared-write", failure (checkAccess owner
    { transfer with writes := transfer.writes ++ [packedRef .usd (.literal .vault)] }
    aliceContext [.bob]) .writeAccess),
  ("interface.declared-read", failure (checkAccess owner
    { transfer with stateReads := [packedRef .usd (.literal .vault)] }
    aliceContext [.bob]) .readAccess),
  ("interface.missing-party", failure (checkAccess owner transfer aliceContext [])
    (.resolution .partyArgument)),
  ("interface.literal", sevenUSD (resolveInputs 3 [] iface [.literal ⟨.amount .usd, 7⟩])),
  ("interface.snapshot-binding", sevenUSD (resolveInputs 3 history iface binding)),
  ("interface.wrong-unit", failure (resolveInputs 3 history iface
    [.literal ⟨.amount .share, 7⟩]) .inputUnit),
  ("interface.wrong-output-unit", failure (resolveInputs 3
    [⟨2, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .share, 7⟩⟩] iface binding) .inputUnit),
  ("interface.unknown-port", failure (resolveInputs 3 history iface
    [.priorOutput 2 ⟨⟨0⟩, ⟨99⟩⟩]) .unavailableOutput),
  ("interface.forward", failure (resolveInputs 1 history iface binding) .unavailableOutput),
  ("interface.current-index", failure (resolveInputs 2 history iface binding) .unavailableOutput),
  ("interface.unavailable", failure (resolveInputs 3 [] iface binding) .unavailableOutput),
  ("interface.input-count", failure (resolveInputs 3 history iface []) .inputCount),
  ("interface.snapshot-exact", match snapshots 2 ⟨0⟩ iface initial with
    | [⟨2, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, q⟩⟩] => decide (q = 10)
    | _ => false)
]

-- BEGIN PROOFS

#eval show IO _root_.Unit from do
  if checks.isEmpty then throw (IO.userError "Interface comparison inventory empty")
  for (label, ok) in checks do IO.println s!"{label}: {ok}"
  let failures := checks.filter (fun entry ↦ !entry.2)
  if !failures.isEmpty then throw (IO.userError s!"Interface failures: {failures.length}")

end DefiKernel.Composition.InterfaceTests


## FILE review/semantic-kernel/sprint5/interfaces-report.md sha256=2ca2d7276b7e4ebcef7ff503ed4d8bc4878cd4ae080e0d901f5423ec211ea608

# Sprint 5 interface implementation

Implemented additive `Composition/Interfaces.lean` and focused `InterfaceTests.lean`
for tasks 2.1–2.4. No historical Lean sources, root imports, commits or task boxes
were changed by this worker. Baseline permission came from the parent after its
successful build/drivers at `86b77b7`.

The public API follows the parent coordination message: typed component/port
wrappers; catalog ownership and exact shared resources; `validateCatalog`,
`lookupOperation`, `checkAccess`, `resolveInputs`, and `snapshots`. Resource
imports identify an exported qualified port directly; no alias mechanism exists.
Component-local input, output and export IDs share one uniqueness namespace.
Private cells cannot also be shared exports. Read-only imports may reduce export
rights. Every concrete delta target is checked even when absent from declared
writes. Required reads include both branches, guards, effects and supplies;
declared reads/writes are checked separately. Output reads are checked during
catalog validation.

Verification:

- LSP diagnostics on Interfaces: success, no errors or warnings.
- Dependency-aware `lake lean DefiKernel/Composition/InterfaceTests.lean`: exit 0.
- Fresh `lake env lean DefiKernel/Composition/InterfaceTests.lean`: exit 0;
  44/44 named runtime comparisons true in `interfaces-runtime.log`.
- `git diff --check`: no output. Source search: no forbidden proof constructs.
- Four generic theorems: `snapshots_length`, `snapshot_of_selected`,
  `resolveSource_literal`, `resolveSource_not_prior`. These concern list snapshots
  and routing; they do not establish general catalog soundness or confidentiality.

The funded interference control executes the real typed kernel with its actually
provisioned live capability store and proves the bounded execution result by
comparing Alice's 7 USD and the vault's 23 USD. The sibling interface checker
refuses that same target with `writeAccess`; adding an exact writable import
permits it. Adapter tests must separately cover whole-world unchanged refusal,
sequence histories and stale-snapshot stability. `resolveInputs` trusts the
runner's successful-history invariant; it does not authenticate arbitrary
external history lists. No financial authority is added by value routing.

Source SHA-256:

- Interfaces.lean: `0f85b76f3066423ead95a3973a4721b7fdf7a5a2552d34d59950a0d26a21c5de`
- InterfaceTests.lean: `38d512c55cab3278b5eaaf06fa6b5545937166947386be555813a6b67cc1f17a`

Full integrated axiom audit, source mutation evidence and independent native
Grok/Fable review remain parent integration obligations; this report claims none
of those completed.

