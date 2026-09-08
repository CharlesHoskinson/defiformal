# P01 independent Lean review — CHANGES_REQUIRED

The generic distinct-participant recovery argument compiles and its inspected premises are sound for the claimed genesis/complete-schedule scope. P01 closeout needs four bounded proof/control additions below. These are missing assigned artifacts, not a mathematical refutation. Do not start the P02 eighteen-mutant, full F01–F20, or ninety-schedule campaign to resolve this review.

## Resolved inputs and identity

- Workflow: Lean4 read-only review, batch; four candidate files plus the exact imported closure. Layer-2 mathlib style findings are advisory (this is a project library, not an upstream mathlib submission). No source repair, commit, push, Foreman, or subagent dispatch occurred.
- Independent checker requested model: `gpt-6-astra`, through the stock Codex agent harness. This session does not expose separate provider-returned model telemetry; none is inferred. Native Grok 4.6 authored the candidate; its report is an input, not acceptance.
- Frozen archive: `9b700c0f6ff4a49d008cb3e5eb6a6d9a6b10ad9366b8a63f0c2619eb205c7741`.
- Worktree: `/home/charl/defiformal-wt-sprint12-grok-gpt6-20260908`; HEAD `a12b7cac05a818cc8d35c2ca440b7170a2807e92`.
- [inputs.json](inputs.json) binds all ten Tree files, 38 unchanged non-Tree dependencies, and three toolchain/Lake configuration files. All 51 bound files and the archive match before and after; HEAD and worktree porcelain are unchanged. [before.json](before.json), [after.json](after.json).
- The six foundation files exactly match the existing independent foundation acceptance, including Simulation and FoundationChecks: [foundation-reuse.json](foundation-reuse.json). Their generic proof evidence is carried; original tasks 2.1–3.5 are not newly closed by this review.
- Contract: strategy PLAN section 1; original operational-tree-regrouping tasks 4.1–4.6, compatible-tree-disjoint-recovery R09–R12 and design D5–D7; current reusable-verification-platform-program tasks 2.1–2.9. Latest user execution authorization supersedes the historical strategy dispatch hold.

## Required bounded fixes

### R1 — Complete the recursive reference's local observation correspondence

**Contract:** original task 4.3 says “prove flat-reference correspondence, grouping/empty units and outside-write frame”; R10/S24 requires that “the reference state/local observation is unchanged.”

`DisjointRuntime.lean:116–130` returns both a world and recursively accumulated local observations. However, `Recovery.lean:628–690` (leaves equality, empty units, association) and `Recovery.lean:740` (flat reference) conclude only `WorldEquivalent ... .1 ... .1`. No candidate theorem states correspondence for `.2`. `isolatedCanonical` at `DisjointRuntime.lean:152` uses the recursive runner's world but constructs its locals separately through flat `isolatedLocals`; the complete recovery theorem therefore does not establish that the recursive local result is correct.

**Minimal repair:** prove the recursive `.2` equals `isolatedLocals ... (Tree.leaves tree)`, derive the left/right empty and association laws for that component, and state roster-normalized local correspondence for a well-formed tree. Combine those with the existing world laws (or provide a full canonical reference theorem). Tree DFS order need not equal roster order: use identity lookup or explicit normalization. No new runtime architecture or full fixture suite is needed.

### R2 — Add one compatible shared/isolated recovery witness that actually refuses

**Contract:** strategy section 1 requires a “nonempty-write success/refusal instance”; current task 2.6 requires the canonical recovery share “with meaningful success/refusal witnesses”; original task 4.2 requires “successful-prefix refusal retention,” and 4.3 requires independently expected balances.

The funded `f06Branch` at `RecoveryChecks.lean:158` does execute USD3 successfully and then refuses USD8 with `insufficientFunds`. Its literal Alice7/Bob3 checks and one-event prefix are meaningful. But this branch is used only by `executeStep`/`isolated`; it is never a branch in a compatible shared tree recovery comparison. The only compatible canonical schedule comparison uses two successful one-step streams (`disjBranches`, lines 189–190). The F20 sentinel check at lines 115–124 tests `mergeOwned` on hand-built worlds, not a recursive/flat reference actually executing funded branches.

**Minimal repair:** one two-participant admitted compatible example with nonempty disjoint writes, a successful-prefix-then-financial-refusal stream, and a successful peer. Check a complete schedule against the independent reference and literal final balances, nonzero unowned sentinel, capability store, consumed counts, retained receipt/output history, and exact located refusal; a second complete order gives a small schedule-independence companion. Explicitly establish successful analysis/compatibility for this actual catalog, without a fallback-to-empty association silently substituting for admission. A kernel instantiation of `complete_schedule_canonicalEq_of_admitIsolated` on this example is a concise way to bind the premises and generic theorem. This is a bounded witness, not the ninety-schedule F05/F06 enumeration.

