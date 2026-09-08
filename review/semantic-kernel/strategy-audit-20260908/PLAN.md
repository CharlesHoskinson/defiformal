# Reusable DeFi verification platform — refined plan v2

> Five independent GPT-6 reviews, followed by a second critique round of PLAN-v1, inform this strategic plan. It does not accept pending implementation candidates. Future implementation remains native Grok 4.6 with independent GPT-6 checks, without Foreman.

**Goal:** A broadly reusable verification platform and financial libraries, demonstrated through explicit semantics, reusable proofs, implementation adapters and reproducible evidence.
**Architecture:** Keep the delivered Lean kernel. Separate financial libraries and contracts, source/runtime adapters, a supported serialized checker, and source/evaluation evidence. Each layer has its own claim boundary; no layer's success silently certifies another.
**Decision:** Continue the architecture, change the spending sequence. The bounded audit found no delivered theorem defect requiring a restart. It did find source-fidelity, oracle, citation and status defects that must constrain the next increment. This is a supported strategic decision, not a complete proof audit or a guarantee of eventual scalability.
**Current execution:** Broad feature dispatch is held for this strategy decision. This audit performed preservation, graphing, state reconciliation and a small reversible cleanup; it did not launch another feature sprint.

## What success means

The platform must let an external developer instantiate an existing financial library and executor interface, state a meaningful financial predicate, bind a pinned implementation, run relevant comparisons and inspect exact proved, measured and assumed obligations. The second contrasting example must reuse substantive results, not merely the same JSON envelope.

Two examples validate one increment. They do not complete the full program or establish generalization across DeFi. All remaining roadmap families stay open with explicit return conditions below.

## 0. Completed audit and recovery

- [x] Run five independent reviews: soundness, agenda/resources, cleanup, fidelity, delivery/testing.
- [x] Critique draft v1 and incorporate the second-round corrections; preserve the draft and ten reports.
- [x] Rebuild the code map: 638 files, 568 directed edges; separate delivered/working/candidate layers. Lean edges are literal imports, not theorem or call analysis. Disconnected files are not dead-code proof.
- [x] Preserve the five terminal candidates, including the cancelled Claims partial, with raw native identity, exact source archives and terminal receipts.
- [x] Replace conflicting current-state copies with one [CURRENT.json](CURRENT.json), 17 lane rows and 11 thin worktree routers. Preserve original workstates by hash.
- [x] Remove five confirmed incidental files, 154,727 bytes, with exact recoverable originals; no source files, proofs or candidate worktrees removed.

Graph artifacts, all previous failure evidence and the existing release remain distinct from this audit's conclusions.

## 1. Close one coherent acceptance item

**Default first substantive review:** M4 recovery r2, tasks 4.1–4.6, already frozen at archive `9b700c0f6ff4a49d008cb3e5eb6a6d9a6b10ad9366b8a63f0c2619eb205c7741`. Review the actual distinct-participant compatibility, nonempty-write success/refusal instance, simulation, canonical equality and grouping. Inspect full statements and axioms; use the candidate's actual dependency closure and private review cache.

Relevant source is in `/home/charl/defiformal-wt-sprint12-grok-gpt6-20260908/lean/DefiKernel/Nary/Tree/`. After preparing exact dependencies in a review checkout, run from `lean/`:

```bash
lake env lean DefiKernel/Nary/Tree/Compatibility.lean
lake env lean DefiKernel/Nary/Tree/Recovery.lean
lake env lean DefiKernel/Nary/Tree/RecoveryChecks.lean
```

These commands are checks within the gate, not a substitute for the theorem/observation review. A missing dependency artifact is setup failure, not mathematical refutation. Stop on a missing assigned theorem, circular/overstrong premise, vacuous compatibility witness, absent actual refusal behavior, changed unreviewed dependencies or empty check inventory. Give Grok a bounded repair against the concrete finding.

The reporting-gate repair or capability foundation may close first if independently ready. Claims remains a preserved partial until its proofs are inspected; do not restart it indiscriminately. Park other candidates with exact next actions. **Neither the entire review backlog nor full M4 completion is a prerequisite to independent source-readiness work.** Deliver only a coherent accepted scope; retain all later whole-package obligations.

