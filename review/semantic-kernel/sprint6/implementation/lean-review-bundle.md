You are an independent native implementation reviewer. Reply directly in plain Markdown with a completed review. Tools are disabled: do not emit tool markup, requests, preliminary narration, or promises. Read the supplied complete source text. State ACCEPT, ACCEPT WITH LIMITATIONS, or REQUEST CHANGES; concrete severity-tagged findings with source paths/declarations, impact, and required fixes. Distinguish proof soundness, modeled semantics, bounded evidence, and environmental/deployment assumptions. Do not claim independent execution. No Foreman.

Review Sprint 6 disjoint parallel composition, source candidate 7cb4807d1ff22c5ac804b03feb4a2530c46146f2. GPT-6 authored this implementation. Focus on conservative all-suffix footprints, expression/full-executor dependency with exact errors and implicit funding targets, branch-local inputs/trusted boundaries/fixed capabilities, partial refusal prefixes, region merge, true LR/RL re-execution, financially complete canonical equivalence, accounting/authority/support/initialized invariants. Check whether theorem premises circularly assume the conclusion or hide missing obligations. Inspect the independently specified full finite-world/receipt/output/refusal fixtures and axiom scope. Check the approved normative scenarios and requirements.

This is the substantive Lean implementation audit. The production mutation runner and complete legacy Python regression evidence are being finalized separately and will receive a separate native evidence audit. Do not treat those pending final gates as completed or waive them. Full Lean integration presently passes all10 commands: Parallel runtime131/131, imported388 theorems and419 supplemental declarations forbidden0. Explicit source theorem count126 (88generic,35reference instances,3counterexamples), plus262 generated declarations in theorem count. Existing165 preserved corpus/proofpaths,32 protectedkernelsources,435 historicaltrackedLeanpaths are unchanged; rootimport only adds Parallel.Verify. Standard axioms propext/Classical.choice/Quot.sound permitted; no sorry/customaxioms/native_decide accepted.


### AGENTS.md
SHA256 8648a6f91d00c75ccf8ad2198428f7cd7e55323204cec9af6f53e6d4972edb7b
```
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

```

### openspec/changes/disjoint-parallel-composition/design.md
SHA256 f685d265564f6ee6baab7888de46255b9d6b834b56305bbafe3d6febeed598ae
```
## Context

See [proposal.md](proposal.md). Base: `c71d61b137014360364c3eeba733df6cada2aff3`,
branch `semantic-kernel-pivot`. Sprint 5 exposes `Composition.run`, `executeStep`,
`TraceSound`, `run_accounting`, `run_frame`, `Supports`, and immutable output
snapshots. The registered executor can refuse on evaluation, authority, guard,
footprints, domains, balances, and accounting. Its sufficient-funds check inspects
all cells, even though only effect targets can alter that check on nonnegative
states. Thus declared writes alone are insufficient to justify independence.

## Goals / Non-Goals

**Goals:** An executable binary operator on finite invocation-only branches;
conservative decidable compatibility; independent successful-prefix and refusal
results; exact merge; generic Lean correspondence to re-executing branches in
either serial order; scoped financial preservation and discriminating evidence.

**Non-Goals:** Scheduling arbitrary shared-state interleavings, atomic rollback,
capability administration inside a branch, consumable allowances, cross-branch
output dependencies, nested/network associativity, secrecy, provenance, liveness,
machine arithmetic, and deployed fidelity. Admitted branches may share read-only
ledger cells and read the same fixed capability store. Values are exact rationals.
This is a logical fork/join operator, not a threaded runtime or speedup claim.

## Decisions

### 1. Binary fork/join with a serial correspondence obligation

Three approaches were considered:

1. **Independent branch execution plus checked merge (selected).** Reuses Sprint 5
   traces/refusals and makes local histories explicit. Requires real executor
   dependency proofs and serial correspondence, not just commutation of patches.
2. **Arbitrary step scheduler.** Closer to shared-state interleaving but requires
   scheduler fairness, history remapping, and more intermediate observations.
   That is the next composition operator, outside this sprint.
3. **Whole-domain partitioning.** Easier to prove but rejects independent cells
   in one financial domain. Exact-cell regions are useful and match existing APIs.

`Branch` contains a list of existing `Composition.Invocation` values. It cannot
contain `Step.issue` or `Step.revoke`. `BranchId` is the closed identity left/right;
labels belong to inputs and remain stable when evaluating right first. Trusted
`ParallelBoundary` is `BranchId → Nat → Composition.Boundary`. A branch's boundary
at local position n is always that function applied to its identity and n, never
an index in a combined event stream. The common immutable config and initial
world are explicit operator arguments.

A local `InputSource.priorOutput` means only an earlier output of the same branch.
The other branch's history is never available, even when keys coincide. Cross-
branch value flow must be expressed as a later sequential stage. Branch-local
output keys are externally tagged `(BranchId, localStep, QualifiedPort)`.

### 2. Compatibility is executable and state-independent

`Footprint` has finite `reads` and `writes` lists of exact cells. For every
invocation in each branch (including a suffix that may later be refused), analyze
the selected registered template and operation interface using its fixed parties
and trusted caller. Resolve references without evaluating financial expressions.

- `writes`: resolved declared template writes **and all delta targets**. Include
  targets even when the expression happens to evaluate to zero or effects cancel.
- `reads`: resolved syntactic `requiredStateReads` (both expression branches,
  guard, every delta and supply expression), declared `stateReads`, all `writes`,
  and every selected output cell. Writes are reads because balance sufficiency
  depends on the pre-balance at every potentially affected target.
- Branch regions are unions over the entire invocation list. Common read-only
  cells are permitted. For L and R require:
  `W_L ∩ W_R = ∅`, `W_L ∩ R_R = ∅`, and `W_R ∩ R_L = ∅`.
  The write/write test is retained explicitly although writes are included in reads.

Analyze all branches before running either. Global catalog validation is first;
then inspect left invocations in local order, then right invocations, then check
write/write, left-write/right-read, right-write/left-read in that order. Within an
invocation, use membership/registry lookup followed by ordered reference analysis
and interface access checks. Errors identify branch, local index, and structural
cause. Conflict errors identify class and the first conflicting cell in stable
list order. Incompatible input returns the initial world, no branch execution,
no receipts, and no outputs. Empty branches are legal, with empty regions.

This admission phase can reject a malformed unreachable suffix before a financial
prefix runs. That is intentional new-operator semantics; it does not alter
`Composition.run`. Signature/value unit, output availability, guard, and financial
checks remain branch runtime checks unless already determined by catalog validity.
A malformed party reference is an admission error; a numerically invalid argument,
missing prior output, or missing/revoked invocation capability is a branch refusal.
No financial expression is evaluated by admission and no initial-state success
or supplied boolean certificate is accepted as evidence of independence.

Capability IDs need not be disjoint: grants are reusable reads in the current
kernel. The parallel type excludes issue/revoke; both branch and joined stores
must equal the original store. A revocation before the fork is therefore observed
by either branch. This is not a capability-provenance theorem.

### 3. Execution and exact merge

For admitted inputs, compute independent cursors with existing `Composition.run`:
`left = run cfg (boundary left) initial (leftInvocations.map Step.invoke)` and the
corresponding right cursor. Each stops on its own first refusal and keeps its
successful prefix. Both branches run even if the other refuses immediately.
There is no global first-failure cancellation and no rollback of either prefix.

Construct the joined balance for every cell c:

```
if c ∈ W_L then left.world.state.balance c
else if c ∈ W_R then right.world.state.balance c
else initial.state.balance c
```

Nonnegativity follows by cases from each existing state's proof. The joined
capability store is exactly initial.capabilities. Compatibility prevents overlap;
proofs must show successful branch effects stay inside the analyzed region, so
this merge cannot hide an unauthorized out-of-region update. The implementation
must not add entire branch balances (which doubles the common base), select one
whole branch world (which loses its peer), or derive supply from post-minus-pre.
Supply remains the sum of the actual invocation receipts from both branches.

Result distinguishes admission refusal from an executed pair of branch outcomes.
Raw cursors remain available as isolated-branch evidence. Their full pre/post
worlds are not falsely described as one interleaved global trace.

### 4. Canonical observations and serial reference evaluation

`BranchObservation` records accepted local positions/operation identity, actual
invocation receipt data (resolved request and evaluated data, compared extensionally
where needed), typed snapshots, final local cursor position, and optional exact
refusal reason/index. Accepted request identity includes caller-relevant parties,
arguments, capabilities, and claimed actor; trusted boundary identity is fixed by
operator inputs. Failure step identity is recovered from the fixed branch input.

`Observation` consists of the joined full ledger, unchanged capability store,
and the two branch observations in fixed left/right slots. Ignore only global
completion order and raw full-world snapshots attached to individual events:
those intentionally include different foreign-state context on a serial run.
Do not erase refusal reasons, local indices, outputs, receipt effects/supplies,
branch labels, or final ledger cells in order to make the law hold.

Define serial references that still execute both branches independently on refusal:
- LR: run L on initial; run R on L's final world with R's own empty local history
  and boundary R starting at zero; observe R's final world plus both observations.
- RL: the symmetric execution, retaining original branch labels in observations.

These are two actual calls to the existing registered sequential executor, not
concatenation with its global short-circuit behavior and not evaluation of cached
receipts. Required theorem: accepted compatibility implies the parallel observation
is equivalent to LR and RL observations, for every well-typed initial world and
fixed config/boundaries. Both success and exact refusal paths are included.
An internal invocation commutation corollary uses singleton branches and states
its branch-local observation scope. Patching two precomputed states alone does
not satisfy the theorem requirement.

### 5. Proof dependency chain and non-circular premises

New proof modules consume old APIs without changing their definitions/statements:

1. `Expr.eval` is invariant under agreement on all resolved syntactic state reads,
   with identical arguments, caller/parties, environment and time. Reuse existing
   `Expr.eval_congr_of_resolved` (already proved through syntax induction),
   discharging its state/environment agreement premises from the concrete analysis.
   Include both branches, division errors and observation behavior.
2. Template evaluation inherits that property for complete `Except` results,
   including evaluation errors, and every resolved delta target lies in W.
3. Registered execution preserves exact refusal under agreement on reads plus
   targets, fixed store/boundary/request/config. For the global sufficient-funds
   quantifier, prove effects vanish outside delta targets; those cells already
   satisfy nonnegativity. This argument must not assume `writesOK`, which is checked
   later and could itself refuse. Accounting/footprint/authority checks depend on
   the identical evaluated result and unchanged store.
4. For successful execution, receipts/outputs agree; the target-region balances
   agree between results, and each result frames its own input outside W. Full
   resulting worlds need not be equal when foreign input balances differ.
5. Lift to branch runs with equal local histories, stable local boundaries and
   region agreement; prove equal complete canonical branch observations, equal
   balances on R∪W, unchanged store, and locality outside W. Include refused prefixes.
6. Use checked compatibility and locality to discharge the branch framing premises
   when re-executing the peer. Derive LR/RL correspondence and commutation.

No premise named `commutes`, `sameOutcome`, or a full evaluator framing assumption
may simply assume the advertised conclusion. Initialization/contract preservation
may retain explicit local contract guarantees, clearly separated from the mandatory
unconditional dependency proofs for the existing closed AST. If that dependency
proof is infeasible, the sprint remains incomplete; replacing it with a narrower
patch law requires a revised OpenSpec candidate and both planning audits again.

Generic preservation: exact domain/asset accounting is initial total plus both
receipt supplies; invocation/debit/supply authority is checked in the initial
fixed store at each point of use; every local and merged state is nonnegative;
joined state frames predicates supported on regions outside W_L∪W_R. Prove
joined-state invariant composition for two initialized ledger predicates whose
supports are preserved by the peer; retain explicit individual contract obligations.
Neither general solvency nor automatic invariant inference is claimed.

### 6. Source layout and verification boundaries

| New file | Responsibility |
| --- | --- |
| `lean/DefiKernel/Parallel/Compatibility.lean` | Branch identities/input type, concrete footprint resolution, admission and conflict errors |
| `lean/DefiKernel/Parallel/Dependency.lean` | Expression/template/full executor state-dependency and refusal framing proofs |
| `lean/DefiKernel/Parallel/Execution.lean` | Parallel result, independent branch runs, region merge, canonical observations and serial references |
| `lean/DefiKernel/Parallel/Commutation.lean` | Branch congruence/locality, LR/RL correspondence and singleton commutation |
| `lean/DefiKernel/Parallel/Preservation.lean` | Accounting, authority, ledger frames, conditional initialized invariants |
| `lean/DefiKernel/Parallel/Examples.lean` | Complete financial catalogs/worlds, proof fixtures and counterexamples |
| `lean/DefiKernel/Parallel/Tests.lean` | Named independent finite-world/runtime comparisons |
| `lean/DefiKernel/Parallel/Audit.lean` | Nonempty, duplicate-free runtime audit driver |
| `lean/DefiKernel/Parallel/Verify.lean` | Imported axiom audit |
| `scripts/check_parallel_mutations.py` | Scoped actual-source projection/mutation runner, reuse validated runner machinery where safe |
| `scripts/test_parallel_mutation_runner.py` | Real CLI failure/positive controls |

A proof module may be split at a clear dependency boundary if needed; do not expand
historical claim scope or replace old modules. New proof inventory distinguishes
named generic results, concrete instances, counterexamples, and generated imported
declarations. Check every new proof in the built import closure.

### 7. Reference fixtures and mutation contract

Use the existing finite reference identities/assets and new registered templates
where needed; preserve previous examples. Construct independent same-domain
branches using distinct exact-cell pairs or assets, not a vacuous second branch.
Core fixture: initial Alice USD10/Bob USD0, vault shares20/Alice shares0. L transfers
3 USD Alice→Bob; R transfers4 shares vault→Alice. Final USD7/3 and shares16/4,
all other cells unchanged. Both orders and parallel join must agree exactly.

Add same-asset/different-party disjoint pairs when the reference universe permits;
otherwise extend only the new fixture universe. Add supply-changing branches with
independent asset/cell regions and compare explicit receipt supplies. Add a branch
with two successful steps and a second branch using its own historical output.
Boundary principals/time must differ by branch/local position in a discriminating
fixture; raw time is never used as a financial price.

Routing fixtures use (a) the same local step and numeric port ID in distinct
components selecting distinct cells/values, (b) the same fully qualified local key
for a common read-only cell with equal values, retaining both branch labels, and
(c) a consumer whose local history lacks a peer-only earlier output key. Case (c)
refuses at local index 1 despite that step-0 key existing in the peer history with
the right unit and a value enabling funded, authorized work. An equivalent literal
or a matching own-history key must enable its successful sibling. Mutant 10 uses
this peer-only-key refusal as its designated oracle; equal-valued duplicate keys
alone cannot discriminate a swapped value source. A passing pair cannot emit
different values for the same fully qualified selected-cell port: writing its
selected cell conflicts with the peer snapshot read. Do not invent that fixture.

Negative siblings: same debit cell; hidden guard, delta, and supply-expression read;
inactive expression branch read; output snapshot of peer write; target-only balance
dependency; missing/revoked capability; independent first/middle/both refusals;
branch output qualification and peer-only history keys; unsupported or written frame region.
For each preflight-negative conflict, include a permissive control showing both
operations have sufficient funds/authority and a matched independent sibling.

Required source mutants (each must compile, execute a full named inventory, fail
its designated oracle, and preserve named unrelated positives):

1. Bypass write/write conflict (if redundant guards would mask it, remove the
   redundant corresponding cross-read guards in this explicitly composite mutant).
2. Omit syntactic expression reads from admission together with redundant declared
   read entries that would otherwise mask the omission; record the composite edit.
3. Omit selected outputs from reads.
4. Omit delta targets from both balance dependencies and prospective writes.
5. Omit the reverse-direction write/read conflict.
6. Cancel the peer after a branch refusal.
7. Roll back a refused branch's successful prefix at join.
8. Select one whole branch world instead of region merge.
9. Add whole branch balances, double-counting the initial state.
10. Share branch output history or misroute a colliding output key.
11. Use global positions or the other branch's trusted boundaries.
12. Drop one branch's supply receipts in accounting observation.
13. Reset the capability store used by one branch to a stale/live fixture store.
14. Re-evaluate cached/prestate effects after a state-dependent prefix incorrectly.

For target omission, use a zero/cancelling delta target absent from declared writes
so the unchanged kernel has a valid successful control; alternatively document
an explicit composite removal of redundant target/write inclusions. For expression
read omission, retain valid declared reads in the registered template and weaken
the admission collector comprehensively, so the ordinary conflicting fixture still
has a funded authorized successful underlying-kernel sibling. Deliberately malformed
footprint fixtures remain separate refusal controls with their exact expected errors.
A targeted mutant's guard redundancy must be analyzed before counting it. A
compiler rejection, unapplied edit, omitted check, malformed evidence, or surviving
mutant is never a semantic detection. Proof holes are used only in isolated audit
negative controls and are never accepted into the kernel import root.

### 8. Planning audit gate, implementation acceptance, and delivery

Freeze a concrete OpenSpec commit with proposal/design/four specs/tasks and source
context manifest. Fable and a separate GPT-6 agent audit that same candidate for
semantic contradictions, proof feasibility/non-circularity, coverage, mutation
vacuity, and scope. Save raw prompts/replies, requested/reported identities, source
and bundle hashes, verdicts, findings, and fixes. Pass means explicit ACCEPT or
ACCEPT WITH LIMITATIONS with every blocking finding resolved; advisory limitations
must not waive a SHALL or proof obligation. Unavailable/error/timeout is not pass.
A revised candidate requires affected re-review; both final verdicts must cover
the final candidate. User specifically authorizes execution only after both pass.
Do not write new implementation before that gate. Baseline inspection/verification
and drafting/review fixes may continue independently.

After planning passes, execute the tasks. Build and run all new/existing suites;
commit frozen source before acceptance runs where feasible, preserving honest
run-start identities if otherwise. Obtain native Grok and Fable source/evidence
review, initially plus one targeted re-review for concrete findings. New findings
justify further affected review. Bind executed bytes, reviewed bytes and Git objects;
never relabel dirty execution heads. Complete roadmap/progress, strict validation,
branch push/remote verification, then archive only this change and validate its
four main specs. Save delivery/archive metadata and verify the final branch head.

## Risks / Trade-offs

- Conservative whole-branch regions reject safe unreachable/zero-effect cases →
  document admission behavior and avoid any maximal-parallelism claim.
- Refusal commutation is stronger than successful-effect locality → prove full
  expression/executor dependency before deriving the schedule theorem.
- Global balance checks hide implicit reads → include every potential target and
  prove zero effect outside targets before the sufficient-funds comparison.
- Raw trace worlds differ across orders → expose them as evidence while proving
  only the explicitly defined, still financially complete canonical observation.
- Fixed capabilities exclude administration → use pre-fork revoke controls and
  keep issue/revoke in the already supported sequential operator.
- Fable availability may prevent planning approval → preserve the unavailable
  verdict and pause dependent implementation; do not substitute a different model.

## Migration Plan

Add isolated modules and an import root after the planning gate. Existing production
execution stays unchanged. To withdraw an unaccepted candidate, remove only its new
import/modules on the branch, preserving evidence and previous sprint commits.
All references remain development examples. No deployed migration is performed.

```

### openspec/changes/disjoint-parallel-composition/specs/parallel-compatibility/spec.md
SHA256 4517203ef08b7d0e3728ad2c6ea8bd1e7f111bf1fb733acbe36a1262d062b2eb
```
## Purpose

Identify when two finite registered workflows can run independently without hidden ledger interference or changes to their trusted capability context.

## ADDED Requirements

### Requirement: Concrete conservative footprints
The system SHALL derive branch footprints from every concrete registered invocation, fixed party references, and trusted branch-local caller. Reads SHALL include all syntactic guard/delta/supply reads, both expression branches, declared reads, every potential write target, and selected output cells. Writes SHALL include declared writes and every delta target, including zero or cancelling effects.

#### Scenario: Hidden reads
- **WHEN** a branch guard, delta, supply expression, or inactive expression arm reads a peer write cell
- **THEN** admission rejects the conflict even if that expression is not evaluated on this initial state

#### Scenario: Balance and output dependencies
- **WHEN** a branch has a delta target or selected output cell written by its peer without an explicit expression read
- **THEN** admission still includes that dependency and rejects the conflict

#### Scenario: No financial evaluation during admission
- **WHEN** two requests have identical structural references but different numeric arguments or initial balances
- **THEN** their structural footprint analysis is the same; financial success is decided by execution

### Requirement: Symmetric conflict rejection
The system SHALL admit a pair only if both write regions are disjoint and each write region is disjoint from the other read region. It SHALL permit common read-only cells and SHALL analyze the complete submitted branches, including unreachable suffixes.

#### Scenario: Both conflict directions
- **WHEN** only the right write region intersects the left read region, or only the reverse holds
- **THEN** admission rejects either direction

#### Scenario: Compatible common reads
- **WHEN** both branches read one common cell and neither writes it, with otherwise disjoint regions
- **THEN** admission accepts the pair

#### Scenario: Unreachable conflicting suffix
- **WHEN** a later submitted invocation conflicts even though an earlier invocation would refuse
- **THEN** admission rejects before either branch executes

### Requirement: Stable local inputs and fixed capabilities
The parallel operator SHALL accept invocation-only branches, retain their left/right identities across execution orders, bind trusted principal/environment/time by identity and local index, isolate prior-output lookup to each branch, and use the same immutable initial capability store throughout. Capability issuance and revocation SHALL be excluded from this operator.

#### Scenario: Branch-local boundaries
- **WHEN** branches use different callers or time assumptions at the same local index
- **THEN** each invocation receives its own unchanged boundary under both execution orders

#### Scenario: Prior revocation
- **WHEN** a capability is revoked before the fork
- **THEN** a dependent invocation refuses under that store in every order, while an otherwise identical live-store sibling succeeds

#### Scenario: Administrative input excluded
- **WHEN** a caller attempts to include issue or revoke as a parallel branch entry
- **THEN** the public branch type cannot represent that entry

#### Scenario: Reusable shared grant
- **WHEN** both independent branches refer to a live reusable capability allowed by the existing authority API
- **THEN** admission does not reject solely because the capability identifier is shared

### Requirement: Deterministic preflight refusal
The system SHALL validate the global catalog, analyze left then right invocations in local order, and check write/write then left-write/right-read then right-write/left-read conflicts. An admission refusal SHALL preserve the complete initial world and emit no execution receipt or output. Structural failures SHALL carry branch/local position/cause; conflicts SHALL carry conflict class and a deterministic witness cell.

#### Scenario: Malformed local reference
- **WHEN** a registered invocation contains an unresolvable party/cell reference
- **THEN** admission returns its structural cause and location without committing any prefix

#### Scenario: Multiple admission failures
- **WHEN** both branch analysis and conflict checks would fail
- **THEN** the documented preflight ordering selects a deterministic reason

#### Scenario: Financial refusal kept local
- **WHEN** catalog and references are valid but a request has insufficient funds, unavailable prior output, wrong argument unit, or missing authority
- **THEN** admission does not replace the eventual existing branch-runtime refusal with an invented compatibility success

```

