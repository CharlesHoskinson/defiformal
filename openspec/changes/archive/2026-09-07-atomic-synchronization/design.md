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
