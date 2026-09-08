# Sprint11 funded-enabledness-r2

Requested worker: `grok-4.6`. Reported worker: `Grok 4.6`. Checker assigned: independent GPT-6 (not executed here). No Foreman. No commit, push, archive, or self-acceptance.

Head: `ed94e6050d092e67f945df7b9762d3096ab0feda`.  
Private cwd: `/home/charl/.cache/defiformal-sprint11-builds/proof`.  
Lean: `4.33.0-rc2` (`d8b18978322de05a8f3dba51ef03cf5461676c17`).  
Lake: `5.0.0-src+d8b1897`.  
Toolchain binaries: lean `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`, lake `60330ab6f07dce20f3fa9ebb08e8b984ea9549eac172afeb15d9d2227060e2b3`.

Owned file: `lean/DefiKernel/Nary/FundedEnabledness.lean`  
SHA-256 `98eccaec1a755d5758d1b88fcb5e0f18e6a35d327ee990beb1094b22bc90f0b7` (34369 bytes).  
Unchanged from the r1 final compiled source. This round did not weaken proofs or edit frozen Nary files. Namespace `DefiKernel.Nary.FundedEnabledness`. Does not import `FundedCausal`.

## r1 limitation (preserved, not rewritten)

Root outer timeout 2400s stopped r1 at **exit 124** after the four lemmas already compiled. Native-worker record `funded-enabledness-r1.json`: `end_event_present: false`, `actual_model_keys: []`, so r1 has **no completed model telemetry**. r1 evidence under `implementation/funded-enabledness-r1/` was left intact. r1 last successful probes: `32-deposits`, `33-final-sync`, `34-lake-env-lean`, `35-print-axioms` (six theorems only), `36-cache-lean-version`, `37-cache-which-lean`. 24 r1 lake-build probes failed before those (consumer `numericRat`/`List.mapM`/`Args` transparency, then deposit effect orientation). Index: `hashes/r1-probe-status-index.json`.

## r2 compile (fresh, this directory)

| Command | Cwd | Exit |
| --- | --- | --- |
| `rsync -a --delete --exclude .lake --exclude .git lean/ → proof cache` | worktree | **0** |
| `lake build DefiKernel.Nary.FundedEnabledness` | proof cache | **0**, 940 jobs, “Build completed successfully” |
| `lake env lean DefiKernel/Nary/FundedEnabledness.lean` | proof cache | **0** (linter warnings on stdout, same class as r1) |
| `lake env lean print-axioms.lean` (all 99 theorems) | proof cache | **0**, 99 axiom lines |

Repository `.lake`, fixture cache, causal cache, and `lake build all` were not used. Worktree, private-cache, and r2 snapshot hashes match.

Source scan of the owned file: `sorry=0`, `native_decide=0`, `axiom` declarations `0`, `admit=0`, one `-- BEGIN PROOFS`. 99 theorems, 16 defs.

`#print axioms` of the four enabledness lemmas: `propext`, `Classical.choice`, `Quot.sound`. Full 99-theorem inventory in `statements.json` / `hashes/print-axioms.txt`. Those three are kernel/Mathlib axioms, not custom module axioms.

## Four actual F10 enabledness lemmas

Reusable `∃ result, executeStep = .ok result` under current store/history/funding, not a whole-run fact:

1. `f10_producer_enabled` — vault participant index 0, empty history, `budgetC = 6` → `rec200`, `[budgetOut 0]`, all balances unchanged.
2. `f10_consumer_enabled` — vault participant index 1, history `[budgetOut 0]`, `vault ≥ 6` → `rec201`, `[]`, vault `−6`, recipient `+6`.
3. `f10_deposit1_enabled` — donor1 index 0, empty history, `donor1 ≥ 1` → `rec202`, `[]`, donor1 `−1`, vault `+1`.
4. `f10_deposit2_enabled` — donor2 index 0, empty history, `donor2 ≥ 2` → `rec203`, `[]`, donor2 `−2`, vault `+2`.

Exact signatures and remaining helpers: `api-handoff.md`.

## Remaining outside this lane

Independent GPT-6 check of this package. FundedCausal generic whole-run K and complete-schedule proof. Imported axiom inventory of the kernel as a whole. `lake build all`. 16 production mutants. Sprint11 acceptance.

This report is not self-acceptance.