### openspec/changes/disjoint-parallel-composition/specs/parallel-preservation/spec.md
SHA256 03c85fdf69b6edfa4927d39572fa437cff10fba8f031b9fcf8385782f720dd0c
```
## Purpose

Prove independence and financial preservation for the registered executor, including refused outcomes and explicitly scoped observations of disjoint workflows.

## ADDED Requirements

### Requirement: Closed expression and executor dependency
The system SHALL prove that the existing closed expression language and registered invocation executor depend on ledger state only through the analyzed reads and potential effect targets, under identical trusted config, caller, parties, arguments, environment, time and capability store. The proof SHALL cover exact evaluation and execution refusals as well as success; it SHALL NOT assume commutation or evaluator framing as an unchecked premise.

#### Scenario: Expression failure framing
- **WHEN** two nonnegative states agree on analyzed dependencies and evaluation divides by zero or returns another expression error
- **THEN** the exact error is the same

#### Scenario: Implicit balance dependency
- **WHEN** the executor compares sufficient funds over all cells before its write-footprint check
- **THEN** the proof derives zero effect outside resolved delta targets and justifies refusal invariance without assuming the later write check succeeds

#### Scenario: Foreign state changes
- **WHEN** two input states differ only outside a branch dependency region
- **THEN** success/refusal, receipts and outputs match canonically, while each successful result retains its own outside-region balances

### Requirement: Actual serial-order correspondence
For every admitted branch pair and initial world the system SHALL prove equivalence of the parallel observation to actual left-then-right and right-then-left branch re-execution. Each serial reference SHALL execute its second branch on the first branch final world with a fresh local history and the original branch-local boundaries, even after first-branch refusal.

#### Scenario: State-dependent re-execution
- **WHEN** a branch contains guard or effect expressions dependent on its own balances
- **THEN** both serial references re-evaluate the real executor and produce the parallel canonical observation

#### Scenario: Refused first branch
- **WHEN** the first serial branch refuses after a prefix
- **THEN** the second still executes on that prefix world and the theorem retains both exact outcomes

#### Scenario: Independent single steps commute
- **WHEN** each branch contains one invocation
- **THEN** the correspondence theorem yields equal final ledgers/stores and branch-qualified success/refusal/receipt/output observations in either order

### Requirement: Cumulative financial preservation
The system SHALL prove joined accounting for each domain/asset from the sum of both actual successful receipt supplies, invocation/debit/supply authority at each point of use in the fixed initial store, and nonnegativity of branch prefixes and the joined state. It SHALL distinguish proof-carrying nonnegativity from discovered invariants.

#### Scenario: Supply-changing peers
- **WHEN** independent branches mint or burn within authorized disjoint cells
- **THEN** the joined total equals initial total plus both explicit receipt supply sums

#### Scenario: Successful use with refused suffix
- **WHEN** a branch successfully uses authority before a later refusal
- **THEN** the accepted invocation retains its point-of-use authority evidence and accounting contribution

### Requirement: Supported ledger frames and initialized invariants
The system SHALL prove unchanged balances outside the union of branch write regions and frame ledger predicates with explicit support disjoint from that union. It SHALL prove composition of initialized branch ledger invariants from individual preservation obligations and peer-disjoint supports, retaining all local contract and trusted-environment assumptions.

#### Scenario: Protected collateral predicate
- **WHEN** an initialized predicate depends only on untouched collateral cells
- **THEN** it is preserved at the join with its support/disjointness premises discharged for a concrete reference

#### Scenario: Necessary frame premises
- **WHEN** support is omitted or the protected region intersects a branch write
- **THEN** concrete counterexamples show why unconditional framing is false

#### Scenario: Two local invariants
- **WHEN** two initialized supported predicates have individual preservation evidence and the peer cannot write either predicate support
- **THEN** the joined state satisfies both without circular assume-guarantee premises

```

### openspec/changes/disjoint-parallel-composition/specs/parallel-regression-evidence/spec.md
SHA256 93c30bb6e8d985f4320a3d776a9e49a3e6976dc0d79b3fdeb8b1b3e80ab41074
```
## Purpose

Make parallel composition claims reviewable through complete scenario coverage, discriminating source mutations, exact proof scope and independently audited candidates.

## ADDED Requirements

### Requirement: Planning approval before implementation
The OpenSpec candidate SHALL receive independent Fable and GPT-6 audits before implementation begins. Both final verdicts SHALL cover the same committed candidate and be explicit passes with no blocking finding unresolved. Unavailable, timeout, malformed or error responses SHALL NOT count as passes. Advisory limitations SHALL NOT waive a normative requirement.

#### Scenario: Planning candidate passes
- **WHEN** both named reviewers pass the same candidate and all blocking findings are resolved
- **THEN** implementation may begin under the existing user authorization

#### Scenario: Reviewer unavailable or candidate revised
- **WHEN** a required planning reviewer is unavailable or the candidate changes substantively after its verdict
- **THEN** implementation remains gated until the missing or affected candidate audit passes

### Requirement: Complete reference comparisons
The sprint SHALL map every requirement/scenario to named proofs, full finite-world comparisons, compiler controls, or actual acceptance evidence. Financial and isolation negatives SHALL have funded/authorized compatible siblings. Counts SHALL distinguish mathematical proofs from bounded comparisons, counterexamples and measurements.

#### Scenario: Negative targets interference
- **WHEN** a fixture rejects a conflicting branch pair
- **THEN** a funded authorized underlying-executor control and compatible pair show rejection is caused by the intended compatibility condition

#### Scenario: Branch behavior inventory
- **WHEN** the suite runs
- **THEN** it compares complete ledgers/stores and all required canonical observation fields for success, independent refusal, output routing, boundary identity and supply scenarios

### Requirement: Real source mutations and robust controls
Required mutation classes SHALL cover conflict directions, hidden/output/target dependencies, peer cancellation, prefix rollback, lost/doubled merge state, output-history leakage, boundary-index misuse, omitted supplies, stale capability use, and incorrect state-dependent evaluation. Each counted detection SHALL apply a real implementation-source edit, compile and run the full nonempty named inventory, fail designated comparisons, and retain specified unrelated positive controls.

#### Scenario: Semantic detection
- **WHEN** a required mutant compiles and changes observable behavior
- **THEN** saved execution identifies its designated false comparison and surviving positives

#### Scenario: Invalid or vacuous run
- **WHEN** a mutant is missing, unapplied, noncompiling, surviving, or its check inventory is empty/partial/duplicated/malformed
- **THEN** the runner reports failure or blocked execution and never a semantic detection

#### Scenario: Redundant conflict guards
- **WHEN** one guard removal is masked by another required guard
- **THEN** the manifest explicitly uses a justified composite mutation or reports survival; a compile error is not substituted for detection

### Requirement: Integrated proof and regression audit
The sprint SHALL run the full Lean build, new runtime/imported-axiom audit, all existing kernel runtime and imported-axiom drivers, typed/compiler/mutation/runner/axiom controls and corpus regressions. Accepted imported proof code SHALL contain no sorry, custom axiom or native_decide. Original proof and corpus files SHALL remain byte-identical apart from explicitly authorized new import wiring.

#### Scenario: New proof enters import closure
- **WHEN** a new named theorem is counted
- **THEN** its statement and premises appear in the inventory and its declaration is covered by the fresh built imported axiom audit

#### Scenario: Historical regression or drift
- **WHEN** an existing test fails or a preserved file changes
- **THEN** acceptance is blocked until the cause is resolved and affected checks pass

### Requirement: Independent implementation review and delivery
The implemented source/evidence candidate SHALL receive native Grok/Fable review with exact requested/reported model identity and preserved findings. Executed inputs, reviewed bytes, tool versions and Git objects SHALL be bound by verifiable manifests. Delivery SHALL update the roadmap, verify the authorized branch push, archive this accepted OpenSpec change, and validate its synchronized main specs.

#### Scenario: Reviewed source changes
- **WHEN** implementation changes after review or execution began on a dirty predecessor
- **THEN** affected validation/review is refreshed and exact executed/reviewed bytes are compared to committed objects without relabeling original run heads

#### Scenario: Verified branch and archive
- **WHEN** all implementation acceptance checks pass
- **THEN** source/evidence and archive metadata are pushed to the authorized branch with verified remote heads; broader roadmap work stays open

```

### openspec/changes/disjoint-parallel-composition/specs/parallel-workflow-execution/spec.md
SHA256 c9ae7111d496783869ac79c5bb36d4119bede6fdd0627fe3c820dfd1c21b297a
```
## Purpose

Execute independent branch workflows with their own histories and refusal results, and join their permitted ledger changes without losing either branch.

## ADDED Requirements

### Requirement: Independent prefix execution
For an admitted pair the system SHALL execute each branch using the existing sequential invocation semantics from the common initial world. Each branch SHALL stop at its first refusal and retain its successful prefix; refusal in one branch SHALL NOT cancel execution of its peer.

#### Scenario: One branch refuses immediately
- **WHEN** left refuses before any accepted invocation and right contains funded authorized work
- **THEN** right completes and its changes appear in the join

#### Scenario: Middle and dual refusal
- **WHEN** one or both branches refuse after successful invocations
- **THEN** each successful prefix is retained with its own exact reason and local refusal index

#### Scenario: Empty branch identity
- **WHEN** one or both branches are empty
- **THEN** the nonempty branch retains its sequential result; two empty branches preserve the complete initial world

### Requirement: Exact region merge
The system SHALL select each branch final balance only inside its admitted write region and preserve the initial balance elsewhere. The joined capability store SHALL equal the initial store. Actual successful effects SHALL be proved confined to the corresponding admitted region.

#### Scenario: Two funded disjoint branches
- **WHEN** left transfers 3 USD from Alice starting at 10 to Bob starting at 0, and right transfers 4 shares from vault starting at 20 to Alice starting at 0
- **THEN** the join has Alice USD7, Bob USD3, vault shares16, Alice shares4, unchanged other cells, and unchanged capability store

#### Scenario: Common initial balance
- **WHEN** an untouched cell has a nonzero initial balance
- **THEN** its joined balance equals that initial balance once, without duplication

#### Scenario: Refused branch prefix
- **WHEN** a branch writes a cell successfully before a later invocation refuses
- **THEN** merge retains that final prefix balance rather than reverting the branch to initial state

### Requirement: Qualified outputs and receipts
The system SHALL retain exact successful invocation receipt data and immutable typed snapshots, keyed externally by branch identity, local position and qualified port. Each branch SHALL resolve only its own earlier successful outputs, preserving its local ordering and refusal semantics.

#### Scenario: Qualified output identities
- **WHEN** branches emit the same local step and numeric port ID from distinct components selecting different cells, or emit the same fully qualified local key for a common read-only cell
- **THEN** the first case preserves distinct component-qualified values and the second preserves equal snapshots as two branch-labeled observations; neither case conflates the branch histories

#### Scenario: Snapshot after later writes
- **WHEN** a branch writes a previously selected cell again
- **THEN** the earlier snapshot value remains unchanged

#### Scenario: Unavailable or foreign output
- **WHEN** an invocation attempts to consume an earlier key present only in its peer history, or another output not available in its own earlier successful history
- **THEN** that branch refuses without consuming its peer history or altering its prefix

### Requirement: Financially complete canonical observations
The system SHALL expose a canonical observation containing the full joined ledger and capability store plus both branch outcomes, accepted local positions and operation/request identity, actual evaluated receipt data, typed outputs, final local indices, and exact refusal reasons/indices. Equivalence SHALL ignore only global completion order and raw event full-world context; raw isolated branch cursors SHALL remain available as separate evidence.

#### Scenario: Swapped completion order
- **WHEN** an admitted pair is evaluated right first instead of left first
- **THEN** canonical observations retain fixed left/right labels and every required financial field

#### Scenario: Distinct refusal evidence
- **WHEN** two candidate results differ only in refusal reason, local index, output value, supply receipt or final ledger cell
- **THEN** they are not equivalent

#### Scenario: Raw trace context
- **WHEN** a serial second branch sees first-branch changes in cells it cannot depend on
- **THEN** canonical equivalence may hold while raw full pre-worlds differ, and the result does not claim a single shared raw trace

```

### lean/DefiKernel/Acceptance.lean
SHA256 9635558b7bb16a66375358a4936ec73d7ea4b07ee959bf3d2583197584e7ff11
```
import DefiKernel.Examples

/-! Concrete behavior contracts for the bounded reference examples. -/
namespace DefiKernel
open Examples

theorem transfer_accept : check policy () (transfer .alice .alice .bob (Quantity.ofNat 3)) initial =
    none := by decide +kernel

theorem transfer_unauthorized :
    check policy () (transfer .bob .alice .bob (Quantity.ofNat 3)) initial =
      some .unauthorizedDebit := by decide +kernel

theorem transfer_insufficient :
    check policy () (transfer .alice .alice .bob (Quantity.ofNat 11)) initial =
      some .insufficientFunds := by decide +kernel

theorem deposit_accept :
    check policy () (deposit (Quantity.ofNat 4)) initial = none := by decide +kernel

theorem withdraw_accept :
    check policy () (withdraw (Quantity.ofNat 2)) initial = none := by decide +kernel

theorem borrow_accept :
    check policy fresh (borrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem stale_oracle_refused :
    check policy stale (borrow (Quantity.ofNat 3)) initial = some .guard := by decide +kernel

theorem zero_price_refused :
    check policy zeroPrice (borrow (Quantity.ofNat 3)) initial = some .guard := by decide +kernel

theorem future_oracle_refused :
    check policy future (borrow (Quantity.ofNat 3)) initial = some .guard := by decide +kernel

theorem excess_credit_refused :
    check policy fresh (borrow (Quantity.ofNat 9)) initial = some .guard := by decide +kernel

theorem unbalanced_refused :
    check policy () unbalanced initial = some .accounting := by decide +kernel

theorem wrong_asset_refused :
    check policy () wrongAsset initial = some .accounting := by decide +kernel

theorem wrong_footprint_refused :
    check policy () wrongFootprint initial = some .footprint := by decide +kernel

theorem unauthorized_issue_refused :
    check policy () unauthorizedIssue initial = some .unauthorizedSupply := by decide +kernel

theorem wrong_feed_refused :
    check policy { fresh with feed := 8 } (borrow (Quantity.ofNat 3)) initial =
      some .guard := by decide +kernel

theorem insufficient_shares_refused :
    check policy () (withdraw (Quantity.ofNat 5)) initial =
      some .insufficientFunds := by decide +kernel

/-- Twenty USD cannot redeem the requested eleven shares, despite twenty shares being held. -/
theorem insufficient_vault_liquidity_refused :
    check policy () (withdraw (Quantity.ofNat 11)) richShares =
      some .insufficientFunds := by decide +kernel

/-- Zero debt and zero borrowing make the collateral inequality true even at price zero. -/
theorem isolated_zero_price_refused :
    check policy zeroPrice (borrow (Quantity.ofNat 0)) zeroDebt = some .guard := by decide +kernel

theorem zero_borrow_positive_price_accept :
    check policy fresh (borrow (Quantity.ofNat 0)) zeroDebt = none := by decide +kernel

/-- Accepted counterexamples expose grants that are not bound to transition shape. -/
theorem policy_overgrant_vault_drain_accepted :
    check policy () policyVaultDrain initial = none := by decide +kernel

theorem policy_overgrant_unbacked_issue_accepted :
    check policy () policyUnbackedIssue initial = none := by decide +kernel

theorem policy_overgrant_debt_burn_accepted :
    check policy () policyDebtBurn initial = none := by decide +kernel

theorem transfer_post :
    observe (execute policy () (transfer .alice .alice .bob (Quantity.ofNat 3)) initial)
      [(.alice, .usd), (.bob, .usd)] = .ok [7, 3] := by decide +kernel

theorem deposit_post :
    observe (execute policy () (deposit (Quantity.ofNat 4)) initial)
      [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [6, 24, 6] := by decide +kernel

theorem withdraw_post :
    observe (execute policy () (withdraw (Quantity.ofNat 2)) initial)
      [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [14, 16, 2] := by decide +kernel

theorem borrow_post :
    observe (execute policy fresh (borrow (Quantity.ofNat 3)) initial)
      [(.alice, .usd), (.pool, .usd), (.alice, .debt), (.alice, .collateral)] =
      .ok [13, 97, 5, 10] := by decide +kernel

/-- Observable round trip across every cell, not just the deposited asset. -/
theorem vault_round_trip :
    observe (do
      let s ← execute policy () (deposit (Quantity.ofNat 4)) initial
      execute policy () (withdraw (Quantity.ofNat 2)) s) allCells =
      .ok (allCells.map initial.balance) := by decide +kernel

/-- Two borrows update debt; a third is refused using that updated debt. -/
theorem repeated_borrow_refused :
    observe (do
      let s₁ ← execute policy fresh (borrow (Quantity.ofNat 3)) initial
      let s₂ ← execute policy fresh (borrow (Quantity.ofNat 3)) s₁
      execute policy fresh (borrow (Quantity.ofNat 3)) s₂) [(.alice, .debt)] =
      .error .guard := by decide +kernel

theorem unauthorized_execute_refused :
    observe (execute policy () (transfer .bob .alice .bob (Quantity.ofNat 3)) initial)
      allCells = .error .unauthorizedDebit := by decide +kernel

/-- A too-large self-transfer is still a no-op under the documented net-effect semantics. -/
theorem self_transfer_noop :
    observe (execute policy () (transfer .bob .alice .alice (Quantity.ofNat 100)) initial)
      allCells = .ok (allCells.map initial.balance) := by decide +kernel

/-- The vault loses its twenty USD while Alice's share balance is unchanged. -/
theorem policy_overgrant_vault_drain_post :
    observe (execute policy () policyVaultDrain initial)
      [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [30, 0, 4] := by decide +kernel

/-- One hundred shares appear without any USD deposit. -/
theorem policy_overgrant_unbacked_issue_post :
    observe (execute policy () policyUnbackedIssue initial)
      [(.alice, .usd), (.vault, .usd), (.alice, .share)] = .ok [10, 20, 104] := by decide +kernel

/-- Debt disappears without any USD repayment to the pool. -/
theorem policy_overgrant_debt_burn_post :
    observe (execute policy () policyDebtBurn initial)
      [(.alice, .usd), (.pool, .usd), (.alice, .debt)] = .ok [10, 100, 0] := by decide +kernel

/-- This defective effect defeats scalar accounting while violating asset accounting. -/
theorem wrong_asset_scalar_cancels :
    (∑ a, ∑ owner, wrongAsset.effect (owner, a)) = 0 := by decide +kernel

theorem wrong_asset_not_accounted : ¬ Accounted wrongAsset := by decide +kernel

theorem unbalanced_not_accounted : ¬ Accounted unbalanced := by decide +kernel

theorem missing_footprint_changes_balance :
    (.bob, .usd) ∉ wrongFootprint.writes ∧ wrongFootprint.effect (.bob, .usd) = 1 :=
  by decide +kernel

end DefiKernel

```

### lean/DefiKernel/Composition/Contracts.lean
SHA256 d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c
```
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

```

### lean/DefiKernel/Composition/Examples.lean
SHA256 55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064
```
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

```

### lean/DefiKernel/Composition/Execution.lean
SHA256 34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602
```
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

```

### lean/DefiKernel/Composition/ExecutionTests.lean
SHA256 68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5
```
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

```

### lean/DefiKernel/Composition/InterfaceTests.lean
SHA256 710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3
```
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

```

### lean/DefiKernel/Composition/Interfaces.lean
SHA256 4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe
```
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

```

### lean/DefiKernel/Composition/Preservation.lean
SHA256 7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709
```
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

```

### lean/DefiKernel/Composition/Sequence.lean
SHA256 32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729
```
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

```

### lean/DefiKernel/Composition/Tests.lean
SHA256 4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980
```
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

```

### lean/DefiKernel/ContractAcceptance.lean
SHA256 a9dfe9006ea32d590f021fa4b3d1c76411ecc872ee524c40ccf2c1406779828f
```
import DefiKernel.ContractExamples

/-! Kernel-checked finite contract execution and refusal examples, not protocol coverage. -/
namespace DefiKernel.ContractAcceptance
open Examples Contracts ContractExamples

theorem transfer_post :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 3)) initial) allCells = .ok [7, 4, 10, 2, 3, 0,
      0, 0, 20, 0, 0, 0, 100, 0, 0, 0] := by decide +kernel

theorem deposit_post :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) policy ()
      (deposit (Quantity.ofNat 4)) initial) allCells = .ok [6, 6, 10, 2, 0, 0, 0, 0, 24, 0, 0, 0,
      100, 0, 0, 0] := by decide +kernel

theorem withdraw_post :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 2)) policy ()
      (withdraw (Quantity.ofNat 2)) initial) allCells = .ok [14, 2, 10, 2, 0, 0, 0, 0, 16, 0, 0, 0,
      100, 0, 0, 0] := by decide +kernel

theorem borrow_post :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy fresh
      (borrow (Quantity.ofNat 3)) initial) allCells = .ok [13, 4, 10, 5, 0, 0, 0, 0, 20, 0, 0, 0,
      97, 0, 0, 0] := by decide +kernel

theorem vault_drain_base_accepted :
    check policy () policyVaultDrain initial = none := by decide +kernel

theorem vault_drain_refused :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 10)) policy ()
      (policyVaultDrain) initial) allCells = .error .contract := by decide +kernel

theorem unbacked_issue_base_accepted :
    check policy () policyUnbackedIssue initial = none := by decide +kernel

theorem unbacked_issue_refused :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 200)) policy ()
      (policyUnbackedIssue) initial) allCells = .error .contract := by decide +kernel

theorem debt_erasure_base_accepted :
    check policy () policyDebtBurn initial = none := by decide +kernel

theorem debt_erasure_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy fresh
      (⟨policyDebtBurn.actor, policyDebtBurn.effect, policyDebtBurn.supplyChange,
        policyDebtBurn.writes, fun _ _ ↦ true⟩) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_recipient_base_accepted :
    check policy () (transfer .alice .alice .pool (Quantity.ofNat 3)) initial = none := by
  decide +kernel

theorem wrong_recipient_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .pool (Quantity.ofNat 3)) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_source_base_accepted :
    check policy () (transfer .alice .vault .bob (Quantity.ofNat 3)) initial = none := by
  decide +kernel

theorem wrong_source_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .vault .bob (Quantity.ofNat 3)) initial) allCells = .error .contract := by
  decide +kernel

theorem unrelated_cell_base_accepted :
    check policy () (unrelatedEffect) initial = none := by decide +kernel

theorem unrelated_cell_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (unrelatedEffect) initial) allCells = .error .contract := by decide +kernel

theorem wrong_amount_base_accepted :
    check policy () (transfer .alice .alice .bob (Quantity.ofNat 4)) initial = none := by
  decide +kernel

theorem wrong_amount_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 4)) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_actor_base_accepted :
    check policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 0)) initial = none := by decide +kernel

theorem wrong_actor_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 0)) policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 0)) initial) allCells = .error .contract := by
  decide +kernel

theorem wrong_supply_refused :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) policy ()
      (wrongSupply) initial) allCells = .error .contract := by decide +kernel

theorem forged_stale_base_accepted :
    check policy (stale) (forgedBorrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem forged_stale_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (stale)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_zero_price_base_accepted :
    check policy (zeroPrice) (forgedBorrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem forged_zero_price_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (zeroPrice)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_isolated_zero_price_base_accepted :
    check policy (zeroPrice) (forgedBorrow (Quantity.ofNat 0)) zeroDebt = none := by decide +kernel

theorem forged_isolated_zero_price_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy (zeroPrice)
      (forgedBorrow (Quantity.ofNat 0)) zeroDebt) allCells = .error .contract := by decide +kernel

theorem forged_future_base_accepted :
    check policy (future) (forgedBorrow (Quantity.ofNat 3)) initial = none := by decide +kernel

theorem forged_future_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (future)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_wrong_feed_base_accepted :
    check policy ({ fresh with feed := 8 }) (forgedBorrow (Quantity.ofNat 3)) initial = none := by
  decide +kernel

theorem forged_wrong_feed_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy ({ fresh with
      feed := 8 })
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract := by decide +kernel

theorem forged_excess_credit_base_accepted :
    check policy (fresh) (forgedBorrow (Quantity.ofNat 9)) initial = none := by decide +kernel

theorem forged_excess_credit_refused :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 9)) policy (fresh)
      (forgedBorrow (Quantity.ofNat 9)) initial) allCells = .error .contract := by decide +kernel

theorem forged_fresh_post :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy fresh
      (forgedBorrow (Quantity.ofNat 3)) initial) [(.alice, .usd), (.pool, .usd), (.alice, .debt),
      (.alice, .collateral)] = .ok [13, 97, 5, 10] := by decide +kernel

theorem zero_borrow_positive_price_post :
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy fresh
      (forgedBorrow (Quantity.ofNat 0)) zeroDebt) allCells = .ok (allCells.map zeroDebt.balance) :=
      by decide +kernel

theorem base_insufficient_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 11)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 11)) initial) allCells = .error (.base
      .insufficientFunds) := by decide +kernel

theorem base_unauthorized_refused :
    Contracts.observe (run (transferContract .bob .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 3)) initial) allCells = .error (.base
      .unauthorizedDebit) := by decide +kernel

theorem base_footprint_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 1)) policy ()
      (wrongFootprint) initial) allCells = .error (.base .footprint) := by decide +kernel

theorem base_guard_refused :
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      ({ transfer .alice .alice .bob (Quantity.ofNat 3) with guard := fun _ _ ↦ false }) initial)
      allCells = .error (.base .guard) := by decide +kernel

theorem base_supply_refused :
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) { policy with supply
      := fun _ _ ↦ false } ()
      (deposit (Quantity.ofNat 4)) initial) allCells = .error (.base .unauthorizedSupply) := by
  decide +kernel

theorem always_base_accounting_refused :
    Contracts.observe (run (always Unit) policy ()
      (unbalanced) initial) allCells = .error (.base .accounting) := by decide +kernel

theorem withdraw_liquidity_refused :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 11)) policy ()
      (withdraw (Quantity.ofNat 11)) richShares) allCells = .error (.base .insufficientFunds) := by
  decide +kernel

theorem withdraw_shares_refused :
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 5)) policy ()
      (withdraw (Quantity.ofNat 5)) initial) allCells = .error (.base .insufficientFunds) := by
  decide +kernel

end DefiKernel.ContractAcceptance

```

