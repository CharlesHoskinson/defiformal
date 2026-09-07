# Operational composition metatheory planning draft

Planning research only, 2026-09-07. Source inspected at
`bea105ec72e633a2dd66c663b96d0b552e1814a8`. This note proposes independently
reviewable increments after atomic synchronization. It is not an approved OpenSpec
change, an implementation, or proof evidence. Each increment needs its own frozen
GPT-6/native Fable planning gate and native Grok/Fable result review through the
stock Codex harness. No Foreman. Routine scope choices follow the user's AFK
execution authorization; no source, historical theorem or existing evidence is
changed by this draft.

The [approved design](../docs/superpowers/specs/2026-09-06-semantic-kernel-design.md)
and [roadmap](../roadmap.md) require operational interface and n-ary composition,
behavioral associativity, initialized causal assume-guarantee rules, observational
equivalence and conservative extension. The
[original proposal](../docs/research/2026-09-06-defi-source-plan.md) is motivation,
not an already verified implementation. The
[atomic draft](sprint-8-atomic-synchronization-draft.md) supplies the proposed
transaction boundary. Its eventual accepted OpenSpec and implementation must
replace draft assumptions before atomic metatheorems are frozen.

## Current foundation and actual gaps

| Source and symbols | What can be reused | What is still required |
| --- | --- | --- |
| [Historical Interface](../lean/Defialgebra/Interface.lean), `Ledger`, `Cons`, `WritesWithin`, `QNeutralOn`, `cons_of_portConfined`, `cons_broken_if_sup_is_port` | An explicit conservation discipline and its negative witness | Typed asset/domain-indexed actual-step and reachable-prefix instances; no automatic inference of neutrality |
| [Historical Nary](../lean/Defialgebra/Nary.lean), `Binding`, `Agrees`, `agrees_union_assoc`, `agrees_of_same_symClosure`, `skip_not_pairLocal_witness` | Stable global names and conjunction of binding constraints | A running multi-participant machine and proof that regrouping preserves its steps, histories, boundaries and failures |
| [Composition interfaces](../lean/DefiKernel/Composition/Interfaces.lean), `QualifiedPort`, `ResourcePort`, `ResourceImport`, `validateCatalog`, `resolveSource` | Exact-cell resource sharing, globally qualified output names, input units and absolute prior-output positions | Global operational binding preservation and supported interface contracts; a valid catalog is not such a proof |
| [Composition execution](../lean/DefiKernel/Composition/Execution.lean), `executeStep`, `StepSound`, `extractReceipt_correspondence` | Actual invocation/admin outcomes and receipt evaluation at the same pre-world | Congruence under a changed but compatible configuration; no invented receipt-level semantics |
| [Sequence](../lean/DefiKernel/Composition/Sequence.lean), `Cursor`, `continueRun_append`, `continueRun_failed`, `TraceSound` | Full cursor propagation and refusal absorption | A separately defined group executor and a correspondence theorem; list append alone does not cover grouping |
| [Contracts](../lean/DefiKernel/Composition/Contracts.lean), `ComponentContract`, `ContractObligations`, `Supports`; [preservation](../lean/DefiKernel/Composition/Preservation.lean), `run_contract` | Initialized conditional contracts and supported ledger frames | Discharge of local assumptions from actual earlier events and current trusted environment premises |
| [Dependency adapter](../lean/DefiKernel/Parallel/Dependency/Adapter.lean), `StepAgrees`, `executeStep_congr`, `executeStep_refusal_iff`; [commutation](../lean/DefiKernel/Parallel/Commutation.lean), `CursorAgrees`, `continueRun_congr`, `runParallel_serialLR`, `runParallel_serialRL` | Full success/refusal dependence on analyzed reads, output cells and equal capabilities, for the same configuration/boundary/history | Configuration extension and many-participant simulations; equality of final balances alone is weaker |
| [Interleaving interference](../lean/DefiKernel/Interleaving/Interference.lean), `LocalObligation`, `CrossInclusion`, `Stable`, `Reachable.two_invariants` | An actual initialized binary induction, with no circular whole-run premise | Finite-index generalization and useful causal assumptions that local proofs truly need |
| [Interleaving recovery](../lean/DefiKernel/Interleaving/Recovery.lean), `runInterleaving_recovers`, `runInterleaving_matchesParallel` | All complete binary schedules recover actual disjoint parallel observations under actual admission | Many-participant recovery and group execution correspondence; arbitrary overlapping runs need not commute |
| [Typed authority](../lean/DefiKernel/Typed/Authority.lean), `CapabilityStore.nextId`, `issueCapability`, `revokeCapability`, `authorizesId` | Existing administration and exact point-of-use permission predicates | Provenance from an initialized administrative trace, and later concurrent allocation/revocation semantics |

