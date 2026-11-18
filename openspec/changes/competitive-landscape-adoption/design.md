## Context

**Draft amendment — 2026-11-18, pending owner review.** The proposed completion
structure below supersedes the original umbrella decision only if this amendment
is accepted. Existing accepted evidence remains bound to the original bytes and
criteria. See tasks.md for the obligation mapping and remaining amendment gates.

See proposal.md. Inputs are the IOG Technical Intelligence report (data as of 2026-11-06), the DeFiFormal source at `2b60322cdc8c98f0e0c27cab3b2d6dcc824c3eda` on `semantic-kernel-pivot`, the toolchain pin `lean/lean-toolchain` `leanprover/lean4:v4.33.0-rc2` with mathlib `v4.33.0-rc2`, and the accepted P16, P17, P18 and P19 records under `review/semantic-kernel/program-execution-20260908/`.

Measurements cited here are of abstract benchmark models under the assessment's measurement contract (local process wall clock, three successful runs per value). They are not proofs about deployed code and they do not rank tools; records were taken in different comparison groups.

## Goals / Non-Goals

**Goals:**

- A delivery milestone with observable proof, package and accounting criteria, linked to a separately tracked validation change. Preserve the original 13 report tasks and 17-item implementation checklist as historical references.
- Delta specs whose scenarios are the completion criteria, so that acceptance of a task is a check, not a judgment.
- Preserve accepted specs, the frozen sprint plan, the roadmap and historical theorem statements. Add implementation and evidence through individually reviewed slices.
- Import the IOG Suite 1.0 and rational-1 adapters in this change with pinned provenance, preserved attribution and portable replay.

**Non-Goals:**

- Treating imported benchmark proofs as new kernel proofs or outside reproduction.
- Re-running or re-grading the assessment inside this repository.
- Changing historical theorem statements, accepted review identities or the P16 to P19 acceptance records.
- Ranking DeFiFormal against competitors by speed.

## Decisions

### 1. Original decision: one change, four phases

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

For the proposed amendment, the report's original criteria remain historical.
The revised scenarios govern the delivery milestone only after acceptance, and
the transferred criteria govern the linked validation change. A checked delivery
task cannot be used as evidence that a transferred criterion passed.

### 5. Evidence location

The report embeds every number it cites. The underlying measurement records stay in IOG's private assessment repository and are named in `evidence-index.json` with their record identifiers. A reviewer inside this repository can verify every claim against the report; verification against raw records needs access to that repository, which the proposal states openly.

### 6. Replay speed is out of scope on purpose

The report's section 2.1 takeaway: replay time itself needs no task. 2.4 to 3.9 s is Lean elaboration against mathlib, Verity sits at the same times, and no assessor weighs the gap to Act's 0.7 s. No task targets it.

## Risks / Trade-offs

- Original entry risk: adapter-dependent tasks were blocked until pinned imports were available. The accepted import and subsequent delivery records now supply those artifacts; this draft does not reopen accepted implementation.
- Outside-run tasks still need a person outside the project. The linked validation change keeps these obligations visible; an agent cannot satisfy them.

### Proposed completion amendment, 2026-11-18

**1. Delivery and validation have separate completion gates.** The existing
change covers the implemented, reviewed and published bounded reference APIs,
engineering replay and scoped accounting. The linked
[competitive-landscape-validation](../competitive-landscape-validation/design.md)
change covers prospective effort measurement and both outside reproductions.
Keeping all obligations in one permanently open delivery checklist was considered;
the split gives each milestone an observable finish without erasing missing data.

**2. Unknown historical effort is a reported result.** I.3's amended criterion is
a scoped accounting record with counts, attribution, source identities, explicit
exclusions and effort availability. Historical time stays `null` with a reason;
command time, shared elapsed intervals and unallocated support files do not become
component authoring cost. The accepted baseline measures selected adapters only.
A new reconciliation note must bind those records and state the changed criterion;
the legacy checker and manifests retain their original `unmet` conclusion.
This amendment cannot establish cheaper development or a complete component cost.

**3. Functional composition and effort measurement are separate.** II.1 retains
all accepted financial connection, initialization/preservation, local guarantee,
unit, refusal and shared-lemma obligations. Its count scope is the illustrative
workflow and its separate deposit/quote/shared partitions. Separately measured
authoring effort moves to a prospective experiment with a predeclared protocol;
it cannot reconstruct the original workflow's unknown component times.

**4. Package delivery and outside validation are separate.** III.1 closes on an
exact published package, checker/runtime/import identities, scope/checksums and
successful engineering replay from a fresh extraction. The original outside
package-only run is retained in validation task 4.1. Original I.4 becomes
validation task 3.1. One outside developer may supply both records, but each run
must meet its own requirements; an agent, download or release is insufficient.

**5. Amendment acceptance is explicit.** The source and scope of every transferred
obligation are mapped in tasks.md. Original accepted records at `cd2f8ef5` remain
the evidence for the previous 13/17 state. This uncommitted draft is not an
accepted amendment. Its task 1.3 requires owner approval and independent planning
review under applicable reviewer bindings. I.3 and 6.1 remain open until new
accounting/scenario reconciliation records are accepted. No archival or release
action follows merely from writing this draft.

### Applying the amendment after approval

1. Freeze and independently review the exact amendment plus linked follow-up.
2. Publish a new scoped accounting reconciliation using the existing source-bound
   counts/attribution and explicit unknowns. Preserve legacy evidence bytes.
3. Add a new scenario inventory mapping unchanged scenarios to prior acceptance,
   changed accounting/package scenarios to their actual support, and transferred
   requirements to the open validation tasks. Preserve the original inventory.
4. Update live status only after that acceptance. Delivery may then close under
   the amended contract while validation remains open. The broader roadmap and
   all stated deployment/adversary/market-safety limitations remain in force.

### Implementation transition authorized on 2026-11-17

The owner directed that both benchmark adapters be included in this change and supplied access to `input-output-hk/SOTA-DeFiFormal-Moriarty`. Import only the relevant DeFiFormal adapter sources, proofs, helpers and required contracts. Record the assessment repository revision and each imported file's hash; preserve upstream files unchanged and place portability wrappers separately. Verify the expected file inventory, dependency pins and replay prerequisites before clearing an adapter-dependent task. Preserve failed automatic cases and characteristic mutations as negative evidence. A source import or historical passing record alone is not a fresh successful replay.

Codex now authors this change, with `gpt-6.1-sol` at high effort requested where available, otherwise the current model. Independent `gpt-6-astra` at medium remains the checker. This supersedes the native Grok author requirement for this change only. Preserve the original planning review and actual model identity limitations. Review this amendment before adapter implementation; review each completed implementation candidate independently. No Foreman or new orchestration framework.

### Continued implementation with missing historical effort (2026-11-17)

The owner asked to continue after the Phase I evidence pause. Proceed with dependency-ready Phase II and later engineering tasks while I.3 historical effort and I.4 outside reproduction remain open. Historical effort stays unknown (`null`), never inferred from command runtimes or reported as zero. This changes execution ordering only: no acceptance criterion, proof obligation, outside-reproduction requirement or task checkbox is waived. Record prospective authoring-session intervals for new work separately from historical effort and human person-hours. Later tasks still require their real source, semantic and evidence dependencies; a missing external recheck remains an open release/adoption claim rather than a reason to stop unrelated engineering.

## Open Questions

- Resolved: the owner requests both IOG benchmark adapters in this change, not a separate change.
- Owner review of this draft is pending. No additional implementation decision is needed before that review.