### lean/DefiKernel/ContractAudit.lean
SHA256 600761fd4f41f112218ea3ab9b74062369c28ef9cf483627b57589b8be7159d9
```
import DefiKernel.ContractAcceptance

/-! Fresh executable comparisons over the actual contract wrapper and financial library. -/
namespace DefiKernel.ContractAudit
open Examples Contracts ContractExamples

/-- Bounded regression observations; source mutation replay runs these same comparisons. -/
def runtimeChecks : List (String × Bool) := [
  ("transfer_post", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 3)) initial) allCells = .ok [7, 4, 10, 2, 3, 0,
      0, 0, 20, 0, 0, 0, 100, 0, 0, 0])),
  ("deposit_post", decide (
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) policy ()
      (deposit (Quantity.ofNat 4)) initial) allCells = .ok [6, 6, 10, 2, 0, 0, 0, 0, 24, 0, 0, 0,
      100, 0, 0, 0])),
  ("withdraw_post", decide (
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 2)) policy ()
      (withdraw (Quantity.ofNat 2)) initial) allCells = .ok [14, 2, 10, 2, 0, 0, 0, 0, 16, 0, 0, 0,
      100, 0, 0, 0])),
  ("borrow_post", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy fresh
      (borrow (Quantity.ofNat 3)) initial) allCells = .ok [13, 4, 10, 5, 0, 0, 0, 0, 20, 0, 0, 0,
      97, 0, 0, 0])),
  ("vault_drain_base_accepted", decide (
    check policy () policyVaultDrain initial = none)),
  ("vault_drain_refused", decide (
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 10)) policy ()
      (policyVaultDrain) initial) allCells = .error .contract)),
  ("unbacked_issue_base_accepted", decide (
    check policy () policyUnbackedIssue initial = none)),
  ("unbacked_issue_refused", decide (
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 200)) policy ()
      (policyUnbackedIssue) initial) allCells = .error .contract)),
  ("debt_erasure_base_accepted", decide (
    check policy () policyDebtBurn initial = none)),
  ("debt_erasure_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy fresh
      (⟨policyDebtBurn.actor, policyDebtBurn.effect, policyDebtBurn.supplyChange,
        policyDebtBurn.writes, fun _ _ ↦ true⟩) initial) allCells = .error .contract)),
  ("wrong_recipient_base_accepted", decide (
    check policy () (transfer .alice .alice .pool (Quantity.ofNat 3)) initial = none)),
  ("wrong_recipient_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .pool (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("wrong_source_base_accepted", decide (
    check policy () (transfer .alice .vault .bob (Quantity.ofNat 3)) initial = none)),
  ("wrong_source_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .vault .bob (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("unrelated_cell_base_accepted", decide (
    check policy () (unrelatedEffect) initial = none)),
  ("unrelated_cell_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (unrelatedEffect) initial) allCells = .error .contract)),
  ("wrong_amount_base_accepted", decide (
    check policy () (transfer .alice .alice .bob (Quantity.ofNat 4)) initial = none)),
  ("wrong_amount_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 4)) initial) allCells = .error .contract)),
  ("wrong_actor_base_accepted", decide (
    check policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 0)) initial = none)),
  ("wrong_actor_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 0)) policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 0)) initial) allCells = .error .contract)),
  ("wrong_supply_refused", decide (
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) policy ()
      (wrongSupply) initial) allCells = .error .contract)),
  ("forged_stale_base_accepted", decide (
    check policy (stale) (forgedBorrow (Quantity.ofNat 3)) initial = none)),
  ("forged_stale_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (stale)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("forged_zero_price_base_accepted", decide (
    check policy (zeroPrice) (forgedBorrow (Quantity.ofNat 3)) initial = none)),
  ("forged_zero_price_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (zeroPrice)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("forged_isolated_zero_price_base_accepted", decide (
    check policy (zeroPrice) (forgedBorrow (Quantity.ofNat 0)) zeroDebt = none)),
  ("forged_isolated_zero_price_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy (zeroPrice)
      (forgedBorrow (Quantity.ofNat 0)) zeroDebt) allCells = .error .contract)),
  ("forged_future_base_accepted", decide (
    check policy (future) (forgedBorrow (Quantity.ofNat 3)) initial = none)),
  ("forged_future_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy (future)
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("forged_wrong_feed_base_accepted", decide (
    check policy ({ fresh with feed := 8 }) (forgedBorrow (Quantity.ofNat 3)) initial = none)),
  ("forged_wrong_feed_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy ({ fresh with
      feed := 8 })
      (forgedBorrow (Quantity.ofNat 3)) initial) allCells = .error .contract)),
  ("forged_excess_credit_base_accepted", decide (
    check policy (fresh) (forgedBorrow (Quantity.ofNat 9)) initial = none)),
  ("forged_excess_credit_refused", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 9)) policy (fresh)
      (forgedBorrow (Quantity.ofNat 9)) initial) allCells = .error .contract)),
  ("forged_fresh_post", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 3)) policy fresh
      (forgedBorrow (Quantity.ofNat 3)) initial) [(.alice, .usd), (.pool, .usd), (.alice, .debt),
      (.alice, .collateral)] = .ok [13, 97, 5, 10])),
  ("zero_borrow_positive_price_post", decide (
    Contracts.observe (run (borrowContract .alice .pool (Quantity.ofNat 0)) policy fresh
      (forgedBorrow (Quantity.ofNat 0)) zeroDebt) allCells = .ok (allCells.map zeroDebt.balance))),
  ("base_insufficient_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 11)) policy ()
      (transfer .alice .alice .bob (Quantity.ofNat 11)) initial) allCells = .error (.base
      .insufficientFunds))),
  ("base_unauthorized_refused", decide (
    Contracts.observe (run (transferContract .bob .alice .bob (Quantity.ofNat 3)) policy ()
      (transfer .bob .alice .bob (Quantity.ofNat 3)) initial) allCells = .error (.base
      .unauthorizedDebit))),
  ("base_footprint_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 1)) policy ()
      (wrongFootprint) initial) allCells = .error (.base .footprint))),
  ("base_guard_refused", decide (
    Contracts.observe (run (transferContract .alice .alice .bob (Quantity.ofNat 3)) policy ()
      ({ transfer .alice .alice .bob (Quantity.ofNat 3) with guard := fun _ _ ↦ false }) initial)
      allCells = .error (.base .guard))),
  ("base_supply_refused", decide (
    Contracts.observe (run (depositContract .alice .vault (Quantity.ofNat 4)) { policy with supply
      := fun _ _ ↦ false } ()
      (deposit (Quantity.ofNat 4)) initial) allCells = .error (.base .unauthorizedSupply))),
  ("always_base_accounting_refused", decide (
    Contracts.observe (run (always Unit) policy ()
      (unbalanced) initial) allCells = .error (.base .accounting))),
  ("withdraw_liquidity_refused", decide (
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 11)) policy ()
      (withdraw (Quantity.ofNat 11)) richShares) allCells = .error (.base .insufficientFunds))),
  ("withdraw_shares_refused", decide (
    Contracts.observe (run (withdrawContract .alice .vault (Quantity.ofNat 5)) policy ()
      (withdraw (Quantity.ofNat 5)) initial) allCells = .error (.base .insufficientFunds)))]

#eval show IO Unit from do
  if runtimeChecks.isEmpty then throw (IO.userError "No contract runtime checks were collected")
  let mut failures := 0
  for (name, passed) in runtimeChecks do
    IO.println s!"{name}: {passed}"
    if !passed then failures := failures + 1
  let passed := runtimeChecks.length - failures
  IO.println s!"Contract runtime checks passed: {passed}/{runtimeChecks.length}"
  if failures != 0 then
    throw (IO.userError s!"Contract runtime comparisons failed: {failures}")

end DefiKernel.ContractAudit

```

### lean/DefiKernel/ContractExamples.lean
SHA256 4423c79ae828489f07d5e1a2db93285a6c30b56912b467df40767026f2e0e51b
```
import DefiKernel.Contracts
import DefiKernel.Examples

/-! Financial library contracts over complete finite effects and explicit trusted parameters.
The vault has the reference rate two USD per share. These are not deployed protocol specifications.
Contract selection, actor identity, oracle provenance and locked-collateral meaning remain trusted.
Guard and write-set equality are deliberately absent: execution still enforces both base checks. -/
namespace DefiKernel.ContractExamples
open Examples Contracts

/-- Complete extensional shape: no unexamined balance cell or supply asset is permitted. -/
def Shape {E : Type} (t : Transition E) (actor : Account)
    (effect : Cell → ℚ) (supply : Asset → ℚ) : Prop :=
  t.actor = actor ∧ (∀ c, t.effect c = effect c) ∧ (∀ a, t.supplyChange a = supply a)

instance {E : Type} (t : Transition E) (actor : Account)
    (effect : Cell → ℚ) (supply : Asset → ℚ) : Decidable (Shape t actor effect supply) :=
  inferInstanceAs (Decidable (t.actor = actor ∧
    (∀ c, t.effect c = effect c) ∧ (∀ a, t.supplyChange a = supply a)))

def transferContract (actor src dst : Account) (q : Quantity .usd) : Contract Unit where
  accepts _ _ t := decide (Shape t actor (move .usd src dst q.amount) (fun _ ↦ 0))

def depositContract (actor vaultAccount : Account) (q : Quantity .usd) : Contract Unit where
  accepts _ _ t := decide (Shape t actor
    (fun c ↦ move .usd actor vaultAccount q.amount c + pulse (actor, .share) (q.amount / 2) c)
    (fun a ↦ if a = .share then q.amount / 2 else 0))

def withdrawContract (actor vaultAccount : Account) (q : Quantity .share) : Contract Unit where
  accepts _ _ t := decide (Shape t actor
    (fun c ↦ move .usd vaultAccount actor (2 * q.amount) c - pulse (actor, .share) q.amount c)
    (fun a ↦ if a = .share then -q.amount else 0))

/-- Independent pre-state oracle and collateral requirements, never read from the proposal guard. -/
def BorrowConditions (actor : Account) (q : Quantity .usd) (s : State) (oracle : Oracle) : Prop :=
  oracle.feed = 7 ∧ 0 < oracle.price ∧ oracle.observedAt ≤ oracle.now ∧
    oracle.now ≤ oracle.observedAt + 5 ∧
    2 * (s.balance (actor, .debt) + q.amount) ≤ s.balance (actor, .collateral) * oracle.price

instance (actor : Account) (q : Quantity .usd) (s : State) (oracle : Oracle) :
    Decidable (BorrowConditions actor q s oracle) :=
  inferInstanceAs (Decidable (oracle.feed = 7 ∧ 0 < oracle.price ∧
    oracle.observedAt ≤ oracle.now ∧ oracle.now ≤ oracle.observedAt + 5 ∧
    2 * (s.balance (actor, .debt) + q.amount) ≤ s.balance (actor, .collateral) * oracle.price))

def borrowContract (actor poolAccount : Account) (q : Quantity .usd) : Contract Oracle where
  accepts s oracle t := decide (Shape t actor
    (fun c ↦ move .usd poolAccount actor q.amount c + pulse (actor, .debt) q.amount c)
    (fun a ↦ if a = .debt then q.amount else 0)) &&
    decide (BorrowConditions actor q s oracle)

/-- Preserve the intended borrow shape while making the untrusted proposal guard always true. -/
def forgedBorrow (q : Quantity .usd) : Transition Oracle :=
  { borrow q with guard := fun _ _ ↦ true }

/-- A balanced extra transfer outside the intended operation's two USD cells. -/
def unrelatedEffect : Transition Unit :=
  { transfer .alice .alice .bob (Quantity.ofNat 3) with
    effect := fun c ↦ move .usd .alice .bob 3 c + move .usd .vault .pool 1 c
    writes := {(.alice, .usd), (.bob, .usd), (.vault, .usd), (.pool, .usd)} }

/-- Identical intended balance effects, but a mismatched supply entry. -/
def wrongSupply : Transition Unit :=
  { deposit (Quantity.ofNat 4) with supplyChange := fun a ↦ if a = .share then 3 else 0 }

-- BEGIN PROOFS

/-- Complete shape equality is decidable without equality of functions or constructor tags. -/
theorem shape_self {E : Type} (t : Transition E) : Shape t t.actor t.effect t.supplyChange :=
  ⟨rfl, fun _ ↦ rfl, fun _ ↦ rfl⟩

theorem transfer_shape (actor src dst : Account) (q : Quantity .usd) :
    Shape (transfer actor src dst q) actor (move .usd src dst q.amount) (fun _ ↦ 0) :=
  shape_self _

theorem deposit_shape (q : Quantity .usd) :
    Shape (deposit q) .alice
      (fun c ↦ move .usd .alice .vault q.amount c + pulse (.alice, .share) (q.amount / 2) c)
      (fun a ↦ if a = .share then q.amount / 2 else 0) := shape_self _

theorem withdraw_shape (q : Quantity .share) :
    Shape (withdraw q) .alice
      (fun c ↦ move .usd .vault .alice (2 * q.amount) c - pulse (.alice, .share) q.amount c)
      (fun a ↦ if a = .share then -q.amount else 0) := shape_self _

theorem borrow_shape (q : Quantity .usd) :
    Shape (borrow q) .alice
      (fun c ↦ move .usd .pool .alice q.amount c + pulse (.alice, .debt) q.amount c)
      (fun a ↦ if a = .debt then q.amount else 0) := shape_self _

theorem transfer_constructor_accepts (actor src dst : Account) (q : Quantity .usd) (s : State) :
    (transferContract actor src dst q).accepts s () (transfer actor src dst q) = true := by
  simpa [transferContract] using transfer_shape actor src dst q

theorem deposit_constructor_accepts (q : Quantity .usd) (s : State) :
    (depositContract .alice .vault q).accepts s () (deposit q) = true := by
  simpa [depositContract] using deposit_shape q

theorem withdraw_constructor_accepts (q : Quantity .share) (s : State) :
    (withdrawContract .alice .vault q).accepts s () (withdraw q) = true := by
  simpa [withdrawContract] using withdraw_shape q

theorem borrow_constructor_accepts_iff (q : Quantity .usd) (s : State) (oracle : Oracle) :
    (borrowContract .alice .pool q).accepts s oracle (borrow q) = true ↔
      BorrowConditions .alice q s oracle := by
  simp [borrowContract, borrow_shape]

/-- Any accepted proposal, even one with a forged guard, satisfies the independent conditions. -/
theorem borrow_accepts_conditions (actor poolAccount : Account) (q : Quantity .usd)
    (s : State) (oracle : Oracle) (t : Transition Oracle)
    (h : (borrowContract actor poolAccount q).accepts s oracle t = true) :
    BorrowConditions actor q s oracle := by
  simp only [borrowContract, Bool.and_eq_true, decide_eq_true_eq] at h
  exact h.2

/-- Trusted effects preserve the declared collateral bound for arbitrary successful proposals. -/
theorem borrow_run_collateral_bound (actor poolAccount : Account) (q : Quantity .usd)
    (p : Policy) (s s' : State) (oracle : Oracle) (t : Transition Oracle)
    (h : run (borrowContract actor poolAccount q) p oracle t s = .ok s') :
    2 * s'.balance (actor, .debt) ≤ s'.balance (actor, .collateral) * oracle.price := by
  obtain ⟨hc, hv, rfl⟩ := run_valid_update (borrowContract actor poolAccount q) p oracle t s s' h
  simp only [borrowContract, Bool.and_eq_true, decide_eq_true_eq] at hc
  have he := hc.1.2.1
  have hb := hc.2.2.2.2.2
  simpa [applyEffect, he, move, pulse] using hb

end DefiKernel.ContractExamples

```

### lean/DefiKernel/Contracts.lean
SHA256 22ec064df455f9472d7c48b956d27f700fc54862f1d7f0bb0acb1051b84e84b2
```
import DefiKernel.Core

/-! Trusted contracts constrain proposals before the unchanged finite executor runs.
The caller selecting a contract and its parameters is trusted; this is not authentication. -/
namespace DefiKernel.Contracts

/-- Executable state/environment/proposal predicate selected outside the untrusted proposal. -/
structure Contract (E : Type) where
  accepts : State → E → Transition E → Bool

/-- Contract rejection and each original executor rejection remain distinguishable. -/
inductive Failure where
  | contract
  | base (reason : Refusal)
  deriving DecidableEq, Repr

/-- Embed the original result without changing its state or refusal reason. -/
def liftBase (result : Except Refusal State) : Except Failure State :=
  match result with
  | .error reason => .error (.base reason)
  | .ok s => .ok s

/-- A failed contract returns no successful state. The proposal cannot replace this predicate. -/
def run {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s : State) : Except Failure State :=
  if contract.accepts s env t then liftBase (execute p env t s) else .error .contract

/-- The vacuous contract is useful for stating conservative recovery of base execution. -/
def always (E : Type) : Contract E := ⟨fun _ _ _ ↦ true⟩

/-- Observe exact balances while retaining the wrapper refusal. -/
def observe (result : Except Failure State) (cells : List Cell) : Except Failure (List ℚ) :=
  result.map (fun s ↦ cells.map s.balance)

-- BEGIN PROOFS

theorem liftBase_ok_iff (result : Except Refusal State) (s' : State) :
    liftBase result = .ok s' ↔ result = .ok s' := by
  cases result <;> simp [liftBase]

/-- Success means both trusted contract satisfaction and actual base execution success. -/
theorem run_ok_iff {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) :
    run contract p env t s = .ok s' ↔
      contract.accepts s env t = true ∧ execute p env t s = .ok s' := by
  by_cases hc : contract.accepts s env t = true
  · simp [run, hc, liftBase_ok_iff]
  · simp [run, hc]

/-- Successful execution retains every original check and the exact update equation. -/
theorem run_valid_update {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s') :
    contract.accepts s env t = true ∧
      ∃ hv : Valid p env t s, applyEffect s t hv.2.2.2.1 = s' := by
  obtain ⟨hc, hb⟩ := (run_ok_iff contract p env t s s').mp h
  exact ⟨hc, (execute_ok_iff p env t s s').mp hb⟩

theorem run_always {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
    run (always E) p env t s = liftBase (execute p env t s) := rfl

theorem run_contract_refused {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s : State) (hc : contract.accepts s env t = false) :
    run contract p env t s = .error .contract := by simp [run, hc]

theorem run_base_refused {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s : State) (reason : Refusal)
    (hc : contract.accepts s env t = true) (hb : execute p env t s = .error reason) :
    run contract p env t s = .error (.base reason) := by simp [run, hc, hb, liftBase]

theorem run_accounting {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s') (a : Asset) :
    total s' a = total s a + t.supplyChange a :=
  execute_accounting p env t s s' ((run_ok_iff contract p env t s s').mp h).2 a

theorem run_locality {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s')
    (c : Cell) (hc : c ∉ t.writes) : s'.balance c = s.balance c :=
  execute_locality p env t s s' ((run_ok_iff contract p env t s s').mp h).2 c hc

theorem run_authority {E : Type} (contract : Contract E) (p : Policy) (env : E)
    (t : Transition E) (s s' : State) (h : run contract p env t s = .ok s') :
    DebitAuthorized p t ∧ SupplyAuthorized p t :=
  execute_authority p env t s s' ((run_ok_iff contract p env t s s').mp h).2

end DefiKernel.Contracts

```

