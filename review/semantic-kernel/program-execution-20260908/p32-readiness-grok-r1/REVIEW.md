# Independent P32 environment readiness review (tasks 33.1–33.7)

Decision: **ACCEPT_WITH_LIMITATIONS** for the six draft readiness records on their stated scope. **P34 is not accepted. The whole program is not complete. Root alone adjudicates and publishes.**

This is an independent native Grok 4.6 high review of Root administrative P32 preparation. It is not an author report. No subagent, Foreman, implementation edit, Lean build, package install, compilation rerun, financial rerun, or held assessment payload was used.

## Identity

| Field | Value |
|---|---|
| Requested model (dispatch.json) | `grok-4.6` |
| Requested effort | `high` |
| Fresh session | `true` |
| Returned model from native telemetry | `unknown` |
| Session id from native telemetry | `unknown` |
| System-announced identity | Grok 4.6 released by xAI (not a native session-info field) |
| Dispatch started_utc | `2026-09-10T17:19:33.849842+00:00` |
| Dispatch pid | `2004831` |
| Brief SHA-256 | `50bc54f2b9383fceedd18cd503400865021b8f720aee8deac0a28630556da826` |
| Inputs.json SHA-256 | `c9184522474aa5e74e5c45a8d552fd16e367af17e860570973ed2e98d97fc948` |
| Sandbox | `/home/charl/.cache/defiformal-program/program-execution-20260908/p32-readiness-grok-r1-sandbox` |
| Source head declared in inputs.json | `e2c8c5b638266ddd68a9d5b7e083c41f4a941e6a` |

`native.jsonl` records tool use and thoughts. It does not expose a provider-returned model string or session UUID. Historical names in PLAN-ACCEPTANCE.md (`grok-4.6-build`, `gpt-6-astra`) and in P16 `result.json` (`grok-4.6-build`, session `01a086d5-41ca-7141-bea1-d5a1dab9c902`) are not this assignment.

## Scope

Tasks 33.1–33.6 require one readiness record per named environment. Missing source or toolchain bindings must remain `blocked_unavailable`. Task 33.7 is this independent review. Source-plan line 1116 is agenda input only. Readiness is not P34 execution. EVM token0 evidence does not score Solana, Cosmos, Move/Sui, sovereign cross-chain, or payment-channel. No mainnet deployment is claimed.

Bound requirements:

- `tasks.md` 33.1–33.7 (SHA-256 `b6cad0985585a2ecff893ae3ada3b6ec2ced805fbd9214c9c0ee436f8640a4de`)
- spec requirement “Environment pins and evaluations” (SHA-256 `379ec56b1c2cb6f5a2f9b301686719b7db6c16d2db42259cf3b1b562f1e2f1ab`)
- `environment-scope-inputs.json` line 1116 excerpt (SHA-256 `9d707f3604f8a83f9b62f45c7d25aad2b3c985f128ed5ff1d1d30f8830df731f`)
- `PLAN-ACCEPTANCE.md` planning contract only (SHA-256 `0bb45e4250560113689f667da126612916f5ac011b2f7af482366bb4007194de`)

## Input hashes

`inputs.json` declares 58 sandbox files. Independent SHA-256 before probes: 58 present, 58 match, 0 missing, 0 mismatch. Independent SHA-256 after probes: 58 present, 58 match, 0 changed. Capture.py was not rerun.

## Per-task verdicts

### 33.1 EVM — ACCEPT_WITH_LIMITATIONS

Record `evm.json` SHA-256 `250b226092a8ccec172ac92d3b6d47184f5ca28e21e0ab42d95ba399864751bd`. Status `scoped_local_harness_available` is correct for the declared local helper. It is not an available platform for other environments and is not P34.

Cross-check (read-only hashes plus two absolute-path `--version` commands):

