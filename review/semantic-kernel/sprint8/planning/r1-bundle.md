# Independent native/GPT6 Sprint 8 OpenSpec planning audit

Frozen candidate 7a73b2d973ae704d5bb38fed9ea389f8ac8b7bff; unchanged implementation context is final Sprint7 proof candidate bea105ec72e633a2dd66c663b96d0b552e1814a8. Sprint7 native final evidence/delivery gate is still pending, and Atomic implementation additionally REQUIRES that gate and a fresh accepted baseline. Plan review can proceed in parallel. No Atomic Lean/Python implementation exists or is authorized before both its own GPT6/Fable planning gate and dependency gate pass.

Audit the COMPLETE proposal/design/four specs/40tasks for implementability, nonvacuous generic proof scope and feasible independent financial/mutation oracles. 16requirements49scenarios. Stock GPT6 implements, native Grok/Fable audit results, no Foreman, userAFK noinputquestions. Resolve routine choices within explicit current scoped plan.

MANDATORY plain-text substantive final report: VERDICT ACCEPT / ACCEPT WITH LIMITATIONS / REQUEST CHANGES; material blockers with exact file/section and smallest correction; nonblocking implementation watchpoints; exact scope/limits. NO tool calls or XML or proposed command markup; no tools will execute. Do not promise later inspection, request files, expose private chain of thought or claim execution/provider telemetry you do not have. All planning and existing source context follows in full. Prior independent reviewer opinions deliberately excluded. Advisory review is not Lean proof.

Focus: first-failure global abort with exact public fullworld/store rollback and zero committed outputs/supply, distinct aborted diagnostics, one real existing Interleaving.advance pertoken and proof of appendedactualattempt/prefix correspondence, exactlocalhistory/boundary values, receipt-derived signed outstanding pertypedlane/authenticatedprincipal with exhaustive participantcoverage, cash+sumowed invariant tied toactualreceipt neteffects, finalpointwisezero and overreturn/intermediatecredit semantics, perlane entireasset zerosupplychecks, meaningful multilanemultiprincipal omittedkey negatives, genericpublic preservation and conditional interleavingcorrespondence (unpaidsuccess doesnotimplycommit), initializednoncircularmacro invariant rule, all18realcompiling productionmutants withdiscriminatingoracles and52actualCLIcontrols. Avoid strongerhistoricalInterface/Nary/associativity claims. Exactrational proofcarrying cash, finitebinaryfixedcapability event, scopedloanreturnclearing, no fullBalancer/runtime/deploymentfidelity/liveness/provenance are explicit bounds.

Threat model: realistic stale state/history/authority, omittedkey and misleadingevidence mistakes, not attackerreplaceseverybyte. Do not turn broad futurepackages into this sprint blockers. Assess whether actual18mutants cancompile/reachindependentfalse plusprotectedpositive; no compilerfailure countsasdetection. Initialreview plusone targetedfix review; additionalroundsonlyconcreteunresolvedblocker.

--- BEGIN FILE openspec/changes/atomic-synchronization/.openspec.yaml ---
schema: spec-driven
created: 2026-09-07

--- END FILE openspec/changes/atomic-synchronization/.openspec.yaml ---

--- BEGIN FILE openspec/changes/atomic-synchronization/design.md ---
## Context

Sprint 7 supplies typed invocation-only branches, complete binary schedules, one
shared evolving world, branch-local histories, exact attempts and generic
preservation/recovery proofs. Its executor preserves successful prefixes and lets
the peer continue after a refusal. This increment supplies a separate atomic
boundary; existing executors and historical Interface/Nary statements remain
unchanged. See `proposal.md` for motivation and the repository's approved
semantic-kernel migration design for the research mandate.

## Goals / Non-Goals

**Goals:** deterministic finite atomic commit/abort with exact observations,
receipt-derived transient obligations, checked final clearing, generic actual-run
proofs, independent financial expected values and mutation evidence.

**Non-Goals:** arbitrary n-ary topology, nested savepoints, capability issue/revoke
inside the event, external callbacks, general signed spendable ledgers, gas/fees,
replay uniqueness, fairness, distributed finality or deployed Balancer fidelity.
General associativity, provenance, claims and asynchronous compensation remain
separate changes. This model does not promise order independence.

## Decisions

### 1. Stage an existing ordered executor and publish one atomic event

A request contains an event label (`Nat`), the existing two invocation-only
branches, an explicit complete schedule and a trusted clearing policy. The
boundary assignment remains `BranchId → Nat → Boundary`; local positions always
refer to the static invocation index, never global schedule position.

Use a new `Atomic.Machine` containing the original entry world, the speculative
`Interleaving.Machine`, signed outstanding table, global token position and an
optional first abort. `Atomic.advance` is inert after an abort. Otherwise call
**the existing `Interleaving.advance` once** on the current speculative machine.
Inspect the appended attempt at the previous attempt count, with a generic proof
that an active selected invocation appends exactly one actual attempt. An internal
out-of-range token produces no attempt and only follows the existing totalized
skip behavior; public admission excludes incomplete/excess schedules.

A kernel refusal records its original invocation/reason, branch, local index and
zero-based global position, then aborts the entire event. A successful attempt
updates outstanding entries from its actual receipt, then checks lane supply.
If that policy check fails, keep the actual successful movement and updated table
only in the diagnostic machine, record a distinct policy abort and stop. The
public result restores the entry world in either case. This ordering preserves a
cash/obligation invariant even at a policy-abort diagnostic prefix.

After every token succeeds, final clearance either produces the exact nonzero
residual table or commits the speculative world. Admission, kernel/policy abort
and settlement refusal have distinct constructors and exact payloads. An empty
valid schedule commits identity. An empty lane set is ordinary atomic-batch mode
and supplies no evidence of nontrivial transient settlement.

Alternatives considered: wrapping a completed interleaving result would execute
peer work after the first failure; summing common-prestate effects would change
live reads and authorization; permitting negative cash would change the existing
State invariant. The selected fold reuses the financial evaluator and authority
checks while giving the macro event a separate publication rule.

### 2. Separate public committed data from diagnostics

Public admission refusal carries label, schedule, exact admission reason and
entry world. Public abort carries label, schedule, exact located kernel/policy
failure or final residual table and entry world. Neither contains committed inner
receipts, outputs or supply. Public commit carries label, schedule, final world
and one atomic observation containing the ordered successful receipts/snapshots
with their branch/local identities and actual committed supply sum.

Expose diagnostics through a separate result/accessor type, not as committed
history. The public projection erases aborted tentative attempts and snapshots.
Later execution starts from public world and fresh histories. An aborted mint has
zero committed supply even though its diagnostic receipt records a real
speculative mint. Prove this distinction rather than calling speculative
accounting a rollback theorem.

A named public comparison retains outcome kind, label, full schedule, all exact
failure/residual fields, complete ledger/store and all committed financial fields.
It can ignore aborted diagnostics only. Equal and changed-field controls must
exercise the production projection/comparator, including failure fields.

### 3. Use typed receipt-derived clearing lanes

A lane contains a domain, asset and vault principal. Policy admission rejects
repeated `(domain, asset)` pairs, including an alternate vault for the same pair.
The policy contains a canonical duplicate-free finite participant list. Every
principal selected by the trusted local boundaries of every static invocation
must occur in the list; extra unused participants are allowed with zero entries.
A missing participant must refuse before execution rather than silently omit a
final obligation.

Preflight order is fixed: catalog, complete left branch analysis, complete right
branch analysis, lane uniqueness, participant uniqueness, participant coverage
(left then right in static order), exact schedule counts. No shared-footprint
compatibility rejection is added. Malformed unreachable suffixes retain their
existing structural precedence. Policy reasons preserve offending positions and
typed identities so tests can distinguish different faults.

Transient entries are exact signed rationals keyed by `(lane, principal)`, all
initially zero. For each actual successful attempt by authenticated principal p,

```text
owed'(lane,p) = owed(lane,p) - receipt.netEffect(lane.vaultCell)
owed'(lane,q) = owed(lane,q), q != p
```

Compute net effect by summing every evaluated delta at the exact typed cell.
Repeated deltas contribute their full sum. Read the principal from the fixed
trusted local boundary at the actual invocation index. No caller-supplied debt,
predicted effect, operation-name branch or independently recomputed execution is
an acceptable substitute.

Positive values denote net draws, negative values net credits. Intermediate
credits are allowed. Final commit requires **every** lane/participant entry zero;
positive and negative amounts across principals, assets or domains cannot cancel.
Return8 after draw7 leaves residual−1 and aborts; a later authorized draw1 can
consume that credit before commit. Return by a peer changes only the peer's
entry. No forgiveness, clamping, tolerance or implicit repayment reassignment is
introduced. Enumerate the complete residual table in lane order then participant
order, retaining typed keys and exact nonzero quantities.

For every successful receipt, require zero signed supply for every configured
lane's domain/asset across the entire asset. A mint at another principal's cell
therefore triggers `laneSupply` with the lane and actual signed amount, even if
vault cash itself did not change. Other assets can mint/burn under existing
capability rules. This is an explicit restricted clearing policy, not a general
claim that atomic transactions cannot change supply.

This bounded return discipline is chosen over unconstrained caller-provided debt
metadata because its cash correspondence can be proved from execution. It remains
a reference loan/return policy; full swap/hook/fee and runtime transient-storage
correspondence needs the later pinned financial library work.

### 4. Prove actual-run invariants and conditional correspondence

`Atomic/Policy.lean` defines lanes, participants, residual enumeration and typed
checks. `Execution.lean` defines machines, first-abort fold and public projection.
`Soundness.lean` connects every running/aborted diagnostic state to an actual
Interleaving prefix and its real append/execute equations. `Settlement.lean`
provides the new exact-cell receipt effect bridge and table induction.
`Preservation.lean` provides the public macro laws. `Observation.lean` gives exact
public comparison and success correspondence. Runtime examples/tests/audit and
Verify have their own files. Keep executable definitions before proof markers.

The central clearing theorem is universal over actual accepted speculative
prefixes (including the successful kernel step that triggers a policy abort):

```text
cash(speculativeWorld,lane) + sum_participants owed(lane,p)
  = cash(entryWorld,lane)
```

Use actual receipt deltas and complete participant coverage. Prove full table
clearance iff all enumerated obligations are zero, and derive restoration of each
clearing vault cash on commit. A theorem about a supplied unrelated receipt list
is insufficient. Prove no-op debt persistence and distinguish global-sum zero from
full clearance with a concrete counterexample.

Prove exact world/store rollback for every public refusal/abort; zero committed
supply/outputs on abort; accounting over actual committed receipts on commit;
point-of-use authority on real speculative pre-worlds; fixed store; existing
proof-carrying nonnegativity; actual/analyzed write frames and supported-predicate
preservation. Initial authority stores and authenticated boundaries remain trust
premises, not provenance conclusions.

Prove every committed result agrees with its supplied Interleaving execution and
its financial observation. Conversely, an actual successful interleaving plus
passing policy checks and final clearance yields atomic commit. Include an unpaid
successful interleaving counterexample to dropping settlement premises. A public
initialized invariant macro rule combines the actual-prefix R/G preservation with
rollback identity; do not require the final zero-table condition at every internal
step or make local obligations assume the whole result.

### 5. Fix independent financial oracles and mutation obligations before coding

Use complete independent expected worlds/stores/receipts/typed outputs and exact
local/global errors for: empty identity; two-step success; first/middle failures
with stopped peers; nonlane speculative mint then rollback; live versus captured
reads; peer-only versus own histories; local principal/time; revoked versus live
capabilities; draw7/return7, return6 and funded return8; cross-principal offset;
asset/domain separation; nonvault lane-asset supply; nonlane supply success;
repeated deltas/no-op; schedule-dependent commit/refusal and public observation
field sensitivity. Protect collateral and independently funded valid siblings.
Every transient fixture must have a nonempty lane and a nonzero intermediate
obligation. Exact arithmetic is not a machine-rounding claim.

Fix **18 production mutants**: retain prefix on abort; continue peer after first
failure; publish aborted outputs; count aborted supply; stale entry-world call;
peer-history leakage; global boundary index; erase debt without receipt; opposite
vault-effect sign; check global lane sum only; collapse principal keys; collapse
asset/domain keys; omit a final lane; omit a final participant; accept lane supply;
resurrect revoked grants; omit an exact abort observation field; omit an exact
residual observation field. Each must change a real production definition, compile,
trip its independent designated false comparison and preserve declared positive
controls. Overlapping oracle detection is disclosed. The omission mutants need
at least two real lanes/participants so an omitted nonzero entry is observable.

Adapt the established defensive source-projection runner in focused Atomic
scripts. Require fresh outside-repository output paths, exact Git/byte input
manifests, complete unique nonempty runtime inventories and no post-marker runtime
definitions. Distinguish semantic violation from blocked source/edit/compile/
inventory/drift/output errors. Exercise all 52 established Interleaving CLI control cases on the Atomic
runner with Atomic module roots and observation names;
compiler failure alone is never a financial detection. Reuse unchanged runner
infrastructure only with exact module/import correspondence and tested Atomic
paths; do not count old logs as a fresh run.

## Risks / Trade-offs

- Proof-carrying cash restricts flash-credit expressiveness → prove a nontrivial
  funded loan/return discipline and keep wider runtime fidelity open.
- A staged success can fail policy → retain consistent diagnostics, restore the
  entire public entry world, publish no tentative event.
- Participant or lane omission could make settlement vacuous → preflight complete
  boundary coverage, duplicate rejection and separate omission mutants.
- Scalar netting could erase qualified liabilities → typed keys, exact residual
  table and cross-principal/asset/domain counterexamples.
- Wrapper reasoning could concern an unrelated trace → use the existing advance
  function and prove exact appended-attempt/prefix correspondence.
- Additional files could escape audit → imported namespace inventory, complete
  source projection closure and declared runtime roots checked nonempty.

## Migration Plan

Freeze proposal/design/four specs/tasks plus context; pass independent GPT-6 and
native Fable planning reviews on the same candidate before implementation. Planning may run while Sprint7 final reviews finish, with its exact final source
candidate as context. Atomic implementation additionally requires Sprint7 accepted
delivery and a fresh baseline on that accepted head. Implement policy, execution, settlement,
preservation and fixtures in dependent increments through stock GPT-6. Run
focused checks while developing; then freeze source and run new and all legacy
acceptance drivers. Obtain native Grok/Fable substantive source and evidence
verdicts, resolve blockers and refresh affected checks. Record proof/runtime/
compiler/advisory categories and exact identities in review artifacts and wiki.
Deliver only to `semantic-kernel-pivot`, verify remote, archive this OpenSpec and
synchronize its four main specs. Existing semantics, corpus sources and historical
proof statements are retained throughout. No Foreman or merge to main.

--- END FILE openspec/changes/atomic-synchronization/design.md ---

--- BEGIN FILE openspec/changes/atomic-synchronization/proposal.md ---
## Why

Sequential and shared-state execution preserve a successful prefix when a later
invocation refuses. Financial synchronization also needs an explicit transaction
boundary that commits a fully settled result or restores the exact initial world.

## What Changes

- Add finite atomic execution over explicit binary schedules with one speculative
  shared world, branch-local histories and global abort on the first refusal.
- Separate committed financial observations from aborted speculative diagnostics;
  failed admission, failed execution and failed final settlement preserve the
  initial ledger and capability store and publish no committed receipts/outputs.
- Add a bounded, receipt-derived clearing policy for temporary vault obligations,
  with typed vault/domain/asset lanes, authenticated principal attribution and
  checked zero outstanding obligations at commit. Spendable balances remain
  proof-carrying nonnegative throughout.
- Prove actual atomic trace soundness, rollback, committed accounting/authority/
  frames, clearing conservation and conditional success correspondence with the
  existing interleaving executor.
- Add independent financial success/refusal fixtures, real runtime mutations,
  defensive runner controls and exact source-bound evidence with native reviews.

## Capabilities

### New Capabilities

- `atomic-execution`: Admission, speculative execution, first-failure abort and
  exact public committed/aborted observations.
- `atomic-settlement`: Receipt-derived typed clearing obligations, policy checks
  and deterministic final-settlement refusal.
- `atomic-preservation`: Generic actual-run rollback/preservation, clearing
  conservation and conditional correspondence to existing execution.
- `atomic-regression-evidence`: Financial fixtures, live source mutations,
  complete runner controls and frozen proof/review/delivery evidence.

### Modified Capabilities

None. Existing sequential, disjoint parallel and shared interleaving semantics
retain their accepted behavior.

## Impact

New Lean namespace and modules under `lean/DefiKernel/Atomic/`, root verification
import, focused Python mutation/control drivers and versioned Sprint 8 review
artifacts. OpenSpec holds requirements and `wiki-llm` records decisions. Existing
proofs, runtime constructors, source corpus and dependency versions are preserved.

This is a finite, fixed-capability, exact-arithmetic reference model. It does not
claim general signed spendable balances, capability mutation inside a transaction,
unbounded liveness, reentrant hooks, fees/gas, distributed atomicity, full Balancer
semantics or deployed-protocol fidelity. Those remain separate roadmap obligations.

--- END FILE openspec/changes/atomic-synchronization/proposal.md ---

--- BEGIN FILE openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md ---
## Purpose

Define finite atomic transaction behavior with exact admission, fail-fast speculative execution and one committed public event.

## ADDED Requirements

### Requirement: Ordered complete admission

The system SHALL validate the catalog, entire left branch, entire right branch, lane uniqueness, participant uniqueness, complete participant coverage and exact schedule counts in that order. Shared footprints SHALL be permitted. Every admission refusal SHALL retain the event label, supplied schedule, exact typed reason and complete initial world without attempts or committed data.

#### Scenario: Shared funded admission

- **WHEN** both valid branches write a funded shared cell under a complete schedule
- **THEN** the request is admitted despite overlapping footprints

#### Scenario: Malformed unreachable suffix

- **WHEN** an unreachable invocation is structurally invalid and policy or schedule is also invalid
- **THEN** the entire branch structural error is reported before policy/schedule and the initial world is unchanged

#### Scenario: Policy and count precedence

- **WHEN** duplicate lane, duplicate participant, uncovered principal and count errors compete
- **THEN** the first error in the specified preflight order is returned with its typed identity and position

#### Scenario: Empty and malformed schedules

- **WHEN** empty branches have an empty schedule, or nonempty branches have missing/excess tokens
- **THEN** the empty case can commit identity and malformed counts refuse before speculation

### Requirement: One speculative world and local histories

Every scheduled active invocation SHALL execute once against the current speculative world using its own captured output history and trusted branch-local boundary. Successful attempts SHALL preserve their exact receipts and snapshots diagnostically. Public execution SHALL never recompute financial effects from a stale initial world or leak peer history.

#### Scenario: Live state after peer movement

- **WHEN** a peer changes a balance before a later live-read operation
- **THEN** the later receipt reflects the changed speculative balance

#### Scenario: Captured local snapshots

- **WHEN** two branches capture distinct values at the same qualified output key and then consume their own snapshots
- **THEN** each consumer uses its own captured value despite subsequent shared-world changes

#### Scenario: Peer-only output refusal

- **WHEN** an invocation references an output produced only by the peer beside an independently funded own-history sibling
- **THEN** the peer-only case refuses with the exact history error and the own-history sibling succeeds

#### Scenario: Local principal and time

- **WHEN** the global schedule position differs from the invocation local index
- **THEN** the actual call uses the fixed local principal/time, including live/revoked and authorized/unauthorized siblings

### Requirement: First failure aborts the whole event

The first attempted kernel refusal or successful-step settlement-policy violation SHALL stop all remaining own and peer invocations. The public abort SHALL restore the entire initial ledger and capability store and preserve label, schedule, branch, invocation, local index, zero-based global index and exact reason. Policy failure SHALL be distinguishable from a kernel refusal.

#### Scenario: Immediate failure stops peer

- **WHEN** the first attempted invocation refuses while later peer work would be valid
- **THEN** no peer or suffix attempt occurs and the public world is exactly the entry world

#### Scenario: Middle failure restores prefix

- **WHEN** a successful prefix is followed by a kernel refusal
- **THEN** all speculative prefix changes roll back publicly and the exact first refusal is retained

#### Scenario: Policy failure diagnostics

- **WHEN** an actual successful kernel step violates lane supply policy
- **THEN** diagnostics retain its real movement and updated obligations, the event aborts at that position, and no public effect commits

### Requirement: Committed publication and exact observations

The public result SHALL distinguish admission refusal, abort and commit. Only commit SHALL publish one named event containing ordered successful financial receipts, typed outputs, local identities and actual committed supply. Abort SHALL publish no committed inner receipt, output or supply. Public comparison SHALL preserve label, schedule, kind, full ledger/store, exact reasons/residuals and all committed financial fields; aborted diagnostic traces alone may be omitted.

#### Scenario: Committed event

- **WHEN** a nonempty event executes and settles successfully
- **THEN** one atomic event contains independently expected complete world/store/receipt/output data

#### Scenario: Aborted mint and history

- **WHEN** a nonlane asset is speculatively minted before a later refusal
- **THEN** the public mint supply is zero, the initial balances return and no tentative output can serve as later committed history

#### Scenario: Observation field sensitivity

- **WHEN** one preserved public field changes beside an equal-value control
- **THEN** the production comparison distinguishes every changed field and accepts the equal control

#### Scenario: Order-sensitive outcome

- **WHEN** identical invocations run under two valid orders with different funding availability
- **THEN** the exact commit/abort outcomes differ without any claim of atomic order independence

--- END FILE openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md ---

--- BEGIN FILE openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md ---
## Purpose

Establish generic proofs about actual atomic executions, committed preservation, exact rollback and receipt-linked transient cash conservation.

## ADDED Requirements

### Requirement: Actual trace and stop soundness

The implementation SHALL prove that every diagnostic machine arises from an actual prefix of the supplied existing interleaving execution with exact appended invocation outcomes, local histories and boundary indices. After first abort its diagnostic state SHALL remain inert. A complete un-aborted event SHALL exhaust every static invocation.

#### Scenario: Actual-prefix witness

- **WHEN** any finite atomic diagnostic prefix is reached
- **THEN** the proof relates that machine to a real interleaving prefix rather than an unrelated supplied trace

#### Scenario: Global stop theorem

- **WHEN** an abort is followed by any remaining schedule suffix
- **THEN** the entire diagnostic state remains unchanged

#### Scenario: Complete exhaustion

- **WHEN** a complete request reaches final settlement without an earlier abort
- **THEN** all branch invocations were successfully exhausted

### Requirement: Cash and obligations conserve

For every reached diagnostic prefix and configured lane, the implementation SHALL prove that current vault cash plus the sum of participant obligations equals entry vault cash, including a successful step causing policy abort. Full clearance SHALL be equivalent to pointwise zero over the complete table and SHALL imply restoration of each clearing vault cash cell on commit.

#### Scenario: Generic cash correspondence

- **WHEN** a nonempty actual speculative prefix changes a lane vault
- **THEN** the exact cash-plus-obligation equality follows from accepted receipt effect application

#### Scenario: Commit restores clearing cash

- **WHEN** a request commits after full clearance
- **THEN** every configured vault cash cell equals its entry value

#### Scenario: Scalar netting counterexample

- **WHEN** a lane has nonzero offsetting principal obligations
- **THEN** a concrete checked counterexample refutes replacing pointwise clearance by global-sum zero

### Requirement: Public financial preservation

The implementation SHALL prove exact entry-world/store identity and zero committed supply/outputs for every admission refusal or abort. On commit it SHALL prove per-domain/asset accounting from actual committed receipts, authority at actual speculative pre-worlds and local boundaries, fixed capability store, proof-carrying nonnegativity, actual/analyzed write locality and supported-predicate frames, with trust and initialization premises explicit.

#### Scenario: Generic rollback

- **WHEN** any public noncommit result is produced
- **THEN** the whole ledger/store equal the entry world and committed supply/history are empty

#### Scenario: Committed accounting and authority

- **WHEN** an event commits with nonzero authorized supply
- **THEN** accounting uses its actual receipts and authority is established at each real pre-world

#### Scenario: Protected collateral and support necessity

- **WHEN** a predicate depends only on untouched collateral or incorrectly claims empty support for a changed cell
- **THEN** the supported predicate is framed and a concrete counterexample exposes the unsupported claim

### Requirement: Conditional correspondence and invariant lifting

Every commit SHALL agree with actual successful interleaving under the supplied schedule. The converse SHALL require actual underlying success, per-step policy acceptance and complete final clearance. An initialized public invariant rule SHALL derive commit preservation from independently quantified actual-prefix obligations and abort preservation from rollback, without circular whole-result assumptions.

#### Scenario: Successful correspondence

- **WHEN** a request commits or an actual successful interleaving passes every policy/clearance check
- **THEN** the two actual committed financial observations agree in the stated direction

#### Scenario: Settlement premise is necessary

- **WHEN** underlying interleaving succeeds while a lane obligation remains nonzero
- **THEN** a concrete example aborts atomically and refutes dropping final clearance

#### Scenario: Initialized macro invariant

- **WHEN** initial invariants and the explicit local/peer-stability premises hold
- **THEN** public commit and abort both preserve the invariant, without requiring zero obligations at every internal step

--- END FILE openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md ---

--- BEGIN FILE openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md ---
## Purpose

Require source-bound financial, proof, mutation, regression and independent-review evidence before accepting the atomic synchronization increment.

## ADDED Requirements

### Requirement: Independent nonempty financial inventory

Acceptance SHALL execute a unique nonempty named runtime inventory with independently constructed full expected ledgers/stores, actual receipts, typed outputs, exact errors/positions/residuals and funded positive siblings. Proof inventory SHALL retain elaborated premises and distinguish generic theorems, reference instances, counterexamples, generated declarations and supplemental checks.

#### Scenario: Exact financial controls

- **WHEN** atomic examples are evaluated
- **THEN** every required financial field and protected positive is compared, with genuine nonempty transient cases

#### Scenario: Imported proof inventory

- **WHEN** the Atomic verification root is elaborated
- **THEN** all imported theorem/supplemental declarations are audited with zero forbidden dependencies and counts kept separate from runtime executions

### Requirement: Eighteen live production mutations

Acceptance SHALL detect all18 design-listed source mutants in fresh actual runtime projections. Each mutant SHALL compile, produce the complete inventory, fail its designated independent oracle and preserve protected positive controls. Compile errors, omitted observations, failed positives and surviving mutants SHALL NOT count as detections.

#### Scenario: Mutation discrimination

- **WHEN** each of the18 frozen production source edits is applied
- **THEN** its exact edit and runtime false oracle are recorded with complete observations and true protected siblings

#### Scenario: Detection qualification

- **WHEN** a mutation fails compilation, omits evidence or leaves its designated comparison true
- **THEN** the result is blocked or violated as appropriate and never counted as a semantic detection

### Requirement: Defensive runner and current regressions

Acceptance SHALL run all52 established defensive CLI control cases using Atomic module roots and observation names, enforce exact source/driver/spec identities and fresh safe output paths, and retain failed attempts honestly. All new/full legacy Lean and Python acceptance drivers SHALL be checked against current or proven byte-identical relevant inputs with actual exits and complete logs. Existing historical proofs and corpus bytes SHALL be preserved.

#### Scenario: Runner controls

- **WHEN** valid, malformed, empty, partial, duplicate, unknown, bad-edit, unsafe-output, drift, compile-only and survivor CLI cases run
- **THEN** all52 intended outcomes and diagnostics are verified without empty pass claims

#### Scenario: Frozen source and artifacts

- **WHEN** a source, driver, specification, projection or recorded result changes
- **THEN** input drift or artifact mismatch is detected, and old runs are not relabeled as fresh evidence

#### Scenario: Legacy preservation

- **WHEN** final integration runs on the atomic candidate
- **THEN** all required new and historical checks pass with exact relevant-source bindings and preserved historical statements/corpus

### Requirement: Independent gated delivery

Implementation SHALL begin only after independent GPT-6 and native Fable planning verdicts pass on the same frozen candidate. Acceptance SHALL require native Grok/Fable substantive implementation and evidence verdicts on exact inputs, resolution of blockers, truthful wiki/roadmap/task records, strict OpenSpec validation and a verified branch push/archive. Unavailable reviewers SHALL remain open and no Foreman SHALL be used.

#### Scenario: Same-candidate planning gate

- **WHEN** implementation is about to begin
- **THEN** both required independent planning verdicts bind the same complete proposal/design/spec/tasks candidate

#### Scenario: Unavailable review

- **WHEN** a required native reviewer is unavailable or returns no substantive passing verdict
- **THEN** the review remains pending while independent work continues, without substituted identity or invented approval

#### Scenario: Accepted delivery

