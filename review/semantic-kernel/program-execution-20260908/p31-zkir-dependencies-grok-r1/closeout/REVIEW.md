# P31 ZKIR dependency-source and navigation independent review

**Decision: this frozen preparation is usable as locked-dependency source identity and static navigation input for a subsequent reviewed ZKIR interface design. It is not a semantic contract, not adapter 32.7, not adapter 32.9, not Compact-to-ZKIR correspondence, not constraint soundness, and not full P31, P19, P20, or the whole program.**

This is the same native Grok 4.6 high review of sandbox `/home/charl/.cache/defiformal-program/program-execution-20260908/p31-zkir-dependencies-grok-r1-sandbox`, session `01a08cb3-a2c6-7432-9c84-cd973ca6efcd`. Dispatch requested `grok-4.6`. This closeout records `returned_model` `grok-4.6` and root terminal identity `grok-4.6-build`. It is not a second independent audit. The initial 18-turn run exited 1 with no final reports. Parent probe bytes under the parent output directory are preserved. Root independently verifies, adjudicates, and publishes.

Fixed `utc` fields on JSON reports are author metadata. They are not substitutes for per-command `started_utc` / `finished_utc` in `commands.json`.

## Identities

`inputs.json` declares 749 frozen files. The parent probe and the corrected closeout probe both rematched 749/749 SHA-256 values. Extra sandbox files: 0. Missing: 0. Source, archive, receipt, and navigation bytes were not edited.

Exact lock selection from the captured `Cargo.lock` is every `midnight-*` package except root `midnight-zkir`. That set is 12 packages. The same lock file SHA-256 `2c1c83d43ad654de176ff1e4f195987a01b2d587f38f3e668897dddd239cb51a` is byte-identical in the dependency packet inputs, the blst packet, and the earlier zkir crate. The lock contains 347 packages. After the 12 Midnight packages, `midnight-zkir` 2.1.0, and `blst` 0.3.16, 333 other lock members remain uncaptured.

All 12 Midnight archives and the blst 0.3.16 archive match both the lock checksum and the captured registry checksum and size. Yanked is false on the captured versions. HTTP receipts bind status 200 and body SHA-256/size for each archive and `registry.json`. Extracted tar members have safe relative paths. Sealed Midnight files are 532. Sealed blst files are 167.

## Parent probe false flags have zero credit

The parent probe `probes/binding-probe.py` SHA-256 `6ccafe133f2058d1e2c413ca09427a86d24a82330c202b5a59fab196e330a3fe` printed `exit` 0 unconditionally with `sys.exit(0)` after recording false flags. That process exit is not a successful all-checks gate.

False parent flags, independently confirmed as probe defects:

1. `midnight_summary.all_members_match` is false. `check_crate_packet` resolved `extracted = packet / rec["path"]`. Midnight receipt paths are relative to `p31-zkir-dependency-source-preparation`, not each package directory. The parent therefore looked for files that do not exist at that doubled path. blst receipt paths are packet-relative, and the parent blst member check stayed true. This is not a crate-member mismatch. Root's earlier archive/member replay of 464 Midnight members remains separate evidence.

2. Four static `byte_check` flags are false because the probe used the wrong 0-based index for claimed 1-based lines:
   - preprocess inputs/outputs: checked `ir_vm[489]`/`[490]` (1-based 490/491) instead of lines 489/490
   - circuit public-input assert: checked `ir_vm[785]` (1-based 786, the closing brace) instead of line 785
   - Poseidon chip init: listed line 559 and checked `[558]` (absorb) instead of 1-based 558
   - blst `BLS12_381_r` limbs: two `TO_LIMB_T` values share each line; the parent looked for the second limb on the next line

Those four false flags and the Midnight member-match false flag receive zero credit. They are not source defects.

The closeout copy `closeout/probes/binding-probe-corrected.py` SHA-256 `c9b2d0be36d2a360cd97755e525b573cce033484fafa6046ee1d0eef5e7facf7` resolves Midnight members from the preparation root and uses 1-based line offsets. It asserts the relevant booleans and exits 0 only if every asserted boolean is true. On this rerun, `failed_assertions` is empty: 464 Midnight members match extracted bytes, 159 blst members match, and all static claim byte checks are true. That exit 0 is not a relabel of the parent false flags.

## Static source facts, not semantic proofs

Byte-backed navigation, with 9 source files and 14 exact anchors matching recorded hashes and excerpts:

- `transient_commit` puts `opening` first, then `value.field_repr`.
- `FieldRepr` for `[Fr]` writes `writer.write(self)` with no length prefix.
- ZKIR preprocess concatenates `preimage.inputs` then `outputs` and calls `transient_commit`.
- The circuit path builds `vec![comm_comm_rand]` then inputs then outputs, calls `std.poseidon`, and asserts equality with `public_inputs[1]`.
- CPU `PoseidonChip::hash` and circuit `PoseidonChip::hash` both initialize with `Some(inputs.len())`. That is source alignment. It is not a generated-constraint correspondence proof and not a runtime execution.

