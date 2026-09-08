# Reviewer 03, round 2 — applied cleanup and platform routing

**Verdict: ACCEPT the five-file cleanup and the draft's preservation/routing policy. ACCEPT WITH LIMITATIONS the refreshed graph as source navigation only. No required cleanup fix remains.** The platform/library sequencing in PLAN-v1 is suitable for refinement; this review does not accept candidate proofs, source correspondence, or a finished platform.

Reviewed plan SHA-256: `93c8464e68d06eecc745489dab4f118b2651443029907d2ae72d775c6dc082d8`.

## Applied cleanup independently verified

Read `evidence/cleanup-applied.json`, original `reviews/03-cleanup-candidates.json`, and every archive member in memory. `cleanup-originals.tar.gz` hashes to `ca66ff7f1f0aca90106a352ed30db1ef59db432bbde92a4b7c9313035f9e2d12`. The archive has exactly five regular-file members, with no extra paths or symlinks. Their names, sizes and SHA-256 values equal the original approved list and the applied record:

| Removed path | Bytes |
| --- | ---: |
| `texput.log` | 753 |
| `scripts/__pycache__/check_integer_arithmetic_evidence.cpython-314.pyc` | 30,088 |
| `scripts/__pycache__/corpus_adjudicate.cpython-314.pyc` | 457 |
| `scripts/__pycache__/test_corpus_adjudication.cpython-314.pyc` | 95,027 |
| `scripts/__pycache__/test_historical_reconciliation.cpython-314.pyc` | 28,402 |

Total: **154,727 bytes**. All five original working paths are absent. The four corresponding `.py` sources remain and pass `ast.parse`. Exact archive member readback establishes byte restoration without writing restored files over the workspace. No runtime behavior, Lean build, or financial proof acceptance is inferred.

This cleanup removes no source and retains the failed LaTeX invocation byte-for-byte in the archive and original review JSON. No evidence was erased. No broader directory cleanup is justified.

## Graph review and update during review

The first report read showed 633 nodes/567 edges. Root rebuilt it during this review; a subsequent consistent read is timestamped **2026-09-08T14:40:22.661489+00:00**, with **638 nodes/568 edges/347 communities**. The increase is five Atlas source files (Atlas now 12). Do not repeat 633 as the final graph inventory.

Reviewed final graph SHA-256: `64b95520877468102b1bfcd64d765d297da38ce092a8cad0e27cd4b325f3b5ba`.
Reviewed source-manifest SHA-256: `cab474d93ce5da5e9a1d71a7e901a96fa0592b609300fa63001976a45e74d50c`.

All eight artifact-manifest entries match their current byte lengths and hashes. All 638 current source files match their source-manifest identities. Graph node IDs equal manifest source IDs; all 568 edges have present endpoints. Layer counts: primary 577, Sprint12 10, lifecycle 4, Claims 9, corpus 12, historical 13, Atlas 12, honest-gate 1. This is navigation over delivered and unaccepted code, not proof coverage or progress.

The new graph still shows `.gp-ord-test.mjs → .gp-ord-scratch.mjs` as `ast_dynamic_import`. It gives no incoming edge to standalone `lean/Axioms.lean` or candidate `Claims/Preservation.lean`. These are direct counterexamples to equating graph orphans with removable code. No orphan deletions are proposed. Candidate-to-primary fallback edges remain architecture hints and do not prove candidate dependency-byte equality. The historical root/codebase graphs should remain as recorded evidence.

## Concrete additive routing notice

Prepend the following to `research/positive-program/AGENDA.md`, retaining every existing byte as the historical body. The current body's SHA-256 is `418f49981edc448bf9c3e6eab25f554934c8a1ef269eefceaee343f7634e62d8`.

```markdown
> **Historical agenda — superseded on 2026-09-06.** This stopped loop and its
> recorded branch, completed items and IDLE state describe the earlier program.
> Continue from the [current roadmap](../../roadmap.md) and
> [semantic-kernel workstate](../../review/semantic-kernel/program-loop-20260908/WORKSTATE.json).
> The [approved migration](../../docs/superpowers/specs/2026-09-06-semantic-kernel-design.md)
> governs the reusable verification platform and library program. Preserve the
> original agenda below as historical evidence; its old branch and loop state
> do not direct new execution.
```

The additive banner changes this entrypoint's file hash, so record the pre-notice hash and distinguish the new routing wrapper from the historical bytes. Do not apply the notice inside frozen candidate archives or captured historical copies.

## Concrete historical tooling index

Create only `research/positive-program/tooling/README.md` with this content; leave the scripts in place:

```markdown
# Positive-program tooling: historical index

These tools support the earlier positive-program record. For current work, use
[the roadmap](../../../roadmap.md),
[the semantic-kernel workstate](../../../review/semantic-kernel/program-loop-20260908/WORKSTATE.json),
and [the approved migration](../../../docs/superpowers/specs/2026-09-06-semantic-kernel-design.md).

| Tool family | Historical role and routing |
| --- | --- |
| `patch_*.py` | One-shot edit recipes for historical plans, claims and fidelity records. Running them can rewrite those records. Retain them as provenance; they are not current migration steps. |
| `g_*.py` | Earlier graph construction utilities. Preserve versioned graph inputs and manifests; graph regeneration does not establish byte equality or acceptance. |
| `clone_repos_2.2.sh`, `split_tex.py`, `ir_probe.py` | Earlier source acquisition, corpus preparation and inspection utilities. Check their exact inputs, outputs and scope before any separate reproduction task. Their presence here does not establish that they are dead or currently authoritative. |

Historical proofs, negative results, failed checks and original source evidence
remain in their existing locations. This index changes routing only. It does
not authorize replaying old patch scripts, deleting disconnected files, or
relabeling development material as untouched evaluation data.
```

Before root applies these notices, check for a concurrently created tooling README. Afterward, validate all six relative link destinations, show the additive diff, and confirm the original AGENDA body survives unchanged after the banner. No frozen failed-proof evidence needs rewriting; do not modify patch script code or archive bytes.

## Platform-plan assessment

The recommended sequence addresses the user's platform/library objective: it retains the accepted execution kernel, stabilizes reusable contracts, tests two contrasting financial operations, and expands after actual reuse rather than counting modules. Keeping source/model correspondence separate from source identity is essential. One quantified refinement for a supported operation is an appropriate first trust gate, provided the accepted scope and remaining assumptions are explicit.

Two advisory refinements would make PLAN-v1 operationally clearer:

1. Treat acceptance debt as per-lane dependencies. A ready coherent platform increment should not wait for unrelated historical or Atlas closeouts; steps 1–2 should not become a global freeze. Preserve queued candidates and choose a bounded review/delivery lane.
2. At the two-case selection gate, identify an actual reusable financial guarantee and the exact pinned implementation entrypoint for each operation. The second operation should test a different behavior or lifecycle through the same interfaces. Do not choose it merely to increase library count, or name one as ready before its source closure is checked. A reusable platform increment should expose a reproducible external-user example/API, as step 5 already requires.

These are sequencing clarifications, not required cleanup repairs. No new author lane, proof implementation or library source edit was performed in this review. Only this report was written. Excluded old12/holdout payloads and the forbidden historical discovery JSON were not read.
