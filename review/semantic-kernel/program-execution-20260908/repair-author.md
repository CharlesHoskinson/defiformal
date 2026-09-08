# Planning-repair author candidate — 2026-09-08

**Status: CANDIDATE, not acceptance.** Native Grok 4.6 authored one bounded revision of `openspec/changes/reusable-verification-platform-program/` in worktree `/home/charl/defiformal-wt-program-repair-grok-gpt6-20260908` on branch `work/program-repair-grok-gpt6-20260908`. Independent GPT-6 review of this revision remains required before dependent sprint dispatch. This file does not set a review gate accepted.

- **Repair contract:** `review/semantic-kernel/full-program-spec-review-20260908/ADJUDICATION.md`
- **Authorization record (separate from this package):** `review/semantic-kernel/program-execution-20260908/STATE.json` (`authorized_by`: `begin implementing`, phase `planning_repair`)
- **Frozen historical reviews:** not rewritten. Original Grok/GPT-6 reports and the frozen 15-file archive retain their identities.
- **Revision id in the package:** `sprint-index.json` `schema.revision.id` = `planning-repair-20260908`, `sets_review_gate_accepted` = false, `status` = `pending_independent_gpt6_acceptance`
- **No commit, push, Foreman, subagents, Lean campaign, or mutation campaign.**

The planning files still do not themselves dispatch implementation. User authorization to execute after independent GPT-6 acceptance of this revision is recorded separately in `STATE.json`; this revision does not re-ask.

## Files changed

Edited only `openspec/changes/reusable-verification-platform-program/**` relative to the frozen review copy at `review/semantic-kernel/full-program-spec-review-20260908/frozen-program/`. Compared by SHA-256:

| File | Disposition |
| --- | --- |
| `coverage.md` | changed |
| `design.md` | changed |
| `legacy-task-disposition.json` | changed |
| `proof-obligation-dependency-matrix.json` | changed |
| `proposal.md` | changed |
| `sprint-index.json` | changed |
| `sprint-plan.md` | changed |
| `tasks.md` | changed |
| `specs/certificates-adapters-evaluation-publication/spec.md` | changed |
| `specs/corpus-historical-honest-reporting/spec.md` | changed |
| `specs/minimum-reusable-contracts/spec.md` | changed |
| `specs/reusable-platform-program/spec.md` | changed |
| `specs/source-bound-library-families/spec.md` | changed |
| `specs/remaining-metatheory-lifecycle/spec.md` | unchanged (byte-identical to frozen) |

No new files were added under the change. Original legacy packages, primary tree, proofs, routing, and prior evidence were not edited. Worktree `AGENTS.md` was already dirty before this session and was not touched.

`tasks.md` now has 179 unique unchecked program tasks (was 164). All 339 original legacy IDs and historical checkbox marks are preserved.

## Chosen split and closure rules

### Liquidity (P16 / P21)

- **P16** remains the narrow pinned Uniswap token0 next-price experiment, including the required denominator-sum overflow branch. Substrate owned only by P16: original 1.3 (Arithmetic cache), 2.2–2.3 (FullMath wrap/proofs).
- **P21** owns residual library work that the overloaded P16 mapping had swallowed: TickMath 3.1–3.3, SwapMath 4.2, bitmap/liquidity/factory 5.1–5.3, original 7.4 remainders, **and the original-4.1 residual token1 next-price plus amount0/amount1 deltas**. P21 also owns the original 45-fixture campaign and M01–M12 mutations, plus multi-word traversal.
- Mixed original IDs `1.1`, `1.2`, `2.1`, `4.1`, `4.3`, `6.1`–`6.5`, `7.1`–`7.3` are `disposition=split`, `owner_sprint=P16+P21`, with named `contributions[]` and `whole_task_closure=all_contributions`.
- A P16 token0 contribution **must not** mark those original IDs done.

### Corpus (P09 / P10)

Simple split, no hard cycle:

- **P09** (hard predecessor `P08` only): identities 3.1–3.2, disputes 5.1–5.3/5.5, manifests 6.1–6.3. Successful_exit does **not** include 7.1–8.3.
- **P09.6.1** is a named sub-delivery consumed by P10 original task 2.4. Collection waits on that artifact, not on all of P09.
- **P10** (hard predecessor `P08` only): source work 2.1–2.2, **original bounded collector 2.4** (three requested-target slots including failed guesses, two attempts per target, five redirects outside target slots, 30-second local HTTP deadlines, manifest-membership anti-spoofing, preserve attempts/remainders, no retrospective collector-budget claims), 3.3, 4.1–4.3, 5.4.
- Original **7.1–8.3** are `P09+P10` split contributions. P10 executes the whole-package tooling/acceptance/archive join after P09 successful_exit **and** P10 source/collector work. Conditional dependencies: `collect_task_2.4 = [P09.6.1]`, `whole_package_acceptance_7_8 = [P09]`. No `P09→P10` hard edge.
- **P16 has no corpus hard edge** and no global 169-work / 7.x/8.x barrier. Defective corpus records still cannot be used for fidelity credit.