The existing repository graph is bound to historical commit `f559c474…` and
contains an `M3_nary_binding` concept at `research/positive-program/AGENDA.md`.
It does not index the current Interleaving source. Current claims above come from
direct source inspection; the historical graph was not regenerated.

Three possible approaches are materially different:

1. Add laws about list flattening and binding union. This is small and useful as
   helper algebra, but leaves the operational roadmap open.
2. Introduce a finite participant machine with stable identities, then a recursive
   group machine related to it by a step simulation. This is recommended: it makes
   failure, histories, boundaries and grouping independently testable.
3. Introduce a general process calculus with dynamic participants, name generation,
   nested transactions and asynchronous contexts. This would combine several open
   dependencies and obscure whether the present finite laws are proved.

Use the second approach, preserving each existing operator's semantics and the
historical statements. Do not turn a sequential group, an interleaving group and
an atomic boundary into three spellings of one operator.

## Shared notation and observation contract

The formulas below are proposed theorem statements, not declarations that already
exist. Fix finite `P`, `A`, `D`, a trusted `Composition.Config`, a complete initial
`World`, and trusted boundaries. Introduce a finite participant type `B` with a
fixed duplicate-free enumeration, a branch family `branches : B → List Invocation`,
and `boundaries : B → Nat → Boundary`. A participant identifies an execution
stream, not necessarily a component: several streams may invoke the same
`ComponentId`. Reparenting must preserve these stream identities.

For invocation-only parallel/interleaving execution, capabilities are fixed.
Sequential composition may contain `issue` and `revoke` and must propagate the
whole store; this distinction is retained. Environment truth and authentication
are assumptions. No theorem derives oracle truth or grants consent from a ledger
frame.

Define explicit observation projections before equivalence laws. A sequential
cursor observation contains its final world, ordered event observations, ordered
output snapshots, next index and exact located failure. A multi-participant
observation contains the final world and those local observations indexed by
stable participant. Global attempt order is a separate trace observation. Atomic
public observations preserve committed versus aborted kind, transaction identity,
exact committed state/store, failures and committed receipts/outputs according to
the accepted Atomic API. Aborted diagnostics are a different observation type.

Use existing `Parallel.EventObservation` and `BranchObservation` fields wherever
possible. They deliberately omit raw intermediate event worlds, which can differ
under independent scheduling. Keep exact request, receipt, output and failure
fields. A theorem equating canonical outcomes is not a theorem equating attempt
orders. Prove reflexivity, symmetry and transitivity, plus correspondence with any
public executable comparison. Prove contextual substitution only for an explicitly
restricted context grammar and state its visible projection.

For extension, define a second observation `Obs(S, K)` projecting ledger cells to
protected set `S` and participant observations to old participants `K`. Initially
compare the entire capability store, since it is unchanged in invocation-only
runs. Full-world equality is inappropriate when a new component legitimately
changes its own unrelated cells. Diagnostic traces and newly introduced stream
identities are not silently quotiented in the old full observation.

## Increment M1: continuation, configuration extension and observations

Proposed files under a new `DefiKernel.Metatheory` namespace:
`Observation.lean`, `Configuration.lean`, `SequentialGroups.lean`, dedicated
`Examples.lean`, `Tests.lean` and `Verify.lean`. Freeze only this increment's scope
in its initial OpenSpec; later files are separate changes.

First define a recursive sequential group syntax with empty, single-step and
sequence nodes. Its executor must call `Composition.advance` for a leaf and pass
the complete returned cursor to the next child. It must not call `run` at each
child, reset a local index or reconstruct a history from live state. Prove

```text
runSeqGroup cfg boundary cursor group
  = continueRun cfg boundary cursor (leaves group).
```

