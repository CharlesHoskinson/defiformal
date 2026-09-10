# P31 ZKIR source and Compact release-binding independent review

**Decision: this frozen preparation is usable as source-navigation and release-identity input for a subsequent reviewed ZKIR interface design. It is not a semantic contract, not adapter 32.7, not Compact-to-ZKIR correspondence, not constraint soundness, and not full P31.**

This is a native Grok 4.6 high review of sandbox `/home/charl/.cache/defiformal-program/program-execution-20260908/p31-zkir-source-grok-r1-sandbox`. Dispatch requested `grok-4.6`. This report records `returned_model` `grok-4.6`. Actual native process identity is unknown here and is for root to capture. Root independently verifies, adjudicates, and publishes. Same-scope acceptance of this preparation remains separate from full adapter acceptance.

Fixed `utc` fields on JSON reports are author metadata. They are not substitutes for per-command `started_utc` / `finished_utc` in `commands.json`.

## Identities

`inputs.json` declares 138 frozen files. Independent SHA-256 recompute matched 138/138 before and after this review. Extra sandbox files: 0. Missing: 0. Source, tree, release, and crate bytes were not edited.

Published crate `midnight-zkir` 2.1.0 archive SHA-256 `ef44e11cfb43259ada31738fd4fb1835f1394bda29ed6c1ca45a35204a544d9a` equals the crates.io metadata checksum. Size 40861 equals `crate_size`. Yanked is false. All nine archive members match the extracted disk files.

`.cargo_vcs_info.json` pins ledger commit `6d1b0acb1d03e01bc0580ec10cd55e54cd813f5a` and `path_in_vcs` `zkir`. Git blob SHA-1 values were recomputed as `sha1("blob " + len + NUL + bytes)` from frozen crate bytes and looked up in the four captured recursive trees. Live `git show` was not repeated.

Normalized `Cargo.toml`, `Cargo.lock`, and `.cargo_vcs_info.json` are package files. They were not treated as Git matches. The Git-comparable mapping is `Cargo.toml.orig` to `zkir/Cargo.toml` plus the four implementation files and `tests/proofs.rs`.

Fetched `upstream-root/LICENSE` is Apache License 2.0, SHA-256 `c71d239df91726fc519c6eb72d318ec65820627232b2f796219e87dcf35d0ab4`, from that crate-vcs commit. Registry metadata license is Apache-2.0.

The GitHub release endpoint `.../releases/tags/zkir-2.1.0` remains HTTP 404 in `fetch-receipts.json` and `root-seal.json`. Git tag `zkir-2.1.0` exists as commit `9da0b63cde82b93ccf1132a943ce05a86de06fe2`. Original failing script `bind-sources-attempt1.py` was not rerun or overwritten.

## Four distinct commits

Do not substitute one commit for another.

| Commit role | SHA | Matching Git-comparable files | Differing files |
|---|---|---|---|
| crate-vcs | `6d1b0acb1d03e01bc0580ec10cd55e54cd813f5a` | all six | none of the six |
| crate-tag `crate-zkir-2.1.0` (annotated tag object `8a9944c9...` targets this commit) | `04a6105472777d0ded1fdab27f611738cd435fd9` | `ir.rs`, `ir_vm.rs`, `lib.rs`, `main.rs`, `proofs.rs` | `Cargo.toml.orig` blob `ddee1208...` |
| binary-tag `zkir-2.1.0` | `9da0b63cde82b93ccf1132a943ce05a86de06fe2` | same five Rust files | `Cargo.toml.orig` blob `82e60189...` |
| ledger-tag `ledger-8.0.2` | `dfb450d558d23100d056d2ba121fe2b865e1208c` | `ir.rs`, `ir_vm.rs`, `lib.rs` | `Cargo.toml.orig`, `main.rs`, `proofs.rs` |

GitHub records `verification.verified` true on the annotated tag object. This review did not independently verify that PGP signature.

## Opcode locations and execution layers

All twelve opcodes observed on the sealed loan snapshot circuits are present in captured source at the claimed locations. `IrSource::load` accepts JSON version 2.0 only (`SerdeVersion { major: 2, minor: 0 }`) and otherwise returns `Unhandled version`.

Observed opcodes: `add`, `assert`, `cond_select`, `constrain_bits`, `constrain_to_boolean`, `declare_pub_input`, `less_than`, `load_imm`, `mul`, `neg`, `pi_skip`, `test_eq`. Each has an `ir.rs` schema variant and both a preprocess arm and a `Relation::circuit` arm in `ir_vm.rs`. The `Instruction` enum also defines opcodes that do not appear in those two circuits. The observed twelve are not a complete ISA.

Layers remain distinct:

1. Schema and loader: `ir.rs`.
2. Preprocessing: `IrSource::preprocess` in `ir_vm.rs`. Non-ZK run. Checks `num_inputs`, index bounds, boolean 0/1, bit bounds, full transcript consumption, and optional communications commitment.
3. Constraint construction: `Relation::circuit` in `ir_vm.rs`.
4. Cost-model / mock execution: `main.rs` `MockCompile` loads IR and calls `IrSource::model` / `midnight_zk_stdlib::cost_model`. It does not run `preprocess` and does not produce a cryptographic proof.
5. Cryptographic proving: `IrSource::prove` calls `preprocess` then `midnight_zk_stdlib::prove`. Not executed here.