### Contribution closure (all mixed original tasks)

One original task row may carry several contribution records. Whole-task closure requires every contribution. Standing task 1.10 encodes that rule. Existing M4 `2.x`/`3.x`/`4.5` and Claims `4.2`/`4.3`/`4.7` splits received the same `contributions[]` machine field so a runner does not have two split shapes.

## Adjudicated finding dispositions

### Required substantive repairs

| Finding | Disposition in this candidate |
| --- | --- |
| GPT 1 / Grok F6 — liquidity scope | **Repaired.** P16 narrowed; TickMath/SwapMath/bitmap/factory/full fixtures/mutations moved to P21; mixed 4.1/6.x/7.x split with whole-task join; P21 explicitly owns token1/delta residual. |
| GPT 2 — P17 reuse gate | **Repaired.** `P17.platform_reuse` requires one common harness engine executing both cases, named shared financial lemma/contract, named shared executor result, token0 kernel bridge, both adapters, and measured case-two definitions/assumptions/interfaces/effort. Composition instance required **only if** composition integration is claimed; narrow noncomposing interface/library reuse remains valid. No P30 dependency. Arithmetic-only reuse is a separate `arithmetic_reuse` field and does not open `P21`–`P29`. |
| GPT 3 / Grok F3–F4 — corpus schedulability | **Repaired.** Original 2.4 executable with original bounds; 6.1 exposed as sub-delivery; 7.x/8.x join P09 and P10 without a task-level cycle; P16 not blocked on corpus closeout. |

### Consistency table

| Item | Disposition |
| --- | --- |
| R18 coverage (Grok F5 mapping) | **Accepted mapping repair.** Coverage and `P20.roadmap_ids` now include P20 compatibility/library-instantiation. **Rejected** the stronger claim that mapping alone closes R18; index and certificate spec still keep R18 open until P20 21.2/21.3. |
| Adapter task IDs (GPT 4 / Grok F9) | **Repaired.** Matrix implementation tasks are `32.5`–`32.8`. No `32.5a`–`32.5d`. |
| Coverage counts (Grok F8) | **Repaired by deriving from headings.** After this revision: 55 requirements, 100 scenarios (see table below). Frozen-package measurement was 54/89; the previous coverage table was stale at 51/67. |
| Curve outcome wording (Grok F10 / root obs. 2) | **Repaired.** Matrix `conditional_property` now follows source-selected revert **or** successful residual. No current Curve source behavior asserted. |
| Solidity locators (Grok F7) | **Repaired.** Cap `SwapMath.sol:87–89`; SPL `UniswapV3Pool.sol:608–613`. Named cap/SPL semantics unchanged. |
| P12 evidence class (Grok F12) | **Classification repaired** to `mixed_behavior` with explicit proof (3.1–3.7) and data (2.x/4.x/5.x) obligations. **Rejected** any reading that proofs may be skipped. |

### Dissent / advisory items from adjudication

| Item | Disposition |
| --- | --- |
| Grok F1 named platform-reuse predicate | **Retained as hardening** inside the P17 repair (`P17.platform_reuse`). Did **not** adopt an automatic-bypass defect: resource_gate, P21 entry, and specs already forbade arithmetic-only reuse. |
| Grok F2 blocked-status in success fields | **Editorial normalization applied.** Blocked prose removed from `successful_exit` where it read as an alternate completion. Standing task 1.8, `terminal_disposition`, and P31/P34/P37 open-on-blocked rules remain. **Not** treated as a missing prohibition to restore. |
| Grok F5 early R18 closure | **Rejected** as before; contribution ≠ closure. |
| Grok F10 unpinned-family notes | **Preserved** global source-entry freeze. No discovered Liquity/Balancer implementation defect claimed. |
| Grok F11 P36 schema binding | **Scheduling hardening applied.** Named accepted schema artifact/hash is a `conditional_dependency`. **Not** a P33 hard edge; stability may not be skipped. |
| Grok F13 Atlas 7.3 / 3D ban | **Traceability hardening applied.** Original 7.3 150 KB / no-scene-graph budget is named as superseded by current-layout budget/conformance. **3D ban not restored.** |

## Spec counts after revision

Derived from `### Requirement:` and `#### Scenario:` headings; `coverage.md` matches:

| Capability | Requirements | Scenarios |
| --- | --- | --- |
| reusable-platform-program | 12 | 19 |
| minimum-reusable-contracts | 7 | 12 |
| remaining-metatheory-lifecycle | 6 | 9 |
| corpus-historical-honest-reporting | 7 | 15 |
| source-bound-library-families | 13 | 22 |
| certificates-adapters-evaluation-publication | 10 | 23 |
| **total** | **55** | **100** |