- Uniswap v3-core tag `v1.0.0`, commit `e3589b192d0be27e100cd0daaf6c97204fdb1899`, tree `f024dbf808e50091852f7cc8724d837543a8c7e5`, tag object `ef64f51d0f0dca5346c903484f3e6a771dd69d59`. Record pin equals `source-pin.json`.
- Helper `SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp`, `SqrtPriceMath.sol` lines 28–56, `internal pure`, `fee_parameter` false. Function text is present at that span.
- Seven token0-closure hashes match pin, upstream capture, overlay copies (six libraries), and `source-hashes.json`. `hardhat.config.ts` is in the seven-file closure and is not an overlay compile input.
- Token0Probe overlay SHA-256 `cc12001912e34069e54042ed62be5ecd0c1e57bca7e1c3685fce404e21cb069c`.
- Standard-JSON settings equal the record: optimizer enabled, runs 800, `metadata.bytecodeHash` none, `evmVersion` istanbul. `hardhat.config.ts` does not declare `evmVersion`; the compiler setting is the standard-JSON input, not the Hardhat file.
- Genesis SHA-256 `1a70be555705a08e5422705322b45fd716a81989af2c5830fbfcffc963b01be4`. `istanbulBlock` is 0. Later fork keys are absent. `compiler_evmVersion_establishes_execution_fork` is false. Compiler `evmVersion` and supplied genesis execution fork are both named istanbul and remain distinct fields.
- Runtime bytecode SHA-256 `07f36245480430411ce6a9afe829520f63ffd9a9af7fd7cac52f133d75c6f580` (734 bytes) agrees across decoded `runtime.hex`, `bytecode-hashes.json`, `compile.json`, `result.json`, and `evm.json`. File hash of `runtime.hex` is the distinct value `f2e0d587d298221822e4fa03a5191b998c2d1ca370ff558457d01b358ed6eb38`.
- Fresh `solc --version` exit 0, tool SHA-256 `bd69ea85427bf2f4da74cb426ad951dd78db9dfdd01d791208eccc2d4958a6bb`, stdout SHA-256 `fb5129a0d033c434a82a06911c66b2307dcb1d9794ec0237aa7098358195a2d7` (`Version: 0.7.6+commit.7338295f.Linux.g++`). Matches P32 commands and P16 solc receipt.
- Fresh `evm --version` exit 0, tool SHA-256 `d298ce2c811de089d650ed4f9535c0c58efc72e7adee9b61a40b6c10cc26fb5c`, stdout SHA-256 `49af542659aefc62a0ec07a860388d6afc05ff1d97bd8be6e7994a7c3afa5954` (`evm version 1.15.11-stable`). Matches P32 commands and P16 evm receipt.
- Deployment kind is a local deterministic helper harness. `mainnet_address_verified` is false. `mainnet_deployment_identity` is null.
- Historical twelve token0 comparisons and six compiled mutations remain P16 accepted evidence (`P16-SOURCE-ACCEPTANCE.md`). They were not rerun. They are not new P32 or P34 execution.
- `source-pin.json` still carries historical `captured_not_executed`, `compiler_binary_verified: false`, and `evm_harness: not_established`. `source-bindings.json` retains those flags on purpose. Later P16 acceptance and frozen compiler receipts are the current EVM evidence. Those historical pin fields are not treated as a missing toolchain.

`shutil.which("solc")` and `shutil.which("evm")` remain null. Exact-name listing of `p16-tools` finds `evm` and not `solc`, because the compiler binary is named `solc-linux-amd64-v0.7.6+commit.7338295f`. The EVM record binds those absolute paths. That is not PATH discovery, and it is sufficient for this scoped harness.

### 33.2 Solana — ACCEPT as `blocked_unavailable`

Record SHA-256 `ea42cc2a65e9586fb12b6c70ad1d2259fd014b5b3d174d7293b1135f2a3b3c8c`. `verified_source_pin`, `verified_deployment`, and `verified_toolchain` are null. Named tools `solana`, `cargo-build-sbf`, `anchor`, `agave-validator`, `solana-test-validator` were not found by the declared bounded lookup. Generic `rustc`/`cargo` on PATH are not Solana readiness. Not an available platform.

### 33.3 Cosmos — ACCEPT as `blocked_unavailable`

