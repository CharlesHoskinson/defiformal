# P31 supplemental runnable-source preparation independent review

**Decision: the two supplements are usable bounded source-and-runtime preparation. They accurately close the earlier missing frontend/bounds capture and the unobserved Compact addition-cast gap for the scope they state. They are not accepted readiness, not adapters, not P31, and not proofs.**

This is a fresh native Grok 4.6 high audit of frozen sandbox `/home/charl/.cache/defiformal-program/program-execution-20260908/p31-runtime-preparation-grok-r1-sandbox` only. Writable copies and replay output stayed under `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p31-runtime-preparation-grok-r1`. Live AGY R13 author/code/cache was not read. Frozen inputs were not modified. No network, subagents, Foreman, production edits, branches, commits, or pushes. No Lean, K, lake, or Compact recompile. Prior source-readiness audit remains a review of its original 13 files. Root independently verified R12 codec review already; this task reviews only these two P31 supplements.

Root captures the actual returned model as Grok 4.6 (`requested_model` in dispatch is `grok-4.6`) and independently adjudicates.

## Identities

Source pin: `7307349d0275af6fcb4144e1661d8b59d6b2663a`.

`inputs.json` declares 73 frozen files. All 73 SHA-256 values match sandbox bytes. No extra sandbox files. Manifest `acceptance` is false on both supplements. Brief SHA-256 matches dispatch: `559b085ee916ee611d15597c7953ba24da23e50fc6bd2981c4ce31533660cdfb`.

The 20 static-closure source files match manifest SHA-256, byte length, and Git blob SHA-1 recomputed as `sha1("blob " + len + NUL + bytes)` from frozen bytes. The three example files (`simulate.mjs`, `loan.mori`, `swap.mori`) match `example-inputs.json` the same way. Live `git show` against `/home/charl/Moriarty` was not repeated. Original-13 hashes are unchanged from the prior source-readiness pin.

Node binary `/home/charl/.foreman/tools/fnm/node-versions/v24.18.1/installation/bin/node` SHA-256 `f3432a45b03b2da0d270095fdd8813dc34cbea73f5fc8b18c7a384b7cf9b333a` matches both receipts. Compact compiler binary and launcher hashes match `runtime-receipt.json` / `tool-inputs.json` / `compile-receipt.json`. Isolated scanner TypeScript 5.9.3 library hash matches `manifest.json`.

## p31-source-closure

The static pin is the original 13 roots plus `frontend.ts`, `registered-bounds.ts`, `parser.ts`, `checker.ts`, `validate.ts`, `diagnostics.ts`, and `spec/bounds.json`. TypeScript AST inspection records 40 edges: 37 pinned relative targets that exist in the pin, and 3 `node:` host dependencies (`fs`, `crypto`, `util`). Unresolved edges: none in the inspected forms.

That is the compile/bounds closure the prior audit named as missing. `evaluate.ts` and `lower-compact.ts` now import pinned `frontend.ts`. `evaluate.ts` also imports pinned `registered-bounds.ts`, which binds `bounds.json` through a literal `new URL('../spec/bounds.json', import.meta.url)` and `node:fs`. The scanner does not claim all runtime filesystem access is closed. `simulate.mjs` is not one of the 20 AST roots; `example-inputs.json` separately binds that exact upstream example and its two enumerated dynamic paths.

Attempt 1 failed before scanning because global TypeScript 7.0.2 does not expose the legacy 5.x AST path. `attempt1/` keeps the original scripts, `failure.json` (`semantic_execution: false`), and partial source (`LICENSE`, `types.ts` only). No scanner failure receives proof or execution credit. The successful scanner uses isolated TypeScript 5.9.3 from `scanner-package-lock.json`, `--ignore-scripts`, and does not modify the global compiler. `capture.py` uses `source.mkdir(exist_ok=False)` and was not rerun.