Then derive actual cursor equality for `(g₁ ; g₂) ; g₃` and
`g₁ ; (g₂ ; g₃)`, including prior-output requests, failed cursors and administrative
steps. This is a genuine but narrowly scoped sequential grouping theorem because
the recursive executor correspondence is proved. It says nothing about parallel
regrouping, new atomic boundaries or a binary wrapper that restarts children.

Next define `ConfigExtendsOn old new U`: both catalogs validate; old operation and
component lookups used by request set `U` return identical templates/interfaces;
old component access declarations remain identical; trusted domain administrators
agree where administrative steps are admitted. Use one fixed identity universe
initially. Configuration extension does not enlarge `P`, `A` or `D`.

Prove exact `executeStep` equality for every old step, same full world, same
boundary/index/history, and the stated lookup preservation. Include errors, not
just successful results. Derive `continueRun` equality for old programs whose
invocations/administrative operation references lie in `U`, and then old parallel
and interleaving admission/execution correspondence. Lift reference-set membership
through every submitted suffix, including unreachable operations. Extending an
invalid catalog is not covered by a premise that both catalogs validate.

Acceptance examples: three sequential groups with producer/consumer snapshots;
revoke in group one and denied invocation in group two; middle refusal with inert
suffix; boundary index-dependent actor/time; unrelated valid catalog extension;
invalid added component causes `.configuration`; changed old registry lookup
breaks equality. For the invalid case, record the exact failure rather than
claiming the extension theorem applies.

## Increment M2: operational interface and binding preservation

Proposed files: `Interface/Accounting.lean`, `Interface/Bindings.lean` and fixtures.
Keep the historical integer `Interface.St` and its theorem unchanged.

For finite same-asset/domain balance region `L`, define
`BalanceSum L state = ∑ c ∈ L, state.balance c`. Define `ReceiptDelta L receipt`
from actual evaluated deltas at those cells, with repeated targets summed. Prove
for actual successful invocation outcomes:

```text
BalanceSum L post.state = BalanceSum L pre.state + ReceiptDelta L receipt.
```

Derive the no-net-port-flow rule under explicit confinement and
`ReceiptDelta L receipt = 0`, and lift it over accepted events of actual runners.
For an invariant `BalanceSum L state = declaredTotal state`, require explicit
support for `declaredTotal` and no writes to that support. A ghost fixed parameter
is a simpler separate specialization. `Typed.State` has a derived asset total;
it does not contain the historical independent `sup` field. Do not introduce a
shareable bookkeeping balance and pretend it is automatically protected. Allow
nonzero authorized supply through the receipt accounting law; neutrality remains
an additional property, not a consequence of typing or interface validity.

The existing resource model identifies an imported resource with an exact exported
cell. A global binding predicate may state equal typed observations at two named
ports, but an equality assertion does not make two distinct cells aliases.
Initially restrict runtime resource sharing to existing exact-cell imports;
additional bindings are invariants to preserve. Bindings connect matching units
and domains and carry global names independent of a binary cut. State explicitly
whether an edge denotes identity of one cell or a demanded equality between two
cells. Implementing quotient storage or alias rewriting is outside this increment.

For a finite global binding set `E`, prove initialization and actual-step
preservation imply `∀ prefix, Agrees E reachedState`. Derive global constraint
union/reorientation laws at the predicate level; lift them to preservation
obligations by explicit pointwise implications. The original symmetric-closure
criterion is sufficient, not necessary: transitive equalities may make different
edge sets logically equivalent. Do not advertise a complete semantic equivalence
decider from symmetric closure equality.

Acceptance examples: a nonzero quantity-neutral transfer through two shared ports;
a private total/support region preserved despite live shared writes; a supply or
cross-boundary transfer that breaks neutrality; the writable-total negative
companion in the new typed setting; a three-participant skip binding retained
across a binary cut; equal-at-entry distinct cells broken by a one-sided write.
Use an actual accepted receipt for the breaking transition. A rejected access
attempt cannot witness violation of a preservation law.

## Increment M3: finite participant execution and causal interference

Proposed files: `Nary/Schedule.lean`, `Nary/Execution.lean`, `Nary/Soundness.lean`,
`Nary/Interference.lean`. Use invocation-only branches, fixed capabilities and
explicit finite schedules. Admission validates the catalog once, analyzes every
branch in the fixed participant enumeration, then checks complete occurrence
counts. Preserve exact first failure precedence. Each token consumes a static
slot; a refused stream is inert while peers continue, as in Sprint 7.

