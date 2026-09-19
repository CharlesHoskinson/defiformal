# September 19 delivery post-mortem and replacement workflow

The user stopped the loop after roughly four hours because usable DeFi Kernel delivery was inadequate. The orchestration owner accepts this assessment. Implementation is paused; resumption requires a user instruction. No candidate is accepted by this document.

## Measured outcome

Six native Grok runs occupied 235.7 minutes in total. R1 began at 17:01:04 UTC; R6 was interrupted at 21:28:16 UTC. These durations include model reasoning, reading, implementation and verification. They do not measure orchestration overhead separately. Source: grok-r1-process.json through grok-r6-process.json in this directory.

Two source integrations were published: 890929f1, the reviewed codec proof closure, and 44f2026d, two reviewed arithmetic/identity helpers. The first source integration occurred at 20:39:07 UTC, about 218 minutes after R1 began. The proofs have value, but no new whole sprint, qualified certificate checker, or financial capability was delivered by this loop. Existing earlier financial work is not credited to this run.

R4 and R5 production checker reviews rejected substantive behavior. R5's actual CLI accepted a report whose compositionCompatible field was false. Host checks failed to detect several source/record substitutions. R6 repaired 19 report regressions and recorded 54/54 fixture comparisons plus comparator negatives, but its first mutation control failed to compile. That successful fixture run predates later edits and is not acceptance of the interrupted final source. R6 is unfinished, unreviewed work.

Evidence: R3-SOURCE-INTEGRATION.json; GROK-R5-SCOPED-ACCEPTANCE.json; astra-grok-r4-review/REVIEW.md; astra-grok-r5-review/REVIEW.md; author worktree R6 logs/fixtures-full-r3 and logs/mutants-m01-m16.

## Causes and responsibility

1. Root selected oversized assignments. R6 combined quantified correspondence, runtime policy, host binding, compatibility semantics, 54 fixtures, 16 mutations and 99 scenario reconciliations. One author could spend a full round without delivering a reviewable behavior change.
2. Root delayed useful integration by misreading the qualified-checker gate as a ban on proof-source integration. Independent clarification later removed that self-imposed hold.
3. The workflow rewarded evidence volume and activity. Repeated snapshots, environments, inventories and status updates obscured the absence of completed behavior. Exact review matters, but duplicating unchanged evidence does not improve correctness.
4. Review feedback was asynchronous and not reliably consumed. R6 read the findings initially, then only reread updated findings at tool call 142 after root added an explicit reminder. A file update was incorrectly treated as adequate delivery of feedback.
5. End-to-end rejection cases came too late. Broad passing counts coexisted with an accepted report containing a failed required judgment. The critical production regression should have led the repair task.
6. Repair scope caused regressions. A report wrapper change produced 19 fixture failures, consuming another repair cycle. The author was given several interacting changes instead of one controlled behavioral delta.
7. Root continued a failing throughput pattern. Repeated short monitoring turns and assurances were not substitutes for delivery. User complaints should have triggered this reset earlier.

Not established: an exact percentage of time wasted, a Foreman runtime defect (Foreman was not used), or that replacing the requested author model alone would solve the failure. Lean compilation and independent semantic review remain necessary. The solution is smaller work and earlier decisive checks, not weaker proof standards.

## Replacement workflow — effective on resumption

- Keep native Grok 4.6 as author and independent Astra medium as checker. Root owns task selection, feedback delivery and immediate integration. Keep one author and one checker, existing isolated trees and build caches. No new harness, dashboard, dependency installation or repository-wide archive per repair.
- Dispatch one user-visible behavior or one indispensable theorem obligation. The brief contains the defect, exact reproducer or theorem, allowed files, acceptance command, and integration destination. Aim for a brief under 250 words; do not assign the whole backlog to a worker.
- Run the decisive failing check first. Fix the production path. Run the same check and affected consumer checks. Preserve historical statements and required final sprint campaigns; do not demand every campaign for every intermediate edit, or claim sprint completion from a narrow check.
- Target a first meaningful execution or proof experiment within 10 minutes. At 30 minutes without a verified repair, root diagnoses the concrete impediment and reduces the assignment or changes the technical approach. These are intervention thresholds, not automatic process kills and not reasons to discard a necessary long compile.
- Review only a completed, fixed candidate: a Git revision or changed-file hashes with an exact dependency baseline, plus relevant raw checks. Reuse unchanged accepted evidence and the existing review cache. A full archive is justified only when the review actually requires it.
- Give Astra one question: does this change fix the stated behavior without breaking the relevant contract? Root must communicate any rejection directly in the next author brief and require acknowledgement before coding. No moving feedback file as the sole delivery mechanism.
- Integrate and publish accepted source in the same cycle after the necessary integration check. State narrow acceptance honestly; keep qualified release gates intact. If integration is impossible, identify that dependency before dispatch.
- No next broad task while the current accepted change sits unintegrated. No metadata-only progress credit. Report the behavior changed, exact commit, verification and remaining limitation. Process liveness is waiting, not implementation progress.
- Preserve the full P37 obligation. Select dependency-ready functional slices with practical DeFi value; do not repeatedly reopen accepted codec work or let certificate packaging consume the whole program. P21/P22 and later source-backed financial work remain required, alongside the earlier core obligations and Atlas.

## First task when explicitly resumed

Reproduce the sealed R5 overlapping-run case against the interrupted R6 source. Fix accepted-status handling so a failed required compatibility judgment cannot be accepted, while preserving the actual sequential execution observation and the declared refusal/incomplete contract. Add the focused regression and a legitimate nonconflicting success control. Review and integrate that isolated change with its necessary dependencies; if the unfinished Delivered module prevents isolated integration, resolve that dependency before launching the author. Host drift validation is the next separate task, not an additional clause in the first brief.

The stop is deliberate. R6 files and failure logs are preserved in the existing author worktree. No further implementation or review was dispatched during this post-mortem.
