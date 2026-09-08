# Independent review of program planning repair r1

**Verdict: CHANGES_REQUIRED.** The revision implements the main P16/P21 split, the complete P17 reuse experiment, and the P09-manifest/P10-collector/final-closeout structure. All six adjudicated consistency-table repairs are present. Three narrower original-task mapping defects remain. They need a bounded follow-up before this candidate is accepted as the complete execution contract.

This is an independent planning gate. It does not accept an implementation, prove a theorem, accept the original liquidity/certificate candidates, complete a sprint, or complete the program. It does not prevent independently authorized work on an existing accepted scope.

## Identity and scope

- Reviewer: independent nonauthor stock-harness agent `/root/program_repair_review`, requested model **gpt-6-astra**. No separate provider telemetry or independently returned native model identity is available or asserted.
- Author: native Grok, requested `grok-4.6`; the supplied frozen manifest records returned `grok-4.6-build`, 34 turns, `end_turn`, process exit 0. That completion is author evidence, not acceptance.
- Candidate root: `/home/charl/defiformal-wt-program-repair-grok-gpt6-20260908/openspec/changes/reusable-verification-platform-program`.
- Candidate archive: `repair-candidate-r1.tar.gz`, SHA-256 **f4162b193aa0ad2b0884c93652cc6bb4507f443ee96318d96c687199f13f35a2**. All 15 archive members and live candidate files match the supplied manifest. Per-file hashes, manifest hash, exact worktree HEAD and tool versions are recorded in [checks.json](checks.json).
- Baseline: `review/semantic-kernel/full-program-spec-review-20260908/frozen-program`. Contract: [prior adjudication](../../full-program-spec-review-20260908/ADJUDICATION.md). The author report was read as a claim, not a verdict. The root's structural report was inspected with its stated limits.
- Review method: normalized JSON diffs, direct comparison of revised prose/maps with the original task contracts, and fresh bounded checks. [normalized.diff](normalized.diff) removes JSON key/formatting noise. [semantic-source-evidence.json](semantic-source-evidence.json) binds the exact source excerpts supporting the findings.
- Repository AGENTS, approved migration design/progress, defi-footguns and gate register were consulted. Graphify navigation returned historical positive-program nodes, which were not relevant evidence for this revised package; direct source inspection supplied the review. No graph extraction, subagent dispatch, Foreman, web access, held assessment payload access, Lean build, Solidity execution or mutation execution occurred.
- Writes are confined to this review directory. No candidate, original package, primary checker, kernel source, or other active worktree/cache was edited.

## Required changes

### PR1 — Liquidity original 1.2 has no review outcome in either contribution

**Priority: medium.** Candidate `legacy-task-disposition.json:3144` and `:3148` split liquidity task 1.2 into two scopes that only say to treat the unaccepted freeze as input. The first explicitly says that this program revision is not original 1.2 acceptance. Neither contribution requires an independent planning verdict on an exact repaired slice or on the original full package. Candidate `tasks.md:181` nevertheless includes 1.2 among the mixed original IDs to close after the contributions exist.

The original liquidity `tasks.md:22` requires independent GPT-6 review of the identical planning freeze, exact verdict/model/input bindings and an unaccepted gate until that review. Treating a document as an input does not deliver that outcome. The general prohibition on self-acceptance remains correct; the defect is that the new contribution/closure contract does not allocate the actual planning-review work it preserves by ID.

**Bounded repair:** name the exact independently reviewed planning outcome for the P16 token0 slice and for the P21 residual slice, and require both applicable accepted outcomes before original 1.2 closes. Alternatively, explicitly retain original 1.2 as a separately open whole-package review obligation with an owner and closer. Do not make the full 45-fixture implementation campaign a P16 prerequisite. This review itself does not accept the original unaccepted library plan.

### PR2 — Original 6.3 still mixes P16 diagnostic repair with P21 SwapMath mutation execution

**Priority: medium.** Candidate `legacy-task-disposition.json:3370` assigns P16 “Token0 overflow-fallback and repaired M09/F28 mutants with unaffected sibling.” The P21 contribution at `:3374` requires M01–M12 with “global positives F01/F10/F28/F40” without the M09 exception. These are new execution-contribution scopes.

