# Independent Sprint 7 planning audit

Candidate: bf3fb509b211d7cd92eb68410fb49dc5f4e20e7d
Base: 850d785d41dc311785dc33cdb3f65c368756434c

Audit this exact OpenSpec proposal/design/specs/tasks for implementability, consistent semantics, nonvacuous generic proof obligations, feasible financial fixtures and real production mutation oracles. This is planning/source review, not a claim of new implementation. No Sprint 7 Lean or runner code exists. Existing code below is baseline context. Prior reviews are deliberately excluded.

Return plain prose only: verdict ACCEPT, ACCEPT WITH LIMITATIONS, or REQUEST CHANGES; ranked blockers with exact file/section and smallest concrete correction; nonblocking limits; scope reviewed. No tool calls, markup pretending to call tools, hidden analysis, or requests for files. All inputs follow in full. You have no tools; do not claim execution or unprovided provider identity. You must deliver a substantive final report.

Threat model: realistic collaborator errors (stale evaluation, wrong history/index, false pass, incomplete proof scope), not an attacker replacing all code and evidence. Initial review plus one targeted revision budget; identify material blockers rather than speculative breadth. Fixed capability store, finite binary schedules and advisory review are intentional limits. Require every complete disjoint schedule proof with exact refusals; bounded examples do not replace it. Runtime overlap acceptance is separate from conditional interference invariants. Assess whether mutation targets truly admit designated discriminating oracles; do not count compile failures as semantic detections.


--- BEGIN FILE openspec/changes/shared-state-interleaving/.openspec.yaml ---
schema: spec-driven
created: 2026-09-07

--- END FILE openspec/changes/shared-state-interleaving/.openspec.yaml ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/design.md ---
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

--- END FILE openspec/changes/shared-state-interleaving/design.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/proposal.md ---
## Why

Sprint 6 proves composition for disjoint branches, but financial workflows often
compete for the same liquidity or observe balances changed by a peer. We need
explicit shared-state execution and conditional preservation across schedules,
including different success/refusal outcomes when order matters.

## What Changes

- Add finite binary invocation interleaving over one evolving world, with separate
  local histories, stable trusted boundaries and retained successful prefixes.
- Validate complete schedules and structural interfaces before execution; permit
  overlapping footprints. Keep runtime admission distinct from proof obligations.
- Define successful-event interference relations and initialized, noncircular
  rely/guarantee premises; prove accounting, authority, locality and invariants.
- Recover Sprint 6 canonical observations for every complete disjoint schedule.
- Add independently specified financial fixtures, production source mutations,
  axiom coverage, exact review records and a linked `wiki-llm/` decision record.

## Capabilities

### New Capabilities

- `interleaving-execution`: schedules, shared execution, refusal and observations.
- `interleaving-preservation`: sound traces, interference and preservation proofs.
- `interleaving-disjoint-recovery`: correspondence to disjoint parallel behavior.
- `interleaving-regression-evidence`: financial checks, mutations and review gates.

### Modified Capabilities

None. Existing sequential and disjoint parallel requirements remain intact.

## Impact

New Lean modules live in `lean/DefiKernel/Interleaving/`; the kernel import root
adds their verification driver. New scoped mutation tooling and evidence live in
`scripts/` and `review/semantic-kernel/sprint7/`. Roadmap/progress and wiki notes
track accepted work. Exact rational arithmetic and existing dependencies remain.

## Non-goals

Atomic synchronization, rollback, capability issue/revoke inside branches,
capability provenance, unbounded fairness/liveness, arbitrary shared-state
schedule equivalence, N-ary associativity and deployed-protocol fidelity are
separate work. These examples are development cases, not untouched holdouts.

--- END FILE openspec/changes/shared-state-interleaving/proposal.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/specs/interleaving-disjoint-recovery/spec.md ---
## Purpose

Relate shared execution to accepted disjoint parallel semantics without equating order-sensitive shared-state outcomes.

## ADDED Requirements

### Requirement: Universal disjoint recovery

For every pair admitted by existing disjoint parallel admission and every complete finite schedule, the named canonical projection of shared execution SHALL equal the existing parallel observation, including exact refusals and retained prefixes. The theorem SHALL derive this result from dependency/frame proofs rather than assume commutation or success-only premises.

#### Scenario: All disjoint schedules

- **WHEN** any complete schedule interleaves structurally accepted branches with compatible footprints
- **THEN** the generic theorem identifies its complete canonical observation with the existing parallel and LR/RL reference observations

#### Scenario: Disjoint refusal

- **WHEN** one disjoint branch refuses in the middle while its peer continues
- **THEN** recovery preserves the same local failure, own successful prefix and complete peer outcome

#### Scenario: Six concrete schedules

- **WHEN** two disjoint branches each have two invocations
- **THEN** all six complete schedules also match independent expected worlds and canonical branch observations in bounded execution

### Requirement: Empty and serial specializations

The system SHALL prove empty/one-empty identity laws and full-block LR/RL schedule correspondence under the same admission and canonical-observation boundaries. It SHALL retain concrete counterexamples to arbitrary shared-state schedule equivalence.

#### Scenario: Empty peer

- **WHEN** one branch is empty and the other succeeds or refuses
- **THEN** the shared observation agrees with its existing sequential branch behavior and empty peer observation

#### Scenario: Full-block schedules

- **WHEN** all left tokens precede all right tokens or vice versa for a disjoint pair
- **THEN** the canonical result equals the corresponding existing real serial evaluator

#### Scenario: Order-sensitive shared state

- **WHEN** two withdrawals compete for insufficient combined liquidity
- **THEN** LR and RL have different independently checked successful/refused branches, so unrestricted equivalence is refuted

--- END FILE openspec/changes/shared-state-interleaving/specs/interleaving-disjoint-recovery/spec.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md ---
## Purpose

Define replayable shared-state execution with exact local histories, refusal outcomes and explicit schedule validity.

## ADDED Requirements

### Requirement: Complete finite schedules

The evaluator SHALL accept finite binary invocation-only branches and a schedule with exactly one token per static invocation slot of each branch. Tokens SHALL select branch-local slots in order. Invalid counts SHALL produce a typed preflight refusal with expected and observed counts for both branches.

#### Scenario: Balanced schedule

- **WHEN** both branches contain two invocations and the schedule is left,right,left,right
- **THEN** preflight accepts the schedule and each branch consumes its two slots in local order

#### Scenario: Missing and excess slots

- **WHEN** a schedule omits a right slot or adds a left slot, including extra tokens for an empty branch
- **THEN** preflight refuses with exact expected/observed counts before any execution

#### Scenario: Empty schedules

- **WHEN** both branches and the schedule are empty
- **THEN** execution returns the initial world, empty attempts and empty branch observations

### Requirement: Structural admission permits shared state

The evaluator SHALL check configuration, the complete left branch, the complete right branch, then schedule counts in that order. It SHALL preserve exact structural failure location and reason, including in unreachable suffixes. Overlapping footprints SHALL NOT itself refuse execution. Every admission refusal SHALL preserve the initial world and emit no attempts or outputs.

#### Scenario: Overlapping funded branches

- **WHEN** two structurally valid funded and authorized branches write the same cell
- **THEN** preflight admits them without requiring disjointness or proof of an invariant

#### Scenario: Unreachable malformed suffix

- **WHEN** an early invocation would financially refuse but its branch has an unknown operation later
- **THEN** the whole-branch structural check refuses at the later local index without executing the prefix

#### Scenario: Preflight precedence

- **WHEN** configuration, structural and schedule errors coexist
- **THEN** the first error in configuration-left-right-schedule order is returned

### Requirement: One evolving shared world

Each active scheduled invocation SHALL execute against the current shared world through the existing trusted single-step semantics. Successful attempts SHALL update that world and emit their actual complete receipts and post-state snapshots. Boundaries SHALL depend only on branch identity and local invocation index. The capability store SHALL remain equal to the initial store.

#### Scenario: Competing liquidity

- **WHEN** left withdraws7 and right withdraws6 from shared USD10 under LR and RL schedules
- **THEN** LR leaves source3/Alice7/Bob0 with right insufficient-funds; RL leaves source4/Alice0/Bob6 with left insufficient-funds, preserving all other cells and the full capability store

#### Scenario: Replenishment order

- **WHEN** one branch funds liquidity before or after a peer withdrawal
- **THEN** the withdrawal observes the balance at its actual attempt and a refused withdrawal is not retried after replenishment

#### Scenario: Local boundary identity

- **WHEN** a multi-step branch is shifted in global schedule position while local trusted inputs are fixed
- **THEN** each attempted step uses its original branch-local principal, environment and time

#### Scenario: Revoked authority

- **WHEN** the initial store differs only in a required grant being live versus revoked
- **THEN** the live funded invocation succeeds and the revoked one refuses for its exact authority reason

### Requirement: Branch-local refusal and history

The first runtime refusal SHALL halt only its own branch, retaining every earlier successful effect, receipt and output. Later tokens of that branch SHALL skip without another attempt. Peer execution SHALL continue. Input resolution SHALL use only the selected branch history with qualified keys and typed units; old snapshots SHALL remain fixed.

#### Scenario: Retained prefix and peer continuation

- **WHEN** a branch succeeds then refuses while its peer has remaining valid invocations
- **THEN** the prefix and peer effects remain, the first exact failure remains stable, and the failed suffix contributes no attempts

#### Scenario: Dual refusal

- **WHEN** both branches refuse at their own local indices
- **THEN** both exact failures remain visible and neither is replaced by the peer failure

#### Scenario: Different snapshots at the same key

- **WHEN** interleaved producers capture different balances at the same fully qualified output key in separate branches
- **THEN** each later local consumer resolves its own value and the stored snapshots do not change after peer writes

#### Scenario: Peer-only history

- **WHEN** only the peer has produced a requested output while an own-history or literal sibling supplies the correct unit and funding
- **THEN** the peer-only reference refuses for the intended missing-history reason and the sibling succeeds

### Requirement: Complete observations and prefix execution

Results SHALL expose the supplied schedule, one final world, consumed slot counts, ordered real success/refusal attempts and both branch observations. Internal finite-prefix execution SHALL be total, explicitly distinguishing skipped and attempted slots. Canonical comparison SHALL retain complete final balances/store, branch labels, ordered requests/receipts/typed outputs, successful indices and exact failures; only global order, consumed skipped slots and raw foreign event worlds SHALL be omitted by the named disjoint projection.

#### Scenario: Attempt continuity

- **WHEN** successes and refusals alternate across branches
- **THEN** every attempt begins at the previous attempt post-world or unchanged refused world and successful branch events are its branch projection

#### Scenario: Observation sensitivity

- **WHEN** two results differ only in one exact refusal, index, request, receipt, output, branch label, final balance or capability entry
- **THEN** canonical comparison distinguishes the changed field; an identical pair remains equal

#### Scenario: Skipped tokens

- **WHEN** a schedule prefix selects an already failed branch or exceeds its static length
- **THEN** internal execution changes only its consumed slot count, emits no attempt, and cannot make an invalid complete schedule publicly admitted

--- END FILE openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md ---
## Purpose

Establish actual-trace preservation and initialized interference rules for every finite shared-state schedule prefix.

## ADDED Requirements

### Requirement: Actual trace soundness

Every evaluated prefix SHALL have an inductive witness connecting its actual initial and final machines. Each success SHALL carry real single-step execution and soundness witnesses; each refusal SHALL carry its real exact failed execution. Local order, history isolation, refusal stability and immutable capabilities SHALL be proved from the runner.

#### Scenario: Prefix soundness

- **WHEN** any finite token prefix executes, including first or middle refusals
- **THEN** the proof connects actual worlds, attempts and local histories without assuming the target runner result

#### Scenario: Complete slot consumption

- **WHEN** an admitted full schedule executes despite failed suffixes
- **THEN** both consumed counts equal their static branch lengths and each branch has exhausted its invocations or retains its first refusal

### Requirement: Accounting authority and nonnegativity

For every finite prefix, total final balance in each domain/asset SHALL equal initial total plus actual successful receipt supplies. Each success SHALL be authorized at its actual pre-world and trusted branch-local boundary under the fixed initial capability store. All reached balances SHALL be nonnegative with the proof-carrying state premise stated.

#### Scenario: Supply and refusal

- **WHEN** both branches emit nonzero supply changes and one later refuses
- **THEN** the equation includes each actual successful supply exactly once and contributes zero for refusals/skips

#### Scenario: Authority at execution

- **WHEN** a funded unauthorized attempt is interleaved with an authorized peer
- **THEN** the unauthorized attempt refuses and every accepted receipt has point-of-use authority evidence

#### Scenario: Reached worlds

- **WHEN** any schedule prefix reaches a success or refusal
- **THEN** initial, intermediate and final nonnegativity are established through the state witnesses

### Requirement: Locality and supported frames

Execution SHALL preserve cells outside actual successful write footprints and outside the union of admitted analyzed branch writes. A ledger predicate SHALL be framed only with explicit support on a protected region disjoint from the relevant writes. Refused and skipped attempts SHALL preserve the whole ledger.

#### Scenario: Protected collateral

- **WHEN** overlapping USD transfers leave a separately supported collateral region untouched
- **THEN** the concrete collateral predicate and every protected balance remain unchanged

#### Scenario: Missing support counterexample

- **WHEN** a purported protected predicate depends on a cell that a valid branch changes
- **THEN** a concrete counterexample shows that the predicate cannot be framed from the stated smaller region

### Requirement: Initialized interference composition

The system SHALL prove both branch invariants at every prefix from initialization, independently proved own-step invariant/guarantee obligations, each guarantee included in the peer rely relation, and stability of each invariant under its rely relation. Own-step obligations SHALL quantify over all own-invariant worlds, histories and applicable branch positions with the fixed local boundaries. They SHALL NOT assume the peer invariant, the final result, or the desired whole-run preservation theorem.

#### Scenario: Overlapping invariant instance

- **WHEN** two competing shared-source transfer branches start at total USD10 and each guarantees unchanged USD total
- **THEN** explicit equality-of-total rely relations, local guarantees and initialization instantiate preservation of total USD10 under every schedule prefix, even when one branch refuses

#### Scenario: Initialization is necessary

- **WHEN** a preserved total predicate is false in the initial ledger
- **THEN** a concrete counterexample prevents concluding that it becomes true merely from step preservation

#### Scenario: Peer stability is necessary

- **WHEN** a locally preserved predicate is changed by an otherwise valid peer invocation
- **THEN** a concrete counterexample shows why own preservation alone cannot discharge the interference theorem

--- END FILE openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md ---
## Purpose

Bind shared-state proof and runtime claims to nonempty discriminating evidence, exact source revisions and independent reviews.

## ADDED Requirements

### Requirement: Independent financial evidence

Reference workflows SHALL check independent complete expected worlds/stores, receipts, outputs and exact failures. Evidence SHALL cover competing liquidity, replenishment, live reads versus snapshots, qualified local history, boundary identity, prefix refusal, supply, protected state, unauthorized/revoked capabilities and disjoint schedules. Development examples SHALL remain labeled as such.

#### Scenario: Full financial oracle

- **WHEN** all required example families run against the frozen source
- **THEN** every named comparison executes, full worlds/stores and intended errors match independent expected values, and the nonempty unique inventory is saved

#### Scenario: Live versus frozen values

- **WHEN** a peer changes shared state between a producer and a consumer
- **THEN** independent expected values distinguish current-ledger evaluation from own prior snapshots

### Requirement: Production mutation sensitivity

Fourteen semantic source mutations specified in the design SHALL compile and execute through the real production runner and complete named runtime inventory. Each SHALL cause its designated false comparison while protected positives remain true. Empty, partial, malformed, duplicate or unknown inventories, compile-only failures, no-op edits and survivors SHALL fail or block explicitly without being counted as detections.

#### Scenario: Semantic mutation

- **WHEN** each required production mutation is run in a fresh isolated projection
- **THEN** its actual edit, compile/run logs, designated failure and protected positives are saved with exact source and artifact hashes

#### Scenario: Runner controls

- **WHEN** actual runner CLI calls encounter empty/partial/duplicate/unknown results, missing/nonunique/no-op edits, compile failures, survivors, failed positives or unsafe output locations
- **THEN** each rejects for its intended diagnostic beside a valid accepted control

#### Scenario: Source drift

- **WHEN** an input differs from the frozen candidate or changes during execution
- **THEN** evidence blocks instead of attributing results to the wrong revision

### Requirement: Proof inventory and regression integrity

The sprint SHALL retain automatic imported theorem and supplemental declaration axiom audits, allowing no sorry, custom axioms or native_decide in accepted kernel proofs. Named inventories SHALL distinguish generic proofs, concrete instances, counterexamples, generated declarations and runtime checks. Existing kernel, corpus, compiler, mutation and runner regressions SHALL pass on the accepted source with historical bytes preserved.

#### Scenario: Imported proof coverage

- **WHEN** the full build and new verification root run
- **THEN** every in-scope imported declaration is inventoried with zero forbidden dependencies and named theorem premises are recorded

#### Scenario: Legacy preservation

- **WHEN** the current source is compared with the base and full legacy checks run
- **THEN** historical source/corpus bytes are unchanged apart from the declared import-root/documentation updates, and fresh command exits/logs are retained

### Requirement: Planning implementation and delivery gates

Implementation SHALL begin only after independent GPT-6 and native Fable planning reviews pass on the same frozen candidate and a current baseline passes. Substantive results SHALL receive native Grok and Fable reviews with exact requested/reported models, source identity, findings and fixes. An unavailable or incomplete review SHALL remain open. Stock Codex SHALL implement using GPT-6 without Foreman. Wiki notes SHALL record decision summaries and links without presenting plans as proved results. Archive SHALL require all tasks and acceptance gates complete.

#### Scenario: Planning gate

- **WHEN** candidate specs, design and tasks are frozen and both required reviewers pass
- **THEN** the recorded gate authorizes the already approved implementation; schema completeness alone does not authorize it

#### Scenario: Unavailable reviewer

- **WHEN** a native provider returns no substantive verdict or reports unavailable credits
- **THEN** the review remains open and dependent implementation or final acceptance does not proceed

#### Scenario: Accepted delivery

- **WHEN** proofs, execution, mutations, full regressions and native implementation audits pass with findings resolved
- **THEN** roadmap/wiki and task states reflect actual evidence, the branch is pushed and verified, and only this completed OpenSpec change is archived

--- END FILE openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md ---

--- BEGIN FILE openspec/changes/shared-state-interleaving/tasks.md ---
## 1. Planning and baseline gates

- [x] 1.1 Save proposal/design/four specs/tasks and the wiki decision index; run strict OpenSpec validation and verify every scenario maps to an implementation task and planned evidence type.
- [ ] 1.2 Freeze the candidate and context bundle, obtain separate GPT-6 and native Fable planning verdicts, resolve blocking findings and save exact candidate/model/hash metadata; verify both passing reviews bind the same final candidate before any implementation.
- [ ] 1.3 Record a current full Lean/runtime/axiom baseline and protected-source inventory at the base revision; verify every required baseline command below exits zero and no preserved source bytes drift.

## 2. Schedule representation and admission

- [ ] 2.1 Add `Interleaving/Schedule.lean` with token counts and typed mismatch details; verify exact counts, empty branches, missing/excess tokens and balanced alternating schedules, and prove accepted-count equivalence.
- [ ] 2.2 Add ordered catalog/left/right/schedule preflight reusing whole-branch analysis without compatibility rejection; verify funded shared writes are admitted, unreachable malformed suffixes refuse, and competing preflight errors follow the specified precedence.
- [ ] 2.3 Prove complete schedules consume each branch's static slots in order and admitted footprints cover each selected invocation; verify original Parallel admission implies shared structural admission for complete schedules.

## 3. Shared execution and observations

- [ ] 3.1 Add `Interleaving/Execution.lean` with one-world machine, local states, successful next indices, consumed counts, exact attempts and initialization; verify empty identity and balanced singleton execution against complete expected worlds.
- [ ] 3.2 Implement token advancement and finite-prefix folding through real `Composition.executeStep` with local boundary/history and current shared world; verify competing USD10 withdrawals and replenishment order with exact receipts and failure reasons.
- [ ] 3.3 Implement permanent branch-local halting and inert suffix/out-of-range token handling; verify immediate/middle/dual refusal, no retry after replenishment, retained prefix, continued peer and absence of skipped attempts.
- [ ] 3.4 Expose full schedule/attempt results and named canonical projection/comparison; verify each preserved observation field with changed/equal pairs, including exact failure and full store/ledger, and document deliberately omitted global order/raw foreign worlds.
- [ ] 3.5 Add real shared-key snapshot and peer-only-history examples using current versus captured values; verify own history, qualified ports/units and local boundary indices with independently funded successful siblings.

## 4. Sound traces and preservation

- [ ] 4.1 Add `Interleaving/Soundness.lean` inductive machine reachability and prove actual prefix execution sound, including exact failed calls; verify initial/final world continuity and that successful branch events project from actual attempts.
- [ ] 4.2 Prove local invocation order/history isolation, refusal stability, skipped-slot inertia, full schedule slot completion and fixed capability store; verify each theorem is about the actual runner rather than a supplied unrelated trace.
- [ ] 4.3 Add `Interleaving/Preservation.lean` actual-receipt supply aggregation and generic prefix accounting; verify independent nonzero supply in both branches plus a refused suffix and prove per-domain/asset equality.
- [ ] 4.4 Prove point-of-use authority at actual pre-worlds/local boundaries and derive initial-store authority, plus reached-world nonnegativity; verify live/revoked and unauthorized/authorized financial siblings and expose state/trust premises.
- [ ] 4.5 Prove locality outside actual writes and analyzed union writes, supported predicate frames, and identity for admission/refusal/skip; verify protected collateral and a concrete missing-support counterexample.