- **WHEN** all proof/runtime/mutation/regression/review obligations pass
- **THEN** the authorized branch push is verified, all scenarios map to actual evidence, wiki/roadmap reflect limits and the accepted change is archived with synchronized main specs

--- END FILE openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md ---

--- BEGIN FILE openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md ---
## Purpose

Specify typed receipt-derived transient obligations and a deterministic full settlement check before an atomic event may commit.

## ADDED Requirements

### Requirement: Complete typed policy

Clearing lanes SHALL have unique domain/asset pairs with an explicit vault cell, and participants SHALL be duplicate-free and cover every authenticated static invocation principal. Final enumeration SHALL include every lane/participant key in declared lane then participant order, retaining typed identities. Empty lanes SHALL be an explicit ordinary batch mode and SHALL NOT count as evidence of transient settlement.

#### Scenario: Ambiguous lane rejection

- **WHEN** two lanes repeat a domain/asset, with either equal or different vaults
- **THEN** policy admission refuses the exact duplicate pair

#### Scenario: Participant completeness

- **WHEN** a participant is duplicated or a later static invocation principal is absent
- **THEN** admission reports the corresponding distinct policy error before execution

#### Scenario: Nonempty settlement evidence

- **WHEN** a fixture is counted as a transient-settlement success or negative
- **THEN** it contains a real configured lane and a nonzero intermediate obligation

### Requirement: Actual receipt origin

Outstanding entries SHALL initialize to zero and update only by subtracting the actual accepted receipt net effect at each exact lane vault cell from the authenticated invoker entry. Other participant entries SHALL remain unchanged. Repeated receipt deltas SHALL be fully summed. No-op effects SHALL NOT erase debt.

#### Scenario: Draw and return

- **WHEN** one authenticated principal draws7 from vault10 and returns7
- **THEN** the intermediate obligation is7 and the final obligation is0 with vault cash10

#### Scenario: Repeated deltas and no-op

- **WHEN** a receipt contains repeated deltas at the lane cell or a later operation has zero lane effect
- **THEN** the full net delta is used and the no-op preserves any existing obligation

#### Scenario: Intermediate credit

- **WHEN** an independently funded principal returns extra before a later authorized draw of that credit
- **THEN** the signed negative intermediate entry can return to zero and settle

### Requirement: Qualified final clearance

Commit SHALL require every outstanding lane/participant entry to equal exact zero. Any nonzero table SHALL abort with the complete canonical nonzero residual table and the entry world. Principal, domain and asset qualifications SHALL NOT be collapsed or netted against other keys.

#### Scenario: Under and over return

- **WHEN** draw7 is followed by return6 or independently funded return8 with no further movement
- **THEN** the results abort with residual+1 or−1 respectively and restore vault10

#### Scenario: Cross-principal cancellation

- **WHEN** one principal owes7 while a peer has credit−7 in the same lane
- **THEN** global sum zero does not settle and both exact residual entries are returned

#### Scenario: Cross-asset and domain separation

- **WHEN** equal numeric debts and credits occur in distinct configured assets or domains
- **THEN** every qualified nonzero entry remains and settlement refuses

#### Scenario: Last lane or participant residual

- **WHEN** only a later lane or later participant has a nonzero obligation
- **THEN** final clearance detects that exact residual rather than checking only a prefix

### Requirement: Lane supply policy

Every successful receipt SHALL have zero signed supply for every configured lane domain/asset across that asset, including supply at a nonvault principal. The first violating lane in policy order SHALL cause a located policy abort with lane and exact amount. Authorized supply of unconfigured assets SHALL remain permitted.

#### Scenario: Nonvault lane mint

- **WHEN** a receipt mints the lane asset into a cell different from the clearing vault
- **THEN** the event aborts for lane supply with the exact amount even if vault cash is unchanged

#### Scenario: Nonlane supply success

- **WHEN** an independently authorized unconfigured-asset mint accompanies a fully cleared nonempty lane
- **THEN** the event commits with its exact nonzero supply summary

--- END FILE openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md ---

--- BEGIN FILE openspec/changes/atomic-synchronization/tasks.md ---
## 1. Planning and accepted baseline

- [ ] 1.1 Save proposal/design/four specs/tasks/wiki rationale and a scenario-to-task/evidence map; verify strict OpenSpec validation, all49 scenarios mapped and no unresolved behavior choices or placeholders.
- [ ] 1.2 Freeze complete plan and exact source context at the final Sprint7 source candidate; require its accepted delivery before Atomic implementation, obtain separate GPT-6/native Fable passing planning verdicts on that same candidate and verify exact model/hash bindings before implementation.
- [ ] 1.3 Capture a current full Lean/runtime/axiom baseline, relevant Python driver identities and historical proof/corpus source inventory; verify every required baseline command succeeds and preserved bytes are unchanged.

## 2. Typed policy and ordered admission

- [ ] 2.1 Add `Atomic/Policy.lean` typed lanes, canonical participants, signed table/residuals and exact policy failure payloads; verify typed asset/domain/participant separation and independent full residual examples.
- [ ] 2.2 Implement ordered lane-pair uniqueness, participant uniqueness and complete static-boundary participant coverage; verify duplicate same/alternate-vault lanes, duplicate participants and late uncovered principals each report exact distinct reasons.
- [ ] 2.3 Implement full catalog/left/right/policy/count admission; verify overlapping funded writes admit, malformed unreachable suffixes retain precedence, missing/excess schedules refuse and valid empty identity is allowed.
- [ ] 2.4 Prove accepted policy completeness and residual enumeration coverage/uniqueness; verify every real branch boundary principal and every lane key is covered without an empty-policy assumption.

## 3. Speculation and public atomic boundary

- [ ] 3.1 Add `Atomic/Execution.lean` entry-world/speculative machine/outstanding/global-position/first-abort state and initialization; verify an independently expected empty request commits identity with exact label/schedule/store.
- [ ] 3.2 Implement each running token through one existing `Interleaving.advance` call and its actual appended attempt; verify live current-world evaluation, local principal/time and both own snapshot histories beside peer-only/refused siblings.
- [ ] 3.3 Implement first-kernel or successful-step-policy failure global abort and inert continuation; verify immediate/middle refusal stops every remaining peer/suffix and records exact invocation/local/global reason.
- [ ] 3.4 Implement final clearance and separate public admission/abort/commit projection; verify full ledger/store rollback and zero committed receipt/output/supply even after nonlane speculative mint.
- [ ] 3.5 Add `Atomic/Observation.lean` exact public comparison and one committed atomic-event observation; verify changed/equal pairs for label, schedule, kind, full worlds/stores, receipt/output, exact abort and full residual fields while aborted diagnostics alone are omitted.

## 4. Actual trace and transient settlement proofs

- [ ] 4.1 Add `Atomic/Soundness.lean` actual atomic reachability and one-appended-attempt correspondence; prove every diagnostic state equals an actual interleaving prefix, no suffix after abort and complete active exhaustion, then verify imported proof checks.
- [ ] 4.2 Add `Atomic/Settlement.lean` exact-cell receipt-effect bridge and authenticated-principal table update; verify repeated deltas sum fully, peer entries stay fixed and zero effects cannot erase a nonzero debt.
- [ ] 4.3 Implement first-lane signed supply check from each actual successful receipt; verify nonvault lane mint refuses exactly while authorized nonlane supply with full nonempty settlement commits.
- [ ] 4.4 Prove actual-prefix cash plus summed participant obligations equals entry vault cash, including the successful step that triggers policy abort; verify no unrelated trace or caller-supplied amount premise substitutes for executor soundness.
- [ ] 4.5 Prove final clearance iff every typed table entry is zero and derive restored vault cash on commit; verify nontrivial draw7/return7 and generic completeness across multiple lanes/participants.
- [ ] 4.6 Add funded under-return/over-return/intermediate-credit/cross-principal/asset/domain/last-key cases and a checked scalar-netting counterexample; verify exact positive and negative residual tables with initial-world rollback.

## 5. Macro preservation and correspondence

- [ ] 5.1 Add `Atomic/Preservation.lean` generic public admission/abort identity and empty committed history/supply theorems; verify the statements cover all noncommit constructors and the complete world/store.
- [ ] 5.2 Prove committed per-domain/asset accounting from actual receipts, point-of-use authority at real speculative pre-worlds, fixed store and proof-carrying nonnegativity; verify authorized/nonlane-supply and unauthorized/revoked siblings with trust premises recorded.
- [ ] 5.3 Prove actual/analyzed write locality and supported-predicate frames; verify protected collateral and a concrete missing-support counterexample rather than an unrestricted predicate claim.
- [ ] 5.4 Prove commit implies actual successful interleaving agreement and the converse with explicit per-step policy/final-clearance premises; verify an unpaid underlying success refutes dropping settlement and two orders can commit versus abort differently.
- [ ] 5.5 Lift the initialized actual-prefix invariant rule to public commit/rollback without circular whole-result premises; verify a nonempty transient instance with internally nonzero obligations and explicit initialization/peer-stability obligations.

## 6. Financial and imported evidence inventory

- [ ] 6.1 Complete `Atomic/Examples.lean` and `Tests.lean` independent full worlds/stores/receipts/outputs/failures/residuals for every design family; verify actual positive/negative paths and protect independently funded valid siblings.
- [ ] 6.2 Add `Atomic/Audit.lean` unique nonempty named runtime inventory and `Verify.lean` automatic imported theorem/supplemental checks, then root import; verify all runtime comparisons true and forbidden axiom count zero.
- [ ] 6.3 Save exact elaborated/source theorem statements, premise classes, source provenance and one-to-one actual scenario map; verify all49 mappings and distinguish generic results/instances/counterexamples/generated/runtime/compiler/advisory evidence.

## 7. Eighteen production mutations and defensive runner

- [ ] 7.1 Add `scripts/check_atomic_mutations.py` explicit repo/spec/fresh external out, actual recursive source projection, complete inventories and exact Git/byte binding; verify an unchanged real control and declared positive comparisons.
- [ ] 7.2 Add actual retain-prefix/global-continuation/aborted-output/aborted-supply/stale-world/peer-history/global-boundary mutants; verify each compiles and its designated independent comparison fails with protected positives true.
- [ ] 7.3 Add actual no-receipt-erasure/wrong-effect-sign/global-sum/principal-collapse/asset-domain-collapse/omitted-lane/omitted-participant mutants; verify all seven affect real nonempty qualified clearing paths and are detected beside funded positive controls.
- [ ] 7.4 Add actual lane-supply-acceptance/revoked-resurrection/abort-field-omission/residual-field-omission mutants; verify all four compile, reach their designated financial oracles and preserve the defined positive controls.
- [ ] 7.5 Add `scripts/test_atomic_mutation_runner.py` and run all52 established real CLI control cases with Atomic roots/names; verify exact valid/violated/blocked classifications, diagnostics and source/edit/inventory/drift/output checks.
- [ ] 7.6 Freeze source/spec/drivers and execute all18 production mutations plus52 controls into fresh external directories; verify complete per-variant inventories, exact edits, all designated false/protected true results, source Git objects and artifact hashes while retaining failed attempts separately.

## 8. Final independent acceptance

- [ ] 8.1 Freeze implementation and run the new Atomic plus all previous Lean build/runtime/axiom drivers, every existing mutation/runner/compiler/axiom/corpus Python suite and required new drivers; verify fresh actual exits/logs and protected bytes with exact relevant input bindings.
- [ ] 8.2 Finish final scenario/proof/tool/source/artifact inventories and an independent reconciliation; verify every counted item exists and hashes/premises/relevant-source equivalence support the exact candidate without relabeling old runs.
- [ ] 8.3 Obtain native Grok/Fable substantive implementation and final evidence audits; verify each required scope receives a passing verdict bound to exact inputs and requested/reported identities, with no unavailable/substituted approval.
- [ ] 8.4 Resolve blocking findings and refresh affected proof/runtime/review evidence, saving limitations and retained dissent; verify no normative obligation is waived and every execution/review claim has its actual artifact.

## 9. Wiki roadmap and branch delivery

- [ ] 9.1 Update roadmap/progress/wiki/task states from accepted evidence; verify general metatheory, dynamic provenance, full Balancer/runtime fidelity and later roadmap packages remain accurately open.
- [ ] 9.2 Validate this OpenSpec strictly and check editorial whitespace/local links while preserving raw hash-bound artifacts; verify all49 scenarios and task states match actual acceptance.
- [ ] 9.3 Commit/push the accepted implementation/evidence to `semantic-kernel-pivot` and verify actual remote identity; record delivery without merging main or including unrelated changes.
- [ ] 9.4 Archive only `atomic-synchronization`, synchronize/validate its four main specs and repair links; push final metadata and verify clean worktree, completed task states and remote head.

Dependencies:1 gates implementation;2→3→4→5;fixtures grow with each behavior;
6 inventories all proofs/runtime;7 requires real production paths;8 and9 accept
and deliver. The user already authorized execution without further input. Stock
GPT-6 implements and native Grok/Fable review; no Foreman.

Verification command instructions (save actual command arrays, UTC times, exits,
source/tool/model hashes and full logs as evidence when executed):

