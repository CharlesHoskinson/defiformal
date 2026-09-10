# P31 ZKIR source preparation

Root located and captured published `midnight-zkir` 2.1.0 source for the next interface review. This is source evidence; the ZKIR adapter and its semantic contract remain unaccepted.

The crate archive matches the crates.io checksum. Its `.cargo_vcs_info.json` pins Midnight ledger commit `6d1b0acb1d03e01bc0580ec10cd55e54cd813f5a`. All six comparable files match Git blob identities at that commit: the original Cargo manifest, four implementation files, and one test file. Cargo.lock, normalized Cargo.toml and VCS metadata remain separately hash-bound crate files.

The annotated `crate-zkir-2.1.0` tag targets `04a6105472777d0ded1fdab27f611738cd435fd9`; the `zkir-2.1.0` tag targets `9da0b63cde82b93ccf1132a943ce05a86de06fe2`. Both match the five inspected Rust files and differ in Cargo.toml. The `ledger-8.0.2` tag targets `dfb450d558d23100d056d2ba121fe2b865e1208c` and matches ir.rs, ir_vm.rs and lib.rs, while the manifest, main.rs and tests differ. The full comparisons and upstream trees are retained. Do not substitute one commit for another.

The installed tool hashes to `5443f87db07b7f19cc273380c224b77b4b7ca124deac6d54f7a165628fc5e1fc`. Its version string matches the crate version. A source-to-binary build binding is not established. The GitHub release endpoint for `zkir-2.1.0` returned HTTP404; the existing Git tag was retrieved successfully. The failed acquisition script and HTTP failure receipt are retained. Later comparison completion used the already downloaded bytes and did not rerun the failed acquisition.

`semantic-source-navigation.json` locates all twelve opcodes observed across the two frozen loan snapshot circuits. `ir.rs` defines JSON instruction fields and the version2.0 loader. `ir_vm.rs` contains both preprocessing and constraint construction. Preprocessing checks input count, index/boolean/bit constraints and transcript consumption; the communications commitment has additional input/output binding checks. These implementations give concrete material for interface review. They are not a formal specification already accepted by DeFiFormal.

Arithmetic is over a prime field; integer financial arithmetic requires its own range and refinement argument. Public-input declarations and `PiSkip` markers affect transcript processing. The snapshot wrapper circuits and the pure financial transitions remain distinct. `main.rs` shows that mock-compile loads the IR and obtains a cost model; it does not run the witness preprocessing or produce a cryptographic proof.

Next: independently review this exact source pin and its relationship to the installed tool; close relevant dependency/interface definitions; bind public inputs, witness layout, commitments and the emitted instruction subset; then implement and prove the actual Compact-to-ZKIR adapter correspondence. Earlier accepted readiness records remain historical. Task32.7 and fullP31 remain open.

Sources: [published crate](https://docs.rs/crate/midnight-zkir/2.1.0/source/), [pinned ledger source](https://github.com/midnightntwrk/midnight-ledger/tree/6d1b0acb1d03e01bc0580ec10cd55e54cd813f5a/zkir). Upstream Apache2.0 license is retained in `upstream-root/LICENSE`. No downloaded code was executed, compiled or installed by this preparation.
