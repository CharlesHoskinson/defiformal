## Context

Base: `850d785d41dc311785dc33cdb3f65c368756434c`, branch
`semantic-kernel-pivot`. See [proposal](proposal.md). Existing
`Composition.executeStep` supplies exact refusal precedence, post-state snapshots,
receipts and `StepSound`. `Parallel.analyzeBranch` supplies whole-branch structural
checks and conservative footprints. `Parallel.runParallel` rejects overlapping
footprints and merges independent executions; it remains unchanged.

## Goals / Non-Goals

Build a deterministic evaluator for each finite supplied schedule and generic
proofs across all such schedules. Keep executable admission, proved conditional
invariants and bounded fixture enumeration separate. Trust in the catalog,
registry, authenticated boundaries, observations and initial capability store
remains explicit. Non-goals are in the proposal.

## Decisions

### 1. Schedules and preflight

Reuse `Parallel.BranchId`, invocation-only `Branch` and `ParallelBoundary`.
`Schedule := List BranchId`. A complete schedule contains exactly `left.length`
left tokens and `right.length` right tokens. Each token denotes the next static
slot of that branch, so local order is built into the representation. A branch
that has refused consumes later tokens as skipped slots without retrying.
This separates schedule validity from state-dependent success.

`checkSchedule` returns an exact count-mismatch record (expected/observed counts
for both branches) or success. `admit` checks catalog validity, complete left
structural analysis, complete right structural analysis, then schedule counts.
Structural refusals keep the existing local failure index and reason; schedule
refusal is a distinct constructor. Footprint overlap does not reject execution.
Any preflight refusal returns the initial world and no events or branch outputs.
Analyze unreachable suffixes just as Sprint 6 does.

Alternative A, chosen: explicit complete finite schedules with skipped failed
suffix slots. Alternative B: an adaptive scheduler selecting only live branches
would make replay and completion depend on runtime results. Alternative C:
transactions with rollback would conflate this increment with atomic settlement.

### 2. Shared execution and observations

`Machine` contains one `world`, left/right local branch state, and an ordered
global attempt log. Local branch state contains a static consumed-slot count,
successful `Composition.Event` list, local output history and first
`Composition.LocatedFailure`. The consumed count advances on each token, even
after refusal; successful `nextIndex` in canonical branch observations remains
the number of successful invocations, matching Sprint 6.

`advance` obtains the invocation at that branch's consumed slot. For an active
branch it calls `Composition.executeStep cfg (boundaries branch localIndex)
localIndex ownHistory (.invoke invocation) machine.world`. Success replaces the
one shared world, appends the real event and own post-state outputs, and increments
the branch's successful index. Refusal keeps the shared world and outputs,
records the exact located failure, and halts only that branch. A skipped token
changes only the consumed count; it has no attempt event. The internal evaluator
is total on arbitrary token lists: tokens beyond a branch length also skip;
the public evaluator admits only complete schedules. This totalization is not a
public acceptance of malformed schedules.

Every attempt records branch, local index, selected invocation, pre-world and
either the complete successful step result or exact refusal. Successful branch
events are the corresponding projection of that global log. Peer histories are
never concatenated. Snapshot values are frozen at their producing step; later
expressions reading ledger state see the current shared world. Fixed boundaries
are indexed by branch/local position, never global position. Boundary timestamps
are supplied observations; no monotonic global clock or oracle truth is inferred.

The full result exposes initial admission versus an executed machine, the supplied
schedule, complete final ledger/store, consumed slots, global attempts, and both
branch observations. Comparison for disjoint recovery deliberately projects away
global schedule/attempt order, consumed failed suffix slots, and raw foreign
pre/post worlds. It retains exact final ledger/store and the existing complete
`Parallel.BranchObservation` fields (events, requests, evaluated receipts, typed
outputs, successful next index and exact located failure). This projection is
named and never described as equality of the full shared execution trace.

### 3. Soundness and preservation

