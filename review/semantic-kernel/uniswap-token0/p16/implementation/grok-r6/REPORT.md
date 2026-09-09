# P16 r6 source-campaign consumer repair — native Grok 4.6

**Status: pending independent GPT-6 review. Not P16 acceptance. Not proof acceptance. Not source refinement. Not self-accepted.**

Native Grok 4.6 repaired the remaining sealed r5 R1: `p16_evm.py` accepted multiple explicit empty `0x` payload lines before a recognized EVM error. Independent checker is GPT-6, not run in this session. No Foreman, subagents, commit, or push.

Sealed r5 review: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p16-source-r5-review/REVIEW.md`. Rejected r5 archive SHA-256 `235e9a0f0aaf18342bc3d99bcb1fa13723e6144dfcc47e8523fc11d8b0da4f7a` (root frozen, unreadited). Verdict `CHANGES_REQUIRED`. Only this R1 remainder was required. R2 was not reopened.

All 197 accepted r2 files still match the frozen proof/recorder manifest (0 mismatches). grok-r3, grok-r4 and grok-r5 evidence trees were not rewritten. Frozen `record_cmd.py` and Lean proofs were not edited. `p16_common.py`, `source_campaign.py`, `p16_compile.py` and `p16_mutants.py` are unchanged.

## R1 remaining — duplicate explicit empty payloads

`classify_evm_stdout` already bounded ABI words and error lines. It collected explicit `0x` records but did not bound their count before known-error classification. The sealed r5 consumer therefore credited:

```text
0x
0x
error: invalid opcode: INVALID
```

as `evm_exception`. The same cardinality hole accepted duplicate `0x` before `error: execution reverted`.

Repair: after the existing duplicate-error check, reject `len(empty_hex) > 1` as `unknown_output` with reason `duplicate empty EVM payload records are ambiguous protocol output`. At most one explicit empty payload may precede error classification. Zero explicit empties (pinned runner blank first returndata) and one explicit empty remain recognized.

## Before reproduction (new grok-r6 paths)

Parser probe `logs/grammar-boundaries-before.json` classified duplicate-empty INVALID as `evm_exception` and duplicate-empty revert as `evm_revert`. Blank-first and one-explicit-empty forms were already recognized.

Full-campaign relays used the sealed method: genuine frozen-recorder EVM invocation, then receipt-consistent replacement of designated stdout plus byte count/hash. Destinations are new:

| Control | Exit | Score |
| --- | --- | --- |
| `controls/duplicate-empty-invalid-before` | 0 | baseline 12/12, mutants 6/6 |
| `controls/duplicate-empty-revert-before` | 0 | baseline 12/12, mutants 6/6 |

Injected stdout hashes match the receipts. Diagnostic corruption is not a production mutant. These before-repair campaigns are retained under `failed-attempts/`.

A first CLI `mismatch` batch also exited 3 because intact `P16-ADD` did not yet exist. That failed attempt is preserved; the post-intact retry exits 1.

## After repair

Parser probe `logs/grammar-boundaries-after.json`: duplicate-empty INVALID and revert are `unknown_output` / blocked. Blank-first revert/INVALID, one explicit empty revert/INVALID, STOP blank and STOP one-`0x` are unchanged. Duplicate ABI, duplicate error, extra text and unknown error text still block.

| Control | Exit | Notes |
| --- | --- | --- |
| duplicate-empty INVALID campaign | 3 | mutants 5 ok / 0 fail / 1 blocked |
| duplicate-empty revert campaign | 3 | baseline 11 ok / 0 fail / 1 blocked |
| intact 12+6 | 0 | nonempty score |
| mismatch P16-ADD vs 0 | 1 | real observation after intact |
| malformed fixtures.json | 3 | real loader |
| empty selection | 3 | denominator 0 |
| missing solc | 3 | blocked_missing_compiler |
| fixture omission/type/extra | 3 | |
| recorder child 0/1/3 + timeout | 0 | outsider remains alive |
| lean-text | 0 | expected `[1,3,3,3,1,3,3,3,3,3,0,3,1,3,0,0,0,3]` |
| compiler-nonzero `#check P16ReviewNonexistentDeclaration` | 3 | genuine Lean child 1 / wrapper 1 |
| malformed-extra genuine extra P16 row | 3 | compiler 0; extra protocol blocked |
| runtime-extra appended protocol row | 3 | RuntimeAudit blocked |
| wrong-status relay | 3 | classification failure with child 0 |
| unknown-error-output | 3 | blocked `unknown_output` |
| lean-false | 1 | wrapper 0, child 0, printed 1, compiler 0 |

Receipt relays first perform a genuine frozen-recorder run, then apply the declared post-record mutation. That tests parsing of invalid output, not tool authenticity.

## Intact campaign

Host command `python3 -B scripts/token0_p16/source_campaign.py --mode intact --evidence grok-r6` from `2026-09-09T15:52:45.664078+00:00` to `2026-09-09T15:52:49.834015+00:00`, process exit 0. Authoritative score: `campaign-score.json` (SHA-256 `0c778223bf42084eca1f81856c27557fa01eef66e7c242e2a0f1387b93712448`) plus per-invocation receipts.

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

Seven baseline/mutant compiler identities match the retained r5 bytecode hashes. Identity-skip still classifies `error: invalid opcode: INVALID` from pinned blank first returndata SHA-256 `ed62e5fdb38a3bd78cbf7708853efa379d7f93fea26b908a9da36c6d9cb640bd`. Ordinary ADD remains 39614081257132168796771975168. Genuine P16-REQ remains `evm_revert` from pinned blank first returndata SHA-256 `fa8e7c0150ccd8d8569b4c2ce31329e1266f43960b17b3954bb5f794b419ac87`.

## Changed files

- `scripts/token0_p16/p16_evm.py` only (before SHA-256 `0e7815c215e694586fe6794cc65f21168a729dea86ecfe4b0da5c4c3ca3e0482`, after `c8d42ba9a93a5baf803adbc42026890b008379989192170eb536716dac81346d`)
- new evidence under `review/semantic-kernel/uniswap-token0/p16/implementation/grok-r6`

Hardcoded W16 / PRIMARY / private `p16-tools` cache / `p16_common.EVIDENCE` default grok-r5 paths remain a known replay limit. This repair used `--evidence grok-r6` and the existing r5 tool/cache configuration. It does not widen into P17, P18, P21, P30, certificate infrastructure, or full library proofs.

## M09 and remainders

M09 stays model-side Lean SwapMath: F28 excluded, F31 designated, F32 protected only under the model's earlier invalidFee guard. No Solidity F32-control claim. Original mixed liquidity 1.2 remains open.

Compile/source/model observations are separate from proof and source-refinement claims.

## What this is not

Not self-acceptance. Not source-gate acceptance. Not operation credit. Not independently accepted proof scope. Not source/assembly refinement. Not compiled M09. Diagnostic output corruption is not a production mutation. Root integrates accepted exact bytes to `semantic-kernel-pivot` only after review.
