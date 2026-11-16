## Context

See proposal.md. Inputs are the IOG Technical Intelligence report (data as of 2026-11-06), the DeFiFormal source at `2b60322cdc8c98f0e0c27cab3b2d6dcc824c3eda` on `semantic-kernel-pivot`, the toolchain pin `lean/lean-toolchain` `leanprover/lean4:v4.33.0-rc2` with mathlib `v4.33.0-rc2`, and the accepted P16, P17, P18 and P19 records under `review/semantic-kernel/program-execution-20260908/`.

Measurements cited here are of abstract benchmark models under the assessment's measurement contract (local process wall clock, three successful runs per value). They are not proofs about deployed code and they do not rank tools; records were taken in different comparison groups.

## Goals / Non-Goals

**Goals:**

- One ordered list of 13 tasks, each with the gap it addresses, the sprint it serves, the kind of value it buys (better product, trusted by others, better measurement) and an observable completion criterion.
- Delta specs whose scenarios are the completion criteria, so that acceptance of a task is a check, not a judgment.
- Additions only. No edit to accepted specs, the frozen sprint plan, the roadmap or any Lean file.

**Non-Goals:**

- Implementation of any task, including CI configuration, adapters, Lean modules or proofs.
- Re-running or re-grading the assessment inside this repository.
- Changing historical theorem statements, accepted review identities or the P16 to P19 acceptance records.
- Ranking DeFiFormal against competitors by speed.

## Decisions

### 1. One change, four phases, rather than four changes

The repository's active changes are sprint-sized slices. The 13 tasks are heterogeneous, so a single umbrella change keeps one review and one evidence index. Phases carry the ordering: I is operational; II targets the first composed example subject to its financial connection and preservation requirements; III depends on II for its subject; IV depends on II and, for liquidation, on sprint P27. Adapter-dependent tasks in every phase also require the artifacts specified in task 1.2. If the owner prefers, phase II can later be split into its own slice without changing this file.

**Rejected:** editing `sprint-plan.md` to add tasks. The program is frozen and earlier changes state they do not edit it.

### 2. Proposed sprint mapping

The report names sprints at four points only: P18 (task I.4 and gap D5), P27 (task IV.3 and gap D4), P16 and P19 (gaps D3 and D5). The rest of this table is a proposal of this change, read off `openspec/ROADMAP.md`, for the owner to confirm or strike.

| Sprint | Tasks that would serve it |
| --- | --- |
| P17 platform reuse | II.1, II.2 |
| P18 external package (named by the report) | I.4, III.1, III.2 |
| P19 certificates (named by the report for D3 and D5) | II.3, III.1 |
| P16 Solidity/EVM token0 campaign (named by the report for D3) | II.3 |
| P20 quantified correspondence | II.2, II.3 |
| P27 liquidation and margin (named by the report) | IV.3, IV.4 |
| P30 source refinement | II.3 |
| P37 reproducible developer package | III.2 |
| No sprint | I.1, I.2, I.3, IV.1, IV.2 |

### 3. Kind of value is recorded per task

Each task carries one of three kinds. *Better product* changes what the kernel can do or how cheaply the next component is proved. *Trusted by others* leaves the kernel unchanged but lets a third party set it up and re-check it. *Better measurement* protects or sharpens the numbers without touching the kernel. The distinction follows the repository's rule that proof, bounded execution, measurement and unchecked assumptions stay separate.

### 4. Completion criteria are the scenarios

Every "done when" of the report's task table appears as a WHEN / THEN scenario in the delta spec of its capability. A task closes when its scenario is demonstrated, not when it is declared done.

### 5. Evidence location

The report embeds every number it cites. The underlying measurement records stay in IOG's private assessment repository and are named in `evidence-index.json` with their record identifiers. A reviewer inside this repository can verify every claim against the report; verification against raw records needs access to that repository, which the proposal states openly.

### 6. Replay speed is out of scope on purpose

The report's section 2.1 takeaway: replay time itself needs no task. 2.4 to 3.9 s is Lean elaboration against mathlib, Verity sits at the same times, and no assessor weighs the gap to Act's 0.7 s. No task targets it.

## Risks / Trade-offs

- The adapters are not in this repository. Every adapter-dependent task, including II.2 and IV.1, remains blocked until its required pinned adapters, proofs and helpers, or specified replacements, are available.
- Tasks I.4 and III.1 need a person outside the project; the implementation loop cannot complete them alone.

## Open Questions

- Whether the owner wants the IOG benchmark adapters contributed as a separate change.
- Whether phase II should be filed as its own slice once accepted.