Field aliases must not be substituted by Rust identifier:

- Wrapper `transient_crypto::Fr` is `pub struct Fr(pub outer::Scalar)` and `outer::Scalar = midnight_curves::Fq`.
- Standard-library circuit field is `type F = midnight_curves::Fq`.
- Embedded scalar is `midnight_curves::Fr` (Jubjub limbs, modulus `0x0e7db4ea6533afa906673b0101343b00a6682093ccc81082d0970e5ed6f72cb7`). It is distinct from Fq.
- `midnight_curves::Fq` wraps `blst_fr` and calls `blst_fr_add` / `blst_fr_mul`. Fq modulus hex `0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001` agrees with the four little-endian limbs and with blst `BLS12_381_r`. `blst_fr_mul` binds `mul_mont_sparse_256(..., BLS12_381_r, r0)`.

These identities are source agreement. They are not a field-arithmetic proof, not integer-financial refinement, and not adapter acceptance.

## PiSkip and remaining interface work

`PiSkip` preprocess records a skip and moves `public_transcript_inputs_idx` when the guard is false, otherwise checks associated public-transcript values against `pis`. The circuit arm is `I::PiSkip { .. } => {}`. An empty circuit arm is a witness / public-instance / skip correspondence boundary. It is not, by itself, a soundness proof or a circuit bug. Source index and resource assumptions, and bounded-integer-to-Fq refinement, need an explicit adapter contract.

## blst matcher versus crate bytes

Root blst verification attempt 1 failed because unanchored `pub fn blst_fr_mul` also matches `blst_fr_mul_by_3` at bindings.rs:265. That failure is retained with `credit` false. Attempt 2 used `pub fn blst_fr_mul(` and verified 159 members plus seven unique static anchors. The failed matcher is not a crate defect. Navigation listed blst 0.3.16 as an uncaptured external boundary at that packet's time. The later blst capture closes that named source gap. It does not capture the remaining non-Midnight lock members, including `cc`, `glob`, `threadpool`, and `zeroize`.

`build.rs` still contains `__BLST_NO_ASM__` and `portable` / `force-adx` selection. Platform, feature, and assembly selection for any installed binary remain unverified. Source-to-binary equivalence is a disclosed assumption. This review does not invent a mandatory reproducible-build or universal compiler-correctness gate.

## Licenses and VCS

License fields are heterogeneous and are source metadata, not a legal review.

- Several `Cargo.toml.orig` files use workspace license inheritance (`license.workspace = true`).
- `midnight-circuits` and `midnight-zk-stdlib` use `license-file.workspace = true`. Receipt `license` is null. Registry records `non-standard`. Each extracted `LICENSE` file is Apache License 2.0, SHA-256 `c71d239df91726fc519c6eb72d318ec65820627232b2f796219e87dcf35d0ab4`.
- Other Midnight receipts carry `Apache-2.0`, `MIT/Apache-2.0`, or `MIT OR Apache-2.0` strings that agree with registry. Not every package contains a standalone `LICENSE` file.
- blst registry, orig manifest, and receipt all say Apache-2.0. Published VCS is git `e7f90de551e8df682f3cc99067d204d8b90d27ad`, `path_in_vcs` `bindings/rust`.

Captured `.cargo_vcs_info.json` agrees with each receipt VCS object.

## Historical readiness and open gates

Tasks 32.1–32.4 remain historical readiness records. Task 32.3 remains the blocked-unavailable interface record. These 13 named crate captures cannot close adapter 32.7, adapter review 32.9, full P31, P19, P20, or the full program. All captures are pure acquisition. No circuit, proof, key, or real execution ran here. Sealed mock artifact execution stays historical.

## Remaining obligations

These are already explicit. They are not new gates invented by this review.

1. Design and independently review a ZKIR JSON 2.0 interface/semantic contract, including opcode meanings, witness/public-input layout, `PiSkip` transcript/instance correspondence, and communications-commitment preimage order.
2. State bounded-integer-to-Fq refinement rather than treating field `Add`/`Mul`/`Neg` as financial integer arithmetic.
3. Keep source index/resource assumptions in the adapter contract.
4. Prove Compact kernel/harness to ZKIR correspondence. Distinguish snapshot `recordN` from pure `transitionN`.
5. Implement `lean/DefiKernel/Adapters/ZKIR.lean` against that pin, or keep task 32.7 `blocked_unavailable`.
6. Independently review actual adapter results (task 32.9).
7. Keep PCT certificate consumption blocked on accepted P20.
8. Treat uncaptured lock members and unverified native/build-script selection as remaining source-to-binary and closure assumptions.
9. P31 and whole-program acceptance remain false.