`Preprocessed` is documented as not part of the public API.

Dependencies `midnight-zk-stdlib` 1.0.0, `midnight-proofs` 0.7.0, `midnight-circuits` 6.0.0, `midnight-transient-crypto` 2.0.0, and `midnight-base-crypto` 1.0.0 are declared/pinned in `Cargo.toml` / `Cargo.lock`. Their full semantic source is not captured.

## Field arithmetic, transcript, and communications

`Add`, `Mul`, and `Neg` are prime-field `Fr` operations. Integer financial arithmetic needs its own range and refinement argument. That argument is not supplied here.

Preprocess `idx` fails on out-of-range indices. `idx_bool` accepts only 0 and 1. `idx_bits` fails an excessive bound or a value outside the requested bit width. Schema comments mark several opcodes UB if boolean or bit assumptions fail.

Circuit construction is not identical to those preprocess checks. `Assert` uses `assert_non_zero`. `CondSelect` uses `is_zero` and inverts the select. `LessThan` requests an even bit width at least 4. `PiSkip` updates `pi_skips` and public-transcript grouping in preprocess and is a no-op in `circuit()`. These are source-navigation facts for a later interface contract. They are not an accepted semantics theorem.

When `do_communications_commitment` is true, preprocess requires a communications commitment, checks `transient_commit` over inputs then `Output` values, and records the commitment as the second public input after `binding_input`. Circuit assigns that commitment, later Poseidon-hashes randomness then inputs then outputs, and asserts equality with `public_inputs[1]`. The exact identity between `transient_commit` and in-circuit Poseidon lives in uncaptured dependency source and stays unknown here.

Public-input declarations append to `pis`. `PiSkip` groups them for transcript processing. Snapshot wrapper circuits remain distinct from pure financial transitions. That split was already recorded in sealed artifact-preparation evidence and is not re-opened as new mock work.

## Compact 0.31.1 release binding

Local archive `/home/charl/.compact/versions/0.31.1/x86_64-unknown-linux-musl/artifact.zip` is 27444336 bytes, SHA-256 `e291b4bab4d4e857707008f8b1c25c2b8e0c843f6c737d0ee6c0d9ac69a6bbfb`. That equals GitHub asset `457912387` digest and size. The archive was hashed in place. It was not copied into this report directory.

All six members match installed files byte-for-byte: `compactc`, `compactc.bin`, `fixup-compact`, `format-compact`, `zkir`, `zkir-v3`. Installed `zkir` remains SHA-256 `5443f87db07b7f19cc273380c224b77b4b7ca124deac6d54f7a165628fc5e1fc`. Members were hashed from the existing zip and installed paths. They were not executed.

Tag `compactc-v0.31.1` resolves to commit `30034b5e58983bace24c0a22a969946957a73967`. The captured tree is complete (`truncated` false) with 24 entries: GitHub templates, documentation, LICENSE, renovate, and prerelease 0.27 zip archives. It does not supply compiler or ZKIR build sources. Release body is null.

Artifact identity is not source-to-binary equivalence. Root already discloses that unverified build assumption. This review does not invent a mandatory reproducible-build gate. A crate-version string match with the installed tool is not a compiler-correctness theorem.

## Historical readiness gap

Root-accepted tasks 32.1–32.4 are preserved. Those records are not rewritten. Task 32.3 remains the historical `blocked_unavailable` readiness record: no verified ZKIR interface/semantic contract was bound at that acceptance.

What changed is the later evidence available for a next interface-design review. Sealed artifact preparation already captured generated JSON 2.0 `record0`/`record1` circuits and bounded mock-format controls. This preparation adds published `midnight-zkir` 2.1.0 source that locates those twelve opcodes and the 2.0 loader, plus Compact 0.31.1 release-package identity. The historical source/interface gap is therefore no longer “no published IR source and no release pin.” It remains “no accepted semantic contract, no Compact-to-ZKIR correspondence, and no adapter 32.7.”

Sealed mock and materialization checks were not rerun. They are not credited as constraint soundness, witness validity, ledger settlement, or correspondence.

## Unsupported claims

None found inside the stated bounds. Frozen records already set `acceptance` false, `semantic_contract_accepted` false, and `source_to_binary_equivalence_proved` false.

## Remaining obligations

These are already explicit. They are not new gates invented by this review.

1. Design and independently review a ZKIR JSON 2.0 interface/semantic contract for the generated subset, including opcode meanings, public-input/witness layout, `PiSkip` transcript behavior, and `do_communications_commitment`.
2. Prove Compact kernel/harness to ZKIR correspondence. Materialization identity and mock-compile cost models are not that proof. Distinguish snapshot `recordN` from pure `transitionN`.
3. Implement `lean/DefiKernel/Adapters/ZKIR.lean` against that pin/interface, or keep task 32.7 `blocked_unavailable`.
4. Independently review actual adapter results (task 32.9).
5. Keep PCT certificate consumption blocked on accepted P20.
6. Capture or explicitly bound uncaptured dependency source (`midnight-zk-stdlib` and related crates) if a later contract needs those semantics.
7. P31 and whole-program acceptance remain false.