Define a machine with one shared world, local state indexed by `B`, and a global
attempt trace. Prove token-by-token soundness, branch histories from own accepted
receipts, local index/consumed-slot correspondence, exact refusal stability,
accounting and supported frames. Embed the existing binary `BranchId` and prove
an actual binary-runner correspondence, including admission errors and all stored
fields after the agreed identity projection. A list of independently executed
worlds is not this shared execution semantics.

Generalize the existing initialized rely/guarantee theorem to `B`. For invariant
`Iᵢ`, guarantees `Gᵢ` and relies `Rᵢ`, require initialization, local obligations for
actual selected invocations, `Gᵢ ⊆ Rⱼ` for every distinct pair, and stability of
`Iⱼ` under `Rⱼ`. Prove all initialized invariants at every actual finite prefix.
The local proof uses its own invariant, not a premise that all peer invariants
hold at the end. Failure/skip steps preserve the ledger by identity. A finite
participant induction establishes the vector invariant, not pairwise whole-run
circular implication.

Add a separate causal rule rather than weakening that theorem invisibly. Introduce
an explicitly defined monitor `q` of the actual finite execution prefix. Its update
uses the current selected boundary and actual outcome only; it cannot read future
schedule outcomes. A joint induction invariant `K(q, machine)` must prove:

1. `K` holds at the initialized machine/monitor, and implies each desired `Iᵢ`.
2. For the next selected invocation, `K` plus a stated *current* external premise
   entails its local assumption `Aᵢ(q, pre, boundary)`.
3. The local semantic obligation uses `Iᵢ`, that assumption and actual `StepSound`
   to derive own preservation and `Gᵢ`.
4. `Gᵢ`, peer relies/stability, and the concrete monitor update establish `K` at the
   next machine. Refusal and skip monitor updates have their own identity cases.

Environment facts not implied by prior kernel execution remain visible external
premises. State a separate success/enabledness obligation if success is claimed:
`StepSound` conditions only successful outcomes and does not prove progress. A
schedule may make a causal assumption false; a runtime check can then refuse, or
the theorem must explicitly restrict admissible schedules. Never assume the
future successful run as the way to establish its assumptions.

Acceptance requires a funded causal producer/consumer example in which the local
proof genuinely needs the established bound, unlike the USD-total instance whose
local invariant antecedent is unnecessary. Demonstrate that dropping the causal
assumption admits an actual violating state/step. Include missing initialization,
missing peer stability, and circular `A₁ iff G₂`, `A₂ iff G₁` with both facts false.
A concrete causal instance can protect a USD4 reserve in a vault initially holding
USD10. A producer exposes a typed budget snapshot6; the consumer transfers that
snapshot amount with the ordinary sufficient-balance guard. The local reserve
proof additionally requires `amount ≤ currentVaultBalance - 4`. A monitor records
the actual budget fact, while peer stability restricts intervening vault changes
to deposits or proves an updated bound. The correct transfer leaves4. Without
the causal bound, an otherwise authorized transfer7 succeeds and leaves3: an
actual invariant violation, not merely an unavailable-history refusal. The
producer's budget correctness and its preservation until consumption are explicit
proof obligations; printing a snapshot does not itself establish either.

For trace-dependent monitors, include a refused producer that emits no usable
fact and a successful producer from the wrong stream. These are separate from
compiler errors and finite positive controls.

## Increment M4: operational regrouping and disjoint schedule independence

Proposed files: `Nary/Groups.lean`, `Nary/GroupSimulation.lean`,
`Nary/DisjointRecovery.lean`. This depends on M3; interface well-formedness from M2
provides the globally named binding context.

A group tree partitions the same finite participant set into disjoint leaf sets.
Each leaf appears exactly once; empty groups are explicit. Configuration, binding
set, participant enumeration and boundaries are global immutable parameters, not
rebuilt at internal nodes. A group machine keeps tree-shaped local states and one
shared world. Its token dispatcher recursively finds the named leaf, passes the
current world to that leaf, and returns the changed world and only that leaf's
updated local state. Dispatch routing is implemented independently of flattening.