**Adjudication of the author's admitted limitation:** absence of an `exact` application to the existing all-success `Parallel.Examples` association, by itself, is not a blocker. A quantified checked theorem plus appropriate meaningful computational instances can satisfy P01. The actual remaining gap is that the relevant compatible refusal recovery/reference behavior is not instantiated or exercised together.

### R3 — Supply the assigned concrete F15 proof and literal counterexample

**Contract:** original task 4.6 says “Prove and execute F15 opposite-order competition counterexample”; R12/S28 specifies “vault3 versus4 and different refusals”; design D7 specifies withdrawals7/6 from USD10.

`RecoveryChecks.lean:193–194` instead runs USD3/USD8. Its runtime controls show opposite winners and differing worlds/canonical results, so they do provide a meaningful *companion* counterexample. The four explicit theorems in RecoveryChecks establish catalog validity, completeness and well-formedness only. `competing_writes_not_compatible` proves overlapping footprints cannot be compatible; it does not prove that concrete opposite orders differ. There is no concrete kernel theorem for the assigned F15 execution.

**Minimal repair:** retain the companion and add the two complete 7/6 executions with the independent literal residual balances3/4 and exact opposite refusals. Add a kernel-checked concrete proposition certifying the canonical inequality (or the differing final balances together with the bridge to inequality) and incompatibility. No general unrestricted-independence theorem or full F15 fixture infrastructure is needed.

### R4 — Add the bounded full-versus-canonical observation controls

**Contract:** current task 2.7 expressly retains “full-trace versus canonical distinctions in F19”; R12/S27 says receipt/failure/consumed/output differences are rejected while raw-world/attempt-only differences are accepted.

The runtime inventory contains canonical reflexivity, failure difference, world difference, and two successful schedule comparisons. It contains no receipt-only, consumed-only or output-only canonical negative; no raw-event-world-only or global-attempt-only positive paired with a rejecting `fullMachineEq`. FoundationChecks has full reflexivity and a consumed extraction, not these discriminator pairs. The generic comparator equivalence is valid, but these specific bounded P01 controls are absent.

**Minimal repair:** add a small set of one-field pairs for retained receipt, consumed, output and failure, and two omitted-field pairs for raw event worlds and global attempts. Assert both relevant comparator outcomes for the omitted-field cases. Reuse the already accepted runtime comparators. This is the required distinction, not the complete F19/full F01–F20 campaign.

## Statement and premise assessment

`PairwiseCompatible assoc` quantifies `p ∈ assoc`, `q ∈ assoc`, and **`p.1 ≠ q.1`** before `Compatible p.2 q.2`. `checkPairwise_ok_iff` requires `(assoc.map Prod.fst).Nodup`. The checker visits each earlier/later pair in list order; `checkPair_error_iff` equates its identity/kind/cell result with the existing exact three-stage conflict checker. There is no self-pair compatibility premise. The positive two-entry `assocOK` has nonempty writes and its runtime check passes. Shared-read positive and WW/WR/RW negatives all execute. Actual `Parallel.analyzeInvocation` includes target reads, writes and output-port cells in reads; `analyzeInvocation_coverage` and branch membership/frame results carry those dependencies into the recovery argument. The union proof handles all three conflict directions.

`runIsolatedLeaf` calls actual `Parallel.runBranch` from the initial world. Recursive forks run both children from that same initial world and select the left/right write owner, otherwise the initial balance; they preserve the initial capability store. The flat reference separately runs branches in an owner-selecting fold. No reference is defined by the shared dispatcher or by summing full worlds. The frame and world grouping proofs use admission and distinct-owner compatibility; their local-output limit is R1 above.

`Simulates` is read-region `CursorAgrees` between a shared local cursor and an independently executed consumed prefix. `advance_own_agrees` handles exhausted, failed, and active states; the active case invokes actual admitted `cursor_advance_congr`. `advance_simulates` preserves peers using actual execution frames and no write/read overlap. `continue_simulates` legitimately takes the previous simulation as an induction hypothesis, with `Nary.Reachable`; `runPrefix_simulates` discharges both from genesis. This is not an assumed desired full-run equality. There is no all-success or empty-write hypothesis.

The exact principal statement is `complete_schedule_canonicalEq cfg boundaries initial branches roster assoc tree schedule hwf hv ha hc hC`. Its premises are:

1. `WellFormed roster tree`;
2. `validateCatalog cfg.registry cfg.catalog = true`;
3. `analyzeAll cfg boundaries branches roster.order = .ok assoc`;
4. distinct-participant `PairwiseCompatible assoc`;
5. `Nary.Complete branches schedule`.