## Validations

### 1. OpenSpec strict

Command (cwd = worktree):

```bash
openspec validate reusable-verification-platform-program --strict
```

Output: `Change 'reusable-verification-platform-program' is valid` (process exit 0). Node printed a `NO_COLOR`/`FORCE_COLOR` warning unrelated to the change.

### 2. Targeted structural/reference checks (this candidate)

Bounded Python in the author session, **not** an edit to primary `verify_program.py`. 77 checks, 77 pass, exit 0. Coverage included:

- 37 unique sprint IDs; acyclic hard DAG; recommended order respects hard edges
- all 47 roadmap IDs; all 17 CURRENT.json lanes
- all 11 legacy packages, 339 original IDs, historical checkbox marks vs original `tasks.md` sources (including sibling liquidity/certificate paths)
- every `split` row has contribution sprint IDs that exist and appear in `owner_sprint`; `whole_task_closure=all_contributions` (34 split rows)
- resource-gate object keeps `id=P17` and adds `predicate=P17.platform_reuse`, `not_satisfied_by=arithmetic_only_reuse`, `p30_dependency=false`
- P21–P29 still have `resource_gate=P17` (old machine id) while prose/predicate distinguish platform vs arithmetic reuse
- corpus order: no P09 hard predecessor of P10; 2.4 consumes `P09.6.1`; 7.x/8.x join consumes P09; P16 has no corpus hard edge
- adapter tasks `32.5`–`32.8` exist; no `32.5a`–`32.5d`
- locators 87–89 and 608–613; stale 89–92 / 603–613 absent
- design mermaid hard-edge *reachability* matches the index; dotted `P09 -.-> P10` is **not** a hard edge
- `schema.revision.sets_review_gate_accepted=false`

Direct mermaid omission `P02→P04` remains a transitive reduction (`P02→P03→P04` plus index hard edge `P02→P04`). Reachability still matches. Same class of diagram reduction as the frozen package.

### 3. Primary `verify_program.py` (not this candidate)

Command:

```bash
python3 /home/charl/defiformal/review/semantic-kernel/full-program-openspec-20260908/verify_program.py
```

Exit 0; 17 structural checks all true **against the primary tree**, whose `ROOT` is `/home/charl/defiformal` and whose change path is the old primary package. That script was **not** pointed at this worktree and was **not** edited. It does not check contribution records, adapter ID existence, corpus task-level order, or `P17.platform_reuse`. Do not treat its green result as review of this revision.

No new checker file was added to the package. The bounded Python above is the candidate-side check. A later shared checker could consume `contributions[]`, `P17.platform_reuse`, and `P09.6.1` conditionals; that is not this repair.

### 4. Not run

No Lean build, no EVM execution, no mutation campaign, no holdout/assessment payload read, no web browse.

## Limitations

- This is a planning-document repair. It does not implement P01–P37, accept frozen candidates, or lift dispatch.
- Semantic ownership is encoded in the package and checked by the session script; it is not proved by OpenSpec `--strict`.
- `resource_gate` machine values remain the sprint id `P17` so a naive reader of the old field still sees a Pnn. The predicate that satisfies the gate is `P17.platform_reuse`.
- Coverage totals changed because requirements/scenarios were added and the stale table was replaced by heading-derived counts. They are not the frozen-package 54/89 measurement.
- Existing split rows for M4/Claims gained `contributions[]` without changing their original IDs, owners, or historical marks.
- Worktree `AGENTS.md` remains a pre-existing dirty file; out of scope.

## Terminal summary

Native Grok 4.6 produced planning-repair candidate `planning-repair-20260908` in `openspec/changes/reusable-verification-platform-program/` (13 of 14 content files changed; remaining-metatheory spec untouched). P16 stays token0 plus required sum-overflow; P21 owns TickMath, SwapMath, token1/delta, bitmap/factory, 45-fixture/M01–M12, and traversal, with mixed original IDs closed only when every contribution exists. P17.platform_reuse now requires one harness, shared lemma/contract, shared executor result, and measured case-two inventory; arithmetic reuse does not open P21–P29; no P30 dependency. Corpus 2.4 is executable after the P09.6.1 sub-delivery; 7.x/8.x join P09 and P10 without a hard cycle; P16 has no corpus barrier. R18 lists P20 as a contribution; adapters are 32.5–32.8; spec counts are 55/100; Curve/cap/SPL/P12/P36/Atlas 7.3 consistency items are aligned. `openspec validate --strict` exit 0; 77/77 targeted candidate checks pass. Primary `verify_program.py` still greens the **primary** tree and was not used as this candidate’s checker. Independent GPT-6 acceptance is still required. Native completion is a candidate, not acceptance.
