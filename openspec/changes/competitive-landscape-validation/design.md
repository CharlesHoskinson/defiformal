## Context

This is the proposed follow-up to the
[delivery amendment](../competitive-landscape-adoption/design.md). Original
accepted state is 13/17 at `cd2f8ef5`; historical component effort is unknown and
the owner confirms no outside P18 reproduction exists. Existing agent replays and
reviews support engineering delivery. They do not supply outside-person records.
All tasks below are pending; these planning files are not observed results.

## Goals / Non-Goals

**Goals:** separately measurable new component work, actual outside P18 and compiled
package reproduction, and reviewable evidence with stable identities and outcomes.

**Non-Goals:** reconstruct missing historical time, demand a positive reuse saving,
redesign financial APIs, repeat accepted proofs without a changed obligation, or
claim adoption/general safety from one reproduction.

## Decisions

### 1. Predeclare a bounded new experiment

Before work starts, select two small component instances with related financial
obligations and a declared reuse opportunity. Pin initial source/tool identities,
define financial correctness/refusal and axiom gates, and record author/reviewer
roles. Selection and allocation must precede timing, rather than choosing favourable
results retrospectively. Existing vault/token0/workflow times remain unknown.

Use one primary measured unit: authoring-session elapsed time per instance. It
includes declared agent/tool/wait intervals and is labelled elapsed, not human
person-hours. Record failed attempts and review/repair sessions separately, then
include or exclude them according to predeclared totals. Keep shared work in its
own bucket; never allocate a cumulative session by guesswork. Human active time
is optional and requires its own collection method. No improvement is an acceptable
experimental outcome. Missing per-instance measurements keep task 2.2 open.

### 2. Bind evidence to exact inputs

Records name source revisions/file hashes, count scope, protocol revision, tool
identities, requested/reported models when available, start/end timestamps,
interruptions, outcomes and raw-log hashes. Model aliases are not provider
attestations. Line counting uses explicit exhaustive/disjoint categories with
shared/dependency exclusions. Records state which financial obligations were
accepted; unmatched scope cannot support an effort-saving comparison.

### 3. Preserve the two outside acceptance standards

P18 task 3.1 inherits original I.4: an actual outside attempt with outcome and setup
time qualifies even if it fails. Compiled-package task 4.1 inherits the original
III.1 successful package-only replay criterion: a failed attempt is useful evidence
and leaves successful rechecking open. Each task records role and independence,
exact instructions/package, host setup, commands, measured times and assistance.
Neither an agent nor a project maintainer qualifies as the outside developer.

Use an existing immutable supported release; v0.16.0 is the initial compiled
candidate, subject to the participant's compatible host. Declare OS/architecture
prerequisites rather than silently replacing the archive or expanding platform
support. A source checkout, existing project build cache, undocumented tool download
or maintainer-only instruction is outside the package-only procedure. Routine
coordination is recorded; substantive troubleshooting cannot be hidden. When a
repair is needed, retain the failed run and attempt the corrected exact package in
a fresh qualifying environment before claiming success.

One person may do both procedures in one session with separate outputs and clear
cache/environment boundaries. Recruitment and sending invitations require their own
explicit communication authorization; creating this plan does not send messages.

### 4. Independent review closes observations, not promises

Review the exact protocol before the experiment and the exact resulting evidence
before completion under applicable reviewer bindings. Record unavailable reviewers
as open review. Final acceptance maps original I.3/II.1 measurement objectives and
I.4/III.1 outside requirements to the new records. Unknown original effort remains
unknown even when the new experiment succeeds. Delivery closure and validation
closure have separate decisions.

## Risks / Trade-offs

- An outside developer is unavailable → keep the corresponding task open with a
  named dependency; delivery completion does not manufacture validation.
- Original time cannot be recovered → preserve `null`; use the new experiment to
  answer only its prospective question.
- Observation or workload bias → predeclare obligations and report the experiment's
  limited comparability, unsuccessful attempts and shared overhead.
- P18 fails while compiled replay succeeds → retain both distinct outcomes;
  P18 record completion is not a claim of successful source reproduction.
- A participant needs additional platform work → report the incompatibility and
  scope any repair separately before scheduling a fresh exact run.

## Migration Plan

After owner approval and independent planning acceptance, freeze the protocol,
perform the prospective experiment, then collect the two actual outside records.
The independent activities can be scheduled separately. Preserve existing frozen
evidence and publish new records with their identities. Update validation state
only after exact evidence acceptance. Original delivery proofs and release assets
need no change merely to adopt this plan.