## 2. Freeze the minimum reusable contracts

Use actual delivered APIs and accepted library arithmetic. Define only the contracts needed by the next two cases:

- Kernel/operator version and typed operation boundary: dimensions, roles, effects, supply, access and exact refusal order.
- Library amount/rounding/error contract, with machine-width and fallback semantics explicit.
- Adapter input/pre-state and output/post-state relation. Include only observations appropriate to the operation; a pure function does not need invented ledger history.
- Common evidence/result interface, with protocol-specific adapters and local proofs permitted.
- Separate obligation classes: model proof, bounded source execution, representation correspondence, source refinement, authenticity/environment assumptions.

If serialized certificates are delivered, first accept the existing repaired Typed/sequential grammar and result contract; implement the checker by invoking actual supported Lean semantics. A caller's claimed judgment, source hash or theorem name is not proof. A broader certificate schema and certificate implementation are **not prerequisites** to the library experiment.

## 3. First source-bound library case

**Selected first target:** the pinned Uniswap V3 token0 next-price operation, including denominator-sum overflow. Existing upstream pin is v3-core `e3589b192d0be27e100cd0daaf6c97204fdb1899`; verify its exact closure/settings before execution.

First repair and review the concrete planning/oracle defects: unbounded denominator addition misses Solidity's wrapped-sum fallback; the M09 direction mutant changes its purported unaffected F28 control. The independent Python transcription is a diagnostic third implementation, not execution of Solidity.

Execute the pinned Solidity source under pinned compiler settings and a declared EVM harness, or justify another actual source-semantics reference. Freeze source/compiler/wrapper/model identities and the observation relation. Predeclare nonempty partitions covering ordinary inputs, multiplication overflow, denominator-sum overflow, rounding boundaries, add/remove paths, zero input and applicable refusals. Distinguish standalone function admissibility from reachability in the full pool. Record the bounded comparison denominator before scoring.

**Exit:** relevant Lean library theorem and axiom evidence; zero unexplained source/model differences over the declared boundary matrix and deterministic bounded set; a characteristic actual production mutation reaches the intended branch and changes its designated observation while an unaffected sibling remains valid. Compilation failure, timeout or an in-memory Python-only mutation earns no production mutation credit. Full tick traversal and deployed pool security remain open.

If used as kernel-platform evidence, add and verify the library-to-Typed operation bridge; pure arithmetic success alone establishes arithmetic-library scope.

## 4. Contrasting reuse case

**Preferred second target:** a narrow stateful vault deposit/withdrawal with asset/share rounding and transfer refusal. This is a selection recommendation: a reviewed executable vault pin has **not** been established by this audit. Verify or acquire its exact source closure from development material before implementation. Do not substitute a second nearby AMM formula merely because it is available.

Freeze a substantive financial predicate, one ordinary successful conversion, one reachable refusal and relevant pre/post balances or supply. State supported token behavior, callbacks and environment assumptions before scoring; do not exclude a behavior after discovering a mismatch merely to keep a pass.

Credited source excerpts must resolve through exact span → raw/derived artifact → extraction/capture → original response. Challenge pages and failed/404 responses remain retained with zero semantic support. Repair the confirmed corpus violations when those inputs are used; completing all 169 work items is not a global experiment prerequisite.

**Substantive reuse gate:** both cases use the delivered kernel/API and common observation/evidence interface, one harness engine, and shared amount/rounding/error contracts where applicable. Name a genuinely reused library lemma/financial contract and an executor/composition theorem. Protocol-specific adapters, fixtures and local proofs are expected. Record new definitions, new assumptions, interface changes and effort for case two.

At least one meaningful two-operation preservation instantiation is required when claiming composition integration. If the selected operations do not financially compose, report the narrower interface/library reuse result rather than inventing a workflow. A new global induction, cloned dispatcher or case-specific checker exemption blocks the unchanged-interface reuse claim; revise that boundary before adding a third family. New local financial proofs alone do not falsify reuse.

## 5. Publish an honestly scoped platform increment

Use one minimum evidence packet per selected operation:

1. Exact source/model/tool identities and supported input/state/observation relation.
2. Relevant Lean theorem, full premise and axiom evidence.
3. Actual pinned-source/model executions over predeclared nonempty cases, including refusal behavior.
4. Actual characteristic mutations with separately verified unaffected controls.
5. Independent exact-candidate verdict and explicit remaining obligations.

