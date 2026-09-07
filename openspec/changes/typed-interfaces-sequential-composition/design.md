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
