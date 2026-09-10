# P31 generated ZKIR artifact-preparation independent review

**Decision: the frozen records are usable generated ZKIR artifact/interface evidence. They are not a semantic contract, not adapter task 32.7, not full P31, and not constraint soundness, witness validity, verification, or settlement.**

This is session `01a08c26-f918-7f31-9a38-b0eeade61fac` completed as a reporting-only closeout after the original process wrote `verdict.json`, `findings.json`, and `commands.json` and then exited 1 at the turn cap. Those three reports were copied here byte-identically. This closeout does not redo probes, rewrite those reports, or treat itself as a second independent audit. Frozen sandbox `/home/charl/.cache/defiformal-program/program-execution-20260908/p31-zkir-artifact-grok-r1-sandbox` was the evidence source. Replay identities already exist under `../replay/`. Root independently verifies.

Parent `verdict.json` records `returned_model` `grok-4.6`. Dispatch requested `grok-4.6`. Root native terminal identity is `grok-4.6-build`. This review states that distinction and does not change the original reports.

Fixed `utc` fields `2026-09-10T16:36:00.000000+00:00` on the three copied reports are author metadata. They are not substitutes for per-command `started_utc` / `finished_utc` captured in `commands.json` and in `../replay/mock-compile/*/command.json`.

`commands.json` entry `brief-sha256` stores the SHA-256 of original `brief.txt` content in the field named `stdout_sha256` (`1850c435af0ce895eb790405dc3bfd303e4c60c7712008c0f32d793af1fb2c85`). That is a content identity. It is not an observed raw-stdout digest of a `sha256sum` process.

## Identities

Source pin: `7307349d0275af6fcb4144e1661d8b59d6b2663a`.

The completed reports record 97/97 review-input SHA-256 matches, extra 0, missing 0; 33/33 source SHA-256, byte-length, and Git-blob matches recomputed as `sha1("blob " + len + NUL + bytes)` from frozen bytes. Live Moriarty `git show` was not repeated. Root independently verifies those identities.

Unchanged `materialize-mapping.mjs` SHA-256 `5dac9c40152378490b35c62c1815978eb4d89d4d261f02bb45761a9fe138b856` regenerated nine loan/swap files byte-identically into `../replay/materialize/`. Independent rematerialize stdout SHA-256 `8efa341b2cda5448825ab91e4362abf49b0db7d552e10593cfb844edc1b86f0a` matches frozen `materialization.json`. Materialization identity is not source-to-ledger correspondence.

Tool `/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl/zkir` SHA-256 `5443f87db07b7f19cc273380c224b77b4b7ca124deac6d54f7a165628fc5e1fc` and version `midnight-zkir 2.1.0` matched the frozen mock receipt before replay. `compactc.bin` SHA-256 `3054ffa89d7a4dfe24afd31c27ef37e87a95757de0fc24485f335635e26dce57` matched the compile receipt. The Compact compiler was not rerun in this audit.

## Generated artifacts

Loan-harness compile under Compact 0.31.1 / language 0.23.0 / runtime 0.16.0 / ledger-8.0.2 `--skip-zk` produced six files, including JSON ZKIR 2.0 `record0` and `record1`.

- `record0`: 39 inputs, 255 instructions, 11 distinct opcodes, mock-compile exit 0, k=13, rows=5297, `input.bzkir` 955 bytes SHA-256 `d1217f2fe66662dce7e0df9eac73ede27406d43704bdfd0f455128ca8a3abb7d`.
- `record1`: 16 inputs, 139 instructions, 11 distinct opcodes, mock-compile exit 0, k=12, rows=2941, `input.bzkir` 395 bytes SHA-256 `f02506aea4a31d7db9bd3526ca65c6173b9fa08d5bc26a5368c61ce36f73684d`.

Opcode union is 12 (`mul` only in record0; `constrain_to_boolean` only in record1). Observed fields and opcodes are not a complete normative opcode semantics. This run matched frozen `.bzkir` bytes exactly; that is this-run evidence, not a general determinism theorem.

`contract-info.json` names eight circuits. `proof` true: `record0`, `record1` (snapshot wrappers). `proof` false: `checkedAdd`, `checkedSub`, `checkedMul`, `checkedDiv`, `transition0`, `transition1`. The emitted ZKIR files are for the test-only snapshot wrappers, which disclose kernel output and move no financial assets. They are not the pure kernel transitions. `--skip-zk` and mock-compile imply no real keys, proofs, or ledger execution.

## Mock-format controls

Each frozen `input.zkir` was copied byte-identically into unique review directories. Timeouts were false. Timeout is not success.

Negative controls: major 999 exit 1 (`invalid value: integer 999, expected u8`); major 255 exit 1 (`Unhandled version: 255.0`); unknown opcode `root_invalid_opcode_control` exit 1 (unknown variant). Replay stderr SHA-256 values differ from frozen logs because the circuit path is embedded in the message; after substituting the quoted path, the five texts match. Frozen bytes and replay bytes are both retained.

These controls show selected parse/version/opcode checks. They do not prove constraint soundness, witness validity, verification, or settlement.

## Scope and remaining obligations

Root-accepted readiness tasks 32.1–32.4 are not reopened. Task 32.3 remains the `blocked_unavailable` gap record. Task 32.7 remains `blocked_unavailable` until a verified JSON 2.0 interface/semantic contract is bound (opcode meanings, public-input/witness layout, `do_communications_commitment`) and Compact kernel/harness-to-ZKIR correspondence is proved separately from materialization identity, including the `recordN` versus `transitionN` split. Then implement `lean/DefiKernel/Adapters/ZKIR.lean` against that pin, or keep 32.7 blocked. Independent review of actual adapter results remains task 32.9.

This review cannot accept adapter 32.7, full P31, P20-dependent PCT correspondence, or the program because mock compilation passed. No actual claim in the frozen records was found to overstate the disclosed test scope.

## Unsupported claims

None found inside the stated bounds. The copied reports keep `acceptance` false.

## Precise remaining gaps

These are already explicit in the copied reports. They are not new gates.

1. Bind a verified ZKIR JSON 2.0 interface/semantic contract for the generated subset before adapter 32.7.
2. Prove Compact kernel/harness to ZKIR constraint correspondence; materialization identity is not that proof.
3. Distinguish snapshot `record0`/`record1` from pure `transition0`/`transition1` in that contract.
4. Implement `lean/DefiKernel/Adapters/ZKIR.lean` against the pin/interface or keep 32.7 `blocked_unavailable`.
5. Independent review of actual adapter results (task 32.9).
6. Accepted P20 before PCT certificate consumption.
7. P31 and whole-program acceptance remain false.