```sh
openspec validate atomic-synchronization --strict --json --no-interactive
openspec status --change atomic-synchronization --json
# from lean/
lake build
lake env lean DefiKernel/Atomic/Audit.lean
lake env lean DefiKernel/Atomic/Verify.lean
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

Use exact established Python command arrays from Sprint7 final manifests after
checking actual driver help, adding the new Atomic runner/control commands with
fresh output paths owned by the runners. Baseline omits only the not-yet-existing
Atomic drivers. Never run a bare dependency-wide clean while concurrent Lean jobs
are using built imports; if a clean package rebuild is needed, use `lake clean
defialgebra` then `lake build` with other compiler jobs idle.

--- END FILE openspec/changes/atomic-synchronization/tasks.md ---

--- BEGIN FILE wiki-llm/sprint-8-atomic-synchronization.md ---
# Sprint 8: atomic synchronization

Status: OpenSpec candidate prepared; independent planning gate remains pending.

[Proposal](../openspec/changes/atomic-synchronization/proposal.md),
[design](../openspec/changes/atomic-synchronization/design.md),
[tasks](../openspec/changes/atomic-synchronization/tasks.md), and
[planned coverage](../review/semantic-kernel/sprint8/planning/coverage.json)
define four capabilities, 16 requirements and 49 scenarios. The separate
[design investigation](sprint-8-atomic-synchronization-draft.md) records alternatives
and historical Interface/Nary scope. This proposed design choice remains subject
to the independent plan audits; no Atomic implementation is claimed.

## Decisions

1. Run the existing interleaving advance once per token in an isolated speculative
   machine. Abort the whole event at the first kernel or settlement-policy error.
   Public atomicity does not imply internal order independence.
2. Keep public committed events and aborted diagnostics in distinct projections.
   Rollback restores the exact entry ledger/store. Speculative minted supply and
   snapshots do not become committed financial observations.
3. Derive signed transient obligations from actual accepted receipt effects at
   typed vault cells, attributed to authenticated local principals. This gives a
   cash-plus-obligations equality that can be proved from execution.
4. Require every typed lane/participant entry to clear. Equal numeric debt/credit
   across principals, assets or domains cannot cancel. Intermediate credit is
   permitted; unresolved over-return at completion aborts exactly.
5. Reject lane-asset supply anywhere in that asset while permitting authorized
   nonlane supply. This is a bounded loan/return policy, with full Balancer, hooks,
   machine arithmetic and deployed fidelity left to later library/refinement work.
6. Use 18 fixed production mutation obligations and all 52 defensive runner
   controls. Source review, kernel proof, financial runtime and compiler controls
   remain separate evidence categories.

The user's AFK instruction authorizes execution after the same-candidate GPT-6 and
native Fable planning gate passes. Native Grok/Fable final audits, exact source
bindings, verified branch delivery and OpenSpec archive remain required. No Foreman.

--- END FILE wiki-llm/sprint-8-atomic-synchronization.md ---

--- BEGIN FILE wiki-llm/sprint-8-atomic-synchronization-draft.md ---
# Sprint 8 atomic synchronization draft

> For agentic workers: this is a design draft for the parent's OpenSpec proposal,
> not an approved implementation plan. Use the existing stock GPT-6 harness and
> applicable executing-plans workflow only after the frozen GPT-6/Fable planning
> gate passes. Native Grok/Fable result audits and exact source binding remain
> required. Do not use Foreman.

**Goal:** Execute named finite multi-component events with all-or-nothing public
commit, exact rollback on failure, and a checked transient settlement discipline
linked to actual token movements.

**Architecture:** Run one complete binary schedule in an isolated speculative
machine, retaining existing branch-local inputs, receipts and authenticated
boundaries. Maintain a separate signed obligation table derived from successful
receipts. Publish one atomic event only when every invocation and settlement
check passes; otherwise publish an exact refusal with the original world.

**Tech stack:** Lean 4.33.0-rc2, existing exact-rational Typed/Composition/
Interleaving modules, OpenSpec, Python source-mutation and artifact checks.

Status: draft only, 2026-09-07. Examined Sprint 7 source candidate
`6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c`; its native result and delivery gates
were still in progress when this draft was written. Implementation must use the
actual accepted Sprint 7 head as its recorded baseline. The user's AFK instruction
authorizes routine scope decisions without new questions; it does not waive the
independent planning gate or turn this note into proof evidence.

## Basis and limits of the source investigation

The [current roadmap](../roadmap.md) separately requires atomic synchronization,
failure/transient-settlement semantics, operational generalization of historical
interface/binding results, and later behavioral associativity. The
[approved migration design](../docs/superpowers/specs/2026-09-06-semantic-kernel-design.md)
requires preservation of old statements, exact accounting, explicit assumptions
and separate reference/fidelity evidence. The
[original supplied plan](../docs/research/2026-09-06-defi-source-plan.md), lines
584–590 and 880–886, calls for named transitions participating in one event and
transient deltas settled before completion. Its embedded external references are
unresolved source material, not a verified Balancer correspondence.

[Interface.lean](../lean/Defialgebra/Interface.lean) proves conservation under an
explicit nonshareable declared-total field, confinement and quantity-neutrality
premises; it supplies a counterexample when the total can be written through a
port. It does not prove atomic execution. [Nary.lean](../lean/Defialgebra/Nary.lean)
proves equality constraints over globally named ports, union associativity and
reindexing, and excludes pair-local skip edges. It explicitly does not prove
operational reachability. Preserve both files and avoid presenting their algebraic
binding results as behavioral associativity of the new runner.

The existing graph has historical `atomic`, `binding`, `interface`, and `nary`
vocabulary and links the old M3 agenda, but lacks the current kernel modules.
This draft therefore uses direct current source inspection for implementation
claims. No graph update, Lean source edit, external protocol claim, or new
implementation occurred during drafting.

## Alternatives and recommended boundary

| Approach | Benefit | Cost or missing behavior |
| --- | --- | --- |
| Isolated staged execution plus receipt-derived settlement, recommended | Reuses current typed steps; explicit all-or-nothing public state; transient debt/credit cannot be fabricated independently of cash movement | Defines a bounded vault return discipline, not general hook/netting semantics |
| Wrapper around a completed sequential/interleaving result | Small rollback proof | Continuing peers after failure obscures global abort; without a transient obligation model this misses the roadmap requirement |
| Fuse all effects evaluated at one common pre-world, or allow signed spendable ledgers | Could express wider simultaneous clearing | Changes live-read/authority/nonnegativity semantics and requires a new adapter metatheory; too broad for this increment |

Select the first. Internal operations retain a specified order. Atomic means no
intermediate durable effects become public, not schedule independence or
simultaneous common-prestate evaluation. Different supplied orders can still
commit or abort differently. Reuse binary branches and complete schedules; defer
arbitrary participant topology, nested savepoints, administrative transactions,
external callbacks and cross-domain finality to separate changes.

## Proposed observable contract

Introduce `DefiKernel.Atomic`, leaving earlier executors unchanged. A request
contains a stable event label, two invocation-only branches, a complete schedule,
and a trusted clearing policy. The label identifies the observation; uniqueness
and replay prevention are not claimed by this sprint.

Preflight checks are ordered: existing catalog validation, complete left analysis,
complete right analysis, clearing-policy well-formedness, participant coverage,
then exact schedule counts. Policy checks cannot be hidden in the caller's own
financial guards. Unknown operations in unreachable suffixes still refuse before
speculation. Existing operation access and kernel refusal order remain unchanged
once an invocation is attempted.

Public results have three distinct cases:

1. Admission refusal: exact structural/policy/count reason, event label, supplied
   schedule and original complete world; no attempted or committed event.
2. Runtime abort: first located kernel/adapter or settlement-policy failure,
   event label, supplied schedule and original complete world. No committed
   inner receipt, output history, supply delta or partial balance is published.
3. Commit: final complete world and one named atomic event containing the ordered
   successful internal receipts and their exact typed snapshots, branch/local
   identities and committed supply summary. Each inner receipt is explicitly
   committed as part of this event, not published during speculation.

An internal diagnostic result may expose speculative attempts and tentative
histories for tests and proofs. It must have a separate type and projection from
public committed receipts/outputs. Later execution consumes only committed state
and fresh invocation histories; aborted snapshots cannot become prior-output
inputs. Diagnostic accounting is not committed accounting.

On the first attempted invocation failure, halt the whole atomic event
immediately. Do not run the peer or any suffix. Its exact failure includes global
schedule position, branch, local index, original invocation and original refusal.
If a successful token movement violates clearing policy, abort at that position
with the exact policy reason; do not conflate it with a Typed kernel refusal.
If all slots succeed but the final outstanding table is nonzero, return a distinct
final-settlement refusal with the complete canonical residual table.

Rollback is full pointwise ledger equality and complete capability-store equality
with the entry world. It is not zeroing only the touched balances. Every abort
publishes zero committed supply even if speculative steps minted another asset.
The public comparison retains exact commit/abort kind, label, schedule, complete
world/store, located reason/residuals and every committed receipt/output field.
It may omit internal aborted diagnostic traces; document that projection precisely.

## Transient settlement with a cash correspondence

A clearing lane is a trusted triple `(domain, asset, vaultPrincipal)`, denoting
one ordinary typed vault balance cell. Require unique `(domain, asset)` lanes,
which also excludes duplicate physical clearing cells. Two different vaults for
the same domain/asset are rejected in this bounded policy rather than silently
splitting one economic obligation across ambiguous lanes.

A policy also supplies a duplicate-free finite participant order. Preflight
requires every principal in the branches' trusted local boundaries to occur in
that list. This supplies a canonical full obligation table and prevents forgetting
a participant at settlement. Extra unused participants have zero entries. All
lane, asset and participant identities remain typed; no cross-asset or cross-domain
scalar netting is permitted.

The transient key is `(lane, authenticatedPrincipal)`. Initialize every entry to
zero. After an actual successful invocation by principal `p`, update each lane by

```text
owed'(lane, p) = owed(lane, p) - actualReceipt.netEffect(lane.vaultCell)
owed'(lane, q) = owed(lane, q), for q ≠ p.
```

`netEffect` is the sum of the real evaluated receipt deltas at the exact typed
cell. It must be computed from the result of the existing executor, not from a
caller-provided amount, predicted effect, template name or a second world.
Repeated delta entries contribute their full sum. A no-op cannot erase a debt.
The participant is taken from the authenticated local boundary, never from an
invocation's optional claimed-actor field or a caller-supplied clearing key.

For every successful receipt, check zero supply for each configured lane's
`(domain, asset)` across the entire asset, not just at the vault cell. A lane-asset
mint elsewhere followed by a repayment must not manufacture settlement funds.
Supply changes in other assets remain possible under existing authority rules.
A violation causes a typed `laneSupply` abort at the actual local/global position,
recording lane and signed supply amount. This is an explicit checked policy
restriction, not a claim that all atomic transactions forbid supply changes.

The principal-partitioned obligations are signed and may be nonzero internally.
Positive entries mean net draw; negative entries mean net return/credit. Exact
zero is required at commit for every key. Over-return at the end therefore aborts
with its negative residual. A negative intermediate credit may be consumed by a
later authorized draw in the same event. There is no automatic forgiveness,
clamping, donation exception, tolerance or repayment reassignment to another
principal. Cross-principal repayment is outside this policy unless a later,
separately reviewed delegation rule gives it explicit semantics.

The key proof obligation, for every accepted speculative prefix and lane, is

```text
vaultCash(current, lane) + sum_p owed(lane, p) = vaultCash(entry, lane).
```

It follows directly from actual receipt effect application. This prevents the
transient table from being arbitrary metadata. Clearing every participant entry
implies the vault's exact initial cash is restored; a zero global sum is weaker
and must be rejected when one principal owes and another has an offsetting credit.
Ordinary spendable balances remain existing proof-carrying nonnegative States at
every internal step. Signed transient obligations do not relax insufficient-funds
checks or redefine a negative cash balance as valid.

This is a meaningful loan/return clearing instance. It does not yet model the full
Balancer Vault, arbitrary swaps, hook semantics, fees, credit limits, flash-credit
creation, rounded token transfers or deployed transient storage. A subsequent
pinned-source library/refinement change must decide which additional settlement
rules are needed and prove their correspondence. Do not mark that fidelity
roadmap item complete from this sprint.

## Proof architecture and reusable boundaries

Keep executable definitions before each `-- BEGIN PROOFS` marker.

| Proposed module | Responsibility and proof deliverable |
| --- | --- |
| `Atomic/Policy.lean` | Typed lanes/participants/keys, ordered policy checks, complete finite residual table, checked zero-supply policy and exact reasons |
| `Atomic/Execution.lean` | Isolated internal machine with original entry world, existing speculative Interleaving machine, transient table and global status; fail-fast replay and public commit/abort projection |
| `Atomic/Soundness.lean` | Inductive actual internal reachability; actual call witnesses; same-world receipt derivation; prefix correspondence to Interleaving until abort; no suffix after first abort |
| `Atomic/Settlement.lean` | Receipt effect bridge, obligation update identity, lane cash-plus-obligation invariant, complete zero-table characterization and restored clearing cash on commit |
| `Atomic/Preservation.lean` | Full rollback identity; committed accounting with aborted contribution zero; actual authorization and fixed store; nonnegativity; actual/analyzed write frames; supported predicates |
| `Atomic/Observation.lean` | Public committed observation, exact abort/commit sensitivity, no aborted history publication, success agreement with existing interleaving projection where appropriate |
| `Atomic/Examples.lean`, `Tests.lean` | Independent exact full worlds/stores, complete receipts/typed outputs, exact local/global failures and full residual tables |
| `Atomic/Audit.lean`, `Verify.lean` | Unique nonempty runtime inventory and imported theorem/supplemental axiom audit |

Use actual invocation outcomes, not an unrelated supplied list of valid receipts,
for every invariant. Reuse `Composition.executeStep_sound`, StepSound accounting,
locality and authority, Interleaving branch-local index/history lemmas, and the
existing analyzed footprints. A small new bridge may relate a StepSound receipt's
net effect at one cell to its actual post-balance; place it in the new namespace
rather than changing an old theorem.

There are two valid implementation routes for internal replay. Prefer an atomic
fold that calls the existing `Interleaving.advance`, then inspects only its actual
new attempt and applies the clearing update, with a proved one-new-attempt lemma
for active complete slots. If that creates unnecessary list-tail plumbing, use
an atomic step calling `Composition.executeStep` directly and prove one-step
correspondence to `Interleaving.advance`. The latter duplicates only orchestration,
never the financial evaluator or its authority checks. Planning reviewers must
select and freeze one route before implementation.

The all-success bridge must require actual completion and policy acceptance, then
show the committed world and internal financial observations match the supplied
interleaving schedule. The opposite direction needs both successful underlying
execution and the explicit clearing condition. A plain interleaving success with
unpaid transient debt must not imply atomic commit.

Generic conditional invariant preservation can reuse the Sprint 7 initialized
R/G rule on accepted speculative prefixes. The public macro rule then has two
cases: commit uses the proved internal invariant; abort returns the initialized
world. Do not require every internal step to satisfy final settlement: the
transient invariant includes the outstanding obligations, and final zero is a
commit-only condition.

Typed globally named lanes and component/port identities instantiate the useful
interface discipline. Prove any binding reindex result only for a bijective
renaming of policy keys and the corresponding data, including all observations
and errors; defer this theorem if it obscures the core atomic milestone. Do not
claim general behavioral associativity, arbitrary n-ary synchronization, or an
embedding of all historical integer ledger models. Those are separate roadmap
obligations even if the design uses lessons from Interface/Nary.

## Proposed OpenSpec acceptance scenarios

Use four bounded capabilities: `atomic-admission`, `atomic-execution`,
`atomic-settlement-preservation`, and `atomic-regression-evidence`.

| ID | Concrete trigger and required observation or theorem |
| --- | --- |
| A01 | Valid two-branch event admits the whole schedule, including overlapping funded writes; malformed suffix refuses before any speculation |
| A02 | Duplicate lane, alternate vault for the same domain/asset, duplicate participant, and uncovered authenticated principal each have a distinct exact policy refusal |
| A03 | Missing/excess tokens and invalid catalog/branch/policy combinations follow the specified preflight precedence and preserve the full entry world |
| A04 | Empty branches and a valid empty schedule commit identity; distinguish this control from nonempty meaningful transient-settlement fixtures |
| A05 | A funded two-step event commits one event with complete independent final ledger/store, receipts, output snapshots and local/global indices |
| A06 | First or middle kernel refusal aborts globally, restores every entry-world cell and store entry, emits no committed receipts/outputs and skips the entire remaining peer/suffix |
| A07 | A successful speculative mint in an unconfigured asset followed by a refusal publishes zero committed supply and the original asset balances |
| A08 | Actual attempts use the current speculative world; a stale-entry-world mutant is discriminated by independently expected receipt values |
| A09 | Own snapshots remain fixed, peer-only history is refused beside a funded same-unit control, and same-key branch histories retain distinct values |
| A10 | Shifting global position preserves branch-local principal/time; live/revoked and authorized/unauthorized siblings have exact outcomes |
| A11 | Draw7 from vault USD10, then return7 by the same principal commits; internal owed7 is observed only in the diagnostic/proof layer; final vault10 and owed0 are proved |
| A12 | Draw7 then return6 aborts with residual+1 and entry vault10; draw7 then return8 aborts with residual−1, with independent funding for the excess return |
| A13 | A principal draws7 and another returns7: global lane sum zero but participant entries+7/−7 cause exact settlement refusal |
| A14 | USD debt cannot cancel share credit; equal numeric amounts in different domains or lanes remain separate; every key in the canonical table is checked |
| A15 | Lane-asset mint into a nonvault cell triggers exact laneSupply rejection, while independently authorized nonlane-asset supply beside a fully cleared lane commits |
| A16 | Repeated receipt deltas and zero-effect operations update obligations by the actual net effect; a no-op cannot clear debt |
| A17 | General actual-prefix proof establishes vault cash plus participant obligations equals entry cash; cleared commit restores every configured vault cash cell |
| A18 | Generic commit/abort accounting, point-of-use authority, complete fixed-store identity and proof-carrying nonnegativity are established with premises recorded |
| A19 | Actual/analyzed write frames preserve supported collateral; a changed-cell predicate with falsely claimed empty support has a concrete counterexample |
| A20 | All-success fully settled execution corresponds to its actual supplied interleaving schedule; an unpaid successful interleaving has no automatic atomic-commit conclusion |
| A21 | Commit/abort comparisons detect every public receipt/output/failure/residual/store/ledger field beside equal controls; aborted tentative data never enters public prior history |
| A22 | Identical actions under distinct schedules may commit versus abort; no unrestricted atomic commutation or common-prestate claim is inferred |
| A23 | Nonempty unique named runtime/proof inventories, full independent expected outputs and typed malformed-input controls execute on the frozen candidate |
| A24 | Real production mutants and actual CLI fail/block controls discriminate rollback, publication, settlement derivation, principal/asset qualification and authority errors |
| A25 | Fresh full build, imported axiom audit, all legacy regressions, preserved historical bytes, native result reviews and source/artifact integrity checks pass before delivery/archive |

A11–A16 must use at least one real nonzero clearing lane and nonzero intermediate
obligation. An empty lane set may be an explicit ordinary atomic-batch mode, but
its controls cannot count as evidence that transient settlement works.

## Implementation order for the parent proposal

- [ ] Freeze the concrete OpenSpec design, all normative scenarios and mutation
  targets; independently obtain passing GPT-6 and native Fable planning verdicts
  bound to the same candidate. Run a current accepted Sprint 7 baseline first.
- [ ] Implement policy and complete preflight with exact positive/negative fixtures
  A01–A04. Tests distinguish each reason, not only generic rejection.
- [ ] Implement speculative fail-fast execution and public result projection.
  Run A05–A10 and prove exact full rollback before adding settlement claims.
- [ ] Implement receipt-derived obligations and lane-supply checks. Establish the
  local effect bridge and cash/obligation induction before A11–A17 can pass.
- [ ] Add macro accounting/authority/frames and committed observation laws;
  instantiate A18–A22 with real successful and failed prefixes.
- [ ] Build production source mutation and CLI-control evidence, source projections,
  complete named inventories and supplemental axiom coverage for A23–A24.
- [ ] Freeze implementation, run all new/legacy gates and native Grok/Fable audits,
  resolve blockers with targeted reruns, then update roadmap/wiki and deliver/archive.

Proposed production mutants include retaining prefix after abort; global failure
continuing a peer; publishing tentative outputs; counting aborted mint as committed
supply; stale-world evaluation; peer-history lookup; global-index boundary lookup;
zeroing pending debt without a receipt; using the opposite vault-effect sign;
checking only total pending sum; collapsing principal/asset keys; omitting one
lane/participant from final clearance; accepting lane supply; resurrecting revoked
grants; and dropping an exact abort/residual observation field. Each requires an
independent designated false oracle and a protected successful sibling. Final
count and exact source edit anchors must be fixed by the planning candidate,
not retroactively selected after observing survivors.

Expected verification commands are the established `lake build`, new Atomic
Audit/Verify drivers, fresh Interleaving and legacy audit/regression drivers,
strict validation of the one new OpenSpec change, and source-bound Python
mutation/control runs into fresh external directories. Record actual command
arrays, timestamps, exits, source/tool/model identities and artifact hashes.
Compiler failures, missing imports and unavailable reviewers remain blocked or
open evidence; none counts as a financial counterexample or approval.

## Draft self-review

The chosen semantics separates public atomicity from internal ordering, cash
nonnegativity from signed transient obligations, and generic preservation from
reference fidelity. Every required clearing value has an actual receipt origin;
participant partition and lane supply checks close cancellation/minted-repayment
loopholes. Excess-return behavior and error precedence are explicit. Prior
capability/store assumptions are retained, not silently strengthened into
provenance guarantees. The useful historical interface discipline is applied
without relabeling old algebraic results as operational associativity.

This draft recommends a bounded atomic settlement kernel increment. Claims,
asynchronous compensation/finality, arbitrary operational associativity, capability
provenance, complete Balancer modeling and external fidelity remain separate
roadmap work. The parent should select the internal replay route, finalize exact
OpenSpec requirements/tasks and obtain the planning gate before implementation.

--- END FILE wiki-llm/sprint-8-atomic-synchronization-draft.md ---

--- BEGIN FILE review/semantic-kernel/sprint8/planning/coverage.json ---
{
  "status": "planning candidate before independent gate",
  "capabilities": 4,
  "requirements": 16,
  "scenario_count": 49,
  "task_count": 40,
  "all_tasks_mapped": true,
  "files": {
    "openspec/changes/atomic-synchronization/proposal.md": "cbd243da58feacb093ae6299abd527cee8dfca616aafe435396a51545da3814e",
    "openspec/changes/atomic-synchronization/design.md": "17e1ce471c6d9a2f7d7f9aff549e01bafea086e0fb07e0fd9068e0c4c7897ef7",
    "openspec/changes/atomic-synchronization/tasks.md": "37ae0eab050e04e4f7a5c8de2bf0de3d8c21c3ec4f23bbc49587e2d35026ff6f",
    "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md": "b97d905b3c6f602d35d22227985dd5cbef0f7349db3ff9624cbc6fb2ff384af3",
    "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md": "52a51cda9fd4eac618945f231cebd0f5afda08c871f77289d7cff02a4c8509f0",
    "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md": "0296c5c274bdc3bdac6dcdebb970a8bae92734adfb60b848e9185067ca7e1112",
    "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md": "b2f3653431534a0eb435bfff914c7d95dddc9a922d4b3f2183d7af3c034b0f1b"
  },
  "scenarios": [
    {
      "id": "A01",
      "capability": "atomic-execution",
      "requirement": "Ordered complete admission",
      "scenario": "Shared funded admission",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 11,
      "tasks": [
        "2.1",
        "2.2",
        "2.3",
        "3.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A02",
      "capability": "atomic-execution",
      "requirement": "Ordered complete admission",
      "scenario": "Malformed unreachable suffix",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 16,
      "tasks": [
        "2.1",
        "2.2",
        "2.3",
        "3.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A03",
      "capability": "atomic-execution",
      "requirement": "Ordered complete admission",
      "scenario": "Policy and count precedence",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 21,
      "tasks": [
        "2.1",
        "2.2",
        "2.3",
        "3.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A04",
      "capability": "atomic-execution",
      "requirement": "Ordered complete admission",
      "scenario": "Empty and malformed schedules",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 26,
      "tasks": [
        "2.1",
        "2.2",
        "2.3",
        "3.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A05",
      "capability": "atomic-execution",
      "requirement": "One speculative world and local histories",
      "scenario": "Live state after peer movement",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 35,
      "tasks": [
        "3.2",
        "6.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A06",
      "capability": "atomic-execution",
      "requirement": "One speculative world and local histories",
      "scenario": "Captured local snapshots",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 40,
      "tasks": [
        "3.2",
        "6.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A07",
      "capability": "atomic-execution",
      "requirement": "One speculative world and local histories",
      "scenario": "Peer-only output refusal",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 45,
      "tasks": [
        "3.2",
        "6.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A08",
      "capability": "atomic-execution",
      "requirement": "One speculative world and local histories",
      "scenario": "Local principal and time",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 50,
      "tasks": [
        "3.2",
        "6.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A09",
      "capability": "atomic-execution",
      "requirement": "First failure aborts the whole event",
      "scenario": "Immediate failure stops peer",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 59,
      "tasks": [
        "3.3",
        "4.1",
        "5.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A10",
      "capability": "atomic-execution",
      "requirement": "First failure aborts the whole event",
      "scenario": "Middle failure restores prefix",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 64,
      "tasks": [
        "3.3",
        "4.1",
        "5.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A11",
      "capability": "atomic-execution",
      "requirement": "First failure aborts the whole event",
      "scenario": "Policy failure diagnostics",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 69,
      "tasks": [
        "3.3",
        "4.1",
        "5.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A12",
      "capability": "atomic-execution",
      "requirement": "Committed publication and exact observations",
      "scenario": "Committed event",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 78,
      "tasks": [
        "3.4",
        "3.5",
        "6.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A13",
      "capability": "atomic-execution",
      "requirement": "Committed publication and exact observations",
      "scenario": "Aborted mint and history",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 83,
      "tasks": [
        "3.4",
        "3.5",
        "6.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A14",
      "capability": "atomic-execution",
      "requirement": "Committed publication and exact observations",
      "scenario": "Observation field sensitivity",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 88,
      "tasks": [
        "3.4",
        "3.5",
        "6.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A15",
      "capability": "atomic-execution",
      "requirement": "Committed publication and exact observations",
      "scenario": "Order-sensitive outcome",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-execution/spec.md",
      "line": 93,
      "tasks": [
        "3.4",
        "3.5",
        "6.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A16",
      "capability": "atomic-preservation",
      "requirement": "Actual trace and stop soundness",
      "scenario": "Actual-prefix witness",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 11,
      "tasks": [
        "4.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A17",
      "capability": "atomic-preservation",
      "requirement": "Actual trace and stop soundness",
      "scenario": "Global stop theorem",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 16,
      "tasks": [
        "4.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A18",
      "capability": "atomic-preservation",
      "requirement": "Actual trace and stop soundness",
      "scenario": "Complete exhaustion",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 21,
      "tasks": [
        "4.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A19",
      "capability": "atomic-preservation",
      "requirement": "Cash and obligations conserve",
      "scenario": "Generic cash correspondence",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 30,
      "tasks": [
        "4.4",
        "4.5",
        "4.6"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A20",
      "capability": "atomic-preservation",
      "requirement": "Cash and obligations conserve",
      "scenario": "Commit restores clearing cash",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 35,
      "tasks": [
        "4.4",
        "4.5",
        "4.6"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A21",
      "capability": "atomic-preservation",
      "requirement": "Cash and obligations conserve",
      "scenario": "Scalar netting counterexample",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 40,
      "tasks": [
        "4.4",
        "4.5",
        "4.6"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A22",
      "capability": "atomic-preservation",
      "requirement": "Public financial preservation",
      "scenario": "Generic rollback",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 49,
      "tasks": [
        "5.1",
        "5.2",
        "5.3"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A23",
      "capability": "atomic-preservation",
      "requirement": "Public financial preservation",
      "scenario": "Committed accounting and authority",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 54,
      "tasks": [
        "5.1",
        "5.2",
        "5.3"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A24",
      "capability": "atomic-preservation",
      "requirement": "Public financial preservation",
      "scenario": "Protected collateral and support necessity",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 59,
      "tasks": [
        "5.1",
        "5.2",
        "5.3"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A25",
      "capability": "atomic-preservation",
      "requirement": "Conditional correspondence and invariant lifting",
      "scenario": "Successful correspondence",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 68,
      "tasks": [
        "5.4",
        "5.5"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A26",
      "capability": "atomic-preservation",
      "requirement": "Conditional correspondence and invariant lifting",
      "scenario": "Settlement premise is necessary",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 73,
      "tasks": [
        "5.4",
        "5.5"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A27",
      "capability": "atomic-preservation",
      "requirement": "Conditional correspondence and invariant lifting",
      "scenario": "Initialized macro invariant",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-preservation/spec.md",
      "line": 78,
      "tasks": [
        "5.4",
        "5.5"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A28",
      "capability": "atomic-regression-evidence",
      "requirement": "Independent nonempty financial inventory",
      "scenario": "Exact financial controls",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md",
      "line": 11,
      "tasks": [
        "6.1",
        "6.2",
        "6.3"
      ],
      "planned_evidence": [
        "actual source-bound CLI/build/mutation/control/review/delivery artifacts according to mapped tasks"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A29",
      "capability": "atomic-regression-evidence",
      "requirement": "Independent nonempty financial inventory",
      "scenario": "Imported proof inventory",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md",
      "line": 16,
      "tasks": [
        "6.1",
        "6.2",
        "6.3"
      ],
      "planned_evidence": [
        "actual source-bound CLI/build/mutation/control/review/delivery artifacts according to mapped tasks"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A30",
      "capability": "atomic-regression-evidence",
      "requirement": "Eighteen live production mutations",
      "scenario": "Mutation discrimination",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md",
      "line": 25,
      "tasks": [
        "7.1",
        "7.2",
        "7.3",
        "7.4",
        "7.6"
      ],
      "planned_evidence": [
        "actual source-bound CLI/build/mutation/control/review/delivery artifacts according to mapped tasks"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A31",
      "capability": "atomic-regression-evidence",
      "requirement": "Eighteen live production mutations",
      "scenario": "Detection qualification",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md",
      "line": 30,
      "tasks": [
        "7.1",
        "7.2",
        "7.3",
        "7.4",
        "7.6"
      ],
      "planned_evidence": [
        "actual source-bound CLI/build/mutation/control/review/delivery artifacts according to mapped tasks"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A32",
      "capability": "atomic-regression-evidence",
      "requirement": "Defensive runner and current regressions",
      "scenario": "Runner controls",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md",
      "line": 39,
      "tasks": [
        "7.5",
        "7.6",
        "8.1",
        "8.2"
      ],
      "planned_evidence": [
        "actual source-bound CLI/build/mutation/control/review/delivery artifacts according to mapped tasks"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A33",
      "capability": "atomic-regression-evidence",
      "requirement": "Defensive runner and current regressions",
      "scenario": "Frozen source and artifacts",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md",
      "line": 44,
      "tasks": [
        "7.5",
        "7.6",
        "8.1",
        "8.2"
      ],
      "planned_evidence": [
        "actual source-bound CLI/build/mutation/control/review/delivery artifacts according to mapped tasks"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A34",
      "capability": "atomic-regression-evidence",
      "requirement": "Defensive runner and current regressions",
      "scenario": "Legacy preservation",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md",
      "line": 49,
      "tasks": [
        "7.5",
        "7.6",
        "8.1",
        "8.2"
      ],
      "planned_evidence": [
        "actual source-bound CLI/build/mutation/control/review/delivery artifacts according to mapped tasks"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A35",
      "capability": "atomic-regression-evidence",
      "requirement": "Independent gated delivery",
      "scenario": "Same-candidate planning gate",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md",
      "line": 58,
      "tasks": [
        "1.1",
        "1.2",
        "1.3",
        "8.3",
        "8.4",
        "9.1",
        "9.2",
        "9.3",
        "9.4"
      ],
      "planned_evidence": [
        "actual source-bound CLI/build/mutation/control/review/delivery artifacts according to mapped tasks"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A36",
      "capability": "atomic-regression-evidence",
      "requirement": "Independent gated delivery",
      "scenario": "Unavailable review",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md",
      "line": 63,
      "tasks": [
        "1.1",
        "1.2",
        "1.3",
        "8.3",
        "8.4",
        "9.1",
        "9.2",
        "9.3",
        "9.4"
      ],
      "planned_evidence": [
        "actual source-bound CLI/build/mutation/control/review/delivery artifacts according to mapped tasks"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A37",
      "capability": "atomic-regression-evidence",
      "requirement": "Independent gated delivery",
      "scenario": "Accepted delivery",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-regression-evidence/spec.md",
      "line": 68,
      "tasks": [
        "1.1",
        "1.2",
        "1.3",
        "8.3",
        "8.4",
        "9.1",
        "9.2",
        "9.3",
        "9.4"
      ],
      "planned_evidence": [
        "actual source-bound CLI/build/mutation/control/review/delivery artifacts according to mapped tasks"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A38",
      "capability": "atomic-settlement",
      "requirement": "Complete typed policy",
      "scenario": "Ambiguous lane rejection",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 11,
      "tasks": [
        "2.1",
        "2.2",
        "2.4"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A39",
      "capability": "atomic-settlement",
      "requirement": "Complete typed policy",
      "scenario": "Participant completeness",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 16,
      "tasks": [
        "2.1",
        "2.2",
        "2.4"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A40",
      "capability": "atomic-settlement",
      "requirement": "Complete typed policy",
      "scenario": "Nonempty settlement evidence",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 21,
      "tasks": [
        "2.1",
        "2.2",
        "2.4"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A41",
      "capability": "atomic-settlement",
      "requirement": "Actual receipt origin",
      "scenario": "Draw and return",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 30,
      "tasks": [
        "4.2",
        "4.4",
        "4.6"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A42",
      "capability": "atomic-settlement",
      "requirement": "Actual receipt origin",
      "scenario": "Repeated deltas and no-op",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 35,
      "tasks": [
        "4.2",
        "4.4",
        "4.6"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A43",
      "capability": "atomic-settlement",
      "requirement": "Actual receipt origin",
      "scenario": "Intermediate credit",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 40,
      "tasks": [
        "4.2",
        "4.4",
        "4.6"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values",
        "named generic Lean theorem with exact premises and imported axiom audit"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A44",
      "capability": "atomic-settlement",
      "requirement": "Qualified final clearance",
      "scenario": "Under and over return",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 49,
      "tasks": [
        "4.5",
        "4.6"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A45",
      "capability": "atomic-settlement",
      "requirement": "Qualified final clearance",
      "scenario": "Cross-principal cancellation",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 54,
      "tasks": [
        "4.5",
        "4.6"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A46",
      "capability": "atomic-settlement",
      "requirement": "Qualified final clearance",
      "scenario": "Cross-asset and domain separation",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 59,
      "tasks": [
        "4.5",
        "4.6"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A47",
      "capability": "atomic-settlement",
      "requirement": "Qualified final clearance",
      "scenario": "Last lane or participant residual",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 64,
      "tasks": [
        "4.5",
        "4.6"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A48",
      "capability": "atomic-settlement",
      "requirement": "Lane supply policy",
      "scenario": "Nonvault lane mint",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 73,
      "tasks": [
        "4.3",
        "6.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    },
    {
      "id": "A49",
      "capability": "atomic-settlement",
      "requirement": "Lane supply policy",
      "scenario": "Nonlane supply success",
      "path": "openspec/changes/atomic-synchronization/specs/atomic-settlement/spec.md",
      "line": 78,
      "tasks": [
        "4.3",
        "6.1"
      ],
      "planned_evidence": [
        "actual named runtime checks with independent expected values"
      ],
      "status": "planned; no implementation claimed"
    }
  ]
}

--- END FILE review/semantic-kernel/sprint8/planning/coverage.json ---

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

--- BEGIN FILE lean/DefiKernel/Interleaving/Schedule.lean ---
import DefiKernel.Parallel.Compatibility

/-! Complete finite schedules and ordered structural admission. Overlapping footprints are
admitted here; compatibility remains a separate premise for disjoint recovery. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

abbrev Schedule := List BranchId

structure ScheduleMismatch where
  expectedLeft : Nat
  observedLeft : Nat
  expectedRight : Nat
  observedRight : Nat
  deriving DecidableEq, Repr

def checkSchedule (leftLength rightLength : Nat) (schedule : Schedule) :
    Except ScheduleMismatch (PUnit : Type) :=
  if schedule.count .left = leftLength ∧ schedule.count .right = rightLength then .ok ⟨⟩
  else .error ⟨leftLength, schedule.count .left, rightLength, schedule.count .right⟩

def Complete {P A D : Type} (left right : Branch P A D) (schedule : Schedule) : Prop :=
  schedule.count .left = left.length ∧ schedule.count .right = right.length

inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : Parallel.LocalFailure)
  | schedule (mismatch : ScheduleMismatch)
  deriving DecidableEq, Repr

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) :
    Except (AdmissionFailure P A D) (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← (checkSchedule left.length right.length schedule).mapError .schedule
  return (lf, rf)

-- BEGIN PROOFS

theorem checkSchedule_ok_iff (leftLength rightLength : Nat) (schedule : Schedule) :
    checkSchedule leftLength rightLength schedule = .ok ⟨⟩ ↔
      schedule.count .left = leftLength ∧ schedule.count .right = rightLength := by
  simp [checkSchedule]

theorem checkSchedule_error_iff (leftLength rightLength : Nat) (schedule : Schedule)
    (mismatch : ScheduleMismatch) :
    checkSchedule leftLength rightLength schedule = .error mismatch ↔
      ¬ (schedule.count .left = leftLength ∧ schedule.count .right = rightLength) ∧
      mismatch = ⟨leftLength, schedule.count .left, rightLength, schedule.count .right⟩ := by
  by_cases h : schedule.count .left = leftLength ∧ schedule.count .right = rightLength
  · simp [checkSchedule, h]
  · simp only [checkSchedule, h, if_false, Except.error.injEq, not_false_eq_true, true_and]
    exact eq_comm

theorem count_sum_length (schedule : Schedule) :
    schedule.count .left + schedule.count .right = schedule.length := by
  induction schedule with
  | nil => rfl
  | cons branch schedule ih =>
    cases branch <;> simp at * <;> omega

theorem count_append (branch : BranchId) (first second : Schedule) :
    (first ++ second).count branch = first.count branch + second.count branch :=
  List.count_append

theorem count_left_cons (schedule : Schedule) :
    (BranchId.left :: schedule).count .left = schedule.count .left + 1 := by simp

theorem count_right_cons (schedule : Schedule) :
    (BranchId.right :: schedule).count .right = schedule.count .right + 1 := by simp

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.length {left right : Branch P A D} {schedule : Schedule}
    (h : Complete left right schedule) : schedule.length = left.length + right.length := by
  rw [← count_sum_length, h.1, h.2]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_empty_iff (schedule : Schedule) :
    Complete ([] : Branch P A D) [] schedule ↔ schedule = [] := by
  constructor
  · intro h
    exact List.length_eq_zero_iff.mp h.length
  · rintro rfl
    exact ⟨rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_left_cons_iff (inv : Invocation P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    Complete (inv :: left) right (.left :: schedule) ↔ Complete left right schedule := by
  simp [Complete]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_right_cons_iff (inv : Invocation P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    Complete left (inv :: right) (.right :: schedule) ↔ Complete left right schedule := by
  simp [Complete]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.prefix_counts {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ suffix)) :
    preTokens.count .left ≤ left.length ∧ preTokens.count .right ≤ right.length := by
  obtain ⟨hl, hr⟩ := h
  simp only [List.count_append] at hl hr
  omega

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.left_slot {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ .left :: suffix)) :
    preTokens.count .left < left.length := by
  have hl := h.1
  simp only [List.count_append, List.count_cons_self] at hl
  omega

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.right_slot {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ .right :: suffix)) :
    preTokens.count .right < right.length := by
  have hr := h.2
  simp only [List.count_append, List.count_cons_self] at hr
  omega

theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧ Complete left right schedule := by
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
    (checkSchedule_ok_iff _ _ _).mp (unmap _ _ _ hc)⟩

theorem admit_of_checks (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (hs : Complete left right schedule) :
    admit cfg boundaries left right schedule = .ok (lf, rf) := by
  simp [admit, hv, hl, hr, checkSchedule, hs.1, hs.2, Except.mapError,
    bind, Except.bind, pure, Except.pure]

theorem admit_of_parallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf))
    (hs : Complete left right schedule) :
    admit cfg boundaries left right schedule = .ok (lf, rf) := by
  obtain ⟨hv, hl, hr, _⟩ := Parallel.admit_ok cfg boundaries left right lf rf hp
  exact admit_of_checks cfg boundaries left right schedule lf rf hv hl hr hs

theorem admit_left_member (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf))
    (n : Nat) (inv : Invocation P A D) (hi : left[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries .left n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ lf.reads) ∧ (∀ c ∈ part.writes, c ∈ lf.writes) := by
  have hl := (admit_ok cfg boundaries left right schedule lf rf h).2.1
  simpa using analyzeBranchFrom_member cfg (boundaries .left) 0 left lf hl n inv hi

theorem admit_right_member (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf))
    (n : Nat) (inv : Invocation P A D) (hi : right[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries .right n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ rf.reads) ∧ (∀ c ∈ part.writes, c ∈ rf.writes) := by
  have hr := (admit_ok cfg boundaries left right schedule lf rf h).2.2.1
  simpa using analyzeBranchFrom_member cfg (boundaries .right) 0 right rf hr n inv hi

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Schedule.lean ---

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

--- BEGIN FILE lean/DefiKernel/Typed/Examples.lean ---
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

--- END FILE lean/DefiKernel/Typed/Examples.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/Examples.lean ---
import DefiKernel.Parallel.Execution
import DefiKernel.Typed.Examples

/-! Independent financial fixtures for binary parallel composition. Expected receipts and complete
ledger tables are written directly, without evaluating templates or selecting executor results. -/
namespace DefiKernel.Parallel.Examples
open Typed Composition Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev W := World Party Asset Domain
abbrev I := Invocation Party Asset Domain
abbrev B := Branch Party Asset Domain
abbrev Evt := EventObservation Party Asset Domain
abbrev Obs := BranchObservation Party Asset Domain
abbrev R := Parallel.Result Party Asset Domain

def aliceUSD : C := (.main, .alice, .usd)
def bobUSD : C := (.main, .bob, .usd)
def vaultUSD : C := (.main, .vault, .usd)
def poolUSD : C := (.main, .pool, .usd)
def vaultShare : C := (.main, .vault, .share)
def aliceShare : C := (.main, .alice, .share)
def protectedCell : C := (.main, .alice, .collateral)
def cells : List C := [Domain.main, .other].flatMap fun d ↦
  [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
    [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)
def cellRef (c : C) : CellRef Party Asset Domain c.2.2 := ⟨c.1, .literal c.2.1⟩
def packed (c : C) : PackedCellRef Party Asset Domain := ⟨c.2.2, cellRef c⟩

/-- Both numerical ports are zero, but their components differ. The provider grants exact
access to every cell so access checks cannot mask the intended compatibility controls. -/
def config (lt rt : Op) (lo ro : List C := []) : Config Party Asset Domain where
  registry id := if id = ⟨10⟩ then some lt else if id = ⟨11⟩ then some rt else none
  domainAdmin := domainAdmin
  catalog := [
    ⟨⟨0⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨2⟩, ⟨n⟩⟩, c, true⟩),
      [⟨⟨10⟩, lt.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨n + 10⟩, u⟩),
        lo.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c⟩)⟩]⟩,
    ⟨⟨1⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨2⟩, ⟨n⟩⟩, c, true⟩),
      [⟨⟨11⟩, rt.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨n + 10⟩, u⟩),
        ro.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c⟩)⟩]⟩,
    ⟨⟨2⟩, [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c, true⟩), [], []⟩]

def transferTemplate (a : Asset) (sender recipient : PartyRef Party) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := nonnegative a (.arg .here)
  deltas := [⟨a, ref a sender, negate a (.arg .here)⟩,
    ⟨a, ref a recipient, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef a sender, packedRef a recipient]
def usdTransfer := transferTemplate .usd (.literal .alice) (.literal .bob)
def shareTransfer := transferTemplate .share (.literal .vault) (.literal .alice)
def peerUSDTransfer := transferTemplate .usd (.literal .vault) (.literal .pool)
def cfg := config usdTransfer shareTransfer [bobUSD] [aliceShare]
def sameAssetCfg := config usdTransfer peerUSDTransfer [bobUSD] [poolUSD]

def store : Store := ⟨[
  ⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .debit aliceUSD⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .debit vaultShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .debit vaultUSD⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .changeSupply .main .usd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.bob, .main, ⟨10⟩, .invoke⟩, true⟩,
  ⟨⟨.bob, .main, ⟨10⟩, .debit bobUSD⟩, true⟩,
  ⟨⟨.vault, .main, ⟨11⟩, .invoke⟩, true⟩,
  ⟨⟨.vault, .main, ⟨11⟩, .debit vaultShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .debit vaultUSD⟩, true⟩]⟩
def caps : List CapabilityId := (List.range 12).map CapabilityId.mk

def balanceTable (au bu vs ash : ℚ) (vu : ℚ := 20) (pu : ℚ := 1) : C → ℚ := fun c ↦
  if c = aliceUSD then au else if c = bobUSD then bu else if c = vaultShare then vs
  else if c = aliceShare then ash else if c = vaultUSD then vu else if c = poolUSD then pu
  else if c = protectedCell then 9 else 0

def initial : W := ⟨⟨balanceTable 10 0 20 0, by
  intro c
  simp only [balanceTable]
  repeat' split
  all_goals decide⟩, store⟩
def boundaries (_ : BranchId) (_ : Nat) : Boundary Party Asset Domain :=
  ⟨aliceContext, fresh, 100⟩

def invoke (component op : Nat) (a : Asset) (q : ℚ) : I :=
  ⟨⟨component⟩, ⟨op⟩, [], [.literal ⟨.amount a, q⟩], caps, none⟩
def usd (q : ℚ) := invoke 0 10 .usd q
def shares (q : ℚ) := invoke 1 11 .share q
def peerUSD (q : ℚ) := invoke 1 11 .usd q

def source (inv : I) (component : Nat) : I :=
  { inv with inputs := [.priorOutput 0 ⟨⟨component⟩, ⟨0⟩⟩] }

def output (index component : Nat) (a : Asset) (q : ℚ) : OutputObservation Asset :=
  ⟨index, ⟨⟨component⟩, ⟨0⟩⟩, ⟨.amount a, q⟩⟩

def evaluatedTransfer (sender recipient : C) (q : ℚ) : Evaluated Party Asset Domain :=
  ⟨true, [(sender, -q), (recipient, q)], [], [], [], [], [], [sender, recipient]⟩
def event (index : Nat) (inv : I) (args : List (PackedValue Asset))
    (evaluated : Evaluated Party Asset Domain) (outputs : List (OutputObservation Asset)) : Evt :=
  ⟨index, .invoke inv,
    .invoked ⟨inv.operation, inv.parties, args, inv.capabilityIds, inv.claimedActor⟩ evaluated,
    outputs⟩
def transferEvent (index : Nat) (inv : I) (sender recipient : C) (q : ℚ)
    (outputs : List (OutputObservation Asset)) : Evt :=
  event index inv [⟨.amount sender.2.2, q⟩] (evaluatedTransfer sender recipient q) outputs

def observed (events : List Evt)
    (failure : Option (LocatedFailure Party Asset Domain) := none) : Obs :=
  ⟨events, events.flatMap EventObservation.outputs, events.length, failure⟩
def failure (index : Nat) (inv : I) (reason : Composition.Failure) :
    Option (LocatedFailure Party Asset Domain) := some ⟨index, some (.invoke inv), reason⟩
def leftEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (usd q) aliceUSD bobUSD q [output index 0 .usd after]
def rightEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (shares q) vaultShare aliceShare q [output index 1 .share after]
def peerEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (peerUSD q) vaultUSD poolUSD q [output index 1 .usd after]

def matchesExpected (actual : R) (balance : C → ℚ) (expectedLeft expectedRight : Obs)
    (expectedStore : Store := store) : Bool :=
  match actual with
  | .refused _ _ => false
  | .executed result =>
    decide ((∀ c, result.world.state.balance c = balance c) ∧
      result.world.capabilities = expectedStore ∧
      result.left.world.capabilities = expectedStore ∧
      result.right.world.capabilities = expectedStore ∧
      observeBranch result.left = expectedLeft ∧ observeBranch result.right = expectedRight)

def basicLeft : Obs := observed [leftEvent 0 3 3]
def basicRight : Obs := observed [rightEvent 0 4 4]

def supplyTemplate (a : Asset) (owner : Party) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, ref a (.literal owner), .arg .here⟩]
  supplyDeltas := [⟨.main, a, .arg .here⟩]
  stateReads := []
  envReads := []
  writes := [packedRef a (.literal owner)]
def supplyCfg := config (supplyTemplate .usd .alice) (supplyTemplate .share .vault)
  [aliceUSD] [vaultShare]
def supplyEvent (index : Nat) (inv : I) (cell : C) (q post : ℚ) : Evt :=
  event index inv [⟨.amount cell.2.2, q⟩]
    ⟨true, [(cell, q)], [((cell.1, cell.2.2), q)], [], [], [], [], [cell]⟩
    [output index inv.component.value cell.2.2 post]

def statefulTransfer : Op := { usdTransfer with
  guard := .binary (.le (.amount .usd)) (.lit 4) (.balance (cellRef aliceUSD))
  deltas := [⟨.usd, cellRef aliceUSD, .binary (.scale (.amount Asset.usd))
    (.lit (-1 / 2 : ℚ)) (.balance (cellRef aliceUSD))⟩,
    ⟨.usd, cellRef bobUSD, .binary (.scale (.amount Asset.usd))
      (.lit (1 / 2 : ℚ)) (.balance (cellRef aliceUSD))⟩]
  stateReads := [packed aliceUSD] }
def statefulCfg := config statefulTransfer shareTransfer [bobUSD] [aliceShare]
def statefulEvent (index : Nat) (amount post : ℚ) : Evt :=
  event index (usd 0) [⟨.amount .usd, 0⟩]
    { evaluatedTransfer aliceUSD bobUSD amount with
      requiredStateReads := [aliceUSD, aliceUSD, aliceUSD]
      declaredStateReads := [aliceUSD] }
    [output index 0 .usd post]

/-- State-dependent mint amount appears independently in both delta and supply evaluation. -/
def statefulSupply : Op := { supplyTemplate .share .vault with
  deltas := [⟨.share, cellRef vaultShare,
    .binary (.scale (.amount Asset.share)) (.lit (1 / 2 : ℚ)) (.balance (cellRef vaultShare))⟩]
  supplyDeltas := [⟨.main, .share,
    .binary (.scale (.amount Asset.share)) (.lit (1 / 2 : ℚ)) (.balance (cellRef vaultShare))⟩]
  stateReads := [packed vaultShare] }
def statefulSupplyEvent (index : Nat) (amount post : ℚ) : Evt :=
  event index (shares 0) [⟨.amount .share, 0⟩]
    ⟨true, [(vaultShare, amount)], [((.main, .share), amount)],
      [vaultShare, vaultShare], [], [vaultShare], [], [vaultShare]⟩
    [output index 1 .share post]

/-- Temporal values constrain the trusted invocation boundary; they do not set a price. -/
def timedTemplate (a : Asset) : Op where
  signature := [.amount a, .scalar]
  domain := .main
  partyArity := 1
  guard := .binary (.eq .scalar) .now (.arg (.there .here))
  deltas := [⟨a, ref a .caller, negate a (.arg .here)⟩,
    ⟨a, ref a (.argument 0), .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := [.currentTime]
  writes := [packedRef a .caller, packedRef a (.argument 0)]
def timedCfg := config (timedTemplate .usd) (timedTemplate .share) [bobUSD] [aliceShare]
def timedBoundaries (branch : BranchId) (index : Nat) : Boundary Party Asset Domain :=
  match branch with
  | .left => ⟨⟨if index = 0 then .alice else .bob, .main⟩, fresh, 100 + index⟩
  | .right => ⟨⟨.vault, .main⟩, fresh, 200 + index⟩
def timedInvocation (component op : Nat) (a : Asset) (q time : ℚ) (recipient : Party) : I :=
  ⟨⟨component⟩, ⟨op⟩, [recipient],
    [.literal ⟨.amount a, q⟩, .literal ⟨.scalar, time⟩], caps, none⟩
def timedLeft : B := [timedInvocation 0 10 .usd 3 100 .bob,
  timedInvocation 0 10 .usd 1 101 .alice]
def timedRight : B := [timedInvocation 1 11 .share 4 200 .alice,
  timedInvocation 1 11 .share 2 201 .alice]
def timedEvent (index : Nat) (inv : I) (sender recipient : C) (q time post : ℚ) : Evt :=
  event index inv [⟨.amount sender.2.2, q⟩, ⟨.scalar, time⟩]
    { evaluatedTransfer sender recipient q with
      requiredEnvReads := [.currentTime], declaredEnvReads := [.currentTime] }
    [output index inv.component.value sender.2.2 post]
def timedExpectedLeft := observed [
  timedEvent 0 (timedInvocation 0 10 .usd 3 100 .bob) aliceUSD bobUSD 3 100 3,
  timedEvent 1 (timedInvocation 0 10 .usd 1 101 .alice) bobUSD aliceUSD 1 101 2]
def timedExpectedRight := observed [
  timedEvent 0 (timedInvocation 1 11 .share 4 200 .alice) vaultShare aliceShare 4 200 4,
  timedEvent 1 (timedInvocation 1 11 .share 2 201 .alice) vaultShare aliceShare 2 201 6]


def noOp : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := []
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := []
def noOpInvocation : I := { usd 0 with inputs := [] }
def noOpEvaluated : Evaluated Party Asset Domain := ⟨true, [], [], [], [], [], [], []⟩
def sharedReadCfg := config noOp noOp [protectedCell] []
def sharedReadExpected := observed [event 0 noOpInvocation [] noOpEvaluated
  [output 0 0 .collateral 9]]
def paramTemplate : Op := { transferTemplate .usd (.argument 0) (.argument 1) with
  partyArity := 2 }
def reusableCfg := config paramTemplate shareTransfer

def revokedStore : Store := ⟨store.entries.set 2 ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, false⟩⟩
def revokedInitial : W := ⟨initial.state, revokedStore⟩

def cancelling : Op := { noOp with
  deltas := [⟨.usd, cellRef aliceUSD, .lit 1⟩, ⟨.usd, cellRef aliceUSD, .lit (-1)⟩] }
def cancellingInvocation : I := { shares 0 with inputs := [] }
def cancellingExpected : Obs := observed [event 0 cancellingInvocation []
  ⟨true, [(aliceUSD, 1), (aliceUSD, -1)], [], [], [], [], [], []⟩ []]

end DefiKernel.Parallel.Examples

--- END FILE lean/DefiKernel/Parallel/Examples.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/ScheduleTests.lean ---
import DefiKernel.Interleaving.Schedule
import DefiKernel.Parallel.Examples

/-! Exact schedule mismatch and ordered admission controls. Financial execution controls ensure
the accepted overlap example is funded and authorized; admission itself performs no transfer. -/
namespace DefiKernel.Interleaving.ScheduleTests
open Typed Composition Parallel Typed.Examples Parallel.Examples

def accepted {E X : Type} (result : Except E X) : Bool :=
  match result with
  | .ok _ => true
  | .error _ => false

def refused (actual : Except (Interleaving.AdmissionFailure Party Asset Domain)
    (Footprint Party Asset Domain × Footprint Party Asset Domain))
    (expected : Interleaving.AdmissionFailure Party Asset Domain) : Bool :=
  match actual with
  | .error reason => decide (reason = expected)
  | .ok _ => false

def unknown : I := { usd 0 with operation := ⟨99⟩ }
def invalidCfg : Config Party Asset Domain := { cfg with catalog := cfg.catalog ++ cfg.catalog }

def checks : List (String × Bool) := [
  ("interleaving.schedule.balanced", accepted (checkSchedule 2 2 [.left, .right, .left, .right])),
  ("interleaving.schedule.block-left", accepted (checkSchedule 2 2 [.left, .left, .right, .right])),
  ("interleaving.schedule.block-right", accepted
    (checkSchedule 2 2 [.right, .right, .left, .left])),
  ("interleaving.schedule.empty", accepted (checkSchedule 0 0 [])),
  ("interleaving.schedule.empty-left", accepted (checkSchedule 0 2 [.right, .right])),
  ("interleaving.schedule.empty-right", accepted (checkSchedule 2 0 [.left, .left])),
  ("interleaving.schedule.missing-right", decide
    (checkSchedule 2 2 [.left, .right, .left] = .error ⟨2, 2, 2, 1⟩)),
  ("interleaving.schedule.missing-left", decide
    (checkSchedule 2 2 [.right, .left, .right] = .error ⟨2, 1, 2, 2⟩)),
  ("interleaving.schedule.excess-left", decide
    (checkSchedule 1 1 [.left, .right, .left] = .error ⟨1, 2, 1, 1⟩)),
  ("interleaving.schedule.excess-right", decide
    (checkSchedule 1 1 [.right, .left, .right] = .error ⟨1, 1, 1, 2⟩)),
  ("interleaving.schedule.empty-extra-left", decide
    (checkSchedule 0 0 [.left] = .error ⟨0, 1, 0, 0⟩)),
  ("interleaving.schedule.empty-extra-right", decide
    (checkSchedule 0 0 [.right] = .error ⟨0, 0, 0, 1⟩)),
  ("interleaving.schedule.both-wrong-counts", decide
    (checkSchedule 1 2 [.left, .left] = .error ⟨1, 2, 2, 0⟩)),
  ("interleaving.schedule.disjoint-admitted", accepted
    (Interleaving.admit cfg boundaries [usd 3] [shares 4] [.right, .left])),
  ("interleaving.schedule.overlap-admitted", accepted
    (Interleaving.admit cfg boundaries [usd 3] [usd 4] [.left, .right])),
  ("interleaving.schedule.overlap-left-funded", accepted
    (executeStep cfg (boundaries .left 0) 0 [] (.invoke (usd 3)) initial)),
  ("interleaving.schedule.overlap-right-funded", accepted
    (executeStep cfg (boundaries .right 0) 0 [] (.invoke (usd 4)) initial)),
  ("interleaving.schedule.unreachable-left-suffix", refused
    (Interleaving.admit cfg boundaries [usd 11, unknown] [shares 4] [.left, .right, .left])
    (.structural .left ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.unreachable-right-suffix", refused
    (Interleaving.admit cfg boundaries [usd 3] [shares 21, unknown] [.right, .left, .right])
    (.structural .right ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.precedence-configuration", refused
    (Interleaving.admit invalidCfg boundaries [unknown] [unknown] []) .configuration),
  ("interleaving.schedule.precedence-left", refused
    (Interleaving.admit cfg boundaries [usd 3, unknown] [unknown] [])
    (.structural .left ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.precedence-right", refused
    (Interleaving.admit cfg boundaries [usd 3] [shares 4, unknown] [])
    (.structural .right ⟨1, .interface .unknownOperation⟩)),
  ("interleaving.schedule.precedence-counts", refused
    (Interleaving.admit cfg boundaries [usd 3] [shares 4] []) (.schedule ⟨1, 0, 1, 0⟩)),
  ("interleaving.schedule.empty-admitted", accepted
    (Interleaving.admit cfg boundaries [] [] []))]

end DefiKernel.Interleaving.ScheduleTests

--- END FILE lean/DefiKernel/Interleaving/ScheduleTests.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Execution.lean ---
import DefiKernel.Interleaving.Schedule
import DefiKernel.Parallel.Observation
import DefiKernel.Parallel.Execution

/-! Finite replay over one evolving world. Local histories and permanent refusals stay separate;
consumed static slots advance even when a failed suffix produces no further attempt. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

structure LocalState (P A D : Type) where
  consumed : Nat := 0
  events : List (Event P A D) := []
  outputs : List (OutputObservation A) := []
  nextIndex : Nat := 0
  failure : Option (LocatedFailure P A D) := none

structure Attempt (P A D : Type) where
  branch : BranchId
  index : Nat
  invocation : Invocation P A D
  before : World P A D
  outcome : Except Composition.Failure (StepResult P A D)

structure Machine (P A D : Type) where
  world : World P A D
  left : LocalState P A D := {}
  right : LocalState P A D := {}
  attempts : List (Attempt P A D) := []

inductive Result (P A D : Type) where
  | refused (reason : Interleaving.AdmissionFailure P A D) (world : World P A D)
      (schedule : Schedule)
  | executed (schedule : Schedule) (machine : Machine P A D)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def Machine.local (m : Machine P A D) : BranchId → LocalState P A D
  | .left => m.left
  | .right => m.right

def Machine.setLocal (m : Machine P A D) (b : BranchId)
    (localState : LocalState P A D) : Machine P A D :=
  match b with
  | .left => { m with left := localState }
  | .right => { m with right := localState }

def selectBranch (left right : Branch P A D) : BranchId → Branch P A D
  | .left => left
  | .right => right

def start (initial : World P A D) : Machine P A D := ⟨initial, {}, {}, []⟩

/-- The new public projection owns every preserved field, including exact located failure. -/
def LocalState.observe (localState : LocalState P A D) : BranchObservation P A D :=
  ⟨localState.events.map observeEvent, localState.outputs,
    localState.nextIndex, localState.failure⟩

def LocalState.toCursor (localState : LocalState P A D) (world : World P A D) : Cursor P A D :=
  ⟨world, localState.events, localState.outputs, localState.nextIndex, localState.failure⟩

def Attempt.supply (attempt : Attempt P A D) (d : D) (a : A) : ℚ :=
  match attempt.outcome with
  | .error _ => 0
  | .ok result => result.receipt.supply d a

/-- Executable aggregation of actual successful attempts; refusals contribute zero. -/
def Machine.supply (m : Machine P A D) (d : D) (a : A) : ℚ :=
  (m.attempts.map (fun attempt ↦ attempt.supply d a)).sum

def Attempt.writes (attempt : Attempt P A D) : List (Cell P A D) :=
  match attempt.outcome with
  | .error _ => []
  | .ok result => result.receipt.writes

def Machine.writes (m : Machine P A D) : List (Cell P A D) :=
  m.attempts.flatMap Attempt.writes

def Machine.skip (m : Machine P A D) (b : BranchId) : Machine P A D :=
  m.setLocal b { m.local b with consumed := (m.local b).consumed + 1 }

def Machine.refuse (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure) : Machine P A D :=
  let own := m.local b
  let stopped : LocalState P A D := { own with
    consumed := own.consumed + 1
    failure := some ⟨own.nextIndex, some (.invoke inv), reason⟩ }
  let updated := m.setLocal b stopped
  { updated with attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .error reason⟩] }

def Machine.accept (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D) : Machine P A D :=
  let own := m.local b
  let advanced : LocalState P A D := ⟨own.consumed + 1,
    own.events ++ [⟨own.nextIndex, .invoke inv, m.world, result⟩],
    own.outputs ++ result.outputs, own.nextIndex + 1, none⟩
  let updated := m.setLocal b advanced
  { updated with world := result.world, attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .ok result⟩] }

variable [Fintype P] [Fintype A] [Fintype D]

/-- Advance exactly one static branch slot, preserving the peer's local state. -/
def advance (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) : Machine P A D :=
  let own := m.local b
  match own.failure with
  | some _ => m.skip b
  | none =>
    match (selectBranch left right b)[own.consumed]? with
    | none => m.skip b
    | some inv =>
      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs
        (.invoke inv) m.world
      match outcome with
      | .error reason => m.refuse b inv reason
      | .ok result => m.accept b inv result

def continueRun (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule) : Machine P A D :=
  schedule.foldl (advance cfg boundaries left right) m

def runPrefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) : Machine P A D :=
  continueRun cfg boundaries left right (start initial) schedule

def runInterleaving (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    Interleaving.Result P A D :=
  match Interleaving.admit cfg boundaries left right schedule with
  | .error reason => .refused reason initial schedule
  | .ok _ => .executed schedule (runPrefix cfg boundaries initial left right schedule)

/-- Exact financial fields, without raw foreign event worlds or global scheduling order. -/
def ProjectedEquivalent (m : Machine P A D) (joined : Parallel.Joined P A D) : Prop :=
  Parallel.WorldEquivalent m.world joined.world ∧
    m.left.observe = observeBranch joined.left ∧ m.right.observe = observeBranch joined.right

def observationsEqual (left right : Interleaving.Result P A D) : Bool :=
  match left, right with
  | .refused lr lw _, .refused rr rw _ => decide (lr = rr) && Parallel.worldEq lw rw
  | .executed _ l, .executed _ r => Parallel.worldEq l.world r.world &&
      decide (l.left.observe = r.left.observe) && decide (l.right.observe = r.right.observe)
  | _, _ => false

def matchesParallel (result : Interleaving.Result P A D) (parallel : Parallel.Result P A D) :
    Bool :=
  match result, parallel with
  | .executed _ m, .executed joined => Parallel.worldEq m.world joined.world &&
      decide (m.left.observe = observeBranch joined.left) &&
      decide (m.right.observe = observeBranch joined.right)
  | _, _ => false

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem local_setLocal (m : Machine P A D) (b : BranchId) (l : LocalState P A D) :
    (m.setLocal b l).local b = l := by cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem setLocal_world (m : Machine P A D) (b : BranchId) (l : LocalState P A D) :
    (m.setLocal b l).world = m.world := by cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_toCursor (l : LocalState P A D) (w : World P A D) :
    observeBranch (l.toCursor w) = l.observe := rfl

theorem continueRun_append (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (s t : Schedule) :
    continueRun cfg boundaries left right m (s ++ t) =
      continueRun cfg boundaries left right (continueRun cfg boundaries left right m s) t :=
  List.foldl_append

theorem matchesParallel_iff (schedule : Schedule) (m : Machine P A D)
    (joined : Parallel.Joined P A D) :
    matchesParallel (.executed schedule m) (.executed joined) = true ↔
      ProjectedEquivalent m joined := by
  simp [matchesParallel, ProjectedEquivalent, Parallel.worldEq, Parallel.WorldEquivalent, and_assoc]

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Execution.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Examples.lean ---
import DefiKernel.Interleaving.Execution
import DefiKernel.Parallel.Examples

/-! Exact rational development fixtures. Expected ledgers, receipts and outputs are direct tables;
none is extracted from `runInterleaving`. These fixtures make no deployed-protocol fidelity claim.
-/
namespace DefiKernel.Interleaving.Examples
open Typed Composition Parallel Typed.Examples Parallel.Examples

abbrev R := Interleaving.Result Party Asset Domain
abbrev M := Machine Party Asset Domain

def matchesExpected (actual : R) (balance : C → ℚ) (left right : Obs)
    (consumedLeft consumedRight : Nat) (expectedStore : Store := store) : Bool :=
  match actual with
  | .refused _ _ _ => false
  | .executed _ m => decide ((∀ c, m.world.state.balance c = balance c) ∧
      m.world.capabilities = expectedStore ∧ m.left.observe = left ∧ m.right.observe = right ∧
      m.left.consumed = consumedLeft ∧ m.right.consumed = consumedRight)

def admissionRefused (actual : R) (reason : Interleaving.AdmissionFailure Party Asset Domain)
    (schedule : Schedule) (expected : W := initial) : Bool :=
  match actual with
  | .refused r w s => decide (r = reason ∧ s = schedule) && worldEq w expected
  | .executed _ _ => false

def sharedBalance (alice bob vault : ℚ) : C → ℚ := fun c ↦
  if c = aliceUSD then alice else if c = bobUSD then bob else if c = vaultUSD then vault
  else if c = protectedCell then 9 else 0

def sharedInitial : W := ⟨⟨sharedBalance 0 0 10, by
  intro c
  simp only [sharedBalance]
  repeat' split
  all_goals decide⟩, store⟩
def sharedCfg := config (transferTemplate .usd (.literal .vault) (.literal .alice))
  (transferTemplate .usd (.literal .vault) (.literal .bob)) [aliceUSD] [bobUSD]
def sharedLeft : B := [usd 7]
def sharedRight : B := [peerUSD 6]
def sharedLR := runInterleaving sharedCfg boundaries sharedInitial sharedLeft sharedRight
  [.left, .right]
def sharedRL := runInterleaving sharedCfg boundaries sharedInitial sharedLeft sharedRight
  [.right, .left]
def withdrawalLeft := observed [transferEvent 0 (usd 7) vaultUSD aliceUSD 7 [output 0 0 .usd 7]]
def withdrawalRight := observed
  [transferEvent 0 (peerUSD 6) vaultUSD bobUSD 6 [output 0 1 .usd 6]]

def replenishInitial : W := ⟨⟨sharedBalance 10 0 0, by
  intro c
  simp only [sharedBalance]
  repeat' split
  all_goals decide⟩, store⟩
def replenishCfg := config (transferTemplate .usd (.literal .alice) (.literal .vault))
  (transferTemplate .usd (.literal .vault) (.literal .bob)) [vaultUSD] [bobUSD]
def depositExpected := observed [transferEvent 0 (usd 7) aliceUSD vaultUSD 7 [output 0 0 .usd 7]]
def replenishLR := runInterleaving replenishCfg boundaries replenishInitial [usd 7]
  [peerUSD 6, peerUSD 1] [.left, .right, .right]
def replenishRL := runInterleaving replenishCfg boundaries replenishInitial [usd 7]
  [peerUSD 6, peerUSD 1] [.right, .left, .right]

/-- Both branches invoke component 0, so the fully qualified output key is identical. -/
def snapshotCfg := config usdTransfer shareTransfer [bobUSD] [aliceShare]
def snapshotConsumer := source (usd 0) 0
def snapshotRun := runInterleaving snapshotCfg boundaries initial
  [usd 3, snapshotConsumer] [usd 1] [.left, .right, .left]
def snapshotLeft := observed [leftEvent 0 3 3,
  transferEvent 1 snapshotConsumer aliceUSD bobUSD 3 [output 1 0 .usd 7]]
def snapshotRight := observed [leftEvent 0 1 4]

/-- The peer transfers four dollars into Alice's balance between the two live reads. -/
def liveCfg := config statefulTransfer
  (transferTemplate .usd (.literal .vault) (.literal .alice)) [bobUSD] [aliceUSD]
def liveRun := runInterleaving liveCfg boundaries initial [usd 0, usd 0] [peerUSD 4]
  [.left, .right, .left]
def liveLeft := observed [statefulEvent 0 5 5, statefulEvent 1 (9 / 2) (19 / 2)]
def liveRight := observed [transferEvent 0 (peerUSD 4) vaultUSD aliceUSD 4 [output 0 1 .usd 9]]

def peerOnly := source (usd 0) 1
def peerOnlyRun := runInterleaving sameAssetCfg boundaries initial [usd 3, peerOnly]
  [peerUSD 4] [.left, .right, .left]
def peerOnlyLeft := observed [leftEvent 0 3 3]
  (failure 1 peerOnly (.interface .unavailableOutput))
def peerOnlyRight := observed [peerEvent 0 4 5]

def immediateRun := runInterleaving cfg boundaries initial [usd 11, usd 1]
  [shares 4, shares 2] [.left, .right, .left, .right]
def middleRun := runInterleaving cfg boundaries initial [usd 3, usd 8, usd 1]
  [shares 4, shares 2] [.left, .right, .left, .right, .left]
def dualRun := runInterleaving cfg boundaries initial [usd 3, usd 8, usd 1]
  [shares 4, shares 17, shares 1] [.left, .right, .left, .right, .left, .right]
def middleLeft := observed [leftEvent 0 3 3]
  (failure 1 (usd 8) (.kernel .insufficientFunds))
def continuedRight := observed [rightEvent 0 4 4, rightEvent 1 2 6]

def supplyRun := runInterleaving supplyCfg boundaries initial [usd 2, usd (-13), usd 1]
  [shares (-3)] [.left, .right, .left, .left]
def supplyLeft := observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
  (failure 1 (usd (-13)) (.kernel .insufficientFunds))
def supplyRight := observed [supplyEvent 0 (shares (-3)) vaultShare (-3) 17]

def schedules : List (String × Schedule) := [
  ("llrr", [.left, .left, .right, .right]), ("lrlr", [.left, .right, .left, .right]),
  ("lrrl", [.left, .right, .right, .left]), ("rllr", [.right, .left, .left, .right]),
  ("rlrl", [.right, .left, .right, .left]), ("rrll", [.right, .right, .left, .left])]
def disjointLeft : B := [usd 3, usd 2]
def disjointRight : B := [shares 4, shares 2]
def disjointLeftExpected := observed [leftEvent 0 3 3, leftEvent 1 2 5]

/-- Directly supplied attempt oracles include all pre/post cells and the entire capability store. -/
structure ExpectedAttempt where
  branch : BranchId
  index : Nat
  invocation : I
  before : C → ℚ
  after : C → ℚ
  outcome : Except Composition.Failure Evt

def attemptMatches (actual : Attempt Party Asset Domain) (expected : ExpectedAttempt) : Bool :=
  decide (actual.branch = expected.branch ∧ actual.index = expected.index ∧
    actual.invocation = expected.invocation ∧
    (∀ c, actual.before.state.balance c = expected.before c) ∧
    actual.before.capabilities = store) &&
  match actual.outcome, expected.outcome with
  | .error actualReason, .error expectedReason => decide (actualReason = expectedReason)
  | .ok result, .ok event => decide
      ((∀ c, result.world.state.balance c = expected.after c) ∧
        result.world.capabilities = store ∧ result.receipt = event.receipt ∧
        result.outputs = event.outputs)
  | _, _ => false

def attemptsMatch (actual : R) (expected : List ExpectedAttempt) : Bool :=
  match actual with
  | .refused _ _ _ => false
  | .executed _ m => m.attempts.length == expected.length &&
      (m.attempts.zip expected).all fun (a, e) ↦ attemptMatches a e

def sharedLRAttempts : List ExpectedAttempt := [
  ⟨.left, 0, usd 7, sharedBalance 0 0 10, sharedBalance 7 0 3,
    .ok (transferEvent 0 (usd 7) vaultUSD aliceUSD 7 [output 0 0 .usd 7])⟩,
  ⟨.right, 0, peerUSD 6, sharedBalance 7 0 3, sharedBalance 7 0 3,
    .error (.kernel .insufficientFunds)⟩]
def replenishRLAttempts : List ExpectedAttempt := [
  ⟨.right, 0, peerUSD 6, sharedBalance 10 0 0, sharedBalance 10 0 0,
    .error (.kernel .insufficientFunds)⟩,
  ⟨.left, 0, usd 7, sharedBalance 10 0 0, sharedBalance 3 0 7,
    .ok (transferEvent 0 (usd 7) aliceUSD vaultUSD 7 [output 0 0 .usd 7])⟩]

end DefiKernel.Interleaving.Examples

--- END FILE lean/DefiKernel/Interleaving/Examples.lean ---

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

--- BEGIN FILE lean/DefiKernel/Composition/Examples.lean ---
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

--- END FILE lean/DefiKernel/Composition/Examples.lean ---

--- BEGIN FILE lean/DefiKernel/Parallel/ObservationTests.lean ---
import DefiKernel.Parallel.Execution
import DefiKernel.Composition.Examples

namespace DefiKernel.Parallel.ObservationTests
open Typed Typed.Examples Composition Composition.Examples

def emptyCursor : Cursor Party Asset Domain := startCursor cfg initialWorld

def refusal (index : Nat) (reason : Failure) : Cursor Party Asset Domain :=
  { emptyCursor with failure := some ⟨index, none, reason⟩ }

def invocation : Invocation Party Asset Domain :=
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd, 3⟩], allCapabilityIds, none⟩

def request : Request Party Asset Domain :=
  ⟨transferId, [.bob], [⟨.amount .usd, 3⟩], allCapabilityIds, none⟩

def evaluated : Evaluated Party Asset Domain :=
  ⟨true, [(aliceUsd, -3), (bobUsd, 3)], [], [], [], [], [], [aliceUsd, bobUsd]⟩

def output : OutputObservation Asset := ⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩

def event : Event Party Asset Domain :=
  ⟨0, .invoke invocation, initialWorld, ⟨initialWorld, .invoked request evaluated, [output]⟩⟩

def changedWorld : World Party Asset Domain := ⟨transferred, expectedStore⟩

def receiptChanges : List (String × Receipt Party Asset Domain) := [
  ("kind", .issued ⟨0⟩),
  ("request", .invoked { request with claimedActor := some .bob } evaluated),
  ("guard", .invoked request { evaluated with guard := false }),
  ("deltas", .invoked request { evaluated with deltas := [(aliceUsd, -4), (bobUsd, 4)] }),
  ("supplies", .invoked request { evaluated with supplies := [((.main, .usd), 1)] }),
  ("required-state", .invoked request { evaluated with requiredStateReads := [aliceUsd] }),
  ("required-env", .invoked request { evaluated with requiredEnvReads := [.currentTime] }),
  ("declared-state", .invoked request { evaluated with declaredStateReads := [aliceUsd] }),
  ("declared-env", .invoked request { evaluated with declaredEnvReads := [.currentTime] }),
  ("writes", .invoked request { evaluated with writes := [aliceUsd] })]

def checks : List (String × Bool) := [
  ("parallel.observe.empty", decide (observeBranch emptyCursor = ⟨[], [], 0, none⟩)),
  ("parallel.observe.refusal-reason", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch (refusal 0 (.kernel .insufficientFunds)))),
  ("parallel.observe.refusal-index", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch (refusal 1 (.kernel .guard)))),
  ("parallel.observe.refusal-step", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch { emptyCursor with failure := some ⟨0, some (.invoke invocation),
        .kernel .guard⟩ })),
  ("parallel.observe.local-index", decide
    (observeBranch emptyCursor ≠ observeBranch { emptyCursor with nextIndex := 1 })),
  ("parallel.observe.history", decide
    (observeBranch emptyCursor ≠ observeBranch { emptyCursor with outputs := [output] })),
  ("parallel.observe.event-index", decide
    (observeEvent event ≠ observeEvent { event with index := 1 })),
  ("parallel.observe.event-step", decide
    (observeEvent event ≠ observeEvent { event with step :=
      (.invoke { invocation with parties := [.vault] }) })),
  ("parallel.observe.event-outputs", decide
    (observeEvent event ≠ observeEvent
      { event with result := { event.result with outputs := [] } })),
  ("parallel.observe.output-unit", decide
    (observeEvent event ≠ observeEvent { event with result := { event.result with
      outputs := [{ output with value := ⟨.amount .share, 7⟩ }] } })),
  ("parallel.observe.output-value", decide
    (observeEvent event ≠ observeEvent { event with result := { event.result with
      outputs := [{ output with value := ⟨.amount .usd, 8⟩ }] } })),
  ("parallel.observe.raw-world-context", decide
    (observeEvent event = observeEvent { event with
      before := changedWorld
      result := { event.result with world := changedWorld } })),
  ("parallel.observe.final-ledger", !(worldEq initialWorld changedWorld)),
  ("parallel.observe.final-store", !(worldEq initialWorld
    { initialWorld with capabilities := ⟨[]⟩ }))] ++
  receiptChanges.map fun (label, receipt) ↦
    ("parallel.observe.receipt." ++ label, decide
      (observeEvent event ≠ observeEvent { event with result := { event.result with receipt } }))

end DefiKernel.Parallel.ObservationTests

--- END FILE lean/DefiKernel/Parallel/ObservationTests.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Tests.lean ---
import DefiKernel.Interleaving.Examples
import DefiKernel.Parallel.ObservationTests

/-! Named finite comparisons use direct complete expectations. They are bounded evidence. -/
namespace DefiKernel.Interleaving.Tests
open Typed Composition Parallel Typed.Examples Parallel.Examples Interleaving.Examples
private def expected (actual : Interleaving.Result Party Asset Domain) (balance : C → ℚ)
    (left right : Obs) (lc rc : Nat) (s : Store := store) : Bool :=
  Interleaving.Examples.matchesExpected actual balance left right lc rc s

def observationEvent : Event Party Asset Domain := Parallel.ObservationTests.event
def observationMachine : M := ⟨initial,
  ⟨1, [observationEvent], observationEvent.result.outputs, 1, none⟩, {}, []⟩
def comparison (m : M) : Interleaving.Result Party Asset Domain := .executed [.left] m
def changedLeft (f : LocalState Party Asset Domain → LocalState Party Asset Domain) : M :=
  { observationMachine with left := f observationMachine.left }
def changedEvent (f : Event Party Asset Domain → Event Party Asset Domain) : M :=
  changedLeft fun l ↦ { l with events := [f observationEvent] }
def different (m : M) := !Interleaving.observationsEqual
  (comparison observationMachine) (comparison m)
def withFailure (n : Nat) (inv : I) (reason : Composition.Failure) :=
  changedLeft fun l ↦ {l with failure := failure n inv reason}
def compareFailures (n : Nat) (inv : I) (reason : Composition.Failure) :=
  !Interleaving.observationsEqual (comparison (withFailure 1 (usd 2) (.kernel .guard)))
    (comparison (withFailure n inv reason))
def changeOutput (out : OutputObservation Asset) :=
  different (changedEvent fun e ↦ {e with result := {e.result with outputs := [out]}})

def requestChanges : List (String × Request Party Asset Domain) := [
  ("operation", { Parallel.ObservationTests.request with operation := ⟨99⟩ }),
  ("parties", { Parallel.ObservationTests.request with parties := [.vault] }),
  ("arguments", { Parallel.ObservationTests.request with arguments := [⟨.amount .usd, 4⟩] }),
  ("capabilities", { Parallel.ObservationTests.request with capabilityIds := [] }),
  ("actor", { Parallel.ObservationTests.request with claimedActor := some .bob })]

def observationChecks : List (String × Bool) := [
  ("interleaving.observe.equal", Interleaving.observationsEqual
    (comparison observationMachine) (comparison observationMachine)),
  ("interleaving.observe.failure", different (withFailure 1 (usd 2) (.kernel .guard))),
  ("interleaving.observe.failure.reason", compareFailures 1 (usd 2) (.kernel .insufficientFunds)),
  ("interleaving.observe.failure.index", compareFailures 2 (usd 2) (.kernel .guard)),
  ("interleaving.observe.failure.step", compareFailures 1 (usd 3) (.kernel .guard)),
  ("interleaving.observe.failure.equal", !compareFailures 1 (usd 2) (.kernel .guard)),
  ("interleaving.observe.successful.index", different
    (changedLeft fun l ↦ {l with nextIndex := 2})),
  ("interleaving.observe.history", different (changedLeft fun l ↦ {l with outputs := []})),
  ("interleaving.observe.events", different (changedLeft fun l ↦ {l with events := []})),
  ("interleaving.observe.peer",
    different {observationMachine with right := observationMachine.left}),
  ("interleaving.observe.event.index", different (changedEvent fun e ↦ {e with index := 2})),
  ("interleaving.observe.event.step", different
    (changedEvent fun e ↦ {e with step := .invoke (usd 9)})),
  ("interleaving.observe.event.outputs", different (changedEvent fun e ↦
    {e with result := {e.result with outputs := []}})),
  ("interleaving.observe.output.unit", changeOutput ⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .share, 7⟩⟩),
  ("interleaving.observe.output.value", changeOutput ⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 8⟩⟩),
  ("interleaving.observe.output.producer", changeOutput ⟨2, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩),
  ("interleaving.observe.output.component", changeOutput ⟨0, ⟨⟨2⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩),
  ("interleaving.observe.output.port", changeOutput ⟨0, ⟨⟨0⟩, ⟨3⟩⟩, ⟨.amount .usd, 7⟩⟩),
  ("interleaving.observe.ledger", different {observationMachine with world := sharedInitial}),
  ("interleaving.observe.store", different {observationMachine with world := revokedInitial}),
  ("interleaving.observe.omitted.context", let altered := changedEvent fun e ↦
      { e with before := sharedInitial, result := { e.result with world := sharedInitial } }
    Interleaving.observationsEqual (comparison observationMachine)
      (.executed [.right] { altered with left := { altered.left with consumed := 9 } }))] ++
  Parallel.ObservationTests.receiptChanges.map fun (label, receipt) ↦
    ("interleaving.observe.receipt." ++ label.replace "-" ".",
      different (changedEvent fun e ↦ {e with result := {e.result with receipt}}))

def requestChecks : List (String × Bool) := requestChanges.map fun (label, request) ↦
  ("interleaving.observe.request." ++ label,
    different (changedEvent fun e ↦ { e with result :=
      { e.result with receipt := .invoked request Parallel.ObservationTests.evaluated } }))

def checks : List (String × Bool) := [
  ("interleaving.fixture.snapshot.both.own", expected
    (runInterleaving snapshotCfg boundaries initial [usd 2, snapshotConsumer]
      [usd 1, snapshotConsumer] [.left, .right, .left, .right])
    (balanceTable 2 8 20 0)
    (observed [leftEvent 0 2 2,
      transferEvent 1 snapshotConsumer aliceUSD bobUSD 2 [output 1 0 .usd 5]])
    (observed [leftEvent 0 1 3,
      transferEvent 1 snapshotConsumer aliceUSD bobUSD 3 [output 1 0 .usd 8]]) 2 2),
  ("interleaving.fixture.shared.lr", expected sharedLR (sharedBalance 7 0 3) withdrawalLeft
    (observed [] (failure 0 (peerUSD 6) (.kernel .insufficientFunds))) 1 1),
  ("interleaving.fixture.shared.rl", expected sharedRL (sharedBalance 0 6 4)
    (observed [] (failure 0 (usd 7) (.kernel .insufficientFunds))) withdrawalRight 1 1),
  ("interleaving.fixture.shared.order", !Interleaving.observationsEqual sharedLR sharedRL),
  ("interleaving.fixture.shared.attempts", attemptsMatch sharedLR sharedLRAttempts),
  ("interleaving.fixture.replenish.funded", expected replenishLR (sharedBalance 3 7 0)
    depositExpected (observed [
      transferEvent 0 (peerUSD 6) vaultUSD bobUSD 6 [output 0 1 .usd 6],
      transferEvent 1 (peerUSD 1) vaultUSD bobUSD 1 [output 1 1 .usd 7]]) 1 2),
  ("interleaving.fixture.replenish.halted", expected replenishRL (sharedBalance 3 0 7)
    depositExpected (observed [] (failure 0 (peerUSD 6) (.kernel .insufficientFunds))) 1 2),
  ("interleaving.fixture.replenish.attempts", attemptsMatch replenishRL replenishRLAttempts),
  ("interleaving.fixture.live.complete", expected liveRun
    (balanceTable (9 / 2) (19 / 2) 20 0 16 1) liveLeft liveRight 2 1),
  ("interleaving.fixture.snapshot.own", expected snapshotRun (balanceTable 3 7 20 0)
    snapshotLeft snapshotRight 2 1),
  ("interleaving.fixture.snapshot.distinct", match snapshotRun with
    | .refused _ _ _ => false
    | .executed _ m => decide (m.left.outputs.head? = some (output 0 0 .usd 3) ∧
        m.right.outputs.head? = some (output 0 0 .usd 4))),
  ("interleaving.fixture.history.peer.only", expected peerOnlyRun
    (balanceTable 7 3 20 0 16 5) peerOnlyLeft peerOnlyRight 2 1),
  ("interleaving.fixture.history.funded.literal", expected
    (runInterleaving sameAssetCfg boundaries initial [usd 3, usd 5] [peerUSD 4]
      [.left, .right, .left]) (balanceTable 2 8 20 0 16 5)
    (observed [leftEvent 0 3 3, leftEvent 1 5 8]) peerOnlyRight 2 1),
  ("interleaving.fixture.history.own", expected
    (runInterleaving sameAssetCfg boundaries initial [usd 3, snapshotConsumer] [peerUSD 4]
      [.left, .right, .left]) (balanceTable 4 6 20 0 16 5)
    (observed [leftEvent 0 3 3,
      transferEvent 1 snapshotConsumer aliceUSD bobUSD 3 [output 1 0 .usd 6]]) peerOnlyRight 2 1),
  ("interleaving.fixture.refusal.immediate", expected immediateRun (balanceTable 10 0 14 6)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) continuedRight 2 2),
  ("interleaving.fixture.refusal.middle", expected middleRun (balanceTable 7 3 14 6)
    middleLeft continuedRight 3 2),
  ("interleaving.fixture.refusal.dual", expected dualRun (balanceTable 7 3 16 4)
    middleLeft (observed [rightEvent 0 4 4]
      (failure 1 (shares 17) (.kernel .insufficientFunds))) 3 3),
  ("interleaving.fixture.refusal.skips", match immediateRun, middleRun, dualRun with
    | .executed _ i, .executed _ m, .executed _ d =>
      decide (i.attempts.length = 3 ∧ m.attempts.length = 4 ∧ d.attempts.length = 4)
    | _, _, _ => false),
  ("interleaving.fixture.empty.both", expected
    (runInterleaving cfg boundaries initial [] [] []) (balanceTable 10 0 20 0)
    (observed []) (observed []) 0 0),
  ("interleaving.fixture.empty.left", expected
    (runInterleaving cfg boundaries initial [] [shares 4] [.right]) (balanceTable 10 0 16 4)
    (observed []) basicRight 0 1),
  ("interleaving.fixture.empty.right", expected
    (runInterleaving cfg boundaries initial [usd 3] [] [.left]) (balanceTable 7 3 20 0)
    basicLeft (observed []) 1 0),
  ("interleaving.fixture.supply.complete", expected supplyRun (balanceTable 12 0 17 0)
    supplyLeft supplyRight 3 1),
  ("interleaving.fixture.supply.aggregate", match supplyRun with
    | .refused _ _ _ => false
    | .executed _ m => decide (∀ d a, m.supply d a =
        if d = .main ∧ a = .usd then 2 else if d = .main ∧ a = .share then -3 else 0)),
  ("interleaving.fixture.collateral.protected", match sharedLR, liveRun, supplyRun with
    | .executed _ a, .executed _ b, .executed _ c => decide
      (a.world.state.balance protectedCell = 9 ∧ b.world.state.balance protectedCell = 9 ∧
        c.world.state.balance protectedCell = 9)
    | _, _, _ => false),
  ("interleaving.fixture.boundary.local", expected
    (runInterleaving timedCfg timedBoundaries initial timedLeft timedRight
      [.right, .left, .left, .right]) (balanceTable 8 2 14 6)
    timedExpectedLeft timedExpectedRight 2 2),
  ("interleaving.fixture.capability.revoked", expected
    (runInterleaving cfg boundaries revokedInitial [usd 3] [shares 4] [.right, .left])
    (balanceTable 7 3 20 0) basicLeft
    (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) 1 1 revokedStore),
  ("interleaving.fixture.capability.live", expected
    (runInterleaving cfg boundaries initial [usd 3] [shares 4] [.right, .left])
    (balanceTable 7 3 16 4) basicLeft basicRight 1 1),
  ("interleaving.fixture.capability.unauthorized", let missing := {usd 3 with capabilityIds := []}
    expected (runInterleaving cfg boundaries initial [missing] [shares 4] [.left, .right])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 missing (.kernel .unauthorizedInvoke))) basicRight 1 1),
  ("interleaving.fixture.capability.debit", let missing := {usd 3 with capabilityIds := [⟨0⟩]}
    expected (runInterleaving cfg boundaries initial [missing] [shares 4] [.left, .right])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 missing (.kernel .unauthorizedDebit))) basicRight 1 1),
  ("interleaving.fixture.history.unit", let wrong :=
      {usd 3 with inputs := [.literal ⟨.amount .share, 3⟩]}
    expected (runInterleaving cfg boundaries initial [wrong] [shares 4] [.right, .left])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 wrong (.interface .inputUnit))) basicRight 1 1),
  ("interleaving.fixture.malformed.suffix", let bad := {usd 1 with operation := ⟨99⟩}
    Interleaving.Examples.admissionRefused
      (runInterleaving cfg boundaries initial [usd 11, bad] [shares 4] [.left, .right, .left])
      (.structural .left ⟨1, .interface .unknownOperation⟩) [.left, .right, .left]),
  ("interleaving.fixture.malformed.schedule", Interleaving.Examples.admissionRefused
    (runInterleaving cfg boundaries initial [usd 3] [shares 4] [.left])
    (.schedule ⟨1, 1, 1, 0⟩) [.left])
  ] ++ schedules.flatMap (fun (label, schedule) ↦
    let actual := runInterleaving cfg boundaries initial disjointLeft disjointRight schedule
    let refused := runInterleaving cfg boundaries initial [usd 3, usd 8] disjointRight schedule
    [("interleaving.fixture.disjoint." ++ label ++ ".complete", expected actual
        (balanceTable 5 5 14 6) disjointLeftExpected continuedRight 2 2),
     ("interleaving.fixture.disjoint." ++ label ++ ".parallel", matchesParallel actual
        (runParallel cfg boundaries initial disjointLeft disjointRight)),
     ("interleaving.fixture.disjoint." ++ label ++ ".refused.complete", expected refused
        (balanceTable 7 3 14 6) middleLeft continuedRight 2 2),
     ("interleaving.fixture.disjoint." ++ label ++ ".refused.parallel", matchesParallel refused
        (runParallel cfg boundaries initial [usd 3, usd 8] disjointRight))]) ++
  observationChecks ++ requestChecks

end DefiKernel.Interleaving.Tests

--- END FILE lean/DefiKernel/Interleaving/Tests.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Audit.lean ---
import DefiKernel.Interleaving.ScheduleTests
import DefiKernel.Interleaving.Tests

/-! Complete named runtime inventory. These are finite development comparisons, separate from
the generic theorems and the imported axiom audit in Verify.lean. -/
namespace DefiKernel.Interleaving.Audit

def checks : List (String × Bool) := ScheduleTests.checks ++ Tests.checks

def main : IO Unit := do
  let names := checks.map Prod.fst
  if checks.isEmpty || names.eraseDups.length != names.length then
    throw (IO.userError "BLOCKED: empty or duplicate interleaving inventory")
  for (name, passed) in checks do
    IO.println s!"{name}: {passed}"
  let failures := (checks.filter (fun row ↦ !row.2)).length
  if failures != 0 then
    throw (IO.userError s!"Interleaving runtime comparisons failed: {failures}")

#eval main

end DefiKernel.Interleaving.Audit

--- END FILE lean/DefiKernel/Interleaving/Audit.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Soundness.lean ---
import DefiKernel.Interleaving.Execution

/-! Reachability witnesses for actual attempts, including refused calls at their original
pre-world. The final world may subsequently change through successful peer invocations. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive AdvanceSound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) : Machine P A D → Prop
  | halted (failure : LocatedFailure P A D) (failed : (m.local b).failure = some failure) :
      AdvanceSound cfg boundaries left right m b (m.skip b)
  | exhausted (active : (m.local b).failure = none)
      (absent : (selectBranch left right b)[(m.local b).consumed]? = none) :
      AdvanceSound cfg boundaries left right m b (m.skip b)
  | refused (inv : Invocation P A D) (reason : Composition.Failure)
      (active : (m.local b).failure = none)
      (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv)
      (rejected : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world = .error reason) :
      AdvanceSound cfg boundaries left right m b (m.refuse b inv reason)
  | accepted (inv : Invocation P A D) (result : StepResult P A D)
      (active : (m.local b).failure = none)
      (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv)
      (executed : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world = .ok result) :
      AdvanceSound cfg boundaries left right m b (m.accept b inv result)

inductive Reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (initial : World P A D) : Machine P A D → Prop
  | start : Reachable cfg boundaries left right initial (Interleaving.start initial)
  | next {pre post : Machine P A D} (b : BranchId)
      (previous : Reachable cfg boundaries left right initial pre)
      (step : AdvanceSound cfg boundaries left right pre b post) :
      Reachable cfg boundaries left right initial post

def AttemptSound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (attempt : Attempt P A D) : Prop :=
  ∃ history, executeStep cfg (boundaries attempt.branch attempt.index) attempt.index history
    (.invoke attempt.invocation) attempt.before = attempt.outcome

-- BEGIN PROOFS

theorem advance_sound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) :
    AdvanceSound cfg boundaries left right m b (advance cfg boundaries left right m b) := by
  cases hf : (m.local b).failure with
  | some failure =>
    simpa [advance, hf] using AdvanceSound.halted (cfg := cfg) (boundaries := boundaries)
      (left := left) (right := right) (m := m) (b := b) failure hf
  | none =>
    cases hs : (selectBranch left right b)[(m.local b).consumed]? with
    | none =>
      simpa [advance, hf, hs] using AdvanceSound.exhausted (cfg := cfg)
        (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b) hf hs
    | some inv =>
      cases he : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
          (m.local b).outputs (.invoke inv) m.world with
      | error reason =>
        simpa [advance, hf, hs, he] using AdvanceSound.refused (cfg := cfg)
          (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b)
          inv reason hf hs he
      | ok result =>
        simpa [advance, hf, hs, he] using AdvanceSound.accepted (cfg := cfg)
          (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b)
          inv result hf hs he

theorem continueRun_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (initial : World P A D) (m : Machine P A D)
    (h : Reachable cfg boundaries left right initial m) (schedule : Schedule) :
    Reachable cfg boundaries left right initial
      (continueRun cfg boundaries left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact h
  | cons b tail ih =>
    exact ih _ (.next b h (advance_sound cfg boundaries left right m b))

theorem runPrefix_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    Reachable cfg boundaries left right initial
      (runPrefix cfg boundaries initial left right schedule) :=
  continueRun_reachable cfg boundaries left right initial (start initial) .start schedule

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem skip_world (m : Machine P A D) (b : BranchId) : (m.skip b).world = m.world := by
  cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem refuse_world (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure) : (m.refuse b inv reason).world = m.world := by
  cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem accept_world (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D) : (m.accept b inv result).world = result.world := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem skip_attempts (m : Machine P A D) (b : BranchId) :
    (m.skip b).attempts = m.attempts := by cases b <;> rfl

theorem AdvanceSound.store {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) :
    post.world.capabilities = m.world.capabilities := by
  cases h with
  | halted => rw [skip_world]
  | exhausted => rw [skip_world]
  | refused => rw [refuse_world]
  | accepted inv result active selected executed =>
    exact (executeStep_sound _ _ _ _ _ _ _ executed).invoke_preserves_capabilities

theorem Reachable.store {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    m.world.capabilities = initial.capabilities := by
  induction h with
  | start => rfl
  | next b previous step ih => exact step.store.trans ih

theorem AdvanceSound.attempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post)
    (previous : ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt) :
    ∀ attempt ∈ post.attempts, AttemptSound cfg boundaries attempt := by
  cases h with
  | halted => simpa [skip_attempts] using previous
  | exhausted => simpa [skip_attempts] using previous
  | refused inv reason active selected rejected =>
    intro attempt member
    simp only [Machine.refuse, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, rejected⟩
  | accepted inv result active selected executed =>
    intro attempt member
    simp only [Machine.accept, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, executed⟩

theorem Reachable.attempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt := by
  induction h with
  | start => simp [Interleaving.start]
  | next b previous step ih => exact step.attempts ih

theorem AdvanceSound.consumed {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (own : BranchId) :
    (post.local own).consumed =
      (m.local own).consumed + if b = own then 1 else 0 := by
  cases h <;> cases b <;> cases own <;>
    simp [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b own : BranchId) :
    ((advance cfg boundaries left right m b).local own).consumed =
      (m.local own).consumed + if b = own then 1 else 0 :=
  (advance_sound cfg boundaries left right m b).consumed own

theorem continueRun_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule) (b : BranchId) :
    ((continueRun cfg boundaries left right m schedule).local b).consumed =
      (m.local b).consumed + schedule.count b := by
  induction schedule generalizing m with
  | nil => simp [continueRun]
  | cons next tail ih =>
    rw [show continueRun cfg boundaries left right m (next :: tail) =
      continueRun cfg boundaries left right
        (advance cfg boundaries left right m next) tail from rfl]
    rw [ih, advance_consumed]
    by_cases h : next = b <;> simp [h, Nat.add_assoc, Nat.add_comm]

theorem runPrefix_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (b : BranchId) :
    ((runPrefix cfg boundaries initial left right schedule).local b).consumed =
      schedule.count b := by
  rw [runPrefix, continueRun_consumed]
  cases b <;> simp [Interleaving.start, Machine.local]

theorem runPrefix_complete_counts (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (h : Complete left right schedule) :
    (runPrefix cfg boundaries initial left right schedule).left.consumed = left.length ∧
    (runPrefix cfg boundaries initial left right schedule).right.consumed = right.length := by
  exact ⟨(runPrefix_consumed cfg boundaries initial left right schedule .left).trans h.1,
    (runPrefix_consumed cfg boundaries initial left right schedule .right).trans h.2⟩

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Soundness.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/LocalOrder.lean ---
import DefiKernel.Interleaving.Soundness

/-! Active local indices count successful static slots. Exhausted internal tokens consume slots
without increasing the successful index; before any real attempt the two indices agree. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem AdvanceSound.active_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {m post : Machine P A D} {b : BranchId}
    (step : AdvanceSound cfg boundaries left right m b post)
    (previous : ∀ own, (m.local own).failure = none →
      (m.local own).nextIndex = min (m.local own).consumed
        (selectBranch left right own).length) :
    ∀ own, (post.local own).failure = none →
      (post.local own).nextIndex = min (post.local own).consumed
        (selectBranch left right own).length := by
  intro own active
  have hl := previous .left
  have hr := previous .right
  cases step with
  | halted failure failed =>
    cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.setLocal, Machine.local, selectBranch]
  | exhausted oldActive absent =>
    have hb := List.getElem?_eq_none_iff.mp absent
    cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.setLocal, Machine.local, selectBranch] <;> omega
  | refused inv reason oldActive selected rejected =>
    cases b <;> cases own <;>
      simp_all [Machine.refuse, Machine.setLocal, Machine.local, selectBranch]
  | accepted inv result oldActive selected executed =>
    obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
    cases b <;> cases own <;>
      dsimp [Machine.accept, Machine.setLocal, Machine.local, selectBranch] at * <;>
      simp_all <;>
      have hb' := hb <;>
      simp only [Machine.local, selectBranch] at hb' <;> omega

theorem Reachable.active_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).failure = none →
      (m.local b).nextIndex = min (m.local b).consumed (selectBranch left right b).length := by
  induction h with
  | start => intro b; cases b <;> simp [Interleaving.start, Machine.local]
  | next b previous step ih => exact step.active_index ih

theorem Reachable.attempt_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (b : BranchId)
    (active : (m.local b).failure = none) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv) :
    (m.local b).nextIndex = (m.local b).consumed := by
  obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
  rw [h.active_index b active, min_eq_left (Nat.le_of_lt hb)]

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/LocalOrder.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Trace.lean ---
import DefiKernel.Interleaving.Soundness
import DefiKernel.Interleaving.LocalOrder

/-! The global attempt chain and its branch projections are derived from real execution.
Refusal witnesses refer to the world at that attempt, not the later peer-updated final world. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive AttemptChain (initial : World P A D) :
    List (Attempt P A D) → World P A D → Prop
  | empty : AttemptChain initial [] initial
  | success {attempts : List (Attempt P A D)} {pre : World P A D}
      {attempt : Attempt P A D} {result : StepResult P A D}
      (previous : AttemptChain initial attempts pre) (before : attempt.before = pre)
      (outcome : attempt.outcome = .ok result) :
      AttemptChain initial (attempts ++ [attempt]) result.world
  | refusal {attempts : List (Attempt P A D)} {pre : World P A D}
      {attempt : Attempt P A D} {reason : Composition.Failure}
      (previous : AttemptChain initial attempts pre) (before : attempt.before = pre)
      (outcome : attempt.outcome = .error reason) :
      AttemptChain initial (attempts ++ [attempt]) pre

def successfulEvent (b : BranchId) (attempt : Attempt P A D) : Option (Event P A D) :=
  if attempt.branch = b then
    match attempt.outcome with
    | .error _ => none
    | .ok result => some ⟨attempt.index, .invoke attempt.invocation, attempt.before, result⟩
  else none

-- BEGIN PROOFS

theorem Reachable.attempt_chain {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    AttemptChain initial m.attempts m.world := by
  induction h with
  | start => exact .empty
  | next b previous step ih =>
    cases step with
    | halted => simpa [skip_world, skip_attempts] using ih
    | exhausted => simpa [skip_world, skip_attempts] using ih
    | refused inv reason active selected rejected =>
      rw [refuse_world]
      exact .refusal ih rfl rfl
    | accepted inv result active selected executed => exact .success ih rfl rfl

theorem Reachable.branch_projection {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).events = m.attempts.filterMap (successfulEvent b) := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local,
        successfulEvent, List.filterMap_append]

theorem Reachable.local_history {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).outputs = (m.local b).events.flatMap (fun event ↦ event.result.outputs) := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem Reachable.local_event_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).nextIndex = (m.local b).events.length := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem Reachable.local_order {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).events.map Event.step =
      ((selectBranch left right b).take (m.local b).nextIndex).map Step.invoke := by
  induction h with
  | start => intro b; cases b <;> rfl
  | @next pre post b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    have ho := ih own
    cases step with
    | halted =>
      cases b <;> cases own <;>
        simpa [Machine.skip, Machine.setLocal, Machine.local] using ho
    | exhausted =>
      cases b <;> cases own <;>
        simpa [Machine.skip, Machine.setLocal, Machine.local] using ho
    | refused =>
      cases b <;> cases own <;>
        simpa [Machine.refuse, Machine.setLocal, Machine.local] using ho
    | accepted inv result active selected executed =>
      have hi := previous.attempt_index b active inv selected
      have ht : (selectBranch left right b).take ((pre.local b).nextIndex + 1) =
          (selectBranch left right b).take (pre.local b).nextIndex ++ [inv] := by
        rw [hi, List.take_add_one]
        simp [selected]
      cases b <;> cases own <;>
        simp_all [Machine.accept, Machine.setLocal, Machine.local, selectBranch]

theorem Reachable.failure_index {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b failure, (m.local b).failure = some failure → failure.index = (m.local b).nextIndex := by
  induction h with
  | start => intro b; cases b <;> simp [Interleaving.start, Machine.local]
  | next b previous step ih =>
    intro own failure hf
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]
    all_goals cases hf; rfl

theorem AdvanceSound.refusal_stable {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex := by
  cases h <;> cases b <;> cases own <;>
    simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_refusal_stable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    let post := advance cfg boundaries left right m b
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex :=
  (advance_sound cfg boundaries left right m b).refusal_stable own failure failed

theorem continueRun_refusal_stable (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Machine P A D) (schedule : Schedule) (own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    let post := continueRun cfg boundaries left right m schedule
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex := by
  induction schedule generalizing m with
  | nil => exact ⟨failed, rfl, rfl, rfl⟩
  | cons b tail ih =>
    have first := advance_refusal_stable cfg boundaries left right m b own failure failed
    have rest := ih _ first.1
    exact ⟨rest.1, rest.2.1.trans first.2.1,
      rest.2.2.1.trans first.2.2.1, rest.2.2.2.trans first.2.2.2⟩

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Trace.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Completion.lean ---
import DefiKernel.Interleaving.Trace

/-! Public refusal and complete-schedule outcome laws. Admission refusals contain the exact
reason, unchanged initial world and supplied schedule; their constructor has no attempts or
outputs. The canonical comparator intentionally ignores the supplied schedule even for refused
results. It compares their exact reasons and full worlds instead; raw Result equality retains
that schedule. Complete active branches exhaust their invocations; failed branches retain the
exact failure recorded by the actual trace. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

/-- A preflight refusal returns the unchanged initial world without an execution payload. -/
theorem runInterleaving_admission_refusal (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (reason : DefiKernel.Interleaving.AdmissionFailure P A D)
    (h : DefiKernel.Interleaving.admit cfg boundaries left right schedule = .error reason) :
    runInterleaving cfg boundaries initial left right schedule =
      .refused reason initial schedule := by
  simp only [runInterleaving, h]

/-- Every active branch of a complete schedule has successfully exhausted its static slots. -/
theorem runPrefix_complete_active_exhaustion (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (complete : Complete left right schedule)
    (b : BranchId)
    (active : ((runPrefix cfg boundaries initial left right schedule).local b).failure = none) :
    ((runPrefix cfg boundaries initial left right schedule).local b).nextIndex =
      (selectBranch left right b).length := by
  have h := (runPrefix_reachable cfg boundaries initial left right schedule).active_index b active
  rw [runPrefix_consumed] at h
  cases b <;> simpa only [selectBranch, complete.1, complete.2, Nat.min_self] using h

/-- Every branch is either exhausted without failure or retains its exact located refusal. -/
theorem runPrefix_complete_exhausted_or_refused (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (complete : Complete left right schedule)
    (b : BranchId) :
    (((runPrefix cfg boundaries initial left right schedule).local b).failure = none ∧
      ((runPrefix cfg boundaries initial left right schedule).local b).nextIndex =
        (selectBranch left right b).length) ∨
    ∃ failure,
      ((runPrefix cfg boundaries initial left right schedule).local b).failure = some failure ∧
      failure.index =
        ((runPrefix cfg boundaries initial left right schedule).local b).nextIndex := by
  cases h : ((runPrefix cfg boundaries initial left right schedule).local b).failure with
  | none => exact .inl ⟨rfl,
      runPrefix_complete_active_exhaustion cfg boundaries initial left right schedule complete b h⟩
  | some failure => exact .inr ⟨failure, rfl,
      (runPrefix_reachable cfg boundaries initial left right schedule).failure_index b failure h⟩

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Completion.lean ---

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

--- BEGIN FILE lean/DefiKernel/Interleaving/Preservation.lean ---
import DefiKernel.Interleaving.Soundness
import DefiKernel.Interleaving.LocalOrder
import DefiKernel.Composition.Preservation
import DefiKernel.Parallel.Dependency.Adapter

/-! Accounting and locality telescope actual scheduled effects. Authority is checked at each
attempt's real pre-world, with a separate proof that every capability store is the initial one. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem AdvanceSound.accounting {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (d : D) (a : A) :
    total post.world.state d a - total m.world.state d a = post.supply d a - m.supply d a := by
  cases h with
  | halted => simp [skip_world, Machine.supply, skip_attempts]
  | exhausted => simp [skip_world, Machine.supply, skip_attempts]
  | refused =>
    simp [Machine.supply, Machine.refuse, Attempt.supply, setLocal_world]
  | accepted inv result active selected executed =>
    have he := (executeStep_sound _ _ _ _ _ _ _ executed).accounting d a
    simp only [Machine.supply, Machine.accept, List.map_append,
      List.map_singleton, List.sum_append, List.sum_singleton, Attempt.supply]
    linarith

theorem Reachable.accounting {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (d : D) (a : A) :
    total m.world.state d a = total initial.state d a + m.supply d a := by
  induction h with
  | start => simp [Interleaving.start, Machine.supply]
  | next b previous step ih =>
    have he := step.accounting d a
    linarith

theorem AdvanceSound.before_stores {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post)
    (store : m.world.capabilities = initial.capabilities)
    (previous : ∀ attempt ∈ m.attempts, attempt.before.capabilities = initial.capabilities) :
    ∀ attempt ∈ post.attempts, attempt.before.capabilities = initial.capabilities := by
  cases h with
  | halted => simpa [skip_attempts] using previous
  | exhausted => simpa [skip_attempts] using previous
  | refused =>
    intro attempt member
    simp only [Machine.refuse, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact store
  | accepted =>
    intro attempt member
    simp only [Machine.accept, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact store

theorem Reachable.before_stores {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ attempt ∈ m.attempts, attempt.before.capabilities = initial.capabilities := by
  induction h with
  | start => simp [Interleaving.start]
  | next b previous step ih => exact step.before_stores previous.store ih

theorem Reachable.authority {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (attempt : Attempt P A D)
    (member : attempt ∈ m.attempts) (result : StepResult P A D)
    (success : attempt.outcome = .ok result) :
    ReceiptAuthorized attempt.before (boundaries attempt.branch attempt.index) result.receipt := by
  obtain ⟨history, executed⟩ := h.attempts attempt member
  rw [success] at executed
  exact (executeStep_sound _ _ _ _ _ _ _ executed).authorized

theorem Reachable.initial_store_authority {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (attempt : Attempt P A D)
    (member : attempt ∈ m.attempts) (result : StepResult P A D)
    (success : attempt.outcome = .ok result) :
    ReceiptAuthorized ⟨attempt.before.state, initial.capabilities⟩
      (boundaries attempt.branch attempt.index) result.receipt := by
  have authorized := h.authority attempt member result success
  have store := h.before_stores attempt member
  cases hr : result.receipt <;> simp_all [ReceiptAuthorized]

theorem AdvanceSound.locality {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (c : Cell P A D)
    (untouched : c ∉ post.writes) :
    post.world.state.balance c = m.world.state.balance c ∧ c ∉ m.writes := by
  cases h with
  | halted => simpa [skip_world, Machine.writes, skip_attempts] using untouched
  | exhausted => simpa [skip_world, Machine.writes, skip_attempts] using untouched
  | refused =>
    simpa [Machine.writes, Machine.refuse, Attempt.writes, setLocal_world] using untouched
  | accepted inv result active selected executed =>
    simp only [Machine.writes, Machine.accept, List.flatMap_append,
      List.flatMap_singleton, Attempt.writes, List.mem_append, not_or] at untouched
    exact ⟨(executeStep_sound _ _ _ _ _ _ _ executed).locality c untouched.2, untouched.1⟩

theorem Reachable.locality {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (c : Cell P A D)
    (untouched : c ∉ m.writes) : m.world.state.balance c = initial.state.balance c := by
  induction h with
  | start => rfl
  | next b previous step ih =>
    obtain ⟨same, old⟩ := step.locality c untouched
    exact same.trans (ih old)

theorem Reachable.frame {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (region : Set (Cell P A D))
    (untouched : ∀ c ∈ region, c ∉ m.writes) : AgreeOn region initial.state m.world.state := by
  intro c member
  exact (h.locality c (untouched c member)).symm

theorem Reachable.predicate_frame {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (region : Set (Cell P A D))
    (predicate : State P A D → Prop) (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ m.writes) :
    predicate initial.state ↔ predicate m.world.state :=
  supported_frame support (h.frame region untouched)

omit [Fintype P] [Fintype A] [Fintype D] in
theorem analyzed_selected (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (b : BranchId) (n : Nat) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[n]? = some inv) :
    ∃ fp, analyzeInvocation cfg (boundaries b n) inv = .ok fp ∧
      ∀ c ∈ fp.writes, c ∈ lf.writes ++ rf.writes := by
  cases b with
  | left =>
    obtain ⟨fp, hf, _, hw⟩ := analyzeBranchFrom_member cfg (boundaries .left)
      0 left lf hl n inv selected
    exact ⟨fp, by simpa using hf, fun c hc ↦ List.mem_append_left _ (hw c hc)⟩
  | right =>
    obtain ⟨fp, hf, _, hw⟩ := analyzeBranchFrom_member cfg (boundaries .right)
      0 right rf hr n inv selected
    exact ⟨fp, by simpa using hf, fun c hc ↦ List.mem_append_right _ (hw c hc)⟩

theorem Reachable.analyzed_locality {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (c : Cell P A D) (untouched : c ∉ lf.writes ++ rf.writes) :
    m.world.state.balance c = initial.state.balance c := by
  induction h with
  | start => rfl
  | @next pre post b previous step ih =>
    cases step with
    | halted => simpa [skip_world] using ih
    | exhausted => simpa [skip_world] using ih
    | refused => simpa [refuse_world] using ih
    | accepted inv result active selected executed =>
      have hi := previous.attempt_index b active inv selected
      obtain ⟨fp, hf, hw⟩ := analyzed_selected cfg boundaries left right lf rf hl hr
        b (pre.local b).consumed inv selected
      rw [← hi] at hf
      have framed := (executeStep_target_frame cfg (boundaries b (pre.local b).nextIndex)
        (pre.local b).nextIndex (pre.local b).outputs inv pre.world result fp hf executed).1
      exact (framed c (fun hc ↦ untouched (hw c hc))).trans ih

theorem Reachable.analyzed_predicate_frame {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ++ rf.writes) :
    predicate initial.state ↔ predicate m.world.state := by
  apply supported_frame support
  intro c hc
  exact (h.analyzed_locality lf rf hl hr c (untouched c hc)).symm

theorem runPrefix_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (d : D) (a : A) :
    total (runPrefix cfg boundaries initial left right schedule).world.state d a =
      total initial.state d a + (runPrefix cfg boundaries initial left right schedule).supply d a :=
  (runPrefix_reachable cfg boundaries initial left right schedule).accounting d a

theorem runPrefix_store (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    (runPrefix cfg boundaries initial left right schedule).world.capabilities =
      initial.capabilities :=
  (runPrefix_reachable cfg boundaries initial left right schedule).store

theorem runPrefix_nonnegative (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (c : Cell P A D) :
    0 ≤ (runPrefix cfg boundaries initial left right schedule).world.state.balance c :=
  (runPrefix cfg boundaries initial left right schedule).world.state.nonneg c

theorem runPrefix_frame (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region,
      c ∉ (runPrefix cfg boundaries initial left right schedule).writes) :
    predicate initial.state ↔
      predicate (runPrefix cfg boundaries initial left right schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial left right schedule).predicate_frame
    region predicate support untouched

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Preservation.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Interference.lean ---
import DefiKernel.Interleaving.LocalOrder

/-! Initialized rely/guarantee reasoning over actual shared-world executions. Local obligations
quantify over arbitrary histories and worlds; they never assume the peer invariant or run result. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

abbrev LedgerPredicate (P A D : Type) := State P A D → Prop
abbrev LedgerRelation (P A D : Type) := State P A D → State P A D → Prop

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Each branch proves its own invariant and guarantee from its own invariant alone. -/
def LocalObligation (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (invariant : BranchId → LedgerPredicate P A D)
    (guarantee : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b index inv, (selectBranch left right b)[index]? = some inv →
    ∀ history pre result, invariant b pre.state →
      StepSound cfg (boundaries b index) index history (.invoke inv) pre result →
      invariant b result.world.state ∧ guarantee b pre.state result.world.state

def CrossInclusion (guarantee rely : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b peer, b ≠ peer → ∀ pre post, guarantee b pre post → rely peer pre post

def Stable (invariant : BranchId → LedgerPredicate P A D)
    (rely : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b pre post, invariant b pre → rely b pre post → invariant b post

-- BEGIN PROOFS

theorem Reachable.two_invariants {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b m.world.state := by
  induction h with
  | start => exact initialized
  | next b previous step ih =>
    cases step with
    | halted => simpa only [skip_world] using ih
    | exhausted => simpa only [skip_world] using ih
    | refused => simpa only [refuse_world] using ih
    | accepted inv result active selected executed =>
      have index := previous.attempt_index b active inv selected
      have selected' : (selectBranch left right b)[_]? = some inv := selected
      rw [← index] at selected'
      have own := localObligation b _ inv selected' _ _ _ (ih b)
        (executeStep_sound _ _ _ _ _ _ _ executed)
      intro other
      change invariant other result.world.state
      by_cases same : b = other
      · subst other
        exact own.1
      · exact stable other _ _ (ih other) (cross b other same _ _ own.2)

theorem runPrefix_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b (runPrefix cfg boundaries initial left right schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial left right schedule).two_invariants
    invariant guarantee rely initialized localObligation cross stable

/-- Any supplied finite prefix retains both initialized invariants, including stopped branches. -/
theorem every_prefix_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) (length : Nat) :
    ∀ b, invariant b
      (runPrefix cfg boundaries initial left right (schedule.take length)).world.state :=
  runPrefix_two_invariants cfg boundaries initial left right (schedule.take length)
    invariant guarantee rely initialized localObligation cross stable

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Interference.lean ---

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

--- BEGIN FILE lean/DefiKernel/Interleaving/InterferenceFixtures.lean ---
import DefiKernel.Interleaving.Interference
import DefiKernel.Interleaving.Preservation
import DefiKernel.Interleaving.Examples
import DefiKernel.Parallel.Preservation

/-! Shared-liquidity development instances and counterexamples. Conservation has a local proof
independent of the invariant antecedent; the generic rely/guarantee rule still exposes it. -/
namespace DefiKernel.Interleaving.InterferenceFixtures
open Typed Composition Parallel Typed.Examples Parallel.Examples Interleaving.Examples

abbrev Ledger := State Party Asset Domain

def dollars (amount : ℚ) (_ : BranchId) (s : Ledger) : Prop := total s .main .usd = amount
def sameDollars (_ : BranchId) (pre post : Ledger) : Prop :=
  total post .main .usd = total pre .main .usd

def leftFP : Footprint Party Asset Domain :=
  ⟨[vaultUSD, aliceUSD, vaultUSD, aliceUSD, aliceUSD], [vaultUSD, aliceUSD, vaultUSD, aliceUSD]⟩
def rightFP : Footprint Party Asset Domain :=
  ⟨[vaultUSD, bobUSD, vaultUSD, bobUSD, bobUSD], [vaultUSD, bobUSD, vaultUSD, bobUSD]⟩
def collateral (s : Ledger) : Prop := s.balance protectedCell = 9

def fragile : BranchId → Ledger → Prop
  | .left, s => s.balance bobUSD = 0
  | .right, s => total s .main .usd = 10

def rightPrefix := runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight [.right]
def leftPrefix := runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight [.left]

-- BEGIN PROOFS

theorem shared_supply_free : ∀ op template, sharedCfg.registry op = some template →
    template.supplyDeltas = [] := by
  intro op template selected
  change (if op = ⟨10⟩ then some (transferTemplate .usd (.literal .vault) (.literal .alice))
    else if op = ⟨11⟩ then some (transferTemplate .usd (.literal .vault) (.literal .bob))
    else none) = some template at selected
  split_ifs at selected <;> cases selected <;> rfl

/-- The local total relation needs no invariant antecedent or peer assumption. -/
theorem shared_step_total (boundary : Boundary Party Asset Domain) (index : Nat)
    (history : List (OutputObservation Asset)) (inv : I) (pre : W)
    (result : StepResult Party Asset Domain)
    (h : StepSound sharedCfg boundary index history (.invoke inv) pre result) :
    total result.world.state .main .usd = total pre.state .main .usd := by
  rw [h.accounting, step_no_supply shared_supply_free h, add_zero]

theorem shared_local_obligation (amount : ℚ) :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight (dollars amount) sameDollars := by
  intro b index inv _ history pre result initialized step
  have totalEq := shared_step_total _ _ _ _ _ _ step
  exact ⟨totalEq.trans initialized, totalEq⟩

theorem shared_cross : CrossInclusion sameDollars sameDollars := by
  intro b peer _ pre post h
  exact h

theorem shared_stable (amount : ℚ) : Stable (dollars amount) sameDollars := by
  intro b pre post initialized same
  exact same.trans initialized

theorem shared_initialized : ∀ b, dollars 10 b sharedInitial.state := by
  intro b
  change total sharedInitial.state .main .usd = 10
  decide +kernel

theorem shared_every_prefix (schedule : Schedule) (length : Nat) :
    ∀ b, dollars 10 b (runPrefix sharedCfg boundaries sharedInitial
      sharedLeft sharedRight (schedule.take length)).world.state :=
  every_prefix_two_invariants sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule
    (dollars 10) sameDollars sameDollars shared_initialized (shared_local_obligation 10)
    shared_cross (shared_stable 10) length

theorem shared_all_tokens (schedule : Schedule) :
    total (runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule).world.state
      .main .usd = 10 :=
  runPrefix_two_invariants sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule
    (dollars 10) sameDollars sameDollars shared_initialized (shared_local_obligation 10)
    shared_cross (shared_stable 10) .left

theorem shared_left_analyzed : analyzeBranch sharedCfg (boundaries .left) sharedLeft =
    .ok leftFP := by decide +kernel

theorem shared_right_analyzed : analyzeBranch sharedCfg (boundaries .right) sharedRight =
    .ok rightFP := by decide +kernel

theorem shared_overlap : vaultUSD ∈ leftFP.writes ∧ vaultUSD ∈ rightFP.writes := by decide

theorem collateral_supported : Supports {protectedCell} collateral :=
  supports_balance protectedCell (· = 9)

theorem protected_collateral_all_tokens (schedule : Schedule) :
    collateral (runPrefix sharedCfg boundaries sharedInitial
      sharedLeft sharedRight schedule).world.state := by
  have frame := (runPrefix_reachable sharedCfg boundaries sharedInitial sharedLeft sharedRight
    schedule).analyzed_predicate_frame leftFP rightFP shared_left_analyzed shared_right_analyzed
    {protectedCell} collateral collateral_supported
  have untouched : ∀ c ∈ ({protectedCell} : Set C), c ∉ leftFP.writes ++ rightFP.writes := by
    intro c member
    have eq := Set.mem_singleton_iff.mp member
    subst c
    decide
  apply (frame untouched).mp
  change sharedInitial.state.balance protectedCell = 9
  decide +kernel

/-- All noninitial premises hold for total USD11, but even the empty prefix has total USD10. -/
theorem missing_initialization_counterexample :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight (dollars 11) sameDollars ∧
    CrossInclusion sameDollars sameDollars ∧ Stable (dollars 11) sameDollars ∧
    ¬ dollars 11 .left
      (runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight []).world.state := by
  refine ⟨shared_local_obligation 11, shared_cross, shared_stable 11, ?_⟩
  change total sharedInitial.state .main .usd ≠ 11
  rw [shared_initialized .left]
  decide

/-- StepSound version of the analyzed target frame for local universal obligations. -/
theorem sound_target_frame {cfg : Config Party Asset Domain}
    {boundary : Boundary Party Asset Domain} {index : Nat}
    {history : List (OutputObservation Asset)} {inv : I} {pre : W}
    {result : StepResult Party Asset Domain} (fp : Footprint Party Asset Domain)
    (analyzed : analyzeInvocation cfg boundary inv = .ok fp)
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∀ c, c ∉ fp.writes → result.world.state.balance c = pre.state.balance c := by
  cases h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    obtain ⟨op, parties, _⟩ := prepareInvocation_shape _ _ _ _ _ _ _ prepared
    apply execute_target_frame cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state post {c | c ∈ fp.writes} _ executed
    intro template selected
    rw [op] at selected
    rw [parties]
    exact (analyzed_dependencies _ _ _ _ analyzed template selected).2.1

theorem fragile_local_obligation :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight fragile sameDollars := by
  intro b index inv selected history pre result initialized step
  have totalEq := shared_step_total _ _ _ _ _ _ step
  refine ⟨?_, totalEq⟩
  cases b with
  | right => exact totalEq.trans initialized
  | left =>
    cases index with
    | zero =>
      simp only [selectBranch, sharedLeft, List.getElem?_cons_zero, Option.some.injEq] at selected
      subst inv
      have analyzed : analyzeInvocation sharedCfg (boundaries .left 0) (usd 7) =
          .ok leftFP := by decide +kernel
      exact (sound_target_frame leftFP analyzed step bobUSD (by decide)).trans initialized
    | succ n => simp [selectBranch, sharedLeft] at selected

theorem fragile_initialized : ∀ b, fragile b sharedInitial.state := by
  intro b
  cases b
  · change sharedInitial.state.balance bobUSD = 0
    decide +kernel
  · exact shared_initialized .right

/-- The peer transfers six dollars to Bob while conserving total USD; this breaks Bob=0. -/
theorem missing_peer_stability_counterexample :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight fragile sameDollars ∧
    CrossInclusion sameDollars sameDollars ∧ (∀ b, fragile b sharedInitial.state) ∧
    sameDollars .left sharedInitial.state rightPrefix.world.state ∧
    ¬ fragile .left rightPrefix.world.state := by
  refine ⟨fragile_local_obligation, shared_cross, fragile_initialized, ?_, ?_⟩
  · exact (shared_all_tokens [.right]).trans (shared_initialized .left).symm
  · change rightPrefix.world.state.balance bobUSD ≠ 0
    decide +kernel

theorem fragile_not_stable : ¬ Stable fragile sameDollars := by
  intro stable
  have witness := missing_peer_stability_counterexample
  exact witness.2.2.2.2 (stable .left _ _ (fragile_initialized .left) witness.2.2.2.1)

/-- Empty region agreement alone cannot protect a financial predicate on a written cell. -/
theorem missing_frame_support_counterexample :
    AgreeOn (∅ : Set C) sharedInitial.state leftPrefix.world.state ∧
    sharedInitial.state.balance aliceUSD = 0 ∧ leftPrefix.world.state.balance aliceUSD ≠ 0 := by
  refine ⟨?_, ?_, ?_⟩
  · intro c impossible
    cases impossible
  · decide +kernel
  · decide +kernel

theorem empty_support_is_false :
    ¬ Supports (∅ : Set C) (fun s : Ledger ↦ s.balance aliceUSD = 0) := by
  intro support
  have witness := missing_frame_support_counterexample
  exact witness.2.2 ((support _ _ witness.1).mp witness.2.1)

end DefiKernel.Interleaving.InterferenceFixtures

--- END FILE lean/DefiKernel/Interleaving/InterferenceFixtures.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Recovery/Reference.lean ---
import DefiKernel.Interleaving.Execution
import DefiKernel.Parallel.Commutation

/-! Isolated sequential prefix references used by shared-state recovery. -/
namespace DefiKernel.Interleaving.Recovery
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def isolated (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat) : Cursor P A D :=
  Composition.run cfg boundary initial ((branch.take n).map Step.invoke)

-- BEGIN PROOFS

theorem isolated_zero (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    isolated cfg boundary initial branch 0 = startCursor cfg initial := rfl

theorem isolated_step (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat) (inv : Invocation P A D)
    (h : branch[n]? = some inv) :
    isolated cfg boundary initial branch (n + 1) =
      Composition.advance cfg boundary (isolated cfg boundary initial branch n) (.invoke inv) := by
  have ht : branch.take (n + 1) = branch.take n ++ [inv] := by
    rw [List.take_add_one]
    simp [h]
  simp only [isolated, ht, List.map_append, List.map_cons, List.map_nil, Composition.run]
  rw [Composition.continueRun_append]
  rfl

theorem isolated_exhausted (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat)
    (h : branch[n]? = none) :
    isolated cfg boundary initial branch (n + 1) = isolated cfg boundary initial branch n := by
  simp only [isolated, List.take_add_one, h, Option.toList_none, List.append_nil]

theorem continue_active_index (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D))
    (h : (Composition.continueRun cfg boundary cursor steps).failure = none) :
    (Composition.continueRun cfg boundary cursor steps).nextIndex =
      cursor.nextIndex + steps.length := by
  induction steps generalizing cursor with
  | nil => simp [Composition.continueRun]
  | cons step tail ih =>
    cases hf : cursor.failure with
    | some failure => simp [Composition.continueRun_failed _ _ _ _ hf, hf] at h
    | none =>
      cases he : executeStep cfg (boundary cursor.nextIndex) cursor.nextIndex cursor.outputs
          step cursor.world with
      | error reason =>
        have ha : Composition.advance cfg boundary cursor step =
            { cursor with failure := some ⟨cursor.nextIndex, some step, reason⟩ } := by
          simp [Composition.advance, hf, he]
        change (Composition.continueRun cfg boundary
          (Composition.advance cfg boundary cursor step) tail).failure = none at h
        rw [ha, Composition.continueRun_failed _ _ _ _ rfl] at h
        contradiction
      | ok result =>
        change (Composition.continueRun cfg boundary
          (Composition.advance cfg boundary cursor step) tail).nextIndex = _
        rw [ih _ h]
        simp [Composition.advance, hf, he, Nat.add_assoc, Nat.add_comm]

theorem isolated_active_index (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (n : Nat)
    (h : (isolated cfg boundary initial branch n).failure = none) :
    (isolated cfg boundary initial branch n).nextIndex = min n branch.length := by
  simpa [isolated, Composition.run, startCursor] using
    continue_active_index cfg boundary (startCursor cfg initial)
      ((branch.take n).map Step.invoke) h

theorem isolated_full (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    isolated cfg boundary initial branch branch.length = runBranch cfg boundary initial branch := by
  simp [isolated, runBranch]

end DefiKernel.Interleaving.Recovery

--- END FILE lean/DefiKernel/Interleaving/Recovery/Reference.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Recovery/Step.lean ---
import DefiKernel.Interleaving.LocalOrder
import DefiKernel.Interleaving.Recovery.Reference

/-! One-token cursor correspondence and admitted dependency frames. -/
namespace DefiKernel.Interleaving.Recovery
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def footprint (lf rf : Footprint P A D) : BranchId → Footprint P A D
  | .left => lf
  | .right => rf

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
theorem admitted_analysis (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (b : BranchId) :
    analyzeBranch cfg (boundaries b) (selectBranch left right b) = .ok (footprint lf rf b) := by
  obtain ⟨_, hl, hr, _⟩ := Parallel.admit_ok cfg boundaries left right lf rf hp
  cases b <;> assumption

omit [Fintype P] [Fintype A] [Fintype D] in
theorem selected_footprint (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (b : BranchId)
    (n : Nat) (inv : Invocation P A D) (selected : (selectBranch left right b)[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries b n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ (footprint lf rf b).reads) ∧
      (∀ c ∈ part.writes, c ∈ (footprint lf rf b).writes) := by
  simpa using analyzeBranchFrom_member cfg (boundaries b) 0 (selectBranch left right b)
    (footprint lf rf b) (admitted_analysis cfg boundaries left right lf rf hp b) n inv selected

theorem advance_own_cursor (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv) :
    let post := Interleaving.advance cfg boundaries left right m b
    (post.local b).toCursor post.world =
      Composition.advance cfg (boundaries b) ((m.local b).toCursor m.world) (.invoke inv) := by
  cases hf : (m.local b).failure with
  | some failure =>
    cases b <;> simp_all [Interleaving.advance, Machine.skip, Machine.setLocal, Machine.local,
      LocalState.toCursor, Composition.advance]
  | none =>
    cases he : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world <;>
      cases b <;> simp_all [Interleaving.advance, Machine.refuse, Machine.accept,
        Machine.setLocal, Machine.local, LocalState.toCursor, Composition.advance]

theorem advance_peer_local (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b peer : BranchId) (hne : b ≠ peer) :
    (Interleaving.advance cfg boundaries left right m b).local peer = m.local peer := by
  have hs := advance_sound cfg boundaries left right m b
  generalize he : Interleaving.advance cfg boundaries left right m b = post at hs ⊢
  cases hs <;> cases b <;> cases peer <;>
    simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_exhausted_cursor (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId)
    (absent : (selectBranch left right b)[(m.local b).consumed]? = none) :
    let post := Interleaving.advance cfg boundaries left right m b
    (post.local b).toCursor post.world = (m.local b).toCursor m.world := by
  cases hf : (m.local b).failure <;> cases b <;>
    simp_all [Interleaving.advance, Machine.skip, Machine.setLocal, Machine.local,
      LocalState.toCursor]

theorem cursor_advance_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (inv : Invocation P A D) (index : Nat) (part : Footprint P A D)
    (region : Set (Cell P A D)) (left right : Cursor P A D)
    (hf : analyzeInvocation cfg (boundary index) inv = .ok part)
    (hin : ∀ c ∈ part.reads, c ∈ region) (hi : left.nextIndex = index)
    (ha : CursorAgrees region left right) :
    CursorAgrees region (Composition.advance cfg boundary left (.invoke inv))
      (Composition.advance cfg boundary right (.invoke inv)) := by
  have hs : analyzeBranchFrom cfg boundary index [inv] = .ok (part.append .empty) := by
    simp [analyzeBranchFrom, hf, bind, Except.bind, pure, Except.pure, Except.mapError]
  have hh := continueRun_congr cfg boundary [inv] index (part.append .empty) region
    left right hs (by simpa [Footprint.append, Footprint.empty] using hin) hi ha
  exact hh

theorem advance_branch_frame (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (b : BranchId) :
    ∀ c, c ∉ (footprint lf rf b).writes →
      (Interleaving.advance cfg boundaries left right m b).world.state.balance c =
        m.world.state.balance c := by
  have hs := advance_sound cfg boundaries left right m b
  generalize he : Interleaving.advance cfg boundaries left right m b = post at hs ⊢
  cases hs with
  | halted => intro c hc; rw [skip_world]
  | exhausted => intro c hc; rw [skip_world]
  | refused => intro c hc; rw [refuse_world]
  | accepted inv result active selected executed =>
    obtain ⟨part, hf, _, hw⟩ := selected_footprint cfg boundaries left right lf rf hp b
      (m.local b).consumed inv selected
    rw [← reach.attempt_index b active inv selected] at hf
    have frame := executeStep_target_frame cfg (boundaries b (m.local b).nextIndex)
      (m.local b).nextIndex (m.local b).outputs inv m.world result part hf executed
    intro c hc
    exact frame.1 c (fun h ↦ hc (hw c h))

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem compatible_peer_reads (lf rf : Footprint P A D) (hc : Compatible lf rf)
    (b peer : BranchId) (hne : b ≠ peer) (c : Cell P A D)
    (hr : c ∈ (footprint lf rf peer).reads) : c ∉ (footprint lf rf b).writes := by
  cases b <;> cases peer
  · exact (hne rfl).elim
  · exact fun hw ↦ hc.2.1 c hw hr
  · exact fun hw ↦ hc.2.2 c hw hr
  · exact (hne rfl).elim

end DefiKernel.Interleaving.Recovery

--- END FILE lean/DefiKernel/Interleaving/Recovery/Step.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Recovery/Simulation.lean ---
import DefiKernel.Interleaving.Recovery.Step

/-! Prefix simulation against independently executed branch prefixes, including exact refusals. -/
namespace DefiKernel.Interleaving.Recovery
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

def Simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (m : Machine P A D) : Prop :=
  ∀ b, CursorAgrees {c | c ∈ (footprint lf rf b).reads}
    ((m.local b).toCursor m.world)
    (isolated cfg (boundaries b) initial (selectBranch left right b) (m.local b).consumed)

theorem advance_own_agrees (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (b : BranchId)
    (ha : CursorAgrees {c | c ∈ (footprint lf rf b).reads}
      ((m.local b).toCursor m.world)
      (isolated cfg (boundaries b) initial (selectBranch left right b) (m.local b).consumed)) :
    let post := Interleaving.advance cfg boundaries left right m b
    CursorAgrees {c | c ∈ (footprint lf rf b).reads} ((post.local b).toCursor post.world)
      (isolated cfg (boundaries b) initial (selectBranch left right b)
        (post.local b).consumed) := by
  dsimp only
  rw [advance_consumed]
  simp only [ite_true]
  cases selected : (selectBranch left right b)[(m.local b).consumed]? with
  | none =>
    rw [isolated_exhausted cfg (boundaries b) initial _ _ selected,
      advance_exhausted_cursor cfg boundaries left right m b selected]
    exact ha
  | some inv =>
    rw [isolated_step cfg (boundaries b) initial _ _ inv selected,
      advance_own_cursor cfg boundaries left right m b inv selected]
    cases hf : (m.local b).failure with
    | some failure =>
      have hr : (isolated cfg (boundaries b) initial (selectBranch left right b)
          (m.local b).consumed).failure = some failure := ha.failure.symm.trans hf
      simpa [Composition.advance, LocalState.toCursor, hf, hr] using ha
    | none =>
      have hi := reach.attempt_index b hf inv selected
      obtain ⟨part, hp', hin, _⟩ := selected_footprint cfg boundaries left right lf rf hp b
        (m.local b).consumed inv selected
      exact cursor_advance_congr cfg (boundaries b) inv (m.local b).consumed part
        {c | c ∈ (footprint lf rf b).reads} _ _ hp' hin hi ha

theorem advance_simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (ha : Simulates cfg boundaries
      initial left right lf rf m) (b : BranchId) :
    Simulates cfg boundaries initial left right lf rf
      (Interleaving.advance cfg boundaries left right m b) := by
  intro own
  by_cases heq : b = own
  · subst own
    exact advance_own_agrees cfg boundaries initial left right lf rf hp m reach b (ha b)
  · rw [advance_peer_local cfg boundaries left right m b own heq]
    have old := ha own
    have hc := (Parallel.admit_ok cfg boundaries left right lf rf hp).2.2.2
    refine ⟨?_, ?_, old.events, old.outputs, old.nextIndex, old.failure⟩
    · intro c hr
      exact (advance_branch_frame cfg boundaries initial left right lf rf hp m reach b c
        (compatible_peer_reads lf rf hc b own heq c hr)).trans (old.state c hr)
    · exact (advance_sound cfg boundaries left right m b).store.trans old.capabilities

theorem continue_simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m)
    (ha : Simulates cfg boundaries initial left right lf rf m) (schedule : Schedule) :
    Simulates cfg boundaries initial left right lf rf
      (Interleaving.continueRun cfg boundaries left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact ha
  | cons b tail ih =>
    exact ih _ (.next b reach (advance_sound cfg boundaries left right m b))
      (advance_simulates cfg boundaries initial left right lf rf hp m reach ha b)

theorem runPrefix_simulates (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule) :
    Simulates cfg boundaries initial left right lf rf
      (runPrefix cfg boundaries initial left right schedule) := by
  apply continue_simulates cfg boundaries initial left right lf rf hp (start initial) .start
  have hv := (Parallel.admit_ok cfg boundaries left right lf rf hp).1
  intro b
  cases b <;>
    exact ⟨fun _ _ ↦ rfl, rfl, rfl, rfl, rfl, by simp [isolated, Composition.run,
      startCursor, Composition.continueRun, Interleaving.start, Machine.local,
      LocalState.toCursor, hv]⟩

theorem continue_outside (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (m : Machine P A D)
    (reach : Reachable cfg boundaries left right initial m) (schedule : Schedule)
    (c : Cell P A D) (hl : c ∉ lf.writes) (hr : c ∉ rf.writes) :
    (Interleaving.continueRun cfg boundaries left right m schedule).world.state.balance c =
      m.world.state.balance c := by
  induction schedule generalizing m with
  | nil => rfl
  | cons b tail ih =>
    exact (ih _ (.next b reach (advance_sound cfg boundaries left right m b))).trans
      (advance_branch_frame cfg boundaries initial left right lf rf hp m reach b c
        (by cases b <;> assumption))

end DefiKernel.Interleaving.Recovery

--- END FILE lean/DefiKernel/Interleaving/Recovery/Simulation.lean ---

--- BEGIN FILE lean/DefiKernel/Interleaving/Recovery.lean ---
import DefiKernel.Interleaving.Recovery.Simulation

/-! Every complete disjoint schedule recovers the full existing canonical parallel observation.
The simulation includes refusals and retained prefixes; raw foreign event worlds are not equated. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel Recovery

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem runPrefix_parallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) initial right
    ProjectedEquivalent (runPrefix cfg boundaries initial left right schedule)
      ⟨mergeWorld lf rf initial l.world r.world, l, r⟩ := by
  have sim := runPrefix_simulates cfg boundaries initial left right lf rf hp schedule
  have counts := runPrefix_complete_counts cfg boundaries initial left right schedule complete
  have hl := sim .left
  have hr := sim .right
  simp only [Machine.local, footprint, selectBranch, counts.1, counts.2, isolated_full] at hl hr
  obtain ⟨_, al, ar, _⟩ := Parallel.admit_ok cfg boundaries left right lf rf hp
  refine ⟨⟨?_, ?_⟩, hl.observation, hr.observation⟩
  · intro c
    by_cases hcl : c ∈ lf.writes
    · have hread := analyzeBranchFrom_writes_read cfg (boundaries .left) 0 left lf al c hcl
      simpa [mergeWorld, hcl, LocalState.toCursor] using hl.state c hread
    · by_cases hcr : c ∈ rf.writes
      · have hread := analyzeBranchFrom_writes_read cfg (boundaries .right) 0 right rf ar c hcr
        simpa [mergeWorld, hcl, hcr, LocalState.toCursor] using hr.state c hread
      · simpa [mergeWorld, hcl, hcr, runPrefix, Interleaving.start] using
          continue_outside cfg boundaries initial left right lf rf hp (start initial)
            .start schedule c hcl hcr
  · exact (runPrefix_reachable cfg boundaries initial left right schedule).store

/-- The actual public evaluator and existing parallel evaluator return related executed results. -/
theorem runInterleaving_recovers (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    ∃ joined, Parallel.runParallel cfg boundaries initial left right = .executed joined ∧
      runInterleaving cfg boundaries initial left right schedule =
        .executed schedule (runPrefix cfg boundaries initial left right schedule) ∧
      ProjectedEquivalent (runPrefix cfg boundaries initial left right schedule) joined := by
  refine ⟨_, ?_, ?_,
    runPrefix_parallel cfg boundaries initial left right lf rf hp schedule complete⟩
  · simp [Parallel.runParallel, hp]
  · simp [runInterleaving, admit_of_parallel cfg boundaries left right schedule lf rf hp complete]

theorem runInterleaving_matchesParallel (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left right schedule)
      (Parallel.runParallel cfg boundaries initial left right) = true := by
  obtain ⟨joined, hp', hs, related⟩ :=
    runInterleaving_recovers cfg boundaries initial left right lf rf hp schedule complete
  rw [hp', hs, matchesParallel_iff]
  exact related

theorem matchesParallel_transport (shared : Interleaving.Result P A D)
    (first second : Parallel.Result P A D)
    (h : matchesParallel shared first = true)
    (equiv : Parallel.ObservationallyEquivalent first second) :
    matchesParallel shared second = true := by
  cases shared with
  | refused => simp [matchesParallel] at h
  | executed schedule m =>
    cases first with
    | refused => simp [matchesParallel] at h
    | executed a =>
      cases second with
      | refused => exact equiv.elim
      | executed b =>
        rw [matchesParallel_iff] at h ⊢
        exact ⟨h.1.trans equiv.1, h.2.1.trans equiv.2.1, h.2.2.trans equiv.2.2⟩

theorem runInterleaving_matchesSerialLR (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left right schedule)
      (Parallel.runSerialLR cfg boundaries initial left right) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial left right lf rf hp schedule complete)
    (Parallel.runParallel_serialLR cfg boundaries initial left right)

theorem runInterleaving_matchesSerialRL (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) (schedule : Schedule)
    (complete : Complete left right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left right schedule)
      (Parallel.runSerialRL cfg boundaries initial left right) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial left right lf rf hp schedule complete)
    (Parallel.runParallel_serialRL cfg boundaries initial left right)

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem complete_blockLR (left right : Branch P A D) :
    Complete left right
      (List.replicate left.length .left ++ List.replicate right.length .right) := by
  simp [Complete, List.count_replicate]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem complete_blockRL (left right : Branch P A D) :
    Complete left right
      (List.replicate right.length .right ++ List.replicate left.length .left) := by
  simp [Complete, List.count_replicate]

theorem runInterleaving_blockLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) :
    matchesParallel (runInterleaving cfg boundaries initial left right
      (List.replicate left.length .left ++ List.replicate right.length .right))
      (Parallel.runSerialLR cfg boundaries initial left right) = true :=
  runInterleaving_matchesSerialLR cfg boundaries initial left right lf rf hp _
    (complete_blockLR left right)

theorem runInterleaving_blockRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf)) :
    matchesParallel (runInterleaving cfg boundaries initial left right
      (List.replicate right.length .right ++ List.replicate left.length .left))
      (Parallel.runSerialRL cfg boundaries initial left right) = true :=
  runInterleaving_matchesSerialRL cfg boundaries initial left right lf rf hp _
    (complete_blockRL left right)

theorem runInterleaving_empty_right (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left : Branch P A D) (lf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left [] = .ok (lf, .empty)) (schedule : Schedule)
    (complete : Complete left [] schedule) :
    matchesParallel (runInterleaving cfg boundaries initial left [] schedule)
      (.executed ⟨(runBranch cfg (boundaries .left) initial left).world,
        runBranch cfg (boundaries .left) initial left, startCursor cfg initial⟩) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial left [] lf .empty hp schedule complete)
    (Parallel.runParallel_empty_right cfg boundaries initial left lf hp)

theorem runInterleaving_empty_left (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (right : Branch P A D) (rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries [] right = .ok (.empty, rf)) (schedule : Schedule)
    (complete : Complete [] right schedule) :
    matchesParallel (runInterleaving cfg boundaries initial [] right schedule)
      (.executed ⟨(runBranch cfg (boundaries .right) initial right).world,
        startCursor cfg initial, runBranch cfg (boundaries .right) initial right⟩) = true :=
  matchesParallel_transport _ _ _
    (runInterleaving_matchesParallel cfg boundaries initial [] right .empty rf hp schedule complete)
    (Parallel.runParallel_empty_left cfg boundaries initial right rf hp)

theorem runInterleaving_empty (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (hv : validateCatalog cfg.registry cfg.catalog = true) :
    runInterleaving cfg boundaries initial [] [] [] = .executed [] (start initial) := by
  simp [runInterleaving, Interleaving.admit, hv, analyzeBranch, analyzeBranchFrom,
    checkSchedule, Except.mapError, bind, Except.bind, pure, Except.pure,
    runPrefix, Interleaving.continueRun]

end DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Recovery.lean ---

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

--- BEGIN FILE lean/DefiKernel/Interleaving/Verify.lean ---
import DefiKernel.Interleaving.Audit
import DefiKernel.Interleaving.Trace
import DefiKernel.Interleaving.Completion
import DefiKernel.Interleaving.Preservation
import DefiKernel.Interleaving.Interference
import DefiKernel.Interleaving.InterferenceFixtures
import DefiKernel.Interleaving.Recovery
import DefiKernel.AxiomAudit

/-! Audit every imported Interleaving theorem and supplemental declaration by module provenance.
Runtime comparisons and generic proofs remain separate evidence classes. -/
#audit_axioms DefiKernel.Interleaving

--- END FILE lean/DefiKernel/Interleaving/Verify.lean ---

--- BEGIN FILE lean/Defialgebra/Interface.lean ---
/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.

# The interface discipline for `⋈`

`BASIS.md` §5 composes constructions along a coupling `κ` that "identifies only
carriers of the same sort". `P1 · Led` has carrier `(N ⇀ Q) × Q` — a balance map and
a declared total — with the law `‖bal‖ = sup`. But `sup` is merely sort `Q`, so `κ`
may glue it to an unrelated `Q` of the partner, whose transitions then write it while
the balance map is untouched. **Conservation dies under plain interleaving, with no
fusion involved**, and the invariant induction §5 relies on has no proof.

Four independent designs (`sigma/INTERFACE-COUNCIL.md`) converged on one fix:
*the declared total is not a shareable thing*. This file is the Lean statement of it.

* `Ledger.sup_not_port` — the discipline, carried as a well-formedness field rather
  than proved. This is the whole fix.
* `cons_of_portConfined` — a foreign transition confined to a ledger's ports, and
  `Q`-neutral on the ports it shares, preserves `‖bal‖ = sup`.
* `cons_broken_if_sup_is_port` — **the negative companion.** Drop `sup ∉ ports` and
  the same theorem is false, by explicit counterexample. Without this the result
  could hold vacuously, which is the failure mode this programme keeps finding.

SCOPE, stated plainly. Sorts are not modelled: state here is `Idx → ℤ`, because
conservation quantifies over `Q` alone and the sort discipline is a separate
concern. Fusion, polarity of `Q` flows, and associativity are M2/M3 and are absent.
What is proved is exactly the milestone: the coupling defect is real, and
`sup ∉ ports` closes it.
-/
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.Ring.Int

namespace Defialgebra.Interface

variable {Idx : Type*} [DecidableEq Idx]

/-- The state of a construction, restricted to its `Q` carriers. -/
def St (Idx : Type*) : Type _ := Idx → ℤ

/-- A `Led` block: the balance indices, the declared total, and the ports it
exposes to a coupling.

`bal : N ⇀ Q` is modelled as `N`-many `Q`-carriers rather than one map carrier.
That is faithful to §5's "`S` a finite product of carriers", and it is what makes
the defect *sayable*: `sup` is a different index from every balance, so a port list
can contain the balances and exclude the total. -/
structure Ledger (Idx : Type*) where
  /-- The indices holding individual balances. -/
  bals : Finset Idx
  /-- The index holding the declared total. -/
  sup : Idx
  /-- The indices a coupling is permitted to bind. -/
  ports : Finset Idx
  /-- The total is not one of the balances. -/
  sup_not_bal : sup ∉ bals
  /-- **THE INTERFACE DISCIPLINE.** The declared total is never a port, so no
  coupling can bind it and no foreign transition can write it. Carried as a
  well-formedness condition, not derived. -/
  sup_not_port : sup ∉ ports

/-- `P1 · Led`'s law: `‖bal‖ = sup`. -/
def Cons (L : Ledger Idx) (s : St Idx) : Prop :=
  ∑ i ∈ L.bals, s i = s L.sup

/-- `f` touches nothing outside `P` — what a coupling confines a partner to. -/
def WritesWithin (P : Finset Idx) (f : St Idx → St Idx) : Prop :=
  ∀ s i, i ∉ P → f s i = s i

/-- `f` moves no net quantity across the ports it shares with `L`. A transfer that
debits one shared balance and credits another satisfies this; a mint into a shared
balance does not. -/
def QNeutralOn (P : Finset Idx) (L : Ledger Idx) (f : St Idx → St Idx) : Prop :=
  ∀ s, ∑ i ∈ L.bals.filter (· ∈ P), f s i
        = ∑ i ∈ L.bals.filter (· ∈ P), s i

/-- **The milestone.** A foreign transition confined to `L`'s ports and `Q`-neutral
on the shared balances preserves conservation.

The proof is three lines and every one of them is the discipline doing work: the
total is untouched *because it is not a port*; the private balances are untouched
*because the transition is confined to ports*; the shared balances net to zero *by
hypothesis*. Remove `sup_not_port` and the first line fails — see
`cons_broken_if_sup_is_port`. -/
theorem cons_of_portConfined (L : Ledger Idx) (f : St Idx → St Idx)
    (hw : WritesWithin L.ports f) (hq : QNeutralOn L.ports L f)
    (s : St Idx) (h : Cons L s) : Cons L (f s) := by
  have hsup : f s L.sup = s L.sup := hw s L.sup L.sup_not_port
  have hsum : ∑ i ∈ L.bals, f s i = ∑ i ∈ L.bals, s i := by
    rw [← Finset.sum_filter_add_sum_filter_not L.bals (· ∈ L.ports) (f s),
        ← Finset.sum_filter_add_sum_filter_not L.bals (· ∈ L.ports) s, hq s]
    congr 1
    refine Finset.sum_congr rfl ?_
    intro i hi
    exact hw s i (by simpa using (Finset.mem_filter.mp hi).2)
  unfold Cons at h ⊢
  rw [hsum, hsup, h]

omit [DecidableEq Idx] in
/-- The frame case: a transition touching none of a ledger's carriers preserves
conservation. Immediate, and worth stating because it is what makes composition
with an unrelated machine free. -/
theorem cons_of_disjoint (L : Ledger Idx) (f : St Idx → St Idx)
    (P : Finset Idx) (hw : WritesWithin P f)
    (hb : ∀ i ∈ L.bals, i ∉ P) (hs : L.sup ∉ P)
    (s : St Idx) (h : Cons L s) : Cons L (f s) := by
  have hsum : ∑ i ∈ L.bals, f s i = ∑ i ∈ L.bals, s i :=
    Finset.sum_congr rfl fun i hi => hw s i (hb i hi)
  unfold Cons at h ⊢
  rw [hsum, hw s L.sup hs, h]

/-- **The negative companion, and the point of the whole file.**

Drop `sup ∉ ports` and `cons_of_portConfined` is false. Here is the witness: one
balance, one total, and a partner permitted to bind the total. The partner writes
only its permitted index and is `Q`-neutral on the shared balances — vacuously, since
it shares none — yet conservation breaks.

This is exactly the coupling `BASIS.md` §5 admits, since `sup` is merely sort `Q`
and `κ` identifies same-sort carriers. -/
theorem cons_broken_if_sup_is_port :
    ∃ (bals : Finset Bool) (sup : Bool) (ports : Finset Bool)
      (f : St Bool → St Bool) (s : St Bool),
      sup ∉ bals ∧
      sup ∈ ports ∧                                    -- the discipline VIOLATED
      WritesWithin ports f ∧                           -- confined to its ports
      (∀ t, ∑ i ∈ bals.filter (· ∈ ports), f t i
            = ∑ i ∈ bals.filter (· ∈ ports), t i) ∧     -- Q-neutral on shared bals
      (∑ i ∈ bals, s i) = s sup ∧                      -- conservation HOLDS
      (∑ i ∈ bals, f s i) ≠ f s sup := by              -- and FAILS after
  -- No `classical`: `Bool` already has `DecidableEq`, and introducing
  -- `Classical.dec` makes the two `∅`s carry different instances, so
  -- `Finset.sum_empty` rewrites one side and not the other.
  refine ⟨{false}, true, {true},
          fun t i => if i = true then t i + 1 else t i,
          fun _ => 0, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · decide
  · decide
  · intro t i hi
    have : i ≠ true := by
      intro h; exact hi (by simp [h])
    simp [this]
  · -- The two sums are equal POINTWISE on an empty index set. Computing both to
    -- `0` via `Finset.sum_empty` rewrites only one side here; congruence avoids
    -- the question entirely.
    intro t
    refine Finset.sum_congr rfl ?_
    intro i hi
    have hfil : ({false} : Finset Bool).filter (· ∈ ({true} : Finset Bool)) = ∅ := by
      decide
    rw [hfil] at hi
    exact absurd hi (Finset.notMem_empty i)
  · simp
  · simp

end Defialgebra.Interface

--- END FILE lean/Defialgebra/Interface.lean ---

--- BEGIN FILE lean/Defialgebra/Nary.lean ---
/-
Copyright (c) 2026 Charles Hoskinson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Charles Hoskinson
-/
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Fintype.Basic
import Mathlib.Tactic.Linarith

/-!
# M3 — n-ary binding and bracket-independent agreement

`INTERFACE-COUNCIL.md` §2: pair-local `κ` makes associativity *unstatable*, because
`κ` is attached to a pair, not to an object. The remedy is **stable port names**
plus **n-ary composition over a global binding set**.

## What is proved

* `Binding` — a finite set of port-pairs (global names).
* `Agrees` — state agreement on every bound pair.
* `agrees_iff_agrees_sym` — agreement depends only on the symmetric closure
  (pair orientation does not matter).
* `agrees_union`, `union_assoc`, `agrees_union_assoc` — multi-party composition
  is constraint-union; union is associative, so bracketing does not change
  agreement.
* `agrees_of_same_symClosure` — **two-binding reindex:** if two bindings have
  equal symmetric closures, they induce the same agreement predicate (listing
  order / pair orientation / redundant reverse edges do not matter).
* `pairLocal_excludes_skip` — **negative companion.** Pair-local edges on a
  binary cut cannot include a skip edge with both ends on the same side.
* `skip_not_pairLocal_witness` — concrete three-port witness.

## What is not proved

* Operational transition systems / reachability.
* Lifting M1 conservation through transitions.
* Corpus adequacy (M4).
-/

set_option linter.unusedSectionVars false
set_option linter.unusedDecidableInType false

namespace Defialgebra.Nary

variable {Idx : Type*} [DecidableEq Idx]

/-- A construction exposes a finite set of globally named ports. -/
structure Machine (Idx : Type*) where
  ports : Finset Idx

/-- Global binding: port-pairs that must carry equal state. -/
structure Binding (Idx : Type*) where
  pairs : Finset (Idx × Idx)

def St (Idx : Type*) : Type _ := Idx → ℤ

def PairAgrees (s : St Idx) (p : Idx × Idx) : Prop :=
  s p.1 = s p.2

def Agrees (B : Binding Idx) (s : St Idx) : Prop :=
  ∀ p ∈ B.pairs, PairAgrees s p

def symClosure (P : Finset (Idx × Idx)) : Finset (Idx × Idx) :=
  P ∪ P.image (fun p => (p.2, p.1))

theorem agrees_iff_agrees_sym (B : Binding Idx) (s : St Idx) :
    Agrees B s ↔ (∀ p ∈ symClosure B.pairs, PairAgrees s p) := by
  constructor
  · intro h p hp
    simp only [symClosure, Finset.mem_union, Finset.mem_image] at hp
    rcases hp with hp | ⟨q, hq, rfl⟩
    · exact h p hp
    · exact (h q hq).symm
  · intro h p hp
    exact h p (by
      simp only [symClosure, Finset.mem_union]
      exact Or.inl hp)

def Binding.union (B₁ B₂ : Binding Idx) : Binding Idx where
  pairs := B₁.pairs ∪ B₂.pairs

theorem agrees_union (B₁ B₂ : Binding Idx) (s : St Idx) :
    Agrees (B₁.union B₂) s ↔ Agrees B₁ s ∧ Agrees B₂ s := by
  constructor
  · intro h
    exact ⟨fun p hp => h p (Finset.mem_union_left _ hp),
           fun p hp => h p (Finset.mem_union_right _ hp)⟩
  · rintro ⟨h₁, h₂⟩ p hp
    cases Finset.mem_union.1 hp with
    | inl hp => exact h₁ p hp
    | inr hp => exact h₂ p hp

theorem union_assoc (B₁ B₂ B₃ : Binding Idx) :
    (B₁.union B₂).union B₃ = B₁.union (B₂.union B₃) := by
  cases B₁; cases B₂; cases B₃
  simp [Binding.union, Finset.union_assoc]

theorem union_comm (B₁ B₂ : Binding Idx) :
    B₁.union B₂ = B₂.union B₁ := by
  cases B₁; cases B₂
  simp [Binding.union, Finset.union_comm]

/-- **Bracket independence.** Agreement under `((B₁ ∪ B₂) ∪ B₃)` iff under
`(B₁ ∪ (B₂ ∪ B₃))`. -/
theorem agrees_union_assoc (B₁ B₂ B₃ : Binding Idx) (s : St Idx) :
    Agrees ((B₁.union B₂).union B₃) s ↔ Agrees (B₁.union (B₂.union B₃)) s := by
  rw [union_assoc]

/-- **Two-binding reindex (M3-DESIGN item 4).** Bindings with the same symmetric
closure of pairs induce the same agreement predicate. Parenthesization of n-ary
composition is already ; this covers reordering and
re-orienting the declared pair list. -/
theorem agrees_of_same_symClosure (B₁ B₂ : Binding Idx) (s : St Idx)
    (h : symClosure B₁.pairs = symClosure B₂.pairs) :
    Agrees B₁ s ↔ Agrees B₂ s := by
  rw [agrees_iff_agrees_sym, agrees_iff_agrees_sym, h]

structure BinaryCut (Idx : Type*) where
  left : Finset Idx
  right : Finset Idx
  disjoint : Disjoint left right

/-- Pair-local κ: every edge spans the cut. -/
def PairLocal (C : BinaryCut Idx) (P : Finset (Idx × Idx)) : Prop :=
  ∀ p ∈ P,
    (p.1 ∈ C.left ∧ p.2 ∈ C.right) ∨ (p.1 ∈ C.right ∧ p.2 ∈ C.left)

/-- Skip edge: both ends on the left side (cannot be stated by pair-local κ). -/
def SkipEdge (C : BinaryCut Idx) (p : Idx × Idx) : Prop :=
  p.1 ∈ C.left ∧ p.2 ∈ C.left ∧ p.1 ≠ p.2

/-- **Negative companion.** Pair-local edge sets exclude skip edges. -/
theorem pairLocal_excludes_skip (C : BinaryCut Idx) (P : Finset (Idx × Idx))
    (hPL : PairLocal C P) {p : Idx × Idx} (hp : p ∈ P) (hS : SkipEdge C p) :
    False := by
  rcases hPL p hp with ⟨_, hR⟩ | ⟨hR, _⟩
  · exact Finset.disjoint_left.1 C.disjoint hS.2.1 hR
  · exact Finset.disjoint_left.1 C.disjoint hS.1 hR

private theorem cut02_1_disjoint :
    Disjoint ({(0 : Fin 3), 2} : Finset (Fin 3)) {1} := by
  decide

private def cut02_1 : BinaryCut (Fin 3) :=
  ⟨{0, 2}, {1}, cut02_1_disjoint⟩

private theorem skip02 : SkipEdge cut02_1 ((0 : Fin 3), 2) := by
  unfold SkipEdge cut02_1
  refine ⟨?_, ?_, ?_⟩
  · exact Finset.mem_insert_self (0 : Fin 3) {2}
  · exact Finset.mem_insert_of_mem (Finset.mem_singleton_self (2 : Fin 3))
  · exact by decide

/-- Concrete three-port witness: cut `{0,2} | {1}`, skip `(0,2)` is not pair-local
for any edge set containing it. -/
theorem skip_not_pairLocal_witness :
    ∃ (C : BinaryCut (Fin 3)) (p : Fin 3 × Fin 3),
      SkipEdge C p ∧
      ∀ P : Finset (Fin 3 × Fin 3), p ∈ P → ¬ PairLocal C P := by
  refine ⟨cut02_1, (0, 2), skip02, ?_⟩
  intro P hp hPL
  exact pairLocal_excludes_skip cut02_1 P hPL hp skip02

end Defialgebra.Nary

--- END FILE lean/Defialgebra/Nary.lean ---

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

--- BEGIN FILE scripts/check_interleaving_mutations.py ---
#!/usr/bin/env python3
"""Replay the actual interleaving Lean implementation under explicit source mutations.

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
import time
from datetime import datetime, timezone


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
    parser.add_argument('--timeout-seconds', type=int, default=600,
                        help='Per Lean/Git command timeout (default: 600 seconds)')
    args = parser.parse_args()
    require(args.timeout_seconds > 0, 'timeout must be positive')
    started = datetime.now(timezone.utc).isoformat()
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
    require('DefiKernel.Interleaving.Audit' in modules, 'missing Interleaving audit root')
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
    # Discover and inline every local import, including split Interleaving modules
    # absent from the mutation-site inventory; never load local cached oleans.
    blobs, ordered, visiting = {}, [], set()
    def capture(module):
        require(re.fullmatch(r'[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*', module),
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
                local_path = repo / 'lean' / (imported.replace('.', '/') + '.lean')
                if imported.startswith('DefiKernel.') or local_path.exists():
                    capture(imported)
        visiting.remove(module)
        ordered.append(module)
    for module in modules:
        require(isinstance(module, str) and re.fullmatch(
            r'DefiKernel\.Interleaving(?:\.[A-Za-z][A-Za-z0-9]*)+', module),
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
        if marker in source and module.startswith('DefiKernel.Interleaving.'):
            source, suffix = source.split(marker)
            # This bounded projection removes theorem tails only. Silently
            # dropping a late runtime declaration would change the computation.
            require(not re.search(r'^\s*(?:(?:private|protected|noncomputable|unsafe|partial)\s+)*'
                                  r'(?:def|abbrev|opaque|instance|structure|inductive|class)\b',
                                  suffix, re.MULTILINE),
                    f'{module}: runtime declaration after proof boundary')
            closure = re.search(r'\n(end DefiKernel\.Interleaving(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$', suffix)
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
        tick = time.monotonic()
        proc = subprocess.run(command, cwd=repo / 'lean', capture_output=True, text=True,
                              timeout=args.timeout_seconds)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        records.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                        'exit': proc.returncode, 'log_sha256': sha(log.encode()),
                        'elapsed_seconds': round(time.monotonic() - tick, 6),
                        'timeout_seconds': args.timeout_seconds})
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
    git_bindings = {}
    for relative, raw in blobs.items():
        command = ['git', '-C', str(repo), 'rev-parse', f'{head.strip()}:{relative}']
        identity = subprocess.run(command, capture_output=True, timeout=args.timeout_seconds)
        require(identity.returncode == 0, f'input absent from frozen Git revision: {relative}')
        object_id = identity.stdout.decode().strip()
        blob_command = ['git', '-C', str(repo), 'cat-file', 'blob', object_id]
        committed = subprocess.run(blob_command, capture_output=True, timeout=args.timeout_seconds)
        require(committed.returncode == 0, f'Git input object unavailable: {relative}')
        require(committed.stdout == raw, f'input differs from frozen Git revision: {relative}')
        git_bindings[relative] = {'git_object': object_id, 'sha256': sha(committed.stdout),
                                  'identity_command': command, 'blob_command': blob_command,
                                  'identity_exit': identity.returncode, 'blob_exit': committed.returncode}
    manifest = {'sources': sources, 'script_sha256': script_sha256,
                'spec_sha256': sha(spec_raw), 'git_head': head.strip(), 'input_status': dirty,
                'git_input_bindings': git_bindings, 'started_utc': started,
                'timeout_seconds_per_command': args.timeout_seconds,
                'binding_scope': 'Captured Lean/config inputs equal HEAD Git objects; external spec/driver '
                                 'are byte-hashed and checked for drift, with production freeze binding separate.',
                'lean_version': version.strip(), 'lean_executable_sha256': executable_sha,
                'scope': 'Fresh local dependency source closure; Interleaving proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.',
                'projection_order': ordered, 'module_roots': modules,
                'audit_root': 'DefiKernel.Interleaving.Audit', 'python_version': sys.version}
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'mutation-spec.json').write_bytes(spec_raw)
    for relative, raw in blobs.items():
        target = out / 'inputs' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    def verify_inputs():
        # Clear the prior variant's success flags before any read can fail.
        manifest.update(input_sources_unchanged=False, specification_unchanged=False,
                        runner_unchanged=False, git_head_unchanged=False)
        (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        manifest['sources_after'] = {p: sha(read(repo / p)) for p in blobs}
        manifest['spec_sha256_after'] = sha(read(args.spec))
        manifest['script_sha256_after'] = sha(read(Path(__file__)))
        current_head = subprocess.run(['git', '-C', str(repo), 'rev-parse', 'HEAD'],
                                      capture_output=True, text=True, timeout=args.timeout_seconds)
        manifest['git_head_after'] = current_head.stdout.strip()
        manifest['input_sources_unchanged'] = manifest['sources_after'] == sources
        manifest['specification_unchanged'] = manifest['spec_sha256_after'] == sha(spec_raw)
        manifest['runner_unchanged'] = manifest['script_sha256_after'] == script_sha256
        manifest['git_head_unchanged'] = (current_head.returncode == 0 and
                                          manifest['git_head_after'] == head.strip())
        (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        require(manifest['input_sources_unchanged'], 'input sources changed during replay')
        require(manifest['specification_unchanged'], 'specification changed during replay')
        require(manifest['runner_unchanged'], 'runner changed during replay')
        require(manifest['git_head_unchanged'], 'Git revision changed during replay')

    for label, parts in variants.items():
        source = '\n'.join(imports) + '\n\n' + '\n'.join(parts[m] for m in ordered)
        fixture = out / (label + '.lean')
        fixture.write_text(source)
        code, log = run(label, ['lake', 'env', 'lean', str(fixture)])
        verify_inputs()
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
            expected_error = f'error: Interleaving runtime comparisons failed: {len(false)}'
            require(not errors or (false and len(errors) == 1 and errors[0].endswith(expected_error)),
                    'control compilation/execution failed')
            check(code == 0 and not false, 'unchanged control has failing comparisons')
            for mutation in mutations:
                require(set(mutation['required_false']) <= checks.keys(),
                        f'{mutation["name"]}: missing required observation in control')
        else:
            require(checks.keys() == results['control']['checks'].keys(), f'{label}: partial execution')
            check(code != 0 or false, f'{label}: all comparisons still pass under mutation')
            expected_error = f'error: Interleaving runtime comparisons failed: {len(false)}'
            require(len(errors) == 1 and errors[0].endswith(expected_error),
                    f'{label}: failure is not solely the expected runtime comparison failure')
            required = next(m['required_false'] for m in mutations if m['name'] == label)
            check(code != 0 and set(required) <= set(false), f'{label}: required mutation not detected')
        check(all(checks[name] == 'true' for name in positives), f'{label}: positive control failed')
        results[label] = {'exit': code, 'fixture_sha256': sha(source.encode()),
                          'checks': checks, 'false_comparisons': false}
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        print(f'{label}: exit={code}; comparisons={len(checks)}; false={false}', flush=True)
    verify_inputs()
    manifest['finished_utc'] = datetime.now(timezone.utc).isoformat()
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

--- END FILE scripts/check_interleaving_mutations.py ---

--- BEGIN FILE scripts/test_interleaving_mutation_runner.py ---
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


INPUT_MODULE = 'DefiKernel.Interleaving.RunnerInput'
AUDIT_MODULE = 'DefiKernel.Interleaving.Audit'
DEPENDENCY = '''import Mathlib.Data.Nat.Basic
namespace DefiKernel.Parallel
def runnerDependency : Nat := 4
-- BEGIN PROOFS
theorem runnerDependency_value : runnerDependency = 4 := rfl
end DefiKernel.Parallel
'''
INPUT = '''import DefiKernel.Parallel.RunnerDependency

namespace DefiKernel.Interleaving

example : DefiKernel.Parallel.runnerDependency = 4 := DefiKernel.Parallel.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Interleaving
'''
AUDIT = '''import DefiKernel.Interleaving.RunnerInput

namespace DefiKernel.Interleaving

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := CHECKS
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Interleaving runtime comparisons failed: {failures}"

end DefiKernel.Interleaving
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
        {'name': 'discovered-interleaving-dependency', 'exit': 0, 'extra_dependency': True,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'fresh-dependency-source-failure', 'exit': 3, 'changed_dependency': True,
         'message': 'control compilation/execution failed'},
        {'name': 'missing-audit-root', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE]},
         'message': 'missing Interleaving audit root'},
        {'name': 'foreign-module-root', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE, AUDIT_MODULE,
                                              'DefiKernel.Composition.RunnerInput']},
         'message': 'invalid scoped module'},
        {'name': 'mutation-module-outside-inventory', 'exit': 3,
         'spec': specification({**mutation(), 'module': 'DefiKernel.Interleaving.Absent'}),
         'message': 'mutation module outside inventory'},
        {'name': 'unchanged-control-failed', 'exit': 1,
         'checks': '[("runner_positive", true), ("runner_sensitivity", false)]',
         'message': 'unchanged control has failing comparisons'},
        {'name': 'nonkernel-local-dependency', 'exit': 0, 'nonkernel_dependency': True,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'dirty-source-before-run', 'exit': 3, 'dirty_source': True,
         'message': 'input differs from frozen Git revision'},
        {'name': 'staged-source-before-run', 'exit': 3, 'staged_source': True,
         'message': 'input differs from frozen Git revision'},
        {'name': 'source-drift-during-run', 'exit': 3, 'source_drift': True,
         'message': 'input sources changed during replay'},
        {'name': 'source-drift-during-mutant', 'exit': 3, 'source_drift': True,
         'mutant_only_drift': True, 'message': 'input sources changed during replay'},
        {'name': 'specification-drift-during-run', 'exit': 3, 'spec_drift': True,
         'message': 'specification changed during replay'},
        {'name': 'runtime-definition-after-proof-boundary', 'exit': 3, 'late_runtime': True,
         'message': 'runtime declaration after proof boundary'},
        {'name': 'empty-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': []}, 'message': 'empty mutation inventory'},
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--runner', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--case', action='append', help='Run only these named controls')
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    runner = (args.runner or repo / 'scripts/check_interleaving_mutations.py').resolve()
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
    typed = lean / 'DefiKernel/Interleaving'
    typed.mkdir(parents=True)
    dependency = lean / 'DefiKernel/Parallel/RunnerDependency.lean'
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
    selected = [case for case in cases() if not args.case or case['name'] in args.case]
    require(selected and (not args.case or set(args.case) <= {c['name'] for c in selected}),
            'unknown or empty control selection')
    for case in selected:
        dependency.write_text(DEPENDENCY)
        (lean / 'lake-manifest.json').write_bytes(manifest)
        setup_records = []
        (typed / 'RunnerInput.lean').write_text(INPUT)
        if case.get('nonkernel_dependency'):
            external = lean / 'SharedFixture/RunnerDependency.lean'
            external.parent.mkdir(parents=True, exist_ok=True)
            external.write_text(DEPENDENCY.replace('DefiKernel.Parallel', 'SharedFixture'))
            (typed / 'RunnerInput.lean').write_text(INPUT.replace(
                'DefiKernel.Parallel', 'SharedFixture'))
        if case.get('extra_dependency'):
            extra = typed / 'SplitComputation.lean'
            extra.write_text('import DefiKernel.Parallel.RunnerDependency\n'
                             'namespace DefiKernel.Interleaving\n'
                             'def splitLimit : Nat := 4\n'
                             '-- BEGIN PROOFS\n'
                             'theorem splitLimit_value : splitLimit = 4 := rfl\n'
                             'end DefiKernel.Interleaving\n')
            (typed / 'RunnerInput.lean').write_text(INPUT.replace(
                'import DefiKernel.Parallel.RunnerDependency',
                'import DefiKernel.Interleaving.SplitComputation').replace(
                    'n ≤ 4', 'n ≤ 4 + (splitLimit - 4)'))
        if case.get('changed_dependency'):
            # Compile the old source, then change only the .lean file. A fresh
            # source projection must see 5 and fail the importing = 4 example.
            olean = lean / '.lake/build/lib/lean/DefiKernel/Parallel/RunnerDependency.olean'
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
        if case.get('late_runtime'):
            source = typed / 'RunnerInput.lean'
            source.write_text(source.read_text().replace('-- BEGIN PROOFS',
                              '-- BEGIN PROOFS\ndef hiddenRuntime : Bool := true'))
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
        if case.get('source_drift') or case.get('spec_drift'):
            drift_path = typed / 'RunnerInput.lean' if case.get('source_drift') else spec_path
            audit = typed / 'Audit.lean'
            drift_statement = 'liftIO <| IO.FS.writeFile ' + json.dumps(str(drift_path)) + \
                ' "-- drifted during actual Lean audit\\n"\n'
            if case.get('mutant_only_drift'):
                drift_statement = 'if runnerAllows 5 then\n    ' + drift_statement
            audit.write_text(audit.read_text().replace('  let checks :',
                '  ' + drift_statement + '  let checks :'))
        for setup_command in [
            ['git', '-C', str(fake), 'add', '-A', '--', 'lean', ':!lean/.lake'],
            ['git', '-C', str(fake), '-c', 'user.name=DeFiFormal fixture',
             '-c', 'user.email=fixture@invalid', 'commit', '--quiet', '--allow-empty',
             '-m', 'Freeze ' + case['name']],
        ]:
            setup = subprocess.run(setup_command, text=True, capture_output=True, timeout=60)
            require(setup.returncode == 0, f'fixture freeze failed: {setup.stderr}')
            setup_records.append({'command': setup_command, 'exit': setup.returncode})
        if case.get('dirty_source') or case.get('staged_source'):
            source = typed / 'RunnerInput.lean'
            source.write_text(source.read_text().replace('-- compiler-control', '-- uncommitted input drift'))
            if case.get('staged_source'):
                setup = subprocess.run(['git', '-C', str(fake), 'add', str(source)],
                                       text=True, capture_output=True, timeout=60)
                require(setup.returncode == 0, 'fixture stage failed')
        tick = time.monotonic()
        proc = subprocess.run(command, cwd=repo, text=True, capture_output=True, timeout=1500)
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
        if case['name'] in ('live-discriminating-mutant', 'dotted-comparisons', 'hyphenated-dotted-comparisons', 'discovered-interleaving-dependency', 'unused-variable-warning', 'nonkernel-local-dependency'):
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
            matched = matched and 'DefiKernel.Interleaving.SplitComputation' in captured.get('projection_order', [])
            matched = matched and captured.get('sources', {}).get(
                'lean/DefiKernel/Interleaving/SplitComputation.lean') == sha(extra.read_bytes())
            matched = matched and captured.get('input_sources_unchanged') is True
        if case.get('mutant_only_drift'):
            captured = json.loads(source_manifest.read_text()) if source_manifest.exists() else {}
            matched = matched and captured.get('input_sources_unchanged') is False
            matched = matched and runtime.get('results', {}).get('control', {}).get('exit') == 0
        if case.get('nonkernel_dependency'):
            captured = json.loads(source_manifest.read_text()) if source_manifest.exists() else {}
            matched = matched and 'SharedFixture.RunnerDependency' in captured.get('projection_order', [])
            matched = matched and captured.get('sources', {}).get(
                'lean/SharedFixture/RunnerDependency.lean') == sha(external.read_bytes())
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

--- END FILE scripts/test_interleaving_mutation_runner.py ---

--- BEGIN FILE review/semantic-kernel/sprint7/mutation-spec.json ---
{
  "schema_version": 1,
  "modules": [
    "DefiKernel.Interleaving.Schedule",
    "DefiKernel.Interleaving.Execution",
    "DefiKernel.Interleaving.Examples",
    "DefiKernel.Interleaving.ScheduleTests",
    "DefiKernel.Interleaving.Tests",
    "DefiKernel.Interleaving.Audit"
  ],
  "mutations": [
    {
      "name": "schedule-count-bypass",
      "module": "DefiKernel.Interleaving.Schedule",
      "needle": "if schedule.count .left = leftLength ∧ schedule.count .right = rightLength then .ok ⟨⟩",
      "replacement": "if True then .ok ⟨⟩",
      "required_false": [
        "interleaving.schedule.missing-right"
      ]
    },
    {
      "name": "reintroduce-overlap-rejection",
      "module": "DefiKernel.Interleaving.Schedule",
      "needle": "  let _ ← (checkSchedule left.length right.length schedule).mapError .schedule\n  return (lf, rf)",
      "replacement": "  let _ ← (checkSchedule left.length right.length schedule).mapError .schedule\n  let _ ← (Parallel.checkCompatibility lf rf).mapError (fun _ ↦ .configuration)\n  return (lf, rf)",
      "required_false": [
        "interleaving.schedule.overlap-admitted"
      ]
    },
    {
      "name": "stale-initial-world",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs\n        (.invoke inv) m.world",
      "replacement": "      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs\n        (.invoke inv) ((m.attempts.head?.map (fun attempt ↦ attempt.before)).getD m.world)",
      "required_false": [
        "interleaving.fixture.live.complete"
      ]
    },
    {
      "name": "isolated-branch-world",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs\n        (.invoke inv) m.world",
      "replacement": "      let isolated := Parallel.runBranch cfg (boundaries b) ((m.attempts.head?.map (fun attempt ↦ attempt.before)).getD m.world)\n        ((selectBranch left right b).take own.consumed)\n      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs\n        (.invoke inv) isolated.world",
      "required_false": [
        "interleaving.fixture.replenish.funded"
      ]
    },
    {
      "name": "global-cancellation",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "  let own := m.local b\n  match own.failure with",
      "replacement": "  let own := m.local b\n  if m.left.failure.isSome || m.right.failure.isSome then m.skip b else\n  match own.failure with",
      "required_false": [
        "interleaving.fixture.refusal.immediate"
      ]
    },
    {
      "name": "prefix-world-rollback",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "      | .error reason => m.refuse b inv reason",
      "replacement": "      | .error reason => { m.refuse b inv reason with world := ((m.attempts.head?.map (fun attempt ↦ attempt.before)).getD m.world) }",
      "required_false": [
        "interleaving.fixture.refusal.middle"
      ]
    },
    {
      "name": "retry-halted-suffix",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "  match own.failure with",
      "replacement": "  match (none : Option (LocatedFailure P A D)) with",
      "required_false": [
        "interleaving.fixture.replenish.halted"
      ]
    },
    {
      "name": "peer-history-leakage",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs\n        (.invoke inv) m.world",
      "replacement": "      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex\n        (own.outputs ++ (m.local (match b with | .left => .right | .right => .left)).outputs)\n        (.invoke inv) m.world",
      "required_false": [
        "interleaving.fixture.history.peer.only"
      ]
    },
    {
      "name": "snapshot-recomputation",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs\n        (.invoke inv) m.world",
      "replacement": "      let refreshed := own.outputs.map fun observation ↦\n        match cfg.catalog.find? (fun component ↦ decide (component.id = observation.port.component)) with\n        | none => observation\n        | some component =>\n          match (component.operations.flatMap (fun operation ↦ operation.outputs)).find?\n              (fun port ↦ decide (port.id = observation.port.port)) with\n          | none => observation\n          | some port => { observation with value :=\n              ⟨.amount port.cell.2.2, m.world.state.balance port.cell⟩ }\n      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex refreshed\n        (.invoke inv) m.world",
      "required_false": [
        "interleaving.fixture.snapshot.own"
      ]
    },
    {
      "name": "global-boundary-position",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "(boundaries b own.nextIndex)",
      "replacement": "(boundaries b (m.left.consumed + m.right.consumed))",
      "required_false": [
        "interleaving.fixture.boundary.local"
      ]
    },
    {
      "name": "global-invocation-position",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "(selectBranch left right b)[own.consumed]?",
      "replacement": "(selectBranch left right b)[m.left.consumed + m.right.consumed]?",
      "required_false": [
        "interleaving.fixture.disjoint.lrlr.complete"
      ]
    },
    {
      "name": "drop-peer-supply",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "  (m.attempts.map (fun attempt ↦ attempt.supply d a)).sum",
      "replacement": "  ((m.attempts.filter (fun attempt ↦ decide (attempt.branch = .left))).map\n    (fun attempt ↦ attempt.supply d a)).sum",
      "required_false": [
        "interleaving.fixture.supply.aggregate"
      ]
    },
    {
      "name": "resurrect-revoked-capabilities",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs\n        (.invoke inv) m.world",
      "replacement": "      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs\n        (.invoke inv) { m.world with capabilities :=\n          ⟨m.world.capabilities.entries.map (fun cap ↦ { cap with live := true })⟩ }",
      "required_false": [
        "interleaving.fixture.capability.revoked"
      ]
    },
    {
      "name": "omit-canonical-failure",
      "module": "DefiKernel.Interleaving.Execution",
      "needle": "  ⟨localState.events.map observeEvent, localState.outputs,\n    localState.nextIndex, localState.failure⟩",
      "replacement": "  ⟨localState.events.map observeEvent, localState.outputs,\n    localState.nextIndex, none⟩",
      "required_false": [
        "interleaving.observe.failure.reason"
      ]
    }
  ],
  "positive_checks": [
    "interleaving.schedule.balanced",
    "interleaving.schedule.disjoint-admitted",
    "interleaving.schedule.overlap-left-funded",
    "interleaving.schedule.overlap-right-funded",
    "interleaving.fixture.empty.both",
    "interleaving.fixture.empty.left",
    "interleaving.fixture.empty.right",
    "interleaving.observe.equal",
    "interleaving.observe.failure.equal"
  ]
}

--- END FILE review/semantic-kernel/sprint7/mutation-spec.json ---
