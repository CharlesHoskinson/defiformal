# P16 source/EVM/mutation r3 independent review

**CHANGES_REQUIRED.** Two bounded repair groups concern campaign evidence handling. No Lean/model/proof source repair is requested, and the accepted r2 proof/model/recorder verdict remains valid. This source candidate must remain an unaccepted snapshot until the repairs receive independent review.

Reviewed archive: `p16-source-candidate-r3.tar.gz`, SHA-256 `95051fd2f33381231740c49d151551d65be4177a72ddb228ca6874962379326c`. Root's manifest binds 595 files, including all 197 accepted r2 files. Native Grok session `01a0830a-4541-73d1-b2ee-ab911a58a5cc` ended normally after 42 turns, process 0, actual reported model `grok-4.6-build`. Independent reviewer: GPT-6. No Foreman or additional reviewer agents were used.

## Verified positives retained for targeted re-review

The unchanged campaign freshly exited 0 in 4.784 seconds, with all twelve independent source observations and six compiled mutants passing. Actual CLI controls returned mismatch 1, empty selection 3, missing compiler 3, and malformed JSON 1. An additional reviewer-local Solidity syntax corruption went through the actual pinned compiler and compile CLI, returning blocked 3. The malformed-input exit 1 is recorded as observed behavior, not accepted classification.

`logs/independent-positive-bindings.json` independently checks all seven baseline/mutant compilations against author artifacts: exact source hashes, optimizer 800, metadata hash none, Istanbul compiler target, selector, creation bytecode and runtime bytecode. The selector is compiler-derived `6c84a8a2`. Baseline creation/runtime SHA-256 are respectively `74306c39f38934e603ee0beb9e4989025c08dd17b8383a209231c3d287f52182` and `07f36245480430411ce6a9afe829520f63ffd9a9af7fd7cac52f133d75c6f580`. Each mutant changes only `SqrtPriceMath.sol`, by exactly one occurrence of its retained find/replace fragment; all six other source files remain identical. These edits implement the accepted plan's identity, wrap guard, product guard retaining assignment, strict removal guard, rounding, and checked-add mutations.

Fresh tool checks bind solc SHA-256 `bd69ea85427bf2f4da74cb426ad951dd78db9dfdd01d791208eccc2d4958a6bb`, EVM `d298ce2c811de089d650ed4f9535c0c58efc72e7adee9b61a40b6c10cc26fb5c`, and retained runner.go `f50fda86bd030cdd4f49f8521d3f7f8e56619123f2a61d9f3cc94d47480fadac`. Go module metadata identifies go-ethereum v1.15.11. Runner source confirms supplied genesis controls the chain configuration, timestamp and block number, and the campaign uses runtime Call, not creation. Genesis SHA-256 is `1a70be555705a08e5422705322b45fd716a81989af2c5830fbfcffc963b01be4`; Istanbul is active at block 0 and later forks omitted. Compiler target alone is not used as execution-fork evidence.

All twelve calldata values were independently decoded/reconstructed from stored fixtures and compared to fresh source rows. All twelve fresh Lean binding lines were parsed and independently checked for exact IDs, inputs, model results and truth. Requirement refusals map to Lean `subUnderflow`; the model label is not the source returndata. Fresh normal observations include strict removal mutant success 1, equality still reverting, ordinary ADD unchanged for all six mutants, and identity-skip INVALID from high-level division by zero. The source failure cases actually have EVM process exit 0; this must not be confused with the host failure cases below.

All 391 rows of the author's internal manifest match. The archive and all 595 candidate files match before/after review; all 197 accepted r2 files, 144 planning files and 179 prior tracked Lean-tree files remain unchanged. Tracked worktree status is clean. Fresh outputs and reviewer-local probes are confined to this review directory. Existing proof inventory was reused; no broad proof campaign was repeated.

## R1 — Reject invalid execution evidence and propagate blocked outcomes

Locations: `scripts/token0_p16/p16_common.py:125` (`record_cmd`, especially receipt loading), `p16_evm.py:93` (`classify_evm_stdout`) and `:171` (`run_probe`), `source_campaign.py:221`, `:341` (comparisons), and `:826` onward (mutant aggregation). The exact files are bound by the rejected-file manifest.

The production consumer accepts a missing receipt as an empty object, treats unknown exit/empty or unknown stdout as a semantic exception, and can interpret partial stdout from a crashed process as a semantic revert. It does not validate current invocation identity or stdout/stderr hashes against loaded receipts. Mutant aggregation also discards blocked comparison gates and converts them into ordinary failure 1.

These are actual full-campaign reproductions, not only helper calls. Reviewer-local transport fault injection changes one invocation at `T0-ID-SKIP-designated-P16-I-ADD`; all other compiler/EVM calls and campaign scoring use the frozen production code. The shim's command/receipt differences are retained, so a sound consumer has the information needed to reject them. These are diagnostic faults, not additional production mutants.

| Evidence under `faults/` | Actual injected observation | Actual campaign result |
| --- | --- | --- |
| `missing-receipt` | Wrapper 1, no receipt or stdout | Exit 0, mutants 6/6 |
| `unknown-stdout` | Recorded child 0, unrecognized text | Exit 0, mutants 6/6 |
| `stale-receipt` | Current wrapper 1, copied historical genuine receipt/output with old invocation paths/time | Exit 0, mutants 6/6 |
| `crash-partial-corrected` | Recorded child -9, classification crash, wrapper 3, partial `0x` and revert text | Exit 0, mutants 6/6 |
| `malformed-receipt` | Invalid receipt JSON | Uncaught exception, exit 1; no blocked campaign score |
| `timeout` | Actual recorder timeout, unknown child exit, wrapper 3 | Campaign exit 1, mutants 5 ok/1 fail/0 blocked |