**Keep the two correspondence claims separate.** A delivered certificate representation requires a quantified representation-to-Lean correspondence result for its supported domain. Separately state the pinned-source refinement obligation over related admissible states/inputs and declared results. Prove it against justified source semantics before claiming universal source fidelity. An increment may ship as **model-verified with bounded source differential evidence and source refinement open**; codec correctness cannot close that source obligation. Compiler/runtime correctness, authentication and external truth remain explicit trust boundaries where not proved.

Integrate only accepted path manifests. Bind the composite tree and freshly check changed modules plus affected consumers, including the two examples. Reuse exact-bound unchanged dependency evidence. Record-only edits need integrity checks, not another full Lean build. Publish to `semantic-kernel-pivot`, verify transport/readback and provide a versioned external-user example/API. Do not merge to main or recursively review administrative receipts.

## 6. Expand the platform after measured reuse

| Workstream retained in the program | Return condition |
|---|---|
| Finish M4, then M5/M6 | Complete remaining M4 contracts/monitors/fixtures/gates; M5 official API refresh after delivered M4; M6 after its actual prerequisites. One bounded semantic lane may proceed without displacing ready acceptance. |
| Claims and capability isolation | Select the reusable lifecycle/provenance service; review existing partial/foundation bytes first. No blanket M4/M5/M6 prerequisite. |
| Full concentrated liquidity, Curve, redemption, loss allocation, shared vaults, derivatives and conditional claims | Source/observation contracts ready, meaningful new financial guarantee, demonstrated reuse and checker capacity. |
| Async and cross-domain workflow | A concrete supported workflow establishes required finality/replay/timeout/challenge/compensation semantics and external assumptions. |
| Wider certificates/runtime adapters | Stable supported APIs and actual consumer need; quantified representation correspondence for each supported extension. |
| Full corpus and historical reconciliation | Repair confirmed misleading claims/source bindings; complete remaining adjudication as a separate evidence program. Preserve original negative results and exposed/development status. |
| Untouched evaluation | Freeze relevant kernel/schema/library versions and audit exposure before selecting/scoring cases. The existing75 remain development. |
| Scientific Atlas and publication | Accepted stable results and separately reported schema/behavioral coverage, reuse, new concepts, assumptions and effort. |

The full agenda is retained. Two development cases are a resource decision point, not a claim of universal platform reuse or completed roadmap.

## Resource and stop policy

Initially allow **one substantive author candidate and one independent checker**; cheap source inspection and mechanical delivery need not wait. Increase concurrency only when independent acceptance/delivery keeps pace and interfaces are stable. Do not open work merely because a process slot is free.

One initial review plus a targeted re-review is the default; further rounds need a concrete unresolved finding. Freeze every terminal/cancelled result. One source/model mismatch suspends fidelity credit for the affected scope, not unrelated valid work. A premise that asserts the desired postcondition is not an acceptable refinement discharge. Nonnegative balances and net accounting must not be marketed as solvency, consumable allowances or intermediate-order fidelity.

No calendar or percentage estimate follows from the 47 roadmap boxes, generated theorem counts or author exits. Track independently accepted user-facing guarantees and their remaining assumptions.

## Cleanup boundary

Applied cleanup is in [cleanup-applied.json](evidence/cleanup-applied.json), independently read back in [03-round2.md](reviews/03-round2.md). Preserve dynamically imported scratch code, standalone proof roots, historical models/counterexamples, failed reviews, graph inputs and unique dirty worktrees. Remove obsolete agendas from active routing without deleting their historical bodies. Future source deletion requires exact consumer/root/build/CLI evidence and appropriate validation, not graph isolation or a suggestive filename.

## Review convergence

All five first-round reports support retaining the kernel while changing sequencing. Second-round reports approve with scoped amendments now incorporated: no global backlog barrier; actual source execution; conditional second-case readiness; substantive rather than superficial reuse; local adapters/proofs allowed; codec/source refinement separated; bounded releases permitted with visible limits; exact small cleanup only. See [CONVERGENCE.md](CONVERGENCE.md) for the decision record.
