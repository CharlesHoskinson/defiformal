## Context

Author draft only. Accepted S9 source `eec499d613688137a341f3556cd80ca461dd2ee9` provides `Metatheory.SeqGroup`, a genuinely recursive `runGroup`, `runGroup_eq_continueRun` and `runGroup_assoc`: all operate on one complete sequential cursor, including administration. M3's finite roster, machine and causal monitor remain proposed in `finite-participant-causal-composition`; S10's region/global-binding API is also pending accepted delivery. Future names below are design notation, not claims that declarations exist.

A read-only graphify query returned historical positive-program algebra nodes, not the current operational kernel. Direct source inspection establishes the useful existing APIs: `Parallel.analyzeBranch`, `Footprint.append`, `Compatible`, `checkCompatibility_ok_iff`, `executeStep_congr`, `executeStep_refusal_iff`, `runBranch`, `mergeWorld`, and `Parallel.observeBranch`. The latter intentionally drops raw intermediate worlds. Existing binary recovery supplies proof templates, not a generic finite/tree theorem.

## Goals / Non-Goals

**Goals:** Execute a participant tree independently; prove full fixed-schedule representation independence; prove separately that compatible complete schedules agree under a precisely reduced observation; retain initialization and causal provenance in transported contracts.

**Non-Goals:** Arbitrary permutation under overlap, tree-local configuration/roster/binding reconstruction, whole-subtree atomic execution, cancellation of peers on refusal, dynamic participants, capability issuance/revocation inside concurrent branches, nested Atomic boundaries, asynchronous histories, identity-universe extension or deployment fidelity. M1 sequential administration remains supported by its existing operator but is not silently added to M4 invocation-only branches.

## Decisions

### D1. Tree shape and canonical admission

Use the same fixed participant type B, complete duplicate-free ordered roster, branches, boundaries, configuration, P/A/D types and instances as accepted M3. A proposed `Tree B` has `empty`, `leaf b`, and `fork left right`. Every roster participant occurs exactly once in a well-formed tree; empty internal nodes are allowed. An empty root is valid only when B has no inhabitants. `checkTree` traverses roster order and returns the first identity whose leaf count differs from one, with expected1/observed count. Counts are computed recursively; there is no noncomputable enumeration.

`admitTree` first calls actual M3 admission (configuration, all complete branches in roster order, schedule counts), and only on its success checks tree multiplicities. Errors are `.base actualM3Failure` or `.tree participant expected observed`. This precedence is intentional: a malformed financial suffix or count mismatch precedes a malformed tree. Changing tree shape cannot change a base diagnostic. Compatibility is not required by shared execution.

The runtime performs no proof-suffix calls. A raw dispatcher is total even on malformed trees: recursive left-first search updates the first matching leaf; absent identity returns the machine unchanged. Admitted runs reject both cases structurally, and all generic simulation claims explicitly require the machine's shape to be well formed. Malformed raw behavior is a documented fallback, not evidence that a duplicate tree is admitted.

### D2. Recursive execution and tree-shaped storage

`LocalTree` stores the tree constructors and a full M3 local state at each named leaf. `TreeMachine` stores one complete world, this local tree, and the actual global attempt list. Internal nodes have no private world, store, history, failure or configuration. `startTree tree initial` recursively creates empty local states while retaining the entire initial world/store.

`advanceTree` routes a stable participant token recursively, without flattening the tree or delegating execution to the flat M3 dispatcher. At the selected leaf it applies M3's precise branch rule and calls actual `Composition.executeStep` exactly once when active/nonexhausted. Boundary position is the own successful nextIndex; branch selection uses consumed. Success updates world, event, output, nextIndex, consumed and actual attempt. Refusal preserves the exact world/store, successful events/history/nextIndex, retains the first located failure and appends the actual error attempt. Failed/exhausted tokens increment only selected consumed. The recursive return reconstructs only the path to that leaf and preserves every peer local exactly. A child failure never stops another child.

`continueTree` folds tokens from an arbitrary tree machine; `runTreePrefix` starts empty locals without admission; `runTree` performs `admitTree` and retains the submitted stable-name schedule in either constructor. Admission refusal returns the full entry world and no machine/attempts. No restart occurs at a fork, chunk boundary or tree conversion.

### D3. Route schedules and their flattening

The semantic schedule is `List B`. For an explicit tree-local representation, a path is a list of left/right directions. `decodePaths tree paths` recursively resolves each path to exactly a leaf, in list order; stopping at a fork/empty node, walking beyond a leaf or entering an empty node gives `.invalidPath tokenIndex fullPath`. It does not execute or inspect financial outcomes. Every submitted path is validated, including a suffix whose eventual branch would already have failed.