The original `planned-mutations.json` identifies M09 as a mutation of `SwapMath.computeSwapStep`, flipping `zeroForOne`; the original F28 record is also `computeSwapStep`, with `amountIn=2`. SwapMath implementation belongs to P21 in the repaired package. Candidate task 17.3 correctly asks P16 to repair the affected-control plan, while task 22.5 places the actual full M01–M12 campaign on P21. The contribution text therefore still overloads the narrow early slice if read as an actual M09 run, and its P21 half repeats the very F28 control requirement that task 17.3 must remove for M09.

The global normative rule already forbids scoring an affected control; this is not a claim that the package permits false mutation credit. It is a concrete conflict between the new per-task scopes and the intended executable sequence.

**Bounded repair:** distinguish P16's diagnostic/control-plan correction from actual compiled execution. P16 owns its token0 production mutants and the M09/F28 plan correction; P21 owns the actual repaired M09 execution with SwapMath and the rest of M01–M12. In the P21 contribution, explicitly apply the repaired per-mutant unaffected-control set, excluding/replacing F28 for M09. Preserve the failed original plan as evidence. No extra mutation campaign is requested.

### PR3 — Corpus original 5.5 remains unsplit although it includes P10's separate challenge

**Priority: medium.** Candidate `legacy-task-disposition.json:1589` retains original corpus task 5.5 solely on P09 and describes only complete 29-facet dispositions. Candidate task 10.2 likewise describes the 29 disagreements. Original corpus `tasks.md:32` requires adjudication records for both **every disputed label and the separate challenge**, with the same reviewed rule version and exact review/rationale/applicability/interpretation evidence. P10 owns the source/challenge decision at original 5.4, but neither its task list nor the revised contribution map owns the challenge portion of original 5.5.

The final original 7.x/8.x join does correctly validate both streams, so this is not a missing final archive gate. It is still an incorrect earlier whole-task closer: completing P09's 29-facet work cannot by itself complete all of original 5.5 while P10's challenge adjudication remains open. The P09 original-6.1 note at `legacy-task-disposition.json:1598` also says P09 successful exit does not wait for P10. Meanwhile P09 `exit` and `successful_exit` at `sprint-index.json:626` and `:644` retain the broad “remaining 169-work dispositions” wording. The original corpus design defines those 169 items as 75 identities + 29 facet records + the separate challenge + 62 citation occurrences + two attachment pointers, so that wording includes work allocated to P10.

**Bounded repair:** split original 5.5 into the P09 facet-disposition contribution and the P10 challenge-disposition contribution, with whole-task closure after both, or otherwise make that consumed challenge artifact and whole-task closer explicit without waiting on all of P10. Narrow P09 successful-exit wording to its actual subset; leave the complete 169-item bookkeeping claim at the final joined acceptance. Preserve the early P09 6.1 → P10 2.4 route and the final 7.x/8.x join. Required source/tooling/scenario work must remain open until done; reviewed unresolved facts may remain unresolved. No global corpus prerequisite for P16 is requested.

## Repairs verified in this candidate