### lean/DefiKernel/Core.lean
SHA256 767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d
```
import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod
import Mathlib.Tactic.Linarith

/-!
A finite reference ledger with exact rational arithmetic. Asset indices distinguish units;
nonnegative quantities and states exclude negative holdings. Effects are signed changes.
Authority policy and environment inputs are supplied assumptions, not authenticated facts.
Authority checks concern net debits, not intermediate execution traces.
Only write locality is checked: this pilot does not track reads or prove composition.
-/
namespace DefiKernel

inductive Account where
  | alice | bob | vault | pool
  deriving DecidableEq, Repr

inductive Asset where
  | usd | share | collateral | debt
  deriving DecidableEq, Repr

instance : Fintype Account := ⟨{.alice, .bob, .vault, .pool}, by
  intro x; cases x <;> simp⟩

instance : Fintype Asset := ⟨{.usd, .share, .collateral, .debt}, by
  intro x; cases x <;> simp⟩

abbrev Cell := Account × Asset

/-- Exact nonnegative quantity in the unit of asset `a`. -/
structure Quantity (a : Asset) where
  amount : ℚ
  nonneg : 0 ≤ amount

def Quantity.ofNat {a : Asset} (n : ℕ) : Quantity a := ⟨n, by positivity⟩

/-- Debt is a separate nonnegative obligation token, not a negative cash balance. -/
structure State where
  balance : Cell → ℚ
  nonneg : ∀ c, 0 ≤ balance c

/-- External capability policy. Permission to debit and to change supply are separate. -/
structure Policy where
  debit : Account → Cell → Bool
  supply : Account → Asset → Bool

/-- A proposal with explicit net effects, per-asset issuance/burn, and write footprint. -/
structure Transition (Env : Type) where
  actor : Account
  effect : Cell → ℚ
  supplyChange : Asset → ℚ
  writes : Finset Cell
  guard : State → Env → Bool

inductive Refusal where
  | guard | unauthorizedDebit | unauthorizedSupply | insufficientFunds | accounting | footprint
  deriving DecidableEq, Repr

def DebitAuthorized {E : Type} (p : Policy) (t : Transition E) : Prop :=
  ∀ c, t.effect c < 0 → p.debit t.actor c = true

def SupplyAuthorized {E : Type} (p : Policy) (t : Transition E) : Prop :=
  ∀ a, t.supplyChange a ≠ 0 → p.supply t.actor a = true

def NonnegativeUpdate {E : Type} (s : State) (t : Transition E) : Prop :=
  ∀ c, 0 ≤ s.balance c + t.effect c

def Accounted {E : Type} (t : Transition E) : Prop :=
  ∀ a, ∑ owner, t.effect (owner, a) = t.supplyChange a

def Local {E : Type} (t : Transition E) : Prop :=
  ∀ c, c ∉ t.writes → t.effect c = 0

instance {E : Type} (p : Policy) (t : Transition E) : Decidable (DebitAuthorized p t) :=
  inferInstanceAs (Decidable (∀ c, t.effect c < 0 → p.debit t.actor c = true))
instance {E : Type} (p : Policy) (t : Transition E) : Decidable (SupplyAuthorized p t) :=
  inferInstanceAs (Decidable (∀ a, t.supplyChange a ≠ 0 → p.supply t.actor a = true))
instance {E : Type} (s : State) (t : Transition E) : Decidable (NonnegativeUpdate s t) :=
  inferInstanceAs (Decidable (∀ c, 0 ≤ s.balance c + t.effect c))
instance {E : Type} (t : Transition E) : Decidable (Accounted t) :=
  inferInstanceAs (Decidable (∀ a, ∑ owner, t.effect (owner, a) = t.supplyChange a))
instance {E : Type} (t : Transition E) : Decidable (Local t) :=
  inferInstanceAs (Decidable (∀ c, c ∉ t.writes → t.effect c = 0))

/-- Checks actual finite effects. The first failing check determines the refusal reason. -/
def check {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
    Option Refusal :=
  if t.guard s env = false then some .guard
  else if ¬ DebitAuthorized p t then some .unauthorizedDebit
  else if ¬ SupplyAuthorized p t then some .unauthorizedSupply
  else if ¬ NonnegativeUpdate s t then some .insufficientFunds
  else if ¬ Accounted t then some .accounting
  else if ¬ Local t then some .footprint
  else none

/-- The explicit conjunction checked by `check`; no inference of external truth is claimed. -/
def Valid {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) : Prop :=
  t.guard s env = true ∧ DebitAuthorized p t ∧ SupplyAuthorized p t ∧
    NonnegativeUpdate s t ∧ Accounted t ∧ Local t

theorem check_eq_none_iff {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
    check p env t s = none ↔ Valid p env t s := by
  by_cases hg : t.guard s env = true
  · by_cases hd : DebitAuthorized p t <;>
      by_cases hs : SupplyAuthorized p t <;>
      by_cases hn : NonnegativeUpdate s t <;>
      by_cases ha : Accounted t <;>
      by_cases hl : Local t <;> simp [check, Valid, hg, hd, hs, hn, ha, hl]
  · have hf : t.guard s env = false := Bool.eq_false_iff.mpr hg
    simp [check, Valid, hf]

/-- Apply a checked effect; its nonnegativity proof constructs the resulting state. -/
def applyEffect {E : Type} (s : State) (t : Transition E) (h : NonnegativeUpdate s t) : State :=
  ⟨fun c ↦ s.balance c + t.effect c, h⟩

/-- Refusal has no post-state; successful execution constructs a nonnegative state. -/
def execute {E : Type} (p : Policy) (env : E) (t : Transition E) (s : State) :
    Except Refusal State :=
  match h : check p env t s with
  | some reason => .error reason
  | none => .ok (applyEffect s t ((check_eq_none_iff p env t s).mp h).2.2.2.1)

def total (s : State) (a : Asset) : ℚ := ∑ owner, s.balance (owner, a)

/-- Accounting is asset-wise and includes explicit authorized issuance or burn. -/
theorem applyEffect_accounting {E : Type} (s : State) (t : Transition E)
    (h : NonnegativeUpdate s t) (ha : Accounted t) (a : Asset) :
    total (applyEffect s t h) a = total s a + t.supplyChange a := by
  simp only [total, applyEffect, Finset.sum_add_distrib, ha a]

theorem applyEffect_locality {E : Type} (s : State) (t : Transition E)
    (h : NonnegativeUpdate s t) (hl : Local t) (c : Cell) (hc : c ∉ t.writes) :
    (applyEffect s t h).balance c = s.balance c := by
  simp [applyEffect, hl c hc]

/-- A framed predicate must explicitly depend only on observations outside the write set. -/
theorem applyEffect_frame {E : Type} (s : State) (t : Transition E)
    (h : NonnegativeUpdate s t) (hl : Local t) (P : State → Prop)
    (depends : ∀ s₁ s₂ : State,
      (∀ c, c ∉ t.writes → s₁.balance c = s₂.balance c) → (P s₁ ↔ P s₂))
    (hp : P s) : P (applyEffect s t h) := by
  apply (depends s (applyEffect s t h) ?_).mp hp
  intro c hc
  exact (applyEffect_locality s t h hl c hc).symm

/-- Success entails the checks and the precise state update, linking execution to the proofs. -/
theorem execute_ok_iff {E : Type} (p : Policy) (env : E) (t : Transition E)
    (s s' : State) : execute p env t s = .ok s' ↔
      ∃ h : Valid p env t s, applyEffect s t h.2.2.2.1 = s' := by
  unfold execute
  split
  next reason he =>
    simp only [reduceCtorEq, false_iff, not_exists]
    intro hv
    have hn := (check_eq_none_iff p env t s).mpr hv
    simp [he] at hn
  next he =>
    constructor
    · intro hs
      exact ⟨(check_eq_none_iff p env t s).mp he, Except.ok.inj hs⟩
    · rintro ⟨hv, rfl⟩
      rfl

/-- Every accepted net debit has the supplied policy's authority.
Identity authentication is external. -/
theorem execute_authority {E : Type} (p : Policy) (env : E) (t : Transition E)
    (s s' : State) (h : execute p env t s = .ok s') :
    DebitAuthorized p t ∧ SupplyAuthorized p t := by
  obtain ⟨hv, _⟩ := (execute_ok_iff p env t s s').mp h
  exact ⟨hv.2.1, hv.2.2.1⟩

theorem execute_accounting {E : Type} (p : Policy) (env : E) (t : Transition E)
    (s s' : State) (h : execute p env t s = .ok s') (a : Asset) :
    total s' a = total s a + t.supplyChange a := by
  obtain ⟨hv, rfl⟩ := (execute_ok_iff p env t s s').mp h
  exact applyEffect_accounting s t hv.2.2.2.1 hv.2.2.2.2.1 a

theorem execute_locality {E : Type} (p : Policy) (env : E) (t : Transition E)
    (s s' : State) (h : execute p env t s = .ok s') (c : Cell) (hc : c ∉ t.writes) :
    s'.balance c = s.balance c := by
  obtain ⟨hv, rfl⟩ := (execute_ok_iff p env t s s').mp h
  exact applyEffect_locality s t hv.2.2.2.1 hv.2.2.2.2.2 c hc

end DefiKernel

```

### lean/DefiKernel/Examples.lean
SHA256 3a3eaf5e43e5a98cb179785789e850d333652a60f112cba9b0df5ce80bf26d28
```
import DefiKernel.Core
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.NormNum

/-!
Reference models, not deployed protocol specifications. The finite universe has four accounts
and four assets. Arithmetic is unbounded exact rational arithmetic, without machine rounding.
The fixed vault rate is two USD units per share. Credit records a nonnegative debt token and
uses declared locked collateral; oracle identity, age and price bounds do not prove market truth.
-/
namespace DefiKernel.Examples

/-- A signed effect on exactly one asset/account cell. -/
def pulse (target : Cell) (amount : ℚ) (c : Cell) : ℚ :=
  if c = target then amount else 0

/-- Net movement handles self-transfers by cancellation. -/
def move (asset : Asset) (src dst : Account) (amount : ℚ) (c : Cell) : ℚ :=
  pulse (dst, asset) amount c - pulse (src, asset) amount c

/-- Alice has explicit vault/pool USD debit and share/debt supply capabilities in this fixture.
This policy is an input assumption; the kernel does not authenticate or derive the grant.
Grants are not bound to transition shape: accepted counterexamples below drain the vault,
issue unbacked shares, and burn debt without repayment. This is not a protocol access policy. -/
def policy : Policy where
  debit actor c := decide (actor = c.1 ∨
    (actor = .alice ∧ (c = (.vault, .usd) ∨ c = (.pool, .usd))))
  supply actor asset := decide (actor = .alice ∧ (asset = .share ∨ asset = .debt))

/-- A single nonnegative initial ledger, including ten units of declared locked collateral. -/
def initial : State where
  balance c := match c with
    | (.alice, .usd) => 10
    | (.alice, .share) => 4
    | (.alice, .collateral) => 10
    | (.alice, .debt) => 2
    | (.vault, .usd) => 20
    | (.pool, .usd) => 100
    | _ => 0
  nonneg c := by rcases c with ⟨owner, asset⟩; cases owner <;> cases asset <;> norm_num

/-- A USD transfer. Zero and self-transfers are permitted; only net debits require authority. -/
def transfer (actor src dst : Account) (q : Quantity .usd) : Transition Unit where
  actor := actor
  effect := move .usd src dst q.amount
  supplyChange := fun _ ↦ 0
  writes := {(src, .usd), (dst, .usd)}
  guard := fun _ _ ↦ true

/-- Deposit USD and mint shares at the exact fixed rate two USD per share. -/
def deposit (q : Quantity .usd) : Transition Unit where
  actor := .alice
  effect := fun c ↦ move .usd .alice .vault q.amount c + pulse (.alice, .share) (q.amount / 2) c
  supplyChange := fun a ↦ if a = .share then q.amount / 2 else 0
  writes := {(.alice, .usd), (.vault, .usd), (.alice, .share)}
  guard := fun _ _ ↦ true

/-- Burn shares and withdraw USD at the same fixed rate. Liquidity and shares are checked. -/
def withdraw (q : Quantity .share) : Transition Unit where
  actor := .alice
  effect := fun c ↦ move .usd .vault .alice (2 * q.amount) c - pulse (.alice, .share) q.amount c
  supplyChange := fun a ↦ if a = .share then -q.amount else 0
  writes := {(.alice, .usd), (.vault, .usd), (.alice, .share)}
  guard := fun _ _ ↦ true

/-- Declared oracle observation: feed identifier and timestamps are not authenticated here.
Price has the declared unit USD per collateral unit. Debt is denominated in USD units. -/
structure Oracle where
  feed : ℕ
  price : ℚ
  observedAt : ℕ
  now : ℕ
  deriving Repr

/-- Borrow USD and mint an equal USD-denominated debt obligation. The reference guard requires
feed 7, positive price, age at most five, no future timestamp, and 200% collateralization using
that declared price and the pre-state's declared locked collateral. No market solvency claim. -/
def borrow (q : Quantity .usd) : Transition Oracle where
  actor := .alice
  effect := fun c ↦ move .usd .pool .alice q.amount c + pulse (.alice, .debt) q.amount c
  supplyChange := fun a ↦ if a = .debt then q.amount else 0
  writes := {(.alice, .usd), (.pool, .usd), (.alice, .debt)}
  guard := fun s oracle ↦ decide (oracle.feed = 7 ∧ 0 < oracle.price ∧
    oracle.observedAt ≤ oracle.now ∧ oracle.now ≤ oracle.observedAt + 5 ∧
    2 * (s.balance (.alice, .debt) + q.amount) ≤
      s.balance (.alice, .collateral) * oracle.price)

def fresh : Oracle := ⟨7, 2, 98, 100⟩
def stale : Oracle := ⟨7, 2, 90, 100⟩
def zeroPrice : Oracle := ⟨7, 0, 98, 100⟩
def future : Oracle := ⟨7, 2, 101, 100⟩

/-- Broken effects, not a bad proof premise: one USD is debited but two are credited. -/
def unbalanced : Transition Unit :=
  { transfer .alice .alice .bob (Quantity.ofNat 1) with
    effect := fun c ↦ pulse (.bob, .usd) 2 c - pulse (.alice, .usd) 1 c }

/-- Scalar deltas cancel, but one USD cannot account for a share. -/
def wrongAsset : Transition Unit :=
  { transfer .alice .alice .bob (Quantity.ofNat 1) with
    effect := fun c ↦ pulse (.bob, .share) 1 c - pulse (.alice, .usd) 1 c
    writes := {(.alice, .usd), (.bob, .share)} }

/-- Balanced and authorized, but omits a cell that really changes. -/
def wrongFootprint : Transition Unit :=
  { transfer .alice .alice .bob (Quantity.ofNat 1) with writes := {(.alice, .usd)} }

/-- Correctly balanced issuance with no grant to change share supply. -/
def unauthorizedIssue : Transition Unit where
  actor := .bob
  effect := pulse (.bob, .share) 1
  supplyChange := fun a ↦ if a = .share then 1 else 0
  writes := {(.bob, .share)}
  guard := fun _ _ ↦ true

/-- Counterexample fixture isolates vault liquidity from share ownership. -/
def richShares : State where
  balance c := if c = (.alice, .share) then 20 else initial.balance c
  nonneg c := by
    split
    · norm_num
    · exact initial.nonneg c

/-- Accepted policy counterexample: no share burn accompanies this vault debit. -/
def policyVaultDrain : Transition Unit := transfer .alice .vault .alice (Quantity.ofNat 20)

/-- Accepted policy counterexample: supply permission alone does not require a deposit. -/
def policyUnbackedIssue : Transition Unit where
  actor := .alice
  effect := pulse (.alice, .share) 100
  supplyChange := fun a ↦ if a = .share then 100 else 0
  writes := {(.alice, .share)}
  guard := fun _ _ ↦ true

/-- Accepted policy counterexample: the owner may burn debt without repayment. -/
def policyDebtBurn : Transition Unit where
  actor := .alice
  effect := pulse (.alice, .debt) (-2)
  supplyChange := fun a ↦ if a = .debt then -2 else 0
  writes := {(.alice, .debt)}
  guard := fun _ _ ↦ true

/-- Zero debt isolates the positive-price conjunct when the requested borrow is also zero. -/
def zeroDebt : State where
  balance c := if c = (.alice, .debt) then 0 else initial.balance c
  nonneg c := by
    split
    · norm_num
    · exact initial.nonneg c

/-- Constructor accounting holds for every amount, independently of execution guards. -/
theorem transfer_accounted (actor src dst : Account) (q : Quantity .usd) :
    Accounted (transfer actor src dst q) := by
  intro a
  cases src <;> cases dst <;> cases a <;>
    simp [transfer, move, pulse]

theorem deposit_accounted (q : Quantity .usd) : Accounted (deposit q) := by
  intro a
  cases a <;> simp [deposit, move, pulse]

theorem withdraw_accounted (q : Quantity .share) : Accounted (withdraw q) := by
  intro a
  cases a <;> simp [withdraw, move, pulse]

theorem borrow_accounted (q : Quantity .usd) : Accounted (borrow q) := by
  intro a
  cases a <;> simp [borrow, move, pulse]

/-- Executable observation preserves the refusal reason. -/
def observe (result : Except Refusal State) (cells : List Cell) : Except Refusal (List ℚ) :=
  result.map (fun s ↦ cells.map s.balance)

/-- Explicit complete finite observation domain, in stable display order. -/
def allCells : List Cell :=
  ([.alice, .bob, .vault, .pool] : List Account).flatMap fun owner ↦
    ([.usd, .share, .collateral, .debt] : List Asset).map fun asset ↦ (owner, asset)

theorem allCells_complete (c : Cell) : c ∈ allCells := by
  rcases c with ⟨owner, asset⟩
  cases owner <;> cases asset <;> decide

/-- Accepted borrowing preserves the example's declared-price collateral bound in its post-state.
This is conditional on the guard and on the external meaning of price and locked collateral. -/
theorem borrow_declared_collateral_bound (p : Policy) (oracle : Oracle) (q : Quantity .usd)
    (s s' : State) (h : execute p oracle (borrow q) s = .ok s') :
    2 * s'.balance (.alice, .debt) ≤ s'.balance (.alice, .collateral) * oracle.price := by
  obtain ⟨hv, rfl⟩ := (execute_ok_iff p oracle (borrow q) s s').mp h
  have hg := hv.1
  simp only [borrow, decide_eq_true_eq] at hg
  simpa [applyEffect, borrow, move, pulse] using hg.2.2.2.2

end DefiKernel.Examples

```

### lean/DefiKernel/Parallel/Audit.lean
SHA256 d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9
```
import DefiKernel.Parallel.CompatibilityTests
import DefiKernel.Parallel.ObservationTests
import DefiKernel.Parallel.ExecutionTests
import DefiKernel.Parallel.Tests

/-! Complete named runtime inventory. Source mutation projections execute this same driver. -/
namespace DefiKernel.Parallel

def runtimeChecks : List (String × Bool) :=
  CompatibilityTests.checks ++ ObservationTests.checks ++ ExecutionTests.checks ++ Tests.checks

#eval do
  if runtimeChecks.isEmpty then throw (IO.userError "Empty parallel runtime inventory")
  let names := runtimeChecks.map Prod.fst
  if names.eraseDups.length != names.length then
    throw (IO.userError "Duplicate parallel runtime names")
  let mut failed := 0
  for (label, passed) in runtimeChecks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Parallel runtime comparisons failed: {failed}")

end DefiKernel.Parallel

```

### lean/DefiKernel/Parallel/Commutation.lean
SHA256 c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef
```
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

```

### lean/DefiKernel/Parallel/Compatibility.lean
SHA256 4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243
```
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

```

### lean/DefiKernel/Parallel/CompatibilityTests.lean
SHA256 d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379
```
import DefiKernel.Parallel.Compatibility
import DefiKernel.Composition.Examples

/-! Bounded admission controls with independently specified footprint lists and financial siblings.
These are development fixtures; generic proof obligations are in Compatibility. -/
namespace DefiKernel.Parallel.CompatibilityTests
open Typed Composition Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev F := Footprint Party Asset Domain
abbrev I := Invocation Party Asset Domain

def aliceUSD : C := (.main, .alice, .usd)
def bobUSD : C := (.main, .bob, .usd)
def vaultShare : C := (.main, .vault, .share)
def aliceShare : C := (.main, .alice, .share)
def common : C := (.main, .alice, .collateral)
def cellRef (c : C) : CellRef Party Asset Domain c.2.2 := ⟨c.1, .literal c.2.1⟩
def packed (c : C) : PackedCellRef Party Asset Domain := ⟨c.2.2, cellRef c⟩
def transferOp (a : Asset) (sender recipient : Party) (q : ℚ) : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, ref a (.literal sender), .lit (-q)⟩,
    ⟨a, ref a (.literal recipient), .lit q⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef a (.literal sender), packedRef a (.literal recipient)]
def usdOp := transferOp .usd .alice .bob 3
def shareOp := transferOp .share .vault .alice 4
def readOnly (c : C) : Op := { usdOp with
  guard := .binary (.le (.amount c.2.2)) (.lit 0) (.balance (cellRef c))
  deltas := [], writes := [], stateReads := [packed c] }
def hidden (t : Op) (c : C) : Op := { t with
  guard := .ite (.lit true) t.guard
    (.binary (.le (.amount c.2.2)) (.lit 0) (.balance (cellRef c)))
  stateReads := [packed c] }
def cfg (left : Op := usdOp) (right : Op := shareOp)
    (leftOutput : List C := []) (rightOutput : List C := []) : Config Party Asset Domain where
  registry op := if op = ⟨10⟩ then some left else if op = ⟨11⟩ then some right else none
  domainAdmin := domainAdmin
  catalog := [⟨⟨0⟩, ([Domain.main, .other].flatMap fun d ↦
    [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
      [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)), [], [],
    [⟨⟨10⟩, [], leftOutput.map (fun c ↦ ⟨⟨0⟩, c⟩)⟩,
     ⟨⟨11⟩, [], rightOutput.map (fun c ↦ ⟨⟨1⟩, c⟩)⟩]⟩]
def boundary (_ : BranchId) (_ : Nat) : Boundary Party Asset Domain :=
  ⟨aliceContext, fresh, 100⟩
def left : I := ⟨⟨0⟩, ⟨10⟩, [], [], [⟨0⟩, ⟨1⟩], none⟩
def right : I := ⟨⟨0⟩, ⟨11⟩, [], [], [⟨2⟩, ⟨3⟩], none⟩
def leftFP : F := ⟨[aliceUSD, bobUSD, aliceUSD, bobUSD],
  [aliceUSD, bobUSD, aliceUSD, bobUSD]⟩
def rightFP : F := ⟨[vaultShare, aliceShare, vaultShare, aliceShare],
  [vaultShare, aliceShare, vaultShare, aliceShare]⟩
def initial : World Party Asset Domain := ⟨⟨fun c ↦
  if c = aliceUSD then 10 else if c = vaultShare then 20 else 0,
  by
    intro c
    split
    · decide
    · split <;> decide⟩,
  ⟨[⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .main, ⟨10⟩, .debit aliceUSD⟩, true⟩,
    ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
    ⟨⟨.alice, .main, ⟨11⟩, .debit vaultShare⟩, true⟩]⟩⟩
def accepted {E X : Type} : Except E X → Bool
  | .ok _ => true
  | .error _ => false
def resultEq {E X : Type} [DecidableEq E] [DecidableEq X]
    (actual expected : Except E X) : Bool := decide (actual = expected)
def funded (config : Config Party Asset Domain) (inv : I) : Bool :=
  accepted (executeStep config (boundary .left 0) 0 [] (.invoke inv) initial)
def fundedExact (inv : I) (expected : C → ℚ) : Bool :=
  match executeStep cfg (boundary .left 0) 0 [] (.invoke inv) initial with
  | .error _ => false
  | .ok result => decide ((∀ c, result.world.state.balance c = expected c) ∧
      result.world.capabilities = initial.capabilities)
def overlap (kind : ConflictKind) (cell : C) :
    Except (AdmissionFailure Party Asset Domain) (F × F) :=
  .error (.conflict kind cell)
def zeroTarget : Op := { (readOnly common) with
  guard := .lit true
  stateReads := []
  deltas := [⟨.usd, cellRef aliceUSD, .lit 0⟩] }
def hiddenDelta : Op := { shareOp with
  deltas := shareOp.deltas.map (fun d ↦ { d with
    amount := .ite (.lit true) d.amount
      (.binary (.unconvert d.asset .usd) (.balance (cellRef aliceUSD)) (.lit 1)) })
  stateReads := [packed aliceUSD] }
def hiddenSupply : Op := { shareOp with
  supplyDeltas := [⟨.main, .usd,
    .ite (.lit true) (.lit 0) (.balance (cellRef aliceUSD))⟩]
  stateReads := [packed aliceUSD] }
def malformed : Op := { usdOp with stateReads := [packedRef .usd (.argument 3)] }
def deniedCfg : Config Party Asset Domain := { cfg with
  catalog := (cfg.catalog.map fun c ↦ { c with privateCells := [vaultShare, aliceShare] }) }
def checks : List (String × Bool) := [
  ("parallel.compat.catalog-positive", validateCatalog cfg.registry cfg.catalog),
  ("parallel.compat.invocation-exact-left", resultEq
    (analyzeInvocation cfg (boundary .left 0) left) (.ok leftFP)),
  ("parallel.compat.invocation-exact-right", resultEq
    (analyzeInvocation cfg (boundary .right 0) right) (.ok rightFP)),
  ("parallel.compat.funded-left-complete", fundedExact left
    (fun c ↦ if c = aliceUSD then 7 else if c = bobUSD then 3 else initial.state.balance c)),
  ("parallel.compat.funded-right-complete", fundedExact right
    (fun c ↦ if c = vaultShare then 16 else if c = aliceShare then 4 else initial.state.balance c)),
  ("parallel.compat.independent", resultEq (admit cfg boundary [left] [right])
    (.ok (leftFP, rightFP))),
  ("parallel.compat.empty", resultEq (admit cfg boundary [] []) (.ok (.empty, .empty))),
  ("parallel.compat.left-empty", resultEq (admit cfg boundary [] [right])
    (.ok (.empty, rightFP))),
  ("parallel.compat.common-read", accepted
    (admit (cfg (hidden usdOp common) (hidden shareOp common)) boundary [left] [right])),
  ("parallel.compat.write-write-witness", resultEq (admit cfg boundary [left] [left])
    (overlap .writeWrite aliceUSD)),
  ("parallel.compat.forward-read", resultEq
    (admit (cfg usdOp (readOnly aliceUSD)) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.reverse-read", resultEq
    (admit (cfg (readOnly vaultShare) shareOp) boundary [left] [right])
    (overlap .rightWriteLeftRead vaultShare)),
  ("parallel.compat.hidden-inactive-guard", resultEq
    (admit (cfg usdOp (hidden shareOp aliceUSD)) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-inactive-guard-funded",
    funded (cfg usdOp (hidden shareOp aliceUSD)) right),
  ("parallel.compat.hidden-delta", resultEq
    (admit (cfg usdOp hiddenDelta) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-delta-funded", funded (cfg usdOp hiddenDelta) right),
  ("parallel.compat.hidden-supply", resultEq
    (admit (cfg usdOp hiddenSupply) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.hidden-supply-funded", funded (cfg usdOp hiddenSupply) right),
  ("parallel.compat.output-dependency", resultEq
    (admit (cfg usdOp shareOp [] [aliceUSD]) boundary [left] [right])
    (overlap .leftWriteRightRead aliceUSD)),
  ("parallel.compat.output-exact", resultEq
    (analyzeInvocation (cfg usdOp shareOp [] [aliceUSD]) (boundary .right 0) right)
    (.ok ⟨rightFP.reads ++ [aliceUSD], rightFP.writes⟩)),
  ("parallel.compat.zero-target", resultEq
    (admit (cfg usdOp zeroTarget) boundary [left] [right]) (overlap .writeWrite aliceUSD)),
  ("parallel.compat.zero-target-funded", funded (cfg usdOp zeroTarget) right),
  ("parallel.compat.zero-target-exact", resultEq
    (analyzeInvocation (cfg usdOp zeroTarget) (boundary .right 0) right)
    (.ok ⟨[aliceUSD], [aliceUSD]⟩)),
  ("parallel.compat.unreachable-suffix", resultEq
    (admit cfg boundary [{left with capabilityIds := []}, right] [right])
    (overlap .writeWrite vaultShare)),
  ("parallel.compat.numeric-input-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0)
      {left with inputs := [.literal ⟨.amount .usd, -500⟩]}) (.ok leftFP)),
  ("parallel.compat.prior-output-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0)
      {left with inputs := [.priorOutput 9 ⟨⟨99⟩, ⟨99⟩⟩]}) (.ok leftFP)),
  ("parallel.compat.capability-not-evaluated", resultEq
    (analyzeInvocation cfg (boundary .left 0) {left with capabilityIds := []}) (.ok leftFP)),
  ("parallel.compat.catalog-first", resultEq
    (admit {cfg with catalog := cfg.catalog ++ cfg.catalog} boundary
      [{left with operation := ⟨99⟩}] []) (.error .configuration)),
  ("parallel.compat.left-before-right", resultEq
    (admit cfg boundary [{left with operation := ⟨99⟩}] [{right with operation := ⟨98⟩}])
    (.error (.structural .left ⟨0, .interface .unknownOperation⟩))),
  ("parallel.compat.local-order", resultEq
    (admit cfg boundary [left, {left with operation := ⟨99⟩}, {left with operation := ⟨98⟩}] [])
    (.error (.structural .left ⟨1, .interface .unknownOperation⟩))),
  ("parallel.compat.structural-before-conflict", resultEq
    (admit cfg boundary [left] [left, {right with operation := ⟨99⟩}])
    (.error (.structural .right ⟨1, .interface .unknownOperation⟩))),
  ("parallel.compat.malformed-reference", resultEq
    (admit (cfg malformed shareOp) boundary [left] [right])
    (.error (.structural .left ⟨0, .interface (.resolution .partyArgument)⟩))),
  ("parallel.compat.access-check", resultEq
    (admit deniedCfg boundary [left] [right])
    (.error (.structural .left ⟨0, .interface .writeAccess⟩))),
  ("parallel.compat.forward-funded", funded (cfg usdOp (readOnly aliceUSD)) right),
  ("parallel.compat.reverse-funded", funded (cfg (readOnly vaultShare) shareOp) left),
  ("parallel.compat.output-funded", funded (cfg usdOp shareOp [] [aliceUSD]) right),
  ("parallel.compat.guard-read-exact", resultEq
    (analyzeInvocation (cfg usdOp (hidden shareOp aliceUSD)) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.delta-read-exact", resultEq
    (analyzeInvocation (cfg usdOp hiddenDelta) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.supply-read-exact", resultEq
    (analyzeInvocation (cfg usdOp hiddenSupply) (boundary .right 0) right)
    (.ok ⟨[aliceUSD, aliceUSD] ++ rightFP.reads, rightFP.writes⟩)),
  ("parallel.compat.forward-before-reverse", resultEq
    (checkCompatibility (⟨[bobUSD], [aliceUSD]⟩ : F) ⟨[aliceUSD], [bobUSD]⟩)
    (.error (.conflict .leftWriteRightRead aliceUSD))),
  ("parallel.compat.common-read-no-writes", resultEq
    (admit (cfg (readOnly common) (readOnly common)) boundary [left] [right])
    (.ok (⟨[common, common], []⟩, ⟨[common, common], []⟩))),
  ("parallel.compat.first-list-witness", resultEq
    (checkCompatibility (⟨[bobUSD, aliceUSD], [bobUSD, aliceUSD]⟩ : F) leftFP)
    (.error (.conflict .writeWrite bobUSD))) ]

end DefiKernel.Parallel.CompatibilityTests

```