Record SHA-256 `ac00bedfa85d933d34158fa9aaaf5afa55b4247a00c934c142559864bfb18a15`. Source, deployment, and toolchain fields are null. Named tools `gaiad`, `osmosisd`, `wasmd`, `hermes` were not found. Generic `go` on PATH is not Cosmos readiness. Not an available platform.

### 33.4 Move/Sui — ACCEPT as `blocked_unavailable`

Record SHA-256 `b7759fed810f8cb8ccc9d0a4189b2b8ca02255f94430b48a05af061a3e263faf`. Source, deployment, and toolchain fields are null. Named tools `sui`, `aptos`, `move` were not found. Matches the spec scenario for a missing Move toolchain: evaluation stays blocked, must not inherit EVM scores, and P34 remains open.

### 33.5 Sovereign cross-chain — ACCEPT as `blocked_unavailable`

Record SHA-256 `3a6bd6e54055cb1d37db2d7b519080321193933581dee8e63ba2886fca5ac522`. Source, deployment, and toolchain fields are null. Named tools `polkadot`, `substrate`, `cardano-node`, `cardano-cli` were not found by `shutil.which` on the current PATH, on the original recorded PATH, or as exact names in the four roots. A Windows directory `.../cardano-node-11.0.1/bin` appears as a PATH entry. That is not a verified Linux toolchain pin and was not a which hit. Absence from these lookups is not whole-machine or public-network absence. Not an available platform.

### 33.6 Payment-channel — ACCEPT as `blocked_unavailable`

Record SHA-256 `0941d34868097d6027f977a195941051da3fd4d923d8388916738d23dad9d67e`. Source, deployment, and toolchain fields are null. Named tools `bitcoind`, `bitcoin-cli`, `lnd`, `lncli`, `lightningd`, `lightning-cli` were not found. Not an available platform.

### 33.7 Independent review — ACCEPT_WITH_LIMITATIONS

Six records exist. Index SHA-256 `da4c4465c162becb703645bc8085df9cf66d8edc4533557f9cbbec4a69de33cc` already sets `task33_7_review` pending, `full_p32_accepted` false, `full_p34_accepted` false, `whole_program_complete` false. This review does not flip those program-level flags to true. Line 1116 is not evidence that the five missing toolchains exist here.

## Bounded discovery

Original method: `shutil.which` on the process PATH plus exact-name directory entries in `/home/charl/.local/bin`, `/home/charl/.cargo/bin`, `/usr/local/bin`, and `.../p16-tools`.

Independent repeat at `2026-09-10T17:26:14.024855+00:00`–`2026-09-10T17:26:16.417498+00:00`:

- Current PATH string differs from the recorded capture PATH. Named-tool which results still match the original: every listed chain tool is null.
- Directory checks match the original: three empty roots; `p16-tools` lists `evm` only among the named tools.
- `p16-tools` also contains `solc-linux-amd64-v0.7.6+commit.7338295f` (SHA-256 `bd69ea85427bf2f4da74cb426ad951dd78db9dfdd01d791208eccc2d4958a6bb`), which is outside the exact-name set.
- Generic tools found and not treated as chain readiness: `rustc` and `cargo` at `/home/charl/.cargo/bin`, `go` at `/usr/local/go/bin`.

## Explicit nonacceptance

- P34 nonempty success and refusal per required environment against APIs frozen under P33: **not accepted**.
- Whole-program completion: **not accepted**.
- Full P32 as six available platforms: **not accepted**.
- Mainnet deployment identity: **not claimed and not accepted**.
- Held assessment payloads: **not selected and not read**.

## Limitations

- Discovery is the declared PATH plus four roots. It is not a whole-machine search and not a network availability proof.
- Overlay-copy.json still names the historical P16 worktree path. Sandbox overlay bytes were hashed here; that old path was not followed.
- Twelve/six P16 campaign results were not re-executed. Frozen compiler artifacts were rehashed. No discrepancy required a compile or EVM rerun.
- Returned native model and session id remain unknown.

## Recommendation to root

Accept the six records as correctly scoped P32 readiness drafts: one EVM local harness for the declared token0 helper, five explicit blocks. Do not mark missing pins as available platforms. Keep P34 and the program open. No repair of the six JSON records is required for this scope.
