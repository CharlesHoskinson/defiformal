# P16 r3 source/EVM/mutant candidate — native Grok 4.6

**Status: pending independent GPT-6 review. Not P16 acceptance. Not proof acceptance. Not source refinement.**

Native Grok 4.6 authored this source-execution batch after root froze the r2 proof/recorder candidate (`p16-proof-recorder-candidate-r2.tar.gz` SHA-256 `62a2b86a3148a38cc9db59658a6843723a81454d8732eae8b23344f2309a1ec8`, 197 files). Those 197 files were rehashed before and after this batch: 0 mismatches. `Token0Probe.sol`, `record_cmd.py`, `test_record_cmd.py`, `timeout_descendant.py`, `rehash_pins.py`, and all nine ConcentratedLiquidity Lean files were not edited. New files only: `scripts/token0_p16/p16_*.py`, `scripts/token0_p16/source_campaign.py`, and this `grok-r3/` tree. No commit, push, Foreman, subagents, or global install.

The r2 author reports (22 runtime comparisons, 138 theorems, 5 recorder controls) remain under independent GPT-6 review. This document does not treat them as accepted proof scope.

## Tool and fork binding (administrative, then used)

Private binaries were rehashed before scoring:

| Tool | Path | SHA-256 | Match |
| --- | --- | --- | --- |
| solc 0.7.6+commit.7338295f | `/home/charl/.cache/defiformal-program/program-execution-20260908/p16-tools/solc-linux-amd64-v0.7.6+commit.7338295f` | `bd69ea85427bf2f4da74cb426ad951dd78db9dfdd01d791208eccc2d4958a6bb` | yes |
| evm 1.15.11-stable | same directory `/evm` | `d298ce2c811de089d650ed4f9535c0c58efc72e7adee9b61a40b6c10cc26fb5c` | yes |
| retained `runner.go` | `p16-evm-readiness/runner.go` | `f50fda86bd030cdd4f49f8521d3f7f8e56619123f2a61d9f3cc94d47480fadac` | yes |

`solc --version` exit 0, stdout SHA-256 `fb5129a0d033c434a82a06911c66b2307dcb1d9794ec0237aa7098358195a2d7`. `go version -m` records `go1.26.4` and `github.com/ethereum/go-ethereum v1.15.11 h1:JK73WKeu0WC0O1eyX+mdQAVHUV+UR1a9VB/domDngBU=`.

`runner.go` uses `params.AllDevChainProtocolChanges` when `--prestate` is absent. This campaign always supplies `--prestate` `genesis/istanbul-genesis.json` (SHA-256 `1a70be555705a08e5422705322b45fd716a81989af2c5830fbfcffc963b01be4`). Config sets `istanbulBlock=0` and omits later forks (`muirGlacierBlock` through `verkleTime`). Time 0, number 0, gasLimit `0x2540be400` (10_000_000_000), sender `0x1000…0001`, receiver `0x2000…0002`. Compiler `evmVersion=istanbul` is a separate compile setting and is not the execution fork. Genesis smoke (`STOP`) process exit 0.

Missing-solc compile is blocked 3 (`controls/missing-tool`). Empty compile/bytecode would also be blocked 3; it did not occur on the intact path.

## Baseline compile

Frozen `Token0Probe.sol` (SHA-256 `cc12001912e34069e54042ed62be5ecd0c1e57bca7e1c3685fce404e21cb069c`) was copied, not edited, with the six captured libraries as standard-JSON source keys matching `import "./Name.sol"`. Settings: optimizer enabled, 800 runs, `metadata.bytecodeHash none`, `evmVersion istanbul`.

Source hashes equal `source-pin.json`. Compiler `methodIdentifiers` (not SHA3): `probe(uint160,uint128,uint256,bool)` → `6c84a8a2`. Calldata is that 4-byte selector plus four 32-byte words. All input words are representable in their ABI types; there is no fee parameter.

| Bytecode | SHA-256 | Bytes |
| --- | --- | --- |
| creation | `74306c39f38934e603ee0beb9e4989025c08dd17b8383a209231c3d287f52182` | 766 |
| deployed runtime | `07f36245480430411ce6a9afe829520f63ffd9a9af7fd7cac52f133d75c6f580` | 734 |

Those hashes are distinct. Scoring uses runtime bytecode with `evm run` (Call), not create.

## Twelve fixtures (finite source observations)

Each fixture binds `fixtures.json` literals directly into calldata. Independent expected values are those literals, not helper self-output. EVM process exit is 0 on both success and semantic revert; classification uses the printed returndata/error line.

| ID | Source class | Observation | Independent expected |
| --- | --- | --- | --- |
| P16-I-ADD | success | 79228162514264337593543950336 | ok 2^96 |
| P16-I-REM | success | same | ok 2^96 |
| P16-I-ZERO-LIQ | success | same | ok 2^96 |
| P16-ADD | success | 39614081257132168796771975168 | ok 2^95 |
| P16-ADD-ROUND | success | 26409387504754779197847983446 | ok ceil(2^96/3) |
| P16-REQ | evm_revert | returndata `0x`, `error: execution reverted` | refusal; model `subUnderflow` is not the payload |
| P16-REQ-STRICT | evm_revert | same empty revert | refusal |
| P16-REM | success | 158456325028528675187087900672 | ok 2^97 |
| P16-SAFECAST | evm_revert | empty revert | refusal |
| P16-ADD-DEN0 | evm_revert | empty revert | refusal |
| P16-PROD | success | 4294967296 | ok 2^32 |
| P16-WRAP | success | 340269576638287423012608907232989748562 | wrap-fallback literal |

