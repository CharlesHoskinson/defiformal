# P31 generated ZKIR interface preparation

At Moriarty commit7307349d0275af6fcb4144e1661d8b59d6b2663a, the unchanged materialize-mapping.mjs regenerated all nine checked-in loan/swap artifacts byte-identically. The captured source set has33 files. The loan harness compiles with Compact0.31.1, language0.23.0, runtime0.16.0, ledger-8.0.2 and --skip-zk. It is explicitly a test-only snapshot harness that stores disclosed output and moves no financial assets.

Compilation produced six files, including record0.zkir and record1.zkir. Both identify JSON ZKIR version2.0. format-observations.json records their exact top-level keys, input and instruction counts, and encountered instruction field names. This is an observed generated subset, not a complete opcode specification or semantic model.

The bundled midnight-zkir2.1.0 accepted both circuits with mock-compile, reporting5297 rows at k13 and2941 rows at k12. It emitted two .bzkir files (955 and395 bytes). No prover/verifier keys or cryptographic proofs were generated. Mock compilation is separate from the initial --skip-zk compiler invocation and from proof verification or ledger execution.

Three negative controls were retained. Major version999 is refused because the field expects u8, so it tests representation. Major255 fits u8 and is separately refused as Unhandled version255.0. An unknown opcode is refused with the recognized variant list. These outcomes show the bundled tool parses and checks these selected interface features; they do not establish general correctness of ZKIR constraints.

inputs.json binds each source to Git blob and SHA256 identities. commands.json and compile-receipt.json bind actual generator/compiler commands, versions, source/generated artifacts and the execve trace. mock-format-validation retains exact valid and mutated inputs, raw outputs, emitted .bzkir files and command receipts. All source hashes were reverified after execution.

Independent review is pending. This supplies concrete artifact-format evidence for the next ZKIR interface review. The accepted readiness record still leaves adapter task32.7 blocked_unavailable until a suitable verified interface/semantic contract is accepted. P31, P20-dependent certificate consumption and full-program completion remain open.
