# Sprint11 grok-gpt6-r1 planning package report

Package worker: native Grok 4.6. Independent checker: GPT-6. This report does not accept the planning gate.

## Status

Recovered hashed-local planning package is ready for independent GPT-6 review of **this package**. Planning gate is not accepted. Implementation task boxes remain unchecked. Nary Lean was not implemented.

Isolated baseline HEAD is `ed94e6050d092e67f945df7b9762d3096ab0feda`. Prior official candidate is `b85c14af7be6e01340a93dcb00b7bad8a10c11ae`. Accepted M2 source remains `b165bc586080d668f689fbc18dfa09eb8739d688`.

## Exact review entrypoint

Read `review/semantic-kernel/sprint11/planning/grok-gpt6-r1/ENTRYPOINT.md`.

Reviewer command (writes no files):

```
python3 review/semantic-kernel/sprint11/planning/grok-gpt6-r1/package.py --check
```

Hash `MANIFEST.json` independently and compare to `ANCHOR.json` field `manifest_sha256`. `MANIFEST.json` does not contain its own hash.

## Historical Fable failure

Official-r1 native Fable 5.1 medium at candidate `b85c14af` returned `Prompt is too long`. Bundle SHA-256 `bac3172259ac20d5da8c6c1085d625f7a56b49753c42ec8a7a232fe1f993b3cc`, 3,432,047 bytes. Verdict remains NO_VERDICT. Those artifacts were not rewritten.

## Original-plan GPT-6 review

Independent nonauthor GPT-6 original-plan review is ACCEPT WITH LIMITATIONS with no required mathematical fixes. Report SHA-256 `348f4c0b32b989ee12e3cd402030f00b36ea884cff5527415612ad44fddbbbbd`. That verdict does not accept this recovered package.

Three advisory notes remain bound: one-mutant SPECs, F05 parameterized producer, timeout honesty. See `original-plan-review/advisory-notes.json`.

## Checker defects found, then fixed

The self-hashing checker SHA-256 `4507692c99a169783615b80b267357b495bf8b3fd698b0039abb6fa05b7bfec5` is preserved under `attempt-defective-checker-r1/`. Targeted GPT-6 review of later `package.py` `c2f10b50313141b8c7b58659db8c49ca45e1dbd8d38c1d84bb0c6092e6236ee0` required two remaining blockers. Those are fixed in the current checker. A failed copy_bound control attempt is noted in `attempt-copy-bound-r2/`.

Fixes now in force:

1. Read-only `--check` uses stored hashes. `copy_bound` copies the union of source-inventory paths and MANIFEST files, plus inventory, manifest and anchor. Inventory is not a self-row.
2. Exact ID and path sets, plus complete cited-source closure: 154 official-r1 inputs, 11 `baseline_references`, accepted APIs, runtime modules, and cited docs including the approved semantic-kernel design. Expected paths are the union of those declared inventories, not a tautological copy of freshly hashed rows.
3. Unchanged official-r1 input paths keep their original hashes. The nine current-binding paths (eight plan files plus `AGENTS.md`) have current hashes plus original-byte snapshots (`before/` and `original-official-bytes/AGENTS.md`). Old evidence is not relabelled fresh.
4. Negative controls are real `python3 package.py --check --root COPY --package COPY/...` subprocesses on temporary copies. Cited-source removal and baseline-reference tampering use the same entrypoint. The real repo is not mutated for those controls.
5. Deterministic derived artifacts are separate from `invocation.json`. OpenSpec strict must emit exactly `Change 'finite-participant-causal-composition' is valid\n`.

## Scope of this package

Source author of the M3 plan: stock GPT-6 agent Hegel. Package worker: grok-4.6. User role override 2026-09-07: have Grok 4.6 do this work and have GPT 6 check. Historical AGENTS.md reviewer instructions are preserved.

Normative edits remain limited to `openspec/changes/finite-participant-causal-composition` plus `AGENTS.md`. Original 15 plan files are in `before/`. Official-r1, Lean sources, Lake config, corpus and root ledgers were not edited. Proposed Nary API remains proposed. `lean/DefiKernel/Nary` does not exist.

All 16 mutation needles, replacements, oracles and protected checks remain. All 19 fixture IDs remain. All 52 scenarios remain. All 35 tasks remain unchecked.

## Validation

Fresh package checks. Old 115/115 `--validate` result is the defective self-hashing attempt, not this result.

Two prepares from the same frozen inputs: 23 declared deterministic files identical; `invocation.json` frozen on the second prepare (`validation/reproducible.json`). First invocation UTC `2026-09-08T01:24:06.372759+00:00` was preserved.

Read-only `--check` on the sealed tree: status PASS, `gate_accepted` false. Denominators: 205 source-inventory rows, 154 official-r1 inputs (145 unchanged original hashes, 9 current bindings with original-byte snapshots), 11 baseline_references, 15 appendix A files, 16 mutation specs using stored `inv.sha256`, 6 official-r1 artifacts, 19 fixtures, 65 controls, 19 requirements, 52 scenarios, 35 unchecked tasks.

OpenSpec: `/home/charl/.local/bin/openspec` SHA-256 `ca136f0e9fd4951dcf93d8ed729ebc97b2d97d3980cd9dc9d42fc80e32e797c6`, version `1.10.0`. Command `openspec validate finite-participant-causal-composition --strict --no-interactive` exit 0, stdout exactly `Change 'finite-participant-causal-composition' is valid\n` (56 bytes).

External subprocess `--check` on temporary copies (same entrypoint; real repo not mutated):

| Case | Exit | Expected | Notes |
| --- | --- | --- | --- |
| valid-unchanged-sibling | 0 | 0 | intact copy |
| missing-source | 3 | 3 | deleted `proposed-api.json` |
| changed-bytes | 1 | 1 | appended byte to `proposed-api.json` |
| changed-spec | 1 | 1 | appended byte to `M01.json` |
| changed-appendix | 1 | 1 | mutated appendix A note |
| empty-inventory | 3 | 3 | `rows: []` |
| duplicate-inventory | 1 | 1 | duplicated first row |
| omitted-inventory | 1 | 1 | dropped a declared plan path |
| missing-cited-design | 3 | 3 | deleted approved semantic-kernel design |
| changed-baseline-reference | 1 | 1 | appended byte to `sprint10/delivery.json` |

`all_matched` true. Complete command argv, stdout and stderr are under `validation/controls/`. Missing cited design blocked with `source-inventory: missing 1 of 205: ['docs/superpowers/specs/2026-09-06-semantic-kernel-design.md']`. Baseline tamper failed with stored-hash mismatch on `review/semantic-kernel/sprint10/delivery.json`.

Python 3.14.4 `/usr/bin/python3`. Trust anchor: `ANCHOR.json` (MANIFEST is not self-hashed).

This package still needs independent GPT-6 review. Gate accepted is false.

## Open questions

- Independent GPT-6 review of this recovered package remains pending.
- Later Fable retry, if any, should use this hashed-local package rather than the 3.4MB inlined bundle.
- Implementation must still elaborate the proposed Nary API, run sixteen one-mutant SPECs, and keep timeout evidence honest.