Denominator 12, unique IDs, 12/12 match, campaign scorer exit 0. A semantic EVM revert is not a host process failure: `evm` still exits 0 and prints `error: execution reverted`.

Frozen Lean `RuntimeAudit` was re-run on the same pinned library (`lake-runtime-r3`, exit 0): all 12 P16 rows print `true`. Ephemeral `lean/P16SourceBindings.lean` imports that frozen library and binds the same 12 input/expected literals directly. First attempt failed (identifier `matches` is not a legal `let` binder; snapshot `lean/failed-attempts/bindings-attempt1`). Repair renamed it to `agrees`. `lean-source-bindings-attempt2` exit 0 printed 12 `match=true` rows with the bound inputs. Model Failure names remain distinct from EVM payloads. Python diagnostics were not used for scoring.

A finite source/model comparison is not a universal refinement proof. P30 remains open.

## Six compiled production mutants

Each mutant is one exact Solidity edit of a copied `SqrtPriceMath.sol`. Captured upstream bytes stay immutable. Baseline and mutants share the same solc/EVM/genesis/selector. Compile failure would be blocked, not detection. All six compiled to distinct runtime bytecode and showed a designated change plus an independent ordinary ADD control (`P16-ADD` still 2^95).

| Mutant | Designated | Baseline | Mutant public | Control P16-ADD |
| --- | --- | --- | --- | --- |
| T0-ID-SKIP | P16-I-ADD | success 2^96 | `evm_exception` `invalid opcode: INVALID` (high-level `/ amount` at 0) | unchanged |
| T0-WRAP-SKIP | P16-WRAP | success wrap literal | success 1430089493431239948923811608424801982436782118539 | unchanged |
| T0-PROD-SKIP | P16-PROD | success 2^32 | success 2^96; product assignment kept, fit-test replaced with `true` | unchanged |
| T0-REQ-SKIP | P16-REQ-STRICT | evm_revert | success 1 | unchanged |
| T0-FLOOR | P16-ADD-ROUND | …83446 | …83445 | unchanged |
| T0-CHECKED-ADD | P16-WRAP | success wrap literal | evm_revert empty 0x (`LowGasSafeMath.add`) | unchanged |

T0-REQ-SKIP equality control `P16-REQ` remains `evm_revert` (wrapped denominator 0, FullMath refusal). That is not the designated false witness.

## Honest 0/1/3 controls

Fresh controls, not fixture-label-only checks:

| Control | Exit | Classification |
| --- | --- | --- |
| intact nonempty 12+6 | 0 | all independent comparisons hold |
| deliberate bound mismatch (P16-ADD vs expected 0) | 1 | fail on a real observation |
| malformed fixture JSON | 1 | parse rejected |
| empty selection | 3 | denominator 0, blocked, zero source credit |
| missing solc | 3 | `blocked_missing_compiler` |

Frozen `record_cmd.py` recorded child and wrapper exits and owned process groups. No new recorder defect was found. `PYTHONDONTWRITEBYTECODE=1` was set; no `__pycache__` was written under `scripts/token0_p16`.

## M09 handoff and remainders

No compiled M09, SwapMath, token1, TickMath, Signed, or 45-fixture campaign. `m09-handoff.json` records F28 excluded, F32 as a model-side `invalidFee` sibling (not a pinned Solidity control), F31 designated. P17 Typed reuse, P21 residuals, and P30 assembly/source refinement stay named in `remaining-gates.json`. Original mixed liquidity 1.2 is not whole-task done.

Planning OpenSpec checkboxes were not edited. Previous r1/r2 evidence was not overwritten.

## Requirement mapping for this source batch

| Task | Evidence | Status in this candidate |
| --- | --- | --- |
| 4.1 solc identity | tool-rehash + `solc --version` | present |
| 4.2 Token0Probe compile | `compiler/baseline/compile.json` | present |
| 4.3 12 partitions including wrap | `evm/baseline/rows.json` 12/12 | present |
| 4.4 missing tool is blocked | `controls/missing-tool` exit 3 | present (intact path had tools) |
| 5.1 six named edits | `evm/mutants/rows.json` 6/6 | present |
| 5.2 compile failure blocked not detection | missing-tool / edit uniqueness guards | present |
| 5.4 M09 handoff | `m09-handoff.json` | present; not compiled |
| 6.1 scenario map | `scenario-map.json` | present |
| 6.2 independent GPT-6 | not run this session | required |
| 6.3 remainders | `remaining-gates.json` | present |
| 5.3 / 2.x / 3.x proofs | frozen r2, under review | not accepted here |

## What this is not

Not self-acceptance. Not full P16 operation credit. Not independently accepted proof scope. Not source/assembly refinement. Not deployed bytecode. Not compiled M09. Root integrates accepted exact bytes to `semantic-kernel-pivot` only after review.

Author: native Grok 4.6. Checker: independent GPT-6, not executed in this session.