## 5. Interference and disjoint recovery

- [ ] 5.1 Add `Interleaving/Interference.lean` ledger relations and independently quantified local preservation/guarantee obligations; prove initialized two-invariant prefix preservation from cross-inclusion and stability without peer-invariant or whole-run premises.
- [ ] 5.2 Instantiate both invariants for overlapping USD10 transfer workflows with equality-of-total rely/guarantee relations; verify local no-supply template proofs, concrete initialization and every schedule-prefix conclusion, plus counterexamples to omitted initialization and peer stability.
- [ ] 5.3 Add `Interleaving/Recovery.lean` prefix simulation with isolated cursors and dependency-region agreement; prove each success/refusal matches the isolated branch using existing dependency lemmas, including local outputs after peer writes outside their region.
- [ ] 5.4 Prove every complete admitted disjoint schedule has the existing parallel canonical observation and derive LR/RL reference correspondence; verify the theorem includes stopped branches and supplied equality/success assumptions are absent.
- [ ] 5.5 Prove empty/one-empty and full-block serial laws; verify all six disjoint 2+2 schedules against independent expected results, a disjoint refused-prefix case, and a shared-source counterexample to unrestricted order equivalence.

## 6. Reference coverage and imported audit

- [ ] 6.1 Complete `Interleaving/Examples.lean` and `Tests.lean` with all seven design fixture families; verify independent complete ledgers/stores, receipts, typed outputs, exact failure reasons/indices and protected successful controls.
- [ ] 6.2 Add `Interleaving/Audit.lean` with a nonempty unique named runtime inventory and `Verify.lean` with automatic imported theorem/supplemental axiom checks; add the new root import and verify zero forbidden dependencies and full runtime success.
- [ ] 6.3 Save named theorem statements/premises and classify generic results, instances, counterexamples and generated declarations; finish a one-to-one scenario inventory and verify every planned scenario has actual evidence without calling finite executions generic proofs.

## 7. Production mutations and runner controls

- [ ] 7.1 Add `scripts/check_interleaving_mutations.py` with explicit repo/spec/out, fresh source projection, byte manifests and complete inventory enforcement; verify an unchanged real execution control with all comparisons true and protected positive labels present.
- [ ] 7.2 Add mutants for count bypass, overlap rejection, stale initial execution, isolated-world replacement, global cancellation, prefix rollback and halted retry; verify all seven compile and each designated independent runtime oracle detects the actual source change.
- [ ] 7.3 Add mutants for peer history, snapshot recomputation, global boundary index, wrong local invocation, dropped peer supply, revoked-grant resurrection and failure-observation omission; verify all seven compile and each designated oracle fails while its protected sibling remains true.
- [ ] 7.4 Add `scripts/test_interleaving_mutation_runner.py` with actual CLI valid/empty/partial/duplicate/unknown/malformed inventory, missing/nonunique/no-op edit, compile failure, survivor, failed-positive, source-drift and unsafe-output controls; verify intended diagnostics and distinguish violated from blocked results.
- [ ] 7.5 Freeze mutation source/spec/driver inputs and execute all fourteen mutations and runner controls in fresh external directories; verify complete per-variant inventories, input Git-object bindings, artifact hashes and unchanged source, retaining failed attempts without counting them as detections.

## 8. Integration and independent implementation review

- [ ] 8.1 Freeze source and run new/full legacy Lean drivers, typed/composition/parallel mutations, their runner controls, compiler typing controls, axiom controls and corpus regressions; verify actual exits/logs and protected bytes, with fresh source manifests and no reused old pass claims.
- [ ] 8.2 Complete scenario/proof/tool/source manifests and perform an independent artifact cross-check; verify all scenario mappings are nonempty, every counted artifact exists and hashes/counts bind the reviewed source revision.
- [ ] 8.3 Obtain native Grok/Fable implementation and evidence audits using exact frozen source bundles; save requested/reported identities and raw responses, and verify each required scope has a substantive passing verdict.
- [ ] 8.4 Resolve blockers and refresh affected checks/review on the revised candidate; save adjudication with limitations and retained dissent, verifying no waived normative proof, mutation or review obligation.

## 9. Wiki roadmap delivery and archive

- [ ] 9.1 Update roadmap/progress/wiki and task states from actual accepted evidence; verify atomic settlement, changing capabilities, general associativity and fidelity remain open and wiki notes link to source/evidence.
- [ ] 9.2 Validate this OpenSpec strictly and check current editorial whitespace/local links; verify raw hash-bound artifacts remain byte-identical when their display contains whitespace warnings.
- [ ] 9.3 Commit/push to `semantic-kernel-pivot`, verify the actual remote head and record delivery metadata; verify no merge to main or unrelated change is included.
- [ ] 9.4 Archive only `shared-state-interleaving`, validate four synchronized main specs and repaired archive links, then push metadata; verify final remote identity, completed task states and clean worktree.

The 37 checkboxes are acceptance obligations, not completed results. Dependencies:
1 gates all implementation; 2→3→4; 4→5; fixtures grow with 2–5; 6 completes their
inventory; 7 requires the actual behaviors; 8 and 9 close integration and delivery.
Execution uses the already approved stock GPT-6 harness and branch. No Foreman.

Verification instructions (save actual command arrays, full logs, exits, UTC times,
source hashes and versions when run; these instructions are not evidence):

```sh
# Repository root
openspec validate shared-state-interleaving --strict --json --no-interactive
openspec status --change shared-state-interleaving --json
git diff --check
# lean/; baseline excludes the two new Interleaving drivers only
lake build
lake env lean DefiKernel/Interleaving/Audit.lean
lake env lean DefiKernel/Interleaving/Verify.lean
lake env lean DefiKernel/Parallel/Audit.lean
lake env lean DefiKernel/Parallel/Verify.lean
lake env lean DefiKernel/Composition/Audit.lean
lake env lean DefiKernel/Composition/Verify.lean
lake env lean DefiKernel/Typed/Audit.lean
lake env lean DefiKernel/Typed/Verify.lean
lake env lean DefiKernel/Audit.lean
lake env lean DefiKernel/ContractAudit.lean
lake env lean DefiKernel/VerifyAxioms.lean
```

Run Python regressions using the exact established command arrays in
`review/semantic-kernel/sprint6/integration/` and mutation/runner manifests after
checking the actual drivers' help. Allocate new output paths and bind current
inputs. New driver command:
`python3 scripts/check_interleaving_mutations.py --repo . --spec review/semantic-kernel/sprint7/mutation-spec.json --out /tmp/NEW-UNIQUE-DIRECTORY`.
The runner must own creation of a fresh output directory. For a fresh package
rebuild use `lake clean defialgebra` followed by `lake build`; bare `lake clean`
also cleans dependency packages and is not the intended regression procedure.

--- END FILE openspec/changes/shared-state-interleaving/tasks.md ---

--- BEGIN FILE wiki-llm/README.md ---
# DeFi formal research decision index

This wiki records concise design rationale, alternatives, assumptions and review
findings. OpenSpec holds the behavioral requirements; Lean holds proof evidence;
versioned review artifacts hold measurements and advisory audits. A wiki entry
does not turn a proposed theorem into a proved result.

- [Sprint 7: shared-state interleaving](sprint-7-shared-state-interleaving.md)
- [Current roadmap](../roadmap.md)
- [Migration progress and evidence](../docs/research/semantic-kernel-progress.md)

Created on 2026-09-07 at the user's request. There was no existing `wiki-llm`
directory or configured integration found in this checkout; these tracked Markdown
pages are the repository-local record.

--- END FILE wiki-llm/README.md ---

--- BEGIN FILE wiki-llm/sprint-7-shared-state-interleaving.md ---
# Sprint 7: shared-state interleaving

Status on 2026-09-07: **OpenSpec candidate in preparation; implementation gated**.
Base: `850d785d41dc311785dc33cdb3f65c368756434c`.

Authoritative links: [proposal](../openspec/changes/shared-state-interleaving/proposal.md),
[design](../openspec/changes/shared-state-interleaving/design.md),
[tasks](../openspec/changes/shared-state-interleaving/tasks.md).

## Decision summaries

1. **Use a shared evolving world.** Two withdrawals can each be valid on their own
   and compete for the same liquidity. With USD10, withdrawals of7 and6 cannot
   both succeed. Preserve accounting and authority while exposing which attempt
   succeeds under each schedule.
2. **Keep schedules explicit and finite.** A token selects the next static slot
   of its branch. Exact counts make replay and completeness independent of whether
   an invocation succeeds. After a refusal, remaining own slots skip. An adaptive
   scheduler or fairness result would add a separate semantic obligation.
3. **Keep partial progress.** Earlier successful effects survive a later refusal;
   the peer continues. All-or-nothing rollback belongs to atomic synchronization.
4. **Separate histories from shared balances.** A live ledger read sees peer
   changes, while an earlier output snapshot retains its captured value. Output
   references remain branch-local even when keys coincide.
5. **Make interference assumptions explicit.** Independent local guarantees must
   fit the peer's rely relation, and the peer invariant must be stable under that
   relation. Both invariants must hold initially. These are proof premises, not
   silently satisfied runtime checks or automatically discovered invariants.
6. **Require a universal disjoint recovery proof.** Sprint 6's dependency lemmas
   should support a simulation for every schedule, including exact failures.
   Enumerating six 2+2 schedules is useful regression evidence but cannot replace
   that theorem. Full trace order remains observable; only a named projection
   recovers the existing canonical parallel observation.
7. **Keep the first scope bounded.** Capabilities remain fixed during execution.
   Initial revoked grants are tested; revocation races, provenance, unbounded
   liveness and deployed financial fidelity remain future work.

## Review questions

- Does the schedule/skip convention distinguish consumed slots from successful
  local indices everywhere, including failure locations and canonical recovery?
- Can every required mutation compile and be discriminated by a real production
  path with an independently expected outcome and a funded successful sibling?
- Does the rely/guarantee instance exercise overlapping support with nontrivial
  local proofs, rather than premises that merely restate the whole-run result?
- Does the generic disjoint simulation preserve exact histories and refusal
  precedence without requiring equality of unrelated foreign event worlds?

These are audit questions against the concrete candidate, not unspecified behavior.
The design resolves the behavior; reviewers can require a corrected candidate.

## Evidence status

No Sprint 7 implementation, new proof, runtime result or reviewer approval is
claimed here yet. Planning requires separate GPT-6 and native Fable 5.1 passing
verdicts on the same frozen candidate. Substantive implementation will require
native Grok/Fable review, full regressions and exact source binding. The stock
GPT harness implements with GPT-6; Foreman is excluded.

--- END FILE wiki-llm/sprint-7-shared-state-interleaving.md ---

--- BEGIN FILE roadmap.md ---
# DeFiFormal migration roadmap

Updated 2026-09-07 UTC after Sprint 6; Sprint 7 planning underway.
Branch: `semantic-kernel-pivot`. Sprint 6 delivery/archive head: `850d785`.

The remaining objective is conditional preservation of financial properties
under composition, backed by faithful protocol models. Sprints 1–6 delivered the
pilot, trusted operation contracts, provisional corpus reconstruction, typed
execution/capabilities, conditional sequential preservation and disjoint parallel
composition. Checked boxes
record accepted work; unchecked boxes remain open. Neither implies deployed fidelity.

Sources: [approved migration design](docs/superpowers/specs/2026-09-06-semantic-kernel-design.md),
[original supplied plan](docs/research/2026-09-06-defi-source-plan.md),
[progress ledger](docs/research/semantic-kernel-progress.md), and
[Sprint 4 adjudication](review/semantic-kernel/sprint4/ADJUDICATION.md).
Historical uppercase `ROADMAP.md` files retain their original evidence and scope.
This root roadmap is the current consolidated agenda.

## 1. Sprint 5: typed interfaces and sequential composition

Accepted with limitations: [OpenSpec change](openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/proposal.md),
[design](openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/design.md),
and [47 implementation tasks](openspec/changes/archive/2026-09-06-typed-interfaces-sequential-composition/tasks.md).
Sequential execution retains the successful prefix and stops at the first refusal.
The [adjudication](review/semantic-kernel/sprint5/ADJUDICATION.md),
[scenario coverage](review/semantic-kernel/sprint5/coverage.md), and
[proof inventory](review/semantic-kernel/sprint5/proof-inventory.json) record the
accepted scope: 93 runtime comparisons, 12 detected source mutants, and 70 named
theorems. Both required native Grok/Fable reviews accepted with limitations.
[Delivery verification](review/semantic-kernel/sprint5/delivery.json) records the
source/evidence push at `5fb0929`; the OpenSpec change is archived and its four main
specifications are synchronized.

- [x] Define component interfaces: typed ports, private/shared state, inputs, outputs, assumptions, and guarantees.
- [x] Define initialization, execution traces, and observable success/refusal behavior.
- [x] Implement sequential composition with explicit state and capability propagation.
- [x] Lift accounting, nonnegativity, authority, and locality results from individual transitions to sequences.
- [x] Prove a frame theorem for predicates that depend only on protected state.
- [x] Add composed reference workflows and mutations covering ordering, refusal propagation, unauthorized interference, and revoked capabilities.

The frame theorem concerns ledger predicates with explicit support and disjoint
writes. Component locality is conditional on denied write access; general private
noninterference is not claimed. Initialization and contract results retain explicit
local/boundary premises, and nonnegativity follows from proof-carrying states.

## 2. Sprint 6: disjoint parallel composition

The [OpenSpec plan](openspec/changes/archive/2026-09-07-disjoint-parallel-composition/design.md)
and [48-task checklist](openspec/changes/archive/2026-09-07-disjoint-parallel-composition/tasks.md)
are implemented and independently reviewed. Source candidate: `fae07ca`.
Both native Grok and Fable audits accepted the Lean implementation and final
evidence with limitations. [Adjudication and review identities](review/semantic-kernel/sprint6/implementation/ADJUDICATION.md)
record the exact reviewed inputs. The accepted source/evidence push
`26bb17d` is verified on `semantic-kernel-pivot`; all 17 requirements were
synchronized to four main specs and the approved change was archived.
[Delivery](review/semantic-kernel/sprint6/delivery.json) and
[archive action](review/semantic-kernel/sprint6/archive-action.json) preserve the records.

Acceptance passes 131 runtime comparisons, 388 imported theorem and 419
supplemental axiom checks with zero forbidden dependencies, all 14 Parallel
mutations, all 45 Parallel runner controls, and all seven historical Python
regression suites. The 126 explicit theorems comprise 88 generic results,
35 reference instances and three counterexamples; generated theorem counts
are separate. A clean repository-package rebuild and frozen administrative
compiler controls also pass. [Coverage](review/semantic-kernel/sprint6/coverage.md)
and [proof inventory](review/semantic-kernel/sprint6/proof-inventory.json) record
all 47 scenarios and their precise evidence classes.

- [x] Pass both planning audits on the same candidate.
- [x] Implement conservative concrete compatibility and independent branch execution.
- [x] Prove full executor dependency, exact refusal framing and both actual serial-order correspondences.
- [x] Prove joined accounting, authority, nonnegativity, supported frames and conditional initialized invariants.
- [x] Complete financial fixtures, real mutations, regressions and native Grok/Fable implementation review.
- [x] Deliver the accepted branch and archive the OpenSpec change.

## Sprint 7: shared-state interleaving

Planning in progress: [OpenSpec proposal](openspec/changes/shared-state-interleaving/proposal.md),
[design](openspec/changes/shared-state-interleaving/design.md),
[37 tasks](openspec/changes/shared-state-interleaving/tasks.md), and
[wiki decision record](wiki-llm/sprint-7-shared-state-interleaving.md).
The candidate covers explicit finite schedules, one evolving shared world,
branch-local histories/refusals, initialized interference obligations and generic
recovery of disjoint behavior. Implementation is gated on independent GPT-6/Fable
planning passes and a fresh baseline; no Sprint 7 implementation is claimed here.

- [ ] Pass the frozen OpenSpec planning review gate and current baseline.
- [ ] Implement shared execution, schedules and exact observations.
- [ ] Prove prefix preservation, explicit interference composition and disjoint recovery.
- [ ] Complete financial examples, production mutations and full regressions.
- [ ] Obtain native Grok/Fable result audits, deliver the branch and archive OpenSpec.

## Remaining composition and metatheory

- [x] Implement disjoint parallel composition.
- [ ] Implement shared-state interleaving with explicit interference conditions.
- [ ] Implement atomic synchronization, including failure and transient-settlement semantics.
- [ ] Generalize the useful results in `Interface.lean` and `Nary.lean` into the operational model.
- [ ] Prove behavioral associativity: regrouping compatible components preserves behavior.
- [ ] Prove assume-guarantee composition with initialization and causal or inductive premises, not circular assumptions.
- [ ] Define observational equivalence and prove conservative extension: unrelated additions preserve existing behavior.
- [ ] Establish capability provenance and component isolation where required, beyond the current trusted-store assumption.

## 3. Claims, liabilities, and asynchronous behavior

- [ ] Implement actual claims with debtor, creditor, asset/payoff, conditions, due time, and status.
- [ ] Implement creation, transfer, modification, discharge, and default.
- [ ] Prove that liabilities cannot disappear without an authorized lifecycle transition.
- [ ] Add repayment semantics; the current debt-erasure regression only rejects an invalid borrowing proposal.
- [ ] Implement message lifecycles, finality conditions, replay protection, timeouts, challenges, and compensation for asynchronous workflows.
- [ ] Represent oracle, custody, legal, sequencing, and finality assumptions explicitly.

## 4. Corpus and provenance

- [ ] Complete organization → product → version → deployment identities for the 75 candidates reconstructed from 72 historical rows.
- [ ] Resolve the 29 annotation disagreements using rules applicable to future cases.
- [ ] Resolve the separate Liquity V1 liquidation source challenge.
- [ ] Complete remaining product splits, pinned source references, dependency relationships, and ambiguity/residue records.
- [ ] Recover or replace unresolved references from the supplied proposal.
- [ ] Establish separate development and untouched-evaluation manifests. The current 75 candidates remain development cases.

## 5. Certificates and verification infrastructure

- [ ] Define a serialized module/transition format with interfaces, assumptions, invariants, observations, and source mappings.
- [ ] Implement a real certificate checker that recomputes judgments rather than accepting supplied labels.
- [ ] Check typing, footprints, authority, accounting, composition compatibility, library proof instantiation, and outstanding assumptions.
- [ ] Establish correspondence between serialized/executable representations and Lean semantics; do the same for any Quint abstraction introduced.
- [ ] Extend audit coverage to explicit package manifests and declared audit roots.
- [ ] Expand mutation coverage beyond Sprint 5’s 12 sequential mutants: effect application, capability allocation, structural catalog checks, and future composition operators.

## 6. Financial libraries still to port

- [ ] Machine arithmetic: widths, overflow, rounding direction, and fees.
- [ ] Uniswap-style concentrated-liquidity arithmetic and tick traversal.
- [ ] Curve-style iterative invariant calculations and failure behavior.
- [ ] Liquity-style ordered redemption.
- [ ] Morpho-style bad-debt realization and loss allocation.
- [ ] Balancer-style shared vault accounting, hooks, and transient settlement.
- [ ] A complete cross-domain financial workflow.
- [ ] Margin, funding, unsettled profit, liquidation, and bankruptcy handling.
- [ ] External conditional claims, including insurance or tokenized off-chain obligations.

## 7. Protocol fidelity and runtime adapters

- [ ] Pin concrete implementations, versions, deployments, and relevant execution environments.
- [ ] Run identical generated sequences against implementations and models; compare successful and refused behavior.
- [ ] Detect characteristic mutations in rounding, fees, ordering, losses, authority, oracles, and delayed settlement.
- [ ] Prove selected concrete implementation-to-model refinements.
- [ ] Add chain/runtime adapters through verified interfaces. Moriarty, Compact, ZKIR, and proof-carrying transaction integration remain later adapter work.

## 8. Evaluation, research claims, and publication

- [ ] Reconcile remaining paper and ledger claims: Q/Σ, four primitives, semantic minimality, Delta terminology, lattice claims, and exhaustive-result scope.
- [ ] Audit the correspondence between general structural theorems and the concrete historical instances.
- [ ] Freeze the kernel before evaluating untouched cases.
- [ ] Audit the proposed twelve evaluation candidates for prior design use; replace contaminated cases where necessary.
- [ ] Evaluate across the planned execution environments.
- [ ] Report schema coverage, behavioral coverage, library reuse, new kernel concepts, external assumptions, and verification effort separately.
- [ ] Rewrite the paper around demonstrated results and their limits.
- [ ] Update the ontology visualization and repository graph after the schema stabilizes.

## 9. Lower-priority review follow-ups

- [ ] Improve malformed-input diagnostics, standalone schema constraints, and package directory inventory checks.
- [ ] Add explicit current-module-exclusion and broader audit-root fixtures.
- [ ] Add a general duplicate-capability-list theorem and an isolated vault-liquidity regression.
- [ ] Extend individual actor/effect/supply comparison mutations in the older contract wrapper.

