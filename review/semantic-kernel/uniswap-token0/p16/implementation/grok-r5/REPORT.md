# P16 r5 source-campaign consumer repair — native Grok 4.6

**Status: pending independent GPT-6 review. Not P16 acceptance. Not proof acceptance. Not source refinement. Not self-accepted.**

Native Grok 4.6 (`grok-4.6-build`) repaired the remaining sealed r4 R1/R2 residuals. Independent checker is GPT-6, not run in this session. No Foreman, subagents, commit, or push.

Sealed r4 review: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p16-source-r4-review/REVIEW.md`, SHA-256 `cf6be9a061902773bc1c3c09ce9c18f7d6e94f744f17e18e9163e8688c8416c0`. Manifest SHA-256 `975375a766309271e093995e017f6f86c9ea0d539e3b9aa64babab5d06cf7cf4`. Rejected r4 archive SHA-256 `b5a344f2db9f73dfe4d6a0aa17e46985cdb49cc431740a6312274561c82c6221`. Verdict `CHANGES_REQUIRED`. Only final R1/R2 were required.

All 197 accepted r2 files still match the frozen proof/recorder manifest (0 mismatches). grok-r3 and grok-r4 evidence trees were not rewritten. Frozen `record_cmd.py` and Lean proofs were not edited. `p16_compile.py` and `p16_mutants.py` are unchanged.

## R1 remaining — successful execution and recognized EVM syntax

`invocation_is_complete` still means a finished ordinary process. Semantic scoring now requires `invocation_is_successful`: child 0, wrapper 0, classification `ok`, and no timeout/cancel/crash. `validate_receipt` rejects classification/exit inconsistency. `score_lean_execution` does not treat parsed protocol rows as success after a genuine compiler failure.

Pinned EVM grammar now accepts only documented forms: ABI uint160 success, `error: execution reverted`, `error: invalid opcode: INVALID`, and separate STOP smoke. Unknown error text, missing required payload, duplicate/extra protocol lines, and invented empty exception payloads block 3.

## R2 remaining — complete protocol, no silent skip

`parse_lean_bindings` and `parse_runtime_audit` consume the full relevant protocol. Documented Lake/compiler wrappers are allowed. Malformed, unknown, duplicate, or extra protocol-prefixed records block 3. A well-formed false comparison with compiler 0 remains fail 1.

## Intact campaign

Host command `python3 -B scripts/token0_p16/source_campaign.py --mode intact --evidence grok-r5` elapsed 5.35s, process exit 0. Authoritative score: `campaign-score.json` (SHA-256 `0c778223bf42084eca1f81856c27557fa01eef66e7c242e2a0f1387b93712448`) plus per-invocation receipts.

| Item | Result |
| --- | --- |
| baseline | 12/12 exit 0 |
| compiled mutants | 6/6 exit 0 |
| RuntimeAudit | 22 rows, 12 P16 true, exit 0 |
| Lean bindings | 12/12 match=true, printed UInt32 0, wrapper 0, child 0, classification ok |
| selector | compiler `6c84a8a2` |
| creation bytecode | `74306c39f38934e603ee0beb9e4989025c08dd17b8383a209231c3d287f52182` |
| runtime bytecode | `07f36245480430411ce6a9afe829520f63ffd9a9af7fd7cac52f133d75c6f580` |
| genesis | `1a70be555705a08e5422705322b45fd716a81989af2c5830fbfcffc963b01be4`, STOP class `stop_smoke` |

Seven baseline/mutant compiler identities match the retained r4 bytecode hashes. Identity-skip still classifies `error: invalid opcode: INVALID`. Ordinary ADD controls remain 39614081257132168796771975168.

## Focused controls that discriminate r4

Parser/scorer before (r4 consumers): extra protocol rows scored 0; compiler-nonzero after valid `#eval` rows scored 0; unknown error text scored as `evm_exception` with invented `0x`; classification `failure` with child 0 scored 0. After repair, those cases block 3. Semantic false with compiler 0 stays fail 1. Revert, INVALID, and STOP smoke are unchanged.

| Control | Exit | Notes |
| --- | --- | --- |
| intact 12+6 | 0 | nonempty score |
| mismatch P16-ADD vs 0 | 1 | real observation |
| malformed fixtures.json | 3 | real loader |
| empty selection | 3 | denominator 0 |
| missing solc | 3 | blocked_missing_compiler |
| fixture omission/type/extra | 3 | |
| recorder child 0/1/3 + timeout | 0 | outsider remains alive |
| lean-text including extra-row and EVM grammar | 0 | expected `[1,3,3,3,1,3,3,3,3,3,0,3,1,3,0,0,0,3]` |
| compiler-nonzero `#check P16ReviewNonexistentDeclaration` | 3 | genuine Lean child 1 / wrapper 1 / classification failure; not semantic 0 |
| malformed-extra genuine `#eval` extra P16 row | 3 | compiler 0; extra protocol blocked |
| runtime-extra appended protocol row | 3 | RuntimeAudit blocked through real consumer |
| wrong-status relay (classification failure, child 0/wrapper 0) | 3 | mutants 5 ok / 0 fail / 1 blocked |
| unknown-error-output `error: unrecognized diagnostic failure` | 3 | blocked `unknown_output`, not exception credit |
| lean-false | 1 | wrapper 0, child 0, printed 1, `match=false` on P16-ADD |

Receipt relays first perform a genuine frozen-recorder run, then apply the sealed post-record mutation. That tests parsing of invalid output, not tool authenticity. Reviewer probe provenance is retained in `controls/receipt_fault_relay.py`.

Hardcoded W16 / primary evidence / private tool-cache paths remain a known replay limit. This repair does not widen into P17, P21, P30, certificate infrastructure, or full library proofs. P18 packet/example publication follows accepted P16 and is not made a prerequisite.

## M09 and remainders

M09 stays model-side Lean SwapMath: F28 excluded, F31 designated, F32 protected only under the model's earlier invalidFee guard. No Solidity F32-control claim. Original mixed liquidity 1.2 remains open.

Compile/source/model observations are separate from proof and source-refinement claims.

## What this is not

Not self-acceptance. Not source-gate acceptance. Not operation credit. Not independently accepted proof scope. Not source/assembly refinement. Not compiled M09. Root integrates accepted exact bytes to `semantic-kernel-pivot` only after review.