Define an inductive machine reachability relation mirroring successful attempts,
failed attempts and skipped slots, and prove the actual evaluator produces it.
Each successful transition includes the real `executeStep = .ok result` witness;
each refusal includes `executeStep = .error reason`. Prove branch-local order,
history isolation, attempt-prefix continuity, refusal stability, skipped-slot
inertia, immutable capability store, and completion of both static slot counts
for admitted schedules. The trace witness must connect actual initial/final worlds,
not merely certify unrelated individually valid receipts.

Use `executeStep_sound` and existing `StepSound` lemmas to prove, for every
evaluated schedule prefix, per-domain/asset final total equals initial total plus
the sum of actual successful receipt supplies. Failed/skipped slots contribute
zero. Prove every success is authorized at its actual pre-world and trusted local
boundary, hence under the fixed initial capability store. Record nonnegativity
as reuse of proof-carrying `State` witnesses for every reached world.

Prove final balance agreement outside the union of actual successful writes and
outside the union of both analyzed branch write footprints. Lift this to every
ledger predicate supported on a protected region disjoint from those writes.
Admission refusal has identity laws. Failure attempts and skipped slots preserve
the entire ledger, not just a protected region.

### 4. Explicit interference obligations

Use ledger predicates `I_left`, `I_right` and relations `G_left`, `G_right`,
`R_left`, `R_right` on pre/post ledgers. Relations describe successful invocations;
refusals/skips are identity cases and need no supplied relational witness.

For each branch b, require a local obligation over **all** branch positions,
histories and worlds with `I_b pre`, for the branch invocation at that position
and the fixed trusted local boundary: a real successful step implies both
`I_b post` and `G_b pre post`. This obligation is proved independently of the
peer's invariant and of the desired whole-run conclusion. Require
`G_left ⊆ R_right`, `G_right ⊆ R_left`, and separate stability
`I_b pre ∧ R_b pre post → I_b post`. Initial state satisfies both predicates.
Induction over real attempts then proves both invariants at every schedule prefix.
This is an explicit sufficient rule, not automatic invariant discovery or an
executable decision procedure for arbitrary predicates.

Instantiate a nontrivial overlapping-support example: two transfer branches use
the same source liquidity and preserve exact total USD10; each succeeds or refuses
depending on remaining balance. Choose guarantee/rely equality of total USD,
prove local obligations from the no-supply operation templates, and establish
initialization from the concrete ledger. Also show why initialization and peer
stability cannot be omitted using concrete counterexamples. A second protected-
collateral predicate demonstrates the supported frame rule.

### 5. Recovery of disjoint composition

For every pair accepted by existing `Parallel.admit` and every complete schedule,
prove the shared result's canonical projection equals `Parallel.runParallel`,
then derive equality with its actual LR/RL references. Do not assume this equality
or success of every invocation as a premise. Use a prefix simulation: track each
branch's isolated cursor, own history and region agreement; prior peer writes
frame its dependencies. Reuse `Parallel.Dependency.Adapter` step congruence and
the analyzed footprint lemmas. Raw event worlds may differ outside the dependency
region. Refusal equality and stopped branches are mandatory cases.

Prove empty/one-empty laws and full-block LR/RL schedule agreement. Include a
shared-source counterexample whose schedules produce different branch outcomes;
no equivalence theorem is claimed outside the compatibility premise.

### 6. Financial examples and discriminating evidence

All fixtures use exact rational arithmetic, funded and authorized controls,
complete expected worlds/stores and exact outcome fields. Required families:

1. USD10 shared-source transfers: left withdraws7 to Alice, right withdraws6 to
   Bob. LR leaves source3/Alice7/Bob0 and right insufficient-funds; RL leaves
   source4/Alice0/Bob6 and left insufficient-funds. All other cells remain fixed.
2. Replenish then withdraw: a branch deposits liquidity before a peer withdrawal;
   reversing order refuses the withdrawal, without retry after replenishment.
3. Multi-step state-dependent effects: a peer changes a ledger value between own
   steps; live reads use the new value while previously emitted outputs stay fixed.
   Independently expected full receipts discriminate stale-world evaluation.
