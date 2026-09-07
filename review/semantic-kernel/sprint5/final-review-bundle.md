Independently review the FINAL Sprint5 candidate 28ba18c446f72084ff11b4d125dccf93bf8f4162. This is (1) a targeted follow-up on the four initial Grok/Fable interface+execution reviews and their concrete findings, and (2) the broad integrated regression/evidence review required by OpenSpec. All implementation is GPT6 via stock Codex; no Foreman. Native source review is advisory, not independent execution. No tools/builds are available to you; inspect supplied sources and evidence. Return ACCEPT WITH LIMITATIONS or REQUEST CHANGES; rank concrete unresolved defects, identify file/line, explain exploit/counterexample, and distinguish proof strength from bounded tests and assumed facts. Preserve dissent. Verify the previous exporter/read-only and snapshot-domain holes and missing interface-write/admin lifts are actually addressed, and assess whether the integrated93comparisons,12source mutations,36runner controls and proof audit provide honest discriminating evidence. Do not presume these fix claims correct. Report only materially actionable remaining issues; keep prior evidence limitations explicit.


## FILE openspec/changes/typed-interfaces-sequential-composition/design.md sha256=99954c4587dcd3b33c621be3d4c8e02b758df7f4d08eacf217039adcbe3caadc

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
  typed post-state balance snapshots within the registered operation's domain.
  They are total after successful execution.
- Resource ports identify exact cells, including domain and asset, with read or
  read/write access. Shared imports must match declared exports and cannot
  escalate access. Each shared cell has a unique exporter; a component's export
  and import cells are disjoint. A read-only export also limits its own exporter.

Each component owns a finite private cell set and an operation allowlist.
Catalog authorship is trusted: export declarations identify shared providers,
not on-chain ownership certificates. Private ownership is disjoint and excludes every other component's resource
access. Operations have unambiguous component ownership. Resolve operation cell
references using the actual principal and party list; packed numeric arguments
cannot select cells in the current reference syntax. Conservatively check all
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


## FILE openspec/changes/typed-interfaces-sequential-composition/specs/composition-regression-evidence/spec.md sha256=bea7d8d7a7ad9642eeddeab0ef86984fd4ea165c63442618b6a4568bb34fcb49

## Purpose

Require reproducible composed examples, discriminating mutations, and independent
review evidence with claims tied to the source and checks actually performed.

## ADDED Requirements

### Requirement: Composed reference workflow coverage
The system SHALL provide named, independently expected comparisons for order,
first and middle refusal, state propagation, typed output routing, resource
isolation, administration, revocation, and protected-state framing. Comparisons
SHALL check complete finite worlds and observable histories where applicable.

#### Scenario: Positive and negative siblings
- **WHEN** foreign-private access, revoked use, or incompatible output binding is tested
- **THEN** a corresponding permitted, live, or correctly typed sibling succeeds so unrelated refusal does not explain the negative result

#### Scenario: Composed financial reference
- **WHEN** transfer, deposit, and withdrawal are composed from the documented initialized reference world
- **THEN** final balances, actual supply receipts, outputs, and event order match independently specified expectations

### Requirement: Discriminating source mutations
The system SHALL compile and execute actual altered workflow code to detect
ordering changes, continuation after refusal, stale ledger/store use, omitted
revocation propagation, interface bypass, incorrect output routing, omitted
supply receipts, and reset continuation positions. Each required mutant SHALL
be killed by a relevant executed comparison.

#### Scenario: Executable mutant
- **WHEN** a mutant compiles but changes a targeted workflow behavior
- **THEN** a named comparison fails and the evidence records the mutation, source identities, command, and outcome

#### Scenario: Invalid or vacuous mutation run
- **WHEN** a required mutant does not apply, fails to compile, has an empty comparison inventory, or survives
- **THEN** acceptance is blocked and the result is not reported as a detected semantic mutation

### Requirement: Honest verification and proof scope
The system SHALL preserve legacy regressions, audit the imported composition
proof closure, and record theorem premises separately from bounded execution and
measurements. Accepted proofs SHALL contain no admitted proof holes, custom
axioms, or native decision axioms.

#### Scenario: New imported proof
- **WHEN** a composition proof enters the accepted import closure
- **THEN** the axiom audit covers its dependencies and the proof inventory states its scope and premises

#### Scenario: Existing regression failure
- **WHEN** a previously passing required regression fails after composition changes
- **THEN** Sprint 5 acceptance is blocked until the failure is resolved and relevant checks pass

### Requirement: Independent review and source-bound delivery
The system SHALL retain GPT-6 implementation through the stock harness and native
Grok and Fable review of the actual candidate, with findings, fixes, limitations,
and exact source/tool identities saved. It SHALL NOT use Foreman. Planning
completion SHALL be distinguished from implementation acceptance.

#### Scenario: Candidate changes after review
- **WHEN** a source fix changes the candidate after independent review
- **THEN** affected verification and review evidence is refreshed against the new candidate before acceptance

#### Scenario: Delivery record
- **WHEN** Sprint 5 is marked implemented
- **THEN** all required tasks, verification, adjudicated review, and branch delivery evidence are complete and the remote branch head is verified


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


## FILE openspec/changes/typed-interfaces-sequential-composition/specs/typed-component-interfaces/spec.md sha256=cbc6387cd050c8cf45f20049cc7abedf0198e9c3bd88c3a4bd796206de3e7978

## Purpose

Describe component boundaries and typed connections so workflows can exchange
values and share resources without silently expanding access or proof claims.

## ADDED Requirements

### Requirement: Stable typed port declarations
The system SHALL identify ports by stable component and port identities, distinguish
value inputs, value outputs, and resource access, and reject duplicate identities,
unknown operations, ambiguous operation ownership, and incompatible signatures.
Selected-cell outputs SHALL remain within the registered operation's domain.

#### Scenario: Valid declared operation
- **WHEN** a uniquely owned registered operation has inputs matching its signature and valid selected-cell outputs
- **THEN** its interface is accepted and every output has the selected cell's asset unit

#### Scenario: Invalid declarations
- **WHEN** declarations contain duplicate port identities, an unknown operation, ambiguous ownership, or a signature mismatch
- **THEN** configuration validation refuses before any workflow step executes

#### Scenario: Cross-domain snapshot
- **WHEN** an operation declares a selected-cell output in a different domain
- **THEN** configuration validation refuses even if the component can read that cell

### Requirement: Private ownership and explicit shared access
The system SHALL enforce disjoint private ownership and explicitly matched shared
resource imports and exports, including exact cell identity, domain, asset, and
access rights. Private cells SHALL NOT be accessible as another component's
resources. A component SHALL access only its permitted reads and writes.
Shared cells SHALL have unique exporters, and each component's exported and
imported cells SHALL be disjoint. Export rights SHALL also constrain the exporter.

#### Scenario: Overlapping ownership
- **WHEN** two components claim the same private cell or another component imports that cell as shared
- **THEN** configuration validation refuses without changing the world

#### Scenario: Conflicting exports
- **WHEN** two export declarations claim the same cell or a component imports a cell it also exports
- **THEN** configuration validation refuses instead of combining conflicting permissions

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


## FILE review/semantic-kernel/sprint5/ADJUDICATION.md sha256=70e9914c1170e1b647c6f1772885c82216d2f9031064dfad5cb9a7c1e81fa586

# Sprint 5 native review adjudication

Implementation uses GPT-6 through the stock Codex harness. Reviews use the native
Grok and Fable CLIs, with no Foreman. Review is advisory source analysis, not an
independent Lean build or mathematical proof.

Initial source candidate: `ba3661f3e875ef6c48e71300fec339d333dab697`.
Revised source candidate: `28ba18c` (full identity is bound in the final review bundle).

## Initial reviews and remediation

Both providers reviewed interfaces/contracts and execution/preservation separately.
All four initial reviews returned ACCEPT WITH LIMITATIONS, with explicit dissent
that integration must close shared-access and isolation-evidence gaps. That dissent
is retained in the raw responses; the initial reviews alone do not close acceptance.

| Finding | Resolution in revised candidate |
| --- | --- |
| Duplicate or self-declared exports could bypass read-only imports | Require globally unique exported cells and disjoint export/import cells within each component; add conflicting-provider and self-import negative controls |
| Output snapshots could read another domain | Require selected outputs to match the registered operation domain; test the otherwise-visible cross-domain negative |
| Component access checks lacked a proof bridge | Add `checkAccess_ok_iff`, `checkAccess_declaredWrites`, `evaluated_writes`, `prepareInvocation_access`, `StepSound.component_writes`, `StepSound.component_locality`, and the trace-level component locality theorem |
| Administrative authority was implicit in step relations | Add explicit `TraceSound.administration`; invocation receipt rights remain separate |
| Interface-only/adapter-only tests did not establish composed refusal behavior | Add full-world, store, receipt, output, index, and refusal comparisons for private/shared/read-only interference and output routing; integrate all 93 comparisons |
| Initial reports did not evidence the whole new import closure | Save the revised full build, eight fresh verification commands, imported axiom audit, and exact source hashes in `build-verification.json` |
| Argument resolution wording overstated the current syntax | Document principal/party-list resolution, static output validation, and the catalog-authorship assumption |
| A runtime comparison was described as a proof | Correct the interface report to call it a check; distinguish theorem inventory from executed comparisons |

No false confidentiality claim is added: interface checks cover declared and
syntactically collected reads, and successful permitted writes. Environment truth,
configuration authenticity, and capability-store provenance remain assumptions.
The unchanged typed expression implementation and authority APIs are supplied to
the final review so their collector and scope behavior can be inspected directly.

The generic initialization/contract theorem retains explicit local and boundary
premises. The concrete collateral frame theorem discharges its protected-write
premise by kernel reduction. The separate boundary-contract fixture uses time as
an explicit assumption and monotone collateral as its guarantee; it does not use
time as a financial price. Nonnegativity is supplied by proof-carrying states and
is not counted as an additional invariant-discovery result.

The mutation projection boundary in `Sequence.lean` was moved above proof-only
relations so the executable projection does not depend on omitted step proofs.
This changes projection organization, not accepted Lean execution semantics.

## Final review

Pending the source-bound combined follow-up and regression/evidence review by
both native providers. The final mutation replay and delivery are recorded
separately and are not implied by this draft adjudication.


## FILE lean/DefiKernel/Composition/Audit.lean sha256=fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2

import DefiKernel.Composition.InterfaceTests
import DefiKernel.Composition.ExecutionTests
import DefiKernel.Composition.Tests

/-! One named inventory for interface, adapter and complete composed workflow comparisons.
Mutation projections execute this driver over freshly captured dependency sources. -/
namespace DefiKernel.Composition

def runtimeChecks : List (String × Bool) :=
  InterfaceTests.checks ++ ExecutionTests.checks ++ Tests.checks

#eval do
  if runtimeChecks.isEmpty then throw (IO.userError "Empty composition runtime inventory")
  let names := runtimeChecks.map Prod.fst
  if names.eraseDups.length != names.length then
    throw (IO.userError "Duplicate composition runtime names")
  let mut failed := 0
  for (label, passed) in runtimeChecks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Composition runtime comparisons failed: {failed}")

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


## FILE lean/DefiKernel/Composition/Examples.lean sha256=55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064

import DefiKernel.Composition.Preservation
import DefiKernel.Typed.Examples
namespace DefiKernel.Composition.Examples
open Typed Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev W := World Party Asset Domain
abbrev S := Step Party Asset Domain
def aliceUsd : C := (.main, .alice, .usd)
def bobUsd : C := (.main, .bob, .usd)
def vaultUsd : C := (.main, .vault, .usd)
def aliceShare : C := (.main, .alice, .share)
def collateral : C := (.main, .alice, .collateral)
def transferInterface : OperationInterface Party Asset Domain :=
  ⟨transferId, [⟨⟨0⟩, .amount .usd⟩], [⟨⟨1⟩, aliceUsd⟩]⟩
def depositInterface : OperationInterface Party Asset Domain :=
  ⟨depositId, [⟨⟨2⟩, .amount .usd⟩], [⟨⟨3⟩, aliceShare⟩, ⟨⟨4⟩, aliceUsd⟩]⟩
def withdrawInterface : OperationInterface Party Asset Domain :=
  ⟨withdrawId, [⟨⟨5⟩, .amount .share⟩], [⟨⟨6⟩, aliceUsd⟩]⟩
def catalog : Catalog Party Asset Domain := [
  ⟨⟨0⟩, [bobUsd], [⟨⟨10⟩, aliceUsd, true⟩], [], [transferInterface]⟩,
  ⟨⟨1⟩, [vaultUsd, aliceShare], [], [⟨⟨⟨0⟩, ⟨10⟩⟩, aliceUsd, true⟩],
    [depositInterface, withdrawInterface]⟩,
  ⟨⟨2⟩, [collateral], [], [], []⟩]
def cfg : Config Party Asset Domain := ⟨registry, domainAdmin, catalog⟩
def boundary (_ : Nat) : Boundary Party Asset Domain := ⟨aliceContext, fresh, 100⟩
/-- Independent table: no call to administrative execution. -/
def expectedStore : Store := ⟨[
  ⟨⟨.alice, .main, ⟨0⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨0⟩, .debit aliceUsd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨1⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨1⟩, .debit aliceUsd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨1⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .debit vaultUsd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .debit aliceShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.alice, .main, ⟨3⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨3⟩, .debit (.main, .pool, .usd)⟩, true⟩,
  ⟨⟨.alice, .main, ⟨3⟩, .changeSupply .main .debt⟩, true⟩]⟩
def initialWorld : W := ⟨initial, expectedStore⟩
def transferStep (q : ℚ) : S := .invoke
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def depositSource (source : InputSource Asset) : S := .invoke
  ⟨⟨1⟩, depositId, [], [source], allCapabilityIds, none⟩
def depositStep (q : ℚ) : S := depositSource (.literal ⟨.amount .usd, q⟩)
def withdrawStep (q : ℚ) : S := .invoke
  ⟨⟨1⟩, withdrawId, [], [.literal ⟨.amount .share, q⟩], allCapabilityIds, none⟩
def routedDeposit (index : Nat := 0) : S := depositSource (.priorOutput index ⟨⟨0⟩, ⟨1⟩⟩)
def workflow : List S := [transferStep 3, depositStep 4, withdrawStep 2]
/-- Boundary truth is an explicit premise, independent of structural validation. -/
def collateralContract : ComponentContract Party Asset Domain ℚ where
  initial w := w.state.balance collateral = 10
  assumes price _ := 1 ≤ price
  invariant w := 10 ≤ w.state.balance collateral
  guarantees price pre post := price * pre.state.balance collateral ≤ post.state.balance collateral
/-- Concrete post-transfer ledger for the support counterexample. -/
def transferred : Ledger where
  balance c := if c = aliceUsd then 7 else if c = bobUsd then 3 else initial.balance c
  nonneg c := by
    split
    · decide
    · split
      · decide
      · exact initial.nonneg c
def boundaryContract : ComponentContract Party Asset Domain (Boundary Party Asset Domain) where
  initial := collateralContract.initial
  assumes b _ := b.now = 100
  invariant := collateralContract.invariant
  guarantees _ pre post := pre.state.balance collateral ≤ post.state.balance collateral
-- BEGIN PROOFS
theorem collateralContract_obligations : ContractObligations collateralContract := by
  constructor
  · intro w h
    exact le_of_eq h.symm
  · intro price pre post hi ha hg
    change 10 ≤ post.state.balance collateral
    change 10 ≤ pre.state.balance collateral at hi
    change 1 ≤ price at ha
    change price * pre.state.balance collateral ≤ post.state.balance collateral at hg
    have hm : pre.state.balance collateral ≤ price * pre.state.balance collateral := by
      simpa using mul_le_mul_of_nonneg_right ha (pre.state.nonneg collateral)
    exact hi.trans (hm.trans hg)
theorem collateral_initialized : collateralContract.initial initialWorld := by rfl
theorem collateral_supported : Supports {collateral}
    (fun s : Ledger ↦ 10 ≤ s.balance collateral) := supports_balance collateral _
theorem unsupported_predicate_counterexample :
    ¬ Supports {collateral} (fun s : Ledger ↦ s.balance aliceUsd = 10) := by
  intro h
  have agree : AgreeOn {collateral} initial transferred := by
    intro cell hc
    have he : cell = collateral := hc
    subst cell
    rfl
  have bad := (h initial transferred agree).mp (show initial.balance aliceUsd = 10 from rfl)
  change (7 : ℚ) = 10 at bad
  exact (by decide : (7 : ℚ) ≠ 10) bad

theorem dropping_disjointness_counterexample :
    Supports {aliceUsd} (fun s : Ledger ↦ s.balance aliceUsd = 10) ∧
    initial.balance aliceUsd = 10 ∧ transferred.balance aliceUsd ≠ 10 := by
  exact ⟨supports_balance aliceUsd (fun q ↦ q = 10), rfl, by decide⟩

theorem workflow_accounting (d : Domain) (a : Asset) :
    total (Composition.run cfg boundary initialWorld workflow).world.state d a =
    total initialWorld.state d a +
      traceSupply (Composition.run cfg boundary initialWorld workflow).events d a :=
  run_accounting cfg boundary initialWorld workflow d a

theorem refused_mint_prefix_accounting (d : Domain) (a : Asset) :
    total (Composition.run cfg boundary initialWorld
      [depositStep 4, transferStep 8]).world.state d a =
    total initialWorld.state d a +
      traceSupply (Composition.run cfg boundary initialWorld
        [depositStep 4, transferStep 8]).events d a :=
  run_accounting cfg boundary initialWorld [depositStep 4,transferStep 8] d a

theorem workflow_nonnegative (c : C) :
    0 ≤ (Composition.run cfg boundary initialWorld workflow).world.state.balance c :=
  run_nonnegative cfg boundary initialWorld workflow c

set_option maxRecDepth 10000 in
set_option maxHeartbeats 2000000 in
-- Kernel reduction expands the complete finite workflow, including authority and footprint checks.
theorem workflow_protected_writes :
    collateral ∉ traceWrites (Composition.run cfg boundary initialWorld workflow).events := by
  decide +kernel

theorem workflow_collateral_frame :
    (10 ≤ initialWorld.state.balance collateral) ↔
    10 ≤ (Composition.run cfg boundary initialWorld workflow).world.state.balance collateral := by
  apply run_frame cfg boundary initialWorld workflow {collateral}
    (fun s ↦ 10 ≤ s.balance collateral) collateral_supported
  intro cell member
  have eq : cell = collateral := member
  subst cell
  exact workflow_protected_writes

theorem boundaryContract_obligations : ContractObligations boundaryContract :=
  ⟨collateralContract_obligations.initialized,
    fun _ _ _ hi _ hg ↦ hi.trans hg⟩

theorem workflow_conditional_invariant
    (localGuarantee : ∀ n outputs step pre result,
      StepSound cfg (boundary n) n outputs step pre result →
      boundaryContract.invariant pre → boundaryContract.assumes (boundary n) pre ∧
        boundaryContract.guarantees (boundary n) pre result.world) :
    boundaryContract.invariant (Composition.run cfg boundary initialWorld workflow).world :=
  run_contract cfg boundary initialWorld workflow boundaryContract boundaryContract_obligations
    collateral_initialized localGuarantee

end DefiKernel.Composition.Examples


## FILE lean/DefiKernel/Composition/Execution.lean sha256=34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602

import DefiKernel.Composition.Interfaces
import DefiKernel.Composition.Contracts

/-! Single-step adaptation of registered execution. Receipts are re-evaluated against the
same pre-state, and are returned only after both execution and extraction succeed. -/
namespace DefiKernel.Composition
open Typed

structure Boundary (Party Asset Domain : Type) where
  ctx : InvocationContext Party Domain
  env : Environment Asset Domain
  now : Nat

structure Config (Party Asset Domain : Type) where
  registry : Registry Party Asset Domain
  domainAdmin : Domain → Party
  catalog : Catalog Party Asset Domain

structure Invocation (Party Asset Domain : Type) where
  component : ComponentId
  operation : OperationId
  parties : List Party
  inputs : List (InputSource Asset)
  capabilityIds : List CapabilityId
  claimedActor : Option Party := none

inductive Step (Party Asset Domain : Type) where
  | invoke (invocation : Invocation Party Asset Domain)
  | issue (grant : Grant Party Asset Domain)
  | revoke (id : CapabilityId)

inductive Failure where
  | configuration
  | interface (reason : InterfaceFailure)
  | kernel (reason : Typed.Refusal)
  | authority (reason : AuthorityFailure)
  | internalReceipt
  deriving DecidableEq, Repr

inductive Receipt (Party Asset Domain : Type) where
  | invoked (request : Request Party Asset Domain) (evaluated : Evaluated Party Asset Domain)
  | issued (id : CapabilityId)
  | revoked (id : CapabilityId)

structure StepResult (Party Asset Domain : Type) where
  world : World Party Asset Domain
  receipt : Receipt Party Asset Domain
  outputs : List (OutputObservation Asset)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def Config.authority (cfg : Config P A D) := registryAuthorityConfig cfg.registry cfg.domainAdmin

def Receipt.supply (receipt : Receipt P A D) (d : D) (a : A) : ℚ :=
  match receipt with
  | .invoked _ e => e.supply d a
  | _ => 0

def Receipt.writes (receipt : Receipt P A D) : List (Cell P A D) :=
  match receipt with
  | .invoked _ e => e.writes
  | _ => []