For a well-formed tree, `encodePaths tree schedule` finds each identity's unique leaf path. Prove decode-after-encode returns exactly the original schedule, preserving multiplicity/order, and decoding concatenation obeys first-error positions with the right suffix offset. Re-encode by stable identity after regrouping; copying old paths unchanged is not an equivalence transformation. `runTreePaths` decodes first, then calls `runTree`; an invalid path therefore precedes base/tree admission in this separate wrapper. Raw paths and path errors remain diagnostic data and are not erased by a claim of wrapper-result equality. The equivalence theorem concerns successful decoding to the same name schedule.

### D4. Full simulation and fixed-schedule regrouping

`flattenMachine roster tm` is a specification/observation conversion: copy world/store/attempts and map each identity to its unique local state. Missing raw lookups have an explicit empty-local default, irrelevant under well-formedness. It is never the production dispatch path. Define `Rep treeMachine flatMachine` by exact full world equality, pointwise complete local equality (including consumed), and exact global attempt equality. Prove shape preservation, start simulation, single-token simulation in both directions for related machines, then arbitrary-entry continuation and admitted-result correspondence. These proofs carry actual successful/error execution equations and do not premise the desired run equality.

Define full observation explicitly: all ledger cells and complete capability store; each identity's consumed, nextIndex, exact located failure, ordered output snapshots and all event fields including raw pre/post worlds and evaluated receipts; every global attempt's identity/index/invocation/pre-world and complete outcome. The executable finite comparator has true iff `Rep`, with standard extensionality/proof irrelevance. Representation equality is not raw structural equality of differently shaped trees.

For well-formed T/T' with identical fixed static parameters and the same decoded schedule, related arbitrary entry machines produce identical full observations. Genesis specialization uses the same supplied world/store and empty locals. Derive `(T1 fork T2) fork T3` versus `T1 fork (T2 fork T3)` plus empty-node units, where the whole trees are well formed. Shared writes are allowed because tokens are not reordered. This is distinct from accepted S9 one-cursor sequential associativity and M3 schedule-chunk associativity.

### D5. Pairwise compatibility and independent reference execution

Use actual admitted per-branch footprints, including output cells and all full-suffix reads/writes. Define pairwise compatibility by `Parallel.Compatible fp_i fp_j` for all distinct roster identities. An executable check visits roster-ordered unordered pairs and reuses `checkCompatibility`, retaining both identities, exact conflict kind and first offending cell. Shared reads are allowed; write/write and either write/read direction are excluded. The disjoint reference's admission is base admission, tree multiplicities, then pairwise conflicts. No compatibility test is inserted into ordinary `runTree`.

For any subtree, footprint union is `Footprint.append` over its leaves. Prove membership/partition laws and that pairwise compatibility implies compatible footprint unions for disjoint subtrees. Lists need not be equal under changed leaf order; the relevant theorem states membership-set agreement and deterministic conflict witnesses only for the unchanged global roster check.

Define a separate flat isolated reference: run every actual `Parallel.runBranch` from the same initial world with its own boundary/history; merge by selecting the unique writing owner's final balance, or the initial balance if no owner. Preserve initial capabilities exactly. Define an independent recursive isolated tree runner: leaves call actual runBranch from that same initial world; forks merge child results using their footprint unions and the same initial world. Never sum two complete balance states or restart a child from its sibling's resulting world. This reference is not defined as the M3 or shared tree result.

Prove flat-reference/tree-reference correspondence, merge independence of tree grouping, fixed store and outside-write frame. Prefix simulation for shared execution tracks each participant's isolated execution on its consumed branch prefix, own history/failure and read-region agreement. Use actual dependency/refusal congruence plus analyzed frames to advance selected streams; failed prefixes stay failed. Complete counts then imply the full isolated result, without requiring all financial steps to succeed. Initialization is the same complete world, empty local cursors and fixed store; arbitrary populated-entry schedule independence is not claimed without new independent premises.

### D6. Canonical equality and its limits

Canonical executed observation contains final full world/store and, in global roster order, each participant's consumed and `Parallel.BranchObservation` (event index/step/evaluated receipt/output list, complete output history, nextIndex and exact located failure). It deliberately excludes raw intermediate event worlds, global attempt order, tree shape and the particular complete schedule. Its comparator must be true iff equality of exactly this projection. Counts complete make consumed equal branch lengths even for refused streams. Wrong receipts, failure reasons, locations, histories or stores remain distinguishable.

