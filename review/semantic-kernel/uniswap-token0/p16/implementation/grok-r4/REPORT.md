# P16 r4 source/EVM/mutant repair — native Grok 4.6

**Status: pending independent GPT-6 review. Not P16 acceptance. Not proof acceptance. Not source refinement. Not self-accepted.**

Native Grok 4.6 (`grok-4.6-build`) repaired the rejected r3 source campaign. Independent checker is GPT-6, not run in this session. No Foreman, subagents, commit, or push.

Rejected r3 archive SHA-256 `95051fd2f33381231740c49d151551d65be4177a72ddb228ca6874962379326c` remains unreadited historical evidence. Its full evidence tree and the 197 accepted r2 files (nine Lean sources and five original scripts) were not rewritten. This batch edits only the five source-campaign modules and adds `grok-r4/` controls and a new intact campaign.

## R1 and R2 as sealed

Sealed primary review: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p16-source-r3-review/REVIEW.md`, verdict `CHANGES_REQUIRED`.

R1: missing/stale/unknown-stdout/crash-partial scored false 6/6; malformed receipt exited 1 uncaught; timeout scored fail 1. Consumer treated empty receipts as semantic exceptions and crash stdout as revert.

R2: omitting `P16-I-REM` scored 11/11 exit 0; Lean `match=false` still exited 0 because `#eval` prints a UInt32 and `lake env lean` can exit 0.

## Production repairs (five modules)

`p16_common.py` validates current receipts before any observation: schema, wrapper/child status, argv/cwd, start time, stdout/stderr hashes. Missing, malformed, stale, crash, cancel, and timeout evidence are blocked 3. Fixtures require the exact twelve IDs, uniqueness, JSON booleans, width-checked decimals, and an unambiguous `ok` or `error` object.

`p16_evm.py` classifies only a completed pinned EVM run. Success requires a 32-byte ABI uint160 word. STOP smoke is `stop_smoke` for genesis and `unknown_output` for token0. Crash partial revert text is not a semantic revert. Named `evm_exception` vs `evm_revert` is not relaxed.

`p16_compile.py` bounds solc with a process-group timeout and writes `solc-receipt.json`. Compiler failure remains blocked 3.

`source_campaign.py` generates Lean rows from stored fixtures, parses complete RuntimeAudit (22 ids) and binding lines (ids, inputs, model results, truth, 12 of 12), and propagates blocked designated/unaffected/equality observations into mutant and overall scores. Printed `#eval` UInt32 is recorded, not treated as a process exit.

`p16_mutants.py` is unchanged (SHA-256 `874cb46e22a1d67772721ebe1505260af765b292de96319167553f840ff0b360`).

Frozen `record_cmd.py` / `Token0Probe.sol` / nine ConcentratedLiquidity Lean files: 0 mismatches against the r2 manifest (197 files).

## Intact campaign

Host command `python3 -B scripts/token0_p16/source_campaign.py --mode intact --evidence grok-r4` elapsed 4.63s, process exit 0. Authoritative score: `campaign-score.json` (SHA-256 `0c778223bf42084eca1f81856c27557fa01eef66e7c242e2a0f1387b93712448`) plus per-invocation receipts.

| Item | Result |
| --- | --- |
| baseline | 12/12 exit 0 |
| compiled mutants | 6/6 exit 0 |
| RuntimeAudit | 22 rows, 12 P16 true, exit 0 |
| Lean bindings | 12/12 match=true, printed UInt32 0, wrapper 0, child 0 |
| selector | compiler `6c84a8a2` |
| creation bytecode | `74306c39f38934e603ee0beb9e4989025c08dd17b8383a209231c3d287f52182` |
| runtime bytecode | `07f36245480430411ce6a9afe829520f63ffd9a9af7fd7cac52f133d75c6f580` |
| genesis | `1a70be555705a08e5422705322b45fd716a81989af2c5830fbfcffc963b01be4`, STOP class `stop_smoke` |

The first r4 Lean binder compile exited 1 (`unexpected token ':='`). That attempt is preserved under `lean/failed-attempts/bindings-attempt1`. The later binding run is the scored one. Historical r3 binder exit 1 remains in grok-r3.

## Focused controls (real consumer path)

| Control | Exit | Notes |
| --- | --- | --- |
| intact 12+6 | 0 | nonempty score |
| mismatch P16-ADD vs 0 | 1 | real observation |
| malformed fixtures.json | 3 | real loader, was 1 |
| empty selection | 3 | denominator 0 |
| missing solc | 3 | blocked_missing_compiler |
| fixture omission of P16-I-REM | 3 | full campaign and loader |
| fixture `add: "true"` | 3 | not a JSON boolean |
| extra fixture id | 3 | |
| child 0/1/3 | wrapper matches child | receipts retained |
| timeout descendant | 3, classification `timeout_blocked` | outsider PID still alive |
| missing-receipt campaign | 3 | mutants 5/0/1 blocked |
| unknown-stdout campaign | 3 | |
| stale-receipt campaign | 3 | |
| crash-partial campaign | 3 | child -9, not revert credit |
| malformed-receipt campaign | 3 | no uncaught exception |
| timeout campaign | 3 | was fail 1 |
| lean-false campaign | 1 | wrapper 0, child 0, printed 1, `match=false` on P16-ADD |
| lean-text false/missing/dup/malformed | 1,3,3,3 then 1,3,3,3 | RuntimeAudit then bindings |

Hardcoded W16 / primary evidence / private tool-cache paths remain a known replay limit. This repair does not widen into the P30 platform harness.

## M09 and remainders

M09 stays model-side Lean SwapMath: F28 excluded, F31 designated, F32 protected only under the model's earlier invalidFee guard. No Solidity F32-control claim. P17, P21, original mixed liquidity 1.2, and P30/source-assembly remain open.

Compile/source/model observations are separate from proof and source-refinement claims.

## What this is not

Not self-acceptance. Not source-gate acceptance. Not operation credit. Not independently accepted proof scope. Not source/assembly refinement. Not compiled M09. Root integrates accepted exact bytes to `semantic-kernel-pivot` only after review.