### lean/DefiKernel/Parallel/Dependency/Adapter.lean
SHA256 10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c
```
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

```

### lean/DefiKernel/Parallel/Dependency/Fixtures.lean
SHA256 14bac7bfdc273c9de0d416e4489f6d16eb9d02e5e01f082ef0aeb194ef17de45
```
import DefiKernel.Parallel.Dependency.Adapter
import DefiKernel.Typed.TransitionTests

/-! Kernel-checked dependency fixtures over eight cells. These are development examples,
including malformed write declarations that refuse after the funds check. -/
namespace DefiKernel.Parallel.DependencyFixtures
open Typed Composition Typed.TransitionTests

def foreignState : S :=
  ⟨fun c ↦ if c = (true, true, true) then 99 else state.balance c, by
    intro c; split
    · decide
    · exact state.nonneg c⟩

def poorState : S :=
  ⟨fun c ↦ if c = (false, false, false) then 1 else state.balance c, by
    intro c; split
    · decide
    · exact state.nonneg c⟩

def targetRegion : Set (Cell Bool Bool Bool) :=
  {(false, false, false), (false, true, false)}

def malformed : T := { transfer with writes := [] }
def unbalanced : T := { transfer with supplyDeltas := [⟨false, false, .lit 1⟩] }
def dividing : T :=
  { transfer with
    deltas := [⟨false, alice,
      .binary (.divide (.amount false)) (.balance alice) (.lit 0)⟩]
    stateReads := [⟨false, alice⟩] }
def missingObservation : T :=
  { transfer with guard := .binary (.le (.amount false)) (.observe ⟨key⟩) (.lit 100)
                  envReads := [.observation key] }
def inactiveReads : T :=
  { transfer with
    guard := .ite (.lit true)
      (.binary (.le (.amount false)) (.balance alice) (.lit 100))
      (.binary (.le (.amount false)) (.balance bob) (.lit 100))
    stateReads := [⟨false, alice⟩, ⟨false, bob⟩] }

def evaluated : Evaluated Bool Bool Bool :=
  ⟨true, [((false, false, false), -3), ((false, true, false), 3)], [], [], [], [], [], []⟩

def exec (template : T) (pre : S) : Result :=
  Typed.execute (registry template) (capabilities template) context environment 10 request pre

-- BEGIN PROOFS

theorem foreign_agrees : AgreeOn targetRegion state foreignState := by
  intro c hc
  rcases hc with rfl | rfl <;> rfl

theorem foreign_differs : state.balance (true, true, true) ≠
    foreignState.balance (true, true, true) := by decide

theorem malformed_evaluates : malformed.evaluate
    ⟨state, environment, false, [], .nil, 10⟩ = .ok evaluated := by rfl

theorem malformed_targets : TargetsWithin malformed false [] targetRegion := by
  intro d hd c hc
  change d ∈ transfer.deltas at hd
  have hm := List.mem_cons.mp hd
  have hm' : d = transfer.deltas[0] ∨ d = transfer.deltas[1] := by
    rcases hm with h | h
    · exact Or.inl h
    · exact Or.inr (List.mem_singleton.mp h)
  rcases hm' with rfl | rfl
  · have he : (false, false, false) = c := Except.ok.inj hc
    subst c
    simp [targetRegion]
  · have he : (false, true, false) = c := Except.ok.inj hc
    subst c
    simp [targetRegion]

/-- The syntactic target theorem applies although the declared write list is empty. -/
theorem malformed_effect_outside (c : Cell Bool Bool Bool) (hc : c ∉ targetRegion) :
    evaluated.effect c = 0 :=
  evaluated_effect_zero_outside malformed _ evaluated malformed_evaluates targetRegion
    malformed_targets c hc

theorem malformed_writes_fail : evaluated.writesOK = false := by decide +kernel

theorem foreign_funds_iff :
    (∀ c, 0 ≤ state.balance c + evaluated.effect c) ↔
      (∀ c, 0 ≤ foreignState.balance c + evaluated.effect c) :=
  funds_iff state foreignState evaluated targetRegion foreign_agrees malformed_effect_outside

theorem target_balance_is_needed :
    (∀ c, 0 ≤ state.balance c + evaluated.effect c) ∧
      ¬ (∀ c, 0 ≤ poorState.balance c + evaluated.effect c) := by decide +kernel

theorem refused_iff (reason : Typed.Refusal) (result : Result) :
    refused reason result = true ↔ result = .error reason := by
  cases result with
  | error e => simp only [refused, beq_iff_eq, Except.error.injEq]
  | ok p =>
    constructor
    · intro h
      cases h
    · intro h
      cases h

theorem funded_malformed_refusal : exec malformed state = .error .writeFootprint := by
  apply (refused_iff _ _).mp
  decide +kernel

theorem foreign_malformed_refusal : exec malformed foreignState = .error .writeFootprint := by
  apply (execute_refusal_iff (registry malformed) (capabilities malformed) context environment 10
    request state foreignState targetRegion foreign_agrees _ _ .writeFootprint).mp
    funded_malformed_refusal
  · intro template hs
    have he : template = malformed := (Option.some.inj hs).symm
    subst template
    simp [ResolvedReadsAgree, Template.requiredStateReads, malformed, transfer, Expr.stateReads]
  · intro template hs
    have he : template = malformed := (Option.some.inj hs).symm
    subst template
    exact malformed_targets

theorem poor_malformed_refusal : exec malformed poorState = .error .insufficientFunds := by
  apply (refused_iff _ _).mp
  decide +kernel

theorem accounting_refusal : exec unbalanced foreignState = .error .accounting := by
  apply (refused_iff _ _).mp
  decide +kernel

theorem division_evaluation : dividing.evaluate
    ⟨state, environment, false, [], .nil, 10⟩ = .error .divisionByZero := by rfl

theorem division_execution : exec dividing foreignState = .error (.evaluation .divisionByZero) := by
  apply (refused_iff _ _).mp
  decide +kernel

theorem observation_error : missingObservation.evaluate
    ⟨foreignState, (fun _ ↦ none), false, [], .nil, 10⟩ = .error .missingObservation := by rfl

/-- Both branches contribute to the proved read premise, even though the condition is true. -/
theorem inactive_evaluation_congr : inactiveReads.evaluate
    ⟨state, environment, false, [], .nil, 10⟩ = inactiveReads.evaluate
      ⟨foreignState, environment, false, [], .nil, 10⟩ := by
  apply evaluate_congr
  intro ref hr c hc
  simp [inactiveReads, transfer, Template.requiredStateReads, Expr.stateReads] at hr
  rcases hr with rfl | rfl <;>
    simp only [alice, bob, CellRef.resolve, PartyRef.resolve, bind, Except.bind,
      pure, Except.pure, Except.ok.injEq] at hc <;>
    subst c <;> rfl

theorem foreign_success : accepted (exec transfer foreignState) = true := by decide +kernel

end DefiKernel.Parallel.DependencyFixtures

```

### lean/DefiKernel/Parallel/Dependency.lean
SHA256 72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245
```
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

```

### lean/DefiKernel/Parallel/Examples.lean
SHA256 d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd
```
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

```

### lean/DefiKernel/Parallel/Execution.lean
SHA256 a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089
```
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

```

### lean/DefiKernel/Parallel/ExecutionTests.lean
SHA256 4b88467004d0392fba8aff169544bbebf586a06c74ca5426a2ca6ab7676ded99
```
import DefiKernel.Parallel.Execution
import DefiKernel.Parallel.CompatibilityTests
import DefiKernel.Composition.Examples

namespace DefiKernel.Parallel.ExecutionTests
open Typed Typed.Examples Composition Composition.Examples

def boundaries (_ : BranchId) : Nat → Boundary Party Asset Domain := boundary

def emptyExpected : BranchObservation Party Asset Domain := ⟨[], [], 0, none⟩

def refusedUnchanged (config : Config Party Asset Domain)
    (left right : Branch Party Asset Domain) (reason : AdmissionFailure Party Asset Domain) : Bool :=
  match runParallel config CompatibilityTests.boundary CompatibilityTests.initial left right with
  | .refused actual world =>
    decide (actual = reason) && worldEq world CompatibilityTests.initial
  | .executed _ => false

def checks : List (String × Bool) := [
  ("parallel.empty", match runParallel cfg boundaries initialWorld [] [] with
    | .refused _ _ => false
    | .executed result =>
      worldEq result.world initialWorld &&
      decide (observeBranch result.left = emptyExpected ∧
        observeBranch result.right = emptyExpected)),
  ("parallel.empty.lr", observationsEqual
    (runParallel cfg boundaries initialWorld [] [])
    (runSerialLR cfg boundaries initialWorld [] [])),
  ("parallel.empty.rl", observationsEqual
    (runParallel cfg boundaries initialWorld [] [])
    (runSerialRL cfg boundaries initialWorld [] [])),
  ("parallel.refused.catalog-unchanged", refusedUnchanged
    { CompatibilityTests.cfg with catalog :=
      CompatibilityTests.cfg.catalog ++ CompatibilityTests.cfg.catalog } [] [] .configuration),
  ("parallel.refused.conflict-unchanged", refusedUnchanged CompatibilityTests.cfg
    [CompatibilityTests.left] [CompatibilityTests.left]
    (.conflict .writeWrite CompatibilityTests.aliceUSD)),
  ("parallel.refused.structural-unchanged", refusedUnchanged CompatibilityTests.cfg
    [{ CompatibilityTests.left with operation := ⟨999⟩ }] [CompatibilityTests.right]
    (.structural .left ⟨0, .interface .unknownOperation⟩))]

end DefiKernel.Parallel.ExecutionTests

```

### lean/DefiKernel/Parallel/Observation.lean
SHA256 38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f
```
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

```

### lean/DefiKernel/Parallel/ObservationTests.lean
SHA256 227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e
```
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

```

### lean/DefiKernel/Parallel/Preservation.lean
SHA256 faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10
```
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

```

### lean/DefiKernel/Parallel/PreservationFixtures.lean
SHA256 0b04488e2d75cbbc4997217aae288692f35571cbcbdec40420254b59948ba9e7
```
import DefiKernel.Parallel.Preservation
import DefiKernel.Parallel.CompatibilityTests

/-! Concrete initialized conservation, protected collateral and independent mint/burn proofs.
The fixtures are development cases, not external financial fidelity evidence. -/
namespace DefiKernel.Parallel.PreservationFixtures
open Typed Composition Typed.Examples CompatibilityTests

def joined : Joined Party Asset Domain :=
  let l := runBranch cfg (boundary .left) initial [left]
  let r := runBranch cfg (boundary .right) initial [right]
  ⟨mergeWorld leftFP rightFP initial l.world r.world, l, r⟩

def usdRegion : Set C := {c | c.1 = Domain.main ∧ c.2.2 = Asset.usd}
def shareRegion : Set C := {c | c.1 = Domain.main ∧ c.2.2 = Asset.share}
def collateralPredicate (s : State Party Asset Domain) : Prop := s.balance common = 0

def mint : Op := { usdOp with
  deltas := [⟨.usd, cellRef aliceUSD, .lit 2⟩]
  supplyDeltas := [⟨.main, .usd, .lit 2⟩]
  writes := [packed aliceUSD] }
def burn : Op := { shareOp with
  deltas := [⟨.share, cellRef vaultShare, .lit (-4)⟩]
  supplyDeltas := [⟨.main, .share, .lit (-4)⟩]
  writes := [packed vaultShare] }
def supplyCfg := cfg mint burn
def supplyInitial : World Party Asset Domain :=
  { CompatibilityTests.initial with capabilities := ⟨initial.capabilities.entries ++
    [⟨⟨.alice, .main, ⟨10⟩, .changeSupply .main .usd⟩, true⟩,
     ⟨⟨.alice, .main, ⟨11⟩, .changeSupply .main .share⟩, true⟩]⟩ }
def mintInv : I := { left with capabilityIds := [⟨0⟩, ⟨4⟩] }
def burnInv : I := { right with capabilityIds := [⟨2⟩, ⟨3⟩, ⟨5⟩] }
def mintFP : F := ⟨[aliceUSD, aliceUSD], [aliceUSD, aliceUSD]⟩
def burnFP : F := ⟨[vaultShare, vaultShare], [vaultShare, vaultShare]⟩
def supplyJoined : Joined Party Asset Domain :=
  let l := runBranch supplyCfg (boundary .left) supplyInitial [mintInv]
  let r := runBranch supplyCfg (boundary .right) supplyInitial [burnInv]
  ⟨mergeWorld mintFP burnFP supplyInitial l.world r.world, l, r⟩

def refusedMint : I := { mintInv with capabilityIds := [] }
def prefixJoined : Joined Party Asset Domain :=
  let l := runBranch supplyCfg (boundary .left) supplyInitial [mintInv, refusedMint]
  let r := runBranch supplyCfg (boundary .right) supplyInitial [burnInv]
  ⟨mergeWorld (mintFP.append mintFP) burnFP supplyInitial l.world r.world, l, r⟩

-- BEGIN PROOFS

theorem admitted : admit cfg boundary [left] [right] = .ok (leftFP, rightFP) := by
  decide +kernel

theorem executed : runParallel cfg boundary initial [left] [right] = .executed joined := by
  simp only [runParallel, admitted]
  rfl

theorem supply_free : ∀ op template, cfg.registry op = some template →
    template.supplyDeltas = [] := by
  intro op template hs
  change (if op = ⟨10⟩ then some usdOp else if op = ⟨11⟩ then some shareOp else none) =
    some template at hs
  split_ifs at hs <;> cases hs <;> rfl

theorem initial_totals : total initial.state .main .usd = 10 ∧
    total initial.state .main .share = 20 := by decide +kernel

/-- Initialized USD and share conservation each have an actual local induction proof. -/
theorem initialized_two_invariants :
    total joined.world.state .main .usd = 10 ∧ total joined.world.state .main .share = 20 := by
  apply runParallel_two_invariants cfg boundary initial [left] [right] leftFP rightFP admitted
    usdRegion shareRegion (fun s ↦ total s .main .usd = 10)
    (fun s ↦ total s .main .share = 20)
  · exact supports_total (P := Party) Domain.main Asset.usd (· = 10)
  · exact supports_total (P := Party) Domain.main Asset.share (· = 20)
  · intro c hc hw
    have hx : c.2.2 = .usd := hc.2
    simp only [rightFP, List.mem_cons, List.not_mem_nil, or_false] at hw
    rcases hw with rfl | rfl | rfl | rfl <;> cases hx
  · intro c hc hw
    have hx : c.2.2 = .share := hc.2
    simp only [leftFP, List.mem_cons, List.not_mem_nil, or_false] at hw
    rcases hw with rfl | rfl | rfl | rfl <;> cases hx
  · exact initial_totals.1
  · exact initial_totals.2
  · exact local_total_preservation cfg (boundary .left) supply_free .main .usd 10
  · exact local_total_preservation cfg (boundary .right) supply_free .main .share 20

theorem protected_collateral : collateralPredicate joined.world.state := by
  have hi : collateralPredicate initial.state := by unfold collateralPredicate; decide +kernel
  apply (runParallel_executed_supported_frame cfg boundary initial [left] [right]
    leftFP rightFP joined admitted executed {common} collateralPredicate
    (supports_balance common (· = 0)) _).mp hi
  intro c hc
  have he : c = common := Set.mem_singleton_iff.mp hc
  subst c
  decide

theorem joined_authority :
    (∀ event ∈ joined.left.events,
      ReceiptAuthorized initial (boundary .left event.index) event.result.receipt) ∧
    (∀ event ∈ joined.right.events,
      ReceiptAuthorized initial (boundary .right event.index) event.result.receipt) :=
  runParallel_executed_authority cfg boundary initial [left] [right] joined executed

theorem joined_nonnegative : ∀ c, 0 ≤ joined.world.state.balance c :=
  (runParallel_executed_nonnegative cfg boundary initial [left] [right] joined executed).1

/-- A predicate with empty declared support can still change if support is not proved. -/
theorem unsupported_counterexample :
    AgreeOn (∅ : Set C) initial.state joined.world.state ∧
    initial.state.balance aliceUSD = 10 ∧ joined.world.state.balance aliceUSD ≠ 10 := by
  refine ⟨?_, ?_, ?_⟩
  · intro c hc
    cases hc
  · decide +kernel
  · decide +kernel

theorem unsupported_is_not_supported :
    ¬ Supports (∅ : Set C) (fun s : State Party Asset Domain ↦ s.balance aliceUSD = 10) := by
  intro h
  have hc := unsupported_counterexample
  exact hc.2.2 ((h initial.state joined.world.state hc.1).mp hc.2.1)

/-- Correct support alone does not frame a predicate whose selected cell is written. -/
theorem written_support_counterexample :
    Supports {aliceUSD} (fun s : State Party Asset Domain ↦ s.balance aliceUSD = 10) ∧
    aliceUSD ∈ leftFP.writes ∧ initial.state.balance aliceUSD = 10 ∧
    joined.world.state.balance aliceUSD ≠ 10 := by
  exact ⟨supports_balance aliceUSD (· = 10), by decide,
    unsupported_counterexample.2.1, unsupported_counterexample.2.2⟩

theorem supply_admitted : admit supplyCfg boundary [mintInv] [burnInv] =
    .ok (mintFP, burnFP) := by decide +kernel

theorem supply_executed : runParallel supplyCfg boundary supplyInitial [mintInv] [burnInv] =
    .executed supplyJoined := by
  simp only [runParallel, supply_admitted]
  rfl

theorem supply_receipts : supplyJoined.left.events.length = 1 ∧
    supplyJoined.right.events.length = 1 ∧ supplyJoined.supply .main .usd = 2 ∧
    supplyJoined.supply .main .share = -4 := by decide +kernel

theorem supply_totals : total supplyJoined.world.state .main .usd = 12 ∧
    total supplyJoined.world.state .main .share = 16 := by
  have hu := runParallel_executed_accounting supplyCfg boundary supplyInitial [mintInv] [burnInv]
    supplyJoined supply_executed Domain.main Asset.usd
  have hs := runParallel_executed_accounting supplyCfg boundary supplyInitial [mintInv] [burnInv]
    supplyJoined supply_executed Domain.main Asset.share
  rw [supply_receipts.2.2.1] at hu
  rw [supply_receipts.2.2.2] at hs
  have hiu : total supplyInitial.state .main .usd = 10 := initial_totals.1
  have his : total supplyInitial.state .main .share = 20 := initial_totals.2
  rw [hiu] at hu
  rw [his] at hs
  constructor <;> linarith

theorem prefix_admitted : admit supplyCfg boundary [mintInv, refusedMint] [burnInv] =
    .ok (mintFP.append mintFP, burnFP) := by decide +kernel

theorem prefix_executed :
    runParallel supplyCfg boundary supplyInitial [mintInv, refusedMint] [burnInv] =
      .executed prefixJoined := by
  simp only [runParallel, prefix_admitted]
  rfl

/-- A successful supply-changing prefix retains its exact receipt before a local refusal. -/
theorem prefix_refusal_receipts : prefixJoined.left.events.length = 1 ∧
    prefixJoined.left.failure =
      some ⟨1, some (.invoke refusedMint), .kernel .unauthorizedInvoke⟩ ∧
    prefixJoined.right.events.length = 1 ∧ prefixJoined.right.failure = none ∧
    prefixJoined.supply .main .usd = 2 ∧ prefixJoined.supply .main .share = -4 := by
  decide +kernel

theorem prefix_authority :
    (∀ event ∈ prefixJoined.left.events,
      ReceiptAuthorized supplyInitial (boundary .left event.index) event.result.receipt) ∧
    (∀ event ∈ prefixJoined.right.events,
      ReceiptAuthorized supplyInitial (boundary .right event.index) event.result.receipt) :=
  runParallel_executed_authority supplyCfg boundary supplyInitial
    [mintInv, refusedMint] [burnInv] prefixJoined prefix_executed

theorem prefix_accounting (d : Domain) (a : Asset) :
    total prefixJoined.world.state d a = total supplyInitial.state d a + prefixJoined.supply d a :=
  runParallel_executed_accounting supplyCfg boundary supplyInitial
    [mintInv, refusedMint] [burnInv] prefixJoined prefix_executed d a

end DefiKernel.Parallel.PreservationFixtures

```