4. Branch history isolation: identical fully qualified output keys may now have
   different values at different interleaved states. Own lookups retain the own
   snapshot. A peer-only producer is rejected beside a successful own/literal
   sibling. Check component qualification, typed units and local indices.
5. Immediate/middle/dual refusals, skipped suffix, successful peer continuation,
   empty branches, malformed schedules and malformed unreachable suffix.
6. Independent supply changes, protected collateral, local principal/time binding,
   unauthorized access and pre-fork revoked-capability siblings.
7. Disjoint 2+2 invocations: enumerate all six schedules, compare each with an
   independent expected world and existing parallel observations. Also include
   refused disjoint multi-step branches. These finite examples supplement the
   general Lean recovery proof.

Fourteen required semantic source mutants, each with a distinct designated
runtime oracle and a protected successful sibling: schedule-count bypass;
reintroduce overlap rejection; stale initial-world execution; replace shared world
with an isolated branch result; global cancellation on one refusal; prefix rollback;
retry halted suffix; peer-history leakage; output snapshot recomputation;
global-position boundary lookup; wrong branch-local invocation selection;
drop a successful peer receipt from accounting aggregation; resurrect revoked
capabilities; canonical observation omission of exact failure. Where a mutant has
overlapping oracle coverage, report that dependence. Mutation 14 must alter the
actual comparison/projection consumed by public recovery checks, and a negative
observation control must distinguish the changed failure beside an equal pair.

The runner uses fresh proof-stripped source projections, compiles actual mutant
production code, executes the entire named inventory, and requires designated
false comparisons plus protected true comparisons. A compile failure, malformed
log, absent/duplicate label, no-op edit, survivor or stale source is never counted
as detection. Include actual CLI accepted, failed and blocked controls following
the established Parallel runner pattern, without changing its accepted scope.

### 7. File and proof boundaries

New files under `lean/DefiKernel/Interleaving/`:
`Schedule.lean` (preflight/count laws), `Execution.lean` (machine/runner),
`Soundness.lean` (actual trace witness and structural laws), `Preservation.lean`
(accounting/authority/frame), `Interference.lean` (conditional rule),
`Recovery.lean` (disjoint simulation), `Examples.lean` (reference definitions),
`Tests.lean` (named comparisons/counterexamples), `Audit.lean` (runtime),
`Verify.lean` (automatic imported theorem/supplemental declaration audit).
Split a module further only at an independent responsibility boundary.

Add `scripts/check_interleaving_mutations.py`,
`scripts/test_interleaving_mutation_runner.py`, a frozen mutation spec and evidence
under `review/semantic-kernel/sprint7/`. Preserve every historical Lean/corpus file;
the import root and current documentation are intentional updates. If a reusable
new helper is needed for old code, place it in the new namespace initially.

## Risks / Trade-offs

- Strong local universal premises can be harder to instantiate than reachable-only
  assumptions → provide the concrete overlapping example and expose the strength.
- Generic disjoint recovery is the largest proof → implement its prefix simulation
  before declaring the scope achievable; finite tests cannot replace it.
- Exact shared output-key collisions were impossible in Sprint 6 → construct
  different snapshots via actual peer writes, not invented impossible fixtures.
- Extensive test counts can obscure oracle overlap → publish named inventories,
  individual mutation outcomes and separate generic proofs from examples.
- Fixed capabilities omit revocation races → retain this boundary explicitly.

## Migration Plan

Save and strictly validate proposal/design/specs/tasks. Freeze candidate and review
bundle in Git; obtain separate GPT-6 stock-harness and native Fable 5.1 planning
verdicts. Implement only after both pass and a current baseline succeeds. Initial
review plus one targeted revision is the default budget; extend only for a concrete
unresolved finding. Unavailable/incomplete reviews remain open.

Use the established branch, full legacy regressions, fresh axiom coverage and
native Grok/Fable implementation audits. Record exact candidate and model identity,
raw requests/responses, findings and fixes. Push the branch and verify the remote;
archive only after all tasks and gates pass. Wiki notes are a decision index, never
a replacement for specs or hash-bound evidence. Rollback is removal/revert of the
new namespace/import through a subsequent commit; no historical rewriting.