def prepareInvocation (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (inv : Invocation P A D) :
    Except Failure (OperationInterface P A D × Request P A D) := do
  let (component, iface) ← match lookupOperation cfg.catalog inv.component inv.operation with
    | none => .error (.interface .unknownOperation)
    | some pair => .ok pair
  let arguments ← (resolveInputs index history iface inv.inputs).mapError Failure.interface
  let template ← match cfg.registry inv.operation with
    | none => .error (.kernel .unknownOperation)
    | some template => .ok template
  let _ ← (checkAccess component template boundary.ctx inv.parties).mapError Failure.interface
  return (iface, ⟨inv.operation, inv.parties, arguments, inv.capabilityIds, inv.claimedActor⟩)

def extractReceipt (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D) : Except Failure (Evaluated P A D) := do
  let template ← match cfg.registry request.operation with
    | none => .error .internalReceipt
    | some template => .ok template
  let args ← (Args.check template.signature request.arguments).mapError (fun _ ↦ .internalReceipt)
  (template.evaluate ⟨pre.state, boundary.env, boundary.ctx.principal,
    request.parties, args, boundary.now⟩).mapError (fun _ ↦ .internalReceipt)

def executeStep (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D) :
    Except Failure (StepResult P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  match step with
  | .invoke inv =>
    let (iface, request) ← prepareInvocation cfg boundary index history inv
    let post ← (Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state).mapError Failure.kernel
    let e ← extractReceipt cfg boundary request pre
    return ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩
  | .issue grant =>
    let (id, store) ← (issueCapability cfg.authority boundary.ctx pre.capabilities grant)
      |>.mapError Failure.authority
    return ⟨⟨pre.state, store⟩, .issued id, []⟩
  | .revoke id =>
    let store ← (revokeCapability cfg.authority boundary.ctx pre.capabilities id)
      |>.mapError Failure.authority
    return ⟨⟨pre.state, store⟩, .revoked id, []⟩

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
/-- The emitted write footprint is exactly the template's resolved declared footprint. -/
theorem evaluated_writes (template : Template P A D)
    (context : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate context = .ok e) :
    resolveRefs context.caller context.parties template.writes = .ok e.writes := by
  unfold Template.evaluate at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  have hp := Except.ok.inj h
  rw [← hp]
  assumption

omit [Fintype P] [Fintype A] [Fintype D] in
/-- The component and access check are selected from the trusted catalog and registry. -/
theorem prepareInvocation_access (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (iface : OperationInterface P A D) (request : Request P A D)
    (h : prepareInvocation cfg boundary index history inv = .ok (iface, request)) :
    ∃ component template, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ cfg.registry request.operation = some template ∧
      checkAccess component template boundary.ctx request.parties = .ok PUnit.unit := by
  cases hl : lookupOperation cfg.catalog inv.component inv.operation with
  | none => simp [prepareInvocation, hl, bind, Except.bind] at h
  | some pair =>
    rcases pair with ⟨component, selected⟩
    cases ha : resolveInputs index history selected inv.inputs with
    | error reason => simp [prepareInvocation, hl, ha, bind, Except.bind, Except.mapError] at h
    | ok arguments =>
      cases ht : cfg.registry inv.operation with
      | none => simp [prepareInvocation, hl, ha, ht, bind, Except.bind, Except.mapError] at h
      | some template =>
        cases hc : checkAccess component template boundary.ctx inv.parties with
        | error reason =>
          simp [prepareInvocation, hl, ha, ht, hc, bind, Except.bind, Except.mapError] at h
        | ok token =>
          cases token
          simp only [prepareInvocation, hl, ha, ht, hc, bind, Except.bind, Except.mapError,
            pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          exact ⟨component, template, rfl, ht, hc⟩

theorem extractReceipt_total (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre post : World P A D)
    (h : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) :
    ∃ e, extractReceipt cfg boundary request pre = .ok e ∧
      applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post := by
  obtain ⟨t, ht, args, ha, e, he, happly⟩ := execute_evaluated _ _ _ _ _ _ _ _ h
  exact ⟨e, by simp [extractReceipt, ht, ha, he, Except.mapError, bind, Except.bind], happly⟩

theorem extractReceipt_correspondence (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre post : World P A D) (e : Evaluated P A D)
    (h : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) (he : extractReceipt cfg boundary request pre = .ok e) :
    applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post := by
  obtain ⟨e', he', happly⟩ := extractReceipt_total cfg boundary request pre post h
  rw [he] at he'
  cases he'
  exact happly

inductive StepSound (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) : Step P A D → World P A D → StepResult P A D → Prop
  | invoke (inv : Invocation P A D) (pre post : World P A D)
      (iface : OperationInterface P A D) (request : Request P A D) (e : Evaluated P A D)
      (prepared : prepareInvocation cfg boundary index history inv = .ok (iface, request))
      (executed : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
        request pre.state = .ok post)
      (extracted : extractReceipt cfg boundary request pre = .ok e)
      (applied : applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post) :
      StepSound cfg boundary index history (.invoke inv) pre
        ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩
  | issue (grant : Grant P A D) (pre : World P A D) (id : CapabilityId)
      (store : CapabilityStore P A D)
      (issued : issueCapability cfg.authority boundary.ctx pre.capabilities grant =
        .ok (id, store)) :
      StepSound cfg boundary index history (.issue grant) pre ⟨⟨pre.state, store⟩, .issued id, []⟩
  | revoke (id : CapabilityId) (pre : World P A D) (store : CapabilityStore P A D)
      (revoked : revokeCapability cfg.authority boundary.ctx pre.capabilities id = .ok store) :
      StepSound cfg boundary index history (.revoke id) pre ⟨⟨pre.state, store⟩, .revoked id, []⟩

theorem executeStep_sound (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D)
    (result : StepResult P A D) (h : executeStep cfg boundary index history step pre = .ok result) :
    StepSound cfg boundary index history step pre result := by
  cases hv : validateCatalog cfg.registry cfg.catalog with
  | false => cases step <;> simp [executeStep, hv, throw, throwThe, bind, Except.bind] at h
  | true =>
    cases step with
    | invoke inv =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hp : prepareInvocation cfg boundary index history inv with
      | error err => simp [hp] at h
      | ok pair =>
        rcases pair with ⟨iface, request⟩
        simp only [hp] at h
        cases hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env
            boundary.now
            request pre.state with
        | error err => simp [hx, Except.mapError] at h
        | ok post =>
          simp only [hx, Except.mapError] at h
          cases he : extractReceipt cfg boundary request pre with
          | error err => simp [he] at h
          | ok e =>
            simp only [he, Except.ok.injEq] at h
            subst result
            exact .invoke inv pre post iface request e hp hx he
              (extractReceipt_correspondence cfg boundary request pre post e hx he)
    | issue grant =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hi : issueCapability cfg.authority boundary.ctx pre.capabilities grant with
      | error err => simp [hi, Except.mapError] at h
      | ok pair =>
        rcases pair with ⟨id, store⟩
        simp only [hi, Except.mapError, Except.ok.injEq] at h
        subst result
        exact .issue grant pre id store hi
    | revoke id =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hr : revokeCapability cfg.authority boundary.ctx pre.capabilities id with
      | error err => simp [hr, Except.mapError] at h
      | ok store =>
        simp only [hr, Except.mapError, Except.ok.injEq] at h
        subst result
        exact .revoke id pre store hr

theorem StepSound.accounting {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result)
    (d : D) (a : A) :
    total result.world.state d a = total pre.state d a + result.receipt.supply d a := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact applyEvaluated_accounting _ _ _ _ _ _ ha d a
  | issue => simp [Receipt.supply]
  | revoke => simp [Receipt.supply]

theorem StepSound.locality {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result)
    (c : Cell P A D) (hc : c ∉ result.receipt.writes) :
    result.world.state.balance c = pre.state.balance c := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact applyEvaluated_locality _ _ _ _ _ _ ha c hc
  | issue => rfl
  | revoke => rfl

/-- Every declared receipt write is allowed by the selected component interface. -/
theorem StepSound.component_writes {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ ∀ cell ∈ result.receipt.writes, component.canWrite cell = true := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨component, template, hl, ht, hc⟩ := prepareInvocation_access _ _ _ _ _ _ _ hp
    obtain ⟨selected, hs, args, hargs, actual, evaluated, applied⟩ :=
      execute_evaluated _ _ _ _ _ _ _ _ hx
    rw [ht] at hs
    cases hs
    have extracted : extractReceipt cfg boundary request pre = .ok actual := by
      simp [extractReceipt, ht, hargs, evaluated, bind, Except.bind, Except.mapError]
    rw [he] at extracted
    cases extracted
    have writes := evaluated_writes _ _ _ evaluated
    have allowed := checkAccess_declaredWrites component template boundary.ctx
      request.parties e.writes hc writes
    exact ⟨component, iface, hl, by simpa [Receipt.writes] using List.all_eq_true.mp allowed⟩

theorem StepSound.component_locality {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ ∀ cell, component.canWrite cell = false →
        result.world.state.balance cell = pre.state.balance cell := by
  obtain ⟨component, iface, selected, writes⟩ := h.component_writes
  refine ⟨component, iface, selected, ?_⟩
  intro cell denied
  apply h.locality cell
  intro member
  have allowed := writes cell member
  rw [denied] at allowed
  contradiction

theorem StepSound.invoke_preserves_capabilities {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {inv : Invocation P A D} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    result.world.capabilities = pre.capabilities := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact execute_preserves_capabilities _ _ _ _ _ _ _ _ hx

theorem StepSound.issue_preserves_ledger {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {grant : Grant P A D} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.issue grant) pre result) :
    result.world.state = pre.state := by cases h; rfl

theorem StepSound.revoke_preserves_ledger {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {id : CapabilityId} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.revoke id) pre result) :
    result.world.state = pre.state := by cases h; rfl

def ReceiptAuthorized (pre : World P A D) (boundary : Boundary P A D)
    (receipt : Receipt P A D) : Prop :=
  match receipt with
  | .invoked request e =>
    hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation .invoke = true ∧
    (∀ c, e.effect c < 0 → hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation (.debit c) = true) ∧
    (∀ d a, e.supply d a ≠ 0 → hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation (.changeSupply d a) = true)
  | _ => True

theorem StepSound.issue_admin {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {grant : Grant P A D} {pre : World P A D}
    {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.issue grant) pre result) :
    boundary.ctx.domain = grant.domain ∧
      boundary.ctx.principal = cfg.domainAdmin grant.domain := by
  cases h with
  | issue grant pre id store hi => exact issueCapability_admin _ _ _ _ _ _ hi

theorem StepSound.revoke_admin {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {id : CapabilityId} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history (.revoke id) pre result) :
    ∃ cap, pre.capabilities.lookup id = some cap ∧ boundary.ctx.domain = cap.domain ∧
      boundary.ctx.principal = cfg.domainAdmin cap.domain := by
  cases h with
  | revoke id pre store hr => exact revokeCapability_admin _ _ _ _ _ hr

theorem StepSound.authorized {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result) :
    ReceiptAuthorized pre boundary result.receipt := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨_, _, _, _, _, _, _, hi, _⟩ := (execute_ok_iff ..).mp hx
    obtain ⟨hv, _, _⟩ := (applyEvaluated_ok_iff ..).mp ha
    exact ⟨hi, of_decide_eq_true hv.2.2.2.2.1, of_decide_eq_true hv.2.2.2.2.2.1⟩
  | issue => trivial
  | revoke => trivial

theorem StepSound.domain {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {inv : Invocation P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history (.invoke inv) pre result)
    (c : Cell P A D) (hc : result.world.state.balance c ≠ pre.state.balance c) :
    c.1 = boundary.ctx.domain := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨_, _, _, _, _, _, _, _, _, hdom⟩ := execute_reads_and_domain _ _ _ _ _ _ _ _ hx
    exact hdom c hc

theorem executeStep_configuration (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D)
    (h : validateCatalog cfg.registry cfg.catalog = false) :
    executeStep cfg boundary index history step pre = .error .configuration := by
  cases step <;> simp [executeStep, h, throw, throwThe, bind, Except.bind] <;> rfl

theorem executeStep_delegated_refusal (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre : World P A D) (iface : OperationInterface P A D) (request : Request P A D)
    (reason : Typed.Refusal) (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hp : prepareInvocation cfg boundary index history inv = .ok (iface, request))
    (hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .error reason) :
    executeStep cfg boundary index history (.invoke inv) pre = .error (.kernel reason) := by
  simp [executeStep, hv, hp, hx, Except.mapError, bind, Except.bind]

theorem executeStep_delegated_success (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre post : World P A D) (iface : OperationInterface P A D) (request : Request P A D)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hp : prepareInvocation cfg boundary index history inv = .ok (iface, request))
    (hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) :
    ∃ e, extractReceipt cfg boundary request pre = .ok e ∧
      executeStep cfg boundary index history (.invoke inv) pre =
        .ok ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩ := by
  obtain ⟨e, he, _⟩ := extractReceipt_total cfg boundary request pre post hx
  exact ⟨e, he, by
    simp [executeStep, hv, hp, hx, he, Except.mapError, bind, Except.bind, pure, Except.pure]⟩

end DefiKernel.Composition


## FILE lean/DefiKernel/Composition/ExecutionTests.lean sha256=68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5

import DefiKernel.Composition.Execution
import DefiKernel.Typed.Examples

namespace DefiKernel.Composition.ExecutionTests
open Typed Typed.Examples

def iface : OperationInterface Party Asset Domain :=
  ⟨transferId, [⟨⟨0⟩, .amount .usd⟩], [⟨⟨1⟩, (.main, .alice, .usd)⟩]⟩

def component : Component Party Asset Domain :=
  ⟨⟨0⟩, [(.main, .alice, .usd), (.main, .bob, .usd)], [], [], [iface]⟩

def cfg : Config Party Asset Domain := ⟨registry, domainAdmin, [component]⟩
def boundary : Boundary Party Asset Domain := ⟨aliceContext, fresh, 100⟩
def adminBoundary : Boundary Party Asset Domain := ⟨adminContext, fresh, 100⟩
def invocation : Invocation Party Asset Domain :=
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd, 3⟩], allCapabilityIds, none⟩

def run (step : Step Party Asset Domain) (b := boundary) (config := cfg) :
    Except Failure (StepResult Party Asset Domain) := do
  let store ← provisioned.mapError Failure.authority
  executeStep config b 0 [] step ⟨initial, store⟩

def refuses (result : Except Failure (StepResult Party Asset Domain)) (reason : Failure) : Bool :=
  match result with
  | .error err => err == reason
  | .ok _ => false

def checks : List (String × Bool) := [
  ("execution.catalog", validateCatalog registry cfg.catalog),
  ("execution.transfer.receipt.snapshots", match run (.invoke invocation) with
    | .error _ => false
    | .ok r => decide (r.world.state.balance (.main, .alice, .usd) = 7 ∧
        r.world.state.balance (.main, .bob, .usd) = 3) &&
      (match r.receipt with
        | .invoked request e => request.operation == transferId &&
          decide (e.effect (.main, .alice, .usd) = -3 ∧ e.supply .main .usd = 0) &&
          decide (e.writes = [(.main, .alice, .usd), (.main, .bob, .usd)])
        | _ => false) &&
      (match r.outputs with
        | [obs] => obs.step == 0 && obs.port == ⟨⟨0⟩, ⟨1⟩⟩ &&
          (match obs.value with
            | ⟨.amount a, q⟩ => a == .usd && decide (q = 7)
            | _ => false)
        | _ => false)),
  ("execution.actor.precedes.authority", refuses
    (run (.invoke { invocation with claimedActor := some .bob, capabilityIds := [] }))
    (.kernel .actorMismatch)),
  ("execution.kernel.authority", refuses
    (run (.invoke { invocation with capabilityIds := [] })) (.kernel .unauthorizedInvoke)),
  ("execution.membership", refuses
    (run (.invoke { invocation with component := ⟨99⟩ })) (.interface .unknownOperation)),
  ("execution.binding.unit", refuses
    (run (.invoke { invocation with inputs := [.literal ⟨.amount .share, 3⟩] }))
    (.interface .inputUnit)),
  ("execution.configuration", refuses
    (run (.invoke invocation) boundary { cfg with catalog := [component, component] })
    .configuration),
  ("execution.issue.ledger.receipt",
    match run (.issue (grant transferId .invoke)) adminBoundary with
    | .error _ => false
    | .ok r => decide ((∀ c, r.world.state.balance c = initial.balance c) ∧ r.outputs = []) &&
      (match r.receipt with | .issued id => id == ⟨12⟩ | _ => false) &&
      decide (r.world.capabilities.nextId = ⟨13⟩)),
  ("execution.issue.unauthorized", refuses
    (run (.issue (grant transferId .invoke))) (.authority .unauthorizedAdmin)),
  ("execution.revoke.ledger.receipt", match run (.revoke ⟨0⟩) adminBoundary with
    | .error _ => false
    | .ok r => decide ((∀ c, r.world.state.balance c = initial.balance c) ∧ r.outputs = []) &&
      (match r.receipt with | .revoked id => id == ⟨0⟩ | _ => false) &&
      !authorizesId r.world.capabilities aliceContext transferId .invoke ⟨0⟩),
  ("execution.revoke.unknown", refuses (run (.revoke ⟨99⟩) adminBoundary)
    (.authority .unknownCapability))]

-- BEGIN PROOFS

#eval show IO _root_.Unit from do
  if checks.isEmpty then throw (IO.userError "Execution comparisons empty")
  for (label, ok) in checks do IO.println s!"{label}: {ok}"
  let failures := checks.filter (fun entry ↦ !entry.2)
  if !failures.isEmpty then
    throw (IO.userError s!"Execution comparisons failed: {failures.length}")

end DefiKernel.Composition.ExecutionTests


## FILE lean/DefiKernel/Composition/InterfaceTests.lean sha256=710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3

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
  ("interface.unique-export-provider", !validateCatalog registry
    [{ owner with exports := [⟨⟨10⟩, vaultUSD, true⟩] },
     { exporter with exports := [⟨⟨10⟩, vaultUSD, false⟩] }]),
  ("interface.missing-import-source", !validateCatalog registry
    [{ shared with imports := [⟨⟨⟨99⟩, ⟨10⟩⟩, vaultUSD, true⟩] }, exporter]),
  ("interface.wrong-import-port", !validateCatalog registry
    [{ shared with imports := [⟨⟨⟨1⟩, ⟨99⟩⟩, vaultUSD, true⟩] }, exporter]),
  ("interface.self-import", !validateCatalog registry
    [owner, { exporter with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, vaultUSD, true⟩] }]),
  ("interface.self-readonly-import-writable-export", !validateCatalog registry
    [owner, { exporter with imports := [⟨⟨⟨1⟩, ⟨10⟩⟩, vaultUSD, false⟩] }]),
  ("interface.readonly-export-selfwrite",
    !({ exporter with exports := [⟨⟨10⟩, vaultUSD, false⟩] } : C).canWrite vaultUSD),
  ("interface.writable-export-selfwrite", exporter.canWrite vaultUSD),
  ("interface.crossdomain-output", !validateCatalog registry
    [{ owner with
      privateCells := owner.privateCells ++ [(.other, .alice, .usd)]
      operations := [{ iface with outputs := [⟨⟨1⟩, (.other, .alice, .usd)⟩] }] }]),
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


## FILE lean/DefiKernel/Composition/Interfaces.lean sha256=4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe

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
  decide ((catalog.flatMap (fun c ↦ c.exports.map ResourcePort.cell)).Nodup) &&
  catalog.all (fun c ↦
    decide (c.portIds.Nodup) && decide ((c.imports.map ResourceImport.source).Nodup) &&
    c.exports.all (fun p ↦
      !(catalog.any (fun owner ↦ decide (p.cell ∈ owner.privateCells)))) &&
    c.imports.all (fun p ↦
      !(c.exports.any (fun e ↦ decide (e.cell = p.cell))) &&
      !(catalog.any (fun owner ↦ decide (p.cell ∈ owner.privateCells))) &&
      catalog.any (fun source ↦ decide (source.id = p.source.component) &&
        source.exports.any (fun e ↦ decide (e.id = p.source.port) &&
          decide (e.cell = p.cell) && (!p.writable || e.writable)))) &&
    c.operations.all (fun i ↦
      (match registry i.operation with
       | none => false
       | some template => decide (i.inputs.map InputPort.unit = template.signature) &&
         i.outputs.all (fun o ↦ decide (o.cell.1 = template.domain))) &&
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

/-- Successful prechecks resolve the complete conservative reference inventories and
accept every concrete read and write; no financial expression evaluation is assumed. -/
theorem checkAccess_ok_iff (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) :
    checkAccess component template ctx parties = .ok PUnit.unit ↔
      ∃ reads writes,
        resolveRefs ctx.principal parties
          (template.requiredStateReads ++ template.stateReads) = .ok reads ∧
        resolveRefs ctx.principal parties
          (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) = .ok writes ∧
        reads.all component.canRead = true ∧ writes.all component.canWrite = true := by
  unfold checkAccess
  cases hr : resolveRefs ctx.principal parties
    (template.requiredStateReads ++ template.stateReads) with
  | error e => simp [Except.mapError, bind, Except.bind]
  | ok reads =>
    cases hw : resolveRefs ctx.principal parties
      (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) with
    | error e => simp [Except.mapError, bind, Except.bind]
    | ok writes =>
      simp only [Except.mapError, bind, Except.bind]
      by_cases r : reads.all component.canRead = true <;>
        by_cases w : writes.all component.canWrite = true <;>
        simp [r, w, -List.all_eq_true, throw, throwThe, pure, Except.pure]


/-- In particular every resolved declared write accepted by the precheck is writable. -/
theorem checkAccess_declaredWrites (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) (writes : List (Cell Party Asset Domain))
    (accepted : checkAccess component template ctx parties = .ok PUnit.unit)
    (resolved : resolveRefs ctx.principal parties template.writes = .ok writes) :
    writes.all component.canWrite = true := by
  obtain ⟨reads, allWrites, _, hw, _, allowed⟩ :=
    (checkAccess_ok_iff component template ctx parties).mp accepted
  simp only [resolveRefs, List.mapM_append] at hw
  change (template.writes.mapM (fun ref ↦ ref.2.resolve ctx.principal parties)) =
    .ok writes at resolved
  rw [resolved] at hw
  cases ht : (template.deltas.map
      (fun d ↦ (⟨d.asset, d.target⟩ : PackedCellRef Party Asset Domain))).mapM
      (fun ref ↦ ref.2.resolve ctx.principal parties) with
  | error e => simp [ht, bind, Except.bind] at hw
  | ok targets =>
    simp only [ht, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
    subst allWrites
    simp only [List.all_append, Bool.and_eq_true] at allowed
    exact allowed.1

/-- A validated catalog keeps every export away from every private owner. -/
theorem validateCatalog_export_not_private (registry : Registry Party Asset Domain)
    (catalog : Catalog Party Asset Domain) (valid : validateCatalog registry catalog = true)
    (component owner : Component Party Asset Domain) (hc : component ∈ catalog)
    (ho : owner ∈ catalog) (port : ResourcePort Party Asset Domain)
    (hp : port ∈ component.exports) : port.cell ∉ owner.privateCells := by
  simp only [validateCatalog, Bool.and_eq_true] at valid
  have componentValid := List.all_eq_true.mp valid.2 component hc
  simp only [Bool.and_eq_true] at componentValid
  have exportValid := List.all_eq_true.mp componentValid.1.1.2 port hp
  simpa using (show ¬port.cell ∈ owner.privateCells from by
    intro h
    have : catalog.any (fun c ↦ decide (port.cell ∈ c.privateCells)) = true :=
      List.any_eq_true.mpr ⟨owner, ho, by simpa using h⟩
    simp [this] at exportValid)

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


## FILE lean/DefiKernel/Composition/Preservation.lean sha256=7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709

import DefiKernel.Composition.Sequence

/-! Induction over actual successful prefixes. Supply is taken from evaluated receipts;
framing requires explicit ledger support, and invariant reasoning requires local premises. -/
namespace DefiKernel.Composition
open Typed

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def traceSupply (events : List (Event P A D)) (domain : D) (asset : A) : ℚ :=
  (events.map (fun event ↦ event.result.receipt.supply domain asset)).sum

def traceWrites (events : List (Event P A D)) : List (Cell P A D) :=
  events.flatMap (fun event ↦ event.result.receipt.writes)

-- BEGIN PROOFS

theorem TraceSound.accounting {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) (d : D) (a : A) :
    total final.state d a = total initial.state d a + traceSupply events d a := by
  induction h with
  | nil => simp [traceSupply]
  | snoc previous step result accepted ih =>
    rw [accepted.accounting, ih]
    simp [traceSupply, List.map_append, List.sum_append, add_assoc]

theorem TraceSound.locality {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (cell : Cell P A D) (untouched : cell ∉ traceWrites events) :
    final.state.balance cell = initial.state.balance cell := by
  induction h with
  | nil => rfl
  | snoc previous step result accepted ih =>
    simp only [traceWrites, List.flatMap_append, List.flatMap_singleton, List.mem_append,
      not_or] at untouched
    exact (accepted.locality cell untouched.2).trans (ih untouched.1)

theorem TraceSound.steps {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events, ∃ priorOutputs,
      StepSound cfg (boundaries event.index) event.index priorOutputs
        event.step event.before event.result := by
  induction h with
  | nil => simp
  | snoc previous step result accepted ih =>
    intro event member
    simp only [List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact ih event member
    · exact ⟨_, accepted⟩

theorem TraceSound.authority {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events,
      ReceiptAuthorized event.before (boundaries event.index) event.result.receipt := by
  intro event member
  obtain ⟨prior, accepted⟩ := h.steps event member
  exact accepted.authorized

theorem TraceSound.component_locality {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events, ∀ inv, event.step = .invoke inv →
      ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
        some (component, iface) ∧ ∀ cell, component.canWrite cell = false →
          event.result.world.state.balance cell = event.before.state.balance cell := by
  intro event member inv he
  obtain ⟨prior, accepted⟩ := h.steps event member
  rw [he] at accepted
  exact accepted.component_locality

/-- Administrative authorization is separate from invocation receipt rights. -/
theorem TraceSound.administration {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events, match event.step with
    | .invoke _ => True
    | .issue grant => (boundaries event.index).ctx.domain = grant.domain ∧
        (boundaries event.index).ctx.principal = cfg.domainAdmin grant.domain
    | .revoke id => ∃ cap, event.before.capabilities.lookup id = some cap ∧
        (boundaries event.index).ctx.domain = cap.domain ∧
        (boundaries event.index).ctx.principal = cfg.domainAdmin cap.domain := by
  intro event member
  obtain ⟨prior, accepted⟩ := h.steps event member
  cases he : event.step with
  | invoke inv => trivial
  | issue grant =>
    rw [he] at accepted
    exact accepted.issue_admin
  | revoke id =>
    rw [he] at accepted
    exact accepted.revoke_admin

theorem TraceSound.invariant {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (invariant : World P A D → Prop) (initialized : invariant initial)
    (preserves : ∀ n outputs step pre result,
      StepSound cfg (boundaries n) n outputs step pre result →
      invariant pre → invariant result.world) :
    invariant final := by
  induction h with
  | nil => exact initialized
  | snoc previous step result accepted ih => exact preserves _ _ _ _ _ accepted ih

theorem TraceSound.event_invariants {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (invariant : World P A D → Prop) (initialized : invariant initial)
    (preserves : ∀ n outputs step pre result,
      StepSound cfg (boundaries n) n outputs step pre result →
      invariant pre → invariant result.world) :
    ∀ event ∈ events, invariant event.before ∧ invariant event.result.world := by
  induction h with
  | nil => simp
  | snoc previous step result accepted ih =>
    intro event member
    simp only [List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact ih event member
    · have hp := previous.invariant invariant initialized preserves
      exact ⟨hp, preserves _ _ _ _ _ accepted hp⟩

theorem TraceSound.frame {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (region : Set (Cell P A D)) (untouched : ∀ cell ∈ region, cell ∉ traceWrites events) :
    AgreeOn region initial.state final.state := by
  intro cell member
  exact (h.locality cell (untouched cell member)).symm

theorem TraceSound.predicate_frame {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate) (untouched : ∀ cell ∈ region, cell ∉ traceWrites events) :
    predicate initial.state ↔ predicate final.state :=
  supported_frame support (h.frame region untouched)

theorem run_accounting (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) (d : D) (a : A) :
    total (run cfg boundaries initial steps).world.state d a =
      total initial.state d a + traceSupply (run cfg boundaries initial steps).events d a :=
  (run_trace_sound cfg boundaries initial steps).accounting d a

theorem run_nonnegative (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) (cell : Cell P A D) :
    0 ≤ (run cfg boundaries initial steps).world.state.balance cell :=
  (run cfg boundaries initial steps).world.state.nonneg cell

theorem run_prefix_nonnegative (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    ∀ event ∈ (run cfg boundaries initial steps).events, ∀ cell,
      0 ≤ event.before.state.balance cell ∧ 0 ≤ event.result.world.state.balance cell := by
  intro event member cell
  exact ⟨event.before.state.nonneg cell, event.result.world.state.nonneg cell⟩

theorem run_frame (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D))
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ cell ∈ region, cell ∉ traceWrites (run cfg boundaries initial steps).events) :
    predicate initial.state ↔ predicate (run cfg boundaries initial steps).world.state :=
  (run_trace_sound cfg boundaries initial steps).predicate_frame region predicate support untouched

theorem run_contract (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D))
    (contract : ComponentContract P A D (Boundary P A D))
    (obligations : ContractObligations contract) (initialized : contract.initial initial)
    (localGuarantee : ∀ n outputs step pre result,
      StepSound cfg (boundaries n) n outputs step pre result →
      contract.invariant pre → contract.assumes (boundaries n) pre ∧
        contract.guarantees (boundaries n) pre result.world) :
    contract.invariant (run cfg boundaries initial steps).world := by
  apply (run_trace_sound cfg boundaries initial steps).invariant contract.invariant
    (obligations.initialized initial initialized)
  intro n outputs step pre result accepted inv
  obtain ⟨assumes, guarantees⟩ := localGuarantee n outputs step pre result accepted inv
  exact obligations.preserved (boundaries n) pre result.world inv assumes guarantees

end DefiKernel.Composition


## FILE lean/DefiKernel/Composition/Sequence.lean sha256=32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729

import DefiKernel.Composition.Execution

/-! Finite ordered execution. A refusal commits no new event, preserves the successful prefix,
and makes every continuation inert. Trusted boundary positions are absolute. -/
namespace DefiKernel.Composition
open Typed

structure Event (Party Asset Domain : Type) where
  index : Nat
  step : Step Party Asset Domain
  before : World Party Asset Domain
  result : StepResult Party Asset Domain

structure LocatedFailure (Party Asset Domain : Type) where
  index : Nat
  step : Option (Step Party Asset Domain)
  reason : Failure

structure Cursor (Party Asset Domain : Type) where
  world : World Party Asset Domain
  events : List (Event Party Asset Domain)
  outputs : List (OutputObservation Asset)
  nextIndex : Nat
  failure : Option (LocatedFailure Party Asset Domain)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def startCursor (cfg : Config P A D) (world : World P A D) : Cursor P A D :=
  ⟨world, [], [], 0, if validateCatalog cfg.registry cfg.catalog then none
    else some ⟨0, none, .configuration⟩⟩

def advance (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (step : Step P A D) : Cursor P A D :=
  match cursor.failure with
  | some _ => cursor
  | none =>
    match executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | .error reason => { cursor with failure := some ⟨cursor.nextIndex, some step, reason⟩ }
    | .ok result =>
      ⟨result.world, cursor.events ++ [⟨cursor.nextIndex, step, cursor.world, result⟩],
        cursor.outputs ++ result.outputs, cursor.nextIndex + 1, none⟩

def continueRun (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) : Cursor P A D :=
  steps.foldl (advance cfg boundaries) cursor

def run (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (world : World P A D) (steps : List (Step P A D)) : Cursor P A D :=
  continueRun cfg boundaries (startCursor cfg world) steps

-- BEGIN PROOFS

/-- The trace relates actual step evidence at each preceding world and output history. -/
inductive TraceSound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) :
    List (Event P A D) → World P A D → List (OutputObservation A) → Nat → Prop
  | nil : TraceSound cfg boundaries initial [] initial [] 0
  | snoc {events : List (Event P A D)} {pre : World P A D}
      {history : List (OutputObservation A)} {index : Nat}
      (previous : TraceSound cfg boundaries initial events pre history index)
      (step : Step P A D) (result : StepResult P A D)
      (accepted : StepSound cfg (boundaries index) index history step pre result) :
      TraceSound cfg boundaries initial (events ++ [⟨index, step, pre, result⟩])
        result.world (history ++ result.outputs) (index + 1)

def RefusalSound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : Prop :=
  ∀ failure, cursor.failure = some failure → failure.index = cursor.nextIndex ∧
    match failure.step with
    | none => failure.reason = .configuration ∧ validateCatalog cfg.registry cfg.catalog = false
    | some step => executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex
        cursor.outputs step cursor.world = .error failure.reason

theorem continueRun_nil (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : continueRun cfg boundaries cursor [] = cursor := rfl

theorem continueRun_append (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (firstSteps suffix : List (Step P A D)) :
    continueRun cfg boundaries cursor (firstSteps ++ suffix) =
      continueRun cfg boundaries (continueRun cfg boundaries cursor firstSteps) suffix := by
  exact List.foldl_append

theorem continueRun_failed (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (failure : LocatedFailure P A D)
    (failed : cursor.failure = some failure) (steps : List (Step P A D)) :
    continueRun cfg boundaries cursor steps = cursor := by
  induction steps with
  | nil => rfl
  | cons step steps ih =>
    simpa [continueRun, List.foldl_cons, advance, failed] using ih

/-- Recorded invocations/admin steps are an ordered prefix of the submitted list. -/
theorem continueRun_order (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) :
    ∃ accepted remaining, steps = accepted ++ remaining ∧
      (continueRun cfg boundaries cursor steps).events.map Event.step =
        cursor.events.map Event.step ++ accepted := by
  induction steps generalizing cursor with
  | nil => exact ⟨[], [], rfl, by simp [continueRun]⟩
  | cons step steps ih =>
    cases hf : cursor.failure with
    | some failure =>
      exact ⟨[], step :: steps, rfl, by rw [continueRun_failed _ _ _ _ hf]; simp⟩
    | none =>
      cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
          step cursor.world with
      | error reason =>
        have ha : (advance cfg boundaries cursor step).failure =
            some ⟨cursor.nextIndex, some step, reason⟩ := by simp [advance, hf, he]
        refine ⟨[], step :: steps, rfl, ?_⟩
        change (continueRun cfg boundaries (advance cfg boundaries cursor step) steps).events.map
          Event.step = cursor.events.map Event.step ++ []
        rw [continueRun_failed _ _ _ _ ha]
        simp [advance, hf, he]
      | ok result =>
        obtain ⟨accepted, remaining, hs, hout⟩ := ih (advance cfg boundaries cursor step)
        refine ⟨step :: accepted, remaining, by simp [hs], ?_⟩
        change (continueRun cfg boundaries (advance cfg boundaries cursor step) steps).events.map
          Event.step = cursor.events.map Event.step ++ step :: accepted
        rw [hout]
        simp [advance, hf, he, List.map_append, List.append_assoc]

theorem run_order (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    ∃ accepted remaining, steps = accepted ++ remaining ∧
      (run cfg boundaries initial steps).events.map Event.step = accepted := by
  simpa [run, startCursor] using continueRun_order cfg boundaries (startCursor cfg initial) steps

theorem advance_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (cursor : Cursor P A D) (step : Step P A D)
    (h : TraceSound cfg boundaries initial cursor.events cursor.world
      cursor.outputs cursor.nextIndex) :
    TraceSound cfg boundaries initial (advance cfg boundaries cursor step).events
      (advance cfg boundaries cursor step).world (advance cfg boundaries cursor step).outputs
      (advance cfg boundaries cursor step).nextIndex := by
  cases hf : cursor.failure with
  | some failure => simpa [advance, hf] using h
  | none =>
    cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | error reason => simpa [advance, hf, he] using h
    | ok result =>
      simpa [advance, hf, he] using h.snoc step result (executeStep_sound _ _ _ _ _ _ _ he)

theorem continueRun_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (cursor : Cursor P A D) (steps : List (Step P A D))
    (h : TraceSound cfg boundaries initial cursor.events cursor.world
      cursor.outputs cursor.nextIndex) :
    TraceSound cfg boundaries initial (continueRun cfg boundaries cursor steps).events
      (continueRun cfg boundaries cursor steps).world
      (continueRun cfg boundaries cursor steps).outputs
      (continueRun cfg boundaries cursor steps).nextIndex := by
  induction steps generalizing cursor with
  | nil => exact h
  | cons step steps ih =>
    exact ih (advance cfg boundaries cursor step)
      (advance_trace_sound cfg boundaries initial cursor step h)

theorem run_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    TraceSound cfg boundaries initial (run cfg boundaries initial steps).events
      (run cfg boundaries initial steps).world (run cfg boundaries initial steps).outputs
      (run cfg boundaries initial steps).nextIndex := by
  apply continueRun_trace_sound
  exact .nil

theorem advance_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (step : Step P A D) (h : RefusalSound cfg boundaries cursor) :
    RefusalSound cfg boundaries (advance cfg boundaries cursor step) := by
  cases hf : cursor.failure with
  | some failure => simpa [advance, hf] using h
  | none =>
    cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | error reason =>
      intro failure hh
      simp only [advance, hf, he, Option.some.injEq] at hh
      subst failure
      simp [advance, hf, he]
    | ok result =>
      intro failure hh
      simp [advance, hf, he] at hh

theorem continueRun_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) (h : RefusalSound cfg boundaries cursor) :
    RefusalSound cfg boundaries (continueRun cfg boundaries cursor steps) := by
  induction steps generalizing cursor with
  | nil => exact h
  | cons step steps ih =>
    exact ih (advance cfg boundaries cursor step)
      (advance_refusal_sound cfg boundaries cursor step h)

theorem run_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    RefusalSound cfg boundaries (run cfg boundaries initial steps) := by
  apply continueRun_refusal_sound
  intro failure h
  simp only [startCursor] at h ⊢
  split at h
  · contradiction
  · simp only [Option.some.injEq] at h
    subst failure
    rename_i hv
    exact ⟨rfl, rfl, by simpa using hv⟩

end DefiKernel.Composition


## FILE lean/DefiKernel/Composition/Tests.lean sha256=4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980

import DefiKernel.Composition.Examples
namespace DefiKernel.Composition.Tests
open Typed Typed.Examples Examples

/-- Independent complete 32-cell oracle in allCells order. -/
def balances (alice bob vault shares : ℚ) : List ℚ :=
  [alice, shares, 10, 2, bob, 0, 0, 0, vault, 0, 0, 0, 100, 0, 0, 0] ++
    List.replicate 16 0

def worldEq (world : W) (values : List ℚ) (store : Store := expectedStore) : Bool :=
  decide (allCells.map world.state.balance = values ∧ world.capabilities = store)
def listEq {α} (eq : α → α → Bool) (xs ys : List α) : Bool :=
  xs.length == ys.length && (xs.zip ys).all (fun (a,b) ↦ eq a b)
def sourceEq : InputSource Asset → InputSource Asset → Bool
  | .literal a, .literal b => decide (a = b)
  | .priorOutput i p, .priorOutput j q => i == j && p == q
  | _, _ => false
def stepEq : S → S → Bool
  | .invoke a, .invoke b => a.component == b.component && a.operation == b.operation &&
      decide (a.parties = b.parties ∧ a.capabilityIds = b.capabilityIds ∧
        a.claimedActor = b.claimedActor) && listEq sourceEq a.inputs b.inputs
  | .issue a, .issue b => a == b
  | .revoke a, .revoke b => a == b
  | _, _ => false
def outputEq (a b : OutputObservation Asset) : Bool :=
  a.step == b.step && a.port == b.port && decide (a.value = b.value)
def obs (index component port : Nat) (asset : Asset) (q : ℚ) : OutputObservation Asset :=
  ⟨index, ⟨⟨component⟩, ⟨port⟩⟩, ⟨.amount asset, q⟩⟩

structure ExpectedEvent where
  step : S
  before : List ℚ
  after : List ℚ
  preStore : Store := expectedStore
  postStore : Store := expectedStore
  arguments : List (PackedValue Asset) := []
  deltas : List (C × ℚ) := []
  supplies : List ((Domain × Asset) × ℚ) := []
  writes : List C := []
  outputs : List (OutputObservation Asset) := []
  adminId : CapabilityId := ⟨0⟩
  envReads : List (EnvRead Domain) := []

def eventEq (index : Nat) (a : Event Party Asset Domain) (e : ExpectedEvent) : Bool :=
  a.index == index && stepEq a.step e.step && worldEq a.before e.before e.preStore &&
  worldEq a.result.world e.after e.postStore && listEq outputEq a.result.outputs e.outputs &&
  match a.result.receipt, e.step with
  | .invoked request value, .invoke inv =>
    request.operation == inv.operation && decide (request.parties = inv.parties ∧
      request.arguments = e.arguments ∧ request.capabilityIds = inv.capabilityIds ∧
      request.claimedActor = inv.claimedActor) &&
    decide (value.guard = true ∧ value.deltas = e.deltas ∧ value.supplies = e.supplies ∧
      value.writes = e.writes ∧ value.requiredStateReads = [] ∧
      value.requiredEnvReads = e.envReads ∧ value.declaredStateReads = [] ∧
      value.declaredEnvReads = e.envReads) &&
    (allCells.all fun c ↦ decide (value.effect c =
      ((e.deltas.filter (fun d ↦ d.1 == c)).map Prod.snd).sum)) &&
    ([Domain.main, .other].all fun d ↦ [Asset.usd, .share, .collateral, .debt].all fun a ↦
      decide (aSupply value d a = ((e.supplies.filter (fun s ↦ s.1 == (d,a))).map Prod.snd).sum))
  | .issued id, .issue _ => id == e.adminId
  | .revoked id, .revoke _ => id == e.adminId
  | _, _ => false
where aSupply := Evaluated.supply

def cursorEq (actual : Cursor Party Asset Domain) (events : List ExpectedEvent)
    (final : List ℚ) (failure : Option (S × Failure) := none)
    (store : Store := expectedStore) : Bool :=
  worldEq actual.world final store && actual.nextIndex == events.length &&
  actual.events.length == events.length &&
  (actual.events.zip events).zipIdx.all (fun ((a,e),i) ↦ eventEq i a e) &&
  listEq outputEq actual.outputs (events.flatMap ExpectedEvent.outputs) &&
  match actual.failure, failure with
  | none, none => true
  | some a, some (step, reason) => a.index == events.length && a.reason == reason &&
      (match a.step with | some s => stepEq s step | none => false)
  | _, _ => false

def tEvent (i : Nat) (q beforeAlice beforeBob afterAlice afterBob : ℚ)
    (shares : ℚ := 4) (vault : ℚ := 20) : ExpectedEvent :=
  ⟨transferStep q, balances beforeAlice beforeBob vault shares,
    balances afterAlice afterBob vault shares, expectedStore, expectedStore,
    [⟨.amount .usd,q⟩], [(aliceUsd,-q),(bobUsd,q)], [], [aliceUsd,bobUsd],
    [obs i 0 1 .usd afterAlice], ⟨0⟩, []⟩
def dEvent (i : Nat) (step : S) (q beforeAlice afterAlice bob beforeVault afterVault
    beforeShare afterShare : ℚ) : ExpectedEvent :=
  ⟨step, balances beforeAlice bob beforeVault beforeShare,
    balances afterAlice bob afterVault afterShare, expectedStore, expectedStore,
    [⟨.amount .usd,q⟩], [(aliceUsd,-q),(vaultUsd,q),(aliceShare,q/2)],
    [((.main,.share),q/2)], [aliceUsd,vaultUsd,aliceShare],
    [obs i 1 3 .share afterShare, obs i 1 4 .usd afterAlice], ⟨0⟩, []⟩
def wEvent : ExpectedEvent :=
  ⟨withdrawStep 2, balances 3 3 24 6, balances 7 3 20 4, expectedStore, expectedStore,
    [⟨.amount .share,2⟩], [(vaultUsd,-4),(aliceUsd,4),(aliceShare,-2)],
    [((.main,.share),-2)], [vaultUsd,aliceUsd,aliceShare], [obs 2 1 6 .usd 7], ⟨0⟩, []⟩
def execute (steps : List S) := Composition.run cfg boundary initialWorld steps

def t3 := tEvent 0 3 10 0 7 3
def d4 := dEvent 0 (depositStep 4) 4 10 6 0 20 24 4 6
def route7 := dEvent 1 (routedDeposit 0) 7 7 0 3 20 27 4 (15/2)

def adminGrant : Grant Party Asset Domain := grant transferId .invoke
def adminStore : Store := ⟨expectedStore.entries.drop 1⟩
/-- The issued ID is 11; the old invoke entry was removed only in the initial fixture. -/
def issuedStore : Store := ⟨adminStore.entries ++ [⟨adminGrant, true⟩]⟩
def revokedStore : Store := ⟨adminStore.entries ++ [⟨adminGrant, false⟩]⟩
def adminUse : S := .invoke
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd,3⟩], [⟨0⟩,⟨11⟩], none⟩
def adminBounds (i : Nat) : Boundary Party Asset Domain :=
  ⟨if i = 0 ∨ i = 2 then adminContext else aliceContext, fresh, 100+i⟩
def issueEvent : ExpectedEvent :=
  { step := .issue adminGrant, before := balances 10 0 20 4, after := balances 10 0 20 4,
    preStore := adminStore, postStore := issuedStore, adminId := ⟨11⟩ }
def useEvent : ExpectedEvent :=
  { (tEvent 1 3 10 0 7 3) with
    step := adminUse
    preStore := issuedStore
    postStore := issuedStore }
def revokeEvent : ExpectedEvent :=
  { step := .revoke ⟨11⟩, before := balances 7 3 20 4, after := balances 7 3 20 4,
    preStore := issuedStore, postStore := revokedStore, adminId := ⟨11⟩ }
def adminRun (steps : List S) := Composition.run cfg adminBounds ⟨initial,adminStore⟩ steps

def isolatedCatalog (shared writable : Bool) : Catalog Party Asset Domain := [
  ⟨⟨0⟩, [bobUsd], [⟨⟨10⟩, aliceUsd, true⟩], [], [transferInterface]⟩,
  ⟨⟨1⟩, [aliceShare], [], [⟨⟨⟨0⟩,⟨10⟩⟩,aliceUsd,true⟩] ++
    (if shared then [⟨⟨⟨2⟩,⟨20⟩⟩,vaultUsd,writable⟩] else []),
    [depositInterface,withdrawInterface]⟩,
  ⟨⟨2⟩, if shared then [collateral] else [collateral,vaultUsd],
    if shared then [⟨⟨20⟩,vaultUsd,true⟩] else [], [], []⟩]
def isolatedRun (shared writable : Bool) (steps : List S) :=
  Composition.run { cfg with catalog := isolatedCatalog shared writable }
    boundary initialWorld steps

def hiddenTransfer : Op := { transfer with
  guard := .ite (.lit true) transfer.guard
    (.binary (.le (.amount Asset.collateral)) (.lit 0) (.balance (ref .collateral .caller))) }
def hiddenCfg : Config Party Asset Domain := { cfg with
  registry := fun id ↦ if id = transferId then some hiddenTransfer else registry id }
def wrongComponent : S := .invoke
  ⟨⟨1⟩,transferId,[.bob],[.literal ⟨.amount .usd,3⟩],allCapabilityIds,none⟩
def actorMismatch : S := .invoke
  ⟨⟨0⟩,transferId,[.bob],[.literal ⟨.amount .usd,3⟩],allCapabilityIds,some .bob⟩
def sharedWithdrawEvent : ExpectedEvent :=
  ⟨withdrawStep 2,balances 10 0 20 4,balances 14 0 16 2,expectedStore,expectedStore,
    [⟨.amount .share,2⟩],[(vaultUsd,-4),(aliceUsd,4),(aliceShare,-2)],
    [((.main,.share),-2)],[vaultUsd,aliceUsd,aliceShare],[obs 0 1 6 .usd 14],⟨0⟩, []⟩

/-- Position zero is an administrator, later positions are Alice. -/
def resumeBounds (i : Nat) : Boundary Party Asset Domain :=
  ⟨if i = 0 then adminContext else aliceContext,fresh,100+i⟩
def resumeStore : Store := ⟨expectedStore.entries ++ [⟨adminGrant,true⟩]⟩
def resumeIssue : ExpectedEvent :=
  { issueEvent with preStore := expectedStore, postStore := resumeStore, adminId := ⟨12⟩ }
def resumeTransfer : ExpectedEvent :=
  { (tEvent 1 3 10 0 7 3) with preStore := resumeStore, postStore := resumeStore }
def resumeDeposit : ExpectedEvent :=
  { (dEvent 2 (routedDeposit 1) 7 7 0 3 20 27 4 (15/2)) with
    preStore := resumeStore
    postStore := resumeStore }
def resumePrefix := Composition.run cfg resumeBounds initialWorld [.issue adminGrant,transferStep 3]

def timedDeposit : Op := { deposit with
  guard := .binary .and deposit.guard (.binary (.le .scalar) (.lit 102) .now)
  envReads := [.currentTime] }
def timedCfg : Config Party Asset Domain := { cfg with
  registry := fun id ↦ if id = depositId then some timedDeposit else registry id }
def timedPrefix :=
  Composition.run timedCfg resumeBounds initialWorld [.issue adminGrant, transferStep 3]
def timedEvent : ExpectedEvent := { resumeDeposit with envReads := [.currentTime] }

def invalidRun := Composition.run { cfg with catalog := catalog ++ catalog }
  boundary initialWorld [transferStep 3]

def checks : List (String × Bool) := [
  ("workflows.isolation.catalogs", [isolatedCatalog false false,isolatedCatalog true false,
    isolatedCatalog true true].all (validateCatalog registry)),
  ("workflows.isolation.private", cursorEq (isolatedRun false false [withdrawStep 2]) []
    (balances 10 0 20 4) (some (withdrawStep 2,.interface .writeAccess)) &&
    hasAuthority expectedStore allCapabilityIds aliceContext withdrawId (.debit vaultUsd)),
  ("workflows.isolation.shared", cursorEq (isolatedRun true true [withdrawStep 2])
    [sharedWithdrawEvent] (balances 14 0 16 2)),
  ("workflows.isolation.readonly", cursorEq (isolatedRun true false [withdrawStep 2]) []
    (balances 10 0 20 4) (some (withdrawStep 2,.interface .writeAccess))),
  ("workflows.isolation.hidden.read", cursorEq
    (Composition.run hiddenCfg boundary initialWorld [transferStep 3]) []
    (balances 10 0 20 4) (some (transferStep 3,.interface .readAccess))),
  ("workflows.isolation.wrong.component", cursorEq (execute [wrongComponent]) []
    (balances 10 0 20 4) (some (wrongComponent,.interface .unknownOperation))),
  ("workflows.actor", cursorEq (execute [actorMismatch]) [] (balances 10 0 20 4)
    (some (actorMismatch,.kernel .actorMismatch))),
  ("workflows.configuration", let result := invalidRun
    worldEq result.world (balances 10 0 20 4) && result.events.isEmpty && result.outputs.isEmpty &&
    result.nextIndex == 0 && (match result.failure with
      | some f => f.index == 0 && f.step.isNone && f.reason == .configuration | none => false)),
  ("workflows.resume.time", cursorEq
    (continueRun timedCfg resumeBounds timedPrefix [routedDeposit 1])
    [resumeIssue,resumeTransfer,timedEvent] (balances 0 3 27 (15/2)) none resumeStore &&
    cursorEq (Composition.run timedCfg resumeBounds initialWorld
      [.issue adminGrant,transferStep 3,routedDeposit 1])
    [resumeIssue,resumeTransfer,timedEvent] (balances 0 3 27 (15/2)) none resumeStore),
  ("workflows.resume.time.negative", cursorEq
    (continueRun timedCfg boundary timedPrefix [routedDeposit 1])
    [resumeIssue,resumeTransfer] (balances 7 3 20 4)
    (some (routedDeposit 1,.kernel .guard)) resumeStore),
  ("workflows.resume.boundary", cursorEq
    (continueRun cfg resumeBounds resumePrefix [routedDeposit 1])
    [resumeIssue,resumeTransfer,resumeDeposit] (balances 0 3 27 (15/2)) none resumeStore &&
    cursorEq (Composition.run cfg resumeBounds initialWorld
      [.issue adminGrant,transferStep 3,routedDeposit 1])
    [resumeIssue,resumeTransfer,resumeDeposit] (balances 0 3 27 (15/2)) none resumeStore),
  ("workflows.catalog", validateCatalog registry catalog),
  ("workflows.initial.complete", worldEq initialWorld (balances 10 0 20 4) &&
    (match provisioned with | .ok s => s == expectedStore | _ => false)),
  ("workflows.empty", cursorEq (execute []) [] (balances 10 0 20 4)),
  ("workflows.transfer.deposit.withdraw", cursorEq (execute workflow)
    [t3, dEvent 1 (depositStep 4) 4 7 3 3 20 24 4 6, wEvent] (balances 7 3 20 4)),
  ("workflows.consecutive", cursorEq (execute [transferStep 3,transferStep 3])
    [t3,tEvent 1 3 7 3 4 6] (balances 4 6 20 4)),
  ("workflows.order.transfer.first", cursorEq
    (execute [transferStep 8,depositStep 4,transferStep 1]) [tEvent 0 8 10 0 2 8]
    (balances 2 8 20 4) (some (depositStep 4,.kernel .insufficientFunds))),
  ("workflows.order.deposit.first", cursorEq
    (execute [depositStep 4,transferStep 8,transferStep 1]) [d4]
    (balances 6 0 24 6) (some (transferStep 8,.kernel .insufficientFunds))),
  ("workflows.snapshot", cursorEq (execute [transferStep 3,routedDeposit 0])
    [t3,route7] (balances 0 3 27 (15/2))),
  ("workflows.output.index", cursorEq
    (execute [transferStep 3,transferStep 2,routedDeposit 1])
    [t3,tEvent 1 2 7 3 5 5,dEvent 2 (routedDeposit 1) 5 5 0 5 20 25 4 (13/2)]
    (balances 0 5 25 (13/2))),
  ("workflows.output.unit", let bad := depositSource (.priorOutput 0 ⟨⟨1⟩,⟨3⟩⟩)
    cursorEq (execute [depositStep 4,bad,transferStep 1]) [d4] (balances 6 0 24 6)
      (some (bad,.interface .inputUnit))),
  ("workflows.output.forward", cursorEq (execute [routedDeposit 1]) []
    (balances 10 0 20 4) (some (routedDeposit 1,.interface .unavailableOutput))),
  ("workflows.output.unknown", let bad := depositSource (.priorOutput 0 ⟨⟨0⟩,⟨99⟩⟩)
    cursorEq (execute [transferStep 3,bad]) [t3] (balances 7 3 20 4)
      (some (bad,.interface .unavailableOutput))),
  ("workflows.first.refusal", cursorEq (execute [transferStep 11,transferStep 1]) []
    (balances 10 0 20 4) (some (transferStep 11,.kernel .insufficientFunds))),
  ("workflows.admin.revocation", cursorEq
    (adminRun [.issue adminGrant,adminUse,.revoke ⟨11⟩,adminUse])
    [issueEvent,useEvent,revokeEvent] (balances 7 3 20 4)
    (some (adminUse,.kernel .unauthorizedInvoke)) revokedStore),
  ("workflows.admin.live.repeat", cursorEq
    (Composition.run cfg (fun i ↦ if i = 0 then adminBounds 0 else boundary i)
      ⟨initial,adminStore⟩ [.issue adminGrant,adminUse,adminUse])
    [issueEvent,useEvent,{ (tEvent 2 3 7 3 4 6) with
      step := adminUse
      preStore := issuedStore
      postStore := issuedStore }] (balances 4 6 20 4) none issuedStore),
  ("workflows.resume.output", cursorEq
    (continueRun cfg boundary (execute [transferStep 3]) [routedDeposit 0])
    [t3,route7] (balances 0 3 27 (15/2))),
  ("workflows.resume.terminal", cursorEq
    (continueRun cfg boundary (execute [depositStep 4,transferStep 8]) [transferStep 1])
    [d4] (balances 6 0 24 6) (some (transferStep 8,.kernel .insufficientFunds))),
  ("workflows.frame.collateral", (execute workflow).world.state.balance collateral == 10),
  ("workflows.frame.unsupported.counterexample",
    initial.balance aliceUsd == 10 &&
      (execute [transferStep 3]).world.state.balance aliceUsd != 10)]

-- BEGIN PROOFS
#eval show IO _root_.Unit from do
  if checks.isEmpty then throw (IO.userError "Composition workflow checks empty")
  for (label, ok) in checks do IO.println s!"{label}: {ok}"
  if checks.any (fun entry ↦ !entry.2) then
    throw (IO.userError "Composition workflow checks failed")
end DefiKernel.Composition.Tests


## FILE lean/DefiKernel/Composition/Verify.lean sha256=0510c92489398990f07a614f5d8d9228db05220fcf66297afe8a20cb078a4fdb

import DefiKernel.Composition.Audit
import DefiKernel.AxiomAudit

/-! Imported composition declarations and transitive dependencies are audited separately
from the bounded runtime inventory. Declarations added after this command are not covered. -/
#audit_axioms DefiKernel.Composition


## FILE lean/DefiKernel.lean sha256=00378bd05ac77e3f3d4603a753ebf5ae5aaf0f2063fc9651fe05d4c31997f9e2

import DefiKernel.VerifyAxioms
import DefiKernel.Typed.Verify
import DefiKernel.Composition.Verify

/-! Entry point for the pilot, typed kernel, regressions and imported axiom audits. -/


## FILE scripts/check_composition_mutations.py sha256=0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031

#!/usr/bin/env python3
"""Replay the actual composition Lean implementation under explicit source mutations.

The specification names an ordered, nonempty list of source modules, mutation
sites, required false observations and protected positive controls. Proof-only
suffixes are excluded from temporary execution copies, never from accepted files.
Exit 0: nonempty control and all sensitivity assertions pass; 1: failed assertion;
3: unavailable evidence, malformed specification or compilation/setup failure.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


CHECK_NAME = r'[a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*'


class Blocked(Exception):
    pass


def require(value, message):
    if not value:
        raise Blocked(message)


def check(value, message):
    if not value:
        raise AssertionError(message)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    raw = path.read_bytes()
    require(raw.strip(), f'empty required input: {path}')
    return raw


def parse(raw):
    def pairs(items):
        value = {}
        for key, item in items:
            require(key not in value, f'duplicate JSON key: {key}')
            value[key] = item
        return value
    return json.loads(raw, object_pairs_hook=pairs)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--spec', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    require(not out.is_relative_to(repo), 'evidence output must be outside the repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'output already exists')
    spec_raw = read(args.spec)
    spec = parse(spec_raw)
    require(isinstance(spec, dict) and set(spec) ==
            {'schema_version', 'modules', 'mutations', 'positive_checks'},
            'invalid mutation specification fields')
    require(type(spec['schema_version']) is int and spec['schema_version'] == 1,
            'unsupported mutation specification version')
    modules, mutations, positives = spec['modules'], spec['mutations'], spec['positive_checks']
    require(isinstance(modules, list) and modules, 'empty module inventory')
    require(isinstance(mutations, list) and mutations, 'empty mutation inventory')
    require(isinstance(positives, list) and positives, 'empty positive-control inventory')
    require(len(set(modules)) == len(modules), 'duplicate source module')
    require(len(set(positives)) == len(positives), 'duplicate positive control')
    require(all(isinstance(name, str) and re.fullmatch(CHECK_NAME, name)
                for name in positives), 'invalid positive check name')
    names = [m['name'] for m in mutations]
    require(len(set(names)) == len(names), 'duplicate mutation name')
    for m in mutations:
        require(isinstance(m, dict) and set(m) ==
                {'name', 'module', 'needle', 'replacement', 'required_false'},
                'invalid mutation fields')
        require(re.fullmatch(r'[a-z][a-z0-9-]*', m['name']), 'invalid mutation name')
        require(m['name'] not in {'control', 'lean-version', 'lean-path', 'git-head',
                                  'git-root-input-status'}, 'reserved variant name')
        require(m['module'] in modules, 'mutation module outside inventory')
        require(isinstance(m['needle'], str) and m['needle'], 'empty mutation needle')
        require(isinstance(m['replacement'], str) and m['replacement'] != m['needle'],
                'mutation must actually change the source')
        require(isinstance(m['required_false'], list) and m['required_false'],
                'mutation has no required false observations')
        require(all(isinstance(name, str) and re.fullmatch(CHECK_NAME, name)
                    for name in m['required_false']), 'invalid required check name')
        require(len(set(m['required_false'])) == len(m['required_false']),
                'duplicate required check')
    # Recompile local dependency closure from captured source, never stale oleans.
    blobs, ordered, visiting = {}, [], set()
    def capture(module):
        require(re.fullmatch(r'DefiKernel\.[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*', module),
                f'invalid scoped module: {module}')
        require(module not in visiting, f'cyclic local dependency: {module}')
        if module in ordered:
            return
        visiting.add(module)
        relative = 'lean/' + module.replace('.', '/') + '.lean'
        path = (repo / relative).resolve()
        require(path.is_relative_to(repo), f'source path escape: {relative}')
        raw = read(path)
        blobs[relative] = raw
        for line in raw.decode().splitlines():
            if line.startswith('import '):
                imported = line.removeprefix('import ').strip()
                require(re.fullmatch(r'[A-Za-z][A-Za-z0-9_.]*', imported),
                        f'{module}: unsupported import syntax')
                if imported.startswith('DefiKernel.'):
                    require(not imported.startswith('DefiKernel.Composition.') or imported in modules,
                            f'{module}: omitted internal dependency {imported}')
                    capture(imported)
        visiting.remove(module)
        ordered.append(module)
    for module in modules:
        require(isinstance(module, str) and re.fullmatch(
            r'DefiKernel\.Composition(?:\.[A-Za-z][A-Za-z0-9]*)+', module),
            f'invalid scoped module: {module}')
        capture(module)
    for relative in ('lean/lean-toolchain', 'lean/lake-manifest.json', 'lean/lakefile.toml'):
        blobs[relative] = read(repo / relative)
    sources = {name: sha(raw) for name, raw in blobs.items()}
    imports, prefixes = [], {}
    for module in ordered:
        source = blobs['lean/' + module.replace('.', '/') + '.lean'].decode()
        marker = '\n-- BEGIN PROOFS\n'
        require(source.count(marker) <= 1, f'{module}: duplicate proof boundary')
        if marker in source and module.startswith('DefiKernel.Composition.'):
            source, suffix = source.split(marker)
            closure = re.search(r'\n(end DefiKernel\.Composition(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$', suffix)
            require(closure, f'{module}: proof suffix lacks exact namespace closure')
            namespace = closure.group(1)[4:]
            require(f'namespace {namespace}\n' in source, f'{module}: unmatched namespace')
            source += '\n\n' + closure.group(1) + '\n'
        lines = []
        for line in source.splitlines():
            if line.startswith('import '):
                imported = line.removeprefix('import ').strip()
                require(re.fullmatch(r'[A-Za-z][A-Za-z0-9_.]*', imported),
                        f'{module}: unsupported import syntax')
                if imported not in ordered and line not in imports:
                    require(not imported.startswith('DefiKernel.'),
                            f'{module}: omitted internal dependency {imported}')
                    imports.append(line)
            else:
                lines.append(line)
        prefixes[module] = '\n'.join(lines) + '\n'
    require(imports, 'no external dependency imports captured')
    variants = {'control': dict(prefixes)}
    for m in mutations:
        source = prefixes[m['module']]
        require(source.count(m['needle']) == 1, f'{m["name"]}: mutation did not apply exactly once')
        variants[m['name']] = {**prefixes, m['module']: source.replace(m['needle'], m['replacement'], 1)}
    out.mkdir(parents=True, exist_ok=False)
    records, results = [], {}

    def run(label, command):
        proc = subprocess.run(command, cwd=repo / 'lean', capture_output=True, text=True, timeout=240)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        records.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                        'exit': proc.returncode, 'log_sha256': sha(log.encode())})
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        return proc.returncode, log

    status, version = run('lean-version', ['lake', 'env', 'lean', '--version'])
    require(status == 0, 'Lean tool identity unavailable')
    status, executable = run('lean-path', ['lake', 'env', 'which', 'lean'])
    require(status == 0, 'Lean executable path unavailable')
    executable_sha = sha(read(Path(executable.strip())))
    status, head = run('git-head', ['git', 'rev-parse', 'HEAD'])
    require(status == 0, 'Git revision unavailable')
    status, dirty = run('git-root-input-status', ['git', '-C', str(repo), 'status', '--porcelain',
                                                '--untracked-files=all', '--', *blobs])
    require(status == 0, 'Git source status unavailable')
    manifest = {'sources': sources, 'script_sha256': sha(read(Path(__file__))),
                'spec_sha256': sha(spec_raw), 'git_head': head.strip(), 'input_status': dirty,
                'lean_version': version.strip(), 'lean_executable_sha256': executable_sha,
                'scope': 'Fresh local dependency source closure; Composition proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.',
                'projection_order': ordered}
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'mutation-spec.json').write_bytes(spec_raw)
    for relative, raw in blobs.items():
        target = out / 'inputs' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    for label, parts in variants.items():
        source = '\n'.join(imports) + '\n\n' + '\n'.join(parts[m] for m in ordered)
        fixture = out / (label + '.lean')
        fixture.write_text(source)
        code, log = run(label, ['lake', 'env', 'lean', str(fixture)])
        observations = re.findall(rf'^({CHECK_NAME}): (true|false)$', log, re.MULTILINE)
        candidates = [line for line in log.splitlines()
                      if re.match(r'^[a-z.][a-z0-9_.-]*:', line)]
        require(len(candidates) == len(observations), f'{label}: malformed observation')
        checks = dict(observations)
        require(checks and len(checks) == len(observations), f'{label}: empty/duplicate observations')
        require(set(positives) <= checks.keys(), f'{label}: missing positive controls')
        false = sorted(name for name, value in checks.items() if value == 'false')
        errors = [line for line in log.splitlines()
                  if re.search(r': error(?:\([^)]*\))?:', line)]
        if label == 'control':
            require(not errors, 'control compilation/execution failed')
            check(code == 0 and not false, 'unchanged control has failing comparisons')
            for mutation in mutations:
                require(set(mutation['required_false']) <= checks.keys(),
                        f'{mutation["name"]}: missing required observation in control')
        else:
            require(checks.keys() == results['control']['checks'].keys(), f'{label}: partial execution')
            check(code != 0 or false, f'{label}: all comparisons still pass under mutation')
            expected_error = f'error: Composition runtime comparisons failed: {len(false)}'
            require(len(errors) == 1 and errors[0].endswith(expected_error),
                    f'{label}: failure is not solely the expected runtime comparison failure')
            required = next(m['required_false'] for m in mutations if m['name'] == label)
            check(code != 0 and set(required) <= set(false), f'{label}: required mutation not detected')
        check(all(checks[name] == 'true' for name in positives), f'{label}: positive control failed')
        results[label] = {'exit': code, 'fixture_sha256': sha(source.encode()),
                          'checks': checks, 'false_comparisons': false}
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        print(f'{label}: exit={code}; comparisons={len(checks)}; false={false}', flush=True)
    manifest['sources_after'] = {p: sha(read(repo / p)) for p in blobs}
    require(manifest['sources_after'] == sources, 'input sources changed during replay')
    manifest['input_sources_unchanged'] = True
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'DISCRIMINATES: {len(mutations)} mutants and one nonempty unchanged control')


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)


## FILE scripts/test_composition_mutation_runner.py sha256=c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706

#!/usr/bin/env python3
"""Exercise the mutation runner's CLI against real temporary Lean computations.

No subprocess is mocked. The temporary repository links installed dependency packages
and has its own isolated git metadata. All fixtures/logs stay outside the
source repository. Exit 0 means every nonempty control has the expected classification;
exit 1 means an observed classification differs; exit 3 means the harness could not run.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


INPUT_MODULE = 'DefiKernel.Composition.RunnerInput'
AUDIT_MODULE = 'DefiKernel.Composition.RunnerAudit'
DEPENDENCY = '''import Mathlib.Data.Nat.Basic
namespace DefiKernel.Typed
def runnerDependency : Nat := 4
-- BEGIN PROOFS
theorem runnerDependency_value : runnerDependency = 4 := rfl
end DefiKernel.Typed
'''
INPUT = '''import DefiKernel.Typed.RunnerDependency

namespace DefiKernel.Composition

example : DefiKernel.Typed.runnerDependency = 4 := DefiKernel.Typed.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Composition
'''
AUDIT = '''import DefiKernel.Composition.RunnerInput

namespace DefiKernel.Composition

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := CHECKS
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Composition runtime comparisons failed: {failures}"

end DefiKernel.Composition
'''
CHECKS = '''if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]'''


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def require(value, message):
    if not value:
        raise RuntimeError(message)


def mutation(needle='n ≤ 4', replacement='n ≤ 5', required=None):
    return {'name': 'probe', 'module': INPUT_MODULE, 'needle': needle,
            'replacement': replacement,
            'required_false': ['runner_sensitivity'] if required is None else required}


def specification(change=None):
    return {'schema_version': 1, 'modules': [INPUT_MODULE, AUDIT_MODULE],
            'mutations': [mutation() if change is None else change],
            'positive_checks': ['runner_positive']}


def cases():
    """Expected classifications are fixed independently of the runner implementation."""
    return [
        {'name': 'live-discriminating-mutant', 'exit': 0,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'dotted-comparisons', 'exit': 0,
         'spec': {**specification(mutation(required=['runner.sensitivity'])),
                  'positive_checks': ['runner.positive']},
         'checks': CHECKS.replace('runner_positive', 'runner.positive').replace(
             'runner_sensitivity', 'runner.sensitivity'),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'hyphenated-dotted-comparisons', 'exit': 0,
         'spec': {**specification(mutation(required=['runner.expected-failure'])),
                  'positive_checks': ['runner.permitted-sibling']},
         'checks': CHECKS.replace('runner_positive', 'runner.permitted-sibling').replace(
             'runner_sensitivity', 'runner.expected-failure'),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'empty-dot-segment-spec', 'exit': 3,
         'spec': specification(mutation(required=['runner..sensitivity'])),
         'message': 'invalid required check name'},
        {'name': 'trailing-dot-spec', 'exit': 3,
         'spec': {**specification(), 'positive_checks': ['runner.']},
         'message': 'invalid positive check name'},
        {'name': 'leading-dot-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println ".runner_bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'empty-dot-segment-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "runner..bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'all-true-mutant', 'exit': 1, 'spec': specification(mutation(replacement='n ≤ 3')),
         'message': 'all comparisons still pass under mutation'},
        {'name': 'required-observation-stays-true', 'exit': 1,
         'spec': specification(mutation(required=['runner_positive'])),
         'message': 'required mutation not detected'},
        {'name': 'positive-control-flipped', 'exit': 1,
         'spec': specification(mutation(replacement='n == 5')),
         'message': 'positive control failed'},
        {'name': 'compilation-only-failure', 'exit': 3,
         'spec': specification(mutation('-- compiler-control', '#check runnerUndefinedConstant')),
         'message': 'failure is not solely the expected runtime comparison failure'},
        {'name': 'compiler-error-with-runtime-failure', 'exit': 3,
         'spec': specification(mutation('n ≤ 4\ndef runnerIncludeSensitivity : Bool := true',
                                        'n ≤ 5\n#check runnerUndefinedConstant\n'
                                        'def runnerIncludeSensitivity : Bool := true')),
         'message': 'failure is not solely the expected runtime comparison failure'},
        {'name': 'empty-observations', 'exit': 3, 'checks': '[]',
         'message': 'control: empty/duplicate observations'},
        {'name': 'duplicate-observations', 'exit': 3,
         'checks': '[("runner_positive", true), ("runner_positive", true), '
                   '("runner_sensitivity", !runnerAllows 5)]',
         'message': 'control: empty/duplicate observations'},
        {'name': 'missing-positive-observation', 'exit': 3,
         'checks': '[("runner_sensitivity", !runnerAllows 5)]',
         'message': 'control: missing positive controls'},
        {'name': 'missing-required-observation', 'exit': 3,
         'spec': specification(mutation(required=['runner_absent'])),
         'message': 'probe: missing required observation in control'},
        {'name': 'partial-mutant-observations', 'exit': 3,
         'spec': specification(mutation('runnerIncludeSensitivity : Bool := true',
                                        'runnerIncludeSensitivity : Bool := false')),
         'message': 'probe: partial execution'},
        {'name': 'no-op-mutation', 'exit': 3,
         'spec': specification(mutation(replacement='n ≤ 4')),
         'message': 'mutation must actually change the source'},
        {'name': 'missing-mutation-needle', 'exit': 3,
         'spec': specification(mutation('runnerNeedleDoesNotExist', 'false')),
         'message': 'mutation did not apply exactly once'},
        {'name': 'missing-source-setup', 'exit': 3, 'missing_source': True,
         'message': 'FileNotFoundError'},
        {'name': 'missing-manifest-setup', 'exit': 3, 'missing_manifest': True,
         'message': 'FileNotFoundError'},
        {'name': 'existing-output-setup', 'exit': 3, 'existing_output': True,
         'message': 'output already exists'},
        {'name': 'reserved-mutation-name', 'exit': 3,
         'spec': specification({**mutation(), 'name': 'lean-version'}),
         'message': 'reserved variant name'},
        {'name': 'empty-module-inventory', 'exit': 3,
         'spec': {**specification(), 'modules': []}, 'message': 'empty module inventory'},
        {'name': 'empty-positive-inventory', 'exit': 3,
         'spec': {**specification(), 'positive_checks': []}, 'message': 'empty positive-control inventory'},
        {'name': 'duplicate-module-inventory', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE, INPUT_MODULE, AUDIT_MODULE]},
         'message': 'duplicate source module'},
        {'name': 'duplicate-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': [mutation(), mutation()]}, 'message': 'duplicate mutation name'},
        {'name': 'duplicate-positive-check', 'exit': 3,
         'spec': {**specification(), 'positive_checks': ['runner_positive', 'runner_positive']},
         'message': 'duplicate positive control'},
        {'name': 'duplicate-required-check', 'exit': 3,
         'spec': specification(mutation(required=['runner_sensitivity', 'runner_sensitivity'])),
         'message': 'duplicate required check'},
        {'name': 'nonunique-mutation-needle', 'exit': 3,
         'spec': specification(mutation('def ', 'private def ')), 'message': 'mutation did not apply exactly once'},
        {'name': 'malformed-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "runner_bad: truth"\n', 'message': 'malformed observation'},
        {'name': 'malformed-json', 'exit': 3, 'raw_spec': '{', 'message': 'JSONDecodeError'},
        {'name': 'duplicate-json-key', 'exit': 3,
         'raw_spec': '{"schema_version": 1, "schema_version": 1}', 'message': 'duplicate JSON key'},
        {'name': 'output-inside-repository', 'exit': 3, 'inside_output': True,
         'message': 'evidence output must be outside the repository'},
        {'name': 'output-symlink', 'exit': 3, 'symlink_output': True, 'message': 'output already exists'},
        {'name': 'empty-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': []}, 'message': 'empty mutation inventory'},
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--runner', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    runner = (args.runner or repo / 'scripts/check_composition_mutations.py').resolve()
    require(not out.is_relative_to(repo), 'harness output must be outside source repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'harness output already exists')
    require(runner.is_file(), 'runner source unavailable')
    require((repo / 'lean/.lake/packages').is_dir(), 'installed dependency packages unavailable')
    out.mkdir(parents=True)
    before = sha(runner.read_bytes())
    started = datetime.now(timezone.utc).isoformat()
    identity = []

    def identify(label, command):
        proc = subprocess.run(command, cwd=repo / 'lean', text=True, capture_output=True, timeout=60)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        identity.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                         'exit': proc.returncode, 'log_sha256': sha(log.encode())})
        require(proc.returncode == 0, f'{label} unavailable: {log}')
        return proc.stdout.strip()

    lean_version = identify('lean-version', ['lake', 'env', 'lean', '--version'])
    lean_path = Path(identify('lean-path', ['lake', 'env', 'which', 'lean']))
    git_head = identify('git-head', ['git', 'rev-parse', 'HEAD'])
    fake = out / 'fixture-repo'
    lean = fake / 'lean'
    typed = lean / 'DefiKernel/Composition'
    typed.mkdir(parents=True)
    dependency = lean / 'DefiKernel/Typed/RunnerDependency.lean'
    dependency.parent.mkdir(parents=True)
    dependency.write_text(DEPENDENCY)
    # Independent metadata prevents even optional index refreshes in the source repo.
    for command in [
        ['git', 'init', '--quiet', str(fake)],
        ['git', '-C', str(fake), '-c', 'user.name=DeFiFormal fixture',
         '-c', 'user.email=fixture@invalid', 'commit', '--allow-empty', '--quiet',
         '-m', 'Initialize isolated mutation-runner fixture'],
    ]:
        proc = subprocess.run(command, text=True, capture_output=True, timeout=60)
        require(proc.returncode == 0, f'isolated fixture git setup failed: {proc.stderr}')
    (lean / '.lake').mkdir()
    # Reuse dependency packages, never the source project's .lake/build directory.
    (lean / '.lake/packages').symlink_to(repo / 'lean/.lake/packages', target_is_directory=True)
    for name in ('lean-toolchain', 'lake-manifest.json', 'lakefile.toml'):
        shutil.copyfile(repo / 'lean' / name, lean / name)
    manifest = (lean / 'lake-manifest.json').read_bytes()
    records = []
    for case in cases():
        (typed / 'RunnerInput.lean').write_text(INPUT)
        (typed / 'RunnerAudit.lean').write_text(AUDIT.replace('CHECKS', case.get('checks', CHECKS)).replace(
            '  let failures :=', case.get('extra_audit', '') + '  let failures :='))
        (lean / 'lake-manifest.json').write_bytes(manifest)
        if case.get('missing_source'):
            (typed / 'RunnerInput.lean').unlink()
        if case.get('missing_manifest'):
            (lean / 'lake-manifest.json').unlink()
        spec = case.get('spec', specification())
        spec_path = out / (case['name'] + '-spec.json')
        spec_path.write_text(case.get('raw_spec', json.dumps(spec, indent=2) + '\n'))
        result_path = out / 'runs' / case['name']
        if case.get('inside_output'):
            result_path = fake / 'forbidden-output'
        if case.get('symlink_output'):
            result_path.parent.mkdir(parents=True, exist_ok=True)
            result_path.symlink_to(out / 'nonexistent-output', target_is_directory=True)
        if case.get('existing_output'):
            result_path.mkdir(parents=True)
        command = [sys.executable, str(runner), '--repo', str(fake), '--spec', str(spec_path),
                   '--out', str(result_path)]
        tick = time.monotonic()
        proc = subprocess.run(command, cwd=repo, text=True, capture_output=True, timeout=300)
        elapsed = time.monotonic() - tick
        log = proc.stdout + proc.stderr
        log_path = out / (case['name'] + '.log')
        log_path.write_text(log)
        matched = proc.returncode == case['exit'] and case['message'] in log
        runtime = {}
        results_file = result_path / 'results.json'
        if results_file.exists():
            runtime = json.loads(results_file.read_text())
        # Accepted discrimination additionally requires exact real Lean observations.
        if case['name'] in ('live-discriminating-mutant', 'dotted-comparisons', 'hyphenated-dotted-comparisons'):
            measured = runtime.get('results', {})
            separator = '.' if case['name'] == 'dotted-comparisons' else '_'
            expected_positive = 'runner' + separator + 'positive'
            expected_sensitivity = 'runner' + separator + 'sensitivity'
            if case['name'] == 'hyphenated-dotted-comparisons':
                expected_positive, expected_sensitivity = 'runner.permitted-sibling', 'runner.expected-failure'
            matched = matched and measured.get('control', {}).get('checks') == {
                expected_positive: 'true', expected_sensitivity: 'true'}
            matched = matched and measured.get('probe', {}).get('checks') == {
                expected_positive: 'true', expected_sensitivity: 'false'}
        observations = {}
        for variant in ('control', 'probe'):
            variant_log = result_path / (variant + '.log')
            if variant_log.exists():
                raw = variant_log.read_text()
                observations[variant] = {
                    'lines': re.findall(r'^([a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*): (true|false)$', raw, re.MULTILINE),
                    'errors': [line for line in raw.splitlines() if re.search(r': error(?:\([^)]*\))?:', line)],
                    'log_sha256': sha(raw.encode())}
        record = {'name': case['name'], 'command': command, 'cwd': str(repo),
                  'expected_exit': case['exit'], 'actual_exit': proc.returncode,
                  'expected_message': case['message'], 'passed': matched,
                  'elapsed_seconds': round(elapsed, 6), 'log': str(log_path),
                  'log_sha256': sha(log.encode()), 'cli_output': log,
                  'spec_sha256': sha(spec_path.read_bytes()),
                  'lean_observations': observations, 'runner_records': runtime.get('runs', [])}
        records.append(record)
        print(f'{case["name"]}: expected={case["exit"]}; actual={proc.returncode}; '
              f'{"PASS" if matched else "FAIL"}', flush=True)
        (out / 'cases.json').write_text(json.dumps(records, indent=2) + '\n')
    require(records, 'zero controls executed')
    require(before == sha(runner.read_bytes()), 'runner changed during controls; rerun final bytes')
    summary = {'schema_version': 1, 'kind': 'executed-cli-runner-controls',
               'started_utc': started, 'finished_utc': datetime.now(timezone.utc).isoformat(),
               'source_repo': str(repo), 'git_head': git_head,
               'runner_source': str(runner), 'runner_sha256': before,
               'harness_source': str(Path(__file__).resolve()),
               'harness_sha256': sha(Path(__file__).read_bytes()),
               'lean_version': lean_version, 'lean_executable_sha256': sha(lean_path.read_bytes()),
               'python_version': sys.version, 'tool_identity_commands': identity,
               'fixture_scope': 'Synthetic development Lean computations; actual CLI and installed '
                                'Lean/mathlib. No subprocess mocks; no production theorem claim.',
               'fixture_dependency_sha256': sha(DEPENDENCY.encode()),
               'fixture_input_sha256': sha(INPUT.encode()),
               'fixture_audit_template_sha256': sha(AUDIT.encode()),
               'total': len(records), 'passed': sum(r['passed'] for r in records),
               'cases': records}
    (out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(f'CONTROLS: {summary["passed"]}/{summary["total"]} passed', flush=True)
    return 0 if all(r['passed'] for r in records) else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)


## FILE lean/DefiKernel/Typed/Types.lean sha256=5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82

import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod

/-! Reusable finite-ledger identities and dimensioned values. Identity authentication,
observation truth and the finite deployment universe are external assumptions. -/
namespace DefiKernel.Typed

structure ClaimId where
  value : Nat
  deriving DecidableEq, Repr

structure CapabilityId where
  value : Nat
  deriving DecidableEq, Repr

structure OperationId where
  value : Nat
  deriving DecidableEq, Repr

structure ObservationId where
  value : Nat
  deriving DecidableEq, Repr

abbrev Cell (Party Asset Domain : Type) := Domain × Party × Asset

/-- Amount expressions can be signed; a quantity is explicitly nonnegative. -/
structure Quantity {Asset : Type} (asset : Asset) where
  amount : ℚ
  nonneg : 0 ≤ amount

structure State (Party Asset Domain : Type) where
  balance : Cell Party Asset Domain → ℚ
  nonneg : ∀ c, 0 ≤ balance c

def total {Party Asset Domain : Type} [Fintype Party]
    (s : State Party Asset Domain) (domain : Domain) (asset : Asset) : ℚ :=
  ∑ party, s.balance (domain, party, asset)

/-- A price is quote-asset units per one base-asset unit. -/
inductive Unit (Asset : Type) where
  | amount (asset : Asset)
  | price (base quote : Asset)
  | scalar
  | bool
  deriving DecidableEq, Repr

/-- Numeric dimensions exclude booleans without a user-supplied typeclass. -/
inductive NumericUnit (Asset : Type) where
  | amount (asset : Asset)
  | price (base quote : Asset)
  | scalar
  deriving DecidableEq, Repr

abbrev NumericUnit.toUnit {Asset : Type} : NumericUnit Asset → Unit Asset
  | .amount a => .amount a
  | .price a b => .price a b
  | .scalar => .scalar

abbrev Value {Asset : Type} : Unit Asset → Type
  | .bool => Bool
  | .amount _ | .price _ _ | .scalar => ℚ

instance {Asset : Type} (u : Unit Asset) : DecidableEq (Value u) := by
  cases u <;> exact inferInstance

instance {Asset : Type} (u : Unit Asset) : Repr (Value u) := by
  cases u <;> exact inferInstance

def numericValue {Asset : Type} (u : NumericUnit Asset) (q : ℚ) : Value u.toUnit :=
  match u with
  | .amount _ | .price _ _ | .scalar => q

def numericRat {Asset : Type} (u : NumericUnit Asset) (v : Value u.toUnit) : ℚ :=
  match u with
  | .amount _ | .price _ _ | .scalar => v

abbrev PackedValue (Asset : Type) := (u : Unit Asset) × Value u

inductive EvalFailure where
  | argumentCount
  | argumentUnit
  | partyArgument
  | missingObservation
  | observationUnit
  | divisionByZero
  deriving DecidableEq, Repr

inductive PartyRef (Party : Type) where
  | caller
  | literal (party : Party)
  | argument (index : Nat)
  deriving DecidableEq, Repr

def PartyRef.resolve {Party : Type} (caller : Party) (parties : List Party) :
    PartyRef Party → Except EvalFailure Party
  | .caller => .ok caller
  | .literal p => .ok p
  | .argument n => match parties[n]? with
    | some p => .ok p
    | none => .error .partyArgument

structure CellRef (Party Asset Domain : Type) (asset : Asset) where
  domain : Domain
  owner : PartyRef Party
  deriving DecidableEq, Repr

def CellRef.resolve {Party Asset Domain : Type} {asset : Asset}
    (caller : Party) (parties : List Party) (c : CellRef Party Asset Domain asset) :
    Except EvalFailure (Cell Party Asset Domain) := do
  let party ← c.owner.resolve caller parties
  return (c.domain, party, asset)

structure ObservationKey (Domain : Type) where
  domain : Domain
  id : ObservationId
  deriving DecidableEq, Repr

/-- Expected unit is intrinsic; the environment's delivered unit is checked at lookup. -/
structure ObservationRef (Asset Domain : Type) (unit : Unit Asset) where
  key : ObservationKey Domain
  deriving DecidableEq, Repr

structure Observation (Asset : Type) where
  value : PackedValue Asset
  timestamp : Nat

abbrev Environment (Asset Domain : Type) := ObservationKey Domain → Option (Observation Asset)

/-- Adapter-supplied identity. Constructing this value is not signature verification. -/
structure InvocationContext (Party Domain : Type) where
  principal : Party
  domain : Domain
  deriving DecidableEq, Repr

-- BEGIN PROOFS

theorem numericRat_numericValue {Asset : Type} (u : NumericUnit Asset) (q : ℚ) :
    numericRat u (numericValue u q) = q := by cases u <;> rfl

theorem numericValue_numericRat {Asset : Type} (u : NumericUnit Asset) (v : Value u.toUnit) :
    numericValue u (numericRat u v) = v := by cases u <;> rfl

end DefiKernel.Typed


## FILE lean/DefiKernel/Typed/Expr.lean sha256=1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed

import DefiKernel.Typed.Types

/-! A closed dimensioned expression language. All arithmetic is exact rational arithmetic.
Read sets conservatively include both conditional branches. Environment truth is assumed. -/
namespace DefiKernel.Typed

inductive Var {Asset : Type} : List (Unit Asset) → Unit Asset → Type where
  | here {u : Unit Asset} {signature : List (Unit Asset)} : Var (u :: signature) u
  | there {u v : Unit Asset} {signature : List (Unit Asset)} :
      Var signature u → Var (v :: signature) u

inductive Args {Asset : Type} : List (Unit Asset) → Type where
  | nil : Args []
  | cons {u : Unit Asset} {signature : List (Unit Asset)} :
      Value u → Args signature → Args (u :: signature)

def Args.get {Asset : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Args signature → Var signature u → Value u
  | .cons value _, .here => value
  | .cons _ rest, .there v => rest.get v

/-- Check arity and every delivered unit before exposing typed arguments to evaluation. -/
def Args.check {Asset : Type} [DecidableEq Asset] (signature : List (Unit Asset))
    (values : List (PackedValue Asset)) : Except EvalFailure (Args signature) :=
  match signature, values with
  | [], [] => .ok .nil
  | u :: us, ⟨v, value⟩ :: vs =>
    if h : v = u then do
      let rest ← Args.check us vs
      return .cons (h ▸ value) rest
    else .error .argumentUnit
  | _, _ => .error .argumentCount

inductive UnaryOp (Asset : Type) : Unit Asset → Unit Asset → Type where
  | neg (u : NumericUnit Asset) : UnaryOp Asset u.toUnit u.toUnit
  | not : UnaryOp Asset .bool .bool

inductive BinaryOp (Asset : Type) : Unit Asset → Unit Asset → Unit Asset → Type where
  | add (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit u.toUnit
  | sub (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit u.toUnit
  | scale (u : NumericUnit Asset) : BinaryOp Asset .scalar u.toUnit u.toUnit
  | divide (u : NumericUnit Asset) : BinaryOp Asset u.toUnit .scalar u.toUnit
  | ratio (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .scalar
  | convert (base quote : Asset) : BinaryOp Asset (.amount base) (.price base quote) (.amount quote)
  | unconvert (base quote : Asset) :
      BinaryOp Asset (.amount quote) (.price base quote) (.amount base)
  | le (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .bool
  | lt (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .bool
  | eq (u : Unit Asset) : BinaryOp Asset u u .bool
  | and : BinaryOp Asset .bool .bool .bool
  | or : BinaryOp Asset .bool .bool .bool

def UnaryOp.eval {Asset : Type} {u v : Unit Asset} :
    UnaryOp Asset u v → Value u → Value v
  | .neg n, x => numericValue n (- numericRat n x)
  | .not, x => !x

/-- Division checks its denominator explicitly; rational division is otherwise total at zero. -/
def BinaryOp.eval {Asset : Type} {u v w : Unit Asset} :
    BinaryOp Asset u v w → Value u → Value v → Except EvalFailure (Value w)
  | .add n, x, y => .ok (numericValue n (numericRat n x + numericRat n y))
  | .sub n, x, y => .ok (numericValue n (numericRat n x - numericRat n y))
  | .scale n, x, y => .ok (numericValue n (x * numericRat n y))
  | .divide n, x, y =>
    if y = 0 then .error .divisionByZero else .ok (numericValue n (numericRat n x / y))
  | .ratio n, x, y =>
    if numericRat n y = 0 then .error .divisionByZero
    else .ok (numericRat n x / numericRat n y)
  | .convert _ _, x, y => .ok (x * y)
  | .unconvert _ _, x, y =>
    if y = 0 then .error .divisionByZero else .ok (x / y)
  | .le n, x, y => .ok (decide (numericRat n x ≤ numericRat n y))
  | .lt n, x, y => .ok (decide (numericRat n x < numericRat n y))
  | .eq _, x, y => .ok (decide (x = y))
  | .and, x, y => .ok (x && y)
  | .or, x, y => .ok (x || y)

inductive Expr (Party Asset Domain : Type) (signature : List (Unit Asset)) :
    Unit Asset → Type where
  | lit {u} (value : Value u) : Expr Party Asset Domain signature u
  | arg {u} (v : Var signature u) : Expr Party Asset Domain signature u
  | balance {a} (cell : CellRef Party Asset Domain a) :
      Expr Party Asset Domain signature (.amount a)
  | observe {u} (key : ObservationRef Asset Domain u) : Expr Party Asset Domain signature u
  | timestamp (key : ObservationKey Domain) : Expr Party Asset Domain signature .scalar
  | now : Expr Party Asset Domain signature .scalar
  | unary {u v} (op : UnaryOp Asset u v) (x : Expr Party Asset Domain signature u) :
      Expr Party Asset Domain signature v
  | binary {u v w} (op : BinaryOp Asset u v w)
      (x : Expr Party Asset Domain signature u) (y : Expr Party Asset Domain signature v) :
      Expr Party Asset Domain signature w
  | ite {u} (condition : Expr Party Asset Domain signature .bool)
      (yes no : Expr Party Asset Domain signature u) : Expr Party Asset Domain signature u

abbrev PackedCellRef (Party Asset Domain : Type) :=
  (asset : Asset) × CellRef Party Asset Domain asset

inductive EnvRead (Domain : Type) where
  | observation (key : ObservationKey Domain)
  | currentTime
  deriving DecidableEq, Repr

structure EvalContext (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  state : State Party Asset Domain
  env : Environment Asset Domain
  caller : Party
  parties : List Party
  args : Args signature
  now : Nat

def readBalance {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (ctx : EvalContext Party Asset Domain signature) (ref : PackedCellRef Party Asset Domain) :
    Except EvalFailure ℚ := do
  let c ← ref.2.resolve ctx.caller ctx.parties
  return ctx.state.balance c

def readObservation {Asset Domain : Type} [DecidableEq Asset] {u : Unit Asset}
    (env : Environment Asset Domain) (ref : ObservationRef Asset Domain u) :
    Except EvalFailure (Value u) :=
  match env ref.key with
  | none => .error .missingObservation
  | some observation =>
    if h : observation.value.1 = u then .ok (h ▸ observation.value.2)
    else .error .observationUnit

/-- Binary operators, including boolean and/or, evaluate both operands. Only `ite`
selects a branch lazily. Read inventories conservatively include every branch. -/
def Expr.eval {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (ctx : EvalContext Party Asset Domain signature) :
    Expr Party Asset Domain signature u → Except EvalFailure (Value u)
  | .lit value => .ok value
  | .arg v => .ok (ctx.args.get v)
  | .balance ref => readBalance ctx ⟨_, ref⟩
  | .observe ref => readObservation ctx.env ref
  | .timestamp key => match ctx.env key with
    | none => .error .missingObservation
    | some observation => .ok observation.timestamp
  | .now => .ok ctx.now
  | .unary op x => do return op.eval (← x.eval ctx)
  | .binary op x y => do op.eval (← x.eval ctx) (← y.eval ctx)
  | .ite condition yes no => do
    if ← condition.eval ctx then yes.eval ctx else no.eval ctx

/-- Syntactic reads include inactive branches and all expression children. -/
def Expr.stateReads {Party Asset Domain : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Expr Party Asset Domain signature u → List (PackedCellRef Party Asset Domain)
  | .balance ref => [⟨_, ref⟩]
  | .unary _ x => x.stateReads
  | .binary _ x y => x.stateReads ++ y.stateReads
  | .ite condition yes no => condition.stateReads ++ yes.stateReads ++ no.stateReads
  | .lit _ | .arg _ | .observe _ | .timestamp _ | .now => []

def Expr.envReads {Party Asset Domain : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Expr Party Asset Domain signature u → List (EnvRead Domain)
  | .observe ref => [.observation ref.key]
  | .timestamp key => [.observation key]
  | .now => [.currentTime]
  | .unary _ x => x.envReads
  | .binary _ x y => x.envReads ++ y.envReads
  | .ite condition yes no => condition.envReads ++ yes.envReads ++ no.envReads
  | .lit _ | .arg _ | .balance _ => []

def Expr.resolveStateReads {Party Asset Domain : Type} {signature : List (Unit Asset)}
    {u : Unit Asset} (caller : Party) (parties : List Party)
    (expression : Expr Party Asset Domain signature u) :
    Except EvalFailure (List (Cell Party Asset Domain)) :=
  expression.stateReads.mapM (fun ref ↦ ref.2.resolve caller parties)

def EnvRead.Agree {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (left right : EvalContext Party Asset Domain signature) : EnvRead Domain → Prop
  | .observation key => left.env key = right.env key
  | .currentTime => left.now = right.now

-- BEGIN PROOFS

/-- Equality on all recorded reads and typed arguments preserves the entire evaluation result,
including missing-input, wrong-unit and zero-division refusal behavior. -/
theorem Expr.eval_congr {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (expression : Expr Party Asset Domain signature u)
    (left right : EvalContext Party Asset Domain signature)
    (ha : left.args = right.args)
    (hs : ∀ ref ∈ expression.stateReads, readBalance left ref = readBalance right ref)
    (he : ∀ key ∈ expression.envReads, EnvRead.Agree left right key) :
    expression.eval left = expression.eval right := by
  induction expression with
  | lit value => rfl
  | arg v => simp only [Expr.eval, ha]
  | balance ref => exact hs ⟨_, ref⟩ (by simp [Expr.stateReads])
  | observe ref =>
    have h := he (.observation ref.key) (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, readObservation, h]
  | timestamp key =>
    have h := he (.observation key) (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, h]
  | now =>
    have h := he .currentTime (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, h]
  | unary op x ih =>
    have hx := ih hs he
    simp only [Expr.eval, hx]
  | binary op x y ihx ihy =>
    have hx := ihx
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hy := ihy
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    simp only [Expr.eval, hx, hy]
  | ite condition yes no ihc ihy ihn =>
    have hc := ihc
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hy := ihy
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hn := ihn
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    simp only [Expr.eval, hc, hy, hn]

/-- Equal caller/party inputs and equal balances at successfully resolved references suffice
for state-read agreement. Invalid party indices produce the same refusal on both sides. -/
theorem readBalance_congr {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (left right : EvalContext Party Asset Domain signature) (ref : PackedCellRef Party Asset Domain)
    (hc : left.caller = right.caller) (hp : left.parties = right.parties)
    (hs : ∀ c, ref.2.resolve left.caller left.parties = .ok c →
      left.state.balance c = right.state.balance c) :
    readBalance left ref = readBalance right ref := by
  simp only [readBalance, ← hc, ← hp]
  cases h : ref.2.resolve left.caller left.parties with
  | error reason => rfl
  | ok c => simp [hs c h]

/-- A concrete ledger formulation of read dependence. Only successfully resolved cells need
equal balances; the same caller and party arguments also preserve resolution failures. -/
theorem Expr.eval_congr_of_resolved {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (expression : Expr Party Asset Domain signature u)
    (left right : EvalContext Party Asset Domain signature)
    (ha : left.args = right.args) (hc : left.caller = right.caller)
    (hp : left.parties = right.parties)
    (hs : ∀ ref ∈ expression.stateReads, ∀ c,
      ref.2.resolve left.caller left.parties = .ok c →
        left.state.balance c = right.state.balance c)
    (he : ∀ key ∈ expression.envReads, EnvRead.Agree left right key) :
    expression.eval left = expression.eval right := by
  apply expression.eval_congr left right ha _ he
  intro ref href
  exact readBalance_congr left right ref hc hp (hs ref href)

end DefiKernel.Typed


## FILE lean/DefiKernel/Typed/Authority.lean sha256=dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb

import DefiKernel.Typed.Types

/-! Nondelegating capability administration under a trusted actor, domain administrator and
operation-domain lookup. List positions are permanent IDs: revoked entries remain as tombstones.
Authentication, registry truth, allowances and replay prevention are outside this model. -/
namespace DefiKernel.Typed

inductive Right (Party Asset Domain : Type) where
  | invoke
  | debit (cell : Cell Party Asset Domain)
  | changeSupply (domain : Domain) (asset : Asset)
  deriving DecidableEq, Repr

def Right.inDomain {Party Asset Domain : Type} [DecidableEq Domain]
    (right : Right Party Asset Domain) (domain : Domain) : Bool :=
  match right with
  | .invoke => true
  | .debit cell => decide (cell.1 = domain)
  | .changeSupply d _ => decide (d = domain)

structure Grant (Party Asset Domain : Type) where
  holder : Party
  domain : Domain
  operation : OperationId
  right : Right Party Asset Domain
  deriving DecidableEq, Repr

structure Capability (Party Asset Domain : Type) extends Grant Party Asset Domain where
  live : Bool
  deriving DecidableEq, Repr

/-- The adapter supplies this immutable configuration, separately from caller requests. -/
structure AuthorityConfig (Party Domain : Type) where
  domainAdmin : Domain → Party
  operationDomain : OperationId → Option Domain

/-- No entry is removed; length is the next fresh ID, so no separate counter invariant is needed. -/
structure CapabilityStore (Party Asset Domain : Type) where
  entries : List (Capability Party Asset Domain)
  deriving DecidableEq, Repr

def CapabilityStore.empty {Party Asset Domain : Type} : CapabilityStore Party Asset Domain := ⟨[]⟩

def CapabilityStore.nextId {Party Asset Domain : Type}
    (store : CapabilityStore Party Asset Domain) : CapabilityId := ⟨store.entries.length⟩

def CapabilityStore.lookup {Party Asset Domain : Type}
    (store : CapabilityStore Party Asset Domain) (id : CapabilityId) := store.entries[id.value]?

inductive AuthorityFailure where
  | unauthorizedAdmin
  | operationDomain
  | resourceDomain
  | unknownCapability
  deriving DecidableEq, Repr

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def isDomainAdmin (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (domain : Domain) : Bool :=
  decide (ctx.domain = domain ∧ ctx.principal = config.domainAdmin domain)

/-- A grant cannot choose its ID or reactivate an existing entry. -/
def issueCapability (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (store : CapabilityStore Party Asset Domain) (grant : Grant Party Asset Domain) :
    Except AuthorityFailure (CapabilityId × CapabilityStore Party Asset Domain) :=
  if isDomainAdmin config ctx grant.domain then
    if config.operationDomain grant.operation = some grant.domain then
      if grant.right.inDomain grant.domain then
        .ok (store.nextId, ⟨store.entries ++ [⟨grant, true⟩]⟩)
      else .error .resourceDomain
    else .error .operationDomain
  else .error .unauthorizedAdmin

/-- Revocation is idempotent and retains the ID permanently, including its original scope. -/
def revokeCapability (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (store : CapabilityStore Party Asset Domain) (id : CapabilityId) :
    Except AuthorityFailure (CapabilityStore Party Asset Domain) :=
  match store.lookup id with
  | none => .error .unknownCapability
  | some cap =>
    if isDomainAdmin config ctx cap.domain then
      .ok ⟨store.entries.set id.value { cap with live := false }⟩
    else .error .unauthorizedAdmin

/-- Each supplied ID must itself pass all scope checks to contribute an exact right. -/
def authorizesId (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) (id : CapabilityId) : Bool :=
  match store.lookup id with
  | none => false
  | some cap => decide (cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = operation ∧ cap.right = right ∧
      right.inDomain ctx.domain = true)

/-- Existential use means duplicate request IDs confer no additional rights. -/
def hasAuthority (store : CapabilityStore Party Asset Domain)
    (ids : List CapabilityId) (ctx : InvocationContext Party Domain)
    (operation : OperationId) (right : Right Party Asset Domain) : Bool :=
  ids.any (authorizesId store ctx operation right)

-- BEGIN PROOFS

omit [DecidableEq Asset] in
theorem issueCapability_ok_iff (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain) :
    issueCapability config ctx store grant = .ok (id, post) ↔
      isDomainAdmin config ctx grant.domain = true ∧
      config.operationDomain grant.operation = some grant.domain ∧
      grant.right.inDomain grant.domain = true ∧
      id = store.nextId ∧ post = ⟨store.entries ++ [⟨grant, true⟩]⟩ := by
  unfold issueCapability
  split <;> simp_all
  split <;> simp_all
  split <;> simp_all
  aesop

omit [DecidableEq Asset] in
theorem issueCapability_admin (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) :
    ctx.domain = grant.domain ∧ ctx.principal = config.domainAdmin grant.domain := by
  simpa [isDomainAdmin] using (issueCapability_ok_iff ..).mp h |>.1

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem lookup_nextId (store : CapabilityStore Party Asset Domain) :
    store.lookup store.nextId = none := by simp [CapabilityStore.lookup, CapabilityStore.nextId]

omit [DecidableEq Asset] in
theorem issueCapability_fresh (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) :
    store.lookup id = none ∧ post.lookup id = some ⟨grant, true⟩ ∧
      post.nextId.value = store.nextId.value + 1 := by
  obtain ⟨_, _, _, rfl, rfl⟩ := (issueCapability_ok_iff ..).mp h
  simp [CapabilityStore.lookup, CapabilityStore.nextId]

omit [DecidableEq Asset] in
theorem issueCapability_preserves_other (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id other : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) (hne : other ≠ id) :
    post.lookup other = store.lookup other := by
  obtain ⟨_, _, _, rfl, rfl⟩ := (issueCapability_ok_iff ..).mp h
  have hn : other.value ≠ store.entries.length := by
    intro he
    apply hne
    cases other
    simp_all [CapabilityStore.nextId]
  simp only [CapabilityStore.lookup, List.getElem?_append]
  split
  · rfl
  · rename_i hge
    have ht : store.entries.length < other.value := by omega
    have hz : other.value - store.entries.length ≠ 0 := by omega
    simp [List.getElem?_eq_none (by omega : store.entries.length ≤ other.value), hz]

omit [DecidableEq Asset] in
theorem issueCapability_ne_existing (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id old : CapabilityId)
    (post : CapabilityStore Party Asset Domain) (cap : Capability Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post))
    (hold : store.lookup old = some cap) : id ≠ old := by
  intro he
  have hf := (issueCapability_fresh config ctx store grant id post h).1
  rw [he, hold] at hf
  contradiction

omit [DecidableEq Asset] in
theorem revokeCapability_ok_iff (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain) :
    revokeCapability config ctx store id = .ok post ↔
      ∃ cap, store.lookup id = some cap ∧ isDomainAdmin config ctx cap.domain = true ∧
        post = ⟨store.entries.set id.value { cap with live := false }⟩ := by
  unfold revokeCapability
  split <;> simp_all
  split <;> simp_all
  aesop

omit [DecidableEq Asset] in
theorem revokeCapability_admin (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) :
    ∃ cap, store.lookup id = some cap ∧ ctx.domain = cap.domain ∧
      ctx.principal = config.domainAdmin cap.domain := by
  obtain ⟨cap, hc, ha, _⟩ := (revokeCapability_ok_iff ..).mp h
  exact ⟨cap, hc, by simpa [isDomainAdmin] using ha⟩

omit [DecidableEq Asset] in
theorem revokeCapability_tombstone (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) :
    ∃ cap, store.lookup id = some cap ∧
      post.lookup id = some { cap with live := false } ∧ post.nextId = store.nextId := by
  obtain ⟨cap, hc, _, rfl⟩ := (revokeCapability_ok_iff ..).mp h
  have hi : id.value < store.entries.length := by
    by_contra hn
    have hn' : store.entries.length ≤ id.value := by omega
    simp [CapabilityStore.lookup, List.getElem?_eq_none hn'] at hc
  exact ⟨cap, hc, by simp [CapabilityStore.lookup, hi], by simp [CapabilityStore.nextId]⟩

omit [DecidableEq Asset] in
theorem revokeCapability_preserves_other (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id other : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) (hne : other ≠ id) :
    post.lookup other = store.lookup other := by
  obtain ⟨cap, _, _, rfl⟩ := (revokeCapability_ok_iff ..).mp h
  have hn : id.value ≠ other.value := by
    intro he
    apply hne
    cases id
    cases other
    simp_all
  simp [CapabilityStore.lookup, List.getElem?_set_ne hn]

theorem authorizesId_iff (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) (id : CapabilityId) :
    authorizesId store ctx operation right id = true ↔
      ∃ cap, store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
        cap.domain = ctx.domain ∧ cap.operation = operation ∧ cap.right = right ∧
        right.inDomain ctx.domain = true := by
  unfold authorizesId
  split <;> simp_all

theorem hasAuthority_iff (store : CapabilityStore Party Asset Domain) (ids : List CapabilityId)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) :
    hasAuthority store ids ctx operation right = true ↔
      ∃ id ∈ ids, authorizesId store ctx operation right id = true := by
  simp [hasAuthority]

theorem hasAuthority_duplicate (store : CapabilityStore Party Asset Domain)
    (ids : List CapabilityId) (id : CapabilityId) (ctx : InvocationContext Party Domain)
    (operation : OperationId) (right : Right Party Asset Domain) :
    hasAuthority store (id :: id :: ids) ctx operation right =
      hasAuthority store (id :: ids) ctx operation right := by
  simp [hasAuthority]

theorem revokeCapability_cannot_use (config : AuthorityConfig Party Domain)
    (adminCtx ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (operation : OperationId) (right : Right Party Asset Domain)
    (h : revokeCapability config adminCtx store id = .ok post) :
    authorizesId post ctx operation right id = false := by
  obtain ⟨cap, _, hc, _⟩ := revokeCapability_tombstone config adminCtx store id post h
  simp [authorizesId, hc]

/-- Reissuing authority leaves every existing revoked ID unusable. -/
theorem issueCapability_keeps_revoked (config : AuthorityConfig Party Domain)
    (adminCtx ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id old : CapabilityId)
    (post : CapabilityStore Party Asset Domain) (cap : Capability Party Asset Domain)
    (operation : OperationId) (right : Right Party Asset Domain)
    (h : issueCapability config adminCtx store grant = .ok (id, post))
    (hold : store.lookup old = some cap) (hdead : cap.live = false) :
    authorizesId post ctx operation right old = false := by
  have hne := issueCapability_ne_existing config adminCtx store grant id old post cap h hold
  have hp := issueCapability_preserves_other config adminCtx store grant id old post h hne.symm
  simp [authorizesId, hp, hold, hdead]

end DefiKernel.Typed


## FILE lean/DefiKernel/Typed/Transition.lean sha256=73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2

import DefiKernel.Typed.Expr
import DefiKernel.Typed.Authority
import Mathlib.Tactic.Linarith

/-! Registered first-order transitions. Checks concern aggregate net effects; they do not model
intermediate debit order, consumable allowances, replay prevention, or observation truth. -/
namespace DefiKernel.Typed

structure CellDelta (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  asset : Asset
  target : CellRef Party Asset Domain asset
  amount : Expr Party Asset Domain signature (.amount asset)

structure SupplyDelta (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  domain : Domain
  asset : Asset
  amount : Expr Party Asset Domain signature (.amount asset)

structure Template (Party Asset Domain : Type) where
  signature : List (Unit Asset)
  domain : Domain
  partyArity : Nat
  guard : Expr Party Asset Domain signature .bool
  deltas : List (CellDelta Party Asset Domain signature)
  supplyDeltas : List (SupplyDelta Party Asset Domain signature)
  stateReads : List (PackedCellRef Party Asset Domain)
  envReads : List (EnvRead Domain)
  writes : List (PackedCellRef Party Asset Domain)

abbrev Registry (Party Asset Domain : Type) := OperationId → Option (Template Party Asset Domain)

/-- Issuance and execution use the same trusted registry to determine the operation domain. -/
def registryAuthorityConfig {Party Asset Domain : Type} (registry : Registry Party Asset Domain)
    (domainAdmin : Domain → Party) : AuthorityConfig Party Domain :=
  ⟨domainAdmin, fun operation ↦ (registry operation).map Template.domain⟩

structure Request (Party Asset Domain : Type) where
  operation : OperationId
  parties : List Party
  arguments : List (PackedValue Asset)
  capabilityIds : List CapabilityId
  claimedActor : Option Party := none

inductive Refusal where
  | unknownOperation
  | actorMismatch
  | domainMismatch
  | partyArity
  | evaluation (reason : EvalFailure)
  | unauthorizedInvoke
  | guard
  | stateReadFootprint
  | envReadFootprint
  | crossDomain
  | unauthorizedDebit
  | unauthorizedSupply
  | insufficientFunds
  | accounting
  | writeFootprint
  deriving DecidableEq, Repr

/-- Internal evaluated data; caller requests cannot supply this record to `execute`. -/
structure Evaluated (Party Asset Domain : Type) where
  guard : Bool
  deltas : List (Cell Party Asset Domain × ℚ)
  supplies : List ((Domain × Asset) × ℚ)
  requiredStateReads : List (Cell Party Asset Domain)
  requiredEnvReads : List (EnvRead Domain)
  declaredStateReads : List (Cell Party Asset Domain)
  declaredEnvReads : List (EnvRead Domain)
  writes : List (Cell Party Asset Domain)

structure ExecutionResult (Party Asset Domain : Type) where
  state : State Party Asset Domain
  capabilities : CapabilityStore Party Asset Domain

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def Template.requiredStateReads (template : Template Party Asset Domain) :=
  template.guard.stateReads ++ template.deltas.flatMap (fun d ↦ d.amount.stateReads) ++
    template.supplyDeltas.flatMap (fun d ↦ d.amount.stateReads)

def Template.requiredEnvReads (template : Template Party Asset Domain) :=
  template.guard.envReads ++ template.deltas.flatMap (fun d ↦ d.amount.envReads) ++
    template.supplyDeltas.flatMap (fun d ↦ d.amount.envReads)

def resolveRefs (caller : Party) (parties : List Party)
    (refs : List (PackedCellRef Party Asset Domain)) :
    Except EvalFailure (List (Cell Party Asset Domain)) :=
  refs.mapM (fun ref ↦ ref.2.resolve caller parties)

def Template.evaluate (template : Template Party Asset Domain)
    (ctx : EvalContext Party Asset Domain template.signature) :
    Except EvalFailure (Evaluated Party Asset Domain) := do
  let required ← resolveRefs ctx.caller ctx.parties template.requiredStateReads
  let declared ← resolveRefs ctx.caller ctx.parties template.stateReads
  let writes ← resolveRefs ctx.caller ctx.parties template.writes
  let guard ← template.guard.eval ctx
  let deltas ← template.deltas.mapM fun d ↦ do
    let cell ← d.target.resolve ctx.caller ctx.parties
    let amount ← d.amount.eval ctx
    return (cell, amount)
  let supplies ← template.supplyDeltas.mapM fun d ↦ do
    let amount ← d.amount.eval ctx
    return ((d.domain, d.asset), amount)
  return ⟨guard, deltas, supplies, required, template.requiredEnvReads, declared,
    template.envReads, writes⟩

/-- Every repeated entry contributes by addition, including repeated supply changes. -/
def Evaluated.effect (evaluated : Evaluated Party Asset Domain)
    (cell : Cell Party Asset Domain) : ℚ :=
  (evaluated.deltas.map (fun d ↦ if d.1 = cell then d.2 else 0)).sum

def Evaluated.supply (evaluated : Evaluated Party Asset Domain)
    (domain : Domain) (asset : Asset) : ℚ :=
  (evaluated.supplies.map (fun d ↦ if d.1 = (domain, asset) then d.2 else 0)).sum

variable [Fintype Party] [Fintype Asset] [Fintype Domain]

def Evaluated.stateReadsOK (e : Evaluated Party Asset Domain) : Bool :=
  e.requiredStateReads.all (fun c ↦ decide (c ∈ e.declaredStateReads))

def Evaluated.envReadsOK (e : Evaluated Party Asset Domain) : Bool :=
  e.requiredEnvReads.all (fun k ↦ decide (k ∈ e.declaredEnvReads))

/-- Required state reads and actual net movement stay within the invocation domain.
Environment observations may explicitly refer to other domains; their truth is adapter supplied. -/
def Evaluated.domainOK (e : Evaluated Party Asset Domain) (domain : Domain) : Bool :=
  decide ((∀ c ∈ e.requiredStateReads, c.1 = domain) ∧
    (∀ c, e.effect c ≠ 0 → c.1 = domain) ∧ ∀ d a, e.supply d a ≠ 0 → d = domain)

def Evaluated.debitsOK (e : Evaluated Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (request : Request Party Asset Domain)
    (ctx : InvocationContext Party Domain) : Bool :=
  decide (∀ c, e.effect c < 0 →
    hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true)

def Evaluated.suppliesOK (e : Evaluated Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (request : Request Party Asset Domain)
    (ctx : InvocationContext Party Domain) : Bool :=
  decide (∀ d a, e.supply d a ≠ 0 →
    hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true)

def Evaluated.accountingOK (e : Evaluated Party Asset Domain) : Bool :=
  decide (∀ d a, ∑ p, e.effect (d, p, a) = e.supply d a)

def Evaluated.writesOK (e : Evaluated Party Asset Domain) : Bool :=
  decide (∀ c, c ∉ e.writes → e.effect c = 0)

/-- All branches are computational. Only the nonnegativity witness enters the state value. -/
def applyEvaluated (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain) :
    Except Refusal (ExecutionResult Party Asset Domain) :=
  if !e.guard then .error .guard
  else if !e.stateReadsOK then .error .stateReadFootprint
  else if !e.envReadsOK then .error .envReadFootprint
  else if !e.domainOK ctx.domain then .error .crossDomain
  else if !e.debitsOK store request ctx then .error .unauthorizedDebit
  else if !e.suppliesOK store request ctx then .error .unauthorizedSupply
  else if hn : ∀ c, 0 ≤ state.balance c + e.effect c then
    if !e.accountingOK then .error .accounting
    else if !e.writesOK then .error .writeFootprint
    else .ok ⟨⟨fun c ↦ state.balance c + e.effect c, hn⟩, store⟩
  else .error .insufficientFunds

/-- Registry selection and actor/domain binding precede `Args.check`, which precedes invoke
checking. Template evaluation (including effect/supply expressions) precedes guard and footprint
checks. Successful read/domain conditions are not refused-path confidentiality guarantees. -/
def execute (registry : Registry Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) : Except Refusal (ExecutionResult Party Asset Domain) := do
  let template ← match registry request.operation with
    | none => .error .unknownOperation
    | some template => .ok template
  if request.claimedActor.isSome && request.claimedActor != some ctx.principal then
    throw .actorMismatch
  if ctx.domain != template.domain then throw .domainMismatch
  if request.parties.length != template.partyArity then throw .partyArity
  let args ← (Args.check template.signature request.arguments).mapError Refusal.evaluation
  if !hasAuthority store request.capabilityIds ctx request.operation .invoke then
    throw .unauthorizedInvoke
  let evaluated ← (template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩)
    |>.mapError Refusal.evaluation
  applyEvaluated store ctx request state evaluated

/-- Logical view of the actual checks; this does not construct executable states. -/
def Evaluated.Valid (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain) : Prop :=
  e.guard = true ∧ e.stateReadsOK = true ∧ e.envReadsOK = true ∧
  e.domainOK ctx.domain = true ∧ e.debitsOK store request ctx = true ∧
  e.suppliesOK store request ctx = true ∧ (∀ c, 0 ≤ state.balance c + e.effect c) ∧
  e.accountingOK = true ∧ e.writesOK = true

variable (registry : Registry Party Asset Domain) (store : CapabilityStore Party Asset Domain)
variable (ctx : InvocationContext Party Domain) (env : Environment Asset Domain) (now : Nat)
variable (request : Request Party Asset Domain) (state : State Party Asset Domain)
variable (post : ExecutionResult Party Asset Domain)

-- BEGIN PROOFS

theorem applyEvaluated_ok_iff (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain) :
    applyEvaluated store ctx request state e = .ok post ↔
      e.Valid store ctx request state ∧ post.capabilities = store ∧
      ∀ c, post.state.balance c = state.balance c + e.effect c := by
  rcases post with ⟨⟨balance, nonneg⟩, capabilities⟩
  unfold applyEvaluated
  split_ifs <;> simp_all [Evaluated.Valid, funext_iff]
  aesop

/-- Success binds the selected template, typed arguments and actual evaluation result to all
checks and the exact post-state. No caller-supplied validity certificate occurs here. -/
theorem execute_ok_iff (registry : Registry Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (post : ExecutionResult Party Asset Domain) :
    execute registry store ctx env now request state = .ok post ↔
      ∃ template, registry request.operation = some template ∧
      (request.claimedActor = none ∨ request.claimedActor = some ctx.principal) ∧
      ctx.domain = template.domain ∧ request.parties.length = template.partyArity ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      hasAuthority store request.capabilityIds ctx request.operation .invoke = true ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
      e.Valid store ctx request state ∧ post.capabilities = store ∧
      ∀ c, post.state.balance c = state.balance c + e.effect c := by
  unfold execute
  cases hr : registry request.operation with
  | none => simp [bind, Except.bind]
  | some template =>
    simp only [bind, Except.bind, Option.some.injEq, exists_eq_left']
    cases hc : request.claimedActor <;>
      simp only [Option.isSome, Bool.false_and, Bool.true_and] <;>
      split_ifs <;> simp_all [throw, throwThe]
    all_goals
      cases ha : Args.check template.signature request.arguments <;>
        simp_all [Except.mapError]
    all_goals
      rename_i args
      cases he : template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ <;>
        simp_all [applyEvaluated_ok_iff]

theorem applyEvaluated_accounting (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post) (d : Domain) (a : Asset) :
    total post.state d a = total state d a + e.supply d a := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have ha : ∀ d a, ∑ p, e.effect (d, p, a) = e.supply d a :=
    of_decide_eq_true hv.2.2.2.2.2.2.2.1
  simp only [total, hu, Finset.sum_add_distrib, ha]

theorem applyEvaluated_locality (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post)
    (c : Cell Party Asset Domain) (hc : c ∉ e.writes) :
    post.state.balance c = state.balance c := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have hw : ∀ c, c ∉ e.writes → e.effect c = 0 :=
    of_decide_eq_true hv.2.2.2.2.2.2.2.2
  simp [hu, hw c hc]

theorem applyEvaluated_debit_authority (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post)
    (c : Cell Party Asset Domain) (hc : post.state.balance c < state.balance c) :
    hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have hd : ∀ c, e.effect c < 0 →
      hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true :=
    of_decide_eq_true hv.2.2.2.2.1
  apply hd c
  rw [hu] at hc
  linarith

theorem applyEvaluated_supply_authority (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post) (d : Domain) (a : Asset)
    (hc : total post.state d a ≠ total state d a) :
    hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true := by
  obtain ⟨hv, _, _⟩ := (applyEvaluated_ok_iff ..).mp h
  have hs : ∀ d a, e.supply d a ≠ 0 →
      hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true :=
    of_decide_eq_true hv.2.2.2.2.2.1
  apply hs d a
  intro hz
  exact hc (by simpa [hz] using applyEvaluated_accounting store ctx request state e post h d a)

/-- Every successful execution has a selected registered template and a checked evaluation
whose concrete application produced the post-state. -/
theorem execute_evaluated
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        applyEvaluated store ctx request state e = .ok post := by
  obtain ⟨t, ht, _, _, _, args, ha, _, e, he, hv, hcap, hu⟩ := (execute_ok_iff ..).mp h
  exact ⟨t, ht, args, ha, e, he, (applyEvaluated_ok_iff ..).mpr ⟨hv, hcap, hu⟩⟩

theorem execute_preserves_capabilities
    (h : execute registry store ctx env now request state = .ok post) :
    post.capabilities = store := by
  obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hcap, _⟩ := (execute_ok_iff ..).mp h
  exact hcap

theorem execute_nonnegative
    (h : execute registry store ctx env now request state = .ok post) :
    ∀ c, 0 ≤ post.state.balance c := by
  obtain ⟨_, _, _, _, _, _, _, _, e, _, hv, _, hu⟩ := (execute_ok_iff ..).mp h
  intro c
  rw [hu]
  exact hv.2.2.2.2.2.2.1 c

theorem execute_invocation_authority
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .invoke := by
  obtain ⟨_, _, _, _, _, _, _, hi, _⟩ := (execute_ok_iff ..).mp h
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_debit_authority
    (h : execute registry store ctx env now request state = .ok post)
    (c : Cell Party Asset Domain) (hc : post.state.balance c < state.balance c) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .debit c := by
  obtain ⟨_, _, _, _, e, _, he⟩ := execute_evaluated registry store ctx env now request state post h
  have hi := applyEvaluated_debit_authority store ctx request state e post he c hc
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_supply_authority
    (h : execute registry store ctx env now request state = .ok post) (d : Domain) (a : Asset)
    (hc : total post.state d a ≠ total state d a) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧
      cap.right = .changeSupply d a := by
  obtain ⟨_, _, _, _, e, _, he⟩ := execute_evaluated registry store ctx env now request state post h
  have hi := applyEvaluated_supply_authority store ctx request state e post he d a hc
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_accounting_and_locality
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        (∀ d a, total post.state d a = total state d a + e.supply d a) ∧
        (∀ c, c ∉ e.writes → post.state.balance c = state.balance c) := by
  obtain ⟨t, ht, args, ha, e, he, happly⟩ :=
    execute_evaluated registry store ctx env now request state post h
  exact ⟨t, ht, args, ha, e, he,
    applyEvaluated_accounting store ctx request state e post happly,
    applyEvaluated_locality store ctx request state e post happly⟩

/-- Successfully recorded reads are declared and domain-local, and all changed balances stay
in the authenticated invocation domain. -/
theorem execute_reads_and_domain
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ctx.domain = template.domain ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        (∀ c ∈ e.requiredStateReads, c ∈ e.declaredStateReads ∧ c.1 = ctx.domain) ∧
        (∀ k ∈ e.requiredEnvReads, k ∈ e.declaredEnvReads) ∧
        (∀ c, post.state.balance c ≠ state.balance c → c.1 = ctx.domain) := by
  obtain ⟨t, ht, _, hd, _, args, ha, _, e, he, hv, _, hu⟩ := (execute_ok_iff ..).mp h
  have hs : ∀ c ∈ e.requiredStateReads, c ∈ e.declaredStateReads := by
    simpa [Evaluated.stateReadsOK] using hv.2.1
  have hen : ∀ k ∈ e.requiredEnvReads, k ∈ e.declaredEnvReads := by
    simpa [Evaluated.envReadsOK] using hv.2.2.1
  have hdom : (∀ c ∈ e.requiredStateReads, c.1 = ctx.domain) ∧
      (∀ c, e.effect c ≠ 0 → c.1 = ctx.domain) ∧
      ∀ d a, e.supply d a ≠ 0 → d = ctx.domain := of_decide_eq_true hv.2.2.2.1
  refine ⟨t, ht, hd, args, ha, e, he, ?_, hen, ?_⟩
  · exact fun c hc ↦ ⟨hs c hc, hdom.1 c hc⟩
  · intro c hc
    apply hdom.2.1 c
    intro hz
    exact hc (by simp [hu, hz])

omit [Fintype Party] [Fintype Asset] [Fintype Domain] in
theorem Evaluated.effect_cons (e : Evaluated Party Asset Domain)
    (entry : Cell Party Asset Domain × ℚ) (c : Cell Party Asset Domain) :
    ({ e with deltas := entry :: e.deltas } : Evaluated Party Asset Domain).effect c =
      (if entry.1 = c then entry.2 else 0) + e.effect c := by
  simp [Evaluated.effect]

omit [DecidableEq Party] [Fintype Party] [Fintype Asset] [Fintype Domain] in
theorem Evaluated.supply_cons (e : Evaluated Party Asset Domain)
    (entry : (Domain × Asset) × ℚ) (d : Domain) (a : Asset) :
    ({ e with supplies := entry :: e.supplies } : Evaluated Party Asset Domain).supply d a =
      (if entry.1 = (d, a) then entry.2 else 0) + e.supply d a := by
  simp [Evaluated.supply]

end DefiKernel.Typed


## FILE lean/DefiKernel/Typed/Examples.lean sha256=640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41

import DefiKernel.Typed.Transition

/-! Registered reference financial libraries. Exact rates and declared locked collateral are
model assumptions, not deployed-contract fidelity or market-solvency claims. -/
namespace DefiKernel.Typed
namespace Examples

inductive Party where
  | alice | bob | vault | pool
  deriving DecidableEq, Repr

inductive Asset where
  | usd | share | collateral | debt
  deriving DecidableEq, Repr

inductive Domain where
  | main | other
  deriving DecidableEq, Repr

instance : Fintype Party := ⟨{.alice, .bob, .vault, .pool}, by
  intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .share, .collateral, .debt}, by
  intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.main, .other}, by intro d; cases d <;> simp⟩

abbrev Ledger := State Party Asset Domain
abbrev Store := CapabilityStore Party Asset Domain
abbrev Op := Template Party Asset Domain
abbrev Call := Request Party Asset Domain
abbrev Result := ExecutionResult Party Asset Domain
abbrev E (signature : List (Unit Asset)) := Expr Party Asset Domain signature

/-- Original reference balances on main; every other-domain balance is zero. -/
def initial : Ledger where
  balance c := match c with
    | (.main, .alice, .usd) => 10
    | (.main, .alice, .share) => 4
    | (.main, .alice, .collateral) => 10
    | (.main, .alice, .debt) => 2
    | (.main, .vault, .usd) => 20
    | (.main, .pool, .usd) => 100
    | _ => 0
  nonneg c := by
    rcases c with ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> decide

def ref (a : Asset) (owner : PartyRef Party) : CellRef Party Asset Domain a :=
  ⟨.main, owner⟩

def packedRef (a : Asset) (owner : PartyRef Party) : PackedCellRef Party Asset Domain :=
  ⟨a, ref a owner⟩

def allGuards {signature : List (Unit Asset)} : List (E signature .bool) → E signature .bool
  | [] => .lit true
  | g :: gs => .binary .and g (allGuards gs)

def nonnegative {signature : List (Unit Asset)} (a : Asset)
    (q : E signature (.amount a)) : E signature .bool :=
  .binary (.le (.amount a)) (.lit 0) q

def negate {signature : List (Unit Asset)} (a : Asset)
    (q : E signature (.amount a)) : E signature (.amount a) :=
  .unary (.neg (.amount a)) q

def usdSignature : List (Unit Asset) := [.amount .usd]
def shareSignature : List (Unit Asset) := [.amount .share]
def usdQuantity : E usdSignature (.amount .usd) := .arg .here
def shareQuantity : E shareSignature (.amount .share) := .arg .here

/-- Registered USD movement; zero and self transfer retain net-effect semantics. -/
def transfer : Op where
  signature := usdSignature
  domain := .main
  partyArity := 1
  guard := nonnegative .usd usdQuantity
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.argument 0), usdQuantity⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef .usd .caller, packedRef .usd (.argument 0)]

/-- Two USD per share is a dimensioned library price, not a unit-changing scalar. -/
def mintedShares : E usdSignature (.amount .share) :=
  .binary (.unconvert Asset.share Asset.usd) usdQuantity (.lit 2)

def deposit : Op where
  signature := usdSignature
  domain := .main
  partyArity := 0
  guard := nonnegative .usd usdQuantity
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.literal .vault), usdQuantity⟩,
    ⟨.share, ref .share .caller, mintedShares⟩]
  supplyDeltas := [⟨.main, .share, mintedShares⟩]
  stateReads := []
  envReads := []
  writes := [packedRef .usd .caller, packedRef .usd (.literal .vault), packedRef .share .caller]

def redeemedUsd : E shareSignature (.amount .usd) :=
  .binary (.convert Asset.share Asset.usd) shareQuantity (.lit 2)

def withdraw : Op where
  signature := shareSignature
  domain := .main
  partyArity := 0
  guard := nonnegative .share shareQuantity
  deltas := [⟨.usd, ref .usd (.literal .vault), negate .usd redeemedUsd⟩,
    ⟨.usd, ref .usd .caller, redeemedUsd⟩,
    ⟨.share, ref .share .caller, negate .share shareQuantity⟩]
  supplyDeltas := [⟨.main, .share, negate .share shareQuantity⟩]
  stateReads := []
  envReads := []
  writes := [packedRef .usd (.literal .vault), packedRef .usd .caller, packedRef .share .caller]

def priceKey : ObservationKey Domain := ⟨.main, ⟨7⟩⟩
def collateralPrice : E usdSignature (.price .collateral .usd) := .observe ⟨priceKey⟩

/-- One USD per debt token is the reference denomination, explicitly dimensioned. -/
def mintedDebt : E usdSignature (.amount .debt) :=
  .binary (.unconvert Asset.debt Asset.usd) usdQuantity (.lit 1)

def debtValue : E usdSignature (.amount .usd) :=
  .binary (.convert Asset.debt Asset.usd)
    (.binary (.add (.amount Asset.debt)) (.balance (ref .debt .caller)) mintedDebt) (.lit 1)

def collateralValue : E usdSignature (.amount .usd) :=
  .binary (.convert Asset.collateral Asset.usd) (.balance (ref .collateral .caller)) collateralPrice

def borrowGuard : E usdSignature .bool := allGuards [
  nonnegative .usd usdQuantity,
  .binary (.lt (.price Asset.collateral Asset.usd)) (.lit 0) collateralPrice,
  .binary (.le .scalar) (.timestamp priceKey) .now,
  .binary (.le .scalar) .now (.binary (.add .scalar) (.timestamp priceKey) (.lit 5)),
  .binary (.le (.amount Asset.usd))
    (.binary (.scale (.amount Asset.usd)) (.lit 2) debtValue) collateralValue]

def borrow : Op where
  signature := usdSignature
  domain := .main
  partyArity := 0
  guard := borrowGuard
  deltas := [⟨.usd, ref .usd (.literal .pool), negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd .caller, usdQuantity⟩,
    ⟨.debt, ref .debt .caller, mintedDebt⟩]
  supplyDeltas := [⟨.main, .debt, mintedDebt⟩]
  stateReads := [packedRef .debt .caller, packedRef .collateral .caller]
  envReads := [.observation priceKey, .currentTime]
  writes := [packedRef .usd (.literal .pool), packedRef .usd .caller, packedRef .debt .caller]

def transferId : OperationId := ⟨0⟩
def depositId : OperationId := ⟨1⟩
def withdrawId : OperationId := ⟨2⟩
def borrowId : OperationId := ⟨3⟩

def registry : Registry Party Asset Domain := fun id ↦ match id.value with
  | 0 => some transfer
  | 1 => some deposit
  | 2 => some withdraw
  | 3 => some borrow
  | _ => none

/-- Vault is the fixture's administrative principal; this does not move ledger balances. -/
def domainAdmin : Domain → Party := fun _ ↦ .vault
def authorityConfig : AuthorityConfig Party Domain := registryAuthorityConfig registry domainAdmin
def adminContext : InvocationContext Party Domain := ⟨.vault, .main⟩
def aliceContext : InvocationContext Party Domain := ⟨.alice, .main⟩
def bobContext : InvocationContext Party Domain := ⟨.bob, .main⟩

def grant (operation : OperationId) (right : Right Party Asset Domain) : Grant Party Asset Domain :=
  ⟨.alice, .main, operation, right⟩

/-- Every operation has its own invocation and exact resource grants. -/
def grants : List (Grant Party Asset Domain) := [
  grant transferId .invoke, grant transferId (.debit (.main, .alice, .usd)),
  grant depositId .invoke, grant depositId (.debit (.main, .alice, .usd)),
  grant depositId (.changeSupply .main .share),
  grant withdrawId .invoke, grant withdrawId (.debit (.main, .vault, .usd)),
  grant withdrawId (.debit (.main, .alice, .share)), grant withdrawId (.changeSupply .main .share),
  grant borrowId .invoke, grant borrowId (.debit (.main, .pool, .usd)),
  grant borrowId (.changeSupply .main .debt)]

def issueGrants (store : Store) : List (Grant Party Asset Domain) → Except AuthorityFailure Store
  | [] => .ok store
  | g :: gs => do
    let (_, next) ← issueCapability authorityConfig adminContext store g
    issueGrants next gs

/-- Provisioning failure is propagated; execution never substitutes a fabricated store. -/
def provisioned : Except AuthorityFailure Store := issueGrants .empty grants
def allCapabilityIds : List CapabilityId := (List.range grants.length).map CapabilityId.mk

def transferRequest (q : ℚ) (recipient : Party := .bob) : Call :=
  ⟨transferId, [recipient], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def depositRequest (q : ℚ) : Call :=
  ⟨depositId, [], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def withdrawRequest (q : ℚ) : Call :=
  ⟨withdrawId, [], [⟨.amount .share, q⟩], allCapabilityIds, none⟩
def borrowRequest (q : ℚ) : Call :=
  ⟨borrowId, [], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩

/-- Supplying a different feed creates a different key; it cannot replace feed seven. -/
def oracle (feed : Nat) (price : ℚ) (observedAt : Nat) : Environment Asset Domain := fun key ↦
  if key = ⟨.main, ⟨feed⟩⟩ then some ⟨⟨.price .collateral .usd, price⟩, observedAt⟩ else none

def fresh : Environment Asset Domain := oracle 7 2 98

inductive ReferenceFailure where
  | authority (reason : AuthorityFailure)
  | execution (reason : Refusal)
  deriving DecidableEq, Repr

def runWith (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger := initial) :
    Except ReferenceFailure Result :=
  (execute registry store ctx env now request state).mapError .execution

def run (request : Call) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext fresh 100 request

def runOracle (env : Environment Asset Domain) (now : Nat) (request : Call) :
    Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext env now request

def runContext (ctx : InvocationContext Party Domain) (request : Call) :
    Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store ctx fresh 100 request

def runRevoked (id : CapabilityId) (request : Call) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  let revoked ← (revokeCapability authorityConfig adminContext store id).mapError .authority
  runWith revoked aliceContext fresh 100 request

def allCells : List (Cell Party Asset Domain) :=
  [Domain.main, .other].flatMap fun d ↦ [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
    [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)

def observe (result : Except ReferenceFailure Result) : Except ReferenceFailure (List ℚ) :=
  result.map fun post ↦ allCells.map post.state.balance

end Examples

-- BEGIN PROOFS

namespace Examples

theorem allCells_complete (cell : Cell Party Asset Domain) : cell ∈ allCells := by
  rcases cell with ⟨d, p, a⟩
  cases d <;> cases p <;> cases a <;> decide

theorem allCells_nodup : allCells.Nodup := by decide

end Examples
end DefiKernel.Typed


## EVIDENCE review/semantic-kernel/sprint5/build-verification.json sha256=bebda74d0554e3bc1ac17ea71544653d788fc08c14084888a9cf29b0d0227379

{
  "sources": {
    "lean/DefiKernel/Composition/Tests.lean": "4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980",
    "lean/DefiKernel/Composition/Execution.lean": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
    "lean/DefiKernel/Composition/InterfaceTests.lean": "710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3",
    "lean/DefiKernel/Composition/Examples.lean": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
    "lean/DefiKernel/Composition/ExecutionTests.lean": "68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5",
    "lean/DefiKernel/Composition/Preservation.lean": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
    "lean/DefiKernel/Composition/Interfaces.lean": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
    "lean/DefiKernel/Composition/Contracts.lean": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
    "lean/DefiKernel/Composition/Sequence.lean": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
    "lean/DefiKernel/Composition/Audit.lean": "fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2",
    "lean/DefiKernel/Composition/Verify.lean": "0510c92489398990f07a614f5d8d9228db05220fcf66297afe8a20cb078a4fdb",
    "lean/DefiKernel.lean": "00378bd05ac77e3f3d4603a753ebf5ae5aaf0f2063fc9651fe05d4c31997f9e2"
  },
  "runs": [
    {
      "label": "final-build",
      "command": [
        "lake",
        "build"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "6be667b9902f1d44e3db63fa5dae24b8b2425c625848bd9691c96e925ac81536"
    },
    {
      "label": "final-runtime",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Composition/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "9173b87109f8c6c3f6afae01958f1480d84a8ec42cd34429f56aa077b1a89368"
    },
    {
      "label": "final-axioms",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Composition/Verify.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "56e39dbb1623f32c71599b0a70c3a9b7752319ccacadac71b2ac95565ef31fe0"
    },
    {
      "label": "final-typed-runtime",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Typed/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "19ecc53feba3fbe993b6f2fed294efb170716f6b5a555a4d34bd1bad7f05af1e"
    },
    {
      "label": "final-typed-axioms",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Typed/Verify.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "0fd188b353c6f014bebb5baaf53447f2660a07619fe2236eca91e9eaa5d24790"
    },
    {
      "label": "final-legacy-runtime",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "61819efaae5d9062231e6dd3e126b3ce93cfb225cdbbdc8498d630f568cbbe63"
    },
    {
      "label": "final-contract-runtime",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/ContractAudit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "660f556e96037016023e457e37f692acf9e3ff0f16072fcc271511537494e438"
    },
    {
      "label": "final-legacy-axioms",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/VerifyAxioms.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "4fe1669dcec9ff26f7626f3a2125aea61719fe3b8c25e8eff385457b54553c8f"
    }
  ],
  "input_sources_unchanged": true
}


## EVIDENCE review/semantic-kernel/sprint5/mutation-spec.json sha256=b91a3e491bbd2ddeb3e0e72ee23622a3923db33aa0db5952b14e2831f78d5cb1

{
  "schema_version": 1,
  "modules": [
    "DefiKernel.Composition.Interfaces",
    "DefiKernel.Composition.Contracts",
    "DefiKernel.Composition.Execution",
    "DefiKernel.Composition.Sequence",
    "DefiKernel.Composition.Preservation",
    "DefiKernel.Composition.Examples",
    "DefiKernel.Composition.InterfaceTests",
    "DefiKernel.Composition.ExecutionTests",
    "DefiKernel.Composition.Tests",
    "DefiKernel.Composition.Audit"
  ],
  "positive_checks": [
    "interface.valid",
    "execution.catalog",
    "workflows.catalog",
    "execution.transfer.receipt.snapshots",
    "interface.shared-write",
    "interface.foreign-funded-kernel-control"
  ],
  "mutations": [
    {
      "name": "reverse-order",
      "module": "DefiKernel.Composition.Sequence",
      "needle": "steps.foldl (advance cfg boundaries) cursor",
      "replacement": "steps.reverse.foldl (advance cfg boundaries) cursor",
      "required_false": [
        "workflows.transfer.deposit.withdraw",
        "workflows.order.transfer.first"
      ]
    },
    {
      "name": "drop-first-step",
      "module": "DefiKernel.Composition.Sequence",
      "needle": "steps.foldl (advance cfg boundaries) cursor",
      "replacement": "(steps.drop 1).foldl (advance cfg boundaries) cursor",
      "required_false": [
        "workflows.consecutive"
      ]
    },
    {
      "name": "continue-after-refusal",
      "module": "DefiKernel.Composition.Sequence",
      "needle": "match cursor.failure with",
      "replacement": "match (none : Option (LocatedFailure P A D)) with",
      "required_false": [
        "workflows.first.refusal",
        "workflows.resume.terminal"
      ]
    },
    {
      "name": "reset-ledger",
      "module": "DefiKernel.Composition.Sequence",
      "needle": "steps.foldl (advance cfg boundaries) cursor",
      "replacement": "steps.foldl (fun current step ↦ advance cfg boundaries\n    { current with world := { current.world with state := cursor.world.state } } step) cursor",
      "required_false": [
        "workflows.consecutive"
      ]
    },
    {
      "name": "reset-capability-store",
      "module": "DefiKernel.Composition.Sequence",
      "needle": "steps.foldl (advance cfg boundaries) cursor",
      "replacement": "steps.foldl (fun current step ↦ advance cfg boundaries\n    { current with world := { current.world with capabilities := cursor.world.capabilities } } step) cursor",
      "required_false": [
        "workflows.admin.live.repeat"
      ]
    },
    {
      "name": "omit-revocation-propagation",
      "module": "DefiKernel.Composition.Execution",
      "needle": "return ⟨⟨pre.state, store⟩, .revoked id, []⟩",
      "replacement": "return ⟨⟨pre.state, pre.capabilities⟩, .revoked id, []⟩",
      "required_false": [
        "execution.revoke.ledger.receipt",
        "workflows.admin.revocation"
      ]
    },
    {
      "name": "interface-write-bypass",
      "module": "DefiKernel.Composition.Interfaces",
      "needle": "if !(writes.all component.canWrite) then throw .writeAccess",
      "replacement": "if false then throw .writeAccess",
      "required_false": [
        "interface.foreign-write",
        "interface.readonly-write",
        "workflows.isolation.private",
        "workflows.isolation.readonly"
      ]
    },
    {
      "name": "wrong-output-index",
      "module": "DefiKernel.Composition.Interfaces",
      "needle": "decide (o.step = step ∧ o.port = port)",
      "replacement": "decide (o.step = 0 ∧ o.port = port)",
      "required_false": [
        "workflows.output.index"
      ]
    },
    {
      "name": "wrong-output-unit",
      "module": "DefiKernel.Composition.Interfaces",
      "needle": "if values.map Sigma.fst != interface.inputs.map InputPort.unit then throw .inputUnit",
      "replacement": "if false then throw .inputUnit",
      "required_false": [
        "interface.wrong-output-unit",
        "workflows.output.unit"
      ]
    },
    {
      "name": "drop-supply-receipt",
      "module": "DefiKernel.Composition.Execution",
      "needle": "return ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩",
      "replacement": "return ⟨post, .invoked request { e with supplies := [] },\n      snapshots index inv.component iface post.state⟩",
      "required_false": [
        "workflows.order.deposit.first",
        "workflows.transfer.deposit.withdraw"
      ]
    },
    {
      "name": "reset-continuation-index",
      "module": "DefiKernel.Composition.Sequence",
      "needle": "steps.foldl (advance cfg boundaries) cursor",
      "replacement": "steps.foldl (advance cfg boundaries) { cursor with nextIndex := 0 }",
      "required_false": [
        "workflows.resume.output",
        "workflows.resume.time"
      ]
    },
    {
      "name": "wrong-snapshot-index",
      "module": "DefiKernel.Composition.Interfaces",
      "needle": "⟨index, ⟨component, o.id⟩, ⟨.amount o.cell.2.2, state.balance o.cell⟩⟩",
      "replacement": "⟨0, ⟨component, o.id⟩, ⟨.amount o.cell.2.2, state.balance o.cell⟩⟩",
      "required_false": [
        "interface.snapshot-exact",
        "workflows.output.index"
      ]
    }
  ]
}


## EVIDENCE review/semantic-kernel/sprint5/mutations/summary.json sha256=c1d38d36764b8f98f11d4a75e70658dba4e6daa6d95febf75506265d9b59bb4b

{
  "schema_version": 1,
  "kind": "executed-composition-source-mutations",
  "command": {
    "command": [
      "/usr/bin/python3",
      "/home/charl/defiformal/scripts/check_composition_mutations.py",
      "--repo",
      "/home/charl/defiformal",
      "--spec",
      "/home/charl/defiformal/review/semantic-kernel/sprint5/mutation-spec.json",
      "--out",
      "/tmp/defiformal-sprint5-mutations-final-s45f0dkx/replay"
    ],
    "cwd": "/home/charl/defiformal",
    "exit": 0,
    "started_utc": "2026-09-07T03:47:58.242951+00:00",
    "finished_utc": "2026-09-07T03:51:00.346133+00:00",
    "scratch": "/tmp/defiformal-sprint5-mutations-final-s45f0dkx",
    "log_sha256": "6fa309f13e98c7abe744ac6277949144edbf5bad002feeba52330501c27dfc52"
  },
  "runner_sha256": "0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031",
  "spec_sha256": "b91a3e491bbd2ddeb3e0e72ee23622a3923db33aa0db5952b14e2831f78d5cb1",
  "git_head": "ba3661f3e875ef6c48e71300fec339d333dab697",
  "input_status": " M lean/DefiKernel/Composition/Execution.lean\n M lean/DefiKernel/Composition/InterfaceTests.lean\n M lean/DefiKernel/Composition/Interfaces.lean\n M lean/DefiKernel/Composition/Preservation.lean\n M lean/DefiKernel/Composition/Sequence.lean\n?? lean/DefiKernel/Composition/Audit.lean\n?? lean/DefiKernel/Composition/Examples.lean\n?? lean/DefiKernel/Composition/Tests.lean\n",
  "lean_version": "Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)",
  "lean_executable_sha256": "e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550",
  "sources": {
    "lean/DefiKernel/Composition/Interfaces.lean": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
    "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "lean/DefiKernel/Composition/Contracts.lean": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
    "lean/DefiKernel/Composition/Execution.lean": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
    "lean/DefiKernel/Composition/Sequence.lean": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
    "lean/DefiKernel/Composition/Preservation.lean": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
    "lean/DefiKernel/Composition/Examples.lean": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
    "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "lean/DefiKernel/Composition/InterfaceTests.lean": "710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3",
    "lean/DefiKernel/Composition/ExecutionTests.lean": "68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5",
    "lean/DefiKernel/Composition/Tests.lean": "4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980",
    "lean/DefiKernel/Composition/Audit.lean": "fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2",
    "lean/lean-toolchain": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "lean/lake-manifest.json": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
    "lean/lakefile.toml": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"
  },
  "input_sources_unchanged": true,
  "mutation_count": 12,
  "detected_mutations": 12,
  "control_comparisons": 93,
  "positive_checks": [
    "interface.valid",
    "execution.catalog",
    "workflows.catalog",
    "execution.transfer.receipt.snapshots",
    "interface.shared-write",
    "interface.foreign-funded-kernel-control"
  ],
  "mutations": [
    {
      "name": "reverse-order",
      "module": "DefiKernel.Composition.Sequence",
      "required_false": [
        "workflows.transfer.deposit.withdraw",
        "workflows.order.transfer.first"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "workflows.admin.live.repeat",
        "workflows.admin.revocation",
        "workflows.first.refusal",
        "workflows.order.deposit.first",
        "workflows.order.transfer.first",
        "workflows.output.index",
        "workflows.output.unit",
        "workflows.output.unknown",
        "workflows.resume.boundary",
        "workflows.resume.terminal",
        "workflows.resume.time",
        "workflows.resume.time.negative",
        "workflows.snapshot",
        "workflows.transfer.deposit.withdraw"
      ],
      "fixture_sha256": "6b89d4b9ee6ff682690f4634dc529205c003c4274fa238a2a00e29772e6e1c9d",
      "positive_controls_preserved": true
    },
    {
      "name": "drop-first-step",
      "module": "DefiKernel.Composition.Sequence",
      "required_false": [
        "workflows.consecutive"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "workflows.actor",
        "workflows.admin.live.repeat",
        "workflows.admin.revocation",
        "workflows.consecutive",
        "workflows.first.refusal",
        "workflows.frame.unsupported.counterexample",
        "workflows.isolation.hidden.read",
        "workflows.isolation.private",
        "workflows.isolation.readonly",
        "workflows.isolation.shared",
        "workflows.isolation.wrong.component",
        "workflows.order.deposit.first",
        "workflows.order.transfer.first",
        "workflows.output.forward",
        "workflows.output.index",
        "workflows.output.unit",
        "workflows.output.unknown",
        "workflows.resume.boundary",
        "workflows.resume.output",
        "workflows.resume.terminal",
        "workflows.resume.time",
        "workflows.resume.time.negative",
        "workflows.snapshot",
        "workflows.transfer.deposit.withdraw"
      ],
      "fixture_sha256": "65e4cb94908fab5d21e91e63461325b8531835709e27fb4e3013776285ced169",
      "positive_controls_preserved": true
    },
    {
      "name": "continue-after-refusal",
      "module": "DefiKernel.Composition.Sequence",
      "required_false": [
        "workflows.first.refusal",
        "workflows.resume.terminal"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "workflows.configuration",
        "workflows.first.refusal",
        "workflows.order.deposit.first",
        "workflows.order.transfer.first",
        "workflows.output.unit",
        "workflows.resume.terminal"
      ],
      "fixture_sha256": "a48e074f256b3ad666b92ac6330bfca3c601448e902d92e6f31066e2f60903f6",
      "positive_controls_preserved": true
    },
    {
      "name": "reset-ledger",
      "module": "DefiKernel.Composition.Sequence",
      "required_false": [
        "workflows.consecutive"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "workflows.admin.live.repeat",
        "workflows.admin.revocation",
        "workflows.consecutive",
        "workflows.order.deposit.first",
        "workflows.order.transfer.first",
        "workflows.output.index",
        "workflows.output.unit",
        "workflows.output.unknown",
        "workflows.resume.boundary",
        "workflows.resume.terminal",
        "workflows.resume.time",
        "workflows.snapshot",
        "workflows.transfer.deposit.withdraw"
      ],
      "fixture_sha256": "805038a0aa344e9fe967e19d8ae928b82fef26f3f41c3b5b8721089fbd14f934",
      "positive_controls_preserved": true
    },
    {
      "name": "reset-capability-store",
      "module": "DefiKernel.Composition.Sequence",
      "required_false": [
        "workflows.admin.live.repeat"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "workflows.admin.live.repeat",
        "workflows.admin.revocation",
        "workflows.resume.boundary",
        "workflows.resume.time",
        "workflows.resume.time.negative"
      ],
      "fixture_sha256": "88ce2aea430579925bdd82b18738c3af416a7f80d0e5f924f258bc1c40906e5d",
      "positive_controls_preserved": true
    },
    {
      "name": "omit-revocation-propagation",
      "module": "DefiKernel.Composition.Execution",
      "required_false": [
        "execution.revoke.ledger.receipt",
        "workflows.admin.revocation"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "execution.revoke.ledger.receipt",
        "workflows.admin.revocation"
      ],
      "fixture_sha256": "8fdb4f6291255a691047a6ef5e621b40bb788f59fe9f1a887008f4a4414f63cd",
      "positive_controls_preserved": true
    },
    {
      "name": "interface-write-bypass",
      "module": "DefiKernel.Composition.Interfaces",
      "required_false": [
        "interface.foreign-write",
        "interface.readonly-write",
        "workflows.isolation.private",
        "workflows.isolation.readonly"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "interface.actual-target",
        "interface.declared-write",
        "interface.foreign-write",
        "interface.readonly-write",
        "workflows.isolation.private",
        "workflows.isolation.readonly"
      ],
      "fixture_sha256": "468808139972628a0e0152a57d47a921217c0afe0d7545e0a3342d738f99030d",
      "positive_controls_preserved": true
    },
    {
      "name": "wrong-output-index",
      "module": "DefiKernel.Composition.Interfaces",
      "required_false": [
        "workflows.output.index"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "interface.snapshot-binding",
        "interface.wrong-output-unit",
        "workflows.output.index",
        "workflows.resume.boundary",
        "workflows.resume.time",
        "workflows.resume.time.negative"
      ],
      "fixture_sha256": "5e7f9c39a5b30ff550481611daa8f90023e0cc6369aa3d1f3e60ce008863c949",
      "positive_controls_preserved": true
    },
    {
      "name": "wrong-output-unit",
      "module": "DefiKernel.Composition.Interfaces",
      "required_false": [
        "interface.wrong-output-unit",
        "workflows.output.unit"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "execution.binding.unit",
        "interface.wrong-output-unit",
        "interface.wrong-unit",
        "workflows.output.unit"
      ],
      "fixture_sha256": "147e72de3a68c9b3ab2e59524e403dac0f13dd427bb310d23f4867c518695e31",
      "positive_controls_preserved": true
    },
    {
      "name": "drop-supply-receipt",
      "module": "DefiKernel.Composition.Execution",
      "required_false": [
        "workflows.order.deposit.first",
        "workflows.transfer.deposit.withdraw"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "workflows.isolation.shared",
        "workflows.order.deposit.first",
        "workflows.output.index",
        "workflows.output.unit",
        "workflows.resume.boundary",
        "workflows.resume.output",
        "workflows.resume.terminal",
        "workflows.resume.time",
        "workflows.snapshot",
        "workflows.transfer.deposit.withdraw"
      ],
      "fixture_sha256": "6257f3bc647264e259bf2166e9fd66b12e785b84e0054a6d6d874bbcba179efb",
      "positive_controls_preserved": true
    },
    {
      "name": "reset-continuation-index",
      "module": "DefiKernel.Composition.Sequence",
      "required_false": [
        "workflows.resume.output",
        "workflows.resume.time"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "workflows.resume.boundary",
        "workflows.resume.output",
        "workflows.resume.terminal",
        "workflows.resume.time",
        "workflows.resume.time.negative"
      ],
      "fixture_sha256": "d0c8a9841287ee50685dd7d53387433545baa26dfb2968be51e0d131b6fce614",
      "positive_controls_preserved": true
    },
    {
      "name": "wrong-snapshot-index",
      "module": "DefiKernel.Composition.Interfaces",
      "required_false": [
        "interface.snapshot-exact",
        "workflows.output.index"
      ],
      "exit": 1,
      "comparisons": 93,
      "false_comparisons": [
        "interface.snapshot-exact",
        "workflows.admin.live.repeat",
        "workflows.admin.revocation",
        "workflows.consecutive",
        "workflows.output.index",
        "workflows.resume.boundary",
        "workflows.resume.output",
        "workflows.resume.time",
        "workflows.resume.time.negative",
        "workflows.snapshot",
        "workflows.transfer.deposit.withdraw"
      ],
      "fixture_sha256": "e5de19fe08d05e45fba49d2a00ad9f413fc3ffe05a7254ed1a57bd037efce477",
      "positive_controls_preserved": true
    }
  ],
  "scope": "Bounded development comparisons over fresh actual Composition source mutants. No compilation failure is a semantic detection. No general proof claim."
}


## EVIDENCE review/semantic-kernel/sprint5/mutations/command.json sha256=13404d68901ee0263de5896557d99cb332f0e8ebfddcbaf4aff5bf2a68ba72a2

{
  "command": [
    "/usr/bin/python3",
    "/home/charl/defiformal/scripts/check_composition_mutations.py",
    "--repo",
    "/home/charl/defiformal",
    "--spec",
    "/home/charl/defiformal/review/semantic-kernel/sprint5/mutation-spec.json",
    "--out",
    "/tmp/defiformal-sprint5-mutations-final-s45f0dkx/replay"
  ],
  "cwd": "/home/charl/defiformal",
  "exit": 0,
  "started_utc": "2026-09-07T03:47:58.242951+00:00",
  "finished_utc": "2026-09-07T03:51:00.346133+00:00",
  "scratch": "/tmp/defiformal-sprint5-mutations-final-s45f0dkx",
  "log_sha256": "6fa309f13e98c7abe744ac6277949144edbf5bad002feeba52330501c27dfc52"
}


## EVIDENCE review/semantic-kernel/sprint5/mutations/source-manifest.json sha256=3cedac0ef60222f9a32e1dbcaf3b0948a2c7f352d1e4a5c4819eeb6f27d495fe

{
  "sources": {
    "lean/DefiKernel/Composition/Interfaces.lean": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
    "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "lean/DefiKernel/Composition/Contracts.lean": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
    "lean/DefiKernel/Composition/Execution.lean": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
    "lean/DefiKernel/Composition/Sequence.lean": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
    "lean/DefiKernel/Composition/Preservation.lean": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
    "lean/DefiKernel/Composition/Examples.lean": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
    "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "lean/DefiKernel/Composition/InterfaceTests.lean": "710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3",
    "lean/DefiKernel/Composition/ExecutionTests.lean": "68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5",
    "lean/DefiKernel/Composition/Tests.lean": "4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980",
    "lean/DefiKernel/Composition/Audit.lean": "fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2",
    "lean/lean-toolchain": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "lean/lake-manifest.json": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
    "lean/lakefile.toml": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"
  },
  "script_sha256": "0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031",
  "spec_sha256": "b91a3e491bbd2ddeb3e0e72ee23622a3923db33aa0db5952b14e2831f78d5cb1",
  "git_head": "ba3661f3e875ef6c48e71300fec339d333dab697",
  "input_status": " M lean/DefiKernel/Composition/Execution.lean\n M lean/DefiKernel/Composition/InterfaceTests.lean\n M lean/DefiKernel/Composition/Interfaces.lean\n M lean/DefiKernel/Composition/Preservation.lean\n M lean/DefiKernel/Composition/Sequence.lean\n?? lean/DefiKernel/Composition/Audit.lean\n?? lean/DefiKernel/Composition/Examples.lean\n?? lean/DefiKernel/Composition/Tests.lean\n",
  "lean_version": "Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)",
  "lean_executable_sha256": "e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550",
  "scope": "Fresh local dependency source closure; Composition proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.",
  "projection_order": [
    "DefiKernel.Typed.Types",
    "DefiKernel.Typed.Expr",
    "DefiKernel.Typed.Authority",
    "DefiKernel.Typed.Transition",
    "DefiKernel.Composition.Interfaces",
    "DefiKernel.Composition.Contracts",
    "DefiKernel.Composition.Execution",
    "DefiKernel.Composition.Sequence",
    "DefiKernel.Composition.Preservation",
    "DefiKernel.Typed.Examples",
    "DefiKernel.Composition.Examples",
    "DefiKernel.Composition.InterfaceTests",
    "DefiKernel.Composition.ExecutionTests",
    "DefiKernel.Composition.Tests",
    "DefiKernel.Composition.Audit"
  ],
  "sources_after": {
    "lean/DefiKernel/Composition/Interfaces.lean": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
    "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "lean/DefiKernel/Composition/Contracts.lean": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
    "lean/DefiKernel/Composition/Execution.lean": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
    "lean/DefiKernel/Composition/Sequence.lean": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
    "lean/DefiKernel/Composition/Preservation.lean": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
    "lean/DefiKernel/Composition/Examples.lean": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
    "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "lean/DefiKernel/Composition/InterfaceTests.lean": "710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3",
    "lean/DefiKernel/Composition/ExecutionTests.lean": "68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5",
    "lean/DefiKernel/Composition/Tests.lean": "4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980",
    "lean/DefiKernel/Composition/Audit.lean": "fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2",
    "lean/lean-toolchain": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "lean/lake-manifest.json": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
    "lean/lakefile.toml": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86"
  },
  "input_sources_unchanged": true
}


## EVIDENCE review/semantic-kernel/sprint5/runner-controls-scoped/summary.json sha256=52ebb6843ff33f0d007c752d65972ddc1a0c655544c1d528ca99f05ac14531b3

{
  "schema_version": 1,
  "kind": "executed-cli-runner-controls",
  "started_utc": "2026-09-07T03:37:07.928688+00:00",
  "finished_utc": "2026-09-07T03:37:54.897679+00:00",
  "source_repo": "/home/charl/defiformal",
  "git_head": "ba3661f3e875ef6c48e71300fec339d333dab697",
  "runner_source": "/home/charl/defiformal/scripts/check_composition_mutations.py",
  "runner_sha256": "0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031",
  "harness_source": "/home/charl/defiformal/scripts/test_composition_mutation_runner.py",
  "harness_sha256": "c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706",
  "lean_version": "Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)",
  "lean_executable_sha256": "e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550",
  "python_version": "3.14.4 (main, Jun 18 2026, 14:25:02) [GCC 15.2.0]",
  "tool_identity_commands": [
    {
      "label": "lean-version",
      "command": [
        "lake",
        "env",
        "lean",
        "--version"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
    },
    {
      "label": "lean-path",
      "command": [
        "lake",
        "env",
        "which",
        "lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
    },
    {
      "label": "git-head",
      "command": [
        "git",
        "rev-parse",
        "HEAD"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "exit": 0,
      "log_sha256": "039907652e4b03098f6961b8c8f5c9a774a5f1b1eade9ff543b710b8a5736b44"
    }
  ],
  "fixture_scope": "Synthetic development Lean computations; actual CLI and installed Lean/mathlib. No subprocess mocks; no production theorem claim.",
  "fixture_dependency_sha256": "a55de86192462c1deab9d024b263dac81a527439579ee78b076627b0ee26b425",
  "fixture_input_sha256": "640045cfb6c58588fbc5f4b1ee38025fe939dd2ce3fc154a83dfbb14d015a9ed",
  "fixture_audit_template_sha256": "6d79a576ce749752a2c14d42caed9f2391737574e7be30813579894dc962b4f3",
  "total": 36,
  "passed": 36,
  "cases": [
    {
      "name": "live-discriminating-mutant",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/live-discriminating-mutant-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/live-discriminating-mutant"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 0,
      "actual_exit": 0,
      "expected_message": "DISCRIMINATES: 1 mutants and one nonempty unchanged control",
      "passed": true,
      "elapsed_seconds": 4.043146,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/live-discriminating-mutant.log",
      "log_sha256": "a105fea8d0e70f6920274a051b99f157115a6e0de8763d1530ef79b3560dd925",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner_sensitivity']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "false"
            ]
          ],
          "errors": [
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/live-discriminating-mutant/probe.lean:25:0: error: Composition runtime comparisons failed: 1"
          ],
          "log_sha256": "c8056203ad66ed8dc3e6cac6e5bfaa0f74fd922117450c195cb3cffc92cb0bbf"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/live-discriminating-mutant/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/live-discriminating-mutant/probe.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "c8056203ad66ed8dc3e6cac6e5bfaa0f74fd922117450c195cb3cffc92cb0bbf"
        }
      ]
    },
    {
      "name": "dotted-comparisons",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/dotted-comparisons-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/dotted-comparisons"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 0,
      "actual_exit": 0,
      "expected_message": "DISCRIMINATES: 1 mutants and one nonempty unchanged control",
      "passed": true,
      "elapsed_seconds": 3.678145,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/dotted-comparisons.log",
      "log_sha256": "aff5df5522e4898e50d0182aa13fcfe14632674d598a71c7d4483891a1c52f05",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner.sensitivity']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n",
      "spec_sha256": "bc9e3cbbeca52a723ea23265a1d586ec73eec0da162c70685c7c3ff8f4dc6793",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner.positive",
              "true"
            ],
            [
              "runner.sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "03c63a1d6b37ea96123ccaaf4116f25c7b3aa603e7b568cb723cf843ed374254"
        },
        "probe": {
          "lines": [
            [
              "runner.positive",
              "true"
            ],
            [
              "runner.sensitivity",
              "false"
            ]
          ],
          "errors": [
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/dotted-comparisons/probe.lean:25:0: error: Composition runtime comparisons failed: 1"
          ],
          "log_sha256": "cec9374c47358486ea1bdd4090076eaa4d07ae67b383c39f9bbddf95ab1137bb"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/dotted-comparisons/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "03c63a1d6b37ea96123ccaaf4116f25c7b3aa603e7b568cb723cf843ed374254"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/dotted-comparisons/probe.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "cec9374c47358486ea1bdd4090076eaa4d07ae67b383c39f9bbddf95ab1137bb"
        }
      ]
    },
    {
      "name": "hyphenated-dotted-comparisons",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/hyphenated-dotted-comparisons-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/hyphenated-dotted-comparisons"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 0,
      "actual_exit": 0,
      "expected_message": "DISCRIMINATES: 1 mutants and one nonempty unchanged control",
      "passed": true,
      "elapsed_seconds": 3.801853,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/hyphenated-dotted-comparisons.log",
      "log_sha256": "1b896f87e1124b9e3b492b536e3efc13ca59d01c8b51701004525efa8e394c1a",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nprobe: exit=1; comparisons=2; false=['runner.expected-failure']\nDISCRIMINATES: 1 mutants and one nonempty unchanged control\n",
      "spec_sha256": "34b0dd754f51112440e2be9869d26f7ff10846ab9c6670e582e8910f70d0b6c7",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner.permitted-sibling",
              "true"
            ],
            [
              "runner.expected-failure",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "f60b9e6dc95fab3863fbd6a121fc795303dab293e384b11f168690139c62c008"
        },
        "probe": {
          "lines": [
            [
              "runner.permitted-sibling",
              "true"
            ],
            [
              "runner.expected-failure",
              "false"
            ]
          ],
          "errors": [
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/hyphenated-dotted-comparisons/probe.lean:25:0: error: Composition runtime comparisons failed: 1"
          ],
          "log_sha256": "049cd3f3d94b9bca5ed61ebb64df1f66d8b94047be8b058fbd8621fd19c19313"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/hyphenated-dotted-comparisons/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "f60b9e6dc95fab3863fbd6a121fc795303dab293e384b11f168690139c62c008"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/hyphenated-dotted-comparisons/probe.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "049cd3f3d94b9bca5ed61ebb64df1f66d8b94047be8b058fbd8621fd19c19313"
        }
      ]
    },
    {
      "name": "empty-dot-segment-spec",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-dot-segment-spec-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/empty-dot-segment-spec"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "invalid required check name",
      "passed": true,
      "elapsed_seconds": 0.043105,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-dot-segment-spec.log",
      "log_sha256": "966e944844462cbddf65d33d74cbadbbea4e3bc6ac1a80cbeb3ad2ce24a11e29",
      "cli_output": "BLOCKED: Blocked: invalid required check name\n",
      "spec_sha256": "094ba219784d7fef7b3f1af887e2c0a20584d75c6914a28ba347f20895040fc9",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "trailing-dot-spec",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/trailing-dot-spec-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/trailing-dot-spec"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "invalid positive check name",
      "passed": true,
      "elapsed_seconds": 0.046247,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/trailing-dot-spec.log",
      "log_sha256": "ef5aa9c54b3ed78a1b22014172138d894d5e9a4623c258e9e28f171d2b1b3395",
      "cli_output": "BLOCKED: Blocked: invalid positive check name\n",
      "spec_sha256": "11d7f9cd0e0248864606e8901be578bb91184b7569596fa835238a3ac93195b1",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "leading-dot-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/leading-dot-observation-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/leading-dot-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "malformed observation",
      "passed": true,
      "elapsed_seconds": 2.257152,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/leading-dot-observation.log",
      "log_sha256": "739eacad65d3250e537e8328936a2294cddb4cc75726052446e8d4fbce21d0a4",
      "cli_output": "BLOCKED: Blocked: control: malformed observation\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "06f628fa0b931d1743b0ab456ab9aba890f8635d5e5277579e9ece68d2ab16fb"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/leading-dot-observation/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "06f628fa0b931d1743b0ab456ab9aba890f8635d5e5277579e9ece68d2ab16fb"
        }
      ]
    },
    {
      "name": "empty-dot-segment-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-dot-segment-observation-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/empty-dot-segment-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "malformed observation",
      "passed": true,
      "elapsed_seconds": 2.293178,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-dot-segment-observation.log",
      "log_sha256": "739eacad65d3250e537e8328936a2294cddb4cc75726052446e8d4fbce21d0a4",
      "cli_output": "BLOCKED: Blocked: control: malformed observation\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "72bd1fedda0267be138240cb6585d909d4b7fc84067ab70a7c289e63a5b4dde8"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/empty-dot-segment-observation/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "72bd1fedda0267be138240cb6585d909d4b7fc84067ab70a7c289e63a5b4dde8"
        }
      ]
    },
    {
      "name": "all-true-mutant",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/all-true-mutant-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/all-true-mutant"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 1,
      "actual_exit": 1,
      "expected_message": "all comparisons still pass under mutation",
      "passed": true,
      "elapsed_seconds": 3.180772,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/all-true-mutant.log",
      "log_sha256": "38f8e08aef294af4760b9555d61e5392846217162b0507fa1beae247ea37597e",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nFAIL: probe: all comparisons still pass under mutation\n",
      "spec_sha256": "f407d3a57a5e5d56102758c2ec1f9198d9ea48566470eb9e729636e16a8ed211",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/all-true-mutant/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/all-true-mutant/probe.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        }
      ]
    },
    {
      "name": "required-observation-stays-true",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/required-observation-stays-true-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/required-observation-stays-true"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 1,
      "actual_exit": 1,
      "expected_message": "required mutation not detected",
      "passed": true,
      "elapsed_seconds": 3.012259,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/required-observation-stays-true.log",
      "log_sha256": "975e9350bce0153613f1588eb93b769a55756f271b64776b70b976ed8ef426e7",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nFAIL: probe: required mutation not detected\n",
      "spec_sha256": "65a5b772fae7b60052378395a44828ed3c9f21fdb21c717406349f3a1460c0de",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "false"
            ]
          ],
          "errors": [
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/required-observation-stays-true/probe.lean:25:0: error: Composition runtime comparisons failed: 1"
          ],
          "log_sha256": "9e4141f41551451b73a107185b8500e158790625600aa0dcdb8d0615f1f94f0a"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/required-observation-stays-true/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/required-observation-stays-true/probe.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "9e4141f41551451b73a107185b8500e158790625600aa0dcdb8d0615f1f94f0a"
        }
      ]
    },
    {
      "name": "positive-control-flipped",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/positive-control-flipped-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/positive-control-flipped"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 1,
      "actual_exit": 1,
      "expected_message": "positive control failed",
      "passed": true,
      "elapsed_seconds": 3.15182,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/positive-control-flipped.log",
      "log_sha256": "da9befd494cab4f16f1f7c58114b37154bb033c544638a08afa1b5a27acf6c9a",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nFAIL: probe: positive control failed\n",
      "spec_sha256": "3d6176031ab9d4df087cd77e95fc3a49ee7e6befbe3d95918d197ee322bf92b5",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "false"
            ],
            [
              "runner_sensitivity",
              "false"
            ]
          ],
          "errors": [
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/positive-control-flipped/probe.lean:25:0: error: Composition runtime comparisons failed: 2"
          ],
          "log_sha256": "61575a678eeacb028fc7b04f8514cff98c3f584c2c4247f01362d9f4c2126cc2"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/positive-control-flipped/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/positive-control-flipped/probe.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "61575a678eeacb028fc7b04f8514cff98c3f584c2c4247f01362d9f4c2126cc2"
        }
      ]
    },
    {
      "name": "compilation-only-failure",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/compilation-only-failure-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/compilation-only-failure"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "failure is not solely the expected runtime comparison failure",
      "passed": true,
      "elapsed_seconds": 3.027249,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/compilation-only-failure.log",
      "log_sha256": "ecc57092d68314b15394738f38d9c11dcf28542813ecba2db179f8fa3a9b9b97",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: failure is not solely the expected runtime comparison failure\n",
      "spec_sha256": "089ef08ab4d7e40e72aedc7df1614882f9e8ede0be29652f131e8e98d8aa9ab6",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/compilation-only-failure/probe.lean:16:7: error(lean.unknownIdentifier): Unknown identifier `runnerUndefinedConstant`"
          ],
          "log_sha256": "ccdf2f5ed4f52420549173c5de81156dd9704279f67403752666dc7c88dc6744"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/compilation-only-failure/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/compilation-only-failure/probe.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "ccdf2f5ed4f52420549173c5de81156dd9704279f67403752666dc7c88dc6744"
        }
      ]
    },
    {
      "name": "compiler-error-with-runtime-failure",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/compiler-error-with-runtime-failure-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/compiler-error-with-runtime-failure"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "failure is not solely the expected runtime comparison failure",
      "passed": true,
      "elapsed_seconds": 2.926515,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/compiler-error-with-runtime-failure.log",
      "log_sha256": "ecc57092d68314b15394738f38d9c11dcf28542813ecba2db179f8fa3a9b9b97",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: failure is not solely the expected runtime comparison failure\n",
      "spec_sha256": "a6321bf87c294e4f6534cb781f5b7aebb5c7788b8afa92b908daf628b86d236a",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "false"
            ]
          ],
          "errors": [
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/compiler-error-with-runtime-failure/probe.lean:15:7: error(lean.unknownIdentifier): Unknown identifier `runnerUndefinedConstant`",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/compiler-error-with-runtime-failure/probe.lean:26:0: error: Composition runtime comparisons failed: 1"
          ],
          "log_sha256": "67516e9c6b466eb80ca38a9bc6b8306a23ce5e055a44357d38c5993754c40e58"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/compiler-error-with-runtime-failure/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/compiler-error-with-runtime-failure/probe.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 1,
          "log_sha256": "67516e9c6b466eb80ca38a9bc6b8306a23ce5e055a44357d38c5993754c40e58"
        }
      ]
    },
    {
      "name": "empty-observations",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-observations-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/empty-observations"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "control: empty/duplicate observations",
      "passed": true,
      "elapsed_seconds": 1.974717,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-observations.log",
      "log_sha256": "fe24a498c94498911224a24b9bb556b5a975532fafc964f9e6aa4e6239e3e450",
      "cli_output": "BLOCKED: Blocked: control: empty/duplicate observations\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {
        "control": {
          "lines": [],
          "errors": [],
          "log_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/empty-observations/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        }
      ]
    },
    {
      "name": "duplicate-observations",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-observations-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/duplicate-observations"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "control: empty/duplicate observations",
      "passed": true,
      "elapsed_seconds": 2.187151,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-observations.log",
      "log_sha256": "fe24a498c94498911224a24b9bb556b5a975532fafc964f9e6aa4e6239e3e450",
      "cli_output": "BLOCKED: Blocked: control: empty/duplicate observations\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "641cc4bc3b894387e2dfab29ebeaca6646c337e912c0d89fced1e75d0864839c"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/duplicate-observations/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "641cc4bc3b894387e2dfab29ebeaca6646c337e912c0d89fced1e75d0864839c"
        }
      ]
    },
    {
      "name": "missing-positive-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/missing-positive-observation-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/missing-positive-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "control: missing positive controls",
      "passed": true,
      "elapsed_seconds": 1.96473,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/missing-positive-observation.log",
      "log_sha256": "3902aedfb8fa72bd61830a36294e361ef9b3733549da73bc3fd30bbc11d13e47",
      "cli_output": "BLOCKED: Blocked: control: missing positive controls\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "f1686d9b5d9174cd8c12ad7952022571dab902d541e6f3de5a0e5ef9a17f1302"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/missing-positive-observation/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "f1686d9b5d9174cd8c12ad7952022571dab902d541e6f3de5a0e5ef9a17f1302"
        }
      ]
    },
    {
      "name": "missing-required-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/missing-required-observation-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/missing-required-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "probe: missing required observation in control",
      "passed": true,
      "elapsed_seconds": 2.018989,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/missing-required-observation.log",
      "log_sha256": "97f7140dd95345df37e622d410d5e9ee924436af377e8f9ea8ef143ace1f8944",
      "cli_output": "BLOCKED: Blocked: probe: missing required observation in control\n",
      "spec_sha256": "096775d4ae7beffeb92639f616663965256d25102876f40ad8902e3a5b63ca05",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/missing-required-observation/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        }
      ]
    },
    {
      "name": "partial-mutant-observations",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/partial-mutant-observations-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/partial-mutant-observations"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "probe: partial execution",
      "passed": true,
      "elapsed_seconds": 3.280646,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/partial-mutant-observations.log",
      "log_sha256": "1b2f26f08958c0b94053bdcb2cac66d567c5f5ecd0d216175e35322af7bda456",
      "cli_output": "control: exit=0; comparisons=2; false=[]\nBLOCKED: Blocked: probe: partial execution\n",
      "spec_sha256": "0f9afa65ef4dcdcd90cd2ac25c8f2a0499c05556cfc650b1cb7558f386e721cb",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        "probe": {
          "lines": [
            [
              "runner_positive",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "bc6e74ae5ad02a8118ad7c0d5f482af8085a7229355f13d6173f86d60683772d"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/partial-mutant-observations/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "5391345256e61cbfb591b4af64a0a8c10d4a034e62190d35848c88cad046a6ed"
        },
        {
          "label": "probe",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/partial-mutant-observations/probe.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "bc6e74ae5ad02a8118ad7c0d5f482af8085a7229355f13d6173f86d60683772d"
        }
      ]
    },
    {
      "name": "no-op-mutation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/no-op-mutation-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/no-op-mutation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "mutation must actually change the source",
      "passed": true,
      "elapsed_seconds": 0.038328,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/no-op-mutation.log",
      "log_sha256": "b17005f70eaf2c952f34332c6115135580b3c72b3d4414ebf4a29af62ffb97dd",
      "cli_output": "BLOCKED: Blocked: mutation must actually change the source\n",
      "spec_sha256": "1acb91ef767c9d1f8668783e3c9d64c167f7353d129e50f5c12aae99fbdecbbe",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "missing-mutation-needle",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/missing-mutation-needle-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/missing-mutation-needle"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "mutation did not apply exactly once",
      "passed": true,
      "elapsed_seconds": 0.041315,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/missing-mutation-needle.log",
      "log_sha256": "6f90bdc0ec4157b596cb33422a789e4b0779aecb3867970c8d92c6fc17300def",
      "cli_output": "BLOCKED: Blocked: probe: mutation did not apply exactly once\n",
      "spec_sha256": "ea47582e90c5beca94df51ca577e01520a9cfe7f75ec1ff471c72f9b33696ce6",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "missing-source-setup",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/missing-source-setup-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/missing-source-setup"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "FileNotFoundError",
      "passed": true,
      "elapsed_seconds": 0.040384,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/missing-source-setup.log",
      "log_sha256": "05a69ebc5941ee3774d4aea5cb3c8e0a5c5408ecd757a5e9ac437352741996d9",
      "cli_output": "BLOCKED: FileNotFoundError: [Errno 2] No such file or directory: '/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean/DefiKernel/Composition/RunnerInput.lean'\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "missing-manifest-setup",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/missing-manifest-setup-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/missing-manifest-setup"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "FileNotFoundError",
      "passed": true,
      "elapsed_seconds": 0.044513,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/missing-manifest-setup.log",
      "log_sha256": "a2bc85adc5fe726e89b91fcd8fc1ac4de077531ea5bc2756ea20c69dd73198c1",
      "cli_output": "BLOCKED: FileNotFoundError: [Errno 2] No such file or directory: '/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean/lake-manifest.json'\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "existing-output-setup",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/existing-output-setup-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/existing-output-setup"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "output already exists",
      "passed": true,
      "elapsed_seconds": 0.036667,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/existing-output-setup.log",
      "log_sha256": "ccb397a7b400740970066a75dcb697d410732428a72ee25b78bd5fd711437d87",
      "cli_output": "BLOCKED: Blocked: output already exists\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "reserved-mutation-name",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/reserved-mutation-name-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/reserved-mutation-name"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "reserved variant name",
      "passed": true,
      "elapsed_seconds": 0.036615,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/reserved-mutation-name.log",
      "log_sha256": "68ca99d80f5e9e2c8ec51b16310399b3bc37cbbbdfbf3dae0309ec4056a6dfa7",
      "cli_output": "BLOCKED: Blocked: reserved variant name\n",
      "spec_sha256": "14b0d18ae3040432fb70873bd294e577bd70f44b96cb2a2e1b6299736fd7bd90",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "empty-module-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-module-inventory-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/empty-module-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "empty module inventory",
      "passed": true,
      "elapsed_seconds": 0.039625,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-module-inventory.log",
      "log_sha256": "420d91bd881136c8edb9404a23f978230b022f8bec33d07f2305f2cf26c11d25",
      "cli_output": "BLOCKED: Blocked: empty module inventory\n",
      "spec_sha256": "7394c2beb0513956605f6e5dab23695ca81214cd06923706ad404d91107d07fb",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "empty-positive-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-positive-inventory-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/empty-positive-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "empty positive-control inventory",
      "passed": true,
      "elapsed_seconds": 0.038176,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-positive-inventory.log",
      "log_sha256": "1380baf49bc7e439f004bd37ea939223bda2e943ae240d4f3f01e16be068e61c",
      "cli_output": "BLOCKED: Blocked: empty positive-control inventory\n",
      "spec_sha256": "8e907b9099591653d9aee4d93f40fa0737f86d908662b2177c686dc004d5e663",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "duplicate-module-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-module-inventory-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/duplicate-module-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "duplicate source module",
      "passed": true,
      "elapsed_seconds": 0.038691,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-module-inventory.log",
      "log_sha256": "d4608a413da337306c20737630210431d7187ce266f1bd286f26160c32038453",
      "cli_output": "BLOCKED: Blocked: duplicate source module\n",
      "spec_sha256": "bef86f12ce7d3925655ee897943723dc39e30b8fa4b05578f775a27a267af205",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "duplicate-mutation-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-mutation-inventory-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/duplicate-mutation-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "duplicate mutation name",
      "passed": true,
      "elapsed_seconds": 0.037522,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-mutation-inventory.log",
      "log_sha256": "d80a2df2959221fed547d3199e12efa18e1c3e251e894ae052b508f104fab8f3",
      "cli_output": "BLOCKED: Blocked: duplicate mutation name\n",
      "spec_sha256": "dd4167cfc7c5a483b2146dbb5b8ae384dd8c2070a1466455b0d894ddfc82cb17",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "duplicate-positive-check",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-positive-check-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/duplicate-positive-check"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "duplicate positive control",
      "passed": true,
      "elapsed_seconds": 0.040644,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-positive-check.log",
      "log_sha256": "97e937f830586a63e44b6ae14d91ee9c854034adc40dda6203402630085f2226",
      "cli_output": "BLOCKED: Blocked: duplicate positive control\n",
      "spec_sha256": "3f93b9cf777ebceb680b8600232ca536073524171d0b34f9460cfce1de57dc6c",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "duplicate-required-check",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-required-check-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/duplicate-required-check"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "duplicate required check",
      "passed": true,
      "elapsed_seconds": 0.043425,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-required-check.log",
      "log_sha256": "a2c8000fdab76596b59060aca02c3955e3277842cd4e277b364645dd334c514a",
      "cli_output": "BLOCKED: Blocked: duplicate required check\n",
      "spec_sha256": "2a444749fb91b852762151bcfc3a015b8ea418c62b06470ea0a63170ba4a8702",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "nonunique-mutation-needle",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/nonunique-mutation-needle-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/nonunique-mutation-needle"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "mutation did not apply exactly once",
      "passed": true,
      "elapsed_seconds": 0.046852,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/nonunique-mutation-needle.log",
      "log_sha256": "6f90bdc0ec4157b596cb33422a789e4b0779aecb3867970c8d92c6fc17300def",
      "cli_output": "BLOCKED: Blocked: probe: mutation did not apply exactly once\n",
      "spec_sha256": "80ee627ac03bafc9d6cc0641be0a7259258f43e61bb6d373f27197655aeb2337",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "malformed-observation",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/malformed-observation-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/malformed-observation"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "malformed observation",
      "passed": true,
      "elapsed_seconds": 2.249218,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/malformed-observation.log",
      "log_sha256": "739eacad65d3250e537e8328936a2294cddb4cc75726052446e8d4fbce21d0a4",
      "cli_output": "BLOCKED: Blocked: control: malformed observation\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {
        "control": {
          "lines": [
            [
              "runner_positive",
              "true"
            ],
            [
              "runner_sensitivity",
              "true"
            ]
          ],
          "errors": [],
          "log_sha256": "41a398d927a319a363b4a2747adff5d227b7970bbfd8e118f93b847464247209"
        }
      },
      "runner_records": [
        {
          "label": "lean-version",
          "command": [
            "lake",
            "env",
            "lean",
            "--version"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d2b0b0a275a0c043b1650ebc4faf0b9c9c686656f0b0f066fc6f77df4f135d3a"
        },
        {
          "label": "lean-path",
          "command": [
            "lake",
            "env",
            "which",
            "lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "23b38542e8acd8878823529ed8bb692d4ffd53c6af9ba8f9d74819de56358881"
        },
        {
          "label": "git-head",
          "command": [
            "git",
            "rev-parse",
            "HEAD"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "c2b1d00f0f65573bcd5ba46e12928812af3aa0b628ede5c4a344d6520d85e367"
        },
        {
          "label": "git-root-input-status",
          "command": [
            "git",
            "-C",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
            "status",
            "--porcelain",
            "--untracked-files=all",
            "--",
            "lean/DefiKernel/Composition/RunnerInput.lean",
            "lean/DefiKernel/Typed/RunnerDependency.lean",
            "lean/DefiKernel/Composition/RunnerAudit.lean",
            "lean/lean-toolchain",
            "lean/lake-manifest.json",
            "lean/lakefile.toml"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "d7ff4c2cfb47f7db3037bb269227c551b9515888f5c7de2808ce1e9e55956dd3"
        },
        {
          "label": "control",
          "command": [
            "lake",
            "env",
            "lean",
            "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/malformed-observation/control.lean"
          ],
          "cwd": "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/lean",
          "exit": 0,
          "log_sha256": "41a398d927a319a363b4a2747adff5d227b7970bbfd8e118f93b847464247209"
        }
      ]
    },
    {
      "name": "malformed-json",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/malformed-json-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/malformed-json"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "JSONDecodeError",
      "passed": true,
      "elapsed_seconds": 0.040043,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/malformed-json.log",
      "log_sha256": "bb288e0effc1922ff3c3292e12ff5e685ed35c7c95eba14587814071c7bb5d83",
      "cli_output": "BLOCKED: JSONDecodeError: Expecting property name enclosed in double quotes: line 1 column 2 (char 1)\n",
      "spec_sha256": "021fb596db81e6d02bf3d2586ee3981fe519f275c0ac9ca76bbcf2ebb4097d96",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "duplicate-json-key",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-json-key-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/duplicate-json-key"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "duplicate JSON key",
      "passed": true,
      "elapsed_seconds": 0.038082,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/duplicate-json-key.log",
      "log_sha256": "0f1dea503e7da8a04bca31c98ae7829025e625df5937d9464229ffce02c5091f",
      "cli_output": "BLOCKED: Blocked: duplicate JSON key: schema_version\n",
      "spec_sha256": "0da553ad4d76ac11a13925a107f1de186487f10e748d11f17130cb8b136e7c45",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "output-inside-repository",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/output-inside-repository-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo/forbidden-output"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "evidence output must be outside the repository",
      "passed": true,
      "elapsed_seconds": 0.038202,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/output-inside-repository.log",
      "log_sha256": "afab9aeb87fc6254658f5f349e1367967b0d6e45d8ea7e56fe69b6049a402228",
      "cli_output": "BLOCKED: Blocked: evidence output must be outside the repository\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "output-symlink",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/output-symlink-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/output-symlink"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "output already exists",
      "passed": true,
      "elapsed_seconds": 0.04021,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/output-symlink.log",
      "log_sha256": "ccb397a7b400740970066a75dcb697d410732428a72ee25b78bd5fd711437d87",
      "cli_output": "BLOCKED: Blocked: output already exists\n",
      "spec_sha256": "300524e26ec55201eae20e5a140692c3442afb27146fe68d38dadee3f1542fe8",
      "lean_observations": {},
      "runner_records": []
    },
    {
      "name": "empty-mutation-inventory",
      "command": [
        "/usr/bin/python3",
        "/home/charl/defiformal/scripts/check_composition_mutations.py",
        "--repo",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/fixture-repo",
        "--spec",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-mutation-inventory-spec.json",
        "--out",
        "/tmp/defiformal-sprint5-runner-controls-scoped-final/runs/empty-mutation-inventory"
      ],
      "cwd": "/home/charl/defiformal",
      "expected_exit": 3,
      "actual_exit": 3,
      "expected_message": "empty mutation inventory",
      "passed": true,
      "elapsed_seconds": 0.037682,
      "log": "/tmp/defiformal-sprint5-runner-controls-scoped-final/empty-mutation-inventory.log",
      "log_sha256": "c4467212b8bbf24a3f24e88e5eaa617a4333a70d5b2b1ef7613128095819e8b8",
      "cli_output": "BLOCKED: Blocked: empty mutation inventory\n",
      "spec_sha256": "1b8f51f961df49497f08713667ee10304f3d25bfed8ff7ec40ab5747a13450b5",
      "lean_observations": {},
      "runner_records": []
    }
  ]
}


## EVIDENCE review/semantic-kernel/sprint5/mutation-runner-report.md sha256=b9c361273df2f68e0f432272996185f3b3ca889020165ac116f4981d19322dc5

# Sprint 5 composition mutation runner

Implemented `scripts/check_composition_mutations.py` and its real CLI control
harness. This report records bounded runner and actual workflow mutation evidence.
Composition theorem verification and independent native review are separate
integration obligations.

The final composition harness passed **36/36 actual CLI controls**. The accepted
case compiled fresh unchanged source and executed two true comparisons; its real
`n ≤ 4` → `n ≤ 5` mutant compiled and executed `runner_sensitivity: false` while
`runner_positive` remained true. A surviving `n ≤ 3` mutant returned exit 1.
Compiler-only and mixed compiler/runtime failures returned exit 3, never a
semantic detection. Empty inventories/observations, duplicates, missing checks,
partial execution, missing/nonunique needles, unchanged replacements, malformed
JSON/observations, reserved artifact names, and output misuse were rejected.

Dotted and hyphenated dotted comparison names have executed accepted siblings;
leading/trailing dots and empty dot segments are rejected in spec/output controls.
The earlier 30-control replay remains under `runner-controls/` as historical evidence.

The unchanged Sprint 4 runner harness passed **17/17 CLI controls**; both legacy
runner source files have zero Git diff. Python syntax checks passed for both new
files. These results do not establish correctness of arbitrary user-supplied
Lean checks or their expected values; source review supplies that trust boundary.

Commands (each exited 0):

```sh
python3 scripts/test_composition_mutation_runner.py --repo . --out /tmp/defiformal-sprint5-runner-controls-scoped-final
python3 scripts/test_typed_kernel_mutation_runner.py --repo . --out /tmp/defiformal-sprint5-legacy-runner-controls
```

[Composition summary](runner-controls-scoped/summary.json) and
[case records](runner-controls-scoped/cases.json) contain exact commands, tool/source
hashes, classification expectations, complete CLI output, observed Lean
comparisons, and log hashes. The `runner-controls-scoped/runs/` directories preserve
actual source projections, input snapshots, manifests, and subprocess logs.
[Legacy summary](legacy-runner-controls/summary.json) and the adjacent artifacts
preserve the unchanged runner replay. Absolute paths in records identify the
original scratch executions; evidence copies retain their original bytes.
The synthetic Git fixture repositories and dependency symlinks are not copied.

## Integration contract

Run from the repository root, selecting a new output path outside the repository:

```sh
python3 scripts/check_composition_mutations.py --repo . --spec review/semantic-kernel/sprint5/mutation-spec.json --out /tmp/composition-mutations-NEW
```

Schema version 1 has exactly these top-level fields:

```json
{
  "schema_version": 1,
  "modules": ["DefiKernel.Composition.RunnerInput", "DefiKernel.Composition.RunnerAudit"],
  "positive_checks": ["runner_positive"],
  "mutations": [{
    "name": "probe",
    "module": "DefiKernel.Composition.RunnerInput",
    "needle": "n ≤ 4",
    "replacement": "n ≤ 5",
    "required_false": ["runner_sensitivity"]
  }]
}
```

All inventories must be nonempty and unique. Each mutation applies exactly once
in its named executable projection. Names for comparisons use lowercase letters,
digits, underscores and hyphens in nonempty dot-separated segments, each starting
with a letter; variant names use lowercase
letters, digits and hyphens and cannot overwrite reserved tool/control logs.
Every required comparison must exist in the unchanged run, and every mutant must
execute the identical comparison set. Positive controls must remain true.
The runtime driver prints `name: true` or `name: false`, then throws exactly
`Composition runtime comparisons failed: N` when N comparisons fail. A detected
mutant must have that single diagnostic, a nonzero Lean exit, and every named
required false comparison. Additional compilation errors block acceptance.

Only Composition modules can be explicit mutation targets. All local DefiKernel
imports are recursively read, hashed, topologically ordered and concatenated
from current source; no project olean is imported. Imported Composition modules
must be listed explicitly. External Mathlib dependencies remain installed package
imports, identified by the recorded Lake manifest/toolchain. Composition proof
suffixes beginning at the unique `-- BEGIN PROOFS` marker are replaced by the
matching namespace closure. Unchanged dependency proof tails are retained.
A real Typed fixture theorem located after its proof marker is referenced from
Composition to exercise that distinction. No accepted source file is rewritten.

The runner records input hashes before/after replay, executable Lean identity,
Git revision and dirty-input status, spec/script hashes, and all subprocess
commands/log hashes, including blocked runs that reached subprocess execution.
Exit 0 means all specified nonempty mutations discriminate; exit 1 means an
executed semantic expectation failed; exit 3 means malformed or unavailable
evidence. Projection supports the documented simple one-module-per-import
syntax and matching namespace closure, and deliberately blocks unsupported input.

Runner-control source/tool binding:

- Runner SHA-256: `0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031`.
- Harness SHA-256: `c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706`.
- Lean: `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`.
- Observed repository revision: `86b77b7f658f57530cc3833c66812d26d9925018`; new files were uncommitted.

## Source-change rejection during integration

The first real workflow replay compiled an unchanged control (85/85 true) and
all twelve altered implementations. Each mutant produced its designated false
comparisons. The runner nevertheless returned **exit 3** because accepted source
bytes changed during replay. This run is not accepted final mutation evidence.
The [rejection record](mutation-probe-rejected.json) preserves the command,
classification, captured/current input hashes and all measured outcomes; the
[probe artifacts](mutation-probe-artifacts/source-manifest.json) retain the exact
captured source closure, projections and compiler/runtime logs. This exercises
the source-unchanged guard on an actual concurrent source change.

## Accepted actual workflow mutations

The final source-bound CLI replay exited **0**, with **93/93**
unchanged comparisons true and **12/12** actual source mutants detected. Every
mutant compiled, executed the identical comparison inventory, failed all its
designated comparisons, and preserved all six positive controls. Inputs matched
before/after hashes and were rechecked against current source before evidence copy.

[Final summary](mutations/summary.json), [exact CLI command](mutations/command.json),
[CLI output](mutations/cli-output.log), [source manifest](mutations/source-manifest.json),
and [complete results](mutations/results.json) bind the source, spec, tool and
observations. [Mutation specification](mutation-spec.json) records every exact
needle/replacement and designated false comparison. Copied scratch paths retain
the original bytes; all actual projections, inputs and per-variant logs are adjacent.

Protected positives include three catalog checks plus an actual permitted
transfer with receipts/snapshots, a permitted shared write, and a funded kernel
execution. Each remained true in every mutant.

| Mutation | Designated executed failures |
| --- | --- |
| reverse-order | `workflows.transfer.deposit.withdraw`, `workflows.order.transfer.first` |
| drop-first-step | `workflows.consecutive` |
| continue-after-refusal | `workflows.first.refusal`, `workflows.resume.terminal` |
| reset-ledger | `workflows.consecutive` |
| reset-capability-store | `workflows.admin.live.repeat` |
| omit-revocation-propagation | `execution.revoke.ledger.receipt`, `workflows.admin.revocation` |
| interface-write-bypass | `interface.foreign-write`, `interface.readonly-write`, `workflows.isolation.private`, `workflows.isolation.readonly` |
| wrong-output-index | `workflows.output.index` |
| wrong-output-unit | `interface.wrong-output-unit`, `workflows.output.unit` |
| drop-supply-receipt | `workflows.order.deposit.first`, `workflows.transfer.deposit.withdraw` |
| reset-continuation-index | `workflows.resume.output`, `workflows.resume.time` |
| wrong-snapshot-index | `interface.snapshot-exact`, `workflows.output.index` |

The supplied mutations alter executable implementation behavior, including
receipt payload supplies; they do not edit expected workflow values or runtime
check definitions. The dropped supply mutation clears actual receipt `supplies`
after genuine kernel execution, and is detected by independent expected receipts.
These reference workflows do not establish deployed-contract fidelity, machine
arithmetic refinement, or general semantic correctness.


## EVIDENCE review/semantic-kernel/sprint5/preservation.json sha256=d0e9e0138923aa08ac7bc2ca80d74fb1370c166132b685c16e4543a9e58a4455

{
  "base_commit": "86b77b7f658f57530cc3833c66812d26d9925018",
  "preserved_file_count": 165,
  "all_preserved": true,
  "files": {
    "algebra/negative-corpus.json": true,
    "algebra/negcorpus.ts": true,
    "algebra/results/R10-corpus.md": true,
    "algebra/stage4/Discharge.lean": true,
    "corpus/CAKEClaude.md": true,
    "corpus/CAKEGPT.md": true,
    "corpus/elementsdefi.md": true,
    "corpus/elementsdefiGPT.md": true,
    "corpus/normalized/README.md": true,
    "corpus/normalized/annotations/a.json": true,
    "corpus/normalized/annotations/b.json": true,
    "corpus/normalized/corpus.schema.json": true,
    "corpus/normalized/generated/corpus.json": true,
    "corpus/normalized/generated/coverage.json": true,
    "corpus/normalized/generated/crosswalk.csv": true,
    "corpus/normalized/inputs/annotation-input.json": true,
    "corpus/normalized/inputs/identity-map.json": true,
    "corpus/normalized/inputs/source-manifest.json": true,
    "corpus/normalized/inputs/taxonomy.json": true,
    "corpus/normalized/requirements.txt": true,
    "corpus/normalized/sources/README.md": true,
    "corpus/normalized/sources/primary-excerpts.json": true,
    "corpus50/VERDICT.md": true,
    "corpus50/decomp-contract.md": true,
    "corpus50/lanes/lane1-dex-lending-cdp-lsd.json": true,
    "corpus50/lanes/lane2-perps-yield-bridges-intents.json": true,
    "corpus50/lanes/lane3-rwa-options-stables-prediction.json": true,
    "corpus50/vocab.md": true,
    "docs/superpowers/plans/2026-09-06-corpus-provenance.md": true,
    "docs/superpowers/specs/2026-09-06-corpus-provenance-design.md": true,
    "formal/v2/corpus-lattice.mjs": true,
    "lean/Axioms.lean": true,
    "lean/DefiKernel/Acceptance.lean": true,
    "lean/DefiKernel/Audit.lean": true,
    "lean/DefiKernel/AxiomAudit.lean": true,
    "lean/DefiKernel/ContractAcceptance.lean": true,
    "lean/DefiKernel/ContractAudit.lean": true,
    "lean/DefiKernel/ContractExamples.lean": true,
    "lean/DefiKernel/Contracts.lean": true,
    "lean/DefiKernel/Core.lean": true,
    "lean/DefiKernel/Examples.lean": true,
    "lean/DefiKernel/Typed/Acceptance.lean": true,
    "lean/DefiKernel/Typed/Audit.lean": true,
    "lean/DefiKernel/Typed/Authority.lean": true,
    "lean/DefiKernel/Typed/AuthorityTests.lean": true,
    "lean/DefiKernel/Typed/Examples.lean": true,
    "lean/DefiKernel/Typed/Expr.lean": true,
    "lean/DefiKernel/Typed/ExprTests.lean": true,
    "lean/DefiKernel/Typed/Transition.lean": true,
    "lean/DefiKernel/Typed/TransitionTests.lean": true,
    "lean/DefiKernel/Typed/Types.lean": true,
    "lean/DefiKernel/Typed/Verify.lean": true,
    "lean/DefiKernel/VerifyAxioms.lean": true,
    "lean/Defialgebra.lean": true,
    "lean/Defialgebra/Basic.lean": true,
    "lean/Defialgebra/ConvexGeometry.lean": true,
    "lean/Defialgebra/Discharge.lean": true,
    "lean/Defialgebra/Extremal.lean": true,
    "lean/Defialgebra/FlowPolarity.lean": true,
    "lean/Defialgebra/Independence.lean": true,
    "lean/Defialgebra/Interface.lean": true,
    "lean/Defialgebra/Lattice.lean": true,
    "lean/Defialgebra/Nary.lean": true,
    "lean/Defialgebra/Obstruction.lean": true,
    "lean/Defialgebra/Permission.lean": true,
    "lean/Defialgebra/Polarity.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/added-source.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/added.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/control-source.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/control.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/custom-axiom-dependency.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/custom-axiom.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/empty-source.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/empty.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/fixtures/DefiKernel/AuditProbe.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/fixtures/DefiKernel/AxiomAudit.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/fixtures/ForeignAssumptions.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/fixtures/RunAudit.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/missing.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/sorry-axiom-dependency.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/sorry-axiom.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/transitive-control-dependency.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/transitive-control.lean": true,
    "review/semantic-kernel/sprint2/axiom-tests/transitive-source.lean": true,
    "review/semantic-kernel/sprint2/contract-mutations/borrow_condition_bypass.lean": true,
    "review/semantic-kernel/sprint2/contract-mutations/contract_bypass.lean": true,
    "review/semantic-kernel/sprint2/contract-mutations/control.lean": true,
    "review/semantic-kernel/sprint2/contract-mutations/inputs/lean/DefiKernel/ContractAcceptance.lean": true,
    "review/semantic-kernel/sprint2/contract-mutations/inputs/lean/DefiKernel/ContractAudit.lean": true,
    "review/semantic-kernel/sprint2/contract-mutations/inputs/lean/DefiKernel/ContractExamples.lean": true,
    "review/semantic-kernel/sprint2/contract-mutations/inputs/lean/DefiKernel/Contracts.lean": true,
    "review/semantic-kernel/sprint2/contract-mutations/inputs/lean/DefiKernel/Core.lean": true,
    "review/semantic-kernel/sprint2/contract-mutations/inputs/lean/DefiKernel/Examples.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/added-source.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/added.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/control-source.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/control.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/custom-axiom-dependency.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/custom-axiom.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/definition-control-source.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/definition-control.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/empty-source.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/empty.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/fixtures/DefiKernel/AuditProbe.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/fixtures/DefiKernel/AxiomAudit.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/fixtures/ForeignAssumptions.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/fixtures/RunAudit.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/missing.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/opaque-control-source.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/opaque-control.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/sorry-axiom-dependency.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/sorry-axiom.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/sorry-definition-source.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/sorry-definition.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/sorry-opaque-source.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/sorry-opaque.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/transitive-control-dependency.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/transitive-control.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/transitive-source.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/unused-custom-axiom-source.lean": true,
    "review/semantic-kernel/sprint2/r2-axiom-tests/unused-custom-axiom.lean": true,
    "review/semantic-kernel/sprint2/r2-contract-mutations/borrow_condition_bypass.lean": true,
    "review/semantic-kernel/sprint2/r2-contract-mutations/contract_bypass.lean": true,
    "review/semantic-kernel/sprint2/r2-contract-mutations/control.lean": true,
    "review/semantic-kernel/sprint2/r2-contract-mutations/inputs/lean/DefiKernel/ContractAcceptance.lean": true,
    "review/semantic-kernel/sprint2/r2-contract-mutations/inputs/lean/DefiKernel/ContractAudit.lean": true,
    "review/semantic-kernel/sprint2/r2-contract-mutations/inputs/lean/DefiKernel/ContractExamples.lean": true,
    "review/semantic-kernel/sprint2/r2-contract-mutations/inputs/lean/DefiKernel/Contracts.lean": true,
    "review/semantic-kernel/sprint2/r2-contract-mutations/inputs/lean/DefiKernel/Core.lean": true,
    "review/semantic-kernel/sprint2/r2-contract-mutations/inputs/lean/DefiKernel/Examples.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/added-source.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/added.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/control-source.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/control.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/custom-axiom-dependency.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/custom-axiom.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/definition-control-source.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/definition-control.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/empty-source.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/empty.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/fixtures/DefiKernel/AuditProbe.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/fixtures/DefiKernel/AxiomAudit.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/fixtures/ForeignAssumptions.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/fixtures/RunAudit.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/missing.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/opaque-control-source.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/opaque-control.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/sorry-axiom-dependency.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/sorry-axiom.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/sorry-definition-source.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/sorry-definition.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/sorry-opaque-source.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/sorry-opaque.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/transitive-control-dependency.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/transitive-control.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/transitive-source.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/unused-custom-axiom-source.lean": true,
    "review/semantic-kernel/sprint4/axiom-controls/unused-custom-axiom.lean": true,
    "review/semantic-kernel/sprint4/proof-inventory-check.lean": true,
    "review/semantic-kernel/sprint4/typing/implicit-debt-conversion.lean": true,
    "review/semantic-kernel/sprint4/typing/mixed-assets.lean": true,
    "review/semantic-kernel/sprint4/typing/positive.lean": true,
    "review/semantic-kernel/sprint4/typing/reversed-price.lean": true,
    "viz/scripts/gencorpus.mjs": true,
    "viz/src/corpus.ts": true
  }
}


## Actual final axiom driver summary
AXIOM AUDIT DECLARATIONS PASSED: 583/583 supplemental declarations; forbidden=0
AXIOM AUDIT PASSED: 328/328 theorems; forbidden=0

## Proof inventory metadata
{
  "schema_version": 1,
  "captured_utc": "2026-09-07T03:48:32.691010+00:00",
  "head": "ba3661f3e875ef6c48e71300fec339d333dab697",
  "status": "verified_named_theorem_inventory",
  "scope": "Named source theorem declarations only; generated declarations counted separately by imported axiom audit. Exact source statements preserve quantification and premises. No bounded runtime comparison is listed as a generic theorem.",
  "theorem_count": 70,
  "scope_counts": {
    "closed_computation_proof": 1,
    "concrete_counterexample": 2,
    "conditional_reference_instantiation": 1,
    "generic": 58,
    "reference_contract_rule": 2,
    "reference_initialization": 1,
    "reference_instantiation": 4,
    "reference_support": 1
  },
  "validated_utc": "2026-09-07T03:50:17.774224+00:00",
  "verification": {
    "manifest": "build-verification.json",
    "manifest_sha256": "bebda74d0554e3bc1ac17ea71544653d788fc08c14084888a9cf29b0d0227379",
    "full_build_log": "final-build.log",
    "full_build_jobs": 1016,
    "imported_axiom_log": "final-axioms.log",
    "imported_theorems": 328,
    "imported_supplemental_declarations": 583,
    "forbidden_dependencies": 0,
    "named_source_theorems": 70,
    "named_theorems_observed": 70,
    "named_inventory_equals_all_composition_source_theorems": true,
    "scope": "All 70 named source theorems are present in the successful nonempty imported audit; the larger audit totals include generated/imported helper declarations. Review and mutation acceptance remain separate."
  }
}