`Roster` itself supplies no duplicates and completeness of all `B` identities. The conclusion compares `canonicalOf roster (runTreePrefix ...)` with the independently executed `isolatedCanonical`. `complete_schedule_independence` derives equality of two complete schedules through that same reference. `complete_schedule_canonicalEq_of_admitIsolated` derives the entire premise bundle from successful actual isolated admission. Nothing assumes the conclusion, runtime success of every branch, or equality of raw traces. Complete counts include tokens consumed after failure, while actual retained events/failure remain in the canonical local observation.

`canonicalEq_iff` is exactly final `WorldEquivalent` (all balances and capability store) plus equality of the entire ordered local list. Each local retains consumed, event index/step/receipt/outputs, output history, nextIndex and exact located failure. It intentionally omits raw intermediate worlds and global attempts. Schedule independence starts from identical genesis world with empty locals and fixed store; arbitrary populated-entry independence, monitor equality, source refinement and deployed-system fidelity are not established.

## Verification and counts

Every command ran from the private worktree's `lean/` directory; `.lake` is a real private directory assigned exclusively to this review. [commands.json](commands.json) contains argv, cwd, exits and timings; [logs/](logs/) contains complete stdout/stderr.

| Check | Result |
|---|---|
| `lake env lean --version`; `lake --version` | Both exit0: Lean4.33.0-rc2 (`d8b18978322de05a8f3dba51ef03cf5461676c17`), Lake5.0.0-src+d8b1897 |
| `lake build DefiKernel.Nary.Tree.Compatibility DefiKernel.Nary.Tree.Recovery DefiKernel.Nary.Tree.RecoveryChecks` | Exit0, 971 dependency jobs, principally replay of exact source-bound artifacts |
| `lake env lean DefiKernel/Nary/Tree/DisjointRuntime.lean` | Exit0 |
| `lake env lean DefiKernel/Nary/Tree/Compatibility.lean` | Exit0 |
| `lake env lean DefiKernel/Nary/Tree/Recovery.lean` | Exit0 |
| `lake env lean DefiKernel/Nary/Tree/RecoveryChecks.lean` | Exit0; 36 rows, 36 unique names, 36 true, 0 false |
| Reviewer imported declaration/axiom inventory | Final exit0; 48/48 project modules, zero omitted/extra project modules |

The first inventory-only scratch attempt failed because the reviewer used an unsupported pretty-printer option and an untyped mutable counter. Its source and full exit1 logs are retained as `Inventory-attempt1.lean` and `logs/inventory.*`; this was a reviewer setup failure and receives no semantic refutation/detection credit. The corrected compact inventory and then the full proof-term-in-types inventory both exited0. No candidate source was edited.

The final [inventory.json](inventory.json) gives full elaborated types with explicit parameters/universes and transitive axioms for **5,702** declarations: **2,372** theorem constants, **2,833** definitions, 123 inductives, 251 constructors and 123 recursors. All 48 expected project modules are represented. There are zero forbidden axiom rows, zero custom axiom declarations and zero `sorry`/`native_decide` tokens across the 48 source files. The axiom union is exactly `propext`, `Classical.choice`, `Quot.sound`. No statement is elided. The inventory discovers private/compiler/generated declarations through Lean module provenance; source-explicit classification is separately identified by source-name matching.

The four P01 candidate modules contain 430 elaborated constants, including 226 theorem constants: 96 source-explicit theorem declarations (92 reusable declarations and four concrete premise witnesses), with the remainder generated/auxiliary. There are 41 private names in these four modules. These are declaration counts, not counts of independent financial guarantees. [inventory-summary.json](inventory-summary.json) and [p01-named-theorem-statements.txt](p01-named-theorem-statements.txt) provide the breakdown and directly reviewable main statements.

The 36 runtime controls are bounded development examples. Several are empty/unit controls, but the suite also executes funded success, actual insufficient-funds refusal and opposite-order competition; it is neither an empty suite nor uniformly vacuous. All labels and results are in [runtime-summary.json](runtime-summary.json). No mutation detection, ninety-schedule enumeration, full M4 acceptance, full-program completion or untouched evaluation credit is claimed.

## Advisory library/style notes

The proof structure is explicit and the dependency/refusal reuse is appropriate. The long Recovery module combines simulation, reference world laws and comparator laws; later separation could improve navigation but is not required for P01. Linter warnings about flexible simp, unused variables and broad linter suppression do not weaken the checked statements. The mutation-specific `mergeNonneg` comment and fallback tactic are historical harness preparation, not independent runtime evidence. No proof golfing or library redesign is required by this review.

The next action is native Grok's bounded repair of R1–R4, then one exact-candidate targeted GPT-6 rereview. Preserve this frozen r2 review and all later P02 obligations.