### lean/DefiKernel/Parallel/Tests.lean
SHA256 626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725
```
import DefiKernel.Parallel.Examples
import DefiKernel.Parallel.Preservation

/-! Named bounded comparisons against direct complete ledger, capability, receipt and output
expectations. Equality between implementations is supplementary to the independent oracles. -/
namespace DefiKernel.Parallel.Tests
open Typed Composition Typed.Examples Parallel.Examples

def basic := runParallel cfg boundaries initial [usd 3] [shares 4]
def peerRuns := runParallel cfg boundaries initial [usd 11] [shares 4]
def prefixKept := runParallel cfg boundaries initial [usd 3, usd 8] [shares 4]
def dualRefusal := runParallel cfg boundaries initial [usd 3, usd 8] [shares 4, shares 17]
def routingForeign := source (usd 0) 1
def routingOwn := source (usd 0) 0
def routingRightOwn := source (shares 0) 1

def routeExpected (consumer : I) (q finalBob : ℚ) : Obs := observed [leftEvent 0 3 3,
  transferEvent 1 consumer aliceUSD bobUSD q [output 1 0 .usd finalBob]]
def rightRouteExpected : Obs := observed [rightEvent 0 4 4,
  transferEvent 1 routingRightOwn vaultShare aliceShare 4 [output 1 1 .share 8]]
def routeForeignExpected : Obs := observed [leftEvent 0 3 3]
  (failure 1 routingForeign (.interface .unavailableOutput))
def routeForeign := runParallel sameAssetCfg boundaries initial [usd 3, routingForeign] [peerUSD 4]

def supplyRun := runParallel supplyCfg boundaries initial [usd 2] [shares (-3)]
def supplyLeft := observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
def supplyRight := observed [supplyEvent 0 (shares (-3)) vaultShare (-3) 17]
def statefulRun := runParallel statefulCfg boundaries initial [usd 0, usd 0, usd 0] [shares 4]
def statefulExpected := observed [statefulEvent 0 5 5, statefulEvent 1 (5 / 2) (15 / 2)]
  (failure 2 (usd 0) (.kernel .guard))
def stateSupplyCfg := config usdTransfer statefulSupply [bobUSD] [vaultShare]
def stateSupplyExpected := observed [statefulSupplyEvent 0 10 30, statefulSupplyEvent 1 15 45]

def admissionRefused (actual : R) (reason : AdmissionFailure Party Asset Domain)
    (expected : W := initial) : Bool :=
  match actual with
  | .refused actualReason actualWorld =>
    decide (actualReason = reason) && worldEq actualWorld expected
  | .executed _ => false

def serialChecks (label : String) (config : Config Party Asset Domain)
    (binding : ParallelBoundary Party Asset Domain) (world : W) (left right : B)
    (balance : C → ℚ) (expectedLeft expectedRight : Obs) (expectedStore : Store := store) :
    List (String × Bool) := [
  (label ++ ".lr.complete", matchesExpected (runSerialLR config binding world left right)
    balance expectedLeft expectedRight expectedStore),
  (label ++ ".rl.complete", matchesExpected (runSerialRL config binding world left right)
    balance expectedLeft expectedRight expectedStore)]

def checks : List (String × Bool) := [
  ("parallel.fixture.catalog", validateCatalog cfg.registry cfg.catalog),
  ("parallel.fixture.basic.complete", matchesExpected basic (balanceTable 7 3 16 4)
    basicLeft basicRight),
  ("parallel.fixture.same-asset.complete", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3] [peerUSD 4])
    (balanceTable 7 3 20 0 16 5) basicLeft (observed [peerEvent 0 4 5])),
  ("parallel.fixture.refusal.peer-runs", matchesExpected peerRuns (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) basicRight),
  ("parallel.fixture.refusal.prefix-kept", matchesExpected prefixKept (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds))) basicRight),
  ("parallel.fixture.refusal.dual", matchesExpected dualRefusal (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds)))
    (observed [rightEvent 0 4 4] (failure 1 (shares 17) (.kernel .insufficientFunds)))),
  ("parallel.fixture.refusal.guard", matchesExpected
    (runParallel cfg boundaries initial [usd (-1)] [shares 4]) (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd (-1)) (.kernel .guard))) basicRight),
  ("parallel.fixture.refusal.input-unit", let wrong :=
      {usd 3 with inputs := [.literal ⟨.amount .share, 3⟩]}
    matchesExpected (runParallel cfg boundaries initial [wrong] [shares 4])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 wrong (.interface .inputUnit))) basicRight),
  ("parallel.fixture.refusal.missing-capability", let missing := {usd 3 with capabilityIds := []}
    matchesExpected (runParallel cfg boundaries initial [missing] [shares 4])
      (balanceTable 10 0 16 4)
      (observed [] (failure 0 missing (.kernel .unauthorizedInvoke))) basicRight),
  ("parallel.fixture.empty.right", matchesExpected
    (runParallel cfg boundaries initial [usd 3] []) (balanceTable 7 3 20 0)
      basicLeft (observed [])),
  ("parallel.fixture.empty.left", matchesExpected
    (runParallel cfg boundaries initial [] [shares 4]) (balanceTable 10 0 16 4)
      (observed []) basicRight),
  ("parallel.fixture.empty.both", matchesExpected
    (runParallel cfg boundaries initial [] []) (balanceTable 10 0 20 0)
      (observed []) (observed [])),
  ("parallel.fixture.routing.peer-only", matchesExpected routeForeign
    (balanceTable 7 3 20 0 16 5) routeForeignExpected (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.funded-literal", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3, usd 5] [peerUSD 4])
    (balanceTable 2 8 20 0 16 5) (observed [leftEvent 0 3 3, leftEvent 1 5 8])
      (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.own-history", matchesExpected
    (runParallel sameAssetCfg boundaries initial [usd 3, routingOwn] [peerUSD 4])
    (balanceTable 4 6 20 0 16 5) (routeExpected routingOwn 3 6) (observed [peerEvent 0 4 5])),
  ("parallel.fixture.routing.both-own-history", matchesExpected
    (runParallel cfg boundaries initial [usd 3, routingOwn] [shares 4, routingRightOwn])
    (balanceTable 4 6 12 8) (routeExpected routingOwn 3 6) rightRouteExpected),
  ("parallel.fixture.routing.shared-qualified-key", matchesExpected
    (runParallel sharedReadCfg boundaries initial [noOpInvocation] [noOpInvocation])
    (balanceTable 10 0 20 0) sharedReadExpected sharedReadExpected),
  ("parallel.fixture.boundary.local-identity", matchesExpected
    (runParallel timedCfg timedBoundaries initial timedLeft timedRight)
    (balanceTable 8 2 14 6) timedExpectedLeft timedExpectedRight),
  ("parallel.fixture.capability.revoked", matchesExpected
    (runParallel cfg boundaries revokedInitial [usd 3] [shares 4])
    (balanceTable 7 3 20 0) basicLeft
      (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) revokedStore),
  ("parallel.fixture.capability.actual-revoke", decide
    (revokeCapability cfg.authority adminContext store ⟨2⟩ = .ok revokedStore)),
  ("parallel.fixture.capability.reusable-shared-grant",
    let l := {usd 3 with parties := [.alice, .bob]}
    let r := {usd 4 with parties := [.vault, .pool]}
    matchesExpected (runParallel reusableCfg boundaries initial [l] [r])
      (balanceTable 7 3 20 0 16 5)
      (observed [transferEvent 0 l aliceUSD bobUSD 3 []])
      (observed [transferEvent 0 r vaultUSD poolUSD 4 []])),
  ("parallel.fixture.supply.complete", matchesExpected supplyRun (balanceTable 12 0 17 0)
    supplyLeft supplyRight),
  ("parallel.fixture.supply.both-receipts", match supplyRun with
    | .refused _ _ => false
    | .executed result => decide (∀ d a, result.supply d a =
        if d = .main ∧ a = .usd then 2 else if d = .main ∧ a = .share then -3 else 0)),
  ("parallel.fixture.supply.prefix-refusal", matchesExpected
    (runParallel supplyCfg boundaries initial [usd 2, usd (-13)] [shares (-3)])
    (balanceTable 12 0 17 0)
    (observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
      (failure 1 (usd (-13)) (.kernel .insufficientFunds))) supplyRight),
  ("parallel.fixture.stateful.prefix", matchesExpected statefulRun
    (balanceTable (5 / 2) (15 / 2) 16 4)
    statefulExpected basicRight),
  ("parallel.fixture.stateful.supply", matchesExpected
    (runParallel stateSupplyCfg boundaries initial [usd 3] [shares 0, shares 0])
    (balanceTable 7 3 45 0) basicLeft stateSupplyExpected),
  ("parallel.fixture.cancelling.admission", admissionRefused
    (runParallel (config usdTransfer cancelling) boundaries initial [usd 3] [cancellingInvocation])
    (.conflict .writeWrite aliceUSD)),
  ("parallel.fixture.cancelling.funded", matchesExpected
    (runParallel (config usdTransfer cancelling) boundaries initial [] [cancellingInvocation])
    (balanceTable 10 0 20 0) (observed []) cancellingExpected),
  ("parallel.fixture.refusal.world-preserved", admissionRefused
    (runParallel cfg boundaries initial [usd 3] [usd 3]) (.conflict .writeWrite aliceUSD)),
  ("parallel.fixture.refusal.suffix-world-preserved", let unknown := {usd 0 with operation := ⟨99⟩}
    admissionRefused (runParallel cfg boundaries initial [usd 3, unknown] [shares 4])
      (.structural .left ⟨1, .interface .unknownOperation⟩)),
  ("parallel.fixture.raw-context-differs", match basic,
      runSerialLR cfg boundaries initial [usd 3] [shares 4] with
    | .executed p, .executed s =>
      observationsEqual basic (runSerialLR cfg boundaries initial [usd 3] [shares 4]) &&
      match p.right.events, s.right.events with
      | pe :: _, se :: _ => !worldEq pe.before se.before
      | _, _ => false
    | _, _ => false)
  ] ++
  serialChecks "parallel.fixture.basic" cfg boundaries initial [usd 3] [shares 4]
    (balanceTable 7 3 16 4) basicLeft basicRight ++
  serialChecks "parallel.fixture.prefix" cfg boundaries initial [usd 3, usd 8] [shares 4]
    (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds))) basicRight ++
  serialChecks "parallel.fixture.routing" sameAssetCfg boundaries initial
    [usd 3, routingForeign] [peerUSD 4] (balanceTable 7 3 20 0 16 5)
    routeForeignExpected (observed [peerEvent 0 4 5]) ++
  serialChecks "parallel.fixture.boundary" timedCfg timedBoundaries initial timedLeft timedRight
    (balanceTable 8 2 14 6) timedExpectedLeft timedExpectedRight ++
  serialChecks "parallel.fixture.supply" supplyCfg boundaries initial [usd 2] [shares (-3)]
    (balanceTable 12 0 17 0) supplyLeft supplyRight ++
  serialChecks "parallel.fixture.stateful" statefulCfg boundaries initial [usd 0, usd 0, usd 0]
    [shares 4] (balanceTable (5 / 2) (15 / 2) 16 4) statefulExpected basicRight ++
  serialChecks "parallel.fixture.revoked" cfg boundaries revokedInitial [usd 3] [shares 4]
    (balanceTable 7 3 20 0) basicLeft
    (observed [] (failure 0 (shares 4) (.kernel .unauthorizedInvoke))) revokedStore ++
  serialChecks "parallel.fixture.same-asset" sameAssetCfg boundaries initial [usd 3] [peerUSD 4]
    (balanceTable 7 3 20 0 16 5) basicLeft (observed [peerEvent 0 4 5]) ++
  serialChecks "parallel.fixture.peer-runs" cfg boundaries initial [usd 11] [shares 4]
    (balanceTable 10 0 16 4)
    (observed [] (failure 0 (usd 11) (.kernel .insufficientFunds))) basicRight ++
  serialChecks "parallel.fixture.dual" cfg boundaries initial [usd 3, usd 8] [shares 4, shares 17]
    (balanceTable 7 3 16 4)
    (observed [leftEvent 0 3 3] (failure 1 (usd 8) (.kernel .insufficientFunds)))
    (observed [rightEvent 0 4 4] (failure 1 (shares 17) (.kernel .insufficientFunds))) ++
  serialChecks "parallel.fixture.both-own-history" cfg boundaries initial
    [usd 3, routingOwn] [shares 4, routingRightOwn]
    (balanceTable 4 6 12 8) (routeExpected routingOwn 3 6) rightRouteExpected ++
  serialChecks "parallel.fixture.stateful-supply" stateSupplyCfg boundaries initial
    [usd 3] [shares 0, shares 0] (balanceTable 7 3 45 0) basicLeft stateSupplyExpected ++
  serialChecks "parallel.fixture.shared-qualified-key" sharedReadCfg boundaries initial
    [noOpInvocation] [noOpInvocation] (balanceTable 10 0 20 0)
    sharedReadExpected sharedReadExpected ++
  serialChecks "parallel.fixture.supply-prefix" supplyCfg boundaries initial
    [usd 2, usd (-13)] [shares (-3)] (balanceTable 12 0 17 0)
    (observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
      (failure 1 (usd (-13)) (.kernel .insufficientFunds))) supplyRight

end DefiKernel.Parallel.Tests

```

### lean/DefiKernel/Parallel/Verify.lean
SHA256 ff25ad430ff36275ecaf7ccfab8a55f2e853cbd9381a739163f81bd3d7bbd3ab
```
import DefiKernel.Parallel.Audit
import DefiKernel.Parallel.Dependency.Fixtures
import DefiKernel.Parallel.PreservationFixtures
import DefiKernel.AxiomAudit

/-! Every imported Parallel theorem and supplemental declaration is checked by module provenance.
The runtime inventory is bounded evidence; this imported audit checks transitive proof axioms. -/
#audit_axioms DefiKernel.Parallel

```

### lean/DefiKernel/Typed/Acceptance.lean
SHA256 4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1
```
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

```

### lean/DefiKernel/Typed/Authority.lean
SHA256 dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb
```
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

```

### lean/DefiKernel/Typed/AuthorityTests.lean
SHA256 02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77
```
import DefiKernel.Typed.Authority

namespace DefiKernel.Typed
namespace AuthorityTests

abbrev P := Fin 3
abbrev A := Fin 2
abbrev D := Fin 2

def config : AuthorityConfig P D :=
  ⟨fun d ↦ if d = 0 then 0 else 2,
   fun op ↦ if op = ⟨0⟩ ∨ op = ⟨2⟩ then some 0 else if op = ⟨1⟩ then some 1 else none⟩

def admin : InvocationContext P D := ⟨0, 0⟩
def holder : InvocationContext P D := ⟨1, 0⟩
def foreignAdmin : InvocationContext P D := ⟨2, 1⟩
def empty : CapabilityStore P A D := .empty

def grant (right : Right P A D := .invoke) : Grant P A D := ⟨1, 0, ⟨0⟩, right⟩

def issued := issueCapability config admin empty (grant .invoke)

def store : CapabilityStore P A D :=
  match issued with
  | .ok (_, s) => s
  | .error _ => empty

def debit : Right P A D := .debit (0, 1, 0)
def supply : Right P A D := .changeSupply 0 0

def issueMore : Except AuthorityFailure (CapabilityStore P A D) := do
  let (_, s) ← issueCapability config admin store (grant debit)
  let (_, s) ← issueCapability config admin s (grant supply)
  return s

def full : CapabilityStore P A D := issueMore.toOption.getD empty

def revoked := revokeCapability config admin full ⟨1⟩
def afterRevoke : CapabilityStore P A D := revoked.toOption.getD empty

def reissued := issueCapability config admin afterRevoke (grant debit)
def afterReissue : CapabilityStore P A D :=
  match reissued with
  | .ok (_, s) => s
  | .error _ => empty

def sameRequest (s : CapabilityStore P A D) : Bool :=
  hasAuthority s [⟨0⟩, ⟨1⟩, ⟨2⟩] holder ⟨0⟩ .invoke &&
  hasAuthority s [⟨0⟩, ⟨1⟩, ⟨2⟩] holder ⟨0⟩ debit

def foreignIssue := issueCapability config foreignAdmin empty
  (⟨1, 1, ⟨1⟩, .invoke⟩ : Grant P A D)

def wrongOperationIssue := issueCapability config admin empty
  { grant .invoke with operation := ⟨2⟩ }

def issueUse (result : Except AuthorityFailure (CapabilityId × CapabilityStore P A D))
    (ctx : InvocationContext P D) (op : OperationId) (right : Right P A D) : Bool :=
  match result with
  | .error _ => false
  | .ok (id, s) => hasAuthority s [id] ctx op right

/-- Named comparisons run public issue/revoke/use definitions. These are development tests. -/
def checks : List (String × Bool) := [
  ("authority_issue_succeeds_with_id_zero", decide (issued = .ok (⟨0⟩, ⟨[⟨grant .invoke, true⟩]⟩))),
  ("authority_unauthorized_issuer", decide (issueCapability config holder empty (grant .invoke) =
    .error .unauthorizedAdmin)),
  ("authority_issuer_wrong_authenticated_domain", decide
    (issueCapability config ⟨0, 1⟩ empty (grant .invoke) = .error .unauthorizedAdmin)),
  ("authority_unknown_operation_grant", decide (issueCapability config admin empty
    { grant .invoke with operation := ⟨99⟩ } = .error .operationDomain)),
  ("authority_foreign_operation_grant", decide (issueCapability config admin empty
    { grant .invoke with operation := ⟨1⟩ } = .error .operationDomain)),
  ("authority_foreign_debit_resource_grant", decide (issueCapability config admin empty
    (grant (.debit (1, 1, 0))) = .error .resourceDomain)),
  ("authority_foreign_supply_resource_grant", decide (issueCapability config admin empty
    (grant (.changeSupply 1 0)) = .error .resourceDomain)),
  ("authority_invoke_live_holder", hasAuthority full [⟨0⟩] holder ⟨0⟩ .invoke),
  ("authority_debit_live_holder", hasAuthority full [⟨1⟩] holder ⟨0⟩ debit),
  ("authority_supply_live_holder", hasAuthority full [⟨2⟩] holder ⟨0⟩ supply),
  ("authority_wrong_holder", !hasAuthority full [⟨0⟩] ⟨2, 0⟩ ⟨0⟩ .invoke),
  ("authority_wrong_authenticated_domain", !hasAuthority full [⟨0⟩] ⟨1, 1⟩ ⟨0⟩ .invoke),
  ("authority_unknown_capability", !hasAuthority full [⟨99⟩] holder ⟨0⟩ .invoke),
  ("authority_empty_capability_request", !hasAuthority full [] holder ⟨0⟩ .invoke),
  ("authority_wrong_operation", !hasAuthority full [⟨0⟩] holder ⟨2⟩ .invoke),
  ("authority_wrong_debit_owner", !hasAuthority full [⟨1⟩] holder ⟨0⟩ (.debit (0, 2, 0))),
  ("authority_wrong_debit_asset", !hasAuthority full [⟨1⟩] holder ⟨0⟩ (.debit (0, 1, 1))),
  ("authority_wrong_supply_asset", !hasAuthority full [⟨2⟩] holder ⟨0⟩ (.changeSupply 0 1)),
  ("authority_right_kind_mismatch", !hasAuthority full [⟨0⟩] holder ⟨0⟩ debit),
  ("authority_duplicates_preserve_success", hasAuthority full [⟨0⟩, ⟨0⟩] holder ⟨0⟩ .invoke),
  ("authority_duplicates_add_no_right", !hasAuthority full [⟨0⟩, ⟨0⟩] holder ⟨0⟩ debit),
  ("authority_unauthorized_revoker", decide (revokeCapability config holder full ⟨1⟩ =
    .error .unauthorizedAdmin)),
  ("authority_revoker_wrong_authenticated_domain", decide
    (revokeCapability config ⟨0, 1⟩ full ⟨1⟩ = .error .unauthorizedAdmin)),
  ("authority_unknown_revocation", decide (revokeCapability config admin full ⟨99⟩ =
    .error .unknownCapability)),
  ("authority_same_request_before_revoke", sameRequest full),
  ("authority_revoke_accepted", decide (revoked = .ok
    ⟨[⟨grant .invoke, true⟩, ⟨grant debit, false⟩, ⟨grant supply, true⟩]⟩)),
  ("authority_same_request_after_revoke", !sameRequest afterRevoke),
  ("authority_revoke_keeps_invoke_sibling", hasAuthority afterRevoke [⟨0⟩] holder ⟨0⟩ .invoke),
  ("authority_revoke_keeps_supply_sibling", hasAuthority afterRevoke [⟨2⟩] holder ⟨0⟩ supply),
  ("authority_revoke_is_idempotent", decide
    (revokeCapability config admin afterRevoke ⟨1⟩ = .ok afterRevoke)),
  ("authority_reissue_receives_fresh_id_three", decide
    (reissued = .ok (⟨3⟩, ⟨afterRevoke.entries ++ [⟨grant debit, true⟩]⟩))),
  ("authority_reissued_right_usable_by_new_id", hasAuthority afterReissue [⟨3⟩] holder ⟨0⟩ debit),
  ("authority_old_revoked_id_remains_unusable", !hasAuthority afterReissue [⟨1⟩] holder ⟨0⟩ debit),
  ("authority_foreign_grant_positive_sibling", issueUse foreignIssue ⟨1, 1⟩ ⟨1⟩ .invoke),
  ("authority_foreign_grant_cannot_authorize_local_context",
    !issueUse foreignIssue holder ⟨1⟩ .invoke),
  ("authority_other_operation_positive_sibling", issueUse wrongOperationIssue holder ⟨2⟩ .invoke),
  ("authority_other_operation_cannot_authorize_original",
    !issueUse wrongOperationIssue holder ⟨0⟩ .invoke)]

end AuthorityTests

-- BEGIN PROOFS

#eval AuthorityTests.checks
#eval AuthorityTests.checks.length

theorem authority_checks_pass : AuthorityTests.checks.all Prod.snd = true := by decide

end DefiKernel.Typed

```

### lean/DefiKernel/Typed/Examples.lean
SHA256 640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41
```
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

```

### lean/DefiKernel/Typed/Expr.lean
SHA256 1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed
```
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

```

