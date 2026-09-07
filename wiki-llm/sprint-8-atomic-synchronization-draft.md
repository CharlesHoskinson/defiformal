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
