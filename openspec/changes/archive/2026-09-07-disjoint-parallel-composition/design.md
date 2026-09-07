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
