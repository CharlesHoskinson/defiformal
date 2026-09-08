# Sprint11 binary-r1: Nary/BinaryCorrespondence

Requested worker: `grok-4.6`. Reported worker: Grok 4.6
(session identity “You are Grok 4.6 released by xAI”; no `grok-4.6-build`
telemetry in this process). Assigned checker: `gpt-6-astra`. This worker did
not run that check. No Foreman. No commit, push, archive, or self-acceptance.

Baseline HEAD: `ed94e6050d092e67f945df7b9762d3096ab0feda`.
Evidence directory: `review/semantic-kernel/sprint11/implementation/binary-r1/`.
Lake toolchain: Lean 4.33.0-rc2 (`d8b18978322de05a8f3dba51ef03cf5461676c17`).

## Owned files

- Additive executable conversions and diagnostic projection in
  `lean/DefiKernel/Nary/Observation.lean` before the unique `-- BEGIN PROOFS`
  marker. Existing comparison definitions were not rewritten.
- Proof-only `lean/DefiKernel/Nary/BinaryCorrespondence.lean`.
- This evidence directory.

Not edited: Examples, Tests, Audit, Schedule, Execution, CausalRuntime, and
other workers’ proof modules. BinaryCorrespondence is not imported by any
runtime root.

## Layout (GPT-6 nonauthor disposition)

Shared full binary conversions and diagnostic projection live in Observation
before the proof marker. Simulation proofs live in BinaryCorrespondence. F03
must call those Observation names; a paste-ready Tests fragment is
`f03-insertion.lean`.

Roster is `binaryParticipants` with order `[left, right]`. The name avoids
clashing with `Examples.binaryRoster` (same order, different namespace).

Schedule-error projection recomputes both expected/observed counts from the
original branches and schedule via `projectBinaryCounts` /
`projectScheduleMismatch`. The n-ary first-mismatch payload is not copied.

## Proofs compiled

Start, arbitrary single-token `advance` (failed skip, exhausted skip, refusal,
success), static admission (catalog, then all-branch analysis in `[left,right]`
order, then counts), arbitrary-entry `continueRun`, `runPrefix`, and
`runNary`/`runInterleaving` correspondence. Core already had generic
`continueRun_append`; this module adds `continueRun_three_chunk` and
`continueRun_chunk_assoc` on arbitrary machines. No participant-tree
regrouping or cross-schedule order claim.

Bool helpers `binaryAdmitAgrees`, `binaryPrefixAgrees`, `binaryRunAgrees` and
siblings are proved true from those equalities.

No `sorry`, custom `axiom`, or `native_decide` in owned sources.

## Builds (cwd `lean/`)

| Command | Exit | Log |
|---|---|---|
| `lake build DefiKernel.Nary.Observation` | 0 | `logs/lake-build-Observation.*` |
| `lake build DefiKernel.Nary.BinaryCorrespondence` | 0 | `logs/lake-build-BinaryCorrespondence.*` |
| `lake env lean DefiKernel/Nary/Observation.lean` | 0 | `logs/lake-env-lean-Observation.*` (empty) |
| `lake env lean DefiKernel/Nary/BinaryCorrespondence.lean` | 0 | `logs/lake-env-lean-BinaryCorrespondence.*` (linter warnings on stdout, no errors) |

Source hashes: `source-hashes.json`. Theorem/API inventory: `statements.json`.

Pre-existing flexible-simp linter notes remain on Observation’s older
`localEq_iff` proof and on Schedule; they are not new failures.

## Not done in this lane

- F03 runtime rows are **not** in Tests. Fixture author must integrate
  `f03-insertion.lean`. This worker did not execute Tests/Audit.
- Independent GPT-6 check of this candidate was not run.
- Causal and InterfaceInstances remain other lanes.
- Integrated root import, axiom inventory, and production mutants remain later.

`implementation_accepted` remains false.