### lean/DefiKernel/Typed/ExprTests.lean
SHA256 8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29
```
import DefiKernel.Typed.Expr
import Mathlib.Tactic.NormNum

/-! Executed expression checks and kernel-checked examples. These are reference examples,
not deployed-protocol fidelity tests. -/
namespace DefiKernel.Typed
namespace ExprTests

inductive TestAsset where
  | usd | share | collateral | debt
  deriving DecidableEq, Repr

instance : Fintype TestAsset := ⟨{.usd, .share, .collateral, .debt}, by
  intro a; cases a <;> simp⟩

abbrev E := Expr Bool TestAsset Bool []
abbrev Context := EvalContext Bool TestAsset Bool []

def priceKey : ObservationKey Bool := ⟨false, ⟨0⟩⟩
def otherKey : ObservationKey Bool := ⟨false, ⟨1⟩⟩
def usdCell : CellRef Bool TestAsset Bool TestAsset.usd := ⟨false, .caller⟩

def initialState : State Bool TestAsset Bool :=
  ⟨fun c ↦ if c = (false, false, TestAsset.usd) then 10 else 0, by
    intro c; split <;> decide⟩

def changedState : State Bool TestAsset Bool :=
  ⟨fun c ↦ if c = (false, true, TestAsset.usd) then 99 else initialState.balance c, by
    intro c; split
    · decide
    · exact initialState.nonneg c⟩

def environment : Environment TestAsset Bool := fun key ↦
  if key = priceKey then some ⟨⟨.price TestAsset.collateral TestAsset.usd, 2⟩, 20⟩ else none

def context : Context := ⟨initialState, environment, false, [true], .nil, 25⟩
def changedContext : Context := { context with state := changedState }
def missingContext : Context := { context with env := fun _ ↦ none }
def wrongUnitContext : Context :=
  { context with env := fun _ ↦ some ⟨⟨.scalar, 2⟩, 20⟩ }

def priced : E (.amount TestAsset.usd) :=
  .binary (.convert TestAsset.collateral TestAsset.usd) (.lit 3) (.observe ⟨priceKey⟩)

def debtValued : E (.amount TestAsset.usd) :=
  .binary (.convert TestAsset.debt TestAsset.usd) (.lit 7) (.lit 1)

def shares : E (.amount TestAsset.share) :=
  .binary (.unconvert TestAsset.share TestAsset.usd) (.lit 10) (.lit 2)

def freshness : E .bool :=
  .binary (.le .scalar) (.binary (.sub .scalar) .now (.timestamp priceKey)) (.lit 10)

def ledgerRead : E (.amount TestAsset.usd) := .balance usdCell

def withInactiveRead : E (.amount TestAsset.usd) :=
  .ite (.lit true) ledgerRead (.observe ⟨otherKey⟩)

def withInactiveStateRead : E (.amount TestAsset.usd) :=
  .ite (.lit true) ledgerRead (.balance ⟨false, .literal true⟩)

def badParty : E (.amount TestAsset.usd) := .balance ⟨false, .argument 2⟩
def validParty : E (.amount TestAsset.usd) := .balance ⟨false, .argument 0⟩

def argumentValue (values : List (PackedValue TestAsset)) : Except EvalFailure ℚ := do
  let args ← Args.check [.amount TestAsset.usd] values
  return args.get .here

def checks : List (String × Bool) := [
  ("expr_exact_price_conversion", decide (priced.eval context = .ok 6)),
  ("expr_explicit_debt_valuation", decide (debtValued.eval context = .ok 7)),
  ("expr_inverse_price_conversion", decide (shares.eval context = .ok 5)),
  ("expr_exact_fractional_conversion", decide
    ((Expr.binary (.convert TestAsset.collateral TestAsset.usd) (.lit (1 / 3)) (.lit (3 / 2)) :
      E (.amount TestAsset.usd)).eval context = .ok (1 / 2))),
  ("expr_same_unit_addition", decide
    ((Expr.binary (.add (.amount TestAsset.usd)) (.lit 2) (.lit 3) :
      E (.amount TestAsset.usd)).eval context = .ok 5)),
  ("expr_scalar_scaling", decide
    ((Expr.binary (.scale (.amount TestAsset.usd)) (.lit 2) (.lit 3) :
      E (.amount TestAsset.usd)).eval context = .ok 6)),
  ("expr_signed_negation", decide
    ((Expr.unary (.neg (.amount TestAsset.usd)) (.lit 2) :
      E (.amount TestAsset.usd)).eval context = .ok (-2))),
  ("expr_safe_scalar_division", decide
    ((Expr.binary (.divide (.amount TestAsset.usd)) (.lit 3) (.lit 2) :
      E (.amount TestAsset.usd)).eval context = .ok (3 / 2))),
  ("expr_zero_scalar_division_refused", decide
    ((Expr.binary (.divide (.amount TestAsset.usd)) (.lit 3) (.lit 0) :
      E (.amount TestAsset.usd)).eval context = .error .divisionByZero)),
  ("expr_safe_ratio", decide
    ((Expr.binary (.ratio (.amount TestAsset.usd)) (.lit 3) (.lit 2) :
      E .scalar).eval context = .ok (3 / 2))),
  ("expr_zero_ratio_refused", decide
    ((Expr.binary (.ratio (.amount TestAsset.usd)) (.lit 3) (.lit 0) :
      E .scalar).eval context = .error .divisionByZero)),
  ("expr_zero_inverse_price_refused", decide
    ((Expr.binary (.unconvert TestAsset.share TestAsset.usd) (.lit 10) (.lit 0) :
      E (.amount TestAsset.share)).eval context = .error .divisionByZero)),
  ("expr_missing_observation_refused", decide
    (priced.eval missingContext = .error .missingObservation)),
  ("expr_wrong_observation_unit_refused", decide
    (priced.eval wrongUnitContext = .error .observationUnit)),
  ("expr_tracked_freshness", decide (freshness.eval context = .ok true)),
  ("expr_stale_observation", decide (freshness.eval { context with now := 40 } = .ok false)),
  ("expr_missing_timestamp_refused", decide
    ((Expr.timestamp priceKey : E .scalar).eval missingContext = .error .missingObservation)),
  ("expr_fresh_time_tracked", decide (.currentTime ∈ freshness.envReads)),
  ("expr_timestamp_observation_tracked", decide (.observation priceKey ∈ freshness.envReads)),
  ("expr_inactive_environment_branch_tracked", decide
    (.observation otherKey ∈ withInactiveRead.envReads)),
  ("expr_inactive_state_branch_tracked", decide (withInactiveStateRead.stateReads =
    [⟨TestAsset.usd, usdCell⟩, ⟨TestAsset.usd, ⟨false, .literal true⟩⟩])),
  ("expr_inactive_missing_branch_not_evaluated", decide (withInactiveRead.eval context = .ok 10)),
  ("expr_boolean_and_is_eager", decide
    ((Expr.binary .and (.lit false) (.observe ⟨otherKey⟩) : E .bool).eval context =
      .error .missingObservation)),
  ("expr_boolean_or_is_eager", decide
    ((Expr.binary .or (.lit true) (.observe ⟨otherKey⟩) : E .bool).eval context =
      .error .missingObservation)),
  ("expr_successful_party_lookup", decide (validParty.eval context = .ok 0)),
  ("expr_failed_party_lookup_refused", decide (badParty.eval context = .error .partyArgument)),
  ("expr_concrete_read_resolution", decide
    (ledgerRead.resolveStateReads false [] = .ok [(false, false, TestAsset.usd)])),
  ("expr_footprint_party_lookup_refused", decide
    (badParty.resolveStateReads false [true] = .error .partyArgument)),
  ("expr_checked_argument", decide (argumentValue [⟨.amount TestAsset.usd, 7⟩] = .ok 7)),
  ("expr_wrong_argument_unit_refused", decide
    (argumentValue [⟨.amount TestAsset.debt, 7⟩] = .error .argumentUnit)),
  ("expr_missing_argument_refused", decide (argumentValue [] = .error .argumentCount)),
  ("expr_excess_argument_refused", decide
    (argumentValue [⟨.amount TestAsset.usd, 7⟩, ⟨.amount TestAsset.usd, 8⟩] =
      .error .argumentCount)),
  ("expr_unrelated_balance_change", decide
    (ledgerRead.eval changedContext = ledgerRead.eval context)),
  ("expr_read_change_observed", decide
    (ledgerRead.eval { context with caller := true } = .ok 0))
]

end ExprTests

-- BEGIN PROOFS

namespace ExprTests

#eval do
  let mut failed := 0
  for (label, passed) in checks do
    IO.println s!"{label}: {passed}"
    unless passed do failed := failed + 1
  if failed != 0 then throw (IO.userError s!"Typed runtime comparisons failed: {failed}")

/-- This is a kernel-checked exact arithmetic fact, separate from the executed comparisons. -/
theorem price_conversion_exact : priced.eval context = .ok 6 := by
  norm_num [priced, Expr.eval, readObservation, context, environment, BinaryOp.eval,
    bind, Except.bind]

theorem inverse_price_exact : shares.eval context = .ok 5 := by
  norm_num [shares, Expr.eval, BinaryOp.eval, bind, Except.bind]

theorem zero_division_refused :
    (Expr.binary (.divide (.amount TestAsset.usd)) (.lit 3) (.lit 0) :
      E (.amount TestAsset.usd)).eval context = .error .divisionByZero := by decide

/-- Read dependence transports the result without evaluating the arithmetic expression. -/
theorem unrelated_balance_preserved : ledgerRead.eval context = ledgerRead.eval changedContext := by
  apply ledgerRead.eval_congr context changedContext rfl
  · intro ref href
    simp only [ledgerRead, Expr.stateReads, List.mem_singleton] at href
    subst ref
    rfl
  · intro key hkey
    simp [ledgerRead, Expr.envReads] at hkey

-- These commands must fail to elaborate their terms. Runtime unit checks are separate above.
#check_failure (Expr.binary (.add (.amount TestAsset.usd)) ledgerRead
  (.lit 1 : E (.amount TestAsset.debt)) : E (.amount TestAsset.usd))

#check_failure (Expr.binary (.convert TestAsset.collateral TestAsset.usd)
  (.lit 1 : E (.amount TestAsset.collateral))
  (.lit 2 : E (.price TestAsset.usd TestAsset.collateral)) : E (.amount TestAsset.usd))

#check_failure (Expr.binary (.scale (.amount TestAsset.debt)) (.lit 1)
  (.lit 2 : E (.amount TestAsset.debt)) : E (.amount TestAsset.usd))

end ExprTests
end DefiKernel.Typed

```

### lean/DefiKernel/Typed/Transition.lean
SHA256 73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2
```
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

```

### lean/DefiKernel/Typed/TransitionTests.lean
SHA256 e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc
```
import DefiKernel.Typed.Transition

namespace DefiKernel.Typed
namespace TransitionTests

abbrev T := Template Bool Bool Bool
abbrev R := Request Bool Bool Bool
abbrev S := State Bool Bool Bool
abbrev C := CapabilityStore Bool Bool Bool
abbrev Result := Except Refusal (ExecutionResult Bool Bool Bool)

def alice : CellRef Bool Bool Bool false := ⟨false, .caller⟩
def bob : CellRef Bool Bool Bool false := ⟨false, .literal true⟩
def state : S := ⟨fun _ ↦ 10, by intro c; decide⟩
def context : InvocationContext Bool Bool := ⟨false, false⟩
def environment : Environment Bool Bool := fun _ ↦ some ⟨⟨.amount false, 3⟩, 10⟩
def key : ObservationKey Bool := ⟨false, ⟨0⟩⟩

def transfer : T :=
  { signature := [], domain := false, partyArity := 0, guard := .lit true
    deltas := [⟨false, alice, .lit (-3)⟩, ⟨false, bob, .lit 3⟩]
    supplyDeltas := [], stateReads := [], envReads := []
    writes := [⟨false, alice⟩, ⟨false, bob⟩] }

def registry (template : T) : Registry Bool Bool Bool :=
  fun op ↦ if op = ⟨0⟩ then some template else none

/-- Every test capability is issued under configuration derived from the execution registry. -/
def capabilities (template : T) : C :=
  ([Right.invoke, .debit (false, false, false),
      .changeSupply false false, .changeSupply false true] : List (Right Bool Bool Bool)).foldl
    (fun store right ↦
      match issueCapability (registryAuthorityConfig (registry template) (fun _ ↦ false))
          context store ⟨false, false, ⟨0⟩, right⟩ with
      | .ok (_, updated) => updated
      | .error _ => store) .empty

def request : R := ⟨⟨0⟩, [], [], [⟨0⟩, ⟨1⟩, ⟨2⟩, ⟨3⟩], none⟩

def runWith (template : T) (req : R) (caps : C) (ctx : InvocationContext Bool Bool) : Result :=
  execute (registry template) caps ctx environment 10 req state

def run (template : T) : Result := runWith template request (capabilities template) context

def accepted : Result → Bool
  | .ok _ => true
  | .error _ => false

def refused (reason : Refusal) : Result → Bool
  | .error actual => actual == reason
  | .ok _ => false

def allBalances (post : ExecutionResult Bool Bool Bool)
    (expected : Cell Bool Bool Bool → ℚ) : Bool :=
  [false, true].all fun d ↦ [false, true].all fun p ↦ [false, true].all fun a ↦
    post.state.balance (d, p, a) == expected (d, p, a)

def transferExact : Result → Bool
  | .error _ => false
  | .ok post => allBalances post
      (fun c ↦ if c = (false, false, false) then 7
        else if c = (false, true, false) then 13 else 10) &&
      post.capabilities == capabilities transfer

def guardRead : T :=
  { transfer with guard := .binary (.le (.amount false)) (.balance alice) (.lit 100)
                  stateReads := [⟨false, alice⟩] }

def effectRead : T :=
  { transfer with
    deltas := [⟨false, alice, .unary (.neg (.amount false)) (.balance alice)⟩,
      ⟨false, bob, .balance alice⟩]
    stateReads := [⟨false, alice⟩] }

def observed : T :=
  { transfer with
    deltas := [⟨false, alice, .unary (.neg (.amount false)) (.observe ⟨key⟩)⟩,
      ⟨false, bob, .observe ⟨key⟩⟩]
    envReads := [.observation key] }

def mint : T :=
  { transfer with deltas := [⟨false, bob, .lit 3⟩]
                  supplyDeltas := [⟨false, false, .lit 3⟩] }

def supplyRead : T :=
  { mint with deltas := [⟨false, bob, .balance alice⟩]
              supplyDeltas := [⟨false, false, .balance alice⟩]
              stateReads := [⟨false, alice⟩] }

def supplyOnlyRead : T :=
  { mint with supplyDeltas := [⟨false, false,
      .ite (.lit true) (.lit 3) (.balance alice)⟩]
              stateReads := [⟨false, alice⟩] }

def inactiveRead : T :=
  { transfer with
    guard := .ite (.lit true) (.lit true)
      (.binary (.le (.amount false)) (.balance alice) (.lit 100))
    stateReads := [⟨false, alice⟩] }

def foreignRead : T :=
  { transfer with
    guard := .binary (.le (.amount false)) (.balance ⟨true, .caller⟩) (.lit 100)
    stateReads := [⟨false, ⟨true, .caller⟩⟩] }

def repeated : T :=
  { transfer with deltas := [⟨false, alice, .lit (-1)⟩, ⟨false, alice, .lit (-2)⟩,
      ⟨false, bob, .lit 1⟩, ⟨false, bob, .lit 2⟩] }

def repeatedSupply : T :=
  { mint with supplyDeltas := [⟨false, false, .lit 1⟩, ⟨false, false, .lit 2⟩] }

def revoked : C :=
  match revokeCapability (registryAuthorityConfig (registry transfer) (fun _ ↦ false))
      context (capabilities transfer) ⟨1⟩ with
  | .ok store => store
  | .error _ => .empty

def mintExact : Result → Bool
  | .error _ => false
  | .ok post =>
    allBalances post (fun c ↦ if c = (false, true, false) then 13 else 10) &&
    ([false, true].all fun d ↦ [false, true].all fun a ↦
      total post.state d a == if (d, a) = (false, false) then 23 else 20) &&
    post.capabilities == capabilities mint

def clockRead : T :=
  { transfer with
    guard := .binary (.le .scalar) (.timestamp key) .now
    envReads := [.observation key, .currentTime] }

def foreignObserved : T :=
  { transfer with
    deltas := [⟨false, alice, .unary (.neg (.amount false)) (.observe ⟨⟨true, ⟨0⟩⟩⟩)⟩,
      ⟨false, bob, .observe ⟨⟨true, ⟨0⟩⟩⟩⟩]
    envReads := [.observation ⟨true, ⟨0⟩⟩] }

def foreignNetZero : T :=
  { transfer with deltas := transfer.deltas ++
      [⟨false, ⟨true, .literal true⟩, .lit (-3)⟩, ⟨false, ⟨true, .literal true⟩, .lit 3⟩] }

def revokedExact : Bool :=
  decide (revoked.entries.length = 4) &&
  revoked.lookup ⟨1⟩ == some ⟨⟨false, false, ⟨0⟩, .debit (false, false, false)⟩, false⟩ &&
  revoked.lookup ⟨0⟩ == (capabilities transfer).lookup ⟨0⟩ &&
  authorizesId revoked context request.operation .invoke ⟨0⟩

def positiveProvisioning : Bool :=
  [transfer, guardRead, effectRead, observed, mint, supplyRead, supplyOnlyRead, inactiveRead,
    repeated, repeatedSupply, clockRead, foreignObserved, foreignNetZero].all
    (fun t ↦ decide ((capabilities t).entries.length = 4))

/-- Positive siblings use the same executor and expose the expected refusal precedence. -/
def checks : List (String × Bool) :=
  [ ("transition_transfer_exact", transferExact (run transfer))
  , ("transition_issue_all_rights", decide ((capabilities transfer).entries.length = 4))
  , ("transition_unknown_operation", refused .unknownOperation
      (runWith transfer { request with operation := ⟨99⟩ } (capabilities transfer) context))
  , ("transition_claimed_actor_ok", transferExact
      (runWith transfer { request with claimedActor := some false } (capabilities transfer) context))
  , ("transition_claimed_actor_wrong", refused .actorMismatch
      (runWith transfer { request with claimedActor := some true } (capabilities transfer) context))
  , ("transition_wrong_cap_holder", refused .unauthorizedInvoke
      (runWith transfer request (capabilities transfer) ⟨true, false⟩))
  , ("transition_context_domain", refused .domainMismatch
      (runWith transfer request (capabilities transfer) ⟨false, true⟩))
  , ("transition_party_arity", refused .partyArity
      (runWith transfer { request with parties := [true] } (capabilities transfer) context))
  , ("transition_argument_count", refused (.evaluation .argumentCount)
      (runWith transfer { request with arguments := [⟨.scalar, 3⟩] } (capabilities transfer) context))
  , ("transition_invoke_required", refused .unauthorizedInvoke
      (runWith transfer { request with capabilityIds := [⟨1⟩, ⟨2⟩, ⟨3⟩] }
        (capabilities transfer) context))
  , ("transition_guard_false", refused .guard (run { transfer with guard := .lit false }))
  , ("transition_guard_read_ok", accepted (run guardRead))
  , ("transition_guard_read_missing", refused .stateReadFootprint
      (run { guardRead with stateReads := [] }))
  , ("transition_effect_read_ok", accepted (run effectRead))
  , ("transition_effect_read_missing", refused .stateReadFootprint
      (run { effectRead with stateReads := [] }))
  , ("transition_inactive_read_ok", accepted (run inactiveRead))
  , ("transition_inactive_read_missing", refused .stateReadFootprint
      (run { inactiveRead with stateReads := [] }))
  , ("transition_supply_read_ok", accepted (run supplyRead))
  , ("transition_supply_only_read_ok", accepted (run supplyOnlyRead))
  , ("transition_supply_only_read_missing", refused .stateReadFootprint
      (run { supplyOnlyRead with stateReads := [] }))
  , ("transition_observed_ok", transferExact (run observed))
  , ("transition_env_read_missing", refused .envReadFootprint
      (run { observed with envReads := [] }))
  , ("transition_observation_missing", refused (.evaluation .missingObservation)
      (execute (registry observed) (capabilities observed) context (fun _ ↦ none) 10 request state))
  , ("transition_foreign_state_read", refused .crossDomain (run foreignRead))
  , ("transition_foreign_effect", refused .crossDomain
      (run { transfer with deltas := [⟨false, alice, .lit (-3)⟩,
        ⟨false, ⟨true, .literal true⟩, .lit 3⟩] }))
  , ("transition_debit_required", refused .unauthorizedDebit
      (runWith transfer { request with capabilityIds := [⟨0⟩, ⟨2⟩, ⟨3⟩] }
        (capabilities transfer) context))
  , ("transition_revoked_debit", refused .unauthorizedDebit
      (runWith transfer request revoked context))
  , ("transition_mint_ok", mintExact (run mint))
  , ("transition_supply_required", refused .unauthorizedSupply
      (runWith mint { request with capabilityIds := [⟨0⟩, ⟨1⟩] } (capabilities mint) context))
  , ("transition_insufficient_funds", refused .insufficientFunds
      (run { transfer with deltas := [⟨false, alice, .lit (-11)⟩, ⟨false, bob, .lit 11⟩] }))
  , ("transition_unbalanced", refused .accounting
      (run { transfer with deltas := [⟨false, alice, .lit (-3)⟩, ⟨false, bob, .lit 4⟩] }))
  , ("transition_mismatched_supply", refused .accounting
      (run { mint with supplyDeltas := [⟨false, false, .lit 2⟩] }))
  , ("transition_wrong_asset_accounting", refused .accounting
      (run { mint with supplyDeltas := [⟨false, true, .lit 3⟩] }))
  , ("transition_missing_write", refused .writeFootprint
      (run { transfer with writes := [⟨false, alice⟩] }))
  , ("transition_repeated_effects_sum", transferExact (run repeated))
  , ("transition_repeated_supply_sum", mintExact (run repeatedSupply))
  , ("transition_duplicate_cap_ids", transferExact
      (runWith transfer { request with capabilityIds := ⟨1⟩ :: request.capabilityIds }
        (capabilities transfer) context))
  , ("transition_positive_provisioning", positiveProvisioning)
  , ("transition_revoked_tombstone_exact", revokedExact)
  , ("transition_clock_read_ok", transferExact (run clockRead))
  , ("transition_now_read_missing", refused .envReadFootprint
      (run { clockRead with envReads := [.observation key] }))
  , ("transition_timestamp_read_missing", refused .envReadFootprint
      (run { clockRead with envReads := [.currentTime] }))
  , ("transition_foreign_supply", refused .crossDomain
      (run { mint with supplyDeltas := [⟨true, false, .lit 3⟩] }))
  , ("transition_foreign_observation_ok", transferExact (run foreignObserved))
  , ("transition_foreign_netzero_ok", match run foreignNetZero with
      | .error _ => false
      | .ok post => allBalances post
          (fun c ↦ if c = (false, false, false) then 7
            else if c = (false, true, false) then 13 else 10) &&
          post.capabilities == capabilities foreignNetZero)
  , ("transition_false_guard_failing_effect_precedence", refused (.evaluation .divisionByZero)
      (run { transfer with
        guard := .lit false
        deltas := [⟨false, bob, .binary (.divide (.amount false)) (.lit 3) (.lit 0)⟩] }))
  , ("transition_underfunded_unbalanced_precedence", refused .insufficientFunds
      (run { transfer with deltas := [⟨false, alice, .lit (-11)⟩, ⟨false, bob, .lit 12⟩] }))
  , ("transition_false_guard_missing_read_precedence", refused .guard
      (run { guardRead with
        guard := .ite (.lit true) (.lit false) guardRead.guard
        stateReads := [] }))
  ]

end TransitionTests

-- BEGIN PROOFS

#eval show IO _root_.Unit from do
  let comparisons := TransitionTests.checks
  if comparisons.isEmpty then throw (IO.userError "Typed runtime comparisons empty")
  for (label, ok) in comparisons do IO.println s!"{label}: {ok}"
  let failures := comparisons.filter (fun entry ↦ !entry.2)
  if !failures.isEmpty then
    throw (IO.userError s!"Typed runtime comparisons failed: {failures.length}")

end DefiKernel.Typed

```

### lean/DefiKernel/Typed/Types.lean
SHA256 5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82
```
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

```