Required repair: validate receipts before consuming outputs, including schema/types, actual wrapper/child status, current invocation arguments/cwd, fresh attempt identity and output hashes. Missing, malformed, stale, cancelled, crashed, timed-out or otherwise invalid execution evidence must become setup-blocked 3, never semantic credit. Preserve failure evidence in distinct attempt directories; do not recover old success receipts or counts after a failed invocation. Only a successfully completed pinned EVM invocation with recognized output syntax may yield semantic success/refusal. Require a valid ABI uint160 word for success; distinguish legitimate STOP smoke output explicitly from an unknown token0 result. Preserve the actual named EVM refusal/exception class and do not silently relax an explicitly named planned class. Propagate blocked state through designated, unaffected and equality controls into mutant and overall scores. Compiler failures remain blocked. Compiler invocation currently has no timeout parameter; use a bounded invocation with preserved receipts/cleanup rather than allowing a hung compiler to leave the campaign without a classified outcome.

The repaired real runner must pass actual child 0/1/3, missing/malformed/stale receipt, unknown/malformed output, crash with partial output, timeout and unaffected-process controls. A host exit 1 alone is never a detected mutant. The frozen r2 recorder need not be edited: the source consumer must enforce its previously accepted obligations.

## R2 — Require exact fixture and Lean semantic coverage

Locations: `p16_common.py:103` (`load_fixtures`), `:211` onward (input/expected coercion), `source_campaign.py:408` (`score_rows`), `:462` (malformed control), `:543` and `:699` (Lean bindings), and `:938` onward (overall score).

The fixture loader only checks nonempty/unique IDs. It does not require the expected twelve IDs or strict field types; `bool(value)` can reinterpret malformed values, and an expected object without `ok` is treated as refusal. The Lean export is hardcoded separately from the fixture input and `#eval main` merely prints its returned UInt32. The scorer checks process exits but does not require exact matching row IDs, bound inputs/results, true comparisons or a nonempty successful semantic summary. It also permits unknown/null process exits in several conditions.

Two full-campaign reproductions demonstrate impact:

- `faults/missing-fixture-file`: the actual fixture loader reads a reviewer-local copy with only P16-I-REM removed. Campaign exits 0 with baseline 11/11 and mutants 6/6. All original planning files remain untouched. An earlier loader-boundary variant is retained separately.
- `faults/lean-false`: only the generated reviewer-local Lean binding's P16-ADD expected value changes to 0. Lean prints `match=false` and a failed comparison, but elaboration exits 0; the campaign still exits 0 with full source/mutant scores. Accepted library source is unchanged.

Required repair: validate the actual fixture file with the exact expected ID set, uniqueness, mandatory fields, actual Boolean values, representable integers and unambiguous expected-result forms. Empty, missing, extra, malformed or selectively omitted rows are setup-blocked 3. Route malformed controls through the same real input loader and classification, rather than a standalone JSON parser returning failure 1. Generate Lean bindings from those stored values or independently enforce exact equality before scoring. Parse a defined complete result format and require exact IDs, inputs, results, truth values and denominators for both RuntimeAudit and bindings. Missing/duplicate/unparseable rows or unknown/non-success execution evidence block; a valid completed semantic comparison that is false returns 1. Printed `#eval` return values and compiler exit 0 are not semantic acceptance. Add direct controls for false, missing, duplicate and malformed Lean rows and fixture omission/type errors, without changing accepted proof sources.

After these repairs, run the intact campaign once and retain its actual command receipt and generated score, plus the meaningful failing/blocked controls. Preserve all current author/reviewer evidence. The frozen author `campaign-score.json` explicitly admits the first intact run exited 1 on a Lean binder error and reconciles a later successful binding run; its final score is not itself a receipt proving the first run exited 0. Our fresh unmodified rerun actually exits 0 and its bindings have independently checked truth, but it does not cure the general scorer defect. The repaired producer must create a new authoritative score with truthful invocation bindings.

## Scope and retained limitations

M09 handoff correctly remains model-side Lean SwapMath: F28 excluded, F31 designated, F32 protected only under the model's earlier invalidFee guard. No Solidity F32-control claim or compiled M09 credit is made. Scenario mapping keeps finite observations separate from proof obligations and diagnostic oracle evidence; the named P17, P21, original mixed whole-liquidity 1.2, and P30/source-assembly remainders stay open. Statements that r2 is still under review are historical author metadata superseded by accepted delivery e53d78f; those bytes were not rewritten.

Scripts currently require hardcoded W16, primary evidence and private tool-cache paths. This review establishes replay in that retained environment, not portable standalone execution. No deployment, full original library acceptance or universal source/assembly refinement is granted. Positive finite observations above are preserved for targeted re-review; source gate and operation credit remain withheld until R1/R2 are repaired.

One crash-probe attempt had a reviewer string-quoting SyntaxError; its exact source and logs are preserved and are only ordinary process-failure evidence. The corrected probe establishes actual SIGKILL. A reviewer binding-check attempt assumed every refusal had `model_label`; the corrected independent parser uses the accepted explicit mapping. Setup-failure provenance is recorded, not counted as candidate semantic failures. All execution has ended; checker and cache access are released.