| Obligation | Independent assessment |
| --- | --- |
| Liquidity ownership by actual outcome | TickMath 3.1–3.3, SwapMath 4.2, bitmap/liquidity/factory 5.1–5.3, residual 7.4, full 45 fixtures and M01–M12 are explicitly P21. FullMath 2.2–2.3 and the arithmetic cache remain P16 substrate. Original 4.1 explicitly splits token0 from **amount0/amount1 deltas, token1 next-price and remaining next-price wrappers**. Wider original 4.3 branch proofs are present in its P21 contribution. All 13 mixed liquidity rows have named contributions and `all_contributions` closure. PR1/PR2 identify the two defective contribution scopes. |
| P17 complete reuse test | Tasks 18.4–18.7, the index, matrix and normative specs require one common engine actually executing both cases, a named shared financial lemma/contract, a named shared executor result, token0-to-kernel bridge, both adapters on that result and measured case-two definitions/assumptions/interfaces/effort. A wrapper around separate engines and a vault-only theorem do not count. Composition integration requires a meaningful two-operation preservation instance only when claimed. Noncomposing interface/library reuse remains legitimate. No P30 prerequisite was added. |
| Stronger resource predicate | `P21`–`P29` retain resource ID `P17`. Schema field documentation explicitly resolves that ID through P17's `platform_reuse_predicate`, which equals `P17.platform_reuse`; the detailed predicate includes all six obligations. Arithmetic reuse has `opens_resource_gate=false`. Resolution is explicit, although these planning JSON files are not a newly implemented scheduling engine. |
| Corpus collection and final acceptance | Original 2.4 is executable in task 11.4 with the original 3-target/2-attempt/5-redirect/30-second bounds, local fixture controls, manifest membership and no retrospective collector claims. `P09.6.1` resolves to the named original-6.1 sub-delivery. All seven original 7.1–8.3 rows split P09 input contributions from P10 whole-package gate execution. P09 excludes those IDs from successful exit; P10 joins P09 accepted outcomes and its source/collector work. No hard cycle or P16 corpus barrier exists. PR3 is the remaining earlier task-closure defect. |
| R18 | Coverage and P20 index now include compatibility/library-instantiation contributions. Actual executable compatibility and real Lean theorem instantiation remain required; P19 alone does not close R18. |
| Adapter IDs | All eight readiness/implementation references resolve to actual tasks. Implementation IDs are 32.5–32.8 with matching adapter names. PCT retains P20 dependence. |
| Coverage totals | Independently counted **55 requirements and 100 scenarios** across six capabilities; every coverage-table row matches. Baseline had **169**, not 164, current checklist items; revision has 179. The author's “was 164” statement is a report arithmetic error, not a missing-task finding. |
| Curve classification | Matrix conditional property now follows source-selected revert or successful residual; pin-entry freezing remains required. No present Curve implementation behavior was inferred. |
| Solidity locators | Directly read local pinned files: SwapMath 87–89 contains the exact-output cap condition/assignment; UniswapV3Pool 608–613 contains the SPL check. This validates the locators, not execution fidelity. |
| P12 class | Index uses `mixed_behavior`; tasks/specs explicitly retain original 3.1–3.7 Lean proof work and the data/CLI obligations. |
| Preserved legacy IDs | All **339** package/task/path/historical-checkbox tuples match the frozen baseline and all **11** actual original task sources. Preserving IDs alone is not semantic completion, as PR1–PR3 demonstrate. |
| Other changed split records | M4 foundation/comparator contributions preserve P01/P02's existing split. Claims contributions preserve the bounded P06 choice with all remainder on P07. No new demand to complete every Claims obligation in P06 was found. |
| Advisory normalization | Blocked attempts remain separate from successful exit. P36's conditional accepted-schema artifact/hash binding adds no P33 hard edge. Atlas 7.3 names the superseding current-layout budget/conformance scope and preserves the authorized Flat/3D layouts. No earlier rejected automatic-bypass or current unpinned-family source defect was reasserted. |

## Fresh verification and limits

Command: `python3 /home/charl/defiformal/review/semantic-kernel/program-execution-20260908/plan-review/check_candidate.py` — exit 0, **35 checks passed, 0 failed**. The script and [checks.json](checks.json) contain exact inputs and denominators. It checked archive/live/frozen hash equality, 37 unique sprints, hard-edge/topological consistency, 179 unique unchecked tasks, heading-derived counts, 339 original IDs/marks/paths against both baseline and original sources, 34 split rows, resource-predicate resolution, the named corpus manifest/join structure, adapter references, R18/P12 fields and direct local source locators.

The script freshly ran `openspec validate reusable-verification-platform-program --strict` in the candidate worktree — exit 0, `Change 'reusable-verification-platform-program' is valid`. [openspec-strict.log](openspec-strict.log) preserves stdout/stderr and cwd. Worktree status and all 15 candidate file hashes were unchanged after validation.

The existing primary `verify_program.py` was read, not edited or executed by this reviewer. Root's separately recorded run with primary ROOT and isolated CHANGE passes its 17 structural checks, including all 47 roadmap IDs, 17 lanes and hard-DAG reachability. That evidence does not discharge semantic contribution scope or original-task closure. The graph's omitted direct P02→P04 edge is a permitted transitive reduction, not a missing predecessor.

The 35 checks are document/reference checks; they do not prove operational scheduling, source fidelity, Solidity behavior, theorem truth or mutation detection. Future pins, API refreshes, inventories, actual controls and independent implementation reviews remain entry/acceptance obligations. An honest unresolved factual result is permissible; a missing required tool path or unexecuted normative scenario is not completed evidence.

Retain r1 unchanged. Route PR1–PR3 as one bounded native-Grok planning repair and independently review the exact resulting revision. Do not rerun delivered-kernel campaigns for these document changes.