Define a representation relation between this tree machine and M3's flat machine:
world/store agreement; pointwise local state/history/index/failure agreement under
leaf identity; equal global attempts and static consumption. Prove initialization,
one-token simulation in both directions, and continuation simulation. Admission
uses the same global canonical ordering; a group-local validation order would
change which malformed suffix is reported.

Derive, for two well-formed groupings `T` and `T'` with the same named leaves and
same schedule `s`:

```text
Obs(runGroup T cfg boundaries initial s)
  = Obs(runGroup T' cfg boundaries initial s).
```

This is representation independence of actual shared execution for a fixed
schedule, and can hold even with shared writes. It neither reorders tokens nor
allows a parent group to halt because one child refused. A group that runs a whole
subtree atomically is a different operator and is not covered.

For pairwise compatible analyzed footprints, prove a second, stronger law:
all complete schedules have the same canonical per-participant observation and
final world, and match a separately defined disjoint executor. That executor runs
leaves independently from the same entry world and merges only their disjoint
write regions; define and prove recursive group-merge correspondence. Do not
compare raw intermediate event worlds or global attempt sequences across orders.
Prove pairwise compatibility implies compatibility of each subgroup's footprint
union; this connects binding/group algebra with the actual dependency proof.

Acceptance: three nonempty streams with two invocations each; several groupings
and all 90 complete schedules for this bounded fixture; successful and refused
streams; snapshots sharing a qualified key in distinct histories; index-dependent
boundaries; an empty group; duplicate/missing leaf rejection; three-party global
skip binding; and the shared USD10 competition showing schedule independence is
false without compatibility. Full expected observations must be independently
constructed for selected financial cases, not all obtained by calling the flat
executor being proved equivalent.

## Increment M5: conservative execution extension and contextual substitution

Proposed files: `Extension/Projection.lean`, `Extension/Execution.lean`,
`Extension/Contexts.lean`. It depends on M1 and M3/M4.

Separate adding declarations from executing additional participants. M1 handles
declarations. For active additions, retain a fixed identity universe, valid
catalog extension and stable lookups; old boundaries, branch histories and
capabilities agree. Let protected set `S` contain all old analyzed reads, writes
and snapshot cells. Every added stream's analyzed writes avoid `S`. Stronger
pairwise compatibility may be used for the first theorem, but state it as stronger
than one-way preservation of old behavior.

For an admitted extended schedule `s`, let `restrict K s` delete tokens of new
participants. Prove after every prefix, old local observations and ledger on `S`
match the old runner on `restrict K prefix`. The simulation treats a new step as
stuttering only under this projection; the new step may change its own state and
may refuse. Prove restricted complete schedules are complete. Include exact old
failure reasons, successful-prefix receipts and frozen outputs, not just final
invariants. The theorem imposes no success condition on new peers in ordinary
interleaving because a peer's refusal does not halt the old streams.

Contextual equivalence is quantified over a declared grammar of contexts that
preserve these hypotheses. First admit sequential continuations that consume the
same projected cursor interface and compatible interleaving peers. A context that
reads an omitted ledger cell, directly inspects omitted diagnostic worlds, changes
an old capability, or adds a transaction-wide abort boundary is excluded. Prove
congruence for each constructor from actual executor correspondence. Do not call
one endpoint equality a general full-abstraction theorem.

Acceptance: new participant changes unrelated collateral and may refuse while old
observations remain exact; new participant writes an old snapshot cell and breaks
equivalence; initial protected balances differ and break a guard; malformed added
catalog entry blocks admission; additional capability entry changes the next
issued ID. The last case establishes why administrative extension needs a distinct
identity-renaming/provenance theory, not a ledger-only disjointness argument.

## Increment M6: atomic boundaries and metatheory transfer

This increment depends on the accepted Atomic implementation and M1–M5 as needed.
Inspect its real APIs before freezing file names or theorem statements. Transfer
the finite participant/group simulation to atomic speculation only if transaction
identity, policy, participant table, schedule, global failure position and the
single outer commit boundary are unchanged. The monitor of clearing obligations
must correspond after every accepted speculative receipt, with the same principal
partition and asset/domain lane admission. Prove equality of the final commit or
abort projection; do not infer it only from equal final balances.