## Acceptance process for each implementation sprint

GPT-6 implements through the stock Codex harness. Lean is the mathematical
authority. Use meaningful negative and mutation checks, independent native Grok
and Fable review, saved evidence bound to exact source/tool identities, and a
verified branch push. Do not use Foreman. Preserve prior proofs, negative results,
and corpus source identities. Keep proofs, bounded execution, measurements,
refutations, and unchecked assumptions distinct.

--- END FILE roadmap.md ---

--- BEGIN FILE review/semantic-kernel/sprint7/planning/coverage.json ---
{
  "scenarios": [
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-disjoint-recovery/spec.md",
      "scenario": "All disjoint schedules",
      "tasks": [
        "5.3",
        "5.4"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-disjoint-recovery/spec.md",
      "scenario": "Disjoint refusal",
      "tasks": [
        "5.3",
        "5.4"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-disjoint-recovery/spec.md",
      "scenario": "Six concrete schedules",
      "tasks": [
        "5.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-disjoint-recovery/spec.md",
      "scenario": "Empty peer",
      "tasks": [
        "5.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-disjoint-recovery/spec.md",
      "scenario": "Full-block schedules",
      "tasks": [
        "5.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-disjoint-recovery/spec.md",
      "scenario": "Order-sensitive shared state",
      "tasks": [
        "5.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Balanced schedule",
      "tasks": [
        "2.1",
        "2.3"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Missing and excess slots",
      "tasks": [
        "2.1"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Empty schedules",
      "tasks": [
        "3.1"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Overlapping funded branches",
      "tasks": [
        "2.2"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Unreachable malformed suffix",
      "tasks": [
        "2.2"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Preflight precedence",
      "tasks": [
        "2.2"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Competing liquidity",
      "tasks": [
        "3.2"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Replenishment order",
      "tasks": [
        "3.2",
        "3.3"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Local boundary identity",
      "tasks": [
        "3.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Revoked authority",
      "tasks": [
        "4.4"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Retained prefix and peer continuation",
      "tasks": [
        "3.3"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Dual refusal",
      "tasks": [
        "3.3"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Different snapshots at the same key",
      "tasks": [
        "3.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Peer-only history",
      "tasks": [
        "3.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Attempt continuity",
      "tasks": [
        "4.1"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Observation sensitivity",
      "tasks": [
        "3.4"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-execution/spec.md",
      "scenario": "Skipped tokens",
      "tasks": [
        "3.3",
        "4.2"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md",
      "scenario": "Prefix soundness",
      "tasks": [
        "4.1"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md",
      "scenario": "Complete slot consumption",
      "tasks": [
        "4.2"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md",
      "scenario": "Supply and refusal",
      "tasks": [
        "4.3"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md",
      "scenario": "Authority at execution",
      "tasks": [
        "4.4"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md",
      "scenario": "Reached worlds",
      "tasks": [
        "4.4"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md",
      "scenario": "Protected collateral",
      "tasks": [
        "4.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md",
      "scenario": "Missing support counterexample",
      "tasks": [
        "4.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md",
      "scenario": "Overlapping invariant instance",
      "tasks": [
        "5.1",
        "5.2"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md",
      "scenario": "Initialization is necessary",
      "tasks": [
        "5.2"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-preservation/spec.md",
      "scenario": "Peer stability is necessary",
      "tasks": [
        "5.2"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md",
      "scenario": "Full financial oracle",
      "tasks": [
        "6.1",
        "6.2",
        "6.3"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md",
      "scenario": "Live versus frozen values",
      "tasks": [
        "3.5",
        "6.1"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md",
      "scenario": "Semantic mutation",
      "tasks": [
        "7.2",
        "7.3",
        "7.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md",
      "scenario": "Runner controls",
      "tasks": [
        "7.4"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md",
      "scenario": "Source drift",
      "tasks": [
        "7.4",
        "7.5"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md",
      "scenario": "Imported proof coverage",
      "tasks": [
        "6.2",
        "6.3"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md",
      "scenario": "Legacy preservation",
      "tasks": [
        "8.1"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md",
      "scenario": "Planning gate",
      "tasks": [
        "1.2"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md",
      "scenario": "Unavailable reviewer",
      "tasks": [
        "1.2",
        "8.3"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    },
    {
      "spec": "openspec/changes/shared-state-interleaving/specs/interleaving-regression-evidence/spec.md",
      "scenario": "Accepted delivery",
      "tasks": [
        "8.4",
        "9.1",
        "9.2",
        "9.3",
        "9.4"
      ],
      "status": "planned",
      "evidence_kind": "generic proof and/or concrete runtime/administrative evidence as specified in the linked task; no execution claimed"
    }
  ],
  "scenario_count": 43,
  "task_count": 37,
  "status": "planning map, not implementation evidence"
}

--- END FILE review/semantic-kernel/sprint7/planning/coverage.json ---

--- BEGIN FILE review/semantic-kernel/sprint7/planning/source-context.json ---
{
  "base": "850d785d41dc311785dc33cdb3f65c368756434c",
  "files": [
    {
      "path": "AGENTS.md",
      "sha256": "8648a6f91d00c75ccf8ad2198428f7cd7e55323204cec9af6f53e6d4972edb7b",
      "bytes": 1830
    },
    {
      "path": "docs/superpowers/specs/2026-09-06-semantic-kernel-design.md",
      "sha256": "9549bec37f76a16b42c8d2ad2c4305fd5f9568ffb1413cd79e218a978f99613a",
      "bytes": 6389
    },
    {
      "path": "lean/lean-toolchain",
      "sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
      "bytes": 29
    },
    {
      "path": "lean/lakefile.toml",
      "sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
      "bytes": 414
    },
    {
      "path": "lean/lake-manifest.json",
      "sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
      "bytes": 3153
    },
    {
      "path": "lean/DefiKernel/AxiomAudit.lean",
      "sha256": "4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524",
      "bytes": 4374
    },
    {
      "path": "lean/DefiKernel/Typed/Acceptance.lean",
      "sha256": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
      "bytes": 17113
    },
    {
      "path": "lean/DefiKernel/Typed/Authority.lean",
      "sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
      "bytes": 13533
    },
    {
      "path": "lean/DefiKernel/Typed/Expr.lean",
      "sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
      "bytes": 12466
    },
    {
      "path": "lean/DefiKernel/Typed/Transition.lean",
      "sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
      "bytes": 21986
    },
    {
      "path": "lean/DefiKernel/Typed/Types.lean",
      "sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
      "bytes": 4499
    },
    {
      "path": "lean/DefiKernel/Composition/Contracts.lean",
      "sha256": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
      "bytes": 3446
    },
    {
      "path": "lean/DefiKernel/Composition/Execution.lean",
      "sha256": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
      "bytes": 21579
    },
    {
      "path": "lean/DefiKernel/Composition/Interfaces.lean",
      "sha256": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
      "bytes": 12415
    },
    {
      "path": "lean/DefiKernel/Composition/Preservation.lean",
      "sha256": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
      "bytes": 10344
    },
    {
      "path": "lean/DefiKernel/Composition/Sequence.lean",
      "sha256": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
      "bytes": 10173
    },
    {
      "path": "lean/DefiKernel/Parallel/Commutation.lean",
      "sha256": "c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef",
      "bytes": 17707
    },
    {
      "path": "lean/DefiKernel/Parallel/Compatibility.lean",
      "sha256": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243",
      "bytes": 14677
    },
    {
      "path": "lean/DefiKernel/Parallel/Dependency.lean",
      "sha256": "72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245",
      "bytes": 13489
    },
    {
      "path": "lean/DefiKernel/Parallel/Execution.lean",
      "sha256": "a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089",
      "bytes": 7916
    },
    {
      "path": "lean/DefiKernel/Parallel/Observation.lean",
      "sha256": "38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f",
      "bytes": 2156
    },
    {
      "path": "lean/DefiKernel/Parallel/Preservation.lean",
      "sha256": "faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10",
      "bytes": 19323
    },
    {
      "path": "lean/DefiKernel/Parallel/Dependency/Adapter.lean",
      "sha256": "10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c",
      "bytes": 9887
    },
    {
      "path": "scripts/check_parallel_mutations.py",
      "sha256": "415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0",
      "bytes": 13964
    },
    {
      "path": "scripts/test_parallel_mutation_runner.py",
      "sha256": "14d807f04c36ad61e3de854ab693f29417201e531942bf012e0c5a84b1f9bb79",
      "bytes": 23313
    },
    {
      "path": "review/semantic-kernel/sprint6/mutation-spec.json",
      "sha256": "5c5fc372c1547271ea8baaedf7fc60bc79efd10c62458bc8934a3a3554426a35",
      "bytes": 7226
    }
  ]
}

--- END FILE review/semantic-kernel/sprint7/planning/source-context.json ---

--- BEGIN FILE AGENTS.md ---
# Working instructions

The user approved the semantic-kernel pivot on 2026-09-06. Read
`docs/superpowers/specs/2026-09-06-semantic-kernel-design.md` and
`docs/research/semantic-kernel-progress.md` before continuing work.

- The new migration supersedes the old publication-first runstate and the
  positive-program primitive-basis mandate. Historical documents remain
  evidence, not instructions to pursue a withdrawn objective.
- Use GPT-6 for implementation through the stock Codex harness. Have Grok and
  Fable independently check substantive results. Invoke their native CLIs
  directly from Codex. Do not use Foreman. Never substitute a GPT reviewer and
  label its response Grok or Fable.
- Record the exact reviewed revision, requested/reported model identity,
  result, findings, and fixes. An unavailable reviewer is an open review, not
  an approval. Review is advisory evidence, not a mathematical proof.
- Preserve existing proofs and negative results. Put new kernel work in a
  separate namespace. Do not change a historical theorem statement to make a
  new claim pass.
- Read `.claude/skills/defi-footguns/SKILL.md` and
  `formal/v3/GATE-REGISTER.md` when editing or reporting verification behavior.
  Empty checks are blocked. Keep proof, bounded execution, measurement and
  unchecked assumptions distinct, with exact input and tool identities.
- Lean is the mathematical authority. Any executable IR or Quint abstraction
  needs explicit correspondence. No `sorry`, custom axioms or `native_decide`
  in accepted kernel proofs.
- Preserve the original corpus and versioned source evidence. Do not silently
  relabel development examples as untouched holdouts.
- User authorization to execute this migration is already present. Resolve
  routine implementation details without repeatedly requesting approval.

--- END FILE AGENTS.md ---

--- BEGIN FILE docs/superpowers/specs/2026-09-06-semantic-kernel-design.md ---
# DeFi semantic kernel: approved migration design

Approved by Charles Hoskinson on 2026-09-06: save the assessed plan and begin
execution, using GPT-6 implementation and Grok/Fable review through the stock
GPT harness. Do not use Foreman. Base: local commit `8ae0bbf`, 22 commits ahead
of the observed GitHub main `25a13c6`. Preserve those local commits.

## Objective

Establish conditional preservation of financial properties under composition.
Separate the empirical ontology, verified financial libraries, typed open
transition semantics, and chain/runtime adapters. Environment assumptions cross
all layers. A primitive count is not the research objective.

The supplied proposal is preserved verbatim in
`../../research/2026-09-06-defi-source-plan.md`. Its external citation tokens and
two sandbox attachment links are unresolved source material, not verified
references. The assessment below refines that proposal and governs execution.

## Seven work packages

1. **Research mandate and claims.** Supersede both the positive-program roadmap
   and the August AFT roadmap. Update the README and working instructions.
   Preserve historical claims with explicit corrections: withdraw the Q/Sigma
   semantic split and four-primitive objective; distinguish syntactic
   independence from semantic minimality; correct Delta terminology and the
   unsupported inference from clause polarity to absence of a lattice. Audit
   the paper's claim sites before changing published theorem statements.
2. **Kernel specification.** Define typed identities, dimensioned quantities,
   exact arithmetic, transitions, guards/refusals, observations, footprints,
   capabilities, claims, and assumptions. Define operational composition modes
   separately. Lean is the mathematical authority. Executable IR and any Quint
   abstractions must have stated correspondence to it.
3. **Corpus normalization.** Preserve all historical rows. Introduce
   organization/product/version/deployment identities, source revisions,
   chain identity, faceted labels, graph relationships, ambiguity, and residue.
   Split bundled products and versions. Independent annotations and their
   adjudication rules are required. Recover or reconstruct the proposal's
   missing CSV and JSON Schema; recover its external references.
4. **Verification path.** Replace keyword certification with checks of typed
   semantics, footprints, authority, accounting, interfaces, library proof
   instantiation, assumptions, and source correspondence. Bind evidence to
   exact inputs and tool versions. Distinguish proved, bounded, measured,
   refuted, and unchecked obligations. Retain useful existing failure-reporting
   and fidelity infrastructure, including refused behavior.
5. **Metatheory.** Prove initialization and preservation for typing, asset
   accounting, authority and locality; then composition, claim lifecycle and
   conservative extension. Generalize Interface.lean and Nary.lean without
   broadening their historical claims. Assume-guarantee rules need causal or
   inductive premises and initialization, not circular implication alone.
   Frame predicates must depend only on the protected footprint.
6. **Financial libraries and fidelity.** Port exact arithmetic, concentrated
   liquidity, Curve iteration, ordered redemption, loss allocation, transient
   accounting, asynchronous messages, margin/funding, and conditional claims.
   Pin reference implementations and observations. Use differential execution,
   characteristic mutations, and selected concrete refinement proofs.
7. **Generalization and publication.** Freeze the kernel before evaluating
   untouched holdouts. Cases already used to design the kernel are development
   challenges, not untouched holdouts. Track new kernel concepts separately
   from new libraries, coverage, assumptions, and verification effort. Rewrite
   the paper around demonstrated results; adapt visualization after the schema
   settles. Moriarty, Compact, ZKIR and runtime proofs remain adapter work until
   verified interfaces exist.

## First executable increment

Build a deliberately scoped Lean pilot, not the complete future IR. Use one
generic transition representation for a transfer, a fixed-rate vault
deposit/withdrawal, and an oracle-dependent collateralized borrow. These are
reference examples, not assertions of ERC-20/ERC-4626/deployed credit fidelity.

The core records actor, state updates, asset-indexed effects, authority checks,
and declared environment input. Financial formulas and protocol guards live in
example definitions. Require successful and refused examples, generic
accounting/locality results, and negative cases that actually violate the
proposed checks. A proof of an implication must not be advertised as automatic
inference of its hypotheses. Ordinary Lean proof terms are the pilot evidence;
no serialized third-party certificate checker is claimed in this increment.

Pilot numeric domain is explicit exact mathematical arithmetic, with
nonnegative balances and guarded debits. Machine-width arithmetic and chain
rounding require later refinement. No market truth, generic solvency, liveness,
deployed-contract correspondence, or full composition theorem is claimed.

## Acceptance and execution

- Preserve source proposal and this design; save a milestone ledger.
- Build the existing Lean baseline before edits.
- Add the pilot in a fresh namespace and Lake target without altering old proofs.
- Check proofs with Lean, with no `sorry`, custom axioms, or `native_decide`.
- Include live positive/negative examples: unauthorized debit, insufficient
  funds, unbalanced effects, wrong-asset accounting, and rejected credit inputs.
- Independently review the exact candidate with Grok and Fable; record model,
  input identity, raw result, findings, and remediation. Use direct native CLI
  processes launched by Codex, not Foreman. Initial review plus one targeted
  re-review; additional review requires a concrete unresolved finding.
- Keep the remaining seven-package work visible. Completing this increment
  does not complete the full migration or its first three-example fidelity gate.

The first useful milestone is three executable models, checked initial
preservation proofs, and broken variants rejected by the appropriate check.
Calendar estimates are provisional; acceptance conditions govern progress.

--- END FILE docs/superpowers/specs/2026-09-06-semantic-kernel-design.md ---

--- BEGIN FILE lean/lean-toolchain ---
leanprover/lean4:v4.33.0-rc2

--- END FILE lean/lean-toolchain ---

--- BEGIN FILE lean/lakefile.toml ---
name = "defialgebra"
version = "0.1.0"
keywords = ["math"]
defaultTargets = ["Defialgebra", "DefiKernel"]

[leanOptions]
pp.unicode.fun = true # pretty-prints `fun a ↦ b`
relaxedAutoImplicit = false
weak.linter.mathlibStandardSet = true
maxSynthPendingDepth = 3

[[require]]
name = "mathlib"
scope = "leanprover-community"
rev = "v4.33.0-rc2"

[[lean_lib]]
name = "Defialgebra"

[[lean_lib]]
name = "DefiKernel"

--- END FILE lean/lakefile.toml ---

--- BEGIN FILE lean/lake-manifest.json ---
{"version": "1.2.0",
 "packagesDir": ".lake/packages",
 "packages":
 [{"url": "https://github.com/leanprover-community/mathlib4",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "51e6992efd06126df61a496bebf8f49482a4e129",
   "name": "mathlib",
   "manifestFile": "lake-manifest.json",
   "inputRev": "v4.33.0-rc2",
   "inherited": false,
   "configFile": "lakefile.lean"},
  {"url": "https://github.com/leanprover-community/plausible",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "123d15766ba49356c02ebad2a4462dfe12d79899",
   "name": "plausible",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/LeanSearchClient",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "f5c090429dff3cf66cb65562526c9ea6e8edfbcb",
   "name": "LeanSearchClient",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/import-graph",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "bb3469a87774349fe01898d8bf2fc6a1ce6411ca",
   "name": "importGraph",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/ProofWidgets4",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "222c58dad7706a6e7cae46c0edd65ea881d3ee27",
   "name": "proofwidgets",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.lean"},
  {"url": "https://github.com/leanprover-community/aesop",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "7db8190085343afde2f5d2cdcc9bac719b6ec02c",
   "name": "aesop",
   "manifestFile": "lake-manifest.json",
   "inputRev": "master",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/quote4",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "ef42f8944eaf5b6cbfbe75d1917d824c7dd6cf33",
   "name": "Qq",
   "manifestFile": "lake-manifest.json",
   "inputRev": "master",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/batteries",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "76e1c118b0700b4ceafe99532e887d6431625e1a",
   "name": "batteries",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover/lean4-cli",
   "type": "git",
   "subDir": null,
   "scope": "leanprover",
   "rev": "1319485273bf87833fa472afbcefdedecb16b45f",
   "name": "Cli",
   "manifestFile": "lake-manifest.json",
   "inputRev": "v4.33.0-rc2",
   "inherited": true,
   "configFile": "lakefile.toml"}],
 "name": "defialgebra",
 "lakeDir": ".lake",
 "fixedToolchain": false}

--- END FILE lean/lake-manifest.json ---

--- BEGIN FILE lean/DefiKernel/AxiomAudit.lean ---
import Lean.Elab.Command
import Lean.Util.CollectAxioms

/-!
Audit theorem constants and supplemental definitions, opaque constants, and axioms in
imported modules whose names extend a given module prefix.
Discovery uses elaborated constant kinds and module provenance, never declaration source text.
Files outside the import closure and declarations in the current module are outside this scope.
-/

namespace DefiKernel.AxiomAudit

open Lean Elab Command

/-- The only permitted transitive axioms for the pilot's inspected declarations. -/
def allowedAxioms : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]

/-- Discover all imported theorem constants with module provenance under `modulePrefix`. -/
def importedTheorems (env : Environment) (modulePrefix : Name) : Array (Name × Name) :=
  (env.constants.fold (init := #[]) fun found name info =>
    match info with
    | .thmInfo _ =>
      match env.getModuleIdxFor? name with
      | some idx =>
        let moduleName := env.header.moduleNames[idx.toNat]!
        if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName) else found
      | none => found
    | _ => found).qsort fun a b => Name.lt a.1 b.1

/-- Discover imported definitions, opaque constants, and axioms under `modulePrefix`. -/
def importedSupplemental (env : Environment) (modulePrefix : Name) : Array (Name × Name × String) :=
  (env.constants.fold (init := #[]) fun found name info =>
    let kind := match info with
      | .defnInfo _ => "definition"
      | .opaqueInfo _ => "opaque"
      | .axiomInfo _ => "axiom"
      | _ => "other"
    if kind == "other" then found else
    match env.getModuleIdxFor? name with
    | some idx =>
      let moduleName := env.header.moduleNames[idx.toNat]!
      if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName, kind) else found
    | none => found).qsort fun a b => Name.lt a.1 b.1

/--
Report every discovered theorem with its module and exact transitive axiom set.
Also inspect definitions, opaque constants, and axiom declarations, even if no theorem uses them.
Reject empty imported theorem scope and every dependency outside the standard allowlist.
For example, `#audit_axioms DefiKernel` audits loaded `DefiKernel.*` modules.
-/
elab "#audit_axioms " modulePrefix:ident : command => do
  let scopePrefix := modulePrefix.getId
  let env ← getEnv
  let modules := env.header.moduleNames.filter (scopePrefix.isPrefixOf ·)
  let theorems := importedTheorems env scopePrefix
  logInfo m!"AXIOM AUDIT scope: imported module prefix {scopePrefix}; modules={modules}"
  if theorems.isEmpty then
    throwError "AXIOM AUDIT BLOCKED: empty theorem scope for imported module prefix {scopePrefix}; theorems=0"
  let mut rejected : Nat := 0
  for (name, moduleName) in theorems do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT theorem: {name}; module={moduleName}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      rejected := rejected + 1
      logError m!"AXIOM AUDIT FORBIDDEN: {name}; axioms={forbidden}"
  let supplemental := importedSupplemental env scopePrefix
  let mut supplementalRejected : Nat := 0
  for (name, moduleName, kind) in supplemental do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT declaration: {name}; module={moduleName}; kind={kind}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      supplementalRejected := supplementalRejected + 1
      logError m!"AXIOM AUDIT DECLARATION FORBIDDEN: {name}; kind={kind}; axioms={forbidden}"
  if rejected > 0 then
    throwError "AXIOM AUDIT FAILED: {rejected}/{theorems.size} theorems use forbidden axioms"
  if supplementalRejected > 0 then
    throwError (m!"AXIOM AUDIT DECLARATIONS FAILED: {supplementalRejected}/{supplemental.size} " ++
      m!"supplemental declarations use forbidden axioms")
  if supplemental.isEmpty then
    logInfo "AXIOM AUDIT DECLARATIONS: supplemental declarations=0; theorem audit remains required"
  else
    logInfo <| m!"AXIOM AUDIT DECLARATIONS PASSED: {supplemental.size}/{supplemental.size} " ++
      m!"supplemental declarations; forbidden=0"
  logInfo m!"AXIOM AUDIT PASSED: {theorems.size}/{theorems.size} theorems; forbidden=0"

end DefiKernel.AxiomAudit

--- END FILE lean/DefiKernel/AxiomAudit.lean ---

--- BEGIN FILE lean/DefiKernel/Typed/Acceptance.lean ---
import DefiKernel.Typed.Examples

/-! Executed reference outcomes, refused requests and kernel-checked concrete examples.
Development-template changes below are trusted test fixtures, not request payload features. -/
namespace DefiKernel.Typed
namespace Acceptance
open Examples

def expectedInitial : List ℚ :=
  [10, 4, 10, 2, 0, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedTransfer : List ℚ :=
  [7, 4, 10, 2, 3, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedRepeatedTransfer : List ℚ :=
  [4, 4, 10, 2, 6, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedDeposit : List ℚ :=
  [6, 6, 10, 2, 0, 0, 0, 0, 24, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedWithdraw : List ℚ :=
  [14, 2, 10, 2, 0, 0, 0, 0, 16, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedBorrow : List ℚ :=
  [13, 4, 10, 5, 0, 0, 0, 0, 20, 0, 0, 0, 97, 0, 0, 0] ++ List.replicate 16 0
def expectedBoundaryBorrow : List ℚ :=
  [18, 4, 10, 10, 0, 0, 0, 0, 20, 0, 0, 0, 92, 0, 0, 0] ++ List.replicate 16 0
def expectedFractionalDeposit : List ℚ :=
  [9, 9 / 2, 10, 2, 0, 0, 0, 0, 21, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0
def expectedZeroExposure : List ℚ :=
  [10, 4, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 100, 0, 0, 0] ++ List.replicate 16 0

def refused (result : Except ReferenceFailure Result) (reason : Refusal) : Bool :=
  match result with
  | .error actual => decide (actual = .execution reason)
  | .ok _ => false

def postMatches (result : Except ReferenceFailure Result) (balances : List ℚ) : Bool :=
  decide (observe result = .ok balances)

def preservesCapabilities (request : Call) : Bool :=
  match provisioned, run request with
  | .ok before, .ok after => decide (after.capabilities = before)
  | _, _ => false

def provisionedIds : Except AuthorityFailure (List CapabilityId) :=
  provisioned.map fun store ↦ (List.range store.entries.length).map CapabilityId.mk

def revokedTransferInvoke : Except AuthorityFailure Store := do
  let store ← provisioned
  revokeCapability authorityConfig adminContext store ⟨0⟩

def issueAfterRevocation : Except AuthorityFailure (CapabilityId × Store) := do
  let revoked ← revokedTransferInvoke
  issueCapability authorityConfig adminContext revoked (grant transferId .invoke)

def runReissued (request : Call) : Except ReferenceFailure Result := do
  let (id, store) ← issueAfterRevocation.mapError .authority
  runWith store aliceContext fresh 100 { request with capabilityIds := id :: request.capabilityIds }

/-- Both calls use exactly the same request; the second uses the first call's state and store. -/
def repeatedTransfer : Except ReferenceFailure Result := do
  let first ← run (transferRequest 3)
  runWith first.capabilities aliceContext fresh 100 (transferRequest 3) first.state

/-- Actual issue/use/revoke/use: preserve the successful state and revoke in its capability store
before submitting the unchanged request again. A live repeat is separately checked above. -/
def transferLifecycle : Except ReferenceFailure (List ℚ × Except Refusal (List ℚ)) := do
  let first ← run (transferRequest 3)
  let revoked ← (revokeCapability authorityConfig adminContext first.capabilities ⟨0⟩)
    |>.mapError .authority
  let second := execute registry revoked aliceContext fresh 100 (transferRequest 3) first.state
  return (allCells.map first.state.balance, second.map fun post ↦ allCells.map post.state.balance)

def unauthorizedGrant : Except AuthorityFailure (CapabilityId × Store) :=
  issueCapability authorityConfig bobContext .empty (grant transferId .invoke)

def unauthorizedRevoke : Except AuthorityFailure Store := do
  let store ← provisioned
  revokeCapability authorityConfig bobContext store ⟨0⟩

/-- A trusted development registry variant; caller requests still contain no template. -/
def runDevelopmentTemplate (template : Op) (request : Call) : Except ReferenceFailure Result := do
  let developmentRegistry : Registry Party Asset Domain := fun id ↦
    if id = request.operation then some template else registry id
  let config := registryAuthorityConfig developmentRegistry domainAdmin
  let issued : Except AuthorityFailure Store := grants.foldlM
    (fun store g ↦ (issueCapability config adminContext store g).map Prod.snd) .empty
  let store ← issued.mapError .authority
  (execute developmentRegistry store aliceContext fresh 100 request initial).mapError .execution

def missingWrites : Op := { transfer with writes := [] }
def missingOracleReads : Op := { borrow with envReads := [] }
def missingBorrowStateReads : Op := { borrow with stateReads := [] }

def quantityWithRead : E usdSignature (.amount .usd) :=
  .binary (.add (.amount Asset.usd)) usdQuantity
    (.binary (.scale (.amount Asset.usd)) (.lit 0) (.balance (ref .usd .caller)))

def effectReadTransfer : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, negate .usd quantityWithRead⟩,
    ⟨.usd, ref .usd (.argument 0), quantityWithRead⟩]
  stateReads := [packedRef .usd .caller] }

def missingEffectRead : Op := { effectReadTransfer with stateReads := [] }

def unbalancedTransfer : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.argument 0), .binary (.add (.amount Asset.usd)) usdQuantity (.lit 1)⟩] }

def wrongAssetTransfer : Op := { transfer with
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.share, ref .share (.argument 0), .lit 3⟩]
  writes := [packedRef .usd .caller, packedRef .share (.argument 0)] }

def zeroPriceDeposit : Op := { deposit with
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.literal .vault), usdQuantity⟩,
    ⟨.share, ref .share .caller,
      .binary (.unconvert Asset.share Asset.usd) usdQuantity (.lit 0)⟩] }

def illiquid : Ledger :=
  ⟨fun c ↦ if c = (.main, .pool, .usd) then 1 else initial.balance c, by
    intro c; split
    · decide
    · exact initial.nonneg c⟩

def illiquidBorrow : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext fresh 100 (borrowRequest 3) illiquid

/-- Both sides of the collateral inequality are zero, independently of the supplied price.
This isolates strict price positivity instead of letting the collateral guard mask it. -/
def zeroExposure : Ledger :=
  ⟨fun c ↦ if c = (.main, .alice, .debt) ∨ c = (.main, .alice, .collateral)
    then 0 else initial.balance c, by
      intro c; split
      · decide
      · exact initial.nonneg c⟩

def zeroExposureBorrow (price : ℚ) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext (oracle 7 price 98) 100 (borrowRequest 0) zeroExposure

def checks : List (String × Bool) := [
  ("reference_initial_all_cells", decide (allCells.map initial.balance = expectedInitial)),
  ("reference_provisioned_twelve_grants", decide
    (provisionedIds = .ok ((List.range 12).map CapabilityId.mk))),
  ("reference_transfer_full_post", postMatches (run (transferRequest 3)) expectedTransfer),
  ("reference_deposit_full_post", postMatches (run (depositRequest 4)) expectedDeposit),
  ("reference_withdraw_full_post", postMatches (run (withdrawRequest 2)) expectedWithdraw),
  ("reference_borrow_full_post", postMatches (run (borrowRequest 3)) expectedBorrow),
  ("reference_collateral_boundary_accept", postMatches
    (run (borrowRequest 8)) expectedBoundaryBorrow),
  ("reference_fractional_deposit", postMatches (run (depositRequest 1)) expectedFractionalDeposit),
  ("reference_zero_transfer", postMatches (run (transferRequest 0)) expectedInitial),
  ("reference_self_transfer", postMatches (run (transferRequest 3 .alice)) expectedInitial),
  ("reference_zero_deposit", postMatches (run (depositRequest 0)) expectedInitial),
  ("reference_zero_withdraw", postMatches (run (withdrawRequest 0)) expectedInitial),
  ("reference_zero_borrow", postMatches (run (borrowRequest 0)) expectedInitial),
  ("reference_negative_transfer", refused (run (transferRequest (-1))) .guard),
  ("reference_negative_deposit", refused (run (depositRequest (-1))) .guard),
  ("reference_negative_withdraw", refused (run (withdrawRequest (-1))) .guard),
  ("reference_negative_borrow", refused (run (borrowRequest (-1))) .guard),
  ("reference_transfer_capabilities_preserved", preservesCapabilities (transferRequest 3)),
  ("reference_deposit_capabilities_preserved", preservesCapabilities (depositRequest 4)),
  ("reference_withdraw_capabilities_preserved", preservesCapabilities (withdrawRequest 2)),
  ("reference_borrow_capabilities_preserved", preservesCapabilities (borrowRequest 3)),
  ("reference_unknown_operation", refused
    (run { transferRequest 3 with operation := ⟨99⟩ }) .unknownOperation),
  ("reference_wrong_holder", refused
    (runContext bobContext (transferRequest 3)) .unauthorizedInvoke),
  ("reference_claimed_actor_mismatch", refused
    (run { transferRequest 3 with claimedActor := some .bob }) .actorMismatch),
  ("reference_claimed_actor_correct", postMatches
    (run { transferRequest 3 with claimedActor := some .alice }) expectedTransfer),
  ("reference_wrong_domain", refused
    (runContext ⟨.alice, .other⟩ (transferRequest 3)) .domainMismatch),
  ("reference_wrong_operation_capabilities", refused
    (run { depositRequest 4 with capabilityIds := [⟨0⟩, ⟨1⟩] }) .unauthorizedInvoke),
  ("reference_unknown_capability", refused
    (run { transferRequest 3 with capabilityIds := [⟨99⟩] }) .unauthorizedInvoke),
  ("reference_missing_debit", refused
    (run { transferRequest 3 with capabilityIds := [⟨0⟩] }) .unauthorizedDebit),
  ("reference_missing_share_supply", refused
    (run { depositRequest 4 with capabilityIds := [⟨2⟩, ⟨3⟩] }) .unauthorizedSupply),
  ("reference_missing_debt_supply", refused
    (run { borrowRequest 3 with capabilityIds := [⟨9⟩, ⟨10⟩] }) .unauthorizedSupply),
  ("reference_duplicate_capabilities", postMatches
    (run { transferRequest 3 with capabilityIds := [⟨0⟩, ⟨0⟩, ⟨1⟩, ⟨1⟩] }) expectedTransfer),
  ("reference_revoked_invocation", refused
    (runRevoked ⟨0⟩ (transferRequest 3)) .unauthorizedInvoke),
  ("reference_live_repeat_same_request", postMatches repeatedTransfer expectedRepeatedTransfer),
  ("reference_issue_use_revoke_same_request", decide
    (transferLifecycle = .ok (expectedTransfer, .error .unauthorizedInvoke))),
  ("reference_resource_revoked_same_request", refused
    (runRevoked ⟨1⟩ (transferRequest 3)) .unauthorizedDebit),
  ("reference_unrelated_revocation", postMatches
    (runRevoked ⟨9⟩ (transferRequest 3)) expectedTransfer),
  ("reference_revocation_tombstone", decide
    ((revokedTransferInvoke.map fun s ↦ (s.lookup ⟨0⟩).map Capability.live) = .ok (some false))),
  ("reference_reissue_fresh_id", decide ((issueAfterRevocation.map Prod.fst) = .ok ⟨12⟩)),
  ("reference_reissued_new_id_works", postMatches
    (runReissued (transferRequest 3)) expectedTransfer),
  ("reference_old_id_stays_revoked", decide
    ((issueAfterRevocation.map fun p ↦
      authorizesId p.2 aliceContext transferId .invoke ⟨0⟩) = .ok false)),
  ("reference_unauthorized_issue", decide (unauthorizedGrant = .error .unauthorizedAdmin)),
  ("reference_unauthorized_revoke", decide (unauthorizedRevoke = .error .unauthorizedAdmin)),
  ("reference_oracle_age_boundary_accept", postMatches
    (runOracle (oracle 7 2 95) 100 (borrowRequest 3)) expectedBorrow),
  ("reference_oracle_stale", refused (runOracle (oracle 7 2 94) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_zero", refused (runOracle (oracle 7 0 98) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_negative", refused
    (runOracle (oracle 7 (-1) 98) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_positive_zero_exposure", postMatches
    (zeroExposureBorrow 2) expectedZeroExposure),
  ("reference_oracle_zero_independent", refused (zeroExposureBorrow 0) .guard),
  ("reference_oracle_negative_independent", refused (zeroExposureBorrow (-1)) .guard),
  ("reference_oracle_future", refused (runOracle (oracle 7 2 101) 100 (borrowRequest 3)) .guard),
  ("reference_oracle_wrong_feed", refused
    (runOracle (oracle 8 2 98) 100 (borrowRequest 3)) (.evaluation .missingObservation)),
  ("reference_oracle_missing", refused
    (runOracle (fun _ ↦ none) 100 (borrowRequest 3)) (.evaluation .missingObservation)),
  ("reference_oracle_wrong_dimension", refused
    (runOracle (fun _ ↦ some ⟨⟨.price .usd .collateral, 2⟩, 98⟩) 100 (borrowRequest 3))
    (.evaluation .observationUnit)),
  ("reference_collateral_exceeded", refused (run (borrowRequest 9)) .guard),
  ("reference_transfer_insufficient", refused (run (transferRequest 11)) .insufficientFunds),
  ("reference_deposit_insufficient", refused (run (depositRequest 11)) .insufficientFunds),
  ("reference_withdraw_insufficient", refused (run (withdrawRequest 5)) .insufficientFunds),
  ("reference_pool_illiquid", refused illiquidBorrow .insufficientFunds),
  ("reference_wrong_argument_dimension", refused
    (run { depositRequest 4 with arguments := [⟨.amount .share, 4⟩] }) (.evaluation .argumentUnit)),
  ("reference_missing_argument", refused
    (run { transferRequest 3 with arguments := [] }) (.evaluation .argumentCount)),
  ("reference_missing_party", refused (run { transferRequest 3 with parties := [] }) .partyArity),
  ("reference_missing_write", refused
    (runDevelopmentTemplate missingWrites (transferRequest 3)) .writeFootprint),
  ("reference_missing_guard_state_read", refused
    (runDevelopmentTemplate missingBorrowStateReads (borrowRequest 3)) .stateReadFootprint),
  ("reference_missing_guard_env_read", refused
    (runDevelopmentTemplate missingOracleReads (borrowRequest 3)) .envReadFootprint),
  ("reference_declared_effect_read", postMatches
    (runDevelopmentTemplate effectReadTransfer (transferRequest 3)) expectedTransfer),
  ("reference_missing_effect_read", refused
    (runDevelopmentTemplate missingEffectRead (transferRequest 3)) .stateReadFootprint),
  ("reference_unbalanced", refused
    (runDevelopmentTemplate unbalancedTransfer (transferRequest 3)) .accounting),
  ("reference_wrong_asset_accounting", refused
    (runDevelopmentTemplate wrongAssetTransfer (transferRequest 3)) .accounting),
  ("reference_zero_divisor", refused
    (runDevelopmentTemplate zeroPriceDeposit (depositRequest 4)) (.evaluation .divisionByZero))
]

end Acceptance

-- BEGIN PROOFS

namespace Acceptance
open Examples

#eval do
  let mut failed := 0
  for (label, passed) in checks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Typed runtime comparisons failed: {failed}")

set_option maxRecDepth 10000 in
theorem transfer_executed : observe (run (transferRequest 3)) = .ok expectedTransfer := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem deposit_executed : observe (run (depositRequest 4)) = .ok expectedDeposit := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem withdraw_executed : observe (run (withdrawRequest 2)) = .ok expectedWithdraw := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem borrow_executed : observe (run (borrowRequest 3)) = .ok expectedBorrow := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem revoked_request_refused :
    observe (runRevoked ⟨0⟩ (transferRequest 3)) = .error (.execution .unauthorizedInvoke) := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem stale_oracle_refused :
    observe (runOracle (oracle 7 2 94) 100 (borrowRequest 3)) = .error (.execution .guard) := by
  decide +kernel

set_option maxRecDepth 10000 in
theorem issued_used_revoked_refused :
    transferLifecycle = .ok (expectedTransfer, .error .unauthorizedInvoke) := by
  decide +kernel

/-- The reference registry inherits the actual executor's authority result, conditional on
the supplied authenticated context and successful execution. -/
theorem reference_invocation_authority (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger) (post : Result)
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .invoke :=
  execute_invocation_authority registry store ctx env now request state post h

theorem reference_capabilities_preserved (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger) (post : Result)
    (h : execute registry store ctx env now request state = .ok post) : post.capabilities = store :=
  execute_preserves_capabilities registry store ctx env now request state post h

end Acceptance
end DefiKernel.Typed

--- END FILE lean/DefiKernel/Typed/Acceptance.lean ---

--- BEGIN FILE lean/DefiKernel/Typed/Authority.lean ---
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

--- END FILE lean/DefiKernel/Typed/Authority.lean ---

--- BEGIN FILE lean/DefiKernel/Typed/Expr.lean ---
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

--- END FILE lean/DefiKernel/Typed/Expr.lean ---

--- BEGIN FILE lean/DefiKernel/Typed/Transition.lean ---
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

--- END FILE lean/DefiKernel/Typed/Transition.lean ---

--- BEGIN FILE lean/DefiKernel/Typed/Types.lean ---
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

--- END FILE lean/DefiKernel/Typed/Types.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Contracts.lean ---
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

--- END FILE lean/DefiKernel/Composition/Contracts.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Execution.lean ---
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

--- END FILE lean/DefiKernel/Composition/Execution.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Interfaces.lean ---
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

--- END FILE lean/DefiKernel/Composition/Interfaces.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Preservation.lean ---
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

--- END FILE lean/DefiKernel/Composition/Preservation.lean ---

--- BEGIN FILE lean/DefiKernel/Composition/Sequence.lean ---
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

--- END FILE lean/DefiKernel/Composition/Sequence.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Commutation.lean ---
import DefiKernel.Parallel.Execution
import DefiKernel.Parallel.Dependency.Adapter

/-! Congruence of full local histories and exact refusals, then correspondence to actual
serial branch re-execution. Dependency premises are discharged from checked admission. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

structure CursorAgrees (region : Set (Cell P A D)) (left right : Cursor P A D) : Prop where
  state : AgreeOn region left.world.state right.world.state
  capabilities : left.world.capabilities = right.world.capabilities
  events : left.events.map observeEvent = right.events.map observeEvent
  outputs : left.outputs = right.outputs
  nextIndex : left.nextIndex = right.nextIndex
  failure : left.failure = right.failure

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorAgrees.observation {region : Set (Cell P A D)} {left right : Cursor P A D}
    (h : CursorAgrees region left right) : observeBranch left = observeBranch right := by
  simp only [observeBranch, h.events, h.outputs, h.nextIndex, h.failure]

theorem continueRun_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (index : Nat) (fp : Footprint P A D)
    (region : Set (Cell P A D)) (left right : Cursor P A D)
    (hf : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (hi : left.nextIndex = index)
    (ha : CursorAgrees region left right) :
    CursorAgrees region (continueRun cfg boundary left (branch.map Step.invoke))
      (continueRun cfg boundary right (branch.map Step.invoke)) := by
  induction branch generalizing index fp left right with
  | nil => exact ha
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, hfp⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    have hhead : ∀ c ∈ head.reads, c ∈ region := by
      intro c hc
      apply hin c
      simp [hfp, Footprint.append, hc]
    have hrest : ∀ c ∈ rest.reads, c ∈ region := by
      intro c hc
      apply hin c
      simp [hfp, Footprint.append, hc]
    have hir : right.nextIndex = index := ha.nextIndex.symm.trans hi
    cases hfl : left.failure with
    | some failure =>
      have hfr : right.failure = some failure := ha.failure.symm.trans hfl
      simpa [continueRun_failed cfg boundary left failure hfl,
        continueRun_failed cfg boundary right failure hfr] using ha
    | none =>
      have hfr : right.failure = none := ha.failure.symm.trans hfl
      have hs := executeStep_congr cfg (boundary index) index left.outputs inv
        left.world right.world head region hh hhead ha.state ha.capabilities
      change CursorAgrees region
        (continueRun cfg boundary (advance cfg boundary left (.invoke inv))
          (tail.map Step.invoke))
        (continueRun cfg boundary (advance cfg boundary right (.invoke inv))
          (tail.map Step.invoke))
      cases hl : executeStep cfg (boundary index) index left.outputs (.invoke inv) left.world with
      | error le =>
        cases hr : executeStep cfg (boundary index) index left.outputs
            (.invoke inv) right.world with
        | ok rr => simp [hl, hr, StepAgrees] at hs
        | error re =>
          simp only [hl, hr, StepAgrees] at hs
          subst re
          have hal : advance cfg boundary left (.invoke inv) =
              { left with failure := some ⟨index, some (.invoke inv), le⟩ } := by
            simp [advance, hfl, hi, hl]
          have har : advance cfg boundary right (.invoke inv) =
              { right with failure := some ⟨index, some (.invoke inv), le⟩ } := by
            simp [advance, hfr, hir, ← ha.outputs, hr]
          rw [hal, har]
          rw [continueRun_failed cfg boundary _ _ rfl,
            continueRun_failed cfg boundary _ _ rfl]
          exact ⟨ha.state, ha.capabilities, ha.events, ha.outputs, ha.nextIndex, rfl⟩
      | ok lr =>
        cases hr : executeStep cfg (boundary index) index left.outputs
            (.invoke inv) right.world with
        | error re => simp [hl, hr, StepAgrees] at hs
        | ok rr =>
          simp only [hl, hr, StepAgrees] at hs
          let nl : Cursor P A D :=
            ⟨lr.world, left.events ++ [⟨index, .invoke inv, left.world, lr⟩],
              left.outputs ++ lr.outputs, index + 1, none⟩
          let nr : Cursor P A D :=
            ⟨rr.world, right.events ++ [⟨index, .invoke inv, right.world, rr⟩],
              right.outputs ++ rr.outputs, index + 1, none⟩
          have hal : advance cfg boundary left (.invoke inv) = nl := by
            simp [advance, hfl, hi, hl, nl]
          have har : advance cfg boundary right (.invoke inv) = nr := by
            simp [advance, hfr, hir, ← ha.outputs, hr, nr]
          rw [hal, har]
          apply ih (index + 1) rest nl nr ht hrest rfl
          refine ⟨hs.1, hs.2.1, ?_, ?_, rfl, rfl⟩
          · simp [nl, nr, List.map_append, observeEvent, ha.events, hs.2.2.1, hs.2.2.2]
          · simp [nl, nr, ha.outputs, hs.2.2.2]

theorem runBranch_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (left right : World P A D) (hf : analyzeBranch cfg boundary branch = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hc : left.capabilities = right.capabilities) :
    CursorAgrees region (runBranch cfg boundary left branch)
      (runBranch cfg boundary right branch) := by
  apply continueRun_congr cfg boundary branch 0 fp region _ _ hf hin rfl
  exact ⟨ha, hc, rfl, rfl, rfl, rfl⟩

theorem continueRun_frame (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (index : Nat) (fp : Footprint P A D) (cursor : Cursor P A D)
    (hf : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (hi : cursor.nextIndex = index) :
    (∀ c, c ∉ fp.writes →
      (continueRun cfg boundary cursor (branch.map Step.invoke)).world.state.balance c =
        cursor.world.state.balance c) ∧
      (continueRun cfg boundary cursor (branch.map Step.invoke)).world.capabilities =
        cursor.world.capabilities := by
  induction branch generalizing index fp cursor with
  | nil => exact ⟨fun _ _ ↦ rfl, rfl⟩
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, hfp⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    cases hfl : cursor.failure with
    | some failure =>
      rw [continueRun_failed cfg boundary cursor failure hfl]
      exact ⟨fun _ _ ↦ rfl, rfl⟩
    | none =>
      change (∀ c, c ∉ fp.writes →
        (continueRun cfg boundary (advance cfg boundary cursor (.invoke inv))
          (tail.map Step.invoke)).world.state.balance c = cursor.world.state.balance c) ∧
        (continueRun cfg boundary (advance cfg boundary cursor (.invoke inv))
          (tail.map Step.invoke)).world.capabilities = cursor.world.capabilities
      cases hx : executeStep cfg (boundary index) index cursor.outputs
          (.invoke inv) cursor.world with
      | error reason =>
        have hadv : advance cfg boundary cursor (.invoke inv) =
            { cursor with failure := some ⟨index, some (.invoke inv), reason⟩ } := by
          simp [advance, hfl, hi, hx]
        rw [hadv, continueRun_failed cfg boundary _ _ rfl]
        exact ⟨fun _ _ ↦ rfl, rfl⟩
      | ok result =>
        let next : Cursor P A D :=
          ⟨result.world, cursor.events ++ [⟨index, .invoke inv, cursor.world, result⟩],
            cursor.outputs ++ result.outputs, index + 1, none⟩
        have hadv : advance cfg boundary cursor (.invoke inv) = next := by
          simp [advance, hfl, hi, hx, next]
        rw [hadv]
        have hs := executeStep_target_frame cfg (boundary index) index cursor.outputs inv
          cursor.world result head hh hx
        have htail := ih (index + 1) rest next ht rfl
        refine ⟨?_, htail.2.trans hs.2⟩
        intro c hc
        have hhead : c ∉ head.writes := by
          intro hm; apply hc; simp [hfp, Footprint.append, hm]
        have hrest : c ∉ rest.writes := by
          intro hm; apply hc; simp [hfp, Footprint.append, hm]
        exact (htail.1 c hrest).trans (hs.1 c hhead)

theorem runBranch_frame (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (fp : Footprint P A D)
    (hf : analyzeBranch cfg boundary branch = .ok fp) :
    (∀ c, c ∉ fp.writes → (runBranch cfg boundary initial branch).world.state.balance c =
      initial.state.balance c) ∧
      (runBranch cfg boundary initial branch).world.capabilities = initial.capabilities := by
  exact continueRun_frame cfg boundary branch 0 fp (startCursor cfg initial) hf rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem analyzeBranchFrom_writes_read (cfg : Config P A D)
    (boundary : Nat → Boundary P A D) (index : Nat) (branch : Branch P A D)
    (fp : Footprint P A D) (hf : analyzeBranchFrom cfg boundary index branch = .ok fp) :
    ∀ c ∈ fp.writes, c ∈ fp.reads := by
  induction branch generalizing index fp with
  | nil =>
    have he : fp = Footprint.empty := by simpa [analyzeBranchFrom] using hf.symm
    simp [he, Footprint.empty]
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, rfl⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    intro c hc
    rcases List.mem_append.mp hc with hc | hc
    · exact List.mem_append_left _ (analyzeInvocation_writes_read _ _ _ _ hh c hc)
    · exact List.mem_append_right _ (ih (index + 1) rest ht c hc)

/-- The real second run has the same local observations, including exact refusal. -/
theorem rerun_after_peer (cfg : Config P A D) (ownBoundary peerBoundary : Nat → Boundary P A D)
    (initial : World P A D) (own peer : Branch P A D) (ownFp peerFp : Footprint P A D)
    (ho : analyzeBranch cfg ownBoundary own = .ok ownFp)
    (hp : analyzeBranch cfg peerBoundary peer = .ok peerFp)
    (hd : ∀ c ∈ peerFp.writes, c ∉ ownFp.reads) :
    CursorAgrees {c | c ∈ ownFp.reads} (runBranch cfg ownBoundary initial own)
      (runBranch cfg ownBoundary (runBranch cfg peerBoundary initial peer).world own) := by
  have frame := runBranch_frame cfg peerBoundary initial peer peerFp hp
  apply runBranch_congr cfg ownBoundary own ownFp _ _ _ ho (fun _ h ↦ h)
  · intro c hc
    exact (frame.1 c (fun hw ↦ hd c hw hc)).symm
  · exact frame.2.symm

/-- Region merge equals a fresh right execution after the real left retained prefix. -/
theorem merge_serialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (hc : Compatible lf rf) :
    WorldEquivalent
      (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
        (runBranch cfg (boundaries .right) initial right).world)
      (runBranch cfg (boundaries .right)
        (runBranch cfg (boundaries .left) initial left).world right).world := by
  have le := runBranch_frame cfg (boundaries .left) initial left lf hl
  have re := runBranch_frame cfg (boundaries .right)
    (runBranch cfg (boundaries .left) initial left).world right rf hr
  have ra := rerun_after_peer cfg (boundaries .right) (boundaries .left)
    initial right left rf lf hr hl hc.2.1
  refine ⟨?_, (re.2.trans le.2).symm⟩
  intro c
  by_cases hcl : c ∈ lf.writes
  · have hcr := hc.1 c hcl
    simpa [mergeWorld, hcl] using (re.1 c hcr).symm
  · by_cases hcr : c ∈ rf.writes
    · have hread := analyzeBranchFrom_writes_read cfg (boundaries .right) 0 right rf hr c hcr
      simpa [mergeWorld, hcl, hcr] using ra.state c hread
    · simpa [mergeWorld, hcl, hcr] using ((re.1 c hcr).trans (le.1 c hcl)).symm

theorem runParallel_serialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left right)
      (runSerialLR cfg boundaries initial left right) := by
  cases ha : admit cfg boundaries left right with
  | error reason => simp [runParallel, runSerialLR, ha, ObservationallyEquivalent, WorldEquivalent]
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    obtain ⟨_, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf ha
    simp only [runParallel, runSerialLR, ha, ObservationallyEquivalent]
    exact ⟨merge_serialLR cfg boundaries initial left right lf rf hl hr hc, True.intro,
      (rerun_after_peer cfg (boundaries .right) (boundaries .left)
        initial right left rf lf hr hl hc.2.1).observation⟩

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_swap (lf rf : Footprint P A D) (initial left right : World P A D)
    (hc : Compatible lf rf) :
    WorldEquivalent (mergeWorld lf rf initial left right)
      (mergeWorld rf lf initial right left) := by
  refine ⟨?_, rfl⟩
  intro c
  by_cases hl : c ∈ lf.writes
  · simp [mergeWorld, hl, hc.1 c hl]
  · by_cases hr : c ∈ rf.writes <;> simp [mergeWorld, hl, hr]

theorem runParallel_serialRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left right)
      (runSerialRL cfg boundaries initial left right) := by
  cases ha : admit cfg boundaries left right with
  | error reason => simp [runParallel, runSerialRL, ha, ObservationallyEquivalent, WorldEquivalent]
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    obtain ⟨_, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf ha
    let swapped : ParallelBoundary P A D := fun side ↦
      match side with | .left => boundaries .right | .right => boundaries .left
    have hm := merge_serialLR cfg swapped initial right left rf lf hr hl (compatible_symm hc)
    have hs := mergeWorld_swap lf rf initial
      (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world hc
    simp only [runParallel, runSerialRL, ha, ObservationallyEquivalent]
    exact ⟨⟨fun c ↦ (hs.1 c).trans (hm.1 c), hs.2.trans hm.2⟩,
      (rerun_after_peer cfg (boundaries .left) (boundaries .right)
        initial left right lf rf hl hr hc.2.2).observation, True.intro⟩

/-- Singleton calls inherit exact refusal-aware sequential correspondence. -/
theorem singleton_commutation (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Invocation P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial [left] [right])
      (runSerialLR cfg boundaries initial [left] [right]) ∧
    ObservationallyEquivalent (runParallel cfg boundaries initial [left] [right])
      (runSerialRL cfg boundaries initial [left] [right]) :=
  ⟨runParallel_serialLR _ _ _ _ _, runParallel_serialRL _ _ _ _ _⟩

theorem runBranch_empty (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) : runBranch cfg boundary initial [] = startCursor cfg initial := rfl

/-- An admitted empty peer has no events or outputs and contributes no ledger change. -/
theorem runParallel_empty_right (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left : Branch P A D) (lf : Footprint P A D)
    (ha : admit cfg boundaries left [] = .ok (lf, .empty)) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left [])
      (.executed ⟨(runBranch cfg (boundaries .left) initial left).world,
        runBranch cfg (boundaries .left) initial left, startCursor cfg initial⟩) := by
  obtain ⟨_, hl, _, _⟩ := admit_ok cfg boundaries left [] lf .empty ha
  have hf := runBranch_frame cfg (boundaries .left) initial left lf hl
  simp only [runParallel, ha, ObservationallyEquivalent, runBranch_empty]
  refine ⟨⟨?_, hf.2.symm⟩, True.intro, True.intro⟩
  intro c
  by_cases hc : c ∈ lf.writes
  · simp [mergeWorld, hc]
  · simpa [mergeWorld, hc, Footprint.empty] using (hf.1 c hc).symm

theorem runParallel_empty_left (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (right : Branch P A D) (rf : Footprint P A D)
    (ha : admit cfg boundaries [] right = .ok (.empty, rf)) :
    ObservationallyEquivalent (runParallel cfg boundaries initial [] right)
      (.executed ⟨(runBranch cfg (boundaries .right) initial right).world,
        startCursor cfg initial, runBranch cfg (boundaries .right) initial right⟩) := by
  obtain ⟨_, _, hr, _⟩ := admit_ok cfg boundaries [] right .empty rf ha
  have hf := runBranch_frame cfg (boundaries .right) initial right rf hr
  simp only [runParallel, ha, ObservationallyEquivalent, runBranch_empty]
  refine ⟨⟨?_, hf.2.symm⟩, True.intro, True.intro⟩
  intro c
  by_cases hc : c ∈ rf.writes
  · simp [mergeWorld, hc, Footprint.empty]
  · simpa [mergeWorld, hc, Footprint.empty] using (hf.1 c hc).symm

/-- Both real sequential schedules yield the same complete canonical observation. -/
theorem serial_orders_equivalent (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runSerialLR cfg boundaries initial left right)
      (runSerialRL cfg boundaries initial left right) :=
  (runParallel_serialLR cfg boundaries initial left right).symm.trans
    (runParallel_serialRL cfg boundaries initial left right)

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Commutation.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Compatibility.lean ---
import DefiKernel.Composition.Execution

/-! Conservative admission for invocation-only branches. Lists preserve deterministic witnesses. -/
namespace DefiKernel.Parallel
open Typed Composition

inductive BranchId where
  | left
  | right
  deriving DecidableEq, Repr
abbrev Branch (P A D : Type) := List (Invocation P A D)
abbrev ParallelBoundary (P A D : Type) := BranchId → Nat → Boundary P A D
structure Footprint (P A D : Type) where
  reads : List (Cell P A D)
  writes : List (Cell P A D)
  deriving DecidableEq, Repr
structure LocalFailure where
  index : Nat
  reason : Composition.Failure
  deriving DecidableEq, Repr
inductive ConflictKind where
  | writeWrite
  | leftWriteRightRead
  | rightWriteLeftRead
  deriving DecidableEq, Repr
inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : LocalFailure)
  | conflict (kind : ConflictKind) (cell : Cell P A D)
  deriving DecidableEq, Repr
variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
def Footprint.empty : Footprint P A D := ⟨[], []⟩
def Footprint.append (a b : Footprint P A D) : Footprint P A D :=
  ⟨a.reads ++ b.reads, a.writes ++ b.writes⟩
/-- Lookup, read resolution, write/target resolution, then access checks.
No financial values are evaluated. -/
def analyzeInvocation (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) : Except Composition.Failure (Footprint P A D) := do
  let (component, iface) ← match lookupOperation cfg.catalog inv.component inv.operation with
    | none => .error (.interface .unknownOperation)
    | some pair => .ok pair
  let template ← match cfg.registry inv.operation with
    | none => .error (.kernel .unknownOperation)
    | some template => .ok template
  let reads ← (resolveRefs boundary.ctx.principal inv.parties
    (template.requiredStateReads ++ template.stateReads)).mapError
      (fun e ↦ .interface (.resolution e))
  let writes ← (resolveRefs boundary.ctx.principal inv.parties
    (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))).mapError
      (fun e ↦ .interface (.resolution e))
  let _ ← (checkAccess component template boundary.ctx inv.parties).mapError .interface
  return ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩
/-- Structural analysis covers the entire suffix even when a financial prefix would refuse. -/
def analyzeBranchFrom (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) : Branch P A D → Except LocalFailure (Footprint P A D)
  | [] => .ok .empty
  | inv :: tail => do
    let head ← (analyzeInvocation cfg (boundary index) inv).mapError (⟨index, ·⟩)
    let rest ← analyzeBranchFrom cfg boundary (index + 1) tail
    return head.append rest
def analyzeBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) : Except LocalFailure (Footprint P A D) :=
  analyzeBranchFrom cfg boundary 0 branch
def firstOverlap (xs ys : List (Cell P A D)) : Option (Cell P A D) :=
  xs.find? (fun c ↦ decide (c ∈ ys))
def checkCompatibility (left right : Footprint P A D) :
    Except (AdmissionFailure P A D) PUnit :=
  match firstOverlap left.writes right.writes with
  | some c => .error (.conflict .writeWrite c)
  | none => match firstOverlap left.writes right.reads with
    | some c => .error (.conflict .leftWriteRightRead c)
    | none => match firstOverlap right.writes left.reads with
      | some c => .error (.conflict .rightWriteLeftRead c)
      | none => .ok ⟨⟩
def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) : Except (AdmissionFailure P A D)
      (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← checkCompatibility lf rf
  return (lf, rf)

-- BEGIN PROOFS

def Compatible (left right : Footprint P A D) : Prop :=
  (∀ c ∈ left.writes, c ∉ right.writes) ∧
  (∀ c ∈ left.writes, c ∉ right.reads) ∧
  (∀ c ∈ right.writes, c ∉ left.reads)
theorem firstOverlap_none_iff (xs ys : List (Cell P A D)) :
    firstOverlap xs ys = none ↔ ∀ c ∈ xs, c ∉ ys := by
  simp [firstOverlap, List.find?_eq_none]
theorem checkCompatibility_ok_iff (left right : Footprint P A D) :
    checkCompatibility left right = .ok PUnit.unit ↔ Compatible left right := by
  unfold Compatible
  simp only [← firstOverlap_none_iff]
  unfold checkCompatibility
  cases hww : firstOverlap left.writes right.writes <;>
    cases hlr : firstOverlap left.writes right.reads <;>
    cases hrl : firstOverlap right.writes left.reads <;>
    simp_all
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem compatible_symm {left right : Footprint P A D} (h : Compatible left right) :
    Compatible right left := by
  exact ⟨fun c hr hl ↦ h.1 c hl hr, h.2.2, h.2.1⟩
theorem analyzeInvocation_ok (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template reads writes,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.requiredStateReads ++ template.stateReads) = .ok reads ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) = .ok writes ∧
      checkAccess component template boundary.ctx inv.parties = .ok PUnit.unit ∧
      fp = ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩ := by
  unfold analyzeInvocation at h
  simp only [bind, Except.bind, Except.mapError, pure, Except.pure] at h
  split at h
  · contradiction
  rename_i pair hl
  rcases pair with ⟨component, iface⟩
  split at h
  · contradiction
  rename_i template ht
  split at h
  · contradiction
  rename_i reads hr
  split at h
  · contradiction
  rename_i writes hw
  split at h
  · contradiction
  rename_i token hc
  cases token
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨component, iface, template, reads, writes, hl, ht,
    unmap _ _ _ hr, unmap _ _ _ hw, unmap _ _ _ hc, (Except.ok.inj h).symm⟩
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_member (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) :
    ∃ cell ∈ cells, ref.2.resolve caller parties = .ok cell := by
  induction refs generalizing cells with
  | nil => simp at hr
  | cons head tail ih =>
    simp only [resolveRefs, List.mapM_cons, bind, Except.bind] at h
    cases hh : head.2.resolve caller parties with
    | error e => simp [hh] at h
    | ok cell =>
      cases ht : resolveRefs caller parties tail with
      | error e =>
        simp only [resolveRefs] at ht
        simp [hh, ht] at h
      | ok rest =>
        have htt := ht
        simp only [resolveRefs] at ht
        simp only [hh, ht, pure, Except.pure,
          Except.ok.injEq] at h
        subst cells
        rcases List.mem_cons.mp hr with he | hm
        · subst ref; exact ⟨cell, by simp, hh⟩
        · obtain ⟨c, hc, resolved⟩ := ih rest htt hm
          exact ⟨c, List.mem_cons_of_mem _ hc, resolved⟩
theorem analyzeBranchFrom_cons (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (inv : Invocation P A D) (tail : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index (inv :: tail) = .ok fp) :
    ∃ head rest, analyzeInvocation cfg (boundary index) inv = .ok head ∧
      analyzeBranchFrom cfg boundary (index + 1) tail = .ok rest ∧ fp = head.append rest := by
  unfold analyzeBranchFrom at h
  cases hh : analyzeInvocation cfg (boundary index) inv with
  | error e => simp [hh, Except.mapError, bind, Except.bind] at h
  | ok head =>
    cases ht : analyzeBranchFrom cfg boundary (index + 1) tail with
    | error e => simp [hh, ht, Except.mapError, bind, Except.bind] at h
    | ok rest =>
      simp only [hh, ht, Except.mapError, bind, Except.bind, pure, Except.pure,
        Except.ok.injEq] at h
      exact ⟨head, rest, rfl, rfl, h.symm⟩
theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧ Compatible lf rf := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i token hc
  cases token
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr,
    (checkCompatibility_ok_iff _ _).mp hc⟩

theorem admit_compatible (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) : Compatible lf rf :=
  (admit_ok cfg boundaries left right lf rf h).2.2.2

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_mem_of_resolve (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) (cell : Cell P A D)
    (resolved : ref.2.resolve caller parties = .ok cell) : cell ∈ cells := by
  obtain ⟨c, hc, he⟩ := resolveRefs_member caller parties refs cells h ref hr
  rw [resolved] at he
  cases he
  exact hc

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_append_ok (caller : P) (parties : List P)
    (xs ys : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties (xs ++ ys) = .ok cells) :
    ∃ left right, resolveRefs caller parties xs = .ok left ∧
      resolveRefs caller parties ys = .ok right ∧ cells = left ++ right := by
  simp only [resolveRefs, List.mapM_append] at h
  change ((resolveRefs caller parties xs).bind fun left ↦
    (resolveRefs caller parties ys).bind fun right ↦ .ok (left ++ right)) = .ok cells at h
  cases hx : resolveRefs caller parties xs with
  | error e => simp [hx, Except.bind] at h
  | ok left =>
    cases hy : resolveRefs caller parties ys with
    | error e => simp [hx, hy, Except.bind] at h
    | ok right =>
      simp only [hx, hy, Except.bind, Except.ok.injEq] at h
      exact ⟨left, right, rfl, rfl, h.symm⟩

/-- Accepted analysis covers every syntactic/declared read, every potential write and target,
and every output, regardless of whether the invocation would execute successfully. -/
theorem analyzeInvocation_coverage (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      (∀ ref ∈ template.requiredStateReads ++ template.stateReads,
        ∃ c ∈ fp.reads, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ ref ∈ template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩),
        ∃ c ∈ fp.writes, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ output ∈ iface.outputs, output.cell ∈ fp.reads) ∧
      (∀ c ∈ fp.writes, c ∈ fp.reads) := by
  obtain ⟨component, iface, template, reads, writes, hl, ht, hr, hw, _, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp h
  refine ⟨component, iface, template, hl, ht, ?_, ?_, ?_, ?_⟩
  · intro ref hm
    obtain ⟨c, hc, he⟩ := resolveRefs_member _ _ _ _ hr ref hm
    exact ⟨c, by simp [hc], he⟩
  · intro ref hm
    exact resolveRefs_member _ _ _ _ hw ref hm
  · intro output hm
    simp only [List.mem_append, List.mem_map]
    exact Or.inr ⟨output, hm, rfl⟩
  · intro c hc
    simp [hc]

theorem analyzeInvocation_writes_read (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∀ c ∈ fp.writes, c ∈ fp.reads := by
  obtain ⟨_, _, _, _, _, _, _, _, hw⟩ := analyzeInvocation_coverage cfg boundary inv fp h
  exact hw

/-- Every local invocation has its own analyzed footprint contained in the whole branch. -/
theorem analyzeBranchFrom_member (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (branch : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (n : Nat) (inv : Invocation P A D) (atIndex : branch[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundary (index + n)) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ fp.reads) ∧ (∀ c ∈ part.writes, c ∈ fp.writes) := by
  induction branch generalizing index fp n with
  | nil => simp at atIndex
  | cons head tail ih =>
    obtain ⟨hf, tf, hh, ht, rfl⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ h
    cases n with
    | zero =>
      simp only [List.getElem?_cons_zero, Option.some.injEq] at atIndex
      subst inv
      exact ⟨hf, by simpa using hh,
        fun c hc ↦ List.mem_append_left _ hc, fun c hc ↦ List.mem_append_left _ hc⟩
    | succ n =>
      simp only [List.getElem?_cons_succ] at atIndex
      obtain ⟨part, hl, hr, hw⟩ := ih (index + 1) tf ht n atIndex
      refine ⟨part, ?_, fun c hc ↦ List.mem_append_right _ (hr c hc),
        fun c hc ↦ List.mem_append_right _ (hw c hc)⟩
      simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using hl

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Compatibility.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Dependency.lean ---
import DefiKernel.Composition.Contracts

/-! Complete evaluation and execution dependence on resolved reads and potential delta targets.
No successful footprint check is assumed in the refusal proofs. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def ResolvedReadsAgree (template : Template P A D) (caller : P) (parties : List P)
    (left right : State P A D) : Prop :=
  ∀ ref ∈ template.requiredStateReads, ∀ c,
    ref.2.resolve caller parties = .ok c → left.balance c = right.balance c

def TargetsWithin (template : Template P A D) (caller : P) (parties : List P)
    (region : Set (Cell P A D)) : Prop :=
  ∀ d ∈ template.deltas, ∀ c, d.target.resolve caller parties = .ok c → c ∈ region

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq D] in
/-- Complete expression results agree on a resolved syntactic read region. -/
theorem expression_congr_of_region {signature : List (Unit A)} {u : Unit A}
    (expression : Expr P A D signature u) (left right : State P A D)
    (env : Environment A D) (caller : P) (parties : List P) (args : Args signature) (now : Nat)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hr : ∀ ref ∈ expression.stateReads, ∀ c,
      ref.2.resolve caller parties = .ok c → c ∈ region) :
    expression.eval ⟨left, env, caller, parties, args, now⟩ =
      expression.eval ⟨right, env, caller, parties, args, now⟩ := by
  apply expression.eval_congr_of_resolved
    ⟨left, env, caller, parties, args, now⟩
    ⟨right, env, caller, parties, args, now⟩ rfl rfl rfl
  · intro ref hm c hc
    exact ha c (hr ref hm c hc)
  · intro key hk
    cases key <;> rfl

theorem mapM_congr_on {α β ε : Type} (xs : List α) (f g : α → Except ε β)
    (h : ∀ x ∈ xs, f x = g x) : xs.mapM f = xs.mapM g := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    simp only [List.mapM_cons, h x (by simp), ih (fun y hy ↦ h y (by simp [hy]))]

theorem mapM_ok_mem {α β ε : Type} (xs : List α) (f : α → Except ε β)
    (ys : List β) (h : xs.mapM f = .ok ys) :
    ∀ y ∈ ys, ∃ x ∈ xs, f x = .ok y := by
  induction xs generalizing ys with
  | nil =>
    have hy : ys = [] := (Except.ok.inj h).symm
    subst ys
    simp
  | cons x xs ih =>
    rw [List.mapM_cons] at h
    cases hx : f x <;> simp only [hx, bind, Except.bind] at h
    · contradiction
    rename_i z
    cases ht : xs.mapM f <;> simp only [ht, bind, Except.bind, pure, Except.pure] at h
    · contradiction
    cases h
    intro y hy
    rcases List.mem_cons.mp hy with rfl | hy
    · exact ⟨x, by simp, hx⟩
    · obtain ⟨a, ha, hf⟩ := ih _ ht y hy
      exact ⟨a, by simp [ha], hf⟩

theorem evaluate_congr (template : Template P A D) (left right : State P A D)
    (env : Environment A D) (caller : P) (parties : List P)
    (args : Args template.signature) (now : Nat)
    (h : ResolvedReadsAgree template caller parties left right) :
    template.evaluate ⟨left, env, caller, parties, args, now⟩ =
      template.evaluate ⟨right, env, caller, parties, args, now⟩ := by
  have expr {u : Unit A} (e : Expr P A D template.signature u)
      (he : ∀ ref ∈ e.stateReads, ref ∈ template.requiredStateReads) :
      e.eval ⟨left, env, caller, parties, args, now⟩ =
        e.eval ⟨right, env, caller, parties, args, now⟩ := by
    apply e.eval_congr_of_resolved
      ⟨left, env, caller, parties, args, now⟩
      ⟨right, env, caller, parties, args, now⟩ rfl rfl rfl
    · intro ref hr c hc
      exact h ref (he ref hr) c hc
    · intro key hk
      cases key <;> rfl
  have hg := expr template.guard (by intros; simp_all [Template.requiredStateReads])
  have hd := mapM_congr_on template.deltas
    (fun d ↦ do
      let c ← d.target.resolve caller parties
      let a ← d.amount.eval ⟨left, env, caller, parties, args, now⟩
      pure (c, a))
    (fun d ↦ do
      let c ← d.target.resolve caller parties
      let a ← d.amount.eval ⟨right, env, caller, parties, args, now⟩
      pure (c, a)) (by
        intro d hd
        rw [expr d.amount (by
          intro ref hr
          simp only [Template.requiredStateReads, List.mem_append, List.mem_flatMap]
          exact Or.inl (Or.inr ⟨d, hd, hr⟩))])
  have hs := mapM_congr_on template.supplyDeltas
    (fun d ↦ do
      let a ← d.amount.eval ⟨left, env, caller, parties, args, now⟩
      pure ((d.domain, d.asset), a))
    (fun d ↦ do
      let a ← d.amount.eval ⟨right, env, caller, parties, args, now⟩
      pure ((d.domain, d.asset), a)) (by
        intro d hd
        rw [expr d.amount (by
          intro ref hr
          simp only [Template.requiredStateReads, List.mem_append, List.mem_flatMap]
          exact Or.inr ⟨d, hd, hr⟩)])
  unfold Template.evaluate
  rw [hg, hd, hs]

theorem evaluated_targets (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate ctx = .ok e) :
    ∀ entry ∈ e.deltas, ∃ d ∈ template.deltas,
      d.target.resolve ctx.caller ctx.parties = .ok entry.1 := by
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
  rename_i deltas hd
  split at h
  · contradiction
  cases h
  intro entry he
  obtain ⟨d, hm, hv⟩ := mapM_ok_mem _ _ _ hd entry he
  refine ⟨d, hm, ?_⟩
  cases hc : d.target.resolve ctx.caller ctx.parties <;>
    simp only [hc, bind, Except.bind] at hv
  · contradiction
  cases ha : d.amount.eval ctx <;> simp only [ha, bind, Except.bind] at hv
  · contradiction
  cases hv
  rfl

theorem evaluated_effect_zero_outside (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate ctx = .ok e) (region : Set (Cell P A D))
    (ht : TargetsWithin template ctx.caller ctx.parties region)
    (c : Cell P A D) (hc : c ∉ region) : e.effect c = 0 := by
  apply List.sum_eq_zero
  intro v hv
  obtain ⟨entry, he, rfl⟩ := List.mem_map.mp hv
  have hn : entry.1 ≠ c := by
    intro eq
    obtain ⟨d, hd, hr⟩ := evaluated_targets template ctx e h entry he
    exact hc (eq ▸ ht d hd entry.1 hr)
  simp [hn]

variable [Fintype P] [Fintype A] [Fintype D]

/-- Equality on potential targets suffices even if accounting or writes later refuse. -/
theorem funds_iff (left right : State P A D) (e : Evaluated P A D)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hz : ∀ c, c ∉ region → e.effect c = 0) :
    (∀ c, 0 ≤ left.balance c + e.effect c) ↔
      (∀ c, 0 ≤ right.balance c + e.effect c) := by
  constructor
  · intro h c
    by_cases hc : c ∈ region
    · rw [← ha c hc]
      exact h c
    · simpa [hz c hc] using right.nonneg c
  · intro h c
    by_cases hc : c ∈ region
    · rw [ha c hc]
      exact h c
    · simpa [hz c hc] using left.nonneg c

/-- Success compares the protected region and fixed store; errors compare exact constructors. -/
def ExecutionAgrees (region : Set (Cell P A D)) :
    Except Typed.Refusal (ExecutionResult P A D) →
    Except Typed.Refusal (ExecutionResult P A D) → Prop
  | .error a, .error b => a = b
  | .ok a, .ok b => AgreeOn region a.state b.state ∧ a.capabilities = b.capabilities
  | _, _ => False

theorem applyEvaluated_congr (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (request : Request P A D)
    (left right : State P A D) (e : Evaluated P A D)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hz : ∀ c, c ∉ region → e.effect c = 0) :
    ExecutionAgrees region (applyEvaluated store ctx request left e)
      (applyEvaluated store ctx request right e) := by
  have hf := funds_iff left right e region ha hz
  by_cases hl : ∀ c, 0 ≤ left.balance c + e.effect c
  · have hr := hf.mp hl
    unfold applyEvaluated
    simp only [dif_pos hl, dif_pos hr]
    split_ifs <;> try rfl
    exact ⟨fun c hc ↦ congrArg (fun q ↦ q + e.effect c) (ha c hc), rfl⟩
  · have hr : ¬ ∀ c, 0 ≤ right.balance c + e.effect c := fun h ↦ hl (hf.mpr h)
    unfold applyEvaluated
    simp only [dif_neg hl, dif_neg hr]
    split_ifs <;> rfl

/-- Complete registered execution dependence, including every exact refusal. -/
theorem execute_congr (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region) :
    ExecutionAgrees region (Typed.execute registry store ctx env now request left)
      (Typed.execute registry store ctx env now request right) := by
  unfold Typed.execute
  cases hs : registry request.operation with
  | none => rfl
  | some template =>
    simp only [bind, Except.bind]
    split_ifs <;> (try simp only [throw, throwThe, bind, Except.bind])
    all_goals try rfl
    all_goals
      cases argsOk : Args.check template.signature request.arguments <;>
        simp only [Except.mapError, bind, Except.bind]
    all_goals try rfl
    rename_i args
    have he := evaluate_congr template left right env ctx.principal request.parties args now
      (hr template hs)
    rw [← he]
    cases ev : template.evaluate ⟨left, env, ctx.principal, request.parties, args, now⟩ with
    | error reason => rfl
    | ok e =>
      simp only [Except.mapError, bind, Except.bind]
      exact applyEvaluated_congr store ctx request left right e region ha
        (evaluated_effect_zero_outside template _ e ev region (ht template hs))

theorem execute_refusal_iff (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region) (reason : Typed.Refusal) :
    Typed.execute registry store ctx env now request left = .error reason ↔
      Typed.execute registry store ctx env now request right = .error reason := by
  have h := execute_congr registry store ctx env now request left right region ha hr ht
  cases hl : Typed.execute registry store ctx env now request left <;>
    cases hh : Typed.execute registry store ctx env now request right <;>
    simp_all [ExecutionAgrees]

theorem execute_success_congr (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region)
    (post : ExecutionResult P A D)
    (hx : Typed.execute registry store ctx env now request left = .ok post) :
    ∃ other, Typed.execute registry store ctx env now request right = .ok other ∧
      AgreeOn region post.state other.state ∧ post.capabilities = store ∧
      other.capabilities = store := by
  have h := execute_congr registry store ctx env now request left right region ha hr ht
  rw [hx] at h
  cases hh : Typed.execute registry store ctx env now request right with
  | error reason => simp [hh, ExecutionAgrees] at h
  | ok other =>
    rw [hh] at h
    have hp := execute_preserves_capabilities registry store ctx env now request left post hx
    have ho := execute_preserves_capabilities registry store ctx env now request right other hh
    exact ⟨other, rfl, h.1, hp, ho⟩

/-- Each success frames its own input outside potential targets, regardless of foreign balances. -/
theorem execute_target_frame (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (pre : State P A D) (post : ExecutionResult P A D)
    (region : Set (Cell P A D))
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region)
    (hx : Typed.execute registry store ctx env now request pre = .ok post) :
    ∀ c, c ∉ region → post.state.balance c = pre.balance c := by
  obtain ⟨template, hs, args, _, e, he, happly⟩ :=
    execute_evaluated registry store ctx env now request pre post hx
  have hp := (applyEvaluated_ok_iff store ctx request pre e post).mp happly
  intro c hc
  rw [hp.2.2 c, evaluated_effect_zero_outside template _ e he region (ht template hs) c hc]
  exact add_zero _

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Dependency.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Execution.lean ---
import DefiKernel.Parallel.Compatibility
import DefiKernel.Parallel.Observation

/-! Binary fork/join over invocation-only branches. Each branch retains its own successful
prefix and refusal. Serial references rerun the existing executor with fresh local histories. -/
namespace DefiKernel.Parallel
open Typed Composition

structure Joined (P A D : Type) where
  world : World P A D
  left : Cursor P A D
  right : Cursor P A D

inductive Result (P A D : Type) where
  | refused (reason : AdmissionFailure P A D) (world : World P A D)
  | executed (joined : Joined P A D)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- An admitted region chooses one complete balance, never a sum of branch base balances. -/
def mergeWorld (leftFootprint rightFootprint : Footprint P A D)
    (initial left right : World P A D) : World P A D :=
  ⟨⟨fun c ↦ if c ∈ leftFootprint.writes then left.state.balance c
      else if c ∈ rightFootprint.writes then right.state.balance c
      else initial.state.balance c,
    fun c ↦ by
      split
      · exact left.state.nonneg c
      · split
        · exact right.state.nonneg c
        · exact initial.state.nonneg c⟩,
    initial.capabilities⟩

def runBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) : Cursor P A D :=
  Composition.run cfg boundary initial (branch.map Step.invoke)

def runParallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok (leftFootprint, rightFootprint) =>
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) initial right
    .executed ⟨mergeWorld leftFootprint rightFootprint initial l.world r.world, l, r⟩

/-- Right always runs after left's retained prefix, including when left has refused. -/
def runSerialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok _ =>
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) l.world right
    .executed ⟨r.world, l, r⟩

/-- Evaluation order changes; branch labels, local history and trusted positions do not. -/
def runSerialRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok _ =>
    let r := runBranch cfg (boundaries .right) initial right
    let l := runBranch cfg (boundaries .left) r.world left
    .executed ⟨l.world, l, r⟩

/-- Pointwise full-ledger equality plus exact capability-store equality. -/
def WorldEquivalent (left right : World P A D) : Prop :=
  (∀ c, left.state.balance c = right.state.balance c) ∧
    left.capabilities = right.capabilities

/-- Raw event worlds are omitted, but every financial and local refusal observation is kept. -/
def ObservationallyEquivalent (left right : Result P A D) : Prop :=
  match left, right with
  | .refused le lw, .refused re rw => le = re ∧ WorldEquivalent lw rw
  | .executed l, .executed r => WorldEquivalent l.world r.world ∧
      observeBranch l.left = observeBranch r.left ∧
      observeBranch l.right = observeBranch r.right
  | _, _ => False

def worldEq (left right : World P A D) : Bool :=
  decide ((∀ c, left.state.balance c = right.state.balance c) ∧
    left.capabilities = right.capabilities)

def observationsEqual (left right : Result P A D) : Bool :=
  match left, right with
  | .refused le lw, .refused re rw => decide (le = re) && worldEq lw rw
  | .executed l, .executed r => worldEq l.world r.world &&
      decide (observeBranch l.left = observeBranch r.left) &&
      decide (observeBranch l.right = observeBranch r.right)
  | _, _ => false

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_store (lf rf : Footprint P A D) (initial left right : World P A D) :
    (mergeWorld lf rf initial left right).capabilities = initial.capabilities := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_nonnegative (lf rf : Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D) :
    0 ≤ (mergeWorld lf rf initial left right).state.balance c :=
  (mergeWorld lf rf initial left right).state.nonneg c

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_outside (lf rf : Footprint P A D) (initial left right : World P A D)
    (c : Cell P A D) (hl : c ∉ lf.writes) (hr : c ∉ rf.writes) :
    (mergeWorld lf rf initial left right).state.balance c = initial.state.balance c := by
  simp [mergeWorld, hl, hr]

theorem worldEq_iff (left right : World P A D) :
    worldEq left right = true ↔ WorldEquivalent left right := by simp [worldEq, WorldEquivalent]

theorem observationsEqual_iff (left right : Result P A D) :
    observationsEqual left right = true ↔ ObservationallyEquivalent left right := by
  cases left <;> cases right <;>
    simp [observationsEqual, ObservationallyEquivalent, worldEq, WorldEquivalent, and_assoc]

theorem runParallel_refuses (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (reason : AdmissionFailure P A D)
    (h : admit cfg boundaries left right = .error reason) :
    runParallel cfg boundaries initial left right = .refused reason initial := by
  simp [runParallel, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.refl (world : World P A D) : WorldEquivalent world world :=
  ⟨fun _ ↦ rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.symm {left right : World P A D} (h : WorldEquivalent left right) :
    WorldEquivalent right left := ⟨fun c ↦ (h.1 c).symm, h.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.trans {first middle last : World P A D}
    (h : WorldEquivalent first middle) (g : WorldEquivalent middle last) :
    WorldEquivalent first last := ⟨fun c ↦ (h.1 c).trans (g.1 c), h.2.trans g.2⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.refl (result : Result P A D) :
    ObservationallyEquivalent result result := by
  cases result with
  | refused reason world => exact ⟨rfl, .refl world⟩
  | executed joined => exact ⟨.refl joined.world, rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.symm {left right : Result P A D}
    (h : ObservationallyEquivalent left right) : ObservationallyEquivalent right left := by
  cases left <;> cases right
  · exact ⟨h.1.symm, h.2.symm⟩
  · exact h.elim
  · exact h.elim
  · exact ⟨h.1.symm, h.2.1.symm, h.2.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.trans {first middle last : Result P A D}
    (h : ObservationallyEquivalent first middle) (g : ObservationallyEquivalent middle last) :
    ObservationallyEquivalent first last := by
  cases first <;> cases middle <;> cases last
  · exact ⟨h.1.trans g.1, h.2.trans g.2⟩
  · exact g.elim
  · exact h.elim
  · exact h.elim
  · exact h.elim
  · exact h.elim
  · exact g.elim
  · exact ⟨h.1.trans g.1, h.2.1.trans g.2.1, h.2.2.trans g.2.2⟩

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Execution.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Observation.lean ---
import DefiKernel.Composition.Sequence

/-! Branch observations retain every request, receipt, output, and refusal field.
Raw event worlds belong to execution evidence and are deliberately not equated across orders. -/
namespace DefiKernel.Parallel
open Typed Composition

-- These computational equality instances do not alter the existing execution definitions.
deriving instance DecidableEq for Composition.InputSource
deriving instance DecidableEq for Composition.Invocation
deriving instance DecidableEq for Composition.Step
deriving instance DecidableEq for Typed.Request
deriving instance DecidableEq for Typed.Evaluated
deriving instance DecidableEq for Composition.Receipt
deriving instance DecidableEq for Composition.OutputObservation
deriving instance DecidableEq for Composition.LocatedFailure

structure EventObservation (P A D : Type) where
  index : Nat
  step : Step P A D
  receipt : Receipt P A D
  outputs : List (OutputObservation A)
  deriving DecidableEq

structure BranchObservation (P A D : Type) where
  events : List (EventObservation P A D)
  outputs : List (OutputObservation A)
  nextIndex : Nat
  failure : Option (LocatedFailure P A D)
  deriving DecidableEq

def observeEvent {P A D : Type} (event : Event P A D) : EventObservation P A D :=
  ⟨event.index, event.step, event.result.receipt, event.result.outputs⟩

def observeBranch {P A D : Type} (cursor : Cursor P A D) : BranchObservation P A D :=
  ⟨cursor.events.map observeEvent, cursor.outputs, cursor.nextIndex, cursor.failure⟩

-- BEGIN PROOFS

/-- Equality of canonical branch observations includes the exact failure location and step. -/
theorem observeBranch_failure {P A D : Type} {left right : Cursor P A D}
    (h : observeBranch left = observeBranch right) : left.failure = right.failure :=
  congrArg BranchObservation.failure h

/-- Histories are compared as ordered, typed snapshots, not as an unqualified value multiset. -/
theorem observeBranch_outputs {P A D : Type} {left right : Cursor P A D}
    (h : observeBranch left = observeBranch right) : left.outputs = right.outputs :=
  congrArg BranchObservation.outputs h

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Observation.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Preservation.lean ---
import DefiKernel.Parallel.Commutation
import DefiKernel.Composition.Preservation

/-! Joined accounting, point-of-use authority in the fixed input store, and supported ledger
invariants. Nonnegativity is proof-carrying; initialization and local preservation are premises. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Net supply from both actual successful branch receipt sequences, including refused prefixes. -/
def Joined.supply (joined : Joined P A D) (domain : D) (asset : A) : ℚ :=
  traceSupply joined.left.events domain asset + traceSupply joined.right.events domain asset

-- BEGIN PROOFS

theorem mergeWorld_balance_sum (lf rf : Footprint P A D) (initial left right : World P A D)
    (hd : ∀ c ∈ lf.writes, c ∉ rf.writes)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (c : Cell P A D) :
    (mergeWorld lf rf initial left right).state.balance c =
      left.state.balance c + right.state.balance c - initial.state.balance c := by
  by_cases hcl : c ∈ lf.writes
  · simp [mergeWorld, hcl, hr c (hd c hcl)]
  · by_cases hcr : c ∈ rf.writes
    · simp [mergeWorld, hcl, hcr, hl c hcl]
    · simp [mergeWorld, hcl, hcr, hl c hcl, hr c hcr]

theorem mergeWorld_accounting (lf rf : Footprint P A D) (initial left right : World P A D)
    (hd : ∀ c ∈ lf.writes, c ∉ rf.writes)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (d : D) (a : A) :
    total (mergeWorld lf rf initial left right).state d a =
      total left.state d a + total right.state d a - total initial.state d a := by
  simp only [total, mergeWorld_balance_sum lf rf initial left right hd hl hr,
    Finset.sum_sub_distrib, Finset.sum_add_distrib]

theorem runBranch_accounting (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (d : D) (a : A) :
    total (runBranch cfg boundary initial branch).world.state d a =
      total initial.state d a + traceSupply (runBranch cfg boundary initial branch).events d a :=
  run_accounting cfg boundary initial (branch.map Step.invoke) d a

/-- Actual successful receipt supplies from both independent runs determine joined accounting. -/
theorem runParallel_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf)) (d : D) (a : A) :
    total (mergeWorld lf rf initial
      (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state d a =
      total initial.state d a +
        traceSupply (runBranch cfg (boundaries .left) initial left).events d a +
        traceSupply (runBranch cfg (boundaries .right) initial right).events d a := by
  obtain ⟨hv, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf hadmit
  rw [mergeWorld_accounting lf rf initial _ _ hc.1
    (runBranch_frame cfg (boundaries .left) initial left lf hl).1
    (runBranch_frame cfg (boundaries .right) initial right rf hr).1]
  rw [runBranch_accounting, runBranch_accounting]
  linarith

theorem runBranch_events_invoke (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ∃ inv ∈ branch, event.step = .invoke inv := by
  obtain ⟨accepted, remaining, hs, he⟩ :=
    run_order cfg boundary initial (branch.map Step.invoke)
  intro event hm
  have hstep : event.step ∈ accepted := he ▸ List.mem_map.mpr ⟨event, hm, rfl⟩
  have hall : event.step ∈ branch.map Step.invoke := by
    rw [hs]
    exact List.mem_append_left _ hstep
  obtain ⟨inv, hi, hh⟩ := List.mem_map.mp hall
  exact ⟨inv, hi, hh.symm⟩

theorem trace_invoke_stores {cfg : Config P A D} {boundary : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundary initial events final history index)
    (hi : ∀ event ∈ events, ∃ inv, event.step = .invoke inv) :
    final.capabilities = initial.capabilities ∧
      ∀ event ∈ events, event.before.capabilities = initial.capabilities ∧
        event.result.world.capabilities = initial.capabilities := by
  induction h with
  | nil => exact ⟨rfl, by simp⟩
  | @snoc events pre history index previous step result sound ih =>
    obtain ⟨hp, he⟩ := ih (by
      intro event hm
      exact hi event (List.mem_append_left _ hm))
    obtain ⟨inv, hstep⟩ := hi ⟨index, step, pre, result⟩ (by simp)
    change step = .invoke inv at hstep
    have hcap : result.world.capabilities = pre.capabilities := by
      rw [hstep] at sound
      exact sound.invoke_preserves_capabilities
    refine ⟨hcap.trans hp, ?_⟩
    intro event hm
    rcases List.mem_append.mp hm with hm | hm
    · exact he event hm
    · have eq := List.mem_singleton.mp hm
      subst event
      exact ⟨hp, hcap.trans hp⟩

/-- Every successful invocation uses authority from the initial fixed store, including prefixes
whose later invocation refuses. The actual local boundary remains attached to each event. -/
theorem runBranch_authority (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ReceiptAuthorized initial (boundary event.index) event.result.receipt := by
  have ht := run_trace_sound cfg boundary initial (branch.map Step.invoke)
  have hi : ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ∃ inv, event.step = .invoke inv := by
    intro event hm
    obtain ⟨inv, _, he⟩ := runBranch_events_invoke cfg boundary initial branch event hm
    exact ⟨inv, he⟩
  have hs := trace_invoke_stores ht hi
  intro event hm
  have ha := ht.authority event hm
  have hc := (hs.2 event hm).1
  cases hr : event.result.receipt <;> simp only [hr, ReceiptAuthorized] at ha ⊢
  simpa only [hc] using ha

theorem runBranch_prefix_nonnegative (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events, ∀ c,
      0 ≤ event.before.state.balance c ∧ 0 ≤ event.result.world.state.balance c :=
  run_prefix_nonnegative cfg boundary initial (branch.map Step.invoke)

/-- The join frames every predicate whose explicit support avoids both write regions. -/
theorem mergeWorld_supported_frame (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (predicate : State P A D → Prop) (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ∧ c ∉ rf.writes) :
    predicate initial.state ↔ predicate (mergeWorld lf rf initial left right).state := by
  apply supported_frame support
  intro c hc
  exact (mergeWorld_outside lf rf initial left right c
    (untouched c hc).1 (untouched c hc).2).symm

theorem mergeWorld_agrees_left (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (locality : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (peer : ∀ c ∈ region, c ∉ rf.writes) :
    AgreeOn region left.state (mergeWorld lf rf initial left right).state := by
  intro c hc
  by_cases hw : c ∈ lf.writes
  · simp [mergeWorld, hw]
  · simp [mergeWorld, hw, peer c hc, locality c hw]

theorem mergeWorld_agrees_right (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (locality : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (peer : ∀ c ∈ region, c ∉ lf.writes) :
    AgreeOn region right.state (mergeWorld lf rf initial left right).state := by
  intro c hc
  by_cases hw : c ∈ rf.writes
  · simp [mergeWorld, hw, peer c hc]
  · simp [mergeWorld, hw, peer c hc, locality c hw]

theorem mergeWorld_two_invariants (lf rf : Footprint P A D)
    (initial left right : World P A D) (ls rs : Set (Cell P A D))
    (lp rp : State P A D → Prop) (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp left.state) (ri : rp right.state) :
    lp (mergeWorld lf rf initial left right).state ∧
      rp (mergeWorld lf rf initial left right).state :=
  ⟨(supported_frame lSupport (mergeWorld_agrees_left lf rf initial left right ls hl lpeer)).mp li,
    (supported_frame rSupport (mergeWorld_agrees_right lf rf initial left right rs hr rpeer)).mp ri⟩

/-- Non-circular initialized induction obligations for a branch's own ledger predicate. -/
def LocalPreservation (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (predicate : State P A D → Prop) : Prop :=
  ∀ n outputs step pre result, StepSound cfg (boundary n) n outputs step pre result →
    predicate pre.state → predicate result.world.state

theorem runBranch_invariant (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (predicate : State P A D → Prop)
    (initialized : predicate initial.state) (preserves : LocalPreservation cfg boundary predicate) :
    predicate (runBranch cfg boundary initial branch).world.state :=
  (run_trace_sound cfg boundary initial (branch.map Step.invoke)).invariant
    (fun w ↦ predicate w.state) initialized preserves

theorem evaluated_supplies_empty (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (hn : template.supplyDeltas = []) (he : template.evaluate ctx = .ok e) :
    e.supplies = [] := by
  unfold Template.evaluate at he
  rw [hn] at he
  simp only [List.mapM_nil, bind, Except.bind, pure, Except.pure] at he
  repeat' first | split at he | contradiction
  cases he
  rfl

theorem extractReceipt_supplies_empty (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D) (e : Evaluated P A D)
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (he : extractReceipt cfg boundary request pre = .ok e) : e.supplies = [] := by
  unfold extractReceipt at he
  cases hs : cfg.registry request.operation with
  | none => simp [hs, bind, Except.bind] at he
  | some template =>
    simp only [hs, bind, Except.bind] at he
    cases ha : Args.check template.signature request.arguments with
    | error reason => simp [ha, Except.mapError] at he
    | ok args =>
      simp only [ha, Except.mapError, bind, Except.bind] at he
      cases hv : template.evaluate
          ⟨pre.state, boundary.env, boundary.ctx.principal, request.parties, args, boundary.now⟩
          <;> simp only [hv, Except.mapError] at he
      · contradiction
      · cases he
        exact evaluated_supplies_empty template _ _ (hn _ _ hs) hv

theorem step_no_supply {cfg : Config P A D} {boundary : Boundary P A D}
    {n : Nat} {outputs : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (hs : StepSound cfg boundary n outputs step pre result) (d : D) (a : A) :
    result.receipt.supply d a = 0 := by
  cases hs with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have he := extractReceipt_supplies_empty cfg boundary request pre e hn extracted
    simp [Receipt.supply, Evaluated.supply, he]
  | issue => rfl
  | revoke => rfl

theorem local_total_preservation (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (d : D) (a : A) (amount : ℚ) :
    LocalPreservation cfg boundary (fun s ↦ total s d a = amount) := by
  intro n outputs step pre result hs hi
  rw [hs.accounting d a, step_no_supply hn hs d a, add_zero]
  exact hi

theorem supports_total (d : D) (a : A) (predicate : ℚ → Prop) :
    Supports {c : Cell P A D | c.1 = d ∧ c.2.2 = a}
      (fun s ↦ predicate (total s d a)) := by
  intro pre post h
  have ht : total pre d a = total post d a := by
    apply Finset.sum_congr rfl
    intro party hp
    exact h (d, party, a) ⟨rfl, rfl⟩
  change predicate (total pre d a) ↔ predicate (total post d a)
  rw [ht]

/-- Both branch invariants are initialized and preserved individually before supported join. -/
theorem runParallel_two_invariants (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (ls rs : Set (Cell P A D)) (lp rp : State P A D → Prop)
    (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp initial.state) (ri : rp initial.state)
    (lPreserves : LocalPreservation cfg (boundaries .left) lp)
    (rPreserves : LocalPreservation cfg (boundaries .right) rp) :
    lp (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state ∧
    rp (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state := by
  obtain ⟨_, hl, hr, _⟩ := admit_ok cfg boundaries left right lf rf hadmit
  exact mergeWorld_two_invariants lf rf initial _ _ ls rs lp rp lSupport rSupport
    (runBranch_frame cfg (boundaries .left) initial left lf hl).1
    (runBranch_frame cfg (boundaries .right) initial right rf hr).1 lpeer rpeer
    (runBranch_invariant cfg (boundaries .left) initial left lp li lPreserves)
    (runBranch_invariant cfg (boundaries .right) initial right rp ri rPreserves)

/-- Accounting binds the public executed result to both of its actual receipt sequences. -/
theorem runParallel_executed_accounting (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) (d : D) (a : A) :
    total joined.world.state d a = total initial.state d a + joined.supply d a := by
  cases hadmit : admit cfg boundaries left right with
  | error reason => simp [runParallel, hadmit] at hx
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    simp only [runParallel, hadmit, Result.executed.injEq] at hx
    subst joined
    simpa only [Joined.supply, add_assoc] using
      runParallel_accounting cfg boundaries initial left right lf rf hadmit d a

theorem runParallel_executed_authority (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ event ∈ joined.left.events,
      ReceiptAuthorized initial (boundaries .left event.index) event.result.receipt) ∧
    (∀ event ∈ joined.right.events,
      ReceiptAuthorized initial (boundaries .right event.index) event.result.receipt) := by
  cases hadmit : admit cfg boundaries left right with
  | error reason => simp [runParallel, hadmit] at hx
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    simp only [runParallel, hadmit, Result.executed.injEq] at hx
    subst joined
    exact ⟨runBranch_authority cfg (boundaries .left) initial left,
      runBranch_authority cfg (boundaries .right) initial right⟩

theorem runParallel_executed_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ c, c ∉ lf.writes → c ∉ rf.writes →
      joined.world.state.balance c = initial.state.balance c) ∧
      joined.world.capabilities = initial.capabilities := by
  simp only [runParallel, hadmit, Result.executed.injEq] at hx
  subst joined
  exact ⟨mergeWorld_outside lf rf initial _ _, rfl⟩

theorem runParallel_executed_nonnegative (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ c, 0 ≤ joined.world.state.balance c) ∧
    (∀ event ∈ joined.left.events ++ joined.right.events, ∀ c,
      0 ≤ event.before.state.balance c ∧ 0 ≤ event.result.world.state.balance c) := by
  exact ⟨joined.world.state.nonneg,
    fun event _ c ↦ ⟨event.before.state.nonneg c, event.result.world.state.nonneg c⟩⟩

theorem runParallel_executed_supported_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ∧ c ∉ rf.writes) :
    predicate initial.state ↔ predicate joined.world.state := by
  apply supported_frame support
  intro c hc
  exact ((runParallel_executed_frame cfg boundaries initial left right lf rf joined hadmit hx).1
    c (untouched c hc).1 (untouched c hc).2).symm

theorem runParallel_executed_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined)
    (ls rs : Set (Cell P A D)) (lp rp : State P A D → Prop)
    (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp initial.state) (ri : rp initial.state)
    (lPreserves : LocalPreservation cfg (boundaries .left) lp)
    (rPreserves : LocalPreservation cfg (boundaries .right) rp) :
    lp joined.world.state ∧ rp joined.world.state := by
  simp only [runParallel, hadmit, Result.executed.injEq] at hx
  subst joined
  exact runParallel_two_invariants cfg boundaries initial left right lf rf hadmit
    ls rs lp rp lSupport rSupport lpeer rpeer li ri lPreserves rPreserves

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Preservation.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Dependency/Adapter.lean ---
import DefiKernel.Parallel.Dependency
import DefiKernel.Parallel.Compatibility

/-! State dependence for the existing composition adapter, with same-prestate receipts and
selected post-state snapshots. Boundaries and local histories are identical inputs. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem prepareInvocation_shape (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (iface : OperationInterface P A D) (request : Request P A D)
    (h : prepareInvocation cfg boundary index history inv = .ok (iface, request)) :
    request.operation = inv.operation ∧ request.parties = inv.parties ∧
      ∃ component, lookupOperation cfg.catalog inv.component inv.operation =
        some (component, iface) := by
  unfold prepareInvocation at h
  simp only [bind, Except.bind, Except.mapError, pure, Except.pure] at h
  split at h
  · contradiction
  rename_i pair hl
  rcases pair with ⟨component, selected⟩
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  cases h
  exact ⟨rfl, rfl, component, hl⟩

theorem analyzed_dependencies (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (template : Template P A D) (hs : cfg.registry inv.operation = some template) :
    (∀ ref ∈ template.requiredStateReads, ∀ c,
      ref.2.resolve boundary.ctx.principal inv.parties = .ok c → c ∈ fp.reads) ∧
    TargetsWithin template boundary.ctx.principal inv.parties {c | c ∈ fp.writes} ∧
    (∀ c ∈ fp.writes, c ∈ fp.reads) := by
  obtain ⟨component, iface, selected, reads, writes, hl, ht, hr, hw, hc, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp hf
  rw [hs] at ht
  cases ht
  refine ⟨?_, ?_, ?_⟩
  · intro ref hm c hres
    obtain ⟨cell, hm', hres'⟩ := resolveRefs_member _ _ _ _ hr ref (by simp [hm])
    rw [hres] at hres'
    cases hres'
    simp [hm']
  · intro d hd c hres
    obtain ⟨cell, hm', hres'⟩ := resolveRefs_member _ _ _ _ hw ⟨d.asset, d.target⟩
      (List.mem_append_right _ (List.mem_map.mpr ⟨d, hd, rfl⟩))
    rw [hres] at hres'
    cases hres'
    exact hm'
  · intros
    simp_all

theorem analyzed_outputs (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (component : Component P A D) (iface : OperationInterface P A D)
    (hl : lookupOperation cfg.catalog inv.component inv.operation = some (component, iface)) :
    ∀ output ∈ iface.outputs, output.cell ∈ fp.reads := by
  obtain ⟨selected, si, template, reads, writes, hs, _, _, _, _, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp hf
  rw [hl] at hs
  cases hs
  intro output ho
  simp only [List.mem_append, List.mem_map]
  exact Or.inr ⟨output, ho, rfl⟩

theorem snapshots_congr (index : Nat) (component : ComponentId)
    (iface : OperationInterface P A D) (left right : State P A D)
    (h : ∀ output ∈ iface.outputs, left.balance output.cell = right.balance output.cell) :
    snapshots index component iface left = snapshots index component iface right := by
  unfold snapshots
  apply List.map_congr_left
  intro output ho
  simp only [h output ho]

theorem extractReceipt_congr (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (left right : World P A D)
    (hr : ∀ template, cfg.registry request.operation = some template →
      ResolvedReadsAgree template boundary.ctx.principal request.parties left.state right.state) :
    extractReceipt cfg boundary request left = extractReceipt cfg boundary request right := by
  unfold extractReceipt
  cases hs : cfg.registry request.operation with
  | none => rfl
  | some template =>
    simp only [bind, Except.bind]
    cases ha : Args.check template.signature request.arguments with
    | error reason => rfl
    | ok args =>
      simp only [Except.mapError, bind, Except.bind]
      rw [evaluate_congr template left.state right.state boundary.env boundary.ctx.principal
        request.parties args boundary.now (hr template hs)]

def StepAgrees (region : Set (Cell P A D)) :
    Except Failure (StepResult P A D) → Except Failure (StepResult P A D) → Prop
  | .error a, .error b => a = b
  | .ok a, .ok b => AgreeOn region a.world.state b.world.state ∧
      a.world.capabilities = b.world.capabilities ∧ a.receipt = b.receipt ∧ a.outputs = b.outputs
  | _, _ => False

theorem executeStep_congr (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (left right : World P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hcap : left.capabilities = right.capabilities) :
    StepAgrees region (executeStep cfg boundary index history (.invoke inv) left)
      (executeStep cfg boundary index history (.invoke inv) right) := by
  unfold executeStep
  by_cases hv : validateCatalog cfg.registry cfg.catalog = true
  · simp only [hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte, bind, Except.bind]
    cases hp : prepareInvocation cfg boundary index history inv with
    | error reason => rfl
    | ok pair =>
      rcases pair with ⟨iface, request⟩
      simp only [bind, Except.bind]
      obtain ⟨hop, hparties, component, hlookup⟩ := prepareInvocation_shape _ _ _ _ _ _ _ hp
      have hr : ∀ template, cfg.registry request.operation = some template →
          ResolvedReadsAgree template boundary.ctx.principal request.parties
            left.state right.state := by
        intro template hs ref href c hc
        rw [hop] at hs
        rw [hparties] at hc
        exact ha c (hin c ((analyzed_dependencies _ _ _ _ hf template hs).1 ref href c hc))
      have ht : ∀ template, cfg.registry request.operation = some template →
          TargetsWithin template boundary.ctx.principal request.parties region := by
        intro template hs d hd c hc
        rw [hop] at hs
        rw [hparties] at hc
        have dep := analyzed_dependencies _ _ _ _ hf template hs
        exact hin c (dep.2.2 c (dep.2.1 d hd c hc))
      have he := extractReceipt_congr cfg boundary request left right hr
      have hx := execute_congr cfg.registry left.capabilities boundary.ctx boundary.env boundary.now
        request left.state right.state region ha hr ht
      rw [← hcap]
      cases hleft : Typed.execute cfg.registry left.capabilities boundary.ctx boundary.env
          boundary.now request left.state <;>
        cases hright : Typed.execute cfg.registry left.capabilities boundary.ctx boundary.env
          boundary.now request right.state <;>
        simp only [hleft, hright, ExecutionAgrees] at hx
      · cases hx
        rfl
      · rename_i post other
        simp only [Except.mapError, bind, Except.bind]
        rw [← he]
        cases hrp : extractReceipt cfg boundary request left with
        | error reason => rfl
        | ok e =>
          exact ⟨hx.1, hx.2, rfl, snapshots_congr index inv.component iface _ _
            (fun output ho ↦ hx.1 output.cell
              (hin _ (analyzed_outputs _ _ _ _ hf _ _ hlookup output ho)))⟩
  · have hfalse : validateCatalog cfg.registry cfg.catalog = false := Bool.eq_false_iff.mpr hv
    simp only [hfalse, Bool.not_false, ↓reduceIte, bind, Except.bind]
    rfl

/-- Successful adapter execution changes only the analyzed write region. -/
theorem executeStep_target_frame (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre : World P A D) (result : StepResult P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hx : executeStep cfg boundary index history (.invoke inv) pre = .ok result) :
    (∀ c, c ∉ fp.writes → result.world.state.balance c = pre.state.balance c) ∧
      result.world.capabilities = pre.capabilities := by
  have sound := executeStep_sound cfg boundary index history (.invoke inv) pre result hx
  cases sound with
  | invoke inv pre post iface request e hp he hex happly =>
    obtain ⟨hop, hparties, _⟩ := prepareInvocation_shape _ _ _ _ _ _ _ hp
    refine ⟨?_, execute_preserves_capabilities _ _ _ _ _ _ _ _ he⟩
    apply execute_target_frame cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state post {c | c ∈ fp.writes} _ he
    intro template hs
    rw [hop] at hs
    rw [hparties]
    exact (analyzed_dependencies _ _ _ _ hf template hs).2.1

theorem executeStep_refusal_iff (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (left right : World P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hcap : left.capabilities = right.capabilities) (reason : Failure) :
    executeStep cfg boundary index history (.invoke inv) left = .error reason ↔
      executeStep cfg boundary index history (.invoke inv) right = .error reason := by
  have h := executeStep_congr cfg boundary index history inv left right fp region hf hin ha hcap
  cases hl : executeStep cfg boundary index history (.invoke inv) left <;>
    cases hr : executeStep cfg boundary index history (.invoke inv) right <;>
    simp_all [StepAgrees]

end DefiKernel.Parallel

--- END FILE lean/DefiKernel/Parallel/Dependency/Adapter.lean ---

--- BEGIN FILE scripts/check_parallel_mutations.py ---
#!/usr/bin/env python3
"""Replay the actual parallel Lean implementation under explicit source mutations.

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
    parser.add_argument('--repo', type=Path, required=True)
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
    require('DefiKernel.Parallel.Audit' in modules, 'missing Parallel audit root')
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
    # Discover and inline every local import, including split Parallel modules
    # absent from the mutation-site inventory; never load local cached oleans.
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
                    capture(imported)
        visiting.remove(module)
        ordered.append(module)
    for module in modules:
        require(isinstance(module, str) and re.fullmatch(
            r'DefiKernel\.Parallel(?:\.[A-Za-z][A-Za-z0-9]*)+', module),
            f'invalid scoped module: {module}')
        capture(module)
    for relative in ('lean/lean-toolchain', 'lean/lake-manifest.json', 'lean/lakefile.toml'):
        blobs[relative] = read(repo / relative)
    sources = {name: sha(raw) for name, raw in blobs.items()}
    script_sha256 = sha(read(Path(__file__)))
    imports, prefixes = [], {}
    for module in ordered:
        source = blobs['lean/' + module.replace('.', '/') + '.lean'].decode()
        marker = '\n-- BEGIN PROOFS\n'
        require(source.count(marker) <= 1, f'{module}: duplicate proof boundary')
        if marker in source and module.startswith('DefiKernel.Parallel.'):
            source, suffix = source.split(marker)
            closure = re.search(r'\n(end DefiKernel\.Parallel(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$', suffix)
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
    manifest = {'sources': sources, 'script_sha256': script_sha256,
                'spec_sha256': sha(spec_raw), 'git_head': head.strip(), 'input_status': dirty,
                'lean_version': version.strip(), 'lean_executable_sha256': executable_sha,
                'scope': 'Fresh local dependency source closure; Parallel proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.',
                'projection_order': ordered, 'module_roots': modules,
                'audit_root': 'DefiKernel.Parallel.Audit', 'python_version': sys.version}
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
        # Lean's unused-variable diagnostics contain standalone Hint:/Note:
        # continuation lines. These exact diagnostic prefixes are not observations.
        diagnostic_prefixes = ('Hint: The binding can be removed (if unused) or named ',
                               'Note: This linter can be disabled with ')
        candidates = [line for line in log.splitlines()
                      if re.match(r'^[A-Za-z0-9_.-]+:', line)
                      and not line.startswith(diagnostic_prefixes)]
        require(len(candidates) == len(observations), f'{label}: malformed observation')
        checks = dict(observations)
        require(checks and len(checks) == len(observations), f'{label}: empty/duplicate observations')
        require(set(positives) <= checks.keys(), f'{label}: missing positive controls')
        false = sorted(name for name, value in checks.items() if value == 'false')
        errors = [line for line in log.splitlines()
                  if re.search(r': error(?:\([^)]*\))?:', line)]
        if label == 'control':
            expected_error = f'error: Parallel runtime comparisons failed: {len(false)}'
            require(not errors or (false and len(errors) == 1 and errors[0].endswith(expected_error)),
                    'control compilation/execution failed')
            check(code == 0 and not false, 'unchanged control has failing comparisons')
            for mutation in mutations:
                require(set(mutation['required_false']) <= checks.keys(),
                        f'{mutation["name"]}: missing required observation in control')
        else:
            require(checks.keys() == results['control']['checks'].keys(), f'{label}: partial execution')
            check(code != 0 or false, f'{label}: all comparisons still pass under mutation')
            expected_error = f'error: Parallel runtime comparisons failed: {len(false)}'
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
    require(sha(read(args.spec)) == sha(spec_raw), 'specification changed during replay')
    require(sha(read(Path(__file__))) == script_sha256, 'runner changed during replay')
    manifest['input_sources_unchanged'] = True
    manifest['specification_unchanged'] = True
    manifest['runner_unchanged'] = True
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

--- END FILE scripts/check_parallel_mutations.py ---

--- BEGIN FILE scripts/test_parallel_mutation_runner.py ---
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


INPUT_MODULE = 'DefiKernel.Parallel.RunnerInput'
AUDIT_MODULE = 'DefiKernel.Parallel.Audit'
DEPENDENCY = '''import Mathlib.Data.Nat.Basic
namespace DefiKernel.Typed
def runnerDependency : Nat := 4
-- BEGIN PROOFS
theorem runnerDependency_value : runnerDependency = 4 := rfl
end DefiKernel.Typed
'''
INPUT = '''import DefiKernel.Typed.RunnerDependency

namespace DefiKernel.Parallel

example : DefiKernel.Typed.runnerDependency = 4 := DefiKernel.Typed.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Parallel
'''
AUDIT = '''import DefiKernel.Parallel.RunnerInput

namespace DefiKernel.Parallel

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := CHECKS
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Parallel runtime comparisons failed: {failures}"

end DefiKernel.Parallel
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
        {'name': 'unused-variable-warning', 'exit': 0,
         'spec': specification(mutation(replacement='true')),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'uppercase-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "Runner_bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'unknown-mutant-observation', 'exit': 3,
         'extra_audit': '  if runnerAllows 5 then\n'
                        '    liftIO <| IO.println "runner_unknown: true"\n',
         'message': 'probe: partial execution'},
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
        {'name': 'discovered-parallel-dependency', 'exit': 0, 'extra_dependency': True,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'fresh-dependency-source-failure', 'exit': 3, 'changed_dependency': True,
         'message': 'control compilation/execution failed'},
        {'name': 'missing-audit-root', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE]},
         'message': 'missing Parallel audit root'},
        {'name': 'foreign-module-root', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE, AUDIT_MODULE,
                                              'DefiKernel.Composition.RunnerInput']},
         'message': 'invalid scoped module'},
        {'name': 'mutation-module-outside-inventory', 'exit': 3,
         'spec': specification({**mutation(), 'module': 'DefiKernel.Parallel.Absent'}),
         'message': 'mutation module outside inventory'},
        {'name': 'unchanged-control-failed', 'exit': 1,
         'checks': '[("runner_positive", true), ("runner_sensitivity", false)]',
         'message': 'unchanged control has failing comparisons'},
        {'name': 'empty-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': []}, 'message': 'empty mutation inventory'},
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--runner', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    runner = (args.runner or repo / 'scripts/check_parallel_mutations.py').resolve()
    require(not out.is_relative_to(repo), 'harness output must be outside source repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'harness output already exists')
    require(runner.is_file(), 'runner source unavailable')
    require((repo / 'lean/.lake/packages').is_dir(), 'installed dependency packages unavailable')
    out.mkdir(parents=True)
    before = sha(runner.read_bytes())
    harness_before = sha(Path(__file__).read_bytes())
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
    typed = lean / 'DefiKernel/Parallel'
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
        dependency.write_text(DEPENDENCY)
        (lean / 'lake-manifest.json').write_bytes(manifest)
        setup_records = []
        (typed / 'RunnerInput.lean').write_text(INPUT)
        if case.get('extra_dependency'):
            extra = typed / 'SplitComputation.lean'
            extra.write_text('import DefiKernel.Typed.RunnerDependency\n'
                             'namespace DefiKernel.Parallel\n'
                             'def splitLimit : Nat := 4\n'
                             '-- BEGIN PROOFS\n'
                             'theorem splitLimit_value : splitLimit = 4 := rfl\n'
                             'end DefiKernel.Parallel\n')
            (typed / 'RunnerInput.lean').write_text(INPUT.replace(
                'import DefiKernel.Typed.RunnerDependency',
                'import DefiKernel.Parallel.SplitComputation').replace(
                    'n ≤ 4', 'n ≤ 4 + (splitLimit - 4)'))
        if case.get('changed_dependency'):
            # Compile the old source, then change only the .lean file. A fresh
            # source projection must see 5 and fail the importing = 4 example.
            olean = lean / '.lake/build/lib/lean/DefiKernel/Typed/RunnerDependency.olean'
            olean.parent.mkdir(parents=True, exist_ok=True)
            setup_command = ['lake', 'env', 'lean', '-o', str(olean), str(dependency)]
            setup = subprocess.run(setup_command, cwd=lean, text=True, capture_output=True, timeout=240)
            setup_log = setup.stdout + setup.stderr
            (out / 'stale-dependency-setup.log').write_text(setup_log)
            require(setup.returncode == 0 and olean.is_file(), 'stale dependency control setup failed')
            setup_records.append({'command': setup_command, 'cwd': str(lean),
                                  'exit': setup.returncode, 'log_sha256': sha(setup_log.encode()),
                                  'source_sha256': sha(dependency.read_bytes()),
                                  'olean_sha256': sha(olean.read_bytes())})
            dependency.write_text(DEPENDENCY.replace(':= 4', ':= 5').replace('= 4', '= 5'))
        (typed / 'Audit.lean').write_text(AUDIT.replace('CHECKS', case.get('checks', CHECKS)).replace(
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
        if case['name'] in ('live-discriminating-mutant', 'dotted-comparisons', 'hyphenated-dotted-comparisons', 'discovered-parallel-dependency', 'unused-variable-warning'):
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
        if case['name'] == 'unused-variable-warning':
            warning_log = result_path / 'probe.log'
            warning = warning_log.read_text() if warning_log.exists() else ''
            matched = matched and 'warning: Variable name `n` is not explicitly referenced.' in warning
            matched = matched and 'Hint: The binding can be removed' in warning
            matched = matched and 'Note: This linter can be disabled with ' in warning
        source_manifest = result_path / 'source-manifest.json'
        if case.get('extra_dependency'):
            captured = json.loads(source_manifest.read_text()) if source_manifest.exists() else {}
            matched = matched and 'DefiKernel.Parallel.SplitComputation' in captured.get('projection_order', [])
            matched = matched and captured.get('sources', {}).get(
                'lean/DefiKernel/Parallel/SplitComputation.lean') == sha(extra.read_bytes())
            matched = matched and captured.get('input_sources_unchanged') is True
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
                  'spec_sha256': sha(spec_path.read_bytes()), 'setup_records': setup_records,
                  'lean_observations': observations, 'runner_records': runtime.get('runs', [])}
        records.append(record)
        print(f'{case["name"]}: expected={case["exit"]}; actual={proc.returncode}; '
              f'{"PASS" if matched else "FAIL"}', flush=True)
        (out / 'cases.json').write_text(json.dumps(records, indent=2) + '\n')
    require(records, 'zero controls executed')
    require(before == sha(runner.read_bytes()), 'runner changed during controls; rerun final bytes')
    require(harness_before == sha(Path(__file__).read_bytes()), 'harness changed during controls')
    summary = {'schema_version': 1, 'kind': 'executed-cli-runner-controls',
               'started_utc': started, 'finished_utc': datetime.now(timezone.utc).isoformat(),
               'source_repo': str(repo), 'git_head': git_head,
               'runner_source': str(runner), 'runner_sha256': before,
               'harness_source': str(Path(__file__).resolve()),
               'harness_sha256': harness_before,
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

--- END FILE scripts/test_parallel_mutation_runner.py ---

--- BEGIN FILE review/semantic-kernel/sprint6/mutation-spec.json ---
{
  "schema_version": 1,
  "modules": [
    "DefiKernel.Parallel.Compatibility",
    "DefiKernel.Parallel.Observation",
    "DefiKernel.Parallel.Execution",
    "DefiKernel.Parallel.Preservation",
    "DefiKernel.Parallel.Audit"
  ],
  "mutations": [
    {
      "name": "bypass-write-write-composite",
      "module": "DefiKernel.Parallel.Compatibility",
      "needle": "  match firstOverlap left.writes right.writes with\n  | some c => .error (.conflict .writeWrite c)\n  | none => match firstOverlap left.writes right.reads with\n    | some c => .error (.conflict .leftWriteRightRead c)\n    | none => match firstOverlap right.writes left.reads with\n      | some c => .error (.conflict .rightWriteLeftRead c)\n      | none => .ok ⟨⟩",
      "replacement": "  .ok ⟨⟩",
      "required_false": [
        "parallel.compat.write-write-witness"
      ]
    },
    {
      "name": "omit-expression-reads-composite",
      "module": "DefiKernel.Parallel.Compatibility",
      "needle": "(template.requiredStateReads ++ template.stateReads)",
      "replacement": "([] : List (PackedCellRef P A D))",
      "required_false": [
        "parallel.compat.hidden-inactive-guard",
        "parallel.compat.hidden-delta",
        "parallel.compat.hidden-supply"
      ]
    },
    {
      "name": "omit-output-dependency",
      "module": "DefiKernel.Parallel.Compatibility",
      "needle": "reads ++ writes ++ iface.outputs.map OutputPort.cell",
      "replacement": "reads ++ writes",
      "required_false": [
        "parallel.compat.output-dependency"
      ]
    },
    {
      "name": "omit-zero-delta-target",
      "module": "DefiKernel.Parallel.Compatibility",
      "needle": "(template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))",
      "replacement": "template.writes",
      "required_false": [
        "parallel.compat.zero-target",
        "parallel.compat.zero-target-exact"
      ]
    },
    {
      "name": "omit-reverse-conflict",
      "module": "DefiKernel.Parallel.Compatibility",
      "needle": "firstOverlap right.writes left.reads",
      "replacement": "firstOverlap ([] : List (Cell P A D)) left.reads",
      "required_false": [
        "parallel.compat.reverse-read"
      ]
    },
    {
      "name": "cancel-peer-after-refusal",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .right) initial right",
      "replacement": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .right) initial (if l.failure.isSome then [] else right)",
      "required_false": [
        "parallel.fixture.refusal.peer-runs"
      ]
    },
    {
      "name": "rollback-refused-prefix-at-join",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "mergeWorld leftFootprint rightFootprint initial l.world r.world",
      "replacement": "mergeWorld leftFootprint rightFootprint initial (if l.failure.isSome then initial else l.world) r.world",
      "required_false": [
        "parallel.fixture.refusal.prefix-kept"
      ]
    },
    {
      "name": "replace-merge-with-left-world",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "  ⟨⟨fun c ↦ if c ∈ leftFootprint.writes then left.state.balance c\n      else if c ∈ rightFootprint.writes then right.state.balance c\n      else initial.state.balance c,\n    fun c ↦ by\n      split\n      · exact left.state.nonneg c\n      · split\n        · exact right.state.nonneg c\n        · exact initial.state.nonneg c⟩,\n    initial.capabilities⟩",
      "replacement": "  left",
      "required_false": [
        "parallel.fixture.basic.complete"
      ]
    },
    {
      "name": "double-initial-balances",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "  ⟨⟨fun c ↦ if c ∈ leftFootprint.writes then left.state.balance c\n      else if c ∈ rightFootprint.writes then right.state.balance c\n      else initial.state.balance c,\n    fun c ↦ by\n      split\n      · exact left.state.nonneg c\n      · split\n        · exact right.state.nonneg c\n        · exact initial.state.nonneg c⟩,\n    initial.capabilities⟩",
      "replacement": "  ⟨⟨fun c ↦ left.state.balance c + right.state.balance c,\n    fun c ↦ add_nonneg (left.state.nonneg c) (right.state.nonneg c)⟩,\n    initial.capabilities⟩",
      "required_false": [
        "parallel.fixture.basic.complete"
      ]
    },
    {
      "name": "leak-peer-output-history",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .right) initial right",
      "replacement": "    let r := runBranch cfg (boundaries .right) initial right\n    let l := continueRun cfg (boundaries .left)\n      { (startCursor cfg initial) with outputs := r.outputs } (left.map Step.invoke)",
      "required_false": [
        "parallel.fixture.routing.peer-only"
      ]
    },
    {
      "name": "reuse-left-trusted-boundary",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .right) initial right",
      "replacement": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .left) initial right",
      "required_false": [
        "parallel.fixture.boundary.local-identity"
      ]
    },
    {
      "name": "drop-peer-supply-receipts",
      "module": "DefiKernel.Parallel.Preservation",
      "needle": "traceSupply joined.left.events domain asset + traceSupply joined.right.events domain asset",
      "replacement": "traceSupply joined.left.events domain asset",
      "required_false": [
        "parallel.fixture.supply.both-receipts"
      ]
    },
    {
      "name": "reuse-live-capability-store",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "    let l := runBranch cfg (boundaries .left) initial left\n    let r := runBranch cfg (boundaries .right) initial right",
      "replacement": "    let l := runBranch cfg (boundaries .left) initial left\n    let stale : World P A D := { initial with capabilities :=\n      ⟨initial.capabilities.entries.map (fun cap ↦ { cap with live := true })⟩ }\n    let r := runBranch cfg (boundaries .right) stale right",
      "required_false": [
        "parallel.fixture.capability.revoked"
      ]
    },
    {
      "name": "stale-intra-branch-evaluation",
      "module": "DefiKernel.Parallel.Execution",
      "needle": "Composition.run cfg boundary initial (branch.map Step.invoke)",
      "replacement": "(branch.map Step.invoke).foldl\n    (fun cursor step ↦ advance cfg boundary { cursor with world := initial } step)\n    (startCursor cfg initial)",
      "required_false": [
        "parallel.fixture.stateful.prefix"
      ]
    }
  ],
  "positive_checks": [
    "parallel.compat.catalog-positive",
    "parallel.compat.funded-left-complete",
    "parallel.compat.funded-right-complete",
    "parallel.compat.zero-target-funded",
    "parallel.compat.hidden-inactive-guard-funded"
  ]
}

--- END FILE review/semantic-kernel/sprint6/mutation-spec.json ---