### Evidence review/semantic-kernel/sprint6/integration/lean-runs.json
```
{
  "source_revision": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
  "runs": [
    {
      "label": "build",
      "command": [
        "lake",
        "build"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:52.157795+00:00",
      "finished_utc": "2026-09-07T05:34:52.829580+00:00",
      "exit": 0,
      "log": "build.log",
      "log_sha256": "adeab4dd0170fbb929186c5568b59c601819b284154e94085a0dd568d4255764"
    },
    {
      "label": "parallel-audit",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Parallel/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:52.833189+00:00",
      "finished_utc": "2026-09-07T05:34:54.577568+00:00",
      "exit": 0,
      "log": "parallel-audit.log",
      "log_sha256": "b8d41e3bab4a6ae65dd3632d85c514421076d6fc6d6f1d5c3a7989965b0368e9"
    },
    {
      "label": "parallel-verify",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Parallel/Verify.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:52.833555+00:00",
      "finished_utc": "2026-09-07T05:34:56.979265+00:00",
      "exit": 0,
      "log": "parallel-verify.log",
      "log_sha256": "82e4c2c957323dde95640e783c7306a124e9627f96a97a1785ccc9c1fe2c9eaf"
    },
    {
      "label": "composition-audit",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Composition/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:52.834103+00:00",
      "finished_utc": "2026-09-07T05:34:54.314266+00:00",
      "exit": 0,
      "log": "composition-audit.log",
      "log_sha256": "9173b87109f8c6c3f6afae01958f1480d84a8ec42cd34429f56aa077b1a89368"
    },
    {
      "label": "composition-verify",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Composition/Verify.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:54.314362+00:00",
      "finished_utc": "2026-09-07T05:34:59.056427+00:00",
      "exit": 0,
      "log": "composition-verify.log",
      "log_sha256": "56e39dbb1623f32c71599b0a70c3a9b7752319ccacadac71b2ac95565ef31fe0"
    },
    {
      "label": "typed-audit",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Typed/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:54.577704+00:00",
      "finished_utc": "2026-09-07T05:34:56.128775+00:00",
      "exit": 0,
      "log": "typed-audit.log",
      "log_sha256": "19ecc53feba3fbe993b6f2fed294efb170716f6b5a555a4d34bd1bad7f05af1e"
    },
    {
      "label": "typed-verify",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Typed/Verify.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:56.128916+00:00",
      "finished_utc": "2026-09-07T05:35:01.954985+00:00",
      "exit": 0,
      "log": "typed-verify.log",
      "log_sha256": "0fd188b353c6f014bebb5baaf53447f2660a07619fe2236eca91e9eaa5d24790"
    },
    {
      "label": "audit",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/Audit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:56.979517+00:00",
      "finished_utc": "2026-09-07T05:34:58.821822+00:00",
      "exit": 0,
      "log": "audit.log",
      "log_sha256": "61819efaae5d9062231e6dd3e126b3ce93cfb225cdbbdc8498d630f568cbbe63"
    },
    {
      "label": "contractaudit",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/ContractAudit.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:58.822384+00:00",
      "finished_utc": "2026-09-07T05:35:00.781051+00:00",
      "exit": 0,
      "log": "contractaudit.log",
      "log_sha256": "660f556e96037016023e457e37f692acf9e3ff0f16072fcc271511537494e438"
    },
    {
      "label": "verifyaxioms",
      "command": [
        "lake",
        "env",
        "lean",
        "DefiKernel/VerifyAxioms.lean"
      ],
      "cwd": "/home/charl/defiformal/lean",
      "started_utc": "2026-09-07T05:34:59.057109+00:00",
      "finished_utc": "2026-09-07T05:35:03.850883+00:00",
      "exit": 0,
      "log": "verifyaxioms.log",
      "log_sha256": "4fe1669dcec9ff26f7626f3a2125aea61719fe3b8c25e8eff385457b54553c8f"
    }
  ],
  "sources": {
    "lean/DefiKernel/ContractExamples.lean": "4423c79ae828489f07d5e1a2db93285a6c30b56912b467df40767026f2e0e51b",
    "lean/DefiKernel/Core.lean": "767395925f09eeb65929c323182900c4cb962d0c117d0bb6e5871dfb39fc024d",
    "lean/DefiKernel/Examples.lean": "3a3eaf5e43e5a98cb179785789e850d333652a60f112cba9b0df5ce80bf26d28",
    "lean/DefiKernel/ContractAcceptance.lean": "a9dfe9006ea32d590f021fa4b3d1c76411ecc872ee524c40ccf2c1406779828f",
    "lean/DefiKernel/Acceptance.lean": "9635558b7bb16a66375358a4936ec73d7ea4b07ee959bf3d2583197584e7ff11",
    "lean/DefiKernel/AxiomAudit.lean": "4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524",
    "lean/DefiKernel/Contracts.lean": "22ec064df455f9472d7c48b956d27f700fc54862f1d7f0bb0acb1051b84e84b2",
    "lean/DefiKernel/Audit.lean": "7843c62e722e2c218e44c532d0f850f66c7ab7eed18715bc5a03dc773b17d400",
    "lean/DefiKernel/ContractAudit.lean": "600761fd4f41f112218ea3ab9b74062369c28ef9cf483627b57589b8be7159d9",
    "lean/DefiKernel/VerifyAxioms.lean": "da8c2b3fd23780417c717a39b3eacbc06e611dfa6b76a576c9f6bd0b0398482e",
    "lean/DefiKernel/Parallel/Dependency.lean": "72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245",
    "lean/DefiKernel/Parallel/Tests.lean": "626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725",
    "lean/DefiKernel/Parallel/Execution.lean": "a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089",
    "lean/DefiKernel/Parallel/CompatibilityTests.lean": "d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379",
    "lean/DefiKernel/Parallel/Compatibility.lean": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243",
    "lean/DefiKernel/Parallel/Observation.lean": "38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f",
    "lean/DefiKernel/Parallel/Examples.lean": "d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd",
    "lean/DefiKernel/Parallel/ExecutionTests.lean": "4b88467004d0392fba8aff169544bbebf586a06c74ca5426a2ca6ab7676ded99",
    "lean/DefiKernel/Parallel/Preservation.lean": "faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10",
    "lean/DefiKernel/Parallel/PreservationFixtures.lean": "0b04488e2d75cbbc4997217aae288692f35571cbcbdec40420254b59948ba9e7",
    "lean/DefiKernel/Parallel/Commutation.lean": "c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef",
    "lean/DefiKernel/Parallel/ObservationTests.lean": "227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e",
    "lean/DefiKernel/Parallel/Audit.lean": "d6cb7e1c7b948b4404007a50ca30bf5bcf5883bd77c6ce700b229884d4e094b9",
    "lean/DefiKernel/Parallel/Verify.lean": "ff25ad430ff36275ecaf7ccfab8a55f2e853cbd9381a739163f81bd3d7bbd3ab",
    "lean/DefiKernel/Typed/ExprTests.lean": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29",
    "lean/DefiKernel/Typed/Transition.lean": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "lean/DefiKernel/Typed/Authority.lean": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "lean/DefiKernel/Typed/Examples.lean": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "lean/DefiKernel/Typed/Types.lean": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "lean/DefiKernel/Typed/Acceptance.lean": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
    "lean/DefiKernel/Typed/Expr.lean": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "lean/DefiKernel/Typed/AuthorityTests.lean": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77",
    "lean/DefiKernel/Typed/TransitionTests.lean": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc",
    "lean/DefiKernel/Typed/Audit.lean": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
    "lean/DefiKernel/Typed/Verify.lean": "2f8fc6cb7202a70d2438dad6d665edcccc3fec47add99087284b03b9b30f8d8d",
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
    "lean/DefiKernel/Parallel/Dependency/Adapter.lean": "10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c",
    "lean/DefiKernel/Parallel/Dependency/Fixtures.lean": "14bac7bfdc273c9de0d416e4489f6d16eb9d02e5e01f082ef0aeb194ef17de45",
    "lean/DefiKernel.lean": "ffa25f35c430bef69e654d18e2d907895aa0c8e7681dada4d61edb858c3f10bb"
  },
  "source_drift": [],
  "git_object_mismatches": [],
  "all_passed": true
}

```

### Evidence review/semantic-kernel/sprint6/preservation.json
```
{
  "checked_utc": "2026-09-07T05:36:45.543012+00:00",
  "baseline_commit": "cd3187534f91f2a0f25e65722652d948ff178f39",
  "source_candidate": "7cb4807d1ff22c5ac804b03feb4a2530c46146f2",
  "checks": {
    "preserved_files": {
      "checked": 165,
      "mismatches": []
    },
    "protected_kernel_sources": {
      "checked": 32,
      "mismatches": []
    },
    "tracked_lean_files": {
      "checked": 435,
      "mismatches": []
    },
    "import_root_only_adds_parallel_verify": true
  },
  "baseline_manifest_sha256": "38bec6049d75919b99097db5e654e9b421791c8f754805cd53262366c95eb551"
}

```

### Evidence review/semantic-kernel/sprint6/financial-report.md
```
# Sprint 6 financial fixtures

`Examples.lean` and `Tests.lean` are new stock GPT-6 implementation sources. The Lean skill was
used. Targeted normal Lake build passed, and the standalone driver ran 59 unique, nonempty
financial comparisons: 59 true, zero failures. Neither imported source contains `#eval`.
No existing source, task checklist, or commit was changed by this subtask.

All fixture IDs have prefix `parallel.fixture.`. The exact inventory and results are in
[the runtime log](financial-evidence/runtime.log). Commands, exits, working directories and
versions are in [runs.json](financial-evidence/runs.json); full captured source hashes are in
[source-inputs.json](financial-evidence/source-inputs.json). The recorded Git head is execution
context, not the identity of these uncommitted source bytes.

`Examples.matchesExpected` compares all 32 domain/party/asset balances, the complete joined
capability store, both branch capability stores, and both exact `BranchObservation` values.
Expected observations include original invocation steps, resolved requests (parties, argument
values, capability IDs and actor), evaluated receipt lists and footprint inventories, ordered
typed snapshots, local next positions, and exact optional refusal indices/steps/reasons.
Expected records are written directly; neither template evaluation nor actual cursor output is
used to generate them. `balanceTable` fixes nonzero untouched vault USD20, pool USD1 and protected
collateral9 in addition to the four principal USD/share cells, with every remaining cell zero.
Actual serial LR and RL results are checked directly against the same independent expected
records for 14 principal scenarios; implementation-to-implementation equality is supplementary.

| Scenario family | Exact check IDs after prefix | Independent expected result |
| --- | --- | --- |
| Funded core and same-asset pairs | `basic.complete`, `same-asset.complete` | USD7/3 and shares16/4; same-asset peer vault USD16/pool USD5; all other cells/store fixed |
| Immediate/middle/dual refusal | `refusal.peer-runs`, `refusal.prefix-kept`, `refusal.dual` | Exact insufficient-funds indices0 or1; peer completes, each successful prefix remains |
| Financial refusal taxonomy | `refusal.guard`, `refusal.input-unit`, `refusal.missing-capability` | Exact guard/inputUnit/unauthorizedInvoke with independent funded right outcome |
| Empty identities | `empty.right`, `empty.left`, `empty.both` | Complete expected nonempty result or original ledger/store with empty observations |
| Qualified and local outputs | `routing.peer-only`, `routing.funded-literal`, `routing.own-history`, `routing.both-own-history` | Peer-only right key holds USD5 but left refuses at1; literal5 succeeds from left balance7; local snapshots3/6 and4/8 remain distinct and immutable |
| Shared qualified key | `routing.shared-qualified-key` | Same component/port/local-step read-only collateral9 appears in both fixed branch slots |
| Boundary principal/time | `boundary.local-identity` | Left principal Alice then Bob at times100/101; right vault at200/201; USD8/2 and shares14/6 |
| Capability store | `capability.revoked`, `capability.actual-revoke`, `capability.reusable-shared-grant` | Real revoke matches explicit right-invoke tombstone; right refuses while left succeeds; same reusable invoke grant authorizes disjoint same-operation branches |
| Supply changes | `supply.complete`, `supply.both-receipts`, `supply.prefix-refusal` | Explicit USD+2/share-3 receipts, joined balances12/17, correct full supply matrix; failed later burn preserves prior supply |
| Stateful prefixes | `stateful.prefix`, `stateful.supply` | USD effects5 then5/2 before guard refusal at2; share mints10 then15 from evolving balances20→30→45 |
| Cancelling undeclared target | `cancelling.admission`, `cancelling.funded` | +1/-1 target conflicts despite net0; independent underlying branch succeeds with original ledger and exact receipt |
| Admission refusal | `refusal.world-preserved`, `refusal.suffix-world-preserved` | Exact initial world and conflict/located unknown-operation reason; refused result has no cursor or execution artifacts |
| Raw context scope | `raw-context-differs` | Canonical agreement with LR while right raw event pre-worlds demonstrably differ |

Actual LR/RL independent comparisons append `.lr.complete` and `.rl.complete` to these prefixes:
`basic`, `prefix`, `routing`, `boundary`, `supply`, `stateful`, `revoked`, `same-asset`, `peer-runs`,
`dual`, `both-own-history`, `stateful-supply`, `shared-qualified-key`, and `supply-prefix`.

Designated mutation oracles coordinated with the mutation agent:

| Planned mutant | Named oracle |
| --- | --- |
| 1 write/write bypass | `parallel.compat.write-write-witness` |
| 2 hidden syntactic reads | `parallel.compat.hidden-inactive-guard` |
| 3 outputs omitted | `parallel.compat.output-dependency` |
| 4 zero delta target omitted | `parallel.compat.zero-target` |
| 5 reverse conflict omitted | `parallel.compat.reverse-read` |
| 6 peer cancellation | `parallel.fixture.refusal.peer-runs` |
| 7 prefix rollback | `parallel.fixture.refusal.prefix-kept` |
| 8 whole-world replacement | `parallel.fixture.basic.complete` |
| 9 doubled initial balances | `parallel.fixture.basic.complete` |
| 10 peer output leakage | `parallel.fixture.routing.peer-only` |
| 11 boundary position/identity | `parallel.fixture.boundary.local-identity` |
| 12 dropped right supply | `parallel.fixture.supply.both-receipts` (actual `Joined.supply`) |
| 13 stale/live capabilities | `parallel.fixture.capability.revoked` (right grant index2) |
| 14 stale intra-branch state | `parallel.fixture.stateful.prefix` |

These are bounded development comparisons, not preserved holdouts or generic proofs. New named
generic proof claims remain in the separate compatibility/dependency/commutation/preservation
modules. The initial ledger's nonnegativity proof is checked as part of its state construction.
Mutation detections, full import/axiom coverage, historical regression and native external review
are separate integration evidence, not implied by this focused test pass. Source is frozen for
mutation replay pending the coordinated integration handoff.

Owned source SHA-256 values:

- `lean/DefiKernel/Parallel/Examples.lean`: `d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd`
- `lean/DefiKernel/Parallel/Tests.lean`: `626dadde5519715fc8d92324ac483c8d00c049001313f1257103a004b284f725`

```

### Evidence review/semantic-kernel/sprint6/preservation-report.md
```
# Sprint 6 preservation proof report

GPT-6 stock-harness implementation. Observed HEAD at final evidence recording:
`2267e005d988f0e32d014f2d76d98a9410360187`, with new uncommitted Sprint 6 source.
The exact source bytes, rather than a clean-commit claim, bind this evidence.
No historical files, commits, or task checkboxes were changed by this agent.

## Verified APIs

`Preservation.lean` contains 25 named generic theorems. `PreservationFixtures.lean`
contains 20 concrete reference theorems. Exact statements and file hashes are in
`preservation-proof-inventory.json`.

- `Joined.supply` is executable before the proof marker. It sums
  `traceSupply joined.left.events` and `traceSupply joined.right.events`.
  `runParallel_executed_accounting` proves, for every domain/asset, that the actual
  public executed result's total is its initial total plus this supply. The proof
  uses actual branch receipt accounting, admitted write disjointness, and proved
  branch locality to justify the region merge. It does not assume final totals.
- `runBranch_events_invoke` derives invocation-only event membership from the
  existing runner's ordered-prefix theorem. `trace_invoke_stores` proves every
  event's pre/post capability store equals the initial store. Consequently
  `runParallel_executed_authority` establishes invocation, debit and supply rights
  from that fixed initial store at each successful event's own local boundary.
  Failed suffixes do not discard earlier point-of-use authority evidence.
- `runBranch_prefix_nonnegative` and `runParallel_executed_nonnegative` expose
  the nonnegativity witnesses already carried by each state. They are not claims
  of automatic invariant discovery; the executed-result premise in the latter
  serves API scope and is not needed to recover a state's existing witness.
- `runParallel_executed_frame` proves all cells outside both analyzed write lists
  unchanged and the capability store unchanged. `runParallel_executed_supported_frame`
  lifts this to predicates with explicit support avoiding both regions.
- `mergeWorld_two_invariants` transports the separate branch predicates to the
  joined state using their support and the peer's disjoint write region.
  `runParallel_executed_two_invariants` first obtains each branch predicate by
  initialized induction. Its `LocalPreservation` premise requires preservation
  at actual `StepSound` transitions from a state satisfying the predicate; this
  remains an explicit local proof obligation, not a circular peer assumption.
- `evaluated_supplies_empty`, `extractReceipt_supplies_empty`, `step_no_supply`
  and `local_total_preservation` provide a concrete route from registered
  supply-free templates to total conservation. `supports_total` proves the
  exact domain/asset ledger support needed for that predicate.

All generic financial statements quantify over the existing finite identity
types, exact rational ledger and actual composition executor. Lower-level merge
lemmas state explicit locality/disjointness premises; public execution theorems
derive them from accepted analysis. Environment truth and boundary/store
authenticity remain external trust assumptions of the existing kernel.

## Concrete instances and counterexamples

The transfer fixture reuses the new compatibility development catalog and its
independently specified initial ledger: Alice USD 10, vault shares 20, other cells
zero. One branch transfers 3 USD; the other transfers 4 shares.

- `initialized_two_invariants` proves joined USD total 10 and share total 20 from
  initialization, separately proved local conservation, exact predicate supports,
  and discharged peer-write disjointness. It is not a bare computation of totals.
- `protected_collateral` instantiates the public supported-frame theorem at the
  untouched Alice collateral cell. `joined_authority` and `joined_nonnegative`
  instantiate the authority and state-witness results for the actual run.
- `unsupported_counterexample` exhibits empty-region agreement while Alice's USD
  predicate changes from 10 to 7. `unsupported_is_not_supported` proves that the
  proposed empty support is false. `written_support_counterexample` supplies a
  correct singleton support and shows why touching that support still prevents
  unconditional framing.
- Independent mint/burn templates have explicit supply effects: +2 USD at Alice
  and -4 shares at the vault. Exact supply capabilities are added to the fixture
  store. `supply_receipts` proves both real event lists have length one and the
  aggregate supplies are +2/-4. `supply_totals` derives actual totals 12/16 from
  the generic public accounting theorem and those explicit receipt amounts.
- `prefix_refusal_receipts` proves that mint succeeds before an exact local-index-1
  `unauthorizedInvoke` refusal caused by an empty capability selection. The peer
  burn succeeds independently. The retained supplies remain +2/-4.
  `prefix_authority` and `prefix_accounting` instantiate the generic authority
  and accounting theorems on that refused-prefix execution.

Closed finite comparisons use Lean kernel reduction (`decide +kernel`), not
`native_decide`. These are development fixtures, not deployed-protocol evidence.

## Verification and source identity

From `lean/`, `lake build DefiKernel.Parallel.PreservationFixtures` passed with
exit 0, 937 jobs. Full log: `preservation-build.log`.
The final `Preservation.lean` LSP diagnostics also reported zero errors.
Linter warnings remain advisory; no source cleanup was performed after the
parent froze the mutation runner's imported source closure.

From `lean/`,
`lake env lean ../review/semantic-kernel/sprint6/preservation-axioms.lean`
passed with exit 0. All 45 expected named declarations matched the 45 actual
disclosures exactly. Each transitive axiom set is a subset of
`propext`, `Classical.choice`, `Quot.sound`. Full log: `preservation-axioms.log`.
Tool: Lean `4.33.0-rc2`, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`.

`preservation-verification.json` records the commands, outcomes, owned source
hashes, artifact hashes and hashes of all 20 local Lean source files in this
import closure. This named disclosure check does not replace the parent's full
imported theorem/supplemental axiom audit, integrated tests or native review.

| Source | SHA-256 |
| --- | --- |
| `lean/DefiKernel/Parallel/Preservation.lean` | `faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10` |
| `lean/DefiKernel/Parallel/PreservationFixtures.lean` | `0b04488e2d75cbbc4997217aae288692f35571cbcbdec40420254b59948ba9e7` |

Both files are final and frozen for parent integration. The parent verification
root imports `PreservationFixtures`. Native implementation review and remaining
Sprint 6 acceptance/delivery work are owned by the parent task.

```

### Evidence review/semantic-kernel/sprint6/dependency-report.md
```
# Sprint 6 dependency proof report

Implemented by the GPT-6 stock-harness dependency agent. Starting HEAD:
`2267e005d988f0e32d014f2d76d98a9410360187`. These checks ran with new,
uncommitted Sprint 6 sources and concurrent work in other new modules. They are
not evidence for a clean committed candidate or the complete Sprint 6 gate.
No historical source was edited by this agent. No commit or task checkbox was made.

## Verified scope

The three modules contain 38 named theorems: 20 generic core/adapter declarations,
17 concrete dependency fixtures, and one refusal-detector helper over the fixture
types. The named inventory includes exact theorem source statements and hashes:
`dependency-proof-inventory.json`.

| API | Quantification and premises | Verified conclusion |
| --- | --- | --- |
| `expression_congr_of_region` | Arbitrary closed typed expression; fixed environment, caller, parties, typed arguments and time; input states agree on a region containing every successfully resolved syntactic read | Entire `Except EvalFailure Value` equal, including errors and inactive-arm read dependencies |
| `evaluate_congr` | Arbitrary template; fixed non-ledger inputs; agreement at every resolved `requiredStateReads` reference | Entire actual `Template.evaluate` result equal, including complete evaluated effects, supplies, declared footprints and errors |
| `evaluated_targets`, `evaluated_effect_zero_outside` | Actual evaluation equals `ok e`; a region contains all successfully resolved delta targets | Every evaluated delta comes from a syntactic target; aggregate effect vanishes outside the region. No declared-write membership or `writesOK` premise |
| `funds_iff` | Two proof-carrying nonnegative input states; equal balances on a region; effect zero outside it | Global sufficient-funds propositions equivalent, including nonzero foreign balances |
| `execute_congr`, `execute_refusal_iff` | Arbitrary finite identity types; fixed registry, store, context, environment, time and request; agreement on a region; all selected-template reads agree and targets lie in it | Full executor results have the same exact refusal, or successful balances agree on the region and capability stores agree |
| `execute_success_congr` | Same premises and one actual successful execution | Matching successful execution on the other state, region agreement and both capability stores equal the fixed input store |
| `execute_target_frame` | Actual successful execution; selected-template targets contained in a chosen region | Every cell outside that region equals its own input balance |
| `analyzed_dependencies`, `analyzed_outputs` | Actual `analyzeInvocation = ok fp`, registry or selected interface lookup | Required reads and selected snapshot cells lie in analyzed reads; potential targets lie in analyzed writes; writes are also balance dependencies |
| `extractReceipt_congr` | Fixed configuration, boundary, request; selected-template resolved-read agreement | Entire receipt extraction result equal using each execution's own prestate |
| `executeStep_congr`, `executeStep_refusal_iff` | Actual admitted invocation footprint; fixed local index/history/boundary; arbitrary region containing analyzed reads; states agree there and input stores equal | Exact composition failure equal, or region balances, capability store, whole receipt and every selected output equal |
| `executeStep_target_frame` | Analyzed footprint and actual successful adapted invocation | Ledger frames its own input outside analyzed writes; capabilities unchanged |

`ExecutionAgrees` and `StepAgrees` are conclusions proved from the actual executors,
not caller-supplied outcome assumptions. Their success case deliberately does not
equate complete worlds when foreign input balances differ. Adapter snapshot
equality uses membership of each output cell from the selected catalog interface.

## Concrete proof fixtures

`Dependency/Fixtures.lean` reuses the existing eight-cell Boolean transition
reference fixture without editing it. Initial balances are 10 at every cell;
the foreign sibling changes only `(true,true,true)` to 99. A transfer moves 3
between the two `(false,_,false)` cells. The poor sibling has only 1 at its debit
target. Actual authority provisioning uses the existing trusted issuance fixture.

- `malformed_evaluates`, `malformed_targets`, `malformed_effect_outside` and
  `malformed_writes_fail`: the transfer has empty declared writes, actual effects
  of -3/+3 and no effects outside its syntactic targets.
- `funded_malformed_refusal`, `foreign_malformed_refusal`,
  `poor_malformed_refusal`: funded states reach exact `writeFootprint`; the poor
  target refuses earlier with exact `insufficientFunds`. The foreign refusal is
  derived by the generic exact-refusal theorem.
- `foreign_agrees`, `foreign_differs`, `foreign_funds_iff`,
  `target_balance_is_needed`, `foreign_success`: establish real foreign-state
  differences, funding equivalence, the necessary target balance dependency,
  and a valid transfer sibling.
- `accounting_refusal`: explicit mismatched supply reaches exact `accounting`.
- `division_evaluation`, `division_execution`: actual balance-based division by
  zero gives exact evaluation and registered-execution errors.
- `observation_error`: missing environmental observation gives its exact error.
- `inactive_evaluation_congr`: both syntactic conditional arms read state and
  their membership premises discharge the general evaluation theorem.

Closed decision fixtures use `decide +kernel` where needed for kernel reduction,
not `native_decide` or an external computation axiom.

## Check evidence and limits

Fresh targeted build: from `lean/`,
`lake build DefiKernel.Parallel.Dependency.Fixtures`, exit 0, 929 jobs.
Full output: `dependency-build.log`. Lean version:
`4.33.0-rc2`, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`.
Targeted LSP diagnostics also reported zero errors during development.
Existing and new linter warnings remain advisory.

Fresh named axiom disclosure: from `lean/`,
`lake env lean ../review/semantic-kernel/sprint6/dependency-axioms.lean`, exit 0.
All 38 expected names matched the 38 actual disclosures exactly; their transitive
axioms are subsets of `propext`, `Classical.choice`, `Quot.sound`.
Output: `dependency-axioms.log`; structured check record:
`dependency-verification.json`. This focused named audit does not replace the
planned automatic imported theorem and supplemental declaration audit.

The proofs establish dependency/locality and exact refusal preservation for
existing closed syntax and executors. They do not establish serial branch
correspondence, whole-sprint mutation sensitivity, protocol fidelity, environmental
truth, or initialized financial invariants. Those remain separate integration work.
The fixture module must be included in the final verification import closure.
Native Grok/Fable implementation reviews are owned by the parent acceptance task.

## Exact owned source hashes

| Source | SHA-256 |
| --- | --- |
| `lean/DefiKernel/Parallel/Dependency.lean` | `72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245` |
| `lean/DefiKernel/Parallel/Dependency/Adapter.lean` | `10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c` |
| `lean/DefiKernel/Parallel/Dependency/Fixtures.lean` | `14bac7bfdc273c9de0d416e4489f6d16eb9d02e5e01f082ef0aeb194ef17de45` |

```