The unchanged example was replayed under the absolute Node 24.18.1 binary from the frozen `simulate.mjs`. Four actions returned `Simulation`. Adverse controls refused with `EXACT_PLAN_MISMATCH` (loan accrue/settle), `GUARD_FAILED` (swap), and `PRINCIPAL_BINDING` (close). All four `evaluate` calls without a backend refused with `PROOF_INVALID`. Loan settle closes the episode and leaves agreement `Outstanding`. Replay stdout is byte-identical to the captured file (`6cc901fb87248a40d1331ae7b9307a18bbe530b381726563789daff183aa887d`). Replay stderr is a 166-byte Node warning that `NO_COLOR` is ignored because `FORCE_COLOR` is set in this harness; captured stderr was empty. That is an environment warning, not a change to simulation results.

This is two bounded local simulation examples. It is not ledger settlement, accepted proof consumption, Compact compiler arithmetic, Lean/K correspondence, or a DeFiKernel adapter.

## p31-compact-add-diagnostic

Frozen `arithmetic.compact` SHA-256 is `b2969d0bc346fa93d88546578c9f9d29f1b74d7bc3f88f2e04709fa0932d9415`, matching the source-closure pin. `compile-receipt.json` records Compact 0.31.1 / language 0.23.0 / runtime 0.16.0 and `--skip-zk`. `execve.log` binds launcher `/home/charl/.local/bin/compact` then `/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl/compactc.bin` with exit 0. Current binaries still have those SHA-256 values. Generated `compiler/contract-info.json` repeats the same three versions. All four exported circuits are `pure: true` and `proof: false`.

Generated `_checkedAdd_0` adds then rejects sums above `2^128-1` with `CompactError` at the narrowing cast (`arithmetic.compact line 14 char 10`). The compiled tree contains exactly four files: `contract-info.json`, `index.js`, `index.d.ts`, `index.js.map`. No `.prover`, `.verifier`, `.zkey`, or ZKIR artifacts. `compiled-manifest.json` sets `keys_generated`, `proofs_generated`, and `zkir_artifacts_present` false.

Private replay copied those four generated files and `probe.mjs` into `replay/compact-add/`, byte-verified the copies, and symlinked `node_modules` to read-only `/home/charl/.cache/defiformal-program/program-execution-20260908/p31-compact-runtime-tool/node_modules`. Sample runtime package bytes match `tool-inputs.json`. Unchanged `probe.mjs` under the same Node binary exited 0. Five `pureCircuits.checkedAdd` calls passed: `0+0`, `max+0`, `(max-1)+1` returned exact sums; `max+1` and `max+max` threw `CompactError` at the cast. Replay stdout is byte-identical to the captured file (`2ef2229921535d031ea72a77d934ddaae6fc1284f85dd94de885b4f66867ae9c`). Frozen sandbox and root package files were not mutated. Compact was not recompiled.

This is bounded runtime evidence for addition-cast overflow-reject at this compiler/runtime pin. It does not establish universal arithmetic, ZKIR constraints, correspondence with `evaluate.ts` `checkedUInt128`, ledger settlement, or an adapter.

## What these supplements resolve

The prior source-readiness audit recorded two implementation-prep gaps inside its 13-file scope: unpinned `frontend.ts` / `registered-bounds.ts` (and their compile closure), and unobserved Compact `checkedAdd` wrap-versus-reject. For the stated bounds, both gaps are now filled with hashed source, tool, probe, and output identity.

They do not accept readiness tasks 32.1–32.8, adapters, full P31/P19/P20, or the program. Full remaining pipeline and P20-dependent certificate consumption remain open.

## Unsupported claims

None found inside the stated bounds. The records keep `acceptance` false and do not relabel Outstanding agreement as settled ledger. Attempt 1 is preserved at zero credit.

## Precise remaining gaps

These are already explicit in the supplements. They are not new gates.

1. Static AST closure does not prove all runtime filesystem or host access is closed.
2. Two local simulation examples are not accepted backends, proofs, or correspondence.
3. Five `checkedAdd` calls are not universal Compact arithmetic or ZKIR soundness.
4. Choose one adapter profile: bounded-atomic `evaluate`, `FundedCore` types, or `prepareRepayment`.
5. `numeric-profile.json` remains proposed-not-frozen.
6. Retained K is still a two-balance projection, not full `prepareRepayment`.
7. Implement and verify adapters 32.5–32.8 against this pin. Missing Lean is the next phase.
8. Complete accepted P20 before PCT certificate consumption.
9. P31 and whole-program acceptance remain false.