From actual base admission, valid trees, pairwise analyzed compatibility and complete schedules s/t, prove both canonical results equal the independently executed reference and hence each other. Prove the final balances and every local refusal/receipt explicitly, not a success-only theorem. Do not claim full observations or arbitrary causal-monitor states equal across different schedules. Two withdrawals7/6 competing for USD10 refute unrestricted schedule independence: final balances3/4, different winner/refusal. A valid shared tree still gives exact equality across shapes for each one of those fixed schedules.

### D7. Initialized contracts and fixed-parameter monitoring

Transport accepted M3 actual-prefix reachability, local order and finite interference through `Rep`. To claim M2 totals/global bindings, retain the same complete global binding set, initialize the predicate at entry and discharge the actual accepted local-effect/support and peer-stability obligations. Compatibility alone does not imply an arbitrary equality binding. Do not rebuild edges at a binary cut, forget cross-subtree edges or infer invariants from structural admission.

For causal execution, wrap one actual `advanceTree` and apply the same M3 update to pre/post machines converted by `flattenMachine` and the exact appended attempt (none on skip). This wrapper never controls finances. Prove actual-input correspondence, erasure and equal monitors for related starts, the same update, same initial monitor/static parameters and fixed token prefix. The monitor may depend on constants closed over by the callback; no unconditional information-flow claim follows from its type. Different schedule orders generally yield different monitors, even under disjointness; only an explicitly permutation-invariant observer would permit a stronger later theorem.

### D8. Independent fixtures and proof/runtime separation

The twenty fixtures in `author-draft/fixtures.json` include a three-stream/two-invocation disjoint family with all90 complete schedules, distinct local snapshots, a financial-refusal sibling, several tree shapes, malformed trees/paths, absolute-boundary and failed-suffix controls, global bindings, synthetic comparator pairs and populated arbitrary entries. Full expected machines are built from literal initial states, grants, requests, independently evaluated receipts and chronological expected world updates. Candidate flat/tree/isolated runners cannot manufacture their own expected value. Cross-runner comparison is supplementary evidence.

Proposed runtime modules: `Nary/Tree/Shape`, `Paths`, `Execution`, `Observation`, `DisjointRuntime`, `MonitorRuntime`, `Examples`, `Tests`, `Audit`. Proof modules: `Simulation`, `Compatibility`, `Recovery`, `Contracts`, `Fixtures`, `Verify`. All shared executable/proposition definitions precede `-- BEGIN PROOFS`; runtime roots must not import proof-only fixture helpers. No existing source behavior changes. Exact predecessor API/runner mappings are mandatory before official freeze.

Eighteen mutations in `planned-mutations.json` target independently observable runtime behavior. Compile the actual proof-stripped runtime closure; a mutation earns detection only when its intended semantic comparison is false while its protected positive controls still pass. Compiler/type errors, timeouts, unavailable modules, malformed/empty output and cancelled runs are blocked execution, not detection. Runner timeout600s and harness timeout1500s are explicit; record actual duration. Carry all accepted predecessor CLI controls using a literal namespace/root/proof-regex/error-text/fixture/command mapping. The current established S9 count65 is historical; the eventual accepted M3 control count/bytes must replace it before freeze, with any added controls separately justified.

## Risks / Trade-offs

- A tree wrapper can secretly flatten and delegate → inspect runtime routing, prove actual one-step simulation and mutate leaf-path updates separately.
- A disjoint proof can assume its conclusion → independently execute branches and use analyzed dependency frames/refusal congruence at each prefix; no whole-run equality premise.
- Projection can hide the fault being claimed → freeze full and canonical field lists and use synthetic one-field pairs alongside actual financial fixtures.
- Group-local admission can reorder refusals → reuse canonical M3 admission before tree validation and canonical pair ordering for conflicts.
- Missing dependencies can turn notation into an invented API → gate official freeze on accepted S10/M3 delivery, exact source/API/fixture/control refresh and fresh author validation.

## Migration Plan

This change creates planning documents only. After accepted S10/M3 delivery, bind exact accepted revisions/baselines, resolve every proposed symbol and fixture against actual APIs, freeze the full planning bundle and obtain nonauthor GPT-6/native Fable5.1 medium verdicts before implementation. Then implement only the new namespace, perform actual integrated Lean/fixture/mutation/CLI/regression checks, generate full theorem/axiom/source inventories and obtain native Grok/Fable5.1 medium evidence review. Preserve earlier failures, reviews and historical sources. No implementation, native review, acceptance or delivery is claimed by this draft.