Regrouping routing within one transaction may preserve behavior. Moving a commit
boundary generally does not: with entry Alice USD10, an authorized transfer7 to
Bob followed by a refused transfer6 to Carol rolls back Alice to10 inside one
atomic event; two separately committed events retain Alice3/Bob7 before the second
aborts. Reassociation of transaction boundaries needs an explicit restricted law
or remains a negative result. Transient draw/return pairs can similarly settle
within a whole event yet fail if an inner boundary demands early settlement.

Atomic conservative extension is stricter than interleaving extension. A disjoint
added participant that refuses aborts the entire event. To preserve old committed
behavior, the first theorem must require added operations to succeed along the
relevant executions, preserve protected reads, and satisfy the accepted settlement
policy at the same boundary. Prove these success/settlement premises independently
in a concrete instance. If old observations retain the supplied global schedule or
participant list, use an explicitly restricted old-observation projection; raw
atomic observations cannot be equal after adding new identities or receipts.

No automatic cross-transaction export of aborted snapshots, committed mint count
from tentative receipts, or empty-lane witness of meaningful transient accounting
is allowed. Nested savepoints, callbacks and arbitrary multi-vault settlement stay
outside these laws unless given their own operational semantics and gate.

## Dependencies, counterexamples and evidence obligations

M1 and M2 can be planned independently after the shared source is accepted. M3
reuses their observation/interface decisions; M4 requires actual M3 execution;
M5 requires M1 configuration correspondence and M3 prefix simulations. M6 waits
for the actual Atomic contract. The initialized basic n-ary rule and richer causal
monitor rule may be separate OpenSpec changes if the latter's financial instance
expands the scope. No increment is accepted by checking off a later roadmap item.

Keep these false stronger laws as named negative companions:

| False claim | Defeating case |
| --- | --- |
| Every grouping is behaviorally interchangeable | Restarted child loses a prior output or uses boundary index zero; nested commit changes rollback |
| Disjoint writes suffice for commutation | One stream writes a cell read by another's guard or output snapshot |
| Arbitrary shared schedules agree | USD10 vault, competing withdrawals7 and6 |
| Same-type ports imply safe sharing | Foreign write changes the independent declared total; quantity neutrality omitted |
| Binding equality at entry persists automatically | Distinct equal cells, accepted one-sided write |
| Symmetric closure equality completely decides constraint equivalence | Transitive equality makes an extra edge redundant despite unequal symmetric closures |
| Circular assumptions discharge themselves | Both promised facts false, each conditional implication still true |
| Unrelated catalog entries cannot affect old execution | Global catalog validation rejects a new duplicate/invalid component |
| Disjoint administration preserves exact receipts | Appending a capability changes `nextId`; revocation changes point-of-use permission |
| A disjoint new atomic participant cannot affect old behavior | New participant refuses, causing transaction-wide rollback |

Dynamic capability provenance is a separate dependency. A future theorem should
relate every live/revoked entry to an authorized actual issue event or explicitly
trusted initialized entry, preserve tombstones and non-reuse, and establish use
against the current store. It needs actual administrative trace induction and a
policy for concurrent fresh IDs, revocation and atomic rollback. Ledger-only
frames and today's fixed-store parallel theorem cannot supply it. Component
information-flow isolation additionally needs an observation/read support policy;
`canWrite` denial alone is not noninterference.

For each implemented increment, require: actual Lean theorem inventory with full
premises and module provenance; no `sorry`, custom axioms or `native_decide`;
nonempty named runtime checks; separately proved or executed negative companions;
real production mutations for world/store/history/index routing, exact refusal,
configuration lookup and observation fields; positive controls that remain true;
and prior accepted regression suites. Enumerating 90 schedules is bounded
execution, not the generic theorem. Mutation detection is evidence that tests
exercise the changed semantics, not a proof of the theorem. Compiler typing
refusals, arithmetic reference models and deployed fidelity remain separate.

Before implementation, each frozen plan must identify its concrete source files,
exact theorem statements, independent financial oracles, mutation expectations,
accepted baseline revision and source-preservation manifest. Future names in this
note are proposals. The current findings support a bounded metatheory program;
none close the roadmap before the corresponding executor/proofs and native gates
are complete.
