# Sprint11 finite-participant planning package (grok-gpt6-r1)

This is the GPT-6 review entrypoint. It is a hashed local map, not a 3.4MB inlined prompt.

**Do not treat this package as planning-gate acceptance.** Independent GPT-6 review of this recovered package remains pending. Native Grok 4.6 is the package worker, not the checker.

## Reviewer command (read-only)

```
python3 review/semantic-kernel/sprint11/planning/grok-gpt6-r1/package.py --check
```

Optional: `--root ROOT --package PACKAGE`. `--check` writes no files. It verifies stored hashes from `source-inventory.json` and `MANIFEST.json`. It does not call `--prepare` and does not rewrite artifacts.

Independently hash `MANIFEST.json` and compare to `ANCHOR.json` field `manifest_sha256`. Hash `source-inventory.json` and compare to `ANCHOR.json` field `inventory_sha256`. `MANIFEST.json` does not contain its own hash. `ANCHOR.json` is the external trust anchor and is not listed inside `MANIFEST.json`.

## Bound identities

| Item | Value |
| --- | --- |
| Isolated baseline | `ed94e6050d092e67f945df7b9762d3096ab0feda` |
| Prior official candidate | `b85c14af7be6e01340a93dcb00b7bad8a10c11ae` |
| Accepted M2 source | `b165bc586080d668f689fbc18dfa09eb8739d688` |
| User role override | have Grok 4.6 do this work and have GPT 6 check |
| Source author | stock GPT-6 agent Hegel (M3 author plan) |
| Package worker | grok-4.6 |
| Independent checker | GPT-6 (this package; pending) |
| Official-r1 Fable | NO_VERDICT: `Prompt is too long` (3,432,047-byte bundle) |

Machine-readable identity: `identity.json` (no invocation timestamp). One-time prepare metadata: `invocation.json` (not rewritten). Status: `STATUS.json`. Report: `REPORT.md`. Checker: `package.py`.

## Original-plan GPT-6 review (not this package)

Independent nonauthor GPT-6 original-plan review is **ACCEPT WITH LIMITATIONS** with **no required mathematical fixes**. That verdict does not accept this recovered package and does not close the planning gate.

Three advisory notes, bound as implementation dispositions:

1. **One-mutant SPEC invocations.** Inherited `scripts/run_interface_mutations.py` has one global `positive_checks` list. `nary.routing.locals` is required false for M01 and protected for M04/M05/M06/M09/M11/M12. `nary.monitor.actual_producer` is required false for M13 and protected for M15. Production evidence is sixteen separate one-mutant SPECs. See `mutation-batching.json` and `appendices/D-mutation-specs/`.
2. **F05 catalog-valid parameterized producer.** `Component.portIds` is component-wide unique. Two producer interfaces cannot share one output port. Expected collision values 6/2 are unchanged.
3. **Honest timeout evidence.** The unchanged runner writes child stdout/stderr only after `subprocess.run` returns. `TimeoutExpired` bypasses that write. Outer invocation records are required. Do not claim complete partial child logs from a BLOCKED line.

Full original-plan review: `original-plan-review/gpt6-original-plan-review-r1.md` (SHA-256 `348f4c0b32b989ee12e3cd402030f00b36ea884cff5527415612ad44fddbbbbd`).

## Reading order

1. This entrypoint, `identity.json`, `findings.json`, `STATUS.json`, `REPORT.md`, `ANCHOR.json`.
2. Original-plan review and `original-plan-review/advisory-notes.json`.
3. `source-inventory.json` (union of cited inventories: 154 official-r1 inputs, 11 baseline_references, accepted APIs, cited docs). `mutation-batching.json` and sixteen files in `appendices/D-mutation-specs/`.
4. Complete normative change under `openspec/changes/finite-participant-causal-composition/` (hashes in `appendices/A-normative-map.json` and `before/`).
5. Dependency hashes in `appendices/B-dependency-index.json`, including `baseline_references`. Proposed Nary API remains proposed.
6. Historical identities in `appendices/C-historical-evidence.json`. Unchanged official-r1 input paths keep their original hashes. Changed plan files and `AGENTS.md` have current bindings plus original-byte snapshots (`before/` and `original-official-bytes/AGENTS.md`). Do not ingest `official-r1/bundle.md` as a prompt.
7. Cited docs including `docs/superpowers/specs/2026-09-06-semantic-kernel-design.md`, `formal/v3/GATE-REGISTER.md`, `.claude/skills/defi-footguns/SKILL.md`.

The defective self-hashing checker is preserved at `attempt-defective-checker-r1/` (SHA-256 `4507692c99a169783615b80b267357b495bf8b3fd698b0039abb6fa05b7bfec5`). It is not this sealed checker.

## What this package is not

- Not Nary Lean implementation.
- Not production mutation or 65-control execution.
- Not a Lean/financial regression rerun.
- Not planning-gate acceptance.
- Not a replacement of official-r1 artifacts.
